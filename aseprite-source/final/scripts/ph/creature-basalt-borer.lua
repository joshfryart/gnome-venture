local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- legs (back)
c:limb({ {14,36}, {11,41}, {8,43} })
c:limb({ {22,38}, {21,43}, {19,45} })
c:limb({ {30,38}, {32,43}, {35,45} })
-- body: long banded grub
local body = c:ellipse(23, 31, 14, 8.5)
-- drill: steel cone pointing right, slightly down
local drill = c:poly({ {43,24}, {47,24}, {57,34}, {57,34}, {47,42}, {43,42} })
local head = c:ellipse(40, 30, 7, 7)
local p = c:build{
  { "body", body, GV.ramp("#9a7447") },
  { "drill", drill, GV.ramp("#6e7685") },
  { "head", head, GV.ramp("#6b4a2c") },
}
-- segment bands (curved, 2px, dark)
for _, x in ipairs({ 14, 19, 24, 29 }) do
  local m = c:line({ {x+1,24}, {x,28}, {x,34}, {x+1,38} }, 2):clip(p.body.m)
  m:cut(head)
  c:fill(m, "#2a1a10")
end
-- back sheen
c:paint({ "..xxxxxxxxxx", "xx.........." }, 12, 25, { x = "#8f7fc9" })
-- drill spiral grooves
for _, x in ipairs({ 48, 51, 54 }) do
  local g = c:line({ {x,27}, {x+2,40} }, 1):clip(p.drill.m):cut(head)
  c:fill(g, "#2f3440")
end
-- antennae with club tips
c:fill(c:line({ {41,24}, {42,20}, {44,17} }, 2), "#2a1a10")
c:fill(c:line({ {37,24}, {35,20}, {34,17} }, 2), "#2a1a10")
c:fill(c:rrect(43,14,46,17,1), "#2a1a10")
c:fill(c:rrect(32,14,35,17,1), "#2a1a10")
c:eye(40, 27, true)
c:seam({ {22,24}, {21,30}, {22,38} })
c:ground(28, 46, 16, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/creature-basalt-borer.aseprite", D .. "img-redraw-full/png/ph/creature-basalt-borer.png")
print(GV.report(t))
