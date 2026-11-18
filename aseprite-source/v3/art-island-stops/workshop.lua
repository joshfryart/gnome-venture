-- workshop.lua : "Workshop" stop look, ISLAND (island_palm), 480x270 gate view.
-- Same composition as the Maplewold workshop (art-2701-batch3/stops/opus3/workshop.lua), re-cast as a coral island's
-- canoe carver's and net weaver's yard (no iron forge, no saws: shell and stone tools, coconut-fibre rope, lashings):
-- road's end: shear-leg gantry of lashed palm-trunk poles hoisting a breadfruit log (a future hull) over a yard of
-- ringed coconut trunks and a roughed-out hull, a windlass wound with sennit. Back left: an open thatched canoe shed
-- with an outrigger canoe under it, stacked bamboo poles, a rack of sennit hanks drying. Back right: an outrigger
-- frame on trestles (booms being lashed), a float log, paddles leaning. Left hero: a coral-stone hearth under a
-- thatched lean-to where breadfruit-gum caulk bubbles in a pot; shell adzes and rope coils on the posts, a pile of
-- husk fuel, a little island pig asleep in the warmth. Right hero: the bamboo net-weaving hall, open front: a net
-- with floats on the back wall, a tool wall of shell scrapers, netting needles, a stone adze and fish hooks, the
-- weaver at the bench with a net spilling to the floor, drying fish and a fish trap outside, a carved fish sign.
-- Foreground: the half-carved dugout on log chocks (hollowed half, raw log half, embers burning out the hollow),
-- a gnome with a shell adze, chips everywhere; a gnome shaping a paddle on a block; bamboo pole ends, a water jar,
-- coils of sennit, a basket of shell tools, a heap of net with floats, a lava whetstone, a carrier with a paddle.
-- Quirk: a red-footed booby wearing a little red gnome hat brings a fish to its three fluffy chicks in a seaweed
-- nest on the gantry beam.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-island-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "workshop", out = DIR, farTrees = { 24, 52, 150, 330, 352, 440 },
  treeLineGap = { 196, 292 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local G = L.glow
local BLUE = "#6aa2e6"
-- tamanu (island mahogany): the red-brown wood of the hulls and paddles
local TAM = { hi = "#e8b07e", base = "#c47c52", shade = "#9a5a3e", deep = "#6c3a2e", edge = "#42221e" }

---------------------------------------------------------------- local helpers
-- a log lying left-right: bark ramp, pale end grain on the right
local function log(x0, x1, y, r, bark, heart)
  bark = bark or L.coconut
  heart = heart or L.redbark
  local m = c:rrect(x0, y - r, x1, y + r, r)
  rimOf(m, bark) part(m, bark, { nopop = true })
  m:each(function(x, yy) if hash(x // 3, yy, 17) < .2 then px(x, yy, bark.shade) elseif hash(x // 2, yy, 18) < .07 then px(x, yy, bark.hi) end end)
  hline(x0 + r, x1 - r, y - r + 1, bark.hi)
  local e = c:ellipse(x1 - r + 1, y, math.max(1, r - 1), r)
  fill(e, heart.base)
  e:each(function(xx, yy) local d = math.sqrt((xx - x1 + r - 1) ^ 2 + (yy - y) ^ 2) if floor(d) % 2 == 1 then px(xx, yy, heart.shade) end if (xx - x1 + r) + (yy - y) < -r * .6 then px(xx, yy, heart.hi) end end)
  px(x1 - r + 1, y, heart.deep)
  return m
end
-- a coconut trunk lying: grey-tan with close ring scars
local function palmLog(x0, x1, y, r)
  local m = c:rrect(x0, y - r, x1, y + r, r)
  rimOf(m, L.palmTrunk) part(m, L.palmTrunk, { nopop = true })
  m:each(function(x, yy) if (x - x0) % 3 == 0 then px(x, yy, L.palmTrunk.shade) elseif (x - x0) % 3 == 1 and yy < y then px(x, yy, L.palmTrunk.hi) end end)
  local e = c:ellipse(x1 - r + 1, y, math.max(1, r - 1), r) fill(e, L.palmTrunk.hi)
  e:each(function(xx, yy) if hash(xx, yy, 19) < .35 then px(xx, yy, L.rope.base) end end)
  px(x1 - r + 1, y, L.palmTrunk.shade)
  return m
end
-- a lashing: crossed turns of coconut-fibre rope over a joint
local function lash(x, y, w, h)
  for yy = y, y + h - 1 do
    for xx = x, x + w - 1 do
      local k = (xx + yy) % 3
      px(xx, yy, k == 0 and L.rope.deep or (k == 1 and L.rope.base or L.rope.hi))
    end
  end
  px(x - 1, y + h // 2, L.rope.shade) px(x + w, y + h // 2, L.rope.shade)
end
-- horizontal bamboo poles stacked, hollow ends showing on the right
local function bamboStack(x0, x1, yb, n)
  for k = 0, n - 1 do
    local y = yb - k * 3
    local xa, xb = x0 + (k % 2) * 3, x1 - (k % 3) * 2
    local m = rect(xa, y - 2, xb, y)
    rimOf(m, L.board)
    F.bamboo(m, L.board, 3, { horizontal = true })
    px(xb, y - 1, L.board.deep) px(xb, y - 2, L.board.hi) px(xb, y, L.board.shade)
  end
end
-- curled wood chips: little hooked strokes
local function chips(x0, x1, y0, y1, n, seed, r)
  r = r or L.redbark
  for i = 1, n do
    local x, y = x0 + floor(hash(i, 1, seed) * (x1 - x0)), y0 + floor(hash(i, 2, seed) * (y1 - y0))
    local d = hash(i, 3, seed) < .5 and 1 or -1
    px(x, y, r.hi) px(x + d, y, r.base) if hash(i, 5, seed) < .6 then px(x + d, y - 1, r.hi) end
    if hash(i, 4, seed) < .5 then px(x, y + 1, r.shade) end
  end
end
-- a coil of sennit (coconut-fibre rope) lying flat
local function coil(x, y, r)
  local m = c:ellipse(x, y, r, math.max(2, floor(r * .5)))
  rimOf(m, L.rope) fill(m, L.rope.base)
  for k = r - 1, 1, -2 do
    c:ellipse(x, y, k, math.max(1, floor(k * .5))):edge():each(function(xx, yy) px(xx, yy, yy < y and L.rope.shade or L.rope.deep) end)
  end
  m:each(function(xx, yy) if (xx - x) + (yy - y) * 2 < -r and hash(xx, yy, 23) < .6 then px(xx, yy, L.rope.hi) end end)
  fill(c:ellipse(x, y, 1, 0), L.coconut.deep)
  -- the loose end trailing off
  line({ { x + r - 1, y + 1 }, { x + r + 4, y + 3 }, { x + r + 7, y + 2 } }):each(function(xx, yy) px(xx, yy, L.rope.shade) end)
  return m
end
-- a canoe paddle: leaf blade, shaft, T grip. (x, yb) = blade tip; leans by dx over its length
local function paddle(x, yb, len, dx, r, stripe)
  r = r or L.redbark
  local tx = x + dx
  local shaft = line({ { x, yb - 8 }, { tx, yb - len } }, 1)
  local blade = c:ellipse(x, yb - 5, 2, 5)
  local grip = rect(tx - 2, yb - len - 1, tx + 2, yb - len)
  local m = union(shaft, blade, grip)
  rimOf(m, L.timber) part(m, r, { nopop = true })
  shaft:each(function(xx, yy) px(xx, yy, r.hi) end)
  if stripe then hline(x - 1, x + 1, yb - 7, stripe.base) hline(x - 1, x + 1, yb - 4, stripe.base) end
  return m
end

---------------------------------------------------------------- road's end: the hull yard + shear-leg gantry of lashed palm poles
F.depth(2)
F.tree(186, 128, 50, 2)
F.tree(304, 130, 48, 0)
local function gantry()
  -- the yard: a roughed-out hull on chocks, coconut trunks and a breadfruit log waiting
  local hull = poly{ { 202, 118 }, { 238, 118 }, { 236, 124 }, { 206, 124 } }
  rimOf(hull, TAM) part(hull, TAM)
  hline(203, 237, 118, TAM.hi) hline(206, 230, 119, TAM.deep) hline(207, 229, 120, TAM.shade)
  for x = 206, 234, 3 do px(x, 122, TAM.shade) end
  palmLog(248, 280, 120, 4) palmLog(252, 284, 112, 4) log(244, 274, 104, 3)
  local legL = line({ { 200, 126 }, { 210, 54 } }, 3):add(line({ { 220, 126 }, { 212, 54 } }, 2))
  local legR = line({ { 284, 126 }, { 274, 54 } }, 3):add(line({ { 264, 126 }, { 272, 54 } }, 2))
  local beam = rect(198, 50, 290, 55)
  local brace = line({ { 213, 70 }, { 228, 56 } }, 2):add(line({ { 271, 70 }, { 256, 56 } }, 2))
  F.shadow(200, 286, 127, 8, 3)
  rimOf(union(legL, legR, beam, brace), L.timber)
  -- palm-trunk legs with ring scars, driftwood beam and braces
  part(legL, L.palmTrunk, { nopop = true }) part(legR, L.palmTrunk, { nopop = true })
  union(legL, legR):each(function(x, y) if y % 3 == 0 then px(x, y, L.palmTrunk.shade) end end)
  part(brace, L.timber, { nopop = true, noshade = true })
  part(beam, L.timber) hline(198, 290, 50, L.timber.hi)
  beam:each(function(x, y) if y > 50 and hash(x // 4, y, 24) < .2 then px(x, y, L.timber.shade) end end)
  -- coconut-rope lashings at every joint
  lash(206, 52, 7, 4) lash(270, 52, 7, 4) lash(219, 59, 4, 3) lash(260, 59, 4, 3)
  lash(209, 69, 4, 3) lash(270, 69, 4, 3)
  -- a carved wooden block pulley, sennit falls, a rope sling round the log
  local pul = c:rrect(234, 56, 242, 64, 2) rimOf(pul, L.timber) part(pul, L.redbark) fill(c:ellipse(238, 60, 1, 1), L.redbark.deep)
  vline(236, 64, 84, L.rope.shade) vline(240, 64, 82, L.rope.deep)
  fill(line({ { 226, 88 }, { 238, 82 }, { 252, 88 } }), L.rope.shade)
  log(216, 262, 92, 5, L.coconut, L.produce)
  lash(225, 87, 3, 10) lash(250, 87, 3, 10)
  -- windlass at the right leg, wound with sennit
  local drum = rect(268, 106, 282, 112) rimOf(drum, L.timber) part(drum, L.rope)
  for x = 269, 281 do if x % 2 == 0 then vline(x, 106, 112, L.rope.shade) end end
  local cr = line({ { 283, 109 }, { 289, 103 } }):add(line({ { 283, 109 }, { 289, 115 } })) fill(cr, L.timber.base)
  vline(276, 64, 105, L.rope.shade)
  -- winch hand turning the windlass
  F.gnome(296, 126, { small = true, hat = L.roof2, coat = L.leaf, arm = "out", flip = true })
  F.depth(3)
  -- quirk: a seaweed-and-twig nest on the beam, three fluffy booby chicks gaping
  F.sprite({
    "..y.......y.......y...",
    ".yYy.....yYy.....yYy..",
    "..ww......ww......ww..",
    ".wewW....wewW....wewW.",
    "nnwwWsnnnnwwWnnsnnwwWn",
    "nNsnNnNnsNnnNsNnnNsnNn",
    ".nNnsnNnnnNnsnNnnnNnn.",
    "..nnNnnsNnnnNnnsNnn...",
  }, 262, 42, { y = L.gold.hi, Y = BLUE, w = L.awnB.hi, W = L.awnB.base, e = L.timber.edge, n = L.needle.base, N = L.needle.shade,
    s = L.seagrass.base })
  -- the parent: a red-footed booby in a little red gnome hat, a silver fish in its blue bill
  F.sprite({
    "..........R.....",
    ".........RRr....",
    "........RRRr....",
    ".......hhhhhh...",
    "......wwwwwww...",
    "..ffbbwewwwWw...",
    ".fFf..wwwwwwBB..",
    "..f...wwwwBBBBB.",
    "......wwWBBBBBBB",
    ".......wWBBBBB..",
    "........oo.o....",
  }, 280, 39, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, w = L.awnB.hi, W = L.awnB.base, e = L.timber.edge,
    b = BLUE, f = L.iron.hi, F = L.iron.base, B = L.coconut.base, o = L.awnA.base })
  px(291, 40, L.awnA.hi) px(282, 46, L.iron.shade)
end
gantry()

---------------------------------------------------------------- back-left: open canoe shed, bamboo poles, sennit drying rack
F.depth(1)
F.tree(86, 130, 40, 4)
F.tree(8, 136, 38, 3)
local function shed()
  local roofM = poly{ { 12, 122 }, { 44, 102 }, { 78, 122 } }:add(rect(12, 120, 78, 124))
  local posts = rect(18, 122, 20, 140):add(rect(70, 122, 72, 140)):add(rect(44, 112, 45, 140))
  local back = rect(21, 124, 69, 137)
  rimOf(union(roofM, posts, back), L.timber)
  -- woven pandanus back wall in shade
  back:each(function(x, y) local wv = ((x // 2 + y // 2) % 2 == 0) px(x, y, wv and L.needle.shade or L.needle.deep) end)
  part(posts, L.timber, { nopop = true, noshade = true })
  part(roofM, L.roof, { sep = true }) F.thatch(roofM, L.roof, 102, 44)
  line({ { 13, 121 }, { 43, 103 } }):each(function(x, y) if roofM:has(x, y) then px(x, y, L.roof.hi) end end)
  hline(12, 78, 124, L.roof.deep)
  -- ridge: crossed palm ribs
  line({ { 40, 98 }, { 48, 106 } }):each(function(x, y) px(x, y, L.timber.base) end) line({ { 48, 98 }, { 40, 106 } }):each(function(x, y) px(x, y, L.timber.shade) end)
  -- the outrigger canoe resting under it
  F.outrigger(24, 66, 134, { side = 1, stripe = L.awnA })
  -- paddles leaning on the post
  paddle(74, 140, 18, -3, TAM, L.wall2)
end
shed()
F.parrot(30, 92, "lory")
bamboStack(96, 150, 140, 5)
-- a rack of sennit hanks drying on a bamboo rail
local function sennitRack(x0, x1, yb)
  local m = rect(x0, yb - 14, x0 + 1, yb):add(rect(x1 - 1, yb - 14, x1, yb)):add(rect(x0, yb - 14, x1, yb - 13))
  rimOf(m, L.board) part(m, L.board, { nopop = true, noshade = true })
  for x = x0 + 4, x1 - 4, 5 do
    local h = rect(x, yb - 12, x + 2, yb - 4 + (x % 3))
    rimOf(h, L.rope) part(h, L.rope, { nopop = true })
    vline(x + 1, yb - 12, yb - 5, L.rope.shade)
  end
end
sennitRack(156, 194, 136)

---------------------------------------------------------------- back-right: an outrigger frame on trestles, booms being lashed
local function frame()
  -- the hull on trestles
  local hull = poly{ { 300, 124 }, { 350, 124 }, { 356, 120 }, { 354, 128 }, { 346, 134 }, { 306, 134 }, { 300, 130 }, { 296, 121 } }
  local booms = line({ { 312, 125 }, { 314, 140 } }, 1):add(line({ { 336, 125 }, { 340, 140 } }, 1))
  local float = c:rrect(304, 139, 348, 142, 1)
  F.shadow(300, 352, 143, 8, 3)
  rimOf(union(hull, booms, float), L.timber)
  part(hull, TAM) hline(300, 352, 124, TAM.hi) hline(302, 350, 126, L.awnA.base)
  hull:each(function(x, y) if y > 129 and hash(x // 3, y, 26) < .25 then px(x, y, TAM.deep) end end)
  part(booms, L.board, { nopop = true, noshade = true }) part(float, L.timber, { nopop = true })
  lash(311, 126, 4, 2) lash(335, 126, 4, 2) lash(312, 138, 4, 2) lash(338, 138, 4, 2)
  for _, x in ipairs({ 308, 342 }) do fill(rect(x, 134, x + 2, 138), L.timber.base) end
  -- a float log waiting and paddles leaning on the hull's end
  palmLog(356, 384, 140, 3)
  paddle(362, 134, 22, 4, TAM, L.wall2) paddle(370, 135, 22, 5, TAM, L.awnA)
end
frame()
-- a net drying on a bamboo rack beside the road
local function netRack(x0, x1, yt, yb)
  local poles = rect(x0, yt - 2, x0 + 1, yb):add(rect(x1 - 1, yt - 2, x1, yb)):add(rect(x0 - 1, yt, x1 + 1, yt + 1))
  F.shadow(x0, x1, yb, 6, 2)
  rimOf(poles, L.board) part(poles, L.board, { nopop = true, noshade = true }) hline(x0 - 1, x1 + 1, yt, L.board.hi)
  local nm = poly{ { x0 + 2, yt + 2 }, { x1 - 2, yt + 2 }, { x1 - 4, yb - 6 }, { (x0 + x1) // 2, yb - 3 }, { x0 + 4, yb - 7 } }
  F.net(nm, { base = L.coconut.base, shade = L.coconut.shade })
  nm:edge():each(function(x, y) if (x + y) % 2 == 0 then px(x, y, L.coconut.shade) end end)
  for x = x0 + 4, x1 - 4, 5 do fill(rect(x, yt + 2, x + 2, yt + 4), L.hibiscus.base) px(x, yt + 2, L.hibiscus.hi) px(x + 2, yt + 4, L.hibiscus.deep) end
  lash(x0 - 1, yt - 1, 3, 3) lash(x1 - 1, yt - 1, 3, 3)
end
F.depth(3)
netRack(258, 292, 150, 176)
F.depth(2)
F.tree(464, 144, 48, 7)
F.tree(446, 138, 40, 2)

F.depth(2)
F.tree(78, 168, 46, 1)
---------------------------------------------------------------- left hero: the caulk hearth under a thatched lean-to
F.depth(3)
local function hearth()
  local posts = rect(92, 128, 95, 206):add(rect(186, 140, 189, 208))
  local roofm = poly{ { 82, 126 }, { 198, 138 }, { 198, 146 }, { 82, 134 } }
  local fire = rect(104, 162, 162, 202)
  local hood = poly{ { 108, 140 }, { 158, 140 }, { 162, 162 }, { 104, 162 } }
  local chim = rect(124, 84, 140, 140)
  F.shadow(94, 194, 208, 12, 5)
  rimOf(union(chim, hood, fire), L.stone)
  part(chim, L.stone) F.courses(chim, 84, 6, 8, L.stone)
  fill(rect(122, 82, 142, 85), L.lava.shade) hline(122, 142, 82, L.lava.hi) hline(122, 142, 85, L.lava.deep)
  part(hood, L.stone, { sep = true }) F.courses(hood, 140, 5, 10, L.stone, 2)
  part(fire, L.stone, { sep = true }) F.courses(fire, 162, 7, 12, L.stone, 5)
  -- black lava blocks in the lowest course, pink coral pores
  local foot = rect(104, 196, 162, 202) part(foot, L.lava, { nopop = true }) F.courses(foot, 196, 7, 10, L.lava, 3)
  union(chim, hood, fire):each(function(x, y) if y < 196 and hash(x // 2, y // 2, 27) < .025 and hash(x, y, 26) < .5 then px(x, y, L.coral.shade) end end)
  local mouth = c:rrect(116, 168, 150, 196, 8):clip(rect(116, 168, 150, 192))
  fill(mouth, L.soil.deep)
  local coals = c:ellipse(133, 190, 14, 4):clip(mouth)
  fill(coals, G.shade)
  coals:each(function(x, y) local v = hash(x, y, 4) if v < .3 then px(x, y, G.base) elseif v < .4 then px(x, y, G.hi) elseif v > .85 then px(x, y, G.deep) end end)
  local flame = poly{ { 122, 190 }, { 125, 182 }, { 128, 186 }, { 131, 180 }, { 134, 185 }, { 137, 178 }, { 140, 185 }, { 143, 181 }, { 146, 190 } }
  fill(flame, G.base) fill(poly{ { 128, 190 }, { 134, 182 }, { 140, 190 } }, G.hi)
  -- the clay pot of breadfruit-gum caulk on three stones, bubbling
  local pot = c:ellipse(133, 178, 10, 7):clip(rect(120, 172, 146, 186))
  rimOf(pot, L.roof2) part(pot, L.roof2)
  pot:each(function(x, y) if (x - 133) < -5 and y < 180 then px(x, y, L.roof2.hi) end end)
  hline(124, 142, 172, L.roof2.hi) hline(125, 141, 173, L.lava.deep)
  fill(rect(127, 173, 139, 173), L.lava.shade) px(130, 173, G.base) px(135, 173, L.lava.hi) px(137, 172, L.lava.base)
  for _, b in ipairs({ { 129, 170 }, { 136, 168 }, { 133, 166 } }) do px(b[1], b[2], L.lava.hi) px(b[1] + 1, b[2], L.lava.base) end
  fill(rect(124, 185, 127, 187), L.lava.base) fill(rect(139, 185, 142, 187), L.lava.base)
  hline(112, 154, 196, L.stone.hi) hline(112, 154, 197, L.stone.deep)
  -- glow cast on the sand
  for y = 203, 214 do for x = 112 + (y - 203), 156 - (y - 203) do if hash(x, y, 7) < .35 then px(x, y, L.glow.hi) end end end
  -- driftwood posts, thatched roof
  rimOf(union(posts, roofm), L.timber)
  part(posts, L.timber, { nopop = true })
  posts:each(function(x, y) if hash(x, y // 3, 28) < .2 then px(x, y, L.timber.shade) end end)
  part(roofm, L.roof, { sep = true }) F.thatch(roofm, L.roof, 126, 9999)
  hline(82, 198, 134, L.roof.deep)
  -- ragged fringe of palm leaf hanging off the eave
  for x = 82, 198, 2 do local yy = floor(134 + (x - 82) * 12 / 116) + 1 local n = 1 + floor(hash(x, 0, 29) * 4) vline(x, yy, yy + n, x % 4 == 0 and L.roof.shade or L.roof.base) end
  lash(91, 132, 6, 3) lash(185, 143, 6, 3)
  part(rect(124, 84, 140, 126):clip(chim), L.stone) F.courses(rect(124, 84, 140, 126), 84, 6, 8, L.stone)
  F.smoke(132, 78, 9, .7, 3)
  -- shell adzes hung on the left post
  for k = 0, 2 do
    local y = 146 + k * 10
    local hf = line({ { 97, y }, { 101, y + 7 } }, 2)
    local h = poly{ { 100, y + 4 }, { 106, y + 2 }, { 107, y + 6 }, { 102, y + 8 } }
    c:rim(union(hf, h), L.timber.edge)
    fill(hf, TAM.base) px(97, y, TAM.hi) px(98, y + 1, TAM.hi)
    fill(h, L.shell.base) hline(101, 106, y + 3, L.shell.hi) px(104, y + 6, L.shell.shade) px(106, y + 5, L.shell.shade)
    hline(99, 101, y + 4, L.rope.base) px(100, y + 5, L.rope.shade)
  end
  -- coils of sennit and bamboo tongs on the right post
  for k = 0, 1 do local o = c:ellipse(183, 152 + k * 9, 4, 4):cut(c:ellipse(183, 152 + k * 9, 2, 2)) rimOf(o, L.rope) fill(o, k == 0 and L.rope.base or L.rope.shade) px(181, 149 + k * 9, L.rope.hi) end
  fill(line({ { 182, 170 }, { 180, 186 } }), L.board.shade) fill(line({ { 185, 170 }, { 183, 186 } }), L.board.base)
  -- a heap of dry husks for fuel
  local hk = poly{ { 162, 186 }, { 186, 186 }, { 182, 176 }, { 172, 172 }, { 164, 177 } }
  rimOf(hk, L.needle) part(hk, L.needle)
  hk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) elseif hash(x, y, 30) < .2 then px(x, y, L.needle.hi) end end)
  F.coconut(170, 188, 3) F.coconut(178, 189, 3)
end
hearth()
-- the paddle shaper: a block of palm trunk, a paddle blank across it, a gnome swinging a stone adze
local function block(x, yb)
  F.shadow(x - 8, x + 9, yb, 8, 3)
  local body = rect(x - 7, yb - 9, x + 7, yb)
  local top = c:ellipse(x, yb - 9, 7, 3)
  rimOf(union(body, top), L.palmTrunk) part(body, L.palmTrunk, { nopop = true })
  body:each(function(xx, yy) if yy % 3 == 0 then px(xx, yy, L.palmTrunk.shade) end end)
  fill(top, L.palmTrunk.hi) px(x, yb - 9, L.rope.base)
  -- the paddle blank lying across: leaf blade left, shaft right, half shaped
  local blank = c:ellipse(x - 7, yb - 13, 9, 3):add(rect(x + 1, yb - 14, x + 16, yb - 13))
  rimOf(blank, TAM) part(blank, TAM, { nopop = true })
  hline(x - 13, x, yb - 15, TAM.hi) vline(x - 7, yb - 14, yb - 11, TAM.shade) hline(x - 14, x, yb - 12, TAM.shade)
  fill(rect(x + 11, yb - 15, x + 16, yb - 12), L.coconut.base) px(x + 11, yb - 15, L.coconut.hi) vline(x + 11, yb - 14, yb - 12, L.coconut.deep) -- the rough end still in bark
  -- flying chips
  for i = 0, 9 do local sx, sy = x - 10 + floor(hash(i, 1, 21) * 22), yb - 18 - floor(hash(i, 2, 21) * 10) px(sx, sy, i % 3 == 0 and TAM.base or TAM.hi) end
  chips(x - 14, x + 16, yb + 1, yb + 6, 14, 22, TAM)
end
block(170, 232)
local _, hx, hy = F.gnome(148, 238, { hat = L.awnA, coat = L.wall2, arm = "up" })
-- stone adze up: wooden haft, black lava blade lashed on
fill(rect(hx, hy - 6, hx + 1, hy + 1), L.redbark.base)
fill(rect(hx + 1, hy - 8, hx + 5, hy - 6), L.lava.base) px(hx + 1, hy - 8, L.lava.hi) px(hx + 5, hy - 6, L.lava.deep)
hline(hx, hx + 1, hy - 5, L.rope.base)
fill(rect(146, 228, 150, 235), L.needle.shade) px(146, 228, L.needle.base) -- a woven pandanus apron
-- a little island pig asleep in the hearth's warmth
F.sprite({
  "..............ee....",
  "....PPPPPPPPPPeEe...",
  "..PPHHHHHHPPPPPPPP..",
  ".PHHHHPPPPPPPPPPkPP.",
  "tPHHPPPPPPPPPPPPPPnn",
  ".PPPPPPpPPPPPPPPPnsn",
  ".PPPPPPPPPPPPpPPPP..",
  "..ppppPpppppPPpppp..",
  "..dd..dd....dd..dd..",
}, 100, 206, { P = L.soil.base, H = L.soil.hi, p = L.soil.shade, e = L.soil.shade, E = L.coral.shade, k = L.timber.edge,
  n = L.coral.base, s = L.coral.deep, t = L.soil.deep, d = L.soil.deep })
for _, b in ipairs({ { 106, 209 }, { 110, 208 }, { 114, 209 }, { 120, 209 } }) do px(b[1], b[2], L.soil.shade) end -- bristles
-- zzz
px(122, 200, L.awnB.base) px(123, 200, L.awnB.base) px(123, 201, L.awnB.base) px(122, 202, L.awnB.base) px(123, 202, L.awnB.base)
px(126, 196, L.awnB.hi) px(127, 196, L.awnB.hi) px(127, 197, L.awnB.hi) px(126, 198, L.awnB.hi) px(127, 198, L.awnB.hi)
-- a split-log water trough and a coconut-shell dipper
local trough = c:rrect(186, 226, 206, 236, 3)
F.shadow(186, 206, 236, 6, 2)
rimOf(trough, L.palmTrunk) part(trough, L.palmTrunk)
trough:each(function(x, y) if (x - 186) % 3 == 0 then px(x, y, L.palmTrunk.shade) end end)
fill(rect(188, 227, 204, 228), L.lagoon.base) hline(189, 194, 227, L.lagoon.hi)
local dip = c:ellipse(199, 224, 3, 2):clip(rect(196, 224, 202, 226)) rimOf(dip, L.coconut) fill(dip, L.coconut.base) px(197, 224, L.coconut.hi)
fill(line({ { 201, 224 }, { 206, 219 } }), L.redbark.base)

---------------------------------------------------------------- right hero: the bamboo net-weaving hall, open front
local function hall()
  local x0, x1, yb = 296, 446, 208
  local top, cx, wallM, roofM = F.building{ x0 = x0, x1 = x1, yb = yb, wh = 56, rh = 36, wall = L.board, roof = L.roof, noFrame = true, noAttic = true }
  F.bamboo(wallM:copy():clip(rect(x0, top + 4, x1, yb)), L.board, 3)
  local gab = poly{ { x0 + 5, top }, { cx, top - 28 }, { x1 - 5, top } }:cut(roofM)
  gab:each(function(x, y) local wv = ((x // 2 + y // 2) % 2 == 0) px(x, y, wv and L.needle.shade or L.needle.deep) if y > top - 4 then px(x, y, L.needle.edge) end end)
  hline(x0, x1, top + 4, L.timber.base) hline(x0, x1, top + 5, L.timber.deep)
  -- driftwood corner posts and lashed rail
  for _, x in ipairs({ x0, x1 - 2 }) do fill(rect(x, top + 4, x + 2, yb), L.timber.base) vline(x, top + 4, yb, L.timber.hi) vline(x + 2, top + 4, yb, L.timber.deep) end
  -- black lava footing so it reads on the bright sand
  local foot = rect(x0, yb - 6, x1, yb)
  part(foot, L.lava, { nopop = true }) F.courses(foot, yb - 6, 3, 8, L.lava, 4)
  -- ridge: crossed palm ribs and a carved frigatebird finial
  line({ { cx - 6, top - 40 }, { cx + 4, top - 32 } }, 1):each(function(x, y) px(x, y, L.timber.base) end)
  line({ { cx + 6, top - 40 }, { cx - 4, top - 32 } }, 1):each(function(x, y) px(x, y, L.timber.shade) end)
  F.sprite({ "k.........k", "kk.......kk", ".kkk...kkk.", "...kkkkk...", ".....k....." }, cx - 5, top - 46, { k = L.timber.shade })
  -- a net draped over the gable as a sun screen
  local gnet = poly{ { cx - 28, top - 22 }, { cx + 24, top - 22 }, { cx + 15, top - 2 }, { cx - 19, top - 2 } }:clip(gab)
  F.net(gnet, { base = L.shell.hi, shade = L.stone.shade }, { floats = true })
  -- window with turquoise shutters, left of the doorway
  F.window(306, 172, 313, 182, L.timber)
  local sl, sr = rect(300, 171, 304, 183), rect(315, 171, 319, 183)
  rimOf(union(sl, sr), L.wall2) part(sl, L.wall2, { nopop = true }) part(sr, L.wall2, { nopop = true })
  union(sl, sr):each(function(x, y) if y % 2 == 0 then px(x, y, L.wall2.shade) end end)
  hline(302, 318, 186, L.timber.base) for k = 0, 7 do px(303 + k * 2, 185, L.foliage2.base) px(304 + k * 2, 184, L.foliage2.hi) end
  px(306, 184, L.hibiscus.base) px(306, 183, L.hibiscus.hi) px(312, 184, L.awnA.base) px(316, 184, L.petal.base)
  -- big open front
  local dx0, dx1, dy0 = 322, 420, 166
  fill(rect(dx0 - 3, dy0 - 3, dx1 + 3, yb), L.timber.base) hline(dx0 - 3, dx1 + 3, dy0 - 3, L.timber.hi) hline(dx0 - 3, dx1 + 3, dy0 - 1, L.timber.deep)
  vline(dx0 - 3, dy0 - 3, yb, L.timber.hi)
  fill(rect(dx0, dy0, dx1, yb), L.soil.deep)
  fill(rect(dx0, yb - 6, dx1, yb), L.soil.shade)
  for x = dx0 + 3, dx1, 6 do vline(x, dy0, yb - 7, L.soil.edge) end -- bamboo slats of the back wall in shadow
  -- a big net with floats hung on the back wall (left)
  local bnet = poly{ { dx0 + 3, dy0 + 2 }, { dx0 + 46, dy0 + 2 }, { dx0 + 44, dy0 + 18 }, { dx0 + 30, dy0 + 24 }, { dx0 + 14, dy0 + 22 }, { dx0 + 4, dy0 + 16 } }
  F.net(bnet, L.rope, { floats = true })
  hline(dx0 + 2, dx0 + 47, dy0 + 2, L.board.base)
  -- tool wall (right): shell scrapers, netting needles, a stone adze, a coral rasp, fish hooks on a cord
  local tw = rect(dx0 + 50, dy0 + 3, dx1 - 6, dy0 + 22) fill(tw, L.soil.base) c:edgeIn(tw, L.timber.deep)
  F.shell(377, 174, "scallop", true) F.shell(383, 175, "scallop", true)
  F.shell(380, 182, "conch", true)
  for k = 0, 2 do local x = 388 + k * 3 vline(x, 171, 184, L.board.hi) px(x, 170, L.board.base) px(x, 175, L.soil.deep) px(x, 181, L.board.shade) end -- netting needles
  vline(400, 171, 186, L.redbark.base) fill(rect(398, 170, 404, 173), L.lava.base) px(398, 170, L.lava.hi) hline(399, 401, 174, L.rope.base) -- stone adze
  fill(rect(406, 171, 407, 184), L.coral.shade) for y = 172, 183, 2 do px(406, y, L.coral.hi) end -- coral rasp
  hline(409, 413, 172, L.rope.shade) for k = 0, 2 do local x = 409 + k * 2 vline(x, 173, 176 + k, L.shell.hi) px(x + 1, 177 + k, L.shell.hi) px(x + 1, 176 + k, L.shell.base) end -- hooks
  -- workbench with a net in progress spilling over the front
  local bench = rect(330, 192, 414, 196)
  local legs = rect(334, 197, 337, 208):add(rect(407, 197, 410, 208))
  rimOf(union(bench, legs), L.timber) part(bench, L.board) F.bamboo(bench, L.board, 2, { horizontal = true }) part(legs, L.timber, { nopop = true, noshade = true })
  local wnet = poly{ { 340, 190 }, { 384, 190 }, { 386, 198 }, { 380, 207 }, { 352, 207 }, { 342, 200 } }
  F.net(wnet, L.rope)
  for _, f in ipairs({ { 346, 205 }, { 360, 207 }, { 374, 206 } }) do fill(rect(f[1], f[2] - 1, f[1] + 2, f[2]), L.hibiscus.base) px(f[1], f[2] - 1, L.hibiscus.hi) end
  -- coconut bowl of twine balls
  local bowl = c:ellipse(398, 191, 4, 2):clip(rect(394, 190, 402, 193)) rimOf(bowl, L.coconut) fill(bowl, L.coconut.base)
  fill(c:ellipse(397, 189, 1, 1), L.rope.hi) fill(c:ellipse(400, 189, 1, 1), L.rope.base)
  -- the weaver at the bench, a netting needle in hand
  local _, wx, wy = F.gnome(392, 208, { hat = L.lav, coat = L.hibiscus, arm = "hold", flip = true, noShadow = true })
  line({ { wx, wy }, { wx - 4, wy - 4 } }):each(function(x, y) px(x, y, L.board.hi) end)
  -- hanging coconut-shell oil lamp
  vline(372, dy0, dy0 + 3, L.rope.deep)
  local lm = c:ellipse(372, dy0 + 6, 3, 2):clip(rect(369, dy0 + 6, 375, dy0 + 8)) rimOf(lm, L.coconut) fill(lm, L.coconut.base)
  px(372, dy0 + 5, G.hi) px(372, dy0 + 4, G.base) px(371, dy0 + 5, G.base)
  -- sign above the doorway: a carved fish
  local sb = rect(352, 148, 390, 159) rimOf(sb, L.timber) part(sb, L.board) F.bamboo(sb, L.board, 3, { horizontal = true })
  F.sprite({
    "......aa.......",
    "..aaaaaaaa...a.",
    ".aaeaAaAaaa.aa.",
    "aaaaaaaaaaaaaa.",
    ".aAaAaAaaaa.aa.",
    "..aaaaaaaa...a.",
  }, 363, 150, { a = L.accent.base, A = L.accent.shade, e = L.timber.edge }, {})
  px(366, 151, L.accent.hi) px(367, 151, L.accent.hi)
  -- right of the door: a string of drying fish and a woven fish trap
  hline(424, 444, 170, L.rope.deep)
  for k = 0, 4 do local x = 426 + k * 4
    local fm = poly{ { x, 171 }, { x + 2, 171 }, { x + 2, 177 }, { x + 1, 180 }, { x, 177 } }
    c:rim(fm, L.timber.edge) fill(fm, k % 2 == 0 and L.iron.hi or L.iron.base) px(x, 172, L.iron.deep) vline(x + 2, 172, 177, L.iron.shade)
  end
  local trap = poly{ { 428, 186 }, { 444, 184 }, { 444, 204 }, { 428, 200 } }
  rimOf(trap, L.board)
  trap:each(function(x, y) px(x, y, ((x + y) % 3 == 0 or (x - y) % 3 == 0) and L.board.shade or L.board.base) end)
  local mouthT = c:ellipse(432, 193, 3, 6) fill(mouthT, L.soil.deep) c:edgeIn(mouthT, L.board.hi)
end
hall()
-- a lava whetstone on a driftwood stand, a coconut of water beside it
local function whetstone(x, yb)
  local legs = rect(x - 12, yb - 8, x - 10, yb):add(rect(x + 10, yb - 8, x + 12, yb))
  local top = rect(x - 13, yb - 11, x + 13, yb - 8)
  local stone = poly{ { x - 9, yb - 11 }, { x + 9, yb - 11 }, { x + 7, yb - 16 }, { x - 7, yb - 16 } }
  F.shadow(x - 12, x + 12, yb, 6, 2)
  rimOf(union(legs, top, stone), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true }) part(top, L.timber)
  part(stone, L.lava) hline(x - 7, x + 7, yb - 16, L.lava.hi)
  stone:each(function(xx, yy) if hash(xx, yy, 31) < .12 then px(xx, yy, L.lava.deep) end end)
  hline(x - 5, x + 3, yb - 15, L.lagoon.shade) -- wet sheen
  -- a shell adze blade being honed
  local b = poly{ { x - 2, yb - 19 }, { x + 4, yb - 19 }, { x + 5, yb - 17 }, { x - 3, yb - 17 } } c:rim(b, L.shell.edge) fill(b, L.shell.base) hline(x - 2, x + 3, yb - 19, L.shell.hi)
  F.coconut(x + 17, yb - 2, 3, true)
end
whetstone(440, 228)

---------------------------------------------------------------- foreground left: bamboo pole ends, water jar, the half-carved dugout
-- stacked bamboo poles seen end-on: hollow rings
F.shadow(26, 80, 204, 8, 3)
for row = 0, 3 do for k = 0, 4 - row do
  local x, y = 30 + k * 10 + row * 5, 198 - row * 8
  local e = c:ellipse(x, y, 5, 4) rimOf(e, L.board) fill(e, L.board.base) c:edgeIn(e, L.board.shade)
  e:each(function(xx, yy) if (xx - x) + (yy - y) < -4 then px(xx, yy, L.board.hi) end end)
  local hol = c:ellipse(x, y, 2, 2) fill(hol, L.board.deep) px(x - 1, y - 1, L.timber.edge) px(x + 1, y + 1, L.board.shade)
end end
-- a big terracotta water jar with a rope sling
local jar = c:ellipse(84, 194, 7, 8):add(rect(81, 184, 87, 187))
F.shadow(78, 92, 203, 5, 2)
rimOf(jar, L.roof2) part(jar, L.roof2)
hline(80, 88, 184, L.roof2.hi) hline(81, 87, 185, L.lava.deep)
hline(77, 91, 192, L.rope.base) vline(80, 186, 192, L.rope.shade) vline(88, 186, 192, L.rope.shade)
local function dugout()
  local hull = poly{ { 22, 212 }, { 28, 220 }, { 122, 219 }, { 132, 224 }, { 134, 234 }, { 126, 246 }, { 40, 248 }, { 26, 241 }, { 20, 226 } }
  local chock = c:ellipse(46, 248, 6, 3):add(c:ellipse(112, 247, 6, 3))
  F.shadow(26, 134, 250, 10, 4)
  rimOf(union(hull, chock), TAM)
  part(chock, L.palmTrunk, { nopop = true }) chock:each(function(x, y) if x % 3 == 0 then px(x, y, L.palmTrunk.shade) end end)
  -- outside: freshly adzed red tamanu, facets in staggered rows, darker toward the keel; the stern still in bark
  hull:each(function(x, y)
    local fx = (x + (y // 4) * 3) % 7
    local h = TAM.base
    if fx == 0 then h = TAM.shade elseif fx == 1 and y < 240 then h = TAM.hi end
    if y > 239 then h = (fx == 0) and TAM.deep or TAM.shade end
    if x > 110 then
      h = L.coconut.base
      if hash(x // 4, y, 32) < .35 then h = L.coconut.shade end
      if y % 3 == 0 then h = L.coconut.deep end
      if y < 228 and hash(x // 2, y, 33) < .5 then h = L.coconut.hi end
      if y > 240 then h = L.coconut.deep end
    end
    px(x, y, h)
  end)
  -- the end grain of the uncut stern
  local eg = c:ellipse(128, 234, 4, 9):clip(hull)
  fill(eg, L.board.base)
  eg:each(function(x, y) local d = math.sqrt(((x - 128) * 2.2) ^ 2 + (y - 234) ^ 2) if floor(d) % 3 == 0 then px(x, y, L.board.shade) end if (x - 128) + (y - 234) < -6 then px(x, y, L.board.hi) end end)
  px(128, 234, L.board.deep)
  -- the bark line: a ragged border where the carving stops
  for y = 220, 246 do local x = 109 + floor(hash(0, y, 34) * 3) px(x, y, L.coconut.edge) px(x - 1, y, TAM.hi) end
  -- the hollow being carved out: the far inside wall in shade, the near lip lit
  local hollow = poly{ { 30, 221 }, { 104, 221 }, { 108, 225 }, { 104, 231 }, { 34, 232 }, { 26, 226 } }
  fill(hollow, TAM.deep)
  hollow:each(function(x, y)
    if y >= 229 then px(x, y, TAM.shade) end
    if y < 229 and (x + y * 2) % 8 == 0 then px(x, y, TAM.shade) end -- adze scallops on the far wall
    if y < 229 and (x + y * 2) % 8 == 1 then px(x, y, "#7e4434") end
  end)
  -- rough uncut core at the stern end of the hollow
  local core = poly{ { 92, 222 }, { 105, 222 }, { 107, 226 }, { 103, 230 }, { 90, 230 } }
  fill(core, TAM.base) core:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, TAM.hi) end end)
  hline(28, 106, 220, TAM.hi) hline(24, 106, 232, TAM.hi) hline(26, 104, 233, "#dc9a6a")
  -- embers burning out the hollow (the old way), charred black around them, a wisp of smoke
  local char = c:ellipse(62, 227, 13, 3):clip(hollow)
  fill(char, L.lava.deep)
  local emb = c:ellipse(62, 227, 9, 2):clip(hollow)
  emb:each(function(x, y) local v = hash(x, y, 35) px(x, y, v < .3 and G.base or (v < .45 and G.hi or (v < .7 and G.deep or L.lava.edge))) end)
  local st = { "#ece8dc", "#dedad0", "#d0ccc4" }
  for k = 0, 4 do local m = c:ellipse(60 - k * 2 + floor(sin(k * 1.3) * 2), 220 - k * 5, 2 + k // 2, 1 + k // 3) fill(m, st[1 + k % 3]) end
  -- the bow: upturned, a painted turquoise eye and a red band
  fill(c:ellipse(26, 219, 2, 2), L.wall2.base) px(26, 219, L.timber.edge) px(25, 218, L.wall2.hi)
  hline(30, 104, 237, L.awnA.base) hline(30, 104, 238, L.awnA.shade)
end
dugout()
chips(16, 144, 246, 262, 44, 36, TAM)
local _, ax, ay = F.gnome(104, 256, { hat = L.leaf, coat = L.accent, arm = "up", flip = true })
-- a shell adze raised over the gunwale
fill(line({ { ax, ay + 1 }, { ax - 2, ay - 6 } }), L.redbark.base)
local blade = poly{ { ax - 5, ay - 9 }, { ax, ay - 7 }, { ax - 1, ay - 5 }, { ax - 5, ay - 6 } } c:rim(blade, L.shell.edge) fill(blade, L.shell.base) px(ax - 4, ay - 8, L.shell.hi)
hline(ax - 2, ax - 1, ay - 6, L.rope.base)
for i = 0, 3 do px(ax - 8 - floor(hash(i, 3, 53) * 5), ay - 2 - i * 2, L.redbark.hi) end

---------------------------------------------------------------- foreground right: coils, baskets, a heap of net
F.depth(3)
F.shadow(300, 336, 244, 6, 2)
coil(312, 238, 9) coil(326, 242, 7)
-- a woven pandanus basket of shell tools
local function basket(x, yb, w, h)
  local m = c:rrect(x - w, yb - h, x + w, yb, 2)
  rimOf(m, L.needle)
  m:each(function(xx, yy)
    local ck = ((xx - x + 20) // 2 + (yy - yb + 20) // 2) % 2 == 0
    local dark = (xx - x) / w + (yy - (yb - h)) / h > 1.1
    px(xx, yy, ck and (dark and L.needle.base or L.needle.hi) or (dark and L.needle.shade or L.needle.base))
  end)
  hline(x - w, x + w, yb - h, L.rope.hi) hline(x - w + 1, x + w - 1, yb - h + 1, L.rope.shade)
  return m
end
F.shell(286, 242, "conch", true) F.shell(292, 241, "scallop", true)
basket(290, 256, 9, 9)
vline(286, 240, 246, L.redbark.base) fill(rect(285, 238, 288, 239), L.lava.base)
-- a heap of net with orange floats
local heap = poly{ { 340, 260 }, { 344, 252 }, { 356, 248 }, { 368, 250 }, { 374, 258 }, { 370, 262 }, { 344, 263 } }
F.shadow(340, 374, 263, 4, 2)
rimOf(heap, L.rope) fill(heap, L.rope.shade)
heap:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.rope.hi) elseif (x - y) % 3 == 0 then px(x, y, L.rope.base) elseif y > 258 then px(x, y, L.rope.deep) end end)
for _, f in ipairs({ { 348, 254 }, { 358, 251 }, { 366, 256 }, { 352, 259 } }) do local m = c:ellipse(f[1], f[2], 2, 1) c:rim(m, L.hibiscus.edge) fill(m, L.hibiscus.base) px(f[1] - 1, f[2] - 1, L.hibiscus.hi) end
-- beach grass, hibiscus, banana
for _, f in ipairs({ { 264, 262, 7 }, { 276, 266, 8 }, { 128, 264, 7 }, { 140, 268, 6 }, { 8, 262, 8 }, { 372, 226, 6 }, { 296, 216, 5 }, { 456, 222, 6 }, { 210, 214, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.hibiscus(24, 266, 8, 10, 51)
F.shell(150, 262, "scallop") F.shell(206, 246, "cowrie") F.shell(318, 262, "conch", true)
F.crab(232, 262, L.awnA) F.crab(374, 246, L.hibiscus, true)

---------------------------------------------------------------- the carrier: a gnome bringing a new paddle along the road
local _, cx1, cy1 = F.gnome(276, 214, { hat = L.produce, coat = L.wall2, arm = "up" })
local pd = line({ { cx1 - 24, cy1 + 3 }, { cx1 + 10, cy1 - 4 } }, 1):add(c:ellipse(cx1 - 26, cy1 + 4, 5, 2)):add(rect(cx1 + 9, cy1 - 6, cx1 + 11, cy1 - 3))
rimOf(pd, TAM) part(pd, TAM, { nopop = true })
line({ { cx1 - 24, cy1 + 3 }, { cx1 + 10, cy1 - 4 } }):each(function(x, y) px(x, y, TAM.hi) end)
hline(cx1 - 28, cx1 - 24, cy1 + 4, L.awnA.base)

F.depth(0)
F.birds({ { 330, 34, 2 }, { 344, 40, 1 }, { 168, 50, 1 }, { 150, 44, 2 }, { 404, 26, 3 } })
-- chopping block of breadfruit log with a stone adze stuck in it, by the road (left)
F.depth(3)
log(176, 198, 256, 6, L.coconut, L.redbark)
local ad = line({ { 186, 248 }, { 196, 236 } }, 2) rimOf(ad, L.timber) fill(ad, L.redbark.base)
fill(poly{ { 193, 234 }, { 200, 230 }, { 201, 238 } }, L.lava.base) px(199, 231, L.lava.hi) px(200, 237, L.lava.deep)
hline(193, 196, 236, L.rope.base)
F.finish()
