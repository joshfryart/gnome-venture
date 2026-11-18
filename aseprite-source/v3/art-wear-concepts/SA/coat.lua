-- coat.lua: SA "Rainroot Reaches" coat concepts, 5 icons (see concepts.md).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local abs, floor, sqrt, max, min, sin, pi = math.abs, math.floor, math.sqrt, math.max, math.min, math.sin, math.pi
local CUT = { .2, .36, .52, .7, .88 }

---------------------------------------------------------------- 1 fleece vest
do
  local c = C.new("coat-1-fleece-vest")
  local vest = c:poly{ {18,8}, {27,7}, {32,24}, {37,7}, {46,8}, {50,14}, {46,22}, {45,30}, {49,52}, {40,56}, {32,55}, {24,56}, {15,52}, {19,30}, {18,22}, {14,14} }
  local back = c:poly{ {26,6}, {38,6}, {32,25} }
  C.lit(c, back, R.alpaca, { R = 2, bias = -2 })
  C.hline(c, 27, 37, 6, R.felt[3])
  C.sep(c, vest, back, R.alpaca[1])
  local vi = C.lit(c, vest, R.alpaca, { R = 6, hs = 0.8, cuts = CUT })
  -- curly fleece
  C.retone(c, vest, vi, R.alpaca, function(x, y)
    local u, v = (x + (floor(y / 3) % 2) * 2) % 4, y % 3
    if u == 0 and v == 1 then return -1 elseif u == 1 and v == 0 then return 1 elseif u == 2 and v == 2 and X.hash(x, y, 1) < .5 then return -1 end
  end)
  -- felt-stitched border down the front opening and along the hem
  local edgeF = HP.mask()
  vest:each(function(x, y)
    local onFront = (y > 7 and y <= 24 and (abs(x - 32) - (24 - y) * 0.29) < 2.2 and abs(x - 32) - (24 - y) * 0.29 >= 0)
    if onFront or (y >= 24 and abs(x - 32) <= 1) or not vest:has(x, y + 2) then edgeF:set(x, y) end
  end)
  edgeF:each(function(x, y) c:put(x, y, R.felt[(x < 32) and 5 or 3]) end)
  C.vline(c, 32, 25, 55, R.felt[1])
  for y = 27, 53, 3 do c:put(31, y, R.alpaca[6]) end
  for x = 17, 47, 3 do if vest:has(x, 53) then c:put(x, 53, R.alpaca[6]) end end
  -- armhole shade
  C.put(c, { {19,23}, {19,24}, {19,25}, {20,26} }, R.alpaca[2]) C.put(c, { {45,23}, {45,24}, {45,25}, {44,26} }, R.alpaca[1])
  -- wooden toggle with cord loop
  local tog = c:rrect(28, 32, 36, 34, 1)
  C.sep(c, tog, vest, R.alpaca[2])
  C.lit(c, tog, R.wood, { R = 1 })
  C.hline(c, 29, 35, 32, R.wood[6])
  c:put(36, 35, R.strap[2]) c:put(37, 34, R.strap[2])
  -- quirk: a wool tuft sticking up off the left shoulder
  local tuft = c:ellipse(20, 6, 2, 2):add(c:ellipse(17, 5, 1.5, 1.5)):add(c:ellipse(22, 3, 1.3, 1.6))
  tuft:cut(vest)
  C.lit(c, tuft, R.alpaca, { R = 1, bias = 1 })
  c:put(17, 4, C.cream) c:put(22, 2, C.cream)
  c:put(22, 14, C.cream) c:put(23, 14, R.alpaca[6])
  C.save(c, "coat-1-fleece-vest")
end

