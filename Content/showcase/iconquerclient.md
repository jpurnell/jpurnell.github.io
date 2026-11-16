---
title: IconquerClient: WebSocket Client Library for iConquer Multiplayer
description: A Swift library that connects to the iConquer game server over WebSockets and exposes the remote session behind the same interface as a local game.
date: 2026-05-12 15:56
lastModified: 2026-11-16
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# IconquerClient: WebSocket Client Library for iConquer Multiplayer

> A Swift library that connects to the iConquer game server over WebSockets and exposes the remote session behind the same interface as a local game.

## Motivation

iConquer is a multiplayer game with a hosted server. The presentation layer — `IconquerApp` and `IconquerUI` — already knows how to drive a local game session. The goal with IconquerClient was to let it drive a remote session through exactly the same interface, so the UI code doesn't need to branch on whether the game is local or networked.

Beyond that, I wanted a client that would work outside of Apple's platforms. URLSession WebSockets ties you to Apple's frameworks; building on SwiftNIO means the library can run in test harnesses on Linux and alongside server-side Swift code without any platform conditionals.

## Approach

The library targets macOS, iOS, tvOS, and visionOS and is built with Swift Package Manager using Swift tools version 6.2. Its dependencies are IconquerCore (which defines the shared game protocol types), SwiftTLSKit, SwiftNIO, and swift-docc-plugin.

The transport is SwiftNIO rather than URLSession. This was a deliberate choice to keep Linux and server-side Swift as first-class targets, not afterthoughts.

TLS is handled by scheme inspection: if the URL uses `wss://`, the library negotiates TLS via SwiftTLSKit; if it doesn't, the connection fails with a typed error rather than silently falling back to plaintext. There is no way to request a secure connection and get an insecure one.

Connection state and server rejections are represented as typed errors throughout. The library doesn't return opaque failure values; every failure condition the server can produce maps to a specific error type the caller can match against.

## Results

The library has shipped four releases: v0.1.0, v0.2.0, v0.3.0-beta.1, and v0.3.0, across 29 commits from a single contributor between April and November 2026. There are two branches in the repository. The test target, IconquerClientTests, is present in the package manifest.

## Decisions

**SwiftNIO over URLSession WebSockets.** URLSession WebSockets is Apple-only. SwiftNIO runs on Linux, which matters for test harnesses that exercise the server protocol and for any future server-side Swift usage. The cost is a heavier dependency and more explicit connection management; the benefit is that the library works wherever Swift runs.

**Scheme-driven transport with hard TLS enforcement.** The URL scheme is the only configuration point for transport security. `wss://` triggers TLS; anything else is an error. This removes the possibility of a misconfiguration that silently degrades to plaintext, but it means callers have to supply the right scheme and can't opt into TLS through a separate flag.

**Matching the local session interface.** Presenting the remote session behind the same shape as a local one means the UI doesn't need to know about the transport. The tradeoff is that the abstraction has to be maintained as the local session interface evolves — changes to IconquerCore's protocol types propagate to this library.

**No design proposals and no Claude Code usage.** The project has no recorded design proposal documents and no Claude Code sessions; the architecture was worked out directly in code. What remains unfinished or uncertain isn't recorded in the available metadata, but the presence of a beta release before v0.3.0 suggests at least one round of revision before that version stabilized.
