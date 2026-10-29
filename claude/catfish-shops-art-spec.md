# Cat Fish pet shops: art spec (2026-10-29)

Design source: `claude/plan-catfish-petshops.md` (sections 1-3, 7). One shop = one Opus artist doing 2 jobs: ITEMS (5 sprites) or FRONT (banner + shopkeeper bust).

## Naming
- item sprite: `cf-pet-<slug>.png` (slug below); shop banner: `banner-<code>-pets.png`; shopkeeper bust: `npc-<shopkeeper_slug>.png` (slug = lowercase, non-alphanumerics to `_`; e.g. coral_pennyfeather).
- Match the ACTUAL sizes/style of existing `banner-*` and `npc-*` PNGs in `game/assets/img/` (and the NPC/banner Lua in `aseprite-source/final/scripts/`); the 480x120 / 400x500 figures in the plan are the 2x written sizes, check the real files and report what you matched.

## Item sprite sizes by slot (room is 320x200, cats are 1x sprites; sprites stand on/hang in their slot)
| slot | max size | notes |
|---|---|---|
| shelf | 20x24 | stands on the shelf at top right; two items share the shelf, so keep to 20 px wide |
| sill | 30x26 | sits on the window sill (bottom edge flat) |
| frame | 35x31 | REPLACES the picture frame art: include the frame itself |
| ceiling | 48x34 | hangs from the top edge (garland / mobile / lantern / chime) |
| floor-left | 38x28 | corner behind the cushion; bed/plush/rug sized, bottom edge flat |
| floor-right | 36x28 | between rug end and bowl; bottom edge flat |
| rod | 16x16 | a charm/lure tied to the rod string; show it hanging |
Rules: same Stitched Toy look as `cf-room.png` and the cf-up-* icons; items read at 1x on the room; no text.

## Shops and items (slug = file name stem)

### CB: Driftwood & Whisker
- `conch_shell` Conch Shell | slot **shelf** | shelf, P, cosmetic, cats "listen"
- `hammock_net` Hammock Net | slot **floor-left** | floor-left, P, away cap +10 min
- `flying_fish_charm` Flying-fish Charm | slot **rod** | rod, P, cosmetic leap
- `steel_pan_chime` Steel-pan Chime | slot **ceiling** | ceiling, A 12h, Pop 10
- `parrot_perch` Parrot Perch | slot **sill** | sill, A 24h, reveals one of tomorrow's shelter coats

### SE: The Olive Pantry Pets
- `terracotta_catgrass` Terracotta Catgrass | slot **sill** | sill, P, +2% Kibble
- `mosaic_mat` Mosaic Mat | slot **floor-right** | floor-right, P, cosmetic
- `lemon_on_a_string` Lemon on a String | slot **rod** | rod, P, +1% Kibble, lemon fish skin
- `amphora` Amphora | slot **shelf** | shelf, A 20h, Pop 15
- `siesta_fan` Siesta Fan | slot **ceiling** | ceiling, P, away cap +15 min

### SA: Canopy Critter Co.
- `bromeliad` Bromeliad | slot **shelf** | shelf, P, cosmetic, frog peeks
- `capybara_plush` Capybara Plush | slot **floor-left** | floor-left, P, Cat Show +1 if the entered cat is lazy
- `toucan_feather_lure` Toucan Feather Lure | slot **rod** | rod, P, first 10 taps each day x1.5
- `rain_stick` Rain Stick | slot **sill** | sill, A 16h, Pop 10 + an hour of rain on the window
- `panpipe_chime` Panpipe Chime | slot **ceiling** | ceiling, P, cosmetic

### EE: Birch Hut Pets
- `matryoshka_mice` Matryoshka Mice | slot **shelf** | shelf, A 24h, Pop 5, 1-in-50 chance of 1 Yarn
- `rug_runner` Rug Runner | slot **floor-right** | floor-right, P, cosmetic
- `felt_boot_bed` Felt Boot Bed | slot **floor-left** | floor-left, P, away +10 min
- `sunflower_head` Sunflower Head | slot **sill** | sill, P, +1% Kibble, birds peck
- `painted_egg_charm` Painted Egg Charm | slot **rod** | rod, P, cosmetic tassel

