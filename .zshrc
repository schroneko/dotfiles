alias ls='ls -G'
alias la='ls -aG'
export LANG=en_US.UTF-8
autoload -Uz colors
colors
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
setopt print_eight_bit
autoload -Uz vcs_info
setopt prompt_subst
setopt auto_cd

zstyle ':vcs_info:*' enable git svn hg bzr
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr "+"
zstyle ':vcs_info:*' unstagedstr "*"
zstyle ':vcs_info:*' formats '(%b%c%u)'
zstyle ':vcs_info:*' actionformats '(%b(%a)%c%u)'

PROMPT="%{${fg[green]}%}%n%{${reset_color}%}@%F{blue}localhost%f:%1(v|%F{red}%1v%f|) $ "
RPROMPT='[%F{green}%d%f]'
cd $HOME/Downloads

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

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/yutahayashi/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/yutahayashi/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/yutahayashi/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/yutahayashi/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

function gi() { curl -sLw n https://www.toptal.com/developers/gitignore/api/$@ ;}
