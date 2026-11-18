-- WCA backpack concepts (5). Run: AppRun -b --script-param png=<dir>/ --script backpack.lua [--script-param only=<name>]
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local ink, cream = C.ink, C.cream
local floor, abs = math.floor, math.abs

-- 1. Calabash Pack: round gourd with cut lid, knotted cord net. quirk: hornbill feather
local function calabash(c)
  local cx, cy, r = 31, 36, 18
  -- shoulder straps peeking out behind
  local st = c:line({ {14,22}, {11,34}, {14,48} }, 3):add(c:line({ {48,22}, {51,34}, {48,48} }, 3))
  C.lay(c, st, R.strap, { R = 1, bias = -1 })
  local g = c:ellipse(cx, cy, r, r - 1)
  C.sep(c, g, st, ink)
  local n = X.sphere(cx - 0.5, cy - 0.5, r, g)
  local idx = C.toneN(c, g, n, R.calabash, { cuts = { .2, .36, .52, .68, .86 } })
  -- lid seam: shallow curve, lid above slightly lighter
  for x = cx - r, cx + r do
    local y = floor(cy - 9 + ((x - cx) / r) ^ 2 * 3 + 0.5)
    if g:has(x, y) then c:put(x, y, R.calabash[1]) if g:has(x, y - 1) then c:put(x, y - 1, R.calabash[6]) end end
  end
  -- stem knob
  local stem = c:rrect(cx - 2, cy - r - 4, cx + 1, cy - r + 1, 1)
  C.sep(c, stem, g, ink)
  C.lay(c, stem, R.forest, { R = 1 })
  -- carved band of dots below the lid
  for x = cx - r + 3, cx + r - 3, 3 do
    local y = floor(cy - 5 + ((x - cx) / r) ^ 2 * 3 + 0.5)
    if g:has(x, y) then c:put(x, y, R.calabash[2]) c:put(x + 1, y, R.calabash[2]) end
  end
  -- cord net: diamond lattice on the lower half
  local net = HP.mask()
  for k = -40, 40, 7 do
    net:add(c:line({ {cx + k - 20, cy - 2}, {cx + k + 20, cy + 22} }, 1))
    net:add(c:line({ {cx + k + 20, cy - 2}, {cx + k - 20, cy + 22} }, 1))
  end
  net:clip(g):each(function(x, y) if y >= cy - 2 then c:put(x, y, R.strap[(x < cx - 4 and y < cy + 8) and 5 or 3]) end end)
  for x = cx - r + 1, cx + r - 1 do if g:has(x, cy - 2) then c:put(x, cy - 2, R.strap[2]) end end
  -- knots where the lattice meets the top cord
  for x = cx - r + 3, cx + r - 3, 7 do if g:has(x, cy - 2) then c:put(x, cy - 2, R.strap[5]) end end
  -- gloss
  C.put(c, { {cx-10,cy-12}, {cx-9,cy-13}, {cx-11,cy-11} }, R.calabash[6]) c:put(cx - 9, cy - 12, cream)
  -- quirk: hornbill feather tucked into the net, upper right
  local fp = { {cx+8,cy+2}, {cx+12,cy-8}, {cx+17,cy-16}, {cx+23,cy-22} }
  local fm0 = G.tube(fp, function(t) return 0.8 + 3.0 * math.sin(math.pi * math.min(1, t * 1.05)) end)
  C.sep(c, fm0, g, ink)
  local fm, fi, T, S = C.tube(c, fp, function(t) return 0.8 + 3.0 * math.sin(math.pi * math.min(1, t * 1.05)) end, R.grey, { bias = -2 })
  fm:each(function(x, y) if T[K(x, y)] > 0.7 then c:put(x, y, R.cotton[S[K(x, y)] < 0 and 6 or 4]) end end)
  fm:each(function(x, y) if abs(S[K(x, y)]) < 0.2 then c:put(x, y, R.cotton[T[K(x, y)] > 0.7 and 3 or 2]) end end)
end

