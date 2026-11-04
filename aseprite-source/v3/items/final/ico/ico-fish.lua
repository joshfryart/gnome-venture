-- ico-fish (final, Opus single pass). A slim river trout swimming left with a slight upward arch: olive-teal
-- spotted back, a pink lateral stripe, a cream belly, forked gold-orange tail, dorsal, pectoral and belly fins.
-- Material: per-pixel tube light (6 tones per band, cool-violet shade), lattice scale ticks, gill-cover arc with a
-- lit lip, fin rays, wet specular on the shoulder, cool reflected light along the belly, AO under the pectoral fin
-- and where the fins join the body. Gold-ringed eye (2x3 ink pill + glint), small ink mouth.
-- quirk: a single water droplet flicks off the top tail lobe.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, sin, pi, atan = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.pi, math.atan
local c = A.new("ico-fish")

local BACK   = { "#142c48", "#1c4a6a", "#22707e", "#2e9288", "#4cb494", "#8ad8a8" }
local STRIPE = { "#5a2448", "#8e3a5c", "#c8546e", "#ea7a84", "#fa9e9a", "#ffc8b8" }
local BELLY  = { "#6a5470", "#9a8494", "#c8b6b0", "#e6d8c4", "#f6ead2", "#fff6e2" }
local FIN    = { "#6a2a2a", "#a8452a", "#d86a2c", "#f29a3a", "#ffc45a", "#ffe48e" }
local SPOT, BOUNCE, SPEC = "#1c2c3c", "#9cc4e4", "#fff4d6"

-- body tube, snout (t=0) on the left
local P = { { 11, 33 }, { 21, 26 }, { 36, 25 }, { 46, 30 } }
local function hw(t)
  local u = min(1, t / 0.97)
  return 2.0 + 7.8 * sin(pi * u ^ 0.72) * (1 - 0.15 * t)
end
local bm, bn, BT, BS, samp = A.tube(P, hw)

-- fins (behind the body), each with rays fanning from its root
local function fin(poly, rx, ry, bias)
  local m = c:poly(poly)
  local n = X.pillow(m, 1.6)
  local v = A.val(n, { amb = 0.12, wrap = 0.3 })
  local b = bias or {}
  m:each(function(x, y) local k = K(x, y)
    local a = atan(y - ry, x - rx)
    if floor(a * 9) % 2 == 0 and (x - rx) ^ 2 + (y - ry) ^ 2 > 6 then b[k] = (b[k] or 0) - 1 end
  end)
  X.ao(b, m, bm, 1, -1)
  X.tone(c, m, v, FIN, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, bias = b, tok = A.tok("fin") })
  return m
end
local tail = c:poly{ { 44, 29 }, { 49, 25 }, { 55, 18 }, { 57, 21 }, { 53, 30 }, { 57, 40 }, { 55, 43 }, { 49, 35 }, { 44, 33 } }
do
  local n = X.pillow(tail, 1.8)
  local v = A.val(n, { amb = 0.12, wrap = 0.3 })
  local b = {}
  tail:each(function(x, y) local k = K(x, y)
    local a = atan(y - 31, x - 44)
    if floor(a * 10 + 0.5) % 2 == 0 and x > 47 then b[k] = -1 end
  end)
  X.tone(c, tail, v, FIN, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, bias = b, tok = A.tok("tail") })
end
fin({ { 24, 20 }, { 27, 15 }, { 32, 14 }, { 36, 17 }, { 37, 21 } }, 30, 22)       -- dorsal
fin({ { 29, 37 }, { 31, 42 }, { 35, 41 }, { 35, 37 } }, 31, 36)                    -- belly (pelvic)
fin({ { 39, 34 }, { 42, 39 }, { 44, 37 }, { 43, 32 } }, 40, 33)                    -- anal

