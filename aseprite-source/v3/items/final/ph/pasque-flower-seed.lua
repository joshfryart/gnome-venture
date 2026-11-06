-- pasque-flower-seed (final, Opus single pass aC32_1). Two pasque-flower achenes (small glossy brown teardrops) trailing
-- long silky feathered plumes (silver shaft, alternating hair barbs, lilac shade) that arc up off a torn scrap of a
-- finely cut, silvery-hairy pasque leaf (comb-cut narrow lobes, pale midrib, hair pixels on the rim, AO under the seeds).
-- A third achene has sprouted on the right: a hairy stem, two small oval seed-leaves and a first true leaf split into
-- narrow forked fingers, the pasque flower's feathery leaf in miniature.
-- quirk: the tip of one plume has wound itself into a little corkscrew curl.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "pasque-flower-seed"
local c = A.new(NAME)
local LEAF = { "#1f3d38", "#2e5947", "#437552", "#5f925f", "#84b07a", "#b4d0a0" }
local HAIR, COOL = "#e4ecd8", "#4a6d78"
local SEED = { "#3a1f22", "#5b2f2a", "#804432", "#a8623c", "#cd8a52", "#f0c486" }
local PL = { "#5a4f78", "#8a80a8", "#bdb4d2", "#e6e0ee", "#fff4d6" }
local STEM = { "#3e6650", "#6c9a72", "#9cc196", "#d2e6c2" }

-- leaf scrap: finely cut pasque leaf segment, comb-cut into narrow lobes on both sides
local lm, ln, LT, LS, len = A.blade(16, 52, 34, 58, 56, 46, function(t)
  if t > 0.99 then return -1 end
  return max(0.6, 7.0 * sin(pi * min(1, t * 0.9 + 0.12)) ^ 0.55)
end, { fold = 0.45 })
do local cut = {}
  lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
    local ph = (t * len - abs(s) * 3.2) / 3.6 + (s > 0 and 0.5 or 0)
    local f = ph - floor(ph)
    if t > 0.1 and abs(s) > 0.38 and f < 0.36 then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do lm.s[k] = nil end
end
A.tear(lm, 20, 52, -0.8, -0.6, 1.3, 3)

-- achenes: cx, cy, rx, ry, angle (long axis points toward the plume)
local seeds = { { 28, 49, 3.4, 2.1, 0.5 }, { 37, 46, 3.4, 2.1, 1.05 }, { 47, 44, 3.2, 2.0, -1.35 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7) end

-- plumes: cubic paths from the achene tip
local plumes = {
  { { 25, 47 }, { 13, 42 }, { 8, 28 }, { 17, 14 } },
  { { 35, 43 }, { 27, 34 }, { 25, 22 }, { 33, 13 } },
}
local pm = HP.mask()
for _, p in ipairs(plumes) do for i = 0, 60 do local x, y = A.bez(p, i / 60) pm:set(floor(x + .5), floor(y + .5)) end end
pm:grow(2)

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.06 and t < 0.92 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) end
end)
-- silky hairs on the upper rim, cool reflected light on the lower rim
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LS[k] < -0.5 and X.hash(x, y, 5) > 0.45 then c:put(x, y, HAIR, ltok)
  elseif LS[k] > 0.55 and LT[k] > 0.12 then c:put(x, y, COOL, ltok) end
end)

-- sprout from achene 3: hairy stem, two oval cotyledons, forked true leaf
local stok = { r = { name = "stem" } }
local sp = { { 47, 41 }, { 48, 35 }, { 46, 30 }, { 47, 24 } }
local sm, sn = A.tube(sp, function() return 1.0 end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
for i = 2, 14, 3 do local x, y = A.bez(sp, i / 16) c:put(floor(x + .5) + ((i % 2 == 0) and -2 or 2), floor(y + .5), HAIR, stok) end
local function coty(cx, cy, ang)
  local m, n = A.oval(cx, cy, 3.0, 1.6, ang, 0.8)
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  return m
end
coty(43, 31, 0.35) coty(51, 30, -0.35)
-- true leaf: three forked segments of narrow fingers (1-2 px)
local fingers = HP.mask()
local base = { 47, 24 }
local segs = {
  { -pi / 2, 6, { -0.45, 0, 0.45 } },
  { -pi / 2 - 1.0, 5, { -0.4, 0.35 } },
  { -pi / 2 + 1.0, 5, { -0.35, 0.4 } },
}
local fm = {}
for _, sg in ipairs(segs) do
  local ux, uy = cos(sg[1]), sin(sg[1])
  local mx, my = base[1] + ux * sg[2], base[2] + uy * sg[2]
  local a = A.pline{ { base[1], base[2] }, { floor(mx + .5), floor(my + .5) } }
  fingers:add(a)
  for _, d in ipairs(sg[3]) do
    local vx, vy = cos(sg[1] + d), sin(sg[1] + d)
    local L = 4.5
    fingers:add(A.pline{ { floor(mx + .5), floor(my + .5) }, { floor(mx + vx * L + .5), floor(my + vy * L + .5) } })
  end
end
local fat = fingers:copy()
fingers:each(function(x, y) if X.hash(x, y, 11) > 0.55 then fat:set(x + 1, y) end end)
local fn = A.X.pillow(fat, 1.2)
A.toneN(c, fat, fn, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.2, wrap = 0.35 })
fingers:each(function(x, y) if X.hash(x, y, 4) > 0.7 then c:put(x, y, LEAF[6], ltok) end end)

-- plumes: shaft + alternating barbs, lit side pale
local ptok = { r = { name = "plume" } }
local function plume(p, curl)
  local L = 0
  do local px, py = A.bez(p, 0) for i = 1, 50 do local x, y = A.bez(p, i / 50) L = L + sqrt((x - px)^2 + (y - py)^2) px, py = x, y end end
  local m, n, T, S = A.tube(p, function(t)
    local saw = (t * L / 2.6) % 1
    return (2.3 * (1 - t) ^ 0.8 + 0.6) * (0.78 + 0.42 * saw)
  end)
  local v = X.light(n, { amb = 0.15, wrap = 0.35 })
  m:each(function(x, y) local k = K(x, y)
    local i = 1 + floor(v[k] * 4.2)
    -- barbs: diagonal hair lines swept back toward the seed
    local ph = (T[k] * L + abs(S[k]) * 2.2) / 2.6
    if (ph % 1) < 0.34 and abs(S[k]) > 0.25 then i = i - 1 end
    if abs(S[k]) < 0.2 then i = i + 1 end
    c:put(x, y, PL[max(1, min(5, i))], ptok)
  end)
  for i = 0, 6 do local x, y = A.bez(p, i / 60) c:put(floor(x + .5), floor(y + .5), SEED[5], ptok) end
  if curl then
    -- corkscrew curl continuing past the tip
    local ex, ey = A.bez(p, 1)
    for i = 0, 26 do local a = -0.6 + i * 0.36 local r = 3.2 - i * 0.09
      c:put(floor(ex + 2 + cos(a) * r + .5), floor(ey + 1 + sin(a) * r + .5), PL[(i % 3 == 0) and 3 or 4], ptok) end
  end
end
plume(plumes[1], false)
plume(plumes[2], true)

-- achenes last: glossy brown teardrop, hairy rim, spec glint
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  local idx = A.tone(c, s.m, s.n, SEED, { tok = tok, bias = sb, amb = 0.12, wrap = 0.35 })
  local bx, by = A.specAt(s.m, s.n, 30)
  c:put(bx, by, PL[5], tok)
end
A.save(c, NAME)
