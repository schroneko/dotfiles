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

太字 (`**text**`) を使わず、読みやすい文章を書く。

## ファイル編集・作成の許可

Edit / Write ツールを使用する前に、必ずユーザーの明示的な許可を得ること。「〜しましょう」「〜に置け」などの発言は場所の指定であり、編集の許可ではない。「編集していい」「書いて」「作成して」など、明確な許可を確認してから実行する。

## ハルシネーション防止

- 機能について言及する前にコードを確認する。不確かな場合は「確認します」と言ってから調べる。
- URL を勝手に作り出さない。テストにはユーザーが提供した URL のみ使用する。
- 外部 URL をユーザーに提案する前に、必ず WebFetch でアクセスして存在と動作を確認する。検索結果に出てきただけでは不十分。401/403/404 エラーが返った URL は提案しない。
- API コールは必要最小限に。1 回のテストで確認できたら追加テストは不要。ユーザーは API 料金を払っている。

## Web 検索時の注意

現在は 2025 年。Web 検索時は必ず「2025」を含めて検索すること。2024 年以前の情報は古い可能性が高い。

## 最新 AI モデル（2025年12月時点）

### OpenAI

| モデル | 用途 | 備考 |
|--------|------|------|
| gpt-5.1 | 汎用（デフォルト推奨） | 2025年11月リリース。Instant/Thinking の2バリアント |
| gpt-5.1-codex-max | コーディング特化 | GitHub Copilot 向け |
| o3, o4-mini | リーズニング特化 | 複雑な問題解決向け |

### Anthropic

| モデル | 用途 | 備考 |
|--------|------|------|
| claude-opus-4-5-20251101 | 最高性能 | 2025年11月リリース。コーディング、エージェント、コンピュータ操作に最適 |
| claude-sonnet-4-5-20241022 | バランス型 | コストと性能のバランス |
| claude-haiku-4-5 | 高速・低コスト | 軽量タスク向け |

参考:
- [OpenAI GPT-5.1](https://openai.com/index/gpt-5-1-for-developers/)
- [Anthropic Claude Opus 4.5](https://www.anthropic.com/news/claude-opus-4-5)

## シークレット管理

API キーやトークンは 1Password CLI (`op`) で管理する。`.env` や `.dev.vars` に直接書かず、1Password から取得する。

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

| 設定 | DNS レコード | SSL 証明書 | 用途 |
|------|-------------|-----------|------|
| `routes` + `zone_name` | 手動作成 | 手動 | 特定パスのみ Worker に向ける場合 |
| `custom_domain = true` | 自動作成 | 自動 | ドメイン全体を Worker に向ける場合（推奨） |

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
npm install -D oxfmt oxlint textlint textlint-rule-preset-ja-spacing @textlint/textlint-plugin-text lefthook typescript vitest

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
