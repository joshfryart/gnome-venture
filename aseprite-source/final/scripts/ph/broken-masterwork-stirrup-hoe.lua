local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local wood = GV.ramp("#b6814d")
-- upper shaft ends in a jagged break
local up = c:line({ {42,20},{32,36} }, 5)
up:cut(c:poly({ {26,33},{31,35},{33,32},{36,37},{40,40},{26,44} }))
-- lower shaft, shifted left, jagged top
local lo = c:line({ {28,40},{20,52} }, 5)
lo:cut(c:poly({ {20,30},{36,30},{36,40},{33,41},{31,38},{28,41},{24,38} }))
-- stirrup head: trapezoid blade with an open window plus a collar
local blade = c:poly({ {35,9},{57,9},{54,22},{38,22} })
blade:cut(c:rrect(41, 12, 51, 17, 1))
local collar = c:rrect(39, 19, 46, 25, 1)

local p = c:build{
  { "lo",     lo,     wood },
  { "up",     up,     wood },
  { "collar", collar, "gold" },
  { "blade",  blade,  "gold", { gloss = { 39, 10 } } },
}
c:seam({ {40,23}, {46,23} })
-- crack lines on the break ends
c:fill(c:line({ {29,35},{31,34},{33,36} }, 1), "#2a1a10")
c:fill(c:line({ {25,41},{27,40},{29,42} }, 1), "#2a1a10")
c:fill(c:line({ {37,27},{35,30} }, 1), "#4a2c1a")
-- loose splinter and chip
c:part(c:poly({ {44,44},{50,46},{49,49},{43,47} }), "#d9a660", { flat = true })
c:part(c:rect(9, 42, 12, 44), wood, { flat = true })

local t = c:save(O .. "aseprite/ph/broken-masterwork-stirrup-hoe.aseprite", O .. "png/ph/broken-masterwork-stirrup-hoe.png")
print(GV.report(t))
