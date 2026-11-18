-- WCA footwear concepts (5). Run: AppRun -b --script-param png=<dir>/ --script footwear.lua [--script-param only=<name>]
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local ink, cream = C.ink, C.cream

-- 1. Palm-Sole Sandals: plaited palm soles, red tooled toe strap, quirk: brass bell
local function sandals(c)
  local function sandal(dx, dy, b)
    local S = {}
    local top = c:poly{ {7+dx,36+dy}, {11+dx,31+dy}, {20+dx,31+dy}, {30+dx,32+dy}, {40+dx,32+dy}, {45+dx,35+dy}, {43+dx,39+dy}, {31+dx,41+dy}, {18+dx,42+dy}, {9+dx,41+dy} }
    local side = HP.mask()
    for s = 1, 4 do side:add(top:shift(0, s)) end
    side:cut(top)
    local toe = { {12+dx,37+dy}, {10+dx,27+dy}, {21+dx,24+dy}, {23+dx,36+dy} }
    local heel = { {35+dx,35+dy}, {34+dx,26+dy}, {42+dx,26+dy}, {42+dx,35+dy} }
    local ank = { {21+dx,27+dy}, {25+dx,25+dy}, {30+dx,25+dy}, {35+dx,27+dy} }
    S.all = top:copy():add(side)
    S.paint = function()
      -- sole side: plait edge
      local si = C.lay(c, side, R.raffia, { R = 1, bias = (b or 0) - 1 })
      C.paintIf(c, side, R.raffia[2 + (b or 0) + 1], function(x, y) return (x + y) % 3 == 0 end)
      C.underline(c, side, R.raffia[1])
      -- top: plaited herringbone
      local ti = C.lay(c, top, R.raffia, { R = 3, bias = b })
      C.retone(c, top, ti, R.raffia, function(x, y, i)
        local u = (x - dx) % 6
        if u == 0 then return -1 end
        if ((y - dy) % 2 == 0) == (u < 3) and u ~= 0 then return 0 end
        if u == 3 then return -1 end
      end)
      C.topline(c, top, R.raffia[6 + math.min(0, (b or 0))])
      -- footbed wear (darker heel and ball)
      local wear = c:ellipse(18+dx, 37+dy, 4, 2):add(c:ellipse(36+dx, 36+dy, 3, 2)):clip(top)
      C.paintIf(c, wear, R.raffia[3 + (b or 0)], function(x, y) return true end)
      -- straps
      local mt = C.tube(c, toe, 1.6, R.redleather, { bias = b })
      local mh = C.tube(c, heel, 1.2, R.redleather, { bias = (b or 0) - 1 })
      local ma = C.tube(c, ank, 0.9, R.redleather, { bias = b })
      -- tooled dots along the toe strap
      for _, p in ipairs({ {11+dx,31+dy}, {14+dx,26+dy}, {19+dx,26+dy}, {22+dx,31+dy} }) do c:put(p[1], p[2], R.redleather[2]) end
      return mt
    end
    return S
  end
  local back = sandal(13, -10, -1)
  local front = sandal(0, 0, nil)
  back.paint()
  C.sep(c, front.all, back.all, ink)
  front.paint()
  -- quirk: brass bell hanging off the front toe strap
  c:put(16, 26, R.strap[2]) c:put(16, 27, R.strap[2])
  local bell = c:poly{ {14,31}, {15,28}, {17,28}, {18,31}, {19,32}, {13,32} }
  C.lay(c, bell, R.brass, { R = 1 })
  c:put(15, 29, R.brass[6]) c:put(16, 33, R.brass[2])
  C.hline(c, 13, 19, 32, R.brass[3])
end

