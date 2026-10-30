-- ph/colcannon (Gourmand P2 dish): cream mashed-potato dome on a small plate, dark kale streaks, a melted butter well on top
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "colcannon"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- plate
local plate = c:ellipse(31.5, 47, 24, 6.5)
c:part(plate, GV.ramp("#e6e2d6", { dot = "#f6f2e6" }), { cres = 2, gloss = false })
c:fill(c:ellipse(31.5, 46, 18, 4):edge(), "#c9bfa8")                         -- plate well ring
c:seam({ {10, 49}, {53, 49} }, { gap = "#c9bfa8" })
-- mash dome
local dome = c:ellipse(31.5, 50, 20, 24):clip(c:rect(0, 0, 63, 46))
dome:add(c:ellipse(24, 30, 5, 4)):add(c:ellipse(39, 30, 5, 4)):add(c:ellipse(31.5, 26, 6, 3))   -- lumpy mashed peaks
c:part(dome, "#e8dcb4", { contour = "#4a2c1a", gloss = { 19, 34 }, cres = 4 })
-- mash ridges (fork marks)
for _, l in ipairs({ { {18, 41}, {22, 38} }, { {41, 41}, {45, 37} }, { {27, 44}, {31, 43} } }) do
  c:fill(c:line(l, 1), "#cdb88a")
end
-- kale streaks folded through
local kale = {
  { {16, 36}, {19, 33}, {23, 31} },
  { {36, 41}, {41, 38}, {45, 34} },
  { {22, 43}, {27, 39}, {31, 38} },
  { {38, 32}, {42, 29} },
}
for _, l in ipairs(kale) do
  c:fill(c:line(l, 2):shift(0, 1), "#2f5a2a")
  c:fill(c:line(l, 2), "#4f8a3a")
end
for _, p in ipairs({ {26, 35}, {33, 44}, {17, 40}, {46, 41} }) do c:px(p[1], p[2], "#4f8a3a"); c:px(p[1] + 1, p[2], "#2f5a2a") end
-- butter well in the top
c:fill(c:ellipse(31.5, 28, 8, 3.5), "#c9a05a")
local pool = c:ellipse(31.5, 28, 6.5, 2.5)
c:fill(pool, "#f2c230")
c:fill(pool:copy():cut(pool:shift(-1, -1)), "#d89a18")
c:px(29, 27, "#fff6c0"); c:px(30, 27, "#fff6c0")
c:fill(c:line({ {37, 30}, {38, 33}, {38, 35} }, 2), "#f2c230")               -- butter trickle
c:px(38, 35, "#d89a18")
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
