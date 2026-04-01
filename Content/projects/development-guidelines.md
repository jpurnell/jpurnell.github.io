---
layout: BlogPostLayout
tags: project, swift, apple, development
image:
imageDescription:
title: How We Stopped Losing Context and Started Shipping Faster with AI
link: https://github.com/jpurnell/development-guidelines
date: 2026-04-01 12:00
lastModified: 2026-04-01
published: true
---

# How I Stopped Losing Context and Started Shipping Faster with AI

**Building a reusable instruction set that turns AI assistants into reliable development partners.**

---

Every developer who has used an AI coding assistant has hit the same wall: you spend twenty minutes getting Claude or ChatGPT up to speed on your project, make real progress, close the session — and the next day, start from scratch. The AI has no memory of the architectural decisions you made yesterday. It doesn't know that your project forbids force unwraps. It doesn't remember that you chose actors over structs for a specific reason.

As I began to work on larger and larger projects with AI, I realized I needed a system to eliminate it.

## The Problem: AI Amnesia

I've been developing Swift libraries for mathematical and financial computation — the kind of code where a 0.01% floating-point error compounds into a real-world bug. Across sessions, I'd see Claude running into the same failures:

- **Repeated mistakes.** The AI would reintroduce force unwraps or unsafe patterns we'd explicitly banned.
- **Lost architectural context.** Decisions made three sessions ago were invisible to the current session.
- **Wasted ramp-up time.** Every new conversation started with re-explaining the project structure, testing approach, and coding standards.
- **Inconsistent quality.** Some sessions produced clean, well-tested code. Others drifted from established patterns.

I needed the AI to walk into every session already knowing the rules, the current state of work, and exactly where to pick up.

## The Solution: Documentation as Persistent Memory

The core insight was simple: **if the AI can't remember, make it read.** I created a structured set of development guidelines — a reusable instruction set — that gives any AI assistant everything it needs to be productive from the first message of a new session.

The system isn't a style guide. It's an operational model for AI-assisted development, covering everything from project vision down to how a session should end.

### The Folder Structure

The guidelines live in a numbered folder hierarchy that mirrors the development workflow:

```
00_CORE_RULES/                    → The rules. Read first, reference always.
01_ROADMAPS/                      → Strategic direction.
02_IMPLEMENTATION_PLANS/          → Tactical plans, proposals, and migrations.
03_STRATEGIES_AND_FRAMEWORKS/     → High-level product guidance.
04_IMPLEMENTATION_CHECKLISTS/     → Per-feature task tracking.
05_SUMMARIES/                     → Session history and handover notes.
06_BACKUP_FILES/                  → Archive.
07_LIBRARY/                       → Reference materials.
```

The numbering isn't arbitrary. It reflects reading priority: an AI assistant recovering context reads `00_CORE_RULES` first, then works its way through based on what it needs. The structure forces a natural flow from strategy to implementation to tracking to history.

## How It Works in Practice

### 1. Context Recovery: Never Start Cold

Every session begins with a context recovery protocol. The AI reads a defined set of documents depending on the task:

