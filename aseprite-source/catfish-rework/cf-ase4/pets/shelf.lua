local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local P = dofile(DIR .. "/pp.lua")
local L, E, RC, poly, part, px, ln, lathe, sep, fillm, rrect = P.L, P.E, P.RC, P.poly, P.part, P.px, P.ln, P.lathe, P.sep, P.fillm, P.rrect
local N = function() return P.new(20, 24) end
local F = function(c, n) P.finish(c, "cf-pet-" .. n, 20, 24) end
local floor = math.floor

-- amphora
do local c = N()
  local body = lathe(10, 3, { 3, 2, 2, 2, 2, 3, 5, 6, 7, 7, 7, 7, 6, 6, 5, 4, 3, 3, 4, 4 })
  local h1 = L.line({ { 7, 5 }, { 4, 6 }, { 3, 8 }, { 4, 10 }, { 6, 11 } }):grow(0)
  local h2 = L.line({ { 12, 5 }, { 15, 6 }, { 16, 8 }, { 15, 10 }, { 13, 11 } })
  part(c, h1, P.CLAY, 1, 1) part(c, h2, P.CLAY, 1, 1)
  part(c, body, P.CLAY, 3, 3)
  ln(c, { { 7, 3 }, { 12, 3 } }, P.CLAY.l, body) -- lip
  P.ln(c, { { 5, 13 }, { 14, 13 } }, P.AQUA.m) P.ln(c, { { 4, 14 }, { 15, 14 } }, P.AQUA.m) ln(c, { { 5, 15 }, { 14, 15 } }, P.AQUA.b)
  for x = 5, 14, 3 do c:put(x, 14, P.CLAY.g) end
  ln(c, { { 6, 17 }, { 13, 17 } }, P.CLAY.s, body)
  px(c, { { 8, 10, P.CLAY.g }, { 7, 11, P.CLAY.L }, { 7, 9, P.CLAY.L }, { 9, 2, '#a87850' }, { 10, 2, '#7a5030' } })  -- kibble peeking
  F(c, "amphora") end
-- beaded rack
do local c = N()
  local top = RC(2, 2, 17, 3) part(c, top, P.WOOD, 1, 1)
  part(c, RC(2, 4, 3, 21), P.WOOD, 1, 1) part(c, RC(16, 4, 17, 21), P.WOOD, 1, 1)
  part(c, RC(2, 20, 17, 21), P.WOOD, 1, 1)
  local cols = { P.RED.m, P.GOLD.m, P.TEAL.m, P.PINK.m, P.BLUE.m }
  for i, x in ipairs({ 5, 8, 11, 14 }) do
    local len = ({ 12, 9, 13, 7 })[i]
    for k = 0, len do local y = 4 + k c:put(x, y, (k % 2 == 0) and cols[(i + k) % 5 + 1] or P.WOOD.D) c:put(x + 1, y, (k % 2 == 0) and P.IVORY.L or P.WOOD.D) end
  end
  px(c, { { 5, 5, P.IVORY.g }, { 11, 5, P.IVORY.g } })
  px(c, { { 14, 12, P.GOLD.g }, { 15, 12, P.GOLD.g }, { 14, 13, P.GOLD.m }, { 15, 13, P.GOLD.s } }) -- a bigger tassel bead
  F(c, "beaded_rack") end
