-- backpack.lua: Maizehollow (CA) backpack concepts 1..5
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local hash = X.hash
local function lash(c, x, y, w)
  for dy = 0, 2 do C.hline(c, x, x + w - 1, y + dy, R.straw[dy == 0 and 5 or (dy == 1 and 4 or 2)]) end
  c:put(x, y + 1, R.straw[3])
end

---------------------------------------------------------------- 1 carrier frame + clay water jar + tumpline
do
  local c = C.new("backpack-1-carrier-frame")
  -- tumpline band arching over the top
  local tump = HP.mask()
  local tm = G.tube({ {18, 10}, {20, 0}, {44, 0}, {46, 10} }, function() return 2.2 end)
  tump:add(tm)
  C.part(c, tump, R.cochi, { R = 2 })
  tump:each(function(x, y) if (x % 3 == 0) then c:put(x, y, R.cochi[2]) end end)
  -- poles
  local pl = c:rrect(14, 8, 18, 58, 2)
  local pr = c:rrect(45, 8, 49, 58, 2)
  local bars = c:rect(15, 14, 48, 16):add(c:rect(15, 32, 48, 34)):add(c:rect(15, 52, 48, 54))
  C.part(c, bars, R.wood, { R = 1, b = -1 })
  for _, y in ipairs({ 14, 32, 52 }) do C.hline(c, 15, 48, y, R.wood[5]) C.hline(c, 15, 48, y + 2, R.wood[2]) end
  C.vcyl(c, pl, R.wood, 14, 18, { tex = function(x, y) if hash(x, y, 4) < .12 then return -1 end end })
  C.vcyl(c, pr, R.wood, 45, 49, { b = -1, tex = function(x, y) if hash(x, y, 4) < .12 then return -1 end end })
  -- slats on the back of the frame (behind the jar)
  for _, x in ipairs({ 24, 31, 38 }) do
    local s = c:rect(x, 17, x + 2, 51)
    C.vcyl(c, s, R.straw, x, x + 2, { b = -1 })
  end
  -- clay jar sitting on the bottom shelf
  local jar = c:ellipse(31.5, 42, 11, 9.5):add(c:rrect(26, 26, 37, 34, 2))
  local lip = c:rrect(24, 24, 39, 28, 2)
  C.sep(c, jar:copy():add(lip), c:rect(0, 0, 63, 63), R.wood[1])
  C.part(c, jar, R.clay, { R = 6, hs = .7 })
  -- painted band + dots
  for x = 21, 42 do if jar:has(x, 40) then c:put(x, 40, R.cotton[5]) c:put(x, 41, R.cotton[3]) end end
  for x = 22, 41, 3 do if jar:has(x, 44) then c:put(x, 44, R.cacao[2]) end end
  C.part(c, lip, R.clay, { R = 1, b = 1 })
  C.hline(c, 26, 37, 25, R.clay[2])
  c:put(24, 36, R.clay[6]) c:put(24, 37, R.clay[6]) c:put(25, 35, C.cream)
  -- rope lashings at the joints
  for _, p in ipairs({ {14, 13}, {45, 13}, {14, 31}, {45, 31}, {14, 51}, {45, 51} }) do lash(c, p[1], p[2], 5) end
  -- quirk: a parrot feather tucked into the top-left lashing
  local fm, fn, FT = X.cyl(16, 13, 6, 2, function(t) return t < .1 and .6 or 1.6 * math.sin(math.min(1, t) * 3.1) + .3 end)
  C.W.toneN(c, fm, fn, R.cochi)
  fm:each(function(x, y) if FT[K(x, y)] > .55 then c:put(x, y, R.jade[(x + y) % 2 == 0 and 5 or 4]) end end)
  fm:each(function(x, y) if FT[K(x, y)] > .85 then c:put(x, y, R.jade[3]) end end)
  C.save(c, "backpack-1-carrier-frame")
end

