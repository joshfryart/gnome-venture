-- salsa-verde (final, artist D14_0). A pitted basalt molcajete seen from a little above: thick bevelled rim, vesicular
-- stone (dark pores with a lit lip, quartz specks), three stubby legs, and a bowl of chunky green salsa (cilantro
-- flecks, pale seeds, onion bits, wet glints) with a smooth granite tejolote standing in it, its tip green-smeared.
-- A husk-split tomatillo with a ribbed papery lantern leans against the bowl, a pale green fruit glossy inside.
-- quirk: the bowl is carved as a little pig: snout with two nostrils and two dot eyes on the front.
local NAME = "salsa-verde"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD14_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local BAS = { "#1c1b2a", "#2c2b40", "#434259", "#5d5c76", "#7e7f98", "#a8a9be" }
local GRA = { "#34344c", "#54566f", "#777994", "#9fa1b8", "#c6c7d8", "#ecebf2" }
local SA  = { "#1b4326", "#2a6232", "#418a3b", "#68b046", "#98d058", "#ccea88" }
local HUSK = { "#6e5a3c", "#95805a", "#bba67a", "#dccb98", "#f0e4b6", "#fdf6d6" }
local TOM = { "#2a5a2c", "#3f7e36", "#5fa040", "#88c456", "#b4e078", "#e4f6a8" }
local CX, CY, RX, RY = 34, 27, 21.5, 7.5

c:groundShadow(34, 54, 21.5, 3)
-- side legs (behind the body)
local function leg(x0, x1, y0, y1)
  local m = c:rrect(x0, y0, x1, y1, 2)
  local n = {}
  local mid = (x0 + x1) / 2
  m:each(function(x, y) local t = max(-.95, min(.95, (x - mid) / ((x1 - x0) / 2 + .6)))
    n[K(x, y)] = { t, 0.25, sqrt(1 - t * t) } end)
  local bias = {}
  m:each(function(x, y) if y <= y0 + 1 then bias[K(x, y)] = -2 end if y >= y1 - 1 then bias[K(x, y)] = -1 end end)
  X.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.3 }), BAS, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 }, bias = bias, tok = { r = { name = "leg" .. x0 } } })
  return m
end
leg(18, 24, 44, 52) leg(44, 50, 44, 52)

-- body -------------------------------------------------------------------------------------
local rimOut = c:ellipse(CX, CY, RX, RY)
local body = c:ellipse(CX, CY, RX, 22):clip(c:rect(0, CY, 63, 49))
body:add(rimOut)
local function hw(y) return RX * sqrt(max(0.02, 1 - ((min(y, 49) - CY) / 22) ^ 2)) end
local bn = {}
body:each(function(x, y)
  local h = hw(y)
  local nx = max(-.96, min(.96, (x - CX) / (h + 0.6)))
  local ny = max(0, (y - CY) / 22) * 0.95
  local nz = sqrt(max(0.03, 1 - nx * nx - ny * ny))
  bn[K(x, y)] = { nx, ny, nz }
end)
local bb = {}
X.ao(bb, body, rimOut, 2, -1)
local btok = { r = { name = "body" } }
local bidx = X.tone(c, body, X.light(bn, { amb = 0.1, wrap = 0.32 }), BAS, { cuts = { 0.24, 0.4, 0.56, 0.72, 0.88 }, bias = bb, tok = btok })
-- vesicular pits with a lit lip, quartz specks
body:each(function(x, y)
  local h = X.hash(x, y, 7)
  local i = bidx[K(x, y)] or 3
  if h < 0.05 and body:has(x + 1, y + 1) then
    c:put(x, y, BAS[max(1, i - 2)], btok) c:put(x + 1, y + 1, BAS[min(6, i + 1)], btok)
  elseif h > 0.985 then c:put(x, y, BAS[6], btok) end
end)
local brim = X.rim(bn)
body:edge():each(function(x, y) if y > 30 and (brim[K(x, y)] or 0) > 0.7 then c:put(x, y, "#4a4c78", btok) end end)

