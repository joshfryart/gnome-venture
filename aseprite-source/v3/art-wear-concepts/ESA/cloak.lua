-- cloak.lua: five ESA (Thornacre Savanna) cloak concepts. See concepts.md.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local W = C
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local floor, sqrt, sin, cos, atan, max, min, abs, pi = math.floor, math.sqrt, math.sin, math.cos, math.atan, math.max, math.min, math.abs, math.pi
local ink = C.ink
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return { x/l, y/l, z/l } end

-- drape normals: folds radiating from (ox, oy); f = fold frequency
local function drape(m, ox, oy, f, amp)
  local n = {}
  m:each(function(x, y)
    local a = atan(y - oy, x - ox)
    local d = sqrt((x - ox) ^ 2 + (y - oy) ^ 2)
    local s = sin(a * f) * (amp or 0.6) * min(1, d / 14)
    n[K(x, y)] = norm(s * cos(a - pi / 2) * -1, -0.25 + s * 0.2, 1)
  end)
  return n
end

------------------------------------------------------------------ 1 check blanket wrap
local function blanket(c)
  local body = c:poly{ {12,8}, {28,11}, {50,17}, {54,40}, {55,55}, {42,59}, {28,58}, {10,52}, {9,30}, {11,18} }
  local n = drape(body, 14, 8, 11, 0.7)
  local idx = W.toneN(c, body, n, R.ochre, { cuts = { .22, .38, .54, .7, .86 } })
  body:each(function(x, y)
    local i = idx[K(x, y)]
    local vb = (x + floor((y - 8) * 0.25)) % 11 <= 2
    local hb = (y - floor((x - 12) * 0.18)) % 11 <= 2
    local col
    if vb and hb then col = R.indigo[max(1, i - 1)]
    elseif vb or hb then col = R.indigo[min(6, i)]
    else col = R.ochre[i] end
    if (vb ~= hb) and (x + y) % 2 == 0 and (vb and (x + floor((y - 8) * 0.25)) % 11 == 1 or hb and (y - floor((x - 12) * 0.18)) % 11 == 1) then col = R.madder[min(6, i + 1)] end
    c:put(x, y, col)
  end)
  -- fringe on the hem
  local fr = HP.mask()
  body:each(function(x, y) if not body:has(x, y + 1) and x % 2 == 0 and y > 50 then fr:add(c:rect(x, y + 1, x, y + 3)) end end)
  fr:each(function(x, y) c:put(x, y, R.indigo[(y % 2 == 0) and 4 or 3]) end)
  -- shoulder knot (bunched cloth) with a tail
  local tail = c:poly{ {17,12}, {22,15}, {21,24}, {17,21} }
  local knot = c:ellipse(15, 11, 5, 4)
  W.sep(c, tail, body, R.ochre[1])
  local ti = C.lit(c, tail, R.ochre, { R = 2, b = 0 })
  tail:each(function(x, y) if (y - 12) % 5 <= 1 then c:put(x, y, R.indigo[ti[K(x, y)]]) end end)
  W.sep(c, knot, body:copy():add(tail), R.ochre[1])
  local ki = C.lit(c, knot, R.ochre, { R = 3, b = 1 })
  W.put(c, { {13,10}, {14,11}, {16,12}, {17,11} }, R.ochre[2])
  W.put(c, { {12,9}, {13,8} }, R.ochre[6])
  -- quirk: carved wooden bead on the knot cord
  W.put(c, { {18,14}, {19,15}, {20,16} }, R.strap[3])
  C.bead(c, 21, 18, 1.8, R.wood, R.wood[6])
  W.put(c, { {21,20} }, R.wood[2])
end

