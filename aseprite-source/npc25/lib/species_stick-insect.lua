-- stick-insect (six-legged) tables from specs/stick-insect.md. Opus: replace S.draw_figure only (body-plan helper: D.sixleg).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "stick-insect", feet_y = 71, outline = "#2b1c26", plan = "sixleg", T = 7, W = 34}
S.ramps = {main = {"#a88ae0", "#7f5cc4", "#5c4196", "#3f2c6a"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#a88ae0", "#7f5cc4", "#5c4196", "#3f2c6a", "#9a6e48", "#d9668a", "#a8496e", "#6e4a44", "#7cc35a", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 1, -1}, {-1, -1, -1, -1, 0, 0}, {-1, -1, -2, 0, -1, 1}, {0, 0, -1, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {-1, -1, 0, 0, 1, -1}}
local h = N.hex
S.c = {
  body = h"#7f5cc4",
  bshade = h"#5c4196",
  bhi = h"#a88ae0",
  deep = h"#3f2c6a",
  head = h"#7f5cc4",
  hat = h"#9a6e48",
  hatshade = h"#9a6e48",
  wing = h"#5c4196",
  belly = h"#9a6e48",
  acc = h"#9a6e48",
  accs = h"#9a6e48",
  eye = h"#9a6e48",
  q = h"#6e4a44",
  qshade = h"#7cc35a",
  qhi = h"#6e4a44",
  ink = h"#3f2c6a", arm = h"#7f5cc4", fbase = h"#5c4196", fshade = h"#3f2c6a"}
S.bw, S.top = 20, 8
S.quirk = {w = 5, h = 3, anchor = "crown", hex = "#6e4a44"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.sixleg(img, view, frame, species)
end
return S
