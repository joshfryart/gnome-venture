-- footwear.lua: MENA "Dunewhisper" footwear concepts, 5 icons (see concepts.md).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local floor, sqrt, abs = math.floor, math.sqrt, math.abs

---------------------------------------------------------------- 1 dune slippers
do
  local c = C.new("footwear-1-dune-slippers")
  local function slipper(dx, dy, b)
    local S = {}
    local vamp = c:poly{ {21+dx,41+dy}, {23+dx,33+dy}, {29+dx,29+dy}, {39+dx,28+dy}, {47+dx,29+dy}, {53+dx,30+dy},
      {56+dx,24+dy}, {59+dx,24+dy}, {58+dx,30+dy}, {55+dx,37+dy}, {50+dx,41+dy} }
    local wall = c:rrect(7+dx, 36+dy, 30+dx, 41+dy, 2)
    local body = vamp:copy():add(wall)
    local sole = c:rrect(7+dx, 41+dy, 53+dx, 43+dy, 1)
    S.all = body:copy():add(sole)
    S.paint = function()
      C.lay(c, sole, R.sole, { R = 1, bias = b })
      C.hline(c, 8+dx, 52+dx, 41+dy, R.sole[5 + (b or 0)])
      C.lay(c, wall, R.ochre, { R = 2, bias = b })
      C.lay(c, vamp, R.ochre, { R = 4, bias = b, cuts = { .22, .4, .56, .72, .88 } })
      -- insole seen through the open back
      local hole = c:poly{ {8+dx,37+dy}, {13+dx,35+dy}, {24+dx,34+dy}, {25+dx,36+dy}, {23+dx,38+dy}, {9+dx,38+dy} }
      c:fillMask(hole, R.lining[3 + (b or 0)])
      C.hline(c, 10+dx, 23+dx, 38+dy, R.lining[2 + (b or 0)])
      C.hline(c, 13+dx, 22+dx, 35+dy, R.lining[5 + (b or 0)])
      -- wall top rim
      C.hline(c, 8+dx, 22+dx, 39+dy, R.ochre[2 + (b or 0)])
      -- vamp edge seam: stitched line where the vamp meets the wall
      C.stroke(c, { {23+dx,34+dy}, {22+dx,40+dy} }, R.ochre[2 + (b or 0)])
      for y = 35, 39, 2 do c:put(24+dx, y+dy, R.ochre[6 + (b or 0)]) end
      -- decorative stitched line along the vamp
      for x = 27, 51, 2 do
        local yy
        for y = 28, 42 do if vamp:has(x+dx, y+dy) then yy = y break end end
        if yy then c:put(x+dx, yy+3+dy, R.ochre[2 + (b or 0)]) end
      end
    end
    return S
  end
  local back = slipper(-3, -10, -1)
  local front = slipper(0, 0, nil)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  -- shine on front vamp and the curled tip
  C.hline(c, 31, 38, 30, R.ochre[6]) c:put(32, 30, C.cream) c:put(33, 30, C.cream)
  c:put(56, 25, R.ochre[6]) c:put(57, 25, R.ochre[6])
  -- quirk: a trickle of sand pouring from the curled toe
  local grains = { {60,27,5}, {60,29,4}, {61,31,6}, {60,33,4}, {61,35,5}, {60,37,3}, {61,39,5} }
  for _, g in ipairs(grains) do c:put(g[1], g[2], R.sand[g[3]]) end
  local heap = c:poly{ {57,44}, {60,41}, {63,44} }
  C.lay(c, heap, R.sand, { R = 1 })
  c:put(60, 42, R.sand[6])
  C.save(c, "footwear-1-dune-slippers")
end

