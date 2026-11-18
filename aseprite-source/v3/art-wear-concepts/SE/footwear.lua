-- footwear.lua: Olivewhistle Shore (SE) footwear concepts, 5 icons 64x64.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, W = C.HP, C.X, C.K, C.R, C
local ink, cream = C.ink, C.cream
local only = app.params.only

-- 1 Shoreline Rope Slips --------------------------------------------------------
local function f1()
  local c = C.canvas("footwear-1-rope-slips")
  local function shoe(dx, dy, b)
    local S = function(m) return m:shift(dx, dy) end
    local sole = S(c:rrect(8, 41, 47, 48, 3))
    local up = S(c:poly{ {8,42}, {8,32}, {11,28}, {16,30}, {22,34}, {30,34}, {38,35}, {44,38}, {47,41}, {47,42} })
    local mouth = S(c:ellipse(17, 31, 6, 1.5)):clip(up)
    local all = sole:copy():add(up)
    local paint = function()
      -- upper: linen with sea stripes (same tone index on the other ramp)
      local idx = C.part(c, up, R.linen, { b = b, R = 4, tex = C.linen })
      up:each(function(x, y)
        if ((y - dy) - 29) % 4 >= 2 then c:put(x, y, R.sea[math.max(1, math.min(6, idx[K(x, y)] - 1))]) end
      end)
      -- mouth: dark lining with a lit back rim
      c:fillMask(mouth, R.jute[1])
      mouth:edge():each(function(x, y) if y >= 32 + dy then c:put(x, y, R.jute[3]) end end)
      -- toe stitch seam
      for x = 30 + dx, 45 + dx, 2 do if up:has(x, 37 + dy + (x - dx > 40 and 1 or 0)) then c:put(x, 37 + dy + (x - dx > 40 and 1 or 0), R.linen[5]) end end
      -- jute sole: coiled braid chevrons
      local si = C.part(c, sole, R.jute, { b = b, R = 2 })
      sole:each(function(x, y)
        local yy, xx = y - dy, x - dx
        local d = ((xx + (yy % 2 == 0 and 0 or 1)) % 3 == 0) and -1 or 0
        if yy == 45 then d = -1 end
        if d ~= 0 then c:put(x, y, R.jute[math.max(1, si[K(x, y)] + d)]) end
      end)
      for x = 9 + dx, 46 + dx do c:put(x, 41 + dy, R.jute[1]) c:put(x, 42 + dy, R.jute[5 + (b or 0)]) end
    end
    return all, paint
  end
  local ba, bp = shoe(9, -7, -1)
  local fa, fp = shoe(0, 0, nil)
  bp()
  C.sep(c, fa, ba, ink)
  fp()
  -- ankle ribbon: a loose loop rising from the heel, end hanging down
  local rib = c:line({ {10,30}, {7,24}, {9,18}, {15,16}, {20,19}, {19,24} }, 2)
  rib:each(function(x, y) c:put(x, y, R.sea[(x < 12 or y < 18) and 5 or 3]) end)
  local tail = c:line({ {10,30}, {14,24}, {16,22} }, 1)
  tail:each(function(x, y) c:put(x, y, R.sea[2]) end)
  -- quirk: scallop shell at the ribbon end
  local sh = c:poly{ {16.5,23}, {23,25}, {21,30}, {18,30} }:add(c:ellipse(19.5, 26.5, 3, 2.5))
  C.part(c, sh, R.coral, { R = 1, b = 1 })
  W.put(c, { {18,27}, {20,27}, {19,29}, {21,28}, {19,26} }, R.coral[3])
  c:put(18, 25, R.coral[6]) c:put(17, 26, cream)
  -- canvas glint
  W.hline(c, 12, 15, 34, R.linen[6]) c:put(11, 34, cream)
  C.save(c, "footwear-1-rope-slips")
end

