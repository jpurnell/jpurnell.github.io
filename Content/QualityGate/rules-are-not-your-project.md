---
layout: BlogPostLayout
series: quality-gate
title: The Rules Are Not Your Project
tags: quality-gate, gate, architecture, ai
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:05
lastModified: 2026-08-13
published: true
---

# The Rules Are Not Your Project

**Separating shared standards from project-specific planning, and what that separation makes possible.**

---

If you work across a lot of repositories, you probably have a set of standards you want all of them to follow — coding rules, a testing contract, a session workflow. I keep mine in a repository called `development-guidelines`, and every Swift project I work on vendors a copy.

For a long time that copy held two kinds of thing in one folder: the shared rules, and the project's own planning — master plan, proposals, checklists, session summaries. It worked. Sixty-plus projects ran that way for a year without incident.

But mixing them costs you specific capabilities, and once I separated them those capabilities arrived all at once. That's what this post is about: not that the old way was broken, but that the new way can do things the old way structurally couldn't.

---

## The shape

```
<project>/
├── development-guidelines/   # shared — gitignored, replaceable, version-pinned
│   ├── rules/  skills/  scripts/  templates/
│   └── .framework-version
│
└── project/                  # yours — tracked in THIS repo
    ├── master_plan.md
    ├── plans/{ideas,proposals,upcoming,completed,archive}/
    ├── decisions/  summaries/  checklists/  docs/
```

One rule decides everything: **each directory has exactly one owner.** The framework directory is written upstream and consumed here. The project directory is written here and never leaves.

---

## What one owner buys you

**Updates become replacement.** When a directory has a single source, updating it is `rm -rf` and unpack. No merge, no allowlist of what to preserve, no conflict markers landing inside documents that an AI assistant will read as instructions. The update tool got shorter and more reliable at the same time, which doesn't happen often.

**Version pinning becomes meaningful.** `.framework-version` records a semver and a commit. That's only possible once the directory is homogeneous — you can't pin a folder that's half yours. And once you can pin it, "is this project on current rules?" becomes a question with an answer, which it previously wasn't.

**Planning history lives with the code it describes.** Proposals and session summaries are now tracked in the project's own repository. They show up in `git log` next to the commits they explain, they survive a fresh clone, and they archive when the project archives. That sounds obvious stated plainly; it simply wasn't available while they lived inside a vendored dependency.

**Everything ships.** The framework includes workflow skills — design, checklist, evaluate-tests, recover, summarize — that the old updater didn't know to carry, because its list of what-to-sync predated them. A replaceable directory has no list to fall behind. Add a folder upstream and every project gets it on next update.

That last one was the pleasant surprise. `evaluate-tests` implements a scored review the testing contract already specified — five dimensions, run during the RED phase, all ≥ 75 before moving to GREEN. The design existed and was good. It just hadn't been reaching anywhere. Now it does.

---

## Two smaller things worth stealing

**Drop numeric filename prefixes.** `01_CODING_RULES.md` became `coding_rules.md`. I'd kept the numbers for reading order, but they'd quietly started colliding — `03_` and `06_` each named two different documents. Reading order moved into an index file, where inserting a rule doesn't renumber its neighbours or invalidate references to them.

**Give plans a lifecycle in the filesystem.** `plans/` has `ideas`, `proposals`, `upcoming`, `completed`, `archive`. Advancing a plan is a `git mv`, so the move is a reviewable event and history follows the file. Sorting one project's accumulated proposals this way turned 62 open items into 29 — 38 had shipped and nobody had moved the paperwork. The stage being *visible in the path* is what makes that obvious.

---

## Where the gate fits

My quality gate has a `status` checker: it reads the master plan and compares the modules documented there against what's actually declared in `Package.swift`. Drift between them is the thing it catches — a module you built and never wrote down, or one you documented and never built.

Moving the master plan means telling the checker where it went:

```yaml
status:
  guidelinesPath: "."
  masterPlanPath: project/master_plan.md
```

Worth doing deliberately, because a checker whose input has moved will report that it skipped rather than that it failed — and a skip reads a lot like a pass at a glance. Mine skipped quietly until I pointed it at the new path. The moment it could see a real plan again it flagged three modules present in `Package.swift` and missing from the documentation, which is exactly its job.

That's the pairing I'd recommend, and the reason the two halves belong together. The structure gives you a plan that lives with its code and rules you can replace wholesale. The gate reads that structure and tells you when the two have drifted apart. Neither is worth much alone: clean layout with nothing checking it goes stale, and a checker pointed at nothing reports green indefinitely.

---

## If you want to try it

You don't need my framework for any of this. The pattern is three decisions:

1. **Put shared standards in a directory you never edit locally**, gitignore it, and record its version.
2. **Put project-owned planning in a directory you track**, in the repository whose code it describes.
3. **Point whatever checks your documentation at the second one**, and read what it says rather than the colour of the tick.

The first two are an afternoon. The third is the one that keeps paying, because it's what notices when the plan and the code stop agreeing — which they will, and usually not on a day you're looking.
