# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Greek mythology iOS app/game built as a summer 2026 father-son project. The game/app concept is still being finalized through a brainstorming and design phase (see roadmap below). The project uses AI-assisted development (Claude Code + OpenAI Codex) as a primary workflow.

## Build & Run Commands

> Commands will be filled in once the tech stack and Xcode project are set up. Expected entries:
> - Build: `xcodebuild -scheme <AppName> -destination 'platform=iOS Simulator,name=iPhone 16'`
> - Run tests: `xcodebuild test -scheme <AppName> -destination 'platform=iOS Simulator,name=iPhone 16'`
> - Lint: `swiftlint` (if SwiftLint is added)

## Architecture

> Architecture notes will be added once the project structure is scaffolded. Expected sections:
> - App entry point and SwiftUI scene structure
> - Game engine or framework choice (SpriteKit / GameplayKit / SwiftUI-only)
> - Asset pipeline (how images and animations are organized and loaded)
> - Data model (gods, myths, levels, game state)

## Summer Roadmap

### Phase 1 — Brainstorm & Design (Weeks 1–2)
- Explore game/app ideas (quiz app, card game, adventure game, myth explorer, etc.)
- Pick a theme and scope appropriate for a 2–3 month build
- Sketch basic screens and game flow on paper or Figma
- Decide tech stack: SwiftUI-only vs. SpriteKit for 2D game, or a hybrid

### Phase 2 — Foundation (Weeks 3–5)
- Set up Xcode project, folder structure, and Git branching strategy
- Build core data model: gods, myths, creatures, stories
- Implement navigation skeleton (main menu → game/content screens)
- Establish asset pipeline: where art and animations live, how they load

### Phase 3 — Core Gameplay / Content (Weeks 6–10)
- Implement the primary game loop or main feature
- Integrate mythology content (text, images, illustrations)
- Add basic animations and sound effects
- Iterative playtesting and refinement each session

### Phase 4 — Polish & Publish (Weeks 11–12)
- App icon, launch screen, and UI polish
- TestFlight internal testing
- App Store Connect setup: screenshots, description, age rating
- Submit to App Store review

## Learning Goals (for Isaac)

1. **AI-assisted development** — using Claude Code and Codex to scaffold, debug, and iterate; writing good prompts
2. **Git & GitHub** — branching, committing with meaningful messages, pull requests, resolving conflicts
3. **iOS publishing** — Apple Developer account, certificates/provisioning, TestFlight, App Store submission
4. **Swift / SwiftUI basics** — understanding generated code, making small edits confidently

## AI Workflow Notes

- Use Claude Code for architecture decisions, feature scaffolding, and debugging
- Use Codex (via GitHub Copilot or API) for inline completions and boilerplate
- Isaac should write or dictate the prompt first; treat AI output as a draft to review together, not a final answer
- Commit working checkpoints frequently so it is easy to roll back experiments
