-- copper-watering-can (final pass, Opus single pass). A slim, slightly tapered copper can: per-pixel cylinder light
-- on a 6-tone copper ramp (warm salmon highs, cool plum shade, bright specular streak, faint reflected light on the
-- right edge), rolled rim bevel and a dark oval mouth at the top, a soldered seam band with brass rivets near the foot,
-- a thin arched carry handle and a long slender spout with a brass rose (dark perforated face). 2-tone ground shadow.
-- quirk: a little green verdigris run trickles down from one rivet.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "copper-watering-can"
local c = A.new(NAME)
local CU = { "#4a1f2a", "#7a3328", "#b0552e", "#d9783c", "#f2a05e", "#ffd09a" }
local SPEC, BOUNCE = "#fff0d6", "#9a5a7a"
local BR = { "#4e3418", "#80582a", "#b88a36", "#e2bc58", "#fff0a8" }
local VG = { "#2e6a5a", "#4fa08a", "#8ad2b4" }
local btok = { r = { name = "body" } }
local htok = { r = { name = "handle" } }
local stok = { r = { name = "spout" } }
local rtok = { r = { name = "rose" } }

c:groundShadow(31, 53, 15, 1.5)

-- handle: thin arch over the top, painted first (body and rim cover its feet)
local hm, hn = A.tube({ { 19, 25 }, { 19, 8 }, { 39, 8 }, { 39, 25 } }, function(t) return 1.25 end)
A.shade(c, hm, hn, CU, { tok = htok, amb = 0.12, wrap = 0.3 })

-- spout: long, thin, tapered, from the lower right of the body up to the rose
local sp = { { 36, 47 }, { 44, 40 }, { 50, 30 }, { 54, 22 } }
local sm, sn, ST, SS, ssamp = A.tube(sp, function(t) return 2.1 - 0.9 * t end)
local sidx = A.shade(c, sm, sn, CU, { tok = stok, amb = 0.1, wrap = 0.28 })
-- spout highlight line
for i = 8, 30 do local s = ssamp[i * 5] local x, y = floor(s.x + s.px * s.w * -0.45 + .5), floor(s.y + s.py * s.w * -0.45 + .5)
  if sm:has(x, y) then c:put(x, y, CU[6], stok) end end

-- body: tapered cylinder, top x 21..37, bottom x 19..39
local TOP, BOT = 24, 51
local bm = HP.mask()
for y = TOP, BOT do local f = (y - TOP) / (BOT - TOP)
  local hw = 8.2 + 1.6 * f
  for x = floor(29 - hw + .5), floor(29 + hw + .5) do bm:set(x, y) end end
-- soften the base corners
bm.s[K(19, BOT)] = nil bm.s[K(39, BOT)] = nil
local _, bn, BT, BS = X.cyl(29, TOP - 2, 29, BOT + 2, function(t) return 8.4 + 1.6 * t end, bm)
local bias = {}
-- ambient: darker just under the rim and at the foot; contact under the spout root
bm:each(function(x, y) local k = K(x, y)
  if y == TOP + 2 or y == BOT then bias[k] = -1 end end)
local bidx = A.shade(c, bm, bn, CU, { tok = btok, bias = bias, amb = 0.06, wrap = 0.22, cuts = { 0.18, 0.34, 0.5, 0.68, 0.86 } })
-- specular streak (vertical, upper-left third) + glint
for y = TOP + 4, BOT - 6 do local x = 24 + floor((y - TOP) / 14)
  c:put(x, y, (y < TOP + 9) and SPEC or CU[6], btok) end
c:put(25, TOP + 5, SPEC, btok)
-- cool reflected light on the right edge
for y = TOP + 6, BOT - 2 do local f = (y - TOP) / (BOT - TOP) local x = floor(29 + 8.2 + 1.6 * f + .5)
  if bm:has(x, y) then c:put(x, y, BOUNCE, btok) end end
-- seam band near the foot: raised strap (lit top lip, dark underside)
local SB = 45
bm:each(function(x, y) local k = K(x, y) local i = bidx[k] or 3
  if y == SB then c:put(x, y, CU[min(6, i + 1)], btok)
  elseif y == SB + 1 then c:put(x, y, CU[max(1, i)], btok)
  elseif y == SB + 2 then c:put(x, y, CU[max(1, i - 2)], btok) end end)
-- vertical solder seam on the left third
for y = TOP + 3, SB - 1 do if y % 2 == 0 then c:put(22, y, CU[max(1, (bidx[K(22, y)] or 4) - 1)], btok) end end
-- brass rivets on the band
local rv = { 22, 27, 32, 37 }
for _, x in ipairs(rv) do
  c:put(x, SB + 1, BR[4], btok) c:put(x + 1, SB + 1, BR[2], btok)
end
c:put(27, SB + 1, BR[5], btok)

-- rolled rim at the top: bevel (bright top row, dark under-roll), dark oval mouth behind the handle feet
for x = 20, 38 do
  local lit = x < 31
  c:put(x, TOP - 1, (x == 20 or x == 38) and CU[3] or (lit and CU[6] or CU[4]), btok)
  c:put(x, TOP, lit and CU[4] or CU[3], btok)
  c:put(x, TOP + 1, CU[2], btok)
end
-- mouth: dark inner wall seen just above the rim
for x = 22, 36 do c:put(x, TOP - 2, (x < 26) and CU[2] or CU[1], btok) end
c:put(21, TOP - 2, CU[4], btok) c:put(37, TOP - 2, CU[3], btok)
for x = 24, 34 do c:put(x, TOP - 3, CU[3], btok) end
c:put(23, TOP - 3, CU[5], btok) c:put(35, TOP - 3, CU[3], btok)
-- handle feet: little lugs riveted to the rim
for _, x in ipairs{ 19, 39 } do
  c:put(x, TOP - 2, CU[4], htok) c:put(x, TOP - 1, CU[3], htok) end

-- spout root collar where it meets the body
for _, q in ipairs{ { 37, 46, 2 }, { 38, 45, 3 }, { 38, 47, 1 }, { 39, 46, 2 } } do c:put(q[1], q[2], CU[q[3]], stok) end

-- rose: brass cone flaring to a round face, face tilted up-right, perforations
local rm, rn = A.oval(55.5, 20.5, 3.4, 2.4, -0.95, 0.9)
A.shade(c, rm, rn, BR, { tok = rtok, amb = 0.1, wrap = 0.3, cuts = { 0.25, 0.45, 0.65, 0.85 } })
local face = A.oval(56.5, 19.5, 2.2, 1.4, -0.95, 1)
face:each(function(x, y) c:put(x, y, BR[2], rtok) end)
c:put(56, 19, BR[1], rtok) c:put(57, 20, BR[1], rtok) c:put(57, 18, BR[1], rtok)
c:put(55, 21, BR[5], rtok)

-- quirk: verdigris run from the second rivet down the foot
c:put(32, SB + 2, VG[2], btok) c:put(32, SB + 3, VG[3], btok) c:put(32, SB + 4, VG[2], btok)
c:put(33, SB + 4, VG[1], btok) c:put(32, SB + 5, VG[1], btok) c:put(33, SB + 2, VG[1], btok)

A.save(c, NAME)
