-- lantana-seed (final, Opus single pass). Two glossy blue-black lantana drupes and one bare wrinkled stone on a
-- torn scrap of lantana leaf (crenate margin, quilted rugose surface, midrib + swept laterals, jagged pale tear,
-- AO + contact shadow under each seed). The bare stone has germinated: a pale square-ish stem, two round
-- cotyledons and the first opposite pair of true leaves, ovate, pointed and crenate, as on the grown shrub.
-- quirk: the seedling is already showing off a tiny two-tone lantana flower head (orange heart, pink rim).
local NAME = "lantana-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC15_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF = { "#163a30", "#21543a", "#2e7040", "#458e46", "#69ac52", "#a0cc6c" }
local SPR  = { "#1f4a36", "#2f6a42", "#479048", "#6cb056", "#98cc68", "#c8e690" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local DRU  = { "#191330", "#2a1f4e", "#3f2f76", "#5a479c", "#8574c4", "#d6cef4" }
local PIT  = { "#4a3020", "#6e4a2c", "#94683c", "#b88c54", "#d8b07a", "#f0d4a0" }
local TEAR, COOL, BOUNCE = "#c4dc92", "#3a6c72", "#4e5aa0"

-- seeds first (masks), the leaf needs their shadows
local drupes = { { 20, 46, 2.6 }, { 27, 49, 2.6 } }
for _, d in ipairs(drupes) do d.m = c:ellipse(d[1], d[2], d[3], d[3]) end
local stone = { 37, 46.5, 3.2, 2.4, -0.25 }
stone.m, stone.n = A.oval(stone[1], stone[2], stone[3], stone[4], stone[5], 0.9)

-- leaf scrap: lantana blade lying almost flat, crenate margin, left end torn off
local lm, ln, LT, LS, len = A.blade(6, 52, 30, 47, 56, 45, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.95 + 0.06)
  local w = 8.4 * sin(pi * u ^ 0.85) ^ 0.7
  if t > 0.1 and t < 0.94 then w = w + 0.75 * abs(sin(t * 70)) - 0.5 end    -- rounded teeth
  return max(0.5, w)
end, { fold = 0.35 })
local tear = HP.mask()
lm:each(function(x, y) local k = K(x, y)
  local s = LS[k]
  local lim = 0.2 + 0.05 * ((floor((s + 1) * 3.5)) % 2) + 0.03 * sin(s * 11)
  if LT[k] < lim then tear:set(x, y) end
end)
lm:cut(tear)
local bias = {}
for _, d in ipairs(drupes) do X.ao(bias, lm, d.m, 1, -1) A.cast(bias, lm, d.m, 1, 2, -1) end
X.ao(bias, lm, stone.m, 1, -1) A.cast(bias, lm, stone.m, 1, 2, -1)
-- quilted rugose surface: puckers between veins
lm:each(function(x, y) local k = K(x, y)
  local q = sin(LT[k] * len * 0.9) * sin(LS[k] * 7.5)
  if q > 0.72 then bias[k] = (bias[k] or 0) - 1 end
end)
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] and bias[k] < -1 then return end
  if abs(s) < 0.13 and t < 0.95 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
  local d = (t * len - abs(s) * 5.5) % 5.0
  if d < 0.8 and abs(s) > 0.16 and abs(s) < 0.82 and t < 0.9 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)
-- cool reflected light on the lower-right rim; pale torn fibres along the tear
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.3 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)
lm:each(function(x, y) if tear:has(x - 1, y) or tear:has(x, y - 1) then c:put(x, y, TEAR, ltok) end end)

-- sprout stem
local stok = { r = { name = "stem" } }
local stp = { { 37, 45 }, { 35, 37 }, { 38, 28 }, { 36, 19 } }
local sm = A.stem(c, stp, function(t) return 1.1 - 0.15 * t end, STEM, { tok = stok, cut = stone.m })
-- leaves
local sprtok = { r = { name = "sprout" } }
local function ovate(ax, ay, cx, cy, bx, by, w)
  local m, T, S = A.leaf(c, ax, ay, cx, cy, bx, by, w, SPR, { cut = sm, tok = sprtok, vs = 3.0, fold = 0.5, wfn = function(t)
    if t > 0.985 then return -1 end
    local ww = w * sin(pi * min(1, (t * 0.97 + 0.03) ^ 0.72)) ^ 0.6
    if t > 0.2 and t < 0.9 then ww = ww + 0.55 * sin(t * 26) end      -- crenate edge
    return max(0.35, ww)
  end })
  return m
end
local cot = function(ax, ay, bx, by)
  return A.leaf(c, ax, ay, (ax + bx) / 2, ay - 1.5, bx, by, 1.8, SPR, { cut = sm, tok = sprtok, vs = 9, fold = 0.3, wfn = function(t)
    if t > 0.97 then return -1 end return max(0.4, 1.9 * sin(pi * min(1, t * 0.9 + 0.12)) ^ 0.45) end })
end
cot(36, 37, 27, 37)
cot(38, 36, 47, 36)
ovate(36, 28, 29, 23, 23, 25, 3.5)
ovate(38, 27, 44, 22, 50, 23, 3.5)

-- seeds on top: glossy drupes, bare wrinkled stone
for i, d in ipairs(drupes) do
  local tok = { r = { name = "drupe" .. i } }
  local n = X.sphere(d[1] + 0.5, d[2] + 0.5, d[3], d.m)
  local db = {}
  if i == 1 then X.ao(db, d.m, drupes[2].m, 1, -1) end
  A.shade(c, d.m, n, DRU, { amb = 0.05, wrap = 0.15, cuts = { 0.15, 0.32, 0.5, 0.7, 0.9 }, bias = db, tok = tok })
  local x0, y0 = floor(d[1] + 0.5), floor(d[2] + 0.5)
  c:put(x0 - 1, y0 - 2, DRU[6], tok) c:put(x0 - 2, y0 - 1, DRU[5], tok)       -- specular
  c:put(x0 + 2, y0 + 1, BOUNCE, tok)                                           -- cool bounce
  c:put(x0, y0 - 3, DRU[2], tok)                                               -- stalk scar
end
local ptok = { r = { name = "pit" } }
local pidx = A.shade(c, stone.m, stone.n, PIT, { amb = 0.08, wrap = 0.25, tok = ptok })
stone.m:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 9)
  if h > 0.62 and (pidx[k] or 1) > 2 and ((x + 2 * y) % 3 == 0) then c:put(x, y, PIT[pidx[k] - 2], ptok) end   -- wrinkles
end)
c:put(35, 45, PIT[6], ptok) c:put(36, 45, PIT[6], ptok)
-- split seam where the shoot came out
c:put(37, 44, PIT[1], ptok) c:put(38, 44, STEM[3], stok)

-- quirk: tiny lantana flower head on the shoot tip
local ftok = { r = { name = "flower" } }
local PK, PKd, OR, ORd, YE = "#f5809f", "#c94f84", "#f08a2a", "#c25a24", "#ffd84a"
A.map(c, {
  ".pPp.",
  "pyoyP",
  "PoOoP",
  ".POP.",
}, 34, 15, { p = PK, P = PKd, y = YE, o = OR, O = ORd }, ftok)
c:put(36, 14, "#ffc4d8", ftok)

A.save(c, NAME)
