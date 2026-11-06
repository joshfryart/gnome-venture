-- sago-seed (final, Sonnet high single pass). Three plump orange-red sago-palm (cycad) seeds on a torn scrap of
-- pinnate frond: a pale rachis with two ranks of stiff glossy dark leaflets (each with a lit midrib, overlap lines),
-- AO + contact shadow under every seed. The right seed has germinated: a pale S-curved rachis with four pairs of
-- fresh feather leaflets, topped by a fist-curled crozier (the new frond in miniature).
-- quirk: the crozier is wrapped in fuzzy brown felt.
local NAME = "sago-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local DARK = { "#10302c", "#1a4a38", "#25673f", "#3a8648", "#5ca555", "#8cc46c" }
local NEW  = { "#2c6a3a", "#3f8a46", "#5fac50", "#8cc866", "#b4e08a", "#d8f4b0" }
local RACH = { "#4a6a3a", "#7d9a4c", "#a9c25e", "#d0e286" }
local RACH2 = { "#6a8a3a", "#98b650", "#c3d86c", "#e2efa0" }
local ORG  = { "#5a1e2e", "#8a2a30", "#b83a2c", "#dc5a28", "#f2832e", "#ffb45e" }
local FELT = { "#4a2e1e", "#6e4628", "#946238", "#bf8a4e", "#dcb272" }
local ltok = { r = { name = "leaf" } }

