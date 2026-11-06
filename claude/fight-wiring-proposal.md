# Proposal: fights on the map scene, popover removed (2026-11-06)

Status: PROPOSAL, nothing built. Based on a read of `adventure.php` (POST handlers ~l.60-135, encounter card l.354-409), `includes/adventure.php` (`combat_turn` l.538, `auto_resolve` l.836, `fight_on` l.945, `fight_replay_stage` l.992), `includes/trail_tiles.php` (`trail_token_event` l.172, `trail_roll_event` l.194, `trail_view_html` l.309), `assets/fighton.js`. Engine and plan: `claude/animating-2-5d-sprites.md`, `claude/fight-plan.md`.

## What happens today
1. A token (E fixed / R random) or `trail_roll_event` sets `exp['encounter']` = `{type:'creature', id, hp, max, ...}` (`trail_token_event`, `next_step`).
2. The page renders the encounter inside a `<dialog class="trailpop">` over the map: a landscape picture (`adventure_stage_html(... 'fight')`, `scenes/fight-<land>.png`) with two sprites and HP bars, a two-card HP grid, and `act_choice` buttons (Attack, ability, Run, Fight on, Snack, Auto-win).
3. Each button is a POST (`do=attack|ability|flee|palskill:*|snack|fighton|auto`) handled in one transaction: `combat_turn` / `fight_on` / `auto_resolve`. The server rolls everything, writes log lines, then the page reloads with the new state.
4. "Fight on" replays rounds with `fighton.js` (`$_SESSION['fight_replay']`, hidden stage, tap to skip).

## Proposal in one line
Replace the popover with the fight engine **in the map's scene slot**, driven by a structured event list the server already almost has. Buttons stay server forms. No schema change.

## 1. Remove the popover (fights first)
- Drop the `<dialog trailpop>` wrapper and `adventure_stage_html(...'fight')` for `type==='creature'`. The creature encounter renders **inline**: `.fe-stage` replaces the tile grid area while a fight is on; the tile map returns when it ends.
- Action buttons dock in a bar directly under the stage (same `act_choice` forms, CSRF and rules untouched), laid out 2 columns, **sub-lines moved into a small "?" fold** (this also fixes the clipped "A determined…", "Slip away, …" text).
- HP cards go away: HP bars become HP bubbles over each fighter (already built). The "About the <creature>" fold stays under the stage. Gnome stats line (atk, ac, die) stays as one small row.
- Other encounter types (choice, meet, problem) keep a popover for now; then become a docked card in the same slot (phase 4). Reason: one risky change at a time.
- Gate: new setting `fight_scene` (bool, default 0) under `gnav_tiles`. Off = today's popover, so rollout and rollback are a toggle.

## 2. Server: emit events (the one real server change)
`combat_turn` already knows every die roll. Add a tiny recorder and push structured events where the rolls happen (not by parsing log lines):
```
fight_ev($exp, ['from'=>'me','to'=>'foe','move'=>'attack'|'pluck','dmg'=>N,'miss'=>bool,'crit'=>bool])
fight_ev($exp, ['from'=>'foe','to'=>'me','dmg'=>N,'miss'=>bool,'crit'=>bool])
fight_ev($exp, ['from'=>'me','move'=>'flee'|'guard'])      // run (success shows the run; failure shows a stumble)
fight_ev($exp, ['from'=>'me','move'=>'fixhat','heal'=>N])  // snack/heal ticks too: {move:'snack',heal:N}
```
- Stored in `$_SESSION['fight_ev']` for the next render (same pattern and 30 s freshness as `fight_replay_take`), plus the start state `{me:{hp,max}, foe:{hp,max}}` so the bars begin where they were. `fight_on` and `auto_resolve` just call `combat_turn` in their loops, so they emit a long list for free. This **replaces `fight_replay`** (one mechanism).
- Poison ticks, bark, pal skills: a `{from:'foe'|'me', move:'hit', dmg}` event with no attacker animation, so numbers still pop.
- Test: `tests/fight_events.php` with seeded dice: for each action, the sum of event damage equals the HP delta in `exp`/`encounter`, KO ends the list, run emits `flee`.

