local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-flatbread: round puffy flatbread with charred blisters.
-- quirk: a bite is missing at upper right and a basil sprig sits on top.
local c = D.new("ico-flatbread")
c:groundShadow(32, 56, 22, 3)
local m = D.ell(32, 35, 24, 19, -0.15)
m:cut(c:ellipse(52, 22, 7, 7)):cut(c:ellipse(55, 30, 5, 5)):cut(c:ellipse(48, 17, 4, 4))
D.lit(m, { "#8a5a30", "#b87c40", "#d89c52", "#ecbc70", "#f8d68e", "#fff0b8" }, 12, { amb = 0.05 })
for _, b in ipairs{ {20,33,4,3},{30,45,5,3},{40,38,3,3},{26,25,3,2},{14,40,2,2},{38,28,3,2} } do
  local bm = D.isect(D.ell(b[1], b[2], b[3], b[4], 0.3), m)
  D.fill(bm, "#7a4a2a") D.fill(bm:copy():shrink(1), "#3a2030")
  c:px(b[1] - 1, b[2] - 1, "#b87c40")
end
-- bite edge
for y = 12, 36 do for x = 40, 58 do
  if m:has(x, y) and (not m:has(x + 1, y) or not m:has(x, y - 1)) and (c:ellipse(52,22,8,8):has(x,y) or c:ellipse(55,30,6,6):has(x,y)) then c:px(x, y, "#fff0b8") end
end end
D.leaf(c, 22, 22, 36, 14, 4, D.GREEN, { 3, 7 })
D.leaf(c, 22, 22, 32, 28, 3, D.GREEN, { 3 })
D.fin()
