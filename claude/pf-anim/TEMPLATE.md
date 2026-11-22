# Template: author the animation entry for one creature piece

Scope: place/play/chain animations of creature pieces (small creatures done: `small-creatures.json`, page `claude/mockups/pf-small-anim.html`).
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
