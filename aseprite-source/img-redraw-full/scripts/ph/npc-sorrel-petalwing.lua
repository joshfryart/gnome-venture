local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

-- tail feather flick, upper-left behind the head
local tail = c:poly({ {16, 46}, {8, 36}, {5, 27}, {9, 26}, {15, 33}, {20, 40} })
tail:add(c:poly({ {14, 44}, {12, 32}, {14, 24}, {18, 25}, {19, 34}, {20, 42} }))

-- body bleeds off bottom
local body = c:ellipse(39.5, 101, 34, 25):cut(c:rect(0, 100, 79, 120))

-- scarf arc + hanging tail
local scarf = c:line({ {26, 77}, {33, 81}, {40, 83}, {47, 81}, {54, 77} }, 5)
local scarfTail = c:poly({ {44, 81}, {51, 81}, {52, 97}, {44, 95} })

-- head
local head = c:ellipse(39.5, 50, 23, 22)

-- chin patch
local chin = c:ellipse(39.5, 63, 13, 8):clip(head)

-- beak (downward triangle, 2+ px thick)
local beak = c:poly({ {34, 51}, {47, 51}, {40, 62} })

-- hood: petal cap over crown, folded down the sides
local hood = c:ellipse(39.5, 44, 28, 25):cut(c:rect(0, 57, 79, 99))
hood:add(c:ellipse(14, 54, 5, 5)); hood:add(c:ellipse(65, 54, 5, 5))
hood:add(c:poly({ {35, 21}, {40, 14}, {45, 21} }))              -- petal tip on top
local opening = c:ellipse(39.5, 54, 19, 18)
hood:cut(opening)
-- petal notches along the inner edge
hood:cut(c:ellipse(27, 37, 2, 2)); hood:cut(c:ellipse(52, 37, 2, 2))

local petal = GV.ramp("#d9667f")
local p = c:build{
  { "tail",  tail,  GV.ramp("#8c4a1a"), { gloss = false } },
  { "body",  body,  GV.ramp("#a38f80") },
  { "scarf", scarf, petal },
  { "scarft", scarfTail, petal },
  { "head",  head,  GV.ramp("#a5663a") },
  { "chin",  chin,  GV.ramp("#f8eed2"), { gloss = false } },
  { "beak",  beak,  "gold", { gloss = { 37, 53 } } },
  { "hood",  hood,  petal },
}

-- petal fold lines on the hood (rim tone)
c:line({ {40, 20}, {40, 27} }, 1):each(function(x, y) c:px(x, y, "#f6b8cf") end)
c:line({ {25, 26}, {21, 33} }, 1):each(function(x, y) c:px(x, y, "#f6b8cf") end)
c:line({ {55, 26}, {59, 33} }, 1):each(function(x, y) c:px(x, y, petal.shade) end)

-- edge stitch along hood
c:stitch(p.hood.m, { side = "lit" })

-- brows
c:line({ {25, 40}, {31, 42} }, 2):each(function(x, y) c:px(x, y, "#2a1a10") end)
c:line({ {55, 40}, {49, 42} }, 2):each(function(x, y) c:px(x, y, "#2a1a10") end)

-- eyes
c:eye(28, 44); c:eye(48, 44)

-- scarf knot button
c:button(38, 79)

local t = c:save(O .. "aseprite/ph/npc-sorrel-petalwing.aseprite", O .. "png/ph/npc-sorrel-petalwing.png")
print(GV.report(t))
