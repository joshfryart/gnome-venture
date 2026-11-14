# Piece effects: how to make pieces feel different

Research and proposal only (2026-11-14). No game code, data or tests were changed. Read from `game/includes/pfboard.php`, `pfight.php` (`pf_apply`, `pf_draw`, `PF_TAGS`, `PF_TAGS_V1`, `PF_MODS`), `pfdeck.php` (`pfd_tiles`), `data/pf_pieces.txt`, `data/pf_creature_pieces.txt`, `data/recipes.txt`, `calling_quests.php` (`CALLING_MENTORS`), `tools/pfengine.js`, `tests/pfengine_js.php`, and `piece-sources.md` beside this file.

## 1. What a piece is today

A piece = type (hurt, guard, heal, charm, soothe, trick, item) + value + right knob family + **one tag** + life + rarity. The tag column holds one key, so a piece carries one effect.

The 14 tags in the code (`PF_TAGS`, board wording in `PF_TAGS_V1`), plus two specials (`PF_SPECIAL`: snack, pal):

| On | Tags |
|---|---|
| Hurt | quick, heavy, pierce, poison, trip, bash |
| Guard | hold, thorns, evade, mend |
| Charm | hum, lull, bond |
| Trick | pluck |

Creature pieces use pierce, poison, quick, trip, bash, hold, thorns, evade, and a trick-only `heal`.

**Four things that look like differences but do nothing in a new fight** (rules of `pfb_v1_cfg`: `redraw` 1, `life` 0, `team2`/`team3` 1.0, one action a turn):

| Thing | Why it is dead |
|---|---|
| Quick ("draws you a piece when you place it") | `pf_apply` draws 1, but you place one piece a turn and `pfb_end_round` then throws the whole hand away and deals 5. The drawn piece is never playable. |
| Heavy | `PF_TAGS_V1` says it itself: "nothing extra on this board". |
| The `life` column (2 to 4 rounds) | cfg `life` is 0, so `pfb_v1_tile` drops it and every piece lasts `PFB_LIFE` = 3. Only the old 2.6.94 rule set in tests turns it on. |
| Teamwork (pal + tool + crop in one chain) | multipliers are 1.0 since 2.6.95. |

So Jab, Dibber Poke, Pickle Splash, Smash, Fork Lift and Windfall are plain Hurt pieces today, and Juicy Bite, Forager's Find and Sea Breeze (life 2) are not short-lived.

## 2. The redraw rule, and what "draw" can honestly mean

Each round: every unplayed hand piece goes to the discard, then you are dealt 5 (4 if tripped). You place 1. So "draw a piece now" is worth nothing. Only three hand effects mean something:

1. **A bigger hand next round** (6 to pick from instead of 5). The engine already has the mirror: the creature's Trip sets `me.slowdraw`, and `pfb_end_round` deals `PF_HAND_CAP - $slow`.
2. **Keep a piece** through the redraw (the loop in `pfb_end_round` that discards the hand).
3. **Place a second piece this turn.** The creature has this (`foe.again` in `pfb_foe_turn`); the player does not (`pfb_play` takes exactly one action, then the creature moves).

"Peek at the creature's next piece" already exists for everyone: the aim (`pfb_intent`, `pfb_aim_total`) shows its next piece, cell and total. A deeper peek has no hook and little value. "Move or swap a board piece" has no hook either: `pfb_play` knows four actions (place, place group, join, add) and none touches a piece on the board. Both are left out below.

## 3. Proposed effect kinds

Each is a new tag key, so the rule "one piece, one tag, one line of text" stays. Text goes in `PF_TAGS` and `PF_TAGS_V1`; the icon in `PF_TAG_ICON`.

