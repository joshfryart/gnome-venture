-- workshop.lua : "Workshop" stop look, FOREST (forest_pinewood), 480x270 gate view.
-- Same composition as the Maplewold workshop (art-2701-batch3/stops/opus3/workshop.lua), re-cast as a pine-wood
-- carver's and toymaker's yard (the mill pilot is already the sawmill, so no saws in the lead role here):
-- road's end: the timber gantry crane hoisting a great red-bark pine log for carving over a yard of bark-on logs,
-- between two spruces. Back left: a log cabin with smoke. Back right: the cooper's corner, a barrel being raised
-- in its truss hoop, finished barrels, bent hoops. Left hero: a stone hearth under a mossy lean-to with a long
-- steam box on top (bending ash for hoops and snowshoes), bent frames on the posts, a grey dog asleep in the warmth,
-- a gnome hewing a bowl at a stump with an adze. Right hero: the log-walled toymaker's workshop with an open front:
-- shelf of painted toys, tool wall (gouges, drawknife, mallet, bow saw), bench with a half-carved horse, the carver,
-- spoons on a peg rail, a grindstone. Foreground: an upright log being carved into an owl (gnome with a gouge),
-- carved bowls, birch-bark baskets of spoons and blocks, a duck pull-toy, a painted rocking horse, a toy chest,
-- a gnome carrying a little rocking horse, chopping block with axe, shavings everywhere, ferns and mushrooms.
-- Quirk: a red crossbill has built its nest (with three gaping chicks) on the crane beam, and brings a caterpillar.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-forest-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "workshop", out = DIR, farTrees = { 24, 52, 160, 300, 330, 440 },
  treeLineGap = { 198, 290 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local IR, G = L.iron, L.glow

---------------------------------------------------------------- local helpers
-- a bark-on log lying left-right, end grain showing on the right
local function log(x0, x1, y, r, bark)
  bark = bark or L.timber
  local m = c:rrect(x0, y - r, x1, y + r, r)
  rimOf(m, bark) part(m, bark, { nopop = true })
  m:each(function(x, yy) if hash(x // 3, yy, 17) < .18 then px(x, yy, bark.shade) elseif hash(x // 2, yy, 18) < .06 then px(x, yy, bark.hi) end end)
  hline(x0 + r, x1 - r, y - r + 1, bark.hi)
  F.logEnd(x1 - r + 1, y, r, bark)
  return m
end
local function stump(x, yb, w, bark)
  bark = bark or L.timber
  local body = rect(x - w, yb - w, x + w, yb)
  local top = c:ellipse(x, yb - w, w, math.max(1, w // 2))
  rimOf(union(body, top), bark) part(body, bark, { nopop = true })
  body:each(function(xx, yy) if (xx - x + w) % 3 == 0 and hash(xx, yy // 2, 19) < .6 then px(xx, yy, bark.shade) end end)
  fill(top, L.board.base) px(x, yb - w, L.board.shade) px(x - 1, yb - w - 1, L.board.hi)
  if w > 3 then c:ellipse(x, yb - w, w - 2, math.max(1, w // 2 - 1)):edge():each(function(xx, yy) px(xx, yy, L.board.shade) end) end
  return body, top
end
local function logStack(x, yb, n, rr, bark)
  for row = 0, n - 1 do
    for k = 0, n - 1 - row do
      F.logEnd(x + k * (rr * 2 + 1) + row * (rr + 1), yb - rr - row * (rr * 2), rr, bark)
    end
  end
end
-- curled wood shavings: little hooked strokes in pale wood
local function shavings(x0, x1, y0, y1, n, seed)
  for i = 1, n do
    local x, y = x0 + floor(hash(i, 1, seed) * (x1 - x0)), y0 + floor(hash(i, 2, seed) * (y1 - y0))
    local d = hash(i, 3, seed) < .5 and 1 or -1
    px(x, y, L.board.hi) px(x + d, y, L.board.base) px(x + d, y - 1, L.board.hi)
    if hash(i, 4, seed) < .5 then px(x, y + 1, L.board.shade) end
  end
end
-- a birch-bark basket with a bent-wood rim
local function basket(x, yb, w, h)
  local m = c:rrect(x - w, yb - h, x + w, yb, 2)
  rimOf(m, L.needle) part(m, L.needle, { nopop = true })
  -- checker weave of bark strips, darker to the lower right
  m:each(function(xx, yy)
    local ck = ((xx - x + 20) // 2 + (yy - yb + 20) // 2) % 2 == 0
    local dark = (xx - x) / w + (yy - (yb - h)) / h > 1.1
    local h1 = ck and (dark and L.needle.base or L.needle.hi) or (dark and L.needle.shade or L.needle.base)
    if (xx - x + 20) % 2 == 0 and (yy - yb + 20) % 2 == 0 then h1 = dark and L.needle.deep or L.needle.shade end
    px(xx, yy, h1)
  end)
  hline(x - w, x + w, yb - h, L.birch.base) hline(x - w + 1, x + w - 1, yb - h + 1, L.birch.shade)
  px(x - w, yb - h, L.birch.hi) px(x - w + 2, yb - h, L.birch.edge) px(x + w - 3, yb - h, L.birch.edge)
  return m
end

---------------------------------------------------------------- road's end: carving-log yard + gantry crane
F.depth(2)
F.tree(190, 128, 54, 2)
F.tree(296, 128, 50, 1)
local function crane()
  -- yard: a low stack of bark-on logs and big pine logs waiting their turn
  logStack(204, 126, 3, 3, L.timber)
  log(246, 278, 120, 4, L.redbark) log(250, 282, 112, 4, L.timber) log(244, 274, 104, 3, L.redbark)
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
  -- moss on the beam top and leg feet
  F.moss(beam, .12, 31) F.moss(rect(198, 118, 224, 126):clip(legL), .3, 32) F.moss(rect(262, 118, 288, 126):clip(legR), .3, 33)
  -- pulley, rope, hook, slung log
  local pul = c:ellipse(238, 58, 3, 3) rimOf(pul, IR) part(pul, IR)
  vline(238, 61, 78, L.board.deep) vline(240, 58, 76, L.board.deep)
  fill(rect(236, 79, 241, 80), IR.base)
  fill(line({ { 226, 88 }, { 238, 80 }, { 252, 88 } }), L.board.deep)
  log(218, 262, 92, 5, L.redbark)
  -- winch drum at the right leg
  local drum = rect(268, 106, 282, 112) rimOf(drum, L.timber) part(drum, L.board) for x = 270, 280, 2 do vline(x, 106, 112, L.board.deep) end
  fill(rect(282, 104, 288, 105), IR.base) fill(rect(287, 104, 288, 112), IR.base)
  vline(276, 56, 105, L.board.deep)
  -- winch hand turning the crank
  F.gnome(296, 126, { small = true, hat = L.roof2, coat = L.leaf, arm = "out", flip = true })
  F.depth(3)
  -- quirk: a red crossbill's moss nest on the crane beam, three chicks gaping, the parent arriving with a caterpillar
  F.sprite({
    "..y.......y.......y...",
    ".yYy.....yYy.....yYy..",
    "..gg......gg......gg..",
    ".gegg....gegg....gegg.",
    "mmggmnmmmmggmmnmmmggmm",
    "nMnmNnMnmNnmMnNnmMnnNn",
    ".nNmnnNmnnNnmnNnnmNnn.",
    "..nnNnnnNnnnNnnnNnn...",
  }, 262, 42, { y = L.gold.hi, Y = L.produce.base, g = L.stone.shade, e = L.timber.edge, n = L.timber.base, N = L.timber.shade,
    m = L.moss.base, M = L.moss.hi })
  F.sprite({
    "......rrr.......",
    ".....rRrrr......",
    "....rrerrrkk....",
    "...rrrrrrk.k.cc.",
    "..WWrrrrrr..cc..",
    ".WWwWrrrrr...c..",
    "WWWwWWrrRr......",
    "WWWWwWrRRr......",
    "..WW.RRRR.......",
    ".....o.o........",
  }, 286, 40, { r = L.apple.base, R = L.apple.shade, e = L.timber.edge, k = L.timber.deep, W = L.timber.shade, w = L.awnB.hi,
    c = L.leaf.base, o = L.timber.deep })
end
crane()

---------------------------------------------------------------- back-left: log cabin, log stacks, drying rack
F.depth(1)
F.tree(84, 130, 42, 4)
F.tree(10, 134, 38, 1)
local ctop, ccx, cwall = F.building{ x0 = 22, x1 = 70, yb = 138, wh = 28, rh = 20, wall = L.timber, roof = L.roof2, chimney = true, shingle = true, noAttic = true, noFrame = true }
F.logs(cwall, L.timber, ctop, 3)
for y = ctop + 1, 136, 3 do F.logEnd(21, y, 1) F.logEnd(71, y, 1) end
F.door(38, 122, 47, 137, L.timber)
F.window(54, 118, 60, 124, L.timber)
F.smoke(60, 92, 6, .6, 2)
-- stacked log blanks
F.shadow(96, 150, 141, 6, 2)
logStack(98, 140, 5, 3, L.timber)
logStack(132, 140, 3, 3, L.redbark)
-- a finished carved bear on a log plinth, and bowl blanks drying on a plank
F.shadow(160, 180, 136, 5, 2)
F.sprite({
  "..bb....bb..",
  ".bHBbbbbHBb.",
  ".HBbbbbbbbb.",
  ".HbebbbbebB.",
  "..HbbnnbbB..",
  "...HbbbbB...",
  "..HbbbbbbB..",
  ".HBbbbbbbbB.",
  ".HbbbbbbbbB.",
  "HbbbbbbbbbbB",
  ".HbbbbbbbbB.",
  ".HbBbbbbBbB.",
  "..Hbb..bbB..",
  "..ddd..ddd..",
}, 162, 116, { b = L.soil.base, B = L.soil.shade, H = L.soil.hi, d = L.soil.deep, e = L.timber.edge, n = L.timber.edge })
local pl = rect(160, 130, 175, 135) rimOf(pl, L.timber) part(pl, L.timber, { nopop = true }) F.logEnd(160, 132, 2)
local sh = rect(178, 132, 196, 133):add(rect(179, 134, 180, 137)):add(rect(194, 134, 195, 137))
rimOf(sh, L.timber) part(sh, L.timber, { nopop = true, noshade = true })
for k = 0, 2 do local x = 182 + k * 6 local bw = c:ellipse(x, 130, 3, 1) rimOf(bw, L.timber) fill(bw, L.board.hi) px(x + 1, 130, L.board.shade) end

---------------------------------------------------------------- back-right: the cooper's corner
local function coopers()
  -- a barrel being raised: staves splayed below a truss hoop
  -- staves gathered in a hoop at the top, bulging, splayed open at the foot over a little fire (firing the barrel)
  local raise = HP.mask()
  for k = -4, 4 do
    local xt, xm, xb = 316 + k * 1.5, 316 + k * 2, 316 + k * 3
    raise:add(line({ { xt, 118 }, { xm, 126 }, { xb, 139 } }, 1))
  end
  F.shadow(302, 330, 141, 6, 2)
  rimOf(raise, L.timber)
  raise:each(function(x, y) local k = (x - 300) % 3 local h = k == 0 and L.board.hi or (k == 1 and L.board.base or L.board.shade) if x > 320 then h = k == 0 and L.board.base or L.board.shade end px(x, y, h) end)
  -- gaps between the splayed staves show the fire inside
  for y = 132, 139 do for x = 306, 326 do if not raise:has(x, y) and x > 316 - (y - 118) * .6 and x < 316 + (y - 118) * .6 then px(x, y, y > 136 and L.glow.base or L.soil.deep) end end end
  fill(rect(313, 136, 319, 139), L.glow.base) px(315, 135, L.glow.hi) px(316, 134, L.glow.hi) px(314, 137, L.glow.hi)
  hline(310, 322, 119, IR.hi) hline(310, 322, 120, IR.shade) hline(309, 323, 125, IR.base) hline(309, 323, 126, IR.deep)
  F.smoke(318, 113, 4, .4, 1)
  -- finished barrels
  for _, b in ipairs({ { 333, 134 }, { 345, 129 } }) do F.barrel(b[1], b[2], L.timber, 11) end
  -- bent hoops leaning on a post
  local post = rect(366, 120, 367, 140) rimOf(post, L.timber) part(post, L.timber, { nopop = true })
  for k = 0, 2 do
    local o = c:ellipse(362 + k * 3, 132, 5, 7):cut(c:ellipse(362 + k * 3, 132, 4, 6))
    fill(o, k % 2 == 0 and L.board.base or L.timber.base) px(358 + k * 3, 128, L.board.hi)
  end
end
coopers()
F.depth(2)
F.tree(452, 142, 56, 5)
F.tree(436, 136, 40, 6)

F.depth(2)
F.birch(78, 166, 50, 47)
---------------------------------------------------------------- left hero: hearth with the steam box under a mossy lean-to
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
  F.moss(rect(122, 82, 142, 86), .35, 34)
  part(fire, L.stone, { sep = true }) F.courses(fire, 172, 6, 11, L.stone, 5) F.moss(fire, .1, 35)
  local mouth = c:rrect(118, 178, 150, 200, 8):clip(rect(118, 178, 150, 196))
  fill(mouth, L.soil.deep)
  local coals = c:ellipse(134, 194, 13, 4):clip(mouth)
  fill(coals, G.shade)
  coals:each(function(x, y) local v = hash(x, y, 4) if v < .3 then px(x, y, G.base) elseif v < .4 then px(x, y, G.hi) elseif v > .85 then px(x, y, G.deep) end end)
  local flame = poly{ { 124, 194 }, { 128, 184 }, { 131, 189 }, { 134, 180 }, { 138, 188 }, { 141, 183 }, { 144, 194 } }
  fill(flame, G.base) fill(poly{ { 129, 194 }, { 134, 185 }, { 139, 194 } }, G.hi)
  -- small split logs in the mouth
  F.logEnd(122, 194, 2) F.logEnd(147, 194, 2)
  hline(114, 154, 200, L.stone.hi) hline(114, 154, 201, L.stone.deep)
  -- glow on the ground
  for y = 203, 214 do for x = 116 + (y - 203), 152 - (y - 203) do if hash(x, y, 7) < .35 then px(x, y, L.gold.hi) end end end
  -- the steam box: a long plank box on the hearth, iron straps, a rag-stuffed end leaking steam
  local box = rect(102, 158, 178, 170)
  rimOf(box, L.timber) part(box, L.board)
  F.planks(box, L.board, 4, false, 37)
  for _, x in ipairs({ 112, 140, 168 }) do vline(x, 158, 170, IR.base) vline(x + 1, 158, 170, IR.shade) px(x, 158, IR.hi) end
  local cap = rect(99, 159, 102, 169) rimOf(cap, L.timber) part(cap, L.awnB, { nopop = true }) px(99, 160, L.awnB.hi)
  F.logEnd(178, 164, 3)
  -- a pipe from the fire into the box
  fill(rect(150, 166, 153, 172), IR.base) px(150, 166, IR.hi)
  -- posts and roof, chimney through it
  rimOf(union(posts, roofm), L.timber)
  part(posts, L.timber, { nopop = true })
  F.logs(posts, L.timber, 128, 7)
  part(roofm, L.roof, { sep = true }) F.courses(roofm, 128, 3, 6, L.roof) F.moss(roofm, .22, 36)
  hline(84, 196, 134, L.roof.deep)
  part(rect(124, 84, 140, 128):clip(chim), L.stone) F.courses(rect(124, 84, 140, 128), 84, 6, 8, L.stone)
  F.smoke(132, 78, 9, .7, 3)
  -- steam from the stuffed end of the box
  local st = { "#f4f6ee", "#e6eadd", "#d6dccc" }
  for k = 0, 5 do
    local x, y = 98 - k * 2 + floor(sin(k * 1.4) * 2), 156 - k * 4
    local m = c:ellipse(x, y, 2 + k // 2, 1 + k // 2)
    fill(m, st[1 + k % 3]) m:edge():each(function(xx, yy) if yy > y then px(xx, yy, st[3]) end end)
  end
  -- bent hoops and snowshoe frames on the left post
  for k = 0, 2 do
    local y = 142 + k * 10
    local o = c:ellipse(100, y, 3, 4):cut(c:ellipse(100, y, 2, 3))
    fill(o, k == 1 and L.board.hi or L.board.base) px(98, y - 3, L.board.hi) px(102, y + 3, L.board.shade)
  end
  local shoe = c:ellipse(100, 182, 4, 7):cut(c:ellipse(100, 182, 3, 6))
  fill(shoe, L.board.shade) for y = 177, 187, 2 do hline(98, 102, y, L.soil.base) end
  -- a bent sled runner hanging on the right post
  local run = line({ { 183, 148 }, { 183, 170 }, { 181, 174 }, { 178, 175 } }, 1)
  run:each(function(x, y) px(x, y, L.board.base) px(x + 1, y, L.board.deep) end)
  -- split firewood stacked by the hearth
  F.shadow(162, 186, 203, 4, 2)
  for k = 0, 3 do F.logEnd(165 + k * 6, 199, 3) end
  for k = 0, 2 do F.logEnd(168 + k * 6, 193, 3) end
  F.logEnd(171, 187, 3) F.logEnd(177, 187, 3, L.redbark)
end
hearth()
-- a gnome hewing a bowl at a stump with an adze
local function hewing(x, yb)
  F.shadow(x - 8, x + 9, yb, 8, 3)
  stump(x, yb, 7)
  -- the bowl blank: a half-log with its hollow begun
  local blank = c:ellipse(x, yb - 9, 8, 3):clip(rect(x - 8, yb - 12, x + 8, yb - 6)):add(rect(x - 8, yb - 9, x + 8, yb - 8))
  rimOf(blank, L.timber) part(blank, L.board) hline(x - 7, x + 7, yb - 10, L.board.hi)
  local hol = c:ellipse(x, yb - 10, 5, 1) fill(hol, L.board.shade) px(x + 2, yb - 10, L.board.deep)
  -- flying chips
  for i = 0, 9 do local sx, sy = x - 10 + floor(hash(i, 1, 21) * 22), yb - 16 - floor(hash(i, 2, 21) * 10) px(sx, sy, i % 3 == 0 and L.board.base or L.board.hi) end
  shavings(x - 14, x + 14, yb + 1, yb + 6, 14, 22)
end
hewing(168, 232)
local _, hx, hy = F.gnome(148, 238, { hat = L.awnA, coat = L.wall2, arm = "up" })
fill(rect(hx, hy - 6, hx + 1, hy + 1), L.board.base) fill(rect(hx + 1, hy - 8, hx + 5, hy - 6), IR.base) px(hx + 1, hy - 8, IR.hi) px(hx + 5, hy - 5, IR.shade) -- adze up
fill(rect(146, 228, 150, 235), L.soil.shade) px(146, 228, L.soil.base) -- leather apron
-- a grey forest dog asleep in the hearth's warmth
F.sprite({
  "................ee..ee...",
  "...............eHHeeHHe..",
  "......DDDDDDD..HHHHHHHH..",
  "....TDDDDDDDDDHHkkHHkkHH.",
  "...TTDDdDDDDDDHHHHHHHHnn.",
  "..TTTDDDdDDDDDDHHHHHHHnn.",
  "...TTDDDDDDDDDDPPHHHHPPP.",
  ".....LLdLLLLLLLPPPLLLPPP.",
}, 100, 210, { e = L.stone.deep, D = L.stone.base, d = L.stone.shade, H = L.stone.hi, k = L.timber.edge, M = L.stone.deep,
  n = L.timber.edge, T = L.stone.shade, L = L.awnB.shade, P = L.awnB.hi })
local qb = F.barrel(196, 236, L.timber, 12) fill(rect(192, 225, 200, 226), L.water.base) px(193, 225, L.water.hi)
-- a birch dipper hooked on the barrel
fill(rect(199, 222, 202, 223), L.birch.base) vline(202, 220, 222, L.birch.shade)

---------------------------------------------------------------- right hero: the toymaker's log workshop, open front
local function workshop()
  local x0, x1, yb = 296, 446, 208
  local top, cx, wallM, roofM = F.building{ x0 = x0, x1 = x1, yb = yb, wh = 56, rh = 36, wall = L.timber, roof = L.roof, shingle = true, noFrame = true }
  F.logs(wallM, L.timber, top, 4)
  local gab = poly{ { x0 + 5, top }, { cx, top - 36 + 8 }, { x1 - 5, top } }:cut(roofM)
  F.logs(gab, L.timber, top, 4)
  F.window(cx - 3, top - 36 // 2 + 1, cx + 2, top - 36 // 2 + 5, L.timber)
  for y = top + 2, yb - 1, 4 do F.logEnd(x0 - 1, y, 2) F.logEnd(x1 + 1, y, 2) end
  -- fix-up: a proper shingled bargeboard band along the gable, so the roof is not a thin line
  gab:each(function(x, y)
    local d = 0
    while d < 7 and gab:has(x, y - d - 1) do d = d + 1 end
    if d <= 5 then
      local h
      if d == 0 then h = L.roof.hi
      elseif d == 5 then h = L.roof.deep
      elseif (x + d * 2) % 5 == 0 then h = L.roof.shade
      else h = (d % 2 == 0) and L.roof.base or L.roof.shade end
      if d > 0 and d < 5 and hash(x, y, 41) < .08 then h = L.moss.base end
      px(x, y, h)
    end
  end)
  F.moss(roofM, .13, 38)
  wallM:each(function(x, y) if y > yb - 6 and hash(x, y // 2, 39) < .45 then px(x, y, hash(x, y, 40) < .5 and L.moss.shade or L.moss.base) end end)
  -- window, left of the doorway
  F.window(303, 174, 313, 183, L.timber)
  hline(301, 315, 187, L.timber.base) for k = 0, 5 do px(303 + k * 2, 186, L.fern.base) px(304 + k * 2, 185, L.fern.hi) end
  -- big open doorway with the interior
  local dx0, dx1, dy0 = 322, 420, 166
  local fr = rect(dx0 - 3, dy0 - 3, dx1 + 3, yb)
  fill(fr, L.timber.base) hline(dx0 - 3, dx1 + 3, dy0 - 3, L.timber.hi) hline(dx0 - 3, dx1 + 3, dy0 - 1, L.timber.deep)
  vline(dx0 - 3, dy0 - 3, yb, L.timber.hi)
  fill(rect(dx0, dy0, dx1, yb), L.soil.deep)
  fill(rect(dx0, yb - 6, dx1, yb), L.soil.shade)
  -- back wall boards inside
  for x = dx0 + 4, dx1, 8 do vline(x, dy0, yb - 7, L.soil.edge) end
  -- toy shelf (left) : horse, top, boat, bird, doll, ball
  local tw = rect(dx0 + 4, dy0 + 3, dx0 + 46, dy0 + 22) fill(tw, L.soil.base) c:edgeIn(tw, L.timber.deep)
  for _, sy in ipairs({ dy0 + 11, dy0 + 21 }) do hline(dx0 + 4, dx0 + 46, sy, L.board.base) hline(dx0 + 4, dx0 + 46, sy + 1, L.timber.deep) end
  local Y1, Y2 = dy0 + 10, dy0 + 20
  F.sprite({ "..rr", ".rrr", "rrrr", "r..r" }, 330, Y1 - 3, { r = L.apple.base }, {})
  px(332, Y1 - 3, L.apple.hi)
  F.sprite({ "ggg", ".g.", }, 338, Y1 - 1, { g = L.gold.base }, {}) px(339, Y1 - 2, L.timber.base)
  F.sprite({ "..s..", "..s..", "bbbbb", ".bbb." }, 344, Y1 - 3, { s = L.awnB.base, b = L.accent.base }, {})
  F.sprite({ ".ll.", "llll", "..ll" }, 352, Y1 - 2, { l = L.lav.base }, {})
  F.sprite({ "p", "P", "P" }, 359, Y1 - 2, { p = L.skin.base, P = L.petal.base }, {})
  F.sprite({ ".oo", "ooo" }, 362, Y1 - 1, { o = L.produce.base }, {})
  -- lower shelf: painted blocks and a little cart
  for k = 0, 5 do local x = 330 + k * 3 local r = ({ L.apple, L.gold, L.accent, L.lav, L.produce, L.leaf })[k + 1] fill(rect(x, Y2 - 2, x + 1, Y2), r.base) px(x, Y2 - 2, r.hi) end
  F.sprite({ "aaaaaa", "w.ww.w" }, 350, Y2 - 2, { a = L.awnA.base, w = L.timber.base }, {})
  F.sprite({ ".gg.", "gggg" }, 360, Y2 - 1, { g = L.leaf.base }, {})
  -- tool wall (right): bow saw, drawknife, gouges, mallet, adze
  local tw2 = rect(dx0 + 50, dy0 + 3, dx1 - 6, dy0 + 22) fill(tw2, L.soil.base) c:edgeIn(tw2, L.timber.deep)
  local bow = line({ { 376, 171 }, { 376, 184 } }):add(line({ { 390, 171 }, { 390, 184 } })):add(line({ { 376, 177 }, { 390, 177 } }))
  fill(bow, L.board.base) hline(376, 390, 184, IR.hi) for x = 377, 389, 2 do px(x, 185, IR.base) end
  hline(394, 404, 172, IR.hi) hline(394, 404, 173, IR.shade) vline(393, 172, 176, L.board.base) vline(405, 172, 176, L.board.base) -- drawknife
  for k = 0, 3 do local x = 395 + k * 3 vline(x, 177, 182, L.board.base) vline(x, 183, 186, IR.hi) px(x, 177, L.board.hi) end -- gouges
  fill(rect(408, 171, 412, 175), L.board.shade) vline(410, 176, 185, L.board.base) px(408, 171, L.board.hi) -- mallet
  vline(415, 172, 185, L.board.base) fill(rect(413, 171, 417, 172), IR.base) px(413, 171, IR.hi) -- adze
  -- workbench with vice, a half-carved horse, spoon blanks
  local bench = rect(330, 192, 414, 196)
  local legs = rect(334, 197, 337, 208):add(rect(407, 197, 410, 208))
  rimOf(union(bench, legs), L.timber) part(bench, L.board) F.planks(bench, L.board, 3, false, 41) part(legs, L.timber, { nopop = true, noshade = true })
  local vice = rect(412, 188, 418, 198) rimOf(vice, L.timber) part(vice, L.timber, { nopop = true }) fill(rect(418, 192, 422, 193), L.board.hi)
  -- the half-carved horse: finished head, rough block body
  F.sprite({
    "....hh.......",
    "...hhhH......",
    "..hhhHH......",
    ".hhHHbbbbbbb.",
    "....HbbbbbbB.",
    "....bBbBbBbB.",
    "....bb...bb..",
  }, 352, 185, { h = L.board.hi, H = L.board.base, b = L.board.shade, B = L.board.deep })
  for k = 0, 2 do hline(372 + k * 5, 375 + k * 5, 191, L.board.hi) px(371 + k * 5, 191, L.board.base) end -- spoon blanks
  shavings(338, 412, 200, 207, 30, 42)
  shavings(370, 390, 189, 191, 6, 43)
  -- the carver at the bench
  F.gnome(392, 208, { hat = L.lav, coat = L.accent, arm = "hold", flip = true, noShadow = true })
  -- hanging lantern inside
  vline(372, 166, 169, L.timber.edge) local ln = rect(370, 170, 374, 174) rimOf(ln, IR) fill(ln, G.base) px(370, 170, G.hi) px(374, 174, G.shade)
  -- sign above the doorway: a carved horse on a plank
  local sb = rect(352, 148, 390, 159) rimOf(sb, L.timber) part(sb, L.board) F.planks(sb, L.board, 4, false, 44)
  F.sprite({
    "........rr.....",
    ".......rrrr....",
    "rr....rrrrr....",
    ".rrrrrrrrr.....",
    "..rrrrrrrr.....",
    "..r..r..r.r....",
  }, 362, 150, { r = L.awnA.base }, { rim = false })
  px(370, 150, L.awnA.hi) px(371, 151, L.awnA.hi)
  -- spoons and ladles on a peg rail, right wall
  hline(424, 444, 170, L.timber.deep) hline(424, 444, 169, L.timber.hi)
  for k = 0, 4 do local x = 426 + k * 4
    vline(x, 171, 178 + (k % 2) * 2, L.board.base)
    fill(c:ellipse(x, 180 + (k % 2) * 2, 1, 2), k % 2 == 0 and L.board.hi or L.board.shade)
  end
end
workshop()
-- a grindstone for the edges, against the right wall
local function grindstone(x, yb)
  local frame = rect(x - 12, yb - 12, x - 10, yb):add(rect(x + 10, yb - 12, x + 12, yb)):add(rect(x - 12, yb - 4, x + 12, yb - 3))
  local stone = c:ellipse(x, yb - 20, 10, 10)
  local trough = rect(x - 9, yb - 8, x + 9, yb - 4)
  F.shadow(x - 12, x + 12, yb, 6, 2)
  rimOf(union(frame, stone, trough), L.timber)
  part(frame, L.timber, { nopop = true, noshade = true })
  part(trough, L.timber) fill(rect(x - 8, yb - 8, x + 8, yb - 7), L.water.base)
  part(stone, L.stone)
  c:ellipse(x, yb - 20, 7, 7):edge():each(function(xx, yy) px(xx, yy, L.stone.shade) end)
  F.moss(stone, .05, 45)
  fill(c:ellipse(x, yb - 20, 2, 2), IR.base) px(x - 1, yb - 21, IR.hi)
  fill(rect(x + 2, yb - 21, x + 14, yb - 20), IR.base) fill(rect(x + 13, yb - 21, x + 14, yb - 13), IR.base) fill(rect(x + 13, yb - 14, x + 17, yb - 13), L.board.base)
end
grindstone(432, 226)

---------------------------------------------------------------- foreground left: log pile, the owl being carved from a standing log
F.shadow(26, 80, 204, 8, 3)
for row = 0, 3 do for k = 0, 4 - row do
  F.logEnd(30 + k * 10 + row * 5, 198 - row * 8, 5, (k + row) % 3 == 0 and L.redbark or L.timber)
end end
F.moss(rect(40, 170, 70, 176), .15, 46)
F.barrel(84, 202, L.timber, 11)
local function owl(x, yb)
  local sil = poly{ { x - 10, yb }, { x - 10, yb - 36 }, { x - 10, yb - 47 }, { x - 4, yb - 40 }, { x + 4, yb - 40 }, { x + 10, yb - 47 }, { x + 10, yb - 36 }, { x + 10, yb } }
  F.shadow(x - 10, x + 10, yb, 10, 4)
  rimOf(sil, L.timber)
  local split = function(xx, yy) return yy > yb - 17 + floor(hash(xx, 0, 48) * 4) end
  sil:each(function(xx, yy)
    local u = (xx - x) / 10
    if split(xx, yy) then
      -- still bark: grooved, mossy at the foot
      local h = L.timber.base
      if (xx - x + 20) % 3 == 0 then h = L.timber.shade end
      if u > .5 then h = L.timber.deep elseif u < -.6 then h = L.timber.hi end
      if hash(xx, yy // 3, 49) < .12 then h = L.timber.shade end
      px(xx, yy, h)
    else
      local h = L.board.base
      if u < -.55 then h = L.board.hi elseif u > .5 then h = L.board.shade end
      if u > .8 then h = L.board.deep end
      px(xx, yy, h)
    end
  end)
  F.moss(rect(x - 10, yb - 5, x + 10, yb):clip(sil), .35, 50)
  -- chisel marks along the carving line
  for xx = x - 9, x + 9, 2 do local yy = yb - 17 + floor(hash(xx, 0, 48) * 4) px(xx, yy, L.board.hi) px(xx + 1, yy - 1, L.board.shade) end
  -- face disc, eyes, beak, brows
  c:ellipse(x, yb - 31, 8, 6):edge():each(function(xx, yy) px(xx, yy, (xx < x and yy < yb - 31) and L.board.hi or L.board.deep) end)
  for _, ex in ipairs({ x - 4, x + 4 }) do
    local e = c:ellipse(ex, yb - 32, 3, 3)
    fill(e, L.board.hi) c:edgeIn(e, L.board.deep)
    fill(rect(ex - 1, yb - 33, ex, yb - 32), L.timber.edge) px(ex - 1, yb - 33, L.board.hi)
  end
  fill(poly{ { x - 1, yb - 29 }, { x + 1, yb - 29 }, { x, yb - 25 } }, L.soil.base) px(x - 1, yb - 29, L.soil.hi)
  line({ { x - 8, yb - 37 }, { x - 2, yb - 35 } }):each(function(xx, yy) px(xx, yy, L.board.deep) end)
  line({ { x + 8, yb - 37 }, { x + 2, yb - 35 } }):each(function(xx, yy) px(xx, yy, L.board.deep) end)
  -- breast feathers: rows of little chevrons
  for row = 0, 2 do local yy = yb - 23 + row * 3
    for xx = x - 6 + (row % 2) * 2, x + 6, 4 do px(xx, yy, L.board.shade) px(xx + 1, yy + 1, L.board.deep) px(xx + 2, yy, L.board.shade) end
  end
  -- folded wings
  vline(x - 8, yb - 25, yb - 18, L.board.deep) vline(x + 8, yb - 25, yb - 18, L.board.deep)
  -- chips heaped at the base
  local heap = poly{ { x - 14, yb + 2 }, { x - 4, yb - 2 }, { x + 10, yb - 1 }, { x + 18, yb + 3 } }
  heap:each(function(xx, yy) local v = hash(xx, yy, 51) px(xx, yy, v < .35 and L.board.hi or (v < .7 and L.board.base or L.board.shade)) end)
  shavings(x - 16, x + 22, yb - 2, yb + 8, 22, 52)
end
owl(44, 256)
local _, ox, oy = F.gnome(68, 260, { hat = L.produce, coat = L.leaf, arm = "up", flip = true })
-- a gouge in hand, its edge in the owl's wing
fill(rect(ox - 1, oy, ox, oy + 2), L.board.base) fill(line({ { ox - 2, oy - 1 }, { ox - 6, oy - 3 } }), IR.hi) px(ox - 6, oy - 3, IR.base)
for i = 0, 3 do px(ox - 6 - floor(hash(i, 3, 53) * 4), oy - 6 - i * 2, L.board.hi) end -- flying chips
-- a stack of finished bowls and spoons beside it
for k = 0, 2 do
  local y = 258 - k * 3
  local b = c:ellipse(92, y, 8 - k, 3):clip(rect(84, y - 1, 100, y + 3))
  rimOf(b, L.timber) fill(b, k % 2 == 0 and L.board.base or L.board.hi) hline(92 - 6 + k, 92 + 6 - k, y - 1, L.board.shade) px(86 + k, y, L.board.hi)
end
fill(c:ellipse(92, 248, 5, 1), L.board.deep)
-- a carved spoon lying on top of the stack
hline(88, 94, 247, L.board.hi) fill(c:ellipse(96, 247, 2, 1), L.board.base)

---------------------------------------------------------------- foreground right: baskets, toys, chest
F.depth(3)
-- birch-bark baskets, one of spoons, one of painted blocks
basket(306, 238, 7, 8)
for k = 0, 3 do local x = 301 + k * 3 vline(x, 225 + k % 2, 230, L.board.base) fill(c:ellipse(x, 224 + k % 2, 1, 1), L.board.hi) end
basket(322, 242, 6, 7)
for k = 0, 3 do local x = 318 + k * 3 local r = ({ L.apple, L.gold, L.accent, L.lav })[k + 1] fill(rect(x, 233 + k % 2, x + 1, 235), r.base) px(x, 233 + k % 2, r.hi) end
-- a duck pull-toy on wheels with its string
local duck = F.sprite({
  "..yy.....",
  ".yyyo....",
  "..yy.....",
  "yyyyyyy..",
  "yyyyyyyy.",
  ".YYYYYY..",
  ".ww..ww..",
}, 286, 250, { y = L.gold.base, Y = L.gold.shade, o = L.produce.base, w = L.timber.deep })
px(288, 251, L.timber.edge) px(287, 253, L.gold.hi)
line({ { 294, 254 }, { 300, 252 }, { 308, 256 }, { 312, 255 } }):each(function(x, y) px(x, y, L.board.deep) end)
-- a painted rocking horse
local function rocker(x, yb)
  local body = c:rrect(x - 8, yb - 13, x + 6, yb - 8, 2)
  local neck = poly{ { x + 3, yb - 13 }, { x + 6, yb - 20 }, { x + 11, yb - 19 }, { x + 11, yb - 16 }, { x + 7, yb - 15 }, { x + 6, yb - 10 } }
  local legs = line({ { x - 6, yb - 8 }, { x - 8, yb - 3 } }, 2):add(line({ { x + 4, yb - 8 }, { x + 6, yb - 3 } }, 2))
  local rock = line({ { x - 13, yb - 5 }, { x - 8, yb - 2 }, { x, yb - 1 }, { x + 8, yb - 2 }, { x + 13, yb - 5 } }, 2)
  local tail = line({ { x - 8, yb - 12 }, { x - 12, yb - 8 } }, 1)
  F.shadow(x - 12, x + 12, yb + 1, 5, 2)
  local sil = union(body, neck, legs, rock, tail)
  rimOf(sil, L.timber)
  part(rock, L.board, { nopop = true }) hline(x - 6, x + 6, yb - 2, L.board.hi)
  part(legs, L.awnB, { nopop = true, noshade = true })
  part(body, L.awnB) part(neck, L.awnB, { nopop = true })
  -- dapples, red saddle, mane, eye
  for _, d in ipairs({ { -5, -11 }, { -2, -10 }, { 3, -11 } }) do px(x + d[1], yb + d[2], L.awnB.shade) end
  fill(rect(x - 3, yb - 13, x + 1, yb - 10), L.awnA.base) hline(x - 3, x + 1, yb - 13, L.awnA.hi) hline(x - 3, x + 1, yb - 10, L.awnA.deep)
  line({ { x + 5, yb - 19 }, { x + 3, yb - 14 } }):each(function(xx, yy) px(xx, yy, L.soil.shade) px(xx - 1, yy, L.soil.base) end)
  fill(tail, L.soil.base)
  px(x + 8, yb - 18, L.timber.edge) px(x + 11, yb - 17, L.awnA.shade)
end
rocker(354, 240)
-- a painted toy chest
local tb = rect(326, 250, 346, 260) rimOf(tb, L.timber) part(tb, L.accent) hline(326, 346, 253, L.accent.deep) hline(326, 346, 254, L.accent.hi)
for _, x in ipairs({ 330, 342 }) do vline(x, 251, 259, L.gold.shade) end fill(rect(335, 254, 337, 256), L.gold.base) px(335, 254, L.gold.hi)
F.sprite({ "r.g.y", "rrgyy" }, 332, 248, { r = L.apple.base, g = L.leaf.base, y = L.gold.hi }, { rim = false })
-- bent ash hoops in a stack
for k = 0, 2 do
  local y = 258 - k * 4
  local o = c:ellipse(366, y, 10, 4):cut(c:ellipse(366, y, 7, 2))
  rimOf(o, L.timber) fill(o, k % 2 == 0 and L.board.base or L.board.shade)
  o:each(function(x, yy) if yy < y - 1 then px(x, yy, L.board.hi) end end)
end
-- ferns and mushrooms
for _, f in ipairs({ { 264, 262, 7 }, { 276, 266, 8 }, { 120, 262, 7 }, { 108, 266, 6 }, { 22, 262, 8 }, { 372, 226, 6 }, { 296, 214, 5 }, { 452, 220, 6 } }) do F.fern(f[1], f[2], f[3]) end
F.mushroom(132, 258, L.apple, true) F.mushroom(137, 260, L.apple) F.mushroom(282, 232, L.needle, true) F.mushroom(286, 234, L.needle)
F.mushroom(206, 214, L.apple, true) F.mushroom(210, 216, L.apple)

---------------------------------------------------------------- the carrier: a gnome bringing a little rocking horse along the road
local _, cx1, cy1 = F.gnome(276, 214, { hat = L.roof2, coat = L.awnA, arm = "up" })
F.sprite({
  "........hh.",
  ".......hhhh",
  "rr.bbbbbhh.",
  ".rbbbbbbb..",
  "..bbbbbbb..",
  "..l.l..l.l.",
  "RRRRRRRRRRR",
  ".RR.....RR.",
}, cx1 - 6, cy1 - 8, { h = L.board.hi, b = L.board.base, r = L.soil.base, l = L.board.shade, R = L.awnA.base })
px(cx1 + 2, cy1 - 7, L.timber.edge)
-- shavings trail along the left verge
shavings(200, 236, 238, 262, 14, 54)

F.depth(0)
F.birds({ { 330, 34, 2 }, { 344, 40, 1 }, { 168, 50, 1 }, { 150, 44, 2 } })
-- chopping block with an axe by the road (left)
F.depth(3)
local cb = log(176, 198, 256, 6)
F.moss(cb, .1, 55)
local axe = line({ { 186, 248 }, { 196, 236 } }, 2) rimOf(axe, L.timber) fill(axe, L.board.base)
fill(poly{ { 193, 234 }, { 200, 230 }, { 201, 238 } }, IR.hi) px(200, 237, IR.shade) px(195, 234, IR.base)
for _, s in ipairs({ { 166, 260 }, { 204, 262 } }) do
  local m = poly{ { s[1], s[2] }, { s[1] + 5, s[2] - 2 }, { s[1] + 6, s[2] }, { s[1] + 1, s[2] + 2 } }
  rimOf(m, L.timber) fill(m, L.board.base) px(s[1] + 1, s[2], L.board.hi) px(s[1] + 5, s[2] - 1, L.timber.base)
end
F.finish()
