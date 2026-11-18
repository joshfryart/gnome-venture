-- cloak.lua: Mistmoor (NWE) cloak concepts 1..5 (see concepts.md).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, G, R = C.HP, C.X, C.K, C.G, C.R
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local only = app.params.only

---------------------------------------------------------------- 1 heather shawl
if not only or only == "1" then
  local c = C.new("cloak-1-heather-shawl")
  local top = {}
  for i = 0, 14 do local t = i / 14 top[#top + 1] = { 3 + t * 58, 11 + 6 * math.sin(math.pi * t) } end
  local pts = {}
  for _, p in ipairs(top) do pts[#pts + 1] = p end
  pts[#pts + 1] = { 33, 52 } pts[#pts + 1] = { 31, 52 }
  local sh = c:poly(pts)
  -- fringe along the two lower edges (drawn first, behind)
  local fr = HP.mask()
  for i = 0, 13 do
    local t = (i + 0.5) / 14
    for _, e in ipairs({ { 3 + t * 28, 11 + t * 41 }, { 61 - t * 28, 11 + t * 41 } }) do
      local x, y = floor(e[1] + 0.5), floor(e[2] + 0.5)
      for k = -2, 6 do fr:set(x, y + k) end
    end
  end
  for k = 0, 6 do fr:set(32, 52 + k) end
  fr:cut(sh)
  fr:each(function(x, y) c:put(x, y, (y % 3 == 0) and R.heather[3] or R.heather[5]) end)
  fr:each(function(x, y) if not fr:has(x, y + 1) then c:put(x, y, R.heather[2]) c:put(x, y - 1, R.heather[4]) end end)
  local idx = C.lit(c, sh, R.heather, { R = 4, cuts = { .2, .36, .52, .68, .86 } })
  -- two-tone dyed bands + lace eyelets
  C.retone(c, sh, idx, R.heather, function(x, y)
    local band = floor((y - 8) / 7) % 2
    if (x + y) % 6 == 0 and (x - y) % 6 == 0 then return -2 end
    if band == 1 then return -1 end
  end)
  for y = 14, 50, 7 do for x = 4, 60 do if sh:has(x, y) and sh:has(x, y - 1) then c:put(x, y, R.heather[2]) end end end
  -- edge rib along the top
  for _, p in ipairs(top) do end
  sh:each(function(x, y) if not sh:has(x, y - 1) then c:put(x, y, R.heather[6]) if sh:has(x, y + 1) then c:put(x, y + 1, R.heather[4]) end end end)
  -- quirk: wooden leaf-shaped shawl pin
  local leaf = G.blade(24, 22, 31, 17, 38, 20, function(t) return 2.8 * math.sin(math.pi * min(1, t * 1.05 + .03)) end)
  C.colour(c, leaf:copy():grow(1):cut(leaf), C.ink)
  C.lit(c, leaf, R.wood, { R = 1, b = 1 })
  c:line({ {25,21}, {37,19} }, 1):each(function(x, y) if leaf:has(x, y) then c:put(x, y, R.wood[2]) end end)
  local pin = c:line({ {19,26}, {44,15} }, 1)
  pin:cut(leaf)
  C.colour(c, pin, R.wood[5])
  C.put(c, { {44,15}, {45,14} }, R.wood[2])
  C.save(c, "cloak-1-heather-shawl")
end

---------------------------------------------------------------- 2 mustard rain cape
if not only or only == "2" then
  local c = C.new("cloak-2-mustard-rain-cape")
  local bell = c:poly{ {21,24}, {43,24}, {51,38}, {56,52}, {8,52}, {13,38} }:add(c:ellipse(32, 51, 24, 5))
  local bi = C.lit(c, bell, R.mustard, { R = 5, cuts = { .2, .36, .52, .7, .88 } })
  -- panel seams radiating from the shoulders
  for _, s in ipairs({ { {26,26}, {17,55} }, { {38,26}, {47,55} }, { {32,30}, {32,56} } }) do
    c:line(s, 1):each(function(x, y) if bell:has(x, y) then c:put(x, y, R.mustard[2]) if bell:has(x - 1, y) then c:put(x - 1, y, R.mustard[5]) end end end)
  end
  -- oilcloth sheen
  c:line({ {15,40}, {12,50} }, 1):each(function(x, y) c:put(x, y, R.mustard[6]) end)
  c:line({ {20,30}, {18,36} }, 1):each(function(x, y) c:put(x, y, R.mustard[6]) end)
  -- hem fold
  bell:each(function(x, y) if not bell:has(x, y + 1) then c:put(x, y, R.mustard[2]) end end)
  -- pointed hood, tip flopped to the right
  local hood = c:poly{ {19,27}, {22,14}, {28,5}, {34,2}, {40,3}, {44,6}, {41,8}, {40,14}, {45,27} }
  C.sep(c, hood, bell, R.mustard[1])
  local hi = C.lit(c, hood, R.mustard, { R = 4, b = 1, cuts = { .2, .36, .52, .7, .88 } })
  c:line({ {36,4}, {33,8}, {31,14} }, 1):each(function(x, y) c:put(x, y, R.mustard[2]) end)
  local face = c:ellipse(32, 21, 7, 6)
  C.colour(c, face, R.peat[2])
  face:each(function(x, y) if y > 22 then c:put(x, y, R.peat[1]) end end)
  face:edge():each(function(x, y) if y < 20 then c:put(x, y, R.mustard[5]) end end)
  -- wooden toggle on a loop
  c:line({ {29,30}, {35,30} }, 1):each(function(x, y) c:put(x, y, R.strap[2]) end)
  local tg = c:rrect(28, 31, 36, 33, 1)
  C.colour(c, tg:copy():grow(1):cut(tg), C.ink)
  C.lit(c, tg, R.wood, { R = 1 }) C.hline(c, 29, 35, 31, R.wood[6])
  -- quirk: a raindrop rolling off the hem
  local drop = c:poly{ {54.5,52}, {57,56.5}, {56.5,59}, {52.5,59}, {52,56.5} }
  C.colour(c, drop:copy():grow(1):cut(drop):cut(bell), C.ink)
  C.lit(c, drop, R.water, { R = 2 })
  c:put(53, 57, C.cream)
  C.save(c, "cloak-2-mustard-rain-cape")
end

---------------------------------------------------------------- 3 sheepskin mantle
if not only or only == "3" then
  local c = C.new("cloak-3-sheepskin-mantle")
  local m = c:ellipse(32, 22, 28, 20)
  m:clip(c:rect(0, 0, 64, 38))
  for x = 6, 58, 6 do m:add(c:ellipse(x, 37 + ((x % 12 == 0) and 1 or 0) - abs(x - 32) * 0.18, 3.6, 3.2)) end
  for _, p in ipairs({ {6,22}, {58,22}, {9,13}, {55,13}, {16,6}, {48,6}, {25,5}, {39,5}, {32,5} }) do m:add(c:ellipse(p[1], p[2], 3.4, 3.2)) end
  local neck = c:ellipse(32, 12, 10, 7)
  m:cut(neck)
  m:cut(c:poly{ {30.5,17}, {33.5,17}, {33,40}, {31,40} })
  -- leather inside of the collar
  local inner = c:ellipse(32, 12, 10, 7):cut(c:ellipse(32, 10, 9, 5.5)):clip(c:rect(0, 12, 64, 64))
  C.lit(c, inner, R.leather, { R = 1, b = -1 })
  local idx = C.lit(c, m, R.fleece, { R = 6, hs = 0.9, cuts = { .18, .34, .5, .66, .84 } })
  -- curls: little rings
  m:each(function(x, y)
    local gx, gy = (x + (floor(y / 3) % 2) * 2) % 4, y % 3
    local i = idx[K(x, y)]
    if gx == 0 and gy == 0 then c:put(x, y, R.fleece[max(1, i - 2)])
    elseif gx == 1 and gy == 1 then c:put(x, y, R.fleece[max(1, i - 1)])
    elseif gx == 2 and gy == 0 and i < 6 then c:put(x, y, R.fleece[i + 1]) end
  end)
  -- gap at the front shows leather edge
  c:line({ {32,18}, {32,39} }, 1):each(function(x, y) c:put(x, y, R.leather[2]) end)
  -- leather thong ties crossing the gap
  for _, y in ipairs({ 22, 29 }) do
    c:line({ {28,y}, {36,y + 1} }, 1):each(function(x, yy) c:put(x, yy, R.leather[4]) end)
    C.put(c, { {31,y}, {32,y}, {33,y + 1} }, R.leather[2])
  end
  c:line({ {33,30}, {35,35}, {34,40} }, 1):each(function(x, y) c:put(x, y, R.leather[5]) end)
  c:line({ {32,30}, {29,35}, {29,40} }, 1):each(function(x, y) c:put(x, y, R.leather[3]) end)
  -- quirk: a prickly burr stuck in the curls
  local bu = c:ellipse(46, 25, 2.6, 2.6)
  local sp = HP.mask()
  for _, d in ipairs({ {0,-4}, {0,-5}, {3,-3}, {4,-4}, {4,0}, {5,0}, {3,3}, {4,4}, {0,4}, {0,5}, {-3,3}, {-4,4}, {-4,0}, {-5,0}, {-3,-3}, {-4,-4} }) do sp:set(46 + d[1], 25 + d[2]) end
  sp:cut(bu)
  C.colour(c, sp, R.peat[1])
  C.colour(c, bu:copy():grow(1):cut(bu):cut(sp), R.peat[2])
  local bui = C.lit(c, bu, R.wicker, { R = 1, b = -1 })
  C.retone(c, bu, bui, R.wicker, function(x, y) if (x + y) % 2 == 0 then return -1 end end)
  C.put(c, { {45,23}, {44,24} }, R.wicker[5])
  C.save(c, "cloak-3-sheepskin-mantle")
end

---------------------------------------------------------------- 4 rush thatch cape
if not only or only == "4" then
  local c = C.new("cloak-4-rush-thatch-cape")
  local tiers = {}
  local all = HP.mask()
  for i = 0, 3 do
    local y0, y1 = 8 + i * 11, 8 + i * 11 + 14
    local x0, x1 = 22 - i * 5.5, 42 + i * 5.5
    local m = c:poly{ {x0 + 3, y0}, {x1 - 3, y0}, {x1 + 3, y1}, {x0 - 3, y1} }
    -- ragged straw ends
    for x = x0 - 3, x1 + 3 do
      local d = floor(X.hash(x, i, 4) * 3)
      for y = y1 - 1, y1 + d do if m:has(x, y1 - 1) then m:set(x, y) end end
    end
    tiers[i + 1] = { m = m, y0 = y0, y1 = y1 }
  end
  for i = 4, 1, -1 do
    local t = tiers[i]
    local m = t.m:copy()
    if i > 1 then m:cut(tiers[i - 1].m) end
    local idx = C.lit(c, m, R.straw, { R = 3, cuts = { .2, .36, .52, .68, .86 } })
    -- straw strands: per-column tone streaks
    C.retone(c, m, idx, R.straw, function(x, y)
      local h = X.hash(x, i, 8)
      if x % 2 == 0 and h < .5 then return -1 elseif h > .8 then return 1 end
    end)
    -- shadow cast by the tier above
    if i > 1 then
      tiers[i - 1].m:grow(1):cut(tiers[i - 1].m):clip(m):each(function(x, y) c:put(x, y, R.straw[1]) end)
      tiers[i - 1].m:shift(1, 2):cut(tiers[i - 1].m):clip(m):each(function(x, y) c:put(x, y, R.straw[2]) end)
    end
    all:add(t.m)
  end
  -- binding twine across each tier
  for i = 1, 4 do
    local y = tiers[i].y0 + 3
    for x = 0, 63 do if tiers[i].m:has(x, y) and not (i > 1 and tiers[i - 1].m:has(x, y)) then c:put(x, y, ((x % 4) < 2) and R.rope[2] or R.rope[4]) end end
  end
  -- neck opening and rope tie
  local nk = c:ellipse(32, 8, 7, 2.2)
  C.colour(c, nk, R.peat[2])
  C.rope(c, { {24,10}, {32,12}, {40,10} }, 2)
  C.rope(c, { {32,12}, {29,19} }, 2) C.rope(c, { {32,12}, {35,18} }, 2)
  -- quirk: a little green frog sitting on the third tier
  local fb = c:ellipse(15, 38, 3.4, 2.6)
  local eye1, eye2 = c:ellipse(13, 35, 1.3, 1.3), c:ellipse(17, 35, 1.3, 1.3)
  local fr = fb:copy():add(eye1):add(eye2)
  C.colour(c, fr:copy():grow(1):cut(fr), C.ink)
  C.lit(c, fr, R.frog, { R = 1 })
  C.put(c, { {13,35}, {17,35} }, C.ink) C.put(c, { {12,34}, {16,34} }, R.frog[6])
  C.hline(c, 13, 17, 39, R.frog[2]) C.put(c, { {12,40}, {18,40} }, R.frog[3])
  C.save(c, "cloak-4-rush-thatch-cape")
end

---------------------------------------------------------------- 5 woad mist cloak
if not only or only == "5" then
  local c = C.new("cloak-5-woad-mist-cloak")
  local body = c:poly{ {22,18}, {42,18}, {50,40}, {54,58}, {10,58}, {14,40} }:add(c:ellipse(32, 57, 22, 3.5))
  local bi = C.lit(c, body, R.mist, { R = 5, cuts = { .2, .36, .52, .68, .86 } })
  -- long folds
  for _, f in ipairs({ { 24, 28, 17, 59 }, { 40, 28, 47, 59 }, { 27, 36, 25, 59 }, { 37, 36, 40, 59 } }) do
    c:line({ {f[1], f[2]}, {f[3], f[4]} }, 1):each(function(x, y) if body:has(x, y) then c:put(x, y, R.mist[2]) if body:has(x - 1, y) then c:put(x - 1, y, R.mist[5]) end end end)
  end
  -- front opening: lining dark gap from the pin down
  c:line({ {32,26}, {31,59} }, 1):each(function(x, y) c:put(x, y, R.mist[1]) end)
  -- woad border along the front edges and the hem
  body:each(function(x, y)
    local hem = not body:has(x, y + 3)
    local front = abs(x - 31.5 + (y - 26) * 0.03) < 3.5 and y > 26
    if hem or front then
      local i = bi[K(x, y)] or 3
      c:put(x, y, R.woad[max(1, min(6, i))])
    end
  end)
  c:line({ {32,26}, {31,59} }, 1):each(function(x, y) c:put(x, y, R.woad[1]) end)
  body:each(function(x, y) if not body:has(x, y + 4) and body:has(x, y + 3) then c:put(x, y, R.woad[5]) end end)
  -- rounded hood with deep opening
  local hood = c:ellipse(32, 15, 12, 12):add(c:poly{ {22,20}, {42,20}, {44,27}, {20,27} })
  C.sep(c, hood, body, R.mist[1])
  C.lit(c, hood, R.mist, { R = 4, b = 1, cuts = { .2, .36, .52, .68, .86 } })
  local face = c:ellipse(32, 18, 7, 7.5)
  C.colour(c, face, R.mist[1])
  face:each(function(x, y) if y < 15 then c:put(x, y, R.peat[1]) end end)
  face:grow(1):cut(face):clip(hood):each(function(x, y) c:put(x, y, (x < 32 and y < 20) and R.woad[5] or R.woad[2]) end)
  -- round steel pin at the throat
  local pin = c:ellipse(32, 27, 2.6, 2.6)
  C.colour(c, pin:copy():grow(1):cut(pin), C.ink)
  C.lit(c, pin, R.steel, { R = 1 })
  C.colour(c, c:ellipse(32, 27, 0.9, 0.9), R.mist[2])
  c:put(31, 25, R.steel[6])
  c:line({ {28,24}, {36,30} }, 1):each(function(x, y) if not pin:has(x, y) then c:put(x, y, R.steel[5]) end end)
  -- quirk: a pale moth resting on the hood
  local wl = c:poly{ {36,5}, {40,3}, {42,7}, {39,9} }
  local wr = c:poly{ {40,7}, {45,5}, {46,9}, {42,10} }
  local mo = wl:copy():add(wr)
  C.colour(c, mo:copy():grow(1):cut(mo), C.ink)
  C.lit(c, wl, R.fleece, { R = 1, b = 1 }) C.lit(c, wr, R.fleece, { R = 1 })
  C.put(c, { {40,7}, {41,8} }, R.peat[2])
  C.put(c, { {38,6}, {43,7} }, R.wicker[3])
  C.save(c, "cloak-5-woad-mist-cloak")
end
