-- ph/pluot-jam (Pantry jam): shouldered preserving jar, two-piece silver lid, plum fill glowing to an apricot band at the base
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pluot-jam"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local glass = c:rrect(15, 26, 49, 54, 7):add(c:poly({ {21, 19}, {44, 19}, {44, 23}, {49, 30}, {15, 30}, {21, 23} }))
local fill = c:rrect(17, 29, 47, 52, 5):add(c:poly({ {23, 24}, {42, 24}, {42, 25}, {46, 31}, {18, 31}, {23, 25} }))
local band = fill:copy():clip(c:rect(0, 45, 63, 63)):add(fill:copy():clip(c:rect(17, 44, 24, 44))):add(fill:copy():clip(c:rect(38, 44, 47, 44)))
c:build{
  { "glass", glass, "glass" },
  { "jam",   fill, "#7a2a58", { contour = "#3e2f66", gloss = { 20, 33 } } },
  { "glow",  band, "#f08a24", { contour = false, gloss = false, rim = false, contact = false } },
  { "label", c:rect(22, 31, 42, 41), "cream", { gloss = false, contact = false } },
  { "disc",  c:rect(20, 11, 44, 13), "#c9c5bc", { gloss = false } },
  { "band",  c:rrect(18, 13, 46, 21, 2), "stone", { gloss = false } },
}
c:fill(c:rect(18, 44, 46, 44):clip(fill), "#c8561c"); c:fill(c:rect(25, 44, 37, 44), "#c8561c")   -- stepped seam where plum meets apricot
c:fill(c:rect(18, 43, 46, 43):clip(fill):clip(c:rect(25, 43, 37, 43)), "#b8452f")
for x = 20, 44, 2 do c:px(x, 15, "#5b6470"); c:px(x, 19, "#5b6470") end   -- knurl ticks
c:fill(c:rect(20, 14, 44, 14), "#c9c5bc")
c:seam({ {19, 20}, {45, 20} })
-- label: round fruit split down the middle, plum left and apricot right
c:paint({
  "....g....",
  "..ppgaa..",
  ".pLppaaa.",
  "ppppkaaaa",
  "ppppkaaas",
  ".pppkaas.",
  "..ppkas..",
}, 28, 32, { p = "#7a2a58", L = "#c04a7a", a = "#f08a24", s = "#c8561c", k = "#3e2f66", g = "#4f9a45" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
