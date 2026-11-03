local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-strawberry: glossy red strawberry with yellow seeds and a leafy green calyx.
-- quirk: someone has taken a bite out of the right shoulder, showing a pale pink inside.
local c = D.new("ico-strawberry")
local body = c:poly{ {14,22},{50,22},{52,32},{44,48},{32,58},{20,48},{12,32} }:add(D.ell(32, 32, 19, 12))
local bite = D.ell(52, 26, 6, 5):add(D.ell(48, 22, 5, 4))
body:cut(bite)
D.lit(c, body, D.RED, 12, { amb = 0.08 })
D.seam(c, body, c:rect(0, 0, 0, 0), D.PINK[6])
body:each(function(x, y) if bite:grow(1):has(x, y) then c:px(x, y, D.PINK[5]) end end)
for _, s in ipairs{ {22,30},{32,28},{42,32},{26,40},{37,40},{32,50},{20,38},{44,40} } do
  if body:has(s[1], s[2]) then D.rect(c, s[1], s[2], s[1] + 1, s[2] + 1, D.YEL[4]) c:px(s[1], s[2], D.YEL[6]) end
end
c:px(20, 27, D.RED[6]) c:px(21, 26, D.RED[6]) c:px(19, 28, D.RED[6])
-- calyx
for _, q in ipairs{ {32,24,16,14},{32,24,48,14},{32,24,22,26},{32,24,42,26},{32,22,32,10} } do D.leaf(c, q[1], q[2], q[3], q[4], 3.2, D.GRN) end
D.rect(c, 31, 6, 33, 12, D.GRN[3]) c:px(31, 7, D.GRN[5])
D.fin()