-- body: band by signed offset across the tube (S<0 = back)
local band = {}
bm:each(function(x, y) local k = K(x, y)
  local s = BS[k] + 0.08 * sin(BT[k] * 7)
  band[k] = s < -0.1 and 1 or (s < 0.4 and 2 or 3)
end)
local RAMPS = { BACK, STRIPE, BELLY }
local v = A.val(bn, { amb = 0.08, wrap = 0.3 })
local idx = {}
local btok = A.tok("body")
-- pectoral fin mask (painted later); cast its AO now
local pec = c:poly{ { 20, 34 }, { 22, 33 }, { 29, 37 }, { 27, 40 }, { 23, 39 } }
local bias = {}
A.cast(bias, bm, pec, 1, 1, -1)
-- gill cover arc
local gx, gy = 9.5, 31
bm:each(function(x, y) local k = K(x, y)
  local val = v[k]
  local i = 1
  for j, t in ipairs{ 0.3, 0.46, 0.6, 0.74, 0.88 } do if val >= t then i = j + 1 end end
  i = i + (bias[k] or 0)
  if band[k] == 3 then i = i + 1 end
  if BS[k] < -0.7 then i = i - 1 end
  local r = sqrt((x - gx) ^ 2 + (y - gy) ^ 2)
  if x > gx and r >= 7.3 and r < 8.4 and BS[k] > -0.85 and BS[k] < 0.85 then i = 1 elseif x > gx and r >= 6.2 and r < 7.3 then i = i + 1 end
  -- scale ticks on the flank (lattice, staggered rows)
  if BT[k] > 0.33 and BT[k] < 0.9 and band[k] ~= 3 and (y % 3 == 0) and ((x + (y // 3) * 2) % 4 == 0) then i = i - 1 end
  -- tail peduncle darkens toward the tail
  if BT[k] > 0.9 then i = i - 1 end
  i = max(1, min(6, i))
  idx[k] = i
  c:put(x, y, RAMPS[band[k]][i], btok)
end)
-- trout spots on the back
for _, p in ipairs{ { 24, 24 }, { 29, 22 }, { 33, 25 }, { 37, 23 }, { 41, 26 }, { 28, 27 }, { 44, 29 } } do
  if bm:has(p[1], p[2]) then c:put(p[1], p[2], SPOT, btok) end
end
-- cool reflected light along the belly edge
bm:edge():each(function(x, y) local k = K(x, y)
  if BS[k] > 0.75 and BT[k] > 0.22 and BT[k] < 0.8 then c:put(x, y, BOUNCE, btok) end end)
-- wet specular streak on the shoulder + one glint
for i, t in ipairs{ 0.2, 0.24, 0.28, 0.32 } do
  local s = samp[floor(t * 160) + 1]
  c:put(floor(s.x - s.px * s.w * 0.55 + .5), floor(s.y - s.py * s.w * 0.55 + .5), BACK[6], btok)
end
do local s = samp[floor(0.22 * 160) + 1]
  c:put(floor(s.x - s.px * s.w * 0.55 + .5), floor(s.y - s.py * s.w * 0.55 + .5) - 1, SPEC, btok) end

-- pectoral fin (over the body) with rays and a dark root
do
  local n = X.pillow(pec, 1.2)
  local v2 = A.val(n, { amb = 0.15, wrap = 0.3 })
  local b = {}
  pec:each(function(x, y) local k = K(x, y)
    if (x + y) % 3 == 0 then b[k] = -1 end
    if x <= 21 then b[k] = -2 end
  end)
  X.tone(c, pec, v2, FIN, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, bias = b, tok = A.tok("pec") })
end

-- eye: gold ring, ink pill, glint
A.map(c, {
  ".gg.",
  "gKKg",
  "gKKd",
  "gKKd",
  ".dd.",
}, 12, 27, { g = "#f5c04a", d = "#b87a2a", K = "#2b1c26" }, A.tok("eye"))
c:put(13, 28, "#fff4d6")
-- mouth
c:put(9, 35, "#2b1c26") c:put(10, 35, "#2b1c26") c:put(11, 34, "#5a2c50")

-- quirk: a droplet flicked off the top tail lobe (bright rim, pale core)
A.map(c, {
  ".s.",
  "sws",
  "sbs",
  ".s.",
}, 52, 11, { s = "#5fc4c8", w = "#e4f6ff", b = "#b6f0e0" }, A.tok("drop"))

A.save(c, "ico-fish")
