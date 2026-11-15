-- shrew (biped (mammal)) tables from specs/shrew.md. Opus: replace S.draw_figure only (body-plan helper: D.draw).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "shrew", feet_y = 71, outline = "#2b1c26", plan = "draw", T = 9, W = 42}
S.ramps = {main = {"#a8826a", "#8c6852", "#6e5040", "#3f2d3d"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#a8826a", "#8c6852", "#6e5040", "#3f2d3d", "#82a45a", "#567858", "#38524a", "#dbb65c", "#aa824c", "#e2908e", "#f2dcba"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 2, -2}, {-1, -1, 0, -1, 1, -1}, {-1, -1, -1, 0, 0, 0}, {0, 0, -2, 0, -2, 2}, {-1, -1, -1, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}}
local h = N.hex
S.c = {
  body = h"#8c6852",
  bshade = h"#6e5040",
  bhi = h"#a8826a",
  deep = h"#3f2d3d",
  head = h"#8c6852",
  hat = h"#dbb65c",
  hatshade = h"#aa824c",
  wing = h"#6e5040",
  belly = h"#82a45a",
  acc = h"#82a45a",
  accs = h"#567858",
  eye = h"#82a45a",
  q = h"#dbb65c",
  qshade = h"#e2908e",
  qhi = h"#f2dcba",
  ink = h"#3f2d3d", arm = h"#8c6852", fbase = h"#6e5040", fshade = h"#3f2d3d"}
S.bw, S.top = 28, 10
S.quirk = {w = 2, h = 6, y = 14, x = {front = 39, back = 22, side = 30}, anchor = "ear", hex = "#dbb65c"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.draw(img, view, frame, species)
end
return S
