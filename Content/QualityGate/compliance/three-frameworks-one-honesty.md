---
layout: BlogPostLayout
series: quality-gate
title: "Three Frameworks, One Honesty: SOC 2, ISO 27001, HIPAA"
tags: quality-gate, compliance, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:27
lastModified: 2026-08-16
published: true
---

# Three Frameworks, One Honesty

**Putting it together: what a single AST-based gate can — and can't — tell you about SOC 2, ISO 27001, and HIPAA at once.**

---

The individual pieces — the [checkers](/QualityGate/safety-security/safety), the [mapping and report](/QualityGate/compliance/coverage-not-a-badge), [privacy-manifest](/QualityGate/compliance/privacy-manifest), [standards-watch](/QualityGate/compliance/standards-watch) — add up to something worth stepping back to see: a single quality gate that speaks all three frameworks' languages, from one set of rules, without ever claiming more than it knows.

## The same rule, three control IDs

The elegant part is how little duplication there is. One AST rule maps to many controls, because the frameworks are describing the same underlying technical safeguards in different vocabularies:

| Rule | HIPAA | SOC 2 | ISO 27001 |
|------|-------|-------|-----------|
| `security.insecure-transport` | §164.312(e) | CC6.6 | A.5.14 |
| `keychain-secrets` | §164.312(a)(2)(iv) | CC6.1 | A.8.24 |
| `logging.*` | — (audit) | CC7.2 | A.8.15 |
| `fp-safety`, `concurrency` | — | PI1.1 | — |
| the gate itself | — | CC8.1 | A.8.25 |

Write the rule once; it enforces a control in three frameworks at once. The mapping stores only control IDs, our own paraphrase, and the official citation for the copyrighted frameworks — never redistributed text.

## The shape of the coverage

Run `quality-gate compliance` and you get the honest picture across all three: **12 enforced, 2 evidence-only, 2 out-of-scope, 0 gap.** The out-of-scope controls — HIPAA's audit controls and integrity — are named, not hidden, because "we can't check this statically" is a *finding*, not something to paper over. The evidence-only ones — change management, secure development — are covered by the gate's own operation: the fact that it runs on every commit, blocks, and records its exemptions *is* the control.

## Why this is the right ceiling

A tool that claimed to make you SOC 2 compliant would be lying — compliance is an attestation about people and process over time, and no static analyzer earns it. What this earns instead is genuinely valuable: **continuous, per-commit evidence that the technical controls are actually in force**, mapped to the IDs an auditor uses, with the gaps stated plainly and the standards themselves watched for drift.

That's the whole compliance story, and it's the same story as the rest of the tool: the gate enforces what it can prove, the report shows exactly what that covers, and neither one pretends to cover what it can't. Coverage, not a badge — three frameworks, one honesty.

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
