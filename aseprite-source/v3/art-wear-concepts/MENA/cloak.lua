-- cloak.lua: MENA "Dunewhisper" cloak concepts, 5 icons (see concepts.md).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local floor, sqrt, abs, min, max, sin, pi = math.floor, math.sqrt, math.abs, math.min, math.max, math.sin, math.pi

-- vertical folds: re-tone by a sine across x so the drape has ridges (lit on the left of each ridge)
local function folds(c, m, idx, ramp, period, phase, y0)
  C.retone(c, m, idx, ramp, function(x, y, i)
    if y0 and y < y0 then return 0 end
    local s = sin((x + (phase or 0)) / period * 2 * pi)
    if s < -0.75 then return -1 elseif s > 0.8 then return 1 end
  end)
end

---------------------------------------------------------------- 1 camel-wool hooded cape
do
  local c = C.new("cloak-1-camel-wool-hooded-cape")
  local body = c:poly{ {22,20}, {42,20}, {50,40}, {55,58}, {9,58}, {14,40} }
  local hood = c:poly{ {20,24}, {21,14}, {26,7}, {33,3}, {39,4}, {43,10}, {44,18}, {44,25} }
  local tip = c:line({ {38,4}, {44,3}, {48,5}, {50,9} }, 3)
  C.sep(c, hood, body, R.linen[1])
  local bi = C.lay(c, body, R.linen, { R = 5, hs = 0.6, tex = C.wool, cuts = { .2, .36, .52, .7, .88 } })
  folds(c, body, bi, R.linen, 7, 2, 30)
  -- camel trim: hem and front opening
  body:each(function(x, y)
    if y >= 55 then c:put(x, y, R.camel[(y == 55) and 5 or 3]) end
  end)
  C.stroke(c, { {32,26}, {32,58} }, R.camel[3], body) C.stroke(c, { {31,26}, {31,58} }, R.camel[5], body)
  -- hood
  local hb = C.bmap(hood, 0)
  local hi = C.lay(c, hood, R.linen, { R = 4, bmap = hb, tex = C.wool })
  C.lay(c, tip:copy():cut(hood), R.linen, { R = 1, tex = C.wool })
  -- face opening: deep shadow ringed with camel trim
  local open = c:ellipse(32, 17, 7.5, 7)
  local inner = c:ellipse(32.5, 18, 5.5, 5.5)
  open:each(function(x, y) c:put(x, y, R.camel[(x < 32) and 4 or 3]) end)
  c:fillMask(inner, R.camel[1])
  inner:each(function(x, y) if x < 30 and y < 18 and inner:has(x + 2, y + 2) then c:put(x, y, R.camel[2]) end end)
  C.put(c, { {27,12}, {28,11}, {29,10} }, R.camel[6])
  -- shoulder line under the hood
  C.hline(c, 18, 46, 26, R.linen[2])
  -- quirk: long wool tassel from the hood tip
  C.stroke(c, { {50,10}, {51,14} }, R.camel[3])
  local t = c:poly{ {49.5,15}, {53,15}, {54,22}, {48.5,22} }
  C.lay(c, t, R.camel, { R = 1 })
  C.vline(c, 51, 16, 21, R.camel[2]) c:put(50, 15, R.camel[6])
  C.hline(c, 50, 52, 15, R.madder[4])
  C.save(c, "cloak-1-camel-wool-hooded-cape")
end

---------------------------------------------------------------- 2 indigo shawl
do
  local c = C.new("cloak-2-indigo-shawl")
  -- folded over at the top, two long tails hanging and splaying a little
  local tailR = c:poly{ {33,10}, {44,8}, {50,52}, {37,54} }
  local tailL = c:poly{ {19,8}, {32,10}, {29,54}, {13,52} }
  local fold = c:rrect(17, 4, 46, 13, 4)
  local ri = C.lay(c, tailR, R.indigo, { R = 3, bias = -1 })
  folds(c, tailR, ri, R.indigo, 5, 1)
  C.sep(c, tailL, tailR, R.indigo[1])
  local li = C.lay(c, tailL, R.indigo, { R = 3 })
  folds(c, tailL, li, R.indigo, 5, 3)
  -- glossy beaten-cloth sheen streaks
  for _, s in ipairs({ { {22,16}, {18,40} }, { {24,18}, {22,30} }, { {38,16}, {41,36} } }) do
    C.stroke(c, s[1] and s or s, R.indigo[6], tailL:copy():add(tailR))
  end
  C.stroke(c, { {39,16}, {42,36} }, R.indigo[5], tailR)
  -- fringe
  local function fringe(x0, x1, ytop, slope)
    for x = x0, x1 do
      if x % 2 == 0 then
        local y = floor(ytop + (x - x0) * slope + .5)
        local len = 4 + (x % 4 == 0 and 1 or 0)
        for d = 1, len do c:put(x, y + d, R.indigo[(d == len) and 3 or ((x < 32) and 5 or 4)]) end
      end
    end
  end
  fringe(14, 28, 52, 0.12) fringe(37, 49, 54, -0.12)
  -- fold at the top (over the peg)
  C.sep(c, fold, tailL:copy():add(tailR), R.indigo[1])
  local fi = C.lay(c, fold, R.indigo, { R = 4, cuts = { .2, .36, .52, .68, .84 } })
  C.hline(c, 21, 41, 5, R.indigo[6])
  c:put(22, 6, C.cream) c:put(23, 6, R.indigo[6])
  C.stroke(c, { {32,7}, {32,12} }, R.indigo[2], fold)
  -- woven border stripe across the tails
  for _, m in ipairs({ tailL, tailR }) do
    m:each(function(x, y) if y == 46 or y == 48 then c:put(x, y, R.turq[(x < 32) and 4 or 3]) end end)
  end
  -- quirk: barred hoopoe feather tucked into the fold
  local fe = c:line({ {44,9}, {47,5}, {51,2} }, 2)
  fe:each(function(x, y)
    local band = floor((x + y) / 2) % 2
    local col = (x <= 45) and R.ochre[5] or (band == 0 and R.goat[2] or R.linen[6])
    c:put(x, y, col)
  end)
  C.put(c, { {43,10}, {42,11} }, R.ochre[3])
  C.save(c, "cloak-2-indigo-shawl")
