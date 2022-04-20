export LANG=en_US.UTF-8
autoload -Uz colors
colors
autoload -Uz compinit
compinit
autoload -Uz vcs_info
setopt auto_cd
setopt print_eight_bit
setopt prompt_subst

zstyle ":completion:*:commands" rehash 1
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':vcs_info:*' actionformats '(%b(%a)%c%u)'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' enable git svn hg bzr
zstyle ':vcs_info:*' formats '(%b%c%u)'
zstyle ':vcs_info:*' stagedstr "+"
zstyle ':vcs_info:*' unstagedstr "*"

PROMPT="%{${fg[green]}%}%n%{${reset_color}%}@%F{blue}localhost%f:%1(v|%F{red}%1v%f|) $ "
RPROMPT='[%F{green}%d%f]'

eval "$(/opt/homebrew/bin/brew shellenv)"

if [[ $(command -v exa) ]]; then
  alias e='exa --icons --git'
  alias l=e
  alias ls=e
  alias ea='exa -a --icons --git'
  alias la=ea
  alias l='clear && ls'
fi

eval "$(starship init zsh)"

export PATH=~/.deno/bin:$PATH
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

alias bu='brew update && brew upgrade && brew upgrade --cask && brew cleanup'
alias dia='vim ~/diary/$(date "+%Y/%m/%d.md")'
alias diaopen='open -a "/Applications/Google Chrome.app/" ~/diary/$(date "+%Y/%m/%d.md")'
alias ds='find $HOME –name ‘.DS_Store’ –type f –delete'
alias gall='git add . && git commit -m "update" && git push origin main'

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit
  compinit
fi
