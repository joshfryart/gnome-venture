-- backpack.lua: Spicepeak (CSA) backpack concepts, 5 icons 64x64. See concepts.md.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local ink, cream = C.ink, C.cream
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local CUT = { .2, .36, .52, .7, .88 }

local function chili(c, pts, w, b)
  local m, n = G.tube(pts, function(t) return w * (1 - t * 0.7) end)
  C.toneN(c, m, n, R.ember, { cuts = CUT, bias = C.bias(m, b or 0) })
  return m
end

---------------------------------------------------------------- 1 chili cone basket
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "backpack-1" }
  -- head strap arching behind
  local sm, sn = G.tube({ {12,22}, {4,-12}, {60,-12}, {52,22} }, function() return 1.7 end)
  C.toneN(c, sm, sn, R.strap, { cuts = CUT })
  local body = c:poly{ {12,18}, {52,18}, {39,57}, {25,57} }
  local bi = C.vcyl(c, body, R.bamboo, 12, 52, { cuts = CUT })
  -- diagonal lattice weave
  body:each(function(x, y)
    local i = bi[K(x, y)]
    local a, b2 = (x + y) % 5, (x - y) % 5
    if a == 0 or b2 == 0 then c:put(x, y, R.bamboo[max(1, i - 2)])
    elseif a == 1 and (y % 2 == 0) then c:put(x, y, R.bamboo[min(6, i + 1)]) end
  end)
  -- binding hoops
  for _, y in ipairs({ 32, 46 }) do
    body:each(function(x, yy) if yy == y then c:put(x, y, R.strap[4]) elseif yy == y + 1 then c:put(x, yy, R.strap[2]) end end)
  end
  -- foot ring
  local foot = c:rrect(25, 56, 39, 59, 1)
  C.part(c, foot, R.strap, { R = 1 })
  -- chilies heaped above the rim
  local pile = c:ellipse(32, 16, 18, 6)
  C.part(c, pile, R.ember, { R = 3, b = -1 })
  local cl = {
    { {16,15}, {20,11}, {25,11}, {28,13} }, { {24,10}, {28,6}, {34,7}, {38,10} }, { {33,13}, {37,9}, {42,9}, {46,12} },
    { {38,7}, {42,5}, {46,6}, {48,9} }, { {19,9}, {22,6}, {26,5}, {29,7} }, { {28,15}, {31,12}, {35,12}, {38,15} },
  }
  local done = HP.mask()
  for i, p in ipairs(cl) do
    local m = G.tube(p, function(t) return 2.3 * (1 - t * 0.7) end)
    C.inkSep(c, m, done:copy():add(pile))
    chili(c, p, 2.3, (i % 2 == 0) and 0 or -1)
    done:add(m)
  end
  -- green stems
  for _, p in ipairs(cl) do c:put(floor(p[1][1]), floor(p[1][2]), R.leaf[4]) c:put(floor(p[1][1]) - 1, floor(p[1][2]), R.leaf[3]) end
  C.put(c, { {21,10}, {29,6}, {38,8}, {43,5} }, cream)
  -- rim on top of the pile front
  local rim = c:rrect(10, 16, 54, 20, 2)
  C.part(c, rim, R.bamboo, { R = 1, b = 1 })
  for x = 12, 52, 3 do c:put(x, 18, R.bamboo[3]) c:put(x + 1, 19, R.bamboo[2]) end
  C.hline(c, 11, 53, 21, R.bamboo[1])
  -- quirk: a chili tumbling off the right of the rim
  local fc = chili(c, { {55,24}, {58,27}, {58,31}, {56,34} }, 2.2, 0)
  c:put(54, 23, R.leaf[4]) c:put(55, 22, R.leaf[5]) c:put(56, 25, R.ember[6])
  c:put(15, 24, R.bamboo[6]) c:put(16, 24, R.bamboo[6])
  C.save(c, "backpack-1-chili-cone-basket")
end

