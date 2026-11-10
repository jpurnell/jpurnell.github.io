---
title: SwiftOAuthCore: Both Sides of OAuth 2.0 in One Swift Package
description: A Swift library that lets a service issue OAuth tokens and an application consume them, with storage left entirely to the caller.
date: 2026-10-30 12:25
lastModified: 2026-11-10
tags: showcase, swift-oauth, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SwiftOAuthCore
published: true
---

# SwiftOAuthCore: Both Sides of OAuth 2.0 in One Swift Package

> A Swift library that lets a service issue OAuth tokens and an application consume them, with storage left entirely to the caller.

## Motivation

Most OAuth libraries pick a side. A server library handles token issuance and validation; a client library handles token acquisition and refresh. The two roles share a name, a set of grant types, a `TokenResponse` structure, error codes, and PKCE — where the client generates the verifier the server validates — and that shared vocabulary is where drift happens when they live in separate packages.

I built SwiftOAuthCore to carry both halves in one package for two concrete reasons.

The first is `SwiftMCPClient`. It currently authenticates with a pasted bearer token and cannot connect to an OAuth-protected MCP server. The MCP specification requires OAuth, so there is a gap, not a preference. The client half of this library fills it.

The second is refresh-token rotation. Presenting a refresh token expires it. If the rotation response is lost in transit, if two requests race, or if the new token is stored after a crash, the user is locked out. These are not edge cases worth documenting in a README and leaving to the caller — they are the reason this is a library rather than a snippet. The rotation logic lives here once, so `SwiftMCPClient`, `LedgeOS`, `geo-audit`, and `Pare` do not each write it again.

Storage was always a protocol, not an implementation. A service already running Postgres should not need SQLite for its token store, and a test should not touch disk.

## Approach

The package is organized into separate targets by responsibility: `SwiftOAuthCore` for shared types, `SwiftOAuthProvider` for the authorization server side, `SwiftOAuthClient` for the consumer side, `SwiftOAuthMTLS` for mutual TLS, and `SwiftOAuthIdentity` for identity integration. `RedirectWireStub` exists as a test harness for the redirect flow. Conformance tests live in their own target so they can run against any storage implementation a consumer provides.

The dependency list reflects the platform Apple provides: `swift-crypto` for cryptographic primitives, `async-http-client`, `swift-nio`, and `swift-nio-ssl` for networking, `swift-certificates` and `swift-asn1` for the MTLS target, and `swift-docc-plugin` for documentation generation. `swift-identity` connects the identity target. The package targets macOS and iOS, built with Swift tooling version 6.2.

There were no design proposals and no design-first workflow. The shape of the API emerged from the requirements of the first two planned adopters — `SwiftMCPServer` on the provider side, `SwiftMCPClient` and `LedgeOS` on the client side — and was revised across 29 releases.

## Results

The project reached v1.0.0-beta.10 across 145 commits between August and November 2026, with one contributor. The release history runs from v0.0.1 through fourteen pre-1.0 minor versions to ten beta releases of v1.0.0, covering provider, client, MTLS, and identity targets. Test targets exist for each library target — `SwiftOAuthCoreTests`, `SwiftOAuthMTLSTests`, `SwiftOAuthProviderTests`, `SwiftOAuthConformanceTests`, `SwiftOAuthIdentityTests`, and `SwiftOAuthClientTests`.

The package has not shipped a stable v1.0.0 release. It is in active beta.

## Decisions

**Both halves in one package.** The alternative was two packages. I chose one because the shared types — grant types, `TokenResponse`, error codes, PKCE — would have to be duplicated or extracted into a third package either way. One package keeps that vocabulary in one place.

**Storage as a protocol.** The package defines what must be persisted; it does not provide a storage implementation. This was a constraint from the start, driven by the target adopters: a production service should not be forced into a storage engine it did not choose, and a test should run without side effects.

**Rotation correctness as a first-class concern.** The three failure modes of refresh-token rotation — lost response, concurrent request, post-crash storage failure — are handled inside the library rather than documented as the caller's problem. This is the strongest argument for the library existing at all rather than circulating as a snippet.

**Beta versioning.** The jump from v0.14.1 to v1.0.0-beta.1 reflects a deliberate API stabilization effort before committing to a stable interface. What remains uncertain is whether the conformance test target covers enough of the rotation failure modes to serve as a contract for third-party storage implementations. That is unresolved before v1.0.0.

**No CLAUDE.md, no AI-assisted sessions.** All 145 commits are from direct authorship. The development record shows no Claude Code sessions.
