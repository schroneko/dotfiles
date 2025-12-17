# グローバル開発ガイドライン

## CLAUDE.md の使い分け

- グローバル (`~/.claude/CLAUDE.md`): 全プロジェクト共通のルール
  - 言語設定、記法ルール、シークレット管理方法
  - 新規プロジェクトセットアップ手順
  - シェル操作の注意点（zsh/bash の違いなど）
- ローカル (`<project>/CLAUDE.md`): プロジェクト固有の情報
  - 技術スタック、アーキテクチャ
  - API エンドポイント、データフロー
  - 環境変数、デプロイ手順
  - プロジェクト固有の制約や注意点

## エラー解決の記録

エラーは金脈。解決できたときは必ず CLAUDE.md に次からどうすればいいかを書いておく。

## 言語設定

- コミットメッセージ: 日本語で記述し、「なぜ」変更したかを重視する
- 会話: 日本語で応答する

## ファイル命名規則

- ファイル名・ディレクトリ名は英語（ASCII 文字）のみを使用する
- 日本語や全角文字をファイル名に含めない
- 単語の区切りはハイフン (`-`) またはアンダースコア (`_`) を使用する

## 記法ルール

- 太字 (`**text**`) を使わず、読みやすい文章を書く
- コード内にコメントを書かない。設定ファイルの説明コメントも不要

## ファイル編集・作成の許可

Edit / Write ツールを使用する前に、必ずユーザーの明示的な許可を得ること。「〜しましょう」「〜に置け」などの発言は場所の指定であり、編集の許可ではない。「編集していい」「書いて」「作成して」など、明確な許可を確認してから実行する。

## コミット・プッシュ

指示された作業が完了したら、ユーザーに確認を求める。確認が OK であれば、コミットまで行う。git push は必ずユーザーの承認後に実行する。

## Subagent 活用ポリシー

コンテキスト節約のため、Subagent を積極活用する。メインエージェントはオーケストレーターとして振る舞い、実作業は Subagent に委譲する。

### 基本ルール

- 2 つ以上の独立したタスクが発生したら、即座に Task ツールで Subagent に委譲する
- 独立したタスクは必ず並列実行する（単一メッセージで複数の Task ツール呼び出し）
- Subagent には `model: opus` を指定する
- バックグラウンド実行（`run_in_background: true`）を活用し、複数 Subagent を同時稼働させる
- Subagent の結果は `TaskOutput` で回収して統合報告する

### Subagent に委譲すべきタスク

| カテゴリ     | タスク例                                         |
| ------------ | ------------------------------------------------ |
| コード探索   | ファイル検索、パターン検索、アーキテクチャ調査   |
| 実装         | 機能追加、バグ修正、リファクタリング             |
| テスト       | テスト実行、テスト修正、カバレッジ確認           |
| ドキュメント | README 更新、API ドキュメント作成                |
| デバッグ     | エラー調査、ログ分析、原因特定                   |
| リサーチ     | 技術調査、ライブラリ比較、ベストプラクティス調査 |
| Web 検索     | 最新情報収集、ドキュメント確認、エラー解決策検索 |

### 並列実行の例

```
ユーザー: 「テストを修正して、ドキュメントも更新して」

→ 並列で 2 つの Task を起動:
  - Task 1: テスト修正（model: opus, run_in_background: true）
  - Task 2: ドキュメント更新（model: opus, run_in_background: true）
→ TaskOutput で結果を回収
→ 統合して報告
```

```
ユーザー: 「React 19 の新機能と、現在のコードベースでの使用箇所を調べて」

→ 並列で 2 つの Task を起動:
  - Task 1: Web 検索で React 19 の新機能を調査
  - Task 2: コードベースで React 関連の実装を探索
→ 両方の結果を統合して報告
```

### メインエージェントの役割

- タスクの分解と Subagent への割り振り
- 結果の統合と最終報告
- ユーザーとのコミュニケーション
- 全体の進捗管理

細かいファイル操作やコード変更は自分で行わず、Subagent に任せる。

## ハルシネーション防止

- 機能について言及する前にコードを確認する。不確かな場合は「確認します」と言ってから調べる。
- URL を勝手に作り出さない。テストにはユーザーが提供した URL のみ使用する。
- 外部 URL をユーザーに提案する前に、必ず WebFetch でアクセスして存在と動作を確認する。検索結果に出てきただけでは不十分。401/403/404 エラーが返った URL は提案しない。
- API コールは必要最小限に。1 回のテストで確認できたら追加テストは不要。ユーザーは API 料金を払っている。

## Web 検索時の注意

現在は 2025 年。Web 検索時は必ず「2025」を含めて検索すること。2024 年以前の情報は古い可能性が高い。

## 最新 AI モデル（2025年12月時点）