---------------------------------------------------------------- 2 palm-rope sandals
do
  local c = C.new("footwear-2-palm-rope-sandals")
  local function sole(cx, cy)
    return c:ellipse(cx, cy - 8, 7.5, 10):add(c:ellipse(cx - 1, cy + 9, 6, 8)):add(c:rect(cx - 6, cy - 6, cx + 5, cy + 8))
  end
  local plait = function(x, y, i)
    if y % 3 == 2 then return -1 end
    if (x + floor(y / 3)) % 3 == 0 then return 1 end
  end
  local function sandal(cx, cy, b)
    local S = {}
    local top = sole(cx, cy)
    local edge = top:shift(0, 2):cut(top)
    S.all = top:copy():add(edge)
    S.paint = function()
      edge:each(function(x, y) c:put(x, y, (top:has(x, y - 1) and not top:has(x, y - 2)) and R.palm[2 + (b or 0)] or R.palm[1]) end)
      edge:each(function(x, y) if (x % 2 == 0) and top:has(x, y - 1) then c:put(x, y, R.palm[3 + (b or 0)]) end end)
      C.lay(c, top, R.palm, { R = 3, bias = b, tex = plait })
      -- foot-shaped shadow worn into the sole
      local worn = c:ellipse(cx, cy - 7, 4, 6):add(c:ellipse(cx - 1, cy + 9, 3, 5))
      worn:each(function(x, y) if (x + y) % 2 == 0 then c:put(x, y, R.palm[3 + (b or 0)]) end end)
      -- crossed straps over the midfoot
      local function strap(pts)
        local m = c:line(pts, 2)
        C.lay(c, m, R.leather, { R = 1, bias = b })
        return m
      end
      local s1 = c:line({ {cx - 7, cy - 1}, {cx + 6, cy - 9} }, 2)
      local s2 = c:line({ {cx + 6, cy - 1}, {cx - 7, cy - 9} }, 2)
      C.lay(c, s1, R.leather, { R = 1, bias = (b or 0) - 1 })
      C.sep(c, s2, s1, R.leather[1])
      C.lay(c, s2, R.leather, { R = 1, bias = b })
      -- heel strap
      local hs = c:line({ {cx - 7, cy + 8}, {cx - 3, cy + 6}, {cx + 2, cy + 6}, {cx + 5, cy + 8} }, 2)
      C.lay(c, hs, R.leather, { R = 1, bias = b })
      -- toe loop
      local ring = c:ellipse(cx - 1, cy - 14, 1.6, 1.6):cut(c:rect(cx - 1, cy - 14, cx - 1, cy - 14))
      ring:each(function(x, y) c:put(x, y, R.leather[(x < cx - 1 or y < cy - 14) and 5 or 2]) end)
      -- knot where the straps cross
      c:put(cx - 1, cy - 5, R.leather[6 + (b or 0)]) c:put(cx, cy - 5, R.leather[4 + (b or 0)])
    end
    return S
  end
  local left = sandal(21, 30, -1)
  local right = sandal(40, 35, nil)
  left.paint()
  C.sep(c, right.all, left.all, C.ink)
  right.paint()
  -- quirk: little green gecko resting on the right sole's heel
  local gx, gy = 40, 43
  local body = c:line({ {gx, gy - 4}, {gx, gy + 3} }, 2)
  local tail = c:line({ {gx + 1, gy + 4}, {gx + 3, gy + 6}, {gx + 5, gy + 6}, {gx + 6, gy + 4} }, 1)
  local gall = body:copy():add(tail)
  for _, l in ipairs({ {gx - 2, gy - 3}, {gx - 2, gy + 2}, {gx + 3, gy - 3}, {gx + 3, gy + 2}, {gx - 1, gy - 5}, {gx, gy - 5} }) do gall:set(l[1], l[2]) end
  gall:grow(1):cut(gall):each(function(x, y) c:put(x, y, R.palm[1]) end)
  C.lay(c, body, R.mint, { R = 1 })
  tail:each(function(x, y) c:put(x, y, R.mint[5]) end)
  for _, l in ipairs({ {gx - 2, gy - 3}, {gx - 2, gy + 2}, {gx + 3, gy - 3}, {gx + 3, gy + 2} }) do c:put(l[1], l[2], R.mint[4]) end
  c:put(gx - 1, gy - 5, R.mint[5]) c:put(gx, gy - 5, R.mint[4])
  c:put(gx - 1, gy - 4, C.ink) c:put(gx + 1, gy - 4, C.ink)
  c:put(gx, gy - 2, R.mint[6])
  C.save(c, "footwear-2-palm-rope-sandals")
end

