-- pumpkin-seed (batch2, Opus single pass, replaces the Sonnet draft). Three flat cream pumpkin seeds (teardrop, raised
-- pale rim, slightly sunken face, dark notch at the pointed hilum end, glossy spec, contact shadow) on a scrap of a
-- palmate pumpkin leaf (lobed, serrated, pale palmate veins, cool lower-right rim). The middle seed has germinated: a
-- thin root tip, a pale hooked stem, two thick oval seed-leaves and a first true leaf with the pumpkin's lobed shape.
-- quirk: the empty seed coat is still stuck on the tip of one seed-leaf like a little hat.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_b2g2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, sqrt, max, min, abs, pi, cos, sin = math.floor, math.sqrt, math.max, math.min, math.abs, math.pi, math.cos, math.sin
local c = G.new2("pumpkin-seed")

local LEAF = { "#173f33", "#225a3d", "#2f7744", "#46954b", "#68b452", "#98d06a" }
local COT  = { "#24544a", "#3a8049", "#559e4c", "#76bb56", "#a2d46a", "#cdea92" }
local HYP  = { "#3d6236", "#5c8642", "#80aa52", "#a3c66a", "#c5dc8c", "#e4efba" }
local SEED = { "#9a8456", "#bea877", "#d9c796", "#ebdcb0", "#f7ecca", "#fff7e0" }
local VEIN, COOL = "#b7dc84", "#3c6f74"

-- seeds: cx, cy, half length, half width, tip angle
local seeds = {
  { 17.5, 42, 5.8, 3.8, 2.0 },
  { 43, 44.5, 5.8, 3.8, 0.35 },
  { 31.5, 49, 6.0, 3.9, 2.75 },     -- germinating one (tip down-left)
}
for _, s in ipairs(seeds) do s.m, s.n, s.U = G.drop(s[1], s[2], s[3], s[4], s[5], 0.55) end
local allSeeds = HP.mask() for _, s in ipairs(seeds) do allSeeds:add(s.m) end

-- leaf scrap: three-lobed piece of a pumpkin leaf, base sinus at the lower left
local lm, ln, inf = G.palm(13, 56, { { -1.32, 25 }, { -0.68, 32 }, { -0.05, 29 } }, { sharp = 2.6, floor = 0.3, serr = true, spread = 2.3, fold = 0.55 })
-- torn edge: a ragged bite out of the far lower-right margin
lm:each(function(x, y) if x + y * 0.5 > 99 + X.hash(floor(y / 2), 2, 3) * 3 then lm.s[K(x, y)] = nil end end)
local bias = {}
X.ao(bias, lm, allSeeds, 1, -1) G.cast(bias, lm, allSeeds, 1, 2, -1) G.cast(bias, lm, allSeeds, 2, 2, -1)
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, amb = 0.12, wrap = 0.25, cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
lm:each(function(x, y) local k = K(x, y) local f = inf[k]
  if bias[k] then return end
  if abs(f.da) * f.r < 0.6 and f.r > 1 and f.r < f.R - 1.5 then c:put(x, y, VEIN, ltok) return end
  -- side veins branching off each lobe midrib
  local off = abs(f.da) * f.r
  if off > 1.2 and off < f.R * 0.32 and abs((f.r - off * 1.3) % 6 - 3) < 0.5 and f.r < f.R - 2 then
    c:put(x, y, f.da < 0 and LEAF[5] or LEAF[2], ltok) end
end)
local rim = X.rim(ln)
lm:edge():each(function(x, y) local k = K(x, y) if not bias[k] and rim[k] > 0.25 and x > 20 and y > 44 then c:put(x, y, COOL, ltok) end end)
-- petiole stub at the base
local pt = G.path({ { 9, 59 }, { 11, 57 }, { 13, 55 } })
pt:cut(lm) pt:each(function(x, y) c:put(x, y, LEAF[4], ltok) end) c:put(10, 58, LEAF[5], ltok)

-- seeds: flat discs with a raised pale rim, face one tone down, dark notch at the tip
local function seedPaint(s, i)
  local tok = { r = { name = "seed" .. i } }
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) G.cast(sb, s.m, seeds[j].m, 1, 1, -1) end
  local e1, e2 = s.m:edge(), s.m:shrink(1):edge()
  vis:each(function(x, y) local k = K(x, y)
    local nn = s.n[k] local d = nn[1] + nn[2]
    local col
    if e1:has(x, y) then col = d < -0.15 and 4 or (d > 0.25 and 1 or 2)
    elseif e2:has(x, y) then col = d < -0.1 and 6 or (d > 0.35 and 3 or 5)
    else col = ((x - s[1]) + (y - s[2]) > 0.5) and 2 or 3 end
    if sb[k] then col = max(1, col - 2) end
    c:put(x, y, SEED[col], tok)
  end)
  -- hilum notch at the tip
  local tx, ty = floor(s[1] + cos(s[5]) * (s[3] - 0.6) + .5), floor(s[2] + sin(s[5]) * (s[3] - 0.6) + .5)
  if vis:has(tx, ty) then c:put(tx, ty, SEED[1], tok) end
  local tx2, ty2 = floor(s[1] + cos(s[5]) * (s[3] - 1.8) + .5), floor(s[2] + sin(s[5]) * (s[3] - 1.8) + .5)
  if vis:has(tx2, ty2) then c:put(tx2, ty2, SEED[2], tok) end
  -- glint on the rim, upper-left
  local bx, by = G.specAt(e2:clip(vis), s.n, 20)
  if bx then c:put(bx, by, "#fffbee", tok) end
