-- african-tulip-tree-seed (final pass, Opus). Spathodea seeds: a small flat brown seed body inside a broad papery,
-- heart-notched wing. Two lie overlapping on a torn, glossy, dark Spathodea leaflet (elliptic, drawn-out tip, pale
-- midrib, looping laterals, a specular sheen streak on the lit half, cool reflected edge, torn base). The wings are
-- translucent: where they lie over the leaf they take a green-cream tint, with fine radial striations and a darker
-- curled rim. The front seed has germinated: a slim stem with the family's bilobed (notched) cotyledons and the first
-- pinnate leaf (two pairs of pointed leaflets + a terminal one) that shows the tree's compound leaf.
-- quirk: a third winged seed is still gliding down, tilted in mid-air at the upper left.
local NAME = "african-tulip-tree-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR1_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)

local LEAF  = { "#12332f", "#1a4a38", "#23633f", "#327f45", "#4f9c4c", "#7fbd5e" }
local SHEEN, VEIN, COOL, TORN = "#b5df8a", "#a9cf7c", "#356470", "#a8cf84"
local WING  = { "#6a6474", "#8f889c", "#b3acbc", "#d2ccd4", "#e9e4e4", "#f8f4ec" }
local WINGL = { "#56685e", "#7a8e82", "#9fb3a4", "#c1d2c0", "#dde8d6", "#eef4e6" }  -- seen over the leaf
local SEED  = { "#3a221e", "#57351f", "#7a4f2a", "#9c6c38", "#bf8e50", "#dfb476" }
local STEM  = { "#3d744a", "#68a35a", "#9fcc80", "#d2ecaa" }
local SLEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }

-- leaf scrap: torn base at the right (t=0), tip to the lower left (t=1)
local lm, ln, LT, LS, len = A.blade(57, 51, 32, 46, 6, 43, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 6.6 * sin(pi * (0.17 + 0.83 * t ^ 1.15)) ^ 0.7)
end, { fold = 0.4 })
A.tear(lm, LT, 0.02, 0.08, 4)

-- winged seed geometry: wing oval with a notch at the hilum end, seed body offset toward the notch
local function wseed(cx, cy, rx, ry, ang)
  local m, n = A.ovalM(cx, cy, rx, ry, ang, 0.35)
  local ca, sa = cos(ang), sin(ang)
  local cut = {}
  m:each(function(x, y)
    local dx, dy = x - cx, y - cy
    local u, v = (dx * ca + dy * sa) / rx, (-dx * sa + dy * ca) / ry
    if u > 0.45 and abs(v) < (u - 0.45) * 1.3 then cut[#cut + 1] = { x, y } end           -- heart notch
    if X.hash(x, y, 21) > 0.93 and u * u + v * v > 0.8 then cut[#cut + 1] = { x, y } end  -- ragged papery margin
  end)
  for _, p in ipairs(cut) do m.s[K(p[1], p[2])] = nil end
  local bcx, bcy = cx + ca * rx * 0.18, cy + sa * rx * 0.18
  local bm, bn = A.ovalM(bcx, bcy, 3.0, 2.0, ang, 0.8)
  return { m = m, n = n, cx = cx, cy = cy, rx = rx, ry = ry, ang = ang, bm = bm, bn = bn, bcx = bcx, bcy = bcy }
end
local S1 = wseed(20, 46, 7.2, 4.4, 0.3)
local S2 = wseed(35, 47, 7.4, 4.5, -0.3)
local S3 = wseed(13, 16, 6.0, 3.6, -0.75)

-- leaf tone, with AO + cast shadow from the seeds
local all = S1.m:copy():add(S2.m)
local bias = {}
X.ao(bias, lm, all, 1, -1) A.cast(bias, lm, all, 1, 2, -1) A.cast(bias, lm, all, 2, 1, -1)
local ltok = A.tok("leaf")
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, amb = 0.06, wrap = 0.22 })
A.veins(c, lm, LT, LS, len, LEAF, VEIN, { tok = ltok, skip = bias, per = 7.0, sweep = 5.0, t0 = 0.03, t1 = 0.94, hiV = 4, reach = 0.8 })
-- glossy sheen streak on the lit half
lm:each(function(x, y) local k = K(x, y)
  local s, t = LS[k], LT[k]
  if not bias[k] and s < -0.38 and s > -0.58 and t > 0.25 and t < 0.55 and X.hash(x, y, 2) > 0.25 then c:put(x, y, SHEEN, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LT[k] < 0.12 then c:put(x, y, TORN, ltok)
  elseif LS[k] > 0.62 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)

-- winged seed painter
local function paint(S, i, over, cover)
  local tok = A.tok("wseed" .. i)
  local m = S.m:copy() if cover then m:cut(cover) end
  local ca, sa = cos(S.ang), sin(S.ang)
  local wb = {}
  X.ao(wb, m, S.bm, 1, -1)
  m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - S.cx, y - S.cy
    local u, v = (dx * ca + dy * sa) / S.rx, (-dx * sa + dy * ca) / S.ry
    local r = sqrt(u * u + v * v)
    -- radial striations fanning out from the seed body
    local a = atan(v * S.ry, (u - 0.28) * S.rx)
    if r > 0.42 and (a * 4.2) % 1 < 0.26 then wb[k] = (wb[k] or 0) - 1 end
    if r > 0.84 then wb[k] = (wb[k] or 0) - 1 end            -- curled rim
    if r > 0.86 and v > -0.2 then wb[k] = (wb[k] or 0) - 1 end
  end)
  local idxs = {}
  local v = X.light(S.n, { amb = 0.22, wrap = 0.35 })
  local mo, mf = HP.mask(), HP.mask()
  m:each(function(x, y) if over and over:has(x, y) then mo:set(x, y) else mf:set(x, y) end end)
  X.tone(c, mf, v, WING, { cuts = A.CUTS, bias = wb, tok = tok })
  X.tone(c, mo, v, WINGL, { cuts = A.CUTS, bias = wb, tok = tok })
  -- separation: wing edge one tone darker where it lies on the leaf (or on the other wing)
  m:edge():each(function(x, y)
    local inside = false
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
      local xx, yy = x + d[1], y + d[2]
      if not m:has(xx, yy) and (c.own[yy * c.w + xx] ~= nil) then inside = true end
    end
    if inside then c:put(x, y, (over and over:has(x, y)) and WINGL[2] or WING[2], tok) end
  end)
  -- seed body
  local bm = S.bm:copy() if cover then bm:cut(cover) end
  A.shade(c, bm, S.bn, SEED, { tok = tok, amb = 0.05, wrap = 0.2 })
  local sx, sy = A.specAt(bm, S.bn, 25)
  if sx then c:put(sx, sy, SEED[6], tok) end
  -- hilum notch line
  local hx, hy = floor(S.bcx + ca * 2.2 + .5), floor(S.bcy + sa * 2.2 + .5)
  if bm:has(hx, hy) then c:put(hx, hy, SEED[1], tok) end
