# Proposal: per-piece animations (place, play, chain)

Status: PROPOSAL, nothing in the game changes. Branch `ccr-893d59b2-e35ovt`. Demo (throwaway, stand-in art, open in a browser): `claude/mockups/pf-piece-anim-demo.html` (single piece, 2-chain, L-shaped 3-chain on 4x4; `#t=3000` freezes the clock; checkboxes: reduced motion, perimeter path, resolve stand-in).
Pilot scope: aphid-swarm pieces (4) and the base player pieces (basic 7, knack 11 listed below). Whole game later: 1,276 creature pieces (todo 2.7.45; 353 unique rows in `pf_creature_pieces.txt`, the rest are shared class/region/size pieces) plus ~154 player pieces.

## 0. What the code does today (facts the plan hangs on)
- The board (`game/assets/pfboardv1.js`, built from `tools/pfboardv1_part.js` by `tools/build_pfboardv1.py`) is DOM, not one canvas: `render()` (l.1047) rebuilds a `.pfb-cell` per piece inside `.pfb-world`; each cell holds one `<canvas class="pfb-cv">` from `P.piece()` (pfparts47). Strip art: body 56x47, tab 13, piece image 82x73, pitch = body (`P.atlas.sizes.strip`; hand 96x80, tab 22, image 140x124). Board art size TW = VW*56+26, TH = VH*47+26; cells and overlays are positioned in % of that (`put`, `putBody`).
- `render()` re-creates every cell, so a CSS/WAAPI animation on a cell is lost on the next render. Anything that must outlive a render (effects) lives in a module with its own clock, drawn on ONE overlay canvas.
- Existing layers, z-index: `.pfb-glow` 2, `.pfb-joint` 3, `.pfb-stamp` 4, `.pfb-drop` 5 (400 ms, the only "place" anim, only for `revealId`), `.pfb-spawn` 6 (2.2 s, env/board piece), `.pfb-scoring` 8 (500 ms scale + gold drop-shadow = the resolve flash).
- Replay: `data.replay[]` events, each fired by one `setTimeout` at `tt += step`, `step = 950*RF/SPD` ms (RF = `replayScale()`, 0.1..1, whole replay <= 8.46 s at 1x). Event fields used: `id` (piece fired), `cs`+`rid` (opens a chain, `rid` = the placed piece, revealed via `hiddenIds`/`revealId`), `root`, `by`/`ta`, `strike`, `combo`, `ln`, `bar`/`hp`/`g`. `data.fx[]` = `{by, ids[]}` per chain of >= 2 pieces, `ids` in firing order (`pfb_fx`, pfboard.php l.2063). A single piece is a chain of 1 (not in `fx`; take it from the event). Pieces carry `p.e[L|R|T|B]` (edge = [knob/hole, family]; linked only if both sides are tabs, `joint()` l.1105), `p.t` type, `p.tag`, `p.ik` (creature icon key), `p.by` (me|foe|env|none), `p.v`, `p.x,p.y`.
- Stop/skip/rewind: `stopPlay(true)`, `SPD==0` (skip), `rewind`, `playTimers[]` cleared. Reduced motion is already honoured in CSS for drop/score/spawn.

## 1. Three layers and timing
All times at 1x. z-order (bottom to top): piece cell (z by DOM) < `.pfb-glow` 2 < `.pfb-joint` 3 < **FX canvas z 7 (new, the play and chain layers)** < `.pfb-scoring` cell 8 and every resolve effect (numbers, chips, bars, hp). Effects draw 2-5 px OUTSIDE the body edge (outward normal), so the scoring glow of the cell is never covered and never covers them badly.

