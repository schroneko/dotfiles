#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_SLUG="github.com/schroneko/dotfiles"
MANAGED_FILES=(
    ".Brewfile"
    ".Brewfile.shared"
    ".Brewfile.darwin"
    ".Brewfile.linux"
    "ghq/repos.txt"
)

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin:$PATH"

if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

LOCKDIR="${TMPDIR:-/tmp}/dotfiles-sync.lock"
cleanup() {
    rmdir "${LOCKDIR}" 2>/dev/null || true
}

acquire_lock() {
    if ! mkdir "${LOCKDIR}" 2>/dev/null; then
        log "sync already running; exiting"
        exit 0
    fi
}

ghq_root() {
    if command -v ghq >/dev/null 2>&1; then
        ghq root
    else
        printf '%s\n' "$HOME/ghq"
    fi
}

refresh_manifests() {
    if command -v brew >/dev/null 2>&1; then
        BREWFILE_SYNC_DISABLE=1 "${REPO_ROOT}/scripts/brewfile-manager.sh" refresh
    fi

    mkdir -p "${REPO_ROOT}/ghq"
    {
        echo "# Managed by scripts/dotfiles-sync.sh."
        echo "# Repositories are added and updated automatically. Deletions are not propagated."
        echo
        if command -v ghq >/dev/null 2>&1; then
            ghq list | LC_ALL=C sort
        fi
    } > "${REPO_ROOT}/ghq/repos.txt"
}

sync_dotfiles_repo() {
    log "pulling dotfiles repo"
    git -C "${REPO_ROOT}" pull --rebase --autostash
}

apply_homebrew_state() {
    if ! command -v brew >/dev/null 2>&1; then
        log "brew not found; skipping package sync"
        return 0
    fi

    log "applying brew bundle"
    BREWFILE_SYNC_DISABLE=1 "${REPO_ROOT}/scripts/brew-bundle-sync.sh" --cleanup
}

clone_missing_repos() {
    if ! command -v ghq >/dev/null 2>&1; then
        log "ghq not found; skipping repo sync"
        return 0
    fi

    local ghq_root_dir
    ghq_root_dir="$(ghq_root)"
    local repo
    while IFS= read -r repo; do
        [[ -n "${repo}" && "${repo}" != \#* ]] || continue

        if [[ -d "${ghq_root_dir}/${repo}/.git" ]]; then
            continue
        fi

        log "cloning ${repo}"
        ghq get "${repo}" || log "failed to clone ${repo}"
    done < "${REPO_ROOT}/ghq/repos.txt"
}

pull_clean_repos() {
    if ! command -v ghq >/dev/null 2>&1; then
        return 0
    fi

    local ghq_root_dir
    ghq_root_dir="$(ghq_root)"
    local repo
    local repo_path
    local branch

    while IFS= read -r repo; do
        [[ -n "${repo}" && "${repo}" != \#* ]] || continue
        [[ "${repo}" == "${REPO_SLUG}" ]] && continue

        repo_path="${ghq_root_dir}/${repo}"
        [[ -d "${repo_path}/.git" ]] || continue

        if [[ -n "$(git -C "${repo_path}" status --porcelain 2>/dev/null)" ]]; then
            log "skipping dirty repo ${repo}"
            continue
        fi

        branch="$(git -C "${repo_path}" symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
        if [[ -z "${branch}" ]]; then
            log "skipping detached repo ${repo}"
            continue
        fi

        if ! git -C "${repo_path}" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' >/dev/null 2>&1; then
            log "skipping repo without upstream ${repo}"
            continue
        fi

        log "pulling ${repo}"
        git -C "${repo_path}" pull --ff-only || log "failed to pull ${repo}"
    done < "${REPO_ROOT}/ghq/repos.txt"
}

stage_managed_files() {
    local path
    for path in "${MANAGED_FILES[@]}"; do
        git -C "${REPO_ROOT}" add -- "${path}"
    done
}

commit_and_push_if_needed() {
    stage_managed_files

    if git -C "${REPO_ROOT}" diff --cached --quiet -- "${MANAGED_FILES[@]}"; then
        log "no managed changes to commit"
        return 0
    fi

    local host
    host="$(scutil --get ComputerName 2>/dev/null || hostname -s || hostname)"

    log "committing managed state"
    git -C "${REPO_ROOT}" commit -m "sync state from ${host}"

    log "pushing dotfiles repo"
    if git -C "${REPO_ROOT}" push; then
        return 0
    fi

    log "push rejected; retrying after rebase"
    git -C "${REPO_ROOT}" pull --rebase --autostash
    git -C "${REPO_ROOT}" push
}

main() {
    acquire_lock
    trap cleanup EXIT

    sync_dotfiles_repo
    apply_homebrew_state
    clone_missing_repos
    pull_clean_repos
    refresh_manifests
    commit_and_push_if_needed
    log "sync complete"
}

main "$@"
