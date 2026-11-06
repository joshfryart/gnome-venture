-- satsuki-azalea-seed (final, Opus-level single pass). Satsuki azalea seeds are dust-fine, so they are drawn big for
-- the icon: slim brown spindles with a pale papery tail at each end, a dark groove and a lit rim. They lie on a torn
-- scrap of a satsuki leaf (small, leathery, obovate, dark glossy green, chevron veins, pale hairs, fibrous torn edge).
-- The right seed has split open: a rosy hypocotyl, two oval cotyledons and a first pair of tiny hairy true leaves.
-- quirk: one fallen satsuki petal (pink, streaked white like the variegated flowers) rests on the leaf scrap.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD14_2.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new("satsuki-azalea-seed")
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local LEAF = { "#0f2e2c", "#184436", "#235e3c", "#348049", "#52a257", "#86c670" }
local VEIN, COOL, FIBRE = "#b2dc86", "#2c6470", { "#9fb85e", "#cfdd8c", "#eef2c0" }
local SEED = { "#2a181a", "#47281f", "#6c4126", "#966030", "#c08a4a", "#e4b574" }
local WING = { "#a98e62", "#d3bd8c", "#efe2b8" }
local STEM = { "#6e2a3a", "#a8445a", "#cf6678", "#ea9490", "#f8c4b0" }
local COT = { "#1a4c3a", "#2c7040", "#45903f", "#6cb04e", "#9ad067", "#c6e890" }
local PET = { "#7d2c5e", "#b8447a", "#e0648e", "#f58aa8", "#ffb4c8", "#ffe4ec" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- ---- leaf scrap ----
local bias = {}
local seeds = { { 16.5, 49, 4.8, 1.9, -0.32 }, { 25, 45.5, 4.6, 1.9, 0.42 } }
local halves = { { 33.4, 43.4, 3.3, 1.7, 0.55 }, { 39.6, 44.6, 3.3, 1.7, -0.4 } }
local lm, ln, LT, LS, len = A.blade(6, 52, 27, 44, 57, 40, function(t)
  if t > 0.985 then return -1 end
  local u = 0.12 + 0.88 * t ^ 1.25
  return max(0.5, 9.2 * max(0, sin(pi * min(1, u))) ^ 0.62)
end, { fold = 0.4 })
-- torn base: jagged diagonal tear
local tear = {}
lm:each(function(x, y) local k = K(x, y)
  local lim = 9 + ((y * 7) % 3) * 0.9 + (y - 48) * 0.28 + ((y % 5 == 0) and 1.5 or 0)
  if x < lim then tear[#tear + 1] = k end
end)
for _, k in ipairs(tear) do lm.s[k] = nil end
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end
for _, h in ipairs(halves) do h.m, h.n = A.oval(h[1], h[2], h[3], h[4], h[5], 0.8) end
local PX, PY = 50, 41
local pm, pn = A.oval(PX, PY, 3.9, 2.5, -0.5, 0.7)
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
for _, h in ipairs(halves) do X.ao(bias, lm, h.m, 1, -1) A.cast(bias, lm, h.m, 1, 2, -1) end
X.ao(bias, lm, pm, 1, -1) A.cast(bias, lm, pm, 1, 2, -1)
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 and t > 0.03 and t < 0.94 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- chevron lateral veins sweeping to the tip
  local ph = (t * len - abs(s) * 4.2) / 5.4 + (s > 0 and 0.5 or 0)
  local f = ph - floor(ph)
  if f < 0.16 and abs(s) > 0.18 and abs(s) < 0.8 and t > 0.06 and t < 0.9 then
    c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
  -- fine pale hairs on the lit blade
  if s < 0.2 and X.hash(x, y, 7) > 0.955 then c:put(x, y, LEAF[6], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.1 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
-- torn edge: pale fibrous lip where the leaf was ripped
lm:each(function(x, y)
  local lim = 9 + ((y * 7) % 3) * 0.9 + (y - 48) * 0.28 + ((y % 5 == 0) and 1.5 or 0)
  if x < lim + 1.6 and not bias[K(x, y)] then
    c:put(x, y, x < lim + 0.4 and FIBRE[3] or FIBRE[2], ltok)
  elseif x < lim + 2.6 and X.hash(x, y, 3) > 0.45 then c:put(x, y, FIBRE[1], ltok) end
end)

-- ---- radicle lying along the leaf (from the split seed) ----
local rm, rn, RT = A.tube({ { 40, 45 }, { 42.5, 47.5 }, { 45, 48.5 }, { 47.5, 48 } }, function(t) return 0.95 * (1 - t) ^ 0.7 + 0.3 end)
-- keep it off the petal
rm:cut(pm)
X.tone(c, rm, X.light(rn, { amb = 0.12, wrap = 0.3 }), { "#9c7a62", "#cdb094", "#ecd8bc", "#fbf0dc" }, { cuts = { 0.3, 0.55, 0.8 } })
-- root hairs
c:px(43, 49, "#fbf0dc") c:px(45, 50, "#ecd8bc") c:px(41, 47, "#fbf0dc")
-- (the radicle was painted over the leaf; re-darken the leaf just under it)
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) and not pm:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)

-- ---- petal (quirk), painted before the stem so nothing overlaps it ----
local ptok = { r = { name = "petal" } }
X.tone(c, pm, X.light(pn, { amb = 0.1, wrap = 0.4 }), PET, { cuts = CUTS, tok = ptok })
-- ruffled edge on the far end, streak and freckles (variegation)
pm:each(function(x, y)
  local dx, dy = x - PX, y - PY
  local u = (dx * cos(-0.5) + dy * sin(-0.5))
  local v = (-dx * sin(-0.5) + dy * cos(-0.5))
  if abs(v + 0.2) < 0.55 and u > -2.6 and u < 1.6 then c:put(x, y, PET[6], ptok) end
  if u > 3.2 then c:put(x, y, PET[2], ptok) end
end)
c:put(PX + 1, PY + 1, "#a02c5c", ptok) c:put(PX + 2, PY, "#a02c5c", ptok)
c:put(PX - 3, PY + 1, PET[6], ptok) c:put(PX - 2, PY, PET[6], ptok) c:put(PX - 2, PY - 1, PET[5], ptok)

-- ---- sprout ----
local stok = { r = { name = "stem" } }
local sm, sn, ST = A.tube({ { 36.5, 43 }, { 35.8, 37 }, { 37.8, 30 }, { 37.2, 23 } }, function(t) return 1.15 - 0.2 * t end)
for _, h in ipairs(halves) do sm:cut(h.m) end
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = stok })
local ctok = { r = { name = "cot" } }
local function cot(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, w * sin(pi * min(1, t * 0.88 + 0.14)) ^ 0.55)
  end, { fold = 0.35 })
  m:cut(sm)
  A.toneN(c, m, n, COT, { tok = ctok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.15 and T[k] > 0.1 and T[k] < 0.88 then c:put(x, y, S[k] <= 0 and COT[6] or COT[2], ctok) end end)
  return m
end
local cl = cot(37, 24.5, 31, 21, 25, 22.5, 3.0)
local cr = cot(38, 24.5, 44, 20.5, 50, 22, 3.0)
-- first true leaves: two tiny obovate hairy leaves above the cotyledons
local function tl(ax, ay, cx, cy, bx, by)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, 2.3 * sin(pi * min(1, t * 0.82 + 0.16)) ^ 0.6)
  end, { fold = 0.4 })
  A.toneN(c, m, n, COT, { tok = ctok, cuts = CUTS, amb = 0.12, wrap = 0.25 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.16 and T[k] > 0.12 and T[k] < 0.85 then c:put(x, y, COT[6], ctok) end end)
  -- hair dots on the rim
  m:edge():each(function(x, y) if X.hash(x, y, 11) > 0.45 then c:put(x, y, "#e4f2c4", ctok) end end)
  return m
end
local t1 = tl(37, 23.5, 33.5, 19, 32, 12.5)
local t2 = tl(37.5, 23.5, 40.5, 18, 43, 12)
-- crown bud between the true leaves
c:put(37, 19, COT[5], ctok) c:put(37, 18, COT[6], ctok) c:put(37, 20, STEM[3], stok)
-- contact shadow: stem on cotyledons
for _, p in ipairs{ { 36, 24 }, { 38, 25 } } do if cl:has(p[1], p[2]) or cr:has(p[1], p[2]) then c:put(p[1], p[2], COT[1], ctok) end end

-- ---- seeds: slim spindles, papery tails, groove, lit rim ----
local function seed(s, i, vis)
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  local sb = {}
  s.m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + 0.45), flip * (-dx * sa + dy * ca) / (s[4] + 0.45)
    local j
    if v < -0.5 then j = 5 elseif v < -0.1 then j = 4 elseif v < 0.25 then j = 3 elseif v < 0.6 then j = 2 else j = 2 end
    if abs(v) < 0.2 and abs(u) < 0.7 then j = max(1, j - 1) end            -- dark central groove
    if abs(u) > 0.78 then j = j - 1 end
    if v < -0.5 and u > -0.55 and u < -0.05 then j = 6 end                 -- lit ridge
    if sb[k] then j = j - 1 end
    c:put(x, y, SEED[max(1, min(6, j))], tok)
  end)
  -- papery tail at each end (along the axis)
  for _, e in ipairs{ -1, 1 } do
    for d = 1, 3 do
      local px = s[1] + (e * (s[3] + d - 0.2)) * ca
      local py = s[2] + (e * (s[3] + d - 0.2)) * sa
      local xi, yi = floor(px + 0.5), floor(py + 0.5)
      if not s.m:has(xi, yi) then c:put(xi, yi, d == 3 and WING[1] or (e < 0 and WING[3] or WING[2]), tok) end
    end
    -- wing flare: one pixel off-axis at the shoulder
    local fx = floor(s[1] + (e * (s[3] + 0.9)) * ca - flip * 1.0 * sa + 0.5)
    local fy = floor(s[2] + (e * (s[3] + 0.9)) * sa + flip * 1.0 * ca + 0.5)
    if not s.m:has(fx, fy) then c:put(fx, fy, WING[2], tok) end
  end
  -- glint on the lit ridge
  local gx, gy = floor(s[1] - 1.2 * ca + (-flip * 0.9) * (-sa) + 0.5), floor(s[2] - 1.2 * sa + (-flip * 0.9) * ca + 0.5)
  if s.m:has(gx, gy) then c:put(gx, gy, "#fbe8b4", tok) end
