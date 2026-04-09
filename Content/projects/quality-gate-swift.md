---
layout: BlogPostLayout
tags: project, swift, apple, development, tooling
image:
imageDescription:
title: Three New Auditors for quality-gate-swift, or Why Modular Linters Win
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-04-08 18:00
lastModified: 2026-04-08
published: true
---

# Three New Auditors for quality-gate-swift

**Modular linting that catches recursion bugs, Swift 6 concurrency traps, and unsafe pointer escapes — built on the same QualityChecker protocol as everything else.**

---

A while back I wrote about the [development-guidelines repo](/projects/development-guidelines) — the system I use to keep AI assistants productive across sessions. One of its load-bearing pieces is `quality-gate`: a single command that runs every quality check before a commit can land. Build, test, safety audit, doc lint, doc coverage, dead-code detection. If any of them fails, the commit doesn't happen.

This week I added three new checkers, and I want to talk about why the modularity of the quality gate made it almost trivial to do — and what each new auditor catches.

## The Trigger

I ran a usage analysis on my recent Claude Code sessions. One bullet jumped out:

> **Buggy first-pass code requiring rework.** Generated code frequently has subtle bugs (recursion, memory, concurrency) that you catch later.
>
> - Convenience inits had infinite recursion flagged by SourceKit
> - Accelerate FFT backend had pointer-escape memory corruption blocking tests

Three distinct bug classes, three real incidents. Each one cost a session — sometimes more — to track down. SourceKit catches some of these eventually, the Swift 6 strict-concurrency build catches others, and Accelerate's pointer issues only surfaced under load. None of them were caught at quality-gate time, which is exactly when I want them caught.

So I built three new auditors.

## The Tools

### 1. RecursionAuditor

Catches infinite-recursion bugs that compile cleanly.

```swift
// ❌ Convenience init forwarding to itself with identical labels
class Foo {
    init(name: String, age: Int) { self.name = name; self.age = age }
    convenience init(name: String) {
        self.init(name: name)   // ← infinite recursion
    }
}

// ❌ Computed property referencing itself
struct Foo {
    var value: Int { value }
}

// ❌ Function with no base case
func loop(_ n: Int) -> Int {
    return loop(n)
}

// ❌ Mutual recursion across files (caught via project-wide call graph)
// A.swift
func a() { b() }
// B.swift
func b() { a() }
```

The mutual cycle detector builds a project-wide call graph keyed by qualified name (`Type.method(label:)`) and runs Tarjan's strongly-connected-components algorithm. A cycle is reported only if **none** of its participants have a guard-driven base case. Both intra-file and cross-file cycles are detected.

The base case heuristic was originally "any guard statement in the body." That worked for the test fixtures. But the first time I ran the auditor against `quality-gate-swift` itself, it flagged its own SwiftSyntax visitor — a legitimate recursive-descent walker where the base case is "the AST is finite," not a syntactic guard. So I tightened the heuristic to also recognize bare `return` statements and returns of literal/identifier expressions as evidence of a non-recursing path. Real dogfooding caught a real false positive before it shipped.

**8 rule IDs.** All 35 tests passing.

### 2. ConcurrencyAuditor

Catches Swift 6 strict-concurrency bugs that compile cleanly but trap at runtime.

```swift
// ❌ @unchecked Sendable with no justification
final class Cache: @unchecked Sendable {
    var entries: [String: Int] = [:]
}

// ✅ With justification — accepted
// Justification: synchronized via NSLock; see Cache.swift:42
final class Cache: @unchecked Sendable {
    var entries: [String: Int] = [:]
}

// ❌ Sendable class with mutable state (private doesn't change the rules)
final class Foo: Sendable {
    private var x = 0
}

// ❌ Task in actor capturing self without an explicit hop
actor A {
    var x = 0
    func f() {
        Task {
            self.x += 1   // races — runs off-actor
        }
    }
}

// ❌ @MainActor deinit touches stored state — runtime trap in Swift 6
@MainActor
class A {
    var x = 0
    deinit { print(x) }
}

// ❌ @preconcurrency import of a first-party module
@preconcurrency import MyAppCore   // your own code; fix it instead
```

