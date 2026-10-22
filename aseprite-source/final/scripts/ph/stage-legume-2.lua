-- ph/stage-legume-2 : soil mound, short sprout with exactly two leaves, bare stake
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local soil  = GV.ramp("#7a4a1f")
local soilT = GV.ramp("#9a6b3f")
local stem  = GV.ramp("#6a9a3a")

c:build{
  { "stake", c:rect(42, 22, 44, 46):add(c:rect(43, 21, 43, 21)), GV.ramp("#8a4f2a"), { flat = true } },
  { "mound", c:ellipse(31.5, 47, 20, 7), soil, { gloss = false } },
  { "top",   c:ellipse(31.5, 45, 15, 3.5), soilT, { gloss = false, contact = false } },
  { "stem",  c:line({ {31, 45}, {31, 38}, {30, 32}, {30, 29} }, 2), stem, { flat = true } },
  { "leafR", c:poly({ {32, 40}, {35, 35}, {40, 32}, {46, 32}, {44, 37}, {39, 41}, {32, 42} }), "moss" },
  { "leafL", c:poly({ {30, 32}, {27, 27}, {22, 24}, {16, 24}, {18, 29}, {24, 33}, {30, 34} }), GV.ramp("#58a03e") },
}
-- leaf midribs
c:line({ {33, 40}, {37, 38}, {41, 36} }, 1)
for _, p in ipairs({ {33,40}, {34,39}, {35,39}, {36,38}, {37,38}, {38,37}, {39,37}, {40,36} }) do c:px(p[1], p[2], "#4a8a3e") end
for _, p in ipairs({ {29,32}, {28,31}, {27,31}, {26,30}, {25,30}, {24,29}, {23,29}, {22,28} }) do c:px(p[1], p[2], "#3f7a35") end
-- soil crumbs
c:paint({ "a.", ".b" }, 22, 44, { a = soilT.rim, b = soil.shade })
c:paint({ "a" }, 38, 46, { a = soilT.rim })
c:paint({ "b" }, 26, 47, { b = soil.shade })

local t = c:save(O .. "aseprite/ph/stage-legume-2.aseprite", O .. "png/ph/stage-legume-2.png")
print(GV.report(t))
