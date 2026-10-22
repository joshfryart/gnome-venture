local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- D-shaped limb: outer ellipse minus inner, right half only
local limb = c:ellipse(21, 32, 33, 23):cut(c:ellipse(21, 32, 29, 20)):clip(c:rect(22, 0, 63, 63))
limb:add(c:rrect(19, 8, 23, 12, 1)):add(c:rrect(19, 52, 23, 56, 1))
c:build{
  { "string", c:rect(20, 11, 21, 53), "cream", { flat = true } },
  { "limb", limb, "wood" },
}
c:fill(c:rect(52, 29, 54, 35), "#e8a317")
c:seam({ {52, 30}, {54, 30} }, { free = true }); c:seam({ {52, 33}, {54, 33} }, { free = true })
c:build{
  { "shaft", c:rect(16, 31, 46, 33), "wood", { flat = true } },
  { "head", c:poly({ {55, 32.5}, {42, 25}, {42, 40} }), GV.ramp("#8b8f96") },
  { "fletch", c:poly({ {12, 26}, {22, 31}, {22, 34}, {12, 39} }), "red" },
}
local t = c:save(O .. "aseprite/ico/ico-bow.aseprite", O .. "png/ico/ico-bow.png")
print(GV.report(t))
