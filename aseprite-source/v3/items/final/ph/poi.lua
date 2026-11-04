-- poi (final pass, Opus). A koa-wood umeke (round calabash bowl: curved grain following the belly, pale bevelled rim,
-- short foot ring) heaped with smooth lavender taro poi (glossy swirl peak, finger-scoop hollow), a young taro leaf
-- (kalo, heart-shaped with a notch, midrib and radiating veins) tucked behind, and a slim basalt poi pounder
-- (pohaku ku'i ai: knob top, narrow neck, flared base, vesicle pits) standing on the right. Ground shadow.
-- History: Sonnet draft (dC35) replaced.
-- quirk: a single fermentation bubble has risen on the sour poi, with its own tiny glint.
local NAME = "poi"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC35_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local KOA   = { "#3a1a1c", "#5e2e24", "#844630", "#a86440", "#c88858", "#e6b27a" }
local POI   = { "#3e2c5e", "#5c4486", "#7c62aa", "#9c84c8", "#bca6e0", "#dccaf2" }
local BAS   = { "#24232f", "#383a50", "#50526a", "#6a6c84", "#8e8fa4", "#bcbccb" }
local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local VEIN  = "#c2e48c"

c:groundShadow(29, 54, 18, 2)

-- taro leaf behind (heart-shaped, pointing up-left, notch at the stalk)
local lm, ln, LT, LS, len = A.blade(26, 34, 18, 26, 9, 11, function(t)
  if t > 0.97 then return -1 end
  return max(0.4, 7.2 * sin(pi * min(1, (t * 0.92 + 0.08))) ^ 0.6)
end, { fold = 0.35 })
-- heart notch at the base
lm:each(function(x, y) local k = K(x, y) if LT[k] < 0.14 and abs(LS[k]) < 0.25 then lm.s[k] = nil end end)
local stalk = c:line({ { 26, 33 }, { 28, 38 } }, 2)

-- pounder (right): knob, neck, flared base
local px = 50
local function pr(y)
  if y <= 22 then return 2.6 end
  if y <= 25 then return 2.6 - (y - 22) * 0.35 end
  if y <= 40 then return 1.5 + (y - 25) * 0.03 end
  return 1.95 + ((y - 40) / 13) ^ 1.5 * 4.6
end
local pm = HP.mask()
for y = 18, 53 do local r = pr(y)
  if y < 20 then r = r - (20 - y) * 0.8 end
  for x = floor(px - r), floor(px + r - 0.01) do if x + 0.5 >= px - r and x + 0.5 <= px + r then pm:set(x, y) end end end

-- bowl
local bcx, rimY = 27, 36
local outer = HP.mask()
outer:add(c:ellipse(bcx, rimY, 16, 14))
outer:each(function(x, y) if y < rimY then outer.s[K(x, y)] = nil end end)
outer:each(function(x, y) if y > 50 then outer.s[K(x, y)] = nil end end)
local foot = c:rect(bcx - 7, 50, bcx + 6, 52)
local rim = c:ellipse(bcx, rimY, 16, 3)
local bowl = outer:copy():add(foot):add(rim)
-- poi mound over the opening
local mound = c:ellipse(bcx - 0.5, rimY - 1, 13.5, 6.5)
mound:each(function(x, y) if y > rimY then mound.s[K(x, y)] = nil end end)
mound:add(c:ellipse(bcx - 0.5, rimY, 13.5, 2))
-- swirl peak
mound:add(c:ellipse(bcx - 2, rimY - 7, 4, 2.5))

-- paint: leaf first (behind), AO where the bowl and poi cover it
local front = bowl:copy():add(mound)
local lbias = {}
X.ao(lbias, lm, front, 1, -1) A.cast(lbias, lm, front, 1, 2, -1)
local ltok = { r = { name = "leaf" } }
lm:cut(front)
A.toneN(c, lm, ln, LEAF, { bias = lbias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if lbias[k] then return end
  if abs(s) < 0.1 and t > 0.12 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- radiating veins from the leaf base
  local ang = math.atan(s * 3.2, t + 0.05)
  local f = abs(((ang * 2.3) - floor(ang * 2.3)) - 0.5) * 2
  if f > 0.88 and abs(s) > 0.18 and t > 0.12 and t < 0.85 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
for _, p in ipairs{ { 26, 33 }, { 27, 34 }, { 27, 35 } } do if not front:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[2], ltok) end end

-- pounder: lathe-lit basalt with vesicle pits, AO behind the bowl
local ptok = { r = { name = "pounder" } }
local pbias = {}
X.ao(pbias, pm, bowl, 1, -1)
local pn = A.lathe(pm, px, pr, 1.5, 0.4)
local pidx = A.shade(c, pm, pn, BAS, { tok = ptok, amb = 0.07, wrap = 0.25, bias = pbias })
pm:each(function(x, y) local h = X.hash(x, y, 21)
  if h > 0.86 and y > 41 then A.step(c, pidx, BAS, x, y, -1, ptok) end
  if h > 0.9 and y < 23 then A.step(c, pidx, BAS, x, y, -1, ptok) end end)
-- knob specular + neck bright edge
c:put(48, 19, BAS[6], ptok) c:put(49, 19, BAS[6], ptok)
for y = 27, 37 do if pm:has(49, y) then c:put(49, y, BAS[5], ptok) end end
-- wear ring where the hand grips
for x = 47, 52 do if pm:has(x, 31) then A.step(c, pidx, BAS, x, 31, -1, ptok) end end

-- bowl: sphere-ish belly, curved grain
local btok = { r = { name = "bowl" } }
local bn = A.dome(bowl, bcx, rimY - 2, 16, 3, 0.65)
local bbias = {}
local bidx = A.shade(c, bowl, bn, KOA, { tok = btok, amb = 0.06, wrap = 0.22, bias = bbias })
outer:each(function(x, y)
  if y <= rimY + 2 then return end
  local dx, dy = (x + 0.5 - bcx) / 16, (y - rimY) / 14
  local r = sqrt(dx * dx * 0.25 + dy * dy)
  local g = r * 9 + 0.6 * sin(dx * 5)
  if abs(g - floor(g + 0.5)) < 0.09 and y < 50 then A.step(c, bidx, KOA, x, y, -1, btok) end
end)
-- foot ring: dark seam under the belly
for x = bcx - 7, bcx + 6 do c:put(x, 50, KOA[1], btok) end
-- rim bevel: pale lip on the front, darker inner lip at the back
rim:each(function(x, y)
  local dx, dy = (x + 0.5 - bcx) / 16, (y - rimY) / 3
  local q = dx * dx + dy * dy
  if q > 0.45 then c:put(x, y, (dx < 0.35) and KOA[6] or KOA[4], btok) end
end)
-- belly specular
for _, p in ipairs{ { 17, 40 }, { 18, 40 }, { 16, 41 } } do c:put(p[1], p[2], "#f6d2a0", btok) end

-- poi: smooth glossy paste, swirl at the peak, finger-scoop hollow
local otok = { r = { name = "poi" } }
local mn = A.dome(mound, bcx - 2, rimY - 5, 13, 3, 0.5)
local obias = {}
-- contact: poi darker right on the rim line
mound:each(function(x, y) if y >= rimY + 1 then obias[K(x, y)] = -1 end end)
local oidx = A.shade(c, mound, mn, POI, { tok = otok, amb = 0.08, wrap = 0.28, bias = obias })
-- swirl: a curved lit ridge + shadow groove circling the peak
for i = 0, 22 do local a = i / 22 * pi * 1.6 + 0.4
  local r = 4.6 - i * 0.12
  local x, y = floor(bcx - 2 + cos(a) * r + 0.5), floor(rimY - 6 + sin(a) * r * 0.5 + 0.5)
  if mound:has(x, y) then A.step(c, oidx, POI, x, y, -1, otok) end
  if mound:has(x, y - 1) then A.step(c, oidx, POI, x, y - 1, 1, otok) end
end
-- finger-scoop hollow on the right of the mound
for _, p in ipairs{ { 32, 33, -2 }, { 33, 33, -2 }, { 34, 33, -1 }, { 32, 32, 1 }, { 33, 32, 1 }, { 31, 33, -1 }, { 33, 34, -1 } } do
  if mound:has(p[1], p[2]) then A.step(c, oidx, POI, p[1], p[2], p[3], otok) end end
-- glossy specular on the peak
c:put(21, 27, POI[6], otok) c:put(22, 27, POI[6], otok) c:put(20, 28, "#f2e8ff", otok)
-- a soft lip of poi lapping over the front rim
for _, p in ipairs{ { 22, 37, 3 }, { 23, 37, 2 }, { 30, 37, 3 } } do c:put(p[1], p[2], POI[p[3]], otok) end

-- quirk: one fermentation bubble with a glint
local qtok = { r = { name = "bubble" } }
c:put(15, 32, POI[5], qtok) c:put(16, 32, POI[4], qtok) c:put(15, 33, POI[4], qtok) c:put(16, 33, POI[2], qtok)
c:put(15, 31, POI[3], qtok) c:put(16, 31, POI[3], qtok)
c:put(15, 32, "#fff4d6", qtok)

A.save(c, "ph", NAME)
