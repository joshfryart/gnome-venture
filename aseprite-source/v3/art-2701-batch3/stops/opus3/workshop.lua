-- workshop.lua : "Workshop" stop look, Maplewold (480x270 gate view). Opus second pass.
-- Read: a smithy forge with a glowing hearth, tall chimney, anvil and quench barrel on the left; an open-fronted
-- carpenter's barn with a tool wall and workbench on the right; a timber gantry crane lifting a log over the
-- lumber yard at the road's end; sawhorse with a half-sawn plank, grindstone, cart wheels, plank stacks.
-- Quirk: a bird has built a nest (with chicks) on the crane beam.
-- opus3 richness pass: depth planes, weatherboard grain, a real smoke column, sparks, five working gnomes (smith,
-- carpenter at the bench, sawyer, winch hand, plank carrier), a dog by the forge warmth. The nest is now big: three
-- gaping chicks and a robin bringing a worm, readable at 50%.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/opus3/"
local F = dofile(DIR .. "_frame.lua").build{ name = "workshop", out = DIR, farTrees = { 24, 52, 160, 300, 330, 440 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local IR, G = L.iron, L.glow

local function log(x0, x1, y, r)
  local m = c:rrect(x0, y - r, x1, y + r, r)
  rimOf(m, L.timber) part(m, L.timber, { nopop = true })
  hline(x0 + r, x1 - r, y - r + 1, L.timber.hi)
  local e = c:ellipse(x1 - r + 1, y, r - 1, r) fill(e, L.board.hi) c:edgeIn(e, L.board.shade) px(x1 - r + 1, y, L.board.shade)
  return m
end
local function planks(x0, x1, yb, n)
  for k = 0, n - 1 do
    local y = yb - k * 4
    local m = rect(x0 + (k % 2) * 2, y - 3, x1 - (k % 2) * 3, y)
    rimOf(m, L.timber) part(m, k % 2 == 0 and L.board or L.timber, { nopop = true, noshade = true })
    hline(x0 + (k % 2) * 2, x1 - (k % 2) * 3, y - 3, (k % 2 == 0 and L.board or L.timber).hi)
    fill(rect(x1 - (k % 2) * 3 - 1, y - 3, x1 - (k % 2) * 3, y), L.board.hi)
  end
end
local function wheel(x, y, r, lean)
  local o = c:ellipse(x, y, r * (lean or 1), r)
  local ring = o:copy():cut(c:ellipse(x, y, (r - 2) * (lean or 1), r - 2))
  local sp = HP.mask()
  for k = 0, 5 do local a = k * pi / 3 + .3 sp:add(line({ { x, y }, { x + cos(a) * (r - 1) * (lean or 1), y + sin(a) * (r - 1) } })) end
  rimOf(union(ring, sp), L.timber) part(sp, L.board, { nopop = true, noshade = true }) part(ring, L.timber, { nopop = true })
  ring:each(function(xx, yy) if (xx - x) + (yy - y) < -r then px(xx, yy, IR.hi) end end)
  fill(c:ellipse(x, y, 2, 2), IR.base)
end

---------------------------------------------------------------- road's end: lumber yard + gantry crane
local function crane()
  F.depth(2)
  planks(204, 236, 124, 4)
  log(246, 278, 120, 4) log(250, 282, 112, 4) log(244, 274, 104, 3)
  local legL = line({ { 200, 126 }, { 210, 54 } }, 3):add(line({ { 220, 126 }, { 212, 54 } }, 2))
  local legR = line({ { 284, 126 }, { 274, 54 } }, 3):add(line({ { 264, 126 }, { 272, 54 } }, 2))
  local beam = rect(198, 50, 290, 55)
  local brace = line({ { 213, 70 }, { 228, 56 } }, 2):add(line({ { 271, 70 }, { 256, 56 } }, 2))
  F.shadow(200, 286, 127, 8, 3)
  rimOf(union(legL, legR, beam, brace), L.timber)
  part(legL, L.timber, { nopop = true }) part(legR, L.timber, { nopop = true }) part(brace, L.timber, { nopop = true, noshade = true })
  part(beam, L.timber) hline(198, 290, 50, L.timber.hi)
  -- pulley, rope, hook, slung log
  local pul = c:ellipse(238, 58, 3, 3) rimOf(pul, IR) part(pul, IR)
  vline(238, 61, 78, L.board.deep) vline(240, 58, 76, L.board.deep)
  fill(rect(236, 79, 241, 80), IR.base)
  fill(line({ { 226, 88 }, { 238, 80 }, { 252, 88 } }), L.board.deep)
  log(218, 262, 92, 5)
  -- winch drum at the right leg
  local drum = rect(268, 106, 282, 112) rimOf(drum, L.timber) part(drum, L.board) for x = 270, 280, 2 do vline(x, 106, 112, L.board.deep) end
  fill(rect(282, 104, 288, 105), IR.base) fill(rect(287, 104, 288, 112), IR.base)
  vline(276, 56, 105, L.board.deep)
  -- winch hand turning the crank
  F.gnome(296, 126, { small = true, hat = L.roof, coat = L.leaf, arm = "out", flip = true })
  F.depth(3)
  -- quirk: a robin's nest on the crane beam, three chicks gaping, the robin arriving with a worm
  F.sprite({
    "..y.......y.......y...",
    ".yYy.....yYy.....yYy..",
    "..gg......gg......gg..",
    ".gegg....gegg....gegg.",
    "nnggnnnnnnggnnnnnnggnn",
    "nNnnNnNnnNnnNnNnnNnnNn",
    ".nNnnnNnnnNnnnNnnnNnn.",
    "..nnNnnnNnnnNnnnNnn...",
  }, 262, 42, { y = L.roof.hi, Y = L.produce.shade, g = L.stone.base, e = L.timber.edge, n = L.board.base, N = L.timber.base })
  F.sprite({
    "......bbb.......",
    ".....bbbbb......",
    "....bbebbbkk....",
    "...bbbbbbbk.....",
    "..BBrrrrbb..ww..",
    ".BBrrrrrrb...w..",
    "BBBrrrrrbb...w..",
    "BBBBrrrbbb......",
    "..BB.bbb........",
    ".....o.o........",
  }, 286, 40, { b = L.timber.base, B = L.timber.shade, e = L.timber.edge, k = L.roof.base, r = L.produce.base, w = L.petal and L.petal.base or "#f5809f", o = L.roof.shade })
end
crane()

---------------------------------------------------------------- back-left: plank stacks, timber shed
F.depth(1)
F.tree(84, 130, 40, 4)
F.building{ x0 = 22, x1 = 70, yb = 138, wh = 28, rh = 20, wall = L.board, roof = L.roof2, shingle = true, noAttic = true }
F.door(38, 120, 52, 137, L.timber)
planks(96, 150, 140, 5)
planks(156, 194, 136, 3)

---------------------------------------------------------------- back-right: wagon under construction
local function wagon()
  local bed = poly{ { 300, 128 }, { 352, 128 }, { 350, 136 }, { 302, 136 } }
  local ribs = HP.mask()
  for x = 304, 348, 8 do ribs:add(rect(x, 116, x + 1, 128)) end
  ribs:add(rect(302, 116, 350, 117))
  F.shadow(302, 352, 142, 8, 3)
  rimOf(union(bed, ribs), L.timber)
  part(ribs, L.board, { nopop = true, noshade = true }) part(bed, L.board)
  hline(302, 350, 132, L.board.deep)
  -- trestles in place of wheels
  for _, x in ipairs({ 308, 340 }) do fill(rect(x, 137, x + 2, 142), L.timber.base) fill(rect(x - 2, 142, x + 4, 143), L.timber.deep) end
  wheel(366, 128, 10, .5) wheel(376, 130, 10, .5)
end
wagon()
F.tree(464, 142, 48, 7)

---------------------------------------------------------------- left hero: the forge
F.depth(3)
local function forge()
  -- lean-to roof on posts
  local posts = rect(92, 128, 95, 206):add(rect(186, 140, 189, 208))
  local roofm = poly{ { 84, 128 }, { 196, 140 }, { 196, 146 }, { 84, 134 } }
  -- hearth block with arched mouth
  local hearth = rect(104, 162, 162, 202)
  local hood = poly{ { 108, 140 }, { 158, 140 }, { 162, 162 }, { 104, 162 } }
  local chim = rect(124, 84, 140, 140)
  F.shadow(94, 194, 208, 12, 5)
  rimOf(union(chim, hood, hearth), L.stone)
  part(chim, L.stone) F.courses(chim, 84, 6, 8, L.stone)
  fill(rect(122, 82, 142, 85), L.stone.shade) hline(122, 142, 82, L.stone.hi)
  part(hood, L.stone, { sep = true }) F.courses(hood, 140, 5, 10, L.stone, 2)
  part(hearth, L.stone, { sep = true }) F.courses(hearth, 162, 7, 12, L.stone, 5)
  local mouth = c:rrect(116, 168, 150, 196, 8):clip(rect(116, 168, 150, 190))
  fill(mouth, L.soil.deep)
  local coals = c:ellipse(133, 188, 14, 5):clip(mouth)
  fill(coals, G.shade)
  coals:each(function(x, y) local v = hash(x, y, 4) if v < .3 then px(x, y, G.base) elseif v < .4 then px(x, y, G.hi) elseif v > .85 then px(x, y, G.deep) end end)
  local flame = poly{ { 124, 186 }, { 128, 176 }, { 131, 182 }, { 134, 172 }, { 138, 181 }, { 141, 176 }, { 144, 186 } }
  fill(flame, G.base) fill(poly{ { 129, 186 }, { 134, 177 }, { 139, 186 } }, G.hi)
  hline(112, 154, 196, L.stone.hi) hline(112, 154, 197, L.stone.deep)
  -- glow cast on the ground
  for y = 203, 214 do for x = 112 + (y - 203), 156 - (y - 203) do if hash(x, y, 7) < .35 then px(x, y, L.roof.hi) end end end
  rimOf(union(posts, roofm), L.timber)
  part(posts, L.timber, { nopop = true })
  part(roofm, L.roof2, { sep = true }) F.courses(roofm, 128, 3, 6, L.roof2)
  hline(84, 196, 134, L.roof2.deep)
  -- chimney passes the roof
  part(rect(124, 84, 140, 128):clip(chim), L.stone) F.courses(rect(124, 84, 140, 128), 84, 6, 8, L.stone)
  -- smoke
  F.smoke(132, 78, 9, .7, 3)
  -- horseshoes and tongs on the post
  for k = 0, 2 do local y = 150 + k * 9 local hs = c:ellipse(100, y, 3, 3):cut(c:ellipse(100, y + 1, 1, 2)) fill(hs, IR.base) px(98, y - 2, IR.hi) end
  fill(line({ { 183, 150 }, { 181, 176 } }), IR.shade) fill(line({ { 186, 150 }, { 184, 176 } }), IR.base)
  -- bellows
  local bel = poly{ { 162, 176 }, { 182, 170 }, { 184, 184 }, { 164, 186 } }
  rimOf(bel, L.timber) part(bel, L.soil) bel:each(function(x, y) if (x - 162) % 5 == 0 then px(x, y, L.soil.deep) end end)
  fill(rect(184, 172, 190, 174), L.timber.base)
end
forge()
-- anvil on a stump, quench barrel, blacksmith
local function anvil(x, yb)
  local stump = rect(x - 7, yb - 10, x + 7, yb)
  local body = poly{ { x - 12, yb - 18 }, { x + 9, yb - 18 }, { x + 9, yb - 14 }, { x + 4, yb - 14 }, { x + 5, yb - 11 }, { x - 5, yb - 11 }, { x - 4, yb - 14 }, { x - 8, yb - 14 } }
  F.shadow(x - 8, x + 9, yb, 8, 3)
  rimOf(union(stump, body), L.timber)
  part(stump, L.timber) hline(x - 7, x + 7, yb - 10, L.board.hi) fill(rect(x - 7, yb - 9, x + 7, yb - 9), L.board.shade)
  part(body, IR) hline(x - 11, x + 8, yb - 18, IR.hi)
  -- glowing bar on the anvil + sparks
  fill(rect(x - 6, yb - 20, x + 4, yb - 19), G.base) px(x - 6, yb - 20, G.hi)
  for i = 0, 9 do local sx, sy = x - 10 + floor(hash(i, 1, 21) * 22), yb - 24 - floor(hash(i, 2, 21) * 12) px(sx, sy, i % 2 == 0 and G.hi or G.base) end
end
anvil(168, 232)
local _, hx, hy = F.gnome(148, 238, { hat = L.awnA, coat = L.soil, arm = "up" })
fill(rect(hx, hy - 6, hx + 1, hy + 1), L.board.base) fill(rect(hx - 3, hy - 9, hx + 4, hy - 6), IR.base) px(hx - 3, hy - 9, IR.hi) -- hammer up
-- leather apron
fill(rect(146, 228, 150, 235), L.soil.shade) px(146, 228, L.soil.base)
-- a dog asleep in the forge's warmth
F.sprite({
  ".......ee.....",
  "......eDDd....",
  "..DDDDDDDDdn..",
  ".DdDDDDDDDDd..",
  "DDDDDDDDDDDd..",
  "TDDDdDDDDdd...",
  ".dd..dd..dd...",
}, 104, 212, { e = L.timber.shade, D = L.wood or L.board.base, d = L.board.shade, n = L.timber.edge, T = L.board.hi })
local qb = F.barrel(196, 236, L.timber, 12) fill(rect(192, 223, 200, 224), L.water.base) px(193, 223, L.water.hi)
for k = 0, 2 do px(194 + k * 2, 220 - k, L.stone.hi) end -- steam

---------------------------------------------------------------- right hero: carpenter's barn, open front
local function barn()
  local x0, x1, yb = 296, 446, 208
  local top, cx = F.building{ x0 = x0, x1 = x1, yb = yb, wh = 56, rh = 36, wall = L.board, roof = L.roof, noFrame = true }
  F.planks(rect(x0, top + 4, x1, yb), L.board, 5, false, 31) -- weatherboards with grain
  for x = x0 + 2, x1 - 2, 30 do vline(x, top, yb, L.timber.base) end
  -- big open doorway with interior
  local dx0, dx1, dy0 = 322, 420, 166
  fill(rect(dx0 - 2, dy0 - 2, dx1 + 2, yb), L.timber.base) hline(dx0 - 2, dx1 + 2, dy0 - 2, L.timber.hi)
  fill(rect(dx0, dy0, dx1, yb), L.soil.deep)
  fill(rect(dx0, yb - 6, dx1, yb), L.soil.shade)
  -- tool wall: saw, hammer, square, brace, chisels
  local tw = rect(dx0 + 6, dy0 + 4, dx1 - 6, dy0 + 22) fill(tw, L.soil.base) c:edgeIn(tw, L.timber.deep)
  local saw = poly{ { 334, 174 }, { 352, 172 }, { 352, 178 }, { 334, 178 } } fill(saw, IR.hi) for x = 334, 352, 2 do px(x, 179, IR.base) end
  fill(rect(330, 172, 334, 178), L.board.base) fill(rect(331, 174, 333, 176), L.soil.base)
  fill(rect(360, 172, 361, 186), L.board.base) fill(rect(356, 170, 365, 173), IR.base) px(356, 170, IR.hi)
  fill(rect(372, 172, 373, 186), IR.hi) fill(rect(372, 185, 382, 186), IR.hi)
  fill(line({ { 390, 174 }, { 396, 170 }, { 402, 174 }, { 396, 178 }, { 390, 174 } }), L.board.hi) vline(396, 178, 186, IR.base)
  for k = 0, 3 do local x = 406 + k * 3 vline(x, 176, 182, L.board.base) vline(x, 183, 186, IR.hi) end
  -- workbench with vice and shavings
  local bench = rect(330, 192, 414, 196)
  local legs = rect(334, 197, 337, 208):add(rect(407, 197, 410, 208))
  rimOf(union(bench, legs), L.timber) part(bench, L.board) part(legs, L.timber, { nopop = true, noshade = true })
  local vice = rect(412, 188, 418, 198) rimOf(vice, IR) part(vice, IR, { nopop = true }) fill(rect(418, 192, 422, 193), IR.hi)
  fill(rect(344, 189, 372, 191), L.board.hi) hline(344, 372, 191, L.board.shade) -- plank on the bench
  local plane = poly{ { 376, 186 }, { 388, 186 }, { 390, 191 }, { 374, 191 } } fill(plane, L.timber.base) fill(rect(380, 184, 383, 186), L.awnA.base)
  for k = 0, 6 do local sx = 346 + k * 9 px(sx, 205, L.board.hi) px(sx + 1, 204, L.roof.hi) px(sx + 3, 206, L.board.hi) end
  -- the carpenter planing a board at the bench
  local _, px1, py1 = F.gnome(392, 208, { hat = L.lav, coat = L.awnB, arm = "hold", flip = true, noShadow = true })
  -- hanging lantern inside
  vline(372, 166, 169, L.timber.edge) local ln = rect(370, 170, 374, 174) fill(ln, G.base) px(370, 170, G.hi)
  -- sign: a crossed saw and hammer board above the doorway
  local sb = rect(354, 150, 388, 160) rimOf(sb, L.timber) part(sb, L.board)
  fill(line({ { 360, 158 }, { 380, 152 } }), IR.hi) fill(line({ { 360, 152 }, { 380, 158 } }), L.timber.base) fill(rect(378, 151, 382, 153), IR.base)
end
barn()

---------------------------------------------------------------- foreground: sawhorse with half-sawn plank, grindstone, wheels
local function sawhorse(x0, yb)
  local legs = line({ { x0, yb }, { x0 + 5, yb - 14 }, { x0 + 10, yb } }, 2):add(line({ { x0 + 44, yb }, { x0 + 49, yb - 14 }, { x0 + 54, yb } }, 2))
  local bar = rect(x0 + 2, yb - 16, x0 + 52, yb - 14)
  local plank = poly{ { x0 - 6, yb - 22 }, { x0 + 60, yb - 22 }, { x0 + 62, yb - 17 }, { x0 - 4, yb - 17 } }
  F.shadow(x0, x0 + 56, yb, 8, 3)
  rimOf(union(legs, bar, plank), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true }) part(bar, L.timber, { nopop = true })
  part(plank, L.board) hline(x0 - 6, x0 + 60, yb - 22, L.board.hi)
  -- the saw stuck in the cut, sawdust heap
  vline(x0 + 34, yb - 22, yb - 17, L.soil.deep)
  local saw = poly{ { x0 + 30, yb - 34 }, { x0 + 36, yb - 36 }, { x0 + 37, yb - 22 }, { x0 + 33, yb - 22 } }
  rimOf(saw, IR) part(saw, IR, { nopop = true }) fill(rect(x0 + 28, yb - 40, x0 + 37, yb - 35), L.board.base) fill(rect(x0 + 30, yb - 39, x0 + 34, yb - 37), L.soil.base)
  local dust = poly{ { x0 + 24, yb + 2 }, { x0 + 34, yb - 4 }, { x0 + 44, yb + 2 } } fill(dust, L.roof.hi) dust:each(function(x, y) if hash(x, y, 2) < .3 then px(x, y, L.board.hi) end end)
end
sawhorse(30, 246)
local function grindstone(x, yb)
  local frame = rect(x - 12, yb - 12, x - 10, yb):add(rect(x + 10, yb - 12, x + 12, yb)):add(rect(x - 12, yb - 4, x + 12, yb - 3))
  local stone = c:ellipse(x, yb - 20, 11, 11)
  local trough = rect(x - 9, yb - 8, x + 9, yb - 4)
  F.shadow(x - 12, x + 12, yb, 6, 2)
  rimOf(union(frame, stone, trough), L.timber)
  part(frame, L.timber, { nopop = true, noshade = true })
  part(trough, L.timber) fill(rect(x - 8, yb - 8, x + 8, yb - 7), L.water.base)
  part(stone, L.stone)
  c:ellipse(x, yb - 20, 8, 8):edge():each(function(xx, yy) px(xx, yy, L.stone.shade) end)
  fill(c:ellipse(x, yb - 20, 2, 2), IR.base) px(x - 1, yb - 21, IR.hi)
  fill(rect(x + 2, yb - 21, x + 16, yb - 20), IR.base) fill(rect(x + 15, yb - 21, x + 16, yb - 13), IR.base) fill(rect(x + 15, yb - 14, x + 19, yb - 13), L.board.base)
end
grindstone(440, 236)
wheel(312, 236, 14, .45) wheel(324, 238, 14, .45)
-- barrel hoops and a tool box
for k = 0, 2 do fill(c:ellipse(352, 256 - k * 3, 9, 3):cut(c:ellipse(352, 256 - k * 3, 7, 2)), k % 2 == 0 and IR.base or IR.shade) end
local tb = rect(286, 250, 306, 260) rimOf(tb, L.timber) part(tb, L.awnA) hline(286, 306, 253, L.awnA.deep)
fill(rect(294, 245, 298, 246), IR.base) vline(294, 246, 249, IR.base) vline(298, 246, 249, IR.base)
-- log pile, left middle
local pile = HP.mask()
for row = 0, 3 do for k = 0, 4 - row do pile:add(c:ellipse(30 + k * 10 + row * 5, 198 - row * 8, 5, 4)) end end
F.shadow(26, 80, 204, 8, 3)
rimOf(pile, L.timber)
for row = 0, 3 do for k = 0, 4 - row do
  local x, y = 30 + k * 10 + row * 5, 198 - row * 8
  local e = c:ellipse(x, y, 5, 4) fill(e, L.board.hi) c:edgeIn(e, L.timber.base)
  c:ellipse(x, y, 2, 2):edge():each(function(xx, yy) px(xx, yy, L.board.shade) end) px(x, y, L.board.deep)
end end
F.barrel(84, 202, L.timber, 11)
local _, sx1, sy1 = F.gnome(104, 256, { hat = L.leaf, coat = L.accent, arm = "up", flip = true })
fill(line({ { sx1, sy1 }, { 98, 214 } }), L.board.base) -- reaching for the stuck saw's handle
-- a gnome carrying a long plank on the shoulder past the barn
local _, cx1, cy1 = F.gnome(276, 214, { hat = L.produce, coat = L.wall2, arm = "up" })
local pl = poly{ { cx1 - 26, cy1 - 1 }, { cx1 + 14, cy1 - 5 }, { cx1 + 14, cy1 - 2 }, { cx1 - 26, cy1 + 2 } }
rimOf(pl, L.timber) part(pl, L.board, { nopop = true }) line({ { cx1 - 25, cy1 - 1 }, { cx1 + 13, cy1 - 5 } }):each(function(x, y) px(x, y, L.board.hi) end)
F.depth(0)
F.birds({ { 330, 34, 2 }, { 344, 40, 1 }, { 180, 44, 2 }, { 168, 50, 1 } })
-- chopping block with axe by the road (left)
log(178, 198, 256, 6)
local axe = line({ { 186, 248 }, { 196, 236 } }, 2) rimOf(axe, L.timber) fill(axe, L.board.base)
fill(poly{ { 193, 234 }, { 200, 230 }, { 201, 238 } }, IR.hi) px(200, 237, IR.shade)
F.finish()
