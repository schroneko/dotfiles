# My Dotfiles Repo

## How to install

```
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/schroneko/dotfiles/main/install.sh)"
```

## Structure

```
❯ tree . -a -I '.git'

dotfiles
├── .Brewfile
├── .alacritty.toml
├── .config
│   └── starship.toml
├── .gitignore
├── .hushlogin
├── .vimrc
├── .zshrc
├── README.md
├── install.sh
└── macos.sh
```

## Export the `.Brewfile` from your system

```
brew bundle dump --file=$HOME/dotfiles/.Brewfile --force
```

## Sync the `.Brewfile` with your system

```
brew bundle --file=$HOME/dotfiles/.Brewfile
brew bundle cleanup --file=$HOME/dotfiles/.Brewfile
```
