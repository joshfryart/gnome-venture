-- sunflower-seed (lean L1_0)
-- Three striped black-and-white achenes on a torn heart-shaped sunflower leaf scrap; one has split: pink-green
-- hypocotyl, fat oval cotyledon pair and a tiny pair of first true leaves. quirk: a cream kernel peeks out of one hull.
local NAME = "sunflower-seed"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local LEAF  = { "#1c3a2a", "#2a5a30", "#3d7a35", "#5a9a3c", "#82b84a", "#b2d466" }
local SLEAF = { "#24512f", "#37783a", "#52a044", "#78c04e", "#a2dc62", "#d2f088" }
local LIGHT = { "#6a6258", "#8f8878", "#b4ac98", "#d2caB4", "#e8e2cc", "#f8f4e6" }
local DARK  = { "#12101a", "#1c1a26", "#2a2634", "#3a3546", "#504a5e", "#6e6680" }
local STEM  = { "#4a2a3a", "#7a3e50", "#a85a68", "#6f9a4c", "#9fc45e" }
local ROOT  = { "#b8a488", "#e2d2b4", "#f6ecd6" }
local VEIN, COOL = "#c8e48a", "#3c6f74"

local function seedMask(cx, cy, rl, rw, a)
  local ca, sa = cos(a), sin(a)
  local m, sv = HP.mask(), {}
  local R = floor(rl + rw) + 2
  for y = floor(cy) - R, floor(cy) + R do for x = floor(cx) - R, floor(cx) + R do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / (rl + 0.4)
    local v = (-dx * sa + dy * ca)
    if abs(u) <= 1 then
      local hw = (rw + 0.4) * (0.35 + 0.65 * ((1 - u) / 2) ^ 0.7) * (abs(u) > 0.85 and 1 - (abs(u) - 0.85) * 2 or 1)
      if abs(v) <= hw then m:set(x, y) sv[K(x, y)] = v / max(hw, 0.5) end
    end
  end end
  return m, sv
end
local seeds = {
  { 15, 51, 5.4, 3.0, -0.45 },
  { 29, 51, 5.4, 3.0, 0.25 },   -- sprouts
  { 43, 47, 5.4, 3.0, 2.55 },   -- kernel peeks
}

-- heart-shaped leaf scrap
local lm, ln, LT, LS, len = G.blade(8, 52, 30, 54, 57, 41, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.95 + 0.05)
  local tooth = 0.86 + 0.14 * abs(sin(t * 38))
  return max(0.45, 6.4 * sin(pi * u ^ 0.75) ^ 0.8 * tooth)
end, { fold = 0.35 })
do local cm = HP.mask() lm:each(function(x, y) if LT[K(x, y)] < 0.08 and X.hash(x, y, 7) > 0.45 then cm:set(x, y) end end) lm:cut(cm) end
local bias = {}
local sm = {}
for i, s in ipairs(seeds) do sm[i], s.sv = seedMask(s[1], s[2], s[3], s[4], s[5]) X.ao(bias, lm, sm[i], 1, -1) G.cast(bias, lm, sm[i], 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.2 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.02 and t < 0.93 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  for _, vt in ipairs{ 8, 13, 18, 24, 30, 36 } do
    local d = t * len - (vt + abs(s) * 4.0)
    if d > -0.55 and d < 0.55 and abs(s) > 0.18 and abs(s) < 0.8 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) return end
  end
end)
lm:edge():each(function(x, y) local k = K(x, y) if not bias[k] and LS[k] > 0.6 and LT[k] > 0.1 and LT[k] < 0.8 then c:put(x, y, COOL, ltok) end end)

-- radicle
local rm = c:line({ {34, 52}, {36, 54}, {39, 55}, {42, 54}, {43, 53} }, 1)
rm:each(function(x, y) c:put(x, y, ROOT[2], { r = { name = "root" } }) end)
c:put(34, 52, ROOT[3]) c:put(36, 54, ROOT[3]) c:put(43, 53, ROOT[1])
rm:shift(0, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)

