-- chayote-seed (final, Opus single pass). One big flat ovate chayote seed (ivory, bevelled lens with a raised rim, fine
-- lengthwise grain, a split lip at the broad end) lies on a torn scrap of chayote leaf (palmate veins fanning from the
-- leaf base, jagged torn end, cool reflected edge, AO + contact shadow under the seed). The seed is germinating as the
-- real thing does, from its broad end: a pale stem rising to a first cucurbit leaf (three shallow palmate lobes, heart
-- sinus, veins from the petiole), a coiling tendril, and a short white root over the scrap.
-- quirk: a single dewdrop sits on the sprout leaf.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB1r1_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local NAME = "chayote-seed"
local c = A.new(NAME)

local LEAF = { "#1d4434", "#2a6040", "#3c7d46", "#58994e", "#80b85c", "#b2d67c" }
local SEED = { "#6c5646", "#987e62", "#c2a984", "#dcc79e", "#efe0bc", "#fbf3dc" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local SPR  = { "#1f4a36", "#2f6a42", "#46894a", "#67a852", "#93c868", "#c2e28c" }

-- seed: flat ovate lens (broad end upper-right)
local SCX, SCY, ANG = 24, 46, -0.32
local ca, sa = cos(ANG), sin(ANG)
local seed = HP.mask()
for y = SCY - 10, SCY + 10 do for x = SCX - 12, SCX + 12 do
  local dx, dy = x - SCX, y - SCY
  local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
  local ry = 5.0 + 1.0 * (u / 9)                         -- ovate: wider toward +u (broad end)
  if (u / 9.2) ^ 2 + (v / ry) ^ 2 <= 1 then seed:set(x, y) end
end end

-- sprout parts (masks first, for AO)
local stemPts = { { 32, 43 }, { 35, 35 }, { 33, 28 }, { 35, 23 } }
local sm, sn = A.tube(stemPts, function(t) return 1.25 - 0.25 * t end)
local LX, LY = 35, 22                                       -- petiole point of the sprout leaf
local sl = HP.mask()
for _, lb in ipairs{ { 0, 7.6, 4.6 }, { -1.05, 5.6, 3.6 }, { 1.05, 5.6, 3.6 } } do
  local a = -pi / 2 + lb[1]
  local ux, uy = cos(a), sin(a)
  sl:add(A.rell(LX + ux * lb[2] * 0.95, LY + uy * lb[2] * 0.95, ux, uy, lb[2], lb[3]))
end
-- heart sinus at the petiole
sl:cut(A.rell(LX, LY + 1.6, 0, 1, 2.2, 1.6))
local root = A.tube({ { 17, 49 }, { 15, 51 }, { 12, 52 }, { 9, 51 } }, function(t) return 0.9 - 0.5 * t end)

-- leaf scrap: V-folded blade on a gentle S curve, midrib + veins, jagged torn right end, lobed lit margin
local bias = {}
local ltok = { r = { name = "leaf" } }
local LT, LS, len
local lm = A.leaf(c, 5, 53, 27, 51, 57, 42, 8.0, LEAF, { fold = 0.55, vs = 3.4, bias = bias, tok = ltok, pw = 0.6,
  pre = function(m, T, S, L)
    LT, LS, len = T, S, L
    local cut = {}
    m:each(function(x, y) local k = K(x, y)
      local jag = 3 + 3.5 * X.hash(floor(y / 2), 3, 11) + ((y % 3 == 0) and 1.2 or 0)
      if T[k] * L > L - jag then cut[#cut + 1] = k end
      if S[k] < -0.74 and ((T[k] * L) % 8) < 2.0 and T[k] > 0.15 and T[k] < 0.8 then cut[#cut + 1] = k end
    end)
    for _, k in ipairs(cut) do m.s[k] = nil end
    X.ao(bias, m, seed, 1, -1) A.cast(bias, m, seed, 1, 2, -1) A.cast(bias, m, root, 1, 1, -1)
  end })
lm:edge():each(function(x, y) local k = K(x, y) if not bias[k] and LS[k] > 0.7 then c:put(x, y, "#3c6e74", ltok) end end)
lm:each(function(x, y) local k = K(x, y) if LT[k] * len > len - 9 and not lm:has(x + 1, y) and not bias[k] then c:put(x, y, "#cfe6a0", ltok) end end)

-- root (white, over the scrap)
local rtok = { r = { name = "root" } }
A.shade(c, root, select(2, A.tube({ { 17, 49 }, { 15, 51 }, { 12, 52 }, { 9, 51 } }, function(t) return 0.9 - 0.5 * t end)), { "#a89c86", "#d8ccb0", "#f0e6cc", "#fbf5e4" }, { cuts = { 0.3, 0.55, 0.8 }, tok = rtok })

-- stem, then tendril, then leaf
local stok = { r = { name = "stem" } }
sm:cut(seed)
A.shade(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3, tok = stok })
-- tendril: thin coil off the stem
local tp = {}
for i = 0, 34 do local t = i / 34
  local x, y
  if t < 0.35 then local u = t / 0.35 x, y = 34 + u * 6, 30 - u * 2.5 + u * u * 1.2
  else local u = (t - 0.35) / 0.65 local a = -pi / 2 + u * 2.3 * pi local r = 3.2 * (1 - u * 0.62)
    x, y = 41.5 + r * cos(a) + 0.5, 31.5 + r * sin(a) end
  tp[#tp + 1] = { floor(x + .5), floor(y + .5), t }
end
for i, p in ipairs(tp) do if not sm:has(p[1], p[2]) then c:put(p[1], p[2], (p[3] < 0.5) and STEM[3] or STEM[2], stok) end end
-- sprout leaf
local sb = {}
A.cast(sb, sl, sm, 0, 0, 0)
local sltok = { r = { name = "sprout" } }
local sn2 = X.pillow(sl, 2.6)
local sidx = A.toneN(c, sl, sn2, SPR, { tok = sltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.14, wrap = 0.28 })
sl:each(function(x, y) local dx, dy = x - LX, y - LY
  local d = sqrt(dx * dx + dy * dy) if d < 1.5 then return end
  local a = atan(dy, dx)
  for _, va in ipairs{ -pi / 2, -pi / 2 - 1.05, -pi / 2 + 1.05 } do
    if abs((a - va) * d) < 0.5 and d < 8.5 then c:put(x, y, (va <= -pi / 2) and SPR[6] or SPR[max(2, (sidx[K(x, y)] or 4) - 1)], sltok) return end
  end
end)
-- tiny serration notches at the lobe tips (cucurbit margin)
sl:edge():each(function(x, y) if X.hash(x, y, 5) > 0.82 then c:put(x, y, SPR[2], sltok) end end)

-- seed last
local sdb = {}
X.ao(sdb, seed, sm, 1, -1)
local stk = { r = { name = "seed" } }
local snn = X.pillow(seed, 2.4)
local sidx2 = A.toneN(c, seed, snn, SEED, { bias = sdb, tok = stk, cuts = { 0.16, 0.32, 0.5, 0.66, 0.82 }, amb = 0.12, wrap = 0.3 })
-- raised rim + lengthwise grain on the flat face
seed:each(function(x, y) local k = K(x, y)
  local dx, dy = x - SCX, y - SCY
  local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
  local inner = (u / 7.6) ^ 2 + (v / (3.6 + 0.8 * u / 9)) ^ 2
  if inner > 0.82 and inner < 1.08 then A.step(c, sidx2, SEED, x, y, (v < 0 or u < -5) and -1 or -1, stk)
  elseif inner < 0.82 and abs(v - 1.4) < 0.45 and u > -5 and u < 4 then A.step(c, sidx2, SEED, x, y, -1, stk) end
end)
-- split lip at the broad end where the stem leaves
for _, q in ipairs{ { 32, 42, 1 }, { 33, 42, 2 }, { 31, 43, 2 } } do if seed:has(q[1], q[2]) then c:put(q[1], q[2], SEED[q[3]], stk) end end
c:put(19, 44, "#fffdf0", stk) c:put(20, 44, "#fffdf0", stk) c:put(21, 44, SEED[6], stk)   -- satin glint

-- quirk: dewdrop on the sprout leaf
for _, q in ipairs{ { 32, 14, "#3f8a8c" }, { 33, 14, "#8fd0c8" }, { 31, 15, "#5aa8a8" }, { 32, 15, "#d8f6ec" }, { 33, 15, "#9fdcd0" },
  { 31, 16, "#4a9898" }, { 32, 16, "#7cc4c0" }, { 33, 16, "#c6eee2" }, { 32, 17, SPR[1] }, { 33, 17, SPR[2] } } do c:put(q[1], q[2], q[3], sltok) end
c:put(32, 14, "#fff4d6", sltok)
A.save(c, NAME)
