local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local gold = GV.ramp("#f2cf4a")
local sack = c:ellipse(32, 39, 18, 13):add(c:poly({ {24, 22}, {41, 22}, {46, 30}, {18, 30} }))
local frill = c:poly({ {21, 9}, {25, 14}, {28, 8}, {32, 13}, {36, 8}, {39, 14}, {44, 9}, {41, 21}, {24, 21} })
local p = c:build{
  { "sack",  sack, GV.ramp("#a5663a") },
  { "frill", frill, GV.ramp("#8c4a1a"), { gloss = false } },
  { "tie",   c:rrect(22, 19, 42, 24, 2), gold, { gloss = false } },
  { "coin",  c:ellipse(32, 40, 7.5), gold },
  { "coinL", c:ellipse(15.5, 47.5, 4.5), gold, { gloss = false } },
  { "coinR", c:ellipse(48.5, 47.5, 4.5), gold, { gloss = false } },
}
c:stitch(p.sack.m, { side = "lit" })
c:seam({ {24, 21}, {40, 21} })
c:fill(c:ellipse(32, 40, 3), "#dcb06a")
c:px(14, 46, "#fff1c8"); c:px(47, 46, "#fff1c8")
local t = c:save(O .. "aseprite/ico/ico-money-bag.aseprite", O .. "png/ico/ico-money-bag.png")
print(GV.report(t))