-- 2. Raffia Cone Basket: tall tapering basket, coiled rim, shoulder bands. quirk: cocoa pod
local function cone(c)
  local body = c:poly{ {12,17}, {51,17}, {40,54}, {23,54} }:add(c:ellipse(31.5, 53, 8, 3))
  -- cocoa pod and leaves behind the rim
  local leaf1 = c:poly{ {22,16}, {16,6}, {19,5}, {26,15} }
  C.lay(c, leaf1, R.forest, { R = 1 })
  C.vline(c, 20, 7, 13, R.forest[2])
  local pod = C.oval(36, 10, 5, 8.5, 0.35)
  local _, pi = C.ovalLit(c, 36, 10, 5, 8.5, 0.35, R.palm, {})
  C.retone(c, pod, pi, R.palm, function(x, y) if (x * 2 - y) % 5 == 0 then return -1 end end)
  C.put(c, { {33,5}, {34,4} }, R.palm[6])
  c:put(40, 1, R.forest[3]) c:put(40, 2, R.forest[3])
  local rim = c:rrect(9, 13, 54, 20, 3)
  C.sep(c, rim, pod:copy():add(leaf1), ink)
  -- body coils
  local bi = C.lay(c, body, R.raffia, { R = 6, cuts = { .22, .4, .56, .72, .88 } })
  C.retone(c, body, bi, R.raffia, function(x, y, i)
    if y % 3 == 0 then return -1 end
    if y % 3 == 1 and (x + (y // 3) * 2) % 4 == 0 then return -1 end
  end)
  -- dyed palm-orange band and a zig-zag
  local band = c:rect(0, 33, 63, 38):clip(body)
  band:each(function(x, y) local i = bi[K(x, y)] c:put(x, y, R.palm[math.max(1, math.min(6, i))]) end)
  band:each(function(x, y) if (y == 35 + ((x // 2) % 2)) then c:put(x, y, R.kente[5]) end end)
  -- rim coil
  C.retone(c, rim, C.lay(c, rim, R.raffia, { R = 2, bias = 1 }), R.raffia, function(x, y) if (x + y) % 3 == 0 then return -1 end end)
  C.hline(c, 11, 52, 20, R.raffia[1])
  -- shoulder bands going over the rim
  for _, sx in ipairs({ 19, 40 }) do
    local sb = c:poly{ {sx,12}, {sx+4,12}, {sx+4-1,46}, {sx+1,46} }
    C.lay(c, sb, R.strap, { R = 1 })
    C.vline(c, sx + 1, 13, 45, R.strap[5])
    c:put(sx + 2, 30, R.brass[5]) c:put(sx + 2, 31, R.brass[3])
  end
  c:put(15, 22, R.raffia[6]) c:put(16, 22, R.raffia[6])
end

-- 3. Indigo Bundle: knotted cloth bundle with resist dots on a carry stick. quirk: chameleon
local function bundle(c)
  local body = C.oval(31, 38, 20, 15, 0)
  local earL = c:poly{ {22,26}, {14,13}, {19,12}, {29,24} }
  local earR = c:poly{ {34,24}, {44,10}, {49,13}, {40,27} }
  local stick = c:rrect(4, 22, 59, 25, 1)
  C.lay(c, earL, R.indigo, { R = 2, bias = -1 })
  C.lay(c, earR, R.indigo, { R = 2, bias = -1 })
  C.sep(c, stick, earL:copy():add(earR), ink)
  C.lay(c, stick, R.mahogany, { R = 1 })
  C.hline(c, 5, 58, 22, R.mahogany[6]) C.hline(c, 5, 58, 25, R.mahogany[2])
  for x = 9, 56, 11 do c:put(x, 23, R.mahogany[2]) end
  C.sep(c, body, stick:copy():add(earL):add(earR), ink)
  local _, bi = C.ovalLit(c, 31, 38, 20, 15, 0, R.indigo, { cuts = { .2, .36, .52, .7, .88 } })
  -- folds radiating from the knot
  for _, f in ipairs({ { {31,27}, {18,40}, {16,47} }, { {31,27}, {30,42}, {27,51} }, { {32,27}, {42,38}, {47,46} } }) do
    c:line(f, 1):clip(body):each(function(x, y) c:put(x, y, R.indigo[math.max(1, (bi[K(x, y)] or 3) - 2)]) end)
  end
  -- resist dots: small rings on a staggered grid
  for gy = 30, 52, 6 do for gx = 12, 52, 7 do
    local x, y = gx + ((gy // 6) % 2) * 3, gy
    if body:shrink(1):has(x, y) and body:shrink(1):has(x + 1, y + 1) then
      local i = bi[K(x, y)] or 3
      local col = i >= 4 and R.cotton[6] or R.cotton[4]
      c:put(x, y, col) c:put(x + 1, y, col) c:put(x, y + 1, col) c:put(x + 1, y + 1, R.indigo[1])
    end
  end end
  -- knot
  local kn = c:ellipse(31, 26, 4.5, 3.5)
  C.lay(c, kn, R.indigo, { R = 2, bias = 1 })
  c:put(29, 24, R.indigo[6]) C.hline(c, 28, 34, 29, R.indigo[1])
  -- ear dots
  c:put(19, 17, R.cotton[5]) c:put(43, 15, R.cotton[4])
  -- quirk: chameleon walking along the carry stick, tail curled
  local chb = C.oval(11, 17, 5, 3.2, 0)
  local hd = c:poly{ {14,13}, {19,15.5}, {20,19}, {14,21} }
  local tl = c:line({ {7,18}, {5,17}, {3,15}, {3,13}, {4,12}, {6,12}, {6,14}, {5,14} }, 1)
  local all = chb:copy():add(hd):add(tl)
  C.sep(c, all, c:rect(0, 0, 63, 63), ink)
  C.ovalLit(c, 11, 17, 5, 3.2, 0, R.plantain, { bias = 1 })
  C.lay(c, hd, R.plantain, { R = 1, bias = 1 })
  tl:each(function(x, y) c:put(x, y, R.plantain[4]) end)
  C.put(c, { {7,15}, {9,14}, {11,14}, {13,14}, {15,14} }, R.plantain[6])
  C.hline(c, 7, 14, 20, R.plantain[2])
  C.put(c, { {17,16}, {18,16}, {17,17}, {18,17} }, R.kente[5]) c:put(18, 17, ink)
  C.put(c, { {8,21}, {9,21}, {13,21}, {14,21} }, R.forest[2])
  C.put(c, { {10,17}, {12,18} }, R.palm[4])
end

-- 4. Tooled Satchel: red leather, pointed ochre flap with zig-zag tooling, fringe. quirk: brass beads
local function satchel(c)
  local strap = c:line({ {16,22}, {18,10}, {26,5}, {38,5}, {46,10}, {48,22} }, 3)
  C.lay(c, strap, R.redleather, { R = 1, bias = -1 })
  local body = c:rrect(12, 18, 52, 46, 4)
  C.sep(c, body, strap, ink)
  local bi = C.lay(c, body, R.redleather, { R = 5 })
  C.speckle(c, body, bi, R.redleather, 0.05, 7)
  -- fringe
  for x = 13, 51, 2 do
    local len = 6 + ((x // 2) % 2) * 3
    for y = 47, 46 + len do c:put(x, y, R.redleather[(x < 30) and 4 or 3]) end
    c:put(x, 46 + len, R.redleather[2])
  end
  C.hline(c, 13, 51, 47, R.redleather[1])
  -- stitched side seams
  for y = 22, 44, 2 do c:put(14, y, R.cotton[5]) c:put(50, y, R.cotton[3]) end
  -- flap
  local flap = c:poly{ {11,17}, {53,17}, {53,27}, {32,40}, {11,27} }
  C.sep(c, flap, body, R.redleather[1])
  local fi = C.lay(c, flap, R.ochre, { R = 3, cuts = { .2, .38, .54, .7, .88 } })
  -- tooled zig-zag border inset
  local inner = flap:shrink(2)
  inner:edge():each(function(x, y) if (x + y) % 2 == 0 then c:put(x, y, R.ochre[2]) end end)
  -- centre diamond tooling
  local dm = c:poly{ {32,21}, {37,26}, {32,31}, {27,26} }
  dm:edge():each(function(x, y) c:put(x, y, R.redleather[2]) end)
  c:put(32, 26, R.redleather[3])
  C.hline(c, 12, 52, 17, R.ochre[6])
  C.underline(c, flap, R.ochre[1])
  -- quirk: string of brass beads from the flap point
  C.vline(c, 32, 41, 43, R.strap[2])
  for i, by in ipairs({ 45, 49, 53 }) do
    local bd = c:ellipse(32, by, 1.6, 1.4)
    C.lay(c, bd, R.brass, { R = 1 })
    c:put(31, by - 1, R.brass[6])
    if i < 3 then c:put(32, by + 2, R.strap[2]) end
  end
end

-- 5. Bamboo Frame Pack: ladder frame, lashed rolled mat, hanging water gourd. quirk: gourd
local function frame(c)
  local function pole(x0)
    local m = c:rect(x0, 5, x0 + 3, 58)
    C.vcyl(c, m, R.kente, x0, x0 + 3)
    for y = 12, 56, 11 do C.hline(c, x0, x0 + 3, y, R.kente[2]) C.hline(c, x0, x0 + 3, y - 1, R.kente[6]) end
    return m
  end
  local function bar(y)
    local m = c:rect(14, y, 49, y + 2)
    C.lay(c, m, R.kente, { R = 1, bias = -1 })
    C.hline(c, 14, 49, y, R.kente[5])
    return m
  end
  local b1, b2, b3 = bar(9), bar(40), bar(52)
  local p1 = c:rect(16, 5, 19, 58) local p2 = c:rect(44, 5, 47, 58)
  C.sep(c, p1:copy():add(p2), b1:copy():add(b2):add(b3), ink)
  pole(16) pole(44)
  -- lashing at joints
  for _, j in ipairs({ {16,9}, {44,9}, {16,40}, {44,40}, {16,52}, {44,52} }) do
    for d = 0, 3 do c:put(j[1] + d, j[2] + (d % 2), R.strap[2]) end
  end
  -- rolled sleeping mat lashed across the middle
  local mm, mn = X.cyl(12, 26, 52, 26, function() return 8 end)
  C.sep(c, mm, p1:copy():add(p2), ink)
  local mi = C.toneN(c, mm, mn, R.raffia, { cuts = { .2, .36, .52, .7, .88 } })
  C.retone(c, mm, mi, R.raffia, function(x, y, i) if x % 4 == 0 then return -1 end if (x // 4 + y) % 2 == 0 and x % 4 == 2 then return 1 end end)
  -- dyed stripes in the mat
  mm:each(function(x, y) if x % 13 == 3 or x % 13 == 4 then c:put(x, y, R.forest[math.max(1, math.min(6, mi[K(x, y)] - 1))]) end end)
  -- spiral end
  local en = c:ellipse(12, 26, 3, 8)
  c:fillMask(en, R.raffia[4])
  for _, p in ipairs({ {12,20}, {13,22}, {13,25}, {12,28}, {11,30}, {10,27}, {10,23}, {11,21} }) do c:put(p[1], p[2], R.raffia[1]) end
  c:put(12, 25, R.raffia[2]) c:put(11, 19, R.raffia[6])
  -- cords
  for _, sx in ipairs({ 24, 38 }) do
    for y = 17, 35 do if mm:has(sx, y) then c:put(sx, y, R.strap[3]) c:put(sx + 1, y, R.strap[1]) end end
    c:put(sx, 18, R.strap[5])
  end
  -- quirk: water gourd hanging from the lower bar
  c:line({ {39,43}, {38,46} }, 1):each(function(x, y) c:put(x, y, R.strap[2]) end)
  local gt = c:ellipse(37, 48, 2, 2):add(c:ellipse(37, 54, 5, 4.5))
  C.sep(c, gt, b3:copy():add(p2), ink)
  local gn = X.sphere(36.5, 53.5, 5, gt)
  C.toneN(c, gt, gn, R.calabash, {})
  c:put(35, 52, R.calabash[6]) c:put(34, 53, cream)
  C.hline(c, 35, 39, 49, R.calabash[2])
end

C.run{
  { "backpack-1-calabash-pack", calabash },
  { "backpack-2-raffia-cone-basket", cone },
  { "backpack-3-indigo-bundle", bundle },
  { "backpack-4-tooled-satchel", satchel },
  { "backpack-5-bamboo-frame-pack", frame },
}
