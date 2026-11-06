-- chickpea-stew (final, Opus single pass). A shallow glazed clay bowl in 3/4 view brimming with a red-orange stew,
-- plump chickpeas bobbing in it, torn parsley and an oil sheen, a slim wooden spoon standing in it. Material: bowl body
-- per-pixel round light on a 6-tone terracotta ramp with a teal glaze band and its bright glaze streak, an unglazed foot
-- ring with AO; stew domed and glossy with 6 tones and oil glints; chickpeas as tiny lit spheres with a seam dimple and
-- contact shadows; spoon with wood grain and a paler end; AO where spoon and rim meet the stew.
-- quirk: one chickpea has escaped and sits on the rim.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new("chickpea-stew")
local CLAY = { "#4a2232", "#7a3434", "#a8503a", "#cc7046", "#e6965c", "#f8c080" }
local GLZ  = { "#173c4a", "#21606a", "#2e8a86", "#4cb09c", "#80d2b4", "#c4f0d8" }
local STEW = { "#5a1a22", "#8c2a24", "#bc4424", "#de6a2c", "#f4923e", "#ffc070" }
local PEA  = { "#7a5040", "#a8784e", "#d0a464", "#ecc884", "#fff0b8" }
local WOOD = { "#4a2a2a", "#7a4a36", "#a8724a", "#d0a064", "#f0cc8a" }
local HERB = { "#1f4a34", "#2e7646", "#5aa64e", "#9dd06c" }
local btok, gtok, stok, ptok, wtok, htok = { r = { name = "bowl" } }, { r = { name = "glaze" } }, { r = { name = "stew" } },
  { r = { name = "pea" } }, { r = { name = "spoon" } }, { r = { name = "herb" } }

c:groundShadow(32, 50, 15, 2)
local CX, RY = 32, 30
-- foot ring
local foot = HP.rrect(23, 45, 41, 49, 1)
A.shade(c, foot, A.vcyl(foot, 32, 9.5, 0), CLAY, { amb = 0.04, bias = nil, tok = btok })
for x = 24, 40 do c:put(x, 45, CLAY[1], btok) end
-- body: lower half of an ellipsoid
local body = HP.ellipse(CX, RY, 21, 16):cut(HP.rect(0, 0, 63, RY - 1)):cut(HP.rect(0, 46, 63, 63))
local bn = A.body(body, CX - 2, RY - 4, 21, 5, 0.65)
local bb = {}
body:each(function(x, y) if y >= 44 then bb[K(x, y)] = -1 end end)
local bidx = A.shade(c, body, bn, CLAY, { amb = 0.06, wrap = 0.22, bias = bb, tok = btok })
-- glaze band (top of body), dipped edge wavy
body:each(function(x, y) local k = K(x, y)
  local edge = RY + 6 + floor(1.2 * math.sin(x * 0.7) + 0.5)
  if y <= edge then c:put(x, y, GLZ[max(1, min(6, (bidx[k] or 3)))], gtok)
  elseif y == edge + 1 then c:put(x, y, CLAY[max(1, (bidx[k] or 3) - 1)], btok) end end)
-- glaze specular streak on lit shoulder
for _, q in ipairs{ { 16, 33 }, { 17, 34 }, { 18, 34 }, { 19, 35 } } do c:put(q[1], q[2], GLZ[6], gtok) end
c:put(15, 32, "#fff4d6", gtok)
-- reflected cool light low right
body:edge():each(function(x, y) if x > 40 and y > 36 and y < 44 then c:put(x, y, "#8a5a7a", btok) end end)

-- rim (top ellipse ring)
local outer = HP.ellipse(CX, RY, 21, 5.5)
local inner = HP.ellipse(CX, RY + 0.5, 18.5, 4)
local rim = outer:copy():cut(inner)
rim:each(function(x, y)
  local col
  if y < RY then col = (x < CX) and GLZ[5] or GLZ[4] else col = (x < CX - 6) and GLZ[4] or GLZ[3] end
  if y <= RY - 5 and x > CX - 8 and x < CX + 2 then col = GLZ[6] end
  c:put(x, y, col, gtok) end)
