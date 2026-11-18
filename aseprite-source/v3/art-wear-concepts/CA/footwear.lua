-- footwear.lua: Maizehollow (CA) footwear concepts 1..5
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R = C.HP, C.X, C.K, C.R
local hash = X.hash

---------------------------------------------------------------- 1 lattice huaraches (top view pair)
do
  local c = C.new("footwear-1-lattice-huaraches")
  local function sandal(x0, y0, b, bead)
    local cx = x0 + 9
    local bed = c:ellipse(cx, y0 + 12, 8.5, 12):add(c:ellipse(cx - 1, y0 + 37, 7, 9.5))
      :add(c:poly{ {x0 + 1, y0 + 12}, {x0 + 18, y0 + 12}, {x0 + 16, y0 + 38}, {x0 + 2, y0 + 38} })
    local edge = bed:shift(1, 3):add(bed:shift(0, 2)):cut(bed)
    C.part(c, edge, R.sole, { R = 1, b = b - 1 })
    C.part(c, bed, R.leather, { R = 4, b = b, tex = function(x, y) if hash(x, y, 3) < .03 then return -1 end end })
    -- worn heel + toe pads
    for _, p in ipairs({ {cx - 2, y0 + 38}, {cx - 1, y0 + 39}, {cx, y0 + 38}, {cx - 2, y0 + 5}, {cx + 1, y0 + 4} }) do c:put(p[1], p[2], R.leather[3]) end
    -- woven lattice over the forefoot
    local band = bed:copy():clip(c:rect(x0 - 2, y0 + 8, x0 + 22, y0 + 25))
    C.sep(c, band, bed, R.leather[2])
    local bi = C.part(c, band, R.strap, { R = 3, b = b + 1 })
    band:each(function(x, y)
      local u, v = (x - x0 + 1) % 5, (y - y0) % 5
      local i, j = (x - x0 + 1) // 5, (y - y0) // 5
      local base = bi[K(x, y)]
      local t = base
      if (i + j) % 2 == 0 then
        if u == 4 then t = base - 2 elseif u == 0 then t = base + 1 elseif v == 4 then t = base - 1 end
      else
        if v == 4 then t = base - 2 elseif v == 0 then t = base + 1 elseif u == 4 then t = base - 1 end
      end
      c:put(x, y, R.strap[math.max(1, math.min(6, t))])
    end)
    -- heel strap loop standing behind the heel, ankle strap across
    local ring = c:ellipse(cx - 1, y0 + 37, 7, 9.5):cut(c:ellipse(cx - 1, y0 + 36, 4.5, 7)):clip(bed)
    ring:cut(c:rect(x0 - 4, y0, x0 + 24, y0 + 31))
    ring:each(function(x, y) c:put(x, y, R.strap[(x < cx - 1) and 4 + math.min(b + 1, 1) or 3]) end)
    ring:each(function(x, y) if not ring:has(x, y + 1) or not ring:has(x + 1, y) then c:put(x, y, R.strap[2]) end end)
    C.vline(c, cx, y0 + 25, y0 + 29, R.strap[4]) C.vline(c, cx + 1, y0 + 25, y0 + 29, R.strap[2])
    local ank = c:line({ {x0 - 1, y0 + 31}, {cx, y0 + 29}, {x0 + 18, y0 + 31} }, 2)
    ank:each(function(x, y) c:put(x, y, R.strap[(y < y0 + 29) and 5 or 3]) end)
    -- tiny brass buckle on the ankle strap
    C.put(c, { {x0 + 14, y0 + 28}, {x0 + 15, y0 + 28}, {x0 + 14, y0 + 31}, {x0 + 15, y0 + 31}, {x0 + 13, y0 + 29}, {x0 + 13, y0 + 30} }, R.brass[4])
    c:put(x0 + 13, y0 + 29, R.brass[6])
    if bead then
      C.ball(c, cx + 1, y0 + 16, 2.2, R.turq)
      c:put(cx, y0 + 15, R.turq[6])
      C.put(c, { {cx + 4, y0 + 17}, {cx + 4, y0 + 18}, {cx + 5, y0 + 19} }, R.strap[2])
    end
  end
  sandal(33, 5, -1, false)
  sandal(11, 9, 0, true)
  C.save(c, "footwear-1-lattice-huaraches")
end

