local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 48, h = 48, mode = "sticker" }
local O = D .. "img-redraw-full/"
local wave = c:rect(9, 35, 36, 37)
for x = 11, 35, 6 do wave:add(c:ellipse(x, 35, 2.5, 2)) end
c:build{
  { "wave", wave, "water" },
  { "mast", c:rect(21, 9, 22, 29), "#8a4f2a", { flat = true } },
  { "big",  c:poly({ {23, 11}, {35, 27}, {23, 27} }), "#f4f0e0" },
  { "small",c:poly({ {21, 13}, {12, 27}, {21, 27} }), "#e9b98a" },
  { "flag", c:rect(23, 9, 25, 11), "red", { flat = true } },
  { "hull", c:poly({ {9, 27}, {38, 27}, {33, 35}, {14, 35} }), "wood" },
}
c:seam({ {11, 29}, {35, 29} })
local t = c:save(O .. "aseprite/stops/ferry.aseprite", O .. "png/stops/ferry.png")
print(GV.report(t))
