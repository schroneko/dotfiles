# .dotfiles

cd

git clone https://github.com/schroneko/.dotfiles.git

ln -snfv ~/.dotfiles/.vimrc ~/

ln -snfv ~/.dotfiles/.zshrc ~/

cd .dotfiles

brew bundle

echo "### .vimrc .zshrc installed"
