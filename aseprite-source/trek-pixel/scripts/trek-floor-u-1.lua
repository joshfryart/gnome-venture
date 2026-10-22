-- trek-floor-u-1: cave floor, two flat pebbles on warm dark earth (underground colour master)
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/trek-pixel/"
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }

local su = { g = "#b88850", r = "#a06c3c", b = "#8a5a30", n = "#6e4426", s = "#5c3520", d = "#33221a" }
local U2 = "#4a2c1a"

c:fill(c:rect(0, 0, 41, 41), su.b)

-- pebble 1: 7x5 oval x9..15 y12..16, su_shade body, lit rim above, umber2 lower-right
c:paint({
  ".rrrr..",   -- y11 rim lip above the top edge
  ".sssss.",   -- y12
  "sgssssu",   -- y13
  "ssssssu",   -- y14
  "sssssuu",   -- y15
  ".uuuuu.",   -- y16
}, 9, 11, { r = su.r, s = su.s, g = su.g, u = U2 })

-- pebble 2: 6x4 oval x25..30 y27..30, su_bounce body
c:paint({
  "..rrr.",    -- y26
  ".nnnnn",    -- y27 (slightly lop-sided: a flatter, tipped stone)
  "ngnnnu",    -- y28
  "nnnnuu",    -- y29
  ".uuuu.",    -- y30
}, 25, 26, { r = su.r, n = su.n, g = su.g, u = U2 })

-- flecks
for _, p in ipairs({ {20,10}, {32,16}, {14,30}, {36,34} }) do c:px(p[1], p[2], su.r) end
for _, p in ipairs({ {22,22}, {9,24} }) do c:px(p[1], p[2], su.d) end

local t = c:save(R .. "aseprite/trek-floor-u-1.aseprite", R .. "png/trek-floor-u-1.png")
print(GV.report(t))
