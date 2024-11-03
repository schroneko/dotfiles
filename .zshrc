autoload -U +X compinit && compinit

eval $(/opt/homebrew/bin/brew shellenv)
eval "$(direnv hook zsh)"

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

alias update='brew update && brew upgrade && brew cleanup'
alias note='vim $HOME/Downloads/text.md'
alias icloud='cd "$HOME/Library/Mobile Documents/com~apple~CloudDocs/"'
alias ls='eza --group-directories-first'

notify() {
  osascript -e 'display notification "Finished!" with title "Task Complete" sound name "Tink"'
}

export PATH=$PATH:/opt/homebrew/opt/john-jumbo/share/john

crack() {
    if ! command -v zip2john > /dev/null; then
        echo "Please install john-jumbo first:"
        echo "brew install john-jumbo"
        return 1
    fi
    
    if [ $# -ne 1 ]; then
        echo "Usage: crack <zipfile>"
        return 1
    fi
    
    local zipfile=$1
    local tmp=$(mktemp)
    
    zip2john "$zipfile" > "$tmp" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        john --incremental=ASCII "$tmp" 2>/dev/null >/dev/null
        local password=$(john --show "$tmp" 2>/dev/null | awk -F: 'NR==1 {print $2}')
        echo "Password: $password"
        rm -f "$tmp"
    else
        echo "Error: Failed to process zip file"
        rm -f "$tmp"
        return 1
    fi
}

jina() {
    local JINA_API_KEY="jina_c4dc96767d0b4a8f94e0cd27d298ab04eB847jDhBDi96R4pGN48JTAaDfxM"
    local statement="$*"
    local response=$(curl -s -X POST https://g.jina.ai \
         -H "Content-Type: application/json" \
         -H "Authorization: Bearer $JINA_API_KEY" \
         -d "{\"statement\":\"$statement\"}")
    
    if [ -z "$response" ]; then
        echo "Error: Empty response from API"
        return 1
    fi
    
    local error_name=$(echo "$response" | jq -r '.name // empty')
    local error_message=$(echo "$response" | jq -r '.message // empty')
    
    if [ "$error_name" = "InsufficientBalanceError" ]; then
        echo "Error: Insufficient balance. $error_message"
        echo "To generate a new API key, please visit: https://jina.ai/reader/#apiform"
        echo "After generating a new key, update the JINA_API_KEY variable in your .zshrc file."
        return 1
    fi
    
    local text=$(echo "$response" | jq -r '.text // empty')
    if [ -z "$text" ] || [ "$text" = "null" ]; then
        echo "API Response:"
        echo "$response" | jq '.'
        echo "Error: Unexpected response from API. Check the full response above."
        return 1
    fi
    
    echo "$text"
}

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
    usage() {
        echo "Usage: extract <directory> [--ext <extension>]"
        echo "  <directory>: The directory to search for files"
        echo "  --ext <extension>: (Optional) The file extension to filter by (without dot)"
        echo "  If --ext is not provided, all files will be processed"
        exit 1
    }
    
    if [[ $# -lt 1 ]]; then
        usage
    fi
    
    directory="$1"
    extension=""
    
    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --ext)
                shift
                extension="$1"
                ;;
            *)
                usage
                ;;
        esac
        shift
    done
    
    process_files() {
        local find_cmd="find \"$directory\" -type f -not -path '*/\.*' -not -name 'output.txt'"
        if [[ -n "$extension" ]]; then
            find_cmd="$find_cmd -name \"*.$extension\""
        fi
        
        eval $find_cmd | while read -r file; do
            echo "<${file#$directory/}>"
            cat "$file"
            echo "</${file#$directory/}>"
            echo
        done
    }
    
    process_files > output.txt
    
    echo "Extraction complete. Results saved in output.txt"
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
