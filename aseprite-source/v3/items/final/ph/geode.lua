-- geode (final pass, Opus single pass). A half geode, cut face tilted toward the viewer: a knobbly warm-grey rind with
-- pits and a sawn stone rim, three agate bands (pale blue / cream / blue), and a cavity packed with faceted amethyst
-- points (Voronoi pyramids, lit left facets, violet shade facets, AO under the upper rim, cream tip glints).
-- quirk: a tuft of moss grows on the rind's lower-left shoulder, as if the geode sat in the forest for years.
local NAME = "geode"
local B = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_0.lua")
local HP, X, K = B.HP, B.X, B.K
local floor, max, min, abs, sin, cos, atan, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.atan, math.sqrt, math.pi
local c = B.new(NAME)
local ROCK = { "#3b2d37", "#574651", "#78656c", "#998789", "#b9aaa6", "#dbd0c6" }
local CUTR = { "#6d6170", "#948799", "#bcb0bb", "#e0d8da" }
local AG = { "#34507e", "#5f86bc", "#9cc3e6", "#e8f3f8" }
local AM = { "#2c1846", "#47286f", "#653c9c", "#8a5cc8", "#b388e6", "#dcc6ff" }
local MOSS = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }

-- rind body: knobbly ellipse
local CX, CY = 32, 33
local body = HP.mask()
for y = 8, 58 do for x = 6, 58 do
  local dx, dy = x - CX, y - CY
  local a = atan(dy, dx)
  local r = 1 + 0.045 * sin(a * 5 + 0.7) + 0.03 * sin(a * 9 + 2.1) + (X.hash(floor(a * 7), 1, 4) - 0.5) * 0.05
  if (dx / (21 * r)) ^ 2 + (dy / (17.5 * r)) ^ 2 <= 1 then body:set(x, y) end
end end
local n = X.pillow(body, 6)
local bias = {}
body:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 11)
  if h < 0.09 then bias[k] = -1 elseif h > 0.93 then bias[k] = 1 end
end)
local rtok = { r = { name = "rind" } }
B.shade(c, body, n, ROCK, { amb = 0.1, wrap = 0.3, bias = bias, tok = rtok })
-- pits: dark pixel with a lit lip above-left
for _, p in ipairs{ { 18, 46 }, { 27, 50 }, { 41, 49 }, { 48, 42 }, { 36, 52 }, { 14, 39 }, { 50, 35 } } do
  if body:has(p[1], p[2]) then c:put(p[1], p[2], ROCK[1], rtok) c:put(p[1] - 1, p[2] - 1, ROCK[4], rtok) end
end

-- cut face (tilted up): sawn stone rim -> agate bands -> crystal cavity
local FX, FY = 31, 29
local function ell(rx, ry, cx, cy) local m = HP.mask()
  for y = 0, 63 do for x = 0, 63 do if ((x - (cx or FX)) / rx) ^ 2 + ((y - (cy or FY)) / ry) ^ 2 <= 1 then m:set(x, y) end end end
  return m:clip(body) end
local face = ell(18.6, 14.6)
local band1 = ell(16.2, 12.4)
local band2 = ell(14.8, 11.1)
local band3 = ell(13.6, 10.0)
local cav = ell(12.2, 8.8, 31.5, 29.5)
local ftok = { r = { name = "face" } }
face:each(function(x, y)
  local h = X.hash(x, y, 7)
  local i = (x + y < FX + FY - 6) and 3 or 2
  if x + y > FX + FY + 14 then i = 2 end
  if h > 0.85 then i = i + 1 elseif h < 0.1 then i = i - 1 end
  c:put(x, y, CUTR[max(1, min(4, i))], ftok)
end)
-- sawn rim bevel: lit upper-left lip, darker lower-right lip
face:edge():each(function(x, y) c:put(x, y, (x - FX) + (y - FY) * 1.3 < 0 and CUTR[4] or CUTR[1], ftok) end)
local atok = { r = { name = "agate" } }
band1:each(function(x, y) c:put(x, y, AG[2], atok) end)
band2:each(function(x, y) c:put(x, y, AG[4], atok) end)
band3:each(function(x, y) c:put(x, y, AG[3], atok) end)
-- band shading: lower-right of each band one step darker (concave bowl: lit on the lower-right inner wall is subtle)
band1:copy():cut(band2):each(function(x, y) if (x - FX) * 0.4 + (y - FY) > 6 then c:put(x, y, AG[1], atok) end end)
band3:copy():cut(cav):each(function(x, y) if (x - FX) * 0.4 + (y - FY) < -5 then c:put(x, y, AG[2], atok) end end)

