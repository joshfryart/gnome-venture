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
  -- big triangular shawl hanging point-down from its top edge, folds radiating from the corners
  local sh = c:poly{ {6,9}, {58,9}, {55,14}, {36,50}, {31,53}, {27,49}, {9,14} }
  -- fringe along both lower edges
  local fr = HP.mask()
  sh:each(function(x, y)
    if not sh:has(x, y + 1) and y > 12 and x % 2 == 0 then
      local len = 4 + ((x % 4 == 0) and 1 or 0)
      for d = 1, len do if not sh:has(x, y + d) then fr:set(x, y + d) end end
    end
  end)
  fr:each(function(x, y) c:put(x, y, R.indigo[(sh:has(x, y - 4) or sh:has(x, y - 5)) and 2 or ((x < 32) and 5 or 4)]) end)
  local idx = C.lay(c, sh, R.indigo, { R = 4, hs = 0.6, cuts = { .2, .36, .52, .68, .86 } })
  -- drape folds: lines from the top corners towards the point
  for _, f in ipairs({ { {14,12}, {29,46} }, { {22,11}, {30,40} }, { {50,12}, {34,46} }, { {42,11}, {33,38} } }) do
    C.stroke(c, f, R.indigo[2], sh)
    C.stroke(c, { {f[1][1] - 1, f[1][2]}, {f[2][1] - 1, f[2][2]} }, R.indigo[5], sh)
  end
  -- glossy beaten-cloth sheen
  C.stroke(c, { {12,12}, {20,24} }, R.indigo[6], sh) c:put(13, 12, C.cream)
  -- rolled top hem
  C.hline(c, 7, 57, 9, R.indigo[6]) C.hline(c, 8, 56, 10, R.indigo[4]) C.hline(c, 9, 55, 11, R.indigo[2])
  -- turquoise woven border line inside the lower edges
  sh:each(function(x, y) if y > 13 and not sh:has(x, y + 3) and sh:has(x, y + 2) then c:put(x, y, R.turq[(x < 32) and 4 or 3]) end end)
  -- quirk: barred hoopoe feather tucked into the top hem
  local fe = c:line({ {46,10}, {49,6}, {53,2} }, 2)
  fe:each(function(x, y)
    local band = floor((x + y) / 2) % 2
    local col = (y >= 8) and R.ochre[5] or (band == 0 and R.goat[2] or R.linen[6])
    c:put(x, y, col)
  end)
  c:put(54, 1, R.goat[2]) C.put(c, { {45,11}, {46,11} }, R.ochre[3])
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
  local bud = c:ellipse(42, 20, 2.4, 3)
  C.sep(c, bud, m, R.madder[1])
  C.lay(c, bud, R.madder, { R = 1, bias = 1 })
  C.put(c, { {41,18}, {42,17} }, R.rose[6]) C.vline(c, 43, 19, 21, R.madder[2])
  C.put(c, { {40,23}, {41,23}, {43,23}, {44,23}, {42,24} }, R.mint[4]) C.stroke(c, { {42,25}, {44,29} }, R.mint[2])
  C.save(c, "cloak-4-rose-madder-mantle")
end

---------------------------------------------------------------- 5 goat-hair tent cape
do
  local c = C.new("cloak-5-goat-hair-tent-cape")
  local cape = c:poly{ {24,6}, {40,6}, {50,12}, {54,24}, {60,59}, {4,59}, {10,24}, {14,12} }
  local idx = C.lay(c, cape, R.goat, { R = 4, cuts = { .18, .34, .5, .66, .82 } })
  folds(c, cape, idx, R.goat, 8, 4, 18)
  -- coarse goat-hair texture
  C.retone(c, cape, idx, R.goat, function(x, y, i) if X.hash(x, y, 21) > 0.9 then return 1 elseif (x * 2 + y) % 5 == 0 and X.hash(x, y, 22) < 0.4 then return -1 end end)
  -- woven stripes: linen bands with a madder thread
  cape:each(function(x, y)
    local i = idx[K(x, y)]
    if y == 22 or y == 23 or y == 44 or y == 45 then c:put(x, y, R.linen[max(1, min(6, i))])
    elseif y == 24 or y == 46 then c:put(x, y, R.madder[max(1, min(6, i + 1))])
    elseif y >= 56 then c:put(x, y, R.linen[max(1, min(6, i - 1))]) end
  end)
  -- neck turned back (lining edge)
  local nk = c:poly{ {24,6}, {40,6}, {37,13}, {32,15}, {27,13} }
  C.lay(c, nk, R.linen, { R = 2, bias = -1 })
  C.hline(c, 25, 39, 6, R.linen[5])
  -- front opening edge
  C.stroke(c, { {32,15}, {32,59} }, R.goat[1], cape) C.stroke(c, { {31,15}, {31,59} }, R.goat[4], cape)
  -- shoulder seams
  C.stroke(c, { {15,13}, {11,24} }, R.goat[5], cape) C.stroke(c, { {49,13}, {53,24} }, R.goat[2], cape)
  -- wooden pin through the opening
  local pin = c:line({ {23,22}, {42,14} }, 2)
  C.lay(c, pin, R.wood, { R = 1 })
  local head = c:ellipse(22, 23, 2.4, 2.4)
  C.lay(c, head, R.wood, { R = 1 })
  c:put(21, 22, R.wood[6]) c:put(43, 14, R.wood[2])
  -- quirk: fluffy camel-wool pompom at the bottom corner
  local pp = c:ellipse(6, 60, 3.4, 3.4)
  for _, d in ipairs({ { -3, -2 }, { 3, -1 }, { 0, 3 }, { -3, 2 }, { 2, 3 } }) do pp:set(6 + d[1], 60 + d[2]) end
  C.lay(c, pp, R.camel, { R = 2, tex = C.wool })
  c:put(5, 58, R.camel[6]) c:put(4, 59, R.camel[6])
  C.save(c, "cloak-5-goat-hair-tent-cape")
end
