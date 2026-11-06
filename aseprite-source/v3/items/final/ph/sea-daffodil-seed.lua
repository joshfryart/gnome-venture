-- sea-daffodil-seed (final, single pass by artist aD14_5). Pancratium seeds: three black, glossy, angular wedges (lit
-- facet, dark facet, blue-violet reflected edge) resting on a long glaucous strap-leaf scrap that sags in a shallow
-- smile (four parallel veins, waxy bloom freckles, torn left end, notched right end, AO + contact shadow).
-- A fourth seed has sprouted: a pale bulb nub (papery brown tunic, root hairs) pushing two arching glaucous straps.
-- quirk: a tiny pink scallop shell has washed up on the scrap beside the seeds.
local NAME = "sea-daffodil-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD14_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local GL = { "#1a3a45", "#2a5b61", "#437f7c", "#68a698", "#97c9b4", "#d2ebd6" }
local COOL, BLOOM = "#3b6f8a", "#e4f4e6"
local BLK = { "#110e1a", "#1e1a2f", "#2f2a48", "#47416a", "#6f6a98", "#aeb0d6" }
local BULB = { "#7a6a78", "#a99aa0", "#d2c4bc", "#ecdfcc", "#fff0d8", "#fffaec" }
local TUN = { "#5a3a2c", "#8a5c3a", "#b8845a" }
local PINK = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8", "#fff0f2" }
local ltok = { r = { name = "leaf" } }

-- scrap: smile-shaped strap
local ax, ay, cx, cy, bx, by = 5, 48, 32, 68, 59, 49
local lm, ln, LT, LS, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
  if t > 0.99 then return -1 end
  local e = min(1, min(t * 9 + 0.35, (1 - t) * 9 + 0.7))
  return max(0.5, 5.4 * e ^ 0.6)
