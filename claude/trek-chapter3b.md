# Treks Chapter III-b: "The Knock Below" (draft title; spec v1, 2026-10-21, vs source 2.0.21)

III-b continues Chapter 3: same chapter number, same run, same map file. It ends Chapter III. Read `claude/trek-chapter3.md` first. Builders A, B, C work in parallel from this file. Only the Opus stitcher touches shared files (§7).

## 0. Problems and fixes
1. No separate switch for III-a / III-b. `trek_chapters_open` = 2 (default): players see none of Ch III ("coming soon"). = 3: players get III-a and III-b as one chapter. Admins always get both. DECISION: no per-part gate.
2. Spot files are not globbed. `trek_spots()` reads only `trek_spots.txt` and `trek_spots_ch3.txt`: APPEND III-b spots to `trek_spots_ch3.txt`. Map stays `trek_map_ch3.txt`, extended down from row 50. Chapters, creatures, texts, drafts ARE globbed (new `_ch3b` files).
3. Crew moments fire once per run (flag `cm_<crew>`), run is shared. No new crew-moment mechanic: trailmate III-b moments come from text (boss-win line, banter, interlude).
4. Check labels must be unique (`trek_ms_checks()` keys by label). Do not repeat III-a labels ("Trail events resolved", "Side stops visited", "Wayfinder nook found").
5. A gate with `ms=` pays its milestone even when bumped shut (unless `noopen`). Counting Door is safe only because its failopen riddle sits right before it on the only path. Keep it that way.
6. Old `ch3.ms.ch3a_end` text lies ("It does not open."): text pass 9 (§5c). Do NOT edit `trek_drafts_ch3.txt` (the pass matches live rows against current drafts).
7. Boss is female (weak-start line in `trek_act_challenge` says "she starts at…").
8. `tests/trek_ch3.php` and `tests/trek_audit_ch3.php` assert closed gate, 12 spots, 3 milestones, 40x50 map, no finish row, 70-95 slots, "what knocks" spoiler guard. Builder C updates them.

## 1. Story
**What knocks:** Warden Umber, a very old tortoise sentry. She went down through the Bedrock Door (floor of the deepest hall) to hold back what rises from the bedrock. From below she knocks three slow beats: "all is well, I am here". She is never on screen in III-b; species only hinted (shell-shaped dent in her bed, a shed scute).
**Why the knock sounded wrong:** Old Holler, a giant blind cave toad in the Still Mere, is blighted: she gulps every sound and booms it back late and garbled (matches III-a echo bat, riddle answer "echo"). Old Gneiss copied the knock so long he forgot why. Thrum's drumming (Ch II) hid the knock until it stopped (book.thrum).
**Not resolved:** what the Warden holds back (Blight Crown NOT named); door stays shut. At the end the knock is clear, then a FOURTH knock comes. Hook for Ch IV (bedrock).

### Beats (Z → J)
1. Still Gate opens (`ch3.spot.stillgate.open`). Warm still air, knock louder.
2. Quiet Steps (y). Silence, own heartbeat. Fallen Pillar blocks the stair (cart: heave or dig).
3. Still Mere (z). Black flat water; knock rings across it late and doubled; something huge breathes under it. Mere Wheel (optional) drains it: shortcut, Drowned Nook, Holler starts weaker.
4. Warden's Lodge (l, camp 2). Tidy cell, cold kettle, bed with shell-shaped dent. Pip Dustwing, small cured bat, keeps the lamp: "She went down to knock. She said wait. I waited." Names Umber. Strongbox needs a bell clapper.
5. Tally Gallery (g, dark). Tally marks in threes. Tally Wall (sign) = sentry log: "3 = all well". Side stops: Hush Bell riddle (prize Bell Clapper), Still Pool rest, Wayfinder nook, Cold Lantern old camp.
6. Tally Door riddle → Counting Door. Answer "A knock". Pays `ch3_hall`.
7. Knock Hall (k, dark, hint). Round hall, floor centre = one banded stone: the Bedrock Door. Hint: "Stand still. Count."
8. Bedrock Door (sign). Knock three; pause; three answer from below (first contact). Then BOOM from the mere pool: Holler answers too.
9. Old Holler (boss). Cured, not killed. Grey drains from her throat; she coughs up a humming stone (Echo Stone), falls asleep, embarrassed.
10. Silence. Knock clear: three. Then a fourth. Trailmate line, gnome reply, chapter complete.
11. Outro/hook. Shard stops pointing down, points at the door, hums in time. Bedrock below; nothing grows there.
12. Interlude 3. Each trailmate reacts. Chapter IV coming soon.

