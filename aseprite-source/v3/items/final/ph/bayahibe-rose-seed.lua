-- bayahibe-rose-seed (ph, Opus single pass, aR3_5). Three glossy black-brown lens seeds of the bayahibe rose (Pereskia,
-- the leafy cactus) on a torn scrap of its thick, waxy elliptic leaf: the scrap shows its succulent thickness as a
-- darker side lip, pinnate veins, a waxy bloom specular and a pale torn end on the right, AO + contact shadow under the
-- seeds. The middle seed has sprouted: a stout succulent stem with a woolly areole and two fine spines (the cactus tell),
-- two fleshy round cotyledons and the first pair of elliptic true leaves.
-- quirk: a single curled pink bayahibe-rose petal has dropped onto the scrap.
local NAME = "bayahibe-rose-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR3_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local LEAF  = { "#143430", "#1b4d44", "#27684e", "#3c8858", "#66aa68", "#a2d08e" }
local SIDE  = { "#10282a", "#2a5a4c" }
local VEINL, VEIND, COOL, TORN = "#c8eab0", "#1a4a40", "#3a6878", "#d4ecb0"
local SEED  = { "#1a1018", "#271820", "#38222a", "#503236", "#704a48", "#a07c78" }
local STEM  = { "#2b5a40", "#3f7c4e", "#5e9e5c", "#8cc278", "#c0e2a0" }
local PET   = { "#7d2c5e", "#b0467a", "#d8689a", "#f08cb2", "#ffb8d0", "#ffe0ea" }
local CUTS  = { 0.2, 0.36, 0.52, 0.68, 0.84 }

local A, C, B = { 9, 52 }, { 29, 48 }, { 56, 34 }
local function spine(t, off)
  local u = 1 - t
  local x, y = u*u*A[1] + 2*u*t*C[1] + t*t*B[1], u*u*A[2] + 2*u*t*C[2] + t*t*B[2]
  local dx, dy = 2*u*(C[1]-A[1]) + 2*t*(B[1]-C[1]), 2*u*(C[2]-A[2]) + 2*t*(B[2]-C[2])
  local l = sqrt(dx*dx + dy*dy)
  return x - dy / l * off, y + dx / l * off, math.atan(dy, dx)
end
-- seeds: lens shapes, glossy
local seeds = {}
for _, q in ipairs{ { 0.42, 1.6, 0.9 }, { 0.6, -0.8, 0.2 }, { 0.73, 2.4, -0.6 } } do
  local x, y, a = spine(q[1], q[2]) seeds[#seeds + 1] = { x, y, 2.9, 2.1, a + q[3] }
end
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.6) end
local SPR = 2

-- petal (quirk) mask: a curled cupped petal near the base end
local px0, py0 = spine(0.24, -4.5)
local PA = -0.6
local petal = G.rell(px0, py0, cos(PA), sin(PA), 6.0, 4.0)
petal:cut(G.rell(px0 + 6.4 * cos(PA), py0 + 6.4 * sin(PA), 1, 0, 2.2, 2.2))   -- heart notch at the outer end
petal:cut(G.rell(px0 - 6.2 * cos(PA), py0 - 6.2 * sin(PA), cos(PA), sin(PA), 3.0, 1.2))  -- narrow claw at the base

