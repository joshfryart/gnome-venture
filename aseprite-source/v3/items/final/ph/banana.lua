local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- banana: a small hand of three ripe bananas curving from a shared dark stalk, with brown freckles and black tips. quirk: the middle banana wears a tiny peeled strip.
local c = D.new("banana")
local function crescent(cx, cy, ang, sh)
  local m = D.ell(cx, cy, 14, 24, ang)
  m:cut(D.ell(cx + sh * math.cos(ang), cy + sh * math.sin(ang), 14, 24, ang))
  return m
end
local bs = { {28, 36, -0.32, 8}, {34, 34, 0.0, 9}, {40, 36, 0.3, 8} }
local ord = { 1, 3, 2 }
for _, i in ipairs(ord) do
  local b = bs[i]
  local m = crescent(b[1] - 3 + i * 2, b[2], b[3], b[4])
  D.lit(m, D.YEL, 3)
  m:each(function(x, y) if (x * 7 + y * 3) % 13 == 0 then c:px(x, y, "#8f5a1f") end end)
end
D.lit(c:rect(30, 6, 36, 14), D.BRN, 2.5)
D.lit(c:rect(31, 4, 35, 7), D.GRAIN, 1.5)
c:px(24, 49, "#2c2030") c:px(25, 50, "#2c2030") c:px(46, 49, "#2c2030") c:px(45, 50, "#2c2030") c:px(36, 56, "#2c2030")
D.ln(34, 16, 38, 23, "#fff2a8") D.ln(35, 16, 39, 22, "#e6cfa8")
D.fin()
