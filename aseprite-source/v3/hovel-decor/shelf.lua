-- Hovel wall shelf layers, 64x40, transparent. Plank top y=28, items stand on y<=27, brackets below.
-- jars  quirk: a wooden spoon left standing in the open honey jar
-- books quirk: a red ribbon bookmark dangles over the shelf edge
-- shells quirk: a pearl sits in the open clam
local H = dofile("/home/user/gnome-venture/aseprite-source/v3/hovel-decor/hd.lua")
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local pick = H.pick
local DRIFT = {"#3a3034", "#5c4e4c", "#806e62", "#a2907c", "#c2b29a", "#ded2ba"}
local GLASS = {"#3e6466", "#5e8e8a", "#86b4a8", "#acd2c2", "#d0e8da", "#eaf4e6"}

local function plank(c, S, R, o)
  o = o or {}
  local x0, x1 = o.x0 or 2, o.x1 or 61
  local m = c:rect(x0, 28, x1, 31)
  if o.drift then m:cut(c:rect(x0, 31, x0 + 1, 31)); m:cut(c:rect(x1, 28, x1, 28)) end
  H.sh(c, m, R, 4, { tex = function(x, y, t)
    if y == 28 then return R[6] end                       -- lit top edge of the board
    if x == x0 then return R[5] end                       -- pale end grain
    if y == 31 then return R[2] end
    if S.hash(floor(x / 5), y, o.seed or 3) > .72 and (x % 5 ~= 0) then return R[3] end   -- grain dashes
    return pick(R, t)
  end })
  -- tapered brackets under the board
  for _, bx in ipairs{ 8, 51 } do
    local rows = { {0, 4}, {1, 4}, {1, 3}, {2, 3}, {2, 3}, {2, 3}, {2, 2} }
    for i, r in ipairs(rows) do for x = bx + r[1], bx + r[2] do
      local col = (x == bx + r[2]) and R[2] or ((x == bx + r[1]) and R[5] or R[4])
      c:put(x, 31 + i, col)
    end end
    c:put(bx + 1, 32, R[2]); c:put(bx + 2, 32, R[2]); c:put(bx + 3, 32, R[2])   -- dark row where the bracket meets the board
  end
end

-- glass jar: body rrect, contents from fillTop down (ramp R base b), empty glass above
local function jar(c, S, x0, x1, y0, y1, r, R, b, fillTop, tex)
  local m = c:rrect(x0, y0, x1, y1, r)
  H.sh(c, m, R, b, { deep = true, tex = function(x, y, t)
    if y < fillTop then
      if x == x0 or x == x0 + 1 and y == y0 then return GLASS[5] end
      if x >= x1 - 1 then return GLASS[2] end
      return GLASS[4]
    end
    if y == fillTop then return pick(R, b + 1) end          -- meniscus catches light
    if y == y1 then return R[1] end
    if tex then local col = tex(x, y, t) if col then return col end end
    return pick(R, t)
  end })
  -- glass streak (bright, vertical) and rim column
  for y = max(y0 + 1, fillTop + 2), y1 - 3 do if (y - fillTop) % 7 ~= 6 then c:put(x0 + 2, y, GLASS[6]) end end
  c:put(x0 + 3, fillTop + 2, GLASS[6])
  for y = fillTop + 1, y1 - 1 do c:put(x0, y, pick(R, b + 2)) end
  for x = x0 + 1, x1 - 1 do c:put(x, 28, "#5a3a2a") end    -- contact shadow on the plank
  return m
end

