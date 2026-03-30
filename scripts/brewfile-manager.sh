#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHARED_PATH="${REPO_ROOT}/.Brewfile.shared"
DARWIN_PATH="${REPO_ROOT}/.Brewfile.darwin"
LINUX_PATH="${REPO_ROOT}/.Brewfile.linux"
COMBINED_PATH="${REPO_ROOT}/.Brewfile"
DARWIN_ONLY_FORMULAE=("container" "mint" "xcodegen")
MACOS_VARIATION_PATTERN='(^|[[:space:]])(arm64_|x86_64_|intel_)?(tahoe|sequoia|sonoma|ventura|monterey|big_sur|catalina)([[:space:]]|$)'
TRACK_TMPDIR=""

cleanup() {
    if [[ -n "${TRACK_TMPDIR}" && -d "${TRACK_TMPDIR}" ]]; then
        rm -rf "${TRACK_TMPDIR}"
    fi
}

extract_entries() {
    local path="$1"
    if [[ -f "${path}" ]]; then
        grep -E '^(tap|brew|cask) ' "${path}" || true
    fi
}

sorted_entries_from_file() {
    local path="$1"
    [[ -f "${path}" ]] || return 0

    awk -F'"' '
        /^(tap|brew|cask) "/ {
            split($1, parts, " ")
            kind = parts[1]
            order = (kind == "tap" ? 0 : (kind == "brew" ? 1 : 2))
            printf "%d\t%s\t%s\n", order, $2, $0
        }
    ' "${path}" | LC_ALL=C sort -t $'\t' -k1,1n -k2,2 | cut -f3-
}

write_component() {
    local path="$1"
    local description="$2"
    local entries_file="$3"

    {
        echo "# Managed by scripts/brewfile-manager.sh."
        echo "# ${description}"
        echo
        sorted_entries_from_file "${entries_file}"
    } > "${path}"
}

render_combined() {
    {
        echo "# Managed by scripts/brewfile-manager.sh."
        echo "# Formulae, taps, and cross-platform casks are shared by default. Darwin-only apps and overrides live in .Brewfile.darwin."
        echo
        echo "# Shared packages"
        sorted_entries_from_file "${SHARED_PATH}"
        echo
        echo "# Darwin-only packages"
        sorted_entries_from_file "${DARWIN_PATH}"
        echo
        echo "# Linux-only packages"
        sorted_entries_from_file "${LINUX_PATH}"
    } > "${COMBINED_PATH}"
}

dump_current_state() {
    local os_name="$1"
    local target="$2"
    local env_prefix=("env" "BREWFILE_SYNC_DISABLE=1" "HOMEBREW_NO_AUTO_UPDATE=1")
    local cmd=(
        brew bundle dump --force "--file=${target}"
        --no-vscode --no-go --no-cargo --no-uv
    )

    if [[ "${os_name}" == "Linux" ]]; then
        cmd+=(--no-flatpak)
    fi

    "${env_prefix[@]}" "${cmd[@]}" >/dev/null
}

entry_key() {
    local line="$1"
    sed -nE 's/^(tap|brew|cask) "([^"]+)".*/\1\t\2/p' <<< "${line}"
}

entry_exists_exact() {
    local file="$1"
    local kind="$2"
    local name="$3"

    awk -F'"' -v kind="${kind}" -v name="${name}" '
        /^(tap|brew|cask) "/ {
            split($1, parts, " ")
            if (parts[1] == kind && $2 == name) {
                found = 1
                exit
            }
        }
        END { exit(found ? 0 : 1) }
    ' "${file}"
}

remove_exact_entry() {
    local file="$1"
    local kind="$2"
    local name="$3"
    local tmp="${file}.tmp"

    awk -F'"' -v kind="${kind}" -v name="${name}" '
        /^(tap|brew|cask) "/ {
            split($1, parts, " ")
            if (parts[1] == kind && $2 == name) {
                next
            }
        }
        { print }
    ' "${file}" > "${tmp}"
    mv "${tmp}" "${file}"
}

