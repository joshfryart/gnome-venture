-- jetty.lua : "Lakeside jetty" stop look, MOUNTAIN (mountain_granite), 480x270 gate view.
-- Same composition as the Maplewold jetty (art-2701-batch3/stops/opus3/jetty.lua), re-cast for an alpine lake:
-- right half: a milky-turquoise glacial lake under the snow peaks (peaks, spruces and larches mirrored softly in the
-- rock-flour water), a moraine shore of boulders and scree, a few ice floes still drifting far out; a larch plank
-- jetty on piles with granite cribs, a moored rowboat, a lantern post and a gnome fishing off the end; a larch
-- boathouse on granite piers under a weighted slab roof, a little sail on the far water; a goosander with her
-- ducklings riding on her back, a leaping char, a dipper on a shore stone.
-- Left: the fisher's stone-and-larch chalet, a rack of char drying in the wind, the net drying frame with cork
-- floats, an upturned boat being tarred, creels, a tabby cat eyeing the fish basket, a goat nosing at the creels.
-- Quirk (kept): a grey heron helping itself to the fish bucket.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-mountain-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "jetty", out = DIR, farTrees = { 24, 52, 120, 196, 352, 440 },
  treeLineGap = { 222, 490 } } -- the right half gets its own moraine shore over the lake
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local mix, rp = F.mix, F.rp
local W = L.water

-- local ramps: silvered larch pier planks, a russet goosander head
local pier = rp("#d6ccb2 #b2a488 #8c7e68 #665a4e #3e3632")
local MILK = "#c4e2de" -- rock flour in the water

