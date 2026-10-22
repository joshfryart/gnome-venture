local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(R .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- leafy dome, bumpy top
local mound = c:ellipse(31.5, 30, 21, 18):cut(c:rect(0, 31, 63, 63))
mound:add(c:ellipse(16, 22, 6, 6)):add(c:ellipse(25, 14, 7, 6)):add(c:ellipse(38, 14, 7, 6)):add(c:ellipse(47, 22, 6, 6))
mound:cut(c:rect(0, 31, 63, 63))
-- bowl: wide half-disc with flat rim
local bowl = c:ellipse(31.5, 29, 24, 23):cut(c:rect(0, 0, 63, 28))
bowl:add(c:rrect(7, 27, 56, 31, 1))
local p = c:build{
  { "mound", mound, GV.ramp("#3f93b2") },
  { "bowl",  bowl,  GV.ramp("#f4f0e0") },
}
c:part(c:ellipse(22, 19, 3.5, 3.5), GV.ramp("#256a80"), { gloss = false })
c:part(c:ellipse(33, 13, 3.5, 3.5), GV.ramp("#7ab55c"), { gloss = false })
c:part(c:ellipse(43, 21, 3, 3), GV.ramp("#e8a317"), { gloss = false })
c:part(c:ellipse(30, 24, 2.5, 2.5), GV.ramp("#dd3a2a"), { gloss = false })
c:px(21, 18, "#5aa9c4"); c:px(32, 12, "#c8d77a"); c:px(42, 20, "#fff1c8"); c:px(29, 23, "#ff9158")
-- rim line and stitch
c:seam({ {10, 33}, {54, 33} })
local t = c:save(R .. "img-redraw-full/aseprite/ico/ico-salad.aseprite", R .. "img-redraw-full/png/ico/ico-salad.png")
print(GV.report(t))
