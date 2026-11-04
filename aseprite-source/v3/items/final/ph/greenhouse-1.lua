-- greenhouse-1 (dC10 first draft): tier 1, a small plain gabled glasshouse with white frame, one tomato bush row.
-- quirk: a watering-can-sized snail climbs the front mullion.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC10.lua")
local B, H, HP, X, K = D.B, D.H, D.HP, D.X, D.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new('greenhouse-1')
c:groundShadow(32, 56, 22, 2.5)
D.house(c, { x0 = 14, x1 = 49, wt = 30, fl = 50, pk = 12, roof = 'gable', mull = 7 })
-- snail
c:fillMask(c:ellipse(21.5, 40.5, 2, 2), '#f5b82e') c:px(21, 40, '#8f4a1f') c:px(22, 40, '#d98322')
c:px(19, 42, '#c9b2f0') c:px(20, 42, '#c9b2f0') c:px(19, 41, '#c9b2f0') c:px(18, 40, '#2b1c26') c:px(19, 39, '#c9b2f0')
D.fin()