-- leaf scrap ---------------------------------------------------------------------------------------------------------
local lm, ln, LT, LS, len = G.blade(A[1], A[2], C[1], C[2], B[1], B[2], function(t)
  if t > 0.99 then return -1 end
  return max(0.3, 7.8 * sin(pi * min(1, t * 0.86 + 0.02)) ^ 0.85)
end, { fold = 0.55 })
G.tear(lm, 49, 0, 1, -0.45, 2.4, 4)
local tops = { petal }
for _, s in ipairs(seeds) do tops[#tops + 1] = s.m end
local bias, aob = {}, {}
for _, m in ipairs(tops) do
  X.ao(bias, lm, m, 1, -1) G.cast(bias, lm, m, 1, 2, -1)
  X.ao(aob, lm, m, 1, -1) G.cast(aob, lm, m, 1, 2, -1)
end
-- succulent thickness: a 1-2 px lip below/right of the blade
local side = lm:shift(0, 1):cut(lm)
local stok = { r = { name = "side" } }
side:each(function(x, y) c:put(x, y, SIDE[2], stok) end)
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.28, 0.46, 0.62, 0.8, 0.93 }, amb = 0.12, wrap = 0.3 })
local PER = 7.0
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if aob[k] then return end
  if abs(s) < 0.1 and t > 0.03 and t < 0.95 then c:put(x, y, s <= 0 and VEINL or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 6.5) / PER + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.12 and abs(s) < 0.8 and t > 0.08 and t < 0.9 then c:put(x, y, s < 0 and VEINL or VEIND, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not aob[k] and LS[k] > 0.8 and LT[k] < 0.7 and LT[k] > 0.15 and (x + y) % 3 == 0 then c:put(x, y, COOL, ltok) end
  if LS[k] < -0.7 and not aob[k] then c:put(x, y, LEAF[5], ltok) end          -- waxy lit lip on the upper edge
  if LT[k] > 0.7 and not lm:has(x + 1, y) and not lm:has(x + 1, y - 1) then c:put(x, y, TORN, ltok) end end)
-- short fleshy petiole at the pointed base
do local pt = { r = { name = "petiole" } }
  for _, q in ipairs{ { A[1] - 1, A[2] + 1, 4 }, { A[1] - 2, A[2] + 1, 3 }, { A[1] - 3, A[2] + 2, 3 }, { A[1] - 4, A[2] + 2, 2 },
      { A[1] - 1, A[2] + 2, 2 }, { A[1] - 2, A[2] + 2, 2 }, { A[1] - 3, A[2] + 3, 1 } } do c:put(q[1], q[2], STEM[q[3]], pt) end
end
-- waxy bloom specular
do local inn = lm:shrink(2)
  inn:each(function(x, y) local k = K(x, y) if aob[k] or LT[k] < 0.25 or LT[k] > 0.55 then inn.s[k] = nil end end)
  local bx, by = G.specAt(inn, ln, 30)
  if bx then c:put(bx, by, "#e8f6c8", ltok) c:put(bx + 1, by, "#e8f6c8", ltok) c:put(bx + 2, by, LEAF[6], ltok) c:put(bx - 1, by + 1, LEAF[6], ltok) end
end

-- sprout from the middle seed --------------------------------------------------------------------------------------
local SX, SY = floor(seeds[SPR][1] + 0.5), floor(seeds[SPR][2] + 0.5)
local sp = { { SX, SY }, { SX + 2, SY - 7 }, { SX - 1, SY - 13 }, { SX + 1, 16 } }
local sm, sn, ST = G.tube(sp, function(t) return 1.75 - 0.6 * t end)
sm:cut(seeds[SPR].m)
local smtok = { r = { name = "stem" } }
X.tone(c, sm, X.light(sn, { amb = 0.12, wrap = 0.3 }), STEM, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = smtok })
-- contact shadow of the stem foot on the leaf
sm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not sm:has(x, y) and not seeds[SPR].m:has(x, y) and y > SY - 4 then c:put(x, y, LEAF[1], ltok) end end)
-- fleshy round cotyledons (pillow-lit discs on short stalks)
local cyt = { r = { name = "coty" } }
local function coty(cx, cy, ang)
  local m = G.rell(cx, cy, cos(ang), sin(ang), 4.3, 2.8)
  m:cut(sm)
  local b = {} X.ao(b, m, sm, 1, -1)
  G.toneN(c, m, X.pillow(m, 2.2), LEAF, { tok = cyt, cuts = CUTS, amb = 0.1, wrap = 0.25, bias = b })
  return m
