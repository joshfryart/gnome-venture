-- EE backpacks: 5 concepts (see concepts.md). Run: AppRun -b --script-param png=<dir>/ --script backpack.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R = C.HP, C.X, C.K, C.R
local floor, max, min, abs = math.floor, math.max, math.min, math.abs

---------------------------------------------------------------- 1 birchbark pester
if C.want("backpack-1") then
  local c = C.new("backpack-1-birchbark-pester")
  local body = c:rrect(15, 16, 45, 57, 4)
  -- two shoulder straps arching up behind the lid
  local loop = c:line({ {19, 13}, {20, 5}, {25, 3}, {27, 9} }, 3):add(c:line({ {41, 13}, {40, 5}, {35, 3}, {33, 9} }, 3))
  C.part(c, loop, R.strap, { R = 1, bias = -1 })
  C.dots(c, { {20, 5}, {21, 4}, {39, 4} }, R.strap[5])
  -- checker plait: 4px squares, alternate light/dark, offset rows
  local plait = function(x, y, i)
    local bx, by = floor((x - 15) / 5), floor((y - 16) / 5)
    local lx, ly = (x - 15) % 5, (y - 16) % 5
    if lx == 4 or ly == 4 then return -2 end
    if (bx + by) % 2 == 0 then return (ly == 0) and 1 or 0 else return (lx == 0) and 0 or -1 end
  end
  C.cylv(c, body, R.birch, 15, 45, { tex = plait, cuts = { .2, .36, .52, .7, .9 } })
  -- bark dashes on the light squares
  for _, p in ipairs({ {18, 23}, {29, 28}, {23, 38}, {34, 43}, {19, 48}, {39, 33}, {28, 53}, {38, 23} }) do
    c:put(p[1], p[2], R.birch[1]) c:put(p[1] + 1, p[2], R.birch[2])
  end
  -- leather rim band at the top and base
  local band = c:rect(15, 22, 45, 24)
  C.cylv(c, band, R.strap, 15, 45)
  for x = 15, 45 do c:put(x, 22, R.strap[(x < 30) and 6 or 4]) end
  local base = c:rect(15, 53, 45, 57):clip(body)
  C.cylv(c, base, R.strap, 15, 45, { bias = -1 })
  for x = 16, 44, 3 do c:put(x, 55, R.strap[1]) end
  -- lid: a shallow bark cap, slightly wider
  local lid = c:rrect(13, 12, 47, 20, 3)
  C.part(c, lid, R.birch, { R = 2, tex = function(x, y) if x % 4 == 0 then return -1 end end })
  for x = 14, 46 do c:put(x, 20, R.birch[1]) end
  -- wooden peg through a loop on the lid
  local peg = c:rect(28, 8, 32, 13)
  C.part(c, peg, R.wood, { R = 1 })
  c:put(29, 8, R.wood[6])
  -- quirk: a red-capped mushroom peeking from under the lid
  local stem = c:rect(18, 18, 21, 22)
  local cap = c:ellipse(19.5, 16, 7, 4.5):cut(c:rect(10, 19, 30, 30))
  C.ring(c, cap, R.birch[1], c:rect(0, 0, 64, 64):cut(c:rect(0, 0, 64, 11)))
  C.fill(c, stem, R.linen[5]) for y = 18, 22 do c:put(21, y, R.linen[3]) end for x = 18, 21 do c:put(x, 23, R.strap[1]) end c:put(18, 18, R.linen[6])
  C.part(c, cap, R.ember, { R = 2 })
  C.dots(c, { {16, 14}, {17, 14}, {21, 15}, {19, 12}, {23, 17}, {15, 17} }, R.linen[6])
  for x = 12, 27 do if cap:has(x, 18) then c:put(x, 18, R.ember[1]) end end
  -- highlight
  C.dots(c, { {18, 28}, {18, 29}, {18, 30} }, R.birch[6])
  C.save(c, "backpack-1-birchbark-pester")
end

