-- coat.lua: OC (Coralscatter) coat concepts, 5 icons (front view, worn over the tunic).
-- Run: AppRun -b --script-param png=<dir>/ --script coat.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R = C.HP, C.X, C.K, C.R
local floor, sin, abs = math.floor, math.sin, math.abs
local CU = { .2, .36, .52, .7, .88 }
local function mirror(pts) local o = {} for i = #pts, 1, -1 do o[#o + 1] = { 64 - pts[i][1], pts[i][2] } end return o end

---------------------------------------------------------------- 1 drover's oilskin
do
  local c = C.canvas("coat-1-drovers-oilskin")
  local O = R.oilskin
  local slL = { {21,18}, {12,26}, {8,48}, {15,49}, {19,30} }
  local sL, sR = c:poly(slL), c:poly(mirror(slL))
  local body = c:poly{ {22,15}, {42,15}, {46,30}, {53,58}, {11,58}, {18,30} }
  C.part(c, sL, O, { R = 3, b = 0, cuts = CU }) C.part(c, sR, O, { R = 3, b = -1, cuts = CU })
  C.sep(c, body, sL:copy():add(sR), O[1])
  local i = C.part(c, body, O, { R = 5, cuts = CU })
  -- front opening + overlap, back vent, hem
  C.vline(c, 33, 30, 57, O[1]) C.vline(c, 32, 30, 57, O[5])
  C.hline(c, 12, 52, 57, O[2])
  -- folds: soft vertical creases
  for _, fx in ipairs({ 22, 42 }) do for y = 36, 56 do c:put(fx + floor((y - 36) / 8) * (fx < 32 and -1 or 1), y, O[2]) end end
  -- cuffs
  C.hline(c, 8, 15, 46, O[2]) C.hline(c, 49, 56, 46, O[1])
  -- shoulder capelet
  local cap = c:ellipse(32, 21, 22, 10):clip(c:rect(0, 13, 63, 63))
  C.sep(c, cap, body:copy():add(sL):add(sR), O[1])
  local ci = C.part(c, cap, O, { R = 4, b = 1, cuts = CU })
  cap:each(function(x, y) if not cap:has(x, y + 1) then c:put(x, y, O[2]) end end)
  -- stand collar
  local col = c:rrect(22, 9, 42, 17, 3)
  C.sep(c, col, cap, O[1])
  C.part(c, col, O, { R = 2, b = 1, cuts = CU })
  local nk = c:ellipse(32, 10, 6, 2)
  C.fill(c, nk, R.jay[2]) C.hline(c, 28, 36, 9, C.ink)
  nk:grow(1):cut(nk):clip(col):each(function(x, y) if y > 10 then c:put(x, y, O[5]) end end)
  C.put(c, { {32,13}, {32,14}, {32,15}, {32,16} }, O[1])
  C.hline(c, 22, 42, 16, O[2])
  -- waxed shine streaks
  C.vline(c, 16, 34, 52, O[6]) C.vline(c, 17, 40, 46, O[5])
  C.vline(c, 11, 30, 40, O[6])
  C.put(c, { {18,17}, {19,17}, {20,16}, {21,16}, {22,15} }, O[6]) c:put(19, 18, C.cream)
  -- brass buttons
  for _, y in ipairs({ 34, 41, 48 }) do C.ball(c, 30, y, 1.2, R.brass) c:put(29, y - 1, R.brass[6]) end
  -- quirk: raindrop running off the capelet edge
  local d = c:poly{ {51.5,29}, {54,33.5}, {53.5,35.5}, {49.5,35.5}, {49,33.5} }
  C.part(c, d, R.water, { R = 1 }) c:put(50, 33, C.cream)
  C.put(c, { {48,25}, {49,26}, {50,27} }, R.water[4])
  C.save(c, "coat-1-drovers-oilskin")
end