---------------------------------------------------------------- 3 indigo wrap boots
do
  local c = C.new("footwear-3-indigo-wrap-boots")
  local function boot(dx, dy, b)
    local B = {}
    b = b or 0
    local shaft = c:poly{ {13+dx,12+dy}, {27+dx,12+dy}, {28+dx,39+dy}, {12+dx,41+dy} }
    local foot = c:rrect(11+dx, 37+dy, 31+dx, 48+dy, 3):add(c:ellipse(34+dx, 44+dy, 7, 4))
      :add(c:poly{ {26+dx,37+dy}, {36+dx,40+dy}, {43+dx,43+dy}, {38+dx,47+dy}, {28+dx,46+dy} })
    local sole = c:rrect(10+dx, 48+dy, 42+dx, 50+dy, 1)
    local flap = c:poly{ {13+dx,13+dy}, {8+dx,7+dy}, {11+dx,6+dy}, {18+dx,12+dy} }
    B.all = shaft:copy():add(foot):add(sole):add(flap)
    B.paint = function()
      C.lay(c, sole, R.sole, { R = 1, bias = b })
      C.hline(c, 11+dx, 41+dx, 48+dy, R.sole[5 + b])
      local fm = foot:copy():cut(shaft)
      C.lay(c, fm, R.camel, { R = 5, hs = 0.6, bias = b })
      C.stroke(c, { {30+dx,45+dy}, {40+dx,45+dy} }, R.camel[2 + b], fm)
      -- wrapped shaft: diagonal bands
      local bm = {}
      shaft:each(function(x, y) local band = floor((y - 12 - dy + (x - 12 - dx) * 0.45) / 4) bm[K(x, y)] = (band % 2 == 0) and b or b - 1 end)
      local sidx = C.vcyl(c, shaft, R.indigo, 12+dx, 28+dx, { bias = bm, cuts = { .2, .36, .52, .7, .9 } })
      shaft:each(function(x, y)
        local v = (y - 12 - dy + (x - 12 - dx) * 0.45) / 4
        local f = v - floor(v)
        if f < 0.25 and y > 13+dy then c:put(x, y, R.indigo[1]) elseif f < 0.5 and x < 22+dx then c:put(x, y, R.indigo[math.min(6, 5 + b)]) end
      end)
      -- loose wrap end flapping at the top
      C.lay(c, flap, R.indigo, { R = 1, bias = b + 1 })
      C.hline(c, 13+dx, 27+dx, 12+dy, R.indigo[5 + b])
      -- criss-cross cord
      local cord = c:line({ {12+dx,38+dy}, {27+dx,32+dy}, {13+dx,26+dy}, {27+dx,20+dy}, {13+dx,15+dy} }, 1)
      cord:each(function(x, y) if shaft:has(x, y) then c:put(x, y, R.camel[(x < 20+dx) and 6 or 4]) end end)
    end
    return B
  end
  local back = boot(11, -5, -1)
  local front = boot(0, 0, nil)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  -- leather shine on the toe
  c:put(33, 41, R.camel[6]) c:put(34, 41, R.camel[6]) c:put(35, 42, R.camel[5])
  -- quirk: cord end dangling with a turquoise bead
  local cd = c:line({ {12,39}, {8,42}, {7,46} }, 1)
  cd:each(function(x, y) c:put(x, y, R.camel[4]) end)
  local bead = c:ellipse(7, 49, 1.7, 1.7)
  C.lay(c, bead, R.turq, { R = 1 })
  c:put(6, 48, R.turq[6])
  C.save(c, "footwear-3-indigo-wrap-boots")
end

---------------------------------------------------------------- 4 camel-pad overshoes
do
  local c = C.new("footwear-4-camel-pad-overshoes")
  local function shoe(dx, dy, b)
    local S = {}
    b = b or 0
    local pad = c:ellipse(26+dx, 45+dy, 22, 4.5)
    local padtop = c:ellipse(26+dx, 44+dy, 21, 3)
    local shaft = c:rrect(15+dx, 20+dy, 31+dx, 42+dy, 4)
    local foot = c:ellipse(31+dx, 38+dy, 11, 5.5):clip(c:rect(0, 0, 63, 43+dy))
    local body = shaft:copy():add(foot)
    local cuff = c:rrect(13+dx, 16+dy, 33+dx, 22+dy, 3)
    S.all = body:copy():add(pad):add(cuff)
    S.paint = function()
      C.lay(c, pad, R.sole, { R = 2, bias = b - 1 })
      C.lay(c, padtop, R.camel, { R = 2, bias = b - 1, tex = C.wool })
      padtop:each(function(x, y) if not padtop:has(x, y - 1) then c:put(x, y, R.camel[4 + b]) end end)
      -- two toe lobes of the pad: cleft at the front
      C.stroke(c, { {45+dx,43+dy}, {47+dx,45+dy} }, R.sole[1])
      for x = 8, 44, 4 do c:put(x+dx, 49+dy, R.sole[1]) end
      C.sep(c, body, padtop, R.camel[1])
      C.lay(c, body, R.camel, { R = 5, hs = 0.8, bias = b, tex = C.wool })
      C.stroke(c, { {31+dx,34+dy}, {36+dx,33+dy}, {40+dx,35+dy} }, R.camel[2 + b], body)
      C.sep(c, cuff, body, R.camel[1])
      C.lay(c, cuff, R.madder, { R = 2, bias = b, tex = C.wool })
      local hole = c:ellipse(23+dx, 16+dy, 8, 1.6)
      c:fillMask(hole, R.madder[1])
      C.hline(c, 17+dx, 29+dx, 18+dy, R.madder[6 + b])
      for x = 15, 32, 2 do c:put(x+dx, 21+dy, R.madder[2 + b]) end
    end
    return S
  end
  local back = shoe(12, -7, -1)
  local front = shoe(0, 0, nil)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  -- drawstring with knot at the cuff
  C.stroke(c, { {14,22}, {11,26}, {12,30} }, R.linen[4])
  c:put(13, 22, R.linen[6]) c:put(12, 31, R.linen[3])
  -- quirk: a two-toed camel footprint stitched on the side
  for _, t in ipairs({ {21,31}, {26,31} }) do
    local m = c:ellipse(t[1], t[2], 1.6, 3)
    c:fillMask(m, R.madder[3])
    m:edge():each(function(x, y) if x <= t[1] and y <= t[2] then c:put(x, y, R.madder[5]) end end)
    c:put(t[1], t[2] - 2, R.madder[6])
  end
  -- felt highlight
  C.vline(c, 17, 24, 30, R.camel[6]) c:put(18, 24, R.camel[6])
  C.save(c, "footwear-4-camel-pad-overshoes")