| # | Name (key) | Player text | Carried by | Engine hook | Risk |
|---|---|---|---|---|---|
| 1 | **Keeper** (`keep`) | Keeper: stays in your hand until you play it | preserves (they keep), Seedkeeper mentor, one Gourmand piece | `pfb_end_round`, the redraw loop: do not discard a hand piece with this tag; `pf_draw` then fills to 5 | Low. Self-limiting: kept pieces count towards the 5, so each one is one fresh piece fewer. |
| 2 | **Plenty** (`plenty`) | Plenty: next round you pick from 6 pieces | feasts, Gourmand, Wayfinder mentor | `pf_apply` (root, `me`): set `me.moredraw` = 1; `pfb_end_round`: deal `PF_HAND_CAP - $slow + $more`, then clear | Low. Does not stack (a flag). The hand row on the page was not checked for 6 pieces. |
| 3 | **Simmer** (`simmer`) | Simmer: heals you 2 at the start of your next 2 turns | meals (soups, stews), Brewroot mentor | `pf_apply` (root, `me`): `me.regen` = 2; tick in `pfb_end_round` beside the `me.poison` tick, with an `envlog` line like poison's | Low. A second Simmer refreshes, it does not add (same as your poison on the creature). |
| 4 | **Sturdy** (`sturdy`) | Sturdy: a long chain does not use it up, and a strike cannot break it | tuber and grain dishes, Rootwarden mentor, a trophy | `pfb_spend`: skip it in the use-up loop (the `keepmine` line is the model); `pfb_strike`: `$broke` false | Medium. A Sturdy Hurt fires in every chain for 3 rounds. Lint: Guard, Heal and Charm only. |
| 5 | **Pairs** (`pair`) | Pairs: +2 when linked to another food piece | snacks, Gourmand | `pfb_fire`, before `pf_apply`: +2 if a `pfb_links` neighbour of the same side has the same `tile.src`; flag on the event for the replay | Low. Needs the new source `food` in `PFB_SRC` (piece-sources.md already asks for it). Previews are right for free: `pfb_cell_preview` runs the engine. |
| 6 | **Freshen** (`fresh`) | Freshen: your pieces touching it stay one more round | herb and drink dishes, Bloomcaller mentor | `pfb_place` after `pfb_fire`: `born`++ on each of your linked neighbours | Medium. The board is 4 x 4 for every size: longer-lived pieces can crowd it. |
| 7 | **Again** (`again`) | Again: place one more piece this turn | Thornblade mentor, one Rare trophy | `pfb_play`: return before `pfb_foe_turn` (like the free flip does), once a turn; `pfb_cell_preview`, the page and every bot assume one action ends the turn | High. Two chains a turn is the strongest thing here, and the largest change. Rare only. |
| 8 | **Built-in knack** (no new key) | the upgrade's own words, e.g. "Finisher: +3 once its Yield bar is past 60%" | trophies, spicy dishes | already in `pf_apply` and the JS: `leech`, `warm`, `spiky`, `finisher`, `soft`, `tender` (field `m`). Needed: `pf_make_tile` and `pfd_tiles` pass `m` through | Low. `m` is the puzzle-upgrade slot (`pfight_game.php` line 902 writes it by key), so decide: a piece with a built-in knack cannot take an upgrade. |

Also worth doing without a new effect: **make Quick true.** Either turn cfg `life` back on (Quick becomes "gone in 2 rounds", a drawback) or give Quick the Plenty rule. Today its text is false.

**JS twin and parity.** `tools/pfengine.js` is a full port (`apply`, `fire`, `spend`, `strike`, `place`, `endRound`, `play`) with its own copy of the tile table. Every row above except 8 needs the same change there, and `tests/pfengine_js.php` must fire it: its chaos bots build decks from `pf_tiles()`, which will not hold the new pieces, so the new tags are only reached through the deck mode (`v1d`, `tv_sources` in `tests/pfboard_tune_v1.php`). Add pieces with each new tag to `tv_sources` or the parity run proves nothing. Row 8 needs no engine twin work, only a deck that carries `m`. `tests/pfdeck_v1.php` lints tag keys against `PF_TAGS`, so new keys go there too.

