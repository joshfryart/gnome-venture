-- jetty.lua : "Lakeside jetty" stop look, FOREST (forest_pinewood), 480x270 gate view.
-- Same composition as the Maplewold jetty (art-2701-batch3/stops/opus3/jetty.lua), re-cast for a pine-wood lake:
-- right half: a cool misted lake under a dark spruce shore (its trees mirrored in the still water), mist lying on
-- the water; a moss-green plank jetty on piles with a moored rowboat, a lantern post and a gnome fishing off the end;
-- a log boathouse on stilts and a little sail on the far water; a loon with a chick on its back, a leaping trout.
-- Left: the fisher's log cabin, a fish rack, the net drying frame with cork floats, an upturned boat being tarred,
-- creels, a tabby cat eyeing the fish basket. Quirk (kept): a grey heron helping itself to the fish bucket.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-forest-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "jetty", out = DIR, farTrees = { 24, 52, 120, 196, 290, 352, 440 },
  treeLineGap = { 220, 490 } } -- the right half gets its own darker spruce shore over the lake
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local mix, rp = F.mix, F.rp
local W = L.water

-- local ramps: dark lakeside spruce, moss-green weathered pier planks
local darkSpruce = rp("#7aa48e #4c7a66 #355e54 #264644 #183238")
local pier = rp("#c2c896 #9ca474 #788658 #566446 #36422e")
local function lum(h)
  local r, g, b = tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16)
  return (r * .3 + g * .59 + b * .11) / 255
end