end

---------------------------------------------------------------- 5 cedar bath clogs
do
  local c = C.new("footwear-5-cedar-bath-clogs")
  local grain = function(x, y, i) if (y * 7 + floor(x / 5)) % 4 == 0 and X.hash(x, y, 3) < 0.7 then return -1 end end
  local function clog(dx, dy, b)
    local S = {}
    b = b or 0
    local plank = c:poly{ {5+dx,33+dy}, {44+dx,32+dy}, {47+dx,34+dy}, {46+dx,38+dy}, {5+dx,38+dy} }
    local heel = c:poly{ {7+dx,38+dy}, {18+dx,38+dy}, {17+dx,49+dy}, {8+dx,49+dy} }
    local ball = c:poly{ {30+dx,38+dy}, {42+dx,38+dy}, {41+dx,49+dy}, {31+dx,49+dy} }
    local strap = c:ellipse(34+dx, 33+dy, 11, 10):clip(c:rect(0, 0, 63, 32+dy))
    S.all = plank:copy():add(heel):add(ball):add(strap)
    S.paint = function()
      for _, m in ipairs({ heel, ball }) do C.lay(c, m, R.cedar, { R = 2, bias = b - 1, tex = grain }) end
      C.hline(c, 8+dx, 17+dx, 39+dy, R.cedar[1]) C.hline(c, 31+dx, 41+dx, 39+dy, R.cedar[1])
      C.lay(c, plank, R.cedar, { R = 2, bias = b, tex = grain })
      C.hline(c, 6+dx, 44+dx, 33+dy, R.cedar[6 + b])
      -- woven strap: madder arch band with linen edge stripes; foot hollow under it
      local idx = C.lay(c, strap, R.madder, { R = 2, bias = b })
      local hollow = c:ellipse(34+dx, 33+dy, 5.5, 4.5):clip(strap)
      strap:each(function(x, y)
        local ax, ay = (x - 34 - dx) / 11.5, (y - 33 - dy) / 10.5
        local d = sqrt(ax * ax + ay * ay)
        local i = idx[K(x, y)]
        if d > 0.9 then c:put(x, y, R.linen[math.min(6, i + 1)])
        elseif d > 0.62 and d < 0.72 then c:put(x, y, R.linen[math.min(6, i)]) end
      end)
      c:fillMask(hollow, R.cedar[1])
      hollow:each(function(x, y) if not hollow:has(x, y - 1) then c:put(x, y, R.madder[1]) end end)
      -- brass tacks
      for _, t in ipairs({ {24,32}, {44,32} }) do c:put(t[1]+dx, t[2]+dy, R.brass[4 + b]) end
    end
    return S
  end
  local back = clog(10, -7, -1)
  local front = clog(0, 0, nil)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  c:put(29, 25, R.madder[6]) c:put(30, 24, R.madder[6])
  -- quirk: a little cedar cone tucked under the strap
  local cone = c:ellipse(22, 28, 2.5, 3.5)
  C.lay(c, cone, R.camel, { R = 1 })
  for _, p in ipairs({ {21,26}, {23,27}, {21,29}, {23,30}, {22,31} }) do c:put(p[1], p[2], R.camel[2]) end
  c:put(21, 25, R.camel[6])
  C.stroke(c, { {23,24}, {24,22} }, R.cedar[2])
  C.save(c, "footwear-5-cedar-bath-clogs")
end
