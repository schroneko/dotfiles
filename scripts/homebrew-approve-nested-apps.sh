#!/usr/bin/env bash
set -uo pipefail

usage() {
    printf 'Usage: %s --all [--dry-run]\n' "$0" >&2
}

all_casks=0
dry_run=0

for arg in "$@"; do
    case "${arg}" in
        --all)
            all_casks=1
            ;;
        --dry-run)
            dry_run=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            usage
            exit 2
            ;;
    esac
done

if (( ! all_casks )); then
    usage
    exit 2
fi

uname_bin="${HOMEBREW_NESTED_APPROVAL_UNAME_BIN:-/usr/bin/uname}"

if [[ ! -x "${uname_bin}" ]]; then
    printf 'Homebrew nested app approval: uname not found: %s\n' "${uname_bin}" >&2
    exit 1
fi

if [[ "$("${uname_bin}" -s)" != "Darwin" ]]; then
    exit 0
fi

if [[ "$(/usr/bin/id -u)" -eq 0 ]]; then
    printf 'Homebrew nested app approval: refusing to run as root\n' >&2
    exit 1
fi

brew_bin="${HOMEBREW_NESTED_APPROVAL_BREW_BIN:-$(command -v brew 2>/dev/null || true)}"
jq_bin="${HOMEBREW_NESTED_APPROVAL_JQ_BIN:-$(command -v jq 2>/dev/null || true)}"
xattr_bin="${HOMEBREW_NESTED_APPROVAL_XATTR_BIN:-/usr/bin/xattr}"
spctl_bin="${HOMEBREW_NESTED_APPROVAL_SPCTL_BIN:-/usr/sbin/spctl}"
plutil_bin="${HOMEBREW_NESTED_APPROVAL_PLUTIL_BIN:-/usr/bin/plutil}"
find_bin="${HOMEBREW_NESTED_APPROVAL_FIND_BIN:-/usr/bin/find}"
realpath_bin="${HOMEBREW_NESTED_APPROVAL_REALPATH_BIN:-/bin/realpath}"
stat_bin="${HOMEBREW_NESTED_APPROVAL_STAT_BIN:-/usr/bin/stat}"

for required_tool in \
    "${brew_bin}" \
    "${jq_bin}" \
    "${xattr_bin}" \
    "${spctl_bin}" \
    "${plutil_bin}" \
    "${find_bin}" \
    "${realpath_bin}" \
    "${stat_bin}"; do
    if [[ -z "${required_tool}" || ! -x "${required_tool}" ]]; then
        printf 'Homebrew nested app approval: required tool unavailable: %s\n' "${required_tool:-unset}" >&2
        exit 1
    fi
done

runtime_dir="$(mktemp -d "${TMPDIR:-/tmp}/homebrew-nested-approval.XXXXXX")" || exit 1
metadata_file="${runtime_dir}/casks.json"

cleanup_runtime() {
    if [[ -d "${runtime_dir}" ]]; then
        rm -R "${runtime_dir}"
    fi
}

trap cleanup_runtime EXIT

if ! HOMEBREW_NO_AUTO_UPDATE=1 "${brew_bin}" info --json=v2 --installed --cask > "${metadata_file}"; then
    printf 'Homebrew nested app approval: failed to read installed cask metadata\n' >&2
    exit 1
fi

if ! "${jq_bin}" -e '.casks | type == "array"' "${metadata_file}" >/dev/null; then
    printf 'Homebrew nested app approval: invalid Homebrew cask metadata\n' >&2
    exit 1
fi

read_quarantine() {
    local path="$1"
    local attributes

    if ! attributes="$("${xattr_bin}" "${path}" 2>/dev/null)"; then
        return 1
    fi

    if ! printf '%s\n' "${attributes}" | /usr/bin/grep -Fxq 'com.apple.quarantine'; then
        return 2
    fi

    "${xattr_bin}" -p com.apple.quarantine "${path}" 2>/dev/null
}

