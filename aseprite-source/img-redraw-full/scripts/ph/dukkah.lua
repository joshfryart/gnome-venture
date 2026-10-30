-- ph/dukkah (Pantry spread): heavy stone mortar on a foot, heaped with brown nut-and-spice crumbs, wooden pestle leaning in, hazelnut tag
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "dukkah"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- mound of crumbs (behind the rim front)
local mound = c:ellipse(32, 28, 18, 10):cut(c:rect(0, 31, 63, 63))
c:part(mound, "#8a6a3a", { gloss = false })
for _, p in ipairs({ {20, 25}, {25, 21}, {31, 19}, {37, 21}, {43, 24}, {28, 26}, {35, 25}, {23, 28}, {40, 28}, {32, 23}, {46, 28}, {17, 29} }) do c:px(p[1], p[2], "#c9a96e") end
for _, p in ipairs({ {22, 23}, {29, 22}, {34, 21}, {39, 24}, {26, 28}, {44, 27}, {31, 27}, {19, 27} }) do c:px(p[1], p[2], "#5a3a1f") end
for _, p in ipairs({ {27, 20}, {33, 24}, {41, 26}, {24, 25}, {36, 28} }) do c:px(p[1], p[2], "#f4e8c8") end
-- wooden pestle leaning into the heap
c:part(c:line({ {44, 10}, {36, 27} }, 4), "#9a6b3f", { gloss = false, cres = 2, deep = 0 })
c:part(c:ellipse(45, 9, 3.5, 3.5), "#9a6b3f", { gloss = { 44, 7 }, cres = 2, deep = 0 })
-- mortar: rim, bowl and foot
local foot = c:rrect(22, 50, 42, 55, 1)
c:part(foot, "#5b6470", { gloss = false })
local bowl = c:ellipse(32, 32, 22, 20):cut(c:rect(0, 0, 63, 31)):cut(c:rect(0, 52, 63, 63))
c:part(bowl, "stone", { gloss = { 14, 37 } })
local rim = c:ellipse(32, 31, 23, 4.5)
rim:cut(c:ellipse(32, 29, 18, 2.5))
c:part(rim, "#c9c5bc", { gloss = false, contact = false })
c:fill(c:ellipse(32, 31, 23, 4.5):edge():cut(c:rect(0, 0, 63, 31)), "#8b8f96")
-- crumbs that spill over the rim
for _, p in ipairs({ {24, 29}, {35, 30}, {42, 30}, {29, 30} }) do c:px(p[1], p[2], "#8a6a3a") end
-- tag with a hazelnut
c:part(c:rrect(23, 38, 39, 48, 1), "cream", { gloss = false, contact = false })
for x = 25, 37, 3 do c:px(x, 39, "#e8a317"); c:px(x + 1, 47, "#e8a317") end
c:paint({
  "..kkkk..",
  ".kccccc.",
  "hHhhhhhs",
  "hhhhhhhs",
  ".hhhhss.",
  "..ssss..",
}, 28, 40, { h = "#c9a96e", H = "#ecc58a", s = "#9a6b3f", c = "#9a6b3f", k = "#7a4a1f" })
c:ground(32, 56, 16, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
