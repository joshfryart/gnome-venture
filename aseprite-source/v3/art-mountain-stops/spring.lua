-- spring.lua : "Spring" stop look, MOUNTAIN (mountain_granite), 480x270 gate view.
-- Same composition as the Maplewold spring (art-2701-batch4/stops/opus3/spring.lua), re-cast for the high mountains:
-- Behind: a hanging glacier on the right-hand crag, its meltwater threading down the rock toward the spring, and
-- snowmelt rills streaking the left crags. Right hero: a jointed granite rock face with lingering snow patches, wet
-- melt streaks, turf ledges with dwarf pines and a goat on the top; a dressed-granite face with a carved stone gnome
-- head spouts glacier-melt into a wide granite basin, a second trickle runs from a crack into a gnome's pail. The
-- basin overflows into a milky snowmelt brook that winds down-left under a granite bridge on the road and spreads
-- into a braided gravel outwash bottom-left (shingle bars, channels, a plank footbridge, a washer gnome).
-- Left: a granite well-head with a larch-shingle roof and a gnome winding the bucket, a stone-and-larch chalet with
-- washing, larches; mid-left a hollowed larch-log water trough fed by a carved post, with goats drinking.
-- A gnome carries two pails on a yoke down the road; a jug stall by the spring sign; a water cart in front.
-- Road's end: a granite hamlet and a whitewashed chapel with a slate spire.
-- Quirk: a big green frog in a red gnome hat sits on a stone in the basin, eyes shut, taking a shower under the spout.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-mountain-stops/"
local F = dofile(DIR .. "_frame.lua")
  .build{ name = "spring", out = DIR, farTrees = { 22, 60, 104, 150, 330, 372, 452 }, treeLineGap = { 188, 290 },
    clouds = { { 130, 42, 40 }, { 280, 30, 46 }, { 400, 58, 34 }, { 30, 82, 24 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local mix, rp = F.mix, F.rp
local Wt = L.water
local GL = "#eef6f2" -- cold water glint
local turf = L.mossGround
local rock = rp("#e6e4de #c2c0bc #9c9ca0 #74767e #4c4e5a") -- the rock face: jointed grey granite
local sand = rp("#eeece2 #d2d0c6 #adaca4 #828580 #565a62") -- dressed pale granite ashlar
local ice = rp("#eef4f4 #cfe4ea #9cc6d6 #6e9cb8 #4c6e90") -- glacier ice
local feld = "#ecdcd2" -- pink feldspar fleck

---------------------------------------------------------------- background: hanging glacier + snowmelt rills (behind the tree line)
F.depth(0)
do
  -- the glacier hangs in the left flank of the right-hand crag (peak at 420,66) and spills toward the rock face
  local g = poly{ { 416, 61 }, { 426, 67 }, { 425, 76 }, { 421, 82 }, { 418, 88 }, { 414, 94 }, { 400, 94 }, { 397, 88 }, { 392, 82 }, { 396, 74 }, { 405, 67 } }
  -- dark lateral moraines either side
  g:grow(2):cut(g):each(function(x, y) if y > 74 then px(x, y, hash(x, y, 4) < .5 and L.peak.deep or L.peak.edge) end end)
  g:edge():each(function(x, y) if y > 80 then px(x, y, mix(ice.edge, L.sky[4], .2)) end end)
  local gi = g:copy():cut(g:edge())
  gi:each(function(x, y)
    local h = ice.base
    if x < 404 - (y - 80) * .2 then h = ice.hi end
    if x > 418 - (y - 80) * .5 then h = ice.shade end
    -- ogives: crevasse arcs bowed downhill, a lit lip above each
    local a = floor((y - 68) + ((x - 410) / 6) ^ 2 * .8)
    if a % 6 == 0 and g:has(x, y - 1) and g:has(x, y + 1) then h = ice.shade elseif a % 6 == 5 and y > 74 then h = ice.hi end
    -- the ice fall: blue seracs at the snout
    if y > 85 then h = (x % 3 == 0) and ice.deep or ((x % 3 == 1) and ice.hi or ice.shade) end
    px(x, y, mix(h, L.sky[4], .15))
  end)
  -- the blue snout and meltwater threads running down to the rock face
  hline(398, 414, 95, ice.deep) hline(400, 412, 94, ice.shade)
  for _, t in ipairs({ { 402, 96 }, { 410, 96 } }) do
    for y = t[2], 110 do px(t[1] + floor((y - t[2]) * .25), y, (y % 3 == 0) and L.snow.hi or ice.shade) end
  end
  -- snowmelt rills streaking down the left crags (thin, broken, catching the light)
  for _, r in ipairs({ { 132, 74, 30 }, { 160, 70, 26 }, { 58, 80, 22 }, { 300, 76, 20 } }) do
    local x = r[1]
    for k = 0, r[3] do
      local y = r[2] + k
      if hash(k // 3, r[1], 5) < .8 then px(x, y, (k % 4 == 0) and L.snow.hi or ice.base) px(x + 1, y, ice.shade) end
      if k % 6 == 5 then x = x + ((hash(k, r[1], 6) < .5) and 1 or -1) end
    end
  end
end

---------------------------------------------------------------- back row: a granite hamlet and a whitewashed chapel at the road's end
F.depth(1)
do
  local top, _, wall = F.building{ x0 = 196, x1 = 228, yb = 126, wh = 13, rh = 11, wall = L.timber, roof = L.roof, noFrame = true, noAttic = true, chimney = true, shingle = true }
  F.planks(wall, L.timber, 3, true, 41)
  local base = rect(196, 120, 228, 126) part(base, L.plaster, { nopop = true }) F.courses(base, 120, 3, 6, L.plaster)
  F.window(204, 113, 208, 117, L.timber)
  F.snow(rect(194, top - 11, 230, top), .2, 42)
end
F.smoke(219, 97, 4, .5, 2)
do -- a whitewashed chapel with a slate spire right of the road
  local wall = rect(254, 112, 278, 126)
  local roof = poly{ { 251, 113 }, { 266, 102 }, { 281, 113 } }
  local tower = rect(256, 96, 263, 112)
  local spire = poly{ { 255, 97 }, { 259, 80 }, { 264, 97 } }
  rimOf(union(wall, roof, tower, spire), L.stone)
  part(wall, L.plaster) F.courses(wall, 112, 3, 7, L.plaster)
  part(tower, L.plaster, { nopop = true })
  part(roof, L.roof, { nopop = true }) F.courses(roof, 102, 2, 4, L.roof)
  part(spire, L.roof, { nopop = true }) F.courses(spire, 80, 2, 3, L.roof)
  F.snow(roof, .35, 43)
  F.lichen(roof, .15, 44)
  fill(c:rrect(258, 99, 261, 104, 1), L.glow.shade) px(259, 79, L.gold.base) px(259, 78, L.gold.hi)
  F.window(270, 116, 273, 120, L.timber, true)
  -- the chapel clock: a dark dial with a gold hand
  px(259, 107, L.timber.deep) px(260, 107, L.timber.deep) px(259, 108, L.timber.deep) px(260, 108, L.gold.hi)
end
F.tree(300, 128, 28, 3)
F.tree(186, 128, 30, 2)
F.fenceP(120, 132, 190, 127, 6)
F.depth(2)
F.tree(184, 150, 36, 0)
F.tree(8, 156, 34, 1)
do -- mid-left: scree, a split granite block, juniper and straw between the chalet and the well
  F.boulder(32, 168, 6, 5, 31) F.boulder(176, 168, 4, 4, 32)
  F.juniper(40, 160, 9, 4, 33) F.juniper(170, 158, 6, 3, 34)
  for i = 1, 14 do
    local x, y = 18 + floor(hash(i, 1, 36) * 200), 142 + floor(hash(i, 2, 36) * 20)
    if not F.roadM:has(x, y) and (x < 104 or x > 168) then F.fern(x, y, 2 + (y - 140) // 9, hash(i, 3, 36) < .4 and L.needle or L.fern) end
  end
  -- far goats and a chamois grazing the mid slopes
  F.goat(92, 122, { k = .4, graze = true, noShadow = true })
  F.goat(312, 136, { k = .4, flip = true, r = L.chamois, noShadow = true })
end

---------------------------------------------------------------- mid left: stone-and-larch chalet, larches, an arolla pine
F.depth(2)
do
  local top, _, wall, roofM = F.building{ x0 = 24, x1 = 70, yb = 136, wh = 20, rh = 16, wall = L.timber, roof = L.roof, chimney = true, noAttic = true, shingle = true, noFrame = true }
  F.planks(wall, L.timber, 3, false, 45)
  local base = rect(24, 128, 70, 136) part(base, L.plaster, { nopop = true }) F.courses(base, 128, 3, 7, L.plaster)
  hline(24, 70, 127, L.timber.edge)
  F.lichen(roofM, .2, 46)
  for _, w in ipairs({ { 34, 113 }, { 47, 106 }, { 60, 113 } }) do
    local ws = c:ellipse(w[1], w[2], 2, 1) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true }) px(w[1] - 1, w[2] - 1, L.stone.hi)
  end
  F.window(30, 118, 35, 123, L.timber) F.door(50, 124, 57, 135, L.timber)
  -- geraniums on the sill
  for x = 29, 36, 2 do px(x, 117, L.apple.base) px(x + 1, 117, L.leaf.shade) end
  -- split firewood stacked under the eave
  local wood = rect(60, 128, 69, 135) rimOf(wood, L.timber) part(wood, L.timber, { nopop = true })
  wood:each(function(x, y) if (x + (y // 2) * 3) % 4 == 0 then px(x, y, L.board.base) end if (y - 128) % 2 == 0 and x % 4 == 1 then px(x, y, L.timber.deep) end end)
end
F.smoke(61, 88, 6, .5, 2)
F.larch(92, 150, 56, 31)
-- washing strung from the chalet gable to the larch (the washer at the outwash has more to do)
F.washing(70, 118, 91, 120, { { "shirt", L.awnA }, { "sock", L.accent }, { "trousers", L.lav } }, 3)
F.larch(160, 140, 44, 34)
F.tree(124, 146, 40, 3)

---------------------------------------------------------------- mid left: a hollowed larch-log water trough fed by a carved post, goats drinking
F.depth(2)
do
  local tr = poly{ { 114, 152 }, { 158, 152 }, { 156, 162 }, { 116, 162 } }
  local post = rect(108, 136, 112, 162)
  local cap = poly{ { 107, 136 }, { 110, 132 }, { 113, 136 } }
  local pipe = rect(112, 141, 120, 142)
  F.shadow(112, 158, 163, 8, 3)
  -- a chamois-brown goat behind the trough, its back showing above the rim
  F.goat(140, 158, { k = .55, r = L.chamois, noShadow = true })
  rimOf(union(tr, post, cap, pipe), L.timber)
  part(tr, L.timber) F.logs(tr, L.timber, 152, 5)
  -- the hollow: water brim-full, lit far lip
  local hollow = rect(117, 153, 155, 155)
  fill(hollow, Wt.base) hline(117, 155, 153, Wt.hi) hline(116, 156, 152, L.timber.hi)
  for x = 120, 154, 7 do px(x, 154, GL) end
  -- iron hoops and a wet dark foot
  for _, hx in ipairs({ 124, 148 }) do vline(hx, 153, 161, L.iron.shade) vline(hx + 1, 153, 161, L.iron.hi) end
  hline(117, 155, 161, L.timber.deep)
  part(post, L.timber, { nopop = true }) part(cap, L.roof2, { nopop = true })
  -- a carved heart in the post and the year notches
  px(109, 146, L.timber.deep) px(111, 146, L.timber.deep) px(110, 147, L.timber.deep)
  for y = 150, 158, 2 do hline(109, 111, y, L.timber.shade) end
  part(pipe, L.board, { nopop = true, noshade = true })
  -- the jet from the pipe into the trough
  for y = 141, 152 do local x = 121 + floor((y - 141) * .25) px(x, y, (y % 3 == 0) and GL or Wt.hi) px(x + 1, y, Wt.base) end
  px(120, 152, Wt.hi) px(126, 151, Wt.hi) px(124, 150, GL)
  -- overflow trickling from the low end
  for y = 156, 166 do px(158 + (y - 156) // 4, y, (y % 2 == 0) and Wt.hi or Wt.base) end
  -- two goats drinking at it, one reared up with its forefeet on the rim
  -- a goat at the low end, head over the water, drinking (with a ripple)
  F.goat(170, 167, { k = .6, flip = true })
  hline(152, 156, 154, GL) px(150, 153, Wt.shade)
  local _, hx, hy = F.gnome(128, 162, { small = true, hat = L.awnA, coat = L.fern, arm = "out", noShadow = true })
end

---------------------------------------------------------------- right hero: the granite rock face
F.depth(2)
F.tree(446, 128, 70, 0)
F.tree(470, 112, 40, 2)
F.tree(352, 114, 38, 3)
F.larch(326, 136, 30, 57)
F.depth(3)
local boulders = {
  { 312, 158, 22, 22, 41 }, { 340, 128, 26, 24, 42 }, { 384, 114, 30, 22, 43 }, { 430, 120, 26, 24, 44 },
  { 452, 160, 20, 30, 45 }, { 300, 196, 16, 16, 46 }, { 436, 196, 26, 18, 47 },
  { 330, 190, 22, 18, 48 }, { 352, 166, 14, 16, 50 }, { 418, 150, 12, 16, 51 },
}
local rockM = HP.mask()
for _, b in ipairs(boulders) do
  local pts = {}
  for i = 0, 13 do
    local a = i / 14 * 2 * pi
    local k = .82 + .2 * hash(i, b[5], 3)
    -- granite weathers blocky: flatten the outline toward a rounded box
    local ca, sa = cos(a), sin(a)
    local sq = 1 / math.max(abs(ca), abs(sa)) ^ .35
    pts[#pts + 1] = { b[1] + ca * b[3] * k * sq, b[2] + sa * b[4] * k * sq }
  end
  b.m = poly(pts)
  rockM:add(b.m)
end
local face = rect(352, 132, 420, 196)
local mass = poly{ { 294, 212 }, { 298, 172 }, { 312, 132 }, { 346, 106 }, { 388, 96 }, { 432, 98 }, { 466, 110 }, { 470, 212 } }
rockM:add(face):add(mass)
F.shadowM(c:ellipse(380, 214, 92, 5))
rimOf(rockM, rock)
mass:each(function(x, y)
  local v = hash(x, y, 77)
  local h = (hash(x // 5, y // 4, 78) < .5) and rock.shade or rock.deep
  if v < .06 then h = rock.base elseif v > .96 then h = rock.edge end
  if hash(x // 3, y // 3, 79) < .08 then h = turf.deep end -- turf in the crevices
  px(x, y, h)
end)
local wet = {} -- melt streaks start under the snow patches
for _, b in ipairs(boulders) do
  local off = hash(b[5], 1, 2) * 2 * pi
  b.m:each(function(x, y)
    local nx, ny = (x - b[1]) / b[3], (y - b[2]) / b[4]
    local r = math.sqrt(nx * nx + ny * ny)
    local a = math.atan(ny, nx)
    local sec = floor(((a + off) % (2 * pi)) / (2 * pi) * 7)
    local ca = sec / 7 * 2 * pi + pi / 7 - off
    local lit
    if r < .38 then lit = .25 - (nx * .6 + ny * .8) * .4
    else lit = -(cos(ca) * .6 + sin(ca) * .8) * math.min(1, r * 1.2) end
    lit = lit + (hash(x // 2, y // 2, b[5]) - .5) * .25
    local h
    if lit > .55 then h = rock.hi elseif lit > .1 then h = rock.base elseif lit > -.4 then h = rock.shade else h = rock.deep end
    if hash(x, y, b[5]) > .97 then h = rock.deep elseif hash(x, y, b[5]) < .03 then h = rock.hi end
    -- granite grain: pink feldspar and dark mica flecks
    if lit > -.4 and hash(x, y, b[5] + 9) < .012 then h = feld end
    if hash(x, y, b[5] + 11) < .008 then h = rock.edge end
    px(x, y, h)
  end)
  c:edgeIn(b.m, rock.edge)
  -- sheeting joints: long near-horizontal cracks that follow the dome, plus one vertical joint, each with a lit lip
  if b[3] >= 22 then -- one exfoliation sheet: a curved joint following the dome, with a lit lip above
    local y0 = floor(b[2] + b[4] * .15)
    local xa, xb = floor(b[1] - b[3] * (.3 + .4 * hash(1, b[5], 85))), floor(b[1] + b[3] * (.2 + .4 * hash(2, b[5], 85)))
    for x = xa, xb do
      local y = y0 - floor(cos((x - b[1]) / b[3] * 1.4) * b[4] * .35) + floor(F.vnoise(x / 5, 0, b[5]) * 2)
      if b.m:has(x, y) and b.m:has(x, y - 1) and b.m:has(x, y + 1) then px(x, y, rock.edge) px(x, y - 1, rock.hi) px(x, y + 1, rock.deep) end
    end
  end
  for k = 1, 2 do
    local x, y = floor(b[1] + (hash(k, b[5], 81) - .5) * b[3]), floor(b[2] - b[4] * .1 + (hash(k, b[5], 82) - .2) * b[4] * .6)
    for t = 0, floor(b[4] * .5) do
      if b.m:has(x, y) and b.m:has(x, y + 1) then px(x, y, rock.edge) if b.m:has(x - 1, y) then px(x - 1, y, rock.hi) end end
      y = y + 1 x = x + ((hash(t, k, b[5]) < .5) and 1 or -1) * ((t % 2) == 0 and 1 or 0)
    end
  end
  F.lichen(b.m, .1, b[5] + 100)
  -- upper boulders keep a snow patch; lower ones a turf cushion with gentians
  if b[2] < 135 then
    b.m:each(function(x, y)
      local nx, ny = (x - b[1]) / b[3], (y - b[2]) / b[4]
      local cap = -.7 + .3 * F.vnoise(x / 6, 1, b[5]) + .55 * F.vnoise(x / 15, 7, b[5]) * F.vnoise(x / 4, 5, b[5] + 3)
      if ny < cap and nx < .6 then
        local edge = not b.m:has(x, y - 1)
        local h = (nx < -.1) and L.snow.hi or L.snow.base
        if hash(x, y, 9) < .08 then h = L.snow.shade end
        if edge then h = L.snow.hi end
        px(x, y, h)
        if not (ny + 0.07 < cap) then
          px(x, y + 1, L.snow.shade) px(x, y + 2, L.snow.deep)
          if hash(x, b[5], 10) < .12 then wet[#wet + 1] = { x, y + 3, b } end
        end
      end
    end)
  else
    b.m:each(function(x, y)
      local nx, ny = (x - b[1]) / b[3], (y - b[2]) / b[4]
      local cap = -.5 + .22 * sin(x * .31 + b[5]) + .2 * hash(x // 3, 3, b[5])
      if ny < cap and nx < .75 then
        local v = hash(x, y, 9)
        local edge = not b.m:has(x, y - 1)
        local lt = -(nx * .6 + ny * .8)
        local h = lt > .75 and turf.hi or (lt > .35 and turf.base or turf.shade)
        if v < .1 then h = L.fern.hi elseif v > .94 then h = L.needle.base end
        if edge then h = (x % 2 == 0) and L.fern.hi or turf.edge end
        px(x, y, h)
        if not (ny + 0.06 < cap) then
          px(x, y + 1, turf.deep)
          if hash(x, b[5], 10) < .08 and b.m:has(x, y + 3) then px(x, y + 2, L.fern.shade) px(x, y + 3, turf.deep) end
        end
      end
    end)
  end
end
-- dark wet melt streaks running down from the snow patches, with a glint
for _, w in ipairs(wet) do
  local x, y, b = w[1], w[2], w[3]
  local n = 6 + floor(hash(x, y, 12) * 10)
  for t = 0, n do
    if rockM:has(x, y + t) and not face:has(x, y + t) then
      px(x, y + t, (t % 5 == 2) and Wt.shade or rock.deep)
    end
  end
end
-- dwarf pines, grass and edelweiss on the ledges
for _, f in ipairs({ { 318, 140, 4 }, { 300, 182, 3 }, { 426, 136, 3 }, { 458, 140, 4 }, { 346, 150, 3 } }) do F.fern(f[1], f[2], f[3], (f[1] % 2 == 0) and L.fern or L.needle) end
F.tree(372, 100, 14, 3)
F.conifer(462, 136, 12, L.foliage2, 59)
for _, e in ipairs({ { 310, 176 }, { 444, 178 }, { 332, 172 }, { 458, 186 } }) do F.edelweiss(e[1], e[2], true) end
for _, g in ipairs({ { 304, 186 }, { 438, 182 }, { 326, 176 } }) do F.gentian(g[1], g[2], true) end
-- a goat on the very top of the rock, as goats do
F.goat(336, 109, { k = .62, noShadow = true })
-- the dressed face: granite ashlar courses, an arched niche
part(face, sand, { inner = false })
F.courses(face, 132, 7, 14, sand)
F.lichen(face, .08, 59)
c:edgeIn(face, sand.edge)
local niche = c:rrect(362, 136, 410, 186, 20):clip(rect(362, 136, 410, 186))
fill(niche, rock.deep) c:edgeIn(niche, sand.edge)
niche:each(function(x, y)
  if (x - 386) + (y - 160) < -14 then px(x, y, rock.shade) end
  if hash(x, y, 5) < .04 then px(x, y, rock.edge) end
  if y > 176 and hash(x // 2, y, 6) < .3 then px(x, y, mix(rock.deep, Wt.deep, .5)) end -- wet at the back of the niche
end)
c:rrect(360, 134, 412, 188, 22):clip(rect(360, 134, 412, 186)):cut(c:rrect(362, 136, 410, 188, 20)):each(function(x, y) px(x, y, ((x + y) % 5 == 0) and sand.deep or sand.hi) end)
-- a keystone with a chiselled drop
do
  local ks = poly{ { 382, 131 }, { 390, 131 }, { 389, 138 }, { 383, 138 } }
  c:rim(ks, sand.edge) part(ks, sand, { nopop = true }) px(386, 133, Wt.shade) px(385, 134, Wt.shade) px(386, 134, Wt.base) px(387, 134, Wt.shade) px(386, 135, Wt.shade)
end
-- snow drift lying on the top of the dressed face, dripping icicles
for x = 352, 420 do
  if hash(x // 3, 2, 8) < .75 then
    local n = 1 + floor(hash(x, 3, 8) * 2)
    for k = 0, n do px(x, 131 + k, k == 0 and L.snow.hi or (k == n and L.snow.shade or L.snow.base)) end
    if hash(x, 4, 8) < .1 and not (x > 380 and x < 392) then for k = n + 1, n + 3 + floor(hash(x, 5, 8) * 3) do px(x, 131 + k, ice.shade) end end
  end
end
-- the carved stone gnome head spout
do
  local hx, hy = 386, 158
  local hat = poly{ { hx - 13, hy - 8 }, { hx + 13, hy - 8 }, { hx + 6, hy - 22 }, { hx + 11, hy - 26 }, { hx + 2, hy - 25 }, { hx - 6, hy - 18 } }
  local fc = c:rrect(hx - 11, hy - 9, hx + 11, hy + 3, 4)
  local beard = poly{ { hx - 12, hy - 1 }, { hx + 12, hy - 1 }, { hx + 9, hy + 12 }, { hx, hy + 18 }, { hx - 9, hy + 12 } }
  local head = union(hat, fc, beard)
  c:rim(head, sand.edge)
  part(fc, sand, { nopop = true }) part(beard, sand, { nopop = true }) part(hat, sand, { nopop = true })
  hline(hx - 13, hx + 13, hy - 8, sand.deep) hline(hx - 12, hx + 12, hy - 9, sand.hi)
  beard:each(function(x, y) if (x + 2 * y) % 5 == 0 and y > hy + 1 then px(x, y, sand.shade) end end)
  for _, ex in ipairs({ hx - 6, hx + 6 }) do px(ex - 2, hy - 4, sand.edge) px(ex - 1, hy - 3, sand.edge) px(ex, hy - 3, sand.edge) px(ex + 1, hy - 3, sand.edge) px(ex + 2, hy - 4, sand.edge) end
  local nose = c:ellipse(hx, hy - 1, 4, 3) c:rim(nose, sand.deep) part(nose, sand, { nopop = true }) px(hx - 2, hy - 3, sand.hi) px(hx - 1, hy - 3, sand.hi)
  px(hx - 9, hy - 1, sand.shade) px(hx + 9, hy - 1, sand.shade)
  -- a bored larch-wood pipe in the mouth
  local pipe = rect(hx - 2, hy + 4, hx + 4, hy + 7) c:rim(pipe, L.timber.edge) fill(pipe, L.timber.base) hline(hx - 2, hx + 4, hy + 4, L.timber.hi) fill(rect(hx + 3, hy + 5, hx + 4, hy + 6), Wt.deep)
  -- a snow cap on the stone hat, lichen on the beard, a wet streak below the mouth
  for x = hx - 4, hx + 8 do px(x, hy - 21 + floor(abs(x - hx - 2) * .6), L.snow.base) px(x, hy - 22 + floor(abs(x - hx - 2) * .6), L.snow.hi) end
  px(hx - 7, hy + 6, L.moss.hi) px(hx - 6, hy + 7, L.moss.base) px(hx + 6, hy + 9, L.lichenOrange)
  for y = hy + 8, hy + 14 do px(hx + 1, y, sand.shade) end
end
-- the jet: an arc from the mouth down into the basin
local JX0, JY0 = 391, 164
local function jetY(x) local t = (x - JX0) / 18 return JY0 + floor(t * t * 22 + t * 2) end
for x = JX0, JX0 + 17 do
  local y0, y1 = jetY(x), jetY(x + 1)
  for y = y0, math.max(y0 + 3, y1 + 1) do px(x, y, Wt.base) px(x + 1, y, Wt.base) px(x + 2, y, Wt.shade) end
  px(x, y0, Wt.hi) px(x, y0 - 1, Wt.edge)
  if x % 3 == 0 then px(x + 1, y0 + 1, GL) end
end

---------------------------------------------------------------- the basin, its overflow and the frog
F.depth(3)
local BX, BY = 392, 202
do
  local outer = c:ellipse(BX, BY, 40, 10)
  local wall = rect(BX - 40, BY, BX + 40, BY + 8)
  local inner = c:ellipse(BX, BY - 1, 35, 7)
  rimOf(union(outer, wall), L.stone)
  part(union(outer, wall), L.stone)
  F.courses(wall, BY, 4, 9, L.stone)
  wall:each(function(x, y) if (x - BX) > 20 and y > BY + 2 then px(x, y, L.stone.shade) end end)
  outer:edge():each(function(x, y) if y < BY then px(x, y, L.stone.hi) end end)
  F.lichen(wall, .18, 61)
  F.water(inner, Wt)
  -- the white rock face mirrored pale in the far half
  inner:each(function(x, y) if y < BY - 2 and y > BY - 7 and hash(x // 4, 0, 13) < .45 and (x + y) % 2 == 0 then px(x, y, Wt.hi) end end)
  -- an iron ladle hung on the rim, a few pebbles at its foot
  vline(BX - 30, BY - 7, BY - 2, L.iron.base) fill(c:ellipse(BX - 30, BY - 1, 2, 1), L.iron.shade) px(BX - 31, BY - 2, L.iron.hi)
  for x = BX - 40, BX + 40 do if hash(x, 4, 12) < .45 then local n = floor(hash(x, 5, 12) * 4) for k = 0, n do px(x, BY + 8 - k, k == n and L.fern.hi or turf.base) end end end
end
-- the trickle from a crack in the rock into a gnome's pail
do
  local cx, cy = 334, 168
  fill(line({ { cx - 3, cy - 4 }, { cx, cy } }, 2), rock.edge)
  for y = cy - 3, cy + 6 do px(cx - 1 + floor((y - cy + 4) * .3), y + 1, rock.deep) end
  for y = cy, 196 do px(cx + floor((y - cy) * .1), y, ((y // 2) % 2 == 0) and Wt.hi or Wt.base) end
  local _, hx, hy = F.gnome(318, 218, { hat = L.awnA, coat = L.lav, arm = "out" })
  local pail = poly{ { hx + 1, hy - 7 }, { hx + 10, hy - 7 }, { hx + 9, hy + 3 }, { hx + 2, hy + 3 } }
  c:rim(pail, L.timber.edge) part(pail, L.board) F.planks(pail, L.board, 3, true, 31)
  hline(hx + 1, hx + 10, hy - 5, L.iron.shade) hline(hx + 2, hx + 9, hy + 1, L.iron.shade)
  hline(hx + 2, hx + 9, hy - 7, Wt.hi) px(hx + 5, hy - 8, GL) px(hx + 8, hy - 9, Wt.hi)
  c:ellipse(hx + 5, hy - 12, 5, 4):edge():each(function(x, y) if y < hy - 11 then px(x, y, L.iron.base) end end)
end
-- QUIRK: the frog in a red gnome hat on a flat stone in the basin, eyes shut, under the shower
do
  local pad = c:ellipse(408, 200, 10, 3)
  rimOf(pad, L.stone) fill(pad, L.stone.base) pad:edge():each(function(x, y) if y > 200 then px(x, y, L.stone.deep) else px(x, y, L.stone.hi) end end)
  hline(399, 417, 203, Wt.hi)
  F.sprite({
    "..........RR....",
    ".........RRr....",
    "........HRRr....",
    ".......HRRRr....",
    "......HRRRRr....",
    "......RRRRRRr...",
    ".....HRRRRRRr...",
    "...bbbbbbbbbbb..",
    "..GGgGGGGGGgGGG.",
    ".GGekeGGGGGekeG.",
    ".GgGGGGGGGGGGgGg",
    "gGGGGmmmmmmGGGGg",
    "gGGGGGmmmmGGGGgg",
    "gGGyyyyyyyyyGGgd",
    ".gGyyyyyyyyyGgdd",
    "GGgyyyyyyyyygdGG",
    "GGGgyyyyyyygdGGG",
    ".dd.ddd..ddd.dd.",
  }, 400, 181, { R = L.awnA.base, r = L.awnA.shade, H = L.awnA.hi, b = L.awnB.base, G = L.leaf.base, g = L.leaf.shade,
    d = L.leaf.deep, e = L.leaf.deep, k = L.timber.edge, m = L.apple.shade, y = L.birchLeaf.hi })
  px(405, 191, L.leaf.deep) px(411, 190, L.leaf.deep) px(410, 192, L.leaf.shade)
  for _, p in ipairs({ { 409, 176 }, { 405, 178 }, { 413, 177 }, { 402, 181 }, { 416, 182 }, { 411, 173 }, { 399, 186 }, { 418, 186 } }) do px(p[1], p[2], Wt.hi) end
  px(407, 175, GL) px(414, 175, GL)
  -- a bar of soap and a little scrubbing brush on the stone
  fill(rect(415, 197, 417, 198), L.petal.hi) px(415, 197, L.awnB.hi)
end
-- the snowmelt brook winding down-left under the road, spreading into a braided gravel outwash
local brook = HP.mask()
local bar = HP.mask() -- gravel bars of the outwash
do
  local pts = { { 356, 208 }, { 340, 218 }, { 318, 226 }, { 296, 232 }, { 270, 238 }, { 240, 242 }, { 210, 244 }, { 180, 247 }, { 158, 250 } }
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local w = 12 + floor(i * 1.4)
    brook:add(line({ a, b }, w))
    brook:add(c:ellipse(b[1], b[2], w // 2, w // 2))
  end
  -- the outwash: a wide flat of shingle with braided channels splitting and rejoining
  local flat = c:ellipse(86, 252, 80, 20):clip(rect(16, 228, 200, 269))
  bar:add(flat)
  local chans = {
    { { 160, 248 }, { 130, 242 }, { 100, 240 }, { 70, 244 }, { 40, 240 }, { 16, 242 } },
    { { 160, 250 }, { 136, 256 }, { 110, 254 }, { 84, 258 }, { 56, 262 }, { 16, 260 } },
    { { 124, 243 }, { 112, 250 }, { 90, 251 }, { 70, 252 }, { 48, 250 }, { 30, 252 } },
    { { 110, 254 }, { 100, 264 }, { 80, 269 } },
  }
  for ci, ch in ipairs(chans) do
    for i = 1, #ch - 1 do brook:add(line({ ch[i], ch[i + 1] }, ci == 3 and 3 or (ci == 4 and 3 or 5))) end
  end
  brook:clip(rect(16, 0, 479, 269))
  bar:cut(brook)
end
local onRoad = HP.mask()
brook:each(function(x, y) if F.roadM:has(x, y) then onRoad:set(x, y) end end)
brook:cut(onRoad)
do
  -- shingle bars: rounded pebbles, pale dry tops, damp dark edges, the odd tuft
  -- a grassy bank round the shingle flat (hides the scree speckle of the turf behind it)
  bar:grow(4):cut(bar):cut(brook):cut(F.roadM):each(function(x, y)
    if y > 214 then
      local v = hash(x, y, 46)
      local h = v < .55 and L.ground.base or (v < .8 and turf.base or (v < .93 and L.ground.shade or L.fern.hi))
      if bar:has(x, y + 1) or bar:has(x, y + 2) then h = (x % 3 == 0) and L.fern.hi or turf.shade end
      px(x, y, h)
    end
  end)
  local wetEdge = brook:grow(1)
  bar:each(function(x, y)
    local v = F.vnoise(x / 4, y / 3, 47)
    local h = v < .35 and L.stone.shade or (v < .78 and L.stone.base or L.stone.hi)
    if hash(x, y, 48) < .025 then h = L.stone.deep end
    if not bar:has(x, y - 1) then h = turf.deep end
    if wetEdge:has(x, y) then h = L.stone.shade end
    px(x, y, h)
  end)
  for i = 1, 110 do
    local x, y = 20 + floor(hash(i, 1, 53) * 180), 232 + floor(hash(i, 2, 53) * 36)
    if bar:has(x, y) and bar:has(x + 2, y) and bar:has(x, y + 1) then
      local w = 1 + floor(hash(i, 3, 53) * 2)
      local m = c:ellipse(x, y, w + 1, w) rimOf(m, L.stone) part(m, L.stone, { nopop = true }) px(x - 1, y - 1, L.stone.hi)
    end
  end
  local bank = brook:grow(2):cut(brook):cut(F.roadM):cut(bar)
  bank:each(function(x, y) local v = hash(x, y, 51) px(x, y, v < .4 and L.stone.base or (v < .6 and L.stone.hi or (v < .85 and turf.base or turf.shade))) end)
  brook:edge():each(function(x, y) if hash(x, y, 52) < .3 then px(x, y, L.stone.hi) end end)
  F.water(brook, Wt, { step = 3 })
  -- the brook runs: lit current lines along the flow, cold glints
  brook:each(function(x, y)
    if y % 3 == 1 and hash(x // 5, y, 54) < .3 and brook:has(x - 2, y) and brook:has(x + 2, y) and brook:has(x, y + 2) then px(x, y, Wt.hi) end
    if hash(x, y, 55) < .015 and brook:has(x, y - 2) then px(x, y, GL) end
  end)
  -- riffles where the channels run shallow over the shingle
  for _, r in ipairs({ { 120, 241 }, { 82, 242 }, { 50, 241 }, { 96, 251 }, { 60, 251 }, { 124, 255 }, { 70, 261 }, { 36, 261 } }) do
    for k = 0, 4 do if brook:has(r[1] + k, r[2]) then px(r[1] + k, r[2], (k % 2 == 0) and GL or Wt.hi) end end
    if brook:has(r[1] + 1, r[2] + 1) then px(r[1] + 1, r[2] + 1, Wt.shade) end
  end
  -- granite stones in the stream, a foam lip upstream
  for _, s in ipairs({ { 334, 220 }, { 310, 228 }, { 290, 234 }, { 186, 247 }, { 270, 241 } }) do
    local m = c:ellipse(s[1], s[2], 3, 2) rimOf(m, L.stone) part(m, L.stone, { nopop = true }) px(s[1] - 1, s[2] - 1, L.stone.hi)
    px(s[1] - 1, s[2] - 2, L.moss.base) px(s[1], s[2] - 2, L.moss.hi)
    for k = 0, 3 do px(s[1] + 3 + k, s[2] - 2 + (k % 2), GL) end hline(s[1] - 4, s[1] - 1, s[2] + 3, Wt.hi)
  end
  for y = 204, 212 do px(354 + (y - 204) // 3, y, Wt.hi) px(355 + (y - 204) // 3, y, Wt.base) px(356 + (y - 204) // 3, y, GL) end
end
-- granite bridge where the road crosses the brook
do
  local Y0, Y1 = 226, 258
  local par, cope = HP.mask(), HP.mask()
  for y = Y0, Y1 do
    local xl, xr = floor(F.xl(y)), floor(F.xr(y) + .99)
    par:add(rect(xl - 7, y - 10, xl + 1, y)):add(rect(xr - 1, y - 10, xr + 7, y))
  end
  par:clip(rect(0, Y0 - 10, 479, Y1))
  par:each(function(x, y) if not par:has(x, y - 2) then cope:set(x, y) end end)
  local wallL = poly{ { floor(F.xl(234)) - 22, 236 }, { floor(F.xl(234)) - 6, 230 }, { floor(F.xl(256)) - 6, 258 }, { floor(F.xl(256)) - 24, 258 } }
  local wallR = poly{ { floor(F.xr(226)) + 6, 224 }, { floor(F.xr(226)) + 22, 228 }, { floor(F.xr(244)) + 22, 248 }, { floor(F.xr(244)) + 6, 248 } }
  local walls = union(wallL, wallR)
  rimOf(union(par, walls), L.stone)
  part(walls, L.stone, { nopop = true }) F.courses(walls, 236, 4, 8, L.stone)
  F.lichen(walls, .2, 60)
  for _, a in ipairs({ { floor(F.xl(244)) - 15, 251, wallL }, { floor(F.xr(236)) + 14, 242, wallR } }) do
    local arch = c:ellipse(a[1], a[2], 7, 9):clip(rect(a[1] - 7, a[2] - 9, a[1] + 7, a[2] + 4)):clip(a[3])
    fill(arch, Wt.edge)
    arch:each(function(x, y) if y > a[2] - 2 then px(x, y, (x + y) % 3 == 0 and Wt.shade or Wt.deep) end end)
    c:ellipse(a[1], a[2], 9, 11):cut(c:ellipse(a[1], a[2], 7, 9)):clip(rect(a[1] - 9, a[2] - 11, a[1] + 9, a[2])):clip(a[3]):each(function(x, y)
      px(x, y, (math.atan(y - a[2], x - a[1]) * 4 // 1) % 2 == 0 and L.stone.hi or L.stone.base) end)
    for k = 0, 4 do px(a[1] - 4 + k * 2, a[2] + 3, GL) end
    -- icicles left hanging from the arch crown
    for k = -4, 4, 2 do local n = 2 + floor(hash(k, a[1], 61) * 3) for t = 0, n do px(a[1] + k, a[2] - 9 + t, t == n and ice.shade or ice.base) end end
  end
  part(par, L.stone, { nopop = true })
  F.courses(par, Y0 - 10, 4, 7, L.stone)
  F.lichen(par, .15, 62)
  cope:each(function(x, y) px(x, y, cope:has(x, y - 1) and L.stone.base or (hash(x // 3, y, 58) < .25 and L.snow.hi or L.stone.hi)) end)
  for _, p in ipairs({ { floor(F.xl(254)) - 6, 254 }, { floor(F.xr(250)) + 4, 250 } }) do for k = -3, 3 do px(p[1] + k, p[2] - (k % 2), turf.base) px(p[1] + k, p[2] - 1 - (k % 2), L.fern.hi) end end
  F.edelweiss(floor(F.xl(254)) - 8, 251, true) F.gentian(floor(F.xr(250)) + 6, 247, true)
end

---------------------------------------------------------------- left: a granite well-head with a larch-shingle roof, a gnome winding the bucket
F.depth(3)
do
  local x0, x1, yb = 52, 104, 204
  local wall = c:rrect(x0, yb - 18, x1, yb, 3)
  local postL, postR = rect(x0 + 4, yb - 52, x0 + 7, yb - 18), rect(x1 - 7, yb - 52, x1 - 4, yb - 18)
  local roof = poly{ { x0 - 6, yb - 48 }, { (x0 + x1) // 2, yb - 66 }, { x1 + 6, yb - 48 } }:add(rect(x0 - 6, yb - 49, x1 + 6, yb - 46))
  local axle = rect(x0 + 4, yb - 36, x1 - 4, yb - 34)
  local crank = line({ { x1 - 2, yb - 35 }, { x1 + 4, yb - 35 }, { x1 + 4, yb - 29 } }, 2)
  F.shadow(x0 + 2, x1, yb, 12, 4)
  rimOf(union(wall, postL, postR, roof, axle, crank), L.timber)
  -- rubble granite curb: irregular blocks, a lit coping
  wall:each(function(x, y)
    local row = (y - (yb - 18)) // 5
    local ry = (y - (yb - 18)) % 5
    local bw = 7 + floor(hash(row, 1, 19) * 4)
    local rx = (x + row * 3) % bw
    local v = hash((x + row * 3) // bw, row, 20)
    local h = v < .35 and L.stone.base or (v < .7 and L.stone.hi or L.stone.shade)
    if ry == 0 or rx == 0 then h = L.stone.deep elseif ry == 1 and rx == 1 then h = L.stone.hi end
    if x > x1 - 12 and ry ~= 0 and rx ~= 0 then h = L.stone.shade end
    px(x, y, h)
  end)
  c:edgeIn(wall, L.stone.edge)
  hline(x0 + 2, x1 - 2, yb - 18, L.stone.hi) hline(x0 + 3, x1 - 3, yb - 17, L.stone.base)
  F.lichen(wall, .22, 63)
  for x = x0, x1 do if hash(x, 7, 61) < .5 then px(x, yb, turf.base) px(x, yb - 1, L.fern.hi) end end
  part(postL, L.timber, { nopop = true }) part(postR, L.timber, { nopop = true })
  -- larch shingles, sun-scorched, with a weighting stone and a snow lump on the ridge
  part(roof, L.roof2, { sep = true }) F.courses(roof, yb - 66, 3, 5, L.roof2)
  roof:each(function(x, y) if hash(x // 2, y // 3, 64) < .12 then px(x, y, L.roof2.deep) end end)
  F.lichen(roof, .12, 65)
  line({ { x0 - 6, yb - 48 }, { (x0 + x1) // 2, yb - 66 } }):each(function(x, y) px(x, y, L.roof2.hi) end)
  for x = x0 + 8, x0 + 22 do local y = yb - 48 - floor((x - x0 + 6) * 18 / 32) px(x, y - 1, L.snow.hi) px(x, y, L.snow.base) end
  local ws = c:ellipse((x0 + x1) // 2, yb - 66, 3, 2) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true }) px((x0 + x1) // 2 - 1, yb - 67, L.stone.hi)
  -- icicles under the eave
  for _, ix in ipairs({ x0 - 3, x0 + 2, x1 + 1, x1 + 4 }) do local n = 1 + (ix % 3) vline(ix, yb - 45, yb - 45 + n, ice.base) px(ix, yb - 45 + n, ice.shade) end
  part(axle, L.timber, { nopop = true, noshade = true })
  fill(rect((x0 + x1) // 2 - 4, yb - 37, (x0 + x1) // 2 + 4, yb - 33), L.board.base)
  for x = (x0 + x1) // 2 - 4, (x0 + x1) // 2 + 4, 2 do vline(x, yb - 37, yb - 33, L.board.shade) end
  part(crank, L.iron, { nopop = true, noshade = true })
  local bx = (x0 + x1) // 2
  vline(bx, yb - 32, yb - 26, L.board.deep)
  local bk = poly{ { bx - 5, yb - 25 }, { bx + 5, yb - 25 }, { bx + 4, yb - 17 }, { bx - 4, yb - 17 } }
  c:rim(bk, L.timber.edge) part(bk, L.board) hline(bx - 5, bx + 5, yb - 23, L.iron.shade) hline(bx - 4, bx + 4, yb - 25, Wt.hi)
  px(bx + 4, yb - 14, Wt.hi) px(bx - 3, yb - 12, Wt.base)
  local _, hx, hy = F.gnome(x1 + 14, yb + 4, { hat = L.awnA, coat = L.accent, arm = "up", flip = true })
  fill(line({ { hx, hy }, { x1 + 4, yb - 29 } }), L.skin.base)
end
-- grass, junipers and edelweiss at the well's foot
for _, f in ipairs({ { 46, 206, 4 }, { 38, 200, 4 }, { 112, 214, 4 } }) do F.fern(f[1], f[2], f[3]) end
F.juniper(40, 216, 7, 4, 66)
F.edelweiss(48, 212, true) F.gentian(54, 215, true) F.edelweiss(34, 210, true)

---------------------------------------------------------------- road: gnome with two pails on a yoke; the spring sign
F.depth(3)
do
  local x, yb = 262, 212
  F.gnome(x, yb, { hat = L.gentian, coat = L.roof2, arm = "hold" })
  local yoke = line({ { x - 16, yb - 12 }, { x, yb - 14 }, { x + 16, yb - 12 } }, 2)
  c:rim(yoke, L.timber.edge) part(yoke, L.board, { nopop = true, noshade = true })
  for _, sx in ipairs({ -16, 16 }) do
    vline(x + sx, yb - 11, yb - 6, L.board.deep)
    local p = poly{ { x + sx - 5, yb - 6 }, { x + sx + 5, yb - 6 }, { x + sx + 4, yb + 2 }, { x + sx - 4, yb + 2 } }
    c:rim(p, L.timber.edge) part(p, L.board) hline(x + sx - 5, x + sx + 5, yb - 4, L.iron.shade) hline(x + sx - 4, x + sx + 4, yb - 6, Wt.hi)
    px(x + sx + 3, yb + 4, Wt.hi)
  end
  for i = 1, 4 do px(x - 2 + (i % 2) * 4, yb - 6 - i * 7, L.road.shade) end
end
do -- the spring sign: a blue drop on a larch board, a little slab roof with snow
  local post = rect(206, 168, 207, 196)
  local bd = rect(194, 156, 220, 170)
  local rf = poly{ { 191, 156 }, { 207, 149 }, { 223, 156 } }
  rimOf(union(post, bd, rf), L.timber) part(post, L.timber, { nopop = true }) part(bd, L.board, { nopop = true }) c:edgeIn(bd, L.board.deep)
  F.planks(bd:shrink(1), L.board, 5, false, 33)
  part(rf, L.roof, { nopop = true }) line({ { 192, 155 }, { 206, 149 } }):each(function(x, y) px(x, y, L.snow.hi) px(x, y + 1, L.snow.base) end)
  local drop = poly{ { 207, 158 }, { 211, 164 }, { 203, 164 } }:add(c:ellipse(207, 165, 4, 3))
  c:rim(drop, Wt.edge) fill(drop, Wt.base) px(205, 164, Wt.hi) px(205, 165, GL) hline(206, 209, 168, Wt.shade)
  -- a tiny snowflake (meltwater from the glacier)
  px(198, 160, L.gentian.base) px(197, 160, L.gentian.shade) px(199, 160, L.gentian.shade) px(198, 159, L.gentian.shade) px(198, 161, L.gentian.shade)
  px(216, 160, L.gentian.base) px(215, 160, L.gentian.shade) px(217, 160, L.gentian.shade) px(216, 159, L.gentian.shade) px(216, 161, L.gentian.shade)
end

---------------------------------------------------------------- a jug stall by the sign: clay jugs and larch cups, a seller behind
F.depth(3)
do
  F.gnome(156, 188, { hat = L.lav, coat = L.awnB, arm = "out", noShadow = true })
  local top = rect(132, 186, 182, 189)
  local legs = rect(135, 190, 136, 200):add(rect(178, 190, 179, 200))
  local cloth = rect(132, 190, 182, 194)
  F.shadow(134, 182, 201, 8, 3)
  rimOf(union(top, legs, cloth), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true }) part(top, L.board, { nopop = true }) hline(132, 182, 186, L.board.hi)
  -- a gentian-and-cream check cloth
  fill(cloth, L.awnB.base) cloth:each(function(x, y) if (((x - 132) // 3) + ((y - 190) // 2)) % 2 == 0 then px(x, y, L.gentian.base) end if y == 194 then px(x, y, L.gentian.deep) end end)
  for i, jx in ipairs({ 137, 147, 165, 174 }) do
    local big = i % 2 == 1
    local jh = big and 10 or 7
    local jug = c:rrect(jx - 3, 185 - jh, jx + 3, 185, 2):add(rect(jx - 1, 183 - jh, jx + 1, 185 - jh))
    local hnd = c:ellipse(jx + 4, 180 - jh // 2, 2, 2):cut(c:ellipse(jx + 4, 180 - jh // 2, 1, 1))
    c:rim(union(jug, hnd), L.timber.edge) part(jug, L.roof2) fill(hnd, L.roof2.shade)
    hline(jx - 3, jx + 3, 182 - jh // 2, L.awnB.base) px(jx - 2, 184 - jh, L.roof2.hi)
    if big then px(jx, 181 - jh // 2, L.gentian.base) end
  end
  for _, bx in ipairs({ 156, 160 }) do -- turned larch cups
    local cup = rect(bx - 1, 182, bx + 1, 185) c:rim(cup, L.timber.edge) fill(cup, L.board.base) px(bx - 1, 182, L.board.hi) px(bx + 1, 184, L.board.deep)
  end
  -- a little round of cheese for the thirsty
  local ch = c:rrect(169, 181, 173, 185, 1) c:rim(ch, L.cheese.edge) part(ch, L.cheese, { nopop = true })
end

---------------------------------------------------------------- mid: a far gnome on the road, path stones
F.depth(2)
F.gnome(238, 146, { small = true, hat = L.lav, coat = L.wall2, arm = "out" })
px(248, 139, L.roof2.base) px(248, 140, L.roof2.shade)
F.depth(3)
for _, s in ipairs({ { 200, 206 }, { 186, 210 }, { 170, 212 }, { 150, 210 }, { 132, 208 } }) do
  local m = c:ellipse(s[1], s[2], 5, 2) rimOf(m, L.stone) part(m, L.stone, { nopop = true }) px(s[1] - 2, s[2] - 1, L.stone.hi) px(s[1] + 1, s[2] - 2, L.moss.base)
end

---------------------------------------------------------------- right of the road: a small gnome with a jug, a young larch and a juniper
F.depth(2)
F.larch(280, 152, 28, 61) F.juniper(300, 148, 9, 5, 62)
F.depth(3)
do
  local _, hx, hy = F.gnome(286, 192, { hat = L.awnA, coat = L.gentian, arm = "hold" })
  local jug = c:rrect(hx - 2, hy - 6, hx + 3, hy + 1, 2) c:rim(jug, L.timber.edge) part(jug, L.roof2, { nopop = true }) px(hx - 1, hy - 5, L.roof2.hi)
end

---------------------------------------------------------------- the outwash: a plank footbridge, marsh marigolds, dwarf willow, the washer gnome
F.depth(3)
do -- a two-plank footbridge over the main channel, on boulder piers
  F.boulder(92, 245, 4, 3, 71) F.boulder(112, 247, 4, 3, 72)
  local pl = poly{ { 88, 238 }, { 116, 241 }, { 116, 244 }, { 88, 241 } }
  rimOf(pl, L.timber) part(pl, L.board, { nopop = true })
  line({ { 89, 239 }, { 115, 242 } }):each(function(x, y) px(x, y, L.board.hi) end)
  line({ { 89, 241 }, { 115, 244 } }):each(function(x, y) px(x, y, L.board.deep) end)
  for x = 92, 112, 6 do px(x, 240 + floor((x - 88) * 3 / 28), L.timber.deep) end
end
do -- dwarf willow scrub with silver catkins at the outwash's left
  local m = F.crown(30, 238, 12, 7, L.juniper, 81)
  for i = 1, 9 do
    local x, y = 20 + floor(hash(i, 1, 82) * 22), 232 + floor(hash(i, 2, 82) * 10)
    if m:has(x, y) and m:has(x, y + 1) then px(x, y, L.edel.hi) px(x, y + 1, L.edel.shade) end
  end
end
local function marigold(x, y)
  px(x - 1, y + 1, L.leaf.shade) px(x, y + 1, L.leaf.base) px(x + 1, y + 1, L.leaf.deep) px(x - 2, y + 1, L.leaf.base)
  px(x, y, L.gold.hi) px(x - 1, y, L.gold.base) px(x + 1, y, L.gold.shade) px(x, y - 1, L.gold.base)
end
for _, p in ipairs({ { 52, 236 }, { 58, 238 }, { 140, 238 }, { 146, 236 }, { 24, 254 }, { 130, 264 }, { 64, 246 } }) do
  if not brook:has(p[1], p[2]) then marigold(p[1], p[2]) end
end
do -- the washer gnome on a flat stone with a basket of laundry and a washboard
  local st = c:ellipse(170, 236, 12, 3) rimOf(st, L.stone) part(st, L.stone, { nopop = true }) F.lichen(st, .2, 64)
  local _, hx, hy = F.gnome(168, 232, { hat = L.awnB, coat = L.fern, arm = "out", flip = true, noShadow = true })
  local wb = rect(hx - 6, hy - 6, hx, hy + 4) c:rim(wb, L.timber.edge) part(wb, L.board, { nopop = true })
  for y = hy - 4, hy + 3, 2 do hline(hx - 5, hx - 1, y, L.board.deep) end
  for k = 0, 2 do hline(hx - 12 - k * 2, hx - 6 + k * 2, hy + 7 + k * 2, Wt.hi) end
  local bsk = c:rrect(184, 222, 202, 234, 3) rimOf(bsk, L.board) part(bsk, L.needle)
  bsk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) elseif (x - y) % 4 == 0 then px(x, y, L.needle.hi) end end)
  fill(c:ellipse(189, 221, 4, 2), L.gentian.base) fill(c:ellipse(196, 220, 4, 2), L.awnA.base) px(194, 219, L.awnA.hi) px(187, 220, L.gentian.hi)
end
-- washing spread to dry on the shingle
for _, w in ipairs({ { 64, 256, L.awnA }, { 132, 258, L.lav } }) do
  local m = rect(w[1], w[2], w[1] + 7, w[2] + 2)
  if not brook:has(w[1], w[2]) then c:rim(m, w[3].edge) fill(m, w[3].base) hline(w[1], w[1] + 7, w[2], w[3].hi) px(w[1] + 3, w[2] + 2, w[3].shade) end
end
F.boulder(20, 232, 8, 7, 76)

---------------------------------------------------------------- grass, gentians, edelweiss and alpine roses round the rocks
F.depth(3)
for _, f in ipairs({ { 292, 214, 5 }, { 306, 222, 4 }, { 452, 214, 5 }, { 376, 222, 4 }, { 120, 208, 4 }, { 468, 220, 4 }, { 230, 214, 4 } }) do F.fern(f[1], f[2], f[3], (f[1] % 3 == 0) and L.needle or L.fern) end
for i = 0, 9 do
  local x, y = 300 + floor(hash(i, 1, 71) * 160), 220 + floor(hash(i, 2, 71) * 8)
  if not F.roadM:has(x, y) and not brook:grow(3):has(x, y) then
    if i % 2 == 0 then F.gentian(x, y, true) F.gentian(x + 3, y + 1, true) else F.edelweiss(x, y, true) F.edelweiss(x + 3, y - 1, false) end
  end
end
local function alpineRose(x, yb, w, seed)
  local m = F.crown(x, yb - 3, w, 3, L.juniper, seed)
  for k = 1, w do
    local bx, by = x + floor((hash(k, 1, seed) - .5) * w * 1.6), yb - 1 - floor(hash(k, 2, seed) * 5)
    if m:has(bx, by) then px(bx, by, L.petal.base) px(bx + 1, by, L.petal.shade) px(bx, by - 1, L.petal.hi) end
  end
end
alpineRose(440, 226, 7, 91) alpineRose(300, 230, 6, 92) alpineRose(462, 228, 5, 93)
for i, s in ipairs({ { 292, 206 }, { 306, 202 }, { 322, 204 } }) do
  local m = c:ellipse(s[1], s[2], 5, 2) rimOf(m, L.stone) part(m, L.stone, { nopop = true }) px(s[1] - 2, s[2] - 1, L.stone.hi) px(s[1] + 2, s[2] - 2, L.moss.base)
end
F.tree(458, 228, 30, 2)

---------------------------------------------------------------- foreground life: willowherb, a water cart, a wagtail, dragonflies
F.depth(3)
local function willowherb(x, yb, n, hmax, seed)
  local m, spikes = HP.mask(), {}
  for i = 1, n do
    local bx = x + floor((hash(i, 1, seed) - .5) * n * 1.4)
    local h = floor(hmax * (.55 + .45 * hash(i, 2, seed)))
    local lean = (hash(i, 3, seed) - .5) * 4
    m:add(line({ { bx, yb }, { bx + lean, yb - h } }, 1))
    for k = 2, h - 4, 3 do m:set(floor(bx + lean * k / h) - 1, yb - k) m:set(floor(bx + lean * k / h) + 1, yb - k + 1) end
    spikes[#spikes + 1] = { floor(bx + lean), yb - h }
  end
  c:rim(m, L.fern.edge)
  m:each(function(xx, yy) local t = (yb - yy) / hmax px(xx, yy, t > .6 and L.fern.hi or (t > .25 and L.fern.base or L.fern.shade)) end)
  for _, s in ipairs(spikes) do
    for k = 0, 5 do
      local yy = s[2] - k
      px(s[1], yy, k > 3 and L.petal.shade or L.petal.base)
      if k % 2 == 0 then px(s[1] - 1, yy + 1, L.petal.hi) px(s[1] + 1, yy, L.petal.shade) end
    end
    px(s[1], s[2] - 6, L.fern.shade)
  end
end
willowherb(352, 236, 7, 18, 21) willowherb(374, 262, 6, 20, 22) willowherb(156, 268, 6, 16, 23)
-- a gnome hauling a little water cart: a barrel on two wheels, slopping over
do
  local x, yb = 322, 266
  local barr = c:rrect(330, 242, 354, 260, 5)
  local shaft = line({ { 332, 256 }, { 326, 258 } }, 2)
  local wh = c:ellipse(342, 262, 6, 6)
  F.shadowM(c:ellipse(346, 268, 16, 1))
  rimOf(union(barr, shaft, wh), L.timber)
  part(barr, L.timber) F.planks(barr, L.timber, 4, true, 12)
  for _, hy in ipairs({ 245, 256 }) do hline(330, 354, hy, L.iron.shade) hline(331, 353, hy - 1, L.iron.hi) end
  part(shaft, L.board, { nopop = true, noshade = true })
  part(wh, L.timber, { nopop = true }) fill(c:ellipse(342, 262, 3, 3), L.timber.shade)
  vline(342, 257, 267, L.timber.deep) hline(337, 347, 262, L.timber.deep) px(342, 262, L.iron.hi)
  fill(rect(339, 240, 345, 241), Wt.base) px(340, 240, Wt.hi)
  for _, p in ipairs({ { 348, 239 }, { 351, 238 }, { 355, 241 }, { 357, 245 }, { 336, 239 } }) do px(p[1], p[2], Wt.hi) end
  F.gnome(x, yb, { hat = L.roof2, coat = L.wall2, arm = "out" })
end
F.fern(306, 262, 5) F.fern(296, 266, 4, L.needle) F.fern(364, 268, 4)
F.edelweiss(300, 258, true) F.gentian(312, 262, true)
-- a white wagtail on the bridge coping: grey back, black bib, white face, long tail
F.sprite({ ".kk....", "kWWk...", "kkGGgt.", ".WGGGtt", "..l.l.." }, floor(F.xr(230)) + 1, 211,
  { k = "#3a3c46", W = L.edel.hi, G = "#9aa0a8", g = "#747a84", t = "#3a3c46", l = L.timber.edge })
-- dragonflies over the water
for i, d in ipairs({ { 296, 222 }, { 176, 238 }, { 120, 234 }, { 360, 222 } }) do
  local x, y = d[1], d[2]
  local body = ({ L.gentian, L.apple, L.fern, L.lav })[i]
  hline(x - 3, x + 3, y, Wt.hi) px(x - 2, y - 1, GL) px(x + 2, y - 1, GL)
  vline(x, y - 1, y + 4, body.shade) px(x, y - 1, body.hi) px(x, y + 4, body.deep)
end

---------------------------------------------------------------- cold mist lying on the water (solid dithered streaks)
brook:each(function(x, y)
  local band = (y + floor(sin(x / 17) * 2)) % 9
  if band < 2 and hash(x // 11, y // 9, 90) < .5 and (x + y) % 2 == 0 then
    local v = c:get(x, y)
    if v == Wt.hi or v == Wt.base or v == Wt.shade or v == mix(Wt.hi, Wt.base, .5) then px(x, y, band == 0 and L.mist2 or L.mist) end
  end
end)

F.depth(0)
F.birds({ { 330, 44, 2 }, { 340, 50, 1 }, { 168, 60, 2 }, { 186, 54, 2 }, { 236, 70, 1 } })
F.finish()
