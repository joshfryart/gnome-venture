-- coat.lua: five ESA (Thornacre Savanna) coat concepts. See concepts.md.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local W = C
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local floor, sqrt, sin, max, min, abs = math.floor, math.sqrt, math.sin, math.max, math.min, math.abs
local ink = C.ink

local function mirror(pts) local q = {} for i, p in ipairs(pts) do q[i] = { 63 - p[1], p[2] } end return q end
local function sleeves(c, ptsL)
  return c:poly(ptsL), c:poly(mirror(ptsL))
end
local function tube(c, pts, w, ramp, b)
  local m, n, T, S = G.tube(pts, type(w) == "function" and w or function() return w end)
  local idx = W.toneN(c, m, n, ramp, { cuts = { .2, .38, .55, .72, .88 }, bias = b and C.bmap(m, b) })
  return m, idx, T, S
end

------------------------------------------------------------------ 1 barkcloth smock
local function smock(c)
  local body = c:poly{ {22,10}, {42,10}, {52,56}, {12,56} }
  local sl, sr = sleeves(c, { {23,11}, {12,16}, {5,28}, {15,33}, {21,25} })
  local tex = function(x, y, i)
    local yy = y + floor(X.hash(floor(x / 5), 0, 3) * 2)
    if yy % 3 == 0 then return -1 end
    if X.hash(x, y, 8) < .06 then return 1 end
  end
  for _, s in ipairs({ sl, sr }) do
    local i = C.lit(c, s, R.bark, { R = 3, b = (s == sr) and -1 or 0 })
    W.retone(c, s, i, R.bark, tex)
  end
  W.sep(c, body, sl:copy():add(sr), R.bark[1])
  local bi = C.lit(c, body, R.bark, { R = 5, cuts = { .22, .38, .54, .7, .88 } })
  W.retone(c, body, bi, R.bark, tex)
  -- fold shadows
  for y = 30, 55 do c:put(floor(24 - (y - 30) * 0.25), y, R.bark[2]) c:put(floor(41 + (y - 30) * 0.25), y, R.bark[2]) end
  -- hem roll
  for x = 13, 51 do if body:has(x, 55) then c:put(x, 54, R.bark[5]) c:put(x, 55, R.bark[2]) end end
  -- neck opening (inside of the back) and slit
  local neck = c:ellipse(32, 10, 6, 3):clip(body)
  c:fillMask(neck, R.bark[1])
  W.hline(c, 27, 37, 12, R.bark[2])
  W.vline(c, 32, 13, 25, R.bark[1])
  -- wooden toggles with cord loops
  for _, ty in ipairs({ 16, 21 }) do
    local t = c:rrect(28, ty, 36, ty + 2, 1)
    C.lit(c, t, R.wood, { R = 1 })
    W.hline(c, 29, 35, ty, R.wood[6]) c:put(32, ty + 1, R.wood[2])
  end
  -- quirk: green fig-leaf patch, stitched on the hem
  local leaf = c:ellipse(19, 47, 4, 4):add(c:ellipse(15, 45, 2, 2)):add(c:ellipse(23, 44, 2, 2)):add(c:ellipse(19, 42, 2, 2))
  C.lit(c, leaf, R.leafg, { R = 2 })
  W.vline(c, 19, 43, 50, R.leafg[2]) W.put(c, { {17,46}, {21,46}, {16,44}, {22,44} }, R.leafg[3])
  leaf:grow(1):cut(leaf):each(function(x, y) if (x + y) % 2 == 0 then c:put(x, y, R.sisal[5]) end end)
  W.put(c, { {18,51}, {19,52} }, R.leafg[2])
  c:put(9, 18, R.bark[6]) c:put(23, 14, R.bark[6]) c:put(24, 14, C.cream)
end

