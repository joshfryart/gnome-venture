-- acai-seed (final pass, Opus). Three round acai stones (cleaned of pulp: tan-brown, wrapped in a fine fibre mesh)
-- on a torn scrap of palm leaflet (parallel veins, ragged torn ends, V fold). The middle stone has germinated: a
-- pale shoot out of its pore, a darker sheath collar, and the palm's first leaf, a pleated two-lobed (bifid) eophyll.
-- Material: seeds per-pixel sphere light on a 6-tone ramp, curved fibre striations, stray rim fibres, one pale
-- hilum scar and one glint each; leaf scrap with midrib, parallel veins, cool reflected edge, AO + contact shadow
-- under every seed; eophyll lobes plicate (alternating lit and shaded pleats along each lobe).
-- History: Sonnet draft (_dA12) replaced.
-- quirk: a single dewdrop hangs from the tip of the right leaf lobe.
local NAME = "acai-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR1_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local YLEAF = { "#2a4a34", "#3d6e3c", "#5a9444", "#7cb450", "#a4cf66", "#cfe68c" }
local VEIN, COOL = "#b8dc8a", "#3a6c72"
local SEED  = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }
local STEM  = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local DEW   = { "#3a86b0", "#8fd4e0", "#e4f6ff" }

local seeds = { { 18, 49, 4.5 }, { 31, 46, 4.9 }, { 44, 43, 4.3 } }
for _, s in ipairs(seeds) do s.m = c:ellipse(s[1], s[2], s[3], s[3] - 0.3) end

-- torn leaflet scrap
local lm, ln, LT, LS, len = A.blade(6, 55, 30, 51, 58, 41, function(t)
  if t > 0.99 then return -1 end
  return 3.6 + 3.4 * sin(pi * t) ^ 0.8
end, { fold = 0.45 })
-- ragged torn ends
local cut = {}
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  local d = min(t, 1 - t) * len                    -- px from an end
  local rag = 1.2 + 2.2 * X.hash(floor(s * 4 + 0.5), t < 0.5 and 1 or 2, 7) + 1.2 * abs(sin(s * 7))
  if d < rag then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  for _, vs in ipairs{ -0.62, -0.32, 0.32, 0.62 } do           -- parallel veins
    if abs(s - vs) < 0.07 then c:put(x, y, vs < 0 and LEAF[6] or LEAF[2], ltok) end
  end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.06 and LT[k] < 0.94 then c:put(x, y, COOL, ltok) end end)

-- sprout: shoot from the middle stone's pore, sheath, bifid pleated eophyll
local S0x, S0y = 31, 40
local stok = { r = { name = "shoot" } }
local sm, sn = A.tube({ { 31, 42 }, { 31, 36 }, { 30, 32 }, { 31, 28 } }, function(t) return 1.25 - 0.2 * t end)
sm:cut(seeds[2].m)
A.shade(c, sm, sn, STEM, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function lobe(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.98 then return -1 end
    return max(0.5, w * sin(pi * min(1, t * 0.8 + 0.12)) ^ 0.55)
  end, { fold = 0.2 })
  m:cut(sm)
  local lb = {}
  m:each(function(x, y) local k = K(x, y)
    local s = S[k]
    -- plicate: pleat ridges along the lobe, lit/shaded alternately
    local p = floor((s + 1) * 2.2)
    if p % 2 == 1 then lb[k] = -1 end
  end)
  A.shade(c, m, n, YLEAF, { amb = 0.12, wrap = 0.3, bias = lb, tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.12 and T[k] < 0.9 then c:put(x, y, YLEAF[6], ltok) end end)
  return m, T
end
local L1 = lobe(31, 29, 25, 21, 17, 14, 3.4)
local L2, T2 = lobe(31, 29, 37, 20, 46, 13, 3.4)
-- sheath collar where the lobes split
for _, p in ipairs{ { 30, 29, 2 }, { 31, 29, 1 }, { 32, 29, 2 }, { 31, 30, 2 }, { 30, 30, 1 }, { 32, 30, 1 } } do c:put(p[1], p[2], STEM[p[3]], stok) end

-- seeds last
for i, s in ipairs(seeds) do
  local m = s.m
  local n = X.sphere(s[1] - 0.4, s[2] - 0.4, s[3] + 0.4, m)
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, m, n, SEED, { amb = 0.05, wrap = 0.2, tok = tok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.85 } })
  -- fibre mesh: curved meridian striations
  m:each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    local f = dx * (1 + 0.05 * dy * dy) + i
    if (f % 2.6) < 0.8 and abs(dx) < s[3] - 0.6 then A.step(c, idx, SEED, x, y, -1, tok) end
    if X.hash(x, y, 31 + i) > 0.9 then A.step(c, idx, SEED, x, y, 1, tok) end
  end)
  -- stray rim fibres (1 px, off the lit upper-left rim)
  for _, a in ipairs{ 3.6, 4.4 } do
    local px, py = floor(s[1] + cos(a) * (s[3] + 1) + 0.5), floor(s[2] + sin(a) * (s[3] + 0.7) + 0.5)
    if not m:has(px, py) then c:put(px, py, SEED[4], tok) end
  end
  -- hilum scar + glint
  c:put(s[1] + 2, s[2] - 2, SEED[6], tok) c:put(s[1] + 3, s[2] - 2, SEED[3], tok)
  c:put(s[1] - 2, s[2] - 3, "#fff0d0", tok) c:put(s[1] - 1, s[2] - 3, SEED[6], tok)
end
-- middle stone: germination pore around the shoot foot
c:px(30, 42, SEED[1]) c:px(32, 42, SEED[1]) c:px(31, 42, STEM[2]) c:px(31, 43, SEED[2])

-- quirk: dewdrop at the right lobe tip
local dx0, dy0 = 47, 13
c:px(dx0, dy0 + 1, DEW[1]) c:px(dx0 + 1, dy0 + 1, DEW[2]) c:px(dx0, dy0 + 2, DEW[2]) c:px(dx0 + 1, dy0 + 2, DEW[1])
c:px(dx0, dy0 + 1, DEW[3])
A.save(c, "ph", NAME)
