-- ico-crown (final, Opus). A gold crown seen front-on from a little above: a curved band (the cylinder's front
-- dips toward the viewer), five slim points rising from it with pearl tips, red velvet cap domed inside.
-- Material: per-pixel cylinder normals with a rounded bevel, snapped to a 6-tone gold ramp; raised band with a
-- bright top lip and a deep underside row, one engraved groove; cabochon gems with a specular pixel and a dark
-- seat; velvet cap with soft fold lines; AO where the points rise out of the band and where the cap meets the gold.
-- quirk: the tallest point is tipped with a little acorn instead of a pearl (a crown for a garden king).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = A.new("ico-crown")
local GOLD = { "#5a2c1e", "#924d1f", "#c77c22", "#eeac2e", "#ffd457", "#fff0a6" }
local VEL  = { "#381232", "#5c1838", "#862342", "#b03848", "#d45a58" }
local RUBY = { "#4e1030", "#8c1838", "#cf2e3e", "#f4605a", "#ffb0a0" }
local SAPH = { "#1c2a5e", "#28449a", "#3a78c8", "#6ab4ec", "#c4ecff" }
local PEARL = { "#7c6a8a", "#b6a8bc", "#e2d8d8", "#fbf0dc" }
local ACAP = { "#3e2622", "#6a3f2c", "#93603c", "#b8844e" }
local ANUT = { "#5a2c1e", "#924d22", "#c47a34", "#e8a456", "#ffd08a" }
local tG, tV, tGem, tP, tA = A.tok("gold"), A.tok("velvet"), A.tok("gem"), A.tok("pearl"), A.tok("acorn")
local CX = 31.5
local X0, X1 = 12, 51
local HW = (X1 - X0) / 2 + 0.5
local function u(x) return (x - CX) / HW end
local function dip(x) local q = u(x) return 2.6 * (1 - q * q) end   -- front of the cylinder sags toward us
local BT, BB = 37, 47          -- band top / bottom at the sides

-- crown wall outline (points) as a polygon above the band
local tips = { { 13, 22 }, { 22, 18 }, { 31.5, 13 }, { 41, 18 }, { 50, 22 } }
local notch = { { 17.5, 32 }, { 26.5, 30 }, { 36.5, 30 }, { 45.5, 32 } }
local wall = c:rect(X0, BT - 4, X1, BT + 2)
wall:add(c:poly{ { X0, BT - 4 }, { X0, 22 }, { 14, 21 }, { 18.5, BT - 4 } })
wall:add(c:poly{ { 17.5, BT - 4 }, { 22, 16.5 }, { 26.5, BT - 4 } })
wall:add(c:poly{ { 25.5, BT - 4 }, { 31.5, 12 }, { 37.5, BT - 4 } })
wall:add(c:poly{ { 36.5, BT - 4 }, { 41, 16.5 }, { 45.5, BT - 4 } })
wall:add(c:poly{ { X1, BT - 4 }, { X1, 22 }, { 49, 21 }, { 44.5, BT - 4 } })
-- band follows the dip
local band = HP.mask()
for x = X0, X1 do
  local d = dip(x)
  for y = floor(BT + d + 0.5), floor(BB + d + 0.5) do band:set(x, y) end
end
wall:cut(band)
-- velvet cap: a dome inside, showing in the notches
local cap = A.ell(CX, 32, 18, 12)
cap:cut(wall):cut(band)
cap = (function() local m = HP.mask() cap:each(function(x, y) if y < 40 then m:set(x, y) end end) return m end)()

-- velvet: dome normals, soft fold lines converging toward the top
local cn = X.sphere(CX, 34, 18, cap)
local cb = {}
X.ao(cb, cap, wall, 1, -1)
local cidx = A.shade(c, cap, cn, VEL, { bias = cb, tok = tV, amb = 0.12, wrap = 0.35, cuts = { 0.25, 0.45, 0.62, 0.8 } })
cap:each(function(x, y)
  local a = (x - CX) / max(1, (y - 20))
  for _, f in ipairs{ -1.35, -0.6, 0.15, 0.9 } do if abs(a - f) < 0.07 then A.step(c, cidx, VEL, x, y, -1, tV) end end
end)

-- gold wall: cylinder across + rounded bevel from the edge distance
local function goldNormals(m, bev, R)
  local np = X.pillow(m, R)
  local n = {}
  m:each(function(x, y) local k = K(x, y)
    local q = max(-0.95, min(0.95, u(x)))
    local cx, cz = q, sqrt(1 - q * q)
    local p = np[k]
    n[k] = { A.norm(cx * 0.8 + p[1] * bev, p[2] * bev - 0.08, cz * 0.8 + p[3] * 0.4) }
  end)
  return n
