-- Hovel floor lamp layers, 16x40, transparent, feet at the bottom centre.
-- candle  quirk: a long wax drip has run down onto the drip pan
-- glowcap quirk: a baby glowcap sprouts from the moss at its foot
-- lantern quirk: the roof finial is bent over sideways
local H = dofile("/home/user/gnome-venture/aseprite-source/v3/hovel-decor/hd.lua")
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local pick = H.pick
local BRASS = {"#3a2638", "#6a4030", "#9c6a2c", "#c89636", "#ecc058", "#fcec a0"}
BRASS[6] = "#fceca0"
local FL = { core = "#fff0b0", hi = "#fcd25a", mid = "#f49a34", out = "#d8582c" }

local function rows(c, list, y0)
  local m = c:rect(-9, -9, -9, -9); m = H.HP.mask()
  for i, r in ipairs(list) do for x = r[1], r[2] do m:set(x, y0 + i - 1) end end
  return m
end
local function flame(c, x, y)          -- (x,y) = tip; 4 wide at the base
  c:put(x, y, FL.out)
  c:put(x, y + 1, FL.mid); c:put(x + 1, y + 1, FL.out)
  c:put(x - 1, y + 2, FL.out); c:put(x, y + 2, FL.hi); c:put(x + 1, y + 2, FL.mid)
  c:put(x - 1, y + 3, FL.mid); c:put(x, y + 3, FL.core); c:put(x + 1, y + 3, FL.hi); c:put(x + 2, y + 3, FL.out)
  c:put(x - 1, y + 4, FL.out); c:put(x, y + 4, FL.hi); c:put(x + 1, y + 4, FL.mid)
end

---------------------------------------------------------------- candle stick
do
  local c, S = H.new("lamp-candle", 16, 40)
  local foot = rows(c, { {6, 9}, {5, 10}, {4, 11}, {3, 12} }, 36)
  H.sh(c, foot, BRASS, 4, { deep = true, pop = { 5, 37 } })
  local stem = c:rect(7, 17, 8, 35)
  stem:add(c:rect(6, 26, 9, 27)); stem:add(c:rect(6, 33, 9, 35))
  H.sh(c, stem, BRASS, 4, { tex = function(x, y, t) if x == 7 then return BRASS[5] end return pick(BRASS, t) end })
  H.hline(c, 6, 9, 28, BRASS[2]); H.hline(c, 6, 9, 32, BRASS[3])
  local pan = rows(c, { {3, 12}, {4, 11}, {6, 9} }, 14)
  H.sh(c, pan, BRASS, 4, { deep = true })
  H.hline(c, 3, 12, 14, BRASS[6]); c:put(12, 14, BRASS[4])
  local wax = c:rect(6, 6, 9, 13)
  H.sh(c, wax, S.CREAM, 5, { tex = function(x, y, t) if y == 6 then return S.CREAM[6] end return pick(S.CREAM, t) end })
  c:put(7, 7, S.CREAM[6]); c:put(7, 8, S.CREAM[6])
  -- the long drip, down the left side and pooling on the pan
  for y = 7, 14 do c:put(5, y, (y < 9) and S.CREAM[6] or S.CREAM[5]) end
  c:put(4, 13, S.CREAM[5]); c:put(4, 14, S.CREAM[6]); c:put(5, 15, S.CREAM[4])
  c:put(8, 5, "#4a2c3c")                                            -- wick
  flame(c, 8, 0)
  H.save(c, "hovel-lamp-candle")
end

