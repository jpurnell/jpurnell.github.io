---
layout: BlogPostLayout
series: quality-gate
title: "HIGAuditor: Apple's Human Interface Guidelines, as Enforced Rules"
tags: quality-gate, safety, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-08-17 09:00
lastModified: 2026-08-17
published: true
---

# HIGAuditor

**Apple's Human Interface Guidelines are usually a PDF you're supposed to remember. Here they're SwiftUI rules the gate can check.**

---

The Human Interface Guidelines are excellent and almost entirely unenforced — they live in a document, and documents don't run. `HIGAuditor` takes the checkable subset and turns it into rules that fire on your SwiftUI code at commit time. It's cross-platform aware: what's correct on iOS isn't always correct on macOS, and the auditor knows the difference.

## The kinds of thing it catches

- **Hit targets** below the platform minimum — a tap target smaller than the guideline's 44×44pt is a real usability defect, not a nitpick.
- **Reserved keyboard shortcuts** — binding a Command-key shortcut that the system already owns.
- **Reduce-Motion / Reduce-Transparency** — an `.animation()` with no `reduceMotion` check, or a `Material` background with no Reduce-Transparency guard, so the accessibility setting is silently ignored.
- **Differentiate-Without-Color** — state conveyed by color alone, with no guard for users who can't distinguish it.

Each diagnostic cites its Apple HIG basis, so the finding is a pointer into the actual guideline, not just an opinion. And because it's SwiftUI-structure-aware (AST, not regex), it can tell a padded 44pt button from a bare 20pt frame, and a genuinely reduce-motion-guarded animation from an unguarded one.

This is where the gate crosses from "will it crash" into "is it *right for the person using it*" — the same instinct behind the [AccessibilityAuditor](/QualityGate/hygiene/accessibility) and the [ContextAuditor](/QualityGate/hygiene/context). Correctness that stops at the compiler misses half of what "correct" means for software people actually touch.

## Try it

```bash
quality-gate --check hig-auditor
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
