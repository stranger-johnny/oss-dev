#!/usr/bin/env bash
#
# oss-dev/public/ を公開リポジトリ `oss` へPRとして同期する。
#
# .github/workflows/sync-public.yml と同じ処理をローカルで実行する。
# `public/` を `git subtree split` で切り出し、`oss` の `sync/<timestamp>`
# ブランチへ push して、main 向けのPull Requestを作成する。
#
# 必要なもの:
#   - git
#   - `oss` へ認証済みの GitHub CLI (`gh`)
#   - clean な oss-dev 作業ツリー
#
set -euo pipefail

PREFIX="public"
PUBLIC_REPO="${PUBLIC_REPO:-stranger-johnny/oss}"
PUBLIC_REMOTE="${PUBLIC_REMOTE:-public}"
BASE_BRANCH="${BASE_BRANCH:-main}"
SYNC_BRANCH="sync/$(date -u +%Y%m%d-%H%M%S)"

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "error: working tree is not clean. Commit or stash first." >&2
  exit 1
fi

# 公開リポジトリの remote を登録する（登録済みなら何もしない）。
if ! git remote get-url "$PUBLIC_REMOTE" >/dev/null 2>&1; then
  git remote add "$PUBLIC_REMOTE" "git@github.com:${PUBLIC_REPO}.git"
fi

echo "==> Splitting '$PREFIX/' into $SYNC_BRANCH"
git branch -D "$SYNC_BRANCH" >/dev/null 2>&1 || true
git subtree split --prefix="$PREFIX" -b "$SYNC_BRANCH"

echo "==> Pushing $SYNC_BRANCH to $PUBLIC_REPO"
git push "$PUBLIC_REMOTE" "$SYNC_BRANCH:$SYNC_BRANCH"

echo "==> Opening PR into $PUBLIC_REPO:$BASE_BRANCH"
gh pr create \
  --repo "$PUBLIC_REPO" \
  --base "$BASE_BRANCH" \
  --head "$SYNC_BRANCH" \
  --title "Sync public from oss-dev" \
  --body "Automated publish from oss-dev/${PREFIX} via git subtree split."

echo "==> Done. Clean up the local split branch with: git branch -D $SYNC_BRANCH"