end

---------------------------------------------------------------- 3 palm-leaf sun cape
do
  local c = C.new("cloak-3-palm-leaf-sun-cape")
  local tiers = {
    { y0 = 10, y1 = 24, w0 = 11, w1 = 15 },
    { y0 = 20, y1 = 36, w0 = 14, w1 = 19 },
    { y0 = 32, y1 = 48, w0 = 18, w1 = 23 },
    { y0 = 44, y1 = 59, w0 = 22, w1 = 26 },
  }
  for ti = #tiers, 1, -1 do
    local T = tiers[ti]
    local m = HP.mask()
    for y = T.y0, T.y1 do
      local w = T.w0 + (T.w1 - T.w0) * (y - T.y0) / (T.y1 - T.y0)
      for x = floor(32 - w), floor(32 + w) do
        -- jagged leaf tips along the bottom edge
        local tipd = (x % 3 == 0) and 0 or ((x % 3 == 1) and 1 or 2)
        if y <= T.y1 - tipd then m:set(x, y) end
      end
    end
    local bias = (ti % 2 == 0) and -1 or 0
    local idx = C.lay(c, m, R.palm, { R = 4, hs = 0.5, bias = bias })
    C.retone(c, m, idx, R.palm, function(x, y, i)
      if x % 3 == 2 then return -1 elseif x % 3 == 0 and y > T.y0 + 2 and X.hash(x, y, ti) < 0.5 then return 1 end
    end)
    -- shadow under the tier above
    if ti < #tiers then end
    m:each(function(x, y) if y <= T.y0 + 1 and ti > 1 then c:put(x, y, R.palm[1]) end end)
  end
  -- binding cord at the collar
  local collar = c:rrect(20, 7, 44, 11, 2)
  C.lay(c, collar, R.linen, { R = 1 })
  for x = 21, 43, 3 do c:put(x, 9, R.linen[2]) end
  C.hline(c, 22, 42, 7, R.linen[6])
  -- tie strings
  C.stroke(c, { {27,11}, {26,17} }, R.linen[4]) C.stroke(c, { {37,11}, {38,17} }, R.linen[3])
  -- quirk: fresh green frond tip sprouting at the collar
  for _, L in ipairs({ { 22, 8, 15, 2 }, { 23, 8, 19, 1 }, { 21, 9, 13, 6 } }) do
    local m, n = G.oval((L[1] + L[3]) / 2, (L[2] + L[4]) / 2, 4.6, 1.3, math.atan(L[4] - L[2], L[3] - L[1]))
    C.G.toneN(c, m, n, R.mint)
  end
  c:put(17, 4, R.mint[6]) c:put(19, 3, R.mint[6])
  C.save(c, "cloak-3-palm-leaf-sun-cape")
end

