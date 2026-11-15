# Creature pass SPEC (2.7.00 -> 2.7.01), binding

Owner decisions are final. Every agent follows this file; if it is wrong or silent, ask the lead, do not improvise. Do not edit files you do not own. No git commands (the lead commits). No model name in any file. Scratch goes in the session scratchpad, never /tmp.

Scope: all 88 creatures of `game/includes/data/creatures.txt` (base rows stay, never deleted, slugs unchanged) plus 230 new variants, each a SEPARATE named creature with its own deck, ability, drop table, AI style and region list. New engine effects (8 max), per-species AI style weights (data) with ONE shared scorer, HP policy D. Bugs B1-B3 of `spawn-review.md` sec 5: listed in sec 8, not fixed.

Files:
| file | owner | what |
|---|---|---|
| `claude/creature-pass/SPEC.md` | spec | this file |
| `claude/creature-pass/data/pf_creatures_<A|B|C|D>.txt` | writers A-D | the rows of their batch (sec 4) |
| `game/includes/data/pf_creatures.txt` | lead (merge A,B,C,D in that order; roster order inside) | all 318 rows |
| `game/includes/data/pf_ai_styles.txt` | engine | style table (sec 3) |
| `game/includes/data/pf_creature_tune.txt` | balance | per-creature multipliers (sec 7) |
| `pfboard.php`, `tools/pfengine.js`, `tests/pfengine_js.sh`, `tests/pfboard_v1_abil.php` | engine | sec 2, 3 effects, scorer, parity |

## 1. Data file `pf_creatures.txt`

Pipe-separated, one row per creature or variant. `#` comment lines and blank lines are skipped. No `|`, no tab, no emoji in any cell. 17 columns:

`slug|family|name|size|landscapes|regions|level|cond|ability|ai|deck|drops|petals|exp|art|description|new_items`

| # | column | rule |
|---|---|---|
| 1 | slug | `slugify(name)` for variants (lowercase, `-`), 3-32 chars, unique across `creatures.txt` + this file. Base rows: the existing slug |
| 2 | family | the BASE slug (a base row names itself). A family = base + 2-4 variants |
| 3 | name | Title Case, 1-3 words, unique (case-insensitive) across both files. Base: `=` (keep) |
| 4 | size | small, medium, large, boss, as in the roster (sec 4). Base: `=` |
| 5 | landscapes | comma list or `any`, as in the roster. Base: `=` |
| 6 | regions | comma list of region codes (sec 4.1), or `*` = every region. Variants: never `*`. Base: `*` |
| 7 | level | integer, as in the roster (writer may move it by at most 1, never across a size). Base: `=` |
| 8 | cond | rest-stop syntax `dp=night,dusk/se=winter/we=rain` (soft: 3x likelier when it matches), or `-`. Never a leading `!`. Base: `=` |
| 9 | ability | 1 or 2 ability ids joined by `+`, optional `(k=v;k=v)` parameter override (sec 2). Roster gives the assigned one; the writer keeps it unless the lead approves |
| 10 | ai | a style id of sec 3, optionally `id(feature=val;...)`, at most 2 overrides, each inside the range of sec 3. Roster gives it |
| 11 | deck | the UNIQUE layer, see 1.1. Base: `=` (the 3 rows of `pf_creature_pieces.txt` stay) |
| 12 | drops | see sec 5. Base: `=` or `=+extra,extra` (inherit the old list, append) |
| 13 | petals | `min-max`, integers, from the rule of sec 5.2. Required for every row (no creature gives Petals today) |
| 14 | exp | multiplier of the old XP `round(6 L m)`: `1.0` = unchanged, range 0.8-1.5, rule 5.3 |
| 15 | art | max 8 words: how the picture differs from the base art, e.g. `smaller, grey, long antennae` (art pipeline input; the on-screen tint stays `crc32(slug)`) |
| 16 | description | 1-2 sentences, max 150 chars, tone sec 4.2. Base: `=` |
| 17 | new_items | comma list of drop item names that are NEW (not in the item catalog, sec 5.1), else `-` |

Rules: a base row carries only `=`/`*` in columns 3-8, 11, 16, `-` in 15, and real values in 9, 10, 13, 14, 17 and in 12 (`=` or `=+...`). The old `creatures.txt` row is never edited; the importer (`import_creatures_txt` then the new `import_pf_creatures`) reads it first and this file second. A variant's class (Critter, Bird, Beast, Reptile/Amphibian, Water, Plant/Fungus) is its base's class (`pf_creature_class.txt`); the importer adds the variant slug to the class map. hp/attack/defence/die/bonus come from size + level exactly as `import_creatures_txt` computes them.

### 1.1 Deck column (the unique layer)

A creature's deck is layered (pfdeck.php `pfd_foe_pieces`): class base 4 (`pf_class_base.txt`: 2 Hurt, 1 Guard, 1 class trick) + region layer (small and medium: the region's `other` piece = 1; large and boss: its `hurt` + `other` = 2, `pf_region_pieces.txt`, taken from the region of the fight) + rarity layer (large: 1 `@large` Slam; boss: 2 `@boss` Scheme + Crush) + UNIQUE layer (exactly 3 pieces, this column).

Deck size: small 4+1+0+3 = 8, medium 4+1+0+3 = 8, large 4+2+1+3 = 10, boss 4+2+2+3 = 11. A writer authors only the 3 unique pieces; the other layers are data that already exist.

Syntax: `CLASS/LEAN/piece;piece;piece`
- `CLASS` = `-` (inherit the base's class) for every row. (An override is a lead decision.)
- `LEAN` = the family 3 of the creature's 5 pieces stack in: `body`, `mind`, `craft` (the base's lean is in `pf_creature_pieces.txt` col 2; a variant may change it).
- piece = `Name:type:mult:knob:tag:life`, exactly as the columns of `pf_creature_pieces.txt` (`name|type|v_mult|knob|tag|life`):
  - `type`: hurt guard heal trick. `mult`: x the creature's archetype value (`pfd_foe_v`), 0.05 steps. Typical: hurt 0.6-1.3, guard 0.5-0.8, heal 0.4-0.6, trick 0.3-0.6.
  - `knob`: body, mind, craft (the right edge family). `life`: 2-4 (quick = 2, hold = 4 by convention; others 3).
  - `tag` (creature side, pfight.php `PF_TAGS_V1`): hurt = pierce poison quick trip bash; guard = hold thorns evade; trick = quick evade bash thorns poison trip heal; heal = none; `-` = none. (`keep`, `plenty`, `simmer`, `mend`, `lull`, `hum`, `bond`, `pluck`, `heavy` are player-side only: not for creature pieces.)
- Piece names: 1-3 words, no `:` `;` `|`, unique across `pf_creature_pieces.txt` and every batch (the lint reports collisions; the later batch A<B<C<D renames).

Deck rules (lint):
1. Exactly 3 pieces; at least 1 Hurt and at least 1 non-Hurt.
2. Budget: sum of the 3 `mult` within [lo, hi - 0.08 x cost] of its size (cost = ability cost, sec 2): small 1.5-2.1, medium 1.8-2.6, large 1.9-3.0, boss 2.45-3.2. (The 88 existing rows sit in these bands.)
3. Differs from the base's unique 3 and from every sibling: at least 2 of the 3 pieces differ in (type, tag) pair.
4. It must satisfy the "deck test" of its `D` ability id, if it has one (sec 2.3).
5. The pieces must read as the animal: names are verbs/nouns of what it does (`Dive`, `Mud Slick`), not mechanics.

## 2. Ability catalogue (41 ids)

An ability = one id + one rule text shown on the creature card (`pf_creatures` ability text, max 80 chars). A row has 1 or 2 ids: at most one `E` (it replaces the class rule: `pfb_kind_of`), at most one `N`, any `D`. Cost: E base kinds 0, E variants 1, N tier I 1, N tier II 2, D 0 (its constraint is the deck). Total cost max 3. Small and medium use tier I, large and boss tier II. Every row's ability string must be distinct inside its family, and no two rows that share a landscape and a level window of 8 may have the same ability string.

New engine behaviour is behind one new v1 key `abil` (`PFB_V1_PRE['abil']` = 0 for fights saved before 2.7.01, 1 in new fights; `pfb_v1r($s,'abil')`). The creature row carries `ab` = the id list; pfb_new copies it to `$s['foe']['ab']`. Old fights ignore it. Parameters: `id(k=v;k=v)` overrides a tier's number inside the stated range; an override costs like its nearer tier.

### 2.1 E: class-rule kinds (existing code, `PFB_KIND_*`, `pfb_kind_of`)

| id | name | rule (player text) | cost | state |
|---|---|---|---|---|
| swarm | Swarm | Its Hurt hits +1 for every 2 of its other pieces on board, up to +2 | 0 | exists |
| swarm-dense | Dense Swarm | As Swarm, up to +3 | 1 | `PFB_KIND_SWARM_MAX` param 3 |
| two-aims | Two aims | It shows two cells; take the first and it plays the second | 0 | exists |
| grudge | Grudge | Each block of its aim makes its Hurt 25% harder, up to 3 times; a landed hit clears it | 0 | exists |
| grudge-fury | Fury grudge | +35% a block, up to 2 times | 1 | param |
| grudge-slow | Slow grudge | +15% a block, up to 5 times | 1 | param |
| current | Current | After its piece lands, one of your touching pieces slides 1 cell | 0 | exists |
| current-hard | Strong current | The slide is up to 2 cells (second only if free and on the board) | 1 | param |
| grows | Grows | After its turn a Bramble grows beside its piece (one of its own at a time) | 0 | exists |
| grows-twin | Twin growth | Up to 2 of its own Brambles at a time | 1 | param (`pfb_grow` own-bramble cap 2) |
| venom-trail | Venom trail | A cell where its piece leaves is venom 2 rounds; your piece there poisons you 2 a round | 0 | exists |
| venom-long | Long venom | Venom 3 rounds, poison 1 a round | 1 | param (`PFB_KIND_VENOM_RNDS` 3, `_POISON` 1) |
| two-turns | Two turns | (boss only) It also shows the piece it plays next round; that piece is forced | 0 | exists |

