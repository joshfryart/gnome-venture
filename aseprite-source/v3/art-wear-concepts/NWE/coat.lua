-- coat.lua: Mistmoor (NWE) coat concepts 1..5 (see concepts.md).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, G, R = C.HP, C.X, C.K, C.G, C.R
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local only = app.params.only

-- a pair of sleeves as tubes; returns left, right masks (painted by caller)
local function sleeves(sh, mid, cuff, w)
  local L = G.tube({ { sh[1], sh[2] }, { mid[1], mid[2] }, { cuff[1], cuff[2] - 6 }, { cuff[1], cuff[2] } }, w)
  local Rm = G.tube({ { 64 - sh[1], sh[2] }, { 64 - mid[1], mid[2] }, { 64 - cuff[1], cuff[2] - 6 }, { 64 - cuff[1], cuff[2] } }, w)
  return L, Rm
end

---------------------------------------------------------------- 1 cable-knit long coat
if not only or only == "1" then
  local c = C.new("coat-1-cable-knit-long-coat")
  local torso = c:poly{ {20,9}, {44,9}, {47,17}, {48,59}, {16,59}, {17,17} }
  local sL, sR = sleeves({ 20, 13 }, { 12, 22 }, { 10, 50 }, function(t) return 4.6 + t * 0.8 end)
  local bothS = sL:copy():add(sR)
  C.lit(c, sR, R.fleece, { R = 3, b = -1 })
  C.lit(c, sL, R.fleece, { R = 3 })
  -- ribbed cuffs
  for _, m in ipairs({ sL, sR }) do m:each(function(x, y) if y >= 46 and x % 2 == 0 then c:put(x, y, R.fleece[2]) end end) end
  C.sep(c, torso, bothS, R.fleece[1])
  local ti = C.lit(c, torso, R.fleece, { R = 5, cuts = { .2, .36, .52, .68, .86 } })
  -- cable columns
  for _, cx in ipairs({ 22, 41 }) do
    for y = 14, 54 do
      local ph = floor(y / 2) % 4
      local a = cx + ((ph == 1 or ph == 2) and 1 or 0)
      c:put(cx - 1, y, R.fleece[2]) c:put(cx + 3, y, R.fleece[2])
      c:put(a, y, R.fleece[6]) c:put(a + 1, y, R.fleece[4]) c:put(((a == cx) and cx + 2 or cx), y, R.fleece[3])
    end
  end
  -- moss-stitch texture between cables
  C.retone(c, torso, ti, R.fleece, function(x, y) if (x + y) % 2 == 0 and X.hash(x, y, 3) < .3 then return -1 end end)
  -- ribbed hem
  for x = 16, 48 do for y = 55, 59 do if torso:has(x, y) then c:put(x, y, (x % 2 == 0) and R.fleece[3] or R.fleece[4]) end end end
  -- open front: dark gap with tunic peeking
  c:line({ {32,26}, {32,58} }, 1):each(function(x, y) c:put(x, y, R.fleece[1]) c:put(x + 1, y, R.yarnB[3]) end)
  -- shawl collar rolls
  local colL = G.blade(21, 9, 24, 20, 32, 30, function(t) return 2.6 - t * 1.4 end)
  local colR = G.blade(43, 9, 40, 20, 33, 30, function(t) return 2.6 - t * 1.4 end)
  local neck = c:poly{ {24,9}, {40,9}, {33,28}, {31,28} }
  C.colour(c, neck, R.yarnB[2])
  neck:each(function(x, y) if y < 12 then c:put(x, y, R.yarnB[1]) end end)
  C.lit(c, colL, R.fleece, { R = 2, b = 1 }) C.lit(c, colR, R.fleece, { R = 2 })
  colR:edge():each(function(x, y) if x < 40 and y > 12 then c:put(x, y, R.fleece[2]) end end)
  -- wooden toggles with loops
  for _, y in ipairs({ 34, 42, 50 }) do
    c:line({ {29,y}, {35,y} }, 1):each(function(x, yy) c:put(x, yy, R.rope[2]) end)
    local tg = c:rrect(30, y - 2, 35, y - 1, 1)
    C.colour(c, tg, R.wood[4]) C.hline(c, 30, 35, y - 2, R.wood[6]) c:put(35, y - 1, R.wood[2])
  end
  -- pocket with the quirk: a little knitted fish patch
  local pk = c:rect(37, 44, 45, 53)
  C.lit(c, pk, R.fleece, { R = 2, b = 0 })
  C.hline(c, 37, 45, 44, R.fleece[6]) C.hline(c, 37, 45, 45, R.fleece[3])
  pk:edge():each(function(x, y) if y > 45 and (x == 45 or y == 53) then c:put(x, y, R.fleece[2]) end end)
  local fish = c:ellipse(40.5, 49, 2.6, 1.6):add(c:poly{ {42.5,49}, {45,47}, {45,51} })
  C.lit(c, fish, R.woad, { R = 1 })
  C.put(c, { {39,48} }, C.ink) C.put(c, { {40,47}, {41,47} }, R.woad[6])
  C.save(c, "coat-1-cable-knit-long-coat")
