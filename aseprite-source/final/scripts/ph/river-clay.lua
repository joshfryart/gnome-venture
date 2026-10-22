local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local clay = c:ellipse(30, 44, 23, 27):cut(c:rect(0,45,63,63)):clip(c:rect(0,0,63,44))
clay:add(c:ellipse(30.5, 44, 23, 5))
clay:add(c:ellipse(36, 39, 18, 10)) -- lean the shoulder right, peak stays left
local silt = clay:copy():clip(c:rect(0,41,63,63)):cut(c:ellipse(31, 32, 40, 12))
local cr = GV.ramp("#dcb06a", { gloss = "#fff3c8", dot = "#ffffff", rim = "#f5b860" })
local p = c:build{
  { "clay", clay, cr, { gloss = {17,25} } },
  { "silt", silt, GV.ramp("#6a6070"), { light = clay, gloss = false } },
}
-- thumb-print dent
c:fill(c:ellipse(35, 31, 2.5, 1.5), cr.shade)
c:px(34,30,cr.deep); c:px(35,30,cr.deep); c:px(36,30,cr.deep)
-- wet streak
c:fill(c:line({ {21,26},{25,22},{29,20} },1), "#fff3c8")
c:ground(30.5, 50, 19, 1.5)
local t = c:save(O.."aseprite/ph/river-clay.aseprite", O.."png/ph/river-clay.png")
print(GV.report(t))
