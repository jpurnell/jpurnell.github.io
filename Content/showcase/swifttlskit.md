---
title: SwiftTLSKit: Shared TLS Configuration for SwiftNIO Servers and Clients
description: A Swift package that centralises TLS identity, validation, trust, and live certificate reload logic that was previously duplicated across eleven SwiftNIO packages.
date: 2026-11-16 11:33
lastModified: 2026-11-16
tags: showcase, swifttlskit, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SwiftTLSKit
published: true
---

# SwiftTLSKit: Shared TLS Configuration for SwiftNIO Servers and Clients

> A Swift package that centralises TLS identity, validation, trust, and live certificate reload logic that was previously duplicated across eleven SwiftNIO packages.

## Motivation

I had TLS configuration code scattered across every SwiftNIO server and client I maintain. Each one repeated the same pattern: check whether cert and key paths were both set, build an SSL context if they were, skip TLS entirely if either was missing. That last part was the problem — passing one path and not the other would silently serve plaintext. Bugs in that logic had to be found and fixed in multiple places independently.

SwiftTLSKit is the single location for all of that: what files constitute a valid server identity, what conditions make them unfit to use, how a running server accepts a renewed certificate without restarting, and what a client is willing to trust. The goal was to write it once, test it once, and have every dependent package pull from one place.

## Approach

The package targets macOS, iOS, tvOS, and visionOS and is built on SwiftNIO's SSL layer: dependencies are `swift-nio`, `swift-nio-ssl`, `swift-crypto`, `swift-certificates`, `swift-asn1`, and `swift-docc-plugin`. Tools version is Swift Package Manager 6.2.

The architecture is strictly configuration-only. There are no sockets, no event loops, and no listener framework — the package produces TLS contexts and configuration values that callers hand to NIO, nothing more. That boundary was a deliberate constraint from the start.

Three design decisions run through the whole surface area. First, a half-configured identity is a hard error: if a caller supplies a certificate path without a key path (or the reverse), the initialiser refuses rather than falling back to plaintext. Second, all refusals are typed errors that name the offending path, not its contents, so diagnostics are specific without leaking key material. Third, the client API has no opt-out for peer verification — there is no "trust everything" case.

The package ships a `SwiftTLSKitTestSupport` target alongside the main library, giving dependents a consistent way to set up TLS fixtures in their own test suites.

One Claude Code session ran across 34 of the 45 total commits, covering 55 messages. The session log records one external blocker and one wrong-approach correction, with an overall outcome of mostly achieved.

## Results

The project ran from 6 October 2026 to 14 November 2026 across 45 commits on a single branch, with one contributor. Five releases shipped: 0.1.0, 0.2.0, 0.2.1, 1.0.0-beta.1, and 1.0.0.

As of 13 November 2026, eleven packages depend on SwiftTLSKit: FleetWatch, ijs-dashboard-server, SwiftHTTPService, SwiftPushHub, SwiftDiagnosticsHub, SwiftPenTest, IconquerClient, IconquerServer, IconquerTournament, IconquerCLI, and swiftMoE. All are pinned to either `.upToNextMinor(from: "0.2.0")` or `.upToNextMinor(from: "0.2.1")`. Three packages named in the original plan — SwiftMCPServer, SwiftMCPClient, and VaultMCP — have no SwiftTLSKit dependency despite being present on the same machine.

## Decisions

**Configuration-only scope.** The package does not manage sockets or event loops. This kept the API surface small and made the package usable from any NIO-based context without imposing a framework.

**Hard error on partial identity.** The copies this replaced built a TLS context only when both cert and key paths were present, silently falling through to plaintext otherwise. SwiftTLSKit treats a missing counterpart as a construction-time error. The tradeoff is that callers must handle the error explicitly, but they can no longer serve plaintext by accident.

**Typed, path-naming errors.** Error cases identify which path caused the refusal. This makes the information useful for diagnostics while avoiding any chance of logging key material.

**No verification bypass in the client API.** There is no case that accepts arbitrary certificates. Callers who need non-standard trust must configure it through explicit trust roots, not a flag that disables checking.

**SwiftTLSKitTestSupport as a shipped target.** Rather than leaving each dependent to roll its own TLS test fixtures, the support target is part of the package. This adds maintenance surface but means fixture bugs are also fixed in one place.

**Eleven dependents, three non-adopters.** SwiftMCPServer, SwiftMCPClient, and VaultMCP were named in the original plan as intended adopters and were not found in an early search because that search was scoped to the `Tools/` directory. A later scan of every `Package.swift` on the machine found them. They remain without a SwiftTLSKit dependency; whether they should adopt it is unresolved.
