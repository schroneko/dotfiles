#!/bin/bash
# Keep Homebrew apps and mise tools the same on every Mac.
#
#   scripts/sync.sh               sync (the LaunchAgent runs this every hour)
#   scripts/sync.sh --dry-run     print what would change; touches nothing
#   scripts/sync.sh --init-state  record what is installed now as the last-synced state
#
# Apps you install or uninstall on this Mac (compared with the last sync) are
# added to / removed from Brewfile. Then Brewfile is applied: missing entries
# are installed and anything not in Brewfile is uninstalled. Brewfile.ignore
# lists names that are never tracked or touched.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
BREWFILE="$REPO/Brewfile"
IGNORE="$REPO/Brewfile.ignore"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/brew-state.tsv"
LOCK="${TMPDIR:-/tmp}/dotfiles-sync.lock"
MAX_REMOVALS=10
TRUSTED_TAPS="schroneko/cdpclick schroneko/exbright schroneko/hithint schroneko/nicevoice-app"
PINNED_CASKS="google-chrome"

export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
unset LC_ALL
export HOMEBREW_NO_AUTO_UPDATE=1 GIT_LFS_SKIP_SMUDGE=1 LC_COLLATE=C

DRY=0 INIT=0 FAILED=0
case "${1:-}" in
    "") ;;
    --dry-run) DRY=1 ;;
    --init-state) INIT=1 ;;
    *) echo "usage: $0 [--dry-run|--init-state]" >&2; exit 2 ;;
esac

log() { printf '[%s] %s\n' "$(date '+%F %T')" "$*"; }
warn() { log "WARN: $*"; FAILED=1; }
count() { wc -l < "$1" | tr -d ' '; }
show() { log "$1 ($(count "$2")):"; sed 's/^/    /' "$2"; }

TMP="$(mktemp -d)"
cleanup() {
    rm -rf "$TMP"
    if [[ "$(cat "$LOCK/pid" 2>/dev/null)" == "$$" ]]; then rm -rf "$LOCK"; fi
}
if ! mkdir "$LOCK" 2>/dev/null; then
    if kill -0 "$(cat "$LOCK/pid" 2>/dev/null)" 2>/dev/null; then
        log "another sync is running"; rm -rf "$TMP"; exit 0
    fi
    rm -rf "$LOCK"; mkdir "$LOCK"
fi
echo $$ > "$LOCK/pid"
trap cleanup EXIT