------------------------------------------------------------------ 2 stripe weave vest
local function vest(c)
  local pts = { {19,8}, {27,8}, {32,30}, {37,8}, {45,8}, {47,14}, {45,20}, {48,27}, {50,52}, {14,52}, {16,27}, {19,20}, {17,14} }
  local body = c:poly(pts)
  local back = c:poly{ {26,7}, {38,7}, {35,30}, {29,30} }
  -- fringe
  local fr = HP.mask()
  for x = 15, 49, 2 do fr:add(c:rect(x, 53, x, 56 + (x % 4 == 1 and 1 or 0))) end
  fr:each(function(x, y) c:put(x, y, (y > 55) and R.canvas[3] or R.canvas[5]) end)
  -- lining of the back inside the V
  c:fillMask(back, R.strap[2])
  W.hline(c, 27, 37, 8, R.strap[3])
  local bi = C.lit(c, body, R.autumn, { R = 4, cuts = { .22, .38, .54, .7, .88 } })
  body:each(function(x, y)
    local u = abs(x - 31.5)
    local k = floor(u) % 8
    local i = bi[K(x, y)]
    local col
    if k <= 2 then col = R.autumn[i] elseif k == 3 or k == 7 then col = R.canvas[min(6, i + 1)] else col = R.yarnB[i] end
    if y % 2 == 0 and (k == 3 or k == 7) then col = R.canvas[i] end
    c:put(x, y, col)
  end)
  -- cream piping on the V opening and armholes
  body:edge():each(function(x, y)
    local inV = (y > 8 and abs(x - 32) < 8 and y < 31)
    local arm = (y > 13 and y < 28 and (x < 20 or x > 44))
    if inV or arm then c:put(x, y, (x < 32) and R.canvas[6] or R.canvas[4]) end
  end)
  -- hem band
  for x = 14, 50 do if body:has(x, 51) then c:put(x, 51, R.umber[3]) c:put(x, 50, R.umber[5]) end end
  -- small wooden button + loop
  c:put(28, 26, R.wood[5]) c:put(29, 26, R.wood[3])
  -- quirk: an iridescent sunbird feather in the buttonhole
  local fm, fi, FT, FS = tube(c, { {24,26}, {23,20}, {21,15}, {22,10} }, function(t) return 0.8 + 1.4 * sin(math.pi * min(1, t * 1.05)) end, R.leafg, 0)
  W.sep(c, fm, body, ink)
  fm:each(function(x, y) local t = FT[K(x, y)] if t and t > .7 then c:put(x, y, R.lav[min(6, fi[K(x, y)] + 1)]) end end)
  fm:each(function(x, y) if FS[K(x, y)] and abs(FS[K(x, y)]) < .25 then c:put(x, y, R.leafg[6]) end end)
  c:put(18, 12, C.cream)
end

------------------------------------------------------------------ 3 highland wool coat
local function woolcoat(c)
  local body = c:poly{ {21,10}, {43,10}, {48,59}, {16,59} }
  local sl, sr = sleeves(c, { {22,10}, {14,13}, {9,46}, {17,47}, {20,22} })
  local spk = function(x, y, i) local h = X.hash(x, y, 11) if h < .1 then return -1 elseif h > .94 then return 1 end end
  for _, s in ipairs({ sl, sr }) do
    local i = C.lit(c, s, R.wool, { R = 3, b = (s == sr) and -1 or 0 })
    W.retone(c, s, i, R.wool, spk)
  end
  -- turned-back cuffs
  for _, cf in ipairs({ c:poly{ {9,41}, {17,42}, {17,47}, {9,46} }, c:poly(mirror{ {9,41}, {17,42}, {17,47}, {9,46} }) }) do
    C.lit(c, cf, R.wool, { R = 1, b = 1 })
    cf:each(function(x, y) if not cf:has(x, y - 1) then c:put(x, y, R.wool[2]) end end)
  end
  W.sep(c, body, sl:copy():add(sr), R.wool[1])
  local bi = C.lit(c, body, R.wool, { R = 5, cuts = { .22, .38, .54, .7, .88 } })
  W.retone(c, body, bi, R.wool, spk)
  -- overlap edge of the double-breasted front
  for y = 13, 58 do c:put(36, y, R.wool[2]) c:put(37, y, R.wool[4]) end
  -- hip pocket flaps
  W.hline(c, 20, 28, 45, R.wool[2]) W.hline(c, 39, 45, 45, R.wool[2])
  W.hline(c, 20, 28, 44, R.wool[6])
  -- hem
  for x = 16, 48 do if body:has(x, 58) then c:put(x, 58, R.wool[2]) end end
  -- tall standing collar
  local col = c:rrect(23, 3, 41, 13, 3)
  W.sep(c, col, body, R.wool[1])
  C.lit(c, col, R.wool, { R = 3, b = 0 })
  local inn = c:ellipse(32, 5, 7, 1.6):clip(col)
  c:fillMask(inn, R.wool[1])
  W.hline(c, 24, 40, 9, R.wool[3])
  -- two rows of wooden buttons
  for _, bx in ipairs({ 30, 40 }) do
    for _, by in ipairs({ 18, 26, 34, 42 }) do
      if not (bx == 40 and by == 34) then C.bead(c, bx, by, 1.4, R.wood, R.wood[6]) end
    end
  end
  -- quirk: one odd button, a red coffee-cherry bead
  C.bead(c, 40, 34, 1.7, R.ember, C.cream)
  c:put(41, 31, R.leafg[4])
  c:put(17, 16, R.wool[6]) c:put(24, 15, C.cream)
