---
title: development-guidelines: A Versioned Rulebook That Enforces Itself
description: A vendorable, AI-readable specification for Design-First TDD in Swift — where every rule that can be checked has a quality gate behind it, and every rule that failed in practice carries its own evidence.
date: 2026-05-13 16:39
lastModified: 2026-10-30
tags: showcase, project, infrastructure, Quality Gate, development-guidelines, selfReflection
layout: ShowcaseLayout
style: deepDive
project: Internal Infrastructure
published: true
---

# development-guidelines: A Versioned Rulebook That Enforces Itself

> A vendorable, AI-readable specification for Design-First TDD in Swift — where every rule that can be checked has a quality gate behind it, and every rule that failed in practice carries its own evidence.

## Overview

Most development guidelines are advisory documents — they tell teams what to do and then trust that humans remember to do it. `development-guidelines` takes a different position: rules that can be mechanically verified *should* be mechanically verified, and rules that have failed in practice should say so, plainly, alongside the record of that failure.

The project is a versioned, vendorable rulebook for AI-assisted Swift development. It defines a workflow called Design-First TDD — the practice of writing architectural proposals before writing code — and pairs that workflow with a zero-tolerance quality gate for warnings. Alongside the prose rules, it ships `setup.swift`, a collection of skills, and hooks that install the process into a new Swift project on its first day rather than retrofitting it later.

Three audiences drive the design. First, developers starting or adopting a Swift project who want process in place before the first commit, not bolted on after technical debt accumulates. Second, AI assistants — Claude Code specifically — that read the rulebook at session start and operate within its constraints. Third, the author's own packages, which are the first and most demanding consumers: if a rule can't be followed in practice, the package that breaks it becomes the evidence for revising or removing it.

The project shipped its first release as `v2.0.0` and has since iterated through seventeen versioned releases up to `v2.6.2`, spanning roughly seven and a half months of active development across 167 commits on eight branches. That release cadence — steady minor releases with occasional patches — reflects a living document under continuous pressure from real consumers.

## Architecture

The central architectural decision is vendoring over cloning. ADR-013 establishes that each consuming project owns exactly one copy of the guidelines tree, and updates are replacements rather than merges. This is a deliberate rejection of the symlink or submodule patterns that introduce ambiguity about which version of the rules is active in a given project. When a project vendor-copies the guidelines at `v2.4.1` and later updates to `v2.6.2`, the old tree is deleted and the new tree written in its place. There is no merge history, no conflict resolution, no uncertainty about provenance.

The document's own `CLAUDE.md` organizes the rules into a structure that an AI assistant can navigate at session start:

- **Session Start** — what to read before writing any code
- **Development Workflow** — the ordered steps Design-First TDD requires
- **Key Rules** — the specific constraints with their rationale
- **Observability (Consumer-Facing Apps)** — instrumentation requirements
- **Quality Gate** — the zero-tolerance checker definitions
- **References** — ADR index and related documents

This structure is not incidental. Because Claude Code reads `CLAUDE.md` at the beginning of each session, the document's organization is effectively an API — the ordering of sections determines what an AI assistant learns first. Session Start appears before Development Workflow, which appears before Key Rules, because the intended reading order is also the intended operating order.

The quality gate is a first-class architectural component, not an appendix. Every rule that admits mechanical verification has a corresponding checker. The zero-tolerance posture on warnings is representative: it is not a preference or a style guide note. It is a gate. A build that emits warnings does not pass. This distinction — enforced versus advisory — is the sharpest edge of the project's design philosophy.

## Implementation

The most interesting implementation challenge is one that most documentation projects never confront: how do you know whether your rules are followable? The answer embedded in `development-guidelines` is empirical rather than theoretical. The author's own packages are designated as the first consumers, and failures in those packages become evidence recorded in the document itself.

This creates an unusual feedback loop. A rule is written, adopted in a consuming package, and either holds or breaks under real conditions. If it breaks, the failure is not quietly corrected — it is recorded alongside the rule. The document carries its own evidence of what has been tried and what the outcome was. Over seventeen releases, this cycle has produced a rulebook that documents not just what the author believes is correct but what has been verified to work in practice.

The `setup.swift` script represents the other implementation pole: not rules-as-prose but rules-as-code. Rather than telling a developer to create certain directories, configure certain hooks, and install certain skills, `setup.swift` does those things. The first day of a new project is automated into compliance before a human has had an opportunity to skip a step.

The Design-First workflow — writing an architectural proposal before writing implementation — is enforced through hook scaffolding. The hooks create checkpoints where the workflow can verify that proposal documents exist before certain phases of development proceed. This is the quality gate philosophy applied to process rather than to build output.

```swift
// The kind of enforcement setup.swift establishes:
// a hook fires before a commit, checks for required artifacts,
// and exits non-zero if the process has been skipped.
// The rule is not a suggestion at that point — it is a gate.
```

The versioning scheme itself reflects implementation care. The presence of `v2.5.0-beta.1` in the release history shows that major rule changes are staged through pre-release versions before being locked into consuming projects — a responsible approach when the consumers are active packages rather than hypothetical future users.

## Testing Strategy

Testing a guidelines document requires inverting the usual relationship between specification and test. Normally a test suite verifies that code conforms to a spec. Here, the consuming packages *are* the test suite — each package that adopts the guidelines and continues to build cleanly is evidence that the rules are internally consistent and followable.

The quality gate provides a formal testing surface. Because warnings are zero-tolerance, any consuming package that emits a warning under the guidelines is a test failure — not of the package, but of the guidelines' completeness. If a rule's intent cannot be expressed in code that produces no warnings, the rule needs revision.

The ADR record functions as a regression suite for architectural decisions. Each ADR captures the context, the decision, and the consequences. When a later decision revisits the same terrain, the earlier ADR constrains the solution space. This prevents the document from oscillating between contradictory positions across releases.

The practice of recording failed rules alongside their failures is a form of negative testing. A rules document that has never recorded a failure is a document that has never been seriously tested. By the time the project reached `v2.6.2`, its failure record is part of its credibility.

## Lessons

The most transferable lesson is the distinction between advisory and enforced. In subsequent projects, this shaped how Purnell frames any process requirement: if it matters enough to write down, it matters enough to check automatically. The corollary — if it cannot be checked automatically, its importance should be stated honestly rather than implied — has influenced how he documents constraints that genuinely require human judgment.

The vendoring pattern from ADR-013 transferred directly to how he thinks about shared configuration in general. The instinct to reach for a symlink or a submodule is strong, but the vendoring model's clarity about ownership — one project, one copy, updates are replacements — eliminates an entire category of drift and ambiguity that shared-reference approaches introduce.

The design of `CLAUDE.md` as a session-start API for AI assistants influenced how he structures documentation in AI-assisted projects more broadly. The ordering of a document is not neutral when the reader is a language model that will act on what it reads in the sequence it reads it. Structure becomes interface.

Finally, the practice of using his own packages as the first consumers of the guidelines imposed a productive discipline: no rule could survive that he was not willing to live under himself. Across 167 commits and seventeen releases, that constraint kept the document grounded in the concrete rather than drifting toward the aspirational.
