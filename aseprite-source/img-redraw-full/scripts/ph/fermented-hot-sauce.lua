-- ph/fermented-hot-sauce (Pantry ferment): slim long-neck dasher bottle, dark shaker cap, deep-red sauce with froth, flame label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "fermented-hot-sauce"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local sauce = GV.ramp("#c8321f", { shade = "#a8241f", deep = "#6b1b2c", bounce = "#b8452f", gloss = "#ff9158", dot = "#ffc27a", rim = "#e0501f" })
c:build{
  { "glass", c:rrect(23, 26, 41, 56, 6):add(c:rect(28, 13, 36, 27)), "glass", { gloss = false } },
  { "sauce", c:rrect(25, 29, 39, 54, 4), sauce, { contour = "#6b1b2c", gloss = false } },
}
c:fill(c:rect(26, 29, 38, 30), "#f6b8cf")   -- fermentation froth
c:px(29, 29, "#fbf6e8"); c:px(35, 30, "#e46a9b"); c:px(27, 30, "#e46a9b")
for _, b in ipairs({ {28, 33}, {35, 32}, {31, 35} }) do c:px(b[1], b[2], "#f6b8cf") end
c:part(c:rrect(24, 37, 40, 50, 2), "cream", { gloss = false, contact = false })
c:paint({   -- flame emblem
  "...o...",
  "..oo...",
  "..ooo.o",
  ".oooooo",
  "oooyooo",
  "ooyyyoo",
  "ooyyyoo",
  ".ooyoo.",
  "..ooo..",
}, 29, 39, { o = "#e0501f", y = "#f5cf6a" })
-- shaker cap with a pour hole, drip of sauce down the neck
c:part(c:rrect(26, 6, 38, 14, 2), "#3d2a1c", { gloss = { 28, 8 } })
c:fill(c:rect(31, 6, 33, 6), "#2a1a10")
c:seam({ {27, 13}, {37, 13} })
c:part(c:rrect(33, 15, 34, 22, 1), sauce, { flat = true, contact = false })
c:fill(c:rect(33, 23, 34, 24), "#a8241f")
c:gloss(c:rrect(23, 26, 41, 56, 6), "glass", { 25, 33 })
c:fill(c:rect(29, 16, 29, 22), "#eef8f2")   -- neck glint
c:ground(32, 57, 11, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
