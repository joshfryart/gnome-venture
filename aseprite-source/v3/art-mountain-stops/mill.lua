-- mill.lua : "Old mill" stop look, MOUNTAIN (mountain_granite), 480x270 gate view.
-- Same composition as the Maplewold mill (art-2701-batch3/stops/opus3/mill.lua), re-cast for the high mountains:
-- road's end: a larch-log granary (stadel) on granite mushroom stilts (replaces the windmill), between a spruce
-- and a larch, with a glacial cascade falling off the crags behind and a stream running down to the flume.
-- Back left: a stone-and-larch chalet with chimney smoke and geraniums, a dry-stone wall. Far right: terraced rye
-- with dry-stone walls, hay racks and grazing goats. Right: the stone dairy-granary with a hoist lifting a sling
-- of grain sacks, a cheese rack and a stone dock. Left hero: the mill, a whitewashed granite storey under a
-- larch-board storey and a weighted slab roof, overshot wheel and flume. Bottom left: a milky glacial tarn with
-- cotton grass and dippers, a granite slab bridge. Millstones and sacks, a gnome dressing a millstone, a goat cart
-- with sacks, a sack-carrying gnome on the road and a whistling marmot, a goat on a boulder, edelweiss and gentian.
-- Quirk: a goat kid in a red gnome hat balancing on the top paddle of the water wheel.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-mountain-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "mill", out = DIR, farTrees = { 24, 52, 160, 330, 352, 440 }, treeLineGap = { 178, 262 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local HZ = F.HZ

---------------------------------------------------------------- the glacial cascade behind (falls off the far crags)
F.depth(0)
do
  local function cx(y) return 190 + floor(3 * sin(y / 7)) + (y > 96 and floor((y - 96) * .3) or 0) end
  local gorge = HP.mask()
  for y = 70, HZ + 2 do
    local w = 2 + floor((y - 70) / 14)
    for x = cx(y) - w - 1, cx(y) + w + 1 do gorge:set(x, y) end
  end
  gorge:each(function(x, y) px(x, y, (x < cx(y)) and F.mix(L.peak.deep, L.sky[4], .3) or F.mix(L.peak.edge, L.sky[4], .3)) end)
  for y = 70, HZ + 2 do
    local w = 1 + floor((y - 70) / 14)
    for x = cx(y) - w, cx(y) + w do
      local v = hash(x, y // 2, 5)
      px(x, y, (x - cx(y) <= -w + 1) and L.snow.hi or (v < .5 and L.snow.base or L.water.hi))
    end
    if (y - 70) % 9 == 0 then hline(cx(y) - w - 2, cx(y) + w + 2, y, L.snow.hi) end -- ledge splashes
  end
  -- spray at the foot
  for i = 0, 14 do px(cx(HZ) - 6 + floor(hash(i, 1, 6) * 14), HZ - 2 + floor(hash(i, 2, 6) * 4), L.mist2) end
end

---------------------------------------------------------------- far right: terraced rye with dry-stone walls, hay racks, goats
F.depth(1)
local field = poly{ { 268, 114 }, { 470, 114 }, { 470, 146 }, { 284, 146 } }
local terr = { 114, 121, 129, 137, 146 }
field:each(function(x, y)
  local t = 1
  for i = 1, #terr - 1 do if y >= terr[i] then t = i end end
  local r = (t % 2 == 1) and L.needle or L.gold
  local ry = (y - terr[t]) % 3
  local h = ry == 0 and r.hi or (ry == 1 and r.base or r.shade)
  if hash(x, y, 3) < .05 then h = r.deep end
  if t % 2 == 0 and hash(x // 9, t, 4) < .3 then h = (ry == 2) and L.fern.shade or L.fern.base end -- a stubble / pasture terrace
  px(x, y, h)
end)
-- dry-stone terrace walls (a lit top course, dark joints)
for i = 2, #terr do
  local y = terr[i]
  for x = 270 + (i - 2) * 4, 470 do
    if field:has(x, y - 1) or field:has(x, y) then
      px(x, y - 1, (x % 4 == 0) and L.stone.deep or L.stone.hi) px(x, y, (x % 4 == 2) and L.stone.deep or L.stone.base) px(x, y + 1, L.stone.shade)
    end
  end
end
-- hay racks (stangen) with drying hay
for _, hr in ipairs({ { 300, 127 }, { 340, 119 }, { 420, 127 }, { 452, 135 } }) do
  local x, y = hr[1], hr[2]
  vline(x - 4, y - 7, y, L.timber.deep) vline(x + 4, y - 7, y, L.timber.deep)
  local hay = F.rect(x - 4, y - 7, x + 4, y - 3)
  fill(hay, L.needle.base) hline(x - 4, x + 4, y - 7, L.needle.hi) hline(x - 4, x + 4, y - 3, L.needle.deep)
  for k = -3, 3, 2 do px(x + k, y - 5, L.needle.shade) end
end
F.goat(372, 135, { k = .45, graze = true, noShadow = true })
F.goat(394, 128, { k = .4, flip = true, r = L.chamois, noShadow = true })
F.goat(318, 143, { k = .45, flip = true, graze = true, noShadow = true })

---------------------------------------------------------------- the glacial stream from the cascade foot to the flume intake
do
  local st = poly{ { 186, 113 }, { 196, 113 }, { 212, 120 }, { 230, 128 }, { 226, 131 }, { 208, 124 }, { 188, 117 } }
  rimOf(st, L.water)
  st:each(function(x, y) px(x, y, hash(x // 2, y, 7) < .35 and L.water.hi or (hash(x, y, 8) < .15 and L.snow.hi or L.water.base)) end)
  for _, b in ipairs({ { 200, 121 }, { 214, 127 }, { 190, 118 } }) do F.boulder(b[1], b[2], 2, 2, b[1]) end
end

---------------------------------------------------------------- road's end: the larch stadel on granite mushroom stilts
F.depth(2)
F.tree(206, 128, 58, 2)
F.larch(278, 128, 54, 5)
local function stadel()
  local body = rect(224, 92, 256, 114)
  local roofM = poly{ { 216, 95 }, { 240, 70 }, { 264, 95 } }
  local gable = poly{ { 228, 92 }, { 240, 79 }, { 252, 92 } }
  roofM:cut(gable)
  local stilts, caps = HP.mask(), HP.mask()
  for _, sx in ipairs({ 227, 240, 253 }) do
    stilts:add(rect(sx - 1, 118, sx + 1, 126))
    caps:add(c:ellipse(sx, 116, 4, 1))
  end
  F.shadow(222, 258, 126, 8, 3)
  rimOf(union(body, roofM, gable, stilts, caps), L.timber)
  part(stilts, L.stone, { nopop = true }) stilts:each(function(x, y) if hash(x, y // 2, 3) < .3 then px(x, y, L.stone.shade) end end)
  part(caps, L.stone, { nopop = true }) caps:each(function(x, y) if not caps:has(x, y - 1) then px(x, y, L.stone.hi) end end)
  part(body, L.timber)
  F.logs(body, L.timber, 92, 3)
  for y = 93, 113, 3 do F.logEnd(223, y, 1, L.timber) F.logEnd(257, y, 1, L.timber) end
  -- sun-scorched larch: darker toward the top
  body:each(function(x, y) if y < 98 and hash(x, y, 4) < .3 then px(x, y, L.timber.deep) end end)
  part(gable, L.board, { nopop = true })
  F.planks(gable, L.timber, 3, true, 7)
  part(roofM, L.roof, { sep = true })
  F.courses(roofM, 70, 3, 6, L.roof)
  F.lichen(roofM, .25, 68)
  line({ { 217, 94 }, { 239, 71 } }):each(function(x, y) if roofM:has(x, y) then px(x, y, L.roof.hi) end end)
  -- a weighting stone on the ridge
  local ws = c:ellipse(240, 70, 3, 2) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true }) px(239, 69, L.stone.hi)
  -- door with a lit crack, a tiny window, steps up on a stone block
  F.door(236, 100, 244, 114, L.timber)
  fill(rect(239, 101, 241, 102), L.glow.base)
  F.window(248, 98, 251, 102, L.timber)
  local step = rect(232, 115, 246, 118) rimOf(step, L.stone) part(step, L.stone, { nopop = true })
  -- a grain sack waiting at the door
  F.sack(230, 114, L.awnB, 3)
end
stadel()
F.birds({ { 300, 40, 2 }, { 312, 47, 1 }, { 292, 52, 1 }, { 150, 62, 2 }, { 178, 72, 1 }, { 330, 60, 1 } })

---------------------------------------------------------------- back-left: stone-and-larch chalet
F.depth(1)
F.tree(84, 128, 44, 1)
F.tree(10, 134, 40, 0)
local ctop, ccx, cwall, croof = F.building{ x0 = 20, x1 = 66, yb = 138, wh = 30, rh = 18, wall = L.timber, roof = L.roof, chimney = true, shingle = true, noFrame = true, noAttic = true }
F.planks(cwall, L.timber, 3, false, 21)
local cbase = rect(20, 126, 66, 138)
part(cbase, L.plaster, { nopop = true }) F.courses(cbase, 126, 4, 7, L.plaster)
F.lichen(croof, .2, 22)
-- a balcony with red geraniums
local bal = rect(18, 122, 68, 124) rimOf(bal, L.timber) part(bal, L.timber, { nopop = true, noshade = true })
for x = 20, 66, 3 do px(x, 121, L.apple.base) if x % 2 == 0 then px(x + 1, 120, L.apple.hi) end px(x + 1, 121, L.leaf.shade) end
F.window(28, 112, 33, 117, L.timber) F.window(54, 112, 59, 117, L.timber) F.door(40, 128, 47, 137, L.timber)
F.smoke(57, 92, 6, .6, 2)
-- a low dry-stone wall receding toward the road
local function stoneWall(x0, y0, x1, y1, h0, h1)
  local m = HP.mask()
  for x = x0, x1 do
    local t = (x - x0) / (x1 - x0)
    local y = floor(y0 + (y1 - y0) * t + .5)
    local h = floor(h0 + (h1 - h0) * t + .5)
    for yy = y - h, y do m:set(x, yy) end
  end
  rimOf(m, L.stone)
  m:each(function(x, y)
    local v = hash(x // 3, y // 2 + (x // 3) % 2, 31)
    local h = v < .3 and L.stone.hi or (v < .75 and L.stone.base or L.stone.shade)
    if (x + (y // 2) * 2) % 3 == 0 and hash(x, y, 32) < .6 then h = L.stone.deep end
    if not m:has(x, y - 1) then h = L.stone.hi end
    px(x, y, h)
  end)
  F.lichen(m, .25, 33)
  return m
end
stoneWall(70, 140, 196, 132, 5, 3)

---------------------------------------------------------------- right: the stone dairy-granary with a hoist lifting a sling of sacks
F.depth(2)
F.tree(300, 152, 54, 1)
F.tree(452, 142, 58, 0)
F.tree(436, 136, 40, 3)
local top, cx, swall, sroof = F.building{ x0 = 330, x1 = 420, yb = 170, wh = 46, rh = 24, wall = L.timber, roof = L.roof, noAttic = true, shingle = true, noFrame = true }
-- larch boards above, whitewashed granite below
F.planks(swall, L.timber, 5, true, 9)
local sbase = rect(330, 146, 420, 170)
part(sbase, L.plaster, { nopop = true }) F.courses(sbase, 146, 5, 9, L.plaster)
sbase:each(function(x, y) if hash(x // 3, y // 3, 12) < .12 then px(x, y, L.stone.base) end if y > 165 and hash(x, y, 13) < .3 then px(x, y, L.plaster.shade) end end)
hline(330, 420, 145, L.timber.edge)
F.lichen(sroof, .2, 69)
-- weighting stones along the slab roof
for _, w in ipairs({ { 344, 120 }, { 363, 110 }, { 387, 110 }, { 406, 120 } }) do
  local ws = c:ellipse(w[1], w[2], 3, 2) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true }) px(w[1] - 1, w[2] - 1, L.stone.hi)
end
-- loft door + hoist beam
local loft = rect(368, 110, 382, 126)
fill(loft, L.timber.deep) fill(rect(369, 111, 381, 126), L.soil.deep)
F.sack(372, 126, L.awnB, 3) F.sack(379, 126, L.board, 3)
local beamH = rect(372, 104, 398, 107)
rimOf(beamH, L.timber) part(beamH, L.timber, { nopop = true, noshade = true }) hline(372, 398, 104, L.timber.hi)
vline(394, 108, 128, L.board.deep) -- rope
-- the hoisted sling of grain sacks
local net = HP.mask()
for _, s in ipairs({ { 386, 140 }, { 394, 141 }, { 402, 140 }, { 390, 134 }, { 398, 134 } }) do net:add(F.sack(s[1], s[2], (s[1] == 394 or s[1] == 390) and L.awnB or L.board, 4)) end
line({ { 394, 128 }, { 383, 135 } }):each(function(x, y) px(x, y, L.board.deep) end)
line({ { 394, 128 }, { 405, 135 } }):each(function(x, y) px(x, y, L.board.deep) end)
F.door(350, 150, 362, 169, L.timber, true)
F.window(398, 152, 406, 159, L.timber)
F.window(340, 128, 346, 134, L.timber)
-- geraniums under the upper window
hline(336, 350, 137, L.timber.base) for x = 337, 349, 2 do px(x, 136, L.apple.base) px(x + 1, 135, L.apple.hi) end
-- the stone dock with sacks and a cheese rack
local dock = rect(298, 160, 340, 172)
rimOf(dock, L.stone) part(dock, L.stone) F.courses(dock, 160, 4, 10, L.stone) F.lichen(dock, .15, 70)
local function cheese(x, yb, r, h)
  local m = c:rrect(x - r, yb - h, x + r, yb, 2)
  c:rim(m, L.cheese.edge) part(m, L.cheese, { nopop = true })
  hline(x - r + 1, x + r - 1, yb - h, L.cheese.hi) hline(x - r + 1, x + r - 1, yb, L.cheese.deep)
  px(x - 1, yb - h // 2, L.cheese.shade) px(x, yb - h // 2, L.cheese.shade) -- the stamp
  return m
end
-- rack: two shelves on posts
local rack = union(rect(300, 132, 301, 159), rect(336, 132, 337, 159), rect(300, 144, 337, 145), rect(300, 132, 337, 133))
rimOf(rack, L.timber) part(rack, L.timber, { nopop = true, noshade = true })
for k = 0, 3 do cheese(306 + k * 8, 143, 3, 4) end
for k = 0, 3 do cheese(306 + k * 8, 158, 3, 4) end
for k = 0, 2 do cheese(310 + k * 8, 131, 3, 4) end
F.depth(3)
local _, ghx, ghy = F.gnome(354, 184, { hat = L.awnA, coat = L.accent, arm = "up", flip = true })
vline(ghx, 146, ghy, L.board.deep) -- hauling the hoist rope
line({ { ghx, 146 }, { 394, 128 } }):each(function(x, y) px(x, y, L.board.deep) end)

---------------------------------------------------------------- a gnome dressing a granite millstone, sacks and stones
local function millstone(x, y, r, flat)
  local m = flat and c:ellipse(x, y, r, floor(r * .4)) or c:ellipse(x, y, floor(r * .62), r)
  F.rimOf(m, L.stone) part(m, L.stone)
  if flat then
    local side = rect(x - r, y, x + r, y + 3):cut(m) -- the thickness
    c:rim(side, L.stone.edge) fill(side, L.stone.shade) hline(x - r + 1, x + r - 1, y + 3, L.stone.deep)
    -- furrows (harp dress) and the eye
    for k = -r + 3, r - 3, 3 do line({ { x + k, y - 1 }, { x + k + 2, y + 1 } }):each(function(xx, yy) if m:has(xx, yy) then px(xx, yy, L.stone.shade) end end) end
    fill(c:ellipse(x, y, 2, 1), L.stone.deep) px(x - 1, y - 1, L.iron.base)
  else
    -- face-on, leaning: harp furrows radiating from the eye, a lit upper-left lip, the thickness on the right
    for k = 0, 9 do
      local a = k * pi / 5 + .3
      line({ { x + cos(a) * 3 * .6, y + sin(a) * 3 }, { x + cos(a) * (r - 2) * .62, y + sin(a) * (r - 2) } }):each(function(xx, yy) if m:has(xx, yy) then px(xx, yy, L.stone.shade) end end)
    end
    m:each(function(xx, yy) if not m:has(xx - 1, yy) or not m:has(xx, yy - 1) then px(xx, yy, L.stone.hi) end if not m:has(xx + 1, yy) then px(xx, yy, L.stone.deep) end end)
    fill(c:ellipse(x, y, 1, 2), L.stone.edge) px(x - 1, y - 1, L.iron.base)
  end
  m:each(function(xx, yy) if hash(xx, yy, 33) < .12 then px(xx, yy, L.stone.deep) elseif hash(xx, yy, 34) < .1 then px(xx, yy, L.stone.hi) end end)
  return m
end
F.shadow(372, 412, 198, 6, 3)
-- trestle with a millstone lying flat
local tl = union(line({ { 380, 198 }, { 384, 190 } }), line({ { 386, 198 }, { 384, 190 } }), line({ { 404, 198 }, { 408, 190 } }), line({ { 410, 198 }, { 408, 190 } }))
rimOf(tl, L.timber) part(tl, L.timber, { nopop = true, noshade = true })
millstone(396, 186, 15, true)
-- grit dust under it
for i = 0, 8 do px(386 + floor(hash(i, 1, 3) * 22), 199 + floor(hash(i, 2, 3) * 2), L.stone.hi) end
local _, mhx, mhy = F.gnome(420, 204, { hat = L.roof2, coat = L.wall2, arm = "up", flip = true })
-- the mill pick raised
line({ { mhx, mhy + 2 }, { mhx + 2, mhy - 6 } }):each(function(x, y) px(x, y, L.board.base) end)
local pick = rect(mhx - 1, mhy - 8, mhx + 5, mhy - 7) c:rim(pick, L.iron.edge) fill(pick, L.iron.base) px(mhx - 1, mhy - 8, L.iron.hi) px(mhx + 5, mhy - 7, L.iron.deep)
-- sparks / chips flying
px(405, 180, L.glow.hi) px(408, 178, L.stone.hi) px(402, 177, L.glow.base)
F.gentian(430, 214, true) F.gentian(434, 211, true) F.edelweiss(426, 212, true)

---------------------------------------------------------------- left hero: the stone-and-larch mill + overshot wheel
F.depth(2)
F.larch(76, 162, 50, 43)
F.depth(3)
local mtop, mcx, wallM, roofM = F.building{ x0 = 92, x1 = 172, yb = 186, wh = 52, rh = 26, wall = L.timber, roof = L.roof, chimney = true, shingle = true, noFrame = true }
-- larch boards on the upper storey, whitewashed rubble granite below
local boards = wallM:copy():clip(rect(92, mtop + 2, 172, 160))
F.planks(boards, L.timber, 4, false, 17)
boards:each(function(x, y) if y < mtop + 10 and hash(x, y, 18) < .25 then px(x, y, L.timber.deep) end end) -- sun-scorched under the eaves
local foot = rect(92, 161, 172, 186)
part(foot, L.plaster, { nopop = true })
-- rubble courses: irregular stones, some showing through the whitewash
foot:each(function(x, y)
  local row = (y - 161) // 5
  local ry = (y - 161) % 5
  local bw = 7 + floor(hash(row, 1, 19) * 4)
  local rx = (x + row * 3) % bw
  if ry == 0 or rx == 0 then px(x, y, L.plaster.shade)
  elseif hash((x + row * 3) // bw, row, 20) < .3 then px(x, y, (ry == 1) and L.stone.hi or L.stone.base)
  elseif ry == 1 and rx == 1 then px(x, y, L.plaster.hi) end
  if y > 182 and hash(x, y, 21) < .35 then px(x, y, L.stone.shade) end
end)
hline(92, 172, 160, L.timber.edge)
local corners = union(rect(92, mtop, 94, 160), rect(170, mtop, 172, 160), rect(92, mtop, 172, mtop + 1))
part(corners, L.timber, { nopop = true, noshade = true })
F.lichen(roofM, .2, 71)
for _, w in ipairs({ { 103, 131 }, { 120, 120 }, { 145, 120 }, { 162, 131 } }) do
  local ws = c:ellipse(w[1], w[2], 3, 2) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true }) px(w[1] - 1, w[2] - 1, L.stone.hi)
end
F.door(108, 166, 120, 185, L.timber, true)
F.window(134, 146, 142, 153, L.timber)
F.window(150, 146, 158, 153, L.timber)
F.window(100, 170, 103, 174, L.timber)
-- a round sign over the door: a millstone with an ear of rye
local plaque = c:ellipse(114, 155, 5, 4) rimOf(plaque, L.timber) part(plaque, L.board)
F.sprite({ ".g.", "gGg", ".G.", ".t." }, 113, 153, { g = L.gold.shade, G = L.gold.base, t = L.timber.base }, { rim = false })
-- window boxes with red geraniums
for _, wx in ipairs({ 138, 154 }) do
  hline(wx - 5, wx + 5, 156, L.timber.base) hline(wx - 5, wx + 5, 157, L.timber.deep)
  for k = -4, 4, 2 do px(wx + k, 155, L.leaf.base) px(wx + k + 1, 154, L.apple.base) px(wx + k, 154, k % 4 == 0 and L.apple.hi or L.leaf.hi) end
end
-- a pile of grain sacks against the wall
F.shadow(160, 178, 188, 6, 3)
F.sack(160, 188, L.awnB, 5) F.sack(171, 189, L.board, 5) F.sack(166, 180, L.awnB, 4)

-- granite wheel pit behind the wheel
local pit = rect(170, 176, 214, 200)
rimOf(pit, L.stone) part(pit, L.stone) F.courses(pit, 176, 6, 10, L.stone) F.lichen(pit, .2, 72)
-- flume on trestles, bringing the glacial water over the top of the wheel
local flume = poly{ { 186, 140 }, { 228, 129 }, { 228, 134 }, { 186, 145 } }
local legs = rect(218, 135, 220, 150):add(rect(206, 138, 208, 152))
rimOf(union(flume, legs), L.timber)
part(legs, L.timber, { nopop = true, noshade = true })
part(flume, L.board)
line({ { 187, 140 }, { 227, 129 } }):each(function(x, y) px(x, y, L.water.hi) end)
line({ { 187, 141 }, { 227, 130 } }):each(function(x, y) if hash(x, y, 2) < .5 then px(x, y, L.water.base) end end)

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
-- iron straps on the rim, wet dark wood low down
ringO:each(function(x, y) if y > hy + R * .55 and hash(x, y, 74) < .45 then px(x, y, L.timber.deep) end end)
for k = 0, 7 do local a = k * pi / 4 + .6 px(floor(hx + cos(a) * (R - 2)), floor(hy + sin(a) * (R - 2)), L.iron.hi) end
local hubm = c:ellipse(hx, hy, 3, 3) fill(hubm, L.iron.base) px(hx - 1, hy - 1, L.iron.hi) px(hx + 1, hy + 1, L.iron.deep)
-- water pouring over the far side of the wheel + splash
local pour = poly{ { 184, 142 }, { 190, 142 }, { 214, 160 }, { 220, 182 }, { 216, 198 }, { 212, 182 }, { 208, 162 } }
pour:cut(spokes):cut(ringI)
pour:each(function(x, y) px(x, y, hash(x, y, 4) < .3 and L.water.hi or (hash(x, y, 5) < .15 and L.snow.hi or L.water.base)) end)
for i = 0, 10 do local x, y = 200 + floor(hash(i, 1, 9) * 26), 192 + floor(hash(i, 2, 9) * 10) px(x, y, L.water.hi) px(x + 1, y, L.snow.hi) end
-- icicles of spray hanging off the flume lip
for _, ix in ipairs({ 188, 192 }) do vline(ix, 146, 148, L.snow.base) end
-- quirk: a goat kid in a red gnome hat balancing on the top paddle
F.goat(195, 141, { k = .74, hat = L.awnA, flip = true, noShadow = true })

---------------------------------------------------------------- tail race and the glacial tarn (bottom-left)
local stream = poly{ { 170, 200 }, { 214, 200 }, { 206, 214 }, { 176, 226 }, { 150, 230 }, { 138, 222 }, { 160, 212 } }
local pond = poly{ { 18, 232 }, { 40, 220 }, { 96, 216 }, { 150, 220 }, { 180, 230 }, { 176, 250 }, { 140, 262 }, { 80, 266 }, { 30, 262 }, { 16, 250 } }
local water = union(stream, pond)
rimOf(water, L.water)
local bank = water:grow(2):cut(water)
bank:each(function(x, y) if y > 199 then local v = hash(x, y, 51) px(x, y, v < .4 and L.stone.base or (v < .7 and L.stone.hi or L.stone.shade)) end end)
F.water(water, L.water)
-- reflections of the peaks (pale) and the spruces (dark) along the far edge
for _, rx in ipairs({ 40, 58, 120, 140 }) do for k = 0, 5 do hline(rx - 3 + k // 2, rx + 3 - k // 2, 222 + k * 2, L.water.shade) end end
for _, rx in ipairs({ 80, 100 }) do for k = 0, 4 do hline(rx - 4 + k, rx + 4 - k, 222 + k * 2, L.water.hi) end end
for y = 206, 214, 3 do hline(176, 196, y, L.water.shade) end
-- stepping boulders, with dippers (brown, white bib) bobbing on them
local function dipper(x, yb, flip)
  local s = flip and -1 or 1
  local rows = { "..dd.....", ".dbbd....", "dbebd...t", "kdWbbd.tt", ".dWWbbbd.", "..dWbbdd.", "...ddd...", "...o.o..." }
  if flip then for i, r in ipairs(rows) do rows[i] = r:reverse() end end
  F.sprite(rows, x - 4, yb - 7, { d = "#4a3a36", b = "#6e5448", W = L.edel.hi, e = L.timber.edge, k = L.iron.deep, t = "#4a3a36", o = L.timber.deep })
end
for _, b in ipairs({ { 66, 237, 7, 6 }, { 112, 243, 6, 5 }, { 140, 232, 4, 3 } }) do F.boulder(b[1], b[2], b[3], b[4], b[1]) hline(b[1] - b[3] - 1, b[1] + b[3] + 1, b[2] + 1, L.water.hi) end
dipper(66, 231) dipper(112, 238, true)
-- cotton grass: white tufts on fine stems along the bank
for i = 0, 10 do
  local x = 20 + i * 3 + floor(hash(i, 1, 52) * 2)
  local h = 6 + floor(hash(i, 9, 52) * 8)
  local yb = 248 - (i % 3)
  vline(x, yb - h, yb, i % 2 == 0 and L.fern.shade or L.fern.deep)
  px(x, yb - h - 1, L.edel.hi) px(x + 1, yb - h - 1, L.edel.base) px(x, yb - h - 2, L.edel.hi) px(x + 1, yb - h, L.edel.shade)
end
-- granite boulders on the bank
F.boulder(166, 252, 9, 8, 76)
F.boulder(16, 232, 7, 6, 77)
-- a granite slab bridge over the race
local br = poly{ { 136, 212 }, { 168, 206 }, { 172, 212 }, { 140, 218 } }
rimOf(br, L.stone) part(br, L.stone)
F.lichen(br, .25, 13)
line({ { 137, 212 }, { 168, 206 } }):each(function(x, y) px(x, y, L.stone.hi) end)
local brs = poly{ { 140, 218 }, { 172, 212 }, { 172, 214 }, { 140, 220 } } fill(brs, L.stone.deep)

---------------------------------------------------------------- left: spare millstones, sacks and a sack-carrying gnome
F.depth(3)
F.shadow(34, 96, 202, 8, 4)
millstone(44, 189, 13)
millstone(60, 192, 11)
millstone(78, 198, 14, true)
F.sack(30, 204, L.awnB, 5) F.sack(40, 206, L.board, 5) F.sack(35, 198, L.awnB, 4)
local _, sx2, sy2 = F.gnome(108, 210, { hat = L.awnA, coat = L.leaf, arm = "up" })
F.sack(sx2 - 1, sy2 + 3, L.awnB, 4)
-- edelweiss and junipers along the left edge
F.juniper(24, 214, 8, 5, 3)
for _, f in ipairs({ { 22, 196 }, { 86, 210 }, { 94, 214 }, { 128, 206 } }) do F.edelweiss(f[1], f[2], true) end

---------------------------------------------------------------- right foreground: a goat cart with sacks
F.depth(3)
local function cart(x0, yb)
  local bed = poly{ { x0, yb - 14 }, { x0 + 40, yb - 14 }, { x0 + 38, yb - 6 }, { x0 + 2, yb - 6 } }
  local shaft = line({ { x0 + 40, yb - 10 }, { x0 + 60, yb - 9 } }, 2)
  rimOf(union(bed, shaft), L.timber)
  part(shaft, L.timber, { nopop = true, noshade = true })
  part(bed, L.board) hline(x0 + 1, x0 + 39, yb - 10, L.board.deep)
  F.planks(bed, L.board, 5, true, 31)
  -- sacks and a cheese wheel on the bed
  F.sack(x0 + 7, yb - 14, L.awnB, 5) F.sack(x0 + 19, yb - 14, L.board, 5) F.sack(x0 + 13, yb - 22, L.awnB, 4)
  local ch = c:rrect(x0 + 27, yb - 22, x0 + 37, yb - 14, 2) c:rim(ch, L.cheese.edge) part(ch, L.cheese, { nopop = true }) hline(x0 + 28, x0 + 36, yb - 22, L.cheese.hi)
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
F.goat(366, 226, { r = L.goat })
-- a red collar with a brass bell
px(374, 210, L.awnA.base) px(375, 209, L.awnA.base) px(374, 211, L.gold.hi) px(374, 212, L.gold.shade)
-- a goat standing on a big boulder, near right (keeps out of the compass corner x>=380, y>=230)
F.boulder(454, 214, 7, 6, 90)
F.edelweiss(446, 214, true) F.edelweiss(462, 216, true)
F.juniper(318, 258, 10, 6, 11) F.juniper(344, 262, 8, 5, 12)
F.edelweiss(330, 246, true) F.edelweiss(336, 249, true) F.gentian(326, 250, true) F.gentian(352, 250, true)
F.conifer(364, 264, 30, L.foliage2, 41)
F.sign(436, 168, 28, 14, L.board)
-- a little millstone painted on the sign
F.sprite({ ".sss.", "sSSSs", "sSeSs", "sSSSs", ".sss." }, 434, 171, { s = L.stone.deep, S = L.stone.base, e = L.timber.edge }, { rim = false })

-- by the road, right: a big lichened boulder with a goat standing on top, as goats do
F.boulder(290, 218, 11, 10, 91)
F.goat(289, 208, { r = L.chamois, k = .8, flip = true, noShadow = true })
F.gentian(276, 220, true) F.edelweiss(304, 219, true)

---------------------------------------------------------------- gnome on the road with a sack on his shoulder
local _, phx, phy = F.gnome(258, 240, { hat = L.roof2, coat = L.wall2, arm = "up" })
F.sack(phx - 2, phy + 3, L.awnB, 5)
-- a trail of spilled grain ... to a whistling marmot by its burrow
for i = 0, 7 do px(262 + i * 4, 243 + i * 2, L.gold.hi) px(263 + i * 4, 243 + i * 2, L.gold.shade) end
local hole = c:ellipse(300, 265, 7, 2) c:rim(hole, L.soil.shade) fill(hole, L.soil.edge) hline(294, 306, 263, L.soil.base)
F.marmot(300, 264)
px(306, 250, L.edel.hi) px(308, 249, L.edel.base) px(309, 248, L.edel.hi) -- the whistle (a puff)
F.depth(0)

F.finish()
