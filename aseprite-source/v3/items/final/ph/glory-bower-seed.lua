-- glory-bower-seed (final, Opus single pass). The glory bower fruit: a glossy steel-blue drupe (sphere light, cream
-- specular, window reflection, cool bounce) seated in a five-point crimson star calyx (pillow-lit points, dark creases,
-- AO under the berry) on a broad ovate clerodendrum leaf scrap torn at the base (pinnate net veins, cool shade edge,
-- contact shadows). Two wrinkled tan seeds lie loose; the left one sprouts a stem with an opposite pair of ovate leaves.
-- quirk: a single dew drop on the leaf has caught a tiny blue reflection of the berry.
local NAME = "glory-bower-seed"
local B = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_3.lua")
local HP, X, K = B.HP, B.X, B.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = B.new(NAME)
local LEAF = { "#1a3c34", "#24563e", "#327246", "#4a8f4a", "#6cad52", "#9ccc68" }
local VEIN, COOL = "#b8dc84", "#3a6a74"
local CAL = { "#4e1430", "#7e1f3a", "#b42c3e", "#dc4446", "#f4705a", "#ffaa86" }
local BER = { "#141a3e", "#1e2c66", "#2a4596", "#3a68c0", "#64a0dc", "#b4e2f4" }
local SEED = { "#4a2c26", "#6e4632", "#93663e", "#b88a52", "#d8b078", "#f0d6a0" }
local STEM = { "#2e6a42", "#4a8c4c", "#7cb462", "#b4da8a" }
local ltok, ctok, btok, stok = { r = { name = "leaf" } }, { r = { name = "calyx" } }, { r = { name = "berry" } }, { r = { name = "stem" } }

-- loose seeds (small wrinkled ovals)
local seeds = { { 16, 44, 3.2, 2.2, -0.3 }, { 49, 40, 3.0, 2.1, 0.5 } }
for _, s in ipairs(seeds) do s.m, s.n = B.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end
-- calyx star + berry
local CX, CY = 33, 38
local star, sn = HP.mask(), nil
for y = CY - 12, CY + 12 do for x = CX - 12, CX + 12 do
  local dx, dy = x - CX, (y - CY) * 1.18
  local a = atan(dy, dx) + pi / 2 + 0.1
  local f = abs(((a / (2 * pi / 5)) % 1) - 0.5) * 2     -- 1 at a point, 0 between points
  local r = 3.6 + 6.4 * f ^ 1.6
  if sqrt(dx * dx + dy * dy) <= r then star:set(x, y) end
end end
local berry = c:ellipse(CX, CY - 1, 5, 5)
local bn = X.sphere(CX, CY - 1, 5, berry)

-- leaf scrap: broad ovate, torn at the base
local lm, ln, LT, LS, len = B.blade(7, 49, 30, 49, 57, 38, function(t)
  if t > 0.99 then return -1 end
  return max(0.4, 9.6 * sin(pi * min(1, t * 0.8 + 0.2)) ^ 0.75)
end, { fold = 0.3 })
B.tear(lm, 11, 48, -0.95, -0.3, 1.8, 9)
local bias = {}
for _, m in ipairs{ star, seeds[1].m, seeds[2].m } do X.ao(bias, lm, m, 1, -1) B.cast(bias, lm, m, 1, 2, -1) end
B.cast(bias, lm, star, 2, 3, -1)
B.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
-- pinnate net veins: midrib + arching laterals, alternating sides
local PER = 7
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) ^ 0.8 * 6.0) / PER + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.12 and abs(s) < 0.78 and t > 0.08 and t < 0.88 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] and LS[k] > 0.6 and LT[k] > 0.15 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end
  if LT[k] and LT[k] < 0.1 and X.hash(x, y, 5) > 0.4 then c:put(x, y, LEAF[6], ltok) end end)
