-- backpack.lua: Mistmoor (NWE) backpack concepts 1..5 (see concepts.md).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, G, R = C.HP, C.X, C.K, C.G, C.R
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local only = app.params.only

---------------------------------------------------------------- 1 peat creel
if not only or only == "1" then
  local c = C.new("backpack-1-peat-creel")
  -- peat bricks behind the rim
  local bricks = {
    { {13,8}, {25,5}, {27,13}, {15,15} }, { {24,4}, {37,3}, {37,13}, {25,13} },
    { {35,4}, {47,6}, {45,14}, {35,13} }, { {44,8}, {53,10}, {52,15}, {44,15} },
  }
  for i, q in ipairs(bricks) do
    local m = c:poly(q)
    local idx = C.lit(c, m, R.peat, { R = 2, b = (i % 2 == 0) and 1 or 0 })
    C.speckle(c, m, idx, R.peat, 0.18, i)
    m:edge():each(function(x, y) if not m:has(x + 1, y) or not m:has(x, y + 1) then c:put(x, y, R.peat[1]) end end)
  end
  local body = c:poly{ {9,16}, {55,16}, {49,57}, {15,57} }
  -- weave: rows of 3 px, alternate cells, darker vertical stakes
  local idx = C.lit(c, body, R.wicker, { R = 6, hs = 0.6, cuts = { .2, .36, .52, .68, .86 } })
  C.retone(c, body, idx, R.wicker, function(x, y, i)
    local row = floor((y - 16) / 3)
    local cx = (x + ((row % 2) * 3)) % 6
    if (y - 16) % 3 == 2 then return -2 end
    if cx == 0 then return -2 end
    if cx == 1 or (cx == 2 and (y - 16) % 3 == 0) then return 1 end
  end)
  -- rim: thick twisted roll
  local rim = c:rrect(7, 14, 57, 20, 3)
  C.sep(c, rim, body, R.wicker[1])
  local ri = C.lit(c, rim, R.wicker, { R = 3, b = 1 })
  C.retone(c, rim, ri, R.wicker, function(x, y) if (x + y * 2) % 5 == 0 then return -2 elseif (x + y * 2) % 5 == 1 then return 1 end end)
  C.hline(c, 10, 54, 21, R.wicker[1])
  -- base band
  for x = 15, 49 do if body:has(x, 53) then c:put(x, 53, R.wicker[2]) c:put(x, 54, R.wicker[4]) end end
  -- rope shoulder strap peeking out at the left
  C.rope(c, { {9,22}, {5,30}, {6,42}, {13,50} }, 2)
  -- quirk: a wren on the rim
  local wb = c:ellipse(46, 9, 4, 3):add(c:ellipse(43, 6, 2.4, 2.2))
  local tail = c:poly{ {48,9}, {50,1}, {52.5,2}, {51,10} }
  C.colour(c, wb:copy():add(tail):grow(1):cut(wb):cut(tail):cut(rim), C.ink)
  C.lit(c, tail, R.wicker, { R = 1, b = -1 })
  C.lit(c, wb, R.wicker, { R = 2 })
  C.put(c, { {44,10}, {45,11}, {46,11}, {47,10} }, R.fleece[5])
  C.put(c, { {42,6} }, C.ink) c:put(41, 5, R.fleece[6])
  C.put(c, { {39,6}, {40,6} }, R.brass[2]) C.put(c, { {43,4}, {44,4} }, R.wicker[2])
  C.put(c, { {47,8}, {48,9}, {49,8} }, R.wicker[2])
  C.put(c, { {45,13}, {47,13} }, R.peat[1])
  C.save(c, "backpack-1-peat-creel")
end

