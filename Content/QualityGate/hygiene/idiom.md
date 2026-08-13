---
layout: BlogPostLayout
series: quality-gate
title: "IdiomAuditor: SwiftLint's Best Rules, Native and AST-Based"
tags: quality-gate, hygiene, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:33
lastModified: 2026-08-22
published: true
---

# IdiomAuditor

**The head of SwiftLint's usage, rebuilt as native AST rules — so you can drop a tool instead of adding one.**

---

The goal here was substitutional, not additive: adopting quality-gate should mean *dropping* a tool, not running one more. `IdiomAuditor` reimplements the most-used SwiftLint rules — about twenty of them — as native SwiftSyntax checks, so the style layer lives in the same gate as the correctness layer.

## The kinds of rule

Empty-count (`x.count == 0` → `x.isEmpty`), the redundant-syntax family, syntactic sugar (`Array<Int>` → `[Int]`), shorthand operators, identifier and type naming, TODO-ticket policy, file/function/line length, the whitespace family, unused closure parameters, implicit getters, redundant `String` enum values, legacy `random`, `contains`-over-`first`.

```swift
// ❌ if array.count == 0        ✅ if array.isEmpty
// ❌ let x: Array<Int> = []      ✅ let x: [Int] = []
// ❌ x = x + 1                   ✅ x += 1
```

## Advisory, with safe autofix

Idiom rules are **advisory** — notes by default, because the gate blocks on correctness, not whitespace (you can escalate them in config if you want). Many carry a safe-subset `suggestedFix`, verified by round-trip tests: apply the fix, reparse, confirm the rule now stays silent. And there's a migration path — `quality-gate import-swiftlint` reads your `.swiftlint.yml`, maps enabled rules to their native equivalents (thresholds carried over), translates `custom_rules` verbatim, and prints an honest report of what it *couldn't* map. Even the migration tells the truth about its gaps.

`// idiom:exempt` suppresses a site — recorded as an override, never silent.

## Try it

```bash
quality-gate --check idiom
quality-gate import-swiftlint      # migrate an existing .swiftlint.yml
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
