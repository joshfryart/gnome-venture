-- beetle (six-legged) tables from specs/beetle.md. Opus: replace S.draw_figure only (body-plan helper: D.sixleg).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "beetle", feet_y = 71, outline = "#2b1c26", plan = "sixleg", T = 8, W = 36}
S.ramps = {main = {"#4fae5a", "#4e7a5c", "#36564f", "#2c3646"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#4fae5a", "#4e7a5c", "#36564f", "#2c3646", "#e2b654", "#cfc278", "#e0584e", "#a83a4e", "#b07c44", "#655c56", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 1, -1}, {-1, -1, -1, -1, 0, 0}, {-1, -1, -2, 0, -1, 1}, {0, 0, -1, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {-1, -1, 0, 0, 1, -1}}
local h = N.hex
S.c = {
  body = h"#4e7a5c",
  bshade = h"#36564f",
  bhi = h"#4fae5a",
  deep = h"#2c3646",
  head = h"#4e7a5c",
  hat = h"#e2b654",
  hatshade = h"#cfc278",
  wing = h"#36564f",
  belly = h"#b07c44",
  acc = h"#e0584e",
  accs = h"#a83a4e",
  eye = h"#b07c44",
  q = h"#b07c44",
  qshade = h"#e0584e",
  qhi = h"#b07c44",
  ink = h"#2c3646", arm = h"#4e7a5c", fbase = h"#36564f", fshade = h"#2c3646"}
S.bw, S.top = 22, 9
S.quirk = {w = 4, h = 3, anchor = "back", hex = "#b07c44"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.sixleg(img, view, frame, species)
end
return S
