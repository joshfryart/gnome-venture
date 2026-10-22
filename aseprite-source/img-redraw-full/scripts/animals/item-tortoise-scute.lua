local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local outer = c:poly({ {32,7}, {53,19}, {53,44}, {32,57}, {11,44}, {11,19} })
local inner = c:poly({ {32,19}, {43,25}, {43,38}, {32,45}, {21,38}, {21,25} })
local amber = GV.ramp("#b99346")
local core = GV.ramp("#8c6a28")

local p = c:build{
  { "outer", outer, amber, { gloss = { 18, 20 } } },
  { "inner", inner, core, { gloss = false } },
}
-- six spokes (2px) joining the inner hexagon to the outer corners
local sp = "#6b4f1a"
local spokes = {
  { {31,10}, {31,19} },
  { {50,20}, {43,25} },
  { {50,42}, {43,38} },
  { {31,54}, {31,45} },
  { {12,42}, {20,38} },
  { {12,20}, {20,25} },
}
for _, s in ipairs(spokes) do c:fill(c:line(s, 2):clip(outer):cut(inner), sp) end
-- concentric growth ring inside the core
local ring = c:poly({ {32,25}, {38,28}, {38,35}, {32,39}, {26,35}, {26,28} }):edge()
c:fill(ring, "#6b4f1a")
-- lit ridge on the upper-left facet
c:fill(c:line({ {24,24}, {31,20} }, 2):cut(inner), "#e6cf8a")
c:fill(c:line({ {15,26}, {15,34} }, 1), "#e6cf8a")

local t = c:save(O .. "aseprite/animals/item-tortoise-scute.aseprite", O .. "png/animals/item-tortoise-scute.png")
print(GV.report(t))
