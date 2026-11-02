---
title: SwiftCLIKitAuth: Zero-Friction Account Sign-In for Swift Command-Line Tools
description: A modular authentication layer for SwiftCLIKit that establishes identity, asserts assurance, and admits users — from local terminals and over SSH — without knowing anything about how identity is proven.
date: 2026-11-02 11:40
lastModified: 2026-11-02
tags: showcase, swift-cli-kit-auth, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SwiftCLIKitAuth
published: true
---

# SwiftCLIKitAuth: Zero-Friction Account Sign-In for Swift Command-Line Tools

> A modular authentication layer for SwiftCLIKit that establishes identity, asserts assurance, and admits users — from local terminals and over SSH — without knowing anything about how identity is proven.

## Problem

Command-line tools that call account-bound services need a way to handle sign-in, but the space between "no accounts at all" and "roll your own auth flow" has historically been a gap rather than a solution. Developers building tools on SwiftCLIKit faced a choice: drag in a heavyweight dependency for features they might not need, or stitch together credential prompts, session management, and SSH handling by hand.

SwiftCLIKitAuth was built to close that gap cleanly. Its mission, as stated in its own `MASTER_PLAN.md`, is to establish *who* someone is (represented as a SwiftIdentity `Subject`), *how strongly* that was proven, and *whether the app admits them* — from a local terminal or over SSH. The package serves two audiences: authors of CLI tools that need a `login` command against an account-bound service, and authors of SSH apps that require accounts, built on SwiftCLIKitSSH.

Critically, the problem was scoped as tightly as the solution. Apps that don't need accounts pay nothing. Apps that do add only the packages for the methods they use.

## Approach

The design was authored prior to implementation and approved through a formal revision process — `2026-10-20_SwiftCLIKitAuth.md` reached revision 7 before receiving approval on 2026-10-24, with revisions 8 and 9 decided afterward. That proposal is explicitly designated the authority; the `MASTER_PLAN.md` tracks delivery against it. This discipline — keeping the design document sovereign over the implementation — reflects a working style that treats architecture as a first-class artifact rather than an afterthought reconstructed from code.

The package is structured into two targets with clean separation: `SwiftCLIKitAuth` for local terminal authentication flows and `SwiftCLIKitAuthSSH` for SSH-based authentication, each with its own test target. The dependency graph was constructed with deliberate restraint — `swift-cli-kit`, `swift-identity`, `swift-crypto`, `swift-nio`, and `swift-nio-ssh` are present because the package genuinely needs them. Third-party auth dependencies such as `swift-oauth` are explicitly kept *out*, pushed to the consuming application. This is not an oversight; it's revision 9 of the design, which specifies that device sign-in takes the app's closure so that OAuth libraries remain the app's dependency, not the package's.

Identity verification is delegated entirely to SwiftIdentity's `Authenticator`. SwiftCLIKitAuth calls `Authenticator.authentication(for:)` — the statically dispatched form — gathers credentials, presents prompts, and manages session state. It does not inspect the reason for a refusal. Every failed sign-in surfaces the same message: "Sign-in failed." This is a privacy guarantee enforced by architectural boundary, not by convention.

## Results

Thirty commits across a single contributor produced four versioned releases — `v0.1.0` through `v0.4.0` — in just over 25 hours between first commit and latest commit. The pace reflects a design that was already settled before implementation began: when the architecture is resolved up front, implementation can move quickly without thrashing. The package ships with test coverage across both the core auth target and the SSH target (`SwiftCLIKitAuthTests` and `SwiftCLIKitAuthSSHTests`), targeting macOS, iOS, and visionOS. Documentation infrastructure is included via `swift-docc-plugin`, signaling intent for the package to be a publishable, maintainable component rather than internal scaffolding.

## Judgment Calls

Several decisions here are worth examining as expressions of craft rather than convenience.

**The refusal is opaque by design.** Consuming `Authenticator.authentication(for:)` in its statically dispatched form is not the path of least resistance — it's the path that prevents any layer of this package from printing a rejection reason. The "Sign-in failed" message isn't a lazy default; it's a deliberate privacy posture baked into the call site.

**Inversion of the OAuth dependency.** It would have been straightforward to take a direct dependency on an OAuth library and offer device sign-in as a first-class capability. Revision 9 of the design rejected this in favor of a closure-based interface that hands responsibility back to the calling application. The package stays thin; the application owns its own auth method dependency. This decision keeps SwiftCLIKitAuth honest about what it actually is — a session and admission layer, not an identity provider.

**Two targets, not one.** Splitting SSH authentication into `SwiftCLIKitAuthSSH` means that tools without SSH exposure don't link against NIO or the SSH stack. The pay-only-for-what-you-use principle stated in the mission is enforced at the package manifest level, not just in documentation.

**Design sovereignty.** Designating the design proposal — not the code, not the plan — as the authoritative source of truth, and tracking delivery against it rather than updating it to match what shipped, is a discipline that keeps architectural intent legible. Four releases in two days is a fast cadence; the fact that the design was at revision 7 before a line was committed explains how that cadence was possible without drift.
