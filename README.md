# dotfiles

chezmoi で管理している個人用 dotfiles

## 管理しているファイル

- `.vimrc` - Vim 設定 (Prettier + textlint 統合)
- `.zshrc` - Zsh 設定
- `.hushlogin` - macOS ログインメッセージ抑制

## セットアップ

### 新しい Mac での初回セットアップ

```bash
# chezmoi をインストール
brew install chezmoi

# dotfiles を適用
chezmoi init --apply git@github.com:schroneko/dotfiles.git
```

### 設定ファイルの更新

#### このマシンで変更を加えた場合

```bash
# ファイルを編集
vim ~/.vimrc

# chezmoi に反映
chezmoi add ~/.vimrc

# コミット & プッシュ
chezmoi cd
git add .
git commit -m "設定を更新"
git push
exit
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

# 変更を適用
chezmoi apply

# chezmoi のソースディレクトリに移動
chezmoi cd

# 新しいファイルを管理対象に追加
chezmoi add ~/.gitconfig
```

## 参考

- [chezmoi 公式ドキュメント](https://www.chezmoi.io/)
