-- cloak.lua: SA "Rainroot Reaches" cloak concepts, 5 icons (see concepts.md).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local abs, floor, sqrt, max, min, sin, pi, atan = math.abs, math.floor, math.sqrt, math.max, math.min, math.sin, math.pi, math.atan
local CUT = { .2, .36, .52, .7, .88 }

---------------------------------------------------------------- 1 striped poncho
do
  local c = C.new("cloak-1-striped-poncho")
  local pon = c:poly{ {16,10}, {26,7}, {38,7}, {48,10}, {57,24}, {33,52}, {31,52}, {7,24} }
  local seq = { R.yarnA, R.yarnA, R.yarnA, R.straw, R.indigo, R.straw, R.alpaca, R.yarnA, R.yarnA, R.indigo, R.indigo, R.alpaca }
  local stripe = function(x, y) return seq[floor(abs(x - 31.5) / 2) % #seq + 1] end
  -- fringe strands along the two lower edges (behind)
  local fr = HP.mask()
  pon:each(function(x, y)
    if not pon:has(x, y + 1) and y > 22 and x % 2 == 0 then
      for d = 1, 3 + floor(X.hash(x, 0, 3) * 2) do fr:set(x, y + d) end
    end
  end)
  fr:cut(pon)
  fr:each(function(x, y) c:put(x, y, R.alpaca[(x < 32) and 4 or 3]) end)
  C.sep(c, pon, fr, R.alpaca[2])
  local pi_ = C.litm(c, pon, stripe, { R = 7, hs = 0.6, cuts = CUT })
  -- drape folds from the shoulders down to the point
  for _, f in ipairs({ { 16, 11, 26, 44 }, { 47, 11, 38, 44 } }) do
    local m = c:line({ { f[1], f[2] }, { f[3], f[4] } }, 1):clip(pon)
    m:each(function(x, y) c:put(x, y, stripe(x, y)[max(1, (pi_[K(x, y)] or 3) - 2)]) end)
    m:shift(-1, 0):clip(pon):cut(m):each(function(x, y) c:put(x, y, stripe(x, y)[min(6, (pi_[K(x, y)] or 3) + 1)]) end)
  end
  -- neck opening with a rolled collar
  local col = c:ellipse(32, 9, 7, 3):cut(c:ellipse(32, 8, 4.5, 1.6))
  C.lit(c, col, R.indigo, { R = 1 })
  c:fillMask(c:ellipse(32, 8, 4.5, 1.6), R.indigo[1])
  -- quirk: one long tassel off the front point
  local cord = c:rect(32, 53, 32, 55)
  c:fillMask(cord, R.yarnA[3])
  local ts = c:poly{ {30.5,56}, {34.5,56}, {35,62}, {30,62} }
  C.lit(c, ts, R.yarnA, { R = 1 })
  C.vline(c, 33, 58, 62, R.yarnA[2]) C.vline(c, 31, 57, 61, R.yarnA[6])
  C.hline(c, 31, 34, 56, R.straw[5])
  c:put(14, 15, C.cream) c:put(15, 14, R.yarnA[6])
  C.save(c, "cloak-1-striped-poncho")
end

---------------------------------------------------------------- 2 thatch rain cape
do
  local c = C.new("cloak-2-thatch-rain-cape")
  local tiers = {
    { y0 = 32, y1 = 55, xt0 = 15, xt1 = 49, xb0 = 8, xb1 = 56, ramp = R.straw, b = -1 },
    { y0 = 20, y1 = 41, xt0 = 19, xt1 = 45, xb0 = 12, xb1 = 52, ramp = R.palm, b = 0 },
    { y0 = 10, y1 = 28, xt0 = 24, xt1 = 40, xb0 = 17, xb1 = 47, ramp = R.straw, b = 1 },
  }
  local acc = HP.mask()
  for ti, T in ipairs(tiers) do
    local m = HP.mask()
    for y = T.y0, T.y1 do
      local f = (y - T.y0) / (T.y1 - T.y0)
      local x0, x1 = T.xt0 + (T.xb0 - T.xt0) * f, T.xt1 + (T.xb1 - T.xt1) * f
      for x = floor(x0 + .5), floor(x1 + .5) do
        local cut = floor(X.hash(x, ti, 11) * 4)
        if y <= T.y1 - cut then m:set(x, y) end
      end
    end
    m:cut(acc)
    C.sep(c, m, acc, T.ramp[1])
    local n = {}
    local cx = 32
    m:each(function(x, y)
      local f = (y - T.y0) / (T.y1 - T.y0)
      local hw = (T.xt1 - T.xt0) / 2 + ((T.xb1 - T.xb0) - (T.xt1 - T.xt0)) / 2 * f
      local t = max(-.95, min(.95, (x - cx) / hw))
      n[K(x, y)] = { t * 0.9, -0.3 + f * 0.5, sqrt(max(.05, 1 - t * t)) }
    end)
    local b = {} m:each(function(x, y) b[K(x, y)] = T.b end)
    local idx = C.toneN(c, m, n, T.ramp, { cuts = CUT, bias = b })
    -- vertical fibre strands
    C.retone(c, m, idx, T.ramp, function(x, y)
      if x % 2 == 0 and X.hash(x, floor(y / 5), ti) < .7 then return -1 end
      if x % 3 == 1 and y % 4 == 0 then return 1 end
    end)
    -- strand tips lighter, upper binding row dark
    m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, T.ramp[min(6, (idx[K(x, y)] or 3) + 1)]) end end)
    acc:add(m)
  end
  -- neck binding + tie cord
  local nb = c:rrect(23, 8, 41, 12, 2)
  C.lit(c, nb, R.strap, { R = 1 })
  C.hline(c, 24, 40, 8, R.strap[5])
  for x = 24, 40, 3 do c:put(x, 10, R.strap[2]) end
  local tie = c:line({ {32,12}, {29,17}, {28,20} }, 1):add(c:line({ {32,12}, {35,17}, {37,19} }, 1))
  tie:each(function(x, y) c:put(x, y, R.strap[3]) end)
  local kn = c:rect(31, 11, 33, 13) C.lit(c, kn, R.strap, { R = 1, bias = 1 })
  -- quirk: hummingbird hovering by the collar
  local bod = c:ellipse(50, 7, 3, 2)
  local tail = c:poly{ {47,8}, {44,11}, {45,12}, {48,9} }
  local wing = c:poly{ {50,6}, {48,1}, {52,2}, {52,6} }
  local beak = c:line({ {53,7}, {57,9} }, 1)
  local hb = bod:copy():add(tail):add(wing)
  C.lit(c, tail, R.frog, { R = 1, bias = -1 })
  C.lit(c, bod, R.frog, { R = 1 })
  C.lit(c, wing, R.turq, { R = 1, bias = 1 })
  c:fillMask(beak, C.ink)
  c:put(52, 7, C.ink) c:put(51, 6, R.frog[6])
  C.put(c, { {50,9}, {51,9}, {49,9} }, R.ember[4])
  C.save(c, "cloak-2-thatch-rain-cape")
