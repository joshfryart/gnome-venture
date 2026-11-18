-- inn.lua : "Inn" stop look, TUNDRA (tundra_frost), 480x270 gate view.
-- Same composition as the Maplewold inn (art-2701-batch4/stops/opus3/inn.lua) and the forest inn, re-cast for an
-- arctic tundra: left hero: a big two-storey sod-roofed lodge. Ground floor of herringbone turf blocks on a granite
-- plinth, a jettied upper floor of falu-red weatherboards with white Nordic trim and blue shutters, a deep sod roof
-- under a heavy snow cap with dormers and two smoking fieldstone chimneys, icicles along the eave, glowing bay
-- windows, a slate porch hood with reindeer antlers. A stockfish drying rack against the left gable end.
-- Gallows sign post with the tankard board. Right: a beer garden under snowy spruces, festoon lanterns, a trestle
-- table with three gnomes raising steaming mugs, a fire basket, skis against the barrels, snow buntings at the crumbs.
-- Road's end: a sod coach shed with a sledge nose. Back right: a falu-red cabin. An Icelandic pony at a hay sledge.
-- Two reindeer tethered at the hitching rail by an iced log trough; one chews the tether.
-- Quirk: an arctic fox in a red gnome hat asleep on top of the inn sign, brush hanging down over the tankard, "z z".
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-tundra-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "inn", out = DIR, farTrees = { 24, 150, 206, 300, 340, 380, 452 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local mix = F.mix
local S = L.snow
local SACK = F.rp("#ecd6aa #ccae80 #a68660 #7a604a #4a3a34")
local TURF = F.rp("#cbbb8c #a49064 #7c6a4a #5a4a38 #382c24")
local DARKDEER = F.rp("#a89080 #7e6658 #5e4a42 #423432 #2a2024")

-- herringbone turf-block wall (Icelandic klombruhnaus): rows of slanted blocks, direction flips each row,
-- a dark earth seam between rows, frost on the row tops, moss and lichen flecks
local function turf(m, y0, seed)
  seed = seed or 70
  m:each(function(x, y)
    local row, ry = (y - y0) // 5, (y - y0) % 5
    local dir = (row % 2 == 0) and 1 or -1
    local k = (x + ry * dir + row * 2) % 5
    local h
    if ry == 4 then h = TURF.deep
    elseif k == 0 then h = TURF.shade
    elseif k == 1 then h = (hash(x // 5, row, seed) < .5) and TURF.hi or TURF.base
    else h = TURF.base end
    if ry == 3 and k == 0 then h = TURF.deep end
    if ry == 0 and hash(x // 2, row, seed + 1) < .4 then h = S.base end
    if ry == 3 and hash(x, row, seed + 2) < .12 then h = L.greyMoss.base end
    if hash(x // 3, y // 3, seed + 3) < .035 then h = L.lichen.base end
    px(x, y, h)
  end)
end
-- snow cover on a sod roof: snow down to a lumpy line, lit left of cx, sod showing below and in scoured patches
local function roofSnow(m, y0, depthF, cx, seed)
  m:each(function(x, y)
    local d = depthF(x) + floor(F.vnoise(x / 7, 1, seed) * 6)
    if y - y0 < d then
      local edge = (y - y0) >= d - 1
      local h
      if edge then h = S.deep
      elseif (y - y0) >= d - 2 then h = S.shade
      else
        local v = F.vnoise(x / 9, y / 4, seed + 2)
        if x < cx then h = v > .55 and S.hi or S.base else h = v > .6 and S.base or S.shade end
        if hash(x, y, seed) < .02 then h = S.hi end
      end
      if (y - y0) % 7 == 3 and hash(x // 4, y, seed + 1) < .25 then h = (x < cx) and S.base or S.deep end -- wind ripples
      px(x, y, h)
    end
  end)
end
local function steamMug(x, y) px(x + 1, y - 8, "#eceef6") px(x + 2, y - 9, "#e4e8f2") px(x + 1, y - 10, "#eceef6") px(x + 2, y - 12, "#e4e8f2") end
local function berries(x, y, r)
  r = r or L.apple
  px(x, y + 1, L.fern.shade) px(x - 1, y + 2, L.fern.deep) px(x + 1, y + 2, L.fern.base)
  px(x, y, r.base) px(x + 1, y, r.shade) px(x - 1, y - 1, r.base) px(x - 1, y, r.hi)
end

---------------------------------------------------------------- back row: sod coach shed at the road's end, far cabin
F.depth(1)
F.tree(300, 128, 34, 4)
F.tree(236, 126, 28, 2)
do
  local top, _, bwall = F.building{ x0 = 246, x1 = 292, yb = 128, wh = 16, rh = 13, wall = L.timber, roof = L.roof, noFrame = true, noAttic = true, snow = 4 }
  F.planks(bwall, L.timber, 3, true, 4)
  local d = c:rrect(260, 117, 276, 133, 5):clip(rect(260, 117, 276, 128))
  fill(d, L.soil.deep) c:edgeIn(d, L.timber.hi)
  -- a sledge nose curling out of the dark, a lamp lit deep inside
  line({ { 263, 127 }, { 271, 127 }, { 273, 125 } }):each(function(x, y) px(x, y, L.board.base) end)
  fill(rect(264, 124, 271, 125), L.wall2.base)
  px(268, 121, L.glow.shade) px(269, 121, L.glow.base)
  F.drift(250, 129, 8, 3, 21)
end
do
  local top, _, cwall = F.building{ x0 = 416, x1 = 456, yb = 126, wh = 13, rh = 10, wall = L.wall2, roof = L.roof, noFrame = true, noAttic = true, chimney = true, snow = 3 }
  F.planks(cwall, L.wall2, 3, true, 32)
  F.window(424, 117, 428, 120, L.plaster) F.window(446, 117, 450, 120, L.plaster)
end
F.smoke(447, 98, 4, .5, 2)
F.fenceP(300, 132, 410, 129, 10)
F.drift(360, 133, 18, 3, 23)
-- the shed's washing line: a red blanket, a woollen tunic, a mitten
do local wp = rect(318, 112, 319, 130) rimOf(wp, L.timber) part(wp, L.timber, { nopop = true, noshade = true }) end
F.washing(293, 114, 318, 113, { { "sheet", L.wall2 }, { "shirt", L.accent }, { "sock", L.awnA } }, 3)

---------------------------------------------------------------- mid right: spruces + bare birch, hay sledge, the pony
F.depth(2)
F.tree(352, 152, 50, 6)
F.birch(384, 158, 44, 17)
F.tree(322, 140, 34, 5)
F.willow(398, 150, 6, 6, 61)
local function haySledge(x0, yb)
  local runner = line({ { x0 - 2, yb }, { x0 + 46, yb } }):add(line({ { x0 - 2, yb }, { x0 - 6, yb - 3 }, { x0 - 5, yb - 6 } }))
  local bed = poly{ { x0, yb - 10 }, { x0 + 46, yb - 10 }, { x0 + 44, yb - 4 }, { x0 + 2, yb - 4 } }
  local stan = rect(x0 + 6, yb - 3, x0 + 7, yb - 1):add(rect(x0 + 38, yb - 3, x0 + 39, yb - 1))
  local hay = c:ellipse(x0 + 23, yb - 14, 25, 8):clip(rect(x0 - 4, yb - 28, x0 + 50, yb - 9))
  rimOf(union(runner, bed, stan, hay), L.timber)
  part(runner, L.timber, { nopop = true, noshade = true }) hline(x0 - 2, x0 + 46, yb, S.hi)
  part(stan, L.timber, { nopop = true, noshade = true })
  part(bed, L.wall2) F.planks(bed, L.wall2, 4, true, 3)
  part(hay, L.fern)
  hay:each(function(x, y)
    if hash(x, y, 81) < .18 then px(x, y, L.fern.hi) elseif (x * 2 + y) % 5 == 0 then px(x, y, L.fern.shade) end
    if y > yb - 12 and hash(x, y, 82) < .3 then px(x, y, L.fern.deep) end
  end)
  F.snowCap(hay, 3, 83, { cx = x0 + 18 })
  for i = 0, 9 do local hx = x0 + 2 + i * 5 px(hx, yb - 13 + (i % 3), L.fern.hi) end
end
F.shadow(300, 350, 166, 8, 3)
haySledge(302, 166)
-- a shaggy dun Icelandic pony with a dark mane, head down in the hay, a red blanket on its back
F.shadowM(c:ellipse(364, 167, 12, 1))
F.sprite({
  ".......mm...............",
  "......mmBBhhhhhhhhhh....",
  ".....mmBBBBrrrrrrrBBBh.t",
  "....mmBBBBBrRRRRRrBBBBtt",
  "...mmBBBBBBrRRRRRrBBBBtt",
  "..mBBB.BBBBrrrrrrrBBBBtt",
  ".mBeB..BBBBBBBBBBBBBBB.t",
  "BBkB...dBBBBBBBBBBBBBd.t",
  "BBBw....dBBdddddddBBBd.t",
  "BBww....BB.d.....BB.d...",
  "nBw.....Bd.d.....Bd.d...",
  "nn......Bd.dd....Bd.dd..",
  "........dd.dd....dd.dd..",
  "........ff.ff....ff.ff..",
}, 347, 153, { m = L.timber.deep, h = L.board.hi, B = L.board.base, d = L.board.shade, k = L.timber.edge, w = L.fur.hi,
  n = L.board.deep, t = L.timber.deep, f = L.timber.edge, e = L.timber.edge, r = L.awnA.shade, R = L.awnA.base })
hline(358, 364, 156, L.gold.base)
px(346, 162, L.fern.hi) px(345, 163, L.fern.base) px(346, 164, L.fern.hi) px(345, 161, L.fern.shade)
F.steam(345, 159, 3, -.4, 12) -- the pony's breath

---------------------------------------------------------------- the lodge (left hero)
F.depth(3)
local function inn()
  local X0, X1 = 30, 184
  local GTOP, YB = 142, 182
  local UX0, UX1, UTOP = 25, 189, 106
  local ground = rect(X0, GTOP, X1, YB)
  local upper = rect(UX0, UTOP, UX1, GTOP - 1)
  local roof = poly{ { 14, UTOP + 1 }, { 200, UTOP + 1 }, { 178, 62 }, { 36, 62 } }
  local ch1, ch2 = rect(52, 46, 61, 70), rect(152, 42, 161, 70)
  local dorm = {}
  for _, dx in ipairs({ 74, 140 }) do
    dorm[#dorm + 1] = { x = dx, m = poly{ { dx - 11, 96 }, { dx, 76 }, { dx + 11, 96 } }:add(rect(dx - 8, 89, dx + 8, 99)) }
  end
  local sil = union(ground, upper, roof, ch1, ch2)
  F.shadow(X0 + 4, X1 + 4, YB, 14, 5)
  rimOf(sil, L.timber)
  -- chimneys: fieldstone rubble, slab caps, snow on top
  for i, ch in ipairs({ ch1, ch2 }) do part(ch, L.stone) F.rubble(ch, L.stone, 42, 4, 33 + i) end
  fill(rect(51, 45, 62, 47), L.stone.deep) hline(51, 62, 45, L.stone.hi)
  fill(rect(151, 41, 162, 43), L.stone.deep) hline(151, 162, 41, L.stone.hi)
  hline(51, 62, 44, S.hi) hline(52, 60, 43, S.base) hline(151, 162, 40, S.hi) hline(152, 160, 39, S.base)
  -- roof: thick sod turf, hipped ends turned from the light, snow down the upper slope, scoured patches
  part(roof, L.roof, { band = 3 })
  F.sod(roof, L.roof, 62, 100)
  roof:each(function(x, y)
    local lx = 36 - (y - 62) * 22 / 45
    local rx = 178 + (y - 62) * 22 / 45
    if x > rx - 12 and hash(x, y, 9) < .7 then px(x, y, ((y - 62) % 5 == 4) and L.roof.edge or L.roof.deep) end
    if x < lx + 6 and hash(x, y, 10) < .5 then px(x, y, L.roof.hi) end
  end)
  -- grass tufts sticking up through the snow line and curling over the eave
  roofSnow(roof, 62, function(x) return 22 + floor(6 * sin(x / 23)) + ((x > 168) and 6 or 0) end, 110, 91)
  for i = 0, 40 do
    local x = 18 + floor(hash(i, 1, 92) * 178)
    local y = 62 + 20 + floor(hash(i, 2, 92) * 20)
    if roof:has(x, y) then px(x, y, L.roof.hi) px(x + 1, y - 1, L.fern.hi) px(x - 1, y - 1, L.roof.base) end
  end
  -- snow patches lower on the sod (wind-lodged), lit tops
  for i, b in ipairs({ { 46, 98, 8 }, { 104, 100, 9 }, { 166, 98, 7 }, { 128, 92, 5 }, { 24, 104, 5 } }) do
    roof:each(function(x, y)
      local d = ((x - b[1]) / b[3]) ^ 2 + ((y - b[2]) / (b[3] * .45)) ^ 2
      if d < 1 and hash(x, y, 30 + i) < .9 then px(x, y, (y < b[2] - 1) and S.hi or (d > .6 and S.shade or S.base)) end
    end)
  end
  -- a raven on the ridge snow
  F.sprite({ "..kk...", ".kKkk..", "kKKKKKo", ".kKKKk.", "..o.o.." }, 118, 57, { k = "#3a3848", K = "#55526a", o = L.timber.edge })
  hline(14, 200, UTOP + 1, L.roof.edge) hline(15, 199, UTOP, L.roof.deep)
  for x = 16, 198, 2 do if hash(x, 1, 93) < .6 then px(x, UTOP + 2, L.roof.shade) if hash(x, 2, 93) < .4 then px(x, UTOP + 3, L.roof.deep) end end end
  -- dormers: sod hoods with snow, falu-red faces, white bargeboards
  for _, d in ipairs(dorm) do
    rimOf(d.m, L.roof)
    local wall = rect(d.x - 7, 89, d.x + 7, 99)
    part(d.m, L.roof, { nopop = true }) F.sod(d.m, L.roof, 76, d.x)
    F.snowCap(d.m, 4, d.x, { cx = d.x })
    part(wall, L.wall2, { nopop = true }) F.planks(wall, L.wall2, 3, false, d.x)
    F.window(d.x - 4, 90, d.x + 3, 96, L.plaster, true)
    line({ { d.x - 11, 96 }, { d.x, 76 } }):each(function(x, y) px(x, y, L.plaster.hi) px(x, y + 1, L.plaster.shade) end)
    line({ { d.x + 11, 96 }, { d.x, 76 } }):each(function(x, y) px(x, y, L.plaster.shade) px(x, y + 1, L.plaster.deep) end)
    px(d.x, 74, L.timber.edge) px(d.x, 75, L.plaster.base)
    F.icicles(d.x - 10, d.x + 10, 100, 3, d.x, .4)
  end
  -- upper floor: falu-red weatherboards with white trim
  part(upper, L.wall2, { nopop = true })
  F.planks(upper, L.wall2, 4, false, 46)
  upper:each(function(x, y)
    if y <= UTOP + 4 then px(x, y, L.wall2.deep) end
    if y >= GTOP - 5 and hash(x, y, 45) < .25 then px(x, y, L.wall2.shade) end
  end)
  local trim = union(rect(UX0, UTOP, UX0 + 2, GTOP - 1), rect(UX1 - 2, UTOP, UX1, GTOP - 1), rect(UX0, GTOP - 4, UX1, GTOP - 2))
  for _, bx in ipairs({ 84, 128 }) do trim:add(rect(bx, UTOP + 3, bx + 1, GTOP - 1)) end
  part(trim, L.plaster, { nopop = true, noshade = true })
  hline(UX0, UX1, GTOP - 4, L.plaster.hi) hline(UX0, UX1, GTOP - 2, L.plaster.shade)
  for x = UX0, UX1, 2 do if hash(x, 3, 47) < .4 then px(x, GTOP - 5, S.hi) end end
  -- jetty beam with driftwood joist ends
  local jet = rect(UX0 - 1, GTOP - 1, UX1 + 1, GTOP + 1)
  part(jet, L.timber, { nopop = true, noshade = true }) hline(UX0 - 1, UX1 + 1, GTOP - 1, L.timber.hi)
  for x = UX0 + 2, UX1 - 2, 6 do F.logEnd(x + 1, GTOP + 1, 1) end
  -- upper windows: white casements with blue heart-cut shutters, snow on the sills
  for _, wx in ipairs({ 62, 106, 148, 176 }) do
    F.window(wx - 3, UTOP + 18, wx + 3, UTOP + 27, L.plaster)
    for y = UTOP + 19, UTOP + 26, 2 do px(wx - 2, y, L.glow.shade) px(wx + 2, y + 1, L.glow.shade) end
    for _, sx in ipairs({ wx - 8, wx + 5 }) do
      local sh = rect(sx, UTOP + 17, sx + 3, UTOP + 28)
      c:rim(sh, L.accent.edge) part(sh, L.accent, { nopop = true })
      vline(sx + 2, UTOP + 18, UTOP + 27, L.accent.shade) hline(sx, sx + 3, UTOP + 22, L.accent.deep)
      px(sx + 1, UTOP + 19, L.accent.deep) px(sx + 2, UTOP + 19, L.accent.deep) px(sx + 1, UTOP + 20, L.accent.deep)
    end
    hline(wx - 5, wx + 5, UTOP + 29, S.hi) hline(wx - 4, wx + 3, UTOP + 28, S.base)
  end
  -- eave icicles over the upper floor
  F.icicles(16, 198, UTOP + 2, 8, 94, .5)
  -- ground floor: herringbone turf on a granite plinth
  part(ground, TURF)
  turf(ground, GTOP + 2, 70)
  ground:each(function(x, y) if y <= GTOP + 3 then px(x, y, TURF.edge) elseif y <= GTOP + 5 and hash(x, y, 71) < .5 then px(x, y, TURF.deep) end end)
  local plinth = rect(X0, YB - 6, X1, YB)
  part(plinth, L.stone, { nopop = true }) F.rubble(plinth, L.stone, YB - 6, 3, 35)
  -- driftwood corner posts
  for _, cx in ipairs({ X0, X1 - 2 }) do local p = rect(cx, GTOP + 2, cx + 2, YB - 7) part(p, L.timber, { nopop = true, noshade = true }) end
  -- porch with a slate hood over the door
  F.door(99, 154, 115, YB - 1, L.accent, true)
  fill(rect(98, YB, 116, YB), L.stone.hi)
  local hood = poly{ { 92, 152 }, { 107, 143 }, { 122, 152 } }:add(rect(92, 151, 122, 153))
  rimOf(hood, L.roof2) part(hood, L.roof2, { nopop = true }) F.courses(hood, 143, 3, 4, L.roof2)
  F.snowCap(hood, 2, 95, { cx = 107 })
  F.icicles(92, 122, 154, 3, 96, .5)
  for _, px0 in ipairs({ 94, 119 }) do local p = rect(px0, 155, px0 + 1, YB) part(p, L.timber, { nopop = true, noshade = true }) end
  -- reindeer antlers over the door
  local ant = HP.mask()
  for _, a in ipairs({ { { 105, 150 }, { 101, 147 }, { 98, 141 }, { 99, 137 } }, { { 109, 150 }, { 113, 147 }, { 116, 141 }, { 115, 137 } },
    { { 100, 144 }, { 96, 143 } }, { { 114, 144 }, { 118, 143 } }, { { 102, 148 }, { 101, 144 } }, { { 112, 148 }, { 113, 144 } } }) do ant:add(line(a, 1)) end
  c:rim(ant, L.timber.edge) fill(ant, L.board.hi) ant:each(function(x, y) if hash(x, y, 97) < .3 then px(x, y, L.board.base) end end)
  fill(rect(105, 149, 109, 151), L.board.shade)
  -- bay windows: white-framed, many panes, warm glow, a window box of spruce twigs and lingonberries under snow
  local function bay(x0, x1, y0, y1)
    local m = rect(x0, y0, x1, y1)
    fill(m:grow(1), L.timber.edge)
    fill(m, L.glow.base)
    m:each(function(x, y)
      if (x - x0) % 6 == 0 or (y - y0) % 5 == 0 then px(x, y, L.plaster.base)
      elseif (x - x0) % 6 == 1 and (y - y0) % 5 == 1 then px(x, y, L.glow.hi)
      elseif (x - x0) % 6 == 5 or (y - y0) % 5 == 4 then px(x, y, L.glow.shade) end
    end)
    hline(x0 - 2, x1 + 2, y0 - 2, L.plaster.hi) hline(x0 - 2, x1 + 2, y0 - 3, L.timber.edge)
    hline(x0 - 1, x1 + 1, y0 - 4, S.hi)
    local box = rect(x0 - 2, y1 + 2, x1 + 2, y1 + 5)
    rimOf(box, L.timber) part(box, L.timber, { nopop = true }) F.planks(box, L.timber, 4, true, 2)
    for x = x0 - 1, x1 + 1 do
      local h = hash(x, y1, 12)
      px(x, y1 + 1, L.foliage.shade)
      if h < .25 then px(x, y1, L.apple.base) px(x, y1 - 1, (h < .1) and L.apple.hi or L.foliage.base)
      elseif h < .8 then px(x, y1, L.foliage.base) px(x, y1 - 1, L.foliage.hi) if h < .5 then px(x, y1 - 2, S.hi) end end
    end
    -- warm light spilling onto the snow-dusted box front
    for x = x0, x1, 3 do px(x, y1 + 3, L.glow.deep) end
  end
  bay(40, 76, 155, 168)
  bay(134, 170, 155, 168)
  F.sprite({ "..ss..", ".ssss.", "ssssss", ".sss..", "sssss.", "sssss." }, 140, 160, { s = L.glow.deep }, { rim = false })
  F.sprite({ ".ss.", "ssss", "ssss", ".ss." }, 66, 162, { s = L.glow.deep }, { rim = false }) -- a cat in the left bay
  px(65, 161, L.glow.deep) px(68, 161, L.glow.deep)
  -- a lantern on a bracket by the door
  fill(rect(122, 146, 128, 146), L.iron.shade) vline(127, 147, 148, L.iron.shade)
  local lam = rect(125, 149, 129, 155) rimOf(lam, L.timber) fill(lam, L.glow.base) px(126, 150, L.glow.hi) vline(129, 150, 155, L.glow.shade)
  hline(124, 130, 148, S.hi)
  for _, p in ipairs({ { 124, 157 }, { 130, 157 }, { 123, 152 }, { 131, 152 }, { 127, 158 } }) do px(p[1], p[2], L.glow.deep) end
  F.smoke(57, 40, 7, .5, 2) F.smoke(156, 36, 8, .8, 3)
  -- a gnome leaning out of the upstairs window, beating a striped wool rug, frost flying
  F.gnome(106, 139, { small = true, hat = L.awnA, coat = L.accent, arm = "out" })
  local rug = rect(112, 135, 124, 151)
  c:rim(rug, L.timber.edge) fill(rug, L.awnA.base)
  rug:each(function(x, y)
    local b = ((y - 135) // 2) % 4
    if b == 1 then px(x, y, L.gold.base) elseif b == 3 then px(x, y, L.accent.base) end
    if x == 124 then px(x, y, L.awnA.deep) end if y == 135 then px(x, y, L.awnA.hi) end
  end)
  for x = 112, 124, 2 do px(x, 152, L.gold.shade) end
  for _, p in ipairs({ { 127, 140 }, { 129, 137 }, { 128, 144 }, { 131, 141 }, { 132, 146 }, { 130, 135 } }) do px(p[1], p[2], "#e4e8f2") px(p[1] + 1, p[2], "#d4d8e6") end
  -- a drift banked against the plinth
  for x = X0 - 4, X1 + 4 do
    local h = 2 + floor(F.vnoise(x / 9, 3, 98) * 5)
    if x > 97 and x < 117 then h = 0 end
    for k = 0, h - 1 do local y = YB + 1 - k px(x, y, k == h - 1 and S.hi or (x < 100 and S.base or S.shade)) end
  end
end
inn()

-- a stockfish drying rack (hjell) against the left gable end, under the roof overhang
do
  local X0, X1, Y0, Y1 = 17, 40, 112, 184
  F.shadow(X0, X1 + 2, Y1, 6, 3)
  local posts = rect(X0, Y0, X0 + 1, Y1):add(rect(X1 - 1, Y0, X1, Y1))
  local bars = HP.mask()
  for _, y in ipairs({ 116, 134, 152 }) do bars:add(rect(X0 - 1, y, X1 + 1, y + 1)) end
  rimOf(union(posts, bars), L.timber) part(posts, L.timber, { nopop = true, noshade = true }) part(bars, L.timber, { nopop = true, noshade = true })
  for _, y in ipairs({ 116, 134, 152 }) do hline(X0 - 1, X1 + 1, y - 1, S.hi) end
  local fish = { "T...T", "kTkTk", ".kHk.", "kHBbk", "kHBbk", "kBBbk", "kBBbk", "kBbbk", ".kbk.", "..k.." }
  local row = 0
  for _, y in ipairs({ 118, 136, 154 }) do
    row = row + 1
    for x = X0 + 2, X1 - 6, 6 do
      local fr = hash(x, y, 99) < .35 and DARKDEER or L.deer
      F.sprite(fish, x, y, { k = L.timber.edge, H = fr.hi, B = fr.base, b = fr.shade, T = L.timber.deep }, { rim = false })
    end
  end
  for x = X0, X1 do if hash(x, 3, 36) < .6 then px(x, Y1, S.hi) px(x, Y1 - 1, S.base) end end
  -- a gull eyeing the fish from the rack top
  F.sprite({ "..WW...", ".WWkW..", "WWWWWWo", ".gggW..", "..o...." }, 22, 109, { W = L.fur.hi, k = L.timber.edge, o = L.gold.base, g = L.iron.base })
end

-- the innkeeper in her apron with a steaming mug, on the step
F.depth(3)
local _, ihx, ihy = F.gnome(132, 194, { hat = L.awnA, coat = L.wall2, arm = "out" })
do local mug = rect(ihx, ihy - 5, ihx + 3, ihy) rimOf(mug, L.timber) part(mug, L.glow, { nopop = true }) hline(ihx, ihx + 3, ihy - 5, L.soil.base) px(ihx + 4, ihy - 3, L.glow.shade) steamMug(ihx, ihy) end
-- a slate board by the door: a chalk mug and a bowl of soup
do
  local leg = line({ { 82, 198 }, { 86, 180 } }, 1):add(line({ { 96, 198 }, { 92, 180 } }, 1))
  local bd = rect(80, 178, 98, 192)
  rimOf(union(bd, leg), L.timber) part(leg, L.timber, { nopop = true, noshade = true })
  fill(bd, L.iron.deep) c:edgeIn(bd, L.timber.base) hline(80, 98, 177, S.hi)
  for _, p in ipairs({ { 83, 182 }, { 84, 182 }, { 85, 182 }, { 83, 183 }, { 83, 184 }, { 83, 185 }, { 84, 186 }, { 85, 186 }, { 86, 183 }, { 86, 184 }, { 87, 184 } }) do px(p[1], p[2], L.awnB.base) end
  for x = 90, 95 do px(x, 186, L.awnB.base) end for x = 91, 94 do px(x, 187, L.awnB.shade) end px(90, 185, L.awnB.base) px(95, 185, L.awnB.base)
  px(91, 183, L.awnB.shade) px(93, 182, L.awnB.shade) px(92, 181, L.awnB.shade)
end

---------------------------------------------------------------- the gallows sign post and its tankard board
F.depth(3)
local SX0, SX1, SY0, SY1 = 202, 240, 128, 152
do
  local post = rect(194, 96, 197, 196)
  local arm = rect(194, 96, 246, 99)
  local brace = line({ { 198, 118 }, { 218, 100 } }, 2)
  local foot = rect(189, 192, 202, 198)
  F.shadowM(c:ellipse(206, 199, 14, 2))
  rimOf(union(post, arm, brace, foot), L.timber)
  part(post, L.timber, { nopop = true }) part(arm, L.timber, { nopop = true, noshade = true }) part(brace, L.timber, { nopop = true, noshade = true })
  post:each(function(x, y) if hash(x, y // 3, 37) < .15 then px(x, y, L.timber.shade) end end)
  part(foot, L.stone, { nopop = true }) F.rubble(foot, L.stone, 192, 3, 38) hline(189, 202, 191, S.hi) hline(190, 201, 192, S.base)
  hline(194, 246, 95, S.hi) hline(196, 244, 94, S.base) hline(200, 236, 93, S.hi)
  F.icicles(198, 244, 100, 4, 39, .35)
  -- a carved reindeer-head finial
  F.sprite({ "g.g.", ".gg.", "gGG.", ".GGg", ".Gg." }, 244, 89, { g = L.board.shade, G = L.board.base })
  -- chains
  for y = 100, SY0 - 1 do if y % 2 == 0 then px(SX0 + 3, y, L.iron.shade) px(SX1 - 3, y, L.iron.shade) else px(SX0 + 3, y, L.iron.hi) px(SX1 - 3, y, L.iron.hi) end end
  -- the board: blue frame, cream field, a big foaming tankard
  local board = rect(SX0, SY0, SX1, SY1)
  rimOf(board, L.accent) part(board, L.accent, { nopop = true })
  local field = rect(SX0 + 3, SY0 + 3, SX1 - 3, SY1 - 3)
  fill(field, L.plaster.hi) field:each(function(x, y) if hash(x, y, 6) < .06 then px(x, y, L.plaster.base) end end)
  hline(SX0, SX1, SY0, L.accent.hi) vline(SX0, SY0, SY1, L.accent.hi)
  F.icicles(SX0, SX1, SY1 + 1, 3, 40, .4)
  -- painted snowflakes in the board corners
  for _, p in ipairs({ { SX0 + 6, SY1 - 6 }, { SX0 + 6, SY0 + 7 } }) do
    px(p[1], p[2], L.accent.base) px(p[1] - 1, p[2], L.accent.shade) px(p[1] + 1, p[2], L.accent.shade) px(p[1], p[2] - 1, L.accent.shade) px(p[1], p[2] + 1, L.accent.shade)
  end
  local tk = rect(213, 136, 227, 149)
  local hnd = c:ellipse(229, 142, 4, 4):cut(c:ellipse(229, 142, 2, 2)):cut(rect(222, 136, 227, 149))
  local foam = c:ellipse(220, 135, 9, 3):add(c:ellipse(216, 133, 3, 2)):add(c:ellipse(223, 132, 3, 2))
  c:rim(union(tk, hnd, foam), L.timber.edge)
  part(tk, L.glow) part(hnd, L.glow, { nopop = true })
  for x = 215, 225, 4 do vline(x, 139, 148, L.glow.shade) end
  hline(213, 227, 138, L.timber.base) hline(213, 227, 147, L.timber.base)
  part(foam, L.awnB, { nopop = true }) px(214, 132, L.awnB.hi) px(215, 131, L.awnB.hi) px(222, 131, L.awnB.hi)
  px(211, 137, L.awnB.base) px(210, 139, L.awnB.base)
end
-- QUIRK: an arctic fox in a red gnome hat asleep on top of the board, its brush hanging down over the tankard
do
  local by = SY0 - 1
  local body = c:ellipse(226, by - 6, 13, 6):clip(rect(200, by - 14, 245, by))
  local head = c:ellipse(208, by - 6, 7, 5):clip(rect(196, by - 14, 220, by))
  local snout = poly{ { 202, by - 6 }, { 196, by - 3 }, { 197, by - 1 }, { 204, by - 2 } }
  local hat = poly{ { 201, by - 9 }, { 215, by - 9 }, { 213, by - 15 }, { 208, by - 20 }, { 203, by - 21 }, { 205, by - 17 }, { 203, by - 13 } }
  local tail = c:ellipse(240, by + 4, 4, 8):add(c:ellipse(237, by + 12, 4, 4)):add(c:ellipse(239, by - 2, 4, 3))
  local paws = c:ellipse(212, by - 1, 5, 1)
  local fox = union(body, head, snout, hat, tail, paws)
  c:rim(fox, L.timber.edge)
  local Fu = L.fur
  part(union(body, tail), Fu, { nopop = true })
  body:each(function(x, y)
    if y >= by - 2 then px(x, y, Fu.shade) end
    if y <= by - 9 and hash(x, y, 3) < .5 then px(x, y, Fu.hi) end
    if x > 232 and y > by - 6 then px(x, y, Fu.deep) end
    if (x + y) % 6 == 0 and y > by - 8 and y < by - 2 then px(x, y, Fu.shade) end
  end)
  tail:each(function(x, y) if x > 240 or y > by + 12 then px(x, y, Fu.shade) end if hash(x, y, 4) < .2 then px(x, y, Fu.deep) end if x < 238 and y < by + 4 then px(x, y, Fu.hi) end end)
  part(head, Fu, { nopop = true }) part(snout, Fu, { nopop = true })
  -- face: closed eyes, dark nose, cheek ruff
  px(203, by - 6, L.timber.edge) px(204, by - 5, L.timber.edge) px(205, by - 6, L.timber.edge)
  px(210, by - 6, L.timber.edge) px(211, by - 5, L.timber.edge) px(212, by - 6, L.timber.edge)
  fill(rect(196, by - 3, 197, by - 2), L.timber.edge) px(196, by - 3, L.iron.base)
  hline(199, 203, by - 1, Fu.shade)
  fill(paws, Fu.hi) px(209, by - 1, Fu.deep) px(213, by - 1, Fu.deep)
  -- the red gnome hat
  part(hat, L.awnA, { nopop = true })
  hat:each(function(x, y) if x < 207 and y > by - 16 then px(x, y, L.awnA.hi) end end)
  hline(201, 215, by - 9, L.awnA.deep) hline(202, 214, by - 10, L.awnA.shade)
  -- one ear poking out of the hat, dark-tipped
  local ear = poly{ { 211, by - 10 }, { 215, by - 15 }, { 215, by - 10 } }
  c:rim(ear, L.timber.edge) fill(ear, Fu.base) px(214, by - 13, Fu.deep) px(214, by - 14, L.timber.deep)
  local function zed(x, y, s)
    for i = 0, s do px(x + i, y, L.accent.shade) px(x + i, y + s, L.accent.shade) px(x + s - i, y + i, L.accent.shade) end
  end
  zed(216, by - 26, 3) zed(222, by - 34, 4) zed(230, by - 43, 5)
end

---------------------------------------------------------------- beer garden (right): snowy spruces, festoons, table
F.depth(3)
do
  F.shadowM(c:ellipse(434, 194, 28, 3))
  F.conifer(462, 190, 78, L.foliage2, 51)
  F.conifer(428, 196, 104, L.foliage, 52, { w = 30 })
end
local function festoon(x0, y0, x1, y1, sag, step, startI)
  local function ly(x) local t = (x - x0) / (x1 - x0) return floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + .5) end
  for x = x0, x1 do px(x, ly(x), L.timber.deep) end
  local cols = { L.awnA, L.glow, L.accent, L.glow, L.gold }
  local i = startI or 0
  for x = x0 + 8, x1 - 6, step do
    i = i + 1
    local y = ly(x) + 1
    local r = cols[i % #cols + 1]
    local m = c:rrect(x - 2, y + 1, x + 2, y + 6, 1)
    c:rim(m, L.timber.edge) fill(m, r.base) px(x - 1, y + 2, r.hi) vline(x + 2, y + 2, y + 5, r.shade) px(x, y, L.timber.deep)
    px(x - 1, y + 1, S.hi) px(x, y + 1, S.hi)
    px(x, y + 7, r.deep)
  end
end
do
  local pole = rect(288, 116, 289, 196)
  rimOf(pole, L.timber) part(pole, L.timber, { nopop = true, noshade = true })
  F.sprite({ ".g.", "ggg" }, 287, 113, { g = L.foliage2.base })
  px(288, 112, S.hi)
  festoon(289, 117, 412, 128, 3, 12, 0)
  festoon(246, 100, 288, 117, 4, 11, 2)
end
-- barrel stack against the pole, snow on the tops
do
  local b1 = F.barrel(300, 206, L.timber, 12) local b2 = F.barrel(312, 207, L.board, 12) local b3 = F.barrel(306, 194, L.timber, 11)
  F.snowCap(b3, 2, 41) F.snowCap(b1, 1, 42) F.snowCap(b2, 1, 43)
end
local function mugAt(x, y, steam)
  local m = rect(x, y - 5, x + 3, y)
  c:rim(m, L.timber.edge) part(m, L.glow, { nopop = true }) hline(x, x + 3, y - 5, L.awnB.hi) hline(x - 1, x + 4, y - 6, L.awnB.base) px(x + 4, y - 3, L.glow.shade)
  if steam then steamMug(x, y - 1) end
end
do
  local g1 = { 338, 210, L.awnA, L.accent, "up" }
  local g2 = { 366, 209, L.lav, L.wall2, "up" }
  local g3 = { 394, 210, L.gold, L.foliage, "out" }
  for i, g in ipairs({ g1, g2, g3 }) do
    local _, hx, hy = F.gnome(g[1], g[2], { hat = g[3], coat = g[4], arm = g[5], flip = (i == 3), noShadow = true, hatBand = L.fur.base })
    mugAt(hx - 1, hy)
  end
  for _, p in ipairs({ { 356, 186 }, { 352, 184 }, { 358, 182 } }) do px(p[1], p[2], L.glow.hi) end
  local top = rect(322, 209, 414, 213)
  local legs = rect(328, 214, 330, 228):add(rect(406, 214, 408, 228)):add(line({ { 329, 222 }, { 407, 222 } }))
  local bench = rect(318, 224, 418, 226):add(rect(322, 227, 323, 231)):add(rect(413, 227, 414, 231))
  F.shadow(324, 414, 231, 6, 3)
  rimOf(union(top, legs, bench), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true })
  part(bench, L.timber, { nopop = true }) F.planks(bench, L.timber, 7, false, 5)
  hline(318, 330, 223, S.hi) hline(406, 418, 223, S.hi)
  part(top, L.board) F.planks(top, L.board, 9, false, 7) hline(322, 414, 209, L.board.hi) hline(322, 414, 213, L.timber.base)
  mugAt(348, 208, true) mugAt(380, 208, true)
  local loaf = c:ellipse(362, 206, 5, 3) rimOf(loaf, L.soil) part(loaf, L.produce) px(360, 205, L.produce.hi) hline(359, 365, 206, L.produce.shade) for k = 0, 2 do px(359 + k * 3, 204, L.produce.deep) end
  local ch = poly{ { 389, 208 }, { 400, 208 }, { 400, 202 } } rimOf(ch, L.gold) part(ch, L.gold, { nopop = true }) px(397, 206, L.gold.shade) px(398, 204, L.gold.shade)
  -- a bowl of cloudberries
  local plate = c:ellipse(334, 208, 6, 1) fill(plate, L.accent.base) fill(c:ellipse(334, 206, 4, 2), L.produce.base)
  for _, p in ipairs({ { 331, 205 }, { 333, 204 }, { 335, 205 }, { 337, 205 }, { 334, 206 } }) do px(p[1], p[2], L.produce.hi) end
  px(332, 206, L.produce.shade) px(336, 206, L.produce.shade)
  -- a candle in a jar
  fill(rect(371, 204, 373, 208), L.awnB.hi) px(372, 203, L.glow.hi) px(372, 202, L.glow.base)
end
-- the waiter crossing the road with a tray of steaming mugs
F.depth(3)
do
  local _, hx, hy = F.gnome(268, 232, { hat = L.accent, coat = L.awnA, arm = "up", flip = true, hatBand = L.fur.base })
  local tray = rect(hx - 9, hy - 1, hx + 5, hy)
  rimOf(tray, L.iron) part(tray, L.iron, { nopop = true, noshade = true })
  mugAt(hx - 8, hy - 2) mugAt(hx - 3, hy - 2, true) mugAt(hx + 2, hy - 2)
  F.tracks({ { 280, 236 }, { 292, 228 } }, "boot", 5)
end

---------------------------------------------------------------- foreground left: hitching rail, log trough, two tethered reindeer
F.depth(3)
local function reindeer(x, yb, s, o)
  o = o or {}
  local R = o.coat or L.deer
  local function P(dx, dy) return { x + dx * s, yb + dy } end
  local body = c:ellipse(x, yb - 15, 12, 6)
  local hd = o.headDown and 8 or 0
  local neck = poly{ P(6, -18), P(12, -26 + hd), P(17, -25 + hd), P(13, -14) }
  local head = c:ellipse(x + 16 * s, yb - 26 + hd, 4, 3):add(poly{ P(16, -28 + hd), P(23, -25 + hd), P(23, -22 + hd), P(17, -23 + hd) })
  local legs = HP.mask()
  for _, lx in ipairs({ -9, -5, 6, 10 }) do legs:add(line({ P(lx, -11), P(lx + (lx > 0 and 1 or -1), 0) }, 2)) end
  local tail = rect(math.min(x - 13 * s, x - 12 * s), yb - 19, math.max(x - 13 * s, x - 12 * s), yb - 16)
  local antl = HP.mask()
  for _, a in ipairs({ { P(14, -29), P(11, -35), P(9, -42), P(12, -47) }, { P(17, -29), P(19, -36), P(18, -43), P(22, -47) },
    { P(11, -35), P(7, -37) }, { P(10, -40), P(5, -42) }, { P(19, -36), P(23, -39) }, { P(18, -41), P(23, -44) }, { P(15, -30), P(18, -33) } }) do
    local pts = {}
    for i, p in ipairs(a) do pts[i] = { p[1], p[2] + hd } end
    antl:add(line(pts, 1))
  end
  local m = union(body, neck, head, legs, tail, antl)
  F.shadowM(c:ellipse(x - 4 * s, yb + 1, 15, 2))
  rimOf(m, R)
  part(legs, R, { nopop = true, noshade = true })
  legs:each(function(xx, yy) if yy > yb - 3 then px(xx, yy, R.edge) elseif yy > yb - 6 then px(xx, yy, L.fur.base) end end)
  part(body, R)
  body:each(function(xx, yy) if yy > yb - 12 then px(xx, yy, L.fur.shade) end if hash(xx, yy, 92 + x) < .08 then px(xx, yy, R.shade) end end)
  part(neck, L.fur, { nopop = true })
  neck:each(function(xx, yy) if hash(xx, yy, 92) < .25 then px(xx, yy, L.fur.shade) end end)
  part(head, R, { nopop = true })
  local e = P(17, -27 + hd) px(e[1], e[2], L.timber.edge)
  local n = P(23, -24 + hd) px(n[1], n[2], L.timber.edge)
  local ea = P(13, -28 + hd) px(ea[1], ea[2], R.deep)
  part(antl, L.board, { nopop = true, noshade = true })
  antl:each(function(xx, yy) if hash(xx, yy, 93) < .35 then px(xx, yy, L.board.shade) end end)
  part(tail, L.fur, { nopop = true, noshade = true })
  -- Sami-style collar: blue band, red and gold stripes, a brass bell
  local collar = line({ P(9, -20), P(13, -15) }, 2)
  fill(collar, L.accent.base)
  collar:each(function(xx, yy) if (xx + yy) % 3 == 0 then px(xx, yy, L.awnA.base) elseif (xx + yy) % 3 == 1 then px(xx, yy, L.gold.base) end end)
  local bl = P(13, -14) fill(rect(math.min(bl[1], bl[1] + s), bl[2], math.max(bl[1], bl[1] + s), bl[2] + 1), L.gold.base) px(bl[1], bl[2], L.gold.hi)
  if o.blanket then
    local bk = body:copy():clip(rect(x - 7, yb - 22, x + 5, yb - 13))
    fill(bk, L.awnA.base)
    bk:each(function(xx, yy) if yy == yb - 13 or not bk:has(xx, yy - 1) then px(xx, yy, L.gold.base) elseif not bk:has(xx - 1, yy) or not bk:has(xx + 1, yy) then px(xx, yy, L.accent.base) end end)
    hline(x - 6, x + 4, yb - 20, L.awnA.hi)
  end
  return P(23, -23 + hd)
end
do
  local rail = rect(22, 212, 104, 214):add(rect(26, 212, 28, 228)):add(rect(98, 212, 100, 228))
  rimOf(rail, L.timber) part(rail, L.timber, { nopop = true, noshade = true }) hline(22, 104, 212, L.timber.hi)
  hline(22, 104, 211, S.hi) hline(24, 102, 210, S.base)
  F.logEnd(22, 213, 1) F.logEnd(104, 213, 1)
  -- a hollowed driftwood log trough, iced over with a broken drinking hole
  F.shadow(64, 100, 232, 6, 3)
  local chocks = rect(68, 228, 73, 232):add(rect(90, 228, 95, 232))
  rimOf(chocks, L.timber) part(chocks, L.timber, { nopop = true })
  local t = rect(64, 219, 100, 229)
  rimOf(t, L.timber) part(t, L.timber)
  F.logs(t, L.timber, 219, 4)
  fill(rect(66, 219, 98, 220), L.ice.base) hline(66, 98, 219, L.ice.hi)
  fill(rect(84, 219, 90, 220), L.water.shade) px(85, 219, L.water.base) px(91, 219, L.ice.shade)
  F.icicles(65, 99, 230, 3, 44, .35)
  F.logEnd(100, 224, 4)
end
-- reindeer A: head lowered to the trough's drinking hole, saddle blanket
reindeer(54, 236, 1, { headDown = true, blanket = true })
-- reindeer B: darker, facing left, chewing the tether tied to the rail post
do
  local mp = reindeer(124, 232, -1, { coat = DARKDEER }) local mx, my = mp[1], mp[2]
  for x = 100, mx do px(x, 217 + floor((x - 100) * (my - 217) / math.max(1, mx - 100)), L.soil.base) end
  fill(rect(98, 216, 100, 218), L.soil.base)
  F.steam(mx - 4, my - 2, 3, -.5, 13)
end
F.tracks({ { 30, 244 }, { 60, 246 }, { 96, 240 } }, "deer", 6)

do -- driftwood stack under a little slate lean-to by the lodge wall
  local stackM = rect(146, 196, 184, 212)
  F.shadow(146, 186, 213, 5, 3)
  rimOf(stackM, L.timber) fill(stackM, L.timber.deep)
  for row = 0, 2 do for k = 0, 6 do
    local cx, cy = 149 + k * 6 + (row % 2) * 3, 199 + row * 5
    if cx <= 182 then
      local tr = (hash(k, row, 8) < .25) and L.birch or L.board
      local lg = c:ellipse(cx, cy, 2.5, 2.5)
      fill(lg, tr.hi) px(cx, cy, tr.shade) px(cx + 1, cy, tr.base)
      lg:edge():each(function(x, y) px(x, y, (x > cx or y > cy) and L.timber.base or tr.base) end)
    end
  end end
  local lean = poly{ { 142, 196 }, { 188, 192 }, { 188, 195 }, { 142, 199 } }
  rimOf(lean, L.roof2) part(lean, L.roof2, { nopop = true })
  F.snowCap(lean, 2, 45, { cx = 160 })
  F.icicles(143, 188, 199, 3, 46, .4)
end
-- a chopping stump by the road with the axe bitten in, split billets and chips on the snow
do
  local x, yb, w = 194, 230, 6
  F.shadowM(c:ellipse(199, 231, 10, 1))
  local body = rect(x - w, yb - 7, x + w, yb)
  local top = c:ellipse(x, yb - 7, w, 2)
  rimOf(union(body, top), L.timber) part(body, L.timber, { nopop = true })
  body:each(function(xx, yy) if (xx - x) % 3 == 0 and hash(xx, yy // 2, 44) < .6 then px(xx, yy, L.timber.shade) end end)
  fill(top, L.board.base) px(x, yb - 7, L.board.shade) hline(x - 3, x - 1, yb - 8, L.board.hi)
  hline(x + 2, x + 5, yb - 8, S.hi)
  line({ { x + 1, yb - 8 }, { x + 7, yb - 18 } }):each(function(xx, yy) px(xx, yy, L.board.base) px(xx + 1, yy, L.board.shade) end)
  fill(rect(x - 2, yb - 10, x + 2, yb - 8), L.iron.base) px(x - 2, yb - 10, L.iron.hi) px(x + 2, yb - 8, L.iron.deep)
  for _, s in ipairs({ { 178, 234 }, { 184, 238 }, { 200, 238 } }) do
    local m = poly{ { s[1], s[2] }, { s[1] + 5, s[2] - 2 }, { s[1] + 6, s[2] }, { s[1] + 1, s[2] + 2 } }
    rimOf(m, L.timber) fill(m, L.board.base) px(s[1] + 1, s[2], L.board.hi) px(s[1] + 5, s[2] - 1, L.timber.base)
  end
  for i = 0, 6 do px(184 + floor(hash(i, 1, 46) * 22), 229 + floor(hash(i, 2, 46) * 6), L.board.shade) end
end
-- a gnome rolling a barrel through the snow toward the lodge
do
  F.gnome(176, 252, { hat = L.gold, coat = L.accent, arm = "out", flip = true, hatBand = L.fur.base })
  local b = c:rrect(152, 240, 166, 254, 4)
  F.shadowM(c:ellipse(160, 255, 9, 1))
  rimOf(b, L.timber) part(b, L.timber)
  vline(155, 241, 253, L.iron.shade) vline(163, 241, 253, L.iron.shade) hline(153, 165, 246, L.timber.hi)
  F.snowCap(b, 1, 47)
  -- the furrow it ploughed and snow puffs
  for x = 166, 186 do px(x, 256, S.shade) if x % 3 == 0 then px(x, 255, S.hi) end end
  for _, p in ipairs({ { 146, 250 }, { 144, 246 }, { 143, 253 }, { 148, 244 } }) do px(p[1], p[2], S.hi) px(p[1] + 1, p[2], S.base) end
end
-- crate of green bottles and burlap sacks, bottom left
do
  F.crate(40, 265, 26, 11)
  for k = 0, 5 do
    local bx = 43 + k * 4
    local b = rect(bx, 247, bx + 2, 253):add(rect(bx + 1, 244, bx + 1, 246))
    c:rim(b, L.timber.edge) fill(b, L.foliage.base) px(bx, 248, L.foliage.hi) px(bx + 1, 244, L.produce.base)
  end
  F.snowCap(F.sack(86, 262, SACK, 7), 2, 48)
  F.sack(100, 264, SACK, 6)
  F.snowCap(F.rock(124, 262, 8, 6), 3, 43)
  F.fern(16, 240, 7) F.fern(24, 252, 8) F.fern(114, 252, 6) F.fern(70, 264, 6)
  berries(134, 256) berries(138, 258) berries(30, 262, L.lav) berries(33, 263, L.lav)
  F.willow(14, 226, 6, 7, 49)
end
-- a half-barrel tub with a little spruce dressed with red baubles by the road
do
  local tub = c:rrect(210, 226, 228, 240, 3)
  F.shadowM(c:ellipse(223, 241, 11, 1))
  F.conifer(219, 228, 26, L.foliage2, 50)
  rimOf(tub, L.timber) part(tub, L.timber) hline(210, 228, 230, L.iron.shade) hline(210, 228, 237, L.iron.shade)
  hline(211, 227, 226, S.hi)
  for _, p in ipairs({ { 217, 222 }, { 222, 218 }, { 215, 214 }, { 220, 210 }, { 223, 224 } }) do px(p[1], p[2], L.apple.base) px(p[1], p[2] - 1, L.apple.hi) end
  px(219, 201, L.gold.hi) px(218, 202, L.gold.base) px(220, 202, L.gold.base)
end

-- an iron fire basket by the table: flames, sparks, a warm pool on the snow
F.depth(3)
do
  local x, yb = 302, 238
  local pool = c:ellipse(x, yb + 1, 14, 3)
  pool:each(function(xx, yy) px(xx, yy, hash(xx, yy, 101) < .5 and "#f4e2cc" or "#ecd8c8") end)
  local legs = line({ { x - 6, yb }, { x - 3, yb - 6 } }):add(line({ { x + 6, yb }, { x + 3, yb - 6 } }))
  local bowl = c:ellipse(x, yb - 8, 7, 3):clip(rect(x - 7, yb - 8, x + 7, yb - 5))
  local fl = poly{ { x - 6, yb - 8 }, { x - 4, yb - 15 }, { x - 2, yb - 12 }, { x, yb - 20 }, { x + 2, yb - 13 }, { x + 4, yb - 16 }, { x + 6, yb - 8 } }
  rimOf(union(legs, bowl), L.iron) part(legs, L.iron, { nopop = true, noshade = true }) part(bowl, L.iron, { nopop = true })
  fill(fl, L.produce.base)
  fl:each(function(xx, yy) if yy > yb - 11 and math.abs(xx - x) < 4 then px(xx, yy, L.glow.hi) elseif yy > yb - 14 and math.abs(xx - x) < 3 then px(xx, yy, L.glow.base) elseif hash(xx, yy, 102) < .3 then px(xx, yy, L.produce.shade) end end)
  for _, p in ipairs({ { x - 3, yb - 22 }, { x + 2, yb - 25 }, { x + 4, yb - 21 }, { x - 1, yb - 28 } }) do px(p[1], p[2], L.glow.hi) end
  F.smoke(x + 1, yb - 30, 3, .5, 1)
end
-- snow buntings pecking at crumbs dropped from the table
local function bunting(x, yb, flip)
  F.sprite(flip and { "..cc...", ".kWWc..", ".bWWWWW", "..WWKWK", "...WWK.", "..o.o.." } or { "...cc..", "..cWWk.", "WWWWWb.", "KWKWW..", ".KWW...", "..o.o.." },
    x - 3, yb - 5, { W = L.fur.hi, c = L.board.hi, k = L.timber.edge, b = L.gold.shade, K = L.timber.edge, o = L.timber.deep })
end
bunting(320, 252) bunting(344, 258, true) bunting(360, 246, true) bunting(332, 262)
for _, g in ipairs({ { 326, 254 }, { 332, 256 }, { 336, 251 }, { 350, 255 }, { 329, 250 } }) do px(g[1], g[2], L.produce.hi) end
F.tracks({ { 316, 258 }, { 340, 262 }, { 360, 252 } }, "bird", 4)
-- a pair of skis and poles leaning on the barrels
do
  local sk = line({ { 284, 224 }, { 291, 190 }, { 293, 188 } }, 2):add(line({ { 288, 225 }, { 295, 191 }, { 297, 189 } }, 2))
  rimOf(sk, L.timber) fill(sk, L.wall2.base)
  sk:each(function(x, y) if hash(x, y, 103) < .3 then px(x, y, L.wall2.hi) end end)
  line({ { 280, 224 }, { 286, 192 } }):each(function(x, y) px(x, y, L.iron.shade) end)
  fill(c:ellipse(281, 219, 2, 1), L.timber.base)
  hline(283, 290, 226, S.shade)
end
-- willow scrub and young spruces on the right (clear of the compass corner)
F.conifer(448, 226, 26, L.foliage, 53)
F.willow(304, 264, 7, 7, 54) F.willow(290, 250, 5, 6, 55) F.willow(374, 264, 6, 6, 56)
F.willow(466, 216, 6, 7, 57) F.willow(432, 224, 5, 6, 58)
F.fern(284, 240, 5) F.fern(470, 228, 5)
F.drift(456, 206, 16, 4, 59)
berries(300, 246) berries(368, 254, L.lav)
-- a husky asleep under the table between the legs
F.sprite({
  "....bb..........",
  "...bBBb.....bb..",
  "..bBkBBBBBBBBBb.",
  "WbBBBBBBBBBBBBBb",
  ".WWWBBWWBBBBWWBt",
  "...WWW..WWWWW.tt",
}, 364, 217, { b = L.iron.base, B = L.iron.shade, W = L.fur.base, k = L.timber.edge, t = L.iron.base })

F.depth(0)
F.birds({ { 330, 52, 2 }, { 342, 46, 1 }, { 120, 46, 2 }, { 380, 78, 2 } })
F.finish()
