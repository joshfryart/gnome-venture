-- footwear.lua: Spicepeak (CSA) footwear concepts, 5 icons 64x64. See concepts.md.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local ink, cream = C.ink, C.cream
local floor, abs, sqrt = math.floor, math.abs, math.sqrt

---------------------------------------------------------------- 1 curl-toe slippers
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "footwear-1" }
  local function slipper(dx, dy, b)
    local S = {}
    local body = c:poly{ {9+dx,35+dy}, {13+dx,30+dy}, {18+dx,32+dy}, {30+dx,33+dy}, {40+dx,36+dy}, {47+dx,40+dy}, {47+dx,45+dy}, {9+dx,45+dy} }
    local curlm, curln, CT = G.tube({ {42+dx,42+dy}, {54+dx,44+dy}, {58+dx,31+dy}, {50+dx,28+dy} },
      function(t) return 3.6 - t * 2.6 end)
    local sole = c:rrect(8+dx, 44+dy, 48+dx, 47+dy, 1)
    local open = c:poly{ {13+dx,31+dy}, {18+dx,33+dy}, {29+dx,34+dy}, {27+dx,36+dy}, {15+dx,35+dy}, {12+dx,33+dy} }
    S.all = body:copy():add(curlm):add(sole)
    S.paint = function()
      local bb = {} if b then C.bias(S.all, b, bb) end
      C.part(c, sole, R.lining, { R = 1, bias = C.bias(sole, (b or 0) - 1) })
      C.part(c, body, R.madder, { R = 4, bias = C.bias(body, b or 0), cuts = { .2, .36, .52, .7, .88 } })
      local cb = C.bias(curlm, b or 0)
      local ci = C.toneN(c, curlm:copy():cut(body), curln, R.madder, { bias = cb, cuts = { .2, .36, .52, .7, .88 } })
      -- opening shows the tan lining inside
      C.part(c, open, R.lining, { R = 1, b = (b or 0) - 2 })
      c:fillMask(open:edge(), R.madder[1])
      -- sole line and heel
      C.hline(c, 9+dx, 47+dx, 44+dy, R.madder[1])
      -- gold running stitch along the vamp and heel
      for x = 20+dx, 44+dx, 3 do
        local yy
        for y = 30+dy, 44+dy do if body:has(x, y) and not open:has(x, y) and not open:has(x, y - 1) then yy = y + 2 break end end
        if yy then c:put(x, yy, R.brass[b and 3 or 4]) c:put(x + 1, yy, R.brass[b and 4 or 5]) end
      end
      for y = 36+dy, 42+dy, 3 do c:put(12+dx, y, R.brass[b and 3 or 4]) end
      -- lit top edge
      if not b then
        C.put(c, { {32,35}, {33,35}, {34,35}, {35,36}, {36,36}, {37,36} }, R.madder[6])
        c:put(14, 31, R.madder[6]) c:put(55, 33, R.madder[6]) c:put(56, 34, R.madder[6]) c:put(15, 31, cream)
      end
    end
    return S
  end
  local back = slipper(4, -9, -1)
  local front = slipper(0, 0, nil)
  back.paint()
  C.inkSep(c, front.all, back.all)
  front.paint()
  -- quirk: saffron pom-pom tassel on the curl tip, a short fringe hanging below it
  local pom = c:ellipse(49.5, 27.5, 2.4, 2.4)
  C.toneN(c, pom, X.sphere(49.1, 27.1, 2.4, pom), R.saffron, {})
  C.put(c, { {48,31}, {50,31}, {49,32}, {51,30} }, R.saffron[3])
  c:put(48, 26, R.saffron[6]) c:put(49, 32, R.saffron[2])
  C.save(c, "footwear-1-curl-toe-slippers")
end