end

---------------------------------------------------------------- 3 feather shoulder mantle
do
  local c = C.new("cloak-3-feather-shoulder-mantle")
  local ox, oy = 32, 6
  local rows = {
    { d0 = 26, d1 = 39, ramp = R.ember, step = 6.0, off = 0 },
    { d0 = 18, d1 = 31, ramp = R.brass, step = 5.0, off = 0.5 },
    { d0 = 10, d1 = 23, ramp = R.jay, step = 4.0, off = 0 },
  }
  local polar = function(x, y)
    local dx, dy = x - ox, (y - oy) * 1.25
    return sqrt(dx * dx + dy * dy), atan(dx, dy)
  end
  local acc = HP.mask()
  for ri, rw in ipairs(rows) do
    local m, U = HP.mask(), {}
    for y = 6, 63 do for x = 0, 63 do
      local d, a = polar(x, y)
      if y >= 9 and abs(a) < 1.45 then
        local s = a * rw.d1 / rw.step + rw.off
        local u = s - floor(s)
        local tip = rw.d1 - 9 * (u - 0.5) ^ 2 * 4 * 0.5
        if d >= rw.d0 and d <= tip then m:set(x, y) U[K(x, y)] = u end
      end
    end end
    m:cut(acc)
    C.sep(c, m, acc, rw.ramp[1])
    local b = {} m:each(function(x, y) local u = U[K(x, y)] b[K(x, y)] = (abs(u - 0.5) > 0.38) and -1 or 0 end)
    local idx = C.lit(c, m, rw.ramp, { R = 4, bias = b, cuts = CUT })
    m:each(function(x, y)
      local u = U[K(x, y)]
      if abs(u - 0.5) < 0.09 then c:put(x, y, rw.ramp[min(6, (idx[K(x, y)] or 3) + 1)]) end
    end)
    acc:add(m)
  end
  -- felt collar band around the neck
  local col = HP.mask()
  for y = 6, 30 do for x = 0, 63 do local d, a = polar(x, y) if y >= 8 and d >= 6 and d <= 11 and abs(a) < 1.5 then col:set(x, y) end end end
  C.sep(c, col, acc, R.felt[1])
  C.lit(c, col, R.felt, { R = 2 })
  col:each(function(x, y) local d = polar(x, y) if d < 7 then c:put(x, y, R.felt[1]) end end)
  -- clasp
  local cl = c:ellipse(32, 15, 1.8, 1.8)
  C.lit(c, cl, R.brass, { R = 1 }) c:put(31, 14, R.brass[6])
  -- quirk: one loose blue feather drifting off the hem
  local fm, fn, FT, FS = G.blade(48, 50, 53, 53, 57, 58, function(t) return max(0, 2.2 * sin(pi * min(1, t * 1.0 + 0.04)) ^ 0.6) end)
  C.toneN(c, fm, fn, R.jay, { cuts = CUT })
  fm:each(function(x, y) local s = FS[K(x, y)] if s and abs(s) < 0.15 then c:put(x, y, R.jay[6]) end end)
  c:put(47, 49, R.felt[3]) c:put(46, 48, R.felt[3])
  C.save(c, "cloak-3-feather-shoulder-mantle")
