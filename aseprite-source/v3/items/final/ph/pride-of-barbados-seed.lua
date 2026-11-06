-- pride-of-barbados-seed (D10 final, Sonnet high). Three flat mottled brown beans (smooth, slightly lumpy, pale hilum,
-- dark blotches, one cream glint) lying on a torn bipinnate pinna: a slim curved rachis carrying nine pairs of oval
-- leaflets with fine midribs (broken base, one leaflet nibbled). The right bean has sprouted: pale stem, two fleshy
-- cotyledons and a first feathery true leaf (rachis, three pairs of pinnae, tiny paired leaflets).
-- quirk: a flame-red flower with three long curling stamens (gold anthers) waves on a thin stalk at the left.
local NAME = "pride-of-barbados-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD10_2.lua")
local HP, X, K, G = A.HP, A.X, A.K, A.G
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local LEAF = { "#16393f", "#1d5547", "#2a7550", "#3f9558", "#64b566", "#9bd283" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local SEED = { "#2c1a14", "#4e3020", "#6e4a2e", "#92693e", "#b88c58", "#e2bc84" }
local EMB = { "#6e2038", "#b52e3f", "#e8493b", "#ff6a3f", "#ff8a5c", "#ffd08a" }
local COOL = "#3a6c72"
local CUT6 = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local ltok = { r = { name = "leaf" } }
local stok = { r = { name = "stem" } }

-- main pinna path (quadratic) lower strip, left to right rising
local PA = { 11, 56, 30, 60, 52, 48 }
local function qb(t) return A.qb({ PA[1], PA[2] }, { PA[3], PA[4] }, { PA[5], PA[6] }, t) end
local function tang(t)
  local x0, y0 = qb(max(0, t - 0.01)) local x1, y1 = qb(min(1, t + 0.01))
  local l = sqrt((x1 - x0)^2 + (y1 - y0)^2) return (x1 - x0) / l, (y1 - y0) / l
end

-- rachis (under the leaflets)
do
  local pts = { { PA[1], PA[2] }, { PA[1] + 8, PA[2] + 2 }, { 36, 56 }, { PA[5], PA[6] } }
  local rm, rn = G.tube({ { 11, 56 }, { 22, 59 }, { 38, 57 }, { 52, 48 } }, function(t) return 1.1 end)
  local xs = {}
  X.tone(c, rm, X.light(rn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
end

-- leaflets: pairs along the rachis, upper side first so the lower side overlaps with a contact line
local U = HP.mask()          -- already drawn leaflets
local function leaflet(bx, by, ang, ra, rb, bite)
  local ux, uy = cos(ang), sin(ang)
  local cx, cy = bx + ux * ra * 0.95, by + uy * ra * 0.95
  local m, n = G.oval(cx, cy, ra, rb, ang, 0.7)
  if bite then m:cut(HP.ellipse(bite[1], bite[2], bite[3], bite[3])) end
  -- separation: edge pixels touching earlier leaflets go to the deepest tone
  local touch = A.touch(m, U)
  touch:cut(m:copy():shrink(1):grow(0))   -- keep rim pixels only
  G.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUT6, amb = 0.14, wrap = 0.3 })
  -- fine midrib (lit)
  for i = 1, floor(ra * 1.7) do
    local x, y = floor(bx + ux * i * 0.85 + .5), floor(by + uy * i * 0.85 + .5)
    if m:has(x, y) then c:put(x, y, LEAF[5], ltok) end
  end
  touch:each(function(x, y) if m:has(x, y) and U:has(x, y) == false then c:put(x, y, LEAF[1], ltok) end end)
  U:add(m)
  return m
end
local NP = 7
local leafMasks = {}
for pass = 1, 2 do
  for i = NP, 1, -1 do
    local t = 0.08 + (i - 1) * 0.135
    local bx, by = qb(t)
    local tx, ty = tang(t)
    local base = atan(ty, tx)
    local side = pass == 1 and -1 or 1                 -- -1 upper (lit), +1 lower
    local ang = base + side * 1.02
    local ra, rb = 3.9, 2.05
    if i == 1 then ra = 3.2 end
    local bite
    if i == 1 and side == 1 then bite = { bx + 1, by + 6.5, 2.2 } end   -- nibbled first lower leaflet
    leafMasks[#leafMasks + 1] = leaflet(floor(bx + .5), floor(by + .5), ang, ra, rb, bite)
  end
end
-- terminal leaflet
do
  local bx, by = qb(0.98)
  local tx, ty = tang(0.98)
  leaflet(floor(bx + .5), floor(by + .5), atan(ty, tx), 4.4, 2.1)
end
-- torn base: pale fibrous break at the rachis end
do
  local x, y = floor(PA[1] + 0.5), floor(PA[2] + 0.5)
  c:put(x - 1, y - 1, STEM[4], stok) c:put(x - 1, y, STEM[3], stok) c:put(x, y + 1, STEM[2], stok) c:put(x - 2, y - 1, STEM[3], stok)
end

-- seeds
local seeds = {}
for i, q in ipairs({ { 0.27, 1.0, 4.2, 3.0, 0.25 }, { 0.49, -3.4, 4.2, 3.0, -0.2 }, { 0.71, 1.8, 4.3, 3.1, 0.1 } }) do
  local x, y = qb(q[1])
  seeds[i] = { floor(x + .5), floor(y + q[2] + .5), q[3], q[4], q[5] }
  seeds[i].m, seeds[i].n = G.oval(seeds[i][1], seeds[i][2], q[3], q[4], q[5], 0.62)
end
-- leaf AO + contact shadow under the seeds
for _, s in ipairs(seeds) do
  local b2 = {}
  X.ao(b2, U, s.m, 1, -1) G.cast(b2, U, s.m, 1, 2, -1)
  for k, v in pairs(b2) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    local cur = c:get(x, y)
    if cur then for i = 2, 6 do if LEAF[i] == cur then c:put(x, y, LEAF[max(1, i + v)], ltok) break end end end
  end
end

-- sprout from the right bean
local s3 = seeds[3]
local sp = { { s3[1], s3[2] - 2 }, { s3[1] - 1, s3[2] - 7 }, { s3[1] + 1, s3[2] - 12 }, { s3[1] + 1, s3[2] - 17 } }
local sm, sn = G.tube(sp, function(t) return 1.0 end)
sm:cut(s3.m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local topx, topy = G.bez(sp, 1)
local tx0, ty0 = floor(topx + .5), floor(topy + .5)
local mx, my = G.bez(sp, 0.5)
local function coty(cx, cy, ang)
  local m, n = G.oval(cx, cy, 3.9, 2.4, ang, 0.7)
  m:cut(sm)
  G.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUT6, amb = 0.14, wrap = 0.3 })
  local ca, sa = cos(ang), sin(ang)
  for i = -1, 2 do local x, y = floor(cx + i * ca * 1.2 + .5), floor(cy + i * sa * 1.2 + .5) if m:has(x, y) then c:put(x, y, LEAF[5], ltok) end end
  return m
end
coty(floor(mx - 5), floor(my - 1), -0.28)
coty(floor(mx + 6), floor(my - 1), 0.25)
-- first true leaf: bipinnate in miniature
local function mini(bx, by, ang, ra, rb)
  local ux, uy = cos(ang), sin(ang)
  local m, n = G.oval(bx + ux * ra * 0.9, by + uy * ra * 0.9, ra, rb, ang, 0.7)
  G.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUT6, amb = 0.14, wrap = 0.3 })
  return m
