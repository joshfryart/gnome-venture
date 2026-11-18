-- backpack.lua: SEA "Monsoon Tangle" backpack concepts 1..5 (see concepts.md).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local floor, sin, cos, rad, max, min, abs = math.floor, math.sin, math.cos, math.rad, math.max, math.min, math.abs

-- leather shoulder loop on the left side (behind the body)
local function loop(c, ramp, pts, w)
  local m, n = G.tube(pts, function() return w or 1.8 end)
  return m, n
end

---------------------------------------------------------------- 1 rattan back-basket
do
  local c = C.canvas("backpack-1-rattan-back-basket")
  local body = c:poly{ {15,16}, {49,16}, {44,54}, {20,54} }:add(c:rrect(19, 46, 45, 56, 5))
  local rim = c:rrect(13, 12, 51, 18, 3)
  local foot = c:rrect(21, 54, 43, 58, 2)
  C.lit(c, foot, R.wood, -1, { R = 1 })
  C.sep(c, body, foot, R.wood[1])
  local bi = C.vcyl(c, body, R.rattan, 15, 49, { cuts = { .2, .36, .52, .7, .88 } })
  C.retone(c, body, bi, R.rattan, function(x, y)
    if x % 5 == 0 then return -2 end
    if y % 3 == 2 then return -1 end
    if (x // 5 + y // 3) % 2 == 0 and x % 5 == 2 then return 1 end
  end)
  -- dyed band with zigzag
  for x = 15, 49 do for y = 33, 38 do
    if body:has(x, y) then
      local i = bi[K(x, y)] or 3
      local z = 35 + abs((x % 6) - 3) - 1
      c:put(x, y, (y == z or y == z + 1) and R.lining[min(6, i + 1)] or R.soga[i])
    end
  end end
  -- rambutans peeking over the rim
  for _, p in ipairs({ { 25, 10, 4 }, { 34, 8, 4.5 }, { 42, 11, 3.6 } }) do
    local f = c:ellipse(p[1], p[2], p[3], p[3])
    C.lit(c, f, R.hibis, 0, { R = 2 })
    f:edge():each(function(x, y) if X.hash(x, y, 3) < 0.45 then c:put(x, y, y < p[2] and R.gecko[5] or R.hibis[2]) end end)
    f:grow(1):cut(f):each(function(x, y) if y < p[2] and X.hash(x, y, 9) < 0.4 and not rim:has(x, y) then c:put(x, y, R.gecko[4]) end end)
    c:put(p[1] - 2, p[2] - 2, R.hibis[6]) c:put(p[1] - 1, p[2] - 2, C.cream)
  end
  -- wrapped rim
  C.lit(c, rim, R.rattan, 1, { R = 2 })
  rim:each(function(x, y) if (x + y) % 3 == 0 then c:put(x, y, R.rattan[3]) end end)
  C.hline(c, 15, 49, 18, R.rattan[1])
  C.hline(c, 15, 48, 13, R.rattan[6])
  -- two leather shoulder straps down the carrying face, brass rivets
  for _, sx in ipairs({ 21, 39 }) do
    local st = c:poly{ {sx,19}, {sx+4,19}, {sx+3+(sx<32 and 1 or -1),50}, {sx-1+(sx<32 and 1 or -1),50} }
    C.sep(c, st, body, R.rattan[1])
    st:shift(1, 0):cut(st):clip(body):each(function(x, y) c:put(x, y, R.rattan[1]) end)
    C.lit(c, st, R.strap, sx < 32 and 0 or -1, { R = 1 })
    st:each(function(x, y) if not st:has(x - 1, y) then c:put(x, y, R.strap[sx < 32 and 5 or 4]) end end)
    c:put(sx + 2, 21, R.brass[5]) c:put(sx + 2, 48, R.brass[4])
  end
  c:put(17, 22, R.rattan[6]) c:put(18, 22, C.cream)
  C.save(c, "backpack-1-rattan-back-basket")
end

---------------------------------------------------------------- 2 bamboo ladder-pack
do
  local c = C.canvas("backpack-2-bamboo-ladder-pack")
  local function bamboo(x0, y0, x1, y1, bias)
    local m = c:rect(x0, y0, x1, y1)
    local vert = (y1 - y0) > (x1 - x0)
    local idx
    if vert then idx = C.vcyl(c, m, R.pandan, x0, x1 + 1, { bias = C.bmap(m, bias) })
    else
      local _, n = X.cyl(x0, (y0 + y1) / 2, x1, (y0 + y1) / 2, function() return (y1 - y0) / 2 + .5 end, m)
      idx = C.toneN(c, m, n, R.pandan, { bias = C.bmap(m, bias) })
    end
    -- nodes
    if vert then for y = y0 + 6, y1 - 2, 11 do C.hline(c, x0, x1, y, R.pandan[1]) C.hline(c, x0, x1, y + 1, R.pandan[5]) end
    else for x = x0 + 5, x1 - 2, 12 do C.vline(c, x, y0, y1, R.pandan[1]) C.vline(c, x + 1, y0, y1, R.pandan[5]) end end
    return m
  end
  local pl = bamboo(13, 3, 17, 60, 0)
  local pr = bamboo(45, 3, 49, 60, -1)
  local bars = {}
  for i, y in ipairs({ 9, 32, 54 }) do
    local m = c:rect(10, y, 52, y + 3)
    C.sep(c, m, pl:copy():add(pr), R.pandan[1])
    bamboo(10, y, 52, y + 3, 0)
    bars[i] = m
  end
  -- indigo sack lashed between the poles
  local sack = c:rrect(18, 22, 44, 52, 7):add(c:poly{ {24,22}, {27,17}, {35,17}, {38,22} })
  local all = pl:copy():add(pr)
  for _, b in ipairs(bars) do all:add(b) end
  C.sep(c, sack, all, C.ink)
  local si = C.lit(c, sack, R.indigo, 1, { R = 5, cuts = { .2, .36, .52, .7, .88 } })
  C.retone(c, sack, si, R.indigo, C.twill(4))
  for _, p in ipairs({ {27,24}, {28,30}, {30,36}, {31,42} }) do c:put(p[1], p[2], R.indigo[2]) end
  C.hline(c, 26, 36, 21, R.indigo[1])
  C.put(c, { {29,18}, {30,18}, {33,18} }, R.indigo[6])
  -- rolled pandan mat on top
  local mm, mn = X.cyl(10, 14, 52, 14, function() return 4.5 end)
  C.sep(c, mm, all:copy():add(sack), C.ink)
  local mi = C.toneN(c, mm, mn, R.straw, { cuts = { .2, .36, .52, .7, .88 } })
  C.retone(c, mm, mi, R.straw, function(x, y) if (x + (y % 2) * 2) % 4 == 0 then return -1 end end)
  local en = c:ellipse(10, 14, 2.5, 4.5)
  c:fillMask(en, R.straw[4])
  C.put(c, { {10,12}, {11,13}, {11,14}, {11,15}, {10,16}, {9,15}, {9,13} }, R.straw[2])
  c:put(10, 14, R.straw[1]) c:put(9, 11, R.straw[6])
  -- cord lashings
  local cords = c:line({ {20,24}, {42,40} }, 1):add(c:line({ {42,24}, {20,40} }, 1))
  cords:clip(sack):each(function(x, y) c:put(x, y, R.canvas[(x % 2 == 0) and 6 or 4]) end)
  for _, p in ipairs({ { 15, 14 }, { 47, 14 }, { 15, 33 }, { 47, 33 } }) do
    for dy = -2, 2, 2 do C.hline(c, p[1] - 2, p[1] + 2, p[2] + dy, R.canvas[(dy < 0) and 6 or 4]) end
  end
  -- quirk: coconut-shell cup on a cord
  local cord = c:line({ { 51, 36 }, { 54, 41 } }, 1)
  cord:each(function(x, y) c:put(x, y, R.canvas[3]) end)
  local cup = c:ellipse(55, 46, 5, 4):cut(c:rect(0, 0, 63, 44))
  local rimc = c:rect(50, 43, 60, 44)
  C.lit(c, cup, R.wood, 0, { R = 2 })
  cup:each(function(x, y) if X.hash(x, y, 4) < 0.25 then c:put(x, y, R.wood[2]) end end)
  c:fillMask(rimc, R.wood[1]) C.hline(c, 51, 59, 43, R.wood[5]) c:put(51, 43, R.petal[5])
  c:put(52, 46, R.wood[6])
  C.save(c, "backpack-2-bamboo-ladder-pack")
end

---------------------------------------------------------------- 3 batik bundle
do
  local c = C.canvas("backpack-3-batik-bundle")
  local body = c:ellipse(32, 39, 21, 17)
  local earL = c:poly{ {21,27}, {12,12}, {19,13}, {30,25} }
  local earR = c:poly{ {35,25}, {45,10}, {52,13}, {43,27} }
  local knot = c:ellipse(32, 25, 6, 4.5)
  local strap = c:poly{ {13,30}, {17,26}, {52,47}, {49,51} }
  local function pattern(m, idx, phase)
    C.motif(c, m, idx, R.wax, function(x, y)
      local a, b = (x + y + phase) % 8, (x - y + 64 + phase) % 8
      if a == 0 and b == 0 then return true end
      for base = 27, 60, 9 do if y == base + floor(1.6 * sin(x / 2.2) + .5) then return true end end
    end, -1)
  end
  local bi = C.lit(c, body, R.indigo, 0, { R = 7, cuts = { .2, .36, .52, .7, .88 } })
  pattern(body, bi, 0)
  -- gather folds radiating from the knot
  for _, f in ipairs({ { 26, 30, 20, 44 }, { 32, 30, 31, 47 }, { 38, 30, 45, 43 } }) do
    c:line({ { f[1], f[2] }, { f[3], f[4] } }, 1):clip(body):each(function(x, y) c:put(x, y, R.indigo[max(1, (bi[K(x, y)] or 3) - 2)]) end)
    c:line({ { f[1] - 1, f[2] }, { f[3] - 1, f[4] } }, 1):clip(body):each(function(x, y) c:put(x, y, R.indigo[min(6, (bi[K(x, y)] or 3) + 1)]) end)
  end
  -- rust carrying sling across the front
  strap:clip(body)
  strap:shift(0, 1):cut(strap):clip(body):each(function(x, y) c:put(x, y, R.indigo[1]) end)
  C.lit(c, strap, R.yarnA, 0, { R = 1 })
  strap:each(function(x, y) if not strap:has(x, y - 1) then c:put(x, y, R.yarnA[5]) end end)
  strap:each(function(x, y) if (x - y) % 5 == 0 and strap:has(x, y - 1) and strap:has(x, y + 1) then c:put(x, y, R.lining[5]) end end)
  for _, e in ipairs({ earL, earR }) do
    C.sep(c, e, body, R.indigo[1])
    local ei = C.lit(c, e, R.indigo, 1, { R = 2 })
    e:edge():each(function(x, y) if (x + y) % 2 == 0 then c:put(x, y, R.wax[4]) end end)
  end
  C.sep(c, knot, body:copy():add(earL):add(earR), R.indigo[1])
  local ki = C.lit(c, knot, R.indigo, 1, { R = 3 })
  C.put(c, { {30,23}, {31,22}, {33,22}, {35,24} }, R.indigo[2])
  pattern(knot, ki, 3)
  -- quirk: orchid tucked in the knot
  local lf = c:poly{ {35,26}, {42,24}, {44,22}, {39,27} }
  C.lit(c, lf, R.leaf, 0, { R = 1 })
  local fl = c:ellipse(37, 21, 3.5, 3.5)
  C.sep(c, fl, knot:copy():add(earR), C.ink)
  C.flower(c, 37, 21, R.orchid, R.brass[5])
  c:put(37, 22, R.orchid[2]) c:put(38, 22, R.hibis[5])
  C.save(c, "backpack-3-batik-bundle")
end

---------------------------------------------------------------- 4 nipa thatch pack
do
  local c = C.canvas("backpack-4-nipa-thatch-pack")
  local base = c:rrect(16, 48, 48, 57, 3)
  C.lit(c, base, R.wood, -1, { R = 2 })
  for x = 17, 47, 3 do C.vline(c, x, 50, 56, R.wood[2]) end
  local tiers = {}
  for i = 4, 1, -1 do
    local y0, hw = 4 + i * 10, 6 + i * 5
    local pts = { { 32 - hw + 3, y0 } , { 32 + hw - 3, y0 } }
    local yb = y0 + 13
    local n = floor(hw * 2 / 4)
    for j = n, 0, -1 do
      local x = 32 - hw + j * (hw * 2 / n)
      pts[#pts + 1] = { x, yb + ((j % 2 == 0) and 0 or -3) }
    end
    local m = c:poly(pts)
    tiers[i] = m
  end
  local tc = { R.straw, R.pandan, R.straw, R.pandan }
  for i = 4, 1, -1 do
    local m = tiers[i]
    local under = HP.mask()
    for j = i + 1, 4 do under:add(tiers[j]) end
    under:add(base)
    C.sep(c, m, under, R.straw[1])
    m:shift(0, 1):cut(m):clip(under):each(function(x, y) c:put(x, y, R.straw[1]) end)
    local ti = C.lit(c, m, tc[i], 0, { R = 2, cuts = { .2, .36, .52, .7, .88 } })
    C.retone(c, m, ti, tc[i], function(x, y) if x % 2 == 0 and X.hash(x, y, i) < 0.7 then return -1 end end)
    local x0, y0 = m:bbox()
    C.hline(c, x0 + 1, 64 - x0 - 2, y0, tc[i][6])
  end
  -- top knot: tuft bound with cord, wooden toggle
  local tuft = c:poly{ {28,14}, {30,6}, {32,3}, {34,6}, {36,14} }
  C.sep(c, tuft, tiers[1], R.straw[1])
  local tfi = C.lit(c, tuft, R.straw, 1, { R = 1 })
  C.vline(c, 32, 5, 12, R.straw[2])
  C.hline(c, 29, 35, 11, R.strap[2]) C.hline(c, 29, 35, 12, R.strap[4])
  -- quirk: snail crawling over the roof
  local shell = c:ellipse(44, 26, 3.5, 3.5)
  local foot = c:poly{ {37,30}, {49,29}, {51,26}, {52,30}, {38,31} }
  local sn = shell:copy():add(foot)
  C.sep(c, sn, tiers[2]:copy():add(tiers[3]), C.ink)
  C.lit(c, foot, R.sage, 1, { R = 1 })
  C.put(c, { {51,24}, {51,25}, {53,24}, {52,25} }, R.sage[4])
  c:put(51, 23, R.sage[2]) c:put(53, 23, R.sage[2])
  C.lit(c, shell, R.clay, 1, { R = 2 })
  C.put(c, { {44,24}, {45,25}, {45,26}, {44,27}, {43,27}, {42,26}, {43,25} }, R.clay[2])
  c:put(44, 26, R.clay[1]) c:put(42, 23, R.clay[6])
  C.save(c, "backpack-4-nipa-thatch-pack")
end

---------------------------------------------------------------- 5 water-jar pack
do
  local c = C.canvas("backpack-5-water-jar-pack")
  local jar = c:ellipse(32, 37, 15, 17):add(c:rrect(25, 16, 39, 26, 4))
  local lip = c:rrect(23, 13, 41, 18, 2)
  local cork = c:rrect(27, 8, 37, 13, 2)
  local foot = c:rrect(22, 52, 42, 57, 2)
  C.lit(c, foot, R.clay, -1, { R = 1 })
  C.sep(c, jar, foot, R.clay[1])
  local ji = C.lit(c, jar, R.jade, 0, { R = 8, cuts = { .2, .36, .52, .7, .86 } })
  -- unglazed clay band at the bottom with drips
  jar:each(function(x, y) if y > 49 and (y > 51 or x % 5 == 0 or x % 7 == 3) then c:put(x, y, R.clay[max(1, (ji[K(x, y)] or 3) - 1)]) end end)
  -- rope net
  jar:each(function(x, y)
    if y > 26 and y < 50 then
      local a, b = (x + y) % 7, (x - y + 70) % 7
      if a == 0 and b == 0 then c:put(x, y, R.canvas[6])
      elseif a == 0 or b == 0 then c:put(x, y, R.canvas[max(2, min(6, (ji[K(x, y)] or 3)))]) end
    end
  end)
  jar:each(function(x, y) if y == 26 then c:put(x, y, R.canvas[5]) elseif y == 27 then c:put(x, y, R.canvas[2]) end end)
  -- canvas shoulder straps over the front
  for _, sx in ipairs({ 22, 38 }) do
    local st = c:poly{ {sx,17}, {sx+4,17}, {sx+4+(sx<32 and -3 or 3),52}, {sx+(sx<32 and -3 or 3),52} }:clip(jar:copy():add(lip))
    st:shift(1, 0):cut(st):clip(jar):each(function(x, y) c:put(x, y, R.jade[1]) end)
    C.lit(c, st, R.canvas, sx < 32 and 1 or 0, { R = 1 })
    st:each(function(x, y) if not st:has(x - 1, y) then c:put(x, y, R.canvas[6]) end end)
    st:each(function(x, y) if y % 4 == 0 and st:has(x - 1, y) and st:has(x + 1, y) then c:put(x, y, R.canvas[3]) end end)
  end
  -- glaze highlight
  C.put(c, { {20,32}, {20,33}, {21,30}, {20,34}, {20,35} }, R.jade[6]) c:put(21, 31, C.cream)
  -- lip and cork
  C.sep(c, lip, jar, R.jade[1])
  C.lit(c, lip, R.jade, 1, { R = 2 })
  C.hline(c, 24, 40, 18, R.jade[1])
  C.sep(c, cork, lip, R.jade[1])
  C.lit(c, cork, R.wood, 1, { R = 2 })
  C.put(c, { {30,10}, {33,11}, {35,9} }, R.wood[3])
  -- bamboo tap low on the right, with a drop
  local tap = c:rect(46, 42, 52, 44)
  C.sep(c, tap, jar, C.ink)
  C.lit(c, tap, R.pandan, 0, { R = 1 })
  c:fillMask(c:rect(49, 40, 50, 41), R.wood[4])
  c:put(49, 40, R.wood[6])
  local drop = c:poly{ {52.5,46}, {54,49}, {53.5,51}, {51.5,51}, {51,49} }
  C.lit(c, drop, R.water, 0, { R = 1 })
  c:put(52, 49, R.water[6])
  -- quirk: sprout from the cork
  C.vline(c, 32, 3, 7, R.leaf[3]) C.vline(c, 33, 5, 7, R.leaf[2])
  local l1 = c:ellipse(29, 3, 3, 1.6)
  local l2 = c:ellipse(36, 2, 3, 1.6)
  C.lit(c, l1, R.leaf, 1, { R = 1 }) C.lit(c, l2, R.leaf, 0, { R = 1 })
  c:put(28, 2, R.leaf[6]) c:put(35, 1, R.leaf[6])
  C.save(c, "backpack-5-water-jar-pack")
end
