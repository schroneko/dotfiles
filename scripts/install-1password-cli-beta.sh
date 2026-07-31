#!/bin/bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
    exit 0
fi

version="2.38.1-beta.01"
local_bin="$HOME/.local/bin/op"
marker="$HOME/.config/op/managed-cli-beta-version"
homebrew_op=""

if [[ -x /opt/homebrew/bin/op ]]; then
    homebrew_op="/opt/homebrew/bin/op"
elif [[ -x /usr/local/bin/op ]]; then
    homebrew_op="/usr/local/bin/op"
fi

if [[ -n "$homebrew_op" ]] && "$homebrew_op" environment --help >/dev/null 2>&1; then
    if [[ -f "$marker" ]]; then
        if [[ -x "$local_bin" ]]; then
            rm "$local_bin"
        fi
        rm "$marker"
    fi
    exit 0
fi

if [[ -x "$local_bin" ]] && "$local_bin" environment --help >/dev/null 2>&1; then
    if [[ "$("$local_bin" --version)" == "$version" ]]; then
        mkdir -p "$(dirname "$marker")"
        printf '%s\n' "$version" > "$marker"
    fi
    exit 0
fi

if [[ -e "$local_bin" && ! -f "$marker" ]]; then
    printf 'Refusing to replace unmanaged executable: %s\n' "$local_bin" >&2
    exit 1
fi

case "$(uname -m)" in
    arm64)
        arch="arm64"
        expected_sha256="ca6bb537833c57269a7f87426e350434c35f3f0f0d725c5bb21c895ce2f3b3d7"
        ;;
    x86_64)
        arch="amd64"
        expected_sha256="3ebcb1d5d3d1ab17af42f8ebb97dd14cce4f593983f215f3e09cc9458ebf2eed"
        ;;
    *)
        printf 'Unsupported architecture: %s\n' "$(uname -m)" >&2
        exit 1
        ;;
esac

temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/op-beta.XXXXXX")"
archive="$temp_dir/op.zip"
extracted_dir="$temp_dir/extracted"
download_url="https://cache.agilebits.com/dist/1P/op2/pkg/v${version}/op_darwin_${arch}_v${version}.zip"

curl --fail --location --output "$archive" "$download_url"
actual_sha256="$(shasum -a 256 "$archive" | cut -d ' ' -f 1)"

if [[ "$actual_sha256" != "$expected_sha256" ]]; then
    printf 'Checksum mismatch for 1Password CLI beta\n' >&2
    exit 1
fi

ditto -x -k "$archive" "$extracted_dir"
codesign --verify --deep --strict "$extracted_dir/op"
mkdir -p "$(dirname "$local_bin")"
install -m 0755 "$extracted_dir/op" "$local_bin"
mkdir -p "$(dirname "$marker")"
printf '%s\n' "$version" > "$marker"
"$local_bin" environment --help >/dev/null
"$local_bin" run --help >/dev/null
rm "$archive"
rm "$extracted_dir/op"
rm "$extracted_dir/op.sig"
rmdir "$extracted_dir"
rmdir "$temp_dir"
