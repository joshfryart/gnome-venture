-- leech-slime (final, Opus single pass). A tall teardrop of glossy translucent green slime settling into a small
-- puddle; a dark ringed leech is curled up inside, seen through the goo (darker, softened). Big wet specular streak,
-- cream sparkle, teal reflected light on the shade side, two trapped bubbles.
-- quirk: one fat drip is sliding off the right side, about to fall.
local NAME = "leech-slime"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC15_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local GOO = { "#14403a", "#1d6046", "#2c8a4c", "#4fb257", "#88d66e", "#c8f09a" }
local LEECH = { "#14201c", "#1f2f26", "#2c4230", "#3d5838", "#4f6e40", "#628548" }
local TEAL, CREAM = "#4fbfb0", "#fff4d6"

-- body: drop with a pointed, slightly bent tip
local body = HP.mask()
for y = 12, 52 do
  local hw
  if y < 34 then local f = (y - 12) / 22 hw = 0.6 + 11.2 * f ^ 1.15 else local f = (y - 34) / 18 hw = 11.8 + 1.4 * sin(f * pi * 0.5) - 6 * f ^ 4 end
  local cx = 32 + 2.2 * ((34 - min(34, y)) / 22) ^ 2
  for x = floor(cx - hw + 0.5), floor(cx + hw - 0.5) do body:set(x, y) end
end
-- puddle spreading at the foot
local pud = A.rell(32, 52, 1, 0, 17, 3.2)
pud:cut(body)
local pn = X.pillow(pud, 2, 0.6)
local ptok = { r = { name = "puddle" } }
local pidx = A.shade(c, pud, pn, GOO, { tok = ptok, cuts = { 0.25, 0.42, 0.58, 0.74, 0.9 }, amb = 0.05, wrap = 0.2 })
local pb = {}
X.ao(pb, pud, body, 1, -2)
for k, v in pairs(pb) do local x, y = k % 1024 - 256, k // 1024 - 256 A.step(c, pidx, GOO, x, y, v, ptok) end

local tok = { r = { name = "goo" } }
local n = A.body(body, 31, 38, 15, 7, 0.55)
local idx, v = A.shade(c, body, n, GOO, { tok = tok, amb = 0.08, wrap = 0.3, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
-- translucency: inner glow one step brighter at the core-low (light passing through)
body:each(function(x, y) local dx, dy = x - 34, y - 44
  if dx * dx / 50 + dy * dy / 18 < 1 then A.step(c, idx, GOO, x, y, 1, tok) end end)
-- teal reflected light on the lower-right rim
local rim = X.rim(n)
body:edge():each(function(x, y) local k = K(x, y) if rim[k] and rim[k] > 0.55 and y > 30 then c:put(x, y, TEAL, tok) end end)

-- the leech inside: curled C, ringed, softened by the goo
local lp = { { 25, 46 }, { 22, 36 }, { 32, 30 }, { 38, 38 } }
local lm, lnrm, LT, LS = A.tube(lp, function(t) return 2.4 * (0.55 + 0.45 * sin(pi * min(1, t * 0.9 + 0.1))) end)
lm:clip(body:shrink(2))
local ltok = { r = { name = "leech" } }
local li = A.shade(c, lm, lnrm, LEECH, { tok = ltok, amb = 0.1, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y)
  if (LT[k] * 22) % 1 < 0.22 then A.step(c, li, LEECH, x, y, -1, ltok) end   -- body rings
end)
-- sucker at the head end: small ring
do local hx, hy = A.bez(lp, 1) hx, hy = floor(hx + 0.5), floor(hy + 0.5)
  for _, d in ipairs{ { 1, 0 }, { 0, 1 }, { 1, 1 }, { 2, 1 }, { 1, 2 } } do c:put(hx + d[1] - 1, hy + d[2] - 1, LEECH[(d[1] == 1 and d[2] == 1) and 1 or 5], ltok) end end
-- goo still glazes over the leech: re-light its top-left pixels
lm:edge():each(function(x, y) if not lm:has(x - 1, y) and not lm:has(x, y - 1) then c:put(x, y, GOO[2], ltok) end end)

-- trapped bubbles
local btok = { r = { name = "bubble" } }
for _, b in ipairs{ { 39, 45, 1.5 }, { 27, 26, 1.0 } } do
  local m = A.rell(b[1], b[2], 1, 0, b[3] + 0.4, b[3] + 0.4)
  m:each(function(x, y) c:put(x, y, GOO[5], btok) end)
  m:edge():each(function(x, y) if x >= b[1] and y >= b[2] then c:put(x, y, GOO[3], btok) end end)
  c:put(floor(b[1] - 0.5), floor(b[2] - 0.5), GOO[6], btok)
end

-- wet specular streak along the upper-left curve + cream sparkle
local stk = { { 25, 33 }, { 24, 35 }, { 23, 37 }, { 23, 39 }, { 26, 31 } }
for _, p in ipairs(stk) do if body:has(p[1], p[2]) then c:put(p[1], p[2], GOO[6], tok) end end
c:put(24, 34, GOO[6], tok) c:put(27, 30, GOO[5], tok)
c:put(25, 32, CREAM, tok)
c:put(32, 17, GOO[6], tok) c:put(32, 18, GOO[5], tok)

-- quirk: a fat drip sliding off the right side, neck + drop
local dtok = { r = { name = "drip" } }
local drip = HP.mask()
for y = 38, 45 do drip:set(45, y) end
for y = 41, 46 do drip:set(46, y) end
drip:add(A.rell(46.5, 48, 1, 0, 2.2, 2.4))
drip:cut(body):cut(pud)
local dn = X.sphere(46.5, 47.5, 3, drip)
local didx = A.shade(c, drip, dn, GOO, { tok = dtok, amb = 0.1, wrap = 0.3 })
local gx, gy = A.specAt(drip, dn, 40) if gx then c:put(gx, gy, GOO[6], dtok) end

A.save(c, NAME)
