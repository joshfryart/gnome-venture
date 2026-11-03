-- ico-peach (final, Opus single pass). Round peach with two soft cheeks split by an S-curved suture crease,
-- rosy blush on the upper shoulders fading to a gold-yellow belly; short twig stem with pale end grain and one
-- slim leaf. Material: per-pixel sphere light (6-tone blush + 6-tone gold), velvety fuzz bloom on the lit rim,
-- grooved crease (dark groove, lit lip on the far cheek), sunken stem cup (AO), cool violet bounce lower-right,
-- one soft specular. Leaf: midrib + side veins.
-- quirk: a caterpillar has nibbled a neat bite out of the leaf edge.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA8_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = A.new("ico-peach")
local BLUSH = { "#6a2340", "#a3304c", "#d4434c", "#ef6a50", "#ff9a64", "#ffc98a" }
local GOLD  = { "#7a3a2c", "#b85c32", "#e2873c", "#f6ac4c", "#ffcd70", "#ffe7a6" }
local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local WOOD  = { "#3e2622", "#5c3a2c", "#82553a", "#a7744c", "#c99566" }
local FUZZ, BOUNCE, SPEC = "#ffd9b0", "#9a4a7a", "#fff1d4"

-- body: two cheeks + core
local CX, CY = 32, 37
local body = c:ellipse(25.5, 37.5, 12, 14):add(c:ellipse(38.5, 37.5, 12, 14)):add(c:ellipse(32, 38, 13, 14))
-- soft dip at the top where the stem sits
body:cut(c:ellipse(32, 22.2, 2.6, 1.6))
local crease = function(y) return 32 + 1.6 * sin((y - 23) / 26 * pi * 1.1) end
local ns = X.sphere(CX, CY, 16, body)
local nl = X.sphere(25.5, 37.5, 13, body)
local nr = X.sphere(38.5, 37.5, 13, body)
local np = X.pillow(body, 5)
local n = {}
body:each(function(x, y) local k = K(x, y)
  local lobe = (x < crease(y)) and nl[k] or nr[k]
  local a, b = ns[k], np[k]
  n[k] = { A.norm(a[1] * 0.35 + lobe[1] * 0.4 + b[1] * 0.25, a[2] * 0.35 + lobe[2] * 0.4 + b[2] * 0.25, a[3] * 0.35 + lobe[3] * 0.4 + b[3] * 0.25) }
end)
local v = X.light(n, { amb = 0.06, wrap = 0.2 })
local bias = {}
-- stem cup AO
body:each(function(x, y) local d = ((x - 32) / 4.5)^2 + ((y - 23.5) / 2.6)^2
  if d < 1 then bias[K(x, y)] = -2 elseif d < 1.8 then bias[K(x, y)] = -1 end end)
local tok = { r = { name = "peach" } }
local idx = X.tone(c, body, v, BLUSH, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = bias, tok = tok })
-- gold belly: lower part of the fruit (wavy hard boundary), same tone index on the gold ramp
local function isGold(x, y) return y > 41 + 3.2 * sin(x * 0.33 + 0.6) + (x - 32) * 0.12 end
local RAMP = {}
body:each(function(x, y) local k = K(x, y)
  if isGold(x, y) then RAMP[k] = GOLD c:put(x, y, GOLD[idx[k]], tok) else RAMP[k] = BLUSH end end)
local function step(x, y, d) local k = K(x, y) if idx[k] then A.step(c, idx, RAMP[k], x, y, d, tok) end end
-- crease: groove + darker flank on the left cheek, lit lip on the right cheek
for y = 23, 50 do
  local xc = floor(crease(y) + 0.5)
  local fade = (y > 45) and 1 or 0
  if body:has(xc, y) then step(xc, y, y < 48 and -3 or -1) end
  if y < 46 then step(xc - 1, y, -1) end
  if y < 44 and body:has(xc + 1, y) then step(xc + 1, y, 1 - fade) end
end
-- fuzz bloom: pale velvet on the lit rim (upper-left edge pixels that are already light)
body:edge():each(function(x, y) local k = K(x, y)
  local nn = n[k]
  if nn[1] < -0.25 and nn[2] < 0.35 and idx[k] >= 4 then c:put(x, y, FUZZ, tok) end
end)
-- sparse fuzz flecks in the light mid-tones (hard single pixels)
body:each(function(x, y) local k = K(x, y)
  if idx[k] == 5 and X.hash(x, y, 7) > 0.9 then c:put(x, y, RAMP[k][6], tok) end end)
-- cool reflected light lower-right
local rim = X.rim(n)
body:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.62 and n[k][1] > 0.15 and n[k][2] > 0.15 then c:put(x, y, BOUNCE, tok) end end)
-- soft specular on the left cheek
c:put(20, 30, SPEC, tok) c:put(21, 30, SPEC, tok) c:put(20, 31, BLUSH[6], tok)

-- stem: short twig leaning right, 3 px
local stem = HP.mask()
for y = 15, 24 do local x0 = floor(31 + (24 - y) * 0.22 + 0.5) for x = x0, x0 + 2 do stem:set(x, y) end end
stem:each(function(x, y)
  local x0 = floor(31 + (24 - y) * 0.22 + 0.5)
  local i = (x == x0) and 4 or (x == x0 + 1 and 3 or 2)
  if y >= 22 then i = max(1, i - 1) end
  c:put(x, y, WOOD[i])
end)
-- pale end grain on the cut top + a bark ring
c:put(33, 15, WOOD[5]) c:put(34, 15, WOOD[4]) c:put(35, 15, WOOD[3])
c:put(33, 19, WOOD[2])
-- leaf out to the upper right (with nibble cut)
local nib = c:ellipse(46, 14.4, 2.0, 2.0):add(c:ellipse(43.6, 15.0, 1.6, 1.6))
A.leaf(c, 35, 17, 43, 7, 54, 11, 4.6, LEAF, { cut = nib, vs = 3.4 })
-- leaf base tucks behind stem: darken stem contact
c:put(35, 17, LEAF[1]) c:put(35, 18, LEAF[2])
A.save(c, "ico-peach")
