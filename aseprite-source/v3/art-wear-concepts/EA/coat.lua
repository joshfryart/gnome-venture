-- coat.lua: EA Blossomreach coat concepts 1..5 (see concepts.md). Front views, laid flat / hanging.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local floor, abs = math.floor, math.abs

---------------------------------------------------------------- 1 indigo work jacket
do
  local c = C.canvas("coat-1-indigo-jacket")
  local slL = c:poly{ {18,10}, {5,14}, {4,36}, {18,36} }
  local slR = c:poly{ {46,10}, {59,14}, {60,36}, {46,36} }
  local body = c:poly{ {18,8}, {46,8}, {48,56}, {16,56} }
  local gap = c:poly{ {30,12}, {34,12}, {35,57}, {29,57} }
  C.part(c, slL, R.indigo, { R = 3, b = 0 })
  C.part(c, slR, R.indigo, { R = 3, b = -1 })
  -- sleeve cuffs and seam into the body
  C.hline(c, 5, 17, 34, R.indigo[2]) C.hline(c, 47, 59, 34, R.indigo[1])
  C.sep(c, body, slL:copy():add(slR), R.indigo[1])
  local bi = C.part(c, body:copy():cut(gap), R.indigo, { R = 5, cuts = { .22, .38, .54, .72, .9 } })
  c:fillMask(gap:copy():clip(body), R.indigo[1])
  -- running-stitch rows across sleeves and body
  local cloth = body:copy():add(slL):add(slR)
  for row, y in ipairs({ 16, 21, 26, 31, 40, 45, 50 }) do
    for x = 4, 60 do
      if cloth:has(x, y) and cloth:has(x, y - 1) and cloth:has(x, y + 1) and not gap:has(x, y) and (x + row) % 3 ~= 0 then
        c:put(x, y, R.indigoL[(x < 30) and 5 or 4])
      end
    end
  end
  -- collar band from the neck down both front edges
  local bandL = c:poly{ {25,8}, {30,8}, {30,57}, {25,57} }:clip(body)
  local bandR = c:poly{ {34,8}, {39,8}, {39,57}, {34,57} }:clip(body)
  local neck = G.tube({ {25,10}, {27,3}, {37,3}, {39,10} }, function() return 2.4 end)
  local band = bandL:copy():add(bandR):add(neck)
  C.sep(c, band, body, R.indigo[1])
  C.part(c, neck, R.canvas, { R = 2, b = 0 })
  C.vcyl(c, bandL, R.canvas, 25, 30, {}) C.vcyl(c, bandR, R.canvas, 34, 39, { bias = C.bias(bandR, -1) })
  C.vline(c, 26, 12, 55, R.canvas[6])
  -- hem shadow
  C.hline(c, 17, 47, 56, R.indigo[1])
  -- quirk: mended patch in paler indigo with a stitched cross
  local patch = c:rect(38, 40, 45, 47)
  C.part(c, patch, R.indigoL, { R = 1, b = 0 })
  for i = 0, 7 do c:put(38 + i, 40 + i, R.canvas[6]) c:put(45 - i, 40 + i, R.canvas[6]) end
  patch:edge():each(function(x, y) if (x + y) % 2 == 0 then c:put(x, y, R.canvas[5]) end end)
  C.save(c, "coat-1-indigo-jacket")
end