---------------------------------------------------------------- 2 waxed roll-top
if not only or only == "2" then
  local c = C.new("backpack-2-waxed-roll-top")
  local body = c:poly{ {18,20}, {46,20}, {48,40}, {47,56}, {17,56}, {16,40} }:add(c:rrect(16, 44, 48, 58, 6))
  local idx = C.vcyl(c, body, R.wax, 15, 49, { cuts = { .2, .36, .52, .7, .88 } })
  -- creases below the roll
  for _, x in ipairs({ 22, 30, 39 }) do
    for y = 21, 27 do if body:has(x, y) then c:put(x, y, R.wax[2]) c:put(x - 1, y, R.wax[5]) end end
  end
  -- waxed sheen streak
  C.vline(c, 20, 30, 52, R.wax[6]) C.vline(c, 21, 34, 46, R.wax[5])
  -- front leather strap down the middle with a brass buckle
  local strap = c:rect(30, 16, 34, 52)
  C.vcyl(c, strap, R.leather, 30, 34)
  C.vline(c, 30, 16, 52, R.leather[5])
  for y = 30, 50, 4 do c:put(32, y, R.leather[2]) end
  local bk = c:rect(28, 36, 36, 41)
  C.lit(c, bk, R.brass, { R = 1 })
  C.colour(c, c:rect(30, 38, 34, 39), R.leather[3])
  C.hline(c, 28, 35, 36, R.brass[6]) C.hline(c, 29, 36, 41, R.brass[2]) C.vline(c, 36, 37, 41, R.brass[2])
  c:put(29, 37, C.cream)
  -- roll top: horizontal cylinder with fold lines
  local rm, rn = X.cyl(13, 15, 51, 15, function() return 4.5 end)
  C.sep(c, rm, body, R.wax[1])
  local ri = C.toneN(c, rm, rn, R.wax, { cuts = { .2, .36, .52, .7, .88 } })
  for _, x in ipairs({ 19, 26, 38, 45 }) do for y = 11, 19 do if rm:has(x, y) then c:put(x, y, R.wax[2]) end end end
  C.hline(c, 15, 49, 12, R.wax[6])
  -- the roll ends fold up into a handle arc closed by a clip
  local arcL = G.tube({ {14,13}, {11,4}, {22,1}, {29,3} }, function() return 2.2 end)
  local arcR = G.tube({ {50,13}, {53,4}, {42,1}, {35,3} }, function() return 2.2 end)
  C.colour(c, arcL:copy():add(arcR):grow(1):cut(arcL):cut(arcR):cut(rm), C.ink)
  C.lit(c, arcL, R.wax, { R = 1 }) C.lit(c, arcR, R.wax, { R = 1, b = -1 })
  local clip = c:rrect(28, 0, 36, 5, 1)
  C.colour(c, clip:copy():grow(1):cut(clip), C.ink)
  C.lit(c, clip, R.leather, { R = 1 })
  C.vline(c, 32, 1, 4, R.leather[1]) C.hline(c, 29, 35, 1, R.leather[6])
  -- quirk: rain beads on the waxed cloth
  for _, p in ipairs({ {24,30}, {41,27}, {26,46}, {42,47}, {38,22} }) do
    local x, y = p[1], p[2]
    c:put(x, y, R.water[5]) c:put(x, y + 1, R.water[3]) c:put(x - 1, y + 1, R.water[4]) c:put(x + 1, y + 1, R.water[2])
    c:put(x, y - 1, R.water[4]) c:put(x - 1, y, C.cream)
  end
  C.save(c, "backpack-2-waxed-roll-top")
end

---------------------------------------------------------------- 3 heather frame
if not only or only == "3" then
  local c = C.new("backpack-3-heather-frame")
  -- frame: two poles + crossbars (behind and in front of the bundle)
  local poleL = c:rect(12, 6, 15, 60)
  local poleR = c:rect(48, 6, 51, 60)
  local barTop = c:rect(12, 8, 51, 10)
  local barBot = c:rect(12, 52, 51, 54)
  local frame = poleL:copy():add(poleR):add(barTop):add(barBot)
  C.vcyl(c, poleL, R.wood, 12, 15, { bias = C.bmap(poleL, -1) })
  C.vcyl(c, poleR, R.wood, 48, 51, { bias = C.bmap(poleR, -1) })
  C.lit(c, barTop, R.wood, { R = 1, b = -1 }) C.lit(c, barBot, R.wood, { R = 1, b = -1 })
  C.sep(c, barTop, poleL:copy():add(poleR), R.wood[1])
  -- sticks poking out of the bundle
  for _, s in ipairs({ { {20,40}, {6,22} }, { {44,38}, {58,18} } }) do
    local m = c:line(s, 2)
    m:each(function(x, y) c:put(x, y, ((x + y) % 2 == 0) and R.wood[3] or R.wood[2]) end)
  end
  -- heather bundle: stems lower part, bloom upper part
  local bundle = c:ellipse(32, 31, 17, 15)
  C.sep(c, bundle, frame, R.wood[1])
  local bloom = bundle:copy():clip(c:rect(0, 0, 64, 31))
  local stems = bundle:copy():cut(bloom)
  local si = C.lit(c, stems, R.wicker, { R = 4, b = -1 })
  C.retone(c, stems, si, R.wicker, function(x, y) if (x * 3 + floor(y / 3)) % 4 == 0 then return -2 elseif x % 4 == 1 then return 1 end end)
  local bi = C.lit(c, bloom, R.heather, { R = 5, hs = 0.8, cuts = { .2, .36, .52, .68, .84 } })
  C.retone(c, bloom, bi, R.heather, function(x, y)
    local h = X.hash(x, y, 7)
    if h < 0.22 then return -1 elseif h > 0.8 then return 1 end
  end)
  -- bumpy blossom top
  for _, p in ipairs({ {20,17}, {27,15}, {34,14}, {41,16}, {46,21} }) do
    local m = c:ellipse(p[1], p[2], 3, 2.2)
    m:cut(bundle)
    C.lit(c, m, R.heather, { R = 1, b = 1 })
  end
  -- green sprigs between bloom and stems
  for x = 17, 47 do if bundle:has(x, 31) and X.hash(x, 31, 2) < .6 then c:put(x, 31, R.moss[2]) c:put(x, 30, R.moss[3]) end end
  -- rope lashings: two bands + diagonal
  C.rope(c, { {14,24}, {50,24} }, 2)
  C.rope(c, { {14,38}, {50,38} }, 2)
  -- front crossbar over the bundle
  local barMid = c:rect(12, 44, 51, 46)
  C.sep(c, barMid, bundle, R.wicker[1])
  C.lit(c, barMid, R.wood, { R = 1 })
  C.hline(c, 13, 50, 44, R.wood[5])
  -- rope knots on the poles
  for _, p in ipairs({ {13,24}, {50,24}, {13,38}, {50,38} }) do C.put(c, { {p[1],p[2]}, {p[1],p[2]+1} }, R.rope[2]) end
  -- quirk: bumblebee at the blossom
  local bee = c:ellipse(53, 12, 2.6, 2)
  C.colour(c, bee:copy():grow(1):cut(bee), C.ink)
  C.lit(c, bee, R.brass, { R = 1 })
  C.vline(c, 53, 10, 14, R.peat[1]) C.vline(c, 55, 11, 13, R.peat[1])
  C.put(c, { {52,8}, {53,8}, {54,9}, {51,9} }, "#c4e0ee")
  C.put(c, { {52,9} }, R.steel[6])
  C.save(c, "backpack-3-heather-frame")
