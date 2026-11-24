# Cat Fish room 2: lure, rod cast, shadow, zoomies (art spec)

Part D / `gvlib/brief.md` rules apply: umber outline `#74462a`/`#4a2c1a`/`#2a1a10`, 1 px `#000000` border on stickers only, alpha 0/255, house hexes only. Coordinates: canvas px, top-left origin. Scripts `cf_props.lua`, `cf_zoom80.lua` (from `cf_run80.lua`); output `out_props/`, `out_zoom/`.

## 1. Lure: plush feather-mouse
Red felt mouse facing right, blue feather tail up-left, gold string loop on the back. Body `#dd3a2a`/gloss `#ff9158`/shade `#b8452f` (bottom 2 rows near, 1 mid/far); feather `#8fcbd8`/`#3f8fb0`/`#2f6290`, `#f5cf6a` quill; ear `#e9b98a` + PINK `#e8909e`; nose PINK; eye `#2a1a10`; loop `#f5cf6a`/`#e8a317`.

| size | canvas/ol | body ellipse | nose tri | ear circle | feather line, w | eye | string anchor | felt floor row |
|---|---|---|---|---|---|---|---|---|
| near | 32x32 / 2 | (14,19) 8x6 | (20,15)(26,20)(20,24) | (17,13) r3, pink 2x2 | (8,17)(6,10)(7,5), 4→2 | 3x3 cream disc (20,16), 2x2 pupil | (13,10) on 3x3 ring | 25 |
| mid | 20x20 / 1 | (9,12) 5x4 | (13,9)(16,12)(13,15) | (11,7) r2, pink 1 px | (5,10)(4,4), 3→2 | 2x2 at (13,10) | (9,5) | 15 |
| far | 12x12 / 1 | grid | | | | | (7,3) | 8 |

Near only: gold belly seam row 24, x 9..19 (2 on, 1 off); gloss 2x1 at (11,15).

Far: `K` border, `o` `#4a2c1a`, `r g s` body, `b w` feather, `y` gold, `e` eye, `p` pink.
```
............
..K....K....
.KoK..KoK...
KowoKKoyoK..
KoboooryoK..
KobogrrroK..
.KorrrrreoK.
.KorrrrrrpoK
.KossssssoK.
..KooooooK..
...KKKKKK...
............
```

Files `cf-lure-{near,mid,far}-1..6.png`: 1-4 land tumble, 5-6 idle wobble. Pivot: centre column, border bottom (y 28/17/10). Offsets below are near; mid x0.6, far x0.4, min 1 px.

| F | ms | pose |
|---|---|---|
| 1 impact | 60 | squash rx +1 ry -1, 1 px lower; feather tip -2 x |
| 2 hop | 80 | up 4, parts rotated -30° (nose up) |
| 3 tumble | 80 | up 2, +20° (nose down); ear 1 px back |
| 4 settle | 100 | rest; feather tip +1 x |
| 5 wobble A | 300 | rest |
| 6 wobble B | 300 | body+ear 1 px right, feather tip 1 px left |

Rotate part polygons, then rasterise (no rotsprite). Checks: far reads "red mouse + blue feather" at 1x; anchor pixel gold every frame; felt never below the floor row; margins hold.

## 2. Rod cast: toy wand from the top edge
48x64 like `cf-rod.png`, same parts and ramps, seen from above. Pivot P (24,-6) off-canvas; shaft P→tip T. Parts back from T:
- Cap: gold disc r3 at T (`#f5cf6a`/`#e8a317`/`#b8661a`, 1 px `#fff1c8` gloss), two `#8a4a1c` button holes.
- Sleeve T-3..T-13, width 9, water `#8fcbd8`/`#3f8fb0`/`#305e86`, gloss stripe on left edge.
- Shaft T-13..T-40, width 5, wood `#d9a660`/`#b07a45`/`#8a4f2a`.
- Grip T-40 to top edge, width 8, red `#f2793a`/`#dd3a2a`/`#ac1c27`, 2 px gold stitch band at T-44.

