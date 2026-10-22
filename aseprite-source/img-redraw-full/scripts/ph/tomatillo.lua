local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fruit = c:ellipse(31.5, 37, 18, 17)
local stem = c:rrect(30, 13, 33, 22, 1)
local leaf = c:poly({ {33,19}, {41,6}, {44,12} }):add(c:ellipse(39.5, 13, 4, 3.5)):add(c:poly({ {33,19}, {40,7}, {37,15} }))
c:build{
  { "stem",  stem,  "#2f5a2a", { flat = true } },
  { "leaf",  leaf,  GV.ramp("#a4b86a", { shade = "#4a8a3e" }) },
  { "fruit", fruit, "moss", { gloss = { 23, 27 } } },
}
-- husk line curving across the belly
c:line({ {16,39}, {24,35}, {32,34}, {40,35}, {47,38} }, 1):each(function(x, y)
  if fruit:shrink(1):has(x, y) then c:px(x, y, "#2f5a2a") end
end)
-- husk lower band: shade the area under the husk line within the fruit (keep crescent pixels)
local M = GV.ramp("moss")
local under = c:poly({ {16,40}, {24,36}, {32,35}, {40,36}, {48,39}, {48,64}, {15,64} }):clip(fruit:shrink(2))
under:each(function(x, y) if c:get(x, y) == M.base then c:px(x, y, "#6a9a3a") end end)
-- leaf vein
c:line({ {35,17}, {41,9} }, 1):each(function(x, y) if leaf:has(x, y) then c:px(x, y, "#6a8a3a") end end)
local t = c:save(O .. "aseprite/ph/tomatillo.aseprite", O .. "png/ph/tomatillo.png")
print(GV.report(t))
