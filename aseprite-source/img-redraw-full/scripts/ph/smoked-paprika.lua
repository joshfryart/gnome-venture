-- ph/smoked-paprika (Pantry spread): mini oak cask with iron hoops, lid heaped with brick-red paprika, S-curl smoke wisps, pepper plate
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "smoked-paprika"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- smoke wisps rising from the dust
local smoke = c:line({ {27, 16}, {25, 13}, {27, 10}, {25, 7} }, 2):add(c:line({ {34, 15}, {36, 12}, {34, 9}, {36, 6} }, 2)):add(c:line({ {41, 16}, {43, 13}, {41, 10} }, 2))
c:part(smoke, "#c9c5bc", { flat = true, contact = false, outline = false })
-- bulging barrel
local barrel = c:ellipse(32, 39, 23, 19):clip(c:rect(0, 23, 63, 55))
c:part(barrel, "#9a6b3f", { gloss = { 14, 32 } })
for _, x in ipairs({ 16, 23, 30, 37, 44 }) do c:fill(c:line({ {x, 25}, {x + (x - 32) // 6, 39}, {x, 53} }, 1):clip(barrel), "#7a4a1f") end
-- iron hoops
for _, y in ipairs({ 27, 50 }) do c:part(c:rect(0, y, 63, y + 2):clip(barrel), "#3d2a1c", { gloss = false, cres = 2, deep = 0, contact = false }) end
-- lid and the paprika heap with a spill down the side
c:part(c:ellipse(32, 23, 20, 5), "#c9a96e", { gloss = false })
c:part(c:ellipse(32, 21, 13, 4):add(c:ellipse(32, 18, 7, 3)), "#a8241f", { gloss = { 26, 17 } })
for _, p in ipairs({ {24, 21}, {30, 18}, {35, 20}, {40, 22}, {28, 23}, {37, 17}, {33, 23} }) do c:px(p[1], p[2], "#d6322b") end
c:part(c:line({ {45, 24}, {46, 30} }, 2), "#a8241f", { flat = true, contact = false })
c:px(47, 33, "#a8241f"); c:px(46, 36, "#d6322b")
-- cream plate with a red pepper, over the middle hoop
c:part(c:rrect(23, 36, 41, 47, 2), "cream", { gloss = false, contact = false })
c:paint({
  "....gg...",
  "...gg....",
  ".rrrrrr..",
  "rRrrrrrr.",
  "rRrrrrrrd",
  "rrrrrrrdd",
  ".rrr.rdd.",
}, 28, 38, { r = "#a8241f", R = "#f2793a", d = "#6b1b2c", g = "#4f9a45" })
for x = 24, 40, 3 do c:px(x, 37, "#e8a317") end
c:ground(32, 56, 18, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
