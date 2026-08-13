---
layout: BlogPostLayout
series: quality-gate
title: "ProcessSafetyAuditor: The 64 KB Pipe Deadlock It Caught in Its Own Author's Code"
tags: quality-gate, correctness, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:13
lastModified: 2026-08-10
published: true
---

# ProcessSafetyAuditor

**Unsafe process spawning and command-injection patterns — including a classic deadlock that hangs forever, silently.**

---

Shelling out from Swift is deceptively easy to get wrong. `Process` + `Pipe` looks innocent, but there's a trap that doesn't show up until output crosses a threshold: if you spawn a process, call `waitUntilExit()`, and *then* read the pipe, you deadlock the moment the child writes more than the pipe buffer (~64 KB on macOS). The child blocks writing; the parent blocks waiting; nothing moves. Forever.

## What it catches

```swift
// ❌ process.wait-before-read — read the pipe AFTER waiting: deadlocks past ~64 KB
let pipe = Pipe()
process.standardOutput = pipe
try process.run()
process.waitUntilExit()                                  // ← child fills the pipe and blocks
let data = pipe.fileHandleForReading.readDataToEndOfFile()

// ✅ drain the pipe before (or concurrently with) waiting
let data = pipe.fileHandleForReading.readDataToEndOfFile()
process.waitUntilExit()
```

**Rule ID:** `process.wait-before-read`. It also flags command-injection shapes — interpolated shell strings, unsanitized arguments passed to `/bin/sh -c`.

## Caught in its own author's code

The best endorsement I can give this checker is that it caught the exact bug in *my* code. While building the CI telemetry-push path — the code that publishes gate results to the corpus — the very first commit attempt had a `waitUntilExit()` before the pipe read. Under a small test fixture it passed; against real gate output it would have hung the moment the report crossed 64 KB. ProcessSafetyAuditor flagged it before it ever ran. That's the whole argument for the tool in one incident: the bug that only appears under load, caught at commit time instead of at 2 a.m.

## Try it

```bash
quality-gate --check process-safety
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