-- seeds (cx, cy, rx, ry, angle); the right one germinates
local seeds = { { 17, 48, 5.4, 4.4, 0.15 }, { 30, 45, 5.4, 4.4, -0.2 }, { 44, 40, 5.7, 4.7, 0.05 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.85) end

-- frond scrap: rachis bezier + two ranks of leaflets
local rb = { { 8, 55 }, { 24, 54 }, { 38, 50 }, { 55, 43 } }
local all = HP.mask()
local lidx = {}
local function leaflet(ax, ay, dx, dy, L, w, bend, ramp, mid, sep)
  local bx, by = ax + dx * L, ay + dy * L
  local cx, cy = ax + dx * L * 0.5 - dy * bend, ay + dy * L * 0.5 + dx * bend
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    if t < 0.78 then return w end
    return max(0.3, w * (1 - (t - 0.78) / 0.22) + 0.25)
  end, { fold = 0.5 })
  local idx = G.toneN(c, m, n, ramp, { tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.12, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.2 and T[k] > 0.06 and T[k] < 0.94 then c:put(x, y, S[k] <= 0 and ramp[6] or ramp[3], ltok) end
    if sep and all:has(x, y) == false then
      -- first row of this leaflet that borders an earlier one gets a dark separating line
      if all:has(x - 1, y) or all:has(x, y - 1) or all:has(x + 1, y) or all:has(x, y + 1) then c:put(x, y, ramp[1], ltok) end
    end
    lidx[k] = idx[k]
  end)
  all:add(m)
  return m
end
local function rot(ux, uy, a) return G.rot(ux, uy, a) end
local pairsList = {}
for i = 1, 10 do pairsList[i] = 0.07 + (i - 1) * 0.09 end
-- lower rank first (drawn behind), then upper rank
for _, side in ipairs{ 1, -1 } do
  for i, t in ipairs(pairsList) do
    local x, y = G.bez(rb, t)
    local x2, y2 = G.bez(rb, min(1, t + 0.01))
    local tx, ty = x2 - x, y2 - y
    local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
    local dx, dy = rot(tx, ty, side * 0.96 * (side == 1 and 0.92 or 1))
    local L = 4.5 + 6.5 * sin(pi * t) ^ 0.7
    leaflet(x, y, dx, dy, L, 1.5, side * 0.9, DARK, true, true)
  end
end
-- rachis over the leaflet roots (pale ridge, lit upper-left)
local rm, rn = G.tube(rb, function(t) if t < 0.02 or t > 0.985 then return 0 end return 1.25 end)
local rtok = { r = { name = "rachis" } }
G.toneN(c, rm, rn, RACH, { tok = rtok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
rm:each(function(x, y) if (x * 3 + y) % 11 == 0 then c:put(x, y, RACH[1], rtok) end end)

-- AO + contact shadow of the seeds on the leaflets
for _, s in ipairs(seeds) do
  local b = {}
  X.ao(b, all, s.m, 1, -1)
  G.cast(b, all, s.m, 1, 2, -1)
  G.cast(b, all, s.m, 2, 3, -1)
  for k, d in pairs(b) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    if all:has(x, y) and not s.m:has(x, y) then
      local idx = lidx[k] or 3
      c:put(x, y, DARK[max(1, idx + d - (d <= -2 and 0 or 0))], ltok)
    end
  end
end

-- sprout: stem + fresh leaflet pairs, drawn before the seed so the seed coat covers the stem foot
local sb = { { 44, 38 }, { 41, 31 }, { 48, 25 }, { 45, 16 } }
local sm, sn, ST, SS = G.tube(sb, function(t) return 1.5 - 0.5 * t end)
sm:cut(seeds[3].m)
local sidx = G.toneN(c, sm, sn, RACH2, { tok = rtok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
local saved = all
all = HP.mask()
for _, t in ipairs{ 0.34, 0.5, 0.66, 0.8 } do
  local x, y = G.bez(sb, t)
  local x2, y2 = G.bez(sb, min(1, t + 0.01))
  local tx, ty = x2 - x, y2 - y
  local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
  local L = 9.5 - (t - 0.34) * 11
  for _, side in ipairs{ 1, -1 } do
    local dx, dy = rot(tx, ty, side * 0.95)
    leaflet(x, y, dx, dy, L, 1.2, side * 0.8, NEW, true, true)
  end
end
-- stem again over the leaflet roots
G.toneN(c, sm, sn, RACH2, { tok = rtok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
sm:each(function(x, y) if (x * 3 + y * 2) % 9 == 0 then c:put(x, y, RACH2[1], rtok) end end)

-- quirk: felted crozier curled at the top of the new frond
local cm, cn = G.tube({ { 45, 16 }, { 44, 10 }, { 52, 8 }, { 52, 14 } }, function(t) return 1.5 - 0.4 * t end)
local ctok = { r = { name = "crozier" } }
local ci = G.toneN(c, cm, cn, FELT, { tok = ctok, cuts = { 0.3, 0.5, 0.7, 0.88 }, amb = 0.12, wrap = 0.3 })
cm:each(function(x, y) if X.hash(x, y, 7) > 0.6 then c:put(x, y, FELT[min(5, (ci[K(x, y)] or 3) + 1)], ctok) end end)
local fz = cm:grow(1):cut(cm)
fz:each(function(x, y)
  if X.hash(x, y, 11) > 0.62 and not (y > 14 and x < 48) then c:put(x, y, FELT[(x + y) % 2 == 0 and 4 or 5], ctok) end
end)
c:put(52, 15, FELT[2], ctok)

-- seeds: glossy sarcotesta, dimple scar, micropyle nub, AO between neighbours
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sbias = {}
  for j = i + 1, #seeds do X.ao(sbias, s.m, seeds[j].m, 1, -1) end
  -- cool bounce on the shade rim
  local idx = G.toneN(c, s.m, s.n, ORG, { tok = tok, bias = sbias, cuts = { 0.22, 0.38, 0.54, 0.7, 0.86 }, amb = 0.08, wrap = 0.25 })
  s.m:each(function(x, y) local k = K(x, y)
    local d = idx[k] or 3
    if X.hash(x, y, 21) > 0.93 and d >= 3 then c:put(x, y, ORG[d - 1], tok) end             -- faint pitting
  end)
  -- apex scar: dark ring + nub at the right end of the seed
  local ca, sa = cos(s[5]), sin(s[5])
  local ax, ay = floor(s[1] + ca * (s[3] - 1.2) + 0.5), floor(s[2] + sa * (s[3] - 1.2) + 0.5)
  c:put(ax, ay, ORG[1], tok) c:put(ax - 1, ay, ORG[2], tok)
  -- reflected green from the frond on the lower rim
  s.m:edge():each(function(x, y) if (x - s[1]) + (y - s[2]) > 3.2 and y > s[2] and not s.m:has(x, y + 1) then c:put(x, y, "#a8452e", tok) end end)
  local sx, sy = G.specAt(s.m, s.n, 28)
  if sx then c:put(sx, sy, "#fff1d0", tok) c:put(sx + 1, sy, "#fff1d0", tok) c:put(sx, sy + 1, ORG[6], tok) c:put(sx - 1, sy, ORG[5], tok) end
end
-- collar where the sprout leaves the seed
for dx = -1, 2 do c:put(44 + dx, 36, ORG[abs(dx - 0.5) > 1 and 2 or 1], { r = { name = "seed3" } }) end
c:put(43, 36, RACH2[2], rtok) c:put(44, 36, RACH2[3], rtok)

G.save2(c, NAME)
