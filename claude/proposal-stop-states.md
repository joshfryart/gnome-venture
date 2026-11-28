# Proposal: stop art states (ruined, being worked on, fixed)

Status: PROPOSAL ONLY, nothing wired in. Written 2026-11-28 for the rebuilding theme of "The Hollow in Disrepair" (`PROPOSAL-HOLLOW-MASTER.md`).
Goal: the picture of every rest stop shows where that gnome's rebuilding stands. No timers, no fail states, nothing earned is ever lost.

Numbers below come from a fresh SQLite install of the current code (branch `ccr-45ffe12f-9cokuo`) and from `game/includes/data/stop_perks.txt` (the hand-written stop catalogue). Where the two disagree it is said.

---

## 1. Inventory

### 1.1 Stops in the data

| What | Fresh install (`locations`) | Catalogue (`stop_perks.txt`) | Note |
|---|---|---|---|
| Villages | 146 (57 on a road, 89 off the road) | 148 | The 2 extra are Cattailmere and Granitegate: in the catalogue with slug `-`, not yet in `zones.txt` |
| Market towns | 14 (+ the hub, Mossbottom Market) | 14, all type `market` | A town is a stop only with `stop_marks_open` = 1 (`stop_is_place()`) |
| Havens | 18 | 18 | The brief says 21: the 3 extra are not in the data (the master doc names two new ones, Heron Stilt Village and the Cairn Keeper's Hut) |
| Stops in all | 178 | **180** (540 perks) | |
| Not stops | 35 wonders, 14 delves, 14 lairs | | They have their own ruin system (1.4) |

### 1.2 The 180 stops by kind (catalogue types)

| Kind | Villages | of which on a road | Towns | Havens | Total |
|---|---|---|---|---|---|
| camp | 13 | 2 | | 5 | 18 |
| ferry | 12 | 6 | | | 12 |
| herb | 13 | 5 | | 2 | 15 |
| inn | 13 | 13 | | 3 | 16 |
| jetty | 13 | 4 | | | 13 |
| market | 2 | 0 | 14 | 4 | 20 |
| mill | 14 | 11 | | 1 | 15 |
| orchard | 14 | 5 | | 1 | 15 |
| shrine | 14 | 4 | | | 14 |
| spring | 13 | 1 | | 1 | 14 |
| tower | 16 | 5 | | | 16 |
| workshop | 11 | 1 | | 1 | 12 |
| **Total** | **148** | **57** | **14** | **18** | **180** |

**Finding (must be settled first, decision 1 in section 8).** `locations.stop_type` in a fresh install is the derived type (`stop_derive_type()`), and it differs from the catalogue type for **123 of the 146 villages** (Poppyburrow: `shrine` in the table, `inn` in the catalogue and the master doc). The picture follows `locations.stop_type` (`stop_type_of()`), the perks follow the catalogue. Until the two are synced, a stop whose Repairs perk is "Fixed Shutters" can be drawn as a shrine.

### 1.3 Villages by kind and landscape (catalogue types, 148 villages)

| Kind | grass | forest | wetland | coast | island | mountain | desert | rainforest | tundra |
|---|---|---|---|---|---|---|---|---|---|
| camp | 2 | 2 | | 1 | 1 | 2 | 4 | 1 | |
| ferry | | | 4 | 6 | 2 | | | | |
| herb | 3 | 4 | 4 | | | | | 2 | |
| inn | 7 | | 2 | 3 | 1 | | | | |
| jetty | | | 4 | 8 | | | | 1 | |
| market | | | | 1 | | | 1 | | |
| mill | 10 | 1 | 2 | | | 1 | | | |
| orchard | 4 | 3 | | | 4 | | | 3 | |
| shrine | 1 | 4 | | | 1 | 4 | | 4 | |
| spring | | | | | 1 | 6 | 3 | 2 | 1 |
| tower | 3 | | | 4 | | 4 | 3 | | 2 |
| workshop | | 2 | | | | 4 | 3 | 1 | 1 |
| **All** | **30** | **16** | **16** | **23** | **10** | **21** | **14** | **14** | **4** |
| on a road | 28 | 4 | 6 | 9 | 6 | 3 | 0 | 1 | 0 |

**51** kind + landscape pairs are in use by villages (**25** by road villages). With the derived types of today's table the figures are 58 and 30. Havens add 6 more pairs if they are ever drawn as stops (they are not today).

### 1.4 Stop art today

| Art | Where | Count | Used by | Gap |
|---|---|---|---|---|
| Stop scenes 480 x 270, `here-stop-<kind>-<landscape>_<style>.png` | `assets/img/scenes` | 108 (12 kinds x 9 landscapes, one look each) | Here page, **road villages only** (`here_kind()` gives `stop` only when `on_road()`) | Complete for the fixed state. No ruined or under-repair twin |
| Kind fallbacks `here-stop-<kind>.png` | same | 11 + `here-stop.png` = 12 files (120 `here-stop*` files in all) | `here_layout_find()` fallback | `here-stop-market.png` is missing |
| Off-road village scene `here-village.png` | same | 1 | Here page of **all 89 off-road villages** | One picture for 89 places, whatever their kind (decision 2) |
| Town scenes `here-town-<code>.png` | same | 14 + hub + `here-town.png` | Here page of towns | One per town, fixed state only |
| Haven scene `here-haven.png` | same | 1 | Here page of havens | One picture for 18 places |
| Stop header `stop-<kind>.png` | same | 12 | `stop_art_file()`: `town.php` stop page, perk banner in `stop_living.php` | Fixed state only |
| Small stop pictures 48 x 48 `<kind>.png` + `.svg` | `assets/img/stops` | 12 + 12 | `stop_svg()`: passport kinds, Almanac, stop page; `route_stop_img()` on the trail strip | The trail strip ignores the kind: town = market, village = inn, other = camp |
| Stamps 64 x 64 `stamp-<kind>.png` + `.svg` | `assets/img/stops` | 12 + 12 (48 files in the folder) | Passport | None needed: a stamp means "visited" |
| Landmark ruin pictures `wonders/ruin/<kind>-<slug>.png` | `assets/img/wonders/ruin` | 9 (3 havens, 4 wonders, 2 delves) | `landmark_scene()`; others get the grey filter `.lmscene-ruin` | 21 landmarks start ruined (6 havens, 9 wonders, 6 delves): 5 of the 6 ruined havens have no drawn ruin |
| Tools | `tools/gen_ruin_art.py`, `tools/ruin_lib.py`, `tools/ruin_places/*.py` | | Makes the landmark ruin pictures from the live ones, hard pixels | Reuse for stops (section 5) |

---

## 2. State model

One state per stop **per gnome**, read from data that only ever goes up. Nothing is stored for the art: it is computed on each page view.

### 2.1 The building state

| State | Key | Rule (first match wins) | Why it can never go back |
|---|---|---|---|
| Always intact | `fixed` | the stop is on the always-intact list (2.3), or `stop_art_states_open` = 0, or `stop_marks_open` = 0 | Setting off = the game looks as it does today |
| Fixed | `fixed` | the Repairs bar is latched: a `stop_marks` row with `bar = 'repairs'` (`mark_latched()`) | A latch is for good |
| Being worked on | `work` | `mark_bar_get($uid, $lid, 'repairs')` >= 34, or the stop is the gnome's home village (floor, 2.3) | `mark_decay` = 0: an unfilled bar does not sink |
| Ruined | `ruin` | everything else the gnome has stood at (Repairs 0 to 33) | |
| Unknown | `unknown` | no `stop_stamps` row for this gnome and stop | Only on maps, the trail strip and the passport. On the Here page it cannot happen: arriving stamps the passport (`here_view()` calls `stop_stamp()`), so the first picture a gnome sees of any stop is the ruin |

Pace check (bar points 6 to 15 an act, `mark_round` 5; sim: 7 visit-days a bar): Repairs passes 34 on the second or third visit-day, so a stop a gnome works at is ruined for a visit or two, under repair for about five, then fixed for good. The under-repair picture is the one seen most: it deserves the most care.

### 2.2 Life overlays (small layers over any building state)

| Layer | Key | Rule | Personal or shared | Picture |
|---|---|---|---|---|
| Stocked | `stocked` | Larder latched | personal | crates, sacks and full shelves by the door of the main building |
| Merry | `merry` | Cheer latched | personal | bunting across the main building, two hanging lanterns |
| Half layers (optional) | `stocked1`, `merry1` | Larder or Cheer >= 50, not latched | personal | one crate; one string of bunting |
| Lamp | `lamp` | `stop_tier($lid)` >= 1 (tier 1 is "Bench & lantern post") | **shared**: every gnome sees the lit post, as with the road glow | the lantern post at the Stamp Post spot, lit |
| Hearth | `hearth` | the stop is the gnome's Hearth stop of the area (the "Stops: Hearth" Standing row: best stop adopted or founded), or `stop_tier` >= 2 for a raised stop | personal for the Hearth, shared for the tier | a banner on the roof ridge; Wren's handcart and desk once the area's Seal is held (`region_seals`) |

The lamp is the only layer that can change downward (tier 4 upkeep can lapse; check in `stop_upkeep_settle()` how far a tier can fall). It is a shared fact, not part of the gnome's three states, so "never lost" holds for everything personal.

A ruined stop can already be stocked or merry (bars fill side by side): bunting on a broken mill is fine, it reads as folk carrying on.

### 2.3 Stops that are never ruined

| Stop | State | Reason |
|---|---|---|
| The hub, Mossbottom Market | always `fixed` | Not in a region, has no bars. Home base |
| The 14 market towns | always `fixed` building; overlays only | The safe harbour of each area: fast travel lands there, the shops must read as open, and the story says: "The towns kept one lamp lit and the door open. Then the carts stopped coming." (town states: `proposal-town-states.md`, 2.8.100). Also 14 one-off town scenes that would each need two hand-made twins |
| The gnome's home village (`users.home_village_id`) | never `ruin`: starts at `work` | The first screen of a new gnome should be hopeful: neighbours on the scaffolding already. The first Repairs acts finish it, so M1 "The First Lamp" teaches the whole idea in one stop |
| Havens | their own system, not the Repairs bar (below) | 12 of the 18 were never ruined: the kept-up refuges of the Hollow |

**Havens.** They already have per-gnome ruins: `landmarks.ruined`, `landmark_rebuilds` (four stages), `landmark_rebuilt_by()`. A second "ruined" rule on top would contradict it. So for a haven: `ruin` = `ruined` = 1 and the gnome has no repair started; `work` = a repair with 1 to 3 stages done; `fixed` = rebuilt by this gnome, or never ruined. The haven's Repairs bar then feeds only its perk, and its Larder and Cheer layers work as at any stop.

---

## 3. Assessment per region

Villages all start ruined for a new gnome (the home village starts under repair). Towns never. Havens as the landmark data says. Wonders, delves and lairs are not stops: listed so the map legend is complete.

| Region | Villages (road + off) | Start ruined | Town | Havens (ruined at start) | Wonders / delve / lair | Special |
|---|---|---|---|---|---|---|
| The Maplewold (NA) | 10 (3 + 7), 12 with Cattailmere and Granitegate | 11 + home at `work` | Maplewold Market | Sugar Shack, Aurora Camp (0) | 2 / 1 / 1 | Start area. The master doc says the Sugar Shack is "closed until M1's Repair" but `landmarks.ruined` = 0 for the start region: one of the two must change |
| Maizehollow (CA) | 10 (4 + 6) | 10 | 1 | Market of a Thousand Chilies (0) | 2 / 1 / 1 | 6 of its villages sit on the Maplewold map |
| The Sunsprinkle Isles (CB) | 10 (3 + 7) | 10 | 1 | Driftwood Tavern (**ruined**, drawn), Turtle Nesting Beach (0) | 2 / 1 / 1 | |
| The Rainroot Reaches (SA) | 11 (5 + 6) | 11 | 1 | Gaucho Gnome Ranch (0) | 3 / 1 / 1 | |
| Mistmoor (NWE) | 10 (4 + 6) | 10 | 1 | Thatchtop Tearoom, Northern Lights Sauna (0) | 2 / 1 / 1 | 6 villages on the Maplewold map |
| Olivewhistle Shore (SE) | 10 (3 + 7) | 10 | 1 | Olive Press Piazza (**ruined**, no picture), Lemon Grove Monastery (0) | 2 / 1 / 1 | |
| Birchbramble Steppe (EE) | 10 (3 + 7) | 10 | 1 | Painted Egg House (**ruined**, no picture) | 2 / 1 / 1 | |
| The Dunewhisper (MENA) | 11 (4 + 7) | 11 | 1 | Spice Souk (**ruined**, no picture) | 3 / 1 / 1 | |
| The Greatcanopy (WCA) | 11 (3 + 8) | 11 | 1 | Drum Circle Market (**ruined**, no picture) | 2 / 1 / 1 | |
| Thornacre Savanna (ESA) | 10 (4 + 6) | 10 | 1 | Baobab Inn (0) | 3 / 1 / 1 | |
| Spicepeak (CSA) | 11 (7 + 4) | 11 | 1 | Floating Flower Market (0) | 3 / 1 / 1 | Most road stops of any area |
| Blossomreach (EA) | 10 (5 + 5) | 10 | 1 | Cherry Blossom Teahouse (**ruined**, no picture) | 3 / 1 / 1 | 4 villages on the Maplewold map |
| The Monsoon Tangle (SEA) | 11 (5 + 6) | 11 | 1 | Floating Market (0) | 3 / 1 / 1 | |
| The Coralscatter (OC) | 11 (4 + 7) | 11 | 1 | Kava Circle (0) | 3 / 1 / 1 | |
| **All** | **146 (57 + 89), 148 planned** | **147 + 1 home** | **14 intact** | **18: 6 ruined, 12 intact** | **35 / 14 / 14** | 9 wonders and 6 delves also start ruined (landmark system) |

### 3.1 The Maplewold's 28 villages

The 28 of master section 17 are the 10 villages the Maplewold owns in the data, the 2 planned ones, and 16 border villages drawn on its map that belong to Maizehollow (6), Mistmoor (6) and Blossomreach (4). All 28 have the three bars, so all 28 have the three pictures.

| Group | Villages | Count | Story use | What the art does |
|---|---|---|---|---|
| Home road villages | Poppyburrow, Honeybrook, Cloverholt | 3 | M1, M2: first lamp, hand it back | One is the home village (starts under repair). The other two are the first true ruins a gnome meets: the Maplewold grassland set must be the best-finished pictures |
| Border road villages | Larkbrook, Poppynook (CA), Windbottom, Windburrow (NWE), Honeythorpe, Clovercove (EA) | 6 | Main line road stops; the doors to band 2 | Ruined on arrival. Clovercove is the dead end of the last chapter: its picture changes on the walk home from the east |
| Story villages | Cattailmere (herb, wetland), Granitegate (tower, mountain) | 2 | M4, M6 `regular zone:4` / `zone:6` | Each chapter's flagship Repair is at the kind's ruin detail: the paddy sluice, the beacon basket |
| Maplewold off-road | Acornby, Birchhollow, Mossgate, Shellhollow, Pebblestead, Iciclecrest, Snowcombe | 7 | Side quests (section 17) | The side quest of a village is about the thing that is broken in its picture (section 4): the ruin concept is the quest hook |
| Border off-road | Frondthorpe, Orchiddell, Stonethorpe, Flintcove (CA), Fernden, Hazelmere, Froststead, Sleetford (NWE), Brambleburrow, Sprayholt (EA) | 10 | Side quests | Same. They use their own area's landscape look |

The master doc counts the "12 main line" two ways (2.3: the 12 Maplewold villages; 17: 9 road stops + 2 story villages + the town). The art does not depend on which: every village is treated the same. No chapter step should require an art state; the Repairs latch is already what a `raise` or `regular` step sits next to.

On the region map: the 11 lit markers of section 17 and the 17 "found places" all carry the state badge of section 5.4.

---

## 4. Per-kind concepts

Ruined = what is broken and cold. Being worked on = the same damage, half undone, with gnome-scale builder's props. Fixed = today's picture, untouched. The broken thing is always the one in the layout's `do` spot (the kind's main building), so the script can find it.

