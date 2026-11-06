-- radish-seed (final, Sonnet high). Round russet radish seeds (6-tone, a faint furrow, wet contact shadow) on a torn radish leaf
-- scrap (midrib, swept veins, pale fibre on the tear, cool bounce). One seed has germinated: split coat, hot-pink hypocotyl,
-- two heart-notched cotyledons and the first rough, scalloped true leaf above them.
-- quirk: the sprouting seed has already put out a white root with root hairs that crawls over the leaf scrap.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_1.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("radish-seed")
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local FRESH = { "#1d4a3a", "#2a6a44", "#3f8f4e", "#62b85a", "#8fd870", "#c4f08a" }
local SEED = { "#3a1c1e", "#5e2a24", "#8a3d2a", "#b25a34", "#d8854a", "#f4b878" }
local PK = { "#7c1d4c", "#b2325f", "#e2567f", "#ff96b2" }
local WHT = { "#8f8cb4", "#c4c0dc", "#ece8f4", "#fffaf0" }

-- ===== torn leaf scrap along a gentle quadratic
local AX, AY, CXc, CYc, BX, BY = 6, 51, 28, 54, 58, 46
local sm = A.tornBlade(c, AX, AY, CXc, CYc, BX, BY, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.97 + 0.03)
  return max(0.5, 8.4 * sin(pi * u ^ 0.85) ^ 0.7 * (0.86 + 0.14 * cos(t * pi * 4)))
end, { ramp = LEAF, cool = "#3a6c72", fibre = "#c2e48c", ribHi = "#c2e48c",
  tear = { [-1] = { depth = 0.32, t0 = 0.12, t1 = 0.55 }, [1] = { depth = 0.3, t0 = 0.45, t1 = 0.92 } },
  veins = { 6, 10, 14, 18, 22, 26, 30, 34, 38, 42, 46, 50 }, sweep = 2.4, fold = 0.4, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 } })
local function mid(t) local u = 1 - t return u * u * AX + 2 * u * t * CXc + t * t * BX, u * u * AY + 2 * u * t * CYc + t * t * BY end

-- ===== seeds
local function seed(cx, cy, r, tint)
  local m = c:ellipse(cx, cy, r, r)
  -- contact shadow on the scrap, below-right
  m:shift(1, 1):cut(m):each(function(x, y) if sm:has(x, y) then c:put(x, y, LEAF[1]) end end)
  m:shift(2, 1):cut(m):each(function(x, y) if sm:has(x, y) and X.hash(x, y, 4) < 0.55 then c:put(x, y, LEAF[1]) end end)
  local n = X.sphere(cx - 0.4, cy - 0.5, r, m)
  A.shade(c, m, n, SEED, { amb = 0.08, wrap = 0.2, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = { r = { name = "seed" } } })
  -- furrow down the shade side + a pale rim glint
  c:put(floor(cx + 1), floor(cy - 1), SEED[2]) c:put(floor(cx + 1), floor(cy), SEED[2]) c:put(floor(cx), floor(cy + 1), SEED[2])
  c:put(floor(cx - 1), floor(cy - 2), SEED[6]) c:put(floor(cx - 2), floor(cy - 1), SEED[6])
  return m
