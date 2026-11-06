-- ico-sun-rain (Opus artist pass): a sun peeking out from behind a soft rain cloud, three slanted drops falling.
-- Material: sun is a per-pixel sphere, 6-tone gold, cream specular, short faceted rays on the open side only;
-- it darkens where the cloud passes in front (contact shadow). Cloud: height field of billow domes so the creases
-- fall dark by themselves, 6-tone cool ramp, flat shaded belly, warm sunlit rim on the billows facing the sun.
-- Drops: 4-tone sea teardrops with a bright glass rim and a pale core. quirk: the last drop lands in a tiny splash
-- crown.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_aA10_3.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, max, min, sqrt, abs, sin, cos, pi = math.floor, math.max, math.min, math.sqrt, math.abs, math.sin, math.cos, math.pi
local c = D.new("ico-sun-rain")
local SU, RY, CL, RN = D.SUN, D.RAY, D.CLOUD, D.RAIN
local stok, rtok, ctok, wtok = { r = { name = "sun" } }, { r = { name = "ray" } }, { r = { name = "cloud" } }, { r = { name = "rain" } }

-- cloud shape first (masks only), so the sun can be shadowed by it
local lobes = { { 31, 33, 7, 6 }, { 41, 27.5, 9.5, 9 }, { 50.5, 33, 6.5, 6 }, { 26, 37, 4.2, 3.6 } }
local cm = HP.mask()
for _, l in ipairs(lobes) do cm:add(D.ell(l[1], l[2], l[3], l[4])) end
cm:add(D.ell(39.5, 37.5, 16, 3.6))
local function ch(x, y)
  local best = 0
  for _, l in ipairs(lobes) do
    local q = ((x - l[1]) / (l[3] + 0.5)) ^ 2 + ((y - l[2]) / (l[4] + 0.5)) ^ 2
    if q < 1 then best = max(best, l[4] * sqrt(1 - q)) end
  end
  local q = ((x - 39.5) / 16.5) ^ 2 + ((y - 37.5) / 4.1) ^ 2
  if q < 1 then best = max(best, 3.2 * sqrt(1 - q)) end
  return best
end

-- sun
local SX, SY, SR = 24, 23, 10.5
for i = 0, 7 do
  local a = pi * 0.5 + i * pi / 4
  local deg = (i * 45 + 90) % 360
  if deg >= 135 and deg <= 315 or deg == 0 then
    local ux, uy = cos(a), sin(a)
    local px, py = -uy, ux
    local r0, r1, hw = 13.2, (i % 2 == 0) and 17.6 or 16.6, 3.2
    local m = D.poly{ { SX + ux * r0 + px * hw, SY + uy * r0 + py * hw }, { SX + ux * r1, SY + uy * r1 }, { SX + ux * r0 - px * hw, SY + uy * r0 - py * hw } }
    m:cut(cm:grow(1))
    local n = {}
    m:each(function(x, y)
      local s = (x - SX) * px + (y - SY) * py
      local sg = abs(s) < 0.35 and 0 or (s > 0 and 1 or -1)
      local nx, ny, nz = px * sg * 0.75 + ux * 0.25, py * sg * 0.75 + uy * 0.25, 0.62
      local l = sqrt(nx * nx + ny * ny + nz * nz)
      n[K(x, y)] = { nx / l, ny / l, nz / l }
    end)
    D.tone(c, m, n, RY, { amb = 0.1, wrap = 0.2, tok = rtok, cuts = { 0.25, 0.45, 0.65, 0.82 } })
  end
end
local sm = D.ell(SX, SY, SR, SR)
local sn = X.sphere(SX - 0.4, SY - 0.4, SR, sm)
local sb = {}
G.cast(sb, sm, cm, -1, -1, -1)
G.cast(sb, sm, cm, -2, -2, -1)
D.tone(c, sm, sn, SU, { amb = 0.1, wrap = 0.3, bias = sb, tok = stok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 } })
c:put(19, 17, D.CREAM, stok) c:put(20, 17, SU[6], stok) c:put(19, 18, SU[6], stok) c:put(18, 19, SU[6], stok)

-- cloud (in front)
local cn = D.hnorm(cm, ch)
local cb = {}
cm:each(function(x, y) if y >= 39 then cb[K(x, y)] = -1 end end)
local cidx = D.tone(c, cm, cn, CL, { amb = 0.14, wrap = 0.4, bias = cb, tok = ctok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
-- creases between billows
local function arg(x, y)
  local best, bi = 0, 0
  for i, l in ipairs(lobes) do
    local q = ((x - l[1]) / (l[3] + 0.5)) ^ 2 + ((y - l[2]) / (l[4] + 0.5)) ^ 2
    if q < 1 and l[4] * sqrt(1 - q) > best then best, bi = l[4] * sqrt(1 - q), i end
  end
  return bi
end
cm:each(function(x, y)
  local a = arg(x, y)
  if a > 0 and y < 37 then
    local l = cm:has(x - 1, y) and arg(x - 1, y) or 0
    local u = cm:has(x, y - 1) and arg(x, y - 1) or 0
    if (l > 0 and l ~= a and lobes[l][4] > lobes[a][4]) or (u > 0 and u ~= a and lobes[u][4] > lobes[a][4]) then D.shift(c, x, y, CL, -2) end
    if (l > 0 and l ~= a and lobes[l][4] < lobes[a][4]) then D.shift(c, x, y, CL, -1) end
  end
end)
-- warm sunlit rim on the billow edges facing the sun
cm:edge():each(function(x, y)
  if (x - SX) ^ 2 + (y - SY) ^ 2 < (SR + 9) ^ 2 and y < 34 and (not cm:has(x - 1, y) or not cm:has(x, y - 1)) then c:put(x, y, "#fff0c0", ctok) end
end)
c:put(37, 21, CL[6], ctok) c:put(38, 21, CL[6], ctok)

-- rain drops: slanted teardrops (round belly, tip up-right in the wind), glass rim + pale core
local function drop(x, y)
  local m = D.ell(x, y, 2.5, 2.7)
  m:add(D.poly{ { x - 2.3, y - 0.8 }, { x + 1.0, y - 5.6 }, { x + 2.5, y - 0.4 } })
  local n = X.sphere(x - 0.3, y - 0.8, 2.6, m)
  D.tone(c, m, n, RN, { amb = 0.12, wrap = 0.3, tok = wtok, cuts = { 0.3, 0.55, 0.85 } })
  -- bright glass rim on the lower-right, pale core highlight upper-left
  c:put(floor(x - 1), floor(y - 1), "#e6fff6", wtok)
  return m
end
drop(30, 49) drop(50, 47.5)
local d3 = drop(39.5, 52.5)
-- quirk: the middle drop lands in a tiny splash crown (puddle lip + two flung droplets)
local base = 57
for x = 34, 45 do c:put(x, base, (x < 37 and RN[3]) or (x > 42 and RN[1]) or RN[2], wtok) end
c:put(35, base - 1, RN[3], wtok) c:put(44, base - 1, RN[2], wtok)
c:put(33, base - 3, RN[3], wtok) c:put(33, base - 4, RN[4], wtok)
c:put(46, base - 3, RN[2], wtok) c:put(46, base - 4, RN[3], wtok)
D.save(c, "ico-sun-rain")
