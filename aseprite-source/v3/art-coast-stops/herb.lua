-- herb.lua : "Herb garden" stop look, COAST (coast_driftwood), 480x270 gate view.
-- Same composition as the Maplewold herb (art-2701-batch3/stops/opus3/herb.lua), re-cast for a cliff-top garden
-- on a chalk-and-dune coast, the sea behind:
-- right: rows of lavender and glaucous sea kale running back to the cliff edge behind a drystone windbreak, two far
-- gnomes gathering. Road's end: a whalebone arch climbed by honeysuckle and a rambling rose, a driftwood gate ajar.
-- Back left: a tarred lean glasshouse on a whitewashed footing beside a wind-bent hawthorn; a lobster pot planter.
-- Left hero: the herbalist's whitewashed cottage with a lichened slate roof and a tarred plinth, drying bundles of
-- samphire, rosemary, lavender and kale with strings of dulse under the eave, a round sea-blue door, a shell-starfish
-- over it and a mortar-and-pestle sign. Wind-sheltered stone-walled beds (sea kale, marsh samphire, rosemary, catnip),
-- a potting table with buckthorn cordial, white WBC bee hives with slate roofs, a lichened stone herb spiral with
-- thyme and thrift, viper's bugloss and foxgloves along the left, a ring of shells round a chamomile patch, tubs of
-- rosemary, fennel and sea holly, a sea-buckthorn heavy with orange berries, an oystercatcher.
-- Quirk: a ginger cat asleep in the catnip bed, a common-blue butterfly on its ear.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-coast-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "herb", out = DIR, farTrees = { 24, 52, 160, 196, 440 }, duneLineGap = { 206, 270 },
  boats = { { 168, 97, 7 }, { 318, 95, 6 }, { 300, 100, 9 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local HAZE = "#d4e2e8"
-- local ramps
local LV = L.lav                                                    -- lavender
local SK = F.rp("#dcece6 #aecac6 #84a6aa #5e8088 #3e5a64")          -- sea kale, glaucous blue-grey
local SAM = F.rp("#d4e68c #a2c850 #74a03a #507630 #324c26")         -- marsh samphire, bright succulent green
local ROS = F.rp("#a4bc96 #72906e #526e56 #3a5440 #24382e")         -- rosemary
local BUG = F.rp("#bccaf6 #8298e4 #5c6ec2 #444e94 #2c3264")         -- viper's bugloss blue
local FX = F.rp("#f8d0ee #e08ed4 #b062aa #7a3c7e #4c2252")          -- foxglove
local BUCK = F.rp("#ffd27a #f8a032 #d8721e #a04c1c #642e16")        -- sea-buckthorn berries
local DUL = F.rp("#e08c96 #b0526a #883a52 #5e283c #3c1828")         -- dulse (red seaweed)
local CATN = F.rp("#d2dccc #a6b8a2 #7e9480 #5c705e #3c4c40")        -- catnip, grey-green
local THY = F.rp("#f0c6e2 #cc92c4 #a46a9e #744a74 #4a2e4c")         -- creeping thyme
local BONE = F.rp("#f4ecd8 #ded4ba #bcae94 #8e836e #5c5648")        -- whalebone
local HONEY = F.rp("#fbf0b8 #f0d278 #d0a64a #9a7434 #604622")       -- honeysuckle

---------------------------------------------------------------- right: lavender and sea-kale rows to the cliff edge
-- Rows run across the view; band height grows with nearness (d^2 / C). Thin far rows are a solid hazed band
-- with horizontal texture only (no shimmer); near rows are rounded lit mounds with sandy furrows.
local C = 190
local function rowOf(y) return floor(C / (y - 109)) end
for y = 114, 160 do
  local row = rowOf(y)
  local y0 = y while y0 > 114 and rowOf(y0 - 1) == row do y0 = y0 - 1 end
  local y1 = y while y1 < 160 and rowOf(y1 + 1) == row do y1 = y1 + 1 end
  local hgt = y1 - y0 + 1
  local kale = row % 3 == 1
  local R = kale and SK or LV
  local farC = F.mix(R.base, HAZE, .4)
  for x = 262, 479 do
    if x > F.xr(y) + 6 then
      local h
      if hgt < 3 then
        h = (y % 2 == 0) and F.mix(R.shade, HAZE, .35) or farC
        if hash(x // 4, y, 3) < .15 then h = F.mix(kale and L.awnB.hi or R.hi, HAZE, .3) end
      else
        local bw0 = math.max(5, floor(hgt * 1.7))
        local xx = x + row * 3
        local bi = xx // bw0
        local fx = (xx % bw0) / bw0
        local hk = .3 + .35 * hash(bi, row, 16)
        local ty = y0 + floor(hgt * hk * (1 - math.sqrt(math.max(0, 1 - (2 * fx - 1) ^ 2))) + (hash(bi, row, 17) < .3 and 1 or 0) + .5)
        local ry = (y - y0) / hgt
        local v = hash(x, y, 18 + row)
        if y < ty then
          h = (ry < .2) and L.ground.deep or L.ground.shade
          if hash(x, y, 12) < .14 then h = L.sand.shade end
        elseif y == y1 then h = L.ground.deep
        elseif kale then
          -- sea kale: broad crinkled blue-grey leaves, clouds of tiny white flowers on top
          if y == ty then h = fx < .5 and SK.hi or SK.base
          elseif fx < .35 then h = SK.base
          elseif fx < .72 then h = (v < .3) and SK.hi or SK.base
          else h = SK.shade end
          if ry > .78 then h = SK.deep end
          if y >= ty and y < y1 - 1 and hash(x, y, 14) < (hgt > 5 and .16 or .1) then h = (fx < .5) and L.awnB.hi or L.awnB.base end
        else
          -- lavender: grey-green woody base under a crust of violet spikes, lit upper left, freckled
          local lit = (1 - fx) * .8 - ry * 1.1 + (v - .5) * .7
          if y == ty then h = (fx < .55) and LV.hi or LV.base
          elseif lit > .45 then h = LV.hi
          elseif lit > -.05 then h = LV.base
          elseif lit > -.45 then h = LV.shade
          else h = (v < .5) and ROS.shade or LV.deep end
          if ry > .8 then h = (v < .5) and ROS.deep or LV.deep end
          if v > .93 and y > ty then h = CATN.base end
        end
      end
      px(x, y, h)
    end
  end
end
-- a low drystone windbreak closing the near edge of the field, lichen on its coping stones
do
  local wall = HP.mask()
  for x = 262, 479 do if x > F.xr(161) + 4 then for y = 156, 162 do wall:set(x, y) end end end
  F.depth(1)
  local cope = HP.mask()
  for x = 262, 479 do if wall:has(x, 156) then cope:set(x, 156) cope:set(x, 157) end end
  wall:each(function(x, y)
    local row = (y - 156) // 2
    local off = (row % 2) * 3
    local h = L.stone.base
    if (y - 156) % 2 == 1 then h = L.stone.shade end
    if (x + off + floor(hash(x // 5, row, 3) * 2)) % 6 == 0 then h = L.stone.deep end
    if y == 162 then h = L.stone.edge end
    if y <= 157 then h = ((x // 3) % 2 == 0) and L.stone.hi or L.stone.base if y == 157 then h = L.stone.shade end end
    px(x, y, h)
  end)
  hline(floor(F.xr(161)) + 5, 479, 155, L.stone.edge)
  F.lichen(cope, .14, 7)
  F.depth(0)
end

---------------------------------------------------------------- road's end: whalebone arch with honeysuckle and a rambling rose
local function arch()
  -- two jawbones rising from the ground, thick at the foot, meeting in a pointed crown
  local pL = poly{ { 212, 126 }, { 219, 126 }, { 220, 112 }, { 219, 96 }, { 220, 80 }, { 216, 80 }, { 215, 96 }, { 213, 112 } }
  local pR = poly{ { 261, 126 }, { 268, 126 }, { 267, 112 }, { 265, 96 }, { 264, 80 }, { 260, 80 }, { 261, 96 }, { 260, 112 } }
  local top = c:ellipse(240, 82, 24, 24):cut(c:ellipse(240, 82, 20, 20)):clip(rect(214, 56, 266, 82))
  F.shadow(214, 266, 126, 6, 3)
  local frame = union(pL, pR, top)
  rimOf(frame, BONE)
  part(frame, BONE, { nopop = true, noshade = true })
  -- bone: shaded right side, pitted with dark pores, orange lichen crusts, a lit left ridge
  frame:each(function(x, y)
    if not frame:has(x + 1, y) or not frame:has(x + 1, y + 1) then px(x, y, BONE.shade) end
    if not frame:has(x - 1, y) or not frame:has(x, y - 1) then px(x, y, BONE.hi) end
    if hash(x // 2, y // 2, 81) < .1 and hash(x, y, 82) < .6 then px(x, y, BONE.deep) end
    if hash(x // 2, y // 3, 84) < .07 then px(x, y, hash(x, y, 85) < .5 and L.lichen.base or L.lichen.shade) end
  end)
  -- the crown lashing: a tarred rope binding where the bones meet
  for y = 57, 60 do hline(238, 242, y, (y % 2 == 0) and L.cork.base or L.cork.deep) end
  px(238, 58, L.cork.hi) vline(240, 61, 64, L.cork.deep) px(240, 65, L.cork.shade)
  -- driftwood picket gate, ajar
  local rails = HP.mask()
  for _, xx in ipairs({ 223, 236 }) do rails:add(rect(xx, 108, xx + 1, 124)) end
  for xx = 226, 233, 3 do rails:add(rect(xx, 109 + (xx - 226) // 4, xx, 123)) end
  rails:add(line({ { 223, 111 }, { 237, 113 } }, 2)):add(line({ { 223, 119 }, { 237, 121 } }, 2))
  rimOf(rails, L.timber) part(rails, L.timber, { nopop = true, noshade = true })
  rails:each(function(x, y) if hash(x // 3, y, 83) < .25 then px(x, y, L.timber.hi) end end)
  -- climbers: honeysuckle up the left bone, a rambling rose up the right, meeting over the crown
  local clumps = { { 212, 121 }, { 221, 104 }, { 220, 80 }, { 224, 67 }, { 232, 60 }, { 248, 60 }, { 256, 66 }, { 263, 84 }, { 268, 120 } }
  for i, p in ipairs(clumps) do
    local leftSide = p[1] < 240
    F.crown(p[1], p[2], 5, 4, (i % 2 == 0) and L.foliage2 or L.leaf, 100 + i)
    if leftSide then
      -- honeysuckle: creamy-yellow trumpets in a fan
      local bx, by = p[1] + (i % 2 == 0 and -2 or 1), p[2] - 1
      px(bx, by, HONEY.hi) px(bx + 1, by - 1, HONEY.base) px(bx - 1, by - 1, HONEY.base) px(bx, by + 1, HONEY.shade)
      px(bx + 2, by + 1, DUL.hi)
    else
      local bx, by = p[1] - 1, p[2] - 2
      fill(rect(bx, by, bx + 1, by + 1), L.petal.base) px(bx, by, L.petal.hi) px(bx + 1, by + 1, L.petal.shade) px(bx + 2, by, L.petal.base)
      px(bx + 1, by, L.gold.hi)
      if i % 2 == 1 then px(bx + 3, by + 3, L.petal.hi) px(bx + 4, by + 3, L.petal.base) end
    end
  end
  -- trailing tendrils hanging off the crown
  for _, t in ipairs({ { 230, 66, 7 }, { 250, 65, 9 }, { 244, 63, 5 } }) do
    for k = 0, t[3] do px(t[1] + floor(sin(k * .9) + .5), t[2] + k, k % 3 == 0 and L.leaf.base or L.leaf.deep) end
    px(t[1], t[2] + t[3] + 1, (t[1] < 240) and HONEY.hi or L.petal.base)
  end
end

---------------------------------------------------------------- back-left: tarred glasshouse on a whitewashed footing
local function glasshouse(x0, x1, yb)
  local wh, rh = 20, 14
  local top, cx = yb - wh, (x0 + x1) // 2
  local wall = rect(x0, top, x1, yb)
  local roofm = poly{ { x0 - 2, top + 1 }, { cx, top - rh }, { x1 + 2, top + 1 } }
  local sill = rect(x0 - 1, yb - 5, x1 + 1, yb)
  F.shadow(x0 + 2, x1, yb, 8, 4)
  rimOf(union(wall, roofm, sill), L.tar)
  fill(wall, L.water.hi) fill(roofm, L.water.base)
  wall:each(function(x, y) if (x - y) % 11 == 0 then px(x, y, "#e8f2f0") end end)
  roofm:each(function(x, y) if (x + y) % 9 == 0 then px(x, y, L.water.hi) end end)
  -- tomatoes, seedlings and a geranium inside
  for x = x0 + 3, x1 - 3, 6 do
    local m = c:ellipse(x, yb - 9, 3, 4) fill(m, SAM.shade) px(x - 1, yb - 11, SAM.base) px(x + 1, yb - 7, SAM.deep) px(x, yb - 12, SAM.hi)
    if (x // 6) % 2 == 0 then px(x + 1, yb - 9, L.apple.base) px(x - 1, yb - 8, L.apple.shade) else px(x, yb - 10, L.petal.base) end
  end
  part(sill, L.plaster) F.courses(sill, yb - 5, 3, 6, L.plaster) F.lichen(sill, .12, 31)
  for x = x0, x1, 7 do vline(x, top, yb - 6, L.tar.base) end
  hline(x0, x1, top, L.tar.base) hline(x0, x1, top + 10, L.tar.base)
  for k = 0, 4 do line({ { x0 - 1 + k * (cx - x0) // 4, top - k * rh // 4 }, { x0 - 1 + k * (cx - x0) // 4, top } }):each(function(x, y) if roofm:has(x, y) then px(x, y, L.tar.hi) end end) end
  for k = 0, 4 do line({ { x1 + 1 - k * (x1 - cx) // 4, top - k * rh // 4 }, { x1 + 1 - k * (x1 - cx) // 4, top } }):each(function(x, y) if roofm:has(x, y) then px(x, y, L.tar.base) end end) end
  line({ { x0 - 2, top + 1 }, { cx, top - rh } }):each(function(x, y) px(x, y, L.tar.hi) end)
  line({ { cx, top - rh }, { x1 + 2, top + 1 } }):each(function(x, y) px(x, y, L.tar.deep) end)
  -- salt haze and a gull feather on the roof glass
  roofm:each(function(x, y) if hash(x, y, 33) < .05 then px(x, y, L.chalk.shade) end end)
  for _, g in ipairs({ { x0 + 3, top + 3 }, { x0 + 10, top + 4 }, { cx - 6, top - 6 } }) do px(g[1], g[2], "#f2f6ee") px(g[1] + 1, g[2] + 1, L.water.hi) end
  local vent = poly{ { cx - 9, top - 7 }, { cx - 3, top - 11 }, { cx - 2, top - 14 }, { cx - 8, top - 10 } }
  rimOf(vent, L.tar) fill(vent, L.water.hi) px(cx - 6, top - 11, "#f2f6ee")
end

---------------------------------------------------------------- left hero: the herbalist's whitewashed cottage
local function cottage()
  local top, cx, wallM, roofM = F.building{ x0 = 96, x1 = 182, yb = 182, wh = 46, rh = 32, wall = L.plaster, roof = L.roof, chimney = true, shingle = true, noFrame = true, noAttic = true }
  F.lichen(roofM, .07, 41)
  -- whitewash over rubble stone: a few flakes showing the stone, salt streaks, a tarred plinth
  wallM:each(function(x, y)
    if y > top + 3 and y < 176 then
      if hash(x // 3, y // 2, 46) < .025 then px(x, y, L.stone.base) if hash(x, y, 47) < .5 then px(x, y, L.stone.shade) end end
      if x > 176 and hash(x, y // 3, 48) < .4 then px(x, y, L.plaster.shade) end
    end
  end)
  -- roughcast speckle, salt streaks under the sills, shadow under the eaves, stone quoins at the corners
  wallM:each(function(x, y)
    if y > top + 3 and y < 176 then
      local v = hash(x, y, 51)
      if v < .07 then px(x, y, L.plaster.shade) elseif v > .97 then px(x, y, L.plaster.hi) end
      if y <= top + 6 then px(x, y, (y <= top + 5) and L.plaster.deep or L.plaster.shade) end
    end
  end)
  for y = top + 7, 175, 4 do
    local w = ((y - top) // 4) % 2 == 0 and 4 or 2
    for _, qx in ipairs({ 96, 182 - w + 1 }) do
      local q = rect(qx, y, qx + w - 1, y + 2) fill(q, L.stone.base) hline(qx, qx + w - 1, y, L.stone.hi) hline(qx, qx + w - 1, y + 3, L.stone.deep)
      if qx > 150 then vline(qx + w - 1, y, y + 2, L.stone.shade) end
    end
  end
  for _, sx in ipairs({ 109, 113, 163, 168 }) do for y = 164, 164 + floor(hash(sx, 1, 52) * 8) do if hash(sx, y, 53) < .7 then px(sx, y, L.plaster.shade) end end end
  -- a porthole window in the gable
  local ph = c:ellipse(cx, top - 13, 4, 4)
  rimOf(ph, L.tar) fill(ph, L.wall2.base) fill(c:ellipse(cx, top - 13, 2, 2), L.glow.base)
  px(cx - 1, top - 14, L.glow.hi) px(cx + 1, top - 12, L.glow.shade) px(cx - 3, top - 15, L.wall2.hi) px(cx + 3, top - 11, L.wall2.deep)
  local plinth = rect(96, 176, 182, 182)
  fill(plinth, L.tar.base) hline(96, 182, 176, L.tar.hi) hline(96, 182, 182, L.tar.edge)
  plinth:each(function(x, y) if y > 177 and hash(x, y, 49) < .12 then px(x, y, L.tar.shade) end if y > 179 and hash(x // 2, y, 50) < .3 then px(x, y, L.sand.shade) end end)
  -- a round sea-blue door with a brass ring and a rosemary wreath
  local d = c:rrect(130, 156, 146, 181, 8):clip(rect(130, 156, 146, 181))
  rimOf(d, L.wall2) part(d, L.wall2) c:edgeIn(d, L.wall2.edge)
  for x = 134, 143, 3 do vline(x, 160, 180, L.wall2.shade) end
  fill(c:ellipse(142, 170, 1, 1), L.gold.base) px(141, 169, L.gold.hi)
  local wr = c:ellipse(138, 163, 3, 3):cut(c:ellipse(138, 163, 1, 1))
  wr:each(function(x, y) px(x, y, (x + y) % 2 == 0 and ROS.base or ROS.shade) end) px(138, 160, L.petal.base) px(136, 166, L.petal.base) px(140, 165, LV.hi)
  F.window(106, 148, 116, 156, L.wall2) F.window(160, 148, 170, 156, L.wall2)
  -- window boxes with thrift and rosemary
  for _, wx in ipairs({ 104, 158 }) do
    local bx = rect(wx, 160, wx + 14, 163) rimOf(bx, L.tar) part(bx, L.wall2, { nopop = true })
    for k = 0, 6 do local fx = wx + 1 + k * 2
      px(fx, 158, ROS.base) px(fx + 1, 157, ROS.hi) px(fx, 159, ROS.shade)
      if k % 2 == 0 then px(fx, 156, (k % 4 == 0) and L.petal.base or L.petal.hi) px(fx + 1, 156, L.petal.shade) end
    end
  end
  -- drying bundles and dulse strings hanging from the eave pole
  hline(98, 180, top + 5, L.timber.deep)
  for k = 0, 10 do
    local x = 100 + k * 8
    if k % 4 == 3 then
      vline(x, top + 6, top + 8, L.cork.deep)
      for j = 0, 3 do local yy = top + 9 + j * 2 px(x - 1 + (j % 2), yy, DUL.base) px(x + (j % 2), yy, DUL.shade) px(x - 1 + (j % 2), yy + 1, DUL.deep) end
      px(x, top + 17, DUL.hi)
    else
      local r = ({ SAM, LV, ROS, SK })[k % 4 + 1]
      if k == 4 then r = LV elseif k == 8 then r = SK end
      vline(x, top + 5, top + 6, L.timber.edge)
      local b = poly{ { x - 2, top + 7 }, { x + 2, top + 7 }, { x + 1, top + 14 }, { x - 1, top + 14 } }
      fill(b, r.base) px(x - 1, top + 8, r.hi) px(x - 1, top + 11, r.hi) vline(x + 1, top + 9, top + 13, r.shade) hline(x - 2, x + 2, top + 7, L.cork.deep)
      px(x, top + 14, r.deep)
    end
  end
  -- hanging mortar & pestle sign on an iron bracket
  hline(184, 198, 152, L.iron.base) hline(184, 198, 153, L.iron.deep)
  vline(188, 154, 157, L.tar.edge) vline(196, 154, 157, L.tar.edge)
  local mortar = poly{ { 185, 160 }, { 199, 160 }, { 197, 167 }, { 193, 170 }, { 191, 170 }, { 187, 167 } }
  local pestle = line({ { 196, 158 }, { 201, 152 } }, 2)
  rimOf(union(mortar, pestle), L.stone) part(mortar, L.stone) part(pestle, L.board, { nopop = true })
  hline(185, 199, 160, L.stone.hi) hline(187, 197, 161, L.stone.deep)
  px(189, 159, SAM.hi) px(190, 158, SAM.base) px(192, 159, SAM.hi)
  -- a dried starfish and a string of shells over the door
  F.sprite({ "..s..", "sSSSs", ".SSS.", "s...s" }, 136, 150, { s = L.produce.base, S = L.produce.hi }, { rimCol = L.produce.edge })
  px(138, 152, L.produce.shade)
  for k = 0, 3 do F.shell(124 + k * 3, 155 + (k % 2), false) F.shell(147 + k * 3, 155 + ((k + 1) % 2), false) end
  return top
end

---------------------------------------------------------------- stone-walled raised beds in perspective (right of road)
local function bed(x0, x1, y0, y1, plant, seed)
  local soil = poly{ { x0 + 4, y0 }, { x1, y0 }, { x1 + 4, y1 }, { x0, y1 } }
  local front = rect(x0, y1, x1 + 4, y1 + 4)
  F.shadow(x0, x1 + 4, y1 + 4, 6, 2)
  rimOf(union(soil, front), L.stone)
  fill(soil, L.soil.shade)
  soil:each(function(x, y) local v = hash(x, y, seed) if v < .18 then px(x, y, L.soil.deep) elseif v > .88 then px(x, y, L.sand.shade) end end)
  -- the coping round the far edge
  hline(x0 + 4, x1, y0, L.stone.base)
  -- drystone front: two courses of flat stones, lit tops, lichen
  part(front, L.stone, { nopop = true })
  F.courses(front, y1, 2, 6, L.stone, seed)
  hline(x0, x1 + 4, y1, L.stone.hi)
  F.lichen(front, .07, seed + 20)
  local n = (x1 - x0) // 7
  for k = 0, n - 1 do plant(x0 + 6 + k * 7, y0 + (y1 - y0) // 2 + 2, k) end
end
local function seakale(x, y, k)
  -- broad wavy glaucous leaves, lit upper left, a cloud of honey-scented white flowers on alternate plants
  local m = c:ellipse(x, y - 3, 4, 3) rimOf(m, SK)
  fill(m, SK.base)
  m:each(function(xx, yy)
    local lt = (xx - x) + (yy - y + 3) * 1.4
    if lt < -2 then px(xx, yy, SK.hi) elseif lt > 2 then px(xx, yy, SK.shade) end
    if (xx + yy) % 3 == 0 and yy > y - 3 then px(xx, yy, SK.deep) end
    if not m:has(xx, yy - 1) and hash(xx, yy, 58) < .4 then px(xx, yy, THY.shade) end -- purple-tinged leaf margins
  end)
  if k % 2 == 0 then
    vline(x, y - 9, y - 6, SK.shade)
    fill(rect(x - 2, y - 10, x + 1, y - 9), L.awnB.base) px(x - 2, y - 10, L.awnB.hi) px(x - 1, y - 11, L.awnB.hi) px(x + 1, y - 9, L.awnB.shade) px(x + 2, y - 10, L.awnB.base)
  end
end
local function samphire(x, y, k)
  -- marsh samphire: little jointed candelabras of bright succulent green
  for j = -1, 1 do
    local sx, h = x + j * 2, 5 + ((j + k) % 2)
    vline(sx, y - h, y, SAM.base) px(sx, y - h, SAM.hi) px(sx, y - 2, SAM.shade)
    px(sx - 1, y - h + 2, SAM.hi) px(sx - 1, y - h + 1, SAM.hi)
    if j == 1 then px(sx + 1, y - h + 3, SAM.shade) px(sx + 1, y - h + 2, SAM.base) end
  end
  px(x - 3, y, SAM.deep) px(x + 3, y, SAM.deep) px(x, y, SAM.deep)
end
local function rosemary(x, y, k)
  -- an upright dark rosemary bush of needle strokes, pale-blue flowers
  local m = c:ellipse(x, y - 4, 3, 4) fill(m, ROS.shade)
  m:each(function(xx, yy) if (xx + yy * 2) % 3 == 0 then px(xx, yy, xx < x and ROS.hi or ROS.base) end if xx > x + 1 and yy > y - 3 then px(xx, yy, ROS.deep) end end)
  px(x - 1, y - 8, ROS.hi) px(x + 1, y - 9, ROS.base)
  px(x - 2, y - 6, BUG.hi) px(x + 1, y - 7, BUG.hi) if k % 2 == 0 then px(x, y - 4, BUG.base) end
end
local function catnip(x, y, k)
  local m = c:ellipse(x, y - 3, 3, 3) fill(m, CATN.base)
  m:each(function(xx, yy) if (xx - x) + (yy - y + 3) < 0 then px(xx, yy, CATN.hi) elseif (xx - x) + (yy - y + 3) > 2 then px(xx, yy, CATN.shade) end end)
  vline(x - 1, y - 8, y - 5, CATN.shade) px(x - 1, y - 8, LV.hi) px(x - 1, y - 7, L.awnB.hi)
  if k % 2 == 0 then vline(x + 2, y - 7, y - 5, CATN.shade) px(x + 2, y - 7, LV.hi) end
end

---------------------------------------------------------------- compose: back to front
F.depth(1)
F.tree(86, 130, 38, 0)
F.tree(14, 142, 40, 2)
glasshouse(22, 76, 140)
-- two far gnomes gathering lavender and kale
F.gnome(420, 150, { small = true, hat = L.awnA, coat = L.wall2, arm = "out" })
F.gnome(352, 138, { small = true, hat = LV, coat = L.accent, flip = true })
-- gorse and tamarisk along the left back, behind the cottage
for x = 104, 206, 10 do
  local g = F.bush(x, 134 + (x % 3), 6, 7, (x % 20 == 4) and L.foliage or L.foliage2, x)
  if x % 20 ~= 4 then g:each(function(xx, yy) if hash(xx, yy, 43 + x) < .12 then px(xx, yy, hash(xx, yy, 44) < .5 and L.gorse.base or L.gorse.hi) end end) end
end
F.depth(2)
F.tree(196, 128, 34, 2)
F.tree(282, 130, 40, 4)
arch()
-- the sea buckthorn at the right edge, heavy with orange berries
do
  local m = F.tree(458, 168, 60, 1)
  m:each(function(x, y)
    if hash(x // 2, y // 2, 61) < .2 and hash(x, y, 62) < .55 then
      px(x, y, hash(x, y, 63) < .4 and BUCK.hi or BUCK.base) if m:has(x + 1, y + 1) then px(x + 1, y + 1, BUCK.shade) end
    end
  end)
end
F.depth(3)
local ctop = cottage()
F.smoke(172, 102, 7, .9, 2)
-- herb drying A-frame rack near the road (left): driftwood legs, bundles and a garland of dulse
local function dryRack(x0, yb)
  local legs = line({ { x0, yb }, { x0 + 6, yb - 26 }, { x0 + 12, yb } }, 2):add(line({ { x0 + 30, yb }, { x0 + 36, yb - 26 }, { x0 + 42, yb } }, 2))
  local bar = rect(x0 + 4, yb - 26, x0 + 38, yb - 25)
  F.shadow(x0, x0 + 42, yb, 6, 2)
  rimOf(union(legs, bar), L.tar) part(legs, L.timber, { nopop = true, noshade = true }) part(bar, L.timber, { nopop = true, noshade = true })
  union(legs, bar):each(function(x, y) if hash(x, y // 2, 85) < .2 then px(x, y, L.timber.hi) elseif hash(x, y // 2, 86) < .12 then px(x, y, L.timber.deep) end end)
  for k = 0, 5 do
    local x = x0 + 9 + k * 5
    local r = ({ LV, SAM, ROS, SK, THY, L.foliage })[k + 1]
    vline(x, yb - 24, yb - 22, L.cork.deep)
    local b = poly{ { x - 2, yb - 21 }, { x + 2, yb - 21 }, { x + 1, yb - 12 }, { x - 1, yb - 12 } }
    rimOf(b, r) fill(b, r.base) px(x - 1, yb - 20, r.hi) px(x - 1, yb - 17, r.hi) vline(x + 1, yb - 19, yb - 13, r.shade)
    hline(x - 2, x + 2, yb - 21, L.cork.deep)
  end
  -- a sagging garland of dulse ribbons drying below
  for xx = x0 + 6, x0 + 36 do
    local t = (xx - x0 - 6) / 30
    local yy = floor(yb - 9 + 4 * 4 * t * (1 - t))
    px(xx, yy, L.cork.deep)
    if (xx - x0) % 4 == 0 then px(xx, yy + 1, DUL.base) px(xx, yy + 2, DUL.shade) px(xx + 1, yy + 3, DUL.deep) px(xx - 1, yy + 1, DUL.hi) end
  end
end
dryRack(160, 214)
-- the beds on the right, near ones larger
bed(276, 360, 166, 174, seakale, 3)
bed(282, 380, 182, 192, samphire, 4)
bed(290, 400, 202, 214, rosemary, 5)
bed(300, 376, 228, 242, catnip, 6)
-- quirk: a ginger tabby curled up asleep in the catnip at the near bed's end, a common blue on its ear
do
  F.sprite({
    "......o..o..........",
    "......oooo..........",
    "....ttttttttt.......",
    "..tTtTttTtttTtt.....",
    ".tttttttttttttttt...",
    "tTttTttTtTttwwwttt..",
    "tttttttttttwwlwwttt.",
    "tttTtttTttwwjjjwtTt.",
    ".tttttttttwwwwwwttt.",
    "..ttttttttttttttTTt.",
    "...TTTTTTTTTTTTTTt..",
  }, 334, 227, { o = L.timber.edge, t = L.produce.base, T = L.produce.shade, w = L.awnB.hi, l = L.produce.deep, j = L.produce.deep })
  for _, s in ipairs({ { 337, 230 }, { 341, 229 }, { 345, 229 }, { 336, 233 }, { 340, 232 } }) do px(s[1], s[2], L.produce.hi) end
  hline(347, 348, 233, L.timber.edge) px(345, 235, "#f08a9a")
  F.sprite({ "a.a", ".k.", "a.a" }, 339, 223, { a = BUG.hi, k = L.timber.edge }, { rim = false })
  px(338, 223, BUG.base) px(342, 223, BUG.base)
  local bub = c:ellipse(328, 222, 2, 2) fill(bub, L.water.hi) px(327, 221, "#f0f4ee")
  px(332, 225, L.water.hi)
end
-- potting table with pots, jars of buckthorn cordial, a trug of samphire
local function pottingTable()
  local top = rect(402, 172, 452, 175)
  local legs = rect(405, 176, 407, 196):add(rect(447, 176, 449, 196))
  local shelf = rect(404, 188, 450, 189)
  F.shadow(404, 452, 196, 8, 3)
  rimOf(union(top, legs, shelf), L.tar)
  part(legs, L.timber, { nopop = true, noshade = true }) part(shelf, L.timber, { nopop = true, noshade = true }) part(top, L.board)
  F.planks(top, L.board, 6, true, 21)
  for k = 0, 2 do
    local x = 406 + k * 12
    local pot = poly{ { x, 165 }, { x + 8, 165 }, { x + 7, 171 }, { x + 1, 171 } }
    rimOf(pot, L.roof2) part(pot, L.roof2, { nopop = true }) hline(x, x + 8, 165, L.roof2.hi)
    local rr = ({ SAM, ROS, LV })[k + 1]
    local pl = c:ellipse(x + 4, 161, 3, 3) fill(pl, rr.base) px(x + 3, 159, rr.hi) px(x + 2, 160, rr.hi) px(x + 6, 162, rr.shade)
    if k == 2 then px(x + 4, 158, LV.hi) px(x + 2, 159, LV.hi) end
  end
  for k = 0, 1 do
    local x = 442 + k * 6
    local jar = rect(x - 2, 164, x + 2, 171) fill(jar, L.glass.hi) fill(rect(x - 1, 167, x + 1, 171), ({ BUCK, DUL })[k + 1].base) hline(x - 2, x + 2, 164, L.cork.base) px(x - 2, 166, "#f0f4ee")
  end
  local bk = poly{ { 430, 181 }, { 446, 181 }, { 444, 187 }, { 432, 187 } }
  rimOf(bk, L.needle) part(bk, L.needle, { nopop = true }) bk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) end end)
  for k = 0, 5 do local mx = 431 + k * 3 px(mx, 180, SAM.base) px(mx + 1, 179, SAM.hi) px(mx, 179, SAM.hi) px(mx + 1, 180, SAM.shade) end
  for k = 0, 1 do local x = 408 + k * 10 local pot = rect(x, 184, x + 6, 187) fill(pot, L.roof2.shade) hline(x, x + 6, 184, L.roof2.base) end
end
pottingTable()
-- white WBC bee hives with slate roofs on little stands at the right edge
local function hives()
  for k = 0, 2 do
    local x, yb = 419 + k * 17, 224
    local legs = rect(x - 5, yb - 3, x - 4, yb):add(rect(x + 4, yb - 3, x + 5, yb))
    local floorB = rect(x - 7, yb - 5, x + 7, yb - 4)
    local board = rect(x - 9, yb - 5, x - 7, yb - 5)
    local lifts = HP.mask()
    for i = 0, 2 do local y1 = yb - 6 - i * 5 lifts:add(rect(x - 6, y1 - 4, x + 6, y1)):add(rect(x - 7, y1, x + 7, y1)) end
    local ytop = yb - 21
    local roofm = poly{ { x - 8, ytop }, { x, ytop - 6 }, { x + 8, ytop } }:add(rect(x - 8, ytop, x + 8, ytop))
    F.shadow(x - 7, x + 7, yb, 5, 2)
    rimOf(union(legs, floorB, board, lifts, roofm), L.tar)
    part(legs, L.timber, { nopop = true, noshade = true }) part(floorB, L.timber, { nopop = true, noshade = true }) fill(board, L.timber.hi)
    part(lifts, L.plaster)
    lifts:each(function(xx, yy)
      local r = (yb - 6 - yy) % 5
      if r == 0 then px(xx, yy, L.plaster.shade) elseif r == 4 then px(xx, yy, L.plaster.hi) end
      if xx >= x + 4 and r ~= 4 then px(xx, yy, L.plaster.shade) end
      if xx <= x - 4 and r == 3 then px(xx, yy, L.plaster.hi) end
    end)
    hline(x - 3, x + 3, yb - 6, L.tar.deep)
    part(roofm, L.roof, { nopop = true })
    line({ { x - 8, ytop }, { x, ytop - 6 } }):each(function(xx, yy) px(xx, yy, L.roof.hi) end)
    roofm:each(function(xx, yy) if xx > x then px(xx, yy, L.roof.shade) end end)
    hline(x - 8, x + 8, ytop, L.roof.deep)
  end
  for i = 0, 9 do local bx, by = 412 + floor(hash(i, 1, 3) * 50), 182 + floor(hash(i, 2, 3) * 18) px(bx, by, L.gold.base) px(bx + 1, by, L.timber.edge) px(bx, by - 1, L.water.hi) end
end
hives()
-- lichened stone herb spiral, bottom-left: thyme, samphire, thrift
local function spiral(cx, cy)
  F.shadow(cx - 36, cx + 40, cy + 14, 8, 3)
  local tiers = { { 40, 13, 0, THY }, { 28, 9, 9, SAM }, { 16, 6, 17, ROS } }
  for i, t in ipairs(tiers) do
    local rx, ry, up, rr = t[1], t[2], t[3], t[4]
    local top = c:ellipse(cx, cy - up - 4, rx, ry)
    local body = union(top, c:ellipse(cx, cy - up, rx, ry))
    rimOf(body, L.stone)
    local face = c:ellipse(cx, cy - up, rx, ry):cut(top)
    face:each(function(x, y)
      local k = (x + (y % 4 < 2 and 0 or 3)) % 6
      px(x, y, (k == 0 or y % 4 == 0) and L.stone.deep or ((x < cx - rx // 2) and L.stone.hi or L.stone.base))
    end)
    F.lichen(face, .12, 50 + i)
    fill(top, L.soil.shade)
    top:each(function(x, y)
      local v = hash(x, y, i * 7)
      if v < .45 then px(x, y, rr.base) elseif v < .55 then px(x, y, rr.hi) elseif v < .7 then px(x, y, rr.shade) end
      if i == 1 and hash(x, y, 77) < .06 then px(x, y, THY.hi) end
      if i == 2 and hash(x, y, 78) < .05 then px(x, y, L.petal.base) end
    end)
    c:edgeIn(top, L.stone.base)
  end
  F.thrift(cx, cy - 22, true)
  F.thrift(cx - 24, cy - 6, true) F.thrift(cx + 20, cy - 4, false) F.thrift(cx + 4, cy - 14, false)
  for _, p in ipairs({ { cx - 12, cy - 16 }, { cx + 30, cy - 5 } }) do px(p[1], p[2], L.awnB.hi) px(p[1] + 1, p[2], L.petal.hi) end
end
spiral(74, 248)
-- viper's bugloss and foxgloves along the left: swaying spires, bells on one side, big low, small to the green tip
for k, x in ipairs({ 26, 36, 46, 58, 70, 82 }) do
  local yb, h = 206 + (k % 2) * 3, 32 + floor(hash(k, 1, 5) * 20)
  local r = (k % 3 == 0) and L.petal or ((k % 3 == 1) and BUG or FX)
  local stem = (r == BUG) and L.foliage or L.fern
  local function sx(y) return x + floor(sin((yb - y) / h * 2.2 + k) * 2 * (yb - y) / h + .5) end
  for y = yb - h, yb do px(sx(y), y, stem.shade) px(sx(y) + 1, y, stem.deep) end
  local bx0 = sx(yb)
  for j, lf in ipairs({ { -9, -2 }, { -7, -6 }, { -3, -8 }, { 4, -8 }, { 8, -5 }, { 10, -1 } }) do
    local ex, ey = bx0 + lf[1], yb + lf[2] + floor(hash(j, k, 8) * 2)
    local m = line({ { bx0, yb }, { (bx0 + ex) // 2 + (lf[1] < 0 and -1 or 1), (yb + ey) // 2 - 1 }, { ex, ey } }, 2)
    c:rim(m, stem.edge) part(m, (j + k) % 3 == 0 and L.leaf or stem, { nopop = true })
    line({ { bx0, yb - 1 }, { (bx0 + ex) // 2, (yb + ey) // 2 - 2 } }):each(function(xx, yy) if m:has(xx, yy) then px(xx, yy, stem.hi) end end)
  end
  local i = 0
  for y = yb - 15, yb - h + 2, -2 do
    i = i + 1
    local t = (yb - 17 - y) / math.max(1, h - 19)
    local cx = sx(y) + 2
    if t < .7 then
      local w = t < .45 and 2 or 1
      local side = (i % 2 == 0) and 1 or -1
      local bx = (side > 0) and cx or (sx(y) - 1 - w)
      if r == BUG then side = 1 bx = (i % 2 == 0) and cx or (sx(y) - 1 - w) end
      hline(bx, bx + w, y, r.base) px(side > 0 and bx or bx + w, y, r.hi)
      hline(bx, bx + w, y + 1, r.shade) px(side > 0 and bx + w or bx, y + 1, r.edge)
      if r == BUG then px(bx + w, y - 1, DUL.hi) end -- pink buds among the blue
      if w == 2 then px(bx + 1, y + 1, r.deep) px(side > 0 and bx + w + 1 or bx - 1, y + 1, r.deep) end
    elseif t < .9 then
      px(cx - 1, y, r.base) px(cx - 1, y + 1, r.shade) px(sx(y) - 1, y, stem.base)
    else
      px(cx - 1, y, stem.base) px(sx(y) - 1, y + 1, stem.hi)
    end
  end
  px(sx(yb - h), yb - h - 1, stem.hi)
end
-- gnome harvesting with a basket of herbs
local _, gx, gy = F.gnome(268, 218, { hat = LV, coat = ROS, arm = "out" })
local bsk = poly{ { gx - 1, gy - 1 }, { gx + 11, gy - 1 }, { gx + 9, gy + 6 }, { gx + 1, gy + 6 } } rimOf(bsk, L.needle) part(bsk, L.needle)
bsk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) end end)
for k = 0, 4 do
  local col = ({ LV, SAM, BUCK, SK, ROS })[k + 1]
  px(gx + 1 + k * 2, gy - 2, col.base) px(gx + 1 + k * 2, gy - 3, col.hi)
end
-- the waterer, tipping a can over the herb spiral
local _, wx, wy = F.gnome(164, 254, { hat = L.awnA, coat = L.wall2, arm = "out", flip = true })
local wcan = rect(wx - 8, wy - 3, wx - 1, wy + 3):add(line({ { wx - 8, wy }, { wx - 14, wy - 4 } }, 2))
rimOf(wcan, L.iron) part(wcan, L.iron) fill(rect(wx - 16, wy - 6, wx - 13, wy - 4), L.iron.shade)
hline(wx - 8, wx - 1, wy - 1, L.iron.hi)
for k = 0, 4 do px(wx - 17 - k, wy - 3 + k * 2, L.water.hi) px(wx - 15 - k, wy - 2 + k * 2, L.water.base) end
-- an oystercatcher probing the path edge by the spiral
F.sprite({
  "......KKK...",
  ".....KKKKK..",
  "OOOOOKeKKKK.",
  "......KKKKKK",
  ".......WWKKK",
  "......WWWWK.",
  ".......p.p..",
  ".......p.p..",
}, 180, 222, { K = L.tar.deep, e = L.apple.base, O = L.produce.base, W = L.gull.hi, p = L.petal.shade }, { rimCol = L.tar.edge })
px(186, 225, L.produce.hi) px(191, 225, L.tar.base)
-- a ring of white shells round a chamomile patch by the cottage
do
  local pm = c:ellipse(132, 208, 12, 3)
  pm:each(function(x, y)
    local v = hash(x, y, 91)
    px(x, y, v < .5 and L.leaf.base or (v < .75 and L.leaf.shade or L.leaf.hi))
    if hash(x, y, 92) < .16 then px(x, y, L.awnB.hi) if hash(x, y, 93) < .5 then px(x, y + 1, L.gold.base) end end
  end)
  for k = 0, 11 do
    local a = k / 12 * 2 * pi
    F.shell(floor(132 + cos(a) * 15 + .5), floor(208 + sin(a) * 5 + .5), k % 3 == 0)
  end
end
F.thrift(206, 222, true) F.thrift(212, 225, false)
-- a lobster pot planted with thrift and a trug of samphire, back left by the glasshouse
do
  F.lobsterPot(40, 162, 6)
  F.thrift(37, 154, false) F.thrift(42, 153, true)
  local tr = poly{ { 52, 156 }, { 64, 156 }, { 62, 162 }, { 54, 162 } }
  rimOf(tr, L.needle) part(tr, L.needle) tr:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) end end)
  line({ { 53, 156 }, { 58, 151 }, { 63, 156 } }):each(function(x, y) if y < 156 then px(x, y, L.needle.deep) end end)
  for k = 0, 4 do px(54 + k * 2, 155, SAM.hi) px(55 + k * 2, 154, SAM.base) end
  for _, f in ipairs({ { 28, 162, 6 }, { 70, 160, 5 }, { 82, 166, 4 }, { 12, 170, 6 } }) do F.marram(f[1], f[2], f[3]) end
  F.thrift(48, 166, true) F.thrift(30, 168, false)
end
-- marram and thrift tucked along the cottage foot and the left edge
for _, f in ipairs({ { 92, 186, 6 }, { 186, 186, 5 }, { 20, 216, 7 }, { 98, 214, 5 }, { 214, 238, 6 } }) do F.marram(f[1], f[2], f[3]) end
F.thrift(90, 190, true) F.thrift(188, 190, false)
F.depth(0)
-- bees over the hives and the lavender, common-blue and white butterflies, gulls
for i = 0, 14 do local bx, by = 300 + floor(hash(i, 1, 33) * 170), 140 + floor(hash(i, 2, 33) * 80) px(bx, by, L.gold.base) px(bx + 1, by, L.timber.edge) px(bx, by - 1, L.water.hi) end
F.sprite({ "a.a", ".k.", "a.a" }, 330, 128, { a = L.awnB.hi, k = L.timber.edge }, { rim = false })
F.sprite({ "a.a", ".k.", "a.a" }, 120, 200, { a = BUG.hi, k = L.timber.edge }, { rim = false })
F.sprite({ "a.a", ".k.", "a.a" }, 240, 196, { a = L.awnB.hi, k = L.timber.edge }, { rim = false })
F.gull(330, 44, 3) F.gull(346, 38, 2) F.gull(190, 30, 2) F.gull(286, 84, 1)
-- half-barrel tubs of rosemary, fennel and sea holly, bottom-right
F.depth(3)
for k, x in ipairs({ 300, 316, 368 }) do
  local pot = poly{ { x - 7, 252 }, { x + 7, 252 }, { x + 6, 264 }, { x - 6, 264 } }
  rimOf(pot, L.tar) part(pot, L.timber)
  pot:each(function(xx, yy) if (xx - x + 7) % 3 == 0 then px(xx, yy, L.timber.deep) end end)
  hline(x - 7, x + 7, 254, L.iron.shade) hline(x - 6, x + 6, 261, L.iron.shade) hline(x - 7, x + 7, 252, L.timber.hi)
  if k == 2 then
    -- fennel: tall feathery stems, flat yellow umbels
    vline(x, 230, 252, SAM.shade) vline(x + 4, 236, 252, SAM.shade)
    for y = 238, 250, 3 do px(x - 1, y, SAM.base) px(x - 2, y - 1, SAM.hi) px(x + 1, y + 1, SAM.base) px(x + 5, y, SAM.hi) end
    for _, u in ipairs({ { x, 229, 3 }, { x + 4, 235, 2 } }) do
      hline(u[1] - u[3], u[1] + u[3], u[2], L.gold.base) hline(u[1] - u[3] + 1, u[1] + u[3] - 1, u[2] - 1, L.gold.hi)
      px(u[1] - u[3], u[2] + 1, SAM.shade) px(u[1] + u[3], u[2] + 1, SAM.shade)
    end
  elseif k == 1 then
    -- rosemary bush spilling over the rim
    local m = c:ellipse(x, 246, 7, 6):clip(rect(x - 8, 238, x + 8, 252))
    rimOf(m, ROS) part(m, ROS)
    m:each(function(xx, yy) if (xx + yy * 2) % 3 == 0 then px(xx, yy, xx < x and ROS.hi or ROS.shade) end if hash(xx, yy, 95) < .06 then px(xx, yy, BUG.hi) end end)
  else
    -- sea holly: spiny silver-blue leaves, round blue thistle heads
    for _, s in ipairs({ { -4, -1 }, { 0, 0 }, { 4, -1 } }) do
      local sx = x + s[1]
      vline(sx, 240 + s[2], 251, SK.shade)
      local hd = c:ellipse(sx, 239 + s[2], 1, 1) fill(hd, BUG.shade) px(sx - 1, 238 + s[2], BUG.hi)
      hline(sx - 2, sx + 2, 241 + s[2], SK.hi) px(sx - 2, 240 + s[2], SK.base) px(sx + 2, 240 + s[2], SK.base)
    end
    for _, l in ipairs({ { -6, 249 }, { 3, 247 }, { -2, 250 } }) do hline(x + l[1], x + l[1] + 4, l[2], SK.base) px(x + l[1], l[2] - 1, SK.hi) px(x + l[1] + 2, l[2] - 1, SK.hi) px(x + l[1] + 4, l[2] - 1, SK.deep) end
  end
end
F.finish()
