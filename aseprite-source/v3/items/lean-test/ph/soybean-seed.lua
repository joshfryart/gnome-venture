-- soybean-seed (lean L1_0)
-- Three fat cream-yellow soybeans with oval brown hila (sleepy-eye look) on a torn broad ovate soybean leaflet; one
-- has split: sturdy stem, two plump pale cotyledons and two big heart-shaped unifoliate leaves. quirk: a dewdrop on a leaf.
local NAME = "soybean-seed"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local LEAF  = { "#17402c", "#1f5e36", "#2e7e3e", "#46a04a", "#6cbc58", "#9ad876" }
local SLEAF = { "#1c4a30", "#2a6e3c", "#3f9446", "#62b454", "#8cd068", "#bcea8c" }
local COT   = { "#4a6a30", "#6f8f3a", "#97b348", "#b8cc5c", "#d2de7c", "#eaf0a4" }
local BEAN  = { "#7a5a30", "#a8803f", "#cfa752", "#e6c570", "#f4dc90", "#fff0b8" }
local STEM  = { "#3e5a2c", "#5e7e38", "#7ea046", "#a0c05a", "#c4dc78" }
local ROOT  = { "#b8a488", "#e2d2b4", "#f6ecd6" }
local VEIN, COOL = "#cdeea0", "#3a7468"

local function seedMask(cx, cy, rl, rw, a)
  local ca, sa = cos(a), sin(a)
  local m = HP.mask()
  for y = floor(cy) - 7, floor(cy) + 7 do for x = floor(cx) - 7, floor(cx) + 7 do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / (rl + 0.4)
    local v = (-dx * sa + dy * ca)
    if abs(u) <= 1 then
      local hw = (rw + 0.4) * sqrt(1 - u * u)
      if v > 0 then hw = hw * (1 - 0.18 * (1 - u * u)) end   -- slight kidney dent on one side
      if abs(v) <= hw then m:set(x, y) end
    end
  end end
  return m
end
local seeds = {
  { 15, 49, 4.8, 3.9, -0.3 },
  { 31, 52, 4.8, 3.9, 0.15 },   -- sprouts
  { 47, 49, 4.7, 3.8, 0.4 },
}
local lm, ln, LT, LS, len = G.blade(7, 47, 31, 55, 56, 47, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.95 + 0.05)
  return max(0.45, 6.4 * sin(pi * u ^ 0.85) ^ 0.6)
end, { fold = 0.3 })
do local cm = HP.mask() lm:each(function(x, y) if LT[K(x, y)] < 0.06 and X.hash(x, y, 11) > 0.45 then cm:set(x, y) end end) lm:cut(cm) end
local sm, bias = {}, {}
for i, s in ipairs(seeds) do sm[i] = seedMask(s[1], s[2], s[3], s[4], s[5]) X.ao(bias, lm, sm[i], 1, -1) G.cast(bias, lm, sm[i], 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.2 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.02 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  for _, vt in ipairs{ 7, 13, 19, 25, 31, 37 } do
    local d = t * len - (vt + abs(s) * 4.5)
    if d > -0.5 and d < 0.5 and abs(s) > 0.18 and abs(s) < 0.7 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) return end
  end
end)
lm:edge():each(function(x, y) local k = K(x, y) if not bias[k] and LS[k] > 0.6 and LT[k] > 0.1 and LT[k] < 0.85 then c:put(x, y, COOL, ltok) end end)

-- radicle
local rm = c:line({ {35, 53}, {37, 55}, {40, 56}, {42, 55} }, 1)
rm:each(function(x, y) c:put(x, y, ROOT[2], { r = { name = "root" } }) end)
c:put(35, 53, ROOT[3]) c:put(37, 55, ROOT[3]) c:put(42, 55, ROOT[1])

-- stem
local stm, stn, ST = G.tube({ {30, 48}, {29, 39}, {33, 28}, {31, 17} }, function(t) return 1.3 - 0.35 * t end)
local stok = { r = { name = "stem" } }
local sv2 = X.light(stn, { amb = 0.15, wrap = 0.3 })
stm:each(function(x, y) local k = K(x, y) local lit = sv2[k] > 0.55
  c:put(x, y, ST[k] < 0.5 and (lit and STEM[3] or STEM[2]) or (lit and STEM[5] or STEM[4]), stok) end)