end

---------------------------------------------------------------- 4 bark box pack
if not only or only == "4" then
  local c = C.new("backpack-4-bark-box-pack")
  local box = c:rect(13, 20, 51, 57)
  local lid = c:rrect(10, 12, 54, 22, 2)
  local loopL = c:line({ {16,13}, {14,6}, {20,5}, {22,13} }, 2)
  C.colour(c, loopL, R.strap[3]) loopL:each(function(x, y) if y < 7 then c:put(x, y, R.strap[5]) end end)
  local function weaveTone(m, b, cuts)
    local bias = C.bmap(m, b)
    m:each(function(x, y) local a, d = floor((x - 13) / 5), floor((y - 20) / 5) if (a + d) % 2 == 0 then bias[K(x, y)] = bias[K(x, y)] - 1 end end)
    local idx = C.lit(c, m, R.birch, { R = 4, bias = bias, cuts = cuts or { .18, .32, .48, .64, .82 } })
    m:each(function(x, y)
      local a, d = (x - 13) % 5, (y - 20) % 5
      local cell = (floor((x - 13) / 5) + floor((y - 20) / 5)) % 2
      if (cell == 0 and d == 0) or (cell == 1 and a == 0) then c:put(x, y, R.birch[max(1, idx[K(x, y)] - 2)]) end
      if X.hash(x, y, 11) < 0.045 and m:has(x + 2, y) then c:put(x, y, R.birch[1]) c:put(x + 1, y, R.birch[1]) c:put(x + 2, y, R.birch[2]) end
    end)
    return idx
  end
  weaveTone(box, -1)
  -- leather corner bindings
  for _, xx in ipairs({ 13, 49 }) do
    local cb = c:rect(xx, 22, xx + 2, 57)
    C.vcyl(c, cb, R.strap, xx, xx + 2)
  end
  C.hline(c, 13, 51, 55, R.strap[3]) C.hline(c, 13, 51, 56, R.strap[2]) C.hline(c, 13, 51, 57, R.strap[1])
  C.sep(c, lid, box, R.birch[1])
  weaveTone(lid, 1, { .2, .34, .5, .66, .84 })
  C.hline(c, 11, 53, 22, R.strap[2]) C.hline(c, 11, 53, 21, R.strap[4])
  C.hline(c, 13, 51, 23, R.birch[1])
  -- carved wooden peg latch
  local latch = c:rect(30, 21, 34, 28)
  C.lit(c, latch, R.wood, { R = 1 })
  C.hline(c, 30, 34, 21, R.wood[6]) C.put(c, { {32,25}, {32,26} }, R.wood[1])
  -- quirk: rowan berries tied to the lid corner, with two leaves
  local tie = c:line({ {46,13}, {48,17} }, 1)
  C.colour(c, tie, R.rope[4])
  local l1 = G.blade(47, 15, 52, 9, 58, 8, function(t) return 1.8 * math.sin(math.pi * t) end)
  C.colour(c, l1:copy():grow(1):cut(l1):cut(lid), C.ink)
  C.lit(c, l1, R.moss, { R = 1 })
  for _, p in ipairs({ {47,19}, {51,20}, {49,23}, {53,23}, {46,23}, {50,26} }) do
    local m = c:ellipse(p[1], p[2], 1.8, 1.8)
    C.colour(c, m:copy():grow(1):cut(m), C.ink)
    C.lit(c, m, R.berry, { R = 1 })
    c:put(p[1] - 1, p[2] - 1, R.berry[6])
  end
  C.save(c, "backpack-4-bark-box-pack")
