-- ph/tahini (Pantry spread): tall narrow tin can, foil top half peeled back with a pull-ring, sesame sprig on a paper wrapper
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "tahini"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local can = c:rrect(18, 13, 46, 55, 3)
c:part(can, "#c9c5bc", { gloss = false })
c:fill(c:rect(20, 17, 21, 52), "#f4f0e0")
c:fill(c:rect(19, 18, 45, 18), "#8b8f96"); c:fill(c:rect(19, 52, 45, 52), "#8b8f96")
-- top: tahini showing where the foil is peeled, foil on the rest, a rolled foil curl and the ring
c:part(c:ellipse(32, 13, 14, 4), "#d6b98a", { gloss = false, contact = false })
c:fill(c:ellipse(37, 13, 6, 2), "#e2c89c"); c:px(33, 12, "#f4e8c0"); c:px(34, 12, "#f4e8c0")
c:part(c:ellipse(32, 13, 14, 4):cut(c:poly({ {31, 6}, {50, 6}, {50, 20}, {37, 20} })), "stone", { gloss = { 22, 12 }, contact = false })
c:part(c:rrect(37, 6, 44, 12, 3), "stone", { gloss = false, cres = 2, deep = 0 })
c:fill(c:ellipse(40, 9, 1.5, 1.5), "#5b6470"); c:px(40, 8, "#d6b98a")
c:fill(c:ellipse(24, 13, 3, 2):edge(), "#5b6470"); c:px(23, 12, "#eef0f0")
c:fill(c:rect(19, 15, 45, 15), "#8b8f96")
-- paper wrapper with umber borders and stitch dashes
local wrap = c:rect(18, 23, 46, 49)
c:part(wrap, "cream", { gloss = false, contact = false })
c:fill(c:rect(18, 23, 46, 23), "#7a4a1f"); c:fill(c:rect(18, 49, 46, 49), "#7a4a1f")
for x = 20, 44, 3 do c:px(x, 25, "#e8a317"); c:px(x + 1, 47, "#e8a317") end
-- sesame sprig: stem, paired pods, a few loose seeds
c:fill(c:rect(32, 28, 32, 45), "#4f9a45")
for _, p in ipairs({ {28, 30}, {34, 30}, {28, 35}, {34, 35}, {28, 40}, {34, 40} }) do
  c:paint({ "pp", "pP", "pp", "ss" }, p[1] + (p[1] < 32 and 1 or -1), p[2], { p = "#c9a96e", P = "#9a6b3f", s = "#4f9a45" })
end
c:paint({ "uu" }, 31, 27, { u = "#c9a96e" })
for _, p in ipairs({ {24, 44}, {39, 43}, {41, 45} }) do c:px(p[1], p[2], "#d6b98a"); c:px(p[1] + 1, p[2], "#9a6b3f") end
c:ground(32, 57, 15, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
