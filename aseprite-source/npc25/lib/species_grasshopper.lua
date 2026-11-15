-- grasshopper (hopper) tables from specs/grasshopper.md. Opus: replace S.draw_figure only (body-plan helper: D.hopper).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "grasshopper", feet_y = 71, outline = "#2b1c26", plan = "hopper", T = 7, W = 38}
S.ramps = {main = {"#9ad55c", "#78bf48", "#3f8a52", "#3a3e6e"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#9ad55c", "#78bf48", "#3f8a52", "#3a3e6e", "#6e8cc8", "#4e62a0", "#e4bc62", "#b98a48", "#c08a4a", "#7a5240", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{1, 1, 0, 0, -1, -1}, {-2, -2, -2, -2, 1, 1}, {-3, -3, -3, -3, 2, 2}, {-1, -1, -1, -1, 1, 1}, {0, 0, 0, 0, -2, -2}, {0, -1, 0, 0, -1, -1}}
local h = N.hex
S.c = {
  body = h"#78bf48",
  bshade = h"#3f8a52",
  bhi = h"#9ad55c",
  deep = h"#3a3e6e",
  head = h"#78bf48",
  hat = h"#e4bc62",
  hatshade = h"#b98a48",
  wing = h"#c08a4a",
  belly = h"#6e8cc8",
  acc = h"#6e8cc8",
  accs = h"#4e62a0",
  eye = h"#6e8cc8",
  q = h"#c08a4a",
  qshade = h"#7a5240",
  qhi = h"#c08a4a",
  ink = h"#3a3e6e", arm = h"#78bf48", fbase = h"#3f8a52", fshade = h"#3a3e6e"}
S.bw, S.top = 20, 8
S.quirk = {w = 4, h = 3, anchor = "chest", hex = "#c08a4a"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.hopper(img, view, frame, species)
end
return S
