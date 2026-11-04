-- pomato-seed (D10 final, Sonnet high). Three flat teardrop tomato seeds (pale straw coat, pressed centre disc, fuzzy rim hairs,
-- pointed hilum end) on a torn, saw-toothed tomato leaflet scrap that runs right-to-left (midrib, a vein into every tooth,
-- V-fold light, cool reflected edge, AO + cast shadow under each seed). On the left a seedling arches up from the leaf: violet-
-- tinged hairy stem, two long strap cotyledons and the first serrated true leaflets.
-- quirk: where the root leaves the leaf a tiny russet potato tuber has already formed (pink eye, thread root), the pomato's tell.
local NAME = "pomato-seed"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aD10_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#1b3a30", "#28523a", "#386f3c", "#528e44", "#7bad54", "#a9cd72" }
local VEIN, COOL = "#cde69a", "#3a6a78"
local SEED = { "#6a4a2a", "#98762f", "#c4a24e", "#e2c878", "#f3e19c", "#fff3c4" }
local STEM = { "#4c4a6a", "#789264", "#a8c47e", "#d6e8aa" }
local POT = { "#3e2a22", "#5e4130", "#85603f", "#a8814f", "#c9a468", "#e8cb90" }
local ltok, stok = { r = { name = "leaf" } }, { r = { name = "stem" } }

-- seeds: flat teardrops
local seeds = { { 46, 49.5, 4.2, 3.0, -0.35 }, { 37.5, 47, 4.0, 3.0, 0.3 }, { 35.5, 53, 4.0, 2.9, -0.12 } }
for _, s in ipairs(seeds) do
  s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.55)
  -- hilum point on the narrow (right) end
  local ca, sa = cos(s[5]), sin(s[5])
  for _, d in ipairs{ s[3] + 0.6, s[3] + 1.4 } do
    local px, py = floor(s[1] + ca * d + 0.5), floor(s[2] + sa * d + 0.5)
    s.m:set(px, py) s.n[K(px, py)] = { A.norm(0.2, 0.2, 1) }
  end
end

-- scrap: serrated leaflet, right (torn base) to left (tip)
local lm, ln, LT, LS, len = A.blade(56, 50, 32, 54, 6, 44, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.95 + 0.05)
  return max(0.5, 7.8 * sin(pi * u ^ 1.05) ^ 0.7)
end, { fold = 0.4 })
local PER = 4.6
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local ph = t * len / PER + (s > 0 and 0.45 or 0)
  local fr = ph - floor(ph)
  if t > 0.1 and t < 0.95 and abs(s) > 0.94 - 0.5 * fr * (0.4 + t) then cut[#cut + 1] = k end
  if t < 0.05 + 0.11 * X.hash(x, y, 5) then cut[#cut + 1] = k end        -- torn base
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
X.tone(c, lm, X.light(ln, { amb = 0.18, wrap = 0.3 }), LEAF, { cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, bias = bias, tok = ltok })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 and t > 0.06 and t < 0.94 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len + abs(s) * 3.0) / PER + (s > 0 and 0.45 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.2 and abs(s) < 0.8 and t > 0.1 and t < 0.9 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.1 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)

-- quirk: tuber at the root (behind sprout)
local tuber = c:ellipse(10.5, 54, 3, 2):add(c:ellipse(12.5, 55, 2, 2)):add(c:ellipse(8.5, 55.5, 2, 1))
local tn = X.pillow(tuber, 2.2)
X.ao(bias, lm, tuber, 1, -1)
X.tone(c, tuber, X.light(tn, { amb = 0.1, wrap = 0.3 }), POT, { cuts = A.CUTS6, tok = { r = { name = "tuber" } } })
c:put(9, 54, POT[1], { r = { name = "tuber" } }) c:put(10, 54, "#e07aa8", { r = { name = "tuber" } }) c:put(9, 53, POT[5], { r = { name = "tuber" } })
A.pline(c, { { 15, 49 }, { 14, 52 }, { 13, 54 } }, "#e8dcc0", stok)

-- sprout: arched hairy stem
local sp = { { 17, 49 }, { 15, 37 }, { 22, 24 }, { 31, 23 } }
local sm, sn, ST = A.tube(sp, function(t) return 1.35 - 0.3 * t end)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- fuzz: single pale hairs along the outer edge of the stem
for _, p in ipairs{ { 14, 40 }, { 15, 35 }, { 17, 30 }, { 21, 26 }, { 25, 24 } } do
  local best
  for dx = -2, 2 do for dy = -2, 2 do if sm:has(p[1] + dx, p[2] + dy) and not sm:has(p[1], p[2]) and not best then best = true end end end
  if best then c:put(p[1], p[2], "#dcecb4", stok) end
end
-- strap cotyledons (long, narrow)
local function strap(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, w * sin(pi * min(1, t * 0.8 + 0.2)) ^ 0.45)
  end, { fold = 0.3 })
  m:cut(sm)
  X.tone(c, m, X.light(n, { amb = 0.14, wrap = 0.3 }), LEAF, { cuts = A.CUTS6, tok = ltok })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.16 and T[k] > 0.08 and T[k] < 0.9 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
