-- agapanthus-seed (final, Opus). Three flat, glossy black agapanthus seeds, each with a papery brown wing, lying on a
-- torn scrap of strap leaf (channelled keel, parallel veins, ragged torn ends, cool blue reflected edge for the
-- blue flower). The right seed has germinated: pale root, a slim hypocotyl and two arching strap blades.
-- quirk: the seed coat is still stuck on the tip of the taller blade like a tiny black hat.
local NAME = "agapanthus-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR1_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)

local LEAF = { "#173a3a", "#1f5642", "#2b734a", "#3f9150", "#63b25a", "#99d072" }
local VEIN, COOL = "#b8e08a", "#4a8aa8"
local SEED = { "#120c16", "#1c1522", "#2a2132", "#3c3248", "#5a4e6c", "#c8c0dc" }
local WING = { "#3a2a2c", "#523c36", "#6e5242", "#8e6e52", "#b8986e" }
local STEM = { "#5e8a52", "#8cba6c", "#bcdc94", "#e4f2c0" }
local ROOT = { "#a8906a", "#d8c8a0", "#f4ead0" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- seeds: cx, cy, length, half-width, angle, wing side (+1 = toward +axis). Flat teardrop flakes.
local seeds = { { 17, 51, 3.6, 2.0, 0.5, 1 }, { 28, 51, 3.8, 2.1, -0.25, 1 }, { 37, 46, 3.6, 2.0, 0.2, -1 } }
local function flake(cx, cy, L, W, a, side)
  local ca, sa = cos(a), sin(a)
  local m, n = HP.mask(), {}
  for y = floor(cy) - 8, floor(cy) + 8 do for x = floor(cx) - 8, floor(cx) + 8 do
    local dx, dy = x - cx, y - cy
    local u, v = (dx * ca + dy * sa) * side, -dx * sa + dy * ca
    local un = u / (L + 0.4)
    local w = (W + 0.45) * (un < 0 and math.sqrt(max(0, 1 - un * un)) or (1 - un ^ 1.6))
    if un >= -1 and un <= 1 and abs(v) <= w then
      m:set(x, y)
      local vn = v / max(w, 0.6)
      local nx, ny = (un * 0.6) * ca * side - vn * sa, (un * 0.6) * sa * side + vn * ca
      local l = math.sqrt(nx * nx + ny * ny + 1.4)
      n[K(x, y)] = { nx / l, ny / l, 1.18 / l }
    end
  end end
  return m, n
end
for _, s in ipairs(seeds) do
  s.m, s.n = flake(s[1], s[2], s[3], s[4], s[5], s[6])
  local ca, sa = cos(s[5]), sin(s[5])
  -- papery wing hugs the blunt end and one flank
  s.w = A.rell(s[1] - s[6] * s[3] * 1.05 * ca, s[2] - s[6] * s[3] * 1.05 * sa, ca, sa, s[3] * 0.95, s[4] + 1.0)
  s.w:cut(s.m)
end

-- strap-leaf scrap: long, nearly parallel sided, gently bowed, torn at both ends
local lm, ln, LT, LS, len = A.blade(4, 55, 30, 53, 58, 40, function(t) return 7.0 - 1.4 * t end, { fold = 0.42 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local d0, d1 = LT[k] * len, (1 - LT[k]) * len
  local j0 = 1.2 + 2.6 * abs(sin(LS[k] * 4.1 + 0.6)) + X.hash(x, y, 3) * 1.2
  local j1 = 1.0 + 3.4 * abs(sin(LS[k] * 3.3 + 1.9)) + (LS[k] > 0 and 2 or 0)
  if d0 < j0 or d1 < j1 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do
  local both = s.m:copy():add(s.w)
  X.ao(bias, lm, both, 1, -1) A.cast(bias, lm, both, 1, 1, -1)
end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.2, 0.4, 0.58, 0.76, 0.9 }, amb = 0.12, wrap = 0.25 })
-- keel and parallel veins
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 then c:put(x, y, s <= 0 and VEIN or LEAF[2], ltok)
  elseif abs(abs(s) - 0.52) < 0.07 and X.hash(x, y, 7) > 0.25 then c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) end
