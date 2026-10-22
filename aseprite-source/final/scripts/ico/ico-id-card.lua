local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local teal = GV.ramp("#3f93b2")
local spineR = GV.ramp("#256a80")
local cover = c:rrect(15, 9, 49, 55, 3)
local spine = c:rrect(15, 9, 21, 55, 2)
local p = c:build{
  { "cover", cover:copy():cut(c:rect(15, 9, 19, 55)), teal, { light = cover } },
  { "spine", spine, spineR, { gloss = false, light = cover } },
  { "globe", c:ellipse(35, 23.5, 8.5, 8.5), "gold" },
  { "bar1", c:rect(25, 36, 44, 39), "gold", { flat = true } },
  { "bar2", c:rect(25, 42, 37, 45), "gold", { flat = true } },
  { "stamp", c:ellipse(44, 48, 6, 6), GV.ramp("#d6322b") },
}
-- globe lines
local L = "#b07a10"
for x = 28, 42 do if p.globe.m:has(x, 24) then c:px(x, 24, L) end end
local mer = c:ellipse(35, 23.5, 3.5, 8.5):edge()
mer:each(function(x, y) if p.globe.m:has(x, y) and not p.globe.m:edge():has(x, y) then c:px(x, y, L) end end)
-- stamp inner ring
local ring = c:ellipse(44, 48, 3.5, 3.5):edge()
ring:each(function(x, y) c:px(x, y, "#f4f0e0") end)
c:seam({ { 21, 12 }, { 21, 52 } }, { free = true })
local t = c:save(O .. "aseprite/ico/ico-id-card.aseprite", O .. "png/ico/ico-id-card.png")
print(GV.report(t))
