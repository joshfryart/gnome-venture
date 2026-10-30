-- ph/salted-eggs (Pantry preserve): wide grey stoneware brine bowl, white salt-crust rim, eggs piled above, one split orange yolk
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "salted-eggs"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local egg = GV.ramp("#f4f0e0", { shade = "#c9c5bc", deep = "#8b8f96", bounce = "#d8d4cc", dot = "#fbf6e8" })
local salt = GV.ramp("#f1ece0", { shade = "#c9c5bc", deep = "#8b8f96", bounce = "#d8d4cc", dot = "#fbf6e8" })
local yolk = GV.ramp("#f08a24", { gloss = "#ffc27a", dot = "#fff1c8", rim = "#f5b040", shade = "#d0601a", deep = "#a8401a", bounce = "#c8641a" })
-- eggs piled in the bowl, back one first
c:part(c:ellipse(34, 22, 6, 8), egg, { gloss = { 31, 17 } })
c:part(c:ellipse(23, 27, 6, 8), egg, { gloss = { 20, 22 } })
c:part(c:ellipse(44, 28, 6, 8), egg, { gloss = { 41, 23 } })
for _, p in ipairs({ {36, 25}, {26, 30}, {46, 31}, {32, 19} }) do c:px(p[1], p[2], "#a8a8a0") end   -- speckles
c:part(c:rrect(10, 36, 54, 55, 10), "stone", { gloss = { 14, 42 } })
c:fill(c:rect(14, 44, 50, 44), "#bfe3ee")   -- brine line
c:part(c:rrect(8, 32, 56, 39, 3), salt, { gloss = false })
for _, p in ipairs({ {12, 34}, {20, 36}, {29, 33}, {37, 35}, {45, 33}, {52, 36}, {16, 37}, {41, 37} }) do c:px(p[1], p[2], "#c9c5bc") end
c:paint({ "w.w", ".w." }, 23, 33, { w = "#fbf6e8" })
-- split egg half in front with an orange yolk
local half = c:ellipse(17, 37, 7, 5):add(c:poly({ {21, 33}, {27, 36}, {21, 41} }))
c:part(half, egg, { gloss = false, contact = false, cres = 3, deep = 0 })
c:part(c:ellipse(16, 37, 4, 3.5), yolk, { gloss = { 14, 35 }, contact = false, cres = 2, deep = 0 })
-- emblem on the bowl: egg and salt grains
c:paint({
  "..eee....",
  ".eEeee.s.",
  "eEeeeee..",
  "eeeeees.s",
  "eeeeess..",
  ".eesss.s.",
  "..sss....",
}, 33, 44, { e = "#f4f0e0", E = "#fbf6e8", s = "#c9c5bc" })
c:ground(32, 57, 21, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