---------------------------------------------------------------- 2 harvest wicker basket
if C.want("backpack-2") then
  local c = C.new("backpack-2-harvest-wicker-basket")
  local body = c:poly{ {9, 20}, {55, 20}, {47, 57}, {17, 57} }:add(c:rrect(17, 52, 47, 58, 3))
  -- sunflower and wheat behind the rim
  local stalk = c:line({ {38, 20}, {40, 12}, {42, 6} }, 1):add(c:line({ {44, 20}, {48, 10} }, 1))
  local ears = c:ellipse(42, 4, 1.5, 3):add(c:ellipse(48, 7, 1.5, 3))
  C.fill(c, stalk, R.straw[3])
  C.part(c, ears, R.straw, { R = 1, tex = function(x, y) if y % 2 == 0 then return -1 end end })
  local sf = c:ellipse(24, 12, 10, 9)
  C.part(c, sf, R.brass, { R = 3, tex = function(x, y)
    local a = math.atan(y - 12, x - 24)
    if floor(a * 12 / math.pi) % 2 == 0 then return -1 end
  end, cuts = { .18, .34, .5, .68, .86 } })
  local disc = c:ellipse(24, 12, 5, 4.5)
  C.ring(c, disc, R.brass[1])
  C.part(c, disc, R.wood, { R = 2, bias = -1, tex = function(x, y) if (x + y) % 2 == 0 then return -1 end end })
  C.dots(c, { {22, 10}, {23, 9} }, R.wood[5])
  local leaf = c:poly{ {12, 18}, {14, 13}, {20, 15}, {18, 20} }
  C.part(c, leaf, R.leaf, { R = 1 })
  -- the basket
  C.sep(c, body, sf:copy():add(stalk):add(ears):add(leaf), C.ink)
  local weave = function(x, y, i)
    local row = floor((y - 20) / 3)
    local ly = (y - 20) % 3
    if ly == 2 then return -2 end
    if (floor(x / 4) + row) % 2 == 0 then return (ly == 0) and 1 or 0 else return -1 end
  end
  C.part(c, body, R.wicker, { R = 5, tex = weave, cuts = { .2, .36, .52, .7, .88 } })
  -- upright stakes
  for _, sx in ipairs({ 18, 25, 32, 39, 46 }) do
    body:each(function(x, y) if y > 24 and x == sx + floor((y - 20) * (32 - sx) / 140) then c:put(x, y, R.wicker[1]) end end)
  end
  -- rolled rim
  local rim, rn = C.X.cyl(9, 21, 55, 21, function() return 2.5 end)
  C.X.tone(c, rim, C.X.light(rn, { amb = .08, wrap = .25 }), R.wicker, { cuts = C.CUTS })
  rim:each(function(x, y) if (x + y) % 3 == 0 then c:put(x, y, R.wicker[2]) end end)
  for x = 10, 54 do c:put(x, 23, R.wicker[1]) end
  -- rope shoulder loops at the sides
  local r1 = c:line({ {10, 25}, {6, 32}, {9, 40} }, 2)
  local r2 = c:line({ {54, 25}, {58, 32}, {55, 40} }, 2)
  r1:add(r2):cut(body):each(function(x, y) c:put(x, y, R.canvas[(x < 32) and 5 or 3]) end)
  -- glints
  C.dots(c, { {14, 19}, {15, 19} }, R.wicker[6])
  C.save(c, "backpack-2-harvest-wicker-basket")
end

