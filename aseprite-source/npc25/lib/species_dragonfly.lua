-- dragonfly (flyer) tables from specs/dragonfly.md. Opus: replace S.draw_figure only (body-plan helper: D.flyer).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "dragonfly", feet_y = 71, outline = "#2b1c26", plan = "flyer", T = 8, W = 46}
S.ramps = {main = {"#4fb35a", "#2f7f5a", "#2a6a4c", "#2f6a92"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#4fb35a", "#2f7f5a", "#2a6a4c", "#2f6a92", "#3a9fbf", "#d6ead8", "#a2c6c2", "#c96e3c", "#e2b552", "#f4f6e2"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, 0, 2, 2}, {-1, -1, 0, -1, 1, 1}, {-2, -2, 0, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {0, 0, 0, -1, 2, 2}, {-1, -1, 0, 0, 1, 1}}
local h = N.hex
S.c = {
  body = h"#2f7f5a",
  bshade = h"#2a6a4c",
  bhi = h"#4fb35a",
  deep = h"#2f6a92",
  head = h"#2f7f5a",
  hat = h"#c96e3c",
  hatshade = h"#e2b552",
  wing = h"#d6ead8",
  belly = h"#3a9fbf",
  acc = h"#3a9fbf",
  accs = h"#2f6a92",
  eye = h"#3a9fbf",
  q = h"#e2b552",
  qshade = h"#f4f6e2",
  qhi = h"#e2b552",
  ink = h"#2f6a92", arm = h"#2f7f5a", fbase = h"#2a6a4c", fshade = h"#2f6a92"}
S.bw, S.top = 16, 9
S.quirk = {w = 3, h = 3, anchor = "chest", hex = "#e2b552"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.flyer(img, view, frame, species)
end
return S
