-- persimmon-seed (Opus artist pass, single). Two flat, glossy, date-brown persimmon seeds on a torn scrap of
-- persimmon leaf (leathery, glossy: elliptic blade with a stub petiole on the left, a ragged torn edge on the right,
-- pale midrib, curved pinnate veins, a waxy gloss band, cool reflected edge, AO + contact shadow under the seeds).
-- The left seed has germinated: pale stem, two elliptic cotyledons and a first true leaf (ovate, glossy, pinnate
-- veins) that shows the persimmon leaf shape.
-- quirk: the right seed is cut open, showing the little white "spoon" embryo of the old weather folklore.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_3.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "persimmon-seed"
local c = D.new(NAME)

local LEAF = { "#132f30", "#1c4a3c", "#276643", "#3a8448", "#5ea552", "#8cc864" }
local GLOSS, VEIN, COOL = "#c4e892", "#a6d47a", "#3c6a78"
local SEED = { "#2e1a1e", "#4c2a24", "#6e3e2a", "#93582e", "#ba7a3e", "#e2aa6a" }
local CUT  = { "#7e6c60", "#a8957e", "#c6b394", "#ddcca8" }
local STEM = { "#5a7a4a", "#8eb06a", "#bcd894", "#e4f2c0" }
local ltok, stok = D.tok("leaf"), D.tok("stem")

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 20, 45, 5.0, 3.0, -0.25 }, { 35, 46, 5.4, 3.3, 0.18 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.55) end

-- leaf scrap: elliptic blade, tip torn off on the right
local lm, ln, LT, LS, len = G.blade(8, 49, 30, 54, 56, 44, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 7.2 * sin(pi * min(1, t * 0.8 + 0.08)) ^ 0.65)
end, { fold = 0.3 })
-- ragged tear: cut beyond a jagged line near t=0.86
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local lim = 0.86 + 0.03 * sin(LS[k] * 8.0)
  if LT[k] > lim then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.03 and t < 0.9 then c:put(x, y, s <= 0 and VEIN or LEAF[4], ltok) return end
  -- curved pinnate veins, swept toward the tip
  local ph = (t * len - abs(s) ^ 0.7 * 6) / 6.5 + (s > 0 and 0.4 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.9 and abs(s) > 0.16 and abs(s) < 0.78 and t > 0.08 and t < 0.86 then c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) end
  -- waxy gloss band on the lit half
  if s < -0.35 and s > -0.55 and t > 0.12 and t < 0.4 and X.hash(x, y, 5) > 0.45 then c:put(x, y, GLOSS, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.15 and LT[k] < 0.8 then c:put(x, y, COOL, ltok) end
  -- torn edge: pale broken tissue
  if LT[k] > 0.8 then c:put(x, y, LEAF[5], ltok) end
end)
for _, q in ipairs{ { 7, 49, 3 }, { 6, 49, 4 }, { 5, 50, 3 }, { 4, 50, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout from the left seed
local sp = { { 21, 43 }, { 18, 37 }, { 24, 32 }, { 24, 27 } }
local sm, sn = G.tube(sp, function(t) return 1.05 end)
sm:cut(seeds[1].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function leafB(ax, ay, cx, cy, bx, by, w, veins)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.92 + 0.06)) ^ 0.62)
  end, { fold = 0.35 })
  G.toneN(c, m, n, LEAF, { tok = ltok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.14 and t > 0.08 and t < 0.88 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
    if veins then
      local ph = (t * L - abs(s) * 3.5) / 3.6
      local f = abs((ph - floor(ph)) - 0.5) * 2
      if f > 0.84 and abs(s) > 0.2 and abs(s) < 0.75 and t > 0.12 and t < 0.85 then c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) end
    end
  end)
  return m, n
end
local cl = leafB(23, 28, 18, 26, 11, 23, 2.4)
local cr = leafB(25, 28, 31, 28, 38, 25, 2.4)
-- first true leaf: short petiole then ovate glossy blade
D.line(c, { { 24, 27 }, { 25, 23 } }, STEM[2], stok)
local tm, tn = leafB(25, 23, 26, 16, 32, 10, 3.6, true)
do local bx, by = G.specAt(tm, tn, 40) if bx then c:put(bx, by, D.CREAM, ltok) c:put(bx, by + 1, GLOSS, ltok) end end
-- AO where the cotyledons meet the stem
c:put(24, 29, STEM[1], stok)

-- seeds last
for i, s in ipairs(seeds) do
  local tok = D.tok("seed" .. i)
  local sb = {}
  if i == 1 then X.ao(sb, s.m, sm, 1, -1) end
  local idx = G.toneN(c, s.m, s.n, SEED, { tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.86 }, amb = 0.08, wrap = 0.2, bias = sb })
  -- flat seed: a lighter keel ridge along the long axis, darker groove under it
  local ca, sa = cos(s[5]), sin(s[5])
  s.m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    if i == 2 then
      -- cut face: cream endosperm inside a 1 px brown coat
      if u * u + v * v < 0.62 then
        local j = (v < -0.25) and 4 or (v > 0.35 or u > 0.55) and 2 or 3
        c:put(x, y, CUT[j], tok)
      end
    else
      if abs(v + 0.05) < 0.12 and abs(u) < 0.7 then c:put(x, y, SEED[min(6, (idx[k] or 3) + 1)], tok) end
      if abs(v - 0.3) < 0.12 and abs(u) < 0.6 then c:put(x, y, SEED[max(1, (idx[k] or 3) - 1)], tok) end
    end
  end)
  if i == 1 then
    local bx, by = G.specAt(s.m, s.n, 30)
    if bx then c:put(bx, by, SEED[6], tok) c:put(bx + 1, by, SEED[6], tok) end
  end
end
-- quirk: the "spoon" embryo (bowl + handle) on the cut face of seed 2
local s2tok = D.tok("seed2")
c:paint({
  ".ww......",
  "wwwhhhhh.",
  ".ww......",
}, 31, 45, { w = "#fff8ea", h = "#f6ead0" })
c:put(32, 46, "#ffffee", s2tok)

D.save(c, NAME)
