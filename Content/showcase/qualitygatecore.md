---
title: QualityGateCore: A Static-Analysis Gate for Swift 6 Projects
description: A modular SwiftSyntax-based analysis tool that runs correctness, safety, concurrency, security, and documentation checks against Swift packages as a pre-commit or CI gate.
date: 2026-05-13 15:44
lastModified: 2026-11-10
tags: showcase, project, QualityGate, infrastructure, selfReflection
layout: ShowcaseLayout
style: deepDive
project: Internal Infrastructure
published: true
---

# QualityGateCore: A Static-Analysis Gate for Swift 6 Projects

> A modular SwiftSyntax-based analysis tool that runs correctness, safety, concurrency, security, and documentation checks against Swift packages as a pre-commit or CI gate.

## Overview

QualityGateCore is a static-analysis framework for Swift 6 packages. It runs on every commit and push, checking the codebase against a set of auditors that cover concurrency safety, memory management, documentation accuracy, floating-point correctness, accessibility, and more. The output goes to the terminal, JSON, SARIF, or Xcode's issue navigator depending on what the caller wants.

The project targets four groups. First, individual Swift developers who want a local pre-commit or pre-push gate and can install the `quality-gate` CLI via Homebrew or build from source. Second, teams running checks in CI, for whom the repository ships a reusable GitHub Actions workflow and a caller template. Third, package authors who need only some checks—each checker is a separate SwiftPM library product and can be pulled in as a dependency on its own. Fourth, developers writing new checkers, who build against `QualityGateCore` and `QualityGateTestKit`.

The tool is designed to sit alongside SwiftLint, not replace it. SwiftLint handles style and idiomatic Swift; QualityGateCore handles things that require an AST or cross-file symbol resolution—dead code, recursion cycles, documentation that claims a function returns a specific value and then doesn't, and so on.

The repository runs its own checkers on itself, so every release has passed the gate before it ships.

## Architecture

The package declares around 90 targets across roughly 40 checker modules, each with its own test target. The top-level structure has a few layers.

**Analysis substrate.** `ExternalInputSyntax` wraps the SwiftSyntax parse pipeline and provides a shared `SourceFile` type that the auditors consume. `IndexStoreInfra` wraps `indexstore-db` to answer cross-file questions: which declarations are referenced from where, which are never referenced at all. Keeping these in separate targets means auditors that only need syntax don't pay for index loading, and auditors that need both can depend on both.

**Checker modules.** Each checker—`ConcurrencyAuditor`, `RecursionAuditor`, `PointerEscapeAuditor`, `FloatingPointSafetyAuditor`, `TemporalDeterminismAuditor`, and so on—is its own library target. The convention is that a checker exposes a type conforming to a protocol in `QualityGateCore` and reports findings as typed values from `quality-gate-types`, a separate package that holds the shared data model so that checkers and consumers can version it independently.

**Gate orchestration.** `QualityGateCore` itself is the orchestration layer. It loads checker plugins through `GatePlugins`, fans the source files out across them, collects findings, and applies suppression rules. The suppression system records findings with an expiry date—`quality-gate adopt` writes the entry, `quality-gate re-verify` works through expired ones—so teams can adopt the tool on an existing codebase without being blocked on pre-existing debt.

**Output formatting.** `QualityGateCLI` owns the final output step. SARIF, JSON, terminal, and Xcode outputs are separate formatters that consume the same findings list.

**Documentation auditors.** Three auditors handle DocC: `DocCodeAuditor` extracts code fences from DocC articles and attempts to compile them as a single program, `DocLinter` checks structure, and `DocCoverageChecker` measures which declarations have documentation. The `doc-claims` check compares figures stated in documentation against what the code actually computes, using `BusinessMath` for numeric verification.

**Foreign mode.** When invoked with `--foreign`, the tool redirects any writes (suppression entries, caches) to an overlay directory and refuses `--fix` operations. This lets you run the gate against a repository you don't own without touching it.

**Calibration.** `quality-gate calibrate --coverage` runs each checker against a corpus managed by `quality-gate-corpus-kit` and records sample counts and estimated false-positive rates. This feeds back into precision reporting in findings output.

## Implementation

**SwiftSyntax over regex.** Every check that can be expressed as an AST walk is. For example, the recursion auditor doesn't grep for a function calling itself by name—it builds a call graph from SwiftSyntax's function call expression nodes and then uses `IndexStoreInfra` to resolve cross-file call edges before looking for cycles. This handles indirect recursion across files.

**`SyntaxScope`.** Several auditors need to know the containing declaration context of a syntax node—whether a particular expression is inside an `actor`, an `async` function, a `@MainActor`-annotated type, and so on. I extracted this into `SyntaxScope`, a shared module that walks the syntax tree upward from a node and answers context questions. This avoids each auditor reimplementing the same upward-walk logic with its own bugs.

