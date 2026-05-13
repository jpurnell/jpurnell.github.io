---
title: Codifying the Craft: Building a Living Standard for Swift Development
description: A solo developer spent two months and 52 commits turning accumulated hard-won instincts into an authoritative, tool-integrated development guidelines system that now governs every Swift project they touch.
date: 2026-05-12 15:55
lastModified: 2026-05-12
tags: showcase, project, development-guidelines, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: development-guidelines
published: true
---

# Codifying the Craft: Building a Living Standard for Swift Development

> A solo developer spent two months and 52 commits turning accumulated hard-won instincts into an authoritative, tool-integrated development guidelines system that now governs every Swift project they touch.

## Problem

Every experienced developer carries a mental model of how things *should* be done — the right way to structure a session, the observability patterns that actually matter in production, the quality gates that catch real bugs before they ship. The problem is that mental models don't scale. They don't survive context switches, they can't be shared with collaborators, and they erode quietly over time.

The challenge here wasn't a missing feature or a broken system. It was something subtler: institutional knowledge trapped in one person's head, with no canonical home. The goal was to extract that knowledge, give it structure, and make it durable enough to actually change behavior on every future project.

## Approach

The work began in March 2026 and ran for exactly two months, producing 52 commits across 5 branches — a cadence that suggests deliberate, iterative refinement rather than a single burst of specification writing.

The centerpiece of the system is a `CLAUDE.md` file, a format that signals something important: these guidelines aren't documentation to be read once and forgotten. They're operational context, designed to be loaded directly into an AI-assisted development session and influence behavior in real time. The architecture of that document reflects clear thinking about what actually matters during development. Six sections — **Session Start**, **Development Workflow**, **Key Rules**, **Observability (Consumer-Facing Apps)**, **Quality Gate**, and **References** — map almost exactly to the lifecycle of a real work session. There's a deliberate hierarchy here: you orient yourself, follow a process, respect hard constraints, instrument your code, verify quality, and know where to look for more.

The observability section deserves particular attention. Most style guides skip instrumentation entirely, treating it as an afterthought. Singling it out — and scoping it specifically to consumer-facing apps — reflects the perspective of someone who has debugged production issues and knows that logging and metrics aren't optional.

Fifteen Claude Code sessions with 152 messages shaped the guidelines themselves, generating 5 commits. That ratio (roughly 30 messages per commit) points to something other than rapid code generation — it looks like careful vetting, debate, and deliberate selection of what actually earns a place in the standard.

## Results

The project shipped a complete, structured development guidelines system anchored by a production-ready `CLAUDE.md` that integrates directly with AI-assisted tooling. The five-branch structure suggests the guidelines cover meaningfully distinct domains or went through genuine alternative-path exploration before converging on canonical form.

Across 15 sessions, 9 fully achieved their objectives and 4 mostly achieved them — a 13-of-15 success rate that reflects a well-scoped project where the author knew what they were building. The guidelines now serve as a standing reference for every Swift project in the author's development environment, transforming what was implicit into something auditable and evolvable.

## Judgment Calls

The most revealing decisions here are about what *not* to do.

There are zero formal design proposals in the repository. For a project that is itself a design artifact — a document about how to build things — that absence is notable. It suggests the author trusted their own accumulated experience enough to build iteratively rather than specify upfront. The 5-branch history implies alternatives were explored in the work itself, not in pre-work documents.

The friction log from Claude Code sessions is instructive. Four `wrong_approach` flags and three `buggy_code` flags against a backdrop of only 5 total commits means the author was willing to discard work that didn't meet the standard — even when building the standard itself. That's a meaningful signal: the quality gate applies reflexively. One `excessive_changes` flag and one `user_rejected_action` entry suggest an author who maintained a clear editorial vision and pushed back when the tooling overreached.

Scoping observability guidance specifically to consumer-facing apps rather than writing a universal rule shows the kind of contextual judgment that separates a useful standard from an academic one. Universal rules are easier to write and harder to follow. Contextual rules are harder to write and actually get used.

The decision to anchor the entire system in `CLAUDE.md` rather than a static wiki or README is perhaps the most forward-looking call in the project. It acknowledges that the primary consumer of development guidelines in 2026 is as likely to be an AI coding assistant as a human developer — and designs for that reality explicitly.
