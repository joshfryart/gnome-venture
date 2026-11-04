-- columbine-seed (Opus single pass). Glossy jet-black columbine seeds (small teardrops, violet sheen, bright glints)
-- trailing across a torn, scalloped columbine leaflet (sage blue-green, palmate veins from the base, purple-flushed
-- shade margin, AO and contact shadow under each seed). One seed has sprouted: thin red stem, two narrow cotyledons
-- and a first true leaf in the columbine shape: three round, three-lobed leaflets on wiry stalks.
-- quirk: the dry papery seed pod (horned follicles, one split open) lies tipped over, still spilling seeds.
local NAME = "columbine-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = G.new2(NAME)

local LF = { "#22203a", "#2f3d50", "#435f5a", "#5f8468", "#88a87a", "#bad09c" }
local FLUSH, VEIN = "#7a527e", "#d2e2b0"
local BLK = { "#110b15", "#1d1623", "#2c2335", "#433a52", "#6c6284", "#b6aecb" }
local STEM = { "#4e2236", "#7e3a4a", "#ad6464", "#dc9c8a" }
local CT = { "#1d3d30", "#2c5c3c", "#43804a", "#64a256", "#90c26a", "#c4e08e" }
local POD = { "#5a3c2c", "#8a6142", "#b38b5c", "#d6b47e", "#f0dcaa", "#fff0cc" }

-- leaflet scrap: wide fan, three shallow scalloped lobes on top, torn on the left
local BX, BY = 38, 57                       -- leaf base (veins radiate from here)
local lm = c:ellipse(36, 48, 17.5, 7.5)
lm:add(c:ellipse(29, 45, 8, 6)):add(c:ellipse(42.5, 44.5, 8, 6.5))
-- deep-ish sinuses between lobes and crenate scallops along the top
lm:cut(c:ellipse(36, 37.2, 1.5, 2.4))
for _, s in ipairs{ { 23.5, 40.5 }, { 31.5, 38.6 }, { 41, 38.6 }, { 48.5, 39.6 }, { 52.5, 43.5 } } do lm:cut(c:ellipse(s[1], s[2], 1.2, 1.2)) end
G.tear(lm, function(x, y) return x - (20 - (y - 48) * 0.6) end, 1.8, 2, 5)
local lnn = X.pillow(lm, 4)
-- slight dome toward the centre of the leaf
for k, nn in pairs(lnn) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  lnn[k] = { G.norm(nn[1] + (x - 36) / 60, nn[2] + (y - 47) / 30, nn[3]) }
end

-- seeds (positions), pod, sprout: masks first so the leaf gets AO and contact shadows
local seeds = { { 24, 47, 0.5 }, { 28.5, 50, -0.3 }, { 31, 45.5, 0.9 }, { 35, 50.5, 0.2 }, { 47, 50, -0.6 } }
local smask = {}
for i, s in ipairs(seeds) do smask[i] = G.oval(s[1], s[2], 2.0, 1.45, s[3], 0.9) end
local SPX, SPY = 41.5, 46
local spm = G.oval(SPX, SPY, 2.1, 1.5, -0.4, 0.9)

-- pod: three papery follicles, fanned, lying on the left (tipped over)
local pods = {
  { 9, 41, 19, 45, 6, 37, 2.6 },
  { 10, 44, 20, 47, 5, 47, 2.4 },
  { 11, 40, 19, 41, 11, 33, 2.2 },
}
local podm = HP.mask()
local pn, PT, PS = {}, {}, {}
for _, p in ipairs(pods) do
  local m, n, T, S = X.cyl(p[3], p[4], p[5], p[6], function(t) return p[7] * sin(pi * min(1, 0.15 + t * 0.85)) ^ 0.6 end)
  podm:add(m) for k, v in pairs(n) do pn[k] = v PT[k] = T[k] PS[k] = S[k] end
end

local bias = {}
for _, m in ipairs(smask) do X.ao(bias, lm, m, 1, -1) G.cast(bias, lm, m, 1, 1, -1) end
X.ao(bias, lm, spm, 1, -1) G.cast(bias, lm, spm, 1, 1, -1)
X.ao(bias, lm, podm, 1, -1) G.cast(bias, lm, podm, 1, 2, -1)
local ltok = { r = { name = "leaf" } }
local lidx = X.tone(c, lm, X.light(lnn, { amb = 0.12, wrap = 0.3 }), LF, { cuts = { 0.08, 0.22, 0.4, 0.58, 0.8 }, bias = bias, tok = ltok })
-- palmate veins from the base: 5 rays
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local dx, dy = x - BX, y - BY
  local d = sqrt(dx * dx + dy * dy)
  if d < 2 or d > 16 then return end
  local a = atan(dy, dx)
  for _, ra in ipairs{ -2.55, -2.05, -1.57, -1.1, -0.6 } do
    if abs(a - ra) * d < 0.55 then c:put(x, y, (dx < 0 and (lidx[k] or 3) >= 3) and VEIN or LF[min(6, (lidx[k] or 3) + 1)], ltok) end
  end
end)
-- purple flush on the shade-side margin
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and (lidx[k] or 1) <= 3 and (x > 36 or y > 52) then c:put(x, y, FLUSH, ltok) end end)
-- torn fibres on the left tear
lm:edge():each(function(x, y) if x < 22 and X.hash(x, y, 8) > 0.5 then c:put(x, y, LF[5], ltok) end end)

