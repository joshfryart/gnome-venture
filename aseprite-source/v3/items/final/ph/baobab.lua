local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- baobab: fat bottle trunk with thick root flare, a few stubby branches and tiny leaf tufts. quirk: a small round hollow in the trunk with a weaver-bird peeking out.
local c = D.new("baobab")
c:groundShadow(32, 57, 15, 2)
local TR = { "#3a2a2e", "#5a4238", "#7c5e4a", "#a07e62", "#c4a07c", "#e0c49e" }
D.ln(26, 22, 14, 12, "#5a4238") D.ln(27, 22, 15, 12, "#7c5e4a") D.ln(38, 22, 50, 12, "#5a4238") D.ln(37, 22, 49, 12, "#7c5e4a") D.ln(32, 22, 32, 9, "#7c5e4a") D.ln(33, 22, 33, 9, "#5a4238")
for _, p in ipairs{{12, 11}, {50, 11}, {32, 7}, {20, 8}, {44, 8}} do D.lf(p[1], p[2], 4.5, 2.8, 0, D.LEAF2) end
local t = c:poly{ {22, 20}, {42, 20}, {47, 32}, {44, 46}, {52, 55}, {12, 55}, {20, 46}, {17, 32} }
D.lit(t, TR, 7)
for x = 20, 46, 4 do D.ln(x, 24, x + (x < 32 and -2 or 2), 52, TR[2]) end
c:fillMask(D.ell(27, 34, 3.4, 3.8, 0), "#2c1a22") c:px(26, 32, "#7c5e4a")
c:fillMask(D.ell(27, 36, 2, 2, 0), "#f8d048") c:px(26, 36, "#ffe46e") c:px(28, 37, "#2b1c26") c:px(27, 38, "#d4403a")
D.fin()