---------------------------------------------------------------- the lake
local WL = 119 -- waterline under the far shore
local lake = poly{ { 268, WL }, { 479, WL }, { 479, 228 }, { 372, 228 }, { 350, 220 }, { 326, 202 }, { 304, 176 }, { 288, 150 }, { 276, 130 } }
-- the far moraine shore: grey scree and boulders with turf between
F.depth(0)
local shore = poly{ { 254, 111 }, { 479, 111 }, { 479, WL }, { 268, WL } }
shore:each(function(x, y)
  local v = F.vnoise(x / 6, y / 2, 81) + (hash(x, y, 81) - .5) * .3
  local h = v < .35 and L.mossGround.shade or (v < .55 and L.groundFar or (v < .8 and L.stone.base or L.stone.hi))
  if hash(x, y, 82) < .12 then h = L.stone.shade end
  px(x, y, h)
end)
-- pebbly near shore along the diagonal edge: granite pebbles and turf
local beach = lake:grow(4):cut(lake):clip(rect(0, WL, 479, 269))
beach:each(function(x, y)
  local v = hash(x, y, 5)
  local h = v < .3 and L.stone.base or (v < .5 and L.stone.shade or (v < .72 and L.duff or L.mossGround.hi))
  if hash(x // 2, y // 2, 6) < .15 then h = L.stone.hi end
  if hash(x // 2, y // 2, 7) < .06 then h = L.stone.deep end
  px(x, y, h)
end)
lake:edge():each(function(x, y) if y > WL then px(x, y, L.stone.hi) end end)
-- milky glacial water: pale rock-flour far off, turquoise in the middle, deeper teal by the jetty
local T1 = mix(W.hi, MILK, .4)
local T2 = mix(mix(W.hi, W.base, .5), MILK, .25)
local T3 = mix(W.base, MILK, .18)
local T4 = mix(T3, W.shade, .45)
local T5 = mix(W.base, W.shade, .72)
local shallowC = mix(W.hi, L.stone.base, .45)
local shallow2 = mix(T3, L.stone.hi, .35)
local function tone(x, y)
  local d = y - WL
  if d < 5 then return T1
  elseif d < 18 then return hash(x // 7, y, 14) < .55 and T1 or T2
  elseif d < 30 then return hash(x // 7, y, 14) < .5 and T2 or T3
  elseif d < 58 then return T3
  elseif d < 85 then return hash(x // 6, y // 2, 15) < .55 and T3 or T4
  else return hash(x // 6, y // 2, 16) < .3 and T4 or T5 end
end
lake:shrink(1):each(function(x, y)
  local h = tone(x, y)
  if not lake:has(x - 7, y) or not lake:has(x, y + 7) or not lake:has(x + 5, y + 5) then h = shallow2 end
  if not lake:has(x - 4, y) or not lake:has(x, y + 4) or not lake:has(x + 3, y + 3) then h = shallowC end
  px(x, y, h)
end)

---------------------------------------------------------------- the far shore: sparse spruce and larch stands, boulders, a scree fan
F.depth(1)
-- a scree fan spilling down to the water from the foothills
do
  local fan = poly{ { 410, 104 }, { 420, 104 }, { 446, WL - 1 }, { 392, WL - 1 } }
  fan:each(function(x, y)
    local v = hash(x, y, 71)
    px(x, y, v < .35 and L.stone.hi or (v < .7 and L.stone.base or (v < .88 and L.stone.shade or L.stone.deep)))
  end)
end
local i = 0
for x = 262, 482, 7 do
  i = i + 1
  if hash(x, 9, 82) < .55 and not (x > 392 and x < 446) then
    local hh = 10 + floor(hash(x, 1, 82) * 10)
    F.tree(x + floor(hash(x, 2, 82) * 4), 113 + floor(hash(x, 3, 82) * 2), hh, i * 2, true)
  end
end
F.depth(2)
i = 0
local x = 262
while x < 486 do
  i = i + 1
  local hh = 16 + floor(hash(x, 4, 83) * 18)
  local inFan = x > 398 and x < 440
  if x > 380 and x < 452 then hh = hh - 4 end -- lower behind the boathouse roof
  if not inFan and hash(x, 8, 83) < .72 then
    local yb = WL - 1 + floor(hash(x, 5, 83) * 2)
    if hash(x, 6, 83) < .35 then F.larch(x, yb, hh, 600 + i) else F.tree(x, yb, hh, (i % 5 == 1) and 3 or ((i % 2) * 2)) end
  end
  x = x + 9 + floor(hash(x, 7, 83) * 9)
end
-- granite boulders between the stands
for _, b in ipairs({ { 276, WL, 4, 3 }, { 330, WL, 5, 4 }, { 372, WL - 1, 3, 3 }, { 402, WL, 6, 4 }, { 452, WL, 4, 3 }, { 470, WL - 1, 3, 2 } }) do
  F.boulder(b[1], b[2], b[3], b[4], b[1])
end
F.depth(0)
-- the mirror: peaks, foothills and trees, softened by the milky water and broken by ripple rows
for xx = 268, 479 do
  for k = 1, 74 do
    local sy, dy = WL - k, WL - 1 + k
    if lake:has(xx, dy) and lake:has(xx, dy + 1) and not beach:has(xx, dy) and sy >= 0 then
      local v = c:get(xx, sy)
      if v and not (dy % 3 == 0 and hash(xx // 4, dy, 84) < .5) then
        local t = .16 + k * .0045
        if k > 60 then t = t + (k - 60) * .05 end
        local h = mix(v, tone(xx, dy), math.min(1, t))
        if (xx + dy) % 2 == 0 and k > 50 then h = mix(h, T3, .4) end
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
-- cold sun glints
for k = 0, 34 do local gx, gy = 276 + floor(hash(k, 1, 18) * 200), 124 + floor(hash(k, 2, 18) * 96) if lake:has(gx, gy) then px(gx, gy, "#f2f0dc") px(gx + 1, gy, W.hi) end end
-- a few ice floes still drifting far out
for _, f in ipairs({ { 330, 128, 6 }, { 352, 124, 3 }, { 452, 162, 5 }, { 466, 158, 2 }, { 300, 138, 3 } }) do
  local fx, fy, fw = f[1], f[2], f[3]
  local m = poly{ { fx - fw, fy }, { fx - fw + 2, fy - 1 }, { fx + fw - 1, fy - 1 }, { fx + fw, fy } }
  fill(m, L.snow.hi) hline(fx - fw + 1, fx + fw - 1, fy + 1, L.snow.shade) hline(fx - fw + 2, fx + fw - 2, fy + 2, mix(L.snow.shade, T2, .5))
  px(fx + fw, fy, L.snow.base) px(fx - fw + 2, fy - 1, "#f6f6f0")
end
-- a leaping char (red belly) over its rings
do
  local fx, fy = 364, 156
  c:ellipse(fx, fy + 6, 9, 2):edge():each(function(x2, y2) px(x2, y2, W.hi) end)
  c:ellipse(fx, fy + 6, 13, 3):edge():each(function(x2, y2) if (x2 // 2) % 2 == 0 then px(x2, y2, W.hi) end end)
  F.sprite({ "...ff..", ".fffff.", "fGGpGe.", ".fppf..", "f.f....", }, fx - 3, fy - 4,
    { f = L.foliage2.shade, G = L.stone.hi, p = L.apple.hi, e = L.timber.edge })
  for _, d in ipairs({ { -6, 2 }, { 5, 3 }, { -4, -1 }, { 7, 0 } }) do px(fx + d[1], fy + d[2], W.hi) end
end
-- granite stones breaking the surface in the shallows (where the forest lake had lily pads)
local function wetStone(sx, sy, w, h, seed)
  F.boulder(sx, sy, w, h, seed)
  hline(sx - w - 1, sx + w + 1, sy + 1, W.hi) hline(sx - w + 1, sx + w - 1, sy + 2, T4)
end
wetStone(312, 168, 3, 2, 31) wetStone(334, 196, 4, 3, 32) wetStone(298, 154, 2, 2, 33) wetStone(346, 210, 3, 2, 34)
-- a dipper bobbing on one of them
local function dipper(x2, yb, flip)
  local rows = { "..dd.....", ".dbbd....", "dbebd...t", "kdWbbd.tt", ".dWWbbbd.", "..dWbbdd.", "...ddd...", "...o.o..." }
  if flip then for j, r in ipairs(rows) do rows[j] = r:reverse() end end
  F.sprite(rows, x2 - 4, yb - 7, { d = "#4a3a36", b = "#6e5448", W = L.edel.hi, e = L.timber.edge, k = L.iron.deep, t = "#4a3a36", o = L.timber.deep })
end
dipper(312, 165, true)

---------------------------------------------------------------- the goosander (ducklings riding on her back) + a far one
local function goosander(lx, ly, big)
  local map = { K = "#9a4a34", k = "#c26a46", R = "#d8603a", b = "#e07a3a", W = L.edel.hi, F = "#c8ccc6",
    G = "#8e969c", g = "#b0b6ba", D = "#6a7078", c = "#7a5a3e", C = "#c8a878", e = L.timber.edge }
  if big then
    F.sprite({
      ".kKK................",
      "kKKKKk..............",
      "KKKeKK..............",
      ".bbKKK..............",
      "...WWW......cc......",
      "...WWW.....cCCc.cc..",
      "...WWWggggcCeCcCCc..",
      "..WWgGgGgGgGgGGGDD..",
      "..WgGgGgGgGgGGGGGDD.",
      "...WGGGGGGGGGGGDDD..",
      "....FFFFFFFFFFFF....",
    }, lx, ly, map)
    for k = 0, 2 do hline(lx + 2 - k * 3, lx + 18 + k * 3, ly + 11 + k * 2, k == 0 and T5 or W.hi) end
    hline(lx - 6, lx + 1, ly + 11, W.hi) -- wake
  else
    F.sprite({ ".kK.....", "bKK.....", ".WWggGg.", ".WGgGGGD", "..FFFFF." }, lx, ly, map)
    hline(lx, lx + 8, ly + 6, T1)
  end
end
goosander(318, 150, true)
F.depth(1)
goosander(346, 130, false)

---------------------------------------------------------------- far water: sail boat and a larch boathouse on granite piers
local function sail(x2, y2)
  local hull = poly{ { x2 - 8, y2 }, { x2 + 8, y2 }, { x2 + 5, y2 + 3 }, { x2 - 5, y2 + 3 } }
  local s1 = poly{ { x2, y2 - 1 }, { x2, y2 - 16 }, { x2 + 8, y2 - 1 } }
  local s2 = poly{ { x2 - 1, y2 - 1 }, { x2 - 1, y2 - 12 }, { x2 - 7, y2 - 1 } }
  rimOf(union(hull, s1, s2), L.timber)
  part(hull, L.roof2, { nopop = true }) fill(s1, L.awnB.base) fill(s2, L.awnB.shade) vline(x2, y2 - 16, y2, L.timber.base)
  vline(x2 + 1, y2 - 13, y2 - 2, L.awnB.hi) hline(x2 + 1, x2 + 4, y2 - 4, L.awnA.base) -- a red band on the sail
  for k = 1, 3 do hline(x2 - 6 + k, x2 + 6 - k, y2 + 4 + k * 2, T4) end
  for k = 1, 3 do hline(x2 + 1, x2 + 5 - k, y2 + 4 + k * 2 - 1, mix(L.awnB.base, T2, .5)) end
end
sail(286, 134)
F.depth(2)
local function boathouse()
  local top, _, wallM, roofM = F.building{ x0 = 388, x1 = 444, yb = 140, wh = 26, rh = 20, wall = L.timber, roof = L.roof,
    noShadow = true, noFrame = true, noAttic = true, shingle = true }
  F.planks(wallM, L.timber, 3, true, 23)
  wallM:each(function(x2, y2) if y2 < top + 6 and hash(x2, y2, 24) < .3 then px(x2, y2, L.timber.deep) end end) -- sun-scorched
  F.lichen(roofM, .22, 85)
  for _, w in ipairs({ { 395, 113 }, { 408, 104 }, { 424, 104 }, { 437, 113 } }) do
    local ws = c:ellipse(w[1], w[2], 2, 1) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true }) px(w[1] - 1, w[2] - 1, L.stone.hi)
  end
  F.window(424, 120, 430, 125, L.timber)
  hline(422, 432, 127, L.timber.base) for k = 0, 4 do px(423 + k * 2, 126, L.apple.base) px(424 + k * 2, 126, L.leaf.base) end
  -- big water door, the dark water inside
  local d = rect(396, 124, 416, 140) fill(d, L.soil.deep) fill(rect(398, 134, 414, 140), W.deep)
  hline(399, 413, 136, W.edge) hline(398, 414, 124, L.timber.hi) vline(396, 124, 140, L.timber.base) vline(416, 124, 140, L.timber.shade)
  -- a gentian-blue skiff stowed inside
  hline(400, 412, 132, L.accent.base) hline(401, 411, 133, L.accent.shade) px(400, 131, L.accent.hi)
  -- stovepipe
  local pipe = rect(434, top - 14, 436, top - 2) rimOf(pipe, L.iron) part(pipe, L.iron, { nopop = true })
  -- granite piers
  local piers = HP.mask()
  for _, x2 in ipairs({ 388, 414, 438 }) do piers:add(rect(x2, 141, x2 + 6, 151)) end
  rimOf(piers, L.stone) part(piers, L.stone, { nopop = true }) F.courses(piers, 141, 3, 4, L.stone)
  piers:each(function(x2, y2) if y2 > 148 then px(x2, y2, hash(x2, y2, 86) < .5 and L.stone.deep or L.stone.shade) end end)
  F.lichen(piers, .15, 87)
  -- the boathouse mirrored in the water under it
  for y2 = 152, 162 do for x2 = 388, 444 do
    if lake:has(x2, y2) and not (y2 % 3 == 0 and hash(x2 // 4, y2, 88) < .5) then
      local src = c:get(x2, 151 - (y2 - 152) * 1)
      if src then px(x2, y2, mix(src, T3, .5 + (y2 - 152) * .04)) end
    end
  end end
  for y2 = 153, 161, 2 do hline(392, 440, y2, (y2 % 4 == 1) and T4 or T2) end
  F.smoke(435, top - 18, 5, .7, 2)
end
boathouse()
F.depth(0)
-- thin cold mist lying on the far water
for _, b in ipairs({ { 270, 400, 119, 1 }, { 300, 479, 122, 1 }, { 380, 479, 152, 1 } }) do
  for y2 = b[3], b[3] + b[4] - 1 do
    for x2 = b[1], b[2] do
      local edge = math.min(x2 - b[1], b[2] - x2)
      if lake:has(x2, y2) then
        if hash(x2 // 5, y2, 87) < .6 and hash(x2, y2, 88) < math.min(1, edge / 18 + .2) then
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
  part(hull, L.accent) hline(x0 + 2, x1 - 2, y + 3, L.awnB.base) hline(x0 + 4, x1 - 4, y + 4, L.awnA.base)
  hull:each(function(x2, y2) if y2 > y + 5 and hash(x2, y2, 89) < .25 then px(x2, y2, L.moss.shade) end end)
  hline(x0 + 1, x1 - 1, y, L.accent.hi)
  fill(inside, L.timber.shade) c:edgeIn(inside, L.board.base)
  vline(x0 + 16, y - 4, y, L.board.hi) vline(x1 - 16, y - 4, y, L.board.hi)
  fill(line({ { x0 + 8, y - 2 }, { x1 + 6, y + 6 } }), L.board.shade) fill(rect(x1 + 4, y + 5, x1 + 8, y + 7), L.board.base)
  -- the boat's name in cream dots on the bow, and a pair of char in the bottom
  for k = 0, 3 do px(x1 - 12 + k * 2, y + 1, L.awnB.hi) end
  fill(c:ellipse(x0 + 24, y - 2, 3, 0), L.stone.hi) px(x0 + 22, y - 2, L.apple.base)
  for k = 0, 3 do hline(x0 + 6 + k, x1 - 6 - k, y + 9 + k * 2, T5) end
  for k = 0, 2 do hline(x0 + 10 + k * 2, x1 - 18 - k * 2, y + 10 + k * 2, mix(L.accent.base, T4, .55)) end
end
F.depth(3)
local deck = rect(300, 178, 470, 185)
local face = rect(300, 186, 470, 188)
local piles, cribs = HP.mask(), HP.mask()
for x2 = 312, 466, 18 do piles:add(rect(x2, 189, x2 + 2, 206)) end
-- granite-filled larch cribs at every other pile
for x2 = 330, 466, 36 do cribs:add(rect(x2 - 3, 199, x2 + 5, 207)) end
for x2 = 312, 466, 18 do for y2 = 208, 220, 3 do if lake:has(x2, y2) and lake:has(x2 + 1, y2 + 1) then px(x2, y2, W.deep) px(x2 + 1, y2 + 1, T5) end end end
rimOf(union(deck, face, piles), L.timber)
part(piles, L.timber, { nopop = true, noshade = true })
piles:each(function(x2, y2) if y2 > 197 and hash(x2, y2, 90) < .5 then px(x2, y2, y2 > 201 and L.timber.deep or L.moss.shade) end end)
c:rim(cribs, L.timber.edge)
cribs:each(function(x2, y2)
  local v = hash(x2 // 2, y2 // 2, 91)
  local h = v < .35 and L.stone.hi or (v < .7 and L.stone.base or L.stone.shade)
  if (y2 - 199) % 4 == 0 then h = L.timber.base end
  if y2 > 204 then h = (hash(x2, y2, 92) < .5) and L.stone.deep or L.stone.shade end
  px(x2, y2, h)
end)
for x2 = 330, 466, 36 do hline(x2 - 4, x2 + 6, 208, W.hi) end
for x2 = 312, 466, 18 do hline(x2, x2 + 2, 203, W.hi) end
part(deck, pier)
F.planks(deck, pier, 5, true, 21)
F.lichen(deck, .06, 91)
hline(300, 470, 178, pier.hi)
for x2 = 300, 470 do if (x2 // 3) % 2 == 0 then px(x2, 189, T5) end end
part(face, L.timber, { nopop = true })
face:each(function(x2, y2) if y2 == 188 and hash(x2 // 2, 0, 92) < .5 then px(x2, y2, L.timber.deep) end end)
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
-- a tackle box, a tin mug and a wedge of cheese on the deck
local tb = rect(406, 172, 414, 177) rimOf(tb, L.timber) part(tb, L.accent, { nopop = true }) hline(406, 414, 174, L.accent.deep) px(410, 173, L.gold.hi)
local mug = rect(344, 173, 347, 177) rimOf(mug, L.iron) part(mug, L.iron, { nopop = true }) px(348, 175, L.iron.shade)
local wedge = poly{ { 352, 177 }, { 360, 177 }, { 360, 173 } } rimOf(wedge, L.cheese) part(wedge, L.cheese, { nopop = true }) px(358, 175, L.cheese.shade)

---------------------------------------------------------------- shore wedge: heron at the fish bucket (quirk), rope, anchor
F.eraseGround(rect(300, 236, 324, 251)) -- keep the bucket's silhouette clear
local bucket = poly{ { 304, 252 }, { 318, 252 }, { 316, 264 }, { 306, 264 } }
rimOf(bucket, L.timber) part(bucket, L.board) hline(304, 318, 255, L.iron.shade) hline(305, 317, 261, L.iron.shade)
for k = 0, 3 do local fx = 306 + k * 3 fill(rect(fx, 248 - (k % 2), fx + 1, 252), L.stone.hi) px(fx, 248 - (k % 2), L.foliage2.shade) px(fx + 1, 250, L.apple.base) end
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
}, 284, 230, { k = "#3e4048", w = L.birch.hi, e = L.timber.edge, y = L.gold.hi, Y = L.gold.shade, f = L.stone.hi, F = L.apple.base,
  G = L.stone.hi, g = L.stone.base, d = L.stone.shade, D = L.stone.deep, l = L.gold.deep })
-- coiled rope + anchor, lichened boulders, edelweiss, gentian and cotton grass on the shore
local coil = c:ellipse(354, 248, 9, 4) rimOf(coil, L.board) part(coil, L.board) fill(c:ellipse(354, 248, 4, 1), L.board.deep)
for k = 0, 2 do c:ellipse(354, 248, 8 - k * 2, 3 - k // 2):edge():each(function(x2, y2) if y2 > 247 then px(x2, y2, L.board.shade) end end) end
local anc = rect(336, 230, 337, 244):add(line({ { 330, 240 }, { 336, 245 }, { 343, 240 } }, 2)):add(rect(333, 232, 340, 233))
rimOf(anc, L.iron) part(anc, L.iron, { nopop = true }) fill(c:ellipse(336, 228, 2, 2):cut(c:ellipse(336, 228, 1, 1)), L.iron.base)
anc:each(function(x2, y2) if y2 > 241 and hash(x2, y2, 93) < .4 then px(x2, y2, L.roof2.shade) end end) -- rust
F.boulder(368, 264, 9, 8, 94)
F.boulder(326, 269, 6, 5, 95)
F.juniper(372, 252, 7, 4, 96)
F.edelweiss(346, 262, true) F.edelweiss(278, 246, true) F.gentian(282, 250, true) F.gentian(362, 236, true) F.edelweiss(366, 232, true)
F.gentian(292, 214, true) F.edelweiss(298, 217, true) F.gentian(287, 217)

---------------------------------------------------------------- left: fisher's stone-and-larch chalet, fish rack
F.depth(1)
F.larch(84, 128, 40, 3)
F.tree(10, 134, 40, 1)
local ctop, _, cwall, croof = F.building{ x0 = 20, x1 = 70, yb = 136, wh = 32, rh = 22, wall = L.timber, roof = L.roof, chimney = true, shingle = true, noFrame = true, noAttic = true }
F.planks(cwall, L.timber, 3, false, 25)
local cbase = rect(20, 124, 70, 136)
part(cbase, L.plaster, { nopop = true }) F.courses(cbase, 124, 4, 7, L.plaster)
cbase:each(function(x2, y2) if hash(x2 // 3, y2 // 3, 26) < .12 then px(x2, y2, L.stone.base) end end)
hline(20, 70, 123, L.timber.edge)
F.lichen(croof, .2, 96)
for _, w in ipairs({ { 27, 100 }, { 63, 100 } }) do
  local ws = c:ellipse(w[1], w[2], 2, 1) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true }) px(w[1] - 1, w[2] - 1, L.stone.hi)
end
-- a balcony with red geraniums under the upper windows
local bal = rect(18, 119, 72, 121) rimOf(bal, L.timber) part(bal, L.timber, { nopop = true, noshade = true })
for x2 = 20, 70, 3 do px(x2, 118, L.apple.base) if x2 % 2 == 0 then px(x2 + 1, 117, L.apple.hi) end px(x2 + 1, 118, L.leaf.shade) end
F.window(26, 108, 32, 114, L.timber) F.window(56, 108, 62, 114, L.timber) F.door(48, 125, 55, 135, L.accent)
F.smoke(61, 86, 6, .5, 2)
-- a fish-shaped sign on the chalet's stone foot
local fs = c:ellipse(35, 130, 6, 3):add(poly{ { 40, 130 }, { 45, 126 }, { 45, 134 } })
rimOf(fs, L.accent) part(fs, L.accent) px(31, 129, L.timber.edge)
-- the char-drying rack: split fish hung by the tail in the dry wind
local function fishRack(x0, x1, yb)
  local posts = rect(x0, yb - 22, x0 + 1, yb):add(rect(x1, yb - 22, x1 + 1, yb))
  local bar = rect(x0 - 2, yb - 22, x1 + 3, yb - 21)
  local roofB = poly{ { x0 - 4, yb - 24 }, { (x0 + x1) // 2, yb - 28 }, { x1 + 5, yb - 24 } }
  F.shadow(x0, x1, yb, 6, 3)
  rimOf(union(posts, bar, roofB), L.timber) part(posts, L.timber, { nopop = true, noshade = true }) part(bar, L.timber, { nopop = true, noshade = true })
  part(roofB, L.roof2, { nopop = true }) hline(x0 - 2, x1 + 3, yb - 24, L.roof2.deep)
  for x2 = x0 + 4, x1 - 2, 5 do
    vline(x2, yb - 20, yb - 19, L.timber.edge)
    local fsh = poly{ { x2 - 1, yb - 18 }, { x2 + 2, yb - 18 }, { x2 + 2, yb - 9 }, { x2, yb - 7 }, { x2 - 1, yb - 9 } }
    local tl = poly{ { x2 - 2, yb - 7 }, { x2 + 3, yb - 7 }, { x2, yb - 9 } }
    local char = (x2 // 5) % 2 == 0
    fill(union(fsh, tl), char and L.stone.base or L.needle.shade) vline(x2 + 2, yb - 18, yb - 10, L.stone.deep) px(x2, yb - 16, L.timber.edge)
    px(x2 - 1, yb - 17, char and L.stone.hi or L.needle.hi)
    if char then vline(x2, yb - 14, yb - 11, L.apple.base) end
  end
end
fishRack(96, 150, 140)
-- split larch stacked against the chalet, a stump with an axe in it
F.depth(2)
for k = 0, 3 do F.logEnd(76 + k * 5, 146, 2) end
for k = 0, 2 do F.logEnd(78 + k * 5, 142, 2) end
for k = 0, 1 do F.logEnd(80 + k * 5, 138, 2) end
do
  local sb = rect(26, 158, 36, 166) local st = c:ellipse(31, 158, 5, 2)
  rimOf(union(sb, st), L.timber) part(sb, L.timber, { nopop = true }) fill(st, L.board.base) px(31, 158, L.board.shade) px(28, 157, L.board.hi)
  F.lichen(sb, .3, 101)
  fill(line({ { 33, 157 }, { 39, 150 } }), L.board.base) fill(rect(31, 154, 34, 157), L.iron.base) px(31, 154, L.iron.hi)
end
F.depth(1)
F.juniper(16, 140, 5, 4, 102) F.juniper(90, 143, 4, 3, 103)
F.edelweiss(74, 140, true) F.gentian(80, 150)
F.depth(3)

---------------------------------------------------------------- left hero: net drying frame with cork floats
local function netFrame(x0, x1, yt, yb)
  local posts = rect(x0, yt, x0 + 3, yb):add(rect(x1 - 3, yt, x1, yb)):add(rect((x0 + x1) // 2 - 1, yt, (x0 + x1) // 2 + 1, yb))
  local bar = rect(x0 - 3, yt, x1 + 3, yt + 3)
  F.shadow(x0, x1, yb, 14, 5)
  rimOf(union(posts, bar), L.timber)
  part(posts, L.timber, { nopop = true }) part(bar, L.timber, { nopop = true })
  bar:each(function(x2, y2) if y2 == yt and hash(x2, y2, 104) < .3 then px(x2, y2, L.timber.deep) end end)
  F.lichen(posts:copy():clip(rect(x0, yb - 14, x1, yb)), .25, 97)
  -- granite footing stones at the post feet
  for _, fx in ipairs({ x0 + 1, (x0 + x1) // 2, x1 - 1 }) do F.boulder(fx, yb + 1, 4, 3, fx) end
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
  -- a larch twig and a straw wisp snagged in the net
  px(120, 170, L.foliage.base) px(121, 171, L.foliage.shade) px(160, 176, L.needle.base) px(161, 177, L.needle.shade)
end
netFrame(92, 192, 150, 214)
F.barrel(110, 222, L.timber, 11) F.barrel(124, 224, L.board, 9)
-- basket of char
local bk = poly{ { 160, 214 }, { 182, 214 }, { 179, 224 }, { 163, 224 } }
rimOf(bk, L.board) part(bk, L.needle) bk:each(function(x2, y2) if (x2 + y2) % 3 == 0 then px(x2, y2, L.needle.shade) end end)
for k = 0, 4 do local fx = 162 + k * 4 fill(c:ellipse(fx, 212, 2, 1), L.stone.hi) px(fx + 2, 212, L.foliage2.shade) px(fx - 1, 212, L.apple.base) px(fx, 213, L.apple.shade) end
-- oars leaning
fill(line({ { 194, 228 }, { 186, 176 } }, 2), L.board.base) fill(c:rrect(184, 168, 189, 182, 2), L.board.shade)
vline(185, 169, 181, L.board.hi) hline(184, 189, 175, L.accent.base)
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

---------------------------------------------------------------- bottom-left: arolla pine, upturned boat on trestles, tar pot, creels
F.tree(44, 206, 54, 2)
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
  part(hull, L.roof2)
  hull:each(function(x2, y2)
    local k = 242 - floor(16 * sin((x2 - 20) / 120 * pi) ^ .6)
    if (y2 - k) % 5 == 4 then px(x2, y2, L.roof2.deep) end
    if x2 < 64 and y2 > k + 4 then px(x2, y2, (y2 - k) % 5 == 4 and L.timber.edge or L.timber.deep) end -- fresh tar
    if x2 > 100 and y2 > k + 2 and hash(x2 // 2, y2, 99) < .12 then px(x2, y2, L.roof2.hi) end -- worn varnish
  end)
  hline(24, 132, 241, L.accent.base) hline(24, 132, 242, L.accent.deep) -- gentian-blue gunwale stripe
  local pot = rect(56, 250, 64, 258) rimOf(pot, L.iron) part(pot, L.iron) hline(56, 64, 250, L.timber.edge)
  fill(line({ { 62, 250 }, { 68, 244 } }), L.board.base)
  -- a little fire on hearth stones under the tar pot
  px(58, 259, L.glow.base) px(60, 259, L.glow.shade) px(62, 259, L.glow.base) px(59, 260, L.glow.hi) px(61, 260, L.produce.base)
  px(55, 260, L.stone.base) px(65, 260, L.stone.base) px(54, 260, L.stone.shade) px(66, 260, L.stone.shade)
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
-- a goat nosing at the creels
F.goat(178, 143, { k = .5, flip = true, graze = true })
F.juniper(14, 224, 7, 5, 105) F.juniper(146, 248, 6, 4, 106)
F.boulder(204, 240, 6, 5, 107)
for _, f in ipairs({ { 22, 214 }, { 140, 264 }, { 198, 228 }, { 150, 236 } }) do F.edelweiss(f[1], f[2], true) end
for _, f in ipairs({ { 10, 232 }, { 136, 258 }, { 212, 252 }, { 188, 246 } }) do F.gentian(f[1], f[2], true) end
-- sedges and cotton grass along the waterline, and in the corner by the jetty foot
local function sedge(rx, ry, h, head)
  vline(rx, ry - h, ry, (rx % 2 == 0) and L.fern.shade or L.fern.deep)
  px(rx - 1, ry - h // 2, L.fern.base)
  if head then
    px(rx, ry - h - 1, L.edel.hi) px(rx + 1, ry - h - 1, L.edel.base) px(rx, ry - h - 2, L.edel.hi) px(rx + 1, ry - h, L.edel.shade)
  end
end
for k = 0, 13 do
  local rx = 298 + k * 3 + (k % 2) local ry = 168 + k * 3
  sedge(rx, ry, 4 + floor(hash(k, 4, 3) * 6), k % 2 == 0)
end
for k = 0, 7 do sedge(346 + k * 3, 218 + k + (k % 2), 5 + floor(hash(k, 5, 3) * 5), k % 2 == 1) end
for k = 0, 4 do sedge(270 + k * 3, 128 + k * 4, 3 + floor(hash(k, 6, 3) * 4), k % 2 == 0) end
for k = 0, 6 do sedge(312 + k * 3 + (k % 2), 222 + (k % 3), 5 + floor(hash(k, 7, 3) * 5), true) end
-- signpost with a hanging fish board by the road
F.sign(206, 148, 18, 10, L.board)
F.boulder(222, 196, 6, 5, 100)
F.edelweiss(206, 176, true) F.gentian(214, 210, true)
F.depth(0)
F.birds({ { 360, 60, 3 }, { 376, 52, 2 }, { 300, 76, 2 }, { 150, 50, 2 } })
fill(c:ellipse(205, 153, 5, 2):add(poly{ { 209, 153 }, { 212, 150 }, { 212, 156 } }), L.accent.base) px(202, 152, L.timber.edge) px(203, 152, L.accent.hi)
F.finish()