------------------------------------------------------------------ 2 highland shawl (folded)
local function shawl(c)
  local weave = function(x, y) if (x + 2 * y) % 5 == 0 and X.hash(x, y, 6) < .6 then return -1 end end
  local layers = { c:rrect(8, 40, 54, 52, 3), c:rrect(10, 30, 52, 42, 3), c:rrect(12, 19, 50, 32, 3) }
  -- tassels on the right ends (behind)
  local tas = HP.mask()
  for _, t in ipairs({ { 54, 44 }, { 55, 47 }, { 53, 34 }, { 53, 37 } }) do tas:add(c:line({ { t[1], t[2] }, { t[1] + 3, t[2] + 3 }, { t[1] + 4, t[2] + 9 } }, 1)) end
  tas:each(function(x, y) c:put(x, y, ((x + y) % 2 == 0) and R.wool[4] or R.wool[5]) end)
  for i, L in ipairs(layers) do
    if i > 1 then W.sep(c, L, layers[i - 1], R.wool[1]) end
    local b = (i == 1) and -1 or ((i == 2) and 0 or 1)
    local idx = C.lit(c, L, R.wool, { R = 3, b = b, cuts = { .22, .4, .58, .74, .9 } })
    W.retone(c, L, idx, R.wool, weave)
    -- woven border along the visible bottom of each fold
    local _, y0, _, y1 = L:bbox()
    L:each(function(x, y)
      local r = y1 - y
      local i2 = idx[K(x, y)]
      if r == 2 or r == 6 then c:put(x, y, R.yarnA[min(6, i2)])
      elseif r == 4 then c:put(x, y, R.yarnB[min(6, i2)])
      elseif r == 3 or r == 5 then
        local z = abs(((x + 1) % 4) - 2)
        c:put(x, y, (z + (r - 3) * 2 <= 1 or z + (5 - r) * 2 <= 1) and R.brass[min(6, i2 + 1)] or R.wool[i2])
      end
    end)
    L:each(function(x, y) if not L:has(x, y + 1) then c:put(x, y, R.wool[2]) end end)
  end
  -- quirk: brass bead on one tassel
  C.bead(c, 58, 54, 1.6, R.brass, R.brass[6])
  c:put(15, 21, C.cream) c:put(16, 21, R.wool[6])
end

