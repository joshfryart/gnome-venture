local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local green = GV.ramp("#58a03e")
local red = GV.ramp("#d6322b")
-- hood back (behind head), frames the eye bumps
local hood = c:ellipse(39.5, 45, 31, 29):cut(c:rect(0, 74, 79, 99))
-- coat dome
local coat = c:ellipse(39.5, 106, 34, 30):clip(c:rect(0, 76, 79, 99))
-- head + eye domes one frog shape
local head = c:ellipse(39.5, 58, 26, 18)
head:add(c:ellipse(26, 38, 9.5, 9)):add(c:ellipse(53, 38, 9.5, 9))
head:add(c:rect(26, 42, 53, 46))
local belly = c:ellipse(39.5, 71, 14, 4.5)
-- front flaps of the hood cloak
local flapL = c:poly({ {8, 46}, {17, 48}, {21, 60}, {19, 74}, {9, 74} })
local flapR = c:poly({ {72, 46}, {63, 48}, {59, 60}, {61, 74}, {72, 74} })
local p = c:build{
  { "back",  c:ellipse(39.5, 50, 36, 36), "#f6b8cf" },
  { "hood",  hood, red, { stitch = { side = "lit" } } },
  { "coat",  coat, GV.ramp("#7a5cc0") },
  { "head",  head, green },
  { "belly", belly, GV.ramp("#b0bc66"), { gloss = false } },
  { "flapL", flapL, red, { gloss = false } },
  { "flapR", flapR, red, { gloss = false } },
}
-- scarf
local scarf = c:line({ {27, 78}, {33, 82}, {40, 84}, {46, 82}, {52, 78} }, 3)
scarf:add(c:rect(47, 81, 50, 95))
c:part(scarf, red, { gloss = false })
c:seam({ {28, 80}, {34, 83}, {40, 85}, {46, 83}, {51, 80} })
-- collar shade
c:paint({ "ddddddddddddd" }, 34, 77, { d = "#4e3a8a" })
-- eyes
c:eye(24, 36); c:eye(51, 36)
-- nostrils
c:paint({ "nn.....nn" }, 35, 53, { n = "#2e5a2c" })
-- wide smile
c:fill(c:line({ {21, 60}, {25, 64}, {31, 67}, {36, 68}, {43, 68}, {48, 67}, {54, 64}, {58, 60} }, 2), "#2a1a10")
c:button(38, 18)
local t = c:save(O .. "aseprite/ph/npc-fennick-barkley.aseprite", O .. "png/ph/npc-fennick-barkley.png")
print(GV.report(t))
