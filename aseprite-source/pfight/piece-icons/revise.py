"""Show GLM its own icon + the existing type icon as character grids, ask for a fixed version."""
import json, sys, urllib.request
from PIL import Image
MODEL = sys.argv[1] if len(sys.argv) > 1 else "glm-5.3-flash:cloud"
CH = {(0x2a,0x1a,0x10):"#",(0xf2,0xe4,0xc0):"c",(0xe8,0xa3,0x17):"g",(0xd5,0x5e,0x00):"H",(0x00,0x72,0xb2):"G",(0x00,0x9e,0x73):"L",(0xf0,0xe4,0x42):"T"}
def grid(path):
    im = Image.open(path).convert("RGBA"); out = []
    for y in range(32):
        out.append("".join("." if im.getpixel((x,y))[3] < 128 else CH.get(im.getpixel((x,y))[:3], "?") for x in range(32)))
    return "\n".join(out)
LEG = "Legend: . transparent, # ink(outline), c cream, g gold, H hurt-orange, G guard-blue, L heal-green, T trick-yellow."
SYS = """You are fixing your own 32x32 pixel icon. You see: (1) the existing game icon for this piece TYPE (reference style), (2) your icon rendered as a grid.
Critique it briefly, then output a FIXED icon. Fix: a clean 1px ink (#2a1a10) outline around the main shape; one clear motif for the NAME on THAT animal; a small type cue in a corner (hurt = claw slashes, guard = shield, heal = heart, trick = mask) like the reference; no loose scattered dots; shapes touching and readable at 32px.
Reply with ONE JSON object only: {"key":"","critique":"one sentence","motif":"2-5 words","parts":[{"shape":"rect|line|circle|tri","x":0,"y":0,"w":0,"h":0,"color":"#hex"}]}
6-20 parts, integer coords 0-31, rect/circle/tri fill the box (tri apex top-centre), line runs (x,y)->(x+w,y+h). Colors only: ink #2a1a10, cream #f2e4c0, gold #e8a317, plus the type accent (hurt #d55e00, guard #0072b2, heal #009e73, trick #f0e442). Draw back to front."""
meta = {l.split("|")[0]: l.split("|") for l in open("input.txt", encoding="utf8").read().splitlines() if l}
PAL = {"#2a1a10","#f2e4c0","#e8a317","#d55e00","#0072b2","#009e73","#f0e442"}
from concurrent.futures import ThreadPoolExecutor
def work(line):
    o = json.loads(line); key = o["key"]; f = meta[key]; typ = f[2]; r = None; err = ""
    prompt = (f"{'|'.join(f)}\n\nREFERENCE existing {typ} icon:\n{grid(f'ico-{typ}.png')}\n\nYOUR icon (motif: {o['motif']}):\n{grid(f'out_v1/ico-{key}.png')}\n{LEG}")
    err = ""
    for a in range(3):
        body = {"model": MODEL, "system": SYS, "prompt": prompt + (f"\nPrevious try failed: {err}" if err else ""), "stream": False, "format": "json", "think": True, "options": {"temperature": 0.6, "num_predict": 16000}}
        try:
            r = json.loads(json.load(urllib.request.urlopen(urllib.request.Request("http://localhost:11434/api/generate", json.dumps(body).encode(), {"Content-Type": "application/json"}), timeout=600))["response"])
            r["key"] = key; ps = r["parts"]; assert 6 <= len(ps) <= 20, f"{len(ps)} parts"
            for p in ps:
                assert p["shape"] in ("rect","line","circle","tri"), "bad shape"
                assert str(p["color"]).lower() in PAL, "off-palette " + str(p["color"])
                for k in "xy": p[k] = max(0, min(31, round(p[k])))
                for k in "wh": p[k] = round(p[k])
                if p["shape"] != "line": p["w"] = max(1, min(32-p["x"], p["w"])); p["h"] = max(1, min(32-p["y"], p["h"]))
                else: p["w"] = max(-p["x"], min(31-p["x"], p["w"])); p["h"] = max(-p["y"], min(31-p["y"], p["h"]))
            break
        except Exception as e:
            err = str(e); r = None
    if r: print("fixed", key, "|", r.get("critique"), flush=True); return json.dumps(r, separators=(",",":"))
    print("kept v1", key, err, flush=True); return line.strip()
lines = [l for l in open("icons_v1.jsonl", encoding="utf8") if l.strip()]
with ThreadPoolExecutor(4) as ex: ok = list(ex.map(work, lines))
open("icons.jsonl", "w", encoding="utf8").write("\n".join(ok) + "\n")
