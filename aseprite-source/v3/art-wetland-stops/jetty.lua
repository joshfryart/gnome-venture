-- jetty.lua : "Lakeside jetty" stop look, WETLAND (wetland_reed), 480x270 gate view.
-- Same composition as the Maplewold jetty (art-2701-batch3/stops/opus3/jetty.lua), re-cast for a reed fen:
-- right half: a still, misted broad (open fen water) under the far reed-and-willow shore, its trees mirrored in the
-- water, mist lying in banks; a reed fringe along the near diagonal shore; a silver timber landing stage on piles
-- with a moored punt, a lantern post and a gnome fishing off the end; wicker eel hives on the boards; a raft of
-- painted duck decoys (with one real drake fooled into joining them); a reed-thatched boathouse on stilts; a black-
-- sailed wherry on the far water; a great crested grebe carrying two chicks; a rising roach.
-- Left: the fisher's tarred weatherboard cottage under dark sedge thatch, an eel-smoking rack, the net drying frame
-- (tanned net, cork floats), standing bottle traps, an upturned punt being tarred on trestles, eel hives lying in
-- the sedge, an otter eyeing the basket of eels. Shore: an eel glaive, a coil of rope, two decoys drying, a moorhen.
-- Quirk (kept): the grey heron helping itself to the fish bucket, now wearing a red gnome hat.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-wetland-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "jetty", out = DIR, farTrees = { 24, 52, 120, 196, 290, 352, 440 }, noPools = true }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local mix, rp = F.mix, F.rp
local W = L.water
local TAR = rp("#8a8c80 #64685e #4a4e48 #363a36 #24282a")     -- tarred weatherboard / tarred hull
local WICK = rp("#d8c088 #b49660 #8c7044 #64502e #3e3020")    -- willow-withy wicker (eel hives, baskets)
local NET = rp("#b08a64 #8a6646 #684a34 #4a3428 #2e2018")     -- cutch-tanned net
local CORK = rp("#e2c48e #c2a068 #9a7a4c #6e5636 #463624")
local EEL = rp("#9a9a72 #6e7254 #50563e #383e30 #242a22")    -- eel skin: olive back, pale belly
local function lum(h)
  local r, g, b = tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16)
  return (r * .3 + g * .59 + b * .11) / 255
end

