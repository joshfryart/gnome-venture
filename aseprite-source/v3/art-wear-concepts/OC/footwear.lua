-- footwear.lua: OC (Coralscatter) footwear concepts, 5 icons.
-- Run: AppRun -b --script-param png=<dir>/ --script footwear.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R = C.HP, C.X, C.K, C.R
local floor = math.floor

---------------------------------------------------------------- 1 reef sandals
do
  local c = C.canvas("footwear-1-reef-sandals")
  local function sole(cx, cy)
    return c:ellipse(cx + 1, cy - 9, 7, 9):add(c:ellipse(cx - 1, cy + 9, 6, 8))
      :add(c:poly{ {cx - 6, cy - 8}, {cx + 8, cy - 8}, {cx + 6, cy + 9}, {cx - 7, cy + 9} })
  end
  local function sandal(cx, cy, b)
    local s = sole(cx, cy)
    local rim = s:shift(1, 2):cut(s)
    C.fill(c, rim, R.coir[b < 0 and 1 or 2])
    local i = C.part(c, s, R.pandanus, { R = 3, b = b, cuts = { .2, .36, .52, .7, .88 } })
    C.retone(c, s, i, R.pandanus, function(x, y)
      local a = floor((x + y) / 2) % 2
      if a == 0 and (x - y) % 4 == 0 then return -1 end
      if a == 1 and (x - y) % 4 == 2 then return -1 end
      if a == 0 and (x - y) % 4 == 1 then return 1 end
    end)
    -- rim stitch line inside the edge
    s:shrink(1):edge():each(function(x, y) if (x + y) % 3 == 0 then c:put(x, y, R.pandanus[2]) end end)
    -- toe thong from toe post, V-strap to both edges
    local post = { cx + 1, cy - 11 }
    local L = c:line({ post, { cx - 5, cy - 3 }, { cx - 7, cy + 1 } }, 2)
    local Rr = c:line({ post, { cx + 6, cy - 4 }, { cx + 7, cy + 0 } }, 2)
    L:add(Rr)
    L:grow(1):cut(L):clip(s):each(function(x, y) if not L:has(x - 1, y - 1) then c:put(x, y, R.pandanus[1]) end end)
    L:each(function(x, y) c:put(x, y, R.coir[(x + y) % 2 == 0 and 4 + (b < 0 and -1 or 0) or 3 + (b < 0 and -1 or 0)]) end)
    c:put(post[1], post[2] - 1, R.coir[5 + (b < 0 and -1 or 0)])
    -- heel strap with a tie bow on the outer side
    local hs = c:rect(cx - 7, cy + 4, cx + 6, cy + 6):clip(s)
    hs:each(function(x, y) c:put(x, y, R.coir[(y == cy + 4) and (b < 0 and 4 or 5) or ((x % 2 == 0) and 3 or 2) + (b < 0 and -1 or 0)]) end)
    C.hline(c, cx - 6, cx + 5, cy + 7, R.pandanus[1])
    local sx = cx + 7
    C.put(c, { {sx,cy+4}, {sx+1,cy+3}, {sx+2,cy+3}, {sx+2,cy+4}, {sx,cy+6}, {sx+1,cy+7}, {sx+2,cy+8}, {sx+1,cy+9} }, R.coir[3])
    C.put(c, { {sx,cy+5}, {sx+1,cy+5} }, R.coir[5])
    return post
  end
  local p1 = sandal(21, 28, -1)
  local p2 = sandal(41, 34, 0)
  -- cowrie on the front thong post
  local cw = c:ellipse(p2[1], p2[2] + 1, 2.6, 2)
  C.part(c, cw, R.fleece, { R = 1 })
  c:put(p2[1] - 1, p2[2], C.cream) c:put(p2[1] - 2, p2[2] + 1, R.fleece[6])
  C.vline(c, p2[1], p2[2], p2[2] + 2, R.fleece[2])
  C.put(c, { {p2[1]-1,p2[2]+1}, {p2[1]+1,p2[2]+1} }, R.fleece[3])
  c:put(p1[1], p1[2], R.pandanus[6])
  C.save(c, "footwear-1-reef-sandals")
end

