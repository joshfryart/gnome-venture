-- coat.lua: Spicepeak (CSA) coat concepts, 5 icons 64x64 (garments laid out flat, front view). See concepts.md.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local ink, cream = C.ink, C.cream
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local CUT = { .2, .36, .52, .7, .88 }

---------------------------------------------------------------- 1 ikat robe coat
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "coat-1" }
  local slL = c:poly{ {22,10}, {12,14}, {3,36}, {5,41}, {15,40}, {20,26} }
  local slR = c:poly{ {42,10}, {52,14}, {61,36}, {59,41}, {49,40}, {44,26} }
  local body = c:poly{ {21,9}, {43,9}, {46,30}, {51,60}, {13,60}, {18,30} }
  local stripe = function(x, y)
    local j = (X.hash(0, floor(y / 2), 11) < .3) and 1 or 0
    local u = (x + j + 2) % 12
    if u < 4 then return R.madder elseif u < 5 then return R.feltc elseif u < 8 then return R.yarnB end
    return R.saffron
  end
  local quilt = function(x, y) if y % 5 == 0 then return -1 end end
  for _, sl in ipairs({ slL, slR }) do
    local i = C.part(c, sl, R.madder, { R = 3, b = -1, cuts = CUT, tex = quilt })
    C.swap(c, sl, i, stripe)
  end
  C.inkSep(c, body, slL:copy():add(slR))
  local bi = C.part(c, body, R.madder, { R = 4, cuts = CUT, tex = quilt })
  C.swap(c, body, bi, stripe)
  -- cuffs (binding)
  for _, cf in ipairs({ c:poly{ {3,36}, {15,39}, {15,41}, {4,41} }, c:poly{ {61,36}, {49,39}, {49,41}, {60,41} } }) do
    C.part(c, cf, R.lining, { R = 1 })
  end
  -- front opening with tan binding, overlapping right over left
  for y = 16, 59 do
    local x = 32 + floor((y - 16) / 14)
    c:put(x, y, R.lining[5]) c:put(x + 1, y, R.lining[3]) c:put(x + 2, y, ink)
  end
  C.hline(c, 14, 50, 59, R.lining[3])
  C.hline(c, 14, 50, 58, R.lining[5])
  -- collar V
  local col = c:poly{ {23,8}, {41,8}, {36,9}, {33,17}, {31,17}, {28,9} }
  local inner = c:poly{ {26,9}, {38,9}, {33,16}, {31,16} }
  c:fillMask(inner, R.indigo[2])
  C.put(c, { {24,9}, {25,10}, {26,11}, {27,12}, {28,13}, {29,14}, {30,15}, {31,16} }, R.lining[5])
  C.put(c, { {40,9}, {39,10}, {38,11}, {37,12}, {36,13}, {35,14}, {34,15}, {33,16} }, R.lining[3])
  C.hline(c, 22, 42, 8, R.lining[4])
  -- quirk: saffron crocus tucked at the collar
  local stem = c:line({ {25,17}, {26,22} }, 1)
  local lf = c:line({ {24,18}, {22,22} }, 1)
  local petals = c:poly{ {21,8}, {24,11}, {25,6}, {27,11}, {30,8}, {28,15}, {23,15} }
  C.inkSep(c, petals:copy():add(stem):add(lf), body)
  c:fillMask(stem, R.leaf[4]) c:fillMask(lf, R.leaf[5])
  C.part(c, petals, R.crocus, { R = 2, b = 1 })
  C.put(c, { {25,9}, {25,10}, {25,11}, {25,12} }, R.crocus[2])
  C.put(c, { {24,12}, {26,12}, {25,13} }, R.ember[4]) c:put(25, 12, R.saffron[5])
  c:put(22, 9, R.crocus[6]) c:put(25, 7, R.crocus[6])
  C.save(c, "coat-1-ikat-robe-coat")
end

