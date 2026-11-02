---
title: GeoSEOMCP: An MCP Server for the Age of AI Retrieval
description: A 29-tool Swift package that shifts the optimization target from search engine rankings to AI citation fidelity — built over eight months to answer a question most SEO tooling doesn't yet know to ask.
date: 2026-11-02 11:38
lastModified: 2026-11-02
tags: showcase, geoseomcp, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: GeoSEOMCP
published: true
---

# GeoSEOMCP: An MCP Server for the Age of AI Retrieval

> A 29-tool Swift package that shifts the optimization target from search engine rankings to AI citation fidelity — built over eight months to answer a question most SEO tooling doesn't yet know to ask.

## Problem

Search engine optimization has always been a proxy game: rank well on a results page, earn a click, and hope the visitor stays. That contract is quietly breaking down. When a user asks an AI assistant a question, the model doesn't surface a list of links — it synthesizes an answer, and the pages it draws from are cited, paraphrased, or quietly ignored based on how well a language model could parse them the one time a crawler read them.

GeoSEOMCP is built on the observation that this creates an entirely different optimization problem. The unit being judged is no longer a page's authority score; it's a *passage* — the extractable chunk of text a model might actually quote. The question is no longer "does Google rank this?" but "when GPTBot crawled this page, did it gain enough semantic clarity to cite it correctly?"

The project ships as a Model Context Protocol (MCP) server, which means it is itself designed to be consumed by AI assistants — an agent auditing a site can invoke GeoSEOMCP's tools directly to understand how machine-readable that site actually is. The target users are content authors who want their work cited rather than merely indexed, and agents performing automated site audits.

## Approach

Purnell built GeoSEOMCP in Swift targeting macOS, using Swift Package Manager 6.2 and a dependency stack of `SwiftMCPServer`, `swift-mcp-sdk`, and `swift-docc-plugin`. The choice of Swift is notable: most MCP server tooling in this space gravitates toward Python or TypeScript, and building in Swift signals both a platform commitment and an intent to ship something with the performance and type-safety characteristics of a compiled language.

The package is organized into three targets: the core `GeoSEOMCP` library, a `GeoSEOMCPServer` executable, and a `GeoSEOMCPTests` test suite. This separation keeps the analyzable domain logic decoupled from the server transport layer — a meaningful architectural choice that makes the tools independently testable and reusable.

The most revealing design decision is the AI-crawler-aware infrastructure at the center of the domain model. Rather than treating all crawlers uniformly, GeoSEOMCP models `AICrawler`, `AIPlatform`, and an `AICrawlerRegistry` as first-class types. This means the system can surface a distinction that virtually no other SEO tooling flags: a `robots.txt` that permits Googlebot while blocking GPTBot isn't a neutral configuration — it's an active choice to exclude AI retrieval, and GeoSEOMCP makes that visible. The project's MASTER_PLAN.md identifies this as a key differentiator, and the type system architecture reflects the same priority.

The 29 tools shipped across the server span the full audit surface: page-level machine-readability analysis, passage-level citability scoring, structured data inspection, and access-control analysis against the known AI crawler registry.

## Results

GeoSEOMCP reached its `0.1.0` release across 56 commits and eight months of active development (March through November 2026), with work tracked across four branches. The single-contributor project shipped a complete 29-tool MCP server — an unusually high surface area for an early release, indicating that the scope was planned ahead and built to completion rather than iterated toward incrementally.

The project defines its own success metric in its mission statement: not ranking, but citation. Whether a page gets correctly quoted by a language model is a harder thing to instrument than a PageRank proxy, and shipping 29 tools against that target in a v0.1.0 represents a coherent, complete first statement of the problem's solution space.

## Judgment Calls

The most interesting judgment in GeoSEOMCP is the refusal to optimize for the wrong thing. Classic SEO tooling is mature, well-understood, and well-served. Building another tool in that space would have been straightforward. Purnell instead identified that the optimization target itself has shifted for a meaningful class of content — anything whose value is being *quoted correctly by a model* rather than *clicked from a results page* — and built infrastructure for that new target before most tooling acknowledges the distinction exists.

The decision to model AI crawlers as a registry with first-class types rather than as a configuration file or lookup table is a second signal of craft. It means the tool can reason about platform-specific behavior, not just generic bot access. A `robots.txt` analysis that understands the difference between allowing Anthropic's crawler and blocking OpenAI's is qualitatively more useful to the actual user than a binary "bots allowed / bots blocked" flag.

Choosing Swift in a landscape where this tooling typically runs on scripting runtimes is a third considered call. It trades ecosystem familiarity for correctness guarantees and performance — a reasonable trade for infrastructure that agents will invoke programmatically rather than developers running interactively.

What the project lacks in external design artifacts and documented process, it compensates for in architectural legibility: the type model, the tool count, and the mission statement all tell a consistent story about what problem is being solved and why the existing tools don't solve it.
