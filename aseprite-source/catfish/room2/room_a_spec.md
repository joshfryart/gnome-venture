# Cat Fish room A "warm cottage": 480 x 270 perspective spec

Part D + E scene rules: **240 x 135 grid, exported 2x nearest**. Numbers are **export px** (even). Alpha 0/255, no gradient/dither, no `#000000`/`#ffffff`, no black border, umber outline on raised objects only, light upper left, crescent lower right.

## 1. Depth model (art and code)
- `y = 268 - 158*d^0.8` (d=0 front, d=1 wall base y 110); `x = 240 + (u-.5)*720*(1-.45d)`; `s = 1-.58d`
- Inverse: `d = ((268-y)/158)^1.25`, `u = .5 + (x-240)/(720(1-.45d))`

| d | .1 | .2 | .3 | .4 | .5 | .6 | .7 | .8 | .9 | 1 |
|---|---|---|---|---|---|---|---|---|---|---|
| y | 244 | 224 | 208 | 192 | 178 | 164 | 150 | 136 | 122 | 110 |
| s | .94 | .88 | .83 | .77 | .71 | .65 | .59 | .54 | .48 | .42 |

Cat range u .2..8, d .05..9; scale snaps to 1/16 steps, pixelated.

## 2. Shell
- **Vanishing point (240,-83)**. Board lines straight to it; the d^0.8 model deviates <= 9 px at u=0, 0 at u=.5 (sprites follow the model).
- Back wall x 42..437, rows 0..109. Slivers: left (0,0)(41,0)(41,109)(0,151); right (438,0)(479,0)(479,151)(438,109). Inner corners 2 px `#dcbc88`.
- Back wall rows: crown 0..5 (`#b07a45` x4, `#8a4f2a` x2); wallpaper 6..77; dado 78..81 (`#d9a660` x2, `#b07a45`, `#8a4f2a`); wainscot 82..99 `#9a6b3f`, 2 px `#8a4f2a` grooves at x 42+44n; skirting 100..109 (`#d9a660` x2, `#b07a45` x6, `#74462a` x2).
- Wallpaper: back haze `#e9d9b0`, stripe `#e8cc98` where `(x-42) mod 16 < 6`. Left wall `#f2dfb6`, stripes x 0..3, 12..15, 22..25, 30..33, 36..37. Right wall (shade) `#e8cc98`/`#dcbc88`, mirrored. Side skirting: 10 px band above the corner line.
- **Floor** rows 110..269, 18 boards. Seams u=(k+.5)/18, k 0..17: `x_k(y) = (-100+40k) + (153-18k)(268-y)/158` (40 px apart at front, 22 at back). Corners (42,110)-(0,151), (438,110)-(479,151).
- Boards alternate `#c78d52`/`#b07a45`. Seams `#8a4f2a` for y >= 178, `#9a6b3f` above. Butt joints on board k at d = .15+.3j+.1(k mod 3), j 0..2, d<.95. Rows 110..115 soil-800 `#5a3a1e`.
- Wand hook (240,6..10) on the crown. **Calm zone** x 192..292, y 6..80: wallpaper only.

## 3. Back-wall furniture (in P1, d=1)
| Item | Box x, y | Notes |
|---|---|---|
| Doorway | frame 48..105, 24..109; opening 54..99, 32..109 | jambs `#b07a45`, rim `#d9a660`; hall wall `#c9a96e`, hall floor `#5a3a1e` rows 98..109 |
| Low bookshelf | 116..187, 64..109 | shelves y 80, 94; books 6..8 x 12..14 `#dd3a2a #4a8a3e #3f8fb0 #e8a317`; pet shelf-a 118..137, shelf-b 166..185, y 40..63 |
| Frame | 140..163, 22..51 | `#b07a45`, mat `#f2e4c0`; = pet slot "frame" |
| Window | frame 296..395, 18..83; glass 304..387, 26..77 | mullion x 344..347, transom y 50..53, sill 292..399, 84..89 |
| Bird slot | (356,58) 24x20 | feet on rail y 77 |
| Plant | pot 404..427, 90..109; leaves to y 50 | `#c8643c`; `#7ab55c #4a8a3e #2f5a2a` |
| Sconce | left wall 16..25, 44..59 | lit at night only |

## 4. Plates (480 x 270, alpha 0/255)
| Plate | File | Content | Max colours |
|---|---|---|---|
| P0 | `cf-room-a-p0.png` | glass only: `#c8e8f4` 26..37, `#a9d6ea` 38..63, hills `#8cc064` 64..71, `#5f9e48` 72..77, cloud `#f1ece0` | 5 |
| P0n | `cf-room-a-p0n.png` | `#291d4a`/`#3e2f66`, moon 8x8 `#f2e4c0` at (318,34), 3 stars | 4 |
| P1 | `cf-room-a-p1.png` | walls + §3; glass alpha 0 | 20 |
| P2 | `cf-room-a-p2.png` | floor | 8 |
| P3 | one per item, §5 | sprites | 16 each |
| P4 | `cf-room-a-p4.png` 488 x 270 at x -4 | foreground | 4 |
| P5 | `cf-room-sunbeam.png` | §7 | 8 |
| P5b | `cf-room-a-p5b.png` | §8 | 8 |

Base composite (P0..P2 + cushion + plain bowl) <= 32.

