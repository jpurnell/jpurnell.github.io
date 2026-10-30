---
title: QualityGateCore: Building a Production Static Analyzer That Eats Its Own Cooking
description: A deep-dive into the architecture, auditor ecosystem, and deliberate engineering tradeoffs behind a Swift 6 static-analysis gate that runs its own checkers on every commit.
date: 2026-05-13 15:44
lastModified: 2026-10-30
tags: showcase, project, QualityGate, infrastructure, selfReflection
layout: ShowcaseLayout
style: deepDive
project: Internal Infrastructure
published: true
---

# QualityGateCore: Building a Production Static Analyzer That Eats Its Own Cooking

> A deep-dive into the architecture, auditor ecosystem, and deliberate engineering tradeoffs behind a Swift 6 static-analysis gate that runs its own checkers on every commit.

## Overview

QualityGateCore is the engine powering `quality-gate-swift`, a static-analysis platform for Swift 6 projects that Jonathan Purnell has been building since March 2026. In roughly seven and a half months it has accumulated 779 commits across 15 releases — from v1.0.0 through v3.6.0 — making it one of the most actively iterated tools in his portfolio.

The project's stated mission is precise: run a curated set of correctness, safety, concurrency, security, and documentation checks against a Swift package using SwiftSyntax and the compiler's index store, then report findings through terminal, JSON, SARIF, or Xcode output formats. It is explicitly designed to sit *beside* SwiftLint rather than replace it, targeting the class of problems that require semantic understanding of Swift's type system and module graph — things a regex-based linter cannot reliably catch.

Four distinct user groups are served. Individual developers can install the `quality-gate` CLI via Homebrew and use it as a pre-commit or pre-push gate. Teams get a reusable GitHub Actions workflow and a caller template for CI integration. Package authors who want surgical adoption can pull individual checker libraries as SwiftPM dependencies without taking the entire platform. And checker authors get `QualityGateCore` and `QualityGateTestKit` as a stable SDK for building new auditors. The repository demonstrates its own fitness by running every checker against itself — a self-hosting constraint that has shaped nearly every architectural decision.

## Architecture

The package is organized around a principle of aggressive modularity. The `Package.swift` declares roughly 90 targets — each auditor ships as its own library product paired with its own test target and DocC catalogue. This is not accidental complexity; it reflects a deliberate judgment that a monolithic analysis library quickly becomes a liability when teams want to adopt only specific checks. The tradeoff is a larger dependency graph and longer cold-build times, which the project manages through SwiftPM's conditional compilation and careful layering.

The dependency stack flows in one direction:

```
QualityGateCLI
    └── GateCI / GatePlugins
        └── QualityGateCore          ← coordination, runner, reporting
            ├── ExternalInputSyntax  ← SwiftSyntax visitor infrastructure
            ├── SyntaxScope          ← scope/binding resolution
            ├── IndexStoreInfra      ← indexstore-db wrapper
            └── [individual auditors]
                └── quality-gate-types (shared value types)
```

`QualityGateCore` owns the gate runner loop, checker registration, finding aggregation, and output formatting. Individual auditors implement a protocol from `quality-gate-types` and declare their own dependencies — `ConcurrencyAuditor` reaches into SwiftSyntax visitors and `SyntaxScope`, while `DependencyAuditor` pulls from `indexstore-db` and the network advisory feed via `DependencyAdvisory`. The separation means auditors can be versioned and tested independently.

Cross-file analysis — dead code detection, recursion cycle finding, cross-module type checks — is handled through `IndexStoreInfra`, a thin wrapper over Apple's `indexstore-db` package. This is the architecturally interesting seam: most SwiftSyntax-based tools stop at file boundaries. By coupling the AST walk to the index store's symbol reference graph, checkers like `UnreachableCodeAuditor` and `RecursionAuditor` can reason about call chains that span modules. The implementation has to handle partial indexes gracefully, since a developer running the gate before a full build will have a stale or incomplete store.

The `--foreign` mode deserves separate attention as an architectural constraint that influenced the entire write path. When analyzing a repository the user does not own, all writes — suppressions, adopted debt records, fix applications — are redirected to an overlay directory. The `--fix` flag is refused entirely in this mode. Enforcing this required that every auditor's output path be mediated through a context object rather than writing directly to the file system, which turned out to be a useful discipline even outside the foreign-mode use case.

## Implementation

**The auditor surface area.** With over 40 named auditors — `FloatingPointSafetyAuditor`, `StochasticDeterminismAuditor`, `TemporalDeterminismAuditor`, `GPUSafetyAuditor`, `PointerEscapeAuditor`, `MemoryLifecycleGuard`, `HIGAuditor`, `AppIntentsAuditor`, among many others — the project is essentially a catalog of things that go wrong in production Swift codebases. Implementing each required Jonathan to define a precise scope: what exactly counts as a violation, what the fix suggestion should look like, and what the false-positive rate is acceptable at. The `quality-gate calibrate --coverage` command reflects this seriousness — it tracks sample counts and measured false-positive rates per checker so practitioners can make informed decisions about which gates to enforce strictly.

**Documentation auditing as a first-class concern.** The documentation checker suite (`DocLinter`, `DocCodeAuditor`, `DocGeneratedAuditor`, `DocCoverageChecker`) goes well beyond checking that doc comments exist. `DocCodeAuditor` extracts code fences from DocC articles and compiles them as a single program to verify they are syntactically and semantically valid. A companion check verifies that published figures in documentation actually match what the code computes at runtime. This is the kind of check that requires the `swift-docc-plugin` and `swift-subprocess` dependencies working in concert — spinning up a subprocess to compile and run extracted snippets, then diffing their output against claimed values:

