---
name: chezmoi-sync
description: chezmoi でドットファイルを同期する。ローカル変更のリモート反映、またはリモート変更のローカル反映を行う。「chezmoi を反映して」「dotfiles を同期して」「chezmoi update」などのリクエストで使用する。
---

# chezmoi-sync

chezmoi で管理されたドットファイルの同期を行う。

## 前提条件

- chezmoi がインストール済みであること
- chezmoi のソースリポジトリが git で管理されていること

## ワークフロー

### 状態確認

まず現在の状態を確認する:

```bash
chezmoi status
chezmoi git status
```

状態に応じて適切な操作を提案する。

### パターン A: ローカル → リモート反映

ローカルで dotfiles を編集した場合、ソースに取り込んでプッシュする。

1. 差分確認
2. chezmoi re-add で変更をソースに反映
3. chezmoi git でコミット・プッシュ

### パターン B: リモート → ローカル反映

リモートで変更があった場合、ローカルに適用する。

1. chezmoi git fetch で差分確認
2. chezmoi update で適用（--force はユーザー確認後のみ）

## 注意事項

- コンフリクトがある場合は chezmoi diff で内容を確認し、ユーザーに判断を仰ぐ
- --force オプションは明示的な許可なしに使用しない
