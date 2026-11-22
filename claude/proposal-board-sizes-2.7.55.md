# Board sizes by creature size (2.7.55 candidate, branch ccr-893d59b2-board-sizes)

Owner decisions (Josh, puzzle combat v1). Live code: game/includes/pfboard.php, its JS twin tools/pfengine.js,
the page game/assets/pfboardv1.js (+ the fork tools/pfboardv1_part.js), game/assets/pfight.css, harness tests/pf_play.php.
Every rule is a NEW-FIGHT rule: a fight saved before this keeps its own board (state w/h) and its own rule numbers
(compat keys `aoe`, `envmax`, `envonce` default 0 in PFB_V1_PRE, so an old state plays exactly as before).

## 1. Board size

| size   | board | env placed a round (PFB_ENV_N) | env field cap (PFB_ENV_MAX) | env piece fires once (envonce) |
|--------|-------|--------------------------------|------------------------------|--------------------------------|
| small  | 3x3   | 1                              | 1                            | yes                            |
| medium | 4x4   | 2                              | 3                            | no                             |
| large  | 5x5   | 2                              | 5                            | no                             |
| boss   | 5x5   | 2                              | 5                            | no                             |

- PFB_SIZE = small [3,3], medium [4,4], large [5,5], boss [5,5]. ?pfboard=WxH / pfight_board_test still override.
- Rules that name cells, checked on 3x3 and 5x5: the Blank opening (blankrand: a random INNER cell = the centre on 3x3, one
  of 9 on 5x5), anchors (no-blank start = centre), ground (dist 1-2 from centre; off in new fights), Wind (arrow toward a
  piece with a free cell behind it, else any side), Plant Grows (a free cell touching its newest piece), the 0.7 board-full cap.
- Isolated-cell rule on 3x3: after the opening (Blank + 2-3 pieces) a 3x3 board usually has NO isolated cell. Fallback
  (unchanged order, now documented and tested): isolated cell (3 farthest) -> a cell where it fits and links to nothing ->
  any cell where it fits -> keep it face up (pass). Tested: the small env piece is placed on 3x3 in the first rounds.

## 2. Field caps (items 2, 3)

- `envmax` = how many environment pieces may stand on the board at once (the creature's own Plant Brambles, tile `own`,
  are not counted: they are its ability). While the cap is reached the environment keeps its face-up piece (envlog
  `pass` with `cap` 1, text "the environment waits"). When a piece goes (expires, used up, fired out) the next env step
  places the face-up one on a random legal cell (pfb_env_cells).
- SMALL: one piece at a time, and it leaves after it fires once (`envonce`: env fire limit 1), so "fires / expires /
  used up" all free the slot. Medium: 2 a round as today, at most 3 standing. Large/boss: 2 a round, at most 5.

## 3. Large and boss: new environment kinds (item 4) -- ASSUMPTION

