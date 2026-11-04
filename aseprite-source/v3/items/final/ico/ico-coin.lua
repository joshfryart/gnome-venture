-- ico-coin (final, Opus). One thick gold coin tipped toward the viewer: an elliptical face with a raised rounded rim
-- and a sunken field, an embossed acorn (cap with crosshatch scales, lit nut, curled stem), and a deep reeded edge
-- showing below. Material: height-field normals (rim torus, emboss bevel) snapped to a 6-tone warm gold ramp, a
-- face-wide light falloff, a specular streak and cream glint on the upper-left rim, reeding as alternating 1 px
-- grooves on the edge with a dark AO row where the face overhangs it.
-- quirk: two little tooth dents on the top-right rim, where somebody bit it to check it was real.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = A.new("ico-coin")
local GO = { "#6e3418", "#a3561c", "#d4842a", "#f2b236", "#ffd968", "#fff2b8" }
local CX, CY, RX, RY, TH = 31.5, 28.5, 20, 16, 5
local ftok, etok = A.tok("face"), A.tok("edge")

-- bite: two tooth dents on the top-right rim
local bite = HP.mask()
local function dent(ang)
  local x, y = CX + cos(ang) * (RX + 0.6), CY + sin(ang) * (RY + 0.6)
  bite:add(A.ell(x, y, 1.9, 1.7))
end
dent(-0.27 * pi) dent(-0.19 * pi)

local face = A.ell(CX, CY, RX, RY)
local edge = HP.mask()
for d = 1, TH do edge:add(A.ell(CX, CY + d, RX, RY)) end
edge:cut(face)
face:cut(bite)
-- dents show on the edge too (same bite through the thickness)
for d = 1, TH do edge:cut(bite:copy():shift(0, d)) end

-- edge: vertical-band cylinder (normal by x), reeded
local nE = {}
edge:each(function(x, y)
  local u = max(-0.96, min(0.96, (x - CX) / (RX + 0.5)))
  nE[K(x, y)] = { u * 0.9, 0.55, sqrt(max(0.05, 1 - u * u * 0.81 - 0.3)) }
end)
local biasE = {}
X.ao(biasE, edge, face, 1, -1)
local idxE = A.shade(c, edge, nE, GO, { tok = etok, bias = biasE, amb = 0.04, wrap = 0.2, cuts = { 0.18, 0.36, 0.55, 0.75, 0.93 } })
edge:each(function(x, y)
  if x % 2 == 0 and not face:has(x, y - 1) then A.step(c, idxE, GO, x, y, -1, etok) end
end)
-- bottom row of the edge darker (underside)
edge:each(function(x, y) if not edge:has(x, y + 1) then A.step(c, idxE, GO, x, y, -1, etok) end end)

-- face height field: rounded rim ring, sunken field, embossed acorn
local function er(x, y) local u, v = (x - CX) / RX, (y - CY) / RY return sqrt(u * u + v * v) end
local acorn = HP.mask()
local AX, AY = CX + 0.5, CY + 0.5
local cap = A.ell(AX, AY - 3.2, 6, 3.2)
cap:cut(HP.rect(0, floor(AY - 1), 63, 63))
cap:add(HP.rect(floor(AX - 6), floor(AY - 2), floor(AX + 6), floor(AY - 1)))
local nut = A.ell(AX, AY + 2.4, 4.4, 4.4)
nut:cut(HP.rect(0, 0, 63, floor(AY - 2)))
nut:add(A.ell(AX, AY + 6.4, 2.2, 1.6)) nut:set(floor(AX), floor(AY) + 9)
local stem = HP.mask() stem:set(floor(AX), floor(AY - 7)) stem:set(floor(AX) + 1, floor(AY - 8)) stem:set(floor(AX) + 1, floor(AY - 7))
stem:set(floor(AX) + 2, floor(AY - 9))
acorn:add(cap):add(nut):add(stem)
local dA = X.dist(acorn)
local function hF(x, y)
  local r = er(x, y)
  local h
  if r > 0.78 then h = 2.6 * sqrt(max(0, 1 - ((r - 0.885) / 0.115) ^ 2)) + 0.3
  else h = 0.3 end
  local da = dA[K(x, y)]
  if da then h = h + 2.4 * min(da + 0.5, 1.6) / 1.6 end
  return h
end
local nF = A.hnorm(face, hF, 1.0)
local biasF = {}
-- AO in the field next to the rim wall and under the emboss (lower-right)
face:each(function(x, y)
  local r = er(x, y)
  local k = K(x, y)
  if r > 0.72 and r <= 0.78 and (x - CX) + (y - CY) < 0 then biasF[k] = -1 end
  if not acorn:has(x, y) and acorn:has(x - 1, y - 1) then biasF[k] = (biasF[k] or 0) - 1 end
end)
local idxF = A.shade(c, face, nF, GO, { tok = ftok, bias = biasF, amb = 0.1, wrap = 0.3, tilt = { CX, CY, 20, 0.22 } })
-- acorn cap: crosshatch scales (every 3rd diagonal), separated from the nut by a dark line
cap:each(function(x, y)
  if (x + y) % 3 == 0 or (x - y) % 3 == 0 then A.step(c, idxF, GO, x, y, -1, ftok) end
end)
nut:each(function(x, y) if cap:has(x, y - 1) then c:put(x, y, GO[2], ftok) idxF[K(x, y)] = 2 end end)
-- nut gloss (2x1) and tip
A.step(c, idxF, GO, floor(AX) - 2, floor(AY) + 1, 2, ftok) A.step(c, idxF, GO, floor(AX) - 1, floor(AY) + 1, 2, ftok)
-- specular streak + cream glint on the upper-left rim
face:each(function(x, y)
  local r = er(x, y)
  local a = math.atan(y - CY, x - CX)
  if r > 0.86 and r < 0.93 and a > -0.8 * pi and a < -0.6 * pi then c:put(x, y, GO[6], ftok) end
end)
do local a = -0.72 * pi local x, y = floor(CX + cos(a) * RX * 0.9 + 0.5), floor(CY + sin(a) * RY * 0.9 + 0.5)
  c:put(x, y, A.CREAM, ftok) c:put(x - 1, y, A.CREAM, ftok) end
-- bite dents: dark lip on the face where the tooth pressed in
A.touch(face, bite):each(function(x, y) c:put(x, y, GO[2], ftok) end)
A.save(c, "ico-coin")
