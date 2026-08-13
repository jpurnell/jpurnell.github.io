---
layout: BlogPostLayout
series: quality-gate
title: "RecursionAuditor: Infinite Loops That Compile Cleanly"
tags: quality-gate, correctness, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:01
lastModified: 2026-08-02
published: true
---

# RecursionAuditor

**Catching infinite-recursion bugs that the compiler is perfectly happy with.**

---

I ran a usage analysis on my recent coding sessions. One bullet jumped out: *convenience inits with infinite recursion, flagged only later by SourceKit.* It had cost me a session to track down. SourceKit catches some of these eventually; the Swift build catches others; none of them were caught at quality-gate time, which is exactly when I want them caught.

So `RecursionAuditor` catches the ones that compile cleanly.

## What it catches

```swift
// ❌ Convenience init forwarding to itself with identical labels
class Foo {
    init(name: String, age: Int) { self.name = name; self.age = age }
    convenience init(name: String) {
        self.init(name: name)   // ← infinite recursion
    }
}

// ❌ Computed property referencing itself
struct Foo { var value: Int { value } }

// ❌ Function with no base case
func loop(_ n: Int) -> Int { return loop(n) }

// ❌ Mutual recursion across files (caught via project-wide call graph)
// A.swift
func a() { b() }
// B.swift
func b() { a() }
```

## How it's detected

The mutual-cycle detector builds a project-wide call graph keyed by qualified name (`Type.method(label:)`) and runs Tarjan's strongly-connected-components algorithm. A cycle is reported only if **none** of its participants have a guard-driven base case. Both intra-file and cross-file cycles are detected — regex could never do this, because it requires knowing what calls what across the whole package.

## The dogfooding story

The base-case heuristic was originally "any guard statement in the body." That worked for the test fixtures. But the first time I ran the auditor against `quality-gate-swift` itself, it flagged its own SwiftSyntax visitor — a legitimate recursive-descent walker whose base case is "the AST is finite," not a syntactic guard.

So I tightened the heuristic to also recognize bare `return` statements and returns of literal/identifier expressions as evidence of a non-recursing path. The fix took fifteen lines. Re-running: zero diagnostics. Fixing a false positive in the auditor itself, against my own codebase, before shipping it — that's exactly what dogfooding is for.

**8 rule IDs. All tests passing.**

## Try it

```bash
quality-gate --check recursion
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
