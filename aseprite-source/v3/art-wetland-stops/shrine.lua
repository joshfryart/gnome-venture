-- shrine.lua : "Wayside shrine" stop look, WETLAND (wetland_reed), 480x270 gate view.
-- Same composition as the Maplewold shrine (art-2701-batch3/stops/opus3/shrine.lua), re-cast for a reed fen:
-- road's end: a small daub chapel under a steep golden reed thatch with a dark sedge ridge cap, on a wattle-
-- revetted peat mound rising out of a still mere, candle-lit inside, lanterns floating on the mere behind it.
-- Over the causeway: a gate of grey bog-oak posts with a reed-thatched cap, a bound reed tie-beam and two hanging
-- lanterns; a grey heron stands on the cap. Back left: a three-tier stilted lantern tower over a pool. Right back:
-- the ancient roped pollard willow (a candle in its hollow, a heron on its nest) and a thatched bell frame.
-- Left hero: the spring pavilion on a boardwalk, a hollow bog-oak trough fed by an alder pipe. Right hero: the
-- offering rack of carved fish plaques and straw knots above a boardwalk laid with offerings. Bottom left: a still
-- mirror pool framed in planks, stepping stones, floating lanterns, a kingfisher. Lanterns on stakes along the
-- causeway, a peat brazier, bulrushes and flag irises, a heron in the reeds.
-- Quirk (kept, re-cast): stone otters guard the gate; a real otter pup sits beside the bare-headed right one,
-- wearing the left one's red knitted gnome hat.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-wetland-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "shrine", out = DIR, farTrees = { 24, 150, 300, 318, 352, 440 },
  treeLineGap = { 140, 340 }, poolK = .79 }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local RED, WB, TH, SC = L.awnA, L.willowBark, L.roof, L.roof2
local BRONZE = F.rp("#dcb878 #ae8a50 #82663c #5c482e #3a2e24")
local ROPE = F.rp("#ecd890 #ccb066 #a48848 #765e36 #4c3c26")
local BOG = F.rp("#8c7a66 #645648 #4a4038 #342e2a #221e1e")   -- black bog oak
local TAR = F.rp("#8a8c80 #64685e #4a4e48 #363a36 #24282a")
local RIB = { L.awnA, L.awnB, L.accent, L.gold, L.lav, L.petal }

---------------------------------------------------------------- local helpers
-- warm lantern-light spill: tint what is already there toward the glow (hard pixels, no alpha)
local function glowSpill(cx, cy, r, k)
  for y = cy - r, cy + r do for x = cx - r, cx + r do
    local d = math.sqrt((x - cx) ^ 2 + ((y - cy) * 1.4) ^ 2)
    if d <= r then local v = c:get(x, y) if v then px(x, y, F.mix(v, L.glow.hi, k * (1 - d / (r + 1)) + .04)) end end
  end end
end
-- a lantern's light broken into dashes on still water below it
local function glowReflect(x, y0, len, w)
  w = w or 1
  for k = 0, len do
    if k % 2 == 0 or k < 2 then
      local col = k < 2 and L.glow.base or (k < len * .6 and L.glow.shade or L.glow.deep)
      for d = 0, w - 1 do px(x + d, y0 + k, col) end
      if k < len // 2 and hash(x, k, 5) < .5 then px(x + w, y0 + k, L.glow.deep) end
    end
  end
end
local function candle(x, yb, h)
  h = h or 3
  vline(x, yb - h + 1, yb, L.awnB.hi) vline(x + 1, yb - h + 2, yb, L.awnB.shade)
  px(x, yb - h, L.glow.base) px(x, yb - h - 1, L.glow.hi)
