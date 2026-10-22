local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local burlap = GV.ramp("#c9a96e", { shade = "#9a6b3f" })
local twine = GV.ramp("#7a4a1f")
-- slumped sack: wide lumpy bottom, narrowing shoulders
local body = c:ellipse(32, 44, 18, 13):add(c:ellipse(32, 33, 13, 9))
body:add(c:rrect(14, 44, 50, 55, 6))
local neck = c:poly({ {25, 12}, {39, 12}, {41, 25}, {23, 25} })
local fray = c:rrect(21, 10, 26, 15, 1):add(c:rrect(29, 7, 34, 13, 1)):add(c:rrect(37, 9, 42, 14, 1))
local wrap = c:rrect(22, 22, 42, 25, 1)
local patch = c:ellipse(32, 42, 9)
local p = c:build{
  { "body",  body,  burlap, { stitch = { side = "lit" } } },
  { "fray",  fray,  burlap, { flat = true } },
  { "neck",  neck,  burlap, { gloss = false } },
  { "wrap",  wrap,  twine,  { gloss = false } },
  { "patch", patch, "#7ab55c" },
}
-- frayed rim ticks
c:paint({ "s.s.s..s.s.s" }, 26, 14, { s = "#9a6b3f" })
-- neck crinkles
c:fill(c:line({ {29, 15}, {29, 20} }, 2), "#9a6b3f")
c:fill(c:line({ {35, 15}, {35, 20} }, 2), "#9a6b3f")
-- dangling twine ends
c:fill(c:line({ {29, 26}, {26, 30} }, 2), "#7a4a1f")
c:fill(c:line({ {35, 26}, {38, 30} }, 2), "#7a4a1f")
-- burlap weave ticks
c:fill(c:line({ {44, 47}, {45, 49} }, 2), "#9a6b3f")
c:fill(c:line({ {20, 37}, {21, 39} }, 2), "#9a6b3f")
-- poppy pod motif on the patch
c:fill(c:line({ {32, 43}, {32, 48} }, 2), "#2e5a2c")
c:fill(c:ellipse(32.5, 40, 3, 3.5), "#2e5a2c")
c:fill(c:ellipse(32.5, 40, 2, 2.5), "#58a03e")
c:fill(c:rect(34, 45, 37, 46), "#58a03e")
c:px(32, 39, "#c8d77a")
-- seam down the left side and a button on the knot
c:seam({ {17, 31}, {16, 42}, {17, 54} })
c:button(30, 22)
local t = c:save(O .. "aseprite/ph/california-poppy-seed.aseprite", O .. "png/ph/california-poppy-seed.png")
print(GV.report(t))