---------------------------------------------------------------- 3 beekeeper's frame
if C.want("backpack-3") then
  local c = C.new("backpack-3-beekeepers-frame")
  -- A-frame poles + crossbars
  local poles = c:line({ {22, 5}, {12, 59} }, 3):add(c:line({ {42, 5}, {52, 59} }, 3))
  local bars = c:rect(14, 50, 50, 52):add(c:rect(19, 14, 45, 15))
  C.part(c, bars, R.wood, { R = 1, bias = -1 })
  C.sep(c, poles, bars, C.ink)
  C.part(c, poles, R.wood, { R = 1, tex = function(x, y) if y % 6 == 0 then return -1 end end })
  C.dots(c, { {21, 6}, {41, 6} }, R.wood[6])
  -- straw skep dome
  local skep = c:ellipse(32, 34, 14, 15):cut(c:rect(0, 46, 64, 64)):add(c:rrect(17, 40, 47, 47, 2))
  C.sep(c, skep, poles:copy():add(bars), C.ink)
  C.part(c, skep, R.straw, { R = 6, hs = .7, tex = function(x, y, i)
    local ly = (y - 19) % 4
    if ly == 3 then return -2 elseif ly == 0 then return 1 end
    if (x * 2 + y) % 7 == 0 then return -1 end
  end, cuts = { .2, .36, .52, .7, .88 } })
  -- binding stitches on the coils
  for y = 22, 44, 4 do for x = 20, 44, 6 do if skep:has(x + (y % 8 == 2 and 3 or 0), y) then c:put(x + (y % 8 == 2 and 3 or 0), y, R.strap[2]) end end end
  -- entrance hole
  local hole = c:ellipse(32, 44, 3, 2):cut(c:rect(0, 46, 64, 64))
  C.fill(c, hole, C.ink) c:put(31, 43, "#4a3236")
  -- rope lashing across the skep
  local rope = c:line({ {17, 26}, {47, 40} }, 2):clip(skep:copy():add(poles))
  C.ring(c, rope, R.straw[1], skep)
  C.part(c, rope, R.canvas, { R = 1 })
  rope:each(function(x, y) if (x + y) % 3 == 0 then c:put(x, y, R.canvas[2]) end end)
  -- skep top knob
  local knob = c:ellipse(32, 19, 3, 2)
  C.part(c, knob, R.straw, { R = 1, bias = 1 })
  -- quirk: a bee buzzing by
  local bee = c:ellipse(52, 18, 2.5, 2)
  C.fill(c, bee, R.brass[4])
  C.dots(c, { {51, 17}, {51, 18}, {51, 19}, {53, 17}, {53, 18}, {53, 19} }, C.ink)
  C.dots(c, { {50, 15}, {51, 14}, {52, 15}, {53, 14}, {54, 15} }, R.jay[6])
  c:put(55, 18, C.ink) c:put(49, 18, R.brass[6])
  C.dots(c, { {46, 22}, {45, 21} }, R.jay[5])
  C.save(c, "backpack-3-beekeepers-frame")
end

---------------------------------------------------------------- 4 flat-weave satchel
if C.want("backpack-4") then
  local c = C.new("backpack-4-flat-weave-satchel")
  local handle = c:line({ {18, 15}, {20, 7}, {32, 4}, {44, 7}, {46, 15} }, 3)
  local body = c:rrect(12, 12, 52, 48, 4)
  C.part(c, handle:copy():cut(body), R.strap, { R = 1 })
  C.sep(c, body, handle, C.ink)
  -- stepped diamonds woven in bands
  local function pat(x, y)
    local by = (y - 12)
    if by < 4 or by > 32 then return "edge" end
    local band = floor((by - 4) / 10)
    local ly = (by - 4) % 10
    if ly == 9 then return "line" end
    local dx = abs(((x - 12) % 10) - 5)
    local dy = abs(ly - 4)
    local d = floor(dx / 2) * 2 + dy
    if d <= 1 then return "core" elseif d <= 4 then return "dia" end
    return "ground"
  end
  local idx = C.part(c, body, R.yarnA, { R = 4, cuts = { .2, .36, .52, .7, .9 } })
  body:each(function(x, y)
    local i = idx[K(x, y)]
    local p = pat(x, y)
    if p == "dia" then c:put(x, y, R.straw[max(1, min(6, i))])
    elseif p == "core" then c:put(x, y, R.yarnB[max(1, min(6, i))])
    elseif p == "line" then c:put(x, y, R.yarnA[max(1, i - 2)])
    elseif p == "edge" and (x % 2 == 0) then c:put(x, y, R.yarnA[max(1, i - 1)]) end
  end)
  -- weft lines
  body:each(function(x, y) if y % 2 == 0 and C.hash(x, y, 4) < .15 then local i = idx[K(x, y)] c:put(x, y, R.yarnA[max(1, i - 1)]) end end)
  -- tassels along the bottom
  for i, tx in ipairs({ 15, 21, 27, 33, 39, 45, 49 }) do
    local ramp = (i == 4) and R.yarnB or R.yarnA
    local t = c:rect(tx, 49, tx + 1, 56)
    C.fill(c, t, ramp[4]) for y = 49, 56 do c:put(tx + 1, y, ramp[2]) end
    c:put(tx, 49, ramp[1]) c:put(tx + 1, 49, ramp[1])
    local knot = c:rect(tx - 0, 50, tx + 1, 51)
    C.fill(c, knot, ramp[5]) c:put(tx + 1, 51, ramp[3])
    c:put(tx, 57, ramp[3])
  end
  -- glint
  C.dots(c, { {15, 15}, {16, 15}, {15, 16} }, R.yarnA[6])
  C.save(c, "backpack-4-flat-weave-satchel")
