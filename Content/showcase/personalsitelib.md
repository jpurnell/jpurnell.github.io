---
title: Building a Personal Site as a Swift Package: Owning the Stack End to End
description: Justin Purnell spent eighteen months turning his personal website into a fully Swift-native publishing system, accumulating 198 commits that trace a developer who refuses to treat infrastructure as someone else's problem.
date: 2026-05-12 15:57
lastModified: 2026-05-12
tags: showcase, website, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Website
published: true
---

# Building a Personal Site as a Swift Package: Owning the Stack End to End

> Justin Purnell spent eighteen months turning his personal website into a fully Swift-native publishing system, accumulating 198 commits that trace a developer who refuses to treat infrastructure as someone else's problem.

## Problem

Most developer personal sites are built on commodity tooling — static site generators with opinionated templates, JavaScript build pipelines, or hosted platforms that abstract away the underlying machinery. For a Swift developer, this creates a persistent friction: the language you think in every day has nothing to do with the tools generating your public presence. The challenge Justin set out to address was less about shipping a website and more about whether a Swift package could become the authoritative publishing layer for justinpurnell.com — something he could reason about, test, and extend using the same mental models he applies everywhere else.

## Approach

The project is built on [Ignite](https://github.com/twostraws/Ignite), Paul Hudson's Swift-based static site generator, which gives the package a foundation for rendering HTML through a declarative Swift API. Justin structured the work as a proper Swift package with Swift Tools Version 5.9, targeting both macOS and iOS and splitting concerns across three targets: `PersonalSiteLib` for the core content and component library, `IgniteStarter` for the site entry point, and `PersonalSiteTests` for a test suite that treats the site's output as something worth verifying rather than just eyeballing.

The architecture reflects a library-first instinct — rather than treating the site as a single monolithic build script, Justin extracted reusable components into `PersonalSiteLib`, making the rendering logic something that can be tested in isolation. With 198 commits across roughly eighteen months from a single primary contributor, the history reads as sustained, deliberate iteration rather than bursts of activity followed by neglect.

Toward the tail end of the project, Justin brought Claude Code into select sessions — eight in total, producing 70 messages and a single committed change. The session type breakdown is telling: three iterative refinement sessions, two single-task sessions, two multi-task sessions, and one exploratory session. This is not someone who handed the project to an AI assistant; it is someone who used one as a sounding board on specific problems while keeping authorship firmly in hand.

## Results

The project shipped and remains actively maintained, with the latest commit dated April 30, 2026 — roughly eighteen months of continuous development. The `PersonalSiteTests` target exists and is structured into the package manifest, establishing that the site's rendered output has test coverage, a commitment most personal site projects never make. The two-target split between library and site entry point means the component architecture is real, not cosmetic. The single branch and consistent commit cadence across 198 commits suggest a developer who works in a stable main-line flow, integrating frequently rather than accumulating long-lived feature branches.

## Judgment Calls

The decisions here that reveal craft are the ones Justin did not have to make. Nobody required him to structure a personal site as a package with a separate library target. Nobody required a test suite. Nobody required Swift tooling at all — Hugo or Astro would have been faster to bootstrap and easier to hand off.

The choice to use Ignite specifically is worth noting: it is a relatively young framework that prioritizes Swift idioms over ecosystem maturity. Betting on it signals a preference for conceptual coherence over safety-in-numbers, and it means Justin has had to work closer to the framework's edges, contributing to his understanding of how the rendering pipeline behaves rather than just consuming a stable API.

The Claude Code usage pattern tells a subtler story about judgment. Eight sessions over the life of a 198-commit project, with 70 messages and only one resulting commit, and a friction log that honestly records wrong approaches, misunderstood tone, and buggy code alongside four fully-achieved outcomes — this is a developer who knows when to use a tool and what to do when it fails. He did not throw the tool away when the outputs were wrong; he refined, redirected, and evaluated. That pattern of treating AI assistance as a collaborator to calibrate rather than an oracle to accept is itself a craft decision, and the friction data makes it legible.
