-- workshop.lua : "Workshop" stop look, TUNDRA (tundra_frost), 480x270 gate view.
-- Same composition as the Maplewold workshop (art-2701-batch3/stops/opus3/workshop.lua), re-cast as a
-- sled-maker's and ski-wright's yard on the tundra:
-- road's end: the driftwood gantry crane hoisting a long freight sled over a yard of ski blanks and snowy birch
-- logs, between two spruces. Back left: a falu-red sod-roofed cottage with peat smoke, a long rack of ski blanks
-- drying, runner blanks under snow. Back right: a sled frame on trestles, two sled dogs curled in the snow.
-- Left hero: a cast-iron stove under a sod lean-to with a tall stovepipe, a copper boiler on top where birch
-- runners steam; a gnome pressing a steamed runner round a bending form; a husky asleep in the warmth.
-- Right hero: the ochre ski-wright's workshop with an open front: painted skis standing in a rack, a ski on the
-- bench being planed, tool wall, snowshoes on the outside wall, the ski-wright at work.
-- Foreground: a new sled on trestles being lashed, a tar pot steaming on a brazier, upright skis in a rack,
-- snowshoes in a snowbank, rawhide coils, a red toolbox, a red kicksled, a gnome carrying skis on the road.
-- Quirk: an ermine in a red gnome hat has made a nest of curled ski shavings on the crane beam, two kits peeking.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-tundra-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "workshop", out = DIR, farTrees = { 24, 52, 160, 300, 330, 440 },
  treeLineGap = { 196, 292 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local IR, G, S = L.iron, L.glow, L.snow
local OCHRE = F.rp("#f2d68e #dcae5c #b08442 #805e36 #4e3a2c")   -- ochre-painted weatherboards
local COPPER = F.rp("#f6be92 #da8a5c #ae6242 #7c4234 #4a2828")  -- the runner boiler
local TAR = F.rp("#8a7a72 #5e5052 #463c42 #322a34 #22202c")     -- pine tar, tarred wood
local RAW = F.rp("#f0dcb4 #d2b484 #aa8c62 #7c664c #4c3e36")     -- rawhide lashing
local SKI = { L.wall2, L.accent, L.board, OCHRE, L.leaf, L.awnA }

---------------------------------------------------------------- local helpers
local function log(x0, x1, y, r, snow)
  local m = c:rrect(x0, y - r, x1, y + r, r)
  rimOf(m, L.timber) part(m, L.timber, { nopop = true })
  m:each(function(x, yy) if hash(x // 3, yy, 17) < .16 then px(x, yy, L.timber.shade) end end)
  hline(x0 + r, x1 - r, y - r + 1, L.timber.hi)
  F.logEnd(x1 - r + 1, y, r, L.birch)
  if snow then F.snowCap(m, snow, x0 + y) end
  return m
end
-- curled shavings in pale birch
local function shavings(x0, x1, y0, y1, n, seed)
  for i = 1, n do
    local x, y = x0 + floor(hash(i, 1, seed) * (x1 - x0)), y0 + floor(hash(i, 2, seed) * (y1 - y0))
    local d = hash(i, 3, seed) < .5 and 1 or -1
    px(x, y, L.board.hi) px(x + d, y, L.board.base) px(x + d, y - 1, L.board.hi)
    if hash(i, 4, seed) < .5 then px(x, y + 1, L.board.shade) end
  end
end
-- a ski standing (bottom xb,yb -> top xt,yt), 2 px wide, curled tip hooking left, painted ramp r
local function ski(xb, yb, xt, yt, r, snowTip)
  local m = line({ { xb, yb }, { xt, yt } }, 2)
  local tip = line({ { xt, yt }, { xt - 1, yt - 2 }, { xt - 3, yt - 3 } }, 1)
  rimOf(union(m, tip), L.timber)
  m:each(function(x, y) px(x, y, m:has(x - 1, y) and r.shade or r.base) end)
  tip:each(function(x, y) px(x, y, r.hi) end)
  -- binding strap and a dark groove
  local my = floor(yb + (yt - yb) * .45)
  local mx = floor(xb + (xt - xb) * .45)
  px(mx, my, L.timber.edge) px(mx + 1, my, L.timber.deep) px(mx, my + 1, RAW.base) px(mx + 1, my + 1, RAW.shade)
  if snowTip then px(xt - 3, yt - 4, S.hi) px(xt - 2, yt - 4, S.base) end
  return m
end
-- a snowshoe frame: teardrop of bent birch, rawhide lacing, a tail. (cx, cy = centre of the oval)
local function snowshoe(cx, cy, w, h, upTail)
  local o = c:ellipse(cx, cy, w, h)
  local tail = upTail and line({ { cx, cy - h }, { cx, cy - h - 4 } }, 1) or line({ { cx, cy + h }, { cx, cy + h + 4 } }, 1)
  local frame = o:copy():cut(c:ellipse(cx, cy, w - 1, h - 1)):add(tail)
  c:rim(union(o, tail), L.timber.edge)
  local inner = c:ellipse(cx, cy, w - 1, h - 1)
  inner:each(function(x, y)
    local k = ((x - cx + 40) + (y - cy + 40)) % 3 == 0 or ((x - cx + 40) - (y - cy + 40)) % 3 == 0
    px(x, y, k and RAW.base or L.soil.deep)
  end)
  hline(cx - w + 1, cx + w - 1, cy - 1, RAW.shade) hline(cx - w + 1, cx + w - 1, cy + 2, RAW.deep) -- toe bars
  frame:each(function(x, y) px(x, y, (x < cx or y < cy - h + 2) and L.board.hi or L.board.shade) end)
  return o
end
-- a long sled seen from the side: runners with a curled nose at the right, stanchions, bed rails, slats,
-- rawhide lashing. Returns the silhouette.
local function sled(x0, x1, yb, bedR, o)
  o = o or {}
  local run = line({ { x0, yb }, { x1 - 4, yb }, { x1, yb - 2 }, { x1 + 2, yb - 6 }, { x1 + 1, yb - 9 } }, 2)
  local bed = rect(x0 + 2, yb - 8, x1 - 4, yb - 6)
  local st = HP.mask()
  for x = x0 + 4, x1 - 6, 9 do st:add(rect(x, yb - 5, x + 1, yb - 1)) end
  local rail = line({ { x0 + 1, yb - 11 }, { x0 + 1, yb - 8 } }, 1) -- a little back stake
  local sil = union(run, bed, st, rail)
  rimOf(sil, L.timber)
  part(run, o.runR or L.board, { nopop = true, noshade = true })
  run:each(function(x, y) if not run:has(x, y - 1) then px(x, y, (o.runR or L.board).hi) end end)
  part(st, L.timber, { nopop = true, noshade = true })
  part(bed, bedR or L.board, { nopop = true }) hline(x0 + 2, x1 - 4, yb - 8, (bedR or L.board).hi)
  for x = x0 + 5, x1 - 6, 4 do px(x, yb - 7, (bedR or L.board).deep) end
  part(rail, L.timber, { nopop = true, noshade = true })
  -- rawhide lashing: X between each stanchion and the bed
  for x = x0 + 4, x1 - 6, 9 do px(x - 1, yb - 5, RAW.hi) px(x + 2, yb - 4, RAW.base) px(x + 2, yb - 5, RAW.shade) end
  return sil
end

---------------------------------------------------------------- far right: open tundra beyond the workshop
F.depth(1)
for _, w in ipairs({ { 462, 128, 5, 4 }, { 300, 146, 5, 4 } }) do F.willow(w[1], w[2], w[3], w[4], w[1]) end
F.drift(470, 140, 14, 4, 5)

---------------------------------------------------------------- road's end: ski-blank yard + gantry crane lifting a sled
F.depth(2)
F.tree(188, 128, 56, 2)
F.tree(300, 130, 50, 1)
local function crane()
  -- yard: stacked ski blanks (left), snowy birch logs (right)
  for k = 0, 3 do
    local y = 124 - k * 3
    local m = rect(204 + (k % 2) * 2, y - 2, 236 - (k % 2) * 3, y)
    rimOf(m, L.timber) part(m, L.board, { nopop = true, noshade = true }) hline(204 + (k % 2) * 2, 236 - (k % 2) * 3, y - 2, L.board.hi)
    px(236 - (k % 2) * 3, y - 2, L.board.hi) px(235 - (k % 2) * 3, y - 3, L.board.base) -- the curled tips
  end
  hline(206, 233, 111, S.hi) hline(207, 232, 112, S.base)
  log(246, 278, 120, 4) log(250, 282, 112, 4) log(244, 274, 104, 3, 2)
  local legL = line({ { 200, 126 }, { 210, 54 } }, 3):add(line({ { 220, 126 }, { 212, 54 } }, 2))
  local legR = line({ { 284, 126 }, { 274, 54 } }, 3):add(line({ { 264, 126 }, { 272, 54 } }, 2))
  local beam = rect(198, 50, 290, 55)
  local brace = line({ { 213, 70 }, { 228, 56 } }, 2):add(line({ { 271, 70 }, { 256, 56 } }, 2))
  F.shadow(200, 286, 127, 6, 3)
  rimOf(union(legL, legR, beam, brace), L.timber)
  part(legL, L.timber, { nopop = true }) part(legR, L.timber, { nopop = true }) part(brace, L.timber, { nopop = true, noshade = true })
  part(beam, L.timber) hline(198, 290, 50, L.timber.hi)
  -- driftwood grain on legs and beam
  union(legL, legR, beam):each(function(x, y) if hash(x // 2, y // 4, 30) < .14 then px(x, y, L.timber.shade) elseif hash(x, y, 31) < .03 then px(x, y, L.timber.hi) end end)
  F.snowCap(beam, 2, 33, { cx = 236 })
  F.icicles(199, 289, 56, 3, 34, .3)
  -- snow drifted against the leg feet
  F.drift(214, 127, 10, 3, 35) F.drift(276, 127, 9, 3, 36)
  -- pulley, rope, hook, a sling holding the freight sled
  local pul = c:ellipse(238, 58, 3, 3) rimOf(pul, IR) part(pul, IR)
  vline(238, 61, 76, L.board.deep) vline(240, 58, 74, L.board.deep)
  fill(rect(236, 77, 241, 78), IR.base) px(236, 77, IR.hi)
  line({ { 222, 86 }, { 238, 78 } }):each(function(x, y) px(x, y, L.board.deep) end)
  line({ { 254, 86 }, { 239, 78 } }):each(function(x, y) px(x, y, L.board.deep) end)
  sled(214, 258, 96, L.wall2)
  F.steam(262, 84, 3, .4, 37) -- the fresh-bent nose still steaming
  -- winch drum at the right leg
  local drum = rect(268, 106, 282, 112) rimOf(drum, L.timber) part(drum, L.board) for x = 270, 280, 2 do vline(x, 106, 112, L.board.deep) end
  hline(268, 282, 105, S.hi)
  fill(rect(282, 104, 288, 105), IR.base) fill(rect(287, 104, 288, 112), IR.base)
  vline(276, 56, 105, L.board.deep)
  F.gnome(296, 126, { small = true, hat = L.roof2, coat = L.leaf, arm = "out", flip = true })
  F.depth(3)
  -- quirk: a nest of curled ski shavings on the beam, an ermine in a red gnome hat, two kits peeking out
  F.sprite({
    "...............RR.......",
    "..............RRr.......",
    ".............RRRr.......",
    "............RRRRRr......",
    "...........RRRRRRr......",
    "..........hhhhhhhhh.....",
    "..........WWWWWWWWw.....",
    "..........WKWWWWKWw.....",
    "..ww..ww..WWWWpWWWw.....",
    ".wKWw.wKWw.WWWWWWw......",
    ".WWpW.WWpW..WWWWWw...KK.",
    "nNWWWnWWWWnNWWWWWWwnnKKn",
    "nNnnNnNnnNnnNnNnnNnnNnnN",
    ".nNnnnNnnnNnnnNnnnNnnnn.",
    "..nnNnnnNnnnNnnnNnnnNn..",
  }, 260, 35, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, W = L.fur.hi, w = L.fur.shade, K = L.timber.edge,
    p = L.petal.base, n = L.board.hi, N = L.board.shade })
  px(273, 37, L.awnA.hi) px(272, 38, L.awnA.hi) px(271, 39, L.awnA.hi) -- hat lit side
end
crane()

---------------------------------------------------------------- back-left: falu-red cottage, ski-blank drying rack
F.depth(1)
F.tree(84, 130, 42, 2)
F.tree(10, 134, 38, 1)
local ctop, ccx, cwall = F.building{ x0 = 22, x1 = 70, yb = 138, wh = 28, rh = 20, wall = L.wall2, roof = L.roof, chimney = true, noAttic = true, noFrame = true, snow = 3 }
F.planks(cwall, L.wall2, 4, true, 3)
part(union(rect(22, ctop, 23, 137), rect(69, ctop, 70, 137)), L.plaster, { nopop = true, noshade = true })
F.door(38, 122, 47, 137, L.timber)
F.window(55, 119, 61, 125, L.plaster)
F.window(27, 119, 32, 125, L.plaster)
F.smoke(60, 92, 6, .6, 2)
F.drift(20, 139, 8, 3, 6)
-- a long rack of ski blanks leaning to dry
F.shadow(96, 152, 141, 5, 2)
local rackBar = rect(96, 120, 152, 121)
local rackPosts = rect(98, 120, 99, 140):add(rect(149, 120, 150, 140))
rimOf(union(rackBar, rackPosts), L.timber) part(union(rackBar, rackPosts), L.timber, { nopop = true, noshade = true })
for k = 0, 9 do
  local x = 102 + k * 5
  local r = (k % 3 == 0) and L.board or L.timber
  local m = line({ { x + 2, 140 }, { x, 116 } }, 2)
  rimOf(m, L.timber) m:each(function(xx, yy) px(xx, yy, m:has(xx - 1, yy) and r.shade or r.hi) end)
  px(x - 1, 115, r.hi) px(x, 115, S.hi)
end
hline(96, 152, 119, S.hi)
F.drift(124, 141, 30, 3, 8)
-- runner blanks stacked under a crust of snow
for k = 0, 2 do
  local y = 138 - k * 3
  local m = rect(158 + k * 2, y - 2, 194 - k * 2, y)
  rimOf(m, L.timber) part(m, L.board, { nopop = true, noshade = true })
  F.logEnd(194 - k * 2, y - 1, 1, L.birch)
end
F.snowCap(rect(162, 130, 190, 134), 2, 9)

---------------------------------------------------------------- back-right: a sled frame on trestles, sled dogs
local function sledFrame()
  F.shadow(302, 352, 142, 6, 2)
  sled(302, 346, 134, L.board, { runR = L.birch })
  for _, x in ipairs({ 310, 336 }) do
    local t = line({ { x - 3, 142 }, { x, 135 }, { x + 3, 142 } }, 1)
    rimOf(t, L.timber) part(t, L.timber, { nopop = true, noshade = true })
  end
  F.snowCap(rect(304, 126, 342, 128), 1, 12)
end
sledFrame()
local function sleepDog(x, y, flip)
  local rows = {
    "...ee.......",
    "..eGGg......",
    ".GGKGGGGGg..",
    "GwwGGGGGGGgT",
    "wwwwGGGGGgTT",
    ".wwwwwwwwTT.",
  }
  if flip then for i, r in ipairs(rows) do rows[i] = r:reverse() end end
  F.sprite(rows, x, y, { e = L.stone.deep, G = L.stone.base, g = L.stone.shade, K = L.timber.edge, w = L.fur.base, T = L.fur.shade })
end
F.depth(2)
F.tree(452, 142, 56, 6)
F.tree(436, 136, 40, 5)

---------------------------------------------------------------- left hero: the iron stove and the runner boiler under a sod lean-to
F.depth(3)
local function stove()
  local posts = rect(92, 128, 95, 206):add(rect(186, 140, 189, 208))
  local roofm = poly{ { 84, 126 }, { 196, 138 }, { 196, 146 }, { 84, 134 } }
  local plinth = rect(104, 190, 164, 202)
  local body = c:rrect(110, 168, 158, 192, 3)
  local legs = rect(112, 192, 115, 194):add(rect(153, 192, 156, 194))
  local pipe = rect(129, 80, 135, 150)
  local capm = poly{ { 125, 80 }, { 132, 72 }, { 139, 80 } }
  F.shadow(94, 194, 208, 10, 5)
  rimOf(union(plinth), L.stone)
  part(plinth, L.stone, { sep = true }) F.rubble(plinth, L.stone, 190, 4, 3)
  rimOf(union(body, legs, pipe, capm), IR)
  part(pipe, IR, { nopop = true })
  pipe:each(function(x, y) if x == 130 then px(x, y, IR.hi) elseif x == 134 then px(x, y, IR.deep) end if (y - 80) % 14 == 0 then px(x, y, IR.deep) end end)
  part(capm, IR, { nopop = true }) F.snowCap(capm, 2, 4, { cx = 132 })
  -- guy wire from the pipe to the roof
  line({ { 131, 96 }, { 108, 128 } }):each(function(x, y) px(x, y, IR.deep) end)
  part(legs, IR, { nopop = true, noshade = true })
  part(body, IR)
  -- cast relief: a top lip, corner rosettes, a star in a ring on the side
  hline(110, 158, 171, IR.deep) hline(111, 157, 170, IR.hi)
  for _, p in ipairs({ { 114, 175 }, { 154, 175 }, { 114, 188 }, { 154, 188 } }) do px(p[1], p[2], IR.hi) px(p[1] + 1, p[2] + 1, IR.deep) end
  -- the firebox door with a glowing grille
  local door = rect(121, 175, 147, 189)
  fill(door, IR.deep)
  local glow = rect(123, 177, 145, 187)
  fill(glow, G.shade)
  glow:each(function(x, y)
    local v = hash(x, y, 4)
    if (x - 123) % 4 == 3 then px(x, y, IR.edge)
    elseif v < .35 then px(x, y, G.base) elseif v < .48 then px(x, y, G.hi) elseif v > .88 then px(x, y, G.deep) end
  end)
  fill(poly{ { 127, 187 }, { 131, 180 }, { 134, 184 }, { 137, 178 }, { 141, 187 } }, G.hi)
  for x = 123, 145, 4 do vline(x + 3, 177, 187, IR.edge) end
  hline(121, 147, 175, IR.base) px(146, 182, G.hi) px(147, 182, L.gold.base) -- latch
  -- warm light thrown on the snow in front
  for y = 203, 216 do for x = 114 + (y - 203), 154 - (y - 203) do if hash(x, y, 7) < .33 then px(x, y, y < 209 and "#f4dcb4" or "#ead8c4") end end end
  -- copper boiler on the stove top; two birch runners poking out of its far end, steaming
  local runA = line({ { 150, 158 }, { 182, 156 }, { 186, 152 } }, 2)
  local runB = line({ { 150, 162 }, { 178, 162 }, { 183, 159 } }, 2)
  rimOf(union(runA, runB), L.timber)
  part(runA, L.birch, { nopop = true, noshade = true }) part(runB, L.birch, { nopop = true, noshade = true })
  union(runA, runB):each(function(x, y) if hash(x // 3, y, 8) < .2 then px(x, y, L.birch.edge) end end)
  local boil = c:rrect(100, 152, 160, 168, 7)
  rimOf(boil, COPPER) part(boil, COPPER)
  boil:each(function(x, y) if y < 156 and x < 140 then px(x, y, COPPER.hi) elseif y > 165 then px(x, y, COPPER.deep) end end)
  for x = 106, 156, 6 do px(x, 154, COPPER.deep) px(x, 166, COPPER.edge) end -- rivets
  hline(104, 156, 160, COPPER.shade)
  vline(118, 153, 167, COPPER.shade) vline(142, 153, 167, COPPER.shade) -- straps
  F.snowCap(c:rrect(100, 152, 160, 154, 1), 1, 10) -- rime where the steam freezes back
  -- a stopper and a brass gauge
  fill(rect(96, 157, 99, 163), L.board.base) px(96, 157, L.board.hi)
  local gauge = c:ellipse(124, 150, 2, 2) c:rim(gauge, IR.edge) fill(gauge, L.gold.hi) px(125, 150, IR.edge)
  -- posts and sod roof, the pipe through it
  rimOf(union(posts, roofm), L.timber)
  part(posts, L.timber, { nopop = true })
  part(roofm, L.roof, { sep = true }) F.sod(roofm, L.roof, 126, 140)
  F.snowCap(roofm, 3, 11, { cx = 150, lip = true })
  F.icicles(85, 195, 135, 5, 12, .4)
  part(rect(129, 80, 135, 148), IR, { nopop = true })
  vline(130, 80, 146, IR.hi) vline(134, 80, 146, IR.deep)
  hline(127, 137, 132, IR.shade) -- a collar where the pipe passes the roof
  F.smoke(132, 66, 8, .7, 2)
  F.steam(102, 150, 6, -.4, 13) F.steam(184, 150, 7, .5, 14) F.steam(150, 148, 4, .3, 15)
  -- snowshoe frames and runner blanks hanging on the left post
  snowshoe(100, 146, 3, 7)
  snowshoe(100, 166, 3, 7)
  -- a coil of rawhide on the right post
  local coil = c:ellipse(181, 176, 4, 5):cut(c:ellipse(181, 176, 2, 3))
  c:rim(coil, L.timber.edge) fill(coil, RAW.base) coil:each(function(x, y) if x < 181 then px(x, y, RAW.hi) elseif y > 178 then px(x, y, RAW.shade) end end)
  -- peat / birch firewood stacked by the stove
  F.shadow(166, 186, 203, 3, 2)
  for k = 0, 3 do F.logEnd(167 + k * 6, 199, 3, L.birch) end
  for k = 0, 2 do F.logEnd(170 + k * 6, 193, 3, L.birch) end
  F.logEnd(173, 187, 3, L.birch) F.logEnd(179, 187, 3, L.redbark)
  hline(170, 182, 183, S.hi)
end
stove()
-- the bending form: a steamed runner pressed round a curved block, clamped, its nose curling up
local function bender()
  F.shadow(156, 190, 232, 6, 3)
  local block = rect(158, 222, 190, 232)
  local form = c:ellipse(168, 213, 8, 8):clip(rect(160, 213, 168, 221))
  local runner = HP.mask()
  for a = 0, 18 do
    local t = a / 18 * pi / 2
    runner:set(floor(168 - sin(t) * 9 + .5), floor(213 + cos(t) * 9 + .5))
    runner:set(floor(168 - sin(t) * 10 + .5), floor(213 + cos(t) * 10 + .5))
  end
  runner:add(rect(168, 221, 190, 222)):add(rect(158, 207, 159, 213))
  rimOf(union(block, form, runner), L.timber)
  part(block, L.timber) F.planks(block, L.timber, 4, false, 16)
  part(form, L.board, { nopop = true })
  runner:each(function(x, y) px(x, y, (runner:has(x, y - 1) and runner:has(x - 1, y)) and L.birch.shade or L.birch.hi) end)
  -- C-clamp at the bend
  fill(rect(173, 218, 175, 225), IR.base) px(173, 218, IR.hi) fill(rect(172, 217, 176, 217), IR.shade) fill(rect(172, 226, 176, 226), IR.deep)
  F.snowCap(rect(178, 221, 190, 223), 1, 17)
  F.steam(162, 204, 5, .4, 18) F.steam(180, 218, 3, .6, 19)
end
bender()
local _, hx, hy = F.gnome(148, 238, { hat = L.awnA, coat = L.wall2, arm = "up" })
fill(rect(hx - 1, hy - 1, hx + 1, hy), L.skin.base) -- mitt pressed on the runner
fill(rect(146, 228, 150, 235), L.soil.shade) px(146, 228, L.soil.base) -- leather apron
-- a husky asleep in the stove's warmth: grey saddle, white face and belly, dark mask, tail curled over its nose
F.sprite({
  ".............ee.e...",
  "............eGGGe...",
  ".....GGGGGG.GKwKGG..",
  "..TGGGGGGGGGGwwwwGn.",
  ".TTGGgGGGGGGGGwwwwn.",
  "TTwGGGgGGGgGGGGww...",
  "TwwwGGGGGGGGGGwww...",
  ".wwwwwwwwwwwwwww....",
}, 100, 210, { e = L.stone.deep, G = L.stone.base, g = L.stone.shade, K = L.timber.edge, w = L.fur.hi, T = L.fur.shade, n = L.timber.edge })
-- water barrel with an ice skin, a birch ladle
local qb = F.barrel(198, 236, L.timber, 12)
fill(rect(194, 225, 202, 226), L.ice.hi) px(195, 225, L.ice.base) px(200, 226, L.ice.shade)
F.icicles(193, 203, 228, 3, 20, .35)
fill(rect(201, 222, 204, 223), L.birch.base) vline(204, 219, 222, L.birch.shade)

---------------------------------------------------------------- right hero: the ochre ski-wright's workshop, open front
local function workshop()
  local x0, x1, yb = 296, 446, 208
  local top, cx, wallM, roofM = F.building{ x0 = x0, x1 = x1, yb = yb, wh = 56, rh = 36, wall = OCHRE, roof = L.roof, noFrame = true, snow = 3, icicles = 6 }
  F.planks(rect(x0, top + 4, x1, yb), OCHRE, 5, false, 31)
  local gab = poly{ { x0 + 5, top }, { cx, top - 36 + 8 }, { x1 - 5, top } }:cut(roofM)
  F.planks(gab, OCHRE, 4, true, 32)
  -- white Nordic trim: corner boards, a sill board, barge boards
  part(union(rect(x0, top, x0 + 2, yb), rect(x1 - 2, top, x1, yb)), L.plaster, { nopop = true, noshade = true })
  F.window(cx - 3, top - 36 // 2 + 1, cx + 2, top - 36 // 2 + 5, L.plaster)
  -- weathering: damp darker boards at the foot, snow splash
  wallM:each(function(x, y) if y > yb - 5 and hash(x, y // 2, 39) < .5 then px(x, y, hash(x, y, 40) < .5 and S.base or OCHRE.shade) end end)
  -- window, left of the doorway, snow on its sill
  F.window(303, 174, 313, 183, L.plaster)
  hline(301, 315, 186, S.hi) hline(302, 314, 185, S.base)
  -- big open doorway with the interior
  local dx0, dx1, dy0 = 322, 420, 166
  local fr = rect(dx0 - 3, dy0 - 3, dx1 + 3, yb)
  fill(fr, L.plaster.base) hline(dx0 - 3, dx1 + 3, dy0 - 3, L.plaster.hi) hline(dx0 - 3, dx1 + 3, dy0 - 1, L.plaster.deep)
  vline(dx0 - 3, dy0 - 3, yb, L.plaster.hi) vline(dx1 + 3, dy0 - 3, yb, L.plaster.shade)
  fill(rect(dx0, dy0, dx1, yb), L.soil.deep)
  fill(rect(dx0, yb - 6, dx1, yb), L.soil.shade)
  for x = dx0 + 4, dx1, 8 do vline(x, dy0, yb - 7, L.soil.edge) end
  -- warm lamp wash on the back wall around the lantern
  rect(dx0, dy0, dx1, yb - 7):each(function(x, y) local d = ((x - 372) / 30) ^ 2 + ((y - 172) / 14) ^ 2 if d < 1 and hash(x, y, 41) < .45 - d * .35 then px(x, y, L.soil.shade) end end)
  -- the ski rack (left of the bench): painted skis standing, tips curled, poles with baskets
  hline(dx0 + 2, dx0 + 44, dy0 + 5, L.timber.base) hline(dx0 + 2, dx0 + 44, dy0 + 6, L.timber.deep)
  for k = 0, 7 do
    local x = dx0 + 5 + k * 5
    ski(x + 1, yb - 7, x, dy0 + 5, SKI[k % #SKI + 1])
  end
  for k = 0, 1 do -- poles with ring baskets
    local x = dx0 + 47 + k * 4
    vline(x, dy0 + 2, yb - 8, L.board.base) px(x, dy0 + 2, L.board.hi)
    local b = c:ellipse(x, yb - 12, 2, 1):cut(rect(x, yb - 12, x, yb - 12)) fill(b, RAW.shade)
  end
  -- tool wall (right): drawknife, spokeshaves, a plane, a mallet, a bow saw, an auger
  local tw2 = rect(dx0 + 54, dy0 + 3, dx1 - 6, dy0 + 22) fill(tw2, L.soil.base) c:edgeIn(tw2, L.timber.deep)
  hline(378, 390, 172, IR.hi) hline(378, 390, 173, IR.shade) vline(377, 172, 176, L.board.base) vline(391, 172, 176, L.board.base) -- drawknife
  for k = 0, 1 do local y = 178 + k * 4 hline(378, 388, y, L.board.base) hline(381, 385, y + 1, IR.hi) px(378, y, L.board.hi) end -- spokeshaves
  local bow = line({ { 395, 171 }, { 395, 185 } }):add(line({ { 408, 171 }, { 408, 185 } })):add(line({ { 395, 178 }, { 408, 178 } }))
  fill(bow, L.board.base) hline(395, 408, 185, IR.hi) for x = 396, 407, 2 do px(x, 186, IR.base) end
  fill(rect(410, 171, 413, 175), L.board.shade) vline(412, 176, 185, L.board.base) px(410, 171, L.board.hi) -- mallet
  vline(416, 171, 186, IR.base) hline(414, 418, 171, L.board.base) px(416, 186, IR.hi) -- auger
  -- workbench: a ski being planed, its tip held up in a bending press, shavings
  local bench = rect(330, 192, 414, 196)
  local legs = rect(334, 197, 337, 208):add(rect(407, 197, 410, 208))
  rimOf(union(bench, legs), L.timber) part(bench, L.board) F.planks(bench, L.board, 3, false, 42) part(legs, L.timber, { nopop = true, noshade = true })
  local vice = rect(412, 188, 418, 198) rimOf(vice, L.timber) part(vice, L.timber, { nopop = true }) fill(rect(418, 192, 422, 193), L.board.hi)
  local sk = line({ { 344, 190 }, { 398, 190 }, { 402, 188 }, { 404, 185 } }, 2)
  rimOf(sk, L.timber) sk:each(function(x, y) px(x, y, sk:has(x, y - 1) and L.board.base or L.board.hi) end)
  -- press: two blocks and a wedge holding the tip
  fill(rect(400, 182, 402, 184), L.timber.base) fill(rect(405, 186, 407, 191), L.timber.base) px(405, 186, L.timber.hi)
  local plane = poly{ { 352, 185 }, { 364, 185 }, { 366, 189 }, { 350, 189 } } fill(plane, L.timber.base) fill(rect(356, 183, 359, 185), L.awnA.base) hline(350, 366, 189, L.timber.deep)
  shavings(338, 412, 199, 207, 30, 43)
  shavings(366, 390, 187, 189, 6, 44)
  -- a tar pot on a little stove inside, steaming
  fill(rect(326, 200, 334, 207), IR.deep) fill(rect(328, 202, 332, 205), G.base) px(328, 202, G.hi)
  fill(rect(325, 196, 335, 199), TAR.base) hline(325, 335, 196, TAR.hi)
  -- the ski-wright planing at the bench
  F.gnome(392, 208, { hat = L.lav, coat = L.accent, arm = "hold", flip = true, noShadow = true })
  -- hanging lantern inside
  vline(372, 166, 169, L.timber.edge) local ln = rect(370, 170, 374, 174) rimOf(ln, IR) fill(ln, G.base) px(370, 170, G.hi) px(374, 174, G.shade)
  -- sign above the doorway: crossed skis and a sled nose, painted on a white board
  local sb = rect(352, 147, 390, 159) rimOf(sb, L.timber) part(sb, L.plaster) F.planks(sb, L.plaster, 4, false, 45)
  line({ { 360, 157 }, { 381, 149 } }, 1):each(function(x, y) px(x, y, L.wall2.base) px(x, y + 1, L.wall2.shade) end)
  line({ { 360, 149 }, { 381, 157 } }, 1):each(function(x, y) px(x, y, L.accent.base) px(x, y + 1, L.accent.shade) end)
  px(359, 148, L.wall2.hi) px(359, 156, L.accent.hi)
  hline(352, 390, 146, S.hi) hline(353, 389, 145, S.base)
  -- snowshoes hanging on the outside wall right of the doorway
  hline(424, 444, 168, L.timber.deep) hline(424, 444, 167, L.timber.hi)
  snowshoe(429, 178, 4, 8) snowshoe(439, 180, 4, 8)
  snowshoe(434, 197, 3, 5, true)
  -- drifts against the walls
  F.drift(300, 209, 10, 4, 46) F.drift(440, 209, 12, 5, 47)
end
workshop()

---------------------------------------------------------------- left middle: painted skis leaning on an A-frame rack, a tar barrel
F.shadow(24, 82, 204, 6, 3)
local aPosts = line({ { 24, 204 }, { 28, 174 } }, 2):add(line({ { 80, 204 }, { 76, 174 } }, 2))
local aBar = rect(24, 173, 80, 175)
rimOf(union(aPosts, aBar), L.timber) part(union(aPosts, aBar), L.timber, { nopop = true, noshade = true })
for k = 0, 9 do
  local x = 30 + k * 5
  ski(x + 3, 203, x, 168, SKI[(k + 2) % #SKI + 1], k % 2 == 0)
end
hline(24, 80, 172, S.hi) hline(26, 78, 173, S.base)
F.drift(52, 205, 32, 3, 21)
local tarB = F.barrel(86, 204, TAR, 12)
fill(rect(82, 192, 90, 193), TAR.deep) px(83, 192, TAR.hi)
vline(90, 194, 199, TAR.deep) px(90, 200, TAR.edge) -- a tar drip
F.snowCap(rect(81, 192, 91, 194), 1, 22)

---------------------------------------------------------------- foreground left: a new sled on trestles being lashed, the tar pot
F.depth(3)
F.shadow(24, 98, 246, 8, 3)
for _, x in ipairs({ 34, 78 }) do
  local t = line({ { x - 6, 246 }, { x, 236 }, { x + 6, 246 } }, 2):add(rect(x - 6, 235, x + 6, 236))
  rimOf(t, L.timber) part(t, L.timber, { nopop = true, noshade = true })
end
sled(24, 92, 233, L.board, { runR = TAR })
-- loose rawhide hanging from the last lashing
line({ { 81, 229 }, { 83, 236 }, { 80, 241 } }):each(function(x, y) px(x, y, RAW.base) end)
local _, shx, shy = F.gnome(104, 256, { hat = L.leaf, coat = L.accent, arm = "up", flip = true })
fill(rect(shx - 1, shy - 1, shx, shy), L.skin.base)
-- the tar pot on a brazier of stones, a brush in it, steam
local function tarpot(x, yb)
  F.shadow(x - 8, x + 8, yb, 4, 2)
  for k = -1, 1 do F.snowCap(F.rock(x + k * 6, yb, 3, 3), 1, x + k) end
  fill(rect(x - 3, yb - 4, x + 3, yb - 3), G.base) px(x - 1, yb - 4, G.hi) px(x + 2, yb - 3, G.shade)
  local pot = c:rrect(x - 6, yb - 12, x + 6, yb - 4, 3)
  rimOf(pot, IR) part(pot, IR)
  hline(x - 5, x + 5, yb - 12, TAR.base) hline(x - 4, x + 4, yb - 11, TAR.deep) px(x - 3, yb - 12, TAR.hi)
  local brush = line({ { x + 2, yb - 12 }, { x + 7, yb - 20 } }, 1)
  brush:each(function(xx, yy) px(xx, yy, L.board.base) end) px(x + 7, yb - 20, L.board.hi)
  F.steam(x - 2, yb - 15, 5, .5, 23)
end
tarpot(56, 258)

---------------------------------------------------------------- foreground right: snowshoes in a bank, rawhide coils, a toolbox, a kicksled
F.depth(3)
F.drift(318, 242, 16, 5, 24)
snowshoe(310, 228, 4, 8) snowshoe(320, 226, 4, 9) snowshoe(329, 230, 3, 7)
F.drift(320, 244, 12, 3, 25)
-- coils of rawhide lashing
for k = 0, 2 do
  local y = 258 - k * 3
  local o = c:ellipse(354, y, 9 - k, 3):cut(c:ellipse(354, y, 6 - k, 1))
  rimOf(o, L.timber) fill(o, k % 2 == 0 and RAW.base or RAW.shade)
  o:each(function(x, yy) if yy < y - 1 then px(x, yy, RAW.hi) end end)
end
line({ { 363, 258 }, { 370, 262 }, { 376, 260 } }):each(function(x, y) px(x, y, RAW.shade) end)
-- red toolbox with snow on its lid
local tb = rect(286, 250, 306, 260) rimOf(tb, L.timber) part(tb, L.awnA) hline(286, 306, 253, L.awnA.deep)
fill(rect(294, 245, 298, 246), IR.base) vline(294, 246, 249, IR.base) vline(298, 246, 249, IR.base)
hline(287, 293, 250, S.hi) hline(299, 305, 250, S.base)
-- a finished red kicksled with a sale tag, front to the right
local function kicksled(x0, yb)
  local run = line({ { x0, yb }, { x0 + 36, yb }, { x0 + 40, yb - 3 }, { x0 + 39, yb - 6 } }, 1)
  local up = line({ { x0 + 12, yb }, { x0 + 18, yb - 26 } }, 2)
  local bar = rect(x0 + 14, yb - 27, x0 + 22, yb - 26)
  local seat = rect(x0 + 22, yb - 13, x0 + 34, yb - 11)
  local back = rect(x0 + 21, yb - 22, x0 + 23, yb - 12)
  local sl = rect(x0 + 23, yb - 10, x0 + 24, yb):add(rect(x0 + 32, yb - 10, x0 + 33, yb))
  F.shadow(x0, x0 + 40, yb, 5, 2)
  local sil = union(run, up, bar, seat, back, sl)
  rimOf(sil, L.timber)
  part(run, IR, { nopop = true, noshade = true }) hline(x0, x0 + 36, yb, IR.hi)
  part(union(up, bar), L.board, { nopop = true, noshade = true })
  part(union(seat, back, sl), L.wall2, { nopop = true })
  hline(x0 + 22, x0 + 34, yb - 13, L.wall2.hi) vline(x0 + 21, yb - 22, yb - 12, L.wall2.hi)
  -- painted flower on the backrest, snow on the seat
  px(x0 + 22, yb - 18, L.gold.hi) px(x0 + 22, yb - 17, L.plaster.hi)
  hline(x0 + 25, x0 + 33, yb - 14, S.hi)
  -- tag on a string from the handlebar
  vline(x0 + 15, yb - 25, yb - 22, RAW.shade)
  local tag = rect(x0 + 13, yb - 21, x0 + 17, yb - 18) c:rim(tag, L.timber.edge) fill(tag, L.board.hi) px(x0 + 15, yb - 20, L.awnA.base)
  return sil
end
kicksled(402, 222)
F.sprite({ -- a snow bunting on the kicksled seat
  "..cc..",
  ".cWWk.",
  "WWWWWb",
  "KWWKW.",
  ".o.o..",
}, 428, 203, { W = L.fur.hi, c = L.board.hi, k = L.timber.edge, b = L.gold.shade, K = L.timber.edge, o = L.timber.deep })
F.tracks({ { 380, 226 }, { 350, 222 }, { 336, 214 } }, "boot", 6)
F.shadowM(c:ellipse(352, 220, 22, 2))
sleepDog(334, 212) sleepDog(352, 214, true)

---------------------------------------------------------------- the carrier: a gnome bringing a pair of skis up the road
local _, cx1, cy1 = F.gnome(276, 214, { hat = L.roof2, coat = L.awnA, arm = "up" })
for k = 0, 1 do
  local m = line({ { cx1 - 26, cy1 + 2 - k * 2 }, { cx1 + 12, cy1 - 6 - k * 2 } }, 1)
  rimOf(m, L.timber) m:each(function(x, y) px(x, y, k == 0 and L.accent.base or L.accent.hi) end)
end
px(cx1 + 13, cy1 - 8, L.accent.hi) px(cx1 + 14, cy1 - 10, L.accent.hi) px(cx1 + 13, cy1 - 10, L.accent.base)
F.tracks({ { 268, 236 }, { 272, 222 } }, "boot", 5)
-- shavings trail along the left verge
shavings(200, 236, 238, 262, 14, 54)
-- willow scrub and sedge
F.willow(14, 214, 6, 7, 26) F.willow(130, 262, 7, 8, 27) F.willow(372, 224, 5, 6, 28)

F.depth(0)
F.birds({ { 330, 34, 2 }, { 344, 40, 1 }, { 168, 50, 1 }, { 150, 44, 2 } })
-- a raven sitting on the stovepipe cap
F.sprite({
  "..kk..",
  ".kkKkb",
  "kkkkk.",
  "kkkkkk",
  ".k..k.",
}, 129, 66, { k = "#3e3a4a", K = L.timber.hi, b = L.gold.shade })
-- chopping block with an axe by the road (left)
F.depth(3)
local cb = log(176, 198, 256, 6, 2)
local axe = line({ { 186, 248 }, { 196, 236 } }, 2) rimOf(axe, L.timber) fill(axe, L.board.base)
fill(poly{ { 193, 234 }, { 200, 230 }, { 201, 238 } }, IR.hi) px(200, 237, IR.shade) px(195, 234, IR.base)
for _, s in ipairs({ { 166, 260 }, { 204, 262 } }) do
  local m = poly{ { s[1], s[2] }, { s[1] + 5, s[2] - 2 }, { s[1] + 6, s[2] }, { s[1] + 1, s[2] + 2 } }
  rimOf(m, L.timber) fill(m, L.birch.base) px(s[1] + 1, s[2], L.birch.hi) px(s[1] + 5, s[2] - 1, L.birch.edge)
end
F.tracks({ { 120, 266 }, { 150, 252 } }, "hare", 7)
F.finish()
