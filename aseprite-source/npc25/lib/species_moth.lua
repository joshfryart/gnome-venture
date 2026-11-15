-- moth (flyer) tables from specs/moth.md. Opus: replace S.draw_figure only (body-plan helper: D.flyer).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "moth", feet_y = 71, outline = "#2b1c26", plan = "flyer", T = 8, W = 42}
S.ramps = {main = {"#d6e3a2", "#bcd694", "#98d69a", "#62a894"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#d6e3a2", "#bcd694", "#98d69a", "#62a894", "#5c78ac", "#435488", "#2f3a62", "#e2b65e", "#b27e4a", "#ece6bc"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, 0, 2, 2}, {-1, -1, 0, -1, 1, 1}, {-2, -2, 0, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {0, 0, 0, -1, 2, 2}, {-1, -1, 0, 0, 1, 1}}
local h = N.hex
S.c = {
  body = h"#bcd694",
  bshade = h"#98d69a",
  bhi = h"#d6e3a2",
  deep = h"#62a894",
  head = h"#ece6bc",
  hat = h"#e2b65e",
  hatshade = h"#b27e4a",
  wing = h"#d6e3a2",
  belly = h"#5c78ac",
  acc = h"#5c78ac",
  accs = h"#435488",
  eye = h"#5c78ac",
  q = h"#ece6bc",
  qshade = h"#e2b65e",
  qhi = h"#ece6bc",
  ink = h"#62a894", arm = h"#bcd694", fbase = h"#98d69a", fshade = h"#62a894"}
S.bw, S.top = 16, 9
S.quirk = {w = 4, h = 3, anchor = "hand", hex = "#ece6bc"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.flyer(img, view, frame, species)
end
return S
