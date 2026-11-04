-- moth-orchid-seed: dust-fine cream seeds spilling from a split brown capsule on a broad glossy leaf, sprout with two fat leaves and a silver root. quirk: a trail of seed dust drifts upward.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B, X = D.H, D.HP, D.B, D.X
local floor, sin, cos, pi, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs
local c = D.new("moth-orchid-seed")
local LF = D.R("#b8e890", "#5cae60", "#2f7a52", "#1c4a44")
B.blade(c, 8, 54, 56, 52, 8, LF, { veins = { 6, 12, 18, 24, 30, 36, 42 }, slant = 1.2, prof = function(t) return sin(pi * min(1, t * .95 + .04)) ^ .5 end })
-- seedling
D.stem(c, { {40,46}, {41,40} }, 2, "#9ab48a", "#d4e4b0")
D.leafE(c, 35, 36, 6, 3.4, -0.5, LF, 0)
D.leafE(c, 46, 36, 6, 3.4, 0.5, LF, 0)
B.lit(c, B.ell(41, 32, 2.2, 3, 0), LF, 1.6)
D.stem(c, { {41,45}, {45,48}, {49,47} }, 1, "#c8d4cc", "#f0f4ee")
-- capsule
local cap = H.sweep({ {10,50}, {16,44}, {24,44}, {32,46} }, function(t) return 3.4 * sin(pi * min(1, t * .95 + .03)) ^ .6 + .6 end)
B.lit(c, cap, D.R("#d8a870", "#946038", "#6a3c2e", "#3e2224"), 2.4)
for i = 0, 3 do B.ln(c, 13 + i * 5, 46, 14 + i * 5, 41, "#3e2224", cap) end
c:fillMask(c:poly{ {26,45}, {33,48}, {31,51}, {25,49} }, "#fff4d6")
-- dust
for _, p in ipairs{ {28,49},{30,50},{27,51},{32,51},{24,52},{36,50},{33,53},{29,53},{20,53},{37,53},{22,50},{34,48} } do c:px(p[1], p[2], p[1] % 2 == 0 and "#fff4d6" or "#f2e0b0") end
for _, p in ipairs{ {30,40},{33,36},{29,32},{34,28},{31,24},{28,20},{32,17} } do c:px(p[1], p[2], "#fff4d6") end
for _, p in ipairs{ {29,38},{33,30},{30,26} } do c:px(p[1], p[2], "#f2e0b0") end
D.fin()