## 3. Client: `assets/fightscene.js` (adapter, ~80 lines)
- The page renders `<div id="fightscene" data-fight="{json}">` with: me (name, parts URLs from `gnome_rig_urls($u)` in the player's hat/beard/scarf colours, hp), foe (`slug`, mini image URL, rig, name, hp/max), the events, the land (for the board theme).
- It mounts `FightEngine`, adds both actors (foe uses `CRIT[slug]` if it has a rig, else the still mini picture: **works for every creature today**), plays `together(enter)` only on the first view of a fight, then `play(events)`. Buttons are disabled while playing; **tap = skip** (set speed x40, same as reduced motion).
- No-JS, reduced-motion, or script error: the server already rendered the final HP and log as plain text inside the stage and the buttons work. Same progressive-enhancement stance as `fighton.js`.
- Backdrop: keep `scenes/fight-<land>.png` as the stage background behind the tilted board, so it still feels like the same place. Board terrain themed by `land` (grass, sand, path colours) first; mirroring the exact tiles around the player is a later polish.
- CSP: no inline styles; the engine already sets CSSOM styles. Fits `style-src 'self'`.

## 4. Hat mechanic (server half, from the plan)
- `combat_turn`: when the gnome's HP first drops below 25% of max, set `enc['hat']=1` and emit `pop:true` on that hit.
- New `do=hat` (valid only while `enc['hat']==1`, no turn cost, once): heal `min(5, max_hp-hp)`, clear the flag, emit `fixhat`+`heal`. The engine's tap ring calls the same form (`onHatTap`).
- Fight ends with the flag still set: no heal, hat refits (engine already does this).

## 5. Creatures without rigs (about 100 minis)
Phase A (free): the still-picture rig plays every move already (charge/pounce/hop/slam by `ATTACK[slug]`, default charge). Phase B: batch rigs by archetype with `tools/creature_rig_parts.py` (quadruped profile, front-facing toy, bird/fish later), a Haiku-level agent measures a spec from `--grid`, one contact sheet check per batch.
The Shore Crab in the screenshot is a front-facing toy like the scorpion: cut like it.

## 6. Gnome moves needed
Plain **Attack** needs its own move (a simpler arm swing; Pluck stays the ability). Also `snack` (eat) and `flee` stumble. All data in `MOVES`/`POSES`, ~1 h each by the guide.

## Build order (each step shippable behind `fight_scene=0`)
1. `fight_ev` recorder + `tests/fight_events.php` (server only; no visible change).
2. `fightscene.js` + inline stage render + docked buttons, fights only, gnome parts in player colours, still-picture creatures. Replaces `fight_replay`.
3. Hat server half + tap ring wired.
4. Gnome `attack`/`snack` moves; Shore Crab and the next 10 most common creatures get rigs.
5. Other encounter types docked into the same slot; delete the popover code and `fighton.js`.
6. Phone pass (Josh): light/dark, 412px, slow device; then flip `fight_scene` to 1 by default.

## Risks
- Double-tap or reload mid-animation: state is already final on the server; events are shown once; the page is correct without them.
- Long Fight on / Auto-win lists: engine plays 30 rounds in 7 s max by raising speed per round count (reuse the 7 s rule from `fighton.js`).
- Perf on low-end phones (springs and drop-shadow filters): profile in step 6; `speed` and a "calm mode" (no hat physics) are the levers.
- `pal` skills and bark/poison add event types: covered by the generic `hit` event.

## Decisions I need from Josh (defaults in brackets)
1. Fights only first, other encounters later? [yes]
2. Themed board + landscape backdrop now, exact map tiles later? [yes]
3. Show Auto-win as a fast-forward of the full fight (watch it) or skip straight to the result? [watch, tap to skip]
4. OK to give plain Attack a new gnome swing and keep Pluck as the ability swing? [yes]
