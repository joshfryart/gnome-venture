-- shrine.lua : "Wayside shrine" stop look, TUNDRA (tundra_frost), 480x270 gate view.
-- Same composition as the Maplewold shrine (art-2701-batch3/stops/opus3/shrine.lua) and the forest shrine, re-cast
-- for the arctic tundra under a faint aurora: road's end: a small sod chapel with a steep turf A-frame roof under a
-- snow cap, herringbone turf walls, reindeer antlers on the apex and a lamp-lit open door, on a frosted stone terrace.
-- Over the road: a gate of two stacked-stone cairn pillars carrying a driftwood lintel, hung with prayer ribbons.
-- Back left: the great snow-capped cairn shrine (a ribbon-wound pole on a stone heap) with prayer-flag lines fanning
-- out to stakes. Right back: an old bare larch hung with ribbons, roped, redpolls and a raven in it, and the bell
-- frame under sod. Left hero: a steaming warm-spring basin under a sod shelter fed by a driftwood spout. Right hero:
-- the offering rack of carved bone plaques and ribbons. Bottom left: a raked snow garden ringed with stones.
-- Paired snow-capped stone lanterns, an ember fire bowl, ravens on the lintel, gnomes sweeping snow and tying ribbons.
-- Quirk (kept): a real arctic fox kit sits on the plinth beside the stone fox, wearing its red bib.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-tundra-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "shrine", out = DIR, farTrees = { 24, 150, 318, 352, 440 }, treeLineGap = { 176, 304 },
  sunX = 104, sunY = 82 }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local S, RED = L.snow, L.awnA
local BRONZE = F.rp("#dcb878 #ae8a50 #82663c #5c482e #3a2e24")
local ROPE = F.rp("#ecd890 #ccb066 #a48848 #765e36 #4c3c26")
local GREENR = F.rp("#bce4c8 #84c09c #5e9a7c #42705c #284838")
local BONE = F.rp("#f2ead8 #ddd2b8 #bcae92 #8e826e #5c5448")
-- prayer colours: blue, white, red, green, yellow (+ lilac)
local RIB = { L.accent, L.awnB, RED, GREENR, L.gold, L.lav }

-- warm light spill: tint what is already there toward the glow (hard pixels, no alpha)
local function glowSpill(cx, cy, r, k)
  for y = cy - r, cy + r do for x = cx - r, cx + r do
    local d = math.sqrt((x - cx) ^ 2 + ((y - cy) * 1.4) ^ 2)
    if d <= r then local v = c:get(x, y) if v then px(x, y, F.mix(v, L.glow.hi, k * (1 - d / (r + 1)) + .04)) end end
  end end
end
local function candle(x, yb, h)
  h = h or 3
  vline(x, yb - h + 1, yb, L.awnB.hi) vline(x + 1, yb - h + 2, yb, L.awnB.shade)
  px(x, yb - h, L.glow.base) px(x, yb - h - 1, L.glow.hi)