---------------------------------------------------------------- 2 tooled ankle boots (side view pair)
do
  local c = C.new("footwear-2-tooled-ankle-boots")
  local function boot(dx, dy, b, gecko)
    local shaft = c:poly{ {13 + dx, 16 + dy}, {28 + dx, 16 + dy}, {29 + dx, 38 + dy}, {13 + dx, 40 + dy} }
    local foot = c:poly{ {13 + dx, 34 + dy}, {28 + dx, 34 + dy}, {40 + dx, 40 + dy}, {44 + dx, 44 + dy}, {44 + dx, 48 + dy}, {13 + dx, 48 + dy} }
    local heel = c:poly{ {13 + dx, 48 + dy}, {22 + dx, 48 + dy}, {21 + dx, 54 + dy}, {14 + dx, 54 + dy} }
    local sole = c:rect(22 + dx, 48 + dy, 44 + dx, 50 + dy):cut(c:rect(22 + dx, 50 + dy, 24 + dx, 50 + dy))
    local body = shaft:copy():add(foot)
    local all = body:copy():add(heel):add(sole)
    local P = {}
    P.all = all
    P.paint = function()
      C.part(c, heel, R.cacao, { R = 1, b = b })
      for y = 50 + dy, 53 + dy, 2 do C.hline(c, 14 + dx, 20 + dx, y, R.cacao[2]) end
      C.part(c, sole, R.sole, { R = 1, b = b })
      C.vcyl(c, shaft, R.leather, 13 + dx, 29 + dx, { b = b, cuts = { .2, .36, .52, .7, .9 } })
      C.part(c, foot:copy():cut(shaft), R.leather, { R = 5, hs = .6, b = b })
      -- toe cap seam + ankle crease
      for x = 31 + dx, 43 + dx do if foot:has(x, 44 + dy) and not foot:has(x, 43 + dy) == false then c:put(x, 43 + dy, R.leather[3]) end end
      C.put(c, { {27 + dx, 37 + dy}, {28 + dx, 36 + dy}, {29 + dx, 36 + dy} }, R.leather[3])
      C.hline(c, 13 + dx, 43 + dx, 47 + dy, R.leather[2])
      -- stamped vine: a wavy stem with leaf pairs
      for y = 19 + dy, 37 + dy do
        local x = 21 + dx + math.floor(2.2 * math.sin((y - dy) * 0.5) + .5)
        c:put(x, y, R.leather[2 + math.min(b + 1, 1)])
        if (y - dy) % 5 == 0 then c:put(x - 1, y - 1, R.leather[2]) c:put(x + 1, y - 1, R.leather[2]) c:put(x - 2, y - 1, R.leather[5]) end
      end
      -- top welt + pull tab
      C.hline(c, 13 + dx, 28 + dx, 16 + dy, R.leather[6 + math.min(b, 0)])
      C.hline(c, 13 + dx, 28 + dx, 17 + dy, R.leather[2])
      local tab = c:rrect(25 + dx, 11 + dy, 28 + dx, 17 + dy, 1)
      C.part(c, tab, R.cacao, { R = 1, b = b + 1 })
      c:put(26 + dx, 13 + dy, R.cacao[1])
    end
    return P
  end
  local back = boot(11, -5, -1)
  local front = boot(0, 0, 0)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  -- shine
  C.vline(c, 15, 21, 36, R.leather[6]) c:put(15, 22, C.cream)
  c:put(34, 40, R.leather[6]) c:put(35, 40, R.leather[6])
  -- quirk: gecko peeking over the front boot top
  local head = c:ellipse(19, 13, 3.2, 2.4)
  C.part(c, head, R.jade, { R = 1, b = 1 })
  C.put(c, { {14, 15}, {15, 14}, {16, 15} }, R.jade[4]) -- little hand
  c:put(14, 15, R.jade[5])
  C.put(c, { {18, 12}, {21, 12} }, C.ink)
  C.put(c, { {18, 11}, {21, 11} }, R.jade[6])
  c:put(19, 15, R.jade[2]) c:put(20, 15, R.jade[2])
  C.save(c, "footwear-2-tooled-ankle-boots")
end

