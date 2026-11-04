-- camp-kit (final pass, Opus). A rolled red wool bedroll lying on its side: horizontal cylinder light, two dark
-- blanket stripes, a gold-stitched hem along the outer edge, a spiral end showing the cream felt lining. Two slim
-- leather straps (one with a bevelled iron buckle) and a twisted leather carry loop arcing over the top. A blue enamel
-- camp mug sits in the saddle between the straps: cylinder light, metal rim, dark mouth, cream speckles, a chip.
-- quirk: a sprig of pine tucked under the right strap.
local NAME = "camp-kit"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB1r0_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, atan, pi, max, min = math.floor, math.abs, math.sqrt, math.atan, math.pi, math.max, math.min
local c = A.new(NAME)

local WOOL = { "#5a1a32", "#8a2338", "#b8333c", "#dc4a3e", "#f2704c", "#ff9c72" }
local FELT = { "#7a5a46", "#b8946a", "#e2c79a", "#f6e6c0" }
local LEA = { "#3e2220", "#5e3426", "#82502f", "#a86e3e", "#cf9658", "#ecc086" }
local IRON = { "#2e2c40", "#4a4a62", "#74758c", "#a2a2b4", "#d2d2dc", "#eeeef4" }
local ENA = { "#1f2a58", "#2a4486", "#3a64ae", "#528aca", "#7eb2e2", "#bfe0f4" }
local PINE = { "#1a3c34", "#2a5a40", "#3f7e4a", "#62a456", "#96c86a" }

local CY, RY = 43, 7.6
-- bedroll body: horizontal cylinder 12..48 with a rounded far (left) end
local body = HP.mask()
for y = 34, 52 do for x = 6, 52 do
  local dy = (y - CY) / (RY + 0.5)
  if abs(dy) <= 1 then
    if x >= 13 and x <= 48 then body:set(x, y) end
    if x < 13 and ((x - 13) / 3.4) ^ 2 + dy * dy <= 1 then body:set(x, y) end
  end
end end
local bn = {}
body:each(function(x, y)
  local sn = max(-0.96, min(0.96, (y - CY) / (RY + 0.8)))
  local nx = x < 15 and -(15 - x) / 5 or 0
  bn[K(x, y)] = { A.norm(nx, sn, sqrt(1 - sn * sn)) }
end)
-- mug footprint (contact shadow on the roll)
local MX0, MX1 = 25, 33
local bias = {}
for x = MX0 - 1, MX1 + 1 do for y = 35, 37 do if body:has(x, y) then bias[K(x, y)] = (y == 35) and -2 or -1 end end end
local wtok = { r = { name = "wool" } }
A.shade(c, body, bn, WOOL, { bias = bias, tok = wtok, cuts = { 0.12, 0.28, 0.46, 0.64, 0.82 }, amb = 0.1, wrap = 0.3 })
-- blanket stripes (two dark bands) + diagonal weave ticks
body:each(function(x, y) local k = K(x, y)
  local v = X.light({ [k] = bn[k] }, { amb = 0.1, wrap = 0.3 })[k]
  local base = v > 0.64 and 4 or v > 0.46 and 3 or v > 0.28 and 2 or 1
  if y == 38 or y == 39 or y == 47 then c:put(x, y, WOOL[max(1, base - 1)], wtok)
  elseif (x + y) % 4 == 0 and (x - y) % 8 < 2 and y > 36 then c:put(x, y, WOOL[max(1, base)], wtok) end
end)
-- hem along the outer edge of the roll + one gold stitch line
for x = 13, 47 do c:put(x, 49, WOOL[1], wtok) end
c:stitch{ { 15, 48 }, { 46, 48 } }

-- spiral end cap (right)
local cap = HP.ellipse(48.5, CY, 3.2, RY - 0.2)
local ctok = { r = { name = "cap" } }
cap:each(function(x, y)
  local u, v = (x - 48.5) / 3.7, (y - CY) / (RY + 0.3)
  local r = sqrt(u * u + v * v)
  local a = (atan(v, u) / (2 * pi)) % 1
  local ph = (r * 3.1 + a) % 1
  local col
  if r > 0.86 then col = (v < -0.2) and WOOL[5] or WOOL[3]
  elseif ph < 0.34 then col = WOOL[2]
  else col = (u + v < -0.3) and FELT[4] or (u + v < 0.4) and FELT[3] or FELT[2] end
  if r < 0.18 then col = FELT[1] end
  c:put(x, y, col, ctok)
end)

