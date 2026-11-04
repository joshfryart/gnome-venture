-- mushroom-toast: golden buttered toast slice topped with three sauteed mushroom slices and a parsley fleck. quirk: a bite is missing from the top-right corner.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B, X = D.H, D.HP, D.B, D.X
local floor, sin, cos, pi, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs
local c = D.new("mushroom-toast")
local CR = D.R("#e8b45a", "#b97a3a", "#864c33", "#51302b")
local CM = D.R("#fff4c4", "#f8d880", "#e4aa4a", "#b97a3a")
c:groundShadow(32, 57, 20, 2)
local bread = c:rrect(12, 20, 52, 54, 6):add(c:ellipse(22, 20, 11, 6)):add(c:ellipse(42, 20, 11, 6))
local bite = c:ellipse(52, 17, 6, 6)
bread:cut(bite)
B.lit(c, bread, CR, 8)
local crumb = bread:shrink(2)
B.lit(c, crumb, CM, 7)
-- bite exposes crumb
bite:grow(1):clip(bread):each(function(x, y) c:px(x, y, "#fff4c4") end)
bite:grow(2):clip(bread):cut(bite:grow(1)):each(function(x, y) if (x + y) % 2 == 0 then c:px(x, y, "#f8d880") end end)
-- butter glaze flecks
D.speck(c, crumb, "#fff4d6", 8, .93)
local MU = D.R("#f4d4a0", "#c48a50", "#8a5a38", "#51302b")
local function mush(cx, cy, s, ang)
  local ca, sa = cos(ang), sin(ang)
  local st = B.ell(cx - sa * s * .7, cy + ca * s * .7, s * .55, s * .9, ang)
  B.lit(c, st, MU, 1.5)
  local cap = B.ell(cx, cy, s * 1.3, s * .8, ang + pi / 2)
  B.lit(c, cap, MU, 2.2)
  c:px(floor(cx - ca * s * .9), floor(cy + s * .7), "#fff4d6") c:px(floor(cx), floor(cy + s * .8), "#fff4d6") c:px(floor(cx + ca * s * .9), floor(cy + s * .7), "#fff4d6")
end
mush(24, 33, 4.6, 0.2) mush(38, 31, 4.2, -0.3) mush(31, 44, 4.8, 0.1)
c:px(23, 32, "#fff4d6") c:px(24, 32, "#fff4d6")
for _, p in ipairs{ {42,41}, {18,42}, {44,46} } do c:px(p[1], p[2], "#3f9150") c:px(p[1] + 1, p[2], "#7cc35a") end
D.fin()