end)
-- cool reflected light on the lower-right rim, torn ends darker (fibres)
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local d0, d1 = LT[k] * len, (1 - LT[k]) * len
  if d0 < 6 or d1 < 6 then c:put(x, y, (x + y) % 2 == 0 and LEAF[2] or "#cfe8a0", ltok)
  elseif LS[k] > 0.7 then c:put(x, y, COOL, ltok) end
end)

-- root of the sprouting seed, curling down over the leaf
local rtok = { r = { name = "root" } }
local rp = { { 40, 48 }, { 42, 51 }, { 45, 51 }, { 48, 49 } }
for i = 0, 24 do local x, y = A.bez(rp, i / 24) local xi, yi = floor(x + .5), floor(y + .5)
  c:put(xi, yi, i < 16 and ROOT[2] or ROOT[1], rtok)
  if lm:has(xi + 1, yi + 1) then c:put(xi + 1, yi + 1, LEAF[1], ltok) end
end
c:put(42, 50, ROOT[3], rtok)

-- sprout: hypocotyl and two strap blades
local stok = { r = { name = "stem" } }
local sp = { { 37, 44 }, { 36, 38 }, { 38, 33 }, { 38, 29 } }
local sm, sn = A.tube(sp, function(t) return 1.0 end)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function strap(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.3, w * (1 - t ^ 2.2))
  end, { fold = 0.4 })
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.16 and T[k] > 0.08 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m, T, S
end
local bl = strap(38, 29, 31, 22, 20, 21, 1.9)
local br, BT = strap(38, 29, 42, 18, 51, 13, 2.0)
-- AO where blades leave the stem
c:put(37, 30, STEM[1], stok) c:put(39, 29, LEAF[2], ltok)

-- seeds: wing first, then glossy body with a single specular, AO where they touch the leaf
for i, s in ipairs(seeds) do
  local wtok = { r = { name = "wing" .. i } }
  local wn = X.pillow(s.w, 1.2)
  local wv = X.light(wn, { amb = 0.35, wrap = 0.4 })
  X.tone(c, s.w, wv, WING, { cuts = { 0.3, 0.5, 0.68, 0.85 }, tok = wtok })
  -- papery veins in the wing
  s.w:each(function(x, y) if X.hash(x, y, 11 + i) > 0.8 then c:put(x, y, WING[2], wtok) end end)
  s.w:edge():each(function(x, y) local k = K(x, y) if wn[k][1] + wn[k][2] < -0.3 then c:put(x, y, WING[5], wtok) end end)
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  if i == 3 then X.ao(sb, s.m, sm, 1, -1) end
  A.toneN(c, s.m, s.n, SEED, { tok = tok, bias = sb, cuts = { 0.25, 0.45, 0.62, 0.8, 2 }, amb = 0.05, wrap = 0.15 })
  -- faint raised rim on the lit edge (flat seed), then one specular
  s.m:edge():each(function(x, y) local k = K(x, y) if s.n[k][1] + s.n[k][2] < -0.5 then c:put(x, y, SEED[4], tok) end end)
  local sx, sy = A.specAt(s.m, s.n, 30)
  c:put(sx + 1, sy, SEED[6], tok) c:put(sx + 2, sy, SEED[5], tok)
end
-- stem foot over the sprouting seed
c:put(37, 44, STEM[2], stok) c:put(37, 43, STEM[3], stok)

-- quirk: the seed coat riding on the tip of the tall blade (a tiny black winged cap)
c:paint({
  ".wwb..",
  "wbbbb.",
  "bdssbb",
  ".bbbb.",
}, 49, 10, { w = WING[2], b = SEED[2], d = SEED[3], s = SEED[6] })

A.save(c, NAME)