end

---------------------------------------------------------------- 2 waxed field jacket
if not only or only == "2" then
  local c = C.new("coat-2-waxed-field-jacket")
  local torso = c:poly{ {19,11}, {45,11}, {48,18}, {48,52}, {16,52}, {16,18} }
  local sL, sR = sleeves({ 19, 15 }, { 11, 24 }, { 9, 49 }, function(t) return 5.4 end)
  C.lit(c, sR, R.wax, { R = 3, b = -1 })
  C.lit(c, sL, R.wax, { R = 3 })
  -- corduroy cuffs
  for _, m in ipairs({ sL, sR }) do
    m:each(function(x, y) if y >= 46 then c:put(x, y, (x % 2 == 0) and R.felt[3] or R.felt[5]) end end)
  end
  C.sep(c, torso, sL:copy():add(sR), R.wax[1])
  local ti = C.lit(c, torso, R.wax, { R = 4, cuts = { .2, .36, .52, .7, .88 } })
  -- crinkle of the wax: soft speckle + sheen streaks
  C.speckle(c, torso, ti, R.wax, 0.06, 3)
  C.vline(c, 19, 20, 32, R.wax[6]) C.vline(c, 20, 24, 30, R.wax[5])
  c:line({ {12,22}, {10,30} }, 1):each(function(x, y) c:put(x, y, R.wax[6]) end)
  -- front placket with brass snaps
  C.vline(c, 32, 14, 52, R.wax[1]) C.vline(c, 33, 14, 52, R.wax[5])
  for y = 22, 46, 8 do c:put(34, y, R.brass[5]) c:put(35, y, R.brass[3]) c:put(34, y + 1, R.brass[2]) end
  -- bellows pockets with flaps
  for _, x0 in ipairs({ 18, 37 }) do
    local pk = c:rect(x0, 35, x0 + 10, 47)
    C.lit(c, pk, R.wax, { R = 2, b = (x0 > 30) and 0 or 1 })
    pk:edge():each(function(x, y) if x == x0 + 10 or y == 47 then c:put(x, y, R.wax[1]) end end)
    local fl = c:poly{ {x0 - 1, 32}, {x0 + 11, 32}, {x0 + 11, 37}, {x0 - 1, 37} }
    C.lit(c, fl, R.wax, { R = 1, b = 1 })
    C.hline(c, x0 - 1, x0 + 11, 38, R.wax[1])
    c:put(x0 + 5, 36, R.brass[5]) c:put(x0 + 6, 36, R.brass[3])
  end
  C.hline(c, 16, 48, 49, R.wax[2])
  -- brown corduroy collar
  local col = c:poly{ {20,5}, {44,5}, {46,13}, {39,16}, {32,12}, {25,16}, {18,13} }
  local ci = C.lit(c, col, R.felt, { R = 2, b = 1 })
  C.retone(c, col, ci, R.felt, function(x, y) if x % 2 == 0 then return -1 end end)
  local nk = c:poly{ {24,6}, {40,6}, {32,11} }
  C.colour(c, nk, R.felt[1])
  -- quirk: a bright fishing fly hooked on the collar
  C.put(c, { {42,9}, {43,8}, {44,8}, {44,9} }, R.berry[4])
  C.put(c, { {45,7}, {46,6}, {45,8} }, R.brass[5])
  C.put(c, { {41,10}, {41,11} }, R.yarnB[5])
  C.put(c, { {43,10}, {44,11}, {44,12} }, R.steel[5])
  c:put(43, 7, R.berry[6])
  C.save(c, "coat-2-waxed-field-jacket")
end