---------------------------------------------------------------- 3 indigo leg wraps (tall gaiters over soft shoes)
do
  local c = C.new("footwear-3-indigo-leg-wraps")
  local function wrap(dx, dy, b)
    local leg = c:poly{ {14 + dx, 6 + dy}, {28 + dx, 6 + dy}, {27 + dx, 44 + dy}, {16 + dx, 44 + dy} }
    local shoe = c:ellipse(25 + dx, 49 + dy, 11, 5):cut(c:rect(0, 54 + dy, 64, 64)):add(c:rrect(14 + dx, 42 + dy, 29 + dx, 52 + dy, 3))
    local P = { all = leg:copy():add(shoe) }
    P.paint = function()
      local si = C.part(c, shoe:copy():cut(leg), R.cacao, { R = 3, b = b + 1 })
      C.hline(c, 15 + dx, 35 + dx, 53 + dy, R.cacao[1])
      local li = C.vcyl(c, leg, R.indigo, 14 + dx, 28 + dx, { b = b })
      -- spiral bands: diagonal seams, each band's lower lip shaded, upper lip lit
      leg:each(function(x, y)
        local s = (y - dy) + (x - dx - 14) * 0.45
        local u = s % 6
        local i = li[K(x, y)]
        if u < 1 then c:put(x, y, R.indigo[1])
        elseif u < 2 then c:put(x, y, R.indigo[math.min(6, i + 1)])
        elseif u >= 5 then c:put(x, y, R.indigo[math.max(1, i - 1)]) end
      end)
      -- cloth top fold
      local top = c:rrect(13 + dx, 4 + dy, 29 + dx, 9 + dy, 2)
      C.part(c, top, R.indigo, { R = 2, b = b + 1 })
      C.hline(c, 14 + dx, 28 + dx, 9 + dy, R.indigo[1])
      -- red cord tied criss-cross at the ankle with hanging ends
      local cord = c:line({ {15 + dx, 34 + dy}, {27 + dx, 40 + dy} }, 1):add(c:line({ {15 + dx, 40 + dy}, {27 + dx, 34 + dy} }, 1))
        :add(c:line({ {15 + dx, 12 + dy}, {28 + dx, 12 + dy} }, 1))
      cord:each(function(x, y) c:put(x, y, R.cochi[(x + y) % 2 == 0 and 4 + math.min(b + 1, 1) or 3]) end)
    end
    return P
  end
  local back = wrap(14, -2, -1)
  local front = wrap(0, 2, 0)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  -- knot + tails on the front cord
  C.put(c, { {28, 39}, {29, 39}, {28, 40} }, R.cochi[5])
  local tails = c:line({ {29, 40}, {31, 44} }, 1):add(c:line({ {28, 41}, {29, 46} }, 1))
  tails:each(function(x, y) c:put(x, y, R.cochi[3]) end)
  c:put(31, 45, R.cochi[5]) c:put(29, 47, R.cochi[5])
  -- light streak on the front wrap
  for y = 13, 32 do if (y + 1) % 6 > 1 then c:put(17, y, R.indigo[6]) end end
  -- quirk: leaf-cutter ant on the top cord carrying a leaf scrap
  C.put(c, { {22, 13}, {23, 13}, {25, 13} }, R.cacao[1])
  c:put(24, 13, R.cacao[2])
  C.put(c, { {22, 14}, {24, 14}, {26, 14} }, R.cacao[1])
  local leaf = c:poly{ {22, 7}, {27, 9}, {25, 12}, {21, 11} }
  C.part(c, leaf, R.jade, { R = 1, b = 1 })
  c:put(23, 12, R.cacao[1])
  C.save(c, "footwear-3-indigo-leg-wraps")
end

