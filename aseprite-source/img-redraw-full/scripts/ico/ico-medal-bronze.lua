local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cop = GV.ramp("#a5663a")
local p = c:build{
  { "ribR", c:poly({ {45, 6}, {34, 6}, {26, 31}, {37, 31} }), "water" },
  { "ribL", c:poly({ {19, 6}, {30, 6}, {38, 31}, {27, 31} }), "red" },
  { "disc", c:ellipse(32, 42, 15, 15), cop },
  { "inner", c:ellipse(32, 42, 8, 8), GV.ramp("#7a4a28"), { gloss = false } },
}
-- embossed star in the dish
c:paint({
  "..s..",
  ".sss.",
  "sssss",
  ".s.s.",
}, 30, 40, { s = cop.rim })
-- ribbon centre stripes
c:seam({ {24, 8}, {32, 29} }, { on = 2, off = 1 })
local t = c:save(O .. "aseprite/ico/ico-medal-bronze.aseprite", O .. "png/ico/ico-medal-bronze.png")
print(GV.report(t))
