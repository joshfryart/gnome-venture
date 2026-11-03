-- blackcurrant-seed (final, Opus single pass). Four tiny glossy black-brown blackcurrant seeds on a torn scrap of
-- blackcurrant leaf (toothed margin, netted veins from the midrib, V-fold light, torn pale edge on the right, AO + contact
-- shadow under each seed). The middle seed has sprouted: thin stem, two round cotyledons and a first true leaf with the
-- three toothed palmate lobes of the currant bush.
-- quirk: a single bead of purple currant juice sits on the leaf, with its own glint.
local NAME = "blackcurrant-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#1b4034", "#255a3c", "#337842", "#4c984a", "#74b856", "#a6d470" }
local VEIN, COOL, TORN = "#c8e692", "#3a6a74", "#d6ecb0"
local SEED = { "#22141c", "#3a2026", "#56302e", "#764636", "#9a6646", "#c89a70" }
local STEM = { "#3e7a4c", "#6ea660", "#a2cc80", "#d8eeb0" }
local JUICE = { "#2a1638", "#45215a", "#66307e", "#8a48a2", "#b276c6", "#e0b8ec" }

-- seeds (cx, cy, rx, ry, ang)
local seeds = { { 18, 46, 2.6, 1.7, 0.35 }, { 25, 50, 2.5, 1.6, -0.3 }, { 33, 45, 2.7, 1.7, 0.1 }, { 41, 49, 2.4, 1.6, 0.6 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end

-- leaf scrap: broad currant lobe lying across, toothed margin, torn on the right
local lm, ln, LT, LS, len = A.blade(7, 50, 28, 37, 58, 47, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 10.5 * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.75)
end, { fold = 0.32 })
-- teeth: small notches every 4 px along both margins
do local cut = {}
  lm:each(function(x, y) local k = K(x, y)
    local ph = (LT[k] * len / 4.2 + (LS[k] > 0 and 0.5 or 0)) % 1
    if abs(LS[k]) > 0.86 - ph * 0.16 then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do lm.s[k] = nil end
end
local torn = A.tear(lm, LT, LS, 0.8, 0.12, 7, false)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 1, -1) end
-- juice bead (quirk) mask first so it can shadow the leaf
local jm = c:ellipse(47, 42, 1.6, 1.4)
A.cast(bias, lm, jm, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 and t < 0.8 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- netted veins: main side veins swept toward the tip, every 7 px
  local ph = ((t * len - abs(s) * 6) / 7 + (s > 0 and 0.4 or 0)) % 1
  if ph < 0.13 and abs(s) > 0.12 and abs(s) < 0.78 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] < 0.75 then c:put(x, y, COOL, ltok) end end)
torn:each(function(x, y) c:put(x, y, (LS[K(x, y)] < 0.2) and TORN or LEAF[5], ltok) end)
for _, q in ipairs{ { 6, 51, 3 }, { 5, 52, 2 }, { 4, 53, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout from seed 3
local stok = { r = { name = "stem" } }
local sp = { { 33, 44 }, { 32, 36 }, { 34, 30 }, { 33, 23 } }
local sm, sn = A.tube(sp, function(t) return 1.0 end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- round cotyledons on short stalks
local function coty(cx, cy, ang)
  local m, n = A.oval(cx, cy, 3.6, 2.2, ang, 0.7)
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  local ca, sa = cos(ang), sin(ang)
  m:each(function(x, y) local dx, dy = x - cx, y - cy
    if abs(-dx * sa + dy * ca) < 0.5 and abs(dx * ca + dy * sa) < 2.4 then c:put(x, y, LEAF[5], ltok) end end)
  return m
end
local cl = coty(27, 30, 0.35)
local cr = coty(39, 28, -0.3)
-- true leaf: three palmate lobes with toothed edges, veins from the petiole tip
local tx, ty = 33, 19
local tl = HP.mask()
local lobes = { { 0, -1, 5.2, 3.2 }, { -0.85, -0.45, 4.2, 2.7 }, { 0.85, -0.45, 4.2, 2.7 } }
for _, L in ipairs(lobes) do
  local l = math.sqrt(L[1]^2 + L[2]^2) local ux, uy = L[1] / l, L[2] / l
  L.ux, L.uy = ux, uy
  tl:add(A.rell(tx + ux * L[3] * 0.85, ty + uy * L[3] * 0.85, ux, uy, L[3], L[4]))
end
tl:add(c:ellipse(tx, ty + 0.5, 2, 1.5))
-- teeth on the leaf edge
do local e = tl:edge() local cut = {}
  e:each(function(x, y) if (x * 3 + y * 5) % 4 == 0 and not (abs(x - tx) < 2 and y > ty) then cut[#cut + 1] = { x, y } end end)
  for _, p in ipairs(cut) do tl.s[K(p[1], p[2])] = nil end
end
tl:cut(cl):cut(cr)
local tn = X.pillow(tl, 2.2)
local tb = {}
X.ao(tb, tl, sm, 1, -1)
A.toneN(c, tl, tn, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.28, bias = tb })
for _, L in ipairs(lobes) do
  for i = 1, floor(L[3] * 1.5) do local x, y = floor(tx + L.ux * i + 0.5), floor(ty + L.uy * i + 0.5)
    if tl:has(x, y) then c:put(x, y, (L.ux <= 0) and LEAF[6] or LEAF[5], ltok) end end
end
for y = ty + 1, 23 do c:put(tx, y, STEM[3], stok) end

-- seeds: glossy black-brown, a pale hilum dot, one glint each
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local idx = A.toneN(c, s.m, s.n, SEED, { tok = tok, cuts = { 0.15, 0.32, 0.5, 0.68, 0.86 }, amb = 0.05, wrap = 0.2 })
  local bx, by = A.specAt(s.m, s.n, 30)
  c:put(bx, by, A.CREAM, tok)
  -- cool bounce on the lower-right edge
  local ca, sa = cos(s[5]), sin(s[5])
  c:put(floor(s[1] + 1.6 * ca - 0.9 * sa + 0.5), floor(s[2] + 1.6 * sa + 0.9 * ca + 0.5), "#5a4a66", tok)
end

-- quirk: purple juice bead, glossy
local jtok = { r = { name = "juice" } }
A.ball(c, 47, 42, 1.6, JUICE, jtok, { ry = 1.4, mask = jm })
c:put(46, 41, A.CREAM, jtok)

A.save(c, NAME)
