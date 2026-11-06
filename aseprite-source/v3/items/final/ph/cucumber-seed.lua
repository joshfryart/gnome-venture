-- cucumber-seed (final, Opus single pass). Three flat, pointed ivory cucumber seeds (raised pale rim, dished centre)
-- on a torn scrap of rough cucumber leaf (toothed lobed margin, palmate veins fanning from the stalk, ragged tear).
-- The right seed has germinated: pale hypocotyl, two blunt oblong cotyledons and a first true leaf (three pointed
-- lobes, toothed) that shows the cucumber vine.
-- quirk: a tiny coiled tendril already springs off the sprout, reaching for something to climb.
local NAME = "cucumber-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local LEAF = { "#163a34", "#20553d", "#2c7243", "#43914a", "#69b257", "#a0d273" }
local VEIN, COOL = "#c6e692", "#386a70"
local SEED = { "#6a5034", "#97794c", "#bea36e", "#dbc792", "#efe0b2", "#fdf3d2" }
local STEM = { "#4c8a56", "#86bd6e", "#bfe09a", "#e6f4c4" }
local ltok = A.tok("leaf")

-- leaf scrap: broad lobed piece, stalk at lower-left, torn across the far end
local lm, ln, LT, LS, len = A.blade(9, 52, 26, 40, 54, 44, function(t)
  if t > 0.99 then return -1 end
  local u = min(1, t * 0.92 + 0.08)
  local w = 12.5 * sin(pi * u ^ 0.9) ^ 0.55
  return max(0.6, w)
end, { fold = 0.5 })
-- palmate lobes: three broad bulges with sinuses, plus fine teeth on the margin
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local lob = 0.2 * cos(t * pi * 3.1 + (s > 0 and 0.9 or 0))
  local tooth = (X.hash(floor(t * len / 1.8), s > 0 and 1 or 2, 5) > 0.55) and 0.07 or 0
  if abs(s) > 0.9 + lob - tooth then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
A.tear(lm, 50, 60, 45, 24, 2.4, 4)
local seeds = { { 21, 45, 5.0, 2.2, -0.35 }, { 31, 49, 4.8, 2.1, 0.12 }, { 38, 39, 4.6, 2.1, -1.2 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.6) end
-- pointed tips: trim the end-row pixels that make the oval blunt
for _, s in ipairs(seeds) do
  local ca, sa = cos(s[5]), sin(s[5])
  local cutp = {}
  s.m:each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45)
    local v = (-dx * sa + dy * ca) / (s[4] + .45)
    if abs(u) > 0.62 and abs(v) > (1 - abs(u)) * 1.9 then cutp[#cutp + 1] = K(x, y) end
  end)
  for _, k in ipairs(cutp) do s.m.s[k] = nil end
end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.3, 0.45, 0.6, 0.74, 0.88 }, amb = 0.06, wrap = 0.2 })
-- palmate veins: midrib + two side veins from the base point, plus short laterals
local base = { 9, 52 }
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 and t > 0.03 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local a = atan(y - base[2], x - base[1])
  for _, va in ipairs{ -0.62, 0.05 } do
    local dd = sqrt((x - base[1])^2 + (y - base[2])^2)
    if abs(a - va) * dd < 0.55 and t > 0.08 and abs(s) < 0.82 then c:put(x, y, (a < -0.3) and VEIN or LEAF[2], ltok) return end
  end
  local ph = (t * len - abs(s) * 5) / 6.5
  if abs(ph - floor(ph + .5)) < 0.08 and abs(s) > 0.2 and abs(s) < 0.75 and t > 0.12 then c:put(x, y, s < 0 and LEAF[5] or LEAF[3], ltok) end
