-- ph/plum-chutney (Pantry chutney): taller jar, fluted gold lid, chunky dark plum fill with gold spice flecks
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "plum-chutney"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = c:rrect(18, 23, 46, 56, 6):add(c:rect(21, 19, 43, 24))
c:build{
  { "glass", glass, "glass" },
  { "fill",  c:rrect(20, 29, 44, 54, 4), "#6a2a4a", { contour = "#3a1228", gloss = { 22, 31 } } },
  { "label", c:rect(22, 37, 42, 46), "cream", { gloss = false, contact = false } },
  { "lid",   c:rrect(17, 10, 47, 20, 2), "gold" },
}
-- fluted lid ridges
for x = 20, 44, 3 do c:fill(c:rect(x, 12, x, 17), x < 30 and "#d0862a" or "#b8661a") end
c:seam({ {19, 19}, {45, 19} })
-- chunky fill: 2px plum chunks (dark and light) + gold spice flecks
for _, p in ipairs({ {23,31}, {29,30}, {36,31}, {41,32}, {25,34}, {33,34}, {39,35}, {23,49}, {29,50}, {35,49}, {40,48}, {26,52}, {37,52} }) do
  c:paint({ "ab", "bb" }, p[1], p[2], { a = "#9a4a6e", b = "#4a1a34" })
end
for _, p in ipairs({ {27,32}, {34,29}, {21,35}, {43,34}, {32,51}, {22,47}, {42,51} }) do c:px(p[1], p[2], "#f5cf6a") end
-- label: two rows of ticks and a tiny plum
c:paint({ "u.uu.u.uu", "", "uu.u.uu.u" }, 24, 39, { u = "#7a4a3a" })
c:paint({ ".g.", "ppp", "pps", ".s." }, 37, 39, { p = "#6a2a4a", s = "#3a1228", g = "#7ab55c" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
