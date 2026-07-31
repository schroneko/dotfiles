#!/bin/bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
    exit 0
fi

version="2.38.1-beta.01"
local_bin="$HOME/.local/bin/op"
marker="$HOME/.config/op/managed-cli-beta-version"
homebrew_op=""

case "$(uname -m)" in
    arm64)
        arch="arm64"
        expected_archive_sha256="ca6bb537833c57269a7f87426e350434c35f3f0f0d725c5bb21c895ce2f3b3d7"
        expected_binary_sha256="3ab8c0d2d6039ad2d5cf5a33b7d537a9833644732cb18fe6b165497bf97f96af"
        ;;
    x86_64)
        arch="amd64"
        expected_archive_sha256="3ebcb1d5d3d1ab17af42f8ebb97dd14cce4f593983f215f3e09cc9458ebf2eed"
        expected_binary_sha256="f5771a9b1576949aedfa7ab6671d3415bc42987e72e09cdd9067a529afcac5cb"
        ;;
    *)
        printf 'Unsupported architecture: %s\n' "$(uname -m)" >&2
        exit 1
        ;;
esac

supports_environments() {
    local executable="$1"
    local run_help

    if ! "$executable" environment --help >/dev/null 2>&1; then
        return 1
    fi

    run_help="$("$executable" run --help 2>&1)"
    [[ "$run_help" == *"--environment"* ]]
}

has_expected_binary() {
    local executable="$1"
    local actual_sha256

    actual_sha256="$(shasum -a 256 "$executable" | cut -d ' ' -f 1)"
    [[ "$actual_sha256" == "$expected_binary_sha256" ]]
}

if [[ -x /opt/homebrew/bin/op ]]; then
    homebrew_op="/opt/homebrew/bin/op"
elif [[ -x /usr/local/bin/op ]]; then
    homebrew_op="/usr/local/bin/op"
fi

if [[ -e "$local_bin" && ! -f "$marker" ]]; then
    printf 'Refusing to replace unmanaged executable: %s\n' "$local_bin" >&2
    exit 1
fi

if [[ -x "$local_bin" ]] && has_expected_binary "$local_bin" && supports_environments "$local_bin"; then
    mkdir -p "$(dirname "$marker")"
    printf '%s\n' "$version" > "$marker"
    exit 0
fi

if [[ -n "$homebrew_op" ]] && has_expected_binary "$homebrew_op" && supports_environments "$homebrew_op"; then
    if [[ -f "$marker" ]]; then
        if [[ -x "$local_bin" ]]; then
            rm "$local_bin"
        fi
        rm "$marker"
    fi
    exit 0
fi

temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/op-beta.XXXXXX")"
archive="$temp_dir/op.zip"
extracted_dir="$temp_dir/extracted"
download_url="https://cache.agilebits.com/dist/1P/op2/pkg/v${version}/op_darwin_${arch}_v${version}.zip"

curl --fail --location --output "$archive" "$download_url"
actual_sha256="$(shasum -a 256 "$archive" | cut -d ' ' -f 1)"

if [[ "$actual_sha256" != "$expected_archive_sha256" ]]; then
    printf 'Checksum mismatch for 1Password CLI beta\n' >&2
    exit 1
fi

ditto -x -k "$archive" "$extracted_dir"
codesign --verify --deep --strict "$extracted_dir/op"
signature_details="$(codesign -dv --verbose=4 "$extracted_dir/op" 2>&1)"
[[ "$signature_details" == *"Authority=Developer ID Application: AgileBits Inc. (2BUA8C4S2C)"* ]]
mkdir -p "$(dirname "$local_bin")"
install -m 0755 "$extracted_dir/op" "$local_bin"
mkdir -p "$(dirname "$marker")"
printf '%s\n' "$version" > "$marker"
"$local_bin" environment --help >/dev/null
supports_environments "$local_bin"
rm "$archive"
rm "$extracted_dir/op"
rm "$extracted_dir/op.sig"
rmdir "$extracted_dir"
rmdir "$temp_dir"
