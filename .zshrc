autoload -U +X compinit && compinit

eval $(/opt/homebrew/bin/brew shellenv)

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

alias update='brew update && brew upgrade && brew cleanup'
alias note='vim $HOME/Downloads/text.md'
alias icloud='cd "$HOME/Library/Mobile Documents/com~apple~CloudDocs/"'
alias ls='eza --group-directories-first'

lofi() {
    for cmd in mpv yt-dlp; do
        if ! command -v $cmd &> /dev/null; then
            echo "$cmd is not installed. Please install it: brew install $cmd"
            return
        fi
    done

    if pgrep -x "mpv" > /dev/null; then
        pkill -9 mpv && echo "Lofi music stopped."
    else
        nohup mpv $(yt-dlp -g -f "bestaudio" "https://www.youtube.com/watch?v=4oStw0r33so" 2>/dev/null) < /dev/null &> /dev/null & disown
        echo "Lofi music playing."
    fi
}

extract() {
    if [ $# -ne 1 ]; then
        echo "Usage: extract <directory_path>"
        return 1
    fi

    dir_path="$1"
    output_file="output.txt"

    find "$dir_path" -type f ! -path "$dir_path/.*/*" -print0 | while IFS= read -r -d '' file; do
        file_path="${file#$dir_path/}"
        if file "$file" | grep -qE 'text|charset'; then
            echo "\`\`\`$file_path" >> $output_file
            sed 's/\r//' "$file" >> $output_file
            echo "\`\`\`" >> $output_file
            echo >> $output_file
        else
            echo "Binary file: $file_path" >> $output_file
            echo >> $output_file
        fi
    done

    echo "Output saved to $output_file"
    cat $output_file
}

if command -v gtac >/dev/null 2>&1; then
    tac="gtac"
elif command -v tac >/dev/null 2>&1; then
    tac="tac"
else
    tac="tail -r"
fi

function peco-select-history() {
    BUFFER=$(fc -l -n 1 | eval $tac | awk '!a[$0]++' | peco --query "$LBUFFER")
    CURSOR=${#BUFFER}
}

zle -N peco-select-history
bindkey '^R' peco-select-history

function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

export KEYTIMEOUT=1

bindkey jj vi-cmd-mode

export HISTSIZE=10000
export LANG=en_US.UTF-8
export LSCOLORS=exfxcxdxbxegedabagacad
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
export MANPAGER="col -b -x|vim -R -c 'set ft=man nolist nomod noma' -"

setopt auto_cd complete_in_word correct hist_ignore_dups hist_reduce_blanks hist_save_no_dups list_packed share_history

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

if [ -f "$HOME/miniforge3/bin/conda" ]; then
    eval "$('$HOME/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
elif [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
    . "$HOME/miniforge3/etc/profile.d/conda.sh"
else
    export PATH="$HOME/miniforge3/bin:$PATH"
fi

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