**Quick recovery** — for bug fixes or resuming same-day work:
- The latest session summary (where we left off)
- The active implementation checklist (what's in progress)

**Full recovery** — for new sessions or complex features:
- The Master Plan (project vision and architecture)
- Coding Rules (forbidden patterns, safety rules)
- TDD Guidelines (testing contract)
- Active implementation checklist
- Latest session summary

The AI then confirms: *"Context recovered. Current task is X. Ready to follow Zero Warnings Gate."*

Two documents or five — either way, the AI is productive within seconds, not minutes. No re-explaining. No re-discovering constraints.

### 2. Design-First TDD: Think Before You Code

The development workflow has six phases, and the first one happens before any code is written:

```
0. DESIGN    → Propose architecture, get approval
1. RED       → Write failing tests
2. GREEN     → Write minimum code to pass
3. REFACTOR  → Improve while keeping tests green
4. DOCUMENT  → DocC comments and working examples
5. VERIFY    → Zero warnings gate — nothing ships until it passes
```

The Design phase is where the real leverage is. Before a single line of code is written, the AI produces a design proposal covering the objective, proposed architecture, API surface, constraints compliance, and test strategy. This catches misunderstandings before they become wasted code.

For our mathematical libraries, the design phase also includes an MCP (Model Context Protocol) schema — a JSON specification of how the API would be consumed by AI tools. This means every function we build is designed for both human and machine consumption from day one.

### 3. The Quality Gate: Zero Tolerance

Every feature must pass a quality gate before it's considered complete. Not "mostly passing." Not "warnings but no errors." Zero.

The gate checks:
- **Build** — zero compiler warnings
- **Test** — zero failures
- **Safety** — no force unwraps, force casts, or unsafe patterns
- **Doc-lint** — documentation compiles cleanly
- **Doc-coverage** — all public APIs are documented

This sounds strict, and it is. But it eliminates the slow accumulation of technical debt that happens when "just one warning" becomes twenty. The AI knows the gate exists, checks against it continuously, and won't declare a task complete until everything passes.

### 4. Session Handover: Leave a Trail

This is what makes the whole system work across time. Before ending any session, the AI must:

1. **Run the quality gate** and report the result.
2. **Update the implementation checklist** — move completed items, flag blockers.
3. **Create a session summary** documenting:
   - What was accomplished (with specific file paths and test names)
   - Quality gate status
   - The **immediate next step** — not "continue the feature" but "add the `calculateYTM` method to `BondPricing.swift`, tests are stubbed in `BondPricingTests.swift` line 47"
   - Pending blockers and context loss warnings

The next session reads this summary and picks up exactly where the last one stopped. No drift. No duplication. No "what were we working on?"

## What Makes This Different

### It's Reusable Across Projects

The guidelines are a template. Fork the repo, replace `[PROJECT_NAME]` placeholders, customize the coding rules for your stack, and you have a fully operational instruction set for a new project. I've used the same structure across multiple Swift libraries, and the ramp-up time for each new project is near zero.

### It Handles Mathematical Code Correctly

Most AI coding workflows don't address the specific challenges of numerical computation. Our guidelines mandate:

- **Deterministic random number generation** with explicit seeds for reproducible stochastic tests
- **Tolerance-based floating-point comparisons** — never exact equality
- **Division safety guards** on every division operation
- **Property-based tests** that verify mathematical invariants (commutativity, boundary conditions, known analytical solutions)

This means my Monte Carlo simulations produce identical results across runs, my tests catch numerical instability before anything reaches production, and all financial calculations are auditable.

### It Scales Over Months

Long-running projects create a different problem: too many session summaries. The system handles this with phase summaries — rollup documents created periodically that consolidate objectives, architectural decisions, and a dependency diagram. Meanwhile, file size limits keep individual documents within context window budgets.

The Architecture Decisions Log uses structured entries that the AI can query by category without reading the entire history:

```yaml
id: ADR-003
date: 2024-02-10
status: accepted
category: concurrency
title: Use actors for simulation engine
rationale: Thread-safe state without manual locking
```

When the AI needs to know why we chose actors, it searches by category instead of reading months of session summaries.

### It Makes the AI Self-Auditing

One of the most effective patterns is the safety audit built into the refactor phase. Before presenting code, the AI searches its own output for forbidden patterns — force unwraps, unsafe casts, unguarded divisions — rather than relying on human review to catch them. The guidelines make the AI its own code reviewer.

## The Results

Since adopting this system:

- **Session ramp-up dropped from minutes to seconds.** Context recovery is reading, not conversation.
- **Defect rate fell significantly.** The quality gate catches issues before they're committed. Forbidden patterns are caught by the AI itself during the refactor phase.
- **Consistency across sessions improved dramatically.** Session 50 follows the same standards as session 1 because the rules are read, not remembered.
- **Design proposals prevent wasted work.** Catching architectural mismatches before coding starts saves hours of rework.
- **The handover protocol preserves momentum.** The next session starts where the last one ended, not where the AI guesses it ended.

## Try It Yourself

The key principles transfer to any stack:

1. **Write your rules down.** If the AI should follow a pattern, document it where the AI will read it.
2. **End every session with a handover.** The five minutes spent writing a summary saves twenty minutes of ramp-up.
3. **Automate your quality gate.** If verification is manual, it gets skipped. Make it a single command.
4. **Design before you code.** A ten-minute design review catches misunderstandings that cost hours to fix in implementation.
5. **Treat documentation as memory.** It's not overhead — it's the mechanism that makes long-running AI collaboration possible.

AI assistants are powerful. But power without continuity is just speed in random directions. Give the AI a structured memory, clear rules, and a defined workflow, and it becomes something better: a reliable development partner that gets more effective over time.

---
