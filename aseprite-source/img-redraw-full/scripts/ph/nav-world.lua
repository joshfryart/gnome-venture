local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local sphere = c:ellipse(31.5, 31.5, 23.5, 23.5)
local ul = c:poly({ {13, 22}, {20, 13}, {29, 15}, {33, 23}, {26, 28}, {23, 37}, {16, 34}, {12, 28} }):clip(sphere)
local rt = c:poly({ {36, 30}, {46, 26}, {51, 33}, {49, 45}, {41, 50}, {36, 42} }):clip(sphere)
local cap = c:poly({ {33, 9}, {42, 9}, {47, 15}, {40, 18}, {34, 14} }):clip(sphere)

c:build{
  { "ocean", sphere, "water", { gloss = { 14, 40 } } },
  { "ul",  ul,  GV.ramp("#58a03e"), { light = sphere, gloss = false } },
  { "rt",  rt,  GV.ramp("#7ab55c"), { light = sphere, gloss = false } },
  { "cap", cap, GV.ramp("#58a03e"), { light = sphere, gloss = false } },
}
-- equator curve on ocean only
local eq = c:line({ {10, 32}, {20, 35}, {32, 37}, {44, 35}, {53, 32} }, 1):clip(sphere):cut(ul):cut(rt)
c:fill(eq, "#256a80")

local t = c:save(O .. "aseprite/ph/nav-world.aseprite", O .. "png/ph/nav-world.png")
print(GV.report(t))
