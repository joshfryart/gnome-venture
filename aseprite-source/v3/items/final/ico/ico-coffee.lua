-- ico-coffee (final, Opus). Tall, slim glazed mug: teal glaze (vertical cylinder light, 6 tones, long specular
-- streak, cool bounce on the right), bare clay foot ring under the glaze line, rounded rim lip lit across the
-- front, dark inner wall at the back, coffee with a crema ring and a glint. D-handle (pillow-lit tube) with AO
-- where it joins the body. Two 2 px steam curls. Ground shadow (it stands).
-- quirk: one coffee drip is running down the front from the rim.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA2_5.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs, sin = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin
local c = A.new("ico-coffee")
local CR = A.CREAM
local GLZ  = { "#1d3459", "#26527a", "#2f7799", "#45a1b5", "#7ccdc8", "#c6f1e3" }
local CLAY = { "#7a4a33", "#a8714c", "#cf9e72", "#ebc898" }
local COF  = { "#2e1820", "#4a2620", "#6e3a24", "#9a5c32", "#c98d55", "#f0c48a" }
local STM  = { "#b9c6e6", "#eaf0fb" }
local X0, X1, YT, YB = 17, 39, 23, 52       -- body
local MX, RX, RY = (X0 + X1) / 2, (X1 - X0) / 2 + 0.5, 3

A.gshadow(c, MX + 3, YB + 2, 16, 1.4)

-- handle (behind body): D loop on the right
local th = A.tok("handle")
local hm = A.ell(41, 37, 7.5, 9):cut(A.ell(41, 37, 3.6, 5.2)):cut(c:rect(0, 0, 38, 63))
local hn = X.pillow(hm, 1.8)
local hb = {}
hm:each(function(x, y) if x <= 41 then hb[K(x, y)] = -1 end end)
A.shade(c, hm, hn, GLZ, { tok = th, bias = hb, amb = 0.1, wrap = 0.25 })

-- body: vertical cylinder with a rounded bottom edge
local tb = A.tok("body")
local bm = c:rect(X0, YT, X1, YB - 2):add(c:rrect(X0, YB - 6, X1, YB, 3))
local bn = {}
bm:each(function(x, y)
  local s = max(-0.97, min(0.97, (x - MX) / (RX + 0.3)))
  local ny = 0
  if y > YB - 3 then ny = (y - (YB - 3)) * 0.28 end
  local l = sqrt(s * s + ny * ny + (1 - s * s))
  bn[K(x, y)] = { s / l, ny / l, sqrt(1 - s * s) / l }
end)
local bb = {}
X.ao(bb, bm, hm, 2, -1)
local bi = A.shade(c, bm, bn, GLZ, { tok = tb, bias = bb, amb = 0.08, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 } })
-- bare clay foot (below glaze line), with its own cylinder light
bm:each(function(x, y)
  if y >= YB - 2 then
    local i = bi[K(x, y)]
    local ci = max(1, min(4, i - 1))
    if y == YB then ci = max(1, ci - 1) end
    c:put(x, y, CLAY[ci], tb)
  elseif y == YB - 3 then
    c:put(x, y, GLZ[max(1, bi[K(x, y)] - 1)], tb)   -- glaze drip edge darkens
  end
end)
-- specular streak (long, upper-left) + cool bounce down the right edge
for y = YT + 4, YB - 9 do c:put(21, y, GLZ[6], tb) end
for y = YT + 5, YT + 10 do c:put(22, y, GLZ[6], tb) end
c:put(21, YT + 6, CR, tb)
for y = YT + 6, YB - 6 do c:put(X1, y, "#5a6fb4", tb) end

-- rim: ellipse lip, inner back wall, coffee surface
local tr = A.tok("rim")
local outer = A.ell(MX, YT, RX, RY)
local inner = A.ell(MX, YT, RX - 1.6, RY - 1.1)
local lip = outer:copy():cut(inner)
lip:each(function(x, y)
  local front = y >= YT
  local s = (x - MX) / RX
  local i = front and (s < -0.2 and 6 or (s < 0.5 and 5 or 4)) or (s < 0 and 5 or 4)
  c:put(x, y, GLZ[i], tr)
end)
-- inner: dark back wall on top half, coffee lower
local tc = A.tok("coffee")
inner:each(function(x, y)
  if y < YT - 1 then c:put(x, y, GLZ[2], tc)
  else
    local s = (x - MX) / (RX - 1.6)
    local i = 4
    if y == YT - 1 then i = 2 end
    if abs(s) > 0.72 or s > 0.45 then i = 3 end
    c:put(x, y, COF[i], tc)
  end
end)
-- crema ring + glint
for x = floor(MX) - 4, floor(MX) + 3 do if inner:has(x, YT) then c:put(x, YT, COF[5], tc) end end
c:put(floor(MX) - 3, YT, COF[6], tc) c:put(floor(MX) - 2, YT, COF[6], tc)
c:put(floor(MX) + 3, YT + 1, COF[4], tc)

-- quirk: drip running down the front
local td = A.tok("drip")
for y = YT + 2, YT + 8 do c:put(24, y, COF[3], td) c:put(25, y, COF[2], td) end
c:put(24, YT + 9, COF[2], td) c:put(25, YT + 9, COF[2], td) c:put(24, YT + 10, COF[1], td)
c:put(24, YT + 3, COF[5], td) c:put(24, YT + 4, COF[4], td)

-- steam: two S-curls, 2 px, pale with a lit side
local ts = A.tok("steam")
local function curl(x0, y0, h, ph)
  for i = 0, h do
    local y = y0 - i
    local x = floor(x0 + sin(i * 0.55 + ph) * 2.2 + .5)
    c:put(x, y, STM[2], ts) c:put(x + 1, y, STM[1], ts)
  end
end
curl(23, YT - 6, 9, 0.4)
curl(30, YT - 5, 7, 0.4)

A.save(c, "ico-coffee")
