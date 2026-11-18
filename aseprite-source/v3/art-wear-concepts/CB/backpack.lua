-- backpack.lua: CB Sunsprinkle Isles backpack concepts (5 icons, 64x64). See concepts.md.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, W, G = C.HP, C.X, C.K, C.R, C, C.G
local only = app.params.only
local function want(n) return not only or only == n end
local cane = { "#2e1e3a", "#4a2c58", "#6a3e74", "#8c5690", "#ae74a8", "#d0a0c4" }

------------------------------------------------------------------ 1 market basket pack
if want("1") then
  local c = C.new("backpack-1-market-basket-pack")
  -- palm leaves sticking out (behind)
  local function blade(pts, w0)
    return C.tube(c, pts, function(t) return math.max(.6, w0 * (1 - t) + .4) end, R.palm, {
      tex = function(x, y, t, s) if s and math.abs(s) < .25 and t < .85 then return 1 end end })
  end
  blade({ {25,24}, {21,16}, {15,9}, {9,6} }, 2.6)
  blade({ {29,24}, {28,14}, {27,8}, {25,2} }, 2.4)
  -- mango peeking over the rim
  local mango = c:ellipse(39, 19, 7, 5.5)
  local mn = X.sphere(38.6, 18.6, 6.5, mango)
  local mi = W.toneN(c, mango, mn, R.sunset, { cuts = { .2, .38, .55, .72, .88 } })
  mango:each(function(x, y) if x > 41 and y < 18 and mi[K(x, y)] > 3 then c:put(x, y, R.hibis[mi[K(x, y)]]) end end)
  c:put(36, 15, R.sunset[6]) c:put(35, 16, W.cream)
  W.put(c, { {40,13}, {41,12} }, R.wood[2])
  W.put(c, { {42,11}, {43,10}, {44,10}, {45,11}, {43,11}, {44,11} }, R.palm[4]) c:put(43, 10, R.palm[6])
  -- basket body
  local body = c:poly{ {16,24}, {48,24}, {45,52}, {41,56}, {23,56}, {19,52} }
  local rim = c:rrect(13, 21, 51, 27, 3)
  local bi = C.lay(c, body, R.straw, { R = 5, cuts = { .22, .4, .56, .72, .88 } })
  W.retone(c, body, bi, R.straw, function(x, y)
    if x % 4 == 0 then return -1 end
    if (y % 4 == 1) and ((x // 4 + y // 4) % 2 == 0) then return -1 end
    if (y % 4 == 3) and ((x // 4 + y // 4) % 2 == 1) then return 1 end
  end)
  -- dyed band
  local band = c:rect(15, 37, 49, 40):clip(body)
  local bdi = C.lay(c, band, R.hibis, { R = 1 })
  W.retone(c, band, bdi, R.hibis, function(x, y) if (x + y) % 4 == 0 then return -1 end end)
  W.hline(c, 16, 48, 41, R.straw[1])
  -- base ring
  for x = 18, 46 do for y = 52, 56 do if body:has(x, y) and not body:has(x, y + 2) then c:put(x, y, R.straw[2]) end end end
  -- twisted rim over everything
  C.sep(c, rim, mango)
  local ri = C.lay(c, rim, R.straw, { R = 2 })
  W.retone(c, rim, ri, R.straw, function(x, y) if (x + y) % 3 == 0 then return -1 elseif (x + y) % 3 == 1 then return 1 end end)
  W.hline(c, 15, 49, 28, R.straw[1])
  -- palm-cord shoulder loops on the sides
  for _, p in ipairs({ { {14,27}, {9,32}, {10,44}, {19,49} }, { {50,27}, {55,32}, {54,44}, {45,49} } }) do
    C.tube(c, p, 1.2, R.palm, { tex = C.twist })
  end
  c:put(18, 30, R.straw[6]) c:put(19, 30, R.straw[6])
  C.save(c, "backpack-1-market-basket-pack")
end

------------------------------------------------------------------ 2 calabash carrier
if want("2") then
  local c = C.new("backpack-2-calabash-carrier")
  local gourd = c:ellipse(32, 39, 17, 15)
  local neck = c:rrect(27, 17, 37, 27, 3)
  local nn = {} -- neck as a vertical cylinder
  C.lay(c, neck, R.gourd, { R = 3 })
  local gn = X.sphere(31, 37, 17, gourd)
  C.sep(c, gourd, neck, R.gourd[1])
  local gi = W.toneN(c, gourd, gn, R.gourd, { cuts = { .2, .36, .52, .68, .86 } })
  -- carved wave band around the belly
  for x = 15, 49 do
    local y = 40 + math.floor(math.sin(x * 0.75) * 1.6 + .5)
    if gourd:has(x, y) then c:put(x, y, R.gourd[1]) c:put(x, y + 1, R.gourd[1]) c:put(x, y - 1, R.gourd[math.min(6, gi[K(x, y)] + 2)]) end
  end
  -- knotted rope net over the gourd (diamond mesh), knots at crossings
  gourd:each(function(x, y)
    if y > 27 and math.abs(y - 40 - math.floor(math.sin(x * 0.75) * 1.6 + .5)) > 1 then
      local a, b = (x + y) % 7, (x - y) % 7
      local i = gi[K(x, y)]
      if a == 0 and b == 0 then c:put(x, y, R.sisal[math.min(6, i + 2)])
      elseif a == 0 or b == 0 then c:put(x, y, R.strap[math.max(1, i - 1)]) end
    end
  end)
  -- rope collar on the neck + carry cords
  local col = c:rect(26, 25, 38, 27)
  local ci = C.lay(c, col, R.sisal, { R = 1 })
  W.retone(c, col, ci, R.sisal, C.twist)
  C.tube(c, { {26,26}, {16,24}, {13,30}, {15,36} }, 1.1, R.sisal, { tex = C.twist })
  C.tube(c, { {38,26}, {48,24}, {51,30}, {49,36} }, 1.1, R.sisal, { tex = C.twist })
  -- gloss
  c:put(22, 30, R.gourd[6]) c:put(23, 29, R.gourd[6]) c:put(22, 29, W.cream)
  -- wooden stopper
  local stop = c:rrect(28, 11, 36, 18, 2)
  C.sep(c, stop, neck)
  C.lay(c, stop, R.wood, { R = 2, tex = C.grain })
  W.hline(c, 29, 35, 11, R.wood[6])
  -- quirk: hummingbird perched on the stopper
  local hb = c:ellipse(33, 8, 3, 1.8)
  C.sep(c, hb, stop)
  W.lit(c, hb, R.seaglass, { R = 1 })
  local head = c:ellipse(36.5, 6, 1.6, 1.6)
  W.lit(c, head, R.seaglass, { R = 1 })
  W.put(c, { {36,8}, {37,8} }, R.hibis[4]) c:put(35, 8, R.hibis[3])
  W.hline(c, 39, 42, 6, R.strap[2])
  c:put(37, 5, W.ink)
  W.put(c, { {29,9}, {28,10}, {27,10} }, R.indigo[4]) c:put(28, 9, R.indigo[5])
  W.put(c, { {31,6}, {32,5}, {33,5} }, R.seaglass[6])
  W.put(c, { {33,10}, {34,10} }, R.strap[1])
  C.save(c, "backpack-2-calabash-carrier")
end

------------------------------------------------------------------ 3 net-roll bundle
if want("3") then
  local c = C.new("backpack-3-net-roll-bundle")
  -- carry loop (behind)
  C.tube(c, { {21,26}, {22,10}, {42,10}, {43,26} }, 1.5, R.sisal, { tex = C.twist })
  local roll, rn = X.cyl(12, 33, 52, 33, function() return 9.5 end)
  local ri = W.toneN(c, roll, rn, R.turq, { cuts = { .2, .36, .52, .68, .86 } })
  W.retone(c, roll, ri, R.turq, function(x, y)
    local a, b = (x + y) % 4, (x - y) % 4
    if a == 0 and b == 0 then return 1 elseif a == 0 or b == 0 then return -1 end
  end)
  -- spiral end on the left
  local en = c:ellipse(12, 33, 3.5, 9.5)
  en:each(function(x, y)
    local d = math.sqrt(((x - 12) / 3.5)^2 + ((y - 33) / 9.5)^2)
    local ring = math.floor(d * 3 + (math.atan(y - 33, x - 12) / 6.283))
    c:put(x, y, (ring % 2 == 0) and R.turq[x < 12 and 5 or 4] or R.turq[2])
  end)
  c:put(11, 26, R.turq[6])
  -- rope straps
  for _, sx in ipairs({ 22, 42 }) do
    for y = 22, 44 do if roll:has(sx, y) then c:put(sx, y, R.sisal[y < 31 and 5 or 3]) c:put(sx + 1, y, R.sisal[y < 31 and 3 or 2]) end end
    W.put(c, { {sx,23}, {sx+1,24} }, R.sisal[6])
  end
  -- cork floats knotted along the bottom
  for _, f in ipairs({ {20,46}, {32,47}, {44,46} }) do
    W.vline(c, f[1], 42, f[2] - 3, R.sisal[2])
    local fm = c:ellipse(f[1], f[2], 3.5, 2.6)
    C.sep(c, fm, roll)
    W.lit(c, fm, R.sunset, { R = 2 })
    c:put(f[1] - 2, f[2] - 1, R.sunset[6])
    W.hline(c, f[1] - 1, f[1] + 1, f[2], R.sunset[2])
  end
  -- quirk: a little silver fish caught in the mesh
  local fish = c:ellipse(34, 31, 4, 2)
  W.lit(c, fish, R.steel, { R = 1 })
  W.put(c, { {39,29}, {39,30}, {39,32}, {39,33}, {38,31} }, R.steel[3])
  c:put(40, 29, R.steel[2]) c:put(40, 33, R.steel[2])
  c:put(31, 30, W.ink) c:put(32, 31, R.steel[6])
  W.hline(c, 33, 37, 33, R.steel[2])
  c:put(36, 30, R.turq[2]) c:put(35, 32, R.turq[2])
  c:put(18, 27, R.turq[6]) c:put(19, 27, R.turq[6])
  C.save(c, "backpack-3-net-roll-bundle")
end

------------------------------------------------------------------ 4 batik sea sack
if want("4") then
  local c = C.new("backpack-4-batik-sea-sack")
  local body = c:ellipse(32, 41, 16, 14):add(c:poly{ {25,25}, {39,25}, {47,36}, {17,36} })
  local top = c:poly{ {19,11}, {45,11}, {38,24}, {26,24} }
  for x = 19, 45 do if x % 5 == 2 then top:cut(c:rect(x, 11, x, 12)) end if x % 5 == 1 or x % 5 == 3 then top:cut(c:rect(x, 11, x, 11)) end end
  -- woven shoulder strap looping out on the left (behind)
  C.tube(c, { {26,24}, {10,26}, {9,42}, {20,52} }, 1.6, R.sisal, { tex = C.twist, b = -1 })
  -- gathered crown (behind the drawstring)
  local ti = C.lay(c, top, R.indigo, { R = 2 })
  W.retone(c, top, ti, R.indigo, function(x, y) local q = x % 4 if q == 0 then return -1 elseif q == 1 then return 1 end end)
  top:edge():each(function(x, y) if not top:has(x, y - 1) then c:put(x, y, R.indigo[(x % 4 == 1) and 6 or 4]) end end)
  C.sep(c, body, top, R.indigo[1])
  local bi = C.lay(c, body, R.indigo, { R = 6, cuts = { .22, .4, .56, .72, .9 } })
  -- folds radiating from the neck
  for _, f in ipairs({ { {28,26}, {24,36} }, { {36,26}, {40,36} }, { {32,27}, {32,33} } }) do
    c:line(f, 1):each(function(x, y) if body:has(x, y) then c:put(x, y, R.indigo[math.max(1, bi[K(x, y)] - 1)]) end end)
  end
  -- batik: pale wax-resist rings and a wave line
  local rings = { {23,40}, {36,36}, {30,49}, {42,47}, {20,50} }
  body:each(function(x, y)
    for _, r in ipairs(rings) do
      local d = math.sqrt((x - r[1])^2 + (y - r[2])^2)
      if d >= 2.6 and d < 3.6 then c:put(x, y, (bi[K(x, y)] >= 3) and R.cotton[5] or R.cotton[3]) end
      if d < 1 then c:put(x, y, R.indigo[5]) end
    end
    local wy = 43 + math.floor(math.sin(x * .6) * 1.5 + .5)
    if y == wy and x > 17 and x < 47 then c:put(x, y, R.indigo[5]) end
  end)
  -- drawstring band + cord ends with knots
  local cord = c:rect(23, 23, 41, 25)
  local ci = C.lay(c, cord, R.sisal, { R = 1 })
  W.retone(c, cord, ci, R.sisal, C.twist)
  C.tube(c, { {40,25}, {44,28}, {45,32}, {44,35} }, 1, R.sisal)
  C.tube(c, { {38,25}, {40,29}, {40,32}, {39,34} }, 1, R.sisal)
  C.ball(c, 44, 36, 1.5, R.sisal) C.ball(c, 39, 35, 1.5, R.sisal)
  -- quirk: sea-turtle appliqué patch
  local shell = c:ellipse(27, 32, 4, 3)
  W.put(c, { {22,30}, {22,34}, {32,30}, {32,34}, {33,32} }, R.seaglass[3])
  W.put(c, { {21,30}, {21,34}, {33,30}, {33,34} }, R.seaglass[2])
  c:put(34, 32, R.seaglass[4]) c:put(34, 31, R.seaglass[5])
  W.lit(c, shell, R.palm, { R = 2 })
  W.put(c, { {27,30}, {26,32}, {28,32}, {27,34}, {25,31}, {29,31} }, R.palm[2])
  c:put(25, 30, R.palm[6])
  -- stitch ring around the patch
  for _, p in ipairs({ {22,28}, {26,27}, {30,27}, {34,29}, {35,34}, {31,37}, {26,37}, {21,35} }) do c:put(p[1], p[2], R.cotton[5]) end
  c:put(19, 36, R.indigo[6]) c:put(19, 37, R.indigo[6])
  C.save(c, "backpack-4-batik-sea-sack")
end

------------------------------------------------------------------ 5 bamboo frame pack
if want("5") then
  local c = C.new("backpack-5-bamboo-frame-pack")
  local function pole(x0, x1, y0, y1, b)
    local m = c:rect(x0, y0, x1, y1)
    local i = W.vcyl(c, m, R.bamboo, x0, x1, { bias = C.bias(m, b or 0) })
    for y = y0 + 4, y1 - 2, 9 do W.hline(c, x0, x1, y, R.bamboo[1]) W.hline(c, x0, x1, y + 1, R.bamboo[5]) end
    return m
  end
  local function bar(y, b)
    local m = c:rect(14, y, 50, y + 2)
    W.lit(c, m, R.bamboo, { R = 1, bias = C.bias(m, b or 0) })
    W.hline(c, 14, 50, y, R.bamboo[5])
    return m
  end
  -- back crossbar, then cane bundle, then poles + front bars
  bar(15, -1)
  local stalks = {}
  for i, sx in ipairs({ 22, 26, 30, 34, 38 }) do
    local y0 = ({ 6, 3, 5, 2, 7 })[i]
    local m = c:rect(sx, y0, sx + 3, 46)
    if i > 1 then C.sep(c, m, stalks[i - 1], cane[1]) end
    local ii = W.vcyl(c, m, cane, sx, sx + 3, { cuts = { .2, .36, .52, .68, .86 } })
    for y = y0 + 3 + i, 46, 7 do W.hline(c, sx, sx + 3, y, R.bamboo[3]) W.hline(c, sx, sx + 3, y + 1, cane[2]) end
    W.hline(c, sx, sx + 3, y0, R.bamboo[4]) c:put(sx + 1, y0, R.bamboo[6])
    stalks[i] = m
  end
  -- rolled mat at the bottom
  local mat, mn = X.cyl(14, 50, 50, 50, function() return 4.5 end)
  local mi = W.toneN(c, mat, mn, R.straw)
  W.retone(c, mat, mi, R.straw, function(x, y) if x % 3 == 0 then return -1 end end)
  local me = c:ellipse(14, 50, 2, 4.5)
  c:fillMask(me, R.straw[4]) W.put(c, { {14,48}, {15,50}, {14,52}, {13,50} }, R.straw[1])
  pole(10, 14, 6, 57) pole(50, 54, 6, 57)
  W.put(c, { {11,6}, {12,6}, {51,6}, {52,6} }, R.bamboo[6])
  local b2 = bar(30)
  -- cord lashings at the joints
  for _, p in ipairs({ {12,30}, {52,30}, {12,15}, {52,15}, {24,31}, {40,31}, {12,50}, {52,50} }) do
    for dy = -1, 3 do c:put(p[1] - 2 + (dy % 2), p[2] + dy, R.sisal[dy % 2 == 0 and 5 or 3]) c:put(p[1] + 2 - (dy % 2), p[2] + dy, R.sisal[2]) end
  end
  -- quirk: parrot feather tucked in the lashing
  local fm, _, fT, fS = G.tube({ {41,32}, {45,24}, {50,16}, {56,8} }, function(t) return t < .15 and .8 or 2.2 * math.sin(math.pi * math.min(1, t)) + .4 end)
  C.sep(c, fm, stalks[5]:copy():add(b2), W.ink)
  fm:each(function(x, y)
    local t, s = fT[K(x, y)], fS[K(x, y)]
    local ramp = t < .5 and R.hibis or (t < .78 and R.brass or R.jay)
    local i = s < -.2 and 5 or (s > .3 and 2 or 4)
    c:put(x, y, ramp[i])
    if math.abs(s) < .2 and t > .1 then c:put(x, y, R.cotton[5]) end
  end)
  C.save(c, "backpack-5-bamboo-frame-pack")
end