end

---------------------------------------------------------------- 5 fleece drawsack
if C.want("backpack-5") then
  local c = C.new("backpack-5-fleece-drawsack")
  local sack = c:ellipse(32, 40, 19, 16):add(c:poly{ {22, 26}, {26, 15}, {38, 15}, {42, 26} })
  -- scalloped woolly silhouette
  local sc = HP.mask()
  sack:edge():each(function(x, y) if (x + y) % 4 == 0 and y > 20 and y < 50 then sc:add(c:ellipse(x, y, 1, 1)) end end)
  sack:add(sc)
  local ruff = c:poly{ {22, 7}, {42, 7}, {38, 15}, {26, 15} }:add(c:ellipse(32, 8, 11, 3))
  local base = sack:copy():clip(c:rect(0, 49, 64, 64))
  local si = C.part(c, sack, R.fleece, { R = 7, hs = .6, cuts = { .2, .36, .52, .7, .88 } })
  -- curls: 2x2 bobbles on a staggered grid, lit top-left, shaded bottom-right
  sack:each(function(x, y)
    local row = floor(y / 4)
    if (x + (row % 2) * 2) % 4 == 0 and y % 4 == 0 and not base:has(x, y + 2) then
      local i = si[K(x, y)] or 3
      c:put(x, y, R.fleece[min(6, i + 1)])
      if sack:has(x + 1, y) then c:put(x + 1, y, R.fleece[i]) end
      if sack:has(x, y + 1) then c:put(x, y + 1, R.fleece[max(1, i - 1)]) end
      if sack:has(x + 1, y + 1) then c:put(x + 1, y + 1, R.fleece[max(1, i - 2)]) end
    end
  end)
  -- leather base
  C.part(c, base, R.leather, { R = 3, bias = -1 })
  sack:each(function(x, y) if y == 49 then c:put(x, y, R.leather[5]) end end)
  for x = 16, 48, 4 do if base:has(x, 51) then c:put(x, 51, R.leather[5]) end end
  -- gathered neck ruffle
  C.sep(c, ruff, sack, C.ink)
  C.part(c, ruff, R.fleece, { R = 2, tex = function(x, y) if x % 3 == 0 then return -2 end end })
  -- drawcord
  local cord = c:rect(25, 15, 39, 16)
  C.fill(c, cord, R.strap[3]) for x = 25, 39 do c:put(x, 15, R.strap[5]) end
  local dang = c:line({ {39, 16}, {43, 21}, {44, 27} }, 1)
  C.fill(c, dang, R.strap[3])
  -- quirk: small brass bell on the cord
  local bell = c:poly{ {42, 27}, {46, 27}, {48, 33}, {40, 33} }:add(c:ellipse(44, 27, 2, 1.5))
  C.ring(c, bell, R.fleece[1], sack)
  C.part(c, bell, R.brass, { R = 2 })
  C.dots(c, { {41, 33}, {42, 33}, {43, 33}, {44, 33}, {45, 33}, {46, 33}, {47, 33} }, R.brass[2])
  c:put(44, 34, C.ink) c:put(42, 29, R.brass[6]) c:put(43, 28, C.cream)
  -- fleece pop
  C.dots(c, { {20, 33}, {21, 32} }, C.cream)
  C.save(c, "backpack-5-fleece-drawsack")
end
