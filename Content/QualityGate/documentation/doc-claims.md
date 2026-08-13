---
layout: BlogPostLayout
series: quality-gate
title: "DocClaimsAuditor: When the Documentation Becomes a Test"
tags: quality-gate, documentation, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-08-13 09:04
lastModified: 2026-08-13
published: true
---

# DocClaimsAuditor

**"This returns 0.847" is a claim. Rung 3 checks it.**

---

An article that compiles and runs can still be wrong about what it does. It says the Sharpe ratio comes out at `1.24`; the program prints `0.98`. Both statements sit on the same page, both look equally authoritative, and nothing in the toolchain has an opinion.

`doc-claims` runs the article's program, captures what it prints, and compares that against the figures the prose publishes. This is the rung where documentation stops resembling the truth and starts being a test.

## It only checks the article against itself

The scope is deliberately narrow, and the narrowness is the whole design.

A figure is checkable when the article contains the program that produces it. Not "a number that appears in the text" — a number the *article's own code* computes. That excludes benchmark results from a machine you no longer own, figures quoted from a paper, and round numbers used rhetorically. It includes exactly the class of claim that goes quietly wrong when an algorithm changes: the worked example.

Anything the article can't compute isn't a claim this checker can adjudicate, and it says nothing about it rather than guessing.

## The trap that makes this permanently opt-in

There is an obvious way to make a failing figure go green, and it is the wrong one.

The program prints `0.98`, the prose says `1.24`. Editing the prose to say `0.98` clears the finding in about four seconds. If the number changed because someone introduced a regression, that edit has just destroyed the only artifact in the repository that objected to it — and left behind a document that is now *demonstrably* consistent with the bug.

That's laundering, not repair. So this rung fails loudly and gets fixed by **deciding which value is right**, which is a judgment no tool should make and no `--fix` flag will ever offer. `doc-claims` has no autofix, and that's not an unimplemented feature.

It's also why the checker is opt-in and will stay that way. Rung 3 asks a project for something rungs 1 and 2 don't: that its documented figures are maintained as results rather than as prose. A catalog that hasn't made that commitment shouldn't be told it's failing a standard it never adopted — but if it *has*, this is the checker that keeps it honest.

## What the failure output has to do

A mismatch is only useful if you can act on it, which means the finding carries three things: the figure the prose published, the value the program produced, and where in the article each one lives. "Documentation is out of date" is not actionable. "Line 34 says 1.24; the program on line 51 prints 0.98" is a five-minute investigation with a defined end.

## Try it

```bash
quality-gate --check doc-claims
```

Run rung 2 first. A program that traps can't tell you what it would have printed, and a doc-claims failure on an article that doesn't run is just `doc-run`'s finding wearing a different hat.

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
