-- coat.lua: Olivewhistle Shore (SE) coat concepts, 5 icons 64x64 (front view, laid flat).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, W, G = C.HP, C.X, C.K, C.R, C, C.G
local ink, cream = C.ink, C.cream
local only = app.params.only
local floor, max, min = math.floor, math.max, math.min
local function mirror(m) local n = HP.mask() m:each(function(x, y) n:set(63 - x, y) end) return n end

-- 1 Net-Mender's Smock -----------------------------------------------------------
local function c1()
  local c = C.canvas("coat-1-net-mender-smock")
  local body = c:poly{ {19,12}, {45,12}, {47,30}, {49,55}, {15,55}, {17,30} }
  local sl = c:poly{ {20,12}, {5,24}, {10,34}, {19,28} }
  local sr = mirror(sl)
  local sleeves = sl:copy():add(sr)
  C.part(c, sl, R.linen, { R = 3, tex = C.linen })
  C.part(c, sr, R.linen, { R = 3, b = -1, tex = C.linen })
  -- sea-blue sleeve hems
  for _, m in ipairs({ sl, sr }) do
    m:each(function(x, y)
      local xx = (m == sl) and x or (63 - x)
      local d = math.abs((xx - 5) * 10 - (y - 24) * 5) / 11.18
      if d < 2.6 then c:put(x, y, R.sea[(m == sl) and ((d < 1.2) and 5 or 4) or ((d < 1.2) and 3 or 2)]) end
    end)
  end
  W.sep(c, body, sleeves, R.linen[2])
  local idx = C.part(c, body, R.linen, { R = 5, hs = 0.5, tex = C.linen })
  -- soft vertical folds
  for _, fx in ipairs({ 24, 38 }) do for y = 34, 54 do c:put(fx + floor((y - 34) / 10) * (fx < 32 and -1 or 1), y, R.linen[3]) end end
  -- square neck: dark inside, sea trim
  local neck = c:rect(26, 12, 38, 19)
  local trim = c:rect(24, 12, 40, 21):cut(neck)
  C.part(c, trim, R.sea, { R = 1 })
  c:fillMask(neck, R.linen[1])
  W.hline(c, 26, 38, 19, R.linen[2])
  -- hem band
  local hem = c:rect(15, 52, 49, 55):clip(body)
  hem:each(function(x, y) c:put(x, y, R.sea[(y == 52) and 4 or 3]) end)
  W.hline(c, 16, 48, 51, R.linen[2])
  -- pocket with stitched sardine
  local pk = c:rrect(34, 36, 45, 47, 1)
  C.part(c, pk, R.linen, { R = 1, b = 1 })
  W.hline(c, 34, 45, 36, R.sea[3])
  W.hline(c, 35, 45, 48, R.linen[2])
  local fish = c:ellipse(39, 42, 3, 1):add(c:poly{ {41.5,42}, {44,40}, {44,44.5} })
  C.part(c, fish, R.steel, { R = 1 })
  W.hline(c, 37, 41, 43, R.sea[3]) c:put(37, 41, R.indigo[1]) c:put(38, 41, R.steel[6])
  -- sheen
  W.put(c, { {21,16}, {22,16}, {21,17} }, R.linen[6]) c:put(20, 17, cream)
  C.save(c, "coat-1-net-mender-smock")
end

