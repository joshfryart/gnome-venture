local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local orange = GV.ramp("#f08a24", { shade = "#d6322b", rim = "#ffc27a" })
-- wide drooping brim
local brim = c:ellipse(31.5, 42, 24, 8)
brim:add(c:ellipse(10, 46, 3, 4)):add(c:ellipse(53, 46, 3, 4))
-- low dome crown
local crown = c:ellipse(31.5, 38, 17, 17):cut(c:rect(0, 40, 63, 63))
-- darker band at the base of the crown, gently curved
local band = crown:copy():clip(c:ellipse(31.5, 46, 22, 14)):cut(c:ellipse(31.5, 49, 22, 12))

local p = c:build{
  { "brim", brim, orange },
  { "crown", crown, orange, { gloss = { 22, 25 } } },
  { "band", band, GV.ramp("#e0501f"), { gloss = false, contour = false } },
}
c:seam({ {15, 40}, {48, 40} })
c:button(30, 34)

local t = c:save(O .. "aseprite/ph/puddle-hat.aseprite", O .. "png/ph/puddle-hat.png")
print(GV.report(t))
