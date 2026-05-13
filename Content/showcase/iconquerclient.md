---
title: IconquerClient: A Cross-Platform Swift Networking Client Built for Modern Apple Ecosystems
description: In roughly two weeks and three focused commits, a lean Swift package took shape — bringing structured networking and async I/O to macOS, iOS, tvOS, and visionOS under a single, well-tested library target.
date: 2026-05-12 15:56
lastModified: 2026-05-12
tags: showcase, iConquer, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: iConquer
published: true
---

# IconquerClient: A Cross-Platform Swift Networking Client Built for Modern Apple Ecosystems

> In roughly two weeks and three focused commits, a lean Swift package took shape — bringing structured networking and async I/O to macOS, iOS, tvOS, and visionOS under a single, well-tested library target.

## Problem

Networked applications across Apple's platform family often repeat the same boilerplate: connection management, logging integration, async coordination. When the Iconquer ecosystem needed a dedicated client library, the goal was to build something reusable and portable — not another one-off networking layer buried inside a single app target. The challenge was delivering a clean abstraction over Swift NIO's event-driven I/O that felt natural to Swift 6 consumers across every relevant Apple platform.

## Approach

The library was structured as a focused Swift Package Manager package, targeting Swift tools version 6.2 and declaring explicit platform support for macOS, iOS, tvOS, and visionOS from the outset. Rather than writing a bespoke I/O layer, the project reached for `swift-nio` as the async networking foundation — a deliberate choice that trades a lighter dependency footprint for production-grade event loop management and connection handling without reinventing low-level primitives.

Alongside `swift-nio`, `swift-log` was brought in as the observability backbone. Tying log output to the standard Swift logging ecosystem means consumers can route IconquerClient's diagnostic output through their own logging handlers — a small but meaningful integration point for library users who care about operational visibility.

Documentation was treated as a first-class concern from the start: the inclusion of `swift-docc-plugin` signals an intent to ship developer-facing docs as part of the build pipeline, not as an afterthought.

The package is organized into two targets — `IconquerClient` and `IconquerClientTests` — keeping the production surface clean and the test boundary explicit.

## Results

Over a 13-day development window spanning late April to early May 2026, the library landed across three commits on a single focused branch. The dual-target structure is in place, cross-platform declarations are established, and the dependency graph is locked to three well-maintained Swift open-source packages. The library is positioned for consumption by any Apple-platform application that needs to communicate with Iconquer services, with a public API ready to be documented via DocC.

## Judgment Calls

Several decisions here reflect library-authorship thinking rather than application-building instincts.

**Choosing swift-nio over URLSession.** For a library targeting all four Apple platforms, URLSession would have been the path of least resistance. Reaching for swift-nio instead suggests the client is doing something closer to the metal — likely persistent connections, custom protocols, or multiplexed I/O — where URLSession's abstractions would have gotten in the way.

**Adopting Swift 6 tooling immediately.** Swift 6's strict concurrency model is stricter to satisfy but produces libraries that are genuinely safer for consumers running their own actor-isolated or structured-concurrency code. Opting into tools version 6.2 early means IconquerClient's public API is designed for Swift concurrency from day one, rather than inheriting the technical debt of an async retrofit.

**Four-platform declaration upfront.** Listing macOS, iOS, tvOS, and visionOS in the manifest before the library was fully built is a constraint that keeps cross-platform compatibility honest throughout development. It's easier to declare broad support early and let the compiler enforce it than to bolt on platform support after the fact.

**Documentation infrastructure on day one.** Adding `swift-docc-plugin` in the initial dependency set rather than the final one is a subtle tell about working style — documentation isn't a polish pass, it's part of the definition of done.
