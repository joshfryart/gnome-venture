-- ph/tamarind-drink (Pantry cordial): double-bulb gourd bottle, orange cloth tie knotted at the waist, dark brown tamarind drink, curved pod label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "tamarind-drink"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = c:ellipse(32, 42, 14):add(c:ellipse(32, 21, 8.5)):add(c:rect(28, 27, 36, 30))
c:build{
  { "glass",  glass, "#d8ecf0", { pale = false } },
  { "liquid", c:ellipse(32, 43, 12):add(c:ellipse(32, 22, 6.5)):add(c:rect(30, 27, 34, 31)), GV.ramp("#5a3a1f", { rim = "#7a4a1f", gloss = "#a8582f", dot = "#c98a4a" }), { contour = "#3d2a1c", gloss = false } },
}
c:fill(c:line({ {22, 41}, {23, 37}, {26, 34} }, 2), "#7a4a1f"); c:px(25, 25, "#7a4a1f"); c:px(26, 23, "#7a4a1f"); c:px(26, 24, "#7a4a1f")
c:part(c:rect(29, 8, 35, 13), "#c9a96e", { gloss = false })
-- cloth strip round the waist, knot and tail on the right
local cloth = c:rect(24, 28, 40, 32):add(c:rrect(38, 27, 43, 33, 1)):add(c:line({ {42, 33}, {44, 37} }, 2))
c:part(cloth, GV.ramp("#e0501f", { shade = "#a8241f" }), { gloss = false, cres = 2, deep = 0 })
for _, x in ipairs({ 27, 31, 35 }) do c:px(x, 29, "#a8241f"); c:px(x + 1, 31, "#a8241f") end
c:fill(c:rect(40, 29, 41, 30), "#a8241f"); c:px(39, 28, "#f08a24")
-- label with a curved, bumpy tamarind pod
c:part(c:rect(24, 42, 40, 53), "cream", { gloss = false, contact = false })
c:paint({
  ".........kk.",
  "..kk...kkpk.",
  ".kppkkkppkk.",
  "kpPpppPpppk.",
  "kpppkpppk...",
  ".kkk.kkk....",
}, 26, 44, { k = "#7a4a1f", p = "#9a6b3f", P = "#c98a4a" })
c:ground(32, 57, 13, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
