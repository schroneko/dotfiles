#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin:$PATH"

if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

cleanup=1
dry_run=0

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

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
shared_brewfile="${repo_root}/.Brewfile.shared"
darwin_brewfile="${repo_root}/.Brewfile.darwin"
linux_brewfile="${repo_root}/.Brewfile.linux"

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
    esac | grep -E '^(tap|brew|cask) ' > "${target}"
}

if [[ "${os}" == "Darwin" ]]; then
    tmp_brewfile="$(mktemp)"
    trap 'rm -f "${tmp_brewfile}"' EXIT
    write_effective_brewfile "${tmp_brewfile}"

    cmd=(brew bundle --file="${tmp_brewfile}")
    if (( cleanup )); then
        cmd+=(--cleanup)
    fi

    if (( dry_run )); then
        cat "${tmp_brewfile}"
        echo
        printf '+'
        printf ' %q' "${cmd[@]}"
        printf '\n'
        exit 0
    fi

    "${cmd[@]}"
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

    brew bundle --file="${tmp_brewfile}"
    if (( cleanup )); then
        brew bundle cleanup --force --formula --tap --file="${tmp_brewfile}"
    fi
    exit 0
fi

echo "Skipping brew bundle: unsupported OS ${os}"
