# oss-dev（開発用・非公開）

公開リポジトリ [`oss`](https://github.com/stranger-johnny/oss) の開発用リポジトリです。

このリポジトリでは、公開してよいコードだけを `public/` 配下で管理します。
`public/` の内容は GitHub Actions により `oss` へ同期され、`oss` 側に Pull Request として作成されます。

## ディレクトリ構成

```text
oss-dev/
├─ public/            # 公開対象。ここだけが `oss` に反映される
├─ internal/          # 非公開。`oss` には反映されない
├─ scripts/
│  └─ sync-public.sh  # 手動公開用スクリプト（Actions と同じ処理）
└─ .github/workflows/
   ├─ ci.yml          # `public/` のテストを実行
   └─ sync-public.yml # `public/` を `oss` に同期してPRを作成
```

## 基本ルール

1. **`public/` 配下の内容は公開されます。**
   秘密情報、実験コード、内部ツール、非公開メモは置かないでください。
2. `oss` リポジトリを手作業で編集しないでください。
   `oss` は `oss-dev/public/` から生成される公開用リポジトリです。
3. 開発は GitHub Flow で行います。
   `main` から作業ブランチを作成し、Pull Request で `main` にマージします。

## ブランチ戦略

| リポジトリ | ブランチ | ルール |
| --- | --- | --- |
| `oss-dev` | `main` | 開発の trunk。常にCIが通る状態にする |
| `oss-dev` | `feature/*`, `fix/*`, `chore/*` | 作業ブランチ。`main` にPRを出す |
| `oss` | `main` | 公開の正。保護ブランチにしてPR経由のみ更新する |
| `oss` | `sync/*` | GitHub Actions が自動生成する公開用PRブランチ |

## 公開フロー

`oss-dev/main` で `public/**` が変更されると、GitHub Actions が自動で公開用 Pull Request を作成します。
手動実行も可能です。

```text
oss-dev/main
  ↓
git subtree split --prefix=public
  ↓
oss の sync/* ブランチへ push
  ↓
oss:main への Pull Request 作成
  ↓
メンテナがレビューしてマージ
```

処理内容は次の通りです。

1. `git subtree split --prefix=public` で `public/` だけを切り出す
2. 切り出した内容を `oss` の `sync/<timestamp>` ブランチへ push する
3. `oss:main` への Pull Request を作成する

## 初回セットアップ

`oss-dev` に `PUBLIC_SYNC_TOKEN` という Repository Secret または Organization Secret を作成してください。

このトークンには、`stranger-johnny/oss` に対して以下の権限が必要です。

- Fine-grained PAT の場合:
  - `Contents: Read and write`
  - `Pull requests: Read and write`
- Classic PAT の場合:
  - `repo`

その後、`oss:main` にブランチ保護を設定してください。

- Pull Request 経由の更新を必須にする
- 直接 push を禁止する
- CI の成功を必須にする

## 手動で公開PRを作る場合

通常は GitHub Actions が自動で実行しますが、ローカルから同じ処理を実行することもできます。

```bash
./scripts/sync-public.sh
```

実行前に、GitHub CLI (`gh`) が認証済みであること、作業ツリーが clean であることを確認してください。
