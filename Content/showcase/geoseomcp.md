---
title: GeoSEOMCP: Building the Audit Layer for the Post-Search Web
description: A Swift MCP server exposing 29 tools that answer the question traditional SEO never asked: not *can a search engine rank this page*, but *can an AI system understand, retrieve, and correctly cite it*?
date: 2026-11-02 11:38
lastModified: 2026-11-09
tags: showcase, geoseomcp, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: GeoSEOMCP
published: true
---

# GeoSEOMCP: Building the Audit Layer for the Post-Search Web

> A Swift MCP server exposing 29 tools that answer the question traditional SEO never asked: not *can a search engine rank this page*, but *can an AI system understand, retrieve, and correctly cite it*?

## Problem

The web's visibility layer is bifurcating. For decades, "being findable" meant satisfying a crawler that produced a ranked list of blue links. That model assumed a human would click through, skim, and decide. Generative AI breaks every one of those assumptions. A language model reads a page once during training or retrieval, extracts passages, and quotes them — often without attribution, often in contexts the author never anticipated. If the content isn't structured for that consumption pattern, it doesn't get cited. It simply doesn't exist in the answer.

GeoSEOMCP is jpurnell's response to that gap. Built as a macOS-native Swift package, it implements the Model Context Protocol (MCP) to expose a suite of 29 tools purpose-built for **Generative Engine Optimization** — a discipline focused on how well a page is understood, cited, and retrieved by AI systems rather than how it ranks on a results page.

The project targets three overlapping audiences: content authors who need to know whether their writing will survive passage-level extraction by an LLM, agents running automated site audits, and developers building AI-native publishing workflows. The unifying question is always the same: *in the form a model actually consumes this, is it citable?*

## Approach

The architectural choice to target MCP from day one is the central decision of this project. Rather than building a standalone CLI or web service, jpurnell chose to make the tooling native to the agent layer — meaning any MCP-aware assistant can call these tools directly, turning a site audit from a report you read into an analysis an AI can perform on your behalf.

The package is structured across three targets: `GeoSEOMCP` for the core domain logic, `GeoSEOMCPServer` for the protocol implementation, and `GeoSEOMCPTests` for the test suite. Dependencies are deliberately lean — `SwiftMCPServer`, the `swift-mcp-sdk`, and `swift-docc-plugin` — keeping the surface area tight and the platform constraint (macOS only) honest rather than aspirationally cross-platform.

One of the more considered pieces of domain modeling is the AI crawler registry. jpurnell built explicit first-class types — `AICrawlerRegistry`, `AICrawler`, `AIPlatform` — to represent the population of AI-specific crawlers that `robots.txt` files now need to reason about. This matters because the tooling surfaces something most audits miss: a `robots.txt` that admits Googlebot while blocking GPTBot is not an oversight, it is a policy decision with real consequences for AI visibility — and it deserves to be named as such.

The passage-level citability framing is similarly intentional. Classic SEO scores pages. GeoSEOMCP scores passages, because that is the unit a model actually quotes. This is a narrower, harder problem, and it required building analysis primitives that operate at a granularity most web tooling has never needed.

Swift Tools version 6.2 means the project is running on the leading edge of Swift's concurrency model, appropriate for a tool designed to handle async document fetching and analysis across many concurrent agent calls.

## Results

GeoSEOMCP shipped its `0.1.0` release across 60 commits, sole-authored, over approximately eight months — from the first commit in March 2026 through the latest in November 2026. Six branches show iterative development with dedicated workstreams rather than a single monolithic trunk. The 29 tools represent a coherent, complete API surface for the GEO audit domain: a number large enough to cover the problem thoroughly, constrained enough that each tool has a reason to exist.

The `GeoSEOMCPTests` target is present and structured as a first-class concern alongside production code. `swift-docc-plugin` as a dependency signals that the documentation is generated from source — the project is built to be understood, not just used.

## Judgment Calls

**MCP as the interface, not a wrapper around one.** jpurnell could have built a command-line tool or a REST API and later considered an MCP adapter. Instead, the protocol is the foundation. This means the tooling lives at the same layer as the agents that need it, reducing integration friction to zero for any MCP-aware system. It also means the design had to be right the first time — MCP tool schemas are part of your public contract in a way a CLI flag never is.

**Naming the AI crawler problem explicitly.** Building `AICrawlerRegistry` as a typed registry rather than parsing `robots.txt` naively and leaving interpretation to the caller is a craft decision. It encodes domain knowledge — that GPTBot, Anthropic's crawler, and their peers are a distinct population with distinct policy implications — into the type system, so that distinction can't be accidentally elided in analysis.

**Passage-level, not page-level.** This is the judgment call that defines the project's identity. It would have been faster and simpler to produce page-level scores. jpurnell chose not to, because a page-level score doesn't answer the actual question. A page can have a strong overall signal and contain passages that are ambiguous, unattributable, or machine-unreadable. GEO lives at the passage level, and so does GeoSEOMCP.

**Swift on the leading edge.** Targeting Swift Tools 6.2 and macOS on a tools project is a bet on longevity and correctness. Strict concurrency means bugs that might surface as race conditions in production are caught at compile time. For a server handling concurrent agent tool calls, that is not a philosophical preference — it is operational discipline.
