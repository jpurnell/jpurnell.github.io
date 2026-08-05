# Proposal: quality-gate-swift Web Experience — *The Gate and the Mirror*

**Status:** PROPOSED (plan-first; no posts/code until approved)
**Date:** 2026-08-01
**Repo:** justinpurnell.com (Ignite static site)
**Model:** the BusinessMath section — ~48 posts, hand-built landing page, compiled `.epub` edition.

## 1. Goal & thesis

A first-class `/quality-gate` section on justinpurnell.com — a top-level peer to BusinessMath — telling the whole story of quality-gate-swift. Not just a linter tour: **two systems, one story.**

- **The Gate** — quality-gate-swift: AST-powered mechanical enforcement that makes it *physically impossible* to commit code that violates your standards.
- **The Mirror** — the **Institutional Judgment System** (`org-judgement-system` + `org-judgement-corpus`): a four-layer feedback loop that captures the *reasoning* behind every override, exemption, and calculated risk, and feeds that institutional memory back into the next gate run.

One enforces; the other remembers and learns. This is *how it all really works* — the checkers are the sensors; the IJS is the nervous system. The existing book draft names it exactly: **"The Gate and the Mirror: How Mechanical Enforcement and Institutional Judgment Build Software You Can Trust"** (preface + Chapter 1 "The Fifty-Five Error Incident" already written). The web series and the `.epub` are two expressions of the same body of work.

