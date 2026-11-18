-- WCA cloak concepts (5). Run: AppRun -b --script-param png=<dir>/ --script cloak.lua [--script-param only=<name>]
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local ink, cream = C.ink, C.cream
local floor, abs, max, min, sin, pi = math.floor, math.abs, math.max, math.min, math.sin, math.pi
local function clampi(i) return max(1, min(6, i)) end

-- 1. Plantain Leaf Cape: overlapping big leaves on a vine collar. quirk: snail
local function leafcape(c)
  local function leaf(ax, ay, bx, by, w, b)
    local wf = function(t) if t > 0.98 then return -1 end return max(0.6, w * sin(pi * min(1, t * 0.95 + 0.08)) ^ 0.6) end
    local m, n, T, S = G.tube({ {ax,ay}, {ax + (bx-ax)*.33, ay + (by-ay)*.33}, {ax + (bx-ax)*.66, ay + (by-ay)*.66}, {bx,by} }, wf)
    return { m = m, n = n, T = T, S = S, b = b, w = w }
  end
  local function paint(L, under)
    if under then C.sep(c, L.m, under, ink) end
    local idx = C.toneN(c, L.m, L.n, R.plantain, { bias = C.bias(L.m, L.b), cuts = { .2, .36, .52, .68, .86 } })
    L.m:each(function(x, y)
      local s, t = L.S[K(x, y)], L.T[K(x, y)]
      if abs(s) < 0.16 and t < 0.9 then c:put(x, y, R.plantain[s <= 0 and 6 or 3]) end
      -- side veins
      local v = (t * 40 + abs(s) * 5) % 5
      if abs(s) > 0.3 and abs(s) < 0.85 and v < 0.7 then c:put(x, y, R.plantain[clampi(idx[K(x, y)] - 1)]) end
    end)
    -- torn notch at the edge (plantain leaves split)
    return L.m
  end
  local back = {
    leaf(18, 12, 6, 50, 7, -1), leaf(32, 12, 32, 58, 8, -1), leaf(46, 12, 58, 50, 7, -1),
  }
  local front = { leaf(24, 12, 17, 56, 8, 0), leaf(40, 12, 47, 56, 8, 0) }
  local all = HP.mask()
  for _, L in ipairs(back) do paint(L, nil) all:add(L.m) end
  for _, L in ipairs(front) do paint(L, all) all:add(L.m) end
  -- vine collar
  local vm, vi = C.tube(c, { {10,12}, {22,16}, {42,16}, {54,12} }, 2, R.forest)
  C.sep(c, vm, all, ink)
  C.tube(c, { {10,12}, {22,16}, {42,16}, {54,12} }, 2, R.forest)
  for _, p in ipairs({ {14,13}, {20,15}, {26,16}, {32,16}, {38,16}, {44,15}, {50,13} }) do c:put(p[1], p[2], R.forest[1]) c:put(p[1] + 1, p[2] - 1, R.forest[6]) end
  -- curl ends
  C.put(c, { {8,11}, {7,10}, {7,9}, {8,8}, {9,9} }, R.forest[4])
  C.put(c, { {56,11}, {57,10}, {57,9}, {56,8}, {55,9} }, R.forest[3])
  -- quirk: a snail on the right front leaf
  local sh = c:ellipse(46, 36, 3.6, 3.6)
  local bd = c:poly{ {40,39}, {49,39}, {49,41}, {39,41} }
  C.sep(c, sh:copy():add(bd), all, ink)
  C.lay(c, bd, R.cotton, { R = 1 })
  c:put(39, 38, R.cotton[4]) c:put(40, 37, R.cotton[4]) c:put(39, 37, R.cotton[2])
  C.lay(c, sh, R.calabash, { R = 2 })
  C.put(c, { {46,34}, {48,35}, {48,37}, {46,38}, {45,37}, {45,36}, {46,36} }, R.ochre[2])
  c:put(44, 34, R.calabash[6])
end