end

---------------------------------------------------------------- 4 cloud-forest shawl (stole)
do
  local c = C.new("cloak-4-cloud-forest-shawl")
  local arc = c:ellipse(32, 18, 20, 11):cut(c:ellipse(32, 20, 11, 6)):cut(c:rect(0, 20, 63, 63))
  local tailL = c:poly{ {12,17}, {23,19}, {25,48}, {13,50} }
  local tailR = c:poly{ {41,19}, {52,17}, {51,50}, {39,48} }
  local inner = c:ellipse(32, 20, 11, 6):cut(c:rect(0, 21, 63, 63))
  -- back of the shawl seen through the neck opening
  C.lit(c, inner, R.mist, { R = 2, bias = -3 })
  -- fringes
  local fr = HP.mask()
  for x = 13, 25 do if x % 2 == 1 then for d = 1, 4 do fr:set(x, 49 + d - floor((x - 13) / 12)) end end end
  for x = 39, 51 do if x % 2 == 1 then for d = 1, 4 do fr:set(x, 49 + d - floor((51 - x) / 12)) end end end
  fr:cut(tailL):cut(tailR)
  fr:each(function(x, y) c:put(x, y, R.lav[(y % 3 == 0) and 4 or 3]) end)
  local all = arc:copy():add(tailL):add(tailR)
  C.sep(c, all, fr:copy():add(inner), R.mist[1])
  -- right tail sits behind the left in the crossing, paint right first
  local soft = function(x, y, i) if (x + y * 2) % 5 == 0 and X.hash(x, y, 6) < .6 then return -1 end end
  local ri = C.lit(c, tailR:copy():add(arc), R.mist, { R = 4, cuts = CUT })
  C.retone(c, tailR:copy():add(arc), ri, R.mist, soft)
  C.sep(c, tailL, tailR:copy():add(arc), R.mist[1])
  local li = C.lit(c, tailL, R.mist, { R = 4, cuts = CUT, bias = 0 })
  C.retone(c, tailL, li, R.mist, soft)
  -- soft folds down each tail
  for _, f in ipairs({ { 18, 22, 19, 48 }, { 46, 22, 45, 48 } }) do
    c:line({ { f[1], f[2] }, { f[3], f[4] } }, 1):each(function(x, y) c:put(x, y, R.mist[2]) end)
    c:line({ { f[1] - 1, f[2] }, { f[3] - 1, f[4] } }, 1):each(function(x, y) c:put(x, y, R.mist[5]) end)
  end
  -- knotted fringe band
  C.hline(c, 13, 25, 48, R.lav[2]) C.hline(c, 39, 51, 48, R.lav[2])
  for x = 14, 24, 3 do c:put(x, 47, R.lav[4]) end for x = 40, 50, 3 do c:put(x, 47, R.lav[3]) end
  c:put(16, 12, C.cream) c:put(17, 11, R.mist[6])
  -- quirk: small orchid pinned on the left tail
  local pet = c:ellipse(20, 30, 2.2, 2.2):shift(-2, -1):add(c:ellipse(22, 29, 2.2, 2.2)):add(c:ellipse(20, 33, 2, 2.5)):add(c:ellipse(17, 32, 1.8, 1.8)):add(c:ellipse(23, 32, 1.8, 1.8))
  C.sep(c, pet, tailL, R.mist[1])
  C.lit(c, pet, R.pink, { R = 1, bias = 1 })
  C.put(c, { {20,31}, {21,31}, {20,32} }, R.brass[5])
  c:put(21, 32, R.pink[2]) c:put(19, 28, R.pink[6])
  C.save(c, "cloak-4-cloud-forest-shawl")