**The Bridgewater lineage is explicit and load-bearing** (Ray Dalio's *Principles*), and the series says so:
- Dalio's five-step loop — **Goals → Problems → Diagnosis → Design → Doing** — is the model every override/failure is mapped through in the corpus.
- **Idea meritocracy + believability-weighting** → calibration and per-writer track record in the corpus.
- **Radical transparency** → "recorded, never silent" + a lossless, human-inspectable corpus (ISO-8601 dates, sorted keys, readable paths).
- **Principles → algorithms → a machine** → the gate + mirror *is* the machine; when the output is bad, you diagnose the machine, not the person.

## 2. Decisions (locked)

- **Plan-first.** Commit this doc; build from it.
- **Checker posts written sequentially**, one family at a time, reviewed as we go.
- **Top-level nav peer** — `Quality Gate` immediately right of BusinessMath in `SiteHeader.swift` (… CV · BusinessMath · **Quality Gate** · NeXT).
- **Slug** `/quality-gate`; **`series: quality-gate`**.
- **Epub: yes** — the compiled edition *is* *The Gate and the Mirror*, built on the existing book draft, using BusinessMath's epub pipeline (`metadata.yaml` + a Complete doc + `.epub`).
- **Richer hero** — not just an intro article; echo the tool's "gate readout" visual identity (the ✓/✗ commit-blocked motif) as a proper hero.
- **Fold in the old post** — adapt `Content/projects/quality-gate-swift.md` ("Three New Auditors…") into the new section and redirect/cross-link from its old path.

## 3. Site integration (mirror BusinessMath exactly)

1. **Content** → `Content/QualityGate/`, grouped into sub-folders (the analog of `week-NN/`): `gate/` (philosophy), `correctness/`, `safety-security/`, `hygiene/`, `documentation/`, `project-health/`, `specialty/`, `mirror/` (IJS), `compliance/`. Plus `metadata.yaml` for the `.epub`.
2. **Landing page** → `Sources/PersonalSiteLib/Pages/QualityGate.swift`, modeled on `Pages/BusinessMath.swift`: `StaticPage` + `@Environment(\.articles)`, a **richer hero** on top, then the **tag-filterable, sortable card grid** (chips = checker family / arc) reusing `card-filter.js`, `Card`, `Badge`, `card-grid-3`.
3. **Nav** → one `Link("Quality Gate", target: QualityGate())` in `SiteHeader.swift` (placement per §2); register the route where BusinessMath is registered.

**Constraint:** the site runs its own quality gate (`.quality-gate.yml`). The new `.swift` page + the build pass **0/0** before commit — fitting, given the subject.

## 4. Content model (matches existing frontmatter)

```yaml
---
layout: BlogPostLayout
series: quality-gate
title: "<Post title>"
tags: quality-gate, <arc-or-family>, swift
link: https://github.com/jpurnell/quality-gate-swift
date: 2026-08-NN 09:00
lastModified: 2026-08-NN
published: true
---
```

Family/arc tag values (filter chips): `gate`, `correctness`, `safety`, `hygiene`, `documentation`, `project-health`, `specialty`, `mirror`, `compliance`.

## 5. Voice & per-post template

Match `Content/projects/quality-gate-swift.md`: first person, a **real incident as the hook**, ❌/✅ red-green code, rule IDs + test counts stated plainly, a **dogfooding story** (a false positive caught against the tool itself), a "why the architecture matters" reflection, "Try it," a closing lesson, a Source link. IJS posts additionally carry the Dalio/Bridgewater throughline where it earns its place — as lived engineering, not name-dropping.

## 6. Post inventory (~55 posts — book-scale)

### Anchors (2)
- `intro` — *Welcome to quality-gate-swift* (drives the landing hero; short).
- `philosophy` — **flagship (Gate):** *A Gate, Not a Linter* — AST-first ("reads the tree, not the text"), zero-tolerance / no-override culture, dogfooding, precision-as-product, "flag to understand not forbid," the `QualityChecker` protocol + modular architecture, inside TDD/hooks/CI.

### Arc I — The Gate: the 33 checkers
- **Correctness (9):** recursion · pointer-escape · concurrency *(the Narbis stop-vs-completed race)* · fp-safety · memory-lifecycle · unreachable *(1,064→0 on Narbis)* · process-safety · complexity · legibility
- **Safety & Security (5):** safety *(OWASP Mobile Top 10)* · keychain-secrets · stochastic-determinism · temporal-determinism · hig-auditor
- **Code Hygiene (7):** logging · test-quality · context · accessibility · idiom *(SwiftLint parity)* · smells · duplication *(14,000→11)*
- **Documentation (2):** doc-coverage · doc-lint
- **Project Health (8):** build · test *(flip detector + stress mode)* · status · dependency-audit *(hallucinated imports)* · release-readiness · swift-version · memory-builder · submodule-audit
- **Specialty (5):** mcp-readiness · appintents-readiness · xcode-build · disk-clean · consistency

### Arc II — The Mirror: the Institutional Judgment System (~8)
The pillar that explains how it *really* works. `org-judgement-system` + `org-judgement-corpus`; the in-tree `IJS*` modules are the sensor/interface into it.
1. **flagship (Mirror):** *The Mirror* — quality-gate as a sensor into a four-layer feedback loop; the gate enforces, the mirror remembers.
2. *The Corpus* — lossless, radically transparent institutional memory (`org-judgement-corpus`).
3. *The Pulse* — narrative synthesis of portfolio state; StatisticalValidity gating (insufficient / preliminary / valid).
4. *Policy Discovery* — surfacing the implicit principles a team already lives by, from telemetry.
5. *Consistency Scoring* — the `consistency` checker as institutional-consistency signal.
6. *Calibration & the Judgment Workbench* — believability, human-reachable judgment; overrides acknowledged in place.
7. *The Trust Service* — verified writers, the second-reviewer rule, governed/held writes ("getting in sync").
8. **essay:** *Principles as Software* — the Dalio/Bridgewater lineage, explicit: the five-step loop, idea meritocracy, believability-weighting, radical transparency, principles→algorithms→a machine.

### Compliance mini-series (4)
*Coverage, not a compliance badge* (control-mapping + the `compliance` report) · privacy-manifest · standards-watch (eCFR + Federal Register drift detection) · a SOC 2 / ISO 27001 / HIPAA synthesis.

**Total: 2 + 33 + 8 + 4 = ~47 distinct posts** (+ folded-in legacy post), on par with / beyond BusinessMath.

## 7. The epub — *The Gate and the Mirror*

The compiled edition is the book, not a generic dump. Build on the existing draft (preface + Ch.1 "The Fifty-Five Error Incident") and adapt the web posts into chapters, arranged in the two-arc structure. Mirror BusinessMath's pipeline: `metadata.yaml` → a `QualityGate-Complete.md` → `.epub`.

## 8. Source material

- **The Gate:** quality-gate-swift README + checker table, per-checker DocC catalogs, CHANGELOG (stories + numbers), the Narbis case (concurrency).
- **The Mirror:** `Tools/org-judgement-system` + `Tools/org-judgement-corpus` repos; the in-tree `IJS*` modules + `.ijs-corpus`; and the existing drafts in quality-gate-swift's guidelines — `BOOK_QUALITY_GATE_AND_INSTITUTIONAL_JUDGMENT.md`, `BLOG_POST_INSTITUTIONAL_JUDGMENT.md`, `BLOG_POST_PERSONAL_JUDGMENT.md`, `P1_InstitutionalJudgmentSystem.md`, `P3b_IJSMCPTools.md`, `PersonalJudgmentSystem.md`.

## 9. Phased build

- **Phase 0 — Scaffold.** `QualityGate.swift` landing page + richer hero, nav link, `Content/QualityGate/` + folders + `metadata.yaml`, the intro post, one Correctness family (2–3 posts). Render it; site gate 0/0.
- **Phase 1 — Both flagships:** *A Gate, Not a Linter* and *The Mirror*.
- **Phase 2 — Checker posts**, sequential by family (Correctness → Safety → Hygiene → Docs → Project Health → Specialty).
- **Phase 3 — The Mirror mini-series** (incl. the Dalio/Bridgewater essay).
- **Phase 4 — Compliance mini-series.**
- **Phase 5 — The epub** *The Gate and the Mirror* + cross-linking + fold-in of the legacy post + final gate 0/0 + build + deploy.

Each phase is its own commit(s), gate-green.
