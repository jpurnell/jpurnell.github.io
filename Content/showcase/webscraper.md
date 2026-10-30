---
title: GEO Audit: Scoring AI Search Visibility with a Vapor-Backed Audit Pipeline
description: A full-stack Swift service that scrapes websites, delegates scoring to a remote MCP server across 18 named tools, and sells the resulting audit reports as one-time purchases or recurring monitoring subscriptions.
date: 2026-05-12 15:58
lastModified: 2026-10-30
tags: showcase, GEO-SEO, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: GEO Auditor
published: true
---

# GEO Audit: Scoring AI Search Visibility with a Vapor-Backed Audit Pipeline

> A full-stack Swift service that scrapes websites, delegates scoring to a remote MCP server across 18 named tools, and sells the resulting audit reports as one-time purchases or recurring monitoring subscriptions.

## Problem

As AI-powered search engines began reshaping how users discover content, website owners faced a new blind spot: traditional SEO audits had no vocabulary for AI crawler access, `llms.txt` compliance, or the signals that large language models use to assess authority. Existing tools measured meta tags and Core Web Vitals, but none answered the question of whether a site was actually *visible to AI search*.

GEO Audit was built to close that gap. Given a URL, it fetches the site's HTML, HTTP headers, `robots.txt`, `sitemap.xml`, and the emerging `llms.txt` convention, then routes that extracted data through a remote GeoSEO MCP server for authoritative scoring. The result is an actionable audit report covering both traditional SEO and generative-engine optimization — delivered as a paid product where users can run a single audit or subscribe to weekly or monthly re-audits as their site evolves.

## Approach

The project is organized into three SwiftPM library targets that enforce a clean separation of concerns. `WebScraper` owns all network I/O — fetching pages, parsing HTML with SwiftSoup, and validating every outbound URL against SSRF rules before a single byte leaves the process. `GEOAuditCore` sits above it as an orchestration layer, mapping scraped data onto 18 named MCP tools (covering meta tags, heading structure, JSON-LD, AI crawler access, E-E-A-T signals, and a composite GEO score) through `SwiftMCPClient`. The Vapor `App` target handles everything user-facing: routing, authentication, Leaf templates, Stripe payments, and Redis-backed job queues.

Making `WebScraper` and `GEOAuditCore` exportable library products was a deliberate decision — it keeps the scoring logic decoupled from the web framework and makes both targets independently testable. The SSRF validation layer inside `WebScraper` reflects the same instinct: fetch behavior is constrained at the module boundary, not scattered through higher-level code.

Scoring itself is intentionally not owned by the application. The 18-tool evaluation lives on a remote GeoSEO MCP server, and `GEOAuditCore` is purely an orchestrator — it knows *what* to send and *how* to interpret responses, but the scoring definitions live elsewhere. This lets the rubric evolve without redeploying the application.

Recurring monitoring is handled by `MonitoringJob`, an hourly scheduled job that queries for subscriptions due for re-audit and dispatches them through the same pipeline. The billing model — single audits, weekly plans, and monthly plans — is wired through Stripe Kit.

The test suite uses in-memory SQLite and mock HTTP and MCP clients, so the full pipeline can be exercised without live credentials or network access. Targets `WebScraperTests`, `GEOAuditCoreTests`, and `AppTests` cover each layer independently.

## Results

Development ran from March 2026 through October 2026 — roughly seven months — across 32 commits on a solo repository with three active branches. The project shipped a complete, monetized audit service: a scraping library, an MCP orchestration layer, a Vapor web application with Leaf templates, Stripe-integrated billing for three plan tiers, and an automated monitoring scheduler. The dependency list reflects genuine production scope: Fluent with both PostgreSQL and SQLite drivers, Redis-backed queues, swift-log for structured observability, and swift-docc-plugin for documentation generation.

The codebase targets Swift 6.2 with Swift Package Manager tools version 6.2, and the macOS platform constraint is explicit in the manifest.

## Judgment Calls

Several decisions in this project reveal deliberate architectural thinking rather than expedient choices.

**Delegating scoring to an MCP server.** Rather than embed a scoring rubric in application code, the project routes evaluation through a named external service. This is a meaningful tradeoff: it introduces a runtime dependency, but it means the definition of "good GEO score" can be updated centrally without touching the application. For a product whose entire value proposition is scoring accuracy, keeping that logic separate — and authoritative — is the right call.

**SSRF validation at the module boundary.** `WebScraper` validates URLs before fetching, not in a middleware layer above it. This means any caller of the library gets the protection automatically, and the constraint cannot be bypassed by a new route or job handler added later. Treating security as a module-level property rather than an application-level convention is a sign of systems thinking.

**Three-target SPM layout with exported library products.** Exposing `WebScraper` and `GEOAuditCore` as library products imposes a discipline that single-target apps avoid: the module interfaces have to be intentional. It also means the scraping and orchestration logic are independently testable and, in principle, reusable. For a solo project, this is over-engineering that pays off — the test targets for each layer confirm the boundaries hold.

**Test isolation via in-memory SQLite and mock clients.** The decision to make the entire pipeline runnable without external services means the test suite is fast, deterministic, and CI-friendly. Given that the real MCP server lives on a specific host, this wasn't optional — but structuring the code so mocks slot in cleanly required designing the interfaces with substitutability in mind from the start.
