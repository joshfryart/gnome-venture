-- herb.lua : "Herb garden" stop look, FOREST (forest_pinewood), 480x270 gate view.
-- Same composition as the Maplewold herb (art-2701-batch3/stops/opus3/herb.lua), re-cast for a pine wood:
-- right: rows of heather and wild garlic running back to the tree line (replaces the lavender), two far gnomes gathering.
-- Road's end: a bent-birch arch climbed by hops and dog roses, a split-rail gate ajar.
-- Back left: a timber-framed glasshouse on a mossy footing beside a birch and a spruce.
-- Left hero: the herbalist's log cabin with a mossy shingle roof, drying bundles and mushroom strings under the eave,
-- a round green door and a mortar-and-pestle sign. Log-edged beds (ramsons, chanterelle logs, wild strawberries,
-- catnip), a potting table, log-gum bee hives, a mossy stone herb spiral, foxgloves along the left, half-barrel tubs
-- of fern and angelica, a fairy ring and a hedgehog. Quirk: a ginger cat asleep in the catnip bed, a butterfly on its ear.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-forest-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "herb", out = DIR, farTrees = { 24, 52, 160, 196, 440 }, treeLineGap = { 206, 270 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local HAZE = "#d2dacb"
-- local ramps
local HE = F.rp("#f2cce6 #cc8cc4 #9c62a2 #6e467a #46294e")     -- heather / fireweed pink-purple
local FX = F.rp("#f8d0ee #e08ed4 #b062aa #7a3c7e #4c2252")     -- foxglove
local RAMS = F.rp("#eef0d8 #d6dcc0 #aab49a #7c8a74 #4e5a4c")   -- ramsons' white flowers
local CHAN = F.rp("#fae69a #eec05a #c8923a #96662c #5e3e22")   -- chanterelle gold
local LV = HE

---------------------------------------------------------------- right: heather and wild-garlic rows to the tree line
-- Rows run across the view; band height grows with nearness (d^2 / C). Thin far rows are a solid hazed band
-- with horizontal texture only (no shimmer); near rows are rounded lit mounds with mossy furrows.
local C = 190
local function rowOf(y) return floor(C / (y - 109)) end
for y = 114, 160 do
  local row = rowOf(y)
  local y0 = y while y0 > 114 and rowOf(y0 - 1) == row do y0 = y0 - 1 end
  local y1 = y while y1 < 160 and rowOf(y1 + 1) == row do y1 = y1 + 1 end
  local hgt = y1 - y0 + 1
  local garlic = row % 3 == 0
  local R = garlic and L.fern or HE
  local farC = F.mix(R.base, HAZE, .4)
  for x = 262, 479 do
    if x > F.xr(y) + 6 then
      local h
      if hgt < 3 then
        local bk = hash(x // 5 + row * 7, row, 9)
        h = (bk < .3) and F.mix(R.shade, HAZE, .3) or ((bk < .68) and farC or F.mix(R.base, HAZE, .15))
        if hash(x // 2, y, 5) < .2 then h = F.mix(R.shade, HAZE, .45) end
        if hash(x // 4, y, 3) < .08 then h = F.mix(garlic and RAMS.hi or R.hi, HAZE, .45) end
      else
        -- each bush its own width and height (hashed), so the rows read as shrubby heather, not tiles
        local bw0 = math.max(5, floor(hgt * 1.7))
        local xx = x + row * 3
        local bi = xx // bw0
        local bw = bw0
        local fx = (xx % bw0) / bw0
        local hk = .3 + .35 * hash(bi, row, 16)
        local ty = y0 + floor(hgt * hk * (1 - math.sqrt(math.max(0, 1 - (2 * fx - 1) ^ 2))) + (hash(bi, row, 17) < .3 and 1 or 0) + .5)
        local ry = (y - y0) / hgt
        local v = hash(x, y, 18 + row)
        if y < ty then
          h = (ry < .2) and L.mossGround.deep or L.mossGround.shade
          if hash(x, y, 12) < .12 then h = L.needle.shade end
        elseif y == y1 then h = L.mossGround.deep
        elseif garlic then
          if y == ty then h = fx < .5 and L.fern.hi or L.fern.base
          elseif fx < .35 then h = L.fern.base
          elseif fx < .72 then h = (v < .3) and L.fern.hi or L.fern.base
          else h = L.fern.shade end
          if ry > .78 then h = L.fern.deep end
          if y >= ty and y < y1 - 1 and hash(x, y, 14) < (hgt > 5 and .16 or .1) then h = (fx < .5) and RAMS.hi or RAMS.base end
        else
          -- heather: dark woody green under a crust of pink bloom, lit upper left, freckled
          local lit = (1 - fx) * .8 - ry * 1.1 + (v - .5) * .7
          if y == ty then h = (fx < .55) and HE.hi or HE.base
          elseif lit > .45 then h = HE.hi
          elseif lit > -.05 then h = HE.base
          elseif lit > -.45 then h = HE.shade
          else h = (v < .5) and L.foliage.deep or HE.deep end
          if ry > .8 then h = (v < .5) and L.fern.deep or HE.deep end
          if v > .93 and y > ty then h = L.fern.shade end
        end
      end
      px(x, y, h)
    end
  end
end
-- a low split-log edging closing the near edge of the field, ferns poking over it
for x = 262, 479 do
  if x > F.xr(161) + 4 then
    px(x, 162, L.timber.edge) px(x, 161, L.timber.deep) px(x, 160, (x % 9 == 0) and L.timber.deep or L.timber.base)
    px(x, 159, (x % 9 == 1) and L.board.base or L.timber.hi)
  end
end

---------------------------------------------------------------- road's end: bent-birch arch with hops and dog roses
L.petal = F.rp("#ffd4dc #f49aae #cc6a86 #8e3e5e #5a2440")
local function arch()
  local pL, pR = rect(216, 76, 219, 126), rect(261, 76, 264, 126)
  local top = c:ellipse(240, 80, 24, 18):cut(c:ellipse(240, 80, 20, 14)):clip(rect(214, 58, 266, 80))
  F.shadow(216, 266, 126, 6, 3)
  local frame = union(pL, pR, top)
  rimOf(frame, L.birch)
  part(frame, L.birch, { nopop = true, noshade = true })
  -- birch bark: shaded right side, black lenticel dashes, peeling curls
  frame:each(function(x, y)
    if not frame:has(x + 1, y) or not frame:has(x + 1, y + 1) then px(x, y, L.birch.shade) end
    if not frame:has(x - 1, y) or not frame:has(x, y - 1) then px(x, y, L.birch.hi) end
    if hash(x // 2, y // 2, 81) < .16 and hash(x, y, 82) < .7 then px(x, y, L.birch.edge) end
  end)
  -- split-rail gate, ajar
  local rails = HP.mask()
  for _, xx in ipairs({ 222, 236 }) do rails:add(rect(xx, 108, xx + 1, 124)) end
  rails:add(line({ { 222, 111 }, { 238, 113 } }, 2)):add(line({ { 222, 119 }, { 238, 121 } }, 2)):add(line({ { 223, 122 }, { 236, 110 } }, 1))
  rimOf(rails, L.timber) part(rails, L.timber, { nopop = true, noshade = true })
  rails:each(function(x, y) if hash(x // 3, y, 83) < .2 then px(x, y, L.timber.hi) end end)
  -- climbing hops: leaf clumps along the arch and posts, pale hop cones, a few dog roses
  local clumps = { { 214, 120 }, { 220, 106 }, { 214, 94 }, { 220, 80 }, { 225, 68 }, { 233, 62 }, { 246, 62 }, { 255, 67 }, { 262, 80 }, { 266, 94 }, { 260, 108 }, { 266, 120 } }
  for i, p in ipairs(clumps) do
    local m = F.crown(p[1], p[2], 5, 4, (i % 2 == 0) and L.leaf or L.fern, 100 + i)
    if i % 3 ~= 0 then
      local hx, hy = p[1] + (i % 2 == 0 and -2 or 2), p[2] + 2
      fill(rect(hx, hy, hx + 1, hy + 2), L.birchLeaf.hi) px(hx + 1, hy + 2, L.birchLeaf.shade) px(hx, hy + 3, L.birchLeaf.base)
    else
      local bx, by = p[1] - 1, p[2] - 2
      fill(rect(bx, by, bx + 1, by + 1), L.petal.base) px(bx, by, L.petal.hi) px(bx + 1, by + 1, L.petal.shade) px(bx + 2, by, L.petal.base)
      px(bx + 1, by, L.gold.hi)
    end
  end
  -- trailing bines hanging off the crown of the arch
  for _, t in ipairs({ { 230, 70, 7 }, { 250, 69, 9 }, { 240, 66, 5 } }) do
    for k = 0, t[3] do px(t[1] + floor(sin(k * .9) + .5), t[2] + k, k % 3 == 0 and L.leaf.base or L.leaf.deep) end
    px(t[1], t[2] + t[3] + 1, L.birchLeaf.hi)
  end
end

---------------------------------------------------------------- back-left: timber-framed glasshouse
local function glasshouse(x0, x1, yb)
  local wh, rh = 20, 14
  local top, cx = yb - wh, (x0 + x1) // 2
  local wall = rect(x0, top, x1, yb)
  local roofm = poly{ { x0 - 2, top + 1 }, { cx, top - rh }, { x1 + 2, top + 1 } }
  local sill = rect(x0 - 1, yb - 5, x1 + 1, yb)
  F.shadow(x0 + 2, x1, yb, 8, 4)
  rimOf(union(wall, roofm, sill), L.timber)
  fill(wall, L.water.hi) fill(roofm, L.water.base)
  -- reflected sky streaks on the glass
  wall:each(function(x, y) if (x - y) % 11 == 0 then px(x, y, "#e6f2e6") end end)
  roofm:each(function(x, y) if (x + y) % 9 == 0 then px(x, y, L.water.hi) end end)
  -- seedlings and ferns inside
  for x = x0 + 3, x1 - 3, 6 do
    local m = c:ellipse(x, yb - 9, 3, 4) fill(m, L.fern.base) px(x - 1, yb - 11, L.fern.hi) px(x + 1, yb - 7, L.fern.shade) px(x, yb - 12, L.fern.hi)
  end
  part(sill, L.stone) F.courses(sill, yb - 5, 3, 6, L.stone) F.moss(sill, .25, 31)
  -- timber glazing bars
  for x = x0, x1, 7 do vline(x, top, yb - 6, L.timber.base) end
  hline(x0, x1, top, L.timber.base) hline(x0, x1, top + 10, L.timber.base)
  for k = 0, 4 do line({ { x0 - 1 + k * (cx - x0) // 4, top - k * rh // 4 }, { x0 - 1 + k * (cx - x0) // 4, top } }):each(function(x, y) if roofm:has(x, y) then px(x, y, L.timber.hi) end end) end
  for k = 0, 4 do line({ { x1 + 1 - k * (x1 - cx) // 4, top - k * rh // 4 }, { x1 + 1 - k * (x1 - cx) // 4, top } }):each(function(x, y) if roofm:has(x, y) then px(x, y, L.timber.shade) end end) end
  line({ { x0 - 2, top + 1 }, { cx, top - rh } }):each(function(x, y) px(x, y, L.timber.hi) end)
  line({ { cx, top - rh }, { x1 + 2, top + 1 } }):each(function(x, y) px(x, y, L.timber.deep) end)
  -- fallen needles and a moss line on the roof glass
  roofm:each(function(x, y) if hash(x, y, 33) < .05 then px(x, y, L.needle.shade) end end)
  for _, g in ipairs({ { x0 + 3, top + 3 }, { x0 + 10, top + 4 }, { cx - 6, top - 6 } }) do px(g[1], g[2], "#f2f4de") px(g[1] + 1, g[2] + 1, L.water.hi) end
  -- an open roof vent
  local vent = poly{ { cx - 9, top - 7 }, { cx - 3, top - 11 }, { cx - 2, top - 14 }, { cx - 8, top - 10 } }
  rimOf(vent, L.timber) fill(vent, L.water.hi) px(cx - 6, top - 11, "#f2f4de")
end

---------------------------------------------------------------- left hero: herbalist's log cabin
local function cottage()
  local top, cx, wallM, roofM = F.building{ x0 = 96, x1 = 182, yb = 182, wh = 46, rh = 32, wall = L.timber, roof = L.roof, chimney = true, shingle = true, noFrame = true }
  F.logs(wallM, L.timber, top, 4)
  for y = top + 2, 180, 4 do F.logEnd(95, y, 2) F.logEnd(183, y, 2) end
  local gableM = poly{ { 101, top }, { cx, top - 32 + 8 }, { 177, top } }:cut(rect(cx - 6, top - 16 - 2, cx + 5, top - 16 + 9))
  F.planks(gableM, L.board, 4, true, 44)
  gableM:each(function(x, y) if hash(x // 4, y, 45) < .25 then px(x, y, L.board.shade) end end)
  F.moss(roofM, .16, 41)
  -- moss creeping on the lowest logs, damp foot
  wallM:each(function(x, y) if y > 175 and hash(x // 2, y, 42) < .35 then px(x, y, hash(x, y, 43) < .5 and L.moss.shade or L.moss.base) end end)
  -- round green door with an iron ring and a fern wreath
  local d = c:rrect(130, 156, 146, 181, 8):clip(rect(130, 156, 146, 181))
  rimOf(d, L.fern) part(d, L.fern) c:edgeIn(d, L.fern.edge)
  for x = 134, 143, 3 do vline(x, 160, 180, L.fern.shade) end
  fill(c:ellipse(142, 170, 1, 1), L.gold.base) px(141, 169, L.gold.hi)
  local wr = c:ellipse(138, 163, 3, 3):cut(c:ellipse(138, 163, 1, 1))
  wr:each(function(x, y) px(x, y, (x + y) % 2 == 0 and L.foliage.base or L.foliage.shade) end) px(138, 160, L.apple.base) px(136, 166, L.apple.base)
  F.window(106, 148, 116, 156, L.timber) F.window(160, 148, 170, 156, L.timber)
  -- window boxes with ferns and pink campion
  for _, wx in ipairs({ 104, 158 }) do
    local bx = rect(wx, 160, wx + 14, 163) rimOf(bx, L.timber) part(bx, L.board, { nopop = true })
    for k = 0, 6 do local fx = wx + 1 + k * 2
      px(fx, 158, L.fern.base) px(fx + 1, 157, L.fern.hi) px(fx, 159, L.fern.shade)
      if k % 2 == 0 then px(fx, 156, (k % 4 == 0) and L.petal.base or RAMS.hi) end
    end
  end
  -- drying bundles and mushroom strings hanging from the eave pole
  hline(98, 180, top + 5, L.timber.deep)
  for k = 0, 10 do
    local x = 100 + k * 8
    if k % 4 == 3 then
      vline(x, top + 6, top + 16, L.board.deep)
      for j = 0, 2 do local yy = top + 8 + j * 3 px(x - 1, yy, CHAN.base) px(x, yy, CHAN.hi) px(x + 1, yy, CHAN.shade) px(x, yy + 1, CHAN.deep) end
    else
      local r = ({ L.fern, HE, L.wall2, L.gold })[k % 4 + 1]
      vline(x, top + 5, top + 6, L.timber.edge)
      local b = poly{ { x - 2, top + 7 }, { x + 2, top + 7 }, { x + 1, top + 14 }, { x - 1, top + 14 } }
      fill(b, r.base) px(x - 1, top + 8, r.hi) px(x - 1, top + 11, r.hi) vline(x + 1, top + 9, top + 13, r.shade) hline(x - 2, x + 2, top + 7, L.board.deep)
      px(x, top + 14, r.deep)
    end
  end
  -- hanging mortar & pestle sign on an iron bracket
  hline(184, 198, 152, L.iron.base) hline(184, 198, 153, L.iron.deep)
  vline(188, 154, 157, L.timber.edge) vline(196, 154, 157, L.timber.edge)
  local mortar = poly{ { 185, 160 }, { 199, 160 }, { 197, 167 }, { 193, 170 }, { 191, 170 }, { 187, 167 } }
  local pestle = line({ { 196, 158 }, { 201, 152 } }, 2)
  rimOf(union(mortar, pestle), L.stone) part(mortar, L.stone) part(pestle, L.board, { nopop = true })
  hline(185, 199, 160, L.stone.hi) hline(187, 197, 161, L.stone.deep)
  px(189, 159, L.fern.hi) px(190, 158, L.fern.base) px(192, 159, L.fern.hi)
  -- antlers over the door
  local ant = line({ { 131, 154 }, { 138, 152 }, { 145, 154 } }):add(line({ { 132, 154 }, { 130, 150 } })):add(line({ { 144, 154 }, { 146, 150 } }))
    :add(line({ { 134, 153 }, { 134, 150 } })):add(line({ { 142, 153 }, { 142, 150 } }))
  ant:each(function(x, y) px(x, y, L.board.hi) end)
  return top
end

---------------------------------------------------------------- log-edged raised beds in perspective (right of road)
local function bed(x0, x1, y0, y1, plant, seed)
  local soil = poly{ { x0 + 4, y0 }, { x1, y0 }, { x1 + 4, y1 }, { x0, y1 } }
  local front = rect(x0, y1, x1 + 4, y1 + 4)
  F.shadow(x0, x1 + 4, y1 + 4, 6, 2)
  rimOf(union(soil, front), L.timber)
  fill(soil, L.soil.shade)
  soil:each(function(x, y) local v = hash(x, y, seed) if v < .18 then px(x, y, L.soil.deep) elseif v > .9 then px(x, y, L.needle.shade) end end)
  F.logs(front, L.timber, y1, 5)
  front:each(function(x, y) if hash(x // 3, y, seed + 9) < .1 then px(x, y, L.moss.base) end end)
  F.logEnd(x0, y1 + 2, 2) F.logEnd(x1 + 4, y1 + 2, 2)
  local n = (x1 - x0) // 7
  for k = 0, n - 1 do plant(x0 + 6 + k * 7, y0 + (y1 - y0) // 2 + 2, k) end
end
local function ramsons(x, y, k)
  local m = c:ellipse(x, y - 3, 4, 3) fill(m, L.fern.shade)
  m:each(function(xx, yy) if xx < x and yy < y - 2 then px(xx, yy, L.fern.base) end end)
  px(x - 3, y - 4, L.fern.hi) px(x + 2, y - 2, L.fern.deep)
  vline(x, y - 8, y - 5, L.fern.shade)
  fill(rect(x - 1, y - 9, x + 1, y - 8), RAMS.base) px(x - 1, y - 9, RAMS.hi) px(x + 1, y - 8, RAMS.shade)
end
local function chanterelle(x, y, k)
  -- gold chanterelle clusters pushing up through needle litter, a fallen birch twig now and then
  if k % 3 == 1 then hline(x - 4, x + 3, y - 1, L.birch.base) px(x - 2, y - 1, L.birch.edge) px(x + 1, y - 1, L.birch.edge) end
  for j = 0, 2 do
    local mx, my = x - 3 + j * 3, y - (j == 1 and 2 or 0) - (k % 2)
    vline(mx, my - 1, my, CHAN.shade)
    hline(mx - 1, mx + 1, my - 2, CHAN.base) px(mx - 1, my - 2, CHAN.hi) px(mx + 1, my - 2, CHAN.shade)
    if j == 1 then px(mx, my - 3, CHAN.hi) px(mx - 1, my - 3, CHAN.base) px(mx + 1, my - 3, CHAN.base) end
  end
  px(x + 3, y, L.moss.base) px(x - 4, y, L.moss.hi)
end
local function strawberry(x, y, k)
  local m = c:ellipse(x, y - 2, 3, 2) fill(m, L.leaf.shade)
  px(x - 2, y - 3, L.leaf.hi) px(x - 1, y - 4, L.leaf.base) px(x + 2, y - 1, L.leaf.deep)
  px(x - 1, y - 1, L.apple.base) px(x - 1, y, L.apple.shade) px(x + 2, y - 3, L.apple.base) px(x + 2, y - 4, L.apple.hi)
  if k % 2 == 0 then px(x, y - 5, RAMS.hi) end
end
local function catnip(x, y, k)
  local m = c:ellipse(x, y - 3, 3, 3) fill(m, L.wall2.base)
  m:each(function(xx, yy) if (xx - x) + (yy - y + 3) < 0 then px(xx, yy, L.wall2.hi) elseif (xx - x) + (yy - y + 3) > 2 then px(xx, yy, L.wall2.shade) end end)
  vline(x - 1, y - 8, y - 5, L.wall2.shade) px(x - 1, y - 8, HE.hi) px(x - 1, y - 7, LV.base)
  if k % 2 == 0 then vline(x + 2, y - 7, y - 5, L.wall2.shade) px(x + 2, y - 7, HE.hi) end
end

---------------------------------------------------------------- compose: back to front
F.depth(1)
F.tree(86, 130, 40, 2)
F.birch(14, 142, 44, 51)
glasshouse(22, 76, 140)
-- two far gnomes gathering in the heather
F.gnome(420, 150, { small = true, hat = L.awnA, coat = L.wall2, arm = "out" })
F.gnome(352, 138, { small = true, hat = L.foliage, coat = L.needle, flip = true })
-- juniper bushes along the left back, behind the cabin
for x = 104, 206, 10 do F.bush(x, 134 + (x % 3), 6, 7, (x % 20 == 4) and L.foliage2 or L.wall2, x) end
F.depth(2)
F.tree(204, 128, 46, 1)
F.tree(282, 130, 44, 4)
arch()
F.tree(447, 168, 60, 2)
F.depth(3)
local ctop = cottage()
F.smoke(172, 102, 7, .5, 2)
-- herb drying A-frame rack near the road (left): bundles and a mushroom garland
local function dryRack(x0, yb)
  local legs = line({ { x0, yb }, { x0 + 6, yb - 26 }, { x0 + 12, yb } }, 2):add(line({ { x0 + 30, yb }, { x0 + 36, yb - 26 }, { x0 + 42, yb } }, 2))
  local bar = rect(x0 + 4, yb - 26, x0 + 38, yb - 25)
  F.shadow(x0, x0 + 42, yb, 6, 2)
  rimOf(union(legs, bar), L.birch) part(legs, L.birch, { nopop = true, noshade = true }) part(bar, L.birch, { nopop = true, noshade = true })
  union(legs, bar):each(function(x, y) if hash(x, y // 2, 85) < .2 then px(x, y, L.birch.edge) end end)
  for k = 0, 5 do
    local x = x0 + 9 + k * 5
    local r = ({ HE, L.fern, L.gold, L.wall2, L.needle, L.leaf })[k + 1]
    vline(x, yb - 24, yb - 22, L.timber.edge)
    local b = poly{ { x - 2, yb - 21 }, { x + 2, yb - 21 }, { x + 1, yb - 12 }, { x - 1, yb - 12 } }
    rimOf(b, r) fill(b, r.base) px(x - 1, yb - 20, r.hi) px(x - 1, yb - 17, r.hi) vline(x + 1, yb - 19, yb - 13, r.shade)
    hline(x - 2, x + 2, yb - 21, L.board.deep)
  end
  -- a sagging garland of drying mushrooms below
  for xx = x0 + 6, x0 + 36 do
    local t = (xx - x0 - 6) / 30
    local yy = floor(yb - 9 + 4 * 4 * t * (1 - t))
    px(xx, yy, L.board.deep)
    if (xx - x0) % 4 == 0 then px(xx, yy + 1, CHAN.shade) px(xx - 1, yy, CHAN.base) px(xx + 1, yy, CHAN.base) px(xx, yy - 1, CHAN.hi) end
  end
end
dryRack(160, 214)
-- the beds on the right, near ones larger
bed(276, 360, 166, 174, ramsons, 3)
bed(282, 380, 182, 192, chanterelle, 4)
bed(290, 400, 202, 214, strawberry, 5)
bed(300, 376, 228, 242, catnip, 6)
-- quirk: a ginger tabby curled up asleep in the catnip at the near bed's end, a butterfly resting on its ear
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
  -- a brimstone butterfly on its ear
  F.sprite({ "a.a", ".k.", "a.a" }, 339, 223, { a = L.gold.hi, k = L.timber.edge }, { rim = false })
  px(338, 223, L.birchLeaf.hi) px(342, 223, L.birchLeaf.hi)
  local bub = c:ellipse(328, 222, 2, 2) fill(bub, L.water.hi) px(327, 221, "#f0f4e0")
  px(332, 225, L.water.hi)
end
-- potting table with pots, jars, a basket of chanterelles
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
    local rr = ({ L.fern, L.wall2, HE })[k + 1]
    local pl = c:ellipse(x + 4, 161, 3, 3) fill(pl, rr.base) px(x + 3, 159, rr.hi) px(x + 2, 160, rr.hi) px(x + 6, 162, rr.shade)
  end
  for k = 0, 1 do
    local x = 442 + k * 6
    local jar = rect(x - 2, 164, x + 2, 171) fill(jar, L.water.hi) fill(rect(x - 1, 167, x + 1, 171), ({ CHAN, HE })[k + 1].base) hline(x - 2, x + 2, 164, L.timber.base) px(x - 2, 166, "#f0f4e0")
  end
  -- chanterelle basket on the shelf, terracotta pots stacked
  local bk = poly{ { 430, 181 }, { 446, 181 }, { 444, 187 }, { 432, 187 } }
  rimOf(bk, L.needle) part(bk, L.needle, { nopop = true }) bk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) end end)
  for k = 0, 4 do local mx = 432 + k * 3 px(mx, 180, CHAN.base) px(mx + 1, 180, CHAN.hi) px(mx, 179, CHAN.hi) end
  for k = 0, 1 do local x = 408 + k * 10 local pot = rect(x, 184, x + 6, 187) fill(pot, L.roof2.shade) hline(x, x + 6, 184, L.roof2.base) end
end
pottingTable()
-- log-gum bee hives on a bench at the right edge, bark caps
local function hives()
  local bench = rect(410, 214, 462, 216):add(rect(412, 217, 414, 224)):add(rect(458, 217, 460, 224))
  F.shadow(410, 462, 224, 6, 2)
  rimOf(bench, L.timber) part(bench, L.timber, { nopop = true, noshade = true })
  for k = 0, 2 do
    local x = 420 + k * 16
    local hb = c:rrect(x - 5, 198, x + 5, 213, 2)
    local cap = c:ellipse(x, 199, 8, 5):clip(rect(x - 9, 190, x + 9, 199))
    rimOf(union(hb, cap), L.timber)
    part(hb, L.timber)
    -- vertical bark ridges, lit left
    hb:each(function(xx, yy)
      if (xx - x + 5) % 3 == 0 then px(xx, yy, L.timber.deep) elseif xx < x - 2 and hash(xx, yy // 3, k) < .5 then px(xx, yy, L.timber.hi) end
      if hash(xx // 2, yy // 2, 40 + k) < .08 then px(xx, yy, L.moss.base) end
    end)
    -- rounded straw skep cap with coiled rings
    part(cap, L.board, { nopop = true })
    cap:each(function(xx, yy) if (yy - 190) % 3 == 2 then px(xx, yy, L.board.shade) elseif xx < x - 2 and yy % 3 == 0 then px(xx, yy, L.board.hi) end end)
    px(x, 189, L.timber.edge)
    fill(c:ellipse(x, 208, 1, 1), L.timber.edge)
    hline(x - 5, x + 5, 203, L.iron.shade)
  end
  for i = 0, 7 do local bx, by = 414 + floor(hash(i, 1, 3) * 48), 182 + floor(hash(i, 2, 3) * 12) px(bx, by, L.gold.base) px(bx + 1, by, L.timber.edge) px(bx, by - 1, L.water.hi) end
end
hives()
-- mossy stone herb spiral, bottom-left: thyme, wild strawberry, heather
local function spiral(cx, cy)
  F.shadow(cx - 36, cx + 40, cy + 14, 8, 3)
  local tiers = { { 40, 13, 0, L.fern }, { 28, 9, 9, L.leaf }, { 16, 6, 17, HE } }
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
    F.moss(face, .22, 50 + i)
    fill(top, L.soil.shade)
    top:each(function(x, y)
      local v = hash(x, y, i * 7)
      if v < .45 then px(x, y, rr.base) elseif v < .55 then px(x, y, rr.hi) elseif v < .7 then px(x, y, rr.shade) end
      if i == 2 and hash(x, y, 77) < .05 then px(x, y, L.apple.base) end
    end)
    c:edgeIn(top, L.stone.base)
  end
  F.fern(cx, cy - 22, 6)
  for _, p in ipairs({ { cx - 28, cy - 6 }, { cx + 18, cy - 4 }, { cx - 8, cy - 16 } }) do px(p[1], p[2], RAMS.hi) px(p[1] + 1, p[2], HE.hi) end
end
spiral(74, 248)
-- foxgloves along the left: swaying spires, bells hanging on one side, big low, small to the green tip
for k, x in ipairs({ 26, 36, 46, 58, 70, 82 }) do
  local yb, h = 206 + (k % 2) * 3, 32 + floor(hash(k, 1, 5) * 20)
  local r = (k % 3 == 0) and RAMS or ((k % 3 == 1) and FX or L.petal)
  local function sx(y) return x + floor(sin((yb - y) / h * 2.2 + k) * 2 * (yb - y) / h + .5) end
  for y = yb - h, yb do px(sx(y), y, L.fern.shade) px(sx(y) + 1, y, L.fern.deep) end
  -- basal rosette: long lance leaves radiating from the foot, lit on their upper edge
  local bx0 = sx(yb)
  for j, lf in ipairs({ { -9, -2 }, { -7, -6 }, { -3, -8 }, { 4, -8 }, { 8, -5 }, { 10, -1 } }) do
    local ex, ey = bx0 + lf[1], yb + lf[2] + floor(hash(j, k, 8) * 2)
    local m = line({ { bx0, yb }, { (bx0 + ex) // 2 + (lf[1] < 0 and -1 or 1), (yb + ey) // 2 - 1 }, { ex, ey } }, 2)
    c:rim(m, L.fern.edge) part(m, (j + k) % 3 == 0 and L.leaf or L.fern, { nopop = true })
    line({ { bx0, yb - 1 }, { (bx0 + ex) // 2, (yb + ey) // 2 - 2 } }):each(function(xx, yy) if m:has(xx, yy) then px(xx, yy, L.fern.hi) end end)
  end
  local i = 0
  for y = yb - 15, yb - h + 2, -2 do
    i = i + 1
    local t = (yb - 17 - y) / math.max(1, h - 19)
    local cx = sx(y) + 2
    if t < .7 then
      -- a hanging bell 2 px tall: lit crown, flared dark mouth, freckled throat; 1 px gap to the next bell
      local w = t < .45 and 2 or 1
      local side = (i % 2 == 0) and 1 or -1
      local bx = (side > 0) and cx or (sx(y) - 1 - w)
      hline(bx, bx + w, y, r.base) px(side > 0 and bx or bx + w, y, r.hi)
      hline(bx, bx + w, y + 1, r.shade) px(side > 0 and bx + w or bx, y + 1, r.edge)
      if w == 2 then px(bx + 1, y + 1, (k % 3 == 0) and HE.shade or r.deep) px(side > 0 and bx + w + 1 or bx - 1, y + 1, r.deep) end
    elseif t < .9 then
      px(cx - 1, y, r.base) px(cx - 1, y + 1, r.shade) px(sx(y) - 1, y, L.fern.base)
    else
      px(cx - 1, y, L.fern.base) px(sx(y) - 1, y + 1, L.fern.hi)
    end
  end
  px(sx(yb - h), yb - h - 1, L.fern.hi)
end
-- gnome harvesting with a basket of herbs and mushrooms
local _, gx, gy = F.gnome(268, 218, { hat = HE, coat = L.fern, arm = "out" })
local bsk = poly{ { gx - 1, gy - 1 }, { gx + 11, gy - 1 }, { gx + 9, gy + 6 }, { gx + 1, gy + 6 } } rimOf(bsk, L.needle) part(bsk, L.needle)
bsk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) end end)
for k = 0, 4 do
  local col = ({ HE, L.fern, CHAN, RAMS, L.fern })[k + 1]
  px(gx + 1 + k * 2, gy - 2, col.base) px(gx + 1 + k * 2, gy - 3, col.hi)
end
-- the waterer, tipping a can over the herb spiral
local _, wx, wy = F.gnome(164, 254, { hat = L.awnA, coat = L.wall2, arm = "out", flip = true })
local wcan = rect(wx - 8, wy - 3, wx - 1, wy + 3):add(line({ { wx - 8, wy }, { wx - 14, wy - 4 } }, 2))
rimOf(wcan, L.iron) part(wcan, L.iron) fill(rect(wx - 16, wy - 6, wx - 13, wy - 4), L.iron.shade)
hline(wx - 8, wx - 1, wy - 1, L.iron.hi)
for k = 0, 4 do px(wx - 17 - k, wy - 3 + k * 2, L.water.hi) px(wx - 15 - k, wy - 2 + k * 2, L.water.base) end
-- a hedgehog trundling past the spiral
F.sprite({
  "...sSsSs....",
  "..SsSsSsSs..",
  ".sSsSsSsSsbb",
  "SsSsSsSsbbbbk",
  ".bbbbbbbbbb.",
  "..o..o..o...",
}, 172, 257, { s = L.needle.shade, S = L.needle.deep, b = L.needle.hi, k = L.timber.edge, o = L.timber.deep })
px(181, 259, L.timber.edge)
-- a fairy ring of little brown mushrooms by the cabin
for k = 0, 9 do
  local a = k / 10 * 2 * pi
  F.mushroom(floor(132 + cos(a) * 14 + .5), floor(208 + sin(a) * 4 + .5), (k % 3 == 0) and L.apple or L.needle, false)
end
F.mushroom(206, 222, L.apple, true) F.mushroom(211, 224, L.apple)
-- a mossy birch stump with bracket fungi and a trug of cut ferns, back left by the glasshouse
do
  local body = rect(36, 152, 45, 162)
  local tp = c:ellipse(40, 152, 5, 2)
  rimOf(union(body, tp), L.birch) part(body, L.birch, { nopop = true })
  body:each(function(x, y) if x > 42 then px(x, y, L.birch.shade) end if hash(x // 2, y // 2, 90) < .2 then px(x, y, L.birch.edge) end end)
  fill(tp, L.board.base) px(40, 152, L.board.shade) px(37, 151, L.board.hi)
  F.moss(body, .2, 91)
  for _, b in ipairs({ { 45, 156 }, { 46, 159 } }) do hline(b[1], b[1] + 3, b[2], CHAN.base) hline(b[1], b[1] + 2, b[2] + 1, CHAN.deep) px(b[1], b[2], CHAN.hi) end
  local tr = poly{ { 52, 156 }, { 64, 156 }, { 62, 162 }, { 54, 162 } }
  rimOf(tr, L.needle) part(tr, L.needle) tr:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) end end)
  line({ { 53, 156 }, { 58, 151 }, { 63, 156 } }):each(function(x, y) if y < 156 then px(x, y, L.needle.deep) end end)
  for k = 0, 4 do px(54 + k * 2, 155, L.fern.hi) px(55 + k * 2, 154, L.fern.base) end
  for _, f in ipairs({ { 28, 162, 6 }, { 70, 160, 5 }, { 82, 166, 4 }, { 12, 170, 6 } }) do F.fern(f[1], f[2], f[3]) end
  F.mushroom(48, 164, L.apple, true) F.mushroom(30, 166, L.apple)
end
-- ferns tucked along the cabin foot and the left edge
for _, f in ipairs({ { 92, 186, 6 }, { 186, 186, 5 }, { 20, 216, 7 }, { 98, 214, 5 }, { 214, 238, 6 } }) do F.fern(f[1], f[2], f[3]) end
F.depth(0)
-- bees over the hives and the heather, brimstone and white butterflies
for i = 0, 14 do local bx, by = 300 + floor(hash(i, 1, 33) * 170), 140 + floor(hash(i, 2, 33) * 80) px(bx, by, L.gold.base) px(bx + 1, by, L.timber.edge) px(bx, by - 1, L.water.hi) end
F.sprite({ "a.a", ".k.", "a.a" }, 330, 128, { a = L.awnB.hi, k = L.timber.edge }, { rim = false })
F.sprite({ "a.a", ".k.", "a.a" }, 120, 200, { a = L.gold.hi, k = L.timber.edge }, { rim = false })
F.sprite({ "a.a", ".k.", "a.a" }, 240, 196, { a = L.awnB.hi, k = L.timber.edge }, { rim = false })
F.birds({ { 330, 44, 2 }, { 344, 40, 1 }, { 120, 60, 2 } })
-- half-barrel tubs of fern and angelica, bottom-right
F.depth(3)
for k, x in ipairs({ 300, 316, 368 }) do
  local pot = poly{ { x - 7, 252 }, { x + 7, 252 }, { x + 6, 264 }, { x - 6, 264 } }
  rimOf(pot, L.timber) part(pot, L.timber)
  pot:each(function(xx, yy) if (xx - x + 7) % 3 == 0 then px(xx, yy, L.timber.deep) end end)
  hline(x - 7, x + 7, 254, L.iron.shade) hline(x - 6, x + 6, 261, L.iron.shade) hline(x - 7, x + 7, 252, L.timber.hi)
  if k == 2 then
    -- angelica: tall stem, green-white umbels
    vline(x, 230, 252, L.fern.shade) vline(x + 4, 236, 252, L.fern.shade)
    for _, u in ipairs({ { x, 229, 3 }, { x + 4, 235, 2 } }) do
      hline(u[1] - u[3], u[1] + u[3], u[2], L.birchLeaf.base) hline(u[1] - u[3] + 1, u[1] + u[3] - 1, u[2] - 1, L.birchLeaf.hi)
      px(u[1] - u[3], u[2] + 1, L.fern.shade) px(u[1] + u[3], u[2] + 1, L.fern.shade)
    end
    F.fern(x - 3, 251, 5)
  else
    F.fern(x - 2, 251, 8 + k) F.fern(x + 3, 251, 6)
  end
end
-- fix-up: small herbs on the plain ground between the glasshouse and the foxgloves
F.depth(3)
F.fern(48, 148, 4) F.fern(90, 152, 4, L.needle) F.fern(36, 160, 3) F.fern(104, 160, 4)
F.mushroom(58, 156, L.needle, true) F.mushroom(62, 158, L.needle) F.mushroom(98, 150, L.apple)
for _, p in ipairs({ { 70, 150 }, { 82, 158 }, { 44, 154 }, { 110, 152 }, { 54, 166 } }) do
  fill(rect(p[1], p[2], p[1] + 3, p[2] + 1), L.stone.base) hline(p[1], p[1] + 3, p[2] - 1, L.stone.edge) px(p[1], p[2], L.stone.hi) hline(p[1] + 1, p[1] + 3, p[2] + 2, L.stone.shade)
end
F.finish()
