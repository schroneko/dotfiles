---
description: Setup pre-commit hooks with husky and lint-staged
---

新しい TypeScript プロジェクトに pre-commit hooks をセットアップしてください。

以下の手順で実施してください。

1. 依存パッケージのインストール
   npm install --save-dev husky lint-staged

2. husky の初期化
   npx husky init

3. package.json に lint-staged 設定を追加
   {
     "lint-staged": {
       "*.ts": ["bash -c 'tsc --noEmit'"],
       "*.md": ["textlint --fix"]
     }
   }

4. .husky/pre-commit ファイルを編集
   npx lint-staged

5. 動作確認
   TypeScript ファイルを変更してコミットを試す

注意点:
- tsconfig.json に skipLibCheck: true があることを確認
- bash -c でラップすることでプロジェクト全体の型チェックを実行
- textlint がインストールされていない場合は *.md の行を削除
