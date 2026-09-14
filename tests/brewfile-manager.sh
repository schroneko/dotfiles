#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
test_dir="$(mktemp -d)"
trap 'rm -r "${test_dir}"' EXIT

fixture="${test_dir}/repo"
bin_dir="${test_dir}/bin"
state_path="${test_dir}/brew-installed.tsv"
manager="${repo_root}/scripts/brewfile-manager.sh"

mkdir -p "${fixture}" "${bin_dir}"

cat > "${bin_dir}/brew" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "bundle" && "${2:-}" == "dump" ]]; then
    target=""
    for arg in "$@"; do
        if [[ "${arg}" == --file=* ]]; then
            target="${arg#--file=}"
        fi
    done
    cp "${BREWFILE_MANAGER_TEST_BREWFILE}" "${target}"
    exit 0
fi

if [[ "${1:-}" == "info" ]]; then
    printf '%s\n' '{"casks":[{"full_token":"explicit-app","url":"https://example.com/darwin/explicit-app"}]}'
    exit 0
fi

exit 0
EOF
chmod +x "${bin_dir}/brew"

export PATH="${bin_dir}:${PATH}"
export BREWFILE_MANAGER_ROOT="${fixture}"
export BREWFILE_MANAGER_STATE_PATH="${state_path}"

write_sources() {
    cat > "${fixture}/.Brewfile.shared" <<'EOF'
# Managed by scripts/brewfile-manager.sh.
brew "alpha"
EOF
    cat > "${fixture}/.Brewfile.darwin" <<'EOF'
# Managed by scripts/brewfile-manager.sh.
cask "removed-app"
cask "new-app"
EOF
    cat > "${fixture}/.Brewfile.linux" <<'EOF'
# Managed by scripts/brewfile-manager.sh.
EOF
    cat > "${fixture}/.Brewfile.ignore" <<'EOF'
zoom
EOF
}

write_current() {
    local entries="$1"
    printf '%s\n' "${entries}" > "${test_dir}/current.Brewfile"
    export BREWFILE_MANAGER_TEST_BREWFILE="${test_dir}/current.Brewfile"
}

write_sources
printf '%s\n' $'brew\talpha' $'cask\tremoved-app' > "${state_path}"
write_current 'brew "alpha"'
"${manager}" reconcile
if grep -Eq 'removed-app' "${fixture}/.Brewfile.shared" "${fixture}/.Brewfile.darwin" "${fixture}/.Brewfile.linux"; then
    exit 1
fi
grep -Fxq 'removed-app' "${fixture}/.Brewfile.ignore"
grep -Fxq 'cask "new-app"' "${fixture}/.Brewfile.darwin"

write_current $'brew "alpha"\ncask "new-app"'
"${manager}" snapshot
grep -Fxq $'brew\talpha' "${state_path}"
grep -Fxq $'cask\tnew-app' "${state_path}"

write_sources
"${manager}" track -- uninstall --cask removed-app
if grep -Eq 'removed-app' "${fixture}/.Brewfile.shared" "${fixture}/.Brewfile.darwin" "${fixture}/.Brewfile.linux"; then
    exit 1
fi
grep -Fxq 'removed-app' "${fixture}/.Brewfile.ignore"

write_sources
write_current 'cask "explicit-app"'
"${manager}" track -- install --cask explicit-app
if grep -Fxq 'explicit-app' "${fixture}/.Brewfile.ignore"; then
    exit 1
fi
grep -R -Fxq 'cask "explicit-app"' "${fixture}/.Brewfile.shared" "${fixture}/.Brewfile.darwin" "${fixture}/.Brewfile.linux"

printf '%s\n' 'PASS brewfile manager tests'
