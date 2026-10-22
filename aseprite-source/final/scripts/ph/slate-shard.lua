local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- wide low shield: domed top, pointed bottom
local slab = c:ellipse(32, 40, 22, 19):clip(c:rect(0, 0, 63, 40))
slab:add(c:poly({ {10, 40}, {55, 40}, {33, 53}, {31, 53} }))
-- chip notch bitten out at the top left
slab:cut(c:ellipse(16, 27, 3, 2.5))
local facet = c:poly({ {33, 53}, {55, 40}, {48, 40}, {38, 45} }):clip(slab)
local p = c:build{
  { "slab",  slab,  GV.ramp("#f08a24"), { gloss = { 23, 29 } } },
  { "facet", facet, GV.ramp("#b8452f"), { light = slab, gloss = false } },
}
-- curved cleavage seam
c:fill(c:line({ {19, 39}, {25, 35}, {32, 33}, {39, 35}, {45, 39} }, 2):clip(p.slab.m:shrink(2)), "#e0501f")
c:fill(c:line({ {20, 41}, {25, 37}, {32, 35}, {39, 37}, {44, 41} }, 1):clip(p.slab.m:shrink(2)), "#b8452f")
c:ground(32, 55, 12, 1.5)

local t = c:save(O .. "aseprite/ph/slate-shard.aseprite", O .. "png/ph/slate-shard.png")
print(GV.report(t))