| Kind | Ruined | Being worked on | Fixed (exists) |
|---|---|---|---|
| camp | Fire ring cold and scattered, tents collapsed, log seats rolled away, weeds in the clearing | Fire ring relaid with a small flame, one tent up, a tarp on a rope between two trees, a stack of split logs | Campfire clearing |
| ferry | Landing posts leaning, the flat boat half sunk, the bell rope snapped, the toll hut boarded | Boat hauled out on trestles with fresh planks, new mooring post, a coil of rope, the bell rehung on a temporary pole | Ferry landing |
| herb | Beds overgrown with bramble, drying rails fallen, the hives tipped over, a hole in the croft thatch | Half the beds weeded and staked, one hive back upright, a ladder on the roof and a bundle of new thatch | Herb croft |
| inn | Shutters hanging, sign down on one chain, a sagging roof with a hole, chimney cold, door planked shut | Scaffolding on the gable, half the roof retiled in a brighter colour, sign propped by the door, smoke from one chimney | Wayfarers' inn |
| jetty | Planks missing over black water, a pile snapped, nets rotted on the rail, lanterns out | New pale planks on half the walkway, a plank and rope bridge over the gap, a net-mending frame, one lantern lit | Fishing jetty |
| market | Stalls collapsed, awnings torn and grey, a cart on its side, weeds between the cobbles | Two stalls rebuilt with bare frames, one awning up, crates being unloaded, a trestle with tools | Market hamlet |
| mill | Wheel fallen in the race, sails or paddles broken, the race choked with reeds, sacks split | Wheel back on its axle held by a block and rope, half the paddles new, a scaffold on the wall, the race cleared | Old mill |
| orchard | Trees unpruned with dead limbs, ladders broken in the grass, the cider press seized, the fence down | Dead limbs stacked, grafts bound with cloth, a new ladder against a tree, half the fence restaked | Orchard camp |
| shrine | Stone lanterns toppled, a split step, the bell on the ground, moss and ivy over the gate | Lanterns reset (one lit), the bell on a tripod hoist, the step shored with planks, ivy half cleared | Moss shrine |
| spring | Pools silted and green, the pipe cracked, the bath-house roof fallen in, no steam | One pool clear and steaming, a new pipe section on trestles, a tarp over the roof gap, buckets of silt | Hot spring |
| tower | Top rungs and platform gone, beacon basket fallen at the foot, a crack up the wall, the signal flags in tatters | Scaffolding up one side, a pulley lifting the basket, new ladder to half height, the crack pinned | Watchtower |
| workshop | Barn doors off, forge cold with a fallen chimney, tools rusting in the yard, a hole in the roof | Doors rehung (one), the chimney rebuilt in new brick, sawhorses and planks, a faint forge glow | Tinkers' workshop |

