-- field-mouse (biped (mammal)) tables from specs/field-mouse.md. Opus: replace S.draw_figure only (body-plan helper: D.draw).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "field-mouse", feet_y = 71, outline = "#2b1c26", plan = "draw", T = 9, W = 40}
S.ramps = {main = {"#e0a46c", "#cf9450", "#946048", "#705446"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#e0a46c", "#cf9450", "#946048", "#705446", "#78b04c", "#4a7c4c", "#2e4e46", "#e8c262", "#b48a4c", "#e8a898", "#f2dcba"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 2, -2}, {-1, -1, 0, -1, 1, -1}, {-1, -1, -1, 0, 0, 0}, {0, 0, -2, 0, -2, 2}, {-1, -1, -1, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}}
local h = N.hex
S.c = {
  body = h"#cf9450",
  bshade = h"#946048",
  bhi = h"#e0a46c",
  deep = h"#705446",
  head = h"#cf9450",
  hat = h"#e8c262",
  hatshade = h"#b48a4c",
  wing = h"#946048",
  belly = h"#e8a898",
  acc = h"#78b04c",
  accs = h"#4a7c4c",
  eye = h"#e8a898",
  q = h"#b48a4c",
  qshade = h"#e8c262",
  qhi = h"#b48a4c",
  ink = h"#705446", arm = h"#cf9450", fbase = h"#946048", fshade = h"#705446"}
S.bw, S.top = 28, 10
S.quirk = {w = 1, h = 6, y = 56, x = {front = 48, back = 13, side = 36}, anchor = "hand", hex = "#b48a4c"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.draw(img, view, frame, species)
end
return S
