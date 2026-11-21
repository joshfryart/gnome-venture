"""Build creature-piece input lines and ask Ollama for one icon design each.
usage: python gen_icons.py [limit] [model]     -> input.txt, icons.jsonl, rejects.txt"""
import json, sys, re, urllib.request
LIMIT = int(sys.argv[1]) if len(sys.argv) > 1 else 5
MODEL = sys.argv[2] if len(sys.argv) > 2 else "qwen3.5:4b"
ACCENT = {"hurt": "#d55e00", "guard": "#0072b2", "heal": "#009e73", "trick": "#f0e442"}
PAL = {"#2a1a10", "#f2e4c0", "#e8a317"} | set(ACCENT.values())
SYS = """You design 32x32 pixel icons. You get one line: key|piece name|type|tag|creature name|creature description.
Design ONE unique icon showing what the piece NAME means for THAT animal (e.g. "Spade-Claw Dig" on a badger = a digging claw with dirt flecks, not a generic claw).
Reply with ONE JSON object only: {"key":"","motif":"","parts":[{"shape":"","x":0,"y":0,"w":0,"h":0,"color":"#hex"}]}
- motif: 2-5 words describing the picture
- parts: 6-20 filled shapes, shape is rect, line, circle or tri; coords 0-31 integers. rect/circle/tri fill the box x,y,w,h (tri: apex top-centre). line runs from (x,y) to (x+w,y+h).
- colors ONLY: ink #2a1a10, cream #f2e4c0, gold #e8a317, plus the type accent: hurt #d55e00, guard #0072b2, heal #009e73, trick #f0e442
- hard pixels, 1px ink outline, no anti-aliasing
- the type must read without colour: keep a small type cue in a corner (hurt = claw slashes, guard = shield, heal = heart, trick = mask)
- draw parts back to front."""

def rows(f): return [l.rstrip("\n").split("|") for l in open(f, encoding="utf8") if l.strip() and not l.startswith("#")]
cre = {r[0]: (r[1], r[6]) for r in rows("creatures.txt")}
lines = []
for r in rows("pf_creature_pieces.txt"):
    slug, name, typ, tag = r[0], r[2], r[3], r[6]
    if typ not in ACCENT or slug not in cre: continue
    key = f"{slug}-" + re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")
    lines.append((key, f"{key}|{name}|{typ}|{tag}|{cre[slug][0]}|{cre[slug][1]}", typ))
lines = lines[:LIMIT]
open("input.txt", "w", encoding="utf8").write("\n".join(l for _, l, _ in lines) + "\n")

def check(o, key, typ):
    if not isinstance(o, dict) or not isinstance(o.get("parts"), list): return "no parts"
    if not 6 <= len(o["parts"]) <= 20: return f"{len(o['parts'])} parts"
    for p in o["parts"]:
        if p.get("shape") not in ("rect", "line", "circle", "tri"): return "bad shape"
        if not all(isinstance(p.get(k), (int, float)) for k in "xywh"): return "bad coords"
        for k in "xy": p[k] = max(0, min(31, round(p[k])))
        for k in "wh": p[k] = round(p[k])
        if p["shape"] != "line":
            p["w"] = max(1, min(32 - p["x"], p["w"])); p["h"] = max(1, min(32 - p["y"], p["h"]))
        else:
            p["w"] = max(-p["x"], min(31 - p["x"], p["w"])); p["h"] = max(-p["y"], min(31 - p["y"], p["h"]))
        if str(p.get("color", "")).lower() not in PAL: return "off-palette " + str(p.get("color"))
    return None

import threading
from concurrent.futures import ThreadPoolExecutor
lock = threading.Lock(); seen = set()
def work(item):
    key, text, typ = item; err = ""; o = None
    for attempt in range(3):
        body = {"model": MODEL, "system": SYS, "prompt": text + (" Previous try failed: " + err if attempt else ""), "stream": False, "format": "json",
                "think": False, "options": {"temperature": 0.7 + 0.1 * attempt, "num_predict": 4000}}
        req = urllib.request.Request("http://localhost:11434/api/generate", json.dumps(body).encode(), {"Content-Type": "application/json"})
        try:
            o = json.loads(json.load(urllib.request.urlopen(req, timeout=600))["response"]); o["key"] = key
            err = check(o, key, typ)
            if not err:
                sig = json.dumps(o["parts"])
                with lock:
                    if sig in seen: err = "duplicate parts"
                    else: seen.add(sig)
        except Exception as e:
            err = f"error {e}"
        if not err: break
    print("REJECT" if err else "ok", key, err or o.get("motif"), flush=True)
    return key, (None if err else json.dumps(o, separators=(",", ":"))), err
with ThreadPoolExecutor(4) as ex: res = list(ex.map(work, lines))
ok = [j for _, j, _ in res if j]; bad = [f"{k}\t{e}" for k, j, e in res if not j]
open("icons.jsonl", "w", encoding="utf8").write("\n".join(ok) + "\n")
open("rejects.txt", "w", encoding="utf8").write("\n".join(bad) + "\n")
print(f"{len(ok)} ok, {len(bad)} rejected")