------------------------------------------------------------------ 3 banana-leaf rain cape
local function leafcape(c)
  local function leaf(cx, cy, len, w, ang, b)
    local m, U, V = C.rot(cx, cy, ang, function(u, v)
      local t = v / len
      if t < 0 or t > 1 then return false end
      return abs(u) <= w * (sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.55)
    end, len + 4)
    local n = {}
    m:each(function(x, y)
      local k = K(x, y)
      local s = U[k] / (w + .5)
      n[k] = norm(s * 0.8 * cos(ang), s * 0.8 * sin(ang) - 0.15, 1)
    end)
    return m, n, U, V, b
  end
  local rows = {
    { y = 33, xs = { 9, 18, 27, 36, 45, 54 }, len = 26, w = 5.5 },
    { y = 22, xs = { 13, 22, 31, 40, 49 }, len = 24, w = 5.5 },
    { y = 11, xs = { 19, 27, 35, 43 }, len = 20, w = 5 },
  }
  local drawn = HP.mask()
  local all = {}
  for ri, r in ipairs(rows) do
    for j, x in ipairs(r.xs) do
      local ang = (x - 32) / 32 * 0.35
      all[#all + 1] = { leaf(x, r.y, r.len, r.w, -ang, ((j + ri) % 2 == 0) and -1 or 0) }
    end
  end
  for _, L in ipairs(all) do
    local m, n, U, V, b = L[1], L[2], L[3], L[4], L[5]
    W.sep(c, m, drawn, ink)
    local idx = W.toneN(c, m, n, R.banana, { cuts = { .22, .38, .54, .7, .86 }, bias = C.bmap(m, b) })
    m:each(function(x, y)
      local k = K(x, y)
      local u, v = U[k], V[k]
      if abs(u) < 0.6 then c:put(x, y, R.banana[min(6, idx[k] + 2)])
      elseif floor(v - abs(u) * 1.3) % 4 == 0 then c:put(x, y, R.banana[max(1, idx[k] - 1)]) end
    end)
    drawn:add(m)
  end
  -- collar band with a cord tie
  local col = c:rrect(18, 7, 46, 12, 2)
  W.sep(c, col, drawn, ink)
  C.vcyl(c, col, R.strap, 18, 46)
  W.hline(c, 19, 45, 8, R.strap[5])
  for x = 20, 44, 3 do c:put(x, 10, R.strap[2]) end
  W.put(c, { {31,13}, {31,14}, {33,13}, {34,14}, {34,15} }, R.sisal[4])
  -- quirk: a little snail riding on a leaf
  local body = c:poly{ {41,49}, {50,49}, {52,47}, {51,50}, {41,51} }
  W.sep(c, body, drawn, ink)
  C.lit(c, body, R.sand, { R = 1, b = 1 })
  W.put(c, { {51,45}, {52,44} }, R.sand[4]) W.put(c, { {50,45} }, R.sand[3])
  local shell = c:ellipse(45, 46, 3.5, 3.2)
  W.sep(c, shell, body:copy():add(drawn), ink)
  C.lit(c, shell, R.gourd, { R = 2 })
  W.put(c, { {45,46}, {46,46}, {46,45}, {45,44}, {44,44}, {43,45}, {43,47}, {44,48}, {46,48} }, R.gourd[2])
  c:put(44, 44, R.gourd[6])
  c:put(14, 37, R.banana[6]) c:put(14, 38, C.cream)
end

------------------------------------------------------------------ 4 dust mantle
local function mantle(c)
  local cape = c:poly{ {22,18}, {42,18}, {52,34}, {57,54}, {7,54}, {12,34} }
  local hood = c:poly{ {32,2}, {35,6}, {42,18}, {41,24}, {23,24}, {22,18}, {29,6} }
  -- fringe
  local fr = HP.mask()
  for x = 8, 56, 2 do fr:add(c:rect(x, 55, x, 58 + (x % 4 == 0 and 1 or 0))) end
  fr:each(function(x, y) c:put(x, y, (y >= 58) and R.madder[4] or R.sand[3]) end)
  local n = drape(cape, 32, 14, 9, 0.55)
  local ci = W.toneN(c, cape, n, R.sand, { cuts = { .22, .38, .54, .7, .86 } })
  W.retone(c, cape, ci, R.sand, function(x, y) if X.hash(x, y, 13) < .07 then return -1 end end)
  -- front opening + hem band
  W.vline(c, 32, 24, 54, R.sand[2])
  for x = 7, 57 do if cape:has(x, 53) then c:put(x, 53, R.madder[3]) c:put(x, 52, R.sand[2]) end end
  W.sep(c, hood, cape, R.sand[1])
  local hi = C.lit(c, hood, R.sand, { R = 4, b = 1, cuts = { .22, .38, .54, .7, .88 } })
  -- face opening, deep shade inside
  local op = c:ellipse(32, 17, 6, 5.5):clip(hood)
  c:fillMask(op, R.umber[2])
  op:each(function(x, y) if not op:has(x, y - 1) or not op:has(x - 1, y) then c:put(x, y, R.umber[4]) end end)
  op:grow(1):cut(op):clip(hood):each(function(x, y) c:put(x, y, (x < 32) and R.sand[6] or R.sand[3]) end)
  -- hood seam and tip highlight
  W.put(c, { {31,3}, {31,4}, {30,6} }, R.sand[6])
  -- quirk: blue-and-orange agama lizard clinging to the hem
  local lz, ln, LT = G.tube({ {44,58}, {46,50}, {48,44}, {50,38} }, function(t)
    if t < .45 then return 0.6 + t * 1.6 end
    return 1.5 + sin((t - .45) / .55 * pi) * 0.7
  end)
  W.sep(c, lz, cape:copy():add(fr), ink)
  local li = W.toneN(c, lz, ln, R.jay, { cuts = { .2, .36, .52, .7, .88 } })
  local head = c:ellipse(51, 35, 2.2, 2.6)
  W.sep(c, head, lz, ink)
  C.lit(c, head, R.autumn, { R = 1, b = 1 })
  c:put(50, 34, R.umber[1]) c:put(52, 35, R.umber[1])
  W.put(c, { {45,46}, {44,46}, {50,44}, {51,45}, {46,41}, {45,40}, {52,40}, {53,41} }, R.jay[3])
end

------------------------------------------------------------------ 5 indigo dot shawl
local function dotshawl(c)
  local top = function(x) return 11 + floor(3 * sin((x - 4) / 56 * pi) + .5) end
  local pts = { {4,10}, {18,13}, {32,14}, {46,13}, {60,10}, {59,15}, {34,57}, {30,57}, {5,15} }
  local body = c:poly(pts)
  -- tassels behind the corners
  local tas = c:line({ {4,13}, {3,19} }, 2):add(c:line({ {60,13}, {61,19} }, 2)):add(c:line({ {32,57}, {32,61} }, 2))
  tas:each(function(x, y) c:put(x, y, ((y % 2) == 0) and R.canvas[5] or R.canvas[3]) end)
  local n = drape(body, 32, 4, 13, 0.4)
  local idx = W.toneN(c, body, n, R.indigo, { cuts = { .2, .36, .52, .7, .86 } })
  -- resist dots: rings on a staggered grid
  body:each(function(x, y)
    local row = floor((y - 14) / 7)
    local ox = (row % 2 == 0) and 0 or 3.5
    local cx = floor((x - ox) / 7) * 7 + ox + 3.5
    local cy = row * 7 + 14 + 3.5
    local d = sqrt((x + .5 - cx) ^ 2 + (y + .5 - cy) ^ 2)
    local i = idx[K(x, y)]
    if d < 2.6 and d >= 1.4 then c:put(x, y, R.indigo[min(6, i + 2)]) elseif d < 1.0 then c:put(x, y, R.canvas[min(6, i + 1)]) end
  end)
  -- cream border along the two lower edges
  local inner = c:poly{ {9,15}, {55,15}, {32,51} }
  body:each(function(x, y)
    if not inner:has(x, y) and y > 13 then
      local i = idx[K(x, y)]
      c:put(x, y, R.canvas[min(6, i + 1)])
    end
  end)
  inner:grow(1):cut(inner):clip(body):each(function(x, y) if y > 15 then c:put(x, y, R.madder[3]) end end)
  -- top folded edge
  body:each(function(x, y) if not body:has(x, y - 1) then c:put(x, y, R.indigo[5]) elseif not body:has(x, y - 2) then c:put(x, y, R.indigo[2]) end end)
  -- quirk: small orange butterfly resting on it
  local wings = c:ellipse(20, 23, 2.4, 2.2):add(c:ellipse(25, 23, 2.4, 2.2)):add(c:ellipse(20, 27, 1.6, 1.4)):add(c:ellipse(25, 27, 1.6, 1.4))
  W.sep(c, wings, body, ink)
  C.lit(c, wings, R.autumn, { R = 1, b = 1 })
  W.vline(c, 22, 22, 28, R.umber[2]) W.vline(c, 23, 22, 28, R.umber[2])
  W.put(c, { {21,20}, {20,19}, {24,20}, {25,19} }, R.umber[3])
  W.put(c, { {18,22}, {27,22} }, R.umber[3]) c:put(19, 22, R.autumn[6])
  c:put(10, 14, C.cream)
end

C.run{
  { "cloak-1-check-blanket-wrap", blanket },
  { "cloak-2-highland-shawl", shawl },
  { "cloak-3-banana-leaf-rain-cape", leafcape },
  { "cloak-4-dust-mantle", mantle },
  { "cloak-5-indigo-dot-shawl", dotshawl },
}