---------------------------------------------------------------- 2 gully fleece boot
do
  local c = C.canvas("footwear-2-gully-fleece-boot")
  local shaft = c:rrect(16, 16, 36, 48, 5)
  local foot = c:ellipse(40, 46, 10, 7):add(c:rrect(16, 38, 40, 52, 6))
  local body = shaft:copy():add(foot)
  local sole = c:rrect(14, 51, 51, 55, 2)
  -- sole (fleece crepe)
  C.part(c, sole, R.fleece, { R = 1, b = -1 })
  C.hline(c, 16, 49, 51, R.fleece[5])
  for x = 16, 49, 4 do c:put(x, 55, R.fleece[2]) end
  local si = C.part(c, body, R.suede, { R = 6, hs = .8, cuts = { .2, .36, .52, .7, .9 } })
  C.speckle(c, body, si, R.suede, .08, 3)
  -- back seam and toe seam stitches
  for y = 22, 48, 2 do c:put(18, y, R.suede[2]) end
  local toe = {}
  for x = 33, 48 do local yy = floor(46 - 6 * math.sqrt(math.max(0, 1 - ((x - 40) / 10) ^ 2)) + 2.5) toe[#toe + 1] = { x, yy } end
  C.dash(c, toe, R.suede[2])
  -- crease at the ankle
  C.put(c, { {30,40}, {31,39}, {32,39}, {33,40} }, R.suede[2])
  -- fleece cuff turned out, lumpy top
  local cuff = c:rrect(13, 10, 39, 21, 4)
  for x = 14, 38, 4 do cuff:add(c:ellipse(x, 10, 2, 2)) end
  for x = 15, 37, 5 do cuff:add(c:ellipse(x, 21, 2, 1.5)) end
  C.hline(c, 16, 36, 22, R.suede[1])
  C.hline(c, 16, 36, 23, R.suede[2])
  local ci = C.part(c, cuff, R.fleece, { R = 3, cuts = { .2, .34, .5, .68, .86 } })
  C.retone(c, cuff, ci, R.fleece, function(x, y, i)
    local h = X.hash(x, y, 9)
    if (x * 2 + y * 3) % 5 == 0 then return -1 end
    if h > .85 then return 1 end
  end)
  -- quirk: wattle puff sprig tucked in the cuff
  local stem = c:line({ {26,13}, {24,8}, {21,4} }, 1)
  stem:each(function(x, y) if y < 10 then c:put(x, y, R.leafwrap[3]) end end)
  C.put(c, { {27,7}, {28,6} }, R.leafwrap[4]) c:put(28, 5, R.leafwrap[5])
  C.ball(c, 19, 5, 2, R.brass) C.ball(c, 24, 5, 2, R.brass) C.ball(c, 21, 1.8, 2, R.brass)
  c:put(18, 4, R.brass[6]) c:put(23, 4, R.brass[6]) c:put(20, 1, R.brass[6])
  -- suede highlight streak
  C.vline(c, 20, 26, 40, R.suede[5])
  c:put(20, 27, R.suede[6])
  C.save(c, "footwear-2-gully-fleece-boot")
end

---------------------------------------------------------------- 3 drover's pull-ons
do
  local c = C.canvas("footwear-3-drovers-pull-ons")
  local function boot(dx, dy, b)
    local shaft = c:poly{ {14+dx,20+dy}, {29+dx,20+dy}, {30+dx,42+dy}, {13+dx,43+dy} }
    local foot = c:rrect(13+dx, 36+dy, 32+dx, 49+dy, 4):add(c:ellipse(36+dx, 45+dy, 7, 4.5))
      :add(c:poly{ {27+dx,35+dy}, {33+dx,39+dy}, {41+dx,42+dy}, {30+dx,45+dy} })
    local body = shaft:copy():add(foot)
    local heel = c:rect(13+dx, 49+dy, 21+dx, 53+dy)
    local sole = c:rrect(21+dx, 49+dy, 43+dx, 51+dy, 1)
    local B = { all = body:copy():add(heel):add(sole) }
    B.paint = function()
      C.part(c, heel, R.sole, { R = 1, b = b })
      for y = 50+dy, 52+dy, 2 do C.hline(c, 14+dx, 20+dx, y, R.sole[2 + b]) end
      C.part(c, sole, R.sole, { R = 1, b = b })
      local idx = C.vcylb(c, shaft, R.leather, 13+dx, 30+dx, b, { cuts = { .2, .36, .52, .7, .9 } })
      C.part(c, foot:copy():cut(shaft), R.leather, { R = 5, hs = .6, b = b, cuts = { .2, .36, .52, .7, .9 } })
      -- elastic gusset: U-panel on the shaft side
      local gus = c:poly{ {19+dx,21+dy}, {25+dx,21+dy}, {23+dx,32+dy}, {22+dx,34+dy}, {21+dx,32+dy} }
      local gi = C.vcylb(c, gus, R.cloak, 17+dx, 27+dx, b - 1, { cuts = { .2, .36, .52, .7, .9 } })
      C.retone(c, gus, gi, R.cloak, function(x, y) if y % 2 == 0 then return -1 end end)
      gus:grow(1):cut(gus):clip(shaft):each(function(x, y) c:put(x, y, R.leather[2 + b]) end)
      -- toe cap seam and welt line
      for x = 30+dx, 41+dx do if foot:has(x, 43+dy) then c:put(x, 43+dy, R.leather[2 + b]) end end
      C.hline(c, 22+dx, 42+dx, 48+dy, R.leather[2 + b])
      C.hline(c, 22+dx, 42+dx, 49+dy, R.sole[5 + b])
      -- pull tabs front and back
      local t1 = c:rrect(12+dx, 15+dy, 15+dx, 21+dy, 1)
      local t2 = c:rrect(27+dx, 15+dy, 30+dx, 21+dy, 1)
      for _, t in ipairs({ t1, t2 }) do
        C.part(c, t, R.strap, { R = 1, b = b })
        local x0, y0 = t:bbox()
        C.put(c, { {x0+1,y0+1}, {x0+2,y0+1} }, R.strap[1])
        C.put(c, { {x0+1,y0+2}, {x0+2,y0+2} }, R.strap[1])
      end
      C.hline(c, 14+dx, 29+dx, 21+dy, R.leather[2 + b])
      return idx
    end
    return B
  end
  local back = boot(12, -6, -1)
  local front = boot(0, 0, 0)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  -- polish shine
  C.vline(c, 15, 24, 40, R.leather[6]) c:put(15, 25, C.cream)
  C.put(c, { {33,41}, {34,41}, {35,41} }, R.leather[6])
  -- quirk: gecko on the front heel, climbing
  local g = R.turtle
  C.put(c, { {11,40}, {11,41}, {11,42}, {12,43}, {12,44}, {12,45}, {12,46}, {11,47}, {10,48} }, g[4])
  C.put(c, { {10,39}, {11,39}, {12,39}, {11,38} }, g[5])
  c:put(10, 38, C.ink)
  C.put(c, { {10,41}, {9,40}, {13,42}, {14,41}, {11,45}, {10,46}, {13,45}, {14,46} }, g[3])
  C.put(c, { {12,40}, {12,42} }, g[2])
  c:put(11, 40, g[6])
  C.save(c, "footwear-3-drovers-pull-ons")
end

---------------------------------------------------------------- 4 flax wading wraps
do
  local c = C.canvas("footwear-4-flax-wading-wraps")
  local shin = c:rrect(18, 12, 34, 42, 4)
  local foot = c:ellipse(37, 45, 11, 7):add(c:rrect(17, 38, 38, 52, 6))
  -- lumpy band edges
  local body = shin:copy():add(foot)
  for y = 14, 40, 5 do body:add(c:ellipse(17, y, 1.4, 1.4)) body:add(c:ellipse(35, y + 2, 1.4, 1.4)) end
  local sole = c:rrect(16, 51, 48, 54, 2)
  C.part(c, sole, R.coir, { R = 1 })
  for x = 18, 46, 3 do c:put(x, 54, R.coir[1]) end
  local i = C.part(c, body, R.flax, { R = 6, hs = .9, cuts = { .2, .36, .52, .7, .9 } })
  -- horizontal plaited bands (5 px) with alternating slant
  C.retone(c, body, i, R.flax, function(x, y)
    local band = floor((y - 12) / 5)
    if (y - 12) % 5 == 0 then return -2 end
    local sl = band % 2 == 0 and (x + y) or (x - y + 100)
    if sl % 3 == 0 then return -1 end
    if sl % 3 == 1 and X.hash(x, y, 4) < .3 then return 1 end
  end)
  -- criss-cross coir ties up the shin
  local ties = c:line({ {18,40}, {34,30}, {18,22}, {33,14} }, 1):add(c:line({ {34,40}, {18,30}, {34,22}, {19,14} }, 1))
  ties:each(function(x, y) if body:has(x, y) then c:put(x, y, R.coir[x < 26 and 5 or 3]) end end)
  -- knot and dangling strip ends at the top
  C.ball(c, 26, 12, 2, R.coir)
  local e1 = c:line({ {24,12}, {21,8}, {20,4} }, 2)
  local e2 = c:line({ {28,11}, {31,6}, {33,3} }, 1)
  e1:each(function(x, y) if y < 11 then c:put(x, y, R.flax[(x + y) % 2 == 0 and 5 or 4]) end end)
  e2:each(function(x, y) if y < 10 then c:put(x, y, R.flax[3]) end end)
  -- toe highlight
  C.put(c, { {40,41}, {41,41}, {42,42} }, R.flax[6])
  -- quirk: little red crab on the toe
  local cr = c:ellipse(44, 39, 3, 2)
  C.part(c, cr, R.ember, { R = 1 })
  c:put(43, 38, R.ember[6])
  C.put(c, { {40,36}, {41,37}, {48,36}, {47,37} }, R.ember[4])
  C.put(c, { {40,35}, {48,35} }, R.ember[5])
  C.put(c, { {43,36}, {45,36} }, C.ink)
  C.put(c, { {41,41}, {47,41}, {40,40}, {48,40} }, R.ember[2])
  C.save(c, "footwear-4-flax-wading-wraps")
end

---------------------------------------------------------------- 5 mangrove clog
do
  local c = C.canvas("footwear-5-mangrove-clog")
  local heel = c:rrect(11, 44, 25, 55, 2)
  local body = c:poly{ {9,24}, {27,22}, {36,25}, {47,31}, {55,37}, {57,44}, {53,49}, {9,49} }
    :add(c:rrect(8, 20, 28, 49, 7)):add(c:ellipse(49, 42, 8, 7))
  local sole = c:rrect(24, 48, 56, 51, 1)
  C.part(c, heel, R.wood, { R = 2, b = -1 })
  for y = 47, 54, 3 do C.hline(c, 12, 24, y, R.wood[2]) end
  C.part(c, sole, R.wood, { R = 1, b = -2 })
  C.sep(c, body, heel:copy():add(sole), C.ink)
  local i = C.part(c, body, R.wood, { R = 7, hs = .8, cuts = { .18, .34, .5, .68, .86 } })
  -- grain: long wavy streaks
  C.retone(c, body, i, R.wood, function(x, y)
    local v = y + math.sin(x * 0.3) * 1.5 + x * 0.12
    if floor(v) % 7 == 0 and X.hash(x, y, 2) < .8 then return -1 end
  end)
  -- foot opening at the back: dark hollow with a lit far lip
  local open = c:ellipse(18, 24, 8, 3.5)
  C.fill(c, open, R.wood[1])
  C.fill(c, c:ellipse(19, 25, 6, 2), C.ink)
  open:edge():each(function(x, y) if y <= 23 then c:put(x, y, R.wood[2]) end end)
  open:grow(1):cut(open):each(function(x, y) if y >= 24 then c:put(x, y, R.wood[6]) end end)
  -- straw-plait strap across the instep
  local strap = c:poly{ {28,21}, {36,24}, {34,49}, {26,49} }
  C.sep(c, strap, body, R.wood[2])
  local si = C.part(c, strap, R.pandanus, { R = 2 })
  C.retone(c, strap, si, R.pandanus, function(x, y) if (y + (floor(x / 3) % 2) * 2) % 4 == 0 then return -2 end end)
  strap:grow(1):cut(strap):clip(body):each(function(x, y) if x > 31 then c:put(x, y, R.wood[2]) end end)
  -- quirk: turtle inlaid on the strap
  local t = R.turtle
  local sh = c:ellipse(31, 36, 3, 4)
  C.fill(c, sh:grow(1), R.pandanus[1])
  C.part(c, sh, t, { R = 2 })
  C.put(c, { {31,35}, {31,36}, {31,37}, {30,34}, {32,34}, {30,38}, {32,38} }, t[2])
  c:put(30, 33, t[6]) c:put(29, 34, t[5])
  C.put(c, { {31,30}, {31,31} }, t[5]) c:put(30, 30, t[4]) c:put(32, 30, t[4])
  C.put(c, { {27,33}, {35,33}, {27,39}, {35,39}, {31,41} }, t[3])
  -- varnish shine
  C.put(c, { {42,31}, {43,31}, {44,32}, {45,32} }, R.wood[6]) c:put(41, 31, C.cream)
  C.put(c, { {10,28}, {10,29}, {10,30}, {10,31} }, R.wood[6])
  C.save(c, "footwear-5-mangrove-clog")
end
