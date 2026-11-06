-- nav-world (C3, Opus single pass): a varnished desk globe held by a slim brass half-meridian on a turned walnut
-- stand. Material: per-pixel sphere light (6-tone ocean, 6-tone land), shallow-water halo along coasts, ice cap,
-- dotted equator + curved meridian, varnish glint (2x1) and a cool reflected rim lower-right; brass tube light with
-- bright edge + pins at the poles; walnut stem with ring grooves and an elliptical foot with lit bevel; AO where the
-- arc enters the stem.
-- quirk: a tiny striped hot-air balloon drifts past the top-left of the globe.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_0.lua")
local HP, X, K, tok = A.HP, A.X, A.K, A.tok
local floor, abs, max, min, sqrt, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.pi
local c = A.new("nav-world")
local SEA  = { "#1c2a5e", "#24427e", "#2f64a6", "#3f8cc8", "#68b6e0", "#a8e0f2" }
local LAND = { "#1d4a3a", "#2c6a40", "#3f8c46", "#5eac4e", "#8acb5e", "#bfe484" }
local WAL  = { "#2e1c1c", "#4a2a26", "#6a3c2c", "#8a5236", "#ab6c44", "#cf9462" }
local BR = A.BRASS
local CX, CY, R = 31, 29, 17

-- stand foot + stem
local foot = A.ell(31, 55, 10.5, 2.6)
local fb = {}
foot:each(function(x, y) if y >= 56 then fb[K(x, y)] = -1 end end)
A.pil(c, foot, WAL, 2, { bias = fb, tok = tok("foot") })
for x = 24, 30 do if foot:has(x, 53) then c:put(x, 53, WAL[6], tok("foot")) end end
for x = 21, 41 do if foot:has(x, 56) and X.hash(x, 56, 4) > 0.55 then c:put(x, 56, WAL[2], tok("foot")) end end
local stem = c:rect(29, 48, 33, 53)
A.vcyl(c, stem, WAL, 29, 33, { tok = tok("stem") })
for x = 29, 33 do c:put(x, 50, WAL[2], tok("stem")) c:put(x, 51, WAL[5], tok("stem")) c:put(x, 53, WAL[1], tok("stem")) end
c:put(30, 51, WAL[6], tok("stem"))

-- brass half meridian (right side), behind the globe
local arcm = A.arc(c, CX, CY, 20.4, -pi / 2 - 0.12, pi / 2 + 0.12, 1.2, BR, { tok = tok("arc") })
-- bright edge on the outer top-right
arcm:each(function(x, y) local dx, dy = x - CX, y - CY local d = sqrt(dx * dx + dy * dy)
  if d > 20.6 and dy < -6 and dx > 2 and X.hash(x, y, 2) > 0.3 then c:put(x, y, BR[6], tok("arc")) end end)
-- pole pins
for y = 9, 12 do c:put(31, y, BR[4], tok("pin")) c:put(32, y, BR[3], tok("pin")) end
for y = 46, 49 do c:put(31, y, BR[3], tok("pin")) c:put(32, y, BR[2], tok("pin")) end
c:put(31, 9, BR[6], tok("pin"))
-- AO where the arc enters the stem
c:put(33, 48, WAL[1], tok("stem")) c:put(29, 48, WAL[2], tok("stem"))

-- globe
local gm = c:ellipse(CX, CY, R, R)
local n = X.sphere(CX - .3, CY - .3, R, gm)
local v = X.light(n, { amb = 0.05, wrap = 0.2 })
-- land mask: blobs + noisy coast
local land = HP.mask()
for _, e in ipairs{
  { 20, 20, 5.5, 5, 0.3 }, { 24, 28, 3, 4.5, -0.3 }, { 26, 36, 2.6, 4.5, 0.2 },
  { 37, 18, 7, 3.6, 0.15 }, { 41, 23, 5, 3.4, 0.4 }, { 36, 31, 3.6, 5, -0.15 }, { 44, 36, 2.2, 1.8, 0 },
} do land:add(A.ell(e[1], e[2], e[3], e[4], e[5])) end
local edge = land:edge()
edge:each(function(x, y) if X.hash(x, y, 11) > 0.65 then land.s[K(x, y)] = nil end end)
land:grow(1):cut(land):each(function(x, y) if X.hash(x, y, 12) > 0.86 then land:set(x, y) end end)
land:clip(gm:shrink(1))
local sea = gm:copy():cut(land)
local cuts = { 0.16, 0.34, 0.52, 0.7, 0.88 }
local sidx = X.tone(c, sea, v, SEA, { cuts = cuts, tok = tok("globe") })
local lidx = X.tone(c, land, v, LAND, { cuts = cuts, tok = tok("globe") })
-- shallow-water halo
land:grow(1):cut(land):each(function(x, y) if sea:has(x, y) then c:put(x, y, SEA[min(6, sidx[K(x, y)] + 1)], tok("globe")) end end)
-- relief: lit north-west coast rows on land, dark south-east
land:each(function(x, y) local i = lidx[K(x, y)]
  if not land:has(x - 1, y - 1) and i < 6 then c:put(x, y, LAND[i + 1], tok("globe"))
  elseif not land:has(x + 1, y + 1) and i > 1 then c:put(x, y, LAND[i - 1], tok("globe")) end end)
-- ice cap
for y = 12, 14 do for x = CX - 6, CX + 6 do if gm:has(x, y) and X.hash(x, y, 5) > (y - 12) * 0.35 then
  c:put(x, y, (x < CX + 2) and "#f2f6fa" or "#c4d6e6", tok("globe")) end end end
-- equator (dotted) + curved meridian
for x = CX - R + 1, CX + R - 1, 2 do if sea:has(x, CY) then c:put(x, CY, SEA[max(1, sidx[K(x, CY)] - 1)], tok("globe")) end end
for y = CY - R + 3, CY + R - 3, 2 do
  local x = floor(CX + 7 * sqrt(1 - ((y - CY) / R) ^ 2) + .5)
  if sea:has(x, y) then c:put(x, y, SEA[max(1, sidx[K(x, y)] - 1)], tok("globe")) end
end
-- cool reflected rim lower-right
local rim = X.rim(n)
gm:edge():each(function(x, y) if rim[K(x, y)] > 0.62 then c:put(x, y, "#5a7ec8", tok("globe")) end end)
-- varnish glint
c:put(22, 17, A.CREAM, tok("globe")) c:put(23, 17, A.CREAM, tok("globe")) c:put(21, 18, "#d8f2fa", tok("globe")) c:put(24, 16, "#d8f2fa", tok("globe"))

-- quirk: tiny hot-air balloon
local bal = A.ell(12, 10, 3.3, 3.6)
local bv = X.light(X.sphere(12, 10, 3.6, bal), { amb = 0.1, wrap = 0.3 })
bal:each(function(x, y)
  local stripe = (x == 11 or x == 14)
  local r = stripe and { "#8a6a50", "#c8b08c", "#ecdcb8", "#fff4d6" } or { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
  local i = max(1, min(4, floor(bv[K(x, y)] * 4) + 1))
  c:put(x, y, r[i], tok("bal"))
end)
c:put(10, 8, "#fff4d6", tok("bal"))
c:put(10, 14, "#8a6a50", tok("bal")) c:put(14, 14, "#8a6a50", tok("bal"))
c:put(11, 15, "#8a6a50", tok("bal")) c:put(13, 15, "#8a6a50", tok("bal"))
c:fillMask(c:rect(11, 16, 13, 17), "#b97a4a") c:put(11, 16, "#e8b982") c:put(13, 17, "#864c33")

A.fin()
