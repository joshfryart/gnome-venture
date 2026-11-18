-- herb.lua : "Herb garden" stop look, MOUNTAIN (mountain_granite), 480x270 gate view.
-- Same composition as the Maplewold herb (art-2701-batch3/stops/opus3/herb.lua), re-cast for the high mountains:
-- right: terraced beds of arnica, gentian, thyme and edelweiss stepping back to the tree line, each held by a
-- dry-stone wall (replaces the lavender rows), two far gnomes picking and a goat nosing at the top terrace.
-- Road's end: granite gate posts carrying a bent larch arch climbed by alpenrose and alpine clematis, a board gate ajar.
-- Back left: a dry-stone drying hut with a slab roof and a glazed cold frame, beside a larch and a spruce.
-- Left hero: the herbalist's chalet, whitewashed granite below and larch boards above, a slab roof with weighting
-- stones, an open drying loft in the gable hung with bundles, bundles under the eave, an arched door with an
-- edelweiss wreath and a mortar-and-pestle sign. Stone-edged beds (edelweiss, arnica, gentian, catnip), a larch
-- potting table, painted box hives under slab lids, a lichened granite herb spiral, yellow gentian and monkshood
-- spires along the left, a houseleek trough, a masterwort tub and a whistling marmot by the drying rack.
-- Quirk: a ginger cat asleep in the catnip bed, an Apollo butterfly on its ear.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-mountain-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "herb", out = DIR, farTrees = { 24, 52, 160, 196, 440 }, treeLineGap = { 206, 272 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local HAZE = "#d6e0e8"
-- local ramps
local GEN = L.gentian                                              -- spring / trumpet gentian blue
local ARN = F.rp("#fff0a2 #f6c84a #de9430 #a8642a #6a3e22")       -- arnica yellow-orange
local THY = F.rp("#f2cce2 #d898c4 #b070a4 #7c4c7a #4c2e50")       -- wild thyme pink-mauve
local EDL = F.rp("#e4e8dc #c2cabc #9ca898 #74806e #4c5648")       -- edelweiss / felted silver leaf
local YG = F.rp("#fff4a0 #f2d24c #d2a632 #9a7428 #5e4620")        -- yellow gentian
local MONK = F.rp("#b6aef0 #7e72d2 #5a4ea8 #3e3478 #28204e")      -- monkshood blue-violet
local AROSE = F.rp("#f8b4c0 #e66a82 #be4462 #882e4c #561c34")     -- alpenrose
local COP = F.rp("#f4c09a #d88a5a #b0623e #7e4430 #4e2a22")       -- copper
local CROPS = { ARN, GEN, THY, EDL }

---------------------------------------------------------------- right: herb terraces to the tree line
-- Rows run across the view; a row's depth grows with nearness (d^2 / C). Each row is a terrace: a band of round
-- herb cushions held by a dry-stone wall along its foot. Thin far rows are a hazed band of wall + bloom (no shimmer).
local C = 190
local function rowOf(y) return floor(C / (y - 109)) end
for y = 114, 160 do
  local row = rowOf(y)
  local y0 = y while y0 > 114 and rowOf(y0 - 1) == row do y0 = y0 - 1 end
  local y1 = y while y1 < 160 and rowOf(y1 + 1) == row do y1 = y1 + 1 end
  local hgt = y1 - y0 + 1
  local R = CROPS[row % 4 + 1]
  for x = 262, 479 do
    if x > F.xr(y) + 6 then
      local h
      if hgt < 3 then
        -- a far terrace: one line of bloom, a hazed wall line under every other one
        if y == y1 and hgt == 2 or (hgt == 1 and row % 3 == 0) then h = F.mix((x + row) % 4 == 0 and L.stone.shade or L.stone.base, HAZE, .3)
        else
          h = F.mix(R.base, HAZE, .25)
          if hash(x // 3, y, 3) < .2 then h = F.mix(R.hi, HAZE, .2) elseif hash(x // 2, y, 4) < .15 then h = F.mix(L.fern.shade, HAZE, .3) end
        end
      else
        local wallH = hgt >= 7 and 2 or 1
        if y > y1 - wallH then
          -- dry-stone terrace wall: a lit top course, dark joints, the odd lichen spot
          local first = (y == y1 - wallH + 1)
          local j = (x + row * 3 + (first and 0 or 2)) % (hgt >= 7 and 6 or 4)
          if first then h = (j == 0) and L.stone.shade or ((hash(x, row, 21) < .5) and L.stone.hi or L.stone.base)
          else h = (j == 0) and L.stone.deep or L.stone.shade end
          if hash(x, y, 22) < .05 then h = L.moss.base end
        else
          local bw0 = math.max(5, floor(hgt * 1.6))
          local xx = x + row * 3
          local bi = xx // bw0
          local fx = (xx % bw0) / bw0
          local hk = .3 + .35 * hash(bi, row, 16)
          local yb = y1 - wallH
          local hh = yb - y0 + 1
          local ty = y0 + floor(hh * hk * (1 - math.sqrt(math.max(0, 1 - (2 * fx - 1) ^ 2))) + .5)
          local ry = (y - y0) / hh
          local v = hash(x, y, 18 + row)
          if y < ty then
            h = (ry < .25) and L.mossGround.deep or L.mossGround.shade
            if hash(x, y, 12) < .1 then h = L.needle.shade end
          elseif R == EDL then
            -- felted silver cushions starred with edelweiss
            local lit = (1 - fx) * .8 - ry * 1.1 + (v - .5) * .6
            h = lit > .3 and EDL.base or (lit > -.3 and EDL.shade or EDL.deep)
            if y == ty then h = EDL.hi end
            if v > .86 and y < yb then h = L.edel.hi end
          elseif R == ARN then
            -- green clumps under a crust of yellow daisies
            local lit = (1 - fx) * .8 - ry * 1.2 + (v - .5) * .7
            if y == ty then h = (fx < .5) and ARN.hi or ARN.base
            elseif lit > .25 then h = (v < .6) and ARN.base or ARN.hi
            elseif lit > -.2 then h = (v < .45) and ARN.shade or L.fern.base
            else h = (v < .5) and L.fern.shade or L.fern.deep end
            if v > .94 then h = ARN.deep end
          else
            local lit = (1 - fx) * .8 - ry * 1.1 + (v - .5) * .7
            if y == ty then h = (fx < .55) and R.hi or R.base
            elseif lit > .45 then h = R.hi
            elseif lit > -.05 then h = R.base
            elseif lit > -.45 then h = R.shade
            else h = (v < .5) and L.fern.deep or R.deep end
            if v > .93 and y > ty then h = L.fern.shade end
          end
          if ry > .85 and y >= ty then h = (v < .5) and L.fern.deep or L.mossGround.deep end
        end
      end
      px(x, y, h)
    end
  end
end
-- the lowest terrace wall, closing the near edge of the field: bigger stones, lit tops, grass tufts over it
do
  local m = HP.mask()
  for x = 262, 479 do if x > F.xr(161) + 4 then for y = 159, 163 do m:set(x, y) end end end
  rimOf(m, L.stone)
  m:each(function(x, y)
    local row = (y - 159) // 2
    local bx = (x + row * 4) % 7
    local h = (bx == 0 or (y - 159) % 2 == 1 and hash(x // 7, y, 23) < .3) and L.stone.deep or (hash((x + row * 4) // 7, row, 24) < .4 and L.stone.hi or L.stone.base)
    if y == 159 then h = (bx == 0) and L.stone.shade or L.stone.hi end
    px(x, y, h)
  end)
  F.lichen(m, .25, 25)
  for x = 270, 476, 7 do local xx = x + floor(hash(x, 1, 26) * 4) if m:has(xx, 159) then px(xx, 158, L.fern.base) px(xx + 1, 157, L.fern.hi) px(xx - 1, 158, L.fern.shade) end end
end

---------------------------------------------------------------- road's end: granite posts, a bent larch arch, alpenrose and clematis
local function arch()
  local pL, pR = rect(215, 84, 220, 126), rect(260, 84, 265, 126)
  local top = c:ellipse(240, 84, 24, 20):cut(c:ellipse(240, 84, 21, 17)):clip(rect(214, 60, 266, 84))
  F.shadow(214, 268, 126, 6, 3)
  -- granite posts: coursed blocks, lit left
  rimOf(union(pL, pR), L.stone)
  for _, p in ipairs({ pL, pR }) do
    part(p, L.stone, { nopop = true })
    F.courses(p, 84, 5, 6, L.stone)
    F.lichen(p, .3, 61)
  end
  vline(216, 85, 125, L.stone.hi) vline(261, 85, 125, L.stone.hi)
  hline(214, 221, 84, L.stone.hi) hline(259, 266, 84, L.stone.hi)
  -- the bent larch pole arch
  rimOf(top, L.timber)
  part(top, L.timber, { nopop = true })
  top:each(function(x, y) if not top:has(x, y - 1) then px(x, y, L.timber.hi) elseif hash(x // 2, y, 62) < .15 then px(x, y, L.timber.deep) end end)
  -- board gate, ajar
  local rails = HP.mask()
  for xx = 222, 236, 3 do rails:add(poly{ { xx, 110 }, { xx + 1, 108 }, { xx + 2, 110 }, { xx + 2, 124 }, { xx, 124 } }) end
  rails:add(rect(222, 112, 238, 113)):add(rect(222, 119, 238, 120))
  rimOf(rails, L.timber) part(rails, L.board, { nopop = true, noshade = true })
  for xx = 222, 236, 3 do vline(xx + 2, 110, 124, L.board.shade) end
  hline(222, 238, 112, L.timber.base) hline(222, 238, 119, L.timber.base)
  -- alpenrose clumps along the arch and posts, clematis bells
  local clumps = { { 213, 122 }, { 222, 106 }, { 213, 94 }, { 220, 80 }, { 225, 69 }, { 233, 64 }, { 247, 64 }, { 255, 68 }, { 262, 80 }, { 267, 94 }, { 259, 108 }, { 267, 122 } }
  for i, p in ipairs(clumps) do
    F.crown(p[1], p[2], 5, 4, (i % 2 == 0) and L.juniper or L.leaf, 100 + i)
    if i % 3 ~= 0 then
      local bx, by = p[1] + (i % 2 == 0 and -2 or 1), p[2] - 2
      fill(rect(bx, by, bx + 2, by + 1), AROSE.base) px(bx, by, AROSE.hi) px(bx + 2, by + 1, AROSE.shade) px(bx + 1, by - 1, AROSE.hi)
      px(bx + 3, by + 2, AROSE.base)
    else
      local bx, by = p[1] - 1, p[2] + 1
      px(bx, by, MONK.hi) px(bx + 1, by, MONK.base) px(bx, by + 1, MONK.base) px(bx + 1, by + 1, MONK.shade) px(bx + 1, by + 2, MONK.deep)
    end
  end
  -- trailing clematis hanging off the crown of the arch
  for _, t in ipairs({ { 231, 70, 7 }, { 249, 69, 9 }, { 240, 67, 4 } }) do
    for k = 0, t[3] do px(t[1] + floor(sin(k * .9) + .5), t[2] + k, k % 3 == 0 and L.leaf.base or L.leaf.deep) end
    px(t[1], t[2] + t[3] + 1, MONK.base) px(t[1], t[2] + t[3] + 2, MONK.deep)
  end
end

---------------------------------------------------------------- back-left: dry-stone drying hut and cold frame
local function rubble(m, y0, seed)
  m:each(function(x, y)
    local row = (y - y0) // 3
    local ry = (y - y0) % 3
    local bw = 4 + floor(hash(row, 1, seed) * 3)
    local rx = (x + row * 2) % bw
    local v = hash((x + row * 2) // bw, row, seed + 1)
    local h = v < .35 and L.stone.hi or (v < .8 and L.stone.base or L.stone.shade)
    if ry == 2 or rx == 0 then h = L.stone.deep end
    if ry == 0 and rx ~= 0 and v < .6 then h = L.stone.hi end
    px(x, y, h)
  end)
end
local function hut()
  local htop, hcx, hwall, hroof = F.building{ x0 = 26, x1 = 60, yb = 140, wh = 18, rh = 14, wall = L.stone, roof = L.roof, shingle = true, noFrame = true, noAttic = true }
  local gab = poly{ { 31, htop }, { hcx, htop - 6 }, { 55, htop } }
  rubble(hwall:copy():add(gab):cut(hroof), htop - 6, 70)
  F.lichen(hwall, .2, 72) F.lichen(hroof, .25, 73)
  -- a low dark door and a vent slit
  local d = rect(36, 128, 43, 140) fill(d, L.timber.edge) fill(rect(37, 129, 42, 140), L.soil.edge) vline(42, 129, 139, L.timber.deep)
  vline(hcx, htop - 3, htop - 1, L.timber.edge)
  -- bundles hung under the eave
  for k = 0, 4 do
    local x = 46 + k * 3
    local r = ({ ARN, THY, EDL, GEN, ARN })[k + 1]
    px(x, htop + 4, L.timber.edge) vline(x, htop + 5, htop + 8, r.base) px(x, htop + 5, r.hi) px(x, htop + 9, r.deep)
  end
  -- a weighting stone on the ridge
  local ws = c:ellipse(hcx, htop - 13, 2, 1) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true })
  -- glazed cold frame against the hut's right side
  local fr = poly{ { 62, 130 }, { 80, 135 }, { 80, 140 }, { 62, 140 } }
  local glass = poly{ { 63, 131 }, { 79, 136 }, { 63, 136 } }
  rimOf(fr, L.timber) part(fr, L.timber, { nopop = true, noshade = true })
  fill(glass, L.water.hi)
  glass:each(function(x, y) if (x - y) % 7 == 0 then px(x, y, "#eef4f2") elseif hash(x, y, 74) < .2 then px(x, y, L.water.base) end end)
  for x = 66, 76, 4 do px(x, 135, L.leaf.base) px(x + 1, 134, L.leaf.hi) end
  vline(70, 133, 136, L.timber.base) vline(74, 134, 136, L.timber.base)
  rubble(rect(63, 137, 79, 139), 137, 75)
end

---------------------------------------------------------------- left hero: herbalist's chalet
local function chalet()
  local top, cx, wallM, roofM = F.building{ x0 = 96, x1 = 182, yb = 182, wh = 46, rh = 32, wall = L.timber, roof = L.roof, chimney = true, shingle = true, noFrame = true, noAttic = true }
  -- larch boards above, whitewashed granite below
  local boards = wallM:copy():clip(rect(96, top + 2, 182, 158))
  F.planks(boards, L.timber, 4, false, 44)
  boards:each(function(x, y) if y < top + 9 and hash(x, y, 45) < .25 then px(x, y, L.timber.deep) end end)
  local foot = rect(96, 159, 182, 182)
  part(foot, L.plaster, { nopop = true })
  foot:each(function(x, y)
    local row = (y - 159) // 5
    local ry = (y - 159) % 5
    local bw = 7 + floor(hash(row, 1, 46) * 4)
    local rx = (x + row * 3) % bw
    if ry == 0 or rx == 0 then px(x, y, L.plaster.shade)
    elseif hash((x + row * 3) // bw, row, 47) < .28 then px(x, y, (ry == 1) and L.stone.hi or L.stone.base)
    elseif ry == 1 and rx == 1 then px(x, y, L.plaster.hi) end
    if y > 178 and hash(x, y, 48) < .35 then px(x, y, L.stone.shade) end
  end)
  hline(96, 182, 158, L.timber.edge)
  local corners = union(rect(96, top, 98, 157), rect(180, top, 182, 157))
  part(corners, L.timber, { nopop = true, noshade = true })
  -- the gable: pale boards, an open drying loft hung with herb bundles on two poles
  local gableM = poly{ { 101, top }, { cx, top - 24 }, { 177, top } }
  F.planks(gableM, L.board, 4, true, 49)
  gableM:each(function(x, y) if hash(x // 4, y, 50) < .2 then px(x, y, L.board.shade) end end)
  local loft = poly{ { 112, top - 1 }, { cx, top - 18 }, { 166, top - 1 } }
  local loftRim = loft:grow(1):cut(loft)
  loftRim:each(function(x, y) if gableM:has(x, y) then px(x, y, L.timber.base) end end)
  fill(loft, L.timber.edge)
  loft:each(function(x, y) if hash(x, y // 2, 51) < .25 then px(x, y, L.soil.edge) end end)
  for _, pole in ipairs({ { top - 12, 3 }, { top - 6, 5 } }) do
    local py, n = pole[1], pole[2]
    local x0, x1
    for x = 100, 178 do if loft:has(x, py) then x0 = x0 or x x1 = x end end
    hline(x0 - 1, x1 + 1, py, L.board.base) hline(x0 - 1, x1 + 1, py + 1, L.board.deep) px(x0 - 1, py, L.board.hi)
    local k = 0
    for x = x0 + 2, x1 - 2, 4 do
      k = k + 1
      local r = ({ ARN, THY, EDL, GEN, L.fern, ARN, THY })[(k + n) % 7 + 1]
      local len = 4 + (k % 2)
      vline(x, py + 2, py + 1 + len, r.base) px(x - 1, py + 2, r.hi) px(x + 1, py + 3, r.shade) px(x, py + 2 + len, r.deep)
      px(x - 1, py + 3, r.base) px(x + 1, py + 2, r.base)
    end
  end
  F.lichen(roofM, .18, 52)
  -- weighting stones along the slab roof
  for _, w in ipairs({ { 108, 128 }, { 124, 116 }, { 154, 116 }, { 170, 128 } }) do
    local ws = c:ellipse(w[1], w[2], 3, 2) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true }) px(w[1] - 1, w[2] - 1, L.stone.hi)
  end
  -- arched larch door, iron strap hinges, an edelweiss-and-arnica wreath
  local d = c:rrect(130, 156, 146, 181, 7):clip(rect(130, 156, 146, 181))
  rimOf(d, L.timber) part(d, L.timber) c:edgeIn(d, L.timber.edge)
  for x = 134, 143, 3 do vline(x, 159, 180, L.timber.shade) end
  hline(131, 140, 163, L.iron.shade) hline(131, 140, 174, L.iron.shade) px(131, 163, L.iron.hi) px(131, 174, L.iron.hi)
  fill(c:ellipse(143, 170, 1, 1), L.gold.base) px(142, 169, L.gold.hi)
  local wr = c:ellipse(138, 152, 4, 3):cut(c:ellipse(138, 152, 2, 1))
  wr:each(function(x, y) px(x, y, (x + y) % 2 == 0 and L.juniper.base or L.juniper.shade) end)
  for _, f in ipairs({ { 135, 150 }, { 141, 150 }, { 138, 155 } }) do px(f[1], f[2], L.edel.hi) px(f[1] + 1, f[2], L.edel.base) end
  px(134, 153, ARN.base) px(142, 154, ARN.base) px(138, 149, ARN.hi)
  F.window(106, 146, 116, 154, L.timber) F.window(160, 146, 170, 154, L.timber)
  F.window(104, 166, 109, 171, L.timber) F.window(166, 166, 171, 171, L.timber)
  -- window boxes with red alpenrose and blue gentian
  for _, wx in ipairs({ 104, 158 }) do
    local bx = rect(wx, 156, wx + 14, 158) rimOf(bx, L.timber) part(bx, L.timber, { nopop = true })
    for k = 0, 6 do local fx = wx + 1 + k * 2
      px(fx, 155, L.leaf.base) px(fx + 1, 154, L.leaf.hi) px(fx, 156, L.leaf.shade)
      px(fx, 153, (k % 2 == 0) and AROSE.base or GEN.base) px(fx + 1, 153, (k % 2 == 0) and AROSE.hi or GEN.hi)
    end
  end
  -- drying bundles hanging from the eave pole
  hline(98, 180, top + 5, L.timber.deep)
  for k = 0, 10 do
    local x = 100 + k * 8
    local r = ({ ARN, THY, L.fern, GEN, EDL })[k % 5 + 1]
    if (x >= 104 and x <= 118) or (x >= 158 and x <= 172) then goto skip end
    vline(x, top + 6, top + 7, L.timber.edge)
    local b = poly{ { x - 2, top + 8 }, { x + 2, top + 8 }, { x + 1, top + 14 }, { x - 1, top + 14 } }
    fill(b, r.base) px(x - 1, top + 9, r.hi) px(x - 1, top + 12, r.hi) vline(x + 1, top + 10, top + 13, r.shade) hline(x - 2, x + 2, top + 8, L.board.deep)
    px(x, top + 14, r.deep)
    ::skip::
  end
  -- hanging mortar & pestle sign on an iron bracket
  hline(184, 198, 152, L.iron.base) hline(184, 198, 153, L.iron.deep) px(184, 152, L.iron.hi)
  vline(188, 154, 157, L.timber.edge) vline(196, 154, 157, L.timber.edge)
  local mortar = poly{ { 185, 160 }, { 199, 160 }, { 197, 167 }, { 193, 170 }, { 191, 170 }, { 187, 167 } }
  local pestle = line({ { 196, 158 }, { 201, 152 } }, 2)
  rimOf(union(mortar, pestle), L.stone) part(mortar, L.stone) part(pestle, L.board, { nopop = true })
  hline(185, 199, 160, L.stone.hi) hline(187, 197, 161, L.stone.deep)
  px(189, 159, ARN.hi) px(190, 158, ARN.base) px(192, 159, GEN.base)
  -- a split larch woodpile against the left foot
  return top
end

---------------------------------------------------------------- stone-edged raised beds in perspective (right of road)
local function bed(x0, x1, y0, y1, plant, seed)
  local soil = poly{ { x0 + 4, y0 }, { x1, y0 }, { x1 + 4, y1 }, { x0, y1 } }
  local front = rect(x0, y1, x1 + 4, y1 + 4)
  F.shadow(x0, x1 + 4, y1 + 4, 6, 2)
  rimOf(union(soil, front), L.stone)
  fill(soil, L.soil.shade)
  soil:each(function(x, y) local v = hash(x, y, seed) if v < .18 then px(x, y, L.soil.deep) elseif v > .92 then px(x, y, L.stone.base) end end)
  -- granite coping along the back edge
  line({ { x0 + 4, y0 }, { x1, y0 } }):each(function(x, y) px(x, y, (x % 6 == 0) and L.stone.shade or L.stone.base) end)
  -- the front: dressed granite blocks, lit top course, lichen
  part(front, L.stone, { nopop = true })
  front:each(function(x, y)
    local row = (y - y1) // 2
    local bx = (x + row * 5 + seed) % 9
    if y == y1 then px(x, y, bx == 0 and L.stone.shade or L.stone.hi)
    elseif (y - y1) % 2 == 0 or bx == 0 then px(x, y, L.stone.deep)
    elseif hash((x + row * 5) // 9, row, seed + 3) < .35 then px(x, y, L.stone.hi) end
  end)
  F.lichen(front, .3, seed + 30)
  local n = (x1 - x0) // 7
  for k = 0, n - 1 do plant(x0 + 6 + k * 7, y0 + (y1 - y0) // 2 + 2, k) end
end
local EDLF = F.rp("#d2dcc4 #a8b89a #84967a #627460 #44523f")   -- woolly grey-green edelweiss leaves
local function edelweissPlant(x, y, k)
  -- a low felted mat, then a rosette of woolly lance leaves, lit on the left
  c:ellipse(x, y - 1, 4, 2):each(function(xx, yy) local v = hash(xx, yy, 203) px(xx, yy, v < .35 and L.fern.shade or (v < .7 and EDLF.shade or (v < .85 and L.fern.deep or EDLF.base))) end)
  for j, d in ipairs({ { -3, -1 }, { -2, -3 }, { 0, -3 }, { 2, -3 }, { 3, -1 }, { 4, 0 }, { -4, 0 } }) do
    line({ { x, y }, { x + d[1], y + d[2] } }):each(function(xx, yy) px(xx, yy, d[1] < 0 and EDLF.base or EDLF.shade) end)
    px(x + d[1], y + d[2], d[1] < 0 and EDLF.hi or EDLF.base)
  end
  px(x, y, EDLF.deep) px(x - 1, y, EDLF.deep) px(x + 1, y, EDLF.deep)
  vline(x, y - 4, y - 2, EDLF.deep)
  F.edelweiss(x, y - 5, true)
  if k % 2 == 1 then vline(x + 3, y - 2, y - 1, EDLF.deep) px(x + 3, y - 3, L.edel.hi) px(x + 4, y - 3, L.edel.base) px(x + 3, y - 4, L.edel.base) end
end
local function arnica(x, y, k)
  local m = c:ellipse(x, y - 2, 3, 2) fill(m, L.leaf.shade) px(x - 2, y - 3, L.leaf.hi) px(x + 2, y - 1, L.leaf.deep)
  vline(x, y - 8, y - 3, L.leaf.deep) vline(x + 2, y - 6, y - 3, L.leaf.deep)
  -- daisy heads: rayed yellow, orange disc
  hline(x - 2, x + 2, y - 9, ARN.base) px(x - 2, y - 9, ARN.hi) px(x - 1, y - 10, ARN.hi) px(x + 1, y - 10, ARN.base) px(x, y - 9, ARN.deep) px(x, y - 8, ARN.shade)
  hline(x + 1, x + 3, y - 7, ARN.base) px(x + 2, y - 7, ARN.deep) px(x + 2, y - 8, ARN.hi)
end
local function gentianPlant(x, y, k)
  local m = c:ellipse(x, y - 1, 4, 2) fill(m, L.leaf.shade)
  px(x - 3, y - 2, L.leaf.base) px(x - 2, y - 2, L.leaf.hi) px(x + 3, y, L.leaf.deep)
  F.gentian(x - 1, y - 4, true)
  F.gentian(x + 2, y - 3, true)
  if k % 2 == 0 then F.gentian(x, y - 6, false) end
end
local CATN = F.rp("#c6dcb6 #9cba8a #789868 #587652 #3c523e")
local function catnip(x, y, k)
  local m = F.crown(x, y - 3, 3, 3, CATN, 200 + k)
  m:each(function(xx, yy) if hash(xx, yy, 201) < .18 then px(xx, yy, CATN.hi) elseif hash(xx, yy, 202) < .12 then px(xx, yy, CATN.deep) end end)
  vline(x - 1, y - 9, y - 6, CATN.deep) px(x - 1, y - 9, THY.hi) px(x - 1, y - 8, THY.base) px(x - 2, y - 8, THY.shade)
  if k % 2 == 0 then vline(x + 2, y - 8, y - 6, CATN.deep) px(x + 2, y - 8, THY.hi) px(x + 3, y - 7, THY.base) end
end

---------------------------------------------------------------- compose: back to front
F.depth(1)
F.tree(86, 130, 40, 2)
F.larch(12, 144, 46, 51)
hut()
-- two far gnomes picking on the terraces, a goat nosing at the top one
F.gnome(420, 150, { small = true, hat = L.awnA, coat = L.wall2, arm = "out" })
F.gnome(352, 138, { small = true, hat = L.foliage2, coat = L.board, flip = true })
F.goat(462, 124, { k = .38, graze = true, flip = true, noShadow = true })
-- juniper and alpenrose cushions along the left back, behind the chalet
for x = 104, 206, 10 do
  local m = F.bush(x, 134 + (x % 3), 6, 7, (x % 20 == 4) and L.juniper or L.foliage2, x)
  if x % 20 ~= 4 then px(x - 2, 130 + (x % 3), AROSE.base) px(x + 1, 129 + (x % 3), AROSE.hi) end
end
F.depth(2)
F.tree(204, 128, 46, 0)
F.larch(284, 130, 46, 7)
arch()
F.tree(460, 168, 60, 2)
F.depth(3)
local ctop = chalet()
F.smoke(172, 102, 7, .5, 2)
-- herb drying A-frame rack near the road (left): larch poles, bundles, a garland of arnica heads
local function dryRack(x0, yb)
  local legs = line({ { x0, yb }, { x0 + 6, yb - 26 }, { x0 + 12, yb } }, 2):add(line({ { x0 + 30, yb }, { x0 + 36, yb - 26 }, { x0 + 42, yb } }, 2))
  local bar = rect(x0 + 4, yb - 26, x0 + 38, yb - 25)
  F.shadow(x0, x0 + 42, yb, 6, 2)
  rimOf(union(legs, bar), L.timber) part(legs, L.timber, { nopop = true, noshade = true }) part(bar, L.timber, { nopop = true, noshade = true })
  hline(x0 + 5, x0 + 37, yb - 26, L.timber.hi)
  for k = 0, 5 do
    local x = x0 + 9 + k * 5
    local r = ({ ARN, GEN, THY, EDL, L.fern, ARN })[k + 1]
    vline(x, yb - 24, yb - 22, L.timber.edge)
    local b = poly{ { x - 2, yb - 21 }, { x + 2, yb - 21 }, { x + 1, yb - 12 }, { x - 1, yb - 12 } }
    rimOf(b, r) fill(b, r.base) px(x - 1, yb - 20, r.hi) px(x - 1, yb - 17, r.hi) vline(x + 1, yb - 19, yb - 13, r.shade)
    hline(x - 2, x + 2, yb - 21, L.board.deep)
    px(x, yb - 15, r.hi) px(x, yb - 13, r.deep)
  end
  for xx = x0 + 6, x0 + 36 do
    local t = (xx - x0 - 6) / 30
    local yy = floor(yb - 9 + 4 * 4 * t * (1 - t))
    px(xx, yy, L.board.deep)
    if (xx - x0) % 4 == 0 then px(xx, yy + 1, ARN.shade) px(xx - 1, yy, ARN.base) px(xx + 1, yy, ARN.base) px(xx, yy - 1, ARN.hi) end
  end
end
dryRack(160, 214)
-- the beds on the right, near ones larger
bed(276, 360, 166, 174, edelweissPlant, 3)
bed(282, 380, 182, 192, arnica, 4)
bed(290, 400, 202, 214, gentianPlant, 5)
bed(300, 376, 228, 242, catnip, 6)
-- quirk: a ginger tabby curled up asleep in the catnip at the near bed's end, an Apollo butterfly on its ear
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
  -- Apollo butterfly: cream wings with red eye-spots
  F.sprite({ "a.a", ".k.", "a.a" }, 339, 223, { a = L.awnB.hi, k = L.timber.edge }, { rim = false })
  px(338, 223, L.awnA.base) px(342, 225, L.awnA.base)
  local bub = c:ellipse(328, 222, 2, 2) fill(bub, L.water.hi) px(327, 221, "#eef4f2")
  px(332, 225, L.water.hi)
end
-- larch potting table with pots, jars of arnica oil, a basket of cut gentian
local function pottingTable()
  local top = rect(402, 172, 452, 175)
  local legs = rect(405, 176, 407, 196):add(rect(447, 176, 449, 196))
  local shelf = rect(404, 188, 450, 189)
  F.shadow(404, 452, 196, 8, 3)
  rimOf(union(top, legs, shelf), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true }) part(shelf, L.timber, { nopop = true, noshade = true }) part(top, L.board)
  F.planks(top, L.board, 6, true, 21)
  for k = 0, 2 do
    local x = 406 + k * 12
    local pot = poly{ { x, 165 }, { x + 8, 165 }, { x + 7, 171 }, { x + 1, 171 } }
    rimOf(pot, L.roof2) part(pot, L.roof2, { nopop = true }) hline(x, x + 8, 165, L.roof2.hi)
    if k == 0 then
      local pl = c:ellipse(x + 4, 162, 3, 2) fill(pl, EDL.shade) px(x + 2, 161, EDL.hi) F.edelweiss(x + 4, 159, true)
    elseif k == 1 then
      local pl = c:ellipse(x + 4, 162, 3, 2) fill(pl, L.leaf.shade) px(x + 2, 161, L.leaf.hi) F.gentian(x + 3, 160, true) F.gentian(x + 6, 161, true)
    else
      local pl = c:ellipse(x + 4, 161, 4, 3) fill(pl, THY.base) pl:each(function(xx, yy) if hash(xx, yy, 77) < .3 then px(xx, yy, THY.hi) elseif hash(xx, yy, 78) < .25 then px(xx, yy, L.fern.shade) end end)
    end
  end
  for k = 0, 1 do
    local x = 442 + k * 6
    local jar = rect(x - 2, 164, x + 2, 171) fill(jar, L.water.hi) fill(rect(x - 1, 167, x + 1, 171), (k == 0) and ARN.shade or GEN.base) hline(x - 2, x + 2, 164, L.timber.base) px(x - 2, 166, "#eef4f2")
  end
  -- a mortar on the table edge
  local mo = poly{ { 434, 168 }, { 440, 168 }, { 439, 171 }, { 435, 171 } } fill(mo, L.stone.base) hline(434, 440, 168, L.stone.hi) px(439, 167, L.board.base) px(440, 166, L.board.base)
  -- basket of cut gentian on the shelf, pots stacked
  local bk = poly{ { 430, 181 }, { 446, 181 }, { 444, 187 }, { 432, 187 } }
  rimOf(bk, L.needle) part(bk, L.needle, { nopop = true }) bk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) end end)
  for k = 0, 4 do local mx = 432 + k * 3 px(mx, 180, GEN.base) px(mx + 1, 180, GEN.shade) px(mx, 179, GEN.hi) end
  for k = 0, 1 do local x = 408 + k * 10 local pot = rect(x, 184, x + 6, 187) fill(pot, L.roof2.shade) hline(x, x + 6, 184, L.roof2.base) end
end
pottingTable()
-- painted box hives under slab-stone lids on a larch bench
local function hives()
  local bench = rect(410, 214, 462, 216):add(rect(412, 217, 414, 224)):add(rect(458, 217, 460, 224))
  F.shadow(410, 462, 224, 6, 2)
  rimOf(bench, L.timber) part(bench, L.timber, { nopop = true, noshade = true })
  local fronts = { GEN, L.awnA, ARN }
  for k = 0, 2 do
    local x = 420 + k * 16
    local hb = rect(x - 6, 199, x + 6, 213)
    local lid = poly{ { x - 8, 200 }, { x, 193 }, { x + 8, 200 } }:add(rect(x - 8, 199, x + 8, 200))
    rimOf(union(hb, lid), L.timber)
    part(hb, L.board)
    hb:each(function(xx, yy) if (yy - 199) % 4 == 3 then px(xx, yy, L.board.shade) end end)
    -- the painted front panel: a little picture on each
    local fr = fronts[k + 1]
    local pn = rect(x - 4, 202, x + 4, 208)
    fill(pn, fr.base) hline(x - 4, x + 4, 202, fr.hi) vline(x + 4, 202, 208, fr.shade) hline(x - 4, x + 4, 208, fr.deep)
    if k == 0 then F.edelweiss(x, 205, true)
    elseif k == 1 then px(x - 1, 204, L.awnB.hi) px(x, 205, L.awnB.hi) px(x + 1, 204, L.awnB.hi) px(x, 206, L.awnB.base)
    else hline(x - 2, x + 2, 205, L.timber.base) px(x, 204, L.timber.base) px(x - 1, 206, L.timber.base) px(x + 1, 206, L.timber.base) end
    hline(x - 2, x + 2, 211, L.timber.edge) px(x - 2, 210, L.board.deep)
    part(lid, L.roof, { nopop = true })
    F.courses(lid, 193, 3, 5, L.roof)
    line({ { x - 7, 199 }, { x, 193 } }):each(function(xx, yy) px(xx, yy, L.roof.hi) end)
    F.lichen(lid, .25, 80 + k)
    local ws = c:ellipse(x, 193, 2, 1) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true })
  end
  for i = 0, 7 do local bx, by = 414 + floor(hash(i, 1, 3) * 48), 182 + floor(hash(i, 2, 3) * 10) px(bx, by, L.gold.base) px(bx + 1, by, L.timber.edge) px(bx, by - 1, L.water.hi) end
end
hives()
-- lichened granite herb spiral, bottom-left: thyme, edelweiss, gentian, an arnica crown
local function spiral(cx, cy)
  F.shadow(cx - 36, cx + 40, cy + 14, 8, 3)
  local tiers = { { 40, 13, 0, THY }, { 28, 9, 9, EDL }, { 16, 6, 17, GEN } }
  for i, t in ipairs(tiers) do
    local rx, ry, up, rr = t[1], t[2], t[3], t[4]
    local tp = c:ellipse(cx, cy - up - 4, rx, ry)
    local body = union(tp, c:ellipse(cx, cy - up, rx, ry))
    rimOf(body, L.stone)
    local face = c:ellipse(cx, cy - up, rx, ry):cut(tp)
    face:each(function(x, y)
      local k = (x + (y % 4 < 2 and 0 or 3)) % 6
      px(x, y, (k == 0 or y % 4 == 0) and L.stone.deep or ((x < cx - rx // 2) and L.stone.hi or L.stone.base))
    end)
    F.lichen(face, .3, 50 + i)
    fill(tp, L.soil.shade)
    tp:each(function(x, y)
      local v = hash(x, y, i * 7)
      if rr == EDL then
        if v < .4 then px(x, y, L.fern.base) elseif v < .55 then px(x, y, EDL.base) elseif v < .62 then px(x, y, L.edel.hi) elseif v < .78 then px(x, y, L.fern.shade) end
      elseif v < .45 then px(x, y, rr.base) elseif v < .55 then px(x, y, rr.hi) elseif v < .7 then px(x, y, (rr == GEN) and L.leaf.shade or rr.shade) end
      if rr == THY and hash(x, y, 81) < .12 then px(x, y, L.fern.shade) end
    end)
    c:edgeIn(tp, L.stone.base)
  end
  -- an arnica clump crowning the top
  for j = -2, 2 do vline(cx + j * 2, cy - 27 + abs(j), cy - 22, L.leaf.shade) end
  for j = -2, 2 do local fx, fy = cx + j * 2, cy - 28 + abs(j) px(fx, fy, ARN.base) px(fx - 1, fy, ARN.hi) px(fx, fy + 1, ARN.deep) end
  for _, p in ipairs({ { cx - 28, cy - 6 }, { cx + 18, cy - 4 }, { cx - 8, cy - 16 } }) do px(p[1], p[2], L.edel.hi) px(p[1] + 1, p[2], ARN.hi) end
end
spiral(74, 248)
-- yellow gentian and monkshood spires along the left: swaying stems, big low, small to the green tip
for k, x in ipairs({ 26, 36, 46, 58, 70, 82 }) do
  local yb, h = 206 + (k % 2) * 3, 32 + floor(hash(k, 1, 5) * 20)
  local yellow = (k % 2 == 1)
  local r = yellow and YG or MONK
  local function sx(y) return x + floor(sin((yb - y) / h * 2.2 + k) * 2 * (yb - y) / h + .5) end
  for y = yb - h, yb do px(sx(y), y, L.leaf.shade) px(sx(y) + 1, y, L.leaf.deep) end
  -- basal leaves: broad ribbed blue-green (yellow gentian) or dark palmate (monkshood)
  local bx0 = sx(yb)
  local LR = yellow and L.juniper or L.leaf
  for j, lf in ipairs({ { -9, -2 }, { -7, -6 }, { -3, -8 }, { 4, -8 }, { 8, -5 }, { 10, -1 } }) do
    local ex, ey = bx0 + lf[1], yb + lf[2] + floor(hash(j, k, 8) * 2)
    local m = line({ { bx0, yb }, { (bx0 + ex) // 2 + (lf[1] < 0 and -1 or 1), (yb + ey) // 2 - 1 }, { ex, ey } }, yellow and 3 or 2)
    c:rim(m, LR.edge) part(m, LR, { nopop = true })
    line({ { bx0, yb - 1 }, { (bx0 + ex) // 2, (yb + ey) // 2 - 2 } }):each(function(xx, yy) if m:has(xx, yy) then px(xx, yy, LR.hi) end end)
  end
  if yellow then
    -- whorls of starry yellow flowers in the axils of paired leaves, buds at the tip
    local i = 0
    for y = yb - 14, yb - h + 3, -6 do
      i = i + 1
      local t = (yb - 14 - y) / math.max(1, h - 17)
      local cx = sx(y)
      local w = t < .5 and 3 or 2
      hline(cx - w - 2, cx - 1, y + 2, L.juniper.base) hline(cx + 2, cx + w + 3, y + 2, L.juniper.shade) px(cx - w - 2, y + 2, L.juniper.hi)
      hline(cx - w, cx + w + 1, y, YG.base) hline(cx - w + 1, cx + w, y - 1, YG.hi) hline(cx - w + 1, cx + w, y + 1, YG.shade)
      px(cx - w, y - 1, YG.base) px(cx + w + 1, y + 1, YG.deep) px(cx, y, YG.deep)
      if w == 3 then px(cx - w - 1, y, YG.hi) px(cx + w + 2, y, YG.shade) end
    end
    px(sx(yb - h), yb - h - 1, YG.base) px(sx(yb - h) + 1, yb - h, L.leaf.base)
  else
    -- monkshood: hooded blue-violet flowers alternating up the spire
    local i = 0
    for y = yb - 15, yb - h + 2, -2 do
      i = i + 1
      local t = (yb - 17 - y) / math.max(1, h - 19)
      local side = (i % 2 == 0) and 1 or -1
      if t < .75 then
        -- a hooded flower each side, the helmet lit, the open lip dark
        for _, sd in ipairs({ side, -side }) do
          local bx = (sd > 0) and sx(y) + 2 or sx(y) - 1
          if sd == side or t < .5 then
            px(bx, y - 1, r.hi) px(bx + sd, y - 1, r.base) px(bx, y, r.base) px(bx + sd, y, r.shade) px(bx + sd, y + 1, r.deep)
            if t < .4 then px(bx + sd * 2, y, r.shade) end
          end
        end
        px(sx(y) - 1, y + 1, L.leaf.base)
      elseif t < .92 then
        px(sx(y) + (side > 0 and 2 or -1), y, r.shade) px(sx(y) - 1, y, L.leaf.base)
      else
        px(sx(y) - 1, y, L.leaf.base)
      end
    end
    px(sx(yb - h), yb - h - 1, L.leaf.hi)
  end
end
-- gnome harvesting with a basket of arnica and gentian
local _, gx, gy = F.gnome(268, 218, { hat = THY, coat = L.fern, arm = "out" })
local bsk = poly{ { gx - 1, gy - 1 }, { gx + 11, gy - 1 }, { gx + 9, gy + 6 }, { gx + 1, gy + 6 } } rimOf(bsk, L.needle) part(bsk, L.needle)
bsk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) end end)
for k = 0, 4 do
  local col = ({ ARN, GEN, ARN, EDL, GEN })[k + 1]
  px(gx + 1 + k * 2, gy - 2, col.base) px(gx + 1 + k * 2, gy - 3, col.hi)
end
-- the waterer, tipping a copper can over the herb spiral
local _, wx, wy = F.gnome(164, 254, { hat = L.awnA, coat = L.wall2, arm = "out", flip = true })
local wcan = rect(wx - 8, wy - 3, wx - 1, wy + 3):add(line({ { wx - 8, wy }, { wx - 14, wy - 4 } }, 2))
rimOf(wcan, COP) part(wcan, COP) fill(rect(wx - 16, wy - 6, wx - 13, wy - 4), COP.shade)
hline(wx - 8, wx - 1, wy - 1, COP.hi)
for k = 0, 4 do px(wx - 17 - k, wy - 3 + k * 2, L.water.hi) px(wx - 15 - k, wy - 2 + k * 2, L.water.base) end
-- a whistling marmot sat up by its burrow under the drying rack, a fallen arnica bundle
do
  local hole = c:ellipse(148, 233, 6, 2) c:rim(hole, L.soil.shade) fill(hole, L.soil.edge) hline(143, 153, 231, L.soil.base)
  F.marmot(148, 232)
  px(154, 220, L.edel.hi) px(156, 219, L.edel.base) px(157, 218, L.edel.hi)
  local b = poly{ { 156, 230 }, { 164, 228 }, { 164, 231 }, { 156, 232 } } rimOf(b, ARN) fill(b, ARN.base) px(157, 230, ARN.hi) hline(163, 165, 229, L.board.deep)
end
-- granite boulders, edelweiss and gentian tucked around the garden
F.boulder(204, 196, 6, 5, 91)
F.boulder(94, 214, 5, 4, 92)
F.boulder(12, 222, 7, 6, 93)
for _, f in ipairs({ { 88, 188 }, { 186, 190 }, { 22, 230 }, { 120, 214 }, { 214, 236 }, { 284, 224 } }) do F.edelweiss(f[1], f[2], true) end
for _, f in ipairs({ { 92, 190 }, { 190, 188 }, { 126, 216 }, { 218, 240 }, { 280, 226 }, { 20, 226 } }) do F.gentian(f[1], f[2], true) end
F.juniper(198, 186, 6, 4, 5)
F.depth(0)
-- bees over the hives and the terraces, Apollo and blue butterflies
for i = 0, 14 do local bx, by = 300 + floor(hash(i, 1, 33) * 170), 140 + floor(hash(i, 2, 33) * 80) px(bx, by, L.gold.base) px(bx + 1, by, L.timber.edge) px(bx, by - 1, L.water.hi) end
F.sprite({ "a.a", ".k.", "a.a" }, 330, 128, { a = L.awnB.hi, k = L.timber.edge }, { rim = false }) px(330, 128, L.awnA.base)
F.sprite({ "a.a", ".k.", "a.a" }, 120, 200, { a = GEN.hi, k = L.timber.edge }, { rim = false })
F.sprite({ "a.a", ".k.", "a.a" }, 240, 196, { a = L.awnB.hi, k = L.timber.edge }, { rim = false }) px(242, 198, L.awnA.base)
F.birds({ { 330, 44, 2 }, { 344, 40, 1 }, { 120, 60, 2 } })
-- bottom right: a carved granite trough of houseleeks, a larch tub of masterwort
F.depth(3)
do
  local tr = rect(290, 252, 326, 263)
  F.shadow(290, 328, 264, 6, 2)
  rimOf(tr, L.stone) part(tr, L.stone)
  hline(291, 325, 252, L.stone.hi) hline(291, 325, 254, L.stone.deep)
  tr:each(function(x, y) if y > 255 and (x - 290) % 12 == 0 then px(x, y, L.stone.shade) end end)
  F.lichen(tr, .3, 95)
  -- houseleek rosettes: green stars with red tips, one in flower
  for k = 0, 4 do
    local x = 294 + k * 7
    local y = 250 + (k % 2)
    local ro = c:ellipse(x, y, 3, 2) c:rim(ro, L.leaf.edge) fill(ro, L.leaf.shade)
    px(x - 1, y - 1, L.leaf.hi) px(x - 2, y, L.leaf.base) px(x, y - 1, L.leaf.base) px(x + 1, y, L.leaf.deep) px(x, y, L.leaf.deep)
    px(x - 3, y, AROSE.base) px(x + 3, y, AROSE.shade) px(x, y - 2, AROSE.base) px(x - 2, y + 2, AROSE.shade) px(x + 2, y - 2, AROSE.shade)
  end
  vline(308, 240, 249, L.leaf.shade) hline(306, 310, 239, AROSE.base) px(307, 238, AROSE.hi) px(309, 238, AROSE.base) px(308, 240, AROSE.deep)
  -- larch tub with masterwort
  local x = 368
  local pot = poly{ { x - 7, 252 }, { x + 7, 252 }, { x + 6, 264 }, { x - 6, 264 } }
  rimOf(pot, L.timber) part(pot, L.timber)
  pot:each(function(xx, yy) if (xx - x + 7) % 3 == 0 then px(xx, yy, L.timber.deep) end end)
  hline(x - 7, x + 7, 254, L.iron.shade) hline(x - 6, x + 6, 261, L.iron.shade) hline(x - 7, x + 7, 252, L.timber.hi)
  for _, s in ipairs({ { -3, 232 }, { 2, 228 }, { 5, 236 }, { -5, 240 }, { 0, 238 } }) do
    vline(x + s[1], s[2], 251, L.leaf.shade)
    local ux, uy = x + s[1], s[2]
    hline(ux - 2, ux + 2, uy, EDL.base) hline(ux - 1, ux + 1, uy - 1, L.edel.hi) px(ux, uy, THY.shade) px(ux - 2, uy + 1, L.leaf.deep) px(ux + 2, uy + 1, L.leaf.deep)
  end
  local lf = c:ellipse(x, 249, 6, 2) fill(lf, L.leaf.base) px(x - 4, 248, L.leaf.hi) px(x + 4, 250, L.leaf.deep)
end
F.finish()