### OpenAI

| モデル            | 用途                   | 備考                                               |
| ----------------- | ---------------------- | -------------------------------------------------- |
| gpt-5.1           | 汎用（デフォルト推奨） | 2025年11月リリース。Instant/Thinking の2バリアント |
| gpt-5.1-codex-max | コーディング特化       | GitHub Copilot 向け                                |
| o3, o4-mini       | リーズニング特化       | 複雑な問題解決向け                                 |

### Anthropic

| モデル                     | 用途           | 備考                                                                   |
| -------------------------- | -------------- | ---------------------------------------------------------------------- |
| claude-opus-4-5-20251101   | 最高性能       | 2025年11月リリース。コーディング、エージェント、コンピュータ操作に最適 |
| claude-sonnet-4-5-20241022 | バランス型     | コストと性能のバランス                                                 |
| claude-haiku-4-5           | 高速・低コスト | 軽量タスク向け                                                         |

参考:

- [OpenAI GPT-5.1](https://openai.com/index/gpt-5-1-for-developers/)
- [Anthropic Claude Opus 4.5](https://www.anthropic.com/news/claude-opus-4-5)

## シークレット管理

API キーやトークンは 1Password CLI (`op`) で管理する。

- ローカル開発: `.dev.vars` に直接書いて OK（gitignore 済み、毎回の認証は非現実的）
- 本番デプロイ: `wrangler secret put` や CI/CD で 1Password から取得して設定
- 共有・CI 環境: `op run` や `op://` URI 形式で動的に取得

```bash
# 例: 1Password から API キーを取得してコマンドに渡す
op run --env-file=.env.1password -- npm run dev

# 例: 特定のキーを取得
op item get "ANTHROPIC_API_KEY" --fields credential

# 例: フィールド構造が不明な場合
op item get "ITEM_NAME" --format json | jq '.fields[] | {label, type}'

# 例: アイテム名を部分一致で検索
op item list | grep -i "keyword"
```

1Password に登録済みのキーは `op item list` で確認できる。フィールド名は `credential`（API キー用）または `password`（ログイン用）が一般的。

注意: `op item get` で値を取得する際は `--reveal` フラグが必要。フラグがないと `[use 'op item get ... --reveal' to reveal]` というメッセージが返される。

```bash
# 正しい例
op item get "SUMMARY_API_KEY" --fields credential --reveal

# 間違い（値が取得できない）
op item get "SUMMARY_API_KEY" --fields credential
```

`op item get` で同じアイテムを 2 回取得しない。一度取得したら変数に保存して再利用する。

## Claude Code での環境変数自動読み込み

プロジェクトの `.dev.vars` を全ての Bash コマンドで自動的に利用可能にする設定。

問題: SessionStart hook で `CLAUDE_ENV_FILE` に書き込む方法は、セッション継続時（resume / auto compact 後）に不安定。

解決策: `~/.zshrc` で `CLAUDE_ENV_FILE` を事前に設定する。

```bash
# ~/.zshrc に追加
export CLAUDE_ENV_FILE="$HOME/.claude/env-loader.sh"
```

```bash
# ~/.claude/env-loader.sh
#!/bin/bash
if [ -n "$CLAUDE_PROJECT_DIR" ] && [ -f "$CLAUDE_PROJECT_DIR/.dev.vars" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    if [ -n "$line" ] && [[ ! "$line" =~ ^# ]]; then
      key="${line%%=*}"
      value="${line#*=}"
      export "$key=$value"
    fi
  done < "$CLAUDE_PROJECT_DIR/.dev.vars"
fi
```

注意: `IFS='=' read -r key value` は値の中の `=`（Base64 パディング等）も区切り文字として扱ってしまう。`${line%%=*}` と `${line#*=}` で最初の `=` だけで分割する。

これにより、セッションの種類（新規/resume/compact）に関係なく、全ての Bash コマンド実行前に `.dev.vars` が自動で読み込まれる。

### 解決済み（2025-12-14）

`settings.json` で `CLAUDE_ENV_FILE` を設定することで解決。

- `claude config set envFile /Users/username/.claude/env-loader.sh` を実行
- env-loader.sh は `${CLAUDE_PROJECT_DIR:-$(pwd)}` でフォールバック
- CLAUDE_PROJECT_DIR が未設定でも、pwd がプロジェクトディレクトリを指すため正常動作

## chezmoi

`chezmoi update` でコンフリクトが発生したら、確認を求めずに自分で `chezmoi diff` を実行し、適切なアクション（`--force` でリモート適用、または `chezmoi re-add` でローカル反映）を提案する。

## CLI コマンドの構文確認

不明な CLI コマンドは推測で実行せず、まずヘルプを確認する。

```bash
op item create --help
op item template list
op item template get "API Credential"
```

flyctl も同様:

```bash
flyctl logs --help
flyctl logs --app <app-name> --no-tail | tail -30
```

## Fly.io

無料枠: VM 1 台につき 256MB RAM まで。

```toml
[[vm]]
  memory = '256mb'
  cpu_kind = 'shared'
  cpus = 1

[http_service]
  auto_stop_machines = 'stop'
  auto_start_machines = true
  min_machines_running = 0
```

yt-dlp を VPS/クラウドから実行すると YouTube がボット判定してブロックする。字幕は `youtube-caption-extractor` で対応可能。

## Bash ツールの永続シェルセッション

`CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1`（settings.json で設定）により、Bash ツールは永続シェルセッションで動作する。

- 作業ディレクトリがプロジェクトルートに維持される
- `source .venv/bin/activate` などの状態が後続のコマンドでも保持される
- コマンドを `&&` で繋げる必要がない

注意:

- `cd` コマンドは原則使用しない
- ディレクトリ移動が必要な場合は、事前にユーザーに確認する

## uv（Python パッケージ管理）

`uv add` を基本とする。`uv pip install` は移行期間や一時実験のみ。

| コマンド         | 用途                 | pyproject.toml | uv.lock      |
| ---------------- | -------------------- | -------------- | ------------ |
| `uv add`         | 新規プロジェクト開発 | 自動更新       | 自動生成     |
| `uv pip install` | 移行期間・一時実験   | 更新されない   | 生成されない |

```bash
# パッケージ追加（pyproject.toml に記録）
uv add requests

# 開発用依存
uv add --dev pytest

# 実行（activate 不要）
uv run python main.py

# 環境同期（clone 後）
uv sync

# 既存 requirements.txt からの移行
uv add -r requirements.txt
```

## zsh でのコマンド実行（重要）

macOS のデフォルトシェルは zsh。以下のケースで `parse error near ')'` などのエラーが発生する：

- `$(...)` コマンド置換
- `while read` ループ
- グロブパターン（`*-client.ts` など）
- 特殊文字（`+`, `=`, `(`, `)` など）を含む値

**原則: `parse error` が出たら即座に `bash -c '...'` でラップする。**

```bash
# NG: zsh でパースエラーになる例
found=$(grep -l "domain" src/services/*-client.ts)
echo "a b c" | while read x; do echo $x; done

# OK: bash -c でラップ
bash -c 'found=$(grep -l "domain" src/services/*-client.ts) && echo $found'
bash -c 'echo "a b c" | while read x; do echo $x; done'
```

複雑なシェルコマンド（ループ、パイプ、コマンド置換の組み合わせ）は最初から `bash -c` を使う。1 回目のエラーで対処し、同じパターンで複数回試行しない。

## timeout コマンド（macOS）

macOS には `timeout` コマンドがない。代わりに `gtimeout`（GNU coreutils）を使用する。

```bash
# 5 秒でタイムアウト
gtimeout 5 curl https://example.com

# タイムアウト時に SIGKILL を送信
gtimeout --signal=KILL 10 long-running-command
```

## Cloudflare: Pages ではなく Workers を使う

2025年時点で Cloudflare Pages は非推奨。新機能開発は全て Workers に集中しており、Pages は維持モードで将来的に終了予定。

- 新規プロジェクトでは Cloudflare Workers を使用する
- Workers は静的アセット配信と SSR の両方をサポート
- Pages Functions ではなく Workers を使う

参考: https://developers.cloudflare.com/workers/static-assets/migration-guides/migrate-from-pages/

### カスタムドメイン設定: routes ではなく custom_domain を使う

Workers にカスタムドメインを設定する場合、`routes` + `zone_name` ではなく `custom_domain = true` を使用する。

```toml
# NG: DNS レコードを手動作成する必要がある
routes = [
  { pattern = "example.com/*", zone_name = "example.com" }
]

# OK: DNS レコードと SSL 証明書が自動作成される
[[routes]]
pattern = "example.com"
custom_domain = true
```

| 設定                   | DNS レコード | SSL 証明書 | 用途                                       |
| ---------------------- | ------------ | ---------- | ------------------------------------------ |
| `routes` + `zone_name` | 手動作成     | 手動       | 特定パスのみ Worker に向ける場合           |
| `custom_domain = true` | 自動作成     | 自動       | ドメイン全体を Worker に向ける場合（推奨） |

### wrangler CLI の注意点

- コマンド構文: スペース区切り（`wrangler kv key list`）。古いコロン区切り（`wrangler kv:key list`）は動作しない
- KV 操作時は `--remote` オプション必須。省略するとローカルの空ストレージを参照してしまう

```bash
# NG: ローカルストレージを参照（データがないように見える）
npx wrangler kv key list --namespace-id xxx

# OK: リモート（本番）KV を参照
npx wrangler kv key list --namespace-id xxx --remote
```

- 一括削除: キーを JSON 配列ファイルに保存して `wrangler kv bulk delete` を使用

```bash
# キーをリストアップして JSON 配列に変換
npx wrangler kv key list --namespace-id xxx --remote | jq -r '.[].name' | jq -R . | jq -s . > keys.json

# 一括削除
npx wrangler kv bulk delete keys.json --namespace-id xxx --remote --force
```

## DNS キャッシュクリア

DNS 設定変更後にサイトにアクセスできない場合、ローカルの DNS キャッシュが原因の可能性がある。

```bash
# macOS
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder

# Windows (管理者権限の PowerShell)
ipconfig /flushdns

# Linux
sudo systemd-resolve --flush-caches
```

ブラウザの DNS キャッシュも確認:

- Chrome: `chrome://net-internals/#dns` → 「Clear host cache」
- Safari: 開発メニュー → 「キャッシュを空にする」

## Git hooks

Git hooks には lefthook を使う。husky は使わない。

## 新規プロジェクトセットアップ

### 手順

```bash
# 1. ディレクトリ作成 & 移動
mkdir <repo-name> && cd <repo-name>

# 2. Git 初期化
git init

# 3. npm 初期化
npm init -y

# 4. TypeScript 設定ファイル生成
npx tsc --init

# 5. 設定ファイル作成（後述の内容で作成）
#    - .oxfmtrc.json
#    - .oxlintrc.json
#    - lefthook.yml
#    - .textlintrc
#    - .github/workflows/deploy.yml
#    - .gitignore

# 6. パッケージ一括インストール
npm install -D oxfmt oxlint oxlint-tsgolint textlint textlint-rule-preset-ja-spacing @textlint/textlint-plugin-text lefthook typescript vitest

# 7. lefthook 初期化
npx lefthook install

# 8. GitHub リポジトリ作成 & push
gh repo create <repo-name> --private --source=. --push
```

### .oxfmtrc.json

Prettier 互換の設定。シングルクォート、printWidth: 80 を使用:

```json
{
  "$schema": "./node_modules/oxfmt/configuration_schema.json",
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "semi": true,
  "singleQuote": true,
  "embeddedLanguageFormatting": "auto"
}
```

### .oxlintrc.json

oxlint Alpha から `--type-aware --type-check` オプションが追加され、`tsc --noEmit && eslint` を 1 コマンドに統合できるようになった。

- `--type-aware`: TypeScript の型情報を使った lint ルール（`@typescript-eslint` 相当）を有効化
- `--type-check`: `tsc --noEmit` 相当の型チェックを同時実行

基本的なルール設定。デフォルトで十分な場合は省略可能:

```json
{
  "$schema": "./node_modules/oxlint/configuration_schema.json",
  "plugins": ["typescript", "unicorn", "oxc"],
  "rules": {
    "no-console": "warn",
    "no-unused-vars": "error",
    "eqeqeq": "error"
  },
  "ignorePatterns": ["dist/", "node_modules/"]
}
```

### tsconfig.json 変更箇所

`npx tsc --init` 実行後、以下を設定:

```json
{
  "compilerOptions": {
    "target": "ES2021",
    "module": "ES2022",
    "lib": ["ES2021"],
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
```

### lefthook.yml

```yaml
pre-commit:
  parallel: true
  commands:
    oxfmt:
      glob: "*.{js,ts,tsx,json,md,css,yaml,yml}"
      run: npx oxfmt --no-error-on-unmatched-pattern {staged_files}
      stage_fixed: true
    oxlint:
      glob: "*.{js,ts,tsx}"
      run: npx oxlint --type-aware --type-check --fix {staged_files}
      stage_fixed: true
    textlint:
      glob: "*.md"
      run: npx textlint --fix {staged_files}
      stage_fixed: true

pre-push:
  commands:
    test:
      run: npm test
```

### .textlintrc

```json
{
  "rules": {
    "preset-ja-spacing": {
      "ja-space-between-half-and-full-width": {
        "space": "always"
      }
    }
  }
}
```

### GitHub Actions（Cloudflare Workers デプロイ）

`.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
      - run: npm ci
      - uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

### .gitignore

```
node_modules/
.env
.env.*
!.env.example
.wrangler/
dist/
*.log
```

### package.json scripts

```json
{
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest",
    "lint": "oxlint --type-aware --type-check --fix src/ && textlint --fix '**/*.md'",
    "format": "oxfmt",
    "check": "oxfmt --check && oxlint --type-aware --type-check src/",
    "prepare": "lefthook install"
  }
}
```
