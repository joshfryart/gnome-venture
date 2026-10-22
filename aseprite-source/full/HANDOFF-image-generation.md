# Handoff: generate the remaining Gnome Venture images (Aseprite)

You are picking up the image-generation phase. Specs are written; your job is to draw the assets, check them, fix duplicates, and report. Do not re-do the spec phase.

## What this project is
Redrawing every SVG in the Gnome Venture repo (`game/assets/img`) as pixel art in the "Stitched Toy" Aseprite style, driven by Aseprite's CLI (`"C:\Program Files\Aseprite\Aseprite.exe" -b --script x.lua`, v1.3.18) and a shared Lua library. Output mirrors the repo layout so PNGs can be dropped into `game/assets/img` (game code must then point at `.png` instead of `.svg`).

## Hard rules from the user
- **Opus draws the art; Sonnet does support work** (specs, file handling, checks, sheets). The user judged Sonnet's busts "horrible" and prefers Opus. Do not draw with Sonnet or Haiku.
- **Every asset must be visually unique.** An earlier batch reused one template for several similar assets (3 feast dishes, 3 region guides, 2 seed packets). Never recolour one layout. Similar families get one agent per asset or mixed groups.
- No 8x preview files, no scratch files shared between agents (give each agent its own scratch folder if it needs one).
- Check the 20-concurrent-subagent cap (workflows run about 16 at once).
- Quote or monitor cost; the user cares about token spend.
- The user deleted the old `style-iterations*`, `recreated-*` folders on purpose. Do not restore them.

## Where everything is (all under `C:\Users\hello\OneDrive\Desktop\claude\asperite\gnome-venture\`)
| What | Path |
|---|---|
| Style guide (Part D + "Part D addenda" are the rules) | `art-style-guide.md` |
| Shared Lua library, README, brief, example | `gvlib\gvlib.lua`, `gvlib\README.md`, `gvlib\brief.md` |
| Work-list: 143 shard files, 678 groups | `full\shards\shard-001.json` ... `shard-143.json` |
| Specs written by Sonnet (one per asset) | `img-redraw-full\specs\<folder>\<name>.md` |
| Drawing instructions for the artists | `full\draw-instructions.md` |
| Output (create as needed) | `img-redraw-full\png\`, `aseprite\`, `scripts\` mirroring `<folder>\<name>` |
| Originals (SVG, subject reference only) | `C:\Users\hello\AppData\Local\Temp\gv\game\assets\img\` (sparse clone of github.com/joshfryart/gnome-venture, private repo, `git` has stored credentials) |
| Earlier results for reference | `test100\` (100 assets), `img-redraw-hybrid\` (20), `img-redraw-pilot\` (Opus, 20), `img-redraw-pilot-sonnet\` (Sonnet, 20) |

## Shard format
Each shard file: `{"shard": N, "groups": [[asset, ...], ...]}` where an asset is `{"id": "<folder>/<name>", "viewBox": "...", "hint": "...optional..."}`. A **group** is the set of assets one Opus agent draws:
- `npc-*` busts and `creature-*` are single-asset groups (163 of them, extra care on faces and eyes).
- Everything else is groups of 3 assets from DIFFERENT families (interleaved), so no agent draws look-alikes.
- `*-seed` assets carry a `hint` assigning a distinct container (packet, pouch, jar, tin, sack, envelope, crate, cone, pot, bundle).

## Step 0: confirm the spec phase is finished (it was: all 1,706 specs verified present)
```
python - <<'E'
import json,glob,os
need=[a['id'] for f in sorted(glob.glob(r'C:\Users\hello\OneDrive\Desktop\claude\asperite\gnome-venture\full\shards\shard-*.json'))
      for g in json.load(open(f))['groups'] for a in g]
root=r'C:\Users\hello\OneDrive\Desktop\claude\asperite\gnome-venture\img-redraw-full\specs'
miss=[i for i in need if not os.path.exists(os.path.join(root,i+'.md'))]
print(len(need),'assets,',len(miss),'specs missing'); print(miss[:20])
E
```
If specs are ever missing, re-run only those (see `full\spec-instructions.md`, Sonnet, `model: 'sonnet'`) before drawing.

## Step 1: draw (Opus), STAGED (the user asked for a staged run)
Run as a Workflow (the user approved a workflow for this job). The script takes `args.shardList` (shard numbers to draw) and `args.groupCounts` (number of groups in each of the 143 shards, 1-indexed by shard; 13 shards of 12, one of 8, 128 of 4, one of 2; compute with `len(json.load(open(f))["groups"])` if in doubt).

**Stage A, trial (about 48 assets, 32 agents): DONE. Result: 0 failed, ~1.77M tokens, no near-duplicates, contact sheet `compare-stageA.html` is waiting for the user's verdict (do not run Stage B until he approves).** Original plan: `shardList: [1, 13, 30, 90]` = shard 1 (12 creatures), shard 13 (12 npc busts), shards 30 and 90 (mixed items). Then STOP: build a contact sheet (original next to redraw) and show it to the user. Only continue after the user approves the look. If the user wants changes, adjust `gvlibrief.md` (or the spec instructions), redo the trial assets, and repeat.

**Stage B, the rest (about 630 agents):** `shardList` = every shard number except 1, 13, 30, 90. Run only after the user approves Stage A.

```js
export const meta = {
  name: 'draw-assets',
  description: 'Opus draws each group of the listed shards in Aseprite via gvlib',
  phases: [{ title: 'Draw', detail: 'one Opus agent per group', model: 'opus' }],
}
const ROOT = 'C:\Users\hello\OneDrive\Desktop\claude\asperite\gnome-venture\full'
const pad = (n) => String(n).padStart(3, '0')
const jobs = []
args.shardList.forEach((n) => { for (let g = 0; g < args.groupCounts[n - 1]; g++) jobs.push({ n, g }) })
const outs = await parallel(jobs.map((j) => () =>
  agent(`Follow ${ROOT}\draw-instructions.md. Your assets are the list in group index ${j.g} (0-based) of "groups" in the shard file ${ROOT}\shards\shard-${pad(j.n)}.json. Draw exactly those assets, nothing else.`,
    { label: `draw:${pad(j.n)}.${j.g}`, phase: 'Draw', model: 'opus' })))
