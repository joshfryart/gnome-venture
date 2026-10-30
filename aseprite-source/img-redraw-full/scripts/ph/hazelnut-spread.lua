-- ph/hazelnut-spread (Pantry spread): tapered tumbler jar (wide mouth, narrow base), dark chocolate spread, ridged red lid, hazelnut pair
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "hazelnut-spread"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local jar = c:poly({ {12, 21}, {53, 21}, {47, 53}, {44, 56}, {21, 56}, {18, 53} })
c:part(jar, "glass", { gloss = false })
local fill = c:poly({ {15, 25}, {50, 25}, {45, 51}, {43, 54}, {22, 54}, {20, 51} })
c:part(fill, "#5a3a1f", { gloss = { 20, 31 }, contact = false })
c:fill(c:line({ {18, 26}, {26, 28}, {34, 27}, {44, 29} }, 2), "#7a4a1f")
c:fill(c:line({ {19, 26}, {26, 27} }, 1), "#a8742f")
-- label with two hazelnuts and a cacao stripe
c:part(c:rect(21, 35, 44, 48), "cream", { gloss = false, contact = false })
c:paint({
  "..ccc....ccc..",
  ".ckkkc..ckkkc.",
  ".hHhhh..hHhhh.",
  "hhhhhhshhhhhhs",
  "hhhhhshhhhhhs.",
  ".hhhs..hhhss..",
  "..ss....ss....",
}, 26, 37, { h = "#c9a96e", H = "#ecc58a", s = "#9a6b3f", c = "#9a6b3f", k = "#7a4a1f" })
c:fill(c:rect(24, 45, 41, 45), "#5a3a1f")
-- ridged red screw lid
local lid = c:rrect(10, 11, 55, 22, 3)
c:part(lid, "#a8241f", { gloss = { 13, 13 } })
for x = 14, 52, 5 do c:fill(c:rect(x, 13, x, 20), "#6a1f2a") end
c:seam({ {12, 22}, {53, 22} }, { free = true })
c:ground(32, 57, 15, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