---

## 5. Art production plan

### 5.1 How many pictures

| Set | Fixed (exists) | New: ruined | New: under repair | New total | Needed by |
|---|---|---|---|---|---|
| Stop scenes, kind + landscape looks | 108 | 108 | 108 | **216** | 51 pairs are in use by villages (102 pictures), 25 by road villages (50 pictures). Generate all 216: the script does not care, and Admin can retype a stop |
| Kind fallback scenes | 11 (+ make `here-stop-market.png`) | 12 | 12 | 25 | Fallback when a look file is missing |
| Off-road village scene `here-village.png` | 1 | 1 | 1 | 2 | Only if decision 2 is "no" |
| Stop headers `stop-<kind>.png` | 12 | 12 | 12 | 24 | Stop page header, perk banner |
| Small stop pictures 48 x 48 | 12 | 12 | 12 | 24 | Trail strip, route menu, Almanac |
| State badges 12 x 12 | | | | 4 (unknown, ruin, work, fixed) | Maps, lists |
| Overlay props (5.3) | | | | 6 sprites x 9 landscape palettes = 54 tiny files, from one sheet | Here page layers |
| Town scenes | 15 | 0 | 0 | 0 | Towns are never ruined |
| Haven pictures (landmark system) | 18 live; 3 ruin pictures drawn, only 1 of them for a haven that starts ruined | 5 | 6 (new `wonders/work/`) | 11 | Existing `gen_ruin_art.py` flow, hand-placed per haven |

