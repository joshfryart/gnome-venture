-- sesame (D15 redraw, Opus-grade single pass). The whole plant, slim and upright: a faintly grooved square stem with
-- node bands, three pairs of lance leaves (broad ovate low, narrow high) arching out and drooping, tan-and-green
-- seed capsules hugging the stem in the leaf axils (ridged, with a groove, a beak and a fuzz of hairs), and two pale
-- pink bell flowers with plum throats hanging off the top axils, a pink bud at the tip.
-- Light: per-pixel on every part, contact shadows where capsules meet stem and leaf, cool reflected edge on leaves.
-- quirk: one ripe tan capsule has split its beak and three cream seeds are tumbling out of it.
local NAME = "sesame"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD15_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STEM = { "#2c5a3a", "#468648", "#74b05a", "#a2cd70", "#cde58f", "#ecf6b8" }
local CAPG = { "#2f5231", "#46753a", "#6c9a46", "#93bb55", "#bcd873", "#e0efa0" }
local CAPT = { "#4a2e22", "#7a5030", "#a8793f", "#cba058", "#e6c378", "#f8e6a8" }
local FL   = { "#6a4a78", "#9a6c96", "#cf9ab4", "#eebccb", "#fbdcdc", "#fff0e2" }
local THR  = { "#3e2248", "#6a3a62", "#9a5a80" }
local SEEDC = { "#8a6e4c", "#b09468", "#d6bc8a", "#ecd8a8", "#f8ecc4", "#fff6dc" }
local COOL = "#3a6c72"

local sp = { { 32, 57 }, { 30, 45 }, { 34, 29 }, { 32, 9 } }
local sm, sn, sT, sS = A.tube(sp, function(t) return 1.75 - 0.75 * t end)

-- leaves ---------------------------------------------------------------------------------------------
local ltok = { r = { name = "leaf" } }
local lmask, lidx = HP.mask(), {}
local function leaf(a, cc, b, w, o)
  o = o or {} o.tok = ltok
  local m, idx, _, T, S, len = A.leafB(c, a[1], a[2], cc[1], cc[2], b[1], b[2], w, o)
  local ao = A.ring(m, sm, 1)
  A.darken(c, ao, idx, LEAF, ltok)
  A.veins(c, m, T, S, len, LEAF, o.veins or { 0.24, 0.38, 0.52, 0.66, 0.8 }, ltok, ao)
  m:edge():each(function(x, y) local k = K(x, y) if S[k] > 0.66 and T[k] > 0.12 and T[k] < 0.86 then c:put(x, y, COOL, ltok) end end)
  lmask:add(m)
  m:each(function(x, y) lidx[K(x, y)] = idx[K(x, y)] end)
  return m
end
-- top pair first, lowest last (low leaves overlap in front)
leaf({ 31, 31.5 }, { 23, 29 }, { 16, 35 }, 3.2, { serr = 2.6 })
leaf({ 34, 29.5 }, { 41, 25 }, { 48, 28 }, 3.2, { serr = 2.6 })
leaf({ 30.5, 41 }, { 22, 36 }, { 14, 42 }, 4.2, { serr = 2.8 })
leaf({ 33, 38.5 }, { 42, 34 }, { 50, 39 }, 4.2, { serr = 2.8 })
leaf({ 30.5, 51 }, { 20, 45 }, { 11, 54 }, 5.0, { serr = 3.0 })
leaf({ 33, 51 }, { 44, 46 }, { 54, 53 }, 5.0, { serr = 3.0 })

