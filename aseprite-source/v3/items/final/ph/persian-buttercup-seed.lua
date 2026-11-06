-- persian-buttercup-seed (C33 slot 2, Opus single pass). A ranunculus "claw" (the dried tuberous root a Persian
-- buttercup is planted from): a knobbly brown crown with slim tapering fingers, ring-wrinkled skin, a papery fibre
-- tuft on top, sitting on a torn fan of a deeply cut, toothed ranunculus leaf (pale palmate veins, cool lower rim, AO
-- and contact shadows under every finger). A pale stem rises from the crown to a first three-lobed, toothed leaf and
-- a smaller second leaf, the plant's own leaf shape.
-- quirk: one claw finger is lifted off the leaf and curled up, like it is waving hello.
local NAME = "persian-buttercup-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = G.new3(NAME)

local LEAF = { "#163a3a", "#205441", "#2c7048", "#428f50", "#66ae5c", "#9ccc78" }
local SPR = { "#1d4a40", "#2a6648", "#3c8650", "#58a45a", "#84c46a", "#bce090" }
local CORM = { "#341e1e", "#53302a", "#774833", "#9c6641", "#c18a58", "#e3b47e" }
local FIB = { "#8a6a48", "#b8966a", "#dcc49a" }
local STEM = { "#5a8a52", "#8cba6a", "#bcd894", "#e6f2c0" }
local VEIN, COOL = "#c2e294", "#3a6a74"

-- claw geometry: crown + fingers (bezier paths, tip last); finger 5 is the waving one
local CX, CY = 30, 45
local fingers = {
  { { 28, 46 }, { 24, 48 }, { 20, 49 }, { 15, 52 } },
  { { 29, 47 }, { 27, 51 }, { 24, 53 }, { 22, 57 } },
  { { 31, 48 }, { 31, 52 }, { 33, 54 }, { 32, 58 } },
  { { 33, 47 }, { 37, 50 }, { 40, 52 }, { 44, 54 } },
  { { 34, 44 }, { 39, 42 }, { 43, 40 }, { 44, 35 } },
}
local claw, fm = HP.mask(), {}
for i, p in ipairs(fingers) do
  local m, n, T, S = G.tube(p, function(t) return 1.75 * (1 - t) ^ 0.7 + 0.35 end)
  fm[i] = { m = m, n = n, T = T, S = S }
  claw:add(m)
end
local crown, crn = G.oval(CX, CY, 4.2, 3.4, -0.2, 0.9)
claw:add(crown)
local flat = claw:copy():cut(fm[5].m)   -- everything that lies on the leaf

-- leaf scrap: toothed palmate fan, torn along the right
local lm, ln, inf = G.palm(30, 60, { { -2.55, 21 }, { -1.95, 25 }, { -1.35, 25 }, { -0.75, 22 } }, { sharp = 2.4, floor = 0.32, serr = true, spread = 2.2, fold = 0.6 })
G.tear(lm, 47, 36, 50, 62, 1.6, 9)
local bias = {}
X.ao(bias, lm, flat, 1, -1) G.cast(bias, lm, flat, 1, 1, -1) G.cast(bias, lm, flat, 2, 2, -1)
G.cast(bias, lm, fm[5].m, 2, 4, -1)                 -- lifted finger casts a detached shadow
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, amb = 0.12, wrap = 0.25, cuts = { 0.2, 0.36, 0.52, 0.68, 0.85 } })
lm:each(function(x, y) local k = K(x, y) local f = inf[k]
  if bias[k] then return end
  if abs(f.da) * f.r < 0.6 and f.r > 1 and f.r < f.R - 1.5 then c:put(x, y, VEIN, ltok) return end
  local off = abs(f.da) * f.r
  if off > 1.2 and off < f.R * 0.3 and abs((f.r - off * 1.3) % 5 - 2.5) < 0.5 and f.r < f.R - 2 then
    c:put(x, y, f.da < 0 and LEAF[5] or LEAF[2], ltok) end
end)
local rim = X.rim(ln)
lm:edge():each(function(x, y) local k = K(x, y) if not bias[k] and rim[k] > 0.25 and y > 48 then c:put(x, y, COOL, ltok) end end)
-- petiole stub
for _, q in ipairs{ { 30, 61, 4 }, { 30, 62, 3 }, { 31, 62, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout: stem from the crown top, three-lobed toothed first leaf, small second leaf
local stok = { r = { name = "stem" } }
local sm, sn = G.tube({ { 30, 42 }, { 28.5, 36 }, { 32, 30 }, { 30.5, 23 } }, function(t) return 0.9 end)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function rleaf(bx, by, lobes, tok)
  local m, n, info = G.palm(bx, by, lobes, { sharp = 2.0, floor = 0.34, serr = true, spread = 2.0, fold = 0.6 })
  m:cut(sm)
  G.toneN(c, m, n, SPR, { tok = tok, amb = 0.14, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  m:each(function(x, y) local f = info[K(x, y)]
    if abs(f.da) * f.r < 0.5 and f.r > 1 and f.r < f.R - 1.2 then c:put(x, y, SPR[6], tok) end end)
  return m
end
rleaf(30.5, 23, { { -2.45, 8.5 }, { -1.57, 10 }, { -0.7, 8.5 } }, { r = { name = "true1" } })
local l2 = rleaf(28.5, 34, { { -3.0, 6 }, { -2.3, 6.5 }, { 2.9, 5 } }, { r = { name = "true2" } })

-- claw: fingers first (back to front), then the crown over their roots
local order = { 5, 1, 4, 2, 3 }
for _, i in ipairs(order) do
  local f = fm[i]
  local tok = { r = { name = "finger" .. i } }
  local vis = f.m:copy():cut(crown)
  local b = {} X.ao(b, vis, crown, 1, -1)
  local idx = G.toneN(c, vis, f.n, CORM, { tok = tok, bias = b, amb = 0.12, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.68, 0.86 } })
  -- ring wrinkles across the finger
  vis:each(function(x, y) local k = K(x, y)
    local ph = (f.T[k] * 14) % 2.6
    if ph < 0.5 and f.T[k] > 0.12 and f.T[k] < 0.9 then c:put(x, y, CORM[max(1, (idx[k] or 3) - 1)], tok) end end)
end
do
  local tok = { r = { name = "crown" } }
  local cb = {} X.ao(cb, crown, sm, 1, -1)
  local idx = G.toneN(c, crown, crn, CORM, { tok = tok, bias = cb, amb = 0.12, wrap = 0.3, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 } })
  -- knobbly pits
  for _, q in ipairs{ { 28, 46 }, { 32, 47 }, { 33, 44 } } do c:put(q[1], q[2], CORM[max(1, (idx[K(q[1], q[2])] or 3) - 2)], tok) end
  local bx, by = G.specAt(crown, crn, 30) if bx then c:put(bx, by, "#f4d6a4", tok) end
  -- papery fibre tuft round the stem foot
  local ftok = { r = { name = "fibre" } }
  for _, q in ipairs{ { 27, 42, 2 }, { 26, 41, 3 }, { 28, 41, 1 }, { 32, 42, 2 }, { 33, 41, 3 }, { 32, 41, 1 }, { 29, 42, 2 }, { 31, 42, 1 } } do
    c:put(q[1], q[2], FIB[q[3]], ftok) end
end
-- the waving finger's tip curls back toward the crown
c:put(43, 34, CORM[4], { r = { name = "finger5" } }) c:put(42, 34, CORM[3], { r = { name = "finger5" } })
G.done(c, NAME)
