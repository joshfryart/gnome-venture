-- dormouse (biped (mammal)) tables from specs/dormouse.md. Opus: replace S.draw_figure only (body-plan helper: D.draw).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "dormouse", feet_y = 71, outline = "#2b1c26", plan = "draw", T = 9, W = 38}
S.ramps = {main = {"#c98a5c", "#b97a4a", "#864c33", "#51302b"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#c98a5c", "#b97a4a", "#864c33", "#51302b", "#f5b82e", "#d98322", "#f3e2bf", "#f5809f", "#c94f84", "#7d2c5e"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 2, -2}, {-1, -1, 0, -1, 1, -1}, {-1, -1, -1, 0, 0, 0}, {0, 0, -2, 0, -2, 2}, {-1, -1, -1, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}}
local h = N.hex
S.c = {
  body = h"#b97a4a",
  bshade = h"#864c33",
  bhi = h"#c98a5c",
  deep = h"#51302b",
  head = h"#b97a4a",
  hat = h"#f5809f",
  hatshade = h"#c94f84",
  wing = h"#864c33",
  belly = h"#f3e2bf",
  acc = h"#f5b82e",
  accs = h"#d98322",
  eye = h"#f3e2bf",
  q = h"#c94f84",
  qshade = h"#7d2c5e",
  qhi = h"#f3e2bf",
  ink = h"#51302b", arm = h"#b97a4a", fbase = h"#864c33", fshade = h"#51302b"}
S.bw, S.top = 28, 10
S.quirk = {w = 4, h = 4, y = 11, x = {front = 30, back = 30, side = 33}, anchor = "crown", hex = "#c94f84"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.draw(img, view, frame, species)
end
return S
