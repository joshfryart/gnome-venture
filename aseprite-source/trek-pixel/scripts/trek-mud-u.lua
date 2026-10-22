-- trek-mud-u: underground mud, two dark holes (map key) and drip arcs round the larger one
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/trek-pixel/"
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }

local MUD, MSH, S900 = "#7a4a1f", "#5c3520", "#3d2a1c"
local SOB, SOBN = "#9a6b3f", "#8b5a31"          -- so_base (wet lip), so_bounce (drip arc)
local WARIM, WAGL = "#a9d6ea", "#c8ecdc"

c:fill(c:rect(0, 0, 41, 41), MUD)

-- dot 1: 6x6 cut corners x13..18 y13..18; shaded inner wall upper-left, wet lip lower-right outside
c:paint({
  ".hhho..",   -- y13 (x13..19)
  "hooooo.",
  "hoooooL",
  "hoooooL",
  "ooooooL",
  ".ooooL.",   -- y18
  "..LLL..",   -- y19
}, 13, 13, { o = S900, h = MSH, L = SOB })

-- dot 2: 4x4 cut corners x28..31 y26..29
c:paint({
  ".ho..",     -- y26 (x28..32)
  "hooo.",
  "ooooL",
  ".ooL.",
  "..L..",     -- y30
}, 28, 26, { o = S900, h = MSH, L = SOB })

-- stepped drip ring, radius 7 round dot 1: lit arc upper-left, shade arc lower-right, no full ring
for _, p in ipairs({ {9,13}, {9,12}, {10,11}, {11,10}, {12,9}, {13,9} }) do c:px(p[1], p[2], SOBN) end
for _, p in ipairs({ {22,18}, {22,19}, {21,20}, {20,21}, {19,22}, {18,22} }) do c:px(p[1], p[2], MSH) end

-- water bead
c:px(20, 9, WAGL); c:px(21, 9, WARIM); c:px(20, 10, WARIM); c:px(21, 10, WARIM)

-- flecks
for _, p in ipairs({ {7,28}, {34,12}, {22,35} }) do c:px(p[1], p[2], MSH) end

local t = c:save(R .. "aseprite/trek-mud-u.aseprite", R .. "png/trek-mud-u.png")
print(GV.report(t))