The auditor maintains an explicit isolation context stack: `.none`, `.mainActor`, `.actor(name:)`. The rules consult the top of the stack to decide whether to fire. Type declarations (`class`, `struct`, `enum`) reset isolation to `.none` unless they have an explicit `@MainActor` attribute, so a class lexically nested inside an actor does **not** inherit actor isolation. Functions and deinits inherit from the parent unless they override.

The escape hatch for the "unsafe" rules is a justification comment immediately above the declaration. Adjacency is strict: a blank line, a block comment, or a comment below the decl all fail to suppress. The mechanism is searchable, auditable, and CI-friendly.

For the `@preconcurrency import` rule, the CLI parses `Package.swift` once at startup and extracts every `.target(name:)` literal. First-party modules get flagged; third-party modules pass through. You can also allowlist specific first-party modules during a transition.

**8 rule IDs.** All 65 tests passing.

### 3. PointerEscapeAuditor

Catches `Unsafe*Pointer` values that escape the `withUnsafe*` closure scope that owns their underlying memory.

This is the auditor I wish I'd had a year ago.

```swift
// ❌ The motivating incident, paraphrased
final class FFTBackend {
    var workspace: UnsafeMutablePointer<DSPSplitComplex>?

    func setup(input: [Float]) {
        input.withUnsafeBufferPointer { buf in
            self.workspace = buf.baseAddress.map { /* … */ }
            //   ↑ pointer escapes the with-block; the memory is gone
            //     after this closure returns. Compiles cleanly.
        }
    }
}
```

The result of the original incident was intermittent memory corruption that manifested as test failures only under load. PointerEscapeAuditor catches this exact pattern — and eight other escape shapes — at quality-gate time:

```
error: pointer escapes by being stored in a property
       FFTBackend.swift:14:13
       rule: pointer-escape.stored-in-property
       fix:  Store the pointee value or a Sendable copy instead.
```

The auditor walks every `withUnsafe*` call site, tracks the closure parameter (`$0`, named, or `_`), and checks for nine kinds of escape. It handles:

- **Direct return** of the pointer, whether explicit or implicit-return
- **Wrapped return** through struct initializers, tuples, array literals, `Any` boxes, or ternary branches
- **Assignment** to outer variables, globals, static properties, instance properties
- **Append/insert** into outer collections
- **Inout-style** sinks where the pointer co-occurs with `&outerVar` in the same call
- **Closure capture** stored in an outer variable (error tier) or passed to `Task { … }` / `DispatchQueue.async { … }` (warning tier)
- **Unmanaged retain leaks** where `Unmanaged.passRetained` has no matching `.release()`
- **OpaquePointer round-trips** outside the with-block

It also handles aliasing (`let alias = ptr; return alias`) and shadowing (`let ptr = 5` rebinds the name). Nested with-blocks push their bound names onto a stack so the inner closure can flag escape of the *outer* pointer.

The pointer-identity tracker is heuristic but precise about value vs. pointer access: `ptr.pointee` is a value (not flagged), `ptr.baseAddress` is a pointer (flagged), `ptr + 1` is a pointer (flagged), `ptr.reduce(0, +)` is a value (not flagged).

For genuinely safe escape destinations — specific vDSP entry points, certain `CFData` accessors — there's a user-supplied allowlist. Rather than ship a global list that drifts, you opt in per project:

```yaml
pointerEscape:
  allowedEscapeFunctions:
    - vDSP_fft_zip
    - vDSP_fft_zop
```

**9 rule IDs.** All 55 tests passing.

## Why the Modularity Mattered

Here's the thing I really want to highlight: each of these auditors slotted into `quality-gate-swift` in a few hundred lines of code, with no changes to the existing checkers and no changes to the CLI runtime.

The whole architecture is:

```swift
public protocol QualityChecker: Sendable {
    var id: String { get }
    var name: String { get }
    func check(configuration: Configuration) async throws -> CheckResult
}
```

