local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-dna: slanted double helix, one blue and one pink strand, gold rungs between them.
-- quirk: a tiny green sprout grows from the top end of the helix.
local c = D.new("ico-dna")
local pts = {}
for y = 8, 58 do
  local ph = (y - 8) / 50 * pi * 4
  local xo = 32 + (y - 33) * 0.0
  pts[#pts + 1] = { y = y, ax = xo + sin(ph) * 14, az = cos(ph), bx = xo - sin(ph) * 14 }
end
for i = 2, #pts, 5 do
  local p = pts[i]
  if abs(p.ax - p.bx) > 8 then D.fill(c:line({ { p.ax, p.y }, { p.bx, p.y } }, 3), D.GOLD[3]) D.fill(c:line({ { p.ax, p.y - 1 }, { p.bx, p.y - 1 } }, 1), D.GOLD[5]) end
end
local order = {}
for i = 1, #pts, 2 do order[#order + 1] = { i = i, z = pts[i].az, s = 1 } order[#order + 1] = { i = i, z = -pts[i].az, s = 2 } end
table.sort(order, function(a, b) return a.z < b.z end)
for _, o in ipairs(order) do
  local p = pts[o.i]
  local x = (o.s == 1) and p.ax or p.bx
  local R = (o.s == 1) and D.BLUE or D.RED
  local r = o.z > 0 and 2.8 or 2.2
  local m = D.disc(x, p.y, r)
  D.lit(m, R, 2, {})
  if o.z > 0.4 then D.px(floor(x - 1), p.y - 1, R[6]) end
end
-- sprout
D.fill(c:line({ { 32, 8 }, { 32, 3 } }, 2), "#3fa862")
D.lit(D.ell(28, 3, 3, 1.6, -0.4), "moss", 1.6) D.lit(D.ell(36, 3, 3, 1.6, 0.4), "moss", 1.6)
D.fin()
