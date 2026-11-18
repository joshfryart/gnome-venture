-- herb.lua : "Herb garden" stop look, WETLAND (wetland_reed), 480x270 gate view.
-- Same composition as the Maplewold herb (art-2701-batch3/stops/opus3/herb.lua), re-cast for a reed fen:
-- right: a flooded cranberry bog running back to the carr, rows of wine-red cranberry, water mint and sweet flag
-- between bright sky-filled ditches, closed by a woven wattle hurdle; two far gnomes, one wading with a rake.
-- Road's end: a living-willow withy arch sprouting leaves and catkins, bindweed trumpets, a wattle hurdle gate ajar,
-- reed sheaves bound at its feet. Back left: a glasshouse with silvered frames and a half-rolled reed-mat blind,
-- on a dyke bank. Left hero: the herbalist's stilt hut, grey-green weatherboard, golden reed thatch with a sedge
-- ridge, on a deck over a pool; drying bundles and cranberry strings under the eave, reed sheaves on the deck,
-- a round green door, a mortar-and-pestle sign. Raised peat-turf beds standing in a flooded bog garden (sweet flag,
-- cranberry, marsh marigold, water mint) with plank bridges, a potting bench, rush skeps under sedge hackles,
-- a mossy herb spiral with its pond at the foot, flag iris and purple loosestrife along the left, wicker baskets of
-- meadowsweet, sweet flag and mint, mallards, a kingfisher, dragonflies, frogs.
-- Quirk: an otter in a red gnome hat asleep curled in the water-mint bed, a dragonfly resting on the hat tip.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-wetland-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "herb", out = DIR, farTrees = { 24, 52, 160, 196, 440 }, treeLineGap = { 206, 270 }, poolK = .79 }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local HAZE = "#dad5bf"
local SKY = F.SKYREF
-- local ramps (hi base shade deep edge)
local CRAN = F.rp("#f6a4a0 #dc4a54 #ac2a44 #741e36 #461628")   -- cranberries
local CRANL = F.rp("#bc8a6c #946050 #6e3e44 #4c2834 #2e1a26")  -- bronze-wine cranberry runners
local MINT = F.rp("#c6deb2 #96be8e #6a9674 #4a705c #2e4a40")   -- water mint, blue-green
local MFL = F.rp("#ead8f2 #c8a8de #9c7cba #705692 #483660")    -- mint flower whorls, lilac
local FLAG = F.rp("#d8e092 #acc060 #7e9848 #586e3a #364628")   -- sweet flag / iris sword leaves
local LOOSE = F.rp("#f6b8de #e274b6 #b64c94 #84326e #52204a")  -- purple loosestrife
local MSW = F.rp("#f6eed2 #e4d8ae #c4b48a #948866 #5e5644")    -- meadowsweet cream plumes
local OTTER = F.rp("#bc9470 #94694a #6e4c36 #4c3226 #2c1c18")
local KING = F.rp("#8ad4e8 #3ca2cc #2a78a4 #1e5478 #14344e")   -- kingfisher blue

