-- trek-chasm-1: a drop into darkness, round pit + two thin chasm-ripple arcs (family 3)
local ROOT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(ROOT .. "gvlib/gvlib.lua")
local OUT = ROOT .. "trek-pixel/"
local NAME = "trek-chasm-1"

local ch = { gloss = "#2d6479", rim = "#24556b", base = "#143645", shade = "#0e2433", deep = "#091623" }

local c = GV.canvas{ w = 42, h = 42, mode = "scene" }
c:fill(c:rect(0, 0, 41, 41), ch.base)

-- Pit: stepped oval 18x11 (x12..29, y10..20) in shade, inner 10x5 (x16..25, y13..17) in deep
local pit = c:ellipse(20.5, 15, 8.5, 5)
c:fill(pit, ch.shade)
c:fill(c:ellipse(20.5, 15, 4.5, 2), ch.deep)

-- Wave arcs (chasm_rip): 1 px ch_gloss, rising 2 px; ch_rim under the first half
local function arc(pts, underTo)
  for _, p in ipairs(pts) do
    c:px(p[1], p[2], ch.gloss)
    if p[1] <= underTo then c:px(p[1], p[2] + 1, ch.rim) end
  end
end
-- arc 1: (8,23) .. (20,23), top y=21
local a1 = { {8,23}, {9,22}, {10,22} }
for x = 11, 17 do a1[#a1+1] = {x,21} end
a1[#a1+1] = {18,22}; a1[#a1+1] = {19,22}; a1[#a1+1] = {20,23}
arc(a1, 14)
-- arc 2: (22,32) .. (33,32), top y=30
local a2 = { {22,32}, {23,31}, {24,31} }
for x = 25, 30 do a2[#a2+1] = {x,30} end
a2[#a2+1] = {31,31}; a2[#a2+1] = {32,31}; a2[#a2+1] = {33,32}
arc(a2, 27)

-- speckles
for _, p in ipairs({ {6,12}, {34,17}, {15,36} }) do c:px(p[1], p[2], ch.rim) end

local t = c:save(OUT .. "aseprite/" .. NAME .. ".aseprite", OUT .. "png/" .. NAME .. ".png")
print(NAME .. ": " .. GV.report(t))
