# Piece strength audit (2.7.07, generated from `data/pf_pieces.txt` with `pfd_catalog()`)

## The base kit as one unit
Base kit everyone has: `PFD_CORE` (swing, dodge, rest, charm) + `PFD_STARTER_FIXED` (jab, swing#2, pierce, snack, brace, soothe).
Printed values (before stat / level / rank): hurt 4, 4, jab 2 (now 3), pierce 3; guard dodge 4, brace 3; heal 3; charm 4; item 5; soothe 2.

## The curve (proposed and applied to the starter)
- **Type base at Common (rank 1):** hurt 4, guard 4, heal 3, charm 4, item 5, trick 3, soothe 2.
- **A tag costs value:** none 0, Quick/Pierce/Hold 1 (Jab 3, Pierce 3, Brace 3), Poison/Trip/Bash/Evade/Mend/Thorns 2, Heavy gives +2 (Smash 6).
- **Rank bonus (`PFD_RANK_BONUS`) 0 / 0 / +2 / +4 / +5** for none / Common / Uncommon / Rare / Masterwork. The MW step is +1, the others +2: left alone (Josh to say if MW should be +6).
- **Starter retune (Josh: "retune evenly"):** only Jab was off the curve: **Jab 2 -> 3** (PHP catalogue, `PF_TILES_BUILTIN`, `tools/pfengine.js`). Swing, Dodge, Rest, Charm, Snack, Brace, Pierce, Soothe already sit on it.

## Outliers flagged (not changed)
- Calling pieces are +2 to +4 over the type base by design: thorn 7 (hurt), bark 6 (guard), brew 6 (heal), bloom 8 (charm), sow / wayfind 5 (trick).
- Knacks with a 2 on a poison / trip / bash tag are on the curve; **Smash 6** is Heavy (+2).
- Legend (`g:`) pieces carry their crop's rank: hurt runs 4-7, guard 3-6, heal 3-6, charm 5-6; the spread inside one type is wider than the rank bonus explains (Macadamia hurt 7 against Clove 4). Candidates to flatten.
- Tool / craft hurt pieces run 2-5 for one rank (Plant and Net 2 Quick / Trip, Broadfork and Tree 5 Heavy): inside the tag costs above.
- No `Boon` tag on pal pieces, 18 tool types for 19 slots, calling tier III second pieces: still open.