-- 2. Mudwader Wraps: indigo leg wraps, criss-cross cord, low leather shoe. quirk: weed sprout
local function wraps(c)
  local function leg(dx, dy, b)
    local L = {}
    local shaft = c:poly{ {13+dx,10+dy}, {28+dx,10+dy}, {29+dx,42+dy}, {12+dx,42+dy} }
    local shoe = c:poly{ {11+dx,39+dy}, {29+dx,39+dy}, {36+dx,42+dy}, {41+dx,46+dy}, {40+dx,50+dy}, {11+dx,50+dy} }
    local sole = c:rrect(10+dx, 50+dy, 41+dx, 52+dy, 1)
    local cuff = c:rrect(11+dx, 6+dy, 30+dx, 12+dy, 2)
    L.all = shaft:copy():add(shoe):add(sole):add(cuff)
    L.paint = function()
      local bb = b or 0
      C.lay(c, shoe, R.strap, { R = 4, bias = bb })
      C.lay(c, sole, R.sole, { R = 1, bias = bb })
      for x = 12+dx, 40+dx, 3 do c:put(x, 52+dy, R.sole[1]) end
      C.hline(c, 12+dx, 39+dx, 50+dy, R.sole[5])
      -- shoe seam + toe cap
      for x = 30+dx, 39+dx do if shoe:has(x, 45+dy) then c:put(x, 45+dy, R.strap[2]) end end
      local si = C.vcyl(c, shaft, R.indigo, 12+dx, 29+dx, { bias = C.bias(shaft, bb) })
      -- overlapping diagonal wrap strips
      C.retone(c, shaft, si, R.indigo, function(x, y, i)
        if (y - dy) % 8 == 0 then return -1 end
      end)
      C.hline(c, 12+dx, 29+dx, 42+dy, R.indigo[1])
      -- criss-cross cord
      local zz = c:line({ {13+dx,15+dy}, {28+dx,28+dy}, {13+dx,41+dy} }, 1)
      local zz2 = c:line({ {28+dx,15+dy}, {13+dx,28+dy}, {28+dx,41+dy} }, 1)
      local cord = zz:add(zz2):clip(shaft)
      cord:shift(0, 1):cut(cord):clip(shaft):each(function(x, y) c:put(x, y, R.indigo[1]) end)
      cord:each(function(x, y) c:put(x, y, R.cotton[(x < 21+dx) and 6 + bb or 4 + bb]) end)
      -- rolled cotton cuff
      C.lay(c, cuff, R.cotton, { R = 2, bias = bb })
      C.hline(c, 12+dx, 29+dx, 9+dy, R.cotton[2 + bb])
      C.hline(c, 12+dx, 28+dx, 13+dy, R.indigo[1])
    end
    return L
  end
  local back = leg(12, -5, -1)
  local front = leg(0, 0, nil)
  back.paint()
  C.sep(c, front.all, back.all, ink)
  front.paint()
  -- highlight streak
  C.vline(c, 14, 15, 38, R.indigo[5])
  -- quirk: a weed sprout pushing out of the front binding
  local st = c:line({ {27,30}, {30,27}, {31,23} }, 1)
  st:each(function(x, y) c:put(x, y, R.forest[4]) end)
  local l1 = c:poly{ {31,23}, {35,19}, {38,20}, {35,24} }
  local l2 = c:poly{ {30,27}, {26,23}, {24,24}, {27,28} }
  C.lay(c, l1, R.plantain, { R = 1 }) C.lay(c, l2, R.plantain, { R = 1, bias = -1 })
  c:put(35, 20, R.plantain[6]) c:put(33, 22, R.plantain[2])
end