---------------------------------------------------------------- 2 kantha patch vest
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "coat-2" }
  local body = c:poly{ {14,8}, {24,8}, {32,24}, {40,8}, {50,8}, {50,16}, {54,24}, {54,56}, {10,56}, {10,24}, {14,16} }
    :cut(c:ellipse(10, 20, 4, 7)):cut(c:ellipse(54, 20, 4, 7))
  local bi = C.part(c, body, R.plum, { R = 4, cuts = CUT })
  -- patches: irregular grid of cloth pieces
  local pal = { R.plum, R.yarnB, R.saffron, R.madder, R.indigo, R.feltc, R.yarnB, R.plum }
  local function patch(x, y)
    local cx = floor((x + (floor(y / 11) % 2) * 5) / 10)
    local cy = floor(y / 11)
    return pal[(cx * 3 + cy * 5) % #pal + 1], cx, cy
  end
  C.swap(c, body, bi, function(x, y) return (patch(x, y)) end)
  -- seams between patches
  body:each(function(x, y)
    local _, a, b = patch(x, y)
    local _, a2, b2 = patch(x + 1, y)
    local _, a3, b3 = patch(x, y + 1)
    if (a ~= a2 or b ~= b2) or (a ~= a3 or b ~= b3) then
      local r = patch(x, y) local i = bi[K(x, y)] c:put(x, y, r[max(1, i - 2)])
    end
  end)
  -- kantha running stitch: horizontal dashed rows
  body:shrink(1):each(function(x, y) if y % 3 == 1 and (x + y) % 4 < 2 then
    local i = bi[K(x, y)] c:put(x, y, R.feltc[min(6, i + 2)]) end end)
  -- front opening and binding
  for y = 24, 55 do c:put(31, y, R.madder[4]) c:put(32, y, ink) c:put(33, y, R.madder[2]) end
  body:edge():each(function(x, y) c:put(x, y, R.madder[(x + y < 60) and 5 or 3]) end)
  -- quirk: walnut shell button
  local nut = c:ellipse(29, 33, 2.6, 3)
  C.part(c, nut, R.yak, { R = 1, b = 1 })
  C.put(c, { {29,31}, {29,32}, {29,34}, {28,35} }, R.yak[2]) c:put(28, 31, R.yak[6])
  C.put(c, { {30,30}, {31,31} }, R.feltc[5])
  C.save(c, "coat-2-kantha-patch-vest")
end

---------------------------------------------------------------- 3 fleece-collar jacket
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "coat-3" }
  local slL = c:poly{ {19,12}, {11,16}, {6,46}, {14,47}, {18,26} }
  local slR = c:poly{ {45,12}, {53,16}, {58,46}, {50,47}, {46,26} }
  local body = c:poly{ {18,11}, {46,11}, {48,50}, {16,50} }
  local hide = function(x, y) if X.hash(x, y, 13) < .1 then return -1 end end
  C.part(c, slL, R.yak, { R = 3, b = -1, cuts = CUT, tex = hide })
  C.part(c, slR, R.yak, { R = 3, b = -1, cuts = CUT, tex = hide })
  C.inkSep(c, body, slL:copy():add(slR))
  C.part(c, body, R.yak, { R = 4, cuts = CUT, tex = hide })
  -- seams: front opening, pocket, yoke seam
  for y = 18, 49 do c:put(32, y, R.yak[1]) c:put(33, y, R.yak[5]) end
  C.put(c, { {20,38}, {21,38}, {22,38}, {23,38}, {24,38}, {25,38}, {26,38} }, R.yak[1])
  C.put(c, { {20,39}, {26,39} }, R.yak[2])
  -- curly fleece: collar, cuffs, hem
  local fleece = function(m, b)
    local i = C.part(c, m, R.feltc, { R = 2, b = b, cuts = CUT })
    m:each(function(x, y)
      local gx, gy = (x + (floor(y / 3) % 2) * 2) % 4, y % 3
      if gx == 0 and gy == 1 or gx == 1 and gy == 2 then c:put(x, y, R.feltc[max(1, i[K(x, y)] - 2)])
      elseif gx == 2 and gy == 0 then c:put(x, y, R.feltc[min(6, i[K(x, y)] + 1)]) end
    end)
  end
  local coll = c:poly{ {15,8}, {26,6}, {32,20}, {38,6}, {49,8}, {47,17}, {38,24}, {33,26}, {31,26}, {26,24}, {17,17} }
  local cuffs = c:rrect(5, 43, 15, 49, 2):add(c:rrect(49, 43, 59, 49, 2))
  local hem = c:rrect(15, 48, 49, 54, 2)
  C.inkSep(c, hem, body:copy():add(slL):add(slR))
  fleece(hem, -1)
  C.inkSep(c, cuffs, body:copy():add(slL):add(slR))
  fleece(cuffs, 0)
  C.inkSep(c, coll, body)
  fleece(coll, 1)
  -- notch shadow where the collar parts
  C.put(c, { {31,21}, {32,22}, {33,21}, {32,23}, {32,21}, {31,20}, {33,20} }, R.yak[2])
  C.put(c, { {31,19}, {33,19}, {32,20} }, R.yak[1])
  -- scuffed hide shine
  c:put(21, 20, R.yak[6]) c:put(22, 20, R.yak[6]) c:put(10, 22, R.yak[6])
  -- quirk: turquoise bead toggle at the throat on a cord loop
  C.put(c, { {29,27}, {30,28}, {34,28}, {35,27} }, R.strap[3])
  local bead = c:ellipse(32, 29, 2.2, 1.8)
  C.inkSep(c, bead, body:copy():add(coll))
  C.toneN(c, bead, X.sphere(31.6, 28.6, 2.2, bead), R.turq, {})
  c:put(31, 28, R.turq[6])
  C.save(c, "coat-3-fleece-collar-jacket")