---------------------------------------------------------------- 2 ikat saddle satchel
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "backpack-2" }
  -- ikat: feathered diamonds; returns ramp for a pixel
  local function ikat(x, y, ox, oy)
    local gx, gy = (x - ox) % 14, (y - oy) % 16
    local d = abs(gx - 7) / 7 + abs(gy - 8) / 8
    local j = (X.hash(0, y, 9) - .5) * 0.28 -- per-row feathering
    d = d + j
    if d < .38 then return R.saffron elseif d < .62 then return R.madder elseif d < .7 then return R.feltc end
    return R.indigo
  end
  -- carrying strap behind
  local sm, sn = G.tube({ {14,22}, {14,4}, {50,4}, {50,22} }, function() return 2 end)
  C.toneN(c, sm, sn, R.strap, { cuts = CUT })
  sm:each(function(x, y) if (x + y) % 4 == 0 then c:put(x, y, R.strap[2]) end end)
  local body = c:rrect(11, 18, 53, 52, 5)
  local bi = C.part(c, body, R.indigo, { R = 4, cuts = CUT })
  C.swap(c, body, bi, function(x, y) return ikat(x, y, 4, 2) end)
  -- flap
  local flap = c:poly{ {11,18}, {53,18}, {53,30}, {32,38}, {11,30} }:clip(body:copy():add(c:rect(11, 18, 53, 22)))
  local fsh = flap:shift(0, 1):add(flap:shift(0, 2)):cut(flap):clip(body)
  c:fillMask(fsh, R.indigo[1])
  local fi = C.part(c, flap, R.indigo, { R = 3, b = 1, cuts = CUT })
  C.swap(c, flap, fi, function(x, y) return ikat(x, y, 11, 6) end)
  -- binding cord on the flap edge
  flap:edge():each(function(x, y) if not flap:has(x, y + 1) then c:put(x, y, R.madder[2]) end end)
  -- toggle at the point
  local tog = c:ellipse(32, 38, 2, 2)
  C.part(c, tog, R.brass, { R = 1 }) c:put(31, 37, R.brass[6])
  -- corner tassels
  for _, tx in ipairs({ 14, 50 }) do
    local cap = c:ellipse(tx, 53, 1.6, 1.6)
    local tas = c:poly{ {tx - 2, 55}, {tx + 2, 55}, {tx + 3, 61}, {tx - 3, 61} }
    C.part(c, tas, R.madder, { R = 1 })
    for x = tx - 2, tx + 2, 2 do c:put(x, 60, R.madder[2]) end
    C.part(c, cap, R.saffron, { R = 1 })
    c:put(tx - 1, 56, R.madder[5])
  end
  -- quirk: a pomegranate tucked under the flap at the right
  local pg = c:ellipse(46, 17, 5, 5)
  C.toneN(c, pg, X.sphere(45.5, 16.5, 5, pg), R.madder, {})
  C.put(c, { {45,11}, {46,10}, {47,11}, {44,10}, {48,10} }, R.madder[3])
  C.put(c, { {44,9}, {46,9}, {48,9} }, R.madder[2])
  c:put(43, 14, R.madder[6]) c:put(44, 14, cream)
  C.save(c, "backpack-2-ikat-saddle-satchel")
end

