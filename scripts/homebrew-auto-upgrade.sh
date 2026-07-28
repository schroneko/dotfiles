#!/usr/bin/env bash
set -uo pipefail

failures=0
waited=0
wait_interval=5
max_wait=1800
trusted_taps=(
    "schroneko/cdpclick"
    "schroneko/claude-code-updater"
    "schroneko/exbright"
    "schroneko/hithint"
    "schroneko/nicevoice-app"
)

fail() {
    printf "%s\n" "$*" >&2
    failures=$((failures + 1))
}

run_step() {
    local name="$1"
    shift

    local output status
    output="$("$@" 2>&1)"
    status=$?

    if [[ "${status}" -ne 0 ]]; then
        fail "FAIL ${name} status=${status}"
        printf "%s\n" "${output}" >&2
    fi

    return "${status}"
}

extract_unlinked_formulae() {
    awk '
        /^Warning: You have unlinked kegs in your Cellar\./ {
            in_warning = 1
            next
        }
        in_warning && /^  [-A-Za-z0-9_+@.\/]+$/ {
            sub(/^  /, "")
            print
            found = 1
            next
        }
        in_warning && found && NF == 0 {
            exit
        }
    '
}

repair_unlinked_formulae() {
    local formulae="$1"
    local repair_failures=0

    if [[ -z "${formulae}" ]]; then
        return 1
    fi

    while IFS= read -r formula; do
        [[ -z "${formula}" ]] && continue
        run_step "brew link ${formula}" brew link "${formula}" || repair_failures=1
    done <<< "${formulae}"

    return "${repair_failures}"
}

trust_managed_taps() {
    local tap
    local trust_failures=0

    for tap in "${trusted_taps[@]}"; do
        if brew tap | grep -Fxq "${tap}"; then
            run_step "brew trust tap ${tap}" brew trust --tap "${tap}" || trust_failures=1
        fi
    done

    return "${trust_failures}"
}

run_brew_doctor() {
    local doctor_output
    local formulae
    local status

    doctor_output="$(brew doctor 2>&1)"
    status=$?

    if [[ "${status}" -eq 0 ]]; then
        return 0
    fi

    printf "%s\n" "${doctor_output}" >&2
    trust_managed_taps || true
    formulae="$(printf "%s\n" "${doctor_output}" | extract_unlinked_formulae)"

    if repair_unlinked_formulae "${formulae}"; then
        doctor_output="$(brew doctor 2>&1)"
        status=$?

        if [[ "${status}" -eq 0 ]]; then
            return 0
        fi

        printf "%s\n" "${doctor_output}" >&2
        fail "FAIL brew doctor status=${status}"
        return "${status}"
    fi

    fail "FAIL repair after brew doctor failure"
    return 1
}

while pgrep -qf "brew (bundle|fetch|install|upgrade)"; do
    if [[ "${waited}" -ge "${max_wait}" ]]; then
        fail "FAIL waiting for another brew process timed out after ${max_wait}s"
        exit 75
    fi

    sleep "${wait_interval}"
    waited=$((waited + wait_interval))
done

if run_step "brew update" brew update; then
    trust_managed_taps || true
    run_step "brew upgrade formulae" brew upgrade --formula --yes

    if outdated_casks="$(brew outdated --cask --greedy 2>&1)"; then
        pinned_casks="$(brew list --cask --pinned 2>/dev/null || true)"
        if [[ -n "${outdated_casks}" ]]; then
            while IFS= read -r cask; do
                [[ -z "${cask}" ]] && continue
                if [[ -n "${pinned_casks}" ]] && grep -Fxq "${cask}" <<< "${pinned_casks}"; then
                    continue
                fi
                run_step "brew upgrade cask ${cask}" brew upgrade --cask --greedy --yes "${cask}"
            done <<< "${outdated_casks}"
        fi
    else
        status=$?
        fail "FAIL brew outdated casks status=${status}"
        printf "%s\n" "${outdated_casks}" >&2
    fi

    run_step "brew autoremove" brew autoremove
    run_step "brew cleanup" brew cleanup
    run_brew_doctor
else
    run_step "brew cleanup after failed update" brew cleanup
fi

if [[ "${failures}" -ne 0 ]]; then
    exit 1
fi

exit 0