---------------------------------------------------------------- 2 bush check smock
do
  local c = C.canvas("coat-2-bush-check-smock")
  local Y, CH = R.yarnA, R.charcoal
  local function check(m, idx)
    C.retone(c, m, idx, Y, function(x, y)
      local a, b = x % 6 < 2, y % 6 < 2
      if a and b then c:put(x, y, CH[math.max(1, idx[K(x, y)] - 1)]) return 0 end
      if a or b then return -2 end
    end)
  end
  -- hood lying behind the neck
  local hood = c:ellipse(32, 14, 11, 7)
  C.part(c, hood, Y, { R = 3, b = -1, cuts = CU })
  C.fill(c, c:ellipse(32, 15, 7, 4), CH[1])
  local slL = { {19,17}, {11,23}, {6,46}, {14,48}, {18,30} }
  local sL, sR = c:poly(slL), c:poly(mirror(slL))
  local body = c:rrect(16, 16, 48, 54, 4)
  local i1 = C.part(c, sL, Y, { R = 3, cuts = CU }) check(sL, i1)
  local i2 = C.part(c, sR, Y, { R = 3, b = -1, cuts = CU }) check(sR, i2)
  C.sep(c, body, sL:copy():add(sR), CH[1])
  local bi = C.part(c, body, Y, { R = 5, cuts = CU }) check(body, bi)
  -- charcoal ribbed cuffs and hem
  for _, cf in ipairs({ c:poly{ {6,43}, {14,45}, {14,49}, {5,47} }, c:poly(mirror({ {6,43}, {14,45}, {14,49}, {5,47} })) }) do
    C.part(c, cf, CH, { R = 1 })
    cf:each(function(x, y) if x % 2 == 0 then c:put(x, y, CH[2]) end end)
  end
  local hem = c:rrect(16, 50, 48, 55, 2)
  C.part(c, hem, CH, { R = 1, b = 1 })
  hem:each(function(x, y) if x % 2 == 0 then c:put(x, y, CH[2]) end end)
  -- laced V neck
  local vn = c:poly{ {26,15}, {38,15}, {32,28} }
  C.fill(c, vn, R.jay[3])
  C.fill(c, c:poly{ {28,15}, {36,15}, {32,22} }, R.jay[2])
  vn:grow(1):cut(vn):clip(body):each(function(x, y) c:put(x, y, CH[2]) end)
  C.put(c, { {29,18}, {30,19}, {31,20}, {34,18}, {33,19}, {32,20}, {30,22}, {31,23}, {33,22}, {32,23}, {31,26} }, R.tapa[6])
  C.put(c, { {31,27}, {33,27}, {30,28}, {34,29} }, R.tapa[5])
  -- big front pocket
  local pk = c:rrect(21, 36, 43, 48, 3)
  pk:grow(1):cut(pk):clip(body):each(function(x, y) c:put(x, y, CH[1]) end)
  local pi2 = C.part(c, pk, Y, { R = 2, b = 1, cuts = CU }) check(pk, pi2)
  C.hline(c, 22, 42, 36, Y[6])
  -- quirk: a fishing fly hooked on the pocket corner
  C.put(c, { {42,33}, {43,33}, {44,34}, {44,35}, {43,36} }, R.steel[5])
  c:put(42, 34, R.steel[3])
  C.put(c, { {41,30}, {40,29}, {41,31}, {40,31} }, R.brass[5])
  C.put(c, { {39,30}, {39,31}, {38,30} }, R.turtle[5])
  C.put(c, { {40,32}, {41,32} }, R.ember[4]) c:put(42, 32, R.ember[3])
  C.save(c, "coat-2-bush-check-smock")
end