---------------------------------------------------------------- glowcap
do
  local c, S = H.new("lamp-glowcap", 16, 40)
  local T = S.TEAL
  -- mossy foot mound, lit from above by the cap
  local mound = rows(c, { {5, 10}, {3, 12}, {2, 13}, {1, 14} }, 36)
  H.sh(c, mound, S.GREEN, 4, { deep = true, tex = function(x, y, t)
    if y == 36 and x >= 6 and x <= 9 then return S.LEAF[6] end
    if (x + y) % 3 == 0 and t == 4 then return S.GREEN[5] end
    return pick(S.GREEN, t)
  end })
  -- stalk, slim with a slight lean, warm-lit near the cap
  local st = H.HP.mask()
  for y = 14, 36 do local x0 = (y > 26) and 6 or 7; for x = x0, x0 + 2 do st:set(x, y) end end
  st:add(c:rect(6, 33, 9, 36))
  H.sh(c, st, S.CREAM, 4, { tex = function(x, y, t)
    if y <= 17 then return (x == 7 or x == 6 and y > 26) and "#fff0b0" or S.GOLD[6] end
    if y <= 21 then t = t + 1 end
    return pick(S.CREAM, t)
  end })
  H.hline(c, 6, 9, 30, S.CREAM[3])                                  -- a little ring-scar on the stalk
  -- cap: stepped glow, brightest in the heart, gills glowing gold under the rim
  local cap = rows(c, { {5, 10}, {3, 12}, {2, 13}, {1, 14}, {1, 14}, {0, 15}, {0, 15}, {0, 15}, {0, 15} }, 3)
  cap:each(function(x, y)
    local dx, dy = abs(x - 6.5), abs(y - 6.5) * 1.6
    local d = max(dx, dy)
    local col = (d < 2.5) and T[6] or ((d < 5) and T[5] or T[4])
    if x >= 13 and y >= 8 then col = T[3] end
    if y == 11 then col = (x >= 12) and T[2] or T[3] end
    c:put(x, y, col)
  end)
  for _, p in ipairs{ {4, 5}, {9, 4}, {11, 7}, {3, 8}, {7, 9} } do c:put(p[1], p[2], "#f4f4b8"); c:put(p[1] + 1, p[2], "#f4f4b8") end
  c:put(5, 6, S.CREAM[6])
  local gill = rows(c, { {1, 14}, {3, 12} }, 12)
  gill:each(function(x, y) c:put(x, y, (y == 12) and ((x % 2 == 0) and S.GOLD[6] or S.GOLD[5]) or ((x % 2 == 0) and S.GOLD[5] or S.GOLD[4])) end)
  -- baby glowcap at the foot
  c:put(11, 32, T[6]); c:put(12, 32, T[5]); c:put(10, 33, T[5]); c:put(11, 33, T[5]); c:put(12, 33, T[4]); c:put(13, 33, T[3])
  c:put(11, 34, S.GOLD[6]); c:put(12, 34, S.GOLD[5]); c:put(11, 35, S.CREAM[5])
  H.save(c, "hovel-lamp-glowcap")
end

---------------------------------------------------------------- tin lantern
do
  local c, S = H.new("lamp-lantern", 16, 40)
  local I = S.IRON
  local TIN = {"#2c2838", "#4a4658", "#6e6c80", "#9898a8", "#c0c0c8", "#e2e2e2"}
  -- three stubby feet and a base plate
  for _, fx in ipairs{ 2, 7, 12 } do c:put(fx, 39, TIN[2]); c:put(fx + 1, 39, TIN[1]) end
  local plate = c:rect(1, 36, 14, 38)
  H.sh(c, plate, TIN, 4, { deep = true })
  H.hline(c, 1, 14, 36, TIN[5])
  -- body: punched tin, warm light shining through the holes
  local body = c:rect(2, 16, 13, 35)
  H.sh(c, body, TIN, 4, { deep = true, band = 2, tex = function(x, y, t)
    local px, py = x - 2, y - 17
    local holes = ((px % 4 == 1) and (py % 4 == 0)) or ((px % 4 == 3) and (py % 4 == 2))
    if holes and y >= 18 and y <= 33 and x >= 3 and x <= 12 then
      return (x <= 7) and FL.core or FL.hi
    end
    if x == 2 or x == 3 and y > 16 then return TIN[5] end
    return pick(TIN, t)
  end })
  -- a little window strip with the candle flame inside
  for y = 20, 27 do for x = 6, 9 do c:put(x, y, (y < 23) and "#f8d878" or "#f2b850") end end
  flame(c, 7, 21); c:put(7, 26, S.CREAM[6]); c:put(8, 26, S.CREAM[5]); c:put(7, 27, S.CREAM[5]); c:put(8, 27, S.CREAM[4])
  H.vline(c, 5, 19, 28, TIN[2]); H.vline(c, 10, 19, 28, TIN[2]); H.hline(c, 5, 10, 19, TIN[2]); H.hline(c, 5, 10, 28, TIN[2])
  H.hline(c, 2, 13, 16, TIN[6]); H.hline(c, 2, 13, 34, TIN[3])
  -- cone roof
  local roof = rows(c, { {6, 9}, {5, 10}, {4, 11}, {3, 12}, {2, 13}, {1, 14} }, 9)
  roof:add(c:rect(1, 15, 14, 15))
  H.sh(c, roof, TIN, 4, { deep = true, tex = function(x, y, t) if (x - y) % 3 == 0 and t == 4 then return TIN[3] end return pick(TIN, t) end })
  H.hline(c, 1, 14, 15, TIN[2])
  -- bent finial
  c:put(7, 8, TIN[4]); c:put(8, 8, TIN[3]); c:put(8, 7, TIN[4]); c:put(9, 6, TIN[5]); c:put(10, 6, TIN[4]); c:put(11, 7, TIN[3])
  -- square bail handle
  for x = 4, 11 do c:put(x, 2, (x < 8) and I[5] or I[4]) end
  for y = 3, 9 do c:put(4, y, I[5]); c:put(11, y, I[3]) end
  H.save(c, "hovel-lamp-lantern")
end