end

------------------------------------------------------------------ 4 savanna field jacket
local function jacket(c)
  local body = c:poly{ {21,12}, {43,12}, {46,48}, {18,48} }
  local smL = tube(c, { {22,15}, {16,20}, {11,28}, {7,36} }, 4.2, R.khaki, 0)
  local smR = tube(c, { {41,15}, {47,20}, {52,28}, {56,36} }, 4.2, R.khaki, -1)
  -- rolled cuffs + forearm stubs
  for _, p in ipairs({ { 7, 36, 0 }, { 56, 36, -1 } }) do
    local cf = c:ellipse(p[1], p[2], 4.5, 3)
    C.lit(c, cf, R.khaki, { R = 1, b = p[3] + 1 })
    W.hline(c, p[1] - 3, p[1] + 3, p[2], R.khaki[3])
  end
  W.sep(c, body, smL:copy():add(smR), R.khaki[1])
  C.lit(c, body, R.khaki, { R = 4, cuts = { .22, .38, .54, .7, .88 } })
  -- centre placket + brass buttons
  W.vline(c, 32, 19, 47, R.khaki[2])
  for _, by in ipairs({ 23, 30, 37, 44 }) do c:put(33, by, R.brass[4]) c:put(33, by - 1, R.brass[6]) end
  -- lapels and collar
  local lapL = c:poly{ {22,11}, {31,11}, {32,20}, {25,16} }
  local lapR = c:poly(mirror{ {22,11}, {31,11}, {32,20}, {25,16} })
  local neck = c:poly{ {28,11}, {36,11}, {32,18} }
  c:fillMask(neck, R.khaki[1])
  C.lit(c, lapL, R.khaki, { R = 1, b = 1 }) C.lit(c, lapR, R.khaki, { R = 1, b = -1 })
  lapL:each(function(x, y) if not lapL:has(x + 1, y) then c:put(x, y, R.khaki[2]) end end)
  -- pockets with flaps
  local function pocket(x0, y0, x1, y1)
    local p = c:rect(x0, y0, x1, y1)
    C.lit(c, p, R.khaki, { R = 1, b = 0 })
    p:edge():each(function(x, y) if x == x1 or y == y1 then c:put(x, y, R.khaki[2]) end end)
    W.hline(c, x0, x1, y0, R.khaki[6]) W.hline(c, x0, x1, y0 + 2, R.khaki[2])
    c:put(floor((x0 + x1) / 2), y0 + 1, R.brass[4])
    return p
  end
  pocket(23, 21, 29, 26) pocket(36, 21, 42, 26)
  pocket(22, 34, 30, 43) pocket(35, 34, 43, 43)
  -- hem band and piping
  W.hline(c, 19, 45, 47, R.strap[3]) W.hline(c, 19, 45, 46, R.khaki[5])
  -- quirk: giraffe-spot patch on the lower left pocket
  local patch = c:rect(22, 36, 30, 43)
  c:fillMask(patch, R.sand[6])
  local spots = { {22,36,24,38}, {26,36,28,37}, {30,36,30,38}, {22,40,23,43}, {25,39,28,41}, {30,40,30,43}, {25,43,28,43} }
  for _, s in ipairs(spots) do c:fillMask(c:rect(s[1], s[2], s[3], s[4]), R.ochre[3]) end
  W.put(c, { {24,38}, {28,37}, {28,41}, {23,43} }, R.ochre[1])
  W.put(c, { {22,36}, {26,36}, {25,39} }, R.ochre[5])
  c:put(14, 18, R.khaki[6]) c:put(15, 17, C.cream)
