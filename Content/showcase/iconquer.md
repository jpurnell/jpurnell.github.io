---
title: Resurrecting iConquer: A Design-First Swift Port of a Classic Mac Strategy Game
description: Justin Purnell is rebuilding a beloved 2002 Mac strategy game from scratch in modern Swift — using a TypeScript reference implementation as a behavioral specification and targeting iOS 26's Liquid Glass aesthetic as the finish line.
date: 2026-05-12 15:56
lastModified: 2026-10-30
tags: showcase, project, selfReflection, iConquer
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# Resurrecting iConquer: A Design-First Swift Port of a Classic Mac Strategy Game

> Justin Purnell is rebuilding a beloved 2002 Mac strategy game from scratch in modern Swift — using a TypeScript reference implementation as a behavioral specification and targeting iOS 26's Liquid Glass aesthetic as the finish line.

## Problem

iConquer was a Risk-style turn-based strategy game released around 2002 by Kavasoft, written in Objective-C for classic Mac OS X. The original source code is gone. The binary is a relic. But the game itself — the map, the mechanics, the feel of it — left an impression worth preserving.

The project, internally named MLXTest and tracked under the `iconquer` path, exists to solve a specific problem: how do you faithfully recreate a piece of software when you have no source, a working reference, and a modern platform with entirely different idioms? Justin's answer was to treat the existing TypeScript port, living in the same repository under `src/`, not as a curiosity but as an authoritative behavioral specification. The TypeScript implementation defines what iConquer *does*. The Swift rebuild defines what iConquer *becomes*.

The stakes are deliberately layered. This is a portfolio project meant to demonstrate Design-First TDD in SwiftUI — not a toy, but a full native application with a plug-in architecture for maps and AI players, original art assets, and a target platform that didn't exist when the original shipped.

## Approach

The project is built on Swift 6.2 targeting macOS, with `swift-docc-plugin` as its sole external dependency — a deliberate choice that keeps the dependency graph clean and signals that documentation is treated as a first-class output, not an afterthought. The test target, `MLXTestTests`, exists from the start, not retrofitted in later.

The CLAUDE.md file structures the working environment around explicit rules: a defined session start ritual, a quality gate that must be cleared before any commit, and architecture references that keep the big picture visible during granular work. This kind of scaffolding is characteristic of a developer who has learned that the bottleneck in long-running solo projects isn't capability — it's continuity. The CLAUDE.md is a contract with future-Justin as much as anything else.

The MASTER_PLAN.md establishes the architectural ambitions clearly: a plug-in system for maps and AI (preserved from the original design philosophy), behavior-equivalence testing enabled by the TypeScript reference, and a progressive modernization path that doesn't require solving every problem at once. iOS 26's Liquid Glass styling is explicitly on the roadmap, which means the visual layer is being designed with future constraints in mind from day one.

## Results

Over roughly six months — from March to late August 2026 — the project accumulated 77 commits across a single focused branch with two contributors. That pace reflects deliberate, sustained work rather than bursts of activity followed by abandonment. The repository structure, the tooling choices, and the documentation artifacts are all present and coherent at the latest commit.

The test target is established and in-scope. The TypeScript reference implementation lives alongside the Swift codebase, making behavioral comparison a tooling problem rather than a memory problem. The original game assets are integrated. The plug-in architecture, one of the most technically interesting aspects of the original iConquer design, is carried forward as a named deliverable rather than something to figure out later.

## Judgment Calls

Several decisions here are worth examining as evidence of craft rather than just execution.

**Choosing a TypeScript reference over documentation.** When you have no source code, you have two options: reconstruct behavior from memory and user expectations, or find something executable to interrogate. Justin chose the latter. The TypeScript port becomes a spec that can be run, diffed, and tested against — a living document that catches drift in a way that written notes never could.

**Keeping dependencies minimal.** A Risk-style strategy game with a plug-in architecture and multiple AI systems could justify a lot of dependencies. The package file lists exactly one: `swift-docc-plugin`. This is a bet that the complexity of the domain should be managed in the codebase, not outsourced to libraries — and that documentation infrastructure is worth paying for explicitly.

**Writing CLAUDE.md before writing much game code.** The CLAUDE.md artifact, with its session start protocol and quality gate, suggests Justin has internalized a lesson about solo long-running projects: the hardest part isn't building, it's maintaining context across sessions separated by days or weeks. Externalizing that context into a structured document is a form of systems thinking applied to personal workflow.

**Targeting iOS 26 from the start.** Liquid Glass is a new visual idiom. Building toward it deliberately rather than treating it as an upgrade path means the UI architecture won't need to be rethought at the end — it's a constraint that shapes decisions being made now, including layout, material usage, and interaction design.

The name in the package is MLXTest; the game is iConquer; the path says iconquer; the mission statement is unambiguous. This is a project that knows exactly what it is, even if the world hasn't seen the finished version yet.
