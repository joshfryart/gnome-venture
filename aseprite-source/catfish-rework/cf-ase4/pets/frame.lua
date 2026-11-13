local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local P = dofile(DIR .. "/pp.lua")
local L, E, RC, poly, part, px, ln, lathe, sep, fillm, rrect = P.L, P.E, P.RC, P.poly, P.part, P.px, P.ln, P.lathe, P.sep, P.fillm, P.rrect
local N = function() return P.new(35, 31) end
local F = function(c, n) P.finish(c, "cf-pet-" .. n, 35, 31) end
local function framed(c, ramp, x0, y0, x1, y1, t, r)
  part(c, rrect(x0, y0, x1, y1, r or 2), ramp, 2, 2)
  local inner = rrect(x0 + t, y0 + t, x1 - t, y1 - t, 1)
  sep(c, inner) return inner
end
-- chai stall sign
do local c = N()
  local inn = framed(c, P.MAROON, 2, 3, 32, 28, 3)
  fillm(c, inn, P.NAVY.s) fillm(c, RC(6, 6, 28, 18):clip(inn), P.NAVY.b) fillm(c, RC(6, 6, 28, 10):clip(inn), P.NAVY.m)
  fillm(c, RC(6, 22, 28, 24):clip(inn), P.WOOD.m) ln(c, { { 6, 22 }, { 28, 22 } }, P.WOOD.l)
  part(c, E(14, 19, 5, 3.6), P.GOLD, 1, 1) part(c, RC(11, 14, 16, 15), P.GOLD, 1, 1) c:put(13, 13, P.GOLD.l) c:put(14, 13, P.GOLD.l)
  part(c, poly({ { 19, 17 }, { 22, 15 }, { 21, 18 } }), P.GOLD, 1, 1) ln(c, { { 9, 17 }, { 10, 19 }, { 11, 20 } }, P.GOLD.D)
  px(c, { { 12, 17, P.GOLD.g }, { 13, 16, P.GOLD.g } })
  part(c, rrect(21, 19, 25, 22, 1), P.CREAM, 1, 1) px(c, { { 22, 19, P.ORANGE.m }, { 23, 19, P.ORANGE.m } })
  px(c, { { 14, 11, P.CREAM.L }, { 15, 10, P.CREAM.l }, { 14, 9, P.CREAM.L }, { 15, 8, P.CREAM.m } })
  for i = 0, 3 do px(c, { { 4 + i * 9, 4, P.GOLD.m }, { 5 + i * 9, 4, P.GOLD.l } }) end
  px(c, { { 4, 26, P.GOLD.m }, { 5, 26, P.GOLD.m }, { 30, 26, P.GOLD.m }, { 29, 26, P.GOLD.m } })
  px(c, { { 3, 5, P.MAROON.g }, { 4, 4, P.MAROON.L } })
  F(c, "chai_stall_sign") end
-- driftwood board
do local c = N()
  local inn = framed(c, P.SAND, 2, 3, 32, 28, 3)
  fillm(c, inn, P.AQUA.s) fillm(c, RC(6, 6, 28, 20):clip(inn), P.AQUA.m) fillm(c, RC(6, 6, 28, 12):clip(inn), P.AQUA.L)
  fillm(c, RC(6, 21, 28, 25):clip(inn), P.SAND.l) ln(c, { { 6, 21 }, { 28, 21 } }, P.CREAM.g)
  for _, w in ipairs({ { 8, 15 }, { 17, 17 }, { 22, 13 } }) do ln(c, { { w[1], w[2] }, { w[1] + 2, w[2] - 1 }, { w[1] + 4, w[2] }, { w[1] + 6, w[2] - 1 } }, P.AQUA.g) end
  part(c, E(22, 9, 2.6, 2.6), P.GOLD, 1, 1) px(c, { { 21, 8, P.GOLD.g } })
  ln(c, { { 7, 15 }, { 10, 15 } }, P.AQUA.b)
  for _, g in ipairs({ { 4, 9 }, { 29, 11 }, { 5, 22 }, { 30, 24 } }) do ln(c, { { g[1], g[2] }, { g[1], g[2] + 3 } }, P.SAND.s) end
  part(c, poly({ { 9, 24 }, { 11, 22 }, { 14, 24 }, { 13, 25 }, { 10, 25 } }), P.PINK, 1, 1) px(c, { { 10, 24, P.PINK.g } }) -- a shell on the sand
  ln(c, { { 14, 1 }, { 17, 3 }, { 20, 1 } }, P.SAND.m) px(c, { { 17, 1, P.SAND.L }, { 17, 0, P.SAND.m } })
  F(c, "driftwood_board") end