---------------------------------------------------------------- 3 tweed waistcoat
if not only or only == "3" then
  local c = C.new("coat-3-tweed-waistcoat")
  local hb = function(x, y, i) local p = (y + abs((x % 6) - 3)) % 3 if p == 0 then return -1 elseif p == 1 and X.hash(x, y, 2) < .4 then return 1 end end
  local vest = c:poly{ {19,6}, {26,6}, {32,26}, {38,6}, {45,6}, {50,13}, {50,48}, {41,55}, {33,50}, {31,50}, {23,55}, {14,48}, {14,13} }
  vest:cut(c:ellipse(12, 19, 5, 9)):cut(c:ellipse(52, 19, 5, 9))
  local back = c:poly{ {26,6}, {38,6}, {32,26} }
  C.colour(c, back, R.tweed[1])
  back:each(function(x, y) if y < 9 then c:put(x, y, R.felt[2]) end end)
  local vi = C.lit(c, vest, R.tweed, { R = 5, cuts = { .2, .36, .52, .68, .86 } })
  C.retone(c, vest, vi, R.tweed, hb)
  -- arm-hole binding and front edges
  vest:edge():each(function(x, y)
    if (x < 21 or x > 43) and y > 9 and y < 30 then c:put(x, y, R.tweed[(x < 32) and 5 or 2]) end
  end)
  c:line({ {32,26}, {32,50} }, 1):each(function(x, y) c:put(x, y, R.tweed[1]) end)
  c:line({ {26,7}, {32,25} }, 1):each(function(x, y) c:put(x, y, R.tweed[6]) end)
  c:line({ {38,7}, {33,25} }, 1):each(function(x, y) c:put(x, y, R.tweed[2]) end)
  -- brass buttons
  for _, y in ipairs({ 30, 36, 42, 48 }) do
    local b = c:ellipse(34.5, y, 1.4, 1.4)
    C.colour(c, b:copy():grow(1):cut(b), R.tweed[1])
    C.lit(c, b, R.brass, { R = 1 }) c:put(34, y - 1, R.brass[6])
  end
  -- welt pockets
  for _, x0 in ipairs({ 19, 38 }) do C.hline(c, x0, x0 + 6, 38, R.tweed[1]) C.hline(c, x0, x0 + 6, 37, R.tweed[5]) end
  -- quirk: an acorn peeking from the left pocket
  local nut = c:ellipse(22, 35, 2, 2.4)
  local cup = c:rrect(19, 31, 25, 34, 1)
  C.colour(c, nut:copy():add(cup):grow(1):cut(nut):cut(cup):cut(vest:copy():clip(c:rect(0, 37, 64, 64))), C.ink)
  C.lit(c, nut, R.leather, { R = 1 })
  local cpi = C.lit(c, cup, R.wicker, { R = 1, b = -1 })
  C.retone(c, cup, cpi, R.wicker, function(x, y) if (x + y) % 2 == 0 then return -1 end end)
  C.put(c, { {22,30}, {22,29}, {23,29} }, R.peat[3])
  c:put(21, 35, R.leather[6])
  C.hline(c, 19, 25, 38, R.tweed[1])
  C.save(c, "coat-3-tweed-waistcoat")
end

---------------------------------------------------------------- 4 tanbark smock
if not only or only == "4" then
  local c = C.new("coat-4-tanbark-smock")
  local torso = c:poly{ {22,9}, {42,9}, {46,16}, {51,56}, {13,56}, {18,16} }
  local sL, sR = sleeves({ 20, 14 }, { 10, 22 }, { 8, 40 }, function(t) return 4.5 + t * 3 end)
  C.lit(c, sR, R.tanbark, { R = 3, b = -1 })
  C.lit(c, sL, R.tanbark, { R = 3 })
  -- gathered cuffs: dark band with pleats
  for _, m in ipairs({ sL, sR }) do
    m:each(function(x, y) if y >= 39 then c:put(x, y, R.tanbark[(x % 3 == 0) and 1 or 2]) end end)
    m:each(function(x, y) if y >= 30 and y < 39 and x % 4 == 0 then c:put(x, y, R.tanbark[2]) end end)
  end
  C.sep(c, torso, sL:copy():add(sR), R.tanbark[1])
  local ti = C.lit(c, torso, R.tanbark, { R = 5, cuts = { .2, .36, .52, .68, .86 } })
  -- long drape folds
  for _, f in ipairs({ { 22, 30, 18, 55 }, { 42, 30, 46, 55 }, { 28, 46, 27, 55 }, { 37, 46, 38, 55 } }) do
    c:line({ {f[1], f[2]}, {f[3], f[4]} }, 1):each(function(x, y) if torso:has(x, y) then c:put(x, y, R.tanbark[2]) if torso:has(x - 1, y) then c:put(x - 1, y, R.tanbark[5]) end end end)
  end
  -- smocked yoke: rows of little stitches
  for y = 18, 22, 2 do for x = 20, 44, 3 do if torso:has(x, y) then c:put(x, y, R.tanbark[2]) c:put(x + 1, y, R.tanbark[5]) end end end
  -- hem band
  for x = 13, 51 do if torso:has(x, 54) then c:put(x, 53, R.tanbark[2]) c:put(x, 54, R.tanbark[3]) c:put(x, 55, R.tanbark[3]) end end
  -- pouch pocket (canvas lining edge)
  local pk = c:poly{ {22,34}, {42,34}, {43,46}, {21,46} }
  C.lit(c, pk, R.tanbark, { R = 2, b = 1 })
  C.hline(c, 22, 42, 34, R.canvas[5]) C.hline(c, 22, 42, 35, R.tanbark[1])
  pk:edge():each(function(x, y) if y > 35 and (x > 41 or y == 46) then c:put(x, y, R.tanbark[1]) end end)
  -- neck: round opening + slit, drawstring with hanging ends
  local nk = c:ellipse(32, 10, 7, 2.5)
  C.colour(c, nk, R.tanbark[1])
  C.colour(c, c:rect(31, 11, 32, 19), R.tanbark[1])
  c:line({ {25,11}, {28,13}, {36,13}, {39,11} }, 1):each(function(x, y) c:put(x, y, R.canvas[5]) end)
  c:line({ {30,13}, {29,20}, {28,24} }, 1):each(function(x, y) c:put(x, y, R.canvas[5]) end)
  c:line({ {34,13}, {35,19}, {36,22} }, 1):each(function(x, y) c:put(x, y, R.canvas[4]) end)
  C.put(c, { {27,25}, {28,25}, {28,24} }, R.canvas[3]) C.put(c, { {36,23}, {37,23} }, R.canvas[3])
  -- quirk: a pale gull feather tucked at the neck
  local fe = G.blade(37, 13, 42, 6, 46, 1, function(t) return 1.9 * math.sin(math.pi * min(1, t * 1.1 + 0.05)) end)
  C.colour(c, fe:copy():grow(1):cut(fe):cut(torso), C.ink)
  C.lit(c, fe, R.feltgrey, { R = 1, b = 2 })
  c:line({ {38,12}, {45,2} }, 1):each(function(x, y) if fe:has(x, y) then c:put(x, y, R.feltgrey[3]) end end)
  C.put(c, { {45,1}, {46,1} }, R.mist[2])
  C.save(c, "coat-4-tanbark-smock")
