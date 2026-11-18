-- EE cloaks: 5 concepts (see concepts.md). Run: AppRun -b --script-param png=<dir>/ --script cloak.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R = C.HP, C.X, C.K, C.R
local floor, max, min, abs = math.floor, math.max, math.min, math.abs

---------------------------------------------------------------- 1 shaggy shepherd cape
if C.want("cloak-1") then
  local c = C.new("cloak-1-shaggy-shepherd-cape")
  local cape = c:poly{ {25, 6}, {39, 6}, {44, 12}, {54, 52}, {10, 52}, {20, 12} }
  -- shaggy hem: long tufts of uneven length
  for x = 10, 54, 3 do
    local len = 3 + floor(C.hash(x, 1, 5) * 5)
    cape:add(c:poly{ {x - 0.5, 50}, {x + 3, 50}, {x + 1.5, 52 + len} })
  end
  -- side tufts
  for y = 16, 48, 4 do
    local wx = 20 - (y - 12) * 10 / 40
    cape:add(c:poly{ {wx + 1, y}, {wx - 3, y + 2}, {wx + 1, y + 3} })
    local ex = 44 + (y - 12) * 10 / 40
    cape:add(c:poly{ {ex - 1, y}, {ex + 3, y + 2}, {ex - 1, y + 3} })
  end
  local shag = function(x, y, i)
    local h = C.hash(x, 0, 11)
    local ph = (y + floor(h * 7)) % 7
    if ph == 0 then return -2 elseif ph == 1 then return -1 elseif ph == 4 and h > .5 then return 1 end
  end
  C.part(c, cape, R.fleece, { R = 6, hs = .7, tex = shag, cuts = { .2, .36, .52, .7, .88 } })
  -- deep folds
  for _, f in ipairs({ { 24, 24, 21, 50 }, { 32, 22, 32, 52 }, { 40, 24, 43, 50 } }) do
    local l = c:line({ {f[1], f[2]}, {f[3], f[4]} }, 1)
    l:each(function(x, y) if cape:has(x, y) and y % 3 ~= 0 then c:put(x, y, R.fleece[2]) end end)
  end
  -- neck: dark opening and cord tie
  local neck = c:ellipse(32, 7, 6, 2)
  C.fill(c, neck, R.sole[2])
  local cord = c:line({ {26, 10}, {32, 12}, {38, 10} }, 1)
  C.fill(c, cord, R.strap[3])
  local tie = c:line({ {32, 12}, {30, 19} }, 1):add(c:line({ {32, 12}, {34, 18} }, 1))
  C.fill(c, tie, R.strap[2])
  C.dots(c, { {30, 20}, {34, 19} }, R.strap[4]) c:put(32, 12, R.strap[5])
  -- quirk: a bramble burr with a blackberry stuck in the wool
  local burr = c:ellipse(43, 38, 2.5, 2.5)
  C.fill(c, burr, "#6a7a3a")
  C.dots(c, { {43, 35}, {46, 38}, {43, 41}, {40, 38}, {41, 36}, {45, 36}, {45, 40}, {41, 40} }, "#4a5a2c")
  c:put(42, 37, "#9aa856")
  local berry = c:ellipse(39, 42, 2, 2)
  C.fill(c, berry, R.plum[2])
  C.dots(c, { {38, 41}, {40, 42}, {39, 43} }, R.plum[4]) c:put(38, 41, R.plum[6])
  C.dots(c, { {40, 39}, {41, 39} }, R.leaf[4])
  -- wool highlight
  C.dots(c, { {22, 15}, {23, 15}, {22, 16} }, C.cream)
  C.save(c, "cloak-1-shaggy-shepherd-cape")
end

