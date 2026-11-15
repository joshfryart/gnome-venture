-- inn.lua : "Inn" stop look, Maplewold (480x270 gate view). Opus second pass (art-2701 batch 4).
-- Builds on ../haiku/inn.lua. Shared frame: ../../../art-2701-batch3/stops/opus3/_frame.lua (read-only).
-- Read: a big two-storey coaching inn fills the left (thatch roof with dormers, timber-framed upper floor
-- jettied over a plaster ground floor, glowing bay windows, porch, two smoking chimneys). A gallows sign post
-- by the road hangs a big tankard board. Right: a beer garden under a maple, a long trestle table with three
-- gnomes raising mugs, festoon lanterns, a barrel stack, a waiter with a tray. Road's end: a hazed coach barn.
-- Quirk: a big ginger tabby asleep on top of the inn sign, tail hanging down over the tankard, "z z" rising.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch4/stops/opus2/"
local F = dofile("/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/opus3/_frame.lua")
  .build{ name = "inn", out = DIR, farTrees = { 24, 150, 206, 300, 340, 380, 452 },
    clouds = { { 150, 40, 44 }, { 300, 28, 50 }, { 410, 62, 30 }, { 230, 70, 22 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local mix = F.mix

---------------------------------------------------------------- back row: coach barn at the road's end, far cottage
F.depth(1)
F.tree(300, 128, 30, 4)
F.building{ x0 = 246, x1 = 292, yb = 128, wh = 16, rh = 13, wall = L.timber, roof = L.roof2, noFrame = true, noAttic = true, shingle = true }
do -- big arched barn door with a cart nose showing
  local d = c:rrect(260, 117, 276, 133, 5):clip(rect(260, 117, 276, 128))
  fill(d, L.soil.deep) c:edgeIn(d, L.timber.hi)
  fill(rect(264, 124, 272, 126), L.board.base) fill(c:ellipse(266, 127, 2, 1), L.timber.shade)
  F.planks(rect(248, 116, 258, 127), L.timber, 3, true, 4) F.planks(rect(278, 116, 290, 127), L.timber, 3, true, 6)
end
F.building{ x0 = 416, x1 = 456, yb = 126, wh = 13, rh = 10, wall = L.plaster, roof = L.roof, noFrame = true, noAttic = true, chimney = true }
F.window(424, 117, 428, 120, L.timber) F.window(446, 117, 450, 120, L.timber)
F.smoke(447, 98, 4, .5, 2)
F.fenceP(300, 132, 410, 129, 10)

---------------------------------------------------------------- mid right: maple, hay cart, festoon pole
F.depth(2)
F.tree(352, 152, 46, 7)
local function hayCart(x0, yb)
  local bed = poly{ { x0, yb - 12 }, { x0 + 46, yb - 12 }, { x0 + 44, yb - 6 }, { x0 + 2, yb - 6 } }
  local hay = c:ellipse(x0 + 23, yb - 16, 25, 8):clip(rect(x0 - 4, yb - 30, x0 + 50, yb - 11))
  local shaft = line({ { x0, yb - 9 }, { x0 - 16, yb - 3 } }, 2)
  rimOf(union(bed, hay, shaft), L.timber)
  part(shaft, L.timber, { nopop = true, noshade = true })
  part(bed, L.board) F.planks(bed, L.board, 4, true, 3)
  part(hay, L.roof)
  hay:each(function(x, y)
    if hash(x, y, 81) < .18 then px(x, y, L.roof.hi) elseif (x * 2 + y) % 5 == 0 then px(x, y, L.roof.shade) end
  end)
  for i = 0, 9 do local hx = x0 + 2 + i * 5 px(hx, yb - 25 + (i % 3), L.roof.hi) px(hx + 1, yb - 26 + (i % 3), L.roof.hi) end
  for _, wx in ipairs({ x0 + 9, x0 + 37 }) do
    local w = c:ellipse(wx, yb - 4, 6, 6)
    rimOf(w, L.timber) part(w, L.timber, { nopop = true })
    fill(c:ellipse(wx, yb - 4, 3, 3), L.timber.shade)
    vline(wx, yb - 9, yb + 1, L.timber.deep) hline(wx - 5, wx + 5, yb - 4, L.timber.deep) px(wx, yb - 4, L.iron.hi)
  end
end
F.shadow(300, 350, 166, 8, 3)
hayCart(302, 166)

---------------------------------------------------------------- the inn (left hero)
F.depth(3)
local function inn()
  local X0, X1 = 30, 184
  local GTOP, YB = 142, 182          -- ground floor
  local UX0, UX1, UTOP = 25, 189, 106 -- jettied upper floor
  local ground = rect(X0, GTOP, X1, YB)
  local upper = rect(UX0, UTOP, UX1, GTOP - 1)
  local roof = poly{ { 16, UTOP + 1 }, { 198, UTOP + 1 }, { 178, 66 }, { 36, 66 } }
  local ch1, ch2 = rect(52, 50, 61, 70), rect(152, 46, 161, 70)
  local dorm = {}
  for _, dx in ipairs({ 74, 140 }) do
    dorm[#dorm + 1] = { x = dx, m = poly{ { dx - 11, 96 }, { dx, 78 }, { dx + 11, 96 } }:add(rect(dx - 8, 89, dx + 8, 99)) }
  end
  local sil = union(ground, upper, roof, ch1, ch2)
  F.shadow(X0 + 4, X1 + 4, YB, 16, 6)
  rimOf(sil, L.timber)
  -- chimneys
  for _, ch in ipairs({ ch1, ch2 }) do part(ch, L.stone) F.courses(ch, 46, 4, 6, L.stone) end
  fill(rect(51, 49, 62, 51), L.stone.deep) hline(51, 62, 49, L.stone.hi)
  fill(rect(151, 45, 162, 47), L.stone.deep) hline(151, 162, 45, L.stone.hi)
  -- roof: deep thatch, combed courses, ridge cap with a scalloped ridge
  part(roof, L.roof, { band = 3 })
  F.thatch(roof, L.roof, 66, 9999)
  roof:each(function(x, y)
    if y <= 69 then px(x, y, (x % 6 < 3) and L.roof.deep or L.roof.shade) end
    if y == 70 and x % 6 == 1 then px(x, y, L.roof.deep) end
    -- hipped ends darker: the slopes at both sides turn away from the light
    local lx = 36 - (y - 66) * 20 / 41
    local rx = 178 + (y - 66) * 20 / 41
    if x > rx - 12 and hash(x, y, 9) < .7 then px(x, y, ((y - 66) % 4 == 3) and L.roof.edge or L.roof.deep) end
    if x < lx + 6 and (y - 66) % 4 ~= 3 and hash(x, y, 10) < .5 then px(x, y, L.roof.hi) end
  end)
  hline(36, 178, 66, L.roof.hi)
  hline(16, 198, UTOP + 1, L.roof.edge) hline(17, 197, UTOP, L.roof.deep)
  for x = 18, 196, 3 do px(x, UTOP + 2, L.roof.deep) if x % 2 == 0 then px(x, UTOP + 3, L.roof.edge) end end
  -- dormers in the thatch
  for _, d in ipairs(dorm) do
    rimOf(d.m, L.roof)
    local wall = rect(d.x - 7, 89, d.x + 7, 99)
    part(d.m, L.roof, { nopop = true }) F.thatch(d.m, L.roof, 78, d.x)
    part(wall, L.plaster, { nopop = true })
    F.window(d.x - 4, 90, d.x + 3, 96, L.timber, true)
    line({ { d.x - 11, 96 }, { d.x, 78 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  end
  -- upper floor: ochre plaster panels in a timber frame (close studding + braces)
  part(upper, L.board, { nopop = true })
  upper:each(function(x, y)
    if hash(x // 3, y // 2, 44) < .08 then px(x, y, L.board.hi) end
    if y >= GTOP - 4 and hash(x, y, 45) < .3 then px(x, y, L.board.shade) end
  end)
  local beams = union(rect(UX0, UTOP, UX1, UTOP + 1), rect(UX0, GTOP - 3, UX1, GTOP - 1), rect(UX0, UTOP + 17, UX1, UTOP + 18))
  for x = UX0, UX1, 11 do beams:add(rect(x, UTOP, x + 1, GTOP - 1)) end
  for x = UX0 + 11, UX1 - 22, 22 do
    beams:add(line({ { x + 1, UTOP + 16 }, { x + 11, UTOP + 3 } }, 2)):add(line({ { x + 12, UTOP + 3 }, { x + 21, UTOP + 16 } }, 2))
  end
  part(beams, L.timber, { nopop = true, noshade = true })
  beams:each(function(x, y) local v = hash(x // 3, y, 43) if v < .2 then px(x, y, L.timber.shade) elseif v > .9 then px(x, y, L.timber.hi) end end)
  hline(UX0, UX1, UTOP, L.timber.hi)
  -- jetty beam with joist ends and the shadow it throws on the ground floor
  local jet = rect(UX0 - 1, GTOP - 1, UX1 + 1, GTOP + 1)
  part(jet, L.timber, { nopop = true, noshade = true }) hline(UX0 - 1, UX1 + 1, GTOP - 1, L.timber.hi)
  for x = UX0 + 2, UX1 - 2, 6 do fill(rect(x, GTOP, x + 2, GTOP + 1), L.timber.edge) px(x, GTOP, L.timber.base) end
  -- upper windows: leaded casements with glow
  for _, wx in ipairs({ 36, 60, 108, 154, 176 }) do
    F.window(wx - 3, UTOP + 22, wx + 3, UTOP + 30, L.timber)
    for y = UTOP + 23, UTOP + 29, 2 do px(wx - 2, y, L.glow.shade) px(wx + 2, y + 1, L.glow.shade) end
  end
  -- ground floor: lime plaster, stone plinth
  part(ground, L.plaster)
  ground:each(function(x, y)
    if y <= GTOP + 3 then px(x, y, L.plaster.shade) end
    if y == GTOP + 4 then px(x, y, L.plaster.deep) end
    if hash(x // 4, y, 41) < .03 then px(x, y, L.plaster.hi) end
  end)
  local plinth = rect(X0, YB - 6, X1, YB)
  part(plinth, L.stone, { nopop = true }) F.courses(plinth, YB - 6, 3, 8, L.stone)
  -- porch with a little shingle hood over the door
  F.door(99, 154, 115, YB - 1, L.accent, true)
  fill(rect(98, YB, 116, YB), L.stone.hi)
  local hood = poly{ { 92, 152 }, { 107, 143 }, { 122, 152 } }:add(rect(92, 151, 122, 153))
  rimOf(hood, L.roof2) part(hood, L.roof2, { nopop = true }) F.courses(hood, 143, 3, 4, L.roof2)
  line({ { 92, 152 }, { 107, 143 } }):each(function(x, y) px(x, y, L.roof2.hi) end)
  for _, px0 in ipairs({ 94, 119 }) do local p = rect(px0, 154, px0 + 1, YB) part(p, L.timber, { nopop = true, noshade = true }) end
  -- bay windows: wide, many panes, warm glow, a fat window box of geraniums under each
  local function bay(x0, x1, y0, y1)
    local m = rect(x0, y0, x1, y1)
    fill(m:grow(1), L.timber.edge)
    fill(m, L.glow.base)
    m:each(function(x, y)
      if (x - x0) % 6 == 0 or (y - y0) % 5 == 0 then px(x, y, L.timber.base)
      elseif (x - x0) % 6 == 1 and (y - y0) % 5 == 1 then px(x, y, L.glow.hi)
      elseif (x - x0) % 6 == 5 or (y - y0) % 5 == 4 then px(x, y, L.glow.shade) end
    end)
    hline(x0 - 2, x1 + 2, y0 - 2, L.timber.base) hline(x0 - 2, x1 + 2, y0 - 3, L.timber.edge)
    local box = rect(x0 - 2, y1 + 2, x1 + 2, y1 + 5)
    rimOf(box, L.timber) part(box, L.board, { nopop = true }) F.planks(box, L.board, 4, true, 2)
    for x = x0 - 1, x1 + 1 do
      local h = hash(x, y1, 12)
      px(x, y1 + 1, L.leaf.shade)
      if h < .45 then px(x, y1, L.apple.base) px(x, y1 - 1, (h < .2) and L.apple.hi or L.apple.base) elseif h < .7 then px(x, y1, L.leaf.base) end
    end
  end
  bay(40, 76, 155, 168)
  bay(134, 170, 155, 168)
  -- a lantern on a bracket by the door
  fill(rect(122, 146, 128, 146), L.iron.shade) vline(127, 147, 148, L.iron.shade)
  local lam = rect(125, 149, 129, 155) rimOf(lam, L.timber) fill(lam, L.glow.base) px(126, 150, L.glow.hi) vline(129, 150, 155, L.glow.shade)
  -- climbing rose on the left corner
  for i = 0, 34 do
    local y = YB - 4 - i
    local x = X0 + 2 + floor(2 * sin(i * .5))
    px(x, y, L.leaf.shade)
    if i % 4 == 0 then px(x + 1, y, L.leaf.base) px(x - 1, y - 1, L.leaf.hi) end
    if i % 6 == 3 then px(x + 1, y, L.awnA.hi) px(x + 1, y - 1, L.awnA.base) end
  end
  F.smoke(57, 44, 7, .5, 2) F.smoke(156, 40, 8, .8, 3)
end
inn()
-- the innkeeper in her apron with a mug, on the step
F.depth(3)
local _, ihx, ihy = F.gnome(132, 194, { hat = L.awnA, coat = L.awnB, arm = "out" })
do local mug = rect(ihx, ihy - 5, ihx + 3, ihy) rimOf(mug, L.timber) part(mug, L.glow, { nopop = true }) hline(ihx, ihx + 3, ihy - 5, L.awnB.hi) px(ihx + 4, ihy - 3, L.glow.shade) end
-- a slate board by the door: a chalk mug and a pie
do
  local leg = line({ { 82, 198 }, { 86, 180 } }, 1):add(line({ { 96, 198 }, { 92, 180 } }, 1))
  local bd = rect(80, 178, 98, 192)
  rimOf(union(bd, leg), L.timber) part(leg, L.timber, { nopop = true, noshade = true })
  fill(bd, L.iron.deep) c:edgeIn(bd, L.timber.base)
  for _, p in ipairs({ { 83, 182 }, { 84, 182 }, { 85, 182 }, { 83, 183 }, { 83, 184 }, { 83, 185 }, { 84, 186 }, { 85, 186 }, { 86, 183 }, { 86, 184 }, { 87, 184 } }) do px(p[1], p[2], L.awnB.base) end
  for x = 90, 95 do px(x, 186, L.awnB.base) end for x = 91, 94 do px(x, 184, L.awnB.shade) end px(90, 185, L.awnB.base) px(95, 185, L.awnB.base)
end

---------------------------------------------------------------- the gallows sign post and its tankard board
F.depth(3)
local SX0, SX1, SY0, SY1 = 202, 240, 128, 152
do
  local post = rect(194, 96, 197, 196)
  local arm = rect(194, 96, 246, 99)
  local brace = line({ { 198, 118 }, { 218, 100 } }, 2)
  local foot = rect(189, 192, 202, 198)
  F.shadowM(c:ellipse(204, 199, 12, 2))
  rimOf(union(post, arm, brace, foot), L.timber)
  part(post, L.timber, { nopop = true }) part(arm, L.timber, { nopop = true, noshade = true }) part(brace, L.timber, { nopop = true, noshade = true })
  part(foot, L.stone, { nopop = true }) hline(189, 202, 192, L.stone.hi)
  hline(194, 246, 96, L.timber.hi)
  fill(rect(244, 92, 247, 95), L.iron.base) px(244, 92, L.iron.hi) -- iron finial
  -- chains
  for y = 100, SY0 - 1 do if y % 2 == 0 then px(SX0 + 3, y, L.iron.shade) px(SX1 - 3, y, L.iron.shade) else px(SX0 + 3, y, L.iron.hi) px(SX1 - 3, y, L.iron.hi) end end
  -- the board: green frame, cream field, a big foaming tankard
  local board = rect(SX0, SY0, SX1, SY1)
  rimOf(board, L.accent) part(board, L.accent, { nopop = true })
  local field = rect(SX0 + 3, SY0 + 3, SX1 - 3, SY1 - 3)
  fill(field, L.plaster.hi) field:each(function(x, y) if hash(x, y, 6) < .06 then px(x, y, L.plaster.base) end end)
  hline(SX0, SX1, SY0, L.accent.hi) vline(SX0, SY0, SY1, L.accent.hi)
  local tk = rect(213, 136, 227, 149)
  local hnd = c:ellipse(229, 142, 4, 4):cut(c:ellipse(229, 142, 2, 2)):cut(rect(222, 136, 227, 149))
  local foam = c:ellipse(220, 135, 9, 3):add(c:ellipse(216, 133, 3, 2)):add(c:ellipse(223, 132, 3, 2))
  c:rim(union(tk, hnd, foam), L.timber.edge)
  part(tk, L.glow) part(hnd, L.glow, { nopop = true })
  for x = 215, 225, 4 do vline(x, 139, 148, L.glow.shade) end
  hline(213, 227, 138, L.timber.base) hline(213, 227, 147, L.timber.base)
  part(foam, L.awnB, { nopop = true }) px(214, 132, L.awnB.hi) px(215, 131, L.awnB.hi) px(222, 131, L.awnB.hi)
  px(211, 137, L.awnB.base) px(210, 139, L.awnB.base) -- a drip of foam
end
-- QUIRK: a big ginger tabby asleep on top of the board, tail hanging down over the tankard
do
  local by = SY0 - 1
  local body = c:ellipse(226, by - 6, 13, 6):clip(rect(200, by - 14, 245, by))
  local head = c:ellipse(208, by - 7, 7, 6):clip(rect(196, by - 14, 220, by))
  local ears = poly{ { 202, by - 10 }, { 203, by - 17 }, { 207, by - 12 } }:add(poly{ { 209, by - 12 }, { 213, by - 17 }, { 215, by - 9 } })
  local tail = line({ { 238, by - 2 }, { 240, by + 4 }, { 237, by + 12 }, { 233, by + 15 } }, 3)
  local paws = c:ellipse(212, by - 1, 5, 1)
  local cat = union(body, head, ears, tail, paws)
  c:rim(cat, L.timber.edge)
  local O = L.produce
  part(union(body, tail), O, { nopop = true })
  -- tabby stripes across the back and tail rings
  body:each(function(x, y)
    if (x + floor((y - by) * .6)) % 5 == 0 and y < by - 2 then px(x, y, O.shade) end
    if y >= by - 2 then px(x, y, O.shade) end
    if y <= by - 10 and hash(x, y, 3) < .5 then px(x, y, O.hi) end
  end)
  tail:each(function(x, y) if (y - by) % 4 == 0 then px(x, y, O.deep) end end)
  part(head, O, { nopop = true }) part(ears, O, { nopop = true })
  head:each(function(x, y) if y <= by - 11 and (x % 3 == 0) then px(x, y, O.shade) end end)
  px(203, by - 14, "#f2a0a0") px(204, by - 13, "#f2a0a0") px(212, by - 14, "#f2a0a0") px(212, by - 13, "#f2a0a0")
  -- cream muzzle, chest and paws
  fill(c:ellipse(208, by - 3, 4, 2), L.awnB.hi) fill(paws, L.awnB.hi) px(209, by - 1, L.awnB.shade) px(213, by - 1, L.awnB.shade)
  -- closed eyes: two smiling arcs
  px(203, by - 8, L.timber.edge) px(204, by - 7, L.timber.edge) px(205, by - 8, L.timber.edge)
  px(210, by - 8, L.timber.edge) px(211, by - 7, L.timber.edge) px(212, by - 8, L.timber.edge)
  fill(rect(207, by - 6, 208, by - 5), L.apple.base) px(207, by - 6, L.apple.hi) -- pink nose
  px(208, by - 4, L.timber.edge)
  hline(197, 200, by - 5, L.awnB.shade) hline(215, 218, by - 5, L.awnB.shade) -- whiskers
  -- z z z floating up
  local function zed(x, y, s)
    for i = 0, s do px(x + i, y, L.awnB.hi) px(x + i, y + s, L.awnB.hi) px(x + s - i, y + i, L.awnB.hi) end
  end
  zed(214, by - 24, 3) zed(220, by - 32, 4) zed(228, by - 41, 5)
end

---------------------------------------------------------------- beer garden (right): big maple, festoons, table, drinkers
F.depth(3)
do -- the beer-garden maple: a lumpy cluster crown on a forked trunk
  local tr = rect(428, 150, 432, 192):add(line({ { 430, 160 }, { 414, 142 } }, 2)):add(line({ { 431, 158 }, { 446, 144 } }, 2))
  F.shadowM(c:ellipse(424, 194, 26, 3))
  rimOf(tr, L.timber) part(tr, L.timber, { nopop = true })
  F.crown(446, 140, 22, 17, L.foliage, 12)
  F.crown(408, 140, 20, 16, L.foliage, 14)
  F.crown(428, 118, 26, 20, L.foliage, 13)
  F.crown(452, 112, 14, 12, L.foliage2, 15)
end
do -- festoon lantern string from the maple to a pole by the road
  local pole = rect(288, 128, 289, 196)
  rimOf(pole, L.timber) part(pole, L.timber, { nopop = true, noshade = true })
  local x0, y0, x1, y1 = 289, 130, 410, 136
  local function ly(x) local t = (x - x0) / (x1 - x0) return floor(y0 + (y1 - y0) * t + 14 * 4 * t * (1 - t) * .5 + .5) end
  for x = x0, x1 do px(x, ly(x), L.timber.deep) end
  local cols = { L.awnA, L.glow, L.accent, L.glow, L.roof2 }
  local i = 0
  for x = x0 + 8, x1 - 6, 12 do
    i = i + 1
    local y = ly(x) + 1
    local r = cols[i % #cols + 1]
    local m = c:rrect(x - 2, y + 1, x + 2, y + 6, 1)
    c:rim(m, L.timber.edge) fill(m, r.base) px(x - 1, y + 2, r.hi) vline(x + 2, y + 2, y + 5, r.shade) px(x, y, L.timber.deep)
  end
end
-- barrel stack against the pole
F.barrel(300, 206, L.timber, 12) F.barrel(312, 207, L.board, 12) F.barrel(306, 194, L.timber, 11)
-- long trestle table with three gnomes behind it, raising mugs
local function mugAt(x, y)
  local m = rect(x, y - 5, x + 3, y)
  c:rim(m, L.timber.edge) part(m, L.glow, { nopop = true }) hline(x, x + 3, y - 5, L.awnB.hi) hline(x - 1, x + 4, y - 6, L.awnB.base) px(x + 4, y - 3, L.glow.shade)
end
do
  local g1 = { 338, 210, L.roof2, L.leaf, "up" }
  local g2 = { 366, 209, L.lav, L.roof, "up" }
  local g3 = { 394, 210, L.leaf, L.awnA, "out" }
  for i, g in ipairs({ g1, g2, g3 }) do
    local _, hx, hy = F.gnome(g[1], g[2], { hat = g[3], coat = g[4], arm = g[5], flip = (i == 3), noShadow = true })
    mugAt(hx - 1, hy)
  end
  -- clinking mugs: a few spark pixels between the raised mugs
  for _, p in ipairs({ { 356, 186 }, { 352, 184 }, { 358, 182 } }) do px(p[1], p[2], L.awnB.hi) end
  local top = rect(322, 206, 414, 210)
  local legs = rect(328, 211, 330, 226):add(rect(406, 211, 408, 226)):add(line({ { 329, 220 }, { 407, 220 } }))
  local bench = rect(318, 222, 418, 224):add(rect(322, 225, 323, 230)):add(rect(413, 225, 414, 230))
  F.shadow(324, 414, 230, 10, 3)
  rimOf(union(top, legs, bench), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true })
  part(bench, L.board, { nopop = true }) F.planks(bench, L.board, 7, false, 5)
  part(top, L.board) F.planks(top, L.board, 9, false, 7) hline(322, 414, 206, L.board.hi)
  -- on the table: mugs, a loaf, a cheese wedge, a pie
  mugAt(348, 205) mugAt(380, 205)
  local loaf = c:ellipse(362, 203, 5, 3) rimOf(loaf, L.soil) part(loaf, L.produce) px(360, 202, L.produce.hi) hline(359, 365, 203, L.produce.shade)
  local ch = poly{ { 389, 205 }, { 400, 205 }, { 400, 199 } } rimOf(ch, L.roof) part(ch, L.roof, { nopop = true }) px(397, 203, L.roof.shade) px(398, 201, L.roof.shade)
  local plate = c:ellipse(334, 205, 6, 1) fill(plate, L.awnB.base) fill(c:ellipse(334, 203, 4, 2), L.produce.shade) hline(331, 337, 202, L.produce.hi)
end
-- a dog under the table end, nose on paws
-- the waiter crossing the road with a tray of mugs
F.depth(3)
do
  local _, hx, hy = F.gnome(268, 232, { hat = L.accent, coat = L.awnA, arm = "up", flip = true })
  local tray = rect(hx - 9, hy - 1, hx + 5, hy)
  rimOf(tray, L.iron) part(tray, L.iron, { nopop = true, noshade = true })
  mugAt(hx - 8, hy - 2) mugAt(hx - 3, hy - 2) mugAt(hx + 2, hy - 2)
end

---------------------------------------------------------------- foreground left: trough, hitching rail, firewood, barrel roller
F.depth(3)
do -- stone horse trough with a hitching rail behind it
  local rail = rect(22, 212, 104, 214):add(rect(26, 212, 28, 228)):add(rect(98, 212, 100, 228))
  rimOf(rail, L.timber) part(rail, L.timber, { nopop = true, noshade = true }) hline(22, 104, 212, L.timber.hi)
  fill(rect(40, 214, 41, 218), L.board.shade) -- a tied rope
  local t = rect(30, 220, 96, 232)
  F.shadow(32, 96, 234, 8, 3)
  rimOf(t, L.stone) part(t, L.stone) F.courses(t, 220, 6, 11, L.stone)
  local w = rect(32, 221, 94, 223)
  fill(w, L.water.base) hline(32, 94, 221, L.water.hi) for x = 36, 92, 9 do px(x, 222, L.water.hi) px(x + 1, 222, "#fff0d0") end
  fill(rect(30, 219, 96, 219), L.stone.hi)
  -- moss on the trough foot
  for x = 30, 96 do if hash(x, 1, 77) < .35 then px(x, 232, L.leaf.base) px(x, 231, hash(x, 2, 77) < .5 and L.leaf.hi or L.leaf.shade) end end
end
do -- firewood stack under a little lean-to by the inn wall
  local stackM = rect(146, 196, 184, 212)
  F.shadow(146, 186, 213, 6, 3)
  rimOf(stackM, L.timber) fill(stackM, L.timber.shade)
  for row = 0, 2 do for k = 0, 6 do
    local cx, cy = 149 + k * 6 + (row % 2) * 3, 199 + row * 5
    if cx <= 182 then
      local lg = c:ellipse(cx, cy, 2.5, 2.5)
      fill(lg, L.board.hi) px(cx, cy, L.board.shade) px(cx + 1, cy, L.board.base)
      lg:edge():each(function(x, y) px(x, y, (x > cx or y > cy) and L.timber.base or L.board.base) end)
    end
  end end
  local axe = line({ { 186, 212 }, { 180, 202 } }) fill(axe, L.board.base) fill(rect(178, 200, 181, 203), L.iron.base) px(178, 200, L.iron.hi)
end
-- a gnome rolling a barrel along toward the inn
do
  local _, hx, hy = F.gnome(176, 252, { hat = L.roof, coat = L.accent, arm = "out", flip = true })
  local b = c:rrect(152, 240, 166, 254, 4)
  F.shadowM(c:ellipse(160, 255, 9, 1))
  rimOf(b, L.timber) part(b, L.timber)
  vline(155, 241, 253, L.iron.shade) vline(163, 241, 253, L.iron.shade) hline(153, 165, 246, L.timber.hi)
  for _, p in ipairs({ { 146, 250 }, { 144, 246 }, { 143, 253 } }) do px(p[1], p[2], L.ground.hi) end -- dust puffs
end
-- crate of green bottles and a cabbage sack, bottom left
do
  F.crate(40, 256, 26, 12)
  for k = 0, 5 do
    local bx = 43 + k * 4
    local b = rect(bx, 238, bx + 2, 244):add(rect(bx + 1, 235, bx + 1, 237))
    c:rim(b, L.timber.edge) fill(b, L.leaf.shade) px(bx, 239, L.leaf.hi) px(bx + 1, 235, L.produce.base)
  end
  F.sack(86, 258, L.awnB, 7)
  F.sack(100, 262, L.board, 6)
  F.rock(124, 262, 8, 6)
end
-- a tub of marigolds by the road
do
  local tub = c:rrect(210, 226, 228, 240, 3)
  F.shadowM(c:ellipse(222, 241, 10, 1))
  rimOf(tub, L.timber) part(tub, L.timber) hline(210, 228, 230, L.iron.shade) hline(210, 228, 237, L.iron.shade)
  local fl = c:ellipse(219, 222, 10, 5)
  rimOf(fl, L.leaf) part(fl, L.leaf, { nopop = true })
  for i = 0, 14 do local fx, fy = 211 + floor(hash(i, 1, 5) * 17), 218 + floor(hash(i, 2, 5) * 7) px(fx, fy, L.produce.base) px(fx + 1, fy, L.produce.hi) end
end

-- hens pecking at crumbs dropped from the table
F.depth(3)
F.hen(318, 252, L.awnB) F.hen(342, 258, L.soil, true) F.hen(360, 246, L.awnB, true)
for _, g in ipairs({ { 326, 254 }, { 332, 256 }, { 336, 251 }, { 350, 255 }, { 329, 250 } }) do px(g[1], g[2], L.produce.hi) end
-- a spare cart wheel leaning on the barrels
do local w = c:ellipse(290, 214, 7, 8) rimOf(w, L.timber) part(w, L.timber, { nopop = true })
  fill(c:ellipse(290, 214, 4, 5), L.ground.shade) vline(290, 207, 221, L.timber.deep) hline(284, 296, 214, L.timber.deep) fill(rect(289, 213, 291, 215), L.iron.base) end
F.depth(0)
F.birds({ { 330, 52, 2 }, { 342, 46, 1 }, { 120, 52, 2 }, { 380, 78, 2, L.awnB.hi } })
F.finish()