Engine work: E params become fields read from `$s['foe']['abp']` instead of constants (default = the constant); JS twin the same.

### 2.2 N: new engine effects (8; each has tier I / II; PHP in `pfboard.php` + `pf_apply`, JS twin in `tools/pfengine.js`)

Notation: Y = the Yield bar maximum of the fight (`$s['fh']['max']` in one-bar fights); "lands" = HP damage that actually reaches you (after Soothe, after your guard, not Evaded, not poison ticks). All numbers are the default tier; `pct`/`mult` overrides allowed within the range in brackets.

| id (I / II) | name | trigger and exact rule | interaction | player text |
|---|---|---|---|---|
| drain1 / drain2 | Drain | After each of its Hurt pieces fires: `pf_foe_heal(landed x pct)`, pct 0.25 / 0.50 [0.15-0.60]. State: none | Evaded or fully blocked hit lands 0, so heals 0. Heal acts on the Yield bar (Hurt part first, then Charm part: `pf_foe_heal`). Poison ticks do not drain | Drain: a hit that lands heals it by a quarter (half) of the damage |
| plated1 / plated2 | Plated | At the start of each of its turns (`pfb_foe_turn`, after the poison tick) `foe.block = max(foe.block, ceil(Y x pct))`, pct 0.03 / 0.05 [0.02-0.07]. It never grows past that | Your Hurt soaks into it like any guard; Pierce ignores it; it is not Hold (does not carry over; recomputed each turn). Soothe, heal unaffected | Plated: starts each turn with some guard |
| enrage1 / enrage2 | Enrage | Flag `foe.enr` set the first time the Yield bar is at or past `at` of Y (0.50 / 0.40 [0.35-0.70]); from then on its Hurt pieces count x`mult` 1.15 / 1.25 [1.10-1.35] (`pfb_fire`, next to Grudge). Never cleared. Charm fills the bar too, so heavy Charm also triggers it | Applied before Soothe cut and guard. Evade, guard work as usual | Enrage: past half its resolve (40%) its Hurt hits 15% (25%) harder |
| wary1 / wary2 | Wary | Your Charm pieces fill the Yield bar x`mult` 0.85 / 0.75 [0.65-0.92], applied at fire time on top of `cm` and Bond (so Bond cannot undo it). Not on a creature that has no Charm effect | Boss Charm x0.6 stacks. Hum/Lull side effects unchanged | Wary: your Charm fills 15% (25%) less |
| toughhide1 / toughhide2 | Tough hide | The first Hurt piece of YOURS that fires in each of your turns counts `cut` less, 2 / 3 [1-4], min 1, before its guard (`pfb_fire`; flag `me.tough` reset in `pfb_begin('me')`) | Poison ticks, Thorns, Riposte and Bash value are not cut. Pierce still cut (it is value, not guard) | Tough hide: your first Hurt each turn is 2 (3) weaker |
| ambush1 / ambush2 | Ambush | In its FIRST creature turn of the fight only: its first Hurt piece fires x`mult` 1.4 / 1.7 [1.2-2.0]; tier II also ignores your guard (as Pierce) [`pierce` 0/1] | Evade makes it miss (and is used up). A guard that holds still works for tier I. The aim total (`pfb_aim_total`) shows the boosted number | Ambush: its first hit of the fight is 40% (70%) harder |
| stagger1 / stagger2 | Stagger | When one of its Hurt pieces lands at least `pct` of your max HP in one go (0.20 / 0.12 [0.08-0.25]), you draw 1 piece fewer next round (`me.slowdraw = 1`, once a round however many land) | A hit that is blocked or Evaded below the threshold does nothing. Trip on your pieces does not stop it | Stagger: a big hit leaves you one piece short next round |
| regrow1 / regrow2 | Regrow | At the start of each of its turns 1 to `turns` (5 [3-6]) it recovers `pct` of Y (0.02 / 0.03 [0.01-0.04]) via `pf_foe_heal`, after the poison tick. Max total 10% / 15% of Y | Skipped turns (Trip, Lull) still regrow. Heals the Hurt part first, then the Charm part | Regrow: heals a little each turn at the start of a fight |

State keys (new, skipped by the parity compare unless listed in the test): `foe.ab` (list), `foe.abp` (params by id), `foe.enr`, `foe.turns` (its turns so far), `me.tough`. Event tags for the replay: `drain`, `stagger`, `regrow`, `plated` as `pfb_note` kinds (page chips: engine agent adds the chips; text as above). Tests (engine agent): `tests/pfboard_v1_abil.php`, one property test per effect (each fails on the 2.7.00 engine), parity (`tests/pfengine_js.sh`) gains fights with each ability; the balanced AI style must give bit-identical fights to 2.7.00 (sec 3).

### 2.3 D: deck-signature abilities (no engine work; the deck column must satisfy the test)

| id | name | deck test (3 unique pieces) | player text |
|---|---|---|---|
| D1 | Sharp | >= 2 Hurt with tag pierce | Sharp: its hits go through guard |
| D2 | Venom spit | >= 2 pieces with tag poison | Venom spit: its hits keep working |
| D3 | Snare | >= 2 pieces with tag trip | Snare: it makes you lose pieces |
| D4 | Flurry | >= 2 pieces with tag quick | Flurry: it often plays twice |
| D5 | Ram | >= 1 Hurt with tag bash and >= 1 trick with tag bash | Ram: its guard becomes damage |
| D6 | Shell | >= 2 Guard with tag hold | Shell: its guard lasts |
| D7 | Prickles | >= 2 Guard with tag thorns | Prickles: blocked hits prick you |
| D8 | Slip | >= 2 pieces with tag evade | Slip: it dodges your first hits |
| D9 | Mender | >= 2 pieces of type heal | Mender: it heals itself |
| D10 | Bruiser | >= 2 Hurt, Hurt mult sum >= 55% of the size's budget hi (small 1.15, medium 1.4, large 1.65, boss 1.75) | Bruiser: heavy hits |
| D11 | Wall | >= 2 Guard, Guard mult sum >= 1.2 | Wall: lots of guard |
| D12 | Mixed | exactly 1 Hurt, 1 Guard, 1 trick or heal, each with a tag other than `-` | Mixed: a bit of everything |

Total ids: 13 E + 16 N + 12 D = 41. Pairing used in the roster: E variants with N tier, D with N tier; two-turns only for boss-size rows.

## 3. AI: one shared scorer, per-species style weights

Creature play today: `pfb_search` tries every creature hand piece in every legal cell on a copy and keeps the best `pfb_score($before,$after,'foe')`; ties go to the first found; the aim, Two aims and the boss committed piece (`$onlyK`) go through the same search. New: the score becomes a dot product of FEATURES with a per-creature WEIGHT VECTOR (style). The shared scorer stays one function `pfb_score`; a creature without a style, and style `balanced`, give the 2.7.00 score exactly (bit-identical fights: test).

### 3.1 Scorer inputs available in pfboard.php (before `$b` and after `$a` states, both fully built copies)

Bars: `bar.now/max/charm`, `fh.now/max` (Yield), `hm`, `cm`. You: `me.hp/max/block/evade/thorns/poison/poison_v/slowdraw/keep/hand`. Creature: `foe.block/evade/thorns/bashnext/again/slow/agg/poison/poison_v/grudge/plan/hand/draw/discard`. Board: `pcs` (id, by, tile, x, y, born, f fires), `cell` map, `ter` map, `round`, `over`, env pieces and `pfb_env_bias`. Helpers: `pfb_cells($s,$tile,$who)` (legal cells), `pfb_check`, `pfb_links`, `pfb_chain`, `pfb_life`, `pfb_ter`, `pfb_mud_near`, `pfb_foe_len`.

### 3.2 Features (after minus before, one placement; `u` = 0.05 x `me.max` HP)

| key | definition | in 2.7.00 as |
|---|---|---|
| dmg | HP you lose = `b.me.hp - a.me.hp` | `-hpD` |
| bar | rise of the Yield bar = `barD` (creature hurt or charmed; negative = it recovered) | `-0.8 x barD` |
| heal | `max(0, -barD)` extra reward for recovering | none (0) |
| guard | change of its own guard `a.foe.block - b.foe.block` | 0.4 |
| strip | `-(a.me.block - b.me.block)`: your guard removed | 0.3 |
| setup | `(pz(a)-pz(b)) + u x (1.5 dEvade + 0.6 dThorns + 1.0 dBashnext)`: poison waiting on you, its Evade, Thorns, Bash lent | the `tg` term (part) |
| tempo | `u x (1.0 dSlowdraw + 1.5 dAgain)`: your fewer draw, its extra piece | the `tg` term (part) |
| control | `u x` (its pieces on board after - before), counted to at most 4 pieces | new |
| deny | `0.1 x me.max x (reach_b - reach_a) / max(1, reach_b)`; reach = the number of distinct empty cells where at least one of YOUR hand pieces may legally be placed | new (costly: computed only when the weight is not 0) |
| force | `0.1 x me.max x` share of your legal (hand piece, cell) pairs after that link to at least one of its Hurt pieces | new (computed only when the weight is not 0) |