-- 2 Goatherd's Fleece Vest --------------------------------------------------------
local function c2()
  local c = C.canvas("coat-2-fleece-vest")
  local body = c:poly{ {19,8}, {27,8}, {32,22}, {37,8}, {45,8}, {47,13}, {48,24}, {50,56}, {14,56}, {16,24}, {17,13} }
  -- inside back seen through the V
  local inside = c:poly{ {27,8}, {37,8}, {33,56}, {31,56} }
  local idx = C.part(c, body, R.felt, { R = 5, hs = 0.6, tex = C.felt })
  c:fillMask(inside:clip(body), R.felt[1])
  -- open front gap
  for y = 22, 55 do c:put(31, y, R.felt[1]) c:put(32, y, R.felt[1]) c:put(33, y, R.felt[2]) end
  -- side seams
  W.vline(c, 21, 26, 52, R.felt[3])
  W.vline(c, 43, 26, 52, R.felt[2])
  -- fleece trim: neck V edges, armholes, hem
  local fl = HP.mask()
  fl:add(c:line({ {20,8}, {16,13}, {15,24} }, 3)):add(c:line({ {44,8}, {48,13}, {49,24} }, 3))
  fl:add(c:line({ {27,8}, {31,20}, {30,55} }, 3)):add(c:line({ {37,8}, {33,20}, {34,55} }, 3))
  fl:add(c:rect(14, 52, 50, 57))
  fl:clip(body:grow(1)):add(c:rect(14, 52, 50, 57))
  local fi = C.part(c, fl, R.fleece, { R = 1 })
  W.retone(c, fl, fi, R.fleece, function(x, y)
    local h = X.hash(x, y, 11)
    if (x + 2 * y) % 5 == 0 then return -1 elseif h > .7 then return 1 end
  end)
  -- toggle + cord + quirk goat bell
  local tog = c:rrect(28, 28, 36, 30, 1)
  C.part(c, tog, R.wood, { R = 1 })
  c:put(29, 28, R.wood[6])
  local cord = c:line({ {35,31}, {38,35}, {39,38} }, 1)
  c:fillMask(cord, R.strap[2])
  local bell = c:poly{ {37,38}, {41,38}, {43,45}, {35,45} }:add(c:ellipse(39, 38, 2, 1.5))
  C.part(c, bell, R.brass, { R = 2 })
  W.hline(c, 35, 43, 45, R.brass[2]) c:put(39, 46, R.wood[1]) c:put(37, 39, R.brass[6]) c:put(38, 40, cream)
  -- leather sheen
  W.put(c, { {20,18}, {20,19}, {21,17} }, R.felt[6])
  C.save(c, "coat-2-fleece-vest")
end

-- 3 Olive-Grove Quilt Jacket -------------------------------------------------------
local function c3()
  local c = C.canvas("coat-3-olive-quilt-jacket")
  local sl = G.tube({ {20,15}, {14,22}, {11,38}, {11,52} }, function(t) return 5 + t * 0.5 end)
  local sr = mirror(sl)
  local body = c:rrect(18, 11, 46, 54, 5)
  local quilt = function(x, y, i)
    if (x + y) % 7 == 0 or (x - y) % 7 == 0 then return -2 end
    if (x + y) % 7 == 3 and (x - y) % 7 == 3 then return 1 end
  end
  C.part(c, sl, R.olive, { R = 4, tex = quilt })
  C.part(c, sr, R.olive, { R = 4, b = -1, tex = quilt })
  -- knit cuffs
  for _, m in ipairs({ c:rect(6, 51, 17, 55), c:rect(46, 51, 57, 55) }) do
    local cm = m:clip(sl:copy():add(sr):grow(1))
    C.part(c, cm, R.wood, { R = 1, b = (cm:has(10, 53) and 0 or -1) })
    cm:each(function(x, y) if x % 2 == 0 then c:put(x, y, R.wood[2]) end end)
  end
  W.sep(c, body, sl:copy():add(sr), R.olive[1])
  C.part(c, body, R.olive, { R = 7, hs = 0.6, tex = quilt })
  -- front opening + toggles
  W.vline(c, 32, 13, 54, R.olive[1]) W.vline(c, 31, 13, 54, R.olive[5])
  for _, y in ipairs({ 21, 31, 41 }) do
    local t = c:rrect(29, y, 35, y + 2, 1)
    C.part(c, t, R.wood, { R = 1 })
    c:put(30, y, R.wood[6]) W.hline(c, 30, 34, y + 3, R.olive[1])
  end
  -- stand collar
  local col = c:rrect(23, 7, 41, 13, 2)
  C.part(c, col, R.olive, { R = 2, b = 1 })
  W.hline(c, 24, 40, 13, R.olive[1]) W.vline(c, 32, 8, 12, R.olive[2])
  -- hem band
  W.hline(c, 19, 45, 51, R.olive[2])
  -- quirk: olive-leaf sprig pinned at the chest
  W.put(c, { {23,26}, {24,25}, {25,24}, {26,23} }, R.wood[2])
  local sg = { R.sage[3], R.sage[4], R.sage[5], R.sage[6], R.fleece[5], R.fleece[6] }
  local lv = G.leaf(c, 24, 25, 17, 20, 1.8, sg):add(G.leaf(c, 25, 24, 28, 16, 1.8, sg))
  lv:grow(1):cut(lv):each(function(x, y) c:put(x, y, R.olive[1]) end)
  lv:each(function() end)
  G.leaf(c, 24, 25, 17, 20, 1.8, sg) G.leaf(c, 25, 24, 28, 16, 1.8, sg)
  W.put(c, { {24,26}, {25,25}, {26,24} }, R.wood[2])
  local ol = c:ellipse(22, 27, 1.5, 1.8)
  C.part(c, ol, R.grape, { R = 1 }) c:put(21, 26, R.grape[6])
  -- puff sheen
  W.put(c, { {21,15}, {22,15}, {21,16} }, R.olive[6]) c:put(20, 16, cream)
  C.save(c, "coat-3-olive-quilt-jacket")
