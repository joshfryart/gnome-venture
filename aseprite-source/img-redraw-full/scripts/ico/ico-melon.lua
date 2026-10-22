local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local melon = c:ellipse(25, 28, 17, 16)
local rind = c:ellipse(39, 39, 16, 15):cut(c:rect(0, 0, 63, 38))
local flesh = c:ellipse(39, 39, 12, 11):cut(c:rect(0, 0, 63, 38))

local p = c:build{
  { "melon", melon, GV.ramp("#58a03e") },
}
-- curved stripes, clipped to melon
local deep = "#2e5a2c"
local stripes = c:line({ {16, 15}, {12, 23}, {11, 31}, {14, 40} }, 3)
stripes:add(c:line({ {25, 12}, {24, 22}, {24, 34}, {25, 44} }, 3))
stripes:add(c:line({ {34, 15}, {37, 23}, {38, 31}, {35, 40} }, 3))
stripes:clip(melon:shrink(1))
c:fill(stripes, deep)
-- regloss over stripes
c:gloss(p.melon.m, p.melon.r)
-- stem nub
c:fill(c:rect(24, 10, 26, 12), "#8a4f2a")

local q = c:build{
  { "rind",  rind, GV.ramp("#58a03e") },
  { "flesh", flesh, GV.ramp("#f0f0c0"), { gloss = { 30, 40 } } },
}
c:fill(c:rect(33, 42, 34, 43), "#2a1a10")
c:fill(c:rect(39, 45, 40, 46), "#2a1a10")
c:fill(c:rect(45, 42, 46, 43), "#2a1a10")
local t = c:save(O .. "aseprite/ico/ico-melon.aseprite", O .. "png/ico/ico-melon.png")
print(GV.report(t))
