-- saffron-seed (final, Sonnet high single pass). Saffron crocus is sterile and grown from corms, so the "seeds" are
-- three squat corms in a papery brown tunic of netted fibres (vertical strands, cross flecks, frayed apex tuft, pale
-- neck) lying on a torn grass-like crocus leaf (white median stripe, fine parallel veins, ragged cut end, cool bounce,
-- AO + contact shadow under each corm). The right corm has sprouted: pale sheath, two white-striped blades and a
-- closed violet bud with veins.
-- quirk: the bud has split its tip early and three crimson saffron threads already poke out, trumpet-tipped.
local NAME = "saffron-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local LEAF   = { "#16402f", "#1f5c3a", "#2f7d42", "#4a9f4c", "#76c05c", "#a8dc78" }
local STRIPE = { "#7aa860", "#a9cf84", "#d2eba4", "#eefacb" }
local COOL   = "#3a7478"
local SEED   = { "#34201a", "#573621", "#7b4e2c", "#a06a3a", "#c6914e", "#e6bb78" }
local FIBRE  = "#f0d49a"
local DUSK   = { "#2a1f4e", "#40307a", "#5a459e", "#7a5fc4", "#a68ae6", "#d2c0f8" }
local STEM   = { "#8ab070", "#b4d28c", "#d8ecb0", "#eefbd0" }
local RED    = { "#8a2236", "#b52e3f", "#e8493b", "#ff7a50", "#ffa878" }
local ltok = { r = { name = "leaf" } }

-- corms (cx, cy, rx, ry, angle); the right one sprouts
local corms = { { 15, 53, 5.0, 4.2, 0.1 }, { 28, 50, 5.4, 4.5, -0.12 }, { 43, 45, 5.7, 4.7, 0.05 } }
for _, s in ipairs(corms) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.85) end

-- torn crocus leaf scrap (long, slightly sagging blade; ragged cut at the left end)
local lm, ln, LT, LS, len = G.blade(6, 55, 30, 57, 55, 46, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.95 + 0.05)
  return max(0.6, 7.4 * sin(pi * u) ^ 0.55)
