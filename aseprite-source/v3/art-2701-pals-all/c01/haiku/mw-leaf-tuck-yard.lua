-- Leaf Tuck (mw-leaf-tuck), yard 64x64. Haiku pass, c01.
-- bloomcaller, common. A red maple-style leaf creature, folded along its midrib, tucked into a leaf pile.
-- quirk: it folds itself into the nearest red leaf pile; the pile is drawn over its lower edge.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mw-leaf-tuck-yard", 64)

local RED  = { "#5e1f2c", "#8c2c35", "#c4413a", "#e8603c", "#f58a5a", "#ffb98a" }
local REDB = { "#4a1a2e", "#6e2440", "#973550", "#bf4f5a", "#d9707a", "#f2a8a6" }
local PILE = { "#4a1a2e", "#7a2a3a", "#a83a3c", "#d05a3c", "#ef7f50", "#ffab7c" }

c:groundShadow(31, 58, 18, 3)

-- the leaf, folded along the midrib: left half lit, right half turned away (darker ramp)
local leaf = c:poly{ {31,6},{40,14},{45,25},{44,36},{36,46},{31,50},{26,46},{18,36},{17,25},{22,14} }
O.shade(c, leaf:copy():clip(c:rect(0, 0, 30, 63)), RED, { R = 5 })
O.shade(c, leaf:copy():clip(c:rect(31, 0, 63, 63)), REDB, { R = 5 })

-- midrib (light, down the fold) and paired veins, mirrored on the right half
local mid = {}
for y = 9, 46 do mid[#mid + 1] = { 31, y } end
O.dots(c, mid, RED[6])
local vl = { {30,19},{29,20},{27,21},{26,22},{30,29},{29,30},{27,31},{25,32} }
O.dots(c, vl, RED[5])
local vr = {}
for _, p in ipairs(vl) do vr[#vr + 1] = { 62 - p[1], p[2] } end
O.dots(c, vr, REDB[6])

-- face: locked eyes, leaf-tip nose, small mouth
c:eyeLocked(21, 27)
c:eyeLocked(36, 27)
c:cheek(19, 34)
c:cheek(41, 34)
O.dots(c, { {30,34},{31,34},{31,35} }, RED[1])
O.dots(c, { {27,38},{28,39},{29,39},{30,39},{31,39},{32,39},{33,39},{34,38} }, RED[1])

-- leaf pile the leaf tucks into (drawn over its lower edge)
local p1 = c:ellipse(18, 51, 8, 5)
local p2 = c:ellipse(33, 52, 10, 6)
local p3 = c:ellipse(47, 50, 7, 5)
O.shade(c, p1, PILE, { R = 3 })
O.shade(c, p2, PILE, { R = 3, sep = PILE[1] })
O.shade(c, p3, PILE, { R = 3, sep = PILE[1] })
O.dots(c, { {15,50},{21,53},{30,49},{38,55},{45,48},{50,52} }, PILE[6])

O.done(c, "mw-leaf-tuck-yard")