-- a tied reed sheaf standing: tapering bundle, stalk stripes, a band, a plume tuft on top
local function sheaf(x, yb, h, r)
  r = r or L.reed
  local w = math.max(2, h // 4)
  local m = poly{ { x - w, yb }, { x + w, yb }, { x + w - 1, yb - h + 2 }, { x, yb - h }, { x - w + 1, yb - h + 2 } }
  rimOf(m, r)
  part(m, r, { nopop = true })
  m:each(function(xx, yy) if (xx - x) % 2 == 0 and yy > yb - h + 2 then px(xx, yy, xx < x and r.hi or r.shade) end end)
  local by = yb - floor(h * .45)
  hline(x - w, x + w, by, L.timber.deep) hline(x - w + 1, x + w - 1, by - 1, L.timber.base)
  px(x, yb - h - 1, L.plume.base) px(x - 1, yb - h, L.plume.hi)
  return m
end

---------------------------------------------------------------- right: a flooded cranberry bog to the carr
-- Rows run across the view; band depth grows with nearness (d^2 / C). Thin far rows are a solid hazed band with
-- only horizontal texture (no shimmer). Each near row is a crop mound with a sky-filled ditch along its near edge.
local C = 190
local function rowOf(y) return floor(C / (y - 109)) end
for y = 114, 160 do
  local row = rowOf(y)
  local y0 = y while y0 > 114 and rowOf(y0 - 1) == row do y0 = y0 - 1 end
  local y1 = y while y1 < 160 and rowOf(y1 + 1) == row do y1 = y1 + 1 end
  local hgt = y1 - y0 + 1
  local kind = row % 3 -- 0 cranberry, 1 water mint, 2 sweet flag
  local R = kind == 0 and CRANL or (kind == 1 and MINT or FLAG)
  local farC = F.mix(R.base, HAZE, .4)
  for x = 262, 479 do
    if x > F.xr(y) + 6 then
      local h
      local v = hash(x, y, 18 + row)
      if hgt < 3 then
        if y == y1 and hgt == 2 then h = (hash(x // 6, y, 4) < .6) and F.mix(SKY, HAZE, .3) or F.mix(L.water.base, HAZE, .4)
        else
          h = (y % 2 == 0) and F.mix(R.shade, HAZE, .35) or farC
          if hash(x // 4, y, 3) < .15 then h = F.mix(kind == 0 and CRAN.base or R.hi, HAZE, .3) end
        end
      else
        local wet = (y == y1) or (hgt > 6 and y == y1 - 1)
        local bw0 = math.max(5, floor(hgt * 1.6))
        local xx = x + row * 3
        local bi = xx // bw0
        local fx = (xx % bw0) / bw0
        local ry = (y - y0) / math.max(1, hgt - 2)
        if wet then
          -- the ditch: the sky's gold in long streaks, dark under the crop's lip
          if y == y1 - 1 or (hgt <= 6 and hash(x, y, 5) < .2) then h = L.water.shade
          else
            local s = hash((x + row * 7) // (5 + hgt), y, 43)
            h = s < .55 and SKY or (s < .85 and L.water.base or L.water.hi)
          end
          if hgt > 6 and y == y1 - 1 then h = (hash(x // 3, y, 6) < .35) and L.water.base or L.water.deep end
        elseif kind == 2 then
          -- sweet flag: upright sword blades, spiky tops, striped lit/shaded
          local ty = y0 + floor((hgt - 2) * .55 * hash(x, row, 19))
          if y < ty then h = (ry < .25) and L.peat.deep or L.peat.shade
          elseif y == ty then h = FLAG.hi
          else
            local k = (x + floor((y - y0) * .3)) % 3
            h = k == 0 and FLAG.hi or (k == 1 and FLAG.base or FLAG.shade)
            if ry > .75 then h = (k == 0) and FLAG.shade or FLAG.deep end
          end
        else
          local hk = (kind == 0 and .22 or .32) + .3 * hash(bi, row, 16)
          local ty = y0 + floor((hgt - 1) * hk * (1 - math.sqrt(math.max(0, 1 - (2 * fx - 1) ^ 2))) + .5)
          if y < ty then
            h = (ry < .2) and L.peat.deep or L.peat.shade
            if hash(x, y, 12) < .1 then h = SKY end -- flood water glinting between the mats
          else
            local lit = (1 - fx) * .8 - ry * 1.1 + (v - .5) * .7
            if kind == 0 then
              if y == ty then h = (fx < .55) and CRANL.hi or CRANL.base
              elseif lit > .4 then h = CRANL.hi elseif lit > -.1 then h = CRANL.base elseif lit > -.5 then h = CRANL.shade else h = CRANL.deep end
              if y > ty and hash(x, y, 14) < (hgt > 5 and .16 or .1) then h = (lit > 0) and CRAN.hi or CRAN.base end
              if y > ty and hash(x, y, 15) < .05 then h = CRAN.shade end
            else
              if y == ty then h = (fx < .55) and MINT.hi or MINT.base
              elseif lit > .4 then h = MINT.hi elseif lit > -.1 then h = MINT.base elseif lit > -.5 then h = MINT.shade else h = MINT.deep end
              if (y == ty or y == ty + 1) and (x + row) % 2 == 0 and fx > .1 and fx < .9 then h = (y == ty) and MFL.hi or MFL.base end
            end
            if ry > .85 then h = R.deep end
          end
        end
      end
      px(x, y, h)
    end
  end
end
-- a woven wattle hurdle closing the near edge of the bog, stakes poking up, a reed fringe in front
for x = 262, 479 do
  if x > F.xr(161) + 4 then
    for y = 158, 162 do
      local k = ((x // 3) + y) % 2
      px(x, y, y == 162 and L.timber.edge or (k == 0 and L.willowBark.hi or L.willowBark.shade))
    end
    if (x // 3) % 2 == 0 then px(x, 160, L.willowBark.base) end
    if x % 9 == 0 then vline(x, 155, 162, L.timber.deep) px(x, 155, L.timber.hi) vline(x + 1, 156, 161, L.timber.edge) end
  end
end

---------------------------------------------------------------- road's end: living willow withy arch
L.petal = F.rp("#fbe2e2 #f0b8c0 #cc8696 #94566a #5e2c40")
local function arch()
  local pL, pR = rect(216, 76, 219, 126), rect(261, 76, 264, 126)
  local top = c:ellipse(240, 80, 24, 18):cut(c:ellipse(240, 80, 20, 14)):clip(rect(214, 58, 266, 80))
  F.shadow(216, 266, 126, 6, 3)
  local frame = union(pL, pR, top)
  local wb = L.willowBark
  rimOf(frame, wb)
  part(frame, wb, { nopop = true, noshade = true })
  -- withies twisted round each other: diagonal plait, lit on the upper left
  frame:each(function(x, y)
    local k = (x + y) % 4
    if k == 0 then px(x, y, wb.deep) elseif k == 1 then px(x, y, wb.hi) end
    if not frame:has(x + 1, y) then px(x, y, wb.shade) end
    if not frame:has(x - 1, y) and k ~= 0 then px(x, y, wb.hi) end
  end)
  -- a wattle hurdle gate, ajar: stakes woven through with withies
  local gm = poly{ { 222, 108 }, { 238, 110 }, { 238, 124 }, { 222, 124 } }
  rimOf(gm, wb)
  gm:each(function(x, y)
    local k = ((x // 2) + (y // 2)) % 2
    px(x, y, k == 0 and wb.hi or wb.base)
    if (y // 2) % 2 == 1 and x % 2 == 0 then px(x, y, wb.shade) end
  end)
  for _, xx in ipairs({ 222, 230, 237 }) do vline(xx, 107, 124, L.timber.deep) px(xx, 106, L.timber.base) end
  -- reed sheaves bound at the feet of both posts
  sheaf(212, 127, 16) sheaf(268, 127, 16) sheaf(209, 128, 12) sheaf(271, 128, 12)
  -- living willow: leafy sprouts along the arch with silver catkins, bindweed trumpets
  local clumps = { { 214, 112 }, { 220, 98 }, { 214, 86 }, { 220, 74 }, { 226, 64 }, { 236, 60 }, { 246, 60 }, { 255, 65 }, { 262, 76 }, { 266, 90 }, { 260, 102 }, { 266, 114 } }
  for i, p in ipairs(clumps) do
    F.crown(p[1], p[2], 5, 4, (i % 2 == 0) and L.willow or L.reedGreen, 100 + i)
    if i % 3 == 0 then
      local bx, by = p[1] - 1, p[2] - 1
      px(bx, by, L.petal.hi) px(bx + 1, by, L.petal.base) px(bx, by + 1, L.petal.base) px(bx + 1, by + 1, L.petal.shade) px(bx + 2, by - 1, L.petal.hi)
    else
      local cx, cy = p[1] + (i % 2 == 0 and -2 or 2), p[2] + 1
      px(cx, cy, MSW.hi) px(cx, cy + 1, MSW.base) px(cx + 1, cy + 2, L.marigold.hi)
    end
  end
  -- whippy shoots springing up off the crown, trailing strands
  for _, s in ipairs({ { 232, 58, -1 }, { 244, 57, 1 }, { 252, 60, 1 }, { 226, 62, -1 } }) do
    for k = 0, 6 do px(s[1] + floor(s[3] * k * .4), s[2] - k, k % 2 == 0 and L.willow.base or L.willow.hi) end
  end
  for _, t in ipairs({ { 230, 70, 8 }, { 250, 69, 10 }, { 240, 66, 6 } }) do
    for k = 0, t[3] do px(t[1] + floor(sin(k * .9) + .5), t[2] + k, k % 3 == 0 and L.willow.hi or L.willow.shade) end
  end
end

---------------------------------------------------------------- back-left: glasshouse on the dyke bank
local function glasshouse(x0, x1, yb)
  local wh, rh = 20, 14
  local top, cx = yb - wh, (x0 + x1) // 2
  local wall = rect(x0, top, x1, yb)
  local roofm = poly{ { x0 - 2, top + 1 }, { cx, top - rh }, { x1 + 2, top + 1 } }
  local sill = rect(x0 - 1, yb - 5, x1 + 1, yb)
  F.shadow(x0 + 2, x1, yb, 8, 4)
  rimOf(union(wall, roofm, sill), L.timber)
  fill(wall, L.water.hi) fill(roofm, L.water.base)
  wall:each(function(x, y) if (x - y) % 11 == 0 then px(x, y, "#ece6cc") end end)
  -- seedlings and marsh plants inside
  for x = x0 + 3, x1 - 3, 6 do
    local r = (x // 6) % 2 == 0 and MINT or FLAG
    local m = c:ellipse(x, yb - 9, 3, 4) fill(m, r.base) px(x - 1, yb - 11, r.hi) px(x + 1, yb - 7, r.shade) px(x, yb - 12, r.hi)
  end
  part(sill, L.peat) F.courses(sill, yb - 5, 3, 6, L.peat) F.moss(sill, .2, 31)
  -- silvered glazing bars
  for x = x0, x1, 7 do vline(x, top, yb - 6, L.board.base) end
  hline(x0, x1, top, L.board.base) hline(x0, x1, top + 10, L.board.base)
  for k = 0, 4 do line({ { x0 - 1 + k * (cx - x0) // 4, top - k * rh // 4 }, { x0 - 1 + k * (cx - x0) // 4, top } }):each(function(x, y) if roofm:has(x, y) then px(x, y, L.board.hi) end end) end
  line({ { x0 - 2, top + 1 }, { cx, top - rh } }):each(function(x, y) px(x, y, L.board.hi) end)
  line({ { cx, top - rh }, { x1 + 2, top + 1 } }):each(function(x, y) px(x, y, L.board.shade) end)
  -- a reed-mat blind half rolled down the right roof slope, a roll at its foot
  roofm:each(function(x, y)
    if x > cx + 1 and y < top - 1 then
      local k = (x - y) % 3
      px(x, y, k == 0 and L.reed.shade or (k == 1 and L.reed.base or L.reed.hi))
      if (y - top) % 5 == 0 then px(x, y, L.timber.base) end
    end
  end)
  local roll = line({ { cx + 2, top - 1 }, { x1 + 2, top - 1 } }, 2)
  rimOf(roll, L.reed) fill(roll, L.reed.base) hline(cx + 2, x1 + 1, top - 2, L.reed.hi)
  for x = cx + 4, x1, 5 do px(x, top - 1, L.timber.deep) end
  for _, g in ipairs({ { x0 + 3, top + 3 }, { x0 + 10, top + 4 }, { cx - 6, top - 6 } }) do px(g[1], g[2], "#f2ead0") px(g[1] + 1, g[2] + 1, L.water.hi) end
  -- a little dyke in front, catching the sky
  local dk = poly{ { x0 - 8, yb + 2 }, { x1 + 12, yb + 2 }, { x1 + 8, yb + 5 }, { x0 - 6, yb + 5 } }
  rimOf(dk, L.peat) F.water(dk, L.water)
end

---------------------------------------------------------------- left hero: the herbalist's stilt hut
local function hut()
  -- the pool under the deck
  local pool = poly{ { 78, 184 }, { 202, 184 }, { 206, 196 }, { 192, 205 }, { 150, 208 }, { 104, 207 }, { 80, 200 } }
  rimOf(pool, L.peat)
  local bank = pool:grow(2):cut(pool)
  bank:each(function(x, y) if y > 183 then local v = hash(x, y, 51) px(x, y, v < .4 and L.peat.base or (v < .65 and L.peat.hi or L.sedgeGround.base)) end end)
  F.water(pool, L.water, { dark = true })
  -- the far half lighter where the sky gets in under the deck edge
  pool:each(function(x, y) if y > 199 and hash((x + y * 3) // 6, y, 52) < .3 then px(x, y, SKY) end end)
  local XS = { 90, 104, 120, 136, 152, 168, 184 }
  for _, sx in ipairs(XS) do for y = 197, 205, 2 do if pool:has(sx, y) then px(sx, y, L.water.deep) px(sx + 1, y, L.water.shade) end end end
  F.stilts(XS, 182, 199, 194)
  -- cross-bracing between the stilts
  for i = 1, #XS - 1 do
    line({ { XS[i] + 1, 184 }, { XS[i + 1], 192 } }):each(function(x, y) px(x, y, L.timber.shade) end)
  end
  local top, cx, wallM, roofM = F.building{ x0 = 96, x1 = 182, yb = 176, wh = 40, rh = 30, wall = L.wall2, roof = L.roof, chimney = true, noFrame = true, noShadow = true }
  F.planks(wallM:copy():clip(rect(96, top + 2, 182, 176)), L.wall2, 4, false, 17)
  -- paint wearing off the boards: silver timber showing through, damp at the foot
  wallM:each(function(x, y)
    if y > top + 2 and hash(x // 3, y // 4, 18) < .12 and hash(x, y, 19) < .6 then px(x, y, L.board.shade) end
    if y > 171 and hash(x // 2, y, 20) < .4 then px(x, y, L.moss.shade) end
  end)
  local corners = union(rect(96, top, 98, 176), rect(180, top, 182, 176))
  part(corners, L.board, { nopop = true, noshade = true }) vline(96, top, 176, L.board.hi)
  F.moss(roofM, .05, 41)
  -- the gable in vertical silvered boards, a reed-bundle cross nailed under the apex
  local gableM = poly{ { 108, top }, { cx, top - 19 }, { 170, top } }:cut(rect(cx - 5, top - 15 - 1, cx + 4, top - 15 + 7))
  F.planks(gableM, L.wall2, 4, true, 44)
  gableM:each(function(x, y) if hash(x // 4, y, 45) < .2 then px(x, y, L.board.shade) end end)
  for _, q in ipairs({ { cx - 14, top - 3, cx - 6, top - 7 }, { cx + 6, top - 7, cx + 14, top - 3 } }) do
    local m = line({ { q[1], q[2] }, { q[3], q[4] } }, 2)
    rimOf(m, L.reed) fill(m, L.reed.base) line({ { q[1], q[2] - 1 }, { q[3], q[4] - 1 } }):each(function(x, y) if m:has(x, y) then px(x, y, L.reed.hi) end end)
  end
  -- the deck
  local deck = rect(84, 177, 194, 181)
  F.boardwalk(deck, true, 31)
  hline(84, 194, 181, L.board.deep)
  -- round green door
  local d = c:rrect(130, 150, 146, 176, 8):clip(rect(130, 150, 146, 176))
  rimOf(d, L.reedGreen) part(d, L.reedGreen) c:edgeIn(d, L.reedGreen.edge)
  for x = 134, 143, 3 do vline(x, 154, 175, L.reedGreen.shade) end
  fill(c:ellipse(142, 164, 1, 1), L.gold.base) px(141, 163, L.gold.hi)
  -- a wreath of sweet flag and cranberries
  local wr = c:ellipse(138, 158, 3, 3):cut(c:ellipse(138, 158, 1, 1))
  wr:each(function(x, y) px(x, y, (x + y) % 2 == 0 and FLAG.base or FLAG.shade) end) px(138, 155, CRAN.base) px(136, 161, CRAN.base) px(141, 159, CRAN.hi)
  F.window(106, 142, 116, 150, L.timber) F.window(160, 142, 170, 150, L.timber)
  -- window boxes with marsh marigolds and mint
  for _, wx in ipairs({ 104, 158 }) do
    local bx = rect(wx, 154, wx + 14, 157) rimOf(bx, L.timber) part(bx, L.board, { nopop = true })
    for k = 0, 6 do
      local fx = wx + 1 + k * 2
      px(fx, 152, MINT.base) px(fx + 1, 151, MINT.hi) px(fx, 153, MINT.shade)
      if k % 2 == 0 then px(fx, 150, L.marigold.base) px(fx + 1, 150, L.marigold.hi) end
    end
  end
  -- drying bundles and cranberry strings hanging from the eave pole
  hline(98, 180, top + 5, L.timber.deep)
  for k = 0, 10 do
    local x = 100 + k * 8
    if k % 4 == 3 then
      vline(x, top + 6, top + 16, L.board.deep)
      for j = 0, 3 do local yy = top + 7 + j * 3 px(x, yy, CRAN.base) px(x - 1, yy, CRAN.hi) px(x, yy + 1, CRAN.shade) end
    else
      local r = ({ MINT, FLAG, MSW, L.reed })[k % 4 + 1]
      if k % 4 == 2 then r = (k == 2) and MSW or MFL end
      vline(x, top + 5, top + 6, L.timber.edge)
      local b = poly{ { x - 2, top + 7 }, { x + 2, top + 7 }, { x + 1, top + 14 }, { x - 1, top + 14 } }
      fill(b, r.base) px(x - 1, top + 8, r.hi) px(x - 1, top + 11, r.hi) vline(x + 1, top + 9, top + 13, r.shade) hline(x - 2, x + 2, top + 7, L.board.deep)
      px(x, top + 14, r.deep)
    end
  end
  -- hanging mortar & pestle sign on an iron bracket
  hline(184, 198, 146, L.iron.base) hline(184, 198, 147, L.iron.deep)
  vline(188, 148, 151, L.timber.edge) vline(196, 148, 151, L.timber.edge)
  local mortar = poly{ { 185, 154 }, { 199, 154 }, { 197, 161 }, { 193, 164 }, { 191, 164 }, { 187, 161 } }
  local pestle = line({ { 196, 152 }, { 201, 146 } }, 2)
  rimOf(union(mortar, pestle), L.stone) part(mortar, L.stone) part(pestle, L.board, { nopop = true })
  hline(185, 199, 154, L.stone.hi) hline(187, 197, 155, L.stone.deep)
  px(189, 153, MINT.hi) px(190, 152, MINT.base) px(192, 153, CRAN.base)
  -- drying reed sheaves leaning on the wall between door and window, a pair at the deck's left end
  sheaf(151, 176, 18) sheaf(156, 176, 20) sheaf(124, 176, 16)
  sheaf(88, 176, 14) sheaf(93, 176, 16)
  -- a ladder from the deck down to the bank at the right
  local lad = line({ { 188, 178 }, { 196, 212 } }, 1):add(line({ { 194, 178 }, { 202, 212 } }, 1))
  for k = 0, 7 do lad:add(line({ { 189 + floor(k * 8 / 34 * 4 + .5), 182 + k * 4 }, { 195 + floor(k * 8 / 34 * 4 + .5), 182 + k * 4 } })) end
  rimOf(lad, L.timber) fill(lad, L.board.base)
  return top
end

---------------------------------------------------------------- raised peat-turf beds standing in the flooded bog garden
local function bed(x0, x1, y0, y1, plant, seed)
  local soil = poly{ { x0 + 4, y0 }, { x1, y0 }, { x1 + 4, y1 }, { x0, y1 } }
  local front = rect(x0, y1, x1 + 4, y1 + 4)
  -- the bed's dark reflection in the water below its face
  for k = 1, 3 do hline(x0 + k, x1 + 4 - k, y1 + 4 + k, k == 1 and L.water.deep or L.water.shade) end
  rimOf(union(soil, front), L.peat)
  fill(soil, L.peat.shade)
  soil:each(function(x, y) local v = hash(x, y, seed) if v < .18 then px(x, y, L.peat.deep) elseif v > .92 then px(x, y, L.moss.base) end end)
  -- cut peat turves: staggered blocks, lit top lips, fibrous flecks, grass along the top edge
  front:each(function(x, y)
    local r = (y - y1) // 2
    local k = (x + r * 3) % 7
    local h = ((y - y1) % 2 == 0) and L.peat.base or L.peat.shade
    if k == 0 then h = L.peat.deep end
    if y == y1 then h = (hash(x, y, seed + 1) < .5) and L.peat.hi or L.sedgeGround.base end
    if hash(x, y, seed + 2) < .08 then h = L.peat.hi end
    px(x, y, h)
  end)
  for x = x0, x1 + 4 do if hash(x, 1, seed + 3) < .35 then px(x, y1 - 1, L.reedGreen.base) if hash(x, 2, seed + 3) < .4 then px(x, y1 - 2, L.reedGreen.hi) end end end
  -- corner stakes
  for _, sx in ipairs({ x0, x1 + 4 }) do vline(sx, y1 - 3, y1 + 6, L.timber.deep) px(sx, y1 - 3, L.timber.hi) end
  local n = (x1 - x0) // 7
  for k = 0, n - 1 do plant(x0 + 6 + k * 7, y0 + (y1 - y0) // 2 + 2, k) end
end
local function sweetflag(x, y, k)
  -- a fan of sword leaves, one with the crimped edge, a horn-like flower spike now and then
  for j, lf in ipairs({ { -2, 9 }, { -1, 11 }, { 0, 12 }, { 1, 10 }, { 3, 8 } }) do
    for t = 0, lf[2] do
      local xx = x + floor(lf[1] * t / lf[2] * 1.4 + .5)
      px(xx, y - t, (lf[1] < 0) and FLAG.hi or (lf[1] == 0 and FLAG.base or FLAG.shade))
    end
  end
  px(x, y, FLAG.deep) px(x - 1, y, FLAG.deep) px(x + 1, y, FLAG.deep)
  if k % 2 == 0 then vline(x + 2, y - 7, y - 4, L.marigold.shade) px(x + 2, y - 7, L.marigold.base) end
end
local function cranberry(x, y, k)
  local m = c:ellipse(x, y - 2, 4, 2)
  m:each(function(xx, yy)
    local d = (xx - x) + (yy - y + 2) * 2
    px(xx, yy, d < -2 and CRANL.hi or (d < 2 and CRANL.base or CRANL.shade))
  end)
  -- runners trailing off, bright berries
  px(x - 5, y - 1, CRANL.shade) px(x + 5, y - 1, CRANL.deep)
  for _, b in ipairs({ { -2, -3 }, { 1, -2 }, { 3, -3 }, { -1, -1 } }) do
    px(x + b[1], y + b[2], CRAN.base) if (k + b[1]) % 2 == 0 then px(x + b[1], y + b[2] - 1, CRAN.hi) end
  end
  px(x + 2, y - 1, CRAN.shade)
end
local function marshMarigold(x, y, k)
  local m = c:ellipse(x, y - 3, 4, 3)
  m:each(function(xx, yy) local d = (xx - x) + (yy - y + 3) px(xx, yy, d < -2 and L.leaf.hi or (d < 2 and L.leaf.base or L.leaf.shade)) end)
  hline(x - 3, x + 3, y, L.leaf.deep)
  for _, f in ipairs({ { -2, -6 }, { 2, -5 }, { 0, -3 } }) do
    local fx, fy = x + f[1], y + f[2]
    px(fx, fy, L.marigold.hi) px(fx + 1, fy, L.marigold.base) px(fx, fy + 1, L.marigold.base) px(fx + 1, fy + 1, L.marigold.shade)
    if f[2] == -6 then px(fx - 1, fy, L.marigold.base) end
  end
end
local function waterMint(x, y, k)
  -- a bushy clump of square stems with opposite leaf pairs, lilac pompom whorls on top
  for j, st in ipairs({ { -2, 7 }, { 0, 9 }, { 2, 6 } }) do
    local sxx, sh = x + st[1], st[2] - (k + j) % 2
    vline(sxx, y - sh, y, MINT.deep)
    for t = 1, sh - 1, 2 do
      px(sxx - 1, y - t, (st[1] <= 0) and MINT.hi or MINT.base) px(sxx + 1, y - t, (st[1] < 0) and MINT.base or MINT.shade)
      if t > 2 then px(sxx - 1, y - t + 1, MINT.base) px(sxx + 1, y - t + 1, MINT.shade) end
    end
    if (j + k) % 3 ~= 2 then px(sxx, y - sh - 1, MFL.hi) px(sxx - 1, y - sh, MFL.base) px(sxx + 1, y - sh, MFL.shade) px(sxx, y - sh, MFL.base)
    else px(sxx, y - sh, MINT.hi) end
  end
  hline(x - 3, x + 3, y, MINT.deep)
end

---------------------------------------------------------------- compose: back to front
F.depth(1)
F.tree(86, 130, 40, 1)
F.tree(14, 140, 40, 3)
glasshouse(22, 76, 140)
-- two far gnomes in the bog: one wading with a cranberry rake, one carrying a basket
F.gnome(420, 150, { small = true, hat = L.awnA, coat = L.wall2, arm = "out" })
line({ { 428, 143 }, { 433, 150 } }):each(function(x, y) px(x, y, L.board.base) end) hline(431, 435, 150, L.iron.base)
F.gnome(352, 138, { small = true, hat = L.accent, coat = L.reed, flip = true })
-- reeds and silvery willow scrub behind the hut
F.reeds(98, 150, 138, 10, 71, { green = true })
for x = 150, 206, 12 do F.bush(x, 134 + (x % 3), 6, 7, (x % 24 == 6) and L.willow or L.wall2, x) end
F.reeds(184, 210, 140, 12, 72, { cattails = 2 })
F.depth(2)
F.tree(204, 128, 46, 3)
F.tree(282, 130, 44, 1)
arch()
F.tree(458, 168, 60, 2)
F.mist(140, 206, 116, 119, 64, .45) F.mist(286, 330, 116, 118, 65, .4)
F.depth(3)
local htop = hut()
F.smoke(172, 98, 7, .5, 2)

-- the flooded bog garden: the beds stand in still water with plank bridges between them
local bog = poly{ { 276, 162 }, { 384, 162 }, { 398, 172 }, { 406, 196 }, { 410, 218 }, { 396, 226 }, { 378, 229 }, { 377, 252 }, { 300, 252 }, { 288, 238 }, { 282, 204 } }
rimOf(bog, L.peat)
local bogBank = bog:grow(2):cut(bog)
bogBank:each(function(x, y) if not F.roadM:has(x, y) then local v = hash(x, y, 53) px(x, y, v < .4 and L.peat.base or (v < .65 and L.peat.hi or L.sedgeGround.base)) end end)
F.water(bog, L.water)
-- reflections of the beds and the willow, lily pads, a moorhen's ripple
for k = 0, 6 do hline(400 - k // 2, 408 - k, 176 + k * 2, L.water.shade) end
-- herb drying A-frame rack near the road (left): bundles and a cranberry garland, reed sheaves at its ends
local function dryRack(x0, yb)
  local legs = line({ { x0, yb }, { x0 + 6, yb - 26 }, { x0 + 12, yb } }, 2):add(line({ { x0 + 30, yb }, { x0 + 36, yb - 26 }, { x0 + 42, yb } }, 2))
  local bar = rect(x0 + 4, yb - 26, x0 + 38, yb - 25)
  F.shadow(x0, x0 + 42, yb, 6, 2)
  rimOf(union(legs, bar), L.willowBark) part(legs, L.willowBark, { nopop = true, noshade = true }) part(bar, L.willowBark, { nopop = true, noshade = true })
  union(legs, bar):each(function(x, y) if hash(x, y // 2, 85) < .2 then px(x, y, L.willowBark.deep) end end)
  for k = 0, 5 do
    local x = x0 + 9 + k * 5
    local r = ({ MINT, FLAG, MSW, MFL, L.reed, L.leaf })[k + 1]
    vline(x, yb - 24, yb - 22, L.timber.edge)
    local b = poly{ { x - 2, yb - 21 }, { x + 2, yb - 21 }, { x + 1, yb - 12 }, { x - 1, yb - 12 } }
    rimOf(b, r) fill(b, r.base) px(x - 1, yb - 20, r.hi) px(x - 1, yb - 17, r.hi) vline(x + 1, yb - 19, yb - 13, r.shade)
    hline(x - 2, x + 2, yb - 21, L.board.deep)
  end
  for xx = x0 + 6, x0 + 36 do
    local t = (xx - x0 - 6) / 30
    local yy = floor(yb - 9 + 4 * 4 * t * (1 - t))
    px(xx, yy, L.board.deep)
    if (xx - x0) % 3 == 0 then px(xx, yy + 1, CRAN.base) px(xx - 1, yy + 1, CRAN.hi) end
  end
  sheaf(x0 - 4, yb, 18) sheaf(x0 + 46, yb, 16)
end
dryRack(160, 220)
-- the beds, near ones larger
bed(282, 360, 166, 174, sweetflag, 3)
bed(288, 380, 184, 194, cranberry, 4)
bed(294, 396, 204, 216, marshMarigold, 5)
bed(304, 372, 228, 242, waterMint, 6)
-- plank bridges from the causeway side across to each bed
for _, b in ipairs({ { 274, 290, 176, 3 }, { 278, 296, 197, 3 }, { 282, 302, 219, 4 } }) do
  local m = rect(b[1], b[3], b[2], b[3] + b[4])
  F.boardwalk(m, true, b[1])
  hline(b[1], b[2], b[3] + b[4] + 1, L.water.deep)
end
-- lilies and reeds in the channels
for _, p in ipairs({ { 392, 200, true, "white" }, { 386, 226, false }, { 300, 224, true }, { 396, 246, true, "yellow" }, { 380, 178, false } }) do F.lily(p[1], p[2], p[3], p[4]) end
F.reeds(398, 410, 228, 14, 88, { cattails = 2, green = true })
for _, p in ipairs({ { 402, 194, true }, { 410, 206, false, "white" }, { 400, 182, false }, { 412, 186, true }, { 404, 212, false } }) do F.lily(p[1], p[2], p[3], p[4]) end
F.reeds(414, 424, 214, 12, 90, { green = true })
F.reeds(388, 400, 184, 12, 87, { green = true })
for _, p in ipairs({ { 372, 168, true }, { 380, 172, false, "white" }, { 366, 176, false }, { 392, 166, true, "yellow" }, { 362, 182, true } }) do F.lily(p[1], p[2], p[3], p[4]) end
F.sprite({ "....kk.", "...kkkR", ".kkkk..", "kKKKKk.", ".wkkk.." }, 370, 191, { k = "#3e3c42", K = "#5a5862", R = L.apple.base, w = L.awnB.hi })
for xx = 368, 380 do if hash(xx, 9, 79) < .6 then px(xx, 196, (xx < 374) and L.water.hi or SKY) end end
F.reeds(284, 292, 250, 12, 89, { green = true })
-- a pair of mallards paddling in the channel between the near beds
local function duck(x, y, drake, flip)
  local rows = drake and { ".......ggg..", "......gGGGgy", "..bbb.ggg.yy", ".bbbbbbwb...", "bBBBbbbbbbb.", "BbbbbbbbbbB.", ".ddddddddd.." }
    or { ".......bbb..", "......bBBbby", "..bbb.bbb.yy", ".bbbbbbbbb..", "bBBBbbbbbbb.", "BbbbbbbbbbB.", ".ddddddddd.." }
  if flip then for i, r in ipairs(rows) do rows[i] = r:reverse() end end
  local gr = drake and L.heron or L.goose
  F.sprite(rows, x, y - 2, { g = "#2e5a46", G = "#4e8a62", y = L.marigold.base, w = L.awnB.hi, b = gr.base, B = gr.hi, d = gr.deep })
  if drake then px(flip and x + 4 or x + 7, y + 2, KING.base) end
  for xx = x - 2, x + 12 do if hash(xx, y, 79) < .6 then px(xx, y + 6, (xx < x + 4) and L.water.hi or SKY) end end
end
duck(352, 223, true, true) duck(370, 221, false, true)

-- quirk: an otter in a red gnome hat asleep, curled in the water-mint bed; a dragonfly resting on the hat tip
do
  local OH = F.mix(OTTER.hi, OTTER.base, .5)
  F.sprite({
    "......................R.....",
    ".....................RRr....",
    "....................RRRr....",
    "...................RRRRr....",
    "..................RRRRRrr...",
    ".................RRRRRRrr...",
    "................hhhhhhhhhh..",
    ".......bbbbbbb..eHHHHHHHHH..",
    ".....bbBBBBBBBbbeHHHkkHHHHHN",
    "....bBBBBBBBBBBbeHHHHHHccccN",
    "...bBBBBBbbbbBBBbeHHHccccc..",
    "..bBBBBbbbbbbbBBbbeccccc....",
    "..bBBBbtttttttbBbbbppbpp....",
    "..bbBbtTTTTTTTTTtttt........",
    "...bbbtttttttttttttttt......",
    "....ddddddddddddddddd.......",
  }, 326, 223, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, b = OTTER.base, B = OTTER.hi, H = OH, e = OTTER.deep,
    t = OTTER.shade, T = OTTER.base, d = OTTER.deep, c = "#e6d4b0", k = L.timber.edge, N = OTTER.edge, p = OTTER.deep })
  -- hat highlight, whiskers, a mint sprig tucked behind its ear
  for _, q in ipairs({ { 345, 226 }, { 346, 225 }, { 347, 224 }, { 344, 227 }, { 345, 227 } }) do px(q[1], q[2], L.awnA.hi) end
  hline(343, 351, 228, L.awnA.shade) px(348, 223, L.awnA.hi) -- hat lit left, brim fold
  px(355, 233, L.awnB.shade) px(356, 234, L.awnB.shade) px(356, 232, L.awnB.shade) -- whiskers
  px(342, 230, MINT.hi) px(341, 229, MINT.base) px(341, 228, MFL.hi) -- a mint sprig behind its ear
  hline(339, 345, 234, OTTER.shade) -- the crease between head and curled body
  F.dragonfly(353, 221, KING, true)
  -- sleepy bubbles
  local bub = c:ellipse(364, 219, 2, 2) fill(bub, L.water.hi) px(363, 218, "#f2ead0")
  px(360, 223, L.water.hi)
end

-- potting bench with peat pots, jars of cranberry jelly and mint, a wicker basket
local function pottingTable()
  local top = rect(412, 172, 462, 175)
  local legs = rect(415, 176, 417, 196):add(rect(457, 176, 459, 196))
  local shelf = rect(414, 188, 460, 189)
  F.shadow(414, 462, 196, 8, 3)
  rimOf(union(top, legs, shelf), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true }) part(shelf, L.timber, { nopop = true, noshade = true }) part(top, L.board)
  F.planks(top, L.board, 6, true, 21)
  for k = 0, 2 do
    local x = 416 + k * 12
    local pot = poly{ { x, 165 }, { x + 8, 165 }, { x + 7, 171 }, { x + 1, 171 } }
    rimOf(pot, L.peat) part(pot, L.peat, { nopop = true }) hline(x, x + 8, 165, L.peat.hi)
    local rr = ({ MINT, FLAG, L.leaf })[k + 1]
    local pl = c:ellipse(x + 4, 161, 3, 3) fill(pl, rr.base) px(x + 3, 159, rr.hi) px(x + 2, 160, rr.hi) px(x + 6, 162, rr.shade)
    if k == 2 then px(x + 3, 158, L.marigold.base) px(x + 5, 159, L.marigold.hi) end
    if k == 1 then vline(x + 4, 154, 158, FLAG.base) vline(x + 2, 156, 158, FLAG.hi) end
  end
  for k = 0, 1 do
    local x = 452 + k * 6
    local jar = rect(x - 2, 164, x + 2, 171) fill(jar, L.water.hi) fill(rect(x - 1, 167, x + 1, 171), ({ CRAN, MINT })[k + 1].base) hline(x - 2, x + 2, 164, L.timber.base) px(x - 2, 166, "#f2ead0")
  end
  local bk = poly{ { 438, 181 }, { 454, 181 }, { 452, 187 }, { 440, 187 } }
  rimOf(bk, L.reed) part(bk, L.reed, { nopop = true }) bk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.reed.shade) end end)
  for k = 0, 4 do local mx = 440 + k * 3 px(mx, 180, CRAN.base) px(mx + 1, 180, CRAN.hi) px(mx, 179, CRAN.shade) end
  for k = 0, 1 do local x = 418 + k * 10 local pot = rect(x, 184, x + 6, 187) fill(pot, L.peat.shade) hline(x, x + 6, 184, L.peat.base) end
end
pottingTable()
-- rush skeps on a stand, each under a pointed sedge hackle
local function skeps()
  local bench = rect(414, 216, 466, 218):add(rect(416, 219, 418, 226)):add(rect(462, 219, 464, 226))
  F.shadow(414, 466, 226, 6, 2)
  rimOf(bench, L.timber) part(bench, L.timber, { nopop = true, noshade = true })
  for k = 0, 2 do
    local x = 424 + k * 16
    local m = c:ellipse(x, 208, 7, 9):clip(rect(x - 8, 198, x + 8, 215))
    local hk = poly{ { x - 9, 207 }, { x, 192 }, { x + 9, 207 }, { x + 6, 205 }, { x - 6, 205 } }
    rimOf(union(m, hk), L.roof2)
    part(m, L.reed)
    for y = 201, 214, 3 do hline(x - 7, x + 7, y, L.reed.shade) end
    m:each(function(xx, y) if y % 3 == 2 and hash(xx, y, k) < .3 then px(xx, y, L.reed.hi) end end)
    fill(rect(x - 1, 212, x + 1, 215), L.timber.edge)
    -- the hackle: combed sedge, lit left, a ragged drip edge, a band near the top
    hk:each(function(xx, y)
      local h = (xx < x) and ((xx + y) % 3 == 0 and L.roof2.base or L.roof2.hi) or ((xx + y) % 3 == 0 and L.roof2.deep or L.roof2.shade)
      if y >= 205 and hash(xx, y, 30 + k) < .5 then h = L.roof2.deep end
      px(xx, y, h)
    end)
    hline(x - 2, x + 2, 196, L.timber.deep) px(x, 191, L.roof2.hi)
  end
  for i = 0, 7 do local bx, by = 418 + floor(hash(i, 1, 3) * 48), 182 + floor(hash(i, 2, 3) * 12) px(bx, by, L.gold.base) px(bx + 1, by, L.timber.edge) px(bx, by - 1, L.water.hi) end
end
skeps()

-- the herb spiral, bottom-left, with its little pond at the foot
local spond = c:ellipse(130, 258, 13, 6)
rimOf(spond, L.stone)
F.water(spond, L.water)
local function spiral(cx, cy)
  F.shadow(cx - 36, cx + 40, cy + 14, 8, 3)
  local tiers = { { 40, 13, 0, MINT }, { 28, 9, 9, CRANL }, { 16, 6, 17, L.leaf } }
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
    F.moss(face, .3, 50 + i)
    fill(top, L.peat.shade)
    top:each(function(x, y)
      local v = hash(x // 2, y // 2, i * 7)
      px(x, y, v < .5 and rr.base or (v < .7 and rr.hi or rr.shade))
      if hash(x, y, i * 3) < .1 then px(x, y, rr.deep) end
      if i == 1 and hash(x, y, 77) < .05 then px(x, y, MFL.base) end
      if i == 2 and hash(x, y, 78) < .07 then px(x, y, CRAN.base) end
      if i == 3 and hash(x, y, 79) < .07 then px(x, y, L.marigold.base) end
    end)
    c:edgeIn(top, L.stone.base)
  end
  sweetflag(cx, cy - 22, 0)
end
spiral(74, 248)
-- the pond's lilies, a frog, a marsh marigold clump on its rim
F.lily(124, 260, true, "yellow") F.lily(136, 256, false) F.lily(131, 262, false)
F.frog(137, 257, false)
F.sedge(145, 256, 5) F.sedge(117, 264, 4)

-- flag iris and purple loosestrife along the left: sword-leaf fans and swaying flower spires
for k, x in ipairs({ 26, 36, 46, 58, 70, 82 }) do
  local yb, h = 210 + (k % 2) * 3, 30 + floor(hash(k, 1, 5) * 20)
  local function sx(y) return x + floor(sin((yb - y) / h * 2.2 + k) * 2 * (yb - y) / h + .5) end
  if k % 2 == 1 then
    -- yellow flag iris: a fan of blue-green swords, a stem with three flags
    for j, lf in ipairs({ { -4, 14 }, { -2, 18 }, { 0, 20 }, { 2, 16 }, { 4, 12 } }) do
      for t = 0, lf[2] do px(x + floor(lf[1] * t / lf[2] + .5), yb - t, (lf[1] < 0) and FLAG.hi or (lf[1] == 0 and FLAG.base or FLAG.shade)) end
    end
    for y = yb - h, yb - 10 do px(sx(y), y, FLAG.deep) px(sx(y) + 1, y, FLAG.shade) end
    for i, fy in ipairs({ yb - h, yb - h + 7, yb - h + 13 }) do
      local fx = sx(fy) + ((i % 2 == 0) and 2 or -1)
      F.sprite({ "..h.h..", ".hbhbh.", "hbbcbbe", "ebbcbbe", ".ebcbe.", "..ebe.." }, fx - 3, fy - 1, { h = L.marigold.hi, b = L.marigold.base, c = L.cattail.base, e = L.marigold.deep }, { rim = false })
    end
  else
    -- purple loosestrife: a leafy stem, a long magenta spike of whorls, smaller to the tip
    for y = yb - h, yb do px(sx(y), y, L.leaf.shade) px(sx(y) + 1, y, L.leaf.deep) end
    for j = 0, 4 do local yy = yb - 3 - j * 4 px(sx(yy) - 2, yy, L.leaf.base) px(sx(yy) - 1, yy, L.leaf.hi) px(sx(yy) + 2, yy + 1, L.leaf.shade) px(sx(yy) + 3, yy + 1, L.leaf.deep) end
    for y = yb - h + 1, yb - floor(h * .45) do
      local t = (y - (yb - h)) / (h * .55)
      local w = t < .2 and 0 or (t < .55 and 1 or 2)
      local cx = sx(y)
      for xx = cx - w, cx + 1 + w do
        local v = hash(xx, y, 40 + k)
        if v < .78 or xx == cx then
          local col = (xx <= cx - 1 or (xx == cx and v < .5)) and LOOSE.hi or ((xx >= cx + 1 + w) and LOOSE.shade or LOOSE.base)
          if v < .12 then col = LOOSE.deep end
          if y % 3 == 0 and xx > cx then col = LOOSE.shade end
          px(xx, y, col)
        end
      end
      if y % 4 == 0 then px(cx - w - 1, y, L.leaf.shade) end
    end
    px(sx(yb - h), yb - h - 1, LOOSE.hi)
  end
end
-- gnome harvesting with a trug of cranberries and mint, at the first bridge
local _, gx, gy = F.gnome(268, 218, { hat = MFL, coat = L.reedGreen, arm = "out" })
local bsk = poly{ { gx - 1, gy - 1 }, { gx + 11, gy - 1 }, { gx + 9, gy + 6 }, { gx + 1, gy + 6 } } rimOf(bsk, L.reed) part(bsk, L.reed)
bsk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.reed.shade) end end)
for k = 0, 4 do
  local col = ({ CRAN, MINT, CRAN, FLAG, CRAN })[k + 1]
  px(gx + 1 + k * 2, gy - 2, col.base) px(gx + 1 + k * 2, gy - 3, col.hi)
end
-- the waterer, tipping a wooden pail over the herb spiral
local _, wx, wy = F.gnome(164, 254, { hat = L.awnA, coat = L.wall2, arm = "out", flip = true })
local pail = poly{ { wx - 12, wy - 7 }, { wx - 1, wy - 3 }, { wx - 2, wy + 4 }, { wx - 10, wy + 1 } }
rimOf(pail, L.timber) part(pail, L.timber)
pail:each(function(x, y) if (x - wx) % 3 == 0 then px(x, y, L.timber.deep) elseif x < wx - 8 then px(x, y, L.timber.hi) end end)
line({ { wx - 11, wy - 4 }, { wx - 1, wy } }):each(function(x, y) if pail:has(x, y) then px(x, y, L.iron.base) end end)
line({ { wx - 10, wy - 1 }, { wx - 2, wy + 2 } }):each(function(x, y) if pail:has(x, y) then px(x, y, L.iron.shade) end end)
line({ { wx - 12, wy - 7 }, { wx - 7, wy - 11 }, { wx - 1, wy - 3 } }):each(function(x, y) px(x, y, L.iron.deep) end) -- the bail handle
for k = 0, 6 do px(wx - 13 - k, wy - 6 + k * 2, L.water.hi) px(wx - 12 - k, wy - 5 + k * 2, L.water.base) if k % 2 == 0 then px(wx - 14 - k, wy - 5 + k * 2, SKY) end end
-- a kingfisher on the corner stake of the cranberry bed
F.sprite({ ".BBb...", "BBBbOkk", "bOOOO..", ".OOO...", "..p....", "..p...." }, 286, 188,
  { B = KING.hi, b = KING.base, O = L.produce.base, k = L.timber.edge, p = L.timber.deep })
px(287, 189, KING.base)
-- sedge and marigold tufts along the hut bank and the left edge
for _, f in ipairs({ { 92, 212, 6 }, { 206, 210, 5 }, { 20, 220, 7 }, { 98, 216, 5 }, { 214, 240, 6 }, { 140, 222, 5 } }) do
  F.sedge(f[1], f[2], f[3]) if f[3] >= 6 then px(f[1] - 1, f[2] - 5, L.marigold.base) px(f[1] + 2, f[2] - 4, L.marigold.hi) end
end
F.reeds(70, 86, 204, 14, 90, { cattails = 2, green = true })
F.depth(0)
-- bees over the skeps and the bog, brimstone and white butterflies, dragonflies, a skein of geese
for i = 0, 14 do local bx, by = 300 + floor(hash(i, 1, 33) * 170), 140 + floor(hash(i, 2, 33) * 80) px(bx, by, L.gold.base) px(bx + 1, by, L.timber.edge) px(bx, by - 1, L.water.hi) end
F.sprite({ "a.a", ".k.", "a.a" }, 330, 128, { a = L.awnB.hi, k = L.timber.edge }, { rim = false })
F.sprite({ "a.a", ".k.", "a.a" }, 120, 200, { a = L.gold.hi, k = L.timber.edge }, { rim = false })
F.sprite({ "a.a", ".k.", "a.a" }, 240, 196, { a = L.awnB.hi, k = L.timber.edge }, { rim = false })
F.dragonfly(256, 180, L.accent) F.dragonfly(374, 160, KING, true) F.dragonfly(52, 232, L.apple)
F.birds({ { 330, 44, 2 }, { 336, 47, 2 }, { 342, 50, 2 }, { 324, 47, 2 }, { 318, 50, 2 }, { 120, 60, 2 } })
-- wicker baskets of meadowsweet, sweet flag and mint, bottom-right
F.depth(3)
for k, x in ipairs({ 300, 316, 368 }) do
  local pot = poly{ { x - 7, 252 }, { x + 7, 252 }, { x + 6, 264 }, { x - 6, 264 } }
  rimOf(pot, L.reed) part(pot, L.reed)
  pot:each(function(xx, yy) if (xx + yy) % 3 == 0 then px(xx, yy, L.reed.shade) elseif (xx - yy) % 5 == 0 then px(xx, yy, L.reed.hi) end end)
  hline(x - 7, x + 7, 252, L.reed.hi) hline(x - 7, x + 7, 253, L.reed.deep) hline(x - 6, x + 6, 261, L.reed.deep)
  if k == 1 then
    -- meadowsweet: reddish stems, frothy cream plumes
    for _, s in ipairs({ { x - 3, 236 }, { x + 1, 230 }, { x + 4, 238 } }) do
      vline(s[1], s[2], 251, CRANL.shade)
      local m = c:ellipse(s[1], s[2], 3, 2)
      m:each(function(xx, yy) px(xx, yy, (hash(xx, yy, 60) < .4) and MSW.hi or ((xx > s[1]) and MSW.shade or MSW.base)) end)
    end
    F.sedge(x, 251, 5, L.leaf)
  elseif k == 2 then
    sweetflag(x, 251, 0) sweetflag(x - 3, 251, 1)
  else
    for _, s in ipairs({ { x - 3, 247 }, { x + 2, 245 }, { x, 249 } }) do waterMint(s[1], s[2], 0) end
  end
end
F.finish()
