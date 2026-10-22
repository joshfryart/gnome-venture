local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- roots fanning down
local roots = c:line({ {30, 46}, {27, 51} }, 3)
roots:add(c:line({ {32, 46}, {32, 52} }, 3))
roots:add(c:line({ {34, 46}, {37, 51} }, 3))
-- teardrop bulb: round belly tapering to a pinched shoulder
local bulb = c:ellipse(31.5, 35, 16, 12)
bulb:add(c:poly({ {19, 31}, {27, 21}, {37, 21}, {45, 31} }))
local neck = c:poly({ {27, 23}, {31, 13}, {33, 13}, {38, 23} })
local p = c:build{
  { "roots", roots, GV.ramp("#ecc58a"), { flat = true } },
  { "bulb",  bulb, "gold", { light = bulb } },
  { "neck",  neck, GV.ramp("#d9a660"), { gloss = false } },
}
-- sprout tip
c:part(c:line({ {31, 13}, {33, 11} }, 3), GV.ramp("#a4b86a"), { flat = true })
-- papery layer ribs (curved), clipped to bulb
local rib = "#b07a45"
local function rib_curve(pts)
  local m = c:line(pts, 2); m:clip(p.bulb.m:shrink(2)); c:fill(m, rib)
end
rib_curve({ {27, 24}, {23, 29}, {21, 35}, {22, 41}, {25, 45} })
rib_curve({ {36, 24}, {40, 29}, {42, 35}, {41, 41}, {38, 45} })
rib_curve({ {32, 25}, {32, 45} })
local t = c:save(O .. "aseprite/ico/ico-onion.aseprite", O .. "png/ico/ico-onion.png")
print(GV.report(t))