-- straps (wrap the roll; lit by the roll's normals)
local ltok = { r = { name = "leather" } }
local function strap(x0)
  local m = HP.mask()
  for y = 34, 52 do for x = x0, x0 + 2 do if body:has(x, y) then m:set(x, y) end end end
  local sb = {}
  for y = 34, 52 do for x = x0, x0 + 2 do if m:has(x, y) and (x == x0 + 2) then sb[K(x, y)] = -1 end end end
  A.shade(c, m, bn, LEA, { bias = sb, tok = ltok, cuts = { 0.12, 0.28, 0.46, 0.64, 0.82 }, amb = 0.1, wrap = 0.3 })
  -- ambient shading on the wool beside the strap
  for y = 34, 52 do if body:has(x0 + 3, y) and not cap:has(x0 + 3, y) then
    local k = K(x0 + 3, y) local p = c:get(x0 + 3, y)
    for i = 2, 6 do if p == WOOL[i] then c:put(x0 + 3, y, WOOL[i - 1], wtok) end end end end
  return m
end
local s1 = strap(19)
local s2 = strap(38)
-- buckle on the left strap: hollow iron square with a bright upper-left edge
local itok = { r = { name = "iron" } }
for y = 40, 44 do for x = 18, 22 do
  local edge = (x == 18 or x == 22 or y == 40 or y == 44)
  if edge then
    local col = (x == 18 or y == 40) and IRON[5] or IRON[2]
    if x == 22 and y == 40 then col = IRON[4] end
    if x == 18 and y == 44 then col = IRON[3] end
    c:put(x, y, col, itok)
  end
end end
c:put(19, 40, IRON[6], itok)
for y = 41, 43 do c:put(20, y, IRON[4], itok) end   -- prong
-- carry loop: twisted leather arc over the top
local hm, hn, HT, HS = A.tube({ { 20, 35 }, { 17, 16 }, { 42, 16 }, { 39, 35 } }, function(t) return 1.05 end)
hm:cut(body)
local hidx = A.shade(c, hm, hn, LEA, { tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.68, 0.84 }, amb = 0.1, wrap = 0.3 })
hm:each(function(x, y) local k = K(x, y)
  local ph = (HT[k] * 30 + HS[k] * 1.4) % 3
  if ph < 0.8 then c:put(x, y, LEA[max(1, (hidx[k] or 3) - 1)], ltok) end
end)

-- enamel mug sitting between the straps
local mtok = { r = { name = "mug" } }
local mb = HP.mask()
for y = 26, 35 do for x = MX0, MX1 do mb:set(x, y) end end
mb.s[K(MX0, 35)] = nil mb.s[K(MX1, 35)] = nil
local mn = {}
mb:each(function(x, y) local t = max(-0.95, min(0.95, ((x - MX0) / (MX1 - MX0)) * 2 - 1))
  mn[K(x, y)] = { A.norm(t, 0.05, sqrt(1 - t * t)) } end)
local midx = A.shade(c, mb, mn, ENA, { tok = mtok, cuts = { 0.12, 0.3, 0.48, 0.66, 0.84 }, amb = 0.08, wrap = 0.25 })
for x = MX0 + 1, MX1 - 1 do c:put(x, 35, ENA[1], mtok) end   -- base ring shadow
-- speckles
for _, p in ipairs{ { 27, 30 }, { 30, 33 }, { 32, 29 }, { 28, 34 } } do c:put(p[1], p[2], (p[1] < 30) and "#e6eef6" or "#9ab6d4", mtok) end
-- rim: metal lip ring and dark mouth
for x = MX0, MX1 do c:put(x, 25, (x < 29) and IRON[5] or IRON[3], mtok) c:put(x, 26, IRON[(x < 28) and 4 or 2], mtok) end
for x = MX0 + 1, MX1 - 1 do c:put(x, 24, IRON[(x < 28) and 6 or 4], mtok) end
for x = MX0 + 1, MX1 - 1 do c:put(x, 25, (x < MX0 + 3) and "#3a3450" or "#241c30", mtok) end
c:put(MX0, 25, IRON[5], mtok) c:put(MX1, 25, IRON[3], mtok)
-- chip in the enamel near the rim (dark metal showing)
c:put(31, 28, IRON[1], mtok) c:put(32, 28, IRON[2], mtok)
-- handle: loop on the left
local hm2, hn2 = A.tube({ { 25, 28 }, { 20, 27 }, { 20, 34 }, { 25, 33 } }, function(t) return 0.75 end)
hm2:cut(mb)
A.shade(c, hm2, hn2, ENA, { tok = mtok, cuts = { 0.2, 0.4, 0.6, 0.8 }, amb = 0.1, wrap = 0.25 })
-- specular streak on the mug
for y = 28, 31 do c:put(27, y, ENA[6], mtok) end
c:put(27, 28, A.CREAM, mtok)

-- quirk: pine sprig tucked under the right strap
local ptok = { r = { name = "pine" } }
local twig = { { 39, 41 }, { 42, 38 }, { 44, 35 }, { 47, 31 } }
for i = 0, 20 do local x, y = A.bez(twig, i / 20)
  local xi, yi = floor(x + .5), floor(y + .5)
  if not s2:has(xi, yi) then c:put(xi, yi, LEA[3], ptok) end
  if i % 3 == 1 and i > 2 then
    local up, dn = { xi - 2, yi - 1 }, { xi + 1, yi + 2 }
    c:put(xi - 1, yi - 1, PINE[4], ptok) c:put(up[1], up[2], PINE[5], ptok)
    c:put(xi + 1, yi + 1, PINE[2], ptok) if not cap:has(dn[1], dn[2]) then c:put(dn[1], dn[2], PINE[3], ptok) end
  end
end
c:put(48, 30, PINE[4], ptok) c:put(49, 29, PINE[5], ptok) c:put(47, 29, PINE[3], ptok)

-- glint on the buckle
c:put(18, 40, A.CREAM, itok)

A.done(c, NAME)
