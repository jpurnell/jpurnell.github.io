---
title: Filling the Gap: A Curated Security Rule Set for Swift Static Analysis
description: When few community-maintained Semgrep rules existed for Swift, one developer mapped a suite of twelve definitions to CWE identifiers and the OWASP Mobile Top 10 — giving compliance-conscious teams something concrete to run.
date: 2026-05-12 15:57
lastModified: 2026-10-30
tags: showcase, Quality Gate, swift-security-rules, infrastructure, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Internal Infrastructure
published: false
---

# Filling the Gap: A Curated Security Rule Set for Swift Static Analysis

> When few community-maintained Semgrep rules existed for Swift, one developer mapped a suite of twelve definitions to CWE identifiers and the OWASP Mobile Top 10 — giving compliance-conscious teams something concrete to run.

## Problem

Swift powers a significant share of mobile software shipped to end users, yet the static analysis ecosystem treats it as a second-class citizen. Semgrep's community rule library is deep for JavaScript, Python, and Java; for Swift, the pickings are thin. Security teams scanning iOS codebases either write their own rules from scratch or accept gaps in coverage that they would never tolerate in a web project.

`swift-security-rules` was built to address exactly this asymmetry. The project is a data-only repository — no build system, no runtime dependencies — containing ten Semgrep-compatible YAML rule files that together define twelve rule definitions targeting the most common Swift security anti-patterns: hardcoded secrets, command injection, weak cryptography, insecure transport, JavaScript evaluation, SQL injection, keychain misconfiguration, disabled TLS certificate validation, path traversal, and SSRF. Because any SAST tool that reads Semgrep rule syntax can consume the files, the rules are immediately usable by teams running either Semgrep directly or Foxguard, without any integration work beyond pointing the scanner at the `rules/` directory.

The compliance angle was a deliberate design choice. Security findings are only actionable inside organizations when they can be tied to a recognized taxonomy. Every rule in the set carries a CWE identifier and an OWASP Mobile Top 10 (2024) mapping, along with a `last-reviewed` date and a confidence level, giving security teams the metadata they need to justify findings in audit reports and vulnerability trackers.

## Approach

The architecture is intentionally minimal: a flat `rules/` directory of YAML files, a README that doubles as documentation, and a coverage matrix that is honest about what the rules can and cannot do.

Two rules — `weak-crypto` and `tls-disabled` — each contain two definitions rather than one, reflecting that both anti-patterns manifest in multiple distinct code shapes that a single pattern cannot catch. This was a deliberate choice to keep rule files semantically coherent (one file per concern) while still providing adequate detection breadth.

The README's coverage matrix maps each of the ten OWASP Mobile Top 10 categories to one of three states: strong, partial, or out of scope. This framing is unusual and worth noting — most rule sets simply list what they cover. Acknowledging partial coverage and explicit out-of-scope categories signals an understanding that syntactic pattern matching has structural limits: no taint analysis, no type resolution, no Info.plist analysis. Rather than overstate what the rules can detect, the README documents these boundaries directly, which is more useful to a security engineer evaluating the tool than a list of covered categories alone would be.

The project also names a downstream consumer explicitly: the author's own `quality-gate-swift` tool, which implements the same rule logic using SwiftSyntax. This positions `swift-security-rules` as the canonical, shareable expression of a rule set that already has a proven implementation, rather than as speculative or untested patterns.

## Results

The project shipped ten rule files and twelve rule definitions spanning the full breadth of common Swift security anti-patterns. Every rule carries CWE and OWASP Mobile Top 10 (2024) metadata with confidence levels and review dates — metadata that is rare in community rule contributions. The coverage matrix in the README gives teams a clear picture of where the rules provide strong detection, where coverage is partial, and where the approach is structurally unsuited to the problem.

The repository is MIT licensed with no dependencies, making adoption frictionless for any team already running Semgrep or a compatible scanner. The explicit documentation of limits — particularly the acknowledgment that syntactic matching cannot replace taint analysis or type resolution — reduces the risk of false confidence in coverage.

The project spans a development window from April to October 2026, with two commits representing an initial publication and a subsequent revision, consistent with a focused, defined-scope deliverable rather than an ongoing feature project.

## Judgment Calls

Several decisions here reflect a kind of editorial discipline that is easy to undervalue.

**Choosing data over tooling.** The format is pure YAML — no CLI wrapper, no package, no installer. This is a real tradeoff: it means no out-of-the-box user experience, but it also means zero integration friction for any Semgrep-compatible scanner and a repository that cannot rot due to language runtime changes. For a security rule set whose value is longevity and portability, this was the right call.

**Splitting by concern, not by pattern count.** The decision to give `weak-crypto` and `tls-disabled` two definitions each — while keeping them in a single file per concern — shows an understanding that the organizational unit should be the security concept, not the pattern. A different developer might have created separate files for each definition, or collapsed everything into fewer files. The chosen structure makes the coverage easier to reason about.

**Writing the README as a compliance artifact.** The CWE mappings, OWASP category matrix, confidence levels, and `last-reviewed` dates are not decorative. They are the specific metadata that makes a finding usable in a compliance workflow. Including them in the rule definitions themselves — rather than in external documentation that can drift out of sync — means every finding produced by the rules carries its own compliance context inline.

**Naming the limits.** The explicit statement in the README that these rules cannot do taint analysis, type resolution, or Info.plist analysis is an act of intellectual honesty that most rule-set authors skip. For a security team deciding how much to rely on these rules, that disclaimer is more valuable than an inflated list of capabilities.
