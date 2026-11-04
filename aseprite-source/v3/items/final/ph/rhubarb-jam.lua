-- rhubarb-jam (final draft D12, Sonnet). Straight-sided glass jar of bright pink rhubarb jam with a red tin lid, cream
-- label with a rhubarb stalk drawing. quirk: a blob of jam has dripped over the lid edge.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dD12.lua")
local H, HP, X, K, B = D.H, D.HP, D.X, D.K, D.B
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("rhubarb-jam")
D.shadow(c, 32, 58, 18, 3)
local body = c:rrect(15, 23, 49, 56, 5)
D.lit(c, body, D.R.glass, 8, { wrap = 0.25 })
local fill = body:shrink(2)
D.lit(c, fill, { "#6e1f3a", "#9a2a4a", "#c8405e", "#e8607c", "#f58aa0", "#ffc0cc" }, 8, { wrap = 0.25 })
D.scatter(fill, 14, 17, function(x, y) c:px(x, y, "#ffb0c0") end)
for y = 27, 36 do c:px(18, y, "#f0fcff") end c:px(19, 26, "#f0fcff")
-- label
local lab = c:rrect(21, 34, 43, 49, 2)
D.lit(c, lab, D.R.cream, 2, {})
D.stalk(c, 25, 46, 36, 38, function(t) return 1.8 end, D.R.pink, {})
c:fillMask(c:rect(36, 36, 40, 38), "#3e8048") c:px(37, 36, "#9dd06c") c:px(38, 37, "#21593f")
for x = 24, 40, 2 do c:px(x, 47, "#b58d70") end
-- tin lid
local lid = c:rrect(14, 14, 50, 25, 2)
D.lit(c, lid, D.R.red, 3, {})
for x = 17, 47, 3 do for y = 16, 22 do c:px(x, y, "#7c1f2e") end end
for x = 15, 49 do c:px(x, 15, "#ee7a5a") end
-- drip over rim
local drip = c:poly{ {40,24},{45,24},{45,31},{43,33},{41,30} }
D.lit(c, drip, { "#6e1f3a", "#9a2a4a", "#c8405e", "#e8607c", "#f58aa0", "#ffc0cc" }, 2, {})
c:px(42, 28, "#ffc0cc")
D.fin()
