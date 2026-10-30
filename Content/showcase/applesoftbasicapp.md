---
title: ApplesoftBASICAppCore: Bringing the Apple II Back to Life on Modern Hardware
description: A native Swift package powering a faithful Applesoft BASIC runtime across iPad, Mac, and Vision Pro — complete with graphics, sound, and period-accurate presentation.
date: 2026-05-12 15:55
lastModified: 2026-10-30
tags: showcase, project, applesoftbasic, selfReflection
layout: ShowcaseLayout
style: caseStudy
project: ApplesoftBASIC
published: true
---

# ApplesoftBASICAppCore: Bringing the Apple II Back to Life on Modern Hardware

> A native Swift package powering a faithful Applesoft BASIC runtime across iPad, Mac, and Vision Pro — complete with graphics, sound, and period-accurate presentation.

## Problem

Applesoft BASIC shaped a generation of programmers. For millions of people who grew up typing listings from *Compute!* magazine or *Creative Computing*, the Apple II was their first encounter with software as something you could make yourself. But that experience has effectively been stranded in time — emulators exist, but they carry the weight of full system emulation and rarely feel at home on modern hardware.

ApplesoftBASICAppCore is the library layer beneath an app designed to solve that problem directly. The project's stated mission is an iPad, Mac, and Vision Pro application that runs Applesoft BASIC programs with a retro terminal experience — editor, terminal, lo-res and hi-res graphics, and speaker sound — on top of a dedicated interpreter. It targets three distinct audiences: people revisiting the Apple II BASIC they grew up with, learners encountering a small and immediately legible language for the first time, and owners of vintage listings from books and magazines who have nowhere to run them anymore. That last group in particular has been poorly served — a dog-eared copy of a 1982 type-in program is useless without something that speaks the full language.

The key differentiator the project stakes its claim on is running the real language, not a subset. Graphics and sound are included, not deferred.

## Approach

The project is structured as a Swift package targeting macOS and iOS simultaneously, using Swift tools version 6.2. The separation of concerns is deliberate: ApplesoftBASICAppCore and its companion test target, ApplesoftBASICAppCoreTests, form a library layer decoupled from any specific UI host. This architecture means the same interpreter core can underpin a Mac app, an iPad app, and a Vision Pro experience without forking logic — the platform-specific presentation layer sits above it.

The sole declared dependency is swift-docc-plugin, which signals that documentation is treated as a first-class concern rather than an afterthought. For a project whose audience includes nostalgic users and first-time learners, that emphasis on legible, browsable documentation is an appropriate investment.

The decision to build natively — one Swift codebase across three platforms — rather than wrapping a web runtime or porting a C emulator directly reflects a conviction that the experience on each device should feel native. Period-accurate presentation, specifically the PrintChar21 and PRNumber3 fonts rendered green-on-black, is not cosmetic flair; for the target audience, that fidelity is the point.

## Results

Over roughly six months of development, from April to October 2026, the project reached three formal releases: v1.0.0, v1.1.0, and v1.2.0. That cadence — three versioned milestones in six months from a solo contributor — reflects sustained, deliberate progress rather than a sprint-and-abandon pattern. The 31 commits across a single branch suggest a developer working methodically, with releases used as genuine checkpoints rather than marketing events.

The package ships with a dedicated test target, establishing a baseline for interpreter correctness that matters considerably when the language runtime is the product. A BASIC interpreter that silently mishandles edge cases in the real language isn't serving its audience — it's just another incomplete implementation.

## Judgment Calls

Several decisions here reveal considered craft rather than default choices.

**Full language fidelity over a useful subset.** The easiest version of this project omits hi-res graphics and PEEK/POKE sound — they're hard, they vary by hardware behavior, and most users might not immediately notice. Committing to the full language instead is a harder promise but the right one for users who want to run their actual vintage listings without hunting for which features were cut.

**Library-first architecture.** Structuring ApplesoftBASICAppCore as a standalone Swift package rather than embedding the interpreter logic directly in the app is a meaningful architectural choice. It enforces a discipline boundary between the runtime and the UI, makes the core independently testable, and leaves the door open to other consumers — a command-line tool, a SwiftUI preview harness, a Playgrounds integration — without restructuring the codebase.

**Native across three platforms from one codebase.** Vision Pro support isn't obviously necessary for a retro BASIC environment, but its inclusion speaks to a developer thinking about where the audience for this kind of experience will be, not just where it is today. A learner encountering Applesoft BASIC for the first time in a spatial computing environment in 2026 is a coherent use case, and the architecture accommodates it without compromise.

**DoCC as a documentation strategy.** Choosing swift-docc-plugin over no documentation infrastructure — particularly for a project serving nostalgic users and learners — reflects an understanding that the interpreter's public interface needs to be discoverable. A library this opinionated about its mission should be equally opinionated about how it explains itself.
