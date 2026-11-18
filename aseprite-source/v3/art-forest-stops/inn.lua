-- inn.lua : "Inn" stop look, FOREST (forest_pinewood), 480x270 gate view.
-- Same composition as the Maplewold inn (art-2701-batch4/stops/opus3/inn.lua), re-cast for a pine wood:
-- left hero: a big two-storey woodland inn, log ground floor on a mossy stone plinth, a jettied upper floor of
-- grey-green painted boards with red shutters, a steep mossy cedar-shingle roof with dormers and two smoking stone
-- chimneys, glowing bay windows, a bark-shingle porch hood. Firewood stacked right up to the eaves at the gable end.
-- A gallows sign post by the road hangs the tankard board. Right: a beer garden under a tall red-bark pine, a long
-- trestle table with three gnomes raising mugs, lantern festoons strung across the road, a barrel stack, a waiter.
-- Road's end: a log coach barn. Back right: a log cabin with smoke. A pony eats from the hay cart; a goat chews the
-- tether at the hitching rail beside a hollowed-log water trough.
-- Quirk: a big ginger tabby asleep on top of the inn sign, tail hanging down over the tankard, "z z" rising.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-forest-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "inn", out = DIR, farTrees = { 24, 150, 206, 300, 340, 380, 452 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local mix = F.mix

---------------------------------------------------------------- back row: log coach barn at the road's end, far log cabin
F.depth(1)
F.tree(300, 128, 34, 4)
F.tree(236, 126, 28, 2)
do
  local top, _, bwall, broof = F.building{ x0 = 246, x1 = 292, yb = 128, wh = 16, rh = 13, wall = L.timber, roof = L.roof2, noFrame = true, noAttic = true, shingle = true }
  F.logs(bwall, L.timber, top, 3)
  F.moss(broof, .12, 31)
  for y = top + 1, 126, 3 do F.logEnd(245, y, 1) F.logEnd(293, y, 1) end
  -- big arched barn door with a cart nose showing
  local d = c:rrect(260, 117, 276, 133, 5):clip(rect(260, 117, 276, 128))
  fill(d, L.soil.deep) c:edgeIn(d, L.timber.hi)
  fill(rect(264, 124, 272, 126), L.board.base) fill(c:ellipse(266, 127, 2, 1), L.timber.shade)
  px(268, 121, L.glow.shade) px(269, 121, L.glow.base) -- a lamp lit deep inside
end
do
  local top, _, cwall, croof = F.building{ x0 = 416, x1 = 456, yb = 126, wh = 13, rh = 10, wall = L.timber, roof = L.roof, noFrame = true, noAttic = true, chimney = true, shingle = true }
  F.logs(cwall, L.timber, top, 3)
  F.moss(croof, .2, 32)
  F.window(424, 117, 428, 120, L.timber) F.window(446, 117, 450, 120, L.timber)
end
F.smoke(447, 98, 4, .5, 2)
F.fenceP(300, 132, 410, 129, 10)
-- the barn's washing line: aprons and tea towels (the inn's laundry), hazed with the back row
do local wp = rect(318, 112, 319, 130) rimOf(wp, L.timber) part(wp, L.timber, { nopop = true, noshade = true }) end
F.washing(293, 114, 318, 113, { { "sheet", L.awnB }, { "shirt", L.awnA }, { "sock", L.accent } }, 3)

---------------------------------------------------------------- mid right: spruce + birch, hay cart, the pony
F.depth(2)
F.tree(352, 152, 50, 6)
F.birch(384, 158, 44, 17)
F.tree(322, 140, 34, 5)
local function hayCart(x0, yb)
  local bed = poly{ { x0, yb - 12 }, { x0 + 46, yb - 12 }, { x0 + 44, yb - 6 }, { x0 + 2, yb - 6 } }
  local hay = c:ellipse(x0 + 23, yb - 16, 25, 8):clip(rect(x0 - 4, yb - 30, x0 + 50, yb - 11))
  local shaft = line({ { x0, yb - 9 }, { x0 - 16, yb - 3 } }, 2)
  rimOf(union(bed, hay, shaft), L.timber)
  part(shaft, L.timber, { nopop = true, noshade = true })
  part(bed, L.board) F.planks(bed, L.board, 4, true, 3)
  part(hay, L.gold)
  hay:each(function(x, y)
    if hash(x, y, 81) < .18 then px(x, y, L.gold.hi) elseif (x * 2 + y) % 5 == 0 then px(x, y, L.gold.shade) end
    if y > yb - 14 and hash(x, y, 82) < .3 then px(x, y, L.gold.deep) end
  end)
  for i = 0, 9 do local hx = x0 + 2 + i * 5 px(hx, yb - 25 + (i % 3), L.gold.hi) px(hx + 1, yb - 26 + (i % 3), L.gold.hi) end
  for _, wx in ipairs({ x0 + 9, x0 + 37 }) do
    local w = c:ellipse(wx, yb - 4, 6, 6)
    rimOf(w, L.timber) part(w, L.timber, { nopop = true })
    fill(c:ellipse(wx, yb - 4, 3, 3), L.timber.shade)
    vline(wx, yb - 9, yb + 1, L.timber.deep) hline(wx - 5, wx + 5, yb - 4, L.timber.deep) px(wx, yb - 4, L.iron.hi)
  end
