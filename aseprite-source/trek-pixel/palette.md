# Trek pixel palette (shared by all 46 trek tile assets)

One palette for open and underground. Every colour is a backticked hex (check.py reads this file and warns on any opaque pixel not listed here). Names are used in all specs. Never use `#000000` or `#ffffff`.

Sources: `TK_P` in `includes/trek_art.php` (22 game colours, kept verbatim), Part D ramp recipe (gloss toward yellow-orange +35% lighter, shade toward red-violet -22%, deep -45%, bounce = shade warmed, rim = gloss -10%), and the `brief.md` family rows (moss, wood, water, gold, skin, red, dusk, stone).

## 1. Game colours (TK_P, verbatim)
| name | hex | game use |
|---|---|---|
| soil900 | `#3d2a1c` | bed gaps, mud dots, deepest soil |
| soil700 | `#7a4a1f` | mud, roots (underground), rails, clay |
| soil500 | `#9a6b3f` | floor bed, dark plank, wall-u outer |
| soil300 | `#c9a96e` | light plank, wall-u inner, clay dots |
| moss600 | `#4f9a45` | tufts |
| moss800 | `#2f5a2a` | wall moss patches, caps |
| gold700 | `#b07a10` | gold token ring |
| gold500 | `#e8a317` | crystal inner, player ring |
| gold300 | `#f5cf6a` | crystal, footprints, thread |
| ember700 | `#a8241f` | ember deep |
| ember500 | `#d6322b` | ember token ring |
| ember400 | `#e0501f` | thorn dots, clay sheen |
| ember300 | `#f08a24` | ember light |
| water700 | `#25637d` | pool outer |
| water500 | `#3f8fb0` | pool inner |
| water300 | `#a9d6ea` | ripples |
| dusk700 | `#4e3a8a` | blight floor |
| dusk500 | `#7a5cc0` | blight dots |
| stone700 | `#5b6470` | wall-o outer / mortar |
| stone500 | `#8b8f96` | wall-o inner |
| ink | `#2b2b2b` | specks, cracks (use sparingly) |
| cream | `#f4f0e0` | token disc, player disc |

## 2. Outline, thread and shadow
| name | hex | use |
|---|---|---|
| umber1 | `#74462a` | outline, lit side (top, left) |
| umber2 | `#4a2c1a` | outline, middle (also ground shadow of the player) |
| umber3 | `#2a1a10` | outline, shaded side (bottom, right) |
| thread | `#f5cf6a` | gold thread stitch, 2 on / 1 off, ONLY at joins |
| thread2 | `#e8a317` | thread on shaded pixels |
| thread_hole | `#8a4a1c` | button holes |

## 3. Four-step ramps (plus rim and bounce)
Order in each row: gloss, rim, base, bounce, shade, deep. "base" is the ring colour of ground tiles that use the ramp.
| family | gloss | rim | base | bounce | shade | deep | notes |
|---|---|---|---|---|---|---|---|
| so (open soil) | `#d9ba7c` | `#c9a96e` | `#9a6b3f` | `#8b5a31` | `#7a4a1f` | `#3d2a1c` | base = soil500. floor-o ring |
| su (underground warm soil) | `#b88850` | `#a06c3c` | `#8a5a30` | `#6e4426` | `#5c3520` | `#33221a` | base = floor-u ring |
| mud (shared open/underground) | `#9a6b3f` | `#8b5a31` | `#7a4a1f` | `#6e4426` | `#5c3520` | `#3d2a1c` | base = soil700. mud-o, mud-u, drained, loose-clay ring |
| or (open roots) | `#b9c58a` | `#a2b076` | `#7d8a62` | `#6f7b56` | `#5f6c4a` | `#3a4530` | stone500 greened toward moss |
| ur (underground roots) | `#8a8a5c` | `#6e6e48` | `#4a4632` | `#403e2c` | `#38352a` | `#272219` | |
| mo (moss) | `#c8d77a` | `#a4b86a` | `#7ab55c` | `#6a9a3a` | `#4a8a3e` | `#2f5a2a` | tufts also use moss600 |
| sn (stone, wall-o) | `#c9c5bc` | `#b3b2b0` | `#8b8f96` | `#7a7f8a` | `#5b6470` | `#3c4252` | base = stone500, shade = stone700 |
| wl (clay rock, wall-u) | `#e6cf98` | `#d9bd84` | `#c9a96e` | `#b08a55` | `#9a6b3f` | `#7a4a1f` | base = soil300, shade = soil500 |
| du (blight) | `#a894dc` | `#7b66b4` | `#4e3a8a` | `#463780` | `#3e2f66` | `#291d4a` | blight-o ring = base, blight-u ring = shade. accent dusk500 |
| wa (water) | `#c8ecdc` | `#a9d6ea` | `#3f8fb0` | `#2f7fa0` | `#25637d` | `#1c3a5e` | pool outer = shade, inner = base, ripples gloss/rim |
| ch (chasm) | `#2d6479` | `#24556b` | `#143645` | `#112f3d` | `#0e2433` | `#091623` | water700 darkened, no black |
| cl (wet clay) | `#c0662c` | `#a85a28` | `#944c1f` | `#84451f` | `#6a3820` | `#3d2a1c` | soil700 plus ember sheen. loose clay uses mud + `#3d2a1c` cracks + soil300 crumbs |
| wd (wood, planks and rails) | `#ecc58a` | `#d9a660` | `#b07a45` | `#a8582f` | `#8a4f2a` | `#5e2f1e` | |
| gd (gold, crystal, tokens) | `#fff1c8` | `#f5cf6a` | `#e8a317` | `#d0862a` | `#b8661a` | `#7a3a14` | |
| rd (red, ember, hat) | `#ff9158` | `#f2793a` | `#dd3a2a` | `#b8452f` | `#ae2a2a` | `#6b1b2c` | gloss dot `#ffc27a` |
| skin | `#ffe2a8` | `#f9d49c` | `#e9b98a` | `#d9885a` | `#c47a52` | `#8a4234` | |
| cr (cream, pale) | `#fff3c8` | `#f5b860` | `#f4f0e0` | `#e2d6b8` | `#cfc3a2` | `#a89a78` | base = cream. no pure white dot anywhere |
| lav (limbs) | | `#7b66b4` | `#54447f` | | | | lit top `#7b66b4` |

Ramp names in specs: `so_base`, `wa_shade`, `gd_gloss`, and so on. `soil500` etc. means the game colour of section 1.

## 4. Terrain ring colours (outer 3 px of every ground tile = exactly this colour)
| tile family | ring |
|---|---|
| trek-floor-o-*, trek-crystal-o | `#9a6b3f` (so_base) |
| trek-mud-o-*, trek-mud-u, trek-drained, trek-clay-loose | `#7a4a1f` (mud_base) |
| trek-roots-o-* | `#7d8a62` (or_base) |
| trek-blight-o-* | `#4e3a8a` (du_base) |
| trek-floor-u-*, trek-crystal-u | `#8a5a30` (su_base) |
| trek-roots-u | `#4a4632` (ur_base) |
| trek-blight-u | `#3e2f66` (du_shade) |
| trek-chasm-* | `#143645` (ch_base) |
| trek-clay-wet | `#944c1f` (cl_base) |
| wall-o-auto empty side apron | `#9a6b3f` (= floor-o ring) |
| wall-u-auto empty side apron | `#8a5a30` (= floor-u ring) |
| water-auto empty side apron | `#7a4a1f` (= mud ring) |

## 5. Rules for using the palette
- 6 steps per ramp are available, but one asset normally uses 8 to 14 colours in total. check.py warns above 16.
- Shade goes lower-right only and only on objects inside the tile (stones, planks, crystal, markers). A ground tile has NO crescent: its texture is lit/flat with 1 px accents.
- Lit pixel = gloss or rim at upper-left, 1 px. Never a gradient, never a dither.
- Umber outlines only on raised objects (crystal, planks, rails, stones/pebbles, wall masses, markers). Ground, water and clay textures have no outline.
- No halo, no cream border, no black border.
