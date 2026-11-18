-- coat.lua: SEA "Monsoon Tangle" coat concepts 1..5 (see concepts.md). Front views, laid flat.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local floor, sin, cos, rad, max, min, abs = math.floor, math.sin, math.cos, math.rad, math.max, math.min, math.abs

local function mir(pts) local q = {} for i, p in ipairs(pts) do q[i] = { 64 - p[1], p[2] } end return q end
-- sleeves (left lit, right shaded) then body; returns body idx and masks
local function garment(c, body, sl, ramp, o)
  o = o or {}
  local L, Rr = c:poly(sl), c:poly(mir(sl))
  local B = c:poly(body)
  local li = C.lit(c, L, ramp, o.sb or 0, { R = o.sR or 3 })
  local ri = C.lit(c, Rr, ramp, (o.sb or 0) - 1, { R = o.sR or 3 })
  C.sep(c, B, L:copy():add(Rr), ramp[1])
  local bi = C.lit(c, B, ramp, o.bb or 0, { R = o.bR or 5, cuts = o.cuts or { .2, .36, .52, .7, .88 } })
  return B, L, Rr, bi, li, ri
end

---------------------------------------------------------------- 1 indigo batik smock
do
  local c = C.canvas("coat-1-indigo-batik-smock")
  local sl = { {23,12}, {15,15}, {4,36}, {5,41}, {16,41}, {21,27} }
  local B, L, Rr, bi, li, ri = garment(c, { {22,11}, {42,11}, {50,56}, {14,56} }, sl, R.indigo)
  local function pat(m, idx)
    C.motif(c, m, idx, R.wax, function(x, y)
      if (x + y) % 6 == 0 and (x - y) % 6 == 0 then return true end
      for base = 20, 46, 8 do if y == base + floor(1.4 * sin(x / 2) + .5) then return true end end
    end, -1)
  end
  pat(B, bi) pat(L, li) pat(Rr, ri)
  -- pale hem band with a zigzag, sleeve cuffs
  B:each(function(x, y) if y >= 50 and y <= 54 then
    local i = bi[K(x, y)] or 3
    local z = 52 + ((x % 4 < 2) and 0 or -1)
    c:put(x, y, (y == z) and R.indigo[max(1, i - 1)] or R.wax[max(1, i - 1)])
  end end)
  for _, m in ipairs({ L, Rr }) do
    local idx = (m == L) and li or ri
    m:each(function(x, y) if y >= 38 then c:put(x, y, R.wax[max(1, (idx[K(x, y)] or 3) - 1)]) end end)
  end
  -- neck opening + placket slit
  local neck = c:ellipse(32, 11, 6, 3):clip(B)
  c:fillMask(neck, R.indigo[1])
  neck:grow(1):cut(neck):clip(B):each(function(x, y) c:put(x, y, R.wax[4]) end)
  C.vline(c, 32, 15, 22, R.indigo[1]) C.vline(c, 33, 15, 22, R.indigo[4])
  -- fold creases
  C.put(c, { {22,30}, {21,34}, {20,38}, {43,32}, {44,36}, {45,40} }, R.indigo[2])
  -- quirk: hibiscus patch on the chest
  local patch = c:rect(21, 21, 29, 29)
  c:fillMask(patch, R.wax[5])
  C.hline(c, 21, 29, 29, R.wax[3]) C.vline(c, 29, 21, 29, R.wax[3])
  for x = 21, 29, 2 do c:put(x, 21, R.indigo[3]) end
  C.flower(c, 25, 25, R.hibis, R.brass[5])
  c:put(26, 26, R.hibis[1]) c:put(28, 27, R.leaf[4]) c:put(27, 28, R.leaf[3])
  C.save(c, "coat-1-indigo-batik-smock")
end

