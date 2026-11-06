-- bromeliad-seeds (final, Opus aB13_1 single pass). Three slim brown spindle seeds, each trailing a fan of silky
-- silver coma hairs, lying on a torn strap of bromeliad leaf (long narrow blade, little hooked teeth along both edges,
-- pale silvery trichome cross-bands, V-fold light, ragged torn foot, AO + contact shadow under each seed). The fourth
-- seed has germinated into a tiny rosette: five stiff pointed strap leaves fanned from a tight base round a pink bract.
-- quirk: the rosette's cup already holds one bead of water, as a tank bromeliad should.
local NAME = "bromeliad-seeds"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB13_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = A.new(NAME)

local LEAF = { "#1d3338", "#2c4d48", "#3f6a55", "#5a8a62", "#82aa78", "#b4cc9a" }
local BAND, COOL = "#d4dfc2", "#38606e"
local ROS = { "#173f36", "#22593e", "#327848", "#4c9a50", "#7cbf5c", "#b4de82" }
local TIPR = "#b8456a"
local PINK = { "#6e2048", "#a8305e", "#d84c78", "#f27a98", "#ffb0c4" }
local SEED = { "#26141a", "#42221f", "#62341f", "#844a28", "#a8683a", "#d09658" }
local HAIR = { "#ece6d2", "#a9a4a0" }
local WATER = { "#2a4a7a", "#3a86b0", "#7cd0dc", "#fff4d6" }

-- seeds: cx, cy, rx, ry, angle (spindles lie along the leaf)
local seeds = { { 16, 51.5, 3.5, 1.8, -0.5 }, { 24, 49, 3.5, 1.8, -0.2 }, { 31.5, 44.5, 3.3, 1.7, -0.7 }, { 41, 41, 3.0, 1.7, -0.3 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end

-- strap leaf: long narrow blade with hooked teeth on both margins
local lm, ln, LT, LS, len = A.blade(9, 55, 31, 46, 57, 35, function(t)
  if t > 0.995 then return -1 end
  local w = 3.7 * (1 - t ^ 3) + 0.4
  local ph = (t * 60 / 4.2) % 1
  if ph < 0.22 and t > 0.06 and t < 0.92 then w = w + 1.0 end
  return w
end, { fold = 0.55 })
-- ragged torn foot
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  if LT[k] < 0.03 + 0.04 * (sin(LS[k] * 7) + 1) * 0.5 + 0.02 * X.hash(x, y, 5) then cut[#cut + 1] = k end end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.26, 0.44, 0.6, 0.76, 0.9 }, amb = 0.1, wrap = 0.2 })
local ledge = lm:edge()
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[2], ltok) return end
  -- silver trichome cross-bands
  local d = (t * len + abs(s) * 1.5) % 6.0
  if d < 0.9 and abs(s) < 0.8 then c:put(x, y, s < 0 and LEAF[5] or LEAF[4], ltok) return end
  if ledge:has(x, y) and s > 0.5 then c:put(x, y, COOL, ltok) end
end)
-- teeth tips darker
lm:each(function(x, y) local k = K(x, y)
  if ledge:has(x, y) and abs(LS[k]) > 0.93 and LT[k] > 0.06 then c:put(x, y, LEAF[2], ltok) end end)

-- rosette sprout from seed 4
local rtok = { r = { name = "rosette" } }
local bx, by = 42, 40
local rosm = HP.mask()
local blades = { { 29, 27, 2.0 }, { 35, 17, 2.1 }, { 44, 14, 2.0 }, { 52, 19, 2.1 }, { 57, 29, 1.9 } }
for _, b in ipairs(blades) do
  local mx, my = (bx + b[1]) / 2, (by + b[2]) / 2
  local m, T = A.leaf(c, bx, by, mx + (b[1] < bx and 1 or -1), my - 2, b[1], b[2], b[3], ROS,
    { tok = rtok, cut = rosm, vs = 3.0, fold = 0.5, pw = 0.5 })
  -- red-blushed tip
  m:each(function(x, y) if T[K(x, y)] > 0.82 then c:put(x, y, TIPR, rtok) end end)
  rosm:add(m)
end
-- pink bract spike in the centre
local pm = HP.mask()
for y = 26, 39 do for x = 39, 46 do
  local t = (y - 26) / 13
  local hw = 0.6 + 2.4 * sin(pi * (0.15 + t * 0.7)) ^ 0.8
  if abs(x - 42.5 - (1 - t) * 0.0) <= hw then pm:set(x, y) end
end end
local pn = A.body(pm, 42, 32, 4, 2, 0.5)
local pidx = A.shade(c, pm, pn, PINK, { amb = 0.08, wrap = 0.25, cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = rtok })
-- bract scales: chevrons
pm:each(function(x, y) local k = K(x, y) if (y + abs(x - 42.5) * 0.9) % 3 < 0.7 and y > 27 and y < 38 then c:put(x, y, PINK[max(1, (pidx[k] or 3) - 1)], rtok) end end)
-- front short blades hugging the base (the cup)
local f1 = A.leaf(c, 41, 42, 37, 38, 34, 35, 1.6, ROS, { tok = rtok, vs = 3.0 })
local f2 = A.leaf(c, 43, 42, 47, 38, 50, 36, 1.6, ROS, { tok = rtok, vs = 3.0 })
-- quirk: a bead of water in the cup
for _, p in ipairs{ { 44, 37, 2 }, { 45, 37, 2 }, { 44, 38, 1 }, { 45, 38, 3 }, { 43, 38, 2 }, { 44, 36, 3 } } do c:put(p[1], p[2], WATER[p[3]], rtok) end
c:put(44, 37, WATER[4], rtok)
-- root hair from seed 4 over the leaf
for _, p in ipairs{ { 44, 43 }, { 45, 44 }, { 47, 44 }, { 46, 44 } } do c:put(p[1], p[2], "#c8dca0", rtok) end

-- seeds: spindles with a coma of silky hairs trailing from the back end
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  if i < 4 then
    -- hairs fan out from the rear (left) end
    local hx, hy = s[1] - ca * (s[3] + 0.5), s[2] - sa * (s[3] + 0.5)
    for h, a in ipairs{ -0.5, 0.0, 0.5 } do
      local dx, dy = A.rot(-ca, -sa, a)
      local L = 4 + (h % 2)
      for st = 1, L do
        local x, y = floor(hx + dx * st + 0.5), floor(hy + dy * st + 0.5 + (st > 3 and a * 0.4 or 0))
        if not s.m:has(x, y) then c:put(x, y, (h + st) % 3 == 0 and HAIR[2] or HAIR[1], tok) end
      end
    end
  end
  local sb = {}
  for j = i + 1, #seeds do X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local vis = s.m:copy()
  if i == 4 then vis:cut(rosm) end
  local idx = A.shade(c, vis, s.n, SEED, { amb = 0.06, wrap = 0.22, bias = sb, tok = tok })
  -- a dark seam line along the spindle's shade side
  vis:each(function(x, y) local dx, dy = x - s[1], y - s[2]
    local v = (-dx * sa + dy * ca) / (s[4] + 0.45)
    if v > 0.35 and v < 0.75 and abs(dx * ca + dy * sa) < s[3] - 1 then c:put(x, y, SEED[2], tok) end end)
  local sx, sy = A.specAt(vis, s.n, 40)
  if sx then c:put(sx, sy, i == 2 and A.CREAM or SEED[6], tok) end
end

A.save(c, NAME)