---------------------------------------------------------------- 2 felted snow boots
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "footwear-2" }
  local function boot(dx, dy, b)
    local B = {}
    local shaft = c:rrect(11+dx, 13+dy, 29+dx, 44+dy, 3)
    local foot = c:rrect(11+dx, 36+dy, 33+dx, 52+dy, 5):add(c:ellipse(35+dx, 46+dy, 7, 6))
    local body = shaft:copy():add(foot)
    local sole = c:rrect(10+dx, 51+dy, 42+dx, 54+dy, 2)
    local top = c:ellipse(20+dx, 13+dy, 9, 2.5)
    B.all = body:copy():add(sole):add(top)
    B.paint = function()
      C.part(c, sole, R.sole, { R = 1, b = b })
      local bias = C.bias(body, b or 0)
      local idx = C.vcyl(c, shaft, R.feltc, 11+dx, 29+dx, { bias = bias, cuts = { .2, .36, .52, .7, .88 } })
      C.retone(c, shaft, idx, R.feltc, C.felt)
      local fm = foot:copy():cut(shaft)
      local fi = C.part(c, fm, R.feltc, { R = 6, hs = .6, b = b, tex = C.felt, cuts = { .2, .36, .52, .7, .88 } })
      -- ankle crease, toe seam
      C.put(c, { {28+dx,40+dy}, {29+dx,40+dy}, {30+dx,41+dy}, {31+dx,42+dy} }, R.feltc[2])
      C.hline(c, 11+dx, 41+dx, 50+dy, R.feltc[2])
      -- top rim: dark opening
      C.part(c, top, R.feltc, { R = 1, b = (b or 0) })
      local hole = c:ellipse(20+dx, 13+dy, 7, 1)
      c:fillMask(hole, R.feltc[1])
      return idx
    end
    return B
  end
  local back = boot(12, -6, -1)
  local front = boot(0, 0, nil)
  back.paint()
  C.inkSep(c, front.all, back.all)
  front.paint()
  -- madder felt band at the top and a clean spiral applique on the shin
  local band = c:rect(11, 15, 29, 18)
  C.vcyl(c, band, R.madder, 11, 29, { cuts = { .2, .36, .52, .7, .88 } })
  for x = 12, 28, 2 do c:put(x, 16 + (x % 4 == 0 and 1 or 0), R.saffron[4]) end
  local pts = {}
  for i = 0, 70 do
    local t = i / 70 * 2.4 * math.pi
    local r = 0.6 + t * 0.95
    pts[#pts + 1] = { 20 + math.cos(t + 2.2) * r, 30 + math.sin(t + 2.2) * r }
  end
  local spm = c:line(pts, 2)
  spm:each(function(x, y) c:put(x, y, (x + y < 50) and R.madder[4] or R.madder[2]) end)
  -- lit edge of shaft + felt pop
  C.vline(c, 13, 18, 40, R.feltc[6]) c:put(13, 17, cream)
  c:put(37, 42, R.feltc[6]) c:put(38, 42, R.feltc[6])
  -- quirk: shaggy tuft of dark yak wool spilling out of the front boot
  local tuft = c:ellipse(18, 10, 6, 3):add(c:poly{ {13,11}, {14,5}, {17,9}, {19,3}, {21,8}, {24,5}, {25,11} })
  C.part(c, tuft, R.yak, { R = 2, tex = function(x, y) if (x * 3 + y) % 4 == 0 then return -1 end end })
  C.put(c, { {14,6}, {19,4}, {15,8}, {20,6}, {24,6} }, R.yak[6])
  C.save(c, "footwear-2-felted-snow-boots")
end

---------------------------------------------------------------- 3 toe-ring sandals (top view)
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "footwear-3" }
  local function sandal(cx, cy, b, s)
    local sole, sn = G.tube({ {cx, cy + 19}, {cx - s * 1, cy + 6}, {cx + s * 2, cy - 6}, {cx + s * 1, cy - 17} }, function(t)
      if t < .35 then return 6.2 - t * 1.5 elseif t < .7 then return 5.7 + (t - .35) * 8 else return 8.5 - (t - .7) * 3 end end)
    local thick = sole:shift(1, 2):cut(sole)
    local S = { all = sole:copy():add(thick) }
    S.paint = function()
      c:fillMask(thick, R.sole[3])
      thick:each(function(x, y) if (x + y) % 3 == 0 then c:put(x, y, R.sole[2]) end end)
      C.part(c, sole, R.leather, { R = 3, b = b, cuts = { .18, .34, .5, .68, .86 } })
      -- footbed darker where the foot presses
      local bed = c:ellipse(cx + s, cy - 9, 3.5, 4):add(c:ellipse(cx, cy + 13, 2.8, 3))
      bed:each(function(x, y) c:put(x, y, R.leather[(b and 2 or 3)]) end)
      -- tooled border stitch
      sole:shrink(2):edge():each(function(x, y) if (x + y) % 3 == 0 then c:put(x, y, R.leather[2]) end end)
      -- V straps from the toe ring back to the sides
      local tx, ty = cx - s * 2, cy - 12
      local v1 = c:line({ {tx, ty}, {cx - 7, cy + 1} }, 3)
      local v2 = c:line({ {tx, ty}, {cx + 8, cy + 1} }, 3)
      local vm = v1:copy():add(v2)
      c:fillMask(vm:shift(1, 1):cut(vm):clip(sole), R.leather[1])
      C.part(c, vm, R.madder, { R = 1, b = b })
      vm:each(function(x, y) if (x + y) % 3 == 0 then c:put(x, y, R.madder[2]) end end)
      -- toe ring
      local ring = c:ellipse(tx, ty, 2.3, 2.3)
      C.part(c, ring, R.strap, { R = 1, b = (b or 0) + 1 })
      c:put(tx, ty, R.strap[1]) c:put(tx - 1, ty - 1, R.strap[6])
      -- broad braided band across the instep, overhanging the sole edge
      local band = c:rrect(cx - 9, cy + 1, cx + 10, cy + 5, 1)
      c:fillMask(band:shift(1, 2):cut(band):clip(sole), R.leather[1])
      C.inkSep(c, band, vm)
      C.part(c, band, R.madder, { R = 2, b = b })
      band:each(function(x, y) if (x + y) % 4 == 0 and band:has(x, y - 1) and band:has(x, y + 1) then c:put(x, y, R.madder[2]) end end)
      C.hline(c, cx - 8, cx + 9, cy + 1, R.madder[b and 4 or 5])
      -- brass studs on the band
      for _, ox in ipairs({ -5, 1, 7 }) do c:put(cx + ox, cy + 3, R.brass[b and 4 or 5]) c:put(cx + ox - 1, cy + 3, R.brass[3]) end
    end
    return S
  end
  local L = sandal(19, 30, -1, -1)
  local Rr = sandal(42, 33, nil, 1)
  L.paint() Rr.paint()
  -- leather pop
  c:put(17, 16, R.leather[6]) c:put(18, 15, cream) c:put(38, 20, R.leather[6]) c:put(39, 19, cream)
  -- quirk: red chili hooked through the right sandal's band
  local chm, chn = G.tube({ {52,35}, {56,37}, {58,44}, {55,50} }, function(t) return 2.4 - t * 1.6 end)
  C.inkSep(c, chm, Rr.all)
  C.toneN(c, chm, chn, R.ember, { cuts = { .2, .36, .52, .7, .88 } })
  C.put(c, { {51,35}, {50,34}, {49,34} }, R.leaf[4]) c:put(50, 33, R.leaf[5])
  c:put(54, 35, R.ember[6]) c:put(55, 35, cream)
  C.save(c, "footwear-3-toe-ring-sandals")
