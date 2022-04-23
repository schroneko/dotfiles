# My Dotfiles Repo

## How to install
```
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/schroneko/dotfiles/main/install.sh)"
```

## Structure
```
❯ tree dotfiles -a -I '.git'    

dotfiles
├── .Brewfile
├── .config
│   └── starship.toml
├── .hushlogin
├── .screenrc
├── .vimrc
├── .zshrc
├── README.md
├── install.sh
└── macos.sh
```

## How to export .Brewfile
```
brew bundle dump --global --force
mas list | awk -F '[ ][ ]+' '{print "mas \"" $2 "\", id: " $1}' >> $HOME/.Brewfile
```