```swift
// Auditors consume SyntaxScope rather than walking parent chains themselves
let scope = SyntaxScope(node: callExprNode, in: sourceFile)
if scope.isInsideActorIsolated {
    // concurrency rules apply
}
```

**`SwiftDeterminism` and `StochasticDeterminismAuditor`.** One category of checks concerns determinism: does the code depend on `Date()`, `UUID()`, unordered collections iterated in a non-deterministic way, or random number generators in paths that are expected to be stable? `TemporalDeterminismAuditor` and `StochasticDeterminismAuditor` are separate targets because the fix guidance differs—temporal issues are usually about injecting a clock dependency, stochastic issues are usually about seeding or separating generation from use.

**`MemoryBuilder` and `MemoryLifecycleGuard`.** These two targets handle memory-related checks: `MemoryBuilder` constructs a model of allocation sites and their expected lifetimes from the syntax, and `MemoryLifecycleGuard` checks that the model's constraints are satisfied—catching cases like a pointer that escapes a `withUnsafeBytes` closure, which `PointerEscapeAuditor` also flags from a different angle.

**`IJSRefiner` and `IJSDashboardCLI`.** "IJS" stands for issue-justification-suppression. The refiner re-evaluates existing suppression entries—checking whether the issue they suppressed still exists, whether the entry has expired, and whether it was correctly categorized—and the dashboard CLI renders the current suppression queue with aging information.

**Claude Code sessions.** I ran 9 Claude Code sessions across 113 commits, mostly for multi-task work and iterative refinement. The session logs show 9 friction events tagged `buggy_code`—generated code that didn't compile or produced wrong behavior—and 3 tagged `self_corrected_false_alarm`, where the assistant initially flagged something as a problem and then walked it back. For this codebase, where the tool being built is itself a code-correctness checker, that failure mode is particularly visible: a generated auditor that misidentifies a valid pattern undercuts trust in the whole gate. In practice I reviewed generated checker logic more carefully than generated boilerplate.

## Testing Strategy

Each of the ~40 checker modules has its own test target, so test failures point directly to the responsible module. `QualityGateTestKit` provides shared test infrastructure—fixture source files, helpers for asserting finding sets, and mock implementations of the protocol types in `QualityGateCore`.

**`ForeignModeAcceptanceTests`** runs the full CLI against a fixture repository with `--foreign` set and verifies that no writes occur outside the overlay directory and that `--fix` is rejected.

**`CIParityTests`** compares the findings produced locally against those produced by the GitHub Actions workflow on the same commit, to catch cases where the CI environment produces different results than a developer's machine.

**`JudgmentWorkbenchTests`** (under `JudgmentWorkbenchTests`, which appears without a corresponding library target) covers the suppression system's judgment logic—whether a finding at a given location matches a suppression entry, how expiry is computed, and how re-verify queuing works.

**Corpus-based calibration.** `CorpusService` manages a set of known Swift packages used as calibration targets. Running `quality-gate calibrate --coverage` against the corpus produces false-positive and false-negative counts per checker, stored as baseline data. When a checker changes, the calibration run shows whether precision moved.

The 809 commits across 20 releases (v1.0.0 through v3.11.0, plus two date-stamped releases) over roughly eight months mean the test suite has been exercised at release cadence throughout.

## Lessons

**Separate the data model from the analysis.** Putting the finding types and the checker protocol in `quality-gate-types` as a standalone package, rather than in `QualityGateCore`, turned out to matter earlier than expected. By v2, two other internal tools depended on the finding format for dashboarding. If the types had lived inside the main package, versioning would have been messier.

**Per-checker test targets pay off when checkers interact.** When `ConcurrencyAuditor` and `PointerEscapeAuditor` both started emitting findings on the same code patterns, having separate test targets meant the interaction was visible as a cross-target concern rather than a collision inside a shared test file. It also made it straightforward to run only the tests for the module under active development.

**`SyntaxScope` as a shared abstraction.** The original auditors each walked parent chains in their own way. Extracting `SyntaxScope` after three auditors had diverged required touching all three, but after that, adding new auditors that needed context was much cheaper. The extraction also caught two bugs where different auditors had slightly different answers for the same node in the same file.

**Foreign mode has to be enforced at the I/O layer, not the logic layer.** An early design checked `--foreign` in each write site in the orchestration layer. That's the wrong place: the enforcement is too easy to miss when adding a new code path. Moving it to a wrapper around the file-system calls that the whole tool uses meant new code paths inherited the restriction automatically.

**Calibration as a feedback loop for new checkers.** Writing a new checker and immediately running it against the corpus shows whether the detection rate on real code is plausible. Several early auditor implementations had false-positive rates above 30% on the corpus, which led to tighter AST conditions before the checker shipped. Without that feedback loop, those issues would have surfaced as user complaints.
