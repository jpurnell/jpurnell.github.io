---
layout: BlogPostLayout
series: quality-gate
title: "DocGeneratedAuditor: Prose That Was Never Written"
tags: quality-gate, documentation, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-08-13 09:05
lastModified: 2026-08-13
published: true
---

# DocGeneratedAuditor

**Some of your documentation isn't written. It's transcribed — and transcription decays.**

---

The ladder — compiles, runs, its numbers are real — handles code embedded in prose. It says nothing about prose *derived* from code: the module table, the checker reference, the error registry, the changelog's link definitions.

Nobody composes those. Somebody copies them, once, and then the tree moves.

The fix is to stop transcribing. Wrap the derived content in delimiters, name the generator that owns it, and let the gate regenerate it in memory and compare:

```markdown
<!-- generated:module-structure -->
- `QualityGateCore` — Shared protocol, models, reporters
…
<!-- /generated:module-structure -->
```

Everything between the delimiters belongs to the generator. Everything outside belongs to the author. Drift stops being "this document feels stale" and becomes "line 47 says something the tree does not."

## What it found on its first run

Turned on against the project that built it: **65 findings across 10 regions.**

Twenty-nine modules absent from the architecture table. Seventeen absent from the status roster. An error registry that had never listed a case which shipped with an entire feature. And four changelog link definitions that had never been written *at all* — meaning every one of those version headings had been rendering on GitHub as literal text with brackets around it, for four releases, on the page most likely to be someone's first look at the project.

None of that was a typo. Every one was somebody adding a module and not editing a table, which is the only way this failure ever happens.

## Three problems that ate the implementation

**A generator must be trustworthy enough to overrule a human.** If it regenerates a table and deletes a row, it had better be right. One naive version would have deleted the row documenting a feature that had *moved* — converting a stale row into a missing one and calling that green. Generation doesn't eliminate editorial judgment. It relocates it somewhere less visible, which is worse if you don't go looking.

**Membership and state are different questions.** A checklist of modules with tick-boxes has two columns and exactly one is derivable. *Which modules deserve a line* is a set. *Whether the work is done* is a judgment, and deriving it from "a directory exists" would produce sixty-three green boxes meaning only that sixty-three folders are present. So the roster generator owns membership and never touches a tick-box: it adds lines, removes lines, and rewrites none. A line containing `~~strikethrough~~` is kept regardless — someone recorded a decision there, and a tool that deletes recorded decisions is not a documentation tool.

**Order is content.** A region holding exactly the right lines in the wrong order isn't a pass. The naive comparison — sort both sides, diff as multisets — reports "no differences" and moves on, which is how a hand-reordered table silently stops matching its generator. There's a dedicated backstop for it: when the sets match and the sequences don't, the finding says so in those words rather than printing an empty diff.

## The one that got measured and killed

A roadmap is the obvious next candidate. It's a checklist, it names artifacts, it goes stale in exactly the way the architecture table did.

Measured before it was built, a generator deriving roadmap membership from the package would have deleted **19 of 38 items** — every entry describing work not yet done. Which is what a roadmap *is*. A roadmap is a roster of intentions, and an intention isn't derivable from a tree, because the tree is what exists and the roadmap is the list of what doesn't.

That proposal is withdrawn in the design document, with the measurement attached, so the next person to have the idea meets the number instead of the conclusion.

## It reports its coverage, and it always has

Every run prints `regions: 10 found · 10 regenerated · 0 unknown` — pass or fail, including when the answer is zero.

That line is the reason this checker has never had the failure mode its two siblings both shipped with. One examined a single module out of 116 and printed a pass. Another would have found zero articles in a package laid out with `Source/` instead of `Sources/` and printed the same pass. Neither lied about what it found; both were silent about what they had looked at, and silence reads as success.

> **A checker that examined nothing must not print what a checker that found nothing prints.**

## Try it

```bash
quality-gate --check doc-generated
quality-gate --check doc-generated --fix --dry-run
```

`--fix` rewrites the body of a region and nothing else — same file, same line endings, author's prose untouched. Run it with `--dry-run` first, because the point of a generator you trust is that you checked once why you trust it.

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
