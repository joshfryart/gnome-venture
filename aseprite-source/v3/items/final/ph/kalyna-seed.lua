-- kalyna-seed (final pass, Opus single pass). Two flat, heart-shaped kalyna (guelder-rose) stones (cream-apricot,
-- bevelled rim, a pale keel line, one glint) and one whole glossy scarlet berry (waxy bloom, hard specular, cool
-- reflected edge, dried calyx star) on a torn, toothed lobe of kalyna leaf that runs down from upper left to lower
-- right (sawtooth margin, pale midrib, palmate side veins, cool rim, AO + contact shadow). The front stone has
-- sprouted: red-flushed stem, two oval cotyledons and a first three-lobed true leaf (the kalyna maple-ish shape).
-- quirk: one drop of red berry juice has run out onto the leaf.
local NAME = "kalyna-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#14303a", "#1e4a40", "#2c6a46", "#43894c", "#68ab58", "#9cce74" }
local COOL, VEIN, TISSUE = "#3e6e7e", "#cfe6a0", "#d8ecb0"
local STONE = { "#5a3428", "#8a5636", "#b98250", "#dcaa72", "#f2cc96", "#fff0cc" }
local BER = { "#4e1426", "#7e1a2c", "#b42430", "#e0383a", "#ff6a52", "#ffb08a" }
local SPR = { "#2a5640", "#3d7648", "#5c9a54", "#84bc66", "#b2da88", "#e0f2b8" }
local STEM = { "#7a3a3a", "#b0605a", "#d8988a", "#f4d4c4" }

-- leaf scrap: from upper left down to lower right, toothed margin, torn at the left end
local lm, ln, LT, LS, len = A.blade(54, 54, 32, 56, 9, 40, function(t)
  if t > 0.995 then return -1 end
  return max(0.6, 8.6 * sin(pi * min(1, t * 0.8 + 0.12)) ^ 0.55)
end, { fold = 0.4 })
-- sawtooth: asymmetric teeth leaning toward the tip
do
  local cut = {}
  lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
    local ph = t * len / 3.2 + (s > 0 and 0.5 or 0)
    local f = ph - floor(ph)                       -- 0..1 ramp = sawtooth
    local lim = 0.98 - (1 - f) * 0.26
    if t > 0.06 and t < 0.95 and abs(s) > lim then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do lm.s[k] = nil end
end
local torn = A.tear(lm, LT, LS, 0.82, { 0.05, -0.02, 0.04, -0.04, 0.03, 0.06, -0.03, 0 })

local stones = { { 22, 45, 3.6, 2.6, -0.5 }, { 30, 48, 3.4, 2.5, 0.35 } }
for _, s in ipairs(stones) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 1.8) end
-- heart notch at the stalk end of each stone
for _, s in ipairs(stones) do
  local ux, uy = cos(s[5]), sin(s[5])
  s.m:cut(A.rell(s[1] - ux * (s[3] + 0.6), s[2] - uy * (s[3] + 0.6), ux, uy, 1.3, 0.9))
end
local berry = { 40, 46, 4.6 }
local bm = A.oval(berry[1], berry[2], berry[3], berry[3], 0, 1)
local bn = X.sphere(berry[1], berry[2], berry[3], bm)

-- quirk mask: juice drop + run
local jm = HP.mask()
for _, q in ipairs{ { 43, 51 }, { 44, 51 }, { 44, 52 }, { 45, 52 }, { 45, 53 }, { 46, 53 }, { 46, 54 }, { 47, 54 }, { 45, 54 }, { 46, 55 }, { 47, 55 } } do jm:set(q[1], q[2]) end

local bias = {}
for _, s in ipairs(stones) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
X.ao(bias, lm, bm, 1, -1) A.cast(bias, lm, bm, 1, 2, -1) A.cast(bias, lm, bm, 2, 3, -1)
local ltok = { r = { name = "leaf" } }
A.leaf(c, lm, ln, LT, LS, { ramp = LEAF, vein = VEIN, cool = COOL, per = 6.5, sweep = 6, len = len, torn = torn,
  tissue = TISSUE, tok = ltok, bias = bias, t1 = 0.84 })
for _, q in ipairs{ { 55, 54, 3 }, { 56, 54, 2 }, { 57, 55, 2 } } do c:put(q[1], q[2], STEM[q[3]], ltok) end

-- juice (quirk): dark red pool with one bright glint
do local tok = { r = { name = "juice" } }
  jm:each(function(x, y) c:put(x, y, (x + y) % 3 == 0 and BER[3] or BER[2], tok) end)
  c:put(46, 54, BER[5], tok) c:put(44, 51, BER[3], tok)
end

