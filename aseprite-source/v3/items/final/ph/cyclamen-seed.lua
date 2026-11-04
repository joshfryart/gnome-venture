-- cyclamen-seed (final, Opus single pass). Three round, slightly angular cyclamen seeds (sticky orange-brown coat with a
-- pale sugary bloom and a hilum dimple) on a torn scrap of cyclamen leaf: heart-shaped base sinus, dark green blade
-- with the silver "fir tree" marbling band, midrib and curved veins, a pale torn edge, AO and contact shadows under
-- the seeds. The middle seed has germinated: a red-violet petiole lifts its single heart-shaped seed leaf, silver-
-- marbled like the parent, with a purple underside peeking at the rim.
-- quirk: a tiny ant (cyclamen seeds are spread by ants) is hauling a fourth seed off the leaf tip.
local NAME = "cyclamen-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin, cos, pi, atan = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi, math.atan
local c = A.new(NAME)

local LEAF = { "#14302a", "#1f4634", "#2c5e3e", "#3f7a48", "#5c9858", "#86b870" }
local SILV = { "#4a6a5c", "#7a9a88", "#a8c4b2", "#d2e6d6" }
local SEED = { "#3c1e1a", "#62301e", "#8c4a24", "#b46a30", "#d89448", "#f4c27a" }
local STEM = { "#4a1e3a", "#7a2c50", "#a8406a", "#d0708e" }
local UNDER = "#7a3a6a"
local TORN = "#a8cc8a"

-- heart-shaped leaf in local coords: axis from base (bx,by) toward the tip, u along, v across (+v = lower-right side)
local function heart(bx, by, ang, L, W, torn, seedx)
  local ux, uy = cos(ang), sin(ang)
  local px, py = -uy, ux
  if px + py < 0 then px, py = -px, -py end
  local m, U, V = HP.mask(), {}, {}
  for y = floor(by - L - 4), floor(by + L + 4) do for x = floor(bx - L - 4), floor(bx + L + 4) do
    local dx, dy = x - bx, y - by
    local u, v = (dx * ux + dy * uy) / L, (dx * px + dy * py) / W
    -- cardioid-ish: ellipse body, pointed tip, sinus notch at the base
    local uu = u - 0.5
    local half = sqrt(max(0, 0.25 - uu * uu)) * 2 * (1 - 0.35 * max(0, u - 0.55) / 0.45)
    local ok = abs(v) <= half and u >= 0 and u <= 1
    if u < 0.2 and abs(v) < (0.2 - u) * 1.6 then ok = false end
    if ok and torn and torn(u, v, x, y) then ok = false end
    if ok then m:set(x, y) U[K(x, y)] = u V[K(x, y)] = v end
  end end
  return m, U, V, ux, uy, px, py
end

-- 1. leaf scrap
local tear = function(u, v, x, y)
  -- upper (lit) side torn off in a jagged line across the blade
  local edge = -0.22 - 0.25 * sin(u * 23) * 0.6 - (X.hash(floor(u * 30), 1, 4) - 0.5) * 0.35
  return v < edge and u > 0.32 and u < 0.95
end
local lm, LU, LV, lux, luy, lpx, lpy = heart(8, 44, -0.16, 46, 17, tear)
local ln = {}
lm:each(function(x, y) local k = K(x, y)
  local s = LV[k]
  local sx = (s < 0 and -0.4 or 0.4) * 0.9 + s * 0.3          -- shallow V fold along the midrib
  local cup = (LU[k] - 0.5) * 0.4                              -- tip curls down a little
  ln[k] = { A.norm(lpx * sx + lux * cup, lpy * sx + luy * cup, 1) }
end)

