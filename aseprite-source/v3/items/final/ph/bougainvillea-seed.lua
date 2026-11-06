-- bougainvillea-seed (final, Opus aB10). Three slim five-ribbed bougainvillea anthocarps (tan, club-shaped, dark rib
-- grooves) lying on a torn scrap of an ovate bougainvillea leaf (V-fold light, midrib + arching pinnate veins, pale
-- torn edge with ragged tissue, cool reflected edge, AO and contact shadow under each seed). The right seed has
-- sprouted: a slim woody stem with one hooked thorn and two ovate leaves with drawn-out tips and midribs.
-- quirk: impatient seedling, already showing off one hot-magenta papery bract with a cream floret.
local NAME = "bougainvillea-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#17402f", "#22603f", "#307c44", "#4b9a46", "#76bb50", "#ade072" }
local VEIN, COOL, TORN = "#cfeaa0", "#3a6c72", "#d8eeb0"
local SEED = { "#3a1f1c", "#5a3424", "#7e4e2e", "#a26c3c", "#c8925a", "#ecc48a" }
local STEM = { "#4a3a2a", "#6e5a36", "#93824a", "#b8ac6e" }
local BRACT = { "#5a1440", "#8e1c5e", "#c42a7e", "#e8489c", "#ff78bc", "#ffb4da" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local ltok = { r = { name = "leaf" } }

-- seeds: cx, cy, rx, ry, angle (club-shaped: wider toward +u)
local seeds = { { 17, 47, 5.2, 1.9, -0.25 }, { 28, 46, 5.0, 1.9, 0.35 }, { 39, 42, 4.8, 1.9, -0.55 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end

-- leaf scrap: ovate, acuminate tip, base torn off
local lm, ln, LT, LS, len = A.blade(6, 52, 30, 52, 57, 37, function(t)
  if t > 0.99 then return -1 end
  local w = 9.8 * sin(pi * min(1, t * 0.82 + 0.18)) ^ 0.8
  if t > 0.8 then w = w * (1 - (t - 0.8) / 0.2 * 0.55) end
  return max(0.4, w)
end, { fold = 0.38 })
local torn = HP.mask()
lm:each(function(x, y) local k = K(x, y)
  local lim = 0.1 + 0.07 * X.hash(floor(LS[k] * 6), 3, 17) + 0.03 * abs(LS[k])
  if LT[k] < lim then lm.s[k] = nil elseif LT[k] < lim + 0.035 then torn:set(x, y) end
end)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
-- veins: midrib + arching laterals swept toward the tip
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) ^ 0.8 * 7.5) / 6.2 + (s > 0 and 0.45 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.15 and abs(s) < 0.78 and t > 0.12 and t < 0.86 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
-- torn edge: pale exposed tissue, a few ragged fibres
torn:each(function(x, y) if lm:has(x, y) then c:put(x, y, (X.hash(x, y, 4) > 0.4) and TORN or LEAF[5], ltok) end end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.2 and LT[k] < 0.85 then c:put(x, y, COOL, ltok) end end)

-- sprout: stem from the right seed's top end
local stok = { r = { name = "stem" } }
local sp = { { 42, 39 }, { 41, 32 }, { 37, 28 }, { 36, 20 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return 1.25 - 0.35 * t end)
sm:cut(seeds[3].m)
local function leaf(ax, ay, cx, cy, bx, by, wmax)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    local w = wmax * sin(pi * min(1, t * 0.85 + 0.12)) ^ 0.7
    if t > 0.7 then w = w * (1 - (t - 0.7) / 0.3 * 0.6) end
    return max(0.35, w)
  end, { fold = 0.35 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.16 and T[k] > 0.08 and T[k] < 0.85 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
local la = leaf(39, 30, 32, 24, 23, 26, 3.4)
local lb = leaf(38, 27, 44, 21, 52, 23, 3.2)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- hooked thorn on the stem (left side, pointing down-left)
c:put(38, 31, STEM[2], stok) c:put(37, 32, STEM[1], stok)
-- leaf-stalk joins: dark node pixels
c:put(39, 29, STEM[1], stok) c:put(38, 27, STEM[1], stok)

-- quirk: one magenta papery bract (three lobes, net-veined) with a cream tubular floret at the stem tip
local btok = { r = { name = "bract" } }
local bm = A.rell(32.5, 17.5, 0.8, -0.6, 3.4, 2.3):add(A.rell(38.5, 16.5, 0.75, 0.66, 3.3, 2.2)):add(A.rell(35.5, 13.5, 0, 1, 3.4, 2.3))
local bidx = A.toneN(c, bm, X.pillow(bm, 2), BRACT, { tok = btok, cuts = CUTS, amb = 0.12, wrap = 0.3 })
-- bract veins: dark lines from the centre toward each lobe tip
for _, v in ipairs{ { 34, 17 }, { 33, 18 }, { 37, 17 }, { 38, 17 }, { 35, 15 }, { 35, 14 } } do
  if bm:has(v[1], v[2]) then c:put(v[1], v[2], BRACT[max(1, (bidx[K(v[1], v[2])] or 3) - 2)], btok) end end
-- floret: cream tube with a tiny star mouth
c:put(36, 18, "#e8d8a8", btok) c:put(36, 17, "#fff4d6", btok) c:put(36, 16, "#fff4d6", btok) c:put(37, 16, "#ffe38a", btok)
c:put(36, 19, STEM[2], stok)

-- seeds last: five-ribbed, club-shaped, AO between neighbours
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  if i == 3 then vis:add(HP.mask()) end
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  local v = X.light(s.n, { amb = 0.1, wrap = 0.25 })
  local idx = X.tone(c, vis, v, SEED, { cuts = CUTS, tok = tok })
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, w = (dx * ca + dy * sa) / (s[3] + .45), flip * (-dx * sa + dy * ca) / (s[4] + .45)
    local i2 = idx[k]
    if abs(w + 0.05) < 0.22 and abs(u) < 0.8 then i2 = i2 - 2 end          -- central rib groove
    if abs(u) > 0.84 then i2 = i2 - 1 end                                    -- rounded ends
    if w < -0.3 and w > -0.75 and u > -0.5 and u < 0.3 then i2 = max(i2, 5) end  -- lit rib
    c:put(x, y, SEED[max(1, min(6, i2))], tok)
  end)
  local gx, gy = A.specAt(vis, s.n, 30)
  if gx then c:put(gx, gy, SEED[6], tok) end
end

A.save(c, NAME)