end

---------------------------------------------------------------- 5 eiderdown coat
if not only or only == "5" then
  local c = C.new("coat-5-eiderdown-coat")
  local sL, sR = sleeves({ 20, 15 }, { 11, 24 }, { 9, 49 }, function(t) return 6 end)
  for _, m in ipairs({ sR, sL }) do
    local idx = C.lit(c, m, R.eider, { R = 3, b = (m == sR) and -1 or 0 })
    C.retone(c, m, idx, R.eider, function(x, y) local p = y % 6 if p == 0 then return -2 elseif p == 1 or p == 2 then return 1 end end)
  end
  local core = HP.mask()
  local cham = {}
  for i, y in ipairs({ 13, 19, 25, 31, 37, 43, 49 }) do
    local m = c:rrect(15, y, 49, y + 6, 3)
    cham[i] = m core:add(m)
  end
  C.sep(c, core, sL:copy():add(sR), R.eider[1])
  for i, m in ipairs(cham) do
    local idx = C.lit(c, m, R.eider, { R = 3, hs = 1.2, cuts = { .2, .36, .52, .7, .88 } })
    -- diamond quilting stitches
    m:each(function(x, y) if (x + y) % 8 == 0 and m:shrink(2):has(x, y) then c:put(x, y, R.eider[2]) end end)
  end
  for i = 2, #cham do C.hline(c, 16, 48, 12 + i * 6, R.eider[1]) end
  -- zip
  for y = 14, 55 do c:put(32, y, (y % 2 == 0) and R.steel[4] or R.steel[2]) end
  local pull = c:rect(33, 22, 34, 25)
  C.colour(c, pull, R.steel[5]) c:put(34, 25, R.steel[2])
  -- high puffed collar with woad lining showing inside
  local col = c:rrect(19, 3, 45, 14, 5)
  C.sep(c, col, core, R.eider[1])
  C.lit(c, col, R.eider, { R = 4, b = 1 })
  local lin = c:ellipse(32, 6, 9, 2.5)
  C.colour(c, lin, R.woad[3])
  lin:each(function(x, y) if y <= 5 then c:put(x, y, R.woad[1]) end end)
  C.hline(c, 24, 40, 9, R.eider[3])
  -- quirk: a down feather escaping from a seam on the right
  local fe = G.blade(48, 31, 53, 27, 56, 22, function(t) return 1.8 * math.sin(math.pi * min(1, t * 1.1 + .05)) end)
  C.colour(c, fe:copy():grow(1):cut(fe):cut(core), C.ink)
  C.lit(c, fe, R.fleece, { R = 1, b = 2 })
  c:line({ {49,30}, {55,23} }, 1):each(function(x, y) if fe:has(x, y) then c:put(x, y, R.fleece[3]) end end)
  C.put(c, { {57,22}, {57,21} }, R.fleece[5])
  C.save(c, "coat-5-eiderdown-coat")
end
