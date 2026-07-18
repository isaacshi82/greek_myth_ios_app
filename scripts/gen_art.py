#!/usr/bin/env python3
"""Generate an illustration with the Gemini image API and (optionally) import it
into the app's asset catalog via add-asset.sh.

Reads the API key from the GEMINI_API_KEY environment variable — the key is
never stored in this file or committed.

Usage:
  GEMINI_API_KEY=... python3 scripts/gen_art.py \
      --prompt "A flat red circle on white" \
      --out /tmp/out.png \
      [--ref path/to/reference1.png --ref path/to/reference2.png] \
      [--name titan-oceanus --type characters]   # imports via add-asset.sh

If --name is given, the saved PNG is passed to ./add-asset.sh <out> <name> <type>.
Reference images (--ref) are sent alongside the prompt so the model keeps a
character consistent — the whole point of our "reference sheet first" workflow.
"""
import argparse, base64, json, mimetypes, os, subprocess, sys, urllib.request

DEFAULT_MODEL = "gemini-2.5-flash-image"
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--prompt", required=True)
    ap.add_argument("--out", required=True, help="where to save the PNG")
    ap.add_argument("--ref", action="append", default=[], help="reference image(s) for consistency")
    ap.add_argument("--name", help="asset name; if set, imports via add-asset.sh")
    ap.add_argument("--type", default="characters", help="add-asset.sh type (characters|scenes)")
    ap.add_argument("--aspect", help="aspect ratio, e.g. 16:9, 4:3, 1:1")
    ap.add_argument("--model", default=DEFAULT_MODEL, help="image model (e.g. gemini-2.5-flash-image, gemini-3-pro-image)")
    ap.add_argument("--size", help="image resolution for pro models: 1K, 2K, or 4K")
    args = ap.parse_args()

    key = os.environ.get("GEMINI_API_KEY")
    if not key:
        sys.exit("GEMINI_API_KEY is not set")

    parts = [{"text": args.prompt}]
    for ref in args.ref:
        mime = mimetypes.guess_type(ref)[0] or "image/png"
        with open(ref, "rb") as f:
            parts.append({"inlineData": {"mimeType": mime, "data": base64.b64encode(f.read()).decode()}})

    payload = {"contents": [{"parts": parts}]}
    image_config = {}
    if args.aspect:
        image_config["aspectRatio"] = args.aspect
    if args.size:
        image_config["imageSize"] = args.size
    if image_config:
        payload["generationConfig"] = {"imageConfig": image_config}
    body = json.dumps(payload).encode()
    endpoint = f"https://generativelanguage.googleapis.com/v1beta/models/{args.model}:generateContent"
    req = urllib.request.Request(
        endpoint, data=body,
        headers={"x-goog-api-key": key, "Content-Type": "application/json"},
        method="POST",
    )
    try:
        resp = json.load(urllib.request.urlopen(req, timeout=180))
    except urllib.error.HTTPError as e:
        sys.exit(f"HTTP {e.code}: {e.read().decode()[:400]}")

    for cand in resp.get("candidates", []):
        for p in cand.get("content", {}).get("parts", []):
            if "inlineData" in p:
                with open(args.out, "wb") as f:
                    f.write(base64.b64decode(p["inlineData"]["data"]))
                print(f"Saved {args.out} ({os.path.getsize(args.out)} bytes)")
                if args.name:
                    subprocess.run(["./add-asset.sh", args.out, args.name, args.type], cwd=REPO, check=True)
                return
    sys.exit(f"No image in response: {json.dumps(resp)[:400]}")


if __name__ == "__main__":
    main()