---------------------------------------------------------------- jars
do
  local c, S = H.new("shelf-jars", 64, 40)
  plank(c, S, S.OAK, { seed = 5 })
  -- jam jar, tall, gingham cap tied with string
  jar(c, S, 5, 16, 11, 27, 2, S.BARN, 3, 13, function(x, y, t)
    if (x * 7 + y * 3) % 11 == 0 and t == 3 then return S.BARN[4] end end)  -- seeds/fruit flecks
  local cap = c:poly{ {4, 7}, {17, 7}, {18, 11}, {16, 12}, {14, 11}, {12, 12}, {9, 11}, {7, 12}, {5, 11}, {3, 11} }
  cap:add(c:rect(6, 6, 15, 6))
  cap:each(function(x, y)
    local chk = ((floor(x / 2) + floor(y / 2)) % 2 == 0)
    local col = chk and S.ROSE[4] or S.CREAM[6]
    if y >= 10 or x >= 16 then col = chk and S.ROSE[3] or S.CREAM[4] end
    if y == 6 then col = chk and S.ROSE[5] or S.CREAM[6] end
    c:put(x, y, col)
  end)
  H.hline(c, 5, 16, 10, S.GOLD[3]); c:put(6, 10, S.GOLD[5]); c:put(17, 11, S.GOLD[3]); c:put(18, 12, S.GOLD[2])  -- string with a loose tail
  -- honey jar, squat and wide, open, a spoon stands in it
  local sp = c:line({ {30, 14}, {35, 3} }, 2)
  H.sh(c, sp, S.OAK, 4, { nolit = false })
  c:put(35, 2, S.OAK[5]); c:put(34, 3, S.OAK[6])
  jar(c, S, 20, 33, 15, 27, 3, S.GOLD, 4, 18, function(x, y, t)
    if t == 4 and (x + y * 2) % 9 == 0 then return S.GOLD[5] end end)
  for x = 21, 32 do c:put(x, 15, (x < 24) and S.IRON[5] or S.IRON[4]) end   -- tin rim band
  c:put(32, 15, S.IRON[2]); c:put(33, 16, GLASS[2])
  for y = 15, 17 do c:put(30, y, S.OAK[3]); c:put(31, y, S.OAK[2]) end      -- spoon handle dips in
  c:put(30, 18, S.GOLD[3]); c:put(31, 18, S.GOLD[3])
  -- pickle jar with a cork
  local cork = c:rect(40, 9, 45, 12)
  H.sh(c, cork, S.DIRT, 4, { tex = function(x, y, t) if (x + y) % 3 == 0 and t == 4 then return S.DIRT[3] end return pick(S.DIRT, t) end })
  H.hline(c, 40, 45, 9, S.DIRT[6])
  jar(c, S, 37, 48, 12, 27, 2, S.LEAF, 4, 14, function(x, y, t)
    local px, py = x - 37, y - 14
    -- two pickles standing in brine
    if (px >= 3 and px <= 5 and py >= 3 and py <= 11) or (px >= 7 and px <= 9 and py >= 5 and py <= 12) then
      local edge = (px == 5 or px == 9)
      if (px == 4 or px == 8) and py % 3 == 0 then return S.GREEN[4] end
      return edge and S.GREEN[2] or S.GREEN[3]
    end
  end)
  H.hline(c, 38, 47, 12, GLASS[5])
  -- little blackberry pot with a brass lid
  jar(c, S, 52, 58, 20, 27, 1, S.VIOLET, 3, 21)
  local lid = c:rect(51, 18, 59, 19)
  H.sh(c, lid, S.GOLD, 4, { pop = { 52, 18 } })
  c:put(55, 17, S.GOLD[4]); c:put(54, 17, S.GOLD[5])
  H.save(c, "hovel-shelf-jars")
end

---------------------------------------------------------------- books
do
  local c, S = H.new("shelf-books", 64, 40)
  plank(c, S, S.TIMB, { seed = 9 })
  local function book(m, R, b, bands, label)
    local x0, y0, x1, y1 = m:bbox()
    H.sh(c, m, R, b, { deep = true })
    if bands then for _, yy in ipairs(bands) do m:each(function(x, y) if y == yy then c:put(x, y, (x == x0) and S.GOLD[6] or S.GOLD[4]) end end) end end
    if label then for y = label[1], label[2] do for x = x0 + 1, x1 - 2 do c:put(x, y, (y == label[1]) and S.CREAM[6] or S.CREAM[5]) end end end
  end
  book(c:rect(5, 8, 9, 27), S.BARN, 3, { 10, 25 })
  book(c:rect(10, 12, 13, 27), S.TEAL, 4, { 14 })
  book(c:rect(14, 5, 19, 27), S.SBLUE, 3, { 7, 24 }, { 11, 14 })
  c:put(19, 5, S.SBLUE[2])
  -- leaning book, resting its top on the blue one
  local lean = c:poly{ {20, 9}, {24, 9}, {30, 28}, {25, 28} }
  book(lean, S.GREEN, 4)
  lean:each(function(x, y) if y == 13 or y == 14 then c:put(x, y, S.GOLD[(y == 13) and 5 or 3]) end end)
  -- a stack lying flat
  local fl = {
    { 34, 23, 58, 27, S.DIRT, 3 },
    { 36, 19, 56, 22, S.VIOLET, 4 },
    { 35, 16, 53, 18, S.ROSE, 4 },
  }
  for _, f in ipairs(fl) do
    local m = c:rect(f[1], f[2], f[3], f[4])
    book(m, f[5], f[6])
    -- spine end on the left: rounded spine highlight, page block on the right
    for y = f[2], f[4] do c:put(f[1], y, pick(f[5], f[6] + 1)); c:put(f[3] - 1, y, S.CREAM[(y == f[2]) and 6 or 4]); c:put(f[3] - 2, y, S.CREAM[5]) end
    c:put(f[1] + 3, f[2] + 1, S.GOLD[5]); c:put(f[1] + 4, f[2] + 1, S.GOLD[5])
  end
  -- ribbon bookmark hangs from the bottom book over the board edge
  for y = 27, 36 do c:put(44, y, (y < 29) and S.BARN[5] or S.BARN[4]); c:put(45, y, S.BARN[3]) end
  c:put(44, 37, S.BARN[4]); c:put(45, 37, S.BARN[2]); c:put(43, 37, S.BARN[4]); c:put(46, 37, S.BARN[2])
  c:put(44, 38, S.BARN[3]); c:put(45, 38, S.BARN[2])
  c:put(43, 38, S.BARN[3]); c:put(46, 38, S.BARN[2])
  c:put(44, 38, S.BARN[1]); c:put(45, 38, S.BARN[1])
  for x = 6, 30 do c:put(x, 28, S.TIMB[3]) end
  H.save(c, "hovel-shelf-books")
