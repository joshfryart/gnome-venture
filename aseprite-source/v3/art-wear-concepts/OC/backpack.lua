-- backpack.lua: OC (Coralscatter) backpack concepts, 5 icons.
-- Run: AppRun -b --script-param png=<dir>/ --script backpack.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R = C.HP, C.X, C.K, C.R
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi

---------------------------------------------------------------- 1 flax basket pack
do
  local c = C.canvas("backpack-1-flax-basket-pack")
  -- handle loops behind the basket
  for _, h in ipairs({ { 17, 27, -1 }, { 37, 47, 0 } }) do
    local loop = c:line({ {h[1],22}, {h[1]+1,13}, {h[2]-1,13}, {h[2],22} }, 3)
    C.part(c, loop, R.flax, { R = 1, b = h[3] })
    C.hline(c, h[1] + 2, h[2] - 2, 12, R.flax[5 + h[3]])
  end
  local body = c:poly{ {9,22}, {55,22}, {51,52}, {46,56}, {18,56}, {13,52} }
  local i = C.part(c, body, R.flax, { R = 5, cuts = { .2, .36, .52, .7, .88 } })
  -- checkerboard plait: alternate light/dark squares of 4 px with weave lines
  C.retone(c, body, i, R.flax, function(x, y)
    local a, b = floor((x - 9) / 4) % 2, floor((y - 26) / 4) % 2
    if a == b then
      if (x - 9) % 4 == 0 then return -2 end
      return -1
    else
      if (y - 26) % 4 == 0 then return -2 end
      if X.hash(x, y, 7) < .15 then return 1 end
    end
  end)
  -- pandanus-coloured band across the middle
  local band = c:rect(10, 37, 54, 41):clip(body)
  local bi = C.part(c, band, R.pandanus, { R = 1 })
  C.retone(c, band, bi, R.pandanus, function(x, y) if (x + y) % 3 == 0 then return -1 end end)
  C.hline(c, 10, 54, 42, R.flax[1])
  -- rolled rim on top
  local rim = c:rrect(8, 20, 56, 25, 2)
  local ri = C.part(c, rim, R.pandanus, { R = 2 })
  C.retone(c, rim, ri, R.pandanus, function(x, y) if (x - y) % 3 == 0 then return -1 end end)
  C.hline(c, 10, 54, 26, R.flax[1])
  -- quirk: a curled fern frond poking out of the top
  local stem = c:line({ {40,20}, {41,15}, {42,10}, {44,6} }, 2)
  C.fill(c, stem, R.leafwrap[4])
  C.put(c, { {41,18}, {41,14}, {42,10} }, R.leafwrap[6])
  -- koru curl
  C.put(c, { {45,5}, {46,4}, {47,4}, {48,5}, {48,6}, {47,7}, {46,7} }, R.leafwrap[5])
  c:put(46, 6, R.leafwrap[3]) c:put(46, 5, R.leafwrap[2])
  -- side leaflets
  for _, l in ipairs({ { 39, 17, -1 }, { 43, 15, 1 }, { 40, 13, -1 }, { 44, 11, 1 } }) do
    C.put(c, { {l[1] + l[3], l[2]}, {l[1] + 2 * l[3], l[2] - 1} }, R.leafwrap[l[3] < 0 and 5 or 3])
  end
  -- weave glint
  c:put(14, 29, R.flax[6]) c:put(15, 29, R.flax[6])
  C.save(c, "backpack-1-flax-basket-pack")
end

