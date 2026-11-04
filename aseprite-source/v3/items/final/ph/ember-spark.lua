-- ember-spark (final, Opus single pass). A slim, tilted spark-crystal of ember glass: a short faceted crown over a long
-- tapering pavilion, eight flat facets lit from the upper left (6-tone ember-glass ramp). A coal-bright core glows
-- inside and lifts the facets around it; crown ridges are picked out bright, pavilion ridges dark, the girdle catches a
-- bright line on the lit half. Bright glass rim on the upper-left edge, cool bounce on the lower-right edge, a cream
-- specular and one sparkle (glossy material).
-- quirk: a hairline crack runs in from the right girdle and the inner fire leaks through it.
local NAME = "ember-spark"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new(NAME)
local EG = { "#4e1426", "#82262c", "#bd3f26", "#e86a26", "#ffa03a", "#ffd274" }
local CORE, RIM, COOL, SPEC = "#fff0b4", "#ffeab0", "#6a3a6a", A.CREAM

local T, L, R, B, C = { 35, 7 }, { 23, 25 }, { 42, 27 }, { 29, 57 }, { 32, 30 }
local ML = { (L[1] + C[1]) / 2, (L[2] + C[2]) / 2 - 0.5 }
local MR = { (C[1] + R[1]) / 2, (C[2] + R[2]) / 2 - 0.5 }
local facets = {
  { { T, L, ML }, 6 }, { { T, ML, C }, 5 }, { { T, C, MR }, 4 }, { { T, MR, R }, 3 },
  { { L, ML, B }, 4 }, { { ML, C, B }, 3 }, { { C, MR, B }, 2 }, { { MR, R, B }, 1 },
}
local tok = A.tok("crystal")
local all = HP.mask()
local base = {}
for _, f in ipairs(facets) do
  local pts = {}
  for _, p in ipairs(f[1]) do pts[#pts + 1] = { p[1], p[2] } end
  local m = HP.poly(pts)
  m:add(HP.line(pts, 1):clip(m:grow(1)))
  m:each(function(x, y) local k = K(x, y) if not base[k] then base[k] = f[2] end all:set(x, y) end)
end
-- inner glow: lift tones around the core
local cx, cy = 31, 34
all:each(function(x, y) local k = K(x, y)
  local d = sqrt((x - cx) ^ 2 + ((y - cy) * 0.6) ^ 2)
  local i = base[k] + (d < 4.5 and 1 or 0)
  c:put(x, y, EG[max(1, min(6, i))], tok)
end)
-- ridges: crown ridges bright, pavilion ridges dark, girdle bright on the lit half
local E = all:edge()
local function ridge(a, b, col) HP.line({ a, b }, 1):each(function(x, y) if all:has(x, y) and not E:has(x, y) then c:put(x, y, col, tok) end end) end
ridge(T, ML, EG[6]) ridge(T, C, EG[6]) ridge(T, MR, EG[5])
ridge(L, ML, EG[6]) ridge(ML, C, EG[5]) ridge(C, MR, EG[4]) ridge(MR, R, EG[3])
ridge(ML, B, EG[2]) ridge(C, B, EG[3]) ridge(MR, B, EG[1])
-- core: pale hot heart
for _, p in ipairs{ { 0, -2 }, { 0, -1 }, { 1, -1 }, { 0, 0 }, { 1, 0 }, { -1, 0 }, { 0, 1 }, { 1, 1 }, { 0, 2 } } do
  c:put(cx + p[1], cy + p[2], (abs(p[1]) + abs(p[2]) <= 1) and CORE or EG[6], tok) end
-- rim: bright glass edge upper-left (T-L), cool bounce on the lower-right (R-B)
E:each(function(x, y)
  local onTL = abs((x - T[1]) * (L[2] - T[2]) - (y - T[2]) * (L[1] - T[1])) / 21.6 < 1.1
  local onRB = abs((x - R[1]) * (B[2] - R[2]) - (y - R[2]) * (B[1] - R[1])) / 31.8 < 1.1
  if onTL and y > T[2] + 1 and y < L[2] - 1 then c:put(x, y, RIM, tok)
  elseif onRB and y > R[2] + 3 and y < B[2] - 4 then c:put(x, y, COOL, tok) end
end)
-- specular 2x1 + sparkle on the lit crown facet
c:put(30, 14, SPEC, tok) c:put(30, 15, SPEC, tok) c:put(31, 13, EG[6], tok)
c:sparkle(29, 19)
-- quirk: glowing hairline crack from the right girdle
for i, p in ipairs{ { 41, 28 }, { 40, 29 }, { 39, 29 }, { 38, 30 }, { 38, 31 }, { 37, 32 }, { 36, 32 } } do
  if all:has(p[1], p[2]) then c:put(p[1], p[2], i < 3 and EG[6] or CORE, tok) end end
for _, p in ipairs{ { 39, 30 }, { 37, 33 }, { 40, 30 } } do if all:has(p[1], p[2]) then c:put(p[1], p[2], EG[5], tok) end end
A.save(c, NAME)