local function blade(ax, ay, cx, cy, bx, by, w, pw, veins, name, ramp, notch)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.9 + 0.1)
    local nt = (notch and t < 0.18) and (0.55 + t * 2.5) or 1
    return max(0.45, w * sin(pi * u ^ 0.8) ^ pw * nt)
  end, { fold = 0.5 })
  m:cut(stm)
  local tok = { r = { name = name } }
  G.toneN(c, m, n, ramp, { tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.12, wrap = 0.22 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.12 and t > 0.05 and t < 0.9 then c:put(x, y, s <= 0 and ramp[6] or ramp[2], tok) return end
    for _, vt in ipairs(veins) do
      local d = t * L - (vt + abs(s) * 3.0)
      if d > -0.5 and d < 0.5 and abs(s) > 0.3 and abs(s) < 0.7 then c:put(x, y, s < 0 and ramp[6] or ramp[2], tok) return end
    end
  end)
  m:edge():each(function(x, y) local k = K(x, y) if S[k] > 0.6 and T[k] > 0.15 and T[k] < 0.85 then c:put(x, y, COOL, tok) end end)
  return m, n
end
-- plump pale cotyledons (low), heart-shaped unifoliate leaves (high)
blade(29, 36, 23, 32, 15, 37, 3.6, 0.45, {}, "co1", COT)
blade(31, 35, 38, 31, 46, 36, 3.6, 0.45, {}, "co2", COT)
local U1 = blade(30, 19, 22, 11, 12, 14, 5.8, 0.6, { 5, 9 }, "u1", SLEAF, true)
blade(32, 19, 40, 11, 51, 14, 5.8, 0.6, { 5, 9 }, "u2", SLEAF, true)
for _, p in ipairs{ {30,19},{31,19},{32,19},{31,18} } do if stm:has(p[1], p[2]) then c:put(p[1], p[2], STEM[1], stok) end end
-- bud
for _, p in ipairs{ {31,16,SLEAF[5]},{31,15,SLEAF[6]},{32,15,SLEAF[4]},{31,14,SLEAF[4]} } do c:put(p[1], p[2], p[3], { r = { name = "bud" } }) end

-- beans with brown hilum
for i, s in ipairs(seeds) do
  local m = sm[i]
  local n = X.pillow(m, 3.2)
  local tok = { r = { name = "seed" .. i } }
  X.tone(c, m, X.light(n, { amb = 0.06, wrap = 0.22 }), BEAN, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 }, tok = tok })
  -- hilum: small oval on the kidney side with pale slit (a sleepy eye)
  local hx, hy = s[1] - sin(s[5]) * -2.2 * 1, s[2] + cos(s[5]) * 2.0
  local ca, sa = cos(s[5]), sin(s[5])
  for u = -1, 1 do for v = 0, 0 do
    local px, py = floor(hx + ca * u + .5), floor(hy + sa * u + .5)
    if m:has(px, py) then c:put(px, py, "#5a3420", tok) end
  end end
  local px2, py2 = floor(hx + .5), floor(hy + .5)
  if m:has(px2, py2) then c:put(px2, py2, "#b8946a", tok) end
  local bx, by = G.specAt(m, n, 30)
  if bx then c:put(bx, by, "#fffadc", tok) end
end
-- split seam of the sprouting bean
for _, p in ipairs{ {28,49},{29,50},{30,50},{27,48} } do if sm[2]:has(p[1], p[2]) then c:put(p[1], p[2], BEAN[1], { r = { name = "seed2" } }) end end
-- quirk: dewdrop on left unifoliate leaf
local DEW = { "#2e6e8c", "#62aac4", "#b4e4f0", "#f4ffff" }
local dt = { r = { name = "dew" } }
for _, p in ipairs{ {19,13,1},{20,13,2},{18,14,1},{19,14,2},{20,14,3},{21,14,2},{19,15,1},{20,15,1},{21,15,1} } do c:put(p[1], p[2], DEW[p[3]], dt) end
c:put(19, 14, DEW[4], dt)
G.save(c, NAME)
