-- cloak.lua: Spicepeak (CSA) cloak concepts, 5 icons 64x64. See concepts.md.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local ink, cream = C.ink, C.cream
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local CUT = { .2, .36, .52, .7, .88 }

---------------------------------------------------------------- 1 palm-leaf rain hood
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "cloak-1" }
  local shell = c:ellipse(32, 40, 25, 22):clip(c:rect(0, 0, 63, 55)):add(c:poly{ {22,22}, {31,6}, {34,6}, {42,22} })
  -- leaf-tip fringe along the bottom
  for x = 8, 56, 4 do shell:add(c:poly{ {x - 1, 54}, {x + 3, 54}, {x + 1, 58} }) end
  local si, sn = C.part(c, shell, R.palm, { R = 8, hs = .9, cuts = { .16, .32, .48, .66, .84 } })
  -- shingled rows of leaf scallops: each row darker at its lower lip
  shell:each(function(x, y)
    local row = floor((y - 6) / 7)
    local off = (row % 2) * 3
    local sx = (x + off) % 6
    local ly = (y - 6) % 7
    local arc = (sx - 2.5) ^ 2 / 6
    local i = si[K(x, y)]
    if ly >= 5 - arc and ly < 6.2 - arc then c:put(x, y, R.palm[max(1, i - 2)])
    elseif ly < 1.2 + 0 and sx == 0 then c:put(x, y, R.palm[max(1, i - 1)])
    elseif ly == 1 and sx == 2 then c:put(x, y, R.palm[min(6, i + 1)]) end
  end)
  -- leaf veins on a few scallops
  -- bamboo binding along the hem
  for x = 8, 56 do if shell:has(x, 53) then c:put(x, 52, R.bamboo[5]) c:put(x, 53, R.bamboo[3]) end end
  for x = 9, 55, 5 do c:put(x, 52, R.bamboo[2]) c:put(x, 53, R.bamboo[1]) end
  -- dark hollow showing under the hem in the middle
  local hollow = c:ellipse(32, 56, 14, 2):clip(c:rect(0, 54, 63, 63))
  c:fillMask(hollow, R.palm[1])
  -- raindrops beading
  for _, d in ipairs({ { 16, 38 }, { 46, 30 }, { 40, 45 } }) do
    local m = c:ellipse(d[1], d[2], 1.4, 1.6)
    C.part(c, m, R.water, { R = 1, b = 1 })
    c:put(d[1] - 1, d[2] - 1, cream) c:put(d[1] + 1, d[2] + 2, R.palm[1])
  end
  -- top tie of the point
  C.hline(c, 30, 35, 10, R.bamboo[2]) C.hline(c, 30, 35, 11, R.bamboo[4])
  c:put(14, 30, R.palm[6]) c:put(15, 29, R.palm[6]) c:put(16, 28, cream)
  -- quirk: a little green frog sitting on the shell's shoulder
  local fb = c:ellipse(43, 18, 4, 3)
  local fh = c:ellipse(46, 15, 2.6, 2.2)
  local legs = c:poly{ {38,19}, {41,21}, {39,22}, {37,22} }:add(c:poly{ {45,20}, {48,21}, {48,22}, {44,22} })
  local frog = fb:copy():add(fh):add(legs)
  C.inkSep(c, frog, shell)
  C.part(c, legs, R.leaf, { R = 1, b = -1 })
  C.part(c, fb:copy():add(fh), R.leaf, { R = 2, b = 1 })
  c:put(45, 13, ink) c:put(48, 14, ink) c:put(44, 13, R.leaf[6]) c:put(47, 14, R.leaf[6])
  C.put(c, { {46,17}, {47,17} }, R.leaf[2]) c:put(41, 16, R.leaf[6])
  C.save(c, "cloak-1-palm-leaf-rain-hood")
end

