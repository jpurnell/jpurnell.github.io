---
title: The Master Plan: Organizing Complexity
date: 2026-01-20 13:00
series: BusinessMath Development Journey
week: 3
post: 2
journey_source: "Week 5 from BusinessMath_Blog.md"
category: "methodology"
tags: ai-collaboration, project-management, planning, organization, development journey
layout: BlogPostLayout
published: true
---

# The Master Plan: Organizing Complexity

**Development Journey Series**

---

## The Context

At the end of a week or two, we had tackled the core of BusinessMath. We had unlocked the power of the TimeSeries data structure, and had shown the proof of concept in a simple topic like the Time Value of Money using Test-Driven Development and our document-first approach. That was great, but we had a long road ahead of us, with some much trickier topics.

- Statistical Distributions
- Time Series Analysis
- Loans & Amortization
- Depreciation
- Investment Analysis
- Portfolio Optimization
- Monte Carlo Simulation
- Sensitivity Analysis
- Financial Statements
- Options Pricing

Each topic had 5-15 functions, dozens of tests, complete DocC documentation, and playground examples.

Even with domain expertise and working with a capable AI agent, this required a structured and methodical approach or risked sprialing out of control.

---

## The Challenge

Large projects with AI have a unique problem: **AI has no memory across sessions.**

Traditional development preserves context naturally:
- You work on the same codebase daily
- You remember what's done and what's next
- Your IDE shows project structure
- Your brain maintains the big picture

With AI collaboration:
- Each session starts fresh
- AI doesn't remember yesterday's priorities
- No inherent sense of progress or dependencies
- Easy to lose track of the overall plan

Without explicit project memory, it's very, **very** easy to drift. If you bounce around and work on whatever seems interesting, dependencies go forgotten, coding patterns start to diverge, and momentum comes to a halt.

I needed a way to maintain project context across sessions—a shared memory between me and AI.

---

## The Solution

**Create a living MASTER_PLAN.md document.**

### The Master Plan Structure

The master plan is a single markdown file that serves as the project's memory:

```markdown
# BusinessMath Master Plan

**Last Updated**: Week 5

## Project Goals

Build a production-quality Swift library for financial calculations with:
- 100% DocC documentation coverage
- Comprehensive test suite (target: 200+ tests)
- Support for generic numeric types
- Playground tutorials for each topic

## Topics

### 1. Time Value of Money [✅ Complete]
**Status**: 24 tests, fully documented
**Effort**: Medium (M)
**Dependencies**: None
**Completed**: Week 4

**Functions**:
- `presentValue`, `futureValue`, `payment`
- `npv`, `irr`, `xnpv`, `xirr`

---

### 2. Statistical Distributions [🟡 In Progress]
**Status**: 8/25 tests
**Effort**: Large (L)
**Dependencies**: None
**Target Completion**: Week 7

**Functions**:
- Normal distribution (CDF, PDF, inverse)
- T-distribution, Chi-squared, F-distribution
- Binomial, Poisson distributions

**Remaining Work**:
- Complete distribution functions
- Add quantile functions
- Write DocC tutorials

---

### 3. Time Series Analysis [⬜ Not Started]
**Status**: 0 tests
**Effort**: Large (L)
**Dependencies**: Statistical Distributions
**Target Completion**: Week 10

**Functions**:
- Period types (Day, Month, Quarter, Year)
- TimeSeries container
- Moving averages, exponential smoothing
- Trend analysis

**Notes**:
- Blocked on Statistical Distributions completion
- Consider using Foundation.Calendar for date arithmetic

---

[... rest of 10 topics ...]

## Current Phase: Foundation (Weeks 1-8)

**Goal**: Complete Topics 1-4, establish 75 tests total

**Progress**:
- ✅ Topic 1: TVM Complete (24 tests)
- 🟡 Topic 2: Distributions 30% complete (8 tests)
- ⬜ Topic 3: Time Series (not started)
- ⬜ Topic 4: Loans & Amortization (not started)

**Next Session Priority**: Complete normal distribution tests

## Effort Estimates

- **Small (S)**: 1-2 sessions, <10 tests
- **Medium (M)**: 3-5 sessions, 10-25 tests
- **Large (L)**: 6-10 sessions, 25-50 tests
- **XL**: 10+ sessions, 50+ tests
```

---

## What Worked

### 1. Visual Progress Tracking

Checkboxes provide instant visual feedback:
- ✅ Complete (feels great!)
- 🟡 In Progress (clear focus)
- ⬜ Not Started (known future work)

At a glance, you see: "I've completed 1/11 topics, making progress on 1 more."

---

### 2. Dependency Graph Prevented Confusion

Time Series depends on Statistical Distributions (for confidence intervals).

**Without the master plan**, I might start Time Series, realize I need distribution functions, context-switch to implement those, forget where I was in Time Series, and end up with half-finished work everywhere.

**With dependencies documented**, I know: "Finish Distributions first, THEN start Time Series."

---

### 3. Effort Estimates Helped Time Management

Knowing a topic is "Large (L)" sets expectations:
- Don't try to finish it in one session
- Break it into sub-tasks
- Allocate multiple sessions

Initial estimates were too optimistic (I thought Statistical Distributions was Medium, but it took Large effort). That's fine—I updated the plan.

---

### 4. The Master Plan is AI's Memory

Every session starts with:

> "Read MASTER_PLAN.md. What's the current priority?"

AI responds:

