-- footwear.lua: SA "Rainroot Reaches" footwear concepts, 5 icons (see concepts.md).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local abs, floor = math.abs, math.floor

---------------------------------------------------------------- 1 latex puddle boots
do
  local c = C.new("footwear-1-latex-puddle-boots")
  local function boot(dx, dy, b)
    local shaft = c:rrect(13+dx, 19+dy, 28+dx, 44+dy, 2)
    local foot = c:rrect(13+dx, 36+dy, 32+dx, 49+dy, 4):add(c:ellipse(34+dx, 44+dy, 7, 5))
    local body = shaft:copy():add(foot)
    local sole = c:rrect(12+dx, 48+dy, 42+dx, 51+dy, 1)
    local all = body:copy():add(sole)
    return { body = body, shaft = shaft, foot = foot, sole = sole, all = all, dx = dx, dy = dy, b = b }
  end
  local function paint(B)
    local dx, dy, b = B.dx, B.dy, B.b
    C.lit(c, B.sole, R.sole, { R = 1 })
    for x = 13+dx, 41+dx, 3 do c:put(x, 51+dy, R.sole[1]) end
    local idx = C.lit(c, B.body, R.latex, { R = 5, hs = 0.8, bias = b, cuts = { .2, .36, .52, .7, .88 } })
    -- dipped edge: cloth cuff on top, latex below with drip tongues
    local drip = { 0, 1, 3, 1, 0, 0, 2, 4, 2, 0, 0, 1, 0, 2, 3, 1 }
    for x = 13+dx, 28+dx do
      local d = drip[(x - 13 - dx) % #drip + 1]
      for y = 19+dy, 24+dy + d do
        if B.body:has(x, y) then
          local i = idx[K(x, y)] or 3
          local cv = R.canvas[math.max(1, math.min(6, i))]
          if y == 24+dy + d then cv = R.latex[math.min(6, i + 1)] end
          c:put(x, y, cv)
        end
      end
      -- rim lip
    end
    C.hline(c, 13+dx, 28+dx, 19+dy, R.canvas[6 + (b or 0)])
    -- sole seam line, toe cap ridge
    for x = 13+dx, 40+dx do if B.body:has(x, 47+dy) then c:put(x, 47+dy, R.latex[2]) end end
    return idx
  end
  local back = boot(12, -6, -1)
  local front = boot(0, 0, 0)
  paint(back)
  C.sep(c, front.all, back.all, C.ink)
  paint(front)
  -- gloss streaks
  C.vline(c, 15, 27, 40, R.latex[6]) C.vline(c, 16, 28, 33, R.latex[6])
  c:put(15, 28, C.cream) c:put(15, 29, C.cream)
  C.hline(c, 34, 37, 40, R.latex[6]) c:put(34, 40, C.cream)
  C.vline(c, 27+12, 25, 36, R.latex[6])
  -- quirk: tree frog sitting on the front toe
  local fr = c:ellipse(39, 38, 4.5, 2.8):add(c:ellipse(36, 35, 1.8, 1.8)):add(c:ellipse(42, 35, 1.8, 1.8))
  C.sep(c, fr, front.all, R.latex[2])
  C.lit(c, fr, R.frog, { R = 2 })
  c:put(36, 35, C.ink) c:put(42, 35, C.ink) c:put(35, 34, R.frog[6]) c:put(41, 34, R.frog[6])
  C.put(c, { {37,38}, {38,39}, {39,39}, {40,39}, {41,38} }, R.frog[2])
  C.put(c, { {34,41}, {44,41} }, R.frog[4])
  c:put(36, 37, R.frog[6])
  C.save(c, "footwear-1-latex-puddle-boots")
end

---------------------------------------------------------------- 2 puna wool booties
do
  local c = C.new("footwear-2-puna-wool-booties")
  local shaft = c:rrect(15, 18, 34, 42, 5)
  local foot = c:ellipse(36, 42, 14, 9):add(c:rrect(14, 33, 36, 51, 7))
  local body = shaft:copy():add(foot)
  local cuff = c:rrect(13, 10, 36, 22, 3)
  local fuzz = function(x, y, i) local h = X.hash(x, y, 7) if h < .18 then return -1 elseif h > .9 then return 1 end end
  local bi = C.lit(c, body, R.alpaca, { R = 6, hs = 0.7, cuts = { .2, .36, .52, .7, .88 } })
  C.retone(c, body, bi, R.alpaca, fuzz)
  -- felt sole rim
  C.edgeLo(c, body, R.alpaca[1])
  body:each(function(x, y) if not body:has(x, y + 2) and body:has(x, y + 1) then c:put(x, y, R.alpaca[2]) end end)
  -- blanket stitch around the foot (indigo)
  for x = 18, 47, 3 do
    local y = 45
    while not body:has(x, y + 3) and y > 30 do y = y - 1 end
    if body:has(x, y) then c:put(x, y, R.indigo[3]) c:put(x, y - 1, R.indigo[4]) end
  end
  -- contact shadow under cuff
  C.hline(c, 15, 34, 23, R.alpaca[2])
  -- knitted striped cuff: rows red / indigo / cream, vertical ribs
  local bands = function(x, y)
    local r = (y - 10) // 3
    return ({ R.yarnA, R.alpaca, R.indigo, R.alpaca, R.yarnA })[r + 1] or R.yarnA
  end
  local ci = C.litm(c, cuff, bands, { R = 3, cuts = { .2, .36, .52, .7, .88 } })
  cuff:each(function(x, y) if (x % 2 == 0) then local i = ci[K(x, y)] c:put(x, y, bands(x, y)[math.max(1, i - 1)]) end end)
  C.hline(c, 14, 35, 10, R.alpaca[6])
  -- tie cord from the cuff front with two red pom-poms (quirk)
  local cord = c:line({ {36,15}, {39,18}, {41,24} }, 1):add(c:line({ {39,18}, {45,21}, {47,26} }, 1))
  cord:each(function(x, y) if not cuff:has(x, y) then c:put(x, y, R.yarnA[2]) end end)
  for _, p in ipairs({ { 41, 27, 3.2 }, { 48, 29, 3.2 } }) do
    local pm = c:ellipse(p[1], p[2], p[3], p[3])
    C.sep(c, pm, body, R.alpaca[2])
    local pi = C.lit(c, pm, R.yarnA, { R = 2 })
    C.retone(c, pm, pi, R.yarnA, function(x, y) if X.hash(x, y, 3) < .25 then return -1 end end)
    c:put(p[1] - 1, p[2] - 2, R.yarnA[6])
  end
  c:put(17, 27, R.alpaca[6]) c:put(18, 27, C.cream) c:put(17, 28, R.alpaca[6])
  C.save(c, "footwear-2-puna-wool-booties")
end

---------------------------------------------------------------- 3 plaited fibre sandals (from above)
do
  local c = C.new("footwear-3-plaited-fibre-sandals")
  local function sole(cx, top)
    return c:ellipse(cx, top + 10, 7.5, 10):add(c:ellipse(cx - 1, top + 30, 5.5, 7.5))
      :add(c:poly{ {cx-7.5,top+12}, {cx+7.5,top+12}, {cx+4.5,top+30}, {cx-6.5,top+30} })
  end
  local function sandal(cx, top, bead)
    local s = sole(cx, top)
    local side = s:shift(1, 2):cut(s)
    c:fillMask(side, R.straw[2])
    side:each(function(x, y) if not side:has(x, y + 1) or not s:shift(1, 2):has(x, y + 1) then c:put(x, y, R.straw[1]) end end)
    local si = C.lit(c, s, R.straw, { R = 3, cuts = { .2, .36, .52, .7, .88 } })
    -- plaited chevrons
    C.retone(c, s, si, R.straw, function(x, y)
      local u = (y + abs(x - cx) ) % 4
      if u == 0 then return -1 elseif u == 2 then return 1 end
    end)
    -- heel cup shadow + toe dent
    -- leather thongs: toe post -> two sides (V), and an instep cross strap
    local th = c:line({ {cx-6,top+20}, {cx-1,top+8} }, 2):add(c:line({ {cx+6,top+19}, {cx,top+8} }, 2))
    local ank = c:line({ {cx-6,top+29}, {cx-2,top+27}, {cx+2,top+27}, {cx+5,top+29} }, 2)
    local straps = th:copy():add(ank)
    C.sep(c, straps, s, R.straw[1])
    C.lit(c, straps, R.leather, { R = 1 })
    th:each(function(x, y) if not th:has(x - 1, y) then c:put(x, y, R.leather[5]) end end)
    -- toe post
    local post = c:ellipse(cx - 0.5, top + 7.5, 1.2, 1.2)
    if bead then
      local bm = c:ellipse(cx - 0.5, top + 7, 2, 2)
      C.sep(c, bm, s:copy():add(straps), R.straw[1])
      C.lit(c, bm, R.turq, { R = 1 })
      c:put(cx - 2, top + 6, R.turq[6])
    else
      C.lit(c, post, R.leather, { R = 1 })
    end
  end
  sandal(41, 9, true)
  C.sep(c, sole(22, 15):add(sole(22, 15):shift(1, 2)), sole(41, 9):shift(1, 2):add(sole(41, 9)), C.ink)
  sandal(22, 15, false)
  C.save(c, "footwear-3-plaited-fibre-sandals")
end

---------------------------------------------------------------- 4 balsa bark clogs (side view)
do
  local c = C.new("footwear-4-balsa-bark-clogs")
  local shoe = c:poly{ {7,31}, {25,29}, {29,23}, {37,20}, {46,22}, {53,29}, {57,38}, {57,46}, {54,50}, {10,50}, {6,45} }:cut(c:rect(22, 49, 37, 50))
  local wi = C.lit(c, shoe, R.balsa, { R = 5, hs = 0.8, cuts = { .2, .36, .52, .7, .88 } })
  -- carved grain following the toe curve
  C.retone(c, shoe, wi, R.balsa, function(x, y)
    if (y - floor(x * 0.18)) % 5 == 0 and X.hash(x, y, 9) < .65 then return -1 end
  end)
  -- heel opening: dark hollow
  local hole = c:ellipse(16, 30, 8.5, 2.6)
  c:fillMask(hole, R.cacao[2])
  hole:each(function(x, y) if not hole:has(x, y - 1) then c:put(x, y, R.cacao[1]) end end)
  hole:each(function(x, y) if not hole:has(x, y + 1) then c:put(x, y, R.balsa[6]) end end)
  -- separate sole block: darker band, notched heel/arch
  for x = 7, 56 do for y = 46, 50 do if shoe:has(x, y) then
    local i = wi[K(x, y)] or 3
    c:put(x, y, R.bark[math.max(1, i - 1)])
  end end end
  C.hline(c, 8, 55, 46, R.bark[5])
  C.hline(c, 23, 36, 48, R.bark[1])
  -- leaf-shaped leather vamp over the instep
  local leaf, ln, LT, LS = G.blade(28, 28, 43, 10, 56, 40, function(t) return math.max(0, 4.6 * math.sin(math.pi * math.min(1, t * 1.05)) ^ 0.8) end, { fold = 0.45 })
  C.sep(c, leaf, shoe, R.balsa[1])
  C.toneN(c, leaf, ln, R.leafG, { cuts = { .2, .36, .52, .7, .88 } })
  leaf:each(function(x, y)
    local s, t = LS[K(x, y)], LT[K(x, y)]
    if s and abs(s) < 0.16 and t < 0.92 then c:put(x, y, R.leafG[6]) end
    if s and s > 0.3 and floor(t * 30) % 4 == 0 then c:put(x, y, R.leafG[3]) end
  end)
  -- tacks holding the vamp
  c:put(30, 26, R.brass[5]) c:put(50, 42, R.brass[3])
  -- gloss
  C.hline(c, 9, 12, 35, R.balsa[6]) c:put(9, 36, C.cream) c:put(9, 37, R.balsa[6])
  -- quirk: pink bromeliad flower tucked under the vamp
  local fl = c:poly{ {40,12}, {42,18}, {38,18} }:add(c:poly{ {46,14}, {43,19}, {41,17} }):add(c:poly{ {34,15}, {39,17}, {37,19} })
    :add(c:ellipse(40, 19, 2.5, 1.6))
  C.sep(c, fl, leaf:copy():add(shoe), R.leafG[1])
  C.lit(c, fl, R.pink, { R = 1 })
  C.put(c, { {40,13}, {45,15}, {35,16} }, R.pink[6])
  c:put(40, 18, R.brass[5]) c:put(39, 19, R.brass[4])
  C.save(c, "footwear-4-balsa-bark-clogs")
end
---------------------------------------------------------------- 5 striped leg wraps
do
  local c = C.new("footwear-5-striped-leg-wraps")
  local function leg(dx, dy, b)
    local wrap = c:poly{ {14+dx,8+dy}, {26+dx,8+dy}, {27+dx,18+dy}, {26+dx,40+dy}, {15+dx,40+dy}, {13+dx,18+dy} }
    local shoe = c:rrect(13+dx, 38+dy, 28+dx, 49+dy, 4):add(c:ellipse(30+dx, 45+dy, 6, 4))
    local sole = c:rrect(12+dx, 48+dy, 37+dx, 50+dy, 1)
    return { wrap = wrap, shoe = shoe, sole = sole, all = wrap:copy():add(shoe):add(sole), dx = dx, dy = dy, b = b }
  end
  local function paint(L)
    local dx, dy, b = L.dx, L.dy, L.b
    C.lit(c, L.sole, R.sole, { R = 1 })
    C.lit(c, L.shoe, R.leather, { R = 4, bias = b })
    C.hline(c, 14+dx, 27+dx, 41+dy, R.leather[2])
    local seq = { R.yarnA, R.straw, R.indigo, R.alpaca }
    local band = function(x, y) return floor((y - dy + (x - dx) * 0.5) / 4) end
    local n = {}
    L.wrap:each(function(x, y)
      local t = math.max(-.95, math.min(.95, ((x - dx - 13) / 14) * 2 - 1))
      n[K(x, y)] = { t * 0.95, -0.15, math.sqrt(1 - t * t) }
    end)
    local wi = C.multi(c, L.wrap, n, function(x, y) return seq[band(x, y) % 4 + 1] end, { bias = b, cuts = { .2, .36, .52, .7, .88 } })
    -- each wrap's lower edge sits in shadow (overlapping bands)
    L.wrap:each(function(x, y)
      if band(x, y + 1) ~= band(x, y) then local i = wi[K(x, y)] c:put(x, y, seq[band(x, y) % 4 + 1][math.max(1, i - 2)]) end
    end)
    -- top tie cord
    C.hline(c, 13+dx, 27+dx, 10+dy, R.strap[2])
    C.hline(c, 13+dx, 27+dx, 9+dy, R.strap[4 + (b or 0)])
  end
  local back = leg(13, -5, -1)
  local front = leg(0, 0, 0)
  paint(back)
  C.sep(c, front.all, back.all, C.ink)
  paint(front)
  -- re-tone the lit streak to match the band under it: simple cream glint
  for y = 13, 36 do c:put(15, y, ({ R.yarnA, R.straw, R.indigo, R.alpaca })[floor((y + 15 * 0.5) / 4) % 4 + 1][6]) end
  c:put(16, 30, C.cream)
  c:put(30, 43, R.leather[6]) c:put(31, 43, R.leather[6])
  -- quirk: tassel hanging off the front top tie
  local tc = c:line({ {27,10}, {29,13}, {30,16} }, 1)
  tc:each(function(x, y) c:put(x, y, R.strap[2]) end)
  local ts = c:poly{ {29,16}, {32,16}, {33,23}, {28,23} }
  C.lit(c, ts, R.yarnA, { R = 1 })
  C.vline(c, 30, 18, 23, R.yarnA[2]) C.vline(c, 29, 17, 21, R.yarnA[6])
  c:put(30, 16, R.brass[5]) c:put(31, 16, R.brass[3])
  C.save(c, "footwear-5-striped-leg-wraps")
end
