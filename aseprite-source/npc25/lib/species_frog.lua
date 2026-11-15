-- frog (hopper) tables from specs/frog.md. Opus: replace S.draw_figure only (body-plan helper: D.hopper).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "frog", feet_y = 71, outline = "#2b1c26", plan = "hopper", T = 9, W = 36}
S.ramps = {main = {"#b6d861", "#6fae3e", "#3f7a4a", "#2f4a4c"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#b6d861", "#6fae3e", "#3f7a4a", "#2f4a4c", "#c2573c", "#8a3a46", "#5a2a3e", "#e6d38a", "#fff4d6", "#f5809f", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{1, 1, 0, 0, -1, -1}, {-2, -2, -2, -2, 1, 1}, {-3, -3, -3, -3, 2, 2}, {-1, -1, -1, -1, 1, 1}, {0, 0, 0, 0, -2, -2}, {0, -1, 0, 0, -1, -1}}
local h = N.hex
S.c = {
  body = h"#6fae3e",
  bshade = h"#3f7a4a",
  bhi = h"#b6d861",
  deep = h"#2f4a4c",
  head = h"#6fae3e",
  hat = h"#c2573c",
  hatshade = h"#8a3a46",
  wing = h"#3f7a4a",
  belly = h"#e6d38a",
  acc = h"#c2573c",
  accs = h"#8a3a46",
  eye = h"#e6d38a",
  q = h"#b6d861",
  qshade = h"#3f7a4a",
  qhi = h"#f5809f",
  ink = h"#2f4a4c", arm = h"#6fae3e", fbase = h"#3f7a4a", fshade = h"#2f4a4c"}
S.bw, S.top = 20, 10
S.quirk = {w = 5, h = 2, anchor = "crown", hex = "#b6d861"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.hopper(img, view, frame, species)
end
return S