---------------------------------------------------------------- 2 coconut string bag
do
  local c = C.canvas("backpack-2-coconut-string-bag")
  local bag = c:poly{ {16,18}, {48,18}, {54,34}, {54,46}, {46,56}, {18,56}, {10,46}, {10,34} }
    :add(c:ellipse(32, 46, 22, 10))
  -- head strap: a curved band arching over the top
  local strap = c:line({ {18,20}, {20,11}, {26,6}, {38,6}, {44,11}, {46,20} }, 3)
  local si = C.part(c, strap, R.ochre, { R = 1 })
  C.retone(c, strap, si, R.ochre, function(x, y) if (x + y) % 4 == 0 then return -1 end end)
  -- contents seen through the mesh: dark interior + coconuts
  C.fill(c, bag, R.coconut[1])
  local nuts = { { 22, 44, 7, -1 }, { 41, 45, 7, 0 }, { 31, 32, 7, 0 } }
  for _, n in ipairs(nuts) do
    local m = c:ellipse(n[1], n[2], n[3], n[3] - 0.5):clip(bag)
    C.part(c, m, R.coconut, { R = 4, b = n[4] })
  end
  -- coconut fibre speckle
  bag:each(function(x, y) if X.hash(x, y, 3) < .1 then local p = c:get(x, y) if p ~= R.coconut[1] then c:put(x, y, R.coconut[2]) end end end)
  -- looped mesh: diamond net in banded colours
  local bands = { R.ochre, R.pandanus, R.turtle, R.ochre, R.pandanus }
  bag:each(function(x, y)
    local u, v = (x + y) % 6, (x - y + 600) % 6
    if u == 0 or v == 0 then
      local rmp = bands[floor((y - 18) / 8) + 1] or R.ochre
      local t = (u == 0 and v == 0) and 6 or ((x < 32) and 5 or 4)
      if y > 48 then t = t - 1 end
      c:put(x, y, rmp[t])
    end
  end)
  -- gathered top cord
  local top = c:rrect(15, 16, 49, 20, 2)
  C.part(c, top, R.ochre, { R = 1 })
  for x = 17, 47, 3 do c:put(x, 18, R.ochre[2]) end
  -- quirk: one coconut face showing through a big mesh gap
  local gap = c:ellipse(31, 33, 4, 3)
  C.part(c, gap, R.coconut, { R = 3, b = 1 })
  C.put(c, { {29,32}, {33,32}, {31,34} }, C.ink)
  c:put(29, 31, R.coconut[6]) c:put(28, 31, R.coconut[5])
  -- tassel at the bottom
  C.vline(c, 32, 57, 60, R.ochre[4]) C.vline(c, 31, 57, 59, R.ochre[5]) C.vline(c, 33, 57, 59, R.ochre[3])
  C.save(c, "backpack-2-coconut-string-bag")
end

---------------------------------------------------------------- 3 bushman's swag
do
  local c = C.canvas("backpack-3-bushmans-swag")
  -- carry strap arching above the roll (behind)
  local cs = c:line({ {14,28}, {16,16}, {26,11}, {38,11}, {46,16}, {48,26} }, 2)
  C.part(c, cs, R.strap, { R = 1 })
  -- billy can hanging off the right end on a cord (behind roll end)
  local cord = c:line({ {50,30}, {51,38} }, 1)
  C.fill(c, cord, R.coir[3])
  local can = c:rect(46, 40, 57, 53)
  C.vcylb(c, can, R.steel, 46, 57, 0, { cuts = { .2, .36, .52, .7, .9 } })
  local lid = c:ellipse(51.5, 40, 6, 1.6)
  C.part(c, lid, R.steel, { R = 1, b = 1 })
  C.hline(c, 47, 56, 46, R.steel[2]) C.hline(c, 47, 56, 47, R.steel[5])
  local bail = c:line({ {46,41}, {47,37}, {51,36}, {55,37}, {57,41} }, 1)
  bail:each(function(x, y) if not lid:has(x, y) and not can:has(x, y) then c:put(x, y, R.steel[3]) end end)
  C.vline(c, 48, 42, 52, R.steel[6])
  C.hline(c, 47, 56, 53, R.sole[3])
  -- steam curl (quirk)
  C.put(c, { {53,34}, {54,33}, {54,32}, {53,31}, {53,30}, {54,29} }, R.fleece[5])
  C.put(c, { {50,33}, {50,32}, {49,31} }, R.fleece[4])
  -- canvas roll: horizontal cylinder
  local m, n = X.cyl(10, 32, 48, 32, function() return 9 end)
  local i = C.toneN(c, m, n, R.canvas, { cuts = { .2, .36, .52, .7, .88 } })
  C.retone(c, m, i, R.canvas, function(x, y) if (x % 3 == 0 and y % 2 == 0) then return -1 end end)
  -- inner blanket edge spiralling at the left end
  local en = c:ellipse(10, 32, 4, 9)
  C.part(c, en, R.canvas, { R = 2, b = 1 })
  C.put(c, { {10,25}, {11,26}, {12,28}, {12,31}, {12,34}, {11,37}, {10,38}, {9,37}, {8,34}, {8,31}, {9,29}, {10,28} }, R.blanket[3])
  C.put(c, { {10,31}, {10,32}, {10,33}, {11,30}, {9,34} }, R.blanket[2])
  -- outer canvas flap line
  for x = 14, 46 do c:put(x, 37 + floor(sin(x * .25) * .8), R.canvas[2]) end
  -- leather straps and buckles
  for _, sx in ipairs({ 19, 38 }) do
    m:each(function(x, y) if x >= sx and x <= sx + 3 then c:put(x, y, R.strap[(x == sx) and 5 or ((y < 28) and 4 or 3)]) end end)
    local bk = c:rect(sx - 1, 33, sx + 4, 36)
    C.part(c, bk, R.brass, { R = 1 })
    C.hline(c, sx, sx + 3, 34, R.strap[2]) C.hline(c, sx, sx + 3, 35, R.strap[3])
    c:put(sx - 1, 33, R.brass[6])
  end
  C.hline(c, 13, 46, 26, R.canvas[6])
  c:put(15, 25, C.cream)
  C.save(c, "backpack-3-bushmans-swag")
