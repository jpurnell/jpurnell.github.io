---
layout: BlogPostLayout
series: quality-gate
title: "AppIntentsAuditor: The Siri Integration That Fails at Registration"
tags: quality-gate, specialty, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:46
lastModified: 2026-09-05
published: true
---

# AppIntentsAuditor

**App Intents power Siri, Shortcuts, and Spotlight — and they fail in ways the compiler often accepts but the system rejects at registration.**

---

Apple's App Intents framework is protocol-heavy: an entity must conform just so, parameters need the right property wrappers, metadata protocols must be present. Get it subtly wrong and the code frequently *compiles* — then the intent doesn't register, or registers without the behavior you expected, and you find out from a Shortcut that silently does nothing. `AppIntentsAuditor` checks the conformances at commit time.

## What it checks

- **Entity conformance** — types meant to be App Intent entities actually conforming correctly, with the required identifiers and display representations.
- **Parameter wrappers** — parameters using the correct `@Parameter` wrappers and metadata rather than plain properties.
- **Metadata protocols** — the supporting protocol conformances the system needs to surface the intent.

Because it understands the App Intents structure through the AST, it can tell a properly-wrapped parameter from a plain property, and a complete entity conformance from one that's missing the piece that only matters at registration.

This is a niche checker with a very specific payoff: the App Intents failure mode is uniquely frustrating because the feedback loop is so long — you don't see the problem until you build, install, and try to invoke the intent from Shortcuts or Siri. Moving that check to commit time collapses a multi-minute test cycle into an instant gate finding.

## Try it

```bash
quality-gate --check appintents-readiness
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
