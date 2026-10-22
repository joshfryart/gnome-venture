local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local bulb = c:ellipse(32, 40, 20, 13):add(c:ellipse(32, 35, 14, 9))
-- wavy cap: scalloped lower edge, dipping at centre and sides
local cap = c:mask()
bulb:each(function(x, y)
  local edge = 41 + 4 * math.cos((x - 32) / 20 * 2 * math.pi)
  if y <= edge then cap:set(x, y) end
end)

c:build{
  { "leafL", c:ellipse(27.5, 18, 4.5, 8), GV.ramp("#4f9a45") },
  { "leafR", c:ellipse(37.5, 19, 4.5, 7), GV.ramp("#5fae4a") },
  { "leafF", c:ellipse(43, 26, 8, 3.5), GV.ramp("#3f8a3a"), { gloss = false } },
  { "root",  c:line({ {32, 52}, {31, 55} }, 2), GV.ramp("#d9c9b8"), { flat = true } },
  { "bulb",  bulb, GV.ramp("#f2e6f0"), { gloss = false } },
  { "cap",   cap, GV.ramp("#b25fa6"), { gloss = { 21, 32 } } },
}
-- leaf veins
c:fill(c:line({ {27, 12}, {28, 23} }, 1), "#2f5a2a")
c:fill(c:line({ {37, 14}, {37, 24} }, 1), "#2f5a2a")
-- highlight arc on the shoulder
c:fill(c:line({ {15, 39}, {17, 35}, {21, 32} }, 1), "#e8b6e0")

c:ground(32, 54, 19, 1.5)
local t = c:save(O .. "aseprite/games/crop-tuber.aseprite", O .. "png/games/crop-tuber.png")
print(GV.report(t))