---------------------------------------------------------------- 3 bark-cloth vest
do
  local c = C.canvas("coat-3-bark-cloth-vest")
  local T, O = R.tapa, R.ochre
  local half = { {22,10}, {28,10}, {31,30}, {31,54}, {14,54}, {14,30}, {16,24}, {21,21} }
  local L = c:poly(half)
  local Rt = c:poly(mirror(half))
  local back = c:poly{ {28,10}, {36,10}, {34,26}, {30,26} }
  C.part(c, back, T, { R = 1, b = -2 })
  C.fill(c, c:poly{ {29,14}, {35,14}, {32,30} }, R.jay[3])
  for _, side in ipairs({ { L, 0 }, { Rt, -1 } }) do
    local m = side[1]
    local i = C.part(c, m, T, { R = 4, b = side[2], cuts = CU })
    -- beaten-bark fibre streaks
    C.retone(c, m, i, T, function(x, y) if X.hash(x, floor(y / 3), 8) < .12 then return -1 end end)
    -- stamped bands: triangles row and dot row
    m:each(function(x, y)
      local k = i[K(x, y)] or 3
      local tone = (k >= 4) and 3 or 2
      if y >= 34 and y <= 37 and abs((x % 6) - 2.5) < (y - 34) + 0.6 then c:put(x, y, O[tone]) end
      if y == 38 or y == 33 then c:put(x, y, O[tone]) end
      if y == 45 and x % 3 == 0 then c:put(x, y, O[tone + 1]) end
      if y == 49 or y == 52 then c:put(x, y, O[tone]) end
      if y >= 50 and y <= 51 and x % 4 < 2 then c:put(x, y, O[tone + 1]) end
    end)
  end
  -- front gap
  C.vline(c, 31, 30, 54, T[1]) C.vline(c, 32, 30, 54, T[2])
  -- armhole edges, binding
  for _, m in ipairs({ L, Rt }) do m:edge():each(function(x, y) if y < 30 then c:put(x, y, O[x < 32 and 3 or 2]) end end) end
  -- cord ties
  for _, y in ipairs({ 32, 40 }) do
    C.put(c, { {29,y}, {30,y}, {31,y}, {32,y}, {33,y}, {34,y} }, R.coir[4])
    C.put(c, { {32,y+1}, {31,y+2}, {33,y+1}, {34,y+2} }, R.coir[3])
  end
  -- quirk: frangipani pinned at the chest
  local fx, fy = 22, 26
  for k = 0, 4 do
    local a = k * 2 * math.pi / 5 - math.pi / 2
    local m = c:ellipse(fx + math.cos(a) * 3.4, fy + math.sin(a) * 3.4, 2.1, 2.1)
    C.sep(c, m, c:rect(0, 0, 63, 63), T[1])
    C.part(c, m, R.fleece, { R = 1, b = 2 })
  end
  C.fill(c, c:ellipse(fx, fy, 1.4, 1.4), R.brass[4]) C.put(c, { {fx,fy}, {fx-1,fy-1} }, R.brass[6])
  c:put(fx - 2, fy - 2, C.cream)
  C.save(c, "coat-3-bark-cloth-vest")
end

---------------------------------------------------------------- 4 reef sail-cloth jerkin
do
  local c = C.canvas("coat-4-reef-sail-cloth-jerkin")
  local S, Cv = R.sea, R.canvas
  local sL, sR = c:ellipse(15, 24, 7, 8), c:ellipse(49, 24, 7, 8)
  local body = c:rrect(17, 15, 47, 50, 5)
  local quilt = function(x, y) if (x + y) % 6 == 0 or (x - y + 600) % 6 == 0 then return -1 end end
  local i1 = C.part(c, sL, S, { R = 3, cuts = CU }) C.retone(c, sL, i1, S, quilt)
  local i2 = C.part(c, sR, S, { R = 3, b = -1, cuts = CU }) C.retone(c, sR, i2, S, quilt)
  C.sep(c, body, sL:copy():add(sR), S[1])
  local bi = C.part(c, body, S, { R = 6, hs = .8, cuts = CU })
  C.retone(c, body, bi, S, quilt)
  -- quilt puffs: light dot in each diamond centre
  body:each(function(x, y) if (x + y) % 6 == 3 and (x - y + 600) % 6 == 3 and x < 34 then c:put(x, y, S[6]) end end)
  -- rope edging: helper for twisted rope band
  local function rope(m)
    m:each(function(x, y) local t = (x + y) % 4 c:put(x, y, Cv[t == 0 and 2 or (t == 1 and 6 or (t == 2 and 5 or 4))]) end)
  end
  -- sleeve rope cuffs
  rope(c:ellipse(15, 24, 7, 8):clip(c:rect(0, 30, 63, 32)))
  rope(c:ellipse(49, 24, 7, 8):clip(c:rect(0, 30, 63, 32)))
  -- hem rope
  local hem = c:rrect(16, 47, 48, 51, 2)
  rope(hem)
  -- stand collar of rope
  local col = c:line({ {23,14}, {26,17}, {32,18}, {38,17}, {41,14} }, 3)
  C.fill(c, c:poly{ {26,13}, {38,13}, {32,18} }, R.tapa[4])
  rope(col)
  -- front opening and rope toggles
  C.vline(c, 32, 19, 46, S[1]) C.vline(c, 31, 19, 46, S[5])
  for _, y in ipairs({ 25, 33, 41 }) do
    local tg = c:rect(28, y, 36, y + 1)
    rope(tg)
    c:put(36, y + 1, Cv[2])
  end
  -- quirk: one iridescent shell button (abalone-like) on the chest
  local pb = c:ellipse(23, 23, 3, 3)
  C.fill(c, pb:grow(1), S[1])
  pb:each(function(x, y)
    local t = (x * 2 + y * 3) % 7
    c:put(x, y, R.paua[({ 2, 3, 4, 5, 3, 4, 2 })[t + 1]])
  end)
  C.put(c, { {21,21}, {22,21} }, R.paua[6]) c:put(21, 22, R.paua[5]) C.put(c, { {25,25}, {24,26} }, R.paua[1])
  C.save(c, "coat-4-reef-sail-cloth-jerkin")
