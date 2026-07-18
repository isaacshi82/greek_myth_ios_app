# ComfyUI on RunPod — setup & resume guide

How we run ComfyUI on a cloud GPU to generate art (especially consistent
multi-character scenes that the single-prompt Gemini API can't do). Written for
picking the work back up in a later session.

## Why cloud GPU (not local)
The dev Mac (M1 Pro, ~37 GB free) can't hold Flux + control models. RunPod gives a
real NVIDIA GPU by the hour. We use an **A40 (48 GB VRAM) ≈ $0.44/hr** — the 48 GB
headroom avoids out-of-memory crashes with the IPAdapter/ControlNet stack.

## First-time pod setup (bare `runpod/pytorch` template)
1. Deploy a Pod → **A40**, template **Runpod Pytorch**, **Volume disk 80 GB**
   (mounted at `/workspace` — the only disk that survives a restart).
2. **Expose HTTP port 8188** (Edit Pod → Expose HTTP Ports → `8888, 8188`).
3. Open the **Web Terminal** and install ComfyUI into `/workspace`:
   ```bash
   cd /workspace && git clone https://github.com/comfyanonymous/ComfyUI && cd ComfyUI
   pip install -r requirements.txt
   git clone https://github.com/ltdrdata/ComfyUI-Manager custom_nodes/comfyui-manager
   apt-get update && apt-get install -y aria2      # fast downloader (HF throttles wget)
   aria2c -x 16 -s 16 -d models/checkpoints -o flux1-schnell-fp8.safetensors \
     https://huggingface.co/Comfy-Org/flux1-schnell/resolve/main/flux1-schnell-fp8.safetensors
   ```
4. **Launch (note the flags — both are required):**
   ```bash
   python main.py --listen 0.0.0.0 --port 8188 --enable-cors-header
   ```
   - `--listen 0.0.0.0` so the pod proxy can reach it.
   - `--enable-cors-header` — **without this the RunPod proxy returns 403** (ComfyUI's
     host/origin check rejects the proxied domain).
5. Connect tab → **Port 8188 → HTTP Service** opens the ComfyUI GUI.

## Driving it from code (no browser) — `scripts/comfy_gen.py`
The pod's ComfyUI is reachable at `https://<POD_ID>-8188.proxy.runpod.net`. Its HTTP
API lets us queue workflows and pull images directly:
```bash
COMFY_URL=https://<POD_ID>-8188.proxy.runpod.net \
python3 scripts/comfy_gen.py --prompt "a young Zeus with lightning" --out /tmp/zeus.png
```
Two non-obvious requirements the script already handles:
- **Browser `User-Agent`** — RunPod is behind Cloudflare, which 403s `Python-urllib`.
- **`Origin` header matching the host** — ComfyUI blocks POSTs otherwise.

Key API endpoints: `POST /prompt` (queue), `GET /history/{id}` (result),
`GET /view?filename=...` (download), `POST /upload/image` (push a reference image).

## Resuming after a Stop
Stopping the pod saves money (~$0.01/hr storage vs ~$0.44/hr running) but **wipes the
container disk** — `/workspace` (ComfyUI + downloaded models) survives, but the
pip-installed Python packages do NOT. On restart:
```bash
cd /workspace/ComfyUI && pip install -r requirements.txt
python main.py --listen 0.0.0.0 --port 8188 --enable-cors-header
```
The pod ID (and thus the proxy URL) changes on redeploy — grab the new one from the
Connect tab and update `COMFY_URL`.

## Reference art for consistent characters
Upload the generated `titan-*` / `god-*` portraits
(`assets/raw/characters/`) to the pod as IPAdapter/reference inputs via
`POST /upload/image`. Scene spec for the Titan group panel:
`workflows/titans-group-scene.json`.

## Status / next steps
- ✅ ComfyUI running on A40; Flux **schnell** + **dev** + **Kontext** installed
  (`models/checkpoints/flux1-{schnell,dev}-fp8.safetensors`,
  `models/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors`).
- ✅ API generation proven end-to-end via `scripts/comfy_gen.py` (basic Flux) and
  `scripts/comfy_kontext.py` (character-consistent Kontext). First proofs: young Zeus,
  and Oceanus (from his bust portrait) re-rendered full-body in a new scene — **identity
  held** (face, beard, green hair, coral circlet all carried over).

### Kontext = character consistency (working)
`scripts/comfy_kontext.py --ref <portrait> --prompt "<new scene>" --out x.png`. It reuses
the flux dev fp8 checkpoint for CLIP+VAE (no separate text-encoder/VAE downloads needed).
**Tuning lessons:** state the palette explicitly ("muted, weathered, desaturated") or it
drifts to saturated comic colors; constrain proportions ("~8 heads tall, normal head, NOT
chibi") when using a bust reference. Palette never matches the reference *exactly* — that's
style-LoRA territory if we ever need it.

### Decision: multiple references per character (2026-07-18)
Each character (Titans, gods, heroes-later) gets **multiple reference images**, not one:
- **portrait/bust** (the current `titan-*` / `god-*` sheets) → app **library grid** + face anchor
- **full-body** → **scene work** with correct proportions (fixes Kontext's head-heavy
  extrapolation from busts). Kontext can also take *both* refs at once for stronger identity.
Plan: regenerate full-body sheets in **Gemini**, feeding each existing bust as a face
reference so identities stay consistent; then crop a portrait from the full-body for the
library. Store dev-side refs as e.g. `assets/raw/characters/full-body/<name>.jpg` alongside
the existing portrait `assets/raw/characters/<name>.jpg`.

- ⏭️ **Next session:** generate full-body references, then build the multi-character Titan
  scene (iterative Kontext per character, or the SDXL regional route).

### Turnkey: download Flux Kontext (all public, no token — verified)
Run in a JupyterLab terminal (aria2 already installed; ~17 GB total, ~3 min @ 125 MB/s):
```bash
cd /workspace/ComfyUI
B=https://huggingface.co/Comfy-Org/flux1-kontext-dev_ComfyUI/resolve/main/split_files
aria2c -x16 -s16 -d models/diffusion_models -o flux1-dev-kontext_fp8_scaled.safetensors \
  $B/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors
aria2c -x16 -s16 -d models/text_encoders -o t5xxl_fp8_e4m3fn_scaled.safetensors \
  $B/text_encoders/t5xxl_fp8_e4m3fn_scaled.safetensors
aria2c -x16 -s16 -d models/text_encoders -o clip_l.safetensors \
  $B/text_encoders/clip_l.safetensors
aria2c -x16 -s16 -d models/vae -o ae.safetensors $B/vae/ae.safetensors
```
Kontext workflow uses: UNETLoader (the kontext diffusion model) + DualCLIPLoader
(t5xxl + clip_l, type flux) + VAELoader (ae) + a reference image loaded via
`LoadImage`/`/upload/image` → FluxKontextImageScale → ReferenceLatent → sampler.
Then upload the `titan-*` refs via `POST /upload/image` and drive it with `comfy_gen.py`
using `--graph` (a Kontext API graph). Test: put `titan-oceanus` in a new heroic pose,
confirm identity holds.
- 💸 **Stop the pod when idle.** Rotate the Gemini + HuggingFace tokens (both were
  pasted in chat during setup).
