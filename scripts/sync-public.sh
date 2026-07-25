#!/usr/bin/env bash
#
# Publish oss-dev/public/ to the public `oss` repository as a PR.
#
# This is the manual equivalent of .github/workflows/sync-public.yml.
# It performs a `git subtree split` of `public/`, pushes the result to a
# `sync/<timestamp>` branch on `oss`, and opens a Pull Request into main.
#
# Requirements:
#   - git, and the GitHub CLI (`gh`) authenticated against `oss`.
#   - Run from a clean checkout of oss-dev on the branch you want to publish.
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

# Register the public repo as a remote (idempotent).
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
