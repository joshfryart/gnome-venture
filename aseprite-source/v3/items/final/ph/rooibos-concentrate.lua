-- rooibos-concentrate (Sonnet high, single pass). A round-bellied glass flask on a long neck, three quarters full of
-- deep red-amber rooibos syrup that glows amber along its lower-right (light through the glass). Glass: bright cool rim
-- on the lit side, teal shade rim, pale empty neck, a long specular streak and a small reflected dot. A curved cream
-- label with a russet needle-sprig stamp wraps the belly; a cork is sealed with an ember wax collar.
-- quirk: a fat bead of red wax has dripped from the collar down the neck.
local NAME = "rooibos-concentrate"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }

local LIQ  = { "#2e0f1e", "#5b1624", "#8c2420", "#bd3f1c", "#e56b20", "#ffa845" }
local GLS  = { "#2f5e79", "#4f8fa6", "#86c3c8", "#bfe8e4", "#e6faf4", "#f4fff6" }
local CREAM = { "#7e625f", "#b39a86", "#dcc6a2", "#f4e4c0", "#fff3d4" }
local CORK = { "#4e2d22", "#7b5036", "#a97a4c", "#cfa56a", "#ecca90" }
local WAX  = { "#4a1630", "#7d2236", "#b53a3c", "#e0594a", "#ff8a6a", "#ffc4a6" }
local gtok, ltok, lbtok, ktok, wtok = {r={name="glass"}}, {r={name="liquid"}}, {r={name="label"}}, {r={name="cork"}}, {r={name="wax"}}
c:groundShadow(32, 54, 11, 2)

local CX, CY, RX, RY = 32, 41, 12, 11
local bulb = c:ellipse(CX, CY, RX, RY)
local neck = c:rect(28, 14, 35, 34)
local fillet = c:poly{ { 28, 29 }, { 35, 29 }, { 39, 35 }, { 25, 35 } }
local glass = bulb:copy():add(neck):add(fillet)
local liq = glass:copy():shrink(2):clip(c:rect(0, 24, 63, 63))

-- glass shell: base tint everywhere, then rims by facing
glass:each(function(x, y) c:put(x, y, GLS[4], gtok) end)
local inner1 = glass:copy():shrink(1)
glass:each(function(x, y)
  if not inner1:has(x, y) then
    local lit = (x - CX) + (y - CY) * 0.8 < 0
    c:put(x, y, lit and GLS[5] or GLS[1], gtok)
  end
end)
glass:copy():shrink(1):each(function(x, y)
  if not glass:copy():shrink(2):has(x, y) then c:put(x, y, ((x - CX) + (y - CY) * 0.8 < 0) and GLS[4] or GLS[2], gtok) end
end)
-- pale empty neck: faint inner shade to the right
for y = 15, 23 do c:put(33, y, GLS[3], gtok) c:put(34, y, GLS[2], gtok) end

-- liquid: pillow-lit, deep red core, amber glow lower-right
local ln = X.pillow(liq, 7)
local v = X.light(ln, { amb = 0.05, wrap = 0.35 })
local rim = X.rim(ln)
local bias = {}
liq:each(function(x, y) local k = K(x, y)
  if rim[k] and rim[k] > 0.5 then bias[k] = 1 end
  if rim[k] and rim[k] > 0.78 then bias[k] = 2 end
  -- caustic: bright patch low right
  if (x - 38) ^ 2 / 14 + (y - 49) ^ 2 / 6 < 1 then bias[k] = 2 end
  -- base darkness at the very bottom edge of the pool
end)
local idx = X.tone(c, liq, v, LIQ, { cuts = { 0.34, 0.54, 0.7, 0.84, 0.95 }, bias = bias, tok = ltok })
-- meniscus: bright line along the surface with a lit curve
liq:each(function(x, y)
  if y == 24 then c:put(x, y, LIQ[6], ltok) end
  if y == 25 then c:put(x, y, LIQ[5], ltok) end
end)
-- a few bubbles rising in the syrup (tiny, quiet)
c:put(35, 33, LIQ[5], ltok) c:put(36, 31, LIQ[5], ltok)