end

---------------------------------------------------------------- 4 stilt clogs
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "footwear-4" }
  local grain = function(x, y) if y % 2 == 0 and X.hash(x, y, 3) < .35 then return -1 end end
  local function clog(dx, dy, b)
    local S = {}
    local plat = c:poly{ {8+dx,31+dy}, {42+dx,31+dy}, {49+dx,27+dy}, {52+dx,28+dy}, {51+dx,32+dy}, {45+dx,37+dy}, {8+dx,37+dy} }
      :cut(c:rect(7+dx, 31+dy, 8+dx, 31+dy))
    local t1 = c:poly{ {9+dx,37+dy}, {21+dx,37+dy}, {20+dx,45+dy}, {10+dx,45+dy} }
    local t2 = c:poly{ {29+dx,37+dy}, {44+dx,37+dy}, {42+dx,45+dy}, {30+dx,45+dy} }
    local dome = c:poly{ {22+dx,31+dy}, {25+dx,25+dy}, {30+dx,20+dy}, {36+dx,19+dy}, {42+dx,22+dy}, {47+dx,27+dy}, {46+dx,31+dy} }
    S.all = plat:copy():add(t1):add(t2):add(dome)
    S.paint = function()
      C.part(c, t1, R.wood, { R = 2, b = (b or 0) - 1, tex = grain })
      C.part(c, t2, R.wood, { R = 2, b = (b or 0) - 1, tex = grain })
      C.hline(c, 10+dx, 20+dx, 37+dy, R.wood[1]) C.hline(c, 30+dx, 43+dx, 37+dy, R.wood[1])
      C.inkSep(c, plat, t1:copy():add(t2))
      C.part(c, plat, R.wood, { R = 2, b = b, tex = grain, cuts = { .2, .36, .52, .7, .86 } })
      C.hline(c, 9+dx, 44+dx, 36+dy, R.wood[2])
      -- woven jute upper: a closed dome band over the foot
      C.inkSep(c, dome, plat)
      local di = C.part(c, dome, R.bamboo, { R = 4, b = b, cuts = { .2, .36, .52, .7, .88 } })
      dome:each(function(x, y)
        local i = di[K(x, y)]
        if i and ((x % 4 == 0 and y % 2 == 0) or (x % 4 == 2 and y % 2 == 1)) then c:put(x, y, R.bamboo[math.max(1, i - 1)]) end
      end)
      -- binding along the dome's edge: madder trim
      dome:edge():each(function(x, y) if y < 30 + dy and dome:has(x, y + 1) then c:put(x, y, R.madder[(b and 3 or 4) + ((x < 34 + dx) and 1 or 0)]) end end)
      -- foot opening shading at the heel end
      C.put(c, { {23+dx,29+dy}, {23+dx,30+dy}, {24+dx,28+dy}, {24+dx,29+dy}, {24+dx,30+dy}, {25+dx,27+dy} }, R.bamboo[1])
    end
    return S
  end
  local back = clog(7, -8, -1)
  local front = clog(0, 0, nil)
  back.paint()
  C.inkSep(c, front.all, back.all)
  front.paint()
  C.hline(c, 21, 22, 31, R.wood[6]) C.hline(c, 46, 49, 30, R.wood[6]) c:put(47, 29, cream)
  -- quirk: snail riding on the heel end of the front clog
  local foot = c:poly{ {9,29}, {20,29}, {20,31}, {9,31} }:add(c:ellipse(9, 28, 1.4, 2))
  C.part(c, foot, R.feltc, { R = 1 })
  C.put(c, { {8,25}, {7,24}, {10,25}, {10,24} }, R.feltc[4])
  local shell = c:ellipse(15, 26, 3.4, 3.4)
  C.inkSep(c, shell, foot)
  C.toneN(c, shell, X.sphere(14.6, 25.6, 3.4, shell), R.saffron, {})
  C.put(c, { {15,26}, {16,26}, {16,25}, {15,24}, {14,24}, {13,25}, {13,26}, {13,27}, {14,28}, {15,28}, {16,28} }, R.saffron[2])
  c:put(15, 25, R.saffron[4]) c:put(13, 24, R.saffron[6])
  C.save(c, "footwear-4-stilt-clogs")
