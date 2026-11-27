# Puzzle combat: every animation time and wait, in seconds (2.8.80)

Source: `tools/pfboardv1_part.js` (+ `tools/build_pfboardv1.py`) -> `game/assets/pfboardv1.js`; `game/assets/pfv1.css`, `pfight.css`, `pfanim.js`, `pfstage.js/css`.
Speed button: 1x, 1.25x, 2x, Skip. Code: `SLOW = 2` (1x is half the old speed), `SPD` = 1 / 1.25 / 2 / 0. A "scaled" time = base x `SLOW` / `SPD`, so the three columns below are x2, x1.6, x1.
RF = squeeze factor (1 when the replay is short). It shrinks piece steps so a whole replay never passes the cap.

## 1. Replay after End turn (scaled by speed)
| what | base | 1x | 1.25x | 2x |
|---|---|---|---|---|
| wait before the first step (NOT scaled) | 0.20 | 0.20 | 0.20 | 0.20 |
| one piece step (place + fire + its line, bars move) | 0.95 x RF | 1.90 | 1.52 | 0.95 |
| creature turn banner: wait added before its pieces | 0.70 | 1.40 | 1.12 | 0.70 |
| creature banner on screen (CSS pf-turn, 0.65 s less than hold) | 0.65 | 1.30 | 1.04 | 0.65 |
| use-up step (chain of 3+: fired pieces leave), step length | 0.85 x RF | 1.70 | 1.36 | 0.85 |
| ... pieces fade away inside it | 0.80 x RF | 1.60 | 1.28 | 0.80 |
| board puts a piece out for the creature (last step) | 0.95 x RF | 1.90 | 1.52 | 0.95 |
| expired pieces leave after the replay | 0.80 x RF | 1.60 | 1.28 | 0.80 |
| replay cap (whole replay, all steps) | 8.46 | 16.92 | 13.54 | 8.46 |
| "Your turn" banner, taps ignored while it shows (pf-turnhold) | 1.45 | 2.90 | 2.32 | 1.45 |
| ... its CSS animation | 1.40 | 2.80 | 2.24 | 1.40 |
Skip: no replay, no banner.

## 2. Fixed times (not changed by the speed button)
| what | seconds |
|---|---|
| piece place wiggle (pfanim): raise 0.18 + click 0.05 + wiggle 0.24 | 0.47 (heavy 0.50) |
| piece fire effects (pfanim): authored per effect, scaled by k = min(1, step / 0.95) | about 0.6 to 1.2 (stat effects 1.2) |
| scoring pulse on a firing piece (pfb-score) | 0.50 |
| history chip slides in (pf-chip-in) | 0.40 |
| struck piece (pfv-struck, JS also clears at 0.9) | 0.90 |
| environment flash on a cell (pfv-flash) | 0.50 |
| boss AOE flash (pfv-aoeflash 0.3 x 3) | 0.90 |
| environment piece comes in (pfv-envin) | 0.60 |
| environment piece slides (gust, pfv-sl) | 0.55 |
| environment piece fades (pfv-fades) / used up (pfv-used) / spawn (pfv-spawn) | 0.80 each |
| expired piece leaves (pfb-leave) | 0.75 |
| new environment strip piece highlight after the replay | 0.90 |
| flip animation (pfv-flip; JS clears the class at 0.45) | 0.40 (0.45) |
| bars fill / drain (yield, guard, creature) | 0.45 |
| placed piece drop (pfb-drop) | 0.40 |
| result card in (pfvresin) | 0.50 |
| plan line (what the planned piece would do): wait after you place | 0.18 |
| Quick turns (opt-in): End turn fires by itself after you place | 0.70 |
| bar hint bubble shows, then hides itself (appears 0.3 after) | 7.0 (1.0 in) |
| the aim marker pulse / env glow / ring (loops) | 1.4 / 1.1 / 1.6 |
| rewind chip tap: no animation | 0 |

## 3. Safety waits (only when something is slow)
| what | seconds |
|---|---|
| wait for the piece art before the replay starts, then play anyway | 4.0 |
| result card held back until the replay ends, at most | 40 |
| frozen copy of the old board kept over a new turn, at most | 8 |
| the "page changed" watcher stops looking | 15 |
| opening hint check (first turn) | 0.25 |

## 4. Jigsaw veil in and out (pfstage.js; all screen sizes, covers the whole window)
| what | seconds |
|---|---|
| wait for the dialog to be modal and a Trail walk to finish, at most | 3.5 |
| one piece flies in | 0.43 (desktop 0.43 to 0.58, grows with the window) |
| pieces start one after another: phone (column + row) x 0.042 (a 390 x 780 phone: about 0.6 in all); desktop spread over | 0.34 |
| the veil fades in | 0.30 |
| a piece flies out | 0.42 (desktop 0.42 to 0.57) |
| pieces leave one after another: phone (column + row) x 0.038; desktop spread over | 0.30 |
| the veil fades out (starts after 55 percent of the flight) | flight + 0.26 |
| pause after the board shows before the pieces leave (fight start) | 0.15 |
| card or board fades in under the pieces | 0.40 |
| Let's fight: second set of pieces in, then the board swap, then out | same as above |
| board never arrived after Let's fight: give up and show | 9.0 |
| End match cover: give up if the swap never comes | 6.0 |
| refit after a turn or resize of the phone | 0.15 |
