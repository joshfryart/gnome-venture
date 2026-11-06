-- potato (D10, single pass). One long lumpy tuber (slightly tapered to the right, outline from a wobbly polar curve) lit per
-- pixel from a height field with big lumps + skin pits, dusty gold-brown 6-tone skin, lenticel dashes, dirt crumbs, deep
-- eyes with brows, a pale scar, cool reflected light lower-right. Two sprouts: a short stub and a curled one.
-- quirk: the long sprout ends in a hook carrying a tiny pair of true leaves, like a seedling waving.
local NAME = "potato"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD10_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local SK = { "#33201a", "#573727", "#82583a", "#a97a4a", "#cf9f62", "#ecc88a" }
local SP = { "#4a3050", "#7a5a80", "#a08a74", "#bcc080", "#d8e8a0", "#f0f8c4" }
local LF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local CUTS = { 0.3, 0.46, 0.6, 0.74, 0.88 }

c:groundShadow(29, 52, 16, 2.2)
local CXc, CYc, ANG = 31.5, 42.4, -0.1
local m = HP.mask()
for y = 24, 60 do for x = 0, 63 do
  local dx, dy = x + 0.5 - CXc, y + 0.5 - CYc
  local rx = dx * cos(ANG) + dy * sin(ANG)
  local ry = -dx * sin(ANG) + dy * cos(ANG)
  local u = rx / 21.8
  local v = ry / (10.6 * (1 - 0.17 * u))
  local rho, th = sqrt(u * u + v * v), math.atan(v, u)
  local lim = 1 + 0.07 * sin(3 * th + 0.7) + 0.05 * sin(5 * th + 2.1) + 0.035 * sin(7 * th + 4)
  if rho <= lim then m:set(x, y) end
end end
local dd = X.dist(m)
local R = 8
local function hf(x, y)
  local d = dd[K(x, y)]
  if not d then return 0 end
  local t = min(d + 0.5, R) / R
  return R * sqrt(1 - (1 - t) ^ 2) + 2.6 * (G.vnoise(x, y, 5.5, 3) - 0.5) + 0.8 * (G.vnoise(x, y, 2.2, 5) - 0.5)
end
local n = {}
m:each(function(x, y)
  local gx, gy = (hf(x + 1, y) - hf(x - 1, y)) / 2, (hf(x, y + 1) - hf(x, y - 1)) / 2
  n[K(x, y)] = { G.nrm(-gx, -gy, 1) }
end)
local v = X.light(n, { amb = 0.1, wrap = 0.25 })

-- sprout bases (needed first for AO): eye A (long sprout) and eye B (stub)
local EA, EB = { 36, 36 }, { 23, 37.5 }
local bias = {}
local function ring(e) for dy = -2, 2 do for dx = -2, 2 do
  local d = sqrt(dx * dx + dy * dy)
  if d <= 2.4 and m:has(floor(e[1]) + dx, floor(e[2]) + dy) then bias[K(floor(e[1]) + dx, floor(e[2]) + dy)] = -1 end
end end end
ring(EA) ring(EB)
local tok = { r = { name = "skin" } }
local idx = X.tone(c, m, v, SK, { cuts = CUTS, tok = tok, bias = bias })
local spc = X.spec(n, 14)
local rim = X.rim(n)
m:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 11)
  local i = idx[k]
  -- lenticels: short dark dashes; pale flecks
  if h > 0.955 and not bias[k] and m:has(x + 1, y) then c:put(x, y, SK[max(1, i - 1)], tok) c:put(x + 1, y, SK[max(1, i - 2)], tok)
  elseif h < 0.025 then c:put(x, y, SK[min(6, i + 1)], tok) end
  -- dirt crumbs low on the skin
  local dn = G.vnoise(x, y, 3.2, 9)
  if dn > 0.8 and y > 44 and not bias[k] then c:put(x, y, X.hash(x, y, 2) > 0.5 and SK[2] or "#6e5238", tok) end
end)
-- cool reflected light lower-right
m:edge():each(function(x, y) if rim[K(x, y)] > 0.66 and y > 40 and x > 28 then c:put(x, y, "#86727c", tok) end end)
-- soft waxy highlight on the shoulder: 3x1 plus 1
local best, bx, by = -1, 0, 0
m:each(function(x, y) local s = spc[K(x, y)] if s > best or (s == best and x + y < bx + by) then best, bx, by = s, x, y end end)
for dx = 0, 2 do if m:has(bx + dx, by) then c:put(bx + dx, by, SK[6], tok) end end
c:put(bx - 1, by + 1, SK[5], tok)

-- eyes: dimple with a lit brow above-left and a shadow lip below
local eyes = { { 20, 44 }, { 29, 40 }, { 42, 47 }, { 31, 49 }, { 47, 41 } }
for _, e in ipairs(eyes) do
  local x, y = e[1], e[2]
  for dx = -1, 2 do c:put(x + dx, y - 1, dx < 1 and SK[5] or SK[4], tok) end
  for dx = -1, 2 do c:put(x + dx, y, (dx == -1) and SK[2] or SK[1], tok) end
  c:put(x, y + 1, SK[2], tok) c:put(x + 1, y + 1, SK[2], tok) c:put(x + 2, y + 1, SK[4], tok)
end
-- pale scar
for _, p in ipairs{ { 14, 40 }, { 15, 41 }, { 16, 41 }, { 17, 42 } } do if m:has(p[1], p[2]) then c:put(p[1], p[2], "#f6e6bc", tok) end end
c:put(15, 42, SK[2], tok) c:put(16, 42, SK[2], tok)

-- sprout A (long, hooked, with two leaves) and sprout B (stub)
local function sprout(p, w0, w1)
  local sm, sn, T = G.tube(p, function(t) return w0 + (w1 - w0) * t end)
  local st = { r = { name = "sprout" } }
  X.tone(c, sm, X.light(sn, { amb = 0.18, wrap = 0.3 }), SP, { cuts = { 0.22, 0.4, 0.58, 0.76, 0.9 }, tok = st })
  sm:each(function(x, y) if T[K(x, y)] < 0.1 then c:put(x, y, SP[2], st) end end)
  return sm
end
sprout({ { 36, 37 }, { 35.5, 31 }, { 40, 25.5 }, { 44, 27 } }, 2.0, 1.2)
sprout({ { 23, 38.5 }, { 21, 35 }, { 22, 32 }, { 24.5, 31.5 } }, 1.9, 1.2)
-- true leaves at the hook tip (quirk): two small serrated leaflets
local ltok = { r = { name = "leaf" } }
local function leaflet(cx, cy, ux, uy, ra, rb)
  local lm = G.rell(cx, cy, ux, uy, ra, rb)
  local ln = X.pillow(lm, 1.6)
  X.tone(c, lm, X.light(ln, { amb = 0.15, wrap = 0.3 }), LF, { cuts = CUTS, tok = ltok })
  lm:each(function(x, y) local dx, dy = x + 0.5 - cx, y + 0.5 - cy
    if abs(-dx * uy + dy * ux) < 0.4 and (dx * ux + dy * uy) > -ra * 0.6 then c:put(x, y, LF[6], ltok) end end)
  return lm
end
leaflet(46.2, 23.2, 0.8, -0.6, 3.1, 1.8)
leaflet(46.6, 29.2, 0.85, 0.5, 3.0, 1.7)
c:put(44, 26, SP[2]) c:put(44, 27, SP[3])
G.save2(c, NAME)
