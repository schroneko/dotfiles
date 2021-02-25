# update with this command
# echo "### .zshrc updating"
# curl -OL https://raw.githubusercontent.com/schroneko/dotfiles/master/.zshrc
# echo "### .zshrc updated"

alias v='vim'
alias vi='vim'
alias p='python3'
alias l='ls'
alias la='ls -a'
alias ll='ls -l'

alias h='history'
alias g='git'
alias gi='git init'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gpom='git push origin master'
alias gs='git status'
alias sz='source ~/.zshrc'
alias vz='vi ~/.zshrc'
alias vv='vi ~/.vimrc'

# 環境変数
export LANG=en_US.UTF-8

## 色を使用出来るようにする
autoload -Uz colors
colors

## 補完機能を有効にする
autoload -Uz compinit
compinit

## タブ補完時に大文字小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

## 日本語ファイル名を表示可能にする
setopt print_eight_bit

## PROMPT
# vcs_infoロード
autoload -Uz vcs_info

# PROMPT変数内で変数参照する
setopt prompt_subst

# vcsの表示
zstyle ':vcs_info:*' enable git svn hg bzr
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr "+"
zstyle ':vcs_info:*' unstagedstr "*"
zstyle ':vcs_info:*' formats '(%b%c%u)'
zstyle ':vcs_info:*' actionformats '(%b(%a)%c%u)'

#add-zsh-hook precmd _update_vcs_info_msg
PROMPT="%{${fg[green]}%}%n%{${reset_color}%}@%F{blue}localhost%f:%1(v|%F{red}%1v%f|) $ "
RPROMPT='[%F{green}%d%f]'

# phits
export PHITSPATH=/Users/yutahayashi/phits
export PATH=$PHITSPATH/bin:$PHITSPATH/dchain-sp/bin:$PATH

# Setting Path for Flutter
export PATH="$PATH:$HOME/Downloads/flutter/bin"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Setting Path for Volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

autoload bashcompinit && bashcompinit
complete -C '/usr/local/bin/aws_completer' aws
complete
