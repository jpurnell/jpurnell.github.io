---
title: SwiftWebAuthn: Server-Side WebAuthn Verification in Swift
description: A Swift package that verifies WebAuthn's registration and authentication ceremonies on the server, written from the W3C specification, so passkeys can replace passwords rather than supplement them.
date: 2026-11-02 11:40
lastModified: 2026-11-10
tags: showcase, swiftwebauthn, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SwiftWebAuthn
published: true
---

# SwiftWebAuthn: Server-Side WebAuthn Verification in Swift

> A Swift package that verifies WebAuthn's registration and authentication ceremonies on the server, written from the W3C specification, so passkeys can replace passwords rather than supplement them.

## Motivation

SwiftWebAuthn implements the two WebAuthn ceremonies — registration and authentication — on the server side. The driving use case is `SwiftIdentity`, a separate package where passkeys are the only credential kind, not an optional alternative to a passphrase. The goal is to make passkeys the default path for authenticating on Apple devices, where platform authenticators and iCloud Keychain already make them practical.

The project has a written condition for its own retirement: if the maintained community implementation reaches a state that meets the bar defined in the project plan, this package should be replaced by it. That condition is documented so the decision is explicit rather than drifted into.

## Approach

The package is written from the W3C WebAuthn specification directly. No code and no tests were copied from other implementations; the spec steps are followed in order and checked in order. The rationale is to avoid any licence ambiguity and to keep the relationship to the specification explicit.

No cryptographic primitives are implemented here. All mathematics are delegated to `swift-crypto`. SwiftWebAuthn parses the wire format, walks the specification's verification steps, and delegates the actual cryptographic operations.

The package includes a CBOR decoder scoped to the subset of CBOR that an attestation object uses. It rejects everything outside that subset. The intent is to fail closed on attacker-supplied bytes rather than to be a general-purpose CBOR library.

The dependency list reflects this division of responsibility: `swift-crypto` for the mathematics, `SwiftDeterminism` and `swift-identity` for integration with the broader identity infrastructure, and `swift-docc-plugin` for documentation generation.

The target list includes a `CaptureHTTP` target and a `webauthn-capture` executable alongside the main library and its identity integration layer. These support development-time ceremony capture for testing real authenticator responses against the verifier.

## Results

Three releases shipped across roughly seven weeks: 0.1.0, 0.2.0, and 0.2.1. The repository has 31 commits from one contributor. The package targets macOS and is built with Swift tools version 6.2. Test targets exist for the core library (`SwiftWebAuthnTests`), the identity integration (`SwiftWebAuthnIdentityTests`), and the HTTP capture harness (`CaptureHTTPTests`).

## Decisions

**Written from the specification, not from an existing implementation.** The project plan names this explicitly and gives the reason: no copied code means no licence question, and the specification is the authoritative source regardless. A maintained external implementation is kept as a comparison bar, not a starting point.

**Narrow CBOR decoder rather than a general one.** The attestation object uses a small, predictable subset of CBOR. Accepting only that subset means attacker-supplied bytes that fall outside it are rejected at the parser rather than passed further into verification logic.

**No cryptographic primitives.** The choice to delegate all mathematics to `swift-crypto` keeps the attack surface of this package limited to parsing and step sequencing. The correctness of the elliptic curve operations and hashing is `swift-crypto`'s responsibility.

**A capture harness as a development tool.** The `webauthn-capture` executable and `CaptureHTTP` target exist so real authenticator responses can be captured during development and replayed against the verifier. This makes it possible to test with actual platform authenticator output rather than synthetic test vectors alone.

**The abandonment condition is written down.** The project plan states the condition under which this package should be replaced by the maintained community implementation. This is unresolved in the sense that the condition has not been evaluated yet — the package is under active development and the community implementation's state relative to that bar has not been formally assessed.