end

------------------------------------------------------------------ 5 beaded tunic-coat
local function tunic(c)
  local body = c:poly{ {23,12}, {41,12}, {46,58}, {18,58} }
  local smL = tube(c, { {24,14}, {19,24}, {16,36}, {14,48} }, 3.4, R.suede, 0)
  local smR = tube(c, { {40,14}, {45,24}, {48,36}, {50,48} }, 3.4, R.suede, -1)
  -- cuff fringe
  for _, p in ipairs({ 13, 50 }) do
    for dx = -3, 3, 2 do W.vline(c, p + dx, 50, 53, R.suede[(dx < 0) and 4 or 3]) end
  end
  W.sep(c, body, smL:copy():add(smR), R.suede[1])
  local bi = C.lit(c, body, R.suede, { R = 5, cuts = { .22, .38, .54, .7, .88 } })
  -- side slits at the hem
  for y = 49, 58 do c:put(22 - floor((y - 49) * 0.12), y, R.suede[1]) c:put(42 + floor((y - 49) * 0.12), y, R.suede[1]) end
  for x = 18, 46 do if body:has(x, 57) then c:put(x, 57, R.suede[2]) end end
  -- soft suede creases
  W.put(c, { {28,40}, {28,41}, {29,42}, {29,43} }, R.suede[3]) W.put(c, { {37,44}, {37,45}, {36,46} }, R.suede[2])
  -- broad round bead collar
  local outer = c:ellipse(32, 16, 13, 6)
  local inner = c:ellipse(32, 13, 4, 2)
  local collar = outer:copy():cut(inner)
  W.sep(c, collar, body:copy():add(smL):add(smR), ink)
  local ci = C.lit(c, collar, R.suede, { R = 2 })
  local rows = { R.ember, R.brass, R.jay, R.yarnB, R.canvas }
  collar:each(function(x, y)
    local d = sqrt(((x - 32) / 13) ^ 2 + ((y - 16) / 6) ^ 2)
    local r = min(5, floor((d - 0.38) / 0.12) + 1)
    if r < 1 then r = 1 end
    local i = ci[K(x, y)]
    if (x + y) % 2 == 0 then c:put(x, y, rows[r][min(6, i + 1)]) else c:put(x, y, rows[r][max(1, i - 1)]) end
  end)
  c:fillMask(inner:clip(outer), R.suede[1])
  W.hline(c, 29, 35, 15, R.suede[2])
  -- quirk: a tiny brass bell on the hem
  W.vline(c, 32, 58, 59, R.strap[3])
  local bell = c:poly{ {30,62}, {31,60}, {33,60}, {34,62} }:add(c:rect(31, 60, 33, 60))
  C.lit(c, bell, R.brass, { R = 1 })
  c:put(31, 61, R.brass[6]) c:put(32, 63, R.brass[2])
  c:put(21, 20, R.suede[6]) c:put(22, 19, C.cream)
end

C.run{
  { "coat-1-barkcloth-smock", smock },
  { "coat-2-stripe-weave-vest", vest },
  { "coat-3-highland-wool-coat", woolcoat },
  { "coat-4-savanna-field-jacket", jacket },
  { "coat-5-beaded-tunic-coat", tunic },
}
