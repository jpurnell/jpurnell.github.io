---
layout: BlogPostLayout
series: quality-gate
title: "TestQualityAuditor: Tests That Don't Actually Test Anything"
tags: quality-gate, hygiene, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-07-31 09:30
lastModified: 2026-08-13
published: true
---

# TestQualityAuditor

**A green test suite is only reassuring if the tests assert something real. This checker audits the tests themselves.**

---

The most dangerous test is the one that passes for the wrong reason. It runs, it's green, and it checks nothing — a false sense of safety that's worse than an honest gap, because nobody goes looking for coverage that appears to exist.

## What it catches

```swift
// ❌ a test with no assertion at all
func testLoad() { let r = loader.load() }        // did anything get verified?

// ❌ a weak assertion — passes on almost any value
XCTAssertNotNil(result)
XCTAssertTrue(count != 0)
// ✅ assert the specific expected value
XCTAssertEqual(count, 3)

// ❌ floating-point exact equality in a test
XCTAssertEqual(score, 0.85)
// ✅ XCTAssertEqual(score, 0.85, accuracy: 1e-6)

// ❌ unseeded randomness in a test — non-reproducible
let pick = items.randomElement()
```

It flags missing assertions, weak assertions (`!= 0`, `!= nil` instead of a specific expected value), floating-point exact equality, and unseeded randomness — the four ways a test quietly stops testing. The project's rule is direct: assertions use specific expected values, not `!= 0` or `!= nil`; tests are deterministic and reproducible.

This is the checker that keeps the [flip detector and stress mode](/QualityGate/project-health/test) honest. A suite full of assertion-free tests would flip-detect nothing, because nothing was ever being asserted. Test quality is the foundation the rest of the test tooling stands on.

## Try it

```bash
quality-gate --check test-quality
```

---

**Source:** [github.com/jpurnell/quality-gate-swift](https://github.com/jpurnell/quality-gate-swift)