-- stew surface: domed, with inner-rim AO
local stew = inner:copy()
local sn = A.disc(stew, CX - 3, RY, 18, 4, 0.55)
local sb = {}
stew:each(function(x, y) if not HP.ellipse(CX, RY + 0.7, 17, 3):has(x, y) then
  if y < RY + 1 then sb[K(x, y)] = -2 else sb[K(x, y)] = -1 end end end)
local sidx = A.shade(c, stew, sn, STEW, { amb = 0.1, wrap = 0.3, cuts = { 0.3, 0.5, 0.65, 0.78, 0.9 }, bias = sb, tok = stok })

-- spoon handle (behind peas, in front of rim) rising up-right out of the stew
local spm, spn, SPT, SPS = A.tube({ { 39, 30 }, { 43, 22 }, { 47, 14 }, { 51, 8 } }, function(t) return 1.3 + (t > 0.8 and (t - 0.8) * 3 or 0) end)
local spv = X.light(spn, { amb = 0.14, wrap = 0.3 })
local spb = {}
spm:each(function(x, y) if y >= RY - 2 then spb[K(x, y)] = -2 end end)
local spidx = X.tone(c, spm, spv, WOOD, { cuts = { 0.25, 0.45, 0.65, 0.83 }, bias = spb, tok = wtok })
spm:each(function(x, y) local k = K(x, y)
  if SPS[k] > 0.15 and SPS[k] < 0.6 and (SPT[k] * 40) % 5 < 2.2 and SPT[k] < 0.9 then c:put(x, y, WOOD[max(1, spidx[k] - 1)], wtok) end
  if SPT[k] > 0.97 then c:put(x, y, WOOD[5], wtok) end end)
-- ripple ring where spoon enters
for _, q in ipairs{ { 37, 30 }, { 41, 30 }, { 38, 31 }, { 40, 31 } } do c:put(q[1], q[2], STEW[6], stok) end
c:put(39, 31, STEW[1], stok) c:put(40, 30, STEW[2], stok)

-- chickpeas
local function pea(x0, y0, r, own)
  local m = HP.ellipse(x0, y0, r, r * 0.9)
  local n = X.sphere(x0 - 0.3, y0 - 0.3, r + 0.2, m)
  -- contact shadow on the stew beneath
  local sh = m:shift(1, 1)
  sh:each(function(x, y) if stew:has(x, y) and not m:has(x, y) then c:put(x, y, STEW[2], stok) end end)
  local idx = A.shade(c, m, n, PEA, { amb = 0.12, wrap = 0.3, cuts = { 0.3, 0.5, 0.7, 0.88 }, tok = own or ptok })
  -- seam dimple (the chickpea's beak)
  c:put(floor(x0 + 0.5), floor(y0 - r + 1.2), PEA[2], own or ptok)
  return m
end
local peas = { { 19, 30 }, { 24, 28.5 }, { 29, 31 }, { 33, 28 }, { 25, 33 }, { 36, 32 }, { 44, 31 }, { 30, 26.5 }, { 46, 28 } }
for _, q in ipairs(peas) do pea(q[1], q[2], 1.6) end
-- parsley bits
local herbs = { { 21, 27 }, { 38, 27 }, { 33, 33 }, { 42, 33 } }
for i, h in ipairs(herbs) do
  c:put(h[1], h[2], HERB[3], htok) c:put(h[1] + 1, h[2], HERB[4], htok) c:put(h[1], h[2] + 1, HERB[2], htok)
  if i % 2 == 0 then c:put(h[1] + 1, h[2] - 1, HERB[3], htok) end
end
-- oil glints
for _, q in ipairs{ { 27, 27 }, { 22, 31 }, { 40, 28 } } do c:put(q[1], q[2], STEW[6], stok) end
c:put(22, 26, "#fff1cf", stok)

-- quirk: escaped chickpea on the rim (right)
pea(50.5, 28.5, 1.6, { r = { name = "pea2" } })

A.save(c, "chickpea-stew")
