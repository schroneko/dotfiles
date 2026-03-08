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
git config core.hooksPath .githooks
git config pull.autostash true
stow --no-folding .

./scripts/brew-bundle-sync.sh
```

`./scripts/brew-bundle-sync.sh` は split Brewfile を正として同期し、Brewfile にない Homebrew パッケージは自動で削除します。削除を伴わずに同期したい場合だけ `--no-cleanup` を使います。

`brew install` / `brew uninstall` / `brew tap` / `brew untap` を実行すると、Brewfile 群は自動更新されます。formula と tap は共有対象として `.Brewfile.shared` に入り、macOS 専用の cask と override は `.Brewfile.darwin` に入ります。Linux 専用 override が必要な場合は `.Brewfile.linux` を使います。

`git pull` 後は `.githooks/post-merge` から `./scripts/brew-bundle-sync.sh` が自動実行され、そのマシン向けの package 状態が反映されます。トップレベルの `.Brewfile` は可読性のための合成ビューで、実際の source of truth は split Brewfile です。

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

- `.Brewfile` (generated view)
- `.Brewfile.shared`
- `.Brewfile.darwin`
- `.Brewfile.linux`

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
