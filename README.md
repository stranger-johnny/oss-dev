# oss-dev (private)

Private development repository for the public [`oss`](https://github.com/stranger-johnny/oss) project.

## Layout

```text
oss-dev/
├─ public/            # PUBLISHED to `oss`. Only put publishable code here.
├─ internal/          # Private only. Never published.
├─ scripts/
│  └─ sync-public.sh  # Manual publish helper (same logic as the workflow).
└─ .github/workflows/
   ├─ ci.yml          # Tests public/ on every push/PR here.
   └─ sync-public.yml # Publishes public/ to `oss` and opens a PR.
```

## Golden rules

1. **Anything under `public/` will become public.** Do not put secrets,
   experiments, or internal tooling there.
2. Never edit the `oss` repository by hand. It is generated from `public/`.
3. Develop with GitHub Flow: branch off `main`, open a PR, merge to `main`.

## Branch strategy

| Repo      | Branch            | Rule                                             |
| --------- | ----------------- | ------------------------------------------------ |
| `oss-dev` | `main`            | Trunk. Green at all times. PR-only.              |
| `oss-dev` | `feature/*` etc.  | Work branches, PR into `main`.                   |
| `oss`     | `main`            | Public source of truth. Protected, PR-only.      |
| `oss`     | `sync/*`          | Auto-generated publish branches (PR head).       |

## Publishing

Publishing runs automatically via GitHub Actions when `public/**` changes on
`main`, and can also be triggered manually (Actions → "Sync public → oss" →
Run workflow). It:

1. runs `git subtree split --prefix=public`,
2. pushes the result to a `sync/<timestamp>` branch on `oss`,
3. opens a Pull Request into `oss:main`.

A maintainer then reviews and merges that PR.

### One-time setup

Create a repository (or organization) secret named `PUBLIC_SYNC_TOKEN` on
`oss-dev` containing a token that can push to and open PRs on `oss`:

- **Fine-grained PAT** scoped to `stranger-johnny/oss` with
  `Contents: Read and write` and `Pull requests: Read and write`, or
- a classic PAT with the `repo` scope.

Then protect `oss:main` (require PRs, disallow direct pushes) and disable
Issues / external PRs on `oss`.
