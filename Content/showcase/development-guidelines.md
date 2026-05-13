---
title: development-guidelines: Systematizing Craft Across a Swift Development Practice
description: A living reference document that encodes hard-won engineering standards — from observability contracts to quality gates — into a single authoritative source that governs every Swift project in the portfolio.
date: 2026-05-13 16:39
lastModified: 2026-05-13
tags: showcase, project, development-guidelines, selfReflection
layout: ShowcaseLayout
style: deepDive
project: development-guidelines
published: true
---

# development-guidelines: Systematizing Craft Across a Swift Development Practice

> A living reference document that encodes hard-won engineering standards — from observability contracts to quality gates — into a single authoritative source that governs every Swift project in the portfolio.

## Architecture

The `development-guidelines` repository occupies an unusual position in a developer's toolkit: it is infrastructure for thought, not infrastructure for computation. Rather than shipping code, it ships *decisions* — the kind that would otherwise be reinvented inconsistently across a dozen projects or buried in the memory of a single developer.

The structural architecture of the document is deliberate. Sections are not organized by topic area alone but by *moment of use*. The `Session Start` section exists because the first five minutes of a working session are the most cognitively expensive — context must be reconstructed, scope must be established, and tools must be oriented. By placing that section first, the guidelines function as a pre-flight checklist rather than a reference manual. Developers (including the author) consult it reflexively rather than occasionally.

The five primary sections — Session Start, Development Workflow, Key Rules, Observability (Consumer-Facing Apps), and Quality Gate — reflect a philosophy that guidance should arrive precisely when it is needed:

- **Session Start** → before a single line is written
- **Development Workflow** → during the act of construction
- **Key Rules** → at decision forks where bad habits surface
- **Observability** → when consumer-facing concerns cross the threshold into production
- **Quality Gate** → before any commit is made

The `CLAUDE.md` file is worth examining as an architectural choice in its own right. Its presence signals that the guidelines were designed not only for human consumption but for AI-assisted development sessions. The document teaches a collaborator — human or AI — how to behave within the developer's system. This is a meaningful abstraction: instead of re-explaining preferences in every session, the `CLAUDE.md` externalizes them into a persistent, versioned contract.

The Observability section's scoping to "Consumer-Facing Apps" is a subtle but important architectural decision. It resists the temptation to write universal rules, acknowledging that instrumentation requirements differ categorically between internal tooling and shipped products. This kind of contextual scoping prevents over-engineering in low-stakes contexts while enforcing rigor where users are affected.

## Implementation

The 53 commits across 5 branches over roughly two months tell a story of iterative refinement rather than big-bang authorship. Documentation projects often collapse into a single burst of writing followed by drift; the branching history here suggests the author treated the guidelines with the same version discipline applied to production code — changes were isolated, reviewed against a baseline, and merged deliberately.

The 15 Claude Code sessions that contributed 5 commits and 152 messages illuminate how the guidelines themselves were stress-tested. A common pattern in documentation work is writing rules in the abstract and never confronting them under real conditions. Instead, the author used AI-assisted sessions as a live testing environment: the AI would attempt to operate within the guidelines, and friction in those sessions became signal about where the guidelines were ambiguous or incomplete.

The friction data from those sessions is instructive. The four `wrong_approach` incidents and three `buggy_code` incidents are not indictments of the tooling — they are data points about where the guidelines had gaps. When an AI collaborator repeatedly misreads intent, the most productive response is not to correct the AI but to clarify the rule. The two `file_sync_issues` and `authentication_error` incidents point toward operational concerns that may have surfaced in the Session Start or Development Workflow sections as guard-rails.

The `excessive_changes` and `user_rejected_action` incidents are particularly telling. They suggest moments where the scope of a proposed change exceeded what the guidelines implicitly authorized — a signal that the Key Rules section needed tighter constraints on change surface area. Good guidelines anticipate the failure modes of their consumers.

The nine `fully_achieved` outcomes across 15 sessions — with four `mostly_achieved` — represents a strong success rate for a living document still under active development.

## Testing Strategy

Testing a guidelines document requires a different mental model than testing software. There are no unit tests for prose. Instead, quality is validated through *application* — each session in which a developer (or an AI collaborator) attempts to follow the guidelines and encounters ambiguity is effectively a failing test case.

The Quality Gate section functions as the document's most explicit testing contract. It defines pass/fail criteria for commits, which means every commit to every governed project is an integration test of the guidelines themselves. If the Quality Gate is consistently bypassed, it fails. If it blocks legitimate work, it fails in the other direction. The commit history — 53 commits over two months — suggests the gate has been calibrated to permit steady forward progress without becoming friction.

The multi-task session type dominates the Claude Code usage (9 of 15 sessions), which is a meaningful signal. Multi-task sessions are the highest-fidelity test of guidelines coherence: they require a collaborator to maintain consistent behavior across context switches, which exposes inconsistencies between sections. Single-task and quick-question sessions, by contrast, exercise the guidelines in narrow slices.

The References section — while its contents are not enumerated here — represents an important quality mechanism: grounding the guidelines in external authority. Internal rules that cite no external sources are vulnerable to drift; rules that point to established community standards inherit their legitimacy and are harder to rationalize away under deadline pressure.

## Lessons

The development of `development-guidelines` produced transferable insights that show up across the broader Swift portfolio.

**Externalizing implicit knowledge is engineering work.** The act of writing down a rule forces precision that verbal or habitual knowledge never demands. Several Key Rules in the document likely exist because the author encountered a recurring mistake and chose to encode the fix rather than rely on memory. This discipline — treating documentation as a first-class artifact — is the same judgment that produces well-commented public APIs.

**The `CLAUDE.md` pattern scales.** Having discovered that a persistent context file meaningfully improves AI-assisted session quality, the author has a replicable mechanism for any project where AI collaboration is anticipated. Rather than starting each session from scratch, future projects can open with a trained collaborator.

**Friction is specification.** The 16 friction events across 15 sessions were not waste — they were requirements discovery. Each `wrong_approach` incident identified a gap between what the guidelines said and what a capable reader would do. This reframe — treating misunderstandings as spec failures rather than user failures — transfers directly to API design, onboarding documentation, and code review culture.

**Scope boundaries prevent entropy.** The decision to scope Observability requirements specifically to consumer-facing apps reflects a broader principle: rules without context boundaries tend to expand until they become unenforceable. The same judgment applies to architecture decision records, coding standards, and test coverage requirements in downstream projects.

**Living documents require commit discipline.** The five-branch structure on a documentation repository is not bureaucracy — it is the mechanism that keeps guidelines authoritative. When changes are proposed on branches rather than committed directly to main, they can be reviewed against the current standard before becoming the new standard. This is the same discipline that prevents production bugs; it happens to work equally well for preventing documentation drift.
