local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local P = dofile(DIR .. "/pp.lua")
local L, E, RC, poly, part, px, ln, lathe, sep, fillm, rrect = P.L, P.E, P.RC, P.poly, P.part, P.px, P.ln, P.lathe, P.sep, P.fillm, P.rrect
local N = function() return P.new(30, 26) end
local F = function(c, n) P.finish(c, "cf-pet-" .. n, 30, 26) end
local sin, cos, pi = math.sin, math.cos, math.pi

-- acacia perch
do local c = N()
  local base = E(15, 22, 11, 2.6) part(c, base, P.CLAY, 2, 2)
  ln(c, { { 6, 21 }, { 24, 21 } }, P.CLAY.L) px(c, { { 10, 23, P.CLAY.s }, { 17, 23, P.CLAY.s } })
  local trunk = L.tube({ { 15, 21 }, { 15, 15 }, { 11, 10 } }, function() return 1.4 end) part(c, trunk, P.WOOD, 1, 1)
  local t2 = L.tube({ { 15, 15 }, { 19, 11 }, { 22, 8 } }, function() return 1.2 end) part(c, t2, P.WOOD, 1, 1)
  part(c, E(15, 6, 13, 3.2), P.LIME, 3, 3) part(c, E(11, 9, 8, 2.4), P.LIME, 2, 2, { lift = -1 }) part(c, E(22, 7, 6, 2.4), P.LIME, 2, 2, { lift = -1 })
  for _, p in ipairs({ { 6, 5 }, { 10, 4 }, { 15, 3 }, { 20, 4 }, { 8, 8 }, { 24, 6 } }) do c:put(p[1], p[2], P.LIME.L) end
  px(c, { { 5, 6, P.LIME.g }, { 6, 4, P.LIME.g } })
  part(c, E(23, 4, 2, 1.6), P.GOLD, 1, 1) px(c, { { 25, 4, P.ORANGE.m }, { 22, 3, '#' } }) -- a small weaver bird on the canopy
  F(c, "acacia_perch") end
-- bonsai
do local c = N()
  local pot = P.lathe(15, 17, { 10, 9, 9, 8, 8, 7 }) part(c, pot, P.NAVY, 2, 2)
  part(c, RC(5, 16, 24, 17), P.GOLD, 1, 1)
  ln(c, { { 8, 20 }, { 21, 20 } }, P.BLUE.m, pot) for x = 9, 21, 4 do c:put(x, 21, P.GOLD.m) end
  px(c, { { 6, 19, P.NAVY.L } })
  local trunk = L.tube({ { 14, 16 }, { 12, 12 }, { 16, 9 }, { 14, 5 } }, function() return 1.3 end) part(c, trunk, P.WOOD, 1, 1)
  local br = L.tube({ { 14, 11 }, { 20, 10 }, { 24, 8 } }, function() return 1 end) part(c, br, P.WOOD, 1, 1)
  local br2 = L.tube({ { 12, 12 }, { 7, 10 }, { 5, 8 } }, function() return 1 end) part(c, br2, P.WOOD, 1, 1)
  for _, b in ipairs({ { 7, 7, 5, 3.2 }, { 24, 7, 4.8, 3.2 }, { 15, 4, 6, 3.4 } }) do part(c, E(b[1], b[2], b[3], b[4]), P.PINK, 2, 2) end
  for _, p in ipairs({ { 6, 6 }, { 9, 8 }, { 15, 3 }, { 18, 5 }, { 23, 6 }, { 26, 8 } }) do c:put(p[1], p[2], P.PINK.g) end
  for _, p in ipairs({ { 10, 5 }, { 21, 9 }, { 13, 6 } }) do c:put(p[1], p[2], P.PINK.s) end
  px(c, { { 18, 19, P.PINK.l }, { 19, 19, P.PINK.m }, { 19, 20, P.PINK.s } }) -- fallen petal on the pot
  F(c, "bonsai") end
