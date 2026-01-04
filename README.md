# dotfiles

GNU Stow で管理している個人用 dotfiles

## 管理しているファイル

### シェル & エディタ

- `.vimrc`
- `.zshrc`
- `.bashrc`
- `.hushlogin`

### Git & SSH

- `.gitconfig`
- `.ssh/config`
- `.config/gh/`

### ターミナル

- `.config/ghostty/config`

### パッケージ管理

- `.Brewfile`

## セットアップ

### 新しい Mac での初回セットアップ

```bash
git clone git@github.com:schroneko/dotfiles.git ~/dotfiles

cd ~/dotfiles
stow --no-folding .

brew bundle --global
```

### 設定ファイルの更新

```bash
vim ~/dotfiles/.zshrc

cd ~/dotfiles
git add .zshrc
git commit -m "zshrc を更新"
git push
```

### 他のマシンの変更を取り込む場合

```bash
cd ~/dotfiles
git pull
stow --no-folding .
```

## よく使うコマンド

```bash
stow --no-folding .
stow -D .
```

## 参考

- [GNU Stow](https://www.gnu.org/software/stow/)
