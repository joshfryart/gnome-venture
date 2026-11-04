-- seedgen: parametric seed-on-leaf-scrap generator, derived from items/batch2/blueberry-seed.lua (Opus).
-- P extras: scrap={ax,ay,cx,cy,bx,by} scrapW scrapExp sprout=pair|blades|trio|single leafw marks=pits|spots|stripes|none markc extra=function(ctx) quirk="none"|"hat"
-- Usage: dofile(dir.."/seedgen/seedgen.lua")(P)  P = {name,dir,leaf,sleaf,seed,stem,root,vein,gloss,cool,red,sl,sw,taper,drop,leafw,quirk}
return function(P)
local DEF = {
  LEAF  = { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" },
  SLEAF = { "#1a4238", "#255f43", "#33804b", "#4f9f52", "#78bd5c", "#a8d877" },
  SEED  = { "#3a1a1e", "#62262a", "#8c3c32", "#b45c3c", "#d68650", "#f0b878" },
  STEM  = { "#5a2a30", "#86403a", "#a85c48", "#7a8a48", "#9cae5a" },
  ROOT  = { "#b8a488", "#e2d2b4", "#f6ecd6" } }
local NAME = P.name
local G = dofile(P.dir .. "/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local LEAF = P.leaf or DEF.LEAF
local SLEAF = P.sleaf or DEF.SLEAF
local SEED = P.seed or DEF.SEED
local STEM = P.stem or DEF.STEM
local VEIN, GLOSS, COOL, RED = P.vein or "#bfe28a", P.gloss or "#dff2a8", P.cool or "#3c6f74", P.red or "#a8443e"
local ROOT = P.root or DEF.ROOT

-- teardrop seed mask + pillow normals; axis angle a points from round end to pointed end
local function seedMask(cx, cy, rl, rw, a)
  local ca, sa = cos(a), sin(a)
  local m = HP.mask()
  for y = floor(cy) - 5, floor(cy) + 5 do for x = floor(cx) - 5, floor(cx) + 5 do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / (rl + 0.4)
    local v = (-dx * sa + dy * ca)
    if abs(u) <= 1 then
      local hw = (rw + 0.4) * sqrt(1 - u * u) * (1 - (P.taper or 0.32) * u)
      if abs(v) <= hw then m:set(x, y) end
    end
  end end
  return m
end
local seeds = {   -- cx, cy, length r, width r, axis angle
  { 17, 50, 3.6, 2.5, -0.8 },
  { 25, 53, 3.3, 2.3, 0.35 },
  { 30, 46, 3.6, 2.5, -1.75 },   -- the one that sprouts
  { 41, 46, 3.5, 2.4, 2.75 },
}
local SPROUT = seeds[3]
for _, i in ipairs(P.drop or {}) do table.remove(seeds, i) end   -- drop list in DESCENDING order, never 3
for _, s in ipairs(seeds) do
  s.m = seedMask(s[1], s[2], s[3] * (P.sl or 1), s[4] * (P.sw or 1), s[5])
  s.n = X.pillow(s.m, 2.4)
end

-- leaf scrap -------------------------------------------------------------------------------------
local SC = P.scrap or {7, 55, 28, 52, 57, 40}
local lm, ln, LT, LS, len = G.blade(SC[1], SC[2], SC[3], SC[4], SC[5], SC[6], function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.92 + 0.08)
  return max(0.45, (P.scrapW or 6.3) * sin(pi * u ^ 1.2) ^ (P.scrapExp or 0.72))
end, { fold = 0.42 })
-- fine serration: nibble every 3rd edge pixel on the outer half
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) G.cast(bias, lm, s.m, 2, 2, -1) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.2 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.02 and t < 0.93 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  for _, vt in ipairs{ 6, 11, 16, 21, 26, 31, 36, 41 } do
    local d = t * len - (vt + abs(s) * 5.0)
    if d > -0.55 and d < 0.55 and abs(s) > 0.18 and abs(s) < 0.74 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) return end
  end
  if s < -0.35 and s > -0.6 and t > 0.6 and t < 0.8 then c:put(x, y, GLOSS, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LS[k] > 0.6 and LT[k] > 0.1 and LT[k] < 0.8 then c:put(x, y, COOL, ltok) end
  if LT[k] > 0.84 or LT[k] < 0.06 then c:put(x, y, RED, ltok) end
end)
-- torn base: ragged cut where the scrap was snipped (left end), paler cut line
for _, p in ipairs{ {7, 55}, {8, 56}, {8, 54} } do if lm:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[5], ltok) end end

-- sprout -----------------------------------------------------------------------------------------
local sp = SPROUT
-- radicle: cream root curling down-right from the split seed onto the leaf
local rpts = { {31, 49}, {32, 51}, {34, 53}, {36, 53}, {37, 52}, {37, 51} }
local rm = c:line(rpts, 1)
rm:each(function(x, y) c:put(x, y, ROOT[2], { r = { name = "root" } }) end)
c:put(31, 49, ROOT[3]) c:put(32, 50, ROOT[3]) c:put(37, 51, ROOT[1]) c:put(36, 53, ROOT[1])
-- AO under the root on the leaf
rm:shift(0, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)

-- stem (red at the base, greening upward)
local stm, stn, ST = G.tube({ {29, 43}, {28, 34}, {35, 28}, {33, 18} }, function(t) return 0.95 - 0.15 * t end)
local stok = { r = { name = "stem" } }
local sv = X.light(stn, { amb = 0.15, wrap = 0.3 })
stm:each(function(x, y) local k = K(x, y)
  local lit = sv[k] > 0.55
  local t = ST[k]
  local col
  if t < 0.55 then col = lit and STEM[3] or STEM[2] else col = lit and STEM[5] or STEM[4] end
  c:put(x, y, col, stok)
end)

