# My Dotfiles Repo

This repo includes dotfiles for

- `zsh`
- `vim`

# How to install

```zsh
# Clone this repository
git clone https://github.com/schroneko/dotfiles

# Move to the repository
mv dotfiles $HOME/dotfiles

# Initialize some additional packages
ln -snfv ~/dotfiles/.vimrc ~/

ln -snfv ~/dotfiles/.zshrc ~/

cd $HOME/dotfiles && brew bundle

source ~/.zshrc
```
