---
title: Auditing the Invisible: Building a GEO Compliance Tool for the AI Search Era
description: A solo developer designed and shipped a full-stack Swift web application that audits how businesses appear in AI-generated search results — before most of the industry had a name for the problem.
date: 2026-05-12 15:58
lastModified: 2026-05-12
tags: showcase, GEO-SEO, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: GEO Auditor
published: true
---

# Auditing the Invisible: Building a GEO Compliance Tool for the AI Search Era

> A solo developer designed and shipped a full-stack Swift web application that audits how businesses appear in AI-generated search results — before most of the industry had a name for the problem.

## Problem

Generative Engine Optimization (GEO) is a nascent discipline: as AI-powered search tools like Perplexity, ChatGPT, and Google's AI Overviews displace traditional search rankings, businesses have almost no visibility into how — or whether — they're being represented. The SEO tooling ecosystem hadn't caught up. There was no straightforward way for a business owner to ask: *When someone queries an AI assistant about my category, does my brand appear? Is what's said accurate? Is it favorable?*

That gap was the target. The project needed to go from zero to a working audit product: scraping AI-generated results, analyzing the content, storing findings relationally, and surfacing them through a web interface — all within a few weeks and a solo development context.

## Approach

The developer made a deliberate architectural commitment at the outset: **design first, then code**. Ten design proposals were written before significant implementation began, covering module structure, data flow, and the relationship between the scraping core and the application layer. A `CLAUDE.md` file codified project conventions, tech stack rationale, and development guidelines — a document that served both as a working reference and as a forcing function for architectural clarity.

The stack reflects considered tradeoffs rather than defaults. Swift was chosen as the primary language, running on Swift 6.0's strict concurrency model — a meaningful constraint that pushes developers toward correct-by-construction async code. The project is organized into distinct targets that reflect a genuine separation of concerns:

- **WebScraper / GEOAuditCore** — the parsing and analysis layer, built around SwiftSoup for HTML extraction and structured to be testable in isolation
- **App** — a Vapor-based web server with Leaf templating, backed by Fluent ORM with support for both PostgreSQL (production) and SQLite (development/testing)
- **Background processing** — Redis-backed job queues via `queues-redis-driver` for asynchronous audit runs
- **Monetization** — Stripe integration present from early in the build, signaling intent to ship a real product, not a prototype

The inclusion of both `fluent-postgres-driver` and `fluent-sqlite-driver` as explicit targets — along with separate test targets for both `WebScraper` and `GEOAuditCore` — shows a developer who anticipated the full lifecycle: local iteration, CI, and production deployment.

## Results

Over 24 days and 7 commits, the developer brought a multi-module Swift web application from concept to a working state. Six of those commits were made across three Claude Code sessions, with the seventh establishing the initial repository structure. All three sessions were classified as multi-task — meaning each session carried multiple distinct workstreams rather than isolated fixes — and two of three sessions reached a "mostly achieved" outcome, with one fully achieved.

The application targets macOS and integrates a non-trivial dependency graph: nine external packages spanning scraping, web serving, ORM, templating, queueing, and payments. The presence of test targets for both core modules indicates the scraping and audit logic was being validated independently of the web layer.

## Judgment Calls

Several decisions in this project reveal a developer thinking past the immediate build.

**Writing ten design proposals before writing significant code** is an unusual discipline for a solo project on a short timeline. It signals that the developer treats architecture as a first-class artifact — not just a byproduct of implementation, but something worth reasoning through explicitly before accumulating technical debt.

**Choosing Swift 6.0's strict concurrency** for a web scraping application is a meaningful bet. The compiler enforcement of actor isolation and sendability requirements adds friction during development but produces safer concurrent code — important in a system that's fetching external AI-generated pages, parsing them, and enqueuing background jobs simultaneously.

**Integrating Stripe before the product was feature-complete** reflects product thinking, not just engineering. The payment infrastructure being present in the dependency graph from early on suggests the developer was building toward something shippable and sustainable, not a demo.

**The SQLite/PostgreSQL dual-driver pattern** — with both included as package dependencies — reflects experience with the full deployment cycle. SQLite for local development keeps iteration fast; PostgreSQL in production scales. Wiring both up from the start avoids a painful migration later.

The three Claude Code sessions show a working style comfortable with complexity and ambiguity: multi-task sessions, friction encountered and navigated (a buggy code instance, a wrong approach corrected, a permission issue resolved), and outcomes that landed in "mostly achieved" territory — the honest result of doing hard, novel work on a short timeline.
