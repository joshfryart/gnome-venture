-- cloak.lua: SEA "Monsoon Tangle" cloak concepts 1..5 (see concepts.md).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local floor, sin, cos, rad, max, min, abs = math.floor, math.sin, math.cos, math.rad, math.max, math.min, math.abs

---------------------------------------------------------------- 1 palm-frond rain cape
do
  local c = C.canvas("cloak-1-palm-frond-rain-cape")
  local tiers = {}
  local spec = { { 9, 9, 30 }, { 18, 14, 43 }, { 30, 19, 57 } } -- top y, half width at top, bottom y
  for i = 3, 1, -1 do
    local t = spec[i]
    local hwB = t[2] + (t[3] - t[1]) * 0.36
    local pts = { { 32 - t[2], t[1] }, { 32 + t[2], t[1] } }
    local n = 14
    for j = 0, n do
      local x = 32 + hwB - j * (hwB * 2 / n)
      pts[#pts + 1] = { x, t[3] - floor(X.hash(j, i, 5) * 4) }
    end
    tiers[i] = c:poly(pts)
  end
  for i = 3, 1, -1 do
    local m = tiers[i]
    local under = HP.mask()
    for j = i + 1, 3 do under:add(tiers[j]) end
    C.sep(c, m, under, R.straw[1])
    m:shift(0, 1):cut(m):clip(under):each(function(x, y) c:put(x, y, R.straw[1]) end)
    local ti = C.lit(c, m, R.straw, (i == 2) and 0 or 1, { R = 3, cuts = { .2, .36, .52, .7, .88 } })
    -- long hanging strands
    C.retone(c, m, ti, R.straw, function(x, y)
      local h = X.hash(x, 0, i)
      if x % 2 == 0 and h < 0.75 then return -1 end
      if x % 4 == 1 and h > 0.6 then return 1 end
    end)
    -- frayed tips
    m:each(function(x, y) if not m:has(x, y + 1) and x % 2 == 0 then c:put(x, y, R.straw[2]) end end)
  end
  -- neck opening + cord tie with dangling ends
  local neck = c:ellipse(32, 9, 5, 2):clip(tiers[1])
  c:fillMask(neck, R.straw[1])
  local cord = c:line({ {27,12}, {32,13}, {37,12} }, 1)
  cord:each(function(x, y) c:put(x, y, R.blanket[3]) end)
  local ends = c:line({ {32,13}, {30,19} }, 1):add(c:line({ {32,13}, {34,20} }, 1))
  ends:each(function(x, y) c:put(x, y, R.blanket[x < 32 and 4 or 2]) end)
  C.put(c, { {30,20}, {34,21} }, R.blanket[5])
  c:put(32, 13, R.blanket[5])
  -- quirk: kingfisher perched on the left shoulder
  local kb = c:ellipse(26, 6, 3.5, 2.6)
  local kh = c:ellipse(22, 4, 2.2, 2.2)
  local beak = c:poly{ {20,4}, {14,5}, {20,6} }
  local tail = c:poly{ {29,6}, {34,9}, {33,10}, {28,8} }
  local km = kb:copy():add(kh):add(beak):add(tail)
  C.sep(c, km, tiers[1], C.ink)
  C.lit(c, tail, R.king, -1, { R = 1 })
  C.lit(c, kb, R.king, 0, { R = 2 })
  kb:each(function(x, y) if y >= 7 then c:put(x, y, R.mango[x < 26 and 5 or 4]) end end)
  C.lit(c, kh, R.king, 1, { R = 1 })
  c:put(21, 4, C.ink) c:put(22, 3, R.king[6]) c:put(21, 5, R.petal[5])
  beak:each(function(x, y) c:put(x, y, R.ink or C.ink) end)
  C.put(c, { {15,5}, {16,5}, {17,5} }, R.soga[2])
  c:put(25, 4, R.king[6]) c:put(26, 4, R.king[6])
  C.put(c, { {24,9}, {26,9} }, R.blanket[2])
  C.save(c, "cloak-1-palm-frond-rain-cape")
end

---------------------------------------------------------------- 2 banana-leaf hood
do
  local c = C.canvas("cloak-2-banana-leaf-hood")
  local leaf = c:poly{ {33,2}, {38,6}, {43,14}, {47,26}, {53,40}, {55,52}, {50,58}, {14,58}, {9,52}, {11,40}, {17,26}, {21,14}, {27,6} }
  -- splits along the bottom edge
  for _, sx in ipairs({ 17, 26, 39, 47 }) do leaf:cut(c:poly{ { sx - 0.6, 59 }, { sx + 0.6, 59 }, { sx + 0.5 + (sx < 32 and -1 or 1), 47 } }) end
  local li = C.lit(c, leaf, R.leaf, 0, { R = 6, cuts = { .2, .36, .52, .7, .86 } })
  -- veins: parallel, angled down and out from the midrib
  leaf:each(function(x, y)
    local u = (x < 32) and (y + (32 - x) * 0.6) or (y + (x - 32) * 0.6)
    if floor(u) % 4 == 0 and y > 24 then c:put(x, y, R.leaf[max(1, li[K(x, y)] - 1)]) end
  end)
  -- hood opening
  local hole = c:ellipse(32, 20, 7, 6)
  local rim = hole:grow(1):cut(hole)
  c:fillMask(hole, R.leaf[1])
  hole:each(function(x, y) if y > 22 then c:put(x, y, R.leaf[2]) end end)
  rim:each(function(x, y) c:put(x, y, (x < 32 or y < 17) and R.leaf[6] or R.leaf[3]) end)
  -- midrib from the hood down
  for y = 28, 57 do c:put(31, y, R.gecko[5]) c:put(32, y, R.gecko[3]) end
  for y = 4, 12 do c:put(32, y, R.gecko[5]) c:put(33, y, R.gecko[3]) end
  -- tie cord below the hood
  local cord = c:line({ {24,27}, {28,28}, {36,28}, {40,27} }, 1)
  cord:each(function(x, y) c:put(x, y, R.straw[4]) end)
  C.put(c, { {31,29}, {30,30}, {30,31}, {33,29}, {34,30}, {35,31} }, R.straw[3])
  -- gloss
  C.put(c, { {16,36}, {15,40}, {15,41}, {16,37}, {24,10} }, R.leaf[6]) c:put(15, 39, C.cream)
  -- quirk: raindrop rolling off the hood tip
  local drop = c:poly{ {40.5,4}, {42.5,7}, {42,9}, {39,9}, {38.5,7} }
  C.sep(c, drop, leaf, C.ink)
  C.lit(c, drop, R.water, 1, { R = 1 })
  c:put(39, 7, R.water[6])
  C.save(c, "cloak-2-banana-leaf-hood")
end

---------------------------------------------------------------- 3 batik shawl
do
  local c = C.canvas("cloak-3-batik-shawl")
  local sh = c:poly{ {4,14}, {32,10}, {60,14}, {33,52} }
  local fringe = HP.mask()
  sh:edge():each(function(x, y)
    if y > 15 and (x + y) % 2 == 0 then
      local dx = (x < 32) and -1 or 1
      for k = 1, 3 do if not sh:has(x + dx * k, y + k) then fringe:set(x + dx * k, y + k) end end
    end
  end)
  fringe:cut(sh)
  fringe:each(function(x, y) c:put(x, y, R.soga[(x + y) % 4 == 0 and 5 or 3]) end)
  local si = C.lit(c, sh, R.soga, 0, { R = 4, cuts = { .2, .36, .52, .7, .88 } })
  -- crackle lines (wax cracks let dye in)
  sh:each(function(x, y)
    local n = X.hash(x // 3, y // 3, 11)
    if (n < 0.2 and (x + y) % 3 == 0) or (n > 0.9 and (x - y) % 3 == 0) then c:put(x, y, R.soga[max(1, si[K(x, y)] - 1)]) end
  end)
  -- motifs: spiral ferns on a lattice, dots between
  -- motifs: little cream ring-flowers on a lattice, dots between
  local function ringf(cx, cy)
    local ring = { {-1,-2}, {0,-2}, {1,-2}, {2,-1}, {2,0}, {2,1}, {1,2}, {0,2}, {-1,2}, {-2,1}, {-2,0}, {-2,-1} }
    for _, p in ipairs(ring) do
      if sh:has(cx + p[1], cy + p[2]) then c:put(cx + p[1], cy + p[2], (p[1] + p[2] < 0) and C.R.cream or R.lining[4]) end
    end
    c:put(cx, cy, R.yarnA[4])
  end
  for gy = 20, 46, 8 do for gx = 6, 60, 10 do
    local ox = (gy // 8) % 2 * 5
    if sh:shrink(1):has(gx + ox + 2, gy + 2) and sh:shrink(1):has(gx + ox - 2, gy - 2) and sh:shrink(1):has(gx + ox + 2, gy - 2) and sh:shrink(1):has(gx + ox - 2, gy + 2) then ringf(gx + ox, gy) end
    if sh:has(gx + ox + 5, gy + 4) and sh:has(gx + ox + 6, gy + 5) then c:put(gx + ox + 5, gy + 4, C.R.cream) end
  end end
  -- border band along the top edge
  sh:each(function(x, y)
    local top = 10 + abs(x - 32) * (4 / 28)
    if y - top >= 0 and y - top < 3.2 then c:put(x, y, (x % 3 == 0 and y - top > 1) and C.R.cream or R.soga[max(1, (si[K(x, y)] or 3) - 1)]) end
  end)
  -- fold shading
  for y = 16, 46 do if sh:has(33, y) then c:put(33, y, R.soga[max(1, (si[K(33, y)] or 3) - 1)]) end end
  -- quirk: birdwing butterfly resting on the right corner, wings open
  local bx, by = 54, 11
  local wl = c:poly{ {bx,by}, {bx-7,by-5}, {bx-6,by+1}, {bx-4,by+4}, {bx,by+2} }
  local wr = c:poly{ {bx+1,by}, {bx+8,by-5}, {bx+7,by+1}, {bx+5,by+4}, {bx+1,by+2} }
  local bf = wl:copy():add(wr)
  C.sep(c, bf, sh, C.ink)
  c:fillMask(wl, C.ink) c:fillMask(wr, C.ink)
  wl:shrink(1):each(function(x, y) c:put(x, y, (y < by) and R.leaf[6] or R.leaf[5]) end)
  wr:shrink(1):each(function(x, y) c:put(x, y, (y < by) and R.leaf[5] or R.leaf[4]) end)
  c:put(bx - 3, by + 2, R.brass[5]) c:put(bx + 4, by + 2, R.brass[4])
  C.vline(c, bx, by - 2, by + 4, R.soga[1]) c:put(bx + 1, by - 1, R.soga[2])
  C.put(c, { {bx-1,by-4}, {bx-2,by-5}, {bx+2,by-4}, {bx+3,by-5} }, R.soga[1])
  C.save(c, "cloak-3-batik-shawl")
end

---------------------------------------------------------------- 4 net-veil mantle
do
  local c = C.canvas("cloak-4-net-veil-mantle")
  local veil = c:poly{ {21,10}, {43,10}, {45,20}, {48,32}, {53,44}, {56,52}, {8,52}, {11,44}, {16,32}, {19,20} }
  -- scalloped hem
  for x = 9, 55 do local d = floor(1.5 + 1.5 * sin(x / 1.6)) for y = 52, 52 + d do if y <= 53 + 1 then veil:set(x, y) end end end
  local vi = C.lit(c, veil, R.mint, 0, { R = 5, cuts = { .2, .36, .52, .7, .86 } })
  -- mesh: light knots on a 2 px grid, dark holes, folds every 7 px
  veil:each(function(x, y)
    local i = vi[K(x, y)]
    local fold = (x + floor((y - 10) * ((x - 32) / 44))) % 7
    local d = 0
    if fold == 0 then d = -2 elseif fold == 1 then d = 1 end
    if x % 2 == 0 and y % 2 == 0 then d = d + 1 elseif (x + y) % 2 == 1 then d = d - 1 end
    c:put(x, y, R.mint[max(1, min(6, i + d))])
  end)
  -- bead-weighted hem
  C.bottomEdge(c, veil, R.mint[2])
  for x = 11, 54, 5 do
    local bx = x local by = 52 + floor(1.5 + 1.5 * sin(x / 1.6)) + 1
    local bd = c:ellipse(bx, by + 1, 1.3, 1.3)
    C.lit(c, bd, R.wood, 0, { R = 1 }) c:put(bx - 1, by, R.wood[6])
  end
  -- bamboo hoop, interior dark
  local inner = c:ellipse(32, 9, 11, 2.6)
  local hoop = c:ellipse(32, 9, 14, 4.5):cut(inner)
  c:fillMask(inner, R.mint[1])
  C.hline(c, 23, 41, 10, R.mint[2])
  C.lit(c, hoop, R.pandan, 1, { R = 1 })
  hoop:each(function(x, y) if y < 9 then c:put(x, y, R.pandan[(x < 32) and 6 or 4]) elseif y > 10 then c:put(x, y, R.pandan[2]) end end)
  C.put(c, { {22,12}, {42,12}, {32,13}, {32,14} }, R.strap[3])
  -- hanging loop
  local lp = c:line({ {28,5}, {30,1}, {34,1}, {36,5} }, 1)
  lp:cut(hoop):each(function(x, y) c:put(x, y, R.strap[3]) end)
  -- quirk: firefly glowing on the veil
  local glow = c:ellipse(44, 34, 2.6, 2.6)
  glow:each(function(x, y) c:put(x, y, R.gecko[6]) end)
  c:fillMask(c:ellipse(44, 34, 1.2, 1.2), R.brass[6])
  c:put(44, 34, C.cream)
  C.put(c, { {42,31}, {43,31}, {46,31}, {47,31} }, R.mint[6])
  C.put(c, { {44,31}, {45,31} }, C.ink)
  C.put(c, { {48,36}, {41,37}, {47,38} }, R.gecko[6])
  C.save(c, "cloak-4-net-veil-mantle")
end

---------------------------------------------------------------- 5 monsoon poncho
do
  local c = C.canvas("cloak-5-monsoon-poncho")
  local hood = c:ellipse(32, 11, 11, 7)
  local po = c:poly{ {21,13}, {43,13}, {59,33}, {33,58}, {31,58}, {5,33} }
  C.lit(c, hood, R.mango, -1, { R = 3 })
  local inside = c:ellipse(32, 12, 7, 4)
  c:fillMask(inside, R.mango[1])
  C.hline(c, 27, 37, 9, R.mango[2])
  C.sep(c, po, hood, R.mango[1])
  local pi = C.lit(c, po, R.mango, 0, { R = 6, cuts = { .2, .36, .52, .7, .88 } })
  -- stitched seam inset along the edges, centre seam
  po:shrink(2):edge():each(function(x, y) if (x + y) % 3 ~= 0 and y > 16 then c:put(x, y, R.mango[max(1, pi[K(x, y)] - 1)]) end end)
  for y = 18, 56 do if y % 3 ~= 0 then c:put(32, y, R.mango[max(1, (pi[K(32, y)] or 3) - 1)]) end end
  -- folds and rubber sheen
  C.put(c, { {16,30}, {17,31}, {18,32}, {46,30}, {45,31}, {44,32} }, R.mango[2])
  for i = 0, 6 do c:put(14 + i, 27 - i, R.mango[6]) end
  c:put(15, 26, C.cream)
  -- neck: drawstring cords and wooden toggle
  local cl = c:line({ {29,17}, {28,24} }, 1):add(c:line({ {35,17}, {36,24} }, 1))
  cl:each(function(x, y) c:put(x, y, R.strap[3]) end)
  local tog = c:rrect(26, 24, 30, 27, 1)
  C.lit(c, tog, R.wood, 1, { R = 1 })
  c:put(36, 25, R.strap[4]) c:put(36, 26, R.strap[2])
  -- quirk: pitcher-plant cup hanging from the toggle
  local str = c:line({ {28,28}, {28,31} }, 1)
  str:each(function(x, y) c:put(x, y, R.leaf[3]) end)
  local cup = c:ellipse(28, 38, 3.5, 5):add(c:rrect(25, 32, 31, 35, 1))
  local lid = c:poly{ {25,31}, {32,29}, {33,31}, {27,32} }
  C.sep(c, cup:copy():add(lid), po, C.ink)
  C.lit(c, cup, R.leaf, 1, { R = 2 })
  cup:each(function(x, y) if y > 35 and X.hash(x, y, 2) < 0.3 then c:put(x, y, R.hibis[3]) end end)
  C.hline(c, 25, 31, 33, R.hibis[4]) C.hline(c, 26, 30, 34, R.leaf[1])
  C.lit(c, lid, R.leaf, 1, { R = 1 })
  c:put(26, 37, R.leaf[6]) c:put(26, 38, R.leaf[6])
  C.save(c, "cloak-5-monsoon-poncho")
end
