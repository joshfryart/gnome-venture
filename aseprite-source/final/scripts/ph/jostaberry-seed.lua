local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- lid swung open, leaning back (trapezoid, wider at top)
local lid = c:poly({ {11, 7}, {54, 7}, {51, 24}, {14, 24} })
local lidIn = c:poly({ {15, 11}, {50, 11}, {48, 23}, {17, 23} })
local purple = GV.ramp("#4e3a8a", { rim = "#7b66b4" })
local dark = GV.ramp("#3e2f66", { rim = "#7b66b4" })
local box = c:rrect(12, 38, 52, 57, 3)

local parts = {
  { "lid", lid, GV.ramp("#8b8f96") },
}
local berries = {
  { 32, 27, purple }, { 23, 32, dark }, { 41, 32, purple },
  { 20, 39, purple }, { 32, 37, dark }, { 44, 39, dark },
}
for i, b in ipairs(berries) do
  parts[#parts + 1] = { "b" .. i, c:ellipse(b[1], b[2], 6, 6), b[3] }
end
parts[#parts + 1] = { "box", box, GV.ramp("#c9c5bc") }
parts[#parts + 1] = { "rim", c:rect(12, 38, 52, 42), GV.ramp("#8b8f96"), { gloss = false } }

-- inner lid face before berries
local p = c:build({ parts[1] })
c:fill(lidIn, "#5b6470")
local rest = {}
for i = 2, #parts do rest[#rest + 1] = parts[i] end
c:build(rest)

-- sprout from top berry
c:fill(c:line({ {32, 21}, {32, 15} }, 2), "#4a8a3e")
c:fill(c:poly({ {33, 15}, {36, 12}, {41, 13}, {39, 16}, {35, 17} }), "#58a03e")
c:px(37, 13, "#a4d86a"); c:px(38, 13, "#a4d86a")

-- hinge rivets, rim seam, latch button
c:fill(c:rrect(14, 39, 17, 42, 1), "#5b6470"); c:px(15, 40, "#c9c5bc")
c:fill(c:rrect(47, 39, 50, 42, 1), "#5b6470"); c:px(48, 40, "#c9c5bc")
c:seam({ {19, 40}, {45, 40} }, { free = true })
c:button(30, 46)
c:ground(32, 58, 18, 1.5)

local t = c:save(O .. "aseprite/ph/jostaberry-seed.aseprite", O .. "png/ph/jostaberry-seed.png")
print(GV.report(t))
