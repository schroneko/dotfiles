#!/usr/bin/env bash
set -uo pipefail

failures=0
waited=0
wait_interval=5
max_wait=1800

timestamp() {
    date "+%Y-%m-%dT%H:%M:%S%z"
}

log() {
    printf "[%s] %s\n" "$(timestamp)" "$*"
}

run_step() {
    local name="$1"
    shift

    log "START ${name}"
    "$@"
    local status=$?

    if [[ "${status}" -eq 0 ]]; then
        log "OK ${name}"
    else
        log "FAIL ${name} status=${status}"
        failures=$((failures + 1))
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
        log "No unlinked formulae to repair"
        return 1
    fi

    while IFS= read -r formula; do
        [[ -z "${formula}" ]] && continue
        run_step "brew link ${formula}" brew link "${formula}" || repair_failures=1
    done <<< "${formulae}"

    return "${repair_failures}"
}

run_brew_doctor() {
    local doctor_output
    local formulae
    local status

    log "START brew doctor"
    doctor_output="$(brew doctor 2>&1)"
    status=$?
    printf "%s\n" "${doctor_output}"

    if [[ "${status}" -eq 0 ]]; then
        log "OK brew doctor"
        return 0
    fi

    log "FAIL brew doctor status=${status}"
    log "Attempting repair after brew doctor failure"
    formulae="$(printf "%s\n" "${doctor_output}" | extract_unlinked_formulae)"

    if repair_unlinked_formulae "${formulae}"; then
        log "START brew doctor after repair"
        doctor_output="$(brew doctor 2>&1)"
        status=$?
        printf "%s\n" "${doctor_output}"

        if [[ "${status}" -eq 0 ]]; then
            log "OK brew doctor after repair"
            return 0
        fi

        log "FAIL brew doctor after repair status=${status}"
        failures=$((failures + 1))
        return "${status}"
    fi

    log "FAIL repair after brew doctor failure"
    failures=$((failures + 1))
    return 1
}

log "homebrew-auto-upgrade started"

while pgrep -qf "brew (bundle|fetch|install|upgrade)"; do
    if [[ "${waited}" -ge "${max_wait}" ]]; then
        log "FAIL waiting for another brew process timed out after ${max_wait}s"
        exit 75
    fi

    log "Waiting for another brew process to finish..."
    sleep "${wait_interval}"
    waited=$((waited + wait_interval))
done

if run_step "brew update" brew update; then
    run_step "brew upgrade formulae" brew upgrade --formula

    if outdated_casks="$(brew outdated --cask --greedy 2>&1)"; then
        if [[ -n "${outdated_casks}" ]]; then
            while IFS= read -r cask; do
                [[ -z "${cask}" ]] && continue
                run_step "brew upgrade cask ${cask}" brew upgrade --cask --greedy "${cask}"
            done <<< "${outdated_casks}"
        else
            log "No outdated casks"
        fi
    else
        status=$?
        log "FAIL brew outdated casks status=${status}"
        printf "%s\n" "${outdated_casks}"
        failures=$((failures + 1))
    fi

    run_step "brew autoremove" brew autoremove
    run_step "brew cleanup" brew cleanup
    run_brew_doctor
else
    run_step "brew cleanup after failed update" brew cleanup
fi

if [[ "${failures}" -eq 0 ]]; then
    log "homebrew-auto-upgrade finished successfully"
    exit 0
fi

log "homebrew-auto-upgrade finished with ${failures} failure(s)"
exit 1