local c1 = strap(30, 23, 39, 15, 51, 12, 2.2)
local c2 = strap(30, 25, 40, 27, 53, 24, 2.1)
c2:cut(c1)
-- first true leaf (compound, serrated) on the outer side of the stem
local function leaflet(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, len2 = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, w * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.7)
  end, { fold = 0.32 })
  local cc = {}
  m:each(function(x, y) local k = K(x, y)
    local ph = T[k] * len2 / 2.4 + (S[k] > 0 and 0.45 or 0)
    local fr = ph - floor(ph)
    if T[k] > 0.1 and T[k] < 0.95 and abs(S[k]) > 0.95 - 0.45 * fr then cc[#cc + 1] = k end
  end)
  for _, k in ipairs(cc) do m.s[k] = nil end
  m:cut(sm)
  X.tone(c, m, X.light(n, { amb = 0.14, wrap = 0.3 }), LEAF, { cuts = A.CUTS6, tok = ltok })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.18 and T[k] > 0.05 and T[k] < 0.9 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
leaflet(18, 33, 12, 30, 7, 22, 3.4)
leaflet(17, 38, 11, 40, 6, 36, 2.8)
-- violet tint on the leaf stalks (petiolule)
for _, p in ipairs{ { 17, 33 }, { 16, 34 }, { 16, 38 }, { 15, 39 } } do if sm:has(p[1], p[2]) then c:put(p[1], p[2], STEM[1], stok) end end
-- the arch tip: tiny bud
c:put(32, 22, STEM[3], stok)

-- seeds last
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  local v = X.light(s.n, { amb = 0.1, wrap = 0.3 })
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, w = (dx * ca + dy * sa) / (s[3] + .45), flip * (-dx * sa + dy * ca) / (s[4] + .45)
    local id = max(1, min(6, floor((v[k] or 0.6) * 6) + 1))
    local r2 = u * u + w * w
    if r2 < 0.42 then id = id - 1 end                      -- pressed centre disc
    if r2 > 0.55 and r2 < 1.1 and w < -0.2 and u < 0.3 then id = id + 1 end   -- raised lit rim
    if u > 0.7 then id = id - 1 end
    if X.hash(x, y, 6) < 0.1 then id = id - 1 end
    if sb[k] then id = id - 1 end
    c:put(x, y, SEED[max(1, min(6, id))], tok)
  end)
  -- fuzzy rim hairs on the lit (upper-left) side
  vis:grow(1):cut(vis):each(function(x, y)
    if not seeds[i].m:has(x, y) and X.hash(x, y, 21) < 0.22 and ((x - s[1]) * (-0.6) + (y - s[2]) * (-0.8)) > -0.5 then
      local covered = false
      for j = i + 1, #seeds do if seeds[j].m:has(x, y) then covered = true end end
      if not covered then c:put(x, y, "#f0e4b4", tok) end
    end
  end)
  -- hilum dot
  local hx, hy = floor(s[1] + ca * (s[3] - 0.6) + 0.5), floor(s[2] + sa * (s[3] - 0.6) + 0.5)
  c:put(hx, hy, SEED[1], tok)
end
c:put(44, 47, SEED[6], { r = { name = "seed1" } })
c:sparkle(25, 54)

A.save(c, NAME)