end
local function ribbon(x, y, len, r, dir)
  dir = dir or 1
  for k = 0, len do
    local xx = x + ((k > len // 2) and dir or 0)
    px(xx, y + k, k == 0 and r.hi or r.base) px(xx + 1, y + k, k == len and r.deep or r.shade)
  end
end
local function zigzag(x, y) fill(line({ { x, y }, { x + 2, y + 2 }, { x, y + 4 }, { x + 2, y + 6 } }), L.awnB.hi) end

-- steep hipped reed thatch: eave x0..x1 at y (bottom), ridge rx0..rx1 at yt. A thick combed eave with a ragged
-- drip, lit left slope, a scalloped dark sedge ridge cap with hazel liggers (o.noCap drops it).
local function thatchRoof(x0, x1, y, rx0, rx1, yt, r, seed, o)
  o = o or {}
  local cx = (x0 + x1) // 2
  local m = poly{ { x0, y }, { x0 + 3, y - 5 }, { rx0, yt }, { rx1, yt }, { x1 - 3, y - 5 }, { x1, y }, { x1 - 2, y + 3 }, { x0 + 2, y + 3 } }
  rimOf(m, r) part(m, r, { sep = true })
  F.thatch(m, r, yt, cx)
  -- the sunlit left hip and a shaded right hip
  m:each(function(x, yy)
    if yy < y then
      local u = (x - cx) / math.max(1, (x1 - x0) / 2)
      if x < rx0 - (yy - yt) * .25 and hash(x, yy, seed) < .35 then px(x, yy, r.hi) end
      if u > .55 and hash(x, yy, seed + 1) < .45 then px(x, yy, r.deep) end
    end
  end)
  line({ { x0 + 1, y - 2 }, { rx0, yt + 1 } }):each(function(x, yy) if m:has(x, yy) then px(x, yy, r.hi) end end)
  -- thick eave lip, combed reed ends, ragged drip
  hline(x0 + 1, x1 - 1, y + 1, r.base) hline(x0 + 2, x1 - 2, y + 2, r.shade)
  for x = x0 + 2, x1 - 2 do
    if x % 2 == 0 then px(x, y + 1, r.hi) end
    px(x, y + 3, hash(x, y, seed + 2) < .55 and r.deep or r.edge)
    if hash(x, y, seed + 3) < .25 then px(x, y + 4, r.edge) end
  end
  F.moss(m, o.moss or .03, seed + 4)
  if not o.noCap then
    local rc = SC
    local cap = HP.mask()
    for x = rx0 - 3, rx1 + 3 do
      local bot = yt + 3 + ((x // 3) % 2)
      local top = (x < rx0 or x > rx1) and yt - 1 or yt - 3
      for yy = top, bot do cap:set(x, yy) end
    end
    rimOf(cap, rc)
    cap:each(function(x, yy)
      local h
      if not cap:has(x, yy - 1) then h = rc.hi elseif not cap:has(x, yy + 1) then h = rc.deep
      else h = (x < cx) and rc.base or rc.shade end
      if (x + yy) % 5 == 0 then h = rc.shade end
      px(x, yy, h)
    end)
    for x = rx0, rx1 - 4, 6 do px(x, yt - 1, L.timber.hi) px(x + 1, yt, L.timber.base) px(x + 2, yt + 1, L.timber.hi) px(x + 2, yt - 1, L.timber.base) px(x, yt + 1, L.timber.base) end
  end
  return m
end

-- a lantern box: a little thatch cap, a timber frame, glowing paper. (x, ytop) = centre top of the cap
local function lanternBox(x, ytop, w, h)
  local cap = poly{ { x - w - 2, ytop + 3 }, { x, ytop }, { x + w + 2, ytop + 3 } }
  local body = rect(x - w, ytop + 3, x + w, ytop + 3 + h)
  c:rim(union(cap, body), L.timber.edge)
  fill(cap, SC.base) hline(x - w - 1, x + w + 1, ytop + 3, SC.deep) px(x - 1, ytop + 1, SC.hi)
  fill(body, L.glow.base)
  fill(rect(x - w + 1, ytop + 4, x - 1, ytop + 2 + h), L.glow.hi)
  vline(x + w - 1, ytop + 4, ytop + 3 + h, L.glow.shade)
  vline(x - w, ytop + 3, ytop + 3 + h, L.timber.base) vline(x + w, ytop + 3, ytop + 3 + h, L.timber.deep)
  if w >= 3 then vline(x, ytop + 3, ytop + 3 + h, L.timber.base) end
  hline(x - w, x + w, ytop + 3 + h, L.timber.deep)
  return body
end
-- a lantern floating on a little reed raft, its light broken on the water. (x, y) = waterline
local function floatLantern(x, y, big)
  local w = big and 3 or 2
  hline(x - w - 1, x + w + 1, y, L.reed.base) hline(x - w, x + w, y + 1, L.reed.deep) px(x - w - 1, y, L.reed.hi)
  local bh = big and 4 or 2
  fill(rect(x - (big and 2 or 1), y - bh, x + (big and 2 or 1), y - 1), L.glow.base)
  px(x - (big and 2 or 1), y - bh, L.glow.hi) if big then px(x - 1, y - bh, L.glow.hi) px(x - 2, y - bh + 1, L.glow.hi) end
  vline(x + (big and 2 or 1), y - bh, y - 1, L.glow.shade)
  hline(x - (big and 2 or 1), x + (big and 2 or 1), y - bh - 1, SC.base)
  glowReflect(x - (big and 1 or 0), y + 2, big and 7 or 4, big and 2 or 1)
end

---------------------------------------------------------------- back: the mere behind the chapel, floating lanterns
F.depth(1)
local mere = poly{ { 128, 118 }, { 352, 117 }, { 360, 123 }, { 344, 131 }, { 300, 133 }, { 180, 133 }, { 136, 130 }, { 122, 124 } }
rimOf(mere, L.peat)
F.water(mere, L.water, { step = 3 })
F.reeds(118, 140, 126, 10, 11, { cattails = 2 })
F.reeds(338, 364, 125, 10, 12, { cattails = 1, green = true })
F.reeds(150, 172, 133, 7, 13)
F.reeds(312, 330, 134, 7, 14, { green = true })
for _, p in ipairs({ { 148, 125 }, { 168, 129 }, { 314, 124 }, { 334, 128 }, { 300, 130 } }) do floatLantern(p[1], p[2], false) end
F.mist(120, 170, 118, 121, 15, .4) F.mist(318, 366, 118, 121, 16, .4)

---------------------------------------------------------------- back-left: the stilted three-tier lantern tower
F.tree(92, 128, 46, 3)
F.tree(10, 132, 36, 1)
local function tower(cx, yb)
  local pool = poly{ { 12, 128 }, { 82, 125 }, { 90, 132 }, { 80, 141 }, { 22, 142 }, { 8, 136 } }
  rimOf(pool, L.peat)
  F.water(pool, L.water)
  F.water(pool:copy():clip(rect(20, 128, 80, 142)), L.water, { dark = true })
  for _, sx in ipairs({ 28, 38, 50, 60, 68 }) do for y = 135, 141, 2 do if pool:has(sx, y) then px(sx, y, L.water.deep) end end end
  F.stilts({ 28, 38, 50, 60, 68 }, 118, 138, 133)
  F.boardwalk(rect(22, 114, 76, 118), true, 41)
  hline(22, 76, 118, L.board.deep)
  local y = 114
  for i = 0, 2 do
    local w = 12 - i * 3
    local body = rect(cx - w, y - 10, cx + w, y - 1)
    rimOf(body, TAR) part(body, TAR) F.planks(body, TAR, 3, true, 40 + i)
    vline(cx - w, y - 10, y - 1, TAR.hi)
    F.window(cx - 1, y - 7, cx + 1, y - 4, L.timber, true)
    y = y - 10
    thatchRoof(cx - w - 8, cx + w + 8, y, cx - w + 2, cx + w - 2, y - 8, TH, 42 + i, { noCap = i < 2 })
    -- little lanterns hung at the eave corners
    for _, lx in ipairs({ cx - w - 7, cx + w + 7 }) do vline(lx, y + 4, y + 5, L.timber.edge) fill(rect(lx - 1, y + 6, lx + 1, y + 8), L.glow.base) px(lx - 1, y + 6, L.glow.hi) px(lx + 1, y + 8, L.glow.shade) end
    y = y - 8
  end
  -- a carved wooden heron on the top
  F.sprite({ ".kk.", "kkkb", ".k..", ".k..", ".kk.", "kkkk", ".kk.", "..k." }, cx - 2, y - 10, { k = L.timber.base, b = L.marigold.shade })
  vline(cx, y - 3, y, L.timber.deep)
  -- reflections of the lantern lights in the pool
  glowReflect(cx - 1, 134, 6, 2) glowReflect(cx - 19, 134, 4) glowReflect(cx + 18, 134, 4)
end
tower(48, 134)

---------------------------------------------------------------- road's end: the reed-thatched chapel on a wattle mound
F.depth(2)
F.tree(170, 128, 62, 1)
F.tree(310, 130, 60, 5)
local terr = poly{ { 186, 127 }, { 294, 127 }, { 291, 116 }, { 285, 112 }, { 195, 112 }, { 189, 116 } }
F.shadow(190, 292, 129, 8, 3)
rimOf(terr, L.peat)
terr:each(function(x, y)
  local col
  if y < 115 then col = (hash(x, y, 11) < .5) and L.sedgeGround.hi or L.sedgeGround.base
  else
    local k = (x - 186) % 7
    if k == 0 then col = WB.shade elseif k == 1 then col = WB.hi
    else
      local row = (y - 115) // 2
      local over = (((x - 186) // 7 + row) % 2) == 0
      col = (y % 2 == 0) and (over and L.reed.hi or L.reed.shade) or (over and L.reed.base or L.reed.deep)
      if x > 270 and hash(x, y, 12) < .3 then col = L.reed.shade end
    end
    if y >= 125 then col = (hash(x, y, 13) < .5) and L.peat.shade or L.moss.shade end
  end
  px(x, y, col)
end)
for x = 190, 290, 3 do if hash(x, 1, 14) < .7 then F.sedge(x, 114, 3 + floor(hash(x, 2, 14) * 3), hash(x, 3, 14) < .3 and L.reed or L.reedGreen) end end
-- plank steps up the middle
for k = 0, 4 do
  local y = 124 - k * 3
  local m = rect(228 + k, y, 252 - k, y + 2)
  fill(m, L.board.base) hline(228 + k, 252 - k, y, L.board.hi) hline(228 + k, 252 - k, y + 2, L.board.deep)
  px(228 + k, y + 1, L.timber.deep) px(252 - k, y + 1, L.timber.deep)
end
-- the chapel: daub walls between grey oak posts
local hall = rect(204, 88, 276, 112)
rimOf(hall, L.plaster) part(hall, L.plaster)
hall:each(function(x, y)
  local v = hash(x // 2, y // 2, 15)
  if v < .07 then px(x, y, L.plaster.hi) elseif v > .94 then px(x, y, L.plaster.shade) end
  if y > 108 and hash(x, y, 16) < .4 then px(x, y, L.plaster.shade) end
end)
for _, x in ipairs({ 204, 216, 228, 252, 264, 274 }) do fill(rect(x, 88, x + 2, 112), WB.base) vline(x, 88, 112, WB.hi) vline(x + 2, 88, 112, WB.shade) end
-- woven reed screens either side
for _, d in ipairs({ { 218, 226 }, { 254, 262 } }) do
  local m = rect(d[1], 96, d[2], 110)
  m:each(function(x, y)
    local over = (((x - d[1]) // 2 + (y - 96) // 2) % 2) == 0
    px(x, y, over and ((y % 2 == 0) and L.reed.hi or L.reed.base) or ((x % 2 == 0) and L.reed.shade or L.reed.deep))
  end)
  c:edgeIn(m, L.timber.deep)
end
-- the open middle bay: a candle-lit altar with a carved wooden heron
fill(rect(231, 96, 249, 112), L.soil.deep)
fill(rect(234, 100, 246, 110), L.soil.shade)
fill(rect(236, 101, 244, 108), L.glow.deep) fill(rect(238, 102, 242, 106), L.glow.shade)
F.sprite({ ".kk..", "kkkb.", "..k..", "..k..", ".kkk.", "kkkkk", "..k..", ".k.k." }, 238, 100, { k = L.timber.hi, b = L.marigold.base }, { rim = false })
for _, x in ipairs({ 233, 235, 245, 247 }) do candle(x, 105 + (x % 3), 3) end
glowSpill(240, 104, 8, .35)
local box = rect(232, 106, 248, 112) rimOf(box, L.timber) part(box, BOG) for x = 234, 246, 3 do px(x, 107, BOG.deep) end
-- the big steep reed thatch, a thatched porch hood over the bay
thatchRoof(186, 294, 87, 220, 260, 58, TH, 17, { moss = .04 })
local boss = c:ellipse(240, 76, 4, 4) rimOf(boss, L.timber) fill(boss, L.board.base) c:edgeIn(boss, L.board.shade) px(238, 74, L.board.hi) px(239, 74, L.board.hi)
F.sprite({ ".k.", "kbk", ".k." }, 239, 75, { k = L.timber.deep, b = L.marigold.base }, { rim = false })
-- carved bird finials at the ridge ends, and a wisp of candle smoke from the smoke hole
for _, e in ipairs({ { 217, -1 }, { 263, 1 } }) do
  F.sprite(e[2] < 0 and { "kk..", "kkk.", ".kkk", "..k." } or { "..kk", ".kkk", "kkk.", ".k.." }, e[1] - 2, 51, { k = L.timber.base })
end
-- bell rope and bell in the bay, straw rope with paper zigzags and reed tassels across the front
vline(240, 96, 104, RED.base) vline(241, 96, 104, L.awnB.base)
local bell = c:ellipse(240, 97, 2, 2) fill(bell, BRONZE.base) px(239, 96, BRONZE.hi) px(241, 98, BRONZE.deep)
for x = 206, 274 do
  local yy = 94 + floor(2 * sin((x - 206) / 68 * pi))
  px(x, yy, ROPE.shade) px(x, yy + 1, (x % 3 == 0) and ROPE.hi or ROPE.base)
end
for i, x in ipairs({ 210, 214, 222, 226, 254, 258, 266, 270 }) do
  local y = 97 + floor(2 * sin((x - 206) / 68 * pi))
  if i % 2 == 0 then zigzag(x, y) else
    vline(x, y, y + 4, L.reed.hi) vline(x + 1, y, y + 4, L.reed.shade) px(x, y + 5, L.plume.base) px(x + 1, y + 5, L.plume.shade) end
end
-- lanterns on short posts at the mound's front corners, and offerings of eggs and marigolds on the top
for _, lx in ipairs({ 196, 284 }) do
  vline(lx, 112, 117, L.timber.edge) vline(lx + 1, 112, 117, L.timber.base)
  lanternBox(lx, 103, 2, 5)
  glowSpill(lx, 108, 6, .28)
end
for _, p in ipairs({ { 208, 113 }, { 272, 113 } }) do
  hline(p[1] - 3, p[1] + 3, p[2], BOG.base) hline(p[1] - 2, p[1] + 2, p[2] + 1, BOG.deep)
  px(p[1] - 2, p[2] - 1, L.awnB.hi) px(p[1] - 1, p[2] - 1, L.awnB.base) px(p[1] + 1, p[2] - 1, L.marigold.base) px(p[1] + 2, p[2] - 1, L.marigold.hi) px(p[1], p[2] - 2, L.marigold.base)
end
-- a moorhen on the mere beside the mound
F.sprite({ ".kr", "kkk.", "kkkkk", "kwkkk." }, 176, 124, { k = "#3e3c44", r = RED.base, w = L.awnB.hi })

---------------------------------------------------------------- right back: the ancient roped pollard willow + bell frame
local function sacredWillow()
  F.shadow(386, 438, 162, 10, 4)
  local trunk = poly{ { 388, 162 }, { 396, 154 }, { 398, 130 }, { 393, 106 }, { 388, 98 }, { 398, 100 }, { 404, 94 }, { 412, 99 }, { 420, 93 }, { 426, 101 },
    { 432, 98 }, { 424, 108 }, { 421, 130 }, { 424, 154 }, { 434, 162 } }
  -- a fan of whippy shoots from the knuckled head up into the leaf clumps
  local shoots = HP.mask()
  for k = 0, 10 do
    local a = -pi / 2 + (k - 5) / 5 * 1.15
    local x0 = 392 + k * 3.6
    local len = 26 + floor(hash(k, 1, 30) * 18)
    shoots:add(line({ { x0, 100 }, { x0 + cos(a) * len, 100 + sin(a) * len } }, k % 3 == 0 and 2 or 1))
  end
  rimOf(union(trunk, shoots), WB)
  part(shoots, WB, { nopop = true, noshade = true })
  part(trunk, WB)
  trunk:each(function(x, y)
    if x < 398 and y > 104 then px(x, y, WB.hi) end
    local f = hash(floor(x + sin(y / 6) * 1.5), 0, 31)
    if f < .22 then px(x, y, WB.deep) elseif f > .9 then px(x, y, WB.hi) end
    if hash(x, y // 3, 32) < .08 then px(x, y, WB.edge) end
    if y > 150 and hash(x // 2, y, 33) < .35 then px(x, y, hash(x, y, 34) < .5 and L.moss.base or L.moss.shade) end
  end)
  -- the knuckled pollard head
  for _, k in ipairs({ { 392, 100, 3 }, { 404, 96, 3 }, { 418, 96, 3 }, { 428, 100, 3 } }) do
    local m = c:ellipse(k[1], k[2], k[3], 2) rimOf(m, WB) part(m, WB) px(k[1] - 1, k[2] - 1, WB.hi)
  end
  -- leaf clumps, silvery willow and darker underneath
  local crowns = {
    { 412, 68, 46, 26, L.foliage, 37 },
    { 384, 76, 22, 13, L.willow, 31 }, { 442, 74, 22, 13, L.foliage2, 32 }, { 410, 56, 24, 12, L.willow, 33 },
    { 414, 88, 18, 8, L.foliage2, 36 },
  }
  for _, cr in ipairs(crowns) do
    local m = F.crown(cr[1], cr[2], cr[3], cr[4], cr[5], cr[6])
    local r = cr[5]
    -- long weeping fronds from the clump's underside
    m:each(function(x, y)
      if not m:has(x, y + 1) and x % 2 == 0 and hash(x, y, cr[6]) < .85 then
        local len = 5 + floor(hash(x, 1, cr[6]) * (.4 + .6 * hash(x, 2, cr[6])) * 34)
        local lit = x < cr[1]
        for k = 1, len do
          local yy = y + k
          local a1 = lit and (yy % 4 == 0 and r.base or r.hi) or (yy % 4 == 0 and r.shade or r.base)
          local a2 = lit and r.base or r.deep
          if k == len then a1, a2 = r.shade, r.deep end
          px(x, yy, a1) px(x + 1, yy, a2)
        end
      end
    end)
  end
  -- a hollow in the trunk with a little shrine candle and offerings
  local hol = c:ellipse(409, 140, 4, 7)
  fill(hol, WB.edge) fill(c:ellipse(409, 142, 3, 5), L.soil.deep)
  hol:each(function(x, y) if not hol:has(x - 1, y) or not hol:has(x, y - 1) then px(x, y, WB.deep) end end)
  candle(409, 145, 4) px(407, 146, L.marigold.base) px(411, 146, L.awnB.hi)
  glowSpill(409, 142, 7, .3)
  -- the straw rope round the trunk with zigzags, and ribbons tied in the fronds
  for x = 396, 424 do
    local yy = 120 + (x - 396) // 8
    if trunk:has(x, yy) then px(x, yy, ROPE.shade) px(x, yy + 1, (x % 3 == 0) and ROPE.hi or ROPE.base) px(x, yy + 2, ROPE.deep) end
  end
  for _, x in ipairs({ 401, 409, 417 }) do zigzag(x, 123 + (x - 396) // 8) end
  for i, p in ipairs({ { 372, 106 }, { 386, 104 }, { 436, 104 }, { 448, 102 }, { 364, 96 }, { 456, 90 }, { 426, 86 }, { 396, 84 } }) do
    ribbon(p[1], p[2], 5 + i % 3, RIB[i % #RIB + 1], (i % 2 == 0) and 1 or -1)
  end
  -- a heron's stick nest in the crown, the adult standing on it
  local nest = c:ellipse(376, 58, 7, 2)
  rimOf(nest, L.timber) fill(nest, L.timber.base)
  nest:each(function(x, y) if (x + y * 2) % 3 == 0 then px(x, y, L.timber.hi) elseif (x - y) % 4 == 0 then px(x, y, L.timber.deep) end end)
  F.sprite({
    "..KKKk...",
    ".WWWWWkK.",
    "YYWeWW...",
    "...WW....",
    "...WkW...",
    "...WWkG..",
    "..WWGGGG.",
    "..wGGGGGK",
    "..GGgGGKK",
    "...GGgg..",
  }, 372, 46, { W = L.heron.hi, w = L.heron.base, G = L.heron.shade, g = L.heron.deep, k = L.heron.deep, K = L.timber.edge, e = L.gold.base, Y = L.marigold.shade })
end
local function bellFrame(x0, yb)
  local posts = rect(x0, yb - 34, x0 + 2, yb):add(rect(x0 + 30, yb - 34, x0 + 32, yb))
  local bm = poly{ { x0 + 11, yb - 28 }, { x0 + 21, yb - 28 }, { x0 + 23, yb - 12 }, { x0 + 9, yb - 12 } }:add(c:rrect(x0 + 11, yb - 31, x0 + 21, yb - 25, 3))
  F.shadow(x0, x0 + 34, yb, 8, 3)
  rimOf(union(posts, bm), L.timber)
  part(posts, WB, { nopop = true }) vline(x0, yb - 34, yb, WB.hi) vline(x0 + 30, yb - 34, yb, WB.hi)
  part(bm, BRONZE)
  hline(x0 + 10, x0 + 22, yb - 20, BRONZE.deep) hline(x0 + 9, x0 + 23, yb - 13, BRONZE.deep)
  for y = yb - 27, yb - 22, 2 do for x = x0 + 13, x0 + 19, 2 do px(x, y, BRONZE.hi) end end
  bm:each(function(x, y) if y > yb - 20 and hash(x, y, 92) < .14 then px(x, y, L.accent.shade) end end) -- verdigris
  thatchRoof(x0 - 8, x0 + 40, yb - 33, x0 + 6, x0 + 26, yb - 46, TH, 93)
  local log = rect(x0 + 24, yb - 22, x0 + 38, yb - 19) rimOf(log, L.timber) part(log, L.board, { nopop = true }) F.logEnd(x0 + 38, yb - 21, 2)
  vline(x0 + 27, yb - 29, yb - 23, L.timber.edge) vline(x0 + 35, yb - 29, yb - 23, L.timber.edge)
  -- reed sheaves leaning on the posts
  for _, sx in ipairs({ x0 - 3, x0 + 35 }) do
    local sh = poly{ { sx - 2, yb }, { sx + 2, yb }, { sx + 1, yb - 14 }, { sx, yb - 16 }, { sx - 1, yb - 14 } }
    rimOf(sh, L.reed) part(sh, L.reed, { nopop = true }) hline(sx - 2, sx + 2, yb - 7, L.timber.deep)
    px(sx, yb - 17, L.plume.base)
  end
end
sacredWillow()
bellFrame(300, 140)
local _, rx, ry = F.gnome(352, 142, { hat = L.lav, coat = SC, arm = "up", flip = true })
line({ { rx, ry }, { 337, 121 } }):each(function(x, y) px(x, y, L.timber.edge) end)

---------------------------------------------------------------- the bog-oak gate over the causeway
local function gate()
  local postL, postR = rect(204, 122, 209, 198), rect(271, 122, 276, 198)
  local cap = poly{ { 182, 113 }, { 190, 108 }, { 290, 108 }, { 298, 113 }, { 296, 117 }, { 184, 117 } }
  local tie = rect(192, 118, 288, 122)
  local nuki = rect(196, 132, 284, 136)
  local plaque = rect(233, 122, 247, 131)
  local feet = rect(202, 196, 211, 199):add(rect(269, 196, 278, 199))
  F.shadow(204, 280, 199, 10, 4)
  local sil = union(postL, postR, cap, tie, nuki, plaque, feet)
  rimOf(sil, BOG)
  for _, p in ipairs({ { postL, 204 }, { postR, 271 } }) do
    part(p[1], BOG)
    p[1]:each(function(x, y)
      local k = x - p[2]
      if k == 1 then px(x, y, BOG.hi) elseif k == 5 then px(x, y, BOG.shade)
      elseif hash(x, y // 5, 93) < .2 then px(x, y, BOG.shade) elseif hash(x, y // 3, 94) < .07 then px(x, y, BOG.hi) end
      if y > 182 and hash(x, y // 2, 95) < .25 + (y - 182) * .04 then px(x, y, hash(x, y, 96) < .5 and L.moss.base or L.moss.shade) end
    end)
  end
  part(tie, L.timber, { nopop = true }) hline(192, 288, 118, L.timber.hi)
  -- the tie-beam below: a bound reed bundle
  part(nuki, L.reed, { nopop = true })
  nuki:each(function(x, y) if (x + (y % 2)) % 2 == 0 then px(x, y, y == 132 and L.reed.hi or L.reed.base) end end)
  for x = 200, 280, 10 do vline(x, 132, 136, L.timber.deep) vline(x + 1, 132, 136, ROPE.base) end
  for _, ex in ipairs({ 196, 284 }) do F.logEnd(ex, 134, 2) end
  -- the reed-thatched cap with a sedge ridge
  part(cap, SC, { nopop = true }) F.thatch(cap, SC, 108, 240)
  hline(190, 290, 108, TH.hi) hline(189, 291, 109, TH.base)
  for x = 188, 292 do if (x // 3) % 2 == 0 then px(x, 110, TH.shade) end end
  for x = 190, 290, 6 do px(x, 109, L.timber.hi) px(x + 1, 110, L.timber.base) end
  hline(184, 296, 117, SC.edge) for x = 185, 295, 2 do px(x, 116, SC.hi) end
  F.moss(cap, .08, 99)
  part(feet, L.stone, { nopop = true }) F.moss(feet, .4, 98)
  part(plaque, L.board) c:edgeIn(plaque, L.timber.base)
  F.sprite({ ".kk...", "kkkb..", "..k...", "..kkk.", ".kkkkk", "..kk..", "..k.k." }, 237, 123, { k = L.timber.deep, b = L.marigold.shade }, { rim = false })
  -- ribbons tied round the posts and reed sheaves lashed on
  for i, p in ipairs({ { 204, 150 }, { 209, 164 }, { 271, 156 }, { 276, 168 } }) do
    local r = RIB[i % #RIB + 1]
    hline(p[1] - (p[1] % 2 == 0 and 0 or 5), p[1] + (p[1] % 2 == 0 and 5 or 0), p[2], r.base)
    ribbon(p[1] + (i % 2 == 0 and 1 or -1), p[2] + 1, 6, r, i % 2 == 0 and 1 or -1)
  end
  for _, sx in ipairs({ 200, 280 }) do
    local sh = poly{ { sx - 3, 140 }, { sx + 3, 140 }, { sx + 2, 170 }, { sx - 2, 170 } }
    rimOf(sh, L.reed) part(sh, L.reed, { nopop = true })
    sh:each(function(x, y) if x % 2 == 0 then px(x, y, x < sx and L.reed.hi or L.reed.shade) end end)
    hline(sx - 3, sx + 3, 146, L.timber.deep) hline(sx - 3, sx + 3, 163, L.timber.deep)
    for k = -1, 1 do px(sx + k * 2, 139, L.plume.base) px(sx + k * 2, 138, L.plume.hi) end
  end
  -- lanterns hanging from the cap ends
  for _, lx in ipairs({ 189, 291 }) do
    vline(lx, 118, 121, L.timber.edge)
    lanternBox(lx, 122, 3, 7)
    vline(lx, 133, 135, L.glow.shade) px(lx, 136, RED.base)
    glowSpill(lx, 128, 9, .3)
  end
end

---------------------------------------------------------------- a lantern on a stake, scaled by depth, light on the ditch
local function postLantern(x, yb, s)
  local function R(a, b, cc, d) return rect(floor(x + a * s), floor(yb + b * s), floor(x + cc * s), floor(yb + d * s)) end
  local post = R(-1, -16, 1, 0)
  local foot = R(-3, -2, 3, 0)
  F.shadow(floor(x - 3 * s), floor(x + 4 * s), yb, floor(5 * s), floor(2 * s))
  rimOf(union(post, foot), L.timber)
  part(post, WB, { nopop = true }) part(foot, L.stone, { nopop = true })
  vline(floor(x - 1 * s), floor(yb - 16 * s), yb - 1, WB.hi)
  -- a reed sheaf tied to the stake
  local sh = poly{ { x - 1, floor(yb - 3 * s) }, { x + floor(3 * s), floor(yb - 3 * s) }, { x + floor(2 * s), floor(yb - 13 * s) }, { x + 1, floor(yb - 13 * s) } }
  part(sh, L.reed, { nopop = true }) hline(x, x + floor(2 * s), floor(yb - 8 * s), L.timber.deep)
  local w, h = math.max(2, floor(4 * s)), math.max(3, floor(7 * s))
  lanternBox(x, floor(yb - 16 * s) - h - 3, w, h)
  glowSpill(x, floor(yb - 16 * s) - h // 2, floor(7 * s) + 3, .26)
end

---------------------------------------------------------------- left hero: the spring pavilion on a boardwalk
local function pavilion()
  local x0, x1 = 96, 184
  -- a strip of water under the boardwalk, the deck, the pavilion posts
  local strip = poly{ { 82, 211 }, { 196, 211 }, { 200, 220 }, { 186, 224 }, { 92, 224 }, { 80, 219 } }
  rimOf(strip, L.peat) F.water(strip, L.water, { dark = true })
  F.stilts({ 92, 112, 136, 160, 184 }, 212, 222, 219)
  local deck = rect(86, 207, 192, 212)
  F.boardwalk(deck, true, 61) hline(86, 192, 212, L.board.deep)
  local posts = rect(x0 + 6, 158, x0 + 9, 207):add(rect(x1 - 9, 158, x1 - 6, 207))
  F.shadow(x0 + 6, x1, 207, 12, 4)
  rimOf(posts, WB) part(posts, WB, { nopop = true })
  posts:each(function(x, y) if x == x0 + 6 or x == x1 - 9 then px(x, y, WB.hi) elseif hash(x, y // 3, 64) < .2 then px(x, y, WB.shade) end end)
  thatchRoof(x0 - 8, x1 + 8, 158, x0 + 18, x1 - 18, 134, TH, 65, { moss = .05 })
  -- a carved heron board in the gable end
  local tri = poly{ { 128, 156 }, { 140, 142 }, { 152, 156 } } rimOf(tri, L.timber) fill(tri, L.board.base) F.planks(tri, L.board, 3, true, 23)
  F.sprite({ ".kk.", "kkkb", "..k.", ".kkk", "kkkk", "..k." }, 138, 147, { k = L.timber.deep, b = L.marigold.shade }, { rim = false })
  -- a lantern hanging under the eave
  vline(118, 161, 164, L.timber.edge) lanternBox(118, 165, 3, 6) glowSpill(118, 171, 9, .28)
  -- the hollow bog-oak trough on two chocks
  for _, cx in ipairs({ 120, 160 }) do local ch = rect(cx - 4, 203, cx + 4, 207) rimOf(ch, L.timber) part(ch, L.timber, { nopop = true }) end
  local front = c:rrect(110, 184, 170, 204, 4)
  rimOf(front, BOG) part(front, BOG)
  front:each(function(x, y)
    if y > 186 and (y + floor(sin(x / 9) * 1.5)) % 4 == 0 then px(x, y, BOG.shade) end
    if y > 186 and y < 190 and x < 150 and hash(x, y, 66) < .4 then px(x, y, BOG.hi) end
    if y > 198 and hash(x // 2, y, 67) < .3 then px(x, y, L.moss.shade) end
  end)
  F.logEnd(110, 194, 9, BOG)
  local wat = poly{ { 116, 189 }, { 166, 189 }, { 164, 185 }, { 118, 185 } } F.water(wat, L.water, { step = 2 })
  F.lily(132, 187, false, "white") F.lily(154, 187, false)
  px(144, 187, L.produce.base) px(145, 187, L.produce.hi) px(143, 187, L.produce.shade) -- a little rudd
  hline(118, 166, 184, BOG.hi)
  -- a peat bank spring on the right with marigolds; a hollow alder pipe on a forked stick
  local bank = poly{ { 168, 206 }, { 172, 188 }, { 180, 182 }, { 190, 186 }, { 194, 206 } }
  rimOf(bank, L.peat) part(bank, L.sedgeGround)
  bank:each(function(x, y)
    if not bank:has(x, y - 2) then px(x, y, hash(x, y, 68) < .5 and L.moss.hi or L.moss.base)
    elseif y > 198 then px(x, y, hash(x // 2, y, 69) < .5 and L.peat.base or L.peat.shade)
    elseif hash(x // 2, y // 2, 69) < .2 then px(x, y, L.moss.shade) elseif hash(x, y, 70) < .12 then px(x, y, L.reedGreen.hi) end
  end)
  for k = 0, 3 do F.sedge(172 + k * 6, 188 + (k % 2) * 3, 4) end
  for _, p in ipairs({ { 176, 186 }, { 184, 184 }, { 189, 190 }, { 172, 194 } }) do px(p[1], p[2], L.marigold.base) px(p[1] - 1, p[2], L.marigold.hi) px(p[1], p[2] + 1, L.reedGreen.shade) end
  local sp = rect(148, 170, 178, 173)
  rimOf(sp, L.timber) part(sp, WB, { nopop = true }) hline(149, 177, 170, WB.hi)
  F.logEnd(148, 172, 2, WB)
  vline(164, 174, 183, L.timber.base) vline(165, 174, 183, L.timber.deep) px(163, 174, L.timber.base) px(166, 174, L.timber.base)
  vline(176, 174, 184, WB.base) -- the pipe's prop on the bank
  vline(148, 175, 185, L.water.hi) vline(149, 176, 185, L.water.base)
  px(147, 186, L.water.hi) px(151, 186, L.water.hi) px(150, 185, L.awnB.hi)
  -- gourd ladles laid across
  for k = 0, 2 do
    local lx = 118 + k * 10
    fill(line({ { lx, 183 }, { lx + 9, 180 } }), L.board.base)
    local cup = c:ellipse(lx - 1, 183, 2, 1) fill(cup, L.gold.base) px(lx - 2, 182, L.gold.hi) px(lx, 184, L.gold.shade)
  end
  F.dragonfly(176, 162, L.accent, true)
end

---------------------------------------------------------------- right hero: the offering rack over a boardwalk of offerings
local function rack()
  local x0, x1, yt, yb = 300, 384, 160, 207
  local deck = rect(286, 207, 398, 213)
  F.shadowM(poly{ { 288, 213 }, { 398, 213 }, { 404, 217 }, { 294, 217 } })
  for _, sx in ipairs({ 292, 316, 344, 372, 394 }) do vline(sx, 214, 217, L.timber.deep) vline(sx + 1, 214, 217, L.timber.shade) end
  F.boardwalk(deck, true, 71) hline(286, 398, 213, L.board.deep)
  local posts = rect(x0, yt, x0 + 3, yb):add(rect(x1 - 3, yt, x1, yb))
  local rails = rect(x0, 172, x1, 173):add(rect(x0, 190, x1, 191))
  F.shadow(x0, x1, yb, 12, 4)
  rimOf(union(posts, rails), L.timber)
  part(posts, WB, { nopop = true }) vline(x0, yt, yb, WB.hi) vline(x1 - 3, yt, yb, WB.hi)
  part(rails, L.timber, { nopop = true, noshade = true }) hline(x0, x1, 172, L.timber.hi) hline(x0, x1, 190, L.timber.hi)
  thatchRoof(x0 - 8, x1 + 8, yt + 1, x0 + 8, x1 - 8, yt - 10, TH, 72)
  -- top row: carved fish plaques painted with scales; bottom row: woven straw knots on strings and ribbons
  local cols = { L.awnA, L.accent, L.produce, L.lav, L.gold }
  for k = 0, 9 do
    local x = x0 + 5 + k * 8
    if x + 6 < x1 - 3 then
      local yy = 174
      local fy = yy + 2 + (k % 2) * 3
      local m = poly{ { x, fy + 2 }, { x + 2, fy }, { x + 4, fy }, { x + 5, fy + 2 }, { x + 4, fy + 4 }, { x + 2, fy + 4 } }
      local tail = poly{ { x + 5, fy + 2 }, { x + 7, fy }, { x + 7, fy + 4 } }
      vline(x + 3, yy, fy - 1, L.timber.edge)
      c:rim(union(m, tail), L.board.edge) fill(m, L.board.hi) fill(tail, L.board.base)
      hline(x + 1, x + 4, fy + 4, L.board.shade) px(x + 7, fy + 4, L.board.deep)
      local cr = cols[k % 5 + 1]
      px(x + 1, fy + 2, L.timber.edge) hline(x + 2, x + 4, fy + 2, cr.base) px(x + 3, fy + 3, cr.shade) px(x + 3, fy + 1, cr.hi) px(x + 6, fy + 2, cr.base)
      -- the bottom row
      local by = 192
      if k % 3 == 1 then
        for j = 0, 2 do ribbon(x + j * 2, by, 6 + (j + k) % 4, RIB[(k + j) % #RIB + 1]) end
      else
        vline(x + 3, by, by + 2, ROPE.deep)
        local kn = poly{ { x + 3, by + 3 }, { x + 6, by + 6 }, { x + 3, by + 9 }, { x, by + 6 } }
        c:rim(kn, L.reed.edge) fill(kn, L.reed.base)
        kn:each(function(xx, yy2) if (xx + yy2) % 2 == 0 then px(xx, yy2, xx <= x + 3 and L.reed.hi or L.reed.shade) end end)
        px(x + 3, by + 6, cols[(k + 2) % 5 + 1].base)
        vline(x + 2, by + 10, by + 12, L.reed.shade) vline(x + 4, by + 10, by + 13, L.reed.deep) px(x + 3, by + 10, RED.base)
      end
    end
  end
  -- offerings laid on the boardwalk: bowls of cranberries and eggs, a loaf, a marigold wreath, candles, reed boats
  local yb2 = 210
  local function bowl(x, r)
    local m = rect(x - 3, yb2 - 1, x + 3, yb2) rimOf(m, L.timber) part(m, BOG, { nopop = true }) hline(x - 3, x + 3, yb2 - 1, BOG.hi)
    hline(x - 2, x + 2, yb2 - 2, r.base) px(x - 1, yb2 - 3, r.hi) px(x + 1, yb2 - 3, r.base) px(x + 2, yb2 - 2, r.shade) px(x - 2, yb2 - 2, r.hi)
  end
  bowl(304, L.apple)
  bowl(338, L.awnB)
  bowl(370, L.marigold)
  local loaf = c:ellipse(318, yb2 - 2, 4, 2) rimOf(loaf, L.soil) part(loaf, L.needle, { nopop = true }) px(316, yb2 - 3, L.needle.hi) hline(316, 320, yb2 - 2, L.needle.shade)
  local wr = c:ellipse(354, yb2 - 1, 5, 2) local wh = c:ellipse(354, yb2 - 1, 2, 1)
  wr:cut(wh) wr:each(function(x, y) px(x, y, (x + y) % 2 == 0 and L.marigold.base or L.reedGreen.base) end) px(350, yb2 - 2, L.marigold.hi) px(357, yb2, L.reedGreen.shade)
  for _, x in ipairs({ 310, 327, 346, 362, 378 }) do candle(x, yb2, 3 + x % 2) end
  glowSpill(327, 206, 6, .2) glowSpill(362, 206, 6, .2)
  -- a little reed boat with a candle left at the boardwalk's end, on the water below
end

---------------------------------------------------------------- otters: stone guardians and the real pup
local OTTER = {
  "..B.....B..",
  ".BHBBBBBBS.",
  ".HHBBBBBSS.",
  ".HeHBBBeSS.",
  ".HmmmnmmmS.",
  "..mmmmmmS..",
  "...BBBBS...",
  "..HBmmBSS..",
  ".HBBmmBBSS.",
  ".HBBmmBBSS.",
  ".HBBmmBBSS.",
  ".HBpBBpBSS.",
  "HHBBBBBBBSS.",
  "HBBBBBBBBSSD",
  ".BBBBBBBSSDD",
  "..SSSSSSS.DD",
}
local function otter(x, yb, r, chest, flip)
  local rows = {}
  for i, row in ipairs(OTTER) do rows[i] = flip and row:reverse() or row end
  local w = #OTTER[13]
  return F.sprite(rows, x - 5 - (flip and (w - 11) or 0), yb - #rows + 1, { H = r.hi, B = r.base, S = r.shade, D = r.deep, e = L.timber.edge, n = L.timber.edge,
    m = chest, p = r.deep }, { rimCol = r.edge })
end
local function otterHat(x, ytop)
  F.sprite({ "....r..", "...RR..", "..HRRr.", ".HRRRr.", "hhhhhhh" }, x - 3, ytop, { R = RED.base, r = RED.shade, H = RED.hi, h = RED.deep })
end
local function plinth(x, yb, w, h)
  local m = rect(x - w, yb - h, x + w, yb) rimOf(m, L.stone) part(m, L.stone) hline(x - w, x + w, yb - h, L.stone.hi) F.moss(m, .25, 76 + x)
end

---------------------------------------------------------------- the mirror pool (bottom left): plank frame, stepping stones, floating lanterns
local function mirrorPool()
  local g = poly{ { 20, 230 }, { 150, 226 }, { 162, 264 }, { 20, 266 } }
  local frame = g:grow(3):cut(g)
  rimOf(g:grow(3), L.timber)
  frame:each(function(x, y)
    local inner = g:has(x - 1, y) or g:has(x + 1, y) or g:has(x, y - 1) or g:has(x, y + 1)
    local seam = (x + y) % 9 == 0
    px(x, y, seam and L.board.deep or (inner and L.board.shade or ((y < 230 or x < 20) and L.board.hi or L.board.base)))
  end)
  F.water(g, L.water)
  -- willow and lantern reflections in the far water
  for _, rx in ipairs({ 40, 120 }) do for k = 0, 4 do hline(rx - 4 + k, rx + 4 - k, 231 + k * 2, L.water.shade) end end
  -- stepping stones crossing it
  for i, s in ipairs({ { 30, 254, 6 }, { 46, 248, 5 }, { 64, 252, 6 }, { 82, 246, 5 }, { 100, 250, 6 }, { 118, 244, 5 }, { 136, 248, 6 }, { 152, 242, 5 } }) do
    local m = c:ellipse(s[1], s[2], s[3], 2)
    rimOf(m, L.stone) part(m, L.stone, { nopop = true })
    hline(s[1] - s[3] + 2, s[1] + 1, s[2] - 1, L.stone.hi)
    if hash(i, 1, 81) < .6 then px(s[1] + 2, s[2] - 1, L.moss.base) px(s[1] + 3, s[2], L.moss.shade) end
    hline(s[1] - s[3] + 1, s[1] + s[3] - 1, s[2] + 3, L.water.deep)
  end
  for _, p in ipairs({ { 40, 236, true, "white" }, { 70, 240, false }, { 132, 258, true, "yellow" }, { 92, 260, true }, { 28, 244, false, "white" }, { 110, 236, false } }) do F.lily(p[1], p[2], p[3], p[4]) end
  floatLantern(58, 240, true) floatLantern(104, 256, true) floatLantern(140, 236, false) floatLantern(30, 262, false)
  -- a kingfisher on a stake at the pool's corner
  vline(152, 220, 230, WB.base) vline(153, 220, 230, WB.deep) px(152, 220, WB.hi)
  F.sprite({ ".bb...", "bBBb..", "bwBBkk", ".oooB.", ".ooB..", "..BB.." }, 149, 214, { b = L.accent.shade, B = L.accent.base, w = L.awnB.hi, k = L.timber.edge, o = L.produce.base })
  F.reeds(10, 24, 260, 22, 82, { cattails = 3, green = true })
  F.reeds(178, 192, 232, 14, 83, { cattails = 2 })
end

---------------------------------------------------------------- compose (front)
F.depth(3)
-- a peat brazier on an iron tripod with a smoke plume (left middle)
do
  local legs = line({ { 61, 206 }, { 52, 221 } }):add(line({ { 61, 206 }, { 70, 221 } })):add(line({ { 61, 206 }, { 62, 222 } }))
  local basket = c:rrect(51, 199, 71, 207, 3)
  F.shadow(52, 70, 221, 6, 2)
  rimOf(union(legs, basket), L.iron)
  part(legs, L.iron, { nopop = true, noshade = true })
  fill(basket, L.iron.shade)
  for x = 53, 69, 3 do vline(x, 200, 206, L.iron.base) end
  hline(51, 71, 203, L.iron.hi)
  -- glowing peat bricks heaped in it
  for k = 0, 5 do local bx = 53 + k * 3 fill(rect(bx, 196 - k % 2, bx + 2, 199), (k % 2 == 0) and L.peat.shade or L.peat.base) px(bx, 196 - k % 2, L.peat.hi) end
  for _, p in ipairs({ { 56, 198 }, { 62, 197 }, { 66, 198 }, { 59, 199 } }) do px(p[1], p[2], L.glow.shade) px(p[1] + 1, p[2], L.glow.base) end
  F.smoke(61, 188, 7, -.3, 2)
  glowSpill(61, 199, 8, .22)
  -- a stack of cut peat beside it
  for row = 0, 2 do for k = 0, 2 - row do
    local m = rect(26 + k * 7 + row * 3, 214 - row * 4, 31 + k * 7 + row * 3, 217 - row * 4)
    rimOf(m, L.peat) part(m, L.peat, { nopop = true }) px(26 + k * 7 + row * 3, 214 - row * 4, L.peat.hi)
  end end
end
pavilion()
rack()
for _, p in ipairs({ { 146, .5, 11 }, { 182, .7, 22 }, { 252, 1.3, 22 } }) do
  local y = p[1]
  postLantern(floor(F.xl(y)) - p[3], y, p[2])
  postLantern(floor(F.xr(y)) + p[3], y, p[2])
end
gate()
plinth(194, 214, 7, 6) otter(194, 207, L.stone, L.stone.hi) otterHat(194, 187)
plinth(291, 214, 14, 6) otter(283, 207, L.stone, L.stone.hi, true)
-- quirk: the real otter pup sits beside the bare-headed stone otter, wearing the other one's red gnome hat
otter(299, 207, L.soil, L.plaster.hi, true) otterHat(298, 186)
px(296, 195, L.awnB.hi) px(302, 195, L.awnB.hi) -- whiskers
mirrorPool()
-- the right edge: bulrushes and yellow flag irises, a heron fishing in the reeds
F.reeds(418, 470, 226, 50, 91, { cattails = 6, green = true })
for _, p in ipairs({ { 414, 226 }, { 426, 224 }, { 468, 222 } }) do
  for k = -2, 2 do line({ { p[1], p[2] }, { p[1] + k * 2, p[2] - 14 + math.abs(k) * 2 } }):each(function(x, y) px(x, y, k < 0 and L.reedGreen.hi or (k == 0 and L.reedGreen.base or L.reedGreen.shade)) end) end
  local fx, fy = p[1] + 1, p[2] - 16
  px(fx, fy, L.marigold.base) px(fx - 1, fy, L.marigold.hi) px(fx + 1, fy + 1, L.marigold.shade) px(fx, fy - 1, L.marigold.hi) px(fx - 1, fy + 1, L.marigold.deep)
end
F.heron(446, 222)
for xx = 438, 454 do if hash(xx, 2, 84) < .6 then px(xx, 223, L.water.hi) end end
F.bush(400, 230, 12, 7, L.reedGreen, 12)
-- a gnome sweeping fallen willow leaves off the ground below the boardwalk
local _, bx, by = F.gnome(348, 238, { hat = RED, coat = L.wall2, flip = true, arm = "hold" })
fill(line({ { bx + 1, by - 6 }, { bx - 6, by + 6 } }, 1), L.timber.base)
local broom = poly{ { bx - 11, by + 6 }, { bx - 3, by + 6 }, { bx - 4, by + 10 }, { bx - 12, by + 10 } }
rimOf(broom, L.reed) part(broom, L.reed, { nopop = true }) for x = bx - 11, bx - 4, 2 do vline(x, by + 7, by + 10, L.reed.deep) end
for i = 0, 34 do local x, y = 314 + floor(hash(i, 1, 5) * 14), 240 + floor(hash(i, 2, 5) * 5) - (i % 3)
  local r = (i % 3 == 0) and L.willow or L.marigold
  px(x, y, r.base) px(x + 1, y, r.shade) end
-- a gnome hanging a straw knot on the rack
local _, ex, ey = F.gnome(392, 214, { hat = L.leaf, coat = L.lav, arm = "up", flip = true })
local kn = poly{ { ex, ey - 2 }, { ex + 3, ey + 1 }, { ex, ey + 4 }, { ex - 3, ey + 1 } }
c:rim(kn, L.reed.edge) fill(kn, L.reed.base) px(ex - 1, ey, L.reed.hi) px(ex, ey + 1, RED.base)
-- sedge and marigolds round the near ground
for _, f in ipairs({ { 186, 228 }, { 290, 226 }, { 172, 250 }, { 312, 258 }, { 370, 252 }, { 200, 262 } }) do F.sedge(f[1], f[2], 6) px(f[1] - 1, f[2] - 5, L.marigold.base) px(f[1] + 2, f[2] - 4, L.marigold.hi) end
F.dragonfly(90, 226, L.apple) F.dragonfly(332, 222, L.accent, true)

-- a heron flying in from the left, swallows over the chapel
F.depth(0)
F.sprite({ "....ww......", "...wwwwwwwww", "YYkwwwwwww..", "......wwwww.", ".......www.." }, 110, 44, { w = L.heron.base, k = L.heron.deep, Y = L.marigold.shade }, { rim = false })
F.birds({ { 330, 38, 2 }, { 342, 44, 1 }, { 168, 64, 1 }, { 290, 52, 2 } })
F.depth(3)
-- fallen willow leaves and marigold petals scattered about
for i = 0, 50 do
  local x, y = 20 + floor(hash(i, 1, 77) * 440), 132 + floor(hash(i, 2, 77) * 128)
  if not (x > 378 and y > 228) and not F.poolAt(x, y) then
    if i % 3 == 0 then px(x, y, L.marigold.base) px(x + 1, y, L.marigold.shade)
    else px(x, y, L.willow.hi) px(x + 1, y, L.willow.shade) px(x + 2, y + 1, L.willow.deep) end
  end
end
F.finish()
