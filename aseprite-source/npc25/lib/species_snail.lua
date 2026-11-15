-- snail (crawler) tables from specs/snail.md. Opus: replace S.draw_figure only (body-plan helper: D.crawler).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "snail", feet_y = 71, outline = "#2b1c26", plan = "crawler", T = 8, W = 44}
S.ramps = {main = {"#d2cb94", "#a09e6e", "#726c60", "#4a4256"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#d2cb94", "#a09e6e", "#726c60", "#4a4256", "#d48e3e", "#9e5c3c", "#5e3446", "#dab65c", "#5ca24c", "#ecdab2", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, -1, 0, 0, 1, 0}, {1, 0, 0, 0, 0, 0}, {0, -1, 0, 0, -1, 0}, {1, 0, 0, 0, -1, 1}, {0, -1, 0, 0, 0, 0}, {1, 0, 0, 0, 0, 1}}
local h = N.hex
S.c = {
  body = h"#a09e6e",
  bshade = h"#726c60",
  bhi = h"#d2cb94",
  deep = h"#4a4256",
  head = h"#a09e6e",
  hat = h"#dab65c",
  hatshade = h"#5ca24c",
  wing = h"#726c60",
  belly = h"#d48e3e",
  acc = h"#d48e3e",
  accs = h"#9e5c3c",
  eye = h"#d48e3e",
  q = h"#9e5c3c",
  qshade = h"#5e3446",
  qhi = h"#ecdab2",
  ink = h"#4a4256", arm = h"#a09e6e", fbase = h"#726c60", fshade = h"#4a4256"}
S.bw, S.top = 20, 9
S.quirk = {w = 4, h = 4, anchor = "shell", hex = "#9e5c3c"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.crawler(img, view, frame, species)
end
return S
