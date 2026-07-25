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

公開ワークフローは GitHub App のインストールトークンで `oss` を操作します。
個人アカウントに依存せず、実行のたびに短命なトークンを発行します。

### 1. GitHub App を作成する

GitHub → Settings → Developer settings → GitHub Apps → New GitHub App

- Repository permissions:
  - `Contents: Read and write`
  - `Pull requests: Read and write`
- Webhook は不要（Active のチェックを外す）
- 作成後、`Generate a private key` で秘密鍵（`.pem`）を発行する
- `App ID` を控えておく

### 2. App を `oss` にインストールする

作成した App の `Install App` から、`stranger-johnny/oss` にのみインストールします。

### 3. Secret を登録する

`oss-dev` の Repository Secret（または Organization Secret）に次の2つを登録します。

- `SYNC_APP_ID`: 作成した App の App ID
- `SYNC_APP_PRIVATE_KEY`: 発行した秘密鍵（`.pem` の中身をそのまま貼り付け）

### 4. ブランチ保護を設定する

`oss:main` にブランチ保護を設定してください。

- Pull Request 経由の更新を必須にする
- 直接 push を禁止する
- CI の成功を必須にする

## 手動で公開PRを作る場合

通常は GitHub Actions が自動で実行しますが、ローカルから同じ処理を実行することもできます。

```bash
./scripts/sync-public.sh
```

実行前に、GitHub CLI (`gh`) が認証済みであること、作業ツリーが clean であることを確認してください。
