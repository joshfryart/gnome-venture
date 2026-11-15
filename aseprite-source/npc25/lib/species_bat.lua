-- bat (flyer) tables from specs/bat.md. Opus: replace S.draw_figure only (body-plan helper: D.flyer).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "bat", feet_y = 71, outline = "#2b1c26", plan = "flyer", T = 7, W = 44}
S.ramps = {main = {"#c9b2f0", "#8a6fd0", "#5a459e", "#35295f"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#c9b2f0", "#8a6fd0", "#5a459e", "#35295f", "#f5b82e", "#d98322", "#f5809f", "#8f4a1f", "#aaa9b8"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, 0, 2, 2}, {-1, -1, 0, -1, 1, 1}, {-2, -2, 0, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {0, 0, 0, -1, 2, 2}, {-1, -1, 0, 0, 1, 1}}
local h = N.hex
S.c = {
  body = h"#8a6fd0",
  bshade = h"#5a459e",
  bhi = h"#c9b2f0",
  deep = h"#35295f",
  head = h"#8a6fd0",
  hat = h"#f5b82e",
  hatshade = h"#d98322",
  wing = h"#c9b2f0",
  belly = h"#f5b82e",
  acc = h"#f5b82e",
  accs = h"#d98322",
  eye = h"#f5b82e",
  q = h"#d98322",
  qshade = h"#8f4a1f",
  qhi = h"#aaa9b8",
  ink = h"#35295f", arm = h"#8a6fd0", fbase = h"#5a459e", fshade = h"#35295f"}
S.bw, S.top = 16, 8
S.quirk = {w = 5, h = 4, anchor = "hand", hex = "#d98322"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.flyer(img, view, frame, species)
end
return S
