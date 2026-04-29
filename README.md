# dotfiles

GNU Stow で管理している個人用 dotfiles（macOS / Linux 両対応）

現在の実体は `~/ghq/github.com/schroneko/dotfiles` で、`~/.zshrc` や `~/.config/...` はそこへのシンボリックリンクです。Homebrew と `ghq` の状態はこの repo を唯一の source of truth として macOS 間で定期同期します。

新しい Mac で最初にやることは 1 つだけです。

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/schroneko/dotfiles/main/setup.sh)"
```

coding agent を新しい Mac で起動した場合も、まずこれを実行すれば十分です。

## セットアップ

### ワンライナー（新しいマシン）

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/schroneko/dotfiles/main/setup.sh)"
```

### 手動セットアップ

```bash
ghq get git@github.com:schroneko/dotfiles.git

cd ~/ghq/github.com/schroneko/dotfiles
git config core.hooksPath .githooks
git config pull.autostash true
stow --no-folding --target="$HOME" .

./scripts/macos-defaults.sh
./scripts/dotfiles-sync.sh
```

`./scripts/brew-bundle-sync.sh` は split Brewfile を正として同期し、Brewfile にない Homebrew パッケージは自動で削除します。削除を伴わずに同期したい場合だけ `--no-cleanup` を使います。

`brew install` / `brew uninstall` / `brew tap` / `brew untap` を実行すると、Brewfile 群は自動更新されます。formula・tap・macOS/Linux 両対応 cask は Homebrew の cask variation 情報から自動判定して `.Brewfile.shared` に入り、macOS 専用の cask と override は `.Brewfile.darwin` に入ります。Linux 専用 override が必要な場合は `.Brewfile.linux` を使います。`ghq/repos.txt` は `scripts/dotfiles-sync.sh` が更新します。

`scripts/dotfiles-sync.sh` は dotfiles repo を pull し、Homebrew を反映し、`ghq/repos.txt` の missing repo を clone し、clean な repo だけ `git pull --ff-only` で更新します。差分があれば managed state だけ commit/push します。LaunchAgent `com.schroneko.dotfiles-sync` が login 時と 5 分おきにこれを実行します。トップレベルの `.Brewfile` は可読性のための合成ビューで、実際の source of truth は split Brewfile です。

macOS 本体設定は `scripts/macos-defaults.sh` で管理します。Dock、Finder、キーボード、スクリーンショットなどの `defaults write` 設定を一括適用します。内容確認だけなら `./scripts/macos-defaults.sh --dry-run` を使います。

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
- `ghq/repos.txt`
- `Library/LaunchAgents/com.schroneko.dotfiles-sync.plist`
- `scripts/macos-defaults.sh`

## 設定ファイルの更新

```bash
vim ~/ghq/github.com/schroneko/dotfiles/.zshrc

cd ~/ghq/github.com/schroneko/dotfiles
git add .zshrc
git commit -m "zshrc を更新"
git push
```

## 他のマシンの変更を取り込む

```bash
cd ~/ghq/github.com/schroneko/dotfiles
./scripts/dotfiles-sync.sh
```

## よく使うコマンド

```bash
sync-now
./scripts/macos-defaults.sh
./scripts/dotfiles-sync.sh
stow --no-folding --target="$HOME" .
stow -D .
```

## 参考

- [GNU Stow](https://www.gnu.org/software/stow/)
