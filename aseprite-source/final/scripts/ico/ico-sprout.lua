local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local soil = c:ellipse(31.5, 50, 18, 6)
local stem = c:rect(30, 26, 33, 47)
local lleaf = c:poly({ {33, 35}, {26, 37}, {19, 34}, {15, 28}, {13, 20}, {20, 20}, {27, 24}, {32, 29} })
local rleaf = c:poly({ {31, 32}, {32, 25}, {36, 19}, {42, 15}, {51, 12}, {50, 20}, {46, 27}, {39, 31} })
local leaf = GV.ramp("#58a03e")
c:build{
  { "soil",  soil,  GV.ramp("#a5663a") },
  { "stem",  stem,  GV.ramp("#2e5a2c"), { gloss = false } },
  { "lleaf", lleaf, leaf },
  { "rleaf", rleaf, leaf },
}
c:paint({ "dd", "dd" }, 21, 49, { d = "#3d2a1c" })
c:paint({ "dd", "dd" }, 41, 49, { d = "#3d2a1c" })
c:paint({ "dd" }, 31, 52, { d = "#3d2a1c" })

local t = c:save(O .. "aseprite/ico/ico-sprout.aseprite", O .. "png/ico/ico-sprout.png")
print(GV.report(t))
