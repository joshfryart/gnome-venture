-- camp.lua : "Camp" stop look, RAINFOREST (rainforest_canopy), 480x270 gate view.
-- Same composition and story as the Maplewold camp (art-2701-batch3/stops/opus3/camp.lua) and the forest camp,
-- re-cast as a jungle expedition camp: road's end: a two-peak teal-and-cream canvas fly on bamboo poles, palm fronds
-- thrown over it, open sides glowing with lamp light and a mosquito net, cook smoke from a clay chimney. Back left:
-- an A-frame of fresh palm leaves and a hammock slung between two canopy trees; a mossy fallen log with bracket
-- fungi. A washing line of batik sarongs from a canopy tree to a palm, a gnome pegging, a spider monkey swinging off
-- the line with a stolen sock. Right: a round hut of palm thatch on a bamboo deck, open sided, a striped hammock
-- with a gnome asleep in it, a hanging lantern. Back right: a dugout canoe on bamboo trestles, paddles, a fish trap.
-- Left: firewood between bamboo stakes under a palm-frond lid, an agouti. Hero: the campfire in a wet mossy stone
-- ring, a bamboo tripod with a clay cooking pot, rice cooking in bamboo tubes, banana-leaf parcels in the embers,
-- mossy log seats with fungi, a ukulele player, a plantain-toasting gnome, a gnome with a coconut cup, a capybara
-- asleep. Bottom left: a bamboo camp table on a banana-leaf cloth: a clay pot, a pineapple, papaya, bananas.
-- Right of the road: rolled pandan mats, woven rattan packs. Near right: a papaya tree, a stump with a machete.
-- Quirk: a coati in a red gnome hat climbing out of the rattan pack with a sausage, ringed tail up over the rim.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-rainforest-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "camp", out = DIR, farTrees = { 24, 52, 160, 196, 290, 318, 440 }, treeLineGap = { 194, 286 }, shafts = { { 30, 16 }, { 118, 9 }, { 178, 12 }, { 342, 16 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local G, IR = L.glow, L.iron
local clay = F.rp("#f6ae7c #d27448 #a8523a #7a3a2e #4a2420")   -- terracotta cooking pots
local rattan = F.rp("#f2d496 #d4aa62 #a87e44 #7a5832 #4a3622") -- woven rattan / pandan
local batik = F.rp("#5ad6e0 #2a9cb8 #1e7090 #164e6c #0e3048")  -- indigo-teal sarong
local coati = F.rp("#d8a070 #b07040 #84502e #5a3424 #382018")  -- ruddy coati fur
local papayaR = F.rp("#ffc862 #f69a2e #d06a22 #9a4a1e #5e2c16")

-- local helpers ------------------------------------------------------------------------
local function stump(x, yb, w, mossK, seed)
  local body = rect(x - w, yb - w, x + w, yb)
  local top = c:ellipse(x, yb - w, w, math.max(1, w // 2))
  local roots = poly{ { x - w - 3, yb }, { x - w, yb - 4 }, { x - w, yb } }:add(poly{ { x + w + 3, yb }, { x + w, yb - 4 }, { x + w, yb } })
  rimOf(union(body, top, roots), L.timber)
  part(union(body, roots), L.timber, { nopop = true })
  body:each(function(xx, yy) if (xx - x) % 3 == 0 and hash(xx, yy // 2, seed or 5) < .6 then px(xx, yy, L.timber.shade) end end)
  vline(x - w + 1, yb - w + 1, yb - 1, L.timber.hi)
  fill(top, L.redbark.hi)
  top:each(function(xx, yy) local d = math.sqrt((xx - x) ^ 2 + ((yy - (yb - w)) * 2) ^ 2) if floor(d) % 2 == 1 then px(xx, yy, L.redbark.base) end if xx - x + (yy - (yb - w)) * 2 < -w * .6 then px(xx, yy, L.board.hi) end end)
  px(x, yb - w, L.redbark.deep)
  if mossK then F.moss(body, mossK, seed or 7) end
  F.shine(body, .06, (seed or 7) + 3)
  return body, top
end
-- orange bracket fungus shelf on a trunk or log
local function bracket(x, y, w)
  for k = 0, w - 1 do px(x + k, y, k < w // 2 and L.produce.hi or L.produce.base) px(x + k, y + 1, L.produce.shade) end
  px(x - 1, y + 1, L.produce.deep) px(x + w, y + 1, L.produce.deep) hline(x, x + w - 1, y + 2, L.timber.edge)
end
local function coconut(x, y, half)
  local m = c:ellipse(x, y, 2, 2)
  c:rim(m, L.soil.edge) fill(m, L.soil.base) px(x - 1, y - 1, L.soil.hi) px(x + 1, y + 1, L.soil.shade)
  if half then fill(rect(x - 1, y - 1, x + 1, y), L.awnB.hi) px(x, y, L.awnB.shade) end
end
-- a curved band slung between two points (hammock): stripes across, rope fans at the ends
local function hammock(xa, ya, xb, yb, sag, ramps, o)
  o = o or {}
  local function cy(x) local t = (x - xa) / (xb - xa) return ya + (yb - ya) * t + sag * 4 * t * (1 - t) end
  local band = HP.mask()
  local e = o.ends or 6
  for x = xa + e, xb - e do
    local t = (x - xa - e) / (xb - xa - 2 * e)
    local th = floor(1 + 3 * sin(pi * t) ^ .5 + .5)
    local y0 = floor(cy(x) + .5)
    for y = y0 - th + 1, y0 + 1 do band:set(x, y) end
  end
  local ropes = HP.mask()
  for _, d in ipairs({ -2, 0, 2 }) do
    ropes:add(line({ { xa, ya }, { xa + e, floor(cy(xa + e) + .5) + d // 2 } }))
    ropes:add(line({ { xb, yb }, { xb - e, floor(cy(xb - e) + .5) + d // 2 } }))
  end
  ropes:each(function(x, y) px(x, y, L.needle.deep) end)
  rimOf(band, L.timber)
  band:each(function(x, y)
    local r = ramps[((x - xa) // 3) % #ramps + 1]
    local top = not band:has(x, y - 1)
    local bot = not band:has(x, y + 1)
    px(x, y, top and r.hi or (bot and r.shade or r.base))
  end)
  return band, cy
end
-- woven texture over a mask: an over-under basket weave
local function weave(m, r, s)
  s = s or 2
  m:each(function(x, y)
    local a, b = (x // s) % 2, (y // s) % 2
    px(x, y, a == b and r.base or r.shade)
    if a == b and x % s == 0 then px(x, y, r.hi) end
  end)
end
-- a papaya tree: a slim scarred trunk, a crown of long-stalked torn palmate leaves, the fruit under the crown
local function papaya(x, yb, h)
  local ty = yb - h
  local trunk = poly{ { x - 2, yb }, { x + 2, yb }, { x + 1, ty }, { x - 1, ty } }
  rimOf(trunk, L.palmTrunk)
  trunk:each(function(xx, yy)
    local hh = xx < x and L.palmTrunk.hi or L.palmTrunk.base
    if (yy - ty) % 4 == 0 then hh = L.palmTrunk.shade end
    if (yy - ty) % 4 == 0 and hash(xx, yy, 3) < .3 then hh = L.palmTrunk.deep end
    px(xx, yy, hh)
  end)
  for i, a in ipairs({ -pi * .95, -pi * .78, -pi * .62, -pi * .45, -pi * .28, -pi * .1, -pi * .55 }) do
    local len = 14 + floor(hash(i, 1, 7) * 5)
    local sx, sy = x + floor(cos(a) * len * .55 + .5), ty + floor(sin(a) * len * .4 + .5) + 2
    F.bigLeaf(sx, sy, floor(len * .6), a + (a < -pi / 2 and -.35 or .35), i % 2 == 0 and L.leaf or L.foliage, 60 + i, 5, { torn = true, droop = .45, stem = { x, ty + 1 } })
  end
  for k, d in ipairs({ { -3, 3 }, { 2, 3 }, { -1, 6 }, { 3, 7 }, { -4, 8 } }) do
    local f = c:ellipse(x + d[1], ty + d[2], 2, 3)
    local r = k <= 2 and papayaR or L.leaf
    c:rim(f, r.edge) part(f, r, { nopop = true }) px(x + d[1] - 1, ty + d[2] - 1, r.hi)
  end
end

-- trodden red-earth clearing around the fire (left of the road)
local clear = c:ellipse(150, 214, 92, 30)
clear:each(function(x, y) if not F.roadM:has(x, y) and x < F.xl(y) - 1 then
  local v = hash(x, y, 3)
  local d = ((x - 150) / 92) ^ 2 + ((y - 214) / 30) ^ 2
  if d < .8 then
    local b = hash(x // 4, y // 2, 4)
    local h = b < .55 and L.soil.base or (b < .85 and L.ground.shade or L.soil.shade)
    if v < .04 then h = L.soil.hi elseif v > .96 then h = L.soil.deep elseif v > .9 then h = L.litter.base end
    px(x, y, h)
  elseif hash(x // 3, y // 2, 4) < .45 then px(x, y, L.litter.shade) end
end end)

---------------------------------------------------------------- back trees (plane 1)
F.depth(1)
F.tree(10, 140, 46, 1)
F.palm(318, 138, 46, 5, { lean = -5 })
F.tree(384, 142, 58, 9)
F.palm(444, 136, 44, 11, { lean = 6, ramp = L.foliage2 })

---------------------------------------------------------------- road's end: the striped canvas fly on bamboo poles
F.depth(2)
F.tree(292, 128, 50, 5)
do
  local cx, yb = 240, 128
  local roofm = poly{ { cx - 44, yb - 19 }, { cx - 16, yb - 48 }, { cx, yb - 36 }, { cx + 16, yb - 48 }, { cx + 44, yb - 19 } }
  local inside = rect(cx - 36, yb - 19, cx + 36, yb)
  local poles = rect(cx - 17, yb - 56, cx - 16, yb - 48):add(rect(cx + 16, yb - 56, cx + 17, yb - 48))
  for _, x in ipairs({ cx - 37, cx - 13, cx + 12, cx + 35 }) do poles:add(rect(x, yb - 19, x + 1, yb)) end
  F.shadow(cx - 36, cx + 36, yb, 10, 3)
  rimOf(union(roofm, inside, poles), L.timber)
  -- the shaded inside: a mat floor, a long table, a mosquito net, lamp glow
  inside:each(function(x, y)
    local d = math.sqrt(((x - cx) / 1.6) ^ 2 + (y - (yb - 10)) ^ 2)
    local h = d < 7 and G.base or (d < 12 and G.shade or (d < 18 and L.timber.base or L.timber.deep))
    if y >= yb - 3 then h = ((x + y) // 2) % 2 == 0 and rattan.shade or rattan.deep end
    px(x, y, h)
  end)
  local tbl = rect(cx - 24, yb - 7, cx + 24, yb - 6):add(rect(cx - 22, yb - 5, cx - 21, yb - 1)):add(rect(cx + 21, yb - 5, cx + 22, yb - 1))
  part(tbl, L.bamboo, { nopop = true, noshade = true }) hline(cx - 24, cx + 24, yb - 6, L.bamboo.deep)
  for _, p in ipairs({ { cx - 18, clay }, { cx - 6, L.produce }, { cx + 8, clay }, { cx + 18, L.leaf } }) do
    fill(rect(p[1] - 1, yb - 9, p[1] + 1, yb - 8), p[2].base) px(p[1] - 1, yb - 9, p[2].hi)
  end
  -- two gnomes at the table, backs lit by the lamp
  for _, g in ipairs({ { cx - 11, L.awnA }, { cx + 15, L.gold } }) do
    local hat = poly{ { g[1] - 3, yb - 9 }, { g[1] + 3, yb - 9 }, { g[1] + 1, yb - 15 } }
    rimOf(hat, L.timber) fill(hat, g[2].base) px(g[1], yb - 12, g[2].hi)
    fill(rect(g[1] - 3, yb - 8, g[1] + 3, yb - 4), L.awnB.base) px(g[1] - 2, yb - 8, L.awnB.hi)
  end
  -- a mosquito net bunched under the left peak
  local net = poly{ { cx - 33, yb - 1 }, { cx - 27, yb - 18 }, { cx - 21, yb - 1 } }
  net:each(function(x, y) if (x + y) % 2 == 0 then px(x, y, L.awnB.shade) elseif (x - y) % 4 == 0 then px(x, y, L.awnB.base) end end)
  vline(cx - 27, yb - 18, yb - 2, L.awnB.hi)
  -- teal-and-cream striped canvas following each peak
  roofm:each(function(x, y)
    local pk = x < cx and cx - 16 or cx + 16
    local u = (x - pk) / (y - (yb - 50))
    local k = floor(u * 5 + 20)
    local h = (k % 2 == 0) and L.teal.base or L.awnB.hi
    if (u * 5 + 20) % 1 < .14 then h = (k % 2 == 0) and L.teal.shade or L.awnB.shade end
    if x > pk + 6 and (x - pk) / 26 + (y - (yb - 48)) / 30 > .9 then h = (k % 2 == 0) and L.teal.shade or L.awnB.base end
    if x < pk - 2 and (pk - x) / 10 + (y - (yb - 48)) / 12 < 1.1 then h = (k % 2 == 0) and L.teal.hi or L.awnB.hi end
    -- damp stain along the lower edge
    if y >= yb - 21 and hash(x, y, 80) < .5 then h = (k % 2 == 0) and L.teal.deep or L.awnB.shade end
    px(x, y, h)
  end)
  -- palm fronds thrown over the canvas against the rain
  F.fronds(cx - 22, yb - 44, 5, 12, L.roof2, 71, "palm")
  F.fronds(cx + 20, yb - 43, 4, 11, L.roof, 72, "palm")
  F.vines(rect(cx - 44, yb - 21, cx - 30, yb - 19), .25, 73, 9)
  part(poles, L.bamboo, { nopop = true, noshade = true })
  poles:each(function(x, y) if y % 6 == 0 then px(x, y, L.bamboo.deep) end end)
  -- a lamp hanging over the table
  vline(cx, yb - 19, yb - 15, L.timber.edge)
  local lamp = rect(cx - 1, yb - 14, cx + 1, yb - 11) fill(lamp, G.hi) hline(cx - 2, cx + 2, yb - 15, L.timber.base)
  -- scalloped red valance
  for x = cx - 42, cx + 40, 6 do fill(poly{ { x, yb - 19 }, { x + 6, yb - 19 }, { x + 3, yb - 15 } }, L.awnA.base) px(x + 3, yb - 16, L.awnA.shade) px(x + 1, yb - 19, L.awnA.hi) end
  hline(cx - 44, cx + 44, yb - 19, L.awnA.deep)
  -- pennants on the peaks
  for _, p in ipairs({ { cx - 16, L.awnA }, { cx + 17, L.gold } }) do fill(poly{ { p[1] + 1, yb - 56 }, { p[1] + 10, yb - 54 }, { p[1] + 1, yb - 51 } }, p[2].base) px(p[1] + 2, yb - 55, p[2].hi) px(p[1] + 8, yb - 54, p[2].shade) end
  for _, g in ipairs({ { cx - 44, cx - 52 }, { cx + 44, cx + 52 } }) do line({ { g[1], yb - 19 }, { g[2], yb + 1 } }):each(function(x, y) px(x, y, L.needle.deep) end) end
  -- a clay chimney pipe through the canvas and its cook smoke
  local ch = rect(cx + 25, yb - 40, cx + 28, yb - 30)
  rimOf(ch, clay) part(ch, clay, { nopop = true }) hline(cx + 24, cx + 29, yb - 41, clay.deep) px(cx + 25, yb - 40, clay.hi)
  F.smoke(cx + 26, yb - 44, 5, .6, 2)
  -- coconut husks heaped by the corner pole
  for k = 0, 2 do coconut(cx + 40 + k * 4, yb - 2) end
  coconut(cx + 42, yb - 5, true) coconut(cx + 46, yb - 5)
end

---------------------------------------------------------------- back left: a palm-leaf A-frame and a hammock between two trees
local function aFrame(x, yb, w, h)
  local front = poly{ { x - w, yb }, { x, yb - h }, { x + w, yb } }
  local side = poly{ { x, yb - h }, { x + w + 18, yb - h + 4 }, { x + w + 22, yb - 2 }, { x + w, yb } }
  local door = poly{ { x - w // 3, yb }, { x, yb - h * 2 // 3 }, { x + w // 3, yb } }
  F.shadow(x - w, x + w + 22, yb, 10, 3)
  rimOf(union(front, side), L.roof2)
  part(side, L.roof2, { noshade = true })
  F.palmThatch(side, L.roof2, yb - h, x - 100, 74)
  part(front, L.roof, { sep = true })
  F.palmThatch(front, L.roof, yb - h, x, 75)
  fill(door, L.timber.deep) fill(poly{ { x - 1, yb }, { x, yb - h * 2 // 3 }, { x + w // 3, yb } }, L.soil.deep)
  fill(poly{ { x, yb - h * 2 // 3 }, { x - w // 3 - 4, yb - 2 }, { x - w // 3, yb } }, rattan.base) -- a mat rolled up as the flap
  -- ragged leaf tips along the eave
  for xx = x + w, x + w + 22 do local l = 1 + floor(hash(xx, yb, 76) * 2) for k = 1, l do px(xx, yb - 2 + k, k == l and L.roof2.edge or L.roof2.deep) end end
  px(x, yb - h - 1, L.bamboo.hi) px(x, yb - h - 2, L.bamboo.base)
  line({ { x - w - 4, yb + 1 }, { x - w + 2, yb - 4 } }):each(function(xx, y) px(xx, y, L.bamboo.shade) end)
end
F.depth(1)
F.tree(84, 140, 46, 13)
aFrame(36, 146, 14, 18)
hammock(12, 118, 80, 118, 9, { L.awnA, L.gold, L.awnB }, { ends = 7 })
F.fern(64, 150, 4) F.fern(18, 150, 4, L.mossGround)
F.depth(2)
do -- a mossy fallen log with bracket fungi
  local fl = c:rrect(98, 151, 138, 156, 2)
  F.shadow(100, 138, 157, 5, 2)
  rimOf(fl, L.timber) part(fl, L.timber, { nopop = true }) F.logs(fl, L.timber, 151, 6) F.moss(fl, .45, 26)
  F.logEnd(137, 153, 2, L.redbark)
  bracket(104, 152, 4) bracket(116, 153, 3) bracket(126, 151, 4)
  F.fern(94, 158, 4) F.fern(144, 158, 3) F.orchid(110, 150, L.orchid, 2)
end

---------------------------------------------------------------- washing line from a canopy tree to a palm, and a thieving monkey
F.palm(184, 140, 46, 6, { lean = -2 })
local function sagY(x) local t = (x - 88) / (182 - 88) return floor(108 + 8 * sin(t * pi)) end
for x = 88, 182 do px(x, sagY(x), L.needle.deep) end
for i, it in ipairs({ { 98, L.awnA, "sock" }, { 112, batik, "sarong" }, { 132, L.gold, "sock" }, { 146, L.orchid, "sarong" } }) do
  local x = it[1] local y = sagY(x) + 1 local r = it[2]
  local m
  if it[3] == "sock" then m = rect(x, y, x + 3, y + 8):add(rect(x, y + 6, x + 6, y + 9))
  else m = rect(x - 2, y, x + 9, y + 14) end
  rimOf(m, r) part(m, r, { nopop = true })
  hline(x, x + 3, y, r.hi) px(x + 1, y - 1, L.timber.base)
  if it[3] == "sock" then hline(x, x + 3, y + 2, L.awnB.hi) end
  if it[3] == "sarong" then -- batik dots and a border
    m:each(function(xx, yy) if (xx + yy * 3) % 5 == 0 and yy > y + 1 then px(xx, yy, r == batik and L.awnB.hi or L.gold.hi) end end)
    hline(x - 2, x + 9, y + 12, r.deep) hline(x - 2, x + 9, y + 13, r == batik and L.gold.base or L.teal.base)
  end
end
-- a spider monkey hanging from the line by its tail, a stolen sock in its fist
F.sprite({
  "..tt......",
  ".t..t.....",
  ".t...tMM..",
  "..t..MMMM.",
  "....MfffM.",
  "....fefef.",
  "....ffnff.",
  "....MMMM..",
  "...MMMMMMa",
  "..aMmMMM..",
  ".aa.MMMM..",
  ".....M.M..",
  ".....M.M..",
  "....aa.aa.",
}, 158, sagY(160) - 1, { t = L.timber.shade, M = L.timber.base, m = L.timber.shade, f = L.skin.base, e = L.timber.edge, n = L.skin.deep, a = L.timber.deep })
local sk = rect(165, 122, 168, 128):add(rect(165, 127, 170, 129))
rimOf(sk, L.lav) part(sk, L.lav, { nopop = true }) hline(165, 168, 124, L.awnB.hi)
-- a gnome pegging a sarong on the line
F.gnome(140, 134, { small = true, hat = L.produce, coat = L.leaf, arm = "up" })

---------------------------------------------------------------- right: the round palm-thatch hut on a bamboo deck, a hammock inside
F.depth(3)
local function roundHut(cx, yb)
  local cone = poly{ { cx - 56, yb - 24 }, { cx - 46, yb - 34 }, { cx - 32, yb - 46 }, { cx - 16, yb - 56 }, { cx, yb - 62 }, { cx + 16, yb - 56 }, { cx + 32, yb - 46 }, { cx + 46, yb - 34 }, { cx + 56, yb - 24 } }
  local inside = rect(cx - 46, yb - 24, cx + 46, yb - 7)
  local deck = rect(cx - 50, yb - 7, cx + 50, yb - 3)
  local legs = HP.mask()
  for _, x in ipairs({ cx - 48, cx - 24, cx, cx + 24, cx + 47 }) do legs:add(rect(x, yb - 3, x + 1, yb)) end
  local posts = HP.mask()
  for _, x in ipairs({ cx - 47, cx - 24, cx + 23, cx + 45 }) do posts:add(rect(x, yb - 24, x + 2, yb - 7)) end
  local finial = rect(cx - 1, yb - 74, cx, yb - 62)
  F.shadow(cx - 48, cx + 50, yb, 16, 5)
  rimOf(union(cone, inside, deck, legs, finial), L.timber)
  -- the back wall: a woven mat warmed by the lantern
  local lx, ly = cx + 33, yb - 16
  inside:each(function(x, y)
    local d = math.sqrt((x - lx) ^ 2 + ((y - ly) * 1.4) ^ 2)
    local r = d < 10 and G or (d < 22 and rattan or L.timber)
    local a, b = (x // 2) % 2, (y // 2) % 2
    local h = a == b and r.base or r.shade
    if r == L.timber then h = a == b and L.timber.shade or L.timber.deep end
    if d < 5 then h = G.hi end
    px(x, y, h)
  end)
  -- the shadow under the eave
  hline(cx - 46, cx + 46, yb - 23, L.timber.edge)
  inside:each(function(x, y) if y == yb - 22 and x % 2 == 0 then px(x, y, L.timber.edge) end end)
  -- gear: a gourd and a basket on the deck, a bow of bananas hung on the back wall
  local gourd = c:ellipse(cx + 12, yb - 11, 3, 3):add(rect(cx + 12, yb - 16, cx + 12, yb - 14))
  rimOf(gourd, papayaR) part(gourd, L.gold, { nopop = true })
  local bk = c:rrect(cx - 8, yb - 14, cx + 2, yb - 8, 2) rimOf(bk, rattan) weave(bk, rattan, 1)
  for k = 0, 2 do local y = yb - 21 + k * 2 hline(cx + 4, cx + 8 - k, y, L.gold.hi) hline(cx + 4, cx + 8 - k, y + 1, L.gold.shade) end
  vline(cx + 6, yb - 23, yb - 22, L.vine.shade)
  -- the deck: horizontal bamboo poles on stilts
  part(deck, L.bamboo) F.bambooWall(deck, L.bamboo, 2, true, 44)
  part(legs, L.bamboo, { nopop = true, noshade = true })
  part(posts, L.bamboo, { nopop = true, noshade = true })
  posts:each(function(x, y) if y % 6 == 0 then px(x, y, L.bamboo.deep) end end)
  -- the cone: palm thatch in courses, a darker shaded right flank, a ragged fringe
  part(cone, L.roof, { sep = true })
  F.palmThatch(cone, L.roof, yb - 62, cx, 45)
  cone:each(function(x, y)
    local v = c:get(x, y)
    if x > cx + 14 and (x - cx) / 56 + (y - (yb - 62)) / 44 > .95 then
      if v == L.roof.hi or v == L.roof.base then px(x, y, L.roof.shade) elseif v == L.roof2.hi or v == L.roof2.base then px(x, y, L.roof2.shade) end
    end
  end)
  cone:each(function(x, y) if x < cx - 6 and (cx - x) / 30 + (y - (yb - 62)) / 22 < 1.0 and hash(x, y, 47) < .25 then px(x, y, L.roof.hi) end end)
  line({ { cx - 54, yb - 25 }, { cx - 45, yb - 34 }, { cx - 31, yb - 46 }, { cx - 15, yb - 56 }, { cx - 1, yb - 61 } }):each(function(x, y) if cone:has(x, y) then px(x, y, L.roof.hi) end end)
  for x = cx - 57, cx + 57 do
    local len = 1 + floor(hash(x, yb, 48) * 4)
    for k = 1, len do px(x, yb - 24 + k, k == len and L.roof.edge or (k == 1 and L.roof.deep or L.roof.shade)) end
  end
  -- binding rings of rattan round the top and the bamboo finial with a red pennant
  for _, y in ipairs({ yb - 56, yb - 52 }) do cone:each(function(x, yy) if yy == y then px(x, yy, rattan.shade) end end) end
  part(finial, L.bamboo, { nopop = true, noshade = true })
  local fl = poly{ { cx + 1, yb - 74 }, { cx + 12, yb - 71 }, { cx + 1, yb - 68 } } fill(fl, L.awnA.base) px(cx + 2, yb - 73, L.awnA.hi) px(cx + 9, yb - 71, L.awnA.shade)
  F.vines(rect(cx - 54, yb - 22, cx - 20, yb - 20), .12, 49, 10)
  -- the lantern
  vline(lx, yb - 22, yb - 19, L.timber.edge)
  local lan = rect(lx - 2, yb - 18, lx + 2, yb - 13) rimOf(lan, L.timber) fill(lan, G.base) px(lx - 1, yb - 17, G.hi) vline(lx + 2, yb - 17, yb - 13, G.shade) hline(lx - 2, lx + 2, yb - 18, L.timber.base)
  -- the hammock and the gnome asleep in it: hat flopped over the edge, boots out of the far end
  local band, hy = hammock(cx - 46, yb - 21, cx + 23, yb - 21, 9, { L.awnA, L.gold, L.teal, L.awnB }, { ends = 6 })
  local mid = floor(hy(cx - 10))
  local body = c:rrect(cx - 22, mid - 6, cx + 2, mid - 2, 2)
  rimOf(body, L.timber) part(body, L.wall2, { nopop = true }) hline(cx - 20, cx, mid - 6, L.wall2.hi)
  local head = c:ellipse(cx - 26, mid - 6, 3, 3) rimOf(head, L.skin) part(head, L.skin, { nopop = true, noshade = true })
  local beard = poly{ { cx - 24, mid - 7 }, { cx - 18, mid - 6 }, { cx - 22, mid - 3 } } fill(beard, L.awnB.base) px(cx - 22, mid - 6, L.awnB.hi)
  hline(cx - 27, cx - 26, mid - 6, L.timber.edge) -- closed eye
  local hat = poly{ { cx - 30, mid - 9 }, { cx - 25, mid - 10 }, { cx - 34, mid - 1 }, { cx - 35, mid + 2 } }
  rimOf(hat, L.awnA) part(hat, L.awnA, { nopop = true })
  for _, b in ipairs({ { cx + 4, mid - 7 }, { cx + 4, mid - 4 } }) do fill(rect(b[1], b[2], b[1] + 2, b[2] + 1), L.timber.base) px(b[1] + 2, b[2], L.timber.hi) end
  -- the hammock in front of him
  band:each(function(x, y) if x > cx - 24 and x < cx + 4 and y < mid - 1 then end end)
  for x = cx - 22, cx + 2 do local y = floor(hy(x) + .5) - 1 local r = ({ L.awnA, L.gold, L.teal, L.awnB })[((x - (cx - 46)) // 3) % 4 + 1] px(x, y, r.hi) px(x, y + 1, r.base) end
  for k, z in ipairs({ { cx - 18, mid - 13 }, { cx - 13, mid - 17 } }) do
    local s = k == 1 and 2 or 3
    hline(z[1], z[1] + s, z[2], L.awnB.hi) hline(z[1], z[1] + s, z[2] + s, L.awnB.hi)
    for q = 1, s - 1 do px(z[1] + s - q, z[2] + q, L.awnB.hi) end
  end
  -- guy ropes and pegs
  for _, g in ipairs({ { cx - 56, yb - 24, cx - 66, yb + 2 }, { cx + 56, yb - 24, cx + 66, yb + 2 } }) do
    line({ { g[1], g[2] }, { g[3], g[4] } }):each(function(x, y) px(x, y, L.needle.deep) end)
    fill(rect(g[3] - 1, g[4] - 2, g[3], g[4] + 1), L.bamboo.shade) px(g[3] - 1, g[4] - 2, L.bamboo.hi)
  end
end
roundHut(350, 196)
for _, f in ipairs({ { 300, 198, 5 }, { 308, 200, 4 }, { 398, 198, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.heliconia(292, 200, 16, 51)
F.orchid(392, 194, L.petal, 2, true)

---------------------------------------------------------------- back right: a dugout canoe on bamboo trestles
local function canoe(x0, yb)
  local hull = poly{ { x0 - 6, yb - 22 }, { x0 + 2, yb - 18 }, { x0 + 56, yb - 18 }, { x0 + 64, yb - 23 }, { x0 + 58, yb - 12 }, { x0 + 2, yb - 12 } }
  local inner = poly{ { x0 + 2, yb - 18 }, { x0 + 56, yb - 18 }, { x0 + 54, yb - 16 }, { x0 + 4, yb - 16 } }
  local tr = HP.mask()
  for _, tx in ipairs({ x0 + 10, x0 + 46 }) do
    tr:add(line({ { tx - 5, yb }, { tx + 3, yb - 16 } })):add(line({ { tx + 5, yb }, { tx - 3, yb - 16 } }))
  end
  F.shadow(x0 - 4, x0 + 62, yb, 10, 3)
  rimOf(union(hull, tr), L.timber)
  tr:each(function(x, y) px(x, y, y % 5 == 0 and L.bamboo.deep or L.bamboo.base) end)
  part(hull, L.redbark)
  hull:each(function(x, y) if (x * 2 + y) % 11 == 0 then px(x, y, L.redbark.shade) end end)
  hline(x0 + 2, x0 + 56, yb - 14, L.awnB.base) hline(x0 + 2, x0 + 56, yb - 13, L.awnA.base) -- painted band
  for x = x0 + 6, x0 + 52, 8 do px(x, yb - 14, L.awnA.shade) px(x + 1, yb - 13, L.gold.base) end
  fill(inner, L.redbark.deep) hline(x0 + 4, x0 + 54, yb - 18, L.redbark.hi)
  F.shine(hull, .08, 52)
  -- paddles leaning on it and a woven fish trap
  for _, p in ipairs({ { x0 + 20, x0 + 26 }, { x0 + 32, x0 + 36 } }) do
    local sh = line({ { p[1], yb - 30 }, { p[2], yb - 2 } }) c:rim(sh, L.timber.edge) sh:each(function(x, y) px(x, y, L.board.base) end)
    local bl = c:ellipse(p[2], yb - 4, 2, 4) rimOf(bl, L.timber) part(bl, L.board, { nopop = true }) px(p[2] - 1, yb - 6, L.board.hi)
  end
  local trap = poly{ { x0 + 60, yb }, { x0 + 72, yb - 3 }, { x0 + 72, yb - 9 }, { x0 + 60, yb - 10 } }:add(c:ellipse(x0 + 60, yb - 5, 3, 5))
  rimOf(trap, rattan) part(trap, rattan, { nopop = true })
  trap:each(function(x, y) if (x - x0) % 3 == 0 then px(x, y, rattan.shade) elseif y % 3 == 0 then px(x, y, rattan.hi) end end)
  fill(c:ellipse(x0 + 59, yb - 5, 1, 3), rattan.deep)
end
F.depth(2)
canoe(398, 152)
F.tree(470, 150, 46, 1)
F.depth(3)

---------------------------------------------------------------- left: firewood between bamboo stakes under a palm-frond lid
local function woodStack(x0, x1, yb)
  local stakes = rect(x0 - 2, yb - 22, x0, yb):add(rect(x1, yb - 22, x1 + 2, yb))
  local stack = rect(x0 + 1, yb - 18, x1 - 1, yb)
  F.shadow(x0, x1 + 2, yb, 8, 3)
  rimOf(union(stakes, stack), L.timber)
  part(stakes, L.bamboo, { nopop = true, noshade = true })
  stakes:each(function(x, y) if y % 6 == 0 then px(x, y, L.bamboo.deep) end end)
  fill(stack, L.timber.edge)
  for row = 0, 3 do for k = 0, (x1 - x0) // 6 do
    local x, y = x0 + 3 + k * 6 + (row % 2) * 3, yb - 3 - row * 5
    if x < x1 - 1 then F.logEnd(x, y, 2, (hash(k, row, 90) < .35) and L.redbark or L.timber) end
  end end
  F.moss(stack:copy():clip(rect(x0, yb - 2, x1, yb)), .4, 92)
  -- a lid of palm fronds laid over the stack
  local lid = poly{ { x0 - 5, yb - 21 }, { x0 + 4, yb - 26 }, { x1 - 4, yb - 26 }, { x1 + 5, yb - 21 }, { x1 + 5, yb - 20 }, { x0 - 5, yb - 20 } }
  rimOf(lid, L.roof2) part(lid, L.roof2, { nopop = true })
  F.palmThatch(lid, L.roof2, yb - 26, x1 - 8, 93)
  for x = x0 - 5, x1 + 5 do if hash(x, yb, 94) < .55 then px(x, yb - 19, L.roof2.shade) if hash(x, yb, 95) < .4 then px(x, yb - 18, L.roof2.deep) end end end
end
woodStack(22, 72, 196)
-- an agouti sitting up at the woodpile with a nut
F.sprite({
  "..ee.....",
  ".eAAAA...",
  "AAkAAAAA.",
  "nAAAAAAAa",
  ".aaoAAAAa",
  "...AAAAAa",
  "...aAAaa.",
  "...a..a..",
}, 75, 188, { e = coati.deep, A = coati.base, a = coati.shade, k = L.timber.edge, n = L.timber.edge, o = L.soil.hi })
px(77, 189, coati.hi) px(78, 189, coati.hi)
F.fern(20, 206, 6) F.fern(28, 204, 5, L.mossGround) F.fern(84, 204, 4)
F.bamboo(12, 200, 40, 3, 61)

---------------------------------------------------------------- the campfire (hero) with bamboo tripod, clay pot, bamboo rice tubes, log seats
local function campfire(cx, cy)
  local function seat(x0, x1, y, bark)
    bark = bark or L.timber
    local m = c:rrect(x0, y - 4, x1, y + 4, 4)
    F.shadow(x0, x1, y + 6, 4, 2)
    rimOf(m, bark) part(m, bark, { nopop = true })
    F.logs(m, bark, y - 4, 9)
    hline(x0 + 4, x1 - 4, y - 3, bark.hi)
    m:each(function(x, yy) if (x * 3 + yy) % 13 == 0 then px(x, yy, bark.deep) end end)
    F.moss(m, .22, x0 + 1)
    F.shine(m, .05, x0 + 2)
    F.logEnd(x1 - 3, y, 4, bark)
  end
  seat(cx - 34, cx + 38, cy - 24)
  bracket(cx - 28, cy - 22, 3) bracket(cx + 18, cy - 23, 4)
  local pit = c:ellipse(cx, cy, 17, 5)
  fill(pit, L.soil.deep)
  pit:each(function(x, y) if hash(x, y, 8) < .3 then px(x, y, L.road.shade) end end)
  for k = 0, 13 do
    local a = k / 14 * 2 * pi
    local x, y = floor(cx + cos(a) * 21), floor(cy + sin(a) * 7)
    local st = c:rrect(x - 4, y - 3, x + 3, y + 2, 2)
    rimOf(st, L.stone) part(st, L.stone, { nopop = k % 3 ~= 0 })
    if sin(a) > -.2 then F.moss(st, .3, 92 + k) end
    F.shine(st, .2, 110 + k)
  end
  local logs = line({ { cx - 12, cy + 2 }, { cx + 10, cy - 4 } }, 3):add(line({ { cx - 10, cy - 4 }, { cx + 12, cy + 2 } }, 3))
  rimOf(logs, L.timber) part(logs, L.timber, { nopop = true })
  logs:each(function(x, y) if hash(x, y, 93) < .25 then px(x, y, G.deep) end end)
  pit:each(function(x, y) if hash(x, y, 9) < .25 and not logs:has(x, y) then px(x, y, G.deep) end end)
  -- banana-leaf parcels roasting in the embers
  for _, p in ipairs({ { cx - 14, cy + 1 }, { cx + 9, cy + 3 } }) do
    local m = rect(p[1], p[2] - 1, p[1] + 4, p[2] + 1) rimOf(m, L.leaf) fill(m, L.leaf.shade) hline(p[1], p[1] + 4, p[2] - 1, L.leaf.base) vline(p[1] + 2, p[2] - 1, p[2] + 1, rattan.base)
  end
  -- three green bamboo tubes of rice leaning into the fire, leaf-plugged, steaming
  for k = 0, 2 do
    local bx = cx + 12 + k * 4
    local t = line({ { bx - 6, cy + 1 }, { bx + 2, cy - 18 + k * 2 } }, 2)
    rimOf(t, L.bamboo) part(t, L.bamboo, { nopop = true })
    t:each(function(x, y) if (y + k) % 5 == 0 then px(x, y, L.bamboo.deep) end end)
    px(bx + 2, cy - 19 + k * 2, L.leaf.hi) px(bx + 3, cy - 20 + k * 2, L.leaf.base) px(bx + 1, cy - 20 + k * 2, L.leaf.shade)
  end
  for i = 0, 3 do px(cx + 15 + i * 2, cy - 24 - i * 2, L.cloud.top) end
  local fl = poly{ { cx - 12, cy }, { cx - 9, cy - 16 }, { cx - 5, cy - 9 }, { cx - 2, cy - 28 }, { cx + 2, cy - 12 }, { cx + 6, cy - 22 }, { cx + 9, cy - 8 }, { cx + 12, cy } }
  fill(fl, G.deep)
  fill(fl:shrink(1), G.shade)
  fill(poly{ { cx - 8, cy }, { cx - 3, cy - 20 }, { cx + 1, cy - 9 }, { cx + 5, cy - 15 }, { cx + 8, cy } }, G.base)
  fill(poly{ { cx - 4, cy }, { cx - 1, cy - 12 }, { cx + 3, cy } }, G.hi)
  for i = 0, 14 do px(cx - 14 + floor(hash(i, 1, 31) * 30), cy - 32 - floor(hash(i, 2, 31) * 24), i % 3 == 0 and G.base or G.hi) end
  -- a bamboo tripod lashed with rattan, the clay pot hung from it
  local tri = line({ { cx - 18, cy + 4 }, { cx, cy - 40 } }, 2):add(line({ { cx + 18, cy + 4 }, { cx, cy - 40 } }, 2)):add(line({ { cx + 4, cy - 2 }, { cx, cy - 40 } }, 1))
  rimOf(tri, L.timber) part(tri, L.bamboo, { nopop = true, noshade = true })
  tri:each(function(x, y) if y % 6 == 0 then px(x, y, L.bamboo.deep) end end)
  hline(cx - 2, cx + 2, cy - 38, rattan.base) hline(cx - 1, cx + 1, cy - 37, rattan.shade)
  vline(cx, cy - 37, cy - 32, L.needle.deep)
  local pot = c:ellipse(cx, cy - 24, 8, 6):add(rect(cx - 5, cy - 31, cx + 5, cy - 28))
  rimOf(pot, clay) part(pot, clay)
  pot:each(function(x, y) if y == cy - 24 or y == cy - 21 then px(x, y, clay.shade) end end)
  hline(cx - 6, cx + 6, cy - 31, clay.hi) hline(cx - 4, cx + 4, cy - 31, L.foliage.base) -- greens in the broth
  px(cx - 2, cy - 31, L.produce.base) px(cx + 2, cy - 31, papayaR.hi)
  for _, x in ipairs({ cx - 5, cx + 5 }) do px(x, cy - 30, clay.deep) end
  F.shine(pot, .12, 39)
  F.smoke(cx + 1, cy - 40, 8, .5, 2)
  -- warm light on the red earth
  local glowM = c:ellipse(cx, cy + 4, 42, 14):cut(c:ellipse(cx, cy, 25, 10))
  glowM:each(function(x, y) if hash(x, y, 33) < .3 and not F.roadM:has(x, y) then px(x, y, hash(x, y, 34) < .5 and L.gold.hi or L.litter.hi) end end)
  seat(cx - 46, cx - 22, cy + 4)
  seat(cx + 24, cx + 50, cy + 2, L.redbark)
  seat(cx - 16, cx + 18, cy + 20)
end
campfire(132, 214)
-- the ukulele player on the back seat
local _, lx, ly = F.gnome(104, 191, { hat = L.leaf, coat = L.awnA, arm = "hold", noShadow = true })
local uke = c:ellipse(lx + 2, ly, 3, 3):add(c:ellipse(lx + 5, ly - 1, 2, 2)):add(line({ { lx + 6, ly - 2 }, { lx + 12, ly - 6 } }, 1))
rimOf(uke, L.timber) part(uke, L.board, { nopop = true }) fill(c:ellipse(lx + 3, ly, 1, 1), L.timber.edge) px(lx + 12, ly - 7, L.timber.base) px(lx + 13, ly - 7, L.timber.base)
for _, n in ipairs({ { lx + 8, ly - 14 }, { lx + 13, ly - 18 } }) do vline(n[1] + 1, n[2] - 3, n[2], L.timber.edge) fill(rect(n[1], n[2], n[1] + 1, n[2] + 1), L.timber.edge) end
-- a gnome toasting plantain slices on a bamboo skewer
local _, mx, my = F.gnome(96, 210, { hat = L.awnA, coat = L.teal, arm = "out" })
fill(line({ { mx, my }, { mx + 11, my - 7 } }), L.bamboo.base)
for k = 0, 2 do local x, y = mx + 5 + k * 3, my - 3 - k * 2 fill(rect(x, y - 1, x + 1, y), L.gold.hi) px(x + 1, y, L.produce.base) end
-- a gnome with a coconut cup and a straw
local _, ux, uy = F.gnome(174, 208, { hat = L.gold, coat = L.lav, arm = "out", flip = true })
local cup = c:ellipse(ux - 1, uy - 1, 3, 3) rimOf(cup, L.soil) part(cup, L.soil, { nopop = true }) hline(ux - 3, ux + 1, uy - 3, L.awnB.hi)
line({ { ux, uy - 4 }, { ux + 2, uy - 8 } }):each(function(x, y) px(x, y, L.awnA.base) end)
px(ux - 3, uy - 5, L.orchid.base) px(ux - 4, uy - 5, L.orchid.hi) -- a flower tucked in the cup
-- a capybara asleep by the fire
local capy = F.rp("#d6b07e #ae8256 #86623e #5e4630 #3a2c20")
F.sprite({
  "..ee................",
  ".eHHe...hhhhhhh.....",
  "HHHHHH.hhCCCCCChh...",
  "CCkkCCCCCCCCCCCCCc..",
  "CCCCCCCCCCCCCCCCCCc.",
  "nCCCCCCCCCCCCCCCCCc.",
  "nnCCCcCCCCCCCCCCCcc.",
  ".ddd.ddddddddddddd..",
}, 150, 224, { e = capy.deep, H = capy.hi, h = capy.hi, C = capy.base, c = capy.shade, d = capy.deep, k = L.timber.edge, n = L.timber.edge })
for _, z in ipairs({ { 170, 219 }, { 174, 215 } }) do hline(z[1], z[1] + 2, z[2], L.awnB.hi) px(z[1] + 1, z[2] + 1, L.awnB.hi) hline(z[1], z[1] + 2, z[2] + 2, L.awnB.hi) end
stump(66, 216, 5, .4, 23)
for _, p in ipairs({ { 112, 230 }, { 84, 222 }, { 192, 236 } }) do coconut(p[1], p[2], p[1] == 84) end
F.puddle(186, 246, 6, 14)

---------------------------------------------------------------- camp table, bottom-left: bamboo on a banana-leaf cloth
local top = rect(24, 236, 76, 239)
local tbl = union(top, rect(27, 240, 30, 252), rect(70, 240, 73, 252))
F.shadow(26, 76, 252, 8, 3)
rimOf(tbl, L.timber) part(tbl, L.bamboo, { nopop = true })
F.bambooWall(top, L.bamboo, 2, true, 31)
for _, lg in ipairs({ rect(27, 240, 30, 252), rect(70, 240, 73, 252) }) do lg:each(function(x, y) px(x, y, x == lg:bbox() and L.bamboo.hi or (y % 5 == 0 and L.bamboo.deep or L.bamboo.base)) end) end
F.bigLeaf(30, 236, 40, 0, L.leaf, 32, 3, { torn = true })
local ket = c:ellipse(36, 230, 6, 5):add(rect(33, 224, 39, 226))
rimOf(ket, clay) part(ket, clay) hline(33, 39, 224, clay.hi) px(36, 230, clay.deep) hline(32, 40, 229, clay.shade) F.shine(ket, .12, 33)
-- papaya halves, bananas and a pineapple
for _, p in ipairs({ { 50, 233 }, { 57, 234 } }) do
  local m = c:ellipse(p[1], p[2], 3, 2) rimOf(m, papayaR) fill(m, papayaR.base) px(p[1] - 1, p[2] - 1, papayaR.hi)
  px(p[1], p[2], L.timber.edge) px(p[1] + 1, p[2], L.timber.edge)
end
for k = 0, 2 do hline(61, 66 - k, 231 + k, k == 0 and L.gold.hi or L.gold.base) px(67 - k, 231 + k, L.leaf.deep) end
local pine = c:ellipse(71, 231, 3, 4) rimOf(pine, L.gold) fill(pine, L.gold.base)
pine:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.gold.deep) elseif (x - y) % 3 == 0 then px(x, y, L.gold.hi) end end)
for d = -2, 2 do px(71 + d, 226 - (2 - math.abs(d)), L.leaf.base) end px(71, 224, L.leaf.hi) px(71, 225, L.leaf.shade)
-- under the table: a clay water jar and ferns
local jar = c:ellipse(44, 247, 5, 5):add(rect(42, 241, 46, 243)) rimOf(jar, clay) part(jar, clay) hline(42, 46, 241, clay.hi)
F.fern(20, 254, 7) F.fern(82, 252, 6, L.mossGround)
F.mushroom(14, 244, L.produce, true) F.mushroom(10, 246, L.produce)
F.heliconia(56, 262, 14, 34)

---------------------------------------------------------------- rolled pandan mats, rattan packs and the coati (right of the road)
local function matRoll(x, y, r)
  local m = c:rrect(x - 14, y - 5, x + 14, y + 5, 5)
  rimOf(m, rattan) weave(m, rattan, 2)
  m:each(function(xx, yy) if yy == y - 4 then px(xx, yy, rattan.hi) elseif yy >= y + 3 then px(xx, yy, rattan.shade) end end)
  for _, k in ipairs({ -8, 8 }) do vline(x + k, y - 5, y + 5, r.base) vline(x + k + 1, y - 5, y + 5, r.shade) end
  local e = c:ellipse(x + 12, y, 3, 5) fill(e, rattan.hi) c:ellipse(x + 12, y, 1, 3):edge():each(function(xx, yy) px(xx, yy, rattan.deep) end)
end
matRoll(300, 230, L.awnA) matRoll(312, 240, batik)
local function pack(x, yb, r)
  local m = c:rrect(x - 8, yb - 18, x + 8, yb, 4)
  local flap = c:rrect(x - 8, yb - 20, x + 8, yb - 12, 3)
  F.shadow(x - 6, x + 8, yb, 6, 2)
  rimOf(union(m, flap), rattan) weave(m, rattan, 2) part(flap, r, { sep = true })
  fill(rect(x - 1, yb - 13, x + 1, yb - 11), L.gold.base) px(x - 1, yb - 13, L.gold.hi)
  vline(x - 5, yb - 11, yb - 2, r.deep) vline(x + 5, yb - 11, yb - 2, r.deep)
  local gd = c:ellipse(x + 10, yb - 7, 3, 4):add(rect(x + 10, yb - 13, x + 10, yb - 11)) rimOf(gd, L.gold) part(gd, L.gold, { nopop = true })
end
pack(346, 258, L.leaf)
pack(330, 262, L.awnA)
-- quirk: a coati in a red gnome hat climbing out of the green pack, a sausage in its paws, ringed tail up over the rim
F.sprite({
  "..........rR......",
  "........RRRr......",
  ".......RRRRr......",
  "......RRRRRr......",
  ".....RRRRRRRr.....",
  "....hhhhhhhhhh....",
  "...eCCCCCCCCCCe...",
  "...CwwkCCCCkwwC...",
  "...CCwwCCCCwwCC...",
  "....CCCCwwCCCC....",
  ".....cCCwwCCc.....",
  "......cCwwCc......",
  ".......cwwc.......",
  ".......cwwc.......",
  ".......nnnn.......",
  "...ppsSSSSSSSpp...",
  "...pSSSSSSSSSSp...",
  "....cC......Cc....",
}, 328, 220, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, C = coati.base, c = coati.shade, e = coati.deep, w = L.awnB.hi,
  k = L.timber.edge, n = L.timber.edge, p = coati.deep, S = L.apple.shade, s = L.apple.hi })
px(339, 221, L.awnA.hi) px(337, 223, L.awnA.hi) px(335, 224, L.awnA.hi) px(339, 220, L.awnB.hi) px(340, 220, L.awnB.base) -- pompom tip
hline(333, 341, 237, L.apple.deep)
F.sprite({ "..c", ".cg", "cg.", "kk.", "gg.", "kk.", "gg.", "kk.", "gg.", "kk." }, 352, 229, { g = coati.base, k = coati.deep, c = coati.shade })
F.fern(364, 262, 7) F.fern(320, 268, 6, L.mossGround) F.fern(294, 258, 5)
F.orchid(300, 252, L.orchid, 2)
F.depth(0)
F.birds({ { 330, 40, 2, "#2e7a46" }, { 344, 48, 1, "#b03a36" }, { 120, 56, 2, "#2e7a46" }, { 132, 62, 1, "#2e7a46" } })
F.depth(3)

---------------------------------------------------------------- near right: a papaya tree, a stump with a machete, heliconia
F.depth(2)
papaya(456, 206, 50)
F.depth(3)
F.treeFern(436, 228, 22, 44)
local cs = stump(416, 224, 8, .35, 24)
local blade = poly{ { 411, 217 }, { 422, 206 }, { 425, 208 }, { 416, 218 } } c:rim(blade, IR.edge) fill(blade, IR.base)
blade:each(function(x, y) if not blade:has(x + 1, y) then px(x, y, IR.shade) end end)
local haft = line({ { 424, 206 }, { 429, 201 } }, 2) c:rim(haft, L.timber.edge) fill(haft, L.timber.base) px(424, 205, L.timber.hi) px(426, 203, L.timber.hi)
blade:each(function(x, y) if not blade:has(x - 1, y) then px(x, y, IR.hi) end end)
for _, s in ipairs({ { 404, 224 }, { 432, 228 } }) do coconut(s[1], s[2], true) end
F.heliconia(470, 226, 18, 53)
F.fern(462, 224, 6) F.fern(398, 226, 5, L.mossGround)
F.mushroom(452, 218, L.produce, true) F.mushroom(447, 220, L.produce)

---------------------------------------------------------------- by the road: bamboo lantern pole, sign
local lp = rect(286, 176, 287, 212) rimOf(lp, L.timber) part(lp, L.bamboo, { nopop = true, noshade = true })
lp:each(function(x, y) if y % 6 == 0 then px(x, y, L.bamboo.deep) end end)
F.moss(rect(286, 204, 287, 212), .5, 25)
fill(rect(281, 176, 287, 177), L.bamboo.base) vline(281, 178, 180, L.needle.deep)
local lan = rect(278, 181, 284, 188) rimOf(lan, L.timber) fill(lan, G.base) px(279, 182, G.hi) vline(284, 182, 188, G.shade) hline(278, 284, 181, rattan.base) hline(278, 284, 188, rattan.shade)
F.vine(287, 178, 14, 7, nil, L.orchid)
F.sign(212, 196, 20, 12, L.board)
-- pictogram: a hammock between two posts
vline(205, 199, 205, L.timber.deep) vline(219, 199, 205, L.timber.deep)
for x = 206, 218 do local t = (x - 205) / 14 px(x, 200 + floor(4 * 4 * t * (1 - t) * .9), L.awnA.base) end
F.fern(204, 214, 4) F.mushroom(220, 212, L.produce)
-- fallen leaves and petals
for i = 0, 40 do
  local x, y = 20 + floor(hash(i, 1, 55) * 440), 140 + floor(hash(i, 2, 55) * 120)
  if not (x > 376 and y > 226) and not F.roadM:has(x, y) then
    local r = (i % 3 == 0) and L.litter or (i % 3 == 1 and L.foliage or L.helic)
    px(x, y, r.base) px(x + 1, y, r.shade)
  end
end
-- blue morphos
F.hen(194, 178, L.produce, true) px(188, 178, L.awnB.hi) px(186, 177, L.awnB.hi)
for _, b in ipairs({ { 176, 160 }, { 270, 150 }, { 60, 176 } }) do
  F.sprite({ "BB.BB", "bBkBb", ".b.b." }, b[1], b[2], { B = "#5aa8f0", b = "#2c62b4", k = L.timber.edge }, { rim = false })
end
F.finish()
