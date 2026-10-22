local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wood = GV.ramp("#b6814d", { rim = "#f0d49a" })
-- lower segment (thicker butt) and upper segment, snapped apart with jagged ends
local lower = c:line({ {12, 53}, {26, 37} }, 6)
lower:add(c:poly({ {24, 34}, {27, 31}, {28, 35}, {31, 35}, {29, 39}, {26, 40} }))
local upper = c:line({ {37, 27}, {50, 13} }, 4)
upper:add(c:poly({ {33, 28}, {36, 24}, {40, 27}, {37, 31}, {36, 29} }))
local p = c:build{
  { "lower", lower, wood },
  { "upper", upper, wood },
  { "line",  c:line({ {50, 12}, {53, 18}, {54, 25}, {52, 32} }, 2), "#8b8f96", { flat = true } },
  { "bobber", c:ellipse(51.5, 36, 3.5, 3.5), "red", { gloss = { 50, 34 } } },
  { "reel",  c:ellipse(19, 45, 5, 5), "#a5663a", { gloss = { 17, 43 } } },
  { "chipA", c:line({ {41, 45}, {45, 48} }, 2), wood, { flat = true } },
  { "chipB", c:line({ {12, 36}, {9, 38} }, 2), wood, { flat = true } },
}
-- bobber band, reel hub and handle
c:paint({ "ccccc" }, 49, 36, { c = "#f1ece0" })
c:paint({ "hh", "hh" }, 18, 44, { h = "#5e2f1e" })
c:paint({ "k.k", ".k." }, 26, 36, { k = "#5e2f1e" }); c:paint({ ".k.", "k.k" }, 35, 26, { k = "#5e2f1e" })
c:seam({ {14, 50}, {22, 41} })
local t = c:save(O .. "aseprite/ph/broken-willow-fishing-rod.aseprite", O .. "png/ph/broken-willow-fishing-rod.png")
print(GV.report(t))
