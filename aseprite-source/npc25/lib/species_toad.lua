-- toad (hopper) tables from specs/toad.md. Opus: replace S.draw_figure only (body-plan helper: D.hopper).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "toad", feet_y = 71, outline = "#2b1c26", plan = "hopper", T = 9, W = 38}
S.ramps = {main = {"#a3b85a", "#7f9a40", "#566e44", "#383c4e"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#a3b85a", "#7f9a40", "#566e44", "#383c4e", "#6c8aba", "#4c5a8c", "#34365e", "#deb658", "#a87e44", "#c45230", "#dcc47c", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{1, 1, 0, 0, -1, -1}, {-2, -2, -2, -2, 1, 1}, {-3, -3, -3, -3, 2, 2}, {-1, -1, -1, -1, 1, 1}, {0, 0, 0, 0, -2, -2}, {0, -1, 0, 0, -1, -1}}
local h = N.hex
S.c = {
  body = h"#7f9a40",
  bshade = h"#566e44",
  bhi = h"#a3b85a",
  deep = h"#383c4e",
  head = h"#7f9a40",
  hat = h"#deb658",
  hatshade = h"#a87e44",
  wing = h"#566e44",
  belly = h"#c45230",
  acc = h"#6c8aba",
  accs = h"#4c5a8c",
  eye = h"#c45230",
  q = h"#566e44",
  qshade = h"#7f9a40",
  qhi = h"#a87e44",
  ink = h"#383c4e", arm = h"#7f9a40", fbase = h"#566e44", fshade = h"#383c4e"}
S.bw, S.top = 20, 10
S.quirk = {w = 5, h = 3, anchor = "crown", hex = "#566e44"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.hopper(img, view, frame, species)
end
return S