basename_or_self() {
    local value="$1"
    if [[ "${value}" == */* ]]; then
        printf '%s\n' "${value##*/}"
    else
        printf '%s\n' "${value}"
    fi
}

detect_entry_line() {
    local file="$1"
    local kind="$2"
    local candidate="$3"

    awk -F'"' -v kind="${kind}" -v candidate="${candidate}" '
        function base(name, copy) {
            copy = name
            sub(/^.*\//, "", copy)
            return copy
        }
        /^(tap|brew|cask) "/ {
            split($1, parts, " ")
            entry_kind = parts[1]
            entry_name = $2
            if (entry_kind == kind && (entry_name == candidate || base(entry_name) == candidate)) {
                print
                exit
            }
        }
    ' "${file}"
}

detect_installed_entry() {
    local current_state="$1"
    local name="$2"
    local explicit_kind="${3:-}"
    local kinds=()
    local candidate
    local kind
    local line

    if [[ -n "${explicit_kind}" ]]; then
        kinds=("${explicit_kind}")
    else
        kinds=("brew" "cask")
    fi

    for candidate in "${name}" "$(basename_or_self "${name}")"; do
        for kind in "${kinds[@]}"; do
            line="$(detect_entry_line "${current_state}" "${kind}" "${candidate}")"
            if [[ -n "${line}" ]]; then
                printf '%s\n' "${line}"
                return 0
            fi
        done
    done

    return 1
}

remove_named_entries() {
    local file="$1"
    local name="$2"
    local explicit_kind="${3:-}"
    local kinds=()
    local candidate
    local kind

    if [[ -n "${explicit_kind}" ]]; then
        kinds=("${explicit_kind}")
    else
        kinds=("brew" "cask" "tap")
    fi

    for candidate in "${name}" "$(basename_or_self "${name}")"; do
        for kind in "${kinds[@]}"; do
            local tmp="${file}.tmp"
            awk -F'"' -v kind="${kind}" -v candidate="${candidate}" '
                function base(name, copy) {
                    copy = name
                    sub(/^.*\//, "", copy)
                    return copy
                }
                /^(tap|brew|cask) "/ {
                    split($1, parts, " ")
                    entry_kind = parts[1]
                    entry_name = $2
                    if (entry_kind == kind && (entry_name == candidate || base(entry_name) == candidate)) {
                        next
                    }
                }
                { print }
            ' "${file}" > "${tmp}"
            mv "${tmp}" "${file}"
        done
    done
}

add_or_replace_entry() {
    local file="$1"
    local line="$2"
    local key
    local kind
    local name

    key="$(entry_key "${line}")"
    kind="${key%%$'\t'*}"
    name="${key#*$'\t'}"

    remove_exact_entry "${file}" "${kind}" "${name}"
    printf '%s\n' "${line}" >> "${file}"
}

probe_cask_platform_support() {
    local output_file="$1"
    shift
    local tokens=("$@")

    : > "${output_file}"
    [[ ${#tokens[@]} -gt 0 ]] || return 0

    local probe_lines
    if ! probe_lines="$(
        HOMEBREW_NO_AUTO_UPDATE=1 brew info --json=v2 --variations --cask "${tokens[@]}" \
            | jq -r '
                .casks[]
                | [
                    .full_token,
                    (([.url] + [(.variations // {} | to_entries[]?.value.url // "")]) | map(ascii_downcase) | join(" ")),
                    ((.variations // {} | keys | map(ascii_downcase) | join(" ")))
                ]
                | @tsv
            '
    )"; then
        : > "${output_file}"
        return 0
    fi

    local token
    local urls
    local keys
    local linux_supported
    local macos_supported
    while IFS=$'\t' read -r token urls keys; do
        [[ -n "${token}" ]] || continue
        linux_supported=0
        macos_supported=0

        if [[ "${urls}" == *linux* ]]; then
            linux_supported=1
        fi
        if [[ "${urls}" == *darwin* || "${urls}" == *"/mac/"* || "${keys}" =~ ${MACOS_VARIATION_PATTERN} ]]; then
            macos_supported=1
        fi

        printf '%s\t%s\t%s\n' "${token}" "${linux_supported}" "${macos_supported}" >> "${output_file}"
    done <<< "${probe_lines}"
}

classify_target() {
    local os_name="$1"
    local kind="$2"
    local name="$3"
    local support_file="$4"

    if [[ "${kind}" == "cask" ]]; then
        local support
        local linux_supported=0
        local macos_supported=0

        support="$(awk -F'\t' -v name="${name}" '$1 == name { print $2 "\t" $3; exit }' "${support_file}")"
        if [[ -n "${support}" ]]; then
            linux_supported="${support%%$'\t'*}"
            macos_supported="${support#*$'\t'}"
        fi

        if [[ "${linux_supported}" == "1" && "${macos_supported}" == "1" ]]; then
            printf 'shared\n'
        elif [[ "${os_name}" == "Darwin" ]]; then
            printf 'darwin\n'
        else
            printf 'linux\n'
        fi
        return 0
    fi

    if [[ "${os_name}" == "Darwin" && "${kind}" == "brew" ]]; then
        local formula
        for formula in "${DARWIN_ONLY_FORMULAE[@]}"; do
            if [[ "${name}" == "${formula}" ]]; then
                printf 'darwin\n'
                return 0
            fi
        done
    fi

    printf 'shared\n'
}

update_tracking() {
    local brew_args=("$@")
    [[ ${#brew_args[@]} -gt 0 ]] || return 0

    local command="${brew_args[0]}"
    local flags=()
    local names=()
    local arg
    for arg in "${brew_args[@]:1}"; do
        if [[ "${arg}" == -* ]]; then
            flags+=("${arg}")
        else
            names+=("${arg}")
        fi
    done
    [[ ${#names[@]} -gt 0 ]] || return 0

    local os_name
    os_name="$(uname -s)"
    [[ "${os_name}" == "Darwin" || "${os_name}" == "Linux" ]] || return 0

    TRACK_TMPDIR="$(mktemp -d)"

    local shared_entries="${TRACK_TMPDIR}/shared.entries"
    local darwin_entries="${TRACK_TMPDIR}/darwin.entries"
    local linux_entries="${TRACK_TMPDIR}/linux.entries"
    extract_entries "${SHARED_PATH}" > "${shared_entries}"
    extract_entries "${DARWIN_PATH}" > "${darwin_entries}"
    extract_entries "${LINUX_PATH}" > "${linux_entries}"

    local explicit_kind=""
    if [[ ${#flags[@]} -gt 0 && " ${flags[*]} " == *" --cask "* ]]; then
        explicit_kind="cask"
    elif [[ ${#flags[@]} -gt 0 && " ${flags[*]} " == *" --formula "* ]]; then
        explicit_kind="brew"
    elif [[ "${command}" == "tap" || "${command}" == "untap" ]]; then
        explicit_kind="tap"
    fi

    if [[ "${command}" == "install" || "${command}" == "reinstall" ]]; then
        local current_state="${TRACK_TMPDIR}/current.entries"
        dump_current_state "${os_name}" "${TRACK_TMPDIR}/current.Brewfile"
        extract_entries "${TRACK_TMPDIR}/current.Brewfile" > "${current_state}"

        local cask_tokens=()
        if [[ -z "${explicit_kind}" || "${explicit_kind}" == "cask" ]]; then
            local name
            local detected_line
            for name in "${names[@]}"; do
                detected_line="$(detect_installed_entry "${current_state}" "${name}" "cask" || true)"
                if [[ -n "${detected_line}" ]]; then
                    cask_tokens+=("$(entry_key "${detected_line}" | cut -f2)")
                fi
            done
        fi

        local cask_support="${TRACK_TMPDIR}/cask-support.tsv"
        probe_cask_platform_support "${cask_support}" ${cask_tokens[@]+"${cask_tokens[@]}"}

        local name
        local detected
        local key
        local kind
        local entry_name
        local line
        local target
        for name in "${names[@]}"; do
            detected="$(detect_installed_entry "${current_state}" "${name}" "${explicit_kind}" || true)"
            [[ -n "${detected}" ]] || continue

            key="$(entry_key "${detected}")"
            kind="${key%%$'\t'*}"
            entry_name="${key#*$'\t'}"
            line="${detected}"

            if entry_exists_exact "${shared_entries}" "${kind}" "${entry_name}"; then
                add_or_replace_entry "${shared_entries}" "${line}"
                continue
            fi
            if entry_exists_exact "${darwin_entries}" "${kind}" "${entry_name}"; then
                add_or_replace_entry "${darwin_entries}" "${line}"
                continue
            fi
            if entry_exists_exact "${linux_entries}" "${kind}" "${entry_name}"; then
                add_or_replace_entry "${linux_entries}" "${line}"
                continue
            fi

            target="$(classify_target "${os_name}" "${kind}" "${entry_name}" "${cask_support}")"
            case "${target}" in
                shared) add_or_replace_entry "${shared_entries}" "${line}" ;;
                darwin) add_or_replace_entry "${darwin_entries}" "${line}" ;;
                linux) add_or_replace_entry "${linux_entries}" "${line}" ;;
            esac
        done
    elif [[ "${command}" == "uninstall" || "${command}" == "remove" || "${command}" == "untap" ]]; then
        local name
        for name in "${names[@]}"; do
            remove_named_entries "${shared_entries}" "${name}" "${explicit_kind}"
            remove_named_entries "${darwin_entries}" "${name}" "${explicit_kind}"
            remove_named_entries "${linux_entries}" "${name}" "${explicit_kind}"
        done
    elif [[ "${command}" == "tap" ]]; then
        local name
        for name in "${names[@]}"; do
            add_or_replace_entry "${shared_entries}" "tap \"${name}\""
        done
    else
        return 0
    fi

    write_component "${SHARED_PATH}" "Shared formulae, taps, and cross-platform casks applied on both macOS and Linux." "${shared_entries}"
    write_component "${DARWIN_PATH}" "Darwin-only packages, including casks and formula overrides." "${darwin_entries}"
    write_component "${LINUX_PATH}" "Linux-only package overrides." "${linux_entries}"
    render_combined
}

refresh_tracking() {
    local os_name
    os_name="$(uname -s)"
    [[ "${os_name}" == "Darwin" || "${os_name}" == "Linux" ]] || return 0

    TRACK_TMPDIR="$(mktemp -d)"

    local current_brewfile="${TRACK_TMPDIR}/current.Brewfile"
    local current_entries="${TRACK_TMPDIR}/current.entries"
    local shared_entries="${TRACK_TMPDIR}/shared.entries"
    local darwin_entries="${TRACK_TMPDIR}/darwin.entries"
    local linux_entries="${TRACK_TMPDIR}/linux.entries"

    dump_current_state "${os_name}" "${current_brewfile}"
    extract_entries "${current_brewfile}" > "${current_entries}"

    : > "${shared_entries}"
    if [[ "${os_name}" == "Darwin" ]]; then
        : > "${darwin_entries}"
        extract_entries "${LINUX_PATH}" > "${linux_entries}"
    else
        : > "${linux_entries}"
        extract_entries "${DARWIN_PATH}" > "${darwin_entries}"
    fi

    local cask_tokens=()
    local line
    local key
    local kind
    local entry_name
    while IFS= read -r line; do
        [[ -n "${line}" ]] || continue
        key="$(entry_key "${line}")"
        kind="${key%%$'\t'*}"
        entry_name="${key#*$'\t'}"

        if [[ "${kind}" == "cask" ]]; then
            cask_tokens+=("${entry_name}")
        fi
    done < "${current_entries}"

    local cask_support="${TRACK_TMPDIR}/cask-support.tsv"
    probe_cask_platform_support "${cask_support}" ${cask_tokens[@]+"${cask_tokens[@]}"}

    local target
    while IFS= read -r line; do
        [[ -n "${line}" ]] || continue
        key="$(entry_key "${line}")"
        kind="${key%%$'\t'*}"
        entry_name="${key#*$'\t'}"
        target="$(classify_target "${os_name}" "${kind}" "${entry_name}" "${cask_support}")"

        case "${target}" in
            shared) add_or_replace_entry "${shared_entries}" "${line}" ;;
            darwin) add_or_replace_entry "${darwin_entries}" "${line}" ;;
            linux) add_or_replace_entry "${linux_entries}" "${line}" ;;
        esac
    done < "${current_entries}"

    write_component "${SHARED_PATH}" "Shared formulae, taps, and cross-platform casks applied on both macOS and Linux." "${shared_entries}"
    write_component "${DARWIN_PATH}" "Darwin-only packages, including casks and formula overrides." "${darwin_entries}"
    write_component "${LINUX_PATH}" "Linux-only package overrides." "${linux_entries}"
    render_combined
}

main() {
    local command="${1:-}"
    case "${command}" in
        render)
            render_combined
            ;;
        refresh)
            refresh_tracking
            ;;
        track)
            shift
            if [[ "${1:-}" == "--" ]]; then
                shift
            fi
            update_tracking "$@"
            ;;
        *)
            echo "Usage: $0 {render|refresh|track -- <brew args>}" >&2
            return 1
            ;;
    esac
}

trap cleanup EXIT
main "$@"
