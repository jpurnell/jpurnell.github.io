---
layout: BlogPostLayout
series: quality-gate
title: "Calibration & the Judgment Workbench: Making the Override Say Why"
tags: quality-gate, mirror, swift
link: https://github.com/jpurnell/org-judgement-system
date: 2026-08-10 10:00
lastModified: 2026-08-10
published: true
---

# Calibration & the Judgment Workbench

**The Sensor layer, up close: when someone overrides the gate, what does the system make them write down — and why does that make the organization smarter?**

---

The whole loop starts here, at the moment of judgment. When a gate fails and someone decides to ship anyway, the Sensor layer records a structured `JudgmentCalibration`. It's not a checkbox. It asks for four things, and each one is a deliberate design choice.

## What an override has to answer

- **A risk tier.** How reversible and how consequential is this? The tier determines *who* has the authority to make the call — a tier-1 typo fix and a tier-3 architectural override are not the same decision, and shouldn't require the same person.
- **A root-cause analysis** that separates the **proximate cause** (what happened) from the **root cause** (which decision process failed). "The test was flaky" is proximate; "we don't have a deterministic-testing standard for async code" is root.
- **Mandatory red-team dissent.** Even when you're right to override, you must articulate the counterargument — the strongest case *against* your own decision. This is the single most Bridgewater thing in the system: you don't get to be right without having genuinely considered being wrong.
- **Root-cause adjectives that describe processes, not people.** "Rushed," "underspecified" — never "incompetent." Learning without blame isn't softness; it's the only way people will record honest root causes instead of defensive ones.

A `DecisionResponsibilityMatrix` prevents *decision compression* — the very human tendency for one person to quietly occupy every role (architect, reviewer, override authority, final sign-off) on a quick fix. The matrix assigns distinct people to distinct responsibilities based on the risk tier.

## The workbench

None of this works if calibration is painful. The **Judgment Workbench** makes it reachable: an *inbox* of the run's advisory findings that you can acknowledge in place (acknowledging one writes the marker line at the flagged location — the override becomes a recorded, searchable fact, not a memory), and a *calibrate wizard* that walks the fields and writes the artifact through the corpus transport. Judgment becomes something a human can do at the keyboard, in the flow, without leaving the tool.

## Justification, not approval

We first imagined an approval workflow for exemptions. In practice, what matters is the **justification**, not the sign-off. "This cluster match is expected — we're mid-migration" is worth more than a rubber stamp, because the justification lets a future session judge whether the exemption still holds. That's believability-weighting in the Dalio sense: input earns its weight through recorded reasoning, not seniority. Every override is a learning event — but only if it's forced to explain itself.

---

**Source:** [github.com/jpurnell/org-judgement-system](https://github.com/jpurnell/org-judgement-system)
