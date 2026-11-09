---
title: QualityGateCore: Building a Static-Analysis Gate That Eats Its Own Cooking
description: A practitioner's account of how jpurnell designed and shipped a modular, AST-driven quality gate for Swift 6 projects — one that runs its own checkers on every commit of itself.
date: 2026-05-13 15:44
lastModified: 2026-11-02
tags: showcase, project, QualityGate, infrastructure, selfReflection
layout: ShowcaseLayout
style: deepDive
project: Internal Infrastructure
published: true
---

# QualityGateCore: Building a Static-Analysis Gate That Eats Its Own Cooking

> A practitioner's account of how jpurnell designed and shipped a modular, AST-driven quality gate for Swift 6 projects — one that runs its own checkers on every commit of itself.

---

## Overview

QualityGateCore is a static-analysis platform for Swift 6 packages. Where linters tend to operate on text patterns, QualityGateCore works at the level of Swift's compiler artifacts: SwiftSyntax parse trees for syntactic checks, and the compiler's index store for cross-file questions such as dead-code detection, recursion cycles, and symbol reachability. The project is explicit that it is not a replacement for SwiftLint but a complement — it occupies the layer SwiftLint does not: semantic correctness, safety contracts, documentation integrity, and release readiness.

The tool targets four overlapping audiences. Individual developers can install it via Homebrew and run `quality-gate` as a pre-commit or pre-push hook. Teams drop the bundled GitHub Actions workflow into their CI pipeline and get the same gate at merge time. Package authors who want only certain checks can depend on individual checker libraries without pulling in the whole system. And developers writing new checkers build against `QualityGateCore` and `QualityGateTestKit`, which together provide the primitives, the corpus harness, and the test infrastructure needed to calibrate a new rule.

The repository runs its own checkers against itself. That self-hosting stance, stated plainly in the project's `MASTER_PLAN.md`, is the most honest possible statement of confidence in the tool.

---

## Architecture

Seven months of active development — first commit March 2026, latest October 2026 — and 779 commits across a three-person team produced a package that is notably wide. The `Package.swift` enumerates roughly 90 targets, each a named SwiftPM library or executable with its own test target. That is not bloat; it is a deliberate modularity strategy. Each checker is a separately importable product, which means a consumer can add `DependencyAuditor` or `ConcurrencyAuditor` as a package dependency without touching anything else.

The dependency graph reflects a clear layering philosophy:

```
QualityGateCLI
    └── GatePlugins, GateCI, ReleaseReadinessAuditor, …
            └── QualityGateCore
                    ├── ExternalInputSyntax      (SwiftSyntax wrapper)
                    ├── SyntaxScope              (scope resolution)
                    ├── IndexStoreInfra          (indexstore-db bridge)
                    └── quality-gate-types       (shared value types)
```

`QualityGateCore` itself exposes the plugin protocol and shared primitives. Individual auditors depend on `QualityGateCore` and, where needed, on `IndexStoreInfra` for symbol-resolution queries. Nothing in the auditor layer depends on another auditor, keeping compile times manageable and checker authors isolated from each other's churn.

Two infrastructure choices deserve attention. First, `indexstore-db` is used rather than running the compiler on demand. This means a single `swift build` populates the index and every cross-file check reads from it, rather than spawning compiler processes per-file. Second, `SwiftSyntax` is consumed through a thin wrapper target, `ExternalInputSyntax`, which normalises the syntax tree into types the rest of the system can depend on without hard-coupling every checker to SwiftSyntax's own evolving API surface.

The read-only `--foreign` mode — for analysing repositories the developer does not own — is architecturally interesting. All writes, including suppressions and calibration data, are redirected to an overlay directory. The `--fix` flag is refused entirely. This is a deliberate safety boundary enforced at the core layer, not a convention, so checker authors cannot accidentally write to foreign source.

---

## Implementation

### The Checker Taxonomy

Looking at the target list, the checkers fall into rough families:

- **Safety and correctness**: `SafetyAuditor`, `PointerEscapeAuditor`, `FloatingPointSafetyAuditor`, `BoundedIOAuditor`, `ProcessSafetyAuditor`, `MemoryLifecycleGuard`
- **Concurrency**: `ConcurrencyAuditor`, `StochasticDeterminismAuditor`, `TemporalDeterminismAuditor`, `GPUSafetyAuditor`
- **Documentation integrity**: `DocLinter`, `DocCodeAuditor`, `DocGeneratedAuditor`, `DocCoverageChecker`
- **Code health**: `ComplexityAnalyzer`, `LegibilityAnalyzer`, `DuplicationAuditor`, `UnreachableCodeAuditor`, `RecursionAuditor`, `IdiomAuditor`, `SmellPack`
- **Infrastructure and release**: `ReleaseReadinessAuditor`, `DependencyAuditor`, `DependencyAdvisory`, `SubmoduleAuditor`, `SwiftVersionChecker`
- **Platform and HIG**: `HIGAuditor`, `AccessibilityAuditor`, `AppIntentsAuditor`, `PrivacyManifestChecker`, `KeychainSecretsChecker`

The documentation checks are the most distinctive. `DocCodeAuditor` extracts code fences from DocC articles, assembles them into a synthesised Swift program, and compiles it. `DocGeneratedAuditor` goes a step further: it runs that program and compares its output against figures claimed in the documentation. This is test-in-documentation at the level of contract, not convention.

### Dated Suppression

