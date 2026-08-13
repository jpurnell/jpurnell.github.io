---
layout: BlogPostLayout
series: quality-gate
title: "SubmoduleAuditor: Git Submodules That Point at the Wrong Commit"
tags: quality-gate, project-health, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:44
lastModified: 2026-08-13
published: true
---

# SubmoduleAuditor

**Git submodules are a reliable way to ship a repo that doesn't build for anyone else. This checker keeps them honest.**

---

Submodules fail quietly. A submodule pointer references a commit that was never pushed; a submodule sits on a detached HEAD that drifted; a `.gitmodules` entry points somewhere a fresh clone can't reach. The person who set it up has the right state locally, so it works for them — and fails for everyone who clones after. `SubmoduleAuditor` catches these before they become someone else's confusing clone failure.

## What it checks

- **Unpushed pointers** — the superproject references a submodule commit that doesn't exist on the remote, so a fresh clone can't fetch it.
- **Detached or drifted HEADs** — a submodule that's wandered off its intended ref.
- **`.gitmodules` consistency** — the declared URLs and paths matching the actual submodule state.

It's a small, focused checker, and its value is entirely about *other people's clones*. The failure mode it prevents is the worst kind of "works on my machine": the code is correct, the tests pass, and the repo is still broken for the next person to check it out — because a pointer references a commit only your local copy has ever seen. A gate that runs on every commit catches the bad pointer while it's still cheap to fix.

## Try it

```bash
quality-gate --check submodule-audit
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
