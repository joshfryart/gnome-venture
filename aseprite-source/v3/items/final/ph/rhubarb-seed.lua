-- rhubarb-seed (final draft D12, Sonnet). Three papery three-winged reddish rhubarb seeds on a ruffled crinkly rhubarb
-- leaf scrap with red veins; the right seed has sprouted a pink stem with two round green cotyledon leaves. quirk: one
-- seed's wing has a nibbled bite.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dD12.lua")
local H, HP, X, K, B = D.H, D.HP, D.X, D.K, D.B
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("rhubarb-seed")
local LEAF = D.R.leaf
local lf = HP.mask()
lf:add(c:ellipse(30, 47, 22, 8)):add(c:ellipse(14, 46, 8, 7)):add(c:ellipse(46, 46, 9, 7)):add(c:ellipse(30, 41, 9, 5)):add(c:ellipse(30, 52, 14, 5))
D.lit(c, lf, LEAF, 5, { wrap = 0.3 })
for _, q in ipairs{ {10,48,18,40},{10,48,24,38},{10,48,30,40},{10,48,36,42},{10,48,50,42},{10,48,54,48},{10,48,40,54},{10,48,28,55} } do D.ln(c, q[1], q[2], q[3], q[4], "#b0305a", lf) end
for _, q in ipairs{ {10,47,18,39},{10,47,28,39},{10,47,36,41} } do D.ln(c, q[1], q[2], q[3], q[4], "#d86a8a", lf) end
-- ruffle nicks
for _, q in ipairs{ {42,38},{22,53},{46,53},{9,52} } do lf:cut(c:rect(q[1], q[2], q[1] + 1, q[2])) end
-- seeds
local WING = { "#7a4a3a", "#a87860", "#d0a080", "#e8c0a0", "#f6dcc0", "#fff0dc" }
local BODY = { "#3a1618", "#5e2420", "#843a2c", "#a85a3c", "#c87e4e", "#e8a870" }
local function seed(cx, cy, bite)
  local wing = B.ell(cx, cy, 5.2, 5.2, 0)
  c:fillMask(B.ell(cx + 1, cy + 1.4, 5.4, 5.4, 0), "#1f553f")
  B.lit(c, wing, WING, 3)
  if bite then c:fillMask(c:ellipse(cx + 5, cy - 4, 2.4, 2.4):clip(wing), "#21593f") end
  local bd = c:poly{ {cx,cy-3},{cx+3,cy+2},{cx-3,cy+2} }
  B.lit(c, bd, BODY, 2)
  c:px(cx, cy, BODY[2]) c:px(cx - 1, cy - 1, "#ffe0b0")
  D.ln(c, cx, cy - 4, cx, cy - 5, WING[2])
  return wing
end
seed(16, 45, false) seed(29, 43, true)
D.ln(c, 44, 41, 44, 26, "#d86a8a") D.ln(c, 45, 41, 45, 27, "#a02a4a")
B.lit(c, B.ell(39, 25, 4, 3, -0.3), LEAF, 2) B.lit(c, B.ell(50, 25, 4, 3, 0.3), LEAF, 2)
B.lit(c, B.ell(44, 21, 3, 3, 0), LEAF, 2) c:px(44, 21, "#c2e48c") c:px(44, 22, "#c2e48c")
seed(44, 46, false)
D.fin()