end
F.shadow(300, 350, 166, 8, 3)
hayCart(302, 166)
-- a chestnut fell pony with a flaxen mane, head down in the hay
F.shadowM(c:ellipse(364, 167, 12, 1))
F.sprite({
  ".......mm...............",
  "......mmBBhhhhhhhhhh....",
  ".....mmBBBBBBBBBBBBBBh.t",
  "....mmBBBBBBBBBBBBBBBBtt",
  "...mmBBBBBBBBBBBBBBBBBtt",
  "..mBBB.BBBBBBBBBBBBBBBtt",
  ".mBeB..BBBBBBBBBBBBBBB.t",
  "BBkB...dBBBBBBBBBBBBBd.t",
  "BBBw....dBBdddddddBBBd.t",
  "BBww....BB.d.....BB.d...",
  "nBw.....Bd.d.....Bd.d...",
  "nn......Bd.dd....Bd.dd..",
  "........dd.dd....dd.dd..",
  "........ff.ff....ff.ff..",
}, 347, 153, { m = L.board.hi, h = L.soil.hi, B = L.soil.base, d = L.soil.shade, k = L.timber.edge, w = L.awnB.hi,
  n = L.soil.deep, t = L.board.base, f = L.timber.deep, e = L.soil.deep })
px(346, 162, L.gold.hi) px(345, 163, L.gold.base) px(346, 164, L.gold.hi) px(345, 161, L.gold.shade)