---------------------------------------------------------------- 4 ixtle slippers (braided agave fibre, rope sole)
do
  local c = C.new("footwear-4-ixtle-slippers")
  local function slip(dx, dy, b)
    local upper = c:ellipse(36 + dx, 41 + dy, 12, 12):cut(c:rect(0, 45 + dy, 64, 64))
      :add(c:rrect(12 + dx, 34 + dy, 40 + dx, 45 + dy, 4)):add(c:ellipse(22 + dx, 35 + dy, 9, 2.5))
    local mouth = c:ellipse(22 + dx, 35 + dy, 8, 2)
    local sole = c:rrect(11 + dx, 44 + dy, 49 + dx, 49 + dy, 2)
    local P = { all = upper:copy():add(sole) }
    P.paint = function()
      C.part(c, sole, R.straw, { R = 2, b = b - 1, tex = function(x, y) if (x + y) % 3 == 0 then return -1 elseif (x + y) % 3 == 1 then return 1 end end })
      C.hline(c, 12 + dx, 48 + dx, 49 + dy, R.straw[1])
      local ui = C.part(c, upper, R.straw, { R = 6, hs = .7, b = b })
      -- braided rows: chevrons following the dome
      upper:each(function(x, y)
        local yy = y - dy
        local row = (yy + 1) % 4
        local i = ui[K(x, y)]
        if row == 0 then c:put(x, y, R.straw[math.max(1, i - 2)])
        elseif row == 1 and (x + (yy // 4)) % 3 == 0 then c:put(x, y, R.straw[math.min(6, i + 1)])
        elseif row == 3 and (x + (yy // 4)) % 3 == 1 then c:put(x, y, R.straw[math.max(1, i - 1)]) end
      end)
      -- opening at the heel end
      local mo = mouth:copy():clip(upper)
      C.fill(c, mo, R.straw[1])
      mo:each(function(x, y) if not mo:has(x, y - 1) then c:put(x, y, R.cacao[2]) end end)
      mo:each(function(x, y) if not mo:has(x, y + 1) then c:put(x, y, R.straw[5]) end end)
    end
    return P
  end
  local back = slip(6, -12, -1)
  local front = slip(-2, 0, 0)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  -- quirk: cochineal pompom tassels on the toes
  local function pom(x, y)
    C.ball(c, x, y, 3, R.cochi)
    c:put(x - 1, y - 2, R.cochi[6]) c:put(x + 2, y + 1, R.cochi[1])
    c:put(x - 3, y + 2, R.cochi[3]) c:put(x - 2, y + 3, R.cochi[2])
  end
  pom(52, 21)
  pom(46, 33)
  C.save(c, "footwear-4-ixtle-slippers")
end

---------------------------------------------------------------- 5 market platform clogs (carved wood + palm band)
do
  local c = C.new("footwear-5-market-platform-clogs")
  local function clog(dx, dy, b, sprout)
    local top = c:rrect(8 + dx, 34 + dy, 46 + dx, 38 + dy, 2)
    local block = c:rrect(7 + dx, 37 + dy, 47 + dx, 51 + dy, 5):add(c:rrect(7 + dx, 37 + dy, 20 + dx, 51 + dy, 2))
    block:cut(top)
    local notch = c:ellipse(27 + dx, 52 + dy, 8, 5)
    block:cut(notch)
    local band = c:ellipse(36 + dx, 36 + dy, 10, 11):cut(c:rect(0, 36 + dy, 64, 64))
    local P = { all = top:copy():add(block):add(band) }
    P.paint = function()
      C.part(c, top, R.wood, { R = 2, b = b + 1 })
      C.hline(c, 10 + dx, 44 + dx, 34 + dy, R.wood[6 + math.min(b, 0)])
      local bi = C.part(c, block, R.wood, { R = 3, b = b, tex = function(x, y) if (y % 3 == 0) and hash(x, y, 9) < .5 then return -1 end end })
      -- painted clay stripe with dots
      for x = 7 + dx, 47 + dx do if block:has(x, 41 + dy) then c:put(x, 41 + dy, R.clay[4 + math.min(b + 1, 1)]) c:put(x, 42 + dy, R.clay[3]) end end
      for x = 9 + dx, 46 + dx, 4 do if block:has(x, 44 + dy) then c:put(x, 44 + dy, R.maize[5]) end end
      -- palm band: woven checker, curving over the foot
      C.sep(c, band, top, R.wood[2])
      local pi = C.part(c, band, R.straw, { R = 4, b = b })
      band:each(function(x, y)
        local i = pi[K(x, y)]
        if ((x // 3) + (y // 3)) % 2 == 0 then c:put(x, y, R.straw[math.min(6, i + 1)]) else c:put(x, y, R.straw[math.max(1, i - 1)]) end
      end)
      -- dark opening where the foot goes in (back edge of the band)
      for y = 27 + dy, 35 + dy do local x0 for x = 20 + dx, 50 + dx do if band:has(x, y) then x0 = x break end end
        if x0 then c:put(x0, y, R.straw[1]) c:put(x0 + 1, y, R.cacao[2]) end end
      -- palm fringe edge along the toe side
      band:each(function(x, y) if not band:has(x + 1, y) and y % 2 == 0 then c:put(x, y, R.straw[2]) end end)
    end
    return P
  end
  local back = clog(10, -14, -1, false)
  local front = clog(0, 4, 0, true)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  -- crack in the front heel and a sprout growing out
  C.put(c, { {12, 44}, {13, 45}, {13, 46}, {14, 47}, {14, 48} }, R.wood[1])
  C.put(c, { {12, 43}, {12, 42}, {11, 41}, {11, 40}, {11, 39} }, R.jade[3])
  local l1 = c:poly{ {11, 39}, {6, 35}, {9, 34}, {12, 37} }
  local l2 = c:poly{ {11, 38}, {14, 33}, {17, 34}, {13, 39} }
  C.part(c, l1, R.jade, { R = 1, b = 1 }) C.part(c, l2, R.jade, { R = 1 })
  c:put(8, 35, R.jade[6]) c:put(15, 34, R.jade[6])
  -- wood shine
  C.hline(c, 10, 18, 39, R.wood[6])
  C.save(c, "footwear-5-market-platform-clogs")
end
