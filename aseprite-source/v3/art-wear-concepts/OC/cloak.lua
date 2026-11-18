-- cloak.lua: OC (Coralscatter) cloak concepts, 5 icons.
-- Run: AppRun -b --script-param png=<dir>/ --script cloak.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R = C.HP, C.X, C.K, C.R
local floor, sin, cos, pi, abs, max, min = math.floor, math.sin, math.cos, math.pi, math.abs, math.max, math.min
local CU = { .2, .36, .52, .7, .88 }

---------------------------------------------------------------- 1 frond rain cape
do
  local c = C.canvas("cloak-1-frond-rain-cape")
  local F = R.flax
  -- three tiers of hanging fibre strands, bottom tier first
  local tiers = {
    { top = 30, bot = 56, hw0 = 18, hw1 = 25, b = -1 },
    { top = 20, bot = 44, hw0 = 13, hw1 = 21, b = 0 },
    { top = 11, bot = 31, hw0 = 7, hw1 = 15, b = 1 },
  }
  local prev
  for ti, t in ipairs(tiers) do
    local m = HP.mask()
    for y = t.top, t.bot do
      local f = (y - t.top) / (t.bot - t.top)
      local hw = t.hw0 + (t.hw1 - t.hw0) * f
      for x = floor(32 - hw), floor(32 + hw) do m:set(x, y) end
    end
    -- ragged strand ends
    for x = 0, 63 do
      local cut = floor(X.hash(x, ti, 4) * 4) + ((x % 2 == 0) and 0 or 1)
      for y = t.bot - cut + 1, t.bot do m.s[K(x, y)] = nil end
    end
    if prev then C.sep(c, m, prev, F[1]) end
    local i = C.part(c, m, F, { R = 4, b = t.b, cuts = CU })
    -- strands: vertical streaks
    C.retone(c, m, i, F, function(x, y)
      local h = X.hash(x, 0, ti)
      if x % 2 == 0 and h < .5 then return -1 end
      if x % 3 == 1 and h > .7 then return 1 end
    end)
    -- binding row at the top of each tier
    m:each(function(x, y) if y == t.top or y == t.top + 1 then c:put(x, y, (y == t.top) and F[5] or F[2]) end end)
    prev = (prev or HP.mask()):copy():add(m)
  end
  -- neck tie cord
  local cord = c:line({ {24,10}, {28,9}, {36,9}, {40,10} }, 2)
  C.fill(c, cord, R.coir[4]) C.hline(c, 25, 39, 9, R.coir[5])
  C.put(c, { {40,11}, {41,13}, {41,15}, {42,17} }, R.coir[3]) C.put(c, { {39,12}, {39,14}, {38,16} }, R.coir[3])
  C.ball(c, 42, 18, 1.2, R.coir) C.ball(c, 38, 17, 1.2, R.coir)
  -- quirk: raindrop bead sliding down one strand
  local d = c:poly{ {19.5,38}, {22,42.5}, {21.5,44.5}, {17.5,44.5}, {17,42.5} }
  C.fill(c, d:grow(1):cut(d), F[1])
  C.part(c, d, R.water, { R = 1 }) c:put(18, 42, C.cream)
  C.put(c, { {19,34}, {19,35}, {19,36} }, R.water[5])
  C.save(c, "cloak-1-frond-rain-cape")
end