-- quirk: dew drop with a blue berry reflection
do local dx, dy = 22, 50
  B.map(c, { ".ab.", "acdb", "beeb", ".bb." }, dx - 1, dy - 1,
    { a = "#d8f4ec", b = "#4e9a7a", c = "#fff4d6", d = "#3a68c0", e = "#8ccab0" }, ltok)
end

-- sprout from the left seed: stem + opposite ovate pair + tiny bud
local sp = { { 16, 43 }, { 15, 36 }, { 17, 29 }, { 16, 23 } }
local sm, snn = B.tube(sp, function(t) return 1.05 - 0.15 * t end)
sm:cut(seeds[1].m)
X.tone(c, sm, X.light(snn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function ovate(ax, ay, cx, cy, bx, by, W)
  local m, n, T, S, L = B.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.35, W * sin(pi * min(1, t * 0.78 + 0.2)) ^ 0.6)
  end, { fold = 0.3 })
  m:cut(sm)
  B.toneN(c, m, n, LEAF, { tok = ltok, cuts = B.CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.14 and T[k] > 0.06 and T[k] < 0.86 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end
    local ph = (T[k] * L - abs(S[k]) * 3) / 4
    if abs(S[k]) > 0.25 and abs(S[k]) < 0.7 and (ph - floor(ph)) < 0.2 and T[k] > 0.15 and T[k] < 0.75 then
      c:put(x, y, S[k] < 0 and LEAF[5] or LEAF[3], ltok) end
  end)
  return m
end
ovate(15, 24, 10, 21, 5, 20, 3.6)
ovate(17, 23, 22, 19, 27, 19, 3.6)
c:put(16, 21, STEM[3], stok) c:put(16, 20, STEM[4], stok) c:put(17, 21, STEM[2], stok)

-- seeds: wrinkled coats (ridges across the long axis)
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local idx = B.shade(c, s.m, s.n, SEED, { tok = tok, amb = 0.1, wrap = 0.25 })
  local ca, sa = cos(s[5]), sin(s[5])
  s.m:each(function(x, y) local u = (x - s[1]) * ca + (y - s[2]) * sa
    if abs(floor(u + 0.5)) % 2 == 1 and abs(u) < s[3] - 0.6 then B.step(c, idx, SEED, x, y, -1, tok) end end)
end

-- calyx star: pillow-lit points, darker creases toward the centre, AO under the berry
local cn = X.pillow(star, 2.2)
local cb = {}
X.ao(cb, star, berry, 2, -1)
B.cast(cb, star, berry, 1, 2, -1)
local ci = B.shade(c, star, cn, CAL, { tok = ctok, bias = cb, amb = 0.1, wrap = 0.3 })
star:each(function(x, y)
  local dx, dy = x - CX, (y - CY) * 1.18
  local a = atan(dy, dx) + pi / 2 + 0.1
  local f = abs(((a / (2 * pi / 5)) % 1) - 0.5) * 2
  if f < 0.12 and not berry:has(x, y) then B.step(c, ci, CAL, x, y, -2, ctok) end     -- crease between points
  if f > 0.9 and sqrt(dx * dx + dy * dy) > 5 then B.step(c, ci, CAL, x, y, 1, ctok) end -- lit ridge along each point
end)

-- berry: glossy sphere
local bb = {}
local bi = B.shade(c, berry, bn, BER, { tok = btok, bias = bb, amb = 0.05, wrap = 0.15, cuts = { 0.12, 0.28, 0.48, 0.68, 0.86 } })
berry:each(function(x, y) local nn = bn[K(x, y)] if nn[1] + nn[2] > 1.0 then c:put(x, y, "#4a5ea8", btok) end end)
-- window reflection 2x2 + cream specular
c:put(CX - 3, CY - 4, B.CREAM, btok) c:put(CX - 2, CY - 4, BER[6], btok) c:put(CX - 3, CY - 3, BER[6], btok)
c:put(CX + 2, CY + 1, BER[5], btok)
-- style scar at the top
c:put(CX, CY - 5, BER[1], btok)

B.save(c, NAME)