end
local function pinna(bx, by, ang, len, np)
  -- axis line
  for i = 0, floor(len) do c:put(floor(bx + cos(ang) * i + .5), floor(by + sin(ang) * i + .5), STEM[3], stok) end
  for k = np, 1, -1 do
    local d = 1.8 + (k - 1) * (len - 3.5) / max(1, np - 1)
    local px, py = bx + cos(ang) * d, by + sin(ang) * d
    mini(floor(px + .5), floor(py + .5), ang - 1.1, 1.8, 1.0)
    mini(floor(px + .5), floor(py + .5), ang + 1.1, 1.8, 1.0)
  end
  mini(floor(bx + cos(ang) * len + .5), floor(by + sin(ang) * len + .5), ang, 2.1, 1.2)
end
local rpts = { { tx0, ty0 + 1 }, { tx0 - 1, ty0 - 5 }, { tx0 + 1, ty0 - 11 }, { tx0, ty0 - 16 } }
for i = 0, 20 do local x, y = G.bez(rpts, i / 20) c:put(floor(x + .5), floor(y + .5), STEM[3], stok) end
for _, h in ipairs({ { 0.3, 8 }, { 0.68, 6 } }) do
  local x, y = G.bez(rpts, h[1])
  pinna(floor(x + .5), floor(y + .5), -pi / 2 - 0.85, h[2], 3)
  pinna(floor(x + .5), floor(y + .5), -pi / 2 + 0.85, h[2], 3)