---------------------------------------------------------------- 3 porter's frame pack
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "backpack-3" }
  local grain = function(x, y) if X.hash(x, y, 4) < .25 then return -1 end end
  -- frame: two poles, two crossbars
  local p1m, p1n = X.cyl(16, 4, 13, 60, function() return 2 end)
  local p2m, p2n = X.cyl(48, 4, 51, 60, function() return 2 end)
  local poles = p1m:copy():add(p2m)
  local n = {} for k, v in pairs(p1n) do n[k] = v end for k, v in pairs(p2n) do n[k] = v end
  local pi = C.toneN(c, poles, n, R.wood, { cuts = CUT })
  local bars = c:rrect(12, 52, 52, 55, 1):add(c:rrect(13, 9, 51, 11, 1))
  C.inkSep(c, bars, poles)
  C.part(c, bars, R.wood, { R = 1, tex = grain })
  -- copper pot
  local belly = c:ellipse(32, 40, 13, 11)
  local neck = c:rrect(24, 26, 40, 31, 1)
  local lip = c:rrect(21, 24, 43, 27, 2)
  local pot = belly:copy():add(neck)
  C.inkSep(c, pot:copy():add(lip), poles:copy():add(bars))
  local pn = X.sphere(31, 39, 13, belly)
  C.toneN(c, belly, pn, R.copper, { cuts = CUT })
  -- hammered dimples
  belly:shrink(2):each(function(x, y) if (x % 4 == 0 and y % 3 == 0) then c:put(x, y, R.copper[2]) c:put(x - 1, y - 1, R.copper[5]) end end)
  C.vcyl(c, neck, R.copper, 24, 40, { cuts = CUT })
  C.hline(c, 24, 40, 31, R.copper[1])
  C.part(c, lip, R.brass, { R = 1 })
  C.hline(c, 22, 42, 24, R.brass[5])
  c:put(24, 33, R.copper[6]) c:put(25, 33, cream) c:put(23, 34, R.copper[6])
  -- rope lashing crossing the pot
  local rope = c:line({ {15,32}, {32,47}, {49,32} }, 1):add(c:line({ {14,46}, {50,46} }, 1))
  rope:each(function(x, y) c:put(x, y, ((x + y) % 2 == 0) and R.canvas[5] or R.canvas[3]) end)
  -- rolled striped rug on the top bar
  local rm, rn = X.cyl(11, 15, 53, 15, function() return 5.5 end)
  C.inkSep(c, rm, poles:copy():add(bars):add(lip))
  local ri = C.toneN(c, rm, rn, R.madder, { cuts = CUT })
  C.swap(c, rm, ri, function(x, y) local u = (x - 11) % 8 if u < 2 then return R.feltc elseif u == 4 then return R.saffron end end)
  local en = c:ellipse(11, 15, 2.5, 5.5)
  c:fillMask(en, R.madder[3])
  C.put(c, { {11,13}, {12,14}, {12,15}, {11,17}, {10,16}, {10,14} }, R.madder[1])
  c:put(11, 15, R.madder[5])
  C.put(c, { {18,10}, {19,10}, {20,10} }, R.madder[6])
  -- quirk: wooden ladle hooked over the pot lip on the right
  local lm, ln = X.cyl(41, 22, 50, 37, function() return 1.1 end)
  C.inkSep(c, lm, pot:copy():add(lip))
  C.toneN(c, lm, ln, R.wood, { bias = C.bias(lm, 1) })
  local bowl = c:ellipse(51, 39, 3, 2.5)
  C.part(c, bowl, R.wood, { R = 1, b = 1 })
  c:put(52, 39, R.wood[2]) c:put(50, 38, R.wood[6])
  C.save(c, "backpack-3-porters-frame-pack")
end

---------------------------------------------------------------- 4 block-print bundle
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "backpack-4" }
  -- loose cloth corners hanging at the lower sides (behind)
  local k1 = c:poly{ {14,44}, {8,52}, {12,54}, {20,50} }
  local k2 = c:poly{ {50,44}, {57,51}, {54,55}, {45,50} }
  C.part(c, k1, R.indigo, { R = 1, b = -1 }) C.part(c, k2, R.indigo, { R = 1, b = -2 })
  C.put(c, { {9,52}, {10,53} }, R.madder[3]) C.put(c, { {55,53}, {54,54} }, R.madder[2])
  local body = c:ellipse(32, 41, 21, 16):add(c:poly{ {18,30}, {46,30}, {50,40}, {14,40} })
  local bi = C.part(c, body, R.indigo, { R = 7, hs = .8, cuts = { .16, .32, .48, .66, .84 } })
  -- block-print motif: 4-petal dots on a grid, plus soft fold creases
  body:shrink(1):each(function(x, y)
    local gx, gy = (x + (floor(y / 7) % 2) * 4) % 8, y % 7
    local i = bi[K(x, y)]
    if (gx == 4 and (gy == 2 or gy == 4)) or (gy == 3 and (gx == 3 or gx == 5)) then
      c:put(x, y, R.feltc[min(6, i + 0)])
    elseif gx == 4 and gy == 3 then c:put(x, y, R.madder[min(6, i + 1)]) end
  end)
  C.put(c, { {24,36}, {25,38}, {26,40}, {26,42}, {40,35}, {39,37}, {38,39} }, R.indigo[1])
  -- border band near the bottom
  body:each(function(x, y) if y == 52 or y == 53 then c:put(x, y, R.madder[(y == 52) and 4 or 2]) end end)
  -- knot ears
  local e1m, e1n = G.tube({ {28,25}, {24,20}, {20,14}, {17,10} }, function(t) return 3.6 - t * 2.4 end)
  local e2m, e2n = G.tube({ {36,25}, {40,19}, {44,15}, {48,13} }, function(t) return 3.6 - t * 2.4 end)
  C.inkSep(c, e1m:copy():add(e2m), body)
  C.toneN(c, e1m, e1n, R.indigo, { cuts = CUT })
  C.toneN(c, e2m, e2n, R.indigo, { cuts = CUT, bias = C.bias(e2m, -1) })
  C.put(c, { {18,11}, {21,15}, {24,19} }, R.feltc[5])
  C.put(c, { {45,16}, {42,18} }, R.feltc[4])
  -- quirk: cinnamon stick poking out of the knot
  local cm, cn = X.cyl(30, 26, 38, 8, function() return 1.7 end)
  C.toneN(c, cm, cn, R.copper, { cuts = CUT, bias = C.bias(cm, -1) })
  cm:each(function(x, y) if (x + 2 * y) % 5 == 0 then c:put(x, y, R.copper[1]) end end)
  local ce = c:ellipse(38, 8, 1.4, 1.2) c:fillMask(ce, R.copper[5]) c:put(38, 8, R.copper[2])
  -- knot ball
  local knot = c:ellipse(32, 26, 5, 4)
  C.inkSep(c, knot, e1m:copy():add(e2m):add(body):add(cm))
  C.part(c, knot, R.indigo, { R = 2, b = 1 })
  C.put(c, { {31,25}, {32,26}, {33,27} }, R.indigo[2]) c:put(29, 24, R.indigo[6])
  c:put(19, 33, R.indigo[6]) c:put(20, 32, R.indigo[6])
  C.save(c, "backpack-4-block-print-bundle")