end, { fold = 0.25 })
local torn = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  -- ragged left tear (slanted), shallow V notch near the right end
  if t < 0.045 + (s + 1) * 0.03 + floor(G.hash(x // 2, y, 7) * 2) * 0.012 then torn[#torn + 1] = k end
  if t > 0.935 and abs(s) < (t - 0.935) * 12 then torn[#torn + 1] = k end
end)
for _, k in ipairs(torn) do lm.s[k] = nil end

-- seeds: black angular wedges, on the scrap (x positions), three flat-lying + the sprouting one
local function pos(t) local x, y = G.qb(ax, ay, cx, cy, bx, by, t) return floor(x + 0.5), floor(y + 0.5) end
local wedges = {}
local function wedge(cxw, cyw, pts)
  local pl = {}
  for i, p in ipairs(pts) do pl[i] = { cxw + p[1], cyw + p[2] } end
  local m = HP.poly(pl)
  wedges[#wedges + 1] = { m = m, cx = cxw, cy = cyw, pl = pl }
  return m
end
local w1x, w1y = pos(0.17)
local w2x, w2y = pos(0.3)
local w3x, w3y = pos(0.86)
wedge(w1x, w1y - 1, { { -4, 2.5 }, { -1, -3 }, { 4, -1.5 }, { 3.5, 2.8 } })
wedge(w2x + 1, w2y - 2, { { -3.5, 2.5 }, { 0, -3.5 }, { 4, 0 }, { 3, 3 } })
wedge(w3x - 1, w3y - 1, { { -4, 2 }, { 0, -3 }, { 4, -0.5 }, { 3.5, 2.8 } })
local bias = {}
for _, w in ipairs(wedges) do X.ao(bias, lm, w.m, 1, -1) G.cast(bias, lm, w.m, 1, 2, -1) end

-- shell position (quirk) on the leaf between seeds and bulb... right of centre
local shx, shy = pos(0.69)
shy = shy - 1
-- bulb sits mid scrap
local bx0, by0 = pos(0.5)
by0 = by0 - 2
local bulb = G.oval(bx0, by0, 3.9, 3.5, 0, 0.9)
X.ao(bias, lm, bulb, 1, -1) G.cast(bias, lm, bulb, 1, 2, -1)
local shm = HP.mask()
for dy = -3, 2 do for dx = -4, 4 do
  local ok = (dy <= 0 and (dx / 4.4) ^ 2 + (dy / 3.4) ^ 2 <= 1) or (dy > 0 and dy <= 1 and abs(dx) <= 1)
  if ok then shm:set(shx + dx, shy + dy) end
end end
X.ao(bias, lm, shm, 1, -1) G.cast(bias, lm, shm, 1, 2, -1)

G.toneN(c, lm, ln, GL, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.2, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  -- four parallel veins
  for _, vs in ipairs{ -0.62, -0.2, 0.22, 0.62 } do
    if abs(s - vs) < 0.075 and t > 0.07 and t < 0.94 then c:put(x, y, s < 0 and GL[5] or GL[2], ltok) end
  end
  if G.hash(x, y, 4) > 0.935 and t > 0.07 then c:put(x, y, BLOOM, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.1 and LT[k] < 0.92 then c:put(x, y, COOL, ltok) end end)

-- sprout: two arching straps from the bulb, drawn before the bulb so the nub sits over the foot
local gtok = { r = { name = "strap" } }
local function strap(p, w0)
  local m, n, T, S = G.tube(p, function(t) return max(0.55, w0 * (1 - t) ^ 0.5 * (0.55 + 0.45 * min(1, t * 5))) end)
  m:cut(bulb)
  G.toneN(c, m, n, GL, { tok = gtok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.16 and t > 0.08 and t < 0.9 then c:put(x, y, s <= 0 and GL[6] or GL[3], gtok) end
    if G.hash(x, y, 9) > 0.95 and t > 0.1 then c:put(x, y, BLOOM, gtok) end
  end)
  return m
end
strap({ { bx0 - 1, by0 - 2 }, { bx0 - 14, by0 - 10 }, { bx0 - 8, by0 - 34 }, { bx0 - 19, by0 - 38 } }, 2.7)
strap({ { bx0 + 1, by0 - 2 }, { bx0 + 4, by0 - 18 }, { bx0 + 14, by0 - 30 }, { bx0 + 19, by0 - 35 } }, 2.6)

-- bulb nub: pale, lit from the upper left, papery tunic scraps at the base, root hairs
local bn = select(2, G.oval(bx0, by0, 3.9, 3.5, 0, 0.9))
local btok = { r = { name = "bulb" } }
G.toneN(c, bulb, bn, BULB, { tok = btok, cuts = { 0.14, 0.3, 0.46, 0.64, 0.82 }, amb = 0.14, wrap = 0.3 })
bulb:each(function(x, y)
  if y >= by0 + 2 and (x + y) % 2 == 0 then c:put(x, y, TUN[1 + ((x + y) // 2) % 3], btok) end
end)
c:put(bx0 - 1, by0 - 2, BULB[6], btok) c:put(bx0, by0 - 2, BULB[6], btok)
c:put(bx0 - 2, by0 + 4, BULB[2], btok) c:put(bx0 + 2, by0 + 4, BULB[2], btok)
c:put(bx0, by0 + 4, TUN[2], btok)

-- wedge seeds: facet planes (lit upper-left facet, dark lower-right facet), bright chipped edge
for i, w in ipairs(wedges) do
  local n = X.pillow(w.m, 1.7)
  local tok = { r = { name = "wedge" .. i } }
  local ridge = (i % 2 == 0) and 1 or -1
  local v = X.light(n, { amb = 0.1, wrap = 0.25 })
  local b = {}
  w.m:each(function(x, y) local k = K(x, y)
    -- faceting: diagonal ridge line from upper-left to lower-right splits two planes
    local side = ((x - w.cx) * 0.7 + (y - w.cy) * ridge * -0.5) > 0.4
    b[k] = side and -1 or 1
  end)
  X.tone(c, w.m, v, BLK, { cuts = { 0.1, 0.26, 0.42, 0.6, 0.8 }, bias = b, tok = tok })
  -- bright edge facet on the upper-left boundary, cool reflected rim on the lower-right
  w.m:edge():each(function(x, y)
    if (not w.m:has(x - 1, y) or not w.m:has(x, y - 1)) and (x < w.cx + 2 and y < w.cy + 1) then c:put(x, y, BLK[6], tok) end
    if not w.m:has(x + 1, y) and not w.m:has(x, y + 1) then c:put(x, y, "#34305c", tok) end
  end)
  c:put(w.cx - 1, w.cy - 2, BLK[6], tok) c:put(w.cx, w.cy - 2, BLK[6], tok)
  c:put(w.cx + 1, w.cy + 1, BLK[1], tok)
end
-- quirk shell: scallop fan, ribbed, lit upper-left
do
  local st = { r = { name = "shell" } }
  local sn = X.pillow(shm, 1.6)
  local rib = {}
  shm:each(function(x, y) local k = K(x, y)
    local a = math.atan(x - shx, -(y - (shy + 2)))
    local r = floor((a + 1.6) / 0.42)
    rib[k] = (r % 2 == 0) and 0 or -1
  end)
  X.tone(c, shm, X.light(sn, { amb = 0.2, wrap = 0.3 }), { PINK[1], PINK[2], PINK[3], PINK[4], PINK[5] }, { cuts = { 0.3, 0.55, 0.78 }, bias = rib, tok = st })
  c:put(shx, shy + 1, PINK[1], st) c:put(shx - 1, shy + 1, PINK[2], st) c:put(shx + 1, shy + 1, PINK[2], st)
  c:put(shx - 2, shy - 2, PINK[5], st)
end
G.save2(c, NAME)
