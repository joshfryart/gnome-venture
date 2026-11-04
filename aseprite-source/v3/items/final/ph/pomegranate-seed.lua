-- pomegranate-seed (D10, single pass). A torn scrap of glossy pomegranate leaf (smooth lance, red midrib, pinnate veins,
-- ragged torn end with pale fibres, bronze tip) carrying two faceted ruby arils (translucent: warm glow on the shade edge,
-- the pale hard seed showing through; one aril split open) and one bare hard seed that has sprouted: a red stem, two
-- opposite pairs of narrow leaves (older pair green, newest pair bronze) and a closed bud.
-- quirk: the seedling still wears a cracked seed coat on its head like a tiny cap.
local NAME = "pomegranate-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD10_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local LEAF = { "#183a30", "#245a3a", "#35794a", "#4f9a52", "#78bb5c", "#aedc78" }
local BRZ  = { "#3e1c22", "#6e2c2c", "#9a4430", "#bf6836", "#e0944a", "#f8c47c" }
local RUBY = { "#4e1630", "#8a2040", "#c0303f", "#e8493b", "#ff7a5c", "#ffb89a" }
local SEEDC = { "#6e4a38", "#9a6e4c", "#c89a68", "#e6c08a", "#f6dcaa", "#fff0cc" }
local STEM = { "#4e1630", "#8a2040", "#b53a48", "#d8605a", "#f08a70", "#ffbfa0" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local ltok = { r = { name = "leaf" } }

-- aril and seed masks first (so the leaf can receive their contact shadow)
local function gem(cx, cy, rx, ry, ang, salt)
  local pts = {}
  for j = 0, 6 do
    local a = j / 7 * 2 * pi + ang
    local r = 0.86 + 0.3 * X.hash(j, salt, 5)
    pts[#pts + 1] = { cx + cos(a) * rx * r * 1.1, cy + sin(a) * ry * r * 1.1 }
  end
  local m = HP.mask()
  for y = floor(cy - ry - 3), floor(cy + ry + 3) do for x = floor(cx - rx - 3), floor(cx + rx + 3) do
    local px, py, inside = x + 0.5, y + 0.5, false
    local j = #pts
    for i = 1, #pts do
      local a, b = pts[i], pts[j]
      if (a[2] > py) ~= (b[2] > py) and px < (b[1] - a[1]) * (py - a[2]) / (b[2] - a[2]) + a[1] then inside = not inside end
      j = i
    end
    if inside then m:set(x, y) end
  end end
  return m
end
local arils = { { 15.5, 49.2, 4.4, 3.2, 0.45, 1 }, { 28.5, 48.6, 4.5, 3.3, -0.35, 2 } }
local seed3 = { 41, 45.6, 4.3, 2.8, -0.38, 3 }
for _, a in ipairs(arils) do a.m = gem(a[1], a[2], a[3], a[4], a[5], a[6]) end
seed3.m = gem(seed3[1], seed3[2], seed3[3], seed3[4], seed3[5], seed3[6])
local allSeeds = HP.mask() for _, a in ipairs(arils) do allSeeds:add(a.m) end allSeeds:add(seed3.m)

-- leaf scrap
local HW = 5.3
local lm, ln, LT, LS, len = G.blade(8, 51, 26, 54, 57, 42, function(t)
  if t > 0.99 then return -1 end
  return max(0.45, HW * sin(pi * min(1, 0.04 + 0.96 * t)) ^ 0.62)
end, { fold = 0.34 })
local tear = {}
local U = {}
lm:each(function(x, y) local k = K(x, y)
  local u, v = LT[k] * len, LS[k] * HW
  U[k] = u
  local umin = 3.4 + 1.5 * v * 0.55 + 2.6 * X.hash(floor(v * 0.8 + 6), 2, 7)
  if v > 3.2 then umin = umin + 1.2 end
  if u < umin then tear[#tear + 1] = k end
end)
for _, k in ipairs(tear) do lm.s[k] = nil end
-- a little bite out of the lower margin
for _, p in ipairs{ { 33, 55 }, { 34, 55 }, { 34, 56 }, { 35, 56 }, { 33, 54 }, { 34, 54 } } do lm:cut(HP.mask():set(p[1], p[2])) end
local bias = {}
for _, a in ipairs(arils) do X.ao(bias, lm, a.m, 1, -1) G.cast(bias, lm, a.m, 1, 2, -1) G.cast(bias, lm, a.m, 2, 3, -1) end
X.ao(bias, lm, seed3.m, 1, -1) G.cast(bias, lm, seed3.m, 1, 2, -1)
local idx = G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.18, wrap = 0.3 })
local VT = { 5, 8.5, 12, 15.5, 19, 22.5, 26, 29.5, 33, 36.5, 40, 43.5 }
lm:each(function(x, y) local k = K(x, y)
  local s, t = LS[k], LT[k]
  local u = t * len
  -- bronze tip
  if t > 0.91 + 0.04 * X.hash(x, y, 4) then c:put(x, y, BRZ[idx[k]], ltok) end
  if bias[k] then return end
  if abs(s) < 0.14 and u > 4 and t < 0.97 then c:put(x, y, s <= 0 and "#f0a07c" or "#a8503c", ltok) return end
  for _, vt in ipairs(VT) do
    local d = u - (vt + abs(s) * 4.6)
    if d > -0.55 and d < 0.55 and abs(s) > 0.2 and abs(s) < 0.8 and t < 0.9 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
  end
  -- torn fibres
  if U[k] and U[k] < 8.2 then
    local lx = lm:has(x - 1, y) local ly = lm:has(x, y - 1) local lz = lm:has(x, y + 1) local lw = lm:has(x - 1, y)
    if not (lx and ly and lz) and X.hash(x, y, 8) > 0.6 then c:put(x, y, s < 0 and "#e4f2a8" or "#a8cc78", ltok) end
  end
end)
-- cool reflected light on the lower margin
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.22 and LT[k] < 0.78 then c:put(x, y, "#2c6a6a", ltok) end end)

