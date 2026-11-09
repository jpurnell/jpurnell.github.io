---
title: QualityGateCore: Building a Static-Analysis Gate That Enforces Its Own Rules
description: An 800-commit, eight-month construction of a SwiftSyntax-based quality gate for Swift 6 projects — modular by design, honest about its own debt, and strict enough to run its own checkers on itself.
date: 2026-05-13 15:44
lastModified: 2026-11-09
tags: showcase, project, QualityGate, infrastructure, selfReflection
layout: ShowcaseLayout
style: deepDive
project: Internal Infrastructure
published: true
---

# QualityGateCore: Building a Static-Analysis Gate That Enforces Its Own Rules

> An 800-commit, eight-month construction of a SwiftSyntax-based quality gate for Swift 6 projects — modular by design, honest about its own debt, and strict enough to run its own checkers on itself.

## Overview

QualityGateCore is the engine behind `quality-gate-swift`, a static-analysis platform for Swift 6 projects that sits beside SwiftLint rather than replacing it. Where SwiftLint excels at style and idiom, QualityGateCore targets the deeper concerns: concurrency safety, documentation correctness, dead code, recursion cycles, floating-point misuse, memory lifecycle hazards, and release readiness. Analysis is driven by SwiftSyntax ASTs and, for cross-file questions, the compiler's own index store — no regular expressions, no fragile line-scanning.

The project serves four distinct constituencies. Individual Swift developers can install the `quality-gate` CLI via Homebrew and wire it into a pre-commit or pre-push hook. Teams can drop in the reusable GitHub Actions workflow shipped with the repository. Package authors who want only a specific checker can depend on that checker's library product directly, since every auditor is its own SwiftPM module. And developers writing new checkers build against `QualityGateCore` and the `QualityGateTestKit` harness, which provides fixture-driven scaffolding for the rule-writing loop.

A detail that says something about the project's character: the repository runs all of its own checkers on itself. QualityGateCore is its own first user, its own tightest critic.

## Architecture

The package's target list reads like a taxonomy of everything that can go wrong in a Swift codebase. At last count there are roughly 90 targets — auditors, analyzers, infrastructure libraries, CLI frontends, and test suites — organized into several conceptual layers.

**Core infrastructure.** `QualityGateCore` holds the shared types, finding representation, suppression logic, and the plugin protocol that every checker implements. `ExternalInputSyntax` wraps the SwiftSyntax parse pipeline. `IndexStoreInfra` abstracts over `indexstore-db` for cross-file symbol queries. `SyntaxScope` provides scope-aware tree walking used by multiple auditors.

**Checker modules.** Each auditor is a standalone library target with its own test target and DocC catalogue. The roster spans concurrency (`ConcurrencyAuditor`, `PointerEscapeAuditor`, `MemoryLifecycleGuard`, `ProcessSafetyAuditor`), determinism (`StochasticDeterminismAuditor`, `TemporalDeterminismAuditor`), documentation (`DocLinter`, `DocCodeAuditor`, `DocGeneratedAuditor`, `DocCoverageChecker`), complexity (`ComplexityAnalyzer`, `RecursionAuditor`, `UnreachableCodeAuditor`), security (`SafetyAuditor`, `KeychainSecretsChecker`, `PrivacyManifestChecker`), and several domains that reflect the project's real-world origin: `HIGAuditor`, `AccessibilityAuditor`, `AppIntentsAuditor`, `LoggingAuditor`.

**Reporting and integration.** `ServerSurface` handles output formatting across terminal, JSON, SARIF, and Xcode diagnostic formats. `GateCI` owns CI-specific behavior. `CorpusService` connects to `quality-gate-corpus-kit` for precision calibration. `NarrativeCore` drives the human-readable summary that appears at the end of a gate run.

**The suppression model.** Rather than the usual blanket `// swiftlint:disable` escape hatch, `quality-gate adopt` records findings as named debt entries with an expiry date. `quality-gate re-verify` works the queue of entries whose deadlines have passed. This design means technical debt is explicitly time-boxed: the team acknowledges it, sets an expectation, and the tool enforces the follow-through.

**Foreign mode.** The `--foreign` flag puts QualityGateCore into a read-only posture for repositories you do not own. Writes — including suppression records and `--fix` patches — are redirected to an overlay directory. This makes it safe to audit a dependency or a third-party package without touching it.

The dependency graph reflects deliberate layering. `quality-gate-types` carries the shared data model, allowing consumers to depend on types without pulling in the full analysis engine. `swift-vigil` provides liveness primitives. `SwiftDeterminism` underpins the determinism auditors. `BusinessMath` and `swift-crypto` appear in the financial and security domains respectively.

## Implementation

Several implementation choices surface repeatedly across the codebase and are worth examining individually.

**AST-first analysis.** Every checker that can operate on a single file does so through a SwiftSyntax `SyntaxVisitor` or `SyntaxRewriter` subclass rather than string matching. This matters most for checkers like `ConcurrencyAuditor`, where the question "is this `Task { }` created on the main actor?" cannot be answered without understanding the surrounding type declaration and its `@MainActor` annotations. `SyntaxScope` exists precisely to give individual auditors a lightweight answer to "what are the actors and isolation domains visible at this call site?" without each auditor re-implementing tree climbing.

```swift
// Sketch of the scope-aware visitor pattern used across auditors
final class IsolationVisitor: SyntaxScopeVisitor {
    override func visitPost(_ node: TaskExprSyntax) {
        guard let scope = currentScope else { return }
        if scope.isolation == .mainActor && node.lacksExplicitIsolation {
            record(.implicitMainActorEscape, at: node)
        }
    }
}
```