end
local ox, oy = G.bez(sp, 0.55)
coty(ox - 5.2, oy + 0.8, 0.3) coty(ox + 5.4, oy + 0.4, -0.3)
-- true leaves: thick ellipses with a midrib and lit lip
local tlt = { r = { name = "trueleaf" } }
local function tleaf(ax, ay, cx, cy, bx, by)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, 3.3 * sin(pi * min(1, t * 0.95 + 0.03)) ^ 0.7)
  end, { fold = 0.35 })
  m:cut(sm)
  local b = {} X.ao(b, m, sm, 1, -1)
  G.toneN(c, m, n, LEAF, { tok = tlt, cuts = CUTS, amb = 0.12, wrap = 0.25, bias = b })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.13 and T[k] > 0.1 and T[k] < 0.82 then c:put(x, y, S[k] <= 0 and VEINL or LEAF[2], tlt) end end)
  return m
end
local tx, ty = G.bez(sp, 0.9)
tx, ty = floor(tx + 0.5), floor(ty + 0.5)
tleaf(tx - 1, ty, tx - 6, ty - 4, tx - 10, ty - 9)
tleaf(tx + 1, ty, tx + 6, ty - 2, tx + 11, ty - 6)
-- growing tip
for _, q in ipairs{ { 0, -1, 5 }, { 1, -1, 4 }, { 0, -2, 6 }, { 1, -2, 5 }, { 0, -3, 5 } } do c:put(tx + q[1], ty + q[2], LEAF[q[3]], tlt) end
-- areoles on the stem (woolly tuft + fine spines poking out of the silhouette), the cactus tell
for _, at in ipairs{ { 0.32, 1 }, { 0.62, -1 } } do
  local ax, ay = G.bez(sp, at[1])
  ax, ay = floor(ax + 0.5), floor(ay + 0.5)
  local e = ax
  while sm:has(e + at[2], ay) do e = e + at[2] end
  c:put(e, ay, "#f0e6cc", smtok) c:put(e, ay + 1, "#b8a890", smtok)
  for i = 1, 3 do c:put(e + at[2] * i, ay - i + 1, i < 3 and "#e8d8b0" or "#b09468", smtok) end
  c:put(e + at[2], ay + 1, "#d0bc94", smtok) c:put(e + at[2] * 2, ay + 2, "#a8906c", smtok)
end

-- seeds ---------------------------------------------------------------------------------------------------------------
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local v = X.light(s.n, { amb = 0.05, wrap = 0.15 })
  local idx = X.tone(c, s.m, v, SEED, { cuts = { 0.4, 0.6, 0.76, 0.88, 0.96 }, tok = tok })
  local r = X.rim(s.n)
  s.m:each(function(x, y) local k = K(x, y) if r[k] > 0.5 and idx[k] <= 2 then c:put(x, y, "#4a3a58", tok) end end)
  -- lens keel: a dark line along the long axis on the shade half
  local ca, sa = cos(s[5]), sin(s[5])
  s.m:each(function(x, y) local dx, dy = x - s[1], y - s[2]
    local u, w = dx * ca + dy * sa, -dx * sa + dy * ca
    if abs(w) < 0.5 and abs(u) < s[3] - 0.8 and u > -0.5 then c:put(x, y, SEED[2], tok) end end)
  local bx, by = G.specAt(s.m, s.n, 30)
  c:put(bx, by, "#fff4d6", tok) c:put(bx + 1, by, SEED[6], tok)
end

-- petal (quirk): curled, with a darker cupped base and a bright turned-up rim -----------------------------------------
do
  local tok = { r = { name = "petal" } }
  local pn = X.pillow(petal, 2.4)
  local b = {}
  petal:each(function(x, y) local dx, dy = x - px0, y - py0
    local u = dx * cos(PA) + dy * sin(PA)
    if u < -2.5 then b[K(x, y)] = -1 end end)
  G.toneN(c, petal, pn, PET, { tok = tok, cuts = { 0.3, 0.48, 0.64, 0.8, 0.92 }, amb = 0.12, wrap = 0.3, bias = b })
  -- curled rim: bright lip along the notch
  petal:edge():each(function(x, y)
    local w = -(x - px0) * sin(PA) + (y - py0) * cos(PA)
    if w < -1.5 then c:put(x, y, PET[6], tok) end end)
  -- two fine vein lines from the base
  for i = 0, 4 do c:put(floor(px0 - 3 + i * cos(PA) + 0.5), floor(py0 + i * sin(PA) + 0.5), PET[3], tok) end
end

G.save2(c, NAME)
