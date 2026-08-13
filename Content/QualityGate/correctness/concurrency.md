---
layout: BlogPostLayout
series: quality-gate
title: "ConcurrencyAuditor: Swift 6 Traps That Compile but Race"
tags: quality-gate, correctness, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:02
lastModified: 2026-08-13
published: true
---

# ConcurrencyAuditor

**Catching Swift 6 strict-concurrency bugs that compile cleanly and trap — or race — at runtime.**

---

## What it catches

```swift
// ❌ @unchecked Sendable with no justification
final class Cache: @unchecked Sendable { var entries: [String: Int] = [:] }

// ✅ With justification — accepted
// Justification: synchronized via NSLock; see Cache.swift:42
final class Cache: @unchecked Sendable { var entries: [String: Int] = [:] }

// ❌ Sendable class with mutable state (private doesn't change the rules)
final class Foo: Sendable { private var x = 0 }

// ❌ Task in an actor capturing self with no isolation hop
actor A {
    var x = 0
    func f() { Task { self.x += 1 } }   // races — runs off-actor
}

// ❌ @MainActor deinit touches stored state — a runtime trap in Swift 6
@MainActor class A { var x = 0; deinit { print(x) } }
```

The auditor maintains an explicit isolation-context stack (`.none`, `.mainActor`, `.actor(name:)`) and consults the top of it to decide whether a rule fires. Type declarations reset isolation to `.none` unless explicitly `@MainActor`, so a class lexically nested inside an actor does *not* inherit actor isolation. The escape hatch is a justification comment immediately above the declaration — adjacency is strict, so the mechanism stays searchable and auditable.

## The Narbis race — the rule that was born from a real bug

The most valuable rule here, `cancellation-checkpoint-after-loop`, came from a production race in **Narbis**, a biofeedback headset app. A session could end two ways — *complete* on its own, or the user could *stop* it. The loop consumed sensor data with `for try await` over an `AsyncThrowingStream`, and the author handled two exits: the stream finishes, or it throws.

But there's a third. When the task is **cancelled**, a `for try await` on an `AsyncThrowingStream` ends *quietly* — the iterator returns `nil`; it does **not** throw. So a user-initiated stop fell straight through to `session.markCompleted()` and was silently recorded as *completed*.

```swift
for try await sample in stream {
    try Task.checkCancellation()
    process(sample)
}
// reached on BOTH normal completion AND cancellation
session.markCompleted()   // ❌ mislabels a cancelled stop
```

It survived Design-First TDD, three green gate cycles, and only surfaced when parallel package gates accidentally stress-loaded the scheduler. The rule flags exactly this shape — an `await` loop, in a function that already treats cancellation as meaningful, followed by exit-reason-dependent code with no post-loop cancellation check. It has to know the function boundary and walk the loop's following statements in control-flow order, which is why it's AST-based, not regex.

**8 rule IDs. All tests passing.**

## Try it

```bash
quality-gate --check concurrency
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
