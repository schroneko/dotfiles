# Aliases
alias update='brew update && brew upgrade && brew upgrade --greedy && brew cleanup'
alias note='vim $HOME/Downloads/text.md'
alias man='man_vim() { man "$@" | col -b | vim -; }; man_vim'
alias venv='python -m venv .venv && source .venv/bin/activate && pip install --upgrade pip'
alias empty='find ~/.Trash -mindepth 1 -exec rm -rf {} +'
alias bell='afplay /System/Library/Sounds/Hero.aiff'
alias icloud='cd "$HOME/Library/Mobile Documents/com~apple~CloudDocs/"'
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

lofi() {
    # Check if mpv is installed, if not prompt to install it
    if ! command -v mpv &> /dev/null; then
        echo "mpv is not installed. Please install it by running: brew install mpv"
        return
    fi

    # Check if yt-dlp is installed, if not prompt to install it
    if ! command -v yt-dlp &> /dev/null; then
        echo "yt-dlp is not installed. Please install it by running: brew install yt-dlp"
        return
    fi

    # Check if mpv is already running
    if pgrep -x "mpv" > /dev/null; then
        # If mpv is running, send the stop signal
        pkill -9 mpv
        echo "Lofi music stopped."
    else
        # If mpv is not running, start playing the lofi music in the background
        nohup mpv $(yt-dlp -g -f "bestaudio" "https://www.youtube.com/watch?v=4oStw0r33so" 2> /dev/null) < /dev/null &> /dev/null & disown
        echo "Lofi music playing."
    fi
}

search() {
  local search_term="$1"
  shift
  local ignore_patterns=()

  # Parse ignore patterns
  while [[ "$1" == "--ignore" ]]; do
    shift
    while [[ $# -gt 0 && "$1" != "--ignore" ]]; do
      ignore_patterns+=("$1")
      shift
    done
  done

  # Construct find command
  local find_cmd="find . -type f"
  for pattern in "${ignore_patterns[@]}"; do
    find_cmd+=" -not -path \"*$pattern*\""
  done

  # Execute the search
  eval "$find_cmd -print0" | while IFS= read -r -d '' file; do
    if grep -q "$search_term" "$file"; then
      echo "$file"
      grep --color=always -Hn "$search_term" "$file"
    fi
  done
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

# peco
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

# Initialization
autoload -Uz compinit
compinit

# zle-keymap-select ウィジェットの定義
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

# vi mode の遷移を速くする
export KEYTIMEOUT=1

# Key bindings
bindkey jj vi-cmd-mode

# Environment variables
export HISTSIZE=10000
export LANG=en_US.UTF-8
export LSCOLORS=exfxcxdxbxegedabagacad
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# Eval statements
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(starship init zsh)"
eval "$(uv generate-shell-completion zsh)"
eval "$(direnv hook zsh)"

# Set options
setopt auto_cd complete_in_word correct hist_ignore_all_dups hist_ignore_dups hist_reduce_blanks hist_save_no_dups list_packed share_history

# Completion styles
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# ngrok
if command -v ngrok &>/dev/null; then
  eval "$(ngrok completion)"
fi
autoload -U compinit; compinit

# Miniforge3 initialization
__conda_setup="$('$HOME/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
