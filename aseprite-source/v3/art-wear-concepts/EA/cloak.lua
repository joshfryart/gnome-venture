-- cloak.lua: EA Blossomreach cloak concepts 1..5 (see concepts.md). Hanging front views.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local floor, abs = math.floor, math.abs

-- small bird (white-eye) or frog helpers kept local to each icon

---------------------------------------------------------------- 1 straw rain cape
do
  local c = C.canvas("cloak-1-straw-rain-cape")
  -- tiers bottom first: each a trapezoid with a jagged fringe hem
  local tiers = {
    { y0 = 40, y1 = 58, xt0 = 10, xt1 = 54, xb0 = 5, xb1 = 59, ramp = R.rattan, b = -1 },
    { y0 = 27, y1 = 45, xt0 = 14, xt1 = 50, xb0 = 9, xb1 = 55, ramp = R.straw, b = 0 },
    { y0 = 15, y1 = 32, xt0 = 19, xt1 = 45, xb0 = 13, xb1 = 51, ramp = R.rattan, b = 0 },
    { y0 = 6, y1 = 20, xt0 = 25, xt1 = 39, xb0 = 18, xb1 = 46, ramp = R.straw, b = 1 },
  }
  local prev
  for i, t in ipairs(tiers) do
    local m = c:poly{ { t.xt0, t.y0 }, { t.xt1, t.y0 }, { t.xb1, t.y1 - 1 }, { t.xb0, t.y1 - 1 } }
    for x = t.xb0, t.xb1 do
      local L = ((x * 7) % 5 < 3) and 2 or 0
      for d = 0, L do if (x % 2 == 0) then m:set(x, t.y1 + d - 1) end end
    end
    if prev then C.sep(c, m, prev, t.ramp[1]) end
    local idx = C.vcyl(c, m, t.ramp, t.xb0 - 2, t.xb1 + 2, { bias = C.bias(m, t.b) })
    -- strands
    m:each(function(x, y)
      if (x * 3 + floor(y / 5)) % 4 == 0 then local p = c:get(x, y) for j = 2, 6 do if p == t.ramp[j] then c:put(x, y, t.ramp[j - 1]) end end end
      if (x * 5 + y) % 11 == 0 then local p = c:get(x, y) for j = 1, 5 do if p == t.ramp[j] then c:put(x, y, t.ramp[j + 1]) break end end end
    end)
    prev = (prev or HP.mask()):copy():add(m)
  end
  -- neck tie cord with knot and hanging ends
  C.tube(c, { {24,8}, {28,11}, {36,11}, {40,8} }, 1.1, R.strap, { b = 0 })
  local kn = c:ellipse(32, 11, 2, 1.6)
  C.part(c, kn, R.strap, { R = 1, b = 1 })
  C.tube(c, { {31,12}, {30,16}, {31,19}, {30,22} }, .8, R.strap, { b = 0 })
  C.tube(c, { {33,12}, {35,16}, {34,19}, {35,21} }, .8, R.strap, { b = -1 })
  -- neck opening
  C.hline(c, 26, 38, 6, R.straw[1])
  -- quirk: a little green tree frog sitting on the second tier
  local fx, fy = 41, 39
  local fb = c:ellipse(fx, fy, 3.4, 2.4)
  local legs = c:poly{ {fx - 4, fy + 1}, {fx - 2, fy + 3}, {fx - 5, fy + 3} }:add(c:poly{ {fx + 4, fy + 1}, {fx + 2, fy + 3}, {fx + 5, fy + 3} })
  c:fillMask(legs, R.frog[3])
  C.part(c, fb, R.frog, { R = 2, b = 0 })
  local e1, e2 = c:ellipse(fx - 2, fy - 2.5, 1, 1), c:ellipse(fx + 2, fy - 2.5, 1, 1)
  c:fillMask(e1, R.frog[5]) c:fillMask(e2, R.frog[4])
  c:put(fx - 2, fy - 2, C.ink) c:put(fx + 2, fy - 2, C.ink)
  C.hline(c, fx - 1, fx + 1, fy, R.frog[2])
  c:put(fx - 2, fy - 1, R.frog[6])
  C.save(c, "cloak-1-straw-rain-cape")
end

