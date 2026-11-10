---
title: Personal Website Built on a Swift Static Site Generator
description: A Swift package that generates my personal site using Ignite, where pages are types and a broken page is usually a compile error rather than a deploy error.
date: 2026-05-12 15:57
lastModified: 2026-11-10
tags: showcase, website, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: Website
published: true
---

# Personal Website Built on a Swift Static Site Generator

> A Swift package that generates my personal site using Ignite, where pages are types and a broken page is usually a compile error rather than a deploy error.

## Motivation

I wanted a personal site that would host writing, a project showcase, and a quality-gate series, and I wanted publishing to be a single `swift run` rather than a multi-step operation involving external services. The other constraint was that I was already building and maintaining a fork of [Ignite](../../Ignite/project/master_plan.md), and I needed a real consumer of that fork — something that would surface divergence before anyone else encountered it. This site is that consumer. It is also published from a `docs/` directory directly to GitHub Pages, which removes any external build service from the pipeline.

## Approach

The site is a Swift package. Pages are types; layouts are composed in code. The consequence of that decision is that a malformed page tends to produce a compile error rather than a broken deploy. The package targets are `PersonalSiteLib`, which holds the site's types and content logic, `IgniteStarter`, which drives the build, and `PersonalSiteTests`, which covers behavior I want to verify automatically. It depends on Ignite directly, on `swift-docc-plugin` for documentation, and on a `DesignTokens` package that centralizes the visual constants the site uses. The package is declared against Swift tools version 6.2 and targets macOS and iOS.

There are no design proposals and no design-first workflow. Visual decisions are encoded in `DesignTokens` and applied in code. The `CLAUDE.md` file records working conventions — notably, never stash and do not call a change live until it is verified — but no Claude Code sessions contributed commits to this repository.

## Results

The repository has 276 commits from 2 contributors across 4 branches, with work running from November 2024 through November 2026. The site generates and deploys from `docs/` via GitHub Pages with no external CI service involved. The `PersonalSiteTests` target exists and runs as part of the package, though the input does not record a specific passing-test count.

## Decisions

**Pages as types.** Encoding pages in Swift rather than a template language means the compiler catches structural errors before deployment. The tradeoff is that contributors need to be comfortable with Swift.

**Primary consumer of the Ignite fork.** Running the site against my own Ignite fork means changes to the generator get exercised here first. That creates an intentional feedback loop: anything that breaks the site surface breaks before it reaches other users.

**`docs/`-based GitHub Pages deployment.** Committing the generated output to `docs/` and pointing Pages at that directory eliminates the need for a build service. The tradeoff is that generated files live in the repository.

**`DesignTokens` as a dependency.** Visual constants are extracted into a separate package rather than scattered across page types. This keeps the site's layout code focused on structure, but it adds a dependency that must stay in sync with any visual changes.

**What is unfinished or uncertain.** The test target exists but the extent of its coverage is not recorded here. The relationship between this site and the Ignite fork means changes to the generator can affect the site in ways that only become visible at build time — the compile-error guarantee applies to the site's own types, not to generator behavior changes upstream.