About **270 scripted pictures** for the stops, plus 11 for the havens.

### 5.2 Pipeline

New `tools/gen_stop_states.py` on top of `tools/ruin_lib.py` (hard pixels only, no blending, the Hearth Pop look). Output to `aseprite-source/v3/stops-states/png`, reviewed on contact sheets, then copied to `game/assets/img/scenes`.

| Step | What | Input |
|---|---|---|
| 1 Recolour | Overcast: desaturate about 40%, darken 10 to 15%, pull to a dusk tint, dim every lit lamp and window (`Pic.remap`, `dim_lights`). Sky and far background get half the effect | the fixed picture |
| 2 Find the building | The `do` and `homes` boxes of the stop's layout in `here_layouts.json` (all 120 stop layouts have `spots` with boxes). No hand-marking per picture | layout json |
| 3 Break | Per-kind recipe (12 recipes, one function each): punch a void hole in the roof, break outlines along a jagged line, drop named pieces (wheel, sign, basket) to the ground line, board the door | recipe + box |
| 4 Overgrow | Moss on top edges, ivy from the ground up, weeds on the path, rubble at wall feet. Seeded by the stop key so a picture is stable between runs | prop sheet |
| 5 Write `-ruin` | `here-<layout key>-ruin.png`, same size, same palette family | |
| 6 Under repair | Mask blend: a stepped diagonal mask over the `do` box takes the fixed pixels on one side and the ruined ones on the other (nearest neighbour, no soft edge), the rest of the scene at half the recolour. Then overlay scaffolding sized to the box, a ladder, a plank stack and a rope and pulley | ruin + fixed + props |
| 7 Write `-work` | `here-<layout key>-work.png` | |
| 8 Small sizes | Headers and 48 x 48 pictures: the same recipes at their size, with a 1-pixel crack and a 5 x 5 scaffold glyph | |
| 9 Check | Contact sheet per kind (9 landscapes x 3 states); a lint that every layout key has both twins | `here_lint_all` style |