---------------------------------------------------------------- 2 fleece mantle
do
  local c = C.canvas("cloak-2-fleece-mantle")
  local Fl, Sd = R.fleece, R.suede
  -- bell-shaped shoulder mantle: narrow at the neck, round at the hem
  local m = c:poly{ {24,12}, {40,12}, {50,24}, {56,40}, {8,40}, {14,24} }:add(c:ellipse(32, 40, 24, 10))
  -- lumpy curly hem
  for k = 0, 24 do
    local a = pi * k / 24
    m:add(c:ellipse(32 + cos(a) * 24, 40 + sin(a) * 10, 2, 2))
  end
  -- leather lining peeking at the parted front
  local gap = c:poly{ {32,22}, {36,51}, {28,51} }
  local lin = gap:copy():clip(m)
  m:cut(gap)
  C.part(c, lin, Sd, { R = 1, b = -1 })
  C.vline(c, 32, 26, 50, Sd[1])
  local i = C.part(c, m, Fl, { R = 6, hs = .9, cuts = { .2, .34, .5, .66, .84 } })
  -- curls: little C shapes
  m:each(function(x, y)
    local cx, cy = x % 5, (y + floor(x / 5) * 2) % 5
    local k = i[K(x, y)] or 3
    if (cx == 0 and cy < 3) or (cy == 0 and cx < 3) then c:put(x, y, Fl[max(1, k - 1)]) end
    if cx == 1 and cy == 1 and k < 6 then c:put(x, y, Fl[k + 1]) end
  end)
  -- turned edges along the opening: suede binding
  gap:grow(1):cut(gap):clip(m):each(function(x, y) c:put(x, y, (x < 32) and Sd[5] or Sd[3]) end)
  -- neck hole
  local nk = c:ellipse(32, 13, 8, 2.5)
  C.fill(c, nk, Sd[1]) C.fill(c, c:ellipse(32, 13, 6, 1.5), C.ink)
  nk:grow(1):cut(nk):clip(m):each(function(x, y) if y > 13 then c:put(x, y, Sd[4]) end end)
  -- thong tie at the throat with dangling ends
  C.hline(c, 28, 36, 21, R.strap[3]) C.hline(c, 28, 36, 20, R.strap[5])
  C.ball(c, 32, 21, 1.6, R.strap)
  C.put(c, { {31,23}, {31,24}, {30,25}, {30,26}, {30,27} }, R.strap[4])
  C.put(c, { {33,23}, {33,24}, {34,25}, {34,26}, {35,27} }, R.strap[2])
  C.put(c, { {30,28}, {35,28} }, R.wood[5])
  -- quirk: prickly burr in the curls
  local bx, by = 45, 36
  C.ball(c, bx, by, 2, R.coconut)
  C.put(c, { {bx-3,by}, {bx+3,by}, {bx,by-3}, {bx,by+3}, {bx-2,by-2}, {bx+2,by-2}, {bx-2,by+2}, {bx+2,by+2} }, R.leafwrap[2])
  c:put(bx - 1, by - 1, R.leafwrap[5])
  C.save(c, "cloak-2-fleece-mantle")
end

