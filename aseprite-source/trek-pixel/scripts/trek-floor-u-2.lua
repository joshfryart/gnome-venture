-- trek-floor-u-2: cave floor with angular slate chips and a damp drip stain
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/trek-pixel/"
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }

local su = { g = "#b88850", r = "#a06c3c", b = "#8a5a30", s = "#5c3520", d = "#33221a" }
local U2, WARIM = "#4a2c1a", "#a9d6ea"
local L = { g = su.g, r = su.r, u = U2, s = su.s, d = su.d, w = WARIM }

c:fill(c:rect(0, 0, 41, 41), su.b)

-- drip stain: flat damp blotch x24..32 y22..27, deep pixels lower-right, drop above
c:paint({
  "..sssss..",  -- y22
  ".sssssss.",  -- y23
  "sssssssss",  -- y24
  "ssssssss.",  -- y25
  ".sssssssd",  -- y26
  "...sssdd.",  -- y27
}, 24, 22, L)
c:px(28, 19, WARIM); c:px(28, 20, WARIM)   -- the two-pixel drip

-- chip 1: 5x4 wedge, right angle up-left, umber2 along the lower-right diagonal
c:paint({
  "grrru",      -- y26
  "rrru.",      -- y27
  "rru..",      -- y28
  "ru...",      -- y29
}, 10, 26, L)
-- chip 2: 4x4 slanted shard
c:paint({
  "grr.",       -- y29
  "rrru",       -- y30
  ".rru",       -- y31
  "..u.",       -- y32
}, 17, 29, L)
-- chip 3: 3x3 flake
c:paint({
  "gr.",        -- y13
  "rru",        -- y14
  ".uu",        -- y15
}, 27, 13, L)

-- hairline crack
for x = 6, 11 do c:px(x, 8, su.d) end
c:px(12, 9, su.d); c:px(13, 10, su.d)
for x = 14, 18 do c:px(x, 10, su.d) end

-- flecks
for _, p in ipairs({ {33,9}, {8,18}, {21,36} }) do c:px(p[1], p[2], su.g) end

local t = c:save(R .. "aseprite/trek-floor-u-2.aseprite", R .. "png/trek-floor-u-2.png")
print(GV.report(t))
