local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local handle = c:line({ {38, 38}, {46, 46} }, 7):add(c:ellipse(47, 47, 4.5))
local collar = c:line({ {34, 39}, {39, 34} }, 5)
c:build{
  { "handle", handle, GV.ramp("#a5663a") },
  { "collar", collar, GV.ramp("#8fcbd8"), { gloss = false } },
  { "frame",  c:ellipse(26, 26, 15), "water" },
  { "glass",  c:ellipse(26, 26, 10), GV.ramp("#c8ecdc"), { gloss = false } },
}
-- glass glint: comma + dot, upper-left
c:paint({ ".gg", "g..", "g.." }, 20, 19, { g = "#fff3c8" }); c:px(21, 23, "#ffffff")
c:px(24, 19, "#fff3c8")
-- reflection streak lower-right of glass
c:paint({ "..b", ".b.", "b.." }, 29, 28, { b = "#8fcbd8" })
local t = c:save(O .. "aseprite/ico/ico-magnifier.aseprite", O .. "png/ico/ico-magnifier.png")
print(GV.report(t))
