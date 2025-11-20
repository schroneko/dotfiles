# グローバル開発ガイドライン

このファイルは、全てのプロジェクトで共通する開発ガイドラインを記述します。

## 日本語ドキュメントのフォーマット

### textlint による自動フォーマット

日本語のマークダウンファイルを扱うプロジェクトでは、textlint を使用して文書品質を保ちます。

#### 推奨セットアップ

```bash
# パッケージのインストール
npm install --save-dev textlint textlint-rule-preset-ja-spacing

# .textlintrc.json の作成
cat > .textlintrc.json << 'EOF'
{
  "rules": {
    "preset-ja-spacing": {
      "ja-space-between-half-and-full-width": {
        "space": "always"
      }
    }
  }
}
EOF

# package.json に script を追加
# "scripts": {
#   "textlint": "textlint \"**/*.md\"",
#   "textlint:fix": "textlint --fix \"**/*.md\""
# }
```

#### 使用方法

チェックのみ
```bash
npm run textlint
```

自動修正
```bash
npm run textlint:fix
```

#### 重要な運用ルール

1. マークダウンファイルを編集した後は、必ず `npm run textlint:fix` を実行する
2. 全角文字と半角文字の間にスペースが自動挿入される
3. コミット前に必ず実行すること

## マークダウン記法のガイドライン

### 太字の使用を避ける

- 太字 (`**text**`) は可読性を下げるため、使用を避ける
- 強調が必要な場合は、見出しレベルの調整やリスト構造で表現する
- セクションタイトルはマークダウンの見出し記法 (`##`, `###`) を使用する

### 推奨される記法

良い例
```markdown
## セクションタイトル

重要なポイント
- 項目 1
- 項目 2
```

避けるべき例
```markdown
**重要なポイント**
- 項目 1
- 項目 2
```

## コミットメッセージ

- 日本語で記述する
- 変更内容を簡潔に説明する
- 「なぜ」変更したかを重視する
