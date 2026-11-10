---
title: SwiftCLIKitAuth: Account Sign-In for SwiftCLIKit Apps
description: A Swift package that gathers credentials, runs prompts, and manages sign-in sessions for command-line tools and SSH apps built on SwiftCLIKit, without owning any identity decisions.
date: 2026-11-02 11:40
lastModified: 2026-11-10
tags: showcase, swift-cli-kit-auth, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: SwiftCLIKitAuth
published: true
---

# SwiftCLIKitAuth: Account Sign-In for SwiftCLIKit Apps

> A Swift package that gathers credentials, runs prompts, and manages sign-in sessions for command-line tools and SSH apps built on SwiftCLIKit, without owning any identity decisions.

## Motivation

SwiftCLIKit provides a foundation for building command-line tools in Swift. Some of those tools need accounts — a `mytool login` flow, or an SSH app that authenticates users before granting access. Without a shared package for this, every tool author would have to wire up credential prompts, session state, and sign-in flows from scratch, and would have to make their own choices about how to handle refusals and what to depend on.

SwiftCLIKitAuth is the answer to that problem. Its mission, as stated in the project's MASTER_PLAN.md, is to establish who someone is (as a SwiftIdentity `Subject`), how strongly that was proven, and whether the app admits them — from a local terminal or over SSH. Identity verification itself stays in SwiftIdentity's `Authenticator`. This package gathers credentials, shows prompts, admits or refuses, and holds the session. Tools that don't need accounts pay nothing; tools that do add only the packages for the sign-in methods they use.

The design was driven by a proposal written before coding started — `2026-10-20_SwiftCLIKitAuth.md`, approved on 2026-10-24 at revision 7, with revisions 8 and 9 decided afterward. That proposal is the authority for what the package does and how it is shaped.

## Approach

The package is structured around a clean separation of concerns enforced by its dependency rules:

**Identity decisions stay out.** SwiftCLIKitAuth calls `Authenticator.authentication(for:)`, the statically dispatched form from SwiftIdentity. Because it uses that form, no layer in this package can print a reason for a refusal. Every failed sign-in surfaces as "Sign-in failed" — the package cannot leak why.

**Method packages are not pulled in.** For device sign-in flows (such as OAuth), the app provides a closure. That means swift-oauth becomes the app's dependency, not SwiftCLIKitAuth's. This was a deliberate decision from revision 9 of the design proposal, keeping the package's dependency footprint minimal and giving app authors control over what they pull in.

**Two targets for two contexts.** The package splits into `SwiftCLIKitAuth` for local terminal sign-in and `SwiftCLIKitAuthSSH` for SSH app scenarios. Each has its own test target. SSH support builds on swift-nio and swift-nio-ssh; cryptographic operations use swift-crypto. The swift-docc-plugin is included for documentation generation.

Platforms supported are macOS, iOS, and visionOS, using Swift Package Manager with tools version 6.2.

## Results

The project reached v0.4.0 across 30 commits from a single contributor, with four releases shipped: v0.1.0, v0.2.0, v0.3.0, and v0.4.0. All commits landed within a two-day window between October 26 and 27, 2026.

The package delivers:
- Local terminal sign-in flow (`SwiftCLIKitAuth` target)
- SSH app sign-in flow (`SwiftCLIKitAuthSSH` target)
- Test coverage via `SwiftCLIKitAuthTests` and `SwiftCLIKitAuthSSHTests`
- Documentation via swift-docc-plugin

## Decisions

**Design-first, then code.** The approved design proposal preceded all implementation. Revisions 8 and 9 were decided during delivery and shaped the closure-based device sign-in approach and the statically dispatched authenticator call. I followed the proposal as the authority rather than letting implementation decisions drift from it.

**Static dispatch for authentication.** Using `Authenticator.authentication(for:)` instead of a dynamically dispatched form means no code path in this package can inspect or surface a refusal reason. This was a deliberate privacy constraint: the package cannot accidentally expose why someone was refused.

**Closure injection for OAuth-style flows.** Rather than depending on swift-oauth directly, device sign-in takes a closure from the app. This keeps swift-oauth out of the package's dependency graph and lets app authors manage that dependency themselves. The tradeoff is that app authors have a little more wiring to do, but they retain full control over their dependency surface.

**Split targets by context.** Separating the terminal and SSH targets means an app that only needs local sign-in does not pull in swift-nio or swift-nio-ssh. This follows the stated goal that apps pay only for what they use.

**What is unfinished or uncertain.** The MASTER_PLAN.md tracks delivery against the proposal, and the project reached v0.4.0 within two days. What remains open — additional sign-in methods, further platform coverage, or additional session management features — is not documented in the available inputs, so I cannot state it here.