The debt-management workflow — `quality-gate adopt` followed eventually by `quality-gate re-verify` — is one of the more thoughtful UX decisions in the system. Instead of a permanent suppression comment that accrues silently, every adopted finding carries an expiry date. When the date lapses, `re-verify` returns the finding to the active queue. This makes technical debt visible and time-bounded rather than invisible and permanent.

A typical adoption record in the overlay might look like:

```yaml
# .quality-gate/debt.yml
- id: ConcurrencyAuditor/actor-isolation-violation
  file: Sources/Networking/Session.swift
  line: 47
  adopted: 2026-08-15
  expires: 2026-11-15
  note: "Refactor blocked on upstream SE-XXXX"
```

The `ContextAuditor` and `ControlMapping` targets suggest that the system also reasons about whether a suppression's stated rationale still applies — checking, for instance, whether the upstream blocker has since resolved.

### Precision Calibration

`quality-gate calibrate --coverage` collects sample counts and false-positive rates per checker. The infrastructure for this lives in `CorpusService` and `quality-gate-corpus-kit`. Running calibration against a known corpus produces precision reports that checker authors can use to tune thresholds, and that teams can use to decide which checks to enable in their gate. This is not common in open-source linters, which typically leave precision measurement as an exercise for the consumer.

### Claude Code Integration Patterns

jpurnell ran nine Claude Code sessions against this project, generating 113 commits and 238 messages. The session type distribution — four multi-task sessions, one iterative refinement, one exploration — reflects how the project was actually built: complex checkers developed over extended sessions rather than quick one-shot completions. The friction log shows `buggy_code` appearing nine times and `self_corrected_false_alarm` three times, suggesting a working pattern where generated code was treated as a draft to be verified rather than a final artifact. All nine sessions reached at least a mostly-achieved outcome, and five were fully achieved, indicating that the sessions were well-scoped and that jpurnell caught and corrected issues before they landed in the main branch. Two `privacy_overreach` friction events are notable given the project's domain — a static-analysis tool that reads source code has an obvious surface area for over-reach, and the session logs suggest that boundary was actively managed.

---

## Testing Strategy

The package ships test targets that mirror every checker target: `SafetyAuditorTests`, `ConcurrencyAuditorTests`, `DocCodeAuditorTests`, and so on across roughly 45 test targets. This is not incidental; it reflects a product decision that checker quality is a first-class concern rather than an afterthought.

`QualityGateTestKit` is the internal testing library. Checker authors write tests against it, which provides fixture Swift source, expected-finding matchers, and helpers for exercising the index-store integration without a full build.

```swift
import QualityGateTestKit

final class ConcurrencyAuditorTests: CheckerTestCase {
    func testActorIsolationViolationIsReported() throws {
        let source = """
        actor Counter {
            var value = 0
        }
        func increment(_ c: Counter) {
            c.value += 1  // isolation violation
        }
        """
        let findings = try audit(source, with: ConcurrencyAuditor())
        XCTAssertFinding(findings, id: "actor-isolation-violation", line: 5)
    }
}
```

The `JudgmentWorkbenchTests` target, which has no obvious paired library target, suggests a separate harness for subjective evaluation — running the full gate against known-good and known-bad corpora and measuring whether the checker's judgment aligns with human review. Combined with `CIParityTests` and `ForeignModeAcceptanceTests`, the test suite covers not just individual checkers but the integration points that matter in production: CI behaviour and foreign-mode write isolation.

The self-hosting property provides an ongoing integration test. When a checker is modified, the gate runs against the repository itself on the next commit. If the modified checker produces false positives or regressions, they surface immediately — on the project's own code, not a synthetic fixture.

---

## Lessons

**Modularity pays its cost at design time, not maintenance time.** Defining 90 targets up front in `Package.swift` feels excessive until a consumer needs only `DependencyAuditor`. The narrow interface per checker means changes to one auditor have zero compile-time impact on any other, and the target list serves as the public API of the platform. jpurnell's decision to enforce this boundary from the first release — v1.0.0 shipped in the same month the project started — meant the architecture was load-bearing from the beginning rather than retrofitted.

**Self-hosting is a forcing function for quality.** A tool that runs its own checks on its own code cannot tolerate noisy or fragile checks. Every false positive in the self-hosted run is immediately disruptive to the development workflow. This constraint visibly shaped the calibration infrastructure: the false-positive rate is not an abstract concern but something jpurnell encounters on every commit.

**Documentation as executable specification.** The `DocCodeAuditor` and `DocGeneratedAuditor` pattern — compile the code in the docs, run it, compare its output to the claimed figures — transfers directly to any project where correctness claims live in prose. The pattern decouples documentation accuracy from human diligence and instead enforces it mechanically. jpurnell has applied variants of this approach in other tooling contexts: wherever a document asserts a number, that number should be produced by code, not typed by hand.

**Dated suppressions over permanent ones.** The `adopt`/`re-verify` workflow transferred directly to larger team settings. Permanent suppression comments tend to be forgotten; suppressions with expiry dates are revisited. The expiry date is not enforced automatically — the developer still has to decide what to do — but the tooling makes the debt visible and ensures it is not silently inherited by future maintainers.

**Treat generated code as a draft.** The Claude Code session logs, with their `buggy_code` friction count of nine across nine sessions, reflect a pragmatic stance: AI-assisted code generation accelerates exploration but requires the same review discipline as any other external contribution. The fully-achieved and mostly-achieved outcome distribution suggests that scoping sessions tightly — matching the multi-task sessions to genuine multi-part problems rather than open-ended generation — is the lever that matters most for quality.
