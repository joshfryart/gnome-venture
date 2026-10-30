-- ph/tomato-passata (Pantry sauce): fat round fiasco flask in a woven straw basket, red cap, tomato label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "tomato-passata"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local flask = c:ellipse(32, 39, 20, 17):add(c:rect(26, 12, 38, 24))
c:build{
  { "glass", flask, "glass" },
  { "fill",  c:ellipse(32, 39, 18, 15):add(c:rect(28, 17, 36, 26)), "#d6322b", { contour = "#7a1a14", gloss = { 18, 33 } } },
}
-- straw basket around the lower half, woven diagonals
local straw = c:ellipse(32, 39, 20, 17):clip(c:rect(0, 40, 63, 63)):add(c:rect(12, 39, 52, 41))
c:part(straw, "#c9a96e", { contour = "#7a4a1f", gloss = false })
local weave = c:mask()
for k = -40, 100, 4 do weave:add(c:line({ {k, 40}, {k + 18, 58} }, 1)) end
weave:clip(straw:shrink(1))
c:fill(weave, "#9a6b3f")
c:fill(c:rect(12, 41, 52, 41), "#9a6b3f")
c:fill(c:rect(13, 39, 51, 39), "#e8d8a8")
c:part(c:ellipse(32, 31, 10, 6), "cream", { gloss = false, contact = false })
-- emblem: tomato with a star calyx
c:paint({
  "..g.g.g..",
  "...ggg...",
  ".rrRrrrr.",
  "rrRrrrrrr",
  "rrrrrrrrs",
  ".rrrrrss.",
}, 28, 27, { r = "#d6322b", R = "#ff8a70", s = "#a8241f", g = "#4f9a45" })
c:part(c:rrect(25, 7, 39, 13, 2), "#a8241f")
c:seam({ {27, 13}, {37, 13} })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
