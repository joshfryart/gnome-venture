local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cone = c:poly({ {26,26}, {39,26}, {36,40}, {34,50}, {33,57}, {32,57}, {31,50}, {29,40} })
local shaft = cone:copy():cut(c:rect(0,50,63,63))
local tip = cone:copy():clip(c:rect(0,50,63,63))
local whole = cone:copy():add(c:ellipse(32,16,10))
local p = c:build{
  { "shaft", shaft, "wood", { light = whole } },
  { "tip", tip, GV.ramp("#8a4f2a"), { light = whole, gloss = false } },
  { "knob", c:ellipse(32,16,10), GV.ramp("#d9a660") },
  { "collar", c:rrect(25,24,39,28,1), GV.ramp("#8a4f2a"), { gloss = false } },
}
c:seam({ {26,26}, {39,26} })
c:line({ {30,35}, {30,38} }, 1)
c:paint({ "d", "d", "d", "d" }, 30, 34, { d = "#5e2f1e" })
c:paint({ "d", "d", "d" }, 34, 42, { d = "#5e2f1e" })
local t = c:save(O .. "aseprite/ph/wooden-dibber.aseprite", O .. "png/ph/wooden-dibber.png")
print(GV.report(t))
