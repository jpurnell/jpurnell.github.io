---
layout: BlogPostLayout
series: quality-gate
title: "Documentation That Cannot Lie"
tags: quality-gate, gate, documentation, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-09-16 09:00
lastModified: 2026-08-12
published: true
---

# Documentation That Cannot Lie

**Every linter checks whether your documentation exists. Almost none check whether it's true.**

---

Ask a static analysis tool about your documentation and it will tell you three things: whether the public API has doc comments, whether the markup parses, and whether the links resolve. All useful. All silent on the only question a reader actually has.

*Does it work?*

The code sample in your README, the one someone will paste into a playground in about four minutes — does it compile? Does it run? The output it claims to produce, does the program actually produce that? The table of modules in your architecture document, the one that says thirty-four when the package has sixty-three — what would have caught it?

Nothing. Documentation is the one artifact in a modern codebase that nobody compiles, and that exemption is why it rots faster than anything else you ship.

## The ladder

There's a natural progression here, and each rung is a strictly stronger claim than the one below it.

**Rung 0 — it exists.** Every doc-coverage tool. Necessary, and the easiest to satisfy without saying anything: a comment reading `/// The name.` above `var name: String` passes.

**Rung 1 — it compiles.** Take every fenced Swift block in an article, concatenate them in document order, and typecheck the result against the built module. This is a bigger step than it sounds, because it forces a decision: is an article *one program* or a collection of fragments? One program is the right answer — it's what a reader does when they paste — and it means a later block referring to an earlier binding is *correct*, while two independent examples that both open with `let data = …` are a defect in the article whose repair is a rename.

Pointed at one 73-article catalog, this found **2,092 errors across 67 of them** — including three constructors documented with argument labels the API never had, and a type documented as public that was internal.

**Rung 2 — it runs.** Compiling proves the types line up. It doesn't prove the example doesn't trap on the second line. Running the article top to bottom catches the sample that typechecks beautifully and force-unwraps a nil.

**Rung 3 — its numbers are real.** An article that says *"this returns 0.847"* is making a claim that can be checked: run the program, capture what it prints, compare. This is the rung where documentation stops being prose that resembles the truth and starts being a test.

There's a trap here worth naming, because it's the reason this rung is opt-in and always will be: the obvious "fix" for a failing number is to rewrite the documentation to match the program. That's not a fix, it's laundering. If the number changed because of a regression, updating the doc erases the only artifact that objected. Rung 3 has to fail loudly and be repaired by *deciding which value is right* — a judgment no tool should make.

## The fourth thing, which isn't a rung

The ladder handles code in prose. It says nothing about prose *derived* from code — the module table, the checker reference, the error registry, the changelog's link definitions. That content isn't written so much as transcribed, and transcription decays.

The fix is to stop transcribing. Wrap the derived content in delimiters, name the thing that generates it, and let the gate regenerate it in memory and compare:

```markdown
<!-- generated:module-structure -->
- `QualityGateCore` — Shared protocol, models, reporters
…
<!-- /generated:module-structure -->
```

Everything between the delimiters belongs to the generator. Everything outside belongs to the author. Drift becomes a compile-time-shaped failure: not "this document feels stale" but "line 47 says something the tree does not."

Turned on for the first time against the project that built it, this reported **65 findings**: twenty-nine modules absent from the architecture table, seventeen from the status roster, an error registry that had never listed a case which shipped with an entire feature, and four changelog link definitions that had never been written *at all* — every version heading rendering on GitHub as literal text with brackets around it, for four releases.

## Why this is harder than it looks

Three problems eat most of the implementation, and they're the interesting part.

**A generator has to be trustworthy enough to overrule a human.** If the tool regenerates a table and deletes a row, it had better be right. One naive version would have deleted the row documenting a feature that had *moved* — turning a stale row into a missing one and calling that green. Generation doesn't eliminate editorial judgment; it relocates it somewhere less visible.

**Membership and state are different questions.** A checklist of modules with tick-boxes has two columns and only one is derivable. *Which modules deserve a line* is a set, exactly. *Whether the work is done* is a judgment no tool can make, and deriving it from "a directory exists" would produce sixty-three green boxes meaning only that sixty-three folders are present. So the generator owns membership and never touches a tick-box — it adds and removes lines and rewrites none.

**Some documents look derivable and aren't.** A roadmap is the obvious next candidate: it's a checklist, it names artifacts, it goes stale. Measured, a generator deriving its membership from the package would have deleted **19 of 38 items** — every entry describing work not yet done, which is what a roadmap *is*. A roadmap is a roster of intentions, and an intention isn't derivable from a tree, because the tree is what exists and the roadmap is the list of what doesn't. That one got measured before it got built, and the measurement killed it.

## The property underneath all of it

Every failure above shares a shape, and it's worth stating on its own:

> **A checker that examined nothing must not print what a checker that found nothing prints.**

The generated-content checker reported its coverage from day one — regions found, regions regenerated, generators unused — on every run, pass or fail, including when the answer was zero. It has never had this class of failure.

Its siblings, written without that discipline, both did. One examined a single module out of 116 and printed a pass. Another would have discovered zero articles in a package laid out with `Source/` instead of `Sources/` and printed the same pass. Neither was lying about what it found. Both were silent about what they'd looked at, and silence reads as success.

If you build one thing from this post, build that. Make every checker state its coverage, and make zero coverage an error rather than a pass. It costs a line of output and it closes a category of bug you would otherwise meet one instance at a time, for years.

## Try it

```bash
quality-gate --check doc-code           # rung 1: the examples compile
quality-gate --check doc-comment-code   # rung 1, applied to /// comments
quality-gate --check doc-run            # rung 2: they run
quality-gate --check doc-claims         # rung 3: their numbers are real
quality-gate --check doc-generated      # derived prose matches the tree
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
