-- lupine-seed (aC21_4, Opus single pass). Three round, flattened lupine seeds (cream-tan coat marbled with brown
-- speckles, dark hilum slit with a pale lip, one glint) resting on a torn scrap of a palmate lupine leaf: four narrow
-- blue-green leaflets fanning from the hub, midribs, silvery hairs on the lit edges, AO + contact shadow under seeds.
-- The right seed has sprouted: slim stem, two thick fleshy oval seed leaves and a first true leaf that is already a
-- tiny palmate star of seven leaflets on a long petiole.
-- quirk: a dewdrop sits in the hub of the palmate leaf, the way lupines hold water.
local NAME = "lupine-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local LEAF = { "#163a3a", "#1f5244", "#2d6c4e", "#448a58", "#6aaa6a", "#a0cc8a" }
local HAIR, FIBRE, COOL = "#d2e6c8", "#c6d8a0", "#3c6474"
local SEED = { "#4a3428", "#6e5038", "#957048", "#b8925e", "#d6b47c", "#eed6a2" }
local MOT = { "#5a3a2e", "#7e5638" }
local COT = { "#2a5a3a", "#3e7a44", "#5a9a4e", "#80b85c", "#a8d27a", "#d0e8a0" }
local STEM = { "#4e7a4e", "#7aa868", "#a8cc8a", "#d8ecb8" }
local DROP = { "#3a86b0", "#5fc4c8", "#b6f0e0" }
local ltok, stok, ctok = { r = { name = "leaf" } }, { r = { name = "stem" } }, { r = { name = "cot" } }

local seeds = { { 21, 47, 3.9, 3.3, 0.3 }, { 30, 43, 3.8, 3.3, -0.2 }, { 40, 45, 3.7, 3.2, 0.5 } }
local allS = HP.mask()
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.65) allS:add(s.m) end

-- leaf scrap: four leaflets fanning from the hub (lower left)
local HX, HY = 10, 53
local fan = { { 0.1, 31, 2.6 }, { -0.3, 40, 2.9 }, { -0.72, 30, 2.6 } }
local bias = {}
local lms = {}
for i, f in ipairs(fan) do
  local a, L, w = f[1], f[2], f[3]
  local ux, uy = cos(a), sin(a)
  local bx, by = HX + ux * L, HY + uy * L
  local cx, cy = HX + ux * L * 0.5 - uy * 1.5, HY + uy * L * 0.5 + ux * 1.5
  local m, n, T, S, len = A.blade(HX, HY, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, w * sin(pi * min(1, t ^ 0.7 * 0.95 + 0.05)) ^ 0.75)
  end, { fold = 0.3 })
  for j = 1, i - 1 do m:cut(lms[j].m) end
  lms[i] = { m = m, n = n, T = T, S = S }
