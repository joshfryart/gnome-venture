-- mill.lua : "Old mill" stop look, FOREST (forest_pinewood), 480x270 gate view.
-- Same composition as the Maplewold mill (art-2701-batch3/stops/opus3/mill.lua), re-cast for a pine wood:
-- road's end: a tall log saw-house with a steep mossy shingle roof (replaces the windmill), between spruces.
-- Back left: a log cabin with chimney smoke. Right: the plank store with a hoist lifting a log bundle, a dock of
-- stacked planks. Left hero: the weatherboard watermill on a mossy stone footing, overshot wheel and flume.
-- Bottom left: the mill pond in cool water with mallards and cattails. Log pile, chopping gnome, sawhorse with two
-- gnomes on a crosscut saw, a log cart, a plank-carrying gnome, a jay on a stump, mushrooms and ferns.
-- Quirk: a red squirrel in a red gnome hat riding the top paddle of the wheel, clutching a pine cone.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-forest-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "mill", out = DIR, farTrees = { 24, 52, 160, 330, 352, 440 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi

---------------------------------------------------------------- far right: a bracken clearing with stumps and log stacks
F.depth(1)
local field = poly{ { 268, 114 }, { 470, 114 }, { 470, 146 }, { 284, 146 } }
field:each(function(x, y)
  local h = L.mossGround.base
  if hash(x // 6, y // 2, 4) < .3 then h = L.mossGround.hi elseif hash(x // 5, y // 2, 5) < .2 then h = L.needle.base end
  if hash(x, y, 3) < .04 then h = L.mossGround.shade end
  px(x, y, h)
end)
-- bracken clumps (green and rusty), bigger lower down
for i = 1, 60 do
  local x, y = 286 + floor(hash(i, 1, 6) * 182), 118 + floor(hash(i, 2, 6) * 27)
  local r = hash(i, 3, 6) < .35 and L.needle or L.fern
  F.fern(x, y, 2 + (y - 116) // 9, r)
end
local function stump(x, yb, w)
  local body = rect(x - w, yb - w, x + w, yb)
  local top = c:ellipse(x, yb - w, w, math.max(1, w // 2))
  rimOf(union(body, top), L.timber) part(body, L.timber, { nopop = true })
  fill(top, L.board.base) px(x, yb - w, L.board.shade) px(x - 1, yb - w - 1, L.board.hi)
  return body
end
for _, s in ipairs({ { 290, 128, 2 }, { 312, 122, 2 }, { 340, 136, 3 }, { 452, 126, 2 }, { 300, 141, 3 } }) do stump(s[1], s[2], s[3]) end
local function logStack(x, yb, n, rr)
  for row = 0, n - 1 do
    for k = 0, n - 1 - row do
      F.logEnd(x + k * (rr * 2 + 1) + row * (rr + 1), yb - rr - row * (rr * 2), rr)
    end
  end
end
logStack(404, 140, 4, 2)
logStack(436, 134, 3, 2)

---------------------------------------------------------------- road's end: the saw-house between two spruces
F.depth(2)
F.tree(206, 128, 62, 2)
F.tree(276, 128, 56, 4)
local function sawhouse()
  local body = poly{ { 226, 126 }, { 254, 126 }, { 252, 82 }, { 228, 82 } }
  local roofM = poly{ { 219, 85 }, { 240, 50 }, { 261, 85 } }
  local gable = poly{ { 230, 82 }, { 240, 66 }, { 250, 82 } }
  roofM:cut(gable)
  local pipe = rect(248, 52, 251, 70)
  F.shadow(226, 254, 126, 8, 3)
  rimOf(union(body, roofM, gable, pipe), L.timber)
  part(pipe, L.iron, { nopop = true }) hline(247, 252, 52, L.iron.deep)
  part(body, L.timber)
  F.logs(body, L.timber, 82, 4)
  -- corner log ends poking out past the walls
  for y = 84, 124, 4 do F.logEnd(226, y, 1) F.logEnd(254, y, 1) end
  part(gable, L.board, { nopop = true })
  F.planks(gable, L.board, 3, true, 7)
  part(roofM, L.roof, { sep = true })
  F.courses(roofM, 50, 3, 5, L.roof)
  F.moss(roofM, .16, 68)
  line({ { 220, 84 }, { 239, 51 } }):each(function(x, y) if roofM:has(x, y) then px(x, y, L.roof.hi) end end)
  -- the open saw floor door: a frame-saw blade glinting inside, warm lamp light
  local d = rect(234, 104, 246, 125)
  fill(d, L.timber.edge)
  fill(rect(235, 105, 245, 125), L.glow.shade) fill(rect(235, 105, 239, 112), L.glow.base)
  vline(240, 105, 125, L.iron.hi) for y = 106, 124, 2 do px(241, y, L.iron.shade) end -- saw blade + teeth
  hline(235, 245, 116, L.timber.base) -- saw frame bar
  hline(232, 248, 103, L.timber.hi)
  F.window(238, 88, 242, 93, L.timber)
  -- a little weathervane: a fish on a rod
  vline(240, 42, 50, L.timber.edge)
  F.sprite({ ".FFF.", "FFFFf", ".fff." }, 238, 40, { F = L.gold.base, f = L.gold.shade })
  -- a gallery plank with a rail
  local gal = rect(222, 98, 258, 100)
  rimOf(gal, L.timber) part(gal, L.timber, { nopop = true, noshade = true })
  for x = 223, 257, 4 do vline(x, 101, 103, L.timber.base) end
end
sawhouse()
F.smoke(250, 46, 5, .5, 2)
-- a log chute running down from the saw floor to the road
local chute = poly{ { 254, 112 }, { 266, 120 }, { 266, 123 }, { 254, 115 } }
rimOf(chute, L.timber) part(chute, L.board, { nopop = true })

---------------------------------------------------------------- back-left: woodcutter's log cabin
F.depth(1)
F.tree(84, 128, 44, 2)
F.tree(10, 134, 40, 1)
local ctop, ccx, cwall = F.building{ x0 = 20, x1 = 66, yb = 138, wh = 30, rh = 22, wall = L.timber, roof = L.roof, chimney = true, shingle = true, noFrame = true }
F.logs(cwall, L.timber, ctop, 3)
for y = ctop + 1, 136, 3 do F.logEnd(19, y, 1) F.logEnd(67, y, 1) end
F.window(26, 116, 31, 121, L.timber) F.door(46, 124, 53, 137, L.timber)
F.smoke(57, 88, 6, .6, 2)
F.fenceP(70, 140, 196, 132, 9)

---------------------------------------------------------------- right: the plank store with a hoist lifting a log bundle
F.depth(2)
F.tree(300, 152, 54, 1)
F.tree(452, 142, 58, 5)
F.tree(436, 136, 40, 6)
local top, cx, swall, sroof = F.building{ x0 = 330, x1 = 420, yb = 170, wh = 46, rh = 28, wall = L.board, roof = L.roof, noAttic = true, shingle = true, noFrame = true }
F.planks(swall, L.board, 5, true, 9)
swall:each(function(x, y) if y > 162 and hash(x, y // 2, 12) < .5 then px(x, y, L.moss.shade) end end) -- damp moss at the foot
F.moss(sroof, .12, 69)
-- corner posts and a sill beam
local posts = union(rect(330, top, 332, 170), rect(418, top, 420, 170), rect(330, 168, 420, 170))
part(posts, L.timber, { nopop = true, noshade = true })
-- loft door + hoist beam
local loft = rect(368, 98, 382, 112)
fill(loft, L.timber.deep) fill(rect(369, 99, 381, 112), L.soil.deep)
for y = 104, 111, 2 do F.logEnd(372, y, 1) F.logEnd(378, y, 1) end
local beamH = rect(372, 92, 398, 95)
rimOf(beamH, L.timber) part(beamH, L.timber, { nopop = true, noshade = true }) hline(372, 398, 92, L.timber.hi)
vline(394, 96, 132, L.board.deep) -- rope
-- the hoisted log bundle, chained
local bundle = rect(380, 134, 408, 142)
rimOf(bundle, L.timber) part(bundle, L.timber, { nopop = true })
F.logs(bundle, L.timber, 134, 3)
F.logEnd(380, 136, 2) F.logEnd(381, 140, 2)
line({ { 394, 132 }, { 384, 134 } }):each(function(x, y) px(x, y, L.iron.shade) end)
line({ { 394, 132 }, { 404, 134 } }):each(function(x, y) px(x, y, L.iron.shade) end)
F.door(352, 140, 366, 169, L.timber)
F.window(396, 150, 404, 157, L.timber)
F.window(340, 128, 346, 134, L.timber)
-- loading dock with stickered plank stacks
local dock = rect(300, 158, 340, 172)
rimOf(dock, L.timber) part(dock, L.board)
F.planks(dock, L.board, 6, true, 11)
local function plankStack(x0, yb, w, n)
  local m = rect(x0, yb - n * 3, x0 + w, yb)
  rimOf(m, L.board) part(m, L.board, { nopop = true })
  for k = 0, n - 1 do
    local y = yb - k * 3
    hline(x0, x0 + w, y, L.board.deep) hline(x0, x0 + w, y - 2, L.board.hi)
    if k % 2 == 1 then px(x0 + 2, y - 1, L.timber.deep) px(x0 + w - 2, y - 1, L.timber.deep) end -- stickers
  end
  for x = x0 + 3, x0 + w - 3, 7 do vline(x, yb - n * 3, yb, L.board.shade) end
  return m
end
plankStack(302, 157, 16, 5)
plankStack(320, 157, 16, 4)
plankStack(308, 141, 20, 3)
F.depth(3)
local _, ghx, ghy = F.gnome(354, 182, { hat = L.awnA, coat = L.accent, arm = "up", flip = true })
vline(ghx, 143, ghy, L.board.deep) -- hauling the hoist rope
line({ { ghx, 143 }, { 394, 132 } }):each(function(x, y) px(x, y, L.board.deep) end)

---------------------------------------------------------------- sawhorse with two gnomes on a crosscut saw
local function sawhorse(x0, x1, yb)
  local legs = line({ { x0, yb }, { x0 + 4, yb - 9 } }, 1):add(line({ { x0 + 7, yb }, { x0 + 4, yb - 9 } }, 1))
    :add(line({ { x1, yb }, { x1 - 4, yb - 9 } }, 1)):add(line({ { x1 - 7, yb }, { x1 - 4, yb - 9 } }, 1))
  rimOf(legs, L.timber) part(legs, L.timber, { nopop = true, noshade = true })
  local log = rect(x0 - 2, yb - 15, x1 + 6, yb - 9)
  rimOf(log, L.timber) part(log, L.timber)
  F.logs(log, L.timber, yb - 15, 7)
  log:each(function(x, y) if hash(x // 2, y, 14) < .15 then px(x, y, L.timber.shade) end end)
  F.logEnd(x1 + 6, yb - 12, 3)
  F.moss(log, .08, 15)
  -- saw kerf + sawdust heap
  vline(x1 - 2, yb - 15, yb - 11, L.timber.edge)
  local dust = c:ellipse(x1 - 2, yb + 1, 5, 1)
  fill(dust, L.board.hi) px(x1 - 4, yb, L.board.base) px(x1, yb + 1, L.board.shade)
end
F.shadow(372, 412, 198, 6, 3)
sawhorse(380, 404, 198)
local _, lhx, lhy = F.gnome(370, 202, { hat = L.awnA, coat = L.wall2, arm = "out" })
local _, rhx, rhy = F.gnome(420, 204, { hat = L.roof2, coat = L.accent, arm = "out", flip = true })
-- the crosscut saw between their hands, passing through the kerf
local sawM = line({ { lhx, lhy }, { rhx, rhy } }, 1)
sawM:add(line({ { lhx + 1, lhy + 1 }, { rhx - 1, rhy + 1 } }, 1))
sawM:each(function(x, y) px(x, y, L.iron.hi) end)
line({ { lhx + 1, lhy + 2 }, { rhx - 1, rhy + 2 } }):each(function(x, y) if x % 2 == 0 then px(x, y, L.iron.shade) end end)
vline(lhx, lhy - 2, lhy + 1, L.timber.base) vline(rhx, rhy - 2, rhy + 1, L.timber.base) -- handles
F.mushroom(430, 212, L.apple, true) F.mushroom(434, 210, L.apple) F.mushroom(426, 211, L.apple)

F.depth(2)
F.birch(76, 162, 48, 43)
---------------------------------------------------------------- left hero: weatherboard mill house + overshot wheel
F.depth(3)
local mtop, mcx, wallM, roofM = F.building{ x0 = 92, x1 = 172, yb = 186, wh = 52, rh = 30, wall = L.timber, roof = L.roof, chimney = true, shingle = true, noFrame = true }
-- weatherboard (horizontal boards) above a mossy stone footing
local boards = wallM:copy():clip(rect(92, mtop + 2, 172, 175))
F.planks(boards, L.timber, 4, false, 17)
local foot = rect(92, 176, 172, 186)
part(foot, L.stone, { nopop = true }) F.courses(foot, 176, 5, 9, L.stone) F.moss(foot, .18, 70)
hline(92, 172, 175, L.timber.edge)
local corners = union(rect(92, mtop, 94, 175), rect(170, mtop, 172, 175), rect(92, mtop, 172, mtop + 1))
part(corners, L.timber, { nopop = true, noshade = true })
F.moss(roofM, .14, 71)
F.door(108, 158, 120, 185, L.timber)
F.window(134, 148, 142, 156, L.timber)
F.window(150, 148, 158, 156, L.timber)
F.window(100, 144, 104, 150, L.timber)
-- a round sign over the door: a pine cone
local plaque = c:ellipse(114, 150, 5, 4) rimOf(plaque, L.timber) part(plaque, L.board)
F.sprite({ ".s.", "sSs", "SsS", "sSs", ".S." }, 113, 148, { s = L.soil.shade, S = L.soil.base }, { rim = false })
-- window boxes with ferns
for _, wx in ipairs({ 138, 154 }) do
  hline(wx - 5, wx + 5, 159, L.timber.base) hline(wx - 5, wx + 5, 160, L.timber.deep)
  for k = -4, 4, 2 do px(wx + k, 158, L.fern.base) px(wx + k + 1, 157, L.fern.hi) end
end

-- stone wheel pit behind the wheel
local pit = rect(170, 176, 214, 200)
rimOf(pit, L.stone) part(pit, L.stone) F.courses(pit, 176, 6, 10, L.stone) F.moss(pit, .2, 72)
-- flume on trestles, bringing water over the top of the wheel
local flume = poly{ { 186, 140 }, { 226, 130 }, { 226, 135 }, { 186, 145 } }
local legs = rect(218, 135, 220, 150):add(rect(206, 138, 208, 152))
rimOf(union(flume, legs), L.timber)
part(legs, L.timber, { nopop = true, noshade = true })
part(flume, L.board)
F.moss(flume, .1, 73)
line({ { 187, 140 }, { 225, 130 } }):each(function(x, y) px(x, y, L.water.base) end)

local hx, hy, R = 192, 170, 26
local outer = c:ellipse(hx, hy, R, R)
local ringO = outer:copy():cut(c:ellipse(hx, hy, R - 4, R - 4))
local ringI = c:ellipse(hx, hy, 9, 9):cut(c:ellipse(hx, hy, 6, 6))
local spokes, pads = HP.mask(), HP.mask()
for k = 0, 7 do
  local a = k * pi / 4 + .2
  spokes:add(line({ { hx + cos(a) * 6, hy + sin(a) * 6 }, { hx + cos(a) * (R - 3), hy + sin(a) * (R - 3) } }, 2))
end
for k = 0, 15 do
  local a = k * pi / 8 + .1
  local p1 = { hx + cos(a) * (R - 3), hy + sin(a) * (R - 3) }
  local p2 = { hx + cos(a) * (R + 3), hy + sin(a) * (R + 3) }
  pads:add(line({ p1, p2 }, 2))
end
local wheel = union(ringO, ringI, spokes, pads)
rimOf(wheel, L.timber)
part(spokes, L.timber, { nopop = true, noshade = true })
part(ringI, L.timber, { nopop = true })
part(pads, L.board, { nopop = true, noshade = true })
part(ringO, L.timber, { nopop = true })
ringO:each(function(x, y) if (x - hx) + (y - hy) < -R * .8 and ((x - hx) ^ 2 + (y - hy) ^ 2) > (R - 2) ^ 2 then px(x, y, L.timber.hi) end end)
-- wet moss on the lower rim
ringO:each(function(x, y) if y > hy + R * .55 and hash(x, y, 74) < .45 then px(x, y, hash(x, y, 75) < .5 and L.moss.base or L.moss.shade) end end)
local hubm = c:ellipse(hx, hy, 3, 3) fill(hubm, L.iron.base) px(hx - 1, hy - 1, L.iron.hi) px(hx + 1, hy + 1, L.iron.deep)
-- water pouring over the far side of the wheel + splash
local pour = poly{ { 184, 142 }, { 190, 142 }, { 214, 160 }, { 220, 182 }, { 216, 198 }, { 212, 182 }, { 208, 162 } }
pour:cut(spokes):cut(ringI)
pour:each(function(x, y) px(x, y, hash(x, y, 4) < .3 and L.water.hi or L.water.base) end)
for i = 0, 8 do local x, y = 200 + floor(hash(i, 1, 9) * 26), 192 + floor(hash(i, 2, 9) * 10) px(x, y, L.water.hi) px(x + 1, y, L.awnB.hi) end
-- quirk: a red squirrel in a red gnome hat riding the top paddle, clutching a pine cone
F.sprite({
  "...........R....",
  "..........RRr...",
  ".........RRRr...",
  "........RRRRr...",
  ".......hhhhhhh..",
  ".TTT...aBBBBBb..",
  "TTTTT.aBBBBBBBb.",
  "TTttT.BBBeBBBBBn",
  "TT.tTtBBBBBBCC..",
  "T..tTtBBBBBCC...",
  "...tTtBBBBCPP...",
  "..TTtBBBBCPPp...",
  ".TTtBBBBBBCpp...",
  ".TtbBBBBBBC.....",
  "..bBBBBBBBb.....",
  "..BB.....BB.....",
}, 178, 125, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, T = L.needle.hi, t = L.needle.shade, B = L.needle.base,
  b = L.needle.shade, a = L.needle.deep, C = L.awnB.base, e = L.timber.edge, n = L.timber.edge, P = L.soil.base, p = L.soil.deep })

---------------------------------------------------------------- tail race and mill pond (bottom-left)
local stream = poly{ { 170, 200 }, { 214, 200 }, { 206, 214 }, { 176, 226 }, { 150, 230 }, { 138, 222 }, { 160, 212 } }
local pond = poly{ { 18, 232 }, { 40, 220 }, { 96, 216 }, { 150, 220 }, { 180, 230 }, { 176, 250 }, { 140, 262 }, { 80, 266 }, { 30, 262 }, { 16, 250 } }
local water = union(stream, pond)
rimOf(water, L.water)
local bank = water:grow(2):cut(water)
bank:each(function(x, y) if y > 199 then local v = hash(x, y, 51) px(x, y, v < .35 and L.stone.base or (v < .6 and L.stone.hi or L.moss.base)) end end)
F.water(water, L.water)
-- dark reflections of the pines along the far edge, and the wheel
for _, rx in ipairs({ 40, 58, 120, 140 }) do for k = 0, 5 do hline(rx - 3 + k // 2, rx + 3 - k // 2, 222 + k * 2, L.water.shade) end end
for y = 206, 214, 3 do hline(176, 196, y, L.water.shade) end
-- a mallard drake, a duck and three ducklings in a line, each with a ripple
local function swim(x, y, kind)
  if kind == "drake" or kind == "duck" then
    local m = c:ellipse(x, y, 5, 3):add(c:ellipse(x + 5, y - 4, 2, 2))
    rimOf(m, L.timber)
    part(m, kind == "drake" and L.awnB or L.needle, { nopop = true })
    if kind == "drake" then
      fill(c:ellipse(x + 5, y - 4, 2, 2), L.foliage2.base) px(x + 4, y - 5, L.foliage2.hi) hline(x + 3, x + 6, y - 2, L.awnB.hi)
      px(x - 1, y - 2, L.needle.shade) px(x, y - 2, L.needle.shade) px(x - 4, y - 1, L.timber.deep)
    else
      for k = -3, 3, 2 do px(x + k, y - 1, L.needle.shade) end
    end
    fill(rect(x + 7, y - 4, x + 8, y - 3), L.gold.base) px(x + 5, y - 5, L.timber.edge) hline(x - 6, x + 6, y + 3, L.water.hi)
  else
    local m = c:ellipse(x, y, 2, 1):add(rect(x + 1, y - 2, x + 2, y - 1))
    rimOf(m, L.timber) part(m, L.gold, { nopop = true })
    px(x + 3, y - 2, L.gold.shade) hline(x - 3, x + 3, y + 2, L.water.hi)
  end
end
swim(110, 238, "drake") swim(96, 236, "duck") swim(84, 240) swim(74, 243) swim(64, 241)
-- cattails and lily pads
for i = 0, 8 do
  local x = 20 + i * 3 local h = 7 + floor(hash(i, 9, 52) * 9)
  vline(x, 247 - h, 247, i % 2 == 0 and L.fern.shade or L.fern.deep)
  if i % 2 == 0 then fill(rect(x, 247 - h - 1, x + 1, 247 - h + 3), L.soil.base) px(x, 247 - h - 1, L.soil.hi) px(x + 1, 247 - h + 3, L.soil.deep) px(x, 247 - h - 2, L.fern.shade) end
end
for _, p in ipairs({ { 60, 230 }, { 92, 248 }, { 48, 252 }, { 140, 246 } }) do
  local pad = poly{ { p[1] - 4, p[2] }, { p[1], p[2] - 2 }, { p[1] + 4, p[2] }, { p[1], p[2] + 2 } }
  fill(pad, L.leaf.base) px(p[1] - 3, p[2], L.leaf.hi) px(p[1] + 1, p[2] + 1, L.leaf.deep)
end
px(93, 247, L.petal.hi) px(94, 247, L.petal.base) px(93, 246, L.petal.hi)
-- mossy boulders on the bank
F.moss(F.rock(166, 252, 9, 8), .3, 76)
F.moss(F.rock(16, 232, 7, 6), .3, 77)
-- plank footbridge over the race
local br = poly{ { 136, 212 }, { 168, 206 }, { 172, 212 }, { 140, 218 } }
rimOf(br, L.timber) part(br, L.board)
F.planks(br, L.board, 5, true, 13)

---------------------------------------------------------------- left: log pile, chopping block, woodcutter gnome
F.depth(3)
F.shadow(34, 96, 202, 8, 4)
local function logPile(x0, yb, n, rr)
  -- the bark side of the pile (behind the end faces), then the end faces row by row
  local back = poly{ { x0 - rr, yb }, { x0 + n * (rr * 2 + 1) + rr, yb }, { x0 + n * (rr + 1) + 8, yb - n * rr * 2 - rr + 2 }, { x0 + n * (rr + 1) - 8 + 12, yb - n * rr * 2 - rr - 2 } }
  for row = 0, n - 1 do
    for k = 0, n - 1 - row do
      local lx = x0 + k * (rr * 2 + 1) + row * (rr + 1)
      local ly = yb - rr - row * (rr * 2)
      local side = rect(lx, ly - rr, lx + 8, ly + rr)
      rimOf(side, L.timber) part(side, L.timber, { nopop = true })
      hline(lx, lx + 8, ly - rr, L.timber.hi)
    end
  end
  for row = 0, n - 1 do
    for k = 0, n - 1 - row do
      F.logEnd(x0 + k * (rr * 2 + 1) + row * (rr + 1), yb - rr - row * (rr * 2), rr)
    end
  end
end
logPile(44, 200, 4, 5)
F.moss(rect(58, 160, 80, 166), .1, 78)
-- chopping block, split firewood and the woodcutter
local blk = rect(114, 202, 126, 210)
local blkTop = c:ellipse(120, 202, 6, 2)
rimOf(union(blk, blkTop), L.timber) part(blk, L.timber, { nopop = true }) fill(blkTop, L.board.base) px(120, 202, L.board.shade) px(117, 201, L.board.hi)
-- an axe bitten into the block
for _, s in ipairs({ { 128, 210 }, { 106, 212 }, { 26, 210 }, { 32, 213 } }) do
  local m = poly{ { s[1], s[2] }, { s[1] + 5, s[2] - 2 }, { s[1] + 6, s[2] }, { s[1] + 1, s[2] + 2 } }
  rimOf(m, L.timber) fill(m, L.board.base) px(s[1] + 1, s[2], L.board.hi) px(s[1] + 5, s[2] - 1, L.timber.base)
end
local _, wx, wy = F.gnome(104, 210, { hat = L.awnA, coat = L.leaf, arm = "up" })
-- the woodcutter's axe raised, mid-swing
line({ { wx, wy + 2 }, { wx - 3, wy - 6 } }):each(function(x, y) px(x, y, L.board.base) end)
fill(rect(wx - 6, wy - 9, wx - 2, wy - 6), L.iron.base) px(wx - 6, wy - 9, L.iron.hi) px(wx - 2, wy - 6, L.iron.deep)
c:rim(rect(wx - 6, wy - 9, wx - 2, wy - 6), L.iron.edge)
fill(rect(wx - 6, wy - 9, wx - 2, wy - 6), L.iron.base) px(wx - 6, wy - 9, L.iron.hi) px(wx - 5, wy - 9, L.iron.hi) px(wx - 2, wy - 6, L.iron.deep)
-- ferns along the left edge
for _, f in ipairs({ { 24, 196, 6 }, { 30, 194, 5 }, { 84, 210, 5 }, { 18, 205, 6 } }) do F.fern(f[1], f[2], f[3]) end

---------------------------------------------------------------- right foreground: a log cart, ferns, mushrooms
F.depth(3)
local function cart(x0, yb)
  local bed = poly{ { x0, yb - 14 }, { x0 + 40, yb - 14 }, { x0 + 38, yb - 6 }, { x0 + 2, yb - 6 } }
  local shaft = line({ { x0 + 40, yb - 10 }, { x0 + 58, yb - 4 } }, 2)
  rimOf(union(bed, shaft), L.timber)
  part(shaft, L.timber, { nopop = true, noshade = true })
  part(bed, L.board) hline(x0 + 1, x0 + 39, yb - 10, L.board.deep)
  -- three long logs on the bed
  for k, lg in ipairs({ { -2, -20, 44 }, { 0, -26, 40 }, { 4, -32, 34 } }) do
    local m = rect(x0 + lg[1], yb + lg[2], x0 + lg[1] + lg[3], yb + lg[2] + 5)
    rimOf(m, L.timber) part(m, k == 2 and L.redbark or L.timber)
    F.logs(m, k == 2 and L.redbark or L.timber, yb + lg[2], 6)
    F.logEnd(x0 + lg[1], yb + lg[2] + 3, 3)
  end
  for _, wx in ipairs({ x0 + 8, x0 + 32 }) do
    local w = c:ellipse(wx, yb - 4, 6, 6)
    rimOf(w, L.timber) part(w, L.timber, { nopop = true })
    fill(c:ellipse(wx, yb - 4, 3, 3), L.timber.shade)
    vline(wx, yb - 9, yb + 1, L.timber.deep) hline(wx - 5, wx + 5, yb - 4, L.timber.deep)
    px(wx, yb - 4, L.iron.hi)
  end
end
F.shadow(302, 352, 226, 8, 3)
cart(300, 226)
for _, f in ipairs({ { 312, 258, 8 }, { 324, 262, 9 }, { 338, 256, 7 }, { 446, 220, 7 }, { 456, 224, 8 }, { 300, 250, 6 } }) do F.fern(f[1], f[2], f[3]) end
-- young spruces and a birch in the near right, so the wood closes in around the stop
-- (keep clear of the compass corner x>=380, y>=230: the frame repaints it)
F.conifer(364, 264, 32, L.foliage2, 41)
F.conifer(420, 226, 22, L.foliage, 42)
F.fern(352, 266, 7) F.fern(374, 262, 6)
F.mushroom(330, 246, L.apple, true) F.mushroom(336, 248, L.apple, true) F.mushroom(326, 249, L.apple)
F.sign(436, 168, 28, 14, L.board)
F.sprite({ "..g..", ".ggg.", "ggggg", ".ggg.", "..t.." }, 434, 171, { g = L.foliage2.shade, t = L.timber.shade }, { rim = false })
-- firewood stack against the sign post
for k = 0, 2 do F.logEnd(452 + k * 6, 200, 3) end
for k = 0, 1 do F.logEnd(455 + k * 6, 194, 3) end
F.logEnd(458, 188, 3)

-- by the road, right: a stump with a jay on it, a split-plank bundle
local st = stump(288, 216, 5)
F.moss(st, .2, 79)
F.sprite({ -- a Eurasian jay: pink-buff body, streaked crest, black moustache, blue-barred wing, white rump, black tail
  "....kSk.......",
  "...JJkJJ......",
  "..JeJJJJ......",
  "gJWkJJJJJ.....",
  "..WkJJJJJJ....",
  "...JJJJBKBJ...",
  "...JJJJKBKJJ..",
  "....jJJWWJJkk.",
  ".....jjJJ.kkkk",
  "......oo..kk..",
}, 280, 201, { J = "#cfa08a", j = "#a87866", S = "#e8d8cc", k = "#3a3036", e = "#3a3036", g = L.iron.shade, W = L.awnB.hi,
  B = "#6a9ed8", K = "#2c4282", o = L.timber.deep })

---------------------------------------------------------------- gnome on the road with a plank on his shoulder
local _, phx, phy = F.gnome(258, 240, { hat = L.roof2, coat = L.wall2, arm = "up" })
local plank = line({ { phx - 18, phy + 8 }, { phx + 10, phy - 3 } }, 2)
rimOf(plank, L.board) part(plank, L.board, { nopop = true, noshade = true })
-- sawdust trail ... to a wood mouse with a dusty nose
for i = 0, 6 do px(252 - i * 4, 243 + i * 3, L.board.hi) px(253 - i * 4, 243 + i * 3, L.board.base) end
local mouse = c:ellipse(222, 263, 4, 2):add(c:ellipse(218, 260, 2, 2))
rimOf(mouse, L.soil) part(mouse, L.needle, { nopop = true }) px(217, 258, L.petal.base) px(219, 257, L.soil.shade) px(220, 257, L.soil.base) px(216, 261, L.board.hi) px(218, 260, L.timber.edge)
line({ { 226, 263 }, { 230, 260 }, { 232, 262 } }):each(function(x, y) px(x, y, L.needle.shade) end)
F.depth(0)
F.birds({ { 300, 40, 2 }, { 310, 46, 1 }, { 292, 49, 1 }, { 140, 58, 2 }, { 186, 74, 1 } })

F.finish()
