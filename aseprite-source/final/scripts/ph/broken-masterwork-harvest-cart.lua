local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- box (gold trapezoid) with a notch where the crack splits the top edge
local box = c:poly({ {11,21}, {43,21}, {36,41}, {17,41} })
box:cut(c:poly({ {26,21}, {30,21}, {28,25} }))
-- shafts
local upper = c:line({ {38,25}, {52,17} }, 4)
local lowerA = c:line({ {30,38}, {42,43} }, 4)
local lowerB = c:line({ {46,46}, {52,50} }, 4)          -- snapped piece, dropped
local splinter = c:line({ {43,49}, {45,50} }, 2)
-- dangling loose plank at left
local plank = c:line({ {14,35}, {10,43} }, 2)
-- wheel with chipped wedge lower-right
local wheel = c:ellipse(21, 45, 8, 8)
wheel:cut(c:poly({ {25,49}, {31,48}, {31,55}, {27,55} }))
local p = c:build{
  { "upper",  upper,  "wood" },
  { "lowerA", lowerA, "wood" },
  { "lowerB", lowerB, "wood" },
  { "splint", splinter, "wood", { flat = true } },
  { "plank",  plank,  "wood", { flat = true } },
  { "box",    box,    "gold" },
  { "wheel",  wheel,  GV.ramp("#5e2f1e") },
}
-- light top edges on shafts
c:line({ {39,24}, {51,17} }, 1):each(function(x, y) if upper:has(x, y) and not box:has(x, y) then c:px(x, y, "#f0d49a") end end)
c:line({ {44,40}, {42,41} }, 1)
-- seam along box top
c:seam({ {13,24}, {41,24} })
-- jagged crack through the box
local crack = c:line({ {28,23}, {30,27}, {27,31}, {30,35}, {28,40} }, 2):clip(box)
c:fill(crack, "#2a1a10")
-- wheel: spokes and hub
c:fill(c:line({ {21,39}, {21,51} }, 1):clip(wheel:shrink(2)), "#8a4f2a")
c:fill(c:line({ {15,45}, {27,45} }, 1):clip(wheel:shrink(2)), "#8a4f2a")
c:fill(c:ellipse(21, 45, 2.5, 2.5), "#b07a10")
c:px(20, 44, "#f5cf6a")
c:ground(30, 54, 16, 1.5)
local t = c:save(D .. "img-redraw-hybrid/aseprite/ph/broken-masterwork-harvest-cart.aseprite",
                 D .. "img-redraw-hybrid/png/ph/broken-masterwork-harvest-cart.png")
print(GV.report(t))