Outline 2 px; black border everywhere except row 0 (wand continues off-screen).

| `cf-wand-cast-N` | T | cap r |
|---|---|---|
| 1 rest | (24,52) | 3 |
| 2 windup (lifted, foreshortened) | (24,40) | 4 |
| 3 flick left | (10,47) | 3 |
| 4 flick centre | (24,56) | 3 |
| 5 flick right | (38,47) | 3 |
| 6 settle (overshoot) | (25,54) | 3 |

String anchor (T.x, T.y+3) per frame goes in `cf-wand-cast.json`; string in code; fish stay `cf-fish-1..5`. Timing: 1 > 2 (120 ms) > 3/4/5 by direction (110 ms) > 6 (290 ms) > 1. Checks: palette ⊆ `cf-rod.png`; shaft width constant on diagonals; cap inside x 4..43; reads as the same toy as `cf-rod.png` at 1x.

## 3. Shadow
Solid hard-pixel ellipses, `#2a1a10` alpha 255, no dither, outline or border; game draws at `globalAlpha .35`, centred under the paw line.

| file | scale | canvas | ellipse | centred row widths |
|---|---|---|---|---|
| cf-shadow-1.png | 1 | 48x12 | 44x10 | 20 32 38 42 44 44 42 38 32 20 |
| cf-shadow-2.png | .75 | 36x10 | 34x8 | 16 26 32 34 34 32 26 16 |
| cf-shadow-3.png | .5 | 24x8 | 22x6 | 12 20 22 22 20 12 |
| cf-shadow-4.png | .42 | 20x6 | 18x4 | 12 18 18 12 |

Checks: 2 colours; 1 px clear margin; mirror-symmetric; never scaled in game (nearest rung).

## 4. Zoomies (80x64, faces right, grey template)
Parts, paint order, ramps, IK and widths as the 12-frame run (`run80_fixes.md`), except:
- Capsule width 13 (was 15); BX 33; `S=(front-5,BY+4)`, `H=(rear+5,BY+3)`, `hx=S.x+9`; skull ry 8.5, haunch ry 6, chest ry 5.5.
- Ears pinned flat, no pink: near tri (hx-2,hy-9)(hx-7,hy-7)(hx-13,hy-10); far tri (hx+1,hy-9)(hx-3,hy-9)(hx-9,hy-12).
- Tail straight back: R (rear+6,BY-5), offsets (0,0)(-3,0)(-6,-1)(-8,-1)(-10,-1) + dy, width 5/3, tip x ≥ 9.

Planted paw y 53; 50 ms frames; 10 px/frame at 1x, plants slide -10.

| F | key | BY | L | arch | tilt | hx,hy | tail dy P2/3/4 |
|---|---|---|---|---|---|---|---|
| Z1 | crouch-launch (once) | 43 | 32 | -2 | 0 | 53,35 | +1/+2/+2 |
| Z2 | hind push | 40 | 38 | 0 | -3 | 56,31 | 0/+1/+1 |
| Z3 | full flight, all paws out | 38 | 40 | 0 | 0 | 57,30 | -1/-1/-2 |
| Z4 | fore contact | 40 | 38 | 0 | +3 | 56,31 | 0/0/0 |
| Z5 | gathered, hind contact | 39 | 30 | -3 | 0 | 52,30 | +1/+1/+2 |
| Z6 | skid at edge (once) | 41 | 34 | -1 | -4 | 55,31 | tail up: offsets (0,0)(-3,-2)(-5,-5)(-6,-9)(-5,-12) |

Paws (hind: hock / paw; **bold** = planted):

