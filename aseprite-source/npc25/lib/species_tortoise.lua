-- tortoise tables from specs/tortoise.md. Opus: replace draw_figure only.
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "tortoise", feet_y = 71, outline = "#2b1c26"}
S.ramps = {
  skin = {"#78b04e", "#93a666", "#667a52", "#434d4a"},
  shell = {"#b28c4e", "#c07d3c", "#8a5236", "#57343c"},
  hat = {"#e4c26c", "#dcbc72"}, band = "#78b04e", sprig = "#6a9a48",
  overalls = {"#6188bc", "#465c92", "#323c66"}, strap = "#dcbc72",
  pot = {"#d6693e", "#8a5236", "#57343c"}, sprout = "#78b04e", petal = "#f5809f",
}
S.palette_list = {"#2b1c26", "#78b04e", "#93a666", "#667a52", "#434d4a", "#b28c4e", "#c07d3c", "#8a5236",
  "#57343c", "#e4c26c", "#dcbc72", "#6a9a48", "#6188bc", "#465c92", "#323c66", "#d6693e", "#f5809f", "#fff4d6"}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 1, -1}, {-1, -1, 0, -1, 0, 0}, {-1, -1, -1, 0, -1, 1},
          {0, 0, -2, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}, {-1, -1, -1, 0, 1, -1}}
local h = N.hex
S.c = {body = h"#c07d3c", bshade = h"#8a5236", bhi = h"#b28c4e", belly = h"#6188bc", arm = h"#93a666",
  head = h"#93a666", hat = h"#dcbc72", ink = h"#2b1c26", fbase = h"#93a666", fshade = h"#667a52",
  q = h"#d6693e", qhi = h"#78b04e"}
S.bw, S.top = 32, 11
S.quirk = {w = 4, h = 3, y = 33, x = {front = 44, back = 30, side = 28}}

-- Stage 3 (Opus) fills this in. See hedgehog file for the contract.
function S.draw_figure(img, view, frame, species)
  D.draw(img, view, frame, species)
end
return S