---------------------------------------------------------------- the lake
local WL = 118 -- waterline under the far shore
local lake = poly{ { 268, WL }, { 479, WL }, { 479, 228 }, { 372, 228 }, { 350, 220 }, { 326, 202 }, { 304, 176 }, { 288, 150 }, { 276, 130 } }
-- the far shore strip (dark duff and moss under the spruces)
local shore = poly{ { 258, 112 }, { 479, 112 }, { 479, WL }, { 268, WL } }
shore:each(function(x, y)
  local v = hash(x, y, 81)
  px(x, y, v < .35 and L.mossGround.deep or (v < .7 and L.mossGround.shade or L.ground.deep))
end)
-- pebbly mossy near shore along the diagonal edge
local beach = lake:grow(4):cut(lake):clip(rect(0, WL, 479, 269))
beach:each(function(x, y)
  local v = hash(x, y, 5)
  local h = v < .3 and L.stone.base or (v < .5 and L.stone.shade or (v < .75 and L.mossGround.base or L.mossGround.hi))
  if hash(x // 2, y // 2, 6) < .15 then h = L.stone.hi end
  px(x, y, h)
end)
lake:edge():each(function(x, y) if y > WL then px(x, y, L.stone.hi) end end)
-- cool misted water: pale mist-white far off, blue-green in the middle, deeper near the jetty
local T1 = mix(W.hi, L.mist, .45)
local T2 = mix(mix(W.hi, W.base, .5), L.mist, .2)
local T3 = mix(W.base, L.mist, .15)
local T4 = mix(T3, W.shade, .45)
local T5 = mix(W.base, W.shade, .7)
local shallowC = mix(W.hi, L.stone.base, .45)
local shallow2 = mix(T3, L.mossGround.base, .3)
lake:shrink(1):each(function(x, y)
  local d = y - WL
  local h
  if d < 5 then h = T1
  elseif d < 18 then h = hash(x // 7, y, 14) < .55 and T1 or T2
  elseif d < 30 then h = hash(x // 7, y, 14) < .5 and T2 or T3
  elseif d < 58 then h = T3
  elseif d < 85 then h = hash(x // 6, y // 2, 15) < .55 and T3 or T4
  else h = hash(x // 6, y // 2, 16) < .3 and T4 or T5 end
  if not lake:has(x - 7, y) or not lake:has(x, y + 7) or not lake:has(x + 5, y + 5) then h = shallow2 end
  if not lake:has(x - 4, y) or not lake:has(x, y + 4) or not lake:has(x + 3, y + 3) then h = shallowC end
  px(x, y, h)
end)

---------------------------------------------------------------- the dark spruce shore across the water
F.depth(1)
local i = 0
for x = 262, 482, 6 do
  i = i + 1
  local hh = 12 + floor(hash(x, 1, 82) * 12)
  F.conifer(x + floor(hash(x, 2, 82) * 4), 114 + floor(hash(x, 3, 82) * 2), hh, L.farTree, 500 + i, { far = true, slim = true })
end
F.depth(2)
i = 0
local x = 260
while x < 486 do
  i = i + 1
  local hh = 16 + floor(hash(x, 4, 83) * 20)
  if x > 380 and x < 452 then hh = hh - 4 end -- lower behind the boathouse roof
  F.conifer(x, WL - 1 + floor(hash(x, 5, 83) * 2), hh, (i % 3 == 0) and L.foliage2 or darkSpruce, 600 + i, { slim = hash(x, 6, 83) < .5 })
  x = x + 8 + floor(hash(x, 7, 83) * 7)
end
-- a red-bark pine standing up out of the spruces
F.pine(302, WL, 36, L.foliage, 61)
F.depth(0)
-- their reflection in the still water: everything dark above the waterline, mirrored, sunk toward the water colour,
-- broken by ripple rows
for xx = 268, 479 do
  for k = 1, 30 do
    local sy, dy = WL - k, WL - 1 + k
    if lake:has(xx, dy) and lake:has(xx, dy + 1) and not beach:has(xx, dy) then
      local v = c:get(xx, sy)
      if v and lum(v) < .52 and not (dy % 3 == 0 and hash(xx // 4, dy, 84) < .55) then
        local t = .22 + k * .012
        local h = mix(mix(v, T5, t), L.mist, k < 6 and .25 or .1)
        if (xx + dy) % 2 == 0 and k > 22 then h = mix(h, T3, .4) end
        px(xx, dy, h)
      end
    end
  end
end
-- lit ripple pairs (pale crest over a shade trough), longer and wider apart nearer
for y = 124, 226 do
  local d = y - 112
  local gap = 2 + d // 18
  if y % gap == 0 then
    local len = 2 + d // 9
    local x0 = 268 + floor(hash(y, 1, 13) * 30)
    while x0 < 478 do
      if hash(x0 // 9, y, 16) < .45 then
        for xx = x0, x0 + len do if lake:has(xx, y) and lake:has(xx, y + 1) and not beach:has(xx, y) then
          px(xx, y, y < 150 and T1 or W.hi) if d > 30 then px(xx, y + 1, T5) end end end
      end
      x0 = x0 + len + 6 + floor(hash(x0, y, 17) * 18)
    end
  end
end
-- glints of the misted sun (pale gold, cool)
for k = 0, 34 do local gx, gy = 276 + floor(hash(k, 1, 18) * 200), 124 + floor(hash(k, 2, 18) * 96) if lake:has(gx, gy) then px(gx, gy, "#f2ecc0") px(gx + 1, gy, W.hi) end end
-- a leaping trout over its rings
do
  local fx, fy = 364, 156
  c:ellipse(fx, fy + 6, 9, 2):edge():each(function(x2, y2) px(x2, y2, W.hi) end)
  c:ellipse(fx, fy + 6, 13, 3):edge():each(function(x2, y2) if (x2 // 2) % 2 == 0 then px(x2, y2, W.hi) end end)
  F.sprite({ "...ff..", ".fffff.", "fGGpGe.", ".fGGf..", "f.f....", }, fx - 3, fy - 4,
    { f = L.foliage2.deep, G = L.stone.hi, p = L.petal.base, e = L.timber.edge })
  for _, d in ipairs({ { -6, 2 }, { 5, 3 }, { -4, -1 }, { 7, 0 } }) do px(fx + d[1], fy + d[2], W.hi) end
end
-- lily pads with a water lily in the shallows by the reeds
for _, p in ipairs({ { 312, 168 }, { 322, 182 }, { 336, 196 }, { 344, 208 }, { 298, 154 } }) do
  local pad = c:ellipse(p[1], p[2], 4, 2) fill(pad, L.fern.base) px(p[1] - 2, p[2] - 1, L.fern.hi) px(p[1] + 1, p[2], L.fern.deep) px(p[1] + 2, p[2] - 1, T3)
  px(p[1] - 3, p[2], L.fern.shade)
end
px(321, 180, L.awnB.hi) px(323, 180, L.awnB.base) px(322, 179, L.awnB.hi) px(322, 180, L.gold.hi)
px(335, 194, L.petal.hi) px(337, 194, L.petal.base) px(336, 193, L.petal.hi) px(336, 194, L.gold.hi)

---------------------------------------------------------------- the loon (with a chick riding on her back) + a far one
local function loon(lx, ly, big)
  if big then
    F.sprite({
      "..kKk...............",
      ".kKKKk..............",
      "bbKKRK..............",
      "..KKKK..............",
      "...WKW......cc......",
      "...KKK.....cCCc.....",
      "...KKKKkkkkcCCcKk...",
      "..KKWKWKWKWKWKKKKk..",
      "..KWKWKWKWKWKWKKKKK.",
      "...KKWKWKWKWKKKKKK..",
      "....FFFFFFFFFFFF....",
    }, lx, ly, { K = "#2c3a38", k = "#446058", R = "#c84040", b = "#3a4446", W = "#e6eadc", F = "#c4cabc",
      c = "#6a6a62", C = "#9a988a" })
    for k = 0, 2 do hline(lx + 2 - k * 3, lx + 18 + k * 3, ly + 11 + k * 2, k == 0 and T5 or W.hi) end
    hline(lx - 6, lx + 1, ly + 11, W.hi) -- wake
  else
    F.sprite({ ".kK.....", "bKK.....", ".KKkkKk.", ".KWKWKKK", "..FFFFF." }, lx, ly,
      { K = "#2c3a38", k = "#446058", b = "#3a4446", W = "#e6eadc", F = "#c4cabc" })
    hline(lx, lx + 8, ly + 6, T1)
  end
end
loon(318, 152, true)
F.depth(1)
loon(346, 130, false)

---------------------------------------------------------------- far water: sail boat and a log boathouse on stilts
local function sail(x2, y2)
  local hull = poly{ { x2 - 8, y2 }, { x2 + 8, y2 }, { x2 + 5, y2 + 3 }, { x2 - 5, y2 + 3 } }
  local s1 = poly{ { x2, y2 - 1 }, { x2, y2 - 16 }, { x2 + 8, y2 - 1 } }
  local s2 = poly{ { x2 - 1, y2 - 1 }, { x2 - 1, y2 - 12 }, { x2 - 7, y2 - 1 } }
  rimOf(union(hull, s1, s2), L.timber)
  part(hull, L.redbark, { nopop = true }) fill(s1, L.awnB.base) fill(s2, L.awnB.shade) vline(x2, y2 - 16, y2, L.timber.base)
  vline(x2 + 1, y2 - 13, y2 - 2, L.awnB.hi)
  for k = 1, 3 do hline(x2 - 6 + k, x2 + 6 - k, y2 + 4 + k * 2, T4) end
  for k = 1, 3 do hline(x2 + 1, x2 + 5 - k, y2 + 4 + k * 2 - 1, mix(L.awnB.base, T2, .5)) end
end
sail(286, 132)
F.depth(2)
local function boathouse()
  local top, _, wallM, roofM = F.building{ x0 = 388, x1 = 444, yb = 140, wh = 26, rh = 20, wall = L.timber, roof = L.roof2,
    noShadow = true, noFrame = true, noAttic = true, shingle = true }
  F.logs(wallM, L.timber, top, 3)
  for y = top + 1, 138, 3 do F.logEnd(387, y, 1) F.logEnd(445, y, 1) end
  F.moss(roofM, .16, 85)
  F.window(424, 120, 430, 125, L.timber)
  -- big water door, the dark water inside
  local d = rect(396, 124, 416, 140) fill(d, L.soil.deep) fill(rect(398, 134, 414, 140), W.deep)
  hline(399, 413, 136, W.edge) hline(398, 414, 124, L.timber.hi) vline(396, 124, 140, L.timber.base) vline(416, 124, 140, L.timber.shade)
  -- a canoe stowed inside
  hline(400, 412, 132, L.redbark.base) hline(401, 411, 133, L.redbark.shade) px(400, 131, L.redbark.hi)
  -- stovepipe
  local pipe = rect(434, top - 14, 436, top - 2) rimOf(pipe, L.iron) part(pipe, L.iron, { nopop = true })
  local piles = HP.mask()
  for x2 = 390, 442, 8 do piles:add(rect(x2, 141, x2 + 1, 150)) end
  rimOf(piles, L.timber) part(piles, L.timber, { nopop = true, noshade = true })
  piles:each(function(x2, y2) if y2 > 146 and hash(x2, y2, 86) < .6 then px(x2, y2, L.moss.shade) end end)
  for x2 = 390, 442, 8 do for y2 = 152, 160, 2 do px(x2, y2, T5) end end
  for y2 = 152, 158, 2 do hline(392, 440, y2, (y2 % 4 == 0) and T4 or T3) end
  F.smoke(435, top - 18, 5, .7, 2)
end
boathouse()
F.depth(0)
-- mist lying on the water: long soft banks, ragged at the ends, veiling the far shore feet and the boathouse piles
for _, b in ipairs({ { 270, 400, 117, 2 }, { 300, 479, 121, 2 }, { 268, 360, 127, 1 }, { 380, 479, 150, 2 }, { 300, 420, 141, 1 } }) do
  for y2 = b[3], b[3] + b[4] - 1 do
    for x2 = b[1], b[2] do
      local edge = math.min(x2 - b[1], b[2] - x2)
      if lake:has(x2, y2) or y2 < WL then
        if hash(x2 // 5, y2, 87) < .75 and hash(x2, y2, 88) < math.min(1, edge / 18 + .25) then
          px(x2, y2, (y2 + x2 // 7) % 2 == 0 and L.mist2 or L.mist)
        end
      end
    end
  end
end

---------------------------------------------------------------- the jetty, moored rowboat, lamp post, fisher gnome
local function rowboat(x0, x1, y)
  local hull = poly{ { x0 - 3, y - 2 }, { x0, y }, { x1, y }, { x1 + 3, y - 2 }, { x1 - 5, y + 8 }, { x0 + 6, y + 8 } }
  local inside = c:ellipse((x0 + x1) / 2, y - 2, (x1 - x0) / 2 - 1, 2)
  rimOf(union(hull, inside), L.timber)
  part(hull, L.redbark) hline(x0 + 2, x1 - 2, y + 3, L.awnB.base) hline(x0 + 4, x1 - 4, y + 4, L.awnB.shade)
  hull:each(function(x2, y2) if y2 > y + 5 and hash(x2, y2, 89) < .25 then px(x2, y2, L.moss.shade) end end)
  fill(inside, L.timber.shade) c:edgeIn(inside, L.board.base)
  vline(x0 + 16, y - 4, y, L.board.hi) vline(x1 - 16, y - 4, y, L.board.hi)
  fill(line({ { x0 + 8, y - 2 }, { x1 + 6, y + 6 } }), L.board.shade) fill(rect(x1 + 4, y + 5, x1 + 8, y + 7), L.board.base)
  for k = 0, 3 do hline(x0 + 6 + k, x1 - 6 - k, y + 9 + k * 2, T5) end
  for k = 0, 2 do hline(x0 + 10 + k * 2, x1 - 18 - k * 2, y + 10 + k * 2, mix(L.redbark.base, T4, .55)) end
end
F.depth(3)
local deck = rect(300, 178, 470, 185)
local face = rect(300, 186, 470, 188)
local piles = HP.mask()
for x2 = 312, 466, 18 do piles:add(rect(x2, 189, x2 + 2, 206)) end
for x2 = 312, 466, 18 do for y2 = 208, 220, 3 do if lake:has(x2, y2) and lake:has(x2 + 1, y2 + 1) then px(x2, y2, W.deep) px(x2 + 1, y2 + 1, T5) end end end
rimOf(union(deck, face, piles), L.timber)
part(piles, L.timber, { nopop = true, noshade = true })
piles:each(function(x2, y2) if y2 > 197 and hash(x2, y2, 90) < .55 then px(x2, y2, y2 > 201 and L.moss.shade or L.moss.base) end end)
for x2 = 312, 466, 18 do hline(x2, x2 + 2, 203, W.hi) end
part(deck, pier)
F.planks(deck, pier, 5, true, 21)
F.moss(deck, .07, 91)
hline(300, 470, 178, pier.hi)
for x2 = 300, 470 do if (x2 // 3) % 2 == 0 then px(x2, 189, T5) end end
part(face, L.timber, { nopop = true })
face:each(function(x2, y2) if y2 == 188 and hash(x2 // 2, 0, 92) < .5 then px(x2, y2, L.moss.shade) end end)
for x2 = 302, 470, 10 do px(x2, 187, L.iron.hi) end
rowboat(368, 422, 212)
fill(line({ { 366, 210 }, { 360, 189 } }), L.board.shade) -- mooring rope
-- lantern post at the end of the jetty
local lp = rect(460, 140, 461, 177) rimOf(lp, L.timber) part(lp, L.timber, { nopop = true, noshade = true })
local arm = rect(452, 140, 461, 141) fill(arm, L.timber.base)
local lam = rect(450, 143, 455, 150) rimOf(lam, L.timber) fill(lam, L.glow.base) px(451, 144, L.glow.hi) vline(455, 144, 150, L.glow.shade)
hline(450, 455, 142, L.timber.deep) px(452, 151, L.timber.deep)
-- fisher gnome on a crate, rod out over the water, a float bobbing on the line
F.crate(424, 177, 12, 6)
local _, fhx, fhy = F.gnome(430, 171, { hat = L.awnA, coat = L.wall2, arm = "out", noShadow = true })
fill(line({ { fhx, fhy }, { 448, 152 }, { 452, 146 } }), L.timber.deep)
vline(452, 147, 176, L.awnB.shade) vline(452, 189, 213, L.awnB.shade) fill(rect(451, 213, 453, 215), L.awnA.base) px(451, 213, L.awnA.hi) px(452, 215, L.awnB.hi)
for k = 0, 2 do hline(448 - k * 2, 456 + k * 2, 217 + k * 2, W.hi) end
F.barrel(316, 177, L.timber, 9)
F.crate(328, 177, 12, 7, L.water)
-- a tackle box and a tin mug on the deck
local tb = rect(406, 172, 414, 177) rimOf(tb, L.timber) part(tb, L.accent, { nopop = true }) hline(406, 414, 174, L.accent.deep) px(410, 173, L.gold.hi)
local mug = rect(344, 173, 347, 177) rimOf(mug, L.iron) part(mug, L.iron, { nopop = true }) px(348, 175, L.iron.shade)

---------------------------------------------------------------- shore wedge: heron at the fish bucket (quirk), rope, anchor
F.eraseGround(rect(300, 236, 324, 251)) -- keep the bucket's silhouette clear
local bucket = poly{ { 304, 252 }, { 318, 252 }, { 316, 264 }, { 306, 264 } }
rimOf(bucket, L.timber) part(bucket, L.board) hline(304, 318, 255, L.iron.shade) hline(305, 317, 261, L.iron.shade)
for k = 0, 3 do local fx = 306 + k * 3 fill(rect(fx, 248 - (k % 2), fx + 1, 252), W.hi) px(fx, 248 - (k % 2), L.foliage2.shade) px(fx + 1, 250, L.petal.base) end
F.shadowM(c:ellipse(294, 263, 10, 1))
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
}, 284, 230, { k = "#3e4048", w = L.birch.hi, e = L.timber.edge, y = L.gold.hi, Y = L.gold.shade, f = W.hi, F = L.foliage2.shade,
  G = L.stone.hi, g = L.stone.base, d = L.stone.shade, D = L.stone.deep, l = L.gold.deep })
-- coiled rope + anchor, a mossy boulder, ferns and a toadstool ring on the shore
local coil = c:ellipse(354, 248, 9, 4) rimOf(coil, L.board) part(coil, L.board) fill(c:ellipse(354, 248, 4, 1), L.board.deep)
for k = 0, 2 do c:ellipse(354, 248, 8 - k * 2, 3 - k // 2):edge():each(function(x2, y2) if y2 > 247 then px(x2, y2, L.board.shade) end end) end
local anc = rect(336, 230, 337, 244):add(line({ { 330, 240 }, { 336, 245 }, { 343, 240 } }, 2)):add(rect(333, 232, 340, 233))
rimOf(anc, L.iron) part(anc, L.iron, { nopop = true }) fill(c:ellipse(336, 228, 2, 2):cut(c:ellipse(336, 228, 1, 1)), L.iron.base)
anc:each(function(x2, y2) if y2 > 241 and hash(x2, y2, 93) < .4 then px(x2, y2, L.roof2.shade) end end) -- rust
F.moss(F.rock(368, 262, 9, 8), .32, 94)
F.moss(F.rock(326, 268, 6, 5), .3, 95)
for _, f in ipairs({ { 372, 250, 7 }, { 346, 264, 6 }, { 276, 248, 6 }, { 362, 234, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.mushroom(292, 214, L.apple, true) F.mushroom(298, 216, L.apple) F.mushroom(287, 216, L.apple)

---------------------------------------------------------------- left: fisher's log cabin, fish rack
F.depth(1)
F.tree(84, 128, 38, 3)
F.tree(10, 134, 40, 1)
local ctop, _, cwall, croof = F.building{ x0 = 20, x1 = 70, yb = 136, wh = 32, rh = 22, wall = L.timber, roof = L.roof, chimney = true, shingle = true, noFrame = true }
F.logs(cwall, L.timber, ctop, 3)
for y = ctop + 1, 134, 3 do F.logEnd(19, y, 1) F.logEnd(71, y, 1) end
F.moss(croof, .15, 96)
F.window(26, 112, 32, 118, L.timber) F.door(48, 122, 55, 135, L.accent)
F.smoke(61, 86, 6, .5, 2)
-- a fish-shaped sign on the cabin
local fs = c:ellipse(37, 128, 6, 3):add(poly{ { 42, 128 }, { 47, 124 }, { 47, 132 } })
rimOf(fs, L.accent) part(fs, L.accent) px(33, 127, L.timber.edge)
local function fishRack(x0, x1, yb)
  local posts = rect(x0, yb - 22, x0 + 1, yb):add(rect(x1, yb - 22, x1 + 1, yb))
  local bar = rect(x0 - 2, yb - 22, x1 + 3, yb - 21)
  F.shadow(x0, x1, yb, 6, 3)
  rimOf(union(posts, bar), L.timber) part(posts, L.timber, { nopop = true, noshade = true }) part(bar, L.timber, { nopop = true, noshade = true })
  for x2 = x0 + 4, x1 - 2, 5 do
    vline(x2, yb - 20, yb - 19, L.timber.edge)
    local fsh = poly{ { x2 - 1, yb - 18 }, { x2 + 2, yb - 18 }, { x2 + 2, yb - 9 }, { x2, yb - 7 }, { x2 - 1, yb - 9 } }
    local tl = poly{ { x2 - 2, yb - 7 }, { x2 + 3, yb - 7 }, { x2, yb - 9 } }
    local trout = (x2 // 5) % 2 == 0
    fill(union(fsh, tl), trout and L.stone.base or L.needle.shade) vline(x2 + 2, yb - 18, yb - 10, L.stone.deep) px(x2, yb - 16, L.timber.edge)
    if trout then vline(x2, yb - 14, yb - 11, L.petal.base) end
  end
end
fishRack(96, 150, 140)
-- split firewood stacked against the cabin, a mossy stump with an axe in it
F.depth(2)
for k = 0, 3 do F.logEnd(76 + k * 5, 146, 2) end
for k = 0, 2 do F.logEnd(78 + k * 5, 142, 2) end
for k = 0, 1 do F.logEnd(80 + k * 5, 138, 2) end
do
  local sb = rect(26, 158, 36, 166) local st = c:ellipse(31, 158, 5, 2)
  rimOf(union(sb, st), L.timber) part(sb, L.timber, { nopop = true }) fill(st, L.board.base) px(31, 158, L.board.shade) px(28, 157, L.board.hi)
  F.moss(sb, .3, 101)
  fill(line({ { 33, 157 }, { 39, 150 } }), L.board.base) fill(rect(31, 154, 34, 157), L.iron.base) px(31, 154, L.iron.hi)
end
F.depth(1)
-- ferns at the cabin's foot
for _, f in ipairs({ { 18, 140, 4 }, { 74, 139, 4 }, { 88, 142, 3 } }) do F.fern(f[1], f[2], f[3]) end
F.depth(3)

---------------------------------------------------------------- left hero: net drying frame with cork floats
local function netFrame(x0, x1, yt, yb)
  local posts = rect(x0, yt, x0 + 3, yb):add(rect(x1 - 3, yt, x1, yb)):add(rect((x0 + x1) // 2 - 1, yt, (x0 + x1) // 2 + 1, yb))
  local bar = rect(x0 - 3, yt, x1 + 3, yt + 3)
  F.shadow(x0, x1, yb, 14, 5)
  rimOf(union(posts, bar), L.timber)
  part(posts, L.timber, { nopop = true }) part(bar, L.timber, { nopop = true })
  F.moss(posts:copy():clip(rect(x0, yb - 14, x1, yb)), .25, 97)
  F.moss(bar, .12, 98)
  local function sag(x2) local t = ((x2 - x0) % ((x1 - x0) // 2)) / ((x1 - x0) // 2) return floor(yb - 14 - 10 * sin(t * pi)) end
  for x2 = x0 + 4, x1 - 4 do
    local y1 = sag(x2)
    for y2 = yt + 4, y1 do
      local a, b = (x2 + y2) % 5, (x2 - y2) % 5
      if a == 0 or b == 0 then px(x2, y2, L.accent.shade) elseif hash(x2, y2, 2) < .08 then px(x2, y2, L.accent.base) end
    end
    px(x2, y1, L.accent.deep)
    if x2 % 7 == 0 then fill(rect(x2 - 1, y1 + 1, x2 + 1, y1 + 3), L.awnA.base) px(x2 - 1, y1 + 1, L.awnA.hi) px(x2 + 1, y1 + 3, L.awnA.deep) end
  end
  -- a little pine-weed snagged in the net
  px(120, 170, L.foliage.base) px(121, 171, L.foliage.shade) px(160, 176, L.needle.base) px(161, 177, L.needle.shade)
end
netFrame(92, 192, 150, 214)
F.barrel(110, 222, L.timber, 11) F.barrel(124, 224, L.board, 9)
-- basket of fish
local bk = poly{ { 160, 214 }, { 182, 214 }, { 179, 224 }, { 163, 224 } }
rimOf(bk, L.board) part(bk, L.needle) bk:each(function(x2, y2) if (x2 + y2) % 3 == 0 then px(x2, y2, L.needle.shade) end end)
for k = 0, 4 do local fx = 162 + k * 4 fill(c:ellipse(fx, 212, 2, 1), W.hi) px(fx + 2, 212, L.foliage2.shade) px(fx - 1, 212, L.petal.base) end
-- oars leaning
fill(line({ { 194, 228 }, { 186, 176 } }, 2), L.board.base) fill(c:rrect(184, 168, 189, 182, 2), L.board.shade)
-- a tabby cat sitting by the basket, eyeing the fish
F.sprite({
  "o...o..",
  "oo.oo..",
  "ttttt..",
  "tetet..",
  "ttntt..",
  ".ttt...",
  ".tTtt..",
  "tTttt..",
  "tTTttt.",
  "tTttttt",
  "tttttt.",
  "wt.tw..",
}, 148, 212, { o = L.timber.edge, t = L.produce.shade, T = L.produce.deep, e = L.leaf.hi, n = L.apple.shade, w = L.awnB.hi })

---------------------------------------------------------------- bottom-left: big spruce, upturned boat on trestles, tar pot, creels
F.tree(44, 206, 54, 6)
F.barrel(64, 210, L.timber, 10) F.barrel(76, 212, L.timber, 10) F.barrel(70, 201, L.board, 9)
local function upBoat()
  local pts = { { 24, 242 } }
  for x2 = 24, 136, 4 do pts[#pts + 1] = { x2, 242 - floor(16 * sin((x2 - 20) / 120 * pi) ^ .6) - (x2 > 120 and (x2 - 120) // 2 or 0) } end
  pts[#pts + 1] = { 138, 230 } pts[#pts + 1] = { 132, 242 }
  local hull = poly(pts)
  local tre = rect(36, 242, 38, 256):add(rect(110, 240, 112, 256)):add(rect(30, 252, 44, 253)):add(rect(104, 252, 118, 253))
  F.shadow(26, 136, 258, 6, 3)
  rimOf(union(hull, tre), L.timber)
  part(tre, L.timber, { nopop = true, noshade = true })
  part(hull, L.accent)
  hull:each(function(x2, y2)
    local k = 242 - floor(16 * sin((x2 - 20) / 120 * pi) ^ .6)
    if (y2 - k) % 5 == 4 then px(x2, y2, L.accent.deep) end
    if x2 < 64 and y2 > k + 4 then px(x2, y2, (y2 - k) % 5 == 4 and L.timber.edge or L.timber.deep) end -- fresh tar
    if x2 > 100 and y2 > k + 2 and hash(x2 // 2, y2, 99) < .12 then px(x2, y2, L.accent.hi) end -- worn paint
  end)
  hline(24, 132, 241, L.awnA.base) hline(24, 132, 242, L.awnA.deep) -- red gunwale stripe
  local pot = rect(56, 250, 64, 258) rimOf(pot, L.iron) part(pot, L.iron) hline(56, 64, 250, L.timber.edge)
  fill(line({ { 62, 250 }, { 68, 244 } }), L.board.base)
  -- a little fire under the tar pot
  px(58, 259, L.glow.base) px(60, 259, L.glow.shade) px(62, 259, L.glow.base) px(59, 260, L.glow.hi) px(61, 260, L.produce.base)
  local _, thx, thy = F.gnome(82, 266, { hat = L.gold, coat = L.roof2, arm = "out", flip = true })
  fill(line({ { thx, thy }, { thx - 6, thy - 3 } }), L.board.base) fill(rect(thx - 9, thy - 6, thx - 6, thy - 3), L.timber.edge) -- tar brush
end
upBoat()
px(59, 247, L.mist2) px(61, 245, L.mist) px(60, 243, L.mist2) -- steam off the tar
local function creel(x2, yb)
  local m = c:rrect(x2 - 7, yb - 10, x2 + 7, yb, 4)
  rimOf(m, L.board) part(m, L.board)
  m:each(function(xx, y2) if (xx - x2) % 3 == 0 or (y2 - yb) % 3 == 0 then px(xx, y2, L.board.deep) end end)
  fill(c:ellipse(x2, yb - 6, 2, 2), L.soil.deep)
end
creel(160, 262) creel(176, 262) creel(168, 251)
for _, f in ipairs({ { 14, 222, 6 }, { 146, 246, 6 }, { 190, 254, 7 }, { 200, 238, 5 }, { 140, 266, 6 } }) do F.fern(f[1], f[2], f[3]) end
F.mushroom(196, 264, L.apple, true) F.mushroom(201, 266, L.apple)
-- reeds and cattails along the waterline, and in the corner by the jetty foot
local function reed(rx, ry, h, head)
  vline(rx, ry - h, ry, (rx % 2 == 0) and L.fern.shade or L.fern.deep)
  px(rx - 1, ry - h // 2, L.fern.base)
  if head then fill(rect(rx, ry - h - 1, rx + 1, ry - h + 2), L.soil.base) px(rx, ry - h - 1, L.soil.hi) px(rx + 1, ry - h + 2, L.soil.deep) px(rx, ry - h - 2, L.fern.shade) end
end
for k = 0, 13 do
  local rx = 298 + k * 3 + (k % 2) local ry = 168 + k * 3
  reed(rx, ry, 5 + floor(hash(k, 4, 3) * 7), k % 3 == 0)
end
for k = 0, 7 do reed(346 + k * 3, 218 + k + (k % 2), 6 + floor(hash(k, 5, 3) * 6), k % 2 == 0) end
for k = 0, 4 do reed(270 + k * 3, 128 + k * 4, 4 + floor(hash(k, 6, 3) * 4), k == 2) end
-- signpost with a hanging fish board by the road
F.sign(206, 148, 18, 10, L.board)
F.moss(F.rock(222, 196, 6, 5), .35, 100)
F.fern(206, 176, 5) F.fern(214, 210, 6)
F.depth(0)
F.birds({ { 360, 60, 3 }, { 376, 52, 2 }, { 300, 76, 2 }, { 150, 50, 2 } })
fill(c:ellipse(205, 153, 5, 2):add(poly{ { 209, 153 }, { 212, 150 }, { 212, 156 } }), L.accent.base) px(202, 152, L.timber.edge) px(203, 152, L.accent.hi)
F.finish()