`pfb_score(foe) = w.dmg*dmg + w.bar*barD + w.heal*heal + w.guard*guard + w.strip*strip + w.setup*setup + w.tempo*tempo + w.control*control + w.deny*deny + w.force*force + (defeat ? 50 : 0)`. `ramp`: the dmg weight is multiplied by `early` on its turns 1-2 and by `late` from turn 3 (`foe.turns`). The player-side branch (`$who==='me'`, used by bots) is unchanged. The aim intent uses the same weights.

### 3.3 Style table `data/pf_ai_styles.txt`

`id|dmg|bar|heal|guard|strip|setup|tempo|control|deny|force|early|late|text`. A creature picks a style (sec 1, col 10); `id(feature=val)` overrides one or two weights; each weight must stay within -2.5..2.5.

| id | dmg | bar | heal | guard | strip | setup | tempo | control | deny | force | early | late | play style |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| balanced | 1.0 | -0.8 | 0 | 0.4 | 0.3 | 1.0 | 1.0 | 0 | 0 | 0 | 1 | 1 | the 2.7.00 scorer (default) |
| crowd | 0.8 | -0.6 | 0 | 0.2 | 0.2 | 0.6 | 0.8 | 1.2 | 1.0 | 0.8 | 1 | 1 | fills the board, shrinks your cells |
| blocker | 0.6 | -0.8 | 0 | 1.0 | 0.6 | 0.8 | 0.6 | 0.3 | 1.2 | 0.2 | 1 | 1 | sits where you want to place, strips your guard |
| burst | 1.5 | -0.5 | 0 | 0.1 | 0.1 | 0.3 | 0.5 | 0 | 0 | 1.0 | 1.6 | 0.8 | biggest hit now, forces you into its pieces |
| stall | 0.5 | -1.0 | 0.3 | 0.8 | 0.5 | 1.0 | 2.0 | 0.2 | 0.6 | 0 | 0.6 | 1.0 | delays: your short draw, its extra piece, guard |
| healer | 0.7 | -1.0 | 1.2 | 0.5 | 0.3 | 0.6 | 0.6 | 0 | 0 | 0 | 1 | 1 | prefers recovering, trades slowly |
| trickster | 0.8 | -0.8 | 0 | 0.3 | 0.3 | 1.8 | 1.8 | 0.2 | 0.4 | 0.2 | 1 | 1 | Trip, Evade, Bash set-ups before damage |
| poisoner | 0.9 | -0.8 | 0 | 0.3 | 0.2 | 2.0 | 1.0 | 0.3 | 0 | 0.3 | 1 | 1 | poison and long set-ups first |
| guardian | 0.5 | -0.9 | 0.4 | 1.5 | 0.8 | 0.8 | 0.5 | 0.1 | 0.6 | 0 | 1 | 1 | big guard, Thorns/Hold, slow trades |
| ambusher | 0.9 | -0.7 | 0 | 0.2 | 0.1 | 0.8 | 0.6 | 0.4 | 0.2 | 1.2 | 0.4 | 1.6 | quiet first turns, then hits hard |

Class default (base rows): Critter crowd, Bird ambusher, Beast burst, Reptile/Amphibian poisoner, Water trickster, Plant/Fungus stall, boss balanced. A family's rows (base + variants) have pairwise different styles. Engine work: `pfb_score` reads `$s['foe']['ai']` (14 numbers); `pfb_new` loads it from the creature row; JS twin `PFB_AI`; tests: balanced == old score on the 352 parity fights, each style plays a legal full fight, and `pfboard_sim.sh` invariants hold for every style on all 318 creatures.

## 4. Names, tone, regions, roster

### 4.1 Regions (column 6)

Region code, region level, lands (`+land` = explore only). A variant's `regions` must list only regions that have one of its landscapes. The picker rule is `creature level in [walk level - 6, walk level + 2]`, so a region R fits a row of level Lv when `Lv-2 <= R <= Lv+6`; the roster below already applies it, siblings that share a landscape and a level window of 8 get disjoint regions where the data allows (otherwise their conds must differ: 7 pairs), and rows above L35 sit in SEA, WCA, ESA, OC (they always walk at gnome level). Engine: `pick_creature(land, level, region)` filters `regions` (`*` always passes); region = the destination region code of the walk (Trek and lair pools unchanged).

| code | name | level | lands |
|---|---|---|---|
| NA | The Maplewold | 1 | grassland forest coast tundra +mountain +wetland |
| CA | Maizehollow | 4 | grassland rainforest desert mountain |
| NWE | Mistmoor | 6 | grassland forest coast tundra +mountain +wetland |
| CB | Sunsprinkle Isles | 8 | island coast rainforest wetland +forest |
| SE | Olivewhistle Shore | 10 | coast mountain island +forest |
| SA | Rainroot Reaches | 12 | grassland mountain rainforest desert |
| EE | Birchbramble Steppe | 14 | grassland forest wetland mountain +tundra |
| MENA | The Dunewhisper | 17 | coast grassland mountain desert |
| EA | Blossomreach | 20 | grassland forest coast desert +mountain +wetland |
| CSA | Spicepeak | 23 | wetland grassland forest mountain |
| SEA | Monsoon Tangle | 26 | wetland coast island rainforest |
| WCA | The Greatcanopy | 29 | grassland wetland rainforest coast +forest |
| ESA | Thornacre Savanna | 32 | grassland mountain wetland desert |
| OC | The Coralscatter | 35 | island coast forest desert +mountain +rainforest |

### 4.2 Naming and tone

- Variant name: Title Case, 1-3 words, a real or plausible small-world animal or a plain collective (Swarm, Flock, Pack, Crew, Troop, Covey, Herd, Colony, Brood). Never reuse a base name. The roster gives the name; keep it. The slug is the slugified name.
- Tone as the old rows: the world is gnome-sized, dry, kind, a little rude about gnomes. British spelling (armour, grey, colour). No emoji, no brands, no real people, no modern slang, no model names, no "you must".
- Description: 1-2 sentences, max 150 chars, present tense, says what makes THIS variant different from its base (habit, look, a danger the deck shows). Do not repeat the ability text. No game numbers.
- Piece names (deck): the animal doing something (`Mud Slick`, `Tail Whip`), 1-3 words.
- Drop item names: Title Case; a part of the animal or a thing it carries (`Spiral Shell`, `Gull Feather`), singular.
- `art`: what to change from the base picture, max 8 words.
- Everything in plain ASCII except the existing apostrophe/hyphen style (`Will-o'-Wisp`).

### 4.3 Roster plan per land (counts of variants, tier A first)

Tier A (55 rows) fills a measured gap with the current picker (spawn-review sec 4.1 G1-G10); tier B (163) is variety and only works because of the `regions` filter; tier X (12) are extra tundra and island rows (G4, G5, G6: tundra L1-3 small, L4-16, island L5-31, plus rows that give the creatures with no tundra host a low-level kin). Write tier A rows of your batch first, then X, then B.

| first landscape | A | B | X | total variants |
|---|---|---|---|---|
| coast | 9 | 16 | 0 | 25 |
| desert | 5 | 22 | 0 | 27 |
| forest | 5 | 18 | 0 | 23 |
| grassland | 10 | 21 | 0 | 31 |
| island | 2 | 10 | 6 | 18 |
| mountain | 4 | 22 | 0 | 26 |
| rainforest | 6 | 21 | 0 | 27 |
| tundra | 6 | 11 | 6 | 23 |
| wetland | 8 | 22 | 0 | 30 |
| all | 55 | 163 | 12 | 230 |

Base creatures stay as they are (rows of `creatures.txt`); they get a base row in the batch files (ability, ai, drops, petals, exp only). Every family has 2 or 3 variants (230 over 88 families; tier X rows raised 12 families from 2 to 3). Row total 318 (88 base + 230 variants).

### 4.4 Batches and rows

Rule: small and medium rows by FIRST landscape (`any` counts as forest/grassland/wetland); large rows by level; bosses and boss-size rows in D.
- **A**: small + medium rows whose first landscape is forest, grassland, wetland or any (84 rows)
- **B**: small + medium rows whose first landscape is coast, island, desert, mountain, tundra, rainforest (130 rows). If run by two writers: B1 = coast, island, desert (files `pf_creatures_B1.txt`), B2 = mountain, tundra, rainforest (`..._B2.txt`); the lead merges B1 then B2.
- **C**: large rows with level <= 28 (46 rows)
- **D**: large rows with level >= 29, all 9 boss bases and boss-size variants (58 rows)

Roster line: `slug|name|size|landscapes|level|cond|tier|regions|ability|ai` (`=` in name/cond/regions means base row: keep). The ability and ai are ASSIGNED and binding (every family has distinct values; changing one needs the lead). A row's other 7 columns of sec 1 are the writer's job. Within a batch file, keep roster order; one row per line; add `#` comment lines freely.

#### Batch A (84 rows)

