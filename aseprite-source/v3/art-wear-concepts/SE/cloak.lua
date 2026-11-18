-- cloak.lua: Olivewhistle Shore (SE) cloak concepts, 5 icons 64x64.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, W, G = C.HP, C.X, C.K, C.R, C, C.G
local ink, cream = C.ink, C.cream
local only = app.params.only
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local function mirror(m) local n = HP.mask() m:each(function(x, y) n:set(63 - x, y) end) return n end

-- 1 Shepherd's Felt Cape ------------------------------------------------------------
local function k1()
  local c = C.canvas("cloak-1-shepherd-felt-cape")
  local cape = c:poly{ {23,18}, {41,18}, {47,30}, {53,52}, {50,58}, {14,58}, {11,52}, {17,30} }
  local hood = c:poly{ {32,2}, {37,6}, {42,13}, {44,22}, {20,22}, {22,13}, {27,6} }
  local ci = C.part(c, cape, R.felt, { R = 7, hs = 0.6, tex = C.felt })
  -- bell folds
  for _, l in ipairs({ { {26,26}, {20,57} }, { {38,26}, {44,57} }, { {29,30}, {27,57} } }) do
    c:line(l, 1):each(function(x, y) if cape:has(x, y) then c:put(x, y, R.felt[2]) c:put(x - 1, y, R.felt[5]) end end)
  end
  -- front opening
  for y = 24, 57 do c:put(33, y, R.felt[1]) c:put(34, y, R.felt[2]) end
  -- stitched hem
  for x = 13, 51 do c:put(x, 55, (x % 3 == 0) and R.cuffL[6] or R.felt[2]) end
  W.sep(c, hood, cape, R.felt[1])
  C.part(c, hood, R.felt, { R = 5, b = 1, tex = C.felt })
  -- face opening (dark), lit rim
  local face = c:ellipse(32, 16, 6, 5):clip(c:rect(20, 10, 44, 21))
  c:fillMask(face, R.felt[1])
  face:grow(1):cut(face):clip(hood):each(function(x, y) c:put(x, y, (x < 32) and R.felt[6] or R.felt[3]) end)
  -- hood centre seam
  W.vline(c, 32, 3, 9, R.felt[2])
  -- brass clasp
  local cl = c:ellipse(32, 23, 2.5, 2)
  C.part(c, cl, R.brass, { R = 1 }) c:put(31, 22, R.brass[6])
  -- quirk: rosemary sprig at the clasp
  local stem = c:line({ {35,24}, {39,28}, {42,33} }, 1)
  c:fillMask(stem, R.wood[2])
  for _, p in ipairs({ {36,23}, {37,24}, {38,25}, {39,26}, {40,28}, {41,29}, {42,31}, {43,32} }) do c:put(p[1] + 1, p[2] - 1, R.sage[5]) c:put(p[1] - 1, p[2] + 1, R.sage[3]) end
  W.put(c, { {40,26}, {44,31} }, R.lav[4]) c:put(40, 25, R.lav[5])
  -- felt sheen
  W.put(c, { {26,8}, {25,9}, {24,11} }, R.felt[6]) c:put(19, 33, R.felt[6])
  C.save(c, "cloak-1-shepherd-felt-cape")
end

-- 2 Lemon-Fringe Shawl --------------------------------------------------------------
local function k2()
  local c = C.canvas("cloak-2-lemon-fringe-shawl")
  local sh = c:poly{ {5,14}, {32,17}, {59,14}, {54,22}, {34,47}, {30,47}, {10,22} }
  local si = C.part(c, sh, R.lemon, { R = 6, hs = 0.6, tex = C.weave })
  -- fold of the top edge, rolled over
  local roll = c:poly{ {5,14}, {32,17}, {59,14}, {57,18}, {32,21}, {7,18} }
  C.part(c, roll, R.lemon, { R = 1, b = 1 })
  for x = 8, 56 do local y = 21 + floor(abs(x - 32) * -0.11 + 0.5) if sh:has(x, y + 1) then c:put(x, y + 1, R.lemon[2]) end end
  -- woven saffron band parallel to the lower edges + dot pattern
  sh:each(function(x, y)
    local d = abs(x - 32) * 1.25 + y
    if y > 22 and d > 41 and d < 44 then c:put(x, y, R.saffron[max(1, min(6, si[K(x, y)] - 1))]) end
    if y > 23 and d < 36 and (x % 4 == 0) and (y % 4 == 2) then c:put(x, y, R.saffron[3]) end
  end)
  -- fringe along the two lower edges
  local fr = HP.mask()
  for x = 11, 53, 2 do
    local y0
    for y = 47, 14, -1 do if sh:has(x, y) then y0 = y break end end
    if y0 and y0 > 21 then fr:add(c:line({ {x, y0 + 1}, {x + ((x < 32) and -1 or 1), y0 + 5} }, 1)) end
  end
  fr:add(c:line({ {32,48}, {32,54} }, 1)):add(c:line({ {31,48}, {30,53} }, 1)):add(c:line({ {33,48}, {34,53} }, 1))
  fr:cut(sh)
  fr:each(function(x, y) c:put(x, y, (x < 32) and R.lemon[4] or R.saffron[3]) end)
  -- quirk: a bee resting on the shawl
  local bb = c:ellipse(42, 27, 3, 2)
  local wings = c:ellipse(41, 23, 1.2, 1.5):add(c:ellipse(44, 24, 1.2, 1.2))
  W.sep(c, bb:copy():add(wings), sh, R.lemon[1])
  c:fillMask(wings, R.sea[6]) c:put(40, 22, cream)
  C.part(c, bb, R.saffron, { R = 1, b = 1 })
  W.vline(c, 42, 25, 29, R.wood[1]) W.vline(c, 44, 26, 28, R.wood[1])
  c:put(39, 27, R.wood[1]) c:put(40, 26, R.saffron[6])
  -- sheen
  W.put(c, { {12,16}, {13,16}, {14,16} }, R.lemon[6]) c:put(11, 16, cream)
  C.save(c, "cloak-2-lemon-fringe-shawl")