-- 2. Strip-Weave Shawl: folded shawl in bold block stripes, one fringed end hanging. quirk: cowrie
local function shawl(c)
  local blocks = { R.kente, R.forest, R.ember, R.kente, R.indigo }
  local function weave(m, idx, ox)
    m:each(function(x, y)
      local u = x - ox
      local r = blocks[(u // 6) % 5 + 1]
      local i = idx[K(x, y)]
      if u % 6 == 0 then i = i - 1 end
      -- tiny woven blocks inside the gold
      if r == R.kente and u % 6 == 3 and y % 4 == 0 then r = R.ember end
      c:put(x, y, r[clampi(i)])
    end)
  end
  local L1 = c:rrect(6, 40, 57, 51, 4)
  local L2 = c:rrect(7, 31, 56, 43, 4)
  local top = c:rrect(8, 17, 55, 34, 4)
  local hang = c:poly{ {38,24}, {50,24}, {52,54}, {40,54} }
  weave(L1, C.lay(c, L1, R.kente, { R = 3, bias = -1 }), 6)
  C.underline(c, L1, R.mud[2])
  C.sep(c, L2, L1, ink)
  weave(L2, C.lay(c, L2, R.kente, { R = 3, bias = 0 }), 4)
  C.sep(c, top, L2, ink)
  weave(top, C.lay(c, top, R.kente, { R = 4, bias = 1 }), 8)
  C.hline(c, 9, 54, 34, R.mud[2])
  for x = 9, 54 do c:put(x, 43, R.mud[2]) end
  -- hanging end with fringe
  C.sep(c, hang, top:copy():add(L2):add(L1), ink)
  local hi = C.lay(c, hang, R.kente, { R = 3, bias = 0 })
  hang:each(function(x, y)
    local r = ({ R.indigo, R.kente, R.ember })[((y - 24) // 6) % 3 + 1]
    local i = hi[K(x, y)]
    if (y - 24) % 6 == 0 then i = i - 1 end
    c:put(x, y, r[clampi(i)])
  end)
  for x = 41, 52, 2 do for y = 55, 59 do c:put(x, y, R.kente[(x < 46) and 5 or 3]) end c:put(x, 59 + (x % 4 == 1 and 1 or 0), R.kente[2]) end
  C.hline(c, 40, 52, 54, R.kente[1])
  -- fold shadow under the hanging end on the stack
  C.vline(c, 37, 25, 34, R.mud[2])
  -- quirk: cowrie shell sewn at the corner
  local cw = C.oval(52, 50, 2.4, 3.4, 0.3)
  C.sep(c, cw, hang, ink)
  C.ovalLit(c, 52, 50, 2.4, 3.4, 0.3, R.cotton, { bias = 1 })
  C.put(c, { {52,48}, {52,49}, {52,50}, {52,51} }, R.cotton[1])
  C.put(c, { {51,49}, {53,51} }, R.cotton[3])
  c:put(51, 48, cream)
end

-- 3. Indigo Hood Mantle: hanging hooded indigo cloak, resist dots on the hem. quirk: red parrot feather
local function hoodmantle(c)
  local cloak = c:poly{ {22,18}, {42,18}, {50,34}, {56,57}, {8,57}, {14,34} }
  local hood = c:poly{ {32,4}, {40,9}, {44,19}, {40,25}, {24,25}, {20,19}, {24,9} }
  local ci = C.lay(c, cloak, R.indigo, { R = 6, cuts = { .22, .4, .56, .72, .88 } })
  -- vertical drape folds
  C.retone(c, cloak, ci, R.indigo, function(x, y, i)
    local f = { 20, 27, 37, 45 }
    for _, fx in ipairs(f) do
      local xx = fx + (fx - 32) * (y - 25) / 40
      if y > 28 and abs(x - xx) < 0.6 then return -2 end
      if y > 28 and x - xx > 0.6 and x - xx < 1.6 then return 1 end
    end
  end)
  -- resist dots along the hem
  for x = 11, 53, 4 do
    for _, y in ipairs({ 51, 54 }) do
      local xx = x + (y == 54 and 2 or 0)
      if cloak:shrink(1):has(xx, y) then c:put(xx, y, (xx < 32) and R.cotton[6] or R.cotton[4]) end
    end
  end
  for x = 9, 55 do if cloak:has(x, 48) then c:put(x, 48, R.indigo[(x < 32) and 4 or 2]) end end
  C.sep(c, hood, cloak, ink)
  C.lay(c, hood, R.indigo, { R = 4, bias = 1 })
  -- hood opening (shadowed face hole)
  local op = c:ellipse(32, 17, 6, 6)
  c:fillMask(op, R.indigo[1])
  op:grow(1):cut(op):clip(hood):each(function(x, y) c:put(x, y, (x < 32 and y < 19) and R.indigo[6] or R.indigo[3]) end)
  C.put(c, { {29,22}, {30,22}, {31,22}, {32,22}, {33,22}, {34,22}, {35,22} }, R.indigo[2])
  -- quirk: grey parrot's red tail feather pinned at the throat with a brass pin
  local fm, fi, T, S = C.tube(c, { {33,25}, {37,30}, {40,36}, {41,42} }, function(t) return 0.6 + 2.2 * sin(pi * min(1, t * 1.05)) end, R.ember, { bias = 1 })
  C.sep(c, fm, cloak, ink)
  C.tube(c, { {33,25}, {37,30}, {40,36}, {41,42} }, function(t) return 0.6 + 2.2 * sin(pi * min(1, t * 1.05)) end, R.ember, { bias = 1 })
  fm:each(function(x, y) if abs(S[K(x, y)]) < 0.2 then c:put(x, y, R.ember[2]) end end)
  local pin = c:ellipse(32, 26, 2.2, 2.2)
  C.sep(c, pin, cloak:copy():add(fm), ink)
  C.lay(c, pin, R.brass, { R = 1 })
  c:put(31, 25, R.brass[6])
end

-- 4. Raffia Poncho: square straw poncho, red dyed chevron bands, long fringe. quirk: seed-pod rattle
local function poncho(c)
  local body = c:poly{ {22,10}, {42,10}, {58,26}, {32,52}, {6,26} }
  local fr = HP.mask()
  -- fringe below the two lower edges
  for x = 7, 57 do
    local yb = 26 + (32 - abs(x - 32)) * 26 / 26 - 0
    yb = floor(52 - abs(x - 32) * 26 / 26 + 0.5)
    if x % 2 == 0 then for y = yb, yb + 4 + (x % 4 == 0 and 1 or 0) do fr:set(x, y) end end
  end
  fr:cut(body)
  fr:each(function(x, y) c:put(x, y, R.raffia[(x < 32) and 4 or 3]) end)
  local bi = C.lay(c, body, R.raffia, { R = 3, cuts = { .22, .4, .56, .72, .88 } })
  C.retone(c, body, bi, R.raffia, function(x, y) if (x + y) % 3 == 0 then return -1 end end)
  -- soft centre drape fold from the neck down to the point
  for y = 22, 50 do c:put(32, y, R.raffia[2]) c:put(31, y, R.raffia[5]) end
  -- red chevron bands parallel to the lower edges
  body:each(function(x, y)
    local d = (52 - y) - abs(x - 32) * 26 / 26
    local dd = floor(d + 0.5)
    if dd == 4 or dd == 5 or dd == 10 then c:put(x, y, R.ember[clampi(bi[K(x, y)] - 1)]) end
    if dd == 7 and (x % 3 == 0) then c:put(x, y, R.mahogany[3]) end
  end)
  -- neck hole
  local nh = C.oval(32, 15, 6, 3, 0)
  c:fillMask(nh, R.raffia[1])
  nh:grow(1):cut(nh):each(function(x, y) c:put(x, y, y < 15 and R.raffia[2] or R.ember[4]) end)
  -- quirk: seed-pod rattle hanging from the left corner
  C.vline(c, 7, 27, 31, R.strap[2])
  local pod = C.oval(7, 36, 2.6, 4.2, 0.2)
  C.sep(c, pod, body:copy():add(fr), ink)
  C.ovalLit(c, 7, 36, 2.6, 4.2, 0.2, R.mahogany, { bias = 1 })
  C.put(c, { {7,34}, {7,36}, {7,38} }, R.calabash[5])
  c:put(6, 33, R.mahogany[6])
end

-- 5. Scaleleaf Mantle: short shoulder mantle of rounded leather tabs like pangolin plates. quirk: hornbill-beak clasp
local function scalemantle(c)
  local mant = c:poly{ {22,12}, {42,12}, {52,22}, {58,40}, {6,40}, {12,22} }
  local base = C.lay(c, mant, R.strap, { R = 4, bias = -2 })
  -- rows of scale tabs, bottom row first so each upper row overlaps
  local rows = { { y = 37, n = 9, x0 = 6, x1 = 58 }, { y = 32, n = 8, x0 = 9, x1 = 55 }, { y = 27, n = 7, x0 = 12, x1 = 52 }, { y = 22, n = 6, x0 = 15, x1 = 49 } }
  local tabs = HP.mask()
  for ri, r in ipairs(rows) do
    local step = (r.x1 - r.x0) / r.n
    for k = 0, r.n - 1 do
      local cx = r.x0 + step * (k + 0.5)
      local tm = c:ellipse(cx, r.y, step / 2, 4):clip(mant:copy():add(c:rect(0, r.y, 63, r.y + 5)))
      tm:cut(c:rect(0, 0, 63, r.y - 5))
      C.sep(c, tm, tabs, R.strap[1])
      local ramp = (ri % 2 == 0) and R.ochre or R.strap
      C.lay(c, tm, ramp, { R = 2, bias = (ri == 1) and -1 or 0 })
      tm:edge():each(function(x, y) if y <= r.y and x < cx then c:put(x, y, ramp[6]) end end)
      tabs:add(tm)
    end
  end
  -- collar roll
  local col = c:rrect(18, 11, 46, 17, 3)
  C.sep(c, col, tabs:copy():add(mant), ink)
  C.lay(c, col, R.strap, { R = 2, bias = -1 })
  for x = 20, 44, 3 do c:put(x, 14, R.strap[1]) end
  -- quirk: carved hornbill-beak clasp at the throat
  local casque = c:poly{ {25,9}, {33,8}, {37,12}, {26,13} }
  local beak = c:poly{ {25,13}, {37,12}, {46,17}, {44,20}, {36,17}, {26,17} }
  C.sep(c, beak:copy():add(casque), col:copy():add(tabs), ink)
  C.lay(c, casque, R.palm, { R = 1, bias = 1 })
  C.lay(c, beak, R.kente, { R = 2, bias = 1 })
  C.hline(c, 27, 36, 13, R.palm[2])
  C.put(c, { {37,15}, {39,16}, {41,17}, {42,18} }, R.kente[2])
  c:put(28, 15, ink) c:put(27, 14, R.kente[6]) c:put(26, 10, R.palm[6])
end

C.run{
  { "cloak-1-plantain-leaf-cape", leafcape },
  { "cloak-2-strip-weave-shawl", shawl },
  { "cloak-3-indigo-hood-mantle", hoodmantle },
  { "cloak-4-raffia-poncho", poncho },
  { "cloak-5-scaleleaf-mantle", scalemantle },
}
