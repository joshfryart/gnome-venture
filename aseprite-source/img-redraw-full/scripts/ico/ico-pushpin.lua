local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local needle = c:rect(31, 36, 33, 54); needle:add(c:rect(32, 55, 32, 56))
local cone = c:poly({ {23,18}, {42,18}, {38,35}, {27,35} })
c:build{
  { "needle", needle, GV.ramp("#968f96", { rim = "#c9c5bc" }), { flat = true } },
  { "collar", c:rrect(19, 33, 45, 39, 3), GV.ramp("#bf6f4f") },
  { "cone", cone, GV.ramp("#9c2a1e") },
  { "dome", c:ellipse(32, 15, 14, 8.5), GV.ramp("#d9667f") },
}
local t = c:save(O .. "aseprite/ico/ico-pushpin.aseprite", O .. "png/ico/ico-pushpin.png")
print(GV.report(t))