---------------------------------------------------------------- 2 shingle leaf smock
do
  local c = C.new("coat-2-shingle-leaf-smock")
  local rows = {
    { y = 41, x0 = 16, x1 = 48 }, { y = 34, x0 = 17, x1 = 47 }, { y = 27, x0 = 18, x1 = 46 },
    { y = 20, x0 = 6, x1 = 58 }, { y = 13, x0 = 8, x1 = 56 },
  }
  local sil = c:poly{ {22,10}, {42,10}, {53,15}, {57,31}, {47,32}, {46,26}, {48,64}, {16,64}, {18,26}, {17,32}, {7,31}, {11,15} }
  local done = HP.mask()
  local lastLeaf
  for ri, rw in ipairs(rows) do
    local off = (ri % 2 == 0) and 3.5 or 0
    local row = HP.mask()
    local leaves = {}
    local x = rw.x0 + 3 + off
    while x <= rw.x1 - 3 do
      local m, n, T, S = G.blade(x, rw.y, x + 0.3, rw.y + 6, x + 0.5, rw.y + 13, function(t) return max(0, 4.6 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.6) end, { fold = 0.4 })
      leaves[#leaves + 1] = { m = m, n = n, T = T, S = S, x = x }
      row:add(m)
      x = x + 7
    end
    row:cut(c:rect(0, 0, 63, rw.y - 1)):clip(sil)
    C.sep(c, row, done, R.leafG[1])
    for li, L in ipairs(leaves) do
      local m = L.m:copy():clip(row)
      local ramp = ((li + ri) % 2 == 0) and R.leafG or R.leafY
      local b = {} m:each(function(px, py) b[K(px, py)] = (ri <= 2 and -1 or 0) end)
      C.toneN(c, m, L.n, ramp, { cuts = CUT, bias = b })
      m:each(function(px, py)
        local s, t = L.S[K(px, py)], L.T[K(px, py)]
        if s and abs(s) < 0.1 and t > 0.15 and t < 0.9 then c:put(px, py, ramp[5]) end
      end)
      -- shadow line where this leaf meets its neighbour on the right
      m:each(function(px, py) if not m:has(px + 1, py) and row:has(px + 1, py) then c:put(px, py, ramp[1]) end end)
      if ri == 1 and li == 3 then lastLeaf = L end
    end
    -- the row above casts a dark band on this row's top
    done:add(row)
  end
  -- collar: braided cord neckband
  local col = c:ellipse(32, 12, 9, 3.2):cut(c:ellipse(32, 11, 6, 1.6))
  C.sep(c, col, done, R.leafG[1])
  C.lit(c, col, R.strap, { R = 1 })
  col:each(function(x, y) if (x + y) % 3 == 0 then c:put(x, y, R.strap[2]) end end)
  local hole = c:ellipse(32, 11, 6, 1.6)
  c:fillMask(hole, R.leafG[1])
  -- spec on the top-left leaves
  c:put(13, 17, R.leafY[6]) c:put(13, 18, C.cream)
  -- quirk: raindrop running down a bottom leaf and hanging off its tip
  local tipx = lastLeaf and floor(lastLeaf.x + 0.5) or 32
  local drop = c:poly{ {tipx + .5, 55}, {tipx + 2.5, 58.5}, {tipx + 2, 60}, {tipx - 1, 60}, {tipx - 1.5, 58.5} }
  C.lit(c, drop, R.water, { R = 1 })
  c:put(tipx - 1, 58, C.cream)
  C.put(c, { {tipx - 1, 46}, {tipx - 1, 47}, {tipx - 1, 49} }, R.water[5])
  C.save(c, "coat-2-shingle-leaf-smock")
end

---------------------------------------------------------------- 3 warp-stripe jacket
do
  local c = C.new("coat-3-warp-stripe-jacket")
  local body = c:poly{ {19,9}, {27,8}, {32,13}, {37,8}, {45,9}, {47,50}, {17,50} }
  local slL = c:poly{ {19,9}, {13,12}, {8,40}, {15,42}, {20,22} }
  local slR = c:poly{ {45,9}, {51,12}, {56,40}, {49,42}, {44,22} }
  local seq = { R.yarnA, R.yarnA, R.straw, R.indigo, R.indigo, R.straw, R.yarnA, R.yarnA, R.alpaca, R.leafG }
  local stripe = function(x, y) return seq[floor(abs(x - 32) / 2) % #seq + 1] end
  for _, sl in ipairs({ slL, slR }) do
    local sb = (sl == slR) and -1 or 0
    local si = C.litm(c, sl, function(x, y) return seq[floor((y - (sl == slL and -x or x) * 0.2) / 2) % #seq + 1] end, { R = 3, bias = sb - 1, cuts = CUT })
  end
  -- turned cuffs
  local cufL = c:poly{ {7,36}, {15,38}, {15,43}, {7,41} }
  local cufR = c:poly{ {57,36}, {49,38}, {49,43}, {57,41} }
  C.lit(c, cufL, R.indigo, { R = 1 }) C.lit(c, cufR, R.indigo, { R = 1, bias = -1 })
  C.sep(c, body, slL:copy():add(slR), R.yarnA[1])
  C.litm(c, body, stripe, { R = 6, hs = 0.7, cuts = CUT })
  -- front opening, hem band
  C.vline(c, 32, 14, 50, R.indigo[1]) C.vline(c, 31, 14, 50, R.alpaca[5])
  for x = 17, 47 do if body:has(x, 49) then c:put(x, 49, R.indigo[2]) c:put(x, 48, R.indigo[4]) end end
  -- collar band
  local col = c:line({ {27,8}, {31,13}, {31,15} }, 2):add(c:line({ {37,8}, {33,13}, {33,15} }, 2))
  C.lit(c, col, R.indigo, { R = 1 })
  c:put(27, 8, R.indigo[6])
  local neck = c:poly{ {28,7}, {36,7}, {32,12} }
  c:fillMask(neck:cut(col), R.indigo[1])
  -- tie toggles
  for _, y in ipairs({ 22, 32 }) do C.hline(c, 30, 34, y, R.brass[4]) c:put(30, y, R.brass[6]) c:put(34, y, R.brass[2]) end
  -- quirk: embroidered flower patch on the left chest
  local patch = c:rrect(20, 17, 27, 24, 1)
  C.sep(c, patch, body, R.yarnA[1])
  C.lit(c, patch, R.alpaca, { R = 1, bias = 1 })
  C.put(c, { {23,19}, {24,19}, {22,20}, {25,20}, {23,21}, {24,21} }, R.pink[3])
  C.put(c, { {23,20}, {24,20} }, R.brass[5])
  C.put(c, { {22,22}, {23,22}, {25,22} }, R.leafG[4])
  C.put(c, { {20,17}, {22,17}, {24,17}, {26,17} }, R.pink[2])
  C.save(c, "coat-3-warp-stripe-jacket")
end

---------------------------------------------------------------- 4 bark-cloth tunic coat
do
  local c = C.new("coat-4-bark-cloth-tunic-coat")
  local body = c:poly{ {20,10}, {44,10}, {47,56}, {17,56} }
  local sleeves = c:poly{ {20,10}, {7,14}, {5,30}, {16,30}, {20,24} }:add(c:poly{ {44,10}, {57,14}, {59,30}, {48,30}, {44,24} })
  local all = body:copy():add(sleeves)
  local ai = C.lit(c, all, R.bark, { R = 6, hs = 0.6, cuts = CUT })
  -- beaten fibre lines + mottling
  C.retone(c, all, ai, R.bark, function(x, y)
    if y % 3 == 0 and X.hash(x, y, 8) < .55 then return -1 end
    if X.hash(x, y, 2) > .93 then return 1 end
  end)
  -- sleeve openings (dark) and sleeve seams
  C.hline(c, 6, 15, 30, R.bark[1]) C.hline(c, 6, 15, 29, R.bark[2])
  C.hline(c, 49, 58, 30, R.bark[1]) C.hline(c, 49, 58, 29, R.bark[2])
  C.put(c, { {20,12}, {20,16}, {20,20}, {20,23} }, R.bark[3]) C.put(c, { {44,12}, {44,16}, {44,20}, {44,23} }, R.bark[2])
  -- printed leaf marks (dotted chevrons)
  for gy = 0, 6 do for gx = -4, 4 do
    local x, y = 32 + gx * 6 + (gy % 2) * 3, 15 + gy * 6
    if all:has(x - 1, y) and all:has(x + 1, y + 2) and y < 50 and not (abs(x - 32) < 3) and not (y >= 31 and y <= 37) then
      C.put(c, { {x,y}, {x-1,y+1}, {x+1,y+1} }, R.felt[2])
      c:put(x, y + 2, R.felt[3])
    end
  end end
  -- neck opening and front edge
  local neck = c:ellipse(32, 10, 5, 2.5)
  c:fillMask(neck, R.bark[1])
  C.vline(c, 32, 13, 56, R.bark[2])
  -- belt
  local belt = c:rect(18, 33, 46, 36)
  belt:clip(body)
  C.lit(c, belt, R.strap, { R = 1 })
  C.hline(c, 18, 46, 33, R.strap[5])
  local knot = c:rrect(30, 32, 34, 37, 1)
  C.lit(c, knot, R.strap, { R = 1, bias = 1 })
  C.put(c, { {31,38}, {31,39}, {31,40}, {33,38}, {34,39}, {34,40}, {34,41} }, R.strap[3])
  c:put(9, 16, C.cream) c:put(10, 16, R.bark[6])
  -- quirk: blue morpho butterfly resting on the right shoulder
  local wings = c:poly{ {46,6}, {52,1}, {55,5}, {51,9} }:add(c:poly{ {46,6}, {40,1}, {37,5}, {41,9} })
  wings:add(c:ellipse(49, 10, 1.6, 1.6)):add(c:ellipse(43, 10, 1.6, 1.6))
  C.sep(c, wings, all, R.bark[1])
  C.lit(c, wings, R.jay, { R = 1, bias = 1 })
  C.put(c, { {53,2}, {54,3}, {54,5}, {39,2}, {38,3}, {38,5}, {50,11}, {42,11} }, R.jay[1])
  C.put(c, { {49,4}, {50,4}, {42,4}, {43,4} }, R.jay[6]) c:put(41, 3, C.cream)
  C.vline(c, 46, 4, 10, C.ink)
  c:put(45, 2, C.ink) c:put(47, 2, C.ink) c:put(45, 3, C.ink) c:put(47, 3, C.ink)
  C.save(c, "coat-4-bark-cloth-tunic-coat")
end

---------------------------------------------------------------- 5 kapok puffer
do
  local c = C.new("coat-5-kapok-puffer")
  local puffs = {}
  for i = 0, 4 do
    local y = 14 + i * 8
    puffs[#puffs + 1] = { m = c:rrect(19 - floor(i / 2), y, 45 + floor(i / 2), y + 8, 4), y0 = y, y1 = y + 8 }
  end
  local sleeve = function(sx, dir)
    local segs = {}
    for i = 0, 3 do
      local cx, cy = sx + dir * (i * 1.3), 18 + i * 7
      segs[#segs + 1] = { m = c:ellipse(cx, cy, 4.6, 4.2), cy = cy }
    end
    return segs
  end
  local sL, sR = sleeve(15, -1), sleeve(49, 1)
  local bodyAll = HP.mask() for _, p in ipairs(puffs) do bodyAll:add(p.m) end
  -- sleeves behind the body; paint bottom segment first so upper ones overlap
  for _, segs in ipairs({ sL, sR }) do
    local acc = HP.mask()
    for i = #segs, 1, -1 do
      local m = segs[i].m:copy():cut(acc)
      C.sep(c, m, acc, R.cacao[1])
      local n = {}
      m:each(function(x, y) local t = max(-.95, min(.95, (y - segs[i].cy) / 4.8)) n[K(x, y)] = { (segs == sL) and -0.35 or 0.35, t, sqrt(1 - t * t) } end)
      C.toneN(c, m, n, R.cacao, { cuts = CUT, bias = (segs == sR) and {} or nil })
      acc:add(segs[i].m)
    end
    -- cuffs
  end
  C.sep(c, bodyAll, sL[1].m:copy():add(sL[2].m):add(sL[3].m):add(sL[4].m):add(sR[1].m):add(sR[2].m):add(sR[3].m):add(sR[4].m), R.cacao[1])
  -- body puffs: horizontal cylinders, upper one overlaps the next
  local acc = HP.mask()
  for i = #puffs, 1, -1 do
    local p = puffs[i]
    local m = p.m:copy():cut(acc)
    local n = {}
    m:each(function(x, y)
      local t = max(-.95, min(.95, ((y - p.y0) / (p.y1 - p.y0)) * 2 - 1))
      local sx = max(-.6, min(.6, (x - 32) / 26))
      n[K(x, y)] = { sx, t * 0.95, sqrt(max(0.05, 1 - t * t - sx * sx * 0.3)) }
    end)
    C.toneN(c, m, n, R.cacao, { cuts = { .18, .34, .5, .68, .86 } })
    -- stitched seam under each puff
    m:each(function(x, y) if not m:has(x, y + 1) and acc:has(x, y + 1) then c:put(x, y, R.cacao[1]) end end)
    acc:add(p.m)
  end
  -- front closure with toggles
  C.vline(c, 32, 14, 54, R.cacao[1]) C.vline(c, 31, 14, 54, R.cacao[5])
  for _, y in ipairs({ 18, 26, 34, 42, 50 }) do C.put(c, { {30,y}, {31,y}, {33,y} }, R.wood[5]) c:put(32, y, R.wood[3]) end
  -- fleece collar
  local col = c:ellipse(32, 13, 13, 4.2):cut(c:ellipse(32, 11, 7, 2.2))
  C.sep(c, col, bodyAll, R.cacao[1])
  local ci = C.lit(c, col, R.alpaca, { R = 2 })
  C.retone(c, col, ci, R.alpaca, function(x, y) if X.hash(x, y, 4) < .25 then return -1 end end)
  c:fillMask(c:ellipse(32, 11, 7, 2.2):cut(col), R.cacao[1])
  -- glints on puffs
  for _, p in ipairs(puffs) do c:put(23, p.y0 + 2, R.cacao[6]) c:put(24, p.y0 + 2, R.cacao[6]) end
  c:put(20, 16, R.alpaca[5])
  -- quirk: kapok floss escaping a seam on the right, one wisp drifting off
  local fl = c:ellipse(42, 37, 2.6, 2):add(c:ellipse(44, 35, 1.8, 1.6))
  C.lit(c, fl, R.alpaca, { R = 1, bias = 2 })
  c:put(42, 36, C.cream) c:put(44, 34, C.cream)
  local wisp = c:ellipse(49, 6, 1.6, 1.2)
  C.lit(c, wisp, R.alpaca, { R = 1, bias = 2 })
  c:put(48, 5, C.cream)
  C.save(c, "coat-5-kapok-puffer")
end