end

---------------------------------------------------------------- 5 fleece bundle
if not only or only == "5" then
  local c = C.new("backpack-5-fleece-bundle")
  -- knitting needles behind the bundle
  for _, s in ipairs({ { {36,30}, {50,4} }, { {38,30}, {56,8} } }) do
    local m = c:line(s, 2)
    m:each(function(x, y) c:put(x, y, ((x + y) % 2 == 0) and R.wood[5] or R.wood[3]) end)
  end
  for _, p in ipairs({ {50,3}, {56,7} }) do
    local m = c:ellipse(p[1], p[2], 1.6, 1.6)
    C.lit(c, m, R.berry, { R = 1 })
  end
  local fl = c:ellipse(32, 36, 22, 16)
  for _, p in ipairs({ {16,26,8,7}, {28,21,9,7}, {41,23,9,7}, {50,32,6,7}, {13,40,6,7}, {22,49,9,5}, {40,50,9,5} }) do
    fl:add(c:ellipse(p[1], p[2], p[3], p[4]))
  end
  local idx = C.lit(c, fl, R.fleece, { R = 6, hs = 0.8, cuts = { .18, .34, .5, .66, .84 } })
  -- curls: small c-shaped arcs
  fl:each(function(x, y)
    local gx, gy = (x + ((floor(y / 4) % 2) * 2)) % 4, y % 4
    if gx == 0 and gy == 1 or gx == 1 and gy == 2 then
      c:put(x, y, R.fleece[max(1, idx[K(x, y)] - 2)])
    elseif gx == 1 and gy == 0 and idx[K(x, y)] < 6 then
      c:put(x, y, R.fleece[idx[K(x, y)] + 1])
    end
  end)
  -- lumpy creases: lower-right rim of each tuft
  for _, p in ipairs({ {16,26,8,7}, {28,21,9,7}, {41,23,9,7}, {13,40,6,7}, {32,36,13,9} }) do
    local m = c:ellipse(p[1], p[2], p[3], p[4])
    m:edge():each(function(x, y)
      if fl:shrink(1):has(x, y) and (x - p[1]) / p[3] + (y - p[2]) / p[4] > 0.6 then c:put(x, y, R.fleece[2]) end
      if fl:shrink(1):has(x, y) and (x - p[1]) / p[3] + (y - p[2]) / p[4] < -0.9 then c:put(x, y, R.fleece[6]) end
    end)
  end
  -- rope cross
  local function rp(pts, w) local m = c:line(pts, w) m:grow(1):cut(m):clip(fl):each(function(x, y) c:put(x, y, R.peat[3]) end) C.rope(c, pts, w, R.wicker) end
  rp({ {14,22}, {48,52} }, 3)
  rp({ {50,20}, {16,52} }, 3)
  rp({ {10,36}, {54,36} }, 2)
  local knot = c:ellipse(32, 36, 3, 2.5)
  C.lit(c, knot, R.wicker, { R = 1 })
  C.put(c, { {31,35}, {32,35} }, R.wicker[6])
  -- quirk: blue yarn ball at the lower right
  local yb = c:ellipse(51, 49, 5, 5)
  C.colour(c, yb:copy():grow(1):cut(yb), C.ink)
  local yi = C.lit(c, yb, R.woad, { R = 3 })
  C.retone(c, yb, yi, R.woad, function(x, y) if (x + y) % 3 == 0 then return -1 end end)
  c:line({ {48,46}, {54,52} }, 1):each(function(x, y) c:put(x, y, R.woad[2]) end)
  c:line({ {47,52}, {46,56}, {42,57} }, 1):each(function(x, y) if not yb:has(x, y) then c:put(x, y, R.woad[4]) end end)
  c:put(49, 46, R.woad[6])
  C.save(c, "backpack-5-fleece-bundle")
end
