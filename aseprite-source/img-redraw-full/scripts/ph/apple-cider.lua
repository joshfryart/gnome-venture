-- ph/apple-cider (Pantry cordial): broad half-gallon cider jug, small glass thumb loop at the neck, stubby cork, cloudy golden cider, red apple label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "apple-cider"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = c:rrect(12, 25, 50, 56, 10):add(c:rect(27, 13, 37, 26)):add(c:poly({ {24, 22}, {41, 22}, {46, 28}, {16, 28} }))
glass:add(c:ellipse(41, 19, 4.5):cut(c:ellipse(41, 19, 2)))
c:build{
  { "glass",  glass, "#d8ecf0", { pale = false } },
  { "liquid", c:rrect(14, 29, 48, 54, 8), GV.ramp("#e0a02f", { shade = "#b07a10" }), { contour = "#b07a10", gloss = false } },
  { "label",  c:rrect(22, 36, 42, 52, 3), "cream", { gloss = false, contact = false } },
}
c:fill(c:rect(16, 33, 18, 50), "#f5cf6a"); c:px(17, 31, "#fbf6e8")
c:part(c:rect(28, 8, 36, 14), "#c9a96e", { gloss = false })
c:px(30, 10, "#9a6b3f"); c:px(34, 12, "#9a6b3f")
c:seam({ {28, 15}, {36, 15} }, { free = true })
-- red apple
c:paint({
  "....k.g.",
  "..rrkrgg",
  ".rRrrrr.",
  "rRrrrrrr",
  "rrrrrrrs",
  "rrrrrrrs",
  ".rrrrrs.",
  "..rs.s..",
}, 28, 40, { r = "#d6322b", R = "#ff9158", s = "#ae2a2a", k = "#7a4a1f", g = "#4f9a45" })
c:ground(31, 57, 19, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
