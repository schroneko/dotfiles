# update with this command
# curl -OL https://raw.githubusercontent.com/schroneko/dotfiles/master/.zshrc
# echo "### .zshrc updated"

alias la='ls -a'
export LANG=en_US.UTF-8

autoload -Uz colors
colors

autoload -Uz compinit
compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
setopt print_eight_bit

autoload -Uz vcs_info
setopt prompt_subst

zstyle ':vcs_info:*' enable git svn hg bzr
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr "+"
zstyle ':vcs_info:*' unstagedstr "*"
zstyle ':vcs_info:*' formats '(%b%c%u)'
zstyle ':vcs_info:*' actionformats '(%b(%a)%c%u)'

export PHITSPATH=$HOME/phits
export PATH=$PHITSPATH/bin:$PHITSPATH/dchain-sp/bin:$PATH
export PATH="$PATH:$HOME/Downloads/flutter/bin"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
autoload bashcompinit && bashcompinit
complete -C '/usr/local/bin/aws_completer' aws
export PATH="/usr/local/sbin:$PATH"
export PATH="$HOME/.deno/bin:$PATH"
export PATH="$HOME/.anyenv/bin:$PATH"