---------------------------------------------------------------- 3 hibiscus pareo
do
  local c = C.canvas("cloak-3-hibiscus-pareo")
  local Co, Hb = R.coral, R.hibiscus
  -- one-shoulder wrap: diagonal neckline from the right-shoulder knot, wide straight hem
  local front = c:poly{ {40,10}, {47,13}, {52,32}, {54,56}, {10,56}, {10,40}, {16,28} }
  -- loose tail hanging from the knot (behind)
  local tail = c:poly{ {46,12}, {54,16}, {58,34}, {54,38}, {50,22} }
  C.part(c, tail, Hb, { R = 2, b = -1, cuts = CU })
  C.sep(c, front, tail, Co[1])
  local i = C.part(c, front, Co, { R = 5, cuts = CU })
  -- folds radiating down from the knot
  for _, f in ipairs({ { 40, 14, 18, 54 }, { 42, 14, 30, 55 }, { 44, 16, 44, 55 } }) do
    local n = 50
    for k = 0, n do
      local x = floor(f[1] + (f[3] - f[1]) * k / n + .5)
      local y = floor(f[2] + (f[4] - f[2]) * k / n + .5)
      if front:has(x, y) and k > 6 then
        c:put(x, y, Co[max(1, (i[K(x, y)] or 3) - 2)])
        if front:has(x - 1, y) then c:put(x - 1, y, Co[min(6, (i[K(x - 1, y)] or 3) + 1)]) end
      end
    end
  end
  -- printed blossoms: 5 cream petals, pink heart
  local function blossom(px, py)
    for k = 0, 4 do
      local a = k * 2 * pi / 5 - pi / 2
      local q = c:ellipse(px + cos(a) * 2.2, py + sin(a) * 2.2, 1, 1):clip(front)
      C.fill(c, q, R.fleece[6])
    end
    c:put(px, py, Hb[3])
  end
  for _, p in ipairs({ { 22, 34 }, { 16, 47 }, { 32, 42 }, { 26, 52 }, { 44, 30 }, { 40, 48 }, { 34, 24 }, { 49, 44 } }) do blossom(p[1], p[2]) end
  -- hem border band
  for x = 10, 54 do if front:has(x, 55) then c:put(x, 55, Hb[3]) c:put(x, 54, Hb[5]) c:put(x, 56, Hb[2]) end end
  for x = 11, 53, 3 do c:put(x, 54, R.fleece[6]) end
  -- neckline edge highlight
  front:each(function(x, y) if not front:has(x, y - 1) and x < 41 then c:put(x, y, Co[6]) end end)
  -- shoulder knot
  local kn = c:ellipse(44, 12, 4, 3.5)
  C.sep(c, kn, front:copy():add(tail), Co[1])
  C.part(c, kn, Co, { R = 2, b = 1 })
  C.put(c, { {42,11}, {43,10} }, Co[6])
  -- quirk: a real hibiscus tucked in the knot
  local fx, fy = 49, 8
  for k = 0, 4 do
    local a = k * 2 * pi / 5 - pi / 2 + 0.3
    local p = c:ellipse(fx + cos(a) * 3, fy + sin(a) * 3, 2.2, 2.2)
    C.part(c, p, Hb, { R = 1, b = (cos(a) + sin(a) < 0) and 1 or 0 })
  end
  C.fill(c, c:ellipse(fx, fy, 1.2, 1.2), Hb[1])
  C.put(c, { {fx+1,fy-1}, {fx+2,fy-2}, {fx+3,fy-3} }, R.brass[5]) c:put(fx + 3, fy - 4, R.brass[6])
  C.save(c, "cloak-3-hibiscus-pareo")
end

---------------------------------------------------------------- 4 red-dust poncho
do
  local c = C.canvas("cloak-4-red-dust-poncho")
  local O, T, CH = R.ochre, R.tapa, R.charcoal
  local body = c:poly{ {22,10}, {42,10}, {58,34}, {32,52}, {6,34} }
  local i = C.part(c, body, O, { R = 5, cuts = CU })
  -- woven texture
  C.retone(c, body, i, O, function(x, y) if (x + y * 2) % 5 == 0 then return -1 end end)
  -- stripe bands following the chevron (distance from the bottom edges)
  body:each(function(x, y)
    local v = y + abs(x - 32) * 0.9
    local k = i[K(x, y)] or 3
    local band = floor(v) - 30
    if band == 0 or band == 1 then c:put(x, y, T[min(6, k + 1)]) end
    if band == 3 or band == 4 then c:put(x, y, CH[k]) end
    if band == 6 then c:put(x, y, T[min(6, k + 1)]) end
    if band == -14 or band == -13 then c:put(x, y, T[min(6, k)]) end
    if band == -11 and x % 2 == 0 then c:put(x, y, CH[k]) end
  end)
  -- neck opening with a rolled collar
  local col = c:ellipse(32, 12, 9, 4)
  C.part(c, col, O, { R = 2, b = 1 })
  C.fill(c, c:ellipse(32, 12, 5, 2), R.jay[2])
  C.hline(c, 28, 36, 11, C.ink)
  -- fringe tassels along both bottom edges
  for x = 7, 57, 2 do
    local y0
    for y = 63, 0, -1 do if body:has(x, y) then y0 = y break end end
    if y0 then
      local len = 3 + ((x % 4 == 1) and 1 or 0)
      for y = y0 + 1, y0 + len do c:put(x, y, T[(y == y0 + len) and 3 or 5]) end
    end
  end
  -- quirk: sand lizard sitting on the fringe, lower right
  local Lz = R.pandanus
  C.put(c, { {44,47}, {45,46}, {46,45}, {47,44}, {48,43} }, Lz[5])
  C.put(c, { {44,48}, {45,47}, {46,46}, {47,45}, {48,44}, {49,44} }, Lz[3])
  C.put(c, { {50,42}, {51,42}, {51,43}, {50,43}, {49,43} }, Lz[4]) c:put(52, 42, Lz[3])
  c:put(51, 42, C.ink)
  C.put(c, { {43,49}, {42,50}, {41,51}, {40,51} }, Lz[3])
  C.put(c, { {45,49}, {47,47}, {48,46}, {49,46}, {44,45}, {46,43} }, Lz[2])
  c:put(46, 44, Lz[6])
  C.save(c, "cloak-4-red-dust-poncho")
