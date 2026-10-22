local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local dome = c:ellipse(31.5, 30, 20, 15):cut(c:rect(0, 31, 63, 63))
-- sardine bumps on top of the dome
dome:add(c:ellipse(22, 19, 6, 4)); dome:add(c:ellipse(38, 17, 7, 4))
local bowl = c:ellipse(31.5, 30, 24, 22):cut(c:rect(0, 0, 63, 29))
local rim = c:rrect(7, 27, 56, 31, 2)
local p = c:build{
  { "dome", dome, GV.ramp("#f08a24"), { gloss = { 19, 20 } } },
  { "bowl", bowl, GV.ramp("#f4f0e0"), { light = bowl:copy():add(rim) } },
  { "rim", rim, GV.ramp("#d6c9b6") },
}
-- fish lines (grill marks) on the dome
c:fill(c:line({ {27,25}, {33,20} }, 1), "#b8661a")
c:fill(c:line({ {38,26}, {44,21} }, 1), "#b8661a")
c:part(c:ellipse(24, 22.5, 3.5, 3.5), GV.ramp("#e0501f"), { flat = true })
c:part(c:ellipse(35.5, 20.5, 3.5, 3.5), GV.ramp("#7ab55c"), { flat = true })
c:part(c:ellipse(44, 24, 3, 3), GV.ramp("#e8a317"), { flat = true })
c:seam({ {12, 39}, {52, 39} })
local t = c:save(O .. "aseprite/ph/grilled-sardines.aseprite", O .. "png/ph/grilled-sardines.png")
print(GV.report(t))
