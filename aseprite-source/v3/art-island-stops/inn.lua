-- inn.lua : "Inn" stop look, ISLAND (island_palm), 480x270 gate view.
-- Same composition as the Maplewold inn (art-2701-batch4/stops/opus3/inn.lua), re-cast for a coral island:
-- left hero: a big palm-thatched beach inn on palm-trunk stilts. A shaggy hipped thatch roof with two gablets,
-- crossed ridge horns and a coral-stone kitchen chimney; a woven pandanus upper floor with turquoise prop-shutters,
-- a shell-bead curtain in the door and a bamboo veranda; under the floor, in the shade between the stilts, a beach
-- bar with glowing glass-float lanterns, a barkeep, bottles and coconut drinks, a striped hammock with a dozing gnome
-- and bougainvillea climbing the corner stilt. A bamboo stair comes down to the innkeeper. A driftwood gallows post
-- by the road hangs the board: a coconut drink with a straw and a pink paper umbrella. Right: a beach garden under
-- two coconut palms with a hammock slung between them, glass-float lantern festoons, rum barrels, a bamboo trestle
-- table with three gnomes raising coconut drinks, a waiter with a tray of them. Road's end: an A-frame thatch canoe
-- house with an outrigger nose showing. Back right: a stilt hut. A coconut cart with a black island pig; a goat
-- chews the tether at the driftwood rail beside an old dugout canoe used as a drinks cooler; a fish grill smokes.
-- Quirk: a monkey in a red gnome hat asleep on top of the inn sign, tail curling down over the drink, "z z" rising.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-island-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "inn", out = DIR, farTrees = { 24, 52, 150, 330, 352, 440 },
  clouds = { { 150, 40, 44 }, { 312, 30, 50 }, { 420, 62, 30 }, { 226, 74, 20 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local mix, rp = F.mix, F.rp

-- local ramps (defined here, not in the shared frame)
local bougain = rp("#ffbce0 #f070b8 #c84892 #963272 #5c1e48")      -- bougainvillea magenta
local shadeB = rp("#a08c66 #84704e #6a583e #50422f #382c22")       -- bamboo in the deep shade under the floor
local pig = rp("#8a7c80 #5e5258 #463c44 #302a32 #1e1a22")          -- black island pig
local mango = rp("#ffe08a #ffc04a #f29a2e #c46e26 #7c4220")

-- small local helpers -----------------------------------------------------------------------------
-- pandanus weave: alternating 3x3 cells of horizontal and vertical strips
local function weave(m, r, seed)
  m:each(function(x, y)
    local k = ((x // 3) + (y // 3)) % 2
    local h = r.base
    if k == 0 then if y % 3 == 2 then h = r.shade elseif y % 3 == 0 then h = r.hi end
    else if x % 3 == 2 then h = r.shade elseif x % 3 == 0 and hash(x, y, seed or 3) < .5 then h = r.hi end end
    if hash(x // 3, y // 3, (seed or 3) + 1) < .06 then h = r.deep end
    px(x, y, h)
  end)
end
-- a drinking coconut, (x, y) = bottom-left like the Maplewold mugAt: husk, cut top with white flesh, striped straw,
-- sometimes a paper umbrella
local function nutDrink(x, y, umb, green)
  local cr = green and L.foliage or L.coconut
  local body = c:ellipse(x + 2, y - 2, 3, 3):clip(rect(x - 2, y - 4, x + 6, y + 2))
  c:rim(body, L.timber.edge) fill(body, cr.base)
  body:each(function(xx, yy) if not body:has(xx + 1, yy + 1) then px(xx, yy, cr.shade) end end)
  px(x, y - 3, cr.hi) px(x + 1, y - 3, cr.hi)
  hline(x, x + 4, y - 4, L.shell.hi) px(x + 2, y - 4, L.coral.base)
  for k = 0, 4 do px(x + 3 + (k > 2 and 1 or 0), y - 5 - k, (k % 2 == 0) and L.awnA.base or L.awnB.hi) end
  if umb then
    local u = umb == true and L.petal or umb
    hline(x - 1, x + 3, y - 8, u.base) hline(x, x + 2, y - 9, u.hi) px(x + 1, y - 10, u.hi) px(x - 1, y - 8, u.shade) px(x + 3, y - 8, u.shade)
    vline(x + 1, y - 7, y - 5, L.board.base)
  end
end
-- a glass fishing-float lantern in a rope net, glowing (r = glass ramp)
local function floatLamp(x, y, r)
  local m = c:ellipse(x, y, 2, 2)
  c:rim(m, L.timber.edge) fill(m, r.base)
  px(x - 1, y - 1, r.hi) px(x, y - 1, r.hi) px(x + 1, y + 1, r.shade) px(x + 1, y, r.shade)
  px(x, y, L.glow.hi)
  hline(x - 2, x + 2, y, L.rope.shade) px(x, y, L.glow.hi)
  px(x, y - 3, L.rope.deep)
end
local function festoon(x0, y0, x1, y1, sag, step, startI)
  local function ly(x) local t = (x - x0) / (x1 - x0) return floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + .5) end
  for x = x0, x1 do px(x, ly(x), L.rope.deep) end
  local cols = { L.glow, L.accent, L.petal, L.seagrass, L.hibiscus }
  local i = startI or 0
  for x = x0 + 7, x1 - 5, step do
    i = i + 1
    local y = ly(x)
    vline(x, y + 1, y + 1, L.rope.deep)
    floatLamp(x, y + 4, cols[i % #cols + 1])
  end
end

---------------------------------------------------------------- back row: canoe house at the road's end, a stilt hut
F.depth(1)
F.tree(304, 128, 36, 0)
F.tree(232, 126, 30, 2)
do -- A-frame thatch canoe house with an outrigger nose showing
  local roofA = poly{ { 240, 129 }, { 269, 92 }, { 298, 129 } }
  local front = poly{ { 254, 128 }, { 269, 108 }, { 284, 128 } }
  local horns = line({ { 269, 93 }, { 263, 85 }, { 260, 84 } }, 1):add(line({ { 269, 93 }, { 275, 85 }, { 278, 84 } }, 1))
  F.shadow(244, 298, 129, 6, 2)
  rimOf(union(roofA, horns), L.timber)
  part(roofA, L.roof) F.thatch(roofA, L.roof, 92, 269)
  line({ { 241, 128 }, { 268, 93 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  part(horns, L.timber, { nopop = true, noshade = true })
  -- dark open gable with the canoe inside
  fill(front, L.soil.deep)
  front:edge():each(function(x, y) px(x, y, L.timber.base) end)
  local hull = poly{ { 258, 125 }, { 278, 125 }, { 284, 121 }, { 280, 127 }, { 260, 127 } }
  fill(hull, L.timber.hi) hline(259, 279, 125, L.awnA.base) px(283, 121, L.timber.hi) px(284, 120, L.timber.base)
  hline(262, 276, 127, L.timber.shade)
  -- a fishing net drying on the right slope, floats along it
  local nm = poly{ { 284, 112 }, { 292, 122 }, { 288, 127 }, { 281, 117 } }
  F.net(nm, L.rope)
  for _, p in ipairs({ { 285, 113 }, { 289, 118 }, { 292, 123 } }) do px(p[1], p[2], L.hibiscus.base) end
end
do -- a little bamboo hut on stilts, back right
  local top, _, hwall, hroof = F.building{ x0 = 418, x1 = 452, yb = 120, wh = 11, rh = 11, wall = L.board, roof = L.roof, noFrame = true, noAttic = true, noShadow = true }
  F.bamboo(hwall:copy():clip(rect(418, top + 4, 452, 120)), L.board, 3)
  F.window(426, 112, 430, 115, L.timber)
  local st = rect(420, 121, 421, 127):add(rect(434, 121, 435, 127)):add(rect(449, 121, 450, 127)):add(rect(416, 120, 454, 121))
  rimOf(st, L.timber) part(st, L.timber, { nopop = true, noshade = true })
  local ladder = line({ { 440, 121 }, { 444, 128 } }) ladder:each(function(x, y) px(x, y, L.board.shade) end)
  F.smoke(458, 112, 4, .5, 2)
end
F.fenceP(304, 133, 410, 130, 10)
-- a washing line of pareos and a towel from the canoe house
do local wp = rect(318, 110, 319, 131) rimOf(wp, L.timber) part(wp, L.timber, { nopop = true, noshade = true }) end
F.washing(293, 112, 318, 111, { { "sheet", L.petal }, { "shirt", L.accent }, { "sheet", L.hibiscus } }, 3)

---------------------------------------------------------------- mid right: palm + banana, coconut cart, the pig
F.depth(2)
F.tree(352, 152, 52, 2)
F.tree(326, 142, 40, 1)
F.palm(388, 156, 46, L.foliage, 14, { lean = 8 })
local function nutCart(x0, yb)
  local bed = poly{ { x0, yb - 12 }, { x0 + 46, yb - 12 }, { x0 + 44, yb - 6 }, { x0 + 2, yb - 6 } }
  local heap = c:ellipse(x0 + 23, yb - 14, 22, 7):clip(rect(x0 - 4, yb - 30, x0 + 50, yb - 11))
  local shaft = line({ { x0, yb - 9 }, { x0 - 16, yb - 3 } }, 2)
  rimOf(union(bed, heap, shaft), L.timber)
  part(shaft, L.timber, { nopop = true, noshade = true })
  part(bed, L.board) F.bamboo(bed, L.board, 3, { horizontal = true })
  fill(heap, L.coconut.deep)
  -- a heap of coconuts, brown and green, lit from the upper left
  for row = 0, 2 do
    for k = 0, 8 - row * 2 do
      local nx, ny = x0 + 5 + row * 5 + k * 5, yb - 14 - row * 4
      if heap:has(nx, ny) then
        local green = hash(k, row, 83) < .4
        local cr = green and L.foliage or L.coconut
        local n = c:ellipse(nx, ny, 2, 2)
        n:each(function(x, y) if heap:has(x, y) then px(x, y, (x < nx and y < ny + 1) and cr.hi or ((x > nx or y > ny) and cr.shade or cr.base)) end end)
        px(nx + 1, ny + 1, cr.deep)
      end
    end
  end
  -- a pineapple riding on top
  local pa = c:ellipse(x0 + 30, yb - 24, 2, 3)
  rimOf(pa, L.gold) fill(pa, L.gold.base) px(x0 + 29, yb - 25, L.gold.hi) px(x0 + 31, yb - 23, L.gold.shade) px(x0 + 30, yb - 24, L.gold.deep)
  for _, d in ipairs({ { -1, -4 }, { 0, -5 }, { 1, -4 }, { 0, -6 }, { -2, -5 }, { 2, -5 } }) do px(x0 + 30 + d[1], yb - 24 + d[2], L.foliage.shade) end
  for _, wx in ipairs({ x0 + 9, x0 + 37 }) do
    local w = c:ellipse(wx, yb - 4, 6, 6)
    rimOf(w, L.timber) part(w, L.timber, { nopop = true })
    fill(c:ellipse(wx, yb - 4, 3, 3), L.timber.shade)
    vline(wx, yb - 9, yb + 1, L.timber.deep) hline(wx - 5, wx + 5, yb - 4, L.timber.deep) px(wx, yb - 4, L.iron.hi)
  end
end
F.shadow(300, 350, 166, 8, 3)
nutCart(302, 166)
-- a black island pig nosing a fallen coconut
F.shadowM(c:ellipse(364, 167, 10, 1))
F.sprite({
  "..........ee....",
  ".....BBBBBBeBB..",
  "...BBBBBBBBBBBB.",
  ".tBBBBBBBBBBBBBB",
  "..BBBBBBBBBBkBBs",
  "..dBBBBBBBBBBBpp",
  "...dBdddddBdB.pp",
  "...dd.....dd....",
  "...ff.....ff....",
}, 350, 157, { B = pig.base, d = pig.shade, e = pig.deep, k = L.timber.edge, s = pig.hi, p = "#d8a0a0", t = pig.shade, f = pig.deep })
for x = 352, 364 do if hash(x, 158, 3) < .5 then px(x, 158, pig.hi) end end
F.coconut(370, 164, 2)

---------------------------------------------------------------- palms standing behind the inn
F.depth(2)
F.palm(54, 142, 104, L.foliage, 6, { lean = -18, dead = true })
F.palm(178, 142, 86, L.foliage2, 9, { lean = 14 })

---------------------------------------------------------------- the inn (left hero): a palm-thatched beach inn on stilts
F.depth(3)
local function inn()
  local FL = 142                        -- veranda floor level
  local UX0, UX1, UTOP = 24, 190, 108   -- woven upper floor
  local YB = 182                        -- ground under the stilts
  local roof = poly{ { 10, 110 }, { 204, 110 }, { 180, 62 }, { 34, 62 } }
  local hem = HP.mask()
  for x = 10, 204 do local d = 1 + floor(hash(x // 2, 1, 51) * 3) + ((x % 5 == 0) and 1 or 0) hem:add(rect(x, 110, x, 110 + d)) end
  local ch = rect(150, 44, 159, 70)
  local horns = line({ { 36, 62 }, { 30, 54 }, { 26, 51 } }, 2):add(line({ { 178, 62 }, { 184, 54 }, { 188, 51 } }, 2))
  local dorm = {}
  for _, dx in ipairs({ 74, 140 }) do
    dorm[#dorm + 1] = { x = dx, m = poly{ { dx - 13, 98 }, { dx, 78 }, { dx + 13, 98 } }:add(rect(dx - 9, 91, dx + 9, 100)) }
  end
  local upper = rect(UX0, UTOP, UX1, FL - 5)
  local deck = rect(14, FL - 4, 200, FL + 1)
  local under = rect(24, FL + 2, 190, YB)
  local sil = union(roof, hem, ch, horns, upper, deck)
  F.shadow(26, 196, YB + 1, 16, 6)
  rimOf(sil, L.timber)
  -- kitchen chimney: coral stone with lava blocks and a cap
  part(ch, L.stone) F.courses(ch, 44, 4, 6, L.stone)
  ch:each(function(x, y) if hash(x // 3, y // 4, 52) < .14 and (y - 44) % 4 ~= 0 then px(x, y, L.lava.base) end end)
  fill(rect(149, 43, 160, 45), L.lava.shade) hline(149, 160, 43, L.lava.hi)
  F.smoke(154, 38, 8, .8, 3)
  -- under the floor: deep shade, a bamboo back screen, shelves of bottles in lantern light
  -- open between the right stilts: the beach seen through, in the floor's shadow (deeper near the floor)
  under:each(function(x, y)
    local k = .62 - (y - FL) / (YB - FL) * .28
    px(x, y, mix(F.groundAt(x, y), shadeB.edge, k))
  end)
  -- a woven screen closes only the bar bay at the left
  local scr = rect(24, FL + 2, 92, YB - 1)
  fill(scr, shadeB.deep) F.bamboo(scr, shadeB, 3)
  for _, y in ipairs({ FL + 14, YB - 9 }) do hline(24, 92, y, shadeB.edge) hline(24, 92, y + 1, shadeB.base) end
  under:each(function(x, y) if y <= FL + 5 then px(x, y, shadeB.edge) elseif y <= FL + 7 and hash(x, y, 53) < .5 then px(x, y, shadeB.edge) end end)
  -- floor joists showing
  for x = 26, 188, 9 do fill(rect(x, FL + 2, x + 2, FL + 4), L.timber.shade) px(x, FL + 2, L.timber.base) end
  -- sand floor under the house, in shadow
  for x = 24, 190 do for y = YB - 3, YB do px(x, y, hash(x, y, 54) < .3 and L.ground.deep or L.ground.shade) end end
  -- the bar's back shelves (left bay)
  for _, sy in ipairs({ 152, 160 }) do
    hline(32, 88, sy, L.timber.base) hline(32, 88, sy + 1, L.timber.deep)
    for k = 0, 12 do
      local bx = 34 + k * 4 + (sy == 160 and 2 or 0)
      local v = hash(k, sy, 55)
      local br = v < .3 and L.seagrass or (v < .55 and L.produce or (v < .75 and L.accent or L.awnB))
      fill(rect(bx, sy - 4, bx + 1, sy - 1), br.shade) px(bx, sy - 4, br.base) px(bx, sy - 6, br.deep) px(bx, sy - 5, br.shade)
      px(bx, sy - 3, br.hi)
    end
  end
  -- a warm glow pool on the screen around the bar lanterns
  for _, lx in ipairs({ 44, 78 }) do
    under:each(function(x, y)
      local d = ((x - lx) / 13) ^ 2 + ((y - 152) / 9) ^ 2
      if d < 1 and y > FL + 6 and y < 164 and hash(x, y, 56) < (1 - d) * .55 then
        local v = c:get(x, y)
        if v == shadeB.deep or v == shadeB.shade or v == shadeB.base then px(x, y, d < .4 and L.glow.deep or shadeB.hi) end
      end
    end)
  end
  -- roof: shaggy palm thatch, combed courses, a woven ridge cap, darker right hip, lit left hip
  part(roof, L.roof, { band = 3 })
  F.thatch(roof, L.roof, 62, 9999)
  roof:each(function(x, y)
    if y <= 66 then px(x, y, ((x // 3) % 2 == 0) and L.rope.base or L.rope.shade) if y == 66 then px(x, y, L.roof.deep) end end
    local lx = 34 - (y - 62) * 24 / 48
    local rx = 180 + (y - 62) * 24 / 48
    if x > rx - 14 and hash(x, y, 9) < .7 then px(x, y, ((y - 62) % 4 == 3) and L.roof.edge or L.roof.deep) end
    if x < lx + 7 and (y - 62) % 4 ~= 3 and hash(x, y, 10) < .5 then px(x, y, L.roof.hi) end
    -- long frond-rib strands combed down the slope
    if y > 68 and (x * 3 + floor(y * .4)) % 17 == 0 and hash(x, y // 6, 11) < .6 then px(x, y, L.roof.shade) end
  end)
  hline(34, 180, 62, L.rope.hi)
  for x = 36, 178, 6 do vline(x, 62, 66, L.rope.deep) end -- lashings on the ridge cap
  -- the hem: ragged dry frond ends hanging past the eave
  hem:each(function(x, y) px(x, y, (y > 111 and hash(x, y, 57) < .5) and L.roof.deep or ((x % 3 == 0) and L.roof.shade or L.roof.base)) end)
  hline(10, 204, 110, L.roof.shade)
  -- sun-bleached patches and a few fresh green fronds laid on as repairs
  for i, b in ipairs({ { 60, 100, 9 }, { 108, 88, 7 }, { 118, 104, 8 }, { 46, 80, 6 } }) do
    roof:each(function(x, y)
      local d = ((x - b[1]) / b[3]) ^ 2 + ((y - b[2]) / (b[3] * .6)) ^ 2
      if d < 1 and hash(x, y, 30 + i) < .8 and (y - 62) % 4 ~= 3 then px(x, y, (d < .5 and (x % 3 ~= 0)) and L.rope.hi or L.rope.base) end
    end)
  end
  F.frond(98, 70, .55, 22, .35, L.foliage, 501, { wide = .26 })
    -- crossed ridge horns, carved, with a shell tied on each tip
  part(horns, L.timber, { nopop = true, noshade = true })
  line({ { 36, 61 }, { 30, 53 } }):each(function(x, y) px(x, y, L.timber.hi) end)
  F.shell(26, 50, "cowrie") F.shell(188, 50, "cowrie")
  -- a scarlet macaw on the ridge (where the Maplewold pigeon sat)
  F.parrot(118, 51, "macaw")
  -- gablets in the thatch: woven faces, a round glowing window
  for _, d in ipairs(dorm) do
    rimOf(d.m, L.roof)
    local wall = rect(d.x - 8, 91, d.x + 8, 100)
    part(d.m, L.roof, { nopop = true }) F.thatch(d.m, L.roof, 78, d.x)
    weave(wall, L.rope, d.x)
    local w = c:ellipse(d.x, 95, 3, 3)
    c:rim(w, L.timber.deep) fill(w, L.glow.base) px(d.x - 1, 94, L.glow.hi) px(d.x + 1, 96, L.glow.shade) vline(d.x, 92, 98, L.timber.base)
    line({ { d.x - 13, 98 }, { d.x, 78 } }):each(function(x, y) px(x, y, L.roof.hi) end)
    line({ { d.x + 13, 98 }, { d.x, 78 } }):each(function(x, y) px(x, y, L.roof.deep) end)
    for k = -12, 12, 3 do px(d.x + k, 99 + (k % 2), L.roof.deep) end
  end
  -- upper floor: pandanus weave between bamboo posts, eave shadow along the top
  weave(upper, L.rope, 7)
  upper:each(function(x, y) if y <= UTOP + 3 then px(x, y, (y == UTOP + 3 and hash(x, y, 58) < .5) and L.rope.shade or L.rope.deep) end end)
  local posts = union(rect(UX0, UTOP, UX1, UTOP + 1))
  for _, bx in ipairs({ UX0, 48, 88, 124, 164, UX1 - 1 }) do posts:add(rect(bx, UTOP, bx + 1, FL - 5)) end
  part(posts, L.board, { nopop = true, noshade = true })
  posts:each(function(x, y) if (y + x) % 7 == 0 then px(x, y, L.board.shade) end end)
  -- windows with turquoise top-hinged shutters propped open on sticks
  for _, wx in ipairs({ 36, 66, 146, 176 }) do
    local op = rect(wx - 5, 117, wx + 5, 128)
    fill(op:grow(1), L.timber.deep) fill(op, L.glow.base)
    op:each(function(x, y) if y >= 125 or x >= wx + 4 then px(x, y, L.glow.shade) end end)
    px(wx - 4, 118, L.glow.hi) px(wx - 3, 118, L.glow.hi) px(wx - 4, 119, L.glow.hi)
    vline(wx, 117, 128, L.timber.base)
    hline(wx - 7, wx + 7, 129, L.board.hi) hline(wx - 7, wx + 7, 130, L.board.shade) -- sill
    local sh = poly{ { wx - 7, 116 }, { wx + 7, 116 }, { wx + 8, 111 }, { wx - 6, 111 } }
    c:rim(sh, L.wall2.edge) part(sh, L.wall2, { nopop = true })
    sh:each(function(x, y) if y % 2 == 0 then px(x, y, L.wall2.shade) end end)
    hline(wx - 6, wx + 7, 111, L.wall2.hi)
    line({ { wx + 5, 128 }, { wx + 7, 117 } }):each(function(x, y) px(x, y, L.timber.base) end) -- prop stick
  end
  -- a gnome at the left window, leaning on the sill with a coconut
  F.sprite({ "...rr..", "..rrr..", ".rrrrr.", "rrrrrrr", ".sssss.", ".sksks.", ".bbbbb.", "..bbb.." }, 33, 118,
    { r = L.leaf.base, s = L.skin.base, k = L.timber.edge, b = L.awnB.hi }, { rim = false })
  nutDrink(38, 129, true)
  -- the door: a shell-bead curtain in a glowing doorway, a carved fish board over it
  local door = rect(98, 113, 116, FL - 5)
  fill(door:grow(1), L.timber.deep) fill(door, L.glow.shade)
  fill(rect(99, 114, 107, FL - 6), L.glow.base)
  for x = 99, 115, 2 do for y = 114, FL - 8 do
    local v = (y + x // 2) % 3
    px(x, y, v == 0 and L.shell.hi or (v == 1 and L.coral.base or L.shell.base))
  end end
  local fb = rect(96, 109, 118, 112)
  rimOf(fb, L.timber) part(fb, L.timber, { nopop = true })
  F.sprite({ "...ccc..c", ".ccccccc.", "cecccccc.", ".ccccccc.", "...ccc..c" }, 102, 108, { c = L.wall2.base, e = L.timber.edge }, { rim = false })
  -- bamboo veranda: deck edge, a low rail, posts
  part(deck, L.board) F.bamboo(deck, L.board, 2, { horizontal = true })
  hline(14, 200, FL - 4, L.board.hi) hline(14, 200, FL + 1, L.timber.deep)
  local rail = rect(14, FL - 13, 96, FL - 12):add(rect(120, FL - 13, 200, FL - 12))
  for x = 16, 198, 12 do if x < 96 or x > 120 then rail:add(rect(x, FL - 13, x + 1, FL - 5)) end end
  rail:add(line({ { 16, FL - 9 }, { 96, FL - 9 } })):add(line({ { 120, FL - 9 }, { 200, FL - 9 } }))
  rimOf(rail, L.timber) part(rail, L.board, { nopop = true, noshade = true })
  rail:each(function(x, y) if (x + y) % 6 == 0 then px(x, y, L.board.deep) end end)
  hline(14, 96, FL - 13, L.board.hi) hline(120, 200, FL - 13, L.board.hi)
  -- glass-float lanterns hanging under the veranda edge
  local lc = { L.glow, L.accent, L.glow, L.petal, L.glow, L.seagrass }
  for i, lx in ipairs({ 32, 64, 92, 132, 154, 182 }) do vline(lx, FL + 2, FL + 4, L.rope.deep) floatLamp(lx, FL + 7, lc[i]) end
  -- palm-trunk stilts on black lava footings
  for _, sx in ipairs({ 24, 58, 92, 124, 158, 188 }) do
    local s = rect(sx, FL + 2, sx + 3, YB - 2)
    local foot = rect(sx - 2, YB - 4, sx + 5, YB + 1)
    rimOf(union(s, foot), L.timber)
    part(s, L.palmTrunk, { nopop = true })
    s:each(function(x, y) if (y + sx) % 3 == 0 then px(x, y, x == sx and L.palmTrunk.base or L.palmTrunk.deep) end end)
    part(foot, L.lava, { nopop = true }) hline(sx - 2, sx + 5, YB - 4, L.lava.hi) px(sx + 3, YB - 1, L.lava.deep)
  end
  -- the beach bar between the left stilts: bamboo front, driftwood top, coconut drinks waiting
  local _, bhx, bhy = F.gnome(62, 167, { hat = L.hibiscus, coat = L.wall2, arm = "out", noShadow = true })
  local front = rect(30, 166, 88, YB - 1)
  local top = rect(28, 162, 90, 165)
  rimOf(union(front, top), L.timber)
  part(front, L.board) F.bamboo(front, L.board, 3)
  hline(30, 88, 172, L.rope.base) hline(30, 88, 173, L.rope.shade) -- a lashing band
  for x = 31, 87, 4 do px(x, 172, L.rope.deep) end
  part(top, L.timber, { nopop = true }) hline(28, 90, 162, L.timber.hi) hline(28, 90, 165, L.timber.deep)
  nutDrink(34, 161, true) nutDrink(42, 161, false, true) nutDrink(80, 161, L.accent) nutDrink(48, 161)
  -- a cocktail shaker in the barkeep's hand
  fill(rect(bhx, bhy - 6, bhx + 2, bhy - 1), L.iron.base) px(bhx, bhy - 6, L.iron.hi) px(bhx + 2, bhy - 2, L.iron.deep)
  for _, p in ipairs({ { bhx + 4, bhy - 7 }, { bhx + 5, bhy - 9 }, { bhx + 3, bhy - 9 } }) do px(p[1], p[2], L.glow.hi) end
  -- bamboo stools in front of the bar
  for _, sx in ipairs({ 40, 58 }) do
    local st = rect(sx - 4, 184, sx + 4, 185):add(rect(sx - 3, 186, sx - 2, 193)):add(rect(sx + 2, 186, sx + 3, 193))
    F.shadowM(c:ellipse(sx + 2, 194, 5, 1))
    rimOf(st, L.timber) part(st, L.board, { nopop = true, noshade = true }) hline(sx - 4, sx + 4, 184, L.board.hi)
  end
  -- a striped hammock between the right stilts, a gnome dozing in it, red hat dangling over the edge
  do
    local x0, x1, ya = 161, 188, 147
    local function hy(x) local t = (x - x0) / (x1 - x0) return floor(ya + 26 * t * (1 - t) + .5) end
    local hm = HP.mask()
    for x = x0 + 3, x1 - 3 do for k = 0, 3 do hm:set(x, hy(x) + k) end end
    line({ { x0, ya }, { x0 + 3, hy(x0 + 3) } }):each(function(x, y) px(x, y, L.rope.base) end)
    line({ { x1, ya }, { x1 - 3, hy(x1 - 3) } }):each(function(x, y) px(x, y, L.rope.base) end)
    local body = c:ellipse(177, hy(177) - 1, 7, 3)
    local head = c:ellipse(168, hy(168) - 3, 3, 3)
    local hat = poly{ { 165, hy(166) - 4 }, { 166, hy(166) + 1 }, { 163, hy(164) + 7 }, { 160, hy(164) + 9 }, { 162, hy(164) + 2 } }
    local bt = rect(184, hy(184) - 4, 186, hy(184) - 1)
    rimOf(union(hm, body, head, hat, bt), L.timber)
    part(body, L.leaf, { nopop = true })
    fill(head, L.skin.base) px(167, hy(168) - 5, L.skin.hi)
    hline(167, 168, hy(168) - 3, L.timber.edge) px(170, hy(168) - 3, L.timber.edge) -- shut eyes
    local beard = poly{ { 168, hy(168) - 1 }, { 173, hy(172) - 6 }, { 174, hy(172) - 2 } }
    fill(beard, L.awnB.hi) px(172, hy(172) - 3, L.awnB.base)
    part(hat, L.awnA, { nopop = true }) px(164, hy(164) + 1, L.awnA.hi)
    fill(bt, L.timber.base) px(184, hy(184) - 4, L.timber.hi)
    hm:each(function(x, y)
      local band = (x - x0) // 3 % 3
      local r = band == 0 and L.awnA or (band == 1 and L.awnB or L.accent)
      px(x, y, (y >= hy(x) + 2) and r.shade or r.base)
    end)
    for x = x0 + 4, x1 - 4, 2 do px(x, hy(x) + 4, L.rope.base) end -- fringe
    px(178, hy(178) - 9, L.awnB.hi) px(179, hy(178) - 9, L.awnB.hi) px(178, hy(178) - 8, L.awnB.hi) px(179, hy(178) - 7, L.awnB.hi) px(180, hy(178) - 7, L.awnB.hi) -- a little z
  end
  -- bougainvillea climbing the left stilt and spilling over the veranda rail and the eave
  local function bloom(x, y, big)
    px(x, y, bougain.base) px(x - 1, y, bougain.hi) px(x + 1, y, bougain.shade) px(x, y + 1, bougain.shade) px(x, y - 1, bougain.hi)
    if big then px(x + 1, y - 1, bougain.base) px(x - 1, y + 1, bougain.base) px(x + 2, y, bougain.deep) end
  end
  for i = 0, 40 do
    local y = YB - 3 - i
    local x = 25 + floor(2 * sin(i * .45))
    px(x, y, L.timber.base)
    if i % 3 == 0 then px(x + 1, y, L.foliage2.base) px(x - 1, y - 1, L.foliage2.hi) end
    if i % 5 == 2 then bloom(x + 1, y, i > 20) end
  end
  for x = 12, 52 do
    local v = hash(x, 3, 59)
    if v < .75 then
      local y = FL - 6 + floor(hash(x, 4, 59) * 7)
      px(x, y, (v < .2) and L.foliage2.shade or L.foliage2.base)
      if v < .35 then bloom(x, y - 1, v < .15) end
    end
  end
  for x = 12, 34 do if hash(x, 5, 59) < .55 then local y = 108 + floor(hash(x, 6, 59) * 6) bloom(x, y, hash(x, 7, 59) < .4) end end
  -- a gnome on the veranda shaking out a striped mat over the rail, dust flying
  F.gnome(84, 137, { small = true, hat = L.foliage, coat = L.hibiscus, arm = "out" })
  local mat = rect(88, 129, 96, 150)
  c:rim(mat, L.timber.edge) fill(mat, L.rope.base)
  mat:each(function(x, y) local b = (y - 129) // 3 % 3 if b == 1 then px(x, y, L.wall2.base) elseif b == 2 then px(x, y, L.rope.shade) end if x == 96 then px(x, y, L.rope.deep) end end)
  for x = 88, 96, 2 do px(x, 151, L.rope.shade) end
  for _, p in ipairs({ { 99, 140 }, { 101, 136 }, { 100, 146 }, { 103, 142 }, { 98, 152 } }) do px(p[1], p[2], "#eedcc4") px(p[1] + 1, p[2], "#e2ccb0") end
  -- a lantern by the door
  vline(121, 112, 114, L.rope.deep)
  floatLamp(121, 117, L.glow)
  -- the bamboo stair down from the veranda
  local str = line({ { 120, FL + 1 }, { 136, YB + 4 } }, 2):add(line({ { 130, FL + 1 }, { 146, YB + 4 } }, 2))
  local treads = HP.mask()
  for y = FL + 5, YB + 2, 5 do
    local t = (y - FL) / (YB + 4 - FL)
    treads:add(rect(floor(120 + 16 * t), y, floor(131 + 16 * t), y + 1))
  end
  F.shadowM(poly{ { 136, YB + 3 }, { 148, YB + 3 }, { 156, YB + 6 }, { 144, YB + 6 } })
  rimOf(union(str, treads), L.timber)
  part(treads, L.board, { nopop = true, noshade = true })
  treads:each(function(x, y) if y % 5 == 0 then px(x, y, L.board.hi) end end)
  part(str, L.board, { nopop = true, noshade = true })
  str:each(function(x, y) if (x + y) % 5 == 0 then px(x, y, L.board.deep) end end)
end
inn()

-- the innkeeper at the stair foot, a coconut drink in hand
F.depth(3)
local _, ihx, ihy = F.gnome(132, 194, { hat = L.awnA, coat = L.petal, arm = "out" })
nutDrink(ihx, ihy, true)
-- the chalk board by the bar (stamp board): a chalk coconut drink and a fish
do
  local leg = line({ { 82, 198 }, { 86, 180 } }, 1):add(line({ { 96, 198 }, { 92, 180 } }, 1))
  local bd = rect(80, 178, 98, 192)
  rimOf(union(bd, leg), L.timber) part(leg, L.timber, { nopop = true, noshade = true })
  fill(bd, L.lava.deep) c:edgeIn(bd, L.timber.base)
  hline(80, 98, 178, L.timber.hi)
  local chalk, chalk2 = L.awnB.hi, L.awnB.shade
  for _, p in ipairs({ { 83, 185 }, { 84, 184 }, { 85, 184 }, { 86, 184 }, { 87, 185 }, { 83, 186 }, { 87, 186 }, { 84, 187 }, { 85, 187 }, { 86, 187 }, { 86, 183 }, { 87, 182 }, { 88, 181 } }) do px(p[1], p[2], chalk) end
  for _, p in ipairs({ { 90, 185 }, { 91, 184 }, { 92, 184 }, { 93, 184 }, { 94, 185 }, { 91, 186 }, { 92, 186 }, { 93, 186 }, { 95, 184 }, { 95, 186 } }) do px(p[1], p[2], chalk) end
  px(92, 185, chalk2) px(84, 189, chalk2) px(86, 189, chalk2) px(88, 189, chalk2) px(90, 189, chalk2) px(92, 189, chalk2) px(94, 189, chalk2)
  F.flower(97, 178, "hibiscus", true) -- a flower tucked in the frame corner
end

---------------------------------------------------------------- the driftwood gallows sign post and its coconut-drink board
F.depth(3)
local SX0, SX1, SY0, SY1 = 202, 240, 128, 152
do
  local post = rect(194, 96, 197, 196)
  local arm = rect(194, 96, 246, 99)
  local brace = line({ { 198, 118 }, { 218, 100 } }, 2)
  local foot = poly{ { 188, 198 }, { 189, 192 }, { 194, 190 }, { 200, 191 }, { 203, 198 } }
  F.shadowM(c:ellipse(204, 199, 12, 2))
  rimOf(union(post, arm, brace, foot), L.timber)
  part(post, L.timber, { nopop = true }) part(arm, L.timber, { nopop = true, noshade = true }) part(brace, L.timber, { nopop = true, noshade = true })
  post:each(function(x, y) if hash(x, y // 4, 37) < .18 then px(x, y, L.timber.shade) elseif hash(x, y // 3, 38) > .93 then px(x, y, L.timber.hi) end end)
  part(foot, L.lava, { nopop = true }) foot:each(function(x, y) if hash(x, y, 39) < .15 then px(x, y, L.lava.deep) end end) hline(190, 199, 191, L.lava.hi)
  hline(194, 246, 96, L.timber.hi)
  -- rope lashings at the joints, a conch finial on the arm end
  for _, p in ipairs({ { 194, 101 }, { 194, 103 }, { 196, 101 }, { 196, 103 } }) do px(p[1], p[2], L.rope.base) end
  local conch = poly{ { 243, 95 }, { 249, 95 }, { 248, 91 }, { 245, 89 }, { 243, 92 } }
  rimOf(conch, L.shell) part(conch, L.shell, { nopop = true }) px(244, 92, L.shell.hi) px(247, 93, L.petal.base) px(248, 94, L.petal.shade) px(246, 90, L.shell.hi)
  -- rope hangers
  for y = 100, SY0 - 1 do local h = (y % 3 == 0) and L.rope.shade or L.rope.base px(SX0 + 3, y, h) px(SX1 - 3, y, h) end
  -- the board: turquoise frame, cream field, a big coconut drink with a straw, a paper umbrella and a hibiscus
  local board = rect(SX0, SY0, SX1, SY1)
  rimOf(board, L.accent) part(board, L.accent, { nopop = true })
  local field = rect(SX0 + 3, SY0 + 3, SX1 - 3, SY1 - 3)
  fill(field, L.plaster.hi) field:each(function(x, y) if hash(x, y, 6) < .06 then px(x, y, L.plaster.base) end end)
  hline(SX0, SX1, SY0, L.accent.hi) vline(SX0, SY0, SY1, L.accent.hi)
  for x = SX0 + 1, SX1 - 1, 3 do px(x, SY1 - 1, L.accent.deep) end -- a painted wave trim
  local nut = c:ellipse(218, 142, 9, 7):clip(rect(200, 138, 240, 150))
  local straw = line({ { 222, 139 }, { 230, 131 } }, 2)
  c:rim(union(nut, straw), L.timber.edge)
  part(nut, L.coconut, { nopop = true })
  nut:each(function(x, y) if (x + y * 2) % 7 == 0 and y > 140 then px(x, y, L.coconut.shade) end if x < 214 and y < 144 then px(x, y, L.coconut.hi) end end)
  hline(210, 226, 138, L.shell.hi) hline(211, 225, 139, L.coral.base) px(213, 139, L.coral.hi) px(214, 139, L.coral.hi)
  straw:each(function(x, y) px(x, y, ((x + y) // 2) % 2 == 0 and L.awnA.base or L.awnB.hi) end)
  -- the paper umbrella
  local umb = poly{ { 204, 136 }, { 216, 136 }, { 212, 132 }, { 208, 132 } }
  c:rim(umb, L.petal.edge) fill(umb, L.petal.base)
  umb:each(function(x, y) if (x - 204) % 3 == 0 then px(x, y, L.petal.shade) end if y == 132 then px(x, y, L.petal.hi) end end)
  vline(210, 137, 139, L.board.deep)
  F.flower(226, 139, "orange")
end
-- QUIRK: a monkey in a red gnome hat asleep on top of the board, tail curling down over the drink
do
  local by = SY0 - 1
  local M = L.soil
  local body = c:ellipse(227, by - 5, 12, 5):clip(rect(200, by - 14, 245, by))
  local head = c:ellipse(210, by - 6, 6, 6):clip(rect(196, by - 14, 222, by))
  local earL, earR = c:ellipse(203, by - 6, 2, 2), c:ellipse(217, by - 7, 2, 2)
  local hat = poly{ { 203, by - 10 }, { 217, by - 10 }, { 213, by - 15 }, { 208, by - 20 }, { 200, by - 21 }, { 203, by - 16 } }
  local tail = line({ { 238, by - 2 }, { 243, by + 4 }, { 242, by + 12 }, { 238, by + 17 }, { 234, by + 16 }, { 235, by + 13 } }, 2)
  local armD = line({ { 220, by - 1 }, { 221, by + 7 } }, 2)
  local monkey = union(body, head, earL, earR, hat, tail, armD)
  c:rim(monkey, L.timber.edge)
  part(union(body, tail, armD), M, { nopop = true })
  body:each(function(x, y)
    if y <= by - 8 and hash(x, y, 3) < .5 then px(x, y, M.hi) end
    if y >= by - 1 then px(x, y, M.shade) end
    if (x * 2 + y) % 9 == 0 and y < by - 2 then px(x, y, M.shade) end
  end)
  tail:each(function(x, y) if y > by + 8 and x < 240 then px(x, y, M.shade) end end)
  part(head, M, { nopop = true })
  fill(earL, M.base) fill(earR, M.shade) px(203, by - 6, "#e8a898") px(217, by - 7, "#c88878")
  -- pale face mask with sleeping eyes and a little smile
  local face = c:ellipse(210, by - 4, 4, 3)
  fill(face, L.skin.base) px(208, by - 6, L.skin.hi) px(209, by - 6, L.skin.hi)
  hline(207, 208, by - 5, M.deep) hline(211, 212, by - 5, M.deep)
  px(209, by - 3, M.deep) px(210, by - 3, M.deep) px(208, by - 2, L.skin.shade) px(211, by - 2, L.skin.shade) hline(209, 210, by - 2, "#c86a64")
  -- the red gnome hat, tip flopped over to the left
  part(hat, L.awnA, { nopop = true })
  hat:each(function(x, y) if y <= by - 15 and x < 207 then px(x, y, L.awnA.hi) end end)
  hline(203, 217, by - 10, L.awnA.deep) hline(204, 216, by - 11, L.awnA.shade)
  -- the dangling arm holding a banana peel
  fill(rect(220, by + 7, 222, by + 8), L.skin.shade)
  F.sprite({ "y.y.y", "yyyyy", ".yyy.", "..g.." }, 219, by + 9, { y = L.gold.base, g = L.foliage.shade })
  px(219, by + 9, L.gold.hi) px(223, by + 9, L.gold.shade)
  local function zed(x, y, s)
    for i = 0, s do px(x + i, y, L.awnB.hi) px(x + i, y + s, L.awnB.hi) px(x + s - i, y + i, L.awnB.hi) end
  end
  zed(214, by - 28, 3) zed(220, by - 36, 4) zed(229, by - 45, 5)
end

---------------------------------------------------------------- beach garden (right): two palms, a hammock, festoons, table
F.depth(3)
F.shadowM(c:ellipse(436, 196, 30, 3))
local _, ptx1 = F.palm(412, 196, 104, L.foliage, 20, { lean = -12, dead = false })
local _, ptx2 = F.palm(462, 192, 84, L.foliage2, 22, { lean = 10 })
-- a striped hammock slung between the two trunks, a gnome lounging in it with a coconut
do
  local x0, x1, y0, y1 = 413, 461, 150, 152
  local function hy(x) local t = (x - x0) / (x1 - x0) return floor(y0 + (y1 - y0) * t + 22 * t * (1 - t) + .5) end
  local hm = HP.mask()
  for x = x0 + 5, x1 - 5 do for k = 0, 3 do hm:set(x, hy(x) + k) end end
  for _, r in ipairs({ { x0, x0 + 5 }, { x1, x1 - 5 } }) do line({ { r[1], (r[1] == x0) and y0 or y1 }, { r[2], hy(r[2]) } }):each(function(x, y) px(x, y, L.rope.base) end) end
  fill(rect(x0 - 1, y0 - 1, x0 + 1, y0), L.rope.shade) fill(rect(x1 - 1, y1 - 1, x1 + 1, y1), L.rope.shade)
  local body = c:ellipse(440, hy(440) - 2, 10, 3)
  local head = c:ellipse(426, hy(426) - 4, 3, 3)
  local hat = poly{ { 422, hy(426) - 6 }, { 430, hy(426) - 6 }, { 426, hy(426) - 12 }, { 420, hy(426) - 14 } }
  local feet = rect(452, hy(452) - 4, 455, hy(452) - 2)
  local arm = line({ { 434, hy(434) - 4 }, { 432, hy(434) - 9 } }, 2)
  local all = union(hm, body, head, hat, feet, arm)
  rimOf(all, L.timber)
  part(body, L.accent, { nopop = true }) part(arm, L.accent, { nopop = true, noshade = true })
  fill(head, L.skin.base) px(425, hy(426) - 5, L.timber.edge) px(428, hy(426) - 5, L.timber.edge)
  hline(424, 429, hy(426) - 2, L.awnB.hi) px(426, hy(426) - 1, L.awnB.base)
  part(hat, L.gold, { nopop = true }) hline(422, 430, hy(426) - 6, L.gold.deep)
  fill(feet, L.timber.base) px(452, hy(452) - 4, L.timber.hi)
  hm:each(function(x, y)
    local band = (x - x0) // 4 % 3
    local r = band == 0 and L.hibiscus or (band == 1 and L.awnB or L.wall2)
    px(x, y, (y >= hy(x) + 2) and r.shade or r.base)
  end)
  for x = x0 + 6, x1 - 6, 2 do px(x, hy(x) + 4, L.rope.base) end
  nutDrink(431, hy(434) - 10, L.accent, true)
end
-- glass-float lantern festoons: sign arm -> bamboo pole across the road, pole -> the palm
do
  local pole = rect(288, 116, 289, 196)
  rimOf(pole, L.timber) part(pole, L.board, { nopop = true, noshade = true })
  pole:each(function(x, y) if y % 7 == 0 then px(x, y, L.board.deep) end end)
  F.frond(289, 115, -2.3, 10, .4, L.foliage, 503, { wide = .3 })
  F.frond(289, 115, -.7, 9, .4, L.foliage, 504, { wide = .3 })
  festoon(289, 118, 410, 128, 3, 12, 0)
  festoon(246, 100, 288, 118, 4, 11, 2)
end
-- rum barrels and green coconuts against the pole
F.barrel(300, 206, L.timber, 12) F.barrel(312, 207, L.coconut, 12) F.barrel(306, 194, L.timber, 11)
F.sprite({ "RRR", "R.R", "RRR" }, 298, 199, { R = L.awnA.base }, { rim = false })
for k = 0, 2 do F.coconut(318 + k * 5, 210, 2, k ~= 1) end F.coconut(321, 206, 2, true)
-- two canoe paddles leaning on the barrels (where the Maplewold spare wheel leaned)
for i, p in ipairs({ { 282, 220, 292, 196 }, { 286, 221, 294, 199 } }) do
  local sh = line({ { p[1], p[2] }, { p[3], p[4] } })
  local blade = c:ellipse(p[1], p[2] - 2, 2, 5)
  rimOf(union(sh, blade), L.timber)
  sh:each(function(x, y) px(x, y, L.timber.base) end)
  fill(blade, i == 1 and L.awnA.base or L.wall2.base) px(p[1] - 1, p[2] - 3, i == 1 and L.awnA.hi or L.wall2.hi)
  hline(p[1] - 1, p[1] + 1, p[2] - 1, L.awnB.hi)
end
-- long bamboo trestle table, three gnomes behind it raising coconut drinks
do
  local g1 = { 338, 210, L.roof2, L.leaf, "up" }
  local g2 = { 366, 209, L.lav, L.wall2, "up" }
  local g3 = { 394, 210, L.leaf, L.awnA, "out" }
  for i, g in ipairs({ g1, g2, g3 }) do
    local _, hx, hy = F.gnome(g[1], g[2], { hat = g[3], coat = g[4], arm = g[5], flip = (i == 3), noShadow = true })
    nutDrink(hx - 2, hy, i == 2, i == 1)
  end
  for _, p in ipairs({ { 356, 186 }, { 352, 184 }, { 358, 182 } }) do px(p[1], p[2], L.awnB.hi) end
  local top = rect(322, 209, 414, 213)
  local legs = line({ { 326, 228 }, { 334, 214 } }, 2):add(line({ { 334, 228 }, { 326, 214 } }, 2))
    :add(line({ { 402, 228 }, { 410, 214 } }, 2)):add(line({ { 410, 228 }, { 402, 214 } }, 2)):add(line({ { 330, 221 }, { 406, 221 } }))
  local bench = rect(318, 224, 418, 226):add(rect(322, 227, 323, 231)):add(rect(413, 227, 414, 231))
  F.shadow(324, 414, 231, 10, 3)
  rimOf(union(top, legs, bench), L.timber)
  part(legs, L.board, { nopop = true, noshade = true }) legs:each(function(x, y) if (x + y) % 6 == 0 then px(x, y, L.board.deep) end end)
  part(bench, L.board, { nopop = true }) F.bamboo(bench, L.board, 3, { horizontal = true })
  part(top, L.board) F.bamboo(top, L.board, 2, { horizontal = true }) hline(322, 414, 209, L.board.hi) hline(322, 414, 213, L.board.deep)
  -- banana-leaf runner down the table
  for x = 326, 410 do if hash(x // 6, 1, 84) < .75 then px(x, 210, L.leaf.base) if x % 6 == 0 then px(x, 210, L.leaf.hi) end end end
  nutDrink(347, 208, true) nutDrink(380, 208, L.accent, true)
  -- a pineapple with its crown
  local pa = c:ellipse(362, 205, 3, 4)
  rimOf(pa, L.gold) fill(pa, L.gold.base)
  pa:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.gold.shade) elseif (x - y) % 3 == 0 then px(x, y, L.gold.deep) end if x < 361 and y < 205 then px(x, y, L.gold.hi) end end)
  F.sprite({ "g.g.g", ".ggg.", "..g.." }, 360, 197, { g = L.foliage.base })
  px(361, 197, L.foliage.hi) px(362, 199, L.foliage.shade)
  -- a grilled fish on a leaf platter
  local plate = c:ellipse(392, 207, 8, 1)
  fill(plate, L.leaf.shade) hline(385, 399, 206, L.leaf.base)
  F.sprite({ ".sss.t", "sksssst", ".ssss.t" }, 388, 203, { s = L.produce.shade, k = L.timber.edge, t = L.produce.deep })
  px(390, 203, L.produce.base) px(392, 203, L.produce.hi) px(394, 204, L.produce.deep) px(391, 205, L.produce.deep)
  -- a bowl of mango slices
  local bowl = c:ellipse(334, 207, 5, 2):clip(rect(328, 207, 340, 210))
  c:rim(bowl, L.coconut.edge) fill(bowl, L.coconut.base) hline(330, 338, 207, L.coconut.hi)
  for _, p in ipairs({ { 331, 205 }, { 333, 204 }, { 335, 205 }, { 337, 204 }, { 334, 206 } }) do px(p[1], p[2], mango.base) px(p[1] + 1, p[2], mango.hi) end
  px(332, 206, mango.shade) px(336, 206, mango.deep)
  -- a candle in a scallop shell
  fill(rect(371, 204, 372, 208), L.awnB.hi) px(371, 203, L.glow.hi) px(371, 202, L.glow.base) px(372, 204, L.awnB.base)
  hline(369, 374, 208, L.coral.base) px(369, 207, L.coral.hi) px(374, 207, L.coral.shade)
end
-- the waiter crossing the road with a tray of coconut drinks
F.depth(3)
do
  local _, hx, hy = F.gnome(268, 232, { hat = L.accent, coat = L.awnA, arm = "up", flip = true })
  local tray = rect(hx - 10, hy - 1, hx + 6, hy)
  rimOf(tray, L.timber) part(tray, L.board, { nopop = true, noshade = true })
  nutDrink(hx - 9, hy - 2, true) nutDrink(hx - 3, hy - 2, false, true) nutDrink(hx + 2, hy - 2, L.accent)
end

---------------------------------------------------------------- foreground left: dugout cooler, driftwood rail, fish grill, barrel roller
F.depth(3)
do -- driftwood hitching rail
  local rail = rect(22, 212, 104, 214):add(rect(26, 212, 28, 228)):add(rect(98, 212, 100, 228))
  rimOf(rail, L.timber) part(rail, L.timber, { nopop = true, noshade = true }) hline(22, 104, 212, L.timber.hi)
  rail:each(function(x, y) if y == 213 and hash(x // 4, 1, 85) < .25 then px(x, y, L.timber.shade) end end)
  fill(rect(40, 214, 41, 218), L.rope.shade)
  -- an old dugout canoe on chocks, used as a drinks cooler full of lagoon water, bottles and green coconuts
  F.shadow(32, 98, 234, 8, 3)
  local chocks = rect(40, 229, 46, 233):add(rect(82, 229, 88, 233))
  F.lavaRock(43, 234, 4, 5, 86) F.lavaRock(85, 234, 4, 5, 87)
  local hull = poly{ { 28, 216 }, { 34, 219 }, { 96, 219 }, { 102, 214 }, { 100, 222 }, { 92, 230 }, { 38, 230 } }
  rimOf(hull, L.timber) part(hull, L.timber)
  hull:each(function(x, y) if (y - 219) % 3 == 0 and hash(x // 5, y, 88) < .4 then px(x, y, L.timber.shade) end end)
  hline(36, 94, 224, L.awnA.base) hline(36, 94, 225, L.awnA.shade) -- painted stripe
  for x = 40, 92, 8 do px(x, 224, L.awnB.hi) px(x + 1, 225, L.awnB.base) end -- painted chevrons
  local w = rect(34, 219, 95, 221)
  fill(w, L.lagoon.base) hline(34, 95, 219, L.lagoon.hi) for x = 37, 93, 7 do px(x, 220, L.lagoon.hi) px(x + 1, 220, L.surf or "#f4fbf6") end
  hline(34, 96, 218, L.timber.hi)
  for k = 0, 6 do
    local bx = 40 + k * 8
    if k % 2 == 0 then
      local b = rect(bx, 214, bx + 1, 219):add(rect(bx, 212, bx, 213))
      c:rim(b, L.timber.edge) fill(b, k == 2 and L.produce.shade or L.seagrass.shade) px(bx, 215, k == 2 and L.produce.hi or L.seagrass.hi)
    else
      F.coconut(bx + 1, 218, 2, true)
    end
  end
end
do -- fish grill under a little palm-thatch lean-to by the stair
  local lean = poly{ { 140, 186 }, { 152, 176 }, { 190, 186 }, { 186, 191 }, { 144, 192 } }
  local posts = rect(145, 190, 146, 211):add(rect(184, 190, 185, 209))
  rimOf(union(lean, posts), L.timber)
  part(posts, L.board, { nopop = true, noshade = true })
  part(lean, L.roof, { nopop = true }) F.thatch(lean, L.roof, 183, 9999)
  line({ { 141, 186 }, { 152, 176 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  line({ { 153, 177 }, { 189, 186 } }):each(function(x, y) px(x, y, L.roof.shade) end)
  for x = 145, 187, 2 do local y = 191 + (x % 4 == 1 and 1 or 0) px(x, y, L.roof.deep) end
  -- lava-rock fire ring, glowing coals, a grate with three fish, a smoke column
  F.shadow(146, 186, 212, 6, 2)
  local ring = c:ellipse(165, 207, 15, 4)
  rimOf(ring, L.lava) part(ring, L.lava)
  ring:each(function(x, y) local v = hash(x // 3, y // 2, 89) if v < .3 then px(x, y, L.lava.hi) elseif v > .8 then px(x, y, L.lava.deep) end end)
  local coals = c:ellipse(165, 206, 11, 2)
  coals:each(function(x, y) local v = hash(x, y, 90) px(x, y, v < .3 and L.glow.base or (v < .6 and L.produce.base or (v < .85 and L.apple.shade or L.lava.shade))) end)
  hline(152, 178, 203, L.iron.shade) hline(152, 178, 201, L.iron.base)
  for x = 153, 177, 4 do vline(x, 201, 203, L.iron.deep) end
  for k = 0, 2 do
    local fx = 154 + k * 8
    local fr = k == 1 and L.coral or L.iron
    F.sprite({ "t..sss.", "ttssssk", "t..sss." }, fx - 1, 197, { s = fr.hi, k = L.timber.edge, t = fr.shade })
    px(fx + 2, 197, fr.base) px(fx + 3, 199, fr.base) px(fx + 4, 198, L.produce.deep) px(fx + 2, 198, L.produce.deep) -- grill marks
  end
  F.smoke(166, 192, 5, -.5, 2)
  -- coconut husks for fuel, piled at the side, and a pair of tongs
  for _, h in ipairs({ { 184, 210 }, { 189, 208 }, { 186, 205 }, { 181, 212 } }) do
    local m = c:ellipse(h[1], h[2], 3, 2) rimOf(m, L.needle) part(m, L.needle, { nopop = true }) px(h[1] - 1, h[2] - 1, L.needle.hi) px(h[1] + 1, h[2], L.needle.shade)
  end
  line({ { 147, 212 }, { 154, 205 } }):each(function(x, y) px(x, y, L.iron.base) end)
end
-- a gnome rolling a rum barrel toward the bar
do
  local _, hx, hy = F.gnome(176, 252, { hat = L.awnA, coat = L.accent, arm = "out", flip = true })
  local b = c:rrect(152, 240, 166, 254, 4)
  F.shadowM(c:ellipse(160, 255, 9, 1))
  rimOf(b, L.timber) part(b, L.coconut)
  vline(155, 241, 253, L.iron.shade) vline(163, 241, 253, L.iron.shade) hline(153, 165, 246, L.coconut.hi)
  for _, p in ipairs({ { 146, 250 }, { 144, 246 }, { 143, 253 } }) do px(p[1], p[2], L.ground.hi) end
end
-- crate of bottles, sacks, a lava rock, shells, bottom left
do
  F.crate(40, 256, 26, 12)
  for k = 0, 5 do
    local bx = 43 + k * 4
    local b = rect(bx, 238, bx + 2, 244):add(rect(bx + 1, 235, bx + 1, 237))
    local br = (k % 3 == 1) and L.produce or L.seagrass
    c:rim(b, L.timber.edge) fill(b, br.shade) px(bx, 239, br.hi) px(bx + 1, 235, L.awnB.base)
  end
  F.sack(86, 258, L.awnB, 7)
  F.sack(100, 262, L.rope, 6)
  F.lavaRock(124, 262, 8, 6, 91)
  F.shell(132, 264, "conch", true) F.shell(70, 266, "scallop", true) F.shell(112, 266, "cowrie")
  F.crab(140, 258, L.awnA)
  F.fern(16, 238, 7, L.seagrass) F.fern(24, 250, 8, L.seagrass) F.fern(114, 250, 6, L.seagrass)
  F.hibiscus(16, 264, 8, 12, 92)
end
-- a giant clam shell planted with plumeria by the road
do
  local clam = c:ellipse(219, 236, 10, 5):clip(rect(205, 232, 233, 242))
  F.shadowM(c:ellipse(223, 242, 11, 1))
  rimOf(clam, L.shell) part(clam, L.shell)
  clam:each(function(x, y) if (x - 219) % 4 == 0 then px(x, y, L.shell.shade) elseif (x - 219) % 4 == 1 then px(x, y, L.shell.hi) end end)
  for x = 209, 229, 2 do px(x, 232, L.shell.hi) px(x + 1, 231, L.shell.base) end -- wavy lip
  local lv = c:ellipse(219, 227, 10, 5)
  rimOf(lv, L.foliage2) part(lv, L.foliage2, { nopop = true })
  lv:each(function(x, y) if hash(x, y, 93) < .2 then px(x, y, L.foliage2.hi) end end)
  F.flower(213, 225, "plumeria") F.flower(220, 223, "plumeria") F.flower(226, 227, "white") F.flower(217, 229, "plumeria", true)
end

-- jungle fowl pecking at crumbs dropped from the table
F.depth(3)
F.hen(318, 252, L.hibiscus) F.hen(342, 258, L.coconut, true) F.hen(360, 246, L.gold, true)
for _, g in ipairs({ { 326, 254 }, { 332, 256 }, { 336, 251 }, { 350, 255 }, { 329, 250 } }) do px(g[1], g[2], L.board.hi) end
-- beach plants on the right around the garden (clear of the compass corner)
F.banana(446, 228, 30, 45)
F.hibiscus(470, 214, 7, 10, 46)
for _, f in ipairs({ { 304, 262, 8 }, { 290, 250, 6 }, { 374, 262, 7 }, { 432, 222, 6 }, { 284, 236, 5 } }) do F.fern(f[1], f[2], f[3], L.seagrass) end
F.shell(300, 242, "conch", true) F.shell(368, 254, "scallop") F.crab(310, 246, L.hibiscus, true)
-- a goat tied to the driftwood rail, chewing the rope
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
for _, p in ipairs({ { 116, 219 }, { 117, 219 }, { 118, 220 }, { 122, 221 }, { 123, 221 } }) do px(p[1], p[2], L.coconut.base) end
for x = 100, 106 do px(x, 218 + (x - 100) // 3, L.rope.deep) end
F.flower(108, 213, "hibiscus", true) -- a hibiscus behind the goat's ear
F.shadowM(c:ellipse(118, 228, 10, 1))
-- the black pig's piglet asleep under the table between the legs
F.sprite({
  "....bb..........",
  "...bBBb.....bb..",
  "..bBkBBBBBBBBBb.",
  "pbBBBBBBBBBBBBBb",
  ".dddBBbbBBBBbbBt",
  "...ddd..ddddd.tt",
}, 364, 217, { b = pig.shade, B = pig.base, d = pig.deep, k = L.timber.edge, t = pig.shade, p = "#d8a0a0" })
for x = 368, 376, 2 do px(x, 218, pig.hi) end

F.depth(0)
F.birds({ { 330, 52, 2 }, { 342, 46, 1 }, { 120, 30, 2 }, { 380, 84, 2, L.awnB.hi } })
F.finish()
