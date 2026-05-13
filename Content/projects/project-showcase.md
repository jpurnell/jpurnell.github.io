---
layout: ProjectLayout
tags: project, swift, cli, ai, portfolio
image:
imageDescription:
title: ProjectShowcase — Turning Git Repos Into Narratives
link: https://github.com/jpurnell/project-showcase
date: 2026-05-12 12:00
lastModified: 2026-05-12
published: true
---

# ProjectShowcase — Turning Git Repos Into Narratives

**A Swift CLI that reads your project artifacts and writes your portfolio for you.**

---

## The Problem

I have thirty active repositories. Each one has a story to tell — about why it exists, what problems it solves, and what I learned building it. Commit histories encode velocity. Test suites encode rigor. Package manifests encode architectural decisions. Design proposals encode judgment. All of this signal is just sitting there, legible to anyone willing to read raw JSON and git logs, which is nobody.

The gap between "my projects exist" and "here is a coherent developer portfolio" is a writing problem. You sit down on a Saturday to update your portfolio, you open a blank document, you stare at it, you remember you need to fix a bug in one of those thirty projects, and the portfolio doesn't get written. Six months later, repeat.

What if the artifacts could write the portfolio themselves? Not a list of repos with star counts — an actual narrative that understands what the project does, how it was built, and what signals a technical reader should care about?

## The Pipeline

ProjectShowcase is a three-stage pipeline: **Gather**, **Narrate**, **Render**.

The **Gather** stage runs a `FactGatherer` that orchestrates extractors against a project directory. `GitExtractor` pulls commit counts, release tags with dates, contributor counts, branch counts, and the timeline from first to latest commit. A `PackageExtractor` protocol dispatches to language-specific implementations — `SwiftPackageExtractor`, `NodePackageExtractor`, `PythonPackageExtractor`, and `CargoExtractor` — each parsing its respective manifest for dependencies, targets, platforms, and tools versions. `DesignDocExtractor` scans for CLAUDE.md, development-guidelines, and design proposals. `TestOutputParser` can ingest a test run's stdout. And `InsightsExtractor` reads Claude Code's own usage data — session counts, commit counts, friction categories, outcome distributions — to add meta-information about how the project was built. The output is a `ProjectCard`: a single Codable struct that captures everything the pipeline knows about a project.

The **Narrate** stage takes a `ProjectCard` and passes it to the Claude API via `PromptBuilder`, which constructs targeted prompts for different audiences. A `hiringManager` audience gets language emphasizing judgment and craft. A `selfReflection` audience gets language about growth and trajectory. The prompt carries every data point from the card — commit count, release history, test numbers, design proposal count, Claude Code session patterns — and instructs the model to ground claims in that data and never fabricate. Three narrative styles are available: `caseStudy`, `projectCard`, and `deepDive`.

The **Render** stage takes the narrative output and produces SSG-compatible markdown with YAML frontmatter, plus SVG infographics. `MarkdownRenderer` writes the page. Three `InfographicGenerator` implementations — `StatsCardGenerator`, `CommitTimelineGenerator`, and `ReleaseTimelineGenerator` — produce dark-themed SVG cards showing stats badges, commit activity bars, and release timelines with alternating label placement. The `PortfolioPromptBuilder` handles the cross-project overview, aggregating all thirty cards into a single prompt that asks for themes, trajectory, and craft signals across the entire body of work.

The CLI exposes this as six subcommands: `gather`, `narrate`, `render`, `refresh` (all three in one shot), `infographics`, and `portfolio`.

## The Git Shortlog Bug

This was the best debugging story of the build.

I ran `showcase gather` against a project directory in my terminal. It hung. No output, no error, just a cursor blinking at me. I switched to the Claude Code terminal, ran the exact same binary against the exact same path. It completed in two seconds.

Same machine. Same binary. Same arguments. Same project. Different result.

I tried five different approaches to fix it. Swapped pipe order. Collapsed the shell script into a single invocation. Moved execution to `DispatchQueue.global`. Switched to `terminationHandler` instead of `waitUntilExit`. Redirected output through a temp file. Each attempt either still hung or introduced a new problem. The file-based approach — writing shell output to a temp file instead of reading from a pipe — actually worked, but I didn't understand *why*, which meant I didn't trust it.

Then I looked at the actual git command that was hanging: `git shortlog -sn --all`. In a normal repository with commits, `--all` resolves refs and the command runs. But in a repo where `--all` resolves to zero refs (empty repo, or a repo state where the ref list is empty), git falls back to reading from **stdin**. It's the same behavior as `cat` with no arguments — if stdin is a TTY, it blocks waiting for input. If stdin is a pipe, it gets EOF immediately and exits.

In my terminal, stdin was a TTY. The process inherited it, `git shortlog` saw an interactive terminal on its stdin, and waited politely for input that would never come. In Claude Code's terminal, stdin was already a pipe (Claude Code's own process orchestration), so the child process got EOF and moved on.

The fix was one line:

```swift
process.standardInput = FileHandle.nullDevice
```

That's it. Disconnect stdin from the parent process, give the child `/dev/null`, and `git shortlog` on an empty ref list gets immediate EOF instead of blocking on a TTY. Every other workaround was treating symptoms. This was the cause.

## MASTER_PLAN.md Integration

The first time I ran the full pipeline against all thirty projects, I read through the generated narratives and found a problem. iConquer — a Risk-style strategy game for iOS — was narrated as an "icon querying tool." The model had no authoritative description of what the project actually does. It was inferring from the name and the package manifest, and inferring badly.

The fix was to teach the `DesignDocExtractor` to look for each project's `MASTER_PLAN.md` and extract three specific sections: **Mission**, **Target Users**, and **Key Differentiators**. These get injected into the prompt as a `Project Description` block with an explicit instruction: "treat this as the authoritative source for what the project does — the narrative must be consistent with this description." The model can still weave its own observations about commit patterns and test coverage, but it cannot contradict the project's own stated purpose. Eleven of my thirty projects now carry this context, and the narratives for those eleven are significantly more accurate.

## The Meta Layer

There is something satisfying about the recursion here. ProjectShowcase uses the Claude API to generate narratives about projects. Many of those projects were themselves built with Claude Code. And ProjectShowcase itself was built with Claude Code — the `InsightsExtractor` can read its own session data and include it in its own project card.

The `selfReflection` audience mode leans into this. Instead of selling your work to a hiring manager, it tells *you* what patterns it sees across your projects — what you keep reaching for, where you invest testing effort, how your design-first workflow shows up across repositories. The portfolio overview weaves thirty projects into a single narrative about trajectory and craft. It is, genuinely, a useful mirror.

## Results

Thirty projects. 709 total commits across the portfolio. Ninety SVG infographics (three per project). Thirty-one markdown pages (one per project plus a portfolio overview). The whole pipeline runs in under five minutes. 119 tests cover the library.

The showcase section is live on the site. Every project page has a narrative, a stats card, a commit timeline, and a release timeline — all generated from artifacts that already existed, with no manual writing required. When I ship a new version of any project, I run `showcase refresh` and the page updates itself.

---

**Source**: [github.com/jpurnell/project-showcase](https://github.com/jpurnell/project-showcase)
