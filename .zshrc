# Aliases
alias update='brew update && brew upgrade && brew upgrade --greedy && brew cleanup'
alias note='vim $HOME/Downloads/text.md'
alias icloud='$HOME/Library/Mobile\ Documents/com~apple~CloudDocs/'
alias man='man_vim() { man "$@" | col -b | vim -; }; man_vim'
alias venv='python3 -m venv .venv && source .venv/bin/activate && pip install --upgrade pip'
alias topdf='soffice --headless --convert-to pdf'
alias lsd='ls -d */'
alias empty='find ~/.Trash -mindepth 1 -exec rm -rf {} +'
alias today='export TODAY=$(date "+%Y-%m-%d") && pbcopy <<< $TODAY'
alias bell='afplay /System/Library/Sounds/Hero.aiff'
alias restart='sudo shutdown -r now'
alias ipad='osascript -e '\''tell application "System Settings" to activate'\'' -e '\''tell application "System Events" to tell process "System Settings" to click menu item "Move to MyPad" of menu "Window" of menu bar 1'\'''
alias export='{ HISTFILE=/dev/null; } && export'

# Path
export PATH="/opt/homebrew/opt/python@3.11/libexec/bin:$PATH"

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

ocr() {
    shortcuts run ocr --input-path "$1" | pbcopy
}

search() {
  if [ -z "$1" ]; then
    echo "Usage: search 'pattern'"
    return 1
  fi
  grep -rnw '.' -e "$1"
}

nb2py() {
    if command -v jupyter &> /dev/null
    then
        jupyter nbconvert --to python "$1"
    else
        echo "Error: Jupyter is not installed."
        echo "Please install Jupyter using the following command:"
        echo "brew install jupyterlab"
        return 1
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

convert2audio() {
    local file="$1"
    local ext="${file##*.}"
    typeset -l l_ext="$ext" # extを小文字に変換してl_extに代入
    local supported_ext=("mp4" "mkv" "avi" "mov" "mpg" "mpeg" "mp3" "wav" "flac" "m4a" "aac")
    local is_supported=0

    # 拡張子がサポートされているかチェック
    for e in "${supported_ext[@]}"; do
        if [[ "$l_ext" == "$e" ]]; then
            is_supported=1
            break
        fi
    done

    # サポートされている拡張子の場合、変換を実行
    if [[ $is_supported -eq 1 ]]; then
        ffmpeg -i "$file" -ar 16000 -ac 1 -c:a pcm_s16le "${file%.*}.wav"
    else
        echo "Error: Unsupported file type ($ext). Please provide a video or audio file with one of the following extensions: ${supported_ext[*]}."
    fi
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
autoload -Uz compinit && compinit

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

# Set options
setopt auto_cd complete_in_word correct hist_ignore_all_dups hist_ignore_dups hist_reduce_blanks hist_save_no_dups list_packed share_history

# Completion styles
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' menu select=1
zstyle ':completion::complete:*' use-cache true

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# ngrok
if command -v ngrok &>/dev/null; then
  eval "$(ngrok completion)"
fi
