-- firefly (flyer) tables from specs/firefly.md. Opus: replace S.draw_figure only (body-plan helper: D.flyer).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "firefly", feet_y = 71, outline = "#2b1c26", plan = "flyer", T = 8, W = 36}
S.ramps = {main = {"#6c5c7c", "#4d405e", "#3b3049", "#30263c"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#6c5c7c", "#4d405e", "#3b3049", "#30263c", "#f08a4c", "#c45c4a", "#dcb98c", "#c3944f", "#56644f", "#f4c24a", "#f0dcb4"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, 0, 2, 2}, {-1, -1, 0, -1, 1, 1}, {-2, -2, 0, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {0, 0, 0, -1, 2, 2}, {-1, -1, 0, 0, 1, 1}}
local h = N.hex
S.c = {
  body = h"#4d405e",
  bshade = h"#3b3049",
  bhi = h"#6c5c7c",
  deep = h"#30263c",
  head = h"#4d405e",
  hat = h"#f08a4c",
  hatshade = h"#c45c4a",
  wing = h"#3b3049",
  belly = h"#dcb98c",
  acc = h"#dcb98c",
  accs = h"#c3944f",
  eye = h"#dcb98c",
  q = h"#f4c24a",
  qshade = h"#f0dcb4",
  qhi = h"#f4c24a",
  ink = h"#30263c", arm = h"#4d405e", fbase = h"#3b3049", fshade = h"#30263c"}
S.bw, S.top = 16, 9
S.quirk = {w = 3, h = 4, anchor = "chest", hex = "#f4c24a"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.flyer(img, view, frame, species)
end
return S
