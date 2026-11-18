-- EE footwear: 5 concepts (see concepts.md). Run: AppRun -b --script-param png=<dir>/ --script footwear.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R = C.HP, C.X, C.K, C.R
local floor, max, min, abs = math.floor, math.max, math.min, math.abs

---------------------------------------------------------------- 1 birchweave shoes
if C.want("footwear-1") then
  local c = C.new("footwear-1-birchweave-shoes")
  local plait = function(x, y, i)
    local a, b = (x + y) % 5, (x - y) % 5
    if a == 0 then return -2 end
    if b == 0 then return ((floor((x + y) / 5)) % 2 == 0) and -1 or 0 end
    if a == 2 and b == 2 then return 1 end
  end
  local function shoe(dx, dy, bias)
    local S = {}
    S.body = c:rrect(8 + dx, 37 + dy, 38 + dx, 50 + dy, 5)
      :add(c:ellipse(39 + dx, 45 + dy, 7, 5))
      :add(c:poly{ {10 + dx, 37 + dy}, {28 + dx, 36 + dy}, {42 + dx, 41 + dy}, {40 + dx, 46 + dy}, {10 + dx, 46 + dy} })
    S.wrap = c:poly{ {12 + dx, 18 + dy}, {26 + dx, 18 + dy}, {27 + dx, 38 + dy}, {11 + dx, 38 + dy} }
    S.top = c:ellipse(19 + dx, 18 + dy, 7.5, 2)
    S.all = S.body:copy():add(S.wrap):add(S.top)
    S.paint = function()
      local wi = C.cylv(c, S.wrap, R.linen, 11 + dx, 27 + dx, { bias = bias, tex = function(x, y) if y % 4 == 0 then return -1 end end })
      C.part(c, S.top, R.linen, { R = 1, bias = (bias or 0) - 1 })
      C.dots(c, { {14 + dx, 17 + dy}, {15 + dx, 17 + dy}, {16 + dx, 17 + dy} }, R.linen[(bias and 4 or 5)])
      -- bark cords criss-crossing the wrap
      local cord = c:line({ {11 + dx, 22 + dy}, {27 + dx, 30 + dy} }, 1):add(c:line({ {27 + dx, 22 + dy}, {11 + dx, 30 + dy} }, 1))
        :add(c:line({ {11 + dx, 31 + dy}, {27 + dx, 37 + dy} }, 1))
      cord:clip(S.wrap):each(function(x, y) c:put(x, y, ((x - dx) < 19) and R.strap[5 + (bias or 0)] or R.strap[3 + (bias or 0)]) end)
      -- shoe: plaited bark
      local sb = C.bmap(S.body, bias)
      S.wrap:shift(0, 1):each(function(x, y) if S.body:has(x, y) then sb[K(x, y)] = (sb[K(x, y)] or 0) - 1 end end)
      local bi = C.part(c, S.body:copy():cut(S.wrap), R.birch, { R = 4, bmap = sb, tex = plait, cuts = { .22, .4, .56, .72, .88 } })
      -- rim: a rolled bark edge around the opening
      for x = 9 + dx, 30 + dx do
        local y = 37 + dy + ((x > 27 + dx) and floor((x - 27 - dx) / 2) or 0)
        if S.body:has(x, y) and not S.wrap:has(x, y) then c:put(x, y, R.birch[(x < 20 + dx) and 6 or 5]) c:put(x, y + 1, R.birch[2]) end
      end
      -- sole line
      for x = 9 + dx, 44 + dx do if S.body:has(x, 49 + dy) then c:put(x, 49 + dy, R.birch[2]) c:put(x, 50 + dy, R.birch[1]) end end
    end
    return S
  end
  local back = shoe(13, -6, -1)
  local front = shoe(0, 0, nil)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  -- trailing cord ends from the front wrap
  local tail = c:line({ {11, 30}, {7, 34}, {6, 40} }, 1)
  tail:each(function(x, y) if not front.body:has(x, y) then c:put(x, y, R.strap[3]) end end)
  c:put(6, 41, R.strap[2]) c:put(7, 33, R.strap[5])
  -- quirk: green birch leaf caught in the lattice near the toe
  local leaf = c:poly{ {34, 40}, {38, 38}, {42, 39}, {38, 42} }
  C.part(c, leaf, R.leaf, { R = 1 })
  C.dots(c, { {36, 39}, {37, 39} }, R.leaf[6]) C.dots(c, { {38, 41}, {39, 40} }, R.leaf[2])
  -- bark glints
  C.dots(c, { {12, 40}, {13, 40} }, R.birch[6])
  C.save(c, "footwear-1-birchweave-shoes")
end

