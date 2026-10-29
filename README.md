# dotfiles

Mac Studio と MacBook Air で、設定ファイルと Homebrew のアプリを1つの定義で揃えるための repo です。

## 新しい Mac

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/schroneko/dotfiles/main/setup.sh)"
```

Homebrew の導入、この repo の clone、設定ファイルのリンク、`scripts/macos-defaults.sh` の適用、同期用 LaunchAgent の登録をします。

## 設定ファイル

次のファイルは `~` からこの repo へのシンボリックリンクです。編集したら commit して push し、もう片方の Mac は次の同期で取り込みます。リンクだけ作り直すときは `./setup.sh --link` を使います。

- `.zshrc` / `.zshenv`
- `.gitconfig`
- `.ssh/config`
- `.config/nvim/init.lua`
- `.config/mise/config.toml`
- `Library/KeyBindings/DefaultKeyBinding.dict`

## アプリの同期

LaunchAgent `com.schroneko.dotfiles-sync` が、ログイン時と1時間ごとに `scripts/sync.sh` を実行します。

1. この repo を `git pull` します。
2. 前回の同期から、この Mac で入れたアプリを `Brewfile` に足し、消したアプリを `Brewfile` から外します。前回の状態は `~/.local/state/dotfiles/brew-state.tsv` にあります。
3. `Brewfile` 通りに、足りないものを入れ、`Brewfile` にないものを消します。
4. formula と、`auto_updates` を持たない cask を `brew upgrade` します。自分で更新するアプリはアプリ自身に任せます。バックグラウンドで更新すると空のアプリが残ることがあったためです。
5. `scripts/homebrew-approve-nested-apps.sh` で、cask の中に入っているアプリの承認をします。
6. `mise install` と `mise upgrade` をします。
7. `ghq/repos.txt` の repo のうち、足りないものを clone し、変更のない repo を `git pull --ff-only` します。対象は GitHub の repo だけで、Hugging Face の repo は同期しません。
8. `Brewfile` と `ghq/repos.txt` に差分があれば commit して push します。

`Brewfile.ignore` に書いた名前は、同期の対象から外れ、入れることも消すこともしません。一度に 10 個を超えて消えそうなときは、事故とみなして止まります。

実行前に何が起きるかを見るには `./scripts/sync.sh --dry-run` を使います。ログは `~/Library/Logs/dotfiles-sync.log` です。

## その他

- `scripts/macos-defaults.sh`: Dock、Finder、キーボードなどの macOS 設定です。`--dry-run` で内容だけ確認できます。
- `docs/`: Mac Studio のリモートアクセスの手順です。
- 1Password CLI は Homebrew の通常版 cask `1password-cli` を使います。1Password Environment の ID はマシンごとに `~/.config/op/environment-id` に置き、`.zshenv` が読み込みます。
