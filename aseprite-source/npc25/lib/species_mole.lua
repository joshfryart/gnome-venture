-- mole (biped (mammal)) tables from specs/mole.md. Opus: replace S.draw_figure only (body-plan helper: D.draw).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "mole", feet_y = 71, outline = "#2b1c26", plan = "draw", T = 9, W = 40}
S.ramps = {main = {"#8a7184", "#6b5462", "#4c3a4f", "#33283a"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#8a7184", "#6b5462", "#4c3a4f", "#33283a", "#7fae5a", "#4f7f4a", "#33533f", "#e9bf5c", "#b98a3e", "#f2949a", "#fff4d6"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 2, -2}, {-1, -1, 0, -1, 1, -1}, {-1, -1, -1, 0, 0, 0}, {0, 0, -2, 0, -2, 2}, {-1, -1, -1, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}}
local h = N.hex
S.c = {
  body = h"#6b5462",
  bshade = h"#4c3a4f",
  bhi = h"#8a7184",
  deep = h"#33283a",
  head = h"#6b5462",
  hat = h"#e9bf5c",
  hatshade = h"#b98a3e",
  wing = h"#4c3a4f",
  belly = h"#7fae5a",
  acc = h"#7fae5a",
  accs = h"#4f7f4a",
  eye = h"#7fae5a",
  q = h"#e9bf5c",
  qshade = h"#fff4d6",
  qhi = h"#e9bf5c",
  ink = h"#33283a", arm = h"#6b5462", fbase = h"#4c3a4f", fshade = h"#33283a"}
S.bw, S.top = 28, 10
S.quirk = {w = 3, h = 3, y = 11, x = {front = 31, back = 31, side = 34}, anchor = "crown", hex = "#e9bf5c"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.draw(img, view, frame, species)
end
return S
