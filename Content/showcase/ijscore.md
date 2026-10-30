---
title: IJSCore: Encoding Institutional Judgment as Enforceable Tooling
description: A Swift library that transforms quality gate telemetry and manual overrides into a self-reinforcing organizational memory, preventing AI-assisted development teams from repeatedly rediscovering the same hard lessons.
date: 2026-05-12 15:57
lastModified: 2026-10-30
tags: showcase, project, infrastructure, org-judgement, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Internal Infrastructure
published: true
---

# IJSCore: Encoding Institutional Judgment as Enforceable Tooling

> A Swift library that transforms quality gate telemetry and manual overrides into a self-reinforcing organizational memory, preventing AI-assisted development teams from repeatedly rediscovering the same hard lessons.

## Problem

Every development organization that leans on AI-assisted tooling faces a quiet, compounding failure mode: each new session starts naive. The AI agent — or the junior developer, or the onboarding engineer — has no memory of why a particular shortcut burned the team last quarter, why a specific override was rejected, or what the accumulated institutional logic behind a quality gate actually is. The result is what IJSCore's own MASTER_PLAN.md names directly: *contextual naivety* and *confident wrongness*.

IJSCore was built to close that loop. It sits inside the `quality-gate-swift` ecosystem and acts as the memory and reasoning layer for quality gate decisions. When a gate fires, when a Decision Owner approves an exception, when a Red-Team Reviewer surfaces a failure mode — those events don't evaporate. They become calibration data. That data is refined into Institutional Pulse documents, which feed back into the start of every subsequent development session, raising the floor of what the system knows before a single line of code is written.

The project serves four distinct roles simultaneously: Decision Owners who carry formal authority over high-risk artifacts, Practitioners producing code through the broader ecosystem, Red-Team Reviewers tasked with adversarial challenge, and AI agents that must recover institutional context before beginning work. Serving all four with the same artifact format — and keeping that format portable enough for any LLM, cloud or local — was a non-negotiable constraint from the start.

## Approach

Jpurnell made a foundational architectural bet early: all artifacts are Markdown and JSON. No proprietary database, no vendor-locked schema, no dependency on a specific cloud provider's embedding store. The entire Institutional Pulse lives in files that any text-based LLM can read directly. This is not a limitation — it's the portability guarantee that makes the closed loop possible across heterogeneous environments.

The dependency graph reflects considered choices. `quality-gate-corpus-kit` and `quality-gate-types` establish the shared vocabulary for gate events and telemetry. `BusinessMath` handles the believability-weighted feedback calculations that underpin the Dalio-inspired scoring model. `Yams` provides YAML serialization for human-readable configuration artifacts that practitioners and Decision Owners are expected to read and edit directly. `swift-argument-parser` powers the `ijs-telemetry` command-line target, making the system scriptable from CI pipelines without ceremony. `swift-docc-plugin` signals that documentation is treated as a first-class deliverable, not an afterthought.

The theoretical foundations are explicit and intentional. Wingard's five-dimension Judgment System Audit and Dalio's believability-weighted feedback loops are not inspiration — they are encoded directly into the tooling's logic. This is the project's core differentiator: *Judgment as Code*. The system doesn't just log decisions; it weights them by the credibility of the decision-maker and uses that weighting to calibrate future gates.

The CLAUDE.md present in the repository is itself an artifact of the system's philosophy — a structured context document that ensures any agent or developer entering the codebase begins with institutional orientation rather than a blank slate.

The project targets macOS and is authored against Swift Tools version 6.2, keeping it current with the strict concurrency model that Swift 6 enforces — a meaningful choice for a system designed to process telemetry events that may arrive concurrently from multiple gate sources.

## Results

IJSCore reached its 1.1.0 release across 59 commits over a six-month span, from late April through late October 2026. The repository carries three distinct targets — `IJSCore` (the library), `ijs-telemetry` (the CLI), and `IJSCoreTests` (the test suite) — reflecting a clean separation between the embeddable core, the operator-facing interface, and the verification layer. Five branches indicate active parallel development across feature work, consistent with a project still in focused expansion.

The 1.1.0 designation suggests a stable public API has been established and at least one meaningful iteration beyond the initial release has shipped — the system has moved from proving the concept to refining the contract.

## Judgment Calls

The most revealing decision in IJSCore is the choice to encode *specific theoretical frameworks* — Wingard and Dalio — rather than inventing a proprietary scoring model. This is an act of epistemic humility with a practical payoff: the system's judgment criteria are auditable by anyone who has read the source material, which means Decision Owners can contest the weighting and Red-Team Reviewers have a shared vocabulary for challenge. The framework isn't hidden inside an opaque algorithm; it's named, documented, and enforceable.

The file-based portability constraint deserves equal attention. A database would have been faster to query and easier to index. Jpurnell chose files anyway — specifically because the target users include AI agents running in environments where a database connection cannot be assumed. The artifact format was designed around the weakest consumer in the system, which is the correct direction to optimize.

The `ijs-telemetry` CLI target as a discrete artifact, rather than a script bolted onto the library, reflects an understanding that operators need a stable, scriptable surface they can invoke from CI without depending on the library's internal API. Keeping those contracts separate means the library can evolve without breaking pipeline integrations.

Finally, the CLAUDE.md file in the repository root is the system eating its own cooking: a structured context document that instantiates the very pattern IJSCore exists to enforce — begin every session with institutional orientation, not a blank slate. The meta-commentary is intentional and clean.