-- 2 Sunpath Sandals (top-down pair) -------------------------------------------------
local function f2()
  local c = C.canvas("footwear-2-sunpath-sandals")
  local function sandal(dx, dy, b, flip)
    local S = function(m) return m:shift(dx, dy) end
    local sole = S(c:ellipse(0, 0, 7, 9):add(c:ellipse(0, 19, 5.5, 6.5)):add(c:poly{ {-7,2}, {7,2}, {5.5,19}, {-5.5,19} }))
    local paint = function()
      local si = C.part(c, sole, R.cork, { b = b, R = 2 })
      -- footbed: lighter worn leather inset
      local bed = sole:shrink(2)
      C.part(c, bed, R.leather, { b = (b or 0) + 1, R = 3 })
      -- toe-print dark worn spots
      W.put(c, { {dx-2,dy-4}, {dx-1,dy-4}, {dx-2,dy+20}, {dx-1,dy+20}, {dx,dy+20}, {dx-1,dy+21} }, R.leather[3])
      -- straps: toe loop, crossed vamp straps, heel strap
      local st = HP.mask()
      st:add(c:line({ {dx-6,dy-1}, {dx,dy-5}, {dx+6,dy-1} }, 2))
      st:add(c:line({ {dx-6,dy+4}, {dx+6,dy+12} }, 2)):add(c:line({ {dx+6,dy+4}, {dx-6,dy+12} }, 2))
      st:add(c:line({ {dx-6,dy+18}, {dx+6,dy+18} }, 3))
      st:clip(sole:grow(1))
      W.sep(c, st, sole, R.strap[1])
      local sti = C.part(c, st, R.strap, { b = b, R = 1 })
      st:each(function(x, y) if not st:has(x, y - 1) then c:put(x, y, R.strap[5 + (b or 0)]) end end)
    end
    return sole, paint
  end
  local la, lp = sandal(20, 16, -1)
  local ra, rp = sandal(38, 22, nil)
  lp()
  rp()
  -- brass buckle on the right heel strap
  local bk = c:rect(43, 38, 46, 42)
  C.part(c, bk, R.brass, { R = 1 })
  c:fillMask(c:rect(44, 39, 45, 41), R.strap[2])
  c:put(43, 38, R.brass[6])
  -- long laces trailing from both heel straps
  local lace = c:line({ {14,34}, {11,40}, {12,46}, {17,50}, {22,50} }, 1):add(c:line({ {32,40}, {28,46}, {30,52}, {36,54}, {42,52} }, 1))
  lace:each(function(x, y) c:put(x, y, R.strap[(x + y) % 3 == 0 and 2 or 4]) end)
  -- quirk: olive-leaf charm on a brass ring off the buckle
  local ring = c:ellipse(49, 44, 1.5, 1.5):cut(c:rect(49, 44, 49, 44))
  c:fillMask(ring, R.brass[4]) c:put(48, 43, R.brass[6])
  local lf = c:poly{ {49,46}, {52,47}, {53,51}, {51,53} }
  C.part(c, lf, R.sage, { R = 1, b = 1 })
  c:put(50, 47, R.sage[6])
  local o1 = c:ellipse(47, 49, 1.5, 1.5) local o2 = c:ellipse(48, 52, 1.5, 1.5)
  C.part(c, o1, R.grape, { R = 1 }) C.part(c, o2, R.olive, { R = 1 })
  c:put(46, 48, R.grape[6]) c:put(47, 51, R.olive[6])
  C.save(c, "footwear-2-sunpath-sandals")
end

