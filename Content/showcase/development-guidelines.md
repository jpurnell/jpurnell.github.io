---
title: development-guidelines: A Versioned Rulebook for AI-Assisted Swift Development
description: A self-contained, vendorable set of rules, scaffolding, and quality-gate tooling that installs a Design-First TDD workflow into a Swift project before the first line of production code is written.
date: 2026-05-13 16:39
lastModified: 2026-11-10
tags: showcase, project, infrastructure, Quality Gate, development-guidelines, selfReflection
layout: ShowcaseLayout
style: deepDive
project: Internal Infrastructure
published: true
---

# development-guidelines: A Versioned Rulebook for AI-Assisted Swift Development

> A self-contained, vendorable set of rules, scaffolding, and quality-gate tooling that installs a Design-First TDD workflow into a Swift project before the first line of production code is written.

## Overview

`development-guidelines` is a rulebook—not a framework, not a library—that describes exactly how I want a Swift project to behave from day one. It covers the full lifecycle: how sessions start (both human and AI), how code gets written (Design-First TDD), what a quality gate checks before a commit lands, and what scaffolding (`setup.swift`, skills, hooks) wires all of that into a new or existing project.

There are three audiences. First, me, when I start a new package and want the process in place before the first commit rather than bolted on after the first few hundred lines. Second, Claude Code, which reads `CLAUDE.md` at session start and uses the rules to know what is and is not acceptable in this codebase. Third, my own packages downstream, which act as the live test of whether any given rule is actually followable in practice.

The project exists because advisory style guides drift. Rules that nobody checks stop being rules. This repository treats enforcement as a first-class concern: every rule that can be mechanically verified has a quality-gate checker behind it. Rules that turned out to be wrong in practice are recorded in the document alongside the failure, so the document carries its own evidence of what was tried and what broke.

## Architecture

The repository is structured around a small number of concerns that stay separated.

**The rulebook itself** lives as markdown, with `CLAUDE.md` as the entry point for AI sessions and a set of referenced documents covering the development workflow, key rules, observability requirements for consumer-facing apps, and the quality gate specification. The architecture sections in `CLAUDE.md` map directly to those concerns: Session Start, Development Workflow, Key Rules, Observability, Quality Gate, References.

**Vendoring over cloning** is the central structural decision, captured in ADR-013. Each consuming project owns its own copy of the guidelines tree. An update is a wholesale replacement, not a merge. This eliminates the question of which rules apply in a given project: the copy in the tree is authoritative, there is no remote to reconcile with, and the history of that copy is the history of when rules changed in that project. The tradeoff is that propagating a rule change to ten projects means ten replacements, but that cost is intentional—it forces a deliberate decision at each site rather than a silent pull.

**The quality gate** is a zero-tolerance warning policy enforced by a checker that runs before commits land. Zero tolerance here means what it says: warnings are treated as errors. The gate does not distinguish between a warning that "matters" and one that does not, because that distinction requires judgment at review time and review-time judgment is the thing the gate is replacing.

**`setup.swift`** is the scaffolding entry point. It takes an empty or new project and installs the hooks, skills, and configuration that the rules require, so the project is compliant from the first commit rather than from whenever a developer remembers to add things.

## Implementation

The 167 commits across 17 releases (v2.0.0 through v2.6.2) show a project that revised its own rules repeatedly as downstream packages exercised them.

The most important pattern in the rulebook is Design-First TDD: the design document for a component is written before any code, the tests are written against the design, and the implementation follows the tests. This ordering matters because it prevents the common failure mode where tests are written to describe code that already exists rather than to constrain code that is about to be written. The rules specify what a design document must contain and what constitutes a passing test before the implementation phase begins.

The skills system gives Claude Code named, invokable procedures. Rather than describing a workflow in prose and hoping the AI infers the steps, a skill names the procedure and lists its preconditions, steps, and postconditions. Session start is itself a skill: when Claude Code opens a session, it reads `CLAUDE.md`, invokes the session-start skill, and arrives at a known state before any user instruction is processed.

The hooks integrate the quality gate into the commit lifecycle. The gate runs on every commit attempt, not on a schedule, so a warning cannot land in the tree and wait for a CI run to surface it.

One pattern that recurred across the release history is that rules which seem precise in prose turn out to be ambiguous when a checker tries to implement them. The resolution in every case was to revise the rule to match what the checker could actually verify, then record the original formulation and the reason for the change. This kept the document and the gate synchronized rather than letting them diverge into separate sources of truth.

## Testing Strategy

The downstream packages are the primary test harness. Each package that vendors these guidelines and runs the quality gate on its own commits is exercising the rules against real code. When a rule causes a false positive or turns out to be unenforceable, it surfaces as a failure in a real project, not a hypothetical.

The zero-warning policy applies to the guidelines repository itself, which is enforced by the same gate the rules describe. This creates a minimal feedback loop: the rules cannot specify a gate that the rules repository itself fails to pass.

The beta release track (visible in v2.5.0-beta.1 preceding v2.5.0) provided a path for testing rule changes in downstream packages before promoting them to a stable release. A consuming project could vendor the beta, run its own gate, and report whether the new rules were followable before the change was finalized.

## Lessons

**Enforcement changes what rules you write.** When a rule has no checker, you write rules that sound good. When a rule needs a checker, you write rules that can be mechanically verified. The second kind of rule is more constrained but more honest about what it actually requires.

**Vendoring transfers cleanly to documentation.** I apply the same replacement-over-merge approach to other reference materials in projects. One owner, one copy, explicit replacement when it changes. The question "which version of this applies here" is always answerable by looking at the tree.

**Recording failures in the document is worth the awkwardness.** It is uncomfortable to leave evidence of a rule that did not work inside the document that replaced it. But the alternative—silently removing the failed rule—loses the reason the replacement rule is shaped the way it is. Downstream readers (including future me) can see what was tried, why it failed, and what the current rule is trying to avoid.

**AI session initialization benefits from explicit state.** The session-start skill pattern transferred to other projects that use Claude Code. Rather than relying on context from the conversation history, the skill brings the AI to a known state from scratch. Sessions that start with an explicit initialization step produce more consistent behavior than sessions that accumulate state implicitly.
