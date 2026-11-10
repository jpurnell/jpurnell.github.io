---
title: GeoSEOMCP: An MCP Server for Generative Engine Optimization
description: A 29-tool MCP server that analyzes how well a page will be understood, cited, and retrieved by AI systems rather than by traditional search engines.
date: 2026-11-02 11:38
lastModified: 2026-11-10
tags: showcase, geoseomcp, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: GeoSEOMCP
published: true
---

# GeoSEOMCP: An MCP Server for Generative Engine Optimization

> A 29-tool MCP server that analyzes how well a page will be understood, cited, and retrieved by AI systems rather than by traditional search engines.

## Motivation

Classic SEO tools answer one question: will this page rank? That question is becoming less useful as AI assistants increasingly read a page once and decide whether to quote from it. The unit that matters is no longer a position in a results list — it is a passage that a model extracts and cites verbatim.

I built GeoSEOMCP to address the gap between what traditional SEO tooling measures and what actually determines whether content gets cited by an LLM. The specific problems I wanted to handle were: whether a page is structured in a way a model can parse, whether the right AI crawlers are permitted in `robots.txt`, and whether individual passages are citable in the form a model actually consumes them. The result is an MCP server — using the Model Context Protocol — so the tools can be called directly by agents performing site audits or by AI assistants answering questions about a page's machine-readability.

## Approach

The project is a Swift package targeting macOS, built against Swift Tools version 6.2. It has three targets: `GeoSEOMCP` (the core library), `GeoSEOMCPServer` (the server executable), and `GeoSEOMCPTests` (the test suite). The two external dependencies that do the protocol-level work are `SwiftMCPServer` and `swift-mcp-sdk`; `swift-docc-plugin` handles documentation generation.

The 29 tools are organized around four concerns that differ from traditional SEO:

- **AI crawler access** — using `AICrawlerRegistry`, `AICrawler`, and `AIPlatform` types to map which AI crawlers a site's `robots.txt` admits or excludes. A configuration that allows Googlebot but blocks GPTBot is a meaningful decision that most tooling ignores entirely.
- **Passage-level citability** — scoring individual passages rather than whole pages, because a model quotes a passage, not a PageRank score.
- **Structural machine-readability** — analyzing whether a page's structure and metadata are parseable in the form an LLM would read it.
- **Citation and retrieval signals** — examining factors that affect whether a model retrieves and quotes a page correctly.

The MCP server architecture means every tool is callable by an agent or assistant directly, without a human in the loop, which fits the target use case of automated site audits.

## Results

The project shipped one release, `0.1.0`, built across 60 commits from one contributor over roughly seven and a half months (March to November 2026). The 29 tools are implemented and exposed through the MCP server interface. The package compiles and runs on macOS against Swift 6.2 tooling.

There are no usage or adoption numbers to report at this stage, as this is a first release.

## Decisions

**MCP as the delivery format.** Shipping as an MCP server rather than a CLI or library means the tools are callable by agents directly. That matches the target users — agents auditing sites and AI assistants answering citability questions — better than a human-facing interface would.

**Swift on macOS only.** The choice narrows the platform surface to what I could build and test. It also fits the likely deployment context: a developer's own machine running an MCP host alongside an AI assistant.

**AI-crawler-specific types.** `AICrawlerRegistry`, `AICrawler`, and `AIPlatform` are first-class types rather than string lookups. This makes the distinction between, say, GPTBot and Bingbot explicit in the data model, which is the distinction that actually matters for generative engine access decisions.

**Passage-level scoring.** Scoring passages rather than pages reflects how models consume content. This was a core architectural choice and shapes what the tools return.

**What is unfinished.** There is no cross-platform support — Linux is out of scope for now. The project has no published adoption data and no integrations with specific AI platforms to validate that its citability signals correlate with actual citation rates. The relationship between passage scores and real-world model behavior remains a hypothesis rather than a measured outcome.