Prop sheet (one Aseprite file, about 28 sprites, palette-swapped per landscape by the script):

| Group | Sprites |
|---|---|
| Decay | rubble x3, crack x3, moss cap x3, ivy climb, weeds x2, cobweb, boarded window, boarded door, fallen beam, torn cloth |
| Work | scaffold bay (stackable), ladder, plank stack, sawhorse, rope and pulley, tarp patch, bucket, tool trestle |
| Life | crate stack, sacks, shelf, bunting string (tileable), hanging lantern, lantern post (lit and unlit), ridge banner, Wren's handcart |

### 5.3 Overlay layers

Drawn over the scene by `here_view()`, like the existing `anim` layers (`here_layers_present()`), but shared files instead of one per layout: `here-stop-dress-<layer>-<landscape>.png`. Positions come from the layout, no hand placement:

| Layer | Anchor |
|---|---|
| `stocked` | foot of the `do` box, door side |
| `merry` | top edge of the `do` box (bunting tiled to its width), lanterns at both ends |
| `lamp` | the `stop` spot (the Stamp Post) |
| `hearth` | ridge of the `do` box; the handcart at the first free `stand` slot |

A layout may carry an optional `dress` list to move a layer by hand where the automatic spot looks wrong.

### 5.4 Small markers and page uses

