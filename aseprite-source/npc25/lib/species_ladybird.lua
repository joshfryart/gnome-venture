-- ladybird (six-legged) tables from specs/ladybird.md. Opus: replace S.draw_figure only (body-plan helper: D.sixleg).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "ladybird", feet_y = 71, outline = "#2b1c26", plan = "sixleg", T = 9, W = 40}
S.ramps = {main = {"#e8584a", "#d93a30", "#a52638", "#7a2030"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#e8584a", "#d93a30", "#a52638", "#7a2030", "#4f4164", "#3d3150", "#3a2c48", "#f0cc6a", "#c99a48", "#6aa84a", "#f4e2bc", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 1, -1}, {-1, -1, -1, -1, 0, 0}, {-1, -1, -2, 0, -1, 1}, {0, 0, -1, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {-1, -1, 0, 0, 1, -1}}
local h = N.hex
S.c = {
  body = h"#d93a30",
  bshade = h"#a52638",
  bhi = h"#e8584a",
  deep = h"#7a2030",
  head = h"#4f4164",
  hat = h"#f0cc6a",
  hatshade = h"#c99a48",
  wing = h"#e8584a",
  belly = h"#3d3150",
  acc = h"#4f4164",
  accs = h"#3d3150",
  eye = h"#3d3150",
  q = h"#d93a30",
  qshade = h"#3d3150",
  qhi = h"#d93a30",
  ink = h"#7a2030", arm = h"#d93a30", fbase = h"#a52638", fshade = h"#7a2030"}
S.bw, S.top = 22, 10
S.quirk = {w = 3, h = 4, anchor = "hand", hex = "#d93a30"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.sixleg(img, view, frame, species)
end
return S