end

---------------------------------------------------------------- 4 mirror-work smock
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "coat-4" }
  local slL = c:ellipse(14, 22, 10, 9):add(c:poly{ {14,22}, {22,14}, {22,30} })
  local slR = c:ellipse(50, 22, 10, 9):add(c:poly{ {50,22}, {42,14}, {42,30} })
  local body = c:poly{ {20,12}, {44,12}, {47,24}, {50,52}, {14,52}, {17,24} }
  local gather = function(x, y) if x % 3 == 0 then return -1 end end
  C.part(c, slL, R.indigo, { R = 4, b = -1, cuts = CUT })
  C.part(c, slR, R.indigo, { R = 4, b = -1, cuts = CUT })
  -- sleeve bands
  for _, sx in ipairs({ 6, 58 }) do
    local band = c:rrect(sx - 2, 18, sx + 2, 28, 1)
    C.part(c, band, R.madder, { R = 1 })
  end
  C.inkSep(c, body, slL:copy():add(slR))
  local bi = C.part(c, body, R.indigo, { R = 4, cuts = CUT })
  -- gathered folds below the yoke
  body:each(function(x, y) if y > 30 and x % 4 == 0 then local i = bi[K(x, y)] c:put(x, y, R.indigo[max(1, i - 1)]) end end)
  -- hem band
  C.hline(c, 15, 49, 50, R.madder[4]) C.hline(c, 14, 50, 51, R.madder[2])
  -- madder yoke, rounded
  local yoke = c:ellipse(32, 13, 17, 15):clip(body:copy():add(c:rect(16, 8, 48, 14))):clip(c:rect(0, 9, 63, 63))
  C.inkSep(c, yoke, body)
  local yi = C.part(c, yoke, R.madder, { R = 3, b = 1, cuts = CUT })
  -- neck opening
  local neck = c:ellipse(32, 10, 6, 3)
  c:fillMask(neck, R.indigo[1])
  C.put(c, { {26,11}, {27,12}, {28,13}, {29,13} }, R.madder[2])
  -- mirrors ringed with saffron chain stitch
  local mir = { {22,17}, {28,21}, {36,21}, {42,17}, {32,24}, {25,25}, {39,25} }
  for _, p in ipairs(mir) do
    local ring = c:ellipse(p[1], p[2], 2, 2)
    c:fillMask(ring, R.saffron[4])
    ring:edge():each(function(x, y) if (x + y) % 2 == 0 then c:put(x, y, R.saffron[2]) end end)
    local glass = c:ellipse(p[1], p[2], 0.9, 0.9)
    c:fillMask(glass, R.steel[4])
    c:put(p[1] - 1, p[2], R.steel[6]) c:put(p[1], p[2] + 1, R.steel[2])
  end
  -- yoke edge stitch
  yoke:edge():each(function(x, y) if y > 14 and (x % 2 == 0) then c:put(x, y, R.saffron[3]) end end)
  -- quirk: one mirror catches a sparkle
  C.put(c, { {42,13}, {42,12}, {41,16}, {43,16}, {44,17}, {40,17} }, R.steel[6])
  c:put(42, 17, cream) c:put(42, 11, cream) c:put(46, 17, R.steel[6])
  C.save(c, "coat-4-mirror-work-smock")
