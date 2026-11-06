-- rangoon-creeper-seed (final, Sonnet high). A long torn scrap of Rangoon creeper leaf (elliptic with a drawn-out tip,
-- ragged left end with a pale fibre rim, midrib + curving lateral veins, downy bloom) lying across the tile. Three slim
-- five-ridged seeds with little wing fins rest on it, each with a contact shadow. The right seed has split and sent up a
-- twining shoot with two pairs of opposite elliptic, acuminate, veined leaves (the plant's real leaf shape).
-- quirk: the shoot is already topped by a first trumpet flower that has changed from white to pink to red.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_4.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt, rad = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.rad
local c = A.new("rangoon-creeper-seed")
local OLD  = { "#122f36", "#1b4a44", "#2a6648", "#3f8350", "#62a262", "#92c47e" }
local NEWL = { "#1e4a3a", "#2e6a44", "#43884c", "#62a858", "#8ccb68", "#bde68a" }
local SEEDR = { "#2d1a1a", "#4a2a22", "#6e402c", "#966040", "#bc8a58", "#e0b884" }
local STEM = { "#4a5a2a", "#7a8a3c", "#aab85a", "#d8e08a" }
local ltok = { r = { name = "leaf" } }

-- seeds: cx, cy, rx, ry, ang
local seeds = { { 14, 49.5, 5.6, 2.6, -0.12 }, { 25, 53, 5.6, 2.6, 0.16 }, { 37, 46.5, 5.8, 2.7, -0.1 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end

-- leaf scrap
local W = 9
local function sw(t)
  if t > 0.99 then return -1 end
  local w
  if t < 0.3 then w = 7.4 + (W - 7.4) * t / 0.3 else w = W * ((1 - t) / 0.7) ^ 0.85 end
  if t < 0.09 then w = w * (0.5 + 0.5 * X.hash(floor(t * 90), 3, 5)) end
  return max(0.5, w)
end
local bias = {}
local all = HP.mask():add(c:rect(0, 0, 63, 63))
for _, s in ipairs(seeds) do X.ao(bias, all, s.m, 1, -1) G.cast(bias, all, s.m, 1, 2, -1) end
local lm, ln, LT, LS, len, torn = A.tornBlade(c, 6, 50, 28, 50, 58, 41, sw, {
  ramp = OLD, veins = { 0.14, 0.24, 0.34, 0.44, 0.54, 0.64, 0.74, 0.84 }, sweep = 3.2, rib = 0.12, ribEnd = 0.97, veinMax = 0.86,
  fibre = "#dcecc0", cool = "#2f6a74", bias = bias, fold = 0.5,
  tear = { [1] = { depth = 0.6, t0 = 0.0, t1 = 0.42 }, [-1] = { depth = 0.45, t0 = 0.02, t1 = 0.3 } } })
lm:each(function(x, y) local k = K(x, y)         -- downy bloom
  if not bias[k] and LT[k] > 0.08 and abs(LS[k]) < 0.92 and X.hash(x, y, 71) > 0.9 then c:put(x, y, OLD[6], ltok) end end)

-- shoot (drawn before the split seed so its coat overlaps the foot)
local stp = { { 33, 46 }, { 30, 38 }, { 40, 30 }, { 37, 19 } }
local sm, sT, sS = A.stem(c, stp, 1.15, 0.8, STEM, { 0.25, 0.5, 0.75 })
local function node(t) local x, y = G.bez(stp, t) return x, y end
local function leaf(ax, ay, ang, L, w, bend, veins)
  local a = rad(ang)
  local cx, cy = ax + cos(a - bend) * L * 0.5, ay + sin(a - bend) * L * 0.5
  local bx, by = ax + cos(a) * L, ay + sin(a) * L
  local m, n, T, S = A.tornBlade(c, ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    if t < 0.1 then return 0.6 end
    local u = (t - 0.1) / 0.9
    local ww = w * sin(pi * min(1, u ^ 0.85)) ^ 0.8
    if u > 0.78 then ww = ww * max(0.4, (1 - u) / 0.22) end   -- drawn-out acuminate tip
    return max(0.5, ww)
  end, { ramp = NEWL, veins = veins, sweep = 2.2, rib = 0.14, ribEnd = 0.95, veinMax = 0.86, cool = "#3a7a70", fold = 0.45 })
  m:edge():each(function(x, y) local k = K(x, y) if X.hash(x, y, 13) > 0.6 and T[k] and T[k] > 0.15 then c:put(x, y, NEWL[6], ltok) end end)
  return m
end
local n1x, n1y = node(0.4)
local n2x, n2y = node(0.72)
local v5 = { 0.3, 0.44, 0.58, 0.72 }
leaf(n2x, n2y, -128, 12, 3.0, 0.18, v5)
leaf(n2x, n2y, -50, 12, 3.0, -0.18, v5)
leaf(n1x, n1y, -168, 15, 3.5, 0.2, { 0.28, 0.4, 0.52, 0.64, 0.76 })
leaf(n1x, n1y, -12, 15, 3.5, -0.2, { 0.28, 0.4, 0.52, 0.64, 0.76 })
-- node knobs
for _, p in ipairs{ { n1x, n1y }, { n2x, n2y } } do c:put(floor(p[1] + 0.5), floor(p[2] + 0.5), STEM[3]) c:put(floor(p[1] + 0.5) + 1, floor(p[2] + 0.5), STEM[2]) end

-- quirk: trumpet flower, white -> pink -> red
local fm, fn, FT = G.tube({ { 37, 19 }, { 38, 16 }, { 40, 13 }, { 41, 10 } }, function(t) return 1.05 - 0.15 * t end)
fm:cut(sm)
local PINKR = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }
local WHITER = { "#9a9ab4", "#c8c8d8", "#e6e6ee", "#fffaf0" }
local REDR = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local fv = X.light(fn, { amb = 0.15, wrap = 0.3 })
local parts = { HP.mask(), HP.mask(), HP.mask() }
fm:each(function(x, y) local t = FT[K(x, y)] parts[t < 0.34 and 1 or (t < 0.7 and 2 or 3)]:set(x, y) end)
X.tone(c, parts[1], fv, WHITER, { cuts = { 0.3, 0.55, 0.8 } })
X.tone(c, parts[2], fv, PINKR, { cuts = { 0.3, 0.55, 0.8 } })
X.tone(c, parts[3], fv, REDR, { cuts = { 0.3, 0.55, 0.8 } })
for _, p in ipairs{ { 40, 8, 3 }, { 42, 8, 2 }, { 39, 9, 2 }, { 40, 9, 4 }, { 42, 9, 3 }, { 43, 9, 2 } } do c:put(p[1], p[2], REDR[p[3]]) end
c:put(41, 9, "#6e2038") c:put(41, 8, REDR[2])

-- seeds, left to right
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  local idx = A.shade(c, vis, s.n, SEEDR, { amb = 0.1, wrap = 0.25, bias = sb, tok = tok })
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + 0.45), flip * (-dx * sa + dy * ca) / (s[4] + 0.45)
    local b = idx[k] or 3
    local d = 0
    for _, r in ipairs{ -0.62, 0, 0.62 } do if abs(v - r) < 0.15 then d = d + 1 end end   -- ridge crests
    for _, g in ipairs{ -0.31, 0.31 } do if abs(v - g) < 0.1 then d = d - 1 end end        -- grooves
    if abs(u) > 0.9 then d = d - 1 end
    c:put(x, y, SEEDR[max(1, min(6, b + d))], tok)
    if v > -0.75 and v < -0.5 and u > -0.5 and u < -0.15 then c:put(x, y, SEEDR[6], tok) end -- specular on the lit crest
  end)
  -- wing fins on the ridges
  for _, f in ipairs{ { -0.4, -1 }, { 0.4, -1 }, { -0.1, 1 }, { 0.5, 1 } } do
    local u, side = f[1], f[2]
    local px = s[1] + (u * s[3]) * ca - (side * flip * (s[4] + 1.05)) * sa
    local py = s[2] + (u * s[3]) * sa + (side * flip * (s[4] + 1.05)) * ca
    local xi, yi = floor(px + 0.5), floor(py + 0.5)
    if not s.m:has(xi, yi) then c:put(xi, yi, side < 0 and SEEDR[5] or SEEDR[3], tok) end
  end
  -- scar at the narrow tip
  c:put(floor(s[1] - ca * (s[3] + 0.2) + 0.5), floor(s[2] - sa * (s[3] + 0.2) + 0.5), SEEDR[1], tok)
end
-- the split seed: pale crack along the coat, white kernel showing
local s3 = seeds[3]
for u = -0.7, 0.4, 0.1 do
  local x = floor(s3[1] + u * s3[3] * cos(s3[5]) + 0.5) local y = floor(s3[2] + u * s3[3] * sin(s3[5]) - 0.6 + 0.5)
  c:put(x, y, "#f6e8b0")
end
c:put(floor(s3[1] - 3.6), floor(s3[2] - 0.2), "#fffaf0")
A.save(c, "rangoon-creeper-seed")
