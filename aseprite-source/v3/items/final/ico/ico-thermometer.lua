-- ico-thermometer (Opus single pass). Slim upright glass thermometer: brass hanging cap with a dark eye, a narrow
-- glass tube with a bright left rim streak and pale core, red mercury column (cylinder-lit, 6 tones) rising from a
-- glossy red bulb seen through a 3 px glass ring; brass scale ticks on the right edge (long/short).
-- Material: glass rim + pale core + cool shade edge, mercury specular, brass bevel + bright top edge + hole,
-- AO where tube meets cap and bulb.
-- quirk: a runaway bead of mercury has split off and floats above the column.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_aR0_2.lua")
local HP, X, K = D.HP, D.X, D.K
local max, min, sqrt = math.max, math.min, math.sqrt
local c = D.new("ico-thermometer")
local GL, RED, BR = D.GLASS, D.EMBER, D.GOLD

-- scale ticks (behind the glass edge, brass), long every other
local ticks = HP.mask()
for i, y in ipairs{ 15, 20, 25, 30, 35 } do
  local L = (i % 2 == 1) and 5 or 3
  ticks:add(c:rect(37, y, 37 + L, y + 1))
end
D.lit(c, ticks, BR, { R = 1, amb = 0.25 })

-- glass: tube + bulb
local tube = c:rrect(27, 9, 37, 44, 5)
local bulb = c:ellipse(32, 48, 10, 10)
local glass = tube:copy():add(bulb)
-- tube: cylinder across x; bulb: sphere
local n = {}
tube:each(function(x, y) local t = max(-0.95, min(0.95, (x - 32) / 5.6)) n[K(x, y)] = { t, -0.1, sqrt(1 - t * t) } end)
local nb = X.sphere(31.6, 47.6, 10, bulb)
for k, v in pairs(nb) do n[k] = v end
local v = X.light(n, { amb = 0.35, wrap = 0.5 })
local bias = {}
X.ao(bias, glass, c:rect(20, 0, 44, 10), 2, -1)          -- under the cap
X.tone(c, glass, v, GL, { cuts = { 0.3, 0.5, 0.66, 0.8, 0.95 }, bias = bias })
-- cool shade edge on the right of the glass
glass:edge():each(function(x, y) if x >= 34 or (y > 50 and x > 30) then c:put(x, y, GL[1]) end end)
-- empty bore above the column (pale channel)
c:fillMask(c:rect(31, 12, 33, 22), GL[3])
c:fillMask(c:rect(31, 12, 31, 22), GL[4])

-- mercury bulb (sphere, 6 tones) + column (cylinder)
local mb = c:ellipse(32, 48, 7, 7)
local idx, _ = X.tone(c, mb, X.light(X.sphere(31, 47, 7, mb), { amb = 0.06, wrap = 0.2 }), RED, { cuts = D.CUTS })
local col = c:rect(30, 23, 34, 42)
local cn = {}
col:each(function(x, y) local t = max(-0.95, min(0.95, (x - 32.2) / 2.9)) cn[K(x, y)] = { t, 0, sqrt(1 - t * t) } end)
local cb = {}
col:each(function(x, y) if y == 23 then cb[K(x, y)] = 1 end end)  -- meniscus lip
X.tone(c, col, X.light(cn, { amb = 0.08, wrap = 0.2 }), RED, { cuts = D.CUTS, bias = cb })
-- where the column enters the bulb: a dark neck row (AO)
c:put(30, 42, RED[2]) c:put(34, 42, RED[1])
-- glossy bulb specular + glass glare crossing the ring
D.put(c, { {27, 43}, {28, 43}, {27, 44} }, RED[6])
D.put(c, { {28, 44} }, D.CREAM)
D.put(c, { {24, 42}, {25, 41}, {26, 40} }, GL[6])
-- faint cool reflected light low-right on the mercury bulb
D.put(c, { {37, 51}, {36, 53}, {35, 54} }, "#9a4a78")
-- glass rim streak on the lit left side of the tube
for y = 14, 38 do c:put(28, y, (y % 9 == 0) and GL[4] or GL[6]) end
c:put(29, 12, GL[6]) c:put(29, 13, GL[6])

-- quirk: runaway mercury bead floating above the column
D.put(c, { {31, 17}, {32, 17}, {31, 18}, {32, 18} }, RED[4])
c:put(32, 18, RED[2]) c:put(31, 17, RED[6])

-- brass cap with a hanging eye
local cap = c:rrect(26, 5, 38, 11, 2)
local cn2 = {}
cap:each(function(x, y) local t = max(-0.95, min(0.95, (x - 31.5) / 6.5)) cn2[K(x, y)] = { t, (y - 8) / 6, sqrt(1 - t * t) } end)
X.tone(c, cap, X.light(cn2, { amb = 0.1, wrap = 0.3 }), BR, { cuts = D.CUTS })
for x = 28, 36 do c:put(x, 5, BR[6]) end               -- bright top edge
for x = 27, 37 do c:put(x, 11, BR[2]) end               -- underside lip
c:fillMask(c:rect(31, 7, 33, 8), "#3a2418")             -- the eye
c:put(31, 9, BR[2]) c:put(29, 6, D.CREAM)               -- specular
D.save(c)