end)
-- rough hairs: a few pale specks
for i = 0, 40 do local x, y = 10 + floor(X.hash(i, 1, 9) * 42), 30 + floor(X.hash(i, 2, 9) * 28)
  if lm:has(x, y) and not bias[K(x, y)] and LS[K(x, y)] < -0.3 then c:put(x, y, LEAF[5], ltok) end end
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 then c:put(x, y, COOL, ltok) end end)
-- petiole stub
for _, q in ipairs{ { 8, 53, 4 }, { 7, 54, 3 }, { 6, 55, 3 }, { 5, 56, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout from seed 3: hypocotyl hook up to the cotyledons
local stok = A.tok("stem")
local sp = { { 39, 37 }, { 37, 33 }, { 39, 30 }, { 38, 27 } }
local sm, sn = A.tube(sp, function(t) return 1.0 end)
sm:cut(seeds[3].m)
A.shade(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function coty(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    return max(0.5, w * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.35)
  end, { fold = 0.25 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.15, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.15 and T[k] > 0.15 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
local cl = coty(37, 27, 32, 26, 26, 28, 2.6)
local cr = coty(39, 27, 44, 26, 50, 29, 2.6)
-- first true leaf: three pointed lobes on a short petiole, toothed
local pet = { { 38, 27 }, { 38, 24 }, { 37, 21 }, { 37, 19 } }
local tl = HP.mask()
local lobes = { { 37, 13.5, 0, -1, 4.4, 2.6 }, { 33.3, 16.6, -0.85, -0.55, 3.6, 2.2 }, { 40.8, 16.4, 0.85, -0.5, 3.6, 2.2 } }
for _, L in ipairs(lobes) do
  local m = HP.mask()
  for i = 0, 10 do local f = i / 10 local r = L[6] * (1 - f) ^ 0.7 + 0.35
    m:add(A.rell(L[1] + L[3] * (f * L[5] - 1.2), L[2] + L[4] * (f * L[5] - 1.2), L[3], L[4], r + 0.6, r)) end
  tl:add(m)
end
tl:add(A.rell(37, 18, 1, 0, 3.4, 2.4))
tl:cut(cl):cut(cr):cut(sm)
local tn = X.pillow(tl, 2)
A.toneN(c, tl, tn, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.25 })
-- veins into the three lobes
for _, v in ipairs{ { { 37, 19 }, { 37, 11 } }, { { 37, 19 }, { 33, 15 } }, { { 37, 19 }, { 41, 15 } } } do
  HP.line(v, 1):each(function(x, y) if tl:has(x, y) and tl:grow(0):has(x, y) then c:put(x, y, (x <= 37) and LEAF[6] or LEAF[4], ltok) end end)
end
for i = 0, 20 do local x, y = A.bez(pet, i / 20) c:put(floor(x + .5), floor(y + .5), STEM[3], stok) end

-- quirk: a coiled tendril springing off the stem to the right
local tdl = { { 39, 32 }, { 41, 32 }, { 43, 31 }, { 44, 30 }, { 45, 29 }, { 46, 28 }, { 47, 27 }, { 48, 28 }, { 48, 29 }, { 47, 30 }, { 46, 29 } }
for i, q in ipairs(tdl) do if not sm:has(q[1], q[2]) and not cr:has(q[1], q[2]) then c:put(q[1], q[2], i < 6 and STEM[2] or STEM[3], stok) end end

-- seeds: dished centre, raised pale rim, pointed tips
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  vis:cut(sm)
  local tok = A.tok("seed" .. i)
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  local idx = A.toneN(c, vis, s.n, SEED, { tok = tok, cuts = { 0.16, 0.32, 0.5, 0.7, 0.86 }, amb = 0.2, wrap = 0.35, bias = sb })
  local inner = s.m:shrink(1)
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45)
    local v = flip * (-dx * sa + dy * ca) / (s[4] + .45)
    local i2 = idx[k] or 4
    if inner:has(x, y) then
      -- dish: centre one step darker on the lit half, lighter on the shade half (concave)
      if abs(u) < 0.6 and abs(v) < 0.4 then i2 = (v < 0) and i2 - 1 or i2 + 1 end
      if abs(u) < 0.55 and abs(v) < 0.12 then i2 = 3 end -- faint seam
    else
      if v < 0 then i2 = 6 elseif u < -0.3 then i2 = 5 end
    end
    if sb[k] then i2 = i2 - 1 end
    c:put(x, y, SEED[max(1, min(6, i2))], tok)
  end)
end
-- glint on the front seed
c:put(29, 48, A.CREAM, A.tok("seed2"))
A.save(c, NAME)