end

---------------------------------------------------------------- 4 bamboo frame pack
do
  local c = C.canvas("backpack-4-bamboo-frame-pack")
  local function pole(x0, y0, x1, y1, w, b)
    local m, n = X.cyl(x0, y0, x1, y1, function() return w end)
    local i = C.toneN(c, m, n, R.bamboo, { cuts = { .2, .36, .52, .7, .88 }, bias = C.bias(m, b) })
    -- nodes
    return m
  end
  -- two side poles converging up, crossbars
  local lp = pole(16, 56, 22, 10, 2, 0)
  local rp = pole(48, 56, 42, 10, 2, -1)
  for _, p in ipairs({ { 16, 56, 22, 10 }, { 48, 56, 42, 10 } }) do
    for _, t in ipairs({ .18, .5, .82 }) do
      local x, y = floor(p[1] + (p[3] - p[1]) * t + .5), floor(p[2] + (p[4] - p[2]) * t + .5)
      C.hline(c, x - 2, x + 2, y, R.bamboo[2]) C.hline(c, x - 1, x + 1, y - 1, R.bamboo[6])
    end
  end
  for _, y in ipairs({ 16, 50 }) do
    local x0 = floor(16 + (22 - 16) * (56 - y) / 46 + .5)
    local x1 = floor(48 - (48 - 42) * (56 - y) / 46 + .5)
    local bar = c:rect(x0, y - 1, x1, y + 1)
    C.sep(c, bar, lp:copy():add(rp), R.bamboo[1])
    C.part(c, bar, R.bamboo, { R = 1 })
    C.hline(c, x0 + 1, x1 - 1, y - 1, R.bamboo[6])
  end
  -- leaf-wrapped bundle lashed in the middle
  local bun = c:rrect(18, 20, 46, 47, 7)
  C.sep(c, bun, c:rect(0, 0, 63, 63), R.leafwrap[1])
  local bi = C.part(c, bun, R.leafwrap, { R = 5, cuts = { .2, .36, .52, .7, .88 } })
  -- leaf ribs: overlapping leaf panels slanting
  C.retone(c, bun, bi, R.leafwrap, function(x, y)
    local u = (x * 2 - y + 200) % 9
    if u == 0 then return -1 end
    if u == 1 and X.hash(x, y, 2) < .6 then return 1 end
  end)
  -- coir lashings: cross and horizontal wraps
  local lash = c:line({ {19,24}, {45,44} }, 1):add(c:line({ {45,24}, {19,44} }, 1))
    :add(c:line({ {16,33}, {48,33} }, 2))
  lash:each(function(x, y) c:put(x, y, R.coir[(x + y) % 2 == 0 and 5 or 3]) end)
  C.ball(c, 32, 34, 2, R.coir)
  -- quirk: glass float ball tied on top in a net
  local fm = C.ball(c, 32, 9, 5, R.sea)
  fm:each(function(x, y) if (x + y) % 4 == 0 or (x - y + 100) % 4 == 0 then c:put(x, y, R.coir[3]) end end)
  C.put(c, { {30,6}, {29,7} }, R.sea[6]) c:put(30, 7, C.cream)
  C.vline(c, 32, 14, 16, R.coir[3])
  C.save(c, "backpack-4-bamboo-frame-pack")
end

