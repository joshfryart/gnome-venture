local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local steel = GV.ramp("#968f96")
-- eight teeth: cardinal blocks plus rotated diagonal blocks
local teeth = c:rect(28, 9, 35, 16):add(c:rect(28, 47, 35, 54))
teeth:add(c:rect(47, 28, 54, 35)):add(c:rect(9, 28, 16, 35))
local function diag(cx, cy)
  return c:poly({ {cx, cy - 6}, {cx + 6, cy}, {cx, cy + 6}, {cx - 6, cy} })
end
teeth:add(diag(45.5, 18.5)):add(diag(45.5, 45.5)):add(diag(18.5, 18.5)):add(diag(18.5, 45.5))
local hole = c:ellipse(31.5, 31.5, 7.5)
local ring = c:ellipse(31.5, 31.5, 18):cut(hole)
local whole = ring:copy():add(teeth)
teeth:cut(hole)
c:build{
  { "teeth", teeth, steel, { light = whole, gloss = false } },
  { "ring",  ring,  steel, { light = whole } },
}
-- 2px umber inner rim around the hole
local rim = hole:grow(2):cut(hole)
c:fill(rim, GV.C.umber)
local t = c:save(O .. "aseprite/ico/ico-cog.aseprite", O .. "png/ico/ico-cog.png")
print(GV.report(t))
