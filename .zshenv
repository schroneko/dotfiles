typeset -U path
path=(
    "$HOME/.local/bin"
    "$HOME/.mint/bin"
    "$HOME/.lmstudio/bin"
    "$HOME/.antigravity/antigravity/bin"
    ${path:#$HOME/.volta/bin}
)
export PATH
export CLAUDE_ENV_FILE="$HOME/.claude/env-loader.sh"
if [[ -r "$HOME/.config/op/environment-id" ]]; then
    export OP_ENVIRONMENT_ID="$(<"$HOME/.config/op/environment-id")"
fi
if [[ -r "$HOME/.config/op/service-account-token" ]]; then
    export OP_SERVICE_ACCOUNT_TOKEN="$(<"$HOME/.config/op/service-account-token")"
fi
export EDITOR=nvim
export LANG=en_US.UTF-8

if [ -e "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

if [ -x /opt/homebrew/bin/mise ]; then
    eval "$(/opt/homebrew/bin/mise activate zsh)"
elif command -v mise > /dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi
