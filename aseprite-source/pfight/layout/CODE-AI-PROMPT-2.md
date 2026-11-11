# Prompt for the code AI: fold in the new Puzzle Combat art (round 2 + groups 2/3)

Repo `joshfryart/gnome-venture`, branch `ccr-dea0abf9-eaakqa`. All art is in `game/assets/img/pfight/` (root) and `game/assets/img/pfight/parts/`. You own PHP/JS/CSS; I only deliver PNGs. Every file is optional: a missing file keeps today's emoji/CSS, never break the screen. Hard pixels: draw with `image-rendering: pixelated`, integer scales only (1x, 2x; never 1.5x).

Specs: `game/assets/img/pfight/parts/README.md` (kit), `parts/marks/marks.json` (marks and anchors), `game/assets/img/pfight/README.md` (file list).

## 1. Marks on pieces (`parts/marks/`)
Draw over the composed piece, top-left at the anchor, 1x. Anchors are in PIECE IMAGE coords (origin = image top-left, tabs included).
| | tag | upgrade | rarity |
|---|---|---|---|
| strip piece 74x52 | (13,32) | (49,32) | (51,7) |
| hand piece 132x92 | (24,64) | (96,64) | (98,18) |
- **Tag** = `tag-<key>.png` 12x12, key = `PF_TAGS` key: quick heavy pierce poison trip bash hold thorns evade mend hum lull bond pluck. Show when the tile has a tag.
- **Upgrade** = `mod-<key>.png` 12x12, key = `PF_MODS` key: sticky swift hardy tender leech spiky soft warm finisher lucky steady. Show when the tile has a mod (`m`).
- **Rarity** = `rarity-<0|1|2>.png` 10x12, from `PF_MODS[mod][3]` (0 common, 1 uncommon, 2 rare): gem shape + 1/2/3 pips. Show only with an upgrade (it grades the upgrade). `rarity-gem-N.png` 7x7 = gem only, if you need a small version.
- Tag = cream rounded square, upgrade = gold hexagon: different shapes, never colour-only. Do not tint.
- In the popover / inspect card draw marks at exactly 2x.
- Foe pieces: bottom marks may sit over a few thorns; that is fine, draw them.

## 2. "Choose an upgrade" popover
- Header art `popover-header.png` 96x96 (medallion, three hexagons). Title banner rect at (7,73) size 82x15, empty cream: print the title in ink (#2a1a10).
- Per-type name header (tile popover): `parts/marks/pop-header-<type>.png` 24x16, 9-slice, slice 9 px left and right, stretch the middle horizontally, print the name in ink on the cream middle. Types: hurt guard heal charm soothe trick item.

## 3. Variant icons (replace the type icon when the tile has a specific kind)
`ico-<name>.png` 32x32 (hand / popover) and `ico-<name>-s.png` 20x20 (strip piece). Names: jab pierce sting trip bash smash (Hurt), brace roll thornhide mending (Guard), hum lull (Soothe), bond (Charm), pluck (Trick). Same look as `ico-<type>.png`. Use the variant icon when the tile's key matches the name, else fall back to `ico-<type>`. The piece-render kit (`parts/icons-<size>.png`) still has only the 7 base icons; for variant icons draw the PNG at the icon offset (strip (30,19) 20x20, hand (55,25) 32x32) over the composed piece instead of the base icon. Tell me if you want them baked into the atlas.

## 4. Combo stamps (Group 3)
`combo-<name>.png` 32x32, shown when a combo fires and on the Almanac page. Map by combo name: Ambush -> `combo-ambush`, Riposte -> `combo-riposte`, Double Swing -> `combo-double-swing`, Calm Charm -> `combo-calm-charm`, Win Over -> `combo-win-over`, Bait -> `combo-bait`. Each has its own outline shape (diamond, shield, burst, cloud, heart, tag). The small flat combo badges `parts/combo-badge-small|big.png` (24x14, number plate (6,3) 12x8) stay for chain length 2-3 / 4+.

## 5. Moments
- End card when a creature is charmed: `end-charmed-<small|medium|large|boss>.png` 64x64 by creature size class (small/medium/large; boss for a boss creature). `ico-gift.png` 24x24 for gift/loot rows.
- Pop FX: `fx-hit|guard|heal|charm.png`, 128x32 = 4 frames of 32x32 (frame i at x = i*32), play once at about 10 fps, centred on the target, then remove. Fade with CSS opacity if you want; the art itself is not faded.

## 6. Boss
- Boss creature pieces: use the `boss` palette in `parts/rim.json` (roles RIM_FOE, BAND_FOE, STITCH_FOE, THORN_TIP, THORN_BODY; gold ring, violet band/thorns), AND draw `crown-boss.png` 12x12 over the piece's top-left corner: strip piece at (2,0), hand piece at (6,0) (piece image coords). It sits on the corner, clear of the number plate, sockets, tag, upgrade and rarity marks. The crown is the second cue, never colour alone.

## 7. Open-socket marker
`open-end.png` 24x24 (gold ring + inward arrow) for an open socket if you want an art marker. The piece-shaped ghost outline rule (built in code from the candidate piece alpha) is still the main target indicator; see `parts/README.md`.

## Please confirm
1. Do you want the variant icons baked into the parts atlas (so a piece = base + stamps + icon from one sheet), or drawn on top as in section 3?
2. Which tile keys map to which variant icon (I assumed key = icon name)?
3. Any combo or tag key that has no art here? Tell me and I will draw it.
