---
title: IconquerClient: WebSocket Client Library for iConquer Multiplayer
description: A Swift library that connects to the iConquer game server over WebSocket and presents the remote session through the same interface as a local game, so the UI layer doesn't branch on transport.
date: 2026-05-12 15:56
lastModified: 2026-11-10
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# IconquerClient: WebSocket Client Library for iConquer Multiplayer

> A Swift library that connects to the iConquer game server over WebSocket and presents the remote session through the same interface as a local game, so the UI layer doesn't branch on transport.

## Motivation

iConquer is a multiplayer strategy game I'm building. The server hosts games, and clients need a way to join and participate over the network. I wanted the presentation layer — `IconquerApp` and `IconquerUI` — to treat a remote game session identically to a local one. That meant the client library had to conform to whatever session shape the rest of the system already expected, hiding the transport entirely.

I also wanted this library usable by test harnesses that exercise the server protocol, not just by the UI. That argued for keeping it a standalone Swift package rather than embedding it in the app target.

## Approach

The library is written in Swift and targets macOS, iOS, tvOS, and visionOS. It depends on SwiftNIO rather than URLSession's built-in WebSocket support. The motivation for that choice is that the iConquer server itself is server-side Swift, and SwiftNIO keeps the networking layer consistent on both sides. It also means the client can run on Linux if a test harness ever needs it.

Transport selection is scheme-driven: a `wss://` URL gets TLS via SwiftTLSKit; anything else that isn't `ws://` is an error. There's no fallback to plaintext when TLS is requested. Connection state and server rejections surface as typed Swift errors rather than opaque string messages or untyped callbacks.

The package declares two targets — `IconquerClient` and `IconquerClientTests` — and pulls in `IconquerCore` for the shared protocol types that both the server and client understand.

There were no design proposals or formal design-first documents. No Claude Code sessions were involved in this work.

## Results

The project reached two tagged releases — v0.1.0 and v0.2.0 — across 26 commits from a single contributor, with development running from April 2026 through October 2026. Two branches exist in the repository. The library covers macOS, iOS, tvOS, and visionOS as declared platform targets.

## Decisions

**SwiftNIO over URLSession WebSockets.** URLSession's WebSocket API is Apple-platform-only and doesn't align with the server's own networking layer. SwiftNIO works across platforms and matches what the server uses, which simplifies reasoning about protocol behavior end to end.

**Scheme-based transport selection.** Rather than accepting a flag or configuration option to toggle TLS, the URL scheme determines the transport. `wss://` means TLS or failure; `ws://` means plaintext. This removes a class of misconfiguration where TLS is intended but not enforced.

**Typed errors over opaque failures.** Connection state transitions and server rejections are represented as specific Swift error types rather than generic errors or string descriptions. This makes it possible for callers to handle specific failure modes rather than inspecting messages.

**Conforming to the local session interface.** The remote session presents the same shape as a local game session so the UI doesn't need a branch for remote vs. local play. This is the central architectural constraint the library is built around, and it's what ties the dependency on `IconquerCore` together — both sides of the connection share the same protocol types.

What remains unfinished or uncertain: the two-branch structure suggests active development, and v0.2.0 is the latest public release as of October 2026. I haven't published specific test coverage numbers. The test target exists, but how thoroughly the protocol edge cases are exercised isn't captured here.
