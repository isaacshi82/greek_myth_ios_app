# Chapter 1 — Ready-to-Paste Panel Prompts (chapter1-02 … chapter1-14)

**You generate these in Gemini.** Panels **1 and 15 are the Hermes guide** (animated frames) — no illustration needed. So you only generate **13 scenes: `chapter1-02` … `chapter1-14`**.

## Workflow for consistency
1. **Generate character reference sheets first** (Cronus-king, young Zeus, Gaia, Rhea) and keep your favorites.
2. For each panel, use Gemini's **reference-image** feature with the matching character sheet so they stay consistent.
3. **Batch by character** (do all the Cronus panels together off the same reference), not in panel order.
4. **Aspect ratio:** square **1:1** (the app crops to fit). 4:5 portrait also works if you prefer.
5. Each prompt below is self-contained — paste it as-is. The style line is identical every time (don't change it).

> **STYLE (identical in all):** Bold graphic-novel illustration fusing the painterly cel-shaded art of the video game *Hades* (Jen Zee) with Japanese manga linework: strong inky black outlines, dramatic rim lighting and deep shadows, saturated jewel-tone palette, expressive angular character design, dynamic cinematic composition. No text, no speech bubbles, no watermark.

---

### chapter1-02 — Chaos
> *[STYLE]* A vast, dark cosmic void: swirling mist and faint sparks of light in endless empty space, the very beginning of everything. Moody deep blues and blacks, lonely and primordial. Wide, atmospheric, abstract composition. No characters.

### chapter1-03 — Gaia & Uranus
> *[STYLE]* Gaia, a majestic primordial Earth-goddess with flowing hair of roots and leaves and skin like warm stone, rising from a landscape of mountains and forests below; Uranus, a vast primordial Sky-god formed of the night sky and glowing constellations, arching above her. The first king and queen of all. Epic, reverent, wide composition.

### chapter1-04 — The twelve Titans
> *[STYLE]* A group of twelve towering, regal Titans standing across a primordial landscape; at the front, the young Titan Cronus — tall and imposing with a sharp jaw, intense dark eyes, long dark hair, dark earth-toned armor — steps forward, confident. Awe-inspiring scale, low heroic camera angle.

### chapter1-05 — Uranus the cruel father
> *[STYLE]* A sorrowful Gaia (primordial Earth-goddess, hair of roots and leaves); trapped beneath her glowing surface are monstrous shapes — one-eyed Cyclopes and hundred-handed giants — locked deep inside the Earth. Dramatic underground glow, oppressive and sad.

### chapter1-06 — Cronus rises
> *[STYLE]* The young Titan Cronus (sharp jaw, intense dark eyes, long dark hair, dark armor) grips a giant gleaming curved sickle with a determined glare; his mother Gaia hands it to him from the shadows. Tense, heroic rim lighting.

### chapter1-07 — Cronus takes the throne
> *[STYLE]* Cronus as king — older, crowned, broad-shouldered, in a dark robe patterned with stars and cosmos motifs — seated on a massive ancient stone throne; the sky dims behind him and a faint, ominous ghostly face of Uranus forms in the clouds. Foreboding, regal.

### chapter1-08 — The prophecy
> *[STYLE]* Extreme close-up of King Cronus's worried, paranoid face (crowned, grim) lit by eerie cold light; glowing prophetic symbols swirl around his head. Unsettling, psychological, high contrast.

### chapter1-09 — Cronus swallows his children
> *[STYLE]* A giant, shadowy King Cronus cradling a single swaddled, glowing infant — stylized and mythic like a dark fairy tale, NOT gory or frightening; in the background, the Titaness Rhea (long flowing hair, sorrowful eyes, draped robe) weeps. Dark, somber, dramatic shadow.

### chapter1-10 — Rhea's plan
> *[STYLE]* The Titaness Rhea secretly cradles a glowing baby Zeus while holding out a swaddled stone toward a looming King Cronus. Tender light on the baby, heavy shadow on Cronus. Tense and hopeful.

### chapter1-11 — Zeus grows up in secret
> *[STYLE]* A lush, hidden cave on a Greek island; a faintly glowing baby Zeus (tuft of dark hair, golden aura) tended by gentle nymphs and a goat. Warm, safe, magical, secret.

### chapter1-12 — Zeus frees his siblings
> *[STYLE]* A triumphant young Zeus (athletic young man, dark curling hair, short beard, crackling lightning, white-and-gold chiton) as five adult gods — including Poseidon with a trident and a shadowy Hades — burst out in shafts of light from a staggering King Cronus. Action, energy, golden light.

### chapter1-13 — The Titanomachy
> *[STYLE]* Epic battle across a storming sky: the young gods versus the giant Titans. Young Zeus hurls crackling thunderbolts; hundred-handed giants fling boulders. Cinematic chaos, electric, dramatic scale.

### chapter1-14 — Victory and the division of the world
> *[STYLE]* Three victorious gods standing over a glowing, divided world: Zeus wreathed in lightning (the sky), Poseidon with his trident (the sea), and a shadowy Hades (the underworld). Triumphant, balanced, regal composition.

---

## After generating
Name them `chapter1-02` … `chapter1-14`, then add each with:
`./add-asset.sh ~/Downloads/<file>.jpeg chapter1-02 scenes` (etc.)
They auto-replace the placeholders in the chapter — no code change.
