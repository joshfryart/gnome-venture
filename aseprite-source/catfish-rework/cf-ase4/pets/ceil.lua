local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local P = dofile(DIR .. "/pp.lua")
local L, E, RC, poly, part, px, ln, lathe, sep, fillm, rrect = P.L, P.E, P.RC, P.poly, P.part, P.px, P.ln, P.lathe, P.sep, P.fillm, P.rrect
local N = function() return P.new(48, 34) end
local F = function(c, n) P.finish(c, "cf-pet-" .. n, 48, 34) end
local sin, cos, pi, floor = math.sin, math.cos, math.pi, math.floor
local function bar(c, x0, x1, y, ramp) part(c, RC(x0, y, x1, y + 2), ramp or P.WOOD, 1, 1) px(c, { { x0 + 1, y, (ramp or P.WOOD).g } }) end
local function star(c, cx, cy, r) local pts = {} for i = 0, 9 do local a = -pi / 2 + i * pi / 5 local rr = (i % 2 == 0) and r or r * 0.45 pts[#pts + 1] = { cx + rr * cos(a), cy + rr * sin(a) } end
  part(c, poly(pts), P.GOLD, 1, 1, { lift = 0 }) c:put(floor(cx - 0.5), floor(cy - 0.5), P.GOLD.g) end
-- banana-leaf fan
do local c = N()
  bar(c, 5, 42, 1)
  ln(c, { { 12, 3 }, { 12, 8 } }, P.SISAL.m) ln(c, { { 35, 3 }, { 35, 8 } }, P.SISAL.m)
  local leaf = E(24, 20, 21, 9)
  part(c, leaf, P.LIME, 3, 3, { lift = 0 })
  ln(c, { { 5, 20 }, { 24, 19 }, { 43, 20 } }, P.LIME.D)
  for x = 7, 41, 3 do local up = 10 - math.abs(x - 24) * 0.25 ln(c, { { x, 20 }, { x + (x < 24 and 2 or -2), floor(20 - up * 0.8) } }, P.LIME.s, leaf) ln(c, { { x, 20 }, { x + (x < 24 and 1 or -1), 27 } }, P.LIME.s, leaf) end
  ln(c, { { 6, 19 }, { 22, 12 }, { 30, 12 } }, P.LIME.L, leaf)
  px(c, { { 14, 16, P.LIME.g }, { 15, 15, P.LIME.g } })
  part(c, poly({ { 19, 25 }, { 23, 22 }, { 22, 28 } }), P.LIME, 1, 1, { lift = -1 }) c:put(20, 25, P.LIME.D) -- a torn flap
  F(c, "banana_leaf_fan") end
-- brass lantern
do local c = N()
  ln(c, { { 24, 0 }, { 24, 4 } }, P.GOLD.s) part(c, E(24, 5, 2, 1.6), P.GOLD, 1, 1)
  part(c, poly({ { 24, 6 }, { 32, 12 }, { 16, 12 } }), P.BRONZE, 1, 1, { lift = 2 }) px(c, { { 23, 8, P.BRONZE.g } })
  part(c, RC(15, 12, 33, 13), P.BRONZE, 1, 1)
  local body = RC(17, 14, 31, 26) part(c, body, P.BRONZE, 1, 1, { lift = 1 })
  local win = RC(19, 15, 29, 25) fillm(c, win, P.GOLD.m) fillm(c, E(24, 20, 4, 4.5), P.GOLD.l) fillm(c, E(24, 21, 2, 2.4), P.GOLD.g)
  for _, x in ipairs({ 21, 24, 27 }) do ln(c, { { x, 15 }, { x, 25 } }, P.BRONZE.s) end
  ln(c, { { 19, 20 }, { 29, 20 } }, P.BRONZE.s) px(c, { { 20, 16, P.GOLD.g }, { 20, 17, P.GOLD.L } })
  part(c, RC(15, 26, 33, 27), P.BRONZE, 1, 1) part(c, poly({ { 17, 28 }, { 31, 28 }, { 28, 31 }, { 20, 31 } }), P.BRONZE, 1, 1, { lift = 1 }) part(c, E(24, 32, 1.4, 1.2), P.GOLD, 1, 1)
  ln(c, { { 7, 17 }, { 12, 21 } }, P.GOLD.L) ln(c, { { 36, 17 }, { 41, 21 } }, P.GOLD.L) -- glow rays
  px(c, { { 38, 14, P.GOLD.L }, { 10, 14, P.GOLD.L } })
  F(c, "brass_lantern") end
-- kente bunting
do local c = N()
  local pts = {} for x = 2, 45 do pts[#pts + 1] = { x, floor(2 + 5 * sin((x - 2) / 43 * pi) + 0.5) } end
  for _, p in ipairs(pts) do c:put(p[1], p[2], P.SISAL.m) c:put(p[1], p[2] + 1, P.SISAL.s) end
  local cols = { { P.RED, P.GOLD, P.NAVY }, { P.GOLD, P.LIME, P.RED }, { P.TEAL, P.GOLD, P.RED }, { P.RED, P.LIME, P.GOLD }, { P.GOLD, P.NAVY, P.RED }, { P.LIME, P.RED, P.GOLD } }
  for i = 1, 6 do local x0 = 4 + (i - 1) * 7 local y0 = pts[x0 - 1][2] + 2
    local fl = poly({ { x0, y0 }, { x0 + 6, y0 }, { x0 + 6, y0 + 14 }, { x0 + 3, y0 + 21 }, { x0, y0 + 14 } })
    local cs = cols[i] part(c, fl, cs[1], 1, 1, { lift = 0 })
    for y = y0, y0 + 20 do for x = x0, x0 + 6 do if fl:has(x, y) then local k = (y - y0) % 6 if k == 2 then c:put(x, y, cs[2].m) elseif k == 3 and (x - x0) % 2 == 0 then c:put(x, y, cs[3].m) elseif k == 0 and (x - x0) % 2 == 1 then c:put(x, y, cs[2].l) end end end end
    px(c, { { x0, y0 + 1, cs[1].g } })
  end
  F(c, "kente_bunting") end
-- marigold garland
do local c = N()
  local pts = {}
  for x = 2, 45 do local ph = ((x - 2) % 22) / 22 pts[#pts + 1] = { x, floor(2 + 15 * sin(ph * pi) + 0.5) } end
  for _, p in ipairs(pts) do c:put(p[1], p[2], P.LIME.s) end
  for i = 0, 15 do local k = floor(1 + i * 43 / 15 + 0.5) local p = pts[math.min(k + 1, #pts)] local x, y = p[1], p[2] + 1
    part(c, E(x, y + 1, 2.8, 2.8), (i % 3 == 1) and P.GOLD or P.ORANGE, 1, 1, { lift = (i % 2) })
    c:put(x, y + 1, P.ORANGE.D) c:put(x - 1, y, P.ORANGE.g)
    if i % 4 == 2 then part(c, P.leaf({ { x, y + 3 }, { x + 2, y + 6 }, { x + 1, y + 9 } }, 1.4), P.LIME, 1, 1) end
  end
  px(c, { { 23, 28, P.PINK.m } }) part(c, E(23, 19, 1.5, 1.5), P.PINK, 1, 1)
  F(c, "marigold_garland") end
-- panpipe chime
do local c = N()
  bar(c, 6, 41, 1, P.WOOD) for x = 8, 39, 6 do c:put(x, 1, P.GOLD.m) end
  part(c, RC(6, 3, 41, 5), P.RED, 1, 1) for x = 7, 40, 3 do c:put(x, 4, P.CREAM.m) end
  for i = 0, 8 do local x = 7 + i * 4 local len = 25 - i * 2 - (i > 4 and 0 or 0)
    local pipe = RC(x, 6, x + 2, 6 + len) part(c, pipe, P.SAND, 1, 1, { lift = (i % 2) })
    fillm(c, RC(x + 1, 6, x + 1, 7), P.BROWN.D) c:put(x, 7 + 0, P.SAND.g) end
  part(c, RC(6, 12, 41, 12), P.TEAL, 1, 1)
  ln(c, { { 24, 14 }, { 24, 28 } }, P.SISAL.m) part(c, poly({ { 21, 29 }, { 27, 29 }, { 28, 33 }, { 20, 33 } }), P.TEAL, 1, 1)
  F(c, "panpipe_chime") end
-- paper lantern string
do local c = N()
  for x = 2, 45 do c:put(x, floor(3 + 3 * sin((x - 2) / 43 * pi) + 0.5), P.SISAL.m) end
  local function lan(cx, top, w, h, ramp) local b = E(cx, top + h / 2, w, h / 2)
    part(c, RC(cx - 2, top - 1, cx + 1, top), P.GOLD, 1, 1) part(c, b, ramp, 2, 2, { lift = 1 })
    for k = -1, 1 do ln(c, { { cx + k * floor(w / 2.2), top + 2 }, { cx + k * floor(w / 2.2), top + h - 2 } }, ramp.s, b) end
    part(c, RC(cx - 2, top + h, cx + 1, top + h + 1), P.GOLD, 1, 1) ln(c, { { cx - 1, top + h + 2 }, { cx - 1, top + h + 5 } }, P.GOLD.m) c:put(cx, top + h + 5, P.GOLD.l)
    px(c, { { cx - floor(w / 2), top + 3, ramp.g } }) end
  lan(9, 6, 5, 14, P.RED) lan(24, 9, 7, 17, P.CREAM) lan(39, 6, 5, 14, P.RED)
  px(c, { { 22, 17, P.RED.m }, { 23, 16, P.RED.m }, { 24, 17, P.RED.m }, { 25, 16, P.RED.m }, { 24, 18, P.RED.m }, { 23, 18, P.RED.m }, { 22, 15, P.RED.m } })
  F(c, "paper_lantern_string") end
-- rain-cloud mobile
do local c = N()
  bar(c, 4, 43, 1)
  ln(c, { { 24, 3 }, { 24, 7 } }, P.SISAL.m)
  local cl = E(24, 12, 11, 4.4):add(E(18, 10, 5, 4)):add(E(27, 9, 5, 4)) part(c, cl, P.SILVER, 3, 3, { lift = 1 })
  fillm(c, RC(14, 15, 34, 16):clip(cl), P.GREY.b)
  px(c, { { 16, 7, P.SILVER.g }, { 15, 8, P.SILVER.g }, { 22, 6, P.SILVER.g } })
  for _, d in ipairs({ { 7, 8 }, { 40, 8 }, { 16, 20 }, { 31, 22 }, { 24, 25 } }) do
    local top = d[2] ln(c, { { d[1], 3 + (d[1] < 14 and 0 or 12) }, { d[1], top } }, P.SISAL.m)
    part(c, poly({ { d[1], top + 1 }, { d[1] + 2.4, top + 5 }, { d[1], top + 8 }, { d[1] - 2.4, top + 5 } }), P.AQUA, 1, 1) c:put(d[1] - 1, top + 4, P.AQUA.g)
  end
  F(c, "rain_cloud_mobile") end
-- siesta fan
do local c = N()
  local fan = L.mask() for y = 0, 33 do for x = 0, 47 do local dx, dy = x - 24, y - 3 if dy >= 0 and dx * dx + dy * dy <= 22 * 22 and dy >= math.abs(dx) * 0.55 then fan:set(x, y) end end end
  part(c, fan, P.CREAM, 3, 3, { lift = 0 })
  for k = 0, 9 do local a = pi * (0.22 + k * 0.056) if k % 2 == 0 then
    local a0, a1 = pi * (0.18 + k * 0.064), pi * (0.18 + (k + 1) * 0.064)
    fillm(c, fan:filter(function(x, y) local ang = math.atan(y - 3, x - 24) if ang < 0 then ang = ang + 2 * pi end return ang >= a0 and ang <= a1 and (x - 24) ^ 2 + (y - 3) ^ 2 > 36 end), P.ORANGE.m) end end
  fillm(c, fan:filter(function(x, y) return (x - 24) ^ 2 + (y - 3) ^ 2 >= 20 ^ 2 end), P.BLUE.m)
  for x = 4, 44, 3 do local y = floor(3 + math.sqrt(math.max(0, 20.5 ^ 2 - (x - 24) ^ 2))) if fan:has(x, y) then c:put(x, y, P.BLUE.L) end end
  part(c, E(24, 4, 3, 2.2), P.BRONZE, 1, 1) px(c, { { 23, 3, P.BRONZE.g } })
  part(c, RC(23, 0, 24, 2), P.GOLD, 1, 1)
  px(c, { { 14, 18, P.CREAM.g }, { 13, 19, P.CREAM.g }, { 10, 22, P.ORANGE.L } })
  -- a drowsy tassel
  ln(c, { { 24, 26 }, { 24, 29 } }, P.RED.m) part(c, poly({ { 22, 30 }, { 26, 30 }, { 27, 33 }, { 21, 33 } }), P.RED, 1, 1)
  F(c, "siesta_fan") end
-- southern cross mobile
do local c = N()
  bar(c, 5, 42, 1)
  local st = { { 9, 15, 6 }, { 24, 10, 6.4 }, { 38, 17, 6 }, { 17, 27, 6.4 }, { 31, 29, 4.6 } }
  ln(c, { { 9, 3 }, { 9, 10 } }, P.SISAL.m) ln(c, { { 24, 3 }, { 24, 8 } }, P.SISAL.m) ln(c, { { 38, 3 }, { 38, 12 } }, P.SISAL.m)
  ln(c, { { 24, 16 }, { 17, 21 } }, P.SISAL.m) ln(c, { { 38, 23 }, { 31, 25 } }, P.SISAL.m)
  for _, s in ipairs(st) do star(c, s[1], s[2] + 0.5, s[3]) end
  px(c, { { 22, 6, P.GOLD.g }, { 18, 24, P.GOLD.g } })
  F(c, "southern_cross_mobile") end
-- steel-pan chime
do local c = N()
  bar(c, 5, 42, 1)
  ln(c, { { 10, 3 }, { 14, 10 } }, P.SISAL.m) ln(c, { { 37, 3 }, { 34, 10 } }, P.SISAL.m)
  local pan = E(24, 14, 16, 5.4) part(c, pan, P.STEEL, 3, 3)
  fillm(c, E(24, 14, 13, 3.8), P.STEEL.l) fillm(c, E(24, 14.5, 12, 3), P.STEEL.m)
  for _, p in ipairs({ { 15, 14, 2 }, { 20, 12, 2 }, { 26, 12, 2 }, { 32, 14, 2 }, { 24, 15, 2 }, { 19, 16, 1 }, { 29, 16, 1 } }) do part(c, E(p[1], p[2], p[3] + 0.5, p[3] - 0.3), P.STEEL, 1, 1, { lift = 1 }) end
  px(c, { { 14, 11, P.STEEL.g }, { 15, 11, P.STEEL.g }, { 19, 10, P.STEEL.g } })
  part(c, RC(10, 19, 38, 22), P.TEAL, 1, 1, { lift = -1 }) for x = 11, 37, 3 do c:put(x, 20, P.GOLD.m) end
  for _, b in ipairs({ { 13, P.RED }, { 20, P.GOLD }, { 28, P.TEAL }, { 35, P.PINK } }) do ln(c, { { b[1], 23 }, { b[1], 27 } }, P.SISAL.m) part(c, E(b[1], 29, 2.4, 2.4), b[2], 1, 1) c:put(b[1] - 1, 28, b[2].g) end
  F(c, "steel_pan_chime") end