-- seeds
local seeds = { { 21, 42, 2.9, 2.6, 0.5 }, { 31, 41, 3.0, 2.7, -0.3 }, { 39, 44, 2.8, 2.5, 0.9 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.85) end

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.shade(c, lm, ln, LEAF, { tok = ltok, bias = bias, amb = 0.12, wrap = 0.3, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local u, v = LU[k], LV[k]
  local r = abs(v)
  -- silver fir-tree band: zig-zag ring inside the margin
  local zz = 0.5 + 0.09 * sin(u * 34)
  if r > zz - 0.13 and r < zz + 0.07 and u > 0.12 and u < 0.86 then
    local i = (v < 0) and 3 or 2
    if (lidx[k] or 3) >= 5 then i = i + 1 end
    c:put(x, y, SILV[min(4, i)], ltok)
  end
  -- midrib
  if r < 0.06 and u > 0.18 and u < 0.95 then c:put(x, y, v <= 0 and SILV[4] or SILV[2], ltok) end
  -- curved veins from the midrib
  local ph = (u * 46 - r * 9) % 7
  if ph < 0.9 and r > 0.1 and r < 0.75 and u > 0.22 and u < 0.88 then c:put(x, y, v < 0 and LEAF[6] or LEAF[2], ltok) end
end)
-- torn edge: pale exposed tissue along the tear; cool reflected edge on the lower-right rim
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local u, v = LU[k], LV[k]
  if v < -0.15 and u > 0.33 and u < 0.94 then c:put(x, y, TORN, ltok)
  elseif v > 0.55 and u > 0.15 then c:put(x, y, "#2f5a62", ltok) end end)
-- petiole stub at the base sinus
for _, q in ipairs{ {11, 45, 3}, {10, 46, 2}, {9, 47, 2}, {8, 48, 1} } do c:put(q[1], q[2], STEM[q[3]], ltok) end

-- 2. sprout from the middle seed: red-violet petiole and one heart-shaped seed leaf
local stok = { r = { name = "stem" } }
local spp = { { 31, 40 }, { 29, 33 }, { 33, 27 }, { 31, 21 } }
local sm, smn = A.tube(spp, function(t) return 1.0 end)
sm:cut(seeds[2].m)
A.shade(c, sm, smn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.14, wrap = 0.3 })
local hm, HU, HV = heart(31, 22, -1.9, 14, 8)
hm:cut(sm)
local hn = {}
hm:each(function(x, y) local k = K(x, y) local s = HV[k]
  local a, b = (x - 31) / 9, (y - 15) / 8
  hn[k] = { A.norm(a * 0.8 + (s < 0 and -0.2 or 0.2), b * 0.8 - 0.1, 1) } end)
local htok = { r = { name = "seedleaf" } }
local hidx = A.shade(c, hm, hn, LEAF, { tok = htok, amb = 0.14, wrap = 0.3, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
hm:each(function(x, y) local k = K(x, y) local u, r = HU[k], abs(HV[k])
  if r > 0.42 and r < 0.62 and u > 0.18 and u < 0.85 then c:put(x, y, SILV[(HV[k] < 0) and 4 or 3], htok) end
  if r < 0.09 and u > 0.2 and u < 0.9 then c:put(x, y, HV[k] <= 0 and SILV[4] or SILV[2], htok) end
end)
-- purple underside peeking at the lower-right rim of the seed leaf
hm:edge():each(function(x, y) local k = K(x, y) if HV[k] > 0.5 and HU[k] > 0.25 and HU[k] < 0.85 then c:put(x, y, UNDER, htok) end end)
-- ambient shading under the seed leaf on the stem top
for _, p in ipairs{ {31, 23}, {32, 23} } do if sm:has(p[1], p[2]) and not hm:has(p[1], p[2]) then c:put(p[1], p[2], STEM[1], stok) end end

-- 3. seeds: rounded, slightly faceted coat, sugary bloom, hilum dimple, AO between neighbours
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  if i == 2 then X.ao(sb, s.m, sm, 1, -1) end
  local idx = A.shade(c, s.m, s.n, SEED, { tok = tok, bias = sb, amb = 0.08, wrap = 0.25 })
  -- facet: one darker ridge pixel line across, gives the angular look
  s.m:each(function(x, y) if (x - s[1]) + (y - s[2]) * 0.6 > 1.6 and (x - s[1]) + (y - s[2]) * 0.6 < 2.4 then A.step(c, idx, SEED, x, y, -1, tok) end end)
  -- hilum dimple (dark with a lit lower lip) and the bloom specular
  local hx, hy = floor(s[1] + 0.5), floor(s[2] + 0.5)
  if i ~= 2 then c:put(hx + 1, hy, SEED[1], tok) c:put(hx + 1, hy + 1, SEED[4], tok) end
  local sx, sy = A.specAt(s.m, s.n, 35)
  c:put(sx, sy, SEED[6], tok)
  if s.m:has(sx + 1, sy) then c:put(sx + 1, sy, SEED[5], tok) end
end

-- 4. quirk: the ant hauling a seed off the leaf tip
local atok = { r = { name = "ant" } }
local AI, AH = "#3a2030", "#6e4a5a"
local ant = {
  { 47, 46, AI }, { 48, 46, AI }, { 47, 47, AI }, { 48, 47, AI }, { 49, 47, AI },   -- gaster
  { 50, 46, AI },                                                                  -- waist
  { 51, 45, AI }, { 52, 45, AI },                                                  -- thorax
  { 53, 44, AI }, { 54, 44, AI }, { 53, 43, AI },                                  -- head
  { 47, 45, AH },                                                                  -- glint on the gaster
  { 50, 48, AI }, { 52, 47, AI }, { 49, 45, AI }, { 51, 43, AI },                  -- legs
  { 54, 42, AI },                                                                  -- antenna
}
for _, p in ipairs(ant) do c:put(p[1], p[2], p[3], atok) end
-- the seed it carries
for _, p in ipairs{ {55, 43, 5}, {56, 43, 4}, {55, 44, 3}, {56, 44, 2}, {56, 42, 3} } do c:put(p[1], p[2], SEED[p[3]], atok) end

A.save(c, NAME)
