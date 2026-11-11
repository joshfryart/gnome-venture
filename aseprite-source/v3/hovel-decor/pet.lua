-- Hovel pet corner layers, 48x32, transparent, empty beds (no animals).
-- basket  quirk: one loose willow withy springs out of the rim
-- cushion quirk: a sleepy dent pressed into the middle, round the tuft button
-- hammock quirk: a frayed rope tail dangles from the left post
local H = dofile("/home/user/gnome-venture/aseprite-source/v3/hovel-decor/hd.lua")
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local pick = H.pick
local WIL = {"#4a2c22", "#6e4428", "#946234", "#b88444", "#d6a65a", "#ecc87c"}
local function rows(list, y0)
  local m = H.HP.mask()
  for i, r in ipairs(list) do for x = r[1], r[2] do m:set(x, y0 + i - 1) end end
  return m
end

---------------------------------------------------------------- basket
do
  local c, S = H.new("pet-basket", 48, 32)
  -- far rim and inside (back wall of the basket seen over the dip)
  local top = rows({ {11, 36}, {7, 40}, {4, 43}, {3, 44}, {2, 45} }, 4)
  top:add(c:rect(2, 9, 45, 16))
  top:each(function(x, y)
    local tw = (x + y) % 3
    local col
    if y <= 6 or x <= 4 or x >= 43 then col = (tw == 0) and WIL[3] or ((y == 4 or x <= 3) and WIL[6] or WIL[5])
    else col = (y <= 8) and WIL[2] or WIL[3] end                       -- shadowed inner wall
    c:put(x, y, col)
  end)
  -- cloth tucked inside, gingham, one corner draped over the dip
  local cloth = c:poly{ {5, 8}, {42, 8}, {43, 14}, {31, 16}, {28, 22}, {24, 23}, {19, 17}, {4, 14} }
  cloth:each(function(x, y)
    local chk = (floor(x / 2) + floor(y / 2)) % 2 == 0
    local lit = y <= 10
    local col = chk and (lit and S.ROSE[5] or S.ROSE[4]) or (lit and S.CREAM[6] or S.CREAM[5])
    if y >= 13 and x >= 36 then col = chk and S.ROSE[3] or S.CREAM[4] end
    if (x == 14 or x == 15) and y >= 10 and y <= 14 then col = chk and S.ROSE[3] or S.CREAM[3] end  -- a fold
    c:put(x, y, col)
  end)
  -- front wall with a low dip in the middle
  local front = c:poly{ {2, 13}, {16, 13}, {19, 18}, {29, 18}, {32, 13}, {46, 13}, {43, 31}, {5, 31} }
  front:each(function(x, y)
    local yy = y - 13
    local stake = (x % 6 == 2)
    local band = floor(yy / 3)
    local seg = floor((x + band * 3) / 4) % 2
    local col = seg == 0 and WIL[5] or WIL[4]
    if yy % 3 == 2 then col = WIL[3] end
    if stake then col = WIL[3] end
    if x <= 4 + floor(yy / 6) then col = WIL[5] end
    if x >= 42 - floor(yy / 6) then col = (yy % 3 == 2) and WIL[1] or WIL[2] end
    if y >= 29 then col = (y == 30) and WIL[1] or WIL[2] end
    c:put(x, y, col)
  end)
  -- twisted rim along the front top edge
  local function rimAt(x) if x < 16 or x > 32 then return 13 end if x >= 19 and x <= 29 then return 18 end return (x < 19) and (13 + floor((x - 16) * 5 / 3 + .5)) or (13 + floor((32 - x) * 5 / 3 + .5)) end
  for x = 2, 45 do
    local y = rimAt(x)
    c:put(x, y, (x % 3 == 0) and WIL[4] or WIL[6]); c:put(x, y + 1, (x % 3 == 1) and WIL[2] or WIL[4])
  end
  -- loose withy springing out of the right rim
  for _, p in ipairs{ {44, 12}, {45, 11}, {46, 10}, {46, 9}, {47, 8} } do c:put(p[1], p[2], WIL[5]) end
  H.save(c, "hovel-pet-basket")
end