end
seed(seeds[1], 1) seed(seeds[2], 2)
-- split seed: two empty coat halves, gap showing pale embryo, the hypocotyl root-out
for hi, h in ipairs(halves) do
  local tok = { r = { name = "half" .. hi } }
  local ca, sa = cos(h[5]), sin(h[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  h.m:each(function(x, y)
    local dx, dy = x - h[1], y - h[2]
    local u, v = (dx * ca + dy * sa) / (h[3] + 0.45), flip * (-dx * sa + dy * ca) / (h[4] + 0.45)
    local j
    if v < -0.4 then j = 5 elseif v < 0.1 then j = 4 elseif v < 0.5 then j = 3 else j = 2 end
    if abs(u) > 0.8 then j = j - 1 end
    if v > 0.5 and abs(u) < 0.6 then j = 1 end
    c:put(x, y, SEED[max(1, min(6, j))], tok)
  end)
end
-- split edge: pale inner coat lip and the seed's creamy nutrient between halves
for _, p in ipairs{ { 36, 43 }, { 37, 43 }, { 36, 44 }, { 37, 44 }, { 35, 44 } } do if not sm:has(p[1], p[2]) then c:put(p[1], p[2], "#f1e4c4", { r = { name = "ep" } }) end end
c:put(35, 43, WING[3], { r = { name = "ep" } })
c:put(34, 41, "#fbe8b4") -- glint on the left half
A.save(c, "satsuki-azalea-seed")
