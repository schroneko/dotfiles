# dotfiles

chezmoi で管理している個人用 dotfiles

## 管理しているファイル

### シェル & エディタ

- `.vimrc`
- `.zshrc`
- `.bashrc`
- `.hushlogin`
- `.textlintrc`

### Git & SSH

- `.gitconfig`
- `.ssh/config`
- `.config/gh/`

### ターミナル & プロンプト

- `.config/ghostty/config`
- `.config/starship.toml`

### パッケージ管理 & 自動化

- `.Brewfile`
- `~/Library/LaunchAgents/com.homebrew.autoupdate.plist`

### Claude Code

- `.claude/CLAUDE.md`
- `.claude/settings.json`
- `.claude/commands/`
- `.claude/hooks/`

## セットアップ

### 新しい Mac での初回セットアップ

```bash
# chezmoi をインストール
brew install chezmoi

# dotfiles を適用
chezmoi init --apply git@github.com:schroneko/dotfiles.git

# Homebrew パッケージをインストール
brew bundle --global

# LaunchAgent を有効化（Homebrew 自動更新）
launchctl load ~/Library/LaunchAgents/com.homebrew.autoupdate.plist
```

### 設定ファイルの更新

#### 日常的な編集方法（推奨）

```bash
# chezmoi edit でファイルを編集
chezmoi edit ~/.zshrc

# 変更をコミット & プッシュ
chezmoi git add .
chezmoi git commit -- -m "zshrc を更新"
chezmoi git push
```

#### 既存のファイルを直接編集した場合

```bash
# 通常通り編集
vim ~/.vimrc

# chezmoi に反映
chezmoi add ~/.vimrc

# コミット & プッシュ
chezmoi git add .
chezmoi git commit -- -m "vimrc を更新"
chezmoi git push
```

#### 他のマシンの変更を取り込む場合

```bash
# 最新版に同期
chezmoi update
```

## よく使うコマンド

```bash
# 管理されているファイル一覧
chezmoi managed

# ローカルファイルと chezmoi の差分を確認
chezmoi diff

# ファイルを編集（推奨）
chezmoi edit ~/.zshrc

# 変更を適用
chezmoi apply

# 新しいファイルを管理対象に追加
chezmoi add ~/.gitconfig

# Git 操作
chezmoi git status
chezmoi git add .
chezmoi git commit -- -m "コミットメッセージ"
chezmoi git push
```

## Tips

- `chezmoi edit --apply` で編集後すぐに適用
- `chezmoi edit --watch` で保存時に自動適用
- `chezmoi cd` でソースディレクトリに移動（直接 git 操作したい場合）

## 参考

- [chezmoi 公式ドキュメント](https://www.chezmoi.io/)