| Page | Today | With states |
|---|---|---|
| Here (`here_view.php`) | the fixed scene | scene by state + overlay layers; a one-line caption under the picture ("Under repair: Repairs 60") |
| Stop page (`town.php`, `place_header_html`) | `stop-<kind>.png` | `stop-<kind>-ruin.png` / `-work.png` |
| Trail strip and route menu (`route_stop_img()` in `maps.php`) | market, inn or camp by place kind | `stops/<kind>-<state>.png` of the real stop type; unknown = the "?" ghost the passport already uses |
| Region map (`maps.php`, where landmark ruins are already flagged) | village dot | dot + state badge: grey hatch (unknown), cracked stone (ruin), crossed hammer and plank (work), gold leaf (fixed). The lamp glow stays a road matter |
| Passport (`stop_pass.php`) | stamp or "?" | unchanged; latched bars already stamp Mended / Stocked / Merry |
| Almanac stop list (`almanac.php`) | kind icon | kind icon + badge; a stop's page shows "as you found it" (the ruin picture) beside "as it stands" once fixed, so the ruin art is kept as a memory |
| Town page | town scene | unchanged; `stocked` and `merry` layers only |

### 5.5 Hand-drawn work that remains

| Item | Size |
|---|---|
| The prop sheet | 1 sheet, about 28 sprites |
| 12 kind recipes (what breaks, where, which piece falls) | 12 short functions, tuned on the Maplewold grassland look of each kind |
| Hand finish of the 12 Maplewold grassland pairs (the first pictures every gnome sees) | 24 pictures, light touch-up in Aseprite |
| Review of the other looks by contact sheet; fix the outliers (expect about 1 in 6: towers and jetties, where the building is tall or over water) | about 35 touch-ups |
| The named fallen piece per kind (wheel, sign, bell, basket, boat) cut out once per landscape look | 12 x 9 small cut-outs, script-assisted from the `do` box |
| 5 missing haven ruins + 6 haven under-repair pictures | 11, by the existing `ruin_places` method |

