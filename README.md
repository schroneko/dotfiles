# dotfiles

GNU Stow で管理している個人用 dotfiles（macOS / Linux 両対応）

## セットアップ

### ワンライナー（新しいマシン）

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/schroneko/dotfiles/main/setup.sh)"
```

### 手動セットアップ

```bash
git clone git@github.com:schroneko/dotfiles.git ~/dotfiles

cd ~/dotfiles
stow --no-folding .

brew bundle --global
```

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

## 設定ファイルの更新

```bash
vim ~/dotfiles/.zshrc

cd ~/dotfiles
git add .zshrc
git commit -m "zshrc を更新"
git push
```

## 他のマシンの変更を取り込む

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
