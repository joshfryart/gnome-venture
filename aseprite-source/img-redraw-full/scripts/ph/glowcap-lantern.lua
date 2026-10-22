local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local loop = c:ellipse(32, 10, 4, 4):cut(c:ellipse(32, 10, 1.5, 1.5))
local p = c:build{
  { "loop", loop, "#968f96", { gloss = false } },
  { "glass", c:rrect(22, 19, 42, 49, 4), "#f5cf6a", { gloss = { 25, 23 } } },
  { "orb", c:ellipse(32, 34, 6, 6), "#e8a317", { gloss = false } },
  { "top", c:rrect(19, 13, 45, 20, 3), "#d6c9b6", { gloss = { 22, 15 } } },
  { "bot", c:rrect(19, 48, 45, 54, 3), "#d6c9b6", { gloss = false } },
}
-- glass bars (skip over orb)
local bars = c:rect(27, 21, 27, 47):add(c:rect(37, 21, 37, 47)):cut(c:ellipse(32, 34, 7, 7))
c:fill(bars, "#b8661a")
-- glowing core
c:fill(c:ellipse(32, 34, 3, 3), "#f5cf6a")
c:fill(c:rect(30, 32, 32, 34), "#fff1c8")
c:px(29, 31, "#fff1c8")
local t = c:save(O .. "aseprite/ph/glowcap-lantern.aseprite", O .. "png/ph/glowcap-lantern.png")
print(GV.report(t))
