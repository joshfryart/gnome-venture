local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local jar = c:rrect(14, 22, 50, 57, 10)
jar:add(c:rrect(23, 15, 41, 24, 2))
local inner = c:rrect(18, 28, 46, 53, 8)
local cork = c:rrect(21, 6, 43, 17, 3)
local seed = c:ellipse(32, 42, 8.5, 8)
local p = c:build{
  { "jar", jar, GV.ramp("#c8ecdc"), { pale = true } },
  { "inner", inner, GV.ramp("#8fcbd8"), { flat = true, contour = false } },
  { "seed", seed, "water" },
  { "cork", cork, "wood" },
}
-- sprout
c:line({ {32, 34}, {32, 29} }, 2)
c:fill(c:line({ {32, 34}, {32, 29} }, 2), "#58a03e")
c:paint({
  "...ll.",
  ".llLll",
  "llLll.",
  "lll...",
}, 33, 26, { l = "#58a03e", L = "#9ccb5a" })
-- cork grain
c:fill(c:line({ {26, 9}, {33, 9} }, 1), "#8a4f2a")
c:fill(c:line({ {30, 12}, {38, 12} }, 1), "#8a4f2a")
c:fill(c:line({ {25, 14}, {29, 14} }, 1), "#8a4f2a")
-- glass shine
c:fill(c:rect(19, 31, 20, 44), "#e6f7ee")
c:fill(c:rect(19, 47, 20, 48), "#e6f7ee")
c:seam({ {23, 18}, {41, 18} })
c:ground(32, 58, 15, 1.5)
local t = c:save(O .. "aseprite/ph/flamboyant-seed.aseprite", O .. "png/ph/flamboyant-seed.png")
print(GV.report(t))
