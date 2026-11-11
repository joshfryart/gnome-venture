# Prompt: draw the Puzzle Combat art for Gnome Venture

You are taking over the **art** for a new feature in the game Gnome Venture (repo `joshfryart/gnome-venture`, branch `ccr-dea0abf9-eaakqa`). Another AI is writing the code and will hook your files in. Do not edit PHP/JS/CSS. Deliver PNGs (and `.aseprite` sources) only.

## Read first
1. `claude/plan-puzzle-combat.md` (on branch `claude/combat-puzzle-pieces-45oi6f`): the design. Section 3 (tiles and sockets), 4 (combos), 9 (UI) matter for art.
2. `claude/pfight-art-todo.md`: the raw asset list.
3. `aseprite-source/HANDOFF.md`, `art-style-guide.md` (Part D and its addenda) and the `gvlib` Lua library, if present on your machine. The look is **"Stitched Toy"**: hard pixels only (no anti-aliasing), cream halo `#f2e4c0`, umber outline `#2a1a10`, 3-tone selective outline, hue-shifted ramps, one lower-right cel-shade, 1px rim light, enamel gloss comma, gold stitched seams. Every asset must be visually unique; recolouring one template is not acceptable. Palette families: soil, moss, gold, ember, petal, water, dusk, stone.
4. `game/assets/img/ico/` and `game/assets/img/jigsaw/` for the existing look. Puzzle Pals pieces already exist as real jigsaw pieces; match their feel.
5. `DESIGN.md` for the UI colours (felt `#3d2a1c`, cream `#f2e4c0`, thread gold `#e8a317`).

## What the game does (so the art makes sense)
Fights are played with **tiles** like jigsaw pieces. You play a chain of 1 to 4 tiles; the creature answers with a chain. Tiles sit on one shared strip. Each tile has a **hole on the left** and a **knob on the right**. A knob that matches the next tile's hole is a "snug fit" (bonus). The player must be able to read, at a glance and **without relying on colour**: what the tile does, and what shape its two ends are.

Seven **effect types**: Hurt, Guard, Heal, Charm, Soothe, Trick, Item.
Three **socket families**: Body (round), Mind (keyhole), Craft (triangle). A knob and hole of the same family fit. A flat edge is wild (fits anything).

## Hard accessibility rules (colour-blind safe, this is the main brief)
Every distinction must be carried by **at least two of: colour, shape, pattern, glyph**. Never colour alone.
- **Effect type = colour + fill pattern + icon.** Use the Okabe-Ito colour-blind-safe set as the base hues, nudged into the Stitched Toy palette: Hurt vermilion `#d55e00`, Guard blue `#0072b2`, Heal bluish-green `#009e73`, Charm reddish-purple `#cc79a7`, Soothe sky `#56b4e9`, Trick yellow `#f0e442`, Item orange-brown `#e69f00` (adjust a little for style, keep them far apart in lightness too). Each type also gets its own **fill pattern** on the frame body (e.g. Hurt diagonal slash stripes, Guard brick/cross-hatch, Heal dots, Charm small flowers/hearts, Soothe wavy lines, Trick checker, Item plain with a stitched border) and its own **icon**.
- **Socket family = shape only** (plus a tiny letter B / M / C is added by the code, you need not draw it). Round, keyhole, triangle. Make the three shapes clearly different at 16 px, both as knob (bump) and as hole (notch). They must stay distinguishable in grayscale and with red/green or blue/yellow colour-blindness.
- **Foe tiles vs your tiles:** do not rely on tint alone. Your tiles have a cream stitched outline; the foe's have a dark thorn/jagged outline.
- Keep the value number area clear: the code prints the number on top, so leave a calm 14x12 px corner for it with good contrast on every type colour.
- Test your work: view each sheet in grayscale and in simulated deuteranopia, protanopia and tritanopia. All seven types and all three sockets must still be tell-apart. Include those test views in your delivery.

## Two sizes of tile frame (important)
Hand cards are **larger**; strip (tracker) cards are **smaller**. Same design, redrawn for each size, not just scaled.
- **Hand tile:** 96 x 68 px native. Icon 32 x 32 inside. Room for a name line (code prints text) and the value corner.
- **Strip tile:** 56 x 40 px native. Icon 20 x 20, no name line.
The game shows them with `image-rendering: pixelated` at 2x on phones (412 px wide screen), so crisp pixels matter.

