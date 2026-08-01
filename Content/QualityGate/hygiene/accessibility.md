---
layout: BlogPostLayout
series: quality-gate
title: "AccessibilityAuditor: The Users You Forgot to Test With"
tags: quality-gate, hygiene, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-08-21 09:00
lastModified: 2026-08-21
published: true
---

# AccessibilityAuditor

**Missing labels, fixed font sizes, color-only meaning — the accessibility defects that never show up in your own testing, because you're not the user who hits them.**

---

Accessibility bugs are uniquely easy to ship: they're invisible to the person who wrote the code and tested it with their own eyes and their own default settings. `AccessibilityAuditor` catches the common SwiftUI shapes at commit time, before they reach someone using VoiceOver, Dynamic Type, or Differentiate Without Color.

## What it catches

```swift
// ❌ an image conveying meaning with no accessibility label
Image("chart-up")
// ✅ Image("chart-up").accessibilityLabel("Revenue up 12%")

// ❌ a fixed font size — ignores Dynamic Type
Text("Total").font(.system(size: 14))
// ✅ Text("Total").font(.body)

// ❌ meaning by color alone
Circle().fill(isError ? .red : .green)          // invisible to color-blind users
// ✅ pair color with a shape, label, or icon

// ❌ a decorative image not hidden from assistive tech
// ✅ Image("divider").accessibilityHidden(true)
```

It also flags custom tap controls without an accessibility label or hint, and `onTapGesture` used where a `Button` (with its built-in traits) belongs. Because it's SwiftUI-structure-aware, it can tell a labeled image from an unlabeled one, and a decorative image correctly marked `accessibilityHidden` from one that was just forgotten.

Alongside the [HIGAuditor](/QualityGate/safety-security/hig-auditor) and [ContextAuditor](/QualityGate/hygiene/context), this is the part of the gate that insists "correct" includes *correct for the person using it* — a standard the compiler will never enforce for you.

## Try it

```bash
quality-gate --check accessibility
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
