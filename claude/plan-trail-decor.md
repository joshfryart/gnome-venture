# Trail `decor` field: the rich map looks as game data

Decided by Josh 2026-11-14: "Add a `decor` data field so the rich map looks are game data." This note says what was built (the safe first slice) and what is left.

## Where the look lived before
- Raised things (trees, haybales, hedges, boulders, landmarks, a few props) were already game data: `objs` `[x, y, key, jit, jy]` per section, drawn by `trail_art_svg` in depth order.
- Everything flat (rough-ground kinds such as wheat, clover, marsh, shells; floor zones such as furrows; ponds and sea looks; most props such as goats, crates, ducks) existed only inside the ground picture `ground/<route>-<section>-r.png` and in the painter's dressing: `tools/maplewold_rich_specs.py` `rich_for()` (hand sketch for the 16 Maplewold routes, `auto()` from the builder's stamps, `infer()` from the tiles for the 230 generated routes).

## Built (first slice, 2026-11-14)
- **Field** `decor` on every authored section (all 246 routes, 665 sections, in `game/includes/data/trail_maps/*_30x18.json`; +0.6 MB, about 13%):
  `{"v": 1, "looks": [[kind, x0, y0, x1, y1]], "rough": [...], "rough_default": kind, "floor": [...], "props": [[kind, x, y]], "tree": kind}`.
  The painter's precedence rules are already applied (looks: last rect wins, only on thicket tiles that are not a stream, border only for `sea`; rough and floor: first rect wins), and the result is stored as rectangles that do not overlap, one kind each. So a reader needs no order rules: a tile is in at most one rect per layer. A rough tile in no rect is `rough_default`.
  `props` are the dressing's hints (the painter snaps each to the nearest free tile; the drawn spot can differ by a few tiles). Ambient animals and milestones the painter adds by itself are not listed.
- **Writer** `tools/trail_decor.py --write` (idempotent, data only, 1 s; `--check` exits 1 when a section's decor is missing or stale). It refuses a route whose source rows (`claude/bend-prototype-v2`, `claude/maplewold-bendy-maps`) differ from the game rows. `tools/bake_trail_rich.py` writes the same field on any future bake.
- **No re-bake**: the ground pictures are untouched (a re-bake is not bit-for-bit the same).
- **Engine** (`game/includes/trail_art.php`): `trail_decor($art)` (the field cleaned: bad entries dropped, other versions ignored, so a hand edit cannot break a walk) and `trail_decor_at($art, $x, $y)` (what a tile is dressed as). Nothing draws from it yet: the look is exactly what it was.
- **Tests**: `tests/trail_bendy.php` block "decor" (every section has it, rects in bounds, no overlap, each layer on its own tile type, 1,419 raised thicket sprites in `objs` stand on a tile of their own look with 0 disagreements, so the decor matches the baked pictures; bad entries dropped; same map with or without it), `tests/trail_authored.php` (228 section 2 draws the same SVG with or without decor).

## Built, slice 2 (2026-11-14, Josh: "next safe slice")
- **Fallback look from decor**: where a section's ground picture is missing (not shipped, not uploaded), the old tile look (`tm_render_svg`) now colours each dressed tile by its decor kind (`TRAIL_DECOR_TINT`, 51 kinds, every kind in the data has one; `trail_decor_tints()`; state key `tints`, layer `class="tmdecor"`): thicket tiles a full tile of their look's colour (hedge green, haybale straw, pond blue), walkable tiles a soft patch (wheat, clover, shells, furrows).
- **With the picture present nothing changes**: `trail_view_html` only passes `tints` when `trail_art_ready()` is false; `trail_art_svg` ignores it; `tm_render_svg` without `tints` (every other map: delves, treks) is byte for byte the old output.
- **Tests**: `tests/trail_bendy.php` (every kind has a colour; the old fallback is identical without tints; tints draw `tmdecor`; the baked look ignores tints) and `tests/trail_sights.php` on an installed game (route 240: with the picture no `tmdecor`; picture moved away: the page draws the decor colours; picture back: the same page as before, form nonce aside).

## Not built (next slices, each needs Josh's word)
1. **Use it in play**: tile aria-labels / the tap card naming what is there ("Wheat", "A duck pond"); Trail Sights or finds keyed to a tile's look (forage in clover, shells on the shore). Changes page markup, not the picture.
2. ~~Fallback look~~: built in slice 2 (colours only). A richer fallback (small sprites per kind from `obj/`) is possible later.
3. **Admin editing**: edit `decor` in Admin and re-paint one section from it (needs the painter in PHP or a server-side bake: big).
4. **Bake from decor**: make `decor` the source of truth for the painter (today `rich_for()` is the source and `decor` a copy of its result). Only worth it with item 3.
5. **Exact prop spots**: store where each prop was actually drawn (the painter's snapped spot) instead of the hint; needs a change in `render_bendy_rich.paint()` to return them, and only lands on the next bake.
