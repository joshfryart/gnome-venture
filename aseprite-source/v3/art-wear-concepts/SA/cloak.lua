-- cloak.lua: SA "Rainroot Reaches" cloak concepts, 5 icons (see concepts.md).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local abs, floor, sqrt, max, min, sin, pi, atan = math.abs, math.floor, math.sqrt, math.max, math.min, math.sin, math.pi, math.atan
local CUT = { .2, .36, .52, .7, .88 }

---------------------------------------------------------------- 1 striped poncho
do
  local c = C.new("cloak-1-striped-poncho")
  local pon = c:poly{ {12,12}, {24,9}, {40,9}, {52,12}, {58,18}, {57,22}, {33,50}, {31,50}, {7,22}, {6,18} }
  local seq = { R.yarnA, R.yarnA, R.yarnA, R.straw, R.indigo, R.straw, R.alpaca, R.yarnA, R.yarnA, R.indigo, R.indigo, R.alpaca }
  local stripe = function(x, y) return seq[floor((y - abs(x - 31.5) * 0.85 + 40) / 2) % #seq + 1] end
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
  for _, f in ipairs({ { 20, 12, 29, 42 }, { 44, 12, 35, 42 } }) do
    local m = c:line({ { f[1], f[2] }, { f[3], f[4] } }, 1):clip(pon)
    m:each(function(x, y) c:put(x, y, stripe(x, y)[max(1, (pi_[K(x, y)] or 3) - 2)]) end)
    m:shift(-1, 0):clip(pon):cut(m):each(function(x, y) c:put(x, y, stripe(x, y)[min(6, (pi_[K(x, y)] or 3) + 1)]) end)
  end
  -- neck opening with a rolled collar
  local col = c:ellipse(32, 9, 7, 3):cut(c:ellipse(32, 8, 4.5, 1.6))
  C.lit(c, col, R.indigo, { R = 1 })
  c:fillMask(c:ellipse(32, 8, 4.5, 1.6), R.indigo[1])
  -- quirk: one long tassel off the front point
  local cord = c:rect(31, 51, 32, 53)
  c:fillMask(cord, R.yarnA[3])
  local ts = c:poly{ {30,54}, {33,54}, {34,61}, {29,61} }
  C.lit(c, ts, R.yarnA, { R = 1 })
  C.vline(c, 32, 56, 61, R.yarnA[2]) C.vline(c, 30, 56, 60, R.yarnA[6])
  C.hline(c, 30, 33, 54, R.straw[5])
  c:put(10, 16, C.cream) c:put(11, 15, R.yarnA[6])
  C.save(c, "cloak-1-striped-poncho")
end

---------------------------------------------------------------- 2 thatch rain cape
do
  local c = C.new("cloak-2-thatch-rain-cape")
  local tiers = {
    { y0 = 32, y1 = 55, xt0 = 15, xt1 = 49, xb0 = 8, xb1 = 56, ramp = R.straw, b = -1 },
    { y0 = 20, y1 = 41, xt0 = 19, xt1 = 45, xb0 = 12, xb1 = 52, ramp = R.palm, b = 0 },
    { y0 = 9, y1 = 28, xt0 = 21, xt1 = 43, xb0 = 16, xb1 = 48, ramp = R.straw, b = 1 },
  }
  local acc = HP.mask()
  for ti, T in ipairs(tiers) do
    local m = HP.mask()
    for y = T.y0, T.y1 do
      local f = (y - T.y0) / (T.y1 - T.y0)
      local x0, x1 = T.xt0 + (T.xb0 - T.xt0) * f, T.xt1 + (T.xb1 - T.xt1) * f
      for x = floor(x0 + .5), floor(x1 + .5) do
        local cut = floor(X.hash(x, ti, 11) * 4)
        local top = T.y0 + ((x - 32) / ((T.xb1 - T.xb0) / 2)) ^ 2 * (ti == 3 and 5 or 3)
        if y <= T.y1 - cut and y >= top then m:set(x, y) end
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
  local nb = c:ellipse(32, 10, 8, 3):cut(c:ellipse(32, 9, 5, 1.5))
  C.lit(c, nb, R.strap, { R = 1 })
  c:fillMask(c:ellipse(32, 9, 5, 1.5), R.cacao[1])
  for x = 25, 39, 3 do c:put(x, 12, R.strap[2]) end
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
    { d0 = 20, d1 = 31, ramp = R.ember, step = 4.6, off = 0 },
    { d0 = 14, d1 = 25, ramp = R.brass, step = 4.0, off = 0.5 },
    { d0 = 8, d1 = 19, ramp = R.jay, step = 3.4, off = 0 },
  }
  local polar = function(x, y)
    local dx, dy = x - ox, (y - oy) * 0.95
    return sqrt(dx * dx + dy * dy), atan(dx, dy)
  end
  local acc = HP.mask()
  for ri, rw in ipairs(rows) do
    local m, U = HP.mask(), {}
    for y = 6, 63 do for x = 0, 63 do
      local d, a = polar(x, y)
      if y >= 9 and abs(a) < 1.08 then
        local s = a * rw.d1 / rw.step + rw.off
        local u = s - floor(s)
        local tip = rw.d1 - 14 * (u - 0.5) ^ 2
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
  for y = 6, 30 do for x = 0, 63 do local d, a = polar(x, y) if y >= 8 and d >= 5 and d <= 10 and abs(a) < 1.3 then col:set(x, y) end end end
  C.sep(c, col, acc, R.felt[1])
  C.lit(c, col, R.felt, { R = 2 })
  col:each(function(x, y) local d = polar(x, y) if d < 6 then c:put(x, y, R.felt[1]) end end)
  -- clasp
  local cl = c:ellipse(32, 14, 1.8, 1.8)
  C.lit(c, cl, R.brass, { R = 1 }) c:put(31, 13, R.brass[6])
  -- quirk: one loose blue feather drifting off the hem
  local fm, fn, FT, FS = G.blade(46, 46, 50, 50, 53, 56, function(t) return max(0, 2.2 * sin(pi * min(1, t * 1.0 + 0.04)) ^ 0.6) end)
  C.toneN(c, fm, fn, R.jay, { cuts = CUT })
  fm:each(function(x, y) local s = FS[K(x, y)] if s and abs(s) < 0.15 then c:put(x, y, R.jay[6]) end end)
  c:put(45, 45, R.felt[3]) c:put(44, 44, R.felt[3])
  C.save(c, "cloak-3-feather-shoulder-mantle")
