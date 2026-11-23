---
title: SwiftTLSKit: Centralised TLS Configuration for SwiftNIO Servers and Clients
description: A Swift package that consolidates TLS identity, trust, and certificate-rotation logic duplicated across eleven dependent packages into one tested place.
date: 2026-11-23 11:33
lastModified: 2026-11-23
tags: showcase, swifttlskit, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SwiftTLSKit
published: true
---

# SwiftTLSKit: Centralised TLS Configuration for SwiftNIO Servers and Clients

> A Swift package that consolidates TLS identity, trust, and certificate-rotation logic duplicated across eleven dependent packages into one tested place.

## Motivation

I had TLS configuration scattered across every SwiftNIO server and client I maintain. Each one repeated the same pattern: check whether a certificate path and key path were both present, then build a TLS context if so. The problem with that pattern is what happens when only one of the two is supplied — it silently falls back to plaintext. No error, no log line, just an unencrypted connection.

I built SwiftTLSKit to hold all of that logic once: what files constitute a valid server identity, what conditions make them unfit to serve, how a running server accepts a renewed certificate without restarting, and what a client is prepared to trust. The intent was that any package needing TLS configuration would pull it from here rather than re-implement it.

## Approach

The package targets macOS, iOS, tvOS, and visionOS and is built against Swift Tools version 6.2. It depends on swift-nio, swift-nio-ssl, swift-crypto, swift-certificates, and swift-asn1 — the standard Apple-maintained stack for NIO-based TLS work — plus swift-docc-plugin for documentation generation.

The library has three targets: `SwiftTLSKit` (the library itself), `SwiftTLSKitTestSupport` (fixtures and helpers for dependents writing their own TLS tests), and `SwiftTLSKitTests` (the package's own test suite).

The design constraints were stated in the project plan and shaped the API directly:

- A half-configured identity is an error at construction time, not a silent plaintext fallback.
- Errors name the filesystem path involved, never the file contents.
- The client trust API has no case that disables verification.
- The package stops at configuration — no sockets, no event loops, no listener management.

A CLAUDE.md file was present throughout development and carried session-start instructions, the quality gate, key rules, and notes specific to this package. One Claude Code session covered 34 of the 54 total commits across 55 messages, handling multiple tasks. That session was recorded as mostly achieved, with one external blocker and one wrong-approach friction point noted.

## Results

The project ran from 6 October 2026 to 21 November 2026 across 54 commits on 2 branches, with six releases: 0.1.0, 0.2.0, 0.2.1, 1.0.0-beta.1, 1.0.0, and 1.0.1.

Eleven packages now depend on SwiftTLSKit: FleetWatch, ijs-dashboard-server, SwiftHTTPService, SwiftPushHub, SwiftDiagnosticsHub, SwiftPenTest, IconquerClient, IconquerServer, IconquerTournament, IconquerCLI, and swiftMoE. All eleven were confirmed by scanning every `Package.swift` on the machine for a SwiftTLSKit dependency. Six of them pin to `.upToNextMinor(from: "0.2.1")` and four Iconquer packages pin to `.upToNextMinor(from: "0.2.0")`.

Three packages that were named in the original plan as expected adopters — SwiftMCPServer, SwiftMCPClient, and VaultMCP — have not added the dependency. They are on the same machine; the initial search missed them because it looked only inside the `Tools/` directory rather than scanning all `Package.swift` files.

## Decisions

**Errors at construction, not at connection time.** The copies this replaces deferred the problem: if one of two required paths was missing, the server started on plaintext. SwiftTLSKit makes an incomplete identity a construction error so the failure is visible at startup.

**Typed errors that name the path.** Diagnostic messages include the path that caused the problem, not the file contents. This was a deliberate constraint: TLS private key material should not appear in logs or error strings.

**No trust-anything escape hatch.** The client API was written without a case that disables certificate verification. Adding one later would require a deliberate API change rather than setting a flag.

**Configuration scope only.** The package does not manage sockets, event loops, or listeners. That boundary keeps it composable — dependents supply their own NIO infrastructure and hand SwiftTLSKit the configuration questions.

**What is unfinished.** SwiftMCPServer, SwiftMCPClient, and VaultMCP were listed in the original plan as targets for adoption and have not moved. Whether they need TLS configuration that SwiftTLSKit can supply, or whether their use case falls outside what the package does, is not settled.
