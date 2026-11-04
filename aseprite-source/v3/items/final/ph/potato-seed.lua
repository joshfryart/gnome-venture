-- potato-seed (D10 final, Sonnet high). Four true-potato seeds (tiny flat kidney discs, pale gold, a notch at the hilum,
-- a dimple and a ridged rim) resting on a torn potato leaflet scrap (ovate, pointed tip, corrugated swept veins, torn zig-zag
-- edge, AO + contact shadow under each seed). The fourth seed has sprouted: pale stem, two oval cotyledons and a first true
-- potato leaf of three leaflets (big pointed terminal + two smaller laterals).
-- quirk: the seedling has already put out a flower, a five-petal lilac star with a yellow cone, on a hair-thin stalk.
local NAME = "potato-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD10_2.lua")
local HP, X, K, G = A.HP, A.X, A.K, A.G
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#1a3b38", "#235641", "#33744b", "#4c9452", "#76b45c", "#a8d072" }
local SEED = { "#6e4f2a", "#9a7238", "#c89c50", "#e6c070", "#f6dc98", "#fff2c8" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local LILAC = { "#5a4590", "#8368c0", "#a98ce0", "#cdb6f4", "#e8dcff", "#faf4ff" }
local COOL = "#3a6c72"
local TAIL = {}

-- leaf scrap: torn ovate potato leaflet on the diagonal
local PA = { 6, 55, 24, 58, 48, 47 }
local function qb(t) return A.qb({ PA[1], PA[2] }, { PA[3], PA[4] }, { PA[5], PA[6] }, t) end
local function seedAt(t, off, rx, ry, ang)
  local x, y = qb(t)
  return { floor(x + .5), floor(y + off + .5), rx, ry, ang }
end
local seeds = { seedAt(0.2, 2.2, 3.9, 3.0, 0.35), seedAt(0.36, -3.4, 3.9, 3.0, -0.3), seedAt(0.5, 3.0, 3.9, 3.0, 0.55), seedAt(0.7, 0.2, 4.0, 3.2, 0) }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.55) end

local bias = {}
local ltok = { r = { name = "leaf" } }
local lm, lT, lS, llen = A.leaf(c, PA, LEAF, {
  wfn = function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.93 + 0.07)
    return max(0.5, 9.4 * sin(pi * u ^ 0.95) ^ 0.62)
  end,
  carve = function(m, T, S, len)
    local cut = {}
    m:each(function(x, y) local k = K(x, y) local t, s = T[k], S[k]
      -- torn base: ragged diagonal cut
      if t < 0.07 + 0.02 * ((x + y) % 3) then cut[#cut + 1] = k end
      -- torn upper edge: zig-zag bite
      if t > 0.46 and t < 0.82 and s < 0 then
        local ph = t * len / 2.3
        local tri = abs((ph - floor(ph)) - 0.5) * 2
        if s < -(0.42 + 0.3 * tri) then cut[#cut + 1] = k end
      end
    end)
    for _, k in ipairs(cut) do m.s[k] = nil end
  end,
  bias = bias, tok = ltok, vper = 3.6, vsl = 2.6, vw = 0.3, v0 = 0.1, v1 = 0.9, rib = 0.13,
  cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 },
})
-- cool reflected light on the lower-right edge
lm:edge():each(function(x, y) local k = K(x, y)
  if lS[k] and lS[k] > 0.62 and lT[k] > 0.12 and lT[k] < 0.9 and not bias[k] then c:put(x, y, COOL, ltok) end end)

-- seed AO + contact shadow on the leaf (seeds 1-3 then the sprouting one)
for _, s in ipairs(seeds) do
  local b2 = {}
  X.ao(b2, lm, s.m, 1, -1) G.cast(b2, lm, s.m, 1, 2, -1)
  for k, v in pairs(b2) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    local cur = c:get(x, y)
    if cur then
      -- step the pixel one tone darker along the leaf ramp
      for i = 2, 6 do if LEAF[i] == cur then c:put(x, y, LEAF[max(1, i + v)], ltok) break end end
      if cur == COOL then c:put(x, y, LEAF[2], ltok) end
    end
  end
end

