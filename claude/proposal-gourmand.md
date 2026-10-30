# Proposal: The Gourmand (Pomeroy Crumbworth) (2026-10-30)

Status: design only, no game code changed. Every slug below was checked against the data files on 2026-10-30, after commit `fe96526b`, which added 137 preserves. Slugs marked **NEW** do not exist yet. Codes are the codes in `regions.txt`.

One line: a travelling dormouse food writer spends two days in each region, timed to that town's festival. At his camp in the town square he tastes raw crops, cooked dishes and Pantry jars that you grew and made. Each region's table, once served, gives back one of his "Fourteen Tastes". It is a monthly loop built on existing systems: the travellers circuit, the town square, harvest quality, Pantry jar scores and the Almanac.

---

## 1. The NPC

| | |
|---|---|
| Name | **Pomeroy Crumbworth** (slug `pomeroy-crumbworth`). Checked: no clash in the game, data or `claude/`. |
| Species / personality | Dormouse / Fussy. `npc_icon()` already maps "mouse" to 🐭, so no code change is needed for the icon. |
| Look | Round and comfortably padded. Wears a mustard waistcoat with eleven labelled pockets ("salt", "pepper", "emergency biscuit", "other emergency biscuit"). A linen napkin stays tucked under his chin at all times. Carries a silver tasting spoon on a watch chain, a folding stool and a fat leather journal with a jam thumbprint on every page. |
| Voice | Grand and florid, with sudden plain truths. He judges in spoons, from one to three, and never scores a cook below the food. Short lines and complete sentences. Examples: “Honest. I’d have seconds.” “That is a jar that has been *thought about*.” |
| Quirks | (a) The napkin tuck: every tasting starts with it. (b) After a three-spoon plate he falls asleep mid-compliment, then wakes and finishes the sentence. (c) He will not taste anything he can't pronounce, so he practises the name aloud first ("ku-SHEE-…no"). (d) He can tell a bought thing at once: “I can taste the shop counter.” (e) He is the dormouse from the `round-door` road card (`road_events.txt` line 54: “A dormouse invites you in for a snack.”). He remembers everyone he has fed. |
| Why he travels | Officially: "I sneezed at Aurora Camp and my sense of taste blew away in fourteen pieces, one to every region. A piece only comes back with that region's own food, grown by someone who means it." Really, as Juniper reveals at the midpoint: he stopped cooking for anyone years ago, and food tastes of nothing when you eat it alone. The tour is how he learns to sit at a table with someone again. |
| Bio (npcs.bio) | “A travelling food writer with a napkin always tucked in. Visits every region for its festival and asks gnomes to share their cooking. Rates in spoons.” |

## 2. Story arc

There is one Hollow-wide tour a month, and everyone sees the same Pomeroy in the same place. Each player's story moves on only through their own journal: the count of **Tastes**, where a Taste is a region whose Plate, Pot and Jar the player has each served at 1 spoon or better. Beats are Almanac pages in a new chapter, "The Gourmand's Journal". They unlock once, and each pays once.