## 5. P3 sprites (anchor = feet bottom-centre; sort by anchor y, furniture before cats on ties)
| File | Upgrade | u, d | Anchor | w x h |
|---|---|---|---|---|
| `cf-room-a-cushion` | base | .24, .12 | (64,240) | 80x30 |
| `cf-room-a-bowl` | base | .76, .10 | (418,244) | 36x14 |
| `cf-room-bowl` | bowl | .76, .10 | (418,244) | 44x18, covers plain |
| `cf-room-rug` | rug | .30..70, .08..44 | (240,248) | quad (101,247)(379,247)(356,186)(124,186), 4 px steps; always under cats |
| `cf-room-toybox` | toybox | .20, .82 | (104,132) | 44x34 |
| `cf-room-cattree` | cattree | .86, .55 | (434,170) | 52x112 |
| `cf-room-scratch` | scratch | .12, .45 | (22,184) | 28x76 |
| `cf-room-catflap` | catflap | wall | (240,109) | 24x22 |
| `cf-room-window` (+`-nobird`) | window | wall | bird slot; sill pots 300..392, 76..83 | robin 24x20 |
| `cf-room-yarnpatch` + ball | base | .36, .32 | (154,204) | patch 40x20 at (134,186), ball 18x18 at (145,187) |
| `cf-room-sunbeam` | sunbeam | .50..72, .48..78 | P5 | §7 |

**Shadow** `#4a2c1a` at 35% = 1-bit mask, pre-blended at build into solids (snap to palette if every channel within 12): on `#c78d52` → `#9a6b3f`, on `#b07a45` → `#8c5f36`, on `#9a6b3f` → `#7e5532`. Ellipse 0.8 x sprite width, 4 px tall. Cats use `cf-shadow-mask.png` with CSS opacity .35 (the only translucency).

## 6. P4 foreground (parallax 3 px, range 2..4)
- Chair legs: plate x 4..11 and 28..35, rows 196..269, stretcher 232..237; `#5e2f1e`, 2 px `#74462a` left rim.
- Hearth-rug fringe: x 300..487, rows 262..269, tufts 4 on / 2 off, `#5e2f1e`/`#4a2c1a`.
- Shift ±3 px opposite the active cat's side; none under reduced motion.

## 7. P5 light (remap, not paint)
- Sunbeam from the window; layered **above P2, below P3 and cats**, clear of every P3 footprint.
- Floor quad (277,138)(343,138)(330,180)(240,180), 4 px mullion/transom bars left unlit. Wall shaft: wainscot under the sill, x 304..387.
- Outer 4 px = UP1, inner = UP2. UP1: `#c78d52→#d9a660`, `#b07a45→#c78d52`, `#9a6b3f→#b07a45`, `#8a4f2a→#9a6b3f`, `#e9d9b0→#f2dfb6`; UP2 adds `#d9a660→#ecc58a`, `#f2dfb6→#f8e8c4`.
- **Vignette baked** into P1/P2/P4: `e = ((x-240)/240)^2 + ((y-135)/135)^2`; e>1.15 DOWN1, e>1.45 DOWN2 (`#c78d52→#b07a45→#9a6b3f`, `#e9d9b0→#e8cc98→#dcbc88`, `#f2dfb6→#e9d9b0`).

## 8. Dusk / night
- Code tint: solid `#291d4a`, opacity .22 dusk, .40 night; P0 → P0n; sunbeam hidden.
- P5b above the tint: flame 4x6 `#ffc27a`/`#f5cf6a`, left-wall cone x 0..41, y 28..100: inner 6 px UP1, next 6 px base tones. Floor not relit.

## 9. Build approach (recommended)
Direct pixel drawing for plates, gvlib parts for furniture, one script `room2/cf_room_a.lua`:
- `GV.canvas{ w=240, h=135, mode="scene", out=2 }` per plate (P4 w=244). Local helpers: `persp(u,d)`, scanline `poly()`, Bresenham `line()`, `remap(mask, map)` (sun, vignette, shadows).
- Each P3 item: own scene canvas via `c:build{}` (outline, crescent, rim), blitted into a transparent 240x135 plate at anchor/2.
- Writes `room2/out_a/` and `room-layout-a.json` (constants, anchors, slots, bird, yarn, calm zone).
- Code follow-up: `catfish_room_base_html` hardcodes 320x200 and has no depth sort.

## 10. Acceptance
1. Sizes exact; alpha 0/255; `GV.check` semi=0, bw=0; caps of §4.
2. Each `x_k` at y 110 and 268 within ±2 px; corners hit (0,151)/(479,151).
3. Test card: 64 px cat at u .2/.5/.8 x d .1/.5/.9 has feet on boards, reads right at 100% and 50%.
4. P5/P5b masks share no pixel with any P3 footprint or the rug.
5. P0 visible only through glass; bird sits on the rail.
6. Coat `#3e2f66` separates from every floor tone and the rug.
7. Calm zone wallpaper only.

## 11. Build order
1. Helpers, layout JSON, seam test card. 2. P2, then P1 shell. 3. §3 furniture, P0, P0n. 4. Cushion, plain bowl, yarn patch. 5. Upgrades: rug, bowl, toybox, cattree, scratch, catflap, window. 6. P5 sunbeam, baked vignette. 7. P4, P5b. 8. Shadows, checks, review.
