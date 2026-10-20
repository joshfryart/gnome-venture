# Gnome Venture changelog (newest first, condensed)
Dates 2026-10-17 unless noted. "Slim needs vX" = minimum installed version. Upgrade steps: see handoff.md.

## 2.0.18
- Treks fixes from Joshua's phone play-test: (1) first-meeting spot text (Bracken, etc.) now opens as the story pop-over: NEW `trek_scene_spot()` (trek_scene.php) queues the spot panel text (before/arrive/talk/locked/question/intro) once per key per run. (2) Fight feed capped <1000px: `ul.trekrounds` max-height 11em, scrolls, newest line shown; "Show all" box 16em. (3) Obstacles can no longer be bypassed: `trek_spot_blocks()` (duel, miniboss, boss, cart, riddle with failopen while flag unset) + `trek_blocker_hold()` in trek_walk (standing on an undone blocker, the first step must go back toward the start; else refused "X blocks the way on…"); `trek_spot_stops()` stops on every pass. Stuck Cart now blocks the way to Burdock in Ch I (dig +8 fatigue always works, or heave; pays its Camp Kit): balance idea: no fatigue on the first dig. Clay Slide still skips the Fallen Shelf (reward only a kit). (4) Party cards one compact row each (~65px, 4 cards ~415 → ~260px at 390px; tap for stats stays). (5) Camp pop-over now works at Ch II rest sites + oldcamps (both chapters): `trek_here_restspot()`, "again"/"arrive" notes for rest_old/rest_spot, dialog offers free "Rest here", no kit shop/swap there.
- Ch II sluices moved close to their water (within 4 tiles = inside the 9x9 phone window): sluice1 (24,9)→(20,9), sluice3 (11,89)→(21,89), sluice2 unchanged. Sluice done-line drafts reworded (drafts only apply to NEW slots: live rows keep generic text until edited).
- Tests: NEW tests/trek_block.php, trek_camp.php (Ch II), trek_audit_ch2 sluice block; trek.php/trek_events.php updated for the cart. treks.sh rc 0 (232 ok), security190 0 failed. No schema, no news (Treks hidden).

## 2.0.17
- Picture tiles + sheet (shop_tiles.php) for the last row-style shops: Curio Cabinet + Dye Pot (sinks.php `sink_tile()`, plain confirm sheet, max 1), festival stalls (festival.php, includes/festival.php selects items `*`), haven pantry (landmarks.php `shop_oneform()`), village stall buy/snack kinds (local.php `local_buy_tile()`, "🛒 For sale" row). Prices, limits, POST fields, payouts unchanged. swap/seedswap/rest stay rows.
- tests/sinks097.sh greps fixed (66 ok). CSS "v2.0.17 shop tiles 2" (11 lines). News entry.
- Watch: CSP inline-style console error on town.php (pre-existing). Optional polish: /tmp scratch css for "For sale" heading margin (not applied).

## 2.0.16
- Treks II-b: NEW skill-check stop "The Fallen Shelf" (zone p, the Dim, tile `0` at 18,74; `cart` type, dc 11, 1 Camp Kit once; slots ch2.spot.shelf.before/win/fail/work/after with briefs + drafts).
- Admin settings (advanced): road_roll_creature 40 / _problem 22 / _choice 14 / _find 24 = weights of the road roll (clamped 0-100, need not sum to 100; all 0 = defaults). `road_roll_bands()` in road_life.php replaces ROAD_CHOICE_PCT; adventure.php next_step uses it. Defaults give the old 40/62/76 bands exactly.
- Tumble talk/done lines reworded to match fatigue −6 (trek_final_200/204 + one-time pass 6: `trek_apply_text_2015()`, data trek_final_2015.txt + trek_final_2015_old.txt, boot_step `trek_bodies_2015`, trek_text_pass 6; edited rows kept; seed.php runs it).
- Removed unused `.tkfoelv` CSS. Tests: trek_ch2/trek_ch2b spot counts, trek_text204 (pass 6), NEW trek_text2015.php, roadlife road-roll block. treks.sh + roadlife + explore pass. No schema, no news.
- Left: ch2.crew.tumble.done brief (trek_texts_ch2b.txt:74) still has the old wording (brief only, not shown to players).

## 2.0.15
- Join card shows "Trek Lv N" (the Party tab number; a late recruit shows avg−2). Before it showed base level + trek level (e.g. 17 when you were Lv 7).
- Foe pop-over no longer shows a creature level (it was on the base-15 scale and meant nothing next to trek Lv).
- Juniper: nookB (Another Nook) now also gives 1 Clay Pot (spot key `also=slug:qty`, read in trek_act_hidden), so skipping the optional II-a wheel no longer forces a walk back.
- Tumble's crew moment is his own: fatigue −6 (Sorrel keeps the map reveal). Talk lines in trek_final_200/204 still promise a short cut: reword when text is next touched.
- Drafts: Old Thrum is a cicada nymph, not a cricket (trek_drafts_ch2b.txt).
- Tests: trek_scene, trek_ch2b, trek_audit_ch2 updated. treks.sh 229 ok (same on pristine; old "243" figure was stale). trek_oldcamp "banks them" flakes on the 12% ambush roll.
- Unused CSS `.tkfoelv` left. No schema, no news (Treks hidden).

## 2.0.14
- Round-1 fight panel waits for the foe pop-over.

## 2.0.13
- Desktop Treks layout: log + Sneak/Camp/Leave under the map; fight keeps the map in column 1 (view-transition `trek-map`), column 2 (`trek-stage`) cross-fades to the fight panel and back. Phone unchanged.