-- parrot perch
do local c = N()
  local bar = RC(3, 20, 26, 21) part(c, bar, P.WOOD, 1, 1) part(c, RC(5, 22, 7, 24), P.WOOD, 1, 1) part(c, RC(22, 22, 24, 24), P.WOOD, 1, 1)
  px(c, { { 4, 20, P.WOOD.g }, { 24, 20, P.WOOD.L } })
  local tail = poly({ { 13, 15 }, { 18, 15 }, { 22, 25 }, { 17, 23 }, { 14, 24 } }) part(c, tail, P.TEAL, 1, 1)
  px(c, { { 17, 21, P.BLUE.m }, { 18, 22, P.BLUE.m } })
  local body = E(14, 13, 5.4, 6.8) part(c, body, P.LIME, 3, 3)
  local head = E(11, 6, 4.2, 4) part(c, head, P.LIME, 2, 2)
  part(c, E(15, 13, 2.8, 4.2), P.BLUE, 1, 1) px(c, { { 14, 11, P.BLUE.g } })
  part(c, poly({ { 6, 5 }, { 9, 4 }, { 9, 9 }, { 7, 9 } }), P.GOLD, 1, 1) px(c, { { 6, 7, P.GOLD.D } })
  px(c, { { 10, 5, '#fff4d6' }, { 11, 5, '#' }, { 10, 6, '#' } }) c:put(10, 5, '#fff4d6') c:put(11, 5, '#') c:put(10, 6, '#fff4d6') c:put(11, 6, '#')
  part(c, E(10, 9, 1.4, 1.2), P.RED, 1, 1)
  part(c, poly({ { 11, 3 }, { 13, 0.5 }, { 14, 4 } }), P.RED, 1, 1)  -- crest feather
  px(c, { { 9, 4, P.LIME.g }, { 8, 5, P.LIME.L }, { 11, 10, P.LIME.L }, { 12, 17, P.LIME.s } })
  px(c, { { 12, 19, P.GOLD.m }, { 15, 19, P.GOLD.m }, { 12, 20, P.GOLD.D } })
  F(c, "parrot_perch") end
-- rain stick
do local c = N()
  local tube = L.tube({ { 4, 22 }, { 26, 5 } }, function() return 3 end)
  local cap1 = L.tube({ { 3, 23 }, { 5, 21.5 } }, function() return 3.6 end) local cap2 = L.tube({ { 25, 6 }, { 27, 4.5 } }, function() return 3.6 end)
  part(c, tube, P.GOLD, 2, 2, { lift = -1 }) part(c, cap1, P.BROWN, 1, 1) part(c, cap2, P.BROWN, 1, 1)
  local cols = { P.RED.m, P.TEAL.m, P.RED.m, P.TEAL.m, P.RED.m }
  for i = 1, 5 do local t = 0.2 + i * 0.13
    local x, y = 4 + 22 * t, 22 - 17 * t
    for d = -3, 3 do local px_, py = math.floor(x + d * 0.62 + 0.5), math.floor(y + d * 0.8 + 0.5) if tube:has(px_, py) then c:put(px_, py, (i % 2 == 0) and P.TEAL.m or P.RED.m) end end end
  px(c, { { 9, 17, P.GOLD.g }, { 10, 16, P.GOLD.g }, { 14, 13, P.GOLD.g } })
  for _, d in ipairs({ { 8, 8 }, { 13, 3 }, { 21, 17 } }) do part(c, poly({ { d[1], d[2] - 2 }, { d[1] + 1.5, d[2] + 0.5 }, { d[1] + 0.5, d[2] + 2 }, { d[1] - 1, d[2] + 1 } }), P.AQUA, 1, 1) end
  px(c, { { 8, 8, P.AQUA.g } })
  F(c, "rain_stick") end
-- shadow puppet screen
do local c = N()
  local fr = rrect(3, 3, 26, 21, 2) part(c, fr, P.WOOD, 2, 2)
  part(c, rrect(6, 6, 23, 18, 1), P.SAND, 1, 1, { lift = 3 })
  fillm(c, RC(7, 7, 22, 17), P.CREAM.l) fillm(c, RC(8, 8, 21, 16), P.CREAM.L) fillm(c, E(15, 12, 5, 4), P.CREAM.g)
  local pup = poly({ { 14, 8 }, { 16, 8 }, { 17, 10 }, { 16, 11 }, { 19, 13 }, { 17, 16 }, { 16, 16 }, { 15, 13 }, { 14, 16 }, { 12, 16 }, { 13, 13 }, { 12, 11 }, { 14, 10 } })
  fillm(c, pup, P.DEEP.s) fillm(c, pup:shift(0, 0):edge(), P.DEEP.D)
  px(c, { { 15, 9, P.CREAM.g }, { 12, 10, P.DEEP.D }, { 19, 10, P.DEEP.D }, { 20, 11, P.DEEP.D }, { 11, 12, P.DEEP.D } })
  px(c, { { 14, 13, P.ORANGE.l }, { 15, 14, P.ORANGE.l } })
  ln(c, { { 20, 11 }, { 20, 16 } }, P.WOOD.m)
  px(c, { { 8, 8, P.CREAM.g }, { 9, 7, P.CREAM.g } })
  part(c, RC(5, 22, 8, 24), P.WOOD, 1, 1) part(c, RC(21, 22, 24, 24), P.WOOD, 1, 1)
  px(c, { { 3, 12, P.GOLD.m }, { 26, 12, P.GOLD.m }, { 3, 11, P.GOLD.l }, { 26, 11, P.GOLD.l } })
  F(c, "shadow_puppet_screen") end