end
local seeds = {}
for _, q in ipairs{ { 0.15, 1.0 }, { 0.3, -1.4 }, { 0.44, 1.8 }, { 0.8, -1.0 }, { 0.93, 0.6 } } do
  local x, y = mid(q[1]) seeds[#seeds + 1] = seed(floor(x + .5), floor(y + q[2] + .5), 2.6)
end

-- ===== germinated seed + root (under the stem)
local gx, gy = mid(0.6) gx, gy = floor(gx + .5), floor(gy + 0.5)
-- root crawling down-left over the scrap
local rm, rn, RT = G.tube({ { gx - 1, gy + 2 }, { gx - 4, gy + 5 }, { gx - 8, gy + 4 }, { gx - 11, gy + 6 } }, function(t) return 1.2 - 0.55 * t end)
X.tone(c, rm, X.light(rn, { amb = 0.12, wrap = 0.3 }), WHT, { cuts = { 0.3, 0.55, 0.8 }, tok = { r = { name = "root" } } })
rm:shift(1, 1):cut(rm):each(function(x, y) if sm:has(x, y) then c:put(x, y, LEAF[1]) end end)
for _, q in ipairs{ { gx - 5, gy + 6 }, { gx - 7, gy + 3 }, { gx - 9, gy + 6 }, { gx - 6, gy + 3 } } do if sm:has(q[1], q[2]) and not rm:has(q[1], q[2]) then c:put(q[1], q[2], WHT[2]) end end

-- ===== stem
local SX, SY = gx, gy - 2
local stp = { { SX, SY }, { SX - 1, SY - 7 }, { SX + 1, SY - 14 }, { SX, SY - 20 } }
local stm, stn = G.tube(stp, function(t) return 1.2 - 0.15 * t end)
X.tone(c, stm, X.light(stn, { amb = 0.12, wrap = 0.3 }), PK, { cuts = { 0.3, 0.55, 0.8 }, tok = { r = { name = "stem" } } })

-- ===== first true leaf: rough scalloped blade on a short petiole
local tl, tn, TT, TS, tlen = G.blade(SX, SY - 19, SX - 4, SY - 28, SX + 1, SY - 38, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 5.0 * sin(pi * min(1, t * 0.95 + 0.07)) ^ 0.75)
end, { fold = 0.45 })
local cut = {}
tl:each(function(x, y) local k = K(x, y) local t, s = TT[k], TS[k]
  local ph = t * tlen / 4.4 + (s > 0 and 0.5 or 0) + 0.3
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if t > 0.1 and t < 0.96 and abs(s) > 0.97 - (1 - f) ^ 2.2 * 0.5 then cut[#cut + 1] = k end end)
for _, k in ipairs(cut) do tl.s[k] = nil end
local ltok = { r = { name = "truleaf" } }
G.toneN(c, tl, tn, FRESH, { tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
tl:each(function(x, y) local k = K(x, y) local s, t = TS[k], TT[k]
  if abs(s) < 0.16 and t > 0.04 and t < 0.92 then c:put(x, y, s <= 0 and FRESH[6] or FRESH[3], ltok) return end
  local d = (t * tlen - 2.2 * abs(s)) % 3.4
  if d < 0.9 and abs(s) > 0.22 and abs(s) < 0.72 and t > 0.1 and t < 0.88 then c:put(x, y, s < 0 and FRESH[5] or FRESH[2], ltok) end end)
tl:edge():each(function(x, y) if TS[K(x, y)] > 0.66 and TT[K(x, y)] > 0.14 and TT[K(x, y)] < 0.86 then c:put(x, y, "#3c7a74", ltok) end end)
-- bristle hairs on the true leaf
for _, q in ipairs{ { SX - 6, SY - 26 }, { SX + 5, SY - 30 }, { SX + 6, SY - 24 } } do if not tl:has(q[1], q[2]) and tl:has(q[1] + 1, q[2]) or tl:has(q[1] - 1, q[2]) then c:put(q[1], q[2], FRESH[6]) end end

-- ===== heart-notched cotyledons
local function heart(bx, by, ang, L, r)
  local ux, uy = cos(ang), sin(ang)
  local px, py = -uy, ux
  local m = HP.mask()
  local lc = L - r
  for _, s in ipairs{ -1, 1 } do
    local cx, cy = bx + ux * lc + px * s * r * 0.78, by + uy * lc + py * s * r * 0.78
    m:add(c:ellipse(cx, cy, r, r))
  end
  m:add(c:poly{ { bx + 0.5, by + 0.5 }, { bx + ux * lc + px * r * 1.4 + 0.5, by + uy * lc + py * r * 1.4 + 0.5 }, { bx + ux * lc - px * r * 1.4 + 0.5, by + uy * lc - py * r * 1.4 + 0.5 } })
  return m, ux, uy, px, py, lc
end
local CY0 = SY - 9
local cl = heart(SX - 1, CY0, -2.75, 13, 4.1)
local cr = heart(SX + 1, CY0, -0.4, 13, 4.1)
cl:cut(stm) cr:cut(stm)
cl:cut(tl) cr:cut(tl)
local ctok = { r = { name = "cotyledon" } }
local function paintHeart(m, bx, by, ang)
  local ux, uy = cos(ang), sin(ang)
  local n = X.pillow(m, 2.0)
  local bias = {}
  X.ao(bias, m, stm, 1, -1)
  local idx = A.shade(c, m, n, FRESH, { bias = bias, tok = ctok, amb = 0.14, wrap = 0.3 })
  -- midrib along the axis, notch shadow at the tip
  m:each(function(x, y)
    local dx, dy = x - bx, y - by
    local a = dx * ux + dy * uy
    local b = -dx * uy + dy * ux
    if abs(b) < 0.55 and a > 1 and a < 8.5 then c:put(x, y, b <= 0 and FRESH[6] or FRESH[3], ctok) end
    if abs(b) < 0.9 and a >= 8.5 then c:put(x, y, FRESH[1], ctok) end
  end)
  m:edge():each(function(x, y) if x > bx + (ux * 2) and y > by - 2 and not m:has(x + 1, y + 1) and X.hash(x, y, 8) < 0.6 then c:put(x, y, "#3c7a74", ctok) end end)
end
paintHeart(cl, SX - 1, CY0, -2.75) paintHeart(cr, SX + 1, CY0, -0.4)
-- stem knot shadow where the cotyledons join
for _, q in ipairs{ { SX - 1, CY0 }, { SX, CY0 }, { SX + 1, CY0 } } do if stm:has(q[1], q[2]) then c:put(q[1], q[2], PK[1]) end end
-- dew drop on the right cotyledon
do local dx, dy = SX + 7, CY0 - 5
  c:put(dx, dy, "#fffaf0") c:put(dx + 1, dy, "#cfeef0") c:put(dx, dy + 1, "#8fd0d8") c:put(dx + 1, dy + 1, "#4f9cae")
  if cr:has(dx, dy) and cr:has(dx + 1, dy + 1) then else c:put(dx, dy, "#cfeef0") end end

-- ===== germinated seed on top: split coat with the pale embryo showing
local gm = c:ellipse(gx, gy, 3.0, 2.8)
gm:shift(1, 1):cut(gm):each(function(x, y) if sm:has(x, y) then c:put(x, y, LEAF[1]) end end)
A.shade(c, gm, X.sphere(gx - 0.4, gy - 0.5, 2.9, gm), SEED, { amb = 0.08, wrap = 0.2, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = { r = { name = "gseed" } } })
for _, q in ipairs{ { gx - 1, gy - 1 }, { gx, gy - 1 }, { gx, gy }, { gx + 1, gy } } do c:put(q[1], q[2], q[2] == gy - 1 and "#fff4d6" or "#ffe0b0") end
c:put(gx - 1, gy, SEED[2]) c:put(gx + 1, gy + 1, SEED[2]) c:put(gx - 2, gy - 1, SEED[6])

A.save(c, "radish-seed")