end
paint(S1, 1, lm, S2.m)
paint(S2, 2, lm)
paint(S3, 3, nil)
-- bright wing glint on the gliding seed (catches the light)
c:put(10, 13, "#fff4d6")

-- sprout from the front seed body: stem, bilobed cotyledons, first pinnate leaf
local stok, ltok2 = A.tok("stem"), A.tok("sleaf")
local SP = { { 34, 45 }, { 33, 37 }, { 36, 30 }, { 35, 20 } }
local sm, sn = A.tube(SP, function(t) return 1.0 + 0.15 * (1 - t) end)
sm:cut(S2.bm)
-- cotyledons: two kidney lobes each, notched at the outer end
local cots = HP.mask()
local function cot(cx, cy, dir)
  local m = A.rell(cx, cy - 1.0, 1, -0.3 * dir, 3.4, 1.7)
  m:add(A.rell(cx, cy + 1.4, 1, 0.25 * dir, 3.4, 1.6))
  m:add(A.rell(cx + 2.0 * dir, cy + 0.2, 1, 0, 2.0, 2.0))
  local nx = floor(cx - 3.0 * dir + .5)
  for _, d in ipairs{ { 0, 0 }, { dir, 0 }, { 0, 1 } } do m.s[K(nx + d[1], floor(cy + .5) + d[2])] = nil end
  cots:add(m)
  return m
end
local cl, cr = cot(28, 31, 1), cot(43, 30, -1)
local pin, lfl = HP.mask(), {}
for _, q in ipairs{ { 35, 25, -0.9, -0.42, 8.0 }, { 35, 25, 0.9, -0.42, 8.0 }, { 35, 18, -0.84, -0.54, 6.8 }, { 35, 18, 0.84, -0.54, 6.8 }, { 35, 15, 0.04, -1, 7.6 } } do
  local ax, ay, L = q[1] + q[3] * 0.8, q[2] + q[4] * 0.8, q[5]
  local bx, by = ax + q[3] * L, ay + q[4] * L
  local cx, cy = (ax + bx) / 2 - q[4] * 0.0, (ay + by) / 2 - 0.9
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.35, 1.85 * sin(pi * min(1, t ^ 0.8 * 0.95 + 0.05)) ^ 0.6)
  end, { fold = 0.3 })
  m:cut(pin)
  lfl[#lfl + 1] = { m = m, n = n, T = T, S = S }
  pin:add(m)
end
pin:cut(sm)
cots:cut(sm)
-- stem
A.shade(c, sm, sn, STEM, { tok = stok, cuts = { 0.28, 0.52, 0.76 }, amb = 0.15, wrap = 0.3 })
-- cotyledons: pillow light, a notch line in the middle, AO where they meet the stem
local cb = {} X.ao(cb, cots, sm, 1, -1)
A.toneN(c, cots, X.pillow(cots, 1.6), SLEAF, { tok = ltok2, bias = cb, cuts = A.CUTS, amb = 0.12, wrap = 0.3 })
-- pinnate leaf: leaflets with a midrib each, rachis on top
for i, f in ipairs(lfl) do
  f.m:cut(sm)
  local pb = {} X.ao(pb, f.m, sm, 1, -1)
  for j = i + 1, #lfl do X.ao(pb, f.m, lfl[j].m, 1, -1) end
  A.toneN(c, f.m, f.n, SLEAF, { tok = ltok2, bias = pb, cuts = A.CUTS, amb = 0.12, wrap = 0.3 })
  f.m:each(function(x, y) local k = K(x, y)
    if abs(f.S[k]) < 0.16 and f.T[k] > 0.12 and f.T[k] < 0.85 and not pb[k] then c:put(x, y, f.S[k] <= 0 and SLEAF[6] or SLEAF[3], ltok2) end end)
end
-- radicle tip peeking out under the front wing


A.save(c, NAME)
