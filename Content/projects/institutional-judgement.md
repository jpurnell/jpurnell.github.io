---
layout: BlogPostLayout
tags: project, swift, apple, development, tooling
image:
imageDescription:
title: Building an Institutional Judgment System: How We Taught an Organization to Learn from Its Own Decisions
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-04-26 18:00
lastModified: 2026-04-26
published: true
---

# Building an Institutional Judgment System: How We Taught an Organization to Learn from Its Own Decisions

Every software team makes judgment calls. A quality gate flags a warning, and someone decides to ship anyway. A safety check fails, and a senior engineer overrides it with "we'll fix it next sprint." These decisions — the overrides, the exemptions, the calculated risks — are where institutional knowledge lives and dies.

The problem is that most organizations treat these moments as noise. The override happens, the build ships, and the reasoning evaporates. Three months later, a different engineer faces the same trade-off with zero context about what happened last time.

We built a system to fix that.

## The Institutional Judgment System

The Institutional Judgment System (IJS) is a four-layer feedback loop built in Swift that captures override decisions, analyzes them statistically, detects recurring patterns, and feeds that institutional memory back into every subsequent quality gate run.

It's not a linter. It's not a policy engine. It's an organizational immune system.

### The Core Insight

Ray Dalio's *Principles* describes a five-step process for organizational learning: Goals, Problems, Diagnosis, Design, Doing. Most engineering tools stop at Problems — they tell you something is wrong. The IJS maps every override and failure through the full five-step model, tracking not just *what* went wrong but *which thinking capability* broke down.

When an engineer overrides a safety check, the IJS requires:
- A **root cause analysis** that separates the proximate cause (what happened) from the root cause (what decision process failed)
- A **risk tier** that determines who has authority to make this call
- **Mandatory red-team dissent** — even if you're right to override, you must articulate the counterargument

This isn't bureaucracy. It's calibration.

## Four Layers, One Feedback Loop

### Layer 1: Sensor

The Sensor layer captures the raw data of institutional decisions. When a quality gate runs and someone overrides a failure, the system records a `JudgmentCalibration` — a structured artifact that includes the override reasoning, the risk tier, the root cause analysis, and the red-team dissent.

Root cause adjectives describe *processes*, not people. "Rushed" or "underspecified" — never "incompetent." This is a deliberate design choice that enables institutional learning without blame assignment.

The `DecisionResponsibilityMatrix` prevents what we call "decision compression" — the tendency for one person to occupy every role (architect, reviewer, override authority, final sign-off) on a quick fix. The matrix assigns distinct individuals to distinct responsibilities based on risk tier.

### Layer 2: Aggregator

The Aggregator layer collects telemetry into a persistent corpus. A `TelemetryWriter` actor handles concurrent file I/O, writing metadata, calibrations, and daily snapshots to a deterministic directory hierarchy organized by project, date, and timestamp.

Configuration lives in `.quality-gate.yml` alongside the existing quality gate config. The system auto-detects CI environments (GitHub Actions, Jenkins, etc.) and adjusts behavior accordingly.

The key design constraint: every write is lossless. ISO 8601 dates, sorted JSON keys, human-readable paths. The corpus is designed to be inspected by humans, not just consumed by machines.

### Layer 3: Refiner

This is where the system starts thinking. The Refiner layer performs statistical analysis over the corpus to generate an `InstitutionalPulse` — a weekly summary of organizational learning.