end

-- 3 Loom-Stripe Poncho --------------------------------------------------------------
local function k3()
  local c = C.canvas("cloak-3-loom-stripe-poncho")
  local p = c:poly{ {24,10}, {40,10}, {57,30}, {57,52}, {7,52}, {7,30} }
  local idx = C.part(c, p, R.linen, { R = 6, hs = 0.6, tex = C.weave })
  local bands = { { 14, R.terra }, { 18, R.terra }, { 22, R.saffron }, { 24, R.olive }, { 25, R.olive }, { 32, R.terra }, { 33, R.terra },
    { 34, R.terra }, { 35, R.saffron }, { 40, R.olive }, { 41, R.olive }, { 45, R.terra }, { 46, R.terra }, { 47, R.terra }, { 48, R.terra }, { 49, R.terra }, { 50, R.terra }, { 51, R.terra } }
  local by = {} for _, b in ipairs(bands) do by[b[1]] = b[2] end
  for y = 12, 13 do by[y] = R.terra end
  p:each(function(x, y)
    local rmp = by[y]
    if rmp then c:put(x, y, rmp[max(1, min(6, idx[K(x, y)]))]) end
    if y == 29 and x % 3 == 0 then c:put(x, y, R.terra[3]) end
  end)
  -- drape folds
  for _, l in ipairs({ { {20,20}, {17,51} }, { {44,20}, {47,51} } }) do
    c:line(l, 1):each(function(x, y) if p:has(x, y) then c:put(x, y, R.linen[2]) end end)
  end
  -- neck slit with a rolled collar
  local col = c:rrect(24, 7, 40, 13, 3)
  C.part(c, col, R.terra, { R = 2 })
  local slit = c:rrect(27, 9, 37, 11, 1):add(c:rect(31, 11, 33, 17))
  c:fillMask(slit, R.terra[1])
  W.hline(c, 28, 36, 9, R.terra[2])
  -- bottom fringe + corner tassels
  local fr = HP.mask()
  for x = 9, 55, 2 do fr:add(c:line({ {x,53}, {x,55} }, 1)) end
  for _, tx in ipairs({ 7, 57 }) do fr:add(c:line({ {tx,53}, {tx - 1,59} }, 1)):add(c:line({ {tx,53}, {tx,59} }, 1)):add(c:line({ {tx,53}, {tx + 1,59} }, 1)) end
  fr:each(function(x, y) c:put(x, y, (y > 55) and R.saffron[3] or R.terra[3]) end)
  for _, tx in ipairs({ 7, 57 }) do c:put(tx, 53, R.terra[1]) c:put(tx, 54, R.saffron[5]) end
  -- quirk: gull feather tucked at the neck
  local fe = G.blade(25, 12, 20, 4, 19, -1, function(t) return 1.6 * math.sin(math.pi * min(1, t * 1.05 + 0.05)) end)
  local fi = C.part(c, fe, R.fleece, { R = 1, b = 1 })
  local q = c:line({ {25,12}, {21,5}, {19,0 + 0} }, 1)
  q:clip(fe):each(function(x, y) c:put(x, y, R.steel[3]) end)
  c:put(19, 0, R.steel[2]) c:put(20, 1, R.steel[2])
  C.save(c, "cloak-3-loom-stripe-poncho")
end