end

---------------------------------------------------------------- 5 indigo hooded cloak
do
  local c = C.new("cloak-5-indigo-hooded-cloak")
  local hood = c:poly{ {32,2}, {37,7}, {42,14}, {44,21}, {20,21}, {22,14}, {27,7} }
  local body = c:poly{ {20,18}, {44,18}, {50,34}, {55,58}, {9,58}, {14,34} }
  local face = c:ellipse(32, 17, 6, 4.5)
  local bi = C.lit(c, body, R.indigo, { R = 6, hs = 0.6, cuts = CUT })
  -- hanging folds
  for _, fx in ipairs({ 18, 25, 39, 46 }) do
    local m = c:line({ { 32 + (fx - 32) * 0.55, 24 }, { fx, 57 } }, 1):clip(body)
    m:each(function(x, y) c:put(x, y, R.indigo[max(1, (bi[K(x, y)] or 3) - 2)]) end)
    m:shift(-1, 0):clip(body):cut(m):each(function(x, y) c:put(x, y, R.indigo[min(6, (bi[K(x, y)] or 3) + 1)]) end)
  end
  -- red lining showing along the open front, turned back
  local lin = c:poly{ {31,24}, {33,24}, {38,58}, {26,58} }
  C.lit(c, lin, R.yarnA, { R = 2, bias = -1 })
  local gap = c:poly{ {31.5,26}, {32.5,26}, {34,58}, {30,58} }
  c:fillMask(gap, R.indigo[1])
  -- hem roll
  for x = 9, 55 do if body:has(x, 57) then c:put(x, 57, lin:has(x, 57) and R.yarnA[2] or R.indigo[2]) end end
  -- hood
  C.sep(c, hood, body, R.indigo[1])
  local hi = C.lit(c, hood, R.indigo, { R = 4, cuts = CUT, bias = 1 })
  C.vline(c, 32, 4, 11, R.indigo[3]) C.vline(c, 31, 5, 11, R.indigo[6])
  c:fillMask(face, R.indigo[1])
  face:edge():each(function(x, y) if y <= 16 then c:put(x, y, R.yarnA[(x < 32) and 4 or 2]) end end)
  -- tie cord with a tiny brass bell (quirk)
  C.put(c, { {28,22}, {29,23}, {30,23}, {31,24}, {33,24}, {34,23}, {35,23}, {36,22} }, R.straw[3])
  local bell = c:poly{ {31,25}, {33,25}, {35,29}, {29,29} }
  C.lit(c, bell, R.brass, { R = 1 })
  c:put(31, 26, R.brass[6]) c:put(32, 30, R.brass[2])
  c:put(23, 7 + 18, C.cream) c:put(16, 40, R.indigo[6]) c:put(16, 41, R.indigo[6])
  c:put(27, 10, R.indigo[6]) c:put(26, 11, C.cream)
  C.save(c, "cloak-5-indigo-hooded-cloak")
end
