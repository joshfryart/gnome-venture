-- tea-seed (lean L1_1)
-- Four glossy chestnut-brown tea seeds (round, pale oval hilum patch) on a glossy elliptic serrated camellia leaf with a deep
-- midrib and looping veins; one seed has split and sends up a thick stem with a cotyledon pair, a true leaf pair and a bud.
-- quirk: the sprout's terminal bud is silver-fuzzy white like a real "silver needle" tea tip.
local NAME = "tea-seed"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local LEAF  = { "#0f2e30", "#17463a", "#226046", "#34805a", "#52a068", "#86c488" }
local SLEAF = { "#17463a", "#26704a", "#3c9055", "#62b062", "#8ccd74", "#c0e69a" }
local SEEDC = { "#2a1410", "#4a2216", "#6e3a20", "#92562c", "#b87a40", "#dca868" }
local STEM  = { "#3a2a22", "#5e4030", "#86603e", "#7a9a52", "#a4be68" }
local VEIN, GLOSS, COOL = "#9edc9a", "#e2f8c8", "#305e70"

local function seedMask(cx, cy, r)   -- big round-ish chestnut, a touch flattened
  local m = HP.mask()
  for y = floor(cy) - 6, floor(cy) + 6 do for x = floor(cx) - 6, floor(cx) + 6 do
    local dx, dy = x - cx, y - cy
    if (dx / (r + 0.5)) ^ 2 + (dy / (r + 0.1)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local seeds = { { 14, 49, 4.4 }, { 26, 56, 4.0 }, { 38, 50, 4.2 }, { 51, 53, 4.0 } }
for _, s in ipairs(seeds) do s.m = seedMask(s[1], s[2], s[3]) s.n = X.pillow(s.m, 3.4) end

-- big elliptic leaf lying low and level, serrated
local lm, ln, LT, LS, len = G.blade(8, 50, 29, 58, 57, 48, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.95 + 0.05)
  return max(0.5, 7.4 * sin(pi * u) ^ 0.6)
end, { fold = 0.5 })
local nib = HP.mask()
lm:edge():each(function(x, y) local k = K(x, y)
  if abs(LS[k]) > 0.6 and LT[k] > 0.12 and LT[k] < 0.92 and ((LT[k] * len) % 3.4) < 0.9 then nib:set(x, y) end end)
lm:cut(nib)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) G.cast(bias, lm, s.m, 2, 2, -1) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.2 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 and t > 0.01 and t < 0.94 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  for _, vt in ipairs{ 7, 13, 19, 25, 31, 37, 43 } do   -- sunken looping lateral veins
    local d = t * len - (vt + abs(s) * 6.0 - 0.8 * (s * s) * 3)
    if d > -0.55 and d < 0.55 and abs(s) > 0.16 and abs(s) < 0.78 then c:put(x, y, s < 0 and LEAF[5] or LEAF[1], ltok) return end
  end
  if s < -0.4 and s > -0.62 and t > 0.62 and t < 0.84 then c:put(x, y, GLOSS, ltok) end
  if s < -0.2 and s > -0.3 and t > 0.18 and t < 0.3 then c:put(x, y, GLOSS, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LS[k] > 0.62 and LT[k] > 0.1 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)

-- sprout: sturdy stem, cotyledon pair low, true leaf pair, silver bud
local stm, stn, ST = G.tube({ {37, 46}, {37, 36}, {34, 28}, {35, 18} }, function(t) return 1.1 - 0.3 * t end)
local stok = { r = { name = "stem" } }
local sv = X.light(stn, { amb = 0.15, wrap = 0.3 })
stm:each(function(x, y) local k = K(x, y) local lit = sv[k] > 0.55
  local col
  if ST[k] < 0.5 then col = lit and STEM[3] or STEM[2] else col = lit and STEM[5] or STEM[4] end
  c:put(x, y, col, stok) end)
local function sleaf(name, ax, ay, cx, cy, bx, by, w, veins, serr)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.9 + 0.1)
    return max(0.5, w * sin(pi * u ^ 1.2) ^ 0.7)
  end, { fold = 0.5 })
  m:cut(stm)
  local tok = { r = { name = name } }
  G.toneN(c, m, n, SLEAF, { tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.12, wrap = 0.22 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.14 and t > 0.05 and t < 0.9 then c:put(x, y, s <= 0 and SLEAF[6] or SLEAF[2], tok) return end
    for _, vt in ipairs(veins) do
      local d = t * L - (vt + abs(s) * 3.0)
      if d > -0.5 and d < 0.5 and abs(s) > 0.28 and abs(s) < 0.72 then c:put(x, y, s < 0 and SLEAF[6] or SLEAF[2], tok) return end
    end
  end)
  m:edge():each(function(x, y) local k = K(x, y) if S[k] > 0.6 and T[k] > 0.15 and T[k] < 0.85 then c:put(x, y, COOL, tok) end end)
end
-- thick rounded cotyledons (low), then longer pointed true leaves
sleaf("cotl", 36, 36, 31, 38, 25, 35, 3.4, { 4 })
sleaf("cotr", 37, 35, 43, 37, 48, 34, 3.4, { 4 })
sleaf("tl", 35, 24, 29, 20, 21, 20, 3.6, { 4, 8 })
sleaf("tr", 35, 22, 41, 17, 50, 17, 3.6, { 4, 8 })
-- silver-fuzz terminal bud: a pointed white-green tip with fuzz pixels
local bud = { {35,17,"#d8ecc4"}, {35,16,"#eef8e4"}, {35,15,"#f8fff0"}, {36,16,"#c0dca8"}, {36,17,"#a4c88c"}, {34,17,"#a4c88c"}, {35,14,"#f6fcf0"}, {34,16,"#dff0d0"} }
for _, p in ipairs(bud) do c:put(p[1], p[2], p[3], { r = { name = "bud" } }) end
c:put(37, 15, "#e8f4dc", { r = { name = "bud" } }) c:put(33, 15, "#e8f4dc", { r = { name = "bud" } })
for _, p in ipairs{ {35, 25}, {35, 24}, {36, 36} } do if stm:has(p[1], p[2]) then c:put(p[1], p[2], STEM[1], stok) end end

-- seeds: glossy chestnuts with a pale oval hilum patch and a strong spec
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local idx = X.tone(c, s.m, X.light(s.n, { amb = 0.05, wrap = 0.2 }), SEEDC, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 }, tok = tok })
  -- hilum: pale oval patch at one side
  local hx, hy = s[1] + 2, s[2] + 2
  if i == 2 then hx, hy = s[1] - 2, s[2] + 2 end
  if i == 4 then hx, hy = s[1] + 3, s[2] - 1 end
  for _, d in ipairs{ {0,0}, {1,0}, {0,1}, {1,1}, {-1,0} } do
    if s.m:has(hx + d[1], hy + d[2]) then c:put(hx + d[1], hy + d[2], (d[1] == 1 and d[2] == 1) and "#a89068" or "#d6c49a", tok) end end
  local bx, by = G.specAt(s.m, s.n, 28)
  if bx then c:put(bx, by, "#fff2dc", tok) c:put(bx + 1, by, SEEDC[6], tok) end
end
-- sprouting seed (#1 is at left; the sprout stands apart on the right from the third seed's cracked twin: seed #3 is the cracked one)
for _, p in ipairs{ {36, 48}, {37, 48}, {38, 47} } do if seeds[3].m:has(p[1], p[2]) then c:put(p[1], p[2], SEEDC[1], { r = { name = "seed3" } }) end end
G.save(c, NAME)
