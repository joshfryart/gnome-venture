-- bumblebee (flyer) tables from specs/bumblebee.md. Opus: replace S.draw_figure only (body-plan helper: D.flyer).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "bumblebee", feet_y = 71, outline = "#2b1c26", plan = "flyer", T = 8, W = 40}
S.ramps = {main = {"#e8c46a", "#f5b83a", "#c97d3a", "#b88848"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#e8c46a", "#f5b83a", "#c97d3a", "#b88848", "#40325a", "#30264a", "#261d3c", "#76b24e", "#477e52", "#2f5248", "#cfe4ee", "#9fb6d8"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, 0, 2, 2}, {-1, -1, 0, -1, 1, 1}, {-2, -2, 0, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {0, 0, 0, -1, 2, 2}, {-1, -1, 0, 0, 1, 1}}
local h = N.hex
S.c = {
  body = h"#f5b83a",
  bshade = h"#c97d3a",
  bhi = h"#e8c46a",
  deep = h"#b88848",
  head = h"#f5b83a",
  hat = h"#40325a",
  hatshade = h"#30264a",
  wing = h"#cfe4ee",
  belly = h"#40325a",
  acc = h"#40325a",
  accs = h"#30264a",
  eye = h"#40325a",
  q = h"#f5b83a",
  qshade = h"#c97d3a",
  qhi = h"#f5b83a",
  ink = h"#b88848", arm = h"#f5b83a", fbase = h"#c97d3a", fshade = h"#b88848"}
S.bw, S.top = 16, 9
S.quirk = {w = 4, h = 4, anchor = "hand", hex = "#f5b83a"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.flyer(img, view, frame, species)
end
return S
