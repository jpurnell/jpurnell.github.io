# justinpurnell.com

## Git: never stash

Do not use `git stash` (or `pull --autostash`) in this repo. If the tree is dirty and you need to pull, commit the work first — a WIP commit is fine — then `git pull --rebase`.

**Why:** Until 2026-07-05 a CI workflow rewrote `main` after every push, so sessions learned to stash before pulling. That workflow is gone (only GitHub's `pages-build-deployment` runs now, and it never commits), but the habit stayed and left 11 stashes, some never re-applied. On 2026-10-15 it produced an empty commit ("Add ORCID references", `5afd06c`) whose real changes sat in a stash, so nothing showed up on the site. Old stashes are archived as patches in `.git/stash-archive/`.

## Before saying a change is live

- `git show --stat HEAD` — confirm the commit actually contains files.
- `git ls-remote origin main` — confirm the ref moved. "Pre-push passed" prints before the transfer.
- Rebuild with `swift run IgniteStarter` so `docs/` (what GitHub Pages serves) includes the change.
