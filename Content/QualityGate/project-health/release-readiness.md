---
layout: BlogPostLayout
series: quality-gate
title: "ReleaseReadinessAuditor: The Placeholder You Forgot to Fill In"
tags: quality-gate, project-health, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:41
lastModified: 2026-08-13
published: true
---

# ReleaseReadinessAuditor

**Missing changelog entries, README placeholders, `TODO`/`FIXME` pending-work markers — the small omissions that turn into embarrassing releases.**

---

Every release has a checklist, and every checklist has the item everyone forgets. `ReleaseReadinessAuditor` is that checklist as code: it flags the artifacts that say "not actually ready" even when the tests are green.

## What it catches

- **Missing CHANGELOG entries** — a batch of commits with nothing recorded in the changelog. The project's own rule pairs a feature commit with its changelog entry; this enforces it.
- **README placeholders** — the `TODO: description here`, the `<!-- fill in -->`, the lorem-ipsum paragraph that shipped because nobody re-read the README before tagging.
- **Pending-work markers** — `TODO`, `FIXME`, `XXX` left in code that's about to be released, so "I'll come back to this" doesn't silently become "this shipped."

None of these are correctness bugs. They're the difference between a release that looks finished and one that looks abandoned — and they're exactly the things a human reviewer skims past because they're focused on the code. A gate doesn't skim.

The philosophy running through the whole project applies here too: the checklist that lives in a document gets skipped under deadline pressure; the checklist that's a gate runs every time, including the time you're in a hurry — which is precisely when you'd otherwise ship the placeholder.

## The tag invariant, and where it belongs

Added later, after the same failure recurred often enough to stop being bad luck: the version in `Package.swift`, the newest heading in `CHANGELOG.md`, and the git tag are three statements of one fact, and they disagree constantly.

The obvious place to enforce that is at commit time. It's the wrong place. Mid-release, those three legitimately disagree — you bump the manifest, you write the changelog, you tag, and between any two of those steps a correct working tree fails a strict equality check. A gate that fails during normal work gets bypassed during normal work, and a bypass habit is not something you can scope to the cases where it was justified.

So the invariant is graded by *when it's checked*:

- **Parity** — manifest against changelog — is a **note** during ordinary work and an **error at the release boundary**. The disagreement is expected in the middle and unacceptable at the end.
- **Identity** — a tag pointing at a commit whose manifest says something else — is an error only for the tag actually being published. Old tags disagreeing with the current manifest is what history looks like.
- **Boundary** — the check that decides which of the above applies — reads the pushed-ref list.

That last piece is the part worth stealing. The natural design is a new `pre-push` hook argument, which means asking every repository using the tool to edit its hooks — and a rollout that depends on dozens of repositories changing a file is a rollout that half-happens, leaving the protection weakest where it's least maintained.

Git already hands `pre-push` the ref list **on stdin**: `<local ref> <local sha> <remote ref> <remote sha>`, one line per ref. Nothing needed teaching. The existing hook already had the information; it was discarding it. Reading stdin — guarded by a zero-timeout `poll` so an interactive run doesn't block waiting for input that will never come — makes every existing hook release-boundary-aware without a single repository editing anything.

## The release preflight

The boundary checks answer "is this tag consistent?" A separate subcommand answers the wider question — is this *release* ready:

```bash
quality-gate release 3.0.0
```

Version parity across manifest and changelog, an `## [Unreleased]` section that is actually empty, the planning document reconciled against shipped code, the newest release's date, and `Last Updated` current. Release-scoped, so it never runs during ordinary work and never has to be weakened to avoid doing so.

## Try it

```bash
quality-gate --check release-readiness
quality-gate release 3.0.0
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
