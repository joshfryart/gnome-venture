-- ph/red-bean-buns (Gourmand P2 dish): two white steamed buns on a bamboo slat, the front one torn open on dark red bean paste
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "red-bean-buns"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- bamboo slat mat
local slat = c:rrect(7, 43, 56, 52, 2)
c:part(slat, "#c9a96e", { cres = 2, gloss = false })
for x = 11, 53, 5 do c:fill(c:rect(x, 44, x, 51), "#a8844a") end
c:fill(c:rect(8, 47, 55, 47), "#b8945a")
-- back bun with pleated top and pink dot
local back = c:ellipse(21, 36, 12, 10):clip(c:rect(0, 0, 63, 44)):add(c:ellipse(21, 42, 11, 3))
c:part(back, GV.ramp("#f1ece0", { dot = "#fbf6e8" }), { contour = "#4a2c1a", gloss = false })
for _, l in ipairs({ { {16, 28}, {19, 29} }, { {26, 28}, {23, 29} } }) do c:fill(c:line(l, 1), "#d8cfba") end
c:paint({ ".pp.", "pPpp", ".pp." }, 19, 27, { p = "#e08a8a", P = "#f2b0a8" })
-- front bun, torn open on top
local front = c:ellipse(41, 37, 13, 11):clip(c:rect(0, 0, 63, 44)):add(c:ellipse(41, 43, 12, 3))
c:part(front, "cream", { contour = "#4a2c1a", gloss = { 32, 36 } })
local tear = c:poly({ {32, 30}, {35, 27}, {38, 29}, {41, 26}, {44, 29}, {47, 27}, {50, 30}, {47, 34}, {41, 35}, {35, 34} })
c:fill(tear:copy():grow(1):clip(front), "#d8cfba")                     -- torn bread fibre
c:part(tear, "#6a1f2a", { contour = "#8a6a4a", cres = 2, gloss = false, contact = false, rim = false })
c:fill(c:ellipse(39, 30, 2, 1), "#8e3040")
c:px(38, 30, "#b05a60")
c:ground(31.5, 55, 20, 1.2)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
