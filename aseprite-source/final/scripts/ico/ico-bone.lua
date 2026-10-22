local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local O = D .. "img-redraw-full/"
local bone = GV.ramp("#f8eed2")
local shaft = c:line({ {22, 42}, {42, 22} }, 9)
local lo = c:ellipse(17, 40, 6.5):add(c:ellipse(24, 47, 6.5))
local hi = c:ellipse(40, 17, 6.5):add(c:ellipse(47, 24, 6.5))
local all = shaft:copy():add(lo):add(hi)
c:build{
  { "shaft", shaft, bone, { light = all, gloss = false, cres = 3, deep = 1 } },
  { "lo", lo, bone, { light = all, contour = "#f5b860", gloss = false, cres = 3, deep = 1 } },
  { "hi", hi, bone, { light = all, contour = "#f5b860", cres = 3, deep = 1 } },
}
c:gloss(shaft, bone, { 28, 31 })
local t = c:save(O .. "aseprite/ico/ico-bone.aseprite", O .. "png/ico/ico-bone.png")
print(GV.report(t))