---------------------------------------------------------------- 2 fine wool shawl
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "cloak-2" }
  local soft = function(x, y) if (x + 2 * y) % 5 == 0 and X.hash(x, y, 8) < .5 then return -1 end end
  -- back layer (the folded-under half peeking out on the right)
  local backL = c:poly{ {14,11}, {58,9}, {44,34}, {36,49} }
  local front = c:poly{ {4,14}, {52,12}, {34,40}, {27,55} }
  C.part(c, backL, R.feltc, { R = 3, b = -1, cuts = CUT, tex = soft })
  C.inkSep(c, front, backL)
  local fi = C.part(c, front, R.feltc, { R = 5, cuts = CUT, tex = soft })
  -- soft drape folds
  for _, f in ipairs({ { {16,15}, {22,30}, {26,44} }, { {32,14}, {32,28}, {30,40} } }) do
    c:line(f, 1):each(function(x, y) if front:has(x, y) then c:put(x, y, R.feltc[3]) c:put(x - 1, y, R.feltc[6]) end end)
  end
  -- woven border bands inside the diagonal edges
  local function border(m, b)
    m:shrink(2):edge():each(function(x, y) if y > 15 then c:put(x, y, R.madder[4 + (b or 0)]) end end)
    m:shrink(3):edge():each(function(x, y) if y > 16 then c:put(x, y, R.yarnB[3 + (b or 0)]) end end)
    m:shrink(4):edge():each(function(x, y) if y > 17 and (x + y) % 2 == 0 then c:put(x, y, R.madder[3 + (b or 0)]) end end)
  end
  border(backL, -1)
  border(front, 0)
  -- top edge: the folded edge, lit
  C.hline(c, 5, 51, 14, R.feltc[6]) C.hline(c, 6, 50, 15, R.feltc[5])
  -- fringe along the lower diagonals of the front
  local fr = HP.mask()
  for t = 0, 1, 0.05 do
    local x1, y1 = 4 + (27 - 4) * t, 14 + (55 - 14) * t
    local x2, y2 = 52 + (34 - 52) * t, 12 + (40 - 12) * t
    fr:add(c:line({ {x1 - 0.5, y1 + 1}, {x1 - 2.5, y1 + 4} }, 1))
    fr:add(c:line({ {x2 + 0.5, y2 + 1}, {x2 + 2.5, y2 + 4} }, 1))
  end
  fr:add(c:line({ {27,55}, {27,60} }, 1)):add(c:line({ {29,53}, {30,59} }, 1)):add(c:line({ {25,54}, {24,59} }, 1))
  fr:cut(front)
  C.inkSep(c, fr, backL)
  fr:each(function(x, y) c:put(x, y, ((x + y) % 2 == 0) and R.madder[3] or R.madder[5]) end)
  -- quirk: a small moth resting on the fold
  local wings = c:poly{ {18,22}, {22,24}, {26,22}, {25,27}, {22,26}, {19,27} }
  C.part(c, wings, R.canvas, { R = 1 })
  C.vline(c, 22, 23, 27, R.yak[2])
  C.put(c, { {20,24}, {24,24} }, R.canvas[2]) C.put(c, { {21,21}, {23,21} }, R.yak[3])
  C.save(c, "cloak-2-fine-wool-shawl")
end