| F | nf | ff | nh | fh |
|---|---|---|---|---|
| Z1 | **52,53** | **49,53** | 19,50 / **22,53** | 21,49 / **25,53** |
| Z2 | 58,48 | 54,49 | 18,49 / **16,53** | 21,49 / **20,53** |
| Z3 | 67,45 | 63,46 | 15,46 / 11,47 | 17,45 / 14,46 |
| Z4 | **61,53** | **57,53** | 21,46 / 18,48 | 23,45 / 21,47 |
| Z5 | 46,49 | 43,48 | 27,50 / **26,53** | 30,50 / **30,53** |
| Z6 | **65,53** | **61,53** | 24,50 / **24,53** | 27,50 / **28,53** |

Play Z1 (80 ms) > loop Z2-Z5 > Z6 (120 ms) at the edge > game mirrors. Files `cf-cat-grey-zoom01..06.png` + `cf-ears-mask-zoom0N`, `cf-tail-mask-zoom0N` for recolour/overlays.

Checks: at 0.5x Z3 shows four separate paws and daylight under a long flat body; ears never above the skull line; tail ≤ 3 px above R (not Z6); felt in x 6..72, y 6..56; joint steps ≤ 12 px (streaks cover them); ≤ 16 colours, `t.semi == 0`, `t.margin >= 3`.

### Effects (behind the cat; umber outline, no black border)
Legend: `o` `#74462a`, `c` `#f1ece0`, `h` `#fff3c8`, `s` `#c9a96e`.

**Dust** `cf-fx-dust-1..4.png`, 24x16, 60 ms; pivot (19,14) on the planted paw; spawn on Z1, Z2, Z4, Z5, doubled on Z6 fore paws.
```
F1                        F2                        F3                        F4
........................  ........................  ........................  ........................
........................  ........................  ........................  ........................
........................  ........................  ........................  ........................
........................  ........................  ........................  .........oooo...........
........................  ........................  ............oooo........  ........ohhhho..........
........................  ........................  ...........ohhhho.......  ....oo..occcco..........
........................  ........................  ......ooooohccccho......  ...ohho.occcco..........
........................  ..............oooo......  .....ohhhhhcccccco......  ..ohcchoosssso..oo......
........................  .............ohhhho.....  ....ohcccccccccccco.....  ..occcso.oooo..ohho.....
........................  ........ooooohccccho....  ..oohccccccccccccco.....  ...osso........osso.....
...............oooo.....  .......ohhhhhcccccco....  .ohhcccccccsccccccco....  .oosoo..........oo......
...........oooohhhho....  .....oohccccccccccco....  .occcsccccsosssscccho...  .ooo.........oo.........
...........ohhhcccco....  ....ohhsccccssccccso....  .osssosssso.oooosccso...  ............osso........
...........ossssssso....  ....ossossssoosssso.....  ..ooo.oooo......osso....  .............oo.........
...........oooooooo.....  .....oo.oooo..oooo......  .................oo.....  ........................
........................  ........................  ........................  ........................
```

**Streaks** `cf-fx-streak-1..3.png`, 40x8, head end right; code puts 2-3 left of the cat in the body band, 3 frames each.
```
streak-1 (long)                          streak-2 (double)                        streak-3 (dashes)
........................................ ........................................ ........................................
........................................ ..................hhhhhhhhhhhhhhhhcco... ........................................
..............................hhhhhh.... ........................cccccccccccco... .........hhhhhhcco......hhhhhhhhhhhhcco.
....hhhhhhhhhhhhhhhhhhhhhhhhhhccccccco.. ..........................oooooooooo.... ...........cccccco.........ccccccccccco.
..........ccccccccccccccccccccccccccco.. ..hhhhhhhhhhhhcco....................... ............oooooo...........oooooooooo.
..............ooooooooooooooooooooooo... ......cccccccccco....................... ........................................
........................................ ........oooooooo........................ ........................................
........................................ ........................................ ........................................
```
Checks: 4 legend colours only; PNGs match grids pixel for pixel; never over the cat's face.
