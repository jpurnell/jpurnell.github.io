---
title: SwiftWebAuthn: Server-Side Passkey Verification, Written From the Specification
description: A Swift package that implements WebAuthn's registration and authentication ceremonies on the server, built from the W3C specification so that passkeys can be the default way a person proves identity — not a fallback.
date: 2026-11-02 11:40
lastModified: 2026-11-02
tags: showcase, swiftwebauthn, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SwiftWebAuthn
published: true
---

# SwiftWebAuthn: Server-Side Passkey Verification, Written From the Specification

> A Swift package that implements WebAuthn's registration and authentication ceremonies on the server, built from the W3C specification so that passkeys can be the default way a person proves identity — not a fallback.

## Problem

Passwords have a fundamental weakness that no implementation can fix: a person can be tricked into revealing one, and a person can guess one. Passkeys solve this at the protocol level, but only if the server can verify the ceremonies WebAuthn defines. SwiftWebAuthn exists to provide that verification for Swift services running on Apple platforms, where platform authenticators and iCloud Keychain already make passkeys the path of least resistance for the user.

The package is designed first for `SwiftIdentity` — a sibling library — as the credential kind that retires the passphrase entirely. Beyond that integration, it targets any Swift service authenticating people on Apple devices, where the authenticator hardware is already in the user's pocket and the ecosystem friction is low. The problem, in other words, is not convincing users to adopt passkeys; it is giving servers a trustworthy, specification-grounded implementation to verify them.

A secondary problem was provenance. Existing Swift WebAuthn implementations exist, and SwiftWebAuthn's own MASTER_PLAN.md acknowledges this explicitly. The project carries a written bar for its own abandonment — a stated condition under which it should be replaced by the maintained alternative. That honesty about scope and purpose is itself a design artifact.

## Approach

SwiftWebAuthn was built between September and October 2026, reaching three releases across 31 commits from a single contributor. The package targets macOS and uses Swift 6.2 tooling.

The architectural philosophy is one of deliberate constraint. No cryptographic primitive is implemented in the package. `swift-crypto` handles the mathematics; SwiftWebAuthn's responsibility is parsing the specification's steps and checking them in order. This is not laziness — it is a considered trust boundary. Cryptographic implementations are among the most dangerous code to write incorrectly, and deferring to a maintained, audited library keeps the surface area of potential error inside this package to the parsing and logic layer.

The same principle governs CBOR handling. Rather than adopting a general-purpose CBOR decoder, SwiftWebAuthn ships a decoder for the specific subset an attestation object uses, and refuses everything else. Failing closed on attacker-supplied bytes is the explicit goal. An overly permissive decoder that accepts unexpected structure is an attack surface; a narrow decoder that rejects it is not.

The target structure reflects the package's integration story. Alongside the core `SwiftWebAuthn` and `SwiftWebAuthnIdentity` targets, a `CaptureHTTP` target and a `webauthn-capture` executable exist — tooling for capturing real ceremony traffic during development, which provides a practical feedback loop against the specification without requiring a running production service.

Dependencies are lean and purposeful: `swift-crypto` for cryptography, `SwiftDeterminism` for controlled behavior in tests, `swift-identity` for the credential integration layer, and `swift-docc-plugin` for documentation generation.

A `CLAUDE.md` file is present, encoding development workflow, quality gates, and key rules in a form that makes the working environment reproducible. Architecture sections cover session start, post-clone setup, and the references that ground implementation decisions in the specification.

## Results

Three releases shipped across the project's seven-week active window: `0.1.0`, `0.2.0`, and `0.2.1`. The version history suggests a complete initial implementation followed by a meaningful second iteration — the step from `0.1` to `0.2` typically signals a substantive revision rather than a patch.

The package ships two complete test targets — `SwiftWebAuthnTests` and `SwiftWebAuthnIdentityTests` — alongside the `CaptureHTTPTests` target, providing coverage across the core verification logic and the identity integration layer separately. The separation of test targets mirrors the separation of concerns in the package itself.

The integration with `swift-identity` is live enough to appear as both a dependency and a named target, suggesting the credential integration story is not theoretical but implemented.

## Judgment Calls

Several decisions in SwiftWebAuthn reveal the kind of thinking that distinguishes careful library design from feature delivery.

**Writing from the specification, not from an existing implementation.** The MASTER_PLAN is explicit: no code copied, no tests copied, no licence question. This is more than a legal precaution. Implementing from the specification means the implementation is grounded in what the standard actually requires, not in what a prior author understood it to require. The cost is higher upfront effort. The benefit is a clean reading of the spec and no inherited misunderstandings.

**The narrow CBOR decoder.** A general CBOR library would have been faster to adopt and easier to justify. Choosing instead to decode only what attestation objects actually use, and to refuse everything else, reflects an understanding that the input to these functions is attacker-controlled. Permissiveness in that context is not flexibility — it is exposure.

**The written abandonment condition.** Shipping a library with a documented condition under which it should be replaced by another is an unusual act of honesty. It signals that the goal is passkey adoption in Swift, not the survival of this particular package. It also makes the project's scope legible: this exists because a specification-grounded, independently implemented alternative has value, not because the maintained implementation is inadequate.

**Separation of the capture tooling.** Including `CaptureHTTP` and `webauthn-capture` as first-class targets rather than throwaway scripts means the development loop against real ceremony traffic is reproducible and versioned. That kind of working infrastructure reflects a developer who treats development ergonomics as a product concern.
