#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin:$PATH"

if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

cleanup=1
dry_run=0
trusted_taps=(
    "schroneko/cdpclick"
    "schroneko/claude-code-updater"
    "schroneko/exbright"
    "schroneko/hithint"
    "schroneko/nicevoice-app"
)
pinned_casks=(
    "google-chrome"
)

for arg in "$@"; do
    case "$arg" in
        --cleanup)
            cleanup=1
            ;;
        --no-cleanup)
            cleanup=0
            ;;
        --dry-run)
            dry_run=1
            ;;
        *)
            echo "Usage: $0 [--cleanup] [--no-cleanup] [--dry-run]" >&2
            exit 2
            ;;
    esac
done

if ! command -v brew >/dev/null 2>&1; then
    echo "Skipping brew bundle: brew not found"
    exit 0
fi

trust_managed_taps() {
    local tap

    for tap in "${trusted_taps[@]}"; do
        if brew tap | grep -Fxq "${tap}"; then
            brew trust --tap "${tap}"
        fi
    done
}

pin_managed_casks() {
    local cask
    local currently_pinned

    currently_pinned="$(brew list --cask --pinned 2>/dev/null || true)"

    for cask in "${pinned_casks[@]}"; do
        if ! brew list --cask "${cask}" >/dev/null 2>&1; then
            continue
        fi
        if grep -Fxq "${cask}" <<< "${currently_pinned}"; then
            continue
        fi
        brew pin --cask "${cask}"
    done
}

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
shared_brewfile="${repo_root}/.Brewfile.shared"
darwin_brewfile="${repo_root}/.Brewfile.darwin"
linux_brewfile="${repo_root}/.Brewfile.linux"
ignore_file="${repo_root}/.Brewfile.ignore"
nested_app_approval="${repo_root}/scripts/homebrew-approve-nested-apps.sh"

filter_ignored() {
    awk -F'"' -v ignore_file="${ignore_file}" '
        function base(name, copy) {
            copy = name
            sub(/^.*\//, "", copy)
            return copy
        }
        BEGIN {
            while ((getline line < ignore_file) > 0) {
                sub(/#.*$/, "", line)
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
                if (line != "") ignored[line] = 1
            }
            close(ignore_file)
        }
        /^(tap|brew|cask) "/ {
            if ($2 in ignored || base($2) in ignored) next
        }
        { print }
    '
}

if [[ ! -f "${shared_brewfile}" ]]; then
    echo "Skipping brew bundle: ${shared_brewfile} not found"
    exit 0
fi

os="$(uname -s)"

write_effective_brewfile() {
    local target="$1"

    case "${os}" in
        Darwin)
            cat "${shared_brewfile}" "${darwin_brewfile}" ;;
        Linux)
            cat "${shared_brewfile}" "${linux_brewfile}" ;;
        *)
            return 1 ;;
    esac | grep -E '^(tap|brew|cask) ' | filter_ignored > "${target}"
}

if [[ "${os}" == "Darwin" ]]; then
    tmp_brewfile="$(mktemp)"
    trap 'rm -f "${tmp_brewfile}"' EXIT
    write_effective_brewfile "${tmp_brewfile}"

    if (( dry_run )); then
        cat "${tmp_brewfile}"
        echo
        printf '+ brew bundle --file=%q\n' "${tmp_brewfile}"
        if (( cleanup )); then
            printf '+ brew bundle cleanup --force --formula --tap --file=%q\n' "${tmp_brewfile}"
        fi
        printf '+ %q --all\n' "${nested_app_approval}"
        exit 0
    fi

    trust_managed_taps
    pin_managed_casks
    bundle_status=0
    approval_status=0
    brew bundle --file="${tmp_brewfile}" || bundle_status=$?
    "${nested_app_approval}" --all || approval_status=$?
    if (( bundle_status != 0 )); then
        exit "${bundle_status}"
    fi
    if (( approval_status != 0 )); then
        exit "${approval_status}"
    fi
    if (( cleanup )); then
        brew bundle cleanup --force --formula --tap --file="${tmp_brewfile}"
    fi
    trust_managed_taps
    exit 0
fi

if [[ "${os}" == "Linux" ]]; then
    tmp_brewfile="$(mktemp)"
    trap 'rm -f "${tmp_brewfile}"' EXIT
    write_effective_brewfile "${tmp_brewfile}"

    if (( dry_run )); then
        cat "${tmp_brewfile}"
        echo
        printf '+ brew bundle --file=%q\n' "${tmp_brewfile}"
        if (( cleanup )); then
            printf '+ brew bundle cleanup --force --formula --tap --file=%q\n' "${tmp_brewfile}"
        fi
        exit 0
    fi

    trust_managed_taps
    pin_managed_casks
    brew bundle --file="${tmp_brewfile}"
    if (( cleanup )); then
        brew bundle cleanup --force --formula --tap --file="${tmp_brewfile}"
    fi
    trust_managed_taps
    exit 0
fi

echo "Skipping brew bundle: unsupported OS ${os}"
