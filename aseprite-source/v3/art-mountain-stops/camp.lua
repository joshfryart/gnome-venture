-- camp.lua : "Camp" stop look, MOUNTAIN (mountain_granite), 480x270 gate view.
-- Same composition and story as the Maplewold camp (art-2701-batch3/stops/opus3/camp.lua), re-cast as a high-pass camp:
-- road's end: the striped two-peak mess marquee (red and cream canvas, guyed to boulders) between a spruce and the
-- larches, stove-pipe smoke, a stone cairn with a waymark pole on the pass behind. Back left: a rust-canvas ridge tent
-- with its skirt weighted by stones, a snow patch in its lee; a washing line of wool socks from a spruce to a larch,
-- a gnome pegging. Right: the cream bell tent glowing inside, its hem held down by granite stones. Back right: the
-- pack goats on a picket line with their panniers and rolled loads, a pile of unloaded pack saddles. Left: larch and
-- arolla firewood between stakes under a granite lid, a ptarmigan. Hero: the cookfire in a lichened granite ring
-- with a larch tripod and pot, sheltered by a curved dry-stone windbreak (snow drift in its lee), log seats and a
-- granite slab bench, a lute player, a toasting gnome, a mug gnome, a Bernese dog asleep. Bottom left: the camp
-- kitchen table with a cheese wheel, bread, the enamel kettle and a milk can; a bucket of snow melting.
-- Edelweiss, gentian, juniper, boulders, choughs.
-- Quirk: a marmot climbing out of the green pack with a sausage, its dark-tipped tail over the rim.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-mountain-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "camp", out = DIR, farTrees = { 24, 52, 160, 196, 290, 318, 440 }, treeLineGap = { 194, 286 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, min, max = math.floor, math.sin, math.cos, math.pi, math.min, math.max
local G, IR = L.glow, L.iron
local HZ = F.HZ

-- local helpers ------------------------------------------------------------------------
local function stump(x, yb, w, k, seed)
  local body = rect(x - w, yb - w, x + w, yb)
  local top = c:ellipse(x, yb - w, w, max(1, w // 2))
  local roots = poly{ { x - w - 2, yb }, { x - w, yb - 3 }, { x - w, yb } }:add(poly{ { x + w + 2, yb }, { x + w, yb - 3 }, { x + w, yb } })
  rimOf(union(body, top, roots), L.timber)
  part(union(body, roots), L.timber, { nopop = true })
  body:each(function(xx, yy) if (xx - x) % 3 == 0 and hash(xx, yy // 2, seed or 5) < .6 then px(xx, yy, L.timber.shade) end end)
  vline(x - w + 1, yb - w + 1, yb - 1, L.timber.hi)
  fill(top, L.board.base)
  top:each(function(xx, yy) local d = math.sqrt((xx - x) ^ 2 + ((yy - (yb - w)) * 2) ^ 2) if floor(d) % 2 == 1 then px(xx, yy, L.board.shade) end if xx - x + (yy - (yb - w)) * 2 < -w * .6 then px(xx, yy, L.board.hi) end end)
  px(x, yb - w, L.board.deep)
  if k then F.lichen(body, k, seed or 7) end
  return body, top
end
local function pebble(x, y) px(x, y, L.stone.base) px(x + 1, y, L.stone.shade) px(x, y - 1, L.stone.hi) px(x + 1, y + 1, L.stone.deep) end
-- a lingering snow patch (ragged top, cold blue shade underneath)
local function snowPatch(x0, x1, yb, h, seed)
  local m = HP.mask()
  for x = x0, x1 do
    local t = (x - x0) / max(1, x1 - x0)
    local hh = floor(h * sin(t * pi) ^ .6 + hash(x // 2, 1, seed) * 2)
    for y = yb - hh, yb do m:set(x, y) end
  end
  m:each(function(x, y)
    local top = not m:has(x, y - 1)
    px(x, y, top and L.snow.hi or (y >= yb and L.snow.shade or (hash(x, y, seed + 1) < .15 and L.snow.shade or L.snow.base)))
  end)
  hline(x0 + 1, x1 - 1, yb + 1, L.snow.deep)
  return m
end
-- dry-stone wall along a path of (x, yBase, height) knots
local function dryWall(knots, seed)
  local m, tops = HP.mask(), {}
  for i = 1, #knots - 1 do
    local a, b = knots[i], knots[i + 1]
    for x = a[1], b[1] do
      local t = (x - a[1]) / max(1, b[1] - a[1])
      local yb = floor(a[2] + (b[2] - a[2]) * t + .5)
      local h = floor(a[3] + (b[3] - a[3]) * t + .5)
      for y = yb - h, yb do m:set(x, y) end
      tops[x] = yb - h
    end
  end
  rimOf(m, L.stone)
  m:each(function(x, y)
    local row = (y - (tops[x] or y)) // 3
    local v = hash((x + row * 2) // 4, y // 3, seed)
    local h = v < .3 and L.stone.hi or (v < .75 and L.stone.base or L.stone.shade)
    if (y - (tops[x] or y)) % 3 == 2 or ((x + row * 2) % 4 == 0 and hash(x, y, seed + 1) < .7) then h = L.stone.deep end
    if not m:has(x, y - 1) then h = L.stone.hi end
    if not m:has(x + 1, y) or x > 176 and hash(x, y, seed + 2) < .25 then h = L.stone.shade end
    px(x, y, h)
  end)
  F.lichen(m, .28, seed + 3)
  return m, tops
end

-- trodden gravel-and-earth clearing around the fire (left of the road)
local clear = c:ellipse(150, 214, 92, 30)
clear:each(function(x, y) if not F.roadM:has(x, y) and x < F.xl(y) - 1 then
  local v = hash(x, y, 3)
  local d = ((x - 150) / 92) ^ 2 + ((y - 214) / 30) ^ 2
  if d < .8 then
    local b = hash(x // 4, y // 2, 4)
    local h = b < .5 and L.soil.base or (b < .8 and L.duff or L.soil.shade)
    if v < .05 then h = L.stone.hi elseif v > .95 then h = L.soil.deep elseif v > .9 then h = L.road.shade end
    px(x, y, h)
  elseif hash(x // 3, y // 2, 4) < .45 then px(x, y, hash(x, y, 5) < .5 and L.duff or L.ground.shade) end
end end)
for i = 0, 22 do
  local x, y = 70 + floor(hash(i, 1, 6) * 150), 192 + floor(hash(i, 2, 6) * 46)
  if clear:has(x, y) and not F.roadM:has(x, y) and x < F.xl(y) - 3 then pebble(x, y) end
end

---------------------------------------------------------------- the pass behind: a cairn with a waymark pole
F.depth(0)
do
  local cx, yb = 356, HZ - 1
  local m = HP.mask()
  for k = 0, 3 do m:add(c:ellipse(cx + (k % 2), yb - 1 - k * 3, 5 - k, 2)) end
  rimOf(m, L.peak) part(m, L.peak, { nopop = true })
  m:each(function(x, y) if not m:has(x, y - 1) then px(x, y, L.peak.hi) elseif hash(x, y, 9) < .3 then px(x, y, L.peak.deep) end end)
  vline(cx, yb - 22, yb - 11, L.timber.deep)
  for y = yb - 22, yb - 15 do px(cx + 1, y, ((y // 2) % 2 == 0) and L.awnA.base or L.awnB.hi) end
end

---------------------------------------------------------------- back trees (plane 1)
F.depth(1)
F.tree(10, 140, 46, 1)
F.tree(318, 138, 46, 0)
F.tree(384, 142, 58, 6)
F.tree(444, 136, 44, 3)

---------------------------------------------------------------- road's end: the striped two-peak mess marquee
F.depth(2)
F.tree(292, 128, 50, 2)
do
  local cx, yb = 240, 128
  local wall = rect(cx - 34, yb - 16, cx + 34, yb)
  local roofm = poly{ { cx - 42, yb - 15 }, { cx - 16, yb - 44 }, { cx, yb - 32 }, { cx + 16, yb - 44 }, { cx + 42, yb - 15 } }
  local poles = rect(cx - 17, yb - 54, cx - 16, yb - 44):add(rect(cx + 16, yb - 54, cx + 17, yb - 44))
  F.shadow(cx - 34, cx + 34, yb, 10, 3)
  rimOf(union(wall, roofm, poles), L.timber)
  local R, C = L.awnA, L.awnB
  roofm:each(function(x, y)
    local pk = x < cx and cx - 16 or cx + 16
    local u = (x - pk) / (y - (yb - 46))
    local k = floor(u * 5 + 20)
    local h = (k % 2 == 0) and R.base or C.hi
    if (u * 5 + 20) % 1 < .14 then h = (k % 2 == 0) and R.shade or C.shade end
    if x > pk + 6 and (x - pk) / 26 + (y - (yb - 44)) / 30 > .9 then h = (k % 2 == 0) and R.shade or C.base end
    if x < pk - 2 and (pk - x) / 10 + (y - (yb - 44)) / 12 < 1.1 then h = (k % 2 == 0) and R.hi or C.hi end
    px(x, y, h)
  end)
  -- weathered: a faded patch sewn on the canvas
  fill(rect(cx - 30, yb - 24, cx - 27, yb - 21), L.roof2.hi) px(cx - 30, yb - 24, L.roof2.base)
  wall:each(function(x, y)
    local k = ((x - cx + 40) // 6) % 2
    local h = k == 0 and C.base or R.hi
    if x > cx + 22 then h = k == 0 and C.shade or R.base end
    if y >= yb - 1 then h = L.stone.base end
    px(x, y, h)
  end)
  for x = cx - 40, cx + 38, 6 do fill(poly{ { x, yb - 15 }, { x + 6, yb - 15 }, { x + 3, yb - 11 } }, L.accent.base) px(x + 3, yb - 12, L.accent.shade) px(x + 1, yb - 15, L.accent.hi) end
  hline(cx - 42, cx + 42, yb - 15, L.accent.deep)
  local door = poly{ { cx - 8, yb }, { cx - 5, yb - 12 }, { cx + 5, yb - 12 }, { cx + 8, yb } }
  fill(door, G.shade) fill(rect(cx - 3, yb - 9, cx + 3, yb), G.base) px(cx - 2, yb - 8, G.hi)
  part(poles, L.timber, { nopop = true, noshade = true })
  for _, p in ipairs({ { cx - 16, L.gentian }, { cx + 17, L.gold } }) do fill(poly{ { p[1] + 1, yb - 54 }, { p[1] + 10, yb - 52 }, { p[1] + 1, yb - 49 } }, p[2].base) px(p[1] + 2, yb - 53, p[2].hi) end
  -- guy lines tied off to boulders (no pegs hold in scree)
  for _, g in ipairs({ { cx - 42, cx - 52 }, { cx + 42, cx + 52 } }) do
    line({ { g[1], yb - 15 }, { g[2], yb - 1 } }):each(function(x, y) px(x, y, L.board.deep) end)
    F.boulder(g[2], yb + 2, 3, 3, g[2])
  end
  fill(rect(cx + 25, yb - 34, cx + 27, yb - 28), IR.base) px(cx + 25, yb - 34, IR.hi) hline(cx + 24, cx + 28, yb - 35, IR.deep)
  F.smoke(cx + 26, yb - 38, 5, .6, 2) -- stove pipe smoke
  -- firewood by the marquee
  for k = 0, 2 do F.logEnd(cx + 36 + k * 4, yb - 2, 2, L.redbark) end
  F.logEnd(cx + 38, yb - 6, 2) F.logEnd(cx + 42, yb - 6, 2, L.redbark)
end

---------------------------------------------------------------- back left: ridge tent, skirt weighted with stones
local function ridgeTent(x, yb, w, h, r, flap)
  local front = poly{ { x - w, yb }, { x, yb - h }, { x + w, yb } }
  local side = poly{ { x, yb - h }, { x + w + 18, yb - h + 4 }, { x + w + 22, yb - 2 }, { x + w, yb } }
  local door = poly{ { x - w // 3, yb }, { x, yb - h * 2 // 3 }, { x + w // 3, yb } }
  F.shadow(x - w, x + w + 22, yb, 10, 3)
  rimOf(union(front, side), r)
  part(side, r, { noshade = true }) side:each(function(xx, y) if (xx - x) % 6 == 0 then px(xx, y, r.shade) end end)
  part(front, r, { sep = true })
  fill(door, r.deep) fill(poly{ { x - 1, yb }, { x, yb - h * 2 // 3 }, { x + w // 3, yb } }, L.soil.deep)
  if flap then fill(poly{ { x, yb - h * 2 // 3 }, { x - w // 3 - 4, yb - 2 }, { x - w // 3, yb } }, r.hi) end
  vline(x, yb - h - 4, yb - h, L.timber.base)
  line({ { x - w - 4, yb + 1 }, { x - w + 2, yb - 4 } }):each(function(xx, y) px(xx, y, L.board.shade) end)
  line({ { x + w + 26, yb + 1 }, { x + w + 18, yb - 6 } }):each(function(xx, y) px(xx, y, L.board.shade) end)
  for xx = x - w + 1, x + w + 20, 5 do pebble(xx, yb) end
end
F.depth(1)
snowPatch(52, 86, 147, 3, 11)
ridgeTent(36, 146, 14, 18, L.roof2, true)
F.juniper(64, 151, 6, 4, 5) F.edelweiss(18, 149, true)
F.depth(2)
-- boulders at the foot of the washing line
F.snow(F.boulder(108, 157, 8, 7, 21), .5, 23) F.boulder(124, 158, 6, 5, 22)
F.juniper(140, 158, 7, 4, 6) F.gentian(96, 158, true) F.edelweiss(132, 158, true)
F.depth(1)

---------------------------------------------------------------- washing line from a spruce to a larch
F.tree(84, 140, 46, 4)
F.depth(2)
F.larch(184, 140, 46, 37)
local function sagY(x) local t = (x - 88) / (182 - 88) return floor(108 + 8 * sin(t * pi)) end
for x = 88, 182 do px(x, sagY(x), L.timber.deep) end
for i, it in ipairs({ { 98, L.awnA, "sock" }, { 112, L.accent, "shirt" }, { 132, L.gold, "sock" }, { 146, L.awnB, "shirt" }, { 166, L.lav, "sock" } }) do
  local x = it[1] local y = sagY(x) + 1 local r = it[2]
  local m
  if it[3] == "sock" then m = rect(x, y, x + 3, y + 8):add(rect(x, y + 6, x + 6, y + 9))
  else m = rect(x - 2, y, x + 10, y + 3):add(rect(x + 1, y, x + 7, y + 13)) end
  rimOf(m, r) part(m, r, { nopop = true })
  hline(x, x + 3, y, r.hi) px(x + 1, y - 1, L.timber.base)
  if it[3] == "sock" then hline(x, x + 3, y + 2, L.awnB.hi) hline(x, x + 3, y + 4, L.awnB.hi) px(x + 5, y + 8, L.awnB.hi) -- knitted bands, darned heel
  else for k = 0, 2 do hline(x + 1, x + 7, y + 5 + k * 3, r.shade) end end -- knitted ribs
end

---------------------------------------------------------------- right: cream bell tent glowing inside, hem held by stones
F.depth(3)
local W2 = L.wall2
local mixS = F.mix(W2.hi, W2.base, .5)
local function bellTent(cx, yb)
  local wall = rect(cx - 46, yb - 26, cx + 46, yb)
  local cone = poly{ { cx - 52, yb - 24 }, { cx - 30, yb - 46 }, { cx, yb - 62 }, { cx + 30, yb - 46 }, { cx + 52, yb - 24 } }
  local pole = rect(cx - 1, yb - 74, cx, yb - 62)
  F.shadow(cx - 44, cx + 46, yb, 16, 5)
  rimOf(union(wall, cone, pole), L.timber)
  cone:each(function(x, y)
    local u = (x - cx) / (yb + 4 - y)
    local k = floor(u * 9 + 20) % 2
    local edge = (u * 9 + 20) % 1 < .12
    local lit = x < cx - 4 and (cx - x) / 30 + (y - (yb - 62)) / 22 < 1.3
    px(x, y, edge and L.awnB.deep or (k == 0 and (lit and W2.hi or mixS) or (lit and L.plaster.hi or L.awnB.hi)))
  end)
  wall:each(function(x, y)
    local k = floor((x - cx) / 10 + 20) % 2
    px(x, y, ((x - cx) % 10 == 0) and L.awnB.deep or (k == 0 and L.awnB.hi or W2.hi))
  end)
  wall:each(function(x, y) if x > cx + 30 and (x - cx) % 10 ~= 0 then px(x, y, (floor((x - cx) / 10 + 20) % 2 == 0) and L.awnB.shade or W2.base) end end)
  cone:each(function(x, y) if x > cx + 20 and (x - cx) / 52 + (y - (yb - 62)) / 40 > 1.1 and c:get(x, y) ~= L.awnB.deep then px(x, y, (floor((x - cx) / (yb + 4 - y) * 9 + 20) % 2 == 0) and W2.shade or L.awnB.shade) end end)
  -- a smoke-darkened ring round the stove-pipe collar, rime on the shaded cone
  cone:each(function(x, y) if y < yb - 56 and hash(x, y, 84) < .4 then px(x, y, L.awnB.shade) end end)
  cone:each(function(x, y) if x > cx + 8 and y < yb - 36 and hash(x // 2, y, 85) < .07 then px(x, y, L.snow.hi) end end)
  -- dusty hem
  wall:each(function(x, y)
    local hgt = 1 + floor(hash(x // 3, 0, 86) * 3)
    if y >= yb - hgt then px(x, y, hash(x, y, 87) < .5 and L.soil.hi or L.awnB.shade) end
  end)
  hline(cx - 52, cx + 52, yb - 24, L.roof2.deep) hline(cx - 51, cx + 51, yb - 23, L.roof2.shade)
  for x = cx - 50, cx + 48, 6 do fill(poly{ { x, yb - 22 }, { x + 6, yb - 22 }, { x + 3, yb - 18 } }, L.roof2.base) px(x + 3, yb - 19, L.roof2.shade) px(x + 1, yb - 22, L.roof2.hi) end
  part(pole, L.timber, { nopop = true, noshade = true })
  local fl = poly{ { cx + 1, yb - 74 }, { cx + 12, yb - 71 }, { cx + 1, yb - 68 } } fill(fl, L.awnA.base) px(cx + 2, yb - 73, L.awnA.hi) px(cx + 9, yb - 71, L.awnA.shade)
  -- open door with warm light, a hanging lantern, a sheepskin rug, a bedroll
  local door = poly{ { cx - 12, yb }, { cx - 6, yb - 30 }, { cx + 6, yb - 30 }, { cx + 12, yb } }
  fill(door, G.shade) fill(poly{ { cx - 8, yb }, { cx - 4, yb - 26 }, { cx + 4, yb - 26 }, { cx + 8, yb } }, G.base)
  fill(rect(cx - 2, yb - 22, cx + 2, yb - 16), G.hi) vline(cx, yb - 26, yb - 23, L.timber.edge) px(cx - 1, yb - 21, L.awnB.hi)
  fill(rect(cx - 6, yb - 6, cx + 6, yb - 1), L.goat.base) hline(cx - 6, cx + 6, yb - 6, L.goat.hi)
  for x = cx - 5, cx + 5, 2 do px(x, yb - 4, L.goat.shade) px(x + 1, yb - 2, L.goat.shade) end
  local flapL = poly{ { cx - 12, yb }, { cx - 6, yb - 30 }, { cx - 20, yb - 2 } } fill(flapL, L.awnB.shade) c:edgeIn(flapL, L.awnB.deep)
  local flapR = poly{ { cx + 12, yb }, { cx + 6, yb - 30 }, { cx + 20, yb - 2 } } fill(flapR, L.awnB.shade) c:edgeIn(flapR, L.awnB.deep)
  for _, t in ipairs({ { cx - 14, yb - 14 }, { cx + 14, yb - 14 } }) do hline(t[1] - 1, t[1] + 1, t[2], L.roof2.base) end -- tie-backs
  -- guy lines to boulders
  for _, g in ipairs({ { cx - 52, yb - 24, cx - 64, yb + 1 }, { cx + 52, yb - 24, cx + 64, yb + 1 } }) do
    line({ { g[1], g[2] }, { g[3], g[4] - 3 } }):each(function(x, y) px(x, y, L.board.deep) end)
  end
end
bellTent(350, 196)
F.boulder(286 + 0, 198, 4, 4, 51) -- (behind the lantern pole)
F.boulder(414, 198, 5, 5, 52)
-- granite stones holding the hem down
for k = 0, 11 do
  local x = 308 + k * 8
  if x < 336 or x > 364 then F.boulder(x, 198 + (k % 2), 3, 2 + (k % 2), 60 + k) end
end
F.edelweiss(300, 202, true) F.gentian(306, 204, true) F.edelweiss(398, 203, true) F.gentian(404, 201, true)
F.juniper(392, 206, 6, 4, 7)

---------------------------------------------------------------- back right: pack goats on a picket line
local function packGoat(x, yb, k, flip, coat, bag, load)
  F.goat(x, yb, { k = k, flip = flip, r = coat })
  local s = flip and -1 or 1
  local function P(dx, dy) return x + floor(dx * k + .5) * s, yb + floor(dy * k + .5) end
  local ax, ay = P(-7, -16)
  local bx, by = P(3, -8)
  local pan = rect(min(ax, bx), ay, max(ax, bx), by)
  rimOf(pan, bag) part(pan, bag, { nopop = true })
  hline(min(ax, bx), max(ax, bx), ay, bag.hi)
  local mx = (ax + bx) // 2
  vline(mx, ay, by, L.timber.deep) px(mx, ay + 2, L.gold.hi) -- strap and buckle
  -- the rolled load across the saddle
  local lx, ly = P(-2, -18)
  local roll = c:rrect(lx - floor(7 * k), ly - 2, lx + floor(7 * k), ly + 1, 1)
  rimOf(roll, load) part(roll, load, { nopop = true })
  hline(lx - floor(7 * k) + 1, lx + floor(7 * k) - 1, ly - 2, load.hi)
  vline(lx - 2, ly - 2, ly + 1, L.timber.deep) vline(lx + 2, ly - 2, ly + 1, L.timber.deep)
end
F.depth(2)
do
  -- picket line between two stakes
  local y0, y1 = 126, 128
  for _, sx in ipairs({ 398, 470 }) do local st = rect(sx, 120, sx + 1, 146) rimOf(st, L.timber) part(st, L.timber, { nopop = true, noshade = true }) end
  for x = 399, 470 do px(x, floor(y0 + (y1 - y0) * (x - 399) / 71 + 2 * sin((x - 399) / 71 * pi)), L.board.deep) end
  F.shadow(408, 466, 156, 8, 3)
  packGoat(418, 156, .86, false, L.goat, L.roof2, L.wall2)
  packGoat(454, 154, .8, true, L.chamois, L.awnA, L.awnB)
  -- lead ropes to the line
  line({ { 431, 138 }, { 433, 130 } }):each(function(x, y) px(x, y, L.board.deep) end)
  line({ { 441, 136 }, { 440, 130 } }):each(function(x, y) px(x, y, L.board.deep) end)
  -- pile of unloaded pack saddles and panniers
  local ps = c:rrect(394, 151, 406, 157, 2) rimOf(ps, L.timber) part(ps, L.timber, { nopop = true })
  hline(395, 405, 151, L.timber.hi) px(397, 150, L.timber.base) px(403, 150, L.timber.base)
  local pn = rect(396, 145, 404, 150) rimOf(pn, L.awnA) part(pn, L.awnA, { nopop = true }) vline(400, 145, 150, L.timber.deep)
end
F.tree(472, 150, 46, 5)
F.depth(3)

---------------------------------------------------------------- left: larch and arolla firewood under a granite lid
local function woodStack(x0, x1, yb)
  local stakes = rect(x0 - 2, yb - 22, x0, yb):add(rect(x1, yb - 22, x1 + 2, yb))
  local stack = rect(x0 + 1, yb - 18, x1 - 1, yb)
  F.shadow(x0, x1 + 2, yb, 8, 3)
  rimOf(union(stakes, stack), L.timber)
  part(stakes, L.timber, { nopop = true, noshade = true })
  px(x0 - 2, yb - 22, L.timber.hi) px(x1, yb - 22, L.timber.hi)
  fill(stack, L.timber.edge)
  for row = 0, 3 do for k = 0, (x1 - x0) // 6 do
    local x, y = x0 + 3 + k * 6 + (row % 2) * 3, yb - 3 - row * 5
    if x < x1 - 1 then F.logEnd(x, y, 2, (hash(k, row, 90) < .35) and L.redbark or L.timber) end
  end end
  -- a granite slab lid with weighting stones, snow on top
  local lid = rect(x0 - 4, yb - 25, x1 + 4, yb - 21)
  rimOf(lid, L.roof) part(lid, L.roof, { nopop = true }) F.courses(lid, yb - 25, 5, 9, L.roof) F.lichen(lid, .3, 91)
  hline(x0 - 3, x1 + 3, yb - 25, L.roof.hi)
  for _, wx in ipairs({ x0 + 8, x1 - 10 }) do local ws = c:ellipse(wx, yb - 27, 3, 2) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true }) px(wx - 1, yb - 28, L.stone.hi) end
  F.snow(rect(x0 + 14, yb - 25, x1 - 16, yb - 25), .9, 92)
end
woodStack(22, 72, 196)
-- a ptarmigan in summer plumage, pecking at the woodpile
F.sprite({
  "..bBb......",
  ".rbBBb.....",
  "kebBhBb....",
  ".bBBBBBbb..",
  "..wBbBbBBbb",
  "..wwwBbBbbt",
  "...wwwwwwt.",
  "....f..f...",
}, 76, 189, { b = L.soil.shade, B = L.chamois.hi, h = L.board.hi, r = L.apple.base, e = L.timber.edge, k = IR.deep, w = L.edel.hi, t = L.timber.deep, f = L.goat.shade })
F.juniper(16, 206, 7, 5, 8) F.edelweiss(28, 204, true) F.gentian(84, 204, true)
-- a gnome pegging a sock on the washing line
F.gnome(140, 134, { small = true, hat = L.produce, coat = L.leaf, arm = "up" })

---------------------------------------------------------------- the dry-stone windbreak behind the fire
F.depth(2)
do
  local wm = dryWall({ { 76, 186, 6 }, { 92, 178, 9 }, { 132, 174, 11 }, { 172, 177, 10 }, { 196, 186, 6 } }, 70)
  F.snow(wm:copy():clip(rect(76, 150, 150, 190)), .6, 71)
  snowPatch(184, 204, 188, 3, 72)
  -- pack frames leaning on the wall
  for _, fx in ipairs({ 150, 160 }) do
    local fr = line({ { fx, 177 }, { fx + 3, 163 } }, 1):add(line({ { fx + 6, 177 }, { fx + 8, 164 } }, 1)):add(rect(fx + 1, 168, fx + 7, 168)):add(rect(fx + 2, 173, fx + 7, 173))
    rimOf(fr, L.timber) part(fr, L.timber, { nopop = true, noshade = true })
  end
end
F.depth(3)

---------------------------------------------------------------- the cookfire (hero) with tripod pot, seats and stumps
local function campfire(cx, cy)
  local function seat(x0, x1, y, bark)
    bark = bark or L.timber
    local m = c:rrect(x0, y - 4, x1, y + 4, 4)
    F.shadow(x0, x1, y + 6, 4, 2)
    rimOf(m, bark) part(m, bark, { nopop = true })
    F.logs(m, bark, y - 4, 9)
    hline(x0 + 4, x1 - 4, y - 3, bark.hi)
    m:each(function(x, yy) if (x * 3 + yy) % 13 == 0 then px(x, yy, bark.deep) end end)
    m:each(function(x, yy) if yy <= y - 2 and hash(x // 2, yy, x0) < .12 then px(x, yy, bark.hi) end end)
    F.lichen(m:copy():clip(rect(x0, y + 1, x1, y + 4)), .3, x0 + 1)
    F.logEnd(x1 - 3, y, 4, bark)
  end
  -- a granite slab bench on two stones
  local function slab(x0, x1, y)
    F.shadow(x0, x1, y + 6, 4, 2)
    for _, sx in ipairs({ x0 + 4, x1 - 4 }) do F.boulder(sx, y + 5, 4, 4, sx) end
    local top = poly{ { x0, y - 2 }, { x1 - 2, y - 3 }, { x1, y + 1 }, { x0 + 1, y + 2 } }
    rimOf(top, L.stone) part(top, L.stone, { nopop = true })
    line({ { x0 + 1, y - 2 }, { x1 - 2, y - 3 } }):each(function(x, yy) px(x, yy, L.stone.hi) end)
    hline(x0 + 2, x1 - 1, y + 1, L.stone.deep)
    F.lichen(top, .3, x0 + 3)
    -- a folded sheepskin on it
    fill(rect(x0 + 6, y - 4, x0 + 13, y - 2), L.goat.base) hline(x0 + 6, x0 + 13, y - 4, L.goat.hi) px(x0 + 8, y - 3, L.goat.shade) px(x0 + 11, y - 3, L.goat.shade)
  end
  seat(cx - 34, cx + 38, cy - 24)
  local pit = c:ellipse(cx, cy, 17, 5)
  fill(pit, L.soil.deep)
  pit:each(function(x, y) if hash(x, y, 8) < .3 then px(x, y, L.road.shade) end end) -- ash
  for k = 0, 13 do
    local a = k / 14 * 2 * pi
    local x, y = floor(cx + cos(a) * 21), floor(cy + sin(a) * 7)
    local st = c:rrect(x - 4, y - 3, x + 3, y + 2, 2)
    rimOf(st, L.stone) part(st, L.stone, { nopop = k % 3 ~= 0 })
    if sin(a) > -.2 then F.lichen(st, .25, 92 + k) end
    if sin(a) < -.2 then st:each(function(xx, yy) if yy >= y + 1 and hash(xx, yy, 95) < .5 then px(xx, yy, L.stone.deep) end end) end -- soot
  end
  local logs = line({ { cx - 12, cy + 2 }, { cx + 10, cy - 4 } }, 3):add(line({ { cx - 10, cy - 4 }, { cx + 12, cy + 2 } }, 3))
  rimOf(logs, L.timber) part(logs, L.redbark, { nopop = true })
  logs:each(function(x, y) if hash(x, y, 93) < .25 then px(x, y, G.deep) end end) -- charred glowing cracks
  pit:each(function(x, y) if hash(x, y, 9) < .25 and not logs:has(x, y) then px(x, y, G.deep) end end)
  local fl = poly{ { cx - 12, cy }, { cx - 9, cy - 16 }, { cx - 5, cy - 9 }, { cx - 2, cy - 28 }, { cx + 2, cy - 12 }, { cx + 6, cy - 22 }, { cx + 9, cy - 8 }, { cx + 12, cy } }
  fill(fl, G.deep)
  fill(fl:shrink(1), G.shade)
  fill(poly{ { cx - 8, cy }, { cx - 3, cy - 20 }, { cx + 1, cy - 9 }, { cx + 5, cy - 15 }, { cx + 8, cy } }, G.base)
  fill(poly{ { cx - 4, cy }, { cx - 1, cy - 12 }, { cx + 3, cy } }, G.hi)
  for i = 0, 14 do px(cx - 14 + floor(hash(i, 1, 31) * 30), cy - 32 - floor(hash(i, 2, 31) * 24), i % 3 == 0 and G.base or G.hi) end
  local tri = line({ { cx - 18, cy + 4 }, { cx, cy - 40 } }, 2):add(line({ { cx + 18, cy + 4 }, { cx, cy - 40 } }, 2)):add(line({ { cx + 4, cy - 2 }, { cx, cy - 40 } }, 1))
  rimOf(tri, L.timber) part(tri, L.timber, { nopop = true, noshade = true }) -- peeled larch poles
  tri:each(function(x, y) if hash(x, y // 2, 94) < .2 then px(x, y, L.board.base) end end)
  hline(cx - 2, cx + 2, cy - 38, L.board.deep) -- lashing
  vline(cx, cy - 37, cy - 30, IR.deep)
  local pot = c:ellipse(cx, cy - 25, 7, 5):add(rect(cx - 7, cy - 28, cx + 7, cy - 26))
  rimOf(pot, IR) part(pot, IR) hline(cx - 7, cx + 7, cy - 28, IR.hi) fill(rect(cx - 5, cy - 29, cx + 5, cy - 29), L.cheese.base)
  px(cx - 3, cy - 29, L.produce.base) px(cx + 2, cy - 29, L.leaf.base) -- barley soup: a carrot, a herb
  fill(c:ellipse(cx, cy - 29, 7, 3):cut(c:ellipse(cx, cy - 29, 6, 2)):clip(rect(cx - 8, cy - 33, cx + 8, cy - 29)), IR.deep)
  F.smoke(cx + 1, cy - 38, 8, .5, 2)
  -- warm light on the gravel
  local glowM = c:ellipse(cx, cy + 4, 42, 14):cut(c:ellipse(cx, cy, 25, 10))
  glowM:each(function(x, y) if hash(x, y, 33) < .3 and not F.roadM:has(x, y) then px(x, y, hash(x, y, 34) < .5 and L.gold.hi or L.board.hi) end end)
  seat(cx - 46, cx - 22, cy + 4)
  slab(cx + 24, cx + 50, cy + 2)
  seat(cx - 16, cx + 18, cy + 20, L.redbark)
end
campfire(132, 214)
local _, lx, ly = F.gnome(104, 191, { hat = L.leaf, coat = L.roof2, arm = "hold", noShadow = true })
local lute = c:ellipse(lx + 2, ly, 4, 3):add(line({ { lx + 5, ly - 1 }, { lx + 12, ly - 6 } }, 1))
rimOf(lute, L.timber) part(lute, L.board, { nopop = true }) fill(c:ellipse(lx + 2, ly, 1, 1), L.timber.edge) px(lx + 12, ly - 7, L.timber.base)
for _, n in ipairs({ { lx + 8, ly - 14 }, { lx + 13, ly - 18 } }) do vline(n[1] + 1, n[2] - 3, n[2], L.timber.edge) fill(rect(n[1], n[2], n[1] + 1, n[2] + 1), L.timber.edge) end
local _, mx, my = F.gnome(96, 210, { hat = L.awnA, coat = L.accent, arm = "out" })
-- a toasting stick: a cube of cheese melting and a sausage end
fill(line({ { mx, my }, { mx + 10, my - 7 } }), L.board.base) fill(rect(mx + 10, my - 9, mx + 12, my - 7), L.cheese.base) px(mx + 10, my - 9, L.cheese.hi) px(mx + 12, my - 6, L.cheese.shade) px(mx + 11, my - 6, L.cheese.hi)
px(mx + 6, my - 5, L.awnA.shade) px(mx + 7, my - 5, L.awnA.deep)
local _, ux, uy = F.gnome(174, 208, { hat = L.gold, coat = L.lav, arm = "out", flip = true })
fill(rect(ux - 3, uy - 3, ux, uy + 1), L.accent.base) px(ux, uy - 2, L.accent.shade) px(ux - 3, uy - 3, L.accent.hi) px(ux - 2, uy - 5, L.cloud.top) px(ux - 1, uy - 7, L.cloud.top)
-- a Bernese dog asleep by the fire, nose on its paws
F.sprite({
  ".ee.............",
  "eDDe....DDDDD...",
  "DweDDDDDDDDDDD..",
  "nwRDDDDDDDdDDDt.",
  "wwwRRDDDDDDDDDtw",
  ".wwRRdRRddRRd...",
}, 154, 228, { e = IR.deep, D = "#3c3a44", d = "#2e2c36", n = L.timber.edge, w = L.edel.hi, R = L.chamois.base, t = "#3c3a44" })
px(159, 229, "#56525e") px(164, 229, "#56525e") px(170, 230, "#56525e")
hline(156, 157, 230, L.timber.edge)
-- a stump stool by the lute player, pebbles by the ring
stump(66, 216, 5, .3, 23)
F.edelweiss(84, 222, true) F.gentian(192, 236, true) F.edelweiss(196, 232, true)

---------------------------------------------------------------- camp kitchen table, bottom-left
local tbl = rect(24, 236, 76, 239):add(rect(27, 240, 30, 252)):add(rect(70, 240, 73, 252))
F.shadow(26, 76, 252, 8, 3)
rimOf(tbl, L.timber) part(tbl, L.board, { nopop = true })
F.planks(rect(24, 236, 76, 239), L.board, 9, true, 31)
local ket = c:ellipse(34, 231, 5, 4):add(rect(39, 228, 42, 229)) rimOf(ket, L.accent) part(ket, L.accent) fill(rect(32, 226, 36, 227), L.accent.shade)
px(32, 230, L.edel.hi) px(35, 233, L.iron.deep) -- an enamel chip
-- a cheese wheel, a cut wedge and a round loaf on a board
local brd = rect(44, 234, 62, 235) rimOf(brd, L.timber) fill(brd, L.board.base) hline(44, 62, 234, L.board.hi)
local ch = c:rrect(45, 227, 55, 233, 2) c:rim(ch, L.cheese.edge) part(ch, L.cheese, { nopop = true }) hline(46, 54, 227, L.cheese.hi) hline(46, 54, 233, L.cheese.deep)
fill(poly{ { 50, 227 }, { 55, 227 }, { 55, 230 } }, L.cheese.hi) px(52, 229, L.cheese.shade) px(53, 231, L.cheese.shade)
local loaf = c:ellipse(59, 231, 3, 2) rimOf(loaf, L.board) part(loaf, L.roof2, { nopop = true }) px(58, 230, L.board.hi) px(60, 230, L.roof2.deep)
-- a milk can
local can = rect(65, 225, 72, 235):add(rect(66, 222, 71, 224))
rimOf(can, IR) part(can, IR, { nopop = true }) vline(66, 225, 234, IR.hi) hline(65, 72, 229, IR.shade) hline(66, 71, 222, IR.hi)
-- under the table: a bucket of snow melting, junipers and edelweiss
local bucket = rect(40, 244, 48, 251) rimOf(bucket, L.timber) part(bucket, L.timber, { nopop = true }) hline(40, 48, 246, IR.shade)
local snowB = c:ellipse(44, 243, 4, 2) fill(snowB, L.snow.base) hline(42, 46, 242, L.snow.hi) px(47, 244, L.water.base)
F.juniper(18, 256, 8, 5, 9) F.edelweiss(84, 250, true) F.gentian(88, 254, true) F.edelweiss(12, 244, true)
F.boulder(160, 262, 7, 5, 31)

---------------------------------------------------------------- bedrolls, packs and the marmot (right of the road)
local function bedroll(x, y, r)
  local m = c:rrect(x - 14, y - 5, x + 14, y + 5, 5)
  rimOf(m, r) part(m, r)
  for k = -8, 8, 8 do vline(x + k, y - 5, y + 5, r.deep) end
  local e = c:ellipse(x + 12, y, 3, 5) fill(e, r.hi) c:ellipse(x + 12, y, 1, 3):edge():each(function(xx, yy) px(xx, yy, r.shade) end)
  hline(x - 6, x - 4, y - 5, L.timber.base)
  m:each(function(xx, yy) if (xx + yy * 2) % 7 == 0 and yy < y then px(xx, yy, r.hi) end end) -- wool check
end
bedroll(300, 230, L.wall2) bedroll(312, 240, L.roof2)
local function pack(x, yb, r)
  local m = c:rrect(x - 8, yb - 18, x + 8, yb, 4)
  local flap = c:rrect(x - 8, yb - 20, x + 8, yb - 12, 3)
  F.shadow(x - 6, x + 8, yb, 6, 2)
  rimOf(union(m, flap), r) part(m, r) part(flap, r, { sep = true })
  fill(rect(x - 1, yb - 13, x + 1, yb - 11), L.gold.base) px(x - 1, yb - 13, L.gold.hi)
  vline(x - 5, yb - 11, yb - 2, r.deep) vline(x + 5, yb - 11, yb - 2, r.deep)
  fill(c:ellipse(x + 10, yb - 8, 4, 4), IR.base) px(x + 9, yb - 10, IR.hi) px(x + 12, yb - 6, IR.deep)
end
pack(346, 258, L.leaf)
pack(330, 262, L.roof)
-- quirk: a marmot climbing out of the green pack, sausage in its paws, dark-tipped tail over the rim
F.sprite({
  "..............",
  "..dd......dd..",
  ".dhhBBBBBBBBd.",
  "dhhBBBBBBBBBBd",
  "dhBeBBBBBBeBBd",
  "dhBBBBmmBBBBbd",
  "dBBBBmmmmBBBbd",
  ".dBBmmmnnmmBd.",
  ".dBBmmmmmmBBd.",
  "..dBBmttmBBd..",
  "..dbBBBBBBbd..",
  ".dbhBBBBBBbbd.",
  "dbhBBBBBBBBbbd",
  "dbBBBBBBBBBBbd",
  "dbBBBBBBBBBBbd",
  "dbbBBBBBBBBbbd",
}, 338, 222, { d = L.chamois.deep, B = L.chamois.base, h = L.chamois.hi, b = L.chamois.shade, e = L.timber.edge, m = L.goat.base,
  n = L.timber.edge, t = L.goat.hi })
px(341, 225, L.edel.hi) px(348, 225, L.edel.hi) -- eye glints
-- the sausage, held across the chest at a slant, a bite out of its upper end, string ties
do
  local sm = line({ { 333, 237 }, { 349, 230 } }, 3)
  sm:cut(c:ellipse(350, 229, 2, 2))
  rimOf(sm, L.redbark) part(sm, L.redbark, { nopop = true })
  line({ { 334, 235 }, { 347, 229 } }):each(function(x, y) if sm:has(x, y) and x % 3 ~= 0 then px(x, y, L.redbark.hi) end end)
  px(332, 238, L.board.deep) px(331, 239, L.board.deep)
  px(348, 231, L.produce.hi) px(347, 232, L.produce.base) -- the bite
  for _, pw in ipairs({ { 338, 233 }, { 344, 230 } }) do fill(rect(pw[1], pw[2], pw[1] + 2, pw[2] + 1), L.chamois.shade) px(pw[1], pw[2], L.chamois.base) hline(pw[1], pw[1] + 2, pw[2] + 2, L.chamois.deep) end
end
F.sprite({ "hB", "BB", "Bb", "bb", "dd", "dd" }, 355, 238, { h = L.chamois.hi, B = L.chamois.base, b = L.chamois.shade, d = L.timber.deep })
F.juniper(366, 262, 8, 5, 10) F.edelweiss(320, 266, true) F.gentian(296, 258, true) F.edelweiss(292, 252, true)
F.depth(0)
F.birds({ { 330, 40, 2 }, { 344, 48, 1 }, { 120, 56, 2 }, { 140, 62, 1 } })
F.depth(3)

---------------------------------------------------------------- near right: chopping stump, young spruce, a boulder
F.depth(2)
F.tree(456, 206, 56, 1)
F.depth(3)
F.conifer(436, 228, 24, L.foliage2, 44)
local cs = stump(416, 224, 8, .25, 24)
local haft = line({ { 417, 213 }, { 426, 203 } }, 1) c:rim(haft, L.timber.edge) haft:each(function(x, y) px(x, y, L.board.base) end) px(426, 203, L.board.hi)
local axe = poly{ { 410, 210 }, { 417, 211 }, { 417, 216 }, { 411, 217 } } c:rim(axe, IR.edge) fill(axe, IR.base) vline(410, 210, 217, IR.hi) px(411, 210, IR.hi) px(416, 216, IR.deep) vline(417, 211, 216, IR.shade)
for _, s in ipairs({ { 404, 224 }, { 432, 226 } }) do
  local m = poly{ { s[1], s[2] }, { s[1] + 5, s[2] - 2 }, { s[1] + 6, s[2] }, { s[1] + 1, s[2] + 2 } }
  rimOf(m, L.timber) fill(m, L.board.base) px(s[1] + 1, s[2], L.board.hi) px(s[1] + 5, s[2] - 1, L.timber.base)
end
F.boulder(466, 226, 8, 7, 41)
F.edelweiss(456, 222, true) F.gentian(450, 224, true)

---------------------------------------------------------------- by the road: lantern pole, sign
local lp = rect(286, 176, 287, 212) rimOf(lp, L.timber) part(lp, L.timber, { nopop = true, noshade = true })
F.lichen(rect(286, 204, 287, 212), .5, 25)
fill(rect(281, 176, 287, 177), L.timber.base) vline(281, 178, 180, L.timber.edge)
local lan = rect(278, 181, 284, 188) rimOf(lan, L.timber) fill(lan, G.base) px(279, 182, G.hi) vline(284, 182, 188, G.shade) hline(278, 284, 181, L.timber.base)
pebble(284, 212) pebble(289, 213)
F.sign(212, 196, 20, 12, L.board)
fill(poly{ { 206, 205 }, { 212, 198 }, { 218, 205 } }, L.awnA.base) fill(poly{ { 211, 205 }, { 212, 202 }, { 213, 205 } }, L.timber.deep) px(210, 200, L.awnA.hi)
F.gentian(204, 214, true) F.edelweiss(220, 212, true)
F.finish()
