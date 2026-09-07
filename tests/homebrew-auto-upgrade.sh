#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
test_dir="$(mktemp -d)"
trap 'rm -r "${test_dir}"' EXIT
export BREWUP_TEST_LOG="${test_dir}/upgrades"

brew() {
    case "$1" in
        outdated)
            printf '%s\n' 'Warning: Calling `postflight` is deprecated!' >&2
            case "${BREWUP_TEST_CASE}" in
                mixed) printf '%s\n' sample-app pinned-app ;;
                empty) ;;
                failed)
                    printf '%s\n' partial-result
                    printf '%s\n' 'Error: unable to enumerate casks' >&2
                    return 2
                    ;;
            esac
            ;;
        list) printf '%s\n' pinned-app ;;
        upgrade)
            if [[ "$2" == --cask ]]; then
                printf '%s\n' "${!#}" >> "${BREWUP_TEST_LOG}"
            fi
            ;;
        update|tap|autoremove|cleanup|doctor) ;;
        *) return 99 ;;
    esac
}

pgrep() { return 1; }
uname() { printf '%s\n' Linux; }
export -f brew pgrep uname

for scenario in mixed empty failed; do
    export BREWUP_TEST_CASE="${scenario}"
    : > "${BREWUP_TEST_LOG}"
    result=0
    bash "${repo_root}/scripts/homebrew-auto-upgrade.sh" > "${test_dir}/stdout" 2> "${test_dir}/stderr" || result=$?
    grep -Fq 'Warning: Calling `postflight` is deprecated!' "${test_dir}/stderr"
    case "${scenario}" in
        mixed)
            [[ "${result}" -eq 0 ]]
            [[ "$(cat "${BREWUP_TEST_LOG}")" == sample-app ]]
            ;;
        empty)
            [[ "${result}" -eq 0 ]]
            [[ ! -s "${BREWUP_TEST_LOG}" ]]
            ;;
        failed)
            [[ "${result}" -eq 1 ]]
            [[ ! -s "${BREWUP_TEST_LOG}" ]]
            grep -Fxq 'Error: unable to enumerate casks' "${test_dir}/stderr"
            grep -Fxq 'FAIL brew outdated casks status=2' "${test_dir}/stderr"
            ;;
    esac
done

printf '%s\n' 'PASS homebrew auto upgrade tests'
