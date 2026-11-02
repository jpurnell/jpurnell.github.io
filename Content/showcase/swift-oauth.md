---
title: SwiftOAuthCore: Both Halves of OAuth 2.0, One Swift Package
description: A solo Swift library project that tackles OAuth's two distinct roles — server and client — in a single, storage-agnostic package, built to eliminate the authentication gap in an ecosystem of Swift services and MCP clients.
date: 2026-10-30 12:25
lastModified: 2026-11-02
tags: showcase, swift-oauth, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SwiftOAuthCore
published: true
---

# SwiftOAuthCore: Both Halves of OAuth 2.0, One Swift Package

> A solo Swift library project that tackles OAuth's two distinct roles — server and client — in a single, storage-agnostic package, built to eliminate the authentication gap in an ecosystem of Swift services and MCP clients.

## Problem

OAuth 2.0 has two roles that share a name and almost no behavior. An authorization server issues tokens and validates its own; a client application obtains someone else's and keeps them fresh. Most libraries pick a side. The ecosystem of Swift services and clients that jpurnell maintains — `SwiftMCPServer`, `SwiftMCPClient`, `LedgeOS`, and others — needed both, and they needed them to speak the same vocabulary.

The immediate forcing function was concrete: `SwiftMCPClient` had no authentication beyond a pasted bearer token. It could not connect to an OAuth-protected MCP server, which MCP's own specification requires. That wasn't a missing feature to plan for later — it was a gap the spec had already closed around.

But the problem jpurnell chose to solve was larger than wiring up a token request. Refresh-token rotation is where OAuth implementations quietly fail users. Presenting a refresh token expires it. If the rotation response is lost, if the new token isn't persisted before it's used, if a concurrent request races ahead — any of these produces a locked-out user and a readable error nowhere. These failure modes are the reason SwiftOAuthCore is a library rather than a snippet copied between projects.

## Approach

The package is organized into deliberately scoped targets that mirror the conceptual split in OAuth itself. `SwiftOAuthCore` carries the shared vocabulary — grant types, `TokenResponse`, PKCE, error codes — while `SwiftOAuthProvider` and `SwiftOAuthClient` implement the server and client halves respectively. `SwiftOAuthMTLS` and `SwiftOAuthIdentity` extend the stack for mTLS and identity concerns without bloating the core. A `RedirectWireStub` target supports testing redirect flows without live infrastructure.

The most consequential architectural decision was making storage a protocol rather than a bundled dependency. The package specifies what must be persisted — tokens, rotation state, client records — not where. A production service behind Postgres brings its own adapter; a test never touches disk. This was a deliberate refusal to make the library's convenience the consumer's constraint.

The dependency graph reflects careful curation: `swift-crypto`, `async-http-client`, `swift-nio`, `swift-nio-ssl`, `swift-certificates`, `swift-asn1`, and `swift-identity` are all Apple or Apple-adjacent packages. The package targets Swift 6.2 and runs on both macOS and iOS, keeping the door open for client applications on either platform.

## Results

SwiftOAuthCore moved from v0.0.1 to v1.0.0-beta.10 across 145 commits and 29 releases in roughly three months — a sustained cadence that reflects both the scope of the problem and the discipline of iterating publicly rather than shipping late. The release history shows continuous forward motion: minor versions advancing the core feature set, point releases handling corrections and adjustments, and a beta series beginning at v1.0.0-beta.1 to signal API stabilization without prematurely locking the surface.

Six distinct test targets — `SwiftOAuthCoreTests`, `SwiftOAuthMTLSTests`, `SwiftOAuthProviderTests`, `SwiftOAuthConformanceTests`, `SwiftOAuthIdentityTests`, and `SwiftOAuthClientTests` — cover both individual modules and cross-cutting conformance, reflecting a testing strategy that tracks the architectural layering rather than bolting verification on at the end.

## Judgment Calls

**Carrying both halves.** Splitting server and client into separate packages would have felt cleaner on paper. jpurnell chose not to, and the reasoning is precise: the two roles share grant types, `TokenResponse`, error codes, and PKCE — specifically because the client generates the verifier the server validates. Splitting the package would duplicate that shared vocabulary and create the conditions for it to drift. The unified package is the judgment.

**Storage as protocol, not prescription.** It would have been faster to ship a SQLite adapter and call it done. The protocol-first approach requires more up-front design — the protocol surface has to be right, because consumers will implement against it — but it means a service already running Postgres doesn't acquire a second database to satisfy the library. The design respects the production environments the library will actually enter.

**Taking rotation seriously as a quality standard.** Jpurnell's own MASTER_PLAN.md names three specific rotation failure modes and frames them as the reason this is a library at all. That framing is unusual and telling — it means the scope of the project was defined not by what was easy to ship but by what was necessary to get right. The `SwiftOAuthConformanceTests` target exists, in part, because correct rotation behavior needs to be verified against a standard, not just against the library's own assumptions.

**A sustained beta series.** Beginning the v1.0.0 beta track while downstream consumers (`SwiftMCPClient`, `LedgeOS`) haven't yet adopted the library reflects a mature instinct about API stability. The betas give jpurnell room to adjust the surface under real integration pressure before committing to a stable contract — rather than discovering breaking changes after the first dependent ships.