end
local wn = goldNormals(wall, 1.1, 2.2)
-- each point is its own faceted spike: bend normals across it (lit left facet, shaded right facet)
local PX = { { 12, 18.5, 14 }, { 17.5, 26.5, 22 }, { 25.5, 37.5, 31.5 }, { 36.5, 45.5, 41 }, { 44.5, 51, 49 } }
wall:each(function(x, y) if y < BT - 4 then
  local k = K(x, y)
  for _, p in ipairs(PX) do if x >= p[1] - 0.5 and x <= p[2] + 0.5 then
    local hw = max(1, (p[2] - p[1]) / 2)
    local q = max(-1, min(1, (x - p[3]) / hw))
    local n = wn[k]
    wn[k] = { A.norm(n[1] + q * 0.55, n[2], n[3]) }
    break
  end end
end end)
local wb = {}
X.ao(wb, wall, band, 1, -1)        -- ambient where the points rise out of the band
local TILT = { CX, 30, 26, 0.24 }
local widx = A.shade(c, wall, wn, GOLD, { bias = wb, tok = tG, amb = 0.06, wrap = 0.22, tilt = TILT, cuts = { 0.24, 0.4, 0.56, 0.74, 0.9 } })
-- a central ridge line up each point (lit left facet, shaded right facet)
for i, t in ipairs(tips) do
  local tx, ty = t[1], t[2]
  for y = floor(ty) + 4, BT - 5 do
    local x = floor(tx + 0.5)
    if wall:has(x, y) and wall:has(x + 1, y) then A.step(c, widx, GOLD, x + 1, y, -1, tG) end
  end
end

-- band: raised, stronger bevel, top lip bright, underside deep
local bn = goldNormals(band, 1.4, 2.6)
local bb = {}
band:each(function(x, y) if not band:has(x, y + 1) then bb[K(x, y)] = -2 end end)
local bidx = A.shade(c, band, bn, GOLD, { bias = bb, tok = tG, amb = 0.06, wrap = 0.22, tilt = TILT, cuts = { 0.24, 0.4, 0.56, 0.74, 0.9 } })
band:each(function(x, y)
  local top = floor(BT + dip(x) + 0.5)
  if y == top then c:put(x, y, (u(x) < 0.45) and GOLD[6] or GOLD[4], tG) bidx[K(x, y)] = 6 end
  if y == top + 1 then A.step(c, bidx, GOLD, x, y, -1, tG) end
  -- engraved groove near the bottom
  if y == top + 8 and x > X0 + 1 and x < X1 - 1 then A.step(c, bidx, GOLD, x, y, -2, tG) end
  if y == top + 9 and x > X0 + 1 and x < X1 - 1 and u(x) < 0.3 then A.step(c, bidx, GOLD, x, y, 1, tG) end
end)

-- gems set in the band
local function gem(cx, cy, rx, ry, ramp)
  local seat = A.ell(cx, cy, rx + 1, ry + 1)
  seat:each(function(x, y) if band:has(x, y) then c:put(x, y, GOLD[2], tG) end end)
  -- bezel: lit upper-left rim
  seat:each(function(x, y) if band:has(x, y) and (x - cx) + (y - cy) < -rx and not A.ell(cx, cy, rx, ry):has(x, y) then c:put(x, y, GOLD[5], tG) end end)
  local m = A.ell(cx, cy, rx, ry)
  local n = X.sphere(cx, cy, max(rx, ry), m)
  local gidx = A.shade(c, m, n, ramp, { tok = tGem, amb = 0.05, wrap = 0.1, cuts = { 0.2, 0.42, 0.62, 0.85 } })
  -- inner glow lower-right (light through the stone), specular upper-left
  local gx, gy = floor(cx + rx * 0.45 + 0.5), floor(cy + ry * 0.45 + 0.5)
  if m:has(gx, gy) then c:put(gx, gy, ramp[4], tGem) end
  local sx, sy = floor(cx - rx * 0.45 + 0.5), floor(cy - ry * 0.5 + 0.5)
  c:put(sx, sy, ramp[5], tGem) c:put(sx - 1, sy, ramp[4], tGem)
  return m
end
local gy = BT + dip(CX) + 4.5
gem(CX, gy, 3.2, 2.6, RUBY)
c:put(floor(CX - 1), floor(gy - 2), "#fff4d6", tGem)
gem(20, BT + dip(20) + 4.5, 2.1, 2.1, SAPH)
gem(43, BT + dip(43) + 4.5, 2.1, 2.1, SAPH)

-- pearl tips on four points
local function pearl(cx, cy, r)
  local m = A.ell(cx, cy, r, r)
  local n = X.sphere(cx, cy, r, m)
  A.shade(c, m, n, PEARL, { tok = tP, amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
  c:put(floor(cx - 0.8), floor(cy - 0.8), "#fff4d6", tP)
  -- seat shadow on the gold right under the pearl
  m:shift(0, 1):each(function(x, y) if wall:has(x, y) and not m:has(x, y) then A.step(c, widx, GOLD, x, y, -2, tG) end end)
end
pearl(13, 20.5, 2.2) pearl(22, 16, 2.2) pearl(41, 16, 2.2) pearl(50, 20.5, 2.2)

-- quirk: acorn finial on the tallest point
do
  local ax, ay = 31, 6
  local rows = {
    "..s...",
    ".CCCC.",
    "CcCcCC",
    "cCcCcD",
    ".nNNo.",
    ".nHNo.",
    ".nNNo.",
    "..No..",
  }
  local pal = { s = ACAP[1], C = ACAP[3], c = ACAP[4], D = ACAP[2], n = ANUT[4], N = ANUT[3], H = ANUT[5], o = ANUT[2] }
  A.map(c, rows, ax - 2, ay, pal, tA)
  -- AO where the acorn sits on the gold tip
  for _, p in ipairs{ { 31, 14 }, { 32, 14 } } do if wall:has(p[1], p[2]) then c:put(p[1], p[2], GOLD[2], tG) end end
end
-- glint on the left point (the one bright pop on the gold)
c:put(15, 27, GOLD[6], tG) c:put(15, 28, GOLD[6], tG)
A.save(c, "ico-crown")