const lines = outs.filter(Boolean).join('
').split('
')
const failed = lines.filter((l) => l.includes('FAILED'))
log(`done lines: ${lines.filter((l) => l.includes(': done')).length}, failed: ${failed.length}, empty groups: ${outs.filter((o) => !o).length}`)
return { failed, emptyGroups: outs.filter((o) => !o).length }
```
Agent total stays under the 1,000-per-workflow cap in each stage. Expected cost: about 21K Opus tokens per asset (50-70K per agent), roughly $0.10-0.16 per asset, so $170-270 for the whole job. Re-running a failed workflow with `resumeFromRunId` reuses completed agents.

## Step 2: verify
1. Count PNGs vs the work-list; list any missing. Re-run those groups (single-asset agents).
2. **Duplicate scan.** Compare scripts for near-copies (templating). From the 100-asset test, ratio > 0.80 caught every template pair:
```
python - <<'E'
import os,re,json,difflib,itertools,glob
root=r'C:\Users\hello\OneDrive\Desktop\claude\asperite\gnome-venture\img-redraw-full\scripts'
files=[os.path.join(d,f) for d,_,fs in os.walk(root) for f in fs if f.endswith('.lua')]
def norm(p):
    t=open(p,encoding='utf8').read(); t=re.sub(r'--.*','',t); t=re.sub(r'#[0-9a-fA-F]{6}','#C',t)
    return [l.strip() for l in t.splitlines() if l.strip()]
S={p:norm(p) for p in files}
# compare within the same family prefix to keep it fast
import collections
fam=collections.defaultdict(list)
for p in S:
    n=os.path.basename(p)[:-4]; k=re.split(r'[-_]',n)[0]
    fam[k].append(p)
for k,ps in fam.items():
    for a,b in itertools.combinations(ps,2):
        if abs(len(S[a])-len(S[b]))>6: continue
        r=difflib.SequenceMatcher(None,S[a],S[b],autojunk=False).ratio()
        if r>0.80: print(round(r,2),a,b)
E
```
   Also compare pixel counts from each agent's `GV.report` line: identical `opaque=` plus identical bbox for look-alike assets is a red flag.
3. **Redo flagged assets** as single-asset Opus agents with an explicit unique concept (what the container/silhouette/composition is) and the instruction "do not read sibling scripts". Overwrite the same output paths. Examples that worked: iron pot with pods vs lattice pie vs laid table; round medallion vs shield badge vs open book.
4. Assets with `margin=0` are fine for full-bleed scenes, banners, tiles and busts (busts bleed off the bottom).
5. View a sample of each family on a contact sheet (HTML: original SVG next to the redraw, `image-rendering:pixelated`). `gnome-venture\compare-test100.html` is a template.

## Step 3: report to the user
Counts (drawn, failed, redone), actual token use and cost estimate, list of anything weak. Offer: copy `img-redraw-full\png` to the repo layout, convert references from `.svg` to `.png`, hand-fix individual assets.

## Not covered by this job
- 14 non-SVG files in `game/assets/img`: `apple-touch-icon.png`, `icon-32.png`, `icon-192.png`, `icon-512.png`, 7 animated GIFs in `puzzles/`, one JPG, `ph/palette.json`. Never touch `palette.json`.
- `chest.svg` at the img root (not in the shards): draw it as a single asset (spec it first), output `img-redraw-full\png\chest.png`.
- Already done elsewhere: the 20 pilot assets (`img-redraw-hybrid\`) and the 100 test assets (`test100\`); copy their PNGs into the final tree rather than redrawing.

## Known gaps in the style guide (from the pilots)
Part D only defines gloss/bounce/rim colours for red, dusk and gold; the "Part D addenda" gives a hue-shift recipe for other colours. Busts, scenes and large canvases are handled by the addenda (halo rules, draw at half size and write 2x for canvases wider than about 100 px). If an agent invents a palette step, that is expected.