end
seedPaint(seeds[1], 1) seedPaint(seeds[2], 2)

-- germination: root out of the tip, hooked hypocotyl rising to the seed-leaves
local s3 = seeds[3]
local tipx, tipy = s3[1] + cos(s3[5]) * s3[3], s3[2] + sin(s3[5]) * s3[3]
local hm, hn, HT = G.tube({ { tipx, tipy - 0.5 }, { tipx - 3, tipy - 6 }, { 30, 32 }, { 31.5, 25 } }, function(t) return 1.0 + 0.2 * (1 - t) end)
local htok = { r = { name = "hyp" } }
G.toneN(c, hm, hn, HYP, { tok = htok, amb = 0.15, wrap = 0.3 })
seedPaint(s3, 3)
local root = G.path({ { tipx - 0.5, tipy + 1 }, { tipx - 2, tipy + 3 }, { tipx - 1.5, tipy + 6 } })
root:each(function(x, y) c:put(x, y, (y % 2 == 0) and "#f4ecd2" or "#e3d6b0", { r = { name = "root" } }) end)
-- split in the germinated seed coat (it opened at the tip)
c:put(floor(tipx + 1.5), floor(tipy - 0.5), SEED[1])

-- seed-leaves: thick ovals, lit per pixel, midrib, AO where they meet the stem top
local cots = { { 24.5, 23.5, 6.6, 3.2, -0.3 }, { 38.5, 23, 6.6, 3.2, 0.28 } }
local cm = {}
for i, ct in ipairs(cots) do
  local m, n = G.oval(ct[1], ct[2], ct[3], ct[4], ct[5], 0.7)
  m:cut(hm)
  local b = {} X.ao(b, m, c:ellipse(31.5, 25, 1.5, 1.5), 1, -1)
  local tok = { r = { name = "cot" .. i } }
  local id = G.toneN(c, m, n, COT, { tok = tok, bias = b, amb = 0.12, wrap = 0.3 })
  local ca, sa = cos(ct[5]), sin(ct[5])
  m:each(function(x, y) local dx, dy = x - ct[1], y - ct[2]
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if abs(v) < 0.5 and abs(u) < ct[3] - 1.5 then c:put(x, y, COT[max(1, (id[K(x, y)] or 3) - 1)], tok) end
  end)
  cm[i] = m
end
-- first true leaf: small palmate, lobed + toothed, on a short petiole between the seed-leaves
local tl, tn, ti = G.palm(32.5, 19.5, { { -1.5, 9.5 }, { -2.3, 7.5 }, { -0.75, 7.5 }, { -3.0, 5 }, { -0.05, 5 } }, { sharp = 2.2, floor = 0.33, spread = 2.4, serr = true, hole = 0.6 })
local ttb = {} X.ao(ttb, tl, cm[1], 1, -1) X.ao(ttb, tl, cm[2], 1, -1)
tl:cut(cm[1]) tl:cut(cm[2])
local ttok = { r = { name = "true" } }
G.toneN(c, tl, tn, LEAF, { tok = ttok, bias = ttb, amb = 0.15, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
tl:each(function(x, y) local f = ti[K(x, y)] if abs(f.da) * f.r < 0.5 and f.r > 1 and f.r < f.R - 1.2 then c:put(x, y, LEAF[6], ttok) end end)
for y = 20, 24 do c:put(32, y, HYP[3], ttok) c:put(31, y, HYP[4], ttok) end

-- quirk: the empty seed coat sits on the tip of the right seed-leaf like a hat
local hx, hy = 44.5, 20.5
local hat, hn2 = G.drop(hx, hy, 3.4, 2.4, 0.3 - pi, 0.6)
hat:cut(G.oval(42.2, 22, 2.2, 1.6, 0.3)) -- hollow side faces the leaf
local htk = { r = { name = "hat" } }
G.toneN(c, hat, hn2, SEED, { tok = htk, amb = 0.15, wrap = 0.3 })
hat:edge():each(function(x, y) if (x - hx) + (y - hy) > 1 then c:put(x, y, SEED[2], htk) end end)
c:put(floor(hx + 1), floor(hy - 1), "#fffbee", htk)

-- centre the drawing (bbox incl. the outline-to-be)
do local x0, y0, x1, y1 = 99, 99, -1, -1
  for i in pairs(c.pix) do local x, y = i % 64, i // 64 x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  x0, y0, x1, y1 = x0 - 1, y0 - 1, x1 + 1, y1 + 1
  G.shift(c, floor((64 - (x1 - x0 + 1)) / 2) - x0, floor((64 - (y1 - y0 + 1)) / 2) - y0)
end
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = G.out .. "pumpkin-seed.aseprite", png = G.out .. "pumpkin-seed.png", scale = 1 }