-- sprout (drawn before the front seed so the coat sits over the stem foot)
local s4 = seeds[4]
local stok = { r = { name = "stem" } }
local sp = { { s4[1], s4[2] - 2 }, { s4[1] - 1, s4[2] - 8 }, { s4[1] + 2, s4[2] - 15 }, { s4[1] + 2, s4[2] - 21 } }
local sm, sn = G.tube(sp, function(t) return 1.05 end)
sm:cut(s4.m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local topx, topy = G.bez(sp, 1)
local midx, midy = G.bez(sp, 0.55)
-- cotyledons: two plump ovals, tilted, slightly bluish
local function coty(cx, cy, ang)
  local m, n = G.oval(cx, cy, 4.2, 2.3, ang, 0.8)
  m:cut(sm)
  G.toneN(c, m, n, LEAF, { tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
  -- short midrib
  local ca, sa = cos(ang), sin(ang)
  for i = -2, 2 do local x, y = floor(cx + i * ca * 1.3 + .5), floor(cy + i * sa * 1.3 + .5) if m:has(x, y) then c:put(x, y, LEAF[5], ltok) end end
  return m
end
local cL = coty(floor(midx - 5), floor(midy + 1), -0.3)
local cR = coty(floor(midx + 6), floor(midy + 1), 0.28)
-- first true leaf: terminal leaflet + two lateral leaflets (potato leaf)
local tx, ty = floor(topx + .5), floor(topy + .5)
local function leaflet(pa, w, vper)
  return A.leaf(c, pa, LEAF, {
    wfn = function(t) if t > 0.985 then return -1 end
      local u = min(1, t * 0.95 + 0.05) return max(0.5, w * sin(pi * u ^ 0.9) ^ 0.62) end,
    tok = ltok, vper = vper, vsl = 2.2, vw = 0.34, v0 = 0.2, v1 = 0.85, rib = 0.16, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
end
leaflet({ tx, ty + 1, tx - 2, ty - 6, tx, ty - 14 }, 3.6, 3.4)
leaflet({ tx, ty + 1, tx - 6, ty - 1, tx - 13, ty - 3 }, 2.5, 99)
leaflet({ tx, ty + 1, tx + 5, ty - 3, tx + 11, ty - 5 }, 2.5, 99)
for _, p in ipairs({ { tx, ty + 1 }, { tx, ty } }) do c:put(p[1], p[2], STEM[3], stok) end

-- quirk: flower on a thin stalk from the leaf axil
local fx, fy = tx + 14, ty - 11
local stalk = { { tx + 1, ty + 1 }, { tx + 6, ty - 1 }, { tx + 10, ty - 5 }, { fx - 1, fy + 2 } }
for i = 0, 24 do local x, y = G.bez(stalk, i / 24) c:put(floor(x + .5), floor(y + .5), i < 12 and STEM[2] or STEM[3], stok) end
local fm = HP.mask()
for i = 0, 4 do
  local a = -pi / 2 + i * 2 * pi / 5
  fm:add(G.rell(fx + cos(a) * 2.8, fy + sin(a) * 2.8, cos(a), sin(a), 2.2, 1.5))
end
fm:add(HP.ellipse(fx, fy, 1.6, 1.6))
local fn = X.pillow(fm, 1.8)
G.toneN(c, fm, fn, LILAC, { tok = { r = { name = "flower" } }, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.1, wrap = 0.3 })
-- petal creases: dark notches between petals
for i = 0, 4 do
  local a = -pi / 2 + (i + 0.5) * 2 * pi / 5
  local x, y = floor(fx + cos(a) * 3.2 + .5), floor(fy + sin(a) * 3.2 + .5)
  if fm:has(x, y) then c:put(x, y, LILAC[2], { r = { name = "flower" } }) end
end
for _, p in ipairs({ { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } }) do c:put(floor(fx) + p[1] - 0, floor(fy) + p[2] - 0, "#ffd24a", { r = { name = "cone" } }) end
c:put(floor(fx), floor(fy), "#fff0a0", { r = { name = "cone" } })
c:put(floor(fx) + 1, floor(fy) + 1, "#e29a22", { r = { name = "cone" } })

-- seeds: kidney discs with ridge rim, notch, dimple
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  local m = s.m:copy()
  -- notch (hilum) on the lower-left rim
  local nx, ny = floor(s[1] - ca * (s[3] - 1) * 0.6 + sa * (s[4]) * 0.9 + .5), floor(s[2] - sa * (s[3] - 1) * 0.6 - ca * s[4] * 0.9 * -1 + .5)
  local v = X.light(s.n, { amb = 0.1, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, w = (dx * ca + dy * sa) / (s[3] + .45), flip * (-dx * sa + dy * ca) / (s[4] + .45)
    local r2 = u * u + w * w
    local val = v[k] or 0.5
    -- flat disc: raised rim ring (r2>0.5) lit on upper-left, dished centre
    local idx = floor(val * 6) + 1
    if r2 < 0.42 then idx = idx - 1 end
    if r2 >= 0.42 and (u + w) < 0 then idx = idx + 1 end
    c:put(x, y, SEED[max(1, min(6, idx))], tok)
  end)
  -- dimple + notch
  c:put(floor(s[1] + .5) + 1, floor(s[2] + .5), SEED[1], tok)
  c:put(floor(s[1] + .5) + 2, floor(s[2] + .5) + 1, SEED[2], tok)
  c:put(floor(s[1] + .5) - 2, floor(s[2] + .5) - 1, SEED[6], tok)
  c:put(floor(s[1] + .5) - 1, floor(s[2] + .5) - 1, SEED[5], tok)
  -- hilum nick at the lower-right rim of seed (pale end)
  local bx, by = floor(s[1] + ca * s[3] * 0.95 + .5), floor(s[2] + sa * s[3] * 0.95 + .5)
  if m:has(bx, by) then c:put(bx, by, SEED[1], tok) end
end
A.save(c, NAME)
