-- ph/broken-gathering-basket : gathering basket, cracked with snapped weave
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local handle = c:ellipse(33, 36, 15.5, 21):cut(c:ellipse(33, 36, 11.5, 17)):cut(c:rect(0, 37, 63, 63))
local bowl = c:poly({ {13, 36}, {53, 36}, {48, 56}, {18, 56} }):cut(c:rect(18, 55, 19, 55)):cut(c:rect(47, 55, 48, 55))
-- chipped notch out of the upper-right rim
bowl:cut(c:poly({ {45, 36}, {51, 36}, {48, 40} }))
local band1 = c:poly({ {13, 41}, {53, 41}, {52, 44}, {14, 44} }):clip(bowl)
local band2 = c:poly({ {14, 48}, {51, 48}, {50, 51}, {15, 51} }):clip(bowl)
local stubR = c:line({ {46, 52}, {52, 56} }, 2)
local stubL = c:line({ {15, 45}, {10, 48} }, 2)
local knot = c:ellipse(22, 35, 3.5, 3.5)

c:build{
  { "stubL",  stubL,  GV.ramp("#5e2f1e"), { flat = true } },
  { "stubR",  stubR,  GV.ramp("#5e2f1e"), { flat = true } },
  { "handle", handle, "wood" },
  { "bowl",   bowl,   GV.ramp("#b07a45", { shade = "#a8582f" }), { light = bowl:copy():add(handle) } },
  { "band1",  band1,  GV.ramp("#f5cf6a"), { flat = true, contact = false } },
  { "band2",  band2,  GV.ramp("#f5cf6a"), { flat = true, contact = false } },
  { "knot",   knot,   GV.ramp("#8a4f2a"), { gloss = { 21, 34 } } },
}
-- weave ticks
local T = "#5e2f1e"
for _, x in ipairs({ 19, 25, 40, 46 }) do c:fill(c:rect(x, 42, x, 43), T) end
for _, x in ipairs({ 20, 26, 41 }) do c:fill(c:rect(x, 49, x, 50), T) end
-- the crack: dark zigzag from handle top down through the bowl
local crack = c:line({ {30, 15}, {35, 25}, {29, 34}, {36, 43}, {31, 51}, {34, 56} }, 2)
c:fill(crack:clip(handle:copy():add(bowl)), "#2a1a10")

local t = c:save(O .. "aseprite/ph/broken-gathering-basket.aseprite", O .. "png/ph/broken-gathering-basket.png")
print(GV.report(t))