---------------------------------------------------------------- 2 poppy field shawl
if C.want("cloak-2") then
  local c = C.new("cloak-2-poppy-field-shawl")
  local sh = c:poly{ {6, 17}, {12, 11}, {21, 8}, {32, 7}, {43, 8}, {52, 11}, {58, 17}, {32, 50} }
  -- fringe hanging straight down from the two slanted edges
  local fr = HP.mask()
  for x = 6, 58, 2 do
    local yb
    for y = 60, 0, -1 do if sh:has(x, y) then yb = y break end end
    if yb then
      local len = 4 + ((x % 6 == 0) and 2 or 0)
      fr:add(c:line({ {x, yb + 1}, {x, yb + len} }, 1))
    end
  end
  fr:cut(sh)
  fr:each(function(x, y) c:put(x, y, (x < 32) and R.ember[3] or R.ember[2]) end)
  fr:each(function(x, y) if not fr:has(x, y + 1) then c:put(x, y, R.ember[1]) end end)
  local idx = C.part(c, sh, R.jay, { R = 4, bias = -1, cuts = { .2, .36, .52, .7, .9 } })
  -- top fold: the turned-back edge
  for x = 6, 58 do
    local yt for y = 0, 30 do if sh:has(x, y) then yt = y break end end
    if yt then c:put(x, yt, R.jay[5]) c:put(x, yt + 1, R.jay[4]) c:put(x, yt + 4, R.jay[1]) end
  end
  -- big poppies with leaves
  local function poppy(cx, cy, r)
    local lf = c:poly{ {cx + r - 1, cy + 1}, {cx + r + 4, cy + r + 1}, {cx + r - 1, cy + r} }
    C.fill(c, lf, R.leaf[3]) c:put(cx + r, cy + 2, R.leaf[5])
    local lf2 = c:poly{ {cx - r + 1, cy + 1}, {cx - r - 4, cy + r}, {cx - r + 2, cy + r - 1} }
    C.fill(c, lf2, R.leaf[4])
    local p = c:ellipse(cx, cy, r, r - 0.5)
    C.part(c, p, R.ember, { R = 2 })
    C.dots(c, { {cx, cy - r + 1}, {cx, cy + r - 1}, {cx - r + 1, cy}, {cx + r - 1, cy} }, R.ember[2])
    local ctr = c:ellipse(cx, cy, 1, 1)
    C.fill(c, ctr, C.ink) c:put(cx - 1, cy - 1, R.plum[3])
    c:put(cx - r + 2, cy - r + 2, R.ember[6]) c:put(cx - r + 3, cy - r + 1, R.ember[6])
  end
  poppy(19, 21, 5) poppy(44, 21, 5) poppy(32, 34, 4)
  -- tiny white-cream flowers scattered (cornfield)
  C.dots(c, { {30, 19}, {11, 17}, {52, 17}, {26, 28}, {38, 28}, {32, 43} }, R.linen[5])
  C.dots(c, { {33, 19}, {36, 41}, {28, 41} }, R.jay[6])
  -- quirk: a ladybird walking on the top edge
  local lb = c:ellipse(52, 9, 2.5, 2)
  C.fill(c, lb, R.ember[4])
  C.dots(c, { {52, 8}, {52, 9}, {52, 10} }, C.ink) C.dots(c, { {51, 9}, {53, 10} }, C.ink)
  C.dots(c, { {55, 8}, {55, 9} }, C.ink) c:put(51, 8, R.ember[6])
  C.save(c, "cloak-2-poppy-field-shawl")
end