---------------------------------------------------------------- 3 felt shepherd cape
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "cloak-3" }
  local cape = c:poly{ {6,12}, {26,10}, {38,10}, {58,12}, {57,17}, {53,18}, {57,58}, {7,58}, {11,18}, {7,17} }
  local ci = C.part(c, cape, R.char, { R = 4, cuts = CUT, tex = C.felt })
  -- stiff vertical folds
  for _, x in ipairs({ 18, 25, 39, 46 }) do
    for y = 20, 57 do if cape:has(x, y) then c:put(x, y, R.char[2]) c:put(x - 1, y, R.char[5]) end end
  end
  -- square shoulder ledges
  C.hline(c, 7, 57, 12, R.char[6]) C.hline(c, 8, 56, 17, R.char[1])
  -- front opening
  for y = 18, 57 do c:put(32, y, ink) c:put(31, y, R.char[4]) end
  -- cream felt stitched spirals down the front
  local function curl(cx, cy, s)
    local pts = {}
    for i = 0, 30 do
      local t = i / 30 * 1.8 * math.pi
      local r = 0.5 + t * 0.9
      pts[#pts + 1] = { cx + s * math.cos(t) * r, cy + math.sin(t) * r }
    end
    c:line(pts, 1):each(function(x, y) if cape:has(x, y) then c:put(x, y, R.feltc[(x + y) % 2 == 0 and 5 or 4]) end end)
  end
  curl(27, 26, -1) curl(36, 26, 1) curl(27, 40, -1) curl(36, 40, 1)
  -- hem stitch
  for x = 8, 56, 2 do c:put(x, 55, R.feltc[3]) end
  -- neck opening
  local neck = c:ellipse(32, 11, 6, 2)
  c:fillMask(neck, R.char[1])
  C.hline(c, 27, 37, 9, R.char[5])
  -- quirk: a brass bell on the neck tie
  C.put(c, { {30,13}, {31,14}, {33,14}, {34,13}, {32,15} }, R.madder[3])
  local bell = c:poly{ {30,16}, {34,16}, {35,20}, {29,20} }:add(c:ellipse(32, 16, 2, 1.3))
  C.inkSep(c, bell, cape)
  C.part(c, bell, R.brass, { R = 1 })
  C.hline(c, 29, 35, 20, R.brass[2]) c:put(32, 21, R.brass[3]) c:put(31, 16, R.brass[6]) c:put(30, 18, R.brass[6])
  C.save(c, "cloak-3-felt-shepherd-cape")
end

---------------------------------------------------------------- 4 striped yak poncho
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "cloak-4" }
  local pon = c:poly{ {32,5}, {60,30}, {32,55}, {4,30} }
  local stripe = { R.madder, R.saffron, R.yarnB, R.indigo, R.madder, R.feltc, R.yarnB, R.saffron }
  local pi = C.part(c, pon, R.madder, { R = 5, cuts = CUT })
  C.swap(c, pon, pi, function(x, y) return stripe[floor((y - 5) / 4) % #stripe + 1] end)
  -- woven texture and thin dark separators
  pon:each(function(x, y)
    local i = pi[K(x, y)]
    local r = stripe[floor((y - 5) / 4) % #stripe + 1]
    if (y - 5) % 4 == 3 then c:put(x, y, r[max(1, i - 1)])
    elseif (x + y) % 4 == 0 then c:put(x, y, r[max(1, i - 1)]) end
  end)
  -- neck slit with yak binding
  local neck = c:rrect(26, 13, 38, 17, 2)
  local bind = neck:grow(1)
  c:fillMask(bind, R.yak[4]) C.hline(c, 26, 38, 12, R.yak[6])
  c:fillMask(neck, R.yak[1])
  C.hline(c, 27, 37, 17, R.yak[2])
  -- knotted fringe along the two lower edges
  local fr = HP.mask()
  for t = 0, 1, 0.07 do
    local x1, y1 = 4 + 28 * t, 30 + 25 * t
    local x2, y2 = 60 - 28 * t, 30 + 25 * t
    fr:add(c:line({ {x1, y1 + 1}, {x1 - 1, y1 + 4} }, 1)):add(c:line({ {x2, y2 + 1}, {x2 + 1, y2 + 4} }, 1))
  end
  fr:add(c:line({ {32,56}, {32,60} }, 1))
  fr:cut(pon)
  fr:each(function(x, y) c:put(x, y, (y % 2 == 0) and R.feltc[5] or R.feltc[3]) end)
  c:put(18, 12, R.madder[6]) c:put(19, 12, R.madder[6])
  -- quirk: barred goose feather tucked into the neck
  local fm, fn = G.tube({ {36,16}, {40,10}, {44,6}, {49,2} }, function(t) return 2.4 * math.sin(math.pi * min(1, t * 1.05 + .08)) end)
  C.inkSep(c, fm, pon:copy():add(bind))
  local fi = C.toneN(c, fm, fn, R.goose, { cuts = CUT })
  fm:each(function(x, y) if (x + y) % 5 == 0 then c:put(x, y, R.goose[1]) end end)
  c:line({ {36,16}, {48,3} }, 1):each(function(x, y) if fm:has(x, y) then c:put(x, y, R.goose[6]) end end)
  C.save(c, "cloak-4-striped-yak-poncho")
end

---------------------------------------------------------------- 5 indigo dot cloak
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "cloak-5" }
  local drape = c:poly{ {22,22}, {42,22}, {54,58}, {10,58} }
  local hood = c:poly{ {20,24}, {24,12}, {30,10}, {38,8}, {44,11}, {44,24}, {38,30}, {26,30} }
  local lining = c:poly{ {29,30}, {35,30}, {37,58}, {27,58} }
  local di = C.part(c, drape, R.indigo, { R = 4, cuts = CUT })
  -- long folds
  for _, f in ipairs({ { 22, 34, 16, 57 }, { 42, 34, 48, 57 } }) do
    c:line({ {f[1], f[2]}, {f[3], f[4]} }, 1):each(function(x, y) if drape:has(x, y) then c:put(x, y, R.indigo[1]) c:put(x - 1, y, R.indigo[4]) end end)
  end
  -- madder lining showing in the front opening
  C.part(c, lining, R.madder, { R = 2, b = -1 })
  C.vline(c, 28, 31, 57, R.indigo[5]) C.vline(c, 36, 31, 57, R.indigo[1])
  -- dot rows
  drape:each(function(x, y)
    if not lining:has(x, y) and y % 5 == 2 and (x + floor(y / 5) * 2) % 4 == 0 then
      local i = di[K(x, y)] c:put(x, y, R.feltc[min(6, (i or 3) + 1)])
    end
  end)
  -- hem
  drape:each(function(x, y) if y >= 57 and not lining:has(x, y) then c:put(x, y, R.indigo[2]) end end)
  C.inkSep(c, hood, drape:copy():add(lining))
  local hi = C.part(c, hood, R.indigo, { R = 4, b = 1, cuts = CUT })
  hood:each(function(x, y) if y % 5 == 0 and (x + floor(y / 5) * 2) % 4 == 0 then
    c:put(x, y, R.feltc[min(6, (hi[K(x, y)] or 3) + 1)]) end end)
  -- hood face opening with lining rim
  local face = c:ellipse(32, 22, 7, 7):clip(hood):clip(c:rect(0, 15, 63, 63))
  c:fillMask(face, R.indigo[1])
  face:edge():each(function(x, y) if not face:has(x, y - 1) or not face:has(x - 1, y) or not face:has(x + 1, y) then c:put(x, y, R.madder[(x < 32) and 5 or 3]) end end)
  -- quirk: a green parakeet perched on the hood point
  local body = c:ellipse(40, 6, 3, 2.2)
  local tail = c:poly{ {42,6}, {47,9}, {47,10}, {42,8} }
  local bird = body:copy():add(tail):add(c:ellipse(37.5, 4.5, 1.6, 1.6))
  C.inkSep(c, bird, hood)
  C.part(c, tail, R.leaf, { R = 1, b = -1 })
  C.part(c, body:copy():add(c:ellipse(37.5, 4.5, 1.6, 1.6)), R.leaf, { R = 1, b = 1 })
  c:put(36, 5, R.madder[4]) c:put(35, 5, R.madder[3]) c:put(37, 4, ink)
  C.put(c, { {40,6}, {41,6}, {42,7} }, R.leaf[3])
  C.save(c, "cloak-5-indigo-dot-cloak")
end
