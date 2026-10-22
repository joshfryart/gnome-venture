local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local tan = GV.ramp("#c9a96e")
local body = c:ellipse(31.5, 40, 19, 15):cut(c:rect(0, 53, 63, 63))
body:add(c:rrect(16, 44, 47, 53, 5))
local rim = c:ellipse(23, 22, 4.5, 4):add(c:ellipse(31.5, 20, 4.5, 4)):add(c:ellipse(40, 22, 4.5, 4))
rim:add(c:rrect(19, 22, 44, 28, 2))

local p = c:build{
  { "body", body, tan, { stitch = { side = "lit" } } },
  { "rim",  rim,  tan, { light = body } },
}
-- ruffle folds
c:fill(c:line({ {27, 20}, {27, 24} }, 1), tan.shade)
c:fill(c:line({ {36, 20}, {36, 24} }, 1), tan.shade)
c:seam({ {22, 30}, {42, 30} })
-- drawstring
local cord = GV.ramp("#7a4a1f")
c:part(c:rect(20, 27, 43, 28), cord, { flat = true })
c:part(c:line({ {28, 28}, {25, 36} }, 2), cord, { flat = true })
c:part(c:line({ {36, 28}, {40, 35} }, 2), cord, { flat = true })
c:part(c:rrect(23, 36, 26, 39, 1), "gold", { flat = true })
c:part(c:rrect(39, 35, 42, 38, 1), "gold", { flat = true })
-- patch
local patch = c:rrect(26, 34, 41, 49, 4)
c:part(patch, GV.ramp("#f4f0e0"), { gloss = false, stitch = true })
-- plantain crescent
local pl = c:line({ {28, 45}, {31, 46}, {34, 45}, {36, 42}, {37, 39} }, 3)
c:part(pl, GV.ramp("#f5cf6a"), { gloss = { 30, 45 } })
c:fill(c:line({ {29, 47}, {32, 47}, {35, 46} }, 1), "#e8a317")
c:part(c:rect(36, 36, 38, 38), "moss", { flat = true })

local t = c:save(O .. "aseprite/ph/plantain-seed.aseprite", O .. "png/ph/plantain-seed.png")
print(GV.report(t))
