-- desert-gem (final, Opus single pass). A slim, tall kite-cut gem (short crown with a table, long pointed pavilion)
-- in sun-warmed magenta: every facet lit flat from its own normal, facet edges as 1 px lines in the darker neighbour
-- tone, a bright girdle bevel, pale internal core and back-lit fire in the lower pavilion, one cream sparkle.
-- quirk: it was just dug out of a dune: a little drift of golden sand still clings to the lower-left pavilion.
local NAME = "desert-gem"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new(NAME)
local GEM = { "#3e0f30", "#6e1648", "#a12462", "#d23c80", "#f56aa6", "#ffaccb", "#ffe0ec" }
local SAND = { "#8f5a24", "#c98a3a", "#e8b860", "#f8dc96" }
local gtok = { r = { name = "gem" } }

local TL, TR = { 25, 9 }, { 39, 9 }
local IL, IR = { 27.5, 15 }, { 36.5, 15 }
local GL, G1, G2, G3, GR = { 18, 22 }, { 25, 22 }, { 32, 22 }, { 39, 22 }, { 46, 22 }
local GLb, G1b, G2b, G3b, GRb = { 18, 24 }, { 25, 24 }, { 32, 24 }, { 39, 24 }, { 46, 24 }
local ML, MR = { 26, 42 }, { 38, 42 }
local CU = { 32, 56 }
-- facets: points, normal, extra (fire = brighten from inside)
local F = {
  { { TL, TR, IR, IL }, { 0, -0.25, 1 } },                          -- table
  { { TL, IL, G1, GL }, { -0.8, -0.55, 0.45 } },                     -- left crown
  { { IL, G2, G1 }, { -0.35, -0.65, 0.65 } },
  { { IL, IR, G2 }, { 0.05, -0.75, 0.6 } },
  { { IR, G3, G2 }, { 0.4, -0.6, 0.6 } },
  { { TR, GR, G3, IR }, { 0.85, -0.45, 0.4 } },                      -- right crown
  { { GLb, G1b, ML }, { -0.85, 0.15, 0.5 } },                        -- pavilion upper
  { { G1b, G2b, ML }, { -0.35, 0.2, 0.9 }, 1 },
  { { G2b, MR, ML }, { 0, 0.15, 1 }, 2 },
  { { G2b, G3b, MR }, { 0.35, 0.2, 0.9 }, 1 },
  { { G3b, GRb, MR }, { 0.85, 0.15, 0.5 } },
  { { GLb, ML, CU }, { -0.75, 0.4, 0.5 } },                          -- pavilion lower
  { { ML, MR, CU }, { 0.05, 0.4, 0.9 }, 1 },
  { { MR, GRb, CU }, { 0.7, 0.45, 0.5 }, 2 },                        -- lower right: back-lit fire
}
local all = HP.mask()
local tone = {}
local CUTS = { 0.12, 0.25, 0.4, 0.55, 0.72, 0.88 }
for i, f in ipairs(F) do
  local m = HP.poly(f[1])
  m:cut(all)
  local v = A.lv(f[2][1], f[2][2], f[2][3], { amb = 0.05, wrap = 0.15 })
  local ti = 1 for j, t in ipairs(CUTS) do if v >= t then ti = j + 1 end end
  ti = min(7, ti + (f[3] or 0))
  f.m, f.t = m, ti
  m:each(function(x, y) tone[K(x, y)] = { i, ti } end)
  all:add(m)
end
-- girdle band (rows 22-23): polished thin bevel, lit left, dark right
local girdle = HP.poly({ GL, GR, GRb, GLb })
girdle:cut(all)
for _, f in ipairs(F) do f.m:each(function(x, y) c:put(x, y, GEM[f.t], gtok) end) end
all:add(girdle)
-- facet edges: 1 px line in the darker neighbour tone (only where neighbour differs)
local edge = {}
all:each(function(x, y) local a = tone[K(x, y)] if not a then return end
  for _, d in ipairs{ { 1, 0 }, { 0, 1 } } do local b = tone[K(x + d[1], y + d[2])]
    if b and b[1] ~= a[1] then
      local px, py, t = x, y, a[2]
      if b[2] < a[2] then px, py, t = x + d[1], y + d[2], b[2] end
      edge[#edge + 1] = { px, py, max(1, t - 1) }
    end end end)
for _, e in ipairs(edge) do c:put(e[1], e[2], GEM[e[3]], gtok) end
girdle:each(function(x, y) local u = (x - 18) / 28 c:put(x, y, GEM[u < 0.4 and 7 or (u < 0.72 and 6 or 3)], gtok) end)
for x = 19, 45 do if all:has(x, 25) then c:put(x, 25, GEM[2], gtok) end end
-- bright edge along the lit top-left ridges
for _, q in ipairs{ { 25, 9 }, { 24, 10 }, { 23, 11 }, { 23, 12 }, { 22, 13 }, { 21, 14 }, { 21, 15 }, { 20, 16 }, { 20, 17 }, { 19, 18 }, { 19, 19 }, { 18, 20 } } do
  if all:has(q[1], q[2]) then c:put(q[1], q[2], GEM[7], gtok) end end
for x = 26, 38 do c:put(x, 9, GEM[6], gtok) end
-- pale core inside the table (glass cue) and a cool reflected glint on the right pavilion
for _, q in ipairs{ { 30, 11 }, { 31, 11 }, { 32, 11 }, { 30, 12 }, { 31, 12 }, { 31, 13 } } do c:put(q[1], q[2], GEM[7], gtok) end
for _, q in ipairs{ { 43, 27 }, { 42, 29 }, { 41, 31 } } do c:put(q[1], q[2], "#c9b2f0", gtok) end
-- fire sparks in the pavilion
c:put(33, 30, GEM[7], gtok) c:put(34, 31, GEM[6], gtok) c:put(36, 47, GEM[7], gtok)
-- sparkle (cream plus) on the table corner
for _, q in ipairs{ { 27, 9 }, { 27, 10 }, { 27, 11 }, { 26, 10 }, { 28, 10 } } do c:put(q[1], q[2], A.CREAM, gtok) end

-- quirk: sand drift clinging on the lower-left pavilion edge, a few grains trickling down
local stok = { r = { name = "sand" } }
local drift = HP.poly({ { 17.5, 29 }, { 20, 27.5 }, { 23, 29 }, { 26, 33 }, { 27.5, 38 }, { 25, 40 }, { 22, 38 }, { 19.5, 34 } })
drift:each(function(x, y)
  local edgeL = not drift:has(x - 1, y) or not drift:has(x, y - 1)
  local i = edgeL and 4 or (X.hash(x, y, 2) > 0.7 and 2 or 3)
  if not drift:has(x + 1, y) or not drift:has(x, y + 1) then i = 2 end
  c:put(x, y, SAND[i], stok)
end)
-- AO line where the sand meets the gem (contact shadow on the facet below/right)
drift:shift(1, 1):each(function(x, y) if all:has(x, y) and not drift:has(x, y) then c:put(x, y, GEM[2], gtok) end end)
c:put(20, 29, SAND[4], stok) c:put(23, 31, SAND[1], stok) c:put(24, 35, SAND[1], stok)

A.save(c, NAME)