-- bromeliad
do local c = N()
  local pot = lathe(10, 15, { 6, 6, 5, 5, 5, 4, 4 }) pot = pot:add(RC(4, 14, 15, 14))
  local leaves = { { { 10, 14 }, { 6, 7 }, { 2, 4 } }, { { 10, 14 }, { 4, 9 }, { 1, 11 } }, { { 10, 14 }, { 15, 7 }, { 18, 4 } }, { { 10, 14 }, { 16, 9 }, { 19, 11 } }, { { 10, 14 }, { 8, 6 }, { 7, 1 } }, { { 10, 14 }, { 12, 6 }, { 13, 1 } } }
  for i, l in ipairs(leaves) do part(c, P.leaf(l, 2.2), P.LIME, 1, 1, { lift = (i % 2 == 0) and -1 or 0 }) end
  px(c, { { 9, 12, P.CORAL.m }, { 10, 12, P.CORAL.b }, { 9, 11, P.CORAL.l }, { 10, 11, P.CORAL.m }, { 9, 10, P.CORAL.g }, { 10, 10, P.CORAL.l } })
  part(c, pot, P.TERRA, 2, 2) P.ln(c, { { 4, 17 }, { 15, 17 } }, P.TEAL.m) P.ln(c, { { 5, 18 }, { 14, 18 } }, P.TEAL.b)
  for x = 5, 14, 3 do c:put(x, 17, P.IVORY.L) end
  -- frog peeking at right leaf base
  part(c, E(14, 11, 2.4, 1.8), P.LIME, 1, 1, { lift = 2 }) px(c, { { 13, 9, '#fff4d6' }, { 15, 9, '#fff4d6' }, { 13, 10, '#' }, { 15, 10, '#' } })
  c:put(13, 8, P.LIME.m) c:put(15, 8, P.LIME.m)
  F(c, "bromeliad") end
-- conch shell
do local c = N()
  local m = poly({ { 2, 7 }, { 8, 10 }, { 14, 11 }, { 17, 16 }, { 15, 21 }, { 8, 21 }, { 4, 17 }, { 5, 12 } })
  m:add(poly({ { 3, 5 }, { 6, 8 }, { 5, 11 } }))
  part(c, m, P.SAND, 3, 3, { lift = 1 })
  P.ln(c, { { 6, 11 }, { 11, 12 }, { 14, 15 } }, P.CORAL.l, m) P.ln(c, { { 6, 14 }, { 10, 16 }, { 12, 19 } }, P.CORAL.m, m) P.ln(c, { { 5, 17 }, { 8, 19 } }, P.CORAL.b, m)
  for _, p in ipairs({ { 10, 10 }, { 13, 11 }, { 16, 13 } }) do c:put(p[1], p[2], P.CORAL.s) end
  local mouth = E(14, 18, 2.2, 3) part(c, mouth, P.PINK, 1, 1) px(c, { { 13, 17, P.PINK.g }, { 14, 20, P.PINK.D } })
  px(c, { { 6, 9, P.SAND.g }, { 7, 10, P.SAND.g } })
  px(c, { { 17, 7, P.AQUA.L }, { 18, 6, P.AQUA.m }, { 18, 8, P.AQUA.m } }) -- a hushed sea-ripple
  F(c, "conch_shell") end
-- floating lantern (lotus boat)
do local c = N()
  local bowl = lathe(10, 17, { 7, 7, 6, 5, 3 }) part(c, bowl, P.TEAL, 2, 2) P.ln(c, { { 4, 17 }, { 15, 17 } }, P.TEAL.l)
  px(c, { { 8, 19, P.TEAL.l }, { 11, 20, P.TEAL.s } })
  for _, pp in ipairs({ { { 3, 17 }, { 1, 13 }, { 6, 14 } }, { { 16, 17 }, { 19, 13 }, { 13, 14 } }, { { 5, 17 }, { 4, 11 }, { 8, 13 } }, { { 14, 17 }, { 15, 11 }, { 11, 13 } } }) do part(c, poly(pp), P.PINK, 1, 1, { lift = 0 }) end
  part(c, RC(9, 8, 10, 16), P.IVORY, 1, 1)
  local fl = poly({ { 9.5, 2 }, { 11.5, 6 }, { 9.5, 7.8 }, { 7.5, 6 } }) part(c, fl, P.GOLD, 1, 1, { lift = 1 }) px(c, { { 9, 6, P.GOLD.g }, { 9, 5, P.GOLD.g } })
  px(c, { { 12, 14, P.PINK.g }, { 5, 13, P.PINK.g } })
  F(c, "floating_lantern") end
