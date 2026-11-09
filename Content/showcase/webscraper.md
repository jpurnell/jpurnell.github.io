---
title: GEO Audit: Scoring AI Search Visibility with a Scrape-Orchestrate-Report Pipeline
description: A solo Swift developer built a paid Vapor web service that audits website visibility for AI search and traditional SEO, delegating scoring to a remote MCP server while handling scraping, orchestration, and reporting in a cleanly separated three-target architecture.
date: 2026-05-12 15:58
lastModified: 2026-11-02
tags: showcase, GEO-SEO, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: GEO Auditor
published: true
---

# GEO Audit: Scoring AI Search Visibility with a Scrape-Orchestrate-Report Pipeline

> A solo Swift developer built a paid Vapor web service that audits website visibility for AI search and traditional SEO, delegating scoring to a remote MCP server while handling scraping, orchestration, and reporting in a cleanly separated three-target architecture.

## Problem

As AI-powered search engines became a meaningful source of web traffic, website owners were left without reliable tools to understand how visible they were to these systems. Traditional SEO auditors focused on signals Google cared about — meta tags, structured data, crawlability — but the emerging category of Generative Engine Optimization (GEO) demanded something different: awareness of `llms.txt`, AI crawler access policies, and E-E-A-T signals that large language models use to assess source credibility.

GEO Audit was built to fill that gap. The service fetches a target website's HTML, headers, `robots.txt`, `sitemap.xml`, and `llms.txt`, routes the extracted data through a remote GeoSEO MCP server for scoring across 18 named dimensions, and returns a structured audit report with actionable recommendations. Users can pay for a single audit or subscribe to weekly or monthly re-audits, with an automated monitoring job dispatching due runs on an hourly schedule.

## Approach

The project runs on Vapor 6, backed by Postgres for production persistence and SQLite for test environments, with Redis queuing the monitoring pipeline. The codebase is organized into three SwiftPM library targets that enforce a clean separation of concerns:

- **WebScraper** handles all network I/O — fetching HTML, headers, and the suite of supporting files — and validates every URL against SSRF before any request leaves the process. SwiftSoup drives HTML parsing across its 10 source files, and the target is exposed as a reusable library product.
- **GEOAuditCore** owns the orchestration layer, mapping scraped data onto the 18 MCP tool calls and assembling the report structure. It communicates with the remote GeoSEO MCP server via SwiftMCPClient, keeping scoring logic off the application server entirely.
- **App** is the Vapor application itself — routing, authentication, Stripe billing integration via stripe-kit, and the Leaf-rendered UI.

Tests across `WebScraperTests`, `GEOAuditCoreTests`, and `AppTests` use in-memory SQLite and mock HTTP and MCP clients, meaning the full test suite runs without any external service dependencies.

## Results

Over roughly seven months — from March to October 2026 — the project reached a shipping state across 32 commits from a single contributor. The target breakdown spans six named SwiftPM targets. A CLAUDE.md file documents the development environment, module structure, and connection details for the hosted MCP server at roseclub.org, indicating the infrastructure was live and connected. The monitoring pipeline, billing integration, and three-tier pricing model (single audit, weekly, monthly) were all present by the final commit.

## Judgment Calls

Several decisions stand out as evidence of architectural judgment rather than just implementation effort.

**Delegating scoring to a remote MCP server.** Rather than embed GEO scoring logic in the application, the project routes that responsibility to a dedicated external server. This is a meaningful boundary decision — it keeps the application focused on scraping and reporting, allows scoring logic to evolve independently, and acknowledges that the rules of GEO are still being written. The 18-tool MCP interface gives that boundary a well-defined contract.

**SSRF validation before any fetch.** Because the service accepts arbitrary URLs from users, every fetch candidate in WebScraper is validated against SSRF before a request is issued. Building this into the scraping layer rather than the application layer means the protection travels with the library, not just the endpoint.

**Three-target split with library products.** Exposing WebScraper and GEOAuditCore as library products rather than embedding everything in the App target signals intent: these components are designed to be composable and testable in isolation. The mock client strategy in tests proves the abstraction is real — the orchestration layer can be exercised fully without a live MCP server or HTTP client.

**`llms.txt` as a first-class signal.** Fetching `llms.txt` alongside the standard SEO artifacts (`robots.txt`, `sitemap.xml`) reflects an early commitment to the emerging GEO category. At the time most tooling ignored this file entirely; treating it as a required input to the audit pipeline was a forward-looking choice.

**Swift Tools 6.2 and strict concurrency.** Building on Swift 6.2 means the codebase targets strict concurrency checking, which imposes real discipline on how the async scraping and queuing pipeline is structured. Choosing the leading edge of the Swift ecosystem for a networked service is a deliberate bet on correctness over short-term convenience.
