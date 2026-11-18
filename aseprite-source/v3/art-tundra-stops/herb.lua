-- herb.lua : "Herb garden" stop look, TUNDRA (tundra_frost), 480x270 gate view.
-- Same composition as the Maplewold herb (art-2701-batch3/stops/opus3/herb.lua) and the forest herb, re-cast as a
-- sheltered arctic lichen-and-berry garden:
-- right: rows of cloudberry, lingonberry and crowberry running back to the fells between low dry-stone windbreaks,
-- two far gnomes picking. Road's end: a whale-jawbone arch hung with old-man's-beard lichen, rowan berries and
-- herb bundles, a driftwood gate ajar. Back left: a domed glass cloche house, lamp-lit, green inside, steaming vent.
-- Left hero: the herbalist's turf house (herringbone turf walls, falu-red board gable, sod roof under snow) with
-- drying bundles, a blue round door and a mortar-and-pestle sign. Right of road: stone-walled cold frames with glass
-- lights (lingonberry, cloudberry, roseroot, reindeer lichen), a potting table with bell jars, baskets of picked
-- berries on a bench, a snowy stone herb spiral (crowberry, purple saxifrage, reindeer lichen), frosted angelica and
-- fireweed seed spikes along the left, glass bell cloches over seedlings, redpolls, a raven.
-- Quirk: an arctic fox in a red gnome hat asleep, curled on the warm reindeer-lichen cold frame, a snow bunting on its back.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-tundra-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "herb", out = DIR, farTrees = { 24, 52, 160, 196, 440 }, treeLineGap = { 206, 270 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local S = L.snow
local HAZE = "#dcdeec"
-- local ramps
local CB = F.rp("#ffd890 #f6a84c #d67c38 #a6562c #6c3626")   -- cloudberry amber
local CBL = F.rp("#e8b884 #c88a5a #9e6444 #74463a #4a2c2a")  -- cloudberry leaves turning bronze
local LG = F.rp("#a6c094 #6e9270 #4e7058 #36524a #22363a")   -- lingonberry evergreen
local CR = F.rp("#a492b4 #6a5478 #4a3a5a #32283e #201a2a")   -- crowberry black-purple
local RL = F.rp("#e6ead2 #ccd4b4 #a8b496 #808e78 #56624e")   -- reindeer lichen
local SAX = F.rp("#f2c4e2 #d68cc4 #aa62a2 #7a4480 #4c2a56")  -- purple saxifrage
local RR = F.rp("#c4dcd0 #90b8ac #6a948c #4c7068 #2e4a48")   -- roseroot blue-green
local BONE = F.rp("#f2e8d2 #dccdb0 #b8a68a #8c7c6a #5a4e48") -- whale bone
local GREEN = F.rp("#c6e0a0 #8cbc6c #5e9452 #3e6c44 #264430") -- living green under glass

-- glass over what is already drawn: mixed toward a pale ice tint (opaque, no alpha)
local function glass(m, k, col)
  m:each(function(x, y) local v = c:get(x, y) if v then px(x, y, F.mix(v, col or L.ice.hi, k or .45)) end end)
end

---------------------------------------------------------------- right: berry rows and dry-stone windbreaks to the fells
local C = 190
local function rowOf(y) return floor(C / (y - 109)) end
for y = 114, 160 do
  local row = rowOf(y)
  local y0 = y while y0 > 114 and rowOf(y0 - 1) == row do y0 = y0 - 1 end
  local y1 = y while y1 < 160 and rowOf(y1 + 1) == row do y1 = y1 + 1 end
  local hgt = y1 - y0 + 1
  local kind = row % 3
  local R = kind == 0 and CBL or (kind == 1 and LG or CR)
  local berry = kind == 0 and CB or (kind == 1 and L.apple or CR)
  local wall = row % 4 == 0
  for x = 262, 479 do
    if x > F.xr(y) + 6 then
      local h
      if hgt < 3 then
        h = (y == y1) and F.mix(R.shade, HAZE, .5) or F.mix(S.base, HAZE, .28)
        if hash(x // 3, y, 3) < .1 then h = F.mix(R.base, HAZE, .55) end
        if hash(x // 5, y, 4) < .04 then h = F.mix(berry.base, HAZE, .5) end
      elseif wall then
        -- dry-stone windbreak: snow on its top course, stones lit left, lee drift under
        local ry = y - y0
        local sx = (x + row * 5) % 7
        if ry == 0 then h = hash(x, y, 4) < .7 and S.hi or S.base
        elseif ry == 1 and hash(x // 2, y, 5) < .5 then h = S.base
        elseif y == y1 then h = (sx > 2) and S.shade or S.deep
        elseif sx == 0 or (ry % 2 == 0 and hash(x // 7, ry, row) < .5) then h = L.stone.deep
        else local v = hash((x + row * 5) // 7, ry // 2, row) h = v < .3 and L.stone.hi or (v < .75 and L.stone.base or L.stone.shade)
          if hash(x, y, 6) < .06 then h = L.lichen.base end end
      else
        local bw0 = math.max(5, floor(hgt * 1.7))
        local xx = x + row * 3
        local bi = xx // bw0
        local fx = (xx % bw0) / bw0
        local hk = .3 + .3 * hash(bi, row, 16)
        local ty = y0 + floor(hgt * hk * (1 - math.sqrt(math.max(0, 1 - (2 * fx - 1) ^ 2))) + .5)
        local ry = (y - y0) / hgt
        local v = hash(x, y, 18 + row)
        if y < ty then
          h = (ry < .25) and S.shade or S.base -- snow in the furrow
          if hash(x, y, 12) < .05 then h = S.hi end
        elseif y == y1 then h = S.deep
        elseif y == ty then h = (fx < .5) and S.hi or S.base -- snow dusting on the mound tops
        else
          local lit = (1 - fx) * .8 - ry * 1.1 + (v - .5) * .6
          if lit > .45 then h = R.hi elseif lit > -.05 then h = R.base elseif lit > -.45 then h = R.shade else h = R.deep end
          if hgt > 4 and v < .12 and ry < .75 then h = (fx < .5) and berry.hi or berry.base end
          if ry > .82 then h = R.deep end
        end
      end
      px(x, y, h)
    end
  end
end
-- a low dry-stone wall closing the near edge of the field, snow along its top
for x = 262, 479 do
  if x > F.xr(161) + 4 then
    local sx = (x + 3) % 6
    px(x, 162, L.stone.edge) px(x, 161, sx == 0 and L.stone.deep or L.stone.shade)
    px(x, 160, sx == 0 and L.stone.deep or (hash(x // 6, 1, 7) < .4 and L.stone.hi or L.stone.base))
    px(x, 159, hash(x, 2, 7) < .6 and S.hi or S.base)
    if hash(x // 3, 3, 7) < .3 then px(x, 158, S.base) end
  end
end

---------------------------------------------------------------- road's end: whale-jawbone arch with lichen and rowan
local function arch()
  local pL, pR = rect(215, 78, 220, 126), rect(260, 78, 265, 126)
  local top = c:ellipse(240, 80, 25, 19):cut(c:ellipse(240, 80, 20, 15)):clip(rect(214, 58, 266, 80))
  F.shadow(216, 266, 126, 6, 3)
  local frame = union(pL, pR, top)
  rimOf(frame, BONE)
  part(frame, BONE, { nopop = true, noshade = true })
  -- bone: lit left edges, shaded right edges, a porous pitted face, growth lines
  frame:each(function(x, y)
    if not frame:has(x + 1, y) or not frame:has(x + 1, y + 1) then px(x, y, BONE.shade) end
    if not frame:has(x - 1, y) or not frame:has(x, y - 1) then px(x, y, BONE.hi) end
    if hash(x, y, 81) < .1 then px(x, y, BONE.shade) end
    if y > 80 and y % 9 == 0 and hash(x, y, 82) < .7 then px(x, y, BONE.deep) end
  end)
  F.snowCap(top, 2, 83, { cx = 240, lip = true })
  -- driftwood picket gate, ajar
  local rails = HP.mask()
  for xx = 222, 236, 4 do rails:add(poly{ { xx, 110 }, { xx + 1, 108 }, { xx + 2, 110 }, { xx + 2, 124 }, { xx, 124 } }) end
  rails:add(rect(222, 113, 238, 114)):add(rect(222, 120, 238, 121))
  rimOf(rails, L.timber) part(rails, L.timber, { nopop = true, noshade = true })
  rails:each(function(x, y) if hash(x, y // 3, 84) < .25 then px(x, y, L.timber.hi) elseif hash(x, y, 85) < .15 then px(x, y, L.timber.shade) end end)
  for xx = 222, 236, 4 do px(xx, 109, S.hi) px(xx + 1, 108, S.hi) end
  hline(222, 238, 112, S.base)
  -- hanging old-man's-beard lichen, rowan clusters and herb bundles along the arch
  local hangs = { { 217, 96 }, { 219, 84 }, { 224, 70 }, { 231, 63 }, { 240, 61 }, { 249, 63 }, { 256, 70 }, { 262, 84 }, { 264, 98 } }
  for i, p in ipairs(hangs) do
    local hx, hy = p[1], p[2] + 3
    if i % 3 == 1 then
      for k = -1, 1 do
        local len = 5 + floor(hash(i, k, 86) * 6)
        for j = 0, len do px(hx + k + floor(sin(j * .8 + k) * .6 + .5), hy + j, j % 2 == 0 and RL.base or RL.shade) end
        px(hx + k, hy + len + 1, RL.deep)
      end
    elseif i % 3 == 2 then
      vline(hx, hy - 1, hy + 1, L.timber.edge)
      for _, b in ipairs({ { 0, 2 }, { -1, 3 }, { 1, 3 }, { 0, 4 }, { -1, 5 }, { 1, 5 }, { 0, 6 } }) do px(hx + b[1], hy + b[2], L.apple.base) end
      px(hx - 1, hy + 3, L.apple.hi) px(hx + 1, hy + 5, L.apple.shade) px(hx, hy + 6, L.apple.deep)
      px(hx + 2, hy + 2, LG.base) px(hx - 2, hy + 2, LG.shade)
    else
      vline(hx, hy - 1, hy + 1, L.timber.edge)
      local b = poly{ { hx - 2, hy + 2 }, { hx + 2, hy + 2 }, { hx + 1, hy + 8 }, { hx - 1, hy + 8 } }
      c:rim(b, L.fern.edge) fill(b, L.fern.base) vline(hx + 1, hy + 3, hy + 7, L.fern.shade) px(hx - 1, hy + 3, L.fern.hi)
      hline(hx - 2, hx + 2, hy + 2, L.wall2.base)
    end
  end
  F.icicles(221, 259, 81, 3, 87, .25)
  -- a raven perched at the crown of the arch
  F.sprite({
    "..kk....",
    ".kKKk...",
    "bKKKKkk.",
    "..kKKKKk",
    "...kKKKk",
    "....o.o.",
  }, 236, 54, { k = "#3a3646", K = "#4e4a5c", b = L.gold.shade, o = "#3a3646" })
  px(238, 56, "#7c7890")
end

---------------------------------------------------------------- back-left: domed glass cloche house
local function clocheHouse(x0, x1, yb)
  local wh, rh = 18, 16
  local top, cx = yb - wh, (x0 + x1) // 2
  local rx = (x1 - x0) // 2 + 1
  local wall = rect(x0, top, x1, yb)
  local dome = c:ellipse(cx, top + 1, rx, rh):clip(rect(x0 - 2, top - rh - 1, x1 + 2, top + 1))
  local sill = rect(x0 - 1, yb - 4, x1 + 1, yb)
  local fin = rect(cx - 1, top - rh - 5, cx + 1, top - rh)
  F.shadow(x0 + 2, x1, yb, 8, 4)
  rimOf(union(wall, dome, sill, fin), L.timber)
  -- the warm green inside: lamp glow behind leafy plants
  fill(wall, F.mix(L.glow.hi, GREEN.hi, .4)) fill(dome, F.mix(L.water.hi, L.glow.hi, .3))
  fill(c:ellipse(cx + 6, top + 6, 5, 4), L.glow.hi)
  for x = x0 + 3, x1 - 3, 5 do
    local hh = 5 + floor(hash(x, 1, 21) * 6)
    local m = c:ellipse(x, yb - 5 - hh // 2, 3, hh // 2 + 1)
    fill(m, GREEN.base) m:each(function(xx, yy) if xx > x or yy > yb - 5 - hh // 3 then px(xx, yy, GREEN.shade) end end)
    px(x - 1, yb - 5 - hh + 1, GREEN.hi) px(x - 2, yb - 6 - hh // 2, GREEN.hi)
    if hash(x, 2, 21) < .5 then px(x + 1, yb - 6 - hh // 2, CB.base) end
  end
  -- a little hanging lamp
  vline(cx + 6, top - 4, top + 2, L.iron.deep) fill(rect(cx + 5, top + 3, cx + 7, top + 5), L.glow.base) px(cx + 5, top + 3, L.glow.hi)
  -- glass over all of it, frost creeping in from the corners
  glass(wall, .38) glass(dome, .3)
  wall:each(function(x, y) if (x - y) % 11 == 0 then px(x, y, F.mix(c:get(x, y), "#f4f6fa", .5)) end end)
  wall:each(function(x, y)
    local d = math.min(x - x0, x1 - x, yb - 4 - y)
    if d >= 0 and d < 4 and hash(x, y, 22) < .55 - d * .14 then px(x, y, d < 2 and L.ice.hi or L.ice.base) end
  end)
  part(sill, L.stone, { nopop = true }) F.rubble(sill, L.stone, yb - 4, 3, 23)
  -- driftwood glazing bars: verticals, a transom, ribs over the dome
  for x = x0, x1, 7 do vline(x, top, yb - 5, L.timber.base) end
  hline(x0, x1, top, L.timber.hi) hline(x0, x1, top + 1, L.timber.shade) hline(x0, x1, top + 9, L.timber.base)
  for k = -3, 3 do
    local a = k * pi / 8
    line({ { cx, top - rh + 1 }, { floor(cx + sin(a) * rx + .5), top } }):each(function(x, y) if dome:has(x, y) then px(x, y, k < 0 and L.timber.hi or L.timber.shade) end end)
  end
  hline(cx - rx + 4, cx + rx - 4, top - rh // 2, L.timber.base)
  part(fin, L.iron, { nopop = true }) px(cx, top - rh - 6, L.gold.base)
  -- snow lying on the shoulders of the dome, thinner on the steep sides
  dome:each(function(x, y)
    if not dome:has(x, y - 1) and abs(x - cx) < rx - 4 then
      px(x, y, x < cx and S.hi or S.base)
      if abs(x - cx) < rx - 9 and dome:has(x, y + 1) then px(x, y + 1, x < cx and S.base or S.shade) end
    end
  end)
  F.icicles(x0, x1, yb - 4 + 5, 2, 24, .2)
  for _, g in ipairs({ { x0 + 3, top + 3 }, { x0 + 10, top + 4 }, { cx - 6, top - 7 } }) do px(g[1], g[2], "#f4f6fa") px(g[1] + 1, g[2] + 1, L.water.hi) end
  return top - rh
end

---------------------------------------------------------------- left hero: the herbalist's turf house
local function turfWall(m, y0)
  -- herringbone turf blocks (klömbruhnaus): rows of slanted sods, flat strips between, moss and frost
  m:each(function(x, y)
    local row = (y - y0) // 6
    local ry = (y - y0) % 6
    local h
    if ry == 5 then h = hash(x // 3, row, 31) < .5 and L.soil.shade or L.roof.deep
    else
      local dir = row % 2 == 0 and 1 or -1
      local k = (x + dir * ry + row * 2) % 4
      if k == 0 then h = L.roof.deep
      elseif k == 1 then h = L.roof.shade
      elseif k == 2 then h = hash(x, y, 32) < .3 and L.greyMoss.base or L.roof.base
      else h = L.roof.base end
      if ry == 0 and k == 3 then h = L.roof.hi end
      if hash(x // 3, y // 3, 33) < .07 then h = L.greyMoss.shade end
    end
    if ry == 0 and hash(x // 2, row, 34) < .3 then h = S.base end -- frost on the strips
    px(x, y, h)
  end)
end
local function cottage()
  local top, cx, wallM, roofM = F.building{ x0 = 96, x1 = 182, yb = 182, wh = 46, rh = 32, wall = L.roof, roof = L.roof, chimney = true, noFrame = true, snow = 4, icicles = 5 }
  local wall = wallM:copy():clip(rect(96, top + 4, 182, 182))
  turfWall(wall, top + 4)
  -- falu-red board gable with white trim
  local gableM = poly{ { 101, top }, { cx, top - 32 + 8 }, { 177, top } }:cut(rect(cx - 6, top - 16 - 2, cx + 5, top - 16 + 9))
  part(gableM, L.wall2, { nopop = true })
  F.planks(gableM, L.wall2, 4, true, 35)
  gableM:each(function(x, y) if not gableM:has(x, y + 1) then px(x, y, L.plaster.base) end end)
  hline(96, 182, top + 3, L.plaster.shade)
  -- a timber front frame around the door and windows (the turf house's wooden face)
  local face = union(rect(124, 150, 125, 181), rect(151, 150, 152, 181), rect(124, 150, 152, 151))
  part(face, L.timber, { nopop = true, noshade = true }) hline(124, 152, 150, L.timber.hi)
  fill(rect(126, 152, 150, 181), L.board.shade)
  F.planks(rect(126, 152, 150, 181), L.board, 4, true, 36)
  -- round blue door with an iron ring and a lichen wreath
  local d = c:rrect(130, 156, 146, 181, 8):clip(rect(130, 156, 146, 181))
  rimOf(d, L.accent) part(d, L.accent) c:edgeIn(d, L.accent.edge)
  for x = 134, 143, 3 do vline(x, 160, 180, L.accent.shade) end
  fill(c:ellipse(143, 170, 1, 1), L.gold.base) px(142, 169, L.gold.hi)
  local wr = c:ellipse(138, 164, 3, 3):cut(c:ellipse(138, 164, 1, 1))
  wr:each(function(x, y) px(x, y, (x + y) % 2 == 0 and RL.base or RL.shade) end) px(138, 161, L.apple.base) px(136, 167, L.apple.base) px(140, 167, CB.base)
  F.window(106, 148, 116, 156, L.timber) F.window(160, 148, 170, 156, L.timber)
  -- window boxes of lingonberry and a rime of snow
  for _, wx in ipairs({ 104, 158 }) do
    local bx = rect(wx, 160, wx + 14, 163) rimOf(bx, L.timber) part(bx, L.timber, { nopop = true })
    for k = 0, 6 do local fx = wx + 1 + k * 2
      px(fx, 158, LG.base) px(fx + 1, 157, LG.hi) px(fx, 159, LG.shade)
      if k % 2 == 0 then px(fx, 157, L.apple.base) end
    end
    hline(wx, wx + 14, 159, S.base) for k = 0, 14, 3 do px(wx + k, 158, S.hi) end
  end
  -- drying bundles on the eave pole: lichen, sedge, angelica, crowberry sprigs, a string of dried cloudberries
  hline(98, 180, top + 5, L.timber.deep)
  for k = 0, 10 do
    local x = 100 + k * 8
    if k % 4 == 3 then
      vline(x, top + 6, top + 16, L.board.deep)
      for j = 0, 3 do local yy = top + 7 + j * 3 px(x - 1, yy, CB.base) px(x, yy, CB.hi) px(x + 1, yy, CB.shade) px(x, yy + 1, CB.deep) end
    else
      local r = ({ RL, L.fern, LG, CR })[k % 4 + 1]
      vline(x, top + 5, top + 6, L.timber.edge)
      local b = poly{ { x - 2, top + 7 }, { x + 2, top + 7 }, { x + 1, top + 14 }, { x - 1, top + 14 } }
      c:rim(b, r.edge) fill(b, r.base) px(x - 1, top + 8, r.hi) px(x - 1, top + 11, r.hi) vline(x + 1, top + 9, top + 13, r.shade)
      hline(x - 2, x + 2, top + 7, L.wall2.shade) px(x, top + 14, r.deep)
    end
  end
  -- hanging mortar & pestle sign on an iron bracket, snow on the bracket and the bowl's rim
  hline(184, 198, 152, L.iron.base) hline(184, 198, 153, L.iron.deep) hline(184, 197, 151, S.hi)
  vline(188, 154, 157, L.timber.edge) vline(196, 154, 157, L.timber.edge)
  local mortar = poly{ { 185, 160 }, { 199, 160 }, { 197, 167 }, { 193, 170 }, { 191, 170 }, { 187, 167 } }
  local pestle = line({ { 196, 158 }, { 201, 152 } }, 2)
  rimOf(union(mortar, pestle), L.stone) part(mortar, L.stone) part(pestle, L.timber, { nopop = true })
  hline(185, 199, 160, S.hi) hline(187, 197, 161, L.stone.deep)
  F.icicles(187, 197, 171, 2, 37, .3)
  -- reindeer antlers over the door
  local ant = line({ { 129, 149 }, { 138, 147 }, { 147, 149 } }):add(line({ { 130, 149 }, { 127, 144 } })):add(line({ { 146, 149 }, { 149, 144 } }))
    :add(line({ { 133, 148 }, { 132, 144 } })):add(line({ { 143, 148 }, { 144, 144 } }))
  ant:each(function(x, y) px(x, y, L.board.hi) end) px(127, 143, S.hi) px(149, 143, S.hi)
  -- a snow bank against the turf foot, firewood of driftwood stacked by the corner
  for x = 92, 186 do local hh = 2 + floor(F.vnoise(x / 9, 1, 38) * 4) if x < 126 or x > 152 then for y = 183 - hh, 183 do px(x, y, y == 183 - hh and S.hi or (x > 170 and S.shade or S.base)) end end end
  return top
end

---------------------------------------------------------------- stone-walled cold frames in perspective (right of road)
local function frame(x0, x1, y0, y1, plant, seed, lid)
  local soil = poly{ { x0 + 4, y0 }, { x1, y0 }, { x1 + 4, y1 }, { x0, y1 } }
  local back = rect(x0 + 3, y0 - 4, x1 + 1, y0)
  local front = rect(x0, y1, x1 + 4, y1 + 4)
  F.shadow(x0, x1 + 4, y1 + 4, 6, 2)
  rimOf(union(soil, front, back), L.stone)
  part(back, L.stone, { nopop = true }) F.rubble(back, L.stone, y0 - 4, 3, seed + 40)
  fill(soil, L.soil.shade)
  soil:each(function(x, y) local v = hash(x, y, seed) if v < .18 then px(x, y, L.soil.deep) elseif v > .92 then px(x, y, L.soil.base) end end)
  part(front, L.stone, { nopop = true }) F.rubble(front, L.stone, y1, 3, seed + 41)
  local n = (x1 - x0) // 7
  for k = 0, n - 1 do plant(x0 + 6 + k * 7, y0 + (y1 - y0) // 2 + 2, k) end
  F.snowCap(back, 2, seed + 42, { lip = true })
  local fs = rect(x0, y1, x1 + 4, y1 + 1)
  fs:each(function(x, y) px(x, y, y == y1 and (x < (x0 + x1) // 2 and S.hi or S.base) or (hash(x, y, seed) < .5 and S.base or L.stone.base)) end)
  if lid == "closed" then
    -- a glass light over the left half: plants show through, driftwood frame, frost
    local xm = x0 + (x1 - x0) * 45 // 100
    local g = poly{ { x0 + 4, y0 - 1 }, { xm, y0 - 1 }, { xm + 4, y1 - 1 }, { x0, y1 - 1 } }
    glass(g, .5)
    g:each(function(x, y) if (x + y * 2) % 13 == 0 then px(x, y, "#f2f6fa") end if hash(x, y, seed + 3) < .08 then px(x, y, L.ice.hi) end end)
    line({ { x0 + 4, y0 - 1 }, { x0, y1 - 1 } }):each(function(x, y) px(x, y, L.timber.base) end)
    line({ { xm, y0 - 1 }, { xm + 4, y1 - 1 } }):each(function(x, y) px(x, y, L.timber.shade) px(x + 1, y, L.timber.edge) end)
    hline(x0 + 4, xm, y0 - 1, L.timber.hi) hline(x0, xm + 4, y1 - 1, L.timber.deep)
    local mid = (x0 + xm) // 2
    line({ { mid + 2, y0 - 1 }, { mid, y1 - 1 } }):each(function(x, y) px(x, y, L.timber.base) end)
  elseif lid == "open" then
    -- the light propped open on a stick, tilted up from the back wall
    local xa, xb = x0 + (x1 - x0) * 62 // 100, x1 - 2
    local g = poly{ { xa, y0 - 4 }, { xb, y0 - 4 }, { xb - 1, y0 - 9 }, { xa - 1, y0 - 9 } }
    local st = line({ { xb - 6, y0 + 1 }, { xb - 6, y0 - 8 } }, 1)
    rimOf(g, L.timber)
    fill(g, F.mix(L.sky[4], L.ice.hi, .4))
    g:each(function(x, y) if (x - y) % 7 == 0 then px(x, y, "#f2f6fa") elseif hash(x, y, seed + 4) < .1 then px(x, y, L.ice.base) end end)
    c:edgeIn(g, L.timber.base)
    hline(xa - 1, xb - 1, y0 - 9, S.hi) hline(xa, xb - 2, y0 - 10, S.base)
    vline((xa + xb) // 2, y0 - 9, y0 - 4, L.timber.base)
    st:each(function(x, y) px(x, y, L.timber.hi) end)
  end
end
local function lingonberry(x, y, k)
  local m = c:ellipse(x, y - 3, 4, 3) fill(m, LG.shade)
  m:each(function(xx, yy) if (xx - x) + (yy - y + 3) < -1 then px(xx, yy, LG.base) end if hash(xx, yy, 71) < .12 then px(xx, yy, LG.hi) end end)
  px(x + 3, y - 1, LG.deep) px(x - 4, y - 3, LG.hi)
  px(x - 1, y - 2, L.apple.base) px(x, y - 2, L.apple.shade) px(x + 2, y - 4, L.apple.base) px(x + 2, y - 5, L.apple.hi)
  if k % 2 == 0 then px(x - 2, y - 5, L.apple.base) px(x - 2, y - 6, L.apple.hi) end
end
local function cloudberry(x, y, k)
  -- broad lobed bronze leaves, one amber berry held up on a stalk
  for _, lf in ipairs({ { -2, -2 }, { 2, -1 } }) do
    local m = c:ellipse(x + lf[1], y + lf[2], 3, 2) fill(m, CBL.base)
    m:each(function(xx, yy) if xx > x + lf[1] then px(xx, yy, CBL.shade) end end)
    px(x + lf[1] - 2, y + lf[2] - 1, CBL.hi) px(x + lf[1], y + lf[2] + 1, CBL.deep)
  end
  vline(x, y - 7, y - 3, CBL.deep)
  fill(rect(x - 1, y - 9, x + 1, y - 7), CB.base) px(x - 1, y - 9, CB.hi) px(x + 1, y - 7, CB.shade) px(x, y - 8, CB.hi)
  px(x - 1, y - 10, CBL.shade) px(x + 1, y - 10, CBL.shade)
end
local function roseroot(x, y, k)
  local v = k % 3
  if v == 0 then
    local m = c:ellipse(x, y - 4, 3, 4) fill(m, RR.base)
    m:each(function(xx, yy) if (xx - x) + (yy - y + 4) > 1 then px(xx, yy, RR.shade) elseif (yy - y) % 2 == 0 and xx < x then px(xx, yy, RR.hi) end end)
    fill(rect(x - 1, y - 9, x + 1, y - 8), CB.hi) px(x + 1, y - 8, L.produce.base) px(x - 1, y - 9, L.gold.hi) px(x, y - 9, L.produce.shade)
  elseif v == 1 then -- low flat rosette of fleshy leaves, a red-gold flower head on a short stalk
    local m = c:ellipse(x, y - 2, 4, 2) fill(m, RR.base)
    m:each(function(xx, yy) if (xx - x) + (yy - y + 2) * 2 > 2 then px(xx, yy, RR.shade) elseif xx < x - 1 then px(xx, yy, RR.hi) end end)
    px(x - 4, y - 2, RR.deep) px(x + 4, y - 2, RR.deep) hline(x - 3, x + 3, y, RR.deep)
    vline(x, y - 7, y - 3, RR.deep)
    fill(rect(x - 1, y - 9, x + 1, y - 7), L.produce.base) px(x - 1, y - 9, L.produce.hi) px(x + 1, y - 7, L.produce.deep)
  else -- three upright stems with red seed pods and pointed leaves
    for i, dx in ipairs({ -2, 0, 2 }) do
      local h = 6 + (i % 2) * 2
      vline(x + dx, y - h, y, RR.shade)
      px(x + dx - 1, y - 3, RR.base) px(x + dx + 1, y - 5, RR.hi)
      px(x + dx, y - h - 1, L.apple.base) px(x + dx, y - h, L.apple.shade)
    end
    px(x - 1, y - 9, L.apple.hi) px(x + 3, y - 8, L.gold.base)
  end
end
local function lichen(x, y, k)
  -- reindeer lichen cushions: pale, knobbly, lit upper left
  local m = c:ellipse(x, y - 2, 4, 3)
  m:each(function(xx, yy)
    local v = hash(xx, yy, 72)
    local ul = (xx - x) + (yy - y + 2) * 1.3
    px(xx, yy, ul < -2 and RL.hi or (ul < 1 and (v < .3 and RL.shade or RL.base) or (v < .5 and RL.shade or RL.deep)))
  end)
  if k % 3 == 1 then px(x + 3, y - 4, L.lichen.base) px(x + 4, y - 4, L.lichen.shade) end
  if k % 2 == 0 then px(x - 2, y - 5, L.apple.base) end
end

---------------------------------------------------------------- compose: back to front
F.depth(1)
F.tree(86, 130, 40, 2)
F.tree(12, 140, 36, 1)
local domeTop = clocheHouse(22, 76, 140)
F.steam(49, domeTop - 6, 5, .5, 11)
-- two far gnomes picking in the berry rows
F.gnome(420, 150, { small = true, hat = L.awnA, coat = L.accent, arm = "out" })
F.gnome(352, 138, { small = true, hat = L.roof2, coat = L.wall2, flip = true })
-- dwarf willow scrub along the left back, behind the turf house
for x = 104, 206, 10 do F.willow(x, 136 + (x % 3), 5, 6 + (x % 4), x) end
F.depth(2)
F.tree(204, 128, 44, 1)
F.tree(282, 130, 46, 7)
arch()
F.tree(458, 168, 56, 0)
F.depth(3)
cottage()
F.smoke(172, 104, 7, .5, 2)
-- driftwood A-frame drying rack near the road (left): lichen, sedge, angelica bundles and a rowan garland
local function dryRack(x0, yb)
  local legs = line({ { x0, yb }, { x0 + 6, yb - 26 }, { x0 + 12, yb } }, 2):add(line({ { x0 + 30, yb }, { x0 + 36, yb - 26 }, { x0 + 42, yb } }, 2))
  local bar = rect(x0 + 4, yb - 26, x0 + 38, yb - 25)
  F.shadow(x0, x0 + 42, yb, 6, 2)
  rimOf(union(legs, bar), L.timber) part(legs, L.timber, { nopop = true, noshade = true }) part(bar, L.timber, { nopop = true, noshade = true })
  union(legs, bar):each(function(x, y) if hash(x, y // 2, 85) < .2 then px(x, y, L.timber.hi) end end)
  hline(x0 + 4, x0 + 38, yb - 27, S.hi) for k = 0, 34, 4 do px(x0 + 5 + k, yb - 28, S.base) end
  for k = 0, 5 do
    local x = x0 + 9 + k * 5
    local r = ({ RL, L.fern, RR, CR, L.fern, LG })[k + 1]
    vline(x, yb - 24, yb - 22, L.timber.edge)
    local b = poly{ { x - 2, yb - 21 }, { x + 2, yb - 21 }, { x + 1, yb - 12 }, { x - 1, yb - 12 } }
    rimOf(b, r) fill(b, r.base) px(x - 1, yb - 20, r.hi) px(x - 1, yb - 17, r.hi) vline(x + 1, yb - 19, yb - 13, r.shade)
    hline(x - 2, x + 2, yb - 21, L.wall2.base)
  end
  for xx = x0 + 6, x0 + 36 do
    local t = (xx - x0 - 6) / 30
    local yy = floor(yb - 9 + 4 * 4 * t * (1 - t))
    px(xx, yy, L.board.deep)
    if (xx - x0) % 3 == 0 then px(xx, yy + 1, L.apple.base) px(xx + 1, yy + 1, L.apple.shade) px(xx, yy + 2, L.apple.deep) end
  end
end
dryRack(160, 214)
-- the cold frames on the right, near ones larger
frame(276, 360, 166, 174, lingonberry, 3, "closed")
frame(282, 380, 182, 192, cloudberry, 4, nil)
frame(290, 400, 202, 214, roseroot, 5, "open")
frame(300, 376, 228, 242, lichen, 6, nil)
-- quirk: an arctic fox in a red gnome hat, curled asleep on the warm lichen, a snow bunting perched on its back
do
  F.sprite({
    "..................R.........",
    ".................RRr........",
    "................RRRr........",
    "...............RRRRrr.......",
    "..............RRRRRRr.......",
    ".............hhhhhhhhh......",
    "......WWWWWWEWWWWWWWWWE.....",
    "....WWWWWWWWWWWWWWWWWWWW....",
    "...WWWWWWWWWWWWWWWWeeWWWWW..",
    "..WWWWWWWWWWWWWWWWWWWWWWWWWn",
    ".WWWWsWWWWWWWWWWWWWWWWWWWss.",
    ".WWWssWWWWWWWWWWWWsWWWss....",
    "WWsTTTTTTTTsssWWWWsWW.......",
    "WsTTTTTTTTTTTTsssssPPPP.....",
    "sTTTTTTTTTTTTTTTTTsPPPP.....",
    ".sTTTTTTTTTTTTTTTtt.........",
    "..sstTTTTTTTTTtt............",
  }, 320, 219, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, E = L.fur.deep, W = L.fur.hi, s = L.fur.shade,
    T = L.fur.base, t = L.fur.shade, e = L.timber.edge, n = L.timber.edge, P = L.fur.base })
  -- hat highlights, a shaded tail curl, the fur of the cheek, a pink nose tip
  px(336, 222, L.awnA.hi) px(335, 223, L.awnA.hi) px(334, 224, L.awnA.hi) px(337, 220, L.awnA.hi)
  for _, q in ipairs({ { 324, 233 }, { 327, 234 }, { 330, 234 }, { 333, 233 } }) do px(q[1], q[2], L.fur.shade) end
  hline(339, 340, 227, L.timber.deep) px(346, 228, "#e88a96") px(341, 230, L.fur.base) px(342, 230, L.fur.base)
  -- a snow bunting perched on its back
  F.sprite({
    "..cc.",
    ".cWWk",
    "WWWWb",
    "KWKW.",
    ".o.o.",
  }, 325, 221, { W = L.fur.hi, c = L.board.hi, k = L.timber.edge, b = L.gold.shade, K = L.timber.edge, o = L.timber.deep })
  local bub = c:ellipse(352, 216, 2, 2) fill(bub, L.water.hi) px(351, 215, "#f4f6fa")
  px(349, 220, L.water.hi)
  -- its pawprints leading in from the road
  for i = 0, 4 do local tx, ty = 296 + i * 6, 250 - i * 2 px(tx, ty, S.deep) px(tx + 1, ty + 1, S.shade) end
end
-- potting table: pots under glass bell jars, jars of cloudberry preserve, a basket of lichen
local function pottingTable()
  local tp = rect(402, 172, 452, 175)
  local legs = rect(405, 176, 407, 196):add(rect(447, 176, 449, 196))
  local shelf = rect(404, 188, 450, 189)
  F.shadow(404, 452, 196, 8, 3)
  rimOf(union(tp, legs, shelf), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true }) part(shelf, L.timber, { nopop = true, noshade = true }) part(tp, L.board)
  F.planks(tp, L.board, 6, true, 21)
  hline(436, 452, 172, S.hi) hline(440, 452, 173, S.base)
  for k = 0, 2 do
    local x = 406 + k * 12
    local pot = poly{ { x, 165 }, { x + 8, 165 }, { x + 7, 171 }, { x + 1, 171 } }
    rimOf(pot, L.produce) part(pot, L.soil, { nopop = true }) hline(x, x + 8, 165, L.soil.hi)
    local rr = ({ GREEN, SAX, RR })[k + 1]
    local pl = c:ellipse(x + 4, 161, 3, 3) fill(pl, rr.base) px(x + 3, 159, rr.hi) px(x + 2, 160, rr.hi) px(x + 6, 162, rr.shade)
    if k ~= 1 then
      -- bell jar over the pot
      local bj = c:ellipse(x + 4, 162, 5, 8):clip(rect(x - 1, 152, x + 9, 164))
      glass(bj, .4)
      bj:each(function(xx, yy) if not bj:has(xx - 1, yy) or not bj:has(xx, yy - 1) then px(xx, yy, L.ice.hi) elseif not bj:has(xx + 1, yy) then px(xx, yy, L.ice.deep) end end)
      fill(rect(x + 3, 152, x + 5, 153), L.ice.base) px(x + 3, 152, S.hi) px(x + 4, 151, S.hi)
      px(x + 1, 156, "#f4f6fa")
    end
  end
  for k = 0, 1 do
    local x = 442 + k * 6
    local jar = rect(x - 2, 164, x + 2, 171) fill(jar, L.water.hi) fill(rect(x - 1, 167, x + 1, 171), ({ CB, L.apple })[k + 1].base) px(x + 1, 170, ({ CB, L.apple })[k + 1].shade)
    hline(x - 2, x + 2, 164, L.wall2.base) hline(x - 2, x + 2, 163, L.board.hi) px(x - 2, 166, "#f2f6fa")
  end
  local bk = poly{ { 430, 181 }, { 446, 181 }, { 444, 187 }, { 432, 187 } }
  rimOf(bk, L.leaf) part(bk, L.leaf, { nopop = true }) bk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.leaf.shade) end end)
  for k = 0, 6 do local mx = 431 + k * 2 px(mx, 180, RL.base) px(mx + 1, 179, RL.hi) end
  for k = 0, 1 do local x = 408 + k * 10 local pot = rect(x, 184, x + 6, 187) fill(pot, L.soil.shade) hline(x, x + 6, 184, L.soil.base) end
  F.icicles(402, 452, 176, 2, 25, .2)
end
pottingTable()
-- willow baskets heaped with picked berries on a snowy bench, redpolls helping themselves
local function baskets()
  local bench = rect(410, 214, 462, 216):add(rect(412, 217, 414, 224)):add(rect(458, 217, 460, 224))
  F.shadow(410, 462, 224, 6, 2)
  rimOf(bench, L.timber) part(bench, L.timber, { nopop = true, noshade = true })
  for k = 0, 2 do
    local x = 420 + k * 16
    local bb = poly{ { x - 7, 203 }, { x + 7, 203 }, { x + 5, 213 }, { x - 5, 213 } }
    local heap = c:ellipse(x, 203, 6, 4):clip(rect(x - 7, 198, x + 7, 203))
    local handle = c:ellipse(x, 202, 6, 9):cut(c:ellipse(x, 202, 5, 8)):clip(rect(x - 7, 192, x + 7, 199))
    rimOf(union(bb, heap, handle), L.leaf)
    part(bb, L.leaf, { nopop = true })
    bb:each(function(xx, yy) if (yy - 203) % 3 == 0 then px(xx, yy, L.leaf.deep) elseif (xx + (yy // 3)) % 3 == 0 then px(xx, yy, L.leaf.shade) elseif xx < x - 2 then px(xx, yy, L.leaf.hi) end end)
    handle:each(function(xx, yy) px(xx, yy, xx < x and L.leaf.base or L.leaf.shade) end)
    local br = ({ CB, L.apple, CR })[k + 1]
    heap:each(function(xx, yy)
      local v = hash(xx, yy, 60 + k)
      local ul = (xx - x) + (yy - 201) * 1.5
      px(xx, yy, (v < .3 and ul < 0) and br.hi or (ul < 3 and br.base or br.shade))
      if v > .9 then px(xx, yy, br.deep) end
    end)
    px(x + 4, 200, LG.base) px(x - 5, 202, LG.shade)
  end
  hline(410, 462, 213, S.hi) for x = 410, 462, 3 do px(x, 214, S.base) end
  -- redpolls: brown-streaked, a red cap, one on a basket rim, one on the bench
  for _, rp in ipairs({ { 427, 201, false }, { 452, 210, true } }) do
    F.sprite(rp[3] and { ".r..", "bBBB", "BBBk", ".o.." } or { "..r.", "BBBb", "kBBB", "..o." }, rp[1], rp[2],
      { r = L.apple.base, b = L.gold.shade, B = L.deer.base, k = L.deer.deep, o = L.timber.deep })
  end
end
baskets()
-- stone herb spiral, bottom-left: crowberry, purple saxifrage, reindeer lichen, snow on every ring
local function spiral(cx, cy)
  F.shadow(cx - 36, cx + 40, cy + 14, 8, 3)
  local tiers = { { 40, 13, 0, CR }, { 28, 9, 9, SAX }, { 16, 6, 17, RL } }
  for i, t in ipairs(tiers) do
    local rx, ry, up, rr = t[1], t[2], t[3], t[4]
    local top = c:ellipse(cx, cy - up - 4, rx, ry)
    local body = union(top, c:ellipse(cx, cy - up, rx, ry))
    rimOf(body, L.stone)
    local face = c:ellipse(cx, cy - up, rx, ry):cut(top)
    part(face, L.stone, { nopop = true }) F.rubble(face, L.stone, cy - up - 4, 3, 50 + i)
    fill(top, L.soil.shade)
    top:each(function(x, y)
      local v = hash(x, y, i * 7)
      local ul = (x - cx) / rx + (y - cy + up + 4) / ry
      if v < .5 then px(x, y, ul < -.3 and rr.hi or rr.base) elseif v < .7 then px(x, y, rr.shade) elseif v < .76 then px(x, y, rr.deep) end
      if i == 1 and hash(x, y, 77) < .06 then px(x, y, CR.deep) end
      if i == 1 and hash(x, y, 78) < .03 then px(x, y, L.apple.base) end
    end)
    -- snow lying on the far part of each ring and drifted in the lee (right)
    top:each(function(x, y)
      if not top:has(x, y - 1) then px(x, y, x < cx and S.hi or S.base) if top:has(x, y + 1) and hash(x, y, 79 + i) < .5 then px(x, y + 1, S.base) end end
      if x > cx + rx * .4 and hash(x // 2, y, 80 + i) < .35 then px(x, y, S.shade) end
    end)
    c:edgeIn(face, L.stone.deep)
  end
  F.willow(cx, cy - 22, 4, 7, 61)
  F.steam(cx + 2, cy - 30, 3, .3, 62)
end
spiral(74, 248)
-- frosted angelica umbels and dry fireweed seed spikes along the left
for k, x in ipairs({ 26, 36, 46, 58, 70, 82 }) do
  local yb, h = 206 + (k % 2) * 3, 32 + floor(hash(k, 1, 5) * 20)
  local function sx(y) return x + floor(sin((yb - y) / h * 2.2 + k) * 2 * (yb - y) / h + .5) end
  if k % 2 == 1 then
    -- angelica: straw stem, side umbels, a big snow-capped crown umbel
    for y = yb - h, yb do px(sx(y), y, L.fern.shade) px(sx(y) + 1, y, L.fern.deep) end
    for _, u in ipairs({ { 0, 8 }, { -1, 4 }, { 1, 4 } }) do
      local uy = (u[1] == 0) and (yb - h) or (yb - h + 10 + floor(hash(k, u[1], 6) * 6))
      local ux = sx(uy) + u[1] * 5
      local w = u[2]
      if u[1] ~= 0 then line({ { sx(uy + 4), uy + 4 }, { ux, uy } }):each(function(xx, yy) px(xx, yy, L.fern.shade) end) end
      for j = -w, w, 2 do line({ { ux, uy + 3 }, { ux + j, uy } }):each(function(xx, yy) px(xx, yy, L.fern.base) end) end
      for j = -w, w do
        local dy = floor((j * j) * .8 / w + .5)
        px(ux + j, uy + dy, (j < 0) and S.hi or S.base)
        px(ux + j, uy + dy + 1, ((ux + j) % 2 == 0) and L.fern.hi or L.fern.shade)
        if abs(j) < w then px(ux + j, uy + dy + 2, ((ux + j) % 2 == 1) and L.fern.base or L.fern.deep) end
      end
    end
    -- frost-browned basal leaves
    for _, lf in ipairs({ { -6, -2 }, { -4, -6 }, { 5, -5 }, { 7, -1 } }) do
      line({ { sx(yb), yb }, { sx(yb) + lf[1], yb + lf[2] } }, 1):each(function(xx, yy) px(xx, yy, L.leaf.shade) end)
      px(sx(yb) + lf[1], yb + lf[2], L.leaf.hi)
    end
  else
    -- fireweed: rust stem, seed pods splitting into white fluff toward the top, last red leaves
    for y = yb - h, yb do px(sx(y), y, L.rust.shade) end
    local i = 0
    for y = yb - 6, yb - h + 1, -3 do
      i = i + 1
      local t = (yb - y) / h
      local o = (i % 2 == 0) and -1 or 1
      if t < .45 then
        line({ { sx(y), y }, { sx(y) + o * 3, y + 1 } }):each(function(xx, yy) px(xx, yy, L.rust.base) end) px(sx(y) + o * 3, y + 1, L.rust.hi)
      else
        line({ { sx(y), y }, { sx(y) + o * 2, y - 2 } }):each(function(xx, yy) px(xx, yy, L.rust.deep) end)
        local fx, fy = sx(y) + o * 3, y - 3
        px(fx, fy, L.fur.hi) px(fx + o, fy - 1, L.fur.base) px(fx, fy - 1, L.fur.shade) px(fx - o, fy, L.fur.base)
      end
    end
    px(sx(yb - h), yb - h - 1, L.fur.hi) px(sx(yb - h) + 1, yb - h - 2, L.fur.base)
  end
  -- a snow mound at the foot
  local d = c:ellipse(sx(yb) + 1, yb, 5, 2):clip(rect(x - 8, yb - 2, x + 8, yb))
  fill(d, S.base) hline(sx(yb) - 3, sx(yb) + 1, yb - 2, S.hi) px(sx(yb) + 5, yb, S.shade)
end
-- a border of lingonberry and crowberry cushions at the foot of the stalks, snow between
for i, x in ipairs({ 20, 30, 41, 52, 63, 74, 86 }) do
  local y = 215 + (i % 2) * 2
  if i % 3 == 0 then
    local m = c:ellipse(x, y - 2, 4, 3) c:rim(m, LG.edge)
    m:each(function(xx, yy) local v = hash(xx, yy, 91) px(xx, yy, ((xx - x) + (yy - y) < -2) and (v < .5 and LG.hi or LG.base) or (v < .6 and LG.shade or LG.deep)) end)
    px(x - 1, y - 2, CR.shade) px(x - 2, y - 3, CR.hi) px(x + 2, y - 1, CR.deep) px(x + 1, y - 3, CR.shade) px(x - 2, y - 5, S.hi) px(x - 1, y - 5, S.hi)
  else
    lingonberry(x, y, i) px(x - 3, y - 6, S.hi) px(x - 2, y - 6, S.base)
  end
end
-- more colour in the left bed: purple saxifrage, golden saxifrage, pink moss campion, white cotton grass
for i = 0, 30 do
  local x, y = 18 + floor(hash(i, 1, 93) * 76), 212 + floor(hash(i, 2, 93) * 9)
  local kind = i % 4
  local col = kind == 0 and { L.lav.hi, L.lav.base } or (kind == 1 and { L.gold.hi, L.gold.base } or (kind == 2 and { L.petal.hi, L.petal.base } or { "#f4f6fa", S.base }))
  px(x, y, col[1]) px(x + 1, y, col[2]) px(x, y + 1, LG.shade) px(x + 1, y + 1, LG.deep)
  if kind == 2 then px(x, y - 1, col[1]) end
end
-- gnome harvesting with a basket of cloudberries
local _, gx, gy = F.gnome(268, 218, { hat = L.awnA, coat = L.leaf, arm = "out" })
local bsk = poly{ { gx - 1, gy - 1 }, { gx + 11, gy - 1 }, { gx + 9, gy + 6 }, { gx + 1, gy + 6 } } rimOf(bsk, L.leaf) part(bsk, L.leaf)
bsk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.leaf.shade) end end)
for k = 0, 4 do local col = ({ CB, CB, L.apple, CB, LG })[k + 1] px(gx + 1 + k * 2, gy - 2, col.base) px(gx + 1 + k * 2, gy - 3, col.hi) end
F.tracks({ { 262, 236 }, { 258, 250 } }, "boot", 5)
-- the waterer, tipping a can of warm water (steaming) over the herb spiral
local _, wx, wy = F.gnome(164, 254, { hat = L.roof2, coat = L.wall2, arm = "out", flip = true })
local wcan = rect(wx - 8, wy - 3, wx - 1, wy + 3):add(line({ { wx - 8, wy }, { wx - 14, wy - 4 } }, 2))
rimOf(wcan, L.iron) part(wcan, L.iron) fill(rect(wx - 16, wy - 6, wx - 13, wy - 4), L.iron.shade)
hline(wx - 8, wx - 1, wy - 1, L.iron.hi)
for k = 0, 4 do px(wx - 17 - k, wy - 3 + k * 2, L.water.hi) px(wx - 15 - k, wy - 2 + k * 2, L.water.base) end
F.steam(wx - 18, wy - 6, 4, .4, 63)
-- sedge tufts and willow along the turf house foot and the left edge
for _, f in ipairs({ { 92, 190, 6 }, { 188, 190, 5 }, { 20, 218, 7 }, { 98, 216, 5 }, { 214, 238, 6 } }) do F.fern(f[1], f[2], f[3]) end
F.willow(14, 226, 6, 8, 64) F.willow(206, 196, 5, 6, 65)
F.drift(40, 172, 22, 5, 66)
F.depth(0)
-- redpolls and snow buntings flitting, ravens high up
for i = 0, 9 do
  local bx, by = 300 + floor(hash(i, 1, 33) * 160), 132 + floor(hash(i, 2, 33) * 80)
  px(bx, by, L.deer.base) px(bx + 1, by, L.timber.edge) px(bx - 1, by - 1, i % 2 == 0 and L.apple.base or L.fur.base) px(bx + 1, by - 1, L.deer.shade)
end
F.birds({ { 330, 44, 2 }, { 344, 40, 1 }, { 120, 60, 2 } })
-- glass bell cloches over seedlings in the snow, bottom-right
F.depth(3)
for k, x in ipairs({ 297, 318, 368 }) do
  local yb = 262
  local pot = poly{ { x - 5, yb - 6 }, { x + 5, yb - 6 }, { x + 4, yb }, { x - 4, yb } }
  F.shadowM(c:ellipse(x + 6, yb + 1, 9, 2))
  rimOf(pot, L.produce) part(pot, L.soil, { nopop = true }) hline(x - 5, x + 5, yb - 6, L.soil.hi)
  local rr = ({ GREEN, SAX, GREEN })[k]
  local pl = c:ellipse(x, yb - 9, 3, 3) fill(pl, rr.base) px(x - 1, yb - 11, rr.hi) px(x + 2, yb - 8, rr.shade)
  if k == 2 then px(x, yb - 12, SAX.hi) px(x - 2, yb - 10, SAX.hi) end
  local bj = c:ellipse(x, yb - 6, 8, 14):clip(rect(x - 9, yb - 20, x + 9, yb - 2))
  local rim = rect(x - 9, yb - 3, x + 9, yb - 2)
  glass(bj, .42)
  bj:each(function(xx, yy)
    if not bj:has(xx - 1, yy) or not bj:has(xx, yy - 1) then px(xx, yy, L.ice.hi)
    elseif not bj:has(xx + 1, yy) then px(xx, yy, L.ice.deep) end
    if yy > yb - 6 and hash(xx, yy, 90 + k) < .3 then px(xx, yy, L.ice.base) end -- condensation at the foot
  end)
  c:rim(bj, L.ice.edge)
  fill(rim, L.ice.base) hline(x - 9, x + 9, yb - 3, L.ice.hi)
  local knob = c:ellipse(x, yb - 21, 2, 2) c:rim(knob, L.ice.edge) fill(knob, L.ice.hi) px(x - 1, yb - 23, S.hi) px(x, yb - 23, S.hi) px(x + 1, yb - 22, S.base)
  px(x - 5, yb - 13, "#f4f6fa") px(x - 5, yb - 12, "#f4f6fa") px(x - 4, yb - 16, "#f4f6fa")
  -- snow banked against the foot
  hline(x - 11, x - 8, yb - 1, S.hi) hline(x + 8, x + 11, yb - 1, S.shade)
end
F.finish()