end
do local x, y = G.bez(rpts, 1) mini(floor(x + .5), floor(y + .5) + 1, -pi / 2, 2.4, 1.3) end

-- quirk: flame flower on a thin stalk at the left, three long stamens
local s1x, s1y = qb(0.12)
local fx, fy = 17, 27
local stk = { { floor(s1x + .5), floor(s1y + .5) - 3 }, { 12, 45 }, { 20, 37 }, { fx, fy + 3 } }
for i = 0, 30 do local x, y = G.bez(stk, i / 30) c:put(floor(x + .5), floor(y + .5), i < 14 and STEM[2] or STEM[3], stok) end
local ftok = { r = { name = "flower" } }
local pm = HP.mask()
pm:add(G.rell(fx - 2.4, fy + 0.6, -0.8, -0.6, 3.2, 2.2))
pm:add(G.rell(fx + 2.6, fy + 0.8, 0.8, -0.6, 3.2, 2.2))
pm:add(G.rell(fx, fy - 1.6, 0, -1, 3.0, 2.4))
pm:add(HP.ellipse(fx, fy + 1, 2, 1.4))
local pn = X.pillow(pm, 2.4)
G.toneN(c, pm, pn, EMB, { tok = ftok, cuts = { 0.2, 0.34, 0.5, 0.66, 0.84 }, amb = 0.1, wrap = 0.35 })
-- gold ruffle on the top edge of the petals
pm:each(function(x, y) if not pm:has(x, y - 1) and y < fy then c:put(x, y, "#ffc83a", ftok) end end)
c:put(fx - 1, fy + 1, EMB[1], ftok) c:put(fx + 1, fy + 1, EMB[1], ftok)
local ends = { { fx + 11, fy - 9, 3, -6 }, { fx + 5, fy - 13, 2, -9 }, { fx - 4, fy - 12, -1, -8 } }
for i, e in ipairs(ends) do
  local p = { { fx, fy - 2 }, { fx + e[3], fy + e[4] }, { fx + (e[1] - fx) * 0.8, fy - 11 + i }, { e[1], e[2] } }
  for j = 0, 22 do
    local x, y = G.bez(p, j / 22)
    c:put(floor(x + .5), floor(y + .5), (j % 4 == 3) and EMB[2] or EMB[3], ftok)
  end
  c:put(e[1], e[2], "#ffe070", ftok) c:put(e[1] + 1, e[2] - 1, "#f5b82e", ftok) c:put(e[1] + 1, e[2], "#e29a22", ftok)
end

-- beans last: mottled, glossy flat discs with a pale hilum
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  local v = X.light(s.n, { amb = 0.1, wrap = 0.3 })
  s.m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, w = (dx * ca + dy * sa) / (s[3] + .45), flip * (-dx * sa + dy * ca) / (s[4] + .45)
    local idx = floor((v[k] or 0.5) * 6) + 1
    local r2 = u * u + w * w
    if r2 > 0.55 and (u + w) < 0 then idx = idx + 1 end              -- lit rim
    if X.hash(x, y, 5 + i) < 0.2 + 0.25 * max(0, w) then idx = idx - 2 end   -- dark blotches, heavier toward the shade side
    c:put(x, y, SEED[max(1, min(6, idx))], tok)
  end)
  -- hilum: pale nick on the short end
  local hx, hy = floor(s[1] + ca * (s[3] - 0.6) + .5), floor(s[2] + sa * (s[3] - 0.6) + .5)
  c:put(hx, hy, SEED[6], tok) c:put(hx - floor(ca + .5), hy - floor(sa + .5), SEED[5], tok)
  -- ring crease (areole) on the face
  c:put(floor(s[1] + .5) + 1, floor(s[2] + .5) + 1, SEED[2], tok)
end
-- one glint on the middle bean
do local s = seeds[2] c:put(s[1] - 2, s[2] - 2, "#fff4d6", { r = { name = "seed2" } }) c:put(s[1] - 1, s[2] - 2, SEED[6], { r = { name = "seed2" } }) end
A.save(c, NAME)