### Ties
Ch I: "something deeper fed her", ch1.hook, Shard points down. Ch II: Thrum's beat hid the knock; interlude.2 readings (Bracken "sentry's knock", Tumble "come down, politely", Burdock "has manners") all come true. III-a: chalk "Cured, not killed" (Warden's hand; Sorrel was right), echo answer, Gneiss's habit, Wren counting "three, then a long wait". Sets up IV: Bedrock Door, fourth knock, Burdock's fear of no-roots layer, Warden waiting below.

### Trailmate moments (text only)
Burdock: roots stop at bedrock, quietly afraid, goes anyway. Zinnia: hums to the sleepy toad, tends everyone after the boom. Bracken: salutes the door, "a fellow sentry at her post". Wren: decodes tallies, hears the fourth: "Four. That is new." (primary win line). Sorrel: copies Tally Wall into margin, "It scans." Tumble: chalks "THIS WAY DOWN (politely)". Juniper: covered bowl by the door, "Whoever knocks gets fed first."

## 2. Chapter data
Chapter row already `chapter|3|III|The Humming Deep`; do not repeat. New file `includes/data/trek_chapters_ch3b.txt` (A):
```
zone|3|y|The Quiet Steps|🪜|u|
zone|3|z|The Still Mere|🫧|u|
zone|3|l|The Warden’s Lodge|🛖|u|
zone|3|g|The Tally Gallery|🧮|d|
zone|3|k|The Knock Hall|🚪|d|hint
ms|3|ch3_hall|Reached the Knock Hall|trek_ms_ch3_hall|Knock Hall|700
ms|3|ch3_holler|Old Holler cured|trek_ms_ch3_holler|Old Holler|1300
ms|3|ch3_chapter|Chapter III complete|trek_ms_ch3_chapter|Chapter III|600
check|3|Tally Door solved|flag|tallydoor_solved|3
check|3|Deep side stops visited|all|pillar_done,rest2_used,seen_tally|3
check|3|Bell riddle solved|flag|bell_solved|4
check|3|Still Mere drained|flag|mere_done|4
check|3|Drowned nook found|flag|nookB_found|4
check|3|Deep trail events resolved|evn|6|5
finish|3|holler_down|ch3_holler,ch3_chapter|trek_ch3_petals|warden-scute,echo-stone|trek:holler|Chapter III
```
Milestone order: III-a 0-2 (ch3_wren, ch3_gneiss, ch3a_end), then ch3_hall, ch3_holler, ch3_chapter. File sort puts `_ch3.txt` before `_ch3b.txt`: A verifies `array_keys(trek_milestones(3))` gives all 6 in order. XP: III-b 2,600 at full checks; Ch III total 5,050. `trek_ms_*` settings self-create from ms rows. New setting `trek_ch3_petals` 600 (stitcher). Tune rows in SEPARATE file `trek_chapters_ch3b_tune.txt`, owned by C.

## 3. Map and spots (Builder A)
`trek_map_ch3.txt`: 40 wide; height grows 50 → **100**. Change only rows 48-49 under Z (10,47): open a 1-wide way down at col 10, zone `y`. Append rows 50-99 and the matching zone-layer rows (zone layer = 100 rows, each padded to 40). Update header comments.
Targets: III-b walkable (rows ≥48) 450-560; main route Z→J 170-210 steps (BFS, mere NOT drained, no Wayfinder); ~20 min.
Tiles: only existing (`# . % : * + ^ = w ~ ,` and spot letters). `w` only in zone z. Mere Wheel M within 4 tiles of its water. `+` only next to F. Each spot letter once on the whole map; III-a owns S B C N H A R G W E X Z.
Layout (A finalises): **y** rows 48-57, cols 4-24, winding stair, P in a 1-wide neck ~(10,52) (only way on). **z** rows 56-70, cols 4-30; mere `w` block ~rows 60-66, cols 8-18; main shore path east; drained shortcut west; D in a pocket reachable ONLY across `w`. **l** rows 57-68, cols 30-38, joined to east shore; camp L ~(34,62), Y ~(36,60); no fights. **g** rows 70-88, long dark gallery west then south; T ~(30,72) on main path; side branches I (west), Q, F behind `+`; O old camp ~6 tiles before U; U ~(8,87), V ~(8,88) directly after on the only path. **k** rows 89-98 round hall, few `*`; K centre on path ~(16,93); J dead end past K ~(26,95).

