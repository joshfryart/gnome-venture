-- backpack.lua: EA Blossomreach backpack concepts 1..5 (see concepts.md).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local floor, abs = math.floor, math.abs

-- bamboo pole along a straight line with node rings every `step` px
local function pole(c, ax, ay, bx, by, w, b, step)
  local m, n, T = X.cyl(ax, ay, bx, by, function() return w end)
  local idx = C.toneN(c, m, n, R.bamboo, { bias = C.bias(m, b or 0) })
  local len = math.sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
  m:each(function(x, y) local d = T[K(x, y)] * len if step and floor(d) % step == 0 then c:put(x, y, R.bamboo[math.max(1, 2 + (b or 0))]) end end)
  return m
end

---------------------------------------------------------------- 1 bamboo A-frame with firewood
do
  local c = C.canvas("backpack-1-bamboo-aframe")
  -- shoulder straps behind (straw rope)
  -- poles and crossbars
  local pl = pole(c, 20, 4, 14, 59, 2.2, 0, 11)
  local pr = pole(c, 42, 4, 48, 59, 2.2, -1, 11)
  local bar1 = X.cyl(20, 12, 42, 12, function() return 1.4 end)
  local bar2 = X.cyl(16, 46, 46, 46, function() return 1.4 end)
  for _, bm in ipairs({ bar1, bar2 }) do
    bm:cut(pl):cut(pr)
    C.part(c, bm, R.bamboo, { R = 1, b = -1 })
  end
  -- prongs sticking out forward-left/right from mid poles
  local prL = X.cyl(16, 40, 7, 30, function(t) return 2 - t * .8 end)
  local prR = X.cyl(46, 40, 55, 30, function(t) return 2 - t * .8 end)
  prL:cut(pl) prR:cut(pr)
  C.part(c, prL, R.wood, { R = 1, b = 0 }) C.part(c, prR, R.wood, { R = 1, b = -1 })
  -- firewood bundle: three stacked logs resting on the prongs
  local logs = HP.mask()
  local lmasks = {}
  for i, ly in ipairs({ 33, 27, 21 }) do
    local x0, x1 = 8 + (i % 2), 53 - (i % 2) * 2
    local lm, ln = X.cyl(x0, ly, x1, ly, function() return 3 end)
    lmasks[i] = { lm = lm, ln = ln, x0 = x0, ly = ly }
  end
  for i = 1, 3 do
    local L = lmasks[i]
    local lb = C.bias(L.lm, 0)
    local idx = C.toneN(c, L.lm, L.ln, R.wood, { bias = lb })
    C.retone(c, L.lm, idx, R.wood, function(x, y) if (x * 3 + y * 7) % 11 == 0 then return -1 end end)
    -- end grain disc on the left
    local en = c:ellipse(L.x0, L.ly, 2, 3)
    c:fillMask(en, R.lining[5]) c:put(L.x0, L.ly, R.lining[3]) c:put(L.x0, L.ly - 1, R.lining[3])
    en:edge():each(function(x, y) if x > L.x0 then c:put(x, y, R.lining[3]) end end)
    logs:add(L.lm):add(en)
    if i < 3 then C.hline(c, L.x0 + 2, 52, L.ly - 3, R.wood[1]) end
  end
  -- rope lashings over the logs
  for _, lx in ipairs({ 19, 41 }) do
    for y = 17, 37 do if logs:has(lx, y) then c:put(lx, y, R.hemp[(y % 2 == 0) and 5 or 3]) c:put(lx + 1, y, R.hemp[2]) end end
  end
  C.hline(c, 22, 40, 13, R.bamboo[1])
  -- woven straw shoulder straps hanging in front, from the top bar down to the lower poles
  C.tube(c, { {22,14}, {25,24}, {25,40}, {18,50} }, 1.6, R.straw, { b = 0, clip = logs })
  C.tube(c, { {40,14}, {37,24}, {37,40}, {44,50} }, 1.6, R.straw, { b = -1, clip = logs })
  -- quirk: a ripe persimmon hanging by a string from the right pole tip
  C.vline(c, 44, 5, 9, R.strap[3])
  local per = c:ellipse(45, 12.5, 3.6, 3.2)
  C.part(c, per, R.autumn, { R = 2, b = 0 })
  C.put(c, { {43,9}, {44,9}, {45,9}, {46,9}, {47,9}, {45,8} }, R.moss[3])
  c:put(43, 11, R.autumn[6]) c:put(44, 11, "#fff4d6")
  C.save(c, "backpack-1-bamboo-aframe")