-- gecko friend
do local c = N()
  local inn = framed(c, P.GOLD, 2, 3, 32, 28, 3)
  fillm(c, inn, P.TEAL.b) fillm(c, RC(6, 6, 28, 18):clip(inn), P.TEAL.m)
  part(c, P.leaf({ { 6, 25 }, { 16, 21 }, { 28, 24 } }, 4), P.LIME, 1, 1) ln(c, { { 8, 24 }, { 26, 23 } }, P.LIME.L)
  local body = L.tube({ { 8, 10 }, { 14, 12 }, { 19, 15 }, { 23, 18 }, { 27, 21 } }, function(t) return 2.8 - t * 1.6 end)
  part(c, body, P.BLUE, 1, 1, { lift = 0 })
  local tail = L.tube({ { 27, 21 }, { 30, 23 }, { 28, 25 } }, function(t) return 1.2 - t * .6 end) part(c, tail, P.BLUE, 1, 1)
  part(c, E(8, 10, 3.2, 2.8), P.BLUE, 1, 1)
  for _, lg in ipairs({ { { 12, 12 }, { 11, 16 }, { 9, 17 } }, { { 14, 11 }, { 15, 7 }, { 13, 6 } }, { { 20, 15 }, { 21, 19 }, { 19, 20 } }, { { 19, 14 }, { 22, 12 }, { 24, 13 } } }) do ln(c, lg, P.BLUE.m) c:put(lg[3][1], lg[3][2], P.BLUE.l) end
  for _, p in ipairs({ { 12, 11 }, { 15, 13 }, { 18, 14 }, { 21, 16 }, { 24, 19 } }) do c:put(p[1], p[2], P.TEAL.l) end
  px(c, { { 7, 9, '#fff4d6' }, { 7, 10, '#' }, { 5, 10, P.BLUE.D }, { 9, 9, P.BLUE.g }, { 12, 10, P.BLUE.g } })
  F(c, "gecko_friend") end
-- mask frame
do local c = N()
  local inn = framed(c, P.BROWN, 2, 3, 32, 28, 3)
  fillm(c, inn, P.NAVY.D)
  for x = 3, 31, 2 do c:put(x, 4, P.BROWN.L) c:put(x, 27, P.BROWN.L) end
  local face = poly({ { 17.5, 6 }, { 24, 8 }, { 24, 17 }, { 20, 24 }, { 17.5, 26 }, { 15, 24 }, { 11, 17 }, { 11, 8 } })
  part(c, face, P.WOOD, 2, 2, { lift = 1 })
  fillm(c, poly({ { 12, 11 }, { 16, 12 }, { 16, 13 }, { 12, 13 } }), P.BROWN.u or '#2a1a10') fillm(c, poly({ { 19, 12 }, { 23, 11 }, { 23, 13 }, { 19, 13 } }), '#2a1a10')
  px(c, { { 14, 12, P.GOLD.l }, { 21, 12, P.GOLD.l } })
  ln(c, { { 17, 12 }, { 17, 19 }, { 18, 19 } }, P.WOOD.D) ln(c, { { 16, 20 }, { 19, 20 } }, P.WOOD.D)
  fillm(c, RC(15, 22, 20, 23), '#2a1a10') for x = 15, 19, 2 do c:put(x, 22, P.GOLD.L) end
  for _, y in ipairs({ 15, 17 }) do ln(c, { { 12, y }, { 14, y } }, P.RED.m) ln(c, { { 21, y }, { 23, y } }, P.RED.m) end
  ln(c, { { 13, 8 }, { 22, 8 } }, P.TEAL.m) for x = 13, 21, 2 do c:put(x, 7, P.TEAL.l) end
  px(c, { { 12, 9, P.WOOD.g }, { 12, 10, P.WOOD.L } })
  F(c, "mask_frame") end
-- mirage mirror
do local c = N()
  local arch = P.lathe(17.5, 3, { 4, 6, 8, 9, 10, 11, 12, 12, 13, 13, 14, 14 }):add(RC(3, 15, 31, 26))
  arch:add(RC(2, 27, 33, 28))
  part(c, arch, P.TEAL, 2, 2)
  local inn = P.lathe(17.5, 6, { 3, 5, 7, 8, 9, 10, 10, 11, 11 }):add(RC(6, 15, 28, 23))
  fillm(c, inn, P.SAND.l) fillm(c, inn:filter(function(x, y) return y < 14 end), P.AQUA.L)
  fillm(c, inn:filter(function(x, y) return y < 9 end), P.AQUA.m)
  fillm(c, inn:filter(function(x, y) return y >= 14 and y < 17 and (x + y) % 5 < 3 end), P.SAND.L)
  fillm(c, poly({ { 6, 18 }, { 12, 14 }, { 18, 18 }, { 24, 15 }, { 28, 19 }, { 28, 23 }, { 6, 23 } }):clip(inn), P.SAND.m)
  fillm(c, poly({ { 6, 21 }, { 14, 19 }, { 22, 21 }, { 28, 20 }, { 28, 23 }, { 6, 23 } }):clip(inn), P.SAND.b)
  ln(c, { { 17, 16 }, { 16, 12 }, { 17, 9 } }, P.WOOD.m)
  for _, l in ipairs({ { { 17, 9 }, { 13, 9 } }, { { 17, 9 }, { 21, 9 } }, { { 17, 9 }, { 14, 11 } }, { { 17, 9 }, { 20, 11 } } }) do ln(c, l, P.LIME.m) end
  part(c, E(24, 11, 2, 2), P.GOLD, 1, 1)
  ln(c, { { 8, 19 }, { 11, 19 } }, P.CREAM.g) ln(c, { { 19, 21 }, { 23, 21 } }, P.CREAM.g)
  sep(c, inn)
  px(c, { { 9, 9, P.TEAL.g }, { 8, 12, P.TEAL.L }, { 4, 17, P.TEAL.g }, { 4, 18, P.TEAL.L }, { 17, 3, P.GOLD.m }, { 17, 4, P.GOLD.l } })
  F(c, "mirage_mirror") end