```swift
// Conceptual shape of DocCodeAuditor's verification loop
for article in corpus.articles {
    let snippet = try extractor.extract(from: article)
    let result = try subprocess.compile(snippet)
    let output = try subprocess.run(result.binary)
    if output != article.claimedOutput {
        emit(.mismatch(article: article, expected: article.claimedOutput, got: output))
    }
}
```

**Dated suppression and debt management.** The `quality-gate adopt` command records existing findings as technical debt entries with expiry dates. `quality-gate re-verify` works the queue of expired entries, prompting the developer to either fix the underlying issue or explicitly extend the deadline. This is meaningfully different from a simple suppression comment — it makes the debt visible, bounded, and actionable. The `CorpusService` target manages the persistent store for these entries, and `IJSRefiner` and `IJSDashboardCLI` suggest a workflow for tracking and triaging the debt queue over time.

**Self-hosting as a correctness constraint.** The repository runs its own checkers on itself on every commit. This is not just a demonstration — it is a development forcing function. When `ConcurrencyAuditor` gains a new check, it immediately fires against the project's own async code. When `LoggingAuditor` tightens its rules, the project's own logging calls are the first thing that breaks. Jonathan described this discipline in `CLAUDE.md` under "Zero-Tolerance Coding Rules," and the git history reflects it: patch releases like v3.1.1, v3.1.2, v2.0.1, and v2.0.2 cluster around periods when a new auditor rule caught something in the project's own code that required an immediate fix rather than a suppression.

**Swift 6 concurrency throughout.** Building on Swift Tools Version 6.2 means the project is fully `Sendable`-annotated, uses structured concurrency for its parallel checker execution, and cannot rely on the escape hatches that made Swift 5.9 concurrency easier to ship. The `ConcurrencyAuditor` — which checks *other* projects for these issues — must itself be correct, which makes it an unusually well-exercised checker.

## Testing Strategy

The project ships a dedicated `QualityGateTestKit` target with its own test target, indicating that testing infrastructure is treated as a first-class product rather than an implementation detail. Each auditor has a paired `*Tests` target — `ConcurrencyAuditorTests`, `MemoryLifecycleGuardTests`, `HIGAuditorTests` — which enables isolated CI runs per module and makes it straightforward to identify which auditor a regression belongs to.

`ForeignModeAcceptanceTests` and `CIParityTests` are structurally distinct from unit tests, reflecting integration concerns: does the gate behave identically in foreign mode versus native mode (modulo write restrictions), and do local results match what CI produces? The `CIParityTests` target in particular addresses a class of "works on my machine" failures that are common in tools that depend on the build system's index store being in a specific state.

`JudgmentWorkbenchTests` suggests a more qualitative testing layer — likely a harness for evaluating whether auditor findings across a corpus match human-reviewed expected outputs. This connects to the `quality-gate-corpus-kit` dependency and the `CorpusService` target, implying that the project maintains a curated set of known-good and known-bad Swift snippets against which checker precision is measured.

The `BusinessMath` and `SwiftDeterminism` dependencies point to a commitment to reproducible, numerically stable computation in the precision reporting path — false-positive rates computed with financial-grade arithmetic rather than floating-point shortcuts.

## Lessons

**Protocol-mediated I/O pays off immediately.** The decision to route all file writes through a context object — forced by the foreign-mode requirement — turned out to be the single most useful architectural choice for testability. Every auditor that writes nothing to disk in tests (it all goes to an in-memory overlay) is easier to test in parallel without flakiness. This pattern transferred directly to other tools in Jonathan's workflow that have any kind of side-effecting output.

**Self-hosting is a better specification than a requirements document.** The zero-tolerance rule — the project must pass its own checks — proved to be a more rigorous spec than any written description of what the checks should do. Edge cases that seemed acceptable in the abstract became obviously wrong when they fired against real production code in the repository. Several checker designs went through two or three iterations specifically because the first version produced false positives against the project's own patterns.

**Claude Code sessions as targeted surgical tools.** Across nine sessions totaling 238 messages and 113 commits, the collaboration pattern was primarily multi-task and iterative refinement rather than exploratory. The friction log is honest: 9 instances of buggy generated code, 3 false alarms that required self-correction, 2 cases of the wrong approach being proposed before course correction. All nine sessions reached full or mostly-achieved outcomes, which reflects a working style where generated code is treated as a starting point subject to the same review and self-hosting tests as anything else — not as a finished artifact.

**Modular auditor packages create a contributor surface.** Shipping each auditor as its own library product was partly an adoption story (teams can add one checker at a time) but it also created a clear contribution model. Someone writing a new auditor builds against `QualityGateCore` and `QualityGateTestKit`, adds their target to `Package.swift`, and the gate immediately begins checking their own code. The low ceremony of that loop — visible in the `GatePlugins` target — is what makes the platform extensible without requiring intimate knowledge of the full codebase.

**Dated suppressions change the psychology of adoption.** The `adopt` / `re-verify` debt workflow emerged from observing that teams rejected static-analysis tools when the initial finding count was overwhelming. Giving every suppression an expiry date reframes the conversation: the debt is acknowledged, bounded, and scheduled for resolution rather than silently ignored. This pattern — make the implicit explicit and time-bounded — has applicability well beyond static analysis tooling.