-- 3 Corkbark Clogs ----------------------------------------------------------------
local function f3()
  local c = C.canvas("footwear-3-corkbark-clogs")
  local function clog(dx, dy, b)
    local S = function(m) return m:shift(dx, dy) end
    local sole = S(c:poly{ {9,38}, {45,38}, {48,42}, {46,48}, {27,48}, {24,52}, {11,52}, {9,48} })
    local up = S(c:poly{ {21,39}, {22,33}, {26,29}, {33,27}, {41,28}, {46,32}, {48,36}, {48,39} })
    local all = sole:copy():add(up)
    local paint = function()
      -- cork sole: speckled bark with strata lines
      local si = C.part(c, sole, R.cork, { b = b, R = 3 })
      W.retone(c, sole, si, R.cork, function(x, y)
        local h = X.hash(x, y, 7)
        if h < .2 then return -1 elseif h > .88 then return 1 end
        if (y - dy) == 45 and h < .6 then return -1 end
      end)
      for x = 10 + dx, 45 + dx do c:put(x, 39 + dy, R.cork[6 + (b or 0)]) end
      -- heel bed visible (open back mule)
      for x = 10 + dx, 21 + dx do c:put(x, 38 + dy, R.cork[2]) end
      -- upper: terracotta leather dome
      W.sep(c, up, sole, R.terra[1])
      local ui = C.part(c, up, R.terra, { b = b, R = 5, hs = 0.8 })
      -- stitched welt along the bottom of the upper
      for x = 23 + dx, 47 + dx, 2 do if up:has(x, 37 + dy) then c:put(x, 37 + dy, R.terra[6]) end end
      -- opening edge
      W.put(c, { {21+dx,36+dy}, {21+dx,35+dy}, {22+dx,34+dy}, {22+dx,33+dy}, {23+dx,32+dy} }, R.terra[1])
      -- nail heads
      for _, p in ipairs({ {25,34}, {29,31}, {34,30} }) do c:put(p[1] + dx, p[2] + dy, R.brass[4]) end
    end
    return all, paint
  end
  local ba, bp = clog(10, -6, -1)
  local fa, fp = clog(0, 0, nil)
  bp()
  W.sep(c, fa, ba, ink)
  fp()
  -- leather sheen
  W.put(c, { {28,30}, {29,29}, {30,29}, {31,29} }, R.terra[6]) c:put(29, 30, cream)
  -- quirk: acorn on the toe
  local cup = c:ellipse(42, 29, 3.5, 2)
  local nut = c:ellipse(42, 33, 2.5, 3):cut(cup)
  C.part(c, nut, R.saffron, { R = 2, b = -1 })
  C.part(c, cup, R.goat, { R = 1 })
  W.put(c, { {40,29}, {42,29}, {44,29}, {41,30}, {43,30} }, R.goat[2])
  W.put(c, { {42,26}, {43,25} }, R.wood[2])
  c:put(41, 32, R.saffron[6]) c:put(41, 33, R.saffron[5])
  C.save(c, "footwear-3-corkbark-clogs")
end

-- 4 Thyme-Hill Wraps --------------------------------------------------------------
local function f4()
  local c = C.canvas("footwear-4-thyme-hill-wraps")
  local function leg(dx, dy, b)
    local S = function(m) return m:shift(dx, dy) end
    local wrap = S(c:poly{ {13,8}, {27,8}, {27,40}, {14,41} })
    local foot = S(c:rrect(12, 38, 30, 49, 4):add(c:ellipse(31, 45, 6, 4.5)))
    local sole = S(c:rrect(11, 49, 38, 51, 1))
    local all = wrap:copy():add(foot):add(sole)
    local paint = function()
      -- moccasin foot and sole
      local fi = C.part(c, foot:copy():cut(wrap), R.leather, { b = b, R = 5, hs = 0.7 })
      C.part(c, sole, R.strap, { b = b, R = 1 })
      -- moccasin pucker stitches over the toe
      for _, p in ipairs({ {30,41}, {32,42}, {34,43}, {35,45} }) do c:put(p[1] + dx, p[2] + dy, R.leather[2]) end
      -- spiral goat-hair wrap bands (diagonal)
      W.sep(c, wrap, foot, R.goat[1])
      local wi = C.vc(c, wrap, R.goat, 13 + dx, 27 + dx, { b = b, tex = C.felt })
      wrap:each(function(x, y)
        local u = (y - dy) + math.floor((x - dx) / 3)
        if u % 6 == 0 then c:put(x, y, R.goat[math.max(1, wi[K(x, y)] - 2)])
        elseif u % 6 == 1 then c:put(x, y, R.goat[math.min(6, wi[K(x, y)] + 1)]) end
      end)
      -- cross-gartered leather thongs
      local th = HP.mask()
      for i = 0, 3 do
        local y0 = 12 + i * 8
        th:add(c:line({ {13 + dx, y0 + dy}, {27 + dx, y0 + 6 + dy} }, 1)):add(c:line({ {27 + dx, y0 + dy}, {13 + dx, y0 + 6 + dy} }, 1))
      end
      th:clip(wrap)
      th:each(function(x, y) c:put(x, y, (x - dx) < 20 and R.strap[4 + (b or 0)] or R.strap[2]) end)
      -- top turn-over band
      local top = S(c:rrect(12, 7, 28, 11, 1))
      C.part(c, top, R.goat, { b = (b or 0) + 1, R = 1 })
      W.hline(c, 13 + dx, 27 + dx, 11 + dy, R.goat[1])
    end
    return all, paint
  end
  local ba, bp = leg(11, -5, -1)
  local fa, fp = leg(0, 0, nil)
  bp()
  W.sep(c, fa, ba, ink)
  fp()
  -- leather toe sheen
  W.put(c, { {31,42}, {32,41}, {28,40} }, R.leather[6])
  -- quirk: flowering thyme sprig tucked into the top band
  local stem = c:line({ {16,9}, {14,4}, {12,0 + 1} }, 1):add(c:line({ {15,6}, {18,3} }, 1))
  stem:each(function(x, y) if y < 7 then c:put(x, y, R.leaf[3]) end end)
  W.put(c, { {11,1}, {12,0 + 0}, {13,1}, {18,2}, {19,3}, {17,2} }, "#d89ac0")
  W.put(c, { {12,1}, {18,3} }, "#f4c8e0")
  W.put(c, { {13,3}, {16,4} }, R.leaf[5])
  C.save(c, "footwear-4-thyme-hill-wraps")
