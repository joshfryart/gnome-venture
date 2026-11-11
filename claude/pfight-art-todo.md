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
