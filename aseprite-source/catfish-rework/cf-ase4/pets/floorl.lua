local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local P = dofile(DIR .. "/pp.lua")
local L, E, RC, poly, part, px, ln, lathe, sep, fillm, rrect = P.L, P.E, P.RC, P.poly, P.part, P.px, P.ln, P.lathe, P.sep, P.fillm, P.rrect
local N = function() return P.new(38, 28) end
local F = function(c, n) P.finish(c, "cf-pet-" .. n, 38, 28) end
local cos, sin, pi = math.cos, math.sin, math.pi
-- capybara plush
do local c = N()
  part(c, E(20, 17, 15, 7.6), P.BROWN, 3, 3, { lift = 0 })
  part(c, E(8, 14, 6, 5.4), P.BROWN, 2, 2, { lift = 1 })
  part(c, E(4, 16, 3.2, 2.8), P.BROWN, 1, 1, { lift = -1 }) px(c, { { 2, 15, '#' }, { 3, 15, P.BROWN.D } })
  part(c, E(10, 9, 1.8, 1.6), P.BROWN, 1, 1) part(c, E(14, 9.5, 1.6, 1.4), P.BROWN, 1, 1)
  for _, e in ipairs({ { 7, 12 } }) do ln(c, { { 6, 13 }, { 9, 13 } }, '#') end
  part(c, poly({ { 18, 12 }, { 35, 13 }, { 34, 22 }, { 22, 24 } }), P.TEAL, 1, 1, { lift = -1 })
  for x = 20, 33, 3 do ln(c, { { x, 12 }, { x - 1, 23 } }, (x % 2 == 0) and P.GOLD.m or P.RED.m) end
  part(c, E(10, 6, 2.6, 2.2), P.ORANGE, 1, 1) c:put(10, 4, P.LIME.m) c:put(11, 4, P.LIME.l) px(c, { { 9, 5, P.ORANGE.g } }) -- a yuzu on its head
  px(c, { { 10, 12, P.BROWN.g }, { 12, 11, P.BROWN.L }, { 14, 13, P.BROWN.l } })
  px(c, { { 9, 26, P.BROWN.D }, { 10, 26, P.BROWN.D }, { 30, 25, P.BROWN.D } })
  F(c, "capybara_plush") end
-- felt boot bed
do local c = N()
  local shaft = rrect(3, 4, 15, 22, 2) local foot = poly({ { 3, 16 }, { 36, 16 }, { 36, 24 }, { 33, 25 }, { 5, 25 }, { 3, 24 } })
  local boot = shaft:copy():add(foot) part(c, boot, P.GREY, 3, 3)
  part(c, rrect(3, 4, 15, 8, 1), P.RED, 1, 1) for x = 4, 14, 2 do c:put(x, 6, P.CREAM.m) end
  local bed = E(25, 16, 10, 2.6) fillm(c, bed, P.PLUM.b) fillm(c, E(25, 16, 9, 1.8), P.PLUM.m) ln(c, { { 18, 15 }, { 30, 15 } }, P.PLUM.L)
  ln(c, { { 16, 17 }, { 35, 17 } }, P.GREY.L, boot)
  for _, p in ipairs({ { 8, 13 }, { 8, 12 } }) do end
  part(c, E(8, 14, 2.4, 2.4), P.PINK, 1, 1) c:put(8, 14, P.GOLD.m) px(c, { { 7, 13, P.PINK.g } })
  ln(c, { { 8, 17 }, { 8, 19 } }, P.LIME.m)
  ln(c, { { 6, 21 }, { 13, 21 } }, P.GREY.s, boot) ln(c, { { 9, 24 }, { 33, 24 } }, P.GREY.D, boot)
  px(c, { { 5, 10, P.GREY.g }, { 5, 11, P.GREY.L }, { 18, 17, P.GREY.g } })
  px(c, { { 20, 13, P.CREAM.L }, { 21, 12, P.CREAM.m } }) -- a snoring Z
  F(c, "felt_boot_bed") end
-- grass tuft (basket)
do local c = N()
  local basket = lathe(19, 17, { 14, 14, 13, 13, 12, 11, 10, 9 }) basket = basket:add(RC(4, 16, 33, 16))
  part(c, basket, P.SAND, 2, 2)
  for y = 17, 24 do for x = 6, 32 do if basket:has(x, y) and ((x + (y % 2) * 2) % 4 == 0) then c:put(x, y, P.SAND.s) elseif basket:has(x, y) and ((x + (y % 2) * 2) % 4 == 2) then c:put(x, y, P.SAND.L) end end end
  ln(c, { { 5, 18 }, { 32, 18 } }, P.RED.m, basket) ln(c, { { 6, 21 }, { 31, 21 } }, P.RED.s, basket)
  for i = 0, 13 do local x = 7 + i * 2 local h = 8 + ((i * 7) % 7) local lean = ((i % 5) - 2)
    part(c, L.tube({ { x, 16 }, { x + lean * 0.7, 16 - h * 0.5 }, { x + lean * 1.6, 16 - h } }, function(t) return 1.3 - t * 0.9 end), P.LIME, 1, 1, { lift = (i % 3) - 1 })
  end
  px(c, { { 7, 19, P.SAND.g }, { 6, 20, P.SAND.L } })
  part(c, E(30, 8, 1.4, 1.4), P.PINK, 1, 1) -- tiny flower in the grass
  F(c, "grass_tuft") end
