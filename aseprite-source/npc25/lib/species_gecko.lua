-- gecko (biped (mammal)) tables from specs/gecko.md. Opus: replace S.draw_figure only (body-plan helper: D.draw).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "gecko", feet_y = 71, outline = "#2b1c26", plan = "draw", T = 9, W = 40}
S.ramps = {main = {"#ffcf8e", "#f29a52", "#b8604c", "#7c5e4e"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#ffcf8e", "#f29a52", "#b8604c", "#7c5e4e", "#e6c766", "#b48f56", "#5fae4c", "#3d7c4c", "#285450", "#f6ecd2", "#7a3a4c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 2, -2}, {-1, -1, 0, -1, 1, -1}, {-1, -1, -1, 0, 0, 0}, {0, 0, -2, 0, -2, 2}, {-1, -1, -1, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}}
local h = N.hex
S.c = {
  body = h"#f29a52",
  bshade = h"#b8604c",
  bhi = h"#ffcf8e",
  deep = h"#7c5e4e",
  head = h"#f29a52",
  hat = h"#e6c766",
  hatshade = h"#b48f56",
  wing = h"#b8604c",
  belly = h"#f6ecd2",
  acc = h"#5fae4c",
  accs = h"#3d7c4c",
  eye = h"#f6ecd2",
  q = h"#b8604c",
  qshade = h"#7a3a4c",
  qhi = h"#b8604c",
  ink = h"#7c5e4e", arm = h"#f29a52", fbase = h"#b8604c", fshade = h"#7c5e4e"}
S.bw, S.top = 28, 10
S.quirk = {w = 4, h = 2, y = 29, x = {front = 28, back = 28, side = 32}, anchor = "neck", hex = "#b8604c"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.draw(img, view, frame, species)
end
return S