---------------------------------------------------------------- local helpers
-- an eel hive lying on its side: a long wicker cone, mouth (dark funnel) toward `dir` (1 = mouth right), tail tied off
local function eelHive(x0, yb, len, dir, r)
  r = r or WICK
  dir = dir or 1
  local hh = math.max(5, len // 3)
  local m = HP.mask()
  for i = 0, len do
    local t = i / len -- 0 = mouth, 1 = tail
    local h = floor(hh * (1 - t * .62) + .5)
    local x = dir == 1 and (x0 + len - i) or (x0 + i)
    for y = yb - h, yb do m:set(x, y) end
  end
  rimOf(m, r)
  m:each(function(x, y)
    local i = dir == 1 and (x0 + len - x) or (x - x0)
    local t = i / len
    local h = floor(hh * (1 - t * .62) + .5)
    local d = (y - (yb - h)) / math.max(1, h)
    local col = d < .3 and r.hi or (d < .7 and r.base or r.shade)
    if (x + (y * 2)) % 4 == 0 then col = (d < .5) and r.base or r.deep end -- weave
    if i % 5 == 0 then col = r.deep end -- hoops
    px(x, y, col)
  end)
  -- the mouth: a dark funnel opening, lit rim
  local mx = dir == 1 and (x0 + len) or x0
  vline(mx, yb - hh + 1, yb - 1, L.soil.deep) vline(mx - dir, yb - hh + 2, yb - 2, r.deep)
  px(mx, yb - hh, r.hi)
  -- the tail tie
  local tx = dir == 1 and x0 or (x0 + len)
  px(tx - dir, yb - 1, L.timber.base) px(tx - 2 * dir, yb, L.timber.deep)
  return m
end
-- a standing bottle-shaped wicker trap (putt / grig): fat body, narrow neck, dark mouth on top
local function bottleTrap(x, yb, h, r)
  r = r or WICK
  local w = math.max(3, h // 3)
  local m = c:rrect(x - w, yb - floor(h * .7), x + w, yb, w - 1):add(rect(x - w // 2, yb - h, x + w // 2, yb - floor(h * .6)))
  rimOf(m, r)
  m:each(function(xx, yy)
    local col = (xx < x - w // 3) and r.hi or ((xx > x + w // 3) and r.shade or r.base)
    if (yy - yb) % 3 == 0 then col = r.deep end
    if (xx + yy) % 3 == 0 and col ~= r.deep then col = (xx < x) and r.base or r.deep end
    px(xx, yy, col)
  end)
  hline(x - w // 2 + 1, x + w // 2 - 1, yb - h, L.soil.deep)
  return m
end
-- a painted wooden mallard decoy, floating (swim) or sitting on the ground; drake = green head, grey back, chestnut breast
local function decoy(x, yb, drake, swim, flip)
  local rows = {
    ".hh.......",
    "hHkh......",
    "ohhh......",
    ".nbbBBBBg.",
    "bbBBBBBBBg",
    "bBBBBBBBgg",
    ".ggggggg..",
  }
  if flip then for i, row in ipairs(rows) do rows[i] = row:reverse() end end
  local map
  if drake then
    map = { h = "#4e7a58", H = "#86ac72", k = L.timber.edge, o = L.marigold.base, n = L.awnB.base, b = "#8a4a34", B = "#a8a89a", g = "#6e6e66" }
  else
    map = { h = "#8a6a48", H = "#b08a60", k = L.timber.edge, o = L.produce.shade, n = "#a48462", b = "#7a5a3c", B = "#9a7a56", g = "#5e4632" }
  end
  local m = F.sprite(rows, x - 5, yb - 6, map)
  -- painted wing speculum and a lit top line
  px(x + (flip and -2 or 2), yb - 2, "#5a74a0") px(x + (flip and -3 or 3), yb - 2, "#5a74a0")
  if swim then
    for xx = x - 7, x + 7 do if hash(xx, yb, 211) < .7 then px(xx, yb + 1, (xx < x) and W.hi or F.SKYREF) end end
    hline(x - 3, x + 3, yb + 2, W.shade)
  end
  return m
end
-- the cut end of a reed bundle, face-on (as in the mill)
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

---------------------------------------------------------------- the broad (open fen water)
local WL = 119 -- waterline under the far reed shore
local lake = poly{ { 266, WL }, { 479, WL }, { 479, 228 }, { 372, 228 }, { 350, 220 }, { 326, 202 }, { 304, 176 }, { 288, 150 }, { 276, 130 } }
-- a peat-and-mud margin along the near diagonal shore, with a band of wet sedge
local margin = lake:grow(4):cut(lake):clip(rect(0, WL, 479, 269))
margin:each(function(x, y)
  local v = hash(x, y, 5)
  local h = v < .35 and L.peat.base or (v < .6 and L.peat.shade or (v < .8 and L.peat.hi or L.sedgeGround.shade))
  if hash(x // 2, y // 2, 6) < .12 then h = L.sedgeGround.base end
  px(x, y, h)
end)
lake:edge():each(function(x, y) if y > WL then px(x, y, L.peat.deep) end end)
-- still water: pale sky band far off, the gold sky reflection, dark grey-teal near the landing stage
local T1 = mix(W.hi, L.mist, .35)
local T2 = mix(W.hi, F.SKYREF, .5)
local T3 = mix(F.SKYREF, W.base, .5)
local T4 = W.base
local T5 = mix(W.base, W.shade, .55)
local T6 = mix(W.shade, W.deep, .3)
local shallowC = mix(W.base, L.peat.base, .5)
local shallow2 = mix(T4, L.peat.shade, .25)
lake:shrink(1):each(function(x, y)
  local d = y - WL
  local h
  if d < 4 then h = T1
  elseif d < 12 then h = hash(x // 9, y, 14) < .6 and T1 or T2
  elseif d < 24 then h = hash(x // 9, y, 14) < .55 and T2 or T3
  elseif d < 38 then h = hash(x // 8, y, 15) < .45 and T3 or T4
  elseif d < 62 then h = T4
  elseif d < 84 then h = hash(x // 7, y // 2, 15) < .55 and T4 or T5
  else h = hash(x // 7, y // 2, 16) < .35 and T5 or T6 end
  if not lake:has(x - 7, y) or not lake:has(x, y + 7) or not lake:has(x + 5, y + 5) then h = shallow2 end
  if not lake:has(x - 3, y) or not lake:has(x, y + 3) or not lake:has(x + 2, y + 2) then h = shallowC end
  px(x, y, h)
end)
-- the far reed shore and its willows mirrored in the still water, sinking into the water colour, broken by streaks
for xx = 266, 479 do
  for k = 1, 26 do
    local sy, dy = WL - k, WL - 1 + k
    if lake:has(xx, dy) and lake:has(xx, dy + 1) and not margin:has(xx, dy) then
      local v = c:get(xx, sy)
      if v and lum(v) < .66 and not (dy % 3 == 0 and hash(xx // 5, dy, 84) < .5) then
        local t = .3 + k * .014
        local h = mix(mix(v, T5, t), L.mist, k < 5 and .22 or .06)
        px(xx, dy, h)
      end
    end
  end
end
-- long thin sky streaks (still water: no ripple pairs), gold near, pale far
for y = WL + 3, 226 do
  local d = y - WL
  local gap = 3 + d // 16
  if y % gap == 0 then
    local x0 = 268 + floor(hash(y, 1, 13) * 40)
    while x0 < 478 do
      local len = 6 + floor(d / 3) + floor(hash(x0, y, 19) * 14)
      if hash(x0 // 11, y, 16) < .5 then
        for xx = x0, x0 + len do if lake:has(xx, y) and lake:has(xx + 2, y) and not margin:has(xx, y) then
          px(xx, y, d < 30 and T1 or (hash(xx // 4, y, 20) < .5 and F.SKYREF or T2)) end end
      end
      x0 = x0 + len + 10 + floor(hash(x0, y, 17) * 26)
    end
  end
end
-- a few cream glints
for k = 0, 26 do local gx, gy = 280 + floor(hash(k, 1, 18) * 196), 128 + floor(hash(k, 2, 18) * 92) if lake:has(gx, gy) and lake:has(gx + 2, gy) then px(gx, gy, "#f2eac8") px(gx + 1, gy, T2) end end
-- a roach rising: rings and a silver-red fish
do
  local fx, fy = 364, 156
  c:ellipse(fx, fy + 6, 9, 2):edge():each(function(x2, y2) px(x2, y2, T2) end)
  c:ellipse(fx, fy + 6, 14, 3):edge():each(function(x2, y2) if (x2 // 2) % 2 == 0 then px(x2, y2, T2) end end)
  F.sprite({ "...ff..", ".fffff.", "fGGrGe.", ".fGGr..", "f.f....", }, fx - 3, fy - 4,
    { f = L.stone.shade, G = L.stone.hi, r = L.awnA.base, e = L.timber.edge })
  for _, d in ipairs({ { -6, 2 }, { 5, 3 }, { -4, -1 }, { 7, 0 } }) do px(fx + d[1], fy + d[2], W.hi) end
end
-- lily pads (white and yellow lilies) in the shallows along the reed fringe
for _, p in ipairs({ { 300, 160, true, "white" }, { 316, 176, true }, { 330, 192, false, "yellow" }, { 344, 206, true }, { 292, 146, false },
  { 352, 214, false, "white" }, { 310, 168, false } }) do F.lily(p[1], p[2], p[3], p[4]) end

---------------------------------------------------------------- the grebe with two chicks riding on her back
local function grebe(gx, gy)
  F.sprite({
    "...KK..............",
    "..KKKK.............",
    "bbWWrK.............",
    "..WrrK.............",
    "...WgK......SsS....",
    "...WgK.....SWSWSk..",
    "...WgGGGGGGgSsSGgg.",
    "..WWGGGGGGGGGGGGGgg",
    "...WwGGGGGGGGGGggg.",
    "....wwwwwwwwwwwww..",
  }, gx, gy, { K = "#3e3632", W = "#ece2c8", r = "#b0623c", b = "#c8968a", g = "#6e6456", G = "#9a8e7a", w = "#c8c0a2",
    S = "#3e3a36", s = "#e2d8bc", k = "#c8968a" })
  for k = 0, 2 do hline(gx + 3 - k * 3, gx + 18 + k * 3, gy + 10 + k * 2, k == 0 and T5 or T2) end
  hline(gx - 7, gx + 1, gy + 10, T2) -- wake
end
grebe(316, 150)

---------------------------------------------------------------- far water: a black-sailed wherry, the boathouse on stilts
F.depth(1)
do -- the wherry: long tarred hull, one tall black gaff sail, a pale vane on the masthead
  local x, y = 300, 133
  local hull = poly{ { x - 14, y - 2 }, { x + 14, y - 2 }, { x + 10, y + 2 }, { x - 11, y + 2 } }
  local sail = poly{ { x - 1, y - 3 }, { x - 1, y - 18 }, { x + 9, y - 27 }, { x + 11, y - 3 } }
  local mast = rect(x - 2, y - 30, x - 2, y - 2)
  rimOf(union(hull, sail, mast), L.timber)
  part(hull, TAR, { nopop = true }) hline(x - 13, x + 13, y - 2, L.awnB.shade) hline(x - 10, x + 9, y + 1, TAR.deep)
  local SAIL = rp("#7a7064 #4e4844 #3e3a38 #302e2e #222222")
  part(sail, SAIL, { nopop = true })
  sail:each(function(xx, yy) if (yy - (y - 27)) % 5 == 0 then px(xx, yy, SAIL.deep) end if xx >= x + 9 then px(xx, yy, SAIL.hi) end end)
  line({ { x - 1, y - 18 }, { x + 9, y - 27 } }):each(function(xx, yy) px(xx, yy, L.timber.base) end) -- gaff
  vline(x - 2, y - 30, y - 2, L.timber.base)
  hline(x - 1, x + 3, y - 31, L.awnA.base) px(x + 3, y - 30, L.awnA.shade) -- vane
  -- its reflection: a dark broken column
  for k = 1, 10 do if k % 3 ~= 0 then hline(x - 1 + k // 4, x + 9 - k // 3, y + 2 + k, mix(SAIL.base, T2, .45 + k * .03)) end end
  for k = 0, 2 do hline(x - 12 + k * 2, x + 10 - k * 2, y + 3 + k * 2, T5) end
end
F.depth(2)
local function boathouse()
  local top, cx, wallM, roofM = F.building{ x0 = 388, x1 = 444, yb = 140, wh = 26, rh = 20, wall = L.wall2, roof = L.roof,
    noShadow = true, noFrame = true, noAttic = true }
  F.planks(wallM:copy():clip(rect(388, top + 2, 444, 140)), L.wall2, 4, true, 23)
  F.window(426, 120, 432, 125, L.timber)
  -- big water door, dark water inside with a punt's bow poking out
  local d = rect(396, 124, 416, 140) fill(d, L.soil.deep) fill(rect(398, 134, 414, 140), W.deep)
  hline(399, 413, 137, W.shade) hline(396, 416, 124, L.timber.hi) vline(396, 124, 140, L.timber.base) vline(416, 124, 140, L.timber.shade)
  local bow = poly{ { 400, 136 }, { 412, 136 }, { 410, 139 }, { 402, 139 } }
  rimOf(bow, L.timber) part(bow, TAR, { nopop = true }) hline(400, 412, 136, L.board.base)
  -- reed bundles stacked under the eaves on the left
  for k = 0, 2 do bundleEnd(391 + k * 0, 128 + k * 4, 2) end
  F.stilts({ 390, 398, 406, 414, 422, 430, 438, 442 }, 141, 154, 149)
  for _, sx in ipairs({ 390, 398, 406, 414, 422, 430, 438, 442 }) do for y2 = 156, 162, 2 do if lake:has(sx, y2) then px(sx, y2, T6) px(sx + 1, y2, T5) end end end
  for y2 = 151, 154 do hline(392, 440, y2, (y2 % 2 == 0) and T6 or T5) end
  F.smoke(cx + 14, top - 22, 3, .7, 1)
end
boathouse()
F.depth(0)
-- mist lying on the water: long soft banks, ragged ends, veiling the far shore feet and the boathouse stilts
for _, b in ipairs({ { 266, 410, WL, 2 }, { 300, 479, WL + 3, 2 }, { 270, 380, WL + 9, 1 }, { 372, 479, 152, 3 }, { 330, 450, 142, 1 } }) do
  for y2 = b[3], b[3] + b[4] - 1 do
    for x2 = b[1], b[2] do
      local edge = math.min(x2 - b[1], b[2] - x2)
      if lake:has(x2, y2) then
        if hash(x2 // 6, y2, 87) < .72 and hash(x2, y2, 88) < math.min(1, edge / 20 + .2) then
          px(x2, y2, (y2 + x2 // 7) % 2 == 0 and L.mist2 or L.mist)
        end
      end
    end
  end
end

---------------------------------------------------------------- reed fringe along the near shore of the broad
F.depth(2)
F.reeds(262, 284, 134, 18, 301, { cattails = 2 })
F.reeds(272, 294, 152, 22, 302, { green = true, cattails = 1 })
F.reeds(282, 302, 172, 24, 303, { cattails = 2 })
F.depth(3)

---------------------------------------------------------------- decoys on the water, and the drake they fooled
decoy(392, 163, true, true) decoy(406, 168, false, true) decoy(416, 160, true, true)
-- tether lines down to the weights
for _, d in ipairs({ { 396, 164 }, { 410, 169 }, { 420, 161 } }) do px(d[1], d[2] + 2, W.deep) px(d[1] + 1, d[2] + 3, T6) end
decoy(376, 169, true, true, true) -- the live one: same paint, but he swims toward the others, beak open
px(370, 165, L.marigold.shade)

---------------------------------------------------------------- the landing stage, moored punt, lantern post, fisher gnome
F.depth(3)
local deck = rect(300, 178, 470, 185)
local face = rect(300, 186, 470, 188)
local pileX = {}
for x2 = 312, 466, 18 do pileX[#pileX + 1] = x2 end
-- the shade the stage throws on the water, and the piles' reflections
for x2 = 300, 470 do for y2 = 189, 192 do if lake:has(x2, y2) then px(x2, y2, (y2 == 189 or (x2 // 3 + y2) % 2 == 0) and T6 or T5) end end end
for _, x2 in ipairs(pileX) do for y2 = 208, 222, 2 do if lake:has(x2, y2) and lake:has(x2 + 1, y2 + 1) then px(x2, y2, W.deep) px(x2 + 1, y2 + 1, T6) end end end
F.stilts(pileX, 189, 206, 202, L.timber, 3)
rimOf(union(deck, face), L.timber)
F.boardwalk(deck, true, 21)
hline(300, 470, 178, L.board.hi)
part(face, TAR, { nopop = true })
face:each(function(x2, y2) if y2 == 188 and hash(x2 // 2, 0, 92) < .5 then px(x2, y2, L.moss.shade) end end)
for x2 = 302, 470, 10 do px(x2, 187, L.iron.hi) end
-- the moored punt, a quant pole and a reed bundle in it, an eel hive in the stern
F.punt(362, 430, 217, TAR, { pole = { 366, 210, 424, 208 } })
for k = 0, 2 do hline(368 + k * 3, 404 - k * 3, 219 + k * 2, mix(TAR.base, T5, .5)) end
for k = 0, 2 do hline(364 + k * 4, 428 - k * 4, 220 + k * 2, k % 2 == 0 and T6 or T5) end
do
  local rb = poly{ { 376, 212 }, { 398, 210 }, { 399, 213 }, { 377, 214 } }
  rimOf(rb, L.reed) part(rb, L.reed, { nopop = true }) rb:each(function(x2, y2) if (x2 + y2) % 2 == 0 then px(x2, y2, L.reed.hi) end end)
  hline(386, 386, 210, L.timber.deep) vline(386, 211, 213, L.timber.deep)
end
eelHive(406, 213, 16, -1)
fill(line({ { 362, 211 }, { 366, 190 } }), L.board.shade) -- mooring rope
-- lantern post at the end of the stage
local lp = rect(460, 140, 461, 177) rimOf(lp, L.timber) part(lp, L.timber, { nopop = true, noshade = true })
local arm = rect(452, 140, 461, 141) fill(arm, L.timber.base)
local lam = rect(450, 143, 455, 150) rimOf(lam, L.timber) fill(lam, L.glow.base) px(451, 144, L.glow.hi) vline(455, 144, 150, L.glow.shade)
hline(450, 455, 142, L.timber.deep) px(452, 151, L.timber.deep)
-- a lifebelt-style cork ring hung on the post
local ring = c:ellipse(461, 160, 4, 4):cut(c:ellipse(461, 160, 2, 2))
rimOf(ring, CORK) part(ring, CORK, { nopop = true }) px(458, 158, CORK.hi) px(459, 157, L.awnA.base) px(463, 163, L.awnA.shade)
-- fisher gnome on a crate, rod out over the water, a float on the line
F.crate(424, 177, 12, 6)
local _, fhx, fhy = F.gnome(430, 171, { hat = L.awnA, coat = L.accent, arm = "out", noShadow = true })
fill(line({ { fhx, fhy }, { 448, 152 }, { 452, 146 } }), L.timber.deep)
vline(452, 147, 176, L.awnB.shade) vline(452, 193, 213, L.awnB.shade) fill(rect(451, 213, 453, 215), L.awnA.base) px(451, 213, L.awnA.hi) px(452, 215, L.awnB.hi)
for k = 0, 2 do hline(448 - k * 2, 456 + k * 2, 217 + k * 2, T2) end
F.barrel(316, 177, L.timber, 9)
F.crate(328, 177, 12, 7, EEL)
-- eel hives stacked on the boards, a standing trap, a tackle box
eelHive(344, 177, 20, 1) eelHive(348, 171, 17, 1)
bottleTrap(398, 177, 13)
local tb = rect(406, 172, 414, 177) rimOf(tb, L.timber) part(tb, L.accent, { nopop = true }) hline(406, 414, 174, L.accent.deep) px(410, 173, L.gold.hi)
-- a dragonfly over the stage
F.dragonfly(384, 164, L.accent)

---------------------------------------------------------------- shore wedge: heron in a red gnome hat at the fish bucket (quirk)
F.eraseGround(rect(278, 214, 330, 251))
local bucket = poly{ { 304, 252 }, { 318, 252 }, { 316, 264 }, { 306, 264 } }
rimOf(bucket, L.timber) part(bucket, L.board) hline(304, 318, 255, L.iron.shade) hline(305, 317, 261, L.iron.shade)
bucket:each(function(x2, y2) if x2 <= 306 and y2 > 255 then px(x2, y2, L.board.hi) end end)
for k = 0, 3 do local fx = 306 + k * 3 fill(rect(fx, 248 - (k % 2), fx + 1, 252), L.stone.hi) px(fx, 248 - (k % 2), L.stone.shade) px(fx + 1, 250, L.awnA.base) end
F.shadowM(c:ellipse(294, 263, 10, 1))
local HR = L.heron
F.sprite({
  ".............kkkk...............",
  "...........kkwwwwk..............",
  "..............wwwwwyyyy.........",
  "..............wwwewyyyyyyy......",
  "...............wwwwYYYYYYYYYff..",
  "...............wwww........fFff.",
  "...............wwww.........ff..",
  "..............wwww..............",
  ".............wwww...............",
  "............wwwkw...............",
  "............wwww................",
  "...........wwwkw................",
  "...........wwww.................",
  "...........wwww.................",
  ".....GGGGGgwwww.................",
  "...GGGGgggggwww.................",
  "..GGggggggggggw.................",
  ".Gggggggdddgggg.................",
  ".gggggdddddggggg................",
  "kgggddddddddgggg................",
  "kkggdddDDddddggd................",
  ".kkgdddDDDdddddd................",
  "..kkddDDDDDdddd.................",
  "...kkdDDDDDddd..................",
  ".....DDDDDDdd...................",
  "........l..l....................",
  "........l..l....................",
  "........l..l....................",
  "........l..l....................",
  "........l..l....................",
  "........l..l....................",
  ".......ll.ll....................",
  "......l.l.l.l...................",
}, 284, 230, { k = "#3e4048", w = HR.hi, e = L.timber.edge, y = L.marigold.base, Y = L.marigold.shade, f = L.stone.hi, F = L.stone.shade,
  G = HR.base, g = HR.shade, d = HR.deep, D = "#5a5e64", l = L.marigold.deep })
-- the red gnome hat, perched on the heron's head, its tip flopping back
do
  local hat = poly{ { 293, 231 }, { 304, 231 }, { 302, 227 }, { 300, 223 }, { 297, 220 }, { 292, 219 }, { 289, 221 }, { 294, 223 }, { 295, 227 } }
  rimOf(hat, L.awnA) part(hat, L.awnA, { nopop = true })
  hat:each(function(x2, y2) if x2 <= 296 and y2 > 222 and y2 < 230 then px(x2, y2, L.awnA.hi) end end)
  hline(293, 304, 231, L.awnA.deep) hline(294, 303, 230, L.awnA.shade)
  px(289, 222, L.awnB.base) px(288, 222, L.awnB.hi) -- a pompom
end
-- coil of rope, an eel glaive stuck in the mud, two decoys drying on the bank, a moorhen
local coil = c:ellipse(354, 248, 9, 4) rimOf(coil, L.board) part(coil, L.board) fill(c:ellipse(354, 248, 4, 1), L.board.deep)
for k = 0, 2 do c:ellipse(354, 248, 8 - k * 2, 3 - k // 2):edge():each(function(x2, y2) if y2 > 247 then px(x2, y2, L.board.shade) end end) end
do
  local shaft = rect(336, 222, 337, 246)
  local head = rect(330, 220, 343, 221)
  local tines = HP.mask()
  for k = 0, 4 do tines:add(rect(331 + k * 3, 212 + (k % 2), 332 + k * 3, 219)) end
  local g = union(shaft, head, tines)
  rimOf(g, L.iron)
  part(shaft, L.timber, { nopop = true, noshade = true }) part(head, L.iron, { nopop = true }) part(tines, L.iron, { nopop = true, noshade = true })
  tines:each(function(x2, y2) if (x2 - 331) % 3 == 0 then px(x2, y2, L.iron.hi) end end)
  head:each(function(x2, y2) if hash(x2, y2, 93) < .35 then px(x2, y2, L.roof2.shade) end end) -- rust
  hline(333, 340, 247, L.peat.deep)
end
decoy(372, 241, false, false)
F.sprite({ -- a moorhen picking along the bank: slate body, red shield, white flank line and tail flash
  "..kk......",
  ".kkkk.....",
  "rRkkk.....",
  "y..kkk....",
  "...kkkkkkw",
  "..kkkkkkkW",
  "..kWWWWkk.",
  "...kkkkk..",
  "....g.g...",
  "...gg.gg..",
}, 368, 252, { k = "#4a4a50", r = L.apple.base, R = L.apple.shade, y = L.marigold.base, W = L.awnB.base, w = L.awnB.hi, g = L.reedGreen.base })
F.moss(F.rock(326, 268, 6, 5), .3, 95)
for _, f in ipairs({ { 372, 266 }, { 346, 264 }, { 276, 250 }, { 362, 234 }, { 386, 236 } }) do F.sedge(f[1], f[2], 7) px(f[1] - 1, f[2] - 5, L.marigold.base) px(f[1] + 2, f[2] - 4, L.marigold.hi) end
F.reeds(346, 366, 228, 14, 304, { cattails = 2, green = true })
F.reeds(270, 284, 232, 16, 305, { cattails = 1 })
F.dragonfly(342, 226, L.apple, true)

---------------------------------------------------------------- left: fisher's tarred cottage under sedge thatch, eel-smoking rack
F.depth(1)
F.tree(84, 128, 38, 3)
F.tree(10, 134, 40, 1)
local ctop, ccx, cwall, croof = F.building{ x0 = 20, x1 = 70, yb = 136, wh = 32, rh = 22, wall = TAR, roof = L.roof2, chimney = true, noFrame = true, ridge = L.reed }
F.planks(cwall:copy():clip(rect(20, ctop + 2, 70, 136)), TAR, 3, false, 27)
cwall:each(function(x, y) if x <= 22 and y > ctop + 2 then px(x, y, TAR.hi) end end)
local cc = union(rect(20, ctop, 21, 136), rect(69, ctop, 70, 136))
part(cc, L.board, { nopop = true, noshade = true })
F.moss(croof, .1, 96)
F.window(26, 112, 32, 118, L.board) F.door(48, 122, 55, 135, L.accent)
F.smoke(61, 86, 6, .5, 2)
-- an eel-shaped sign on the cottage
do
  local es = HP.mask()
  for k = 0, 16 do local x, y = 30 + k, floor(128 + 2 * sin(k / 2.6)) es:add(rect(x, y, x, y + (k < 13 and 2 or 1))) end
  rimOf(es, L.accent) part(es, L.accent, { nopop = true }) px(31, 128, L.timber.edge) px(30, 130, L.accent.hi)
end
-- reed bundles stacked against the gable end
for k = 0, 2 do bundleEnd(76 + k * 5, 134, 2) end
for k = 0, 1 do bundleEnd(78 + k * 5, 130, 2) end
local function smokeRack(x0, x1, yb)
  local posts = rect(x0, yb - 22, x0 + 1, yb):add(rect(x1, yb - 22, x1 + 1, yb))
  local bar = rect(x0 - 2, yb - 22, x1 + 3, yb - 21)
  F.shadow(x0, x1, yb, 6, 3)
  rimOf(union(posts, bar), L.timber) part(posts, L.timber, { nopop = true, noshade = true }) part(bar, L.timber, { nopop = true, noshade = true })
  local i = 0
  for x = x0 + 4, x1 - 2, 5 do
    i = i + 1
    vline(x, yb - 20, yb - 19, L.timber.edge)
    if i % 3 ~= 0 then -- an eel hung by the head, a slow S down to the tail
      local em = HP.mask()
      for k = 0, 13 do local ex = floor(x + 1.4 * sin(k / 2.3 + i)) em:add(rect(ex, yb - 18 + k, ex + (k < 9 and 1 or 0), yb - 18 + k)) end
      rimOf(em, EEL) em:each(function(xx, yy) px(xx, yy, (em:has(xx - 1, yy) and EEL.shade) or EEL.base) end)
      px(x, yb - 18, EEL.hi)
    else -- a split roach
      local fsh = poly{ { x - 1, yb - 18 }, { x + 2, yb - 18 }, { x + 2, yb - 9 }, { x, yb - 7 }, { x - 1, yb - 9 } }
      local tl = poly{ { x - 2, yb - 7 }, { x + 3, yb - 7 }, { x, yb - 9 } }
      fill(union(fsh, tl), L.stone.base) vline(x + 2, yb - 18, yb - 10, L.stone.deep) px(x, yb - 16, L.timber.edge) vline(x, yb - 14, yb - 11, L.awnA.shade)
    end
  end
  -- peat smoke curling up from a smudge pot under the rack
  local pot = rect(x0 + 22, yb - 4, x0 + 28, yb) rimOf(pot, L.iron) part(pot, L.iron, { nopop = true })
  px(x0 + 24, yb - 5, L.glow.shade) px(x0 + 26, yb - 5, L.glow.base)
end
smokeRack(96, 150, 140)
for k = 0, 5 do px(121 + (k % 2), 134 - k * 2, k % 2 == 0 and L.mist or L.mist2) end
F.depth(2)
F.reeds(156, 176, 142, 10, 306)
F.depth(3)

---------------------------------------------------------------- left hero: net drying frame (tanned net, cork floats)
local function netFrame(x0, x1, yt, yb)
  local posts = rect(x0, yt, x0 + 3, yb):add(rect(x1 - 3, yt, x1, yb)):add(rect((x0 + x1) // 2 - 1, yt, (x0 + x1) // 2 + 1, yb))
  local bar = rect(x0 - 3, yt, x1 + 3, yt + 3)
  F.shadow(x0, x1, yb, 14, 5)
  rimOf(union(posts, bar), L.willowBark)
  part(posts, L.willowBark, { nopop = true }) part(bar, L.willowBark, { nopop = true })
  F.moss(posts:copy():clip(rect(x0, yb - 12, x1, yb)), .3, 97)
  -- withy lashings where the bar meets the posts
  for _, lx in ipairs({ x0, (x0 + x1) // 2 - 1, x1 - 3 }) do for k = 0, 3 do px(lx + k, yt + 1 + (k % 2), WICK.hi) px(lx + k, yt + 3, WICK.shade) end end
  local function sag(x2) local t = ((x2 - x0) % ((x1 - x0) // 2)) / ((x1 - x0) // 2) return floor(yb - 14 - 10 * sin(t * pi)) end
  for x2 = x0 + 4, x1 - 4 do
    local y1 = sag(x2)
    for y2 = yt + 4, y1 do
      local a, b = (x2 + y2) % 5, (x2 - y2) % 5
      if a == 0 or b == 0 then px(x2, y2, (a == 0 and b == 0) and NET.deep or NET.shade) elseif hash(x2, y2, 2) < .07 then px(x2, y2, NET.base) end
    end
    px(x2, y1, NET.deep)
    if x2 % 7 == 0 then
      local red = (x2 // 7) % 4 == 0
      local r = red and L.awnA or CORK
      fill(rect(x2 - 1, y1 + 1, x2 + 1, y1 + 3), r.base) px(x2 - 1, y1 + 1, r.hi) px(x2 + 1, y1 + 3, r.deep)
    end
  end
  -- weed snagged in the net
  for _, w in ipairs({ { 118, 168 }, { 162, 174 }, { 136, 160 } }) do px(w[1], w[2], L.reedGreen.base) px(w[1] + 1, w[2] + 1, L.reedGreen.shade) px(w[1], w[2] + 2, L.reedGreen.deep) end
end
netFrame(92, 192, 150, 214)
F.barrel(110, 222, L.timber, 11) F.barrel(124, 224, L.board, 9)
-- basket of eels
local bk = poly{ { 160, 214 }, { 182, 214 }, { 179, 224 }, { 163, 224 } }
rimOf(bk, WICK) part(bk, WICK) bk:each(function(x2, y2) if (x2 + y2) % 3 == 0 then px(x2, y2, WICK.shade) end if (y2 - 214) % 3 == 2 then px(x2, y2, WICK.deep) end end)
for k = 0, 3 do
  local ex = 162 + k * 5
  for t = 0, 6 do local yy = 212 - floor(1.5 * sin(t / 1.6 + k)) px(ex + t, yy - 1, L.timber.edge) px(ex + t, yy, t < 2 and EEL.hi or EEL.shade) px(ex + t, yy + 1, EEL.edge) end px(ex, 211 - floor(1.5 * sin(k)), EEL.hi)
end
fill(line({ { 166, 211 }, { 170, 205 }, { 168, 201 } }), EEL.base) px(168, 200, EEL.hi) -- one making a break for it
-- the quant (punt pole) leaning, with its forked foot uppermost
fill(line({ { 194, 228 }, { 184, 168 } }, 2), L.board.base) vline(185, 168, 200, L.board.hi)
fill(line({ { 184, 168 }, { 180, 162 } }), L.iron.base) fill(line({ { 185, 168 }, { 188, 162 } }), L.iron.base) px(180, 161, L.iron.hi)
-- an otter sitting up by the basket, eyeing the eels
do
  local om = F.sprite({
    "...o..o...",
    "..bbbbbb..",
    ".bbbbbbbb.",
    ".bbebbbbnn",
    ".bbbbbbbb.",
    "..bpppppw.",
    "..bbpppb..",
    ".bbbppbbb.",
    ".bbbppbbbb",
    "bbbbppbbbb",
    "bbbbppbbbb",
    "bbbbbbbbbb",
    ".bbbbbbbB.",
    ".bbBB.bbB.",
    "BBbbB.....",
    ".BBB......",
  }, 145, 207, { o = L.soil.shade, b = L.soil.base, B = L.soil.deep, e = L.timber.edge, n = L.timber.edge, p = L.plume.hi, w = L.awnB.base })
  om:each(function(x2, y2) if not om:has(x2 - 1, y2) and y2 > 208 then px(x2, y2, L.soil.hi)
    elseif not om:has(x2 + 1, y2) and y2 > 210 and y2 < 219 then px(x2, y2, L.soil.shade) end end)
  px(149, 210, L.awnB.hi) -- eye glint
  hline(155, 157, 212, L.awnB.base) -- whiskers
end

---------------------------------------------------------------- bottom-left: willow, bottle traps, upturned punt being tarred, eel hives
F.tree(44, 206, 54, 6)
bottleTrap(64, 210, 14) bottleTrap(76, 212, 13) bottleTrap(70, 200, 11)
local function upBoat()
  -- an upturned fen dinghy on trestles, clinker planked, silver-weathered, half of it already freshly tarred
  local pts = { { 24, 242 } }
  for x2 = 24, 136, 4 do pts[#pts + 1] = { x2, 242 - floor(16 * sin((x2 - 20) / 120 * pi) ^ .6) - (x2 > 120 and (x2 - 120) // 2 or 0) } end
  pts[#pts + 1] = { 138, 230 } pts[#pts + 1] = { 132, 242 }
  local hull = poly(pts)
  local tre = rect(36, 242, 38, 256):add(rect(110, 240, 112, 256)):add(rect(30, 252, 44, 253)):add(rect(104, 252, 118, 253))
  F.shadow(26, 136, 258, 6, 3)
  rimOf(union(hull, tre), L.timber)
  part(tre, L.timber, { nopop = true, noshade = true })
  part(hull, L.board)
  hull:each(function(x2, y2)
    local k = 242 - floor(16 * sin((x2 - 20) / 120 * pi) ^ .6)
    local s = (y2 - k) % 5
    if s == 4 then px(x2, y2, L.board.deep) elseif s == 0 and y2 > k then px(x2, y2, L.board.hi) end
    if hash(x2 // 3, y2, 98) < .08 then px(x2, y2, L.board.shade) end
    if x2 > 100 and hash(x2 // 2, y2, 95) < .1 then px(x2, y2, L.moss.shade) end -- green stain near the stern
    if x2 < 70 then -- fresh tar, wet and glossy
      local h = (s == 4) and TAR.edge or TAR.deep
      if s == 0 and hash(x2 // 2, y2, 99) < .5 then h = TAR.base end
      if s == 1 and x2 < 60 and hash(x2, y2, 97) < .3 then h = TAR.hi end
      px(x2, y2, h)
    end
    if x2 >= 70 and x2 < 75 and hash(x2, y2, 96) < (75 - x2) / 5 then px(x2, y2, TAR.deep) end -- ragged brush edge
  end)
  hline(24, 132, 241, L.accent.base) hline(24, 132, 242, L.accent.deep) -- painted gunwale band
  hline(24, 69, 241, TAR.shade)
  local pot = rect(56, 250, 64, 258) rimOf(pot, L.iron) part(pot, L.iron) hline(56, 64, 250, L.timber.edge)
  fill(line({ { 62, 250 }, { 68, 244 } }), L.board.base)
  px(58, 259, L.glow.base) px(60, 259, L.glow.shade) px(62, 259, L.glow.base) px(59, 260, L.glow.hi) px(61, 260, L.produce.base)
  local _, thx, thy = F.gnome(84, 266, { hat = L.gold, coat = L.roof2, arm = "out", flip = true })
  fill(line({ { thx, thy }, { thx - 6, thy - 3 } }), L.board.base) fill(rect(thx - 9, thy - 6, thx - 6, thy - 3), TAR.edge) -- tar brush
end
upBoat()
px(59, 247, L.mist2) px(61, 245, L.mist) px(60, 243, L.mist2) -- steam off the tar
eelHive(146, 262, 22, -1) eelHive(170, 263, 24, 1) eelHive(156, 252, 18, 1)
F.reeds(4, 18, 228, 18, 307, { cattails = 2, green = true })
for _, f in ipairs({ { 144, 246 }, { 196, 254 }, { 202, 238 }, { 140, 268 }, { 22, 266 } }) do F.sedge(f[1], f[2], 6) end
-- signpost with a hanging fish board by the road
F.sign(206, 148, 18, 10, L.board)
F.sedge(214, 210, 6, L.reed) F.sedge(206, 176, 5)
F.depth(0)
-- a skein of ducks low over the broad, a heron flying far off
F.birds({ { 360, 60, 2 }, { 368, 64, 2 }, { 376, 68, 2 }, { 352, 64, 2 }, { 150, 50, 2 }, { 186, 72, 1 } })
F.sprite({ "......ww....", "wwwwwwwww...", "..wwwwwwwkYY", ".wwwww......", "..www......." }, 412, 46, { w = L.heron.base, k = L.heron.deep, Y = L.marigold.shade }, { rim = false })
fill(c:ellipse(205, 153, 5, 2):add(poly{ { 209, 153 }, { 212, 150 }, { 212, 156 } }), L.accent.base) px(202, 152, L.timber.edge) px(203, 152, L.accent.hi)
F.finish()
