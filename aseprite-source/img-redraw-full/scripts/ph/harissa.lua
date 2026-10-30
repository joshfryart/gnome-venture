-- ph/harissa (Pantry paste): red-clay tagine, low wide dish under a tall cone lid, harissa smear at the rim
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "harissa"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
c:build{
  { "dish", c:rrect(8, 43, 56, 55, 4), "#a8501f", { gloss = { 12, 46 } } },
  { "cone", c:poly({ {14, 43}, {51, 43}, {37, 22}, {34, 13}, {31, 13}, {28, 22} }), "#c0602a", { gloss = false } },
  { "rim",  c:rrect(12, 40, 52, 44, 1), "#7a3a1f", { gloss = false } },
  { "knob", c:ellipse(32.5, 11, 3.5, 3), "#c0602a", { gloss = false } },
}
-- glaze highlight down the lit side of the cone, and painted bands
c:fill(c:line({ {29, 17}, {25, 28}, {20, 38} }, 2), "#e0803a")
c:px(31, 9, "#fbe0c0")
c:fill(c:line({ {22, 33}, {43, 33} }, 1), "#f5cf6a")
for x = 23, 41, 3 do c:px(x, 34, "#7a3a1f") end
-- harissa smear spilling over the rim
c:part(c:rrect(14, 42, 22, 46, 2):add(c:rect(16, 46, 18, 48)), "#a8241f", { flat = true })
c:px(15, 43, "#e05a40")
c:part(c:rrect(24, 46, 44, 53, 1), "cream", { gloss = false, contact = false })
-- emblem: two crossed chilies and a bell pepper
c:paint({
  "r...r..ggp...",
  ".r.r..pppppp.",
  "..r...pPpppp.",
  ".r.r..pppppp.",
  "r...r..pppp..",
}, 26, 47, { r = "#d6322b", p = "#e0501f", P = "#f5a070", g = "#4f9a45" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
