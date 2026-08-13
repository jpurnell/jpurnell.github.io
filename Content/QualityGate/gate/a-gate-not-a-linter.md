---
layout: BlogPostLayout
series: quality-gate
title: "A Gate, Not a Linter"
tags: quality-gate, gate
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:04
lastModified: 2026-08-13
published: true
---

# A Gate, Not a Linter

**The philosophy behind quality-gate-swift: why mechanical enforcement beats good intentions, and what it takes to earn the right to block a commit.**

---

## The fifty-five error incident

We had thirteen documents. Sixty-one kilobytes of coding rules. A TDD contract with a mandatory VERIFY step. A session workflow. Design-proposal templates. Release checklists. Floating-point formatting guides.

None of them prevented us from shipping fifty-five errors and fifty-three warnings in a single batch of commits.

The failure happened during a sprint to build new modules for the Institutional Judgment System — the very system designed to help organizations learn from their mistakes. The workflow was followed: DESIGN, RED, GREEN, REFACTOR, DOCUMENT. Tests first. But the workflow has *six* steps, and the sixth is VERIFY — run the quality gate before committing. It got skipped. Every time. Across dozens of commits.

Floating-point exact equality in tests. Unreachable dead code left from refactoring. Public APIs with no documentation — in a project whose own doc-coverage checker flags exactly that. Silent error swallowing. Fifty-five errors, in the tool built to prevent these exact problems.

The root cause was not a lack of documentation. The documents were fine. The root cause was that **documentation describes the ideal process, and nothing forced adherence to it.**

That crystallized the principle underneath the whole project:

> **If a rule matters, it needs a hook, not a document.**

A linter is a document with syntax highlighting. It tells you what's wrong and lets you ship anyway. A **gate** is a hook. It doesn't happen when you remember; it happens every time, and when it fails, the commit does not happen.

## To block, you must be right

The moment you decide to *block* rather than *warn*, everything changes. A warning can be 60% accurate and still be useful. A gate that's 60% accurate is a gate people rip out within a week — and rightly so. An ignored checker is worse than no checker, because it trains people to skip gate output entirely.

So the entire design is organized around one demand: **nearly every finding must be real.** That single constraint drives every technical choice in the tool.

### It reads the tree, not the text

Most quality problems in Swift aren't typos — they're structural. A force-unwrap that crashes on the one `nil` you didn't expect. An `async` stream whose cancellation path was never specified. A pointer that escapes the block that owned it. These are invisible to a regex, which can't tell `value!` from `value != nil` from a `!` inside a string literal.

Every rule in quality-gate-swift walks the Swift **abstract syntax tree** via SwiftSyntax. It knows scope, type context, and control flow. That's what makes it precise enough to block. Zero regex — 42 checkers, all AST-based.

### Precision is the product

Precision isn't a nicety; it *is* the deliverable. Two numbers make the point. The first run of the dead-code checker against a real app (Narbis) emitted **~1,064 findings** — almost all from a vendored SDK the team couldn't change. A gate that cries wolf 1,064 times is one people learn to ignore. Tightening the checker drove that to **0**. Later, a noisy duplication pass produced **14,000+** findings; the same discipline collapsed it to **11** genuine ones.

Every hour spent killing a false-positive class buys the right to keep blocking.

### Recorded, never silent

Zero-tolerance doesn't mean zero exemptions. It means **no silent ones.** Every exemption is a single inline comment that states *why* — `// SAFETY:`, `// Justification:`, `// keychain:exempt` — recorded, dated, and searchable. You can see every place the rules were consciously relaxed, and so can the next person. There is no `--no-verify` culture, no backlog of ignored warnings.

## The architecture that makes it cheap

The reason this scales is a single protocol:

```swift
public protocol QualityChecker: Sendable {
    var id: String { get }
    var name: String { get }
    func check(configuration: Configuration) async throws -> CheckResult
}
```

That's the whole contract. Implement it, return a `CheckResult` with diagnostics, and register the module in one line. The reporters (terminal, JSON, SARIF for GitHub Code Scanning, Xcode build phase), the config loader, the parallel runner, the exit-code wiring — all of it works automatically.

The cost of adding a new check is proportional to the complexity of the *check*, not the complexity of *integrating* it. That matters more than it sounds. When integration is expensive, you don't add checks — you write the rule in a style guide, tell yourself you'll remember, and the bugs ship anyway. When integration is one new file and one line, you add the check. And then the bugs don't ship.

## Flag to understand, not forbid

Not every checker blocks. Some are advisory by design — complexity, legibility, smells, duplication — surfacing unusual-but-legitimate code with a recorded acknowledgment rather than a hard stop. The rule for advisory tools is strict: **earn your keep or get removed.** If a checker's findings are consistently ignored, the correct response is to disable it, not to force compliance. An advisory checker exists to help you *understand* the shape of the codebase, not to boss it around.

The gate blocks on correctness and safety. It informs on everything else. Keeping that line clean is what keeps the gate trusted.

## It's held to its own standard

quality-gate-swift runs its own 42 checkers on every push. Its ~2,800 tests are the tool held to the standard it enforces. When it finds a false positive, it finds it against itself first — like the recursion checker flagging its own SwiftSyntax visitor, caught and fixed before it ever shipped to another project. Dogfooding isn't a virtue signal here; it's the primary test harness.

## The gate is half the story

A gate tells you *no*. It's mechanical, unambiguous, and it never forgets to run. But it has no memory of *why you said yes* the last time you overrode it. It can't tell you that this exact exemption has been taken four times across three projects, or that the reasoning that justified it last quarter no longer holds.

That's the other half — the **Mirror** — and it's where this project stops being a linter and starts being an organizational nervous system. But the Mirror only works because the Gate is honest: every block, every exemption, every reason, recorded and never silent. Enforcement first. Then memory.

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