# tap/brew/cask lines of a Brewfile, minus anything named in Brewfile.ignore.
entries() {
    awk -F'"' -v ignore="$IGNORE" '
        BEGIN { while ((getline l < ignore) > 0) { sub(/#.*/, "", l); gsub(/[[:space:]]/, "", l); if (l != "") skip[l] = 1 } }
        /^(tap|brew|cask) "/ { b = $2; sub(/.*\//, "", b); if (!($2 in skip) && !(b in skip)) print }
    ' "$1"
}
# "kind<TAB>name" keys of a Brewfile.
keys() { entries "$1" | awk -F'"' '{ split($1, p, " "); print p[1] "\t" $2 }' | sort -u; }

# What is installed on request right now, as Brewfile keys. Refuses an empty result.
installed_keys() {
    brew bundle dump --force --file="$TMP/installed.Brewfile" --no-vscode --no-go --no-cargo --no-uv >/dev/null
    keys "$TMP/installed.Brewfile" > "$1"
    if [[ ! -s "$1" ]]; then log "brew bundle dump returned nothing; aborting"; exit 1; fi
}

# Rewrite a Brewfile as header + entries sorted tap, brew, cask.
write_brewfile() {
    {
        echo "# Apps shared by every Mac. scripts/sync.sh adds what you install and drops what you uninstall."
        echo
        awk -F'"' '/^(tap|brew|cask) "/ { split($1, p, " "); o = (p[1] == "tap" ? 0 : (p[1] == "brew" ? 1 : 2)); print o "\t" $2 "\t" $0 }' "$1" \
            | sort -t "$(printf '\t')" -u -k1,1n -k2,2 | cut -f3-
    } > "$2"
}

# Three-way merge: local installs/uninstalls since the last sync go into the Brewfile copy.
merge_local_changes() {
    local work="$1" kind name
    keys "$work" > "$TMP/desired"
    if [[ -f "$STATE" ]]; then
        sort -u "$STATE" > "$TMP/last"
    else
        comm -12 "$TMP/installed" "$TMP/desired" > "$TMP/last"  # first run: never uninstall
    fi
    comm -13 "$TMP/last" "$TMP/installed" | comm -23 - "$TMP/desired" > "$TMP/added"
    comm -23 "$TMP/last" "$TMP/installed" | comm -12 - "$TMP/desired" > "$TMP/removed"
    show "installed here, adding to Brewfile" "$TMP/added"
    show "uninstalled here, removing from Brewfile" "$TMP/removed"
    if (( $(count "$TMP/removed") > MAX_REMOVALS )); then
        log "more than $MAX_REMOVALS removals looks wrong; aborting"; exit 1
    fi
    while IFS="$(printf '\t')" read -r kind name; do
        awk -F'"' -v k="$kind" -v n="$name" '{ split($1, p, " ") } p[1] == k && $2 == n { print; exit }' "$TMP/installed.Brewfile" >> "$work"
    done < "$TMP/added"
    while IFS="$(printf '\t')" read -r kind name; do
        awk -F'"' -v k="$kind" -v n="$name" '{ split($1, p, " ") } !(p[1] == k && $2 == n)' "$work" > "$work.tmp"
        mv "$work.tmp" "$work"
    done < "$TMP/removed"
    keys "$work" > "$TMP/desired"
}

# What applying the Brewfile copy would install / uninstall.
plan_apply() {
    {
        brew tap | awk '{ print "tap\t" $0 }'
        brew list --formula --full-name | awk '{ print "brew\t" $0 }'
        brew list --cask --full-name | awk '{ print "cask\t" $0 }'
    } | sort -u > "$TMP/present"
    comm -23 "$TMP/desired" "$TMP/present" > "$TMP/install"
    comm -23 "$TMP/installed" "$TMP/desired" > "$TMP/uninstall"
    show "to install" "$TMP/install"
    show "to uninstall" "$TMP/uninstall"
}

trust_taps() {
    local tap
    for tap in $TRUSTED_TAPS; do
        if brew tap | grep -Fxq "$tap"; then brew trust --tap "$tap" >/dev/null || warn "trust $tap"; fi
    done
}

apply_brewfile() {
    local k kind name casks
    trust_taps
    if [[ -s "$TMP/install" ]]; then
        entries "$BREWFILE" > "$TMP/apply.Brewfile"
        brew bundle install --no-upgrade --file="$TMP/apply.Brewfile" || warn "brew bundle install"
    fi
    if (( $(count "$TMP/uninstall") > MAX_REMOVALS )); then
        warn "more than $MAX_REMOVALS uninstalls looks wrong; skipping them"
    else
        for k in cask brew tap; do
            while IFS="$(printf '\t')" read -r kind name; do
                log "uninstalling $kind $name"
                case "$kind" in
                    cask) brew uninstall --cask "$name" ;;
                    brew) brew uninstall --formula "$name" ;;
                    tap) brew untap "$name" ;;
                esac || warn "uninstall $kind $name"
            done < <(grep "^$k	" "$TMP/uninstall" || true)
        done
    fi
    trust_taps
    for name in $PINNED_CASKS; do
        if brew list --cask "$name" >/dev/null 2>&1 && ! brew list --cask --pinned 2>/dev/null | grep -Fxq "$name"; then
            brew pin --cask "$name" || warn "pin $name"
        fi
    done
    brew upgrade --formula || warn "brew upgrade --formula"
    # Casks with auto_updates update themselves; upgrading them here left empty apps behind.
    casks="$(brew info --json=v2 --installed --cask | jq -r '.casks[] | select(.auto_updates != true) | .full_token' \
        | grep -Fxv -f <(brew list --cask --pinned 2>/dev/null; echo "-") || true)"
    if [[ -n "$casks" ]]; then
        # shellcheck disable=SC2086
        brew upgrade --cask $casks || warn "brew upgrade --cask"
    fi
    "$REPO/scripts/homebrew-approve-nested-apps.sh" --all || warn "nested app approval"
    # Drop every cached download and old version; nothing here needs them after install.
    brew cleanup --prune=all -q || warn "brew cleanup"
}

commit_and_push() {
    git -C "$REPO" add -- Brewfile
    if git -C "$REPO" diff --cached --quiet -- Brewfile; then return 0; fi
    git -C "$REPO" commit -q -m "sync state from $(scutil --get ComputerName 2>/dev/null || hostname -s)" -- Brewfile
    log "pushing"
    git -C "$REPO" push -q || { git -C "$REPO" pull --rebase --autostash -q && git -C "$REPO" push -q; } || warn "git push"
}

if (( INIT )); then
    mkdir -p "$(dirname "$STATE")"
    installed_keys "$TMP/installed"
    cp "$TMP/installed" "$STATE"
    log "recorded $(count "$STATE") installed entries in $STATE"
    exit 0
fi

if (( DRY )); then
    log "dry run: not pulling; using the Brewfile as checked out"
else
    log "pulling dotfiles"
    git -C "$REPO" pull --rebase --autostash -q || { log "git pull failed; aborting"; exit 1; }
    brew update -q || warn "brew update"
fi

installed_keys "$TMP/installed"
cp "$BREWFILE" "$TMP/Brewfile"
merge_local_changes "$TMP/Brewfile"
plan_apply

if (( DRY )); then
    log "would then: brew upgrade --formula, upgrade casks without auto_updates, approve nested apps, brew cleanup --prune=all, mise install/upgrade, commit and push"
    exit 0
fi

write_brewfile "$TMP/Brewfile" "$BREWFILE"
apply_brewfile
log "mise install / upgrade"
{ mise install && mise upgrade; } || warn "mise"
installed_keys "$TMP/installed"
mkdir -p "$(dirname "$STATE")"
cp "$TMP/installed" "$STATE"

commit_and_push
if (( FAILED )); then log "sync finished with warnings"; else log "sync finished"; fi
exit "$FAILED"