-- pod: papery follicles with long-axis ribs and hooked beaks, one split open
local ptok = { r = { name = "pod" } }
local pidx = X.tone(c, podm, X.light(pn, { amb = 0.2, wrap = 0.35 }), POD, { cuts = { 0.24, 0.42, 0.6, 0.76, 0.9 }, tok = ptok })
podm:each(function(x, y) local k = K(x, y)
  if abs(PS[k] + 0.1) < 0.12 and PT[k] > 0.15 and PT[k] < 0.9 then c:put(x, y, POD[max(1, (pidx[k] or 3) - 2)], ptok) end end)
-- split follicle: dark open seam showing a seed inside
for _, p in ipairs{ { 13, 45 }, { 14, 45 }, { 15, 46 }, { 16, 46 }, { 17, 46 } } do c:put(p[1], p[2], BLK[2], ptok) end
c:put(15, 45, BLK[5], ptok)
-- hooked beaks (thin, curled)
for _, p in ipairs{ { 5, 36, 3 }, { 4, 35, 4 }, { 4, 34, 5 }, { 10, 32, 3 }, { 9, 31, 4 }, { 4, 47, 3 }, { 3, 46, 4 } } do c:put(p[1], p[2], POD[p[3]], ptok) end
-- dry stalk stub at the right end of the pod
for _, p in ipairs{ { 20, 42, 2 }, { 21, 42, 3 }, { 22, 41, 2 } } do c:put(p[1], p[2], POD[p[3]], ptok) end

-- sprout stem (thin, red), cotyledons, ternate true leaf
local stok = { r = { name = "stem" } }
local sp = { { 41, 45 }, { 39, 37 }, { 43, 29 }, { 41, 22 } }
local sm, sn = G.tube(sp, function(t) return 0.95 end)
sm:cut(spm)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })

local ctok = { r = { name = "cot" } }
local function cot(ax, ay, bx, by)
  local m, n, T, S = G.blade(ax, ay, (ax + bx) / 2, (ay + by) / 2 - 1, bx, by, function(t)
    if t > 0.98 then return -1 end
    return max(0.4, 1.5 * sin(pi * min(1, 0.1 + t * 0.9)) ^ 0.5)
  end, { fold = 0.3 })
  m:cut(sm)
  G.toneN(c, m, n, CT, { tok = ctok, amb = 0.14, wrap = 0.3, cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 } })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.15 and T[k] > 0.15 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and CT[6] or CT[3], ctok) end end)
  return m
end
cot(40, 34, 32, 31)
cot(42, 33, 50, 29)

-- wiry leaflet stalks
local wires = { { { 41, 22 }, { 41, 19 }, { 41, 17 } }, { { 41, 22 }, { 39, 21 }, { 37, 21 } }, { { 41, 22 }, { 44, 21 }, { 46, 20 } } }
for _, w in ipairs(wires) do for _, p in ipairs(w) do c:put(p[1], p[2], STEM[3], stok) end end
-- three round leaflets, each cut into three lobes
local tl = HP.mask()
local function leaflet(cx, cy, r, ang)
  local m = c:ellipse(cx, cy, r, r * 0.9)
  -- two sinuses on the outer edge (direction ang)
  for _, da in ipairs{ -0.62, 0.62 } do
    local a = ang + da
    m:cut(c:ellipse(cx + cos(a) * (r + 0.6), cy + sin(a) * (r + 0.6), 0.9, 0.9))
  end
  return m
end
local L = {
  { 41, 13, 3.6, -pi / 2 },
  { 34.5, 19, 3.2, pi * 1.1 },
  { 48, 18, 3.2, -0.15 },
}
local LV = {}
for _, q in ipairs(L) do
  local m = leaflet(q[1], q[2], q[3], q[4])
  local n = X.sphere(q[1] - 0.6, q[2] - 0.6, q[3] + 1.5, m)
  local idx = G.toneN(c, m, n, CT, { tok = ctok, amb = 0.12, wrap = 0.3, cuts = { 0.24, 0.42, 0.6, 0.76, 0.9 } })
  -- three short veins from the stalk point into the lobes
  local sx, sy = q[1] - cos(q[4]) * q[3], q[2] - sin(q[4]) * q[3]
  for _, da in ipairs{ -0.7, 0, 0.7 } do
    for s = 1, floor(q[3] * 1.4) do
      local x = floor(sx + cos(q[4] + da) * s + 0.5) local y = floor(sy + sin(q[4] + da) * s + 0.5)
      if m:has(x, y) then c:put(x, y, (idx[K(x, y)] or 4) >= 4 and CT[6] or CT[4], ctok) end
    end
  end
  tl:add(m)
end

-- seeds last: jet black, glossy (two glints allowed), AO between pod and first seed
local function seed(m, cx, cy, ang, tok)
  local n = select(2, G.oval(cx, cy, 2.0, 1.45, ang, 0.9))
  G.toneN(c, m, n, BLK, { tok = tok, amb = 0.08, wrap = 0.2, cuts = { 0.24, 0.42, 0.6, 0.78, 0.92 } })
  local bx, by = G.specAt(m, n, 30)
  if bx then c:put(bx, by, "#fff4d6", tok) end
end
for i, s in ipairs(seeds) do seed(smask[i], s[1], s[2], s[3], { r = { name = "seed" .. i } }) end
seed(spm, SPX, SPY, -0.4, { r = { name = "sprout" } })
c:put(41, 44, STEM[3], stok)
-- violet sheen on the shade rim of the big front seed
c:put(36, 52, "#5a4a7a", { r = { name = "seed4" } })

G.save2(c, NAME)