---------------------------------------------------------------- 3 birch hooded mantle
if C.want("cloak-3") then
  local c = C.new("cloak-3-birch-hooded-mantle")
  local mantle = c:poly{ {22, 20}, {42, 20}, {51, 28}, {58, 57}, {6, 57}, {13, 28} }
  local hood = c:poly{ {30, 3}, {35, 3}, {44, 14}, {46, 26}, {18, 26}, {20, 14} }
  local bark = function(x, y, i)
    local h = C.hash(floor(x / 3), y, 13)
    if h < .07 then return -3 elseif h < .12 then return -2 end
  end
  local mi = C.part(c, mantle, R.birch, { R = 5, tex = bark, cuts = { .2, .36, .52, .7, .9 } })
  -- folds
  for _, f in ipairs({ { 22, 30, 15, 56 }, { 27, 30, 25, 56 }, { 37, 30, 39, 56 }, { 42, 30, 49, 56 } }) do
    c:line({ {f[1], f[2]}, {f[3], f[4]} }, 1):clip(mantle):each(function(x, y) c:put(x, y, R.birch[3]) end)
  end
  -- front opening
  for y = 27, 56 do c:put(32, y, R.birch[1]) end
  -- hem band: birch-dark border
  for x = 6, 58 do if mantle:has(x, 56) then c:put(x, 55, R.birch[2]) c:put(x, 56, R.birch[1]) end end
  C.sep(c, hood, mantle, C.ink)
  C.part(c, hood, R.birch, { R = 4, tex = bark, cuts = { .22, .4, .56, .72, .9 } })
  -- face opening (shadowed inside)
  local face = c:poly{ {32, 9}, {38, 15}, {39, 21}, {36, 26}, {28, 26}, {25, 21}, {26, 15} }:clip(hood)
  C.ring(c, face, R.birch[2], hood)
  C.fill(c, face, R.sole[2])
  local fl = c:ellipse(32, 20, 4, 4):clip(face)
  C.fill(c, fl, R.sole[1])
  -- hood rim lit edge
  C.dots(c, { {24, 18}, {24, 17}, {25, 15}, {26, 14}, {27, 13}, {28, 12} }, R.birch[6])
  -- dark bark marks (birch dashes), horizontal
  for _, p in ipairs({ {16, 36}, {22, 46}, {36, 40}, {46, 48}, {28, 51}, {20, 30}, {42, 33}, {40, 19}, {21, 21}, {11, 50}, {51, 42} }) do
    if mantle:has(p[1], p[2]) or hood:has(p[1], p[2]) then
      C.dots(c, { {p[1], p[2]}, {p[1] + 1, p[2]}, {p[1] + 2, p[2]} }, C.ink)
      c:put(p[1] + 1, p[2] - 1, R.birch[2])
    end
  end
  -- clasp
  local cl = c:rrect(29, 26, 35, 28, 1)
  C.part(c, cl, R.wood, { R = 1 })
  -- quirk: catkin dangling from the hood tip
  local str = c:line({ {34, 3}, {37, 2}, {39, 4} }, 1)
  C.fill(c, str, R.leaf[2])
  local cat = c:poly{ {37.5, 4}, {41.5, 4}, {42, 12}, {40.5, 14}, {38, 12} }
  C.ring(c, cat, R.birch[1], hood)
  C.part(c, cat, R.straw, { R = 1, bias = 1, tex = function(x, y) if y % 2 == 0 then return -1 end end })
  c:put(38, 5, R.straw[6])
  local lf = c:poly{ {35, 1}, {38, -1}, {39, 2} }
  C.fill(c, lf, R.leaf[4])
  C.save(c, "cloak-3-birch-hooded-mantle")
end

---------------------------------------------------------------- 4 wheatfield poncho
if C.want("cloak-4") then
  local c = C.new("cloak-4-wheatfield-poncho")
  local pon = c:poly{ {22, 8}, {42, 8}, {58, 20}, {58, 48}, {6, 48}, {6, 20} }
  local idx = C.part(c, pon, R.straw, { R = 5, cuts = { .2, .36, .52, .7, .9 } })
  -- woven stripes: rust bands with a thin teal line
  pon:each(function(x, y)
    local i = idx[K(x, y)]
    local b = (y - 8) % 12
    if b >= 7 and b <= 9 then c:put(x, y, R.yarnA[i])
    elseif b == 10 then c:put(x, y, R.yarnB[max(1, i - 1)])
    elseif b == 5 and (x % 4 == 0) then c:put(x, y, R.yarnA[max(1, i)])
    elseif (x + y) % 2 == 0 and b < 5 then c:put(x, y, R.straw[max(1, i - 1)]) end
  end)
  -- drape folds: the cloth hangs from the shoulders
  for _, f in ipairs({ { 18, 14, 14, 47 }, { 46, 14, 50, 47 } }) do
    c:line({ {f[1], f[2]}, {f[3], f[4]} }, 1):clip(pon):each(function(x, y) local i = idx[K(x, y)] c:put(x, y, ((y - 8) % 12 >= 7 and (y - 8) % 12 <= 9) and R.yarnA[max(1, i - 2)] or R.straw[max(1, i - 2)]) end)
  end
  -- neck opening with a rolled collar
  local col = c:ellipse(32, 9, 9, 3.5)
  C.ring(c, col, R.straw[1], pon)
  C.part(c, col, R.yarnA, { R = 2 })
  local nh = c:ellipse(32, 9, 6, 1.5)
  C.fill(c, nh, R.sole[2])
  -- fringe along the hem
  for x = 7, 57, 2 do
    local len = 4 + ((x % 6 == 1) and 1 or 0)
    for y = 49, 48 + len do c:put(x, y, (x < 32) and R.straw[4] or R.straw[3]) end
    c:put(x, 48 + len + 1, R.straw[2])
  end
  -- quirk: a wheat ear tucked at the neck
  local st = c:line({ {38, 11}, {44, 3} }, 1)
  C.fill(c, st, R.straw[3])
  for i, p in ipairs({ {44, 2}, {45, 1}, {42, 4}, {43, 3}, {46, 0} }) do
    local g = c:ellipse(p[1], p[2], 1, 0.6)
    C.fill(c, g, R.straw[5])
  end
  C.dots(c, { {43, 4}, {44, 3}, {45, 2} }, R.straw[3])
  C.dots(c, { {47, 0}, {46, 2}, {41, 2} }, R.straw[6])
  -- highlight
  C.dots(c, { {9, 22}, {10, 22}, {9, 23} }, R.straw[6])
  C.save(c, "cloak-4-wheatfield-poncho")
