# Template: author the animation entry for one creature piece

Scope: place/play/chain animations of creature pieces (small creatures done: `small-creatures.json`, page `claude/mockups/pf-small-anim.html`).
Two passes: (1) sections 1-8 = the family pass (every piece gets one of 16 shared families; this stays the engine FALLBACK and the page's Generic look);
(2) section 9 = the THEMED pass (every creature gets its own palette, motif, place personality and sound lines in `themes.json`; the page's default Themed look). Do both for medium, large and boss creatures.
Background: `claude/proposal-piece-animations.md` (read its Decisions section) and the approved demo `claude/mockups/pf-piece-anim-demo.html`. Nothing in `game/` changes.
Fixed decisions (Josh 2026-11-22): the chain effect runs along the OUTER edge of the whole chain; creature pieces use the creature-heavy variant (harder slam, bigger wobble,
darker/duller colours); one setting Full/Light/Off; sound lines are visual only; the wiggle numbers of the demo (x 2.6 px, rot .06) are kept for the player variant.

## 1. Where to read the creature and its pieces
1. List: `php claude/pf-anim/dump_small.php` (JSON; reads `tests/pf_creatures_load.php` -> `pfd_foe_row()`; change the `size` test for medium/large/boss).
2. Per creature you get: `slug`, `name`, `level`, `class` (Critter, Bird, Beast, Reptile/Amphibian, Water, Plant/Fungus), `lean` (body/mind/craft), `ab` (abilities,
   e.g. `swarm`, `swarm-dense`, `venom-long`, `grudge-fury`, `ambush1`, `plated1`, `current-hard`, `D4`), `lands`, `regions`, `art` (look line), `family`, and `pieces[]`.
3. Per piece: `k` (`f:u0..u3` = the creature's own 4 unique pieces, `f:b0..b3` = its 4 class pieces with its own names; medium+ also `f:x*`), `n` name, `t` type
   (hurt, guard, heal, trick), `tag` (quick, evade, hold, thorns, poison, pierce, trip, bash or empty), `v` value, `r` knob family, `layer` (uni, base, rar, reg).
4. Source rows: `game/includes/data/pf_creature_pieces.txt` (unique 3), `pf_creatures.txt` (variants: `deck` cell `-/lean/Name:type:mult:knob:tag:life;...`, ability, art), `pf_class_base.txt`.
5. Edges on the board (`pfb_author_edges`): left = hole, right = knob, top/bottom = one knob + one hole; hurt/charm/trick have the knob on top, guard/heal the knob below. No flat edges.

## 2. Closed list of families (16). Do not invent a 17th; ask Josh.
Each has: own-edge effect (drawn on the piece's own boundary runs, 650 ms), carrier (travels 450 ms along the OUTER loop to the next piece), tone, place sound-line style, heavy rule.
| family | own | carrier | tone | place snd | heavy variant |
|---|---|---|---|---|---|
| slash | streak | comet | #fff3c8 | click | two thick streaks, 12-square comet |
| bite | jaws | chomp-trail | #f2e4c0 | click | bigger jaws, snap twice, grit |
| thrust | lance | lance-line | #ffffff | tink | thicker lance, recoil dots |
| shock | zigzag | arc-hop | #ffe27a | zig | 4 jagged lines, bigger spark |
| buzz | orbit-dots | scatter | #9bd05a | zig | 10 dark dots, wider wobble |
| bash | thump-blocks | block-roll | #d9a85a | thud | big blocks, dust |
| shield | dash-scroll | dash-run | #a9d6ea | tink (hold: thud) | thick slow dashes, corner plates |
| thorn | spikes | spike-run | #8fb86a | thud | longer spikes, dark tips |
| puff | puff-bloom | puff-trail | #dfe6ee | pop | bigger, greyer puffs |
| mend | plus-rise | plus-drift | #5f9a4a | pop | fewer, larger pluses |
| drip | drops-fall | drop-trail | #7fd35a | pop | fat drops, dark pool |
| web | strands | strand-run | #e8e4f0 | tink | thick strands, big dew drops |
| ripple | edge-ripple | ripple-run | #a8c8e8 | pop | wide, murky ripples |
| sparkle | stars | star-trail | #f6d878 | tink | fewer, harder stars |
| ember | embers-rise | ember-trail | #ff9a3c | zig | dull red embers, smoke dots |
| leaf | leaf-spin | leaf-drift | #7fb85a | pop | darker leaves, slow spin |
The page implements each id for both variants (`ownFx`, `carrier`). A new effect id means new page code plus a row here.

## 3. Decision procedure: piece -> family (first rule that fires wins; `build_small_anim.py` `decide()` does exactly this)
1. Override: `overrides.json` key `creature/piece_key` (see 6). Humans only.
2. heal, or trick with tag heal: `mend`.
3. hurt: tag pierce `thrust`; poison `drip`; bash `bash`. Else name keyword (whole-word start, lower case):
   bite|nip|pincer|mandible|fang|jaw|clamp|chomp|pinch|snap|gulp|beak|tusk|gnaw|chew|munch|nibble -> `bite`; ember|fire|flame|burn|scorch|ash|cinder|lava|smoke|boiling|crackle|blaze|heat -> `ember`;
   web|silk|snare|thread|tangle|net|sticky|stitch -> `web`; leaf|vine|petal|frond|fern|spore|moss|bloom|bark|sprig|root|bramble -> `leaf`.
   Else tag quick: `buzz` if class Critter and (ability starts with swarm, or the name says swarm/buzz/wing/flutter/whine/hum/fly/flit/mob/gnat/hornet/scatter/burst/sting), else `shock`. Else `slash` (trip and untagged).
4. guard: tag hold `shield`; thorns `thorn`. Else keyword sparkle (glow|lamp|shimmer|sheen|glitter|dew|sparkle|wink|glamour|flicker|twinkle|lure), leaf, ripple
   (water|wave|tide|surf|ripple|splash|skim|float|current|pond|pool|brine|bubble|croak|drift|swirl), web. Else evade: `ripple` if class Water else `puff`. Else `shield`.
5. trick: tag poison `drip`; bash `bash`; thorns `thorn`. Else keyword ember/web/sparkle/leaf/ripple. Else trip `web`; quick `shock`; evade `ripple` (Water) or `puff`; none `ripple` (flag).
6. Two different keyword families on one name, or a trick with no tag and no keyword: choose the best one, then FLAG `needs-art-review` (override with `"review": true`).
Heal pieces never take a keyword (the type is the signal). Mechanical tags (pierce, poison, bash, hold, thorns) beat keywords; a hand override may break that when the art says so (Fire Sting poison -> ember).

## 4. Entry format (one per piece; also what the page reads)
```json
{"creature":"aphid-swarm","piece_key":"f:u0","name":"Swarm","type":"hurt","tag":"quick","layer":"unique","v":4,"knob":"mind",
 "family":"buzz","variant":"creature-heavy","place":{"lift":2,"snd":"zig"},"play":{"own":"orbit-dots","carrier":"scatter"},
 "col":"#8fa65d","accent":"#382f1f","note":"type hurt/quick on swarm critter; palette land:any","review":"needs-art-review"}
```
`review` only when flagged. `place.lift` 1..3 = slam weight: 3 for hold/bash/thorns or family bash/shield/thorn; 1 for quick or family mend/puff/sparkle/ripple/leaf with v<=3 (else 2); +1 when v>=5 (max 3).
`place.snd` = the family's sound-line style (click = 4 corner dashes, pop = arc of 6 lines, tink = 3 small crosses, zig = buzz zigzags, thud = 2 low lines + dust). Visual only.
Creature list entry: `slug, name, level, cls, ab, lands, art, base, theme, families`.

## 5. Colour rules (two tones per piece)
1. Creature base tone: the first colour word of its `art` line or name (red, orange, yellow/golden/amber, green, blue, black/dark, white/pale/grey, brown/tan/dusty, pink, purple); else its first landscape:
   grassland #8fb04a, coast #5fa3b5, wetland #4f9a8a, forest #3f7a45, desert #c9964a, island #3fb0a0, mountain #7f8c9a, rainforest #2f9a55, tundra #a9c8dc, any #b0a080.
2. `col` (effect colour) = family tone mixed 40% toward the base tone, then dulled for the heavy variant: saturation x .75, lightness x .88, clamped to 50..74% so it stays readable on the dark felt.
3. `accent` (dark tone) = base hue at lightness 17%, saturation <= .6: used for outlines, the pool of a drip, tips of thorns, dark dots of a buzz.
4. Player (light) variant on the page = `col` mixed 45% toward white. Never hand-pick a colour unless the art line names a clearly different one; then set `col`/`accent` in the override.

## 6. Steps to author one creature (Sonnet checklist)
1. Run `php claude/pf-anim/dump_small.php | python3 -m json.tool` and find the creature. Note class, abilities, art line, lands.
2. For each piece apply section 3 in order; write the family and a one-line reason (type, tag or keyword).
3. Compute `place` (lift, snd) and `col`/`accent` (sections 4, 5). Do not edit `small-creatures.json` by hand: add a row to `overrides.json`
   (`"slug/f:u0": {"family":"web","note":"why","review":true}`; optional `col`, `accent`, `lift`, `snd`) and run `python3 claude/pf-anim/build_small_anim.py` (it also rebuilds the page and `coverage.txt`).
4. Open `claude/mockups/pf-small-anim.html#c=<slug>&shape=sq2&t=4400` and look; also try shapes row3, l3, single and `#path=1`.
5. Review checklist: every piece has a family from the closed list; no family repeats 4 times in one creature unless the creature is a one-trick (mixes are the default); a guard never gets slash/bite,
   a hurt never gets mend/shield; colours differ between creatures of one family a little (base tone), but stay in the family's feel; every `review` flag has a note; coverage prints no unused-family error.

## 7. Worked examples
- aphid-swarm (Critter, swarm, land any): Swarm hurt/quick -> rule 3: Critter + swarm ability -> `buzz` (zig, lift 2, col #8fa65d). Honeydew heal -> `mend` (pop, lift 1). Cloud Up guard/evade, no keyword, Critter -> `puff` (pop, lift 1). Sap Sip hurt/poison -> `drip` (pop, lift 2).
- weaver-ant-nest (Critter, art "green ants, stitched leaves"): Silk Nip hurt/trip: keywords silk (web) and nip (bite) -> rule 6: override `web`, `review: true`; Brood Tending heal -> `mend`; Leaf Weave guard/thorns: tag says `thorn`, but the art is a leaf wall -> override `leaf` (note: art beats tag); Larva Thread trick/quick: keyword thread -> `web`.
- croc-hatchling-scatter (Reptile/Amphibian, wetland): Hatchling Nip hurt/poison -> `drip`; Mud Spit trick/poison -> `drip` (dark pool = accent #1c3b34); Scatter Slip guard/evade -> `puff` (not Water); Dozen Bites hurt/quick: keyword bite beats quick -> `bite`. Result mix drip x2 + puff + bite: fine, poison is its identity.

## 8. QA list (page, 3x3 board, Shape + At controls; check both variants and Reduced motion)
1. Single: own effect on 4 edges, no carrier; place on the cell of the At picker (3x3 corners and centre).
2. Row of 2: carrier crosses the shared seam along the OUTER edge only, never through the middle; knob bumps appear on the free right/top edges.
3. L of 3: the carrier turns the concave corner without a jump; path outline (Show path) is one closed loop.
4. 2x2 (clockwise order): carriers go along the outer edge, last piece sends nothing; the middle point (inner corner) is never walked.
5. Row of 3 filling a whole side (col 1, row 1/2/3): effects and bumps stay inside the canvas padding (no clipping at the board edge); effect radius <= 22 px.
6. Chain of 3 where piece 1 and 3 have the same family: colours must still hand over visibly (piece 2 differs).
7. Heavy vs light: slam deeper, wobble about 1.5x, 2 swings, dust; colours duller; light = approved demo numbers.
8. Effects Light: place wiggle stays, no edge effects; Off: pieces just appear; Reduced motion: fade 120 ms, 260 ms outline flash, no sound lines or carrier.
9. Phone 390 px: no horizontal scroll, buttons 44 px high, detail list readable; `#t=ms` frozen clock gives the same picture twice (no randomness: hash noise only).
10. Console clean; `python3 claude/pf-anim/build_small_anim.py` twice gives an identical json.

## 9. Themed pass: design a creature theme (themes.json)
Goal: a hurt piece of an aphid must not look like a hurt piece of any other small bug. The family (sections 2-3) stays as the fallback; the theme is drawn on top of the
same engine (stateless function of time, hash noise only, glyph budget `MAXG` 220 per frame, no allocation in the effect loops, wiggle x 2.6 px / rot .06 never changed).
Files: `themes.json` (hand-authored: `motifs` = the catalogue, `creatures` = one theme per creature), `build_small_anim.py` (adds `theme` to each creature and `th` to each entry,
checks that every id used has a `case 'id'` in the page template, writes the themed coverage into `coverage.txt`), `small-anim.template.html` (draw code: `glyph()`, `lay()`, `mot()`, `ext()`, `themedOwn()`, `themedCar()`, `placeState(..pz)`, `persFx()`, `soundLines()`).

### 9.1 Identity reading checklist (per creature, 5 minutes)
1. Name and family slug (`dump_small.php`): what animal is it really, and which sibling variants share its family (e.g. garden-snail / ramshorn / dune-snail)?
2. `art` line: colours and the one visual thing a child would draw (big claw, glowing tail, eggshell on the head, three spines).
3. Class and abilities (`swarm*` = many small bodies; `venom*` = drops; `plated`/`toughhide` = hard shell; `ambush` = pounce; `current` = water; `drain` = sipping).
4. Lands (snow, sand, mud, pond, rainforest): the place gives the extra (snow, dust, bubbles, kelp, moon).
5. The 4 unique piece names and what they do (type/tag): each name usually names its own picture (Nest Rush, Ball Relay, Ink Jet Squirt).
6. How it moves when it lands (personality): slow and wet, springy, heavy, floaty, sideways, from below.
7. What it sounds like (sound lines, visual only): squish, whirr, croak, crack, hiss, chirp, click, pop, tink, zig, thud.

### 9.2 Theme entry (themes.json `creatures.<slug>`)
```json
"aphid-swarm": {"pal":["#a4d65e","#2f4a1a","#e8f4b0"], "m":"aphid-drop", "pers":"hop", "snd":["zig","pop"], "spd":1.1,
  "notes":"Plump green aphids on a stem: bouncing teardrop bodies; ants farm their honeydew.",
  "p":{"u0":"Swarm: a dozen green teardrops bounce off the edge",
       "u1":{"m":"honeydew-bead","c":"#e8a317","n":"Honeydew: amber beads well up and glisten"},
       "b3":{"m":"ant-march","c":"#9a5a30","n":"Ant Herd Ruse: a few herding ants march past"}}}
```
- `pal` = [main, dark, hi]: main = the glyph body (must read on the dark felt #4a3322 AND on the red/blue/purple/green stand-in pieces: lightness >= ~45%); dark = outlines,
  legs, pools; hi = highlight/alt colour (dew, glow, red tongue, white snow). Glyph code uses main for the mass; never make the dark tone the only visible part.
- `m` signature motif; `m2` optional second motif (default for guard and heal pieces); `pers` personality (9.5); `snd` = [hurt/trick style, guard/heal style]; `spd` motion speed
  (snails .55-.75, swarms 1.2-1.5); `x` optional extra override for the signature motif (siblings: dune-snail uses `dust` instead of the gloss `trail`).
- `p` per piece (key = piece key without `f:`): a string = the one-line note "Name: visual idea", or an object `{m, n, c, lay, car, x}` to change the motif, colour, layout, carrier or extra.
  Write a hand note for all 4 unique pieces; class pieces get an automatic note ("Name: <motif nm> <layout verb>") unless their name deserves its own picture (aphid b3 Ant Herd Ruse).
- Built per piece (`th`): `motif`, `mp` = {lay, spd, z, x}, `carrier`, `snd`, `col`/`acc`/`hi`/`colL`, `note`, `place` = {pers, lift, snd}, `fam` = the motif's fallback family.

### 9.3 Layouts (automatic from type/tag; override with `lay` when two unique pieces would look the same)
| type/tag | layout | what the glyphs do |
|---|---|---|
| hurt | strike | launch off the edge one after another, fly 12 px out, fade (stipple) |
| hurt/pierce | lance | a head + up to 3 followers run the length of the edge |
| hurt/bash, trick/bash | slam | shoot out 10 px and drop back |
| hurt/poison, trick/poison | fall | drop off the edge and fall 18 px (gravity) |
| guard, guard/hold | hold | line up along the edge, small breathing (hold: +1 size, speed x.8) |
| guard/evade, trick/evade | scatter | spread out 11 px and come back |
| guard/thorns, trick/thorns | bristle | push out like spikes and hold |
| heal, trick/heal | rise | rise 20 px and fade |
| trick, trick/quick | feint | blink at hashed spots, hop between them |
| trick/trip | snare | hang at spots, tied together by 1 px lines (hi colour) |
Size `z`: +1 for bash/hold or value >= 12, +1 for the creature-heavy variant (max 2). Speed: theme `spd` x 1.3 for quick, x .8 for hold.

### 9.4 Motif catalogue (67; a motif = glyph + motion + extra + carrier + fallback family + gap in px of edge per glyph)
Glyphs (pixel sprites, `glyph()`): drop bead wingdot bee speck dot spiral coil lily ant pincer plume spot frill wing skipper ball bar chip glow wisp hex claw ring ringdot shard zig crown wave fluff fish squeal needle bristle shrimp crystal flake seg eye tuft pad foot legs sandwave splat stem paw shell glint flipper spine stitch feather whirr spike loop fan dome mound puff.
Motions (`mot()`): bounce hop ooze loop jitter slide race roll trundle march queue snap clap drift curl sway flutter fallsoft flurry dig tumble blink flash zig build wave orbit pulse pop shake waddle swim dive glitter shimmer dangle wriggle pounce stick flop emerge bloom scramble burst loopdance (`none` = still).
Extras (`ext()`, one per run): glint sheen splat dust trail bubbles crumbs embers sawdust haze powder dew arc clods glowtrail sting pollen spots prints puff blood kelp marks tongue snow moon dewrun jet click ink; per glyph: threads (base to glyph), silk (short dragline), thread (glyph to glyph).
Carriers (`themedCar()`, the chain effect along the OUTER loop): train (5 glyphs in file), comet (glyph + tail), hop (arcs + landing marks), cloud (jitter cluster + 2 glyphs), trail (glossy line + head),
rings (rings left behind), blink (teleports in 6 steps), thread (silk line from the start), roll (turning glyph + dust), flutter (sway + powder), zig (zigzag), loop (circling head), tunnel (dashed under-line + mounds popping).

| motif | glyph | motion | extra | carrier | fallback | gap | look | used by |
|---|---|---|---|---|---|---|---|---|
| aphid-drop | drop | bounce | - | hop | buzz | 11 | tiny plump teardrops that bounce off the edge | aphid-swarm |
| honeydew-bead | bead | ooze | glint | trail | mend | 14 | sticky beads that well up, wobble and glint | aphid-swarm, dune-snail |
| fly-loop | wingdot | loop | sheen | cloud | buzz | 12 | metallic bodies flying small loops, wings flicker, sheen flecks | fly-swarm |
| rot-spit | drop | none | splat | comet | drip | 12 | heavy drops that fall and splat into a dark pool | fly-swarm, kelp-fly-swarm |
| mite-speck | speck | jitter | dust | cloud | shock | 8 | tiny specks with ticking legs scurrying in a dust haze | mite-swarm |
| snail-trail | spiral | slide | trail | trail | shield | 20 | a slow glossy trail laid down behind a turning spiral glint | dune-snail, garden-snail, ramshorn-pond-snail |
| ramshorn-coil | coil | roll | bubbles | roll | bash | 16 | flat coiled shells rolling, pond bubbles rising | ramshorn-pond-snail |
| lily-ripple | lily | pulse | - | rings | ripple | 18 | notched lily pads with a ring pulsing round them | ramshorn-pond-snail, tree-frog-chorus |
| ant-march | ant | march | crumbs | train | bite | 10 | three-segment ants stepping in a line, crumbs left behind | ant-scouts, aphid-swarm, carpenter-ant-gang +1 |
| fire-ant | ant | march | embers | train | ember | 10 | a red column marching, ember sparks flicking up | fire-ant-raiders |
| sawdust-gnaw | pincer | snap | sawdust | train | bite | 14 | big jaws snapping open and shut, sawdust flakes falling | carpenter-ant-gang |
| gnat-jitter | dot | jitter | - | cloud | buzz | 6 | a dense swarm of 1-2 px specks jittering in place | gnat-cloud, mosquito-storm, sandfly-cloud |
| midge-plume | plume | drift | haze | cloud | puff | 10 | pale midges with feathery antennae drifting in a haze band | midge-cloud |
| slime-spot | spot | slide | trail | trail | drip | 14 | spotted blobs oozing slowly over a wet trail | banana-slug, leopard-slug |
| frill-wave | frill | sway | - | flutter | ripple | 12 | frilled ruffles waving like sea-slug cerata, bright tips | sea-slug-drift |
| moth-dust | wing | flutter | powder | flutter | puff | 14 | soft V wings fluttering, shedding a fall of powder | dusk-moth, snow-moth |
| skipper-dew | skipper | bounce | dew | hop | sparkle | 14 | stubby round wings bouncing, dew drops flung off | dawn-skipper-flutter |
| dung-ball | ball | roll | dust | roll | bash | 16 | balls rolling along the edge with a turning highlight, dust behind | dung-beetle |
| pale-ball | ball | hop | arc | hop | bash | 20 | a pale ball lobbed in arcs, its dotted flight path shown | tumblebug-troupe |
| grave-band | bar | dig | clods | train | slash | 12 | orange-black banded backs digging in, soil clods thrown | carrion-beetle-crew |
| pincer-snap | pincer | snap | - | comet | bite | 14 | earwig forceps opening and snapping shut | earwig, rock-earwig, shore-earwig |
| scree-chip | chip | tumble | dust | roll | bash | 10 | grey scree chips tumbling, grit dust | rock-earwig |
| firefly-blink | glow | blink | glowtrail | blink | sparkle | 12 | lights that blink off and on, a dotted afterglow behind | firefly-flicker |
| wasp-dart | bar | zig | sting | zig | shock | 12 | yellow-black striped darts zigzagging, sting lines | yellowjacket-mob |
| honeycomb | hex | build | pollen | train | shield | 9 | hexagon cells appearing one by one, pollen drifting | honeybee-swarm |
| bee-pollen | bee | loop | pollen | cloud | buzz | 12 | striped furry bees looping, pollen dust trailing | honeybee-swarm |
| claw-wave | claw | wave | - | hop | bite | 18 | one oversized claw waving up and down, opening and closing | fiddler-crab-band, mangrove-crab-court |
| wisp-light | wisp | orbit | - | blink | sparkle | 12 | cold flame-tailed lights orbiting and bobbing | marsh-spark-swarm |
| croak-ring | ring | pulse | - | rings | ripple | 16 | throat-sac rings swelling and shrinking in a beat | natterjack-chorus |
| eggshell | shard | pop | - | cloud | bite | 9 | white eggshell flecks popping out and falling | croc-hatchling-scatter |
| cackle | zig | shake | spots | zig | shock | 12 | cackle zigzags shaking, dark spots blinking | hyena-pup-cackle |
| barnacle-crown | crown | pulse | - | train | shield | 14 | little three-point crowns with barnacles, pulsing | mangrove-crab-court |
| musk-wave | wave | curl | - | trail | puff | 12 | striped wavy musk lines curling up | zorilla-stink-squad |
| chick-fluff | fluff | waddle | prints | hop | slash | 14 | striped fluff balls waddling, three-toe prints behind | cassowary-chick-creche |
| spine-fish | fish | swim | - | train | slash | 12 | tiny silver fish with three back spines swimming as a shoal | stickleback-shoal |
| squeal | squeal | bounce | prints | hop | slash | 14 | three-ray squeal marks bouncing, trotter prints behind | dingo-pup-pack, piglet-squeal |
| flea-hop | speck | hop | puff | hop | buzz | 10 | specks springing in high arcs, puffs where they land | sand-fleas, snow-flea-swarm |
| mosquito-needle | needle | dive | blood | cloud | thrust | 12 | bodies with long beaks stabbing in and out, red drops | mosquito-storm |
| kelp-whirl | bristle | loop | kelp | cloud | buzz | 10 | bristly dark flies whirling over waving kelp strands | kelp-fly-swarm |
| shrimp-leap | shrimp | hop | - | hop | slash | 12 | curled shrimp shapes flipping over in high leaps | beach-hopper-horde |
| salt-glint | crystal | glitter | - | blink | sparkle | 8 | white crystals glittering through 4 phases | salt-mite-swarm |
| frost-flake | flake | fallsoft | - | flutter | puff | 10 | snowflake crosses drifting down, swaying | snow-moth |
| glow-thread | bead | dangle | threads | thread | web | 12 | silk threads hanging off the edge with glowing beads | cave-glowworm, glow-grub-cluster |
| grub-lamp | seg | wriggle | - | train | mend | 14 | pale segmented grubs wriggling, a green lamp at the tail | glow-grub-cluster |
| spider-leap | eye | pounce | silk | thread | thrust | 18 | two big front eyes pouncing in arcs on a silk dragline | jumping-spider |
| fury-tuft | tuft | shake | marks | hop | bash | 12 | fur tufts trembling with anger, angry marks popping | lemming-kit-scurry |
| toe-pad | pad | stick | tongue | hop | web | 14 | four-pad toe prints slapping down, a tongue flicks out | tree-frog-chorus |
| snow-print | foot | hop | snow | hop | bash | 14 | long hind-foot prints bounding, snow falling | snowshoe-leveret-dash |
| centipede-legs | legs | race | - | train | thrust | 10 | a comb of fine legs rippling as it races along | house-centipede-skitter |
| sand-swim | sandwave | swim | glint | trail | ripple | 12 | sand-wave arcs moving like something swims beneath, a gold glint | sandfish-skink-shoal |
| mud-flop | splat | flop | - | hop | bash | 14 | mud splats flopping up and down | croc-hatchling-scatter, mudskipper-troop |
| eel-sway | stem | emerge | - | train | thorn | 10 | thin eels rising out of the edge and swaying in a row | garden-eel-colony |
| paw-tumble | paw | tumble | - | hop | bite | 14 | pad-and-toe prints tumbling over each other | dingo-pup-pack, hyena-pup-cackle |
| blue-ring | ringdot | flash | ink | rings | drip | 14 | bright rings with a dark core flashing on and off, ink blot | blue-ring-octopus |
| ink-cloud | puff | bloom | - | cloud | puff | 14 | round ink puffs blooming from small to large | blue-ring-octopus, zorilla-stink-squad |
| shell-click | shell | queue | click | train | shield | 14 | three kinds of shell shuffling in a queue, click marks | hermit-crab-convoy |
| glass-glint | glint | shimmer | - | blink | sparkle | 12 | hollow outlines only, a light glint crossing them | glass-frog |
| flipper-track | flipper | scramble | moon | hop | slash | 12 | paired flipper marks scrambling along under a moon glint | turtle-hatchling-dash |
| urchin-spine | spine | pulse | - | train | thorn | 6 | dense radial spines growing and shrinking | sea-urchin-bed |
| leaf-stitch | stitch | march | thread | thread | web | 10 | cross-stitches walked along by green ants, a silk line joins them | weaver-ant-nest |
| bunting-flurry | feather | flurry | snow | cloud | puff | 12 | white and tawny feathers whirling with snow | snow-bunting-flurry |
| grouse-whirr | whirr | burst | - | flutter | shock | 14 | curved wing arcs bursting outward with a whirr | willow-grouse-covey |
| devil-spike | spike | pulse | dewrun | trail | thorn | 9 | rust spikes with dew beads running along the grooves | thorny-devil |
| stoat-loop | loop | loopdance | - | loop | web | 18 | spiralling loop dance, a black tail tip following | stoat |
| cockle-fan | fan | clap | jet | hop | bite | 16 | ridged fan shells clapping, squirt jets | cockle-bed |
| shell-dome | dome | trundle | - | roll | shield | 18 | plated domes trundling slowly, legs stepping | tortoise-hatchling-trundle |
| vole-tunnel | mound | pop | - | tunnel | thrust | 14 | tunnel mounds with a vole head popping up | tundra-vole-swarm |

Rules: reuse a motif only when the creatures are truly similar (sibling variants: same motif, different palette, speed or extra: garden-snail/dune-snail, leopard-slug/banana-slug,
gnat-cloud/sandfly-cloud, earwig/shore-earwig, sand-fleas/snow-flea-swarm). A new motif is usually a new combination of existing glyph/motion/extra; a new glyph, motion, extra or
carrier needs page code (a `case` in the template) and the build refuses ids without one.

### 9.5 Place personalities (the raise and click change; the wiggle stays the approved one)
| personality | raise x | extra rise px | what it does | creatures |
|---|---|---|---|---|
| squelch | 1.4 | +0 | slow wet raise, squash on landing that recovers through the wiggle, slime puddle spreads | 4 |
| hop | 1.0 | +1 | double hop on the way up, a small re-bounce after the click, dust puffs | 9 |
| thud | 0.8 | +2 | fast heavy raise, squash and a 1 px shake on landing, dust | 5 |
| flutter | 1.5 | +1 | slow floating raise with side sway, soft landing, two powder motes fall | 4 |
| skitter | 0.9 | +0 | quick raise with a tiny side jitter, leg ticks at the sides | 6 |
| scuttle | 1.0 | +0 | slides in sideways like a crab, sand dots behind | 4 |
| glide | 1.1 | -2 | low slide in from the left, almost no lift, a streak behind | 1 |
| plop | 1.0 | +4 | drops from higher, squash, a ring splashes out at the base | 3 |
| bob | 1.3 | +0 | bobs on the way up as if floating, a ripple ring on landing | 4 |
| tumble | 1.1 | +1 | rolls in (a rotation unwinds during the raise), dust arc | 2 |
| march | 1.1 | +0 | steps up in 2 px steps, crumbs at the base | 3 |
| swarm | 1.3 | +0 | dots converge onto the spot and the piece fades in out of them | 6 |
| pounce | 0.9 | +5 | crouch, then a high quick leap, speed lines below | 4 |
| burrow | 1.2 | +0 | rises up out of the ground (comes from below), a dirt mound kicks out | 4 |
| hover | 1.6 | +3 | hangs above longer with a small bob and a stipple shadow, then drops | 5 |
| trundle | 1.7 | +0 | very slow heavy raise, deep squash, dust | 3 |

Sound-line styles (visual only): click (4 corner dashes), pop (arc of 6 lines), tink (3 small crosses), zig (buzz zigzags), thud (2 low lines + dust), squish (wavy blobs at the base),
whirr (curved wing arcs), croak (3 concentric arcs above), crack (jagged broken lines), hiss (S lines), chirp (small v marks rising).

### 9.6 Worked examples
- **aphid-swarm** (Critter, swarm, any land, no art line): identity = plump green sap-suckers farmed by ants. Palette leaf green / dark stem / pale. Signature `aphid-drop`
  (teardrop glyph, bounce, hop carrier); personality `hop`; sounds zig (hurt) / pop (guard, heal). Pieces: Swarm hurt/quick -> strike: teardrops bounce off fast;
  Honeydew heal -> rise with `honeydew-bead` in amber (#e8a317); Cloud Up guard/evade -> scatter: the colony pops out and back; Sap Sip hurt/poison -> fall: sap drops fall.
  Class piece Ant Herd Ruse gets `ant-march` in rust: the ants that herd aphids march past.
- **jumping-spider** (Critter, D3, mountain/desert, "small, hairy, big front eyes"): the one thing to draw is the two big front eyes; it leaps on a dragline. Motif `spider-leap`
  (eye glyph on a hairy brown band, pounce motion, silk extra, thread carrier = a silk line from piece to piece), personality `pounce` (crouch then high leap), sounds tink / click.
  Pounce Leap hurt/pierce -> lance (the jumper runs the edge on its line); Silk Tether trick/trip -> snare (tethered spots); Hop Snare trick/trip -> override `lay: feint`
  so it differs from Silk Tether (hops spot to spot); Collar Hop hurt/quick -> strike.
- **dune-snail** (Critter, family garden-snail, desert/coast, "pale chalky shell, dusty"): sibling of the garden snail, so it SHARES `snail-trail` (spiral glint sliding) but gets a
  chalk palette, `spd` .55 (slower), extra `dust` instead of the wet `trail`, personality `trundle` instead of `squelch`. Dew Rush and Dew Lick use `honeydew-bead` in dew blue
  (#bfe4f0): the desert snail lives on dew. Result: same family feel, clearly a different animal.

### 9.7 Review checklist (themed)
1. `python3 claude/pf-anim/build_small_anim.py`: no missing theme, no unknown motif, no id without page code; themed line says 0 weak spots and 0 near-duplicate themes
   (a weak spot = 2 unique pieces of one creature with the same motif + layout + extra; a near duplicate = 2 creatures with the same signature motif + personality + extra).
2. Every unique piece has a hand note naming its picture; class pieces read sensibly with the automatic note (else add one).
3. Distinct motifs >= ~60% of the creature count; siblings share a motif only with a different palette AND speed or extra.
4. Page `#c=<slug>&t=3600` (first piece plays) and `#t=4300` (second): the motif is visible on the felt and on the pieces (main tone light enough), nothing crosses the
   piece interior except the 1 px snare/thread lines, effects stay within ~22 px of the edge, carrier visibly travels to the next piece.
5. Place `#t=450..700`: the personality reads (squash, hop, sideways, from below), the wiggle is unchanged, sound lines use the theme set.
6. Compare with `#look=generic`: the themed version must say more about the animal than the family does; if it does not, change the motif, not the family.
7. Light (player) variant, Effects Light/Off and Reduced motion behave as in section 8; console clean; phone 360-390 px without horizontal scroll.
8. Frame captures: `PFA.seek(ms)` sets the frozen clock without a reload (GIFs at 25 fps = seek in 40 ms steps and screenshot the canvas).

## 10. Larger sizes (medium 4x4, large 5x5, boss 5x5)
The same pipeline runs for every size. Parallel authors never edit a shared file: each writes only its own new files in the three folders below.

```
python3 claude/pf-anim/build_small_anim.py <small|medium|large|boss>     (php; node only when motifs/*.js exist)
  -> claude/pf-anim/<size>-creatures.json, coverage-<size>.txt (small: coverage.txt), claude/mockups/pf-<size>-anim.html
php claude/pf-anim/dump_small.php [repo-root] <size>                       (the raw creature + deck dump the build reads)
```
Small keeps its file names and is byte-identical to the pre-size-aware build (regression check: rebuild small, `git diff` shows no change in `small-creatures.json` / `coverage.txt`).

| size | board | cell (canvas px) | creatures |
|---|---|---|---|
| small | 3x3 | 56 x 47 | 67 |
| medium | 4x4 | 48 x 41 | 146 |
| large | 5x5 | 40 x 34 | 95 |
| boss | 5x5 | 40 x 34 | 11 |
Cells shrink with the board so the canvas stays 212-244 px wide and scales cleanly to a phone column (360-390 px). Shape picker: Single, Row of 2, Row of 3, L of 3, 2x2, and on 4x4+ "Bent chain of 4",
on 5x5 also "Bent chain of 5" (a shape with more than 4 cells switches Pieces to "All 8"). Only shapes that fit the board are offered. `#shape=chain4|chain5` works in the URL hash.

### 10.1 Theme fragments: `claude/pf-anim/themes/<size>/<anything>.json`
One file per author or batch (e.g. `themes/medium/batch-03.json`). All fragments of a size are merged; a creature defined twice, or a slug that is not of that size, stops the build.
```json
{"_doc": "free text, ignored",
 "creatures": { "<slug>": { "pal": ["#main", "#dark", "#hi"], "m": "<motif>", "m2": "<motif, optional>", "pers": "<personality>", "snd": ["<hurt/trick style>", "<guard/heal style>"],
                "spd": 1, "x": "<extra override, optional>", "notes": "identity sentence",
                "p": { "u0": "Name: one-line note", "u1": { "m": "<motif>", "c": "#colour", "n": "Name: note", "lay": "<layout>", "car": "<carrier>", "x": "<extra>" } } } },
 "motifs": { "<new-motif>": { "g": "glyph", "mo": "motion", "x": "extra or -", "car": "carrier", "fam": "<one of the 16 families>", "gap": 12, "nm": "short name", "desc": "what it looks like" } } }
```
- `creatures.<slug>` is exactly the themes.json entry of section 9.2 (same keys, same meaning, same rules: 4 hand notes for the unique pieces `u0..u3`, `pal` lightness >= ~45%, `fam` fallback for Generic).
- `motifs` (optional) = composition-only motifs built from ids the page already implements (glyph + motion + extra + carrier, section 9.4). The name must be new (not in themes.json, not in another fragment, not a module).
- A creature without a theme is allowed on medium/large/boss: it is built and shown with the generic families (Look: Generic is forced for it) and listed in `coverage-<size>.txt` under `themeless_creatures`. Small must have a theme for every creature.
- Every motif named anywhere in a fragment must exist (themes.json catalogue, fragment `motifs`, or a module). Unknown ids fail the build with the slug.

### 10.2 Family overrides: `claude/pf-anim/overrides/<size>/<anything>.json`
Same schema as `overrides.json` (small keeps using that file; small may also have `overrides/small/*.json`). Key = `<creature>/<piece_key>`:
```json
{"_doc": "ignored", "<slug>/f:u0": {"family": "ember", "note": "why", "review": true, "col": "#hex", "accent": "#hex", "lift": 1, "snd": "pop"}}
```
`family` must be one of the 16; `review: true` = still a best guess (reported as needs-art-review). A key twice, or a key that matches no piece, stops the build.

### 10.3 Motif modules: `claude/pf-anim/motifs/<name>.js`
New drawing code is loaded from modules; the build concatenates every `motifs/*.js` (sorted by file name) into the page at `/*__MOTIFS__*/`. Name a file after its motif; one author = one file = no merge conflict.
A module is plain ES5 that runs inside the page and calls the registration functions (the build also runs it once in a node sandbox with a stub `PFA` to read the meta, so the top level must only register):
```js
PFA.motif('ant-bridge', function (c, e, H) {            // own-edge effect, called every frame for the piece's own outer edge, p = 0..1 over 650 ms
  e.runs.forEach(function (r, ri) {                      // e.runs = the piece's outer edge runs [[s0, s1, idx], ...] (distance along the OUTER loop)
    for (var k = 0; k < 5; k++) { e.P.atq(r[0] + (r[1] - r[0]) * (k + .5) / 5);   // writes H.Q = {x, y, nx, ny} (point on the edge + outward normal)
      H.sq(c, H.Q.x + H.Q.nx * (3 + e.p * 12), H.Q.y + H.Q.ny * (3 + e.p * 12), 3, e.col); } });
}, { nm: 'bridge ants', desc: 'ants link up into a bridge', fam: 'bite', gap: 10, g: 'ant', mo: 'march', x: '-', car: 'custom',
     carDraw: function (c, e, H) { /* chain effect, only when the piece's carrier is 'custom' */ } });
PFA.glyph('newglyph', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, H) { H.sq(c, x, y, 3, C); });   // optional: a new glyph id usable by composition motifs
PFA.motion('newmotion', function (G, pp, k, ph, H) { G.up += Math.sin(pp * 6 + k) * 3; });               // optional: a new motion id (mutates the scratch G)
```
- Meta: `nm`, `desc`, `fam` (one of the 16 families = Generic fallback) are required; `gap` (default 12), `g`/`mo`/`x` (defaults dot/bounce/-) and `car` (default train, or `custom` when `carDraw` exists) are used for the catalogue, the coverage report and the id check.
  Without `carDraw` the motif's chain effect is the standard carrier named by `car`. A module motif with a `draw` function replaces the whole own-edge effect (layouts and motions are then yours to draw; `e.th.mp.lay` tells you the layout verb).
- `e` (own): `P` (perimeter: `P.atq(s)` scratch point, `P.at(s)` allocating, `P.len`, `P.runs[o]`), `o` (piece index), `runs`, `th`, `mp` = {lay, spd, z, x}, `p`, `seed`, `h` (true = creature-heavy), `z` (size step 0..2), `col`, `acc`, `hi`.
  `e` (carDraw): `P`, `a` (start distance), `d` (signed distance to the next piece, short way round), `hh` (eased 0..1), `p`, `h`, `z`, `fr`, `col`, `acc`, `hi`.
- `H` helpers: `px bx sq ln plus ringpx hash hexmix eo stip glyph lay mot ext carHead`, scratch objects `Q` and `G`, colours `WHITE DEW`. Draw only with these 1 px / small-block primitives, no allocation per frame, no `Math.random` / `Date`: every effect is a stateless function of `p`.
- Fixed rules still apply (Decisions in claude/proposal-piece-animations.md): the wiggle (x 2.6 px, rot .06) is never touched, the chain effect runs along the OUTER edge only, sound lines are visual only, the creature-heavy variant is the default. Stay within about 22 px of the edge.
- Names must be unique across all modules, fragments and themes.json (a clash stops the build). Small's existing motifs stay in the template/themes.json; modules only add. A module motif is written into a size's json/page catalogue once a theme of that size uses it.
- Test a module without touching the shared folders: `PFA_MOTIFS_DIR=<scratch dir> PFA_THEMES_DIR=<scratch dir with <size>/*.json> python3 claude/pf-anim/build_small_anim.py medium`.

### 10.4 Checklist for a batch author (medium / large / boss)
1. `python3 claude/pf-anim/build_small_anim.py <size>` once to read `<size>-creatures.json` (creatures, pieces, generic families).
2. Section 9.1 identity reading per creature; write `themes/<size>/<batch>.json` (4 hand notes per creature) and any `motifs/<name>.js`; add `overrides/<size>/<batch>.json` only where the generic family is wrong.
3. Rebuild; section 9.7 review items (0 weak spots, 0 near duplicates in your batch), open `claude/mockups/pf-<size>-anim.html#c=<slug>&t=3600` and check on the felt AND on the pieces, phone width, console clean.

## 11. The game engine (production): `game/assets/pfanim.js` + `game/assets/pfanim-data.json`
The fight page (v1 board) loads `assets/pfanim.js` before `assets/pfboardv1.js`; it fetches `assets/pfanim-data.json` (same `?v=`, cached) and draws on ONE overlay canvas
(`.pfa-fx`, z 7 inside `.pfb-world`, art pixels, margin 26 px outside the board art). Both files are GENERATED; nothing in this folder is read at run time.
```
python3 tools/build_pfanim.py            # after ANY change here: a size json, themes.json, a motif module, the template's draw code
python3 tools/build_pfanim.py --check    # tests/pfanim.sh runs this: fails when the game files are stale
tests/pfanim.sh                          # data round trip (tests/pfanim_unit.js) + the real fight page (3x3, 4x4, 5x5, boss AOE) at 390 px
```
- Reads `<size>-creatures.json` for every size that exists (small, medium, large, boss; a missing size is skipped, its creatures use the type/tag fallback), the motif catalogue,
  `small-anim.template.html` from `function hexmix(` to the gallery minus its single-loop `perimeter()` (the engine has a multi-loop one: largest outer loop; a piece with no
  outer edge, e.g. the centre of a 3x3 block, draws on its own cell and anchors to the nearest loop point), and every `motifs/*.js` module (bundled into pfanim.js in file order).
  So: build your size with `build_small_anim.py <size>` FIRST, then `tools/build_pfanim.py`, then `tests/pfanim.sh`.
- Every glyph / motion / extra / carrier / personality / sound id the data uses must have a `case 'id'` in the template draw code or be registered by a module, else the build stops.
- Look-up at run time: creature piece = `cslug` (page data) + piece name -> its themed motif (creature-heavy variant); no theme -> its generic family; no data -> the player / shared
  table (pilot table of the proposal for the 15 base pieces, the section 3 rules for every other row of pf_pieces.txt, wear_items_pieces.txt, pf_region_pieces.txt, pf_class_base.txt);
  else by tag, then type. Player pieces use the light variant, environment pieces the plain place (raise + click) and their kind's family (sun sparkle, bramble thorn, rain ripple ...).
- Hooks in `pfboardv1.js` (hand-synced into `tools/pfboardv1_part.js`): `pfaPlace` at a reveal (`revealId`) and as your own piece's chain starts, `pfaStep` in every replay step
  (fire: own edges + carrier to the next piece of `data.fx` order; a boss AOE landing pulses its cells), `pfaReset` on skip / rewind, `PFAnim.attach` after each render.
  Effects scale with the step (k = step / 950, .3..1) and never add a timer: the replay's step times are identical with effects on and off (tested).
- Setting: help sheet "Piece effects: Full / Light / Off", per device in localStorage `pfvfx` like the animation speed (`pfvspd`); no choice = Full, or Off under prefers-reduced-motion.
- Environment pieces (2.7.56): `motifs/weather_env.js` registers each of the 8 kinds with `PFA.env(kind, { ps, pl, fi })` (place motion, place effect ~600 ms, fire effect ~1200 ms); the engine plays them instead of the family look (Light = place motion only). A piece next to a Mud that fires (`ev.mud`) makes the Mud play at it. Wind pushes / Tremor falls are afterimages and shakes only.
- Budget: the JSON stays well under 250 KB for all 319 creatures (short keys, one theme per creature, motif refs by index, only what differs from the rules is stored).