end

---------------------------------------------------------------- 2 forager's basket
do
  local c = C.canvas("backpack-2-forager-basket")
  local body = c:poly{ {13,17}, {51,17}, {47,55}, {17,55} }:add(c:rrect(16, 50, 48, 58, 4))
  -- contents first (behind the rim): fern fronds and a mushroom
  local fp = { {22,18}, {20,10}, {16,5}, {11,4} }
  local fern1 = G.tube(fp, function() return 0.8 end)
  for i = 1, 9 do local t = i / 10 local x, y = G.bez(fp, t) x, y = floor(x), floor(y)
    local L = math.max(1, floor(4 - t * 3))
    for j = 1, L do fern1:set(x - j, y - j + 1) fern1:set(x + j, y - j + 1 + (t > .5 and 1 or 0)) end
  end
  C.part(c, fern1, R.moss, { R = 1, b = 0 })
  local mush = c:ellipse(40, 12, 6, 3.6)
  local stem = c:rect(38, 13, 41, 18)
  C.part(c, stem, R.fleece, { R = 1, b = 0 })
  C.part(c, mush, R.felt, { R = 3, b = 1 })
  c:put(37, 10, R.lining[6]) c:put(42, 10, R.lining[6]) c:put(39, 9, R.lining[5])
  C.hline(c, 35, 45, 15, R.felt[1])
  -- basket body, open hex weave
  local bi = C.vcyl(c, body, R.rattan, 12, 52, { cuts = { .22, .38, .54, .7, .88 } })
  C.retone(c, body, bi, R.rattan, function(x, y)
    local u, v = (x + y) % 6, (x - y) % 6
    if u == 0 or v == 0 then return -2 end
    if u == 1 or v == 1 then return 1 end
  end)
  -- horizontal binding bands
  for _, by in ipairs({ 32, 46 }) do
    for x = 10, 54 do if body:has(x, by) then c:put(x, by, R.rattan[(x < 30) and 5 or 4]) if body:has(x, by + 1) then c:put(x, by + 1, R.rattan[2]) end end end
  end
  -- thick rim and the dark opening
  local open = c:ellipse(32, 17, 18, 3)
  c:fillMask(open:copy():cut(fern1):cut(mush):cut(stem), R.rattan[1])
  local rim = X.cyl(12, 19, 52, 19, function() return 2 end)
  C.part(c, rim, R.rattan, { R = 1, b = 1 })
  for x = 12, 52, 3 do c:put(x, 18, R.rattan[3]) end
  -- rope shoulder loop at the side
  C.tube(c, { {13,22}, {7,27}, {8,40}, {16,46} }, 1.2, R.hemp, { b = 0 })
  -- quirk: a curled fiddlehead fern above the rim
  local fh = G.tube({ {30,18}, {30,12}, {31,9}, {33,8} }, function() return .9 end)
  C.part(c, fh, R.frog, { R = 1, b = 0 })
  C.put(c, { {33,7}, {34,6}, {35,6}, {36,7}, {36,8}, {35,9}, {34,9} }, R.frog[4])
  c:put(34, 7, R.frog[6]) c:put(35, 8, R.frog[1]) c:put(34, 6, R.frog[6])
  C.save(c, "backpack-2-forager-basket")
end