---------------------------------------------------------------- 2 pandan weave vest
do
  local c = C.canvas("coat-2-pandan-weave-vest")
  local half = { {32,23}, {26,9}, {19,10}, {15,17}, {18,23}, {17,54}, {31,54} }
  local back = c:poly{ {26,9}, {38,9}, {38,54}, {26,54} }
  C.lit(c, back, R.straw, -2, { R = 1 })
  local Lm, Rm = c:poly(half), c:poly(mir(half))
  local function weave(m, bias)
    local i = C.lit(c, m, R.pandan, bias, { R = 4 })
    m:each(function(x, y)
      local k = K(x, y)
      local alt = ((x // 4) + (y // 4)) % 2 == 0
      local t = i[k]
      if alt then c:put(x, y, R.straw[t]) end
      if (alt and y % 4 == 3) or (not alt and x % 4 == 3) then c:put(x, y, (alt and R.straw or R.pandan)[max(1, t - 1)]) end
    end)
    return i
  end
  weave(Rm, -1)
  C.sep(c, Lm, Rm, R.soga[1])
  weave(Lm, 0)
  -- dark bound edges: front opening, armholes, hem
  for _, m in ipairs({ Lm, Rm }) do
    local e = m:edge()
    e:each(function(x, y)
      local front = (m == Lm) and not m:has(x + 1, y) or (m == Rm) and not m:has(x - 1, y)
      local inner = (x > 20 and x < 44)
      if (front and inner and y > 10) or not m:has(x, y + 1) or (y > 15 and y < 24 and (x < 20 or x > 44)) then
        c:put(x, y, (x < 32 and y < 50) and R.soga[4] or R.soga[2])
        local ix = x < 32 and x - 1 or x + 1
      end
    end)
  end
  C.hline(c, 18, 31, 53, R.soga[3]) C.hline(c, 33, 46, 53, R.soga[2])
  -- pockets
  for _, px in ipairs({ 20, 37 }) do
    local pk = c:rect(px, 36, px + 7, 44)
    C.sep(c, pk, Lm:copy():add(Rm), R.pandan[1])
    C.lit(c, pk, R.pandan, px > 32 and -1 or 0, { R = 1 })
    C.hline(c, px, px + 7, 36, R.soga[px > 32 and 3 or 4]) C.hline(c, px, px + 7, 37, R.soga[2])
    pk:edge():each(function(x, y) if y > 37 and (x + y) % 2 == 0 then c:put(x, y, R.straw[5]) end end)
  end
  -- seed-pod buttons
  for _, y in ipairs({ 27, 33 }) do c:put(29, y, R.wood[5]) c:put(30, y, R.wood[3]) c:put(29, y + 1, R.wood[2]) c:put(30, y + 1, R.wood[1]) end
  -- quirk: red chilli poking out of the right pocket
  local ch = c:line({ {41,35}, {42,31}, {44,28}, {46,27} }, 2)
  C.sep(c, ch, Rm, C.ink)
  C.lit(c, ch, R.hibis, 1, { R = 1 })
  c:put(41, 31, R.hibis[6])
  C.put(c, { {40,35}, {41,36}, {42,35}, {43,35} }, R.leaf[3])
  c:put(47, 26, R.leaf[4])
  C.save(c, "coat-2-pandan-weave-vest")
end

---------------------------------------------------------------- 3 ikat wrap-jacket
do
  local c = C.canvas("coat-3-ikat-wrap-jacket")
  local sl = { {21,11}, {13,15}, {8,44}, {15,45}, {19,25} }
  local B, L, Rr, bi, li, ri = garment(c, { {21,10}, {43,10}, {48,45}, {16,45} }, sl, R.yarnA, { bR = 4 })
  local function ikat(m, idx, ph)
    m:each(function(x, y)
      local i = idx[K(x, y)] or 3
      local r = (y + ph) % 9
      if r <= 1 then c:put(x, y, R.indigo[min(6, i)])
      elseif r == 8 then c:put(x, y, R.yarnA[max(1, i - 1)])
      else
        local d = abs(((x + floor(X.hash(x // 2, y, 3) * 1.6)) % 8) - 4) + abs(r - 4.5)
        if d <= 2.5 and d >= 1.5 then c:put(x, y, R.lining[min(6, i + 1)]) elseif d < 1.2 then c:put(x, y, R.indigo[min(6, i + 1)]) end
      end
    end)
  end
  ikat(B, bi, 0) ikat(L, li, 0) ikat(Rr, ri, 0)
  -- cuffs
  for _, m in ipairs({ L, Rr }) do m:each(function(x, y) if y >= 42 then c:put(x, y, R.indigo[(m == L) and 4 or 2]) end end) end
  -- neck: back collar visible
  local neck = c:poly{ {25,10}, {39,10}, {35,14}, {29,14} }
  c:fillMask(neck, R.indigo[1])
  -- wrap edge: wide indigo band from left neck down to the right waist
  local band = c:line({ {26,10}, {33,18}, {41,28}, {45,34} }, 3)
  band:clip(B)
  local under = c:poly{ {26,10}, {46,36}, {48,45}, {16,45}, {16,10} }
  band:shift(1, 1):cut(band):clip(B):each(function(x, y) c:put(x, y, R.yarnA[1]) end)
  C.lit(c, band, R.indigo, 1, { R = 1 })
  band:each(function(x, y) if not band:has(x - 1, y) then c:put(x, y, R.indigo[6]) end end)
  -- side tie: knot, two ends, tassel quirk
  local knot = c:ellipse(46, 35, 2.5, 2.5)
  C.sep(c, knot, B, C.ink)
  C.lit(c, knot, R.indigo, 1, { R = 1 })
  local t1 = c:line({ {47,37}, {49,42}, {50,46} }, 2)
  local t2 = c:line({ {46,38}, {46,43} }, 1)
  local ties = t1:copy():add(t2)
  C.sep(c, ties, B, C.ink)
  t1:each(function(x, y) c:put(x, y, R.indigo[(x % 2 == 0) and 3 or 4]) end)
  t2:each(function(x, y) c:put(x, y, R.indigo[3]) end)
  local tas = c:poly{ {48.5,47}, {51.5,47}, {53,53}, {47,53} }
  C.sep(c, tas, ties, C.ink)
  C.lit(c, tas, R.brass, 0, { R = 1 })
  for x = 48, 52, 2 do C.vline(c, x, 50, 53, R.brass[2]) end
  C.hline(c, 49, 51, 48, R.brass[6]) c:put(49, 47, R.brass[3]) c:put(51, 47, R.brass[3])
  C.save(c, "coat-3-ikat-wrap-jacket")
end

---------------------------------------------------------------- 4 kapok puffer
do
  local c = C.canvas("coat-4-kapok-puffer")
  local body = c:rrect(16, 11, 48, 54, 9)
  local sL, nL = G.oval(13, 29, 6.5, 12, 0.35)
  local sR, nR = G.oval(51, 29, 6.5, 12, -0.35)
  local collar = c:rrect(23, 5, 41, 13, 3)
  -- sleeves: rings of quilting
  for _, s in ipairs({ { sL, nL, 0 }, { sR, nR, -1 } }) do
    local idx = C.toneN(c, s[1], s[2], R.sage, { bias = C.bmap(s[1], s[3]) })
    s[1]:each(function(x, y) if (y + floor(x * (s[1] == sL and 0.35 or -0.35))) % 6 == 0 then c:put(x, y, R.sage[max(1, idx[K(x, y)] - 2)]) end end)
  end
  C.sep(c, body, sL:copy():add(sR), R.sage[1])
  -- diamond-quilted cells, each puffed on its own
  local cells = {}
  body:each(function(x, y)
    local a, b = (x + y), (x - y + 64)
    if a % 7 == 0 or b % 7 == 0 then return end
    local key = (a // 7) * 100 + (b // 7)
    cells[key] = cells[key] or HP.mask()
    cells[key]:set(x, y)
  end)
  local seam = body:copy()
  for _, m in pairs(cells) do seam:cut(m) end
  local base = C.lit(c, body, R.sage, 0, { R = 6 })
  seam:each(function(x, y) c:put(x, y, R.sage[max(1, (base[K(x, y)] or 3) - 2)]) end)
  for _, m in pairs(cells) do
    local bias = {}
    m:each(function(x, y) bias[K(x, y)] = (base[K(x, y)] or 3) - 4 end)
    C.lit(c, m, R.sage, 0, { R = 2, bias = bias })
  end
  -- centre closure: wooden toggles
  C.vline(c, 32, 13, 53, R.sage[1]) C.vline(c, 33, 13, 53, R.sage[2])
  for _, y in ipairs({ 20, 29, 38, 47 }) do
    local t = c:rrect(30, y, 35, y + 2, 1)
    C.lit(c, t, R.wood, 0, { R = 1 }) c:put(30, y, R.wood[6])
  end
  -- stand collar
  C.sep(c, collar, body, R.sage[1])
  C.lit(c, collar, R.sage, 1, { R = 2 })
  C.hline(c, 24, 40, 9, R.sage[3])
  local cn = c:ellipse(32, 6, 6, 1.5):clip(collar)
  c:fillMask(cn, R.sage[1])
  -- quirk: kapok fluff escaping the right shoulder seam
  local fl = c:ellipse(46, 13, 3, 2.2):add(c:ellipse(49, 11, 2.2, 2)):add(c:ellipse(44, 10.5, 1.8, 1.6))
  C.sep(c, fl, body:copy():add(sR):add(collar), R.sage[1])
  C.lit(c, fl, R.petal, 1, { R = 1 })
  C.put(c, { {47,13}, {49,12}, {44,11} }, R.petal[3])
  c:put(51, 9, R.petal[5]) c:put(42, 9, R.petal[5])
  C.save(c, "coat-4-kapok-puffer")
end

---------------------------------------------------------------- 5 mangrove oilcloth
do
  local c = C.canvas("coat-5-mangrove-oilcloth")
  local sl = { {22,11}, {15,14}, {10,46}, {16,47}, {19,24} }
  local B, L, Rr, bi = garment(c, { {22,10}, {42,10}, {47,59}, {17,59} }, sl, R.olive, { bR = 6 })
  -- waxed sheen streaks on the lit side
  C.vline(c, 20, 16, 50, R.olive[6]) C.vline(c, 21, 20, 36, R.olive[6])
  C.vline(c, 13, 20, 40, R.olive[6])
  c:put(20, 17, C.cream)
  -- centre placket and brass buttons
  C.vline(c, 32, 14, 58, R.olive[1]) C.vline(c, 33, 14, 58, R.olive[4])
  for _, y in ipairs({ 18, 26, 34, 42, 50 }) do
    local bt = c:ellipse(30, y, 1.2, 1.2)
    C.lit(c, bt, R.brass, 0, { R = 1 }) c:put(29, y - 1, R.brass[6])
  end
  -- flap pockets
  for _, px in ipairs({ 20, 36 }) do
    local fp = c:poly{ {px,38}, {px+8,38}, {px+8,41}, {px+4,43}, {px,41} }
    fp:shift(0, 1):cut(fp):clip(B):each(function(x, y) c:put(x, y, R.olive[1]) end)
    C.lit(c, fp, R.olive, px > 32 and 0 or 1, { R = 1 })
    C.hline(c, px, px + 8, 38, R.olive[px > 32 and 4 or 6])
    c:put(px + 4, 41, R.brass[4])
    C.vline(c, px, 44, 48, R.olive[2]) C.vline(c, px + 8, 44, 48, R.olive[2])
  end
  -- cuffs and hem tabs
  for _, m in ipairs({ L, Rr }) do m:each(function(x, y) if y == 42 then c:put(x, y, R.olive[1]) end end) end
  -- high flared collar
  local cl = c:poly{ {22,4}, {31,10}, {31,15}, {20,12} }
  local cr = c:poly(mir{ {22,4}, {31,10}, {31,15}, {20,12} })
  local back = c:poly{ {24,5}, {40,5}, {40,11}, {24,11} }
  C.lit(c, back, R.olive, -2, { R = 1 })
  C.lit(c, cr, R.olive, -1, { R = 1 })
  C.sep(c, cl, cr, R.olive[1])
  C.lit(c, cl, R.olive, 1, { R = 1 })
  C.hline(c, 26, 38, 11, R.olive[1])
  -- quirk: fiddler crab clinging to the hem, one big orange claw raised
  local crab = c:ellipse(39, 57, 4, 2.2)
  local claw = c:ellipse(47, 52, 3, 2.2)
  local arm = c:line({ {42,56}, {44,54} }, 2)
  local legs = c:line({ {35,58}, {33,60} }, 1):add(c:line({ {37,59}, {36,61} }, 1)):add(c:line({ {42,59}, {43,61} }, 1))
  local stalks = c:rect(37, 53, 37, 54):add(c:rect(40, 53, 40, 54))
  local cm = crab:copy():add(claw):add(arm):add(legs):add(stalks)
  C.sep(c, cm, B, C.ink)
  legs:each(function(x, y) c:put(x, y, R.blanket[2]) end)
  stalks:each(function(x, y) c:put(x, y, R.blanket[2]) end)
  C.lit(c, crab, R.blanket, 1, { R = 1 })
  C.lit(c, arm, R.mango, 0, { R = 1 })
  C.lit(c, claw, R.mango, 1, { R = 1 })
  c:put(47, 53, R.mango[2]) c:put(48, 53, R.mango[2]) c:put(45, 51, R.mango[6])
  c:put(37, 52, R.petal[5]) c:put(40, 52, R.petal[5])
  c:put(37, 56, R.blanket[6]) c:put(38, 56, R.blanket[6])
  C.save(c, "coat-5-mangrove-oilcloth")
end