-- amethyst cavity: Voronoi pyramids
local pts = {}
local seedn = 0
for gy = 0, 5 do for gx = 0, 8 do
  seedn = seedn + 1
  local x = 19 + gx * 3.1 + (X.hash(gx, gy, 21) - 0.5) * 2.2 + (gy % 2) * 1.5
  local y = 21 + gy * 3.2 + (X.hash(gx, gy, 22) - 0.5) * 2.0
  if cav:has(floor(x + .5), floor(y + .5)) then pts[#pts + 1] = { x, y } end
end end
local an = {}
local nearest = {}
cav:each(function(x, y)
  local b1, b2, bp = 1e9, 1e9, nil
  for _, p in ipairs(pts) do local q = (x - p[1]) ^ 2 + (y - p[2]) ^ 2
    if q < b1 then b2 = b1 b1, bp = q, p elseif q < b2 then b2 = q end end
  local dx, dy = x - bp[1], y - bp[2]
  -- snap to 4 facets
  local fx, fy
  if abs(dx) >= abs(dy) then fx, fy = (dx >= 0 and 1 or -1), 0 else fx, fy = 0, (dy >= 0 and 1 or -1) end
  if dx == 0 and dy == 0 then fx, fy = 0, 0 end
  -- bowl: crystals near the wall lean inward (toward cavity centre)
  local wx, wy = (x - 31.5) / 12.2, (y - 29.5) / 8.8
  local nx, ny, nz = B.norm(fx * 0.9 - wx * 0.55, fy * 0.9 - wy * 0.55, 0.75)
  an[K(x, y)] = { nx, ny, nz }
  nearest[K(x, y)] = { bp, sqrt(b2) - sqrt(b1) }
end)
local abias = {}
-- AO: the upper-left rim overhangs the cavity
local rimSh = band3:copy():cut(cav)
X.ao(abias, cav, rimSh, 1, -1)
cav:each(function(x, y) local k = K(x, y)
  if (x - 31.5) / 12.2 * -0.5 + (y - 29.5) / 8.8 * -0.9 > 0.55 then abias[k] = (abias[k] or 0) - 1 end
  if nearest[k][2] < 0.6 then abias[k] = (abias[k] or 0) - 1 end  -- crease between crystals
end)
local amtok = { r = { name = "amethyst" } }
B.shade(c, cav, an, AM, { amb = 0.05, wrap = 0.15, bias = abias, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, tok = amtok })
-- tip glints on a few crystals (glossy material allows several)
local glints = 0
for _, p in ipairs(pts) do
  local x, y = floor(p[1] + .5), floor(p[2] + .5)
  if cav:has(x, y) and cav:has(x - 1, y) and X.hash(x, y, 5) > 0.55 and glints < 5 and (y - 29.5) > -6 then
    c:put(x, y, AM[6], amtok) glints = glints + 1
  end
end
c:sparkle(36, 31)

-- quirk: moss tuft on the lower-left shoulder of the rind
local mtok = { r = { name = "moss" } }
B.map(c, {
  "....d.....d.",
  "..d.cd..d.cd",
  ".dcbcd.dcbd.",
  "dcbbacdbbacd",
  "cbbaabbaabbc",
}, 9, 43, { a = MOSS[4], b = MOSS[3], c = MOSS[2], d = MOSS[1] }, mtok)

B.save(c, NAME)
