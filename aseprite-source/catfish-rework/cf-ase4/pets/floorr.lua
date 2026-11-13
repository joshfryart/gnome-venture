local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local P = dofile(DIR .. "/pp.lua")
local L, E, RC, poly, part, px, ln, lathe, sep, fillm, rrect = P.L, P.E, P.RC, P.poly, P.part, P.px, P.ln, P.lathe, P.sep, P.fillm, P.rrect
local N = function() return P.new(36, 28) end
local F = function(c, n) P.finish(c, "cf-pet-" .. n, 36, 28) end
-- calabash bowl
do local c = N()
  local bowl = lathe(18, 9, { 14, 15, 15, 15, 15, 14, 14, 13, 12, 10, 8, 6 }) bowl = bowl:filter(function(x, y) return y >= 12 or (x >= 6 and x <= 29) end)
  part(c, bowl, P.ORANGE, 3, 3, { lift = -1 })
  for x = 5, 30 do local zz = (x % 4 < 2) and 17 or 18 if bowl:has(x, zz) then c:put(x, zz, P.BROWN.m) end end
  for x = 6, 29, 4 do if bowl:has(x, 20) then c:put(x, 20, P.RED.m) c:put(x + 1, 21, P.RED.m) end end
  ln(c, { { 5, 15 }, { 30, 15 } }, P.BROWN.s, bowl)
  fillm(c, E(18, 11, 12, 3):clip(RC(0, 0, 40, 12)), P.BROWN.D)
  local heap = E(18, 11, 11, 4) part(c, heap, P.BROWN, 1, 1, { lift = 1 })
  for _, p in ipairs({ { 10, 10 }, { 14, 8 }, { 20, 8 }, { 25, 10 }, { 17, 11 }, { 22, 12 }, { 12, 12 } }) do c:put(p[1], p[2], P.BROWN.L) c:put(p[1] + 1, p[2] + 1, P.BROWN.D) end
  part(c, poly({ { 14, 8 }, { 19, 5 }, { 24, 7 }, { 19, 9 } }), P.BLUE, 1, 1, { lift = 1 }) part(c, poly({ { 24, 7 }, { 27, 4 }, { 27, 9 } }), P.BLUE, 1, 1) px(c, { { 16, 7, P.BLUE.g }, { 17, 6, P.BLUE.g } })
  px(c, { { 8, 17, P.ORANGE.g }, { 7, 18, P.ORANGE.L }, { 7, 19, P.ORANGE.L } })
  F(c, "calabash_bowl") end
