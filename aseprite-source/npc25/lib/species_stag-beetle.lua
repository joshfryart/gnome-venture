-- stag-beetle (six-legged) tables from specs/stag-beetle.md. Opus: replace S.draw_figure only (body-plan helper: D.sixleg).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "stag-beetle", feet_y = 71, outline = "#2b1c26", plan = "sixleg", T = 8, W = 40}
S.ramps = {main = {"#9a5f36", "#9a5f36", "#64394a", "#3d2438"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#9a5f36", "#64394a", "#3d2438", "#7cc35a", "#3f9150", "#e8493b", "#b52e3f", "#aaa9b8", "#fff4d6", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 1, -1}, {-1, -1, -1, -1, 0, 0}, {-1, -1, -2, 0, -1, 1}, {0, 0, -1, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {-1, -1, 0, 0, 1, -1}}
local h = N.hex
S.c = {
  body = h"#9a5f36",
  bshade = h"#64394a",
  bhi = h"#9a5f36",
  deep = h"#3d2438",
  head = h"#9a5f36",
  hat = h"#7cc35a",
  hatshade = h"#3f9150",
  wing = h"#64394a",
  belly = h"#fff4d6",
  acc = h"#7cc35a",
  accs = h"#3f9150",
  eye = h"#fff4d6",
  q = h"#e8493b",
  qshade = h"#b52e3f",
  qhi = h"#aaa9b8",
  ink = h"#3d2438", arm = h"#9a5f36", fbase = h"#64394a", fshade = h"#3d2438"}
S.bw, S.top = 22, 9
S.quirk = {w = 3, h = 4, anchor = "hand", hex = "#e8493b"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.sixleg(img, view, frame, species)
end
return S