-- stem -----------------------------------------------------------------------------------------------
local stok = { r = { name = "stem" } }
local sidx = A.toneN(c, sm, sn, STEM, { tok = stok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
local nodes = { 51, 41, 31 }
sm:each(function(x, y) local k = K(x, y) local s, t = sS[k], sT[k]
  if y >= 56 then c:put(x, y, STEM[y == 56 and 5 or 6], stok) return end
  for _, ny in ipairs(nodes) do if y == ny + 1 then c:put(x, y, STEM[max(1, sidx[k] - 1)], stok) return end end
  if s > 0.05 and s < 0.35 and t > 0.04 and t < 0.96 and X.hash(x, y, 3) > 0.12 then c:put(x, y, STEM[2], stok) end
end)

-- capsules (hug the stem, leaning slightly out) ---------------------------------------------------------
local function capsule(bx, by, tx, ty, w, ramp, burst)
  local p = { { bx, by }, { bx + (tx - bx) / 3, by + (ty - by) / 3 }, { bx + 2 * (tx - bx) / 3, by + 2 * (ty - by) / 3 }, { tx, ty } }
  local m, n, T, S = A.tube(p, function(t) return max(0.55, w * (1 - t ^ 2.4) ^ 0.55) end)
  -- contact shadow on stem and leaf first
  A.darken(c, A.ring(sm, m, 1), sidx, STEM, stok)
  A.darken(c, A.ring(lmask, m, 1):add(A.under(lmask, m, 1, 1)), lidx, LEAF, ltok)
  local ctok = { r = { name = "cap" .. bx } }
  local idx = A.toneN(c, m, n, ramp, { tok = ctok, cuts = { 0.18, 0.34, 0.5, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if t < 0.1 then c:put(x, y, LEAF[s < 0 and 4 or 3], ctok)
    elseif abs(s) < 0.13 and t < 0.9 then c:put(x, y, ramp[max(1, idx[k] - 2)], ctok)
    elseif s < -0.72 and t > 0.2 and t < 0.8 and X.hash(x, y, 7) > 0.55 then c:put(x, y, ramp[6], ctok) end
    if burst and t > 0.84 and abs(s) < 0.34 then c:put(x, y, "#4a2a22", ctok) end
  end)
  return m
end
capsule(28.8, 40.5, 27.4, 32, 2.0, CAPG)
local burstTop = { 37.2, 33 }
capsule(35.6, 41.5, burstTop[1], burstTop[2], 2.1, CAPT, true)
capsule(36.2, 29, 37.4, 21.5, 1.9, CAPG)
-- quirk: curled-back valve flecks at the split beak
c:put(36, 33, CAPT[5], { r = { name = "valve" } }) c:put(39, 33, CAPT[3], { r = { name = "valve" } })
-- seeds tumbling out
local sk = { r = { name = "seeds" } }
for _, q in ipairs{ { 39, 35 }, { 41, 38.5 }, { 39.5, 42 } } do
  local x, y = floor(q[1]), floor(q[2])
  c:put(x, y, SEEDC[6], sk) c:put(x + 1, y, SEEDC[4], sk) c:put(x, y + 1, SEEDC[2], sk) c:put(x + 1, y + 1, SEEDC[2], sk)
  c:put(x, y - 1, SEEDC[5], sk)
end

-- flowers: hanging bells -------------------------------------------------------------------------------
local function flower(p, ftok)
  local m, n, T, S = A.tube(p, function(t) return 1.2 + 2.2 * t ^ 1.1 end)
  A.darken(c, A.ring(sm, m, 1), sidx, STEM, stok)
  A.toneN(c, m, n, FL, { tok = ftok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 }, amb = 0.12, wrap = 0.3 })
  local ex, ey = floor(p[4][1] + 0.5), floor(p[4][2] + 0.5)
  local mouth = A.ell(ex, ey + 0.6, 2.9, 1.5, 0)
  mouth:each(function(x, y) c:put(x, y, y <= ey and THR[1] or THR[2], ftok) end)
  c:put(ex - 1, ey + 1, THR[3], ftok) c:put(ex + 1, ey + 1, THR[3], ftok)
  for dx = -2, 2 do c:put(ex + dx, ey + 2, FL[abs(dx) == 2 and 3 or 5], ftok) end
  c:put(ex - 1, ey + 3, FL[4], ftok) c:put(ex + 1, ey + 3, FL[3], ftok)
  m:each(function(x, y) local k = K(x, y)
    if T[k] > 0.55 and T[k] < 0.85 and S[k] > 0.2 and X.hash(x, y, 5) > 0.7 then c:put(x, y, FL[2], ftok) end end)
  c:put(ex - 3, ey - 1, FL[6], ftok)
  return m
end
flower({ { 31, 25.5 }, { 28, 23 }, { 25.5, 24 }, { 25, 28 } }, { r = { name = "flowerL" } })
flower({ { 33.5, 19 }, { 36.5, 17.5 }, { 39.5, 19 }, { 40, 23.5 } }, { r = { name = "flowerR" } })

-- tip: pink bud between two small sepal leaves ----------------------------------------------------------
local bk = { r = { name = "bud" } }
leaf({ 32.2, 13.5 }, { 30, 10.5 }, { 27.5, 9.5 }, 1.4, {})
leaf({ 32.6, 13.5 }, { 35, 10.5 }, { 37.5, 9.5 }, 1.4, {})
local bud = A.ell(32.4, 10.4, 1.5, 2.5, 0)
A.lit2(c, bud, FL, 1.5, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 } })
c:put(32, 12, LEAF[4], bk) c:put(33, 12, LEAF[3], bk)

A.save2(c, NAME)