Edit `trek_spots_ch3.txt`. Replace the stillgate row with:
```
3|stillgate|gate|The Still Gate|x|sym=Z;needs=gneiss_down;ms=ch3a_end;obj=5;flag=reached_stillgate
```
(needs set, no `noopen`: first pass says `.open`, pays ch3a_end once. Old admin runs already have reached_stillgate: no repay.) Append (header comment "Chapter III-b spots (v2.0.22). No new types."):
```
3|pillar|cart|The Fallen Pillar|y|sym=P;obj=6;dc=13;item=camp-kit:1;flag=pillar_done
3|mere|switch|The Mere Wheel|z|sym=M;flag=mere_done
3|nookB|find|A Drowned Nook|z|sym=D;item=camp-kit:1;petals=80;flag=nookB_found
3|camp2|camp|The Warden’s Lodge|l|sym=L;obj=7;flag=camp2_seen;keeper=lodge;entry=trek:lodge
3|strongbox|chest|The Warden’s Strongbox|l|sym=Y;needs=bell-clapper;item=camp-kit:2;petals=120;flag=strongbox_open
3|tally|sign|The Tally Wall|g|sym=T;obj=8;entry=trek:tally
3|bench2|rest|The Still Pool|g|sym=Q;flag=rest2_used
3|bell|riddle|The Hush Bell|g|sym=I;pass=1;right=3;tries=2;item=bell-clapper:1;flag=bell_solved
3|nookC|find|A Narrow Nook|g|sym=F;item=glowing-bead:1;petals=100;flag=nookC_found
3|oldlamp|oldcamp|The Cold Lantern|g|sym=O
3|tallydoor|riddle|The Tally Door|g|sym=U;obj=9;right=2;tries=2;flag=tallydoor_open;solved=tallydoor_solved;seedkeeper=1;failopen=1
3|tallygate|gate|The Counting Door|g|sym=V;needs=tallydoor_open;ms=ch3_hall;obj=10;flag=reached_tallygate
3|door|sign|The Bedrock Door|k|sym=K;obj=11
3|holler|boss|Old Holler|k|sym=J;obj=12;script=holler;creature=old-holler;flag=holler_down;weak=drained_z;weak_pct=85
```
Types used all exist in trek.php. Ch 3 then has 26 spots. Camp-to-camp travel works with no code change.

Tune file `trek_chapters_ch3b_tune.txt` (C owns; start values, C retunes to §4 bands):
```
tune|3|y|320|13|8|13
tune|3|z|330|14|8|14
tune|3|g|335|14|9|14
tune|3|k|340|15|9|15
tune|3|holler|480|11|6|20
```

## 4. Creatures and boss
New `includes/data/trek_creatures_ch3b.txt` (A). Format as ch3; landscape `trek`. Pools:
```
@pool|y|105|tallow-grub:3,stone-loach:1,crystal-weaver:1|3
@pool|z|110|stone-loach:3,tallow-grub:1,bellcap-beetle:1|3
@pool|l|0|tallow-grub:1|3
@pool|g|115|crystal-weaver:2,bellcap-beetle:2,basalt-borer:1|3
@pool|k|105|bellcap-beetle:2,basalt-borer:2,crystal-weaver:1|3
```
| slug | name | size | lv | drop | flavour |
|---|---|---|---|---|---|
| tallow-grub | Tallow Grub | small | 24 | Tallow Wax:50 | A pale fat grub that glows faintly, like a candle stub. It wriggles at you, mostly out of fright. |
| stone-loach | Stone Loach | medium | 25 | Loach Scale:45 | A blind grey fish that slides out of the still water to see who is knocking. |
| crystal-weaver | Crystal Weaver | medium | 25 | Glass Thread:40 | A long-legged spider that spins threads so thin they ring. It does not like to be rung. |
| bellcap-beetle | Bellcap Beetle | medium | 26 | Bellcap Shell:40 | A round beetle with a shell like a little bell. It chimes when it charges. |
| basalt-borer | Basalt Borer | large | 27 | Borer Plate:40 | A mole-cricket as long as a wheelbarrow, with spade hands. It digs toward the knock and gets cross when you are in the way. |
| old-holler | Old Holler | boss | 28 | (none) | A giant blind cave toad, wide as a cart, who lives in the Still Mere. She swallows every sound she hears, and the blight makes her boom it back wrong. |

