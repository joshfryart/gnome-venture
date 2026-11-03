local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("blight-shard")
-- blight-shard: a slim jagged violet-black crystal shard, bright cracked facets, a sickly green glow vein. quirk: a wisp of green blight smoke curls off the tip.
D.shadow(32, 58, 11, 2)
D.P({{32,6},{40,22},{42,46},{34,56},{24,52},{22,30}}, D.PURP, 3)
D.P({{32,6},{26,24},{24,48},{34,56},{34,30}}, D.PURP, 2.5, {amb = 0.02})
D.P({{32,6},{34,30},{34,56},{42,46},{40,22}}, D.INDIGO, 3)
D.ln(32, 8, 34, 30, "#d0aee8") D.ln(33, 30, 33, 54, "#2a1640") D.ln(26, 28, 28, 44, "#a97ccc")
D.ln(35, 24, 38, 30, "#9dd06c") D.ln(38, 30, 36, 36, "#6ab455") D.ln(36, 36, 39, 44, "#6ab455") D.px(35, 24, "#ccf090")
D.px(29, 14, "#fff4d6") D.px(29, 15, "#fff4d6")
for i = 0, 5 do D.px(31 + floor(sin(i * 1.2) * 2.2 + .5), 5 - i + 0, i % 2 == 0 and "#9dd06c" or "#6ab455") end
D.P({{18,40},{14,44},{19,46}}, D.PURP, 1) D.P({{46,34},{51,36},{46,40}}, D.INDIGO, 1)
D.fin()
