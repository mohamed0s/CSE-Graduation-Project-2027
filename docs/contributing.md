# Contributing: your daily workflow

The full rules (why, releases, hotfixes) are in [branching.md](branching.md). This is the quick version.

## Every day

```bash
git checkout main
git pull
git checkout -b mobile/home-screen      # <area>/<short-description>
# ... work, commit small and often ...
git push -u origin mobile/home-screen
```

Then on GitHub: **open a PR to `main`** → fill the template → wait for ✅ `CI passed` and 1 approval
→ **Squash and merge**. Your branch is deleted automatically.

## Branch names

```
backend/login-endpoint     mobile/home-screen      frontend/profile-page
ai/summarize-prompt        design/new-icons        infra/backend-dockerfile
docs/api-update
```

## Commit / PR titles

```
backend: add login endpoint
mobile: fix crash on profile page
```

## My PR is red ❌ — what now?

1. Click **Details** next to the failed check and read the log.
2. Fix it locally and push to the same branch. CI re-runs automatically.
3. You can't merge until it's green. Nobody can bypass this, so don't ask. 🙂

## Golden rules

1. Stay in your folder. Need something from another team? Open an issue and tag them.
2. Changed an API? Update [`docs/api/`](api/) in the same PR.
3. Never commit secrets (`.env`, API keys, keystores).
4. Small PRs > big PRs. Merge often. Pull `main` before you start each day.
5. Never push directly to `main` (it's blocked anyway).
