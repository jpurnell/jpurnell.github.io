---
layout: BlogPostLayout
tags: project, swift, apple, development, tooling, security
image:
imageDescription:
title: Your AI Wrote the Code. Who's Checking the Documentation?
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-04-14 18:00
lastModified: 2026-04-14
published: true
---

# Your AI Wrote the Code. Who's Checking the Documentation?

**How a security audit revealed that the real risk in LLM-assisted development isn't bad code — it's documentation that silently rots while the code races ahead.**

---

Here's a story about how a routine security scan led to building an entirely new class of quality tooling — and why it matters more in the age of AI-assisted development than it ever did before.

## The Foxguard Report

I ran [Foxguard](https://github.com/PwnKit-Labs/foxguard), a Rust-based SAST scanner, against [BusinessMath](https://github.com/jpurnell/BusinessMath) — my Swift financial mathematics library. Four findings came back: one real path-traversal vulnerability in `AuditTrail.swift`, and three false positives where `fatalError("Failed: \(error)")` messages were flagged as SQL injection.

The real finding was straightforward: a `FileManager` operation accepting a `URL` parameter without sanitizing path traversal sequences. Fixed it with `URL.standardized` plus an `isFileURL` guard. Committed, moved on.

The false positives were more interesting. Foxguard uses tree-sitter for AST parsing — fast, cross-language, but context-blind. It sees "string interpolation inside a function call" and can't distinguish a crash message from a database query. Three out of four findings were noise.

## The Decision Not to Integrate

My first instinct was to add Foxguard to [quality-gate-swift](https://github.com/jpurnell/quality-gate-swift), the CLI tool I use to enforce zero-warning quality gates across all my Swift projects. But the more I looked at it, the more I realized I was solving the wrong problem.

Foxguard has 10 Swift rules. They were added 11 days before my audit. Semgrep's public registry has effectively zero community Swift rules. The Swift security scanning ecosystem is nearly empty.

So instead of integrating someone else's tool with a 75% false-positive rate, I built a `SecurityVisitor` inside quality-gate-swift's existing `SafetyAuditor` module. Ten rules mapped to OWASP Mobile Top 10 and CWE identifiers, implemented with SwiftSyntax for full AST context. The key differentiator: it knows that `fatalError("...\(error)")` is a crash message, not a SQL query, because it can see the enclosing function name in the typed AST.

Then I published the same rules as [Semgrep-compatible YAML](https://github.com/jpurnell/swift-security-rules) — because if the community has almost no Swift security rules, someone should fix that, and the high-precision implementation can stay proprietary while the patterns are democratized.

## The Real Finding

But the security rules weren't the insight. The insight came when I ran `quality-gate --check status` against quality-gate-swift's own Master Plan — the document that tracks what's built, what's in progress, and what's planned.

It said `SafetyAuditor — Stub only`.

SafetyAuditor had 1,186 lines of production code, 83 tests across two visitor passes, and 10 OWASP-mapped security rules. It had been fully implemented for weeks. The Master Plan — the document that any new contributor (human or AI) reads first to understand the project — was lying.

Not just about SafetyAuditor. About six modules. About the CLI. About the entire roadmap. The code had raced ahead while the documentation stood still.

## Why This Matters More With AI

Here's the thing about human developers: they navigate by intuition as much as documentation. A senior engineer opens the `Sources/` directory, sees 14 modules, and understands the project is mature. The Master Plan saying "Stub only" is clearly wrong, and they mentally correct for it.

An AI assistant reads the Master Plan literally. If it says "Stub only," the AI treats the module as unbuilt. It might propose reimplementing something that already exists. It might skip the module entirely when making architectural decisions. It might tell you the project is 30% complete when it's actually 95% complete.

In an era where developers increasingly rely on AI for code review, architectural guidance, and implementation planning, **documentation drift isn't just misleading — it's actively dangerous.** The AI doesn't know to distrust the docs.

This is doubly true when the AI is also *writing* the code. Sessions move fast. Features land in hours that used to take days. The code accelerates, but the documentation is updated only when someone remembers — and with AI doing the heavy lifting, the human who should remember is often not reading every diff line by line.

## Building the StatusAuditor

So I built a checker that catches this automatically.

StatusAuditor reads the Master Plan's checkbox entries, parses the roadmap phases, extracts test counts from descriptions, and reads the "Last Updated" date. Then it collects actual project state from the file system: source line counts, test file counts, Package.swift targets. It cross-validates the two, and any contradiction becomes a diagnostic.

Eight rules:

| Rule | What it catches |
|------|----------------|
| `module-marked-incomplete` | Module has real code but Master Plan says `[ ]` |
| `module-marked-complete-missing` | Master Plan says `[x]` but module doesn't exist |
| `stub-description-mismatch` | Description says "Stub only" but module is implemented |
| `test-count-drift` | Documented test count differs from actual by >10% |
| `roadmap-phase-stale` | Phase marked "CURRENT" but all items checked complete |
| `last-updated-stale` | "Last Updated" date exceeds 90-day threshold |
| `phantom-module` | Package.swift target not documented in Master Plan |
| `doc-doc-conflict` | Master Plan and Implementation Checklist disagree |

The first run against quality-gate-swift found the six "Stub only" entries, a test count that said 54 when the actual count was 465, and a roadmap phase marked "CURRENT" with all items complete. All real. All the kind of drift that an AI assistant would take at face value.

## The Fix Mode

Detection alone doesn't help existing projects clean up. So StatusAuditor also implements `FixableChecker` — a new protocol in quality-gate-swift that lets checkers repair what they find.

```bash
# See what's drifted
quality-gate --check status

# Preview fixes without writing
quality-gate --check status --fix --dry-run

# Apply surgical patches (backups created automatically)
quality-gate --check status --fix

# Generate a Master Plan from scratch for new projects
quality-gate --check status --bootstrap
```

The fix mode is surgical: it patches checkboxes, test counts, phase labels, and "Last Updated" dates. It doesn't touch human-authored prose. It creates timestamped backups before modifying anything.

For projects that never had proper status documentation — or where drift is so severe that patching would be worse than starting over — `--bootstrap` generates a complete Master Plan from actual Package.swift targets and source file analysis.

## The Propagation Problem

Then I ran it against all 18 of my projects. Six had template placeholder entries (`[Feature 1]`, `[Feature 2]`) that were never customized. Several had feature-based checklists ("Docker + Redis deployment") that the auditor initially mis-flagged as missing modules.

That false-positive run was productive. It led to a `looksLikeModuleName` heuristic that distinguishes PascalCase SPM module names from feature descriptions with spaces and punctuation. I captured the false-positive patterns as real-world integration tests — snapshot fixtures from actual projects that any future heuristic change is validated against.

But the bigger realization was about propagation. Fixing quality-gate-swift's own heuristic doesn't help BusinessMath or CoverLetterWriter unless those projects are *running the latest version of the tool*.

## Always Build from Main

The solution was a reusable GitHub Actions workflow that every project calls with one line:

```yaml
jobs:
  quality-gate:
    uses: jpurnell/quality-gate-swift/.github/workflows/quality-gate-reusable.yml@main
```

The workflow clones and builds quality-gate-swift from `main` on every CI run. No version pins. No release tags to bump. No cached binaries to go stale.

When I add a new rule, fix a heuristic, or add a new checker, every consuming project picks it up on its next CI run. The bar only rises, and it rises everywhere simultaneously.

This costs ~25 seconds of build time per CI run. That's the price of continuous improvement. I'll take it over the alternative, which is 18 projects running 18 different versions of the quality gate with 18 different sets of rules.

The development-guidelines template repo — the source of truth for all my projects' workflows — now has its own CI that builds and tests quality-gate-swift weekly. If the tool breaks, the template catches it before any consuming project does.

## The Closed Loop

Here's what the system looks like now:

1. **SecurityVisitor** catches OWASP vulnerabilities in code.
2. **StatusAuditor** catches drift between documentation and code.
3. **MemoryBuilder validation** catches drift between AI memory files and code.
4. **Real-world integration tests** catch false positives before they ship.
5. **Reusable CI workflow** propagates all improvements automatically.
6. **Toolchain validation** in the template repo catches breakage upstream.

Every representation of project state — human-facing docs, AI-facing memory, code itself — is validated against reality. Nothing can silently drift.

## The Lesson

In traditional development, documentation drift is annoying but survivable. Developers learn to distrust the README and read the code instead.

In AI-assisted development, documentation drift is structural failure. The AI *is* reading the README. It *is* trusting the Master Plan. It *is* making decisions based on what the documentation says, not what the code does. And if you're moving fast with AI help, the gap between documentation and reality grows faster than it ever did with human-only development.

The fix isn't "be more disciplined about updating docs." Humans have been failing at that for decades. The fix is the same as every other quality problem: **automate the check, run it in CI, and don't let the build pass when reality and documentation disagree.**

That's what StatusAuditor does. And because it's built on the same `QualityChecker` protocol as every other checker, it was one new module, one line of CLI registration, and one reusable workflow away from running across every project I maintain.

The bar only rises.

---

**Source**: [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
**Community rules**: [github.com/jpurnell/swift-security-rules](https://github.com/jpurnell/swift-security-rules)
