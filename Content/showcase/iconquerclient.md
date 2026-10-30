---
title: Bridging the Transport Gap: IconquerClient's Transparent Remote Play Architecture
description: A SwiftNIO-backed WebSocket client library that makes a remote iConquer game session indistinguishable from a local one — and refuses to be less secure than its URL implies.
date: 2026-05-12 15:56
lastModified: 2026-10-30
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# Bridging the Transport Gap: IconquerClient's Transparent Remote Play Architecture

> A SwiftNIO-backed WebSocket client library that makes a remote iConquer game session indistinguishable from a local one — and refuses to be less secure than its URL implies.

## Problem

Multiplayer games built with a shared local-and-remote codebase face a persistent UI problem: the presentation layer has to know which transport it's talking to. Branch on `isRemote`, thread connection state through view models, handle opaque errors from the network stack — it compounds fast. IconquerClient was built to eliminate that branching entirely for the iConquer ecosystem.

The library serves a specific triangle of consumers: `IconquerApp` and `IconquerUI` on the remote-play path, any Swift client that needs to join a hosted iConquer game, and test harnesses that need to exercise the server's protocol directly. All three of those use cases demand the same thing: a session that behaves like a local game, regardless of what's underneath.

The secondary problem is infrastructure reach. URLSession WebSockets are a Apple-platform-only story. IconquerClient was built from the start to treat server-side Swift and Linux as first-class targets, which ruled out URLSession as a foundation.

## Approach

The architectural centerpiece is the transport abstraction: a remote game session presented behind the same interface shape as a local one. The UI layer has no branch for "am I talking to a WebSocket or to an in-process engine?" — IconquerClient's conformance to whatever session protocol `IconquerCore` defines handles that. This keeps the presentation layer honest and keeps the library's contract narrow.

SwiftNIO is the networking substrate, pulled in alongside `SwiftTLSKit` for TLS handling. That stack compiles and runs on Linux, meaning the same library can be used in server-side test harnesses and in an iOS app without conditional compilation gymnastics. The Swift 6.2 toolchain and strict concurrency settings were chosen to make the async transport story sound from the start, not retrofitted later.

The error model is typed rather than opaque. Connection failures and server rejections surface as concrete error cases, not `Error`-erased blobs that callers have to inspect with `as?` casts. That decision keeps integration sites clean and makes test harnesses straightforward to write.

The scheme-enforcement rule is the sharpest single policy in the library: `wss://` means TLS or it means an error. There is no silent fallback to plaintext. The URL's scheme is a contract, and violating it is a hard failure rather than a quiet degradation.

## Results

IconquerClient shipped two tagged releases — `v0.1.0` and `v0.2.0` — across 26 commits on a timeline running from April to October 2026. The library targets all four Apple platforms (macOS, iOS, tvOS, visionOS) plus the Linux-capable SwiftNIO stack, a breadth that reflects the library's explicit cross-platform mandate. A dedicated `IconquerClientTests` target exists alongside the main library target, providing the test harness surface the MASTER_PLAN.md identified as a first-class consumer. The library's dependency surface is intentional and contained: `IconquerCore` for the shared protocol types, `SwiftTLSKit` and `swift-nio` for the transport, and `swift-docc-plugin` signaling that documentation is treated as a deliverable rather than an afterthought.

## Judgment Calls

**The session shape decision is the most consequential design call in the library.** Presenting a remote session behind the same interface as a local one is not a natural default — it requires discipline about what leaks through the abstraction and what doesn't. The payoff is that `IconquerApp` and `IconquerUI` can be written without transport awareness, which is a significant reduction in view-layer complexity. The cost is that IconquerClient has to own more of the session lifecycle. That tradeoff was made deliberately and held.

**Choosing SwiftNIO over URLSession WebSockets was a platform philosophy decision, not a features decision.** URLSession would have been faster to integrate. SwiftNIO was chosen because Linux and server-side Swift are first-class targets — not aspirational ones. That choice shapes the dependency graph, the concurrency model, and the long-term portability of the library.

**The `wss://` enforcement rule is an opinion expressed in code.** Many networking libraries treat scheme validation as a warning or a configuration option. IconquerClient treats it as a hard invariant: the scheme is a security contract, and a library that silently falls back to plaintext when TLS fails isn't actually providing a security guarantee. Surfacing that as a typed error rather than a silent behavior makes the library's stance legible to every integration site.

**Typed errors over opaque failures reflects a considered stance on API design.** It's more work to define and maintain a concrete error type than to throw a generic `Error`. But it makes test harnesses dramatically easier to write — which matters here because the MASTER_PLAN.md explicitly names test harnesses as a first-class consumer — and it makes integration-site error handling expressive rather than defensive.
