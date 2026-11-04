-- cattail-fritters (ph, Opus single pass). Three crisp golden fritters (flat pucks: lit pillowy top, darker fried
-- side band, knobbly crust from bumps and pits, green flecks of cattail shoot in the batter) piled on a slim
-- oval glazed plate (rim bevel, pale glaze spec, inner well) with a 2-tone ground shadow; a slim cattail spike
-- on its stalk leans out behind as the garnish (velvety brown head with a pale pollen tip).
-- quirk: honey drips off the front fritter and pools on the plate.
local NAME = "cattail-fritters"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r1_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local FR = { "#5a2a2a", "#8e4426", "#c06a28", "#e09634", "#f4bf52", "#fde58a" }
local PL = { "#3e4466", "#5f6c94", "#8da0c0", "#bccde0", "#e2ecf2", "#f8fcfa" }
local HON = { "#8a3a12", "#c86a14", "#f0a024", "#ffd468" }
local SPK = { "#3a2026", "#5e3428", "#845034", "#a8703e", "#cc9a5a" }
local STK = { "#2a5a3e", "#4c8a4a", "#7cb45a", "#b0d880" }

-- ground shadow under the plate
c:groundShadow(32, 52, 21, 2)
-- plate
local pm = HP.ellipse(32, 48, 22, 5.5)
local pn = {}
pm:each(function(x, y) local dx, dy = (x - 32) / 22.5, (y - 48) / 6 local q = dx * dx + dy * dy
  local r = sqrt(q)
  -- rim: outer band tilts out, inner well flat-ish
  local nx, ny, nz
  if r > 0.72 then local s = (r - 0.86) / 0.14 nx, ny, nz = dx * s * 0.9, dy * s * 2.5, 1
  else nx, ny, nz = -dx * 0.15, -dy * 0.4, 1 end
  local l = sqrt(nx * nx + ny * ny + nz * nz) pn[K(x, y)] = { nx / l, ny / l, nz / l } end)
local ptok = A.tok("plate")
X.tone(c, pm, X.light(pn, { amb = 0.15, wrap = 0.3 }), PL, { cuts = A.CUTS, tok = ptok })
-- plate rim inner groove
pm:each(function(x, y) local dx, dy = (x - 32) / 22.5, (y - 48) / 6 local r = sqrt(dx * dx + dy * dy)
  if r > 0.7 and r < 0.78 then c:put(x, y, dy < 0 and PL[3] or PL[5], ptok) end end)
-- plate underside lip (gives thickness)
for x = 14, 50 do local dx = (x - 32) / 18 if abs(dx) <= 1 then local y = floor(53.6 + 0.0) if not pm:has(x, y) then c:put(x, y, PL[2], ptok) end end end
c:put(17, 46, PL[6], ptok) c:put(18, 46, PL[6], ptok)

-- garnish: cattail spike on stalk, behind the fritters
local gtok = A.tok("stalk")
for i = 0, 40 do local t = i / 40 local x, y = 40 + t * 15, 40 - t * 33
  c:put(floor(x + .5), floor(y + .5), STK[3], gtok) c:put(floor(x + .5) + 1, floor(y + .5), STK[1], gtok) end
local km, kn, KT, KS = X.cyl(45.5, 26, 51.5, 12, function(t) if t < 0.04 or t > 0.98 then return -1 end return 2.6 * sin(pi * min(1, t * 0.8 + 0.2)) ^ 0.35 end)
local ktok = A.tok("spike")
local kidx = X.tone(c, km, X.light(kn, { amb = 0.06, wrap = 0.25 }), SPK, { cuts = { 0.22, 0.42, 0.62, 0.82 }, tok = ktok })
km:each(function(x, y) local k = K(x, y) if A.hash(x, y, 4) < 0.22 then c:put(x, y, SPK[max(1, kidx[k] - 1)], ktok) end end)
-- pollen tip
for _, q in ipairs{ { 52, 11 }, { 52, 10 }, { 53, 9 }, { 53, 8 } } do c:put(q[1], q[2], q[2] < 10 and "#e8d070" or "#b49a4a", gtok) end

-- fritters (back two then front)
local function puck(cx, cy, rx, ry, th, seed)
  local top = HP.mask()
  top:add(HP.ellipse(cx, cy, rx, ry))
  local side = HP.mask()
  for d = 1, th do side:add(HP.ellipse(cx, cy + d, rx, ry)) end
  side:cut(top)
  -- knobbly crust: nibble and bump the silhouette
  local all = top:copy():add(side)
  all:edge():each(function(x, y) local h = A.hash(x, y, seed) if h < 0.18 then top.s[K(x, y)] = nil side.s[K(x, y)] = nil end end)
  all:grow(1):cut(all):each(function(x, y) if A.hash(x, y, seed + 1) < 0.12 and y < cy + th then top:set(x, y) end end)
  return top, side