end

-- 4 Vintner's Long Coat ------------------------------------------------------------
local function c4()
  local c = C.canvas("coat-4-vintner-long-coat")
  local sl = G.tube({ {20,10}, {16,18}, {14,32}, {13,44} }, function() return 4 end)
  local sr = mirror(sl)
  local body = c:poly{ {19,6}, {45,6}, {48,12}, {48,30}, {54,60}, {10,60}, {16,30}, {16,12} }
  C.part(c, sl, R.wine, { R = 3, tex = C.felt })
  C.part(c, sr, R.wine, { R = 3, b = -1, tex = C.felt })
  W.sep(c, body, sl:copy():add(sr), R.wine[1])
  local idx = C.part(c, body, R.wine, { R = 6, hs = 0.5, tex = C.felt })
  -- open front: dark lining showing in a V then straight
  local v = c:poly{ {26,6}, {38,6}, {33,30}, {33,60}, {31,60}, {31,30} }
  c:fillMask(v, R.wine[1])
  -- lapels
  local ll = c:poly{ {22,6}, {27,6}, {31,28}, {25,20} }
  local lr = mirror(ll)
  C.part(c, ll, R.wine, { R = 1, b = 1 })
  C.part(c, lr, R.wine, { R = 1, b = 0 })
  W.put(c, { {25,20}, {26,22}, {27,23}, {28,25}, {29,26}, {30,27} }, R.wine[2])
  -- skirt folds
  for _, l in ipairs({ { {22,34}, {19,59} }, { {42,34}, {45,59} }, { {28,40}, {27,59} } }) do
    c:line(l, 1):each(function(x, y) c:put(x, y, R.wine[2]) c:put(x - 1, y, R.wine[5]) end)
  end
  -- waist seam + buttons
  W.hline(c, 17, 30, 31, R.wine[2]) W.hline(c, 34, 47, 31, R.wine[1])
  for _, y in ipairs({ 32, 38, 44 }) do c:fillMask(c:rect(28, y, 29, y + 1), R.brass[4]) c:put(28, y, R.brass[6]) end
  -- turned-back linen cuffs
  for _, m in ipairs({ c:rect(7, 40, 19, 46), c:rect(44, 40, 56, 46) }) do
    local cm = m:clip(sl:copy():add(sr))
    C.part(c, cm, R.linen, { R = 1, b = cm:has(13, 43) and 0 or -1 })
  end
  -- quirk: vine-leaf patch on the hem
  local lf = c:poly{ {38,47}, {42,45}, {45,47}, {48,46}, {47,50}, {49,53}, {44,55}, {41,53}, {37,54}, {38,50}, {36,48} }
  C.part(c, lf, R.leaf, { R = 2 })
  C.edge(c, lf, function(x, y) if (x + y) % 2 == 0 then return R.leaf[2] end end)
  W.put(c, { {42,51}, {43,50}, {44,49}, {45,48}, {41,52} }, R.leaf[2])
  W.put(c, { {40,49}, {39,48} }, R.leaf[5])
  -- wool sheen
  W.put(c, { {19,10}, {19,11}, {20,9} }, R.wine[6])
  C.save(c, "coat-4-vintner-long-coat")
