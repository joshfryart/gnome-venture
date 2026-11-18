-- camp.lua : "Camp" stop look, ISLAND (island_palm), 480x270 gate view.
-- Same composition and story as the Maplewold camp (art-2701-batch3/stops/opus3/camp.lua), re-cast as a beach camp:
-- road's end: a two-peak palm-thatch fale (open-sided mess hut) on a lava footing, glowing inside, cook smoke behind.
-- Back left: a little A-frame frond hut; an outrigger canoe pulled up on the sand; a washing line strung between two
-- coconut palms with a sarong, socks and an aloha shirt, a gnome pegging. Right: the big palm-frond lean-to on bamboo
-- posts, a woven-mat back wall lit by a hanging lantern, a striped hammock slung inside, a net with floats, bananas.
-- Back right: a second outrigger canoe on driftwood chocks with paddles stuck in the sand. Left: driftwood and husks
-- stacked between bamboo stakes, a hermit crab. Hero: the fire pit in a ring of black lava rocks, fish roasting on
-- skewers stuck in the sand round it, a bamboo tripod with a fish-stew pot (a tail sticking out), driftwood and
-- palm-log seats, a ukulele player, a gnome toasting a fish, a gnome with a coconut drink, a piglet asleep.
-- Near right: a hammock between two palms with a gnome napping. Bottom left: a bamboo table with a banana-leaf fish
-- platter, papaya, coconut. Quirk: a little monkey in a red gnome hat climbing out of a woven pack with a grilled fish.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-island-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "camp", out = DIR, farTrees = { 24, 52, 150, 330, 352, 440 }, treeLineGap = { 190, 290 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local G, IR = L.glow, L.iron

-- local helpers ------------------------------------------------------------------------
-- a fish lying along a stick: (x, y) = head, dir = 1 faces right; r = body ramp; cooked browns the top
local function fish(x, y, dir, r, cooked, big)
  r = r or L.iron
  local s = dir or 1
  local rows = big and { "..bbbb....", ".BBBBBBb.t", "hBBBBBBBtt", ".sBBBBBs.t", "..ssss...." } or { ".bbbb.t", "hBBBBBtt", ".ssss.t" }
  local oy = big and 3 or 2
  local m = HP.mask()
  for j, row in ipairs(rows) do for i = 1, #row do if row:sub(i, i) ~= "." then m:set(x + (i - 1) * -s, y + j - oy) end end end
  c:rim(m, L.timber.edge)
  for j, row in ipairs(rows) do for i = 1, #row do
    local ch = row:sub(i, i)
    local col = ({ b = cooked and L.produce.hi or r.hi, B = r.base, s = cooked and L.shell.base or r.shade, t = r.deep, h = r.base })[ch]
    if col then px(x + (i - 1) * -s, y + j - oy, col) end
  end end
  px(x - s, y - 1, L.timber.edge) -- eye
  if cooked then
    px(x - 3 * s, y - 1, L.produce.shade) px(x - 5 * s, y - 1, L.produce.shade) px(x - 4 * s, y, L.produce.hi)
    if big then px(x - 3 * s, y + 1, L.produce.shade) px(x - 5 * s, y + 1, L.produce.shade) px(x - 2 * s, y - 2, L.produce.hi) end
  end
  return m
end
-- a hammock: fabric between xa..xb (ends at ya / yb2) sagging by sag, ropes fanning back to the anchor points
local function hammock(ax, ay, bx, by, sag, cols, o)
  o = o or {}
  local xa, xb = ax + (o.inset or 8), bx - (o.inset or 8)
  local function topY(x) local t = (x - ax) / (bx - ax) return ay + (by - ay) * t + sag * 4 * t * (1 - t) end
  local m, own = HP.mask(), {}
  for x = xa, xb do
    local t = (x - xa) / (xb - xa)
    local ty = floor(topY(x) + .5)
    local th = 1 + floor(5 * sin(pi * t) + .5)
    for y = ty, ty + th do m:set(x, y) own[y * 480 + x] = { t, y - ty, th } end
  end
  local ropes = HP.mask()
  for k = 0, 2 do
    ropes:add(line({ { ax, ay }, { xa, floor(topY(xa)) + k } }))
    ropes:add(line({ { bx, by }, { xb, floor(topY(xb)) + k } }))
  end
  c:rim(union(m, ropes), L.timber.edge)
  ropes:each(function(x, y) px(x, y, (x + y) % 2 == 0 and L.rope.base or L.rope.shade) end)
  m:each(function(x, y)
    local ow = own[y * 480 + x]
    local band = ((x - xa) // 5) % #cols + 1
    local r = cols[band]
    local h = r.base
    if ow[2] == 0 then h = r.hi elseif ow[2] >= ow[3] then h = r.deep elseif ow[2] > ow[3] * .55 then h = r.shade end
    if (x - xa) % 5 == 0 then h = r.shade end
    px(x, y, h)
  end)
  -- a fringe of tassels along the lower edge
  for x = xa + 2, xb - 2, 3 do
    local t = (x - xa) / (xb - xa)
    local ty = floor(topY(x) + .5) + 1 + floor(5 * sin(pi * t) + .5)
    px(x, ty + 1, L.rope.base) px(x, ty + 2, L.rope.shade)
  end
  return m, topY
end

-- a dugout outrigger canoe drawn up on the sand: (x0..x1) bow at x1, y = keel line. The hull rises to
-- upturned ends, the open top shows the dark inside, a painted stripe under the gunwale. o.side = -1 float behind
-- (drawn first), 1 float in front. o.hull = hull ramp, o.stripe = paint ramp.
local function canoe(x0, x1, y, o)
  o = o or {}
  local hr, sr = o.hull or L.timber, o.stripe or L.accent
  local len = x1 - x0
  local side = o.side or -1
  local fy = y - 2 + side * 6
  local float = c:rrect(x0 + 8, fy - 1, x1 - 8, fy + 1, 1)
  local booms = HP.mask()
  for _, bx in ipairs({ x0 + floor(len * .32), x0 + floor(len * .66) }) do booms:add(line({ { bx, y - 7 }, { bx + 2, fy } }, 1)) end
  local function rig()
    local m = union(float, booms)
    c:rim(m, L.timber.edge)
    part(float, L.timber, { nopop = true }) hline(x0 + 9, x1 - 9, fy - 1, L.timber.hi)
    booms:each(function(x, yy) px(x, yy, (x + yy) % 3 == 0 and L.board.deep or L.board.base) end)
  end
  if side < 0 then rig() end
  local hull, tops = HP.mask(), {}
  for x = x0, x1 do
    local t = (x - x0) / len
    local e = math.abs(t - .5) * 2
    local top = y - 7 - floor(4 * e ^ 4 + .5) - ((t > .9) and 1 or 0)
    local bot = y - floor(5 * e ^ 2.5 + .5)
    tops[x] = top
    for yy = top, math.max(top, bot) do hull:set(x, yy) end
  end
  F.shadow(x0 + 3, x1 - 3, y + 1, 6, 2)
  c:rim(hull, hr.edge)
  hull:each(function(x, yy)
    local k = yy - tops[x]
    local h = hr.base
    if k == 0 then h = hr.hi elseif k == 1 and x > x0 + 4 and x < x1 - 4 then h = L.timber.edge
    elseif k == 2 then h = sr.base elseif k == 3 then h = sr.shade elseif yy >= y - 1 then h = hr.deep elseif k > 4 then h = hr.shade end
    if k > 3 and hash(x // 3, yy, 41) < .1 then h = hr.hi end
    px(x, yy, h)
  end)
  -- carved bow and stern posts
  px(x1, tops[x1] - 1, hr.base) px(x1 + 1, tops[x1] - 2, hr.hi) px(x0, tops[x0] - 1, hr.base)
  hline(x0 + 5, x1 - 5, y - 6, hr.edge)
  if side > 0 then rig() end
end

---------------------------------------------------------------- beach-camp clearing: trampled darker sand around the fire
local clear = c:ellipse(150, 214, 92, 30)
clear:each(function(x, y) if not F.roadM:has(x, y) and x < F.xl(y) - 1 then
  local v = hash(x, y, 3)
  local d = ((x - 150) / 92) ^ 2 + ((y - 214) / 30) ^ 2
  if d < .78 then
    local b = hash(x // 4, y // 2, 4)
    local h = b < .5 and L.ground.base or (b < .82 and L.duff or L.ground.shade)
    if v < .05 then h = L.ground.hi elseif v > .96 then h = L.lava.base elseif v > .93 then h = L.ground.deep end
    px(x, y, h)
  elseif hash(x // 3, y // 2, 4) < .35 then px(x, y, L.duff) end
end end)
-- footprints in the sand toward the road
for k = 0, 6 do local x, y = 196 + k * 7, 222 + (k % 2) * 3 if not F.roadM:has(x, y) and x < F.xl(y) - 2 then px(x, y, L.ground.shade) px(x + 1, y, L.ground.shade) px(x, y + 1, L.ground.deep) end end

---------------------------------------------------------------- back palms (plane 1)
F.depth(1)
F.palm(10, 140, 46, L.foliage, 2, { lean = 10 })
F.tree(318, 138, 44, 2)
F.palm(384, 142, 58, L.foliage2, 6, { lean = -14 })
F.tree(446, 136, 44, 5)

---------------------------------------------------------------- road's end: the two-peak palm-thatch fale
F.depth(2)
F.tree(294, 128, 50, 0)
do
  local cx, yb = 240, 128
  local foot = rect(cx - 37, yb - 3, cx + 37, yb)
  local inner = rect(cx - 33, yb - 16, cx + 33, yb - 4)
  local roofm = poly{ { cx - 44, yb - 14 }, { cx - 16, yb - 46 }, { cx, yb - 32 }, { cx + 16, yb - 46 }, { cx + 44, yb - 14 } }
  local poles = rect(cx - 17, yb - 54, cx - 16, yb - 44):add(rect(cx + 16, yb - 54, cx + 17, yb - 44))
  local posts = HP.mask()
  for _, x in ipairs({ cx - 33, cx - 12, cx + 11, cx + 32 }) do posts:add(rect(x, yb - 16, x + 1, yb - 4)) end
  F.shadow(cx - 36, cx + 36, yb, 10, 3)
  F.smoke(cx + 30, yb - 30, 6, .7, 2) -- the cook fire behind the hut
  rimOf(union(foot, inner, roofm, poles), L.timber)
  -- shady interior: a woven back wall, a lamp, a table with gnome-sized stools, a hammock silhouette
  inner:each(function(x, y)
    local wv = ((x // 2 + y // 2) % 2 == 0)
    px(x, y, wv and L.rope.deep or L.rope.edge)
  end)
  fill(c:ellipse(cx, yb - 11, 7, 4):clip(inner), G.shade) fill(c:ellipse(cx, yb - 11, 4, 2), G.base) px(cx - 1, yb - 12, G.hi) px(cx, yb - 12, G.hi)
  fill(rect(cx - 9, yb - 7, cx + 9, yb - 6), L.board.shade) vline(cx - 8, yb - 5, yb - 4, L.board.deep) vline(cx + 8, yb - 5, yb - 4, L.board.deep)
  for x = cx - 26, cx - 16 do px(x, floor(yb - 12 + 3 * sin((x - cx + 26) / 10 * pi)), L.awnA.shade) end -- a hammock at the back
  for x = cx + 16, cx + 26 do px(x, floor(yb - 12 + 3 * sin((x - cx - 16) / 10 * pi)), L.accent.shade) end
  part(foot, L.lava, { nopop = true }) F.courses(foot, yb - 3, 3, 7, L.lava) hline(cx - 37, cx + 37, yb - 3, L.lava.hi)
  part(posts, L.board, { nopop = true, noshade = true })
  posts:each(function(x, y) if (y + x) % 4 == 0 then px(x, y, L.board.deep) end end)
  -- thatch: lit on the slopes facing the sun, shaded on the far slopes, combed courses
  roofm:each(function(x, y)
    local pk = x < cx and cx - 16 or cx + 16
    local h = L.roof.base
    if x < pk - 1 then h = ((pk - x) + (y - (yb - 46))) < 20 and L.roof.hi or L.roof.base
    elseif x > pk + 1 then h = L.roof.shade end
    if x > cx + 18 and h == L.roof.shade and (x - pk) / 28 + (y - (yb - 46)) / 32 > .9 then h = L.roof.deep end
    px(x, y, h)
  end)
  F.thatch(roofm, L.roof, yb - 46, cx + 16)
  hline(cx - 44, cx + 44, yb - 14, L.roof.deep)
  for x = cx - 44, cx + 44 do if hash(x, 3, 61) < .45 then px(x, yb - 13, L.roof.deep) end end -- ragged eave
  -- frond ridge caps on both peaks, a woven knot
  for _, pk in ipairs({ cx - 16, cx + 16 }) do
    F.frond(pk, yb - 45, 2.55, 11, .5, L.foliage, pk) F.frond(pk, yb - 45, .55, 11, .5, L.foliage2, pk + 1)
  end
  part(poles, L.board, { nopop = true, noshade = true })
  for _, p in ipairs({ { cx - 16, L.awnA }, { cx + 17, L.accent } }) do fill(poly{ { p[1] + 1, yb - 54 }, { p[1] + 10, yb - 52 }, { p[1] + 1, yb - 49 } }, p[2].base) px(p[1] + 2, yb - 53, p[2].hi) px(p[1] + 8, yb - 52, p[2].shade) end
  -- a string of glass floats under the eave
  for x = cx - 40, cx + 38, 7 do local fy = yb - 12 + ((x // 7) % 2) px(x, fy, L.accent.base) px(x + 1, fy, L.accent.shade) px(x, fy - 1, L.accent.hi) end
  for _, g in ipairs({ { cx - 44, cx - 52 }, { cx + 44, cx + 52 } }) do line({ { g[1], yb - 14 }, { g[2], yb + 1 } }):each(function(x, y) px(x, y, L.rope.deep) end) end
  -- coconut-shell lamps hung on the end posts, hibiscus at the steps
  F.hibiscus(cx - 46, yb + 1, 6, 6, 51) F.hibiscus(cx + 47, yb + 1, 5, 5, 52)
  F.parrot(cx + 15, yb - 64, "lory")
end

---------------------------------------------------------------- back left: a small A-frame frond hut
local function frondHut(x, yb, w, h)
  local front = poly{ { x - w, yb }, { x, yb - h }, { x + w, yb } }
  local side = poly{ { x, yb - h }, { x + w + 18, yb - h + 4 }, { x + w + 22, yb - 2 }, { x + w, yb } }
  local door = poly{ { x - w // 3, yb }, { x, yb - h * 2 // 3 }, { x + w // 3, yb } }
  F.shadow(x - w, x + w + 22, yb, 10, 3)
  rimOf(union(front, side), L.roof)
  part(side, L.roof, { noshade = true }) F.thatch(side, L.roof, yb - h, x)
  side:each(function(xx, y) if (xx - x) % 7 == 0 then px(xx, y, L.roof.deep) end end)
  part(front, L.board, { sep = true }) F.bamboo(front, L.board, 3)
  fill(door, L.rope.edge) fill(poly{ { x - 1, yb }, { x, yb - h * 2 // 3 }, { x + w // 3, yb } }, L.soil.deep)
  fill(poly{ { x, yb - h * 2 // 3 }, { x - w // 3 - 4, yb - 2 }, { x - w // 3, yb } }, L.awnA.base) -- a hibiscus-red curtain tied back
  px(x - w // 3 - 2, yb - 5, L.awnA.hi)
  F.frond(x, yb - h - 1, .25, 16, .35, L.foliage, 33, { noRim = true }) F.frond(x, yb - h - 1, 2.9, 10, .5, L.foliage2, 34, { noRim = true })
end
F.depth(1)
frondHut(36, 146, 14, 18)
F.depth(2)
-- the second outrigger canoe pulled up on the sand, a paddle across it
canoe(94, 146, 156, { side = 1, stripe = L.hibiscus, hull = L.coconut })
line({ { 104, 146 }, { 126, 148 } }):each(function(x, y) px(x, y, L.board.base) end) fill(rect(126, 147, 129, 149), L.wall2.base) px(126, 147, L.wall2.hi)
F.coconut(150, 156, 2) F.coconut(155, 157, 2, true)
F.depth(1)

---------------------------------------------------------------- washing line between two coconut palms
F.palm(86, 140, 46, L.foliage, 4, { lean = 3 })
F.depth(2)
F.palm(184, 140, 44, L.foliage2, 7, { lean = -3 })
local function sagY(x) local t = (x - 88) / (182 - 88) return floor(108 + 8 * sin(t * pi)) end
for x = 88, 182 do px(x, sagY(x), L.rope.deep) end
for _, k in ipairs({ { 87, 107 }, { 183, 107 } }) do fill(rect(k[1] - 1, k[2], k[1] + 1, k[2] + 2), L.rope.base) px(k[1] - 1, k[2], L.rope.hi) end
for i, it in ipairs({ { 98, L.awnA, "sock" }, { 112, L.wall2, "shirt" }, { 132, L.gold, "sock" }, { 146, L.hibiscus, "sarong" }, { 166, L.lav, "sock" } }) do
  local x = it[1] local y = sagY(x) + 1 local r = it[2]
  local m
  if it[3] == "sock" then m = rect(x, y, x + 3, y + 8):add(rect(x, y + 6, x + 6, y + 9))
  elseif it[3] == "sarong" then m = poly{ { x - 1, y }, { x + 11, y }, { x + 12, y + 14 }, { x - 2, y + 13 } }
  else m = rect(x - 2, y, x + 10, y + 3):add(rect(x + 1, y, x + 7, y + 13)) end
  rimOf(m, r) part(m, r, { nopop = true })
  hline(x, x + 3, y, r.hi) px(x + 1, y - 1, L.timber.base)
  if it[3] == "sock" then hline(x, x + 3, y + 2, L.awnB.hi) end
  if it[3] == "shirt" then for _, f in ipairs({ { x + 2, y + 5 }, { x + 6, y + 9 }, { x - 1, y + 1 } }) do px(f[1], f[2], L.awnB.hi) px(f[1] + 1, f[2], L.petal.base) end end
  if it[3] == "sarong" then F.flower(x + 4, y + 6, "plumeria", true) F.flower(x + 8, y + 10, "white", true) hline(x - 1, x + 12, y + 12, L.gold.base) end
end

---------------------------------------------------------------- back right: an outrigger canoe on driftwood chocks, paddles in the sand
F.depth(2)
for _, x in ipairs({ 418, 444 }) do local ch = rect(x, 153, x + 5, 157) rimOf(ch, L.timber) part(ch, L.timber, { nopop = true }) end
canoe(404, 462, 156, { side = -1, stripe = L.awnA })
for _, p in ipairs({ { 466, 156, L.wall2 }, { 472, 158, L.awnA } }) do
  local pm = line({ { p[1], p[2] - 26 }, { p[1] + 1, p[2] - 8 } }, 1):add(c:rrect(p[1] - 2, p[2] - 9, p[1] + 3, p[2], 2))
  rimOf(pm, L.timber) part(pm, L.board, { nopop = true, noshade = true }) fill(c:rrect(p[1] - 1, p[2] - 8, p[1] + 2, p[2] - 1, 1), p[3].base) px(p[1] - 1, p[2] - 8, p[3].hi)
end
F.lavaRock(386, 160, 6, 5, 71)
F.depth(3)

---------------------------------------------------------------- right hero: the big palm-frond lean-to
F.depth(3)
local function leanTo(cx, yb)
  local x0, x1 = cx - 48, cx + 52
  local eave = yb - 40
  local back = rect(cx - 42, yb - 60, cx + 46, yb - 7)
  local floorM = poly{ { cx - 44, yb - 7 }, { cx + 48, yb - 7 }, { cx + 52, yb }, { cx - 48, yb } }
  local roofm = poly{ { x0 - 6, eave + 2 }, { x1 + 8, eave + 2 }, { x1 - 2, yb - 70 }, { x0 + 4, yb - 68 } }
  local postL, postR = rect(x0 - 1, eave, x0 + 1, yb), rect(x1 - 1, eave, x1 + 1, yb)
  local backPosts = rect(cx - 42, yb - 60, cx - 41, yb - 7):add(rect(cx + 45, yb - 60, cx + 46, yb - 7))
  F.shadow(x0, x1 + 4, yb, 16, 5)
  rimOf(union(back, floorM, roofm, postL, postR), L.timber)
  -- the woven pandanus back wall, in the shade of the roof, warmed round the lantern
  local lx, ly = cx + 4, yb - 34
  back:each(function(x, y)
    local wv = ((x // 3 + y // 3) % 2 == 0)
    local d = math.sqrt((x - lx) ^ 2 + ((y - ly) * 1.3) ^ 2)
    local h
    if d < 9 then h = wv and L.rope.hi or L.rope.base
    elseif d < 17 then h = wv and L.rope.base or L.rope.shade
    elseif d < 26 then h = wv and L.rope.shade or L.rope.deep
    else h = wv and L.rope.deep or L.rope.edge end
    if (wv and x % 3 == 0) or (not wv and y % 3 == 0) then h = d < 17 and L.rope.shade or L.rope.edge end
    if y < yb - 50 then h = (y + x) % 3 == 0 and L.rope.edge or L.roof.edge end -- deep shadow under the roof
    px(x, y, h)
  end)
  part(backPosts, L.board, { nopop = true, noshade = true })
  -- the sand floor inside, a woven mat
  floorM:each(function(x, y) px(x, y, hash(x, y, 13) < .3 and L.shadow or L.ground.shade) end)
  local mat = poly{ { cx - 26, yb - 6 }, { cx + 20, yb - 6 }, { cx + 24, yb - 1 }, { cx - 30, yb - 1 } }
  mat:each(function(x, y) px(x, y, ((x + y) % 4 < 2) and L.awnA.shade or L.rope.shade) end)
  hline(cx - 26, cx + 20, yb - 6, L.rope.base)
  -- a fishing net with floats hung on the back wall (left), a bunch of bananas and a spare paddle (right)
  local netM = poly{ { cx - 38, yb - 48 }, { cx - 12, yb - 48 }, { cx - 16, yb - 22 }, { cx - 34, yb - 26 } }
  F.net(netM, L.rope, { floats = true })
  local bunch = c:rrect(cx + 30, yb - 30, cx + 38, yb - 18, 3)
  c:rim(bunch, L.leaf.edge) fill(bunch, L.leaf.base)
  bunch:each(function(x, y) if (y - yb) % 3 == 0 then px(x, y, L.leaf.shade) elseif x < cx + 33 then px(x, y, L.gold.hi) elseif x > cx + 36 then px(x, y, L.leaf.deep) end end)
  vline(cx + 34, yb - 38, yb - 31, L.rope.base)
  local pad = line({ { cx + 41, yb - 20 }, { cx + 40, yb - 40 } }, 1):add(c:rrect(cx + 38, yb - 22, cx + 43, yb - 8, 2))
  c:rim(pad, L.timber.edge) fill(pad, L.board.base) fill(c:rrect(cx + 39, yb - 21, cx + 42, yb - 9, 1), L.wall2.base) px(cx + 39, yb - 21, L.wall2.hi) vline(cx + 42, yb - 20, yb - 10, L.wall2.shade)
  -- a sea chest and a water gourd on the floor
  local chest = rect(cx - 40, yb - 14, cx - 28, yb - 6)
  rimOf(chest, L.timber) part(chest, L.wall2, { nopop = true }) hline(cx - 40, cx - 28, yb - 11, L.timber.deep) px(cx - 34, yb - 10, L.gold.hi) px(cx - 34, yb - 9, L.gold.base)
  local gourd = c:ellipse(cx + 26, yb - 9, 3, 3):add(rect(cx + 25, yb - 14, cx + 27, yb - 12))
  c:rim(gourd, L.timber.edge) part(gourd, L.gold, { nopop = true })
  -- the lantern hanging from the ridge
  vline(lx, yb - 60, ly - 5, L.rope.deep)
  local lan = rect(lx - 3, ly - 4, lx + 3, ly + 4)
  c:rim(lan, L.timber.edge) fill(lan, G.base) fill(rect(lx - 2, ly - 3, lx - 1, ly + 2), G.hi) vline(lx + 3, ly - 4, ly + 4, G.shade)
  hline(lx - 3, lx + 3, ly - 4, L.timber.base) hline(lx - 3, lx + 3, ly + 4, L.timber.base)
  -- the striped hammock slung between the front posts, a pillow and a book on it
  hammock(x0 + 1, eave + 6, x1 - 1, eave + 6, 18, { L.awnA, L.awnB, L.accent }, { inset = 10 })
  fill(c:rrect(x0 + 18, eave + 12, x0 + 26, eave + 16, 2), L.awnB.hi) px(x0 + 25, eave + 15, L.awnB.shade)
  fill(rect(cx + 6, eave + 20, cx + 11, eave + 21), L.wall2.base) px(cx + 6, eave + 20, L.wall2.hi) hline(cx + 7, cx + 11, eave + 22, L.awnB.hi)
  -- the front bamboo posts
  part(union(postL, postR), L.board, { nopop = true, noshade = true })
  union(postL, postR):each(function(x, y) if (y + floor(hash(x, 0, 14) * 7)) % 8 == 0 then px(x, y, L.board.deep) elseif x == x0 - 1 or x == x1 - 1 then px(x, y, L.board.hi) end end)
  -- the roof: a thatch slab under layers of whole palm fronds laid down the slope, green fresh ones and dried gold ones
  part(roofm, L.roof, { sep = true })
  F.thatch(roofm, L.roof, yb - 70, cx + 30)
  roofm:each(function(x, y) if (x - x0) / (x1 - x0) + (y - (yb - 70)) / 30 > 1.15 then if hash(x, y, 15) < .5 then px(x, y, L.roof.deep) end end end)
  -- light falls on the left of the slab, the far right in shade
  roofm:each(function(x, y) if (x - x0) / (x1 - x0) < .22 and hash(x, y, 15) < .5 then px(x, y, L.roof.hi) end end)
  -- whole palm fronds laid over the thatch, running down the slope (two fresh, one dried)
  for i, f in ipairs({ { x0 + 6, yb - 68, .42, 46, L.foliage }, { x0 + 40, yb - 69, .5, 42, L.foliage2 }, { x0 + 70, yb - 69, .38, 34, L.needle } }) do
    F.frond(f[1], f[2], f[3], f[4], .08, f[5], 160 + i, { wide = .28 })
  end
  -- a ragged fringe of frond tips hanging under the eave
  for x = x0 - 4, x1 + 6 do
    local n = floor(hash(x, 1, 17) * 5)
    if x % 2 == 0 then for k = 1, n do px(x, eave + 2 + k, k == n and L.roof.deep or (hash(x, k, 18) < .5 and L.roof.shade or L.needle.base)) end end
  end
  -- the bamboo eave beam, the ridge pole with lashings
  local beam = rect(x0 - 6, eave, x1 + 8, eave + 2)
  rimOf(beam, L.timber) part(beam, L.board, { nopop = true }) F.bamboo(beam, L.board, 3, { horizontal = true })
  for _, bx in ipairs({ x0, x1 }) do fill(rect(bx - 2, eave - 1, bx + 2, eave + 3), L.rope.base) px(bx - 2, eave - 1, L.rope.hi) px(bx + 2, eave + 3, L.rope.deep) end
  local ridge = rect(x0 + 2, yb - 71, x1 - 1, yb - 69)
  rimOf(ridge, L.timber) part(ridge, L.timber, { nopop = true }) hline(x0 + 2, x1 - 1, yb - 71, L.timber.hi)
  -- guy ropes to stakes in the sand
  for _, g in ipairs({ { x0 + 4, yb - 69, x0 - 16, yb + 2 }, { x1 - 2, yb - 69, x1 + 18, yb + 2 } }) do
    line({ { g[1], g[2] }, { g[3], g[4] } }):each(function(x, y) if not roofm:has(x, y) then px(x, y, L.rope.deep) end end)
    fill(rect(g[3] - 1, g[4] - 3, g[3], g[4] + 1), L.timber.base) px(g[3] - 1, g[4] - 3, L.timber.hi)
  end
  -- a little flag on the ridge
  vline(x1 - 4, yb - 80, yb - 72, L.timber.base)
  local fl = poly{ { x1 - 3, yb - 80 }, { x1 + 7, yb - 77 }, { x1 - 3, yb - 74 } } fill(fl, L.hibiscus.base) px(x1 - 2, yb - 79, L.hibiscus.hi) px(x1 + 4, yb - 77, L.hibiscus.shade)
end
leanTo(350, 196)
-- hibiscus and beach grass at the lean-to's feet, a conch
F.hibiscus(296, 200, 7, 8, 61) F.hibiscus(408, 199, 6, 7, 62, "orange")
F.shell(312, 202, "conch", true) F.shell(392, 204, "scallop", true)


---------------------------------------------------------------- left: driftwood and husks stacked between bamboo stakes
local function woodStack(x0, x1, yb)
  local stakes = rect(x0 - 2, yb - 22, x0, yb):add(rect(x1, yb - 22, x1 + 2, yb))
  local stack = rect(x0 + 1, yb - 18, x1 - 1, yb)
  F.shadow(x0, x1 + 2, yb, 8, 3)
  rimOf(union(stakes, stack), L.timber)
  part(stakes, L.board, { nopop = true, noshade = true })
  stakes:each(function(x, y) if y % 6 == 0 then px(x, y, L.board.deep) end end)
  fill(stack, L.timber.edge)
  for row = 0, 3 do for k = 0, (x1 - x0) // 6 do
    local x, y = x0 + 3 + k * 6 + (row % 2) * 3, yb - 3 - row * 5
    if x < x1 - 1 then
      if hash(k, row, 90) < .3 then F.coconut(x, y, 2) else F.logEnd(x, y, 2, L.timber) end
    end
  end end
  -- a lid of dried palm thatch, a frond tip hanging over
  local lid = rect(x0 - 3, yb - 24, x1 + 3, yb - 21)
  rimOf(lid, L.roof) part(lid, L.roof, { nopop = true }) F.thatch(lid, L.roof, yb - 24, x1)
  F.frond(x1 + 2, yb - 23, .3, 12, .9, L.needle, 92, { noRim = true })
end
woodStack(22, 72, 196)
-- a hermit crab in a conch shell, trundling to the woodpile
F.sprite({
  "...sSSs.",
  "..sSppSs",
  ".sSSSpSS",
  "cCsSSSSd",
  "cCCddddd",
  ".l.l.l..",
}, 76, 190, { s = L.shell.hi, S = L.shell.base, p = L.petal.base, d = L.shell.shade, c = L.awnA.base, C = L.awnA.shade, l = L.awnA.deep })
px(76, 192, L.timber.edge)
F.banana(10, 214, 34, 9)
F.flower(28, 208, "hibiscus", true) F.flower(86, 206, "plumeria", true)
-- a gnome pegging a sock on the washing line
F.gnome(140, 134, { small = true, hat = L.produce, coat = L.leaf, arm = "up" })

---------------------------------------------------------------- the fire pit (hero): lava-rock ring, roasting fish, tripod stew pot, seats
local function campfire(cx, cy)
  local function seat(x0, x1, y, palmLog)
    local bark = palmLog and L.palmTrunk or L.timber
    local m = c:rrect(x0, y - 4, x1, y + 4, 4)
    F.shadow(x0, x1, y + 6, 4, 2)
    rimOf(m, bark) part(m, bark, { nopop = true })
    if palmLog then
      m:each(function(x, yy) if (x - x0) % 3 == 0 then px(x, yy, bark.shade) end if yy <= y - 2 and (x - x0) % 3 ~= 0 then px(x, yy, bark.hi) end end)
    else
      F.logs(m, bark, y - 4, 9)
      m:each(function(x, yy) if (x * 3 + yy) % 13 == 0 then px(x, yy, bark.deep) end end)
      m:each(function(x, yy) if yy <= y - 2 and hash(x // 2, yy, x0) < .14 then px(x, yy, bark.hi) end end)
      -- silver driftwood: worm grooves
      for k = 0, 2 do local gx = x0 + 5 + floor(hash(k, x0, 17) * (x1 - x0 - 10)) hline(gx, gx + 3, y + (k % 2), bark.deep) end
    end
    hline(x0 + 4, x1 - 4, y - 3, bark.hi)
    F.logEnd(x1 - 3, y, 4, bark)
  end
  seat(cx - 34, cx + 38, cy - 24)
  local pit = c:ellipse(cx, cy, 17, 5)
  fill(pit, L.soil.deep)
  pit:each(function(x, y) if hash(x, y, 8) < .3 then px(x, y, L.lava.shade) end end) -- ash and charcoal
  -- the ring of black lava rocks, a few bleached coral lumps
  for k = 0, 13 do
    local a = k / 14 * 2 * pi
    local x, y = floor(cx + cos(a) * 21), floor(cy + sin(a) * 7)
    local st = c:rrect(x - 4, y - 3, x + 3, y + 2, 2)
    local r = (k % 5 == 2) and L.stone or L.lava
    rimOf(st, r) part(st, r, { nopop = k % 3 ~= 0 })
    st:each(function(xx, yy) if hash(xx, yy, 18 + k) < .14 then px(xx, yy, r.deep) end end)
    px(x - 2, y - 2, r.hi)
  end
  local logs = line({ { cx - 12, cy + 2 }, { cx + 10, cy - 4 } }, 3):add(line({ { cx - 10, cy - 4 }, { cx + 12, cy + 2 } }, 3))
  rimOf(logs, L.timber) part(logs, L.timber, { nopop = true })
  logs:each(function(x, y) if hash(x, y, 93) < .25 then px(x, y, G.deep) end end)
  pit:each(function(x, y) if hash(x, y, 9) < .25 and not logs:has(x, y) then px(x, y, G.deep) end end)
  -- coconut husks smouldering at the edge
  for _, h in ipairs({ { cx - 13, cy + 1 }, { cx + 13, cy - 1 } }) do fill(c:ellipse(h[1], h[2], 2, 2), L.coconut.shade) px(h[1] - 1, h[2] - 1, G.shade) px(h[1] + 1, h[2], G.deep) end
  -- fish roasting on skewers stuck in the sand, leaning over the flames (the back pair first)
  local function skewer(sx, sy, ex, ey, dir, r)
    local st = line({ { sx, sy }, { ex, ey } }, 1)
    c:rim(st, L.timber.edge) st:each(function(x, y) px(x, y, L.board.shade) end)
    px(sx, sy, L.board.deep) px(ex, ey, L.board.hi)
    fish(floor((sx + ex * 3) / 4) + dir * 4, floor((sy + ey * 3) / 4), dir, r, true, true)
  end
  skewer(cx - 30, cy - 4, cx - 17, cy - 24, 1, L.gold)
  skewer(cx + 30, cy - 5, cx + 18, cy - 25, -1, L.hibiscus)
  local fl = poly{ { cx - 12, cy }, { cx - 9, cy - 16 }, { cx - 5, cy - 9 }, { cx - 2, cy - 28 }, { cx + 2, cy - 12 }, { cx + 6, cy - 22 }, { cx + 9, cy - 8 }, { cx + 12, cy } }
  fill(fl, G.deep)
  fill(fl:shrink(1), G.shade)
  fill(poly{ { cx - 8, cy }, { cx - 3, cy - 20 }, { cx + 1, cy - 9 }, { cx + 5, cy - 15 }, { cx + 8, cy } }, G.base)
  fill(poly{ { cx - 4, cy }, { cx - 1, cy - 12 }, { cx + 3, cy } }, G.hi)
  for i = 0, 14 do px(cx - 14 + floor(hash(i, 1, 31) * 30), cy - 32 - floor(hash(i, 2, 31) * 24), i % 3 == 0 and G.base or G.hi) end
  -- bamboo tripod, lashed with rope, the stew pot with a fish tail poking out
  local tri = line({ { cx - 18, cy + 4 }, { cx, cy - 40 } }, 2):add(line({ { cx + 18, cy + 4 }, { cx, cy - 40 } }, 2)):add(line({ { cx + 4, cy - 2 }, { cx, cy - 40 } }, 1))
  rimOf(tri, L.timber) part(tri, L.board, { nopop = true, noshade = true })
  tri:each(function(x, y) if y % 5 == 0 then px(x, y, L.board.deep) end end)
  fill(rect(cx - 2, cy - 39, cx + 2, cy - 37), L.rope.base) px(cx - 2, cy - 39, L.rope.hi)
  vline(cx, cy - 36, cy - 30, IR.deep)
  local pot = c:ellipse(cx, cy - 25, 7, 5):add(rect(cx - 7, cy - 28, cx + 7, cy - 26))
  rimOf(pot, IR) part(pot, IR) hline(cx - 7, cx + 7, cy - 28, IR.hi) fill(rect(cx - 5, cy - 29, cx + 5, cy - 29), L.gold.hi)
  px(cx - 3, cy - 29, L.leaf.base) px(cx + 2, cy - 29, L.produce.base) px(cx - 1, cy - 29, L.shell.hi)
  fill(c:ellipse(cx, cy - 29, 7, 3):cut(c:ellipse(cx, cy - 29, 6, 2)):clip(rect(cx - 8, cy - 33, cx + 8, cy - 29)), IR.deep)
  F.sprite({ "t.t", ".t.", ".b." }, cx + 3, cy - 33, { t = L.iron.base, b = L.iron.shade })
  F.smoke(cx + 1, cy - 38, 8, .5, 2)
  -- warm firelight on the sand
  local glowM = c:ellipse(cx, cy + 4, 42, 14):cut(c:ellipse(cx, cy, 25, 10))
  glowM:each(function(x, y) if hash(x, y, 33) < .3 and not F.roadM:has(x, y) then px(x, y, hash(x, y, 34) < .5 and L.gold.hi or L.glow.hi) end end)
  -- the front pair of fish skewers
  skewer(cx - 28, cy + 10, cx - 18, cy - 8, 1, L.coral)
  skewer(cx + 28, cy + 9, cx + 19, cy - 8, -1, L.gold)
  seat(cx - 46, cx - 22, cy + 4, true)
  seat(cx + 24, cx + 50, cy + 2)
  seat(cx - 16, cx + 18, cy + 20)
end
campfire(132, 214)
-- the ukulele player on the back seat
local _, lx, ly = F.gnome(104, 191, { hat = L.leaf, coat = L.hibiscus, arm = "hold", noShadow = true })
local uke = c:ellipse(lx + 2, ly, 3, 2):add(c:ellipse(lx + 5, ly - 1, 2, 2)):add(line({ { lx + 6, ly - 2 }, { lx + 12, ly - 6 } }, 1))
rimOf(uke, L.timber) part(uke, L.board, { nopop = true }) fill(c:ellipse(lx + 3, ly, 1, 1), L.timber.edge) px(lx + 12, ly - 7, L.timber.base) px(lx + 13, ly - 7, L.timber.base)
for _, n in ipairs({ { lx + 8, ly - 14 }, { lx + 13, ly - 18 } }) do vline(n[1] + 1, n[2] - 3, n[2], L.timber.edge) fill(rect(n[1], n[2], n[1] + 1, n[2] + 1), L.timber.edge) end
F.flower(lx - 6, ly - 22, "hibiscus", true) -- a flower tucked in the hat brim
-- the toasting gnome holds a fish on a long stick over the flames
local _, mx, my = F.gnome(96, 210, { hat = L.awnA, coat = L.wall2, arm = "out" })
fill(line({ { mx, my }, { mx + 14, my - 9 } }), L.board.base)
fish(mx + 19, my - 10, 1, L.coral, true)
-- the gnome with a coconut drink, straw and a little umbrella
local _, ux, uy = F.gnome(174, 208, { hat = L.gold, coat = L.lav, arm = "out", flip = true })
F.coconut(ux - 2, uy - 2, 3)
fill(rect(ux - 3, uy - 4, ux - 1, uy - 4), L.shell.hi) vline(ux - 1, uy - 9, uy - 4, L.awnA.base) px(ux, uy - 9, L.awnA.base)
fill(poly{ { ux - 7, uy - 8 }, { ux - 4, uy - 11 }, { ux - 1, uy - 8 } }, L.accent.base) px(ux - 4, uy - 10, L.accent.hi) vline(ux - 4, uy - 7, uy - 5, L.timber.base)
-- a piglet asleep by the fire, snout on its trotters
F.sprite({
  "..ee............",
  ".ePPe...PPPPP...",
  "PPePPPPPPPPPPPP.",
  "nnPPPPPPPPpPPPPt",
  "nNpPPPPPPPPPPPP.",
  ".ppdddddddddddt.",
}, 154, 228, { e = L.petal.shade, P = L.pinkwash.base, p = L.pinkwash.shade, d = L.pinkwash.deep, n = L.petal.base, N = L.petal.shade, t = L.petal.shade })
hline(157, 158, 230, L.timber.edge) px(154, 231, L.petal.deep) px(155, 232, L.petal.deep)
px(170, 229, L.petal.deep) px(171, 228, L.petal.shade) -- curly tail
-- shells and a fallen plumeria by the ring
F.shell(112, 232, "cowrie") F.shell(184, 236, "scallop", true) F.flower(80, 224, "plumeria", true) F.shell(64, 222, "conch", true)

---------------------------------------------------------------- camp kitchen: a bamboo table, bottom-left
local top = rect(24, 236, 76, 239)
local tbl = union(top, rect(27, 240, 30, 252), rect(70, 240, 73, 252))
F.shadow(26, 76, 252, 8, 3)
rimOf(tbl, L.timber) part(tbl, L.board, { nopop = true })
F.bamboo(top, L.board, 2, { horizontal = true })
F.bamboo(rect(27, 240, 30, 252), L.board, 2) F.bamboo(rect(70, 240, 73, 252), L.board, 2)
-- a banana leaf platter with two grilled fish
local bl = poly{ { 40, 235 }, { 66, 233 }, { 70, 235 }, { 62, 237 }, { 40, 237 } }
c:rim(bl, L.leaf.edge) fill(bl, L.leaf.base) hline(41, 66, 235, L.leaf.hi) bl:each(function(x, y) if y == 236 and x % 3 == 0 then px(x, y, L.leaf.shade) end end)
fish(48, 233, -1, L.iron, true) fish(64, 232, -1, L.coral, true)
-- a kettle, a split papaya, a coconut with a straw
local ket = c:ellipse(32, 231, 5, 4):add(rect(37, 228, 40, 229)) rimOf(ket, L.accent) part(ket, L.accent) fill(rect(30, 226, 34, 227), L.accent.shade)
local pap = c:ellipse(74, 233, 4, 3) rimOf(pap, L.produce) fill(pap, L.produce.base) fill(c:ellipse(74, 233, 2, 1), L.produce.hi)
px(73, 233, L.timber.edge) px(75, 233, L.timber.edge) px(74, 232, L.timber.edge) hline(71, 77, 236, L.leaf.shade)
F.coconut(70, 230, 2, true) vline(71, 225, 228, L.awnA.base)
-- under the table: a woven basket of coconuts and a fishing rod
local bask = c:rrect(38, 244, 52, 252, 2)
rimOf(bask, L.rope) part(bask, L.rope, { nopop = true })
bask:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.rope.shade) elseif (x - y) % 4 == 0 then px(x, y, L.rope.hi) end end)
F.coconut(42, 243, 2) F.coconut(47, 242, 2, true)
line({ { 80, 254 }, { 96, 226 } }):each(function(x, y) px(x, y, L.board.shade) end) px(96, 225, L.board.hi)
F.fern(18, 254, 7, L.seagrass) F.fern(86, 256, 6)

---------------------------------------------------------------- rolled mats, woven packs and the monkey (right of the road)
local function rolledMat(x, y, r)
  local m = c:rrect(x - 14, y - 5, x + 14, y + 5, 5)
  rimOf(m, L.rope) part(m, L.rope)
  m:each(function(xx, yy) if ((xx // 2 + yy // 2) % 2 == 0) then px(xx, yy, yy < y - 1 and L.rope.hi or L.rope.base) end end)
  for k = -8, 8, 8 do vline(x + k, y - 5, y + 5, r.base) vline(x + k + 1, y - 5, y + 5, r.shade) end
  local e = c:ellipse(x + 12, y, 3, 5) fill(e, L.rope.hi) c:ellipse(x + 12, y, 1, 3):edge():each(function(xx, yy) px(xx, yy, L.rope.shade) end) px(x + 12, y, L.rope.deep)
end
rolledMat(300, 230, L.awnA) rolledMat(312, 240, L.accent)
local function pack(x, yb, r)
  local m = c:rrect(x - 8, yb - 18, x + 8, yb, 4)
  local flap = c:rrect(x - 8, yb - 20, x + 8, yb - 12, 3)
  F.shadow(x - 6, x + 8, yb, 6, 2)
  rimOf(union(m, flap), L.rope) part(m, L.rope) part(flap, L.rope, { sep = true })
  m:each(function(xx, yy) if not flap:has(xx, yy) and ((xx // 2 + yy // 2) % 2 == 0) then px(xx, yy, L.rope.shade) end end)
  hline(x - 8, x + 8, yb - 6, r.base) hline(x - 8, x + 8, yb - 5, r.shade)
  fill(rect(x - 1, yb - 13, x + 1, yb - 11), L.shell.hi) px(x - 1, yb - 13, L.shell.base)
  vline(x - 5, yb - 11, yb - 2, L.rope.deep) vline(x + 5, yb - 11, yb - 2, L.rope.deep)
  F.coconut(x + 10, yb - 5, 3) -- a coconut cup
end
pack(346, 258, L.accent)
pack(330, 262, L.awnA)
-- quirk: a little monkey in a red gnome hat climbing out of the turquoise pack, a grilled fish on a stick in its paw
F.sprite({
  "........R.......",
  ".......RRr......",
  "......RRRr......",
  ".....RRRRRr.....",
  "....RRRRRRr.....",
  "...hhhhhhhhh....",
  ".bbBFFFFFFFBbb..",
  "bbFbFeFFFeFbFbb.",
  ".bbFFFFFFFFFbb..",
  "..bFFFnnFFFFb...",
  "...bFFmmmFFb....",
  "..AbbbbbbbbbA...",
  ".AAbbbbbbbbbAA..",
  "WwWwWwWwWwWwWwW.",
}, 338, 224, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, b = L.coconut.base, B = L.coconut.shade,
  F = L.skin.hi, e = L.timber.edge, n = L.skin.shade, m = L.skin.deep, A = L.skin.base, W = L.rope.hi, w = L.rope.base })
px(344, 231, L.skin.base) px(348, 231, L.skin.base)
px(346, 224, L.awnB.hi) px(345, 225, L.awnB.hi) -- a cream pompom on the hat tip
-- the curled tail over the pack's rim
for _, p in ipairs({ { 353, 238 }, { 354, 239 }, { 355, 240 }, { 355, 241 }, { 356, 242 }, { 357, 241 }, { 357, 240 } }) do px(p[1], p[2], L.coconut.shade) end
-- the fish on a stick held aloft
line({ { 339, 236 }, { 333, 222 } }):each(function(x, y) px(x, y, L.board.shade) end)
fish(332, 219, 1, L.iron, true)
F.fern(364, 262, 7, L.seagrass) F.fern(294, 258, 5)
F.shell(318, 258, "scallop", true) F.crab(370, 252, L.awnA, true)

---------------------------------------------------------------- near right: a hammock between two palms, a gnome napping in it
F.depth(2)
F.palm(468, 222, 62, L.foliage2, 11, { lean = -6, dead = true })
F.depth(3)
do
  local ax, ay, bx, by = 403, 180, 466, 182
  -- the napper: a belly mound, a face with closed eyes, a beard spilling over, boots up, the hat flopped over the edge
  local mid = 438
  local belly = c:ellipse(mid + 2, 192, 9, 4)
  rimOf(belly, L.accent) part(belly, L.accent) hline(mid - 5, mid + 9, 193, L.timber.deep) px(mid + 2, 193, L.gold.hi)
  local face = rect(mid - 14, 186, mid - 8, 191)
  rimOf(face, L.skin) part(face, L.skin, { nopop = true, noshade = true })
  hline(mid - 13, mid - 12, 188, L.timber.edge) hline(mid - 10, mid - 9, 188, L.timber.edge)
  px(mid - 11, 189, L.skin.shade) px(mid - 13, 190, "#ec8c84")
  local beard = poly{ { mid - 14, 191 }, { mid - 7, 191 }, { mid - 9, 196 }, { mid - 12, 197 } }
  c:rim(beard, L.timber.edge) part(beard, L.awnB, { nopop = true })
  local hat = poly{ { mid - 15, 185 }, { mid - 9, 184 }, { mid - 18, 190 }, { mid - 22, 197 }, { mid - 20, 189 } }
  c:rim(hat, L.timber.edge) part(hat, L.awnA, { nopop = true }) px(mid - 16, 186, L.awnA.hi)
  for _, bxx in ipairs({ mid + 14, mid + 18 }) do local bt = rect(bxx, 185, bxx + 2, 189) c:rim(bt, L.timber.edge) part(bt, L.timber, { nopop = true, noshade = true }) px(bxx, 185, L.timber.hi) end
  -- zzz
  for k, z in ipairs({ { mid - 6, 177 }, { mid - 2, 171 }, { mid + 3, 164 } }) do
    local s = k == 3 and 3 or 2
    hline(z[1], z[1] + s, z[2], L.awnB.hi) line({ { z[1] + s, z[2] }, { z[1], z[2] + s } }):each(function(x, y) px(x, y, L.awnB.hi) end) hline(z[1], z[1] + s, z[2] + s, L.awnB.hi)
  end
  hammock(ax, ay, bx, by, 16, { L.hibiscus, L.awnB, L.wall2 }, { inset = 6 })
  -- rope wraps on the trunks
  for _, k in ipairs({ { ax, ay }, { bx, by } }) do fill(rect(k[1] - 2, k[2] - 1, k[1] + 2, k[2] + 1), L.rope.base) px(k[1] - 2, k[2] - 1, L.rope.hi) px(k[1] + 2, k[2] + 1, L.rope.deep) end
end
-- a bamboo A-frame rack of fish drying in the sun
do
  local x0, x1, yb = 418, 448, 229
  local legs = line({ { x0, yb }, { x0 + 4, yb - 17 } }, 1):add(line({ { x0 + 8, yb }, { x0 + 4, yb - 17 } }, 1))
    :add(line({ { x1 - 8, yb }, { x1 - 4, yb - 17 } }, 1)):add(line({ { x1, yb }, { x1 - 4, yb - 17 } }, 1))
  local bar = rect(x0 + 2, yb - 17, x1 - 2, yb - 16)
  F.shadow(x0, x1, yb + 1, 6, 2)
  rimOf(union(legs, bar), L.timber) part(union(legs, bar), L.board, { nopop = true, noshade = true }) hline(x0 + 2, x1 - 2, yb - 17, L.board.hi)
  for k, fx in ipairs({ x0 + 9, x0 + 15, x0 + 21 }) do
    vline(fx, yb - 15, yb - 14, L.rope.deep)
    local fm = HP.mask()
    for j = 0, 8 do local w = (j < 2 or j > 6) and 0 or 1 for i = -w, w do fm:set(fx + i, yb - 13 + j) end end
    fm:set(fx - 1, yb - 4) fm:set(fx + 1, yb - 4)
    local r = k == 2 and L.coral or L.iron
    c:rim(fm, L.timber.edge) fm:each(function(x, y) px(x, y, x < fx and r.hi or (x > fx and r.shade or r.base)) end)
    px(fx, yb - 11, L.timber.edge)
  end
end
F.hibiscus(456, 222, 8, 9, 63)
F.coconut(410, 226, 2) F.coconut(404, 228, 2, true) F.flower(448, 226, "orange", true)

---------------------------------------------------------------- fallen fronds and coconuts on the sand
F.frond(64, 262, -.15, 28, .1, L.needle, 301, { wide = .25 })
F.frond(250 + 130, 214, 2.9, 20, .15, L.needle, 302, { wide = .25 })
F.coconut(206, 248, 3) F.coconut(178, 258, 2, true)
F.shell(160, 262, "conch", true) F.shell(270, 246, "scallop")
F.depth(0)
F.birds({ { 330, 40, 2 }, { 344, 48, 1 }, { 150, 30, 2 }, { 300, 70, 1 } })
F.depth(3)

---------------------------------------------------------------- by the road: a bamboo lantern pole, the sign
local lp = rect(286, 176, 287, 212) rimOf(lp, L.timber) part(lp, L.board, { nopop = true, noshade = true })
for y = 178, 212, 6 do hline(286, 287, y, L.board.deep) end
fill(rect(281, 176, 287, 177), L.board.base) vline(281, 178, 180, L.rope.deep)
local lan = rect(278, 181, 284, 188) rimOf(lan, L.timber) fill(lan, G.base) px(279, 182, G.hi) vline(284, 182, 188, G.shade) hline(278, 284, 181, L.timber.base) hline(278, 284, 188, L.timber.base)
F.sign(212, 196, 20, 12, L.board)
-- pictogram: a lean-to with a palm
line({ { 205, 201 }, { 216, 198 } }):each(function(x, y) px(x, y, L.awnA.base) end) vline(206, 202, 205, L.timber.deep) vline(215, 199, 205, L.timber.deep)
px(218, 199, L.foliage.base) px(217, 198, L.foliage.base) px(219, 198, L.foliage.base) vline(218, 200, 205, L.coconut.base)
F.fern(204, 214, 4, L.seagrass) F.flower(222, 212, "hibiscus", true)
F.finish()
