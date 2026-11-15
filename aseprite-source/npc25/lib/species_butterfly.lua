-- butterfly (flyer) tables from specs/butterfly.md. Opus: replace S.draw_figure only (body-plan helper: D.flyer).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "butterfly", feet_y = 71, outline = "#2b1c26", plan = "flyer", T = 8, W = 42}
S.ramps = {main = {"#bb8a5c", "#94684f", "#664654", "#432f45"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#bb8a5c", "#94684f", "#664654", "#432f45", "#4a3352", "#2f5250", "#f7c843", "#72b24e", "#e9c274", "#f5809f", "#c94f84"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, 0, 2, 2}, {-1, -1, 0, -1, 1, 1}, {-2, -2, 0, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {0, 0, 0, -1, 2, 2}, {-1, -1, 0, 0, 1, 1}}
local h = N.hex
S.c = {
  body = h"#94684f",
  bshade = h"#664654",
  bhi = h"#bb8a5c",
  deep = h"#432f45",
  head = h"#94684f",
  hat = h"#e9c274",
  hatshade = h"#f7c843",
  wing = h"#4a3352",
  belly = h"#f7c843",
  acc = h"#bb8a5c",
  accs = h"#bb8a5c",
  eye = h"#f7c843",
  q = h"#f5809f",
  qshade = h"#c94f84",
  qhi = h"#f5809f",
  ink = h"#432f45", arm = h"#94684f", fbase = h"#664654", fshade = h"#432f45"}
S.bw, S.top = 16, 9
S.quirk = {w = 4, h = 3, anchor = "neck", hex = "#f5809f"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.flyer(img, view, frame, species)
end
return S
