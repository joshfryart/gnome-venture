local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cx, cy = 31.5, 40
local lower = c:rect(0, 41, 63, 63)
local function band(ro)
  local m = c:ellipse(cx, cy, ro, ro)
  m:cut(c:ellipse(cx, cy, ro - 4, ro - 4))
  m:cut(lower)
  return m
end
local light = c:ellipse(cx, cy, 23, 23):cut(lower)
local cl = c:ellipse(14, 43, 5.5, 5):add(c:ellipse(20, 46, 5, 4.5)):add(c:ellipse(9.5, 47, 4, 3.5)):add(c:rrect(7, 46, 24, 50, 2))
local cr = c:ellipse(49, 43, 5.5, 5):add(c:ellipse(43, 46, 5, 4.5)):add(c:ellipse(53.5, 47, 4, 3.5)):add(c:rrect(39, 46, 56, 50, 2))
c:build{
  { "outer",  band(23), GV.ramp("#dd3a2a"), { light = light } },
  { "orange", band(19), GV.ramp("#e8892a"), { light = light, gloss = false } },
  { "green",  band(15), GV.ramp("#58a03e"), { light = light, gloss = false } },
  { "blue",   band(11), GV.ramp("#3f93b2"), { light = light, gloss = false } },
  { "cloudL", cl, GV.ramp("#f1ece0") },
  { "cloudR", cr, GV.ramp("#f1ece0") },
}
local t = c:save(O .. "aseprite/ico/ico-rainbow.aseprite", O .. "png/ico/ico-rainbow.png")
print(GV.report(t))
