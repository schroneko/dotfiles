#!/bin/bash

GLOBAL_GITIGNORE="$HOME/.config/git/ignore"

GITIGNORE_URLS=(
    "https://raw.githubusercontent.com/github/gitignore/main/Global/macOS.gitignore"
    "https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore"
    "https://raw.githubusercontent.com/github/gitignore/main/Node.gitignore"
)

create_global_gitignore() {
    mkdir -p "$(dirname "$GLOBAL_GITIGNORE")"

    if [ -f "$GLOBAL_GITIGNORE" ]; then
        read -p "File $GLOBAL_GITIGNORE already exists. Overwrite? (y/N): " response
        if [[ ! $response =~ ^[Yy]$ ]]; then
            echo "Operation cancelled."
            exit 1
        fi
    fi

    > "$GLOBAL_GITIGNORE"

    for url in "${GITIGNORE_URLS[@]}"; do
        curl -sS "$url" >> "$GLOBAL_GITIGNORE"
        echo "" >> "$GLOBAL_GITIGNORE"
    done
}

create_global_gitignore

echo "Global .gitignore has been created at $GLOBAL_GITIGNORE"
