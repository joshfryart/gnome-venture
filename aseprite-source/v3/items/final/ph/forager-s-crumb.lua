-- forager-s-crumb (final, Opus aB32_2). A forager's hand pie: a slim half-moon turnover, golden glazed crust with a
-- fork-crimped rim (alternating ridge/groove), one slanted steam vent showing berry filling, sugar crystals and one glaze
-- specular. The right end is bitten off: ragged crust shell around glossy pink berry filling with seeds.
-- quirk: a single drop of berry jam drips from the bite, with three crumbs tumbling below.
local NAME = "forager-s-crumb"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_2.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local CRUST = { "#5a2a22", "#8a4428", "#b86a30", "#d9913c", "#efb85a", "#fde08e" }
local JAM   = { "#4e1236", "#80204e", "#b8346a", "#e0558a", "#f88db0", "#ffc8dc" }
local DOUGH = { "#c08a52", "#e2b77a", "#f6dcaa", "#fff0d0" }
local SPEC = "#fff6e0"

-- half-moon: arc on top, flat-ish underside
local CX, CY, R = 31, 44, 21
local body = HP.mask()
for y = 20, 47 do for x = 8, 54 do
  local dx, dy = (x - CX) / (R + 0.5), (y - CY) / (R * 0.98)
  if dy <= 0.12 and dx * dx + dy * dy <= 1 then body:set(x, y) end
end end
-- bite on the right end: two overlapping tooth arcs
local bite = c:ellipse(54, 33, 7, 8):add(c:ellipse(51, 43, 5, 5))
body:cut(bite)
-- crimped rim band along the arc
local rim, inner = HP.mask(), HP.mask()
body:each(function(x, y)
  local dx, dy = (x - CX) / (R + 0.5), (y - CY) / (R * 0.98)
  if dx * dx + dy * dy > 0.7 or y >= 45 then rim:set(x, y) else inner:set(x, y) end
end)
-- dome normals for the whole pie (puffy turnover)
local n = A.body(body, CX - 2, CY - 4, 19, 5, 0.55)
local tok = { r = { name = "crust" } }
local bias = {}
-- groove between rim and dome (ambient)
inner:edge():each(function(x, y) if rim:has(x - 1, y) or rim:has(x, y - 1) or rim:has(x + 1, y) or rim:has(x, y + 1) then bias[K(x, y)] = -1 end end)
local idx = A.shade(c, body, n, CRUST, { tok = tok, bias = bias, amb = 0.08, wrap = 0.2 })
-- fork crimp: radial grooves every 3 px of arc
rim:each(function(x, y) local k = K(x, y)
  local a = atan(y - CY, x - CX)
  local s = (a * R) % 3.2
  if s < 1.0 and y < 45 then c:put(x, y, CRUST[max(1, (idx[k] or 3) - 2)], tok)
  elseif s < 1.8 and y < 45 then c:put(x, y, CRUST[min(6, (idx[k] or 3) + 1)], tok) end
end)
-- underside lip: darker baked row
body:each(function(x, y) if not body:has(x, y + 1) and y >= 44 then c:put(x, y, CRUST[2], tok) end end)
-- vents showing filling
local jtok = { r = { name = "jam" } }
-- one long slanted steam vent (a single slash, off-centre)
for i, q in ipairs{ { 26, 29 }, { 27, 29 }, { 28, 28 }, { 29, 28 }, { 30, 27 }, { 31, 27 } } do
  c:put(q[1], q[2], i % 2 == 0 and JAM[3] or JAM[2], jtok)
  c:put(q[1], q[2] - 1, CRUST[2], tok) c:put(q[1], q[2] + 1, CRUST[5], tok)
end
c:put(28, 28, JAM[5], jtok)
-- sugar crystals on the lit dome + glaze specular
inner:copy():shrink(2):each(function(x, y) local k = K(x, y)
  if (idx[k] or 0) >= 4 and X.hash(x, y, 5) > 0.88 then c:put(x, y, CRUST[6], tok) end end)
c:put(19, 29, SPEC, tok) c:put(20, 29, SPEC, tok) c:put(21, 28, CRUST[6], tok)

-- bite face: crust shell ring + filling
local near = bite:grow(6)
local fill = body:copy():shrink(1):clip(bite:grow(5)):cut(c:rect(0, 44, 63, 63))
local dough = fill:grow(1):clip(body):clip(near:grow(1)):cut(fill)
dough:each(function(x, y) c:put(x, y, (x + y) % 3 == 0 and DOUGH[2] or DOUGH[3], tok) end)
-- the bitten edge itself: ragged pale dough lip where teeth tore the crust
bite:grow(1):clip(body):each(function(x, y) if not fill:has(x, y) then c:put(x, y, X.hash(x, y, 9) > 0.5 and DOUGH[1] or DOUGH[2], tok) end end)
local jn = X.pillow(fill, 2.5)
local jidx = A.shade(c, fill, jn, JAM, { tok = jtok, amb = 0.1, wrap = 0.2 })
-- berry seeds + gloss
fill:copy():shrink(1):each(function(x, y) if X.hash(x, y, 13) > 0.8 then c:put(x, y, JAM[1], jtok) end end)
do local gx, gy = G.specAt(fill, jn, 30) if gx then c:put(gx, gy, JAM[6], jtok) c:put(gx + 1, gy, JAM[5], jtok) end end

-- quirk: jam drip from the bite + tumbling crumbs
local fx0, fy0, fx1, fy1 = fill:bbox()
local dx = fx0 + 2
local dy = fy1
for y = dy, dy + 4 do c:put(dx, y, y < dy + 3 and JAM[3] or JAM[2], jtok) end
c:put(dx + 1, dy + 3, JAM[2], jtok) c:put(dx, dy + 5, JAM[2], jtok) c:put(dx + 1, dy + 4, JAM[1], jtok) c:put(dx, dy + 3, JAM[5], jtok)
local ctok = { r = { name = "crumbs" } }
for _, cr in ipairs{ { 46, 51, 2 }, { 51, 54, 1 }, { 43, 55, 1 } } do
  for j = 0, cr[3] - 1 do for i = 0, cr[3] do c:put(cr[1] + i, cr[2] + j, (i == 0 and j == 0) and CRUST[6] or CRUST[4], ctok) end end
  c:put(cr[1] + cr[3], cr[2] + cr[3] - 1, CRUST[2], ctok)
end

A.save(c, NAME)
