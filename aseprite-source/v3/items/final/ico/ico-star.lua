-- ico-star (Opus artist pass): a bold faceted gold five-point star, tipped a few degrees for life.
-- Material: per-pixel light from a distance-field cone (ridges run from the centre to each tip, valleys to each
-- inner corner) snapped to a 6-tone gold ramp, so it reads as a cut, polished metal star. Bright bevel lip on the
-- upper-left edges, warm-violet deep in the lower-right valleys, ember reflected light on the shade rim, one
-- specular streak + cream glint on the top facet, a sunken centre dimple where the facets meet.
-- quirk: two specks of stardust trail off the lower-left arm, as if it just landed.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_aA10_2.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, max, min, sqrt, pi = math.floor, math.max, math.min, math.sqrt, math.pi
local c = D.new("ico-star")
local GOLD = D.GOLD
local tok = { r = { name = "gold" } }

local CX, CY = 32, 33
local ROT = -pi / 2 + 0.07
local m, pts = D.star(CX, CY, 24, 12.2, ROT)
local dist = X.dist(m)
-- facet normals: 10 planar triangles (raised centre, tips and inner corners at z = 0)
local H = 9
local function cross(ax, ay, az, bx, by, bz) return ay*bz - az*by, az*bx - ax*bz, ax*by - ay*bx end
local n = {}
m:each(function(x, y)
  local a = (math.atan(y - CY, x - CX) - ROT) % (2 * pi)
  local i = floor(a / (pi / 5)) % 10
  local A, B = pts[i + 1], pts[(i + 1) % 10 + 1]
  local nx, ny, nz = cross(A[1] - CX, A[2] - CY, -H, B[1] - CX, B[2] - CY, -H)
  if nz < 0 then nx, ny, nz = -nx, -ny, -nz end
  local l = sqrt(nx*nx + ny*ny + nz*nz)
  -- soften toward the rim so tips stay lit-readable
  n[K(x, y)] = { nx / l, ny / l, nz / l }
end)
local v = X.light(n, { amb = 0.16, wrap = 0.2 })
local bias = {}
-- dimple: the very centre sits a step down
m:each(function(x, y) local k = K(x, y) if (x - CX) ^ 2 + (y - CY) ^ 2 <= 1.6 then bias[k] = -1 end end)
local idx = X.tone(c, m, v, GOLD, { cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 }, bias = bias, tok = tok })
-- bevel lip: edge pixels facing up-left get one step brighter; lower-right edge gets ember reflected light
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y)
  local nn = n[k]
  local up = not m:has(x, y - 1) or not m:has(x - 1, y)
  local dn = not m:has(x, y + 1) or not m:has(x + 1, y)
  if up and not dn and idx[k] >= 3 then c:put(x, y, GOLD[min(6, idx[k] + 1)], tok)
  elseif dn and not up and rim[k] > 0.25 and idx[k] <= 3 then c:put(x, y, "#c8502e", tok) end
end)
-- specular streak along the top arm's lit facet + glint
local sp = X.spec(n, 30)
local best, bx, by
m:each(function(x, y) local s = sp[K(x, y)] if s and dist[K(x, y)] > 2 and (not best or s > best) then best, bx, by = s, x, y end end)
c:put(bx, by, D.CREAM, tok) c:put(bx + 1, by, GOLD[6], tok) c:put(bx, by + 1, GOLD[6], tok)
c:put(bx - 1, by + 2, GOLD[6], tok) c:put(bx - 1, by + 3, GOLD[6], tok)

-- quirk: stardust specks off the lower-left arm (3x3 then 2x2 + 1 glint each)
local function speck(x, y, s)
  for yy = 0, s - 1 do for xx = 0, s - 1 do c:put(x + xx, y + yy, GOLD[4], tok) end end
  c:put(x, y, GOLD[6], tok)
  if s >= 3 then c:put(x + 2, y + 2, GOLD[3], tok) c:put(x + 1, y + 2, GOLD[3], tok) c:put(x + 2, y + 1, GOLD[3], tok) end
end
speck(10, 55, 3) speck(6, 59, 2)
D.save(c, "ico-star")
