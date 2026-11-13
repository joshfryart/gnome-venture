local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local P = dofile(DIR .. "/pp.lua")
local L, E, RC, poly, part, px, ln, lathe, sep, fillm, rrect = P.L, P.E, P.RC, P.poly, P.part, P.px, P.ln, P.lathe, P.sep, P.fillm, P.rrect
local N = function() return P.new(16, 16) end
local F = function(c, n) P.finish(c, "cf-pet-" .. n, 16, 16) end
-- bell
do local c = N()
  part(c, E(8, 2.6, 1.6, 1.4), P.RED, 1, 1)
  local b = lathe(8, 4, { 3, 4, 4, 5, 5, 6, 6, 6, 5 }) part(c, b, P.GOLD, 2, 2)
  ln(c, { { 3, 13 }, { 12, 13 } }, P.GOLD.D, b) P.ln(c, { { 3, 12 }, { 12, 12 } }, P.GOLD.l)
  px(c, { { 6, 6, P.GOLD.g }, { 6, 7, P.GOLD.L }, { 5, 9, P.GOLD.L } })
  part(c, E(8, 14, 1.5, 1), P.GOLD, 1, 1) px(c, { { 11, 6, P.RED.m }, { 12, 5, P.RED.m } })
  F(c, "bell_lure") end
-- coffee-bean rattle
do local c = N()
  ln(c, { { 8, 1 }, { 8, 3 } }, P.SISAL.m)
  local b = E(8, 9, 4.6, 5.8) part(c, b, P.BROWN, 2, 2)
  ln(c, { { 9, 4 }, { 7, 7 }, { 9, 10 }, { 7, 13 } }, P.BROWN.D, b)
  px(c, { { 6, 6, P.BROWN.g }, { 5, 8, P.BROWN.L }, { 12, 3, P.BROWN.m }, { 13, 3, P.BROWN.l }, { 14, 4, P.BROWN.m } })
  F(c, "coffee_bean_rattle") end
-- flying fish
do local c = N()
  part(c, poly({ { 11, 8 }, { 14, 4 }, { 14, 12 } }), P.BLUE, 1, 1, { lift = -1 })
  part(c, poly({ { 5, 6 }, { 9, 1 }, { 11, 3 }, { 9, 7 } }), P.AQUA, 1, 1, { lift = 1 }) ln(c, { { 9, 6 }, { 9, 2 } }, P.AQUA.b)
  part(c, E(7, 9, 5.2, 3), P.BLUE, 2, 2) fillm(c, RC(3, 10, 10, 11):clip(E(7, 9, 5.2, 3)), P.SILVER.l)
  px(c, { { 3, 8, '#' }, { 4, 7, P.BLUE.g }, { 6, 7, P.BLUE.L } }) c:put(3, 8, '#fff4d6') c:put(4, 8, '#')
  px(c, { { 2, 13, P.AQUA.m }, { 6, 14, P.AQUA.l }, { 10, 14, P.AQUA.m } })
  F(c, "flying_fish_charm") end
-- kite tail
do local c = N()
  part(c, poly({ { 7, 1 }, { 11, 6 }, { 7, 11 }, { 3, 6 } }), P.VIOLET, 1, 1, { lift = 0 })
  fillm(c, poly({ { 7, 1 }, { 11, 6 }, { 7, 6 } }), P.PINK.m) ln(c, { { 7, 1 }, { 7, 11 } }, P.VIOLET.D) ln(c, { { 3, 6 }, { 11, 6 } }, P.VIOLET.D)
  px(c, { { 6, 3, P.PINK.g }, { 5, 5, P.VIOLET.L } })
  ln(c, { { 7, 12 }, { 9, 13 }, { 7, 14 } }, P.PINK.m) part(c, poly({ { 5, 13 }, { 7, 13 }, { 6, 15 } }), P.GOLD, 1, 1) part(c, poly({ { 9, 13 }, { 11, 13 }, { 10, 15 } }), P.TEAL, 1, 1)
  F(c, "kite_tail_lure") end
