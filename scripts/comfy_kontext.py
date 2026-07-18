#!/usr/bin/env python3
"""Character-consistent image generation via Flux Kontext on a remote ComfyUI.

Give it a reference image of a character + a prompt describing a NEW scene/pose;
Kontext re-renders the SAME character in that new context. Runs entirely over the
ComfyUI HTTP API (upload reference, queue, poll, download) — no browser needed.

Uses the Kontext diffusion model for MODEL and reuses the all-in-one flux dev fp8
checkpoint for CLIP + VAE (identical Flux components — saves downloading them
separately). Requires on the pod:
  models/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors
  models/checkpoints/flux1-dev-fp8.safetensors

Usage:
  COMFY_URL=https://<pod>-8188.proxy.runpod.net \
  python3 scripts/comfy_kontext.py --ref assets/raw/characters/titan-oceanus.jpg \
      --prompt "the same man, full body, standing on a rocky shore, muted palette" \
      --out /tmp/oceanus_scene.png [--guidance 2.5 --steps 20]

Tuning lessons (from first runs):
  - State the palette explicitly ("muted, weathered, desaturated") or Kontext drifts
    toward saturated comic colors, especially if the scene implies strong light (sunset).
  - A bust reference makes full-body output head-heavy; constrain proportions
    ("realistic proportions, ~8 heads tall, normal-sized head, NOT chibi") or, better,
    use a FULL-BODY reference (see docs — we keep both a portrait and a full-body ref
    per character).
"""
import argparse, json, mimetypes, os, random, sys, time, urllib.parse, urllib.request, uuid

UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0 Safari/537.36"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ref", required=True, help="reference image of the character")
    ap.add_argument("--prompt", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--guidance", type=float, default=2.5)
    ap.add_argument("--steps", type=int, default=20)
    ap.add_argument("--seed", type=int, default=None)
    ap.add_argument("--base", default=os.environ.get("COMFY_URL"))
    a = ap.parse_args()
    if not a.base:
        sys.exit("Set COMFY_URL or pass --base")
    base = a.base.rstrip("/")
    H = {"User-Agent": UA, "Origin": base, "Referer": base + "/"}
    seed = a.seed if a.seed is not None else random.randint(0, 2**31)

    # 1. upload the reference image
    boundary = "----" + uuid.uuid4().hex
    fn = os.path.basename(a.ref)
    mime = mimetypes.guess_type(a.ref)[0] or "image/jpeg"
    body = (f"--{boundary}\r\nContent-Disposition: form-data; name=\"image\"; filename=\"{fn}\"\r\n"
            f"Content-Type: {mime}\r\n\r\n").encode() + open(a.ref, "rb").read() + \
           (f"\r\n--{boundary}\r\nContent-Disposition: form-data; name=\"overwrite\"\r\n\r\ntrue\r\n--{boundary}--\r\n").encode()
    req = urllib.request.Request(base + "/upload/image", data=body,
        headers={**H, "Content-Type": f"multipart/form-data; boundary={boundary}"})
    name = json.load(urllib.request.urlopen(req, timeout=60))["name"]
    print("uploaded reference:", name)

    # 2. Kontext graph: Kontext UNET + dev checkpoint's CLIP/VAE + reference latent
    g = {
        "10": {"class_type": "UNETLoader", "inputs": {"unet_name": "flux1-dev-kontext_fp8_scaled.safetensors", "weight_dtype": "default"}},
        "11": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": "flux1-dev-fp8.safetensors"}},
        "12": {"class_type": "LoadImage", "inputs": {"image": name}},
        "13": {"class_type": "FluxKontextImageScale", "inputs": {"image": ["12", 0]}},
        "14": {"class_type": "VAEEncode", "inputs": {"pixels": ["13", 0], "vae": ["11", 2]}},
        "15": {"class_type": "CLIPTextEncode", "inputs": {"clip": ["11", 1], "text": a.prompt}},
        "16": {"class_type": "ReferenceLatent", "inputs": {"conditioning": ["15", 0], "latent": ["14", 0]}},
        "17": {"class_type": "FluxGuidance", "inputs": {"conditioning": ["16", 0], "guidance": a.guidance}},
        "18": {"class_type": "CLIPTextEncode", "inputs": {"clip": ["11", 1], "text": ""}},
        "19": {"class_type": "KSampler", "inputs": {"model": ["10", 0], "positive": ["17", 0], "negative": ["18", 0],
                "latent_image": ["14", 0], "seed": seed, "steps": a.steps, "cfg": 1.0,
                "sampler_name": "euler", "scheduler": "simple", "denoise": 1.0}},
        "20": {"class_type": "VAEDecode", "inputs": {"samples": ["19", 0], "vae": ["11", 2]}},
        "21": {"class_type": "SaveImage", "inputs": {"images": ["20", 0], "filename_prefix": "kontext"}},
    }

    def get(p):
        return json.load(urllib.request.urlopen(urllib.request.Request(base + p, headers=H), timeout=60))

    req = urllib.request.Request(base + "/prompt", data=json.dumps({"prompt": g}).encode(),
                                 headers={**H, "Content-Type": "application/json"})
    pid = json.load(urllib.request.urlopen(req, timeout=60))["prompt_id"]
    print("queued", pid, "seed", seed)

    # 3. poll + download (first Kontext run loads ~11GB into VRAM, be patient)
    for _ in range(200):
        time.sleep(3)
        node = get(f"/history/{pid}").get(pid, {})
        if node.get("outputs"):
            for o in node["outputs"].values():
                for img in o.get("images", []):
                    q = urllib.parse.urlencode({"filename": img["filename"], "subfolder": img.get("subfolder", ""), "type": img.get("type", "output")})
                    data = urllib.request.urlopen(urllib.request.Request(f"{base}/view?{q}", headers=H), timeout=120).read()
                    open(a.out, "wb").write(data)
                    print("saved", a.out, len(data))
                    return
        if node.get("status", {}).get("status_str") == "error":
            sys.exit("error: " + json.dumps(node["status"])[:400])
    sys.exit("timed out")


if __name__ == "__main__":
    main()