```
aphid-swarm|=|S|any|1|=|base|*|swarm|crowd
fly-swarm|Fly Swarm|S|grassland,wetland|12|we=heat,sun|A|SA,EE,MENA|swarm-dense+D2|burst
mite-swarm|Mite Swarm|S|forest,mountain|15|-|B|EE,MENA,EA|venom-long+D4|poisoner
garden-snail|=|S|forest,grassland,wetland,coast|1|=|base|*|swarm|crowd
ramshorn-pond-snail|Ramshorn Pond Snail|S|wetland|10|we=rain|B|CB,EE|drain1|healer
ant-scouts|=|S|any|2|=|base|*|swarm|crowd
carpenter-ant-gang|Carpenter Ant Gang|S|forest|28|-|B|WCA|swarm-dense+wary1|stall
gnat-cloud|=|S|wetland,rainforest|2|=|base|*|swarm|crowd
midge-cloud|Midge Cloud|S|wetland,mountain|11|se=summer|A|SE,SA,EE|swarm-dense+plated1|guardian
leopard-slug|=|S|forest,wetland,rainforest|2|=|base|*|swarm|crowd
ghost-slug|Ghost Slug|M|forest,mountain|19|dp=night|B|MENA,EA,CSA|drain1|healer
dusk-moth|=|S|forest,grassland,mountain|3|=|base|*|swarm|crowd
dawn-skipper-flutter|Dawn Skipper Flutter|S|grassland,mountain|17|dp=dawn|B|MENA,EA,CSA|D3|trickster
luna-moth|Luna Moth|M|forest,rainforest|30|dp=night|B|WCA,OC|D8|blocker
dung-beetle|=|S|grassland,desert|3|=|base|*|swarm|crowd
carrion-beetle-crew|Carrion Beetle Crew|S|grassland,forest|21|se=autumn|B|EA,CSA|regrow1|healer
tumblebug-troupe|Tumblebug Troupe|S|grassland|33|we=wind|B|ESA|swarm-dense+D12|balanced
earwig|=|S|forest,grassland,wetland|4|=|base|*|swarm|crowd
earwig-matron|Earwig Matron|M|wetland,forest|28|-|B|SEA,WCA,ESA|drain1|healer
firefly-flicker|Firefly Flicker|S|grassland,wetland|15|dp=dusk,night/se=summer|B|EE,MENA,EA|swarm-dense+D4|burst
orb-spider|=|M|any|5|=|base|*|swarm|crowd
fishing-spider|Fishing Spider|M|wetland,coast|11|-|B|SE,EE,MENA|swarm-dense+wary1|stall
paper-wasp|=|M|grassland,forest,desert|6|=|base|*|swarm|crowd
hornet-sentry|Hornet Sentry|M|forest,grassland|24|se=summer,autumn|B|CSA,WCA|regrow1|healer
yellowjacket-mob|Yellowjacket Mob|S|grassland,mountain|30|se=autumn|A|ESA,OC|swarm-dense+D12|balanced
bog-leech|=|M|wetland|6|=|base|*|current|trickster
giant-mire-leech|Giant Mire Leech|M|wetland|33|we=rain|B|ESA|D3|blocker
bullfrog|=|M|wetland,rainforest|7|=|base|*|venom-trail|poisoner
cane-toad|Cane Toad|M|grassland,wetland|19|dp=night|B|MENA,EA,CSA|venom-long+D8|trickster
fiddler-crab-band|Fiddler Crab Band|S|wetland,coast|16|dp=dawn,dusk|B|EE,MENA,EA|current-hard+D12|balanced
barn-rat|=|M|grassland,forest,coast|8|=|base|*|grudge|burst
marsh-rat|Marsh Rat|M|wetland|21|-|B|EA,CSA,SEA|grudge-slow+enrage1|blocker
tunnel-mole|=|M|grassland,forest|9|=|base|*|grudge|burst
star-nosed-mole|Star-nosed Mole|M|wetland|12|-|B|EE|plated1|guardian
mole-rat-gang|Mole-rat Gang|M|grassland|31|-|B|WCA,ESA|drain1|crowd
carrion-crow|=|M|grassland,forest,mountain|9|=|base|*|two-aims|ambusher
magpie-mob|Magpie Mob|M|grassland|17|dp=dawn,day|B|MENA,EA,CSA|D12|balanced
thistle-beast|=|M|grassland,mountain|12|=|base|*|grows|stall
nettle-lurker|Nettle Lurker|M|forest,wetland|14|se=spring,summer|B|EE,EA|grows-twin+D7|guardian
bombardier-beetle|Bombardier Beetle|M|grassland,forest|27|-|A|WCA,ESA|drain1|healer
will-o-wisp|=|M|wetland|13|=|base|*|grows|stall
marsh-spark-swarm|Marsh Spark Swarm|S|wetland|22|dp=night|B|EA,CSA,SEA|D6|guardian
foxfire-wisp|Foxfire Wisp|M|forest|32|dp=night|B|OC|D12|balanced
smooth-snake|Smooth Snake|M|grassland|22|we=sun|B|EA,CSA|venom-long+stagger1|trickster
water-snake|Water Snake|M|wetland,coast|26|-|B|SEA,WCA,ESA|toughhide1|blocker
night-heron|Night Heron|M|wetland,coast|22|dp=night,dusk|B|EA,CSA,SEA|ambush1|burst
egret-flock|Egret Flock|M|grassland,wetland|25|se=spring,summer|A|WCA|D1|balanced
macaque-troop|Macaque Troop|M|forest,mountain|20|-|B|EA,CSA|D5|blocker
tanuki|Tanuki|M|forest,grassland|21|dp=night,dusk|B|EA,CSA|stagger1|trickster
burrowing-owl|Burrowing Owl|M|grassland,desert|20|dp=dawn,dusk|B|EA,CSA|D1|balanced
badger-cub-gang|Badger Cub Gang|M|grassland|13|dp=dusk,night|B|SA,EE,MENA|plated1|guardian
natterjack-chorus|Natterjack Chorus|S|wetland,coast|17|dp=dusk,night|A|MENA,EA,CSA|venom-long+stagger1|trickster
mud-crab-brawler|Mud Crab Brawler|M|wetland,coast|28|-|B|SEA,WCA,ESA|current-hard+regrow1|healer
bramble-pup-pack|Bramble Pup Pack|M|forest|18|-|B|EA,CSA|plated1|guardian
thorn-jackal|Thorn Jackal|M|grassland,desert|23|dp=dusk,night|A|CSA,WCA|grudge-fury+regrow1|healer
kestrel-hoverer|Kestrel Hoverer|M|grassland,mountain|15|we=wind|B|EE,MENA,EA|ambush1|ambusher
snapper-hatchling-bask|Snapper Hatchling Bask|M|wetland|9|we=sun|B|CB,EE|venom-long+ambush1|ambusher
roebuck|Roebuck|M|forest,mountain|15|se=autumn|B|EE,MENA,EA|grows-twin+toughhide1|blocker
croc-hatchling-scatter|Croc Hatchling Scatter|S|wetland,coast|27|-|A|SEA,WCA,ESA|venom-long+D2|stall
fishing-cat|Fishing Cat|M|wetland,rainforest|29|dp=night|A|WCA,ESA,OC|plated1|guardian
tree-monitor|Tree Monitor|M|forest,island|31|-|A|WCA,OC|venom-long+stagger1|trickster
water-monitor|Water Monitor|M|wetland,coast|33|-|B|ESA,OC|toughhide1|blocker
savanna-hyena|=|M|grassland|29|=|base|*|grudge|burst
hyena-pup-cackle|Hyena Pup Cackle|S|grassland|26|dp=night|B|WCA,ESA|grudge-fury+enrage1|ambusher
mangrove-crab-court|Mangrove Crab Court|S|wetland,coast|32|-|A|ESA,OC|toughhide1|blocker
zorilla-stink-squad|Zorilla Stink Squad|S|grassland,desert|35|dp=night|A|OC|grudge-fury+toughhide1|ambusher
ratel-pair|Ratel Pair|M|grassland|38|-|B|WCA,ESA|grudge-slow+enrage1|blocker
cassowary-chick-creche|Cassowary Chick Creche|S|forest,rainforest|33|-|A|OC|ambush1|burst
emu-mob|Emu Mob|M|grassland,forest|38|-|B|ESA|D1|balanced
river-otter|River Otter|M|wetland,forest|17|-|B|EA,CSA|current-hard+D12|balanced
night-adder|Night Adder|M|grassland,desert|34|dp=night|B|ESA,OC|venom-long+D1|burst
termite-column|Termite Column|M|grassland,desert|19|-|A|MENA,EA,CSA|swarm-dense+plated1|guardian
stickleback-shoal|Stickleback Shoal|S|wetland|16|se=spring|B|EE,EA|current-hard+D3|crowd
fisher|Fisher|M|forest,mountain|28|-|B|WCA,ESA|grudge-slow+enrage1|blocker
piglet-squeal|Piglet Squeal|S|forest,grassland|14|se=spring|A|SA,EE,MENA|grudge-fury+enrage1|ambusher
warthog|Warthog|M|grassland|34|-|B|ESA|D5|blocker
muskrat-crew|Muskrat Crew|M|wetland|10|-|B|CB,EE|grudge-slow+D11|blocker
capybara-herd|Capybara Herd|M|wetland,grassland|30|-|B|WCA,ESA|stagger1|trickster
pangolin|Pangolin|M|grassland,forest|32|dp=night|B|ESA,OC|grudge-slow+enrage1|blocker
honeybee-swarm|Honeybee Swarm|S|grassland,forest|17|se=spring,summer|B|MENA,EA,CSA|swarm-dense+D4|burst
wildcat|Wildcat|M|forest,grassland|26|dp=dusk,night|B|WCA,ESA|plated1|guardian
turkey-vulture|Turkey Vulture|M|grassland,desert|21|dp=day|B|EA,CSA|D8|trickster
bear-cub-tumble|Bear Cub Tumble|M|forest,mountain|20|se=spring|B|EA,CSA|plated1|guardian
bison-calf-stampede|Bison Calf Stampede|M|grassland|25|-|B|CSA,WCA|grudge-fury+enrage1|ambusher
```