**Cross-file questions via index store.** `IndexStoreInfra` wraps `indexstore-db` to answer questions like "is this symbol referenced anywhere outside this file?" (dead code) or "does this call chain eventually call itself?" (recursion cycles). The index store approach means the analysis sees the same symbol graph the compiler built — no reimplementing import resolution or protocol conformance lookup.

**DocC article verification.** The documentation checkers represent the most unusual feature in the system. `DocCodeAuditor` extracts Swift code fences from DocC articles and assembles them into a minimal program, then shells out to the Swift compiler to verify they compile. `DocGeneratedAuditor` goes further: it runs that assembled program, captures its output, and compares the figures against numeric claims in the surrounding prose. A documentation article that says "this reduces latency by 40%" is a falsifiable claim that the tool can check on every commit.

**Dated suppression implementation.** The `GatePlugins` target wires the adoption workflow together. When `quality-gate adopt` runs, it serializes findings into a structured debt file with an ISO 8601 expiry timestamp. `quality-gate re-verify` reads this file, filters for expired entries, and re-runs only the relevant checkers against the affected files. This avoids re-scanning the entire project on every re-verification pass.

**Precision calibration.** `CorpusService` connects to `quality-gate-corpus-kit`, a companion repository of annotated Swift code samples with known ground truth. `quality-gate calibrate --coverage` runs a checker against this corpus, counts true positives, false positives, and false negatives, and reports sample-level precision and recall. This gives checker authors a feedback loop beyond "does the test pass?"

**Claude Code sessions.** Nine Claude Code sessions contributed 113 commits across the project's 800-commit history. The friction log is instructive: `buggy_code` was the most common issue (9 instances), followed by `self_corrected_false_alarm` (3). The session mix — four multi-task, one exploration, one iterative refinement — reflects the project's complexity: most work required holding several moving parts in mind simultaneously rather than isolated single-task application. All nine sessions reached their goals fully or mostly, suggesting that the project's own strict `CLAUDE.md` guidance (zero-tolerance coding rules, build feedback requirements, development workflow) was effective scaffolding even for AI-assisted sessions.

## Testing Strategy

Each of the ~45 auditor modules ships its own test target, making `QualityGateCoreTests` a coordination suite rather than a monolithic test file. The pattern throughout is fixture-driven: test cases provide minimal but realistic Swift source as inline strings or file fixtures, run the checker, and assert on the finding set.

```swift
func testDetectsImplicitMainActorEscape() throws {
    let source = """
    @MainActor class ViewModel {
        func refresh() {
            Task { await expensiveWork() }  // no explicit isolation
        }
    }
    """
    let findings = try ConcurrencyAuditor().analyze(source: source)
    XCTAssertEqual(findings.count, 1)
    XCTAssertEqual(findings[0].rule, .implicitMainActorEscape)
}
```

`QualityGateTestKit` codifies this pattern into a reusable harness for new checker authors, with helpers for constructing synthetic index stores, asserting on SARIF output, and comparing finding sets with order-independent equality.

The `ForeignModeAcceptanceTests` and `CIParityTests` targets represent integration-level coverage. `ForeignModeAcceptanceTests` runs the full CLI against a checked-in fixture repository with `--foreign`, verifying that no writes escape the overlay. `CIParityTests` asserts that running the gate locally and running it in the GitHub Actions workflow produce identical finding sets — a guard against environment-sensitive analysis.

The `JudgmentWorkbenchTests` target is notably named: it appears to be the testing ground for borderline or ambiguous cases where the correct finding is a matter of judgment rather than mechanical correctness, keeping those decisions explicit and reviewable.

The corpus calibration loop via `CorpusService` functions as a statistical quality gate on the checkers themselves — a meta-layer of quality assurance that tracks precision and recall trends across releases.

## Lessons

**Modularity must be designed in from the start, not refactored in.** The decision to make each auditor a separate SwiftPM target from the beginning — rather than a class inside a monolithic library — was validated repeatedly when adding new checkers, deprecating old ones, and allowing consumers to take narrow dependencies. Retrofitting this structure into an existing monolith would have been a major disruption.

**The tool should eat its own cooking.** Running QualityGateCore's checkers against QualityGateCore itself catches real bugs and surfaces real usability problems. When a checker's output is confusing, the author encounters that confusion immediately. This tight feedback loop transferred directly to later projects: self-hosting analysis tooling is now a first-day setup step rather than an afterthought.

**Suppression with expiry dates is the right model for technical debt.** The dated adoption workflow changed how the team talked about existing findings. "We'll fix this by the end of the sprint" became a machine-enforced commitment rather than a social one. This pattern transferred to project management tooling built afterward.

**Precision measurement belongs in the tool, not in a spreadsheet.** Building `quality-gate calibrate` as a first-class command rather than an ad-hoc script meant that precision regressions were caught in CI alongside functional regressions. The lesson generalized: any metric important enough to track is important enough to automate.

**AI-assisted sessions work best with tight environmental contracts.** The `CLAUDE.md` file specifying build feedback requirements, zero-tolerance rules, and workflow steps was not overhead — it was the difference between sessions that produced mergeable code and sessions that required cleanup. The friction pattern (buggy code more common than wrong approach) suggests the guidance successfully constrained strategy while mechanical correctness remained the variable to manage.