---------------------------------------------------------------- 4 rose-madder mantle
do
  local c = C.new("cloak-4-rose-madder-mantle")
  local cx, cy = 32, 6
  local m = HP.mask()
  for y = 12, 50 do for x = 2, 61 do
    local dx, dy = (x - cx) / 28, (y - cy) / 40
    local scal = 1.5 * abs(sin((x - cx) / 3.2 * pi / 2))
    if dx * dx + dy * dy <= 1 and y <= 44 + scal then m:set(x, y) end
  end end
  m:cut(c:ellipse(32, 10, 7, 5))
  -- fringe under the scalloped edge
  m:each(function(x, y) if not m:has(x, y + 1) and x % 2 == 0 and y > 30 then
    for d = 1, 3 do c:put(x, y + d, R.madder[(d == 3) and 2 or ((x < 32) and 4 or 3)]) end
  end end)
  local idx = C.lay(c, m, R.rose, { R = 5, hs = 0.6, cuts = { .2, .36, .52, .7, .88 } })
  folds(c, m, idx, R.rose, 9, 0, 22)
  -- madder scallop border band
  m:each(function(x, y)
    local inner = m:has(x, y + 3) and m:has(x, y + 2)
    if not inner then c:put(x, y, R.madder[min(6, (idx[K(x, y)] or 3))]) end
    if not m:has(x, y + 3) and m:has(x, y + 2) and x % 2 == 0 then c:put(x, y, R.ochre[4]) end
  end)
  -- collar band
  local col = c:ellipse(32, 10, 9, 6.5):cut(c:ellipse(32, 10, 7, 5)):clip(c:rect(0, 10, 63, 20))
  C.lay(c, col, R.madder, { R = 1 })
  col:each(function(x, y) if not col:has(x, y - 1) then c:put(x, y, R.madder[5]) end end)
  -- brass clasp: two discs and a chain
  for _, d in ipairs({ { 28, 17 }, { 37, 17 } }) do
    local dm = c:ellipse(d[1], d[2], 2.2, 2.2)
    C.lay(c, dm, R.brass, { R = 1 })
    c:put(d[1] - 1, d[2] - 1, R.brass[6])
  end
  C.hline(c, 31, 34, 18, R.brass[3]) c:put(32, 18, R.brass[5])
  -- quirk: dried rosebud tucked beside the clasp
  local bud = c:ellipse(41, 20, 1.8, 2.4)
  C.lay(c, bud, R.rose, { R = 1, bias = -1 })
  C.put(c, { {40,19}, {41,18} }, R.rose[5])
  C.put(c, { {40,22}, {42,22}, {41,23} }, R.mint[3]) C.stroke(c, { {41,24}, {43,27} }, R.mint[2])
  C.save(c, "cloak-4-rose-madder-mantle")
end

---------------------------------------------------------------- 5 goat-hair tent cape
do
  local c = C.new("cloak-5-goat-hair-tent-cape")
  local cape = c:poly{ {22,8}, {42,8}, {55,16}, {56,57}, {8,57}, {9,16} }
  local idx = C.lay(c, cape, R.goat, { R = 4, cuts = { .18, .34, .5, .66, .82 } })
  folds(c, cape, idx, R.goat, 8, 4, 18)
  -- coarse goat-hair texture
  C.retone(c, cape, idx, R.goat, function(x, y, i) if X.hash(x, y, 21) > 0.9 then return 1 elseif (x * 2 + y) % 5 == 0 and X.hash(x, y, 22) < 0.4 then return -1 end end)
  -- woven stripes: linen bands with a madder thread
  cape:each(function(x, y)
    local i = idx[K(x, y)]
    if y == 22 or y == 23 or y == 44 or y == 45 then c:put(x, y, R.linen[max(1, min(6, i))])
    elseif y == 24 or y == 46 then c:put(x, y, R.madder[max(1, min(6, i + 1))])
    elseif y >= 54 then c:put(x, y, R.linen[max(1, min(6, i - 1))]) end
  end)
  -- neck turned back (lining edge)
  local nk = c:poly{ {22,8}, {42,8}, {38,14}, {32,16}, {26,14} }
  C.lay(c, nk, R.linen, { R = 2, bias = -1 })
  C.hline(c, 23, 41, 8, R.linen[5])
  -- front opening edge
  C.stroke(c, { {32,16}, {32,57} }, R.goat[1], cape) C.stroke(c, { {31,16}, {31,57} }, R.goat[4], cape)
  -- shoulder seams
  C.stroke(c, { {22,9}, {10,16} }, R.goat[5]) C.stroke(c, { {42,9}, {54,16} }, R.goat[2])
  -- wooden pin through the opening
  local pin = c:line({ {24,24}, {40,17} }, 2)
  C.lay(c, pin, R.wood, { R = 1 })
  local head = c:ellipse(23, 25, 2, 2)
  C.lay(c, head, R.wood, { R = 1 })
  c:put(22, 24, R.wood[6]) c:put(41, 17, R.wood[2])
  -- quirk: fluffy camel-wool pompom at the bottom corner
  local pp = c:ellipse(10, 58, 3.4, 3.4)
  for _, d in ipairs({ { -3, -2 }, { 3, -1 }, { 0, 3 }, { -3, 2 }, { 2, 3 } }) do pp:set(10 + d[1], 58 + d[2]) end
  C.lay(c, pp, R.camel, { R = 2, tex = C.wool })
  c:put(9, 56, R.camel[6]) c:put(8, 57, R.camel[6])
  C.save(c, "cloak-5-goat-hair-tent-cape")
end