---------------------------------------------------------------- 2 plum snow hood (hooded quilted mantle)
do
  local c = C.canvas("cloak-2-plum-snow-hood")
  local mantle = c:poly{ {18,20}, {46,20}, {55,56}, {9,56} }:add(c:rrect(9, 48, 55, 59, 5)):add(c:ellipse(32, 24, 15, 6))
  local hood = c:ellipse(32, 15, 11, 10):add(c:poly{ {24,8}, {35,0}, {40,8} })
  local face = c:ellipse(32, 18, 5, 5.5)
  C.part(c, mantle, R.frost, { R = 6, cuts = { .22, .38, .54, .72, .9 } })
  -- quilted diamonds over the mantle
  local mi = {}
  mantle:each(function(x, y)
    local u, v = (x + y) % 7, (x - y) % 7
    if (u == 0 or v == 0) and mantle:shrink(1):has(x, y) then local p = c:get(x, y) for j = 2, 6 do if p == R.frost[j] then c:put(x, y, R.frost[j - 1]) end end end
  end)
  -- front opening
  for y = 26, 58 do if mantle:has(32, y) then c:put(32, y, R.frost[1]) c:put(31, y, R.frost[5]) end end
  C.sep(c, hood, mantle, R.frost[1])
  local hi = C.part(c, hood, R.frost, { R = 4, b = 1 })
  -- fleece rim around the face opening, dark inner hood
  local rim = c:ellipse(32, 18, 7, 7.5):cut(face)
  c:fillMask(face, R.frost[1])
  local inner = face:copy():cut(face:shift(-1, -1))
  c:fillMask(inner, R.frost[2])
  local ri = C.part(c, rim, R.fleece, { R = 2, b = 1 })
  C.retone(c, rim, ri, R.fleece, function(x, y) if (x * 3 + y * 5) % 4 == 0 then return -1 end end)
  -- fleece hem trim
  local hem = c:rrect(9, 56, 55, 60, 2)
  local hmi = C.part(c, hem, R.fleece, { R = 1, b = 0 })
  C.retone(c, hem, hmi, R.fleece, function(x, y) if (x * 3 + y * 5) % 4 == 0 then return -1 end end)
  -- quirk: red plum blossom pinned at the throat, with a bud
  local fx, fy = 32, 29
  for _, d in ipairs({ { 0, -2.5 }, { 2.5, -1 }, { 1.6, 2 }, { -1.6, 2 }, { -2.5, -1 } }) do
    local p = c:ellipse(fx + d[1], fy + d[2], 1.6, 1.6)
    C.part(c, p, R.ember, { R = 1, b = (d[1] <= 0 and d[2] < 0) and 1 or 0 })
  end
  C.put(c, { {fx, fy}, {fx - 1, fy}, {fx, fy - 1} }, R.brass[6]) c:put(fx + 1, fy + 1, R.brass[3])
  c:put(fx - 2, fy - 3, R.petal[6])
  c:put(fx + 6, fy + 4, R.ember[3]) c:put(fx + 5, fy + 3, R.wood[2]) c:put(fx + 4, fy + 2, R.wood[2])
  C.save(c, "cloak-2-plum-snow-hood")
end

