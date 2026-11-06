-- cauliflower-seed (final, Opus aB1r1_1). Five tiny round brassica seeds (rust-brown spheres, each with a glint,
-- 1 px air between) on a torn scrap of a broad glaucous cauliflower leaf (blue-green 6-tone, wavy margin, pale
-- cream midrib + arching veins, waxy bloom streaks, cool reflected edge, pale torn rim, AO + contact shadow under
-- each seed). The right seed has sprouted: a pale stem and two broad notched heart-shaped brassica cotyledons on
-- short petioles, with the first true leaf just peeping between them.
-- quirk: a cabbage-white butterfly has already found the seedling and perches on the right cotyledon.
local NAME = "cauliflower-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r1_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#182c42", "#1f4656", "#2c6468", "#40827a", "#62a28e", "#92c6a8" }
local VEIN, BLOOM, COOL, TORN = "#e4f2d8", "#c4e2d4", "#4a6c94", "#d6ecd0"
local COT = { "#1c4a36", "#28663e", "#3a8448", "#58a452", "#82c264", "#b6e08a" }
local STEM = { "#5c8a5a", "#8cb87a", "#bcdca2", "#e4f2c8" }
local SEED = { "#2c1820", "#4c2824", "#6e3a2a", "#94523a", "#ba744c", "#e0a874" }
local ltok = { r = { name = "leaf" } }

-- leaf scrap: broad, lying flat, wavy margin, torn at the left
local lm, ln, LT, LS, len = A.blade(8, 49, 31, 40, 57, 47, function(t)
  if t > 0.985 then return -1 end
  local w = 9.6 * sin(pi * min(1, t * 0.86 + 0.14)) ^ 0.62
  return max(0.6, w + 0.75 * sin(t * 26))
end, { fold = 0.32 })
local rim = A.tear(lm, LT, LS, len, 2.5, 4)

-- seeds
local seeds = { { 15, 44 }, { 20, 42 }, { 20, 47 }, { 25, 44 }, { 35, 43 } }
local smask = HP.mask()
for _, s in ipairs(seeds) do s.m = HP.ellipse(s[1], s[2], 1.75, 1.75) smask:add(s.m) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 1, -1) A.cast(bias, lm, s.m, 2, 1, -1) end
local stemPts = { { 35, 42 }, { 34, 36 }, { 37, 30 }, { 38, 25 } }
local sm, sn = A.tube(stemPts, function(t) return 1.05 end)
A.cast(bias, lm, sm, 1, 1, -1)
A.leaf(c, lm, ln, LT, LS, len, LEAF, { bias = bias, tok = ltok, per = 6.5, sweep = 4, vein = VEIN, cool = COOL, rim = rim, rimCol = TORN })
-- waxy bloom: short pale streaks on the lit half
for _, b in ipairs{ { 14, 40 }, { 30, 39 }, { 41, 41 }, { 47, 43 }, { 10, 47 } } do
  for i = 0, 1 do local x, y = b[1] + i, b[2]
    if lm:has(x, y) and not bias[K(x, y)] and LS[K(x, y)] < -0.2 then c:put(x, y, BLOOM, ltok) end end
end

-- sprout stem
local stok = { r = { name = "stem" } }
sm:cut(seeds[5].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })

-- cotyledons: broad hearts with a notch at the outer end, on short petioles
local ctok = { r = { name = "cot" } }
local function cot(px, py, cx, cy, ux, uy)
  local l = sqrt(ux * ux + uy * uy) ux, uy = ux / l, uy / l
  local m = A.rell(cx, cy, ux, uy, 6.2, 4.3)
  m:cut(A.rell(cx + ux * 6.6, cy + uy * 6.6, ux, uy, 1.9, 1.5))
  local n = X.pillow(m, 2.6)
  A.toneN(c, m, n, COT, { tok = ctok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.12, wrap = 0.25 })
  -- midrib from the petiole to the notch, and a dark rim on the far side of the notch
  for i = -3, 3 do local x, y = floor(cx + ux * i + .5), floor(cy + uy * i + .5)
    if m:has(x, y) then c:put(x, y, i < 0 and COT[5] or COT[4], ctok) end end
  for i = 0, 3 do local x, y = floor(px + (cx - ux * 5.4 - px) * i / 3 + .5), floor(py + (cy - uy * 4.5 - py) * i / 3 + .5)
    c:put(x, y, STEM[3], stok) end
  return m
end
local cl = cot(38, 25, 30, 21, -1, -0.32)
local cr = cot(38, 25, 47, 20, 1, -0.4)
-- first true leaf peeping between them
A.map(c, 37, 21, { ".g.", "gGg", ".s." }, { g = COT[4], G = COT[6], s = STEM[2] }, ctok)

-- seeds last (glossy little balls)
for i, s in ipairs(seeds) do
  A.ball(c, s[1], s[2], 1.75, SEED, { r = { name = "seed" .. i } }, i % 2 == 1 and "#ffe2b8" or nil)
end

-- quirk: cabbage-white butterfly perched on the right cotyledon (wings closed, upright)
A.map(c, 45, 10, {
  "..k.k..",
  "...kk..",
  ".WWWWs.",
  "WWWWWWs",
  "WWdWWWs",
  ".WWWWS.",
  "..WWSS.",
  "...bb..",
  "...b.b.",
}, { k = "#4a3a46", W = "#fff1d4", d = "#3a2a36", s = "#d8d0e2", S = "#a69cbc", b = "#3a2a36" })
A.save(c, NAME)