-- sprout from stone 1: stem
local stok = { r = { name = "stem" } }
local sp = { { 21, 43 }, { 20, 36 }, { 24, 30 }, { 22, 24 } }
local sm, sn = A.tube(sp, function(t) return 1.05 end)
A.shade(c, sm, sn, STEM, { tok = stok, amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
-- oval cotyledons
local ctok = { r = { name = "coty" } }
local function oco(cx, cy, ux, uy, ra, rb)
  local l = sqrt(ux * ux + uy * uy) ux, uy = ux / l, uy / l
  local m = A.rell(cx, cy, ux, uy, ra, rb)
  return m, X.pillow(m, 1.6), ux, uy
end
local cl, cln, lux, luy = oco(17.5, 25, -1, -0.25, 4.2, 2.0)
local cr, crn, rux, ruy = oco(27, 25.5, 1, -0.15, 4.2, 2.0)
cl:cut(sm) cr:cut(sm)
local sb = {}
X.ao(sb, cl, sm, 1, -1) X.ao(sb, cr, sm, 1, -1)
A.shade(c, cl, cln, SPR, { tok = ctok, bias = sb, amb = 0.1, wrap = 0.3 })
A.shade(c, cr, crn, SPR, { tok = ctok, bias = sb, amb = 0.1, wrap = 0.3 })
for i = -2, 2 do
  c:put(floor(17.5 + lux * i + 0.5), floor(25 + luy * i + 0.5), SPR[6], ctok)
  c:put(floor(27 + rux * i + 0.5), floor(25.5 + ruy * i + 0.5), SPR[3], ctok)
end
-- three-lobed true leaf above, on a short petiole
local tl = HP.mask()
tl:add(A.rell(22, 15.5, 0, -1, 4.3, 2.4))
tl:add(A.rell(18.6, 18.6, -0.8, -0.55, 3.4, 2.0))
tl:add(A.rell(25.6, 18.8, 0.8, -0.5, 3.4, 2.0))
tl:add(A.rell(22, 19.5, 0, -1, 2.2, 2.2))
-- teeth: nick a few rim pixels
for _, q in ipairs{ { 20, 13 }, { 24, 13 }, { 15, 18 }, { 29, 18 }, { 16, 20 } } do tl.s[K(q[1], q[2])] = nil end
tl:cut(sm:copy():cut(HP.mask()))
local tn = X.pillow(tl, 1.8)
local ttok = { r = { name = "tleaf" } }
local ti = A.shade(c, tl, tn, LEAF, { tok = ttok, amb = 0.12, wrap = 0.3, cuts = { 0.12, 0.28, 0.44, 0.6, 0.76 } })
-- palmate veins from the leaf base
for _, v in ipairs{ { 0, -1, 6 }, { -0.8, -0.6, 4 }, { 0.8, -0.6, 4 } } do
  for i = 1, v[3] do local x, y = floor(22 + v[1] * i + 0.5), floor(21 + v[2] * i + 0.5)
    if tl:has(x, y) then c:put(x, y, v[1] <= 0 and VEIN or LEAF[3], ttok) end end
end
c:put(22, 22, STEM[3], stok) c:put(22, 23, STEM[2], stok)

-- berry: glossy sphere, bloom, spec, cool bounce, calyx
do local tok = { r = { name = "berry" } }
  local b = {}
  for _, s in ipairs(stones) do X.ao(b, bm, s.m, 1, -1) end
  local idx = A.seed(c, bm, bn, BER, { tok = tok, bias = b, amb = 0.06, wrap = 0.2, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, rim = "#9a4a7a" })
  -- waxy bloom: pale speckle on the mid tones
  bm:each(function(x, y) local k = K(x, y) if idx[k] == 4 and (x + 2 * y) % 5 == 0 then c:put(x, y, BER[5], tok) end end)
  local gx, gy = A.specAt(bm, bn, 40)
  c:put(gx, gy, "#fff4d6", tok) c:put(gx + 1, gy, BER[6], tok) c:put(gx, gy + 1, BER[6], tok)
  -- dried calyx star at lower right
  local cx, cy = 42, 48
  for _, q in ipairs{ { 0, 0, "#3a1a1e" }, { 1, 0, "#5a3a2a" }, { 0, 1, "#5a3a2a" }, { -1, 0, "#2b1c26" }, { 0, -1, "#2b1c26" } } do c:put(cx + q[1], cy + q[2], q[3], tok) end
end

-- stones: flat lens, bevelled rim, keel line, glint
for i, s in ipairs(stones) do
  local vis = s.m:copy()
  local b = {}
  for j = i + 1, #stones do vis:cut(stones[j].m) X.ao(b, s.m, stones[j].m, 1, -1) end
  vis:cut(bm) X.ao(b, s.m, bm, 1, -1)
  if i == 1 then X.ao(b, s.m, sm, 1, -1) end
  local tok = { r = { name = "stone" .. i } }
  local idx = A.shade(c, vis, s.n, STONE, { tok = tok, bias = b, amb = 0.08, wrap = 0.2, cuts = { 0.15, 0.3, 0.46, 0.62, 0.8 } })
  -- bevel: inner ring one tone lighter on lit side, darker on shade side
  local e = vis:edge()
  vis:each(function(x, y) local k = K(x, y)
    if not e:has(x, y) then
      local nn = s.n[k]
      if nn and (nn[1] + nn[2]) > 0.35 and (e:has(x + 1, y) or e:has(x, y + 1)) then c:put(x, y, STONE[max(1, idx[k] - 1)], tok) end
    end end)
  -- keel: pale line along the long axis
  local ux, uy = cos(s[5]), sin(s[5])
  for t = -2, 1 do local x, y = floor(s[1] + ux * t + 0.5), floor(s[2] + uy * t - 0.3 + 0.5)
    if vis:has(x, y) and not e:has(x, y) then c:put(x, y, STONE[6], tok) end end
  local gx, gy = A.specAt(vis, s.n, 30) if gx then c:put(gx, gy, "#fff4d6", tok) end
end
c:put(21, 43, STEM[2], stok) c:put(21, 44, STEM[1], stok)

A.save(c, NAME)
