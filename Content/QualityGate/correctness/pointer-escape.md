---
layout: BlogPostLayout
series: quality-gate
title: "PointerEscapeAuditor: The Auditor I Wish I'd Had a Year Ago"
tags: quality-gate, correctness, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:03
lastModified: 2026-08-13
published: true
---

# PointerEscapeAuditor

**Catching `Unsafe*Pointer` values that escape the `withUnsafe*` closure that owns their memory.**

---

This is the auditor I wish I'd had a year ago.

## The motivating incident

```swift
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

The result was intermittent memory corruption that manifested as test failures *only under load*. It took days to find. `PointerEscapeAuditor` catches this exact pattern — and eight other escape shapes — at quality-gate time:

```
error: pointer escapes by being stored in a property
       FFTBackend.swift:14:13
       rule: pointer-escape.stored-in-property
       fix:  Store the pointee value or a Sendable copy instead.
```

## How it's detected

The auditor walks every `withUnsafe*` call site, tracks the closure parameter (`$0`, named, or `_`), and checks for nine kinds of escape: direct and wrapped returns (through struct inits, tuples, arrays, `Any` boxes, ternaries), assignment to outer/global/static/instance storage, append/insert into outer collections, inout-style sinks, closure capture that outlives the block, `Unmanaged` retain leaks, and `OpaquePointer` round-trips.

It's precise about value vs. pointer access: `ptr.pointee` is a value (not flagged), `ptr.baseAddress` is a pointer (flagged), `ptr + 1` is a pointer (flagged), `ptr.reduce(0, +)` is a value (not flagged). Nested with-blocks push their bound names onto a stack so an inner closure can flag escape of the *outer* pointer.

For genuinely safe escape destinations — specific vDSP entry points, certain `CFData` accessors — you opt in per project rather than shipping a global list that drifts:

```yaml
pointerEscape:
  allowedEscapeFunctions:
    - vDSP_fft_zip
    - vDSP_fft_zop
```

**9 rule IDs. All tests passing.**

## Why the architecture made this easy

Each of these auditors slotted into `quality-gate-swift` in a few hundred lines, with no changes to the existing checkers and no changes to the CLI runtime. The whole contract is one protocol:

```swift
public protocol QualityChecker: Sendable {
    var id: String { get }
    var name: String { get }
    func check(configuration: Configuration) async throws -> CheckResult
}
```

Implement it, register the module in one line, and the reporters, config loader, parallel runner, and exit-code wiring all work automatically. When the cost of adding a check is one new file and one line, you add the check — and then the bugs don't ship.

## Try it

```bash
quality-gate --check pointer-escape
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
