-- hare (hopper) tables from specs/hare.md. Opus: replace S.draw_figure only (body-plan helper: D.hopper).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "hare", feet_y = 71, outline = "#2b1c26", plan = "hopper", T = 7, W = 36}
S.ramps = {main = {"#e0b480", "#c99a62", "#946a58", "#76503e"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#e0b480", "#c99a62", "#946a58", "#76503e", "#6e9e5a", "#4a6e54", "#2f4448", "#e0b858", "#ae8044", "#e2929a", "#efdcb8", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{1, 1, 0, 0, -1, -1}, {-2, -2, -2, -2, 1, 1}, {-3, -3, -3, -3, 2, 2}, {-1, -1, -1, -1, 1, 1}, {0, 0, 0, 0, -2, -2}, {0, -1, 0, 0, -1, -1}}
local h = N.hex
S.c = {
  body = h"#c99a62",
  bshade = h"#946a58",
  bhi = h"#e0b480",
  deep = h"#76503e",
  head = h"#c99a62",
  hat = h"#e0b858",
  hatshade = h"#ae8044",
  wing = h"#946a58",
  belly = h"#e2929a",
  acc = h"#6e9e5a",
  accs = h"#4a6e54",
  eye = h"#e2929a",
  q = h"#ae8044",
  qshade = h"#76503e",
  qhi = h"#ae8044",
  ink = h"#76503e", arm = h"#c99a62", fbase = h"#946a58", fshade = h"#76503e"}
S.bw, S.top = 20, 8
S.quirk = {w = 1, h = 8, anchor = "hand", hex = "#ae8044"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.hopper(img, view, frame, species)
end
return S
