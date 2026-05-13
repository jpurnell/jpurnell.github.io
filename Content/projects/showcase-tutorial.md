---
layout: BlogPostLayout
tags: tutorial, swift, cli, portfolio, project
image:
imageDescription:
title: Generate a Developer Showcase for Your Swift Projects in 5 Minutes
link: https://github.com/jpurnell/project-showcase
date: 2026-05-12 12:00
lastModified: 2026-05-12
published: true
---

# Generate a Developer Showcase for Your Swift Projects in 5 Minutes

**Turn any git repository into a narrative portfolio page with structured facts, AI-written prose, and SVG infographics.**

---

ProjectShowcase is a Swift CLI that walks your project directory, extracts everything worth knowing -- git history, package manifest, test results, design docs -- and feeds it through Claude to produce a polished markdown write-up. Here's how to go from zero to published portfolio page.

## Prerequisites

- Swift 5.9+ (macOS 13+)
- `ANTHROPIC_API_KEY` set in your environment
- A git repository with at least a few commits

## Step 1: Install ProjectShowcase

```bash
git clone https://github.com/jpurnell/project-showcase.git
cd project-showcase
swift build
```

The executable lands at `.build/debug/showcase`.

## Step 2: Gather Facts

```bash
.build/debug/showcase gather ~/path/to/your/project --output card.json
```

This produces a `ProjectCard` JSON file containing everything the tool could find about your project:

- **Git facts** -- commit count, contributor list, first/last commit dates, recent commit messages, tags and releases
- **Package manifest** -- dependencies, targets, Swift tools version (also supports Node, Python, Rust, and Go)
- **Design artifacts** -- whether you have a CLAUDE.md, development-guidelines, design proposals, and architecture notes
- **Test results** -- pass/fail counts and suite names (add `--run-tests` to execute your test suite during gather)

If your project has Claude Code usage data, point to it with `--insights-path` to include session metrics.

## Step 3: Generate Narrative

```bash
.build/debug/showcase narrate card.json --audience selfReflection --style caseStudy --output narrative.json
```

This sends your ProjectCard to Claude, which returns structured narrative content shaped by your audience and style choices.

| Option | Values | Best for |
|--------|--------|----------|
| `--audience` | `hiringManager` (default) | Job applications, LinkedIn |
| | `openSourceContributor` | README and contributor docs |
| | `client` | Client-facing proposals |
| | `selfReflection` | Personal sites, dev blogs |
| `--style` | `caseStudy` (default) | Problem/solution storytelling |
| | `projectCard` | Quick summary with key stats |
| | `deepDive` | Full technical walkthrough |

I recommend `selfReflection` for personal sites -- it produces prose that reads like you wrote it, not like a recruiter pitch.

## Step 4: Render to Markdown

```bash
.build/debug/showcase render narrative.json --output ./content/
```

This takes the NarrativeResult JSON and renders it to a markdown file with YAML frontmatter:

```yaml
---
title: "Your Project Title"
description: "One-line summary"
date: 2026-05-12 12:00
lastModified: 2026-05-12
tags: showcase, project, yourproject, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: YourProject
published: true
---
```

The output file is named after your project (`your-project.md`) and placed in the output directory.

## Step 5: Generate Infographics

```bash
.build/debug/showcase infographics card.json --output ./assets/
```

This generates three SVG files from your ProjectCard data:

- **`your-project-stats.svg`** -- Key metrics at a glance: commit count, contributors, dependencies, test counts
- **`your-project-commits.svg`** -- Commit activity timeline showing development cadence
- **`your-project-releases.svg`** -- Release history with version tags and dates

The SVGs are self-contained -- no external dependencies, ready to embed in any web page or markdown file.

## Or: All-in-One

If you just want to go from project directory to finished markdown in one command:

```bash
.build/debug/showcase refresh ~/path/to/project \
  --audience selfReflection \
  --style caseStudy \
  --output ./content/
```

This runs gather, narrate, and render in sequence. Same options as the individual commands.

## Batch Processing

For multiple projects, gather the cards first, then narrate in a second pass:

```bash
for proj in ~/projects/*/; do
  .build/debug/showcase gather "$proj" \
    --output "/tmp/cards/$(basename "$proj")-card.json"
done

for card in /tmp/cards/*-card.json; do
  .build/debug/showcase narrate "$card" \
    --audience selfReflection \
    --style caseStudy \
    --output "/tmp/narratives/$(basename "$card" -card.json)-narrative.json"
done

for narrative in /tmp/narratives/*-narrative.json; do
  .build/debug/showcase render "$narrative" --output ./content/
done
```

The gather step is purely local -- no API calls, fast enough to run against dozens of repositories. The narrate step calls Claude once per project.

## Portfolio Overview

Once you have cards for multiple projects, generate a cross-project overview:

```bash
.build/debug/showcase portfolio /tmp/cards/*.json \
  --audience selfReflection \
  --output ./content/
```

This produces a `portfolio-overview.md` that weaves your projects into a single narrative -- connecting themes across repositories, highlighting your strongest work, and presenting aggregate stats. Useful as a landing page or an "about my work" section.

## Pro Tip: MASTER_PLAN.md

If your projects use [development-guidelines](https://github.com/jpurnell/development-guidelines) with a filled-in `MASTER_PLAN.md`, the gather step extracts your **Mission**, **Target Users**, and **Key Differentiators** sections and includes them as authoritative context in the ProjectCard. When the narrate step runs, Claude uses these as ground truth instead of guessing what your project does.

The difference is significant. Without a MASTER_PLAN, the narrative is inferred from commit messages and file structure -- accurate but generic. With one, the narrative knows *why* the project exists and *who* it's for, and the prose reflects that.

---

**Source**: [github.com/jpurnell/project-showcase](https://github.com/jpurnell/project-showcase)