#### Batch B (130 rows)

```
snow-flea-swarm|Snow Flea Swarm|S|tundra|2|we=snow,frost|B|NA,NWE|drain1|healer
dune-snail|Dune Snail|S|desert,coast|9|dp=dawn|A|CB,SE,SA|swarm-dense+D4|burst
giant-banded-snail|Giant Banded Snail|M|rainforest,island|20|we=rain,fog|B|SEA|swarm-dense+stagger1|trickster
fire-ant-raiders|Fire Ant Raiders|S|desert,grassland|18|we=heat,sun|A|MENA,EA,CSA|D3|trickster
army-ant-column|Army Ant Column|M|rainforest|31|-|B|WCA,OC|D8|blocker
sandfly-cloud|Sandfly Cloud|S|coast,island|14|dp=dawn,dusk|A|MENA,EA|regrow1|healer
mosquito-storm|Mosquito Storm|S|rainforest,wetland|31|we=rain,storm|B|WCA,ESA,OC|swarm-dense+D12|balanced
banana-slug|Banana Slug|S|rainforest|13|we=rain,fog|B|SA|swarm-dense+D2|burst
sea-slug-drift|Sea Slug Drift|S|island,coast|5|we=fog,rain|A|NWE,CB,SE|venom-long+D4|poisoner
sand-fleas|=|S|coast,island,desert|3|=|base|*|swarm|crowd
kelp-fly-swarm|Kelp Fly Swarm|S|coast|21|we=sun,heat|B|EA,SEA|swarm-dense+D4|burst
beach-hopper-horde|Beach Hopper Horde|S|island|25|dp=dusk,night|A|SEA|drain1|healer
salt-mite-swarm|Salt Mite Swarm|S|desert|22|we=wind|A|EA|swarm-dense+stagger1|trickster
snow-moth|Snow Moth|S|tundra,mountain|9|we=snow,frost|A|SE,SA,EE|swarm-dense+wary1|stall
scarab-roller|Scarab Roller|M|desert|18|dp=dawn,day|B|MENA,EA|swarm-dense+plated1|guardian
rock-earwig|Rock Earwig|S|mountain|6|-|B|CA,NWE,SE|swarm-dense+D2|burst
shore-earwig|Shore Earwig|S|coast,island|9|dp=night|B|CB,SE|venom-long+D4|poisoner
cave-glowworm|=|S|mountain,rainforest|5|=|base|*|swarm|crowd
glow-grub-cluster|Glow Grub Cluster|S|rainforest,forest|24|dp=night|B|CSA,SEA,WCA|drain1|healer
lantern-glowworm-queen|Lantern Glowworm Queen|M|mountain|34|dp=night|B|ESA,OC|swarm-dense+stagger1|trickster
jumping-spider|Jumping Spider|S|mountain,desert|7|dp=day|B|NWE,SE,SA|D3|trickster
golden-orb-weaver|Golden Orb Weaver|M|rainforest,island|23|-|A|SEA,WCA|D8|blocker
mud-dauber|Mud Dauber|M|desert,mountain|14|we=sun,heat|B|SA,EE,MENA|swarm-dense+plated1|guardian
tiger-leech|Tiger Leech|M|rainforest|10|we=rain|B|CB,SA|current-hard+plated1|crowd
saltmarsh-leech|Saltmarsh Leech|M|coast,wetland|18|we=fog,rain|B|MENA,EA,CSA|current-hard+regrow1|healer
grumpy-lemming|=|M|tundra|6|=|base|*|grudge|burst
lemming-kit-scurry|Lemming Kit Scurry|S|tundra|1|-|A|NA,NWE|grudge-fury+enrage1|ambusher
pika-sentry|Pika Sentry|M|mountain|8|-|B|NWE,SE,SA|D5|blocker
marmot-bruiser|Marmot Bruiser|M|mountain,grassland|22|se=summer|B|EA,CSA|grudge-slow+D10|crowd
tree-frog-chorus|Tree Frog Chorus|S|rainforest,island|9|we=rain|A|CB,SE,SA|drain1|healer
shore-crab|=|M|coast,island|7|=|base|*|current|trickster
ghost-crab|Ghost Crab|M|coast,island|17|dp=night|B|MENA,EA|stagger1|burst
land-crab-march|Land Crab March|M|island,rainforest|24|we=rain|B|SEA,WCA|current-hard+D6|guardian
pack-rat|Pack Rat|M|desert,mountain|16|dp=night|B|EE,MENA,EA|grudge-fury+toughhide1|ambusher
ship-rat-crew|Ship Rat Crew|M|coast,island|28|dp=night|B|SEA,WCA|D5|crowd
sun-lizard|=|M|desert,grassland,rainforest|8|=|base|*|venom-trail|poisoner
rock-agama|Rock Agama|M|mountain|5|we=sun,heat|B|CA,NWE,SE|venom-long+ambush1|ambusher
basilisk-runner|Basilisk Runner|M|rainforest,wetland|21|-|B|EA,CSA,SEA|regrow1|healer
frilled-lizard|Frilled Lizard|M|desert,forest|33|we=heat,sun|B|ESA,OC|venom-long+plated1|guardian
golden-mole|Golden Mole|M|desert|26|dp=night|B|ESA|grudge-fury+regrow1|healer
raven-pair|Raven Pair|M|mountain|13|we=wind|B|SA,EE,MENA|toughhide1|blocker
jungle-crow|Jungle Crow|M|rainforest,coast|32|-|B|OC|regrow1|healer
herring-gull|=|M|coast,island|10|=|base|*|two-aims|ambusher
tern-squadron|Tern Squadron|M|coast,island|18|we=wind|A|MENA,EA|ambush1|burst
skua-raider|Skua Raider|M|coast,tundra|20|se=summer|B|SEA|D1|balanced
dune-scorpion|=|M|desert|10|=|base|*|swarm|crowd
bark-scorpion|Bark Scorpion|M|rainforest|19|dp=night|B|SEA,WCA|swarm-dense+D4|burst
whip-scorpion|Whip Scorpion|M|desert|22|dp=night|B|EA|drain1|healer
frost-hare|=|M|tundra,mountain|11|=|base|*|grudge|burst
snowshoe-leveret-dash|Snowshoe Leveret Dash|S|tundra|3|we=snow,frost|A|NA,NWE|plated1|guardian
mountain-hare|Mountain Hare|M|mountain,grassland|20|se=spring|B|EA,CSA|grudge-fury+regrow1|healer
jackrabbit|Jackrabbit|M|desert,grassland|25|dp=dawn,dusk|B|WCA|drain1|crowd
giant-centipede|=|M|rainforest,forest|11|=|base|*|swarm|crowd
house-centipede-skitter|House Centipede Skitter|S|mountain,desert|10|dp=night|B|SE,SA,EE|swarm-dense+plated1|guardian
cave-centipede|Cave Centipede|M|mountain|30|dp=night|B|ESA,OC|regrow1|healer
giant-millipede|Giant Millipede|M|rainforest,forest|34|we=rain|A|OC|swarm-dense+D12|balanced
cactus-beast|Cactus Beast|M|desert|19|we=heat,sun|B|MENA,EA|grows-twin+regrow1|healer
ember-beetle|=|M|desert,mountain|12|=|base|*|swarm|crowd
frost-beetle|Frost Beetle|M|tundra|12|we=snow,frost|B|EE|swarm-dense+D4|burst
lava-beetle|Lava Beetle|M|mountain,desert|38|we=heat|A|ESA,OC|swarm-dense+stagger1|trickster
storm-wisp|Storm Wisp|M|coast,island|24|we=storm|A|SEA,WCA|grows-twin+drain1|healer
tree-snake|Tree Snake|M|rainforest,island|28|-|A|SEA,WCA|venom-long+wary1|stall
capuchin-pickpocket|Capuchin Pickpocket|M|rainforest|12|dp=day|B|SA|grudge-fury+enrage1|ambusher
fox-kit-pair|Fox Kit Pair|M|tundra,mountain|10|se=spring|A|SE,SA,EE|plated1|guardian
fennec|Fennec|M|desert|17|dp=night|B|MENA,EA|grudge-fury+regrow1|healer
coati-band|Coati Band|M|rainforest|19|dp=day|B|SEA,WCA|grudge-slow+D11|blocker
snowy-owl-scout|Snowy Owl Scout|M|tundra|14|dp=night|B|EE|ambush1|burst
arctic-fox-kit|Arctic Fox Kit|M|tundra|5|se=summer|B|NWE|grudge-fury+enrage1|ambusher
whiteout-fox|Whiteout Fox|M|tundra|13|we=snow,fog|X|EE|grudge-slow+D10|crowd
stink-badger|Stink Badger|M|rainforest,island|26|dp=night|B|SEA,WCA|grudge-fury+regrow1|healer
desert-spadefoot|Desert Spadefoot|M|desert|21|we=rain,storm|B|EA|toughhide1|blocker
tide-crab-squire|Tide Crab Squire|M|coast,island|14|-|A|MENA,EA|current-hard+plated1|crowd
palm-thief-crab|Palm Thief Crab|M|island|18|dp=dusk|X|SE|current-hard+D6|guardian
sandfish-skink-shoal|Sandfish Skink Shoal|S|desert|14|we=heat,sun|A|SA,MENA,EA|venom-long+D2|poisoner
snow-owl-fledgling|Snow Owl Fledgling|M|tundra,mountain|27|dp=night|B|ESA|enrage1|burst
gyrfalcon|Gyrfalcon|M|tundra,mountain|16|we=wind|X|MENA,EA|stagger1|crowd
mountain-buzzard|Mountain Buzzard|M|mountain,grassland|26|we=wind|B|WCA,ESA|D10|burst
ocelot|Ocelot|M|rainforest,forest|23|dp=night,dusk|B|CSA,SEA,WCA|grudge-slow+D11|blocker
jaguarundi|Jaguarundi|M|rainforest,grassland|35|-|A|OC|stagger1|trickster
vine-snake|Vine Snake|M|rainforest,forest|30|-|B|WCA,OC|venom-long+ambush1|ambusher
spice-monitor|=|M|rainforest,island,coast|27|=|base|*|venom-trail|poisoner
komodo-pup|Komodo Pup|M|island,coast|21|we=heat|X|EA,SEA|venom-long+wary1|stall
snow-leopard-cub|Snow Leopard Cub|M|mountain,tundra|23|we=snow,frost|B|CSA|grudge-fury+toughhide1|ambusher
striped-hyena|Striped Hyena|M|desert,mountain|33|dp=night|A|ESA,OC|D5|blocker
mudskipper-troop|Mudskipper Troop|S|island,wetland|20|we=rain|X|EA,CSA,SEA|wary1|stall
horned-viper|Horned Viper|M|desert|29|dp=dusk,night|B|ESA,OC|venom-long+stagger1|trickster
rock-viper|Rock Viper|M|mountain|36|we=sun|B|OC|toughhide1|blocker
yak-calf-herd|Yak Calf Herd|M|mountain,grassland|31|-|B|WCA,ESA,OC|grudge-fury+enrage1|ambusher
garden-eel-colony|Garden Eel Colony|S|coast,island|30|-|A|WCA,OC|toughhide1|blocker
outback-dingo|=|M|desert,grassland|35|=|base|*|grudge|burst
dingo-pup-pack|Dingo Pup Pack|S|desert,grassland|37|dp=dawn,dusk|B|OC|grudge-slow+D11|blocker
blue-ring-octopus|Blue-ring Octopus|S|coast,island|36|-|A|OC|current-hard+D3|crowd
hermit-crab-hoarder|=|M|island,coast|12|=|base|*|current|trickster
hermit-crab-convoy|Hermit Crab Convoy|S|island,coast|7|-|B|NWE,CB,SE|toughhide1|blocker
coconut-hermit|Coconut Hermit|M|island,rainforest|27|dp=night|B|SEA,WCA|current-hard+drain1|healer
rock-crab-pincher|Rock Crab Pincher|M|island|19|-|X|SE|wary1|stall
sea-otter-bandit|=|M|coast|13|=|base|*|current|trickster
dust-sidewinder|=|M|desert|15|=|base|*|venom-trail|poisoner
dune-racer|Dune Racer|M|desert,coast|24|we=heat,sun|B|SEA,WCA|venom-long+D2|stall
poison-dart-frog|=|M|rainforest,wetland|16|=|base|*|venom-trail|poisoner
glass-frog|Glass Frog|S|rainforest|18|dp=night|A|SA,SEA|venom-long+ambush1|ambusher
golden-mantella|Golden Mantella|M|rainforest,island|29|we=rain|B|WCA,OC|regrow1|healer
turtle-hatchling-dash|Turtle Hatchling Dash|S|island,coast|10|dp=night|B|CB,SE|drain1|healer
sea-urchin-bed|Sea Urchin Bed|S|island,coast|12|dp=day|X|MENA|D12|balanced
leafcutter-column|=|M|rainforest|17|=|base|*|swarm|crowd
weaver-ant-nest|Weaver Ant Nest|S|rainforest,forest|26|-|B|SEA,WCA|regrow1|healer
ptarmigan-flock|=|M|tundra,mountain|18|=|base|*|two-aims|ambusher
snow-bunting-flurry|Snow Bunting Flurry|S|tundra,mountain|8|se=winter|B|NWE,SE,SA|ambush1|burst
rock-partridge-covey|Rock Partridge Covey|M|mountain,desert|29|-|A|ESA,OC|D1|balanced
willow-grouse-covey|Willow Grouse Covey|S|tundra|7|se=autumn|X|NWE|D4|crowd
garfish|Garfish|M|coast,wetland|34|-|A|ESA,OC|D11|blocker
thorny-devil|Thorny Devil|S|desert|19|we=heat,sun|B|MENA,EA|drain1|healer
beaded-lizard|Beaded Lizard|M|desert,rainforest|35|-|B|OC|venom-long+D8|trickster
goat-kid-gang|Goat Kid Gang|M|mountain|8|-|B|NWE,SE,SA|grudge-slow+D11|blocker
stoat|Stoat|S|tundra,grassland|10|se=winter|B|SA,EE|grudge-fury+toughhide1|ambusher
wolverine-cub|Wolverine Cub|M|tundra,mountain|13|-|X|MENA|D5|crowd
cormorant-line|Cormorant Line|M|coast,wetland|19|dp=dawn|B|MENA,EA,CSA|D10|burst
booby-colony|Booby Colony|M|island,coast|22|we=wind|X|SEA|wary1|stall
tamandua|Tamandua|M|rainforest,forest|22|dp=night|B|EA,CSA,SEA|grudge-fury+toughhide1|ambusher
carpenter-bee|Carpenter Bee|M|rainforest,desert|28|we=sun,heat|B|SEA,WCA,ESA|drain1|healer
caracal|Caracal|M|desert,grassland|31|dp=dusk|B|OC|grudge-fury+regrow1|healer
cockle-bed|Cockle Bed|S|coast|19|dp=dawn|B|MENA,EA|current-hard+D12|balanced
tortoise-hatchling-trundle|Tortoise Hatchling Trundle|S|desert,grassland|16|-|B|EE,MENA,EA|venom-long+D2|stall
sun-bear|Sun Bear|M|rainforest|33|-|B|OC|grudge-fury+regrow1|healer
seal-pup-raft|Seal Pup Raft|M|coast,island|15|-|B|MENA,EA|current-hard+D12|balanced
glacier-cub|Glacier Cub|M|tundra|9|we=snow,frost|A|EE|grudge-fury+toughhide1|ambusher
ice-floe-seal|Ice Floe Seal|M|tundra,coast|15|we=snow|X|MENA,EA|D5|crowd
camel-calf|Camel Calf|M|desert|23|-|B|EA,ESA|plated1|guardian
reindeer-calf-herd|Reindeer Calf Herd|M|tundra|4|se=spring,summer|B|NWE|grudge-slow+D11|blocker
tundra-vole-swarm|Tundra Vole Swarm|S|tundra|3|dp=day|X|NA|grudge-fury+ambush1|ambusher
```