That's it. Implement `QualityChecker`, conform to `Sendable`, return a `CheckResult` with diagnostics. Register the new module in the CLI's `allCheckers` list. Done. The reporters (terminal, JSON, SARIF), the configuration loader, the parallel runner, the exit-code wiring — all of it works automatically.

Adding the three new auditors followed the same shape as the existing six:

1. **Design proposal** → architecture, rule list, test strategy, open questions. Reviewed before any code.
2. **RED** → write the failing test suite. One file per rule. Red and green fixtures paired.
3. **GREEN** → implement until tests pass. Iterate against failures.
4. **DOCUMENT** → DocC catalog with rule table and narrative guide.
5. **REGISTER** → wire into the CLI, add YAML config, parse Package.swift if needed.
6. **DOGFOOD** → run against the package itself, fix any false positives the test suite missed.

Each of those steps was a separate commit. The whole sequence — three full auditors from design to shipped — landed on `main` over two days. **The package now has 375 tests across 47 suites, all passing.**

The reason this scales is the protocol. Every checker is a black box from the CLI's perspective. If I want to add a tenth auditor next month — say, one that catches `try? someThrowingFunction()` followed by force-unwrap, or one that detects `Result.success(())` patterns that should be `Void`-returning — I don't have to touch any existing file. I write a new module, conform to `QualityChecker`, register it in one line, and ship.

## What I Found Dogfooding

The first run of RecursionAuditor against `quality-gate-swift` itself flagged nine warnings, all in `PointerEscapeAnalyzer.swift`. They were in functions like `processItem`, `walkBodyItems`, `analyzeWithBlock` — the recursive descent visitor. They genuinely do form a mutual cycle. None of them have a guard statement.

But they're not infinite recursion. They terminate because the AST is finite.

This is the classic visitor-pattern false positive. The naive heuristic flagged it. I tightened the heuristic to also accept bare `return` statements and returns of non-call expressions as evidence of a non-recursing path. The visitor functions all have early returns after each branch matches. That's a base case, structurally — the function returns without recursing if the input doesn't match a recursive type.

The fix took fifteen lines. Re-running the auditor: zero diagnostics. Fixing the false positive in the auditor itself, against my own codebase, before shipping it to other projects, is exactly what dogfooding is for.

## Configuration

`.quality-gate.yml` now supports nested config sections for the new auditors:

```yaml
enabledCheckers:
  - build
  - test
  - safety
  - doc-lint
  - doc-coverage
  - unreachable
  - recursion
  - concurrency
  - pointer-escape

concurrency:
  justificationKeyword: "Justification:"
  allowPreconcurrencyImports:
    - SomeLegacyDependency

pointerEscape:
  allowedEscapeFunctions:
    - vDSP_fft_zip
```

Defaults are sensible for every field. If you don't have a config file at all, every checker runs with reasonable defaults. If you have an existing config, the new fields are silently filled in.

## Try It

Clone [quality-gate-swift](https://github.com/jpurnell/quality-gate-swift), build it, point it at any Swift package:

```bash
git clone https://github.com/jpurnell/quality-gate-swift
cd quality-gate-swift
swift build -c release
.build/release/quality-gate --check recursion concurrency pointer-escape
```

Or run the whole gate, which is what I do before every commit:

```bash
quality-gate
```

Each new auditor has a DocC catalog explaining every rule with red/green examples, the suppression mechanism, and the limitations. ConcurrencyAuditor and PointerEscapeAuditor each have full narrative guides walking through the bug each rule catches and the recommended fix.

## The Lesson

Modular linting wins because the cost of adding a new check should be proportional to the complexity of the check, not the complexity of integrating it. When the integration cost is high, you don't add checks. You write down the rule in a style guide, you tell yourself you'll remember, and the bugs ship anyway.

When the integration cost is one new file and one line in a CLI registration, you add the check. And then the bugs don't ship.

That's the real argument for protocol-oriented quality tooling: it lowers the friction of catching the next class of bug to the point where you actually do it.

---

**Source**: [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
