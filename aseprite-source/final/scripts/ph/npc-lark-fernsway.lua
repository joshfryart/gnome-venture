local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local disc = c:ellipse(40, 49, 34, 34)
local body = c:ellipse(39.5, 101, 34, 24):clip(c:rect(0, 0, 79, 99))
local scarf = c:line({ {27, 80}, {33, 84}, {40, 86}, {47, 84}, {53, 80} }, 5)
local tail = c:poly({ {44, 84}, {52, 84}, {51, 97}, {45, 95} })
scarf:add(tail)
local antL = c:line({ {34, 40}, {31, 35}, {28, 31}, {25, 28}, {22, 27} }, 2)
antL:add(c:rrect(18, 24, 21, 27, 1))
local antR = c:line({ {45, 40}, {48, 35}, {51, 31}, {54, 28}, {57, 27} }, 2)
antR:add(c:rrect(58, 24, 61, 27, 1))
local head = c:ellipse(40, 55, 21, 20)

c:build{
  { "disc",  disc,  GV.ramp("#b0bc66"), { gloss = false } },
  { "body",  body,  GV.ramp("#58a03e"), { stitch = { side = "lit" } } },
  { "antL",  antL,  GV.ramp("#3e2f66"), { flat = true } },
  { "antR",  antR,  GV.ramp("#3e2f66"), { flat = true } },
  { "head",  head,  "wood" },
  { "scarf", scarf, "moss" },
}
-- collar V on the tunic below the scarf
c:fill(c:poly({ {36, 88}, {44, 88}, {40, 94} }), "#2e5a2c")
-- shell split seam
c:seam({ {40, 36}, {40, 46} }, { gap = "#4a2c1a" })
c:button(38, 79)
-- face
c:eye(30, 51); c:eye(46, 51)
c:paint({ "u.........u", ".u.......u.", "..uuuuuuu.." }, 35, 63, { u = "#4a2c1a" })

local t = c:save(O .. "aseprite/ph/npc-lark-fernsway.aseprite", O .. "png/ph/npc-lark-fernsway.png")
print(GV.report(t))