-- faceted ruby aril
local function drawAril(a, split)
  local n = X.pillow(a.m, 2.6)
  local tilt = {}
  for i = 0, 5 do tilt[i] = { X.hash(i, a[6], 1) * 2 - 1, X.hash(i, a[6], 2) * 2 - 1 } end
  local cx, cy = a[1], a[2]
  a.m:each(function(x, y) local k = K(x, y)
    local ang = math.atan(y + 0.5 - cy, x + 0.5 - cx)
    local sec = floor((ang + pi) / (2 * pi) * 6) % 6
    local t = tilt[sec]
    local q = n[k]
    n[k] = { G.nrm(q[1] + 0.45 * t[1], q[2] + 0.45 * t[2], q[3]) }
  end)
  local tok = { r = { name = "aril" .. a[6] } }
  local ib = {}
  X.ao(ib, a.m, allSeeds:copy():cut(a.m), 1, -1)
  local ix = X.tone(c, a.m, X.light(n, { amb = 0.12, wrap = 0.25 }), RUBY, { cuts = CUTS, tok = tok, bias = ib })
  -- translucent warm glow on the shade edge
  local rim = X.rim(n)
  a.m:edge():each(function(x, y) if rim[K(x, y)] > 0.62 and not ib[K(x, y)] then c:put(x, y, "#ff9a62", tok) end end)
  -- pale hard seed showing through
  local ca, sa = cos(a[5] + 0.5), sin(a[5] + 0.5)
  local scx, scy = cx - 0.5 * ca + 0.4, cy - 0.5 * sa + 0.6
  local core = HP.mask()
  for y = floor(scy) - 4, floor(scy) + 4 do for x = floor(scx) - 4, floor(scx) + 4 do
    local dx, dy = x + 0.5 - scx, y + 0.5 - scy
    local u, v = (dx * ca + dy * sa) / 2.35, (-dx * sa + dy * ca) / 1.35
    if u * u + v * v <= 1 and a.m:has(x, y) then core:set(x, y) end
  end end
  local ring = core:grow(1):cut(core):clip(a.m)
  ring:each(function(x, y) c:put(x, y, RUBY[2], tok) end)
  core:each(function(x, y)
    local d = (x + 0.5 - scx) + (y + 0.5 - scy)
    local col
    if split then col = d < -0.9 and SEEDC[6] or (d > 1.0 and SEEDC[4] or SEEDC[5])
    else col = d < -0.9 and "#ffc0ae" or (d > 1.0 and "#d86a64" or "#f59088") end
    c:put(x, y, col, tok)
  end)
  if split then
    -- the aril has cracked open above the seed: dark split line + dark lips
    local x0 = floor(cx - 3.2)
    for i = 0, 6 do local px, py = floor(cx - 3 + i * 1.0), floor(cy - 1.8 + i * 0.28 + (i % 2) * 0.0) if a.m:has(px, py) then c:put(px, py, RUBY[1], tok) end end
    for i = 0, 5 do local px, py = floor(cx - 2 + i * 1.0), floor(cy - 2.8 + i * 0.28) if a.m:has(px, py) then c:put(px, py, RUBY[4], tok) end end
  end
  -- specular
  local bx, by = G.specAt(a.m, n, 40)
  if not core:has(bx, by) then c:put(bx, by, "#fff4ea", tok) c:put(bx + 1, by, RUBY[6], tok) end
