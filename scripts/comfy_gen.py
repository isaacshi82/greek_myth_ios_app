#!/usr/bin/env python3
"""Drive a remote ComfyUI instance over its HTTP API: queue a workflow, wait for
it to finish, and download the resulting image — no browser/screenshots needed.

Why the odd headers: RunPod sits behind Cloudflare (which blocks the default
`Python-urllib` User-Agent) and ComfyUI does a host/origin check on POSTs. So
every request sends a browser User-Agent + an Origin matching the host.

Usage:
  COMFY_URL=https://<pod>-8188.proxy.runpod.net \
  python3 scripts/comfy_gen.py --prompt "a young Zeus with lightning" --out /tmp/zeus.png \
      [--width 1024 --height 1024 --steps 4 --cfg 1.0 --ckpt flux1-schnell-fp8.safetensors]

For anything beyond a basic text2image graph (IPAdapter, ControlNet, regional
prompting), pass a full API-format workflow JSON with --graph <file.json>; any
{"__PROMPT__"} / {"__SEED__"} placeholders in it are substituted.
"""
import argparse, json, os, random, sys, time, urllib.parse, urllib.request

UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0 Safari/537.36"


def _headers(base, json_body=False):
    h = {"User-Agent": UA, "Origin": base, "Referer": base + "/"}
    if json_body:
        h["Content-Type"] = "application/json"
    return h


def post(base, path, data):
    req = urllib.request.Request(base + path, data=json.dumps(data).encode(),
                                 headers=_headers(base, json_body=True))
    return json.load(urllib.request.urlopen(req, timeout=60))


def get(base, path):
    req = urllib.request.Request(base + path, headers=_headers(base))
    return json.load(urllib.request.urlopen(req, timeout=60))


def download(base, img, out_path):
    q = urllib.parse.urlencode({"filename": img["filename"],
                                "subfolder": img.get("subfolder", ""),
                                "type": img.get("type", "output")})
    req = urllib.request.Request(f"{base}/view?{q}", headers=_headers(base))
    data = urllib.request.urlopen(req, timeout=120).read()
    with open(out_path, "wb") as f:
        f.write(data)
    return len(data)


def basic_graph(a, seed):
    """Minimal Flux text2image graph (all-in-one fp8 checkpoint)."""
    return {
        "4": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": a.ckpt}},
        "6": {"class_type": "CLIPTextEncode", "inputs": {"clip": ["4", 1], "text": a.prompt}},
        "7": {"class_type": "CLIPTextEncode", "inputs": {"clip": ["4", 1], "text": ""}},
        "5": {"class_type": "EmptySD3LatentImage", "inputs": {"width": a.width, "height": a.height, "batch_size": 1}},
        "3": {"class_type": "KSampler", "inputs": {
            "model": ["4", 0], "positive": ["6", 0], "negative": ["7", 0], "latent_image": ["5", 0],
            "seed": seed, "steps": a.steps, "cfg": a.cfg, "sampler_name": a.sampler,
            "scheduler": a.scheduler, "denoise": 1.0}},
        "8": {"class_type": "VAEDecode", "inputs": {"samples": ["3", 0], "vae": ["4", 2]}},
        "9": {"class_type": "SaveImage", "inputs": {"images": ["8", 0], "filename_prefix": "api"}},
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--prompt", default="")
    ap.add_argument("--out", required=True)
    ap.add_argument("--graph", help="full API-format workflow JSON (overrides the basic graph)")
    ap.add_argument("--ckpt", default="flux1-schnell-fp8.safetensors")
    ap.add_argument("--width", type=int, default=1024)
    ap.add_argument("--height", type=int, default=1024)
    ap.add_argument("--steps", type=int, default=4)
    ap.add_argument("--cfg", type=float, default=1.0)
    ap.add_argument("--sampler", default="euler")
    ap.add_argument("--scheduler", default="simple")
    ap.add_argument("--seed", type=int, default=None)
    ap.add_argument("--base", default=os.environ.get("COMFY_URL"))
    a = ap.parse_args()
    if not a.base:
        sys.exit("Set COMFY_URL or pass --base (e.g. https://<pod>-8188.proxy.runpod.net)")
    a.base = a.base.rstrip("/")
    seed = a.seed if a.seed is not None else random.randint(0, 2**31)

    if a.graph:
        graph = json.loads(open(a.graph).read().replace("__PROMPT__", a.prompt).replace('"__SEED__"', str(seed)))
    else:
        graph = basic_graph(a, seed)

    pid = post(a.base, "/prompt", {"prompt": graph})["prompt_id"]
    print(f"queued {pid} (seed {seed})")
    for _ in range(180):
        time.sleep(2)
        hist = get(a.base, f"/history/{pid}")
        node = hist.get(pid, {})
        if node.get("outputs"):
            for o in node["outputs"].values():
                for img in o.get("images", []):
                    n = download(a.base, img, a.out)
                    print(f"saved {a.out} ({n} bytes)")
                    return
        if node.get("status", {}).get("status_str") == "error":
            sys.exit(f"generation error: {json.dumps(node['status'])[:400]}")
    sys.exit("timed out waiting for image")


if __name__ == "__main__":
    main()
