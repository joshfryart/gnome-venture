-- ferry.lua : "Ferry crossing" stop look, WETLAND (wetland_reed), 480x270 gate view.
-- Same composition as the Maplewold ferry (art-2701-batch4/stops/opus3/ferry.lua), re-cast for a reed fen:
-- a wide, still marsh channel runs across the whole view, mirroring the grey-gold sky, and the causeway stops at it
-- on a stilted boardwalk stage. The ferry is the centre hero: a big flat pole-punt with tarred sides and raked swim
-- ends, running on a guide rope slung across the channel from a far post to the lantern post by the near stage. A
-- ferryman poles it, a traveller with a bundle and cargo (milk churns, reed bundles, an eel basket) ride it, and a
-- gnome on the stage hauls it in by the tow rope. Far bank: a dense reed bed, the causeway going on from a far stage
-- past the ferryman's tarred house on stilts (reed thatch, heron weathervane, bell post, lantern, eel hives), a
-- reed-cutter's cottage with sheaf stooks, washing, a gnome waving; a row of pollard willows on the right, a heron
-- wading in the shallows, a reed-cutter poling a punt piled with sheaves, moorhens, mist on the water.
-- Near bank: ferry bell under a little thatch, a painted ferry sign (punt and heron), a tarred ticket booth with a
-- reed roof and a gnome in the hatch, a bench of waiting travellers, a beached duck punt with eel hives, a barrow of
-- cut peat turves, a turf stack, cargo, bulrush beds, lilies, a kingfisher on the mooring stake, a fisher gnome with
-- an eel in his creel and a greylag goose after an apple.
-- Quirk: an otter in a red gnome hat, riding the ferry on a trunk, holding its fish.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-wetland-stops/"
local F = dofile(DIR .. "_frame.lua")
  .build{ name = "ferry", out = DIR, roadTop = 178, farTrees = { 30, 70, 120, 168, 330, 372, 446 }, poolK = .8,
    clouds = { { 170, 44, 40 }, { 300, 34, 50 }, { 420, 70, 28 }, { 214, 78, 24 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local mix = F.mix
local Wt = L.water
local SKY = F.SKYREF
local GLINT = "#f2eac8"
local TAR = F.rp("#8a8c80 #64685e #4a4e48 #363a36 #24282a") -- tarred weatherboard / punt sides
local KF = F.rp("#9ce0ea #4cb0cc #2e86a6 #20607c #163e52")  -- kingfisher blue
-- DY: a temporary vertical offset for whole near-bank groups (set, draw, reset)
local DY = 0
do local base = c.put c.put = function(self, x, y, h, o) base(self, x, y + DY, h, o) end end

local function yF(x) return 124 + floor(2 * sin(x / 31) + 1.5 * sin(x / 11)) end
local function yN(x) local t = (x - 240) / 240 return 177 + floor(14 * t * t + 3 * sin(x / 23) + 2 * sin(x / 9 + 1)) end

---------------------------------------------------------------- local helpers
-- a tied reed sheaf standing (side view): tapering bundle, stalk stripes, a band, a plume tuft on top
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
local function stook(x, yb, h) sheaf(x - h // 4, yb, h - 2) sheaf(x + h // 4, yb, h - 2) sheaf(x, yb + 1, h) end
-- the cut end of a reed bundle seen face-on
local function bundleEnd(x, y, r)
  local m = c:ellipse(x, y, r, r)
  c:rim(m, L.reed.edge)
  m:each(function(xx, yy)
    local d = (xx - x) + (yy - y)
    local col = d < -r * .6 and L.reed.hi or (d > r * .6 and L.reed.shade or L.reed.base)
    if (xx + yy * 2) % 3 == 0 then col = (d < 0) and L.reed.base or L.reed.deep end
    px(xx, yy, col)
  end)
  px(x, y, L.reed.deep)
  return m
end
-- a wicker eel hive lying on its side (horizontal cone), mouth to the left, x..x+len, centre y
local function eelHive(x, y, len, rr)
  rr = rr or 3
  local m = poly{ { x, y - rr }, { x + len, y - 1 }, { x + len, y + 1 }, { x, y + rr } }
  rimOf(m, L.reed)
  part(m, L.reed, { nopop = true })
  m:each(function(xx, yy)
    if (xx - x) % 3 == 0 then px(xx, yy, L.reed.deep)
    elseif (xx + yy) % 2 == 0 then px(xx, yy, yy < y and L.reed.hi or L.reed.shade) end
  end)
  vline(x, y - rr + 1, y + rr - 1, L.cattail.deep) px(x, y, L.soil.deep)
  return m
end
-- a cut peat turf brick, front face 7x3 with a lit top lip, fibres
local function turf(x, y, w)
  w = w or 7
  local m = rect(x, y, x + w - 1, y + 3)
  c:rim(m, L.peat.edge)
  m:each(function(xx, yy)
    local col = yy == y and L.peat.hi or (xx == x + w - 1 and L.peat.deep or L.peat.base)
    if yy > y and xx < x + w - 1 and hash(xx, yy, 201) < .3 then col = L.peat.shade end
    if yy > y and hash(xx, yy, 202) < .08 then col = L.cattail.hi end
    px(xx, yy, col)
  end)
  return m
end
-- a kingfisher perched, facing left, feet at (x, yb)
local function kingfisher(x, yb)
  F.sprite({
    "..BHb",
    ".BHBb",
    "kkBwB",
    "..OOB",
    "..OOb",
    "..OBb",
    "...bb",
  }, x - 2, yb - 6, { B = KF.base, H = KF.hi, b = KF.shade, w = L.awnB.hi, O = L.produce.base, k = L.timber.edge })
end
-- a moorhen swimming, facing left (body x..x+9, waterline yb)
local function moorhen(x, yb)
  F.sprite({
    "..KK......",
    ".rKKk.....",
    "yrKKKKKKw.",
    "..KKKKKKKw",
    "...kwkkkk.",
  }, x, yb - 4, { K = L.iron.shade, k = L.iron.deep, r = L.apple.base, y = L.marigold.base, w = L.awnB.hi })
  for xx = x + 1, x + 9 do if hash(xx, yb, 203) < .7 then px(xx, yb + 1, xx < x + 5 and Wt.hi or SKY) end end
end

---------------------------------------------------------------- the marsh channel
local river = HP.mask()
for x = 0, 479 do for y = yF(x), yN(x) do river:set(x, y) end end
do
  river:each(function(x, y)
    local f = (y - yF(x)) / math.max(1, yN(x) - yF(x))
    local h
    if f < .1 then h = Wt.hi
    elseif f < .26 then h = hash(x // 7, y, 14) < .45 and Wt.hi or SKY
    elseif f < .42 then h = hash(x // 9, y, 15) < .3 and SKY or mix(SKY, Wt.base, .5)
    elseif f < .76 then h = Wt.base
    else h = hash(x // 6, y // 2, 16) < .55 and Wt.shade or mix(Wt.base, Wt.shade, .5) end
    px(x, y, h)
  end)
  -- long, thin, still sky streaks (no current): every 4th row, longer nearer; a few dark wind-lines
  for y = 128, 194 do
    local d = y - 122
    if y % 4 == 0 then
      local x = floor(hash(y, 1, 13) * 40)
      while x < 480 do
        local len = 10 + d // 2 + floor(hash(x, y, 18) * 20)
        local v = hash(x // 9, y, 16)
        if v < .42 then
          for xx = x, x + len do if river:has(xx, y) and river:has(xx, y + 1) then px(xx, y, d < 20 and Wt.hi or mix(SKY, Wt.hi, .5)) end end
        elseif v > .86 and d > 24 then
          for xx = x, x + len // 2 do if river:has(xx, y) and river:has(xx, y + 1) then px(xx, y, Wt.deep) end end
        end
        x = x + len + 14 + floor(hash(x, y, 17) * 30)
      end
    end
  end
  for i = 0, 50 do local x, y = floor(hash(i, 1, 18) * 480), 128 + floor(hash(i, 2, 18) * 60) if river:has(x, y) and river:has(x + 1, y) then px(x, y, GLINT) px(x + 1, y, Wt.hi) end end
  -- far bank: dark lip under a peat edge; near bank: wet edge line, then peat and mud
  for x = 0, 479 do
    px(x, yF(x), Wt.deep) px(x, yF(x) + 1, Wt.shade)
    local v = hash(x, 3, 7)
    px(x, yF(x) - 1, v < .4 and L.peat.base or (v < .7 and L.peat.shade or L.sedgeGround.shade))
    local yn = yN(x)
    for k = 1, 4 do
      local col
      if k == 1 then col = L.peat.deep elseif k == 2 then col = L.peat.shade
      else local w = hash(x, k, 5) col = w < .35 and L.peat.base or (w < .55 and L.peat.hi or (w < .75 and L.sedgeGround.shade or L.peat.shade)) end
      px(x, yn + k, col)
    end
    if hash(x, 10, 6) < .1 then px(x, yn + 3, L.stone.hi) end
    px(x, yn, SKY)
  end
end

---------------------------------------------------------------- far bank: causeway on, far stage, reed-cutter's cottage
F.depth(1)
F.drawRoad(113, 122)
F.tree(112, 122, 30, 5)   -- an alder
F.tree(16, 123, 34, 3)    -- a pollard willow
do -- the reed-cutter's cottage: grey-green board, golden reed thatch with a sedge ridge, peat smoke
  F.building{ x0 = 36, x1 = 80, yb = 122, wh = 13, rh = 12, wall = L.wall2, roof = L.roof, noFrame = true, noAttic = true, chimney = true }
  F.window(44, 113, 48, 116, L.timber) F.window(68, 113, 72, 116, L.timber)
  F.smoke(70, 93, 4, .6, 2)
  stook(90, 123, 10) stook(26, 124, 9)
end
-- the far reed bed along the whole far bank: dense golden stems, mauve plumes, a few bulrushes
for _, r in ipairs({ { 0, 22, 9, 1 }, { 84, 104, 8, 2 }, { 118, 160, 10, 3 }, { 150, 164, 7, 4 }, { 260, 300, 10, 5 }, { 306, 350, 9, 6 }, { 352, 392, 11, 7 }, { 458, 479, 9, 8 } }) do
  local x0, x1 = r[1], r[2]
  F.reeds(x0, x1, yF((x0 + x1) // 2) + 1, r[3], 500 + r[4], { cattails = (x1 - x0) // 14 })
end
-- far stage on stilts
do
  local d = poly{ { 234, 121 }, { 248, 121 }, { 250, 129 }, { 232, 129 } }
  F.boardwalk(d, false, 4)
  F.stilts({ 232, 240, 248 }, 130, 135, 133)
end
F.depth(2)
do -- the ferryman's tarred house on stilts: reed thatch, sedge ridge, heron weathervane, lantern pole and a bell post
  F.stilts({ 166, 178, 190, 200, 211 }, 125, 132, 129)
  local top, cx, wallM, roofM = F.building{ x0 = 164, x1 = 214, yb = 125, wh = 20, rh = 17, wall = TAR, roof = L.roof, noAttic = true, chimney = true, noFrame = true }
  F.planks(wallM:copy():clip(rect(164, top + 2, 214, 125)), TAR, 3, false, 7)
  wallM:each(function(x, y) if x <= 166 and y > top + 1 then px(x, y, TAR.hi) end end)
  F.door(184, 113, 192, 124, L.board)
  F.window(171, 110, 176, 115, L.board) F.window(201, 110, 206, 115, L.board)
  F.smoke(205, 76, 6, .7, 2)
  -- the heron weathervane on the ridge
  vline(189, 82, 88, L.iron.deep)
  F.sprite({ "..kk..", ".kkkkk", "yk.kk.", "...k..", "..k.k." }, 186, 77, { k = L.iron.deep, y = L.gold.shade }, { rim = false })
  -- eel hives hung on the wall
  eelHive(196, 120, 8, 2)
  -- the far ferry bell post at the stage
  local bp = rect(222, 100, 223, 125):add(rect(218, 100, 230, 101)) rimOf(bp, L.timber) part(bp, L.timber, { nopop = true, noshade = true })
  local fb = poly{ { 226, 102 }, { 229, 102 }, { 230, 107 }, { 225, 107 } } c:rim(fb, L.timber.edge) part(fb, L.gold, { nopop = true })
  local lp = rect(256, 98, 257, 125) rimOf(lp, L.timber) part(lp, L.timber, { nopop = true, noshade = true })
  fill(rect(256, 98, 262, 98), L.timber.base)
  local lam = rect(259, 100, 263, 105) rimOf(lam, L.timber) fill(lam, L.glow.base) px(260, 101, L.glow.hi) vline(263, 101, 105, L.glow.shade)
  -- washing between the house and a pole
  local wp = rect(132, 106, 133, 124) rimOf(wp, L.timber) part(wp, L.timber, { nopop = true, noshade = true })
  F.washing(133, 106, 163, 108, { { "shirt", L.awnA }, { "sock", L.marigold }, { "sheet", L.awnB } }, 3)
end
-- a small gnome waving from the far stage
F.gnome(242, 127, { small = true, hat = L.awnA, coat = L.leaf, arm = "up" })
-- a row of pollard willows along the right far bank, and the far guide-rope post
F.tree(408, 124, 44, 3)
F.tree(432, 123, 50, 7)
F.tree(458, 124, 42, 11)
F.tree(474, 124, 36, 1)
do -- their reflections in the channel
  for x = 396, 479 do for y = yF(x) + 2, yF(x) + 14 do if river:has(x, y) and (y + x // 4) % 3 == 0 and hash(x, y, 27) < .6 then px(x, y, mix(L.willow.shade, Wt.base, .5)) end end end
end
-- reflections of the far bank in the water (broken dashes)
for x = 0, 479 do
  local y0 = yF(x) + 2
  local v = c:get(x, yF(x) - 6)
  if v and hash(x, 1, 31) < .55 then
    for y = y0, y0 + 5, 2 do if river:has(x, y) and hash(x, y, 32) < .6 then px(x, y, mix(v, Wt.base, .55)) end end
  end
end

---------------------------------------------------------------- warm mist lying over the far half of the channel
for y = 125, 138 do
  local x = floor(hash(y, 3, 41) * 40)
  while x < 480 do
    local len = 10 + floor(hash(x, y, 42) * 30)
    if hash(x // 11, y, 43) < .45 - (y - 125) * .028 then
      for xx = x, x + len do if river:has(xx, y) and c:get(xx, y) and hash(xx, y, 44) < .8 then px(xx, y, mix(c:get(xx, y), L.mist2, .55)) end end
    end
    x = x + len + 8 + floor(hash(x, y, 45) * 30)
  end
end

---------------------------------------------------------------- reed islets in the channel
F.depth(2)
do
  local function islet(x0, x1, yb, h, seed)
    local mud = c:ellipse((x0 + x1) // 2, yb + 1, (x1 - x0) // 2 + 3, 2)
    fill(mud, L.peat.shade) hline(x0 - 2, x1 + 2, yb + 1, L.peat.base)
    F.reeds(x0, x1, yb, h, seed, { cattails = 2, green = true })
    for xx = x0 - 4, x1 + 4 do if hash(xx, 1, seed) < .5 then px(xx, yb + 3, mix(L.reed.deep, Wt.base, .5)) px(xx, yb + 5, mix(L.reed.shade, Wt.base, .6)) end end
  end
  islet(2, 36, 152, 16, 611)
  islet(448, 479, 146, 14, 612)
end

---------------------------------------------------------------- a heron wading in the shallows, moorhens
F.depth(2)
F.heron(136, 147, false)
for k = 0, 2 do hline(130 - k * 2, 140 + k * 2, 148 + k, k == 1 and Wt.shade or Wt.hi) end
moorhen(160, 141)
for k, mx in ipairs({ 174, 181, 188 }) do
  local my = 144 + (k % 2)
  fill(c:ellipse(mx, my, 2, 1), L.iron.deep) px(mx - 2, my - 1, L.iron.shade) px(mx - 3, my - 1, L.apple.base) hline(mx - 2, mx + 2, my + 2, Wt.hi)
end

---------------------------------------------------------------- left water: a reed-cutter poling a punt piled with sheaves
F.depth(2)
do
  local y = 146
  F.punt(54, 108, y, TAR)
  -- the load of reed bundles lying lengthwise, cut ends to the left
  for row = 0, 1 do
    for k = 0, 2 - row do
      local bx, by = 80 + k * 7 + row * 3, y - 6 - row * 5
      local side = rect(bx, by - 2, bx + 22, by + 2)
      rimOf(side, L.reed) part(side, L.reed, { nopop = true })
      side:each(function(xx, yy) if yy % 2 == 0 then px(xx, yy, L.reed.hi) end if xx > bx + 19 then px(xx, yy, L.plume.base) end end)
      vline(bx + 9, by - 2, by + 2, L.timber.deep)
    end
  end
  for row = 0, 1 do for k = 0, 2 - row do bundleEnd(80 + k * 7 + row * 3, y - 6 - row * 5, 2) end end
  local _, hx, hy = F.gnome(66, y - 3, { small = true, hat = L.marigold, coat = L.awnA, arm = "up", noShadow = true })
  line({ { hx + 1, hy - 8 }, { hx - 10, y + 8 } }):each(function(x, yy) px(x, yy, yy > y and L.board.shade or L.board.base) end)
  for k = 0, 2 do hline(hx - 14 - k * 2, hx - 6 + k * 2, y + 9 + k, k == 1 and Wt.shade or Wt.hi) end
end

---------------------------------------------------------------- the near stage on stilts
F.depth(3)
local LY0, LY1 = 166, 180
do
  local deck = poly{ { F.xl(LY0) - 6, LY0 }, { F.xr(LY0) + 6, LY0 }, { F.xr(LY1) + 6, LY1 }, { F.xl(LY1) - 6, LY1 } }
  local face = rect(floor(F.xl(LY0)) - 6, LY0 - 3, floor(F.xr(LY0)) + 6, LY0 - 1)
  local piles = HP.mask()
  for _, x in ipairs({ floor(F.xl(LY0)) - 6, floor(F.xr(LY0)) + 4 }) do piles:add(rect(x, LY0 - 8, x + 2, LY0 + 8)) end
  rimOf(union(deck, face, piles), L.timber)
  piles:each(function(x, y) px(x, y, y > LY0 + 3 and L.timber.deep or (x % 3 == 0 and L.timber.hi or L.timber.base)) end)
  part(deck, L.board) F.planks(deck, L.board, 4, false, 9)
  F.moss(deck, .04, 104)
  part(face, TAR, { nopop = true, noshade = true })
  face:each(function(x, y) if y == LY0 - 1 and hash(x, y, 107) < .5 then px(x, y, L.moss.shade) end end)
  for x = floor(F.xl(LY0)) - 5, floor(F.xr(LY0)) + 5, 7 do px(x, LY0 - 2, L.iron.hi) end
  for _, x in ipairs({ floor(F.xl(LY0)) - 6, floor(F.xr(LY0)) + 4 }) do
    hline(x - 2, x + 4, LY0 + 9, Wt.hi) fill(rect(x, LY0 - 9, x + 2, LY0 - 9), L.board.hi)
    hline(x, x + 2, LY0 + 4, L.moss.shade)
  end
end

---------------------------------------------------------------- the ferry punt (centre hero)
local RX0, RX1, RY0, RY1 = 270, 366, 137, 152
local FY = RY1 - 6 -- where figures stand
local function otter(x0, y0)
  F.sprite({
    "..........RR.....",
    ".........RRr.....",
    "........HRRr.....",
    ".......HRRRr.....",
    ".......RRRRr.....",
    "......HRRRRRr....",
    "......RRRRRRr....",
    ".....HRRRRRRRr...",
    "....bbbbbbbbbbb..",
    ".....LOOOOOOo....",
    "....LOeOOOeOOo...",
    "....LOOccnccOo...",
    "...wOOccccccOow..",
    ".....oOccccOo....",
    "......OccccO.....",
    ".....LOccccOO....",
    "..t.POOccccOOP...",
    "..tSSPSSSPccOOo..",
    "..t..OOccccOOOo..",
    "....LOOccccOOOOo.",
    "....LOOOccOOOOOo.",
    ".....oOOOOOOOOo.T",
    "......ooOOOOoo.TT",
    "......FF...FF.TT.",
  }, x0, y0, { R = L.awnA.base, r = L.awnA.shade, H = L.awnA.hi, b = L.gold.hi, L = L.soil.hi, O = L.soil.base, o = L.soil.shade,
    c = L.plaster.hi, e = L.timber.edge, n = L.cattail.deep, w = L.plaster.shade, P = L.soil.deep, S = L.iron.hi, t = L.iron.shade,
    T = L.soil.shade, F = L.soil.deep })
  px(x0 + 8, y0 + 17, L.iron.base) px(x0 + 3, y0 + 17, L.iron.base)
end
do
  -- the punt's broken reflection under it and the wash at its swim ends
  for x = RX0 - 6, RX1 + 6 do for y = RY1 + 6, RY1 + 15 do
    if river:has(x, y) and (y % 2 == 0) and hash(x // 2, y, 41) < .6 - (y - RY1) * .03 then px(x, y, mix(TAR.shade, Wt.base, .45)) end
  end end
  for k = 0, 2 do px(RX0 - 9 - k, RY0 + 8 + k * 3, GLINT) hline(RX0 - 12 - k * 3, RX0 - 8 - k * 2, RY0 + 10 + k * 3, Wt.hi) end
  for k = 0, 3 do hline(RX0 - 12 - k * 5, RX0 - 4 - k * 2, RY1 + 7 + k * 2, Wt.hi) hline(RX1 + 4 + k * 2, RX1 + 10 + k * 5, RY1 + 7 + k * 2, Wt.hi) end
  -- hull side: tarred, with raked swim ends standing proud of the deck, a red rubbing strake
  local face = poly{ { RX0 - 8, RY1 - 2 }, { RX1 + 8, RY1 - 2 }, { RX1 + 2, RY1 + 5 }, { RX0 - 2, RY1 + 5 } }
  local deck = poly{ { RX0 + 4, RY0 }, { RX1 - 4, RY0 }, { RX1, RY1 }, { RX0, RY1 } }
  rimOf(union(deck, face), TAR)
  part(face, TAR, { nopop = true })
  face:each(function(x, y)
    if y == RY1 + 1 then px(x, y, L.awnA.base) elseif y == RY1 + 2 then px(x, y, L.awnA.shade) end
    if y == RY1 - 2 then px(x, y, TAR.hi) end
    if y >= RY1 + 4 and hash(x // 2, y, 120) < .5 then px(x, y, L.moss.shade) end
  end)
  for x = RX0 + 4, RX1 - 4, 12 do vline(x, RY1 + 3, RY1 + 4, TAR.deep) px(x, RY1 + 1, L.iron.hi) end
  -- deck: silvered boards running fore and aft, damp seams, a lit back edge
  part(deck, L.board) F.planks(deck, L.board, 3, false, 17)
  deck:each(function(x, y)
    if hash(x // 7, y // 3, 108) < .18 then px(x, y, ((y % 3) == 0) and L.board.deep or L.board.shade) end
    if y >= RY1 - 1 and hash(x, y, 109) < .4 then px(x, y, L.moss.shade) end
  end)
  hline(RX0 + 4, RX1 - 4, RY0, L.board.hi)
  -- a low tarred transom along the back of the deck
  local tran = rect(RX0 + 5, RY0 - 2, RX1 - 5, RY0 - 1)
  rimOf(tran, TAR) fill(tran, TAR.base) hline(RX0 + 5, RX1 - 5, RY0 - 2, TAR.hi)
  -- rail posts and the far rail rope
  local posts = HP.mask()
  for _, x in ipairs({ RX0 + 1, RX1 - 2 }) do posts:add(rect(x, RY1 - 9, x + 1, RY1)) end
  local backPosts = rect(RX0 + 5, RY0 - 8, RX0 + 6, RY0)
  local guide = rect(RX1 - 6, RY0 - 18, RX1 - 5, RY0)
  rimOf(union(backPosts, guide), L.timber) part(union(backPosts, guide), L.timber, { nopop = true, noshade = true })
  for x = RX0 + 6, RX1 - 6 do px(x, RY0 - 6 + floor(2 * sin((x - RX0) / (RX1 - RX0) * pi)), L.board.shade) end
  -- the guide rope slung across the channel: far post -> pulley on the guide post -> the lantern post by the stage
  do
    local fp = rect(396, 100, 397, 124) rimOf(fp, L.timber) part(fp, L.timber, { nopop = true, noshade = true })
    fill(rect(394, 99, 399, 99), L.timber.deep)
    local function rope(ax, ay, bx, by, sag)
      local prev
      for xx = math.min(ax, bx), math.max(ax, bx) do
        local t = (xx - ax) / (bx - ax)
        local yy = floor(ay + (by - ay) * t + sag * 4 * t * (1 - t) + .5)
        if xx % 3 == 0 then px(xx, yy, L.board.base) else px(xx, yy, L.timber.deep) end
        if prev and abs(yy - prev) > 1 then vline(xx, math.min(yy, prev) + 1, math.max(yy, prev) - 1, L.timber.deep) end
        prev = yy
      end
    end
    rope(398, 101, RX1 - 5, RY0 - 17, 2)
    rope(RX1 - 6, RY0 - 17, 284, 151, 4)
    -- the pulley block
    local pb = c:ellipse(RX1 - 5, RY0 - 17, 2, 2) rimOf(pb, L.iron) part(pb, L.iron, { nopop = true }) px(RX1 - 5, RY0 - 17, L.iron.deep)
  end
  -- cargo: milk churns, a stack of reed bundles end-on, an eel basket
  for _, cx in ipairs({ RX0 + 9, RX0 + 16 }) do
    local ch = c:rrect(cx - 3, RY0 - 4, cx + 3, RY0 + 6, 2):add(rect(cx - 1, RY0 - 6, cx + 1, RY0 - 4))
    c:rim(ch, L.iron.edge) part(ch, L.iron) hline(cx - 3, cx + 3, RY0 - 1, L.iron.deep) px(cx - 2, RY0 - 3, L.iron.hi)
  end
  for row = 0, 1 do for k = 0, 2 - row do bundleEnd(RX1 - 32 + k * 6 + row * 3, RY0 + 6 - row * 5, 3) end end
  do -- the eel basket (a round wicker skep) with an eel looping over the rim
    local bx, by = RX0 + 66, RY0 + 8
    local bk = c:rrect(bx - 5, by - 6, bx + 5, by + 2, 2)
    rimOf(bk, L.reed) part(bk, L.reed, { nopop = true })
    bk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.reed.shade) elseif (x - y) % 4 == 0 then px(x, y, L.reed.hi) end end)
    hline(bx - 4, bx + 4, by - 6, L.reed.deep)
    for k = 0, 6 do px(bx - 3 + k, by - 7 - floor(1.5 * sin(k / 2)), k < 3 and L.foliage.shade or L.foliage.deep) end
  end
  -- the trunk the otter sits on
  local T0 = RX0 + 40
  local tk = rect(T0, RY0 + 1, T0 + 18, RY0 + 9)
  c:rim(tk, L.timber.edge) part(tk, L.awnA) hline(T0, T0 + 18, RY0 + 4, L.timber.deep) vline(T0 + 6, RY0 + 1, RY0 + 9, L.gold.shade) vline(T0 + 12, RY0 + 1, RY0 + 9, L.gold.shade)
  fill(rect(T0 + 8, RY0 + 4, T0 + 10, RY0 + 6), L.gold.base) px(T0 + 8, RY0 + 4, L.gold.hi)
  -- the traveller with a big bundle on a stick
  local gx = RX0 + 28
  fill(line({ { gx + 7, FY - 17 }, { gx - 9, FY - 23 } }), L.board.base)
  local bun = c:ellipse(gx - 11, FY - 23, 4, 4) c:rim(bun, L.timber.edge) part(bun, L.accent, { nopop = true })
  bun:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.awnB.hi) end end) px(gx - 11, FY - 27, L.accent.deep)
  F.gnome(gx, FY, { hat = L.lav, coat = L.roof, arm = "up", noShadow = true })
  -- QUIRK: the otter in the red gnome hat, riding on the trunk with its fish
  otter(T0 + 1, RY0 - 23)
  -- the ferryman, poling from the back right corner
  local _, fx, fy = F.gnome(RX1 - 14, FY, { hat = L.foliage, coat = L.accent, arm = "up", flip = false, noShadow = true, hatBand = L.gold.base })
  local pole = line({ { fx - 3, fy - 10 }, { fx + 14, RY1 + 16 } }, 1)
  fill(pole, L.board.shade) line({ { fx - 2, fy - 10 }, { fx + 15, RY1 + 16 } }):each(function(x, y) if y < RY1 + 4 then px(x, y, L.board.hi) end end)
  for k = 0, 2 do hline(fx + 10 - k * 3, fx + 18 + k * 3, RY1 + 17 + k * 2, Wt.hi) end
  -- near rail posts and rope in front of everyone
  rimOf(posts, L.timber) part(posts, L.timber, { nopop = true, noshade = true })
  for x = RX0 + 2, RX1 - 2 do px(x, RY1 - 7 + floor(2 * sin((x - RX0) / (RX1 - RX0) * pi)), L.board.deep) end
end

---------------------------------------------------------------- near stage: gnome hauling the tow rope
F.depth(3)
do
  local _, hx, hy = F.gnome(244, 200, { hat = L.roof2, coat = L.board, arm = "up" })
  local x0, y0 = RX0 + 2, RY1 - 8
  local pts = {}
  for xx = hx, x0 do local t = (xx - hx) / (x0 - hx) pts[#pts + 1] = { xx, floor(hy + (y0 - hy) * t + 9 * 4 * t * (1 - t) + .5) } end
  local rope = line(pts, 2)
  c:rim(rope, L.timber.edge)
  rope:each(function(x, y) local top = not rope:has(x, y - 1) px(x, y, top and L.board.hi or L.board.base) if (x + y) % 3 == 0 then px(x, y, L.board.shade) end end)
  for _, p in ipairs(pts) do if p[2] > yN(p[1]) - 3 and p[1] % 5 == 0 then px(p[1], p[2] + 2, GLINT) end end
  local coil = c:ellipse(232, 200, 6, 2) c:rim(coil, L.timber.edge) part(coil, L.board, { nopop = true }) c:ellipse(232, 200, 3, 1):edge():each(function(x, y) px(x, y, L.board.deep) end)
  local tail = line({ { hx - 1, hy + 1 }, { 236, 198 } }, 2) c:rim(tail, L.timber.edge) fill(tail, L.board.base) tail:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.board.shade) end end)
end

-- a pollard willow and a reed bed at the left of the near bank (behind the booth)
F.depth(3)
F.tree(106, 190, 40, 3)
F.reeds(0, 30, 196, 26, 701, { cattails = 3 })

DY = 10
---------------------------------------------------------------- near bank left: bell frame, ferry sign, booth, bench, punt
do -- the ferry bell on a frame under a little reed thatch
  local fr = rect(186, 150, 187, 196):add(rect(206, 150, 207, 196)):add(rect(183, 148, 210, 150))
  F.shadow(186, 208, 197, 6, 3)
  rimOf(fr, L.timber) part(fr, L.timber, { nopop = true, noshade = true }) hline(183, 210, 148, L.timber.hi)
  local roofb = poly{ { 180, 148 }, { 196, 139 }, { 213, 148 } }
  rimOf(roofb, L.roof) part(roofb, L.roof, { nopop = true }) F.thatch(roofb, L.roof, 139, 196)
  fill(rect(194, 138, 198, 140), L.roof2.shade) hline(194, 198, 138, L.roof2.base)
  vline(196, 151, 153, L.iron.shade)
  local bell = poly{ { 193, 154 }, { 199, 154 }, { 201, 163 }, { 203, 165 }, { 189, 165 }, { 191, 163 } }:add(c:ellipse(196, 155, 3, 2))
  c:rim(bell, L.timber.edge) part(bell, L.gold) vline(193, 156, 163, L.gold.hi) hline(190, 202, 164, L.gold.shade)
  fill(rect(195, 166, 197, 167), L.iron.base)
  fill(line({ { 197, 167 }, { 199, 180 } }), L.board.shade)
  -- a bulrush sheaf tied to the frame
  for k = 0, 2 do F.cattail(209 + k, 196, 18 - k * 3, k == 0) end
end
do -- the ferry sign: a painted punt on still water, a heron on the bank
  local post = rect(170, 168, 171, 200)
  local bd = rect(156, 152, 185, 168)
  rimOf(union(post, bd), L.timber) part(post, L.timber, { nopop = true }) part(bd, L.board, { nopop = true })
  c:edgeIn(bd, L.board.deep)
  fill(rect(158, 162, 183, 166), L.water.base) hline(158, 183, 162, SKY) hline(160, 166, 165, L.water.hi) hline(172, 181, 164, L.water.hi)
  fill(rect(164, 159, 180, 161), TAR.base) hline(163, 181, 159, TAR.hi) px(163, 159, TAR.base) px(181, 159, TAR.base) hline(164, 180, 160, L.awnA.base)
  vline(169, 154, 158, L.timber.edge) fill(rect(172, 155, 175, 158), L.awnA.base) -- passengers
  fill(line({ { 178, 153 }, { 183, 166 } }), L.timber.deep) -- the pole
  F.sprite({ ".kk", "kk.", ".k.", ".kk", ".k.", ".k." }, 158, 155, { k = L.heron.deep }, { rim = false })
  for k = 0, 3 do px(158 + k * 2, 167, L.reedGreen.base) px(158 + k * 2, 166, L.reedGreen.hi) end
end
F.depth(3)
do -- the ticket booth: tarred weatherboard, golden reed thatch with a sedge ridge, a gnome in the hatch
  local wall = rect(38, 168, 92, 200)
  local roof = poly{ { 32, 171 }, { 65, 145 }, { 98, 171 } }:add(rect(32, 168, 98, 172))
  F.shadow(40, 92, 200, 10, 4)
  rimOf(union(wall, roof), TAR)
  part(wall, TAR) F.planks(wall, TAR, 4, false, 3)
  wall:each(function(x, y) if x <= 40 then px(x, y, TAR.hi) end if y > 195 and hash(x, y // 2, 121) < .45 then px(x, y, L.moss.shade) end end)
  part(roof, L.roof, { sep = true }) F.thatch(roof, L.roof, 145, 65)
  line({ { 32, 171 }, { 65, 145 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  -- sedge ridge cap and a ragged eave
  local cap = poly{ { 58, 151 }, { 65, 144 }, { 72, 151 } } rimOf(cap, L.roof2) part(cap, L.roof2, { nopop = true })
  for x = 32, 98 do if hash(x, 1, 122) < .5 then px(x, 173, L.roof.deep) end end
  -- hatch with awning
  local hatch = rect(50, 178, 80, 192)
  fill(hatch, L.soil.deep) c:edgeIn(hatch, L.board.hi)
  fill(rect(51, 179, 56, 183), L.glow.shade) px(52, 180, L.glow.base) -- a lamp lit inside
  F.gnome(65, 198, { hat = L.awnA, coat = L.accent, arm = "out", noShadow = true })
  local sill = rect(48, 192, 82, 194) rimOf(sill, L.timber) part(sill, L.board, { nopop = true })
  fill(rect(76, 189, 78, 191), L.awnB.hi) px(77, 189, L.awnA.base) -- a ticket
  local aw = poly{ { 46, 172 }, { 84, 172 }, { 88, 178 }, { 42, 178 } }
  rimOf(aw, L.awnA) fill(aw, L.awnA.base)
  aw:each(function(x, y) if ((x - 42) // 5) % 2 == 1 then px(x, y, L.awnB.base) end if y == 178 then px(x, y, ((x // 3) % 2 == 0) and L.awnA.deep or L.awnA.shade) end end)
  hline(46, 84, 172, L.awnA.hi)
  F.window(86, 158, 88, 161, L.timber)
  -- a round plaque over the hatch: a painted eel
  local plaque = c:ellipse(65, 162, 5, 4) rimOf(plaque, L.timber) part(plaque, L.board, { nopop = true })
  for k = 0, 6 do px(62 + k, 162 + floor(sin(k * 1.2) + .5), L.foliage.deep) end px(61, 162, L.foliage.shade)
end
do -- bench with two waiting travellers and their luggage
  F.gnome(112, 214, { hat = L.roof, coat = L.lav, arm = "hold", noShadow = true })
  F.gnome(134, 215, { hat = L.accent, coat = L.awnA, flip = true, noShadow = true })
  local seat = rect(100, 207, 146, 209)
  local legs = rect(103, 210, 104, 218):add(rect(142, 210, 143, 218))
  F.shadow(102, 146, 219, 8, 3)
  rimOf(union(seat, legs), L.timber) part(legs, L.timber, { nopop = true, noshade = true }) part(seat, L.board, { nopop = true }) hline(100, 146, 207, L.board.hi)
  local tr = c:rrect(150, 204, 168, 218, 3):clip(rect(150, 204, 168, 218))
  F.shadow(150, 168, 219, 5, 2)
  rimOf(tr, L.timber) part(tr, L.redbark) hline(150, 168, 209, L.iron.base) vline(155, 204, 218, L.iron.shade) vline(163, 204, 218, L.iron.shade) px(159, 211, L.glow.hi)
  local bag = c:rrect(152, 222, 166, 232, 3) rimOf(bag, L.timber) part(bag, L.lav)
  bag:each(function(x, y) if (x + y) % 4 == 0 then px(x, y, L.lav.hi) end end)
  fill(c:ellipse(159, 221, 3, 2):cut(c:ellipse(159, 221, 1, 1)):clip(rect(150, 218, 168, 221)), L.timber.base)
end
do -- a duck punt drawn up on the mud, eel hives in it, a pole across
  local y = 228
  local hull = poly{ { 16, y - 3 }, { 84, y - 3 }, { 78, y + 6 }, { 22, y + 6 } }
  local inside = rect(22, y - 3, 78, y - 1)
  F.shadow(22, 80, y + 7, 6, 3)
  rimOf(hull, TAR)
  part(hull, TAR, { nopop = true }) hline(16, 84, y - 3, TAR.hi) hline(20, 80, y + 1, L.accent.base) hline(21, 79, y + 2, L.accent.shade)
  hull:each(function(x, y2) if y2 >= y + 4 and hash(x // 2, y2, 117) < .45 then px(x, y2, L.moss.shade) end end)
  fill(inside, L.board.shade) hline(22, 78, y - 3, L.board.base)
  eelHive(28, y - 5, 14, 3) eelHive(46, y - 4, 12, 3)
  fill(line({ { 18, y - 8 }, { 84, y - 2 } }), L.board.base)
end
DY = 0
-- near bulrush and reed beds on both sides of the stage
F.reeds(202, 226, yN(214) + 3, 22, 711, { cattails = 4, green = true })
F.reeds(108, 132, yN(120) + 3, 18, 712, { cattails = 2 })
F.reeds(380, 404, yN(392) + 3, 22, 713, { cattails = 3, green = true })
F.reeds(444, 462, yN(452) + 3, 20, 714, { cattails = 2 })

---------------------------------------------------------------- the channel right: lilies, a frog, a moored punt, a kingfisher
F.depth(3)
DY = 8
for _, p in ipairs({ { 360, 168, true, "white" }, { 376, 174, true }, { 344, 176, false }, { 412, 160, true, "yellow" }, { 352, 172, false }, { 392, 166, true }, { 428, 168, false, "white" } }) do F.lily(p[1], p[2], p[3], p[4]) end
F.frog(377, 172, false)
do -- a punt tied to a stake, a kingfisher on the stake
  local y = 178
  F.punt(420, 470, y + 2, TAR)
  eelHive(436, y - 4, 12, 2)
  local st = rect(410, y - 12, 412, y + 6) rimOf(st, L.timber) part(st, L.timber, { nopop = true, noshade = true })
  hline(408, 414, y + 7, Wt.hi)
  fill(line({ { 412, y - 8 }, { 422, y - 1 } }), L.board.shade)
  kingfisher(411, y - 13)
end

---------------------------------------------------------------- near bank right: cargo waiting to cross, a turf stack, a gnome
F.depth(3)
do
  F.crate(300, 222, 18, 12, L.apple) F.crate(318, 222, 16, 12) F.crate(306, 209, 16, 10, L.produce)
  F.sack(342, 224, L.plaster, 7) F.sack(354, 226, L.board, 6)
  F.barrel(288, 224, L.timber, 12)
  local _, hx, hy = F.gnome(372, 236, { hat = L.lav, coat = L.leaf, arm = "out", flip = true })
  local ap = c:ellipse(hx - 1, hy - 2, 2, 2) c:rim(ap, L.timber.edge) part(ap, L.apple, { nopop = true }) px(hx - 1, hy - 5, L.leaf.base)
  -- the lantern post at the stage's right, where the guide rope is made fast
  local lp = rect(280, 160, 281, 200) rimOf(lp, L.timber) part(lp, L.timber, { nopop = true, noshade = true })
  local lam = rect(277, 152, 284, 160) rimOf(lam, L.timber) fill(lam, L.glow.base) fill(rect(278, 153, 280, 158), L.glow.hi) vline(284, 153, 160, L.glow.shade)
  fill(rect(276, 150, 285, 151), L.timber.base)
  fill(rect(282, 162, 283, 164), L.board.base) px(283, 165, L.board.shade) -- the rope's lashing
end
-- foreground: a wheelbarrow of cut peat turves waiting for the ferry, sunk stones
do
  local y = 250
  local tray = poly{ { 96, y - 12 }, { 132, y - 12 }, { 128, y - 2 }, { 100, y - 2 } }
  local legs = rect(102, y - 2, 103, y + 4):add(line({ { 132, y - 8 }, { 146, y - 2 } }, 2))
  local wh = c:ellipse(92, y, 5, 5)
  F.shadow(92, 132, y + 5, 8, 3)
  rimOf(union(tray, legs, wh), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true })
  part(tray, L.board) F.planks(tray, L.board, 5, true, 2)
  part(wh, L.timber, { nopop = true }) px(92, y, L.iron.hi) hline(88, 96, y, L.timber.deep)
  for k = 0, 3 do turf(100 + k * 7, y - 16) end
  for k = 0, 2 do turf(103 + k * 7, y - 20) end
  turf(107, y - 24) turf(114, y - 24)
end
F.moss(F.rock(160, 254, 9, 6), .3, 121) F.rock(172, 257, 5, 4)
F.moss(F.rock(70, 254, 6, 4), .3, 122)
do -- a stack of drying peat turves on the near right
  F.shadow(194, 230, 236, 6, 3)
  for row = 0, 3 do for k = 0, 3 - row do turf(196 + k * 8 + row * 4, 230 - row * 5, 8) end end
end
for _, f in ipairs({ { 30, 216, 6 }, { 148, 246, 6 }, { 186, 242, 7 }, { 270, 214, 5 }, { 362, 214, 5 }, { 60, 262, 7 }, { 290, 250, 7 }, { 330, 258, 6 }, { 214, 214, 5 }, { 96, 224, 5 } }) do F.sedge(f[1], f[2], f[3]) end
for _, f in ipairs({ { 152, 248 }, { 268, 226 }, { 336, 260 }, { 34, 218 } }) do px(f[1] - 1, f[2] - 5, L.marigold.base) px(f[1] + 1, f[2] - 4, L.marigold.hi) px(f[1], f[2] - 6, L.marigold.shade) end

---------------------------------------------------------------- bank sedge, a fisher gnome, a goose after the apple
DY = 0
F.depth(3)
for x = 0, 479 do
  local yn = yN(x)
  if hash(x, 1, 91) < .5 and not F.roadM:has(x, yn + 1) and not (x > 190 and x < 290) then
    local h = 2 + floor(hash(x, 2, 91) * 5)
    local r = hash(x, 4, 91) < .35 and L.reed or L.reedGreen
    vline(x, yn + 4 - h, yn + 4, r.shade) px(x, yn + 4 - h, r.base) if h > 3 then px(x, yn + 3 - h, r.hi) end
  end
  if hash(x, 3, 91) < .04 then px(x, yn + 5, L.stone.base) px(x + 1, yn + 5, L.stone.shade) px(x, yn + 4, L.moss.hi) end
end
do -- the fisher gnome on an upturned bucket, rod out over the reeds, an eel in the creel
  local bk = poly{ { 410, 210 }, { 422, 210 }, { 420, 220 }, { 412, 220 } }
  F.shadowM(c:ellipse(418, 222, 10, 1))
  rimOf(bk, L.timber) part(bk, L.board) hline(410, 422, 213, L.iron.shade) hline(411, 421, 218, L.iron.shade)
  local _, hx, hy = F.gnome(416, 210, { hat = L.awnA, coat = L.wall2, arm = "up", flip = true, noShadow = true, hatBand = L.gold.base })
  local rod = line({ { hx, hy + 2 }, { 380, 176 } })
  fill(rod, L.timber.shade) px(380, 176, L.timber.deep)
  for y = 177, 190 do px(380 - floor((y - 177) * .2), y, L.awnB.shade) end
  px(377, 191, L.apple.base) px(377, 190, GLINT) hline(372, 382, 192, Wt.hi)
  local cr = c:rrect(428, 212, 442, 222, 2) rimOf(cr, L.timber) part(cr, L.reed)
  cr:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.reed.shade) end end)
  -- an eel looping out of the creel
  for k = 0, 8 do local ex, ey = 430 + k, 211 - floor(3 * sin(k / 2.6)) px(ex, ey, L.foliage.shade) px(ex, ey + 1, L.foliage.deep) end
  px(439, 209, L.foliage.base) px(440, 209, L.timber.edge)
end
-- a greylag goose stretching its neck at the gnome's apple
F.sprite({
  "..........kk.",
  ".........kWWo",
  "..........Ww.",
  "..........W..",
  ".........WW..",
  "........WW...",
  "..WWWWWWWw...",
  ".WWWWwwwww...",
  "WWWwwwwwws...",
  ".swwwwwss....",
  "...ss.ss.....",
  "....o..o.....",
}, 340, 228, { W = L.goose.hi, w = L.goose.base, s = L.goose.shade, k = L.goose.deep, o = L.produce.base })
F.dragonfly(300, 196, L.accent) F.dragonfly(436, 196, L.apple, true)

F.depth(0)
-- a skein of geese and a heron flying over
F.birds({ { 300, 40, 2 }, { 307, 43, 2 }, { 314, 46, 2 }, { 293, 43, 2 }, { 286, 46, 2 }, { 150, 62, 1 } })
F.sprite({
  "..........gggg........",
  ".........gwwwwg.......",
  "..YkWW...gwwwwwg......",
  ".YYWWWWgwwwwwwwwg.....",
  "....WWWWWWWWWWWWWWWYYY",
  ".....gggWWWWWWWWgg....",
  ".......gggggggg.......",
}, 360, 60, { W = L.heron.hi, w = L.heron.base, g = L.heron.deep, Y = L.marigold.shade, k = L.timber.edge }, { rim = false })
F.finish()
