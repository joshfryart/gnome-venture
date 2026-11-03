local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local floor = math.floor
local c = D.new("antler-shard")
-- antler-shard: broken length of deer antler: ridged brown beam with two tines and a pale porous break. quirk: a hunter has scratched four tally marks into it.
local B = D.BONE
local beam, tn = D.H.cyl(c, 14, 50, 46, 16, function(t) return 4.6 - t * 1.6 end, B, {})
D.H.cyl(c, 30, 34, 22, 20, function(t) return 2.4 - t * 1.3 end, B, {})
D.H.cyl(c, 38, 24, 50, 28, function(t) return 2.2 - t * 1.2 end, B, {})
-- bez ridges along the beam
for i = 0, 9 do local t = i / 9 local x, y = 14 + 32 * t, 50 - 34 * t
  D.px(floor(x) + 1, floor(y) + 2, "#8a6c52") D.px(floor(x) + 2, floor(y) + 2, "#8a6c52") end
D.ln(17, 46, 40, 20, "#6e5440")
-- break end: pale porous disc
D.E(13, 51, 5.2, 3.6, -0.8, {"#b8966c","#d8bc8c","#ecd8aa","#f6e8c0","#fbf0d0","#fff8e4"}, 2)
for _, p in ipairs{{11,51},{13,49},{14,53},{12,53},{15,51}} do D.px(p[1], p[2], "#9a7a56") end
-- tally marks
for i = 0, 3 do D.ln(26 + i * 2, 38 - i * 2 + 1, 26 + i * 2 + 1, 38 - i * 2 + 5, "#4a3626") end
D.ln(25, 41, 33, 33, "#4a3626")
D.px(34, 17, "#fff4d6")
D.fin()