---------------------------------------------------------------- the inn (left hero)
F.depth(3)
local function inn()
  local X0, X1 = 30, 184
  local GTOP, YB = 142, 182          -- ground floor
  local UX0, UX1, UTOP = 25, 189, 106 -- jettied upper floor
  local ground = rect(X0, GTOP, X1, YB)
  local upper = rect(UX0, UTOP, UX1, GTOP - 1)
  local roof = poly{ { 16, UTOP + 1 }, { 198, UTOP + 1 }, { 178, 62 }, { 36, 62 } }
  local ch1, ch2 = rect(52, 46, 61, 70), rect(152, 42, 161, 70)
  local dorm = {}
  for _, dx in ipairs({ 74, 140 }) do
    dorm[#dorm + 1] = { x = dx, m = poly{ { dx - 11, 96 }, { dx, 76 }, { dx + 11, 96 } }:add(rect(dx - 8, 89, dx + 8, 99)) }
  end
  local sil = union(ground, upper, roof, ch1, ch2)
  F.shadow(X0 + 4, X1 + 4, YB, 16, 6)
  rimOf(sil, L.timber)
  -- chimneys: fieldstone, mossy, with a slate cap
  for _, ch in ipairs({ ch1, ch2 }) do part(ch, L.stone) F.courses(ch, 42, 4, 6, L.stone) F.moss(ch, .14, 33) end
  fill(rect(51, 45, 62, 47), L.stone.deep) hline(51, 62, 45, L.stone.hi)
  fill(rect(151, 41, 162, 43), L.stone.deep) hline(151, 162, 41, L.stone.hi)
  -- roof: mossy cedar shingle courses, ridge cap, darker hipped right end, lit left end
  part(roof, L.roof, { band = 3 })
  F.courses(roof, 62, 3, 5, L.roof)
  roof:each(function(x, y)
    if y <= 65 then px(x, y, (x % 6 < 3) and L.roof2.shade or L.roof2.deep) end -- bark ridge cap
    local lx = 36 - (y - 62) * 20 / 45
    local rx = 178 + (y - 62) * 20 / 45
    if x > rx - 12 and hash(x, y, 9) < .75 then px(x, y, ((y - 62) % 3 == 0) and L.roof.edge or L.roof.deep) end
    if x < lx + 6 and (y - 62) % 3 ~= 0 and hash(x, y, 10) < .5 then px(x, y, L.roof.hi) end
    -- weathered silver shingles here and there
    if y > 66 and hash((x + ((y - 62) // 3) * 2) // 5, (y - 62) // 3, 11) < .1 and (y - 62) % 3 ~= 0 then px(x, y, mix(L.roof.base, L.stone.hi, .45)) end
  end)
  hline(36, 178, 62, L.roof2.hi)
  -- moss cushions on the shady lower slope, and a few fern sprouts in them
  for i, b in ipairs({ { 52, 98, 10 }, { 100, 92, 7 }, { 126, 100, 11 }, { 168, 94, 8 }, { 150, 78, 6 }, { 64, 80, 5 }, { 30, 104, 6 }, { 110, 72, 5 } }) do
    roof:each(function(x, y)
      local d = ((x - b[1]) / b[3]) ^ 2 + ((y - b[2]) / (b[3] * .6)) ^ 2
      if d < 1 and hash(x, y, 30 + i) < .85 then
        local h = (y - b[2]) < -b[3] * .2 and L.moss.hi or (d > .6 and L.moss.shade or L.moss.base)
        if (y - 62) % 3 == 0 then h = L.moss.deep end
        px(x, y, h)
      end
    end)
  end
  F.fern(126, 96, 3) F.fern(54, 94, 3)
  -- a wood pigeon on the ridge
  F.sprite({ "..gg...", ".gGgk..", "gGGGGGo", ".gGGGg.", "..o.o.." }, 118, 57, { g = L.iron.base, G = L.iron.hi, k = L.timber.edge, o = L.apple.base })
  hline(16, 198, UTOP + 1, L.roof.edge) hline(17, 197, UTOP, L.roof.deep)
  for x = 18, 196, 3 do px(x, UTOP + 2, L.roof.deep) if x % 2 == 0 then px(x, UTOP + 3, L.roof.edge) end end
  -- dormers: shingle hoods, board faces, carved bargeboards
  for _, d in ipairs(dorm) do
    rimOf(d.m, L.roof)
    local wall = rect(d.x - 7, 89, d.x + 7, 99)
    part(d.m, L.roof, { nopop = true }) F.courses(d.m, 76, 3, 5, L.roof) F.moss(d.m, .1, 34 + d.x)
    part(wall, L.board, { nopop = true }) F.planks(wall, L.board, 3, true, d.x)
    F.window(d.x - 4, 90, d.x + 3, 96, L.timber, true)
    line({ { d.x - 11, 96 }, { d.x, 76 } }):each(function(x, y) px(x, y, L.roof2.hi) end)
    line({ { d.x + 11, 96 }, { d.x, 76 } }):each(function(x, y) px(x, y, L.roof2.shade) end)
    px(d.x, 74, L.timber.edge) px(d.x, 75, L.roof2.base) -- finial
  end
  -- upper floor: grey-green painted board-and-batten between log posts
  part(upper, L.wall2, { nopop = true })
  upper:each(function(x, y)
    local k = (x - UX0) % 7
    if k == 0 then px(x, y, L.wall2.hi) elseif k == 1 then px(x, y, L.wall2.shade)
    elseif hash(x, y // 4, 46) < .07 then px(x, y, L.wall2.shade) elseif hash(x, y // 5, 47) < .05 then px(x, y, L.wall2.hi) end
    if y >= GTOP - 5 and hash(x, y, 45) < .3 then px(x, y, L.wall2.shade) end
    if y <= UTOP + 3 then px(x, y, L.wall2.deep) end -- eave shadow
  end)
  local beams = union(rect(UX0, UTOP, UX1, UTOP + 1), rect(UX0, GTOP - 3, UX1, GTOP - 1))
  for _, bx in ipairs({ UX0, 48, 84, 128, 166, UX1 - 1 }) do beams:add(rect(bx, UTOP, bx + 1, GTOP - 1)) end
  part(beams, L.timber, { nopop = true, noshade = true })
  beams:each(function(x, y) local v = hash(x // 3, y, 43) if v < .2 then px(x, y, L.timber.shade) elseif v > .9 then px(x, y, L.timber.hi) end end)
  hline(UX0, UX1, GTOP - 3, L.timber.hi)
  -- jetty beam with joist ends and the shadow it throws on the ground floor
  local jet = rect(UX0 - 1, GTOP - 1, UX1 + 1, GTOP + 1)
  part(jet, L.timber, { nopop = true, noshade = true }) hline(UX0 - 1, UX1 + 1, GTOP - 1, L.timber.hi)
  for x = UX0 + 2, UX1 - 2, 6 do F.logEnd(x + 1, GTOP + 1, 1) end
  -- upper windows: lit casements with red shutters (heart cut-outs)
  for _, wx in ipairs({ 62, 106, 148, 178 }) do
    F.window(wx - 3, UTOP + 18, wx + 3, UTOP + 27, L.timber)
    for y = UTOP + 19, UTOP + 26, 2 do px(wx - 2, y, L.glow.shade) px(wx + 2, y + 1, L.glow.shade) end
    for _, sx in ipairs({ wx - 8, wx + 5 }) do
      local sh = rect(sx, UTOP + 17, sx + 3, UTOP + 28)
      c:rim(sh, L.awnA.edge) part(sh, L.awnA, { nopop = true })
      vline(sx + 2, UTOP + 18, UTOP + 27, L.awnA.shade) hline(sx, sx + 3, UTOP + 22, L.awnA.deep)
      px(sx + 1, UTOP + 19, L.awnA.deep) px(sx + 2, UTOP + 19, L.awnA.deep) px(sx + 1, UTOP + 20, L.awnA.deep)
    end
  end
  -- ground floor: round logs with corner log ends, mossy stone plinth
  part(ground, L.timber)
  F.logs(ground, L.timber, GTOP + 2, 4)
  ground:each(function(x, y) if y <= GTOP + 4 then px(x, y, L.timber.deep) end end) -- under the jetty
  for y = GTOP + 4, YB - 8, 4 do F.logEnd(X0 - 1, y, 2) F.logEnd(X1 + 1, y, 2) end
  local plinth = rect(X0, YB - 6, X1, YB)
  part(plinth, L.stone, { nopop = true }) F.courses(plinth, YB - 6, 3, 8, L.stone) F.moss(plinth, .2, 35)
  -- porch with a bark-shingle hood over the door
  F.door(99, 154, 115, YB - 1, L.accent, true)
  fill(rect(98, YB, 116, YB), L.stone.hi)
  local hood = poly{ { 92, 152 }, { 107, 143 }, { 122, 152 } }:add(rect(92, 151, 122, 153))
  rimOf(hood, L.roof2) part(hood, L.roof2, { nopop = true }) F.courses(hood, 143, 3, 4, L.roof2)
  line({ { 92, 152 }, { 107, 143 } }):each(function(x, y) px(x, y, L.roof2.hi) end)
  for _, px0 in ipairs({ 94, 119 }) do local p = rect(px0, 154, px0 + 1, YB) part(p, L.redbark, { nopop = true, noshade = true }) end -- peeled pine porch posts
  -- antlers over the door
  for _, p in ipairs({ { 103, 148 }, { 102, 147 }, { 101, 146 }, { 100, 147 }, { 101, 145 }, { 111, 148 }, { 112, 147 }, { 113, 146 }, { 114, 147 }, { 113, 145 } }) do px(p[1], p[2], L.awnB.base) end
  hline(104, 110, 149, L.board.base) px(104, 149, L.board.hi)
  -- bay windows: wide, many panes, warm glow, a window box of ferns and red lingonberry under each
  local function bay(x0, x1, y0, y1)
    local m = rect(x0, y0, x1, y1)
    fill(m:grow(1), L.timber.edge)
    fill(m, L.glow.base)
    m:each(function(x, y)
      if (x - x0) % 6 == 0 or (y - y0) % 5 == 0 then px(x, y, L.timber.base)
      elseif (x - x0) % 6 == 1 and (y - y0) % 5 == 1 then px(x, y, L.glow.hi)
      elseif (x - x0) % 6 == 5 or (y - y0) % 5 == 4 then px(x, y, L.glow.shade) end
    end)
    -- a silhouette of a drinker inside the left panes
    hline(x0 - 2, x1 + 2, y0 - 2, L.timber.base) hline(x0 - 2, x1 + 2, y0 - 3, L.timber.edge)
    local box = rect(x0 - 2, y1 + 2, x1 + 2, y1 + 5)
    rimOf(box, L.timber) part(box, L.board, { nopop = true }) F.planks(box, L.board, 4, true, 2)
    for x = x0 - 1, x1 + 1 do
      local h = hash(x, y1, 12)
      px(x, y1 + 1, L.fern.shade)
      if h < .3 then px(x, y1, L.apple.base) px(x, y1 - 1, (h < .12) and L.apple.hi or L.fern.base)
      elseif h < .75 then px(x, y1, L.fern.base) px(x, y1 - 1, L.fern.hi) if h < .5 then px(x, y1 - 2, L.fern.shade) end end
    end
  end
  bay(40, 76, 155, 168)
  bay(134, 170, 155, 168)
  -- inside the right bay: a gnome silhouette with a mug
  F.sprite({ "..ss..", ".ssss.", "ssssss", ".sss..", "sssss.", "sssss." }, 140, 160, { s = L.glow.deep }, { rim = false })
  -- a lantern on a bracket by the door
  fill(rect(122, 146, 128, 146), L.iron.shade) vline(127, 147, 148, L.iron.shade)
  local lam = rect(125, 149, 129, 155) rimOf(lam, L.timber) fill(lam, L.glow.base) px(126, 150, L.glow.hi) vline(129, 150, 155, L.glow.shade)
  -- a lantern glow pool on the logs around it
  for _, p in ipairs({ { 124, 157 }, { 130, 157 }, { 123, 152 }, { 131, 152 }, { 127, 158 } }) do px(p[1], p[2], L.glow.deep) end
  -- hop vine climbing the right log corner
  for i = 0, 34 do
    local y = YB - 4 - i
    local x = X1 - 2 + floor(2 * sin(i * .5))
    px(x, y, L.leaf.shade)
    if i % 4 == 0 then px(x - 1, y, L.leaf.base) px(x + 1, y - 1, L.leaf.hi) end
    if i % 6 == 3 then px(x - 1, y, L.birchLeaf.hi) px(x - 1, y + 1, L.birchLeaf.base) end
  end
  F.smoke(57, 40, 7, .5, 2) F.smoke(156, 36, 8, .8, 3)
  -- a gnome leaning out of the upstairs window, beating a striped rug, dust flying
  F.gnome(106, 139, { small = true, hat = L.leaf, coat = L.awnA, arm = "out" })
  local rug = rect(112, 135, 124, 151)
  c:rim(rug, L.timber.edge) fill(rug, L.awnA.base)
  rug:each(function(x, y) if ((y - 135) // 3) % 2 == 1 then px(x, y, L.awnB.base) end if x == 124 then px(x, y, L.awnA.deep) end if y == 135 then px(x, y, L.awnA.hi) end end)
  for x = 112, 124, 2 do px(x, 152, L.awnB.shade) end
  for _, p in ipairs({ { 127, 140 }, { 129, 137 }, { 128, 144 }, { 131, 141 }, { 132, 146 }, { 130, 135 } }) do px(p[1], p[2], "#d6d4c2") px(p[1] + 1, p[2], "#c4c4b0") end
end
inn()

-- firewood stacked to the eaves against the left gable end, under the roof overhang
do
  local X0, X1, Y0, Y1 = 17, 38, 109, 182
  local back = rect(X0, Y0, X1, Y1)
  F.shadow(X0, X1 + 2, Y1, 6, 3)
  rimOf(back, L.timber) fill(back, L.timber.deep)
  local row = 0
  for y = Y1 - 3, Y0 + 2, -5 do
    row = row + 1
    for x = X0 + 3 + (row % 2) * 2, X1 - 2, 5 do
      local v = hash(x, y, 6)
      F.logEnd(x, y, 2, v < .15 and L.redbark or (v > .88 and L.birch or L.timber))
      if hash(x, y, 7) < .25 then px(x - 1, y - 1, L.board.hi) px(x + 1, y + 1, L.board.shade) end
    end
  end
  -- stack props: two stakes, moss on the bottom course
  for _, sx in ipairs({ X0, X1 }) do local s = rect(sx, Y0 - 1, sx + 1, Y1) part(s, L.timber, { nopop = true, noshade = true }) end
  for x = X0, X1 do if hash(x, 3, 36) < .5 then px(x, Y1, L.moss.base) px(x, Y1 - 1, hash(x, 4, 36) < .5 and L.moss.hi or L.moss.shade) end end
  -- a sawbuck axe leaning on it
  line({ { 41, 182 }, { 46, 166 } }):each(function(x, y) px(x, y, L.board.base) end)
  fill(rect(44, 164, 48, 167), L.iron.base) px(44, 164, L.iron.hi) px(48, 167, L.iron.deep)
end

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
  post:each(function(x, y) if hash(x, y // 3, 37) < .15 then px(x, y, L.timber.shade) end end)
  part(foot, L.stone, { nopop = true }) hline(189, 202, 192, L.stone.hi) F.moss(foot, .25, 38)
  hline(194, 246, 96, L.timber.hi)
  F.sprite({ ".gg.", "gGGg", "gGGg", ".gg." }, 244, 92, { g = L.soil.shade, G = L.soil.base }) -- a carved pine-cone finial
  px(245, 93, L.soil.hi)
  -- chains
  for y = 100, SY0 - 1 do if y % 2 == 0 then px(SX0 + 3, y, L.iron.shade) px(SX1 - 3, y, L.iron.shade) else px(SX0 + 3, y, L.iron.hi) px(SX1 - 3, y, L.iron.hi) end end
  -- the board: green frame, cream field, a big foaming tankard
  local board = rect(SX0, SY0, SX1, SY1)
  rimOf(board, L.accent) part(board, L.accent, { nopop = true })
  local field = rect(SX0 + 3, SY0 + 3, SX1 - 3, SY1 - 3)
  fill(field, L.plaster.hi) field:each(function(x, y) if hash(x, y, 6) < .06 then px(x, y, L.plaster.base) end end)
  hline(SX0, SX1, SY0, L.accent.hi) vline(SX0, SY0, SY1, L.accent.hi)
  -- little painted pine sprigs in the board corners
  F.sprite({ ".g.", "ggg", ".t." }, SX0 + 4, SY1 - 7, { g = L.foliage2.shade, t = L.timber.shade }, { rim = false })
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
  body:each(function(x, y)
    if (x + floor((y - by) * .6)) % 5 == 0 and y < by - 2 then px(x, y, O.shade) end
    if y >= by - 2 then px(x, y, O.shade) end
    if y <= by - 10 and hash(x, y, 3) < .5 then px(x, y, O.hi) end
  end)
  tail:each(function(x, y) if (y - by) % 4 == 0 then px(x, y, O.deep) end end)
  part(head, O, { nopop = true }) part(ears, O, { nopop = true })
  head:each(function(x, y) if y <= by - 11 and (x % 3 == 0) then px(x, y, O.shade) end end)
  px(203, by - 14, "#f2a0a0") px(204, by - 13, "#f2a0a0") px(212, by - 14, "#f2a0a0") px(212, by - 13, "#f2a0a0")
  fill(c:ellipse(208, by - 3, 4, 2), L.awnB.hi) fill(paws, L.awnB.hi) px(209, by - 1, L.awnB.shade) px(213, by - 1, L.awnB.shade)
  px(203, by - 8, L.timber.edge) px(204, by - 7, L.timber.edge) px(205, by - 8, L.timber.edge)
  px(210, by - 8, L.timber.edge) px(211, by - 7, L.timber.edge) px(212, by - 8, L.timber.edge)
  fill(rect(207, by - 6, 208, by - 5), L.apple.base) px(207, by - 6, L.apple.hi)
  px(208, by - 4, L.timber.edge)
  hline(197, 200, by - 5, L.awnB.shade) hline(215, 218, by - 5, L.awnB.shade)
  -- a pine needle stuck in its fur
  px(230, by - 12, L.fern.shade) px(231, by - 13, L.fern.shade)
  local function zed(x, y, s)
    for i = 0, s do px(x + i, y, L.awnB.hi) px(x + i, y + s, L.awnB.hi) px(x + s - i, y + i, L.awnB.hi) end
  end
  zed(214, by - 24, 3) zed(220, by - 32, 4) zed(228, by - 41, 5)
end

---------------------------------------------------------------- beer garden (right): a big spruce + a red-bark pine, festoons, table
F.depth(3)
do
  F.shadowM(c:ellipse(434, 194, 28, 3))
  F.conifer(462, 190, 78, L.foliage2, 51)
  F.conifer(428, 196, 104, L.foliage, 52, { w = 30 })
end
-- festoon lantern strings: sign arm -> pole across the road, pole -> pine
local function festoon(x0, y0, x1, y1, sag, step, startI)
  local function ly(x) local t = (x - x0) / (x1 - x0) return floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + .5) end
  for x = x0, x1 do px(x, ly(x), L.timber.deep) end
  local cols = { L.awnA, L.glow, L.accent, L.glow, L.roof2 }
  local i = startI or 0
  for x = x0 + 8, x1 - 6, step do
    i = i + 1
    local y = ly(x) + 1
    local r = cols[i % #cols + 1]
    local m = c:rrect(x - 2, y + 1, x + 2, y + 6, 1)
    c:rim(m, L.timber.edge) fill(m, r.base) px(x - 1, y + 2, r.hi) vline(x + 2, y + 2, y + 5, r.shade) px(x, y, L.timber.deep)
    px(x, y + 7, r.deep)
  end
end
do
  local pole = rect(288, 116, 289, 196)
  rimOf(pole, L.timber) part(pole, L.timber, { nopop = true, noshade = true })
  F.sprite({ ".g.", "ggg" }, 287, 113, { g = L.foliage2.base }) -- a spruce sprig tied to the pole top
  festoon(289, 117, 412, 128, 3, 12, 0)
  festoon(246, 100, 288, 117, 4, 11, 2)
end
-- barrel stack against the pole
F.barrel(300, 206, L.timber, 12) F.barrel(312, 207, L.board, 12) F.barrel(306, 194, L.timber, 11)
F.moss(rect(295, 202, 317, 207), .1, 39)
-- long trestle table with three gnomes behind it, raising mugs
local function mugAt(x, y)
  local m = rect(x, y - 5, x + 3, y)
  c:rim(m, L.timber.edge) part(m, L.glow, { nopop = true }) hline(x, x + 3, y - 5, L.awnB.hi) hline(x - 1, x + 4, y - 6, L.awnB.base) px(x + 4, y - 3, L.glow.shade)
end
do
  local g1 = { 338, 210, L.roof2, L.leaf, "up" }
  local g2 = { 366, 209, L.lav, L.wall2, "up" }
  local g3 = { 394, 210, L.leaf, L.awnA, "out" }
  for i, g in ipairs({ g1, g2, g3 }) do
    local _, hx, hy = F.gnome(g[1], g[2], { hat = g[3], coat = g[4], arm = g[5], flip = (i == 3), noShadow = true })
    mugAt(hx - 1, hy)
  end
  for _, p in ipairs({ { 356, 186 }, { 352, 184 }, { 358, 182 } }) do px(p[1], p[2], L.awnB.hi) end
  -- the table: a split-log top on round log trestles
  local top = rect(322, 209, 414, 213)
  local legs = rect(328, 214, 330, 228):add(rect(406, 214, 408, 228)):add(line({ { 329, 222 }, { 407, 222 } }))
  local bench = rect(318, 224, 418, 226):add(rect(322, 227, 323, 231)):add(rect(413, 227, 414, 231))
  F.shadow(324, 414, 231, 10, 3)
  rimOf(union(top, legs, bench), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true })
  part(bench, L.timber, { nopop = true }) F.logs(bench, L.timber, 224, 3)
  part(top, L.board) F.planks(top, L.board, 9, false, 7) hline(322, 414, 209, L.board.hi) hline(322, 414, 213, L.timber.base)
  F.logEnd(322, 211, 2) F.logEnd(414, 211, 2)
  mugAt(348, 208) mugAt(380, 208)
  local loaf = c:ellipse(362, 206, 5, 3) rimOf(loaf, L.soil) part(loaf, L.produce) px(360, 205, L.produce.hi) hline(359, 365, 206, L.produce.shade) for k = 0, 2 do px(359 + k * 3, 204, L.produce.deep) end
  local ch = poly{ { 389, 208 }, { 400, 208 }, { 400, 202 } } rimOf(ch, L.gold) part(ch, L.gold, { nopop = true }) px(397, 206, L.gold.shade) px(398, 204, L.gold.shade)
  -- a bowl of chanterelles
  local plate = c:ellipse(334, 208, 6, 1) fill(plate, L.awnB.base) fill(c:ellipse(334, 206, 4, 2), L.produce.shade) hline(331, 337, 205, L.produce.hi)
  px(332, 204, L.gold.hi) px(335, 204, L.gold.base) px(336, 205, L.gold.hi)
  -- a candle in a jar
  fill(rect(371, 204, 373, 208), L.awnB.hi) px(372, 203, L.glow.hi) px(372, 202, L.glow.base)
end
-- the waiter crossing the road with a tray of mugs
F.depth(3)
do
  local _, hx, hy = F.gnome(268, 232, { hat = L.accent, coat = L.awnA, arm = "up", flip = true })
  local tray = rect(hx - 9, hy - 1, hx + 5, hy)
  rimOf(tray, L.iron) part(tray, L.iron, { nopop = true, noshade = true })
  mugAt(hx - 8, hy - 2) mugAt(hx - 3, hy - 2) mugAt(hx + 2, hy - 2)
end

---------------------------------------------------------------- foreground left: hollow-log trough, hitching rail, firewood, barrel roller
F.depth(3)
do
  local rail = rect(22, 212, 104, 214):add(rect(26, 212, 28, 228)):add(rect(98, 212, 100, 228))
  rimOf(rail, L.timber) part(rail, L.timber, { nopop = true, noshade = true }) hline(22, 104, 212, L.timber.hi)
  F.logEnd(22, 213, 1) F.logEnd(104, 213, 1)
  fill(rect(40, 214, 41, 218), L.board.shade) -- a tied rope
  -- a hollowed pine log on two chocks, full of water
  F.shadow(32, 96, 234, 8, 3)
  local chocks = rect(38, 229, 44, 233):add(rect(82, 229, 88, 233))
  rimOf(chocks, L.timber) part(chocks, L.timber, { nopop = true })
  local t = rect(32, 219, 96, 230)
  rimOf(t, L.redbark) part(t, L.redbark)
  F.logs(t, L.redbark, 219, 4)
  t:each(function(x, y) if hash(x // 4, y, 40) < .12 then px(x, y, L.redbark.deep) end end)
  local w = rect(35, 220, 93, 222)
  fill(rect(34, 219, 94, 219), L.board.base)
  fill(w, L.water.base) hline(35, 93, 220, L.water.hi) for x = 38, 92, 9 do px(x, 221, L.water.hi) px(x + 1, 221, "#eef6e6") end
  hline(34, 94, 223, L.board.shade)
  local e = F.logEnd(96, 225, 5, L.redbark)
  fill(c:ellipse(96, 224, 2, 2), L.water.shade) px(95, 223, L.water.hi)
  F.moss(t, .1, 41)
  for x = 32, 96 do if hash(x, 1, 77) < .35 then px(x, 230, L.moss.base) end end
end
do -- firewood stack under a little lean-to by the inn wall
  local stackM = rect(146, 196, 184, 212)
  F.shadow(146, 186, 213, 6, 3)
  rimOf(stackM, L.timber) fill(stackM, L.timber.shade)
  for row = 0, 2 do for k = 0, 6 do
    local cx, cy = 149 + k * 6 + (row % 2) * 3, 199 + row * 5
    if cx <= 182 then
      local tr = (hash(k, row, 8) < .3) and L.needle or L.board
      local lg = c:ellipse(cx, cy, 2.5, 2.5)
      fill(lg, tr.hi) px(cx, cy, tr.shade) px(cx + 1, cy, tr.base)
      lg:edge():each(function(x, y) px(x, y, (x > cx or y > cy) and L.timber.base or tr.base) end)
    end
  end end
  local lean = poly{ { 142, 196 }, { 188, 192 }, { 188, 195 }, { 142, 199 } }
  rimOf(lean, L.roof2) part(lean, L.roof2, { nopop = true }) F.moss(lean, .2, 42)
  local axe = line({ { 186, 212 }, { 180, 202 } }) fill(axe, L.board.base) fill(rect(178, 200, 181, 203), L.iron.base) px(178, 200, L.iron.hi)
end
-- a chopping stump by the road with the axe bitten in, split billets and chips
do
  local x, yb, w = 194, 230, 6
  F.shadowM(c:ellipse(198, 231, 9, 1))
  local body = rect(x - w, yb - 7, x + w, yb)
  local top = c:ellipse(x, yb - 7, w, 2)
  rimOf(union(body, top), L.timber) part(body, L.timber, { nopop = true })
  body:each(function(xx, yy) if (xx - x) % 3 == 0 and hash(xx, yy // 2, 44) < .6 then px(xx, yy, L.timber.shade) end end)
  fill(top, L.board.base) px(x, yb - 7, L.board.shade) hline(x - 3, x - 1, yb - 8, L.board.hi)
  F.moss(body, .15, 45)
  -- axe: handle up and to the right, head bitten into the top
  line({ { x + 1, yb - 8 }, { x + 7, yb - 18 } }):each(function(xx, yy) px(xx, yy, L.board.base) px(xx + 1, yy, L.board.shade) end)
  fill(rect(x - 2, yb - 10, x + 2, yb - 8), L.iron.base) px(x - 2, yb - 10, L.iron.hi) px(x + 2, yb - 8, L.iron.deep)
  for _, s in ipairs({ { 178, 234 }, { 184, 238 }, { 200, 238 } }) do
    local m = poly{ { s[1], s[2] }, { s[1] + 5, s[2] - 2 }, { s[1] + 6, s[2] }, { s[1] + 1, s[2] + 2 } }
    rimOf(m, L.timber) fill(m, L.board.base) px(s[1] + 1, s[2], L.board.hi) px(s[1] + 5, s[2] - 1, L.timber.base)
  end
  for i = 0, 6 do px(184 + floor(hash(i, 1, 46) * 22), 229 + floor(hash(i, 2, 46) * 6), L.board.hi) end
end
-- a gnome rolling a barrel along toward the inn
do
  local _, hx, hy = F.gnome(176, 252, { hat = L.roof2, coat = L.accent, arm = "out", flip = true })
  local b = c:rrect(152, 240, 166, 254, 4)
  F.shadowM(c:ellipse(160, 255, 9, 1))
  rimOf(b, L.timber) part(b, L.timber)
  vline(155, 241, 253, L.iron.shade) vline(163, 241, 253, L.iron.shade) hline(153, 165, 246, L.timber.hi)
  for _, p in ipairs({ { 146, 250 }, { 144, 246 }, { 143, 253 } }) do px(p[1], p[2], L.needle.hi) end
end
-- crate of green bottles and a sack, bottom left
do
  F.crate(40, 256, 26, 12)
  for k = 0, 5 do
    local bx = 43 + k * 4
    local b = rect(bx, 238, bx + 2, 244):add(rect(bx + 1, 235, bx + 1, 237))
    c:rim(b, L.timber.edge) fill(b, L.leaf.shade) px(bx, 239, L.leaf.hi) px(bx + 1, 235, L.produce.base)
  end
  F.sack(86, 258, L.awnB, 7)
  F.sack(100, 262, L.board, 6)
  F.moss(F.rock(124, 262, 8, 6), .35, 43)
  F.fern(16, 238, 7) F.fern(24, 250, 8) F.fern(114, 250, 6) F.fern(70, 262, 6)
  F.mushroom(134, 256, L.apple, true) F.mushroom(138, 258, L.apple) F.mushroom(30, 262, L.needle, true)
end
-- a half-barrel tub of ferns and red bunchberries by the road
do
  local tub = c:rrect(210, 226, 228, 240, 3)
  F.shadowM(c:ellipse(222, 241, 10, 1))
  rimOf(tub, L.timber) part(tub, L.timber) hline(210, 228, 230, L.iron.shade) hline(210, 228, 237, L.iron.shade)
  for _, f in ipairs({ { 214, 227, 6 }, { 219, 226, 8 }, { 224, 227, 6 } }) do F.fern(f[1], f[2], f[3]) end
  for i = 0, 7 do local fx, fy = 211 + floor(hash(i, 1, 5) * 16), 220 + floor(hash(i, 2, 5) * 6) px(fx, fy, L.apple.base) px(fx + 1, fy, L.apple.hi) end
end

-- hens pecking at crumbs dropped from the table
F.depth(3)
F.hen(318, 252, L.awnB) F.hen(342, 258, L.soil, true) F.hen(360, 246, L.awnB, true)
for _, g in ipairs({ { 326, 254 }, { 332, 256 }, { 336, 251 }, { 350, 255 }, { 329, 250 } }) do px(g[1], g[2], L.produce.hi) end
-- a spare cart wheel leaning on the barrels
do local w = c:ellipse(290, 214, 7, 8) rimOf(w, L.timber) part(w, L.timber, { nopop = true })
  fill(c:ellipse(290, 214, 4, 5), L.ground.shade) vline(290, 207, 221, L.timber.deep) hline(284, 296, 214, L.timber.deep) fill(rect(289, 213, 291, 215), L.iron.base) end
-- ferns and young spruces on the right, around the garden (clear of the compass corner)
F.conifer(448, 226, 26, L.foliage, 53)
for _, f in ipairs({ { 304, 262, 8 }, { 290, 250, 6 }, { 374, 262, 7 }, { 432, 222, 6 }, { 466, 214, 7 }, { 284, 236, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.mushroom(300, 240, L.apple, true) F.mushroom(304, 242, L.apple) F.mushroom(368, 252, L.needle, true)
-- a goat tied to the hitching rail, chewing the rope
F.depth(3)
F.sprite({
  "...h.h..............",
  "..hWhW..............",
  ".WWWWWW.............",
  "WkWWWWWw............",
  "WWWWWWWWWWWWWWWw..t.",
  ".pWWw.WWWWWWWWWWWtt.",
  "..bb..WWWWWWWWWWWw..",
  "..b...WWwWWWWWWwWw..",
  "......sWwwwwwwwwws..",
  "......sWw.....wWs...",
  "......sw......ws....",
  "......ss......ss....",
  "......oo......oo....",
}, 106, 214, { W = L.awnB.hi, w = L.awnB.base, s = L.awnB.shade, h = L.timber.hi, k = L.timber.edge, p = "#f2a0a0", b = L.awnB.shade, t = L.awnB.shade, o = L.timber.deep })
-- a few grey patches on the goat
for _, p in ipairs({ { 116, 219 }, { 117, 219 }, { 118, 220 }, { 122, 221 }, { 123, 221 } }) do px(p[1], p[2], L.birch.shade) end
for x = 100, 106 do px(x, 218 + (x - 100) // 3, L.board.deep) end
F.shadowM(c:ellipse(118, 228, 10, 1))
-- the dog asleep under the table between the legs
F.sprite({
  "....bb..........",
  "...bBBb.....bb..",
  "..bBkBBBBBBBBBb.",
  "dbBBBBBBBBBBBBBb",
  ".dddBBbbBBBBbbBt",
  "...ddd..ddddd.tt",
}, 364, 217, { b = L.soil.base, B = L.soil.hi, d = L.soil.shade, k = L.timber.edge, t = L.soil.shade })

F.depth(0)
F.birds({ { 330, 52, 2 }, { 342, 46, 1 }, { 120, 52, 2 }, { 380, 78, 2 } })
F.finish()