end
-- the up-pointing leaflet is torn off short
local torn = A.tear(lms[3].m, 28, 45, 17, 35, 1.2, 3)
for i, l in ipairs(lms) do
  local b = {}
  X.ao(b, l.m, allS, 1, -1) A.cast(b, l.m, allS, 1, 2, -1)
  for j, o in ipairs(lms) do if j < i then X.ao(b, l.m, o.m, 1, -1) end end
  l.b = b
  A.toneN(c, l.m, l.n, LEAF, { bias = b, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
  l.m:each(function(x, y) local k = K(x, y)
    if b[k] then return end
    if abs(l.S[k]) < 0.15 and l.T[k] > 0.05 and l.T[k] < 0.93 then c:put(x, y, l.S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end
  end)
  l.m:edge():each(function(x, y) local k = K(x, y)
    if b[k] or torn:has(x, y) then return end
    if l.S[k] < -0.5 and X.hash(x, y, 2) < 0.45 then c:put(x, y, HAIR, ltok)
    elseif l.S[k] > 0.6 then c:put(x, y, COOL, ltok) end
  end)
end
-- 1px deep line where leaflets overlap near the hub
for i = 2, #lms do lms[i].m:each(function(x, y)
  for j = 1, i - 1 do if lms[j].m:has(x - 1, y) or lms[j].m:has(x + 1, y) or lms[j].m:has(x, y - 1) or lms[j].m:has(x, y + 1) then c:put(x, y, LEAF[1], ltok) return end end end) end
torn:each(function(x, y) if not lms[3].b[K(x, y)] then c:put(x, y, FIBRE, ltok) end end)
-- hub: dark knot where leaflets join + petiole stub
for _, q in ipairs{ { 10, 53, 1 }, { 11, 53, 2 }, { 10, 52, 2 }, { 9, 54, 3 }, { 8, 55, 3 }, { 7, 56, 4 } } do c:put(q[1], q[2], q[3] <= 2 and LEAF[q[3]] or STEM[q[3] - 2], ltok) end

-- sprout from the right seed
local sp = { { 41, 43 }, { 43, 36 }, { 39, 29 }, { 41, 23 } }
local sm, sn = A.tube(sp, function(t) return 1.05 end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- cotyledons: thick fleshy ovals
local cots = HP.mask()
for _, q in ipairs{ { 35.5, 32, 4.2, 2.3, 0.35 }, { 46.5, 31, 4.2, 2.3, -0.4 } } do
  local m, n = A.oval(q[1], q[2], q[3], q[4], q[5], 0.6)
  m:cut(sm)
  local b = {} X.ao(b, m, sm, 1, -1)
  A.toneN(c, m, n, COT, { tok = ctok, bias = b, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, amb = 0.12, wrap = 0.3 })
  cots:add(m)
end
-- palmate first leaf: seven leaflets around the hub
local PX, PY = 41, 19
for i = 0, 4 do
  local a = pi + 0.25 + i * (pi - 0.5) / 4
  local L = ({ 8.5, 10, 11, 10, 8.5 })[i + 1]
  local ux, uy = cos(a), sin(a)
  local m = A.leaf(c, PX + ux * 1.5, PY + uy * 1.5, PX + ux * L * 0.55, PY + uy * L * 0.55, PX + ux * L, PY + uy * L, 1.4,
    { ramp = LEAF, tok = ltok, pw = 0.6, minw = 0.6 })
end
-- lower pair, drooping either side of the petiole
for _, a in ipairs{ pi - 0.55, 0.55 } do
  local ux, uy = cos(a), sin(a)
  A.leaf(c, PX + ux * 1.5, PY + uy * 1.5, PX + ux * 4, PY + uy * 4, PX + ux * 8, PY + uy * 8, 1.3, { ramp = LEAF, tok = ltok, pw = 0.6, minw = 0.6 })
end
-- quirk: dewdrop on the hub (bright rim, pale core, glint)
local dtok = { r = { name = "dew" } }
for _, q in ipairs{ { 40, 18, 2 }, { 41, 18, 3 }, { 42, 18, 2 }, { 40, 19, 2 }, { 41, 19, 3 }, { 42, 19, 1 }, { 41, 20, 1 }, { 40, 20, 1 } } do
  c:put(q[1], q[2], DROP[q[3]], dtok) end
c:put(40, 18, A.CREAM, dtok)

-- seeds last: round marbled coats with hilum slit
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local vis, sb = s.m:copy(), {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local idx = A.toneN(c, vis, s.n, SEED, { tok = tok, bias = sb, cuts = { 0.16, 0.32, 0.48, 0.64, 0.84 }, amb = 0.1, wrap = 0.25 })
  local P = A.cells(s[1] - 5, s[2] - 5, s[1] + 5, s[2] + 5, 2.6, 1.6, 20 + i)
  vis:each(function(x, y) local k = K(x, y)
    local d1, d2, ci = A.near2(P, x, y)
    if X.hash(ci, i, 5) < 0.42 and d1 < 0.95 then
      c:put(x, y, (idx[k] or 3) >= 4 and MOT[2] or MOT[1], tok)
    end
  end)
  -- hilum: short dark slit along the lower-right rim, pale lip above it
  local ca, sa = cos(s[5]), sin(s[5])
  for u = -0.4, 0.4, 0.2 do
    local x, y = floor(s[1] + u * s[3] * ca - (s[4] - 1) * sa + .5), floor(s[2] + u * s[3] * sa + (s[4] - 1) * ca + .5)
    if vis:has(x, y) then c:put(x, y, SEED[1], tok) end
    if vis:has(x, y - 1) and abs(u) < 0.3 then c:put(x, y - 1, SEED[4], tok) end
  end
  local gx, gy = A.specAt(vis, s.n, 40)
  if gx then c:put(gx, gy, A.CREAM, tok) if i == 2 then c:put(gx + 1, gy, SEED[6], tok) end end
end

A.save2(c, NAME)