**Layer P, place** (on the piece's own cell; CSS class `pfb-place` replaces `pfb-drop` for the revealed piece; 470 ms; uses `transform` only, so it is cheap):
| ms | phase | piece | shadow (under, stippled) | extra |
|---|---|---|---|---|
| 0-180 | raise | scale .90 -> 1.10 (ease-out), y 0 -> -3 px, opacity 0 -> 1 in 60 ms | offset grows 0 -> (3,5) px | "lifted from the table" |
| 180-230 | click | scale 1.10 -> .97, y -3 -> +1 | collapses to 0 | at 230: one 50 ms bright outline frame (impact) |
| 230-470 | wiggle | rotate +-2.6 deg, 2.5 damped swings, x +-1.2 px, scale .97 -> 1 | none | settles to rest |
| 230-400 | sound lines | 3-6 short strokes, 2 px, grow 6 -> 12 px and vanish (last 40 ms stipple) | - | style per piece: click (4 corner dashes), pop (arc of 6 lines), tink (3 small crosses), zig (buzz zigzags), thud (2 low lines + dust) |
Sound lines are a burst sprite on the FX canvas (4 frames x 40 ms), colour from the piece's family. No audio. The wiggle never moves the hit area (the cell box does not move; only the inner canvas transforms).
Who gets it: every piece that appears during a replay (yours, the creature's, `p.fnew`), at its reveal step (`revealId`), also env pieces in a plainer variant (`raise`+`click`, no wiggle). Not on first load, history rewind, or `hiddenIds` re-renders.

**Layer F, play (own)**: starts at the piece's own fire event (the `setTimeout` at `tt`), runs 650 ms along that piece's own perimeter edges (its "runs", section 2). Shape of the effect = its family (section 3).
**Layer C, chain**: at fire +250 ms a carrier (comet of 8 squares, family colour) leaves this piece's anchor and travels 450 ms along the chain's outer perimeter to the NEXT piece in firing order (ids order from `fx`). Last piece sends nothing. Optional chain finish (+ the whole chain pulses once, 300 ms, gold) when the chain is >= V1.limit (the "used up" chain).
Non-blocking rule: the replay clock is untouched. `PFAnim.fire()` is called inside the existing `setTimeout` and returns at once; no event waits for an animation, no `tt` changes, no extra timer in `playTimers` that gates anything. Durations scale `k = clamp(step/950, .3, 1)` (step already includes SPD), so a squeezed replay shortens effects but they may overlap into the next step (up to 1.5 steps) and keep running through `useUpStep`, banners and the resolve step. At `stopPlay`, skip (`SPD==0`), `rewind`, new `render()` from a different step: `PFAnim.cancel()` drops everything at once (no fast-forward needed: nothing is state). Reduced motion (`prefers-reduced-motion`, checked at fire time): place = 120 ms fade only; play = a 260 ms 2 px outline flash on the piece; no chain carrier, no sound lines, no sprites.

## 2. Edge-following algorithm (chain cells -> perimeter path)
Input per chain: cells `[{x,y,i}]` in firing order (i = firing index) + per-side tab info `e`. Only cells of the chain (not every adjacent piece) join the union. Output: closed polylines in ART pixels (same space as `put()`, so the canvas is just `TW x TH` and scales with the board by CSS, pixelated).
1. Directed boundary edges, clockwise (y down): for each cell, each side whose neighbour is NOT in the chain set emits an edge with the cell on its right: T: (x,y)->(x+1,y); R: (x+1,y)->(x+1,y+1); B: (x+1,y+1)->(x,y+1); L: (x,y+1)->(x,y). Each edge keeps `owner` (firing index) and `side`.
2. Index edges by start vertex. Trace a loop: from an unused edge follow the edge starting at its end vertex; if two candidates (diagonal touch, a pinch point) take the one with the largest clockwise cross product (sharpest right turn), which keeps the loop hugging its own cells. Repeat until all edges are used. Loops are signed by area: positive = outer boundary, negative = hole (a ring of 8 around an empty cell, a U closing round a gap). Chains are edge-connected by construction (linked joints), so normally 1 outer loop (+ holes); diagonal-only contact makes a separate loop, fine.
3. Rotate each loop so the first and last edge have different owners (no run is cut at the loop start).
4. Expand edges to pixels: vertex (u,v) -> (PAD + u*56, PAD + v*47) in body space (+ tab 13 offset as in `put`). Insert knob geometry on edges that are tabs but NOT linked: a free knob adds a trapezoid bump outward (depth 10 px, base 18, top 12 at the side centre), a free hole a notch inward (depth 8). Linked joints are on seams, not in the perimeter. So the path follows what you see: the outline of the whole jigsaw.
5. Cumulative arc length `cum[]` (Float32Array) per loop; `at(s)` = binary search + lerp -> `{x,y,nx,ny}` (outward normal). Total cost O(edges); a chain has <= ~12 cells, so < 100 points. Computed once per chain when it first fires, cached by key `sorted ids + positions + tab flags`.
6. Per owner: `runs` = list of `[s0,s1]` arc intervals of its own boundary edges (the middle piece of an I has two runs, a corner of an L one, a 2x2 piece two touching ones); `anchor` = midpoint of its longest run.
7. Order along the path: the carrier from piece i to the next fired piece j moves from `anchor[i]` to `anchor[j]` by the shorter arc (tie: clockwise). Firing order may jump (Quick first, Heavy last): the carrier still never crosses the interior. The own effect of piece i is drawn on its runs only, so the user sees each piece light its own edge, then the effect run to the next.
8. Optional inner seams: for each LINKED joint between consecutive pieces (`joint()` true) a 2-point polyline across the shared side with the knob centre as midpoint. Used by `hop` families (web strand, shock arc, ripple) that must cross from piece to piece instead of going round: effect = draw along `seam(i,i+1)` at the same 450 ms carrier time. Default is the perimeter; `hop` is a per-family flag.
Shapes to unit test (node, no DOM): single, I (3), L, T, S/Z, 2x2, U with notch, ring of 8 (hole loop), diagonal pair, same chain translated (path identical up to offset). The demo implements steps 1-6 (`perimeter()`).

## 3. Data-driven design
Family = a template (draw function + sprites + defaults), chosen per piece by a lookup, never by code per piece.
Resolution order for piece `p`: `pf_piece_fx.txt` row for `p.key` (handmade special) > creature class flavour (`class` rule, e.g. critter `Swarm` -> `buzz` for its hurt pieces) > `TAG[p.tag]` > `TYPE[p.t]`. New data file `game/includes/data/pf_piece_fx.txt` (`key|family|variant|colour|sound|hop`), read by a tiny loader that adds `fx:{f,v,c,s,h}` to each piece in the state the page already receives (page data only; the engine, the JS/PHP twins and saves are untouched). Colour defaults come from the owner (me = cream/gold, foe = hurt-red/ink) mixed with the type colour; per-creature accent from its class lean (body red, mind purple, craft gold).
Families (13 for the pilot): `slash` (hurt: white streak along the edge), `shock` (quick/jab: 2 zig lines + spark), `thrust` (pierce: one long thin line through the edge), `shield` (guard: scrolling dashes + diamonds on corners; `hold` = slower, thicker), `roll` (evade: curl puffs low), `mend` (heal: plus sparkles drifting up), `sparkle` (charm/item: stars, hop), `veil` (trick: ripple that fades inward), `calm` (soothe: slow wave, hop), `buzz` (swarm: dots orbiting with wing flicker), `puff` (cloud: round puffs outward), `drip` (poison/honey: drops fall 14 px), `web` (strands between perimeter points, dew drops; hop; used later by spiders). Later: `bite`, `ember`, `leaf`, `thorn`, `trip`, `bash`, `hum`, `lull`, `bond`, `heavy`.

Pilot table (colour = family tone; sound line = place style):
| piece | type/tag | family | place variant | play effect | colour | sound |
|---|---|---|---|---|---|---|
| Swarm (aphid-swarm) | hurt/quick | buzz | quick: raise 140 ms | 7 dots orbit its edges, chain: dots scatter to next | #9bd05a, ink | zig |
| Honeydew | heal | mend (amber) | slow raise 220 ms | amber drops climb its edges, 4 plus sparkles | #e8a317 | pop |
| Cloud Up | guard/evade | puff | raise, soft click | grey-blue puffs bloom out of the edges | #dfe6ee | pop |
| Sap Sip | hurt/poison | drip | normal | green drops fall off the bottom edge, pool 1 frame | #7fd35a | pop |
| Swing | hurt | slash | normal | white streak runs round its edge | #fff3c8 | click |
| Dodge | guard | shield | normal | blue dashes scroll its edge, corner diamonds | #a9d6ea | tink |
| Rest | heal | mend | slow raise | green pluses rise | #5f9a4a | pop |
| Charm | charm | sparkle (hop) | normal | stars pop along edge and across seams | #f6b8cf | tink |
| Snack | item | sparkle | normal | crumb sparks | #c9a96e | pop |
| Hide | trick | veil | fast | edge ripples inward | #c3b2ea | thud |
| Breather | heal | mend | slow | 2 small pluses | #5f9a4a | pop |
| Jab | hurt/quick | shock | fast raise | two zig lines + spark at corner | #ffe27a | click |
| Pierce | hurt/pierce | thrust | normal | one thin line crossing the edge | #ffffff | click |
| Brace | guard/hold | shield (hold) | heavy: raise 100 ms, long wiggle off | thick slow dashes | #4f7fa8 | thud |
| Soothe | soothe | calm (hop) | slow | slow wave along seams | #3f8fb0 | tink |
Chain effect default = the carrier in the colour of the piece that just fired; if the chain mixes families the colours simply change hand to hand, which shows the order. Combo (Riposte etc.): the second piece of a combo pair gets its family effect plus a 2-frame gold edge ring (data: `ev.combo`). Teamwork (`planQ.tw`, if the event carries it) = a second sparkle pass; unverified, check the event fields in Phase 0.
Scaling to all pieces: 353 unique rows give ~20 distinct (type, tag) pairs (hurt/guard/heal/trick x -,pierce,poison,quick,trip,bash,hold,thorns,evade,heal). Phase 3 script `tools/pf_piece_fx_report.py` assigns family by the lookup and writes a coverage report; humans only write `pf_piece_fx.txt` rows for pieces whose art says more than their tag (web spiders, bite jaws, ember dragons, leaf plants): estimate 8-10% (~100-130 rows). Colour per piece = family tone, tinted by the creature class lean; no per-piece art unless a row names a custom sprite.

## 4. Aseprite pathway (no Aseprite binary in the cloud)
Two tiers so the pilot ships without art: (a) procedural: the effects are drawn by code as `fillRect` pixels (like the demo), always available; (b) sprite stamps from PNG strips override a family's stamp when present (`P.cico`-style lazy load; a missing strip silently falls back to (a)).
Layout: `aseprite-source/pfight/anim/` with `README.md`, `gen_anim.py` (PIL, writes every strip + JSON), `palette.json` (ink #2a1a10, cream #f2e4c0, gold #e8a317, family 3-tone ramps hi/base/shade from the art guide), `check.py` (hard pixels, palette only, frame counts), `<family>/stamp-<family>-<20|32>.png`, `<family>/stamp-<family>-<20|32>.json`, `burst/burst-<click|pop|tink|zig|thud>-<20|32>.png`, `src/*.aseprite` (hand-off, empty until Josh draws).
Sizes follow the icon pipeline (board strip = 20 px art, hand/detail = 32 px art): stamp frame 20x20 (board) and 32x32 (hand). Burst frame 24x24 (board) / 38x38 (hand); one corner burst is mirrored to 4 corners by code. Horizontal strips, one tag per animation, frame durations in the JSON (Aseprite `--format json-array` shape: `frames[]{frame{x,y,w,h},duration}`, `meta.frameTags[]{name,from,to}`), so the same loader reads files exported by Aseprite later.
Frame counts: stamp `spawn` 4, `loop` 4 (cycled by code), `end` 2 (stipple out); burst 4 frames x 40 ms. 13 families x 10 frames + 5 bursts x 4 = 150 frames per size. Tags: `spawn`, `loop`, `end` (stamps), `burst`. No alpha blends: fades are stipple frames (`end`), the same hard-pixel rule `v47/check.py` enforces. Names: `stamp-<family>[-<variant>]-<size>.png`.
Authoring without the binary: `gen_anim.py` draws the pixel grids from small ASCII/shape tables (as `gen_pieces.py` does) and writes PNG + JSON. Hand-off for Josh: `aseprite -b stamp-web-20.png --save-as src/stamp-web-20.aseprite` (the same one-liner as the icon README), he repaints frames in his tool, then `aseprite -b src/x.aseprite --sheet-type horizontal --sheet x.png --data x.json --format json-array --list-tags` overwrites the PNG/JSON; the generator never overwrites a file whose `.aseprite` is newer.
Build: `tools/build_piece_anim.py` (PIL only) packs strips into `game/assets/img/pfight/anim/anim-20.png`, `anim-32.png` and `anim.json` (name -> x,y,w,h,frames,dur,tags; one atlas per size = 2 requests, ~30-60 KB). Loaded after `P.ok` and only the families the current fight uses (aphid pieces + the player's deck), lazily; cached on the offscreen sheet; added to the art zip, not to the code zip (no version bump from this proposal).
Runtime budget (phones): one FX canvas of `TW x TH` (250x214 for 4x4; <= ~600x400 for the largest board) at devicePixelRatio 1, pixelated CSS scaling; max 3 active chains, 24 stamps per frame, 8 carrier squares per chain; stamps are `drawImage` from the atlas; `fillRect` for dots; no per-frame allocation (pre-sized Float32Array for the path, hash noise `sin`-based as in the demo, no particle objects); the loop runs only while something is active and sleeps with `visibilitychange`; the canvas is cleared by `clearRect` of the dirty bounding box. Target: < 1.5 ms scripting per frame on a 4x-throttled desktop (~ mid phone). Effects are pure functions of `(chain, t)`, so scrubbing/screenshots just call `PFAnim.seek(ms)`.

## 5. The three deliverable cases (timelines; ms from the reveal step, 1x)
**A. Single piece, Swarm (aphid-swarm).** Reveal step (creature turn, after its banner): 0 raise (grows 90 -> 110%, shadow opens) -> 180 click -> 230 impact frame + zig sound lines (buzz style) -> 230-470 wiggle -> 470 rest. Later, at its fire event T: T+0 `.pfb-scoring` (resolve) + `buzz` own effect starts on its 4 edges (7 dots orbit, 650 ms); no chain (nothing to carry); the dots outlive T+step into the next event's resolve.
**B. 2-chain, Dodge then Swing (Riposte).** Each piece has its own reveal (turn it was placed): raise/click/wiggle with `tink` (Dodge) and `click` (Swing). The chain fires on the placing turn: T: Dodge fires: shield dashes scroll along Dodge's top/bottom/left runs; T+250: blue carrier leaves Dodge's anchor and runs 450 ms along the perimeter (top edge of both, over the seam gap) to Swing's anchor; T+step: Swing fires: white streak runs Swing's own runs; resolve gold ring and "Riposte" combo chip on top; combo 2-frame gold edge ring. Perimeter = 6 edges (2x1 rectangle), the seam between them is never walked.
**C. 3-chain bent (L): Cloud Up (1,0), Swarm (1,1), Sap Sip (2,1).** Cells {(1,0),(1,1),(2,1)} -> union perimeter = 8 unit edges + free knob/hole bumps (Cloud Up top hole, Sap Sip right knob). Loop (clockwise) starts at Cloud Up's top-left; owner runs: Cloud Up 3 edges (left, top, right), Swarm 2 (left, bottom), Sap Sip 3 (bottom, right, top); the Cloud Up/Swarm and Swarm/Sap Sip seams are inside. Anchors at run midpoints. Order by firing: Cloud Up (guard first) -> Swarm -> Sap Sip. T: puff blooms along Cloud Up's three edges; T+250 carrier Cloud Up -> Swarm goes down the left side (short arc, 1.5 edges); T+step: Swarm buzzes its two edges; its carrier goes along the bottom, turns the inner corner of the L (concave: the path turns left, the carrier's normal flips with `at()`) to Sap Sip; T+2step: Sap Sip drips along bottom and right edges. All of it keeps running while resolve rings, damage numbers and the creature bar change; none of it moves a timer.
(Exact run lengths are produced by `perimeter()`; the L's concave corner at (2,1) is the pinch case the unit test pins.)

## 6. Risks
- `render()` rebuilds cells: place animation must be keyed to `revealId` only and the FX canvas re-attached after each render (`render()` makes a NEW `.pfb-world` at l.1046, so the canvas must be re-appended to it; PFAnim keeps the state, the canvas is cheap to recreate). Medium.
- Visual noise: every piece animating at once on a long chain plus resolve numbers. Mitigate: own effect <= 650 ms, small stamps, <= 3 chains, a Settings toggle "Piece effects: full / light / off" (reduced motion forces light).
- Replay budget: steps can shrink to 95 ms (RF .1); effects must still read: `k` clamp .3 and overlap.
- Art volume if all 1,276 pieces got custom sprites: refused by design; families + colour carry it.
- Twin parity (PHP/JS) is safe only if no event field is added; reading existing fields only. If a needed field (combo name, tw) is missing, add it to the page payload in `pfboard.php`'s view, never to `pfengine.js` state.
- Creature icons are 32/20 px art; effects at 2x zoom must stay pixel-aligned (canvas size = TW x TH, integer coordinates).
- Large boards (other agent's board sizes): path is size-independent, canvas grows with TW x TH; check the 600x400 case.

## 7. Open questions for Josh (max 6)
1. Should the ghost (planned, not yet played) piece get the raise-only lift when you drop it on a spot, or only the real placement at replay?
2. Sound lines are visual only: do you also want a (tiny, optional, default off) audio tick later?
3. Chain effect: perimeter carrier (default) or seam-hop for every family? Perimeter reads as "the chain's outline"; hop reads as "through the joints".
4. Foe pieces: same animations in their own colours, or a rougher variant (shorter raise, thud) so the creature feels heavier?
5. Settings: one "Piece effects" toggle (full/light/off) OK, or none?
6. Pilot approval: is `buzz` for Swarm, `drip` for Sap Sip, `puff` for Cloud Up, amber `mend` for Honeydew the right feel (web comes with spiders later)?

## 8. Phased plan and effort
| phase | work | effort |
|---|---|---|
| 0 | read check of event fields (combo, tw, root), `perimeter()` + node unit tests for 9 shapes, `pfanim.js` skeleton, overlay, cancel hooks | 0.5-1 d |
| 1 pilot | place anim (CSS, replaces `pfb-drop`), 13 procedural families, 4 aphid + 15 base rows, reduced motion, settings toggle | 2 d |
| 2 art | `gen_anim.py`, `check.py`, `build_piece_anim.py`, loader + fallback, hand-off README, screenshots for Josh | 1.5 d |
| 3 families | remaining ~10 families, tag/type tables, coverage report | 2 d |
| 4 all pieces | `pf_piece_fx.txt` special cases (~100-130 rows), class flavours, visual review sheets | 2-3 d |
Release: pilot ships with the next normal version bump (not part of this proposal); the art zip carries `anim/`.

## 9. Test plan
- Determinism: effects are functions of (replay event, chain cells, t); no `Math.random`, no `Date` inside draw (hash noise seeded by piece id + index). Unit test: `seek(t)` twice gives byte-identical canvas data for a fixed replay.
- No engine impact: `git diff` touches no `pfboard.php` engine/`tools/pfengine.js`; run the existing parity suite (`tests/` pf twin tests) and `tests/pfdeck_v1.php` lint, both unchanged and green; new `pf_piece_fx.txt` has its own lint (family exists, colour hex, key exists).
- Non-blocking: instrument `playTimers` count and step times before/after: identical `tt` sequence with effects on and off.
- Rewind/skip/fast-forward: scripted run: start replay, call `stopPlay(true)` at 300 ms, assert FX canvas empty and no rAF pending; rewind likewise; 2x speed shortens durations by `k`.
- Perimeter: node tests listed in section 2, plus a property test (random connected cell sets <= 8 cells: sum of edge lengths = 4*cells - 2*shared sides, loops closed, owners cover all exposed sides).
- Screenshots: headless Chrome at fixed `seek` times (place 100/230/300/450 ms; play 200/500; chain carrier mid-flight) for A, B, C, plus a 2x2 and a ring; compare to approved PNGs by eye (like `claude/mockups` sheets), phone width 360 px and 4x4 / largest board.
- Perf: Chrome CPU throttle 4x, 12-piece chain, record frame times (< 1.5 ms script); check memory flat over 50 replays.
- Reduced motion: emulate `prefers-reduced-motion`, assert no sound lines, no carrier, place = fade.

## Decisions (Josh, 2026-11-22)
- Chain effect: along the OUTER edge of the whole chain (not through joints).
- Creature pieces: a rougher, heavier variant set (harder slam, bigger wobble, darker effects), not just recoloured player animations. Needs a second variant per family.
- Setting: one "Piece effects" setting, Full / Light / Off (Light keeps the place wiggle, drops edge effects; Off follows reduced motion).
- Sound lines: visual only (no audio).
- Not asked, defaults assumed (change if wrong): a planned ghost piece gets no lift, only the real placement at replay does; pilot mapping as proposed (buzz Swarm, drip Sap Sip, puff Cloud Up, amber mend Honeydew).
