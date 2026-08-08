#!/usr/bin/env bash
set -uo pipefail

case "$(basename "$0")" in
    mock-brew)
        "${HOMEBREW_NESTED_APPROVAL_TEST_JQ_BIN}" -n \
            --arg token "${HOMEBREW_NESTED_APPROVAL_TEST_TOKEN}" \
            --arg target "${HOMEBREW_NESTED_APPROVAL_TEST_TARGET}" \
            --arg installed "${HOMEBREW_NESTED_APPROVAL_TEST_INSTALLED}" \
            --argjson installed_time "${HOMEBREW_NESTED_APPROVAL_TEST_INSTALLED_TIME}" \
            --arg bundle_version "${HOMEBREW_NESTED_APPROVAL_TEST_BUNDLE_VERSION}" \
            --arg bundle_short_version "${HOMEBREW_NESTED_APPROVAL_TEST_BUNDLE_SHORT_VERSION}" \
            '{
                formulae: [],
                casks: [{
                    token: $token,
                    full_token: $token,
                    installed: $installed,
                    installed_time: $installed_time,
                    bundle_version: $bundle_version,
                    bundle_short_version: $bundle_short_version,
                    artifacts: [{app: [($target | split("/") | last)], target: $target}]
                }]
            }'
        exit $?
        ;;
    mock-spctl)
        candidate="${!#}"
        if [[ "${candidate}" == *'/Rejected.app' ]]; then
            printf '%s\n' '<?xml version="1.0" encoding="UTF-8"?>'
            printf '%s\n' '<plist version="1.0"><dict><key>assessment:authority</key><dict><key>assessment:authority:source</key><string>Unnotarized Developer ID</string></dict><key>assessment:verdict</key><false/></dict></plist>'
            exit 3
        fi
        printf '%s\n' '<?xml version="1.0" encoding="UTF-8"?>'
        printf '%s\n' '<plist version="1.0"><dict><key>assessment:authority</key><dict><key>assessment:authority:source</key><string>Notarized Developer ID</string></dict><key>assessment:verdict</key><true/></dict></plist>'
        exit 0
        ;;
esac

repo_root="$(/bin/realpath "$(dirname "$0")/..")"
helper="${repo_root}/scripts/homebrew-approve-nested-apps.sh"
test_script="$(/bin/realpath "$0")"
temp_dir_raw="$(mktemp -d "${TMPDIR:-/tmp}/homebrew-nested-approval-test.XXXXXX")"
temp_dir="$(/bin/realpath "${temp_dir_raw}")"
mock_brew="${temp_dir}/mock-brew"
mock_spctl="${temp_dir}/mock-spctl"
failures=0

cleanup() {
    if [[ -d "${temp_dir}" ]]; then
        rm -R "${temp_dir}"
    fi
}

trap cleanup EXIT
ln -s "${test_script}" "${mock_brew}"
ln -s "${test_script}" "${mock_spctl}"

export HOMEBREW_NESTED_APPROVAL_BREW_BIN="${mock_brew}"
export HOMEBREW_NESTED_APPROVAL_SPCTL_BIN="${mock_spctl}"
export HOMEBREW_NESTED_APPROVAL_TEST_JQ_BIN="$(command -v jq)"
export HOMEBREW_NESTED_APPROVAL_TEST_INSTALLED=1.0.0
export HOMEBREW_NESTED_APPROVAL_TEST_INSTALLED_TIME=1
export HOMEBREW_NESTED_APPROVAL_TEST_BUNDLE_VERSION=100
export HOMEBREW_NESTED_APPROVAL_TEST_BUNDLE_SHORT_VERSION=1.0.0

fail() {
    printf 'FAIL %s\n' "$1" >&2
    failures=$((failures + 1))
}

assert_equal() {
    local name="$1"
    local expected="$2"
    local actual="$3"

    if [[ "${actual}" != "${expected}" ]]; then
        fail "${name}: expected [${expected}], got [${actual}]"
    fi
}

assert_status() {
    local name="$1"
    local expected="$2"
    local actual="$3"

    if [[ "${actual}" -ne "${expected}" ]]; then
        fail "${name}: expected status ${expected}, got ${actual}"
    fi
}

assert_no_quarantine() {
    local name="$1"
    local path="$2"

    if /usr/bin/xattr -p com.apple.quarantine "${path}" >/dev/null 2>&1; then
        fail "${name}: unexpected quarantine attribute"
    fi
}

prepare_fixture() {
    local name="$1"

    fixture_dir="${temp_dir}/${name}"
    top_app="${fixture_dir}/Top Level.app"
    mkdir -p "${top_app}/Contents/Resources"
    export HOMEBREW_NESTED_APPROVAL_TEST_TOKEN="test-${name}"
    export HOMEBREW_NESTED_APPROVAL_TEST_TARGET="${top_app}"
    export HOMEBREW_NESTED_APPROVAL_TEST_INSTALLED_TIME=1
    export HOMEBREW_NESTED_APPROVAL_TEST_BUNDLE_VERSION=100
    export HOMEBREW_NESTED_APPROVAL_TEST_BUNDLE_SHORT_VERSION=1.0.0
}