#### Batch C (46 rows)

```
grass-snake|=|L|grassland,wetland,rainforest,desert|14|=|base|*|venom-trail|poisoner
grey-heron|=|L|wetland,coast|15|=|base|*|two-aims|ambusher
mischief-monkey|=|L|rainforest|15|=|base|*|grudge|burst
red-fox|=|L|forest,grassland,mountain,tundra|16|=|base|*|grudge|burst
raccoon|=|L|forest,wetland|16|=|base|*|grudge|burst
tawny-owl|=|L|forest,mountain|17|=|base|*|two-aims|ambusher
arctic-fox|=|L|tundra|17|=|base|*|grudge|burst
tundra-fox|Tundra Fox|L|tundra,mountain|24|se=summer|B|CSA|D5|blocker
badger|=|L|forest,grassland|18|=|base|*|grudge|burst
mire-toad|=|L|wetland|18|=|base|*|venom-trail|poisoner
tide-crab-knight|=|L|coast,island|19|=|base|*|current|trickster
moss-golem|=|L|forest,rainforest,mountain|20|=|base|*|grows|stall
lichen-golem|Lichen Golem|L|mountain|13|-|B|SA,EE,MENA|grows-twin+D9|healer
coral-golem|Coral Golem|L|coast,island|26|-|B|SEA,WCA|plated2|guardian
bramble-wolf|=|L|forest|22|=|base|*|grudge|burst
coconut-crab-youngster|Coconut Crab Youngster|L|island|22|dp=night|B|SEA|current-hard+D12|trickster
marsh-harrier|Marsh Harrier|L|wetland,grassland|27|dp=dawn,dusk|B|SEA,WCA,ESA|D1|burst
moray-lurker|Moray Lurker|L|coast,island|24|dp=night|B|SEA,WCA|toughhide2|blocker
dune-wyrmling|Dune Wyrmling|L|desert|22|-|B|EA|venom-long+D1|burst
delta-gharial|=|L|wetland|24|=|base|*|venom-trail|poisoner
emerald-python|=|L|rainforest,wetland|25|=|base|*|venom-trail|poisoner
jungle-tiger|=|L|forest,rainforest|26|=|base|*|grudge|burst
cloud-leopard|=|L|mountain|28|=|base|*|grudge|burst
reef-turtle|=|L|island|16|=|base|*|venom-trail|poisoner
bog-pike|=|L|wetland|20|=|base|*|current|trickster
desert-gila-dragon|=|L|desert|20|=|base|*|venom-trail|poisoner
cliff-ram|=|L|mountain|21|=|base|*|grudge|burst
wolverine|=|L|tundra,mountain|21|=|base|*|grudge|burst
wild-boar|=|L|forest,grassland|21|=|base|*|grudge|burst
pelican-parliament|=|L|coast,island|21|=|base|*|two-aims|ambusher
beaver-foreman|=|L|wetland,forest|22|=|base|*|grudge|burst
giant-anteater|=|L|rainforest|22|=|base|*|grudge|burst
giant-bumblebee|=|L|grassland,forest|23|=|base|*|swarm|crowd
tufted-lynx|=|L|forest,mountain|23|=|base|*|grudge|burst
clam-lurker|=|L|coast|23|=|base|*|current|trickster
giant-clam|Giant Clam|L|island|28|-|B|SEA|stagger2|burst
desert-tortoise|=|L|desert|24|=|base|*|venom-trail|poisoner
griffon-vulture|=|L|mountain,desert|24|=|base|*|two-aims|ambusher
black-bear|=|L|forest,mountain|25|=|base|*|grudge|burst
salt-sea-lion|=|L|coast|25|=|base|*|current|trickster
glacier-bear|=|L|tundra|26|=|base|*|grudge|burst
ice-bear|Ice Bear|L|tundra|16|se=winter|B|EE|grudge-slow+enrage2|blocker
prairie-bison|=|L|grassland|26|=|base|*|grudge|burst
desert-camel|=|L|desert|27|=|base|*|grudge|burst
lichen-reindeer|=|L|tundra|28|=|base|*|grudge|burst
caribou-bull|Caribou Bull|L|tundra|12|se=autumn|A|EE|stagger2|trickster
```

