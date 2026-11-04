-- coriander-seed (final pass, Opus single pass). Round, ribbed coriander seeds (straw-tan spheres with fine wavy
-- meridian ribs and a tiny calyx point on top) resting on a torn coriander leaf scrap (broad flat-parsley blade with
-- a scalloped margin, midrib + veins, jagged tear on the right, AO and contact shadow under each seed).
-- The middle seed has germinated: a pale stem, two long strap cotyledons and the first true leaf (round, three-lobed,
-- toothed: the coriander leaf in miniature).
-- quirk: one seed has split into its two half-shells, showing the pale hollow insides.
local NAME = "coriander-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, asin = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.asin
local c = A.new(NAME)

local LEAF = { "#163d2c", "#1f5a34", "#2c7a3a", "#46a042", "#72c052", "#a8de74" }
local SEED = { "#4a3020", "#6e4a2c", "#94683c", "#b88c52", "#d6b072", "#f0d79c" }
local STEM = { "#4d8a52", "#82ba6a", "#b6dc8e", "#e0f2bc" }
local COOL, INSIDE = "#3e6e70", "#fbecc4"
local ltok, stok = { r = { name = "leaf" } }, { r = { name = "stem" } }

-- seeds (cx, cy, r)
local S1, S2 = { 19, 46, 3.6 }, { 30, 45, 3.8 }
local SPL = { 41, 47 }
local function sphere(s) return c:ellipse(s[1], s[2], s[3], s[3]) end
local m1, m2 = sphere(S1), sphere(S2)
local splitM = c:ellipse(SPL[1] - 2.2, SPL[2] + 0.5, 2.6, 2.4):add(c:ellipse(SPL[1] + 3.2, SPL[2] + 0.5, 2.6, 2.4))

