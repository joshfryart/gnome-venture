local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local green = GV.ramp("#3e7a2c")
local light = GV.ramp("#7fbf5a")
local white = GV.ramp("#f8eed2")
local body = c:ellipse(31.5, 40, 21, 15)
local bumps = c:ellipse(20, 24, 8.5):add(c:ellipse(43, 24, 8.5))
local toes = c:ellipse(15, 52, 2.5, 2):add(c:ellipse(20, 54, 2.5, 2)):add(c:ellipse(48, 52, 2.5, 2)):add(c:ellipse(43, 54, 2.5, 2))
c:build{
  { "toes", toes, light, { flat = true } },
  { "body", body, green, { light = body:copy():add(bumps) } },
  { "bumps", bumps, green, { light = body:copy():add(bumps), gloss = { 14, 18 } } },
  { "belly", c:ellipse(31.5, 47, 12, 6), light, { gloss = false } },
  { "whiteL", c:ellipse(20, 24, 4.5), white, { flat = true } },
  { "whiteR", c:ellipse(43, 24, 4.5), white, { flat = true } },
}
c:eye(18, 22); c:eye(41, 22)
c:fill(c:line({ {23, 38}, {27, 40}, {31, 41}, {32, 41}, {36, 40}, {40, 38} }, 2), "#2a1a10")
c:px(27, 33, "#2a1a10"); c:px(36, 33, "#2a1a10")
local t = c:save(O .. "aseprite/ico/ico-frog.aseprite", O .. "png/ico/ico-frog.png")
print(GV.report(t))
