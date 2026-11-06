-- black-eyed-susan-seed (final, Opus single pass). Three slim, four-angled Rudbeckia achenes (near-black brown, one pale
-- ridge along each, a tan crown scar at the broad end) on a torn scrap of rough, lanceolate Rudbeckia leaf (midrib,
-- pinnate veins, a few marginal teeth, jagged torn right end, cool reflected edge, AO + contact shadow under the seeds).
-- The left seed has sprouted: pale stem, two round cotyledons and a first hairy, lance-shaped true leaf.
-- quirk: one golden ray petal (notched tip, orange base) has dropped onto the leaf scrap.
local NAME = "black-eyed-susan-seed"
local R = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_3.lua")
local HP, X, K = R.HP, R.X, R.K
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = R.new(NAME)
local LEAF = { "#1d3a2e", "#2a5536", "#3a713e", "#548e46", "#77ab55", "#a4c96e" }   -- dull, slightly grey Rudbeckia green
local VEIN, COOL, HAIR = "#c4dc8e", "#3d6a6a", "#d4e6a8"
local SEED = { "#120a0e", "#1f1216", "#301d1d", "#472b25", "#6a4434", "#a07452" }
local CROWN = "#c9a46a"
local STEM = { "#4b7a48", "#7da862", "#b2d08a", "#def0b8" }
local PET = { "#a8501c", "#d97a1e", "#f0a524", "#fbc93a", "#ffe27a", "#fff2b4" }

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 21, 47, 4.4, 1.8, -0.5 }, { 32, 46, 4.5, 1.8, 0.35 }, { 42, 43, 4.3, 1.75, -0.15 } }
for _, s in ipairs(seeds) do s.m = R.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end

-- leaf scrap: lanceolate blade, torn across near the top end
local lm, ln, LT, LS, len = R.blade(6, 53, 28, 44, 58, 36, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 8.4 * sin(pi * min(1, t * 0.85 + 0.08)) ^ 0.7)
end, { fold = 0.4 })
-- torn end: jagged line across the blade around t = 0.8
local cut = {}
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  local j = ({ 0, 2.2, 0.6, 3.0, 1.0, 2.6, 0.2, 1.8 })[floor((s + 1) * 4.2) % 8 + 1]
  if t * len > 0.8 * len - j then cut[#cut + 1] = k end
  -- a few serrate teeth on the margin (notch every ~6 px)
  local ph = (t * len / 6.5 + (s > 0 and 0.5 or 0)) % 1
  if abs(s) > 0.88 and ph > 0.62 and t > 0.12 and t < 0.75 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) R.cast(bias, lm, s.m, 1, 1, -1) end
local ltok = { r = { name = "leaf" } }
R.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 5.0) / 6.5 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.15 and abs(s) < 0.75 and t > 0.05 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
local edge = lm:edge()
edge:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LS[k] > 0.6 then c:put(x, y, COOL, ltok)
  elseif LS[k] < -0.6 and (x + y) % 3 == 0 then c:put(x, y, HAIR, ltok) end      -- rough hairs on the lit margin
  if LT[k] > 0.7 and abs(LS[k]) < 0.6 then c:put(x, y, "#c8d8a0", ltok) end          -- pale torn tissue
end)
for _, q in ipairs{ { 5, 54, 3 }, { 4, 55, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- quirk: a dropped ray petal lying on the scrap (drawn before seeds so it sits under nothing)
local pm, pn, PT, PS = R.blade(44, 39, 49, 33, 55, 30, function(t)
  if t > 0.97 then return -1 end return max(0.4, 2.4 * sin(pi * min(1, t * 0.8 + 0.2)) ^ 0.5) end, { fold = 0.15 })
pm:each(function(x, y) local k = K(x, y) if PT[k] > 0.84 and abs(PS[k]) < 0.3 then pm.s[k] = nil end end)  -- notched tip
local ptok = { r = { name = "petal" } }
local pidx = R.shade(c, pm, pn, PET, { tok = ptok, amb = 0.25, wrap = 0.35 })
pm:each(function(x, y) local k = K(x, y)
  if PT[k] < 0.18 then c:put(x, y, PET[2], ptok) end
  if abs(PS[k]) < 0.15 and PT[k] > 0.2 and PT[k] < 0.8 then c:put(x, y, PET[3], ptok) end end)   -- petal crease
pm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not pm:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)

-- sprout from the left seed: stem, two round cotyledons, a lance-shaped hairy true leaf
local stok = { r = { name = "stem" } }
local sp = { { 20, 45 }, { 18, 38 }, { 21, 31 }, { 21, 25 } }
local sm, sn = R.tube(sp, function(t) return 1.0 end)
R.shade(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function lf(ax, ay, cx, cy, bx, by, w, pw)
  local m, n, T, S = R.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end return max(0.4, w * sin(pi * min(1, t * 0.92 + 0.06)) ^ pw) end, { fold = 0.3 })
  m:cut(sm)
  R.shade(c, m, n, LEAF, { tok = ltok, amb = 0.16, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.12 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  m:edge():each(function(x, y) local k = K(x, y) if S[k] < -0.5 and (x * 2 + y) % 3 == 0 then c:put(x, y, HAIR, ltok) end end)
  return m
end
local cl = lf(20, 26, 15, 24, 10, 26, 2.3, 0.45)     -- round cotyledons
local cr = lf(22, 26, 27, 24, 32, 26, 2.3, 0.45)
local tl = lf(21, 25, 21, 17, 25, 9, 3.1, 0.8)       -- first true leaf, lanceolate
tl:cut(cl):cut(cr)

-- seeds last: four-angled achenes, pale ridge, groove, crown scar
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  if i == 1 then X.ao(sb, s.m, sm, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), flip * (-dx * sa + dy * ca) / (s[4] + .45)
    -- tapered: narrow end (u<0) darker
    local ii
    if v < -0.45 then ii = 4 elseif v < 0 then ii = 5 elseif v < 0.45 then ii = 3 else ii = 2 end
    if abs(v) < 0.2 and u > -0.5 and u < 0.5 then ii = (v < 0) and 6 or 2 end   -- the angle (ridge) catches light
    if u < -0.7 then ii = ii - 1 end
    if u > 0.82 then ii = 5 end
    if sb[k] then ii = ii - 1 end
    c:put(x, y, SEED[max(1, min(6, ii))], tok)
  end)
  -- crown scar at the broad end
  local xi, yi = floor(s[1] + ca * (s[3] - 0.2) + .5), floor(s[2] + sa * (s[3] - 0.2) + .5)
  if vis:has(xi, yi) then c:put(xi, yi, CROWN, tok) end
end
R.finish(c)