end

-- 5 Sun-Stripe Tunic Coat ---------------------------------------------------------
local function c5()
  local c = C.canvas("coat-5-sun-stripe-tunic")
  local sl = c:poly{ {22,11}, {22,24}, {13,42}, {3,40}, {8,26}, {15,13} }
  local sr = mirror(sl)
  local body = c:poly{ {20,10}, {44,10}, {46,30}, {47,52}, {17,52}, {18,30} }
  local stripes = { R.saffron, R.saffron, R.saffron, R.terra, R.linen, R.linen }
  local function stripe(m, b, axis)
    local idx = C.part(c, m, R.linen, { R = 4, b = b, tex = C.weave })
    m:each(function(x, y)
      local u = axis(x, y)
      local ramp = stripes[(floor(u / 2) % #stripes) + 1]
      if ramp ~= R.linen then c:put(x, y, ramp[max(1, min(6, idx[K(x, y)]))]) end
    end)
  end
  stripe(sl, 0, function(x, y) return floor(x * 0.45 + y * 0.9) end)
  stripe(sr, -1, function(x, y) return floor((63 - x) * 0.45 + y * 0.9) end)
  -- bell sleeve inner opening (dark)
  for _, p in ipairs({ { {4,39}, {12,41} }, { {59,39}, {51,41} } }) do c:line(p, 1):each(function(x, y) c:put(x, y, R.terra[1]) end) end
  W.sep(c, body, sl:copy():add(sr), R.terra[1])
  stripe(body, 0, function(x, y) return x - 1 end)
  -- keyhole neck
  local nk = c:ellipse(32, 11, 4, 2):add(c:rect(31, 11, 32, 18))
  c:fillMask(nk, R.terra[1])
  C.edge(c, c:ellipse(32, 11, 6, 3.5):cut(nk):clip(body), function(x, y) return R.sea[x < 32 and 4 or 3] end)
  -- sea-blue sash with knot and tails
  local sash = c:rect(17, 33, 47, 37):clip(body:grow(1))
  C.part(c, sash, R.sea, { R = 1 })
  W.hline(c, 18, 46, 37, R.sea[1])
  local knot = c:rrect(22, 32, 27, 38, 1)
  C.part(c, knot, R.sea, { R = 1, b = 1 })
  local tails = c:poly{ {22,38}, {25,38}, {22,50}, {19,49} }:add(c:poly{ {25,38}, {28,38}, {29,48}, {26,49} })
  C.part(c, tails, R.sea, { R = 1 })
  W.put(c, { {20,49}, {21,49}, {26,48}, {27,48} }, R.sea[2])
  -- fringed hem
  for x = 18, 46, 2 do c:put(x, 53, R.saffron[3]) end
  -- quirk: little gecko on the right shoulder
  local gb = c:ellipse(41, 17, 1.5, 3)
  local gh = c:ellipse(41, 13, 1.5, 1.5)
  local gt = c:line({ {41,20}, {42,23}, {44,24}, {45,22} }, 1)
  local legs = c:line({ {39,15}, {38,14} }, 1):add(c:line({ {43,15}, {44,14} }, 1)):add(c:line({ {39,19}, {38,20} }, 1)):add(c:line({ {43,19}, {44,20} }, 1))
  local gk = gb:copy():add(gh):add(gt):add(legs)
  W.sep(c, gk, body, R.terra[1])
  C.part(c, gb:copy():add(gh), R.leaf, { R = 1, b = 1 })
  c:fillMask(gt, R.leaf[4]) c:fillMask(legs, R.leaf[3])
  c:put(40, 12, R.leaf[6]) c:put(42, 12, R.indigo[1])
  -- sheen
  W.put(c, { {21,14}, {21,15} }, R.saffron[6])
  C.save(c, "coat-5-sun-stripe-tunic")
end

local all = { c1, c2, c3, c4, c5 }
for i, f in ipairs(all) do if not only or tonumber(only) == i then f() end end