end

---------------------------------------------------------------- 5 gum-dyed cardigan
do
  local c = C.canvas("coat-5-gum-dyed-cardigan")
  local G = R.gum
  local sL, sR = c:rrect(8, 17, 17, 52, 3), c:rrect(47, 17, 56, 52, 3)
  local body = c:rrect(16, 13, 48, 56, 4)
  local knit = function(x, y) if x % 3 == 1 and y % 2 == 0 then return -1 end end
  local i1 = C.part(c, sL, G, { R = 3, cuts = CU }) C.retone(c, sL, i1, G, knit)
  local i2 = C.part(c, sR, G, { R = 3, b = -1, cuts = CU }) C.retone(c, sR, i2, G, knit)
  C.sep(c, body, sL:copy():add(sR), G[1])
  local bi = C.part(c, body, G, { R = 5, cuts = CU }) C.retone(c, body, bi, G, knit)
  -- tunic showing in the V
  C.fill(c, c:poly{ {25,12}, {39,12}, {32,36} }, R.jay[3])
  C.fill(c, c:poly{ {28,12}, {36,12}, {32,24} }, R.jay[2])
  -- shawl collar lapels
  local lap = { {22,12}, {27,12}, {33,37}, {29,37}, {19,22} }
  local lL, lR = c:poly(lap), c:poly(mirror(lap))
  for _, l in ipairs({ { lL, 1 }, { lR, -1 } }) do
    l[1]:grow(1):cut(l[1]):clip(body):each(function(x, y) c:put(x, y, G[1]) end)
    local li = C.part(c, l[1], G, { R = 2, b = l[2], cuts = CU })
    C.retone(c, l[1], li, G, function(x, y) if (x + y) % 3 == 0 then return -1 end end)
  end
  -- ribbed cuffs and hem
  local rib = function(m, b) C.part(c, m, G, { R = 1, b = b }) m:each(function(x, y) if x % 2 == 0 then c:put(x, y, G[2]) end end) end
  rib(c:rrect(8, 47, 17, 53, 2), 0) rib(c:rrect(47, 47, 56, 53, 2), -1) rib(c:rrect(16, 50, 48, 56, 2), 0)
  -- front opening below the collar
  C.vline(c, 32, 37, 50, G[1])
  -- patch pockets
  for _, px in ipairs({ 19, 36 }) do
    local pk = c:rect(px, 39, px + 9, 47)
    pk:edge():each(function(x, y) if y > 39 then c:put(x, y, G[2]) end end)
    C.hline(c, px, px + 9, 39, G[5])
  end
  -- quirk: gum-nut buttons and a gum leaf in the left pocket
  for _, y in ipairs({ 40, 46 }) do
    C.ball(c, 30, y, 1.6, R.coconut)
    C.put(c, { {29,y-1}, {30,y-1} }, R.coconut[6]) c:put(30, y, R.coconut[1])
  end
  local leaf = C.G.blade(24, 40, 18, 36, 13, 30, function(t) return math.max(0, 2.2 * math.sin(math.pi * t)) end)
  C.fill(c, leaf:grow(1):cut(leaf), C.ink)
  C.fill(c, leaf, R.turtle[4])
  leaf:each(function(x, y) if not leaf:has(x - 1, y) or not leaf:has(x, y - 1) then c:put(x, y, R.turtle[6]) end end)
  C.put(c, { {22,39}, {19,36}, {17,34}, {15,32} }, R.turtle[2])
  C.put(c, { {24,40}, {25,40} }, R.ochre[3])
  -- wool highlight
  C.put(c, { {11,20}, {11,21}, {18,16}, {19,16} }, G[6])
  C.save(c, "coat-5-gum-dyed-cardigan")
end