---------------------------------------------------------------- 3 maple shawl (square on point, fringe)
do
  local c = C.canvas("cloak-3-maple-shawl")
  -- drape: a square folded on point, hung from its top edge; the top edge sags between two corners
  local shawl = c:poly{ {5,9}, {16,12}, {32,13}, {48,12}, {59,9}, {50,30}, {38,49}, {32,55}, {26,49}, {14,30} }
  local fringe = HP.mask()
  local edges = { { {5,9}, {14,30}, {26,49}, {32,55} }, { {59,9}, {50,30}, {38,49}, {32,55} } }
  for side, e in ipairs(edges) do
    for i = 0, 30 do
      local x, y = G.bez(e, i / 30)
      if i % 2 == 0 and i < 30 then
        local s = (side == 1) and -1 or 1
        for d = 1, 4 do fringe:set(floor(x + s * d * .7 + .5), floor(y + d * .55 + .5)) end
      end
    end
  end
  fringe:cut(shawl)
  fringe:each(function(x, y) c:put(x, y, R.lining[(x < 32) and 5 or 3]) end)
  local si = C.part(c, shawl, R.ember, { R = 6, cuts = { .22, .38, .54, .72, .9 } })
  -- deepen toward the point, warm toward the top (gradient dye)
  shawl:each(function(x, y)
    local i = si[K(x, y)]
    if y > 42 then c:put(x, y, R.lacq[math.min(6, i + 1)]) elseif y < 18 then c:put(x, y, R.autumn[i]) end
  end)
  -- drape folds from the hanging corners toward the point
  for _, f in ipairs({ { {16,13}, {24,30}, {30,50} }, { {48,13}, {40,30}, {34,50} }, { {32,14}, {32,40} } }) do
    c:line(f, 1):clip(shawl:shrink(1)):each(function(x, y) c:put(x, y, R.ember[1]) c:put(x - 1, y, R.ember[5]) end)
  end
  -- shibori resist rings, pale
  for _, p in ipairs({ { 14, 16 }, { 50, 16 }, { 25, 22 }, { 39, 22 }, { 32, 33 }, { 26, 40 }, { 38, 40 }, { 32, 48 } }) do
    if shawl:shrink(2):has(p[1], p[2]) then
      local ring = c:ellipse(p[1], p[2], 2, 2):cut(c:ellipse(p[1], p[2], .6, .6))
      ring:each(function(x, y) if shawl:has(x, y) then c:put(x, y, (x + y <= p[1] + p[2]) and R.lining[6] or R.lining[4]) end end)
    end
  end
  -- rolled top edge
  for x = 5, 59 do for y = 8, 14 do if shawl:has(x, y) and not shawl:has(x, y - 1) then c:put(x, y, R.autumn[6]) c:put(x, y + 1, R.autumn[4]) break end end end
  -- quirk: a red dragonfly resting on the shawl
  local dx, dy = 44, 20
  local wingC = R.snow
  C.put(c, { {dx - 4, dy - 1}, {dx - 3, dy - 1}, {dx - 2, dy - 1}, {dx - 4, dy + 1}, {dx - 3, dy + 1}, {dx - 2, dy + 1},
             {dx + 2, dy - 1}, {dx + 3, dy - 1}, {dx + 4, dy - 1}, {dx + 2, dy + 1}, {dx + 3, dy + 1}, {dx + 4, dy + 1} }, wingC[4])
  C.put(c, { {dx - 4, dy - 1}, {dx + 4, dy - 1} }, wingC[6])
  for y = dy - 1, dy + 7 do c:put(dx, y, R.lacq[(y < dy + 2) and 3 or 4]) end
  c:put(dx, dy - 2, R.lacq[2]) c:put(dx - 1, dy - 2, R.lacq[2]) c:put(dx + 1, dy - 2, R.lacq[2])
  c:put(dx - 1, dy + 1, R.lacq[5])
  C.save(c, "cloak-3-maple-shawl")
end

---------------------------------------------------------------- 4 felt herder's poncho
do
  local c = C.canvas("cloak-4-felt-poncho")
  local pon = c:poly{ {24,10}, {40,10}, {58,30}, {58,54}, {6,54}, {6,30} }
  local pi = C.part(c, pon, R.oat, { R = 6, cuts = { .22, .38, .54, .72, .9 } })
  C.speckle(c, pon, pi, R.oat, .07, 4)
  -- drape folds
  for _, f in ipairs({ { {18,24}, {15,40}, {14,53} }, { {46,24}, {49,40}, {50,53} }, { {32,24}, {32,53} } }) do
    local fm = c:line(f, 1):clip(pon)
    fm:each(function(x, y) c:put(x, y, R.oat[2]) c:put(x - 1, y, R.oat[5]) end)
  end
  -- rust border band around the lower edges with a pale running stitch
  local band = pon:copy():cut(pon:shrink(4))
  band:cut(c:rect(0, 0, 63, 25))
  local bi = C.part(c, band, R.yarnA, { R = 1, b = 0 })
  local mid = pon:shrink(2):edge():clip(band)
  mid:each(function(x, y) if (x + y) % 3 ~= 0 then c:put(x, y, R.lining[6]) end end)
  -- shoulder seams
  C.put(c, { {23,11}, {21,13}, {19,15}, {17,17}, {15,19}, {13,21}, {11,23} }, R.oat[2])
  C.put(c, { {41,11}, {43,13}, {45,15}, {47,17}, {49,19}, {51,21}, {53,23} }, R.oat[2])
  -- neck slit with a rolled collar
  local col = c:rrect(23, 6, 41, 12, 3)
  C.part(c, col, R.yarnA, { R = 2, b = 0 })
  local hole = c:ellipse(32, 8, 6, 1.5)
  c:fillMask(hole, R.oat[1])
  for y = 12, 20 do c:put(32, y, R.oat[1]) c:put(31, y, R.oat[5]) end
  -- quirk: collar tie with a string of turquoise beads
  C.tube(c, { {30,12}, {28,16}, {29,19}, {27,22} }, .7, R.strap, { b = 0 })
  for i, p in ipairs({ { 34, 14 }, { 35, 17 }, { 35, 20 }, { 34, 23 } }) do
    local bd = c:ellipse(p[1], p[2], 1.4, 1.3)
    C.part(c, bd, (i == 2) and R.ember or R.turq, { R = 1, b = 1 })
    c:put(p[1] - 1, p[2] - 1, (i == 2) and R.ember[6] or R.turq[6])
  end
  C.save(c, "cloak-4-felt-poncho")
