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
  -- side view of a leaf shell hood: rounded back on the left, open front on the right
  local shell = c:ellipse(30, 36, 26, 22):clip(c:rect(0, 0, 63, 53))
  for x = 6, 46, 4 do shell:add(c:poly{ {x - 1, 53}, {x + 3, 53}, {x + 1, 57} }) end
  shell:add(c:poly{ {40,16}, {57,24}, {55,28}, {46,26} })
  local hollow = c:ellipse(46, 40, 12, 15):clip(shell)
  local outer = shell:copy():cut(hollow)
  local si = C.part(c, outer, R.palm, { R = 8, hs = .9, cuts = { .16, .32, .48, .66, .84 } })
  -- shingled rows of leaf scallops, overlapping downward
  outer:each(function(x, y)
    local row = floor((y - 14) / 6)
    local off = (row % 2) * 3
    local sx = (x + off) % 6
    local ly = (y - 14) % 6
    local arc = (sx - 2.5) ^ 2 / 7
    local i = si[K(x, y)]
    if ly >= 4.4 - arc and ly < 5.6 - arc then c:put(x, y, R.palm[max(1, i - 2)])
    elseif ly == 1 and sx == 2 then c:put(x, y, R.palm[min(6, i + 1)]) end
  end)
  -- dark hollow inside the shell, lighter toward its back wall
  local hv = {}
  hollow:each(function(x, y) hv[K(x, y)] = (x < 42) and 2 or 1 end)
  hollow:each(function(x, y) c:put(x, y, R.palm[hv[K(x, y)]]) end)
  C.put(c, { {39,30}, {38,33}, {38,36}, {38,39} }, R.palm[3])
  -- bamboo binding around the opening
  hollow:grow(1):cut(hollow):clip(outer):each(function(x, y) c:put(x, y, (y < 36) and R.bamboo[5] or R.bamboo[3]) end)
  -- tie cord hanging from the opening
  local cord = c:line({ {40,50}, {41,54}, {40,58} }, 1)
  c:fillMask(cord, R.madder[3]) c:put(40, 58, R.madder[5])
  -- raindrops beading
  for _, d in ipairs({ { 14, 34 }, { 28, 24 }, { 22, 44 } }) do
    local m = c:ellipse(d[1], d[2], 1.4, 1.6)
    C.part(c, m, R.water, { R = 1, b = 1 })
    c:put(d[1] - 1, d[2] - 1, cream) c:put(d[1] + 1, d[2] + 2, R.palm[1])
  end
  c:put(12, 24, R.palm[6]) c:put(13, 23, R.palm[6]) c:put(14, 22, cream)
  -- quirk: a little green frog sitting on top of the shell
  local fb = c:ellipse(30, 12, 4, 3)
  local fh = c:ellipse(34, 10, 2.6, 2.2)
  local legs = c:poly{ {25,13}, {28,15}, {26,16}, {24,16} }:add(c:poly{ {32,14}, {35,15}, {35,16}, {31,16} })
  local frog = fb:copy():add(fh):add(legs)
  C.inkSep(c, frog, shell)
  C.part(c, legs, R.leaf, { R = 1, b = -1 })
  C.part(c, fb:copy():add(fh), R.leaf, { R = 2, b = 1 })
  c:put(33, 8, ink) c:put(36, 9, ink) c:put(32, 8, R.leaf[6]) c:put(35, 9, R.leaf[6])
  C.put(c, { {34,12}, {35,12} }, R.leaf[2]) c:put(28, 10, R.leaf[6])
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
    if floor(t * 20 + .5) % 2 == 0 then
      fr:add(c:line({ {x1 - 0.5, y1 + 1}, {x1 - 2.5, y1 + 4} }, 1))
      fr:add(c:line({ {x2 + 0.5, y2 + 1}, {x2 + 2.5, y2 + 4} }, 1))
    end
  end
  fr:add(c:line({ {27,55}, {27,60} }, 1)):add(c:line({ {29,53}, {30,59} }, 1)):add(c:line({ {25,54}, {24,59} }, 1))
  fr:cut(front)
  C.inkSep(c, fr, backL)
  fr:each(function(x, y) c:put(x, y, fr:has(x, y + 1) and R.feltc[4] or R.madder[3]) end)
  -- quirk: a small moth resting on the fold
  local wings = c:poly{ {16,21}, {22,24}, {28,21}, {27,28}, {22,27}, {17,28} }
  C.inkSep(c, wings, front)
  C.part(c, wings, R.yak, { R = 1, b = 2 })
  C.vline(c, 22, 23, 28, R.yak[1])
  C.put(c, { {19,24}, {25,24} }, R.madder[4]) C.put(c, { {20,24}, {24,24} }, R.yak[1])
  C.put(c, { {20,21}, {21,22}, {24,22}, {25,21} }, R.yak[2])
  C.save(c, "cloak-2-fine-wool-shawl")
