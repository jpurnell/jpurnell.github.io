---
layout: BlogPostLayout
series: quality-gate
title: "DocCodeAuditor: The Examples in Your Docs Must Compile"
tags: quality-gate, documentation, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-08-13 09:01
lastModified: 2026-08-13
published: true
---

# DocCodeAuditor

**Nobody compiles documentation. That exemption is why it rots faster than anything else you ship.**

---

Someone reads your DocC article, sees a code block, and pastes it into a playground. That's the entire contract, and until now nothing checked whether it holds.

`doc-code` checks it. Every fenced Swift block in an article is concatenated in document order, typechecked against the built module, and the failures come back as gate findings.

Pointed at one 73-article catalog for the first time, it found **2,092 errors across 67 of them** — including three constructors documented with argument labels the API never had, and a type documented as `public` that was internal.

## The article is one program

The first real decision: is an article one program or a bag of fragments?

One program. That's what a reader does when they paste, and the choice has consequences that run through the whole design. A later block referring to a binding from an earlier one is **correct** and must keep working. Two independent examples that both open with `let data = …` are **a defect in the article**, and the repair is a rename — `salesData`, `returnsData` — not an annotation.

That rule turns a class of vague "this example is confusing" into something a compiler can decide.

## What it refuses to do

**It won't guess your language mode.** It reads `Package.swift` with SwiftSyntax: tools-version default, `.swiftLanguageMode`, package-level `swiftLanguageModes`, plus `enableUpcomingFeature`, `unsafeFlags`, `strictMemorySafety` and the rest, translated to flags. Checking under weaker rules than your build is how an actor method returning a non-`Sendable` type passes for months; checking under stronger ones hands an older package errors its own build never raises. When it genuinely cannot tell, it uses the compiler default and says so rather than assuming the strictest.

**It won't fail on constructs it can't reach.** `swift-testing` blocks typecheck, because the `@Test` and `#expect` macros need the host plugin and a gate that can't compile a legitimate construct gets worked around — and the workaround looks exactly like compliance. Same reasoning added `ManifestAPI` to the include path so documented `Package.swift` excerpts resolve, and later added the package's own macro plugins after a 100k-line codebase produced 25 errors from that one gap.

**It won't silently exempt anything.** The one opt-out is `<!-- docs:illustrative -->`, it's counted and reported per article, and no tool applies it for you.

## Coverage is reported, not assumed

Fences *found* is printed separately from fences *checked*.

That distinction exists because an early prototype matched fences at column zero, silently skipped every block nested inside a list item, and six articles passed with real API drift sitting inside them. A checker that examined nothing and a checker that found nothing must not print the same thing.

## Validated against a real catalog

BusinessMath, 73 articles: **1,305 fences found, 1,219 checked, 86 exempt, 0 errors** — after the repair pass. Getting there is the point; the number that mattered was the 2,092 it found on the way.

## Try it

```bash
quality-gate --check doc-code
```

Opt-in, deliberately — not because it's slow, but because it holds an article to being one compilable program, and that's a convention a codebase adopts rather than inherits.

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