---

## 6. Game hooks

| What | Where | Detail |
|---|---|---|
| Setting | settings list in `includes/functions.php` | `stop_art_states_open`, default `0`. Also needs `stop_marks_open` = 1 (the bars). Off = every picture as today |
| State | new `includes/stop_art.php` | `stop_art_state(int $uid, array $node): string` returns `fixed`, `work`, `ruin` or `unknown` by section 2 (reads `mark_latched()`, `mark_bar_get()`, `stop_stamps`, `users.home_village_id`, `loc_real_kind()`; for a haven `landmark_rebuilt_by()` and `landmark_rebuilds`). Constant `STOP_ART_WORK_AT = 34`. Cached per request |
| Layers | same file | `stop_art_layers(int $uid, array $node): array` returns the keys of 2.2 (reads `mark_latched()`, `stop_tier()`, `stop_adoption()`, `region_seals`) |
| Scene pick | `here_view()` after `here_layout_find()`; helper `stop_art_scene(string $key, string $state): string` beside `here_layout_file()` | Tries `here-<key>-ruin.png` / `-work.png` (so `here-stop-<kind>-<landscape>_<style>-ruin.png`), then `here-stop-<kind>-ruin.png`, then the fixed file with CSS class `here-ruin` or `here-work` (the same idea as `.lmscene-ruin { filter: saturate(.35) brightness(.85) }`) plus the prop layers. The layout (spots, exits, stand slots) is the fixed one's in every state: the twins are drawn on the same grid |
| Header pick | `stop_art_file(string $type, string $state = 'fixed')` in `stops.php` | `stop-<type>-ruin.png`, fallback the fixed file. Callers: `town.php` line 137, `stop_perk_body()` in `stop_living.php` |
| Small pick | `route_stop_img()` in `maps.php`; `stop_svg()` in `stop_pass.php` gets an optional state | `stops/<type>-ruin.png`, `-work.png`; fallback the fixed picture with a badge |
| Map badge | region map markers in `maps.php` | `assets/img/map/state-<state>.png` |
| Moment of change | `mark_after()` in `stop_marks.php` | When an add crosses 34 or latches Repairs: one flash line and the picture changes on the next view. No popup, no timer |
| Art lint | `here_lint_all()` or a new `tools/check_stop_states.py` | Every `stop-*` layout key has both twins; sizes match |
| Tests | `tests/stop_art_states.sh` + `.php`, in the style of `tests/seals_standing.sh` | Setting off: always `fixed`. Unvisited: `unknown`. Repairs 0, 33: `ruin`; 34, 99: `work`; latched: `fixed`, and still `fixed` after 30 sleeps. Home village at 0: `work`. Town: `fixed` at any bar. Ruined haven: `ruin`, one stage done `work`, rebuilt `fixed`. Layers: Larder latch gives `stocked`, tier 1 gives `lamp`. A second gnome sees their own state at the same stop. Missing twin file falls back without error |