-- label wrapping the belly, bowed like a smile
local lab = HP.mask()
for x = 24, 40 do
  local off = floor(((x - CX) ^ 2) * 0.016 + 0.5)
  for y = 38 + off, 47 + off do if liq:has(x, y) then lab:set(x, y) end end
end
lab:each(function(x, y)
  local u = (x - CX) / 8
  local i = u < -0.6 and 4 or (u < 0.2 and 5 or (u < 0.55 and 4 or 3))
  if u > 0.8 then i = 2 end
  c:put(x, y, CREAM[i], lbtok)
end)
-- label border (russet) and top/bottom hem
lab:each(function(x, y)
  if not lab:has(x, y - 1) or not lab:has(x, y + 1) then c:put(x, y, (x - CX) > 4 and CREAM[1] or CREAM[2], lbtok) end
end)
-- sprig stamp: stem + needle pairs (russet)
local SP, SPD = "#9a4430", "#6a2c2c"
for y = 40, 46 do local off = floor(((CX - CX) ^ 2) * 0.016 + 0.5) c:put(CX, y, SPD, lbtok) end
for i = 0, 3 do
  local y = 42 + i * 2
  c:put(CX - 1, y, SP, lbtok) c:put(CX - 2, y - 1, SP, lbtok)
  c:put(CX + 1, y, SPD, lbtok) c:put(CX + 2, y - 1, SPD, lbtok)
end
c:put(CX, 41, SP, lbtok)

-- glass streak (specular) following the left curve + neck, and a small reflected dot
for y = 34, 47 do
  local dy = (y - CY) / RY
  local xs = floor(CX - RX * sqrt(max(0, 1 - dy * dy)) + 2.6)
  c:put(xs, y, GLS[6], gtok)
  if y < 38 then c:put(xs + 1, y, GLS[5], gtok) end
end
for y = 16, 23 do c:put(29, y, GLS[6], gtok) end
c:put(41, 48, GLS[5], gtok) c:put(42, 47, GLS[4], gtok)
c:put(23, 36, GLS[6], gtok) c:put(24, 35, GLS[6], gtok)
-- bright cream sparkle on the shoulder
c:sparkle(24, 33)

-- cork
local cork = c:rrect(28, 6, 35, 14, 2)
local cn = X.pillow(cork, 4)
G.toneN(c, cork, cn, CORK, { tok = ktok, cuts = { 0.2, 0.4, 0.58, 0.76 }, amb = 0.14, wrap = 0.3 })
cork:each(function(x, y) local h = X.hash(x, y, 13) if h > 0.86 then c:put(x, y, CORK[1], ktok) elseif h < 0.07 then c:put(x, y, CORK[5], ktok) end end)

-- wax collar over the cork and lip
local collar = c:rrect(26, 12, 37, 16, 1)
local wn = X.pillow(collar, 2.6)
G.toneN(c, collar, wn, WAX, { tok = wtok, cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 }, amb = 0.1, wrap = 0.35 })
for x = 27, 36 do c:put(x, 16, WAX[1], wtok) end   -- ambient under the collar
c:put(28, 13, WAX[6], wtok) c:put(29, 13, WAX[6], wtok)
for x = 28, 35 do c:put(x, 11, CORK[1], ktok) end  -- shadow of the collar on the cork
-- dripping wax (quirk): a runnel down the front of the neck ending in a fat bead
local dm, dn = G.tube({ { 34, 16 }, { 34, 19 }, { 35, 21 }, { 34, 25 } }, function(t) return 0.8 + 1.0 * max(0, t - 0.65) / 0.35 end)
G.toneN(c, dm, dn, WAX, { tok = wtok, cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 }, amb = 0.1, wrap = 0.3 })
local dx, dy = G.bez({ { 34, 16 }, { 34, 19 }, { 35, 21 }, { 34, 25 } }, 0.95)
c:put(floor(dx - 0.5), floor(dy - 0.5), WAX[6], wtok)

G.save(c, NAME)
