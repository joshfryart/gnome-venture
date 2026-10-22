local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local jar = c:rrect(16, 22, 47, 55, 7)
local glass = GV.ramp("#a9d6ea")
local brine = c:rrect(19, 28, 44, 52, 5)
local p = c:build{
  { "jar", jar, glass },
  { "brine", brine, GV.ramp("#d9ecd8"), { gloss = false, rim = false } },
  { "egg1", c:ellipse(25.5, 45.5, 5, 6), GV.ramp("#f4f0e0"), { light = jar } },
  { "egg2", c:ellipse(38.5, 45.5, 5, 6), GV.ramp("#f4f0e0"), { light = jar } },
  { "egg3", c:ellipse(32, 36, 5, 6), GV.ramp("#f4f0e0"), { light = jar } },
  { "lid", c:rrect(15, 13, 48, 24, 4), "gold" },
}
-- speckles
local sp = "#8a4f2a"
c:px(27, 47, sp); c:px(23, 43, sp); c:px(26, 49, sp)
c:px(40, 47, sp); c:px(37, 43, sp); c:px(39, 50, sp)
c:px(33, 38, sp); c:px(30, 34, sp); c:px(34, 35, sp)
-- lid ridge
for x = 17, 46 do if c:get(x, 18) then c:px(x, 18, "#b8661a") end end
-- glass gloss strip on left
c:fill(c:rect(18, 28, 18, 46), "#e6f6fb")
c:fill(c:rect(18, 49, 18, 50), "#e6f6fb")
c:seam({ {18, 23}, {45, 23} })
local t = c:save(O .. "aseprite/ph/pickled-quail-eggs.aseprite", O .. "png/ph/pickled-quail-eggs.png")
print(GV.report(t))
