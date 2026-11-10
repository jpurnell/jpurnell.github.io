---
title: GEO Audit: AI and SEO Visibility Scoring via MCP
description: A Vapor web application that scrapes a target site, delegates scoring to a remote MCP server, and returns an audit report with recommendations — sold as single audits or recurring monitoring subscriptions.
date: 2026-05-12 15:58
lastModified: 2026-11-10
tags: showcase, GEO-SEO, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: GEO Auditor
published: true
---

# GEO Audit: AI and SEO Visibility Scoring via MCP

> A Vapor web application that scrapes a target site, delegates scoring to a remote MCP server, and returns an audit report with recommendations — sold as single audits or recurring monitoring subscriptions.

## Motivation

Website owners increasingly need to know how their sites appear not just to Google but to AI-powered search and retrieval systems. Existing SEO tools don't cover that gap. I wanted to build a paid web service that checks both: traditional SEO signals alongside the newer signals that AI crawlers and retrieval systems rely on, things like `llms.txt`, JSON-LD structured data, and E-E-A-T indicators.

The business model is per-audit purchases and weekly or monthly monitoring subscriptions, billed through Stripe. The scoring itself is handled by a remote GeoSEO MCP server I operate at roseclub.org, which means the application's job is scaping, orchestrating, and presenting results — not implementing scoring logic itself.

## Approach

The codebase is split into three SwiftPM targets inside a single package:

- **WebScraper** — builds a `ScrapedSiteData` value from the [SwiftWebScraper](https://github.com/jpurnell/SwiftWebScraper) package I extracted on 2026-11-07. It fetches HTML, HTTP headers, `robots.txt`, `sitemap.xml`, and `llms.txt`, and validates all URLs against SSRF rules before any network request leaves the process. Four source files. The audit data model `ScrapedSiteData` lives here rather than in the external package, keeping the scraping library generic.
- **GEOAuditCore** — the orchestration layer. It maps scraped data onto 18 named MCP tools (covering meta tags, heading structure, JSON-LD, AI crawler access, E-E-A-T, and a composite GEO score, among others) and assembles the report. Exposed as a library product alongside WebScraper so both can be reused or tested independently.
- **App** — the Vapor 4 web layer. Fluent with PostgreSQL in production and SQLite for tests. Redis-backed queues via `queues-redis-driver`. Leaf for server-side HTML rendering. Stripe via `stripe-kit` for payments.

A `MonitoringJob` runs on an hourly schedule and dispatches re-audits for any subscriptions that are due.

The CLAUDE.md file documents the architecture, module boundaries, development guidelines, and the MCP server address — it served as the working reference throughout the project.

## Results

The project has 47 commits from one contributor across three branches, running from March 2026 through November 2026. The package builds against Swift 6.2 on macOS.

Tests in both `WebScraperTests`, `GEOAuditCoreTests`, and `AppTests` run entirely against in-memory SQLite and mock HTTP and MCP clients, so no external services are required to run the test suite. The SwiftWebScraper dependency was extracted into its own package on 2026-11-07, leaving the scraping library independent while keeping `ScrapedSiteData` in this package. One Claude Code session contributed one commit.

## Decisions

**Delegate scoring to an MCP server.** The 18 scoring tools live on the remote GeoSEO MCP server rather than in the app. This keeps the application thin and means scoring logic can be updated on the server without a redeployment of the web app. The tradeoff is that the app is unavailable for scoring if the MCP server is unreachable.

**Extract SwiftWebScraper as a separate package.** Fetching and HTML extraction are generic enough to be useful outside this project, so I pulled them out. The extraction happened late in the project (commit history shows November 2026), which means the split was driven by the code stabilizing rather than being planned up front. `ScrapedSiteData` stayed in the audit package because it carries audit-specific fields.

**Three-target structure.** Separating WebScraper and GEOAuditCore from App lets both library targets be tested without standing up the Vapor server, and makes the orchestration logic available as a library if I want to build other surfaces later.

**Swift 6.2 and SwiftMCPClient.** Using Swift's structured concurrency and the MCP client library at language version 6.2 required strict concurrency conformance throughout. That shaped a number of type-level decisions in GEOAuditCore.

**What's unfinished or uncertain.** The project has zero design proposals and no design-first workflow on record, so the UI is not documented through any formal design artifact. The monitoring subscription flow depends on Stripe webhooks behaving correctly in production, and I haven't documented how webhook failures are handled. The SSRF validation covers the cases I know about but hasn't been externally reviewed.
