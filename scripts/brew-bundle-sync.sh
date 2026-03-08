#!/usr/bin/env bash
set -euo pipefail

cleanup=0
dry_run=0

for arg in "$@"; do
    case "$arg" in
        --cleanup)
            cleanup=1
            ;;
        --dry-run)
            dry_run=1
            ;;
        *)
            echo "Usage: $0 [--cleanup] [--dry-run]" >&2
            exit 2
            ;;
    esac
done

if ! command -v brew >/dev/null 2>&1; then
    echo "Skipping brew bundle: brew not found"
    exit 0
fi

brewfile="${HOME}/.Brewfile"
if [[ ! -f "${brewfile}" ]]; then
    echo "Skipping brew bundle: ${brewfile} not found"
    exit 0
fi

os="$(uname -s)"

linux_brewfile() {
    grep -v '^cask ' "${brewfile}" \
        | grep -v '"container"' \
        | grep -v '"xcodegen"' \
        | grep -v '"mint"'
}

if [[ "${os}" == "Darwin" ]]; then
    cmd=(brew bundle --global)
    if (( cleanup )); then
        cmd+=(--cleanup)
    fi

    if (( dry_run )); then
        printf '+'
        printf ' %q' "${cmd[@]}"
        printf '\n'
        exit 0
    fi

    "${cmd[@]}"
    exit 0
fi

if [[ "${os}" == "Linux" ]]; then
    if (( cleanup )); then
        echo "Skipping cleanup on Linux: filtered Brewfile is not a complete package set"
    fi

    if (( dry_run )); then
        linux_brewfile
        exit 0
    fi

    linux_brewfile | brew bundle --file=-
    exit 0
fi

echo "Skipping brew bundle: unsupported OS ${os}"