-- leaf scrap: broad blade with scalloped margin and a torn right end
local lm, LT, LS, lidx, len = nil
do
  local wfn = function(t) if t > 0.99 then return -1 end return max(0.5, 8.8 * sin(pi * min(1, t * 0.86 + 0.1)) ^ 0.55) end
  local m, n, T, S, L = A.blade(6, 51, 32, 41, 58, 47, wfn, { fold = 0.35 })
  -- scallops: rounded notches along the margin
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    local ph = (T[k] * L / 6.0 + (S[k] > 0 and 0.5 or 0)) % 1
    local f = abs(ph - 0.5) * 2
    if abs(S[k]) > 0.93 - (1 - f) ^ 3 * 0.35 then cut[#cut + 1] = k end
    -- tear: jagged diagonal on the right
    local tear = 49 + (y - 44) * 0.4 + ((y % 3 == 0) and 1.5 or 0) + ((y % 5 == 1) and -1 or 0)
    if x > tear then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  local bias = {}
  for _, sm in ipairs{ m1, m2, splitM } do X.ao(bias, m, sm, 1, -1) A.cast(bias, m, sm, 1, 2, -1) end
  local idx = A.toneN(c, m, n, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
  -- midrib + curved veins
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if bias[k] then return end
    if abs(s) < 0.13 and t > 0.03 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
    local ph = (t * L - abs(s) * 5.0) / 6.0 + (s > 0 and 0.5 or 0)
    local f = abs((ph - floor(ph)) - 0.5) * 2
    if f > 0.86 and abs(s) > 0.18 and abs(s) < 0.72 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
  end)
  -- cool reflected light on the shade edge; pale torn fibres on the tear
  m:edge():each(function(x, y) local k = K(x, y)
    if not bias[k] and S[k] > 0.7 then c:put(x, y, COOL, ltok) end
    if not m:has(x + 1, y) and x > 46 and abs(S[k]) < 0.8 then c:put(x, y, LEAF[6], ltok) end
  end)
  -- petiole stub
  for _, q in ipairs{ { 5, 52, 4 }, { 4, 53, 3 }, { 3, 54, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end
  lm, LT, LS = m, T, S
end

-- sprout: stem from the middle seed, two strap cotyledons, a round three-lobed true leaf
local sm = A.stem(c, { { 30, 42 }, { 28, 35 }, { 31, 29 }, { 30, 22 } }, function(t) return 1.0 + 0.2 * (1 - t) end, STEM, { cut = m2 })
local function strap(ax, ay, cx, cy, bx, by)
  local m = A.leaf(c, ax, ay, cx, cy, bx, by, 1.8, LEAF, { pw = 0.5, fold = 0.3, cut = sm, vs = 99 })
  return m
end
local cl = strap(29, 24, 23, 21, 15, 20)
local cr = strap(31, 24, 37, 20, 45, 19)
-- true leaf on a short petiole
A.line(c, { { 30, 22 }, { 31, 19 }, { 32, 17 } }, STEM[3], stok)
local tl = HP.mask()
tl:add(c:ellipse(28.6, 13.2, 2.7, 2.4)):add(c:ellipse(35.8, 13.4, 2.7, 2.4)):add(c:ellipse(32.2, 10.6, 3.0, 2.8))
tl:add(c:ellipse(32.2, 14.4, 2.2, 1.6))
-- toothed margin: knock out every third rim pixel
local teeth = {}
tl:edge():each(function(x, y) if (x * 3 + y * 5) % 7 == 0 then teeth[#teeth + 1] = K(x, y) end end)
for _, k in ipairs(teeth) do tl.s[k] = nil end
local tn = X.pillow(tl, 2.2)
local tidx = A.shade(c, tl, tn, LEAF, { amb = 0.14, wrap = 0.3, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, tok = ltok })
-- veins radiating from the base into each lobe
A.line(c, { { 32, 16 }, { 32.2, 9 } }, LEAF[3], ltok)
A.line(c, { { 32, 15 }, { 28, 12 } }, LEAF[3], ltok)
A.line(c, { { 32, 15 }, { 36, 12.5 } }, LEAF[2], ltok)
c:put(31, 10, LEAF[6], ltok) c:put(30, 11, LEAF[6], ltok)
c:put(32, 16, STEM[2], stok)

-- seeds: sphere light with ribs (wavy meridians), calyx point, AO between neighbours
local function seed(s, m)
  local n = X.sphere(s[1] - 0.4, s[2] - 0.4, s[3] + 0.4, m)
  local bias = {}
  local idx = A.shade(c, m, n, SEED, { amb = 0.08, wrap = 0.22, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, tok = { r = { name = "seed" } }, bias = bias })
  m:each(function(x, y) local k = K(x, y)
    local dy = (y - s[2]) / (s[3] + 0.5)
    local w = sqrt(max(0.05, 1 - dy * dy))
    local u = max(-1, min(1, (x - s[1] + 0.3 * sin(dy * 3)) / ((s[3] + 0.5) * w)))
    local ph = (asin(u) / pi * 5 + 0.5) % 1
    local i = idx[k]
    if ph < 0.2 then i = i - 1 elseif ph > 0.8 then i = i + 1 end
    c:put(x, y, SEED[max(1, min(6, i))], { r = { name = "seed" } })
  end)
  -- calyx point on top + specular
  c:put(floor(s[1] + 0.5), floor(s[2] - s[3] - 0.5), SEED[2], { r = { name = "seed" } })
  c:put(floor(s[1] - 1.5), floor(s[2] - 1.5), SEED[6], { r = { name = "seed" } })
end
seed(S1, m1)
seed(S2, m2)
-- stem foot over the sprouting seed's crack
c:put(30, 42, STEM[2], stok) c:put(30, 41, STEM[3], stok) c:put(31, 42, SEED[1], { r = { name = "seed" } })

-- quirk: split seed, two half shells tipped open (outer dome below, pale hollow inside above)
for i, cx in ipairs{ SPL[1] - 2.2, SPL[1] + 3.2 } do
  local shell = c:ellipse(cx, SPL[2] + 0.5, 2.6, 2.4)
  local n = X.sphere(cx - 0.4, SPL[2] + 0.1, 3.0, shell)
  local idx = A.shade(c, shell, n, SEED, { amb = 0.08, wrap = 0.22, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, tok = { r = { name = "shell" .. i } } })
  -- cut face: ellipse on top half (rim pale, hollow tan)
  local face = c:ellipse(cx, SPL[2] - 0.6, 2.2, 1.3)
  face:each(function(x, y) c:put(x, y, INSIDE, { r = { name = "shell" .. i } }) end)
  face:shrink(1):each(function(x, y) c:put(x, y, SEED[4], { r = { name = "shell" .. i } }) end)
  -- ribs on the outer dome
  shell:each(function(x, y) if y > SPL[2] and (x - floor(cx)) % 2 == 0 and not face:has(x, y) then
    c:put(x, y, SEED[max(1, idx[K(x, y)] - 1)], { r = { name = "shell" .. i } }) end end)
end

A.save(c, NAME)
