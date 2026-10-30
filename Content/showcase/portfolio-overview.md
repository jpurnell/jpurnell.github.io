---
title: Developer Portfolio Overview
description: Cross-project portfolio covering 23 projects and 1917 total commits.
date: 2026-05-13 16:41
lastModified: 2026-10-30
tags: showcase, portfolio, overview
layout: ShowcaseLayout
projects: ApplesoftBASICAppCore, ApplesoftBASICLib, development-guidelines, MLXTest, IconquerAI, IconquerClient, IconquerCLILib, IconquerCore, IconquerGameKit, IconquerMatch, IconquerMCP, IconquerServer, IconquerUI, IJSCore, MCPClient, narbis, PersonalSiteLib, BoundedIO, ProjectShowcase, SearchOperatorCore, SwiftCLIKit, SwiftMCPServer, SwiftSVG
published: true
---

# Two Years at the Frontier of Swift: A Portfolio in Motion

> In roughly two years and 1,917 commits across 23 Swift packages, this developer has built a coherent, interconnected ecosystem spanning retro computing archaeology, AI agent infrastructure, multiplayer game backends, biofeedback signal processing, MCP tooling, and static site generation — all under a single, enforced engineering discipline.

## Overview

What first appears to be a collection of unrelated projects reveals itself, on closer inspection, as a single expanding platform. The earliest commit (November 2024) lands in a period when the developer is already thinking in systems: rules engines, orchestration layers, presentation libraries, and server backends are conceived as separate packages from the start, not factored out later. By the most recent commit (October 2026), that instinct has produced a mature multi-repo ecosystem — the iConquer game alone spans nine discrete packages (IconquerCore, IconquerMatch, IconquerAI, IconquerClient, IconquerServer, IconquerMCP, IconquerCLILib, IconquerGameKit, IconquerUI) — each with a narrow, documented responsibility.

Two themes recur across every domain the developer touches. The first is **fidelity**: ApplesoftBASICLib promises 1979 behavior "including the parts that were surprising then"; BoundedIO derives from Selinger's paper rather than the GPL source to guarantee independent correctness; IconquerCore pins behavior to a deterministic seeded RNG so a TypeScript oracle can verify it. The second is **separation of concerns as a forcing function for testability**: every project draws a hard boundary between the thing that knows the rules and the thing that presents them, the thing that computes and the thing that renders, the thing that speaks the protocol and the thing that supplies the tools.

The developer also runs one of the more unusual self-imposed constraints in the portfolio: `development-guidelines`, a versioned rulebook that is itself a published project with 167 commits and 17 releases, consumed by 17 of the 23 other projects via `CLAUDE.md` files. The rulebook is not advisory; its rules are enforced by a quality gate, and rules that failed in practice are recorded with their failures. The portfolio is, in part, a longitudinal test of whether those rules are followable.

## Technical Breadth

Every line of production code in the portfolio is Swift. That single-language commitment is not a limitation; it is a deliberate surface-area choice that lets the developer apply a uniform quality gate, a uniform documentation convention (`swift-docc-plugin` appears in 21 of 23 projects), and a uniform concurrency model (Swift 6 strict concurrency, actor isolation, `Sendable` everywhere) across the entire body of work.

The platform spread is genuinely wide. Targets appear across iOS, macOS, tvOS, visionOS, and watchOS; SwiftCLIKit explicitly targets Linux via Swift NIO. Within that Swift-only constraint, the domains covered are heterogeneous:

- **Networking and protocol implementation** — SwiftNIO WebSocket server (IconquerServer), SwiftNIO client (IconquerClient), full MCP client (MCPClient) and server (SwiftMCPServer) over HTTP/SSE, WebSocket, and stdio transports, SSH server embedded in SwiftCLIKit
- **Machine learning** — MLX Swift inference and self-play training pipelines in IconquerAI; biofeedback HRV signal processing with FFT in narbis
- **Interpreter and language runtime** — a complete Applesoft BASIC interpreter with a line editor, lo-res and hi-res graphics renderer, and period-accurate fonts in ApplesoftBASICLib
- **Vector graphics and geometry** — an independent Swift derivation of the Potrace algorithm in BoundedIO; a Foundation-only SVG generation library in SwiftSVG
- **Terminal UI** — SwiftCLIKit's two-layer architecture (low-level terminal foundation + cell-based UI framework) with 164 commits and 23 releases
- **Static site generation** — PersonalSiteLib as the primary consumer of an Ignite fork, with pages as Swift types
- **AI and MCP tooling** — SearchOperatorCore, IconquerMCP, IJSCore, and MCPClient form a coherent MCP infrastructure layer

The shared dependency graph reveals the architecture beneath the project list. SwiftCLIKit, SwiftMCPServer, SwiftTLSKit, and IconquerCore each appear as dependencies in multiple downstream packages, confirming that these are genuine infrastructure layers rather than one-off utilities.

## Craft Signals

**Design-first as a non-negotiable.** The `development-guidelines` project encodes a "Design-First TDD" workflow, and 17 of 23 projects carry the `CLAUDE.md` that references it. Across the iConquer ecosystem, every package's MASTER_PLAN.md defines Target Consumers and Key Differentiators before implementation begins. IconquerAI's plan pre-registers benchmark criteria in git before the runs they judge — a discipline that prevents post-hoc rationalization of results.

