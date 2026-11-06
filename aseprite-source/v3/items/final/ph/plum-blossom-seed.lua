-- plum-blossom-seed (final pass, Opus, aC35_2). Two plum stones on a torn plum leaf: flattened almond-shaped pits,
-- warm tan, pitted/wrinkled surface and a raised keel ridge along one edge, AO + contact shadow on the leaf.
-- The leaf scrap is an elliptic plum leaf with a serrated margin, midrib and veins, its base end ripped off raggedly.
-- The right stone has split along the keel: a slim stem rises with two round cotyledons and a serrated true leaf.
-- quirk: the seedling already wears a single five-petal plum blossom at its tip, far too early.
local NAME = "plum-blossom-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC35_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local PIT = { "#4a2a24", "#6e3e2c", "#94583a", "#b8784c", "#d49c6a", "#ecc494" }
local STEM = { "#5a3a3a", "#86564a", "#b07c62", "#d4a684" }
local PET = { "#7d2c5e", "#c94f84", "#e87aa0", "#f8a6c0", "#ffd0e0", "#fff0f4" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }

-- leaf scrap: elliptic leaf on a low diagonal, tip lower-right, base torn away upper-left
local seeds = { { 22, 44, 5.6, 3.4, -0.35 }, { 35, 45, 5.2, 3.3, 0.25 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.55) end
local bias = {}
local lm = HP.mask()
do
  local m, n, T, S, len = A.blade(8, 42, 30, 52, 56, 50, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, 8.0 * sin(pi * min(1, t * 0.7 + 0.3)) ^ 0.8)
  end, { fold = 0.4 })
  -- ragged tear at the base end
  local rmv = {}
  m:each(function(x, y) local k = K(x, y)
    local edge = 0.05 + 0.06 * X.hash(floor(S[k] * 5 + 5), 3, 9) + 0.03 * sin(S[k] * 9)
    if T[k] < edge then rmv[#rmv + 1] = k end
  end)
  -- serrated margin
  m:edge():each(function(x, y) local k = K(x, y)
    if T[k] > 0.15 and ((T[k] * len + (S[k] > 0 and 0.8 or 0)) % 2.8) < 0.9 then rmv[#rmv + 1] = k end end)
  for _, k in ipairs(rmv) do m.s[k] = nil end
  for _, s in ipairs(seeds) do X.ao(bias, m, s.m, 1, -1) A.cast(bias, m, s.m, 1, 2, -1) end
  local tok = { r = { name = "leaf" } }
  local idx = A.toneN(c, m, n, LEAF, { bias = bias, tok = tok, amb = 0.16, wrap = 0.3, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 } })
  m:each(function(x, y) local k = K(x, y)
    if bias[k] then return end
    local s, t = S[k], T[k]
    if abs(s) < 0.13 and t < 0.96 then c:put(x, y, s <= 0 and "#c2e48c" or LEAF[3], tok)
    elseif t > 0.08 and t < 0.9 and abs(s) > 0.22 and abs(s) < 0.82 then
      local d = (t * len - abs(s) * 8 * 1.2) % 5
      if d < 0.9 then c:put(x, y, s < 0 and LEAF[min(6, idx[k] + 1)] or LEAF[max(1, idx[k] - 1)], tok) end
    end
  end)
  -- torn edge shows a paler fibrous rim
  m:each(function(x, y) local k = K(x, y)
    if T[k] < 0.14 and not m:has(x - 1, y) and not bias[k] then c:put(x, y, "#b8d88a", tok) end end)
  -- cool reflected light on the lower edge
  m:edge():each(function(x, y) local k = K(x, y) if S[k] > 0.7 and T[k] > 0.2 and T[k] < 0.85 and not bias[k] then c:put(x, y, "#3a6c72", tok) end end)
  lm = m
end

-- sprout from the right stone
local stok = { r = { name = "stem" } }
local spts = { { 37, 43 }, { 36, 36 }, { 38, 29 }, { 37, 18 } }
local sm, sn = A.tube(spts, function(t) return 0.95 end)
sm:cut(seeds[2].m)
A.shade(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 } })
-- cotyledons: round, fleshy
local ctok = { r = { name = "coty" } }
local CL = { "#2e7646", "#45954c", "#6ab455", "#9dd06c", "#c4e490", "#e2f4b8" }
local c1, c1n = A.oval(32.5, 33, 3.6, 2.1, 0.35, 0.8)
local c2, c2n = A.oval(42, 31, 3.6, 2.1, -0.4, 0.8)
c1:cut(sm) c2:cut(sm)
A.shade(c, c1, c1n, CL, { tok = ctok, amb = 0.12, wrap = 0.3 })
A.shade(c, c2, c2n, CL, { tok = ctok, amb = 0.12, wrap = 0.3 })
-- true leaf: small serrated ovate, angled up-left
local tm = A.leaf(c, 37, 24, 33, 19, 28, 17, 2.6, LEAF, { tok = ctok, serr = 2.4, vs = 2.6, pw = 0.6, cut = sm })
-- blossom at the tip (quirk): five petals round a gold eye
local btok = { r = { name = "blossom" } }
local bx, by = 38, 14
local pm = HP.mask()
for i = 0, 4 do
  local a = -pi / 2 + i * 2 * pi / 5
  local px, py = bx + cos(a) * 3.0, by + sin(a) * 3.0
  pm:add(A.oval(px, py, 2.1, 1.7, a, 1))
