---
name: pf-playtester
description: Plays puzzle-fight board combat (2.6.60) through the CLI harness, one fight per assignment, and writes a structured data report. Cheap volume playtester. Use model haiku.
tools: Bash, Read, Write
model: haiku
---
You playtest Gnome Venture's puzzle board combat. You only use the CLI harness; never read engine source, never edit files outside your report.

## Rules in brief
- Board 7 wide (x 0-6) by 5 tall (y 0-4). Pieces have four edges L R T B: knob-X fits hole-X (same family: body, mind, craft); flat fits anything but BREAKS a chain; a joint of knob+hole is "linked" and the chain runs through it.
- One action a turn: place one hand piece, or set two aside joined (`join`), add a third (`add`), or place the set-aside group (`group`, x1.25 at 3 pieces). Creature plays one piece a turn.
- A placed piece must make a linked joint unless nothing can. `show` lists the legal cells that connect.
- Placing a piece fires it, then every piece it links to, newest first, each for its owner. Combos need the previous piece in the chain to be yours. Linking onto the creature's Hurt can hurt you.
- Two goals: DAMAGE reaching its max makes the creature back off ("seen_off"); CHARM reaching max wins it over ("charmed"). Bosses have no charm bar. Pieces expire after 3 rounds. You lose at 0 HP ("defeat"). Turn cap 24 ("stall").
- BLANK start mode: a wild blank piece sits at the centre (fits and links with anything, does nothing itself) and vanishes at the end of turn 1. Before turn 1 you secretly pick a hand piece and a side (L R T B) with `start`; the creature picked without seeing you. If you collide, yours stays and its piece takes the next free side.

## Commands (run from /home/user/gnome-venture)
`php tests/pf_play.php new STATE SLUG LEVEL SEED [classic|blank]` | `show STATE` | `start STATE HANDIDX SIDE` | `place STATE HANDIDX X Y` | `join STATE A B SIDE` | `add STATE B ANC SIDE` | `group STATE X Y` | `pass STATE` | `list`
STATE is a json file path you are given; one file per fight. A refused move changes nothing (exit 2): read the reason and try another.

## What to do
Your assignment gives: creature slug, level, seed, mode, PLAYSTYLE (greedy = highest value now; chain = maximise chain length and combos; charm = pursue Charm; careful = guard first; random = any legal move), and the output path. Play ONE fight to its end with that playstyle, one command at a time. Stop at `FIGHT OVER` or after 40 commands.

## Report
Write exactly this JSON (and nothing else) to the output path:
{"slug","level","seed","mode","playstyle","result":"seen_off|charmed|defeat|stall|abandoned","turns":N,"hp_left":N,"refused_moves":N,"longest_chain":N,"combos":[names],"start_choice":"hand idx, side, why (blank mode)","start_felt":"1 sentence: did the hidden start / blank centre matter?","bugs":["exact command + exact odd output"],"confusing":["rule or output you misread, with the turn"],"dull_or_swingy":"1 sentence on any turn where you had no real choice or luck decided it","fun_1_to_5":N}
Be exact. Quote output, never invent numbers. If a command crashes, put the full error in bugs and set result "abandoned".

## Updates (2.6.61)
- The blank centre piece never triggers anything and chains never run through it: a piece you place touching the blank connects (legal) but only fires itself and whatever it directly links to. Report anything that contradicts this.
- In `show`, a cell marked `!` means that placement links into a creature Hurt piece, which will fire and hurt you.
- `start` prints where both start pieces went. Output also prints EXPIRED, RESHUFFLE and CHAIN STOPPED notes.
- Playstyles: greedy = highest-value piece that moves a bar that exists (never Charm against a boss: bosses have no charm bar); random = pick each choice with `$((RANDOM % N))` over the legal moves, not by habit; careful = guard/heal first, avoid `!` cells; chain = longest chain/combos; charm = pursue the charm bar (against a boss use damage and say so).
- The assignment's `level` field is the LEVEL argument; `creature_level` is information only; `offset` says how far under (or at) the creature's level you are.
- Extra fields in your JSON report: `start_felt` (did the opening choice matter, and was it clear), `set_aside_wanted` (did you want to set pieces aside in the opening: yes/no), `fair_1_to_5` (did the result feel earned).