#### Batch D (58 rows)

```
goliath-frog|Goliath Frog|L|wetland,rainforest|34|we=rain,storm|A|ESA,OC|D12|balanced
frigatebird|Frigatebird|L|island,coast|29|we=storm,wind|B|WCA,OC|D4|crowd
emperor-scorpion|Emperor Scorpion|L|desert,rainforest|37|dp=dusk,night|B|OC|swarm-dense+stagger2|trickster
gorse-beast|Gorse Beast|L|grassland,forest|38|se=autumn|A|ESA,OC|D9|crowd
goliath-heron|Goliath Heron|L|wetland|35|-|A|WCA,ESA|D4|crowd
mandrill-boss|Mandrill Boss|L|rainforest,grassland|32|-|B|ESA,OC|grudge-slow+D10|crowd
silver-fox|Silver Fox|L|mountain|34|se=winter|B|ESA,OC|drain2|crowd
crab-eating-raccoon|Crab-eating Raccoon|L|coast,wetland|32|dp=night|B|ESA,OC|grudge-fury+ambush2|ambusher
eagle-owl|Eagle Owl|L|mountain,forest|35|dp=night|A|OC|D4|crowd
old-brock|Old Brock|L|forest,grassland|38|-|B|ESA,OC|drain2|crowd
elder-mire-toad|Elder Mire Toad|L|wetland|36|we=rain,fog|B|WCA,ESA|venom-long+wary2|stall
tide-crab-paladin|Tide Crab Paladin|L|island,coast|30|we=storm|B|OC|D3|blocker
peat-golem|Peat Golem|L|wetland|31|we=fog|B|WCA,ESA|grows-twin+wary2|blocker
elder-bramble-wolf|Elder Bramble Wolf|L|forest|34|se=autumn|B|OC|drain2|crowd
coconut-crab-titan|=|B|island|26|=|base|*|two-turns|balanced
robber-crab-baron|Robber Crab Baron|B|coast,island|36|-|B|OC|two-turns+stagger2|burst
great-hawk|=|B|grassland|28|=|base|*|two-turns|balanced
ancient-snapper|=|B|wetland|28|=|base|*|two-turns|balanced
alligator-snapper|Alligator Snapper|L|wetland,coast|29|-|B|WCA,ESA,OC|regrow2|healer
reef-leviathan|=|B|coast|29|=|base|*|two-turns|balanced
conger-brute|Conger Brute|L|coast|38|we=storm|B|WCA,OC|current-hard+drain2|healer
old-bramblehorn|=|B|forest|30|=|base|*|two-turns|balanced
red-stag|Red Stag|L|forest,mountain|32|se=autumn|A|ESA,OC|enrage2|burst
dune-wyrm|=|B|desert|30|=|base|*|two-turns|balanced
snow-owl-monarch|=|B|tundra|30|=|base|*|two-turns|balanced
frost-owl-regent|Frost Owl Regent|B|tundra|14|se=winter|B|EE|two-turns+D8|trickster
storm-eagle|=|B|mountain|32|=|base|*|two-turns|balanced
lammergeier|Lammergeier|L|mountain|36|-|B|OC|drain2|healer
jade-jaguar|=|B|rainforest|32|=|base|*|two-turns|balanced
saltwater-gharial|Saltwater Gharial|L|coast,wetland|36|-|A|OC|venom-long+D1|burst
rock-python|Rock Python|L|grassland,mountain|36|we=sun,heat|A|OC|regrow2|healer
elder-tiger|Elder Tiger|L|forest,rainforest|38|-|A|WCA,OC|grudge-fury+regrow2|healer
ghost-leopard|Ghost Leopard|L|mountain|37|dp=night|B|OC|grudge-slow+enrage2|blocker
mangrove-crab-king|=|L|coast,island,wetland|30|=|base|*|current|trickster
mangrove-crab-emperor|Mangrove Crab Emperor|L|wetland,island|38|we=storm|A|ESA,OC|current-hard+drain2|healer
sand-viper-matriarch|=|L|desert|31|=|base|*|venom-trail|poisoner
honey-badger-brute|=|L|grassland,desert|32|=|base|*|grudge|burst
thunder-yak|=|L|mountain|33|=|base|*|grudge|burst
musk-ox|Musk Ox|L|mountain,tundra|39|se=winter|B|ESA,OC|D5|blocker
reef-eel-lord|=|L|coast,island|34|=|base|*|current|trickster
reef-eel-tyrant|Reef Eel Tyrant|L|coast|39|-|B|WCA,OC|current-hard+drain2|healer
alpha-dingo|Alpha Dingo|L|desert|39|-|B|ESA|stagger2|trickster
fern-cassowary|=|L|forest,rainforest,island|36|=|base|*|two-aims|ambusher
deep-octopus|=|L|island,coast|37|=|base|*|current|trickster
kraken-spawn|Kraken Spawn|L|coast|40|we=storm|B|WCA|D11|blocker
giant-otter-gang|Giant Otter Gang|L|wetland,rainforest|30|-|B|WCA,ESA,OC|stagger2|burst
leatherback|Leatherback|L|island,coast|32|-|B|OC|venom-long+D8|trickster
ibex-patriarch|Ibex Patriarch|L|mountain,desert|38|-|A|ESA,OC|stagger2|trickster
bearded-pig|Bearded Pig|L|rainforest,wetland|33|-|B|ESA,OC|grudge-slow+D10|crowd
albatross|Albatross|L|island,coast|33|we=wind,storm|B|OC|drain2|healer
aardvark|Aardvark|L|grassland,desert|36|dp=night|B|OC|D5|crowd
snow-lynx|Snow Lynx|L|mountain,tundra|30|se=winter|B|ESA,OC|drain2|crowd
spurred-tortoise|Spurred Tortoise|L|grassland,desert|34|-|A|ESA,OC|venom-long+D1|burst
condor|Condor|L|mountain|35|we=wind|B|OC|enrage2|burst
sloth-bear|Sloth Bear|L|forest,grassland|35|dp=night|B|OC|drain2|crowd
elephant-seal-bull|Elephant Seal Bull|L|coast,island|36|-|A|OC|stagger2|burst
wood-bison|Wood Bison|L|forest,tundra|32|se=winter|B|OC|D5|blocker
wild-bactrian|Wild Bactrian|L|desert,mountain|37|-|B|OC|grudge-fury+regrow2|healer
```


## 5. Drops, petals, exp (columns 12, 13, 14, 17)

### 5.1 Drops syntax and policy

