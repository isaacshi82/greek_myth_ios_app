# Greek Mythology iOS App — Summer 2026 Brainstorm & Plan

## The Big Picture

2–3 months at ~2 hrs/day = roughly **120–180 hours total**. That's a real, shippable app if scoped right. The sweet spot is something small enough to finish but rich enough that Isaac feels proud showing it to friends.

---

## Phase 1 — Brainstorm & Design (Weeks 1–2)

**Goal:** Pick the app idea together. Don't skip this — buy-in from Isaac here drives motivation for the whole summer.

**Session activities:**
- Browse Greek mythology together (books, Percy Jackson, YouTube). Ask Isaac: *what's the coolest part?*
- Evaluate 3–4 app ideas side by side (see options below)
- Pick one, write a one-paragraph "what is this app" description
- Sketch 3–5 screens on paper — no code yet

**App idea candidates:**

| Idea | Fun factor | Scope | Isaac learns |
|---|---|---|---|
| **Myth Quiz Game** | Medium | Small | SwiftUI, data modeling |
| **God Card Collector** | High | Medium | Collections, animations |
| **Adventure / Choose-your-path** | Very high | Medium-large | Game state, branching logic |
| **Mythology Encyclopedia** | Low | Small | Lists, navigation, search |
| **2D mini-game** (e.g. dodge Zeus's lightning) | Very high | Large | SpriteKit, physics |

**Recommendation:** The **God Card Collector** or **Choose-your-path adventure** hits the sweet spot — visual, fun, achievable, and a natural fit for Greek myths.

**Isaac's GitHub task this phase:**
- Create his first branch (`design/brainstorm`)
- Commit the paper sketches as photos
- Open a pull request and practice writing a description

---

## Phase 2 — Foundation (Weeks 3–5)

**Goal:** Scaffold the Xcode project so every future session starts from working code.

- Set up Xcode project with SwiftUI
- Establish folder structure: `/Models`, `/Views`, `/Assets`, `/Data`
- Create the data model: gods, myths, attributes (JSON files to start)
- Build the main menu screen and basic navigation
- Add a placeholder for the core feature

**Isaac's AI task this phase:**
- Learn to give Claude Code a prompt like: *"Create a Swift struct for a Greek god with name, domain, symbol, and a short description"*
- Review the generated code line by line together — explain what `struct`, `var`, and `String` mean

**Isaac's GitHub task:**
- Feature branches for each screen (`feature/main-menu`, `feature/god-model`)
- Practice `git pull` before every session to stay in sync

---

## Phase 3 — Core Feature Build (Weeks 6–10)

**Goal:** Build the actual thing. This is the bulk of the summer.

- Implement the primary game loop or content experience
- Integrate real mythology content (curate ~12 gods, ~10 myths)
- Source or generate art (see Assets section below)
- Add animations (SwiftUI transitions or Lottie)
- Add sound effects (free SFX libraries or GarageBand)
- Weekly "playtests" — Isaac plays it, lists what feels broken or boring, fix it next session

**Assets strategy:**
- **Illustrations:** Use AI image generators (Midjourney, DALL-E, Adobe Firefly) — prompt together, pick favorites, export as PNG
- **Animations:** Lottie files from LottieFiles.com, or simple SwiftUI `.animation()` transitions
- **Sounds:** Freesound.org or GarageBand loops
- Keep an `/Assets/raw` folder with originals and `/Assets/processed` for what goes into Xcode

**Isaac's AI task this phase:**
- Prompt engineering practice: learn to add constraints (*"in SwiftUI, no external libraries, under 50 lines"*)
- Debug with Claude: paste an error, ask what it means, understand the fix before applying it

---

## Phase 4 — Polish & Publish (Weeks 11–12)

**Goal:** Ship it. A real app on the App Store (or at minimum TestFlight) is the trophy.

- App icon (design together, export all required sizes)
- Launch screen
- Accessibility basics (large text, VoiceOver labels)
- App Store Connect: create the listing, write the description, take screenshots on Simulator
- Submit for review (~1–3 day turnaround)

**Isaac's GitHub task:**
- Tag the release (`v1.0`) — explain what a git tag is
- Write the release notes together

---

## Pacing & Rhythm

| Cadence | What to do |
|---|---|
| **Start of each session** | `git pull`, read last session's notes, set a goal for today |
| **During session** | Code in focused 25-min chunks; Isaac drives the AI prompts |
| **End of each session** | Commit working code, write a 2-sentence note about what you did and what's next |
| **End of each week** | Mini-review: what's done, what's blocked, adjust scope if needed |

---

## What Makes This Work

- **Isaac drives the prompts.** You guide, he types. This builds the muscle.
- **Commit every session.** Even ugly progress. The git history becomes a diary of the summer.
- **Scope ruthlessly.** If something takes too long, cut it or simplify. Shipping > perfecting.
- **Make it his.** Let Isaac name the app, pick the gods, choose the colors. Ownership = motivation.