end
drawAril(arils[1], false)
drawAril(arils[2], true)
c:put(11, 47, "#fff4ea") c:put(12, 46, RUBY[6])

-- the bare seed that sprouted (angular, cream, ridged)
do
  local a = seed3
  local n = X.pillow(a.m, 2.4)
  local tok = { r = { name = "seed3" } }
  local ib = {} X.ao(ib, a.m, arils[2].m, 1, -1)
  X.tone(c, a.m, X.light(n, { amb = 0.16, wrap = 0.25 }), SEEDC, { cuts = CUTS, tok = tok, bias = ib })
  local ca, sa = cos(a[5]), sin(a[5])
  a.m:each(function(x, y)
    local dx, dy = x + 0.5 - a[1], y + 0.5 - a[2]
    local v = (-dx * sa + dy * ca)
    local u = (dx * ca + dy * sa)
    if abs(v - 0.5) < 0.55 and abs(u) < 3.2 then c:put(x, y, SEEDC[2], tok) end        -- ridge groove
    if abs(v + 1.0) < 0.5 and abs(u) < 2.6 and u > -2 then c:put(x, y, SEEDC[5], tok) end
  end)
  local bx, by = G.specAt(a.m, n, 36)
  c:put(bx, by, "#fffaf0", tok)
end

-- sprout: red stem, two opposite pairs of narrow leaves, bud, seed-coat cap
local function lance(ax, ay, cx, cy, bx, by, wmax, ramp, midcol)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    return max(0.42, wmax * sin(pi * min(1, 0.12 + 0.88 * t)) ^ 0.6)
  end, { fold = 0.34 })
  local lb = {}
  G.toneN(c, m, n, ramp, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3, bias = lb })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.16 and T[k] > 0.08 and T[k] < 0.92 then c:put(x, y, S[k] <= 0 and midcol[1] or midcol[2], ltok) end
  end)
  return m
end
local lowL = lance(41, 31.5, 34, 23.2, 24.5, 26.5, 2.1, LEAF, { LEAF[6], LEAF[3] })
local lowR = lance(41.5, 31.5, 48.5, 23.5, 56, 26.5, 2.1, LEAF, { LEAF[6], LEAF[3] })
local upL = lance(41, 23.8, 36.5, 17.2, 29.5, 19.5, 1.9, BRZ, { BRZ[6], BRZ[3] })
local upR = lance(41.6, 23.8, 46.5, 17.2, 53, 19.5, 1.9, BRZ, { BRZ[6], BRZ[3] })
-- stem
local sm, sn = G.tube({ { 41, 45.2 }, { 40, 37 }, { 42, 29 }, { 41.2, 17 } }, function(t) return 1.15 - 0.2 * t end)
local stok = { r = { name = "stem" } }
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.25, 0.45, 0.62, 0.8, 0.92 }, tok = stok })
-- nodes (leaf pair bases)
for _, ny in ipairs{ 31, 23.5 } do
  local x = floor(41 + 0.5 - (ny > 28 and 0.9 or 0.2))
  for dx = -1, 2 do if sm:has(x + dx, floor(ny)) then c:put(x + dx, floor(ny), STEM[2], stok) end end
end
-- collar where the stem leaves the seed
for _, p in ipairs{ { 39, 44 }, { 40, 44 }, { 41, 44 }, { 42, 44 }, { 43, 44 } } do if seed3.m:has(p[1], p[2]) then c:put(p[1], p[2], SEEDC[1]) end end
c:put(38, 45, SEEDC[1]) c:put(44, 45, SEEDC[1])
-- closed bud
local bud = c:ellipse(41.2, 15.6, 1.2, 2.0)
X.tone(c, bud, X.light(X.sphere(41, 15.6, 2.0, bud), { amb = 0.12, wrap = 0.3 }), BRZ, { cuts = CUTS, tok = ltok })
-- seed-coat cap: cracked husk worn like a hat
local cap = c:poly({ { 38.2, 14.4 }, { 38.4, 11.6 }, { 40.2, 9.6 }, { 42.8, 9.4 }, { 44.6, 11.2 }, { 44.8, 14.2 }, { 43.4, 12.8 }, { 41.8, 14.4 }, { 40.2, 12.8 } })
X.tone(c, cap, X.light(X.pillow(cap, 2.0), { amb = 0.16, wrap = 0.25 }), SEEDC, { cuts = CUTS, tok = { r = { name = "cap" } } })
c:put(41, 10, SEEDC[6]) c:put(40, 10, SEEDC[6]) c:put(43, 12, SEEDC[2]) c:put(42, 11, SEEDC[2])
G.save2(c, NAME)
