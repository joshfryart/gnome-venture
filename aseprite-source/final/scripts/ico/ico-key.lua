local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local ring = c:ellipse(19, 30, 11, 11):cut(c:ellipse(19, 30, 4.5, 4.5))
local shaft = c:rrect(28, 27, 54, 33, 2)
local teeth = c:rect(40, 32, 46, 44):add(c:rect(49, 32, 54, 40))
local whole = ring:copy():add(shaft):add(teeth)

local p = c:build{
  { "teeth", teeth, "gold", { light = whole, gloss = false } },
  { "shaft", shaft, "gold", { light = whole } },
  { "bow",   ring,  "gold", { light = whole } },
  { "collar", c:rrect(30, 25, 34, 35, 1), GV.ramp("#d0862a") , { gloss = false } },
}
-- engraved notch on the bit
c:fill(c:rect(47, 34, 48, 40), GV.R.gold.deep)
local t = c:save(O .. "aseprite/ico/ico-key.aseprite", O .. "png/ico/ico-key.png")
print(GV.report(t))
