local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local hide = c:poly({
  {12, 14}, {17, 12}, {22, 15}, {27, 12}, {32, 15}, {37, 12}, {42, 15}, {47, 12}, {52, 14},
  {58, 24}, {57, 28}, {50, 33}, {50, 36}, {56, 45}, {54, 49}, {46, 52},
  {42, 54}, {37, 51}, {32, 54}, {27, 51}, {22, 54}, {18, 52},
  {10, 49}, {8, 45}, {14, 36}, {14, 33}, {7, 28}, {6, 24},
})

local p = c:build{
  { "hide", hide, GV.ramp("#7a5cc0"), { stitch = true, gloss = { 22, 21 } } },
}

-- fur curls (bean-like arcs)
local curl = "#4e3a8a"
c:fill(c:line({ {17, 30}, {19, 27}, {22, 26}, {25, 27} }, 2), curl)
c:fill(c:line({ {33, 22}, {36, 20}, {39, 21}, {41, 23} }, 2), curl)
c:fill(c:line({ {37, 41}, {40, 38}, {43, 37}, {46, 38} }, 2), curl)
c:fill(c:line({ {21, 45}, {24, 42}, {27, 41}, {29, 42} }, 2), curl)

local t = c:save(O .. "aseprite/ph/velvet-pelt.aseprite", O .. "png/ph/velvet-pelt.png")
print(GV.report(t))