## 2.0.12
- Treks fights (branch trek-fight-touches): ONE combined foe pop-over (`dialog.tkfoe`, all foes side by side, same-name = one card ×N, boss shows "Next: X, then Y"; muted by `gvSceneOff`). After a walk into a fight the map shows above the fight card ("🗺️ Where it began", `details.tkfmap`, inert) and a red "!" bounces over the token before the pop-over; reload shows neither. Animations in every mode (hit shake, floating −N/+N, crit flash on the hit row, KO fade, eased bars, plan-each-turn stage tokens, Auto replay). Files: trek.php, includes/trek_fight.php (`trek_foe_card`, replay snap [6]), assets/trekfight.js, assets/trekmap.js, CSS block "v2.0.10 trek fight touches". No fight maths changed.
- Treks text fixes (Fable review, 8 verified issues): NEW data/trek_final_2012.txt (9 slots) applied once by `trek_apply_text_2012()` (boot_step `trek_bodies_2012`, trek_text_pass = 5; edited rows kept; seed.php runs it): Tin Lamp keeper no longer says the snail never came back, "satchel" not "pack" for the Shard, kiln/cook lines reworded, NEW slots ch2.banter.zinnia.1/2 + bracken.1/2 (briefs in trek_texts_ch2.txt, drafts in trek_drafts_ch2.txt). interlude.1.* speakers now NPC slugs (pass updates existing rows only if still the old first name).
- Fix: Lanternroot Seed Satchel description showed "TODO" (item row; boot_step `trek_item_desc_2012`, only if still the old words).
- Left: ch2.spot.crossroads.locked (unreachable by design). Doc drift fixed in trek-chapter1.md (2 tries, 1 add / 4th round).
- Tests: tests/trek_text2012.php (in treks.sh); trek_text204 expects pass 5. treks.sh 243 ok, security190 170 ok. No news entry (Treks hidden).
- Numbering: 2.0.10–2.0.19, then 2.0.20 (set 2026-10-20 by Joshua's other session). Not built as 2.0.10/2.0.11 here.

## 2.0.11
- NEW camp pop-over (Treks). The 🏕️ Camp button on the map now opens a `<dialog class="tkcamp">` instead of resting at once. It also opens by itself when the party reaches a camp tile (switch in the pop-over: "Open this when I reach a camp", this browser only) and again after each action inside it. It waits for a story pop-over or Auto replay to finish first.
- Inside: camp name + keeper greeting (short ones), Fatigue and kit chips, party with health bars, 💬 Talk per trailmate (cycles their banter slots 1-4, then their bio; no POST, no state), Rest (camp tile: Rest and bank; elsewhere: Use a Camp Kit, or Cold rest with the ambush odds, or "Everyone is rested"), at a camp also Buy a Camp Kit and Trailmates (rest here / bring along; full party shows a disabled row).
- Rules unchanged: every button is the old POST (rest, makecamp, buy_kit, party). No-JS: the old Camp form sits in `<noscript>`. The interlude hub keeps its own "Talk to your party".
- Files: NEW includes/trek_camp_ui.php (dialog html, open note), assets/trekcamp.js, CSS "v2.0.11 trek camp pop-over", hooks in trek.php (button, note in trek_dispatch after rest/makecamp/buy_kit/party and a walk onto a camp, dialog printed on the Map tab) and layout.php (script on trek.php). No schema change. No news entry (Treks hidden).
- Tests: NEW tests/trek_camp.php (in treks.sh). Playwright 390 + 1400 px: opens from the button, Talk cycles, rest reopens it after the story pop-over, no sideways scroll, no console errors.
- Open: no single-member healing (camp tiles already heal in full; the rest choices are the wound care). Only 2 banter lines per trailmate per chapter, so Talk repeats fast: more `chN.banter.<crew>.3/.4` slots would be read automatically once they exist. Gnome has no Talk.

## 2.0.10
- Map camera follows the token while it walks (Treks map, delve + lair maps). Before: the server drew the window centred on the END tile, so the picture jumped, then the token walked across it from the edge. Now a wider picture covering the whole walk is sent with the walk (`.tkbg.tkx` in trek_art.php/trek.php; `.tmbg.tmx` in tilemap.php/delve_map.php, param `sfx`; delve `dim` param = no dimming on the wide picture), shown only while the token walks. assets/trekmap.js + tilemap.js `look()` slide it so the token stays centred (trek: clamped at map edges like the final window; delves: unclamped like the final window). At the end the wide picture hides and the normal final picture shows: no jump. No script / reduced motion: unchanged.
- Cap: trek wide picture <= 2600 tiles, delve <= 900 (else old behaviour). Wide pictures are made only on walk renders.
- Tests: delvemap.sh ALL OK, treks.sh all ok. Playwright 390 + 1400 px (trek + delve): token x offset 0 every frame, same offset before/after the camera, no sideways scroll. No schema change. No news entry.

## 2.0.9
- ALL story text (speech, narration, place arrivals, boss intro/defeat) now opens as the talk pop-over, once per line per run; the log keeps every line. Speakers come from the text slot's speaker; narration shows with no portraits. Mixed lines ("Tumble bows. “Lovely!”") split into narration + speech.
- NEW "Party member joined!" card after a recruit: name, species, calling, level, Health/Attack/Armour, role, a bit about them (npc bio). Benched trailmates say the party is full.
- NEW "Story pop-ups" toggle (this browser only) under the tabs.
- Fix: trek_text_rows() now loads the speaker column. Pop-up lines are dropped if the action rolls back; queue-full lines can still show later.

## 2.0.8
- Fix: Gloomtooth cure scene now also shows on the chapter hub render; scene waits until an open Auto replay closes.
- Treks map tab: the latest log lines now sit directly under the map (above Sneak / Camp / Leave), not under the buttons.
- NEW talk pop-over ("scene"): a `<dialog class="tkscene">` for story beats. Speaker always LEFT at full strength, listener RIGHT faded (opacity .35, scale .88); sides slide across (.28s) when the speaker changes; narration beats fade both; text fades out/in (.12s/.2s); tap, Enter, Space or Right-arrow = next, Skip = last beat, Done/Esc closes; reduced-motion = instant. Portraits use the picture lookup (real art, placeholder, emoji) + the player's gnome svg.
- Files: NEW includes/trek_scene.php (`trek_scene_queue` parks plain-text beats in `$_SESSION['trek_scene']`, `trek_scene_stage` emits the hidden `.trekscene[data-scene]` once on the Map tab, 30 s, this run only), assets/trekscene.js (scan + MutationObserver like the Auto replay), CSS block "v2.0.8 trek scene", script tag in layout.php (trek.php only). No schema change.
- Scenes: Burdock freed, Zinnia joins, Bracken duel win, Gloomtooth cured (narration, then Burdock if in party, then the gnome), Sorrel, Tumble, Juniper. The normal log lines stay as they were; the scene is an extra view.
- NEW gnome reply slots (draft status, edit in Admin → Trek text): ch1.scene.burdock.me, zinnia.me, bracken.me, gloomtooth.me, ch2.scene.sorrel.me, tumble.me, juniper.me. The speaker is the gnome; a quoted line = speech, any other line = narration.
- Tests: tests/trek_scene.php (in treks.sh), trek_audit_ch1 orphan list. Real-page Playwright check at 390 and 1400 px (Burdock scene), no sideways scroll, scene not shown again after reload.
- Not announced (Treks hidden). Open: Gloomtooth INTRO is still a plain panel (only the cure is a scene); banter, trail events, riddles stay plain cards by design.

## 2.0.7
- Treks text fix pass after a Haiku review (100 findings), Sonnet check (88 false) and Opus recheck (102/105 agreed). NEW data/trek_final_207.txt (12 slots) applied once by `trek_apply_text_207()` (boot_step `trek_bodies_207`, setting trek_text_pass = 4; replaces a body only if empty or still a shipped draft/2.0.0/2.0.4 text; Joshua's edits kept; seed.php runs it on fresh installs). Fixes: tut.treklevel + tut.firstfight under 200 chars, gloomtooth.burdock (one reason), barrow.work (bundle), tumble.freed, thrum.defeat + ms.ch2_thrum + 3 "patient" lines (repetition), signpost.question 4 lines. NEW slot ch2.banter.burdock.2 (Ch I "innkeeper's soup" line no longer shows at Ch II camps; brief in trek_texts_ch2.txt, draft in trek_drafts_ch2.txt).
- Code: `trek_recruit_crew()` returns bool (false = joined but all 3 places taken); recruit, fetch and duel-win log `trek_benched_line()` ("X waits with the other Trailmates: your party is full. Swap them in at a camp"). Before, Sorrel/Tumble/Juniper were benched silently.
- Tests: tests/trek_text207.php (in treks.sh), trek_201.php party-full block, trek_text204.php expects pass 4 + 207 fixes. treks.sh all ok, security190 170 ok, upgrade from 2.0.6 clean. No news entry (Treks hidden).
- Not done (optional, low value): thrum.harden line, Tumble interlude line. Haiku's Ch I/II claims mostly false: do not apply its raw list.

## 2.0.6
- Phase 3 of claude/plan-consolidation.md: delve + lair MAPS (optional view, list flow kept as fallback). NEW includes/tilemap.php (generic: tm_parse/tile/walkable/path/reach/reveal/window/spots/gen/validate/render_svg, 9 landscape palettes), includes/delve_map.php (walk_scene schema, setting `delve_map` default 1, scene handling, dm_walk, dm_view_html), assets/tilemap.js (tap-to-walk, token animation; tile size from data attr), data/delve_maps.txt (3 hand layouts, ~3 in 12 delves; rest generated 11x11, lairs 13x13, seeded by landmark+expedition).
- NEW table walk_scene (user_id, exp_id UNIQUE, map_key, x, y, seen, state; VARCHAR only; row removed when the expedition ends; orphans purged at next start; dm_table_ok() creates it on first use if upgrade not run). Reaching a room tile calls the existing delve_next() (odds, danger, rewards unchanged); room 5 (guardian + chest) opens only after 4 rooms cleared; walking free; fog radius 2 (3 with lantern). Lairs: boss waits at the far tile (lair_engage), "Slip out" before it rises ends the lair. `?view=list|map` remembered in session. Phone window 9x9 at 44px (7x7 at 390px), no overflow.
- Trek files untouched (strangler). tests/delvemap.sh (500 delve + 500 lair seeds, 6 full tile-played delves, fallback, lairs, cleanup). CSS "v2.0.6 tilemap". News entry.
- Open: path preview is hover/focus only (touch sees reachable dots then walks); 390px crop hides outer tiles; walk_scene purge SQL untested on MySQL; roads/towns stay list-based by design (decision gate: look at delve completion before extending maps).

## 2.0.5
- Phase 2 of claude/plan-consolidation.md. NEW includes/shop_tiles.php (shop_tile/shop_chips/shop_mini/shop_cat_of): shop.php, market.php (stall buy), marketday.php (stall buy + wanted sell) share one tile + `<dialog>` sheet (site.js gvSheetTotal: skips "Too much" when no .mycoins[data-coins]). CSS "v2.0.5 shop tiles". Left as rows: sinks.php (Curio/Dye Pot), festival stalls, haven pantry, local.php, florist, my stall list.
- NEW includes/rewards.php: give_petals/take_petals (single-statement UPDATE, take = conditional claim), reward_log() empty hook, give_xp alias. 26 plain call sites moved (15 give, 11 take); rest still raw `coins = coins` (list in git history of this change; migrate lazily when touching a file). tests/rewards.php.
- NEW includes/combat_math.php: d(), attack_roll, damage, scale_creature, foe_hits, foe_damage, flee_roll, combat_pct shared by adventure.php and trek_fight.php; all "keep in sync" comments gone. Proof: tests/combat_math_golden.php + tests/combat_golden.json (~9,500 outputs identical before/after; run `php -d disable_functions=random_int tests/combat_math_golden.php GAME_DIR` on a fresh install; `--record` only from known-good code). treks/security190/explore same as pristine.
- News entry.

## 2.0.4
- Phase 1 of claude/plan-consolidation.md. Menu 19 -> 14 tiles: Seasons = fold on World (?tab=seasons), Passport = town.php?view=passport, Villagers you know = town.php?view=villagers; seasons.php/passport.php/folk.php (no id) are 302 stubs (folk.php?id=N stays: Talk/Gift/Deal POSTs). "Stop villagers" label for rest stops. Admin settings: search box + advanced flag (`settings_is_adv()` ~70 keys hidden by default; no keys deleted; save skips fields not on the page). CSS "v2.0.4 menu folds".
- Content: +66 road events (11 regions x 6), +44 region road lines, +24 stop chat lines (Warm/Eager/Fussy/Dreamy), 4 finds per landscape, delve room text (data/delve_rooms.txt kind|cond|lands|text; delve_room_line() in landmarks.php).
- Admin > Road text (admin/road_text.php, includes/road_text.php, NEW table road_texts): override road lines, scenes, wonder text, delve lines; hash ids; status todo/draft/done; restore. Hooks in road_life.php + landmarks.php (wonder_texts, delve_room_line).
- Treks text rework (Sonnet writers + story and gameplay reviewers): includes/data/trek_final_204.txt (146 slots), one-time pass `trek_apply_text_204()` (setting trek_text_pass = 3; replaces a body only if empty or still a shipped draft/2.0.0 final; Joshua's edits kept). New slots ch2.ko.camp, ch2.spot.libdoor.after, ch2.camp.cook.full/.nofunds. ~60 briefs updated. seed.php now runs both text passes (fresh installs had only drafts before). Tests accept status done.
- Treks code: cook speaks Ch II kit lines; first-fight/party/trek-level tutorials Chapter I only; boulder/capwall open text only names Burdock/Zinnia when in the party; libdoor.after on failopen; no "may be gone" at an old campsite KO before first camp; old-thrum description says cicada nymph (existing installs keep the old Almanac line).
- News entry. Open (see claude/todo.md): beetle shells lost on KO (mush quest), Silverfin Sorrel line, Ch II stash event text, chest button label.

## 2.0.3
- Admin → Progress & quests → 📊 Usage (admin/usage.php, read-only, no schema): rows + distinct players + last 7 days per feature (jobs, orders, favours, errands, hires, helping water, gifts, trades, stops, landmarks, market, contests, mini-games per game, treks). Players only (no admin/mod/banned). CSV export. Phase 0 of the 2026-10-20 review (claude/plan-consolidation.md). No news entry.

## 2.0.2
- Setting `puzzles_open` (default 0 = admins only): puzzles.php redirects players to games.php with "coming soon"; Games hub tile shown only when open or admin. 2.0.0.1 news entry still mentions Puzzles.

## 2.0.1
- Treks rebalance (w201-a): Auto uses Spore Burst on bosses when a friend <75% or boss holding; Sorrel 1|1|2|1 lore 3, Spore Burst mends 7% + breaks hold; Tumble 3|1|2|1, Sling +5 hit +5 dmg cd2, breaks hold; Juniper 2|0|3|1, Poison 2d6 then 3/round, poisoned foe hits 5% softer; Bracken 3|1|2|0, Power Strike +6, crit +1, breaks hold; Zinnia Heal 27%. Tune health %: Silverfin 138, Pinch 252, Thrum 160, Gloomtooth 166. Sims (800 trials): Pinch 75.9–93.1 (median 87), Thrum 76.1–94.6 (median 88); Silverfin Lv10 74.5–95, Lv11 93–99; Ch I ±1. trek_audit_ch2 asserts every party ≥70%.
- Riddles 2 tries (choir, stone, library door, kiln stone, signpost); trek_riddle_heal opens doors for runs saved with 2 misses. Orphan slots shown: item.camp-kit (Pack tile), item.blight-shard (banked tiles + reward card), ch2.spot.crossroads.locked (gate needs=silverfin_down;noopen=1). Bracken: no unpaid path (migration pays 0) — tests only.
- Setting trek_items_daily (0 = off; users.trek_item_day/today; creature drops only).
- Old campsites (includes/trek_oldcamp.php, spot type oldcamp ⛺, do=rest_old): repeatable, −trek_oldcamp_fatigue 40, half heal, ambush trek_oldcamp_ambush_pct 12, refused when nothing to mend; trek_oldcamp_checkpoint 1 = KO wakes at the furthest-down rested site if beyond last camp (no banking). Ch I Cold Hearth 33,15, Old Lean-to 20,27; Ch II Dry Ledge 7,14, Sagging Tent 16,66, Cistern Bench 14,89. 11 text slots (trek_texts_oldcamp.txt, trek_drafts_2_0_1.txt). tests/trek_oldcamp.php.
- Road in-sight card live countdown (gvCountdown ticks every [data-countdown]; data-show-at-zero / data-hide-at-zero); "then on to B, then toward C (your destination)" wording (Poppy names were correct, wording confusing).
- Tests fixed: stale draft count, security190 riddle tries. News entry (Treks not announced).

## 2.0.0.1 (2026-10-19)
- Puzzles: animated jigsaw game from the Jiggy Jigsaws source. `game/puzzles.php` + `assets/puzzles.css/.js` + `assets/img/puzzles/*.gif`; tile at the end of the Games hub. No prizes, no server state, no schema.
- New picture: Swaying Sunflower (`tests/gen_puzzle_sunflower.py`). Add more: drop a .gif in assets/img/puzzles/ and a row in PUZZLES (puzzles.php).
- Fitted to CSP (no blob:, inline, web fonts): pictures are files, data in a JSON block.

## 1.9.9
- Treks audit (3 parallel passes). Ch I: KO clears stale event card; hidden crew moment no longer blocks trail events; double-tap camp when rested no longer burns a kit; free first kit goes to pack when kits at max; trek_short_name() ("Captain Dov" not "Captain"); fight Round heading centred; mother-aphid brief says 4th round. Ch II: silvergate zone l→m, drumgate s→r; new slot ch2.spot.thrum.stunned; never-locked gate no longer asks for missing .open text. Engine: trek_load survives corrupt state/log/fight JSON; removed crew row plays as plain trailmate; admin/trek_text.php array-param guards (trek_arg); trek_inside() honours trek_open/level gate (admins exempt). New tests: trek_audit_ch1.php, trek_audit_ch2.php, trek_audit_engine.php + trek_audit.sh (in treks.sh). Security: ~45 bad-input POSTs, XSS, concurrency all pass.
## 1.9.8
- shop.php Buy/Sell = Satchel-style picture tiles (rarity, art, name, price, stock/you-have, season/price marker) → `<dialog>` sheet (gvOpenDlg) with −/qty/+/All, live total ("Too much" disables Buy), same POST fields (do=buy|sell, qty[id], CSRF). Long text folded. Old basket JS replaced in site.js; chip filter scoped to .shopwrap. CSS "v1.9.8 shop tiles". Shop intro + counter centred. Not converted (one-click rows): Curio/Dye Pot (sinks.php), marketday.php, haven pantry, festival.php stalls, local.php, market.php. News entry.
## 1.9.7
- Yard: tapping a glowing building (hive, compost, animal homes) collects and returns to the garden (form field from=yard); not glowing still opens its info on the Buildings tab. Panel Collect buttons still return to Buildings.
## 1.9.6
- Today page centring (CSS block "v1.9.6 Today centring"): greeting card (desktop too, overrides v1.7.5 left rule), news card header/Read, Wren tip.
## 1.9.5
- Treks no longer use gnome level for balance: setting `trek_base_level` 15. Ch I foes grow toward base−1; Ch II lift row removed (parser ignores lift); Bracken duel + trailmates (base−2) + player gnome (`trek_gnome_user()`: level = base; stat points, calling, buffs still count; level-derived HP/armour/attack and calling tier don't) use base; find-Petals outlevel cut vs base. Party cards no longer show level. Gate L15 + milestone gnome XP unchanged. Retune: silverfin 106|7|3|14, zone l 250|12|8|11, m 250|11|8|12, o 385|14|8|16, old-pinch 212|11|6|21, old-thrum 140|17|8|60 (short, hard-hitting). Sims same at gnome 15/20/30: zones 82–94%, Silverfin Lv10 72–78 / Lv11 ~90, Pinch ~85, Thrum healer ~85, no-healer 61–71 (parties with Sorrel or no Burdock ~21–25%). tests/trek_levels.php asserts identical numbers at L15/L30. No news entry (Treks hidden).
## 1.9.4
- Road (branch road2): road choice cards (data/road_events.txt: 30 generic + 8 each NA/NWE/EA + 12 sights; OFFPATH_* moved out of explore.php; old saved choices still resolve). Roll shares creature 40 / problem 22 / choice 14 / find 24 (constants). Villagers + travellers met on roads (data/road_meet.txt 44 lines incl. Warm/Eager/Fussy/Dreamy; clock hashes, no cron; ~30% of finds when someone is about; chat = existing once-a-day claim, travellers use npc_talk maths minus gifts). Wonder text per wonder (data/wonder_text.txt intro/success/fail ×35 + 9 day moods; mood shifts DC −1/0/+1; non-own approaches change daily). village_blurbs.txt (+4 per landscape, hashed). Centring pass road/explore/delve/landmarks/walk bar. `.choice` text centred sitewide (spacer balances the icon when no badge). No schema change.
- Treks (branch trek2b): Chapter II-b — map ch2 40x106, +15 spots (Crossroads/Tumble signpost riddle, Hush sneak, Dim, Brewhouse camp 2/Juniper, Sour Cistern/Old Pinch, Drum Chamber/Old Thrum), finish + interlude 2. Data *_ch2b.txt (94 text slots with briefs + drafts), 5 new creatures (placeholders tests/gen_ph_ch2.py). Camp-to-camp travel (+12 fatigue) + Slide (spot type `slide`), spot `icon=` key, zone style `d` + `hint`. Settings trek_ch2_petals 500 (chapter finish, once), 5 II-b milestones, `trek_cold_rest_fatigue` 25 (cold rest without kit: −25 fatigue, ¼ heal; kits/camps/rest spots stay −50/½). trek_drafts() multi-line parser fixed. tests/trek_ch2b.php in treks.sh (226 ok). Sims: gnome16 normal 82–92%, Pinch ~82% (95% if drained), Thrum ~89% with a healer (20–60% without); gnome20 ~100%.
- Fast travel blocked inside a trek (gathering allowed). News entry (Treks not announced).
## 1.9.3
- Road life (non-trek explore). includes/road_life.php: `road_pick()` anti-repeat ring (last 8 per kind in users.road_recent; last 3 banned, next 5 ×0.3; written only by road_flush() inside adventure.php transaction + user lock) for creatures, problems, finds, off-path choices/sights, ambient lines; creatures/problems cached per request. `cond` column (VARCHAR 190) on problems/creatures/gatherables, stop syntax dp/se/we; `!` prefix = hard requirement, plain = ×3 weight; tags in data files' last column; admin editor field. 8 new weather/season problems (all hard-gated). upgrade193.php step `upg193_road_cond` (import_problems_txt + road_cond_backfill only where cond empty). data/road_lines.txt (160 lines: cond|lands|region|text; Claude drafts) one per road space/explore step, heading + walk bar show the next one (seeded); arrival logs the stop type's daypart ambience. UI: off-path choices + road/explore/delve buttons as `.choice` rows; small result card. CSS "v1.9.3 road". Tests: tests/roadlife.sh (+ roadlife.php), tests/upgrade193.sh. News entry.
## 1.9.2
- Treks Chapter II-a "The Weeping Clay" (data *_ch2.txt, trek_map_ch2.txt 40x46, 553 walkable, ~202 route steps, ~21 fights): Seep Steps → Tin Lamp camp → Drowned Library (Sorrel Inkcap Seedkeeper, lore 3; riddle door opens on answer / Seedkeeper / 3rd fail; Silverfin boss hit/sweep/mend, enrage <30%, ≤2 adds) → Potter's Row → closed Crossroads gate (ch2a_end). Tiles `:` wet clay, `*` crystal, `w` water drained by sluice switch spots. Milestones ch2_sorrel 400, ch2_silverfin 1000, ch2a_end 800. 88 new text slots (briefs + drafts). Admin trek_text.php: chapter tabs, status filter, Claude's suggestion, Restore; in-game ✏️ pencil for admins on draft text (trek_draft_marker). Today page merged (no tabs; phone: greeting, news, 6 cards, Hollow, tip; desktop: greeting, 3x2 cards (4-wide with Treks), Hollow | news+tip; rail hides weather/boosts/tasks on Today); status strip centred. tests/trek_ch2.php in treks.sh. Tuned for gnome Lv16 (sim 89-97%, Silverfin 79-91%).
## 1.9.1
- Treks chapter engine: per-chapter trek_runs rows (UNIQUE user,trek,mode,chapter), users.trek_ch, per-user Petal cap users.trek_pet_day/today. Interlude hub "The Shard Hollow" after a chapter (no replay; old run read-only, Log tab keeps it). trek_godown carries recruits, st.tl, st.tac, kits. Data-driven chapters: includes/data/trek_chapters*.txt (chapter/zone/ms/check/tune/finish/lift rows); boss registry trek_scripts()/trek_script_register(). MySQL migration verified live.
## 1.9.0
- Player's own gnome (gnome_avatar via trek_me_ico / trek_art_me) in Treks; Leave + Climb out confirm (trek_form $formAttrs, trek_leave_confirm); map wall texture + root/hedge seam; road fight "Show all" log (exp_log_cap 160 in fights); security fixes (trek_post_str/int, plan slots 0-3) + tests/security190.sh; news entry.
## 1.8.10
- Trek map art (includes/trek_art.php, one SVG per map; open zones = blighted hedge bands, underground g/w/c/x = root bands; lantern radial gradient on player), walk animation (assets/trekmap.js; path one-shot in $_SESSION['trek_walk']).
## 1.8.9
- Trek levels (includes/trek_levels.php; st.tl[crew]=[lv,xp]; uncapped; +6% HP/lv, +1 hit/2 lv, +1 dmg/3 lv; late recruit = avg−2 with +50% catch-up). Gnome XP ONLY from milestones (settings trek_ms_*: 150/250/350/500/600/350, × 0.5–1.0 by checks); table trek_ms (survives admin reset). trek_xp_daily retired. TREK_TUNE retuned. Migration gives mid-run players a start level. Banked items as Satchel tiles. tests/trek_levels.php.
## 1.8.8 / 1.8.8.1
- Trail events (includes/trek_events.php; trek_event_pct 6, trek_event_gap 15), stops Stuck Cart / Mushroom Camp / Riddle Stone, crew moments, full fight log (Show all, replay stays open, Full log link). New text slots ship drafts from includes/data/trek_drafts.txt (used only when slot is new). tests/trek_events.php.
## 1.8.7 / 1.8.7.1
- Road fight compact on desktop (fight above map, 2-col actions, Attack centred); party cards "▾ Tap for stats & tactics".
## 1.8.6
- Tactics per member (st.tac[crew_key]); trek_fight_ai (snack > heal > shield > open > ability > attack); tests/trek_tactics.php. Party/Pack rework; same-name foes grouped ×N. Blight Mother: 1 add / 4 rounds, ≤3 alive, ≤4 adds.
## 1.8.5
- Trek Auto plays back round by round ($_SESSION['trek_replay'], `<dialog class="tkr">`).
## 1.8.4
- Trek fight redesign: plan line + plan sheet (`<dialog class="trekplan">`, radio tiles), plan memory st.plan, "Plan each turn" mode, fades. assets/trekfight.js.
## 1.8.3 / 1.8.2.1
- 1.8.3 Treks tidy (hud card, no empty story lines, capped map, tile buttons, 2 cols ≥1000px). 1.8.2.1 phone toasts move to top while a Satchel item sheet is open.
## 1.8.2
- Pickers + chest = native `<dialog>` (gvOpenDlg/gvCloseDlg); confirm()/alert() → gvAsk/gvSay (data-confirm on forms and buttons); aria-labels on icon buttons; @view-transition fade; :user-invalid; hero fetchpriority. CSS block "v1.8.2 tighter layout" (desktop header 40px, strip 34px, phone header 46px, travel stack 700px).
## 1.8.1
- `games_petals_percent` 60 + `game_petals()` (Worms, Memory, Spit, Mushroom, Pest, Letters + Rules text). `orders_food_quality` 0 (crop/preserve orders no grade, diff 1); boot_step `market176_almanac`. "Where to next?" restyle (CSS "v1.7.6 travel card"). Treks fixes: trek_petals_daily 150, trek.php in AJAX_PAGES, trek_runs.finished set, admin reset warns rewards re-pay. tests/market100.php covers food quality.
## 1.8.0
- Treks (NeoQuest-style party campaign), Chapter I "The Wilting Rows": trek.php (?t=map|party|pack|log), includes/trek.php, trek_fight.php (copies adventure.php maths, keep in sync), trek_data.php, admin/treks.php, admin/trek_text.php. Data trek_map_ch1.txt, trek_spots.txt, trek_crew.txt, trek_creatures.txt, trek_texts.txt (89 slots). Tables trek_runs/party/recruits/pack/flags/texts. Gate L15 + trek_open (default admins only). Road walks/explore/landmarks blocked inside a trek. tests/treks.sh, tests/trek.php. CSS "v1.8.0 Treks".
## 1.7.5
- Tasks badge + bottom-bar pip = jobs + quests + orders (cached $_SESSION['nav_badges'] 60s). Journey Hand in / Finish on jobs.php?t=quests. "Villagers" wording. 721–1199px side nav = A4 look. Shop one season tag. Today greeting stacked on phones. CSS "v1.7.5".
## 1.7.4
- CSS-only alignment pass (style.css block "v1.7.4 alignment"): contests 2-col grid + compact buttons on desktop; rail walk/fight centred, stacked duel, 1-col choices; phone walk bar centred; Today jar bars full width, right-aligned links, equal tabs; town tiles auto-fill 260px; donate row flex; tabular-nums; balanced headings; dark `.btn:hover` readable.
## 1.7.3 / 1.7.3.1
- Menu regroup (phone + desktop): You (Gnome, Almanac, Satchel, Crafting), Grow (Garden, Arranging), Out & about (World, Town, Villagers, Seasons, Passport, Games), Together (Trading, Together, Tasks, Gnome friends), Account at bottom. Desktop >=1200px "A4" sidebar: groups always open (`.navfixed`), 2-col icon+name tiles. 21 `nav-*` placeholder icons (tests/gen_ph_nav.py; items.php `nav_icon()`/`NAV_ICONS`; real art uploads/nav/{slug}.png via Admin → Images). Rail box "Tasks". Almanac: Contents always open; Plants/Flowers filter by region (`reg`) + kind (`tier`). 1.7.3.1: phone sheet shows tiles that are also on the bottom bar.
## 1.7.2
- jobs.php = "📋 Tasks" tabs ?t=jobs|quests|orders|errands (sub ?p=); helpers tasks_* in includes/quests_view.php; town.php?view=quests → jobs.php?t=orders; jobs.php?s=quests → t=quests; journey.php `back` accepts jobs.php. community.php = "🌻 Together" ?t=garden|jar|about; hollow.php redirects to ?t=jar. "Gnome friends" / "Villagers" names; "Calling mentor" vs "Gnome mentor". games.php?tab=contests hub (contests_hub_html, includes/contests.php); entry pages "← Contests". Tests updated (social100, mentors120, games2).
## 1.7.1
- Today Home: one jar/Pulse row. Admin settings: ~143 labels prefixed by feature + sub-headings. Unlinked pages audit: none orphaned.
## 1.7.0 (upgrade170.php, flag upg170_reacts)
- Reactions merged into guestbook stamps (PAL_STAMPS starts 🌻👏🐝✨; garden_reacts copied → garden_stamps, table kept unused). Player text "Guestbook" (passport stamps unchanged). One "Visitors today" roll-up notice per garden/day (stamps + watering; `social169_notify_owner`). `gate_can_interact()`. Garden "🤝 Need help?" fold. Menu de-dup (one Jobs & quests tile, Contests via Games, Getting started only during tour <L5). `tour_active()` false when `away_from` set.
## 1.6.9 / 1.6.9.1
- includes/social169.php: 💧 Water for them on visit.php (1/day per plot per helper, cap `social169_water_gardens` 3, 1 energy, 5 XP + 5 Petals; garden_waterings UNIQUE; water logic duplicated from garden water case) + reactions (merged in 1.7.0). 1.6.9.1: no friendship needed; same sign-up IP (`mentors120_same_origin`) earns nothing. Shop/sell/curio/dye `.choice` rows; seed picker selected; crafting ×1 solid. World map piecewise depth scale (MYC_VER 160b), desktop cap 460px. Phone header fits ≤440px.
## 1.6.8
- Email verify at sign-up (verify.php; resend 3/h). Opt-in reminder emails default OFF (users.email_nudges; includes/mail_nudge.php `mail_nudge_tick()` in page_footer shutdown after fastcgi_finish_request, once/hour; unsub.php HMAC + List-Unsubscribe; no sends while `mail_address` blank). send_mail optional SMTP (config smtp_*). admin/retention.php. includes/logrotate.php (error log → .1 at 1 MB). Backups: 5 DB / 2 program zips. bootstrap writes data/.htaccess deny (data/ had been web-readable). Tour-first helpers (`helper_slot()`: back > fw > daily > fest). Placeholder red outline removed. Sub-folder installs: own session cookie + X-Robots-Tag noindex (`app_base_path()`).
## 1.6.7
- Desktop rail: "On the road" box above Messages (site.js `walkBox()`).
## 1.6.6
- World → 🗺️ Map tab (`?tab=map`): region map first, world map in `details#worldmap` (`&w=1` opens). Old `?r=` links land there.
## 1.6.5 (10-17)
- Dark by default: `<html data-theme>` from users.theme (new column, default dark; dark/light/auto) → cookie gvtheme → dark; auto via early.js. Dark CSS now keyed on `:root[data-theme="dark"]` (tests/theme_css.py rewrites @media dark blocks; re-runnable). theme.php (POST+CSRF, safe back). Toggles: phone menu (next to Today), desktop header, account "Look" box, footer (logged out/admin). News post.
## 1.6.4.1–1.6.4.2 (10-17)
- Walk-bar fight rows compact 2-up. Desktop admin side menu = plain list; "Update, settings & system" section first.
## 1.6.4 (10-17)
- Region maps: 🏷️ Names chip (remembered per device), ＋/−/⤢ zoom + drag (names show at ≥1.5×), pinch coded (untested on real touch), tip line. Walk-bar fight actions as .choice rows (closed line keeps small buttons).
## 1.6.3.1–1.6.3.5 (10-17)
- Phone status line flat + centred (level + XP bar, season day + weather, festival icon, badges). Admin phone menu = tile grid from admin_menu_def (old side-nav removed). Tab rows ≤5 one equal row on phones; World "Here" tab. Fast travel = own World tab.
## 1.6.3 (10-17)
- `.choice` rows on fights (odds badge), problem approaches, rest-stop activities, Job Board. Adopt slots: 1 + 1 per stop at Hall tier (max = stop_adopt_limit, now 3). Animal cards show feeder N/M + next gift ETA; worms 12h (was 24). Satchel/Crafting/Arrange tabs one row; Show/Sort dropdowns; ✨ Untasted filter; Almanac dropdowns. Phone top chrome folded to 2 lines. Garden phone crop covers all used squares (toggle above grid). Path line drops ❤️/⚡. New logged-out landing + How to play + 7 SVG teasers (old landing jpgs removed). Admin: grouped searchable menu, crumbs, phone tables. Player news for 1.6. upgrade163.php (adopt limit 1→3, worm 24→12).
## 1.6.2 (10-17)
- First-hour fixes from a newcomer playtest: tour card once per step then a one-line chip; phones show 1 toast at a time above the bottom nav ("🧺 +3 Radish"); square panel = 2 plain lines + "Soil details" fold; seed picker cards size to content; phone garden crops to beds (~48px squares, "Show whole yard"); energy note; till confirm only for no-till; Almanac day one flags 3 "Start here" pages; rest-stop odds as %; walk bar shows 🏁 destination; tap targets ≥40px; tab/chip rows wrap (no sideways scroll); seed placeholders show their crop.
- Games energy: no daily cap (upgrade step `gamesnolimit`). Map auto-scroll only on map tab/fold. Rest-stop "full town square" footer removed.
## 1.6.1 (10-17)
- Maps shorter on phones: region map defaults to nearby view (2 steps + town + quest targets; "Show whole region" `?full=1`), names only on big places/current/quest spots (villages: tap), auto-scroll to 🎩 (`gvMycScroll`, site.js).
## 1.6.0 (10-17)
- Mycelium cross-section world + 14 region maps (includes/maps_myc.php): depth = 8+(min_level-1)*1.75 roots (topsoil/clay/deep rock/bedrock at 28/45/62), gauge, surface shaft, folk 👤 / quest ! / gather overlays, filter chips (sessionStorage). Scenery cache data/cache/myc-*.txt (denied .htaccess, atomic writes; bump MYC_VER when scenery changes). Setting `map_style` = classic rolls back. Fable-reviewed.
## 1.5.3 (10-17)
- ~1400 SVG placeholders in assets/img/ph/ (palette.json). Lookup order: real art → flower art → ph → emoji (`ph_img`, `ph_or_emoji`, items.php). Generators: tests/gen_ph_items.php, gen_ph_folk.py, gen_ph_world.py. Admin → Images counts placeholders (still "missing").
## 1.5.2
- Fixed CSS merge markers (snail cards). build_update.sh refuses conflict markers.
## 1.5.1
- Image URLs versioned (`url()` adds ?v=APP_VERSION / upload filemtime). Rock-pick practice = gather game.
## 1.5.0
- Gathering minigames reworked (six, incl. Spore Lure fishing), Games → Practice tab. Rest stops: no hard cap; after `stop_daily_total` (100) visits Petals/XP halved till midnight (6 per stop/day, 3 per visit).
## 1.4.8 / 1.4.7
- Pest Patrol (25 growing plants, Ladybird tie-in, bug-net bonus). Wonder approaches as compact rows. All games give energy. Walk-bar choices centred. GOTM: players above NPCs. Animals tab quiet-day note. Snail race / weight / letters restyled.
## 1.4.6
- Seed Memory and Mushroom Sweeper restyled (assets/memory.js, assets/mushroom.js); double-tap guard. Delve chest reveal overlay (includes/chest.php, assets/chest.js). Walk bar fold keying (`data-busy`, `window.gvAdvLast`). Bottom bar gesture gap capped. tests/explore.sh home fallback.
## 1.4.5 / 1.4.4 / 1.4.3 / 1.4.2 / 1.4.1
- 1.4.5 spit result faster; admin/xp.php groups sources. 1.4.4 admin/xp.php CSV export. 1.4.3 region map rework (`region_map_svg()`), smaller fight buttons, craft filter chips in place. 1.4.2 spit hotfix (never swallow a tap, wait `spit_min_ms`). 1.4.1 game pages 🎮 Play / 📖 Rules tabs (includes/games.php).

## 1.4.0 (slim needs 1.2.0+; `upgrade140.php` flags `upg140_animals|crafts`)
- Garden animals (`animals140.php`): 🦋 Butterfly Bush (L4, 1,100), 🐌 Snail Jar (L3, 300). 26 new creatures L12-28; `pick_creature` window L-6..L+2. 🎒 Snack in fights (`fight_snack_heal_mult` 3, 1/fight). Fight on replays (assets/fighton.js). Seed Spitting physics (assets/spit.js; server `spit_sim()`), Worm Hunting wander (assets/worms.js). Garden tabs `?t=` beds/bld/an/help/grow. Soil craft outputs up. tests/games140.sh.

## 1.3.0 (slim needs 1.2.0+)
- Fights: odds line, ⏩ Fight on, flee DC 8 + lvl/3, +10% HP on quiet steps. Late creature HP eased at fight start (`creature_hp_late_percent`). Rest stops tabs Do / Folk / Stop, 2 errands offered.

## 1.2.3
- Smaller walk-bar buttons; problem approaches with chance badge; visit.php 🧬 cross hint; admin/xp.php `mentor_share` label; trade.sh fixed.

## 1.2.2 (slim needs 1.2.0+; col `users.sess_ver`)
- Free daily water in select mode. Oct 13 review fixes (GotM alt guards, mod self-action, sess_ver logout, reset timing leak, account delete scrub, notices pruned 30 d). Races closed (users-row lock + re-read, or DELETE/conditional UPDATE as claim) across jobs, expeditions, games, gifts, GotM. Day turnover = midnight Hollow time. Bug fixes (spider map, rand:rare, mole, delve kind, Wayfinder price, admin item delete refs). `boot_step()` wrapper + `boot_failed_steps`. load_plot writes only on change.

## 1.2.1
- Garden select mode quick picks.

## 1.2.0 (slim needs 1.0.0+; `upgrade120.php`)
- Quail Coop, Silkworm Shelf, Tortoise Run; Clementine the goat, Percy the pigeon; 9 recipes, 4 crafts, 13 Almanac pages. Player mentors (mentors120.php). Today tabs Home / Out / Hollow.

## 1.1.0 (slim needs 1.0.0+; `upgrade110.php`)
- Crop breeding (22 hybrids, breeding110.php, admin/hybrids.php). 11 egg recipes. Quests tab in Jobs. `cook_energy_percent` 150 → 115; `orders_board_max` 5 → 3.

## 1.0.4 / 1.0.3 / 1.0.2 / 1.0.1
- 1.0.4 pause at rest stops too. 1.0.3 walk bar folds. 1.0.2 phone declutter (Today ~7100px → ~1450px). 1.0.1 `fresh_hold()`, Hollow Goals roll-up, caches.

## 1.0.0 "The Hollow Wakes Up" (slim needs 0.9.9+; `upgrade100.php`)
- Clock/seasons/weather/daypart. Rest stops rewrite (12 types, 55 activities, 365 villagers, passport, adopt-a-stop). Crop seasons, weather, pests, companions; Worm Farm, Ladybird Lodge, Frog Pond, Biddy. Townsfolk orders, market day, price drift. Social: Hollow Goals + Pulse, friends/guestbook/gifts, First Week, welcome back, daily card, Opening Day.

## 0.9.x
- 0.9.9 flower arranging, drying rack, seed packets, florists; gathering mini-games rewrite. 0.9.8 Pantry; item pictures + Admin → Images. 0.9.7 action XP scale, easy roads, Petal sinks (Curio, skins, feasts, Dye Pot, signposts). 0.9.6 desktop 3 columns, dark mode tokens. 0.9.5 "Add 4 beds", Kitchen stacking, fences auto-join, yard undo. 0.9.4 calling questlines (6 mentors, 12 chapters) + cooking/energy rework. 0.9.3 region maps, road board, GPS plans. 0.9.2 visual makeover. 0.9.1.1 select-all, calling change cost (versions stay numeric). 0.9.0/0.9.1 calling tiers + XP retune.

## 0.8.x
- 0.8.9 real climates, editable page text, energy regen 1/min. 0.8.8 SEO (seo.php, guide.php, sitemap.php, robots.txt, manifest). 0.8.7 soil care stars. 0.8.6 landing page, feedback form. 0.8.3/0.8.4 new menu. 0.8.1 Mushroom Sweeper, Lost Letters, Harvest Fair. 0.8.0 Guess the Weight.

## 0.7.x (2026-10-09 →)
- 0.7.0 14 regions, 81 landmarks, staple/uncommon/treasure tiers, 168 flowers, region medals. Wren's tour, auto DB upgrade, tools, gathering, crafting/cooking, NPK, hired help, Job Board, Trading Post, Worms/Memory/Snail Race, NPC friendships, Community garden, Village Show, carving, town squares, NPC lives, roads, exploring, moderation, yard designer, visits, GotM, renamed Gnome Venture (0.7.36), first live MySQL fixes, SVG maps, admin updater (0.7.40), start in Maplewold, npc.php/mod.php renamed (host blocks), in-place updates, security pass. 0.7.64 balance (sell mults, regrow, steep XP). 0.7.74–0.7.99 exploring tuning, repairs, gathering, Toolbelt, building upgrades, Gather tab + Seek, destinations, tappable buildings.
