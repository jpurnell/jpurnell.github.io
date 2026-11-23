---
title: IconquerClient: WebSocket Client Library for iConquer Multiplayer
description: A Swift library that connects to the iConquer game server over WebSocket and presents the remote session through the same interface as a local game, so the UI doesn't branch on transport.
date: 2026-05-12 15:56
lastModified: 2026-11-23
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# IconquerClient: WebSocket Client Library for iConquer Multiplayer

> A Swift library that connects to the iConquer game server over WebSocket and presents the remote session through the same interface as a local game, so the UI doesn't branch on transport.

## Motivation

iConquer is a multiplayer game with a hosted server. The presentation layer — `IconquerApp` and `IconquerUI` — needed a way to join remote games without duplicating game-session logic or scattering transport conditionals through UI code. I wanted a client library that could slot into the same interface shape as a local session, so the UI remains unaware of whether the game is running locally or over a network.

A secondary goal was Linux compatibility. URLSession's WebSocket support is Apple-platform-only, which rules it out for test harnesses or any future server-side Swift tooling. I wanted the client to work in those environments from the start rather than retrofit it later.

## Approach

The library is built on SwiftNIO rather than URLSession, which makes macOS, iOS, tvOS, visionOS, and Linux all first-class targets. TLS is handled through SwiftTLSKit, also a dependency here.

The central design constraint is the transport abstraction: the client conforms to the same session interface that the local game path uses, so `IconquerApp` doesn't need to know which path it's on. Connection state and server rejections are typed errors rather than string messages or opaque `Error` values, which makes handling them at the call site explicit.

The URL scheme drives transport selection. If the scheme is `wss://`, the library negotiates TLS; if TLS setup fails, it's an error. There's no silent fallback to plaintext. `ws://` uses plaintext. Any other scheme is rejected at connection time. This keeps the security boundary auditable from a single point.

The package declares targets for `IconquerClient` and `IconquerClientTests`, depends on `IconquerCore` for shared game-protocol types, and uses `swift-docc-plugin` for documentation generation.

## Results

The project reached v0.3.0 across four releases (v0.1.0, v0.2.0, v0.3.0-beta.1, v0.3.0) over roughly seven months, with 29 commits from one contributor. It targets macOS, iOS, tvOS, and visionOS. The library is consumed by the `IconquerApp` remote-play path as its primary production use.

## Decisions

**SwiftNIO over URLSession WebSockets.** URLSession's WebSocket API isn't available on Linux, which would have blocked test harnesses and any server-side tooling. SwiftNIO runs everywhere Swift does, so this was a prerequisite for the cross-platform goal, not a preference.

**Same interface as local sessions.** The main value the library provides to `IconquerApp` is hiding the transport. If the client had its own distinct interface, every UI component that touches game state would need a branch. Making it conform to the same shape as the local path meant the presentation layer needed no changes when the remote path was added.

**Scheme-driven TLS, no plaintext fallback.** Letting a `wss://` URL silently fall back to plaintext on TLS failure would be worse than an error — it would succeed quietly in an insecure state. The current behavior treats `wss://` as a contract: TLS or failure. This makes the security posture legible without reading implementation details.

**What's unfinished.** The test target exists but the commit history doesn't show how extensively it's exercised. Reconnection behavior after dropped connections isn't documented in the available materials, so it's unclear whether the library handles that or leaves it to callers. The project has one contributor; the protocol details live in `IconquerCore`, which means changes to the server protocol require coordinated updates across both packages.