-- rim ring -----------------------------------------------------------------------------------
local inner = c:ellipse(CX, CY, 18.4, 5.3)
local ring = rimOut:copy():cut(inner)
local rn = X.pillow(ring, 2.2, 1)
local rtok = { r = { name = "rim" } }
local ridx = X.tone(c, ring, X.light(rn, { amb = 0.16, wrap = 0.3 }), BAS, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 }, tok = rtok })
ring:each(function(x, y)
  local h = X.hash(x, y, 3)
  local i = ridx[K(x, y)] or 3
  if h < 0.06 then c:put(x, y, BAS[max(1, i - 2)], rtok) elseif h > 0.95 then c:put(x, y, BAS[min(6, i + 2)], rtok) end
end)
-- front lip shadow line under the rim on the bowl
rimOut:shift(0, 1):each(function(x, y) if body:has(x, y) and not rimOut:has(x, y) then c:put(x, y, BAS[1], btok) end end)
-- inside back wall (dark) visible above the sauce
local wn = {}
inner:each(function(x, y) wn[K(x, y)] = { 0, 0.3, 0.9 } end)
X.tone(c, inner, X.light(wn, { amb = 0 }), BAS, { cuts = { 0.4, 0.6, 0.8, 0.9, 0.97 }, tok = { r = { name = "wall" } } })
inner:each(function(x, y) if y <= 23 and (x + y) % 3 == 0 then c:put(x, y, BAS[2]) end end)

-- sauce ---------------------------------------------------------------------------------------
local sauce = c:ellipse(CX, CY + 1.4, 18.2, 5.3):clip(inner)
local sn = X.pillow(sauce, 3.2, 0.7)
local satok = { r = { name = "sauce" } }
local sb = {}
sauce:each(function(x, y) if y <= 24 then sb[K(x, y)] = -1 end end)
local sidx = X.tone(c, sauce, X.light(sn, { amb = 0.3, wrap = 0.4 }), SA, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = sb, tok = satok })
sauce:each(function(x, y)
  local h = X.hash(x, y, 11)
  local i = sidx[K(x, y)] or 3
  if h < 0.07 then c:put(x, y, SA[1], satok)                      -- cilantro fleck (dark)
  elseif h < 0.12 then c:put(x, y, SA[min(6, i + 2)], satok)      -- bright chunk
  elseif h > 0.965 then c:put(x, y, "#f4f0c8", satok)             -- pale seed
  elseif h > 0.945 then c:put(x, y, "#b6cf6a", satok) end         -- onion bit
end)
-- a few 2px cilantro leaves
for _, q in ipairs{ {26,29,0}, {41,31,1}, {33,25,0}, {45,28,1}, {30,31,1} } do
  c:put(q[1], q[2], SA[2], satok) c:put(q[1] + 1, q[2], SA[4], satok) c:put(q[1] + (q[3] == 0 and 1 or 0), q[2] - 1, SA[5], satok)
end
-- wet glints
c:put(24, 27, "#f2fbd0") c:put(25, 27, "#f2fbd0") c:put(38, 30, "#f2fbd0") c:put(29, 30, SA[6])
-- meniscus (dark line where the sauce meets the stone wall)
sauce:edge():each(function(x, y) if y >= 28 then c:put(x, y, SA[2], satok) end end)

-- pestle ----------------------------------------------------------------------------------------
local pm, pn, PT = G.tube({ { 47.5, 10.5 }, { 45.5, 17 }, { 43.5, 23 }, { 41.8, 29.5 } }, function(t) return 2.3 - 0.35 * t end)
local capm, capn = G.oval(47.8, 9.6, 3.1, 2.8, 0, 1)
capm:cut(pm)
local ptok = { r = { name = "pestle" } }
G.toneN(c, pm, pn, GRA, { tok = ptok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 }, amb = 0.12, wrap = 0.3 })
G.toneN(c, capm, capn, GRA, { tok = ptok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 }, amb = 0.12, wrap = 0.3 })
-- speckled granite
pm:each(function(x, y) local h = X.hash(x, y, 5) if h < 0.07 then c:put(x, y, GRA[2], ptok) elseif h > 0.94 then c:put(x, y, GRA[6], ptok) end end)
-- collar groove
for _, q in ipairs{ {46,13},{47,13},{45,14} } do if pm:has(q[1], q[2]) then c:put(q[1], q[2], GRA[1], ptok) end end
-- green dip on the lower end + a drip
pm:each(function(x, y) local k = K(x, y) if PT[k] > 0.8 then c:put(x, y, SA[(x + y) % 2 == 0 and 3 or 4], ptok) end end)
c:put(42, 26, SA[3], ptok) c:put(42, 27, SA[2], ptok)
-- ripple ring where the pestle meets the sauce
for _, q in ipairs{ {38,30},{39,31},{40,31},{44,31},{45,30},{46,29} } do if sauce:has(q[1], q[2]) then c:put(q[1], q[2], SA[6], satok) end end
c:put(47, 7, GRA[6], ptok) c:put(48, 7, GRA[6], ptok)         -- polished cap glint

