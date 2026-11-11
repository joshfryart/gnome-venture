# Puzzle combat: ART TODO

The fight card works with emoji and CSS borders now. Pixel art to replace them (same style as the existing ico/ set; files under game/assets/img/pfight/, all optional: a missing file keeps the emoji, so nothing breaks).

## Tile type icons, 24x24 px (ico/pfight-<type>.png)
hurt (swing/claw), guard (shield/leaf), heal (green heart/herb), charm (flower), soothe (calm face/dove), trick (mask/feather), item (snack/jar).

## Tile frames, 80x56 px, 9-slice friendly (pfight/tile-<type>.png)
One per type. Left edge has a HOLE (notch), right edge has a KNOB (bump). The knob and hole come in 3 shapes so fit reads without colour:
- Body: round knob / round hole
- Mind: keyhole knob / keyhole hole
- Craft: triangle knob / triangle hole
Flat edge variant for wild tiles (corner/edge pal pieces). Also a "picked" (raised) look and a "foe" tint.
Sheet idea: pfight/sockets.png, 3 shapes x (knob, hole) x 16x16 px, drawn over the frame ends.

## Strip and scene
- pfight/strip-bg.png: a stone/wood rail the played tiles sit on (tileable horizontally, 24 px high).
- Open-end marker: a glowing ring/arrow 24x24 (pfight/open-end.png).
- Foe intent icons: same 7 type icons, small (16x16) with a speech-bubble background (pfight/intent-bubble.png).
- Resolve bar: empty/full frame, 96x12 (pfight/bar-frame.png), with a heart-ish fill for Hurt side and a flower fill for Charm side.

## Combo stamps, 32x32 each (pfight/combo-<name>.png)
ambush, riposte, double-swing, calm-charm, win-over, bait. Used as a pop when a combo fires and on the Almanac pages.

## Outcome art
- "Charmed" end card: the creature with a flower (per size is enough: small/medium/large/boss), 64x64.
- Gift box icon, 24x24.

## Added: Hurt tile variants (needs art)
The Hurt type now has six tiles that play differently. Each needs its own 32x32 hand icon (and 20x20 strip icon) instead of the generic Hurt icon, plus a tiny 12x12 tag mark shown next to the name:
- Jab (quick: a fast light poke) / tag mark: lightning
- Pierce (ignores guard: a needle or thorn through a shield) / tag mark: pin
- Sting (poison: a bee/thorn with a drip) / tag mark: flask or drip
- Trip (creature plays a tile fewer: a rope or root across the path) / tag mark: knot
- Shield Bash (uses your guard: a shield swung at the foe) / tag mark: small shield
- Smash (heavy, last in chain: a mallet or boulder) / tag mark: rock
Names: `ico-hurt-<jab|pierce|sting|trip|bash|smash>.png`, `ico-hurt-<name>-s.png`, `tag-<quick|pierce|poison|trip|bash|heavy>.png`. They must stay distinguishable from each other in grayscale (different silhouettes).

## Added: defence, charm and stealing tiles, and Puzzle upgrades (needs art)
New tile icons (32x32 hand + 20x20 strip each, own silhouette in grayscale) and a 12x12 tag mark each:
- Guards: Brace (anchor/stump, tag: anchor), Roll (a tumbling gnome, tag: whoosh), Thorn Hide (a prickly shield, tag: cactus), Mending (a plaster/leaf bandage, tag: plaster)
- Charms: Hum (musical note, tag: note), Lull (a crescent moon, tag: moon), Bond (two hands or two sprouts, tag: handshake)
- Trick: Pluck (a pinching hand with a small item, tag: pinch)
Names: `ico-<brace|roll|thornhide|mending|hum|lull|bond|pluck>.png` and `-s.png`, `tag-<hold|evade|thorns|mend|hum|lull|bond|pluck>.png`.

Puzzle upgrades: a 12x12 corner gem on any upgraded tile (shown on hand tiles and the Puzzle box), one mark per upgrade so they stay tell-apart without colour: Sticky (magnet), Swift (feather), Hardy (bricks), Tender (heart), Leech (drop), Spiky (hedgehog), Soft touch (wing), Warm (flame), Finisher (target), Lucky (clover), Steady (scales). `mod-<sticky|swift|hardy|tender|leech|spiky|soft|warm|finisher|lucky|steady>.png`.
Plus: a 96x96 popover header picture for "Choose an upgrade" (a jigsaw piece with a spark) and rarity trim for common/uncommon/rare (not colour only: 1, 2, 3 stitches or pips).