end

---------------------------------------------------------------- 3 felt shepherd cape
do
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "cloak-3" }
  -- stiff felt cape: squared shoulder ledges, flaring to a wide hem, open at the front
  local cape = c:poly{ {9,10}, {26,8}, {38,8}, {55,10}, {54,16}, {50,17}, {61,58}, {3,58}, {14,17}, {10,16} }
  local gap = c:poly{ {32,24}, {38,58}, {26,58} }
  local ci = C.part(c, cape, R.char, { R = 4, cuts = CUT, tex = C.felt })
  -- flaring folds
  for _, f in ipairs({ { 20, 20, 12, 57 }, { 26, 20, 22, 57 }, { 38, 20, 42, 57 }, { 44, 20, 52, 57 } }) do
    c:line({ {f[1], f[2]}, {f[3], f[4]} }, 1):each(function(x, y) if cape:has(x, y) then c:put(x, y, R.char[2]) c:put(x - 1, y, R.char[5]) end end)
  end
  -- open front: dark inside
  c:fillMask(gap, R.char[1])
  c:line({ {32,24}, {26,57} }, 1):each(function(x, y) c:put(x - 1, y, R.feltc[3]) end)
  c:line({ {32,24}, {38,57} }, 1):each(function(x, y) c:put(x + 1, y, R.char[3]) end)
  -- square shoulder ledges
  C.hline(c, 10, 54, 10, R.char[6]) C.hline(c, 11, 53, 16, R.char[1])
  -- cream felt spirals stitched on each shoulder and the hem
  local function curl(cx, cy, s)
    local pts = {}
    for i = 0, 30 do
      local t = i / 30 * 1.8 * math.pi
      local r = 0.5 + t * 0.85
      pts[#pts + 1] = { cx + s * math.cos(t) * r, cy + math.sin(t) * r }
    end
    c:line(pts, 1):each(function(x, y) if cape:has(x, y) and not gap:has(x, y) then c:put(x, y, R.feltc[(x + y) % 2 == 0 and 5 or 4]) end end)
  end
  curl(19, 13, -1) curl(45, 13, 1)
  for x = 5, 59, 2 do if cape:has(x, 55) and not gap:has(x, 55) then c:put(x, 55, R.feltc[3]) end end
  -- neck opening
  local neck = c:ellipse(32, 9, 6, 2)
  c:fillMask(neck, R.char[1])
  -- quirk: a brass bell on the neck tie
  C.put(c, { {30,11}, {31,12}, {33,12}, {34,11}, {32,13} }, R.madder[3])
  local bell = c:poly{ {30,14}, {34,14}, {35,18}, {29,18} }:add(c:ellipse(32, 14, 2, 1.3))
  C.inkSep(c, bell, cape)
  C.part(c, bell, R.brass, { R = 1 })
  C.hline(c, 29, 35, 18, R.brass[2]) c:put(32, 19, R.brass[3]) c:put(31, 14, R.brass[6]) c:put(30, 16, R.brass[6])
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
