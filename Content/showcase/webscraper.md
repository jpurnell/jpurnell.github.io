---
title: GEO Audit: Building a Paid AI-Visibility Scoring Service in Swift
description: A solo developer designed and shipped a three-layer Vapor application that scrapes websites, delegates scoring to a remote MCP server, and sells per-audit and subscription monitoring plans — all in under eight months.
date: 2026-05-12 15:58
lastModified: 2026-11-09
tags: showcase, GEO-SEO, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: GEO Auditor
published: true
---

# GEO Audit: Building a Paid AI-Visibility Scoring Service in Swift

> A solo developer designed and shipped a three-layer Vapor application that scrapes websites, delegates scoring to a remote MCP server, and sells per-audit and subscription monitoring plans — all in under eight months.

## Problem

Search is bifurcating. Traditional crawlers still matter, but AI-powered search engines read pages differently — they weight structured data, `llms.txt` declarations, E-E-A-T signals, and machine-readable metadata in ways that standard SEO tools don't measure. Website owners have no easy way to know how visible they are to this new class of searcher.

GEO Audit was built to close that gap. It accepts a URL, fetches the target site's HTML, headers, `robots.txt`, `sitemap.xml`, and `llms.txt`, routes the extracted data through a remote GeoSEO MCP server for authoritative scoring, and returns an audit report with actionable recommendations. Users can pay for a one-time audit or subscribe to weekly or monthly re-audits that run automatically.

The project is a commercial product, not an internal tool — meaning it had to handle payments, recurring jobs, and a multi-tenant web UI from day one.

## Approach

The architecture is deliberately split into three SwiftPM library targets, each with a narrow responsibility.

**WebScraper** is the data-gathering layer. It wraps the separately extracted `SwiftWebScraper` package, assembles a `ScrapedSiteData` model from raw HTTP responses, and enforces SSRF URL validation before any network call is made. Keeping the audit model (`ScrapedSiteData`) in this target rather than in the scraping package was a conscious boundary decision: the scraping logic is reusable, but the shape of the data the audit cares about belongs to the audit.

**GEOAuditCore** is the orchestration layer. It maps scraped data onto 18 named MCP tools — covering meta tags, heading structure, JSON-LD, AI crawler access, E-E-A-T signals, and a composite GEO score, applied per-page and site-wide — and assembles the final report. Scoring is intentionally delegated to the remote GeoSEO MCP server hosted on roseclub.org; the core library stays thin and testable.

**App** is the Vapor web layer. It owns routing, Leaf templates, Stripe payment integration, Fluent persistence (Postgres in production, SQLite in tests), and the Redis-backed queue that drives `MonitoringJob` — an hourly scheduled worker that checks which subscriptions are due and dispatches re-audits.

The test strategy reflects the layered design. `WebScraperTests`, `GEOAuditCoreTests`, and `AppTests` each run against in-memory SQLite and mock HTTP/MCP clients, so the full suite runs locally with no external dependencies.

Documentation was treated as a first-class output: `swift-docc-plugin` is a declared dependency, signaling that both library targets (`WebScraper` and `GEOAuditCore`) are meant to be consumed by others.

## Results

Over roughly seven and a half months — first commit March 21, 2026, latest November 8, 2026 — the project reached 35 commits across 3 branches on a solo contributor's timeline. That pacing reflects sustained, deliberate iteration rather than a sprint.

What shipped is a complete commercial service: a paid web application with Stripe-backed per-audit purchases and subscription tiers, automated monitoring via a scheduled Redis job, a Vapor/Leaf front end, and two reusable Swift library products. The `SwiftWebScraper` dependency was extracted into its own package as recently as November 7, 2026 — one day before the latest commit — demonstrating active architectural refinement even as the product matures.

The three-target structure means both `WebScraper` and `GEOAuditCore` are available as libraries, opening a path for other clients to consume the scraping or orchestration layers independently.

## Judgment Calls

**Extracting SwiftWebScraper without moving ScrapedSiteData.** When the scraping logic was pulled into its own open-source package, the temptation would be to move the data model with it. The developer kept `ScrapedSiteData` inside the audit project. This is the right call: the extracted package stays generic and reusable, while the specific shape of data the audit pipeline depends on remains a versioned, explicit contract owned by this product.

**Delegating scoring to a remote MCP server.** Rather than implementing GEO scoring heuristics in Swift and maintaining them as AI search evolves, the app treats scoring as an external, upgradeable service. The 18 named MCP tool calls are the interface; the intelligence lives elsewhere. This keeps `GEOAuditCore` stable and testable while allowing the scoring model to improve without a client release.

**SSRF validation before any fetch.** Putting URL validation in `WebScraper` before any HTTP call is made is a security-first boundary. In a service that accepts arbitrary user-supplied URLs and fetches them server-side, this is not optional — and placing it at the lowest layer means no path through the orchestration can bypass it.

**Swift Tools version 6.2 and strict concurrency.** Targeting the latest Swift toolchain on a commercial product means embracing Swift 6's strict concurrency model from the start, rather than accumulating technical debt that would have to be paid down later. For an async-heavy pipeline — concurrent MCP tool calls, background monitoring jobs, HTTP fetching — getting concurrency semantics right at the foundation is leverage that compounds.

**In-memory SQLite for the full test suite.** Swapping the production Postgres driver for SQLite in tests, combined with mock HTTP and MCP clients, means every test is fast, deterministic, and runnable without infrastructure. For a solo developer shipping a paid service, that's not a convenience — it's what makes confident iteration possible.