-- maneki-neko
do local c = N()
  part(c, L.line({ { 4, 12 }, { 3, 8 }, { 3, 5 } }):grow(0):add(RC(3, 4, 4, 8)), P.IVORY, 1, 1)
  local body = rrect(4, 11, 15, 22, 3) part(c, body, P.IVORY, 2, 2)
  local head = E(9.5, 8, 6, 5) part(c, head, P.IVORY, 2, 2)
  part(c, poly({ { 4, 6 }, { 4, 1 }, { 8, 4 } }), P.IVORY, 1, 1) part(c, poly({ { 15, 6 }, { 15, 1 }, { 11, 4 } }), P.IVORY, 1, 1)
  px(c, { { 5, 3, P.PINK.m }, { 14, 3, P.PINK.m }, { 5, 4, P.PINK.m }, { 14, 4, P.PINK.m } })
  px(c, { { 7, 7, '#' }, { 12, 7, '#' }, { 9, 9, P.PINK.m }, { 10, 9, P.PINK.m }, { 6, 9, P.PINK.l }, { 13, 9, P.PINK.l } })
  P.ln(c, { { 3, 8 }, { 4, 8 } }, P.PINK.m)
  px(c, { { 3, 5, '#' }, { 4, 5, '#' } })
  part(c, RC(6, 12, 13, 13), P.RED, 1, 1)
  part(c, E(9.5, 15, 1.8, 1.8), P.GOLD, 1, 1) px(c, { { 9, 14, P.GOLD.g }, { 9, 16, P.GOLD.D }, { 10, 16, P.GOLD.D } })
  local coin = E(11, 19, 3, 2.6) part(c, coin, P.GOLD, 1, 1) px(c, { { 11, 19, P.GOLD.D }, { 10, 18, P.GOLD.g } })
  px(c, { { 6, 5, P.IVORY.g }, { 7, 4, P.IVORY.g } })
  F(c, "maneki_neko") end
-- matryoshka mice
do local c = N()
  local d = lathe(8, 4, { 3, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 5, 5, 5, 4, 4 })  -- big
  part(c, E(4.5, 4.2, 2, 2), P.GREY, 1, 1) part(c, E(11.5, 4.2, 2, 2), P.GREY, 1, 1) px(c, { { 4, 4, P.PINK.m }, { 12, 4, P.PINK.m } })
  part(c, d, P.RED, 2, 2)
  local face = E(8, 8, 3, 2.4) part(c, face, P.IVORY, 1, 1)
  px(c, { { 6, 8, '#' }, { 9, 8, '#' }, { 8, 9, P.PINK.P }, { 7, 8, P.IVORY.D } })
  part(c, E(8, 15, 2.6, 2.6), P.GOLD, 1, 1) c:put(8, 15, P.RED.D) px(c, { { 7, 14, P.GOLD.g } })
  ln(c, { { 3, 12 }, { 13, 12 } }, P.GOLD.m, d)
  px(c, { { 6, 7, P.RED.g } })
  local d2 = lathe(16, 14, { 2, 3, 3, 3, 3, 3, 3, 3, 2 }) -- small blue one
  part(c, d2, P.NAVY, 1, 1) part(c, E(16, 12, 2, 2), P.IVORY, 1, 1) px(c, { { 15, 12, '#' }, { 17, 12, '#' }, { 14, 10, P.GREY.m }, { 17, 10, P.GREY.m } })
  F(c, "matryoshka_mice") end
