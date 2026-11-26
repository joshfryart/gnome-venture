# Phone in-place art check (step 5)

Build v2.8.70, 2026-11-26. Report only: nothing under `game/` was edited. The real game ran locally on a throwaway SQLite copy (`tests/walk.sh`, `tests/shot_seed.php`, `php -S`), 412 px wide at 2x, light and dark. Ten screens captured: garden, here, world, satchel, fight (pre-fight deck screen), catfish, almanac, puzzlepals, palyard, menu.

## Findings
P1
1. Fight (light): creature tags, the "Swarm" rule line, "lv 1" and the deck count "12" are nearly invisible on cream. Dark theme is fine. (Confirmed by eye on fight-light.png.)
2. World map: the "you" marker is a smooth system emoji (hat) on the pixel map; the "You are here" pill shows the pixel gnome hat for the same symbol.

P2
3. Here and Pal Yard: 8 of 9 hotspot labels are cut off ("Wander...", "Villa...") and cover the building art.
4. Here and Pal Yard (dark): scenes are dimmed and desaturated; dashed hotspot frames look like debug outlines.
5. World map: right half of the frame is dark dither with cyan streaks; reads as noise at 412 px.
6. World map: button icons are about 10 to 12 px in 48 px boxes; in dark theme two boxes turn brown while +/- stay green.
7. Puzzle Pals: "Still locked" cards use a plain grey square with "?" as art; looks like missing art.
8. More menu: "Puzzle Pals" and "Puzzle box" share the same green jigsaw icon.
9. Satchel: search placeholder starts with a glossy system emoji next to pixel icons.
10. Fight pieces: creature piece glyphs are small and low contrast; Pierce and Brace glyphs are muddy on the player deck.
11. Fight (dark): the Aphid Swarm portrait reads as a smudge on dark brown.

P3
12. Garden: tilled empty beds read as stone or brick with blue stripes, not soil.
13. Garden, satchel, almanac: 12 to 16 px tab icons turn into colour blobs.
14. Cat Fish (dark): the black cat is separated from the card only by a thin outline; mini cats in the header are faint.
15. Top bar: "Gnome Venture" is cut to "Gnome Ven" at 412 px (UI, not art).
16. Puzzle Pals (dark): Jeff's black outline loses edge on dark brown.

## Checked and fine
No broken images, no sideways overflow, no blur on pixel art in zoomed crops, dock icons read well in both themes, villager sprites on Here are clean.

## Not checked
A fight in progress, animations, Cat Fish after adoption, the yard with real pals, other towns and seasons, real phones (emoji differ on iOS and Android), anything below the first 1500 CSS px of long pages.

Note: the first screens of this folder were committed once as work in progress, then replaced by this run.
