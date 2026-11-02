---
title: Filling the Gap: A Curated Security Rule Library for Swift
description: When no adequate community resource existed for scanning Swift code against common security anti-patterns, the solution was to build the reference artifact itself.
date: 2026-05-12 15:57
lastModified: 2026-11-02
tags: showcase, Quality Gate, swift-security-rules, infrastructure, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Internal Infrastructure
published: false
---

# Filling the Gap: A Curated Security Rule Library for Swift

> When no adequate community resource existed for scanning Swift code against common security anti-patterns, the solution was to build the reference artifact itself.

## Problem

Swift occupies a significant share of mobile development, yet the security scanning ecosystem has treated it as an afterthought. Semgrep's community rule library is richly populated for JavaScript, Python, and Java — languages with large web-backend footprints — but Swift developers running SAST tooling against iOS and macOS codebases have had little to work with. Teams that need CWE-tagged findings for compliance reporting are left to write their own rules or go without structured coverage.

`swift-security-rules` exists to fill that gap directly. The repository is a deliberately scoped, data-only artifact: ten Semgrep-compatible YAML rule files defining twelve rule definitions that detect the security anti-patterns most likely to surface in Swift applications. The targets are consequential ones — hardcoded secrets, command injection, weak cryptography, disabled TLS validation, SQL injection, JavaScript `eval` misuse, insecure keychain accessibility, path traversal, and SSRF. Each rule carries both a CWE identifier and an OWASP Mobile Top 10 (2024) mapping, giving compliance teams the structured metadata they need to triage findings in context rather than in isolation.

The project also feeds directly into the author's own `quality-gate-swift` tool, which implements the same rule logic natively via SwiftSyntax — making this repository the canonical source of truth for what that broader quality toolchain enforces.

## Approach

The architectural decision that defines `swift-security-rules` is what it deliberately is not. There is no build system, no code, no CI pipeline generating rule files from templates. The repository is pure YAML, consumable by any SAST tool that reads Semgrep rule syntax — including Foxguard, which the README names explicitly alongside Semgrep. This zero-dependency stance means adoption friction is as low as it can be: clone or download, point your scanner at the `rules/` directory, run.

Within that constraint, the quality bar for each rule is deliberately high. Every definition includes a `last-reviewed` date and an explicit confidence level — metadata that signals to consuming teams whether a finding warrants immediate attention or further investigation. The README publishes a coverage matrix mapping each of the ten OWASP Mobile Top 10 (2024) categories to one of three honest states: strong, partial, or out of scope. That matrix is a design choice worth noting. It would have been easy to omit it and let the rules speak for themselves; instead, the documentation actively tells users what the tooling cannot do.

The README also enumerates the limits of syntactic pattern matching directly: no taint analysis, no type resolution, no `Info.plist` analysis. This transparency about the approach's ceiling is an act of professional honesty that distinguishes the project from tools that oversell their coverage. The two rule files that bundle multiple definitions — `weak-crypto` and `tls-disabled` each contain two rules — reflect a judgment that closely related patterns belong together rather than scattered across separate files, keeping the `rules/` directory navigable without fragmenting related coverage.

## Results

The repository shipped twelve rule definitions across ten YAML files, covering eight of the ten OWASP Mobile Top 10 (2024) categories with varying degrees of coverage. The rule set spans secrets detection, injection vulnerabilities (command, SQL, path traversal, SSRF), cryptographic weaknesses, insecure transport configuration, and keychain misuse — the categories most commonly cited in iOS and macOS security audits.

The project is MIT licensed and carries no build or runtime dependencies, making it immediately usable by any team already running Semgrep or Foxguard. The rules serve two distinct user populations simultaneously: developers who need fast feedback in a scanning pipeline, and security engineers who need CWE-tagged findings they can drop into a compliance report without reformatting.

The project spans from April to October 2026 — roughly six and a half months of active lifetime across two commits, which is consistent with a reference artifact that stabilized quickly: the shape of the problem was clear, the rules were authored, and the repository reached a state of reliable utility without ongoing churn.

## Judgment Calls

Several decisions here reveal the thinking behind the work. The choice to publish a coverage matrix that admits gaps — rather than simply not mentioning uncovered categories — reflects a commitment to the user's trust over the appearance of completeness. Security tooling that overstates its coverage is actively harmful; a tool that clearly marks its boundaries is one a team can actually reason about.

The decision to keep the repository data-only, rather than wrapping rules in a CLI or plugin framework, is similarly deliberate. Any abstraction layer would have introduced maintenance obligations and compatibility surface area. By staying in raw Semgrep YAML, the rules remain usable across scanner versions, forkable without ceremony, and auditable by anyone who can read a YAML file. The MIT license reinforces this: the goal is maximum reach, not ownership.

The two-rule-per-file approach for `weak-crypto` and `tls-disabled` demonstrates domain knowledge. Weak cryptographic patterns in Swift don't live in one API; they cluster. Grouping them reflects an understanding of how vulnerabilities actually appear in codebases, not just how to mechanically generate one rule per CWE.

Finally, the explicit connection to `quality-gate-swift` — documented in the README — positions this repository as infrastructure rather than a standalone experiment. The rules are canonical, not illustrative. That framing shapes how future contributors are invited to engage, and it means that improvements to this repository propagate directly into production tooling.
