# Gnome Venture: Treks plan (draft v5, 2026-10-17, checked vs source 1.7.5)

NeoQuest-style campaign, called **Treks** (player-facing and code). Party = player gnome + 3 of 8 featured Trailmates (friendship Acquaintance+). One trek first, roughly NeoQuest length, with QOL fixes. Chapter I detail: claude/trek-chapter1.md.

## Decided (Joshua)
- Name: Treks (was "Expeditions"; that word is already the internal road-walk system).
- Unlock L15 (= calling_tier2_level default).
- Trailmates: 8 featured only. The word "Companions" is taken (companion planting).
- Classes: the 6 existing callings.
- Entry costs 10 energy per entry (at L15 max energy is about 80). Free inside.
- Party Fatigue bar: rest at camps or Make camp to recover (detail in chapter1 doc).
- Camp Kit: bought, 60 Petals.
- KO: lose 45% of unbanked finds, rounded down, per stack. A stack of 1 gets a 45% chance to be lost. Found Petals also lose 45%. Back to the last camp. No loss before the first camp (tutorial).

## Source findings (1.7.5)
- Table `expeditions`, `active_expedition()`, `exp_log()`, `save_exp()` = the road walk / explore system. Treks use the `trek_` prefix everywhere. "Trek" appears nowhere in the 1.7.5 source.
- Never call treks "expeditions" in UI text: the internal word would confuse future code searches.
- Only one outing at a time: block a trek while `active_expedition()` is set, and the reverse.
- "Companions" = companion planting (companions.txt). Trailmate data goes in `trek_crew.txt`.
- Callings and their fight roles: Rootwarden tank (Bark Skin), Bloomcaller healer/charm, Thornblade fighter/crits, Seedkeeper spore magic/puzzles, Wayfinder hidden paths/sling, Brewroot poison/+1 snack.
- Combat (includes/adventure.php) is 1v1, d20. Reuse the maths (gnome_combat, attack_roll, damage, calling_perk, fight_odds) in new `trek_combat()` for parties. Don't edit combat_turn(). Comment both places so they don't drift.
- Healing outside camps = the existing Snack action.
- Friendship: FRIEND_LEVELS in includes/friends.php (20 Acquaintance, 100 Friend, 250 Good, 500 Best).

## Shape
- Menu: Out & about → 🥾 Treks. Page `trek.php`, tabs ?t=map|party|pack|log.
- First trek, "The Withering": blight rising from the deep. Topsoil → clay → deep rock → bedrock (maps_myc.php layers). Final boss: the Blight Crown.
- 6 chapters. Each has 1 map, 1 camp, 2-3 side spots, 1 boss. About 1 chapter a week at 20-30 min/day.
- Replay modes: Gentle → Thorny → Bramble.

## Party
- Gnome: real level + calling tier perks.
- Trailmates: fixed calling each (2 repeats; suggest Bloomcaller + Thornblade). Level = gnome level −2 (min 13). Trek XP buys skill points only.
- Recruit scenes give +20 friendship, so nobody is locked out. Later friendship gains: daily cap.
- Swap at camps only. Duplicate callings allowed.

## Map
- About 40x40 tiles per chapter. Phone view 9x9, desktop 15x11. Tap-to-walk; walking stops on an encounter.
- Fog, mini-map, ! objective.
- Wayfinder reveals hidden tiles. Seedkeeper opens riddle doors.
- Camps: heal, fatigue 0, bank, swap, respec, fast travel.

## Fights
- Each member: Attack / Ability / Snack / Guard; Flee = whole party. `.choice` rows + odds badges.
- Boss moves are shown one round ahead on the fight card.
- ⏩ Auto (heals under 40% HP), 🔁 Fight on, speed setting. 🥾 Hunt / 🤫 Sneak (×0.25).
- Respec at camp: free in Gentle, Petals in Thorny/Bramble.

## Economy
- Gnome XP via `add_action_xp`, daily cap `trek_xp_daily`.
- Sinks: entry energy, snacks, Camp Kits.
- Rewards: chapter Petals, trek-only seeds, Book entries; at the end, hat per mode, passport stamp, news line; Bramble trophy.

## QOL vs NeoQuest
Autosave every step, any device. Tap-to-walk. Auto battle. Sneak/Hunt. Fast travel. No missable items (lost-and-found at camps). Quest log. Skip seen text. "Recap" on return. Rest of site usable mid-run.

## Data and code
- `includes/data/trek_*.txt`: maps (ASCII), creatures (Blightlings), crew, dialogue, loot. Importers add missing rows only.
- Tables: trek_runs(id, user_id, trek_key, mode, chapter, x, y, camp, fatigue, state JSON, started, finished; UNIQUE(user_id, trek_key, mode)), trek_party(run_id, slot, crew_key, xp, hp, skills), trek_pack(run_id, item_id, qty, banked), trek_flags(run_id, flag), trek_seen(run_id, tile_key).
- Race safety as adventure.php v1.2.2: lock the gnome row, refresh, re-read the run.
- `includes/trek.php`, `assets/trek.js`, admin/treks.php. Settings "Treks: ..." (`trek_*`).
- Host: test-upload an empty `trek.php` first.

## Build order
1. Engine + Chapter I slice. Joshua tests on phone.
2. Tune length, encounter rate, fatigue numbers.
3. Chapters II-VI + all 8 trailmates (Sonnet/Haiku draft, Opus review).
4. Modes, hats, trophy.

## Risks
- Content cost >> engine cost.
- 4 vs 4 on a 412px screen.
- Copied combat maths drifting from adventure.php.
- 10 energy is cheap at L15+ (about 10 min of regen). That's fine because energy only gates entry; fatigue gates session length.
