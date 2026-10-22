local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local legR = GV.ramp("#44281c")
local brown = GV.ramp("#8c4a1a")
-- legs: bent sticks splaying out
c:build{
  { "legBL", c:line({ {14, 40}, {10, 44}, {9, 49} }, 2), legR, { flat = true } },
  { "legML", c:line({ {20, 42}, {17, 46}, {16, 50} }, 2), legR, { flat = true } },
  { "legMR", c:line({ {32, 42}, {36, 46}, {37, 50} }, 2), legR, { flat = true } },
  { "legFR", c:line({ {38, 40}, {43, 44}, {45, 49} }, 2), legR, { flat = true } },
}
-- antennae behind head, sweeping up-right
local ant = c:line({ {46, 24}, {49, 19}, {51, 15} }, 2)
ant:add(c:line({ {43, 23}, {42, 18}, {43, 14} }, 2))
c:part(ant, legR, { flat = true })
c:part(c:rrect(50, 11, 53, 14, 1), legR, { flat = true })
c:part(c:rrect(42, 10, 45, 13, 1), legR, { flat = true })
local p = c:build{
  { "body", c:ellipse(26, 34, 15, 9.5), brown, { stitch = { side = "lit" } } },
  { "plate", c:ellipse(25, 31, 10.5, 5.5), GV.ramp("#a5663a"), { gloss = { 17, 28 } } },
  { "head", c:ellipse(44, 29, 6.5, 6.5), brown, { gloss = { 40, 25 } } },
}
-- wing ridges on the plate
local rid = c:line({ {19, 35}, {23, 29} }, 1)
rid:add(c:line({ {26, 35}, {30, 29} }, 1))
c:fill(rid:clip(p.plate.m:shrink(1)), "#dcb06a")
c:seam({ {15, 29}, {19, 26}, {25, 25}, {31, 26}, {35, 29} })
c:eye(45, 26, true)
c:ground(26, 51, 17, 1.5)
local t = c:save(O .. "aseprite/ph/creature-drumming-cricket.aseprite", O .. "png/ph/creature-drumming-cricket.png")
print(GV.report(t))