---------------------------------------------------------------- 2 snowdrift felt boots
if C.want("footwear-2") then
  local c = C.new("footwear-2-snowdrift-felt-boots")
  local felt = function(x, y, i) local h = C.hash(x, y, 7) if h < .12 then return -1 elseif h > .93 and i < 5 then return 1 end end
  local function boot(dx, dy, bias)
    local B = {}
    B.shaft = c:poly{ {11 + dx, 10 + dy}, {29 + dx, 10 + dy}, {28 + dx, 42 + dy}, {11 + dx, 44 + dy} }:add(c:rrect(10 + dx, 8 + dy, 30 + dx, 14 + dy, 3))
    B.foot = c:rrect(10 + dx, 36 + dy, 32 + dx, 52 + dy, 6):add(c:ellipse(34 + dx, 46 + dy, 7, 6))
    B.all = B.shaft:copy():add(B.foot)
    B.paint = function()
      local fb = C.bmap(B.foot, bias)
      C.part(c, B.foot:copy():cut(B.shaft), R.fgrey, { R = 6, hs = .6, bmap = fb, tex = felt, cuts = { .2, .38, .54, .7, .88 } })
      C.cylv(c, B.shaft, R.fgrey, 11 + dx, 29 + dx, { bias = bias, tex = felt, cuts = { .22, .4, .56, .72, .9 } })
      -- the fat rounded opening: a darker inside rim
      local open = c:ellipse(20 + dx, 9 + dy, 8.5, 1.5)
      C.fill(c, open, R.fgrey[1]) C.dots(c, { {14 + dx, 9 + dy}, {15 + dx, 9 + dy} }, R.fgrey[2])
      for x = 11 + dx, 29 + dx do c:put(x, 11 + dy, R.fgrey[(x < 20 + dx) and 5 + (bias or 0) or 3 + (bias or 0)]) end
      -- ankle fold creases
      C.dots(c, { {24 + dx, 37 + dy}, {25 + dx, 36 + dy}, {26 + dx, 36 + dy}, {27 + dx, 37 + dy}, {23 + dx, 38 + dy} }, R.fgrey[2 + (bias or 0) < 1 and 1 or 2 + (bias or 0)])
      -- leather heel patch with stitches
      local patch = c:rrect(9 + dx, 43 + dy, 17 + dx, 53 + dy, 3):clip(B.all)
      C.part(c, patch, R.leather, { R = 2, bias = bias })
      for y = 45 + dy, 51 + dy, 2 do c:put(16 + dx, y, R.leather[6]) end
      -- worn sole line
      for x = 11 + dx, 40 + dx do if B.foot:has(x, 52 + dy) then c:put(x, 52 + dy, R.fgrey[1]) end end
    end
    return B
  end
  local back = boot(12, -5, -1)
  local front = boot(0, 0, nil)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  -- felt highlight streak
  C.dots(c, { {13, 15}, {13, 16}, {13, 17}, {14, 18}, {14, 19}, {14, 20}, {14, 21} }, R.fgrey[6])
  C.dots(c, { {30, 41}, {31, 41}, {32, 41} }, R.fgrey[6])
  -- quirk: red wool pompom at the front of the cuff
  local pom = c:ellipse(26, 13, 3, 3)
  C.ring(c, pom, R.fgrey[1], front.shaft)
  C.part(c, pom, R.ember, { R = 2, tex = function(x, y) if (x + y) % 3 == 0 then return -1 end end })
  c:put(25, 11, R.ember[6])
  C.save(c, "footwear-2-snowdrift-felt-boots")
end

