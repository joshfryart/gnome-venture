-- footwear.lua: SEA "Monsoon Tangle" footwear concepts 1..5 (see concepts.md).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local floor, sin, cos, rad, max, min = math.floor, math.sin, math.cos, math.rad, math.max, math.min

------------------------------------------------------------------ 1 paddy stilt-clogs
do
  local c = C.canvas("footwear-1-paddy-stilt-clogs")
  local function clog(dx, dy, bias)
    local o = {}
    o.body = c:poly{ {6+dx,28+dy}, {10+dx,29+dy}, {12+dx,31+dy}, {25+dx,31+dy}, {29+dx,27+dy}, {35+dx,24+dy}, {42+dx,24+dy}, {47+dx,27+dy}, {49+dx,32+dy}, {48+dx,37+dy}, {7+dx,38+dy} }
    o.hole = c:rect(11+dx, 31+dy, 25+dx, 32+dy):add(c:rect(24+dx, 30+dy, 26+dx, 31+dy)):clip(o.body)
    o.band = c:poly{ {27+dx,27+dy}, {33+dx,24+dy}, {37+dx,38+dy}, {30+dx,38+dy} }:clip(o.body)
    o.b1 = c:poly{ {10+dx,38+dy}, {20+dx,38+dy}, {19+dx,47+dy}, {11+dx,47+dy} }
    o.b2 = c:poly{ {32+dx,38+dy}, {42+dx,38+dy}, {41+dx,47+dy}, {33+dx,47+dy} }
    o.all = o.body:copy():add(o.b1):add(o.b2)
    o.paint = function()
      local b = bias or 0
      for _, blk in ipairs({ o.b1, o.b2 }) do
        local x0 = blk:bbox()
        C.lit(c, blk, R.wood, b - 1, { R = 2 })
        C.bottomEdge(c, blk, R.wood[1])
        C.vline(c, x0 + 1, 39+dy, 45+dy, R.wood[4 + b])
        c:put(x0 + 4, 42+dy, R.wood[2]) c:put(x0 + 4, 43+dy, R.wood[2])
      end
      C.hline(c, 10+dx, 20+dx, 38+dy, R.wood[1]) C.hline(c, 32+dx, 42+dx, 38+dy, R.wood[1])
      local bi = C.lit(c, o.body, R.wood, b, { R = 4, cuts = { .2, .36, .52, .7, .88 } })
      -- grain lines following the sole
      for x = 9+dx, 44+dx do if (x - dx) % 9 < 5 and o.body:has(x, 33+dy) then c:put(x, 33+dy, R.wood[3 + b]) end end
      for x = 12+dx, 40+dx do if (x - dx) % 11 < 4 and o.body:has(x, 30+dy) then c:put(x, 30+dy, R.wood[3 + b]) end end
      C.hline(c, 8+dx, 47+dx, 37+dy, R.wood[2])
      -- foot opening
      c:fillMask(o.hole, R.wood[1])
      C.hline(c, 11+dx, 24+dx, 33+dy, R.wood[5 + b])
      -- red cloth band over the vamp, cream ikat dashes
      C.sep(c, o.band, o.body, R.wood[1])
      local si = C.lit(c, o.band, R.blanket, b, { R = 2 })
      o.band:each(function(x, y) if (y - dy) % 4 == 0 and ((x - dx) + (y - dy)) % 2 == 0 then c:put(x, y, b < 0 and R.lining[4] or C.R.cream) end end)
    end
    return o
  end
  local back = clog(11, -8, -1)
  local front = clog(0, 0, 0)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  c:put(8, 30, C.cream) c:put(9, 31, R.wood[6]) c:put(37, 26, R.wood[6]) c:put(38, 26, R.wood[6])
  -- quirk: tree frog on the front toe
  local fb = c:ellipse(43, 23, 4.5, 3)
  C.sep(c, fb, back.all, C.ink)
  C.lit(c, fb, R.leaf, 0, { R = 2 })
  local eye = c:ellipse(46, 20, 1.6, 1.6)
  C.sep(c, eye, back.all, C.ink)
  c:fillMask(eye, R.leaf[5])
  c:put(47, 20, C.ink) c:put(46, 19, R.leaf[6]) c:put(45, 20, R.leaf[6])
  C.put(c, { {39,26}, {40,26}, {47,26}, {48,26}, {38,25} }, R.leaf[3])
  c:put(41, 21, R.leaf[6]) c:put(42, 21, R.leaf[6])
  C.hline(c, 42, 46, 25, R.gecko[5])
  c:put(48, 23, R.blanket[3])
  C.save(c, "footwear-1-paddy-stilt-clogs")
