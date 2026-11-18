-- workshop.lua : "Workshop" stop look, MOUNTAIN (mountain_granite), 480x270 gate view.
-- Same composition as the Maplewold workshop (art-2701-batch3/stops/opus3/workshop.lua), re-cast as a stonemason's
-- and bell-founder's yard (the mill pilot already owns millstones and the stadel, so here: ashlar, chisels, bronze):
-- road's end: a stepped granite quarry face behind; the timber gantry crane hoisting a dressed granite block in a
-- chain sling over a yard of cut blocks, a winch hand at the drum. Back left: the mason's stone lodge with smoke,
-- stacks of paving slabs and ashlar. Back right: the bell pit: a clay bell mould, a little furnace tapping glowing
-- bronze down a clay runner, a finished bell on its frame. Left hero: a small forge under a lichened slab lean-to
-- (granite hood and chimney), cowbells hanging from the post and the eave, bellows, a Bernese dog asleep in the
-- warmth, the smith drawing a chisel point on the anvil, a granite quench trough. Right hero: the bell-founder's
-- workshop, whitewashed granite under larch boards and a weighted slab roof with a little bell-cote: open front with
-- a rack of graded cowbells on embroidered straps, a mason's tool wall (mallets, points, claw chisels, square,
-- dividers), a banker with a half-carved ibex head, the carver, a grindstone outside. Foreground: a pyramid of ashlar
-- blocks with a goat kid on top, a granite marmot being carved out of a raw block (gnome with mallet and chisel),
-- granite mortars, a crate of cowbells sniffed by a goat, a big bronze bell on a trestle, a gnome carrying cowbells
-- on a pole, a block with a sledgehammer, stone chips everywhere, edelweiss, gentian, junipers.
-- Quirk: a wallcreeper (crimson wings) has built its nest on the crane beam; three chicks gape, it brings a moth.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-mountain-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "workshop", out = DIR, farTrees = { 24, 52, 160, 330, 352, 440 },
  treeLineGap = { 176, 306 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, max, min = math.floor, math.sin, math.cos, math.pi, math.max, math.min
local IR, G, HZ = L.iron, L.glow, F.HZ
local BR = F.rp("#f6dc94 #d6a856 #aa7a3e #7c562e #4e3622") -- bell bronze
local ROSE = F.rp("#ecccc0 #c8a49a #a2807c #7a5c5e #4c3842") -- rose granite
local CLAY = F.rp("#d4a27a #b07a56 #8a5a42 #643e32 #3e2622") -- bell-mould loam

---------------------------------------------------------------- local helpers
-- a dressed granite block in oblique view: front face, lit top face, shaded right side; tooled (pointed) surface,
-- a drafted margin, a few lichen spots. w,h = front size; d = depth of the top/side.
local function block(x0, yb, w, h, d, r, seed)
  r = r or L.stone seed = seed or 1
  local dy = max(1, floor(d * .6 + .5))
  local front = rect(x0, yb - h, x0 + w, yb)
  local top, side = HP.mask(), HP.mask()
  for j = 1, dy do
    local o = floor(j * d / dy + .5)
    for x = x0 + o, x0 + w + o do top:set(x, yb - h - j) end
  end
  for k = 1, d do
    local o = floor(k * dy / d + .5)
    for y = yb - h - o, yb - o do side:set(x0 + w + k, y) end
  end
  side:cut(top)
  local all = union(front, top, side)
  rimOf(all, r)
  front:each(function(x, y)
    local v = hash(x, y, seed)
    local hh = v < .14 and r.shade or (v > .9 and r.hi or r.base)
    if y == yb - h or x == x0 then hh = r.hi end
    if x == x0 + w then hh = r.shade end
    if y == yb then hh = r.shade end
    px(x, y, hh)
  end)
  top:each(function(x, y) px(x, y, hash(x, y, seed + 1) < .18 and r.base or r.hi) end)
  side:each(function(x, y) px(x, y, hash(x, y, seed + 2) < .2 and r.deep or r.shade) end)
  if w > 8 and h > 5 then F.lichen(front, .1, seed + 3) end
  return front, top, side, all
end
-- stone chips: tiny lit flakes and grit
local function chips(x0, x1, y0, y1, n, seed)
  for i = 1, n do
    local x, y = x0 + floor(hash(i, 1, seed) * (x1 - x0)), y0 + floor(hash(i, 2, seed) * (y1 - y0))
    local v = hash(i, 3, seed)
    px(x, y, v < .4 and L.stone.hi or (v < .75 and L.stone.base or L.road.hi))
    if v < .5 then px(x + 1, y, L.stone.shade) end
  end
end
-- a cowbell: x centre, yt top of the bell body, s = half width at the mouth; r metal ramp; returns its mask
local function cowbell(x, yt, s, r)
  r = r or BR
  local h = max(3, floor(s * 1.7 + .5))
  local body = HP.mask()
  for y = yt, yt + h do
    local t = (y - yt) / h
    local hw = floor(s - 1 + t * 1.2 + .5)
    if y == yt then hw = max(1, s - 2) end
    for x = x - hw, x + hw do body:set(x, y) end
  end
  local loop = HP.mask():set(x - 1, yt - 1):set(x + 1, yt - 1):set(x, yt - 2):set(x - 1, yt - 2):set(x + 1, yt - 2)
  loop:set(x, yt - 1)
  rimOf(union(body, loop), r)
  body:each(function(xx, yy)
    local hw = s
    local u = (xx - x) / hw
    local hh = u < -.45 and r.hi or (u < .3 and r.base or (u < .75 and r.shade or r.deep))
    if yy == yt + h then hh = (u < -.3) and r.shade or r.deep end
    px(xx, yy, hh)
  end)
  if s >= 3 then hline(x - s + 2, x + s - 2, yt + 1, r.hi) px(x - s + 1, yt + h - 2, L.edel.base) end
  loop:each(function(xx, yy) px(xx, yy, IR.base) end) px(x - 1, yt - 2, IR.hi) px(x, yt - 1, IR.deep)
  if s >= 3 then px(x, yt + h + 1, IR.shade) end
  return body
end
-- an embroidered strap hanging from (x, y0) down to a bell top at yt
local function strap(x, y0, yt, r)
  r = r or L.awnA
  for y = y0, yt - 3 do px(x - 1, y, r.base) px(x, y, (y % 3 == 0) and L.awnB.hi or r.shade) px(x + 1, y, r.deep) end
end
-- a church bell: crown, waist, flared lip; s = half width at the lip
local function bigbell(x, yt, s, hgt, r)
  r = r or BR
  local m = HP.mask()
  for y = yt, yt + hgt do
    local t = (y - yt) / hgt
    local hw = s * (.48 + .2 * t + .32 * t ^ 6)
    if t < .1 then hw = hw - (1 - t / .1) * s * .18 end
    hw = floor(hw + .5)
    for xx = x - hw, x + hw do m:set(xx, y) end
  end
  local crown = rect(x - 2, yt - 3, x + 2, yt - 1)
  rimOf(union(m, crown), r)
  fill(crown, r.shade) px(x - 2, yt - 3, r.hi) hline(x - 1, x + 1, yt - 2, r.deep)
  local mid = yt + hgt // 2
  m:each(function(xx, yy)
    local t = (yy - yt) / hgt
    local hw = floor(s * (.48 + .2 * t + .32 * t ^ 6) + .5)
    local u = (xx - x) / max(1, hw)
    local hh = u < -.6 and r.hi or (u < .05 and r.base or (u < .62 and r.shade or r.deep))
    if u > -.5 and u < -.3 and t > .15 and t < .8 then hh = r.hi end
    px(xx, yy, hh)
  end)
  -- inscription band and the sound-bow ridges
  local yb1, yb2 = yt + floor(hgt * .3), yt + floor(hgt * .82)
  for _, yy in ipairs({ yb1, yb1 + 2, yb2 }) do
    m:each(function(xx, y2) if y2 == yy then px(xx, y2, ((xx - x) < -s * .3) and r.base or r.deep) end end)
  end
  m:each(function(xx, y2) if y2 == yb1 + 1 and (xx % 2 == 0) then px(xx, y2, r.hi) end end)
  m:each(function(xx, y2) if y2 == yt + hgt then px(xx, y2, r.deep) end end)
  px(x, yt + hgt + 1, IR.shade) px(x, yt + hgt + 2, IR.deep)
  return m
end

---------------------------------------------------------------- behind the tree line: the stepped granite quarry
F.depth(0)
do
  local function hz(h) return F.mix(h, L.sky[4], .07) end
  local P, S = L.peak, L.stone
  local q = poly{ { 176, HZ + 2 }, { 182, 98 }, { 190, 88 }, { 204, 80 }, { 222, 76 }, { 246, 74 }, { 266, 77 }, { 282, 84 }, { 296, 94 }, { 306, HZ + 2 } }
  q:each(function(x, y)
    local v = F.vnoise(x / 5, y / 4, 7)
    local h = v < .25 and P.hi or (v < .6 and P.base or P.shade)
    if x > 262 + (y - 76) * .6 then h = (v < .5) and P.shade or P.deep end
    if v < .1 then h = P.deep end
    if not q:has(x, y - 1) then h = L.snow.base end
    px(x, y, hz(h))
  end)
  -- cracks / joints in the natural rock
  for _, cr in ipairs({ { { 186, 96 }, { 190, 106 } }, { { 286, 90 }, { 292, 104 } }, { { 210, 80 }, { 206, 86 } } }) do
    line(cr):each(function(x, y) px(x, y, hz(P.deep)) end)
  end
  -- three benches cut into the face: lit ledge, fresh pale face with drill-hole lines, a shadow under each ledge
  local benches = { { 84, 208, 270 }, { 93, 200, 280 }, { 102, 192, 290 } }
  for i, b in ipairs(benches) do
    local by, x0, x1 = b[1], b[2], b[3]
    local yN = benches[i + 1] and benches[i + 1][1] - 1 or HZ + 1
    for y = by + 1, yN do for x = x0, x1 do
      if q:has(x, y) then
        local v = hash(x // 3, y // 2, 11 + i)
        local h = v < .3 and S.hi or (v < .8 and S.base or S.shade)
        if x - x0 < 2 then h = S.hi end
        if x1 - x < 3 then h = S.shade end
        if y == by + 1 then h = P.deep end
        if (x - x0) % 6 == 3 and y > by + 2 and y < by + 6 and y % 2 == 0 then h = S.deep end -- drill holes
        px(x, y, hz(h))
      end
    end end
    for x = x0 - 1, x1 + 1 do if q:has(x, by) then px(x, by, hz(S.hi)) end end
  end
  -- a block half lifted out of the top bench, and spoil scree at the foot
  local cut = rect(232, 86, 246, 92) fill(cut, hz(P.deep)) hline(232, 246, 92, hz(S.shade))
  for i = 0, 40 do
    local x = 178 + floor(hash(i, 1, 13) * 126) local y = HZ - floor(hash(i, 2, 13) * 4)
    if q:has(x, y) then px(x, y, hz(i % 3 == 0 and S.hi or S.shade)) px(x + 1, y, hz(S.base)) end
  end
  F.goat(276, 102, { k = .38, flip = true, noShadow = true })
end

---------------------------------------------------------------- road's end: block yard + gantry crane
F.depth(2)
F.tree(186, 128, 54, 2)
F.tree(300, 128, 50, 1)
local function crane()
  -- yard: cut blocks waiting their turn
  block(204, 126, 13, 7, 4, nil, 3) block(219, 126, 10, 6, 3, nil, 4) block(208, 118, 10, 6, 3, ROSE, 5)
  block(244, 124, 14, 8, 4, ROSE, 6) block(262, 125, 9, 6, 3, nil, 7) block(248, 115, 12, 6, 3, nil, 8)
  local legL = line({ { 200, 126 }, { 210, 54 } }, 3):add(line({ { 220, 126 }, { 212, 54 } }, 2))
  local legR = line({ { 284, 126 }, { 274, 54 } }, 3):add(line({ { 264, 126 }, { 272, 54 } }, 2))
  local beam = rect(198, 50, 290, 55)
  local brace = line({ { 213, 70 }, { 228, 56 } }, 2):add(line({ { 271, 70 }, { 256, 56 } }, 2))
  F.shadow(200, 286, 127, 8, 3)
  rimOf(union(legL, legR, beam, brace), L.timber)
  part(legL, L.timber, { nopop = true }) part(legR, L.timber, { nopop = true }) part(brace, L.timber, { nopop = true, noshade = true })
  part(beam, L.timber) hline(198, 290, 50, L.timber.hi)
  F.logs(beam, L.timber, 50, 6)
  F.logEnd(198, 52, 2) F.logEnd(290, 52, 2)
  -- sun-scorched larch: darker grain on the beam, granite footing stones under the legs
  beam:each(function(x, y) if hash(x // 2, y, 81) < .12 then px(x, y, L.timber.deep) end end)
  for _, fx in ipairs({ 204, 280 }) do F.boulder(fx, 128, 6, 3, fx) end
  F.lichen(beam, .08, 82)
  -- pulley, rope, hook, chain sling and the slung granite block
  local pul = c:ellipse(238, 58, 3, 3) rimOf(pul, IR) part(pul, IR)
  vline(238, 61, 78, L.board.deep) vline(240, 58, 76, L.board.deep)
  fill(rect(236, 79, 241, 80), IR.base) px(236, 79, IR.hi)
  block(220, 100, 32, 11, 4, ROSE, 9)
  for _, ch in ipairs({ { { 237, 81 }, { 224, 87 } }, { { 240, 81 }, { 252, 87 } } }) do
    line(ch):each(function(x, y) px(x, y, (x + y) % 2 == 0 and IR.deep or IR.base) end)
  end
  for _, vx in ipairs({ 224, 248 }) do for y = 88, 100 do px(vx, y, (y % 2 == 0) and IR.deep or IR.base) px(vx + 1, y, (y % 2 == 0) and IR.shade or IR.deep) end end
  -- winch drum at the right leg
  local drum = rect(268, 106, 282, 112) rimOf(drum, L.timber) part(drum, L.board) for x = 270, 280, 2 do vline(x, 106, 112, L.board.deep) end
  fill(rect(282, 104, 288, 105), IR.base) fill(rect(287, 104, 288, 112), IR.base)
  vline(276, 56, 105, L.board.deep)
  -- winch hand turning the crank
  F.gnome(296, 126, { small = true, hat = L.roof2, coat = L.leaf, arm = "out", flip = true })
  F.depth(3)
  -- quirk: a wallcreeper's nest on the crane beam (twigs, lichen, goat hair), three chicks gaping,
  -- the parent arriving on crimson wings with a moth
  F.sprite({
    "..y.......y.......y...",
    ".yYy.....yYy.....yYy..",
    "..gg......gg......gg..",
    ".gegg....gegg....gegg.",
    "mmggwnmmmmggmmnwmmggmm",
    "nMnmNnMnmNnmMnNnmMnnNn",
    ".nNmnnNmnnNnmnNnnmNnn.",
    "..nnNnnnNnnnNnnnNnn...",
  }, 262, 42, { y = L.gold.hi, Y = L.produce.base, g = L.stone.shade, e = L.timber.edge, n = L.timber.base, N = L.timber.shade,
    m = L.moss.base, M = L.moss.hi, w = L.goat.hi })
  F.sprite({
    "..........RR.R....",
    ".........RRwRRRR..",
    "........RRRRRwRR..",
    "..kgg..RRwRRRR....",
    "kkgegg.RRRRR......",
    "m.gDDggggRR.......",
    "mm.DDgggggggg.....",
    "....DDGggggggTT...",
    ".......GGG...TTTT.",
  }, 282, 36, { k = L.timber.edge, g = L.stone.base, G = L.stone.shade, D = L.stone.deep, e = L.timber.edge, R = L.apple.base,
    w = L.edel.hi, T = L.stone.deep, m = L.needle.hi })
  px(290, 36, L.apple.hi) px(291, 37, L.apple.hi) px(290, 38, L.apple.hi)
end
crane()

---------------------------------------------------------------- back-left: the mason's stone lodge, slab stacks
F.depth(1)
F.tree(84, 130, 42, 0)
F.tree(10, 134, 38, 1)
local ltop, lcx, lwall, lroof = F.building{ x0 = 22, x1 = 70, yb = 138, wh = 28, rh = 20, wall = L.plaster, roof = L.roof, chimney = true, shingle = true, noAttic = true, noFrame = true }
lwall:each(function(x, y)
  local row = (y - ltop) // 4
  local rx = (x + row * 3) % 7
  if (y - ltop) % 4 == 0 or rx == 0 then px(x, y, L.plaster.shade) elseif hash((x + row * 3) // 7, row, 83) < .25 then px(x, y, L.stone.base) end
end)
F.lichen(lroof, .2, 84)
for _, w in ipairs({ { 31, 106 }, { 61, 106 } }) do local ws = c:ellipse(w[1], w[2], 2, 1) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true }) px(w[1] - 1, w[2] - 1, L.stone.hi) end
F.door(38, 122, 47, 137, L.timber)
F.window(54, 118, 60, 124, L.timber)
F.smoke(60, 92, 6, .6, 2)
-- stacked paving slabs, a pile of ashlar, roof slates leaning on a rack
local function slabs(x0, x1, yb, n)
  F.shadow(x0, x1, yb + 1, 6, 2)
  for k = 0, n - 1 do
    local y = yb - k * 3
    local a, b = x0 + floor(hash(k, 1, 85) * 4), x1 - floor(hash(k, 2, 85) * 4)
    local m = rect(a, y - 2, b, y)
    rimOf(m, L.stone)
    hline(a, b, y - 2, L.stone.hi) hline(a, b, y - 1, L.stone.base) hline(a, b, y, L.stone.shade)
    px(b, y - 1, L.stone.deep) px(a, y - 1, L.stone.hi)
    if hash(k, 3, 85) < .5 then F.lichen(m, .3, 86 + k) end
  end
end
slabs(96, 132, 140, 5)
block(136, 140, 12, 7, 3, nil, 21) block(150, 140, 10, 6, 3, nil, 22) block(141, 132, 10, 6, 3, nil, 23)
-- roof slates leaning on a rack
local rk = rect(166, 122, 196, 123):add(rect(167, 124, 168, 136)):add(rect(194, 124, 195, 136))
rimOf(rk, L.timber) part(rk, L.timber, { nopop = true, noshade = true })
for k = 0, 6 do
  local x = 170 + k * 4
  local sl = poly{ { x, 136 }, { x + 3, 136 }, { x + 6, 124 }, { x + 3, 124 } }
  rimOf(sl, L.roof) fill(sl, k % 2 == 0 and L.roof.base or L.roof.shade)
  line({ { x + 1, 135 }, { x + 4, 125 } }):each(function(xx, yy) px(xx, yy, L.roof.hi) end)
end

---------------------------------------------------------------- back-right: the bell pit
local function bellpit()
  -- the clay mould (cope) in its pit, bound with iron, a pouring cup on top
  F.shadow(302, 330, 134, 6, 2)
  local pit = c:ellipse(316, 135, 15, 2) fill(pit, L.soil.deep)
  local cope = c:ellipse(316, 120, 7, 6):add(poly{ { 309, 120 }, { 323, 120 }, { 329, 134 }, { 303, 134 } })
  local cup = rect(313, 111, 319, 114)
  rimOf(union(cope, cup), CLAY)
  part(cope, CLAY)
  cope:each(function(x, y) if hash(x // 2, y, 87) < .12 then px(x, y, CLAY.shade) end if (x - 316) < -4 and y < 124 and hash(x, y, 88) < .4 then px(x, y, CLAY.hi) end end)
  for _, yy in ipairs({ 122, 128, 133 }) do cope:each(function(x, y) if y == yy then px(x, y, (x < 312) and IR.base or IR.deep) end end) end
  part(cup, CLAY, { nopop = true }) fill(rect(314, 111, 318, 112), G.base) px(315, 111, G.hi)
  -- the furnace: a squat clay-and-granite cupola, firehole glowing, tapping bronze down a runner into the cup
  local fur = rect(336, 90, 354, 133)
  rimOf(fur, L.stone) part(fur, L.stone) F.courses(fur, 90, 5, 7, L.stone)
  fill(rect(334, 88, 356, 91), CLAY.base) hline(334, 356, 88, CLAY.hi) hline(334, 356, 91, CLAY.deep)
  local fh = c:rrect(340, 97, 350, 108, 3):clip(rect(340, 97, 350, 108)) fill(fh, L.soil.edge)
  fill(c:ellipse(345, 106, 4, 2):clip(fh), G.shade) px(344, 105, G.hi) px(346, 106, G.base) px(343, 106, G.base) px(345, 103, G.base) px(347, 102, G.shade)
  local run = line({ { 337, 108 }, { 328, 110 }, { 320, 112 } }, 2)
  rimOf(run, CLAY) fill(run, CLAY.shade)
  line({ { 337, 108 }, { 328, 110 }, { 320, 111 } }):each(function(x, y) px(x, y, hash(x, y, 89) < .5 and G.hi or G.base) end)
  px(321, 113, G.base)
  F.smoke(345, 84, 6, .8, 2)
  for i = 0, 6 do px(324 + floor(hash(i, 1, 90) * 14), 100 + floor(hash(i, 2, 90) * 8), i % 2 == 0 and G.hi or G.base) end
end
bellpit()
F.depth(2)
F.tree(452, 142, 56, 0)
F.tree(436, 136, 40, 3)

F.depth(2)
F.larch(78, 166, 50, 47)
---------------------------------------------------------------- left hero: the forge under a slab lean-to
F.depth(3)
local function forge()
  local posts = rect(92, 128, 95, 206):add(rect(186, 140, 189, 208))
  local roofm = poly{ { 84, 128 }, { 196, 140 }, { 196, 146 }, { 84, 134 } }
  local hearth = rect(104, 162, 162, 202)
  local hood = poly{ { 108, 140 }, { 158, 140 }, { 162, 162 }, { 104, 162 } }
  local chim = rect(124, 84, 140, 140)
  F.shadow(94, 194, 208, 12, 5)
  rimOf(union(chim, hood, hearth), L.stone)
  part(chim, L.stone) F.courses(chim, 84, 6, 8, L.stone)
  fill(rect(122, 82, 142, 85), L.stone.shade) hline(122, 142, 82, L.stone.hi)
  F.lichen(rect(122, 82, 142, 86), .3, 34)
  part(hood, L.plaster, { sep = true }) F.courses(hood, 140, 5, 10, L.plaster, 2)
  hood:each(function(x, y) if y < 146 and hash(x, y, 91) < .3 then px(x, y, L.plaster.shade) end end) -- soot under the roof
  part(hearth, L.stone, { sep = true }) F.courses(hearth, 162, 7, 12, L.stone, 5) F.lichen(hearth, .08, 35)
  local mouth = c:rrect(116, 168, 150, 196, 8):clip(rect(116, 168, 150, 190))
  fill(mouth, L.soil.edge)
  mouth:each(function(x, y) if y < 172 and hash(x, y, 92) < .5 then px(x, y, L.soil.deep) end end)
  local coals = c:ellipse(133, 188, 14, 5):clip(mouth)
  fill(coals, G.shade)
  coals:each(function(x, y) local v = hash(x, y, 4) if v < .3 then px(x, y, G.base) elseif v < .4 then px(x, y, G.hi) elseif v > .85 then px(x, y, G.deep) end end)
  local flame = poly{ { 124, 186 }, { 128, 176 }, { 131, 182 }, { 134, 172 }, { 138, 181 }, { 141, 176 }, { 144, 186 } }
  fill(flame, G.base) fill(poly{ { 129, 186 }, { 134, 177 }, { 139, 186 } }, G.hi)
  -- chisel blanks heating in the fire
  for k = 0, 2 do line({ { 140 + k * 3, 184 }, { 152 + k * 2, 176 + k } }):each(function(x, y) px(x, y, (x > 146) and IR.base or G.base) end) end
  hline(112, 154, 196, L.stone.hi) hline(112, 154, 197, L.stone.deep)
  -- glow on the ground
  for y = 203, 214 do for x = 112 + (y - 203), 156 - (y - 203) do if hash(x, y, 7) < .35 then px(x, y, L.gold.hi) end end end
  -- posts and the slab roof, chimney through it
  rimOf(union(posts, roofm), L.timber)
  part(posts, L.timber, { nopop = true })
  posts:each(function(x, y) if hash(x, y // 3, 93) < .2 then px(x, y, L.timber.shade) end end)
  part(roofm, L.roof, { sep = true }) F.courses(roofm, 128, 3, 6, L.roof) F.lichen(roofm, .25, 36)
  hline(84, 196, 134, L.roof.deep)
  part(rect(124, 84, 140, 128):clip(chim), L.stone) F.courses(rect(124, 84, 140, 128), 84, 6, 8, L.stone)
  F.lichen(rect(124, 120, 140, 128), .25, 37)
  for _, w in ipairs({ { 100, 129 }, { 112, 130 }, { 154, 135 }, { 176, 137 } }) do
    local ws = c:ellipse(w[1], w[2], 3, 2) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true }) px(w[1] - 1, w[2] - 1, L.stone.hi)
  end
  F.smoke(132, 78, 9, .7, 3)
  -- bellows
  local bel = poly{ { 162, 176 }, { 182, 170 }, { 184, 184 }, { 164, 186 } }
  rimOf(bel, L.timber) part(bel, L.soil) bel:each(function(x, y) if (x - 162) % 5 == 0 then px(x, y, L.soil.deep) end end)
  fill(rect(184, 172, 190, 174), L.timber.base)
  -- cowbells on straps, graded, hung on nails down the left post
  for k = 0, 2 do
    local y = 142 + k * 13
    px(97, y, IR.hi)
    strap(100, y, y + 4, k == 1 and L.accent or L.awnA)
    cowbell(100, y + 4, 2 + k, k == 2 and IR or BR)
  end
  -- and a row of bronze bells hanging from the eave on the right
  for k, b in ipairs({ { 166, 3 }, { 173, 4 }, { 181, 3 } }) do
    local x = b[1]
    local ye = floor(134 + (x - 84) * 12 / 112) + 1
    vline(x, ye, ye + 2 + k, L.timber.deep)
    cowbell(x, ye + 5 + k, b[2], k == 2 and IR or BR)
  end
end
forge()
-- anvil on a larch stump, the smith drawing a chisel point
local function anvil(x, yb)
  local stump = rect(x - 7, yb - 10, x + 7, yb)
  local body = poly{ { x - 12, yb - 18 }, { x + 9, yb - 18 }, { x + 9, yb - 14 }, { x + 4, yb - 14 }, { x + 5, yb - 11 }, { x - 5, yb - 11 }, { x - 4, yb - 14 }, { x - 8, yb - 14 } }
  F.shadow(x - 8, x + 9, yb, 8, 3)
  rimOf(union(stump, body), L.timber)
  part(stump, L.timber) hline(x - 7, x + 7, yb - 10, L.board.hi) fill(rect(x - 7, yb - 9, x + 7, yb - 9), L.board.shade)
  stump:each(function(xx, yy) if (xx - x + 7) % 3 == 0 and yy > yb - 9 and hash(xx, yy // 2, 19) < .6 then px(xx, yy, L.timber.shade) end end)
  part(body, IR) hline(x - 11, x + 8, yb - 18, IR.hi)
  -- a glowing chisel bar on the face, sparks
  fill(rect(x - 6, yb - 20, x + 4, yb - 19), G.base) px(x - 6, yb - 20, G.hi) px(x + 4, yb - 19, G.shade) px(x + 5, yb - 19, G.shade)
  for i = 0, 11 do local sx, sy = x - 10 + floor(hash(i, 1, 21) * 22), yb - 24 - floor(hash(i, 2, 21) * 12) px(sx, sy, i % 2 == 0 and G.hi or G.base) end
  -- finished points and chisels laid on the stump foot
  for k = 0, 3 do hline(x - 6 + k * 3, x - 6 + k * 3 + 1, yb + 2, IR.hi) vline(x - 6 + k * 3, yb + 1, yb + 3, IR.base) end
end
anvil(168, 232)
local _, hx, hy = F.gnome(148, 238, { hat = L.awnA, coat = L.soil, arm = "up" })
fill(rect(hx, hy - 6, hx + 1, hy + 1), L.board.base) fill(rect(hx - 3, hy - 9, hx + 4, hy - 6), IR.base) px(hx - 3, hy - 9, IR.hi) -- hammer up
fill(rect(146, 228, 150, 235), L.soil.shade) px(146, 228, L.soil.base) -- leather apron
-- a Bernese dog asleep in the forge's warmth (tricolour: dark coat, rust, white blaze)
F.sprite({
  "....................ee....",
  "...................eKKe...",
  "......KKKKKKKK....eKKWKe..",
  "...KKKKKKKKKKKKKKKKKrWWKk.",
  "..KKKhKKKKKKKKKKKKrKWWWWWn",
  ".TKKKKKhKKKKKKhKKrrWWWWWW.",
  "TTKKKKKKKKKKKKKKKrrWWrrW..",
  "TT.KKKKKKKKKKKKKKrWWWrr...",
  "....rrWW..rrWWrrrWWWW.....",
}, 94, 206, { e = L.soil.edge, K = "#3a3036", h = "#56484a", W = L.awnB.hi, r = L.redbark.base, n = L.timber.edge, k = L.timber.edge, T = "#3a3036" })
px(115, 209, L.timber.edge) px(116, 208, "#56484a") -- closed eye
for k = 0, 2 do px(98 + k * 2, 203 - k * 2, L.awnB.base) end -- a little z
-- a granite quench trough with steam
local _, ttop = block(186, 236, 18, 9, 3, nil, 24)
fill(rect(188, 227, 202, 228), L.water.base) hline(189, 196, 227, L.water.hi)
for k = 0, 3 do px(192 + k * 2, 223 - k, L.mist2) px(193 + k * 2, 222 - k, L.mist) end
-- a pair of tongs in the trough
line({ { 199, 226 }, { 205, 218 } }):each(function(x, y) px(x, y, IR.base) end) line({ { 200, 226 }, { 207, 219 } }):each(function(x, y) px(x, y, IR.shade) end)

---------------------------------------------------------------- right hero: the bell-founder's workshop, open front
local function workshop()
  local x0, x1, yb = 296, 446, 208
  local top, cx, wallM, roofM = F.building{ x0 = x0, x1 = x1, yb = yb, wh = 56, rh = 36, wall = L.plaster, roof = L.roof, shingle = true, noFrame = true }
  -- larch boards on the upper band and the gable, whitewashed granite rubble below
  local boards = rect(x0, top, x1, top + 9)
  part(boards, L.timber, { nopop = true }) F.planks(boards, L.timber, 4, true, 51)
  boards:each(function(x, y) if y < top + 4 and hash(x, y, 52) < .3 then px(x, y, L.timber.deep) end end)
  local gab = poly{ { x0 + 5, top }, { cx, top - 36 + 8 }, { x1 - 5, top } }:cut(roofM)
  part(gab, L.timber, { nopop = true }) F.planks(gab, L.timber, 4, true, 53)
  F.window(cx - 3, top - 36 // 2 + 1, cx + 2, top - 36 // 2 + 5, L.timber)
  hline(x0, x1, top + 10, L.timber.edge)
  local foot = rect(x0, top + 11, x1, yb)
  foot:each(function(x, y)
    local row = (y - top - 11) // 5
    local ry = (y - top - 11) % 5
    local bw = 7 + floor(hash(row, 1, 54) * 4)
    local rx = (x + row * 3) % bw
    local h = L.plaster.base
    if ry == 0 or rx == 0 then h = L.plaster.shade
    elseif hash((x + row * 3) // bw, row, 55) < .28 then h = (ry == 1) and L.stone.hi or L.stone.base
    elseif ry == 1 and rx == 1 then h = L.plaster.hi end
    if y > yb - 4 and hash(x, y, 56) < .4 then h = L.stone.shade end
    if x == x0 then h = L.plaster.hi end
    px(x, y, h)
  end)
  F.lichen(roofM, .2, 57)
  for _, w in ipairs({ { 310, 149 }, { 334, 137 }, { 408, 137 }, { 432, 149 } }) do
    local ws = c:ellipse(w[1], w[2], 3, 2) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true }) px(w[1] - 1, w[2] - 1, L.stone.hi)
  end
  -- the bell-cote on the ridge
  local bc = union(rect(365, 104, 366, 116), rect(376, 104, 377, 116))
  local bcr = poly{ { 361, 105 }, { 371, 96 }, { 381, 105 } }
  rimOf(union(bc, bcr), L.timber) part(bc, L.timber, { nopop = true, noshade = true })
  part(bcr, L.roof) F.courses(bcr, 96, 2, 4, L.roof) line({ { 362, 104 }, { 370, 97 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  fill(rect(367, 106, 375, 116), L.soil.edge)
  cowbell(371, 108, 3, BR) vline(371, 105, 106, IR.base)
  -- window left of the doorway, gentian box
  F.window(303, 174, 313, 183, L.timber)
  hline(301, 315, 187, L.timber.base) for k = 0, 5 do px(303 + k * 2, 186, L.fern.base) px(304 + k * 2, 185, k % 2 == 0 and L.gentian.base or L.gentian.hi) end
  -- big open doorway with the interior
  local dx0, dx1, dy0 = 322, 420, 166
  local fr = rect(dx0 - 3, dy0 - 3, dx1 + 3, yb)
  fill(fr, L.timber.base) hline(dx0 - 3, dx1 + 3, dy0 - 3, L.timber.hi) hline(dx0 - 3, dx1 + 3, dy0 - 1, L.timber.deep)
  vline(dx0 - 3, dy0 - 3, yb, L.timber.hi)
  fill(rect(dx0, dy0, dx1, yb), L.soil.edge)
  fill(rect(dx0, yb - 6, dx1, yb), L.soil.deep)
  for x = dx0 + 4, dx1, 8 do vline(x, dy0, yb - 7, "#3a2e2a") end
  -- bell rack (left): graded cowbells on embroidered straps
  local rack = rect(dx0 + 3, dy0 + 3, dx0 + 47, dy0 + 4)
  fill(rack, L.timber.base) hline(dx0 + 3, dx0 + 47, dy0 + 3, L.timber.hi)
  local sizes = { 5, 4, 4, 3, 3, 2, 2 }
  local straps = { L.awnA, L.accent, L.awnA, L.gold, L.accent, L.awnA, L.leaf }
  local bx = dx0 + 7
  for i, s in ipairs(sizes) do
    local yt = dy0 + 10 + (5 - s) * 2
    strap(bx, dy0 + 5, yt, straps[i])
    cowbell(bx, yt, s, i % 3 == 0 and IR or BR)
    bx = bx + s * 2 + 3
  end
  -- a lower shelf with bell moulds (little clay cones) and wax models
  hline(dx0 + 3, dx0 + 47, dy0 + 24, L.board.base) hline(dx0 + 3, dx0 + 47, dy0 + 25, L.timber.deep)
  for k = 0, 4 do local x = dx0 + 7 + k * 9 local m = poly{ { x - 3, dy0 + 23 }, { x + 3, dy0 + 23 }, { x + 1, dy0 + 18 }, { x - 1, dy0 + 18 } }
    rimOf(m, CLAY) fill(m, k % 2 == 0 and CLAY.base or L.cheese.shade) px(x - 1, dy0 + 19, CLAY.hi) end
  -- mason's tool wall (right): round mallets, points, claw chisels, square, dividers
  local tw2 = rect(dx0 + 52, dy0 + 3, dx1 - 6, dy0 + 22) fill(tw2, L.soil.base) c:edgeIn(tw2, L.timber.deep)
  tw2:each(function(x, y) if (x - dx0) % 6 == 0 and hash(x, y // 4, 58) < .5 then px(x, y, L.soil.shade) end end)
  for k, mx in ipairs({ 380, 388 }) do
    local mh = c:ellipse(mx, 174, 3 - (k - 1), 3 - (k - 1)) fill(mh, L.board.base) c:edgeIn(mh, L.board.deep) px(mx - 1, 173, L.board.hi)
    vline(mx, 177 - (k - 1), 185, L.timber.base)
  end
  for k = 0, 4 do local x = 395 + k * 3 vline(x, 172, 177, L.timber.base) vline(x, 178, 185, IR.hi) px(x, 186, k == 2 and IR.deep or IR.base) if k == 3 then px(x - 1, 186, IR.base) px(x + 1, 186, IR.base) end end
  fill(rect(410, 171, 411, 185), IR.hi) fill(rect(410, 184, 416, 185), IR.hi) px(411, 171, IR.shade) -- square
  line({ { 377, 170 }, { 374, 185 } }):each(function(x, y) px(x, y, IR.base) end) line({ { 377, 170 }, { 380, 185 } }):each(function(x, y) px(x, y, IR.shade) end)
  px(377, 169, IR.hi) -- dividers
  -- the banker (stone bench) with a half-carved ibex head, points, dust
  local bench = rect(330, 192, 414, 196)
  local legs = rect(334, 197, 339, 208):add(rect(405, 197, 410, 208))
  rimOf(union(bench, legs), L.stone) part(bench, L.timber) F.planks(bench, L.timber, 3, false, 59) part(legs, L.stone, { nopop = true })
  F.sprite({
    ".hh.........hh....",
    "h..h.......h..h...",
    "h...h.....h...h...",
    "....hh...hh.......",
    ".....sSSSSs.......",
    "....sSeSSeSs......",
    "....sSSSSSSs......",
    ".....sSSSSs.......",
    "......sSSs........",
    "....BbbbbbbbbB....",
    "...BbbBbbBbbbbB...",
    "...bBbbbbbBbbbb...",
  }, 344, 180, { h = "#9c9078", s = L.stone.hi, S = L.stone.base, e = L.timber.edge, b = L.stone.shade, B = L.stone.deep })
  px(352, 186, L.stone.hi) px(351, 188, L.stone.shade) px(354, 189, L.stone.shade) -- muzzle and nose
  for k = 0, 2 do hline(368 + k * 5, 371 + k * 5, 191, IR.hi) px(367 + k * 5, 191, IR.base) end
  chips(338, 412, 200, 207, 26, 60)
  chips(360, 380, 189, 191, 6, 61)
  F.gnome(392, 208, { hat = L.lav, coat = L.accent, arm = "hold", flip = true, noShadow = true })
  fill(c:ellipse(387, 201, 2, 2), L.board.base) px(386, 200, L.board.hi) -- the mallet in hand
  -- hanging lantern inside
  vline(372, 166, 169, L.timber.edge) local ln = rect(370, 170, 374, 174) rimOf(ln, IR) fill(ln, G.base) px(370, 170, G.hi) px(374, 174, G.shade)
  -- sign above the doorway: a bell and a crossed chisel on a board
  local sb = rect(352, 148, 390, 159) rimOf(sb, L.timber) part(sb, L.board) F.planks(sb, L.board, 4, false, 62)
  cowbell(366, 151, 3, BR)
  line({ { 374, 157 }, { 384, 150 } }):each(function(x, y) px(x, y, IR.hi) end) fill(rect(383, 149, 385, 151), L.timber.base)
  line({ { 374, 150 }, { 384, 157 } }):each(function(x, y) px(x, y, L.timber.base) end) fill(c:ellipse(375, 151, 1, 1), L.board.shade)
  -- cowbells on embroidered straps hung on pegs on the right wall
  hline(424, 444, 170, L.timber.deep) hline(424, 444, 169, L.timber.hi)
  for k, b in ipairs({ { 428, 3, L.awnA }, { 436, 4, L.accent }, { 443, 2, L.gold } }) do
    strap(b[1], 171, 176 + (4 - b[2]), b[3]) cowbell(b[1], 176 + (4 - b[2]), b[2], k == 2 and IR or BR)
  end
end
workshop()
local function grindstone(x, yb)
  local frame = rect(x - 12, yb - 12, x - 10, yb):add(rect(x + 10, yb - 12, x + 12, yb)):add(rect(x - 12, yb - 4, x + 12, yb - 3))
  local stone = c:ellipse(x, yb - 20, 10, 10)
  local trough = rect(x - 9, yb - 8, x + 9, yb - 4)
  F.shadow(x - 12, x + 12, yb, 6, 2)
  rimOf(union(frame, stone, trough), L.timber)
  part(frame, L.timber, { nopop = true, noshade = true })
  part(trough, L.timber) fill(rect(x - 8, yb - 8, x + 8, yb - 7), L.water.base)
  part(stone, L.soil)
  c:ellipse(x, yb - 20, 7, 7):edge():each(function(xx, yy) px(xx, yy, L.soil.shade) end)
  stone:each(function(xx, yy) if hash(xx, yy, 63) < .1 then px(xx, yy, L.soil.hi) end end)
  fill(c:ellipse(x, yb - 20, 2, 2), IR.base) px(x - 1, yb - 21, IR.hi)
  fill(rect(x + 2, yb - 21, x + 14, yb - 20), IR.base) fill(rect(x + 13, yb - 21, x + 14, yb - 13), IR.base) fill(rect(x + 13, yb - 14, x + 17, yb - 13), L.board.base)
end
grindstone(432, 226)

---------------------------------------------------------------- foreground left: a pyramid of ashlar blocks, a goat kid on top
F.shadow(24, 82, 205, 8, 3)
block(24, 204, 16, 9, 3, nil, 41) block(43, 204, 15, 9, 3, nil, 42) block(61, 204, 14, 9, 3, nil, 43)
block(32, 192, 15, 8, 3, nil, 44) block(51, 192, 14, 8, 3, nil, 45)
block(42, 181, 14, 8, 3, nil, 46)
F.goat(52, 171, { k = .62, flip = true, noShadow = true })
F.barrel(86, 204, L.timber, 11)
fill(rect(82, 192, 90, 193), L.water.base) px(83, 192, L.water.hi)
-- a granite marmot being carved out of a raw block
local function marmotStatue(x, yb)
  local blockM = rect(x - 11, yb - 15, x + 11, yb)
  local body = c:ellipse(x, yb - 25, 8, 11)
  local head = c:ellipse(x, yb - 39, 6, 5)
  local ears = rect(x - 6, yb - 44, x - 4, yb - 42):add(rect(x + 4, yb - 44, x + 6, yb - 42))
  local sil = union(blockM, body, head, ears)
  F.shadow(x - 11, x + 11, yb, 10, 4)
  rimOf(sil, L.stone)
  -- raw block: rough, pocked with point marks, a lichen skin on its foot
  blockM:each(function(xx, yy)
    local u = (xx - x) / 11
    local v = hash(xx, yy, 64)
    local h = v < .3 and L.stone.shade or L.stone.base
    if u < -.7 then h = L.stone.hi elseif u > .7 then h = L.stone.deep end
    if v > .9 then h = L.stone.deep end
    px(xx, yy, h)
  end)
  F.lichen(rect(x - 11, yb - 5, x + 11, yb), .35, 65)
  -- the carving line where the marmot emerges
  for xx = x - 10, x + 10, 2 do local yy = yb - 15 + floor(hash(xx, 0, 66) * 3) px(xx, yy, L.stone.hi) px(xx + 1, yy + 1, L.stone.deep) end
  -- smooth dressed figure, lit upper left
  union(body, head):each(function(xx, yy)
    if yy < yb - 15 then
      local u = (xx - x) / 8
      local h = L.stone.base
      if u < -.5 then h = L.stone.hi elseif u > .45 then h = L.stone.shade end
      if u > .85 then h = L.stone.deep end
      px(xx, yy, h)
    end
  end)
  c:edgeIn(union(body, head):clip(rect(x - 12, yb - 46, x + 12, yb - 16)), L.stone.deep)
  hline(x - 5, x + 5, yb - 33, L.stone.shade) -- chin / neck
  fill(ears, L.stone.shade) px(x - 6, yb - 44, L.stone.hi) px(x - 5, yb - 43, L.stone.deep) px(x + 5, yb - 43, L.stone.deep)
  -- face: eyes, nose, the incisors, cheeks
  for _, ex in ipairs({ x - 3, x + 3 }) do px(ex, yb - 40, L.timber.edge) px(ex, yb - 41, L.timber.edge) px(ex - 1, yb - 41, L.stone.deep) px(ex + 1, yb - 41, L.stone.deep) end
  fill(rect(x - 2, yb - 38, x + 2, yb - 35), L.stone.hi) -- the pale muzzle
  for _, ck in ipairs({ x - 5, x + 5 }) do px(ck, yb - 37, L.stone.shade) end
  fill(rect(x - 1, yb - 38, x + 1, yb - 37), L.stone.deep) px(x - 1, yb - 38, L.stone.shade)
  px(x - 1, yb - 36, L.edel.base) px(x, yb - 36, L.edel.shade) px(x, yb - 35, L.stone.deep)
  -- paws folded on the chest, belly line
  for _, pxx in ipairs({ x - 3, x + 2 }) do hline(pxx, pxx + 1, yb - 30, L.stone.deep) px(pxx, yb - 31, L.stone.hi) end
  c:ellipse(x, yb - 24, 5, 7):edge():each(function(xx, yy) if xx > x and yy > yb - 29 then px(xx, yy, L.stone.shade) end end)
  -- chips heaped at the base
  chips(x - 16, x + 22, yb - 2, yb + 8, 30, 67)
end
marmotStatue(44, 256)
local _, ox, oy = F.gnome(70, 260, { hat = L.produce, coat = L.leaf, arm = "up", flip = true })
-- a point chisel to the marmot's flank, the round mallet raised
line({ { ox - 1, oy + 4 }, { 56, oy + 1 } }):each(function(x, y) px(x, y, IR.hi) px(x, y + 1, IR.shade) end) px(55, oy + 1, IR.deep)
fill(rect(ox - 2, oy + 3, ox, oy + 5), L.board.base)
vline(ox, oy - 4, oy, L.timber.base) local mh = rect(ox - 2, oy - 7, ox + 3, oy - 4) rimOf(mh, L.timber) part(mh, L.board, { nopop = true }) px(ox - 2, oy - 7, L.board.hi)
for i = 0, 3 do px(54 - floor(hash(i, 3, 53) * 4), 228 - i * 2, L.stone.hi) end
-- granite mortars and a pestle
for k, m in ipairs({ { 92, 256, 7 }, { 104, 262, 5 } }) do
  local mx, my, r = m[1], m[2], m[3]
  local b = c:ellipse(mx, my, r, r - 2):clip(rect(mx - r, my - 2, mx + r, my + r))
  local rimM = c:ellipse(mx, my - 2, r, 2)
  rimOf(union(b, rimM), L.stone) part(b, L.stone, { nopop = true })
  fill(rimM, L.stone.hi) fill(c:ellipse(mx, my - 2, r - 2, 1), L.stone.deep)
  if k == 1 then line({ { mx + 1, my - 3 }, { mx + 5, my - 10 } }, 2):each(function(x, y) px(x, y, L.board.base) end) px(mx + 5, my - 10, L.board.hi) end
end

---------------------------------------------------------------- foreground right: crate of cowbells, a bronze bell on a trestle
F.depth(3)
F.crate(296, 242, 20, 10)
for k, b in ipairs({ { 301, 3 }, { 309, 4 }, { 314, 2 } }) do
  local yt = 230 - b[2]
  cowbell(b[1], yt, b[2], k == 2 and IR or BR)
end
for k = 0, 2 do local x = 299 + k * 6 line({ { x, 232 }, { x + 2, 236 }, { x + 1, 244 } }):each(function(xx, yy) px(xx, yy, (k % 2 == 0) and L.awnA.base or L.accent.base) end) end
-- a goat nosing the crate, wearing a new bell
F.goat(292, 262, { k = .82, flip = true })
px(282, 245, L.awnA.base) px(283, 246, L.awnA.base) px(284, 246, L.awnA.shade)
cowbell(283, 248, 2, BR)
-- a big bronze bell slung under a larch trestle, with a little test hammer
local tre = rect(334, 214, 376, 217):add(line({ { 338, 218 }, { 334, 246 } }, 2)):add(line({ { 340, 218 }, { 344, 246 } }, 2))
tre:add(line({ { 370, 218 }, { 366, 246 } }, 2)):add(line({ { 372, 218 }, { 376, 246 } }, 2))
F.shadow(334, 378, 247, 8, 3)
rimOf(tre, L.timber) part(tre, L.timber, { nopop = true, noshade = true }) hline(334, 376, 214, L.timber.hi)
vline(355, 218, 220, IR.base)
bigbell(355, 225, 13, 18)
line({ { 377, 220 }, { 379, 230 } }):each(function(x, y) px(x, y, L.board.base) end) fill(rect(376, 230, 379, 232), IR.base) px(376, 230, IR.hi)
-- a painted tool chest
local tb = rect(326, 250, 346, 260) rimOf(tb, L.timber) part(tb, L.accent) hline(326, 346, 253, L.accent.deep) hline(326, 346, 254, L.accent.hi)
for _, x in ipairs({ 330, 342 }) do vline(x, 251, 259, L.gold.shade) end fill(rect(335, 254, 337, 256), L.gold.base) px(335, 254, L.gold.hi)
for k = 0, 3 do vline(331 + k * 4, 246, 249, IR.hi) px(331 + k * 4, 245, L.timber.base) end
-- a coil of hemp rope
for k = 0, 2 do
  local y = 258 - k * 3
  local o = c:ellipse(366, y, 9 - k, 3):cut(c:ellipse(366, y, 6 - k, 1))
  rimOf(o, L.needle) fill(o, k % 2 == 0 and L.needle.base or L.needle.shade)
  o:each(function(x, yy) if yy < y - 1 then px(x, yy, L.needle.hi) end end)
end
-- alpine flowers and junipers
F.juniper(22, 266, 9, 5, 3) F.juniper(122, 264, 7, 4, 4) F.juniper(262, 266, 8, 5, 5)
for _, f in ipairs({ { 112, 248 }, { 132, 258 }, { 274, 258 }, { 206, 216 }, { 296, 214 }, { 452, 220 }, { 20, 214 } }) do F.edelweiss(f[1], f[2], true) end
for _, f in ipairs({ { 118, 252 }, { 136, 262 }, { 210, 218 }, { 268, 262 }, { 372, 226 }, { 446, 222 }, { 14, 218 } }) do F.gentian(f[1], f[2], true) end

---------------------------------------------------------------- the carrier: a gnome bringing new cowbells on a pole
local _, cx1, cy1 = F.gnome(276, 214, { hat = L.roof2, coat = L.awnA, arm = "up" })
local pole = line({ { cx1 - 24, cy1 + 1 }, { cx1 + 12, cy1 - 3 } }, 2)
rimOf(pole, L.timber) fill(pole, L.board.base)
line({ { cx1 - 24, cy1 + 1 }, { cx1 + 12, cy1 - 3 } }):each(function(x, y) px(x, y, L.board.hi) end)
for k, b in ipairs({ { cx1 - 20, 3, L.accent }, { cx1 - 13, 4, L.awnA }, { cx1 + 9, 3, L.gold } }) do
  local yp = floor(cy1 + 1 - (b[1] - (cx1 - 24)) * 4 / 36) + 2
  strap(b[1], yp, yp + 6, b[3]) cowbell(b[1], yp + 6, b[2], k == 2 and IR or BR)
end
-- chips trail along the road
chips(204, 280, 236, 262, 18, 68)

F.depth(0)
F.birds({ { 330, 34, 2 }, { 344, 40, 1 }, { 168, 50, 1 }, { 150, 44, 2 }, { 318, 62, 1 } })
-- a granite block by the road with a sledgehammer leaning on it
F.depth(3)
block(174, 262, 20, 8, 3, nil, 69)
local sh = line({ { 186, 252 }, { 196, 236 } }, 2) rimOf(sh, L.timber) fill(sh, L.board.base)
local hd = rect(192, 231, 201, 236) rimOf(hd, IR) part(hd, IR, { nopop = true }) px(192, 231, IR.hi)
chips(160, 210, 258, 266, 12, 70)
F.finish()
