# Creature HP/damage audit, Puzzle Combat v1 (2.7.00), condensed

Source: audit agent run of `tests/pfboard_tune_v1.php` (88 creatures, model gnome, blank-centre, 4x4). Raw scripts were in session scratchpad (not kept). Offset = gnome level minus creature level (floored at gnome L1). Bots: chain = floor player, look = 1-turn lookahead, smart = 2-turn.

## Headline
- Chain bot win at level: small 85, medium 95, large 93, boss 90. Design target was ~70; 2.6.96 changelog said 79/80/82/78. Drifted easier ~5-15 pts (cause not bisected; candidates: class rules, `pfb_rank` order, new decks).
- Look/smart win 99-100% nearly everywhere (even 8 under). Chain loses 56-70% HP at level, look 17-22%. Real player is between chain and look.
- Size spread at -4: small 79, medium 59, large 75, boss 72. At -8: medium 31, large 39, boss 39.
- Medium has the steepest cliff (95 -> 59 -> 31). Cause: gnome progression (HP/deck value +6-9%/level at L5-14, 2-3% at L30+). A per-size multiplier cannot flatten it.
- Spread inside a size is bigger than between sizes (medium at -4: sun-lizard 16% to will-o-wisp 100%).
- Piece damage non-monotonic across sizes: small lv4-5 Hurt 4.3-4.7 > medium lv5-7 2.0-2.3; medium lv18 7.7 > large lv19-23 5.0-6.4; medium lv29 12.3 > every boss (7.8-9.8).

## Formulas
Creature row (`import_creatures_txt`): m = small .8 / medium 1.1 / large 1.6 / boss 2.4. hp = round((5+3L)m); attack 1+L/3(+0,0,2,2); defence 9+L/3(+0,1,2,3); die 4/6/8/10; dmg bonus L/4; xp round(6L m). Puzzle combat ignores hp/attack/defence/xp; it reads size, level, die, bonus, temper (PF_GENTLE), class, layered deck.

Fight bar: round(max(6, round(pace*K*(5+0.4L),1))*BARMULT,1) * min(1,lvx) * 1.15. pace 2.5/3.5/4.5/7.0; K 1.7 (boss 2.0); BARMULT 1.325/1.491/1.495/0.825.
Piece value: v = round(((die+1)/2 + L div 4)*1.4) (boss x0.78); piece = round(piece_m*v); then x FOE(.855/.48/.378/.585) x lvx x 1.15 (x1.2 boss).
lvx = clamp(1+slope*(L-ref), lo, hi): small, boss flat; medium slope .05 ref 12 .85-1.35; large slope .025 ref 22 .85-1.10.
Deck: 1 piece/turn (boss 2 out), hand 3 (boss 4), deck 8/8/10/11.
Temper: gentle Hurt x0.8 Charm x1; hostile Hurt x1 Charm x0.6; boss Charm x0.6.
Gnome (model): HP 20+3L+5*mod, mod=(L+3) div 14. HP L1 23, L10 50, L20 85, L36 138, L60 220. Deck saturates at 19 pieces from L20; mean Hurt L1 3.3, L10 7.1, L20 12.2, L36 18.8, L60 28.8.
Road pick (`pick_creature`): level-6..level+2, else strongest scaled; bosses 6%, up to level+8. Scaling adds +5.5 hp, +0.4 atk/def, +0.25 dmg bonus per level above creature level.
Data coverage: small lv1-5 (10), medium lv5-18 + 27/29/35 (26), large lv14-37 (43), boss lv26-32 (9). Gap: nothing medium/large between lv 1-4 beyond small; no creature >37; gnome L38+ always meets scaled creatures.

## Win% (chain), win / HP lost% by band
| size / lv | +4 | 0 | -4 | -8 |
|---|---|---|---|---|
| small all | 100/35 | 85/64 | 79/68 | 79/68 |
| medium 5-7 | 100/35 | 95/51 | 54/86 | 59/82 |
| medium 8-10 | 100/36 | 97/61 | 38/92 | 7/98 |
| medium 11-13 | 99/38 | 96/47 | 64/80 | 27/93 |
| medium 14-18 | 98/48 | 89/69 | 67/82 | 11/98 |
| medium 19+ | 100/49 | 98/58 | 88/74 | 60/85 |
| large 14-18 | 100/44 | 97/58 | 79/75 | 5/99 |
| large 19-22 | 98/47 | 89/62 | 71/78 | 51/86 |
| large 23-26 | 100/49 | 95/61 | 71/77 | 42/92 |
| large 27-37 | 95/60 | 91/65 | 81/73 | 55/86 |
| boss 26-32 | 94/63 | 90/70 | 72/81 | 39/92 |

Road sweep (gnome L vs what road sends): hard zone = gnome L1-10 vs lv5-13 mediums, and L10-20 vs first large/boss (L15-20 boss: 17-50%). Easy zone = L25+ (small 100% at 20-30% HP lost, large 93-100%). Above L38 all creatures are scaled lv<=37; fights trend easy (81-100%).

