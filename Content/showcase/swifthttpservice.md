---
title: SwiftHTTPService: A Typed HTTP/1.1 + TLS Service Kit for Swift
description: A small Swift package that provides routing, middleware, problem details, conditional requests, validated configuration, and a NIO-backed TLS transport for serving JSON APIs.
date: 2026-11-23 11:32
lastModified: 2026-11-23
tags: showcase, swifthttpservice, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SwiftHTTPService
published: true
---

# SwiftHTTPService: A Typed HTTP/1.1 + TLS Service Kit for Swift

> A small Swift package that provides routing, middleware, problem details, conditional requests, validated configuration, and a NIO-backed TLS transport for serving JSON APIs.

## Motivation

My Stack Map had an `http-service` gap: when I needed to build `ijs-dashboard-server` — a server with 19 routes, bearer auth, ETag/304 support, problem+json error responses, TLS, and graceful shutdown — I had no reusable foundation to put it on. The options were to pull in a large third-party framework or build a focused kit that covered exactly that surface and nothing more.

I wanted something with two properties that most available options don't combine: a core layer with no network dependency (so routing and middleware are testable without a running server), and a strict failure mode (ambiguous request targets refused rather than normalized, contradictory configuration rejected at startup, error text never forwarded to clients). SwiftHTTPService is what I built to close that gap.

## Approach

The package is split into two targets that reflect the core/transport boundary. `SwiftHTTPService` contains routing, middleware, problem details, conditional request handling, and configuration validation. It has no NIO dependency. `SwiftHTTPServiceNIO` adds the transport: a SwiftNIO-backed HTTP/1.1 and HTTP/2 server with TLS via SwiftTLSKit. The separation means the core can be exercised in unit tests without any network setup.

Dependencies are intentionally constrained to Apple-vended packages — `swift-http-types`, `swift-nio`, `swift-nio-extras`, `swift-nio-http2` — plus SwiftTLSKit and the DocC plugin. The package targets Swift Tools 6.2 and runs on macOS and iOS.

A CLAUDE.md file was present throughout development and defined session start procedures, the development workflow, key rules, and the quality gate. Three Claude Code sessions contributed 33 of the 105 total commits across 101 messages, covering a mix of multi-task and single-task work. Friction was low — a small number of rejected actions, tool failures, and one instance of buggy generated code — and two of the three sessions reached a mostly-achieved outcome, one fully achieved.

There is no formal design-first workflow and no committed design proposal file, though MASTER_PLAN.md references a design proposal document at `project/plans/proposals/DesignProposal_SwiftHTTPService.md`.

## Results

The project reached v1.0.0-beta.5 across 105 commits over roughly four weeks (first commit 2026-10-27, latest 2026-11-21). The release history shows 15 tags: an initial sequence from v0.1.0 through v0.8.1 that established the core API, then five beta releases working toward v1.0.0. There are two test targets — `SwiftHTTPServiceTests` for the core and `SwiftHTTPServiceNIOTests` for the transport layer. The package is not yet at a stable 1.0.0 release; `ijs-dashboard-server`, the stated first consumer, has not shipped against it yet.

## Decisions

**No NIO in the core.** Keeping `SwiftHTTPService` free of SwiftNIO means every routing and middleware test runs as a pure function call. The tradeoff is an additional layer of indirection between the core request/response types and the wire.

**Apple-vended dependencies only (for the core).** Using `swift-http-types` as the shared request/response vocabulary makes the package consistent with the direction Apple's own frameworks are heading, and it avoids pulling in community packages that could introduce API instability or licensing concerns.

**Strict failure modes by default.** Refusing ambiguous targets and rejecting contradictory configuration at startup rather than attempting recovery makes failure visible early. The alternative — normalizing or silently correcting — would hide integration mistakes in `ijs-dashboard-server` and later consumers.

**Configuration validation at startup.** A configuration that contradicts itself refuses to start rather than running in a degraded state. This was a deliberate policy choice over permissive defaults.

**What is unfinished.** The package is in beta. `ijs-dashboard-server` has not yet integrated it, so the design has not been validated against a real consumer with 19 routes in production. The design proposal document referenced in MASTER_PLAN.md is not present in the committed artifacts, so some of the original design intent is not directly auditable. HTTP/2 support is wired in through `swift-nio-http2` but the extent of its test coverage is not recorded in the available data.