-- stem
local stm, stn, ST = G.tube({ {28, 47}, {27, 39}, {32, 30}, {31, 23} }, function(t) return 1.2 - 0.3 * t end)
local stok = { r = { name = "stem" } }
local sv2 = X.light(stn, { amb = 0.15, wrap = 0.3 })
stm:each(function(x, y) local k = K(x, y) local lit = sv2[k] > 0.55
  local col = ST[k] < 0.5 and (lit and STEM[3] or STEM[2]) or (lit and STEM[5] or STEM[4])
  c:put(x, y, col, stok) end)

local function blade(ax, ay, cx, cy, bx, by, w, pw, veins, name)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.9 + 0.1)
    return max(0.45, w * sin(pi * u) ^ pw)
  end, { fold = 0.5 })
  m:cut(stm)
  local tok = { r = { name = name } }
  G.toneN(c, m, n, SLEAF, { tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.12, wrap = 0.22 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.12 and t > 0.05 and t < 0.9 then c:put(x, y, s <= 0 and SLEAF[6] or SLEAF[2], tok) return end
    for _, vt in ipairs(veins) do
      local d = t * L - (vt + abs(s) * 3.0)
      if d > -0.5 and d < 0.5 and abs(s) > 0.3 and abs(s) < 0.7 then c:put(x, y, s < 0 and SLEAF[6] or SLEAF[2], tok) return end
    end
  end)
  m:edge():each(function(x, y) local k = K(x, y) if S[k] > 0.6 and T[k] > 0.15 and T[k] < 0.85 then c:put(x, y, COOL, tok) end end)
  return m
end
-- first true leaves (behind), then fat cotyledons
blade(32, 23, 30, 15, 26, 9, 2.2, 0.8, { 3 }, "tl1")
blade(33, 23, 36, 15, 40, 9, 2.2, 0.8, { 3 }, "tl2")
local C1 = blade(31, 24, 23, 17, 12, 21, 4.8, 0.5, { 5, 9 }, "co1")
blade(33, 24, 41, 17, 52, 21, 4.8, 0.5, { 5, 9 }, "co2")
for _, p in ipairs{ {31, 24}, {32, 24}, {33, 24} } do if stm:has(p[1], p[2]) then c:put(p[1], p[2], STEM[1], stok) end end

-- quirk kernel peeking from seed 3's pointed end
do local s = seeds[3]
  local kx, ky = s[1] + cos(s[5]) * (s[3] + 0.6), s[2] + sin(s[5]) * (s[3] + 0.6)
  local km = HP.mask() for dy = -2, 2 do for dx = -2, 2 do if dx * dx + dy * dy <= 3.4 then km:set(floor(kx + dx + .5), floor(ky + dy + .5)) end end end
  km:cut(sm[3])
  local kt = { r = { name = "kernel" } }
  km:each(function(x, y) local lit = (x - kx) + (y - ky) < 0.5 c:put(x, y, lit and "#f6e6b0" or "#d6b878", kt) end)
end

-- seeds
for i, s in ipairs(seeds) do
  local m = sm[i]
  local n = X.pillow(m, 2.8)
  local tok = { r = { name = "seed" .. i } }
  local idx = X.tone(c, m, X.light(n, { amb = 0.06, wrap = 0.22 }), LIGHT, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 }, tok = tok })
  m:each(function(x, y) local k = K(x, y)
    local b = min(4, floor((s.sv[k] + 1) * 2.5))
    if b % 2 == 0 then c:put(x, y, DARK[idx[k]], tok) end end)
  local tx, ty = floor(s[1] + cos(s[5]) * (s[3] - 0.3) + .5), floor(s[2] + sin(s[5]) * (s[3] - 0.3) + .5)
  if m:has(tx, ty) then c:put(tx, ty, "#c9b48a", tok) end
  local bx, by = G.specAt(m, n, 30)
  if bx then c:put(bx, by, "#fbf6e8", tok) end
end
c:put(26, 48, DARK[1], { r = { name = "seed2" } }) c:put(27, 49, DARK[1], { r = { name = "seed2" } })
G.save(c, NAME)