end

---------------------------------------------------------------- 5 turmeric wrap coat
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "coat-5" }
  local slL = c:poly{ {21,10}, {13,13}, {8,36}, {14,37}, {19,22} }
  local slR = c:poly{ {43,10}, {51,13}, {56,36}, {50,37}, {45,22} }
  local top = c:poly{ {20,9}, {44,9}, {45,30}, {19,30} }
  local skirt = c:poly{ {19,29}, {45,29}, {56,60}, {8,60} }
  local bprint = function(x, y) if (x % 6 == 0 and y % 6 == 0) or (x % 6 == 3 and y % 6 == 3) then return -1 end end
  C.part(c, slL, R.saffron, { R = 3, b = -1, cuts = CUT, tex = bprint })
  C.part(c, slR, R.saffron, { R = 3, b = -1, cuts = CUT, tex = bprint })
  C.inkSep(c, skirt, slL:copy():add(slR))
  local si = C.part(c, skirt, R.saffron, { R = 4, cuts = CUT, tex = bprint })
  -- skirt flare folds
  for _, f in ipairs({ { 26, 31, 20, 59 }, { 32, 31, 32, 59 }, { 38, 31, 44, 59 } }) do
    local m = c:line({ {f[1], f[2]}, {f[3], f[4]} }, 1)
    m:each(function(x, y) if skirt:has(x, y) then c:put(x, y, R.saffron[2]) c:put(x - 1, y, R.saffron[5]) end end)
  end
  C.inkSep(c, top, slL:copy():add(slR):add(skirt))
  local under = c:poly{ {19,9}, {32,9}, {20,30}, {19,30} }:clip(top)
  local tb = C.bias(under, -1)
  C.part(c, top, R.saffron, { R = 3, b = 1, bias = tb, cuts = CUT, tex = bprint })
  c:line({ {31,9}, {19,30} }, 1):each(function(x, y) if top:has(x - 1, y) then c:put(x - 1, y, R.saffron[1]) end end)
  -- crossover: right panel wraps over to the left, madder trim on its edge
  local edge = c:line({ {32,9}, {20,30} }, 2)
  C.hline(c, 19, 45, 30, R.madder[2])
  edge:each(function(x, y) c:put(x, y, R.madder[4]) end)
  c:line({ {33,9}, {21,30} }, 1):each(function(x, y) if not edge:has(x, y) then c:put(x, y, R.saffron[2]) end end)
  -- neck
  C.put(c, { {24,9}, {25,9}, {26,10}, {27,10}, {28,11}, {29,10}, {30,9} }, R.saffron[1])
  -- hem trim
  skirt:each(function(x, y) if y >= 58 then c:put(x, y, R.madder[y == 58 and 4 or 2]) end end)
  -- side ties hanging from the waist on the left
  local t1 = c:line({ {19,29}, {15,33}, {14,40} }, 1)
  local t2 = c:line({ {19,30}, {17,35}, {18,42} }, 1)
  C.inkSep(c, t1:copy():add(t2), skirt)
  c:fillMask(t1, R.madder[5]) c:fillMask(t2, R.madder[3])
  local bow = c:ellipse(19, 29, 1.6, 1.4) C.part(c, bow, R.madder, { R = 1, b = 1 })
  -- quirk: a fresh tea leaf pinned on the chest
  local lm = G.blade(36, 22, 38, 15, 42, 13, function(t) return 2.6 * math.sin(math.pi * t) end)
  C.inkSep(c, lm, top)
  C.part(c, lm, R.leaf, { R = 1, b = 1 })
  C.put(c, { {37,20}, {38,18}, {39,16}, {40,15} }, R.leaf[3])
  c:put(36, 22, R.brass[4]) c:put(37, 17, R.leaf[6])
  C.save(c, "coat-5-turmeric-wrap-coat")
end