end

---------------------------------------------------------------- 2 pandan sandals (seen from above)
do
  local c = C.canvas("footwear-2-pandan-sandals")
  local function sandal(cx, cy, ang, bias)
    local ca, sa = cos(rad(ang)), sin(rad(ang))
    local function T(x, y) return cx + x * ca - y * sa, cy + x * sa + y * ca end
    local function tp(list) local q = {} for i, p in ipairs(list) do local x, y = T(p[1], p[2]) q[i] = { x, y } end return q end
    local o = {}
    o.sole = c:poly(tp{ {0,-19}, {4,-18}, {7,-13}, {7,-4}, {5,4}, {5,11}, {3,16}, {-3,16}, {-5,11}, {-5,3}, {-7,-5}, {-6,-14}, {-3,-18} })
    o.s1 = c:line(tp{ {-6,-10}, {5,0} }, 4)
    o.s2 = c:line(tp{ {6,-10}, {-5,0} }, 4)
    o.heel = c:line(tp{ {-5,9}, {-3,12}, {0,13}, {3,12}, {5,9} }, 3)
    o.toe = c:line(tp{ {-2,-14}, {2,-14} }, 2)
    o.straps = o.s1:copy():add(o.s2):add(o.heel):add(o.toe)
    o.all = o.sole:copy():add(o.straps)
    o.T = T
    o.paint = function()
      local b = bias or 0
      local si = C.lit(c, o.sole, R.pandan, b, { R = 3, cuts = { .2, .38, .56, .72, .88 } })
      C.retone(c, o.sole, si, R.pandan, function(x, y)
        if y % 3 == 2 then return -1 end
        if (x + ((y // 3) % 2) * 3) % 6 == 0 then return -2 end
        if (x + ((y // 3) % 2) * 3) % 6 == 1 then return 1 end
      end)
      -- woven border band
      o.sole:edge():each(function(x, y) c:put(x, y, ((x + y) % 2 == 0) and R.straw[3 + b] or R.straw[2 + b]) end)
      -- strap shadows on the sole
      o.straps:shift(1, 1):each(function(x, y) if o.sole:has(x, y) and not o.straps:has(x, y) then c:put(x, y, R.pandan[1]) end end)
      local sb = {}
      C.lit(c, o.straps, R.leather, b, { R = 1 })
      o.straps:each(function(x, y) if not o.straps:has(x - 1, y) or not o.straps:has(x, y - 1) then c:put(x, y, R.leather[5 + b]) end end)
      o.straps:each(function(x, y) if not o.straps:has(x + 1, y + 1) then c:put(x, y, R.leather[2 + b]) end end)
    end
    return o
  end
  local back = sandal(40, 29, 16, -1)
  local front = sandal(24, 34, 6, 0)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  -- quirk: frangipani on the front strap cross
  local fx, fy = front.T(0, -5)
  fx, fy = floor(fx + .5), floor(fy + .5)
  local fl = c:ellipse(fx, fy, 3, 3)
  C.sep(c, fl, front.all, R.leather[1])
  C.flower(c, fx, fy, R.petal, R.brass[4])
  c:put(fx - 1, fy - 1, R.brass[5]) c:put(fx, fy - 1, R.brass[4])
  C.save(c, "footwear-2-pandan-sandals")
end

---------------------------------------------------------------- 3 ikat leech-wraps
do
  local c = C.canvas("footwear-3-ikat-leech-wraps")
  local function leg(dx, dy, bias)
    local o = {}
    o.shaft = c:poly{ {14+dx,12+dy}, {26+dx,12+dy}, {27+dx,41+dy}, {13+dx,42+dy} }
    o.foot = c:rrect(12+dx, 38+dy, 30+dx, 48+dy, 3):add(c:ellipse(32+dx, 45+dy, 5, 3.5)):cut(o.shaft)
    o.sole = c:rrect(11+dx, 48+dy, 38+dx, 50+dy, 1)
    o.top = c:rrect(12+dx, 8+dy, 28+dx, 14+dy, 2)
    o.all = o.shaft:copy():add(o.foot):add(o.sole):add(o.top)
    o.paint = function()
      local b = bias or 0
      local bm = C.bmap(o.foot, b)
      local fi = C.lit(c, o.foot, R.soga, b, { R = 3 })
      C.hline(c, 26+dx, 36+dx, 47+dy, R.soga[2])
      C.lit(c, o.sole, R.sole, b, { R = 1 })
      C.hline(c, 12+dx, 37+dx, 48+dy, R.sole[5])
      local idx = C.vcyl(c, o.shaft, R.indigo, 13+dx, 27+dx, { bias = C.bmap(o.shaft, b + 1) })
      -- spiral wound bands: indigo / rust / indigo / cream, shadow under each turn, ikat blur
      o.shaft:each(function(x, y)
        local k = K(x, y)
        local u = (y - dy) + (x - dx - 13) * 0.45
        local jit = (X.hash(x, y, 7) < 0.22) and 1 or 0
        local band = floor((u + jit) / 5) % 4
        local i = idx[k]
        local col
        if band == 1 then col = R.yarnA[i] elseif band == 3 then col = R.indigo[min(6, i + 1)] else col = R.indigo[i] end
        if band == 1 and floor(u) % 5 == 2 and x % 3 == 0 then col = R.lining[min(6, i + 1)] end
        if band == 3 and floor(u) % 5 == 2 and x % 4 == 1 then col = R.wax[max(1, i - 1)] end
        if floor(u) % 5 == 4 then col = (band == 1) and R.yarnA[max(1, i - 2)] or R.indigo[max(1, i - 2)] end
        c:put(x, y, col)
      end)
      -- cream folded cuff
      C.sep(c, o.top, o.shaft, R.indigo[1])
      C.lit(c, o.top, R.yarnA, b, { R = 2 })
      C.hline(c, 13+dx, 27+dx, 11+dy, R.yarnA[2 + b])
      for x = 14+dx, 26+dx do if (x - dx) % 4 == 0 then c:put(x, 12+dy, R.lining[5 + b]) c:put(x+1, 13+dy, R.lining[4 + b]) c:put(x-1, 13+dy, R.lining[4 + b]) end end
      C.hline(c, 13+dx, 27+dx, 15+dy, R.indigo[1])
    end
    return o
  end
  local back = leg(12, -4, -1)
  local front = leg(0, 0, 0)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  -- ties with wooden beads hanging from the front cuff
  local cord = c:line({ {13,13}, {10,17}, {9,23} }, 1):add(c:line({ {14,14}, {13,19}, {13,25} }, 1))
  cord:each(function(x, y) if not front.shaft:has(x, y) or x < 14 then c:put(x, y, R.strap[3]) end end)
  for _, p in ipairs({ { 9, 25 }, { 13, 27 } }) do
    local bd = c:ellipse(p[1], p[2], 1.6, 1.6)
    C.lit(c, bd, R.wood, 0, { R = 1 }) c:put(p[1] - 1, p[2] - 1, R.wood[6])
  end
  -- quirk: dragonfly resting on the back cuff
  local oy = 4
  C.hline(c, 31, 42, oy, R.yarnB[4]) C.hline(c, 31, 35, oy, R.yarnB[5]) C.hline(c, 36, 42, oy + 1, R.yarnB[2])
  c:put(43, oy, R.yarnB[3])
  c:fillMask(c:rect(28, oy - 1, 30, oy + 1), R.yarnB[3]) c:put(28, oy - 1, R.yarnB[6]) c:put(29, oy, C.ink)
  for _, w in ipairs({ { 31, 5 }, { 36, 5 } }) do
    for i = 0, w[2] - 1 do
      c:put(w[1] + i, oy - 2, R.mint[6]) c:put(w[1] + i, oy - 1, R.mint[5])
    end
  end
  C.put(c, { {33,oy-3}, {34,oy-3}, {35,oy-3}, {38,oy-3}, {39,oy-3}, {40,oy-3} }, R.mint[4])
  C.save(c, "footwear-3-ikat-leech-wraps")
end

---------------------------------------------------------------- 4 rattan trail boot
do
  local c = C.canvas("footwear-4-rattan-trail-boot")
  local shaft = c:poly{ {15,13}, {34,13}, {35,34}, {15,36} }
  local foot = c:rrect(14, 30, 44, 47, 6):add(c:ellipse(44, 41, 8, 6)):cut(shaft)
  local upper = shaft:copy():add(foot)
  local sole = c:rrect(12, 47, 53, 51, 1):cut(c:rect(22, 51, 31, 51))
  local collar = c:rrect(13, 9, 36, 15, 2)
  local cap = upper:copy():clip(c:ellipse(46, 41, 9, 7.5)):cut(c:rect(0, 0, 37, 63))
  local heel = upper:copy():clip(c:rect(0, 34, 21, 47))
  local ui = C.lit(c, upper, R.rattan, 0, { R = 5, cuts = { .2, .36, .52, .7, .88 } })
  C.retone(c, upper, ui, R.rattan, function(x, y)
    local a, bb = (x + y) // 3, (x - y + 60) // 3
    if (a + bb) % 2 == 0 then
      if (x + y) % 3 == 0 then return -2 end
      if (x - y) % 3 == 1 then return 1 end
    else
      if (x - y) % 3 == 0 then return -2 end
    end
  end)
  -- leather toe cap and heel counter
  C.sep(c, cap, upper, R.rattan[1]) C.sep(c, heel, upper, R.rattan[1])
  C.lit(c, cap, R.leather, 0, { R = 3 })
  C.lit(c, heel, R.leather, -1, { R = 2 })
  cap:shrink(1):edge():each(function(x, y) if (x + y) % 3 == 0 and x < 48 and y < 45 then c:put(x, y, "#f2e2b8") end end)
  c:put(45, 37, R.leather[6]) c:put(46, 37, C.cream)
  -- sole
  C.lit(c, sole, R.sole, 0, { R = 1 })
  C.hline(c, 13, 52, 47, R.sole[5])
  for x = 13, 52, 3 do c:put(x, 51, R.sole[1]) end
  C.hline(c, 16, 43, 46, R.rattan[1])
  -- leather collar
  C.sep(c, collar, upper, R.rattan[1])
  C.lit(c, collar, R.leather, 0, { R = 2 })
  C.hline(c, 14, 35, 12, R.leather[3])
  for x = 15, 34 do if x % 3 < 2 then c:put(x, 10, "#f2e2b8") end end
  -- laces down the front edge
  for i, y in ipairs({ 18, 23, 28 }) do
    C.put(c, { {29,y}, {30,y+1}, {31,y+2}, {32,y+3}, {33,y+4} }, R.strap[2])
    C.put(c, { {33,y}, {32,y+1}, {31,y+2}, {30,y+3}, {29,y+4} }, "#f2e2b8")
    c:put(29, y, R.brass[4]) c:put(33, y, R.brass[3])
  end
  -- quirk: gecko climbing the side
  local gb = c:ellipse(22, 25, 2, 4.5):add(c:ellipse(22, 18.5, 1.8, 2.4))
  local tail = c:line({ {22,30}, {21,33}, {19,35}, {17,35}, {16,33} }, 1)
  local legs = c:line({ {20,21}, {18,20} }, 1):add(c:line({ {24,21}, {26,20} }, 1))
    :add(c:line({ {20,28}, {18,30} }, 1)):add(c:line({ {24,28}, {26,30} }, 1))
  local all = gb:copy():add(tail):add(legs)
  C.sep(c, all, upper, R.rattan[1])
  tail:add(legs):each(function(x, y) c:put(x, y, R.gecko[3]) end)
  C.put(c, { {17,19}, {17,20}, {27,19}, {27,20}, {17,30}, {17,31}, {27,30}, {27,31} }, R.gecko[4])
  C.lit(c, gb, R.gecko, 1, { R = 2 })
  c:put(21, 17, C.ink) c:put(23, 17, C.ink)
  C.put(c, { {22,24}, {21,27}, {23,26} }, R.gecko[2])
  c:put(21, 22, R.gecko[6])
  C.save(c, "footwear-4-rattan-trail-boot")
end

---------------------------------------------------------------- 5 mudflat paddles
do
  local c = C.canvas("footwear-5-mudflat-paddles")
  local function pad(dy) return c:poly{ {4,40+dy}, {10,35+dy}, {30,33+dy}, {50,34+dy}, {58,37+dy}, {60,41+dy}, {56,45+dy}, {36,47+dy}, {12,46+dy}, {5,44+dy} } end
  local top = pad(0)
  local side = pad(3):cut(top)
  local slipper = c:poly{ {13,30}, {17,29}, {19,32}, {30,32}, {35,26}, {42,23}, {48,24}, {52,28}, {53,34}, {51,38}, {14,38} }
  local opening = c:rect(20, 31, 30, 32):add(c:rect(30, 30, 31, 31))
  local strap = c:poly{ {33,27}, {38,24}, {41,38}, {36,38} }:clip(slipper)
  C.lit(c, side, R.mudrub, -2, { R = 1 })
  C.bottomEdge(c, side, R.mudrub[1])
  local ti = C.lit(c, top, R.mudrub, 0, { R = 3, cuts = { .22, .4, .56, .72, .88 } })
  -- cross ribs
  for x = 9, 57, 5 do for y = 30, 50 do if top:has(x, y) then c:put(x, y, R.mudrub[2]) if top:has(x - 1, y) then c:put(x - 1, y, R.mudrub[5]) end end end end
  top:edge():each(function(x, y) if not top:has(x, y - 1) then c:put(x, y, R.mudrub[6]) end end)
  -- mud splats
  C.put(c, { {7,42}, {8,42}, {8,43}, {55,43}, {56,43}, {48,46}, {20,46}, {21,46} }, R.felt[3])
  -- slipper
  C.sep(c, slipper, top, R.mudrub[1])
  slipper:shift(1, 1):cut(slipper):clip(top):each(function(x, y) c:put(x, y, R.mudrub[1]) end)
  C.lit(c, slipper, R.felt, 1, { R = 4, cuts = { .2, .36, .52, .7, .86 } })
  c:fillMask(opening, R.felt[1])
  C.hline(c, 20, 29, 33, R.felt[5])
  C.hline(c, 15, 51, 38, R.felt[1])
  for x = 15, 50 do if x % 3 == 0 then c:put(x, 36, R.felt[5]) end end
  -- strap + brass buckle
  C.sep(c, strap, slipper, R.felt[1])
  C.lit(c, strap, R.strap, 0, { R = 1 })
  local bk = c:rect(35, 30, 40, 34)
  C.lit(c, bk, R.brass, 0, { R = 1 })
  c:fillMask(c:rect(37, 32, 38, 32), R.strap[2])
  c:put(35, 30, C.cream)
  -- slipper sheen
  c:put(43, 25, R.felt[6]) c:put(44, 25, R.felt[6]) c:put(15, 31, R.felt[6])
  -- quirk: mudskipper peeking over the front tip
  local fish = c:ellipse(56, 34, 4, 2.2)
  local fin = c:poly{ {52,32}, {55,29}, {57,32} }
  local fm = fish:copy():add(fin)
  C.sep(c, fm, top:copy():add(slipper), C.ink)
  C.lit(c, fin, R.mudrub, 0, { R = 1 })
  C.lit(c, fish, R.mudrub, 1, { R = 2 })
  C.put(c, { {54,35}, {56,36} }, R.king[5])
  c:fillMask(c:ellipse(58, 31, 1.3, 1.3), R.petal[5])
  c:put(59, 31, C.ink) c:put(57, 30, R.petal[6])
  C.save(c, "footwear-5-mudflat-paddles")
end