end
local function paint(top, side, cx, cy, rx, ry, bias, seed)
  local tok = A.tok("fritter" .. seed)
  local tn = X.pillow(top, 2.4)
  local tidx = X.tone(c, top, X.light(tn, { amb = 0.12, wrap = 0.3 }), FR, { cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, bias = bias, tok = tok })
  local sn = {}
  side:each(function(x, y) local t = max(-0.95, min(0.95, (x - cx) / (rx + 1))) sn[K(x, y)] = { t * 0.8, 0.45, sqrt(1 - t * t * 0.64) } end)
  local sidx = X.tone(c, side, X.light(sn, { amb = 0.05, wrap = 0.1 }), FR, { cuts = { 0.25, 0.45, 0.62, 0.9, 0.99 }, bias = bias, tok = tok })
  -- crust: bumps (lit pixel + shade under) and pits
  top:each(function(x, y) local k = K(x, y) local h = A.hash(x, y, seed + 2)
    if h < 0.07 and top:has(x, y + 1) then c:put(x, y, FR[min(6, tidx[k] + 1)], tok) c:put(x, y + 1, FR[max(1, tidx[k] - 1)], tok)
    elseif h > 0.93 then c:put(x, y, FR[max(1, tidx[k] - 2)], tok)
    elseif h > 0.88 and h <= 0.93 and abs(x - cx) < rx - 2 then c:put(x, y, (y < cy) and "#7cb04a" or "#4a7a3a", tok) end end)
  side:each(function(x, y) if A.hash(x, y, seed + 3) < 0.15 then c:put(x, y, FR[1], tok) end end)
  -- seam between top and side
  side:each(function(x, y) if top:has(x, y - 1) then c:put(x, y, FR[max(1, (sidx[K(x, y)] or 3) - 1)], tok) end end)
  return tidx, tn
end
local P = { { 23, 36, 9, 4.5, 3, 11 }, { 41, 37, 9, 4.5, 3, 21 }, { 32, 42, 10, 5, 3, 31 } }
local tops, sides = {}, {}
for i, q in ipairs(P) do tops[i], sides[i] = puck(q[1], q[2], q[3], q[4], q[5], q[6]) end
-- back pucks: AO where the front one overlaps
local fall = tops[3]:copy():add(sides[3])
for i = 1, 2 do
  local b = {}
  local all = tops[i]:copy():add(sides[i])
  X.ao(b, all, fall, 1, -1)
  tops[i]:cut(fall) sides[i]:cut(fall)
  paint(tops[i], sides[i], P[i][1], P[i][2], P[i][3], P[i][4], b, P[i][6])
end
-- plate contact shadow under the pile
local pb = HP.mask()
for i = 1, 3 do pb:add(sides[i]) end
pb:shift(1, 1):each(function(x, y) if pm:has(x, y) and not pb:has(x, y) and not fall:has(x, y) and c:get(x, y) and (c:get(x, y) == PL[4] or c:get(x, y) == PL[5] or c:get(x, y) == PL[3] or c:get(x, y) == PL[6]) then c:put(x, y, PL[2], ptok) end end)
local tidx, tn = paint(tops[3], sides[3], 32, 42, 10, 5, {}, 31)
-- glossy spec on the front fritter
do local bx, by = A.specAt(tops[3], tn, 40) c:put(bx, by, "#fff6d0", A.tok("fritter31")) c:put(bx + 1, by, FR[6], A.tok("fritter31")) end

-- quirk: honey drip off the front fritter's right edge, pooling on the plate
local htok = A.tok("honey")
local drip = { { 39, 45, 3 }, { 40, 45, 4 }, { 39, 46, 3 }, { 40, 46, 2 }, { 39, 47, 3 }, { 40, 47, 2 }, { 39, 48, 4 }, { 40, 48, 3 }, { 40, 49, 2 } }
for _, d in ipairs(drip) do c:put(d[1], d[2], HON[d[3]], htok) end
local pool = HP.ellipse(42, 50, 3, 1)
pool:each(function(x, y) c:put(x, y, (y < 50 and x < 43) and HON[4] or (y > 50 and HON[2] or HON[3]), htok) end)
c:put(41, 49, "#fff2c0", htok)
A.save2(c, NAME)
