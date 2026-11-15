-- wren (flyer) tables from specs/wren.md. Opus: replace S.draw_figure only (body-plan helper: D.flyer).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "wren", feet_y = 71, outline = "#2b1c26", plan = "flyer", T = 9, W = 40}
S.ramps = {main = {"#c88050", "#b06a3a", "#7a4438", "#4e2c3a"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#c88050", "#b06a3a", "#7a4438", "#4e2c3a", "#e2b97e", "#cfb699", "#e0b052", "#a87a48", "#2c4848"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, 0, 2, 2}, {-1, -1, 0, -1, 1, 1}, {-2, -2, 0, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {0, 0, 0, -1, 2, 2}, {-1, -1, 0, 0, 1, 1}}
local h = N.hex
S.c = {
  body = h"#b06a3a",
  bshade = h"#7a4438",
  bhi = h"#c88050",
  deep = h"#4e2c3a",
  head = h"#b06a3a",
  hat = h"#e2b97e",
  hatshade = h"#cfb699",
  wing = h"#7a4438",
  belly = h"#e2b97e",
  acc = h"#2c4848",
  accs = h"#2c4848",
  eye = h"#e2b97e",
  q = h"#e2b97e",
  qshade = h"#b06a3a",
  qhi = h"#e2b97e",
  ink = h"#4e2c3a", arm = h"#b06a3a", fbase = h"#7a4438", fshade = h"#4e2c3a"}
S.bw, S.top = 16, 10
S.quirk = {w = 3, h = 3, anchor = "chest", hex = "#e2b97e"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.flyer(img, view, frame, species)
end
return S
