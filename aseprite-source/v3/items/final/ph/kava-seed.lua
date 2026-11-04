-- kava-seed (final, Opus single pass). Two glossy ovoid kava seeds on a torn scrap of kava leaf (cordate, deep
-- green, palmate veins fanning from the notch, V-fold light, pale ragged tear edge on the right, AO + contact shadow
-- under the seeds). A third seed has split and sent up a slim jointed stem with two round cotyledons and a first
-- heart-shaped true leaf (kava's leaf shape, palmate veins, waxy specular).
-- quirk: the seedling stem already has kava's knuckled nodes, each freckled with a purple speck.
local NAME = "kava-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local LEAF = { "#163a33", "#1f5240", "#2b6c47", "#3f8a4c", "#62a854", "#97c96a" }
local VEIN, TORN, COOL = "#b8dc86", "#d6e49a", "#33666e"
local SEED = { "#2e1a1e", "#4c2a22", "#6e3f2a", "#935a34", "#b97c46", "#e0ad6c" }
local STEM = { "#3d6e45", "#5f9452", "#8cbc68", "#c3e09a" }
local NODE, SPECK = "#7c5a6e", "#7a3f8a"

-- palmate veins painter for a heart mask
local function veins(m, notch, ang, n, len, tok, skip)
  local dirs = { 0, -0.62, 0.62, -1.2, 1.2 }
  for i = 1, n do
    local a = ang + dirs[i]
    local dx, dy = -sin(a), cos(a)     -- local "down" rotated
    local x, y = notch[1] + dx * 1.2, notch[2] + dy * 1.2
    for s = 0, len do
      local bend = dirs[i] * 0.012 * s
      local ex, ey = -sin(a + bend), cos(a + bend)
      x, y = x + ex * 0.9, y + ey * 0.9
      local xi, yi = floor(x + .5), floor(y + .5)
      if not m:has(xi, yi) then break end
      if not (skip and skip[K(xi, yi)]) then
        c:put(xi, yi, (i == 1 or s < len * 0.5) and VEIN or LEAF[5], tok)
        if m:has(xi + 1, yi + 1) and not (skip and skip[K(xi + 1, yi + 1)]) and i == 1 then c:put(xi + 1, yi + 1, LEAF[3], tok) end
      end
    end
  end
end

-- leaf scrap: kava heart leaf lying tilted, tip to the lower left, right lobe torn away
local LA = 0.5
local lm, LU, LV, lnotch = A.heart(31, 45, 14.5, LA, 0.95, 0.9)
local torn = A.tear(lm, 45, 44, 1, -0.25, 1.4, 3)
local seeds = { { 22, 46, 3.6, 2.4, 0.5 }, { 31, 50, 3.4, 2.3, -0.35 }, { 37, 40, 3.2, 2.2, 0.2 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local fold = {}
lm:each(function(x, y) local k = K(x, y) local v = LV[k]
  local f = (v < 0 and -0.45 or 0.45) * min(1, abs(v) * 3)
  local ca, sa = cos(LA), sin(LA)
  fold[k] = { A.norm(f * ca, f * sa, 1) } end)
local ln = A.blend(lm, { { X.pillow(lm, 2.5), 1 }, { X.sphere(30, 42, 18, lm), 0.6 }, { fold, 0.8 } })
local ltok = { r = { name = "leaf" } }
A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.15, wrap = 0.3 })
veins(lm, lnotch, LA, 5, 18, ltok, bias)
torn:each(function(x, y) c:put(x, y, TORN, ltok) end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not torn:has(x, y) and not bias[k] and LV[k] > 0.25 and LU[k] > 0.45 then c:put(x, y, COOL, ltok) end end)
-- petiole stub at the notch
do local x, y = floor(lnotch[1] + .5), floor(lnotch[2] + .5)
  for i = 0, 3 do c:put(x + i, y - i, i < 2 and LEAF[4] or LEAF[3], ltok) c:put(x + i + 1, y - i, LEAF[2], ltok) end end

-- sprout from seed 3: slim knuckled stem
local stok = { r = { name = "stem" } }
local sp = { { 37, 39 }, { 39, 32 }, { 35, 25 }, { 36, 17 } }
local sm, sn, ST = A.tube(sp, function(t) return 1.15 end)
sm:cut(seeds[3].m)
local sidx = X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- nodes: a darker swollen ring + purple freckle (quirk)
for _, t in ipairs{ 0.3, 0.62 } do
  local x, y = A.bez(sp, t)
  local xi, yi = floor(x + .5), floor(y + .5)
  for dx = -2, 2 do local px = xi + dx
    if abs(dx) == 2 then c:put(px, yi, STEM[2], stok) else c:put(px, yi, NODE, stok) end end
  c:put(xi - 1, yi - 1, STEM[4], stok)
  c:put(xi + 1, yi + 1, SPECK, stok)
end
-- cotyledons: two round seed leaves
local ctok = { r = { name = "cot" } }
for _, q in ipairs{ { 31, 28, -0.5 }, { 42, 27, 0.4 } } do
  local m, n = A.oval(q[1], q[2], 3.6, 2.0, q[3], 0.8)
  m:cut(sm)
  A.shade(c, m, n, LEAF, { tok = ctok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, amb = 0.18, wrap = 0.3 })
  local ux, uy = cos(q[3]), sin(q[3])
  for i = -1, 1 do c:put(floor(q[1] + ux * i + .5), floor(q[2] + uy * i + .5), LEAF[4], ctok) end
end
-- first true leaf: small kava heart, notch on the stem tip, tilted to the right
local hm, HU, HV, hnotch = A.heart(40, 15, 5.2, -2.1, 0.95, 0.95)
local hfold = {}
hm:each(function(x, y) local k = K(x, y) local f = (HV[k] < 0 and -0.5 or 0.5) * min(1, abs(HV[k]) * 3)
  hfold[k] = { A.norm(f * cos(-2.1), f * sin(-2.1), 1) } end)
local hn = A.blend(hm, { { X.pillow(hm, 2), 1 }, { X.sphere(40, 13, 9, hm), 0.5 }, { hfold, 0.8 } })
local htok = { r = { name = "tleaf" } }
A.shade(c, hm, hn, LEAF, { tok = htok, cuts = { 0.16, 0.3, 0.46, 0.62, 0.8 }, amb = 0.15, wrap = 0.3 })
veins(hm, hnotch, -2.1, 3, 9, htok)
do local bx, by = A.specAt(hm, hn, 30) if bx then c:put(bx, by, "#e6f4b4", htok) end end

-- seeds last: glossy ovoids, pale hilum, AO between neighbours; seed 3 split open at the top
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local b = {}
  if i == 3 then X.ao(b, s.m, sm, 1, -1) end
  local idx = A.shade(c, s.m, s.n, SEED, { tok = tok, bias = b, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.1, wrap = 0.3 })
  local ca, sa = cos(s[5]), sin(s[5])
  -- hilum: pale scar at the lower-right end
  local hx, hy = floor(s[1] + ca * (s[3] - 0.6) + .5), floor(s[2] + sa * (s[3] - 0.6) + .5)
  if s.m:has(hx, hy) then c:put(hx, hy, "#d9c08e", tok) end
  -- cool reflected light on the lower edge
  s.m:edge():each(function(x, y) if (x - s[1]) * 0.6 + (y - s[2]) > s[4] - 0.3 then c:put(x, y, "#5a4a62", tok) end end)
  local bx, by = A.specAt(s.m, s.n, 40)
  if bx then c:put(bx, by, A.CREAM, tok) end
end
-- split seed coat lips around the stem foot
c:put(35, 38, SEED[5]) c:put(39, 38, SEED[3])
A.save(c, NAME)