-- 4 Whitewash Sun Mantle --------------------------------------------------------------
local function k4()
  local c = C.canvas("cloak-4-whitewash-mantle")
  local m = c:poly{ {25,10}, {39,10}, {48,18}, {51,32}, {53,56}, {11,56}, {13,32}, {16,18} }
  -- scalloped hem
  for x = 12, 52, 6 do m:add(c:ellipse(x + 3, 56, 3, 2.5):clip(c:rect(0, 56, 63, 63))) end
  m:clip(c:rect(12, 0, 53, 63))
  local mi = C.part(c, m, R.linen, { R = 6, hs = 0.5, tex = C.linen })
  -- long folds
  for _, l in ipairs({ { {22,22}, {19,57} }, { {42,22}, {45,57} }, { {27,30}, {26,58} }, { {38,30}, {39,58} } }) do
    c:line(l, 1):each(function(x, y) if m:has(x, y) then c:put(x, y, R.linen[3]) c:put(x - 1, y, R.linen[6]) end end)
  end
  -- front opening edges
  for y = 20, 58 do if m:has(32, y) then c:put(32, y, R.linen[1]) c:put(33, y, R.linen[2]) end end
  -- indigo border on the scalloped hem
  m:each(function(x, y) if y >= 54 and not m:has(x, y + 1) then c:put(x, y, R.indigo[3]) if m:has(x, y - 1) then c:put(x, y - 1, R.indigo[4]) end end end)
  -- hood lying back on the shoulders
  local hood = c:ellipse(32, 14, 13, 6)
  W.sep(c, hood, m, R.linen[2])
  local hi = C.part(c, hood, R.linen, { R = 3, b = 1, tex = C.linen })
  -- hood folds radiating from the neck
  for _, l in ipairs({ { {27,14}, {22,19} }, { {37,14}, {42,19} }, { {32,15}, {32,20} } }) do c:line(l, 1):each(function(x, y) if hood:has(x, y) then c:put(x, y, R.linen[3]) end end) end
  local neck = c:ellipse(32, 11, 5, 2)
  c:fillMask(neck, R.linen[1])
  neck:grow(1):cut(neck):clip(hood):each(function(x, y) c:put(x, y, (y > 11) and R.linen[6] or R.linen[3]) end)
  -- cord ties
  local cord = c:line({ {30,22}, {28,27}, {29,31} }, 1):add(c:line({ {34,22}, {36,27}, {35,32} }, 1))
  c:fillMask(cord, R.indigo[3])
  c:put(29, 31, R.indigo[5]) c:put(35, 32, R.indigo[4])
  -- quirk: indigo swallow stitched near the hem
  W.put(c, { {40,44}, {41,45}, {42,45}, {43,46}, {44,45}, {45,45}, {46,44}, {43,47}, {43,48}, {42,49}, {44,49} }, R.indigo[3])
  W.put(c, { {42,46}, {43,45} }, R.indigo[1]) c:put(44, 46, R.coral[4])
  -- sheen
  W.put(c, { {21,10}, {22,9}, {23,9} }, cream)
  C.save(c, "cloak-4-whitewash-mantle")
end

-- 5 Sea-Squall Capelet --------------------------------------------------------------
local function k5()
  local c = C.canvas("cloak-5-sea-squall-capelet")
  local cape = c:ellipse(32, 30, 25, 24):clip(c:rect(0, 20, 63, 50))
  -- wavy hem (drape)
  for x = 7, 57 do local w = floor(1.5 + 1.5 * math.sin(x * 0.55)) for y = 48 - w + 1, 50 do cape.s[K(x, y)] = nil end end
  local ci, cn = C.part(c, cape, R.indigo, { R = 8, hs = 0.8 })
  -- radiating folds from the collar
  for _, a in ipairs({ -0.9, -0.45, 0.45, 0.9 }) do
    local ex, ey = 32 + math.sin(a) * 30, 25 + math.cos(a) * 26
    c:line({ {32 + math.sin(a) * 8, 25 + math.cos(a) * 5}, {ex, ey} }, 1):each(function(x, y)
      if cape:has(x, y) then c:put(x, y, R.indigo[2]) if cape:has(x - 1, y) then c:put(x - 1, y, R.indigo[min(6, (ci[K(x - 1, y)] or 3) + 1)]) end end
    end)
  end
  -- waxed glints on the lit shoulder
  W.put(c, { {14,30}, {15,29}, {16,28}, {17,27}, {18,27} }, R.indigo[6]) c:put(15, 30, cream)
  -- front opening
  for y = 26, 48 do if cape:has(32, y) then c:put(32, y, R.indigo[1]) end end
  -- high stand collar
  local col = c:rrect(23, 12, 41, 24, 3)
  W.sep(c, col, cape, R.indigo[1])
  C.vc(c, col, R.indigo, 23, 41, { b = 1 })
  local inside = c:ellipse(32, 13, 6, 1.5)
  c:fillMask(inside, R.indigo[1])
  W.hline(c, 24, 40, 15, R.indigo[5])
  W.vline(c, 32, 16, 24, R.indigo[1])
  -- quirk: coral bead toggle on a cord loop
  local loop = c:line({ {33,19}, {37,19}, {37,22}, {33,22} }, 1)
  c:fillMask(loop, R.jute[4])
  local bead = c:ellipse(29.5, 21, 2.5, 2)
  C.part(c, bead, R.coral, { R = 1, b = 1 })
  c:put(28, 20, R.coral[6]) c:put(29, 20, cream) c:put(31, 22, R.coral[2])
  C.save(c, "cloak-5-sea-squall-capelet")
end

local all = { k1, k2, k3, k4, k5 }
for i, f in ipairs(all) do if not only or tonumber(only) == i then f() end end