run_helper() {
    "${helper}" --all "$@"
}

prepare_fixture approve
nested_app="${top_app}/Contents/Resources/Nested Tool.app"
inner_app="${nested_app}/Contents/SharedSupport/Inner Tool.app"
mkdir -p "${inner_app}"
/usr/bin/xattr -w com.apple.quarantine '0381;one;Homebrew Cask;top' "${top_app}"
/usr/bin/xattr -w com.apple.quarantine '0381;one;Homebrew Cask;nested' "${nested_app}"
/usr/bin/xattr -w com.apple.quarantine '0381;one;Homebrew Cask;inner' "${inner_app}"
run_helper
status=$?
assert_status approve 0 "${status}"
assert_equal top-level-untouched '0381;one;Homebrew Cask;top' "$(/usr/bin/xattr -p com.apple.quarantine "${top_app}")"
assert_equal nested-approved '03c1;one;Homebrew Cask;nested' "$(/usr/bin/xattr -p com.apple.quarantine "${nested_app}")"
assert_equal inner-approved '03c1;one;Homebrew Cask;inner' "$(/usr/bin/xattr -p com.apple.quarantine "${inner_app}")"

prepare_fixture missing
nested_app="${top_app}/Contents/Resources/Missing.app"
mkdir -p "${nested_app}"
run_helper
status=$?
assert_status missing 0 "${status}"
assert_no_quarantine missing "${nested_app}"

prepare_fixture already
nested_app="${top_app}/Contents/Resources/Approved.app"
mkdir -p "${nested_app}"
/usr/bin/xattr -w com.apple.quarantine '03c1;one;Homebrew Cask;approved' "${nested_app}"
run_helper
status=$?
assert_status already 0 "${status}"
assert_equal already-unchanged '03c1;one;Homebrew Cask;approved' "$(/usr/bin/xattr -p com.apple.quarantine "${nested_app}")"

prepare_fixture rejected
good_app="${top_app}/Contents/Resources/Good.app"
rejected_app="${top_app}/Contents/Resources/Rejected.app"
mkdir -p "${good_app}" "${rejected_app}"
/usr/bin/xattr -w com.apple.quarantine '0381;one;Homebrew Cask;good' "${good_app}"
/usr/bin/xattr -w com.apple.quarantine '0381;one;Homebrew Cask;rejected' "${rejected_app}"
run_helper
status=$?
if [[ "${status}" -eq 0 ]]; then
    fail 'rejected: expected nonzero status'
fi
assert_equal rejected-good-unchanged '0381;one;Homebrew Cask;good' "$(/usr/bin/xattr -p com.apple.quarantine "${good_app}")"
assert_equal rejected-unchanged '0381;one;Homebrew Cask;rejected' "$(/usr/bin/xattr -p com.apple.quarantine "${rejected_app}")"

prepare_fixture malformed
nested_app="${top_app}/Contents/Resources/Malformed.app"
mkdir -p "${nested_app}"
/usr/bin/xattr -w com.apple.quarantine 'invalid;one;Homebrew Cask;malformed' "${nested_app}"
run_helper
status=$?
if [[ "${status}" -eq 0 ]]; then
    fail 'malformed: expected nonzero status'
fi
assert_equal malformed-unchanged 'invalid;one;Homebrew Cask;malformed' "$(/usr/bin/xattr -p com.apple.quarantine "${nested_app}")"

prepare_fixture dry-run
nested_app="${top_app}/Contents/Resources/Dry Run.app"
mkdir -p "${nested_app}"
/usr/bin/xattr -w com.apple.quarantine '0381;one;Homebrew Cask;dry' "${nested_app}"
run_helper --dry-run
status=$?
assert_status dry-run 0 "${status}"
assert_equal dry-run-unchanged '0381;one;Homebrew Cask;dry' "$(/usr/bin/xattr -p com.apple.quarantine "${nested_app}")"

prepare_fixture repeated
nested_app="${top_app}/Contents/Resources/Repeated.app"
mkdir -p "${nested_app}"
/usr/bin/xattr -w com.apple.quarantine '0381;one;Homebrew Cask;repeated' "${nested_app}"
run_helper
status=$?
assert_status repeated-first 0 "${status}"
/usr/bin/xattr -w com.apple.quarantine '0381;one;Homebrew Cask;repeated' "${nested_app}"
run_helper
status=$?
assert_status repeated-second 0 "${status}"
assert_equal repeated-approved '03c1;one;Homebrew Cask;repeated' "$(/usr/bin/xattr -p com.apple.quarantine "${nested_app}")"

if (( failures > 0 )); then
    exit 1
fi

printf 'PASS homebrew nested app approval tests\n'