**Zero-tolerance quality gates.** The `development-guidelines` rulebook is explicit: "zero tolerance for warnings." SwiftMCPServer (168 commits, 38 releases), IconquerServer, and MCPClient all declare Swift 6 `.v6` language mode with strict concurrency. The quality gate is not aspirational; it ships.

**Release discipline at scale.** 132 releases across 23 projects, with SwiftMCPServer alone accounting for 38. SwiftCLIKit has 23; MCPClient has 9. These numbers indicate a developer who treats version boundaries as meaningful signals to downstream consumers rather than administrative overhead.

**Honesty about decisions, including reversals.** MCPClient's MASTER_PLAN.md contains a striking self-correction: the "zero dependencies" differentiator is struck through with an explicit annotation — "No longer true, and hasn't been for some time" — followed by a plain-English account of what was traded and why. This pattern, recording the failure alongside the decision, mirrors what `development-guidelines` calls for explicitly and reflects a consistent preference for accurate documentation over flattering documentation.

**AI tooling used minimally and deliberately.** Across 1,917 commits, only 10 are AI-assisted and only 2 Claude Code sessions are recorded. The developer is building AI infrastructure (MCP servers, LLM-backed game agents, the IJSCore judgment loop) while keeping AI's role in their own workflow narrow and logged.

**Documentation as a first-class deliverable.** `swift-docc-plugin` appears in 21 of 23 packages. The MASTER_PLAN.md convention — Mission, Target Users, Key Differentiators — is applied consistently enough that a tool like ProjectShowcase can treat it as authoritative structured data.

## Key Projects

**development-guidelines** is a versioned, vendorable rulebook for AI-assisted Swift development. It exists because the developer wanted a process that could be installed on day one of a project and enforced rather than merely referenced. With 167 commits and 17 releases, it predates or coincides with the start of every other project in the portfolio, and its presence in 17 downstream `CLAUDE.md` files makes it the load-bearing beam of the entire body of work. The fact that it tracks its own failures — rules that did not survive contact with practice — makes it a living document rather than a manifesto.

**SwiftMCPServer** is a Swift implementation of the Model Context Protocol server, owning protocol framing, HTTP transport, and auth so that a server author supplies only tools, resources, and prompts. It exists because the developer needed a reusable MCP server layer across multiple projects (IconquerMCP, SearchOperatorCore) and built the infrastructure rather than repeating it. At 168 commits and 38 releases — the highest release count in the portfolio — it is the most actively maintained infrastructure package and evidence that the iConquer and AI tooling work is generating genuine reuse.

**MCPClient** is a spec-compliant Swift MCP client library supporting HTTP/SSE, WebSocket, and stdio transports with OAuth. It exists as the client-side counterpart to SwiftMCPServer, enabling any Swift application to connect to MCP servers. At 110 commits and 9 releases across macOS, iOS, tvOS, and watchOS, it is the widest-platform package in the portfolio and the one whose MASTER_PLAN.md most candidly documents an architectural pivot.

**The iConquer ecosystem** (IconquerCore, IconquerMatch, IconquerAI, IconquerGameKit, IconquerUI, IconquerClient, IconquerServer, IconquerMCP, IconquerCLILib) is collectively a faithful Swift port of a 2002 Mac strategy game, rebuilt as a distributed system. The rules engine is pure Swift with deterministic seeded RNG; a TypeScript reference port provides behavioral parity; the server is actor-isolated with Swift 6 strict concurrency; AI opponents run MLX inference and self-play training; a full MCP server exposes the game to AI agents; a TUI terminal client provides animated dice rolls and colored territory maps. The 390+ combined commits across the nine packages represent the largest single undertaking in the portfolio and a demonstration that the developer's architectural instincts hold under genuine complexity.

**ApplesoftBASICLib** is a faithful Applesoft BASIC interpreter in modern Swift, built to celebrate Apple's 50th anniversary. It exists to run 1979 listings — including their surprising behaviors — on iPad, Mac, and Vision Pro without an emulator. The interpreter is a library first, embeddable by any client, and ships its own line editor and Apple II graphics renderer. Together with ApplesoftBASICAppCore, it demonstrates that "fidelity" is a design constraint this developer takes literally.

**narbis** is a cross-platform Swift library that ingests BLE heart rate data, processes it through a patented HRV coherence algorithm, and emits biofeedback signals. It exists to run a clinically-grounded algorithm entirely on-device, offline, across Apple platforms and Android via the Swift 6.3 SDK. At 336 commits — the highest single-project commit count in the portfolio — it is also the deepest: the CLAUDE.md architecture section covers session start, development workflow, development process, Swift development, key rules, agent usage, quality assurance, and file organization, a scope that suggests this is the project where the engineering discipline is most fully exercised.

**SwiftCLIKit** is a pure Swift terminal UI library with a low-level terminal foundation, a cell-based UI framework, and an embedded SSH server, with zero C dependencies beyond system libc. It exists as infrastructure for IconquerCLILib and any other Swift project needing rich terminal output on macOS or Linux. At 164 commits and 23 releases, it is the second-most-released package in the portfolio.
