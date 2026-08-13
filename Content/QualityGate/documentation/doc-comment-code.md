---
layout: BlogPostLayout
series: quality-gate
title: "DocCommentCode: The Examples in /// Must Compile Too"
tags: quality-gate, documentation, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-08-13 09:02
lastModified: 2026-08-13
published: true
---

# DocCommentCode

**`doc-code` compiles the catalog. This compiles the doc comments the catalog was copied from — and the distinction is not theoretical.**

---

A repair pass across one package fixed 26 DocC articles and found real API drift doing it: a `Configuration.default` that no longer existed, a parameter that had been retyped, `{ … }` placeholders that never parsed.

It touched **no doc comment**.

The article got fixed. The `///` it was copied from still carried the broken version, and Quick Help still served it. `doc-code` repaired the copy and could not see the original.

## The unit is one fence

`doc-code` treats an article as one program, because that's what a reader pastes. Nobody pastes a whole source file out of Quick Help — they copy **one panel**. So here the compilation unit is a single fence, and that difference drives everything else.

It's not a detail. One auditor in this suite carries a single `///` run holding two unrelated fences: a usage example, and a fragment of the *reader's* SwiftUI code. Concatenating them would import `doc-code`'s collision rule into a place where its premise is false.

## The preamble is `Foundation` plus the owning module, and nothing widens it

Not the dependency closure. Not a configured extras list. The function that builds it takes the configuration and deliberately ignores it, with a comment saying so, so that the next person looking for the knob finds the reasoning instead of adding one.

Here's why. Measured on this package: **43 doc fences across 26 files, of which 16 failed.** Ten of the sixteen were one `## Usage` template copied into ten auditors — and the obvious repair fails too, because the block never says `import QualityGateCore`. A reader who copies it out of Quick Help cannot build it.

Injecting that import would have turned ten failures into ten passes while the examples stayed exactly as uncopyable. Whatever a fence needs in order to compile is precisely what a reader has to type.

## What it looks like at scale

Run against a 100k-line package, it reported 1,515 errors. Triaged, that was **560 distinct doc comments** — roughly 2.7 errors per decision — and it split cleanly:

- **62% referenced something the fence doesn't define.** Not 387 separate mistakes: ten identifiers accounted for most of them. `balanceSheet` 62 times, `incomeStatement` 43, `q1` 37. That's a house style — examples written assuming a fixture exists, the way you'd write a snippet in prose.
- **37% genuinely don't compile.** Generic inference, missing `try`, wrong argument labels. These are the ones users copy and can't build.
- **A further finding:** 40% of the compile errors were *downstream* of the undefined references. `Account<T>` can't infer `T` when the values passed to it are undefined. Define the fixture and the generic error evaporates.

The headline overstated the work by about 3×. That's worth knowing before you look at a four-figure number and conclude the documentation is beyond saving.

## The decision it puts in front of you

For each fence: **recipe or shape?**

A recipe should stand alone. Making it stand alone is genuine improvement, and it's the only repair that survives the copy-out-of-Quick-Help test.

A shape — illustrating an API's form rather than a runnable sequence — is what `<!-- docs:illustrative -->` is for, and marking it is honest rather than a dodge. The hint says the marker is a human edit and is never applied by a tool, which is the line that stops a 387-site sweep from becoming 387 silent exemptions.

## Try it

```bash
quality-gate --check doc-comment-code
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