> "You're 30% through Statistical Distributions. The next task is completing normal distribution tests. Time Series is blocked waiting for this."

**Instant context restoration.** No wasted time figuring out where you left off.

---

## What Didn't Work

### 1. Initial Estimates Were Too Optimistic

I thought Statistical Distributions would take 3-5 sessions (Medium). It took 8+ (Large).

**Fix**: I adjusted the plan. Effort estimates improve over time as you calibrate.

---

### 2. Forgot to Plan for Integration Testing

The master plan listed 11 topics as independent work. But after completing several topics, I needed integration tests: "Do TVM and Time Series work together?"

I hadn't planned for this.

**Fix**: Added a Phase 4 "Integration & Polish" with dedicated time for cross-topic validation.

---

### 3. No Mechanism for Prioritization Changes

The master plan was linear (Topic 1 → Topic 2 → Topic 3...). But sometimes priorities shift:
- A user requests a specific feature
- You discover a critical bug
- Integration reveals missing functionality

The plan didn't accommodate this gracefully.

**Fix**: Added a "Current Session Priority" section that can override the default order.

---

## The Insight

**AI has no memory across sessions. The master plan document serves as the project's memory.**

Traditional development preserves context implicitly (your brain, IDE state, recent commits). AI collaboration requires **explicit context preservation**.

The master plan serves as:
- **Roadmap**: What needs to be done
- **Memory**: What's already done
- **Prioritization**: What to work on next
- **Dependency tracker**: What blocks what
- **Progress indicator**: How far you've come

Without it, you drift. With it, you maintain momentum across weeks and months.

> **Key Takeaway**: Create a living master plan document. Update it at the end of each session. Start each new session by reading it.

---

## How to Apply This

**For your next project**:

**1. Create MASTER_PLAN.md at Project Start**
   - List all major topics/features
   - Estimate effort (S/M/L/XL)
   - Map dependencies
   - Set completion targets

**2. Structure the Plan**
   ```markdown
   ## Topics

   ### 1. [Topic Name] [Status Emoji]
   **Status**: [Specific completion metric]
   **Effort**: [S/M/L/XL]
   **Dependencies**: [What must be done first]
   **Target Completion**: [Week/Sprint number]

   **Functions/Features**:
   - List of specific work items

   **Remaining Work**:
   - What's left to do
   ```

**3. Update at End of Each Session**
   - Mark completed items
   - Update progress percentages
   - Adjust estimates based on reality
   - Note blockers or discoveries

**4. Start Each Session by Reading the Plan**
   - "What's the current priority?"
   - "What did I complete last time?"
   - "What should I work on next?"

**5. Use It as AI Specification**
   - Paste relevant section when starting work
   - "Here's the master plan. Focus on Topic 2: Statistical Distributions. The next task is completing normal distribution tests."

---

## See It In Action

The master plan guided the entire BusinessMath development:

**Technical Examples**:
- **Week 5-7**: Statistical Distributions (originally estimated M, actually L)
- **Week 8-10**: Time Series (blocked until Distributions complete)
- **Week 15**: Integration testing (added after initial plan)

**Methodology Integration**:
- **Test-First Development** (Week 1): Each topic's test count tracked in plan
- **Documentation as Design** (Week 2): DocC coverage tracked in plan
- **Coding Standards** (Week 5): Standards violations tracked as plan items

---

## Common Pitfalls

### ❌ Pitfall 1: Making the plan too detailed

**Problem**: 50-page plan with every function documented upfront
**Solution**: High-level topics with detail added as you go

### ❌ Pitfall 2: Never updating the plan

**Problem**: Plan becomes stale, loses value
**Solution**: Update at end of EVERY session, even if it's just checking a box

### ❌ Pitfall 3: Treating estimates as commitments

**Problem**: Feeling bad when Medium takes Large effort
**Solution**: Estimates are guesses that improve over time. Update them!

### ❌ Pitfall 4: Skipping dependency tracking

**Problem**: Starting work that's blocked, wasting time
**Solution**: Explicitly list "Dependencies: [Topic X complete]"

---

## Template

Here's a starter template for your master plan:

```markdown
# [Project Name] Master Plan

**Last Updated**: [Date]

## Project Goals

[1-3 sentences describing what you're building and key quality criteria]

## Topics / Features

### 1. [Feature Name] [✅ | 🟡 | ⬜]
**Status**: [Specific completion metric]
**Effort**: [S/M/L/XL]
**Dependencies**: [None | Topic X complete]
**Target Completion**: [Week/Sprint]

**Work Items**:
- [ ] Item 1
- [ ] Item 2

**Remaining Work**:
- [What's left]

---

[Repeat for each topic/feature]

## Current Phase

**Goal**: [Phase objective]

**Progress**:
- ✅ [Completed items]
- 🟡 [In progress]
- ⬜ [Not started]

**Next Session Priority**: [Specific task]

## Effort Legend

- **Small (S)**: [Your time estimate]
- **Medium (M)**: [Your time estimate]
- **Large (L)**: [Your time estimate]
- **XL**: [Your time estimate]
```

---

## Discussion

**Questions to consider**:
1. How detailed should the master plan be?
2. How often should you update it?
3. What do you do when priorities shift mid-project?

**Share your experience**: Do you use a master plan or roadmap document? What works for you?

---

**Series Progress**:
- Week: 3/12
- Posts Published: 10/~48
- Methodology Posts: 3/12
- Practices Covered: Test-First, Documentation as Design, Master Planning
