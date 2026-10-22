local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local L, D = GV.ramp("#d6c9b6"), GV.ramp("#968f96")
local parts = {}
-- horizontal arm stones (left and right of the cap)
local xs = { 8, 15, 41, 49 }
local ws = { 7, 7, 7, 7 }
local k = 0
for i, x0 in ipairs(xs) do
  k = k + 1
  local y0 = 20
  parts[#parts + 1] = { "a" .. i, c:rrect(x0, y0, x0 + ws[i], 32, 3), (k % 2 == 1) and L or D }
end
-- stem stones
local ys = { { 33, 40 }, { 41, 48 }, { 49, 55 } }
for i, yy in ipairs(ys) do
  parts[#parts + 1] = { "s" .. i, c:rrect(25, yy[1], 38, yy[2], 3), (i % 2 == 1) and D or L }
end
-- joint cap (raised) and its top
parts[#parts + 1] = { "cap", c:rrect(22, 15, 41, 34, 4), GV.ramp("#6a6070") }
parts[#parts + 1] = { "top", c:rrect(25, 17, 37, 29, 3), D, { gloss = { 27, 19 } } }
c:build(parts)

local t = c:save(O .. "aseprite/ph/stone-wall-tee.aseprite", O .. "png/ph/stone-wall-tee.png")
print(GV.report(t))
