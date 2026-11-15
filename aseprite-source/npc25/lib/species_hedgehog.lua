-- hedgehog tables from specs/hedgehog.md. Opus: replace draw_figure only.
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "hedgehog", feet_y = 71, outline = "#2b1c26"}
S.ramps = {  -- hi, base, shade, deep
  fur = {"#d89a5c", "#8f5f3a", "#5e3a35", "#3d2532"},
  skin = {"#f0d8a8", "#e0b986", "#b38469", "#7d5763"},
  hat = {"#ffe38a", "#e0b453", "#d89a5c"}, band = "#6188bc",
  vest = {"#6a9a48", "#46704a", "#2f4a42"},
  lantern = {gold = "#f5b82e", hi = "#ffe38a", metal = "#aaa9b8", flame = "#fff4d6"},
}
S.palette_list = {"#2b1c26", "#d89a5c", "#8f5f3a", "#5e3a35", "#3d2532", "#f0d8a8", "#e0b986", "#b38469",
  "#7d5763", "#ffe38a", "#e0b453", "#6188bc", "#6a9a48", "#46704a", "#2f4a42", "#f5b82e", "#aaa9b8", "#fff4d6"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 2, -2}, {-1, -1, 0, -1, 1, -1}, {-1, -1, -1, 0, 0, 0},
          {0, 0, -2, 0, -2, 2}, {-1, -1, -1, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}}
local h = N.hex
S.c = {body = h"#8f5f3a", bshade = h"#5e3a35", bhi = h"#d89a5c", belly = h"#e0b986", arm = h"#e0b986",
  head = h"#e0b986", hat = h"#e0b453", ink = h"#3d2532", fbase = h"#e0b986", fshade = h"#b38469",
  q = h"#f5b82e", qhi = h"#fff4d6"}
S.bw, S.top = 28, 10
S.quirk = {w = 3, h = 3, y = 52, x = {front = 44, back = 17, side = 38}}

-- Stage 3 (Opus) fills this in: draw one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  D.draw(img, view, frame, species)
end
return S