---------------------------------------------------------------- 2 maize net bag
do
  local c = C.new("backpack-2-maize-net-bag")
  local sack = c:ellipse(32, 40, 19, 17):add(c:poly{ {22, 26}, {42, 26}, {38, 18}, {26, 18} })
  -- the cob poking out the top (behind the gather)
  local cob = X.cyl(37, 22, 45, 5, function(t) return t > .92 and 2 or 3.2 end)
  local cobm, cobn = X.cyl(37, 22, 45, 5, function(t) return t > .9 and 2.2 or 3.4 end)
  C.W.toneN(c, cobm, cobn, R.maize)
  cobm:each(function(x, y) if (x + 2 * y) % 3 == 0 then c:put(x, y, R.maize[2]) end end)
  local husk = c:poly{ {33, 20}, {38, 10}, {37, 20} }:add(c:poly{ {40, 20}, {44, 13}, {42, 21} })
  C.part(c, husk, R.jade, { R = 1 })
  -- silk tuft
  C.put(c, { {45, 3}, {46, 2}, {47, 2}, {44, 2}, {46, 1}, {48, 3}, {47, 4} }, R.maize[6])
  C.put(c, { {46, 3}, {45, 4} }, R.marig[3])
  -- strap loop over the top
  local loop = G.tube({ {22, 22}, {16, 4}, {32, 4}, {30, 20} }, function() return 1.3 end)
  C.part(c, loop, R.straw, { R = 1 })
  C.sep(c, sack, cobm:copy():add(husk):add(loop), R.straw[1])
  -- contents: cobs + husk seen through the net
  local si = C.part(c, sack, R.maize, { R = 7, hs = .8, b = 0 })
  local onNet = function(x, y) return (x + y) % 6 == 0 or (x - y + 60) % 6 == 0 end
  sack:each(function(x, y)
    local i = si[K(x, y)]
    local cell = ((x + y) // 6) * 31 + ((x - y + 60) // 6)
    if hash(cell, 3, 11) < .1 then c:put(x, y, R.jade[math.max(1, i - 1)])
    elseif (x + y * 2) % 3 == 0 then c:put(x, y, R.maize[math.max(1, i - 1)]) end
  end)
  -- the knotted net: pale cord, knots at crossings, shadow under each cord
  sack:each(function(x, y)
    local i = si[K(x, y)]
    if onNet(x, y) then
      local knot = (x + y) % 6 == 0 and (x - y + 60) % 6 == 0
      c:put(x, y, knot and R.cotton[math.min(6, i + 1)] or R.straw[math.min(6, i + 1)])
    elseif onNet(x - 1, y - 1) == false and (onNet(x, y - 1) or onNet(x - 1, y)) then
      c:put(x, y, R.straw[1])
    end
  end)
  -- gathered neck + drawstring
  local neck = c:rrect(24, 18, 40, 22, 2)
  C.part(c, neck, R.straw, { R = 1 })
  for x = 25, 39, 2 do c:put(x, 21, R.straw[2]) end
  C.hline(c, 24, 40, 23, R.cochi[3]) C.hline(c, 25, 39, 24, R.cochi[2])
  C.put(c, { {22, 24}, {21, 25}, {21, 26}, {20, 27} }, R.cochi[4]) c:put(20, 28, R.cochi[5])
  C.save(c, "backpack-2-maize-net-bag")
end

---------------------------------------------------------------- 3 palm basket pack + hummingbird
do
  local c = C.new("backpack-3-palm-basket-pack")
  local body = c:poly{ {14, 22}, {50, 22}, {46, 56}, {18, 56} }:add(c:rrect(18, 52, 46, 58, 3))
  local cords = c:line({ {14, 26}, {9, 34}, {10, 48}, {18, 54} }, 2):add(c:line({ {50, 26}, {55, 34}, {54, 48}, {46, 54} }, 2))
  C.part(c, cords, R.strap, { R = 1, b = -1 })
  local bi = C.vcyl(c, body, R.straw, 14, 50, { cuts = { .2, .36, .52, .7, .9 } })
  -- twill plait: diagonal steps per row
  body:each(function(x, y)
    local i = bi[K(x, y)]
    local row = y % 4
    if row == 3 then c:put(x, y, R.straw[math.max(1, i - 2)])
    elseif ((x + (y // 4) * 2) % 6) < 2 then c:put(x, y, R.straw[math.min(6, i + 1)]) end
  end)
  -- marigold-dyed band
  body:each(function(x, y)
    if y >= 36 and y <= 42 then
      local i = bi[K(x, y)]
      local row = y % 4
      local t = math.max(1, math.min(6, i - 1 + ((row == 3) and -1 or 0) + (((x + (y // 4) * 2) % 6 < 2) and 1 or 0)))
      c:put(x, y, R.marig[t])
    end
  end)
  -- dark zig-zag inside the band
  for x = 15, 49 do local y = 39 + ((x % 4 < 2) and 0 or 1) if body:has(x, y) then c:put(x, y, R.cochi[2]) end end
  -- base rim
  C.hline(c, 19, 45, 58, R.straw[1])
  -- lid: conical dome
  local lid = c:ellipse(32, 21, 20, 4):add(c:poly{ {14, 21}, {50, 21}, {38, 11}, {26, 11} })
  C.sep(c, body, lid, R.straw[1])
  local li = C.part(c, lid, R.straw, { R = 3, b = 1 })
  lid:each(function(x, y) if (x - 32 + (y - 10) * 0) % 4 == 0 and y > 12 then c:put(x, y, R.straw[math.max(1, li[K(x, y)] - 1)]) end end)
  C.hline(c, 14, 50, 22, R.straw[2])
  local knob = c:ellipse(32, 9, 3, 2.5)
  C.part(c, knob, R.wood, { R = 1 })
  c:put(31, 8, R.wood[6])
  -- quirk: hummingbird perched on the lid (right): slim body, long beak, forked tail
  local hb = G.oval(45, 12, 4, 2, -0.6)
  local head = c:ellipse(42, 8, 2, 2)
  local tail = c:poly{ {47, 14}, {51, 20}, {49, 21}, {46, 15} }
  C.fill(c, tail, R.jade[2]) c:put(50, 20, R.jade[1])
  C.part(c, hb:copy():add(head), R.jade, { R = 2, b = 1 })
  C.put(c, { {42, 10}, {43, 11}, {44, 11}, {43, 10} }, R.cochi[4]) c:put(42, 10, R.cochi[5]) -- red throat
  C.put(c, { {39, 7}, {38, 6}, {37, 5}, {36, 4}, {35, 3} }, R.cacao[2]) -- long beak
  c:put(42, 7, C.ink) c:put(41, 6, R.jade[6])
  C.put(c, { {47, 10}, {48, 11}, {46, 11} }, R.jade[2]) -- folded wing
  C.put(c, { {44, 15}, {46, 16} }, R.cacao[1]) -- feet on the rim
  C.save(c, "backpack-3-palm-basket-pack")
end

---------------------------------------------------------------- 4 loom-cloth bundle + marigold in the knot
do
  local c = C.new("backpack-4-loom-cloth-bundle")
  local body = c:poly{ {10, 30}, {22, 22}, {42, 22}, {54, 30}, {56, 50}, {48, 58}, {16, 58}, {8, 50} }
  local earL = c:poly{ {22, 24}, {14, 10}, {20, 8}, {30, 20} }
  local earR = c:poly{ {34, 20}, {46, 6}, {51, 11}, {42, 24} }
  local knot = c:ellipse(32, 20, 6, 5)
  local bi = C.part(c, body, R.cochi, { R = 8, hs = .8 })
  -- woven stripes following the bulge
  body:each(function(x, y)
    local i = bi[K(x, y)]
    local s = y + math.floor(((x - 32) / 24) ^ 2 * 6)
    local u = s % 12
    if u == 0 or u == 1 then c:put(x, y, R.indigo[math.min(6, i + 1)])
    elseif u == 3 then c:put(x, y, R.cotton[math.min(6, i + 1)])
    elseif u == 7 and (x % 4 == 0 or x % 4 == 1) then c:put(x, y, R.maize[math.min(6, i + 1)])
    elseif u == 7 then c:put(x, y, R.cochi[math.max(1, i - 1)]) end
  end)
  -- folds converging on the knot
  for _, f in ipairs({ { {20, 30}, {28, 25} }, { {44, 30}, {36, 25} }, { {16, 44}, {27, 27} }, { {48, 42}, {38, 27} } }) do
    local l = c:line(f, 1)
    l:each(function(x, y) c:put(x, y, R.cochi[1]) c:put(x - 1, y, R.cochi[5]) end)
  end
  C.sep(c, earL:copy():add(earR), body, R.cochi[1])
  for _, e in ipairs({ earL, earR }) do
    local ei = C.part(c, e, R.cochi, { R = 2, b = 0 })
    e:each(function(x, y) if (x + y) % 8 == 0 then c:put(x, y, R.indigo[3]) end end)
  end
  C.sep(c, knot, body:copy():add(earL):add(earR), R.cochi[1])
  C.part(c, knot, R.cochi, { R = 3, b = 0 })
  C.put(c, { {29, 19}, {30, 18}, {32, 17}, {35, 19} }, R.cochi[2])
  -- fringe along the bottom hem
  for x = 17, 47, 2 do c:put(x, 58, R.cotton[4]) c:put(x, 59, R.cotton[3]) end
  -- quirk: marigold in the knot
  local fl = c:ellipse(37, 17, 3.5, 3.5)
  C.part(c, fl, R.marig, { R = 2, b = 1 })
  fl:each(function(x, y) if (x + y) % 2 == 0 then c:put(x, y, R.marig[math.min(6, 5)]) end end)
  C.put(c, { {37, 17}, {38, 18} }, R.marig[2]) c:put(36, 15, R.marig[6])
  C.put(c, { {40, 20}, {41, 21} }, R.jade[4]) c:put(42, 21, R.jade[3])
  C.save(c, "backpack-4-loom-cloth-bundle")
end

---------------------------------------------------------------- 5 dry-spell water pack (leather + two gourds)
do
  local c = C.new("backpack-5-dry-spell-water-pack")
  local function gourd(cx, b)
    local lo = c:ellipse(cx, 44, 7.5, 9)
    local hi = c:ellipse(cx, 28, 5, 5.5)
    local neck = c:rect(cx - 2, 18, cx + 2, 36)
    local g = lo:copy():add(hi):add(neck)
    C.part(c, g, R.maize, { R = 6, hs = .7, b = b })
    for y = 18, 52 do if g:has(cx, y) and y % 3 == 0 then c:put(cx + 2, y, R.maize[2]) end end
    -- cork stopper
    local cork = c:rrect(cx - 2, 15, cx + 2, 19, 1)
    C.part(c, cork, R.cacao, { R = 1, b = 1 })
    -- tie at the waist
    C.hline(c, cx - 4, cx + 4, 34, R.strap[3]) C.hline(c, cx - 4, cx + 4, 35, R.strap[2])
    return g
  end
  local gl = gourd(13, 0)
  local gr = gourd(51, -1)
  local body = c:rrect(18, 18, 46, 56, 5)
  C.sep(c, body, gl:copy():add(gr), R.leather[1])
  local bi = C.part(c, body, R.leather, { R = 5 })
  -- side straps over the gourds
  for _, x in ipairs({ 8, 47 }) do
    for y = 40, 42 do C.hline(c, x, x + 9, y, R.strap[y == 40 and 5 or (y == 41 and 4 or 2)]) end
  end
  -- flap with tooled border
  local flap = c:poly{ {18, 19}, {46, 19}, {46, 32}, {32, 40}, {18, 32} }
  C.hline(c, 20, 44, 33, R.leather[2])
  C.part(c, flap, R.leather, { R = 3, b = 1 })
  flap:shrink(2):edge():each(function(x, y) if (x + y) % 2 == 0 then c:put(x, y, R.leather[3]) end end)
  -- tooled flower in the flap
  C.put(c, { {32, 26}, {30, 28}, {34, 28}, {32, 30}, {31, 27}, {33, 27}, {31, 29}, {33, 29} }, R.leather[3])
  c:put(32, 28, R.copper[5])
  -- copper clasp
  local clasp = c:rrect(30, 37, 34, 41, 1)
  C.part(c, clasp, R.copper, { R = 1 }) c:put(31, 38, R.copper[6])
  -- top handle
  local h = G.tube({ {24, 19}, {24, 10}, {40, 10}, {40, 19} }, function() return 1.4 end)
  C.sep(c, h, body, R.leather[1])
  h:cut(body)
  C.part(c, h, R.strap, { R = 1 })
  -- shine
  c:put(21, 22, R.leather[6]) c:put(22, 22, R.leather[6])
  -- quirk: little clay cup on a hook below the pack
  C.put(c, { {32, 57}, {32, 58} }, R.copper[3])
  local cup = c:poly{ {27, 59}, {37, 59}, {36, 63}, {28, 63} }
  C.part(c, cup, R.clay, { R = 1 })
  C.hline(c, 28, 36, 59, R.clay[2]) c:put(28, 60, R.clay[6])
  C.save(c, "backpack-5-dry-spell-water-pack")
end