| Act | Beat (key) | Trigger | What happens |
|---|---|---|---|
| I. The Napkin | `hello` | First talk to him, at level 3 or above | He introduces himself, the sneeze and the fourteen pieces, and gives you the Journal (the gourmand.php tabs and the Almanac chapter). “Start with something raw. I like to meet an ingredient before it’s been dressed.” |
| | `first` | 1 Taste | “There! A little piece came back. Sweet smoke, I think. Or possibly regret. Either way, thank you.” |
| | `four` | 4 Tastes | He tastes salt again and is unbearable about it for a page. |
| II. Juniper's Letter | `mid` | 7 Tastes | A letter from Juniper Kettleby, the Brewroot mentor at the Brewhouse, where he camps in the Isles: “He was never ill, you know. He just stopped cooking for anyone, and then stopped tasting. Keep feeding him. And sit down while he eats. It matters.” From now on his camp panel sets **a second spoon** (a recurring visual). |
| | `home` | 10 Tastes | He asks what YOUR home tastes of. Phase 2 adds a one-off "Home Plate": any Pot dish that uses a crop from your home region, at 2 spoons, served at any stop. |
| III. Supper for Two | `finale` | 14 Tastes, then the next Long Table (day 1, Mossbottom Green) | For the only time, he cooks and you are served. “It tastes of company. I think it always did.” Rewards: title **Second Spoon**, item **NEW** `second-spoon` (garden decor: a silver spoon planted in a flowerpot), 1,000 Petals and the Almanac page "A Gnome's Larder, second edition: for {gnome}". |
| Coda | `golden` | All 42 courses at 3 spoons | Title **Golden Palate**. He asks you to judge the Long Table with him (cosmetic: your name heads the month's board). |

Recurring beats:
1. **Napkin, spoon, verdict.** Every serve's `prize()` opens the same way: “Pomeroy tucks in his napkin, lifts his spoon…”
2. **The nap.** A 3-spoon verdict ends with him asleep mid-compliment, then: “…as I was saying: splendid.”
3. **Margin notes.** The first time you earn a spoon on a course, his line for it goes into your journal.
4. **Road arrivals and departures.** He sniffs the wind on the road into town and complains about leaving on the road out (`road_meet.txt`).
5. **The Long Table.** On the 1st of each month, on Mossbottom Green, he reads out the month's best plates.
6. **The second spoon** (after `mid`): it is always laid at his table.
7. **Festival day.** On the second day of each stay, which is the town's festival, he wears the festival hat and the repeat tip pays twice. This mirrors the existing "festival day pays twice" rule in `town.php`.

## 3. The visit mechanic

### 3.1 Schedule: follow the festivals

`TOWN_FESTIVALS` (`includes/town.php`) already gives each town one day a month, in `regions.txt` order and two days apart: Mossbottom 1, NA 3, CA 5, CB 7, SA 9, NWE 11, SE 13, EE 15, MENA 17, WCA 19, ESA 21, CSA 23, EA 25, SEA 27, OC 28. Pomeroy arrives the eve of each festival and stays through the festival day:

- A region's window runs from the day after the previous town's festival to its own festival day: **2 Hollow days (48 h)**, 00:00 to 23:59 Halifax time.
- **OC runs from day 28 to the end of the month** ("island time", which matches the Coralscatter's climate trait). That is 1 to 4 days. February in a non-leap year gives OC only 1 day; late plates (3.5) cover it.
- **Day 1 is the Long Table on Mossbottom Green** (the Moss Fair). Every player can reach it, because `can_reach()` lets everyone reach HUB_REGION.
- One tour is one Hollow month. The **tour key** is `Y-m` of the region visits, and the Long Table on day 1 closes the previous month's tour.

The schedule is a pure function of the Hollow date, like `traveller_stop()` and `road_meet_candidates()`. No row ever moves him. Because the rule reads `TOWN_FESTIVALS` and sorts by day, changing a festival day moves Pomeroy with it.

### 3.2 Camp or stop-hopping: camp, with an optional stop-hop

**Decision: he camps at one fixed place in each region's town square.** He also takes an optional afternoon wander to one road stop (Phase 3, "Wayside Bite").

Why camp:
- **Road stops are uneven.** Road villages come from `ROAD_PAIRS`. CB, SE, EE, WCA, ESA and OC have 2 roads (2 to 4 road villages); CSA has 5 roads (up to about 7). A tour of "every stop" would last twice as long in Spicepeak as in the Isles.
- **Village names are made per world** (`lay_roads()`), so data can't name them. A camp is a `town_spots` slug, which can be named and checked by a lint.
- **Finding a moving NPC in 48 hours is a chore.** The town is where fast travel lands. A town spot already has an NPC shelf (`npcs_at_spot()`), a folk list, teahouse rumours and the "Today at a glance" travellers row.
- **Havens were considered and rejected.** Every region has a zone-1 haven, and it would be a lovely fit, but havens stay hidden until found. Revealing one would also hand out free credit on the Wayfinder "Find N hidden places" calling task (`calling_task_value` → `places`).
- **The traveller rule stays the same.** Like the other three travellers, you only need to be **in the region** (`can_reach($u, $town)`) to deal with him. Walking to the camp spot shows him at his table, but serving works from the spot page *or* `gourmand.php` anywhere in that region.

Wayside Bite (Phase 3, optional): on each day of a stay, from 14:00 to 17:00, he is at one road village of that region. The pick is `crc32("gmw|$date|$code") % n` over the region's road villages ordered by id. A gnome standing there (location_id matches and not mid-walk) gets one free unit of that stop's `stop_snack()`, +3 friendship and a "Wayside note" Almanac page per stop *type*: 12 pages, one per row of `stops.txt`. This happens once a Hollow day per gnome. It rewards stop-hopping without requiring it.

### 3.3 Camp per region (pick and why)

All picks are always-open town spots: no `hours` and no `months` value in `towns.txt`, or a shared spot or calling lodge made in code. Spots that close in the evening (`ma-plaza` 18–23, `mm-pub` 18–23, `gc-drums` 17–23, `ts-kopje` 17–20, `mt-lanterns` 19–23) were left out. Teahouse slugs are `<town_key>-tea`, where town_key is the lowercase region code.

| Region | Days | Festival | Camp slug | Camp name | Why |
|---|---|---|---|---|---|
| Mossbottom | 1 | Moss Fair | `hub-green` | Mossbottom Green | The Long Table. Everyone can reach it, and every thread meets there (town lore). |
| NA The Maplewold | 2–3 | Maple Moon Festival | `na-sugarshack` | The Sugar Shack | Syrup and taffy on snow. He sits on the sap pan's edge "for warmth and proximity". |
| CA Maizehollow | 4–5 | Festival of the Three Sisters | `ca-tea` | Abuela Bee’s Café | Spiced hot chocolate. The Plaza only opens in the evening. |
| CB The Sunsprinkle Isles | 6–7 | Steel-drum Carnival | `ss-brewhouse` | The Brewhouse | Juniper Kettleby's lodge (a calling mentor spot made by `ensure_calling_mentors`). His oldest friend and rival; sets up Act II. |
| SA The Rainroot Reaches | 8–9 | Potato Hundred Day | `sa-tea` | The Yerba Gourd | Maté and gossip. Rainroot's two special spots are a rope bridge and a canoe landing. |
| NWE Mistmoor | 10–11 | Puddle Day | `nwe-tea` | The Drizzle & Crumpet | A pot of tea in the rain. The Crooked Kettle only opens in the evening. |
| SE Olivewhistle Shore | 12–13 | Olive Harvest Feast | `ow-press` | The Olive Press | Bread dipped in fresh oil. “It should make you cough just a little.” |
| EE Birchbramble Steppe | 14–15 | Mushroom Moon | `ee-tea` | The Samovar | Every samovar has a name (lore). He names this one too. |
| MENA The Dunewhisper | 16–17 | Night of Lanterns and Dates | `dw-bazaar` | The Spice Bazaar | Haggling is part of the meal. |
| WCA The Greatcanopy | 18–19 | Rain-drum Festival | `wca-tea` | The Baobab Bar | Hibiscus tea, and the WCA Jar can be a hibiscus cordial. |
| ESA Thornacre Savanna | 20–21 | Coffee Bloom Gathering | `esa-tea` | The Rooibos Rest | Rooibos, and the ESA Jar can be rooibos concentrate. Sunset Rock only opens at dusk. |
| CSA Spicepeak | 22–23 | Festival of Colours | `sp-grind` | The Spice Grinders | “My eyes are watering, and that’s just the grinders.” |
| EA Blossomreach | 24–25 | Blossom Viewing | `br-blossom` | The Blossom Garden | Picnics under the trees (town lore). |
| SEA The Monsoon Tangle | 26–27 | Floating Lantern Night | `mt-float` | The Floating Market | You shop by leaning over the side, so he eats that way too. |
| OC The Coralscatter | 28–end | Tide-turn Feast | `cs-pools` | The Rock Pools | A driftwood fire and a mussel pot by the pools. |

### 3.4 How players find him

Most of this reuses code that already serves travellers.

1. **Town page, "Today at a glance"** (`town.php` `$travHere`): “🍽️ Pomeroy Crumbworth is at The Spice Bazaar” links to `gourmand.php`.
2. **"Where the travellers are" fold** (`town.php`): “in Spicepeak until Wed 23rd, then Blossomreach”.
3. **Camp spot tile and page**: his 🐭 shows on the tile (`place_ui.php` → `npcs_at_spot()`), and the spot page carries a "Pomeroy’s table" panel with the menu and Serve buttons.
4. **Teahouse rumours** (`teahouse_rumours()`): the generic "is in town / heading for" lines already work. Add one menu rumour: “Pomeroy’s asking for jars of Kimchi in Blossomreach. Five days in the jar, mind.”
5. **"Festivals coming up" fold**: “🍽️ Pomeroy will be there.”
6. **Road meetings**: during the first 2 h of his stay he is on the road into the town, and during the last 2 h on the road out (`road_meet_candidates()`), with his own chat lines.
7. **Folk page** (`folk.php?id=`): routine lines, plus "🍽️ Serve a course" where travellers normally show their deal button.
8. **`gourmand.php`**: Now, Journal, Menu and Rules tabs. Linked from Out & about, the Almanac chapter and every spot above.
9. **Next month's menu shows from day 20.** That leaves time for 14-day cordials.

## 4. Per-region table (every region in regions.txt)

Each region has three **courses**:
- **Plate**: a raw crop, judged by its harvest quality (exists: `fair_quality` → `item_quality`).
- **Pot**: a cooked dish, judged by a new dish score (5.2).
- **Jar**: a Pantry preserve, judged by its jar score (exists: `pantry_quality`).

There is also an optional **Grand** course: the region's existing feast, which needs Kitchen III and opens after that region's first Taste. Where a course has two or three variants, `(year*12 + month) % n` picks one per tour. v1 is Phase 1; a **NEW** slug arrives in Phase 2 as the "Gourmand's Own" (8.2).

Crop tiers checked against `region_crops.txt`. Gatherables are only bound to landscape, and each one used here occurs in that region's zones (`zones.txt`).

| Region | Plate (raw) | Pot (v1 / v2) | Jar (v1 / v2 / v3) | Grand | Ask (dialogue) | Taste | Golden table seed |
|---|---|---|---|---|---|---|---|
| **NA** | 3 × `wild-rice` (uncommon) | `apple-crumble` (`apple` unc, `oats` staple) / **NEW** `wild-rice-hotdish` | `raspberry-jam` / `apple-cider` (14 d) | `feast-maplewold-table` | “Wild rice, raw, if you please. I want to hear it crunch before I hear it cooked.” | sweet smoke | `pecan-seed` |
| **CA** | 3 × `tomatillo` (staple) | `three-sisters-stew` / **NEW** `bean-tamales` | `salsa-verde` / `fermented-hot-sauce` (7 d) | `feast-maizehollow-mole` | “Tomatillos! Little lanterns of sour. Three, and I’ll forgive the café for the chocolate I haven’t had yet.” | slow heat | `cacao-seed` |
| **CB** | 2 × `plantain` (staple) | `sea-grape-sorbet` (`sea-grapes`, island/coast) / **NEW** `rice-and-peas` | `guava-jam` (`guava` unc) / `lime-cordial` (`lime` staple, 14 d) | `feast-isles-ackee-pot` | “Juniper says I’m not to be fussy. So: two plantains, ripe, and I shan’t mention the colour.” | lime on the breeze | `nutmeg-seed` |
| **SA** | 3 × `quinoa` (staple) | `fiddlehead-fry` (`fiddleheads`, rainforest) / **NEW** `quinoa-soup` | `peanut-butter` (`peanut` staple) / `passion-fruit-curd` / **NEW** `chicha` | none yet (8.3) | “Quinoa, three handfuls. The Rainroot has a hundred potatoes, and I am pacing myself.” | high green | `brazil-nut-seed` |
| **NWE** | 3 × `rhubarb` (unc) | `potato-leek-soup` (`leek` staple) / **NEW** `colcannon` | `lingonberry-jam` (unc) / `blackcurrant-cordial` (unc, 14 d) | `feast-mistmoor-supper` | “Rhubarb. Raw. Don’t look at me like that. A gnome must face the sour to deserve the crumble.” | rainy-day comfort | `cloudberry-seed` |
| **SE** | 2 × `artichoke` (staple) | `grilled-sardines` (`sardine`, coast; `lemon` unc) / **NEW** `artichoke-fava-stew` | `cured-olives` (`olive` unc, 7 d) / `lemon-cordial` (14 d) | `feast-olivewhistle-supper` | “Two artichokes. I eat them petal by petal, so we’ll be here a while. Pull up a crate.” | sunshine | `caper-seed` |
| **EE** | 4 × `sorrel` (unc) | `mushroom-toast` (`chanterelle`, forest) / **NEW** `buckwheat-kasha` | `plum-jam` (`plum` staple) / `sauerkraut` (7 d) / `elderberry-cordial` (`elderberry` unc, 14 d) | `feast-steppe-table` | “Four leaves of sorrel, please. Not you, Sorrel Inkcap. You’re a snail and a scholar. The leaves.” | the good sour | `sea-buckthorn-seed` |
| **MENA** | 3 × `date` (unc) | `shakshuka` (`hen-egg`) / **NEW** `falafel` | `hummus-jar` (`chickpea` staple, `sesame` unc) / `pomegranate-molasses` (unc, 7 d) | `feast-dunewhisper-pilaf` | “Three dates, and sit. In the bazaar the first date is a joke and the second is a story.” | warm spice | `saffron-seed` |
| **WCA** | 4 × `fonio` (unc) | `rice-and-beans` (“waakye, if you squint”) / **NEW** `egusi-soup` | `pickled-okra` (`okra` staple) / `hibiscus-cordial` (`hibiscus` unc, 14 d) | none yet | “Fonio! The smallest grain in the Hollow. Four handfuls, and I shall admire every one.” | deep red earth | `grains-of-paradise-seed` |
| **ESA** | 1 × `watermelon` (unc) | `chickpea-stew` (“shiro, near enough”) / **NEW** `sukuma-wiki` | `banana-chips` (`banana` staple) / `rooibos-concentrate` (unc, 7 d) | none yet | “One watermelon. Whole. I have a spoon, and I have the afternoon.” | first light | `coffee-seed` |
| **CSA** | 3 × `apricot` (unc) | `lentil-dal` (`turmeric` unc) / **NEW** `khichdi` | `mango-chutney` (`mango` unc, `ginger` staple) / `curry-paste` (3 d, 4 kinds) | `feast-spicepeak-thali` | “Three apricots from the roof of the world. My eyes are watering already, and that’s just the grinders.” | fire | `black-pepper-seed` |
| **EA** | 2 × `persimmon` (unc) | `mackerel-rice` (`mackerel`, coast) / **NEW** `red-bean-buns` | `kimchi` (`napa-cabbage` staple, 5 d) / `pickled-daikon` (`daikon` staple) | none yet | “Two persimmons, soft as a promise. Under the blossom, if you don’t mind. I like to eat with a view.” | the quiet savoury | `yuzu-seed` |
| **SEA** | 3 × `rambutan` (unc) | `coconut-curry` (`rice` staple) / **NEW** `kangkong-stir-fry` | `lemongrass-cordial` (`lemongrass` staple, 14 d) / `tempeh` | none yet | “Rambutan! They look like they’re shouting. Three, please, and I’ll shout back.” | bright | `mangosteen-seed` |
| **OC** | 1 × `coconut` (staple) | `mussel-broth` (`blue-mussels`, `sea-salt`, coast) / **NEW** `palusami` | `pickled-samphire` (`samphire`, coast) / **NEW** `poi` | none yet | “One coconut, opened with ceremony. Island time, gnome: there is no hurry, only lunch.” | salt of the sea | `macadamia-seed` |
| **Mossbottom** | none: up to 3 late plates for any region of the tour just ended (3.5) | | | | “Sit, sit. There’s always a second spoon at this table.” | | |

Quantities: a Pot or Jar is always 1 item; the Plate quantity is shown in the table.

Rewards per region, with exact numbers in section 6:
- **Full table** (Plate, Pot and Jar each at 1 spoon or better, first time): the Taste page, 150 Petals and 2 × `<plate crop>-seed` (for example `wild-rice-seed`, `tomatillo-seed`, …, `coconut-seed`; all 14 checked).
- **Golden table** (all three at 3 spoons, first time): 300 Petals and the treasure seed in the last column. All 14 checked.

### 4.1 Signature recipes (Phase 2, NEW rows for `recipes.txt`)

Columns follow `recipes.txt`. Buff lines are suggestions for Joshua. Every ingredient slug exists.

```
wild-rice-hotdish|Wild Rice Hotdish|wild-rice:2,chanterelle:1,onion:1,celery:1|hardiness:3,lore:1|300|11|Wild rice and chanterelles baked under a lid until the kitchen smells of the woods.|meal|15
bean-tamales|Bean Tamales|corn:3,black-bean:2,chili-pepper:1|grit:3,charm:1|300|11|Little parcels of corn dough and beans, steamed in their husks. Unwrap with ceremony.|meal|15
rice-and-peas|Rice and Peas|rice:2,pigeon-pea:2,coconut:1|grit:2,nimble:2|240|10|Rice simmered in coconut milk with pigeon peas. The Isles call beans peas and nobody argues.|meal|15
quinoa-soup|Quinoa Soup|quinoa:2,potato:2,carrot:1|hardiness:3,sense:1|240|10|A highland soup for thin air and cold evenings. Potato number one of a hundred.|meal|15
colcannon|Colcannon|potato:3,kale:1,leek:1|hardiness:3,luck:1|240|11|Buttery mash with greens folded through. Hide a coin in it for luck.|meal|15
artichoke-fava-stew|Artichoke and Fava Stew|artichoke:2,fava-bean:2,lemon:1|sense:3,charm:1|240|10|Spring artichokes and broad beans with lemon. Eat it slowly, in the sun.|meal|15
buckwheat-kasha|Buckwheat Kasha|buckwheat:3,chanterelle:1,onion:1|hardiness:2,lore:2|240|10|Toasted buckwheat with mushrooms and onion. Steppe grandmothers will tell you it’s wrong.|meal|15
falafel|Falafel|chickpea:3,parsley:1,cumin:1|grit:2,sense:1|180|7|Crisp green-hearted chickpea balls. Best eaten standing up in a bazaar.|snack|3
egusi-soup|Egusi Soup|egusi:2,okra:2,spinach:1|grit:3,hardiness:1|300|11|Ground melon seeds thicken a rich green soup. A Greatcanopy Sunday.|meal|15
sukuma-wiki|Sukuma Wiki|collard:3,onion:1,tomato:1|hardiness:2,nimble:2|240|10|Collards cooked with tomato and onion. The name means “push the week”, and it does.|meal|15
khichdi|Khichdi|mung-bean:2,rice:2,turmeric:1|hardiness:2,lore:2|240|10|Rice and yellow lentils cooked soft. The dish for a tired gnome.|meal|15
red-bean-buns|Red Bean Buns|adzuki:2,wheat:2,garden-honey:1|charm:2,luck:1|180|8|Soft white buns with sweet adzuki paste inside. Picnic rules: one each, then another.|snack|3
kangkong-stir-fry|Kangkong Stir-fry|kangkong:3,garlic:1,chili-pepper:1|nimble:2,sense:1|180|7|Water spinach flashed in a hot pan with garlic. Done before you’ve found a plate.|snack|3
palusami|Palusami|taro:2,coconut:2,onion:1|hardiness:3,charm:1|300|11|Taro and coconut cream baked in a parcel. The Coralscatter’s Sunday lunch.|meal|15
chicha|Chicha|corn:3,quinoa:1|grit:1,luck:1|1080|5|A cloudy, gently fizzing highland drink of corn and quinoa. Five days in the jar.|preserve|7200|3
poi|Poi|taro:5|hardiness:2|1080|5|Pounded taro left to sour for a week. Purple, smooth and an acquired taste worth acquiring.|preserve|10080|3
```

Rule: `poi` is 1 kind and 7 days, `chicha` 2 kinds and 5 days. Both are long enough for a 3-spoon jar (see 5.3), which fills the two gaps where no existing SA or OC preserve can reach 3 spoons.

## 5. Request mechanics

### 5.1 Serving

- **Where and when:** while he is in region R (3.1) and `can_reach($u, town of R)` holds. During the Long Table, any player can serve.
- **What:** the current tour's variant for the course. You must hold `qty` of the item.
- **Quality read:** `market_stack_q($uid, $itemId, $have)`, the average quality of the stack you hold (`market100.php`). Units that aren't tracked count as plain (`MARKET_PLAIN_Q` = 35). That means traded or bought goods never pass, which is the alt guard: “I can taste the shop counter.”
- **Tasting:** spoons come from the course's bars (5.3). With 0 spoons he refuses and nothing is taken. With 1 to 3 spoons, the serve happens in one transaction (6.4) and a `prize()` card shows the napkin, the spoon, the verdict and any nap.
- **Before you press Serve**, the panel shows: “Your Wild Rice: 3 held, quality 52 (Fine) → 🥄🥄.” A mixed stack gets a hint: “Older or bought ones are dragging this down. A fresh harvest scores higher.”

### 5.2 New: dish quality (Pot and Grand)

Today a cooked dish carries no quality ("dishes are judged by recipe tier", `market100.php` header). Proposal:
- Add column `cook_pots.score INT NOT NULL DEFAULT 0`.
- `cook_start()` works out the score once per pot before taking the ingredients:
  ```
  ing  = qty-weighted mean over the recipe's ingredients of q(item), where
         q = market_stack_q(uid,item) if the gnome holds tracked units,
             else 50 for wild or animal goods (category forage/part, or hen-egg / quail-egg / goat-milk),
             else 35 (plain)
  score = clamp(round(0.8*ing + 4*kitchen_best + min(4, max(0, eff_mod(u,'luck'))) + random_int(-3,3)), 0, 100)
  ```
- `cook_collect_one()` then calls `market_note_quality($uid, $outputItemId, $dishes, (int)$pot['score'])`, the same one-line hook `pantry_collect_one()` already uses.
- Side effects: only `market_stack_q` reads it, and today that is used only by orders (crop and preserve only) and `marketday.php` (produce only). Nothing else changes. Dishes cooked before the upgrade are untracked (plain), which the UI hint explains.

Worked numbers: home crops at about 55 in a Kitchen I give 0.8*55 + 4 + 2 = 50, which is 2 spoons, just. Bought ingredients in a Kitchen III give 28 + 12 + 2 = 42, which is 1 spoon at best and pushes the player to grow.

### 5.3 Spoon bars (setting `gourmand_bars`, default `40,50,65|40,50,65|45,52,62` for plate|pot|jar; Grand uses pot)

| Spoons | Plate / Pot | Jar | Word (`fair_word`) |
|---|---|---|---|
| 🥄 | 40+ | 45+ | Good |
| 🥄🥄 | 50+ | 52+ | Fine |
| 🥄🥄🥄 | 65+ | 62+ | Splendid |

Jar bars are their own because `pantry_quality()` = 38 + min(20, 2×days) + 3×kitchen + 3×min(4, kinds) + luck ± 3 is capped by the recipe:
- A 1-day single-fruit jam tops out at about 52 at Kitchen III, so 2 spoons.
- A long ferment or a busy jar is needed for 3: 7 days with 1 kind gives 64; 3 days with 3+ kinds gives 62 or more; 14 days gives 70.

Design rule, enforced by the lint: **every region has at least one jar variant that can reach 3 spoons.**

| Region | 3-spoon jar |
|---|---|
| NA | `apple-cider` |
| CA | `fermented-hot-sauce` |
| CB | `lime-cordial` |
| SA | **NEW** `chicha` |
| NWE | `blackcurrant-cordial` |
| SE | `cured-olives`, `lemon-cordial` |
| EE | `sauerkraut`, `elderberry-cordial` |
| MENA | `hummus-jar`, `pomegranate-molasses` |
| WCA | `pickled-okra`, `hibiscus-cordial` |
| ESA | `rooibos-concentrate` |
| CSA | `curry-paste` |
| EA | `kimchi` |
| SEA | `lemongrass-cordial` |
| OC | **NEW** `poi` |

Phase 1 caveat: SA and OC jars cap at 2 spoons until Phase 2 ships.

### 5.4 The Gourmand's Journal (collection and progress)

- The `gourmand.php?t=journal` page shows 14 region cards.
  - Each card has the Taste name (shown as a silhouette until earned), three course slots with 🥄 marks and the best quality, and a gold spoon for Grand.
  - The header reads: **Tastes 5/14 · Spoons 23/126 · Grand 1/8**.
- Almanac chapter "The Gourmand's Journal":
  - 14 Taste pages (`gourmand:taste:NA` …): his write-up of the region plus your best plates.
  - The beat pages (`gourmand:beat:hello` …).
  - Later, 12 Wayside notes (`gourmand:wayside:<stop type>`).
- **Menu tab:** this tour and the next (from day 20). For each of the 14 regions: the three courses with jar days. This is how players plan their preserves.
- **Long Table board** (day 1, `hub-green` panel and Now tab): the top 5 gnomes of the closed tour by spoons served, with ties broken by earlier time. It uses `profile_link()`, and players can opt out through the existing garden-privacy idea; this is Open question 9.

### 5.5 Late plates (mercy rule)

On day 1 at the Long Table, a gnome may serve **up to 3** courses (`gourmand_late_max`) from the tour that just ended, for any region they missed.
- Late plates pay the repeat tip, and their spoons count toward the ledger.
- They never count for the Long Table board.
- This covers February's 1-day OC visit and anyone away for a weekend.

## 6. Rewards, progression, repeat play, anti-grind

### 6.1 Rewards (all settings, defaults shown)

| What | Once per | Pays |
|---|---|---|
| Reach 🥄 on a course | lifetime, per region+course | 60 Petals, 20 XP (`gourmand_pay` `60,60,120`, `gourmand_xp` `20,20,40`) |
| Reach 🥄🥄 | lifetime | +60 Petals, +20 XP |
| Reach 🥄🥄🥄 | lifetime | +120 Petals, +40 XP. Skipping levels pays every skipped level. |
| Repeat serve (already paid at this level) | per tour, per region+course | 25 Petals, 8 XP (`gourmand_tip`). Doubled on the festival day. |
| Full table (a Taste) | lifetime, per region | Taste page, 150 Petals, 2 × plate-crop seed |
| Golden table | lifetime, per region | 300 Petals, 1 × region treasure seed (section 4) |
| Grand course at 🥄+ | lifetime, per region (8) | 200 Petals, 40 XP, gold-spoon mark |
| Long Table seat (served 7+ courses in the tour) | per tour | 50 Petals, `tbuff:charm:2:240` |
| Finale | once | 1,000 Petals, title **Second Spoon**, item `second-spoon` |
| Friendship with Pomeroy | per serve | +5 (+10 at 🥄🥄🥄), through `friend_add()` |

Lifetime ceiling:
- Courses: 42 × 240 = 10,080 Petals.
- Tables: 14 × 150 + 14 × 300 = 6,300 Petals.
- Grand: 8 × 200 = 1,600 Petals.
- Total: about 18,000 Petals and 14 treasure seeds, earned over many months.

For comparison, region medals are 200/500/1,500 × 14, about 30k.

Monthly ceiling after that: about 45 serves × 25 = 1,125 Petals, or about 2,250 if every serve lands on a festival day.

Titles come from `gourmand_titles()`, merged in `book.php` next to `calling_titles` and `stop_titles`:
- **Guest of the Gourmand** (1 Taste)
- **Well Fed** (7)
- **Second Spoon** (finale)
- **Grand Diner** (all 8 Grand courses)
- **Golden Palate** (42 × 🥄🥄🥄)

### 6.2 Progression and when each course opens

- **Plate:** a garden only, so a fresh level-3 gnome can join.
- **Pot:** needs a Kitchen.
- **Jar:** needs a Pantry (600 Petals + 4 planks).
- **Grand:** needs Kitchen III.

Reaching far regions needs `can_fast_travel()`, which requires walking there once, so the journal fills as the map does. Native crops score +5 on the Plate (`fair_quality` `_native`), which rewards having a garden in that region.

### 6.3 Repeat-play hooks

- Variants rotate every month (`(Y*12+m) % n`), so the same region asks for a different Pot or Jar.
- There are 126 spoon slots, plus Grand.
- The Long Table board and seat give a monthly social beat.
- Gourmand's Own recipes (Phase 2) are taught as **recipe cards** on a region's first Full table: `gourmand_teach()` inserts `user_recipes`, so the recipe appears before you have collected every ingredient. The new dish then enters that region's Pot rotation, so the next visit asks for the dish he just taught you.
- Phase 3 adds an optional Brewroot tie-in (calling event `serve`) and Wayside notes.

### 6.4 Anti-grind and anti-exploit

1. **One serve per course per tour** comes from `UNIQUE(user_id, tour, region, course)` on `gourmand_plates`, inserted first as the claim (the repo's pattern (b)). The whole serve sits in one transaction: lock the users row with `UPDATE users SET id = id`, re-read, insert the claim, `give_item(-qty)`, upsert the ledger, pay. That is pattern (c).
2. **Pay once per spoon level:** `gourmand_ledger.paid` is raised with a conditional `UPDATE … SET paid = ? WHERE id = ? AND paid = ?` and checked with rowCount. Table, Golden and Grand payouts are separate ledger rows (`course` = `table` | `gold` | `grandpay`) claimed the same way, never through `unlock_entries()` return values.
3. **No alt-feeding:** quality comes from `item_quality`. Traded, bought or market goods are untracked, so they count as plain 35 and fall below every 1-spoon bar.
4. **Not a Petal pump:** the repeat tip (25) is under the sell value of any dish or jar it consumes, so selling always beats serving for repeats. Only first-time spoon rewards are generous, and those are finite.
5. **No daily-chore pressure:** each region is visited once a month, missing one costs nothing permanent, and late plates catch up to 3.
6. **No energy cost to serve** (cooking already costs energy). Guests are refused (`is_guest_uid`). Players need level 3 (`gourmand_min_level`). `fresh_hold` is not needed: nothing can be traded out.
7. **Stack dilution** is shown before serving. Serving takes from the stack and leaves its average unchanged.
8. **Clock edges:** everything runs on Hollow time. Stop keys `tour|code` match traveller dealt-checks. For tests and admin preview, the setting `gourmand_force_date` (empty in production, like `hollow_season_forced`) pins the date.
9. **Wayside Bite** (Phase 3) is `UNIQUE(user_id, day)` and only gives a cheap snack.
10. **Off switch:** `gourmand_open()` = `is_admin() || setting('gourmand_open') === '1'`, the same as `catfish_open()`. When it is off, he is filtered out of every traveller listing (7.3).

## 7. Data model and touch-points (repo idiom)

### 7.1 New data file `game/includes/data/gourmand.txt`

It is read with `stops_file_rows()` and a static cache, like `road_meet_lines()` and `wonder_texts()`. There is no table import in Phase 1; Phase 3 can import it into tables for an Admin tab, keeping admin edits the way `ensure_calling_quests()` does.

```
# The Gourmand (proposal). Pomeroy Crumbworth's tour: one row per camp, menu course and story beat. Never use a pipe inside a field; ’ for apostrophes.
#
# R|region code|camp spot slug|taste name|camp line (spot panel)|arrival line (road in)|leaving line (road out)
# M|region code|course (plate|pot|jar|grand)|variant (1..3)|item slug|qty|ask line|margin note (written in the journal at the first spoon)
#   plate = a crop's produce item from that region (staple or uncommon); pot = a snack or meal recipe; jar = a preserve recipe; grand = a feast-
#   Variant n of a course is used when (Y*12+m) % (number of variants) == n-1.
# B|beat key|tastes needed (or 0 = first talk)|title|text (Almanac page body; {gnome} = the gnome's name)
#
R|NA|na-sugarshack|sweet smoke|Pomeroy has claimed the end of the sap pan, “for warmth and proximity”.|Pomeroy waddles in from Mossbottom, sniffing the maples.|Pomeroy sets off for Maizehollow with a pocket of taffy he thinks nobody saw.
M|NA|plate|1|wild-rice|3|Wild rice, raw, if you please. I want to hear it crunch before I hear it cooked.|Nutty, grassy, faintly smoky. The lake is in it somewhere.
M|NA|pot|1|apple-crumble|1|Something warm with apples in it. A crumble. I won’t say please twice.|The crust gave way like a good argument.
M|NA|jar|1|raspberry-jam|1|A jar of raspberry, set soft. I shall test the wobble.|It wobbled. It was right to.
M|NA|jar|2|apple-cider|1|Cider, two weeks in the jar. Patience is an ingredient.|Sharp, cloudy, cold. Autumn talking.
M|NA|grand|1|feast-maplewold-table|1|The whole Maplewold on one table. I’ve cleared my afternoon.|Pecans. Cranberries. I may need to lie down.
...
R|CB|ss-brewhouse|lime on the breeze|Pomeroy and Juniper Kettleby are arguing about gravy at the copper kettle. Neither is winning.|…|…
B|hello|0|The Napkin|…
B|mid|7|Juniper’s Letter|Dear {gnome}. He was never ill, you know. …
```

The lint lives in `tests/gourmand.php`. It checks:
- Every code in `regions.txt` has one R row and at least one plate, pot and jar.
- Every camp slug exists in `town_spots` after install.
- Plate slugs are produce of that region's staple or uncommon tier.
- Pot recipes are snack or meal, jars are preserves and grand recipes start with `feast-`.
- At least one jar variant per region has `min(20,2·days) + 3·min(4,kinds) ≥ 15`. That is the 62 bar at Kitchen III: 38 + 9 + 15 = 62.
- No line is over 140 characters.

### 7.2 Tables (`gourmand_schema($PK, $ID, $END)` returns `[$t, $i, $c]`, merged at the end of `schema.php` like `trek_schema()`)

```sql
CREATE TABLE IF NOT EXISTS gourmand_plates (
    id $PK,
    user_id INT NOT NULL,
    tour CHAR(7) NOT NULL,              -- 'YYYY-MM' of the region visits (the Long Table on day 1 serves the month before)
    region VARCHAR(4) NOT NULL,         -- region code
    course VARCHAR(8) NOT NULL,         -- plate | pot | jar | grand
    item_id INT NOT NULL,
    qty INT NOT NULL DEFAULT 1,
    quality INT NOT NULL DEFAULT 0,
    spoons INT NOT NULL DEFAULT 0,
    late INT NOT NULL DEFAULT 0,        -- 1 = served at the Long Table
    coins INT NOT NULL DEFAULT 0,
    xp INT NOT NULL DEFAULT 0,
    at DATETIME NOT NULL
)$END;
CREATE TABLE IF NOT EXISTS gourmand_ledger (
    id $PK,
    user_id INT NOT NULL,
    region VARCHAR(4) NOT NULL,
    course VARCHAR(8) NOT NULL,         -- plate | pot | jar | grand, plus claim rows: table | gold | grandpay
    best_q INT NOT NULL DEFAULT 0,
    spoons INT NOT NULL DEFAULT 0,
    paid INT NOT NULL DEFAULT 0,        -- highest spoon level already paid (claim rows: 0/1)
    served INT NOT NULL DEFAULT 0,
    first_at DATETIME NULL,
    last_at DATETIME NULL
)$END;
-- Phase 3
CREATE TABLE IF NOT EXISTS gourmand_wander (id $PK, user_id INT NOT NULL, day CHAR(10) NOT NULL, loc_id INT NOT NULL, at DATETIME NOT NULL)$END;
```

Indexes:
- `UNIQUE uq_gourmand_plate (user_id, tour, region, course)`
- `idx_gourmand_tour (tour, late, spoons)` (for the board)
- `UNIQUE uq_gourmand_ledger (user_id, region, course)`
- `UNIQUE uq_gourmand_wander (user_id, day)`

Column added through the `$c` list in `schema.php`: `['cook_pots', 'score', 'INT NOT NULL DEFAULT 0']`.

No new npcs columns: Pomeroy is `npcs.traveller = 'gourmand'`. `circuit_offset` is unused for him.

### 7.3 New file `game/includes/gourmand.php` (prefix `gourmand_`, the way Puzzle Pals uses `ppal_`)

| Function | Does |
|---|---|
| `gourmand_settings()` | `gourmand_open` (0), `gourmand_min_level` (3), `gourmand_bars`, `gourmand_pay`, `gourmand_xp`, `gourmand_tip` (25), `gourmand_tip_xp` (8), `gourmand_table_pay` (150), `gourmand_gold_pay` (300), `gourmand_grand_pay` (200), `gourmand_late_max` (3), `gourmand_force_date` (''). Merged into `settings_schema()`. |
| `gourmand_open(): bool` | Admins always; players only when the setting is on. |
| `gourmand_now(): int` | `time()`, or noon of `gourmand_force_date`. |
| `gourmand_stop(?int $ts): array` | `['town','code','stop'=>"$tour|$code",'tour','starts','ends','next','long_table'=>bool,'festival'=>bool,'camp'=>slug]`. A pure function of `hollow_date('j'/'t')` and `TOWN_FESTIVALS`. |
| `gourmand_rows(bool $reload=false)` | The parsed data file (static cache). |
| `gourmand_menu(string $code, string $tour): array` | course => M row (the variant for this tour). |
| `gourmand_itinerary(string $tour): array` | 15 stops with dates and menus (Menu tab). |
| `gourmand_spoons(string $course, int $q): int` | 0 to 3 from the bars. |
| `gourmand_item_q(int $uid, int $itemId): int` | `market_stack_q`. |
| `gourmand_dish_score(array $u, array $stock): int` | Section 5.2. Called from `cook_start()`. |
| `gourmand_serve(array $u, string $course, string $lateRegion = ''): array` | `[ok, msg]`, the whole flow in 6.4. |
| `gourmand_tastes(int $uid): int`, `gourmand_progress(int $uid): array` | Journal counts. |
| `gourmand_beats(int $uid): void` | Unlocks beat pages by Tastes and pays the finale through a ledger claim row. |
| `gourmand_teach(int $uid, string $recipeSlug): bool` | Phase 2: insert-or-ignore into `user_recipes`. |
| `gourmand_board(string $tour, int $n = 5): array` | The Long Table board. |
| `gourmand_titles(int $uid): array` | The titles in 6.1. |
| `gourmand_wander(string $code, string $date): ?array` | Phase 3 road village pick. |
| `ensure_gourmand(): int` | The NPC (through `TRAVELLERS`), the Almanac chapter entries (14 tastes, beats, `hint` texts), and the `second-spoon` item. Idempotent. Called by `boot_step('ensure_gourmand', …)` in bootstrap **and** `seed.php`. |

### 7.4 Hooks into existing code (exact sites)

| File | Change |
|---|---|
| `includes/npc_life.php` | `TRAVELLERS['gourmand'] = ['Pomeroy Crumbworth', 'Dormouse', 'Fussy', <bio>, 0]`. In `traveller_stop()`, first line: `if (($npc['traveller'] ?? '') === 'gourmand') return gourmand_stop($at);`; it returns the same keys plus `starts`. `npcs_at_spot()` skips the gourmand on the Green and adds him to the spot whose slug is `gourmand_stop()['camp']`. `npc_now()` and `npc_routine()` get gourmand branches (camp, dates, next town). `traveller_offer()` gets `case 'gourmand'` → `['kind' => 'link', 'url' => 'gourmand.php', 'label' => '🍽️ Serve a course']`. `traveller_deal()` refuses the gourmand. `teahouse_rumours()` gets the menu rumour. |
| `includes/npc_life.php` (new helper) | `travellers_active(): array`. This is the single `SELECT * FROM npcs WHERE traveller IS NOT NULL AND active = 1`, and it drops the gourmand when `!gourmand_open()`. It replaces the five inline copies: `npcs_at_spot`, `teahouse_rumours` (npc_life.php), `road_meet_candidates` (road_life.php), and `town.php` lines 231 and 301. (`friends.php` `npc_here()` looks him up by id; it gets the same `gourmand_open()` guard.) |
| `includes/road_life.php` | `road_meet_candidates()`: `$started = $s['starts'] ?? ($s['ends'] - TRAVEL_STOP_HOURS * 3600);`. Nothing else, because `ROAD_TRAVEL_WINDOW` (2 h) already does arrival and departure. |
| `includes/data/road_meet.txt` | About 10 chat rows with who `gourmand` (the existing `@trav-in` / `@trav-out` card lines already read well). For example: `-|gourmand|“{name}! Have you eaten? You have the look of someone who hasn’t eaten properly.”` |
| `includes/crafting.php` | `cook_start()`: work out `gourmand_dish_score($u, $stock)` before the ingredient loop, and add `'score' => $score` to each `cook_pots` insert. `cook_collect_one()`: after `give_item`, call `market_note_quality($uid, (int)$r['output_item_id'], $dishes, (int)$pot['score'])` (require `market100.php`, as `pantry.php` requires `catalog.php`). |
| `includes/schema.php` | Merge `gourmand_schema()`; add the `cook_pots.score` row to `$c`. **Only one agent edits schema.php.** |
| `includes/bootstrap.php`, `includes/seed.php` | `boot_step('ensure_gourmand', …)`. Phase 2 needs nothing extra for recipes: the existing `ensure_crafts()` / `import_recipes()` adds missing slugs. |
| settings merge | `gourmand_settings()` merged into `settings_schema()` (Opus wires these lines). |
| `folk.php` | Line ~81: when `$offer['kind'] === 'link'`, print an `<a class="btn small">` instead of the deal form. |
| `town.php` | `$travHere` row text for the gourmand ("is at <camp>"); on a spot page whose slug is the current camp, include the `gourmand_panel($u)` partial (menu, stack qualities, Serve buttons, the second spoon once `mid` is unlocked). |
| `book.php` | Merge `gourmand_titles($uid)` at lines 22 and 248, next to `stop_titles`. Add the Almanac chapter "The Gourmand's Journal". |
| `includes/fresh_start.php` | Add `'gourmand_plates' => 'user_id', 'gourmand_ledger' => 'user_id', 'gourmand_wander' => 'user_id'`. |
| `includes/layout.php` | Add `gourmand.php` to `AJAX_PAGES`, and a nav tile under Out & about (Opus wires the menu). |
| New page `game/gourmand.php` | Tabs `?t=now|journal|menu|rules`. POST `do=serve&course=plate|pot|jar|grand[&late=CODE]` with CSRF, returning to its tab. |
| Phase 3, `includes/calling_quests.php` | Add `'serve'` to `CALLING_EVENT_KINDS` (ctx: `course`, `spoons`, `region`), called from `gourmand_serve()`. Hollow goals hear it for free. Optional Brewroot task rows: `T|brewroot-2|event|serve|spoons>=2|5|Serve Pomeroy 5 courses at two spoons or better`. |

## 8. Phased plan, tests, open questions

### 8.1 Phase 0: data and clock (S, no UI, nothing visible)
- `data/gourmand.txt`: R, M and B rows for all 14 regions plus Mossbottom, using only existing slugs.
- `includes/gourmand.php`: `gourmand_stop`, `gourmand_rows`, `gourmand_menu`, `gourmand_itinerary`, `gourmand_spoons`.
- `tests/gourmand.php`: the schedule and lint parts (below).

### 8.2 Phase 1: Pomeroy tours (M). Off until Joshua sets `gourmand_open`
- NPC through `TRAVELLERS`, the npc_life hooks and the `travellers_active()` refactor.
- Camp panel, `gourmand.php` (Now, Journal, Menu, Rules), serving Plate, Pot and Jar with existing recipes.
- Dish score (`cook_pots.score`), ledger, rewards, Taste pages, beats `hello` through `finale`, titles, Long Table with late plates and the board, `second-spoon` item.
- Placeholder art: red border + THIS IS PLACEHOLDER. Needed: a portrait, a camp sprite, the spoon icon and 14 taste page banners.
- Version bump and news entry by Opus. The schema change suggests a milestone number (2.2.0?).

### 8.3 Phase 2: his own cooking (M, mostly data)
- 16 NEW recipes (4.1) through `recipes.txt` (the importer adds missing slugs).
- Recipe cards (`gourmand_teach`), the v2 Pot variants and the `chicha`/`poi` Jar variants.
- The Grand course (8 regions), the Home Plate beat and the Grand Diner title.
- Later, optional: feasts for SA, WCA, ESA, EA, SEA and OC (`feast-` slugs, ingredients from that region's treasures) so all 14 have a Grand course.

### 8.4 Phase 3: the road (S–M)
- Wayside Bite (`gourmand_wander`, 12 Wayside notes), `road_meet.txt` lines and teahouse menu rumours.
- Calling event `serve`.
- Admin > Gourmand: schedule preview with a force date, a read-only menu view, and optionally an import into tables for editing.

### 8.5 Tests

**`tests/gourmand.php`** is the engine, run with `php tests/gourmand.php GAME`.
1. **Schedule:** every Hollow day of 2026, 2027 and 2028 maps to exactly one stop.
   - Days 2–27 map to the expected code from `TOWN_FESTIVALS`, day 1 to Mossbottom, and day 28 to the last day to OC.
   - Each stop's `ends` equals the next stop's `starts`.
   - February 2027 gives OC 1 day; February 2028 gives 2.
   - `stop` keys are unique per window.
   - Changing a festival day in a copy of the const moves the windows.
2. **Lint:** the rules in 7.1, plus every NEW recipe ingredient slug exists in `items` after install, and every R camp slug exists in `town_spots`.
3. **Quality maths:**
   - Bars give 0/1/2/3 spoons at 39/40/50/65 for plate and 44/45/52/62 for jar.
   - An untracked dish gives 35 and 0 spoons.
   - `gourmand_dish_score` with all-plain ingredients at Kitchen III is ≤ 50.
   - `cook_start` writes `cook_pots.score`, and `cook_collect_one` writes `item_quality`. This is also checked with pots off (`kitchen_pots` = 0).
4. **Serve claims:**
   - The second serve of the same course in the same tour is refused and nothing is taken.
   - With the force date moved to the next month, the same serve pays the tip only.
   - A jump from 0 to 3 spoons pays 240 Petals; a later 3 pays the tip.
   - Full-table and Golden payouts happen once.
5. **Late plates:** on day 1 the 3 allowed are accepted and the 4th is refused; on day 2 none are accepted; late plates never show on the board.
6. **Off switch:** with `gourmand_open` = 0, `travellers_active()` has no gourmand for players and does have one for admins.

**`tests/gourmand.sh`** is self-contained, modelled on `tests/calling.sh`: temp copy, install, register sprout, onboard, run `gourmand.php`, then HTTP.
- `gourmand.php` (each tab), `town.php?spot=<camp>`, `folk.php?id=<pomeroy>` and `book.php?ch=…` all return 200 with no new lines in the PHP log.
- Serving from the wrong region is refused ("Pomeroy is in …").
- Serving with a forced date in the right region works: item qty falls by the M qty and Petals rise by 60.
- **Race:** two concurrent `curl` POSTs serve once.
- A guest is refused.
- `reset.php`/fresh start removes `gourmand_*` rows.
- The road meet candidate shows on the road into the camp town at `starts + 1 h` and not at `starts + 3 h`.

Also:
- Add `gourmand` to `tests/ci_suites.sh`.
- Add one line to `tests/cook.sh`: the `cook_pots.score` column exists and is non-zero after a cook.
- Run suites one at a time on separate ports (known spurious INSTALL FAILED under parallel runs).

### 8.6 Open questions for Joshua
1. Name and species: Pomeroy Crumbworth, dormouse, with the call-back to the `round-door` card. Keep, or pick another?
2. Calendar: two days per region tied to the festivals, monthly. This gives a 1-day OC stop in February, covered by late plates. The alternative is a fixed 30-day loop with no festival tie.
3. Camp at a town spot (proposed) or at each region's zone-1 haven (prettier, but hidden and it leaks into the "places" calling task)?
4. Reach: anywhere in the region (the same as other travellers, proposed), or must the gnome stand in the town?
5. Dish quality (`cook_pots.score`): fine to add? Quality orders were turned off because Satchel stacks don't split. This only feeds the Gourmand, but players may ask to see dish quality in the Satchel.
6. Reward sizes: are 14 treasure seeds over a lifetime too generous? Should the repeat tip double on festival day?
7. Finale timing: wait for the next Long Table (proposed, a dated event), or play it at the next meeting?
8. Art: a portrait, a camp sprite, a spoon icon, 14 taste banners, the `second-spoon` decor and 16 dish/jar icons for Phase 2. Placeholders first; a cost estimate and first batch before any art at scale.
9. Long Table board: show names publicly, or only "you placed 3rd"?
10. Wayside Bite (stop-hopping): build it in Phase 3, or drop it?
11. Version: Phase 1 as 2.2.0 (schema change, full zips)?