end

-- 5 Harvest Treaders ---------------------------------------------------------------
local function f5()
  local c = C.canvas("footwear-5-harvest-treaders")
  local tan = R.cork
  local function boot(dx, dy, b)
    local S = function(m) return m:shift(dx, dy) end
    local shaft = S(c:poly{ {12,22}, {27,23}, {28,40}, {12,42} })
    local foot = S(c:rrect(12, 36, 30, 48, 4):add(c:ellipse(32, 44, 7, 4.5)))
    local cuff = S(c:poly{ {10,17}, {29,18}, {30,26}, {26,28}, {20,26}, {14,28}, {10,25} })
    local sole = S(c:rrect(11, 48, 40, 50, 1))
    local all = shaft:copy():add(foot):add(cuff):add(sole)
    local paint = function()
      local body = shaft:copy():add(foot)
      -- soft pale leather on top, grape stain below the ankle line (wavy)
      local idx = C.part(c, body, tan, { b = (b or 0) + 1, R = 6, hs = 0.6 })
      body:each(function(x, y)
        local line = 38 + math.floor(1.5 * math.sin((x - dx) * 0.7))
        if (y - dy) >= line then c:put(x, y, R.grape[math.max(1, math.min(6, idx[K(x, y)] - 1))])
        elseif (y - dy) == line - 1 then c:put(x, y, R.grape[math.min(6, idx[K(x, y)])]) end
      end)
      -- slouch wrinkles
      for _, l in ipairs({ { {14,31}, {18,30}, {22,32} }, { {16,35}, {21,34}, {25,35} }, { {20,29}, {25,28} } }) do
        local m = c:line(l, 1):shift(dx, dy):clip(shaft)
        m:each(function(x, y) c:put(x, y, tan[3 + (b or 0)]) c:put(x, y - 1, tan[6 + (b or 0)]) end)
      end
      C.part(c, sole, R.strap, { b = b, R = 1 })
      -- folded cuff, floppy
      W.sep(c, cuff, body, tan[1])
      C.part(c, cuff, tan, { b = (b or 0) + 1, R = 3 })
      local fold = c:line({ {11,21}, {20,22}, {29,22} }, 1):shift(dx, dy)
      fold:each(function(x, y) c:put(x, y, tan[3 + (b or 0)]) end)
      -- cuff drawstring
      for x = 12 + dx, 28 + dx, 2 do c:put(x, 24 + dy, R.strap[2]) end
    end
    return all, paint
  end
  local ba, bp = boot(10, -6, -1)
  local fa, fp = boot(0, 0, nil)
  bp()
  W.sep(c, fa, ba, ink)
  fp()
  -- juice drips on the front boot
  W.put(c, { {16,36}, {16,37}, {24,35}, {24,36}, {24,37} }, R.grape[3])
  -- quirk: a plump grape stuck on the toe, with a twig
  local g = c:ellipse(25, 21, 2.5, 2.5)
  C.part(c, g, R.grape, { R = 2, b = 1 })
  c:put(24, 20, R.grape[6]) c:put(23, 20, cream)
  W.put(c, { {26,18}, {27,17} }, R.leaf[3]) c:put(28, 17, R.leaf[5])
  -- leather sheen
  W.put(c, { {14,24}, {15,24}, {16,24} }, tan[6])
  C.save(c, "footwear-5-harvest-treaders")
end

local all = { f1, f2, f3, f4, f5 }
for i, f in ipairs(all) do if not only or tonumber(only) == i then f() end end