-- sprout leaves: elliptic, pointed (blueberry leaf), midrib + 2 veins
local function sleaf(ax, ay, cx, cy, bx, by, w, veins)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.9 + 0.1)
    return max(0.45, w * sin(pi * u ^ 1.25) ^ 0.75)
  end, { fold = 0.5 })
  m:cut(stm)
  local tok = { r = { name = "sl" .. ax .. bx } }
  G.toneN(c, m, n, SLEAF, { tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.12, wrap = 0.22 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.14 and t > 0.05 and t < 0.9 then c:put(x, y, s <= 0 and SLEAF[6] or SLEAF[2], tok) return end
    for _, vt in ipairs(veins) do
      local d = t * L - (vt + abs(s) * 3.4)
      if d > -0.5 and d < 0.5 and abs(s) > 0.28 and abs(s) < 0.72 then c:put(x, y, s < 0 and SLEAF[6] or SLEAF[2], tok) return end
    end
  end)
  m:edge():each(function(x, y) local k = K(x, y) if S[k] > 0.6 and T[k] > 0.15 and T[k] < 0.85 then c:put(x, y, COOL, tok) end end)
  return m, S, T
end
local kind = P.sprout or "pair"
local lw = P.leafw or 3.6
if kind == "pair" then
  sleaf(32, 20, 25, 13, 16, 13, lw, { 4, 8 })
  sleaf(34, 20, 40, 12, 49, 11, lw, { 4, 8 })
elseif kind == "blades" then   -- grass-like: three thin blades
  sleaf(32, 22, 26, 12, 20, 4, lw * 0.5, { 6 })
  sleaf(33, 22, 36, 11, 42, 3, lw * 0.5, { 6 })
  sleaf(33, 21, 33, 12, 33, 2, lw * 0.45, { 6 })
elseif kind == "trio" then   -- trifoliate: two side leaflets + a top one
  sleaf(32, 21, 26, 17, 20, 18, lw, { 3, 6 })
  sleaf(34, 21, 40, 17, 46, 18, lw, { 3, 6 })
  sleaf(33, 20, 31, 12, 33, 4, lw, { 4, 8 })
else   -- single big leaf
  sleaf(33, 21, 28, 9, 38, 3, lw * 1.3, { 4, 8, 12 })
end
-- terminal bud between the pair
local bud = { {33, 17, SLEAF[5]}, {33, 16, SLEAF[6]}, {34, 16, SLEAF[4]}, {34, 15, SLEAF[5]}, {34, 14, SLEAF[3]}, {33, 18, SLEAF[4]}, {34, 17, SLEAF[3]} }
for _, p in ipairs(bud) do c:put(p[1], p[2], p[3], { r = { name = "bud" } }) end
-- AO where the leaves meet the stem
for _, p in ipairs{ {32, 21}, {34, 21}, {33, 21} } do if stm:has(p[1], p[2]) then c:put(p[1], p[2], STEM[1], stok) end end

-- seeds ------------------------------------------------------------------------------------------
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local idx = X.tone(c, s.m, X.light(s.n, { amb = 0.06, wrap = 0.22 }), SEED, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 }, tok = tok })
  -- pitted coat: a few deep pits on the mid tones
  local mk = P.marks or "pits"
  s.m:shrink(1):each(function(x, y) local k = K(x, y)
    if mk == "pits" and idx[k] >= 3 and idx[k] <= 5 and X.hash(x, y, 31 + i) > 0.72 then c:put(x, y, SEED[idx[k] - 2], tok)
    elseif mk == "spots" and X.hash(x, y, 77 + i) > 0.8 then c:put(x, y, P.markc or SEED[1], tok)
    elseif mk == "stripes" and (x * 7 + y * 3) % 4 == 0 and idx[k] >= 2 then c:put(x, y, P.markc or SEED[1], tok) end end)
  -- hilum: pale dot near the pointed end
  local hx, hy = floor(s[1] + cos(s[5]) * (s[3] - 0.6) + .5), floor(s[2] + sin(s[5]) * (s[3] - 0.6) + .5)
  if s.m:has(hx, hy) then c:put(hx, hy, "#efd2a0", tok) end
  local bx, by = G.specAt(s.m, s.n, 30)
  if bx then c:put(bx, by, "#fff0d8", tok) end
end
-- the sprouting seed: split along its seam where the stem leaves
for _, p in ipairs{ {28, 44}, {30, 44}, {29, 45} } do if sp.m:has(p[1], p[2]) then c:put(p[1], p[2], SEED[1], { r = { name = "seed3" } }) end end
c:put(29, 44, STEM[2], { r = { name = "seed3" } })

-- quirk: empty seed coat sitting on the tip of the right sprout leaf like a hat
if P.extra then P.extra{ c = c, G = G, X = X, K = K, HP = HP, seeds = seeds, sprout = SPROUT, lm = lm, stm = stm } end
if P.quirk == "none" then G.save(c, NAME) return end
local hat = seedMask(49, 9, 2.4, 1.7, -2.4)
local hn = X.pillow(hat, 2)
local htok = { r = { name = "hat" } }
X.tone(c, hat, X.light(hn, { amb = 0.08, wrap = 0.25 }), SEED, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 }, tok = htok })
local hb, hy2 = G.specAt(hat, hn, 30)
if hb then c:put(hb, hy2, "#fff0d8", htok) end
c:put(48, 11, SEED[1], htok)   -- the open mouth of the coat over the leaf tip
G.save(c, NAME)

end
