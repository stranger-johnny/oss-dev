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

`oss-dev/main` で `public/**` が変更されると、GitHub Actions が自動で `oss` に
同期ブランチを push します。手動実行も可能です。
PRの作成だけは、作成者を実際の開発者にするため本人がワンクリックで行います。

```text
oss-dev/main
  ↓ (CI 自動・デプロイキーで push)
public/ を1コミットにした sync/* ブランチ（親は oss/main）
  ↓ (本人がジョブサマリの Compare リンクをクリック)
oss:main への Pull Request 作成（作成者=本人）
  ↓
メンテナがレビューしてマージ
```

処理内容は次の通りです。

1. `public/` の内容を、`oss/main` を親にした1コミットにまとめる（CI）
2. それを `oss` の `sync/<timestamp>` ブランチへ push する（CI）
3. ジョブサマリに出力される Compare リンクから、本人がPRを作成する

補足:

- **スナップショット方式**です。`oss-dev` の細かいコミット履歴は公開されず、
  同期ごとに1コミットにまとまります（内部履歴を公開したくない用途に好都合）。
- 同期コミットのメッセージは、`oss-dev` 側の**元コミットの件名**を使います
  （手動実行時はタイトルを入力可）。単一コミットのため、GitHub はこのメッセージを
  **PRタイトルの初期値**に使うので、実質「コミットメッセージ＝PRタイトル」です。
- `sync/*` は `oss/main` を親に作るため、`entirely different commit histories`
  にならず、通常のPull Requestとして比較できます。
- PR作成を完全自動化しない理由: PRの「作成者」は認証情報の持ち主に固定される
  ため、CIの共有認証で作ると常に同じ個人/Botになってしまう。最後のPR作成だけを
  本人が行うことで、作成者を実際の開発者にできる。

## 初回セットアップ

`oss` への push には、個人にも Bot にも紐づかない「デプロイキー（リポジトリ
専用のSSH鍵）」を使います。GitHub App も個人PATも不要です。

### 1. デプロイキーを生成する

```bash
ssh-keygen -t ed25519 -N "" -f oss-deploy -C "oss-dev sync"
# 公開鍵: oss-deploy.pub / 秘密鍵: oss-deploy
```

### 2. 公開鍵を `oss` に登録する

`oss` → Settings → Deploy keys → Add deploy key

- Key: `oss-deploy.pub` の内容
- **Allow write access にチェック**（push に必要）

### 3. 秘密鍵を `oss-dev` の Secret に登録する

`oss-dev` → Settings → Secrets and variables → Actions → New repository secret

- Name: `OSS_DEPLOY_KEY`
- Secret: `oss-deploy`（秘密鍵）の内容をそのまま貼り付け

登録後、ローカルの鍵ファイル（`oss-deploy` / `oss-deploy.pub`）は削除して構いません。

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
