---
layout: BlogPostLayout
series: quality-gate
title: "Coverage, Not a Compliance Badge"
tags: quality-gate, compliance, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-08-13 10:00
lastModified: 2026-08-13
published: true
---

# Coverage, Not a Compliance Badge

**SOC 2, ISO 27001, and HIPAA are natural things to want a quality gate to check. The trap is a green "compliant" badge — so quality-gate-swift refuses to print one.**

---

It started as a reasonable question: *do ISO 27001, SOC 2, and HIPAA make sense as quality-gate checkers?* They do — but only if you're honest about what a static analyzer can actually see, and the honesty is the entire design.

## The trap

A checker that prints `SOC 2: PASS ✓` would be the most dangerous thing this tool ever emitted. These frameworks are overwhelmingly *organizational* — risk registers, access reviews, incident response, vendor management — audited by people over a period of time. A static analyzer sees maybe 5–15% of any of them: the technical safeguards that live in source code. Asserting compliance from that thin slice manufactures false assurance, which is the exact inverse of the [precision principle](/QualityGate/gate/a-gate-not-a-linter) the whole tool is built on — and a real legal-liability risk.

So the framing is **not** "compliance checkers." It's **technical-control checkers that produce audit evidence, mapped to specific control IDs, with an explicit scope boundary.** The tool reports *coverage*, never *compliance*.

## What it actually enforces

Much of it you already enforce without labels. `security.insecure-transport` *is* HIPAA §164.312(e) and SOC 2 CC6.6 and ISO A.8.24. [`keychain-secrets`](/QualityGate/safety-security/keychain-secrets) is HIPAA §164.312(a)(2)(iv) and SOC 2 CC6.1. Your fp-safety and concurrency checkers are SOC 2 Processing Integrity. And the gate itself — running on every commit, blocking, recording justified exemptions — is a SOC 2 change-management control producing per-commit audit evidence.

A `control-mapping` checker keeps the mapping honest, the same way [dependency-audit](/QualityGate/project-health/dependency-audit) catches hallucinated imports: a mapping to a rule that doesn't exist, or a control no catalog defines, is an error. The mapping can't drift from reality.

## The honest report

`quality-gate compliance` renders a coverage matrix across HIPAA §164.312, SOC 2, and ISO 27001 — every control in one of four honest states:

```
[enforced]     — a real rule enforces it (listed)
[evidence-only]— the gate's own operation is the evidence
[out-of-scope] — beyond static analysis; requires process evidence
[gap]          — checkable but not yet mapped
```

Every rendering leads with the disclaimer: *this is technical-control coverage by static analysis, NOT an assertion of compliance.* Out-of-scope controls — HIPAA's audit controls, integrity — are **listed, never hidden.** On the shipped slice: 12 enforced, 2 evidence-only, 2 out-of-scope. That refusal to overclaim is the trust anchor and the liability shield, both.

The tool never tells you you're compliant. It shows you exactly what static analysis enforces, evidences, and cannot reach — and won't blur the line. That honesty is what makes it useful to an auditor instead of a hazard.

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