end

---------------------------------------------------------------- 4 cloud-forest shawl (stole)
do
  local c = C.new("cloak-4-cloud-forest-shawl")
  local arc = c:ellipse(32, 18, 20, 11):cut(c:ellipse(32, 20, 11, 6)):cut(c:rect(0, 20, 63, 63))
  local tailL = c:poly{ {12,17}, {23,19}, {27,48}, {10,50} }
  local tailR = c:poly{ {41,19}, {52,17}, {54,50}, {37,48} }
  local inner = c:ellipse(32, 20, 11, 6):cut(c:rect(0, 21, 63, 63))
  -- back of the shawl seen through the neck opening
  C.lit(c, inner, R.mist, { R = 2, bias = -3 })
  -- fringes
  local fr = HP.mask()
  for x = 10, 27 do if x % 2 == 1 then for d = 1, 4 do fr:set(x, 50 + d - floor((x - 10) / 9)) end end end
  for x = 37, 54 do if x % 2 == 1 then for d = 1, 4 do fr:set(x, 50 + d - floor((54 - x) / 9)) end end end
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
  for _, f in ipairs({ { 18, 22, 16, 47 }, { 46, 22, 48, 47 } }) do
    c:line({ { f[1], f[2] }, { f[3], f[4] } }, 1):each(function(x, y) c:put(x, y, R.mist[2]) end)
    c:line({ { f[1] - 1, f[2] }, { f[3] - 1, f[4] } }, 1):each(function(x, y) c:put(x, y, R.mist[5]) end)
  end
  -- knotted fringe band
  tailL:each(function(x, y) if not tailL:has(x, y + 2) then c:put(x, y, R.lav[(x + y) % 3 == 0 and 4 or 2]) end end)
  tailR:each(function(x, y) if not tailR:has(x, y + 2) then c:put(x, y, R.lav[(x + y) % 3 == 0 and 3 or 2]) end end)
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
  local hood = c:poly{ {43,2}, {41,7}, {42,14}, {44,22}, {20,22}, {22,13}, {28,8}, {36,5} }
  local body = c:poly{ {22,18}, {42,18}, {50,23}, {52,34}, {54,57}, {46,59}, {38,57}, {32,59}, {26,57}, {18,59}, {10,57}, {12,34}, {14,23} }
  local face = c:ellipse(32, 17, 6, 4.5)
  local bi = C.lit(c, body, R.indigo, { R = 6, hs = 0.6, cuts = CUT })
  -- hanging folds ending in the wavy hem
  for _, fx in ipairs({ 18, 26, 38, 46 }) do
    local m = c:line({ { 32 + (fx - 32) * 0.6, 26 }, { fx, 57 } }, 1):clip(body)
    m:each(function(x, y) c:put(x, y, R.indigo[max(1, (bi[K(x, y)] or 3) - 2)]) end)
    m:shift(-1, 0):clip(body):cut(m):each(function(x, y) c:put(x, y, R.indigo[min(6, (bi[K(x, y)] or 3) + 1)]) end)
  end
  -- front opening, red lining edges turned back
  C.vline(c, 32, 26, 58, R.indigo[1])
  for y = 30, 58 do
    local w = floor((y - 30) / 9)
    for d = 0, w do
      if body:has(32 + 1 + d, y) then c:put(32 + 1 + d, y, R.yarnA[3 - min(1, d)]) end
      if body:has(32 - 1 - d, y) then c:put(32 - 1 - d, y, R.yarnA[5 - d]) end
    end
  end
  -- shoulder rolls
  C.put(c, { {15,24}, {16,23}, {17,23} }, R.indigo[6])
  -- hood
  C.sep(c, hood, body, R.indigo[1])
  C.lit(c, hood, R.indigo, { R = 4, cuts = CUT, bias = 1 })
  c:line({ {41,4}, {37,7}, {32,9}, {30,11} }, 1):each(function(x, y) c:put(x, y, R.indigo[3]) end)
  C.put(c, { {29,10}, {30,9}, {34,7}, {38,5} }, R.indigo[6])
  c:fillMask(face, R.indigo[1])
  face:edge():each(function(x, y) if y <= 17 then c:put(x, y, R.yarnA[(x < 32) and 4 or 2]) end end)
  -- quirk: tie cord with a tiny brass bell
  C.put(c, { {27,22}, {28,23}, {29,23}, {30,24}, {31,24}, {33,24}, {34,24}, {35,23}, {36,23}, {37,22} }, R.straw[4])
  local bell = c:poly{ {31,25}, {33,25}, {35,30}, {29,30} }
  C.sep(c, bell, body, R.indigo[1])
  C.lit(c, bell, R.brass, { R = 1 })
  c:put(30, 27, R.brass[6]) c:put(32, 31, R.brass[2])
  c:put(15, 30, C.cream) c:put(15, 31, R.indigo[6])
  C.save(c, "cloak-5-indigo-hooded-cloak")
end
