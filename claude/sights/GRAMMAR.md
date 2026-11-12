# Trail Sights: data grammar (reference for the data files). Engine: `game/includes/trail_sights.php`, `trail_sight_extras.php`. Lint: `bash tests/trail_sights_lint.sh` (set `SIGHTS_LINT_DIR=/tmp/sights-lint-<you>` so you have your own scratch install).

All files are in `game/includes/data/`. Each kind has a base file and one file per SET (`maplewold`, `shared`, `end`); an agent edits only its own set's files. Lines starting `#` and blank lines are ignored. No `|` or newline inside a field.

## Sight rows: `trail_sights_<set>.txt` (13 columns)
`slug|verb|icon|energy|cd|uses|when|check|rewards|win|lose|tool|fail_en`
- verb: unique across ALL rows (lint). icon: one emoji. energy 0-5. cd = cooldown in tenths of a game day (55 = 5.5). uses per cooldown (1-9).
- `when`: `-` or conditions joined by `/`; each is `key=v1,v2` (any one value). Keys: `dp` (dawn day dusk night), `se` (spring summer autumn winter), `we` (sun cloud rain storm frost heat wind fog snow), `hp` (a stop happening id), **`st`** (the walk stance: `sneak`, `hunt`, `normal`), **`pal`** (`1` = a Puzzle Pal is along, `0` = alone), **`tl=<key>:N`** (the private tally `<key>` is at least N).
- check: `-` | `stat:dc` (stat keys: grit nimble hardiness lore sense charm luck ... see GNOME_STATS in `game/includes/gnome.php`; dc 8-14) | **`pick:N`** or **`pick:N:label;label;label`** (N 2-5 labels: the gnome chooses one; one is right, fixed per gnome and game day; wrong = the lose line; a pick needs a lose line). A fail costs `fail_en` extra energy.
- tool: `-` or `type:tier` (types: forage pick net bucket axe rod basket staff lantern; tier 1-4).
- win / lose: one line each; **variants joined by ` // `** (a random one shows). No emoji inside (the icon column shows one).
- rewards: comma-joined tokens. Each token may have `@chance` (percent) and `?cond` (conditions as in `when`, with `;` instead of `,` between values, `/` between conditions: `item=x:1@25?se=summer;autumn/dp=dusk`), and `first:` in front = only the first time this gnome ever uses the Sight.
  Tokens: `xp=3:1` `c=4:1` (coins) `en=3` `item=<slug>:<qty>` `crop=1` `find=1` `fish=1` `seed=1` `buff=<stat>:<amount>:<minutes>` `fp=1` (friendship with a RANDOM villager of the start place) `reveal` (tells a hidden place) `gather=<tool>` (the ordinary gather table) `take=<item>:<qty>` (a cost: needed and used up on a win) and the new ones:
  - `hint=weather|season|away|creature`: a TRUE line from the game state (tomorrow's weather, the season, who is away today, a large creature nearby).
  - `title=<Name>`: a title the gnome can wear (shown on the Almanac page's title list).
  - `page=<key>`: opens an extra Almanac page defined in `trail_sight_pages_<set>.txt`.
  - `tally=<key>`: adds 1 to a private counter (a cairn, a collection); then `...?tl=<key>:5` tokens pay at milestones.
  - `fpto=<Name>[@village-slug][:points]`: friendship with a NAMED villager (default 1 point).
  Item slugs must exist (the lint checks the DB, the items files and the new items files).

## Villagers at a Sight: `trail_sight_folk_<set>.txt`
`sight slug|villager|when|chance %|line|rewards`
- villager = an exact name (a stop villager or a town NPC/traveller); when two villagers share a name use `Name@village-slug` (the village's location slug, e.g. `v-na-1-3`).
- Chance is rolled once per gnome, Sight, villager and game day (so the Sights card can say who is here). A villager who is **away today** (visiting family) or a **hidden NPC** (Pomeroy Crumbworth before the Gourmand opens) is not there.
- rewards: any Sight reward tokens, plus: **`nocheck`** (their being here makes the Sight's check a sure thing) and **`give=<item>:<qty>`** (they ask for that item: the gnome gets a "Give" button on the Sights card; the item is used up and the OTHER tokens pay). `fp=N` = friendship with THIS villager. A row with `give=` pays only on giving; a row without pays automatically after a win (the first present one).

## Quest lines: `trail_sight_quests_<set>.txt`
`Q|slug|title|giver|icon|order|reward|intro|outro|gate` then `B|slug|sight slug or @kind|label|when|needs`
- order: `seq` (in order), `any`, **`anylast`** (any order but the LAST beat only after all the others).
- gate (optional): `quest:<other quest slug>` = cannot begin until that line is done.
- A Sight may be a beat more than once in a line. Beat kinds: a Sight slug, or **`@boss`** (a lair is won: defeated or befriended; `@boss:<lair slug>` for one lair), **`@meal`** (a home-cooked meal eaten), **`@friend:<Name[@village]>`** (that villager is at least an acquaintance).
- needs (beat column 6, optional): `take=<item>:<qty>`: the beat counts only if the gnome carries it; it is used up.
- giver: a villager's name (`Name@village-slug` if shared). reward as the rewards column (`fp=N` = friendship with the giver; `title=`, `page=` allowed).

## New items: `trail_sight_items_<set>.txt`
`slug|Name|category|rarity|base_price|edible|description|effects` (effects optional JSON). categories: forage part decor food produce supply other misc flower soil. Decor you can place in a yard: edible 0, effects `{"decor":{"type":"ornament","w":1,"h":1,"icon":"🎐","appeal":4,"bonus":""}}` (look at `game/includes/animals120.php` ~line 56 for types). Something to eat or use that gives a short buff: edible 1, effects `{"temp":{"charm":1,"minutes":120}}` (stats: see `game/includes/alchemy.php` ALCHEMY_ITEMS for examples). The picture is a 64x64 PNG `game/assets/img/ph/<slug>.png` (art is made by someone else; list new item slugs in your todo file).

## Extra Almanac pages: `trail_sight_pages_<set>.txt`
`key|Chapter|Category|Title|Body` (Body uses `\n` for a line break and the Almanac's `[b]bold[/b]`); opened by a `page=<key>` reward. Use chapter `Sights` (or `General`).

## New villagers: `trail_sight_newfolk_<set>.txt`
`Name|species|personality|role|bio|village slug`: a villager the world did not make (Keeper Marram ...), added to that village's stop villagers (slot 9+). Then rows may name them. (Find village slugs: location slugs like `v-na-1-3`; list them with a scratch install, see `claude/sights/folk-todo.md` for the snippet.)

## Names and captions: `trail_sight_info_<set>.txt` (`slug|Name|caption`): one per Sight; already written.