-- hammock net
do local c = N()
  part(c, RC(2, 5, 4, 25), P.WOOD, 1, 1) part(c, RC(33, 5, 35, 25), P.WOOD, 1, 1) part(c, RC(1, 24, 6, 26), P.WOOD, 1, 1) part(c, RC(31, 24, 36, 26), P.WOOD, 1, 1)
  local top = {}
  for x = 5, 32 do local t = (x - 5) / 27 local y = 8 + 12 * math.sin(t * pi) top[#top + 1] = { x, math.floor(y + 0.5) } end
  local net = L.mask() for _, p in ipairs(top) do for y = p[2], p[2] + 3 do net:set(p[1], y) end end
  part(c, net, P.SAND, 1, 1)
  for _, p in ipairs(top) do if p[1] % 3 == 0 then for k = 0, 3 do c:put(p[1] + (k % 2), p[2] + k, P.BROWN.m) end end end
  for k = 0, 3 do for _, p in ipairs(top) do if (p[1] + k) % 4 == 0 then c:put(p[1], p[2] + k, P.SAND.L) end end end
  for _, p in ipairs(top) do if p[1] % 6 == 2 then part(c, E(p[1], p[2] + 5, 1.3, 1.3), ((p[1] // 6) % 2 == 0) and P.RED or P.TEAL, 1, 1) end end
  px(c, { { 3, 5, P.WOOD.g }, { 3, 6, P.WOOD.L }, { 5, 8, P.GOLD.m }, { 32, 8, P.GOLD.m } })
  part(c, poly({ { 14, 16 }, { 17, 13 }, { 22, 14 }, { 24, 16 }, { 19, 18 } }), P.IVORY, 1, 1) px(c, { { 16, 14, P.IVORY.g }, { 17, 14, P.IVORY.g } }) -- a pillow in the sag
  F(c, "hammock_net") end
-- kilim cushion
do local c = N()
  local cu = rrect(3, 7, 34, 23, 3) part(c, cu, P.RED, 3, 3)
  fillm(c, rrect(6, 10, 31, 20, 1), P.MAROON.m) for x = 6, 31 do c:put(x, 10, P.GOLD.m) c:put(x, 20, P.GOLD.b) end
  for i = 0, 2 do local cx = 12 + i * 7
    fillm(c, poly({ { cx, 11 }, { cx + 3.5, 15 }, { cx, 19 }, { cx - 3.5, 15 } }), (i == 1) and P.GOLD.m or P.TEAL.m)
    fillm(c, poly({ { cx, 13 }, { cx + 1.5, 15 }, { cx, 17 }, { cx - 1.5, 15 } }), P.RED.m) c:put(cx - 1, 13, P.CREAM.g) end
  for _, t in ipairs({ { 2, 6 }, { 35, 6 }, { 2, 24 }, { 35, 24 } }) do part(c, E(t[1], t[2], 1.8, 1.8), P.GOLD, 1, 1) end
  px(c, { { 5, 8, P.RED.g }, { 6, 8, P.RED.L }, { 4, 9, P.RED.L } })
  for x = 8, 28, 5 do c:put(x, 25, P.GOLD.s) end
  F(c, "kilim_cushion") end
-- kiwi plush
do local c = N()
  part(c, E(22, 15, 11, 9), P.BROWN, 3, 3)
  for _, p in ipairs({ { 18, 10 }, { 22, 9 }, { 26, 11 }, { 16, 14 }, { 21, 14 }, { 27, 15 }, { 18, 19 }, { 24, 19 } }) do ln(c, { { p[1], p[2] }, { p[1] + 1, p[2] + 1 } }, P.BROWN.D) c:put(p[1] - 1, p[2], P.BROWN.l) end
  part(c, E(11, 13, 4.4, 4), P.BROWN, 2, 2, { lift = 1 })
  local beak = L.tube({ { 8, 14 }, { 4, 17 }, { 2, 22 } }, function() return 1.2 end) part(c, beak, P.SAND, 1, 1, { lift = 1 })
  px(c, { { 10, 12, '#' }, { 11, 12, '#fff4d6' }, { 12, 12, P.BROWN.D } }) c:put(10, 12, '#fff4d6') c:put(11, 12, '#')
  part(c, E(12, 15, 1.4, 1), P.PINK, 1, 1)
  part(c, RC(18, 23, 20, 26), P.SAND, 1, 1) part(c, RC(25, 23, 27, 26), P.SAND, 1, 1) px(c, { { 17, 26, P.SAND.m }, { 21, 26, P.SAND.m }, { 24, 26, P.SAND.m }, { 28, 26, P.SAND.m } })
  px(c, { { 20, 8, P.BROWN.g }, { 18, 9, P.BROWN.L } })
  F(c, "kiwi_plush") end
-- paddy-hat bed
do local c = N()
  local hat = poly({ { 19, 3 }, { 36, 23 }, { 36, 25 }, { 2, 25 }, { 2, 23 } }) part(c, hat, P.SAND, 3, 3, { lift = 0 })
  for i = 1, 9 do local t = i / 10 ln(c, { { 19 - 17 * t * 1.0, 3 + 22 * t * 0.9 }, { 19 + 17 * t, 3 + 22 * t * 0.9 } }, (i % 2 == 0) and P.SAND.s or P.SAND.L, hat) end
  for i = -5, 5 do ln(c, { { 19, 3 }, { 19 + i * 3.4, 24 } }, P.SAND.b, hat) end
  local door = lathe(19, 17, { 5, 6, 7, 7, 7, 7, 7, 7 }) door = door:filter(function(x, y) return y >= 17 end) fillm(c, door, P.BROWN.D) fillm(c, door:filter(function(x, y) return y <= 18 end), P.BROWN.s)
  part(c, E(19, 23, 8, 1.6), P.RED, 1, 1) ln(c, { { 12, 22 }, { 26, 22 } }, P.RED.l)
  ln(c, { { 5, 25 }, { 33, 25 } }, P.SAND.D, hat)
  part(c, poly({ { 16, 12 }, { 19, 10 }, { 22, 12 }, { 22, 14 }, { 16, 14 } }), P.TEAL, 1, 1)
  px(c, { { 15, 11, P.SAND.g }, { 14, 13, P.SAND.L }, { 12, 16, P.SAND.L }, { 19, 4, P.SAND.g } })
  F(c, "paddy_hat_bed") end
-- talking drum
do local c = N()
  local body = L.mask()
  for x = 7, 30 do local t = (x - 7) / 23 local r = 3.4 + 6.4 * (math.abs(t - 0.5) * 2) ^ 1.3 for y = math.floor(14 - r), math.floor(14 + r) do body:set(x, y) end end
  part(c, body, P.WOOD, 3, 3)
  part(c, E(7, 14, 3.6, 9.4), P.CREAM, 2, 2, { lift = -1 }) part(c, E(31, 14, 3.2, 7.4), P.CREAM, 2, 2, { lift = -1 })
  fillm(c, E(6.5, 14, 1.6, 6), P.CREAM.g)
  for x = 9, 29, 4 do ln(c, { { x, 6 + math.abs(x - 19) // 3 }, { x + 2, 22 - math.abs(x - 19) // 3 } }, P.RED.m, body) ln(c, { { x + 2, 6 + math.abs(x - 19) // 3 }, { x, 22 - math.abs(x - 19) // 3 } }, P.GOLD.m, body) end
  fillm(c, RC(15, 12, 22, 15), P.TEAL.m) for x = 15, 22, 2 do c:put(x, 13, P.GOLD.m) end ln(c, { { 15, 12 }, { 22, 12 } }, P.TEAL.L)
  part(c, L.line({ { 24, 24 }, { 30, 20 } }), P.WOOD, 1, 1) part(c, E(31, 19.5, 1.8, 1.8), P.RED, 1, 1)  -- the beater
  px(c, { { 10, 8, P.WOOD.g }, { 12, 7, P.WOOD.L } })
  F(c, "talking_drum") end
-- tiger-stripe rug
do local c = N()
  local rg = rrect(2, 6, 35, 23, 3) part(c, rg, P.ORANGE, 3, 3, { lift = 0 })
  for x = 5, 32, 5 do local w = 2 + (x % 3) for y = 7, 22 do for dx = 0, w - 1 do local xx = x + dx + ((y > 14) and 1 or 0) if rg:has(xx, y) and (y - 7) % 16 ~= 15 then c:put(xx, y, (y < 9 or y > 20) and P.ORANGE.s or '#3a2230') end end end end
  fillm(c, E(19, 14, 3.4, 2.2), P.CREAM.l) fillm(c, E(19, 14, 2.2, 1.4), P.CREAM.g)
  px(c, { { 18, 13, '#' }, { 20, 13, '#' }, { 19, 15, P.PINK.P }, { 12, 9, P.ORANGE.g }, { 13, 8, P.ORANGE.L }, { 6, 8, P.ORANGE.L } })
  for x = 4, 33, 2 do c:put(x, 24, P.CREAM.m) c:put(x, 25, P.CREAM.b) end
  F(c, "tiger_stripe_rug") end