end

---------------------------------------------------------------- shells
do
  local c, S = H.new("shelf-shells", 64, 40)
  plank(c, S, DRIFT, { drift = true, seed = 2 })
  -- conch lying on its side, knobbly crown, pink mouth lower left
  local con = c:poly{ {4, 26}, {6, 20}, {10, 15}, {16, 13}, {21, 15}, {23, 20}, {20, 25}, {14, 28}, {6, 28} }
  H.sh(c, con, S.CREAM, 4, { deep = true, tex = function(x, y, t)
    if ((x + y * 2) % 6 == 0) and t >= 4 then return S.ROSE[4] end   -- spiral growth bands
    return pick(S.CREAM, t)
  end })
  for _, k in ipairs{ {11, 14}, {15, 12}, {19, 13} } do c:put(k[1], k[2], S.CREAM[6]); c:put(k[1] + 1, k[2], S.CREAM[4]) end
  local mouth = c:poly{ {5, 26}, {8, 21}, {12, 20}, {12, 24}, {9, 27}, {6, 27} }
  H.sh(c, mouth, S.PINK, 4, { tex = function(x, y, t) if x <= 6 then return S.PINK[6] end return pick(S.PINK, t) end })
  c:put(8, 22, S.PINK[2]); c:put(9, 22, S.PINK[2]); c:put(9, 23, S.PINK[3])
  -- red coral branching up from a sand clump
  local co = c:line({ {29, 25}, {29, 16}, {26, 11}, {25, 5} }, 2)
  co:add(c:line({ {29, 17}, {33, 12}, {34, 6} }, 2))
  co:add(c:line({ {27, 13}, {23, 10} }, 2))
  co:add(c:line({ {32, 13}, {36, 11} }, 1))
  co:add(c:line({ {25, 7}, {27, 5} }, 1))
  H.sh(c, co, S.BARN, 5, { tex = function(x, y, t) return pick(S.BARN, t) end })
  c:put(25, 4, S.BARN[6]); c:put(34, 5, S.BARN[6]); c:put(23, 9, S.BARN[6])
  local sand = c:poly{ {24, 28}, {26, 24}, {33, 24}, {35, 28} }
  H.sh(c, sand, S.DIRT, 5, { tex = function(x, y, t) if (x * 3 + y) % 5 == 0 then return S.DIRT[4] end return pick(S.DIRT, t) end })
  -- scallop fan, upright, ribbed, scalloped top edge
  local fan = c:poly{ {42, 28}, {37, 19}, {38, 15}, {41, 13}, {45, 13}, {48, 15}, {49, 19}, {44, 28} }
  for _, n in ipairs{ {38, 15}, {40, 13}, {43, 13}, {46, 13}, {48, 15} } do fan:cut(c:rect(n[1], n[2], n[1], n[2])) end
  local ear = c:rect(39, 25, 47, 27)
  fan:add(ear)
  H.sh(c, fan, S.BARN, 5, { deep = true, tex = function(x, y, t)
    local ang = math.atan(x + .5 - 43, 27 - y)
    local rib = floor((ang + 1.2) * 4.2) % 2
    if y >= 25 then return pick(S.BARN, t - 1) end
    if rib == 0 and t >= 5 then return S.BARN[6] end
    if rib == 1 and t == 5 then return S.BARN[4] end
    return pick(S.BARN, t)
  end })
  -- open clam with a pearl
  local lo = c:poly{ {50, 24}, {60, 24}, {58, 28}, {52, 28} }
  H.sh(c, lo, S.STONE, 4, { deep = true })
  H.hline(c, 51, 59, 24, S.PINK[5])
  local up = c:poly{ {50, 23}, {53, 17}, {59, 16}, {61, 23} }
  H.sh(c, up, S.STONE, 4, { deep = true, tex = function(x, y, t) if (x + y) % 3 == 0 and t == 4 then return S.STONE[3] end return pick(S.STONE, t) end })
  H.hline(c, 51, 60, 23, S.PINK[4])
  for _, p in ipairs{ {54, 21, S.CREAM[6]}, {55, 21, S.CREAM[5]}, {54, 22, S.CREAM[5]}, {55, 22, S.STONE[4]} } do c:put(p[1], p[2], p[3]) end
  c:put(53, 22, S.STONE[2]); c:put(56, 22, S.STONE[2]); c:put(56, 21, S.CREAM[4]); c:put(53, 21, S.CREAM[6])
  H.save(c, "hovel-shelf-shells")
end