### MENA: Lantern & Lounge
- `brass_lantern` Brass Lantern | slot **ceiling** | ceiling, P, warm glow
- `kilim_cushion` Kilim Cushion | slot **floor-left** | floor-left, P, Cat Show +1
- `bell_lure` Bell Lure | slot **rod** | rod, P, cosmetic jingle, gold combo pop
- `sand_timer` Sand Timer | slot **shelf** | shelf, A 24h, Pop 20
- `mirage_mirror` Mirage Mirror | slot **frame** | frame, A 18h, says if tomorrow's shelter has an uncommon-or-better cat

### EA: Blossom Lantern Cattery
- `maneki_neko` Maneki-neko | slot **shelf** | shelf, A 24h, Pop 15, 1-in-40 chance of 1 Yarn
- `paper_lantern_string` Paper Lantern String | slot **ceiling** | ceiling, P, cosmetic
- `bonsai` Bonsai | slot **sill** | sill, P, +2% Kibble
- `koi_kite_lure` Koi Kite Lure | slot **rod** | rod, P, koi skin, rare fish +5%
- `tea_tray` Tea Tray | slot **floor-right** | floor-right, A 12h, all cats play happy frames, Pop 5

### CSA: Spice Bazaar Pets
- `singing_bowl` Singing Bowl | slot **shelf** | shelf, A 12h, previews your cat's score for this week's show theme
- `marigold_garland` Marigold Garland | slot **ceiling** | ceiling, P, cosmetic
- `tiger_stripe_rug` Tiger-stripe Rug | slot **floor-left** | floor-left, P, cosmetic
- `kite_tail_lure` Kite Tail Lure | slot **rod** | rod, P, Catnip Hour +10 min
- `chai_stall_sign` Chai Stall Sign | slot **frame** | frame, P, +2% Kibble

### SEA: Monsoon Mew Market
- `paddy_hat_bed` Paddy-hat Bed | slot **floor-left** | floor-left, P, away +15 min
- `gecko_friend` Gecko Friend | slot **frame** | frame, P, cosmetic, animated
- `shadow_puppet_screen` Shadow-puppet Screen | slot **sill** | sill, A 16h, names one coat you have never seen, text hint only
- `banana_leaf_fan` Banana-leaf Fan | slot **ceiling** | ceiling, P, cosmetic
- `floating_lantern` Floating Lantern | slot **shelf** | shelf, A 24h, Pop 20

### WCA: Drum & Den
- `talking_drum` Talking Drum | slot **floor-left** | floor-left, A 24h, one free shelter reroll, still counts toward `CATFISH_REROLL_MAX`
- `kente_bunting` Kente Bunting | slot **ceiling** | ceiling, P, cosmetic
- `calabash_bowl` Calabash Bowl | slot **floor-right** | floor-right, P, +2% Kibble
- `weaver_bird_nest` Weaver-bird Nest | slot **sill** | sill, P, window bird visits twice as often, rare fish +5%
- `mask_frame` Mask Frame | slot **frame** | frame, P, cosmetic

### ESA: Thornacre Trading Den
- `acacia_perch` Acacia Perch | slot **sill** | sill, P, Cat Show +1
- `beaded_rack` Beaded Rack | slot **shelf** | shelf, P, cosmetic
- `grass_tuft` Grass Tuft | slot **floor-left** | floor-left, P, away +10 min
- `rain_cloud_mobile` Rain-cloud Mobile | slot **ceiling** | ceiling, A 24h, Pop 15
- `coffee_bean_rattle` Coffee-bean Rattle | slot **rod** | rod, P, first 30 taps each day +25%

### OC: Reef & Purr
- `tide_pool_jar` Tide-pool Jar | slot **shelf** | shelf, A 24h, Pop 10, 1-in-30 chance of 1 Yarn
- `driftwood_board` Driftwood Board | slot **frame** | frame, P, cosmetic
- `southern_cross_mobile` Southern Cross Mobile | slot **ceiling** | ceiling, P, +2% Kibble
- `kiwi_plush` Kiwi Plush | slot **floor-left** | floor-left, P, Cat Show +1
- `seashell_lure` Seashell Lure | slot **rod** | rod, P, rare fish +5%