-- tomatillo with split husk ----------------------------------------------------------------------
local TCX, TCY = 14.5, 46
local husk = c:ellipse(TCX, TCY + 0.5, 6.6, 6.4)
husk:add(c:poly{ { TCX - 3, TCY - 4 }, { TCX, TCY - 8.2 }, { TCX + 3, TCY - 4 } })
local hn = X.pillow(husk, 3.4, 1)
local htok = { r = { name = "husk" } }
local hb = {}
X.ao(hb, husk, body, 1, -1)
local hidx = X.tone(c, husk, X.light(hn, { amb = 0.18, wrap = 0.4 }), HUSK, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = hb, tok = htok })
-- ribs from the apex, curving to the base
for _, off in ipairs{ -4.6, -2.3, 0, 2.3, 4.6 } do
  for y = TCY - 7, TCY + 6 do
    local f = (y - (TCY - 8)) / 14
    local x = floor(TCX + off * sin(f * pi * 0.5) + 0.5)
    if husk:has(x, y) then c:put(x, y, HUSK[max(1, (hidx[K(x, y)] or 3) - 1)], htok) end
  end
end
-- split: front opening shows the fruit
local opening = c:ellipse(TCX + 0.2, TCY + 1.6, 3.7, 4.2):clip(husk)
local fn = X.sphere(TCX - 0.4, TCY + 1, 4.6, opening)
X.tone(c, opening, X.light(fn, { amb = 0.1, wrap = 0.25 }), TOM, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 }, tok = { r = { name = "tomatillo" } } })
opening:edge():each(function(x, y) if y < TCY + 1 then c:put(x, y, HUSK[1], htok) else c:put(x, y, HUSK[2], htok) end end)
c:put(TCX - 2, TCY - 0.3, "#fbffe0") c:put(TCX - 1, TCY - 0.3, "#fbffe0") c:put(TCX - 2, TCY + 0.7, TOM[6])
-- stem knot at the apex
c:put(TCX, TCY - 8, HUSK[1]) c:put(TCX, TCY - 9, "#6a4a2c") c:put(TCX + 1, TCY - 9, "#8a6a40")
-- contact shadow on the ground
for x = 9, 21 do c:put(x, 53, "#4c4c68") end

-- front leg + pig snout (quirk) ----------------------------------------------------------------------
leg(31, 37, 46, 53)
for x = 31, 37 do c:put(x, 46, BAS[1]) end
local sn2 = c:ellipse(34, 41, 5.2, 3.5)
local snn = X.pillow(sn2, 2.6, 1)
local sntok = { r = { name = "snout" } }
X.tone(c, sn2, X.light(snn, { amb = 0.2, wrap = 0.4 }), BAS, { cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 }, tok = sntok })
sn2:edge():each(function(x, y) if y >= 41 then c:put(x, y, BAS[1], sntok) end end)
for _, q in ipairs{ {31,41},{36,41} } do c:put(q[1], q[2], BAS[1]) c:put(q[1] + 1, q[2], BAS[1]) c:put(q[1], q[2] + 1, BAS[1]) c:put(q[1] + 1, q[2] + 1, BAS[2]) end
c:put(32, 40, BAS[6]) c:put(33, 39, BAS[5])
-- dot eyes carved above the snout
for _, q in ipairs{ {25,38},{43,38} } do c:put(q[1], q[2], BAS[1]) c:put(q[1] + 1, q[2], BAS[1]) c:put(q[1] + 1, q[2] + 1, BAS[5]) end
G.save2(c, NAME)
