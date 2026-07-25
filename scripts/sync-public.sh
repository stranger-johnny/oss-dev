#!/usr/bin/env bash
#
# oss-dev/public/ を公開リポジトリ `oss` へPRとして同期する（ローカル実行版）。
#
# public/ を oss/main を親にした1コミット（スナップショット）にして push し、
# 本人のアカウントでPRを作成する。
#
# 必要なもの:
#   - git
#   - `oss` へ push / PR 作成できる認証済みの GitHub CLI (`gh`)
#
set -euo pipefail

PREFIX="public"
PUBLIC_REPO="${PUBLIC_REPO:-stranger-johnny/oss}"
PUBLIC_REMOTE="${PUBLIC_REMOTE:-public}"
BASE_BRANCH="${BASE_BRANCH:-main}"
SYNC_BRANCH="sync/$(date -u +%Y%m%d-%H%M%S)"

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

# 公開リポジトリの remote を登録する（登録済みなら何もしない）。
if ! git remote get-url "$PUBLIC_REMOTE" >/dev/null 2>&1; then
  git remote add "$PUBLIC_REMOTE" "git@github.com:${PUBLIC_REPO}.git"
fi

git fetch "$PUBLIC_REMOTE" "$BASE_BRANCH"

# コミットメッセージ＝PRタイトル。第1引数があればそれを、無ければ元コミット件名を使う。
message="${1:-$(git log -1 --format=%s HEAD)}"

# public/ の tree を、oss/main を親にした1コミットにして push する。
tree="$(git rev-parse "HEAD:${PREFIX}")"
commit="$(git commit-tree "$tree" -p "${PUBLIC_REMOTE}/${BASE_BRANCH}" -m "$message")"
git push "$PUBLIC_REMOTE" "${commit}:refs/heads/${SYNC_BRANCH}"

gh pr create \
  --repo "$PUBLIC_REPO" \
  --base "$BASE_BRANCH" \
  --head "$SYNC_BRANCH" \
  --title "$message" \
  --body "oss-dev/${PREFIX} のスナップショットを公開します。"
