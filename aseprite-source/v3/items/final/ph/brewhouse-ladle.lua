-- brewhouse-ladle (final, Opus aB10_3). A deep copper brewer's ladle: round-bottomed bowl (per-pixel lit, bright
-- rolled rim, specular streak, a few hammer dents, cool bounce on the lower right), full of amber wort with a foam
-- ring and a sky reflection. A slim ash handle (grain streaks, pale end grain, a hanging hole) is clamped to the rim
-- by a riveted copper strap, with AO where wood meets metal.
-- quirk: a fresh hop cone is tied to the handle with a twist of twine, dangling for luck.
local NAME = "brewhouse-ladle"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local CU = { "#47202a", "#76302a", "#a6482e", "#cf6a38", "#ee9a5a", "#ffd29c" }
local WOOD = { "#3e2420", "#5c3828", "#845533", "#ab7a48", "#d1a46c", "#ecd09a" }
local WORT = { "#4e2412", "#7e4218", "#b06e26", "#d99a3a" }
local FOAM = { "#d8c49a", "#f4e6c0", "#fff4d6" }
local HOP = { "#28563c", "#3c7a44", "#5c9c4a", "#86bd5a", "#b8dc7c", "#e0f0a6" }
local TW = { "#8a6a42", "#c4a272", "#e6cf9c" }
local CX, CY, RX = 19, 39, 12

-- handle (drawn first; bowl and strap overlap its foot)
local hp = { { 29, 38 }, { 36, 30 }, { 44, 20 }, { 53, 9 } }
local hm, hn, HT, HS = A.tube(hp, function(t) return 1.55 end)
local hb = {}
local htok = { r = { name = "handle" } }
-- bowl masks
local rimO = HP.ellipse(CX, CY, RX, 4)
local body = HP.mask()
local bn = {}
for y = CY, CY + 13 do for x = CX - RX - 1, CX + RX + 1 do
  local u, v = (x - CX) / (RX + .5), (y - CY) / 12.5
  if u*u + v*v <= 1 then body:set(x, y) end
end end
body:add(rimO)
body:each(function(x, y)
  local u, v = (x - CX) / (RX + .5), max(0, (y - CY)) / 12.5
  local q = u*u + v*v
  bn[K(x, y)] = { A.norm(u, v * 1.1, sqrt(max(1 - q, 0.04))) }
end)
hm:cut(body)
X.ao(hb, hm, body, 2, -1)
local hidx = A.lit(c, hm, hn, WOOD, { tok = htok, bias = hb, amb = 0.1, wrap = 0.3, cuts = { 0.18, 0.36, 0.55, 0.74, 0.9 } })
-- grain: broken darker streaks along the handle
hm:each(function(x, y) local k = K(x, y)
  local t, s = HT[k], HS[k]
  local band = floor(s * 2.2 + 3)
  local ph = t * 9 + X.hash(band, 1, 7) * 3
  if abs(s) < 0.75 and (ph - floor(ph)) < 0.32 and hidx[k] > 2 and X.hash(band, floor(ph), 3) > 0.35 then
    c:put(x, y, WOOD[hidx[k] - 1], htok) end
end)
-- pale end grain + hanging hole
c:put(53, 8, WOOD[6], htok) c:put(54, 8, WOOD[5], htok) c:put(53, 9, WOOD[5], htok) c:put(54, 9, WOOD[4], htok)
c:put(51, 12, WOOD[1], htok) c:put(51, 11, WOOD[2], htok)

-- copper strap clamping the handle foot to the rim
local stp = { { 28, 39 }, { 30, 37 }, { 32, 34 }, { 34, 32 } }
local strm, strn = A.tube(stp, function(t) return 2.1 end)
strm:cut(body)
local ctok = { r = { name = "copper" } }
local stok = { r = { name = "strap" } }
A.lit(c, strm, strn, CU, { tok = stok, amb = 0.12, wrap = 0.3, cuts = { 0.18, 0.36, 0.55, 0.74, 0.9 } })
-- strap end edge (ambient row onto the wood) and two rivets
for _, q in ipairs{ { 35, 32 }, { 34, 31 }, { 36, 31 } } do if hm:has(q[1], q[2]) then c:put(q[1], q[2], WOOD[1], htok) end end
for _, q in ipairs{ { 30, 36 }, { 32, 34 } } do c:put(q[1], q[2], CU[6], stok) c:put(q[1] + 1, q[2] + 1, CU[2], stok) end