end

---------------------------------------------------------------- 5 fox-collar capelet
if C.want("cloak-5") then
  local c = C.new("cloak-5-fox-collar-capelet")
  local cape = c:poly{ {18, 18}, {46, 18}, {58, 40}, {54, 46}, {32, 49}, {10, 46}, {6, 40} }
  local wool = function(x, y, i) if (x + y) % 4 == 0 and C.hash(x, y, 3) < .5 then return -1 end end
  local ci = C.part(c, cape, R.storm, { R = 5, tex = wool, cuts = { .2, .36, .52, .7, .9 } })
  -- pleat folds radiating from the neck
  for _, f in ipairs({ { 22, 26, 14, 45 }, { 28, 28, 24, 48 }, { 36, 28, 40, 48 }, { 42, 26, 50, 45 } }) do
    c:line({ {f[1], f[2]}, {f[3], f[4]} }, 1):clip(cape):each(function(x, y) c:put(x, y, R.storm[2]) end)
    c:line({ {f[1] - 1, f[2]}, {f[3] - 1, f[4]} }, 1):clip(cape):each(function(x, y) if ci[K(x, y)] and ci[K(x, y)] < 5 then c:put(x, y, R.storm[ci[K(x, y)] + 1]) end end)
  end
  -- hem trim
  for x = 7, 57 do for y = 38, 49 do if cape:has(x, y) and not cape:has(x, y + 1) then c:put(x, y, R.storm[1]) c:put(x, y - 1, R.jay[4]) end end end
  -- big fox-fur collar: a lumpy ring of tufts
  local fur = c:ellipse(32, 18, 18, 8)
  for _, p in ipairs({ {14, 18}, {18, 24}, {25, 26}, {32, 27}, {39, 26}, {46, 24}, {50, 18}, {46, 12}, {39, 10}, {32, 10}, {25, 10}, {18, 12} }) do
    fur:add(c:ellipse(p[1], p[2], 3, 3))
  end
  C.sep(c, fur, cape, C.ink)
  local fi = C.part(c, fur, R.autumn, { R = 5, hs = .8, cuts = { .2, .36, .52, .7, .88 }, tex = function(x, y, i)
    if (x * 3 + y * 2) % 7 == 0 then return -1 elseif (x + y * 3) % 9 == 0 then return 1 end
  end })
  -- cream fur tips along the lower edge
  fur:each(function(x, y) if not fur:has(x, y + 1) and x % 2 == 0 then c:put(x, y, R.linen[5]) end end)
  -- neck hole
  local nh = c:ellipse(32, 17, 9, 3)
  C.fill(c, nh, R.storm[1]) C.dots(c, { {26, 16}, {27, 16}, {28, 16} }, R.sole[3])
  for x = 24, 40 do if nh:has(x, 15) then c:put(x, 15, R.sole[2]) end end
  -- cord clasp + quirk: amber bead
  local cord = c:line({ {28, 25}, {32, 30} }, 1):add(c:line({ {36, 25}, {32, 30} }, 1))
  C.fill(c, cord, R.strap[2])
  local bead = c:ellipse(32, 32, 2.5, 2.5)
  C.ring(c, bead, R.storm[1], cape)
  local bi = C.part(c, bead, R.brass, { R = 2 })
  C.dots(c, { {33, 33}, {33, 34}, {34, 33} }, R.autumn[2]) c:put(31, 31, C.cream)
  C.dots(c, { {16, 30}, {15, 31} }, R.storm[6])
  C.save(c, "cloak-5-fox-collar-capelet")
end
