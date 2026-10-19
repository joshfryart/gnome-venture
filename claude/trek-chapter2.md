# Treks Chapter II: "The Weeping Clay" — final plan (2026-10-17)
Process: Sonnet design → Fable review → Opus final. Full drafts kept in scratchpad (chapter2-design.md, chapter2-review-fable.md); this doc is the decision.

## Decided by Joshua (2026-10-17)
1. Two drops: II-a then II-b. 2. Dark light-radius mechanic CUT (art only). 3. ~180 text lines OK (drafts ship). 4. Joshua's Ch I playthrough ≈ 20 min → Ch II ≈ 40 min total, II-a ≈ 20 min. Sizing by route steps/fights stays (≈2x); play-time estimates in the drafts were too high.

## Size (2x Ch I, measured)
Ch I = 556 walkable tiles, ~213 route steps, ~19 Hunt fights, 20 spots, 140 text keys, 2,200 milestone XP, ≈20 min real play.
Ch II = 10 zones, ~1,000 walkable, ~420 route steps, ~38 fights, 26 spots, 2 camps, 3 recruits, 2 mid-bosses + final boss, ~180 text slots, 4,400 milestone XP.
**II-a**: Seep Steps → Tin Lamp camp → Drowned Library → Potter's Row; Sorrel, Silverfin. **II-b**: Crossroads → Hush → Dim → Brewhouse camp → Sour Cistern → Drum Chamber; Tumble, Juniper, Old Pinch, Old Thrum. Joshua times II-a; that tunes II-b.

## Story
Blight Shard points down into the clay layer. Clay "weeps" blight. Cosy, a bit eerie, cured not killed. Ending hook: a slow knock from deep rock (Ch III).
Trailmates (existing CALLING_MENTORS rows): **Sorrel** Inkcap (Seedkeeper; return the Overdue Book), **Tumble** (Wayfinder; Signpost riddle — he can't read his own signs), **Juniper** (Brewroot; bring 2 Clay Pots). Wren → Ch III.

## Bosses (pattern shown a round ahead)
- **Silverfin** (Library): hit, sweep, mend (+8%). Burn before mend. Enrage <30%: extra hit.
- **Old Pinch** (Cistern): hit, grab (1 round only), squeeze (only if still held). Bark Skin breaks grab. Draining the cistern sluice first = she starts at 80%.
- **Old Thrum** (cicada nymph, Drum Chamber): hit, drum (small to all), harden (½ dmg to him), crack (+50% dmg to him AND he's stunned 1 round). Molt at 30%: cycle hit → crack → drum, still ONE action.

## Mechanics (kept small)
- **Sluices**: `w` high-water tiles drain when a sluice is turned (flag).
- **Dark zone**: art/vignette only. Glow crystals `*` reveal radius 4.
- **Cling**: Thrum's drum only (target cooldown +1).
- Shortcuts: camp-to-camp fast travel + one Slide. `+` loose clay only for 3 Wayfinder nooks.
- New tiles `:` wet clay, `w` high water, `+` loose clay, `*` crystal — each with a glyph.
- One free rest spot per long segment.
- Hush = Sneak section, single large patrols + hint (add 'o' to single-foe zone list).
- Riddle doors: 3rd fail opens ("the clay gives way") or Seedkeeper. Ch I items = bonuses, never gates.

## Difficulty
Not anchored to main gnome level. Creatures lv 17–21, bosses 22/23/24, gate = Ch I complete. Growth via TREK_TUNE + trek levels (~Lv9 → ~Lv15). Normal fights 85–95% win; bosses 75–85% at Silverfin Lv10–11, Pinch Lv13, Thrum Lv14. Sim at gnome 16 and 20.
Creatures (8): Clay Crawler, Page Silverfish, Mud Crayfish, Spadefoot Toad, Hollow Antlion, Cicada Nymph, Blind Salamander, Claybound Millipede.

## Side content
~8 stops, 3 riddles, 4 new trail events + Ch I's 8, 3 new crew moments (+ old mates reuse effects with new text), banter 6, Almanac 5, items: Overdue Book, Clay Pot, Kiln Key, Cistern Pearl.

## Economy
7 milestones (`ch2_*`), 4,400 XP at full checks, 50–100% by checks. Petal cap → per-user counter.

## Engine work (step 1, before content)
1. Per-chapter run rows + chapter select on trek.php (Ch I replay free). Carry over trek levels, kits, recruits on completion; trek_leave remembers active chapter.
2. Chapter-aware: trek_enter, milestones, text keys (ch2.*), camps/firstkit/camp_seen per chapter, boss scripts by data, Auto AI big-hit keys per boss, lore stat for trailmates.
3. Petal cap → users table.
4. Tests: Ch I regression, Ch II map/spots/reachability, boss sims.
Order: engine refactor (Ch I unchanged) → II-a → Joshua plays → II-b.
