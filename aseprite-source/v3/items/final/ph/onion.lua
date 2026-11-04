-- onion (final pass, Opus aC31_1). Slim golden teardrop bulb on a twisted dry neck, two thin hollow green shoots,
-- a tan basal plate with a splayed tuft of wiry roots. Material: per-pixel round light (6-tone amber, violet shade),
-- papery meridian veins (dark line + lit lip on the light half), waxy specular streak upper-left, cool reflected
-- light lower-right, AO where neck and bulb meet, twist marks on the neck, paler tubular shoots with a lit edge.
-- quirk: one papery skin flap has peeled back and curls off the right side, showing the pale pink layer beneath.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "onion"
local c = A.new(NAME)
local SKIN = { "#5a2232", "#93402a", "#c4692a", "#e3953a", "#f4bf5e", "#ffe49c" }
local NECK = { "#5e3a2c", "#8a5a36", "#b4844e", "#d8ae72", "#f0d29a" }
local LEAF = A.LEAF
local FLESH = { "#b8879e", "#e0bcc6", "#f8e2e0" }
local COOL, SPEC = "#9a5a72", "#fff4d6"

-- shoots first (neck paints over their feet)
local function shoot(ax, ay, cx, cy, bx, by, wd)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.98 then return -1 end
    return max(0.3, wd * (1 - t) ^ 0.45)
  end, { fold = 0.25 })
  local tok = { r = { name = "shoot" } }
  local idx = A.shade(c, m, n, LEAF, { tok = tok, amb = 0.12, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if S[k] < -0.3 and T[k] > 0.08 and T[k] < 0.8 then A.step(c, idx, LEAF, x, y, 1, tok) end end)
  return m
end
local sl = shoot(32, 16, 28, 10, 23, 8, 1.35)
local sr = shoot(33, 16, 37, 9, 41, 6, 1.45)

-- bulb: teardrop, widest a little below the middle
local TOP, BOT, CX = 22, 50, 32
local function hw(y)
  local t = (y - TOP) / (BOT - TOP)
  if t <= 0 or t >= 1 then return -1 end
  return 12.2 * sin(pi * t ^ 1.3) ^ 0.62
end
local bm = HP.mask()
for y = TOP, BOT do local w = hw(y) if w > 0.4 then
  for x = floor(CX - w + 0.5), floor(CX + w - 0.5 + 1) - 1 do bm:set(x, y) end end end
-- neck tube
local np = { { 32, 26 }, { 32, 21 }, { 33, 18 }, { 33, 14 } }
local nm, nn, NT, NS = A.tube(np, function(t) return 2.7 - 1.3 * t end)
nm:cut(bm)

local n = A.mix(X.pillow(bm, 6), X.sphere(CX, 38, 14, bm), 0.55)
local bias = {}
X.ao(bias, bm, nm, 1, -1)
local btok = { r = { name = "bulb" } }
local idx = A.shade(c, bm, n, SKIN, { tok = btok, bias = bias, amb = 0.05, wrap = 0.2 })
-- meridian veins from the neck to the root plate
bm:each(function(x, y) local w = hw(y) local t = (y - TOP) / (BOT - TOP)
  if t < 0.14 or t > 0.93 then return end
  local s = (x - CX) / w
  for _, kk in ipairs{ -0.7, -0.36, 0.02, 0.38, 0.72 } do
    local d = (s - kk) * w
    if d > -0.5 and d <= 0.5 then A.step(c, idx, SKIN, x, y, -1, btok)
    elseif kk < 0.1 and d > -1.5 and d <= -0.5 and idx[K(x, y)] >= 3 then A.step(c, idx, SKIN, x, y, 1, btok) end
  end
end)
-- cool reflected light lower-right
local rim = X.rim(n)
bm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.62 and y > 33 and y < BOT - 1 and x > CX + 3 then c:put(x, y, COOL, btok) end end)
-- specular streak + glint (waxy)
for _, p in ipairs{ { 25, 31 }, { 24, 32 }, { 24, 33 }, { 24, 34 }, { 25, 30 } } do c:put(p[1], p[2], SKIN[6], btok) end
c:put(25, 32, SPEC, btok)

-- neck: dry, twisted
local ntok = { r = { name = "neck" } }
local nidx = A.shade(c, nm, nn, NECK, { tok = ntok, cuts = { 0.22, 0.42, 0.62, 0.82 }, amb = 0.1, wrap = 0.3 })
nm:each(function(x, y) local k = K(x, y)
  local ph = NT[k] * 12 + NS[k] * 1.6
  if ph % 3 < 0.8 then A.step(c, nidx, NECK, x, y, -1, ntok) end
  if NT[k] < 0.18 then A.step(c, nidx, NECK, x, y, -1, ntok) end
end)

-- basal plate + wiry roots
local plate = c:rect(29, BOT, 35, BOT + 1)
local ptok = { r = { name = "plate" } }
plate:each(function(x, y) c:put(x, y, (y == BOT and x < 33) and NECK[3] or NECK[2], ptok) end)
local rtok = { r = { name = "root" } }
local roots = { { 29, -3, 4 }, { 30, -1.5, 6 }, { 32, 0, 7 }, { 33, 1, 5 }, { 34, 2.2, 6 }, { 35, 3.5, 4 } }
for i, r in ipairs(roots) do
  for j = 1, r[3] do
    local f = j / r[3]
    local x = floor(r[1] + r[2] * f + sin(j * 1.3 + i) * 0.6 + 0.5)
    c:put(x, BOT + 1 + j, (j < 3 or i % 2 == 0) and "#e9d6aa" or "#c09a6e", rtok)
  end
end

-- quirk: peeled skin flap curling off the right side, pale pink layer showing beneath
local ftok = { r = { name = "flesh" } }
for y = 33, 38 do local w = hw(y)
  local xe = floor(CX + w - 0.5 + 1) - 1
  for x = xe - 3 + floor((y - 33) * 0.4), xe do
    local i = (x == xe or y == 38) and 1 or ((x - y) % 4 == 0 and 3 or 2)
    c:put(x, y, FLESH[i], ftok)
  end
end
c:put(43 - 2, 34, FLESH[3], ftok)
local xe = floor(CX + hw(32) - 0.5 + 1) - 1
A.map(c, {
  "...a",
  "..ab",
  ".abc",
  "abcd",
}, xe - 1, 29, { a = "#ffe49c", b = "#f4bf5e", c = "#c4692a", d = "#93402a" }, { r = { name = "flap" } })

A.save(c, NAME)