## Outliers (chain; mult ~ piece-value multiplier to reach size median; <1 softens)
At level, hard: sand-fleas (.79), earwig (.88), sun-lizard (.78), giant-centipede (.76), bramble-wolf (.72), wild-boar (.74), arctic-fox (.76), jungle-tiger (.78), beaver-foreman (.78).
At -4, hard: ant-scouts .86, carrion-crow .63, barn-rat .67, paper-wasp .77, ember-beetle .86, sea-otter-bandit .86, grass-snake .72, griffon-vulture .76, tufted-lynx .80, cliff-ram .82, desert-gila-dragon .84, bog-pike .86, prairie-bison .88, thunder-yak .88, storm-eagle .88, coconut-crab-titan .92.
At -4, easy (mult >1): will-o-wisp 2.8, thistle-beast 2.4, savanna-hyena 2.25, outback-dingo 1.68, spice-monitor 1.62, leafcutter-column 1.62, moss-golem 1.55, garden-snail 1.58, reef-turtle 1.5, bullfrog 1.44, giant-bumblebee/clam-lurker/black-bear/fern-cassowary 1.42, poison-dart-frog 1.39, raccoon/tawny-owl 1.35, hermit-crab-hoarder 1.3.
No boss flagged at level (80-95). ~40 flagged at -4. Temper is not the cause.
Per-creature full table (win +4/0/-4/-8) for all 88 was in the agent's report; re-generate with `php tests/pfboard_tune_v1.php chain 4,0,-4,-8 2 i/4 json`.

## Bar and Hurt vs level (bar / mean creature Hurt)
small 1:35/3.2 5:45/4.3 | medium 5:61/2.0 8:71/3.2 12:100/4.2 16:116/6.7 18:124/7.7 27:161/9.2 29:169/12.3 35:194/11.7 | large 14:119/4.3 20:162/5.6 22:182/6.1 26:202/8.1 32:234/10.0 37:260/9.3 | boss 26:205/7.8 32:236/9.8.
Over L1-60 gnome deck value x11, HP x9.6; largest creature bar x7.
At level (chain): turns 5.3/6.5/6.9/7.1, HP lost 64/56/61/70% (small/medium/large/boss).

## Target options (NOT applied)
Levers: `PFB_V1_FOE_MULT` (piece values, sim key `foe_x`), `PFB_V1_BAR_MULT` (`bar_x`), `PFB_V1_LEVEL` curve. JS port `tools/pfengine.js` must change with any constant (`bash tests/pfengine_js.sh`). Sim override: `V1='{"foe_x":{...},"bar_x":{...}}'`.

Size-wide damage multiplier response (win +4/0/-4/-8): small 0.8: 100/94/89/89; 1.0: 99/85/78/78; 1.2: 98/69/62/62. medium 0.8: 100/96/71/39; 1.0: 100/94/59/31; 1.2: 98/86/38/19. large 0.8: 99/99/88/59; 1.0: 98/93/75/37; 1.2: 97/88/56/24. boss 0.8: 99/97/87/69; 1.0: 93/89/72/37; 1.2: 82/66/42/16.

| option | small | medium | large | boss | result +4/0/-4/-8 |
|---|---|---|---|---|---|
| A equal 80% at level | foe 1.03 bar 1.04 | foe 1.16 bar 1.19 | foe 1.14 bar 1.15 | foe 1.03 bar 1.11 | small 99/82/75/75; medium 96/78/27/13; large 94/82/52/17; boss 90/83/55/26 |
| B ~65-70% (design doc) | foe 1.10 bar 1.12 | foe 1.25 bar 1.30 | foe 1.25 bar 1.30 | foe 1.08 bar 1.30 | small 99/78/70/70; medium 92/66/13/8; large 81/64/34/10; boss 82/69/43/15 |
| C equal 60% at -4 (damage only) | foe 1.25 | foe 1.00 | foe 1.16 | foe 1.08 | small ~100/66/60/60; medium 100/94/59/31; large ~97/89/60/28; boss ~91/80/60/28 |

A/B equalise only the at-level column; medium still collapses at -4. C equalises -4 but at-level spread stays 66-94%. Both columns even needs creature power tied to gnome power at its level (e.g. lower bar for low-level medium: bar_x 0.7 gave 99/84/49 at 0/-4/-8 with 4.9-turn fights; unverified combined with damage change). Per-creature fixes: use mult column; first batch = 8 at-level hard outliers x~0.8 and easy tail (will-o-wisp, thistle-beast, savanna-hyena, moss-golem, reef-turtle) x1.4-1.6.

## Caveats
- Chain = floor, look/smart = ceiling (99-100%); real player unknown, needs human data.
- `pfb_score` and tuner ignore Keeper/Plenty/Simmer. Model decks omit 42 legendary crop pieces and wearables, so real gnomes likely stronger.
- `tests/pfboard_tune.php` measures old rules; `tests/balance_sim.php` is garden economy, not combat.
- Model gnome stats all (L+3) div 14: level-specific model quirks show as creature quirks.
- Offsets floored at gnome L1 (small -4/-8 identical; medium lv5-9 at -8 is gnome L1).
- Noise: size totals +-2-4, bands +-5-8, large per-creature at +4/-8 (n=10) +-14, sweep rows +-15.
- Drift vs 2.6.96 changelog (79/80/82/78 -> 85/95/93/90) not bisected.
- Human playtest must confirm: normal-player win per size; whether 56-70% HP lost and 5-8 turns feel right; medium lv5-13 vs gnome L1-10; flagged creatures; boss vs large difficulty (design call); real decks at L10-12 and L24-26.
