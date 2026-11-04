# Note for another AI: Run 3 part 2 (tag C2) — where it is and what it covers

- Branch: `c2-01Qem` (repo joshfryart/gnome-venture), branched from `origin/ccr-c4d6c653-u81tm0`. Not yet rebased/merged into the shared branch.
- Scope: 140 static 64x64 items, `ph/lemon-cordial` .. `ph/nav-together`. List: `aseprite-source/v3/rollout/run3-part2.json`. Nothing outside this list was touched except docs (HANDOFF.md, ROLLOUT-STATE.md) and rollout/run3-part2-remaining.args.json.
- Output: `aseprite-source/v3/items/final/ph/<name>.lua/.png/.aseprite`; helpers in `items/final/_helpers/` (`_aC2*` / `_aC2r*` = Opus, `_dC2*` = Sonnet drafts). All filenames are unique to this list, so merging with C1/C3/D parts should only conflict in the two docs (keep both sides).
- Status: 140/140 Opus-finished (grep `_aC2` or `_aC2r` in each .lua). 97 in the first pass (C2), 43 in re-run C2r after the 5-hour limit. 0 draft-only. check.py: 0 missing, 0 bad.
- Not done: no fix round, no PDF/artifact rebuild, game code untouched.
- Weak per artists (ask Josh before fixing): lizard-scale, loach-scale, millipede-plate, lettuce-seed, lilac-seed, lucuma/lucuma-seed, lungwort-seed (ant quirk), lychee-seed, mandarin-seed, marzipan, moringa-seed, morning-glory-seed, moth-orchid-seed, mossy-shell, nav-passport, nav-tasks.
