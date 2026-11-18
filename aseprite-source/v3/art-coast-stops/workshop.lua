-- workshop.lua : "Workshop" stop look, COAST (coast_driftwood), 480x270 gate view.
-- Same composition as the Maplewold workshop (art-2701-batch3/stops/opus3/workshop.lua) and the forest carver's yard,
-- re-cast as a boatbuilder's and sailmaker's yard on a chalk-and-dune coast (the mill pilot is the salt / tide mill):
-- road's end: the timber gantry crane hoisting an oak keel log over a yard of sawn planks, the open sea behind it.
-- Back left: a whitewashed cottage and a tall tarred net shop, smoke blown seaward; stickered plank stacks, an oar
-- rack. Back right: sails spread to dry on poles (a barked red lugsail and a cream jib) with a sailmaker stitching
-- at a spread sail. Left hero: a granite hearth under a red-pantiled lean-to with a long steam box on top (bending
-- oak strakes), a tar pot bubbling in the fire mouth, bent ribs on the posts, a grey dog asleep in the warmth, a gnome
-- hewing a block at a stump. Right hero: the tarred boat shed, open front: a half-built clinker boat on stocks
-- (lower strakes riveted, upper ribs bare), clamps and blocks on the walls, a gnome riveting at the stem, a grindstone.
-- Foreground: a sawhorse bench with a strake being planed, a tar barrel and plank ends, a sea chest, a bucket of
-- copper roves, coils of rope, a pull-along toy boat, a gnome carrying oars, marram, thrift, shells.
-- Quirk: a herring gull has built its nest (rope ends and wrack, three gaping speckled chicks) on the crane beam,
-- and the parent lands beside it with a fish.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-coast-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "workshop", out = DIR, farTrees = { 24, 52, 160, 300, 330, 440 },
  duneLineGap = { 196, 292 }, boats = { { 174, 97, 8 }, { 318, 96, 6 }, { 346, 101, 10 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local IR, G, OAK = L.iron, L.glow, L.needle

---------------------------------------------------------------- local helpers
-- a log lying left-right, end grain showing on the right
local function log(x0, x1, y, r, bark)
  bark = bark or OAK
  local m = c:rrect(x0, y - r, x1, y + r, r)
  rimOf(m, L.tar) part(m, bark, { nopop = true })
  m:each(function(x, yy) if hash(x // 3, yy, 17) < .18 then px(x, yy, bark.shade) elseif hash(x // 2, yy, 18) < .06 then px(x, yy, bark.hi) end end)
  hline(x0 + r, x1 - r, y - r + 1, bark.hi)
  F.logEnd(x1 - r + 1, y, r, bark)
  return m
end
local function stump(x, yb, w, bark)
  bark = bark or L.timber
  local body = rect(x - w, yb - w, x + w, yb)
  local top = c:ellipse(x, yb - w, w, math.max(1, w // 2))
  rimOf(union(body, top), L.tar) part(body, bark, { nopop = true })
  body:each(function(xx, yy) if (xx - x + w) % 3 == 0 and hash(xx, yy // 2, 19) < .6 then px(xx, yy, bark.shade) end end)
  fill(top, L.board.base) px(x, yb - w, L.board.shade) px(x - 1, yb - w - 1, L.board.hi)
  if w > 3 then c:ellipse(x, yb - w, w - 2, math.max(1, w // 2 - 1)):edge():each(function(xx, yy) px(xx, yy, L.board.shade) end) end
  return body, top
end
-- a stickered stack of sawn planks seen end-on-ish: n layers of boards with thin sticks between
local function plankStack(x0, x1, yb, n, r)
  r = r or L.board
  local m = HP.mask()
  for k = 0, n - 1 do m:add(rect(x0 + (k % 2), yb - k * 4 - 2, x1 - (k % 2), yb - k * 4)) end
  m:add(rect(x0 + 1, yb - n * 4 + 1, x1 - 1, yb))
  rimOf(m, L.tar)
  for k = 0, n - 1 do
    local y = yb - k * 4
    hline(x0 + (k % 2), x1 - (k % 2), y - 2, r.hi) hline(x0 + (k % 2), x1 - (k % 2), y - 1, r.base) hline(x0 + (k % 2), x1 - (k % 2), y, r.shade)
    -- board ends (right side) and the dark stickers between layers
    for x = x0 + 2, x1 - 2, 7 do px(x, y - 1, r.deep) end
    px(x1 - (k % 2), y - 1, r.hi)
    if k < n - 1 then hline(x0 + 1, x1 - 1, y - 3, L.tar.shade) for x = x0 + 3, x1 - 3, 9 do px(x, y - 3, L.timber.base) px(x + 1, y - 3, L.timber.hi) end end
  end
  return m
end
-- curled plane shavings: little hooked strokes in pale wood
local function shavings(x0, x1, y0, y1, n, seed)
  for i = 1, n do
    local x, y = x0 + floor(hash(i, 1, seed) * (x1 - x0)), y0 + floor(hash(i, 2, seed) * (y1 - y0))
    local d = hash(i, 3, seed) < .5 and 1 or -1
    px(x, y, L.board.hi) px(x + d, y, L.board.base) px(x + d, y - 1, L.board.hi)
    if hash(i, 4, seed) < .5 then px(x, y + 1, L.board.shade) end
  end
end
-- a flat coil of rope seen from above-front
local function ropeCoil(x, y, rx, ry, r)
  r = r or L.cork
  local m = c:ellipse(x, y, rx, ry)
  rimOf(m, r)
  fill(m, r.base)
  for k = 1, rx - 1, 2 do
    c:ellipse(x, y, rx - k, math.max(1, ry - k * ry // rx)):edge():each(function(xx, yy) px(xx, yy, yy > y and r.deep or r.shade) end)
  end
  m:each(function(xx, yy) if (xx - x) / rx + (yy - y) / ry < -1 then px(xx, yy, r.hi) end end)
  fill(c:ellipse(x, y, math.max(1, rx // 4), math.max(1, ry // 4)), r.deep)
  px(x + rx, y + 1, r.base) px(x + rx + 1, y + 2, r.shade) px(x + rx + 2, y + 2, r.base) -- the loose end
  return m
end
-- a dark tar-smoke column (reads against the pale chalk headland)
local function tarSmoke(x, y, n, drift)
  local cols = { L.tar.hi, L.stone.deep, L.stone.shade, L.stone.base }
  for i = 0, n - 1 do
    local t = i / math.max(1, n - 1)
    local r = floor(2 + t * 3 + sin(i * 1.3) * .6)
    local cx, cy = x + floor(drift * i * i * .5 + 2 * sin(i * 1.7)), y - i * 5
    local m = c:ellipse(cx, cy, r, math.max(1, r - 1))
    local ci = math.min(4, 1 + floor(t * 3.5))
    fill(m, cols[ci])
    m:each(function(xx, yy) if not m:has(xx + 1, yy + 1) then px(xx, yy, cols[math.max(1, ci - 1)]) end end)
    px(cx - r + 1, cy - 1, cols[math.min(4, ci + 1)])
  end
end
-- a sail spread on a line between two poles: canvas panels, a bolt rope, reef points
local function hungSail(x0, x1, yt, yb, r, seed, yardTilt)
  -- a lugsail hung by its yard: the yard tilts (peak up to the right), the leech slants in, the foot is loose
  local t = yardTilt or 6
  local m = poly{ { x0, yt + t }, { x1, yt }, { x1 - 4, yb - 2 }, { x0 + 2, yb } }
  rimOf(m, r)
  m:each(function(x, y)
    local u = (x - x0) / (x1 - x0)
    local h = (u < .3) and r.hi or (u < .72 and r.base or r.shade)
    if (x - x0) % 8 == 0 then h = (u < .5) and r.shade or r.deep end -- cloth seams
    if hash(x // 2, y // 3, seed) < .04 then h = r.deep end
    local fold = math.sin((x - x0) * .55 + (y - yt) * .09 + seed)
    if fold > .75 and h == r.base then h = r.shade elseif fold < -.8 and h == r.shade then h = r.base end
    if y > yb - 4 and (x + y) % 3 == 0 then h = r.deep end
    if x - x0 < 2 then h = r.hi end
    px(x, y, h)
  end)
  -- a reef band with points, the bolt rope along the leech
  for x = x0 + 2, x1 - 4, 3 do local y = floor(yt + t + 8 - (x - x0) * t / (x1 - x0)) px(x, y, r.deep) px(x, y + 1, r.hi) end
  line({ { x1, yt + 1 }, { x1 - 4, yb - 2 } }):each(function(x, y) px(x, y, L.cork.shade) end)
  -- the yard: a spar lashed along the head, overhanging both ends
  local yard = line({ { x0 - 3, yt + t + 1 }, { x1 + 3, yt - 1 } }, 1)
  rimOf(yard, L.tar) part(yard, L.timber, { nopop = true, noshade = true })
  return m
end

---------------------------------------------------------------- sea life
F.gull(160, 84, 1) F.gull(366, 80, 1) F.gull(196, 76, 1)

---------------------------------------------------------------- road's end: plank yard + gantry crane against the sea
F.depth(2)
F.tree(188, 128, 40, 2)
F.tree(300, 128, 34, 1)
local function crane()
  -- yard: stickered stacks of sawn planks and oak keel logs waiting their turn
  plankStack(202, 226, 126, 4, L.board)
  log(246, 280, 121, 4, OAK) log(250, 284, 113, 4, L.timber) log(244, 276, 105, 3, OAK)
  local legL = line({ { 200, 126 }, { 210, 54 } }, 3):add(line({ { 220, 126 }, { 212, 54 } }, 2))
  local legR = line({ { 284, 126 }, { 274, 54 } }, 3):add(line({ { 264, 126 }, { 272, 54 } }, 2))
  local beam = rect(198, 50, 290, 55)
  local brace = line({ { 213, 70 }, { 228, 56 } }, 2):add(line({ { 271, 70 }, { 256, 56 } }, 2))
  F.shadow(200, 286, 127, 8, 3)
  rimOf(union(legL, legR, beam, brace), L.tar)
  part(legL, L.timber, { nopop = true }) part(legR, L.timber, { nopop = true }) part(brace, L.timber, { nopop = true, noshade = true })
  part(beam, L.timber) hline(198, 290, 50, L.timber.hi)
  F.logs(beam, L.timber, 50, 6)
  F.logEnd(198, 52, 2) F.logEnd(290, 52, 2)
  -- lichen on the beam top, salt-bleach and sand at the leg feet
  F.lichen(beam, .1, 31)
  rect(198, 118, 224, 126):clip(legL):each(function(x, y) if hash(x, y // 2, 32) < .4 then px(x, y, L.sand.shade) end end)
  rect(262, 118, 288, 126):clip(legR):each(function(x, y) if hash(x, y // 2, 33) < .4 then px(x, y, L.sand.shade) end end)
  -- pulley block, rope, hook, slung keel log
  local pul = rect(235, 56, 241, 63) rimOf(pul, L.tar) part(pul, OAK, { nopop = true }) fill(c:ellipse(238, 59, 1, 2), IR.base) px(237, 58, IR.hi)
  vline(237, 64, 78, L.cork.deep) vline(239, 64, 76, L.cork.deep)
  fill(rect(236, 79, 241, 80), IR.base) px(236, 79, IR.hi)
  fill(line({ { 226, 88 }, { 238, 80 }, { 252, 88 } }), L.cork.deep)
  log(214, 264, 92, 5, OAK)
  -- winch drum at the right leg, rope coiled on it
  local drum = rect(268, 106, 282, 112) rimOf(drum, L.tar) part(drum, L.cork) for x = 270, 280, 2 do vline(x, 106, 112, L.cork.deep) end
  fill(rect(282, 104, 288, 105), IR.base) fill(rect(287, 104, 288, 112), IR.base)
  vline(276, 56, 105, L.cork.deep)
  -- winch hand turning the crank
  F.gnome(296, 126, { small = true, hat = L.roof2, coat = L.wall2, arm = "out", flip = true })
  F.depth(3)
  -- quirk: a herring gull's nest of rope ends and wrack on the beam, three speckled chicks gaping
  F.sprite({
    "..y.......y.......y...",
    ".yRy.....yRy.....yRy..",
    "..gg......gg......gg..",
    ".gegs....gegs....gegs.",
    "kkggsgkkkkggskkgkkggkk",
    "rKrkqrKrkqrkKrqrkKrrqr",
    ".rqkrrqkrrqrkrqrrkqrr.",
    "..rrqrrrqrrrqrrrqrr...",
  }, 262, 42, { y = L.gold.hi, R = L.apple.base, g = L.gull.shade, s = L.gull.deep, e = L.tar.edge, k = L.kelp.base, K = L.kelp.deep,
    r = L.cork.base, q = L.cork.shade }, { rimCol = L.tar.edge })
  -- the parent gull landing on the beam beside the nest, a silver fish in its bill
  F.sprite({
    "......WWW.......",
    ".....WWWWW......",
    "....YWeWWW......",
    "..srYYWWWWW.....",
    ".sSs..WWWWWW....",
    "sSs...WWWWWWW...",
    ".s...WWGGGGGGG..",
    ".....WWGGGGGGGG.",
    "......WWGGGGwKK.",
    ".......WWWGKwKKK",
    "........WWW..KK.",
    ".........p.p....",
  }, 283, 38, { W = L.gull.hi, G = L.gull.shade, K = L.tar.deep, w = L.gull.hi, Y = L.gold.base, r = L.apple.base, e = L.tar.edge,
    p = L.petal.shade, s = IR.base, S = IR.hi }, { rimCol = L.gull.edge })
  px(290, 43, L.gull.base) px(289, 44, L.gull.base)
end
crane()

---------------------------------------------------------------- back-left: whitewashed cottage, tall tarred net shop, plank stacks, oar rack
F.depth(1)
F.tree(8, 134, 30, 0)
local ctop, ccx, cwall, croof = F.building{ x0 = 18, x1 = 56, yb = 138, wh = 24, rh = 18, wall = L.plaster, roof = L.roof, chimney = true, shingle = true, noAttic = true, noFrame = true }
F.lichen(croof, .06, 21)
F.door(32, 124, 40, 137, L.wall2)
F.window(22, 119, 27, 124, L.wall2) F.window(46, 119, 51, 124, L.wall2)
tarSmoke(47, 94, 5, 1.1) -- (peat smoke: darker, so it reads against the chalk)
-- the net shop: a tall narrow tarred-board tower with a pantiled cap and a loft door, nets hanging out of it
local ntop, ncx, nwall, nroof = F.building{ x0 = 60, x1 = 80, yb = 140, wh = 40, rh = 12, wall = L.tar, roof = L.roof2, shingle = true, noAttic = true, noFrame = true }
F.planks(nwall, L.tar, 4, true, 22)
F.pantile(nroof, L.roof2, ntop - 12, 23)
fill(rect(66, 106, 74, 116), L.tar.edge) fill(rect(67, 107, 73, 116), L.soil.deep)
F.netSwag(64, 76, 113, 12, { floatStep = 5, col = L.cork.hi, col2 = L.cork.base })
F.door(65, 126, 75, 139, L.wall2)
-- stickered plank stacks drying in the wind
F.shadow(94, 150, 141, 6, 2)
plankStack(94, 124, 140, 5, L.board)
plankStack(128, 152, 140, 4, OAK)
-- an oar and spar rack: a trestle with oars leaning, blades up
local tr = union(rect(160, 120, 161, 138), rect(192, 122, 193, 138), rect(158, 124, 196, 125))
rimOf(tr, L.tar) part(tr, L.timber, { nopop = true, noshade = true }) hline(158, 196, 124, L.timber.hi)
local DX = { 5, -3, 6, -5, 3, -2 }
for k = 0, 5 do
  local x = 164 + k * 5
  local dx = DX[k + 1]
  local ty = 108 + (k % 3) * 4
  local m = line({ { x, 138 }, { x + dx, ty } }, 1)
  local blade = rect(x + dx - 1, ty - 8, x + dx + 2, ty + 2)
  rimOf(union(m, blade), L.tar) part(m, L.board, { nopop = true, noshade = true })
  local br = ({ L.wall2, L.awnA, L.board })[k % 3 + 1]
  fill(blade, br.base) vline(x + dx + 2, ty - 8, ty + 2, br.shade) hline(x + dx - 1, x + dx + 2, ty - 8, br.hi) vline(x + dx - 1, ty - 7, ty + 1, br.hi)
end

---------------------------------------------------------------- back-right: sails spread to dry, a sailmaker stitching
local function sailyard()
  local poles = union(rect(300, 102, 301, 140), rect(336, 100, 337, 140), rect(370, 104, 371, 140))
  rimOf(poles, L.tar) part(poles, L.timber, { nopop = true, noshade = true })
  px(300, 102, L.timber.hi) px(336, 100, L.timber.hi) px(370, 104, L.timber.hi)
  hungSail(303, 334, 100, 134, L.roof2, 61, 5)         -- a barked red-ochre lugsail
  hungSail(339, 368, 98, 130, L.cork, 62, 6)           -- a tan cutch-dyed mizzen
  -- a sail laid out flat on the turf in front, the sailmaker on his knees stitching the bolt rope
  local flat = poly{ { 306, 141 }, { 356, 139 }, { 368, 146 }, { 314, 148 } }
  rimOf(flat, L.awnB) fill(flat, L.awnB.base)
  flat:each(function(x, y) if (x - 306) % 7 == 0 then px(x, y, L.awnB.shade) end if y <= 141 and x < 340 then px(x, y, L.awnB.hi) end end)
  line({ { 314, 148 }, { 368, 146 } }):each(function(x, y) px(x, y, L.cork.base) end)
  F.gnome(348, 146, { small = true, hat = L.awnA, coat = L.accent, arm = "out", flip = true })
  px(336, 140, IR.hi) px(337, 141, IR.base)            -- needle glint
  F.shadow(372, 386, 148, 4, 2)
end
sailyard()
F.depth(2)
F.tree(456, 144, 48, 2)
F.tree(438, 138, 32, 1)

---------------------------------------------------------------- left hero: hearth with the steam box under a pantiled lean-to
F.depth(3)
local function hearth()
  local posts = rect(92, 128, 95, 206):add(rect(186, 140, 189, 208))
  local roofm = poly{ { 84, 128 }, { 196, 140 }, { 196, 146 }, { 84, 134 } }
  local fire = rect(108, 172, 160, 202)
  local chim = rect(124, 84, 140, 160)
  F.shadow(94, 194, 208, 12, 5)
  rimOf(union(chim, fire), L.stone)
  part(chim, L.stone) F.courses(chim, 84, 6, 8, L.stone)
  fill(rect(122, 82, 142, 85), L.stone.shade) hline(122, 142, 82, L.stone.hi)
  F.lichen(rect(122, 82, 142, 86), .3, 34)
  part(fire, L.stone, { sep = true }) F.courses(fire, 172, 6, 11, L.stone, 5) F.lichen(fire, .08, 35)
  local mouth = c:rrect(118, 178, 150, 200, 8):clip(rect(118, 178, 150, 196))
  fill(mouth, L.soil.deep)
  local coals = c:ellipse(134, 194, 13, 4):clip(mouth)
  fill(coals, G.shade)
  coals:each(function(x, y) local v = hash(x, y, 4) if v < .3 then px(x, y, G.base) elseif v < .4 then px(x, y, G.hi) elseif v > .85 then px(x, y, G.deep) end end)
  local flame = poly{ { 122, 194 }, { 125, 186 }, { 128, 190 }, { 140, 190 }, { 143, 185 }, { 146, 194 } }
  fill(flame, G.base) fill(poly{ { 126, 194 }, { 128, 191 }, { 140, 191 }, { 142, 194 } }, G.hi)
  -- the tar pot: an iron cauldron on a trivet over the fire, black tar bubbling, a stirring stick
  local pot = c:ellipse(134, 186, 9, 6):clip(rect(124, 182, 144, 192)):add(rect(125, 181, 143, 183))
  rimOf(pot, L.tar) part(pot, IR, { nopop = true })
  pot:each(function(x, y) if x > 138 and y > 184 then px(x, y, IR.deep) elseif x < 129 and y > 183 then px(x, y, IR.base) end end)
  hline(125, 143, 181, IR.hi) hline(126, 142, 182, L.tar.deep)
  px(129, 182, L.tar.hi) px(134, 182, L.tar.hi) px(139, 182, L.tar.base) px(131, 181, L.tar.hi)
  line({ { 138, 182 }, { 146, 172 } }):each(function(x, y) px(x, y, L.timber.base) end) px(146, 171, L.timber.hi)
  hline(126, 142, 190, IR.deep) -- the trivet
  F.logEnd(121, 195, 2) F.logEnd(147, 195, 2)
  hline(114, 154, 200, L.stone.hi) hline(114, 154, 201, L.stone.deep)
  -- glow on the ground
  for y = 203, 214 do for x = 116 + (y - 203), 152 - (y - 203) do if hash(x, y, 7) < .35 then px(x, y, L.gold.hi) end end end
  -- tar drips down the pot side
  px(124, 186, L.tar.deep) px(124, 187, L.tar.deep) px(144, 185, L.tar.deep)
  -- the steam box: a long plank box on the hearth, iron straps, a rag-stuffed end leaking steam, an oak strake poking out
  local box = rect(102, 158, 178, 170)
  rimOf(box, L.tar) part(box, L.board)
  F.planks(box, L.board, 4, false, 37)
  for _, x in ipairs({ 112, 140, 168 }) do vline(x, 158, 170, IR.base) vline(x + 1, 158, 170, IR.shade) px(x, 158, IR.hi) end
  local cap = rect(99, 159, 102, 169) rimOf(cap, L.tar) part(cap, L.awnB, { nopop = true }) px(99, 160, L.awnB.hi)
  local strake = rect(178, 162, 186, 165) rimOf(strake, L.tar) part(strake, OAK, { nopop = true, noshade = true }) hline(178, 186, 162, OAK.hi)
  -- a pipe from the fire into the box
  fill(rect(150, 166, 153, 172), IR.base) px(150, 166, IR.hi)
  -- posts and roof, chimney through it
  rimOf(union(posts, roofm), L.tar)
  part(posts, L.timber, { nopop = true })
  F.logs(posts, L.timber, 128, 7)
  part(roofm, L.roof2, { sep = true })
  F.pantile(roofm, L.roof2, 128, 36) F.lichen(roofm, .1, 36)
  hline(84, 196, 134, L.roof2.deep)
  part(rect(124, 84, 140, 128):clip(chim), L.stone) F.courses(rect(124, 84, 140, 128), 84, 6, 8, L.stone)
  tarSmoke(132, 78, 9, .9)
  -- steam from the stuffed end of the box
  local st = { "#eef0ea", "#dce4e6", "#c8d4dc" }
  for k = 0, 5 do
    local x, y = 98 - k * 2 + floor(sin(k * 1.4) * 2), 156 - k * 4
    local m = c:ellipse(x, y, 2 + k // 3, 1 + k // 3)
    fill(m, st[1 + k % 3]) px(x - 1, y - 1, "#f6f6f0")
  end
  -- bent oak ribs (frames) hung on the left post to set, a coil of rope under them
  for k = 0, 2 do
    local y = 140 + k * 11
    local o = c:ellipse(100, y, 4, 5):cut(c:ellipse(100, y, 3, 4)):clip(rect(95, y, 105, y + 5))
    o:add(rect(96, y - 4, 96, y)):add(rect(104, y - 4, 104, y))
    fill(o, k == 1 and OAK.hi or OAK.base) px(96, y - 4, OAK.hi) px(104, y + 2, OAK.shade)
  end
  ropeCoil(100, 180, 4, 5, L.cork)
  -- a tiller hanging on the right post
  local run = line({ { 183, 148 }, { 183, 168 }, { 181, 172 }, { 178, 174 } }, 1)
  run:each(function(x, y) px(x, y, OAK.base) px(x + 1, y, OAK.deep) end) px(183, 147, OAK.hi)
  -- split driftwood stacked by the hearth
  F.shadow(162, 186, 203, 4, 2)
  for k = 0, 3 do F.logEnd(165 + k * 6, 199, 3) end
  for k = 0, 2 do F.logEnd(168 + k * 6, 193, 3) end
  F.logEnd(171, 187, 3) F.logEnd(177, 187, 3, OAK)
end
hearth()
-- a gnome hewing a pulley block at a stump with an adze
local function hewing(x, yb)
  F.shadow(x - 8, x + 9, yb, 8, 3)
  stump(x, yb, 7)
  local blank = rect(x - 5, yb - 13, x + 5, yb - 7)
  rimOf(blank, L.tar) part(blank, OAK) hline(x - 4, x + 4, yb - 13, OAK.hi)
  fill(c:ellipse(x, yb - 10, 1, 2), OAK.deep) vline(x - 3, yb - 12, yb - 8, OAK.shade)
  for i = 0, 9 do local sx, sy = x - 10 + floor(hash(i, 1, 21) * 22), yb - 16 - floor(hash(i, 2, 21) * 10) px(sx, sy, i % 3 == 0 and OAK.base or OAK.hi) end
  shavings(x - 14, x + 14, yb + 1, yb + 6, 14, 22)
end
hewing(168, 232)
local _, hx, hy = F.gnome(148, 238, { hat = L.awnA, coat = L.wall2, arm = "up" })
fill(rect(hx, hy - 6, hx + 1, hy + 1), L.board.base) fill(rect(hx + 1, hy - 8, hx + 5, hy - 6), IR.base) px(hx + 1, hy - 8, IR.hi) px(hx + 5, hy - 5, IR.shade) -- adze up
fill(rect(146, 228, 150, 235), L.tar.base) px(146, 228, L.tar.hi) -- tarred canvas apron
-- a grey dog asleep in the hearth's warmth
F.sprite({
  "..............e.e...",
  ".............eHHHe..",
  ".....DDDDDD..HHHHHH.",
  "..TDDDDDDDDDDHkHHHMn",
  ".TTDDdDDDDDDDHHHHMM.",
  "TTTDDDdDDDdDDDHHLL..",
  "TT.DDDDDDDDDDDLLLL..",
  "....LLdLLLLLdLLLL...",
}, 102, 210, { e = L.stone.deep, D = L.stone.base, d = L.stone.shade, H = L.stone.hi, k = L.timber.edge, M = L.stone.deep,
  n = L.timber.edge, T = L.stone.shade, L = L.awnB.shade })
local qb = F.barrel(196, 236, L.timber, 12) fill(rect(192, 225, 200, 226), L.water.base) px(193, 225, L.water.hi)
-- a tin dipper hooked on the water butt
fill(rect(199, 222, 202, 223), IR.hi) vline(202, 220, 222, IR.shade)

---------------------------------------------------------------- right hero: the tarred boat shed, open front, a half-built clinker boat
local function boatShed()
  local x0, x1, yb = 296, 446, 208
  local top, cx, wallM, roofM = F.building{ x0 = x0, x1 = x1, yb = yb, wh = 56, rh = 36, wall = L.tar, roof = L.roof, shingle = true, noFrame = true, noAttic = true }
  F.planks(wallM, L.tar, 5, true, 38)
  local gab = poly{ { x0 + 5, top }, { cx, top - 36 + 8 }, { x1 - 5, top } }:cut(roofM)
  F.planks(gab, L.tar, 5, true, 39)
  -- a sea-blue loft door in the gable with a hoist beam
  local ld = rect(cx - 6, top - 20, cx + 6, top - 2) rimOf(ld, L.tar) part(ld, L.wall2) vline(cx, top - 19, top - 3, L.wall2.deep)
  hline(cx - 6, cx + 6, top - 20, L.wall2.hi) px(cx - 3, top - 11, IR.base) px(cx + 3, top - 11, IR.base)
  local hb = rect(cx - 2, top - 26, cx + 2, top - 23) rimOf(hb, L.tar) part(hb, L.timber, { nopop = true, noshade = true })
  F.lichen(roofM, .07, 38)
  -- white corner boards and a whitewashed plinth (the shed is tarred, its trim is painted)
  local trim = union(rect(x0, top, x0 + 2, yb), rect(x1 - 2, top, x1, yb))
  part(trim, L.plaster, { nopop = true, noshade = true }) vline(x0 + 2, top, yb, L.plaster.shade) vline(x1, top, yb, L.plaster.shade)
  wallM:each(function(x, y) if y > yb - 5 and hash(x, y // 2, 40) < .45 then px(x, y, hash(x, y, 41) < .5 and L.sand.shade or L.sand.base) end end)
  F.barnacles(rect(x0, yb - 4, x1, yb):clip(wallM), .05, 42)
  -- window, left of the doorway, with a box of thrift
  F.window(303, 172, 314, 183, L.wall2)
  hline(301, 316, 186, L.wall2.base) hline(301, 316, 187, L.wall2.deep)
  for k = 0, 5 do px(303 + k * 2, 185, L.leaf.shade) px(304 + k * 2, 184, L.petal.base) px(303 + k * 2, 183, L.petal.hi) end
  -- the big open doorway with the interior
  local dx0, dx1, dy0 = 322, 420, 164
  local fr = rect(dx0 - 3, dy0 - 3, dx1 + 3, yb)
  fill(fr, L.wall2.base) hline(dx0 - 3, dx1 + 3, dy0 - 3, L.wall2.hi) hline(dx0 - 3, dx1 + 3, dy0 - 1, L.wall2.deep)
  vline(dx0 - 3, dy0 - 3, yb, L.wall2.hi) vline(dx1 + 3, dy0 - 3, yb, L.wall2.deep)
  fill(rect(dx0, dy0, dx1, yb), L.soil.deep)
  fill(rect(dx0, yb - 6, dx1, yb), L.soil.shade)
  for x = dx0 + 4, dx1, 8 do vline(x, dy0, yb - 7, L.soil.edge) end
  -- a tie beam inside with clamps, blocks and a coil hanging from it
  hline(dx0, dx1, dy0 + 4, L.soil.base) hline(dx0, dx1, dy0 + 5, L.soil.edge)
  for k = 0, 5 do -- C-clamps on the beam
    local x = 328 + k * 5
    vline(x, dy0 + 6, dy0 + 11, IR.base) hline(x, x + 2, dy0 + 6, IR.base) hline(x, x + 2, dy0 + 11, IR.shade) vline(x + 2, dy0 + 9, dy0 + 12, L.timber.base) px(x, dy0 + 6, IR.hi)
  end
  for _, b in ipairs({ { 364, 8 }, { 372, 11 } }) do -- pulley blocks
    vline(b[1], dy0 + 6, dy0 + b[2], L.cork.deep)
    local bm = c:ellipse(b[1], dy0 + b[2] + 3, 2, 3) rimOf(bm, L.tar) part(bm, OAK, { nopop = true }) px(b[1], dy0 + b[2] + 3, IR.base)
  end
  ropeCoil(410, dy0 + 12, 4, 4, L.cork)
  vline(410, dy0 + 6, dy0 + 8, L.cork.deep)
  -- hanging lantern
  vline(392, dy0 + 6, dy0 + 8, L.timber.edge) local ln = rect(390, dy0 + 9, 394, dy0 + 13) rimOf(ln, IR) fill(ln, G.base) px(390, dy0 + 9, G.hi) px(394, dy0 + 13, G.shade)
  for y = dy0 + 14, dy0 + 18 do for x = 386, 398 do if hash(x, y, 77) < .12 then px(x, y, L.soil.base) end end end

  -- THE BOAT: a clinker hull on stocks, bow to the right; lower strakes planked and riveted, the upper ribs still bare
  local keelY = 201
  local X0, X1 = 326, 402                               -- transom .. foot of the stem
  local function sheer(x) local t = (x - X0) / (X1 + 8 - X0) return 181 - 9 * (2 * t - 1) ^ 2 - (t > .85 and (t - .85) * 30 or 0) end
  local function bottom(x)
    if x > 396 then return keelY - ((x - 396) / 14) ^ 1.8 * 24 end
    if x < 336 then return keelY - (336 - x) * .5 end
    return keelY
  end
  local hull = HP.mask()
  for x = X0, X1 + 12 do local yt, ybt = floor(sheer(x)), floor(bottom(x)) if ybt >= yt then for y = yt, ybt do hull:set(x, y) end end end
  local stemPts = {}
  for x = 396, 412 do stemPts[#stemPts + 1] = { x, floor(bottom(x)) + 1 } end
  stemPts[#stemPts + 1] = { 413, 164 }
  local stem = line(stemPts, 2)
  local transom = rect(X0 - 3, 170, X0, 196)
  local keel = rect(334, keelY + 1, 398, keelY + 2)
  local stocks = rect(342, keelY + 3, 350, yb - 1):add(rect(380, keelY + 3, 388, yb - 1))
  local shores = line({ { 334, yb - 1 }, { 342, 192 } }, 1):add(line({ { 396, yb - 1 }, { 388, 190 } }, 1))
  rimOf(union(hull, stem, transom, keel, stocks, shores), L.tar)
  part(stocks, L.timber, { nopop = true }) hline(342, 350, keelY + 3, L.timber.hi) hline(380, 388, keelY + 3, L.timber.hi)
  part(shores, L.timber, { nopop = true, noshade = true })
  local function plankTop(x) return sheer(x) + (bottom(x) - sheer(x)) * .42 end
  -- the open upper hull: dark shed seen between bare ribs, the inwale along the top
  hull:each(function(x, y)
    local h = L.soil.deep
    local k = (x - X0 - 2) % 6
    if k == 0 then h = OAK.hi elseif k == 1 then h = OAK.shade elseif k == 4 and y > sheer(x) + 3 then h = L.soil.shade end -- near rib / far rib
    if y <= floor(sheer(x)) + 1 then h = (y == floor(sheer(x))) and OAK.hi or OAK.base end
    px(x, y, h)
  end)
  -- strakes: four overlapping planks, each lit along its top, its lower land throwing a dark line on the one below;
  -- the hull darkens toward the keel (the bilge turns under) and at the bow (it turns away from the light)
  local NS = 4
  hull:each(function(x, y)
    local pt, bt = plankTop(x), bottom(x)
    if y >= pt then
      local f = (y - pt) / math.max(1, bt - pt + 1) * NS
      local k, fr_ = floor(f), f - floor(f)
      local h
      if fr_ * ((bt - pt + 1) / NS) < 1 then h = (k == 0) and OAK.hi or OAK.base
      elseif fr_ > .8 then h = OAK.deep
      else h = (k <= 1) and OAK.base or OAK.shade end
      if x > 398 and h == OAK.base then h = OAK.shade end
      if x < 334 and h == OAK.shade then h = OAK.base end
      px(x, y, h)
    end
  end)
  -- copper roves glinting along the lands
  for x = 336, 398, 6 do
    local pt, bt = plankTop(x), bottom(x)
    for k = 1, NS - 1 do local y = floor(pt + (bt - pt + 1) * k / NS) - 1 if hull:has(x, y) and ((x - 336) // 6 + k) % 2 == 0 then px(x, y, L.produce.hi) end end
  end
  for x = X0 + 1, X1 + 10 do local y = floor(plankTop(x)) if hull:has(x, y - 1) then px(x, y - 1, L.tar.deep) end end
  part(stem, OAK, { nopop = true, noshade = true }) stem:each(function(x, y) if not stem:has(x - 1, y) then px(x, y, OAK.hi) end end)
  part(transom, OAK, { nopop = true }) vline(X0 - 3, 170, 196, OAK.hi)
  part(keel, OAK, { nopop = true, noshade = true }) hline(334, 398, keelY + 2, OAK.deep)
  -- the next strake clamped on, waiting to be riveted
  for _, x in ipairs({ 352, 372 }) do local y = floor(plankTop(x)) vline(x, y - 4, y + 2, IR.hi) hline(x, x + 2, y - 4, IR.base) hline(x, x + 2, y + 2, IR.shade) end
  -- the rivetting gnome at the bow with a hammer up; the holder-up inside the hull, only his hat and face showing
  local _, bhx, bhy = F.gnome(414, 208, { hat = L.produce, coat = L.wall2, arm = "up", flip = true, noShadow = true })
  fill(rect(bhx - 1, bhy - 3, bhx, bhy + 2), L.timber.base) fill(rect(bhx - 3, bhy - 5, bhx + 2, bhy - 3), IR.base) px(bhx - 3, bhy - 5, IR.hi)
  F.sprite({
    "....hh..",
    "...hhH..",
    "..hhhH..",
    ".HHHHHH.",
    "..ssss..",
    "..ebeb..",
    "..wwww..",
  }, 356, 168, { h = L.awnA.base, H = L.awnA.deep, s = L.skin.base, e = L.timber.edge, b = L.skin.shade, w = L.awnB.hi }, { rimCol = L.timber.edge })
  px(357, 171, L.awnA.hi)
  shavings(326, 418, 202, 207, 26, 43)
  -- sign above the doorway: a little clinker boat painted on a board
  local sb = rect(350, 146, 392, 157) rimOf(sb, L.tar) part(sb, L.wall2) hline(350, 392, 146, L.wall2.hi)
  F.sprite({
    "..........m........",
    "..........mSS......",
    "..........mSSS.....",
    "..........mSSSS....",
    "rrrrrrrrrrrrrrrrrr.",
    ".bbbbbbbbbbbbbbbb..",
    "...bbbbbbbbbbbb....",
  }, 362, 148, { r = L.awnA.base, b = L.awnB.hi, m = L.tar.base, S = L.roof2.base }, { rim = false })
  -- right wall: a peg rail of caulking irons, a saw and a mallet
  hline(424, 444, 170, L.timber.deep) hline(424, 444, 169, L.timber.hi)
  for k = 0, 3 do local x = 426 + k * 3 vline(x, 171, 177, L.board.base) fill(rect(x - 1, 178, x + 1, 179), IR.hi) px(x, 171, L.board.hi) end
  local saw = poly{ { 438, 171 }, { 444, 171 }, { 443, 184 }, { 438, 182 } } fill(saw, IR.hi) saw:each(function(x, y) if x == 444 or (x == 443 and y % 2 == 0) then px(x, y, IR.shade) end end)
  fill(rect(437, 171, 439, 174), OAK.base)
  -- name on the plinth? no lettering: a row of rivet heads along the doorframe foot
  for x = dx0, dx1, 6 do px(x, yb - 1, L.produce.shade) end
end
boatShed()
-- a grindstone for the edges, against the right wall
local function grindstone(x, yb)
  local frame = rect(x - 12, yb - 12, x - 10, yb):add(rect(x + 10, yb - 12, x + 12, yb)):add(rect(x - 12, yb - 4, x + 12, yb - 3))
  local stone = c:ellipse(x, yb - 20, 10, 10)
  local trough = rect(x - 9, yb - 8, x + 9, yb - 4)
  F.shadow(x - 12, x + 12, yb, 6, 2)
  rimOf(union(frame, stone, trough), L.tar)
  part(frame, L.timber, { nopop = true, noshade = true })
  part(trough, L.timber) fill(rect(x - 8, yb - 8, x + 8, yb - 7), L.water.base)
  part(stone, L.stone)
  c:ellipse(x, yb - 20, 7, 7):edge():each(function(xx, yy) px(xx, yy, L.stone.shade) end)
  F.lichen(stone, .04, 45)
  fill(c:ellipse(x, yb - 20, 2, 2), IR.base) px(x - 1, yb - 21, IR.hi)
  fill(rect(x + 2, yb - 21, x + 14, yb - 20), IR.base) fill(rect(x + 13, yb - 21, x + 14, yb - 13), IR.base) fill(rect(x + 13, yb - 14, x + 17, yb - 13), L.board.base)
end
grindstone(432, 226)

---------------------------------------------------------------- foreground left: plank ends, tar barrel, the sawhorse bench with a strake being planed
F.shadow(26, 80, 204, 8, 3)
for row = 0, 3 do for k = 0, 4 - row do
  F.logEnd(30 + k * 10 + row * 5, 198 - row * 8, 5, (k + row) % 3 == 0 and OAK or L.timber)
end end
F.lichen(rect(40, 170, 70, 176), .12, 46)
-- a herring gull standing on top of the plank-end pile, eyeing the dog
F.sprite({
  "..WWW.....",
  ".WWWWW....",
  "YYeWWWW...",
  "r..WWWWWW.",
  "...WWGGGGG",
  "...WWGGGKK",
  "....WWWKK.",
  ".....p.p..",
}, 50, 166, { W = L.gull.hi, G = L.gull.shade, K = L.tar.deep, Y = L.gold.base, r = L.apple.base, e = L.tar.edge, p = L.petal.shade }, { rimCol = L.gull.edge })
px(53, 170, L.gull.base) px(54, 171, L.gull.base)
-- the tar barrel: black, drips down its side, a brush in it
local tb = F.barrel(84, 202, L.tar, 11)
for _, d in ipairs({ { 81, 4 }, { 85, 6 }, { 88, 3 } }) do vline(d[1], 192, 192 + d[2], L.tar.deep) px(d[1], 192 + d[2] + 1, L.tar.edge) end
fill(rect(80, 190, 88, 191), L.tar.deep) px(81, 190, L.tar.hi)
line({ { 86, 190 }, { 90, 182 } }):each(function(x, y) px(x, y, L.timber.base) end) fill(rect(89, 180, 91, 182), L.cork.base)
-- the sawhorse bench: two trestles, a long oak strake on them, a gnome pushing a plane along it
local function sawhorse(x, yb)
  local m = line({ { x - 5, yb }, { x - 1, yb - 12 } }, 2):add(line({ { x + 5, yb }, { x + 1, yb - 12 } }, 2)):add(rect(x - 5, yb - 14, x + 5, yb - 12)):add(rect(x - 3, yb - 6, x + 3, yb - 5))
  rimOf(m, L.tar) part(m, L.timber, { nopop = true, noshade = true }) hline(x - 5, x + 5, yb - 14, L.timber.hi)
end
F.shadow(20, 100, 256, 8, 3)
sawhorse(30, 256) sawhorse(78, 254)
local pl = poly{ { 16, 241 }, { 96, 238 }, { 96, 242 }, { 16, 245 } }
rimOf(pl, L.tar) part(pl, OAK, { nopop = true })
line({ { 16, 241 }, { 96, 238 } }):each(function(x, y) px(x, y + 1, OAK.hi) end)
line({ { 16, 245 }, { 96, 242 } }):each(function(x, y) px(x, y - 1, OAK.shade) end)
for x = 20, 92, 9 do px(x, 243 - floor((x - 16) / 27), OAK.deep) end -- grain knots
local _, ox, oy = F.gnome(62, 236, { hat = L.roof2, coat = L.accent, arm = "out" })
local plane = rect(ox - 2, 234, ox + 5, 238) rimOf(plane, L.tar) part(plane, OAK, { nopop = true }) fill(rect(ox + 1, 232, ox + 2, 233), IR.hi)
-- a long curl of shaving springing off the plane
for i = 0, 6 do px(ox - 3 - i, 235 - floor(sin(i * .9) * 2), L.board.hi) px(ox - 3 - i, 236 - floor(sin(i * .9) * 2), L.board.shade) end
shavings(16, 100, 247, 262, 26, 52)
-- a stack of copper roves in a bucket and a rope coil by the bench
local bk = c:rrect(104, 252, 114, 262, 2) rimOf(bk, L.tar) part(bk, L.timber, { nopop = true })
hline(104, 114, 255, IR.shade) hline(104, 114, 260, IR.shade)
for x = 105, 113 do px(x, 252, (x % 2 == 0) and L.produce.hi or L.produce.shade) px(x, 251, (x % 3 == 0) and L.produce.base or L.produce.shade) end
ropeCoil(126, 258, 8, 3, L.cork)
F.lobsterPot(20, 226, 6)
F.wrack(100, 246, 6, 3) F.wrack(132, 246, 5, 7)

---------------------------------------------------------------- foreground right: sea chest, blocks, rope, a toy boat
F.depth(3)
-- a painted sea chest with rope beckets
local sc = rect(300, 230, 324, 242) rimOf(sc, L.tar) part(sc, L.accent)
local lid = rect(299, 227, 325, 231) rimOf(lid, L.tar) part(lid, L.accent, { nopop = true }) hline(299, 325, 227, L.accent.hi) hline(299, 325, 231, L.accent.deep)
for _, x in ipairs({ 305, 319 }) do vline(x, 232, 241, L.accent.deep) end
fill(rect(311, 233, 313, 236), L.gold.base) px(311, 233, L.gold.hi)
px(298, 235, L.cork.base) px(297, 236, L.cork.base) px(298, 237, L.cork.base) px(326, 235, L.cork.shade) px(327, 236, L.cork.shade) px(326, 237, L.cork.shade)
-- a pair of rigging blocks and a coil of rope on the chest
ropeCoil(314, 225, 6, 2, L.cork)
local b1 = c:ellipse(304, 224, 2, 3) rimOf(b1, L.tar) part(b1, OAK, { nopop = true }) px(304, 224, IR.base)
-- a pull-along toy boat on wheels with its string
F.sprite({
  "....m.....",
  "....mSS...",
  "....mSSS..",
  "rrrrrrrrrr",
  ".bbbbbbbb.",
  "..BBBBBB..",
  "..w....w..",
}, 286, 248, { m = L.tar.base, S = L.awnB.hi, r = L.awnA.base, b = L.wall2.base, B = L.wall2.deep, w = L.timber.deep }, { rimCol = L.tar.edge })
line({ { 296, 254 }, { 302, 252 }, { 310, 256 }, { 314, 255 } }):each(function(x, y) px(x, y, L.cork.deep) end)
-- a big coil of hemp rope and a stack of lobster-pot hoops
ropeCoil(352, 246, 12, 5, L.cork)
ropeCoil(338, 260, 7, 3, L.cork)
F.lobsterPot(368, 226, 7)
-- marram, thrift and shells (keep clear of the compass corner x>=380, y>=230)
for _, f in ipairs({ { 264, 262, 7 }, { 276, 266, 8 }, { 120, 236, 6 }, { 138, 266, 6 }, { 8, 262, 8 }, { 372, 214, 6 }, { 292, 214, 5 }, { 452, 220, 6 } }) do F.marram(f[1], f[2], f[3]) end
F.thrift(150, 262, true) F.thrift(206, 214, true) F.thrift(212, 217, false) F.thrift(284, 232, true) F.thrift(334, 270 - 6, false)
F.shell(160, 256, true) F.shell(166, 259, false) F.shell(372, 260, true) F.shell(296, 264, false)
F.pebbles(196, 262, 4, 9)

---------------------------------------------------------------- the carrier: a gnome bringing a pair of oars along the road
local _, cx1, cy1 = F.gnome(276, 214, { hat = L.roof2, coat = L.awnA, arm = "up" })
local oars = line({ { cx1 - 18, cy1 + 11 }, { cx1 + 14, cy1 - 5 } }, 2)
local blades = poly{ { cx1 + 12, cy1 - 8 }, { cx1 + 20, cy1 - 12 }, { cx1 + 22, cy1 - 7 }, { cx1 + 15, cy1 - 2 } }
rimOf(union(oars, blades), L.tar) part(oars, L.board, { nopop = true }) part(blades, L.wall2, { nopop = true })
hline(cx1 + 14, cx1 + 19, cy1 - 9, L.wall2.hi)
-- shavings trail along the left verge
shavings(200, 236, 238, 262, 14, 54)

F.depth(0)
F.gull(330, 32, 3) F.gull(346, 40, 2) F.gull(168, 48, 2) F.gull(150, 40, 2) F.gull(420, 96, 1)
-- a driftwood chopping block with an adze stuck in it (left of the road)
F.depth(3)
local cb = log(176, 198, 256, 6, L.timber)
F.lichen(cb, .08, 55)
local axe = line({ { 186, 248 }, { 196, 236 } }, 2) rimOf(axe, L.tar) fill(axe, L.board.base)
fill(poly{ { 193, 234 }, { 200, 230 }, { 201, 238 } }, IR.hi) px(200, 237, IR.shade) px(195, 234, IR.base)
for _, s in ipairs({ { 166, 262 }, { 204, 264 } }) do
  local m = poly{ { s[1], s[2] }, { s[1] + 5, s[2] - 2 }, { s[1] + 6, s[2] }, { s[1] + 1, s[2] + 2 } }
  rimOf(m, L.tar) fill(m, L.board.base) px(s[1] + 1, s[2], L.board.hi) px(s[1] + 5, s[2] - 1, L.timber.base)
end
F.finish()