`drops` = comma list of entries `Item Name:chance%` with optional gates, and the specials:
- `Item:chance%` chance 1-100 (the `%` is optional; `creatures.txt` has none and means the same), one independent roll per entry per win (+ Luck and pal Spoils as today, `win_fight`).
- Gates, appended: `@reg=EE` or `@reg=EE/MENA/EA` (the fight's region code: `exp_scene` region), `@lv>=20`, `@lv<=29`, `@lv>24`, `@lv<30` (the creature's FIGHT level, after any scaling). Two gates may follow each other: `Item:25%@reg=EE@lv>=20`. A gate that is not met means no roll.
- `*seed:N` (a local seed) and `*guide:N` (that region's Gardening Guide) as today. `*guide` only on boss-size rows (5%). `*seed` only where the base has it, or 3-10% on non-boss variants of a family whose base has it.
- Base row: `=` (keep old list) or `=+Item:chance%...` (old list plus the new entries).

Per variant row: 3 to 5 entries not counting specials; 1-2 common (40-70%), 1-2 uncommon (12-35%), AT LEAST 1 rare (1-5%), and 1 gated entry (about 1; 0 or 2 allowed on boss-size and large rows); a gated entry may be up to 60%. At least 2 entry names differ from the base's and from every sibling's drops (per-variant tables, not copies). No entry twice; the same item may appear in siblings with other chances. Rare entries are the things a gnome keeps: gems, pearls, charms, feathers of note, a fine pelt. Order: common first, rare last.

Item names must exist in the item catalog or be flagged NEW:
- The catalog (table `items`) is built from data files by the importers (`catalog.php` `import_catalog`, `adventure_data.php` `import_creatures_txt`); lookup is `item_id_by_slug(slugify(name))` (`includes/db.php`). A name counts as KNOWN when its slug is in: any drop of `creatures.txt` (these become 'part' items), `data/gatherables.txt` col 2, `data/trail_sight_items*.txt` col 2, `data/crops.txt` col 2 and `data/flowers.txt` col 2. The lint prints the known list (`php tests/pf_creatures_lint.php --items`, lint owner: lead assigns).
- Any other name is NEW: list it in column 17 and it is created by the importer as a 'part' item (rarity and price from its chance and level, `import_creatures_txt` formula). At most 2 NEW names per row. A NEW name reused by a sibling is listed in each row that uses it.
- Prefer known names for common drops, NEW names for the identity of the variant (its part).
- Importer work (engine/data agent): `creature_drops` gets gate columns (`reg`, `lvmin`, `lvmax`); `win_fight` honours them; the base `creatures.txt` rows are untouched.

### 5.2 Petals (column 13)

New: a win gives Petals (`give_petals`, `rewards.php`; a peaceful win without puzzle Charm gives half, like XP; a puzzle Charm win gives full). Written as `min-max`. Rule: `mid = max(1, round(K x (2 + 0.6 x L)))`, K = 0.5 small, 1.0 medium, 1.8 large, 4.0 boss, L = row level; `min = max(1, round(0.7 x mid))`, `max = max(min, round(1.3 x mid))`. The writer may tilt a row by at most +-20% for a rarer or harder variant; the lint accepts min and max within 25% of the rule. Examples: small L1 1-1; small L12 4-7; medium L10 6-10; medium L20 10-18; large L20 18-33; large L30 25-47; boss L30 56-104; boss L36 66-122.

### 5.3 Exp (column 14)

Multiplier of the old XP `round(6 L m)` (m = 0.8/1.1/1.6/2.4). Default 1.0; `1.0 + 0.1 x ability cost` rounded to 0.05, max 1.5; a variant that is easier than its base (small, weak deck) 0.9. Outlevel scaling and pal lessons apply afterwards as today.

## 6. Writer procedure and lint (each of A-D)

1. Read sec 1-5 and the rows of your batch; read `data/creatures.txt`, `pf_creature_pieces.txt`, `pf_class_base.txt`, `pf_region_pieces.txt`.
2. For each row: write the unique 3 pieces, drops, petals, exp, art, description, new_items. Keep the assigned ability and ai; make the deck express the ability (D ids: deck test) and the ai (a crowd creature's pieces are many cheap Hurts; a stall creature's carry trip/evade/hold; a healer's carry heal).
3. Write only `claude/creature-pass/data/pf_creatures_<batch>.txt`, with the header comment of sec 1 (column names) and the batch letter.
4. Lint (`tests/pf_creatures_lint.php`, to be written before the merge; the checks are the rules above): 17 columns; slug unique and equal to the roster; size/lands/level/cond/regions/ability/ai equal to the roster (level +-1); regions valid for the lands; ability ids known, cost <= 3, distinct in the family; ai known and distinct in the family; deck 3 pieces, tag/type legal, budget, D test, piece names unique; drops syntax, entry counts, rare 1-5%, gates, item names KNOWN or in column 17; petals rule; exp range; description <= 150 chars; no emoji, no `|` inside cells.

## 7. HP policy D (Balance agent; constants, files, targets)

Option D = Option A (equal ~80% chain-bot win at level) + per-creature fixes from the audit mult column + a lower bar for low-level medium creatures so medium -4 is not a cliff. Source numbers: `hp-audit.md`. The levers are `PFB_V1_FOE_MULT` (piece values), `PFB_V1_BAR_MULT`, the per-creature tune file, and the medium bar ease; the JS twin changes with every constant (`bash tests/pfengine_js.sh`), `PFB_V1_LEVEL` curve unchanged.

### 7.1 Size constants (2.7.00 value x option A factor)

| size | PFB_V1_FOE_MULT | was x factor | PFB_V1_BAR_MULT | was x factor |
|---|---|---|---|---|
| small | 0.8807 | 0.855 x 1.03 | 1.3780 | 1.325 x 1.04 |
| medium | 0.5568 | 0.48 x 1.16 | 1.7743 | 1.491 x 1.19 |
| large | 0.4309 | 0.378 x 1.14 | 1.7193 | 1.495 x 1.15 |
| boss | 0.6026 | 0.585 x 1.03 | 0.9158 | 0.825 x 1.11 |

### 7.2 Medium low-level bar ease (new constant `PFB_V1_BAR_EASE_MEDIUM`)

Bar multiplier for a medium creature of level L (applied after the size constant and the tune): `ease(L) = clamp(0.80 + 0.20 x (L - 12) / 7, 0.80, 1.00)`: 0.80 up to L12, linear to 1.00 at L19, 1.00 above. Small, large, boss: 1.0. Balance may move the floor within 0.60-0.90 and the end level within 16-24, and raise the low-level medium FOE_MULT by up to 15%, to meet the targets in 7.4 (the audit's `bar_x 0.7` gave 99/84/49 at 0/-4/-8 with 4.9-turn fights but was not tried together with option A).

### 7.3 Per-creature tune `data/pf_creature_tune.txt`

`slug|foe_x|bar_x` (default 1.0 for a missing row; piece value x `foe_x`, bar x `bar_x`, both applied to the final numbers; JS twin reads the same table). Starting values (audit mult column; sizes at level hard = exact audit mult; at -4 hard = half the gap; easy = half the gap capped at 1.6 except the five marked):
- at-level hard (x audit mult): sand-fleas 0.79, earwig 0.88, sun-lizard 0.78, giant-centipede 0.76, bramble-wolf 0.72, wild-boar 0.74, arctic-fox 0.76, jungle-tiger 0.78, beaver-foreman 0.78.
- -4 hard (1 - gap/2): ant-scouts 0.93, carrion-crow 0.815, barn-rat 0.835, paper-wasp 0.885, ember-beetle 0.93, sea-otter-bandit 0.93, grass-snake 0.86, griffon-vulture 0.88, tufted-lynx 0.90, cliff-ram 0.91, desert-gila-dragon 0.92, bog-pike 0.93, prairie-bison 0.94, thunder-yak 0.94, storm-eagle 0.94, coconut-crab-titan 0.96.
- easy tail (the audit's first batch, x1.4-1.6): will-o-wisp 1.6, thistle-beast 1.6, savanna-hyena 1.6, moss-golem 1.4, reef-turtle 1.4.
- easy tail rest (1 + gap/2): outback-dingo 1.34, spice-monitor 1.31, leafcutter-column 1.31, garden-snail 1.29, bullfrog 1.22, giant-bumblebee 1.21, clam-lurker 1.21, black-bear 1.21, fern-cassowary 1.21, poison-dart-frog 1.20, raccoon 1.18, tawny-owl 1.18, hermit-crab-hoarder 1.15.
- `bar_x` 1.0 for all of these (the lever is the piece value); the 230 variants start at `foe_x` 1.0 and are tuned by measurement: after the abilities and decks are in, run `php tests/pfboard_tune_v1.php chain 4,0,-4,-8 2 i/4 json` over all 318 and write a row only where |tune - 1| > 0.03. Cost points make a variant harder, so expect many variants with ability cost 2-3 below 1.0.

### 7.4 Acceptance (chain bot, model gnome, 4x4, the audit's harness)

- Win at level 80 +-4 per size (small, medium, large, boss), HP lost 50-70%, 5-8 turns a fight.
- Medium: -4 win >= 55 and -8 win >= 35 for levels 5-18 (the audit had 54-67 and 7-27); the drop from level to -4 at most 30 points for any size band of the audit table.
- Look and smart bots: no size below 95% at level (they stay ceiling).
- No creature (318) outside 60-95% at level; no creature outside 35-90% at -4 (rows outside get a tune).
- Order of work: size constants, ease, tune of the 88, then variants; re-run `pfboard_sim.sh`, `pfboard_tune_v1.php`, `pfengine_js.sh`. Human playtest still needed (hp-audit caveats).

## 8. Out of scope (listed, not fixed)

- B1 (spawn-review sec 5): a fresh install numbers routes one lower from 239 up (`roads.php:96-98`, commit e21c8d65 stopped inserting the Clovercove > Blossomreach Market leg that `cut_dead_end_roads()` later deleted); `trail_maps`, `trail_camps.json`, `road_kinds.txt`, ground pictures use the map numbering. Not fixed.
- B2: lair routes' stretch count (`roads.php:141`, `steps = 2 + min(3, lvl / 8)`) differs from the authored map on a fresh install (315, 327, 340, 363, 377: 5 authored / 3; 389, 402, 415: 5 / 4; 425, 435, 458, 471: 4 / 5); existing worlds keep old steps. Not fixed.
- B3: the boss spot on 8 of 14 lair routes can never find a boss (`trail_pick_fixed()` needs a boss of the land with level <= L+8; none for 315, 327, 340, 349, 363, 377, 389, 415 and 402 below L22), so an ordinary creature (Grumpy Lemming class) appears. Not fixed (the new variants may happen to fill it; do not add logic for it).
- Also not in scope: Treks (own pools, `trek_creatures.txt`), the 14 inactive lair bosses, B4-B15 of the review, art generation, human playtest.
