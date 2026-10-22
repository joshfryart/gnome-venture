local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local blade = c:ellipse(32, 37, 20, 16)
blade:add(c:poly({ {32,9}, {14,33}, {51,33} }))
blade:add(c:ellipse(32, 26, 15, 12))
blade = blade:closed(3)
local stem = c:rect(31, 52, 33, 56)
local purple = blade:copy():clip(c:rect(0, 42, 63, 63))
local green = blade:copy():cut(purple)
local p = c:build{
  { "stem", stem, GV.ramp("#54447f"), { flat = true } },
  { "blade", green, GV.ramp("#58a03e"), { light = blade, gloss = { 22, 21 } } },
  { "base", purple, GV.ramp("#7b66b4"), { light = blade, gloss = false, contour = false } },
}
local vg = "#2e5a2c"
local vp = "#3e2f66"
local function vein(pts)
  local m = c:line(pts, 2):clip(blade:shrink(2))
  m:copy():clip(green):each(function(x, y) c:px(x, y, vg) end)
  m:copy():clip(purple):each(function(x, y) c:px(x, y, vp) end)
end
vein({ {32,15}, {32,52} })
vein({ {32,46}, {23,40} }); vein({ {32,46}, {41,40} })
vein({ {32,38}, {21,31} }); vein({ {32,38}, {43,31} })
vein({ {32,29}, {23,22} }); vein({ {32,29}, {41,22} })
local t = c:save(O .. "aseprite/ph/perilla.aseprite", O .. "png/ph/perilla.png")
print(GV.report(t))
