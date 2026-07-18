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
- ✅ ComfyUI running on A40; Flux **schnell** installed; API generation proven
  (first image: a young Zeus).
- ⏭️ Add **Flux dev** + reference-conditioning (Redux/Kontext/IPAdapter) + ControlNet
  to prove single-character consistency, then build the multi-character Titan scene.
- 💸 **Stop the pod when idle.** Rotate the Gemini + HuggingFace tokens (both were
  pasted in chat during setup).
