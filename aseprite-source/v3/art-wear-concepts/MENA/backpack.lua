-- backpack.lua: MENA "Dunewhisper" backpack concepts, 5 icons (see concepts.md).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local floor, sqrt, abs, min, max = math.floor, math.sqrt, math.abs, math.min, math.max

---------------------------------------------------------------- 1 goatskin waterskin
do
  local c = C.new("backpack-1-goatskin-waterskin")
  -- harness straps peeking out behind the skin
  local handle = c:line({ {14,30}, {16,20}, {24,15}, {34,16}, {42,22} }, 3)
  local body, bn = G.oval(30, 38, 22, 16, -0.1)
  local neck, nidx = C.tube(c, { {44,30}, {47,24}, {49,20}, {50,16} }, function(t) return 4.5 - t * 1.5 end, R.leather, { bias = -1 })
  local hm = handle:copy():cut(body):cut(neck)
  C.lay(c, hm, R.strap, { R = 1 })
  hm:each(function(x, y) if not hm:has(x, y - 1) then c:put(x, y, R.strap[5]) end end)
  C.sep(c, body, neck, R.leather[1])
  -- skin: plump, lit, a few wrinkles
  local skin = C.G.toneN(c, body, bn, R.leather, { cuts = { .2, .36, .52, .7, .88 } })
  C.speckle(c, body, skin, R.leather, 0.04, 7)
  for _, w in ipairs({ { {38,26}, {42,29} }, { {36,28}, {40,30} }, { {12,40}, {14,44} } }) do C.stroke(c, w, R.leather[2], body) end
  -- seam along the belly with stitches
  local seam = {}
  for x = 13, 49 do local y = floor(46 - (x - 31)^2 / 70 + .5) if body:has(x, y) then seam[#seam + 1] = { x, y } end end
  for i, p in ipairs(seam) do c:put(p[1], p[2], R.leather[2]) if i % 3 == 0 then c:put(p[1], p[2] - 1, R.lining[6]) end end
  -- cord ties at the leg stump and neck
  C.stroke(c, { {45,22}, {50,24} }, R.linen[5]) C.stroke(c, { {45,23}, {50,25} }, R.linen[3])
  -- harness straps crossing the front with brass rings
  for _, sx in ipairs({ 22, 40 }) do
    local m = HP.mask()
    for y = 23, 52 do for d = 0, 2 do local x = sx + d + floor((y - 23) * (sx < 30 and -0.05 or 0.05)) if body:has(x, y) then m:set(x, y) end end end
    C.lay(c, m, R.strap, { R = 1 })
  end
  for _, r in ipairs({ {23,38}, {41,38} }) do
    local ring = c:ellipse(r[1], r[2], 2, 2):cut(c:ellipse(r[1], r[2], 0.6, 0.6))
    ring:each(function(x, y) c:put(x, y, R.brass[(x + y < r[1] + r[2]) and 5 or 3]) end)
  end
  -- wooden spout plug
  local plug = c:rrect(47, 10, 53, 16, 1)
  C.sep(c, plug, neck, R.wood[1])
  C.lay(c, plug, R.wood, { R = 1 })
  C.hline(c, 48, 52, 10, R.wood[6]) C.hline(c, 47, 53, 13, R.wood[2])
  -- shine
  c:put(18, 32, R.leather[6]) c:put(19, 31, R.leather[6]) c:put(20, 31, C.cream) c:put(17, 34, R.leather[5])
  -- quirk: one water drop at the spout
  local drop = c:poly{ {56.5,16}, {58.5,20}, {57.5,22}, {55,22}, {54.5,20} }
  C.lay(c, drop, R.water, { R = 1 })
  c:put(55, 20, C.cream)
  C.save(c, "backpack-1-goatskin-waterskin")
end

---------------------------------------------------------------- 2 date-palm basket
do
  local c = C.new("backpack-2-date-palm-basket")
  local basket = c:poly{ {13,16}, {51,16}, {44,57}, {20,57} }:add(c:rrect(19, 53, 45, 58, 2))
  local rim = c:rrect(11, 12, 53, 18, 3)
  -- rope shoulder loops behind, at the sides
  local loopL = c:line({ {14,18}, {9,26}, {10,36}, {16,42} }, 2)
  local loopR = c:line({ {50,18}, {55,26}, {54,36}, {48,42} }, 2)
  local loops = loopL:copy():add(loopR):cut(basket)
  loops:each(function(x, y) c:put(x, y, R.linen[(x < 32) and 5 or 3]) end)
  -- dates heaped over the rim (behind the front lip)
  local heap = HP.mask()
  local dates = { {20,10}, {25,8}, {30,9}, {35,7}, {40,9}, {45,10}, {23,13}, {28,12}, {33,11}, {38,12}, {43,13}, {31,5} }
  for i, d in ipairs(dates) do
    local m = G.oval(d[1], d[2], 3, 2, (i % 3 - 1) * 0.5)
    heap:add(m)
  end
  for i, d in ipairs(dates) do
    local m, n = G.oval(d[1], d[2], 3, 2, (i % 3 - 1) * 0.5)
    m:grow(1):cut(m):each(function(x, y) if heap:has(x, y) then c:put(x, y, R.date[1]) end end)
    C.G.toneN(c, m, n, R.date, { cuts = { .2, .36, .52, .7, .86 } })
    c:put(d[1] - 1, d[2] - 1, R.date[6])
  end
  -- palm stalk strand
  C.stroke(c, { {36,6}, {40,3}, {46,2} }, R.ochre[5])
  C.stroke(c, { {33,7}, {36,6} }, R.ochre[4])
  -- basket body: herringbone plait
  local herr = function(x, y, i)
    local row = floor(y / 4)
    local u = (row % 2 == 0) and (x + y) or (x - y)
    if u % 4 == 0 then return -1 elseif u % 4 == 2 and (x % 2 == 0) then return 1 end
  end
  local bi = C.lay(c, basket, R.palm, { R = 6, hs = 0.5, tex = herr, cuts = { .22, .4, .56, .72, .88 } })
  -- dyed bands woven in
  for _, band in ipairs({ { 27, 29, R.madder }, { 41, 42, R.indigo } }) do
    basket:each(function(x, y) if y >= band[1] and y <= band[2] then
      local i = bi[K(x, y)] or 3
      c:put(x, y, band[3][max(1, min(6, i + (((x + y) % 3 == 0) and -1 or 0)))])
    end end)
  end
  for y = 20, 56, 4 do basket:each(function(x, yy) if yy == y then c:put(x, yy, R.palm[max(1, (bi[K(x, yy)] or 3) - 1)]) end end) end
  -- rolled rim
  C.sep(c, rim, basket, R.palm[1])
  local ri = C.lay(c, rim, R.palm, { R = 3 })
  C.retone(c, rim, ri, R.palm, function(x, y, i) if (x - y) % 3 == 0 then return -1 end end)
  -- quirk-plus: one date fallen onto the rim front
  local fd, fn = G.oval(46, 15, 2.6, 1.8, 0.6)
  C.sep(c, fd, rim, R.palm[1])
  C.G.toneN(c, fd, fn, R.date) c:put(45, 14, R.date[6])
  C.save(c, "backpack-2-date-palm-basket")
end

---------------------------------------------------------------- 3 kilim saddle-bag
do
  local c = C.new("backpack-3-kilim-saddle-bag")
  -- shoulder strap loops at the top
  local st = c:line({ {18,16}, {18,9}, {22,6}, {42,6}, {46,9}, {46,16} }, 3)
  C.lay(c, st, R.strap, { R = 1, bias = -1 })
  local body = c:rrect(9, 14, 55, 50, 3)
  local bi = C.lay(c, body, R.madder, { R = 3, cuts = { .2, .36, .52, .7, .9 } })
  -- body stripes: linen and indigo bands, flat-weave ticks
  body:each(function(x, y)
    local i = bi[K(x, y)]
    local r = (y - 14) % 9
    if r == 6 then c:put(x, y, R.linen[min(6, i + 1)])
    elseif r == 7 then c:put(x, y, R.indigo[i])
    elseif r == 8 then c:put(x, y, R.linen[min(6, i + 1)])
    elseif (x + floor(y / 2)) % 4 == 0 and r < 5 and X.hash(x, y, 4) < 0.6 then c:put(x, y, R.madder[max(1, i - 1)]) end
  end)
  -- flap with a V point
  local flap = c:poly{ {9,14}, {56,14}, {56,30}, {32.5,41}, {9,30} }:clip(c:rrect(9, 14, 55, 50, 3):add(c:rect(9, 14, 55, 41)))
  for x = 10, 54 do
    local yb
    for y = 45, 14, -1 do if flap:has(x, y) then yb = y break end end
    if yb then c:put(x, yb + 1, R.madder[1]) c:put(x, yb + 2, R.madder[2]) end
  end
  local fi = C.lay(c, flap, R.indigo, { R = 3, cuts = { .2, .36, .52, .7, .9 } })
  -- flap border and diamond row
  flap:edge():each(function(x, y) c:put(x, y, R.linen[(x < 32 and y < 30) and 6 or 4]) end)
  flap:shrink(1):edge():each(function(x, y) c:put(x, y, R.madder[(x < 32) and 4 or 3]) end)
  for i = 0, 4 do
    local cx, cy = 17 + i * 8, 23
    for dy = -4, 4 do for dx = -4, 4 do
      local d = abs(dx) + abs(dy)
      if d <= 4 and flap:has(cx + dx, cy + dy) then
        local lit = (dx + dy) < 0
        if d == 4 or d == 3 then c:put(cx + dx, cy + dy, R.ochre[lit and 5 or 4])
        elseif d <= 1 then c:put(cx + dx, cy + dy, R.madder[lit and 5 or 4]) end
      end
    end end
  end
  -- small chevrons below the diamonds
  for x = 16, 49 do local y = 31 + ((x % 4 < 2) and 0 or 1) if flap:shrink(2):has(x, y) then c:put(x, y, R.ochre[3]) end end
  -- corner tassels
  local function tassel(x, y)
    C.stroke(c, { {x, y}, {x, y + 2} }, R.ochre[3])
    local t = c:poly{ {x - 1.5, y + 3}, {x + 2.5, y + 3}, {x + 3, y + 8}, {x - 2, y + 8} }
    C.lay(c, t, R.ochre, { R = 1 })
    C.vline(c, x, y + 4, y + 7, R.ochre[2])
    c:put(x - 1, y + 3, R.ochre[6])
  end
  tassel(10, 51) tassel(54, 51)
  -- quirk: little brass bell at the flap point
  C.stroke(c, { {32,41}, {32,43} }, R.strap[2])
  local bell = c:poly{ {32.5,43}, {35,45}, {36,49}, {29,49}, {30,45} }
  C.lay(c, bell, R.brass, { R = 1 })
  C.hline(c, 29, 35, 49, R.brass[2]) c:put(31, 45, R.brass[6]) c:put(30, 46, C.cream)
  c:put(32, 50, R.brass[2])
  C.save(c, "backpack-3-kilim-saddle-bag")
end

---------------------------------------------------------------- 4 copper-pot frame
do
  local c = C.new("backpack-4-copper-pot-frame")
  local grain = function(x, y, i) if (x * 5 + floor(y / 4)) % 5 == 0 and X.hash(x, y, 8) < 0.6 then return -1 end end
  -- frame: two poles and crossbars
  local poles = c:rect(12, 6, 15, 59):add(c:rect(49, 6, 52, 59))
  local bars = c:rect(10, 9, 54, 12):add(c:rect(12, 47, 52, 49))
  C.lay(c, bars, R.wood, { R = 1, bias = -1, tex = grain })
  C.lay(c, c:rect(12, 6, 15, 59), R.wood, { R = 2, tex = grain })
  C.lay(c, c:rect(49, 6, 52, 59), R.wood, { R = 2, bias = -1, tex = grain })
  -- pole caps
  for _, x in ipairs({ 12, 49 }) do C.hline(c, x, x + 3, 6, R.wood[6]) end
  -- rolled reed mat lashed under the pot
  local mat, mn = X.cyl(9, 53, 55, 53, function() return 4.5 end)
  local mi = C.toneN(c, mat, mn, R.palm)
  C.retone(c, mat, mi, R.palm, function(x, y, i) if x % 3 == 0 then return -1 end end)
  local me = c:ellipse(9, 53, 2, 4.5)
  c:fillMask(me, R.palm[3])
  C.put(c, { {9,51}, {10,52}, {10,54}, {9,55}, {8,53} }, R.palm[1]) c:put(9, 53, R.palm[5])
  -- copper pot
  local belly = c:ellipse(32, 35, 14, 11)
  local neck = c:poly{ {26,18}, {38,18}, {37,26}, {27,26} }
  local lip = c:rrect(23, 15, 41, 19, 2)
  local pot = belly:copy():add(neck)
  -- mint sprig behind the lip
  local stem = c:line({ {33,15}, {34,10}, {36,6} }, 1)
  stem:each(function(x, y) c:put(x, y, R.mint[2]) end)
  local leaves = {}
  for _, L in ipairs({ { 33, 12, 29, 9 }, { 35, 10, 40, 7 }, { 35, 6, 34, 2 }, { 31, 15, 27, 12 } }) do
    local m, n = G.oval((L[1] + L[3]) / 2, (L[2] + L[4]) / 2, 3, 1.6, math.atan(L[4] - L[2], L[3] - L[1]))
    m:grow(1):cut(m):each(function(x, y) if not stem:has(x, y) then c:put(x, y, R.mint[1]) end end)
    leaves[#leaves + 1] = { m, n }
  end
  for _, l in ipairs(leaves) do C.G.toneN(c, l[1], l[2], R.mint) end
  -- ropes lashing the pot to the frame
  C.sep(c, pot, bars:copy():add(poles), R.wood[1])
  local pidx = C.G.toneN(c, belly, X.sphere(31, 33, 14.5, belly), R.copper, { cuts = { .2, .36, .52, .68, .86 } })
  C.vcyl(c, neck, R.copper, 26, 38)
  -- hammered dimples
  belly:each(function(x, y) if (x * 3 + y * 5) % 7 == 0 and X.hash(x, y, 11) < 0.7 then
    local i = pidx[K(x, y)] if i and i > 1 then c:put(x, y, R.copper[i - 1]) end
    if belly:has(x - 1, y - 1) and i and i < 6 then c:put(x - 1, y - 1, R.copper[i + 1]) end
  end end)
  C.hline(c, 24, 40, 26, R.copper[1])
  C.sep(c, lip, neck, R.copper[1])
  C.lay(c, lip, R.copper, { R = 1 })
  C.hline(c, 25, 39, 15, R.copper[6])
  local mouth = c:rect(26, 16, 38, 16)
  c:fillMask(mouth, R.copper[1])
  -- rope across the belly to both poles
  local rope = c:line({ {15,34}, {20,36}, {44,36}, {49,34} }, 1)
  local rope2 = c:line({ {15,36}, {20,38}, {44,38}, {49,36} }, 1)
  rope:each(function(x, y) c:put(x, y, R.linen[5]) end)
  rope2:each(function(x, y) c:put(x, y, R.linen[3]) end)
  for _, x in ipairs({ 12, 49 }) do C.put(c, { {x,33}, {x+3,33}, {x,37}, {x+3,37} }, R.linen[4]) C.hline(c, x, x + 3, 35, R.linen[5]) end
  -- shine
  for y = 28, 40 do c:put(22 + floor((y - 28) / 6), y, R.copper[6]) end
  for y = 30, 36 do c:put(23 + floor((y - 28) / 6), y, R.copper[5]) end
  C.vline(c, 42, 32, 40, R.copper[4])
  c:put(23, 29, C.cream) c:put(24, 28, R.copper[6]) c:put(23, 30, R.copper[6]) c:put(25, 28, R.copper[6])
  C.save(c, "backpack-4-copper-pot-frame")
end

---------------------------------------------------------------- 5 bottle-gourd sling
do
  local c = C.new("backpack-5-bottle-gourd-sling")
  -- sling cord behind
  local sling = c:line({ {26,22}, {14,26}, {9,38}, {13,50}, {22,55} }, 2)
  sling:each(function(x, y) c:put(x, y, R.linen[(x < 14) and 5 or 3]) end)
  local low = c:ellipse(33, 42, 15, 14)
  local up = c:ellipse(33, 20, 8.5, 8.5)
  local waist = c:poly{ {27,24}, {39,24}, {42,32}, {24,32} }
  local neck = c:rrect(30, 8, 36, 14, 1)
  local gourd = low:copy():add(up):add(waist):add(neck)
  C.sep(c, gourd, sling, R.linen[1])
  local n = {}
  local nl = X.sphere(33, 42, 15, low)
  local nu = X.sphere(33, 20, 8.5, up)
  local nn = {}
  gourd:each(function(x, y)
    local k = K(x, y)
    nn[k] = nl[k] or nu[k] or { (x - 33) / 9, -0.1, 0.9 }
  end)
  -- blend the waist by vertical cylinder
  waist:each(function(x, y) if not low:has(x, y) and not up:has(x, y) then local t = (x - 33) / 10 nn[K(x, y)] = { t, 0, sqrt(max(0.05, 1 - t * t)) } end end)
  neck:each(function(x, y) local t = (x - 33) / 4 nn[K(x, y)] = { t, 0, sqrt(max(0.05, 1 - t * t)) } end)
  local gi = C.G.toneN(c, gourd, nn, R.gourd, { cuts = { .2, .36, .52, .68, .86 } })
  -- faint vertical stripes of the dried skin
  C.retone(c, gourd, gi, R.gourd, function(x, y, i) if (x - 33) % 6 == 3 and y > 30 and X.hash(x, y, 12) < 0.8 then return -1 end end)
  -- neck mouth
  C.hline(c, 31, 35, 8, R.gourd[1]) C.hline(c, 30, 36, 9, R.gourd[5])
  -- knotted net over the lower bulb
  local netA = HP.mask()
  low:each(function(x, y)
    if y > 30 and ((x + y) % 7 == 0 or (x - y) % 7 == 0) then netA:set(x, y) end
  end)
  netA:each(function(x, y)
    local lit = (x + y) < 76
    local knot = ((x + y) % 7 == 0) and ((x - y) % 7 == 0)
    c:put(x, y, knot and R.linen[lit and 6 or 4] or R.linen[lit and 5 or 3])
  end)
  -- net gathering ring at the waist
  local ring = c:line({ {24,31}, {29,29}, {37,29}, {42,31} }, 1)
  ring:each(function(x, y) c:put(x, y, R.linen[(x < 33) and 6 or 4]) end)
  C.hline(c, 25, 41, 32, R.gourd[2])
  -- the sling tie at the neck
  C.hline(c, 29, 37, 13, R.linen[5]) C.hline(c, 30, 36, 14, R.linen[3])
  -- shine
  C.put(c, { {25,35}, {24,36}, {26,34} }, R.gourd[6]) c:put(25, 36, C.cream)
  C.put(c, { {29,16}, {28,17} }, R.gourd[6])
  -- quirk: cork-wood stopper dangling on its own little string
  local str = c:line({ {37,13}, {41,15}, {44,19} }, 1)
  str:each(function(x, y) if not gourd:has(x, y) then c:put(x, y, R.strap[2]) end end)
  local stop = c:rrect(42, 19, 47, 25, 1)
  C.lay(c, stop, R.cedar, { R = 1 })
  C.hline(c, 43, 46, 19, R.cedar[6]) C.hline(c, 42, 47, 22, R.cedar[3])
  c:put(43, 20, C.cream)
  C.save(c, "backpack-5-bottle-gourd-sling")
end