## Assets to deliver (all under `game/assets/img/pfight/`, PNG with transparency, plus the `.aseprite` in a mirrored folder)
Names are fixed so the code can find them; a missing file simply keeps the current emoji, so you can deliver in any order. **Do the first group first.**

### Group 1: tiles (needed to ship)
- `tile-hand-<type>.png` x7 (hurt, guard, heal, charm, soothe, trick, item): 96x68. Frame body only: pattern fill, outline, and the left/right ends **without** socket shapes (sockets are separate overlays, below).
- `tile-strip-<type>.png` x7: 56x40, same.
- `sock-hand-<family>-<knob|hole>.png` x6 (body, mind, craft): the end-cap drawn to overlay the frame's left or right edge. Hand size: 20x68. Also `sock-hand-flat-knob.png` / `sock-hand-flat-hole.png` (wild edge).
- `sock-strip-<family>-<knob|hole>.png` x6 + flat x2: 12x40.
- `ico-<type>.png` x7: 32x32 (hand) and `ico-<type>-s.png` x7: 20x20 (strip). Simple, bold, readable in one colour. Hurt: swing/claw. Guard: leaf-shield. Heal: herb/green heart. Charm: flower. Soothe: dove or calm face. Trick: mask/feather. Item: snack/jar.
- `frame-foe-hand.png`, `frame-foe-strip.png`: the jagged dark outline overlay for the foe's tiles. `frame-me-hand.png`, `frame-me-strip.png`: the cream stitched outline overlay for yours.
- `frame-picked-hand.png`: a "raised / selected" overlay (glow ring + shadow) 100x72.

### Group 2: strip and bar
- `strip-rail.png`: tileable horizontally, 24 px high.
- `open-end.png`: 24x24 marker (glowing ring or arrow) for the open end of the strip.
- `intent-bubble.png`: 28x24 speech bubble that the small type icon (`ico-<type>-s.png`) sits in.
- `bar-frame.png` 96x12 plus `bar-fill-hurt.png` and `bar-fill-charm.png` 92x8 (the resolve bar fills from both sides: Hurt = slashes, Charm = flowers; distinguishable without colour).

### Group 3: moments
- `combo-ambush.png`, `combo-riposte.png`, `combo-double-swing.png`, `combo-calm-charm.png`, `combo-win-over.png`, `combo-bait.png`: 32x32 stamps shown when a combo fires and on its Almanac page. Each unique, each readable alone.
- `end-charmed-small|medium|large|boss.png`: 64x64, the creature won over with a flower. `ico-gift.png`: 24x24.
- Optional: `fx-hit.png`, `fx-guard.png`, `fx-heal.png`, `fx-charm.png` 4-frame 32x32 sprite sheets (128x32) for a pop animation.

## Style and working rules
- Hard pixels only. No anti-aliasing, no gradients, no blur. Pixel-perfect at native size.
- Light and dark theme: the card sits on the dark felt panel, but icons must also work on cream. Keep the outline umber `#2a1a10` and halo cream so both work.
- Pixel art by Opus-quality hand drawing, not recoloured templates. If you use Sonnet or Haiku, only for support work (file handling, sheets, grayscale checks).
- No 8x preview files. Make one HTML contact sheet (`pfight-contact.html`, scaled with CSS) showing every asset at native size on felt and on cream, plus the colour-blind and grayscale views side by side.
- Give a short cost estimate and **ask before any large spend**.
- Put a `README.md` in `game/assets/img/pfight/` listing every file, its size, and the type/shape it encodes.

## Acceptance checklist (I will check these)
1. All files named exactly as above, correct sizes, transparent PNG.
2. Grayscale and the three colour-blind simulations: all 7 types and 3 socket shapes are tell-apart at hand size and strip size.
3. Hand tiles look clearly bigger and richer than strip tiles.
4. No two icons or combo stamps share a silhouette.
5. Value corner readable on all seven colours.
6. Contact sheet and README delivered.

Commit only under `game/assets/img/pfight/` and `aseprite-source/pfight/` (sources). Do not touch other files. Report what is done and what is left.
