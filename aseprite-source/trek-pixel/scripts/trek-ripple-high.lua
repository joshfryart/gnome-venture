-- trek-ripple-high: high-water double waves plus spray, the map-key sign for HIGH water (42x42 transparent overlay)
local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(R .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }
local G, RIM, BASE = "#c8ecdc", "#a9d6ea", "#3f8fb0"   -- wa_gloss, wa_rim, wa_base (trek-water-auto ramp)
local function run(x0, x1, y, h) for x = x0, x1 do c:px(x, y, h) end end
-- strand A, baseline y=17: hump x8..20, trough x21..33
run(8, 9, 17, RIM); run(19, 20, 17, RIM); run(10, 11, 16, G); run(17, 18, 16, G)
run(12, 16, 15, G); run(12, 16, 16, RIM)
run(21, 22, 17, RIM); run(32, 33, 17, RIM); run(23, 24, 18, RIM); run(30, 31, 18, RIM)
run(25, 29, 19, RIM); run(25, 29, 18, BASE)
-- strand B, baseline y=29: hump x12..23, trough x24..34
run(12, 13, 29, RIM); run(22, 23, 29, RIM); run(14, 15, 28, G); run(20, 21, 28, G)
run(16, 19, 27, G); run(16, 19, 28, RIM)
run(24, 25, 29, RIM); run(33, 34, 29, RIM); run(26, 27, 30, RIM); run(31, 32, 30, RIM)
run(28, 30, 31, RIM)
-- spray
for _, p in ipairs({ {6,8},{35,12},{9,36},{33,35} }) do c:px(p[1], p[2], G) end
local P = R .. "trek-pixel/"
print(GV.report(c:save(P .. "aseprite/trek-ripple-high.aseprite", P .. "png/trek-ripple-high.png")))
