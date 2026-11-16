---
title: SwiftHTTPService: HTTP/1.1 and TLS Service Kit for Swift
description: A focused Swift package that layers routing, middleware, problem details, and a bounded NIO transport on top of `swift-http-types`, closing a gap in a larger server stack.
date: 2026-11-16 11:32
lastModified: 2026-11-16
tags: showcase, swifthttpservice, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SwiftHTTPService
published: true
---

# SwiftHTTPService: HTTP/1.1 and TLS Service Kit for Swift

> A focused Swift package that layers routing, middleware, problem details, and a bounded NIO transport on top of `swift-http-types`, closing a gap in a larger server stack.

## Motivation

I had a gap in what I call the Stack Map: the `http-service` slot, the layer that sits between raw sockets and application route handlers. The first concrete consumer waiting on it was `ijs-dashboard-server` — 19 routes, bearer auth, ETag/304 conditional requests, problem+json error responses, TLS, and graceful shutdown. Rather than reach for a full framework, I wanted a small kit that covered exactly that surface and no more.

The specific thing I wanted from the library: servers built on it write routes and handlers, not socket code. The transport details stay inside the package.

## Approach

The package is split into two targets that reflect a hard architectural boundary: `SwiftHTTPService` contains routing and middleware and has no NIO dependency at all. `SwiftHTTPServiceNIO` adds the transport — NIO, NIO extras, HTTP/2, and TLS via SwiftTLSKit — and sits on top of the core. This means the routing logic can be tested without a network stack present.

The dependency list is intentionally narrow and Apple-vended where possible: `swift-http-types` in the core; `swift-nio`, `swift-nio-extras`, `swift-nio-http2`, and SwiftTLSKit in the transport layer. The `swift-docc-plugin` is included for documentation generation.

The package targets macOS and iOS and is built against Swift Tools version 6.2.

Three things are strict by default: an ambiguous request target is refused rather than normalised; a configuration that contradicts itself prevents startup rather than producing undefined behavior at runtime; and error detail text is never forwarded to a client response. These are policy decisions baked into the core, not left to callers.

A `CLAUDE.md` file was present to orient Claude Code sessions. Three sessions ran, contributing 33 commits of the 99 total and generating 101 messages. The friction log across those sessions records ten friction events — tool failures, environment limitations, two rejected actions, one instance of buggy generated code — with two sessions marked `mostly_achieved` and one `fully_achieved`. The remaining 66 commits were written directly.

There was no formal design-first workflow and no separate design proposal document on disk, though `MASTER_PLAN.md` references a design proposal path (`project/plans/proposals/DesignProposal_SwiftHTTPService.md`) as the authoritative design source.

## Results

The project reached fourteen releases across roughly seventeen days (first commit 2026-10-27, latest 2026-11-13): `v0.1.0` through `v0.8.1`, then four beta releases culminating in `v1.0.0-beta.4`. The release history shows an increment roughly every day or two during active development. There are two branches and 99 commits from one contributor. Test targets exist for both the core (`SwiftHTTPServiceTests`) and the NIO layer (`SwiftHTTPServiceNIOTests`).

The package is not yet at a stable 1.0 release; it sits at `v1.0.0-beta.4`.

## Decisions

**No NIO in the core.** Routing and middleware are pure Swift with no network dependency. This was the central structural decision. It makes the core independently testable and means the NIO transport can be replaced or extended without touching route logic.

**Apple-vended dependencies only in the core.** `swift-http-types` is the sole core dependency. Third-party code (SwiftTLSKit) enters only in the transport target. The intent is to keep the core stable against dependency churn.

**Strict refusal over normalisation.** An ambiguous request target returns an error rather than attempting to interpret intent. This is a deliberate tradeoff: it places more burden on well-formed clients but removes a category of silent misbehavior from the server.

**Configuration validation at startup.** A contradictory configuration refuses to start. The alternative — detecting conflicts at request time — was not taken because it would surface errors later and in harder-to-diagnose contexts.

**Error text suppression.** Internal error messages are never sent to clients. Problem details responses are structured, not raw exception strings. This is a default, not an option callers can disable at the call site.

**What is unfinished.** The library is in beta. The first real consumer, `ijs-dashboard-server`, has not yet integrated it; that integration will be the first real test of whether the API surface is right. HTTP/2 is included as a dependency but its status as a fully exercised path versus a stub is not recorded in the available data. The design proposal document referenced in `MASTER_PLAN.md` was not present among the tracked design artifacts, so the degree to which the implementation matches the original written design is unclear from the outside.
