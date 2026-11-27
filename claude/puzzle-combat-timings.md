# Puzzle combat: every animation time and wait, in seconds (2.8.80)

Source: `tools/pfboardv1_part.js` (+ `tools/build_pfboardv1.py`) -> `game/assets/pfboardv1.js`; `game/assets/pfv1.css`, `pfight.css`, `pfanim.js`, `pfstage.js/css`.
Speed button: 1x, 1.25x, 2x, Skip (`SPD` = 1 / 1.25 / 2 / 0).

## 1. Replay after End turn (set for 1x; 2x keeps the old numbers; 1.25x = the 1x time / 1.25)
Code: `T1(ms at 1x, ms at 2x)` in `tools/pfboardv1_part.js`. RF = squeeze factor (1 when the replay is short): it shrinks piece steps so a whole replay never passes the cap.
| what | 1x | 1.25x | 2x |
|---|---|---|---|
| wait before the first step (same at every speed) | 0.13 | 0.13 | 0.13 |
| one piece step (place + fire + its line, bars move) | 1.35 x RF | 1.08 | 0.95 |
| creature turn banner: wait added before its pieces | 1.15 | 0.92 | 0.70 |
| creature banner on screen (CSS pf-turn, 0.05 s less than the hold) | 1.10 | 0.87 | 0.65 |
| use-up step (chain of 3+: fired pieces leave), step length | 1.35 x RF | 1.08 | 0.85 |
| ... pieces fade away inside it | 1.27 x RF | 1.02 | 0.80 |
| board puts a piece out for the creature (last step) | 1.35 x RF | 1.08 | 0.95 |
| expired pieces leave after the replay | 1.35 x RF | 1.08 | 0.80 |
| replay cap (all steps; the banner wait and first wait count as fixed) | 16.92 | 13.54 | 8.46 |
| "Your turn" banner, taps ignored while it shows (pf-turnhold) | 2.35 | 1.88 | 1.45 |
| ... its CSS animation | 2.30 | 1.83 | 1.40 |
Skip: no replay, no banner.
Measured, one medium-board turn from End turn to the last step: 6.7 s at 1x, 5.4 s at 1.25x, 4.7 s at 2x.

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