-- sand timer
do local c = N()
  part(c, RC(3, 2, 16, 4), P.WOOD, 1, 1) part(c, RC(3, 19, 16, 21), P.WOOD, 1, 1)
  part(c, RC(3, 5, 4, 18), P.WOOD, 1, 1) part(c, RC(15, 5, 16, 18), P.WOOD, 1, 1)
  local g = poly({ { 6, 5 }, { 14, 5 }, { 14, 7 }, { 10.5, 11.5 }, { 14, 16 }, { 14, 18 }, { 6, 18 }, { 6, 16 }, { 9.5, 11.5 }, { 6, 7 } })
  part(c, g, P.AQUA, 1, 1, { lift = 3 })
  fillm(c, poly({ { 8, 8 }, { 12, 8 }, { 10.5, 11 }, { 9.5, 11 } }), P.GOLD.m) fillm(c, poly({ { 7, 17 }, { 13, 17 }, { 11, 14 }, { 9, 14 } }), P.GOLD.m)
  P.ln(c, { { 10, 12 }, { 10, 14 } }, P.GOLD.l) px(c, { { 11, 16, P.GOLD.D }, { 9, 17, P.GOLD.b }, { 8, 8, P.GOLD.l } })
  px(c, { { 6, 6, P.AQUA.g }, { 6, 7, P.AQUA.g }, { 7, 17, P.AQUA.g } })
  px(c, { { 13, 3, P.WOOD.L }, { 5, 20, P.WOOD.l }, { 16, 12, P.GOLD.m }, { 16, 13, P.GOLD.s } }) -- a tied-on brass bead
  F(c, "sand_timer") end
-- singing bowl
do local c = N()
  local cu = E(10, 20, 8, 2.8) part(c, cu, P.DEEP, 1, 1)
  px(c, { { 6, 20, P.GOLD.m }, { 10, 21, P.GOLD.m }, { 14, 20, P.GOLD.m } })
  local bowl = lathe(10, 11, { 8, 8, 7, 7, 6, 6, 5, 4, 3 }) part(c, bowl, P.BRONZE, 3, 3, { lift = 1 })
  P.ln(c, { { 3, 11 }, { 16, 11 } }, P.GOLD.l) P.ln(c, { { 4, 14 }, { 15, 14 } }, P.GOLD.m, bowl)
  px(c, { { 5, 12, P.BRONZE.g }, { 6, 12, P.BRONZE.L }, { 5, 13, P.BRONZE.L } })
  for x = 5, 14, 2 do c:put(x, 15, P.BRONZE.D) end
  part(c, L.line({ { 15, 2 }, { 12, 7 } }):grow(0), P.WOOD, 1, 1) px(c, { { 15, 2, P.GOLD.g }, { 16, 1, P.GOLD.m }, { 16, 2, P.GOLD.s } })
  px(c, { { 3, 5, P.AQUA.m }, { 2, 6, P.AQUA.m }, { 2, 7, P.AQUA.m }, { 3, 8, P.AQUA.m } })
  F(c, "singing_bowl") end
-- tide-pool jar
do local c = N()
  local lid = rrect(5, 2, 14, 5, 1) part(c, lid, P.ORANGE, 1, 1) P.ln(c, { { 5, 3 }, { 14, 3 } }, P.ORANGE.L)
  local jar = rrect(3, 6, 16, 22, 3) part(c, jar, P.AQUA, 1, 1, { lift = 2 })
  fillm(c, RC(4, 9, 15, 21):clip(jar), P.AQUA.m); fillm(c, RC(4, 17, 15, 21):clip(jar), P.SAND.m)
  P.ln(c, { { 4, 17 }, { 15, 17 } }, P.SAND.l)
  P.ln(c, { { 4, 9 }, { 15, 9 } }, P.AQUA.L)
  part(c, poly({ { 8, 19 }, { 9, 16 }, { 10.5, 19 }, { 13, 18 }, { 11, 20.5 }, { 12, 22 }, { 9, 21 }, { 6, 22 }, { 7, 20 } }), P.ORANGE, 1, 1)
  px(c, { { 9, 18, P.ORANGE.g } })
  part(c, E(5.5, 20, 1.6, 1.4), P.PINK, 1, 1) px(c, { { 13, 12, P.AQUA.g }, { 14, 14, P.AQUA.g } })
  px(c, { { 4, 7, P.AQUA.g }, { 4, 8, P.AQUA.g }, { 4, 11, P.AQUA.g }, { 4, 12, P.AQUA.g } })
  F(c, "tide_pool_jar") end