end
local pidx = {}
pm:each(function(x, y)
  local dx, dy = x - bx, y - by
  local r = sqrt(dx * dx + dy * dy)
  local lit = (-dx - dy) / (r + 0.01)
  local i = 3 + floor(lit * 1.4 + 0.5) + (r > 3.6 and 0 or 1)
  -- petal separation: ray lines between petals
  local ang = math.atan(dy, dx) + pi / 2
  local f = (ang / (2 * pi / 5)) % 1
  if (f < 0.12 or f > 0.88) and r > 1.8 then i = i - 2 end
  i = max(1, min(6, i))
  c:put(x, y, PET[i], btok)
end)
A.map(c, { ".a.", "aba", ".a." }, bx - 1, by - 1, { a = GOLD[2], b = GOLD[4] }, btok)
for _, p in ipairs{ { bx - 2, by - 2 }, { bx + 2, by - 1 }, { bx + 1, by + 2 }, { bx - 2, by + 1 } } do c:put(p[1], p[2], GOLD[3], btok) end
c:put(bx - 3, by - 3, PET[6], btok)

-- stones last: pitted surface, keel ridge on the upper edge
for i, s in ipairs(seeds) do
  local tok = { r = { name = "pit" .. i } }
  local vis = s.m:copy()
  if i == 2 then vis:cut(sm) end
  local sidx = {}
  local v = X.light(s.n, { amb = 0.1, wrap = 0.25 })
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local k = K(x, y)
    local ii = 1
    for j, t in ipairs({ 0.2, 0.36, 0.52, 0.68, 0.86 }) do if v[k] >= t then ii = j + 1 end end
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45)
    local w = (-dx * sa + dy * ca) / (s[4] + .45)
    -- keel: lit ridge just inside the upper edge
    if w < -0.55 and w > -0.85 and abs(u) < 0.8 then ii = ii + 1 end
    if w <= -0.85 then ii = ii - 1 end
    -- pits / wrinkles
    if abs(u) < 0.8 and w > -0.5 and X.hash(x, y, 30 + i) > 0.8 then ii = ii - 1 end
    if (u * 3 + w * 2) % 1.6 < 0.25 and abs(u) < 0.7 and w > -0.4 and w < 0.7 then ii = ii - 1 end
    ii = max(1, min(6, ii))
    sidx[k] = ii
    c:put(x, y, PIT[ii], tok)
  end)
  local px, py = A.specAt(vis, s.n, 30)
  if px then c:put(px, py, PIT[6], tok) if vis:has(px + 1, py) then c:put(px + 1, py, "#f6dcb0", tok) end end
end
-- the split along the keel of the sprouting stone: dark crack each side of the stem
for _, p in ipairs{ { 35, 42 }, { 39, 42 }, { 34, 42 } } do if seeds[2].m:has(p[1], p[2]) then c:put(p[1], p[2], PIT[1], { r = { name = "pit2" } }) end end

A.save(c, NAME)
