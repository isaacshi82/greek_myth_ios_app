# Hermes — Guide Character & Animation Frames

**Design:** "Cheeky trickster kid" · **Style:** Hades × manga (same Style Block as the chapter) · **Use:** front-facing talking guide, animated by swapping frames in SwiftUI.

## Design hooks (what makes him memorable — keep these every frame)
- Looks ~12–14, **caricatured** (not a realistic teen): **big expressive eyes**, a mischievous **gap-tooth grin**.
- **Oversized winged petasos** (traveler's cap) with little white wings on the sides — his signature silhouette.
- Tousled dark hair poking out from under the cap.
- Short tunic + small cloak, **gold accents**, with a **bright signature accent color (warm orange + teal)**.
- A **glowing gold coin** he flips (appears in the gesture frame).
- Hades × manga look: inky outlines, cel shading, jewel tones, rim light.

## STYLE BLOCK (verbatim, same as chapters)
> Bold graphic-novel illustration fusing the painterly cel-shaded art of the video game *Hades* (Jen Zee) with Japanese manga linework: strong inky black outlines, dramatic rim lighting and deep shadows, saturated jewel-tone palette, expressive angular character design. No text, no speech bubbles, no watermark.

---

## STEP 1 — Generate the MASTER (get one you love first)
**Generate in a FRESH chat thread** (an old thread anchors Gemini to the previous full-body running pose). Lead with the framing and use explicit negatives, or it defaults to an action pose:

> *[STYLE BLOCK]* **A HEAD-AND-SHOULDERS BUST PORTRAIT, viewed from the FRONT, facing the viewer directly, centered and symmetrical — like a character talking to the camera. NOT full-body, NOT a side or profile view, NOT a running or action pose.** A cheeky young Greek god, about 12–14, caricatured, with **big expressive eyes (open, looking right at the viewer)** and a warm mischievous gap-tooth grin. He wears an oversized winged traveler's cap (small white side-wings), tousled dark hair, a short tunic with a small cloak, gold accents, bright orange-and-teal colors. **Flat solid teal background.** Square 1:1.

→ Pick your favorite **front-facing, eyes-open** result. **This is the canon (`hermes-idle`).** All other frames are *edits* of this one image.

### If it keeps giving the wrong pose
- Start a brand-new thread (no earlier Hermes images in context).
- Keep the framing sentence FIRST, with the NOT-full-body / NOT-side-view negatives.
- "Bust portrait" + "facing the viewer" + "talking to the camera" are the key phrases.
- Eyes must be **open** for the master (closed eyes belong to the `hermes-blink` frame).

## STEP 2 — Derive the FRAMES by EDITING the master (do NOT re-generate)
For each, use Gemini's **edit/"change this image"** feature on the master so everything stays pixel-stable and only the delta changes:

- **`hermes-idle`** — the master itself (mouth closed, eyes open, friendly).
- **`hermes-talk`** — *"Keep this image identical in every way; change only his mouth to open, as if mid-speech."*
- **`hermes-blink`** — *"Keep identical; change only his eyes to closed, in a happy blink."*
- **`hermes-gesture`** — *"Keep identical; raise one hand in a welcoming wave while flipping a small glowing gold coin."*
- **`hermes-wink`** — *"Keep identical; change only to a playful wink (one eye closed) with a bigger grin."*

Start with **idle + talk + blink** (enough for a convincing talker); add gesture + wink for personality and quiz reactions.

## Consistency rules for frames (important!)
1. **Master + edits only** — re-generating each frame will jitter; editing keeps the rest locked.
2. **Identical crop, head position, lighting, and background** in every frame.
3. Flat solid background → we can keep it or cut him out to overlay on scenes with a dialogue box.

## How SwiftUI will use these
- **Talk loop:** alternate `hermes-idle ↔ hermes-talk` ~5x/sec while narration shows → "speaking."
- **Blink:** flash `hermes-blink` briefly every few seconds → "alive."
- **Reactions:** `hermes-wink` on the outro and on correct quiz answers.
- A styled **dialogue box** (SwiftUI) shows his words next to him.