---------------------------------------------------------------- 3 poppy hide moccasins
if C.want("footwear-3") then
  local c = C.new("footwear-3-poppy-hide-moccasins")
  local function moc(dx, dy, bias)
    local M = {}
    M.body = c:poly{ {8 + dx, 42 + dy}, {9 + dx, 35 + dy}, {14 + dx, 31 + dy}, {28 + dx, 31 + dy}, {36 + dx, 35 + dy},
      {43 + dx, 36 + dy}, {48 + dx, 33 + dy}, {51 + dx, 29 + dy}, {53 + dx, 31 + dy}, {51 + dx, 38 + dy}, {45 + dx, 46 + dy},
      {36 + dx, 50 + dy}, {14 + dx, 51 + dy}, {9 + dx, 48 + dy} }
    M.collar = c:poly{ {9 + dx, 26 + dy}, {27 + dx, 26 + dy}, {28 + dx, 33 + dy}, {9 + dx, 33 + dy} }
    M.all = M.body:copy():add(M.collar)
    M.paint = function()
      local mb = C.bmap(M.body, bias)
      C.part(c, M.body, R.leather, { R = 6, hs = .7, bmap = mb, cuts = { .2, .38, .54, .7, .88 } })
      -- upturned toe seam and vamp seam (gathered pleats)
      for _, p in ipairs({ {29, 37}, {32, 36}, {35, 37}, {38, 38}, {41, 38} }) do c:put(p[1] + dx, p[2] + dy, R.leather[2]) c:put(p[1] + dx, p[2] + 1 + dy, R.leather[2]) end
      C.dots(c, { {30 + dx, 37 + dy}, {33 + dx, 36 + dy}, {36 + dx, 37 + dy}, {39 + dx, 38 + dy} }, R.leather[5])
      -- toe seam running up to the point
      C.dots(c, { {42 + dx, 39 + dy}, {44 + dx, 38 + dy}, {46 + dx, 37 + dy}, {48 + dx, 35 + dy}, {50 + dx, 32 + dy} }, R.leather[2])
      -- collar: gathered hide, puckered top
      C.sep(c, M.collar, M.body, R.leather[1])
      C.part(c, M.collar, R.leather, { R = 2, bias = (bias or 0) - 0, tex = function(x, y) if x % 3 == 0 then return -1 end end })
      for x = 9 + dx, 27 + dx do c:put(x, 26 + dy, (x % 3 == 1) and R.leather[6] or R.leather[4]) end
      -- thong lace wrapping the ankle
      for x = 8 + dx, 28 + dx do c:put(x, 31 + dy, R.strap[(x < 18 + dx) and 4 or 3]) c:put(x, 32 + dy, R.strap[2]) end
      -- sole edge
      for x = 10 + dx, 44 + dx do if M.body:has(x, 50 + dy) then c:put(x, 50 + dy, R.leather[1]) end end
    end
    return M
  end
  local back = moc(9, -8, -1)
  local front = moc(0, 0, nil)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  -- hanging lace ends
  local l1 = c:line({ {10, 33}, {7, 37}, {7, 42} }, 1)
  local l2 = c:line({ {12, 33}, {11, 38}, {12, 43} }, 1)
  l1:add(l2):each(function(x, y) c:put(x, y, R.strap[3]) end)
  C.dots(c, { {7, 43}, {12, 44} }, R.strap[1])
  -- toe glint
  C.dots(c, { {49, 31}, {50, 30} }, R.leather[6]) c:put(12, 36, C.cream)
  -- quirk: a red poppy in the lace
  local pet = c:ellipse(16, 31, 4, 3.4)
  C.part(c, pet, R.ember, { R = 2 })
  C.dots(c, { {14, 28}, {15, 28}, {13, 29}, {13, 30} }, R.ember[6])
  C.dots(c, { {16, 28}, {16, 29}, {19, 31}, {13, 32} }, R.ember[2])
  C.dots(c, { {16, 31}, {17, 31}, {16, 30} }, C.ink) c:put(17, 30, "#3f9150")
  C.save(c, "footwear-3-poppy-hide-moccasins")
end

---------------------------------------------------------------- 4 rider's red boots
if C.want("footwear-4") then
  local c = C.new("footwear-4-riders-red-boots")
  local function boot(dx, dy, bias)
    local B = {}
    B.shaft = c:poly{ {14 + dx, 13 + dy}, {26 + dx, 13 + dy}, {26 + dx, 40 + dy}, {15 + dx, 44 + dy} }
    B.foot = c:poly{ {15 + dx, 36 + dy}, {26 + dx, 36 + dy}, {32 + dx, 42 + dy}, {42 + dx, 45 + dy}, {44 + dx, 48 + dy}, {15 + dx, 48 + dy} }
      :add(c:rrect(14 + dx, 40 + dy, 22 + dx, 48 + dy, 3))
    B.fold = c:poly{ {12 + dx, 7 + dy}, {28 + dx, 7 + dy}, {27 + dx, 15 + dy}, {13 + dx, 15 + dy} }
    B.heel = c:rect(15 + dx, 49 + dy, 20 + dx, 53 + dy)
    B.sole = c:rect(22 + dx, 49 + dy, 44 + dx, 49 + dy)
    B.all = B.shaft:copy():add(B.foot):add(B.fold):add(B.heel):add(B.sole)
    B.paint = function()
      C.cylv(c, B.shaft, R.redl, 14 + dx, 26 + dx, { bias = bias, cuts = { .2, .36, .52, .7, .9 } })
      C.part(c, B.foot:copy():cut(B.shaft), R.redl, { R = 4, hs = .7, bias = bias, cuts = { .2, .36, .52, .7, .9 } })
      -- folded top, lighter inner leather
      C.cylv(c, B.fold, R.leather, 12 + dx, 28 + dx, { bias = bias })
      for x = 13 + dx, 27 + dx do c:put(x, 15 + dy, R.redl[1]) end
      for x = 13 + dx, 27 + dx do c:put(x, 8 + dy, R.leather[(x < 20 + dx) and 6 or 5]) end
      -- stacked wooden heel + thin sole
      C.part(c, B.heel, R.wood, { R = 1, bias = bias })
      for x = 15 + dx, 20 + dx do c:put(x, 51 + dy, R.wood[2]) end
      C.fill(c, B.sole, R.sole[3])
      -- ankle crease
      C.dots(c, { {24 + dx, 39 + dy}, {25 + dx, 38 + dy}, {26 + dx, 38 + dy}, {27 + dx, 39 + dy} }, R.redl[1])
    end
    return B
  end
  local back = boot(12, -4, -1)
  local front = boot(0, 0, nil)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  -- polished leather streaks
  for y = 17, 37 do c:put(16, y, R.redl[6]) end
  for y = 19, 32 do c:put(17, y, R.redl[5]) end
  c:put(16, 18, C.cream)
  C.dots(c, { {36, 44}, {37, 44}, {38, 45} }, R.redl[6])
  -- quirk: brass horseshoe heel plate, glinting
  C.dots(c, { {15, 54}, {16, 54}, {17, 54}, {18, 54}, {19, 54}, {20, 54} }, R.brass[4])
  C.dots(c, { {15, 53}, {20, 53} }, R.brass[3])
  c:put(16, 54, R.brass[6]) c:put(14, 52, R.brass[6]) c:put(13, 52, R.brass[5])
  C.save(c, "footwear-4-riders-red-boots")