end

---------------------------------------------------------------- 5 stacked tin pack
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "backpack-5" }
  -- leather shoulder straps peeking out behind
  for _, sx in ipairs({ 17, 43 }) do
    local s = c:rect(sx, 14, sx + 4, 58)
    C.vcyl(c, s, R.strap, sx, sx + 4, { bias = C.bias(s, -1) })
  end
  local tins = {}
  local x0, x1 = 15, 49
  for i, y0 in ipairs({ 21, 33, 45 }) do
    local m = c:rect(x0, y0, x1, y0 + 11):add(c:ellipse(32, y0 + 11, 17, 2.5))
    tins[i] = { m = m, y0 = y0 }
  end
  for i = 3, 1, -1 do
    local t = tins[i]
    C.vcyl(c, t.m, R.brass, x0, x1, { cuts = { .16, .32, .5, .7, .9 } })
    -- copper rim band and a seam
    for x = x0, x1 do
      c:put(x, t.y0 + 1, R.copper[4]) c:put(x, t.y0 + 2, R.copper[2])
    end
    C.vline(c, x0 + 3, t.y0 + 3, t.y0 + 10, R.brass[6])
    C.vline(c, x1 - 4, t.y0 + 3, t.y0 + 11, R.brass[2])
    -- engraved dot line
    for x = x0 + 6, x1 - 6, 3 do c:put(x, t.y0 + 7, R.brass[2]) end
    if i > 1 then C.hline(c, x0, x1, t.y0, ink) end
  end
  -- lid dome and knob
  local lid = c:ellipse(32, 21, 17, 4):clip(c:rect(0, 0, 63, 21))
  C.part(c, lid, R.copper, { R = 2 })
  C.hline(c, x0, x1, 21, R.copper[2])
  local knob = c:ellipse(32, 15, 2, 1.6)
  C.part(c, knob, R.brass, { R = 1 }) c:put(31, 14, R.brass[6])
  -- side clamp bars and the carry handle
  for _, bx in ipairs({ x0 - 2, x1 + 1 }) do
    local bar = c:rect(bx, 20, bx + 1, 57)
    c:fillMask(bar, R.steel[bx < 32 and 5 or 3]) C.vline(c, bx + 1, 20, 57, R.steel[bx < 32 and 3 or 2])
    for _, y in ipairs({ 26, 38, 50 }) do c:put(bx, y, R.steel[1]) c:put(bx + 1, y, R.steel[1]) end
  end
  local hm, hn = G.tube({ {14,20}, {14,6}, {50,6}, {50,20} }, function() return 1.2 end)
  hm = hm:cut(lid):cut(c:rect(15, 14, 49, 30))
  C.toneN(c, hm, hn, R.steel, { cuts = CUT })
  -- shine
  c:put(18, 25, cream) c:put(18, 37, R.brass[6]) c:put(18, 49, R.brass[6])
  -- quirk: a steam curl rising from the knob
  C.put(c, { {33,12}, {34,11}, {34,10}, {33,9}, {32,8}, {32,7}, {33,6}, {34,5} }, R.feltc[5])
  C.put(c, { {35,11}, {35,10}, {33,7} }, R.feltc[3])
  C.save(c, "backpack-5-stacked-tin-pack")
end
