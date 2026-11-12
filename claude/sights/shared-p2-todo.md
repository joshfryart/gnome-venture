# Shared land Trail Sights: what still cannot be done (engine gaps)

Status: TODO (2026-11-12, after the full-grammar data pass). Data: `trail_sights_shared.txt` (89 rows) + the 5 example rows in `trail_sights.txt`, `trail_sight_folk_shared.txt`, `trail_sight_quests_shared.txt`, `trail_sight_items_shared.txt`, `trail_sight_pages_shared.txt`, `trail_sight_newfolk_shared.txt`. Ideas: `ideas-shared-land.md`. Art: `shared-art-todo.md`.
Everything else in the ideas file is now in the data (picks, tallies and milestones, titles, pages, hints, nocheck helpers, give= hand-ins, newfolk, quest closers at the opening Sight, beat needs, fpto, item effects).

## Test harness (tests/trail_sights.php is behind the grammar)
- The all-routes walk calls `trail_sight_do` with no `pick`, so every `pick:` Sight is refused "Choose one." (shared: root tangle, acorn scatter, mud skippers, scree, driftwood arch, shell-bell tree, ice steps, shell heap).
- The quest walk does not hand over beat `needs` items, so lines with `take=` beats never finish (shared: runaway-kite, sunday-hat, bridgewarden, picnic-for-everyone, walking-ladder). It also reverses `anylast` lines (last beat first) and has no @boss/@meal/@friend events.
- "One page per Sight" counts every page in chapter `Sights`, so the extra `page=` pages (chapter Sights, as GRAMMAR.md says) make it fail.
- `grassland-the-clover-patch` is the test's fixture row (no check, win line with "thorough"), so it keeps no luck check (design: luck 12).

## Grammar gaps
- `@chance` is ignored on `fpto=`, `hint=`, `title=`, `page=` (they always pay when their condition holds), and `?cond` on `tally=` is ignored (every win counts). So "3 different nights / seasons / weathers" milestones count any wins; the prize tokens carry the condition instead (lantern wick title at dusk/night, Ice Pianist on frost, mirror pebble on calm days).
- A `?tl=` milestone pays on EVERY use after N (no "exactly N" / once), so milestone items are low-odds keepsakes, not big prizes.
- `nocheck` does not help a `pick:` Sight (only stat checks).
- No condition for "this quest line is done": after-quest effects stay out (meadow forecast after KITE is a tally milestone instead; Marrowby's stall is `se=autumn` only; stilt-house nap Sight, knoll feast buff, crows' trinket every 7 days, Pinchwell's weekly letter, Lyra's Hollow Round buff whenever she is on a green).
- No either/or checks (boardwalk: plank OR nimble 9), no season-dependent DC (bluebells easier in spring), no penalty token (wind notch headwind), no "rest N game hours" (stone hut, shade awning, hammock, bones).
- Folk rows: no stat check for the villager's own ask (charm/sense/lore/luck asks pay on any win); no escorts (mossy stair basket, Tobias switchback 20% off); no "return it next visit" (glow-moss book); no shop effects (Tobias seed discount, Marrowby price book better prices, Lyra's free song).
- Effects that are not tokens: next fishing Sight +1 catch (Keeper Loamwick), next crossing +2 (lily-pad coach), hay-ride skip of 10 minutes, rowboat short hop, Lantern Path no-fog night, Squirrel's Spare Key acorn bonus, Teeny Axe +1 at the bramble gap, Hatter's Thimble on gifts only, Parrot Phrasebook with travellers only, Pocket Star-Wheel night markers, Bridgewarden's Badge +2 on crossings (it is decor; the line gives a 4-hour nimble buff), Feather Pillow +1 energy on naps (decor).
- Charms whose rows exist but cannot be buffs without changing `edible` (brief allows only adding effects): fern-drip-hat-charm, pocket-whistle, daisy-chain-crown stay keepsakes.
- "+10 friendship with every villager of that town" (PICNIC) and "Wish Delivery" (dandelion: a thank-you in the next town 3 days later): no token.
- Shared-across-players mechanics (P4): cairn pass stone count and Cairn Token, bottle-post notes, stargazer's chalk marks.
- Quests that should start from a villager's request (Notice Board favour) start at their first beat Sight.
- Seeds that must grow: Tiny Thank-You Seed, Lantern Fruit Seed (rows keep `seed=1@8`, `lanternroot`).
