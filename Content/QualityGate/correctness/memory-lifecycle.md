---
layout: BlogPostLayout
series: quality-gate
title: "MemoryLifecycleGuard: Tasks That Never Cancel, Delegates That Never Die"
tags: quality-gate, correctness, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-08-08 09:00
lastModified: 2026-08-08
published: true
---

# MemoryLifecycleGuard

**Retain cycles, un-cancelled tasks, and unbounded streams — the memory bugs that don't crash, they just leak.**

---

Memory bugs in Swift rarely announce themselves. A stored `Task` that's never cancelled keeps running after its owner is gone. A `strong` delegate quietly forms a retain cycle. An `AsyncStream` with no back-pressure grows without bound. The app doesn't crash — it just gets slower, warmer, and stranger over hours.

## What it catches

```swift
// ❌ lifecycle-task-no-cancel — a stored Task with no cancellation
final class Loader {
    private var task: Task<Void, Never>?
    func start() { task = Task { await load() } }   // never cancelled
}

// ❌ lifecycle-strong-delegate — a strong delegate reference (retain cycle)
var delegate: MyDelegate?          // should be `weak var`

// ❌ lifecycle-unbounded-stream — an AsyncStream with no termination path
// ❌ lifecycle-task-no-deinit — a Task-owning type with no deinit to cancel it
```

Representative rule IDs: `lifecycle-task-no-cancel`, `lifecycle-task-no-deinit`, `lifecycle-strong-delegate`, `lifecycle-unbounded-stream`, `lifecycle-stream-terminated-elsewhere`, `lifecycle-delegate-retained-elsewhere`.

## Cross-file lifecycle analysis

The interesting part is what makes it precise. A `Task` stored in one file might legitimately be cancelled in another; a delegate declared `strong` here might be retained safely there. So the guard does **cross-file** analysis — the `-elsewhere` rules exist specifically to suppress a finding when the cancellation or the ownership actually lives in a different file. That's the difference between a checker that nags and one you can leave on: it looks at the whole picture before it fires. Stale exemptions (`lifecycle-stale-exemption`) get flagged too, so suppressions don't rot.

## Try it

```bash
quality-gate --check memory-lifecycle
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