end

---------------------------------------------------------------- 5 storm-petrel hood
do
  local c = C.canvas("cloak-5-storm-petrel-hood")
  local S, J = R.sea, R.jay
  -- cloak body, flaring
  local body = c:poly{ {24,20}, {40,20}, {50,40}, {56,58}, {8,58}, {14,40} }
  local i = C.part(c, body, S, { R = 5, cuts = CU })
  -- long folds
  for _, f in ipairs({ { 22, 14 }, { 28, 26 }, { 37, 39 }, { 43, 50 } }) do
    for y = 26, 57 do
      local x = floor(f[1] + (f[2] - f[1]) * (y - 26) / 31 + .5)
      if body:has(x, y) then c:put(x, y, S[1]) if body:has(x - 1, y) then c:put(x - 1, y, S[min(6, (i[K(x - 1, y)] or 3) + 1)]) end end
    end
  end
  -- wave-stitched hem
  for x = 9, 55 do
    local y = 54 + floor(sin(x * 0.7) * 1.5 + .5)
    if body:has(x, y) then c:put(x, y, R.canvas[(x % 3 == 2) and 3 or 6]) end
  end
  C.hline(c, 9, 55, 57, S[1])
  -- pointed hood up
  local hood = c:poly{ {32,3}, {40,14}, {43,24}, {32,28}, {21,24}, {24,14} }:add(c:ellipse(32, 20, 10, 8))
  C.sep(c, hood, body, S[1])
  local hi = C.part(c, hood, J, { R = 4, b = -1, cuts = CU })
  -- face opening (shadowed)
  local face = c:ellipse(32, 20, 5.5, 5)
  C.fill(c, face, J[1]) C.fill(c, c:ellipse(32, 21, 4, 3.5), C.ink)
  face:grow(1):cut(face):clip(hood):each(function(x, y) c:put(x, y, (x < 32) and J[5] or J[3]) end)
  C.put(c, { {31,4}, {30,6}, {29,8} }, J[6])
  -- quirk: shell clasp with a seahorse charm
  C.ball(c, 32, 29, 2, R.fleece, C.cream)
  C.put(c, { {31,30}, {32,30}, {33,30} }, R.fleece[3])
  local sh = R.coral
  C.vline(c, 32, 32, 33, R.brass[3])
  C.put(c, { {32,34}, {33,34}, {33,35}, {32,35} }, sh[5])
  C.put(c, { {34,34}, {34,35} }, sh[4]) c:put(33, 34, C.ink)
  C.put(c, { {32,36}, {31,37}, {31,38}, {32,39}, {32,40}, {31,41}, {30,41}, {30,40} }, sh[4])
  C.put(c, { {33,36}, {33,37}, {32,38}, {33,39}, {33,40} }, sh[3])
  C.put(c, { {30,37}, {30,38} }, sh[6])
  -- sheen
  C.vline(c, 18, 40, 52, S[6])
  C.save(c, "cloak-5-storm-petrel-hood")
end