---------------------------------------------------------------- 5 pouch pack
do
  local c = C.canvas("backpack-5-pouch-pack")
  -- shoulder straps peeking at sides (behind)
  for _, sx in ipairs({ 12, 49 }) do
    local s = c:rrect(sx, 22, sx + 3, 50, 1)
    C.part(c, s, R.strap, { R = 1, b = -1 })
  end
  local body = c:ellipse(32, 38, 19, 17):add(c:rrect(16, 20, 48, 40, 6))
  local i = C.part(c, body, R.suede, { R = 7, hs = .9, cuts = { .18, .34, .5, .68, .86 } })
  C.speckle(c, body, i, R.suede, .06, 5)
  -- gathered drawstring top with ruffle
  local ruf = c:poly{ {22,20}, {42,20}, {38,12}, {26,12} }
  for x = 23, 41, 3 do ruf:add(c:ellipse(x, 12, 1.5, 1.5)) end
  C.sep(c, ruf, body, R.suede[1])
  local ri = C.part(c, ruf, R.suede, { R = 2, b = 1 })
  C.retone(c, ruf, ri, R.suede, function(x, y) if x % 3 == 0 then return -1 end end)
  local cord = c:rect(21, 19, 43, 21)
  C.fill(c, cord, R.strap[3]) C.hline(c, 21, 43, 19, R.strap[5])
  C.put(c, { {44,21}, {45,23}, {45,25} }, R.strap[3]) C.ball(c, 45, 27, 1.5, R.wood)
  -- front pouch: half-ellipse pocket with a rolled lip
  local pouch = c:ellipse(32, 44, 13, 10):clip(c:rect(0, 40, 63, 63))
  C.sep(c, pouch, body, R.suede[1])
  local pi2 = C.part(c, pouch, R.suede, { R = 4, b = -1 })
  pouch:shrink(1):edge():each(function(x, y) if y > 44 and (x + y) % 3 ~= 0 then c:put(x, y, R.suede[5]) end end)
  local lip = c:rrect(18, 38, 46, 42, 2)
  -- possum peeking out of the pouch (behind the lip)
  local PG = { "#3e3640", "#5a5058", "#786e74", "#968c90", "#b8b0ae", "#d8d0c8" }
  local head = c:ellipse(32, 34, 7, 5.5)
  for _, e in ipairs({ { 25, 28, -1 }, { 39, 28, 0 } }) do
    local ear = c:ellipse(e[1], e[2], 2.6, 3)
    C.sep(c, head, ear, C.ink)
    C.part(c, ear, PG, { R = 1, b = e[3] })
    C.put(c, { {e[1], e[2]}, {e[1], e[2] + 1} }, R.hibiscus[4])
  end
  local hn = X.sphere(31, 33, 7, head)
  C.toneN(c, head, hn, PG, { cuts = { .15, .3, .45, .62, .8 } })
  -- pale face mask, big dark eyes, pink nose
  C.put(c, { {31,35}, {32,35}, {33,35}, {30,36}, {31,36}, {32,36}, {33,36}, {34,36}, {32,34} }, PG[6])
  for _, ex in ipairs({ 28, 35 }) do
    C.put(c, { {ex,33}, {ex+1,33}, {ex,34}, {ex+1,34} }, C.ink)
    c:put(ex, 33, PG[6])
  end
  C.put(c, { {32,36}, {31,37}, {32,37}, {33,37} }, R.hibiscus[3])
  c:put(32, 36, R.hibiscus[5])
  C.vline(c, 32, 29, 32, PG[2])
  -- pouch lip over the possum's chin
  C.sep(c, lip, head, R.suede[1])
  local li = C.part(c, lip, R.suede, { R = 2, b = 1 })
  C.hline(c, 19, 45, 43, R.suede[2])
  for x = 20, 44, 3 do c:put(x, 40, R.suede[3]) end
  -- paws over the lip
  C.put(c, { {26,38}, {27,38}, {37,38}, {38,38} }, PG[5]) C.put(c, { {26,39}, {27,39}, {37,39}, {38,39} }, PG[3])
  -- stitches down the body sides
  for y = 26, 48, 3 do c:put(17 + floor((y - 26) / 12), y, R.suede[2]) end
  c:put(20, 26, R.suede[6]) c:put(21, 25, R.suede[6])
  C.save(c, "backpack-5-pouch-pack")
end