end

---------------------------------------------------------------- 5 wrapped hide boots
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "footwear-5" }
  local function boot(dx, dy, b)
    local B = {}
    local shaft = c:poly{ {13+dx,9+dy}, {29+dx,9+dy}, {28+dx,42+dy}, {13+dx,42+dy} }
    local foot = c:rrect(12+dx, 37+dy, 30+dx, 51+dy, 3):add(c:ellipse(34+dx, 47+dy, 7, 4.5))
      :add(c:poly{ {24+dx,37+dy}, {31+dx,40+dy}, {38+dx,43+dy}, {27+dx,45+dy} })
    local sole = c:rrect(11+dx, 51+dy, 42+dx, 54+dy, 1)
    local wrap = c:rect(12+dx, 13+dy, 30+dx, 38+dy)
    B.all = shaft:copy():add(foot):add(sole):add(wrap)
    B.paint = function()
      C.part(c, sole, R.sole, { R = 1, b = b })
      for x = 12+dx, 41+dx, 3 do c:put(x, 54+dy, R.sole[1]) end
      local bb = C.bias(B.all, b or 0)
      C.vcyl(c, shaft, R.yak, 13+dx, 29+dx, { bias = bb, cuts = { .2, .36, .52, .7, .88 } })
      C.part(c, foot:copy():cut(shaft), R.yak, { R = 6, hs = .6, bias = bb, cuts = { .2, .36, .52, .7, .88 } })
      C.hline(c, 28+dx, 39+dx, 48+dy, R.yak[2])
      -- turned top rim
      C.hline(c, 13+dx, 29+dx, 10+dy, R.yak[b and 4 or 5]) C.hline(c, 13+dx, 29+dx, 11+dy, R.yak[2])
      -- woven wrap: slanted bands teal / saffron with dark gaps
      local wb = C.bias(wrap, b or 0)
      local wi = C.vcyl(c, wrap, R.yarnB, 12+dx, 30+dx, { bias = wb, cuts = { .2, .36, .52, .7, .88 } })
      wrap:each(function(x, y)
        local u = (y - dy) + (x - dx) * 0.35
        local band = floor(u / 4)
        local f = u - band * 4
        local i = wi[K(x, y)]
        if f < 0.9 then c:put(x, y, R.yarnB[1])
        elseif band % 3 == 1 then c:put(x, y, R.saffron[math.min(6, i)])
        elseif band % 3 == 2 then c:put(x, y, R.madder[math.min(6, i)]) end
      end)
      -- bottom and top edge of the wrap
      C.hline(c, 12+dx, 30+dx, 39+dy, R.yak[1])
    end
    return B
  end
  local back = boot(12, -6, -1)
  local front = boot(0, 0, nil)
  back.paint()
  C.inkSep(c, front.all, back.all)
  front.paint()
  -- lit streaks
  C.vline(c, 15, 41, 48, R.yak[6]) c:put(32, 44, R.yak[6]) c:put(33, 44, R.yak[6])
  -- quirk: tie cord with a saffron pom-pom dangling off the front boot
  local cord = c:line({ {30,15}, {32,17}, {33,21}, {33,25} }, 1)
  C.inkSep(c, cord, front.all)
  c:fillMask(cord, R.strap[4])
  local pom = c:ellipse(33.5, 28, 2.6, 2.6)
  local pn = X.sphere(33.1, 27.6, 2.6, pom)
  C.toneN(c, pom, pn, R.saffron, {})
  c:put(32, 26, R.saffron[6]) c:put(35, 30, R.saffron[2]) c:put(31, 29, R.saffron[3])
  C.save(c, "footwear-5-wrapped-hide-boots")
end