-- 3. Rainroot Clogs: carved mahogany on two raised blocks, woven instep band. quirk: tree frog
local function clogs(c)
  local function clog(dx, dy, b)
    local L = {}
    local body = c:poly{ {9+dx,30+dy}, {10+dx,24+dy}, {14+dx,23+dy}, {27+dx,25+dy}, {36+dx,27+dy}, {43+dx,30+dy}, {46+dx,34+dy}, {45+dx,39+dy}, {40+dx,41+dy}, {9+dx,41+dy} }
    local slab = c:rect(9+dx, 42+dy, 43+dx, 44+dy)
    local peg1 = c:poly{ {11+dx,45+dy}, {20+dx,45+dy}, {19+dx,51+dy}, {12+dx,51+dy} }
    local peg2 = c:poly{ {31+dx,45+dy}, {40+dx,45+dy}, {39+dx,51+dy}, {32+dx,51+dy} }
    L.all = body:copy():add(peg1):add(peg2):add(slab)
    L.paint = function()
      local bb = b or 0
      local grain = function(x, y, i) if (y * 3 + x // 6) % 8 == 0 and X.hash(x, y, 3) < .5 then return -1 end end
      C.lay(c, peg1, R.mahogany, { R = 2, bias = bb - 1 })
      C.lay(c, peg2, R.mahogany, { R = 2, bias = bb - 1 })
      C.topline(c, peg1, R.mahogany[1]) C.topline(c, peg2, R.mahogany[1])
      C.vline(c, 12+dx, 46+dy, 50+dy, R.mahogany[4 + bb]) C.vline(c, 32+dx, 46+dy, 50+dy, R.mahogany[4 + bb])
      C.lay(c, slab, R.kente, { R = 1, bias = bb - 1 })
      C.hline(c, 9+dx, 43+dx, 42+dy, R.kente[5 + bb]) C.hline(c, 10+dx, 43+dx, 44+dy, R.kente[1])
      local bi = C.lay(c, body, R.mahogany, { R = 5, bias = bb, cuts = { .2, .38, .54, .7, .86 } })
      C.retone(c, body, bi, R.mahogany, grain)
      -- deep foot opening at the heel end, lit lip
      local hole = c:poly{ {11+dx,25+dy}, {15+dx,23+dy}, {25+dx,25+dy}, {22+dx,28+dy}, {13+dx,28+dy} }
      c:fillMask(hole, R.mahogany[1])
      C.hline(c, 13+dx, 21+dx, 28+dy, R.mahogany[5 + bb])
      c:put(12+dx, 27+dy, R.mahogany[5 + bb])
      -- sole edge + carved groove
      C.hline(c, 10+dx, 40+dx, 40+dy, R.mahogany[2])
      for x = 11+dx, 43+dx do if body:has(x, 37+dy) and x % 2 == 0 then c:put(x, 37+dy, R.mahogany[2]) end end
      -- woven instep band: gold / green / rust stripes
      local band = c:poly{ {24+dx,24+dy}, {30+dx,25+dy}, {34+dx,39+dy}, {27+dx,39+dy} }:clip(body)
      local cols = { R.kente, R.forest, R.kente, R.palm }
      band:each(function(x, y)
        local r = cols[((y - dy) // 3) % 4 + 1]
        local t = 5 + bb - ((x - dx) > 29 + (y - dy - 25) * 0.3 and 2 or 0)
        c:put(x, y, r[math.max(1, t)])
      end)
      band:each(function(x, y) if not band:has(x + 1, y) or not band:has(x - 1, y) then c:put(x, y, R.mahogany[1]) end end)
    end
    return L
  end
  local back = clog(11, -11, -1)
  local front = clog(0, 0, nil)
  back.paint()
  C.sep(c, front.all, back.all, ink)
  front.paint()
  c:put(11, 31, R.mahogany[6]) c:put(11, 32, R.mahogany[6])
  -- quirk: tree frog on the toe
  local fr = c:ellipse(41, 29, 4.2, 2.6):add(c:ellipse(38, 26, 2, 2))
  C.sep(c, fr, c:rect(0,0,63,63), ink)
  C.lay(c, fr, R.plantain, { R = 2, bias = 1 })
  c:put(38, 25, ink) c:put(38, 26, ink) c:put(37, 24, R.plantain[6]) c:put(37, 25, cream)
  C.put(c, { {44,31}, {45,31}, {36,31}, {35,31} }, R.plantain[2])
  c:put(41, 27, R.plantain[6]) c:put(42, 27, R.plantain[6]) c:put(40, 30, R.palm[4]) c:put(41, 30, R.palm[4])
end

-- 4. Ochre Trail Boots: single ankle boot, turned-down red cuff with stitching. quirk: tassel
local function boots(c)
  local shaft = c:poly{ {17,14}, {35,14}, {36,36}, {16,38} }
  local foot = c:rrect(16, 31, 40, 48, 4):add(c:ellipse(43, 43, 8, 5))
    :add(c:poly{ {30,30}, {38,34}, {46,38}, {34,42} })
  local body = shaft:copy():add(foot)
  local sole = c:rrect(15, 48, 52, 51, 1)
  local cuff = c:poly{ {14,9}, {38,9}, {39,19}, {36,22}, {33,19}, {30,22}, {27,19}, {24,22}, {21,19}, {18,22}, {15,19}, {13,20} }
  local idx = C.vcyl(c, shaft, R.ochre, 16, 36, { cuts = { .2, .36, .52, .7, .9 } })
  C.lay(c, foot:copy():cut(shaft), R.ochre, { R = 6, hs = 0.6, cuts = { .2, .36, .52, .7, .9 } })
  -- vamp seam and tooled dashes
  local seam = c:line({ {28,33}, {31,37}, {35,40}, {41,40}, {47,41} }, 1):clip(body)
  seam:each(function(x, y) c:put(x, y, R.ochre[2]) end)
  local n = 0
  c:line({ {27,36}, {30,40}, {34,43}, {41,44} }, 1):clip(body):each(function(x, y) n = n + 1 if (x + y) % 3 ~= 0 then c:put(x, y, R.ochre[5]) end end)
  -- heel counter
  local hc = c:poly{ {16,38}, {24,40}, {24,48}, {16,48} }:clip(body)
  C.lay(c, hc, R.ochre, { R = 2, bias = -1 })
  C.lay(c, sole, R.sole, { R = 1 })
  C.hline(c, 16, 51, 48, R.sole[5])
  for x = 17, 50, 3 do c:put(x, 51, R.sole[1]) end
  C.hline(c, 17, 35, 23, R.ochre[1])
  -- cuff
  C.lay(c, cuff, R.redleather, { R = 2, cuts = { .2, .38, .54, .7, .88 } })
  C.hline(c, 15, 37, 10, R.redleather[6])
  for x = 15, 37 do if x % 3 ~= 0 then c:put(x, 13, R.cotton[x < 26 and 5 or 4]) end end
  for x = 15, 37 do c:put(x, 16, R.redleather[2]) end
  -- streak
  C.vline(c, 19, 25, 36, R.ochre[6]) C.vline(c, 20, 27, 32, R.ochre[5])
  c:put(19, 26, cream)
  c:put(42, 39, R.ochre[6]) c:put(43, 39, R.ochre[6])
  -- quirk: red tassel on a thong at the side
  c:line({ {35,17}, {39,21}, {41,25} }, 1):each(function(x, y) c:put(x, y, R.redleather[2]) end)
  local knot = c:ellipse(41, 26, 1.4, 1.4)
  C.lay(c, knot, R.kente, { R = 1 })
  local tas = c:poly{ {39,27}, {43,27}, {45,35}, {38,35} }
  C.lay(c, tas, R.redleather, { R = 1, bias = 1 })
  for x = 39, 44 do if x % 2 == 0 then C.vline(c, x, 30, 35, R.redleather[2]) end end
  c:put(39, 28, R.redleather[6])
end

-- 5. Plantain Slippers: round bundles of plantain leaf, vine tie, fanned leaf ends. quirk: tendril
local function slippers(c)
  local function sl(cx, cy, b)
    local S = {}
    local bun = C.oval(cx, cy, 13, 8.5, -0.06)
    local fan = c:poly{ {cx-7,cy-6}, {cx-11,cy-14}, {cx-6,cy-11}, {cx-2,cy-19}, {cx+1,cy-12}, {cx+6,cy-17}, {cx+6,cy-6} }
    local sole = c:ellipse(cx + 1, cy + 8, 13, 2)
    S.all = bun:copy():add(fan):add(sole)
    S.paint = function()
      local bb = b or 0
      C.lay(c, sole, R.raffia, { R = 1, bias = bb - 1 })
      C.retone(c, fan, C.lay(c, fan, R.plantain, { R = 2, bias = bb }), R.plantain,
        function(x, y) if (x - cx) % 5 == 0 then return -2 end end)
      local _, bi = C.ovalLit(c, cx, cy, 13, 8.5, -0.06, R.plantain, { bias = bb })
      -- wrapped leaf bands: diagonal edges + midribs
      C.retone(c, bun, bi, R.plantain, function(x, y, i)
        local u = (x - cx + (y - cy) * 2) % 9
        if u == 0 then return -2 elseif u == 1 then return 1 elseif u == 5 and i > 2 then return 1 end
      end)
      -- vine tie around the neck
      local tie = c:rrect(cx - 8, cy - 7, cx + 7, cy - 5, 1)
      C.lay(c, tie, R.forest, { R = 1, bias = bb })
      for x = cx - 7, cx + 6, 3 do c:put(x, cy - 6, R.forest[6 + math.min(0, bb)]) end
    end
    return S
  end
  local back = sl(42, 30, -1)
  local front = sl(25, 40, nil)
  back.paint()
  C.sep(c, front.all, back.all, ink)
  front.paint()
  c:put(18, 35, R.plantain[6]) c:put(19, 35, cream)
  -- quirk: curly vine tendril from the tie
  C.put(c, { {33,34}, {35,33}, {36,31}, {35,29}, {33,29}, {33,31}, {34,32} }, R.forest[5])
  c:put(32, 34, R.forest[4])
end

C.run{
  { "footwear-1-palm-sole-sandals", sandals },
  { "footwear-2-mudwader-wraps", wraps },
  { "footwear-3-rainroot-clogs", clogs },
  { "footwear-4-ochre-trail-boots", boots },
  { "footwear-5-plantain-slippers", slippers },
}