The Pulse contains:
- **Trend analyses** with confidence intervals (via BusinessMath's statistical library)
- **Statistical anomalies** detected at 90th, 95th, and 99th percentile thresholds using z-scores
- **Violation clusters** — recurring patterns of the same rule being overridden across projects
- **Calibration summaries** — human-readable bullet points of the week's key decisions

Every statistical result carries a `StatisticalValidity` classification based on the Central Limit Theorem: fewer than 3 samples is "insufficient," 3-29 is "preliminary," and 30+ is "valid." This prevents the system from over-reacting to small sample sizes — a principle borrowed from how NASA's Artemis II program handles sensor data.

### Layer 4: PolicyDiscovery

The final layer closes the loop. When a new quality gate run happens, the `PolicyDiscoveryAuditor` compares the current failures against the most recent Pulse. It asks three questions:

1. **Cluster match:** Does this failure match a known violation cluster? If the same rule has been failing and getting overridden for weeks, that's institutional drift.
2. **Anomaly pattern:** Does this checker's failure rate deviate from the statistical baseline? A sudden spike in safety violations might indicate a systemic issue, not a one-off.
3. **Unaddressed policy:** Was a policy change proposed in response to this pattern, and has it still not been implemented? Unaddressed proposals are institutional debt.

Each match produces a `ConsistencyFinding` with a risk weight, and the `ConsistencyScorer` computes an overall consistency score from 1.0 (fully consistent with institutional history) downward. The scoring uses validity-aware discounting — findings based on 3 data points get 0.25x the deduction weight of findings based on 30+.

The result: every quality gate run now includes an institutional consistency score. A score of 0.85 means "you're mostly consistent with what the organization has been doing." A score of 0.4 means "this looks like drift — the Pulse shows recurring patterns you should know about."

## The Ethical Context Layer

Building the IJS raised an obvious question: if we can detect institutional patterns in override decisions, can we detect ethical patterns in the code itself?

The `ContextAuditor` is a SwiftSyntax-based checker that scans for four categories of ethical risk:

- **Missing consent guards** — Accessing location, contacts, camera, health data, calendar, or photos without a prior consent check in the enclosing function
- **Unguarded analytics** — Tracking user behavior without an opt-out guard
- **Automated decisions without review** — Machine learning predictions feeding directly into deny/block/suspend actions without a human review step
- **Surveillance patterns** — Background location tracking without a disclosure annotation

Each rule can be suppressed with a justification annotation (`// CONSENT: User opted in via Settings > Privacy`). The requirement for justification text is intentional — silent suppression is not allowed.

The ContextAuditor is designed as a separate, easily-disableable module. If its findings are consistently ignored, the correct response is to disable it — not force compliance. An ignored checker is worse than no checker because it trains people to skip gate output entirely. This philosophy — advisory tools should earn their keep or get removed — runs through the entire system.

## What We Learned Building It

### 1. Memory files beat documentation

The IJS generates `.claude/memory` files automatically via a `MemoryBuilder` tool. Six extractors pull project profile, architecture, conventions, active work, ADR summaries, and environment info into structured memory files that Claude Code loads at session start. Generated files are tagged with frontmatter so they can be safely regenerated without destroying manually-written memory.

This turned out to be more valuable than traditional documentation. Documentation tells you what the code does. Memory tells the AI what it needs to know to help you effectively.

### 2. Statistical validity changes everything

The single most important design decision was carrying `StatisticalValidity` through every analysis result. Early in development, the system would flag "anomalies" based on 2 data points — statistically meaningless noise that eroded trust. Adding CLT-based validity classification (insufficient/preliminary/valid) and discounting scores by validity eliminated false signals and made the output trustworthy.

### 3. Exemptions need justification, not approval

We initially considered an approval workflow for consistency exemptions. In practice, what matters is the *justification*, not the *approval*. A documented exemption saying "This cluster match is expected because we're mid-migration" is more valuable than a rubber-stamped approval. The justification enables future sessions to evaluate whether the exemption is still valid.

### 4. The five-step model works for software decisions

Mapping overrides to Dalio's five-step model (Goals, Problems, Diagnosis, Design, Doing) revealed patterns we wouldn't have seen otherwise. Teams that consistently fail at the "Diagnosis" stage — they see the problem but don't correctly identify the root cause — need different interventions than teams failing at "Design" — they diagnose correctly but choose poor solutions.

This taxonomy turns vague "we need to do better" conversations into specific "our diagnosis capability needs calibration" actions.

## By the Numbers

| Metric | Count |
|--------|-------|
| IJS types (Sensor + Aggregator + Refiner + PolicyDiscovery) | 33 |
| IJS tests | 258 |
| quality-gate-swift checkers | 17 |
| quality-gate-swift tests | 614 |
| MemoryBuilder extractors | 6 |
| ContextAuditor ethical rules | 4 |

The entire IJS — from Sensor to PolicyDiscovery — was built using strict test-driven development. Tests were written first, confirmed failing, then implementation was written to make them pass. Every phase followed the same cycle: Design → RED → GREEN → REFACTOR → DOCUMENT → VERIFY.

## What's Next

The IJS infrastructure is complete. The feedback loop runs: quality gate → telemetry → corpus → Pulse → consistency audit → enriched gate output. The next questions are operational:

- How do teams respond when they see a consistency score of 0.6?
- Do violation clusters actually shrink over time when made visible?
- Does mandatory red-team dissent improve override quality, or does it become rote?

These are human questions, not engineering ones. The system provides the data. The organization provides the judgment.

That's the point. The Institutional Judgment System doesn't replace human judgment — it makes it visible, trackable, and improvable. Every override is a learning event. Every Pulse is a progress report. Every consistency score is a mirror.

The question was never "how do we prevent bad decisions?" It was "how do we help an organization learn from the decisions it's already making?"

---

*Built with Swift 6, strict concurrency, SwiftSyntax, BusinessMath, and a deep suspicion of silent overrides.*
