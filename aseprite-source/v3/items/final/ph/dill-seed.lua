-- dill-seed (final, Opus single pass). Four flat dill seeds (dark ribbed brown body inside a pale tan wing rim)
-- on a torn scrap of glaucous blue-green leaf (midrib, swept veins, V-fold light, pale torn fibres along the rip,
-- AO + contact shadow under each seed). The right seed has germinated: pale stem, two long strap cotyledons and the
-- first true leaf, thread-fine and forked like a dill frond.
-- quirk: the seedling is already showing off a tiny yellow umbel on top.
local NAME = "dill-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi
local c = A.new(NAME)

local LEAF = { "#183c3a", "#22564a", "#2f7252", "#46905a", "#6cae68", "#a0cc84" }
local TORN, VEIN = "#cfe4a4", "#bfe0a0"
local SEED = { "#3a2620", "#5a3a26", "#7e5530", "#a47640", "#c89e62", "#ecd29c" }
local STEM = { "#4c8650", "#7cb468", "#b2d88e", "#e0f0b8" }
local FR   = { "#2c6a40", "#4a9450", "#78bc5e", "#a8d878" }
local YEL  = { "#b07818", "#e8b42a", "#ffe06a" }

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 17, 51, 4.3, 2.5, -0.35 }, { 27, 50, 4.4, 2.6, 0.25 }, { 23, 44, 4.0, 2.4, -0.15 }, { 38, 45, 4.2, 2.5, -1.35 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.6) end

-- leaf scrap, torn off across the far end and nibbled on the top edge
local lm, ln, LT, LS, len = A.blade(8, 54, 30, 51, 55, 41, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 9.5 * sin(pi * min(1, t * 0.9 + 0.06)) ^ 0.6)
end, { fold = 0.4 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local jag = (X.hash(floor(s * 6), 3, 11) - 0.5) * 0.07 + s * 0.05
  if t > 0.8 + jag then cut[#cut + 1] = k end
  if s < -0.55 and abs(t - 0.62) < 0.05 - (abs(s) - 0.55) * 0.05 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 and t > 0.03 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 5) / 6 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.18 and abs(s) < 0.75 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
-- torn fibres: pale pixels along the rip (edge pixels near the cut end)
lm:edge():each(function(x, y) local k = K(x, y)
  if LT[k] > 0.72 and abs(LS[k]) < 0.85 and not bias[k] then c:put(x, y, TORN, ltok) end
  if not bias[k] and LS[k] > 0.7 and LT[k] < 0.7 and LT[k] > 0.1 then c:put(x, y, "#3a6c72", ltok) end
end)
-- petiole stub
for _, q in ipairs{ { 7, 55, 4 }, { 6, 56, 3 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout stem (before the seed so the coat overlaps its foot)
local stok = { r = { name = "stem" } }
local sp = { { 38, 43 }, { 37, 36 }, { 39, 30 }, { 38, 23 } }
local stm, stn = A.tube(sp, function() return 1.05 end)
stm:cut(seeds[4].m)
X.tone(c, stm, X.light(stn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- cotyledons: long narrow straps
local function coty(ax, ay, cx, cy, bx, by)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, 1.5 * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.4)
  end, { fold = 0.3 })
  m:cut(stm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.85 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
coty(37, 24, 30, 22, 23, 17)
coty(39, 24, 46, 22, 53, 18)
-- first true leaf: thread-fine forked segments off a slim petiole
local ftok = { r = { name = "frond" } }
local function seg(x, y, dx, dy, n, col)
  for i = 1, n do c:put(x + dx * i, y + dy * i, col, ftok) end
  return x + dx * n, y + dy * n
end
for y = 13, 23 do c:put(y > 18 and 38 or 39, y, y > 18 and STEM[3] or FR[3], ftok) end
for _, b in ipairs{ { 38, 20, -1, 3 }, { 38, 20, 1, 3 }, { 39, 16, -1, 3 }, { 39, 16, 1, 3 } } do
  local ex, ey = seg(b[1], b[2], b[3], -1, b[4], FR[2])
  seg(ex, ey, 0, -1, 2, FR[3])
  seg(ex, ey, b[3], 0, 2, FR[4])
end
-- quirk: tiny umbel on top (spokes + yellow florets)
A.dots(c, { { 38, 12 }, { 40, 12 }, { 37, 11 }, { 41, 11 }, { 39, 11 } }, FR[2], ftok)
A.dots(c, { { 36, 10 }, { 39, 9 }, { 42, 10 } }, YEL[2], ftok)
A.dots(c, { { 37, 10 }, { 38, 9 }, { 40, 9 }, { 41, 10 } }, YEL[3], ftok)
A.dots(c, { { 36, 11 }, { 42, 11 } }, YEL[1], ftok)

-- seeds last: winged rim, dark ribbed body, AO between neighbours, one glint
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), flip * (-dx * sa + dy * ca) / (s[4] + .45)
    local r = u * u + v * v
    local ii
    if r > 0.62 then ii = (v < 0 or u < -0.6) and 6 or 4         -- pale wing
      if v > 0.5 then ii = 3 end
    else
      ii = (v < 0) and 3 or 2
      if abs(abs(v) - 0.32) < 0.14 then ii = ii + 1 end           -- ribs
      if abs(v) < 0.1 then ii = 4 end
    end
    if sb[k] then ii = ii - 1 end
    c:put(x, y, SEED[max(1, min(6, ii))], tok)
  end)
end
c:put(25, 49, A.CREAM, { r = { name = "seed2" } })

A.save(c, NAME)
