-- herb.lua : "Herb garden" stop look, ISLAND (island_palm), 480x270 gate view.
-- Same composition as the Maplewold herb (art-2701-batch3/stops/opus3/herb.lua), re-cast for a coral island:
-- right: rows of lemongrass fountains and red torch-ginger running back to the shore (replaces the lavender),
-- two far gnomes cutting. Road's end: a bamboo arch smothered in magenta bougainvillea, a lattice gate ajar,
-- between a banana and a coconut palm. Back left: a bamboo shade house with a slatted palm-leaf roof, hanging
-- orchids. Left hero: the herbalist's thatched hut on a black lava platform, woven pandanus walls, rolled mat
-- blinds, drying lemongrass / turmeric / chilli / noni bundles under the eave, a lava mortar-and-pestle sign.
-- Raised coral-rock beds (aloe, turmeric-ginger, chillies, purple basil), a bamboo potting table with coconut-shell
-- pots, palm-log bee hives with thatch caps, a coral-rock herb spiral, torch-ginger and heliconia spires along the
-- left, terracotta pots of noni and lemongrass, ti plants, a junglefowl, a gecko, crabs and shells.
-- Quirk: a pink island piglet asleep in the basil bed wearing a red gnome hat, a blue butterfly on the hat tip.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-island-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "herb", out = DIR, farTrees = { 24, 52, 160, 196, 440 }, treeLineGap = { 206, 270 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local HAZE = "#d4ecee"
-- local ramps
local LG = F.rp("#f2f4b0 #cede78 #9cb852 #6e8e40 #46622e")    -- lemongrass, pale gold-green
local GIN = F.rp("#ffb4a8 #f2546a #c82c50 #8e1c40 #561432")   -- red torch ginger
local BOUG = F.rp("#ffc2ec #f070cc #c840a8 #8c2a84 #561a54")  -- bougainvillea magenta
local ALOE = F.rp("#d0f0d8 #92ccb4 #62a498 #427c7a #285056")  -- aloe blue-green
local NONI = F.rp("#f8f6d8 #e0e0b0 #b8ba8a #868e68 #565e46")  -- noni fruit, pale warty
local CR = F.rp("#fdeee0 #eccab4 #ca9e8c #9c726a #66484c")    -- pink-cream coral rock (beds, spiral)
local BAS = F.rp("#d6b4f0 #a07ad2 #7454ae #50388a #32245e")   -- purple basil spikes
local PIG = F.rp("#ffe0da #f8b8b0 #dc8c88 #aa6266 #6c4048")   -- piglet
local TI = F.rp("#ffa6c4 #e0567e #a8345e #742448 #48182e")    -- ti plant / croton red
local POT = F.rp("#f6b48c #dc8458 #b06040 #804432 #4e2a22")   -- terracotta

---------------------------------------------------------------- right: lemongrass and torch-ginger rows to the shore
-- Rows run across the view; band height grows with nearness (d^2 / C). Thin far rows are a solid hazed band with
-- horizontal texture only (no shimmer); near rows are fountain clumps (lemongrass) or glossy ginger with red torches.
local C = 190
local function rowOf(y) return floor(C / (y - 109)) end
for y = 114, 160 do
  local row = rowOf(y)
  local y0 = y while y0 > 114 and rowOf(y0 - 1) == row do y0 = y0 - 1 end
  local y1 = y while y1 < 160 and rowOf(y1 + 1) == row do y1 = y1 + 1 end
  local hgt = y1 - y0 + 1
  local ginger = row % 3 == 1
  local R = ginger and L.foliage2 or LG
  local farC = F.mix(R.base, HAZE, .4)
  for x = 262, 479 do
    if x > F.xr(y) + 6 then
      local h
      if hgt < 3 then
        h = (y % 2 == 0) and F.mix(R.shade, HAZE, .35) or farC
        if hash(x // 4, y, 3) < .15 then h = F.mix(ginger and GIN.base or R.hi, HAZE, .35) end
      else
        local bw0 = math.max(5, floor(hgt * 1.6))
        local xx = x + row * 3
        local bi = xx // bw0
        local fx = (xx % bw0) / bw0
        local hk = .3 + .4 * hash(bi, row, 16)
        local ty = y0 + floor(hgt * hk * (1 - math.sqrt(math.max(0, 1 - (2 * fx - 1) ^ 2))) + .5)
        if not ginger and hgt > 3 then ty = math.max(y0, ty + ((xx % 2 == 0) and 0 or 1) - (hash(xx, row, 21) < .3 and 1 or 0)) end
        local ry = (y - y0) / hgt
        local v = hash(x, y, 18 + row)
        if y < ty then
          h = (ry < .2) and L.mossGround.deep or L.ground.shade
          if hash(x, y, 12) < .15 then h = L.ground.deep end
          if ginger and y == ty - 1 and hgt > 3 and hash(bi, row, 19) < .55 and xx == bi * bw0 + floor((.3 + .4 * hash(bi, row, 23)) * bw0) then h = GIN.hi end
        elseif y == y1 then h = L.soil.shade
        elseif ginger then
          -- glossy dark lance leaves, lit upper left, red torch heads poking up
          local lit = (1 - fx) * .8 - ry * 1.1 + (v - .5) * .6
          if lit > .5 then h = L.foliage2.hi elseif lit > 0 then h = L.foliage2.base elseif lit > -.45 then h = L.foliage2.shade else h = L.foliage2.deep end
          if (xx % 3 == 0) and y > ty + 1 and lit > -.3 then h = L.foliage2.shade end
          local tc = bi * bw0 + floor((.3 + .4 * hash(bi, row, 23)) * bw0)
          local dx = xx - tc
          if hash(bi, row, 19) < .55 and hgt > 3 then
            if y == ty and abs(dx) <= 1 then h = dx < 0 and GIN.hi or (dx == 0 and GIN.base or GIN.shade)
            elseif y == ty + 1 and abs(dx) <= 1 then h = dx < 1 and GIN.base or GIN.shade
            elseif y == ty + 2 and abs(dx) <= 2 and hgt > 5 then h = dx < 0 and GIN.base or GIN.deep end
          end
        else
          -- lemongrass: fountain of thin blades, pale tips, darker vertical blade lines, red-brown base stalks
          local blade = (xx + floor(ry * 3 * (fx - .5) * 2)) % 2 == 0
          if y == ty then h = fx < .55 and LG.hi or LG.base
          elseif ry < .45 then h = blade and (fx < .5 and LG.hi or LG.base) or (fx < .6 and LG.base or LG.shade)
          elseif ry < .8 then h = blade and LG.base or LG.shade
          else h = (xx % 2 == 0) and L.roof2.shade or LG.deep end
          if fx > .78 and ry > .2 then h = LG.shade end
          if v > .95 and ry < .7 then h = L.roof.base end -- dry blades
        end
      end
      px(x, y, h)
    end
  end
end
-- a low edging of coral-rock pieces closing the near edge of the field, beach grass poking over it
for x = 262, 479 do
  if x > F.xr(161) + 4 then
    local k = (x + floor(hash(x // 5, 0, 5) * 3)) % 6
    px(x, 162, CR.edge) px(x, 161, k == 0 and CR.deep or CR.shade) px(x, 160, k == 0 and CR.deep or (hash(x, 160, 6) < .2 and CR.deep or CR.base))
    px(x, 159, k == 0 and CR.edge or CR.hi)
    if hash(x, 158, 8) < .18 then px(x, 158, L.mossGround.hi) px(x, 157, L.mossGround.base) end
  end
end

---------------------------------------------------------------- road's end: bamboo arch with bougainvillea
local function arch()
  local pL, pR = rect(216, 76, 219, 126), rect(261, 76, 264, 126)
  local top = c:ellipse(240, 80, 24, 18):cut(c:ellipse(240, 80, 20, 14)):clip(rect(214, 58, 266, 80))
  F.shadow(216, 266, 126, 6, 3)
  local frame = union(pL, pR, top)
  rimOf(frame, L.board)
  part(frame, L.board, { nopop = true, noshade = true })
  -- bamboo: lit left lip, dark right seam, node rings
  frame:each(function(x, y)
    if not frame:has(x + 1, y) then px(x, y, L.board.deep) elseif not frame:has(x - 1, y) or not frame:has(x, y - 1) then px(x, y, L.board.hi) end
    if (y % 7 == 0) and (x < 220 or x > 260) then px(x, y, L.board.shade) end
  end)
  for _, y in ipairs({ 84, 98, 112 }) do hline(215, 220, y, L.rope.base) hline(260, 265, y, L.rope.base) px(215, y + 1, L.rope.deep) px(260, y + 1, L.rope.deep) end
  -- bamboo lattice gate, ajar
  local gate = HP.mask()
  for _, xx in ipairs({ 222, 237 }) do gate:add(rect(xx, 108, xx + 1, 124)) end
  gate:add(rect(222, 109, 238, 110)):add(rect(222, 121, 238, 122))
  for xx = 225, 235, 3 do gate:add(rect(xx, 111, xx, 120)) end
  gate:add(line({ { 223, 120 }, { 236, 111 } }))
  rimOf(gate, L.timber) part(gate, L.board, { nopop = true, noshade = true })
  gate:each(function(x, y) if y == 109 or y == 121 then px(x, y, L.board.hi) elseif (y % 5 == 0) then px(x, y, L.board.shade) end end)
  for _, xx in ipairs({ 222, 237 }) do px(xx, 108, L.board.hi) end
  -- bougainvillea: dark leaf clumps along the arch and posts, smothered in magenta bracts
  local clumps = { { 214, 120 }, { 219, 113 }, { 220, 104 }, { 214, 96 }, { 218, 87 }, { 221, 78 }, { 225, 69 }, { 231, 63 }, { 240, 60 }, { 249, 62 }, { 255, 67 }, { 260, 76 }, { 263, 86 }, { 267, 95 }, { 261, 104 }, { 264, 112 }, { 267, 120 } }
  for i, p in ipairs(clumps) do
    local m = F.crown(p[1], p[2], 5, 4, L.foliage2, 120 + i)
    -- bract clusters: little 2x2 magenta bunches, lit upper left, on the sunny side of each clump
    m:each(function(x, y)
      local d = (x - p[1]) + (y - p[2])
      local v = hash((x + i) // 2, (y + (x // 2) % 2) // 2, 130)
      if d < 4 and v < .6 and m:has(x, y - 1) or (d < 0 and v < .6) then
        local lit = not m:has(x - 1, y) or not m:has(x, y - 1) or hash(x, y, 131) < .3
        px(x, y, lit and (d < 0 and BOUG.hi or BOUG.base) or (d > 1 and BOUG.shade or BOUG.base))
        if v < .08 then px(x, y, BOUG.deep) end
      end
    end)
  end
  -- trailing bougainvillea hanging off the crown of the arch
  for _, t in ipairs({ { 229, 68, 8 }, { 251, 68, 10 }, { 240, 64, 5 }, { 223, 82, 6 } }) do
    for k = 0, t[3] do
      local xx = t[1] + floor(sin(k * .9) + .5)
      px(xx, t[2] + k, k % 3 == 0 and L.foliage2.base or L.foliage2.deep)
      if k % 2 == 1 then px(xx + 1, t[2] + k, k % 4 == 1 and BOUG.base or BOUG.shade) end
    end
    px(t[1], t[2] + t[3] + 1, BOUG.hi)
  end
  -- fallen bracts at the foot
  for i = 0, 10 do local x, y = 210 + floor(hash(i, 1, 140) * 60), 124 + floor(hash(i, 2, 140) * 6) if not F.roadM:has(x, y) or hash(i, 3, 140) < .5 then px(x, y, hash(i, 4, 140) < .5 and BOUG.base or BOUG.hi) end end
end

---------------------------------------------------------------- back-left: bamboo shade house, slatted palm-leaf roof, hanging orchids
local function shadeHouse(x0, x1, yb)
  local wh, rh = 20, 14
  local top, cx = yb - wh, (x0 + x1) // 2
  local wall = rect(x0, top, x1, yb)
  local roofm = poly{ { x0 - 2, top + 1 }, { cx, top - rh }, { x1 + 2, top + 1 } }
  local sill = rect(x0 - 1, yb - 4, x1 + 1, yb)
  F.shadow(x0 + 2, x1, yb, 8, 4)
  rimOf(union(wall, roofm, sill), L.timber)
  -- dappled green shade inside, striped by the light through the slats
  wall:each(function(x, y) px(x, y, ((y + x // 3) % 4 == 0) and L.foliage2.shade or L.foliage2.deep) end)
  -- benches of seedlings and orchids in coconut-husk baskets
  hline(x0 + 1, x1 - 1, yb - 7, L.board.shade) hline(x0 + 1, x1 - 1, yb - 6, L.board.deep)
  for x = x0 + 3, x1 - 3, 5 do
    local m = c:ellipse(x, yb - 10, 2, 3)
    fill(m, L.leaf.base) px(x - 1, yb - 12, L.leaf.hi) px(x + 1, yb - 8, L.leaf.shade)
  end
  for k, x in ipairs({ x0 + 6, x0 + 16, x0 + 26, x0 + 38, x0 + 48 }) do
    vline(x, top + 1, top + 4, L.rope.shade)
    fill(rect(x - 2, top + 5, x + 2, top + 7), L.coconut.base) hline(x - 2, x + 2, top + 5, L.coconut.hi) px(x + 2, top + 7, L.coconut.deep)
    local col = (k % 2 == 0) and L.petal or L.shell
    px(x - 2, top + 9, col.base) px(x - 3, top + 9, col.hi) px(x - 2, top + 10, col.shade) px(x + 1, top + 10, col.base) px(x + 2, top + 11, col.shade) px(x + 1, top + 11, L.leaf.base)
    px(x - 1, top + 8, L.leaf.shade) px(x, top + 8, L.leaf.base)
  end
  -- lava-block sill
  part(sill, L.lava) F.courses(sill, yb - 4, 2, 6, L.lava)
  -- bamboo posts and rails
  local poles = HP.mask()
  for x = x0, x1, 9 do poles:add(rect(x, top, x + 1, yb - 5)) end
  poles:add(rect(x0, top, x1, top + 1))
  part(poles, L.board, { nopop = true, noshade = true })
  poles:each(function(x, y) if not poles:has(x + 1, y) or y == top + 1 then px(x, y, L.board.deep) end if y % 6 == 0 then px(x, y, L.board.shade) end end)
  -- slatted roof: strips of dried palm leaf with sky-bright gaps
  roofm:each(function(x, y)
    local k = (x - cx + (y * 2)) % 5
    if k <= 2 then px(x, y, (k == 0) and L.roof.hi or L.roof.base) elseif k == 3 then px(x, y, L.roof.shade) else px(x, y, L.foliage2.deep) end
  end)
  line({ { x0 - 2, top + 1 }, { cx, top - rh } }):each(function(x, y) px(x, y, L.board.hi) end)
  line({ { cx, top - rh }, { x1 + 2, top + 1 } }):each(function(x, y) px(x, y, L.board.deep) end)
  hline(x0 - 2, x1 + 2, top + 1, L.board.shade)
  -- a frond laid along the ridge
  F.frond(cx - 14, top - rh + 6, -.45, 16, .1, L.foliage, 151, { wide = .25 })
end

---------------------------------------------------------------- left hero: the herbalist's thatched hut on a lava platform
local function weave(m, r)
  m:each(function(x, y)
    local a, b = (x + y) // 3, (x - y) // 3
    local over = (a + b) % 2 == 0
    local k = over and ((x + y) % 3) or ((x - y) % 3)
    local h = over and (k == 0 and r.hi or r.base) or (k == 2 and r.deep or r.shade)
    px(x, y, h)
  end)
end
local function hut()
  local top, cx, wallM, roofM = F.building{ x0 = 96, x1 = 182, yb = 176, wh = 40, rh = 34, wall = L.rope, roof = L.roof, noAttic = true, noFrame = true }
  -- the lava-stone platform the hut stands on, three steps up to the door
  local plat = rect(90, 176, 188, 186)
  local steps = rect(128, 186, 148, 189):add(rect(130, 189, 146, 192))
  rimOf(union(plat, steps), L.lava)
  part(plat, L.lava, { nopop = true }) F.courses(plat, 176, 5, 9, L.lava)
  part(steps, L.lava, { nopop = true }) hline(128, 148, 186, L.lava.hi) hline(130, 146, 189, L.lava.hi)
  plat:each(function(x, y) if hash(x, y, 70) < .1 then px(x, y, L.lava.deep) elseif y == 176 then px(x, y, L.lava.hi) end end)
  -- woven pandanus walls between bamboo corner posts
  weave(wallM:copy():clip(rect(96, top + 4, 182, 175)), L.rope)
  local posts = rect(96, top + 3, 99, 175):add(rect(179, top + 3, 182, 175)):add(rect(124, top + 3, 126, 175)):add(rect(152, top + 3, 154, 175))
  part(posts, L.board, { nopop = true, noshade = true }) F.bamboo(posts, L.board, 4)
  hline(96, 182, 174, L.timber.deep) hline(96, 182, 175, L.lava.deep)
  -- bamboo gable with a smoke vent
  local gableM = poly{ { 101, top }, { cx, top - 34 + 8 }, { 177, top } }
  F.bamboo(gableM, L.board, 3)
  local vent = rect(cx - 4, top - 18, cx + 3, top - 13)
  fill(vent, L.soil.deep) hline(cx - 4, cx + 3, top - 18, L.timber.deep) vline(cx, top - 18, top - 13, L.board.shade)
  -- extra-deep thatch: a second lower skirt of palm thatch over the eave, and a frond ridge
  local skirt = poly{ { 92, top + 1 }, { 186, top + 1 }, { 188, top + 7 }, { 90, top + 7 } }
  rimOf(skirt, L.roof) part(skirt, L.roof, { nopop = true })
  skirt:each(function(x, y)
    if y == top + 7 or (y == top + 6 and hash(x, 0, 160) < .5) then px(x, y, L.roof.deep)
    elseif (x * 2 + y) % 3 == 0 then px(x, y, L.roof.shade) elseif y == top + 2 and hash(x, y, 161) < .5 then px(x, y, L.roof.hi) end
  end)
  -- ragged strand ends hanging off the skirt
  for x = 91, 187, 2 do if hash(x, 1, 162) < .6 then px(x, top + 8, L.roof.deep) if hash(x, 2, 162) < .4 then px(x, top + 9, L.roof.shade) end end end
  -- ridge bundle tied with rope, sprouting little frond tips at the apex
  for k = -1, 1 do F.frond(cx, top - 34 + 1, -pi / 2 + k * .9, 8, .2, L.foliage, 170 + k, { wide = .25 }) end
  -- a rolled-up mat blind over each window, warm interior below
  for _, wx in ipairs({ 104, 158 }) do
    local w = rect(wx, 154, wx + 14, 165)
    fill(rect(wx - 1, 153, wx + 15, 166), L.timber.deep)
    fill(w, L.glow.shade) fill(rect(wx, 156, wx + 14, 159), L.glow.base) px(wx + 1, 156, L.glow.hi) px(wx + 2, 156, L.glow.hi)
    vline(wx + 7, 156, 165, L.timber.base)
    local roll = c:rrect(wx - 2, 151, wx + 16, 155, 2)
    rimOf(roll, L.rope) part(roll, L.rope, { nopop = true }) hline(wx - 1, wx + 15, 152, L.rope.hi) hline(wx - 1, wx + 15, 155, L.rope.deep)
    for x = wx - 1, wx + 15, 3 do px(x, 153, L.rope.shade) end
    vline(wx + 1, 156, 158, L.rope.shade) vline(wx + 13, 156, 158, L.rope.shade)
  end
  -- window boxes of coconut-husk with marigold and basil
  for _, wx in ipairs({ 104, 158 }) do
    local bx = rect(wx - 1, 167, wx + 15, 170) rimOf(bx, L.coconut) part(bx, L.coconut, { nopop = true })
    bx:each(function(x, y) if (x + y) % 2 == 0 then px(x, y, L.coconut.shade) end end)
    for k = 0, 6 do local fx = wx + 1 + k * 2
      px(fx, 166, L.leaf.base) px(fx + 1, 165, L.leaf.hi)
      if k % 2 == 0 then px(fx, 164, (k % 4 == 0) and L.produce.base or BAS.base) px(fx, 163, (k % 4 == 0) and L.produce.hi or BAS.hi) end
    end
  end
  -- turquoise plank door under a carved lintel
  local d = rect(130, 148, 146, 175)
  rimOf(d, L.wall2) part(d, L.wall2) c:edgeIn(d, L.wall2.edge)
  for x = 133, 143, 3 do vline(x, 150, 174, L.wall2.shade) end
  hline(131, 145, 160, L.wall2.deep) hline(131, 145, 161, L.wall2.hi)
  fill(c:ellipse(142, 163, 1, 1), L.gold.base) px(141, 162, L.gold.hi)
  local lintel = rect(127, 144, 149, 147)
  rimOf(lintel, L.timber) part(lintel, L.timber, { nopop = true, noshade = true }) hline(127, 149, 144, L.timber.hi)
  for x = 129, 147, 4 do px(x, 145, L.timber.deep) px(x + 1, 146, L.timber.deep) end -- carved zigzag
  -- a plumeria lei over the door
  for k = 0, 8 do local x = 131 + k * 2 local y = 148 + floor(3 * sin(k / 8 * pi) + .5) px(x, y, (k % 2 == 0) and L.petal.base or L.shell.hi) px(x + 1, y, L.gold.base) end
  -- drying bundles and strings hanging from the eave pole
  hline(96, 182, top + 9, L.timber.deep)
  for k = 0, 10 do
    local x = 100 + k * 8
    if k % 4 == 3 then
      -- a string of red chillies
      vline(x, top + 10, top + 18, L.rope.deep)
      for j = 0, 2 do local yy = top + 11 + j * 3 px(x - 1, yy, L.awnA.hi) px(x - 1, yy + 1, L.awnA.base) px(x + 1, yy, L.awnA.base) px(x + 1, yy + 1, L.awnA.shade) px(x + 1, yy + 2, L.awnA.deep) end
    elseif k % 4 == 1 then
      -- a knot of turmeric and ginger roots in a net
      vline(x, top + 10, top + 12, L.rope.deep)
      local m = c:ellipse(x, top + 15, 3, 3) rimOf(m, L.produce) fill(m, L.produce.base)
      m:each(function(xx, yy) if (xx + yy) % 2 == 0 then px(xx, yy, L.produce.shade) end if xx < x and yy < top + 15 then px(xx, yy, L.produce.hi) end end)
      px(x + 2, top + 17, L.needle.base) px(x - 2, top + 14, L.needle.hi)
    else
      local r = ({ LG, nil, ALOE, nil })[k % 4 + 1] or LG
      if k % 8 == 2 then r = ALOE elseif k % 8 == 6 then r = L.leaf end
      vline(x, top + 10, top + 11, L.timber.edge)
      local b = poly{ { x - 2, top + 12 }, { x + 2, top + 12 }, { x + 1, top + 19 }, { x - 1, top + 19 } }
      rimOf(b, r) fill(b, r.base) px(x - 1, top + 13, r.hi) px(x - 1, top + 16, r.hi) vline(x + 1, top + 14, top + 18, r.shade)
      hline(x - 2, x + 2, top + 13, L.rope.base) px(x, top + 19, r.deep)
    end
  end
  -- a cowrie-shell string along the fascia
  for x = 92, 186, 3 do px(x, top + 8 + ((x // 3) % 2), L.shell.hi) end
  -- hanging lava mortar & pestle sign on a driftwood bracket
  hline(184, 198, 152, L.timber.base) hline(184, 198, 153, L.timber.deep) px(184, 152, L.timber.hi)
  vline(188, 154, 157, L.rope.shade) vline(196, 154, 157, L.rope.shade)
  local mortar = poly{ { 185, 160 }, { 199, 160 }, { 197, 167 }, { 193, 170 }, { 191, 170 }, { 187, 167 } }
  local pestle = line({ { 196, 158 }, { 201, 152 } }, 2)
  rimOf(union(mortar, pestle), L.lava) part(mortar, L.lava) part(pestle, L.timber, { nopop = true })
  hline(185, 199, 160, L.lava.hi) hline(187, 197, 161, L.lava.deep)
  mortar:each(function(x, y) if hash(x, y, 171) < .12 and y > 161 then px(x, y, L.lava.deep) end end)
  px(189, 159, L.leaf.hi) px(190, 158, L.leaf.base) px(192, 159, L.leaf.hi) px(191, 158, GIN.base)
  -- a gecko on the wall by the door
  F.sprite({ "g...g", ".ggg.", "..g..", ".ggg.", "g.g.g", "..g..", "..g..", "...g." }, 118, 158,
    { g = L.foliage.base }, { rim = true })
  px(120, 158, L.foliage.hi) px(119, 159, L.timber.edge)
  return top
end

---------------------------------------------------------------- raised coral-rock beds in perspective (right of road)
local function bed(x0, x1, y0, y1, plant, seed)
  local soil = poly{ { x0 + 4, y0 }, { x1, y0 }, { x1 + 4, y1 }, { x0, y1 } }
  local front = rect(x0, y1, x1 + 4, y1 + 4)
  F.shadow(x0, x1 + 4, y1 + 4, 6, 2)
  rimOf(union(soil, front), CR)
  fill(soil, L.soil.base)
  soil:each(function(x, y) local v = hash(x, y, seed) if v < .18 then px(x, y, L.soil.deep) elseif v > .92 then px(x, y, L.soil.hi) end end)
  -- rounded coral-rock blocks: lit tops, pores, the odd black lava block
  front:each(function(x, y)
    local bi = (x - x0 + (seed * 3)) // 6
    local bx = (x - x0 + (seed * 3)) % 6
    local lava = hash(bi, seed, 180) < .14
    local r = lava and L.lava or CR
    local h = r.base
    if bx == 0 then h = r.edge elseif y == y1 then h = r.hi elseif y == y1 + 4 then h = r.deep elseif bx == 5 or y == y1 + 3 then h = r.shade end
    if h == r.base and hash(x, y, seed + 181) < .18 then h = r.shade end
    if not lava and h == r.base and hash(x, y, seed + 182) < .06 then h = L.coral.base end
    px(x, y, h)
  end)
  hline(x0 + 4, x1, y0, CR.shade)
  local n = (x1 - x0) // 7
  for k = 0, n - 1 do plant(x0 + 6 + k * 7, y0 + (y1 - y0) // 2 + 2, k) end
end
local function aloe(x, y, k)
  -- a rosette of thick spiky blue-green leaves, pale spots, lit on their upper-left edge
  local leaves = { { -4, -3 }, { -3, -6 }, { -1, -7 }, { 1, -7 }, { 3, -5 }, { 4, -2 } }
  for j, lf in ipairs(leaves) do
    local m = line({ { x, y - 1 }, { x + lf[1], y + lf[2] } }, 1)
    m:each(function(xx, yy) px(xx, yy, lf[1] < 0 and ALOE.hi or (lf[1] > 1 and ALOE.shade or ALOE.base)) end)
    px(x + lf[1], y + lf[2], ALOE.deep)
  end
  hline(x - 2, x + 2, y, ALOE.shade) hline(x - 1, x + 1, y - 1, ALOE.base) px(x - 1, y - 2, ALOE.hi)
  if k % 2 == 0 then px(x - 2, y - 3, ALOE.hi) end
  if k % 3 == 1 then vline(x + 1, y - 12, y - 8, L.leaf.shade) px(x + 1, y - 13, L.hibiscus.hi) px(x + 1, y - 12, L.hibiscus.base) px(x + 2, y - 11, L.hibiscus.base) end
end
local function turmeric(x, y, k)
  -- tall lance leaves fanning up; a pink-cream turmeric bloom or a red ginger cone now and then
  for j, a in ipairs({ -2.0, -1.6, -1.25, -.95 }) do
    local len = 7 + (j % 2)
    local ex, ey = x + floor(cos(a) * len + .5), y + floor(sin(a) * len + .5)
    local m = line({ { x, y }, { ex, ey } }, 1)
    m:each(function(xx, yy) px(xx, yy, j <= 2 and L.leaf.base or L.leaf.shade) end)
    px(ex, ey, j <= 2 and L.leaf.hi or L.leaf.base)
    px(ex + 1, ey + 1, L.leaf.deep)
  end
  px(x - 1, y, L.produce.base) px(x + 1, y, L.produce.shade) -- the orange root shoulder in the soil
  if k % 3 == 0 then px(x, y - 4, L.petal.hi) px(x, y - 3, L.petal.base) px(x + 1, y - 3, L.shell.hi) end
  if k % 3 == 2 then vline(x + 2, y - 3, y, L.leaf.deep) px(x + 2, y - 5, GIN.hi) px(x + 2, y - 4, GIN.base) px(x + 3, y - 4, GIN.shade) end
end
local function chilli(x, y, k)
  local m = c:ellipse(x, y - 4, 3, 3)
  fill(m, L.foliage2.base)
  m:each(function(xx, yy) if (xx - x) + (yy - y + 4) < -1 then px(xx, yy, L.foliage2.hi) elseif (xx - x) + (yy - y + 4) > 2 then px(xx, yy, L.foliage2.deep) end end)
  vline(x, y - 1, y, L.foliage2.shade)
  local cols = { L.awnA, L.hibiscus, L.gold }
  for j, p in ipairs({ { -2, -2 }, { 1, -3 }, { 2, 0 }, { -1, 1 } }) do
    if (j + k) % 4 ~= 0 then
      local r = cols[(j + k) % 3 + 1]
      px(x + p[1], y - 4 + p[2] + 2, r.base) px(x + p[1], y - 4 + p[2] + 3, r.shade) px(x + p[1], y - 4 + p[2] + 1, L.foliage.shade)
    end
  end
end
local function basil(x, y, k)
  local m = c:ellipse(x, y - 3, 3, 3)
  fill(m, L.foliage.base)
  m:each(function(xx, yy) if (xx - x) + (yy - y + 3) < 0 then px(xx, yy, L.foliage.hi) elseif (xx - x) + (yy - y + 3) > 2 then px(xx, yy, L.foliage.shade) end end)
  vline(x - 1, y - 8, y - 5, BAS.shade) px(x - 1, y - 8, BAS.hi) px(x - 1, y - 7, BAS.base) px(x - 2, y - 6, BAS.base)
  if k % 2 == 0 then vline(x + 2, y - 7, y - 5, BAS.shade) px(x + 2, y - 7, BAS.hi) px(x + 3, y - 6, BAS.base) end
end

---------------------------------------------------------------- compose: back to front
F.depth(1)
F.palm(86, 130, 40, L.foliage, 4, { lean = -9 })
F.tree(14, 142, 44, 3)
shadeHouse(22, 76, 140)
-- two far gnomes cutting lemongrass and ginger
F.gnome(420, 150, { small = true, hat = L.awnA, coat = L.wall2, arm = "out" })
F.gnome(352, 138, { small = true, hat = L.roof, coat = L.hibiscus, flip = true })
-- hibiscus and croton hedge along the left back, behind the hut
for x = 104, 206, 10 do
  if (x // 10) % 3 == 1 then
    local m = F.bush(x, 134 + (x % 3), 6, 7, L.leaf, x)
    m:each(function(xx, yy) local v = hash(xx, yy, x) if v < .22 then px(xx, yy, v < .1 and L.gold.base or TI.base) end end) -- croton
  else F.hibiscus(x, 134 + (x % 3), 6, 7, x, (x % 20 == 4) and "orange" or "hibiscus") end
end
F.depth(2)
F.tree(204, 128, 46, 1)
F.palm(282, 130, 46, L.foliage2, 6, { lean = 10 })
arch()
F.palm(458, 168, 62, L.foliage, 8, { lean = -14 })
F.depth(3)
local htop = hut()
F.smoke(139, htop - 20, 6, .5, 2)
-- herb drying A-frame rack near the road (left), bamboo, bundles and a hanging lei of noni fruit
local function dryRack(x0, yb)
  local legs = line({ { x0, yb }, { x0 + 6, yb - 26 }, { x0 + 12, yb } }, 2):add(line({ { x0 + 30, yb }, { x0 + 36, yb - 26 }, { x0 + 42, yb } }, 2))
  local bar = rect(x0 + 4, yb - 26, x0 + 38, yb - 25)
  F.shadow(x0, x0 + 42, yb, 6, 2)
  rimOf(union(legs, bar), L.timber) part(legs, L.board, { nopop = true, noshade = true }) part(bar, L.board, { nopop = true, noshade = true })
  hline(x0 + 4, x0 + 38, yb - 26, L.board.hi)
  union(legs, bar):each(function(x, y) if (x + y) % 7 == 0 then px(x, y, L.board.deep) end end)
  for _, lx in ipairs({ x0 + 5, x0 + 35 }) do hline(lx, lx + 2, yb - 25, L.rope.base) end
  for k = 0, 5 do
    local x = x0 + 9 + k * 5
    local r = ({ LG, ALOE, L.produce, L.leaf, GIN, LG })[k + 1]
    vline(x, yb - 24, yb - 22, L.timber.edge)
    local b = poly{ { x - 2, yb - 21 }, { x + 2, yb - 21 }, { x + 1, yb - 12 }, { x - 1, yb - 12 } }
    rimOf(b, r) fill(b, r.base) px(x - 1, yb - 20, r.hi) px(x - 1, yb - 17, r.hi) vline(x + 1, yb - 19, yb - 13, r.shade)
    hline(x - 2, x + 2, yb - 21, L.rope.shade)
  end
  -- a sagging string of noni fruit below
  for xx = x0 + 6, x0 + 36 do
    local t = (xx - x0 - 6) / 30
    local yy = floor(yb - 9 + 4 * 4 * t * (1 - t))
    px(xx, yy, L.rope.deep)
    if (xx - x0) % 5 == 0 then
      local m = c:ellipse(xx, yy + 2, 1, 2) c:rim(m, NONI.edge) fill(m, NONI.base) px(xx - 1, yy + 1, NONI.hi) px(xx, yy + 3, NONI.shade) px(xx + 1, yy + 2, NONI.deep)
    end
  end
end
dryRack(160, 214)
-- the beds on the right, near ones larger
bed(276, 360, 166, 174, aloe, 3)
bed(282, 380, 182, 192, turmeric, 4)
bed(290, 400, 202, 214, chilli, 5)
bed(300, 376, 228, 242, basil, 6)
-- quirk: a pink piglet asleep in the basil at the near bed's end, in a red gnome hat, a blue butterfly on the hat tip
do
  F.sprite({
    "...................R..",
    "..................RRr.",
    ".................RRRr.",
    ".................RRRr.",
    "................RRRRr.",
    "...............RRRRRr.",
    "..............RRRRRRr.",
    ".............hhhhhhhhh",
    ".....ppppppppEEpppppp.",
    "...pPpppppppEEppppppppp",
    "..ppppppppppppppkkpppssp",
    ".pppppppppppppppppppsnsp",
    "tpppppppppppppppppppsssp",
    ".tpppppppppppppppppppp..",
    "..PPPPPPPPPPPPPPPPPPP...",
    "...PP.PP........PP.PP...",
  }, 330, 219, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, p = PIG.base, P = PIG.shade, E = PIG.shade,
    k = L.timber.edge, s = PIG.hi, n = PIG.deep, t = PIG.shade })
  -- lit back and belly shading
  for _, s in ipairs({ { 335, 228 }, { 336, 228 }, { 337, 228 }, { 340, 227 }, { 341, 227 }, { 334, 229 }, { 338, 227 } }) do px(s[1], s[2], PIG.hi) end
  hline(334, 349, 231, PIG.shade) px(332, 230, PIG.shade)
  px(344, 225, L.awnA.hi) px(345, 224, L.awnA.hi) px(346, 223, L.awnA.hi) px(347, 221, L.awnA.hi) px(347, 222, L.awnA.hi) hline(344, 350, 225, L.awnA.shade) px(349, 219, L.awnA.hi) -- hat lit edge, band
  px(331, 232, PIG.deep) px(330, 230, PIG.deep) -- tail curl
  -- a blue morpho-ish butterfly on the hat tip
  F.sprite({ "a.a", ".k.", "a.a" }, 349, 216, { a = "#3c78c8", k = L.timber.edge }, { rim = false })
  px(348, 216, "#6aa2e6") px(352, 216, "#6aa2e6")
  -- sleepy bubble
  local bub = c:ellipse(358, 221, 2, 2) fill(bub, L.lagoon.hi) px(357, 220, "#f2faf4")
  px(356, 224, L.lagoon.hi)
end
-- bamboo potting table with coconut-shell pots, bottles of oil, a basket of ginger root
local function pottingTable()
  local top = rect(402, 172, 452, 175)
  local legs = rect(405, 176, 407, 196):add(rect(447, 176, 449, 196))
  local shelf = rect(404, 188, 450, 190)
  F.shadow(404, 452, 196, 8, 3)
  rimOf(union(top, legs, shelf), L.timber)
  part(legs, L.board, { nopop = true, noshade = true }) part(shelf, L.board, { nopop = true, noshade = true }) part(top, L.board)
  F.bamboo(top, L.board, 2, { horizontal = true }) F.bamboo(shelf, L.board, 2, { horizontal = true }) F.bamboo(legs, L.board, 3)
  for k = 0, 2 do
    local x = 406 + k * 12
    local pot = c:ellipse(x + 4, 168, 4, 3):clip(rect(x, 166, x + 8, 171))
    rimOf(pot, L.coconut) part(pot, L.coconut, { nopop = true }) hline(x + 1, x + 7, 166, L.coconut.hi)
    pot:each(function(xx, yy) if (xx * 3 + yy) % 4 == 0 then px(xx, yy, L.coconut.deep) end end)
    local rr = ({ ALOE, L.leaf, BAS })[k + 1]
    if k == 0 then
      for _, d in ipairs({ { -3, -4 }, { -1, -6 }, { 1, -6 }, { 3, -4 } }) do line({ { x + 4, 165 }, { x + 4 + d[1], 165 + d[2] } }):each(function(xx, yy) px(xx, yy, d[1] < 0 and ALOE.hi or ALOE.base) end) end
    else
      local pl = c:ellipse(x + 4, 162, 3, 3) fill(pl, rr.base) px(x + 3, 160, rr.hi) px(x + 2, 161, rr.hi) px(x + 6, 163, rr.shade)
    end
  end
  for k = 0, 1 do
    local x = 442 + k * 6
    local jar = rect(x - 2, 164, x + 2, 171) fill(jar, L.lagoon.hi) fill(rect(x - 1, 167, x + 1, 171), ({ L.gold, NONI })[k + 1].base)
    hline(x - 1, x + 1, 162, L.timber.base) hline(x - 1, x + 1, 163, L.lagoon.base) px(x - 2, 166, "#f2faf4")
  end
  -- a woven basket of ginger root on the shelf, terracotta pots stacked
  local bk = poly{ { 430, 182 }, { 446, 182 }, { 444, 187 }, { 432, 187 } }
  rimOf(bk, L.rope) part(bk, L.rope, { nopop = true }) bk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.rope.shade) end end)
  for k = 0, 4 do local mx = 432 + k * 3 px(mx, 181, L.needle.base) px(mx + 1, 181, L.needle.hi) px(mx, 180, L.produce.base) end
  for k = 0, 1 do local x = 408 + k * 10 local pot = rect(x, 183, x + 6, 187) fill(pot, POT.shade) hline(x, x + 6, 183, POT.base) px(x, 184, POT.hi) end
end
pottingTable()
-- palm-log bee hives with thatch caps on a lava-block bench at the right edge
local function hives()
  local bench = rect(410, 214, 462, 217)
  local feet = rect(412, 218, 418, 224):add(rect(454, 218, 460, 224))
  F.shadow(410, 462, 224, 6, 2)
  rimOf(union(bench, feet), L.lava) part(bench, L.lava, { nopop = true }) part(feet, L.lava, { nopop = true })
  F.courses(union(bench, feet), 214, 4, 7, L.lava)
  for k = 0, 2 do
    local x = 420 + k * 16
    local hb = c:rrect(x - 6, 199, x + 6, 213, 3)
    local cap = poly{ { x - 9, 201 }, { x - 3, 192 }, { x + 3, 192 }, { x + 9, 201 } }
    rimOf(union(hb, cap), L.palmTrunk)
    part(hb, L.palmTrunk)
    -- palm-trunk rings, lit left
    hb:each(function(xx, yy)
      if (yy + k) % 3 == 0 then px(xx, yy, (xx < x - 2) and L.palmTrunk.base or L.palmTrunk.deep)
      elseif xx < x - 3 then px(xx, yy, L.palmTrunk.hi) elseif xx > x + 3 then px(xx, yy, L.palmTrunk.shade) end
    end)
    part(cap, L.roof, { nopop = true }) F.thatch(cap, L.roof, 192, x)
    hline(x - 9, x + 9, 201, L.roof.deep) hline(x - 2, x + 2, 192, L.roof.hi)
    for xx = x - 9, x + 9, 2 do if hash(xx, k, 190) < .5 then px(xx, 202, L.roof.shade) end end
    fill(c:ellipse(x, 209, 1, 1), L.timber.edge) hline(x - 2, x + 2, 211, L.board.base)
  end
  for i = 0, 7 do local bx, by = 414 + floor(hash(i, 1, 3) * 48), 180 + floor(hash(i, 2, 3) * 12) px(bx, by, L.gold.base) px(bx + 1, by, L.timber.edge) px(bx, by - 1, L.lagoon.hi) end
end
hives()
-- coral-rock herb spiral, bottom-left: gotu kola, purple basil, aloe on top
local function spiral(cx, cy)
  F.shadow(cx - 36, cx + 40, cy + 14, 8, 3)
  local tiers = { { 40, 13, 0, L.foliage }, { 28, 9, 9, BAS }, { 16, 6, 17, ALOE } }
  for i, t in ipairs(tiers) do
    local rx, ry, up, rr = t[1], t[2], t[3], t[4]
    local top = c:ellipse(cx, cy - up - 4, rx, ry)
    local body = union(top, c:ellipse(cx, cy - up, rx, ry))
    rimOf(body, CR)
    local face = c:ellipse(cx, cy - up, rx, ry):cut(top)
    face:each(function(x, y)
      local bi = (x + (y % 4 < 2 and 0 or 3)) // 6
      local k = (x + (y % 4 < 2 and 0 or 3)) % 6
      local lava = hash(bi, y // 4, 200 + i) < .12
      local r = lava and L.lava or CR
      local h = (k == 0 or y % 4 == 0) and r.deep or ((x < cx - rx // 2) and r.hi or r.base)
      if h == r.base and hash(x, y, 201) < .15 then h = r.shade end
      if not lava and h ~= r.deep and hash(x, y, 202) < .05 then h = L.coral.base end
      px(x, y, h)
    end)
    fill(top, L.soil.shade)
    top:each(function(x, y)
      local v = hash(x, y, i * 7)
      if i == 3 then
        if (x + y) % 3 == 0 or v < .3 then px(x, y, (x < cx) and ALOE.hi or ALOE.base) elseif v < .6 then px(x, y, ALOE.shade) end
      elseif v < .45 then px(x, y, rr.base) elseif v < .55 then px(x, y, rr.hi) elseif v < .7 then px(x, y, rr.shade) end
      if i == 1 and hash(x, y, 77) < .04 then px(x, y, L.petal.base) end
    end)
    c:edgeIn(top, CR.base)
  end
  -- an aloe crown on top, a staghorn coral and shells set in the rockwork
  for _, d in ipairs({ { -5, -6 }, { -3, -9 }, { 0, -10 }, { 3, -9 }, { 5, -6 }, { -1, -8 } }) do
    local m = line({ { cx, cy - 22 }, { cx + d[1], cy - 22 + d[2] } }, 1)
    c:rim(m, ALOE.edge)
    m:each(function(xx, yy) px(xx, yy, d[1] < 0 and ALOE.hi or (d[1] > 2 and ALOE.shade or ALOE.base)) end)
  end
  px(cx, cy - 33, L.hibiscus.base) px(cx, cy - 34, L.hibiscus.hi) vline(cx, cy - 32, cy - 31, L.leaf.shade)
  F.coral(cx + 30, cy - 2, 6)
  F.shell(cx - 30, cy - 2, "conch", true) F.shell(cx + 12, cy + 4, "cowrie") F.shell(cx - 12, cy - 12, "scallop")
end
spiral(74, 248)
-- torch ginger and heliconia along the left: reed stems with long leaves, waxy red torches / lobster claws
for k, x in ipairs({ 26, 36, 46, 58, 70, 82 }) do
  local yb, h = 206 + (k % 2) * 3, 32 + floor(hash(k, 1, 5) * 20)
  local function sx(y) return x + floor(sin((yb - y) / h * 2.2 + k) * 2 * (yb - y) / h + .5) end
  for y = yb - h, yb do px(sx(y), y, L.foliage2.shade) px(sx(y) + 1, y, L.foliage2.deep) end
  for y = yb - h + 2, yb, 4 do px(sx(y), y, L.foliage2.deep) end
  -- long paddle leaves from the stem, alternating sides, lit on the upper edge
  for j = 0, 2 do
    local y = yb - 6 - j * floor(h / 4)
    local s = ((j + k) % 2 == 0) and -1 or 1
    local ex, ey = sx(y) + s * (7 - j), y - 5 + j
    local m = line({ { sx(y), y }, { (sx(y) + ex) // 2 + s, (y + ey) // 2 - 1 }, { ex, ey } }, 2)
    c:rim(m, L.foliage2.edge) part(m, (j % 2 == 0) and L.foliage2 or L.leaf, { nopop = true })
    line({ { sx(y), y - 1 }, { (sx(y) + ex) // 2, (y + ey) // 2 - 2 } }):each(function(xx, yy) if m:has(xx, yy) then px(xx, yy, L.leaf.hi) end end)
  end
  local tx, ty = sx(yb - h), yb - h
  if k % 2 == 1 then
    -- torch ginger: a fat waxy cone of red bracts, petal tips lighter, a ring of open bracts below
    local cone = poly{ { tx - 3, ty }, { tx - 3, ty - 4 }, { tx - 1, ty - 8 }, { tx, ty - 9 }, { tx + 1, ty - 8 }, { tx + 3, ty - 4 }, { tx + 3, ty } }
    local ring = poly{ { tx - 7, ty + 1 }, { tx - 3, ty - 1 }, { tx + 3, ty - 1 }, { tx + 7, ty + 1 }, { tx + 3, ty + 3 }, { tx - 3, ty + 3 } }
    local m = union(cone, ring)
    c:rim(m, GIN.edge)
    ring:each(function(xx, yy) px(xx, yy, (xx < tx) and (yy <= ty and GIN.hi or GIN.base) or (yy <= ty and GIN.base or GIN.shade)) end)
    px(tx - 7, ty + 1, GIN.hi) px(tx + 7, ty + 1, GIN.shade)
    -- waxy bract scales, each one lit on its upper-left lip
    cone:each(function(xx, yy)
      local row = (ty - yy) // 2
      local k = (xx - tx + row) % 2
      local hh = (k == 0) and GIN.base or GIN.shade
      if (ty - yy) % 2 == 1 and k == 0 then hh = (xx <= tx) and GIN.hi or GIN.base end
      if xx >= tx + 2 then hh = (k == 0) and GIN.shade or GIN.deep end
      px(xx, yy, hh)
    end)
    px(tx - 1, ty - 7, L.shell.hi) px(tx, ty - 9, GIN.hi)
  else
    -- heliconia: upright lobster claws stepping up the stem, red with gold tips and green lips
    for j = 0, 3 do
      local yy = ty + 4 + j * 4
      local s = (j % 2 == 0) and -1 or 1
      local bx = sx(yy) + s
      local claw = poly{ { bx, yy + 2 }, { bx + s * 3, yy }, { bx + s * 6, yy - 4 }, { bx + s * 6, yy - 6 }, { bx + s * 4, yy - 3 }, { bx + s, yy - 1 } }
      c:rim(claw, L.awnA.edge) fill(claw, L.awnA.base)
      claw:each(function(xx, yy2) if yy2 < yy - 1 + (xx - bx) * s * -.5 + 2 then px(xx, yy2, L.awnA.hi) end end)
      px(bx + s * 6, yy - 6, L.gold.hi) px(bx + s * 6, yy - 5, L.gold.base) px(bx + s * 5, yy - 4, L.gold.base) px(bx + s * 4, yy - 2, L.leaf.hi)
      px(bx + s, yy + 1, L.leaf.base) px(bx + s * 2, yy + 1, L.awnA.shade) px(bx + s * 3, yy, L.awnA.shade)
    end
  end
end
-- gnome harvesting with a woven pandanus basket of lemongrass and ginger
local _, gx, gy = F.gnome(268, 218, { hat = L.awnA, coat = L.foliage2, arm = "out" })
local bsk = poly{ { gx - 1, gy - 1 }, { gx + 11, gy - 1 }, { gx + 9, gy + 6 }, { gx + 1, gy + 6 } } rimOf(bsk, L.rope) part(bsk, L.rope)
bsk:each(function(x, y) if ((x // 2 + y // 2) % 2 == 0) then px(x, y, L.rope.shade) end end)
for k = 0, 4 do
  local col = ({ LG, L.produce, GIN, LG, L.leaf })[k + 1]
  px(gx + 1 + k * 2, gy - 2, col.base) px(gx + 1 + k * 2, gy - 3, col.hi)
  if col == LG then px(gx + 1 + k * 2, gy - 4, LG.base) px(gx + 1 + k * 2, gy - 5, LG.hi) end
end
-- the waterer, tipping a calabash gourd over the herb spiral
local _, wx, wy = F.gnome(164, 254, { hat = L.hibiscus, coat = L.wall2, arm = "out", flip = true })
local gourd = c:ellipse(wx - 5, wy, 4, 3):add(line({ { wx - 8, wy - 1 }, { wx - 13, wy - 4 } }, 2))
rimOf(gourd, L.needle) part(gourd, L.needle)
gourd:each(function(x, y) if x < wx - 6 and y < wy then px(x, y, L.needle.hi) end end)
hline(wx - 8, wx - 2, wy + 1, L.needle.deep)
for k = 0, 4 do px(wx - 15 - k, wy - 3 + k * 2, L.lagoon.hi) px(wx - 14 - k, wy - 2 + k * 2, L.lagoon.base) end
-- a hermit crab in a cowrie trundling past the spiral
F.sprite({
  "...sSsS.....",
  "..SsSsSsS...",
  ".sShsSsSsS..",
  "SsSsSsSsSscc",
  ".bbbbbbbbccc",
  "..l..l..l...",
}, 172, 257, { s = L.shell.base, S = L.shell.shade, h = L.shell.hi, b = L.coconut.base, c = L.hibiscus.base, l = L.hibiscus.deep })
px(181, 259, L.timber.edge) px(182, 259, L.timber.edge)
-- a junglefowl rooster scratching by the hut steps, a scatter of fallen hibiscus and coconuts
F.hen(112, 206, L.hibiscus, false)
px(105, 199, L.foliage2.base) px(104, 198, L.foliage2.deep) px(106, 198, "#3c78c8") -- tail sheen
F.hen(124, 210, L.coconut, true)
for _, f in ipairs({ { 200, 224, "hibiscus" }, { 206, 228, "orange" }, { 96, 214, "plumeria" }, { 150, 200, "hibiscus" } }) do F.flower(f[1], f[2], f[3], true) end
F.coconut(212, 226, 3) F.coconut(218, 228, 2, true)
-- a lava boulder with a coconut-shell bowl of cut lemongrass, back left by the shade house
do
  F.lavaRock(40, 162, 7, 9, 210)
  local bowl = c:ellipse(58, 159, 6, 3):clip(rect(52, 157, 64, 162))
  rimOf(bowl, L.coconut) part(bowl, L.coconut, { nopop = true }) hline(53, 63, 157, L.coconut.hi)
  for k = 0, 5 do
    local x = 53 + k * 2
    vline(x, 150 + (k % 2), 156, (k % 2 == 0) and LG.base or LG.shade) px(x, 149 + (k % 2), LG.hi) px(x + 1, 151, LG.deep)
  end
  for _, f in ipairs({ { 28, 162, 6 }, { 70, 160, 5 }, { 82, 166, 4 }, { 12, 170, 6 } }) do F.fern(f[1], f[2], f[3]) end
  F.shell(48, 165, "scallop", true) F.crab(32, 168, L.awnA)
end
-- ti plants: fans of red-purple strap leaves along the hut foot and the left edge
local function tiPlant(x, yb, s)
  vline(x, yb - s, yb, L.timber.base) px(x - 1, yb - s, L.timber.hi)
  for j, a in ipairs({ -2.6, -2.1, -1.6, -1.1, -.6, -1.85, -1.35 }) do
    local len = s + 2 + (j % 3)
    local ex, ey = x + floor(cos(a) * len + .5), yb - s + floor(sin(a) * len * .8 + .5) + floor(len * .25)
    local m = line({ { x, yb - s }, { (x + ex) // 2, (yb - s + ey) // 2 - 2 }, { ex, ey } }, 1)
    c:rim(m, TI.edge)
    m:each(function(xx, yy) px(xx, yy, (a < -1.6) and TI.base or TI.shade) end)
    px(ex, ey, TI.deep)
    if a < -1.9 then px((x + ex) // 2, (yb - s + ey) // 2 - 2, TI.hi) end
  end
end
for _, t in ipairs({ { 92, 190, 6 }, { 186, 190, 5 }, { 20, 218, 7 }, { 214, 240, 6 } }) do tiPlant(t[1], t[2], t[3]) end
F.fern(98, 216, 5) F.fern(14, 236, 6)
F.depth(0)
-- bees over the hives and the rows, blue and orange butterflies, seabirds
for i = 0, 14 do local bx, by = 300 + floor(hash(i, 1, 33) * 170), 140 + floor(hash(i, 2, 33) * 80) px(bx, by, L.gold.base) px(bx + 1, by, L.timber.edge) px(bx, by - 1, L.lagoon.hi) end
F.sprite({ "a.a", ".k.", "a.a" }, 330, 128, { a = L.hibiscus.base, k = L.timber.edge }, { rim = false })
F.sprite({ "a.a", ".k.", "a.a" }, 120, 196, { a = "#3c78c8", k = L.timber.edge }, { rim = false })
F.sprite({ "a.a", ".k.", "a.a" }, 240, 196, { a = L.gold.hi, k = L.timber.edge }, { rim = false })
F.birds({ { 330, 44, 2 }, { 344, 40, 1 }, { 150, 66, 2 } })
-- terracotta pots of noni and lemongrass, bottom-right (clear of the compass corner)
F.depth(3)
for k, x in ipairs({ 300, 316, 368 }) do
  local pot = poly{ { x - 7, 252 }, { x + 7, 252 }, { x + 5, 264 }, { x - 5, 264 } }
  rimOf(pot, POT) part(pot, POT)
  hline(x - 7, x + 7, 252, POT.hi) hline(x - 7, x + 7, 254, POT.deep) hline(x - 6, x + 6, 255, POT.shade)
  for xx = x - 5, x + 5 do px(xx, 258 + (xx % 2), POT.deep) px(xx, 257 + (xx % 2), (xx < x) and POT.hi or POT.base) end -- a pressed zigzag band
  if k == 2 then
    -- lemongrass fountain
    for j = -5, 5 do
      local ex, ey = x + j * 2, 252 - 16 + abs(j) * 2
      line({ { x + floor(j / 2), 251 }, { x + j, 252 - 10 }, { ex, ey } }):each(function(xx, yy) px(xx, yy, (j < 0) and LG.hi or ((j % 2 == 0) and LG.base or LG.shade)) end)
    end
    vline(x - 1, 247, 251, L.roof2.shade) vline(x + 1, 247, 251, L.roof2.deep)
  else
    -- a little noni tree: glossy leaves, warty pale fruit, white star flowers
    vline(x, 238, 251, L.timber.base) px(x - 1, 245, L.timber.hi)
    local m = F.crown(x, 234 - k, 7, 6, L.foliage2, 220 + k)
    for _, f in ipairs({ { -3, 1 }, { 3, 3 }, { 0, 5 } }) do
      local fx, fy = x + f[1], 234 - k + f[2]
      local fm = c:ellipse(fx, fy, 1, 2) c:rim(fm, NONI.edge) fill(fm, NONI.base) px(fx - 1, fy - 1, NONI.hi) px(fx - 1, fy, NONI.hi) px(fx + 1, fy + 1, NONI.shade) px(fx + 1, fy, NONI.shade) px(fx, fy + 2, NONI.shade)
      px(fx, fy - 3, L.foliage2.deep)
    end
    px(x - 4, 230 - k, L.shell.hi) px(x + 4, 231 - k, L.shell.hi)
  end
end
F.shell(332, 258, "conch", true) F.crab(342, 266, L.hibiscus, true)
F.finish()