---------------------------------------------------------------- 3 knotted cloth bundle
do
  local c = C.canvas("backpack-3-cloth-bundle")
  -- knot ears behind the bundle top
  local earL = c:poly{ {26,18}, {14,4}, {19,4}, {30,16} }
  local earR = c:poly{ {34,16}, {47,6}, {50,10}, {38,19} }
  local bundle = c:rrect(9, 16, 55, 56, 12)
  local knot = c:ellipse(32, 18, 6, 4.5)
  C.part(c, earL, R.plum, { R = 2, b = 1 })
  C.part(c, earR, R.plum, { R = 2, b = 0 })
  C.sep(c, bundle, earL:copy():add(earR), R.plum[1])
  local bi = C.part(c, bundle, R.plum, { R = 9, cuts = { .22, .38, .54, .72, .9 } })
  -- folds radiating from the knot
  for _, f in ipairs({ { {28,22}, {20,32}, {14,44} }, { {36,22}, {44,34}, {49,46} }, { {32,23}, {31,36}, {30,50} } }) do
    local fm = c:line(f, 1)
    fm:clip(bundle):each(function(x, y) c:put(x, y, R.plum[2]) c:put(x - 1, y, R.plum[5]) end)
  end
  -- shibori dots: pale rings in a grid
  for gy = 26, 52, 8 do for gx = 13 + ((gy // 8) % 2) * 4, 52, 8 do
    if bundle:shrink(2):has(gx, gy) then
      local d = (gx < 30 and gy < 40) and 6 or 5
      C.put(c, { {gx, gy - 1}, {gx - 1, gy}, {gx + 1, gy}, {gx, gy + 1} }, R.petal[d])
      c:put(gx, gy, R.plum[3])
    end
  end end
  -- knot
  C.sep(c, knot, bundle, R.plum[1])
  C.part(c, knot, R.plum, { R = 3, b = 1 })
  C.put(c, { {30,17}, {31,16}, {33,17}, {34,18} }, R.plum[2])
  -- carrying cords from the knot down the sides
  C.tube(c, { {27,20}, {14,24}, {7,36}, {10,48} }, 1, R.strap, { b = 0 })
  -- quirk: a sprig of plum blossom pushed through the knot
  local twig = c:line({ {36,20}, {41,11}, {45,6} }, 1)
  twig:each(function(x, y) c:put(x, y, R.wood[2]) end)
  c:put(43, 9, R.wood[2]) c:put(47, 9, R.wood[2])
  for _, p in ipairs({ { 45, 5 }, { 40, 12 }, { 48, 10 } }) do
    local fl = c:ellipse(p[1], p[2], 1.6, 1.6)
    c:fillMask(fl, R.petal[5])
    c:put(p[1], p[2], R.brass[5]) c:put(p[1] - 1, p[2] - 1, R.petal[6]) c:put(p[1] + 1, p[2] + 1, R.petal[3])
  end
  C.save(c, "backpack-3-cloth-bundle")
end

---------------------------------------------------------------- 4 lacquer tea chest
do
  local c = C.canvas("backpack-4-tea-chest")
  local box = c:rect(16, 12, 46, 56)
  local side = c:poly{ {46,12}, {52,8}, {52,52}, {46,56} }
  local lid = c:poly{ {14,9}, {48,9}, {54,5}, {20,5} }:add(c:rect(14, 9, 48, 12))
  C.part(c, side, R.lacq, { R = 1, b = -2 })
  C.part(c, box, R.lacq, { R = 2, b = -1, cuts = { .2, .36, .54, .72, .9 } })
  C.part(c, lid, R.lacq, { R = 1, b = 0 })
  C.hline(c, 15, 47, 9, R.lacq[6]) C.hline(c, 15, 47, 12, R.lacq[1])
  C.vline(c, 47, 13, 55, R.lacq[1])
  -- three drawers
  for i, y0 in ipairs({ 15, 29, 43 }) do
    local dr = c:rect(19, y0, 43, y0 + 11)
    local di = C.part(c, dr, R.lacq, { R = 1, b = 0 })
    C.hline(c, 19, 43, y0, R.lacq[5]) C.vline(c, 19, y0, y0 + 11, R.lacq[5])
    C.hline(c, 19, 43, y0 + 11, R.lacq[1]) C.vline(c, 43, y0, y0 + 11, R.lacq[1])
    -- brass ring pull
    local ring = c:ellipse(31, y0 + 6, 2.2, 2):cut(c:ellipse(31, y0 + 6, .6, .5))
    c:fillMask(ring, R.brass[4]) c:put(30, y0 + 4, R.brass[6]) c:put(32, y0 + 8, R.brass[2])
    c:put(31, y0 + 6, R.lacq[2])
    c:fillMask(c:rect(30, y0 + 2, 32, y0 + 3), R.brass[3])
  end
  -- brass corner plates
  for _, p in ipairs({ { 16, 12, 1, 1 }, { 46, 12, -1, 1 }, { 16, 56, 1, -1 }, { 46, 56, -1, -1 } }) do
    local x, y, sx, sy = p[1], p[2], p[3], p[4]
    C.put(c, { {x, y}, {x + sx, y}, {x + 2 * sx, y}, {x, y + sy}, {x, y + 2 * sy}, {x + sx, y + sy} }, R.brass[(sx > 0 and sy > 0) and 5 or 3])
  end
  C.put(c, { {14,9}, {15,9}, {14,10} }, R.brass[5]) C.put(c, { {48,9}, {47,9}, {48,10} }, R.brass[3])
  -- shoulder strap edges visible at the side
  C.vline(c, 50, 10, 50, R.strap[3]) C.vline(c, 51, 10, 50, R.strap[2])
  -- quirk: a small water gourd swinging from the side on a cord
  C.tube(c, { {52,20}, {55,22}, {56,26}, {56,29} }, .7, R.strap, { b = 0 })
  local g1 = c:ellipse(56, 31, 2.2, 2.2)
  local g2 = c:ellipse(56, 37.5, 4, 4.2)
  C.sep(c, g1, g2, R.hemp[1])
  C.part(c, g2, R.straw, { R = 3, b = 0 })
  C.part(c, g1, R.straw, { R = 2, b = 1 })
  C.hline(c, 54, 58, 33, R.ember[3])
  c:put(54, 36, R.straw[6]) c:put(55, 29, R.straw[6])
  C.save(c, "backpack-4-tea-chest")
end

---------------------------------------------------------------- 5 quilted silk satchel with lantern
do
  local c = C.canvas("backpack-5-quilted-satchel")
  local loop = G.tube({ {22,16}, {22,6}, {40,6}, {40,16} }, function() return 1.6 end)
  local body = c:rrect(10, 14, 52, 54, 8)
  C.part(c, loop, R.strap, { R = 1, b = 0 })
  C.sep(c, body, loop, R.strap[1])
  local bi = C.part(c, body, R.jade, { R = 6, cuts = { .22, .38, .54, .72, .9 } })
  -- diamond quilting: stitched grooves with puffed cells
  C.retone(c, body, bi, R.jade, function(x, y)
    local u, v = (x + y) % 8, (x - y) % 8
    if u == 0 or v == 0 then return -1 end
    if (u == 1 or v == 1) then return 1 end
  end)
  -- rounded flap with silk-trim edge
  local flap = c:rrect(12, 15, 50, 30, 6):add(c:ellipse(31, 30, 15, 7))
  flap:clip(body)
  C.shadowUnder(c, flap, body, R.jade[1], 0, 1)
  local fi = C.part(c, flap, R.jade, { R = 4, b = 1 })
  C.retone(c, flap, fi, R.jade, function(x, y) local u, v = (x + y) % 8, (x - y) % 8 if u == 0 or v == 0 then return -1 end end)
  flap:edge():each(function(x, y) if y > 18 then c:put(x, y, (x < 31) and R.lining[5] or R.lining[3]) end end)
  -- wooden toggle on a loop
  C.put(c, { {30,36}, {31,36}, {32,36}, {30,38}, {32,38} }, R.lining[3])
  local tog = c:rrect(27, 37, 35, 39, 1)
  C.part(c, tog, R.wood, { R = 1, b = 0 }) C.hline(c, 28, 34, 37, R.wood[6])
  -- quirk: a little paper lantern hanging from the strap loop, with a firefly glow inside
  local lx, ly = 57, 26
  local str = c:line({ {41,8}, {50,12}, {lx,ly - 6} }, 1)
  str:cut(body):cut(loop):each(function(x, y) c:put(x, y, R.strap[2]) end)
  local lan = c:ellipse(lx, ly, 4.2, 5)
  local cap1, cap2 = c:rect(lx - 2, ly - 6, lx + 2, ly - 5), c:rect(lx - 2, ly + 5, lx + 2, ly + 6)
  C.sep(c, lan, body, C.ink)
  local li = C.part(c, lan, R.autumn, { R = 3, b = 2, cuts = { .1, .25, .45, .65, .85 } })
  for _, ry in ipairs({ ly - 3, ly, ly + 3 }) do for x = lx - 4, lx + 4 do if lan:has(x, ry) then c:put(x, ry, R.autumn[(x < lx) and 3 or 2]) end end end
  c:fillMask(cap1, R.lacq[2]) c:fillMask(cap2, R.lacq[2]) c:put(lx - 2, ly - 6, R.lacq[4])
  c:put(lx - 1, ly - 1, "#fff4d6") c:put(lx, ly, R.brass[6]) c:put(lx - 1, ly + 1, R.brass[5])
  C.vline(c, lx, ly + 7, ly + 9, R.ember[3])
  C.save(c, "backpack-5-quilted-satchel")
end
