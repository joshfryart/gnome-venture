-- ico/ico-basket : wicker basket with tall arched handle
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local handle = c:ellipse(32, 36, 17.5, 23):cut(c:ellipse(32, 36, 13.5, 19)):cut(c:rect(0, 37, 63, 63))
local bowl = c:poly({ {11, 36}, {54, 36}, {49, 57}, {16, 57} }):cut(c:rect(16, 57, 17, 57)):cut(c:rect(48, 57, 49, 57))
local band1 = c:poly({ {12, 41}, {53, 41}, {52, 44}, {13, 44} }):clip(bowl)
local band2 = c:poly({ {13, 49}, {52, 49}, {51, 52}, {14, 52} }):clip(bowl)
local rim = c:rrect(10, 33, 54, 38, 2)
local knot = c:ellipse(18, 35, 4, 4)

c:build{
  { "handle", handle, "wood" },
  { "bowl",   bowl,   "wood", { light = bowl:copy():add(handle) } },
  { "band1",  band1,  GV.ramp("#f5cf6a"), { flat = true, contact = false } },
  { "band2",  band2,  GV.ramp("#f5cf6a"), { flat = true, contact = false } },
  { "rim",    rim,    GV.ramp("#d9a660"), { gloss = { 14, 34 } } },
  { "knot",   knot,   GV.ramp("#8a4f2a"), { gloss = { 16, 33 } } },
}
-- weave ticks: vertical slats crossing the gold bands
local T = "#5e2f1e"
for _, x in ipairs({ 20, 27, 34, 41, 48 }) do
  c:fill(c:rect(x, 42, x, 43), T)
  c:fill(c:rect(x - 3, 50, x - 3, 51), T)
end
for _, x in ipairs({ 24, 31, 38, 45 }) do c:fill(c:rect(x, 46, x, 47), T); c:fill(c:rect(x - 2, 55, x - 2, 56), T) end
c:seam({ {22, 36}, {52, 36} })

local t = c:save(O .. "aseprite/ico/ico-basket.aseprite", O .. "png/ico/ico-basket.png")
print(GV.report(t))