---------------------------------------------------------------- cushion
do
  local c, S = H.new("pet-cushion", 48, 32)
  local R = { "#3c2048", "#5e3060", "#844678", "#a8608e", "#c882a4", "#e4aac0" }   -- plum velvet
  local side = c:poly{ {3, 16}, {3, 21}, {12, 28}, {36, 28}, {45, 21}, {45, 16} }
  H.sh(c, side, R, 3, { deep = true, tex = function(x, y, t) if y >= 26 then return R[1] end return pick(R, t) end })
  local topf = c:poly{ {12, 4}, {36, 4}, {45, 11}, {45, 17}, {36, 23}, {12, 23}, {3, 17}, {3, 11} }
  topf:each(function(x, y)
    local dx, dy = (x - 23.5) / 14, (y - 13.5) / 6
    local d = max(abs(dx), abs(dy)) * .6 + (abs(dx) + abs(dy)) * .4  -- octagonal distance from centre
    local t
    if d < .5 then
      t = (dx - dy > .15) and 4 or 3                                -- the dent: dark far side, lit near side
      if dx + dy > .45 then t = 5 end
    elseif d < .62 then t = (dx + dy < 0) and 3 or 5                -- rim of the dent
    elseif d < .85 then t = (dx + dy < -.4) and 6 or 5
    else t = (dx + dy > .5) and 4 or 5 end
    c:put(x, y, R[t])
  end)
  -- gold piping along the seam between top and side
  local pip = { {3, 17}, {12, 23}, {36, 23}, {45, 17} }
  local pm = c:line(pip, 1)
  pm:each(function(x, y) c:put(x, y, (x < 20) and S.GOLD[5] or S.GOLD[4]) end)
  -- tuft button in the dent
  c:put(23, 13, S.GOLD[5]); c:put(24, 13, S.GOLD[4]); c:put(23, 14, S.GOLD[4]); c:put(24, 14, S.GOLD[3])
  c:put(22, 13, R[2]); c:put(25, 14, R[2])
  -- corner tassels
  for _, t in ipairs{ {2, 17, -1}, {45, 17, 1} } do
    c:put(t[1], t[2], S.GOLD[5]); c:put(t[1] + t[3], t[2] + 1, S.GOLD[4]); c:put(t[1] + t[3], t[2] + 2, S.GOLD[3])
    c:put(t[1], t[2] + 2, S.GOLD[4]); c:put(t[1], t[2] + 1, S.GOLD[4])
  end
  c:put(14, 6, R[6]); c:put(15, 6, R[6])
  H.save(c, "hovel-pet-cushion")
end

---------------------------------------------------------------- hammock
do
  local c, S = H.new("pet-hammock", 48, 32)
  local O = S.OAK
  for _, px in ipairs{ 3, 42 } do
    local post = c:rect(px, 4, px + 2, 29)
    H.sh(c, post, O, 4, { deep = true, tex = function(x, y, t) if x == px + 1 and y % 5 == 2 then return O[3] end return pick(O, t) end })
    local cap = c:rect(px, 2, px + 2, 3); H.sh(c, cap, O, 5)
    c:put(px + 1, 1, O[5])
    local foot = c:rect(px - 2, 29, px + 4, 31)
    H.sh(c, foot, O, 4, { deep = true })
    H.hline(c, px, px + 2, 6, S.DIRT[5]); H.hline(c, px, px + 2, 7, S.DIRT[3])   -- rope lashing
  end
  -- ropes from post tops to the spreader bars
  local rope = c:line({ {6, 7}, {11, 12} }, 1); rope:add(c:line({ {41, 7}, {36, 12} }, 1))
  rope:each(function(x, y) c:put(x, y, ((x + y) % 2 == 0) and S.DIRT[5] or S.DIRT[4]) end)
  -- sagging cloth, striped
  local ST = { S.TEAL, S.CREAM, S.BARN, S.CREAM }
  for x = 11, 36 do
    local k = 1 - ((x - 23.5) / 13) ^ 2
    local yt = 12 + floor(7 * k + .5)
    local yb = yt + 3 + floor(2 * k + .5)
    local R = ST[(floor((x - 11) / 3) % 4) + 1]
    for y = yt, yb do
      local t = 4
      if y == yt then t = 6 elseif y == yt + 1 then t = 5 elseif y == yb then t = 2 elseif y == yb - 1 then t = 3 end
      c:put(x, y, R[t])
    end
  end
  for _, bx in ipairs{ 11, 36 } do for y = 11, 15 do c:put(bx, y, (y == 11) and O[6] or O[4]) end end   -- spreader bars
  -- frayed rope tail off the left post
  for _, p in ipairs{ {2, 8}, {1, 9}, {1, 10}, {1, 11}, {2, 12}, {1, 13} } do c:put(p[1], p[2], S.DIRT[5]) end
  c:put(0, 14, S.DIRT[4]); c:put(2, 14, S.DIRT[4])
  H.save(c, "hovel-pet-hammock")
end