end

---------------------------------------------------------------- 5 blossom capelet
do
  local c = C.canvas("cloak-5-blossom-capelet")
  local cape = c:poly{ {24,9}, {40,9}, {50,22}, {57,37}, {7,37}, {14,22} }:add(c:rrect(22, 7, 42, 14, 4))
  local scal = {}
  for i = 0, 7 do
    local sx = 9 + i * 6.6
    scal[#scal + 1] = c:ellipse(sx, 38, 3.6, 4)
  end
  local ai = C.part(c, cape, R.petal, { R = 6, cuts = { .22, .38, .54, .72, .9 } })
  for i, m in ipairs(scal) do
    local mm = m:copy():cut(cape:shrink(1))
    C.part(c, mm, R.petal, { R = 2, b = (i < 4) and 1 or 0 })
    local sx = floor(9 + (i - 1) * 6.6 + .5)
    c:put(sx, 41, R.petal[3]) c:put(sx, 40, R.petal[4])
  end
  local all = cape:copy() for _, m in ipairs(scal) do all:add(m) end
  -- seam where the petal hem joins
  for x = 6, 58 do if all:has(x, 35) and all:has(x, 36) then c:put(x, 35, R.petal[3]) end end
  -- soft gathers from the neck
  for _, f in ipairs({ { {27,14}, {20,24}, {15,34} }, { {37,14}, {44,24}, {49,34} }, { {32,15}, {32,34} } }) do
    c:line(f, 1):clip(cape:shrink(1)):each(function(x, y) c:put(x, y, R.petal[3]) c:put(x - 1, y, R.petal[5]) end)
  end
  -- neck opening and cord tie with tassels
  local hole = c:ellipse(32, 9, 7, 1.6)
  c:fillMask(hole, R.petal[1])
  C.tube(c, { {24,13}, {28,16}, {36,16}, {40,13} }, 1, R.jade, { b = 0 })
  local kn = c:ellipse(32, 16, 1.6, 1.4) C.part(c, kn, R.jade, { R = 1, b = 1 })
  C.tube(c, { {31,17}, {30,21}, {31,24}, {30,27} }, .8, R.jade, { b = 0 })
  C.tube(c, { {33,17}, {34,21}, {33,24}, {34,26} }, .8, R.jade, { b = -1 })
  local t1, t2 = c:rrect(29, 27, 31, 31, 1), c:rrect(33, 26, 35, 30, 1)
  C.part(c, t1, R.brass, { R = 1, b = 0 }) C.part(c, t2, R.brass, { R = 1, b = -1 })
  -- quirk: a tiny green white-eye bird perched on the left shoulder
  local bx, by = 18, 15
  local bird = c:ellipse(bx, by, 4, 2.6)
  local head = c:ellipse(bx - 3, by - 2, 2.2, 2.2)
  local tail = c:poly{ {bx + 3, by}, {bx + 8, by - 3}, {bx + 8, by - 1}, {bx + 4, by + 2} }
  C.part(c, tail, R.frog, { R = 1, b = -1 })
  C.part(c, bird, R.frog, { R = 2, b = 1 })
  C.part(c, head, R.frog, { R = 1, b = 1 })
  -- pale belly, white eye-ring, beak, feet
  C.hline(c, bx - 2, bx + 2, by + 2, R.lining[5])
  C.put(c, { {bx - 4, by - 3}, {bx - 3, by - 4}, {bx - 2, by - 3}, {bx - 3, by - 2} }, R.snow[5])
  c:put(bx - 3, by - 3, C.ink)
  c:put(bx - 6, by - 2, R.straw[2])
  C.put(c, { {bx - 1, by + 3}, {bx + 1, by + 3} }, R.strap[2])
  c:put(bx - 1, by - 1, R.frog[6])
  C.save(c, "cloak-5-blossom-capelet")
end