build_approved_quarantine() {
    local current="$1"
    local flags rest width numeric new_flags

    if [[ "${current}" == *$'\n'* || ! "${current}" =~ ^([[:xdigit:]]+)(\;.*)$ ]]; then
        return 1
    fi

    flags="${BASH_REMATCH[1]}"
    rest="${BASH_REMATCH[2]}"
    width="${#flags}"

    if (( width == 0 || width > 8 )); then
        return 1
    fi

    numeric=$((16#${flags}))

    if (( numeric & 0x0040 )); then
        printf '%s' "${current}"
        return 2
    fi

    printf -v new_flags "%0${width}x" "$((numeric | 0x0040))"
    printf '%s%s' "${new_flags}" "${rest}"
}

path_identity() {
    "${stat_bin}" -f '%d:%i' "$1" 2>/dev/null
}

assess_notarized() {
    local path="$1"
    local assessment verdict source

    if ! assessment="$("${spctl_bin}" --assess --type execute --raw --ignore-cache --no-cache -- "${path}" 2>/dev/null)"; then
        return 1
    fi

    if ! verdict="$(printf '%s' "${assessment}" | "${plutil_bin}" -extract 'assessment:verdict' raw -o - -- - 2>/dev/null)"; then
        return 1
    fi

    if ! source="$(printf '%s' "${assessment}" | "${plutil_bin}" -extract 'assessment:authority.assessment:authority:source' raw -o - -- - 2>/dev/null)"; then
        return 1
    fi

    [[ "${verdict}" == "true" && "${source}" == "Notarized Developer ID" ]]
}

process_cask() {
    local cask_json="$1"
    local full_token
    local target target_real nested_file nested nested_real quarantine approved identity
    local index existing duplicate parent candidate_count=0
    local -a targets=()
    local -a candidate_paths=()
    local -a candidate_values=()
    local -a candidate_approved_values=()
    local -a candidate_identities=()
    local -a candidate_parents=()
    local -a assessed_parents=()

    if ! full_token="$(printf '%s' "${cask_json}" | "${jq_bin}" -er '
        if (.full_token | type) == "string"
            and (.full_token | length) > 0
            and (.full_token | contains("\t") | not)
            and (.full_token | contains("\n") | not)
            and .installed != null
            and .installed_time != null
            and (.artifacts | type) == "array"
        then .full_token
        else error("invalid cask metadata")
        end
    ')"; then
        printf 'Homebrew nested app approval: malformed cask metadata\n' >&2
        return 1
    fi

    if ! printf '%s' "${cask_json}" | "${jq_bin}" -e '
        [
            .artifacts[]?
            | select(type == "object" and has("app"))
            | ((.app | type) == "array"
                and (.target | type) == "string"
                and (.target | startswith("/"))
                and (.target | endswith(".app"))
                and (.target | contains("\u0000") | not))
        ]
        | all
    ' >/dev/null; then
        printf 'Homebrew nested app approval: invalid app artifact for %s\n' "${full_token}" >&2
        return 1
    fi

    while IFS= read -r -d '' target; do
        targets+=("${target}")
    done < <(printf '%s' "${cask_json}" | "${jq_bin}" -j '
        .artifacts[]?
        | select(type == "object" and has("app") and (.target | type == "string"))
        | select((.target | startswith("/")) and (.target | endswith(".app")))
        | .target + "\u0000"
    ')

    for target in "${targets[@]+"${targets[@]}"}"; do
        if [[ ! -d "${target}" || -L "${target}" ]]; then
            printf 'Homebrew nested app approval: invalid app target for %s: %s\n' "${full_token}" "${target}" >&2
            return 1
        fi

        if ! target_real="$("${realpath_bin}" "${target}" 2>/dev/null)" || [[ "${target_real}" != "${target}" ]]; then
            printf 'Homebrew nested app approval: non-canonical app target for %s: %s\n' "${full_token}" "${target}" >&2
            return 1
        fi

        nested_file="${runtime_dir}/nested-${candidate_count}-$RANDOM"
        if ! "${find_bin}" "${target}" -type d -name '*.app' ! -path "${target}" -print0 > "${nested_file}"; then
            printf 'Homebrew nested app approval: failed to inspect %s\n' "${target}" >&2
            return 1
        fi

        while IFS= read -r -d '' nested; do
            if [[ -L "${nested}" ]]; then
                continue
            fi

            if ! nested_real="$("${realpath_bin}" "${nested}" 2>/dev/null)" || [[ "${nested_real}" != "${nested}" ]]; then
                printf 'Homebrew nested app approval: non-canonical nested app: %s\n' "${nested}" >&2
                return 1
            fi

            case "${nested_real}" in
                "${target_real}"/*)
                    ;;
                *)
                    printf 'Homebrew nested app approval: nested app escaped target: %s\n' "${nested}" >&2
                    return 1
                    ;;
            esac

            duplicate=0
            for existing in "${candidate_paths[@]+"${candidate_paths[@]}"}"; do
                if [[ "${existing}" == "${nested_real}" ]]; then
                    duplicate=1
                    break
                fi
            done
            if (( duplicate )); then
                continue
            fi

            quarantine="$(read_quarantine "${nested_real}")"
            case $? in
                0)
                    ;;
                2)
                    continue
                    ;;
                *)
                    printf 'Homebrew nested app approval: failed to read xattrs: %s\n' "${nested_real}" >&2
                    return 1
                    ;;
            esac

            approved="$(build_approved_quarantine "${quarantine}")"
            case $? in
                0)
                    ;;
                2)
                    continue
                    ;;
                *)
                    printf 'Homebrew nested app approval: malformed quarantine attribute: %s\n' "${nested_real}" >&2
                    return 1
                    ;;
            esac

            if ! identity="$(path_identity "${nested_real}")"; then
                printf 'Homebrew nested app approval: failed to identify nested app: %s\n' "${nested_real}" >&2
                return 1
            fi

            candidate_paths+=("${nested_real}")
            candidate_values+=("${quarantine}")
            candidate_approved_values+=("${approved}")
            candidate_identities+=("${identity}")
            candidate_parents+=("${target_real}")
            candidate_count=$((candidate_count + 1))
        done < "${nested_file}"
    done

    for parent in "${candidate_parents[@]+"${candidate_parents[@]}"}"; do
        duplicate=0
        for existing in "${assessed_parents[@]+"${assessed_parents[@]}"}"; do
            if [[ "${existing}" == "${parent}" ]]; then
                duplicate=1
                break
            fi
        done
        if (( duplicate )); then
            continue
        fi
        if ! assess_notarized "${parent}"; then
            printf 'Homebrew nested app approval: top-level app is not accepted as Notarized Developer ID: %s\n' "${parent}" >&2
            return 1
        fi
        assessed_parents+=("${parent}")
    done

    for nested in "${candidate_paths[@]+"${candidate_paths[@]}"}"; do
        if ! assess_notarized "${nested}"; then
            printf 'Homebrew nested app approval: nested app is not accepted as Notarized Developer ID: %s\n' "${nested}" >&2
            return 1
        fi
    done

    if (( dry_run )); then
        for nested in "${candidate_paths[@]+"${candidate_paths[@]}"}"; do
            printf 'Would approve nested Homebrew app: %s\n' "${nested}"
        done
        return 0
    fi

    for ((index = 0; index < candidate_count; index++)); do
        nested="${candidate_paths[index]}"

        if [[ "$(path_identity "${nested}")" != "${candidate_identities[index]}" ]]; then
            printf 'Homebrew nested app approval: nested app changed during assessment: %s\n' "${nested}" >&2
            return 1
        fi

        quarantine="$(read_quarantine "${nested}")"
        if [[ $? -ne 0 || "${quarantine}" != "${candidate_values[index]}" ]]; then
            printf 'Homebrew nested app approval: quarantine changed during assessment: %s\n' "${nested}" >&2
            return 1
        fi

        if ! "${xattr_bin}" -w com.apple.quarantine "${candidate_approved_values[index]}" "${nested}"; then
            printf 'Homebrew nested app approval: failed to approve nested app: %s\n' "${nested}" >&2
            return 1
        fi

        quarantine="$(read_quarantine "${nested}")"
        if [[ $? -ne 0 || "${quarantine}" != "${candidate_approved_values[index]}" ]]; then
            printf 'Homebrew nested app approval: approval verification failed: %s\n' "${nested}" >&2
            return 1
        fi

        printf 'Approved nested Homebrew app: %s\n' "${nested}"
    done

    return 0
}

failures=0

while IFS= read -r -d '' cask_json; do
    if ! process_cask "${cask_json}"; then
        failures=$((failures + 1))
    fi
done < <("${jq_bin}" -j '.casks[] | tojson + "\u0000"' "${metadata_file}")

if (( failures > 0 )); then
    exit 1
fi

exit 0