-- koi kite
do local c = N()
  part(c, poly({ { 11, 7 }, { 14, 3 }, { 14, 12 } }), P.ORANGE, 1, 1, { lift = 1 })
  part(c, E(7, 7.5, 5.4, 3.4), P.IVORY, 2, 2) fillm(c, E(6, 6, 2.2, 1.6), P.ORANGE.m) fillm(c, E(10, 8, 1.6, 1.4), P.RED.m)
  px(c, { { 3, 6, '#' }, { 2, 7, P.IVORY.l }, { 4, 5, P.IVORY.g } }) c:put(3, 6, '#')
  part(c, poly({ { 5, 10 }, { 8, 11 }, { 6, 14 } }), P.ORANGE, 1, 1)
  px(c, { { 7, 3, P.ORANGE.l }, { 8, 3, P.ORANGE.m }, { 9, 4, P.ORANGE.s } })
  F(c, "koi_kite_lure") end
-- lemon
do local c = N()
  ln(c, { { 8, 0 }, { 8, 3 } }, P.SISAL.m)
  local lm = poly({ { 1, 9 }, { 3, 6 }, { 8, 4 }, { 13, 6 }, { 15, 9 }, { 13, 12 }, { 8, 14 }, { 3, 12 } }) part(c, lm, P.LEMON, 2, 2)
  px(c, { { 1, 8, P.LEMON.m }, { 15, 10, P.LEMON.s }, { 5, 7, P.LEMON.g }, { 4, 8, P.LEMON.L }, { 10, 11, P.LEMON.b }, { 11, 9, P.LEMON.D } })
  part(c, P.leaf({ { 8, 4 }, { 11, 2 }, { 14, 3 } }, 1.6), P.LIME, 1, 1)
  F(c, "lemon_on_a_string") end
-- painted egg
do local c = N()
  part(c, lathe(8, 1, { 2, 3, 4, 5, 5, 5, 5, 5, 4, 4, 3 }), P.IVORY, 2, 2, { lift = -1 })
  local egg = lathe(8, 1, { 2, 3, 4, 5, 5, 5, 5, 5, 4, 4, 3 })
  for y = 4, 5 do for x = 3, 12 do if egg:has(x, y) then c:put(x, y, P.RED.m) end end end
  for x = 3, 12, 2 do if egg:has(x, 7) then c:put(x, 7, P.TEAL.m) end if egg:has(x + 1, 8) then c:put(x + 1, 8, P.GOLD.m) end end
  ln(c, { { 3, 6 }, { 12, 6 } }, P.GOLD.m, egg)
  px(c, { { 5, 3, P.IVORY.g }, { 4, 4, P.IVORY.g } })
  part(c, poly({ { 7, 12 }, { 9, 12 }, { 10, 15 }, { 6, 15 } }), P.RED, 1, 1) px(c, { { 7, 13, P.RED.L } })
  F(c, "painted_egg_charm") end
-- seashell
do local c = N()
  local sh = poly({ { 8, 13 }, { 1, 8 }, { 2, 4 }, { 5, 2 }, { 8, 1.5 }, { 11, 2 }, { 14, 4 }, { 15, 8 } }) part(c, sh, P.PINK, 2, 2, { lift = 1 })
  for _, e in ipairs({ { 2, 7 }, { 4, 4 }, { 8, 3 }, { 12, 4 }, { 14, 7 } }) do ln(c, { { 8, 12 }, e }, P.PINK.s, sh) end
  part(c, RC(6, 13, 9, 14), P.SAND, 1, 1) px(c, { { 6, 3, P.PINK.g }, { 4, 5, P.PINK.g }, { 3, 6, P.PINK.L } })
  F(c, "seashell_lure") end
-- toucan feather
do local c = N()
  local f = L.tube({ { 13, 1 }, { 9, 6 }, { 5, 11 }, { 3, 14 } }, function(t) return 2.8 * math.sin(math.min(1, t * 1.15 + .15) * math.pi) ^ .6 + .5 end)
  part(c, f, P.ORANGE, 1, 1, { lift = 0 })
  fillm(c, f:filter(function(x, y) return x + y < 14 and x + y > 9 end), P.GOLD.m)
  fillm(c, f:filter(function(x, y) return x + y <= 9 and x + y > 6 end), P.NAVY.b)
  ln(c, { { 12, 2 }, { 8, 7 }, { 4, 13 } }, P.ORANGE.D, f)
  px(c, { { 11, 3, P.GOLD.g }, { 12, 3, P.ORANGE.g } })
  F(c, "toucan_feather_lure") end
