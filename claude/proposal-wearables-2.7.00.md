# Wearables as Keepsakes: proposal for 2.7.00

Proposal only (2026-11-15). No game file, data file or test was changed. Rules read from the 2.6.990 rule book and from `origin/main` (`pfight.php`, `pfboard.php`, `pfdeck.php`, `data/pf_pieces.txt`). Sims ran on a throwaway copy of the engine (section 5).

## 1. The idea in five lines

- A wearable is **one piece in your deck**. It needs a free Keepsake slot to be switched on, like a crop piece needs a Larder slot. "Worn" means "switched on in the Puzzle box".
- Every effect below **already exists in the engine** (tags Evade, Keeper, Mend, Plenty; knack Leech). No new tag, no new global rule, no change to one action a turn, the 4x4 board or the redraw.
- Numbers use today's scale: base value + your stat + a third of your level + rank bonus (+0 / +2 / +4). Base values are 2 to 3, the low end of sourced pieces (2 to 5), because a wearable is available from level 1.
- Rank comes from the Tailor: bought, found or first-made = Common; **Lined** = Uncommon (+2); **Fine** = Rare (+4, counts toward the deck's 3 Rare). No Masterwork wearable.
- Slots as decided: 1 / 2 at level 15 / 3 at level 25 / 4 at level 40. No Keepsake piece exists in the game yet, so nobody loses a piece when level 1 goes from 2 slots to 1.

## 2. The six wearables

| Wearable | Piece | Type | Base | Right knob | Effect (existing) | Main source |
|---|---|---|---|---|---|---|
| Flood Boots | Puddle Hop | Guard | 3 | body | **Evade**: its next Hurt misses; an unused Evade stops a poison tick | craft |
| Wayfarer's Hat | Tip of the Hat | Soothe | 3 | mind | **Keeper**: stays in your hand until you play it | buy |
| Work Gloves | Firm Grip | Hurt | 3 | craft | **Leech** (built-in knack): heals you 1 + a sixth of the hit | craft |
| Travel Cloak | Wrap Up | Guard | 3 | mind | **Mend**: also heals you 2 | found, craft |
| Trail Pack | Rummage | Item | 2 | body | **Plenty**: next round you pick from 6 pieces | buy, found |
| Yarn Scarf | Yarn Wrap | by colour | 3 | craft | none (plain) | Cat Fish, 12 Yarn |

Top and bottom edges: body family for all six (new entry `'wear' => 'body'` in `PFB_SRC_FAM`, like pal pieces). They then stack on Hurt, Guard and pal pieces. In the sim, body columns lost slightly less health than mind columns (26.0% against 28.1%).

What the number is in play (test gnome of the rule book: stat 0 below level 11, 1 from 11, 2 from 25):

| Gnome level | Firm Grip, Common | Lined | Fine | The rule book's "typical Hurt of yours" |
|---|---|---|---|---|
| 4 | 4 | 6 | 8 | 3 to 5 |
| 9 | 6 | 8 | 10 | 5 to 8 |
| 21 | 11 | 13 | 15 | 10 to 16 |
| 28 | 14 | 16 | 18 | 13 to 19 |

So a Common wearable sits at the low end of your hand and a Fine one in the middle. The tag effects do not grow: Evade is one miss, Mend is 2, Plenty is one extra piece, Leech is 1 + hit / 6 (a hit of 11 heals 2).

### Flood Boots (the decided item)
- **Look**: tall waxed green boots with a rolled top; they replace the boots layer on the gnome.
- **Road**: flooded sections cost +5 game minutes instead of +10, while the boots are worn (switched on). See question 1.
- **Fight**: Puddle Hop, Guard 3, Evade. I chose Guard with Evade because flooded roads are where Water and Reptile creatures live, and Evade is the only player effect that stops a poison tick (rule book 2.10). Reptiles are the worst class for the careful player: 47% of health lost.
- **Get it**: Tailor: Rubber Sap 2, Coir Fibre 2, Cork Bark 1, 4 energy. Also a Sights reward on flooded routes.
- **Almanac**: "Waxed boots that come up past the knee. Flooded roads slow you half as much, and in a fight you hop clear of the next hit."

### Wayfarer's Hat
- **Look**: a wide brown felt hat with a feather; drawn over the gnome's own hat colour as a brim and band (the pointed hat stays).
- **Fight**: Tip of the Hat, Soothe 3, Keeper. The engine's Keeper check is on the tag only (`pfboard.php` line 1413), so a Soothe can carry it. Hold it for the round the aim is big. It costs a draw while you hold it (you see 4 new pieces, not 5). Soothe is not a block, so it is safe against a Beast's Grudge.
- **Get it**: Twigg's, 300 Petals, level 5 (beside the fight belts). Also a Sights reward.
- **Almanac**: "A hat for long roads. A polite tip of it calms a creature, and you can save it for the right moment."

### Work Gloves
- **Look**: tan leather gloves with a stitched cuff; a small recolour of the hands.
- **Fight**: Firm Grip, Hurt 3, Leech. The only Hurt wearable: the pick for shorter fights. Because Leech sits in the knack slot, the piece cannot take a puzzle upgrade.
- **Get it**: Tailor: Coir Fibre 2, Pine Resin 1, Stag Beetle Shell 1, 4 energy.
- **Almanac**: "Thick gloves for thorns and stings. A firm grip that gives a little back each time it lands."

### Travel Cloak
- **Look**: a moss green cloak with a wooden toggle, behind the gnome in front view, over the back in back view.
- **Fight**: Wrap Up, Guard 3, Mend (also heals 2). Today only the level 15 knack Mending has this tag. A Guard next to a Hurt is also a Riposte (x1.5).
- **Get it**: found (Sights and road rewards from level 10), or Tailor: Cottongrass 3, Sphagnum Moss 2, 4 energy.
- **Almanac**: "Wool against the wind. Pull it close to block a hit and warm up a little."

### Trail Pack
- **Look**: a small canvas pack with a rolled blanket, on the back.
- **Fight**: Rummage, Item 2, Plenty. An Item without the Snack tag eats nothing and is never refused (rule book 10.20). Base 2, not 3, because of the sim (section 5).
- **Get it**: Twigg's, 800 Petals, level 15; or a camp-spot or toll-road reward.
- **Almanac**: "There is always something at the bottom. A bite to eat now, and one more piece to choose from next round."

### Yarn Scarf (exists; keep the 12 Yarn purchase)
- **Look**: as today. It is drawn whenever a colour is set, worn in a slot or not.
- **Fight**: Yarn Wrap, a plain 3 with no tag. **The colour sets the type**: Poppy red Hurt, Bluebell Guard, Buttercup Charm, Moss green Soothe, Wool cream Trick. Colours stay free.
- **Why colour should matter**: it gives the Cat Fish purchase a use, it is the one Keepsake you can re-type for free, and a plain 3 is the floor of the scale (Swing 4, Dodge 4, Charm 4). **No colour heals**: in the sim a plain Heal 3 was worth three to five times any other colour (-6.3 points of health lost against -1.3 to -2.0), so everybody would wear green.
- **The cost**: a player who likes blue but wants Hurt must choose. If that bothers you, the fallback is a fixed Charm 3 whatever the colour (question 2).
- **Almanac**: "Knitted from Cat Fish yarn. Its colour decides what it does in a fight: red strikes, blue blocks, gold charms, green calms, cream tricks."

Lining at the Tailor (any wearable, the scarf too): Lined = the wearable + Cottongrass 2 + Butterfly Scales 1. Fine = the Lined wearable + Seed Pearl 1 + Snow Moth Dust 1. All are existing gatherables; Seed Pearl is rare. Camp kit and toll receipt stay plain items with no piece.

## 3. Slots: what competes, and what a player wears

Everything that wants a Keepsake slot, ranked by what one piece did for the careful player in the sim (health lost per fight, baseline 29.4%; turns, baseline 7.8). Friend, Gourmand and trophy rows use the pieces of `piece-effects.md`.

| Rank | Piece | Kind | Health lost | Turns | Role |
|---|---|---|---|---|---|
| 1 | Juniper's Gravy (Heal 4, Simmer, Uncommon) | friend | -10.1 | +0.5 | safety, much the strongest |
| 2 | Rummage (Item 2, Plenty) | wearable | -5.4 | +0.4 | safety |
| 3 | Firm Grip, Fine | wearable | -3.9 | -0.6 | speed and safety |
| 4 | Wrap Up, Tip of the Hat | wearable | -3.2, -3.1 | +0.3, +0.6 | safety |
| 5 | Firm Grip, Puddle Hop (Common) | wearable | -2.5, -2.4 | 0, +0.3 | all-round |
| 6 | Bramblehorn's Gore (Hurt 6, Pierce, Rare) | trophy | -1.8 | **-1.1** | speed: careless player wins 93% (was 88%) |
| 7 | Yarn Wrap, any colour | wearable | -1.3 to -2.0 | 0 to +0.3 | style |
| 8 | Pomeroy's Table (Charm 6, Keeper, Rare) | Gourmand | -0.7 | **-1.0** | speed: careless player wins 91% |

Reading: trophies and the Gourmand Rare make fights shorter, a friend's Heal makes them safer, wearables do a little of either. That is the intended order: wearables come first and cheapest, the earned pieces are stronger.

| Tier | Slots | What is owned by then | A sensible pick | The real choice |
|---|---|---|---|---|
| Level 1 to 14 | 1 | scarf, gloves, hat; the first Gourmand piece | Work Gloves | speed (gloves) or safety (hat); Flood Boots on a flooded route |
| 15 to 24 | 2 | pack, cloak, boots; first mentor friend piece | Gloves + Cloak, or Boots + Pack against poisoners | a friend's Uncommon piece beats a Common wearable: line the wearable or swap it out |
| 25 to 39 | 3 | first lair trophies | Trophy + Fine Gloves + Pack | the deck's 3 Rare: a Fine wearable, a trophy and a Rare legendary crop piece all want them |
| 40 and up | 4 | everything | Trophy + friend + two wearables | the fourth slot is the first room for a utility piece (hat or pack) |

Only one Keeper is worth wearing (each costs a draw), and Plenty does not stack, so Hat + Pomeroy's Table or Pack + Tumble's Shortcut are poor pairs by the existing rules. No extra rule is needed to stop stacking.

## 4. Why this is small enough

- One piece among 13 to 19 in the deck: you draw it in about a third of rounds.
- Each tag is one already measured in the game: Evade (Roll 2, Sweep 3), Mend (Mending 2), Keeper and Plenty (legendary pieces of base 4 to 6), Leech (Cane Crush 6). Every wearable is at or below the existing piece with the same effect.
- Nothing lasts past the fight, nothing changes the creature, and no wearable carries Trip or Lull (rule book 10.5 is still open).

## 5. Balance check (sim)

Method: the rule book's driver `play/sim.php`, same 19 creatures and policies, 40 seeds instead of 6 (760 fights a row), gnome at the creature's level. The baseline reproduces the book exactly on seeds 1 to 6 (99%, 29.0%, 7.8). Wearable pieces were added to the dealt deck. Differences are paired by seed; standard error of "health lost" is about 0.9 points.

| Deck | Careful: wins | Health lost | Turns | Careless ("biggest number"): wins | Health lost |
|---|---|---|---|---|---|
| Baseline 2.6.990 | 99.7% | 29.4% | 7.84 | 88.2% | 64.0% |
| Decided slots, Common (gloves; + boots at 15; + cloak at 25) | 99.6% | 26.0% | 7.98 | 87.6% | 64.6% |
| Decided slots, all Fine | 99.9% | 23.6% | 7.43 | 89.9% | 59.6% |
| Upper bound: 4 Fine wearables at every level | 100% | 18.0% | 8.08 | 90.8% | 58.4% |
| For scale: Juniper's Gravy alone | 99.9% | 19.3% | 8.29 | 87.9% | 64.0% |

- Pass by the test of `piece-sources.md` section 5 (win rate within 3 points, no more than half a turn longer): both "decided slots" rows pass.
- Win rates do not move. What moves is health carried to the next fight: 3 points with Common wearables, 6 with Fine ones.
- By class, one wearable helps most against Birds (-6 to -7) and least against Plants (0). Boots against Reptiles measured +1.9 (noise): the bot does not know Evade stops poison.
- The heal-type pieces are the outliers. Rummage at base 3 measured -6.7, at base 2 -5.4. One friend piece from the earlier proposal (Heal 4 + Simmer) does more than four Common wearables together: worth a look before those rows are written.

Limits: the bots do not value Keeper, Plenty or Evade against poison, so the hat, the pack's tag and the boots are under-measured. The harness gnome stops at level 32, so four slots were only forced, never earned. The harness deck is thin on Heal pieces, which flatters every healing piece. Scarf cream (Trick) was not run. No live page was opened.

Files: `/tmp/claude-0/-home-user-gnome-venture/1101d9fa-b4fd-50ef-b489-67587a4c53bd/scratchpad/wear/sim/a/b/c/play/simw.php` (driver; env `WEAR`, `RANK`, `SLOTS`, `COL`) and `/tmp/claude-0/-home-user-gnome-venture/1101d9fa-b4fd-50ef-b489-67587a4c53bd/scratchpad/wear/runs/` (one jsonl per row).

## 6. Change list

| File | Change |
|---|---|
| `game/includes/data/pf_pieces.txt` | 10 rows, source `wear`, key `w:`. Header comment gets the new source. Example: `w:gloves\|Firm Grip\|wear\|work-gloves\|hurt\|3\|craft\|-\|-\|src\|A firm grip. Heals you a little when it hits.\|leech`. Others: `w:boots` guard 3 body evade; `w:hat` soothe 3 mind keep; `w:cloak` guard 3 mind mend; `w:pack` item 2 body plenty; `w:scarf-red` hurt, `-blue` guard, `-gold` charm, `-green` soothe, `-cream` trick (all 3, craft, no tag). |
| `game/includes/pfdeck.php` | `pfd_slots()`: keeps 1 / 2 (15) / 3 (25) / 4 (40). `PFD_KEEP_SRC` += `wear`. `PFD_PLAYER_SRC` += `wear`. `pfd_build`: `$owned` and `$rankOf` cases for `wear` (from `$src['wear'][ref] = rank`). `pfd_sources_blank` and `pfd_sources`: read owned wearable items (rank from the item's `effects`, as tools do) and the worn scarf colour (`catfish_scarf_color` knows it). `pfd_ensure_content`: hat and pack into Twigg's stock, as the belts are. |
| `game/includes/pfboard.php`, `tools/pfengine.js` | `PFB_SRC` += `wear`; `PFB_SRC_FAM` += `'wear' => 'body'`. The JS copy of `PFB_SRC_FAM` has no `legend` entry today: confirm tiles reach it with their edges already made. No rule code changes. |
| `game/includes/pfdeck_view.php`, `assets/pfv1.css` | Keepsake pips in `pfv_box_html` (line 171) for 1 to 4 slots, shown once a Keepsake is owned; a filter button and `PFV_SRC_ICON` entry for wearables; "worn" wording on the switch. |
| `game/includes/crafting.php`, `data/crafts.txt`, `hub_pages.php` | New category `tailor` (the workshop picture makes one hotspot per category in `workshop_view`, so the Tailor spot follows; needs its art region). 4 recipes + 2 lining recipes per wearable. `tests/pfdeck_v1.php` line 75 expects one craft piece per category: add `k:tailor` (for example "Needle Jab", Hurt 2) or exempt the category. |
| Items, Almanac, road code | Items `flood-boots`, `wayfarers-hat`, `work-gloves`, `travel-cloak`, `trail-pack` with Almanac pages (plan item 8). Flooded-road minutes (plan item 5, not written yet) ask "are the boots worn". Sights and road reward tables (`data/trail_sights_*.txt`) get the found items. |
| `game/includes/gnome.php`, `gnome25.php`, `gnome_parts.php` | Draw worn wearables. `GNOME25_ORDER` already has boots, tunic, scarf and hat layers; cloak, pack and gloves are new layers in three views plus the rig sheet. Can ship after the pieces (question 4). |
| Tests | `tests/pfdeck_v1.php`: slot table (line 282), "keepsakes 0 of 2" (line 289), data lint for `w:` keys (line 69), a wearable takes a slot, the second is refused at level 1, the scarf piece follows the colour, a Fine wearable counts as Rare. A parity fight with the wearable pieces in `tests/pfengine_js.php`. Flood minutes with and without boots worn. |
| Rule book | 3.6 (slot table), 2.5 (Keeper on Soothe, Plenty on Item), 9.2. |

## 7. Risks and questions for the owner

1. **Flood Boots: worn or carried?** I read "takes a Keepsake slot" as: the +5 only applies while the boots are switched on. Risk: players switch them on before a flooded road and off after (free outside a fight). Alternative: the road effect works from the satchel and only the fight piece needs the slot.
2. **Scarf colour = type**: accept the style-against-use conflict, or fall back to a fixed Charm 3?
3. **Trail Pack at Item 2**: still the strongest wearable for a careful player. Keep it (it comes latest and costs most), or make it a Trick?
4. **Avatar art**: three new layers in three views plus the rig. Ship pieces with item icons first and the avatar layers later?
5. **Fine = Rare** puts wearables under the 3 Rare cap. If that crowds out legendary crop pieces too much, cap wearables at Lined.
6. **Hat and Pack rest on tags the bots cannot judge.** They need hand play before release, on a phone for the 6-piece hand (still open in the rule book).
7. **Tailor needs a building?** Proposed: none, like Garden supplies.
8. **Overlap with friend pieces**: no wearable repeats a type-and-tag pair from `piece-effects.md`, but Keeper and Plenty appear on both lists. Fine as long as friend pieces stay Uncommon and wearables start Common.