end

---------------------------------------------------------------- 5 sunflower straw sandals (seen from above)
if C.want("footwear-5") then
  local c = C.new("footwear-5-sunflower-straw-sandals")
  local function sandal(cx, cy, bias)
    local S = {}
    S.sole = c:ellipse(cx, cy - 7, 9, 12):add(c:ellipse(cx, cy + 9, 8, 10)):add(c:rect(cx - 8, cy - 7, cx + 8, cy + 9))
    S.edge = S.sole:shift(1, 2):cut(S.sole)
    S.all = S.sole:copy():add(S.edge)
    S.paint = function()
      C.fill(c, S.edge, R.straw[1 + ((bias or 0) < 0 and 0 or 1)])
      S.edge:each(function(x, y) if (y % 2 == 0) then c:put(x, y, R.straw[2]) end end)
      -- plaited straw: chevron rows
      C.part(c, S.sole, R.straw, { R = 3, bias = bias, tex = function(x, y)
        local v = (y + abs(x - cx)) % 4
        if v == 0 then return -2 elseif v == 1 then return 1 end
      end })
      -- crossed leather straps
      local s1 = c:line({ {cx - 9, cy - 12}, {cx + 9, cy - 2} }, 3)
      local s2 = c:line({ {cx + 9, cy - 12}, {cx - 9, cy - 2} }, 3)
      local heel = c:line({ {cx - 8, cy + 10}, {cx - 7, cy + 15}, {cx, cy + 17}, {cx + 7, cy + 15}, {cx + 8, cy + 10} }, 2)
      local s = s2:copy():add(heel)
      C.ring(c, s, R.straw[1], S.sole)
      C.part(c, s, R.strap, { R = 1, bias = bias })
      C.ring(c, s1, C.ink, s2) -- s1 crosses over s2
      C.part(c, s1, R.strap, { R = 1, bias = bias })
      C.ring(c, s1, R.straw[1], S.sole:copy():cut(s2))
      local knot = c:rect(cx - 1, cy - 7, cx + 1, cy - 6)
      C.part(c, knot, R.strap, { R = 1, bias = (bias or 0) + 1 })
    end
    return S
  end
  local back = sandal(41, 29, -1)
  local front = sandal(24, 33, nil)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  -- quirk: sunflower-seed charm hanging off the strap end on a cord
  local cord = c:line({ {15, 30}, {12, 33}, {11, 37} }, 1)
  C.fill(c, cord, R.strap[2]) c:put(15, 30, R.strap[4])
  local seed = c:poly{ {7.5, 38}, {14.5, 38}, {15, 43}, {11.5, 50}, {7, 43} }
  C.fill(c, seed, "#3a2e34")
  C.dots(c, { {9, 39}, {9, 40}, {9, 41}, {10, 42}, {10, 43}, {10, 44}, {11, 45} }, R.fleece[6])
  C.dots(c, { {12, 39}, {13, 40}, {13, 41}, {13, 42}, {12, 43}, {12, 44} }, R.fleece[3])
  C.dots(c, { {8, 40}, {8, 41}, {8, 42}, {11, 40}, {11, 41} }, "#5e5058")
  C.save(c, "footwear-5-sunflower-straw-sandals")
end