**Boss script** (C, `includes/trek_ch3b.php`, registered `holler`). Follow trek_ch3.php pattern: existing hooks only, no engine edits.
- `TREK_HO_MOVES = ['hit','gulp','holler']`, `TREK_HO_CRACKED = ['hit','holler']`. Shown a round ahead via `moves`. `'big' => ['holler']`.
- hit: `trek_foe_attack`. gulp: every living member whose ability cooldown >0 gets +1 (Thrum's cling pattern); log line. holler: no roll; every living member takes `HO_HOLLER_PCT` (90) % of `foe_damage`; Guard and Bark halve it (`trek_hurt_member`); after crack 60 %.
- Crack (`after_round`): under 35 % health. Pattern → TREK_HO_CRACKED, `gp` resets, she takes 115 %. Say `ch3.spot.holler.crack` once.
- Knock (`round_end`): every 2nd round (C retuned from 3rd) each living member regains 10 % max health. Say `ch3.spot.holler.knock` first time, then plain `trek_say('🪨 Knock. Knock. Knock. Everyone steadies.')`.
- Tire: from round 4 she takes +10 % a round up to +100 % (combine with crack via `dm`, as Gneiss).
- Party balance (`round_start`, once): +30 % max and hp per living bloomcaller, seedkeeper, rootwarden or brewroot beyond the first (as Gneiss).
- Weak start: `drained_z` → starts at 85 % (engine does this).
- win: (1) set flag, say `.defeat`; (2) say `ch3.spot.holler.<k>` for the FIRST of [wren, burdock, zinnia, bracken, sorrel, tumble, juniper] in the party (`trek_in_party`), `{trailmate}` = that name; (3) say `ch3.scene.holler.me`, then `trek_complete_chapter($run, $u)`; (4) do NOT call trek_ms_award (finish row pays ch3_holler and ch3_chapter).
- TREK_MOVE_NAMES has no gulp/holler; ucfirst fallback is fine.

**Balance** (Auto, real dice, no knacks, sims as trek_audit_ch3): zones y,z: gnome trek Lv18, mates 17. Zones g,k: gnome 19, mates 18. Random fights win 85-95 % mean. Boss: gnome Lv19, mates 18, all 35 three-trailmate parties, 300 fights each. Target median 78-88; assert 78-90; worst ≥ 65. C reports median/worst/best.

## 5. Text (Builder B)
### 5a. Files
`trek_texts_ch3b.txt`: header line, then `text_key|kind|speaker|sort|brief` exactly as in trek_texts_ch3.txt. `trek_drafts_ch3b.txt`: `key|body`, `\n` = line break. Every slot ships a draft in Joshua's voice (importer sets status draft). Sort numbers 3200-3400 in story order. Each brief ends with the same Style sentence as ch3.
Voice: short sentences, cosy-eerie, no gore. Curly quotes “ ” and ’ (never '). One sentence/clause-group per line. Speech ≤ 300 chars; place/narration 2-3 lines; banter 1-2 lines. Never name the Blight Crown. Never write "the knocker is", "it was the knocker", "Old Gneiss knocks" (audit greps).

### 5b. Slots (key | kind | speaker | brief)
- ch3.spot.stillgate.open | narration | | Gate swings open after Gneiss. Warm still air, knock louder. 2 lines.
- ch3.zone.y.arrive | place | | Quiet Steps: total hush, your heartbeat, the knock now and then. 3 lines.
- ch3.zone.z.arrive | place | | Still Mere: black flat water; knock rings back late, doubled; something huge breathes under it (do not name Holler). 3 lines.
- ch3.zone.l.arrive | place | | Lodge: tidy, cold kettle, lamp kept lit. 2 lines.
- ch3.zone.g.arrive | place | | Dark gallery; walls covered in tally marks in threes. 3 lines.
- ch3.zone.k.arrive | place | | Round hall; floor centre one banded stone; knock is under it. 3 lines.
- ch3.zone.k.hint | place | | "Stand still. Count." Three beats, a long wait. 2 lines.
- ch3.spot.pillar.before / win / fail / work / after | narration | | before: a Camp Kit is wrapped under the fallen pillar. win: rolls aside. fail: does not budge. work: chip it free. after: pushed aside. 1-2 lines each.
- ch3.spot.mere.before / done / after | narration | | Wheel by the mere. done: water slides away; something big grumbles, mere lower. after: still. 1-2 lines each.
- ch3.spot.nookB.arrive (place) / .find (narration) | | | Pocket under the old waterline; dry bundle (kit + Petals). 1-2 lines each.
- ch3.spot.camp2.arrive | place | | Bed with a shell-shaped dent; one cup; lamp lit for someone. 2 lines.
- ch3.camp.lodge.greet | speech | pip-dustwing | Pip, small shy bat: the Warden (Umber) went down to knock and said wait; Pip waits; you may rest. ≤2 lines.
- ch3.camp.lodge.shop | speech | pip-dustwing | Kits: she left spares "for whoever came". 1-2 lines.
- ch3.camp.lodge.rest | speech | pip-dustwing | Lamp trimmed, satchel safe; "she would like that you came". 1 line.
- ch3.camp.lodge.full | speech | pip-dustwing | You carry the most already. 1 line.
- ch3.camp.lodge.nofunds | speech | pip-dustwing | Not enough Petals, kindly. 1 line.
- ch3.spot.strongbox.locked / open / after | narration | | Small iron box shaped like a bell, needs a clapper. open: kits + Petals, note "for whoever came". after: empty. 1-2 lines each.
- ch3.spot.tally.arrive | place | | Sentry log: threes for years; key line "3 = all well"; signed U. Do not explain the fourth. 3 lines.
- ch3.spot.bench2.before / done / after | narration | | Still warm pool; sit; better. 1-2 lines each.
- ch3.spot.bell.question | narration | | Tongueless bell; riddle whose answer is "a clapper"; end with "The answers are on the three buttons below." 3-4 lines.
- ch3.spot.bell.a1 / a2 / a3 | choice | | a1 "A rope", a2 "A hammer", a3 "A clapper" (RIGHT = 3).
- ch3.spot.bell.right / wrong / out / after | narration | | right: a clapper drops into your hand. wrong: silence. out: bell keeps its secret. after: hangs quiet. 1-2 lines each.
- ch3.spot.nookC.arrive (place) / .find (narration) | | | Behind loose rock; a bead and Petals. 1-2 lines each.
- ch3.spot.oldlamp.find | narration | | Cold lantern, folded blanket; someone kept watch here. 2 lines.
- ch3.spot.tallydoor.question | narration | | Door cut with threes: "No voice, yet heard through stone. Three of me mean all is well." End with the buttons line. 3-4 lines.
- ch3.spot.tallydoor.a1 / a2 / a3 | choice | | a1 "A bell", a2 "A knock" (RIGHT = 2), a3 "A heartbeat".
- ch3.spot.tallydoor.right / wrong / out / after / seed | narration | | right: opens. wrong: waits. out: "the stone gives way" anyway. after: open. seed: a Seedkeeper reads the cuts. 1-2 lines each.
- ch3.spot.tallygate.locked / open | narration | | locked: Counting Door shut. open: beyond, a round hall; knock plain. 2 lines each.
- ch3.spot.door.arrive | place | | Bedrock Door. Knock three; three answer from below (first contact). Then a BOOM from the pool behind: something answers too. Shard pulls toward the door. 4 lines max.
- ch3.spot.holler.intro | boss | | Holler heaves out of the pool, throat grey with blight, gulping the air; not wicked, stuffed with sounds. 3-4 lines.
- ch3.spot.holler.hit / gulp / holler | boss | | One line per move, used as next-move hint. gulp: swallows the sound. holler: guard! (boom).
- ch3.spot.holler.crack | boss | | Grey flakes off her throat; she cannot gulp any more. 2 lines.
- ch3.spot.holler.knock | boss | | From below: three knocks; party steadies. 1-2 lines.
- ch3.spot.holler.defeat | boss | | Grey drains; she coughs up a humming stone; sleepy, embarrassed. Silence, then the knock clear: three, and a FOURTH. 4 lines.
- ch3.spot.holler.wren | speech | wren-thimblewick | "Four. That is new." She writes it down; thinks it means come. 2 lines.
- ch3.spot.holler.burdock | speech | burdock-deepdelve | Roots stop below here; afraid; will go anyway. 2 lines.
- ch3.spot.holler.zinnia | speech | zinnia-fuzzbottom | Hums to the toad; counts the fourth knock with her feelers. 2 lines.
- ch3.spot.holler.bracken | speech | bracken-spurwing | Salutes the door: a sentry still at her post; the fourth beat is a call. 2 lines.
- ch3.spot.holler.sorrel | speech | sorrel-inkcap | Fourth beat breaks the verse; something changed. 2 lines.
- ch3.spot.holler.tumble | speech | tumble-waymarsh | Chalks an arrow on the door "this way down, politely". 2 lines.
- ch3.spot.holler.juniper | speech | juniper-kettleby | Sets a covered bowl by the door; whoever knocks eats first. 2 lines.
- ch3.scene.holler.me | speech | gnome | Gnome answers: we heard you; we are coming. 1-2 lines.
- ch3.ms.ch3_hall | narration | | You reach the Knock Hall. 1-2 lines.
- ch3.ms.ch3_holler | narration | | Mere quiet; Holler snores. 1-2 lines.
- ch3.ms.ch3_chapter | narration | | The bottom of the deep rock. 1-2 lines.
- ch3.outro | narration | | Deep rock behind you; tired, together; Shard hums in time with the knock. 3 lines.
- ch3.hook | narration | | Shard no longer points down; points at the door. Below is bedrock, where nothing grows. Four knocks. 2-3 lines.
- interlude.3.intro | place | | Shard Hollow again; everyone quieter; the four knocks in the floor. 3 lines.
- interlude.3.burdock / zinnia / bracken / sorrel / tumble / juniper / wren | speech | (each npc slug) | Each trailmate's reflection per §1 moments. ≤ 300 chars each.
- ch3.banter.{burdock,zinnia,bracken,sorrel,tumble,juniper}.2 | speech | npc slug | Camp-card line about the hush or the tallies. No spoilers past the zone. 1-2 lines.
- ch3.banter.{burdock,zinnia,bracken,sorrel,tumble,juniper,wren}.3 | speech | npc slug | Camp Talk line about the Warden or Pip. 1-2 lines.
- book.lodge | book | | Almanac: Warden's Lodge, Pip, the dent in the bed. 4 lines.
- book.tally | book | | Almanac: Tally Wall and what the threes mean. 4 lines.
- book.holler | book | | Almanac: Old Holler, cured, sleeps in the mere. 4 lines.
- item.warden-scute | item | | Shed shell plate, warm, scratched with three lines. 1-2 lines.
- item.echo-stone | item | | Holler's stone: holds one sound and hums it back. 1-2 lines.
- item.bell-clapper | item | | Iron clapper, fits a small bell-shaped box. 1 line.
(Check exact speaker slug spellings against trek_crew.txt / existing texts before use.)

### 5c. Text pass 9 (B writes data; stitcher wires)
`includes/data/trek_final_2022.txt` holds: `ch3.ms.ch3a_end|The Still Gate swings open at last.\nThe knock comes again, louder, from far below.` In `trek_texts_ch3.txt`, B edits ONLY these briefs: `ch3.ms.ch3a_end` → "paid when you first pass the opened Still Gate"; `ch3.spot.stillgate.locked` → "unreachable since III-b (Gneiss blocks the way first); kept".

## 6. Art (A)
Placeholders `creature-{tallow-grub, stone-loach, crystal-weaver, bellcap-beetle, basalt-borer, old-holler}.svg` via new `tests/gen_ph_ch3b.py` (copy gen_ph_ch3.py style; writes only these 6) into `game/assets/img/ph/`. Later (Joshua): `npc-pip-dustwing`; items `warden-scute`, `echo-stone`, `bell-clapper` (emoji fallback).

## 7. Part split (disjoint files)
**A, data:** `includes/data/trek_map_ch3.txt`, `trek_spots_ch3.txt`, new `trek_chapters_ch3b.txt`, new `trek_creatures_ch3b.txt`, `tests/gen_ph_ch3b.py` + 6 SVGs. No importer registration needed.
**B, text:** new `trek_texts_ch3b.txt`, `trek_drafts_ch3b.txt`, `trek_final_2022.txt`; `trek_texts_ch3.txt` (2 briefs only). No change to trek_crew.txt or trek_drafts_ch3.txt.
**C, engine + tests:** new `includes/trek_ch3b.php` (header as trek_ch3.php; `trek_script_register('holler', …)`), new `includes/data/trek_chapters_ch3b_tune.txt`, new `tests/trek_ch3b.php`, `tests/trek_audit_ch3b.php`; `tests/treks.sh` add both after trek_audit_ch3, BEFORE the `pre_ch3.bak` restore; update `tests/trek_ch3.php` and `tests/trek_audit_ch3.php` (rows < 48 walkable, 12 III-a spots by code, milestone list prefix, Still Gate opens and pays once, slot range ~170-200, spoiler grep limited to III-a keys or dropped, `ch3.spot.stillgate.locked` into KNOWN_ORPHANS). C develops with a local require line and hands the exact line to the stitcher.
**Stitcher (Opus) only:** bootstrap.php, install.php, seed.php, trek.php, trek_data.php, trek_textpass.php, update_news.php, schema.php (no change), version. Exact adds:
1. `includes/trek.php` after line 10: `require_once __DIR__ . '/trek_ch3b.php';   // v2.0.22: Chapter III-b's boss script (Old Holler)`
2. `trek.php` TREK_QUEST_ITEMS: append `'bell-clapper'`.
3. `trek_data.php`: TREK_ITEMS `'bell-clapper' => ['Bell Clapper','misc',25,10,0,'An iron clapper. It fits a small bell-shaped box.']`, `'warden-scute' => ['Warden’s Scute','misc',140,40,1,'A shed shell plate, warm, scratched with three neat lines.']`, `'echo-stone' => ['Echo Stone','misc',110,35,1,'A smooth stone that holds one sound and hums it back.']`. TREK_BOOK_CH: `'lodge'=>3,'tally'=>3,'holler'=>3,'warden-scute'=>3,'echo-stone'=>3,'bell-clapper'=>3`. `$titles` in trek_import: `'lodge'=>'The Warden’s Lodge','tally'=>'The Tally Wall','holler'=>'Old Holler'`. trek_settings_base: `'trek_ch3_petals' => ['label'=>'Treks: Petals for finishing Chapter III (v2.0.22)','type'=>'int','default'=>'600','min'=>0,'max'=>1000000]`.
4. `trek_textpass.php`: `function trek_apply_text_2022(): int { trek_import_texts(); return trek_apply_text_file('trek_final_2022.txt', '', 9); }`
5. `bootstrap.php`: `boot_step('trek_bodies_2022', …)` guarded by `(int)setting('trek_text_pass') < 9`, requiring trek_textpass.php. `seed.php`: call `trek_apply_text_2022();` after 2021.
6. APP_VERSION ≥ 2.0.22 in bootstrap.php and install.php.
7. update_news.php: NO entry while `trek_chapters_open` is 2.

## 8. Risks and acceptance
Risks: duplicate spot letter or mis-sized zone layer silently drops spots; `w` outside zone z never drains; Holler weak start depends on name `drained_z` (rename → update spot row); duplicate check labels overwrite; old admin III-a runs: gate opens next walk, ch3a_end must not repay; seen bits pad on load (no migration); `pre_ch3.bak` ordering in treks.sh; healer stacking: worst party ≥ 65; Wren Thimblewick is also the Journey/Tansy NPC: never mention Tansy; text pass must not touch Joshua-edited rows.
Stitcher checklist: (1) `php -l` all changed PHP, no `'` in single-quoted strings (use ’). (2) `bash tests/treks.sh` rc 0 incl. trek_ch3b, trek_audit_ch3b, trek_ch3, trek_audit_ch3, trek_chapters, trek_ch2b, trek_block. (3) `trek_chapter_exists(3)`, `!trek_chapter_exists(4)`; 6 ch3 milestones in order; finish row; map 40x100; 26 spots; D only after drain, F only with Wayfinder, V only after U; main route 170-210. (4) Holler sims median 78-88 (assert ≤90), worst ≥ 65; zones 85-95 % mean. (5) Full walk pays ch3a_end, ch3_hall, ch3_holler, ch3_chapter once each + `trek_ch3_petals` once; hub says "Chapter IV is coming soon", godown refused. (6) `trek_chapters_open` 2: Ch II hub shows "Chapter III is coming soon" (no energy); 3: player reaches III-a and III-b. (7) Text audit: every requested key exists, 0 TO WRITE for players, all III-b slots draft, pass 9 replaces `ch3.ms.ch3a_end` only where unedited. (8) Upgrade check: install 2.0.21, copy over, load: db_version bumps, `boot_failed_steps` empty, text pass 9. (9) Phone screenshot 412px dark of Knock Hall and Holler fight card: centred, no sideways scroll. (10) `git diff` shows no other shared file touched.
