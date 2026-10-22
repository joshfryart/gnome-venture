local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

-- body: red tunic, bleeds off bottom
local body = c:ellipse(39.5, 104, 34, 28):clip(c:rect(0, 76, 79, 99))
-- hood: crown arc behind head + side drapes ending in points at shoulders
local hood = c:ellipse(39.5, 50, 25, 26)
hood:add(c:poly({ {15, 50}, {65, 50}, {64, 66}, {60, 84}, {52, 74}, {28, 74}, {20, 84}, {16, 66} }))
-- head: wide gecko head, flatter top
local head = c:ellipse(39.5, 57, 23, 17)
-- eye bulbs on the crown
local bulbL = c:ellipse(27.5, 40, 8, 8)
local bulbR = c:ellipse(51.5, 40, 8, 8)
-- collar V
local collar = c:poly({ {30, 77}, {50, 77}, {40, 90} }):clip(body)

local p = c:build{
  { "body",  body,  GV.ramp("#d6322b"), { stitch = { side = "lit" } } },
  { "hood",  hood,  "gold", { stitch = { side = "lit" } } },
  { "collar", collar, GV.ramp("#9c2a1e"), { flat = true } },
  { "head",  head,  GV.ramp("#b0bc66") },
  { "bulbL", bulbL, GV.ramp("#f8eed2") },
  { "bulbR", bulbR, GV.ramp("#f8eed2") },
}

-- hood fold lines on the drapes
c:fill(c:line({ {19, 62}, {21, 74} }, 1), "#b07a10")
c:fill(c:line({ {60, 62}, {58, 74} }, 1), "#b07a10")

-- gecko spots (beans/diamonds) on head
c:spot(c:ellipse(39.5, 45, 2, 1.5), "#2e5a2c")
c:spot(c:ellipse(22.5, 55, 1.5, 2), "#2e5a2c")
c:spot(c:ellipse(56.5, 55, 1.5, 2), "#2e5a2c")
c:spot(c:ellipse(33.5, 49, 1, 1), "#2e5a2c")
c:spot(c:ellipse(46.5, 49, 1, 1), "#2e5a2c")

-- locked eyes centred in bulbs
c:eye(25, 38); c:eye(49, 38)

-- very wide curved grin
c:fill(c:line({ {25, 59}, {28, 62}, {33, 64}, {40, 65}, {47, 64}, {52, 62}, {55, 59} }, 2), "#2a1a10")
-- nostrils
c:px(37, 54, "#2e5a2c"); c:px(42, 54, "#2e5a2c")

-- hood button at the front
c:button(38, 75)

local t = c:save(O .. "aseprite/ph/npc-reed-hollowell.aseprite", O .. "png/ph/npc-reed-hollowell.png")
print(GV.report(t))