-- sunflower head
do local c = N()
  part(c, E(15, 22, 11, 2.2), P.SAND, 2, 2)
  for _, s in ipairs({ { 6, 21 }, { 9, 22 }, { 20, 21 }, { 23, 22 }, { 14, 23 } }) do part(c, poly({ { s[1], s[2] }, { s[1] + 1.4, s[2] - 0.6 }, { s[1] + 2, s[2] + 0.6 }, { s[1] + 0.4, s[2] + 1 } }), P.BROWN, 1, 1) end
  local stem = L.tube({ { 15, 22 }, { 14, 17 }, { 15, 13 } }, function() return 1 end) part(c, stem, P.LIME, 1, 1)
  part(c, P.leaf({ { 14, 19 }, { 9, 17 }, { 5, 18 } }, 2.4), P.LIME, 1, 1)
  for i = 0, 11 do local a = i * pi / 6 + 0.2
    local p = { { 15 + 4 * cos(a), 8 + 4 * sin(a) }, { 15 + 9.2 * cos(a - .2), 8 + 7.4 * sin(a - .2) }, { 15 + 9.6 * cos(a), 8 + 7.8 * sin(a) }, { 15 + 9.2 * cos(a + .2), 8 + 7.4 * sin(a + .2) } }
    part(c, poly(p), P.GOLD, 1, 1, { lift = (i % 2) })
  end
  part(c, E(15, 8, 5, 4.4), P.BROWN, 2, 2)
  for _, p in ipairs({ { 13, 7 }, { 16, 6 }, { 15, 9 }, { 12, 10 }, { 18, 9 }, { 17, 11 } }) do c:put(p[1], p[2], P.BROWN.L) end
  px(c, { { 12, 6, P.BROWN.g }, { 19, 7, P.BROWN.D } })
  fillm(c, E(15, 8, 5, 4.4):clip(RC(18, 4, 22, 12)):clip(E(20.5, 8, 2, 2.2)), P.SAND.m) -- a peck taken from the seeds
  F(c, "sunflower_head") end
-- terracotta catgrass
do local c = N()
  local pot = lathe(15, 15, { 9, 8, 8, 7, 7, 6, 6, 5 }) part(c, pot, P.CLAY, 2, 2)
  part(c, RC(5, 14, 24, 15), P.CLAY, 1, 1)
  fillm(c, RC(7, 18, 23, 19), P.IVORY.m) for x = 8, 22, 3 do c:put(x, 18, P.AQUA.m) c:put(x + 1, 19, P.AQUA.m) end
  ln(c, { { 7, 20 }, { 22, 20 } }, P.CLAY.s, pot)
  px(c, { { 6, 16, P.CLAY.g }, { 6, 17, P.CLAY.L }, { 5, 15, P.CLAY.L } })
  for i = 0, 8 do local x = 7 + i * 2 local h = 6 + ((i * 5) % 6) local lean = ((i % 3) - 1)
    part(c, L.tube({ { x, 14 }, { x + lean, 14 - h / 2 }, { x + lean * 2, 14 - h } }, function(t) return 1.3 - t end), P.LIME, 1, 1, { lift = (i % 2) })
  end
  px(c, { { 15, 4, P.LIME.g }, { 9, 6, P.LIME.g } })
  px(c, { { 20, 21, P.CLAY.D }, { 21, 22, P.CLAY.D }, { 19, 22, P.CLAY.D } }) -- a paw print
  F(c, "terracotta_catgrass") end
-- weaver-bird nest
do local c = N()
  local br = L.tube({ { 2, 3 }, { 15, 2 }, { 28, 3 } }, function() return 1.3 end) part(c, br, P.WOOD, 1, 1)
  ln(c, { { 15, 4 }, { 15, 8 } }, P.SAND.s)
  local nest = lathe(15, 7, { 3, 5, 7, 8, 9, 9, 9, 9, 8, 8, 7, 6, 4, 3 }) part(c, nest, P.SAND, 3, 3, { lift = -1 })
  for y = 9, 19 do for x = 7, 23 do if nest:has(x, y) and (x + y * 2) % 4 == 0 then c:put(x, y, P.SAND.s) elseif nest:has(x, y) and (x + y * 2) % 4 == 2 and y % 2 == 0 then c:put(x, y, P.SAND.L) end end end
  fillm(c, E(15, 17, 3.2, 2.8), P.BROWN.D)
  part(c, E(15, 17, 2, 1.8), P.GOLD, 1, 1) px(c, { { 14, 16, '#' }, { 16, 16, '#' }, { 15, 18, P.ORANGE.m } })
  px(c, { { 11, 11, P.SAND.g }, { 10, 12, P.SAND.g }, { 12, 10, P.SAND.L }, { 22, 14, P.LIME.m } })
  ln(c, { { 21, 18 }, { 24, 22 } }, P.SAND.m) ln(c, { { 22, 17 }, { 26, 21 } }, P.SAND.l)  -- loose straw
  F(c, "weaver_bird_nest") end
