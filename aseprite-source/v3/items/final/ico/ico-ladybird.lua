-- ico-ladybird (final pass, Opus). Top-down seven-spot ladybird, head up: a glossy domed red shell split by a
-- seam that parts at the tail, dark pronotum with two cream shoulder patches, small dark head with cream eye
-- patches (2x3 ink pills) and a pink smile, clubbed antennae, six short legs peeking from under the shell.
-- Material: per-pixel sphere light (6-tone red, violet-red shade), glossy specular + hi streak on each wing case,
-- cool reflected light lower right, AO under the pronotum and along the seam, spots shaded with the dome.
-- quirk: one spot on the left wing case is a little heart.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new("ico-ladybird")
local RED  = { "#5c1532", "#93213a", "#c4303b", "#e8493b", "#ff7652", "#ffaa80" }
local DARK = { "#1c121e", "#2b1d2e", "#3d2c44", "#54425e", "#6f5c7c" }
local SPOT = { "#2a1424", "#3a1a2c", "#4e2436" }
local CR, INK, BOUNCE = "#fff1cf", "#2b1c26", "#b4507a"
local LEG = "#2e2030"

-- legs (under everything): 3 per side, short bent stubs
local function leg(pts) local m = c:line(pts, 3) c:fillMask(m, LEG) return m end
leg{ { 20, 28 }, { 15, 25 }, { 14, 22 } }
leg{ { 44, 28 }, { 49, 25 }, { 50, 22 } }
leg{ { 18, 38 }, { 13, 39 } }
leg{ { 46, 38 }, { 51, 39 } }
leg{ { 21, 47 }, { 16, 51 }, { 16, 54 } }
leg{ { 43, 47 }, { 48, 51 }, { 48, 54 } }
-- lit edge on legs
for _, p in ipairs{ { 14, 22 }, { 15, 24 }, { 49, 22 }, { 13, 38 }, { 50, 38 }, { 16, 53 }, { 47, 53 } } do c:put(p[1], p[2], DARK[4]) end

-- antennae: 2 px stalks, 3 px club tips
c:fillMask(c:line({ { 29, 12 }, { 26, 8 } }, 2), DARK[3])
c:fillMask(c:line({ { 35, 12 }, { 38, 8 } }, 2), DARK[3])
c:fillMask(c:rect(24, 6, 26, 8), DARK[2]) c:put(24, 6, DARK[5])
c:fillMask(c:rect(38, 6, 40, 8), DARK[2]) c:put(38, 6, DARK[5])

-- head
local hm = A.ell(32, 15, 7, 4.5)
local hn = X.sphere(31, 13.5, 7, hm)
A.shade(c, hm, hn, DARK, { amb = 0.05, wrap = 0.2 })
-- cream eye patches + ink pills
for _, ex in ipairs{ 28, 35 } do
  c:fillMask(c:rect(ex - 1, 12, ex + 2, 16), CR)
  c:put(ex - 1, 12, DARK[3]) c:put(ex + 2, 16, "#d9c8a8") c:put(ex - 1, 16, "#d9c8a8")
  c:fillMask(c:rect(ex, 13, ex + 1, 15), INK)
  c:put(ex, 13, CR)
end
-- smile
c:put(30, 18, "#f5809f") c:put(31, 19, "#f5809f") c:put(32, 19, "#f5809f") c:put(33, 18, "#f5809f")

-- shell
local CX, CY, RX, RY = 32, 37, 15, 16
local bm = A.ell(CX, CY, RX, RY)
bm:cut(A.ell(32, 55, 1, 2))                      -- wing cases part at the tail
local bn = X.sphere(CX - 1.5, CY - 2.5, RY + 0.5, bm)
local bias = {}
-- AO under the pronotum
local pm = A.ell(32, 22.5, 10, 4.5)
X.ao(bias, bm, pm, 2, -1)
-- seam AO
bm:each(function(x, y) if abs(x - 31.5) < 1.6 and y > 26 then local k = K(x, y) bias[k] = (bias[k] or 0) - 1 end end)
local stok = { r = { name = "shell" } }
local idx = A.shade(c, bm, bn, RED, { amb = 0.05, wrap = 0.4, bias = bias, tok = stok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.8 } })
-- seam line
for y = 25, 56 do if bm:has(32, y) then c:put(32, y, RED[1], stok) end
  if y < 52 and bm:has(31, y) then A.step(c, idx, RED, 31, y, 0, stok) end end
-- spots: shaded with the dome
local function spotPx(x, y)
  if not bm:has(x, y) then return end
  local i = idx[K(x, y)] or 3
  c:put(x, y, SPOT[i >= 5 and 3 or (i >= 3 and 2 or 1)], stok)
end
local function spot(cx, cy, r) A.ell(cx, cy, r, r * 0.92):each(spotPx) end
spot(39, 31, 2.6)
spot(43, 41, 2.8)
spot(37, 49, 2.4)
spot(24, 40, 2.8)
spot(26, 49, 2.4)
-- front spot shared across the seam, half tucked under the pronotum
A.ell(32, 27, 3, 2):each(spotPx)
c:put(32, 27, SPOT[1]) c:put(32, 28, SPOT[1])
-- quirk: heart spot, lower left
local heart = { "XX.XX", "XXXXX", "XXXXX", ".XXX.", "..X.." }
for yy, row in ipairs(heart) do for xx = 1, 5 do
  if row:sub(xx, xx) == "X" then spotPx(22 + xx, 28 + yy) end end end
c:put(23, 29, SPOT[3]) -- tiny lit lobe on the heart

-- gloss: hi streak along the upper-left of each wing case, one specular, cool bounce lower right
for _, p in ipairs{ { 21, 30 }, { 21, 31 }, { 21, 32 }, { 22, 29 }, { 23, 28 }, { 36, 28 }, { 37, 28 } } do
  if bm:has(p[1], p[2]) then c:put(p[1], p[2], RED[6], stok) end end
c:put(26, 34, CR) c:put(27, 34, CR) c:put(26, 35, RED[6]) c:put(28, 34, RED[6])
local rim = X.rim(bn)
bm:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.55 and y > 36 and x > 35 then c:put(x, y, BOUNCE, stok) end end)

-- pronotum (over the shell top) with cream shoulder patches
local pn = X.sphere(31, 21, 10, pm)
local pidx = A.shade(c, pm, pn, DARK, { amb = 0.04, wrap = 0.2, cuts = { 0.25, 0.45, 0.65, 0.82 } })
for _, q in ipairs{ { 24, 21 }, { 37, 21 } } do
  c:fillMask(A.ell(q[1] + 1.5, q[2] + 1.5, 1.8, 1.4), CR)
  c:put(q[1] + 3, q[2] + 2, "#d9c8a8")
end
c:put(29, 19, DARK[5]) c:put(30, 19, DARK[5])

A.save(c, "ico-ladybird")
