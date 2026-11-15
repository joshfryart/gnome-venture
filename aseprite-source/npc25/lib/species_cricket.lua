-- cricket (hopper) tables from specs/cricket.md. Opus: replace S.draw_figure only (body-plan helper: D.hopper).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "cricket", feet_y = 71, outline = "#2b1c26", plan = "hopper", T = 7, W = 40}
S.ramps = {main = {"#e8a868", "#b8682f", "#7d3f33", "#4a2633"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#e8a868", "#b8682f", "#7d3f33", "#4a2633", "#5f9b45", "#3d6749", "#29404a", "#e3bb5e", "#a9824c", "#eadcb8", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{1, 1, 0, 0, -1, -1}, {-2, -2, -2, -2, 1, 1}, {-3, -3, -3, -3, 2, 2}, {-1, -1, -1, -1, 1, 1}, {0, 0, 0, 0, -2, -2}, {0, -1, 0, 0, -1, -1}}
local h = N.hex
S.c = {
  body = h"#b8682f",
  bshade = h"#7d3f33",
  bhi = h"#e8a868",
  deep = h"#4a2633",
  head = h"#b8682f",
  hat = h"#e3bb5e",
  hatshade = h"#a9824c",
  wing = h"#5f9b45",
  belly = h"#e8a868",
  acc = h"#e8a868",
  accs = h"#e8a868",
  eye = h"#e8a868",
  q = h"#a9824c",
  qshade = h"#eadcb8",
  qhi = h"#a9824c",
  ink = h"#4a2633", arm = h"#b8682f", fbase = h"#7d3f33", fshade = h"#4a2633"}
S.bw, S.top = 20, 8
S.quirk = {w = 2, h = 6, anchor = "hand", hex = "#a9824c"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.hopper(img, view, frame, species)
end
return S
