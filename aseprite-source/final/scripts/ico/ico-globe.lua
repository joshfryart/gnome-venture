local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local sphere = c:ellipse(31.5, 31, 25, 25)
local ocean = GV.ramp("#3f93b2", { shade = "#2f6290" })
c:part(sphere, ocean, { gloss = false })
-- upper-left glaze band
local glaze = sphere:copy():cut(sphere:shift(3, 3)):cut(sphere:copy():cut(sphere:shrink(1)))
c:fill(glaze, "#5fb0c8")

local inner = sphere:shrink(3)
local A = c:ellipse(21, 23, 7, 6):add(c:ellipse(17, 30, 4, 4)):add(c:rect(24, 18, 29, 24)):clip(inner)
local B = c:ellipse(43, 40, 6, 7):add(c:ellipse(39, 47, 4, 3)):add(c:rect(46, 32, 50, 37)):clip(inner)
local C = c:ellipse(41, 13, 7, 4):add(c:rect(44, 15, 48, 19)):clip(inner)

c:build{
  { "C", C, GV.ramp("#58a03e"), { light = sphere, gloss = false } },
  { "A", A, GV.ramp("#58a03e"), { light = sphere, gloss = false } },
  { "B", B, GV.ramp("#7ab55c"), { light = sphere, gloss = false } },
}

local eq = c:line({ {8, 31}, {16, 34}, {24, 36}, {32, 37}, {40, 36}, {48, 34}, {55, 31} }, 1)
eq:clip(sphere:shrink(2)):cut(A:grow(1)):cut(B:grow(1)):cut(C:grow(1))
c:fill(eq, "#256a80")

c:gloss(sphere, ocean, { 18, 14 })

local t = c:save(O .. "aseprite/ico/ico-globe.aseprite", O .. "png/ico/ico-globe.png")
print(GV.report(t))