end, { fold = 0.3 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  if LT[k] < 0.03 + 0.035 * ((y * 7 + 3) % 4) then cut[#cut + 1] = k end
  -- one small bite out of the lower edge
  if (x - 36) ^ 2 + (y - 60) ^ 2 < 6.5 and LS[k] > 0.3 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(corms) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
local li = G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s, t = LS[k], LT[k]
  if abs(s) < 0.17 and t > 0.05 and t < 0.97 then c:put(x, y, s <= 0 and STRIPE[4] or STRIPE[3], ltok)
  elseif abs(s) < 0.27 and t > 0.05 and t < 0.97 then c:put(x, y, s <= 0 and STRIPE[2] or STRIPE[1], ltok)
  elseif abs(abs(s) - 0.58) < 0.06 and t > 0.07 and t < 0.95 then c:put(x, y, LEAF[max(1, (li[k] or 3) - 1)], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.68 and LT[k] > 0.1 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)

-- sprout, drawn before the corm so the sheath foot sits inside the tunic
local stok = { r = { name = "stem" } }
local sm, sn = G.tube({ { 43, 44 }, { 43, 40 }, { 43, 37 }, { 43, 34 } }, function(t) return 1.9 - 0.3 * t end)
sm:cut(corms[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function blade(ax, ay, cx, cy, bx, by)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.35, 2.1 * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.6)
  end, { fold = 0.35 })
  m:cut(sm)
  local idx = G.toneN(c, m, n, LEAF, { tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.2 and T[k] > 0.08 and T[k] < 0.9 then c:put(x, y, S[k] <= 0 and STRIPE[4] or STRIPE[2], ltok) end end)
  return m
end
local bl = blade(42, 39, 34, 40, 28, 17)
local br = blade(44, 39, 53, 38, 54, 18)

-- bud: closed violet tulip-shaped bud with petal veins
local bm, bn = G.oval(43, 29, 5.3, 2.9, -1.5708, 0.9)
bm:cut(sm)
local btok = { r = { name = "bud" } }
local bi = G.toneN(c, bm, bn, DUSK, { tok = btok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.1, wrap = 0.25 })
bm:each(function(x, y) local k = K(x, y)
  local d = bi[k] or 3
  if y >= 26 and y <= 31 and (x == 41 or x == 45) then c:put(x, y, DUSK[max(1, d - 1)], btok) end
  if x == 43 and y >= 28 then c:put(x, y, DUSK[max(1, d - 1)], btok) end
end)
c:put(41, 25, DUSK[5], btok) c:put(40, 28, DUSK[6], btok) c:put(40, 29, DUSK[6], btok)
-- split tip: dark slit where the threads emerge
c:put(42, 24, DUSK[1], btok) c:put(43, 24, DUSK[1], btok) c:put(44, 24, DUSK[1], btok)
-- quirk: three crimson saffron threads, trumpet tips
local function thread(x0, y0, x1, y1, tipx, tipy)
  G.bres(c, x0, y0, x1, y1, function(x, y, i, n)
    if i < n * 0.45 then return RED[2] elseif i < n then return RED[3] end
  end)
  c:put(x1, y1, RED[4]) c:put(x1 + tipx, y1 + tipy, RED[5]) c:put(x1, y1 - 1, RED[4])
end
thread(42, 23, 39, 17, -1, 0)
thread(43, 23, 43, 15, 0, -1)
thread(44, 23, 47, 17, 1, 0)

-- corms last: tunic fibres, cross flecks, frayed apex, pale neck, ambient shading between neighbours
for i, s in ipairs(corms) do
  local tok = { r = { name = "corm" .. i } }
  local cb = {}
  for j = i + 1, #corms do X.ao(cb, s.m, corms[j].m, 1, -1) end
  local idx = G.toneN(c, s.m, s.n, SEED, { tok = tok, bias = cb, cuts = { 0.22, 0.38, 0.54, 0.7, 0.86 }, amb = 0.08, wrap = 0.25 })
  s.m:each(function(x, y) local k = K(x, y)
    local u = x - s[1]
    local d = idx[k] or 3
    if u % 3 == 0 and y > s[2] - s[4] + 1 then c:put(x, y, SEED[max(1, d - 1)], tok)
    elseif (y * 2 + u + 40) % 7 == 0 and d >= 3 then c:put(x, y, SEED[min(6, d + 1)], tok) end
    if y >= s[2] + s[4] - 0.6 then c:put(x, y, SEED[max(1, d - 1)], tok) end   -- bottom rim in shade
  end)
  local ty = floor(s[2] - s[4] + 0.5)
  if i < 3 then
    -- pointed neck + frayed tuft
    local tip = G.rell(s[1], s[2] - s[4] - 0.4, 0, -1, 2.3, 1.5)
    tip:cut(s.m)
    local tn = X.pillow(tip, 1.3)
    G.toneN(c, tip, tn, SEED, { tok = tok, cuts = { 0.3, 0.45, 0.6, 0.75, 0.9 }, amb = 0.1, wrap = 0.3 })
    c:put(s[1] - 1, ty - 3, FIBRE, tok) c:put(s[1], ty - 3, SEED[5], tok) c:put(s[1] + 2, ty - 2, FIBRE, tok)
    c:put(s[1] + 1, ty - 3, SEED[4], tok)
    s.m:add(tip)
  else
    -- collar where the shoot leaves the tunic
    for dx = -2, 2 do c:put(s[1] + dx, ty + 1, SEED[abs(dx) == 2 and 3 or 5], tok) end
    c:put(s[1] - 3, ty + 1, FIBRE, tok) c:put(s[1] + 3, ty, FIBRE, tok)
  end
  local sx, sy = G.specAt(s.m, s.n, 30)
  if sx then c:put(sx, sy, "#f6dca4", tok) c:put(sx + 1, sy, "#f6dca4", tok) c:put(sx, sy + 1, SEED[5], tok) end
end

G.save2(c, NAME)
