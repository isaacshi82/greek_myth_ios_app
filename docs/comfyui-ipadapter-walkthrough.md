# Learning IPAdapter + ControlNet in ComfyUI — Consistent Character Art

**Goal:** learn the core skill for putting a *specific character* in a *specific pose*,
consistently. This is the foundation for all the app's character art (library portraits,
story panels, group scenes). We build a **simple 1-character version first** to learn the
mechanics, then scale up to the full multi-character Titan scene.

## The two tools (the whole idea)
- **IPAdapter** = *WHO*. Feed it a reference image of a character; it injects that
  identity into the generation so the output looks like that character — in any pose.
- **ControlNet (OpenPose)** = *HOW they're posed*. Feed it a stick-figure skeleton; it
  forces the generated figure into that pose/composition.
- **The prompt** = *style, scene, mood* — free to change once identity + pose are pinned.

Separating "who" from "how" is what gives **consistent + dynamic** at the same time.

## Assets already on the pod (in `Load Image` dropdowns)
- Character refs: `ref-titan-cronus-young.png`, `ref-titan-oceanus.png`, `ref-titan-hyperion.png`,
  `ref-titan-iapetus.png`, `ref-titan-rhea.png`, `ref-titan-theia.png`, `ref-titan-themis.png`,
  `ref-titan-phoebe.png`
- Pose skeleton: `pose.png`  •  Style ref: `style-ref.png`
- Region masks (for later): `mask-titan-*.png`

## Models on the pod
- Checkpoint: `animagineXL.safetensors` (illustrated style) — or `juggernautXL.safetensors`
- IPAdapter: `ip-adapter-plus_sdxl_vit-h.safetensors`  •  CLIP-vision: `CLIP-ViT-H-14.safetensors`
- ControlNet: `openpose-sdxl.safetensors`

---

## PART 1 — Build the simple workflow (~13 nodes, one character)

In the ComfyUI GUI: **right-click → Add Node** (or double-click the canvas and search).
Add these, then wire them (drag from an output dot to an input dot). Colors of the dots
must match (MODEL→MODEL, IMAGE→IMAGE, etc.).

1. **Load Checkpoint** → set `ckpt_name` = `animagineXL.safetensors`
   (gives 3 outputs: MODEL, CLIP, VAE)
2. **Load Image** → pick `ref-titan-cronus-young.png`  *(the character's identity)*
3. **IPAdapter Model Loader** → `ip-adapter-plus_sdxl_vit-h.safetensors`
4. **Load CLIP Vision** → `CLIP-ViT-H-14.safetensors`
5. **IPAdapter Advanced**
   - `model` ← Load Checkpoint MODEL
   - `ipadapter` ← IPAdapter Model Loader
   - `image` ← Load Image (#2)
   - `clip_vision` ← Load CLIP Vision (#4)
   - `weight` = **0.7** (this is the main knob — how strongly the character is enforced)
   - `weight_type` = `linear`
6. **Load ControlNet Model** → `openpose-sdxl.safetensors`
7. **Load Image** → pick `pose.png`  *(the pose skeleton)*
8. **CLIP Text Encode (Prompt)** ×2 (positive + negative), each `clip` ← Load Checkpoint CLIP
   - Positive: `masterpiece, best quality, a heroic young Titan god in ornate bronze armor
     striding forward, golden dawn, epic, painterly cel-shaded illustration, bold inky outlines`
   - Negative: `worst quality, low quality, blurry, extra fingers, watermark, text`
9. **Apply ControlNet (Advanced)**
   - `positive` ← positive prompt, `negative` ← negative prompt
   - `control_net` ← Load ControlNet Model (#6)
   - `image` ← Load Image pose (#7)
   - `strength` = **0.8**
10. **Empty Latent Image** → `width` 832, `height` 1216 (portrait for one figure)
11. **KSampler**
    - `model` ← IPAdapter Advanced (#5)  ← *identity flows through here*
    - `positive`/`negative` ← Apply ControlNet outputs  ← *pose flows through here*
    - `latent_image` ← Empty Latent
    - `steps` 30, `cfg` 6, `sampler_name` `dpmpp_2m`, `scheduler` `karras`
12. **VAE Decode** → `samples` ← KSampler, `vae` ← Load Checkpoint VAE
13. **Save Image** → `images` ← VAE Decode

Click **Queue Prompt**. You should get *young Cronus* (identity from #2) in the pose from
`pose.png` (his skeleton), in Animagine's illustrated style.

## PART 2 — Tune (this is the skill)
Change one thing, re-queue, look. Fast feedback is the whole point:
- **IPAdapter `weight`** (0.4–1.0): too low = doesn't look like him; too high = ignores the
  pose/prompt and can collapse. Find the sweet spot (~0.6–0.8).
- **ControlNet `strength`** (0.5–1.0) and **`end_percent`** (~0.8): how rigidly it follows
  the skeleton.
- **`weight_type`**: try `style transfer`, `strong style transfer` for different blends.

## PART 3 — Scale up to the full scene (multi-character)
Once the single-character version makes sense, the group scene adds **regional masking** so
each character only applies in their part of the frame:
- Use **IPAdapter Regional Conditioning** (one per character) with that character's
  `ref-*` image + their `mask-*` band, chaining the positive/negative through each.
- Combine them with **IPAdapter Combine Params**, apply with **IPAdapter From Params**.
- Keep the same ControlNet(pose) + KSampler tail.
- **Key lesson from our API attempts:** with 8 characters, per-character weight must be
  **low (~0.5–0.6)** and combine embeds `average` — otherwise the combined conditioning
  over-powers the model and the image collapses to grey. This is exactly the kind of
  balance that's fast to find in the GUI and painful blind.

## Why the GUI (not the API) for this
Tuning IPAdapter/ControlNet weights is a "change a slider, see the result in 20s" loop.
The GUI gives instant visual feedback; driving it blind through the API means guessing.
So: **prototype/tune here, then** we can capture the final settings back into a script for
batch runs.
