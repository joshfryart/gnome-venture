-- roasted-roots (final draft D12, Sonnet). An iron roasting tin holding three glazed, browned root vegetables (carrot,
-- parsnip, purple beet wedge) with charred tips and a rosemary sprig. quirk: the steam wisps curl into a little heart.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dD12.lua")
local H, HP, X, K, B = D.H, D.HP, D.X, D.K, D.B
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("roasted-roots")
D.shadow(c, 30, 58, 24, 2.5)
local tin = c:ellipse(29, 44, 23, 11)
D.lit(c, tin, D.R.ink, 6, { wrap = 0.25 })
-- handle
D.stalk(c, 48, 46, 59, 42, function(t) return 2 end, D.R.ink, {})
c:px(58, 42, "#9a96ac")
local inner = c:ellipse(29, 42, 19, 7)
D.lit(c, inner, { "#14101a", "#1e1a2a", "#2e2a40", "#403c58", "#58546e", "#76728a" }, 4, { amb = 0.2 })
-- roots
local CAR = D.R.orange
local PAR = { "#5a3a22", "#8a5c34", "#b88850", "#d8ac6c", "#ecc88a", "#f8e0b0" }
local BEET = { "#2a1030", "#4a1a4a", "#6e2a68", "#923a80", "#b85a9c", "#dc8cc0" }
local rm = D.stalk(c, 13, 41, 34, 33, function(t) return 3.4 * (1 - t * 0.55) end, CAR, { -0.3, 0.35 })
local pm = D.stalk(c, 18, 47, 44, 40, function(t) return 3.2 * (1 - t * 0.45) end, PAR, { -0.3, 0.35 })
local bm = B.ell(42, 33, 4.6, 3.4, -0.5)
local bi = B.lit(c, bm, BEET, 3)
D.ln(c, 39, 32, 45, 35, BEET[2], bm) D.ln(c, 40, 30, 44, 33, BEET[5], bm)
-- char marks
for _, q in ipairs{ {14,39},{13,41},{18,45},{20,46},{30,34},{43,41},{44,40} } do c:px(q[1], q[2], "#3a2420") end
for _, q in ipairs{ {22,38},{27,36},{30,43},{36,41},{24,45} } do c:px(q[1], q[2], "#fff4d6") end
-- rosemary
D.ln(c, 28, 38, 38, 38, "#3e8048")
for x = 29, 37, 2 do c:px(x, 37, "#6ab455") c:px(x + 1, 39, "#45954c") end
-- steam heart
local ST, ST2 = "#e4f6ff", "#b9e2f5"
D.curl(c, { {26,24},{23,21},{23,18},{26,17},{29,19} }, ST)
D.curl(c, { {29,19},{32,17},{35,18},{35,21},{32,24},{29,27} }, ST2)
D.fin()