---------------------------------------------------------------- 2 padded winter vest
do
  local c = C.canvas("coat-2-padded-vest")
  local body = c:poly{ {20,5}, {27,5}, {32,12}, {37,5}, {44,5}, {45,12}, {48,20}, {53,27}, {53,54}, {11,54}, {11,27}, {16,20}, {19,12} }
  body:add(c:rrect(11, 44, 53, 58, 5))
  local neck = c:ellipse(32, 6, 6, 5)
  body:cut(neck)
  -- inner back visible in the neck
  local inner = c:ellipse(32, 7, 5, 3):cut(c:ellipse(32, 11, 5, 4))
  C.part(c, inner, R.lining, { R = 1, b = -1 })
  -- puffy horizontal channels, each its own pillow
  local y0 = 6
  local chans = {}
  for _, h in ipairs({ 8, 8, 8, 8, 8, 9, 10 }) do
    local band = body:copy():clip(c:rect(0, y0, 63, y0 + h - 1))
    chans[#chans + 1] = band
    y0 = y0 + h
  end
  for i, band in ipairs(chans) do
    local bi = C.part(c, band, R.autumn, { R = 3, hs = 1.2, cuts = { .22, .38, .54, .72, .9 } })
    C.speckle(c, band, bi, R.autumn, .03, i)
  end
  -- centre front opening with lining edge
  for y = 11, 58 do if body:has(32, y) then c:put(32, y, R.autumn[1]) c:put(31, y, R.autumn[5]) end end
  -- armhole binding
  local bind = G.tube({ {19,8}, {18,16}, {13,23}, {11,27} }, function() return 1.1 end)
  C.part(c, bind:clip(body), R.lining, { R = 1, b = 0 })
  local bind2 = G.tube({ {45,8}, {46,16}, {51,23}, {53,27} }, function() return 1.1 end)
  C.part(c, bind2:clip(body), R.lining, { R = 1, b = -1 })
  -- quirk: knotted jade cord buttons with loops; the lowest one has a loose dangling end
  for i, y in ipairs({ 16, 25, 34, 43 }) do
    C.hline(c, 28, 36, y, R.jade[2]) C.hline(c, 28, 36, y - 1, R.jade[4])
    local kn = c:ellipse(32, y, 1.7, 1.7)
    C.part(c, kn, R.jade, { R = 1, b = 0 })
    c:put(31, y - 1, R.jade[6])
  end
  C.tube(c, { {33,45}, {35,49}, {33,52}, {35,55} }, .8, R.jade, { b = 0 })
  C.save(c, "coat-2-padded-vest")
end

---------------------------------------------------------------- 3 spring wrap coat
do
  local c = C.canvas("coat-3-spring-wrap")
  local slL = c:poly{ {20,8}, {9,16}, {3,40}, {16,42}, {21,26} }
  local slR = c:poly{ {44,8}, {55,16}, {61,40}, {48,42}, {43,26} }
  local body = c:poly{ {20,6}, {44,6}, {47,30}, {51,59}, {13,59}, {17,30} }
  C.part(c, slL, R.petal, { R = 4, b = 0 })
  C.part(c, slR, R.petal, { R = 4, b = -1 })
  -- sleeve openings: dark inside with cream lining edge
  local opL = c:poly{ {4,38}, {15,40}, {15,42}, {4,40} }
  local opR = c:poly{ {49,40}, {60,38}, {60,40}, {49,42} }
  C.part(c, opL, R.petal, { R = 1, b = -3 }) C.part(c, opR, R.petal, { R = 1, b = -3 })
  C.sep(c, body, slL:copy():add(slR), R.petal[1])
  local bi = C.part(c, body, R.petal, { R = 6, cuts = { .22, .38, .54, .72, .9 } })
  -- crossing: left-over-right diagonal from the left neck to the right waist, then down to the hem
  local lap = c:poly{ {26,6}, {29,6}, {41,31}, {40,59}, {37,59}, {38,32} }
  local edge = HP.mask()
  for y = 6, 59 do
    local xe
    if y <= 31 then xe = floor(27 + (y - 6) * (13 / 25) + .5) else xe = 40 end
    for x = xe, xe + 1 do edge:set(x, y) end
    c:put(xe + 2, y, R.petal[2])
  end
  -- cream collar band along the crossing, wrapping the neck
  local collar = G.tube({ {38,6}, {33,3}, {26,4}, {27,9} }, function() return 2 end)
    :add(X.cyl(27, 8, 40, 32, function() return 2 end))
  C.part(c, collar, R.fleece, { R = 1, b = 1 })
  for y = 9, 31 do c:put(floor(28 + (y - 8) * (13 / 24) + .5), y, R.fleece[6]) end
  -- sash at the waist with a tied knot and tails
  local sash = body:copy():clip(c:rect(0, 30, 63, 35))
  C.shadowUnder(c, sash, body, R.petal[2], 0, 1)
  C.vcyl(c, sash, R.jade, 15, 49, {})
  C.hline(c, 16, 48, 30, R.jade[6])
  local kn = c:rrect(22, 29, 27, 36, 1)
  C.part(c, kn, R.jade, { R = 1, b = 1 })
  C.tube(c, { {23,36}, {22,40}, {24,44}, {22,47} }, 1.1, R.jade, { b = 0 })
  C.tube(c, { {26,36}, {27,41}, {26,43}, {28,46} }, 1.1, R.jade, { b = -1 })
  -- hem band
  C.hline(c, 14, 50, 58, R.petal[2])
  -- quirk: an embroidered goldfish on the lower panel
  local fish = c:ellipse(30, 50, 3, 1.8)
  C.part(c, fish, R.autumn, { R = 1, b = 1 })
  C.put(c, { {33,49}, {34,48}, {34,51}, {35,52}, {34,50} }, R.autumn[3])
  c:put(28, 49, R.lacq[1]) c:put(29, 49, R.autumn[6])
  C.put(c, { {26,46}, {25,44} }, R.ramie[5])
  C.save(c, "coat-3-spring-wrap")
end

---------------------------------------------------------------- 4 fleece-lined jacket
do
  local c = C.canvas("coat-4-fleece-jacket")
  local slL = X.cyl(22, 13, 9, 41, function() return 5.5 end)
  local slR = X.cyl(42, 13, 55, 41, function() return 5.5 end)
  local body = c:poly{ {19,10}, {45,10}, {47,48}, {17,48} }
  C.part(c, slL, R.leather, { R = 4, b = 0 })
  C.part(c, slR, R.leather, { R = 4, b = -1 })
  C.sep(c, body, slL:copy():add(slR), R.leather[1])
  local bi = C.part(c, body, R.leather, { R = 6, cuts = { .22, .38, .54, .72, .9 } })
  C.speckle(c, body, bi, R.leather, .04, 7)
  -- side fastening: diagonal front edge from the collar to the right hem
  for y = 22, 47 do local x = floor(34 + (y - 22) * .3) c:put(x, y, R.leather[1]) c:put(x - 1, y, R.leather[5]) end
  -- fleece cuffs and hem
  local fleece = function(m, b)
    local i = C.part(c, m, R.fleece, { R = 2, b = b })
    C.retone(c, m, i, R.fleece, function(x, y) local h = (x * 5 + y * 3) % 4 if h == 0 then return -1 elseif h == 2 then return 1 end end)
  end
  local cufL = c:ellipse(8.5, 42, 6, 3.4)
  local cufR = c:ellipse(55.5, 42, 6, 3.4)
  local hem = c:rrect(16, 46, 48, 52, 3)
  fleece(hem, 0) fleece(cufL, 0) fleece(cufR, -1)
  -- big curly fleece collar
  local col = c:ellipse(32, 13, 15, 7):add(c:poly{ {22,16}, {30,30}, {36,26}, {42,16} })
  col:cut(c:ellipse(32, 9, 6, 3))
  C.sep(c, col, body, R.leather[1])
  fleece(col, 1)
  for _, p in ipairs({ {22,13}, {27,16}, {37,15}, {41,12}, {30,22}, {34,20}, {19,10} }) do
    c:put(p[1], p[2], R.fleece[2]) c:put(p[1] - 1, p[2] - 1, R.fleece[6])
  end
  local inner = c:ellipse(32, 9, 6, 2.6)
  C.part(c, inner, R.leather, { R = 1, b = -2 })
  -- quirk: turquoise bead toggle on a leather loop
  C.put(c, { {38,27}, {39,28}, {40,28}, {41,27} }, R.strap[1])
  local bead = c:ellipse(37, 29, 2, 2)
  C.part(c, bead, R.turq, { R = 1, b = 1 })
  c:put(36, 28, R.turq[6])
  C.save(c, "coat-4-fleece-jacket")
end

---------------------------------------------------------------- 5 ramie summer jacket
do
  local c = C.canvas("coat-5-ramie-jacket")
  local slL = c:poly{ {20,10}, {3,15}, {5,30}, {20,28} }
  local slR = c:poly{ {44,10}, {61,15}, {59,30}, {44,28} }
  local body = c:poly{ {19,8}, {45,8}, {47,50}, {17,50} }
  local vneck = c:poly{ {26,7}, {38,7}, {33,30}, {31,30} }
  local weave = function(x, y) if x % 3 == 0 or y % 3 == 0 then return -1 end if (x + y) % 3 == 2 then return 1 end end
  local li = C.part(c, slL, R.ramie, { R = 3, b = 1 })
  C.retone(c, slL, li, R.ramie, weave)
  local ri = C.part(c, slR, R.ramie, { R = 3, b = 0 })
  C.retone(c, slR, ri, R.ramie, weave)
  C.sep(c, body, slL:copy():add(slR), R.ramie[2])
  local bm = body:copy():cut(vneck)
  local bi = C.part(c, bm, R.ramie, { R = 5, b = 1, cuts = { .22, .38, .54, .72, .9 } })
  C.retone(c, bm, bi, R.ramie, weave)
  -- inner back of the jacket visible in the open V and down the open front
  local innerV = vneck:copy():clip(body)
  C.part(c, innerV, R.ramie, { R = 1, b = -1 })
  for y = 30, 50 do c:put(32, y, R.ramie[1]) c:put(31, y, R.ramie[6]) end
  -- self-fabric facing along the V and the front edges
  for y = 7, 30 do
    local t = (y - 7) / 23
    c:put(floor(26 + 5 * t + .5) - 1, y, R.ramie[5]) c:put(floor(38 - 5 * t + .5) + 1, y, R.ramie[3])
  end
  -- side slits and hems
  C.vline(c, 18, 44, 50, R.ramie[2]) C.vline(c, 46, 44, 50, R.ramie[1])
  C.hline(c, 4, 19, 29, R.ramie[3]) C.hline(c, 45, 59, 29, R.ramie[2])
  C.hline(c, 18, 46, 49, R.ramie[3])
  -- little canvas ties at the chest
  C.put(c, { {29,22}, {30,22}, {34,22}, {35,22}, {28,23}, {36,23}, {28,24}, {37,24} }, R.canvas[3])
  c:put(29, 21, R.canvas[6]) c:put(35, 21, R.canvas[5])
  -- quirk: a cicada clinging to the left shoulder
  local cx, cy = 12, 17
  local wing = c:poly{ {cx - 3.5, cy - 1.5}, {cx + 3.5, cy - 1.5}, {cx + 3, cy + 6}, {cx, cy + 8.5}, {cx - 3, cy + 6} }
  c:fillMask(wing, R.snow[4])
  wing:edge():each(function(x, y) c:put(x, y, R.ramie[1]) end)
  C.vline(c, cx, cy, cy + 7, R.ramie[2])
  C.put(c, { {cx - 2, cy + 1}, {cx - 2, cy + 3} }, R.snow[6])
  local head = c:rect(cx - 3, cy - 4, cx + 3, cy - 2)
  C.part(c, head, R.frog, { R = 1, b = -2 })
  c:put(cx - 3, cy - 4, R.lacq[2]) c:put(cx + 3, cy - 4, R.lacq[2]) c:put(cx - 1, cy - 4, R.frog[5])
  C.save(c, "coat-5-ramie-jacket")
end
