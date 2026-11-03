-- apple-seed (final, Opus). Glossy mahogany apple pips (teardrops: round back, pointed pale hilum tip, one bright
-- specular each) on a torn scrap of apple leaf (ovate, finely serrated, midrib + swept veins, V-fold light, ragged torn
-- end with pale fibres, cool reflected edge, contact shadow under each pip). The front pip has germinated: white root,
-- pale stem, two smooth oval cotyledons and a first true apple leaf (serrated, pointed, veined).
-- quirk: the split seed coat is still stuck like a little cap on the tip of the left cotyledon.
local NAME = "apple-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = A.new(NAME)

local LEAF  = { "#143628", "#1d5034", "#2a6a3c", "#3c8a44", "#5eaa50", "#92ca6a" }
local YLEAF = { "#24543a", "#357a42", "#4e9a4a", "#72b856", "#a0d270", "#cfeb98" }
local SEED  = { "#200e0c", "#3c1610", "#5e2414", "#86361a", "#ae5426", "#d88448" }
local STEM  = { "#5a8a52", "#8cba6e", "#bcdc96", "#e4f4c2" }
local ROOT  = { "#a89a86", "#d4c8b0", "#f2ead6" }
local COOL, TORN = "#3a6a76", "#c6e2a0"

-- pips: cx, cy, ux, uy (tip direction)
local pips = {
  { 17, 47, -0.8, -0.6, 4.3, 2.5 },
  { 27, 46, 0.35, -0.94, 4.3, 2.5 },
  { 37, 44, 0.15, 0.99, 4.0, 2.4 },     -- sprouting pip: tip down (root comes out of the tip)
}
for _, p in ipairs(pips) do
  local l = sqrt(p[3]^2 + p[4]^2) p[3], p[4] = p[3] / l, p[4] / l
  p.m, p.n, p.U, p.V = A.pip(p[1], p[2], p[3], p[4], p[5], p[6], 1.2, 0.9)
end

-- root (drawn under the pip, over the leaf): pale, tapering, curling down over the leaf edge
local rtok = { r = { name = "root" } }
local rp = { { 37, 48 }, { 38, 52 }, { 41, 55 }, { 44, 56 } }

-- leaf scrap along the diagonal
local bias = {}
local lm, ln, LT, LS, LEN = A.blade(9, 52, 30, 54, 55, 37, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 9.0 * sin(pi * min(1, t * 0.9 + 0.1) ^ 0.9) ^ 0.75)
end, { fold = 0.4 })
-- serration on the margin
do local cut = {}
  lm:edge():each(function(x, y) local k = K(x, y)
    local ph = (LT[k] * LEN / 2.3) + (LS[k] > 0 and 0.5 or 0)
    if LT[k] > 0.2 and LT[k] < 0.95 and (ph - floor(ph)) < 0.34 and abs(LS[k]) > 0.5 then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do lm.s[k] = nil end
end
-- torn end: ragged line across the blade near the base (t ~ 0.12..0.2)
local torn = {}
lm:each(function(x, y) local k = K(x, y)
  local lim = 0.15 + 0.05 * sin(LS[k] * 9.0) + 0.03 * sin(LS[k] * 23.0)
  if LT[k] < lim then torn[#torn + 1] = k end
end)
for _, k in ipairs(torn) do lm.s[k] = nil end

for _, p in ipairs(pips) do X.ao(bias, lm, p.m, 1, -1) A.cast(bias, lm, p.m, 1, 2, -1) end
local rootm, rootn = A.tube(rp, function(t) return 1.3 * (1 - t) ^ 0.8 + 0.3 end)
A.cast(bias, lm, rootm, 1, 0, -1)
local ltok = { r = { name = "leaf" } }
local lidx = A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t < 0.95 then c:put(x, y, s <= 0 and "#b6dc84" or LEAF[3], ltok) return end
  if t > 0.2 and t < 0.88 and abs(s) > 0.2 and abs(s) < 0.76 then
    local d = (t * LEN - abs(s) * 9 * 1.1 + (s > 0 and 1.7 or 0)) % 5.6
    if d < 0.9 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
  end
end)
-- cool reflected light on the lower-right margin, pale fibres along the torn end
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.25 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end
  if LT[k] < 0.26 and not lm:has(x - 1, y) and not bias[k] then c:put(x, y, TORN, ltok) end
end)

-- root
local ridx = A.shade(c, rootm, rootn, ROOT, { amb = 0.2, wrap = 0.3, tok = rtok, cuts = { 0.35, 0.65 } })
c:put(44, 57, ROOT[2], rtok)

-- sprout stem (rises from the pip's round end), cotyledons, first true leaf
local stok = { r = { name = "stem" } }
local sp = { { 37, 41 }, { 36, 34 }, { 38, 28 }, { 37, 22 } }
local sm = A.stem(c, sp, function(t) return 1.05 end, STEM, { tok = stok })
local ytok = { r = { name = "sprout" } }
local function coty(ax, ay, cx, cy, bx, by)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, 2.6 * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.55)
  end, { fold = 0.25 })
  m:cut(sm)
  A.shade(c, m, n, YLEAF, { tok = ytok, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.12 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and YLEAF[6] or YLEAF[3], ytok) end end)
  return m
end
local cl = coty(36, 26, 30, 22, 25, 25)
local crt = coty(38, 26, 44, 22, 49, 24)
-- first true apple leaf, pointing up from the stem tip
local tl = A.leaf(c, 37, 23, 35, 16, 39, 8, 3.4, LEAF, { teeth = 2.0, vs = 2.6, tok = ltok, cut = cl:copy():add(crt) })
for y = 22, 24 do c:put(37, y, STEM[2], stok) end

-- quirk: split seed coat stuck on the left cotyledon tip
local qt = { r = { name = "coat" } }
A.map(c, {
  ".ab",
  "abc",
  "bc.",
}, 23, 23, { a = SEED[5], b = SEED[3], c = SEED[2] }, qt)
c:put(24, 23, SEED[6], qt)

-- pips last: lit as glossy ovoids, pale hilum at the tip, spec glint
for i, p in ipairs(pips) do
  local tok = { r = { name = "pip" .. i } }
  local idx = A.shade(c, p.m, p.n, SEED, { tok = tok, amb = 0.05, wrap = 0.25, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
  -- faint long ridge (seed coat seam) on the lit side
  p.m:each(function(x, y) local k = K(x, y)
    if p.U[k] > 0.75 then c:put(x, y, SEED[6], tok) end           -- pale hilum tip
  end)
  local sx, sy = A.specAt(p.m, p.n, 30)
  c:put(sx, sy, A.CREAM, tok)
end

A.save(c, NAME)