end
-- a cloth ribbon fluttering down (and a little sideways in the wind) from (x,y)
local function ribbon(x, y, len, r, dir)
  dir = dir or 1
  for k = 0, len do
    local xx = x + ((k > len // 2) and dir or 0) + ((k > len - 2 and len > 6) and dir or 0)
    px(xx, y + k, k == 0 and r.hi or r.base) px(xx + 1, y + k, k == len and r.deep or r.shade)
  end
end
-- a cord from a to b sagging, with square prayer flags hanging every `every` px
local function flagLine(x0, y0, x1, y1, sag, every, fh, start)
  local function ly(xx) local t = (xx - x0) / (x1 - x0) return floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + .5) end
  local a, b = math.min(x0, x1), math.max(x0, x1)
  for xx = a, b do
    local y = ly(xx)
    px(xx, y, ROPE.deep)
    local yn = ly(xx + (x1 > x0 and 1 or -1))
    if math.abs(yn - y) > 1 then for yy = math.min(y, yn) + 1, math.max(y, yn) - 1 do px(xx, yy, ROPE.deep) end end
  end
  local i = start or 0
  for xx = a + 3, b - 3, every do
    i = i + 1
    local r = RIB[(i - 1) % 5 + 1]
    local yy = ly(xx) + 1
    for k = 0, fh - 1 do
      px(xx, yy + k, k == 0 and r.hi or r.base) px(xx + 1, yy + k, r.base) px(xx + 2, yy + k, k == fh - 1 and r.deep or r.shade)
    end
  end
end
local function stake(x, yb, h)
  local m = rect(x, yb - h, x + 1, yb)
  rimOf(m, L.timber) part(m, L.timber, { nopop = true, noshade = true }) px(x, yb - h, S.hi) px(x + 1, yb - h, S.base)
  fill(c:ellipse(x + 1, yb, 3, 1), S.base) px(x - 2, yb, S.hi)
end
-- a stack of flat stones from yb up to yt around cx: returns mask and the rows. Snow lies on every exposed top.
local function stack(cx, yt, yb, w0, seed)
  local m, rows, y, i = HP.mask(), {}, yb, 0
  while y > yt do
    i = i + 1
    local sh = 4 + floor(hash(i, 2, seed) * 3)
    if y - sh < yt then sh = y - yt end
    local w = w0 + floor(hash(i, 1, seed) * 3) - (i % 2)
    local ox = floor((hash(i, 3, seed) - .5) * 3)
    local r = c:rrect(cx - w + ox, y - sh + 1, cx + w + ox, y, 1)
    rows[#rows + 1] = r m:add(r)
    y = y - sh
  end
  return m, rows
end
local function paintStack(m, rows, cx, seed)
  rimOf(m, L.stone)
  for _, r in ipairs(rows) do part(r, L.stone, { nopop = true, sep = true }) end
  m:each(function(x, y)
    if not m:has(x, y - 1) then px(x, y, x < cx + 1 and S.hi or S.base)
      if m:has(x, y + 1) and hash(x, y, seed) < .5 then px(x, y + 1, x < cx and S.base or S.shade) end
    elseif hash(x, y, seed + 1) < .07 then px(x, y, L.lichen.base)
    elseif hash(x // 2, y, seed + 2) < .05 then px(x, y, L.rust.shade) end
  end)
end

---------------------------------------------------------------- back-left: the great cairn shrine (stone heap, ribbon pole)
F.depth(1)
F.tree(90, 128, 44, 2)
F.tree(16, 132, 30, 1)
local function ovoo(cx, yb)
  F.shadow(cx - 24, cx + 24, yb, 8, 3)
  local heap = poly{ { cx - 27, yb }, { cx - 21, yb - 7 }, { cx - 14, yb - 17 }, { cx - 8, yb - 26 }, { cx - 3, yb - 29 }, { cx + 4, yb - 29 },
    { cx + 9, yb - 25 }, { cx + 15, yb - 16 }, { cx + 22, yb - 7 }, { cx + 27, yb } }
  -- lumpy silhouette: boulders bulging out of the slope
  for i = 0, 9 do
    local t = i / 9
    local side = (i % 2 == 0) and -1 or 1
    local yy = yb - floor(t * 24)
    local xx = cx + side * floor(26 - t * 20)
    heap:add(c:ellipse(xx, yy - 1, 3, 2))
  end
  heap:cut(rect(cx - 40, yb + 1, cx + 40, yb + 10))
  local pole = rect(cx - 1, yb - 72, cx, yb - 28)
  rimOf(union(heap, pole), L.stone)
  part(heap, L.stone)
  -- heaped boulders: each pixel belongs to its nearest seed stone, lit upper-left, dark joints, lichen on some
  local seeds = {}
  for i = 1, 70 do seeds[i] = { cx - 27 + hash(i, 1, 101) * 54, yb - hash(i, 2, 101) * 30, hash(i, 3, 101) } end
  heap:each(function(x, y)
    local b1, b2, bi = 1e9, 1e9, 1
    for i, sd in ipairs(seeds) do
      local d = ((x - sd[1]) / 1.5) ^ 2 + (y - sd[2]) ^ 2
      if d < b1 then b2 = b1 b1, bi = d, i elseif d < b2 then b2 = d end
    end
    local sd = seeds[bi]
    local h
    if math.sqrt(b2) - math.sqrt(b1) < .8 then h = L.stone.deep
    else
      local lit = (sd[1] - x) / 1.5 + (sd[2] - y)
      h = lit > 1.5 and L.stone.hi or (lit > -1 and L.stone.base or L.stone.shade)
      if x > cx + 8 and h == L.stone.base then h = L.stone.shade end
      if sd[3] < .12 then h = lit > 0 and L.lichen.base or L.lichen.shade elseif sd[3] > .9 then h = lit > 0 and L.greyMoss.base or L.greyMoss.shade end
      if lit > 1.5 and sd[3] > .5 and hash(x, y, 102) < .6 then h = S.base end
    end
    px(x, y, h)
  end)
  F.snowCap(heap, 3, 103, { cx = cx - 1 })
  -- snow drifted against the foot
  F.drift(cx - 18, yb + 1, 12, 3, 104) F.drift(cx + 20, yb + 2, 10, 2, 105)
  -- the pole: silver driftwood, a twig-and-antler bundle at the top, blue scarves wound round it
  part(pole, L.timber, { nopop = true, noshade = true }) vline(cx - 1, yb - 72, yb - 28, L.timber.hi)
  local tw = HP.mask()
  for k = -3, 3 do tw:add(line({ { cx, yb - 72 }, { cx + k * 2, yb - 80 + math.abs(k) } }, 1)) end
  fill(tw, L.redbark.shade) tw:each(function(x, y) if hash(x, y, 106) < .4 then px(x, y, L.redbark.deep) end end)
  for _, a in ipairs({ { { cx - 1, yb - 73 }, { cx - 6, yb - 77 }, { cx - 8, yb - 83 } }, { { cx, yb - 73 }, { cx + 5, yb - 77 }, { cx + 7, yb - 83 } },
    { { cx - 5, yb - 77 }, { cx - 9, yb - 78 } }, { { cx + 5, yb - 77 }, { cx + 9, yb - 78 } } }) do
    fill(line(a, 1), BONE.base)
  end
  for k = 0, 3 do hline(cx - 1, cx, yb - 66 + k * 9, L.accent.base) px(cx - 2, yb - 65 + k * 9, L.accent.shade) end
  ribbon(cx + 1, yb - 66, 9, L.accent, 1) ribbon(cx - 3, yb - 57, 7, L.awnB, -1) ribbon(cx + 1, yb - 48, 8, GREENR, 1) ribbon(cx - 3, yb - 40, 6, L.accent, -1)
  -- prayer-flag lines fanning out from the pole top to stakes in the snow
  stake(8, 130, 8) stake(88, 132, 9) stake(22, 144, 7) stake(74, 146, 7)
  flagLine(cx, yb - 70, 9, 122, 4, 5, 3, 0)
  flagLine(cx, yb - 70, 88, 123, 4, 5, 3, 2)
  flagLine(cx, yb - 66, 23, 137, 3, 6, 3, 1)
  flagLine(cx, yb - 66, 74, 139, 3, 6, 3, 3)
end
ovoo(48, 134)
-- little offering cairns around it
F.cairn(82, 140, 10, 3) F.cairn(16, 140, 8, 7)
F.willow(104, 132, 5, 4, 3)

---------------------------------------------------------------- road's end: terrace, steps, the sod chapel
F.depth(2)
F.tree(176, 128, 60, 1)
F.tree(304, 128, 40, 0)
local terr = poly{ { 188, 126 }, { 292, 126 }, { 288, 112 }, { 192, 112 } }
F.shadow(190, 292, 128, 8, 3)
rimOf(terr, L.stone) part(terr, L.stone) F.rubble(terr, L.stone, 112, 5, 107)
F.snowCap(terr, 2, 108, { cx = 236 })
for k = 0, 4 do
  local y = 124 - k * 3
  local m = rect(228 + k, y, 252 - k, y + 2)
  fill(m, L.road.base) hline(228 + k, 252 - k, y, S.hi) hline(228 + k, 252 - k, y + 2, L.road.deep)
  for x = 229 + k, 251 - k do if hash(x, y, 109) < .3 then px(x, y + 1, S.base) end end
end
local function chapel()
  local outer = poly{ { 184, 94 }, { 240, 48 }, { 296, 94 } }
  local gable = poly{ { 204, 93 }, { 240, 64 }, { 276, 93 } }
  local roofM = outer:copy():cut(gable)
  local wall = rect(204, 92, 276, 112)
  local antl = HP.mask()
  for _, a in ipairs({ { { 239, 50 }, { 234, 44 }, { 230, 36 }, { 233, 30 } }, { { 241, 50 }, { 246, 44 }, { 250, 36 }, { 247, 30 } },
    { { 234, 44 }, { 228, 42 } }, { { 231, 38 }, { 226, 35 } }, { { 246, 44 }, { 252, 42 } }, { { 249, 38 }, { 254, 35 } }, { { 236, 47 }, { 236, 42 } }, { { 244, 47 }, { 244, 42 } } }) do
    antl:add(line(a, 1))
  end
  rimOf(union(roofM, gable, wall, antl), L.timber)
  -- herringbone turf wall: rows of slanted sod blocks, alternating direction, a stone course at the foot
  part(wall, L.roof, { nopop = true })
  wall:each(function(x, y)
    local row = (y - 92) // 4
    local ry = (y - 92) % 4
    local d = (row % 2 == 0) and 1 or -1
    local h
    if y >= 108 then
      local v = hash(x // 5, y // 4, 110)
      h = (y - 108) % 4 == 0 and L.stone.deep or (v < .4 and L.stone.base or (v < .8 and L.stone.shade or L.stone.hi))
      if (x + (y // 4) * 3) % 6 == 0 then h = L.stone.deep end
    elseif ry == 3 then h = L.roof.deep
    else
      local u = (x + d * ry) % 4
      h = u == 0 and L.roof.deep or (u == 1 and (x < 240 and L.roof.hi or L.roof.base) or (hash(x, y, 111) < .25 and L.greyMoss.base or L.roof.base))
      if x > 262 and u == 2 then h = L.roof.shade end
    end
    px(x, y, h)
  end)
  -- driftwood gable boards
  part(gable, L.timber, { nopop = true })
  F.planks(gable, L.timber, 3, true, 112)
  gable:each(function(x, y) if x > 250 and hash(x, y, 113) < .35 then px(x, y, L.timber.shade) end end)
  -- a round lamp-lit window high in the gable, a carved sun disc under it
  local win = c:ellipse(240, 76, 3, 3)
  c:rim(win, L.timber.edge) fill(win, L.glow.base) px(239, 75, L.glow.hi) px(238, 76, L.glow.hi) px(242, 78, L.glow.shade)
  vline(240, 73, 79, L.timber.deep) hline(237, 243, 76, L.timber.deep)
  hline(206, 274, 93, L.timber.edge) hline(206, 274, 94, L.timber.deep)
  -- sod roof rakes, snow cap, grass fringe hanging over the gable, icicles at the eave tips
  part(roofM, L.roof, { sep = true })
  F.sod(roofM, L.roof, 48, 238)
  F.snowCap(roofM, 4, 114, { cx = 238, lip = true })
  roofM:each(function(x, y)
    if gable:has(x, y + 1) and hash(x, y, 115) < .55 then px(x, y + 1, L.fern.shade) if hash(x, y, 116) < .4 then px(x, y + 2, L.fern.deep) end end
  end)
  F.icicles(184, 205, 95, 5, 117, .6) F.icicles(275, 296, 95, 5, 118, .6)
  -- antlers on the apex
  fill(antl, BONE.base) antl:each(function(x, y) if x > 240 and hash(x, y, 119) < .6 then px(x, y, BONE.shade) end if y < 34 then px(x, y, BONE.hi) end end)
  px(233, 30, S.hi) px(247, 30, S.base)
  -- small windows in the turf
  F.window(211, 98, 217, 104, L.timber) F.window(263, 98, 269, 104, L.timber)
  -- open door: plank leaves swung out, lamp-lit altar inside with a stone figure and candles
  local dl = rect(226, 96, 230, 112) local dr = rect(250, 96, 254, 112)
  for _, d in ipairs({ dl, dr }) do part(d, L.board, { nopop = true }) c:edgeIn(d, L.board.deep) end
  for _, x in ipairs({ 227, 251 }) do hline(x, x + 3, 99, L.iron.deep) hline(x, x + 3, 108, L.iron.deep) end
  fill(rect(231, 96, 249, 112), L.soil.deep)
  fill(rect(233, 99, 247, 111), L.soil.shade)
  fill(rect(235, 101, 245, 109), L.glow.deep) fill(rect(237, 102, 243, 107), L.glow.shade)
  F.sprite({ "..s..", ".sss.", "..s..", ".sss.", "sssss" }, 238, 102, { s = L.stone.shade }, { rim = false }) -- a tiny cairn idol
  px(240, 102, L.stone.hi) px(239, 104, L.stone.hi)
  for _, x in ipairs({ 233, 235, 245, 247 }) do candle(x, 108 + (x % 2), 3) end
  hline(228, 252, 95, L.timber.base) hline(228, 252, 94, S.hi)
  glowSpill(240, 105, 8, .35)
  -- offering box
  local box = rect(232, 107, 248, 112) rimOf(box, L.timber) part(box, L.timber) for x = 234, 246, 3 do px(x, 108, L.timber.deep) end
  hline(232, 248, 106, S.base)
  -- bronze bell hung from the lintel, red rope
  vline(240, 96, 104, RED.base) vline(241, 97, 104, RED.shade)
  local bell = c:ellipse(240, 97, 2, 2) fill(bell, BRONZE.base) px(239, 96, BRONZE.hi) px(241, 98, BRONZE.deep)
  -- candles on the terrace foot, light spilling on the snow
  for x = 212, 225, 3 do candle(x, 129 - (x % 2), 2 + (x % 3)) end
  for x = 256, 269, 3 do candle(x, 129 - (x % 2), 2 + (x % 3)) end
  glowSpill(218, 127, 6, .3) glowSpill(262, 127, 6, .3)
  -- prayer-flag lines from the apex to the flanking spruce and the bell frame
  flagLine(238, 46, 177, 70, 2, 5, 3, 0)
  flagLine(242, 46, 310, 68, 4, 5, 3, 2)
end
chapel()

---------------------------------------------------------------- right back: the ribboned old larch + bell frame
local function sacredTree()
  local x, yb, seed = 410, 162, 41
  F.shadow(392, 434, 162, 10, 4)
  local trunk = poly{ { 396, 162 }, { 402, 156 }, { 404, 132 }, { 403, 110 }, { 416, 110 }, { 415, 132 }, { 417, 156 }, { 424, 162 } }
  local limbs, twigs = HP.mask(), HP.mask()
  local tips = {}
  local function br(x0, y0, ang, len, d)
    local x1, y1 = x0 + cos(ang) * len, y0 - sin(ang) * len
    local w = d == 1 and 3 or (d == 2 and 2 or 1)
    local l = line({ { floor(x0 + .5), floor(y0 + .5) }, { floor(x1 + .5), floor(y1 + .5) } }, w)
    if d <= 2 then limbs:add(l) else twigs:add(l) end
    if d == 3 then tips[#tips + 1] = { floor(x1 + .5), floor(y1 + .5) } end
    if d < 5 and len > 3 then
      local k = 2 + (hash(d, floor(x1), seed) < .4 and 1 or 0)
      for j = 1, k do
        local da = (j - (k + 1) / 2) * (.5 + .25 * hash(j, d, seed)) + (hash(j, floor(y1), seed) - .5) * .35
        br(x1, y1, ang + da, len * (.62 + .1 * hash(j, d + 9, seed)), d + 1)
      end
    end
  end
  br(406, 114, pi / 2 + .62, 28, 1)
  br(413, 114, pi / 2 - .58, 30, 1)
  br(409, 112, pi / 2 + .05, 24, 1)
  br(404, 128, pi / 2 + 1.25, 18, 2)
  br(415, 126, pi / 2 - 1.2, 18, 2)
  twigs:cut(limbs):cut(trunk)
  rimOf(union(trunk, limbs), L.timber)
  part(trunk, L.timber)
  trunk:each(function(xx, yy)
    if hash(xx, yy // 3, 42) < .22 then px(xx, yy, L.timber.deep) elseif xx < 407 and hash(xx, yy // 2, 43) < .45 then px(xx, yy, L.timber.hi) end
    if xx > 413 and hash(xx, yy, 44) < .5 then px(xx, yy, L.timber.shade) end
    if yy > 150 and hash(xx // 2, yy, 45) < .3 then px(xx, yy, L.lichen.base) end
  end)
  part(limbs, L.timber, { nopop = true })
  twigs:each(function(xx, yy) px(xx, yy, hash(xx, yy, 46) < .5 and L.redbark.shade or L.redbark.deep) end)
  twigs:each(function(xx, yy) if not twigs:has(xx, yy - 1) and hash(xx, yy, 47) < .2 then px(xx, yy - 1, L.redbark.base) end end)
  union(limbs, trunk):each(function(xx, yy)
    if not limbs:has(xx, yy - 1) and not trunk:has(xx, yy - 1) and hash(xx, yy, 48) < .7 then px(xx, yy - 1, xx < 410 and S.hi or S.base) end
  end)
  -- roped trunk, ribbon knots
  for xx = 403, 416 do px(xx, 136 + (xx - 403) // 6, ROPE.shade) px(xx, 137 + (xx - 403) // 6, (xx % 3 == 0) and ROPE.hi or ROPE.base) px(xx, 138 + (xx - 403) // 6, ROPE.deep) end
  ribbon(405, 139, 8, L.awnB, -1) ribbon(412, 140, 10, L.accent, 1)
  -- ribbons tied all over the boughs
  table.sort(tips, function(a, b) return a[1] * 1000 + a[2] < b[1] * 1000 + b[2] end)
  local n = 0
  for i, t in ipairs(tips) do
    if hash(t[1], t[2], 49) < .7 then
      n = n + 1
      ribbon(t[1], t[2], 5 + floor(hash(i, 1, 50) * 6), RIB[n % #RIB + 1], (n % 2 == 0) and 1 or -1)
    end
  end
  F.drift(410, 163, 18, 3, 51)
  -- two redpolls (red caps) in the twigs
  for _, p in ipairs({ { 382, 98 }, { 436, 92 } }) do
    F.sprite({ "...rrr....", "..bbrrb...", "yEbbbbbb..", ".pppbbbbtt", ".pwwwbbbtt", "..wwwwbt..", "....k.k..." }, p[1], p[2],
      { r = RED.base, k = L.timber.edge, E = L.timber.edge, y = L.gold.base, b = L.deer.hi, p = L.petal.base, w = L.fur.hi, t = L.deer.deep })
  end
end
local function bellFrame(x0, yb)
  local posts = rect(x0, yb - 34, x0 + 2, yb):add(rect(x0 + 30, yb - 34, x0 + 32, yb))
  local roofm = poly{ { x0 - 8, yb - 34 }, { x0 + 4, yb - 44 }, { x0 + 28, yb - 44 }, { x0 + 40, yb - 34 }, { x0 + 38, yb - 31 }, { x0 - 6, yb - 31 } }
  local bm = poly{ { x0 + 11, yb - 28 }, { x0 + 21, yb - 28 }, { x0 + 23, yb - 12 }, { x0 + 9, yb - 12 } }:add(c:rrect(x0 + 11, yb - 31, x0 + 21, yb - 25, 3))
  F.shadow(x0, x0 + 34, yb, 8, 3)
  rimOf(union(posts, roofm, bm), L.timber)
  part(posts, L.timber, { nopop = true })
  part(roofm, L.roof) F.sod(roofm, L.roof, yb - 44, x0 + 14) hline(x0 - 6, x0 + 38, yb - 31, L.timber.deep)
  F.snowCap(roofm, 3, 52, { cx = x0 + 14, lip = true })
  F.icicles(x0 - 6, x0 + 38, yb - 30, 4, 53, .5)
  part(bm, BRONZE)
  hline(x0 + 10, x0 + 22, yb - 20, BRONZE.deep) hline(x0 + 9, x0 + 23, yb - 13, BRONZE.deep)
  for y = yb - 27, yb - 22, 2 do for x = x0 + 13, x0 + 19, 2 do px(x, y, BRONZE.hi) end end
  bm:each(function(x, y) if y > yb - 20 and hash(x, y, 54) < .12 then px(x, y, GREENR.shade) end end)
  hline(x0 + 12, x0 + 20, yb - 31, S.hi)
  local log = rect(x0 + 24, yb - 22, x0 + 38, yb - 19) rimOf(log, L.timber) part(log, L.board, { nopop = true }) F.logEnd(x0 + 38, yb - 21, 2)
  hline(x0 + 25, x0 + 37, yb - 23, S.base)
  vline(x0 + 27, yb - 31, yb - 23, L.timber.edge) vline(x0 + 35, yb - 31, yb - 23, L.timber.edge)
  F.drift(x0 + 18, yb + 1, 16, 2, 55)
end
sacredTree()
bellFrame(300, 140)
local _, rx, ry = F.gnome(352, 142, { hat = L.lav, coat = L.wall2, arm = "up", flip = true })
line({ { rx, ry }, { 337, 121 } }):each(function(x, y) px(x, y, L.timber.edge) end)

---------------------------------------------------------------- the cairn-pillar gate over the road
local function gateCairns()
  local mL, rowsL = stack(206, 119, 199, 5, 61)
  local mR, rowsR = stack(274, 119, 199, 5, 62)
  local kasagi = poly{ { 184, 109 }, { 194, 113 }, { 286, 113 }, { 296, 109 }, { 294, 118 }, { 186, 118 } }
  local nuki = rect(194, 132, 286, 135)
  local plaque = rect(233, 121, 247, 130)
  F.shadow(200, 282, 199, 10, 4)
  -- the lower rail first; the pillars stand over it
  rimOf(nuki, L.timber) part(nuki, L.timber, { nopop = true })
  nuki:each(function(x, y) if hash(x // 4, y, 63) < .2 then px(x, y, L.timber.shade) end end)
  hline(195, 285, 132, S.hi) F.logEnd(194, 133, 2) F.logEnd(286, 133, 2)
  paintStack(mL, rowsL, 205, 64)
  paintStack(mR, rowsR, 273, 65)
  -- the driftwood lintel: bleached log, cracks, snow on top with a lip, icicles under
  rimOf(kasagi, L.timber) part(kasagi, L.timber, { nopop = true })
  kasagi:each(function(x, y)
    if y == 115 and hash(x // 5, 1, 66) < .6 then px(x, y, L.timber.deep) end
    if hash(x // 3, y, 67) < .1 then px(x, y, L.timber.hi) end
    if x > 280 and y > 114 then px(x, y, L.timber.shade) end
  end)
  hline(186, 294, 118, L.timber.deep)
  F.snowCap(kasagi, 3, 68, { cx = 236, lip = true })
  F.icicles(188, 292, 119, 5, 69, .5)
  -- carved bone plaque on two cords: a sun over three aurora waves
  vline(236, 119, 120, ROPE.deep) vline(244, 119, 120, ROPE.deep)
  rimOf(plaque, L.timber) part(plaque, BONE, { nopop = true }) c:edgeIn(plaque, BONE.shade)
  fill(c:ellipse(240, 124, 1, 1), L.gold.shade)
  for k = 0, 1 do for x = 235, 245 do if (x + k) % 4 < 2 then px(x, 127 + k, k == 0 and GREENR.shade or L.lav.shade) end end end
  -- prayer ribbons hanging off the lower rail over the road, and tied round the pillars
  local i = 0
  for x = 214, 266, 3 do
    i = i + 1
    ribbon(x, 136, 4 + floor(hash(x, 1, 70) * 7), RIB[i % #RIB + 1], (i % 2 == 0) and 1 or -1)
  end
  for j, p in ipairs({ { 206, 148 }, { 206, 170 }, { 274, 152 }, { 274, 176 } }) do
    local r = RIB[j % #RIB + 1]
    hline(p[1] - 6, p[1] + 6, p[2], r.base) hline(p[1] - 6, p[1] + 6, p[2] + 1, r.shade)
    ribbon(p[1] + (j % 2 == 0 and 5 or -6), p[2] + 2, 7, r, j % 2 == 0 and 1 or -1)
  end
  F.drift(206, 201, 10, 2, 71) F.drift(276, 201, 10, 2, 72)
end

---------------------------------------------------------------- snow-capped stone lantern, scaled by depth, lamp-lit
local function toro(x, yb, s)
  local function R(a, b, cc, d) return rect(floor(x + a * s), floor(yb + b * s), floor(x + cc * s), floor(yb + d * s)) end
  local base = R(-5, -3, 5, 0)
  local post = R(-2, -14, 2, -3)
  local fire = R(-5, -21, 5, -14)
  local cap = poly{ { x - 8 * s, yb - 21 * s }, { x - 3 * s, yb - 26 * s }, { x + 3 * s, yb - 26 * s }, { x + 8 * s, yb - 21 * s }, { x + 7 * s, yb - 20 * s }, { x - 7 * s, yb - 20 * s } }
  local knob = R(-1, -29, 1, -26)
  F.shadow(floor(x - 4 * s), floor(x + 5 * s), yb, floor(5 * s), floor(2 * s))
  rimOf(union(base, post, fire, cap, knob), L.stone)
  part(base, L.stone) part(post, L.stone, { nopop = true }) part(fire, L.stone, { sep = true })
  local win = R(-2, -19, 2, -16) fill(win, L.glow.base) px(floor(x - 2 * s), floor(yb - 19 * s), L.glow.hi)
  win:each(function(xx, y) if not win:has(xx + 1, y) or not win:has(xx, y + 1) then px(xx, y, L.glow.shade) end end)
  part(cap, L.stone, { sep = true }) part(knob, L.stone, { nopop = true })
  base:each(function(xx, y) if hash(xx, y, 73) < .15 then px(xx, y, L.lichen.base) end end)
  F.snowCap(union(cap, knob), s > 1 and 3 or 2, floor(x), { cx = x, lip = s > .6 })
  F.snowCap(base, 1, floor(x) + 1)
  if s >= 1 then F.icicles(floor(x - 7 * s), floor(x + 7 * s), floor(yb - 19 * s), 3, floor(x), .4) end
  if s >= .7 then glowSpill(x, floor(yb - 17 * s), floor(5 * s), .28) end
end

---------------------------------------------------------------- left hero: the warm-spring basin under a sod shelter
local function basinShelter()
  local x0, x1, yt, yb = 96, 184, 150, 214
  local posts = rect(x0 + 6, yt + 8, x0 + 9, yb):add(rect(x1 - 9, yt + 8, x1 - 6, yb))
  F.shadow(x0 + 6, x1, yb, 12, 5)
  rimOf(posts, L.timber) part(posts, L.timber, { nopop = true })
  posts:each(function(x, y) if hash(x, y // 3, 74) < .2 then px(x, y, L.timber.deep) end end)
  -- sod roof: a low-pitched turf slab with a front fascia board, thick snow, icicles
  local roofm = poly{ { x0 - 8, yt + 6 }, { x0 + 14, yt - 16 }, { x1 - 14, yt - 16 }, { x1 + 8, yt + 6 } }
  local fascia = rect(x0 - 8, yt + 6, x1 + 8, yt + 9)
  rimOf(union(roofm, fascia), L.timber)
  part(roofm, L.roof, { sep = true }) F.sod(roofm, L.roof, yt - 16, 136)
  part(fascia, L.timber, { nopop = true }) F.planks(fascia, L.timber, 9, true, 75)
  F.snowCap(roofm, 5, 76, { cx = 134, lip = true })
  roofm:each(function(x, y) if fascia:has(x, y + 1) and hash(x, y, 77) < .5 then px(x, y + 1, L.fern.shade) end end)
  F.icicles(x0 - 7, x1 + 7, yt + 10, 6, 78, .55)
  -- the carved gable board: a reindeer
  local tri = poly{ { 126, yt - 16 }, { 140, yt - 26 }, { 154, yt - 16 } }
  rimOf(tri, L.timber) fill(tri, L.board.base) c:edgeIn(tri, L.board.deep) F.snowCap(tri, 2, 79, { cx = 139 })
  F.sprite({ "k.k..", ".kk..", ".kkkk", ".k..k" }, 138, yt - 21, { k = L.wall2.shade }, { rim = false })
  -- rubble-stone basin, frosted rim, warm green-blue water, steam
  local front = rect(112, 190, 168, 208)
  local topm = poly{ { 108, 190 }, { 172, 190 }, { 168, 182 }, { 112, 182 } }
  rimOf(union(front, topm), L.stone)
  part(front, L.stone) F.rubble(front, L.stone, 190, 6, 80)
  part(topm, L.stone, { sep = true })
  hline(109, 171, 190, S.hi) hline(113, 167, 182, S.base)
  local wat = poly{ { 114, 188 }, { 166, 188 }, { 163, 184 }, { 117, 184 } } F.water(wat, GREENR, { step = 2 })
  wat:each(function(x, y) if hash(x, y, 81) < .2 then px(x, y, L.water.base) end end)
  -- ice glaze on the basin face where it overflowed
  for x = 114, 166 do if hash(x, 1, 82) < .3 then local len = 1 + floor(hash(x, 2, 82) * 5) for k = 0, len do px(x, 191 + k, k == len and L.ice.deep or L.ice.base) end end end
  -- mossy rock spring with a driftwood spout, icicles on the spout, a trickle
  F.snowCap(F.rock(178, 190, 9, 14), 3, 83, { lip = true })
  local sp = rect(148, 168, 176, 171)
  rimOf(sp, L.timber) part(sp, L.timber, { nopop = true }) hline(149, 175, 169, L.water.base) hline(149, 175, 168, S.base)
  F.logEnd(148, 170, 2)
  F.icicles(150, 175, 172, 4, 84, .5)
  vline(148, 172, 184, L.water.hi) vline(149, 173, 184, L.water.base)
  px(147, 184, L.water.hi) px(151, 184, L.water.hi)
  vline(164, 172, 181, L.timber.base) vline(165, 172, 181, L.timber.deep)
  -- horn ladles laid across
  for k = 0, 2 do
    local lx = 118 + k * 10
    fill(line({ { lx, 181 }, { lx + 10, 178 } }), BONE.base)
    local cup = rect(lx - 2, 180, lx + 1, 183) fill(cup, L.soil.base) px(lx - 2, 180, L.soil.hi) px(lx, 182, L.soil.deep)
  end
  for _, st in ipairs({ { 124, 182, 7, .4, 11 }, { 144, 181, 8, .6, 12 }, { 160, 182, 6, .3, 13 } }) do
    local x, y, n, dr, sd = st[1], st[2], st[3], st[4], st[5]
    for i = 0, n - 1 do
      local cx = x + floor(dr * i * 1.4 + 2 * sin(i * 1.1 + sd))
      local cy = y - i * 3
      local w = 2 + (i % 3) + floor(i / 3)
      for xx = cx - w, cx + w do
        local a = hash(xx, cy, sd)
        if a < .85 - i * .05 then px(xx, cy, i % 2 == 0 and "#c4cce2" or "#d4d9ec") end
        if hash(xx, cy - 1, sd) < .55 - i * .05 and math.abs(xx - cx) < w - 1 then px(xx, cy - 1, "#f4f6fa") end
      end
      px(cx + w + 1, cy + 1, "#a0a8c8")
    end
  end
  -- a snow bunting on the basin rim
  F.sprite({ "...cc..", "..cWWk.", "WWWWWb.", "KWWKWW.", ".KKWW..", "..o.o.." }, 158, 177,
    { W = L.fur.hi, c = L.board.hi, k = L.timber.edge, b = L.gold.shade, K = L.timber.edge, o = L.timber.deep })
end

---------------------------------------------------------------- right hero: the offering rack (bone plaques, ribbons)
local function offerRack()
  local x0, x1, yt, yb = 300, 384, 160, 214
  local posts = rect(x0, yt, x0 + 3, yb):add(rect(x1 - 3, yt, x1, yb))
  local roofm = poly{ { x0 - 6, yt }, { x0 + 4, yt - 8 }, { x1 - 4, yt - 8 }, { x1 + 6, yt }, { x1 + 4, yt + 3 }, { x0 - 4, yt + 3 } }
  local rails = rect(x0, 172, x1, 173):add(rect(x0, 190, x1, 191))
  F.shadow(x0, x1, yb, 12, 4)
  rimOf(union(posts, roofm, rails), L.timber)
  part(posts, L.timber, { nopop = true }) part(rails, L.timber, { nopop = true, noshade = true })
  hline(x0, x1, 172, S.hi) hline(x0, x1, 190, S.base)
  part(roofm, L.roof) F.sod(roofm, L.roof, yt - 8, 330) hline(x0 - 4, x1 + 4, yt + 3, L.timber.deep)
  F.snowCap(roofm, 4, 85, { cx = 336, lip = true })
  F.icicles(x0 - 4, x1 + 4, yt + 4, 5, 86, .5)
  local cols = { L.accent, RED, GREENR, L.lav, L.wall2 }
  for row = 0, 1 do
    local yy = row == 0 and 174 or 192
    for k = 0, 9 do
      local x = x0 + 5 + k * 8 + (row == 1 and 3 or 0)
      if x + 6 < x1 - 3 then
        if row == 1 and k % 3 ~= 1 then
          for j = 0, 2 do ribbon(x + j * 2, yy, 7 + (j + k) % 4, RIB[(k + j) % #RIB + 1]) end
        else
          local m = poly{ { x, yy + 2 }, { x + 3, yy }, { x + 6, yy + 2 }, { x + 6, yy + 9 }, { x, yy + 9 } }
          c:rim(m, L.board.edge) fill(m, BONE.hi) hline(x, x + 6, yy + 9, BONE.shade) vline(x + 6, yy + 2, yy + 9, BONE.base)
          local cr = cols[(k + row * 2) % 5 + 1]
          if k % 3 == 0 then -- a little reindeer
            px(x + 1, yy + 3, cr.shade) px(x + 2, yy + 4, cr.base) hline(x + 2, x + 5, yy + 5, cr.base) px(x + 2, yy + 7, cr.shade) px(x + 5, yy + 7, cr.shade)
          elseif k % 3 == 1 then -- a sun
            px(x + 3, yy + 5, cr.base) px(x + 2, yy + 5, cr.shade) px(x + 4, yy + 5, cr.shade) px(x + 3, yy + 4, cr.shade) px(x + 3, yy + 6, cr.shade)
          else -- an aurora wave
            px(x + 1, yy + 5, cr.base) px(x + 2, yy + 4, cr.base) px(x + 3, yy + 5, cr.base) px(x + 4, yy + 4, cr.base) px(x + 5, yy + 5, cr.base)
            px(x + 2, yy + 7, cr.shade) px(x + 4, yy + 7, cr.shade)
          end
          px(x + 3, yy + 1, RED.base)
        end
      end
    end
  end
  F.drift(306, 216, 8, 2, 87) F.drift(380, 216, 8, 2, 88)
end
local function fox(x, yb, flip, bare)
  local s = flip and -1 or 1
  local r = L.stone
  local body = poly{ { x - 4 * s, yb }, { x - 4 * s, yb - 10 }, { x - 2 * s, yb - 14 }, { x + 3 * s, yb - 14 }, { x + 4 * s, yb } }
  local head = poly{ { x - 3 * s, yb - 14 }, { x - 3 * s, yb - 20 }, { x - 1 * s, yb - 18 }, { x + 2 * s, yb - 18 }, { x + 3 * s, yb - 21 }, { x + 4 * s, yb - 16 }, { x + 7 * s, yb - 15 }, { x + 3 * s, yb - 13 } }
  local tail = line({ { x - 4 * s, yb - 2 }, { x - 8 * s, yb - 6 }, { x - 7 * s, yb - 12 } }, 3)
  local m = union(body, head, tail)
  rimOf(m, r) part(m, r)
  px(x + 1 * s, yb - 16, r.edge) px(x + 7 * s, yb - 15, L.timber.edge)
  m:each(function(xx, y) if hash(xx // 2, y // 2, 89) < .1 then px(xx, y, L.lichen.base) end end)
  F.snowCap(m, 1, x, { cx = x })
  if not bare then local bib = poly{ { x - 3 * s, yb - 13 }, { x + 3 * s, yb - 13 }, { x, yb - 8 } } fill(bib, RED.base) px(x, yb - 12, RED.hi) end
end
local function plinth(x, yb, w, h)
  local m = rect(x - w, yb - h, x + w, yb) rimOf(m, L.stone) part(m, L.stone) hline(x - w, x + w, yb - h, L.stone.hi)
  m:each(function(xx, y) if hash(xx, y, 90) < .1 then px(xx, y, L.lichen.base) end end)
  F.snowCap(m, 2, x, { cx = x, lip = true })
end

---------------------------------------------------------------- raked snow garden ringed with stones (bottom-left)
local function snowGarden()
  local g = poly{ { 20, 230 }, { 150, 226 }, { 162, 264 }, { 20, 266 } }
  local edge = g:grow(3):cut(g)
  edge:each(function(x, y)
    local cx, cy = x // 4, y // 3
    local v = hash(cx, cy, 91)
    local h = v < .3 and L.stone.hi or (v < .7 and L.stone.base or L.stone.shade)
    if x % 4 == 0 or y % 3 == 0 then h = L.stone.deep end
    if not edge:has(x, y - 1) and not g:has(x, y - 1) then h = x < 90 and S.hi or S.base end
    if hash(x, y, 92) < .05 then h = L.lichen.base end
    px(x, y, h)
  end)
  g:each(function(x, y) px(x, y, S.base) end)
  local rocks = { { 56, 246, 10 }, { 120, 248, 8 } }
  g:each(function(x, y)
    local best = 1e9
    for _, r in ipairs(rocks) do best = math.min(best, math.sqrt(((x - r[1]) / 1.6) ^ 2 + ((y - r[2])) ^ 2) - r[3] * .55) end
    local k
    if best < 14 then k = floor(best) % 3 else k = (y + floor(sin(x / 20) * 1.5)) % 3 end
    if k == 0 then px(x, y, S.shade) elseif k == 1 and hash(x, y, 93) < .6 then px(x, y, S.hi) end
  end)
  -- snow-capped boulders, sedge at the corners
  F.snowCap(F.rock(56, 250, 12, 12), 3, 94, { lip = true }) F.snowCap(F.rock(120, 251, 9, 9), 3, 95, { lip = true }) F.snowCap(F.rock(129, 252, 5, 5), 2, 96)
  F.shadowM(poly{ { 68, 250 }, { 80, 250 }, { 86, 254 }, { 70, 254 } }) F.shadowM(poly{ { 129, 251 }, { 138, 251 }, { 142, 254 }, { 130, 254 } })
  for _, f in ipairs({ { 18, 232, 6 }, { 24, 228, 5 }, { 160, 228, 6 }, { 166, 262, 7 } }) do F.fern(f[1], f[2], f[3]) end
  -- a pair of snow buntings on the big rock
  F.sprite({ "...cc..", "..cWWk.", "WWWWWb.", "KWWKWW.", ".KKWW..", "..o.o.." }, 50, 233,
    { W = L.fur.hi, c = L.board.hi, k = L.timber.edge, b = L.gold.shade, K = L.timber.edge, o = L.timber.deep })
end

---------------------------------------------------------------- compose
F.depth(3)
-- ember fire bowl on legs with peat smoke (left middle), a cairn beside it
do
  local legs = rect(54, 214, 55, 220):add(rect(66, 214, 67, 220))
  local bowl = c:rrect(50, 204, 71, 215, 4)
  F.shadow(52, 70, 220, 6, 2)
  rimOf(union(legs, bowl), L.timber)
  part(legs, L.iron, { nopop = true }) part(bowl, BRONZE)
  hline(50, 71, 208, BRONZE.deep) for x = 53, 68, 3 do px(x, 211, BRONZE.hi) end
  bowl:each(function(x, y) if y > 210 and hash(x, y, 97) < .15 then px(x, y, GREENR.shade) end end)
  -- glowing peat embers heaped in the bowl
  local emb = c:ellipse(61, 204, 8, 2):clip(rect(50, 201, 71, 205))
  emb:each(function(x, y) local v = hash(x, y, 98) px(x, y, v < .25 and L.glow.hi or (v < .6 and L.glow.base or (v < .85 and L.produce.base or L.soil.deep))) end)
  glowSpill(61, 204, 10, .3)
  F.smoke(61, 192, 7, -.3, 2)
  F.cairn(36, 222, 14, 9)
end
basinShelter()
offerRack()
for _, p in ipairs({ { 146, .5, 11 }, { 182, .7, 22 }, { 252, 1.3, 22 } }) do
  local y = p[1]
  toro(floor(F.xl(y)) - p[3], y, p[2])
  toro(floor(F.xr(y)) + p[3], y, p[2])
end
gateCairns()
plinth(194, 214, 7, 6) fox(194, 208, false)
plinth(291, 214, 14, 6) fox(283, 208, true, true)
-- quirk: a real arctic fox kit poses on the plinth beside the stone fox, wearing its red bib (the stone fox's neck is bare)
F.sprite({
  ".o....o........",
  ".oO..Oo........",
  ".OOOOOs........",
  "OOOOOOOs.......",
  "OeOOOeOs.......",
  "OOOnOOss.......",
  ".OOOOss........",
  "..OOss.....OO..",
  "..RRRRR...OOOs.",
  ".RRrRRRR..OOOs.",
  "..RRRRR...OOs..",
  "..OOOOs...Os...",
  "..OOOOOs..Os...",
  "..OOOOOsOOOs...",
  "..OOOOOssOss...",
  "..sOOOOsssss...",
  "..kk..kk.......",
}, 291, 191, { o = L.timber.edge, O = L.fur.hi, s = L.fur.shade, e = L.timber.edge, n = L.timber.edge, R = RED.base, r = RED.hi, k = L.fur.deep })
-- its little prints in the snow, off to the rack
for i = 0, 5 do px(306 + i * 5, 218 + (i % 2) * 2, S.shade) px(307 + i * 5, 219 + (i % 2) * 2, S.deep) end
snowGarden()
-- the right edge: snowy spruces, a bare birch, willow scrub
F.tree(452, 228, 70, 0)
F.conifer(424, 228, 32, L.foliage, 52)
F.birch(440, 230, 52, 53)
F.willow(410, 232, 8, 8, 54) F.willow(466, 230, 6, 7, 55)
-- a gnome sweeping snow off the path by the right lanterns, the little heap he has swept
F.drift(322, 245, 15, 7, 56)
local _, bx, by = F.gnome(348, 238, { hat = RED, coat = L.accent, flip = true, arm = "hold" })
fill(line({ { bx + 1, by - 6 }, { bx - 6, by + 6 } }, 1), L.timber.base)
local broom = poly{ { bx - 11, by + 6 }, { bx - 3, by + 6 }, { bx - 4, by + 10 }, { bx - 12, by + 10 } }
rimOf(broom, ROPE) part(broom, ROPE, { nopop = true }) for x = bx - 11, bx - 4, 2 do vline(x, by + 7, by + 10, ROPE.deep) end
for i = 0, 8 do px(bx - 14 - i * 2, by + 9 - (i % 2), S.hi) end
ribbon(316, 236, 3, L.gold, 1)
-- a gnome tying a ribbon on the rack
local _, ex, ey = F.gnome(392, 214, { hat = GREENR, coat = L.lav, arm = "up", flip = true })
ribbon(ex, ey - 1, 7, L.accent)
F.tracks({ { 404, 224 }, { 420, 236 } }, "boot", 5)
-- ravens on the lintel ends and birds over the chapel
F.depth(0)
F.sprite({ ".kk.", "kkkk", "kkkkk", ".y.." }, 196, 105, { k = "#3c3a48", y = L.gold.shade })
F.sprite({ "..kk", "kkkk", "kkkkk", ".y.y" }, 276, 105, { k = "#3c3a48", y = L.gold.shade })
F.sprite({ ".kk..", "kkkkk", "kkkk.", ".y..." }, 428, 107, { k = "#3c3a48", y = L.gold.shade })
F.birds({ { 330, 38, 2 }, { 342, 44, 1 }, { 150, 52, 2 }, { 160, 46, 1 } })
F.depth(3)
-- crowberries, lichen crumbs and lost ribbon scraps scattered in the snow
for i = 0, 50 do
  local x, y = 20 + floor(hash(i, 1, 77) * 440), 130 + floor(hash(i, 2, 77) * 130)
  if not (x > 378 and y > 228) and not F.roadM:has(x, y) then
    local k = i % 4
    if k == 0 then px(x, y, L.lav.deep) px(x + 1, y, L.lav.edge) px(x, y - 1, L.lav.base)
    elseif k == 1 then px(x, y, L.lichen.base) px(x + 1, y, L.lichen.shade)
    elseif k == 2 then px(x, y, L.rust.base) px(x, y + 1, L.rust.shade)
    else local r = RIB[i % #RIB + 1] px(x, y, r.base) px(x + 1, y + 1, r.shade) end
  end
end
F.finish()
