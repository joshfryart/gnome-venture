local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- arch frame: two posts + rounded top (inverted U)
local outer = c:rrect(19, 9, 44, 44, 9)
local inner = c:rrect(23, 13, 40, 44, 6)
local frame = outer:copy():cut(inner)

-- stone well body: top ellipse + wall + rounded bottom
local stone = c:ellipse(31.5, 37, 21.5, 7)
stone:add(c:rect(10, 37, 53, 47))
stone:add(c:ellipse(31.5, 47, 21.5, 6))
local water = c:ellipse(31.5, 37, 16.5, 4)

local bucket = c:rrect(28, 26, 35, 33, 2)
bucket:add(c:rect(27, 26, 36, 27))

local p = c:build{
  { "frame", frame, "wood", { cres = 2, deep = 1 } },
  { "stone", stone, GV.ramp("#8b8f96") },
  { "water", water, GV.ramp("#3f8fb0"), { gloss = false, contact = false } },
}
-- rope from the arch to the bucket
c:part(c:rect(31, 13, 32, 25), GV.ramp("#d9a660"), { flat = true })
local b = c:part(bucket, GV.ramp("#a8582f"), { gloss = { 29, 28 } })
c:fill(c:rect(28, 30, 35, 30), "#e8a317")

-- water lit ripple at upper left
c:paint({ "ww.www", }, 20, 35, { w = "#c8ecdc" })
c:paint({ "ww" }, 38, 38, { w = "#8fcbd8" })
-- stone block mortar lines
local m = "#5b6470"
c:fill(c:rect(11, 45, 52, 45), m)
for _, x in ipairs({ 17, 27, 37, 47 }) do c:fill(c:rect(x, 41, x, 44), m) end
for _, x in ipairs({ 22, 32, 42 }) do c:fill(c:rect(x, 46, x, 50), m) end

-- seam across the arch top and a button where the rope hangs
c:seam({ { 24, 11 }, { 39, 11 } })
c:button(30, 9)
c:ground(31.5, 54, 18, 1.5)

local t = c:save(O .. "aseprite/ph/wishing-well.aseprite", O .. "png/ph/wishing-well.png")
print(GV.report(t))
