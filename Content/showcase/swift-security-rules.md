---
title: Swift Security Rules: Semgrep-Compatible YAML Rules for Swift Static Analysis
description: A data-only repository of 12 Semgrep rule definitions covering 10 security anti-patterns in Swift, each tagged with CWE identifiers and OWASP Mobile Top 10 (2024) mappings.
date: 2026-05-12 15:57
lastModified: 2026-11-10
tags: showcase, Quality Gate, swift-security-rules, infrastructure, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Internal Infrastructure
published: false
---

# Swift Security Rules: Semgrep-Compatible YAML Rules for Swift Static Analysis

> A data-only repository of 12 Semgrep rule definitions covering 10 security anti-patterns in Swift, each tagged with CWE identifiers and OWASP Mobile Top 10 (2024) mappings.

## Motivation

Semgrep's public registry has extensive rule coverage for JavaScript, Python, and Java, but very little for Swift. If you want to run a SAST scan against a Swift codebase and get CWE-tagged findings you can cite in a compliance report, you mostly have to write the rules yourself. That's what this repository is: the rules I wrote, published as a standalone data package so other teams can use them directly.

The project also feeds my own `quality-gate-swift` tool, which implements the same detection patterns using SwiftSyntax. Having the rules defined here in a canonical, tool-agnostic format keeps that implementation honest and gives it a reference point to stay aligned with.

## Approach

The repository contains no code and no build system — just YAML. The ten files in `rules/` map to ten categories of security anti-pattern: secrets in source, command injection, weak cryptography, insecure transport, JavaScript `eval` via `WKWebView`, SQL injection, keychain accessibility attributes, disabled TLS validation, path traversal, and SSRF. Two of those files (`weak-crypto` and `tls-disabled`) each contain two rule definitions, bringing the total to 12.

Every rule carries:

- A CWE identifier
- An OWASP Mobile Top 10 (2024) category
- A `last-reviewed` date
- A confidence level

The README includes a coverage matrix that maps each of the ten OWASP categories to either strong coverage, partial coverage, or out-of-scope, and explicitly lists what syntactic pattern matching cannot do: no taint tracking, no type resolution, no `Info.plist` analysis.

The file format is Semgrep rule syntax, which means anything that reads Semgrep YAML — including Foxguard, which the README names alongside Semgrep — can consume the files without modification.

## Results

The repository is in active state across a roughly six-month window (April to October 2026), with 2 commits from a single contributor on one branch. It ships 10 rule files and 12 rule definitions covering the full OWASP Mobile Top 10 (2024) range to the extent syntactic analysis allows. The README documents contribution steps for external collaborators and states the gap the project addresses relative to existing community rule sets.

## Decisions

**Data-only, no build system.** Keeping the repository as pure YAML means any SAST tool that speaks Semgrep syntax can use it. Adding a build or validation layer would create a dependency and a maintenance surface. The tradeoff is that correctness of the YAML is not automatically verified on commit.

**CWE and OWASP metadata on every rule.** The stated reason in the README is compliance reporting: teams that need to map findings to a framework can do so without manual cross-referencing. This adds authoring overhead per rule but makes the output directly usable in that context.

**Coverage matrix with explicit gaps.** The README names which OWASP categories get strong coverage, which get partial, and which are out of scope. Stating limits explicitly rather than leaving them implicit is a deliberate choice; it tells a consumer what they cannot rely on this rule set to catch.

**What is unfinished.** Syntactic pattern matching has known limits that the README names directly: no taint analysis means multi-step data flows are not detected; no type resolution means rules can produce false positives when different types share method names; no `Info.plist` analysis leaves transport security misconfigurations outside the scope of these rules. These are not bugs to fix so much as boundaries of the approach — taint analysis would require a different tool architecture entirely.