**Wren and the Almanac.**

| Where | Line |
|---|---|
| Wren's cover note of an area (arrival letter, by event) | "Every roof you see sagging is somebody's job nobody took. Mend what you like, in any order. I draw them as I find them." |
| Flash at 34 (from `mark_after()`) | "The scaffolding is up at {stop}. Wren has started a fresh drawing." |
| Flash at the Repairs latch | "{stop} is mended. Wren pastes the old drawing beside the new one." |
| Wren's area page (the Standing card in `journey.php`) | A count for looks only, never part of Standing: "Mended 4 of 12 · under repair 3 · still in ruins 5" |
| Almanac stop page | The before and after pair (5.4), with the date of the gnome's own game day the latch happened |
| The last page (all 14 Seals) | Sorrel's Whole Map on the left is drawn with every stop in its fixed state for this gnome, or its current state where not: an honest map, never a reproach |

---

## 7. Effort, build slices, open decisions

### 7.1 Slices

| # | Slice | Contents | Effort | Ships behind |
|---|---|---|---|---|
| 0 | Type sync (decision 1) | `locations.stop_type` from the catalogue; Cattailmere and Granitegate rows | 0.5 day code | `stop_marks_open` |
| 1 | State function and filter fallback | `stop_art.php`, the setting, tests, CSS classes `here-ruin` / `here-work`, the caption, the flash lines. No new art: the theme is visible on day one by filter alone | 1.5 days code | `stop_art_states_open` |
| 2 | Prop sheet and script, Maplewold first | Prop sheet, `gen_stop_states.py`, 12 recipes, the 12 grassland pairs hand-finished, overlay layers | 3 days art, 2 days script, 1 day code | same |
| 3 | All looks | The other 96 pairs generated, contact-sheet review, touch-ups, kind fallbacks, headers | 1 day script runs, 2 to 3 days review and touch-up | same |
| 4 | Small markers | 48 x 48 variants, badges, trail strip, route menu, region map, Almanac before and after pair | 1 day art, 1.5 days code | same |
| 5 | Havens | 5 ruins, 6 under-repair pictures, haven state in `stop_art_state()`, `wonders/work/` in `landmark_scene()` | 2 days art, 0.5 day code | same |
| 6 | Wren | Letters lines, the count on the area page, the last-page map | 1 day | `seals_open` |

Total about 16 to 18 working days, of which about 8 are art. Slice 1 alone already answers the owner's request in a plain way; slices 2 and 3 make it look right.

### 7.2 Open decisions

| # | Decision | Recommendation |
|---|---|---|
| 1 | The table's stop types differ from the catalogue's for 123 of 146 villages. Which one draws the picture? | **The catalogue.** Write the catalogue type into `locations.stop_type` in the stop-marks migration. The perks, the side quests and the per-kind ruin concepts were all written against it |
| 2 | The 89 off-road villages all show `here-village.png`. Give them the kind + landscape scenes too? | **Yes**, picture only: all 108 looks exist. Otherwise 60% of the stops have one ruined picture between them. Check the gate-view layout suits a village with one path before switching |
| 3 | Gnomes who already know a stop well find it "ruined" the day the setting goes on (no old meter latches) | **Floor at `work`** for a stop where the gnome is `local` or `pillar` (`stop_fam_level()`), computed, never stored. The visit count never goes down either, so the rule keeps "never lost" |
| 4 | Is the home village's `work` floor right, or should even home start ruined for a stronger first chapter? | **Keep the floor.** One hopeful picture first, then the two ruined road villages next door carry the drama |
| 5 | One under-repair picture, or two (early and late)? | **One** for now. The mask of step 6 takes a fraction, so a second picture (34 to 66, 67 to 99) is a later script run, not new drawing |
