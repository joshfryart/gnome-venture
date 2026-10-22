local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local low = c:rect(0, 23, 63, 63)
local rind  = c:ellipse(32, 22, 25, 26):clip(low)
local pale  = c:ellipse(32, 22, 21, 22):clip(low)
local flesh = c:ellipse(32, 22, 18, 19):clip(low)

c:build{
  { "rind",  rind,  "#3f8a3a" },
  { "pale",  pale,  "#d6eaa8", { gloss = false, contour = false } },
  { "flesh", flesh, "#e04a4a", { gloss = { 20, 25 }, contact = false } },
}
-- seeds: beans, varied tilt
c:spot(c:ascii({ ".xx", "xxx", "xxx", "xx." }, 24, 27), "#3a2f3a")
c:spot(c:ascii({ "xx.", "xxx", "xxx", ".xx" }, 39, 27), "#3a2f3a")
c:spot(c:ascii({ ".xx.", "xxxx", "xxxx", ".xx." }, 31, 33), "#3a2f3a")

local t = c:save(O .. "aseprite/ico/ico-watermelon.aseprite", O .. "png/ico/ico-watermelon.png")
print(GV.report(t))