-- mosaic mat
do local c = N()
  local m = rrect(2, 7, 33, 23, 2) part(c, m, P.NAVY, 2, 2)
  fillm(c, rrect(4, 9, 31, 21, 1), P.IVORY.m)
  for y = 9, 21 do for x = 4, 31 do if ((x - 4) // 3 + (y - 9) // 3) % 2 == 0 then c:put(x, y, P.IVORY.l) end end end
  for x = 4, 31 do c:put(x, 9, P.BLUE.m) c:put(x, 21, P.BLUE.b) end for y = 9, 21 do c:put(4, y, P.BLUE.m) c:put(31, y, P.BLUE.b) end
  for x = 6, 29, 4 do c:put(x, 10, P.GOLD.m) c:put(x + 1, 20, P.GOLD.m) end
  local fish = poly({ { 9, 15 }, { 13, 12 }, { 18, 12 }, { 22, 15 }, { 18, 18 }, { 13, 18 } })
  fillm(c, fish, P.ORANGE.m) fillm(c, fish:filter(function(x, y) return y >= 16 end), P.ORANGE.b)
  fillm(c, poly({ { 21, 15 }, { 26, 11 }, { 26, 19 } }), P.ORANGE.m)
  px(c, { { 11, 14, '#' }, { 12, 13, P.ORANGE.g }, { 14, 12, P.ORANGE.L }, { 15, 12, P.ORANGE.L } })
  ln(c, { { 16, 13 }, { 16, 17 } }, P.ORANGE.D) ln(c, { { 19, 14 }, { 19, 16 } }, P.ORANGE.D)
  px(c, { { 3, 8, P.NAVY.L }, { 4, 8, P.NAVY.L }, { 30, 22, P.GOLD.m }, { 32, 22, P.GOLD.m } })
  px(c, { { 33, 8, P.NAVY.b }, { 3, 22, P.NAVY.s }, { 2, 23, P.NAVY.D } })
  -- a chipped tile corner
  c:put(31, 21, P.NAVY.D) c:put(30, 21, P.NAVY.D)
  F(c, "mosaic_mat") end
-- rug runner
do local c = N()
  local m = RC(3, 8, 32, 21) m:unset(3, 8) m:unset(32, 8) m:unset(3, 21) m:unset(32, 21) part(c, m, P.RED, 2, 2)
  fillm(c, RC(5, 10, 30, 19), P.MAROON.m) for x = 5, 30 do c:put(x, 10, P.GOLD.m) c:put(x, 19, P.GOLD.b) end
  for i = 0, 3 do local cx = 9 + i * 6
    fillm(c, poly({ { cx, 11 }, { cx + 3.5, 14.5 }, { cx, 18 }, { cx - 3.5, 14.5 } }), (i % 2 == 0) and P.TEAL.m or P.GOLD.m)
    c:put(cx, 14, (i % 2 == 0) and P.TEAL.L or P.GOLD.L) c:put(cx, 15, P.RED.D) c:put(cx - 1, 13, P.CREAM.g) end
  for x = 4, 31, 2 do c:put(x, 22, P.CREAM.m) c:put(x, 23, P.CREAM.b) c:put(x + 1, 22, P.CREAM.l) end
  px(c, { { 4, 9, P.RED.g }, { 5, 9, P.RED.L }, { 3, 10, P.RED.L } })
  px(c, { { 24, 24, P.RED.D } }) c:put(24, 23, P.CREAM.s) c:put(26, 23, P.CREAM.s) -- one fringe thread askew
  F(c, "rug_runner") end
-- tea tray
do local c = N()
  local tray = rrect(2, 16, 33, 23, 2) part(c, tray, P.RED, 2, 2)
  fillm(c, RC(4, 17, 31, 20), P.RED.l) ln(c, { { 4, 17 }, { 31, 17 } }, P.RED.g) ln(c, { { 4, 21 }, { 31, 21 } }, P.RED.D)
  for x = 6, 30, 4 do c:put(x, 19, P.GOLD.m) c:put(x + 1, 19, P.GOLD.l) end
  px(c, { { 3, 24, P.RED.D }, { 4, 24, P.RED.D }, { 31, 24, P.RED.D }, { 32, 24, P.RED.D } })
  local pot = E(13, 11, 6, 4.8) part(c, pot, P.TEAL, 2, 2)
  part(c, RC(10, 5, 15, 6), P.TEAL, 1, 1) part(c, E(12.5, 4, 1.4, 1.2), P.GOLD, 1, 1)
  part(c, poly({ { 18, 11 }, { 24, 6 }, { 25, 7 }, { 20, 13 } }), P.TEAL, 1, 1)
  part(c, L.line({ { 7, 8 }, { 4, 10 }, { 4, 13 }, { 7, 14 } }), P.TEAL, 1, 1)
  ln(c, { { 8, 11 }, { 18, 11 } }, P.GOLD.m, pot) px(c, { { 10, 8, P.TEAL.g }, { 9, 9, P.TEAL.g } })
  for _, cx in ipairs({ 24, 30 }) do local cup = lathe(cx, 12, { 3, 3, 3, 2 }) part(c, cup, P.CREAM, 1, 1) fillm(c, RC(cx - 2, 12, cx + 1, 12), P.LIME.m) end
  px(c, { { 22, 12, P.CREAM.g } })
  px(c, { { 12, 1, P.CREAM.L }, { 13, 0, P.CREAM.l } }) -- a wisp of steam
  F(c, "tea_tray") end