Josh's answer was "3, but 2 more total for large or boss fights". THIS IS AN INTERPRETATION (the task's reading):
2 NEW environment kinds exist that appear only in large and boss decks, and each region leans to one of them
(region flavour, the `=REGION` lines of data/pf_env.txt). The other reading ("a field cap of 3, 2 more = 5 for
large/boss") is ALSO covered: PFB_ENV_MAX large/boss = 5. Both are single constants: PFB_ENV_BIG (kinds), PFB_ENV_BIG_SIZES,
PFB_ENV_MAX. If Josh meant only one of the two, set the copies of quake/spring to 0 or the cap to 3.

Tile data (same format as data/pf_env.txt, copies small/medium/large/boss):

    quake|Tremor|quake|hc,kb,hm,km|2|0/0/1/1|Fire it in your chain: the other side's pieces touching it fall off the board.
    spring|Spring|spring|hm,kc,hb,kc|3|0/0/1/1|Fire it in your chain: you recover a tenth of your health. If the creature fires it, its Yield bar empties a tenth.

- Tremor (PFB_QUAKE_N = 2): up to 2 pieces of the other side that touch it fall (oldest first; the Blank never; a creature
  piece knocked off by your Tremor counts as used up by you). Spring (PFB_SPRING = 0.10): heal you 10% of max health, or
  the creature recovers 10% of its bar (pf_foe_heal).
- Region flavour: rocky/dry regions lean Tremor (+1): NA, CA, MENA, WCA, ESA, CSA, OC; wet/green lean Spring (+1): CB, SA,
  NWE, SE, EE, EA, SEA. pfb_env_deck drops PFB_ENV_BIG kinds outright for small and medium (a +1 lean never leaks down).

## 4. Boss AOE (item 5)

Rule `aoe` (boss fights only). Cadence: lands in rounds 2, 5, 8, ... (PFB_AOE_FIRST 2, PFB_AOE_EVERY 3). TELEGRAPH: at the
end of the round before (pfb_intent), the boss picks where its shape lands (the placement covering most of YOUR pieces;
ties by the seeded roll) and the cells are marked for your whole turn ($s['aoe'], view `aoe`, harness `!` marks).
RESOLVE: at the end of the boss's turn (after its piece and Grows), only YOUR pieces standing in marked cells count:
- break: each breaks (to your discard, shown as used up by it); a Guard piece of yours holds.
- hurt: you lose pct x max health per piece of yours there; your guard takes it first.
- drain: the boss recovers pct x its bar per piece of yours there.
Answers: do not place into the marks, chain your marked pieces away (a use-up of 3+ empties the cells), raise guard
(hurt), stand a Guard piece there (break). Nothing in the marks = nothing happens. The creature's own and env pieces are safe.

| boss               | AOE name       | shape                                   | effect      |
|--------------------|----------------|-----------------------------------------|-------------|
| coconut-crab-titan | Husk Crush     | 2x2 square                              | break       |
| robber-crab-baron  | Pincer Heist   | pincer: 2 cells at each end of a row    | drain 0.05  |
| great-hawk         | Shadow Swoop   | diagonal (main or anti)                 | hurt 0.06   |
| ancient-snapper    | Snap           | plus (centre + 4 sides)                 | break       |
| reef-leviathan     | Tidal Sweep    | a full row                              | hurt 0.05   |
| old-bramblehorn    | Bramble Crown  | ring (8 cells around a centre)          | hurt 0.04   |
| dune-wyrm          | Sand Burst     | X (centre + 4 diagonals)                | break       |
| snow-owl-monarch   | Whiteout       | the 4 corners                           | break       |
| frost-owl-regent   | Rime Glare     | diamond (4 sides of a cell, centre safe) | hurt 0.05  |
| storm-eagle        | Lightning      | a full column                           | hurt 0.07   |
| jade-jaguar        | Spirit Pounce  | L (a corner + 2 cells along each edge)  | drain 0.05  |
| (any other boss)   | Stomp          | plus                                    | hurt 0.05   |

Table PFB_AOE (PHP) / PFB_AOE (JS): slug => [shape, effect, pct, name]. Shapes in pfb_aoe_cells (anchors that keep the
whole shape on the board; works on any board from 3x3).

## 5. UI / harness

- pfb_view: `aoe` = {n, fx, pct, cells, r}; the page marks the cells (class `mk aoe`, a red hatched ring) with a chip
  "Husk Crush: lands after its move"; the replay flashes the cells and the pieces it breaks at the `aoe` note.
- Tiles scale: the board cell size is computed from the board width (3x3 cells larger, 5x5 smaller), so 5x5 fits 360px.
- pf_play show: board with `!` after a marked cell and a BOSS AOE line (name, shape, cells, effect, when).

## 6. Tests (tests/pf_board_sizes.php, tests/pf_board_sizes.sh)

dims per size (3x3/4x4/5x5/5x5); small: one env piece at a time, it regenerates after it goes, never 2 on board in 60
rounds; medium: never more than 3 env pieces; large/boss decks hold quake/spring and small/medium never do; each of the 11
bosses: the AOE telegraphs (cells marked, shape size right) then resolves on that turn (break/hurt/drain observed with a
piece placed in a mark); old-state compat (no `aoe` key = no AOE); JS twin via tests/pfengine_js.sh (1188 fights).

## 7. Retune plan

Chain-bot refit on the new boards with tests/pfboard_tune_v1.php (chain and look, offsets 0 and -4): targets small 4-5
turns, medium/large/boss 6-8, chain ~80% at level, >= ~60% four under, look high. First the size constants
PFB_V1_FOE_MULT / PFB_V1_BAR_MULT; then data/pf_creature_tune.txt scaled only where a size moved as a whole (rows keep
their relative fit). Then a collector sample: GRID=cp php tests/pf_collect.php OUT k/4 all 3 (4 shards).
