---
title: SwiftOAuthCore: Both Halves of OAuth 2.0, One Swift Package
description: A solo-built Swift library that handles token issuance and token consumption in a single, storage-agnostic package — purpose-built to close a real authentication gap in a live ecosystem of apps.
date: 2026-10-30 12:25
lastModified: 2026-10-30
tags: showcase, swift-oauth, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SwiftOAuthCore
published: true
---

# SwiftOAuthCore: Both Halves of OAuth 2.0, One Swift Package

> A solo-built Swift library that handles token issuance and token consumption in a single, storage-agnostic package — purpose-built to close a real authentication gap in a live ecosystem of apps.

## Problem

OAuth 2.0 has two distinct roles that happen to share a name: a server that issues tokens and validates its own, and a client that obtains tokens from someone else and keeps them fresh. Most libraries pick one side. That choice forces teams to either stitch two libraries together — duplicating shared vocabulary like grant types, `TokenResponse`, and PKCE — or write the plumbing themselves.

For J. Purnell, the problem was concrete, not hypothetical. `SwiftMCPClient` was authenticating via pasted bearer tokens. The MCP specification itself requires OAuth, which meant that gap wasn't cosmetic — it was a conformance failure. On the other side of the ecosystem, `SwiftMCPServer` needed to act as an authorization server, and `LedgeOS`, `geo-audit`, and `Pare` were lined up as client consumers. The question was never whether to build authentication infrastructure. It was whether to build it once or repeatedly.

The third pressure was refresh-token rotation. When a refresh token is presented, it is consumed. Three specific failure modes follow from that — races, network drops at the wrong moment, retry logic that re-presents an already-expired token — and each one silently locks a user out of their own data. That problem is complicated enough that it justifies a library over a snippet.

## Approach

SwiftOAuthCore is structured as a Swift package targeting macOS and iOS, organized into purpose-specific targets that reflect the library's dual mandate: `SwiftOAuthCore` holds shared vocabulary, `SwiftOAuthMTLS` handles mutual TLS, `SwiftOAuthIdentity` manages identity concerns, `SwiftOAuthProvider` implements the server side, and `SwiftOAuthClient` implements the consumer side. A `RedirectWireStub` target exists for testing redirect-based flows without running live infrastructure.

The dependency selection reflects the Swift server ecosystem directly — `swift-nio` and `async-http-client` for async networking, `swift-crypto` and `swift-certificates` with `swift-asn1` for cryptographic operations including mTLS, and `swift-docc-plugin` signaling that documentation is treated as a deliverable rather than an afterthought. The addition of `swift-identity` ties into the broader ecosystem where these pieces will be consumed.

The most consequential architectural decision is the storage protocol boundary. The library defines what must be persisted — tokens, rotation state, client registrations — but imposes nothing about where. A service running Postgres doesn't pull in SQLite. A test suite doesn't touch disk. This is the kind of decision that looks obvious in retrospect but requires making it explicitly early, before concrete storage assumptions leak into the core abstractions.

The package was built using Swift 6.2 tooling, meaning strict concurrency checking shaped the design from the start rather than being retrofitted later.

## Results

Over roughly eleven weeks between early August and late October 2026, Purnell shipped 143 commits across 28 tagged releases — from `v0.0.1` through fourteen minor and patch versions before pivoting to a beta series now at `v1.0.0-beta.9`. That release cadence, averaging more than two releases per week, reflects a library being iterated against real consumer needs rather than developed in isolation.

The test coverage spans six dedicated test targets — `SwiftOAuthCoreTests`, `SwiftOAuthMTLSTests`, `SwiftOAuthProviderTests`, `SwiftOAuthConformanceTests`, `SwiftOAuthIdentityTests`, and `SwiftOAuthClientTests` — with a conformance suite that sits separately from unit tests, suggesting the library is being held to specification correctness as a first-class concern. The beta series implies that the API surface is being stabilized with known consumers watching.

## Judgment Calls

**Carrying both halves.** The decision to implement provider and client in one package is the one that most libraries don't make. Purnell's reasoning, documented in the project's own MASTER_PLAN.md, is precise: the two roles share grant types, `TokenResponse`, error codes, and PKCE — specifically, the client generates the PKCE verifier that the server validates. Splitting the package would duplicate that vocabulary and create the conditions for it to drift. The single-package design isn't a shortcut; it's a claim about where the real coupling lives.

**Making rotation a first-class concern.** Refresh-token rotation is the kind of problem that looks solved until it isn't. Purnell identified three specific failure modes that each produce the same bad outcome — a user locked out of their own data with no readable error — and named them as the reason a library exists at all rather than a code snippet. Building the client half around those failure modes rather than around the happy path is a different kind of discipline, and it's visible in the structural choice to give the client its own test target.

**Storage as a protocol, not a default.** Choosing to express storage as a protocol boundary rather than bundling a default implementation is a form of respect for the consumer's existing infrastructure. It also makes the test story cleaner — `RedirectWireStub` exists because the redirect flow needs testable infrastructure, and that infrastructure can be ephemeral. The decision suggests Purnell was thinking about how the library would be adopted by real services rather than how it would pass its own tests.

**Beta discipline.** The shift from a minor-version series to a `v1.0.0-beta` series at `beta.9` reads as intentional semantic signaling — the core is stable enough to stabilize against, but the API contract isn't locked until known consumers have validated it in real use. That's what betas are for, and using them correctly is rarer than it should be.
