-- wood-mouse (biped (mammal)) tables from specs/wood-mouse.md. Opus: replace S.draw_figure only (body-plan helper: D.draw).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "wood-mouse", feet_y = 71, outline = "#2b1c26", plan = "draw", T = 9, W = 40}
S.ramps = {main = {"#d88a50", "#b8743c", "#8a4f34", "#5e3a2c"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#d88a50", "#b8743c", "#8a4f34", "#5e3a2c", "#6aa848", "#3f7a4a", "#2c4f48", "#b08848", "#e8968e", "#ecd6b0"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 2, -2}, {-1, -1, 0, -1, 1, -1}, {-1, -1, -1, 0, 0, 0}, {0, 0, -2, 0, -2, 2}, {-1, -1, -1, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}}
local h = N.hex
S.c = {
  body = h"#b8743c",
  bshade = h"#8a4f34",
  bhi = h"#d88a50",
  deep = h"#5e3a2c",
  head = h"#b8743c",
  hat = h"#b08848",
  hatshade = h"#8a4f34",
  wing = h"#8a4f34",
  belly = h"#e8968e",
  acc = h"#6aa848",
  accs = h"#3f7a4a",
  eye = h"#e8968e",
  q = h"#b08848",
  qshade = h"#b08848",
  qhi = h"#b08848",
  ink = h"#5e3a2c", arm = h"#b8743c", fbase = h"#8a4f34", fshade = h"#5e3a2c"}
S.bw, S.top = 28, 10
S.quirk = {w = 4, h = 3, y = 11, x = {front = 30, back = 30, side = 33}, anchor = "crown", hex = "#b08848"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.draw(img, view, frame, species)
end
return S
