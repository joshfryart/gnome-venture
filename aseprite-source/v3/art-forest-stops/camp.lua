-- camp.lua : "Camp" stop look, FOREST (forest_pinewood), 480x270 gate view.
-- Same composition and story as the Maplewold camp (art-2701-batch3/stops/opus3/camp.lua), re-cast for a pine wood:
-- road's end: the striped two-peak mess marquee (sage and cream canvas) between two spruces, stove-pipe smoke.
-- Back left: a rust-canvas ridge tent under a fir; a washing line strung from a spruce to a birch, a gnome pegging.
-- Right: the cream bell tent glowing inside, its hem moss-stained, needles on the cone. Back right: a canvas wagon
-- under spruces. Left: split firewood stacked between stakes (log ends), a hedgehog. Hero: the campfire in a mossy
-- stone ring with a tripod pot, log seats with sawn ends and stumps, a lute player, a toasting gnome, a mug gnome,
-- a dog asleep. Bottom left: the camp kitchen table with a basket of chanterelles. Ferns, mushrooms, pine cones.
-- Quirk: a raccoon climbing out of the green pack with a sausage, ringed tail over the rim.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-forest-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "camp", out = DIR, farTrees = { 24, 52, 160, 196, 290, 318, 440 }, treeLineGap = { 194, 286 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local G, IR = L.glow, L.iron
local sage = L.wall2

-- local helpers ------------------------------------------------------------------------
local function stump(x, yb, w, mossK, seed)
  local body = rect(x - w, yb - w, x + w, yb)
  local top = c:ellipse(x, yb - w, w, math.max(1, w // 2))
  local roots = poly{ { x - w - 2, yb }, { x - w, yb - 3 }, { x - w, yb } }:add(poly{ { x + w + 2, yb }, { x + w, yb - 3 }, { x + w, yb } })
  rimOf(union(body, top, roots), L.timber)
  part(union(body, roots), L.timber, { nopop = true })
  body:each(function(xx, yy) if (xx - x) % 3 == 0 and hash(xx, yy // 2, seed or 5) < .6 then px(xx, yy, L.timber.shade) end end)
  vline(x - w + 1, yb - w + 1, yb - 1, L.timber.hi)
  fill(top, L.board.base)
  top:each(function(xx, yy) local d = math.sqrt((xx - x) ^ 2 + ((yy - (yb - w)) * 2) ^ 2) if floor(d) % 2 == 1 then px(xx, yy, L.board.shade) end if xx - x + (yy - (yb - w)) * 2 < -w * .6 then px(xx, yy, L.board.hi) end end)
  px(x, yb - w, L.board.deep)
  if mossK then F.moss(body, mossK, seed or 7) end
  return body, top
end
local function cone(x, y) px(x, y, L.soil.base) px(x + 1, y, L.soil.shade) px(x, y + 1, L.soil.shade) px(x + 1, y + 1, L.soil.deep) px(x, y - 1, L.soil.hi) end

-- trodden needle-earth clearing around the fire (left of the road)
local clear = c:ellipse(150, 214, 92, 30)
clear:each(function(x, y) if not F.roadM:has(x, y) and x < F.xl(y) - 1 then
  local v = hash(x, y, 3)
  local d = ((x - 150) / 92) ^ 2 + ((y - 214) / 30) ^ 2
  if d < .8 then
    local b = hash(x // 4, y // 2, 4)
    local h = b < .55 and L.soil.base or (b < .85 and L.needle.shade or L.soil.shade)
    if v < .04 then h = L.soil.hi elseif v > .96 then h = L.soil.deep end
    px(x, y, h)
  elseif hash(x // 3, y // 2, 4) < .45 then px(x, y, L.needle.shade) end
end end)

---------------------------------------------------------------- back trees (plane 1)
F.depth(1)
F.tree(10, 140, 46, 1)
F.tree(318, 138, 46, 0)
F.tree(384, 142, 58, 6)
F.tree(444, 136, 44, 5)

---------------------------------------------------------------- road's end: the striped two-peak mess marquee
F.depth(2)
F.tree(292, 128, 50, 2)
do
  local cx, yb = 240, 128
  local wall = rect(cx - 34, yb - 16, cx + 34, yb)
  local roofm = poly{ { cx - 42, yb - 15 }, { cx - 16, yb - 44 }, { cx, yb - 32 }, { cx + 16, yb - 44 }, { cx + 42, yb - 15 } }
  local poles = rect(cx - 17, yb - 54, cx - 16, yb - 44):add(rect(cx + 16, yb - 54, cx + 17, yb - 44))
  F.shadow(cx - 34, cx + 34, yb, 10, 3)
  rimOf(union(wall, roofm, poles), L.timber)
  roofm:each(function(x, y)
    local pk = x < cx and cx - 16 or cx + 16
    local u = (x - pk) / (y - (yb - 46))
    local k = floor(u * 5 + 20)
    local h = (k % 2 == 0) and sage.base or L.awnB.hi
    if (u * 5 + 20) % 1 < .14 then h = (k % 2 == 0) and sage.shade or L.awnB.shade end
    if x > pk + 6 and (x - pk) / 26 + (y - (yb - 44)) / 30 > .9 then h = (k % 2 == 0) and sage.shade or L.awnB.base end
    if x < pk - 2 and (pk - x) / 10 + (y - (yb - 44)) / 12 < 1.1 then h = (k % 2 == 0) and sage.hi or L.awnB.hi end
    px(x, y, h)
  end)
  -- fallen needles and a damp line on the canvas
  roofm:each(function(x, y) if hash(x, y, 81) < .008 then px(x, y, L.needle.shade) end end)
  wall:each(function(x, y)
    local k = ((x - cx + 40) // 6) % 2
    local h = k == 0 and L.awnB.base or sage.hi
    if x > cx + 22 then h = k == 0 and L.awnB.shade or sage.base end
    if y >= yb - 2 and hash(x, y, 82) < .55 then h = L.moss.shade end
    px(x, y, h)
  end)
  for x = cx - 40, cx + 38, 6 do fill(poly{ { x, yb - 15 }, { x + 6, yb - 15 }, { x + 3, yb - 11 } }, L.roof2.base) px(x + 3, yb - 12, L.roof2.shade) px(x + 1, yb - 15, L.roof2.hi) end
  hline(cx - 42, cx + 42, yb - 15, L.roof2.deep)
  local door = poly{ { cx - 8, yb }, { cx - 5, yb - 12 }, { cx + 5, yb - 12 }, { cx + 8, yb } }
  fill(door, G.shade) fill(rect(cx - 3, yb - 9, cx + 3, yb), G.base) px(cx - 2, yb - 8, G.hi)
  part(poles, L.timber, { nopop = true, noshade = true })
  for _, p in ipairs({ { cx - 16, L.awnA }, { cx + 17, L.gold } }) do fill(poly{ { p[1] + 1, yb - 54 }, { p[1] + 10, yb - 52 }, { p[1] + 1, yb - 49 } }, p[2].base) px(p[1] + 2, yb - 53, p[2].hi) end
  for _, g in ipairs({ { cx - 42, cx - 50 }, { cx + 42, cx + 50 } }) do line({ { g[1], yb - 15 }, { g[2], yb + 1 } }):each(function(x, y) px(x, y, L.board.deep) end) end
  fill(rect(cx + 25, yb - 34, cx + 27, yb - 28), IR.base) px(cx + 25, yb - 34, IR.hi) hline(cx + 24, cx + 28, yb - 35, IR.deep)
  F.smoke(cx + 26, yb - 38, 5, .6, 2) -- stove pipe smoke
  -- a stack of log ends beside the marquee
  for k = 0, 2 do F.logEnd(cx + 38 + k * 4, yb - 2, 2) end
  for k = 0, 1 do F.logEnd(cx + 40 + k * 4, yb - 6, 2) end
end

---------------------------------------------------------------- back left: ridge tent under a fir
local function ridgeTent(x, yb, w, h, r, flap)
  local front = poly{ { x - w, yb }, { x, yb - h }, { x + w, yb } }
  local side = poly{ { x, yb - h }, { x + w + 18, yb - h + 4 }, { x + w + 22, yb - 2 }, { x + w, yb } }
  local door = poly{ { x - w // 3, yb }, { x, yb - h * 2 // 3 }, { x + w // 3, yb } }
  F.shadow(x - w, x + w + 22, yb, 10, 3)
  rimOf(union(front, side), r)
  part(side, r, { noshade = true }) side:each(function(xx, y) if (xx - x) % 6 == 0 then px(xx, y, r.shade) end end)
  side:each(function(xx, y) if y < yb - h + 7 and hash(xx, y, 83) < .06 then px(xx, y, L.needle.shade) end end)
  part(front, r, { sep = true })
  fill(door, r.deep) fill(poly{ { x - 1, yb }, { x, yb - h * 2 // 3 }, { x + w // 3, yb } }, L.soil.deep)
  if flap then fill(poly{ { x, yb - h * 2 // 3 }, { x - w // 3 - 4, yb - 2 }, { x - w // 3, yb } }, r.hi) end
  hline(x - w, x + w + 22, yb, L.moss.shade)
  vline(x, yb - h - 4, yb - h, L.timber.base)
  line({ { x - w - 4, yb + 1 }, { x - w + 2, yb - 4 } }):each(function(xx, y) px(xx, y, L.board.shade) end)
  line({ { x + w + 26, yb + 1 }, { x + w + 18, yb - 6 } }):each(function(xx, y) px(xx, y, L.board.shade) end)
end
F.depth(1)
ridgeTent(36, 146, 14, 18, L.roof2, true)
F.fern(64, 150, 4) F.fern(18, 150, 4, L.needle)
F.depth(2)
do
  local fl = c:rrect(98, 151, 138, 156, 2)
  F.shadow(100, 138, 157, 5, 2)
  rimOf(fl, L.timber) part(fl, L.timber, { nopop = true }) F.logs(fl, L.timber, 151, 6) F.moss(fl, .35, 26)
  F.logEnd(137, 153, 2)
  F.mushroom(108, 151, L.needle, true) F.mushroom(113, 151, L.needle) F.mushroom(122, 151, L.apple)
  F.fern(94, 158, 4) F.fern(144, 158, 3, L.needle)
end
F.depth(1)

---------------------------------------------------------------- washing line from a spruce to a birch
F.tree(84, 140, 46, 4)
F.depth(2)
F.birch(184, 140, 46, 37)
local function sagY(x) local t = (x - 88) / (182 - 88) return floor(108 + 8 * sin(t * pi)) end
for x = 88, 182 do px(x, sagY(x), L.awnB.deep) end
for i, it in ipairs({ { 98, L.awnA, "sock" }, { 112, sage, "shirt" }, { 132, L.gold, "sock" }, { 146, L.awnB, "shirt" }, { 166, L.lav, "sock" } }) do
  local x = it[1] local y = sagY(x) + 1 local r = it[2]
  local m
  if it[3] == "sock" then m = rect(x, y, x + 3, y + 8):add(rect(x, y + 6, x + 6, y + 9))
  else m = rect(x - 2, y, x + 10, y + 3):add(rect(x + 1, y, x + 7, y + 13)) end
  rimOf(m, r) part(m, r, { nopop = true })
  hline(x, x + 3, y, r.hi) px(x + 1, y - 1, L.timber.base)
  if it[3] == "sock" then hline(x, x + 3, y + 2, L.awnB.hi) end
end

---------------------------------------------------------------- right: cream bell tent glowing inside
F.depth(3)
local mixS = F.mix(sage.hi, sage.base, .5)
local function bellTent(cx, yb)
  local wall = rect(cx - 46, yb - 26, cx + 46, yb)
  local cone = poly{ { cx - 52, yb - 24 }, { cx - 30, yb - 46 }, { cx, yb - 62 }, { cx + 30, yb - 46 }, { cx + 52, yb - 24 } }
  local pole = rect(cx - 1, yb - 74, cx, yb - 62)
  F.shadow(cx - 44, cx + 46, yb, 16, 5)
  rimOf(union(wall, cone, pole), L.timber)
  cone:each(function(x, y)
    local u = (x - cx) / (yb + 4 - y)
    local k = floor(u * 9 + 20) % 2
    local edge = (u * 9 + 20) % 1 < .12
    local lit = x < cx - 4 and (cx - x) / 30 + (y - (yb - 62)) / 22 < 1.3
    px(x, y, edge and L.awnB.deep or (k == 0 and (lit and sage.hi or mixS) or (lit and L.plaster.hi or L.awnB.hi)))
  end)
  wall:each(function(x, y)
    local k = floor((x - cx) / 10 + 20) % 2
    px(x, y, ((x - cx) % 10 == 0) and L.awnB.deep or (k == 0 and L.awnB.hi or sage.hi))
  end)
  wall:each(function(x, y) if x > cx + 30 and (x - cx) % 10 ~= 0 then px(x, y, (floor((x - cx) / 10 + 20) % 2 == 0) and L.awnB.shade or sage.base) end end)
  cone:each(function(x, y) if x > cx + 20 and (x - cx) / 52 + (y - (yb - 62)) / 40 > 1.1 and c:get(x, y) ~= L.awnB.deep then px(x, y, (floor((x - cx) / (yb + 4 - y) * 9 + 20) % 2 == 0) and sage.shade or L.awnB.shade) end end)
  -- needles and a cone fallen on the canvas, a mossy damp hem
  cone:each(function(x, y) if hash(x, y, 84) < .006 then px(x, y, L.needle.shade) px(x + 1, y - 1, L.needle.base) end end)
  wall:each(function(x, y)
    local hgt = 2 + floor(hash(x // 3, 0, 86) * 4)
    if y >= yb - hgt then px(x, y, hash(x, y, 87) < .45 and L.moss.shade or (hash(x, y, 88) < .5 and L.mossGround.shade or L.moss.deep)) end
  end)
  hline(cx - 52, cx + 52, yb - 24, sage.deep) hline(cx - 51, cx + 51, yb - 23, sage.shade)
  for x = cx - 50, cx + 48, 6 do fill(poly{ { x, yb - 22 }, { x + 6, yb - 22 }, { x + 3, yb - 18 } }, sage.base) px(x + 3, yb - 19, sage.shade) px(x + 1, yb - 22, sage.hi) end
  part(pole, L.timber, { nopop = true, noshade = true })
  local fl = poly{ { cx + 1, yb - 74 }, { cx + 12, yb - 71 }, { cx + 1, yb - 68 } } fill(fl, L.awnA.base) px(cx + 2, yb - 73, L.awnA.hi) px(cx + 9, yb - 71, L.awnA.shade)
  -- open door with warm light, a hanging lantern inside, a rug, a bedroll and a teddy
  local door = poly{ { cx - 12, yb }, { cx - 6, yb - 30 }, { cx + 6, yb - 30 }, { cx + 12, yb } }
  fill(door, G.shade) fill(poly{ { cx - 8, yb }, { cx - 4, yb - 26 }, { cx + 4, yb - 26 }, { cx + 8, yb } }, G.base)
  fill(rect(cx - 2, yb - 22, cx + 2, yb - 16), G.hi) vline(cx, yb - 26, yb - 23, L.timber.edge) px(cx - 1, yb - 21, L.awnB.hi)
  fill(rect(cx - 6, yb - 6, cx + 6, yb - 1), L.roof2.shade) hline(cx - 6, cx + 6, yb - 6, L.roof2.base)
  for x = cx - 5, cx + 5, 3 do px(x, yb - 4, L.gold.base) end
  local flapL = poly{ { cx - 12, yb }, { cx - 6, yb - 30 }, { cx - 20, yb - 2 } } fill(flapL, L.awnB.shade) c:edgeIn(flapL, L.awnB.deep)
  local flapR = poly{ { cx + 12, yb }, { cx + 6, yb - 30 }, { cx + 20, yb - 2 } } fill(flapR, L.awnB.shade) c:edgeIn(flapR, L.awnB.deep)
  for _, t in ipairs({ { cx - 14, yb - 14 }, { cx + 14, yb - 14 } }) do hline(t[1] - 1, t[1] + 1, t[2], L.roof2.base) end -- tie-backs
  for _, g in ipairs({ { cx - 52, yb - 24, cx - 66, yb + 2 }, { cx + 52, yb - 24, cx + 66, yb + 2 } }) do
    line({ { g[1], g[2] }, { g[3], g[4] } }):each(function(x, y) px(x, y, L.board.deep) end)
    fill(rect(g[3] - 1, g[4] - 2, g[3], g[4] + 1), L.timber.base) px(g[3] - 1, g[4] - 2, L.board.hi)
  end
end
bellTent(350, 196)
-- ferns and mushrooms at the tent's feet
for _, f in ipairs({ { 300, 198, 5 }, { 308, 200, 4 }, { 398, 198, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.mushroom(392, 201, L.needle) F.mushroom(388, 200, L.needle, true)

---------------------------------------------------------------- back right: canvas-covered wagon
local function wagon(x0, yb)
  local bed = rect(x0, yb - 16, x0 + 56, yb - 8)
  local cover = HP.mask()
  for k = 0, 3 do cover:add(c:ellipse(x0 + 7 + k * 14, yb - 22, 9, 14):clip(rect(x0, yb - 40, x0 + 56, yb - 16))) end
  cover:add(rect(x0 + 2, yb - 28, x0 + 54, yb - 16))
  local shaft = line({ { x0, yb - 10 }, { x0 - 16, yb - 4 } }, 2)
  F.shadow(x0, x0 + 58, yb, 10, 3)
  rimOf(union(bed, cover, shaft), L.timber)
  part(shaft, L.timber, { nopop = true, noshade = true })
  part(cover, L.awnB)
  for k = 1, 3 do vline(x0 + k * 14, yb - 34, yb - 17, L.awnB.shade) end
  cover:each(function(x, y) if hash(x, y, 89) < .006 then px(x, y, L.needle.shade) px(x + 1, y - 1, L.needle.base) end end)
  part(bed, L.timber) F.planks(bed, L.timber, 3, false, 21) hline(x0, x0 + 56, yb - 12, L.timber.deep)
  F.moss(bed, .06, 22)
  for _, wx in ipairs({ x0 + 10, x0 + 46 }) do
    local w = c:ellipse(wx, yb - 6, 7, 7) rimOf(w, L.timber) part(w, L.timber, { nopop = true }) fill(c:ellipse(wx, yb - 6, 4, 4), L.timber.shade)
    vline(wx, yb - 12, yb, L.timber.deep) hline(wx - 6, wx + 6, yb - 6, L.timber.deep) px(wx, yb - 6, IR.hi)
  end
  fill(c:ellipse(x0 + 58, yb - 18, 3, 3), IR.base) px(x0 + 57, yb - 19, IR.hi) px(x0 + 59, yb - 17, IR.deep)
end
F.depth(2)
wagon(400, 152)
F.tree(468, 150, 46, 5)
F.depth(3)

---------------------------------------------------------------- left: split firewood stacked between stakes
local function woodStack(x0, x1, yb)
  local stakes = rect(x0 - 2, yb - 22, x0, yb):add(rect(x1, yb - 22, x1 + 2, yb))
  local stack = rect(x0 + 1, yb - 18, x1 - 1, yb)
  F.shadow(x0, x1 + 2, yb, 8, 3)
  rimOf(union(stakes, stack), L.timber)
  part(stakes, L.timber, { nopop = true, noshade = true })
  px(x0 - 2, yb - 22, L.timber.hi) px(x1, yb - 22, L.timber.hi)
  fill(stack, L.timber.edge)
  for row = 0, 3 do for k = 0, (x1 - x0) // 6 do
    local x, y = x0 + 3 + k * 6 + (row % 2) * 3, yb - 3 - row * 5
    if x < x1 - 1 then F.logEnd(x, y, 2, (hash(k, row, 90) < .3) and L.redbark or L.timber) end
  end end
  -- a strip of bark shingle over the stack, mossed
  local lid = rect(x0 - 3, yb - 24, x1 + 3, yb - 21)
  rimOf(lid, L.roof2) part(lid, L.roof2, { nopop = true }) F.courses(lid, yb - 24, 2, 5, L.roof2) F.moss(lid, .3, 91)
end
woodStack(22, 72, 196)
-- a hedgehog snuffling at the woodpile
F.sprite({
  "...sSsSs.....",
  "..SsSsSsSs...",
  ".sSsHsSsSsS..",
  "sSsHsSsHsSsf.",
  "SsSsSsSsSsfFf",
  "sSsSsHsSsfFeF",
  "SsSsSsSsfFFFFn",
  ".ffff.ffffff..",
  "..d.d...d.d...",
}, 74, 187, { s = L.soil.deep, S = L.soil.shade, H = L.soil.hi, f = L.needle.hi, F = L.board.hi, e = L.timber.edge, n = L.timber.edge, d = L.timber.deep })
F.fern(20, 206, 6) F.fern(28, 204, 5, L.needle) F.fern(84, 204, 4)
-- a gnome pegging a sock on the washing line
F.gnome(140, 134, { small = true, hat = L.produce, coat = L.leaf, arm = "up" })

---------------------------------------------------------------- the campfire (hero) with tripod pot, log seats and stumps
local function campfire(cx, cy)
  local function seat(x0, x1, y, bark)
    bark = bark or L.timber
    local m = c:rrect(x0, y - 4, x1, y + 4, 4)
    F.shadow(x0, x1, y + 6, 4, 2)
    rimOf(m, bark) part(m, bark, { nopop = true })
    F.logs(m, bark, y - 4, 9)
    hline(x0 + 4, x1 - 4, y - 3, bark.hi)
    m:each(function(x, yy) if (x * 3 + yy) % 13 == 0 then px(x, yy, bark.deep) end end)
    m:each(function(x, yy) if yy <= y - 2 and hash(x // 2, yy, x0) < .12 then px(x, yy, bark.hi) end end)
    F.moss(m:copy():clip(rect(x0, y + 1, x1, y + 4)), .25, x0 + 1)
    F.logEnd(x1 - 3, y, 4, bark)
  end
  seat(cx - 34, cx + 38, cy - 24)
  local ring = c:ellipse(cx, cy, 24, 9):cut(c:ellipse(cx, cy, 17, 5))
  local pit = c:ellipse(cx, cy, 17, 5)
  fill(pit, L.soil.deep)
  pit:each(function(x, y) if hash(x, y, 8) < .3 then px(x, y, L.road.shade) end end) -- ash
  for k = 0, 13 do
    local a = k / 14 * 2 * pi
    local x, y = floor(cx + cos(a) * 21), floor(cy + sin(a) * 7)
    local st = c:rrect(x - 4, y - 3, x + 3, y + 2, 2)
    rimOf(st, L.stone) part(st, L.stone, { nopop = k % 3 ~= 0 })
    if sin(a) > -.2 then F.moss(st, .22, 92 + k) end
  end
  local logs = line({ { cx - 12, cy + 2 }, { cx + 10, cy - 4 } }, 3):add(line({ { cx - 10, cy - 4 }, { cx + 12, cy + 2 } }, 3))
  rimOf(logs, L.timber) part(logs, L.timber, { nopop = true })
  logs:each(function(x, y) if hash(x, y, 93) < .25 then px(x, y, G.deep) end end) -- charred glowing cracks
  pit:each(function(x, y) if hash(x, y, 9) < .25 and not logs:has(x, y) then px(x, y, G.deep) end end)
  local fl = poly{ { cx - 12, cy }, { cx - 9, cy - 16 }, { cx - 5, cy - 9 }, { cx - 2, cy - 28 }, { cx + 2, cy - 12 }, { cx + 6, cy - 22 }, { cx + 9, cy - 8 }, { cx + 12, cy } }
  fill(fl, G.deep)
  fill(fl:shrink(1), G.shade)
  fill(poly{ { cx - 8, cy }, { cx - 3, cy - 20 }, { cx + 1, cy - 9 }, { cx + 5, cy - 15 }, { cx + 8, cy } }, G.base)
  fill(poly{ { cx - 4, cy }, { cx - 1, cy - 12 }, { cx + 3, cy } }, G.hi)
  for i = 0, 14 do px(cx - 14 + floor(hash(i, 1, 31) * 30), cy - 32 - floor(hash(i, 2, 31) * 24), i % 3 == 0 and G.base or G.hi) end
  local tri = line({ { cx - 18, cy + 4 }, { cx, cy - 40 } }, 2):add(line({ { cx + 18, cy + 4 }, { cx, cy - 40 } }, 2)):add(line({ { cx + 4, cy - 2 }, { cx, cy - 40 } }, 1))
  rimOf(tri, L.timber) part(tri, L.birch, { nopop = true, noshade = true }) -- birch poles
  tri:each(function(x, y) if hash(x, y // 2, 94) < .15 then px(x, y, L.birch.edge) end end)
  hline(cx - 2, cx + 2, cy - 38, L.board.deep) -- lashing
  vline(cx, cy - 37, cy - 30, IR.deep)
  local pot = c:ellipse(cx, cy - 25, 7, 5):add(rect(cx - 7, cy - 28, cx + 7, cy - 26))
  rimOf(pot, IR) part(pot, IR) hline(cx - 7, cx + 7, cy - 28, IR.hi) fill(rect(cx - 5, cy - 29, cx + 5, cy - 29), L.needle.hi)
  px(cx - 3, cy - 29, L.apple.base) px(cx + 2, cy - 29, L.gold.hi) -- stew: a mushroom slice, a carrot
  fill(c:ellipse(cx, cy - 29, 7, 3):cut(c:ellipse(cx, cy - 29, 6, 2)):clip(rect(cx - 8, cy - 33, cx + 8, cy - 29)), IR.deep)
  F.smoke(cx + 1, cy - 38, 8, .5, 2)
  -- warm light on the needles
  local glowM = c:ellipse(cx, cy + 4, 42, 14):cut(c:ellipse(cx, cy, 25, 10))
  glowM:each(function(x, y) if hash(x, y, 33) < .3 and not F.roadM:has(x, y) then px(x, y, hash(x, y, 34) < .5 and L.gold.hi or L.needle.hi) end end)
  seat(cx - 46, cx - 22, cy + 4)
  seat(cx + 24, cx + 50, cy + 2, L.redbark)
  seat(cx - 16, cx + 18, cy + 20)
end
campfire(132, 214)
local _, lx, ly = F.gnome(104, 191, { hat = L.leaf, coat = L.roof2, arm = "hold", noShadow = true })
local lute = c:ellipse(lx + 2, ly, 4, 3):add(line({ { lx + 5, ly - 1 }, { lx + 12, ly - 6 } }, 1))
rimOf(lute, L.timber) part(lute, L.board, { nopop = true }) fill(c:ellipse(lx + 2, ly, 1, 1), L.timber.edge) px(lx + 12, ly - 7, L.timber.base)
for _, n in ipairs({ { lx + 8, ly - 14 }, { lx + 13, ly - 18 } }) do vline(n[1] + 1, n[2] - 3, n[2], L.timber.edge) fill(rect(n[1], n[2], n[1] + 1, n[2] + 1), L.timber.edge) end
local _, mx, my = F.gnome(96, 210, { hat = L.awnA, coat = sage, arm = "out" })
-- a toasting stick: a marshmallow and a little mushroom skewered on it
fill(line({ { mx, my }, { mx + 10, my - 7 } }), L.board.base) fill(rect(mx + 10, my - 9, mx + 12, my - 7), L.awnB.hi) px(mx + 12, my - 7, L.needle.base) px(mx + 10, my - 9, L.plaster.hi)
px(mx + 6, my - 5, L.apple.base) px(mx + 7, my - 5, L.apple.shade)
local _, ux, uy = F.gnome(174, 208, { hat = L.gold, coat = L.lav, arm = "out", flip = true })
fill(rect(ux - 3, uy - 3, ux, uy + 1), L.board.hi) px(ux, uy - 2, L.board.base) px(ux - 3, uy - 3, L.board.base) px(ux - 2, uy - 5, L.cloud.top) px(ux - 1, uy - 7, L.cloud.top)
-- a dog asleep by the fire, nose on its paws
F.sprite({
  ".ee.............",
  "eDDe....DDDDD...",
  "DDeDDDDDDDDDDD..",
  "nwDDDDDDDDdDDDt.",
  "wwwDDDDDDDDDDDtt",
  ".wwdddddddddd...",
}, 154, 228, { e = L.timber.base, D = L.needle.base, d = L.needle.shade, n = L.timber.edge, w = L.awnB.hi, t = L.needle.hi })
hline(156, 157, 230, L.timber.edge)
-- a stump stool by the lute player and pine cones by the ring
stump(66, 216, 5, .3, 23)
for _, p in ipairs({ { 112, 230 }, { 158, 222 }, { 84, 222 }, { 192, 236 } }) do cone(p[1], p[2]) end

---------------------------------------------------------------- camp kitchen table, bottom-left
local tbl = rect(24, 236, 76, 239):add(rect(27, 240, 30, 252)):add(rect(70, 240, 73, 252))
F.shadow(26, 76, 252, 8, 3)
rimOf(tbl, L.timber) part(tbl, L.board, { nopop = true })
F.planks(rect(24, 236, 76, 239), L.board, 9, true, 31)
local ket = c:ellipse(36, 231, 5, 4):add(rect(41, 228, 44, 229)) rimOf(ket, L.accent) part(ket, L.accent) fill(rect(34, 226, 38, 227), L.accent.shade)
local pan = c:ellipse(56, 234, 7, 2) rimOf(pan, IR) part(pan, IR, { nopop = true }) fill(rect(63, 233, 70, 234), L.timber.base)
for k = 0, 2 do px(52 + k * 3, 233, L.gold.base) px(53 + k * 3, 233, L.gold.shade) end
-- a woven basket of chanterelles
local bask = c:rrect(64, 228, 75, 235, 2)
rimOf(bask, L.needle) part(bask, L.needle, { nopop = true })
bask:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) end end)
for k = 0, 4 do local x = 65 + k * 2 px(x, 227, L.produce.hi) px(x + 1, 227, L.produce.base) px(x, 226, L.gold.hi) end
line({ { 64, 228 }, { 69, 222 }, { 75, 228 } }):each(function(x, y) if y < 228 then px(x, y, L.needle.deep) end end)
-- under the table: a water bucket and ferns
local bucket = rect(40, 244, 48, 251) rimOf(bucket, L.timber) part(bucket, L.timber, { nopop = true }) hline(40, 48, 246, IR.shade) hline(41, 47, 244, L.water.base)
F.fern(20, 254, 7) F.fern(82, 252, 6, L.needle)
F.mushroom(14, 244, L.apple, true) F.mushroom(10, 246, L.apple)

---------------------------------------------------------------- bedrolls, packs and the raccoon (right of the road)
local function bedroll(x, y, r)
  local m = c:rrect(x - 14, y - 5, x + 14, y + 5, 5)
  rimOf(m, r) part(m, r)
  for k = -8, 8, 8 do vline(x + k, y - 5, y + 5, r.deep) end
  local e = c:ellipse(x + 12, y, 3, 5) fill(e, r.hi) c:ellipse(x + 12, y, 1, 3):edge():each(function(xx, yy) px(xx, yy, r.shade) end)
  hline(x - 6, x - 4, y - 5, L.timber.base)
  m:each(function(xx, yy) if (xx + yy * 2) % 7 == 0 and yy < y then px(xx, yy, r.hi) end end) -- check weave
end
bedroll(300, 230, sage) bedroll(312, 240, L.roof2)
local function pack(x, yb, r)
  local m = c:rrect(x - 8, yb - 18, x + 8, yb, 4)
  local flap = c:rrect(x - 8, yb - 20, x + 8, yb - 12, 3)
  F.shadow(x - 6, x + 8, yb, 6, 2)
  rimOf(union(m, flap), r) part(m, r) part(flap, r, { sep = true })
  fill(rect(x - 1, yb - 13, x + 1, yb - 11), L.gold.base) px(x - 1, yb - 13, L.gold.hi)
  vline(x - 5, yb - 11, yb - 2, r.deep) vline(x + 5, yb - 11, yb - 2, r.deep)
  fill(c:ellipse(x + 10, yb - 8, 4, 4), IR.base) px(x + 9, yb - 10, IR.hi) px(x + 12, yb - 6, IR.deep)
end
pack(346, 258, L.leaf)
pack(330, 262, L.roof)
F.sprite({
  ".kk..........kk.",
  "kggk........kggk",
  "kgggggggggggggk.",
  "gggwwggggggwwgg.",
  "gwwkkkwggwkkkwwg",
  "gwkkKkkwwkkKkkwg",
  ".gwkkkwwwwkkkwg.",
  "..gwwwwnnwwwwg..",
  "...gwwwwwwwwg...",
  "...gggggggggg...",
  "..pggggggggggp..",
  "SSSSSSSSSSSSSs..",
  "ssSSSSSSSSSSSS..",
  "..pg........gp..",
}, 337, 224, { k = L.stone.edge, g = L.stone.base, w = L.awnB.hi, K = L.awnB.hi, n = L.timber.edge, p = L.stone.shade, S = L.awnA.shade, s = L.awnA.hi })
F.sprite({ "gg", "kk", "gg", "kk", "gg", "kk" }, 355, 238, { g = L.stone.base, k = L.stone.edge })
F.fern(364, 262, 7) F.fern(320, 268, 6, L.needle) F.fern(294, 258, 5)
F.depth(0)
F.birds({ { 330, 40, 2 }, { 344, 48, 1 }, { 120, 56, 2 } })
F.depth(3)

---------------------------------------------------------------- near right: chopping stump, young spruce, mushrooms
F.depth(2)
F.tree(456, 206, 56, 1)
F.depth(3)
F.conifer(436, 228, 24, L.foliage2, 44)
local cs = stump(416, 224, 8, .25, 24)
-- an axe bitten into the stump
local haft = line({ { 417, 213 }, { 426, 203 } }, 1) c:rim(haft, L.timber.edge) haft:each(function(x, y) px(x, y, L.board.base) end) px(426, 203, L.board.hi)
local axe = poly{ { 410, 210 }, { 417, 211 }, { 417, 216 }, { 411, 217 } } c:rim(axe, IR.edge) fill(axe, IR.base) vline(410, 210, 217, IR.hi) px(411, 210, IR.hi) px(416, 216, IR.deep) vline(417, 211, 216, IR.shade)
for _, s in ipairs({ { 404, 224 }, { 432, 226 } }) do
  local m = poly{ { s[1], s[2] }, { s[1] + 5, s[2] - 2 }, { s[1] + 6, s[2] }, { s[1] + 1, s[2] + 2 } }
  rimOf(m, L.timber) fill(m, L.board.base) px(s[1] + 1, s[2], L.board.hi) px(s[1] + 5, s[2] - 1, L.timber.base)
end
F.fern(462, 222, 7) F.fern(470, 226, 5, L.needle)
F.mushroom(456, 216, L.apple, true) F.mushroom(460, 218, L.apple)

---------------------------------------------------------------- by the road: lantern pole, sign
local lp = rect(286, 176, 287, 212) rimOf(lp, L.timber) part(lp, L.timber, { nopop = true, noshade = true })
F.moss(rect(286, 204, 287, 212), .5, 25)
fill(rect(281, 176, 287, 177), L.timber.base) vline(281, 178, 180, L.timber.edge)
local lan = rect(278, 181, 284, 188) rimOf(lan, L.timber) fill(lan, G.base) px(279, 182, G.hi) vline(284, 182, 188, G.shade) hline(278, 284, 181, L.timber.base)
F.sign(212, 196, 20, 12, L.board)
fill(poly{ { 206, 205 }, { 212, 198 }, { 218, 205 } }, sage.base) fill(poly{ { 211, 205 }, { 212, 202 }, { 213, 205 } }, L.timber.deep) px(210, 200, sage.hi)
F.fern(204, 214, 4) F.mushroom(220, 212, L.needle)
F.finish()