**Sims.** The chain and smart bots do not know that a kept piece or a 6-piece hand has value (`pfb_score` only prices the creature's lasting effects). Win rates for Keeper and Plenty will read low until the bots are taught.

## 4. Food: one rule per tier, type from the buff

241 dishes cannot each have a rule. Two lookups give every dish a piece the player can guess before reading it:

| Dish tier (`recipes.txt`, count) | Value | Effect |
|---|---|---|
| snack (30) | 3 | Pairs |
| meal (40) | 4 | Simmer |
| feast (15) | 6, counts as Rare | Plenty |
| preserve (156) | 3 | Keeper |

Type from the dish's first buff stat, as piece-sources.md proposed: grit Hurt, hardiness Guard, nimble Guard, charm Charm, lore Trick, sense Soothe, luck Item. 44 dishes have no buff: Heal.

## 5. Example pieces

Values are base values (stat, level / 3 and rank are added as today).

| Name | Source | Type | v | Effect | Text |
|---|---|---|---|---|---|
| Cornbread | food, snack | Hurt | 3 | Pairs | A warm wedge. +2 when linked to another food piece. |
| Hot Cocoa | food, snack | Charm | 3 | Pairs | A shared mug. +2 when linked to another food piece. |
| Three Sisters Stew | food, meal | Hurt | 4 | Simmer | Filling. Heals you 2 at the start of your next 2 turns. |
| Garden Vegetable Soup | food, meal | Guard | 4 | Simmer | A warm bowl. Heals you 2 at the start of your next 2 turns. |
| Harvest Home Pie | food, feast | Guard | 6 | Plenty | Enough for everyone. Next round you pick from 6 pieces. |
| Orchard Crumble | food, feast | Charm | 6 | Plenty | Pass it round. Next round you pick from 6 pieces. |
| Tomato Chutney | food, preserve | Hurt | 3 | Keeper | Sharp and patient. Stays in your hand until you play it. |
| Dill Pickles | food, preserve | Soothe | 3 | Keeper | Good any day. Stays in your hand until you play it. |
| Napkin Flick | Gourmand, 1 Taste | Trick | 3 | Pairs | A flick of the napkin. +2 when linked to a food piece. |
| Second Helping | Gourmand, 10 Tastes | Heal | 5 | Plenty | There is always more. Next round you pick from 6 pieces. |
| Pomeroy's Table | Gourmand, 14 Tastes, Rare | Charm | 6 | Keeper | The table is always laid. Stays in your hand until you play it. |
| Burdock's Dig In | mentor, rootwarden (`bark`) | Guard | 4 | Sturdy | The mole stands firm. A long chain does not use it up. |
| Zinnia's Posy | mentor, bloomcaller (`bloom`) | Charm | 4 | Freshen | Fresh flowers. Your pieces touching it stay one more round. |
| Bracken's Drill | mentor, thornblade (`thorn`) | Hurt | 4 | Again (until built: pierce) | One, two. Place one more piece this turn. |
| Sorrel's Bookmark | mentor, seedkeeper (`sow`) | Trick | 4 | Keeper | Saved for later. Stays in your hand until you play it. |
| Tumble's Shortcut | mentor, wayfinder (`wayfind`) | Trick | 4 | Plenty | The hare knows a way. Next round you pick from 6 pieces. |
| Juniper's Gravy | mentor, brewroot (`brew`) | Heal | 4 | Simmer | Goes on everything. Heals you 2 at the start of your next 2 turns. |
| Bramblehorn's Gore | trophy, Old Bramblehorn (Horn Gore) | Hurt | 6 | pierce (exists) | The old horn. Ignores the creature's guard. |
| Titan Shell | trophy, Coconut Crab Titan (Titan Shell) | Guard | 5 | Sturdy | A shell that size. A long chain does not use it up, and a strike cannot break it. |
| Lightning Claw | trophy, Storm Eagle (Lightning Claw) | Hurt | 5 | built-in Finisher | Strikes when it is tiring. +3 once its Yield bar is past 60%. |

Trophies keep the boss's own tag where the player side of that tag works (pierce, hold, evade, poison, trip). Storm Eagle's piece is Quick on the creature, which is dead for the player, hence Finisher.

## 6. Build first (ranked)

| Rank | Effect | Why | Engine work |
|---|---|---|---|
| 1 | Keeper | The honest answer to "draw" under the redraw rule; gives all 156 preserves a reason | 1 condition in `pfb_end_round` + JS `endRound`; tag text and icon; 1 test section in `tests/pfboard_v1.php`; parity deck |
| 2 | Plenty | The other honest "draw"; the mirror of a rule that exists (`slowdraw`) | flag in `pf_apply`, 1 term in `pfb_end_round`; JS `apply`, `endRound`; check the hand row with 6 pieces; optional: Quick takes this rule |
| 3 | Simmer | Heal over time, copied from poison | `me.regen` in `pf_new`, `pf_apply`, tick in `pfb_end_round`; JS twins; replay line |
| 4 | Built-in knack | Six finished effects for no engine work | pass `m` in `pf_make_tile` and `pfd_tiles` (and JS `makeTile`); rule that such a piece takes no upgrade |
| 5 | Pairs | Makes a Larder of food pieces play together | needs source `food` first; 5 lines in `pfb_fire` + JS `fire`; event flag |
| 6 | Sturdy | Answers use-up and strikes, the two ways you lose a piece | `pfb_spend`, `pfb_strike` + JS `spend`, `strike`; type lint in `tests/pfdeck_v1.php` |

Later: Freshen (wait for data on board crowding at 4 x 4), Again (needs a second-action path through `pfb_play`, the preview, the page and the bots).

Not verified here: how the fight page lays out a 6-piece hand, whether `tests/pfdeck_v1.php` rejects unknown tag keys or only warns, and the exact Gourmand thresholds (taken from piece-sources.md).
