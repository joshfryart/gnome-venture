-- trek-ripple-pool: calm pool glints, two short single low waves (42x42 transparent overlay)
local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(R .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }
local G, RIM, BASE = "#c8ecdc", "#a9d6ea", "#3f8fb0"   -- wa_gloss, wa_rim, wa_base (trek-water-auto ramp)
local function run(x0, x1, y, h) for x = x0, x1 do c:px(x, y, h) end end
-- wave 1: 14 wide (x10..23), rising 2 px
run(14, 19, 21, G); run(12, 13, 22, G); run(20, 21, 22, G)
run(10, 11, 23, RIM); run(22, 23, 23, RIM); run(14, 16, 22, RIM)
-- wave 2: 10 wide
run(25, 28, 11, G); run(23, 24, 12, G); run(29, 30, 12, G)
run(21, 22, 13, RIM); run(31, 32, 13, RIM)
local P = R .. "trek-pixel/"
print(GV.report(c:save(P .. "aseprite/trek-ripple-pool.aseprite", P .. "png/trek-ripple-pool.png")))