-- bowl body: metal, per-pixel lit, strong specular streak, hammer dents
local bb = {}
body:each(function(x, y) local k = K(x, y)
  if y > CY + 1 and X.hash(floor(x / 3), floor(y / 3), 19) > 0.78 and (x + y) % 3 == 0 then bb[k] = -1 end end)
local bidx = A.lit(c, body, bn, CU, { tok = ctok, bias = bb, amb = 0.06, wrap = 0.2, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 } })
local sp = X.spec(bn, 18)
body:each(function(x, y) local k = K(x, y) if y > CY + 1 and sp[k] > 0.72 then c:put(x, y, sp[k] > 0.9 and A.CREAM or CU[6], ctok) end end)
-- cool bounce light on the lower-right rim of the bowl
local rr = X.rim(bn)
body:edge():each(function(x, y) local k = K(x, y) if y > CY + 2 and rr[k] > 0.5 then c:put(x, y, "#b06a78", ctok) end end)

-- rim ring and interior
local inner = HP.ellipse(CX, CY - 0.2, RX - 1.6, 2.6)
local ring = rimO:copy():cut(inner)
ring:each(function(x, y)
  local a = atan(y - CY, x - CX)
  local i
  if y >= CY then i = (x < CX + 4) and 6 or 5 else i = (x < CX - 4) and 4 or 3 end
  if x > CX + RX - 3 and y >= CY then i = 4 end
  c:put(x, y, CU[i], ctok)
end)
-- interior: far wall (copper, lit on the right since it faces left), then wort surface with foam ring
inner:each(function(x, y)
  if y <= CY - 2 then c:put(x, y, x > CX + 2 and CU[4] or CU[2], ctok)
  else
    local i = (x < CX - 3) and 2 or 3
    if y >= CY + 1 then i = i - 1 end
    c:put(x, y, WORT[max(1, i)], ctok)
  end
end)
-- ambient row where the wort meets the wall
inner:each(function(x, y) if y == CY - 1 then c:put(x, y, x > CX + 2 and WORT[1] or "#3a1a14", ctok) end end)
-- foam: bubbles along the front-left of the surface
for _, q in ipairs{ { CX - 9, CY, 2 }, { CX - 8, CY, 3 }, { CX - 7, CY + 1, 2 }, { CX - 6, CY + 1, 3 }, { CX - 5, CY + 1, 1 },
  { CX - 8, CY - 1, 1 }, { CX + 6, CY + 1, 2 }, { CX + 7, CY + 1, 1 }, { CX + 8, CY, 2 } } do c:put(q[1], q[2], FOAM[q[3]], ctok) end
-- sky glint on the wort
c:put(CX + 1, CY, WORT[4], ctok) c:put(CX + 2, CY, WORT[4], ctok) c:put(CX + 3, CY + 1, WORT[3], ctok)

-- quirk: hop cone tied on with a twist of twine
local twtok = { r = { name = "twine" } }
-- wrap around the handle (alternating twist)
for i, q in ipairs{ { 43, 20 }, { 44, 21 }, { 42, 21 }, { 43, 22 }, { 44, 19 }, { 45, 20 } } do
  if hm:has(q[1], q[2]) then c:put(q[1], q[2], TW[(i % 2 == 0) and 3 or 1], twtok) end end
-- hanging strand
for i, q in ipairs{ { 44, 23 }, { 44, 24 }, { 45, 25 }, { 45, 26 } } do c:put(q[1], q[2], TW[(i % 2 == 0) and 2 or 1], twtok) end
local cm, cn = A.oval(46, 31, 3.3, 4.6, 0.12, 1.0)
local htk = { r = { name = "hop" } }
local hi = A.lit(c, cm, cn, HOP, { tok = htk, amb = 0.1, wrap = 0.25, cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
-- overlapping bracts: scallop rows, dark lower edge of each scale
cm:each(function(x, y) local k = K(x, y)
  local row = floor((y - 26) / 2.2)
  local off = (row % 2) * 1.6
  local f = ((x - 43 + off) / 3.2) % 1
  local yy = (y - 26) / 2.2 - row
  if yy > 0.62 - abs(f - 0.5) * 0.6 then c:put(x, y, HOP[max(1, (hi[k] or 3) - 1)], htk) end
  if yy < 0.2 and abs(f - 0.5) < 0.2 and (hi[k] or 0) >= 4 then c:put(x, y, HOP[6], htk) end
end)
-- strig tip
c:put(46, 26, HOP[2], htk) c:put(46, 25, TW[1], twtok)
c:put(47, 36, HOP[2], htk)

A.save(c, NAME)
