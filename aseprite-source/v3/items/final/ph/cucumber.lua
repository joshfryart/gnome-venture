-- cucumber (final, Opus single pass). One slim, gently curved cucumber lying on the diagonal (stalk end
-- upper-right, blossom end lower-left). Material: per-pixel cylinder light (6-tone deep green, cool shade), pale
-- lengthwise stripes fading from the blossom end, raised warts (lit pixel + dark pixel under), a few prickle nubs on
-- the silhouette, waxy specular streak + glint, cool reflected light lower-right. Short ridged stalk with a pale
-- cut face and a coiled tendril; AO ring where stalk meets fruit; shrivelled flower at the blossom end.
-- quirk: one bright yellow petal still clings to the withered blossom, flapping open like a little flag.
local NAME = "cucumber"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB22_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.pi
local c = A.new(NAME)
local CU    = { "#10342e", "#1a4e3a", "#276b43", "#3e8c4c", "#68b05e", "#a6d886" }
local STRIPE = { "#4f9a58", "#7fbf6c" }
local STALK = { "#2a5a3a", "#4f8a4c", "#86b866", "#c4e09a" }
local DRY   = { "#5a3a22", "#8a6030", "#c09040" }
local PET   = { "#d98322", "#f5b82e", "#ffe38a" }
local COOL, SPEC = "#2f6f78", "#f4ffe0"

-- body
local p = { { 14, 50 }, { 24, 44 }, { 40, 34 }, { 50, 17 } }
local function hw(t) return 5.3 * sin(pi * min(1, t * 0.94 + 0.03)) ^ 0.28 end
local m, n, T, S, samp = A.tube(p, hw)
-- prickle nubs on the silhouette
for _, q in ipairs{ { 0.22, -1 }, { 0.41, -1 }, { 0.6, -1 }, { 0.33, 1 }, { 0.55, 1 }, { 0.76, 1 }, { 0.8, -1 } } do
  local s = samp[floor(q[1] * 160) + 1]
  local w = s.w + 0.9
  local x, y = floor(s.x + s.px * w * q[2] + .5), floor(s.y + s.py * w * q[2] + .5)
  if not m:has(x, y) then m:set(x, y) n[K(x, y)] = { s.px * q[2] * 0.9, s.py * q[2] * 0.9, 0.4 } T[K(x, y)] = q[1] S[K(x, y)] = q[2] * 0.95 end
end
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i - 1].x) ^ 2 + (samp[i].y - samp[i - 1].y) ^ 2) end
local bias = {}
m:each(function(x, y) local k = K(x, y) if T[k] > 0.965 then bias[k] = -1 end end)   -- AO round the stalk
local tok = { r = { name = "cucumber" } }
local idx = A.shade(c, m, n, CU, { tok = tok, bias = bias, amb = 0.05, wrap = 0.22, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
-- pale stripes from the blossom end (three, wavy, fading toward the stalk)
m:each(function(x, y) local k = K(x, y)
  local t, s = T[k], S[k]
  for j, s0 in ipairs{ -0.42, 0.05, 0.5 } do
    local wob = 0.06 * sin(t * LEN * 0.45 + j)
    local reach = 0.62 - j * 0.06
    if t > 0.04 and t < reach and abs(s - s0 - wob) < 0.1 + 0.05 * (1 - t / reach) then
      local i = idx[k]
      c:put(x, y, (i >= 4) and STRIPE[2] or (i >= 2 and STRIPE[1] or CU[3]), tok)
    end
  end
end)
-- warts: lit bump + shadow pixel under-right, on a staggered lattice
m:each(function(x, y) local k = K(x, y)
  local t, s = T[k], S[k]
  local a = t * LEN / 3.2
  local row = floor(a + 0.5)
  local off = (row % 2 == 0) and 0 or 0.5
  local b = s * 3.0 + off
  if abs(a - row) < 0.17 and abs(b - floor(b + 0.5)) < 0.17 and abs(s) < 0.85 and t > 0.06 and t < 0.94 then
    local i = idx[k]
    c:put(x, y, CU[min(6, i + 2)], tok)
    if m:has(x + 1, y + 1) then c:put(x + 1, y + 1, CU[max(1, i - 1)], tok) end
  end
end)
-- cool reflected light lower-right edge
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.6 and S[k] > 0.75 and T[k] > 0.1 and T[k] < 0.88 then c:put(x, y, COOL, tok) end end)
-- waxy specular streak on the lit shoulder + glint
for _, q in ipairs{ { 0.55, -0.55 }, { 0.6, -0.55 }, { 0.64, -0.52 }, { 0.68, -0.5 }, { 0.72, -0.5 }, { 0.3, -0.58 }, { 0.34, -0.58 } } do
  local s = samp[floor(q[1] * 160) + 1]
  c:put(floor(s.x + s.px * s.w * q[2] + .5), floor(s.y + s.py * s.w * q[2] + .5), CU[6], tok)
end
do local s = samp[floor(0.62 * 160) + 1]
  c:put(floor(s.x + s.px * s.w * -0.55 + .5), floor(s.y + s.py * s.w * -0.55 + .5), SPEC, tok) end

-- stalk: short, ridged, cut face pale
local stok = { r = { name = "stalk" } }
local skm, _, sT, sS = A.stem(c, { { 49, 18 }, { 51, 15 }, { 52, 13 }, { 54, 10 } }, function(t) return 1.5 - 0.2 * t end, STALK, { tok = stok, cut = m })
skm:each(function(x, y) local k = K(x, y) if abs(sS[k]) < 0.18 and sT[k] < 0.85 then c:put(x, y, STALK[2], stok) end end)
c:put(54, 9, STALK[4], stok) c:put(55, 9, STALK[3], stok) c:put(53, 9, STALK[3], stok) c:put(54, 10, STALK[3], stok)
-- coiled tendril off the stalk (1 px, lit/shade alternating)
local TD = { { 52, 14, 3 }, { 53, 15, 3 }, { 54, 16, 2 }, { 55, 16, 3 }, { 56, 15, 3 }, { 56, 14, 2 }, { 55, 13, 3 },
             { 54, 13, 2 } }
for _, q in ipairs(TD) do if not skm:has(q[1], q[2]) and not m:has(q[1], q[2]) then c:put(q[1], q[2], STALK[q[3]], stok) end end

-- withered blossom at the lower-left tip + quirk petal
local s0 = samp[1]
local bx, by = floor(s0.x - s0.tx * 2 + .5), floor(s0.y - s0.ty * 2 + .5)
local ftok = { r = { name = "blossom" } }
A.map(c, {
  ".ab",
  "abc",
  "bca",
}, bx - 1, by - 1, { a = DRY[2], b = DRY[3], c = DRY[1] }, ftok)
-- the petal: flaps open down-left
A.map(c, {
  "..abc",
  ".abb.",
  "abb..",
  "bb...",
}, bx - 5, by + 1, { a = PET[3], b = PET[2], c = PET[1] }, ftok)

A.save(c, NAME)
