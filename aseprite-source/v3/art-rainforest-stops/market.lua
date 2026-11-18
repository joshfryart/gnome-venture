-- market.lua : "Market hamlet" stop look, RAINFOREST (rainforest_canopy), 480x270 gate view.
-- Same composition and hotspots as the Maplewold market (here-gate/pilot-market.lua) and the forest market,
-- re-cast as a jungle market of bamboo stalls:
-- road's end: the Jungle Trail, a bamboo-bundle arch under a little palm-thatch roof hung with heliconia and orchids,
-- a lantern, a path running in under the canopy. Back left: two stilt huts with smoke. Back right: a bamboo notice
-- board under palm thatch (a toucan carved on the peak, banana-leaf notes) and the bamboo rest house with a hammock
-- on its porch, coconut drinks and a teapot. Left: the mossy wishing well under palm thatch on bamboo posts, and the
-- Spice Hut (open sacks of turmeric, chilli, cinnamon and cardamom, spice jars, potted orchids). Right hero: the fruit
-- stall: bamboo posts, palm-thatch roof, a woven orange-and-teal valance, baskets of mangoes, rambutans, dragon fruit
-- and limes, spice cones, banana hands and chilli strings hanging, a macaw on a perch, a gnome stallkeeper. Stacked
-- goods along the road. Bottom: the lotus pond with a bamboo jetty, the long table under a striped canopy (a fruit
-- platter on a banana leaf, a pineapple, coconut drinks), the raised bed of chilli plants and pineapple plants.
-- Quirks kept from Maplewold, in jungle dress: the teapot-hatted scarecrow, the barrow growing something too big
-- (a giant pineapple), the snail mailbox (a banded tree snail), and the haystack house as a calabash-gourd house.
-- Plus a sloth in a red gnome hat dozing on the stall roof, hugging the sign.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-rainforest-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "market", out = DIR, treeLineGap = { 204, 276 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local courses, shadow, window, door = F.courses, F.shadow, F.window, F.door
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs

-- local ramps for market goods
local mango = F.rp("#ffe680 #ffb43c #f07a2c #b84a2a #6e2a22")
local dragon = F.rp("#ffb8dc #f05aa6 #c23484 #861e60 #4e1240")
local pine = F.rp("#fae488 #e4b240 #b6802c #7c5424 #4a321c")      -- pineapple skin
local gourd = F.rp("#f4dc94 #dab060 #ac8040 #78562e #48321e")     -- calabash
local lime = F.rp("#e0f48a #a8d84a #74b030 #4c8028 #2c5220")
local cinna = F.rp("#d8925a #b0663a #86462c #5e3022 #3a1e18")     -- cinnamon / clay
local sloth = F.rp("#d8c4a0 #b09a78 #8a765a #645444 #3e342c")

---------------------------------------------------------------- local helpers
local function jar(x, yb, r, lidR) -- little spice jar 4 wide, 6 tall, cloth lid
  local m = rect(x, yb - 5, x + 3, yb)
  rimOf(m, L.timber)
  fill(m, r.base) vline(x, yb - 4, yb, r.hi) vline(x + 3, yb - 4, yb, r.shade) hline(x, x + 3, yb, r.deep)
  hline(x, x + 3, yb - 5, (lidR or L.awnB).base) px(x + 1, yb - 5, (lidR or L.awnB).hi)
  px(x + 1, yb - 3, L.shine)
  return m
end
local function basket(x0, x1, yb, h, r, kind, seed) -- woven rattan basket heaped with fruit
  local body = poly{ { x0, yb - h }, { x1, yb - h }, { x1 - 2, yb }, { x0 + 2, yb } }
  local mid = (x0 + x1) // 2
  local heap = poly{ { x0 + 1, yb - h }, { x0 + 3, yb - h - 4 }, { mid, yb - h - 7 }, { x1 - 3, yb - h - 4 }, { x1 - 1, yb - h } }
  rimOf(union(body, heap), L.timber)
  part(body, L.board, { nopop = true })
  body:each(function(x, y)
    local k = ((x + (y // 2) * 2) // 2 + y // 2) % 2
    if k == 0 then px(x, y, L.board.shade) end
    if (y - (yb - h)) % 3 == 0 then px(x, y, L.board.deep) end
  end)
  hline(x0, x1, yb - h, L.board.hi)
  part(heap, r, { nopop = true })
  heap:each(function(x, y)
    if kind == "round" then -- 3x3 round fruit: lit upper-left, dark gaps, a red blush
      local bx, by = (x + (y // 3) % 2 * 2) % 3, y % 3
      if bx == 0 and by == 0 then px(x, y, r.hi) elseif bx == 2 and by == 2 then px(x, y, r.deep) elseif bx == 2 or by == 2 then px(x, y, r.shade) end
      if bx == 1 and by == 1 and hash(x // 3, y // 3, seed) < .4 then px(x, y, L.apple.base) end
    elseif kind == "rambutan" then -- red hairy balls with green spines
      local bx, by = (x + (y // 2) % 2) % 2, y % 2
      if bx == 0 and by == 0 then px(x, y, r.hi) elseif bx == 1 and by == 1 then px(x, y, r.deep) end
      if hash(x, y, seed) < .14 then px(x, y, L.leaf.base) end
    elseif kind == "dragon" then -- pink scaled fruit with green-tipped bracts
      local v = hash(x // 3, y // 2, seed)
      if (x + y) % 4 == 0 then px(x, y, v < .5 and lime.base or lime.shade) elseif v < .25 then px(x, y, r.hi) elseif v > .8 then px(x, y, r.shade) end
    else
      local v = hash(x, y, seed) if v < .18 then px(x, y, r.hi) elseif v > .85 then px(x, y, r.deep) end
    end
  end)
  -- a few leaves tucked in
  px(x0 + 3, yb - h - 3, L.leaf.base) px(x0 + 4, yb - h - 4, L.leaf.hi) px(x1 - 4, yb - h - 2, L.leaf.shade) px(x1 - 5, yb - h - 3, L.leaf.base)
  return body
end
local function bananas(x, y) -- a hand of bananas hanging, 7 wide, 9 tall: finger pairs, green top, dark tips
  F.sprite({ "...s...", "..gsg..", ".YhsYh.", ".YhsYh.", "YhysYhy", "Yh.s.hy", "Yy.s.yy", ".y...y.", ".k...k." }, x, y,
    { s = L.vine.shade, g = lime.base, Y = L.gold.hi, h = L.gold.base, y = L.gold.shade, k = L.timber.deep })
end
local function chilli(x, y, n) -- a string of red chillies
  vline(x, y - 2, y, L.needle.deep)
  for k = 0, n - 1 do
    local yy = y + 1 + k * 2
    px(x - 1, yy, L.apple.hi) px(x, yy, L.apple.base) px(x + 1, yy, L.apple.shade) px(x, yy + 1, L.apple.deep)
  end
  px(x, y + 1 + n * 2, L.leaf.base)
end
local function lantern(x, y, cord) -- little hanging lantern, top at y
  if cord then vline(x, y - cord, y - 1, L.timber.edge) end
  local l = rect(x - 2, y + 1, x + 2, y + 6)
  local cap = rect(x - 2, y, x + 2, y)
  rimOf(union(l, cap), L.timber)
  fill(l, L.glow.base) px(x - 2, y + 1, L.glow.hi) px(x - 1, y + 1, L.glow.hi) vline(x + 2, y + 2, y + 6, L.glow.shade)
  hline(x - 2, x + 2, y, L.bamboo.base) hline(x - 1, x + 1, y + 6, L.timber.deep)
end
local function stripes(m, x0, w, rA, rB)
  m:each(function(x, y) px(x, y, ((x - x0) // w) % 2 == 0 and rA.base or rB.base) end)
  m:each(function(x, y) if not m:has(x, y + 1) then px(x, y, (((x - x0) // w) % 2 == 0 and rA or rB).shade) end end)
  m:each(function(x, y) if ((x - x0) % w) == 0 and m:has(x, y + 1) and ((x - x0) // w) % 2 == 0 then px(x, y, rA.hi) end end)
end
local function weave(m, x0, w, rA, rB) -- a woven batik band: stripes with a zig-zag in the light band
  stripes(m, x0, w, rA, rB)
  m:each(function(x, y) if ((x - x0) // w) % 2 == 1 and ((x + y) % 4 == 0) and m:has(x, y + 1) then px(x, y, rB.hi) end end)
end
local function bambooPosts(m, r) -- round culm posts: lit left, dark right, nodes
  r = r or L.bamboo
  rimOf(m, L.timber)
  part(m, r, { nopop = true, noshade = true })
  m:each(function(x, y)
    if not m:has(x - 1, y) then px(x, y, r.hi)
    elseif not m:has(x + 1, y) then px(x, y, r.shade) end
    if y % 9 == 0 then px(x, y, r.deep) elseif y % 9 == 1 and not m:has(x - 1, y) then px(x, y, L.shine) end
  end)
end
local function coconut(x, y, half)
  local m = c:ellipse(x, y, 2, 2)
  c:rim(m, L.soil.edge) fill(m, L.soil.base) px(x - 1, y - 1, L.soil.hi) px(x + 1, y + 1, L.soil.shade)
  if half then fill(rect(x - 1, y - 1, x + 1, y), L.awnB.hi) px(x, y, L.awnB.shade) end
end
local function coconutDrink(x, yb) -- green coconut with a straw and a hibiscus
  local m = c:ellipse(x, yb - 2, 3, 3)
  c:rim(m, L.vine.edge) fill(m, L.vine.base) px(x - 2, yb - 4, L.vine.hi) px(x - 1, yb - 4, L.vine.hi) px(x + 2, yb, L.vine.shade)
  hline(x - 1, x + 1, yb - 5, L.awnB.base)
  line({ { x + 1, yb - 5 }, { x + 3, yb - 9 } }):each(function(xx, yy) px(xx, yy, L.awnA.base) end)
  px(x - 2, yb - 5, L.apple.base) px(x - 3, yb - 5, L.apple.hi)
end
local function spiceSack(x, yb, r) -- open sack, rolled lip, a heaped cone of spice
  local body = c:rrect(x - 5, yb - 7, x + 5, yb, 3)
  local lip = rect(x - 6, yb - 8, x + 6, yb - 7)
  local heap = poly{ { x - 5, yb - 8 }, { x, yb - 13 }, { x + 5, yb - 8 } }
  rimOf(union(body, lip, heap), L.timber)
  part(body, L.awnB) body:each(function(xx, yy) if (xx + yy) % 3 == 0 and hash(xx, yy, 5) < .4 then px(xx, yy, L.awnB.shade) end end)
  fill(lip, L.awnB.hi) hline(x - 6, x + 6, yb - 7, L.awnB.shade)
  part(heap, r, { nopop = true })
  heap:each(function(xx, yy) if xx < x and hash(xx, yy, 7) < .5 then px(xx, yy, r.hi) elseif hash(xx, yy, 8) < .15 then px(xx, yy, r.deep) end end)
  px(x, yb - 13, r.hi)
end
local function spiceCone(x, yb, r, h) -- a sculpted cone of spice powder on a plate
  local m = poly{ { x - h // 2, yb - 1 }, { x, yb - h }, { x + h // 2, yb - 1 } }
  rimOf(m, r) part(m, r, { nopop = true })
  m:each(function(xx, yy) if xx < x then px(xx, yy, (yy % 2 == 0) and r.hi or r.base) elseif xx > x + 1 then px(xx, yy, r.shade) end end)
  hline(x - h // 2 - 1, x + h // 2 + 1, yb, L.awnB.base)
end

---------------------------------------------------------------- far quirks (plane 1): teapot scarecrow + giant pineapple barrow
F.depth(1)
F.tree(196, 118, 30, 1, true)
local function scarecrow()
  local t = L.timber
  local post = rect(108, 72, 109, 112):add(rect(100, 80, 117, 81))
  local shirt = poly{ { 103, 79 }, { 114, 79 }, { 116, 92 }, { 101, 92 } }
  local head = c:rrect(105, 70, 112, 78, 2)
  local hat = poly{ { 103, 66 }, { 114, 66 }, { 113, 70 }, { 104, 70 } }
  local spout = line({ { 114, 68 }, { 118, 65 } })
  local lid = rect(107, 63, 110, 65)
  rimOf(union(post, shirt, head, hat, spout, lid), t)
  part(post, L.bamboo, { nopop = true })
  part(shirt, L.accent)
  shirt:each(function(x, y) if (x + y) % 4 == 0 then px(x, y, L.helic.base) elseif (x - y) % 4 == 0 then px(x, y, L.accent.shade) end end) -- batik
  part(head, L.soil) px(107, 73, t.edge) px(110, 73, t.edge) hline(107, 110, 76, L.soil.deep) px(106, 71, L.soil.hi) -- coconut head
  part(hat, L.roof2) part(lid, L.roof2) fill(spout, L.roof2.shade)
  px(102, 69, L.roof2.deep) px(101, 68, L.roof2.deep)
  -- palm-fibre tufts at cuffs and hem
  for _, p in ipairs({ { 99, 82 }, { 118, 82 }, { 103, 93 }, { 108, 93 }, { 113, 93 } }) do px(p[1], p[2], L.roof.base) px(p[1], p[2] + 1, L.roof.shade) end
  -- a keel-billed toucan perched on the arm
  F.sprite({ ".kk...", "kWkOOg", "kkkOog", ".kk...", "..o..." }, 112, 75, { k = "#2e2a30", W = L.gold.hi, O = L.produce.base, o = L.timber.deep, g = lime.base })
end
scarecrow()
local function barrow()
  local t = L.timber
  local tray = poly{ { 160, 92 }, { 184, 92 }, { 180, 100 }, { 163, 100 } }
  local handles = line({ { 160, 94 }, { 152, 98 } }):add(line({ { 166, 100 }, { 164, 104 } }))
  local wheel = poly{ { 180, 98 }, { 186, 98 }, { 188, 101 }, { 186, 104 }, { 180, 104 }, { 178, 101 } }
  local fruit = c:ellipse(172, 74, 13, 18)
  fruit:clip(rect(150, 50, 196, 93))
  rimOf(union(tray, handles, wheel, fruit), t)
  part(handles, L.bamboo, { nopop = true }) part(tray, t) F.bambooWall(tray, L.board, 3, true, 5) part(wheel, L.stone, { nopop = true })
  part(fruit, pine)
  -- pineapple eyes: a diamond lattice, each eye lit top-left with a green-brown tip
  fruit:each(function(x, y)
    local a, b = (x + y) % 6, (x - y) % 6
    local lit = (x - 172) / 13 + (y - 74) / 18 < -.3
    local dark = (x - 172) / 13 + (y - 74) / 18 > .55
    if a == 0 or b == 0 then px(x, y, dark and pine.deep or pine.shade)
    elseif a == 3 and b == 3 then px(x, y, L.vine.shade)
    elseif a == 2 and b == 2 then px(x, y, lit and pine.hi or pine.base)
    elseif dark then px(x, y, pine.shade) end
  end)
  F.shine(fruit, .05, 7)
  -- the leafy crown: stiff spiky blades fanning up
  local blades = { { -10, -7 }, { -7, -13 }, { -3, -17 }, { 0, -19 }, { 3, -16 }, { 7, -13 }, { 11, -7 }, { -12, -2 }, { 13, -3 } }
  local cm = HP.mask()
  for _, b in ipairs(blades) do cm:add(line({ { 172, 57 }, { 172 + b[1], 57 + b[2] } }, 2)) end
  cm:add(c:ellipse(172, 57, 5, 2))
  rimOf(cm, lime)
  part(cm, L.foliage2, { nopop = true })
  for _, b in ipairs(blades) do line({ { 172, 56 }, { 172 + b[1], 56 + b[2] } }):each(function(x, y) px(x, y, b[1] <= 0 and L.foliage2.hi or L.foliage2.base) end) end
  -- moss in the barrow tray and a ladder propped against the fruit, a gnome-sized ladder
  hline(162, 182, 93, L.moss.base) hline(163, 181, 94, L.moss.shade)
  local lad = line({ { 186, 96 }, { 190, 70 } }):add(line({ { 189, 96 }, { 193, 70 } }))
  for y = 74, 94, 4 do local tt = (96 - y) / 26 lad:add(rect(floor(186 + 4 * tt), y, floor(189 + 4 * tt), y)) end
  rimOf(lad, L.timber) part(lad, L.bamboo, { nopop = true, noshade = true })
  F.mushroom(162, 92, L.helic)
end
barrow()

---------------------------------------------------------------- road's end: the Jungle Trail arch (plane 2)
F.depth(2)
F.tree(202, 128, 60, 1)
F.palm(282, 126, 56, 5, { lean = 7 })
local function trail()
  local opening = poly{ { 222, 124 }, { 222, 80 }, { 258, 80 }, { 258, 124 } }
  fill(opening, L.foliage2.edge)
  opening:each(function(x, y) if hash(x // 2, y, 31) < .3 then px(x, y, L.foliage2.deep) elseif hash(x, y // 2, 32) < .06 then px(x, y, L.foliage.deep) end end)
  -- the jungle inside: a misted gap, receding canopy trees and palms, the path running in
  fill(poly{ { 236, 104 }, { 244, 104 }, { 243, 92 }, { 237, 92 } }, L.mist)
  hline(237, 243, 104, L.mist2)
  F.conifer(229, 112, 22, L.farTree, 229, { far = true, slim = true })
  F.palm(252, 112, 24, 3, { far = true, lean = 3 })
  F.conifer(226, 121, 30, L.foliage2, 227, { slim = true })
  F.conifer(256, 122, 32, L.foliage, 255, { slim = true })
  fill(poly{ { 234, 124 }, { 246, 124 }, { 242, 104 }, { 238, 104 } }, L.road.shade)
  for i = 0, 3 do hline(239 - i, 241 + i, 108 + i * 5, L.road.deep) end
  px(239, 106, L.road.base) px(240, 111, L.road.base)
  -- bundled bamboo pillars on stone footings, a lintel of lashed poles, a little palm-thatch roof
  local pL, pR = rect(210, 76, 221, 116), rect(259, 76, 270, 116)
  local fL, fR = rect(208, 116, 223, 124), rect(257, 116, 272, 124)
  local lintel = rect(204, 72, 276, 79)
  local roof = poly{ { 198, 73 }, { 240, 52 }, { 282, 73 } }
  shadow(212, 270, 124, 8, 4)
  rimOf(union(pL, pR, fL, fR, lintel, roof), L.timber)
  part(pL, L.bamboo) part(pR, L.bamboo)
  F.bambooWall(union(pL, pR), L.bamboo, 3, false, 34)
  for _, y in ipairs({ 84, 106 }) do hline(210, 221, y, L.needle.shade) hline(259, 270, y, L.needle.shade) hline(210, 221, y + 1, L.needle.deep) hline(259, 270, y + 1, L.needle.deep) end
  part(fL, L.stone) part(fR, L.stone) courses(union(fL, fR), 116, 4, 5, L.stone) F.moss(union(fL, fR), .25, 35) F.shine(union(fL, fR), .1, 36)
  part(lintel, L.board) F.bambooWall(lintel, L.board, 4, true, 37)
  for _, x in ipairs({ 214, 266 }) do vline(x, 72, 79, L.needle.deep) vline(x + 1, 72, 79, L.needle.shade) end
  part(roof, L.roof, { sep = true }) F.palmThatch(roof, L.roof, 52, 240, 38)
  line({ { 199, 72 }, { 239, 53 } }):each(function(x, y) if roof:has(x, y) then px(x, y, L.roof.hi) end end)
  for x = 199, 281 do local len = 1 + floor(hash(x, 73, 39) * 3) for k = 1, len do if not lintel:has(x, 73 + k) then px(x, 73 + k, k == len and L.roof.edge or L.roof.deep) end end end
  -- a carved parrot finial on the peak
  F.sprite({ ".RR.", "RWeR", ".RRY", ".RB.", "..B." }, 238, 46, { R = L.apple.base, W = L.awnB.hi, e = L.timber.edge, Y = L.gold.base, B = "#4a8ad8" })
  -- hanging heliconia chains and orchid sprays at the corners, vines on the pillars
  F.heliconia(206, 92, 16, 51)
  for _, v in ipairs({ { 211, 80, 14 }, { 268, 80, 16 }, { 230, 80, 6 }, { 251, 80, 7 } }) do F.vine(v[1], v[2], v[3], v[1], nil, L.orchid) end
  F.orchid(258, 82, L.orchid, 2) F.orchid(222, 82, L.petal, 2, true)
  -- lantern hanging from the lintel, a red cloth tied on the right pillar, ferns at the feet
  vline(240, 80, 82, L.timber.edge)
  lantern(240, 83)
  local mk = rect(262, 96, 267, 101) rimOf(mk, L.awnA) part(mk, L.awnA) px(268, 102, L.awnA.base) px(268, 103, L.awnA.shade)
  for _, f in ipairs({ { 212, 125, 5 }, { 219, 126, 4 }, { 262, 125, 4 }, { 269, 126, 5 } }) do F.fern(f[1], f[2], f[3]) end
end
trail()

---------------------------------------------------------------- back left: two stilt huts (plane 1)
F.depth(1)
F.tree(86, 126, 42, 3)
F.palm(10, 128, 40, 9)
do
  local st = HP.mask()
  for _, sx in ipairs({ 20, 31, 43, 53, 64, 74 }) do st:add(rect(sx, 128, sx + 1, 136)) end
  rimOf(st, L.timber) part(st, L.bamboo, { nopop = true })
  local top, cx, wall = F.building{ x0 = 19, x1 = 45, yb = 128, wh = 26, rh = 22, wall = L.board, roof = L.roof, noFrame = true }
  F.bambooWall(wall:copy():clip(rect(19, top + 4, 45, 128)), L.board, 3, false, 40)
  window(24, 108, 30, 114, L.timber) door(34, 113, 41, 127, L.accent)
  local top2, cx2, wall2, roof2 = F.building{ x0 = 52, x1 = 75, yb = 128, wh = 34, rh = 24, wall = L.wall2, roof = L.roof2, noFrame = true }
  F.planks(wall2, L.wall2, 4, true, 36)
  part(union(rect(52, top2, 53, 128), rect(74, top2, 75, 128)), L.bamboo, { nopop = true, noshade = true })
  window(57, 100, 63, 106, L.timber) window(57, 114, 62, 119, L.timber)
  door(66, 112, 72, 127, L.timber)
  hline(18, 76, 129, L.timber.base) hline(18, 76, 130, L.timber.deep) -- the shared bamboo deck
  F.shadow(18, 76, 137, 6, 2)
  local pot = rect(47, 123, 50, 128) rimOf(pot, L.timber) part(pot, cinna, { nopop = true })
  F.orchid(46, 123, L.orchid, 1)
  F.washing(22, 131, 50, 132, { { "sock", L.awnA }, { "shirt", L.accent }, { "sock", L.gold } }, 1)
  F.smoke(66, 72, 6, .6, 2)
end

---------------------------------------------------------------- back right: notice board (plane 2)
F.depth(2)
F.tree(348, 134, 50, 0)
local function notice()
  local T = L.timber
  local roof = poly{ { 280, 61 }, { 313, 44 }, { 346, 61 }, { 346, 64 }, { 280, 64 } }
  local posts = rect(289, 64, 294, 136):add(rect(332, 64, 337, 136))
  local board = rect(287, 66, 339, 114)
  local bar = rect(286, 120, 340, 123)
  shadow(290, 338, 136, 10, 5)
  rimOf(union(roof, posts, board, bar), T)
  bambooPosts(posts)
  part(board, L.plaster, { band = 2 })
  board:each(function(x, y) px(x, y, (((x + y) // 2) % 2 == ((x - y) // 2) % 2) and L.plaster.base or L.plaster.shade) end)
  hline(287, 339, 66, L.bamboo.base) hline(287, 339, 114, L.bamboo.shade) vline(287, 66, 114, L.bamboo.hi) vline(339, 66, 114, L.bamboo.shade)
  part(bar, L.bamboo, { nopop = true }) hline(286, 340, 120, L.bamboo.hi)
  part(roof, L.roof, { sep = true }) F.palmThatch(roof, L.roof, 44, 313, 62)
  for x = 281, 345 do local len = 1 + floor(hash(x, 64, 63) * 2) for k = 1, len do if not board:has(x, 64 + k) then px(x, 64 + k, L.roof.deep) end end end
  -- the carved toucan on the peak
  F.sprite({ "..kkk....", ".kWWkOOO.", "kkWekOOoo", "kkkkkg...", ".kkkk....", "..kkk....", "..o.o...." }, 307, 33,
    { k = "#2e2a30", W = L.gold.hi, e = L.timber.edge, O = L.produce.base, o = L.timber.deep, g = lime.base })
  -- notes: paper slips and pinned banana-leaf notes
  local notes = { { 291, 69, 302, 82, L.awnB }, { 306, 70, 320, 80, lime }, { 324, 68, 335, 84, L.awnB },
                  { 292, 87, 305, 100, L.wall2 }, { 309, 85, 321, 104, L.leaf }, { 325, 89, 335, 99, L.gold },
                  { 296, 103, 306, 111, L.helic }, { 323, 102, 334, 111, L.awnB } }
  for _, n in ipairs(notes) do
    local m = rect(n[1], n[2], n[3], n[4])
    part(m, n[5], { nopop = true })
    c:edgeIn(m, n[5].deep)
    if n[5] == L.leaf or n[5] == lime then vline((n[1] + n[3]) // 2, n[2] + 1, n[4] - 1, n[5].hi)
      for y = n[2] + 2, n[4] - 2, 2 do px((n[1] + n[3]) // 2 - 2, y, n[5].shade) px((n[1] + n[3]) // 2 + 2, y + 1, n[5].shade) end
    else for y = n[2] + 3, n[4] - 2, 3 do hline(n[1] + 2, n[3] - 2 - (y % 4), y, n[5].shade) end end
    px((n[1] + n[3]) // 2, n[2] + 1, L.awnA.base)
  end
  -- a pinned map scrap with a route line, a pressed orchid, a pinned macaw feather
  line({ { 297, 90 }, { 300, 95 }, { 297, 98 } }):each(function(x, y) px(x, y, L.awnA.base) end)
  F.sprite({ "p.p", ".y.", "p.p" }, 327, 91, { p = L.orchid.base, y = L.gold.hi }, { rim = false })
  line({ { 327, 104 }, { 331, 109 } }):each(function(x, y) px(x, y, (x % 2 == 0) and L.apple.base or "#4a8ad8") end)
  -- lantern on the right post, a coconut-shell paste pot, a junglefowl at its foot
  hline(337, 340, 70, T.deep) vline(340, 70, 72, T.deep)
  lantern(340, 73)
  local b = c:ellipse(304, 132, 4, 3) rimOf(b, L.soil) part(b, L.soil, { nopop = true }) hline(301, 307, 130, L.awnB.base)
  vline(305, 122, 129, L.bamboo.hi)
  F.hen(318, 136, L.produce)
end
notice()

---------------------------------------------------------------- back right: the rest house (plane 2)
local function lodge()
  local top, cx, wall, roofM = F.building{ x0 = 360, x1 = 456, yb = 136, wh = 46, rh = 26, wall = L.board, roof = L.roof, noFrame = true }
  F.bambooWall(wall:copy():clip(rect(360, top + 4, 456, 136)), L.board, 4, false, 64)
  local gab = poly{ { 366, 89 }, { 408, 72 }, { 450, 89 } }:cut(rect(402, 76, 413, 86))
  gab:each(function(x, y) px(x, y, (((x + y) // 2) % 2 == ((x - y) // 2) % 2) and L.plaster.base or L.plaster.shade) end)
  F.smoke(447, 61, 5, .5, 2)
  -- palm-thatch porch roof on bamboo posts
  local porch = poly{ { 356, 103 }, { 460, 103 }, { 463, 111 }, { 353, 111 } }
  rimOf(porch, L.roof2) part(porch, L.roof2, { sep = true }) F.palmThatch(porch, L.roof2, 103, 9999, 65)
  hline(356, 460, 103, L.roof2.hi)
  for x = 353, 463 do if hash(x, 111, 66) < .5 then px(x, 112, L.roof2.deep) end end
  local pp = rect(361, 113, 362, 135):add(rect(454, 113, 455, 135))
  bambooPosts(pp)
  window(366, 94, 378, 100, L.timber) window(438, 94, 450, 100, L.timber)
  window(436, 116, 446, 121, L.timber)
  door(400, 113, 416, 135, L.wall2)
  local sign = rect(398, 85, 418, 91) rimOf(sign, L.timber) part(sign, L.board)
  F.sprite({ "..s..", ".sss.", "s.s.s", "..t.." }, 403, 86, { s = L.vine.shade, t = L.timber.shade }, { rim = false }) -- palm
  F.sprite({ ".b.b.", "bbbbb", ".bbb.", "..b.." }, 410, 86, { b = L.awnA.base }, { rim = false }) -- a heart: welcome
  lantern(421, 114)
  -- a woven hammock slung between the porch post and a hook, a gnome napping in it
  local ham = HP.mask()
  for x = 363, 397 do local t = (x - 363) / 34 local y = floor(118 + sin(t * pi) * 9 + .5) ham:add(rect(x, y - 2, x, y)) end
  rimOf(ham, L.timber)
  ham:each(function(x, y) px(x, y, (((x // 3) + (y // 2)) % 3 == 0) and L.helic.base or ((((x // 3) + (y // 2)) % 3 == 1) and L.accent.base or L.awnB.base)) end)
  ham:each(function(x, y) if not ham:has(x, y + 1) then px(x, y, L.awnB.shade) end end)
  for x = 363, 397, 3 do local t = (x - 363) / 34 px(x, floor(118 + sin(t * pi) * 9 + .5) + 1, L.awnB.base) end
  vline(397, 112, 116, L.timber.deep)
  F.sprite({ "...RR.", "..RRRr", ".ffffr", "BBBBB.", }, 374, 119, { R = L.awnA.base, r = L.awnA.deep, f = L.skin.base, B = L.awnB.base })
  -- tea table: teapot + coconut cups
  local tbl = rect(424, 127, 444, 129):add(rect(426, 130, 427, 135)):add(rect(441, 130, 442, 135))
  local pot = poly{ { 429, 120 }, { 438, 120 }, { 440, 126 }, { 427, 126 } }
  local lid = rect(432, 118, 435, 119)
  rimOf(union(tbl, pot, lid), L.timber)
  part(tbl, L.bamboo, { nopop = true }) part(pot, L.accent) part(lid, L.accent, { nopop = true })
  line({ { 440, 122 }, { 443, 119 } }):each(function(x, y) px(x, y, L.accent.deep) end)
  px(426, 122, L.accent.deep) px(425, 123, L.accent.deep)
  hline(429, 438, 123, L.awnB.base)
  coconut(443, 125, true)
  -- orchid window boxes under the top windows
  for _, x in ipairs({ 365, 437 }) do
    hline(x, x + 14, 103, L.timber.base)
    for i = 0, 14, 2 do px(x + i, 102, (i % 4 == 0) and L.orchid.base or L.fern.base) px(x + i + 1, 101, (i % 4 == 2) and L.orchid.hi or L.fern.hi) end
  end
  F.vines(rect(360, top - 1, 456, top + 2), .05, 67, 8)
end
lodge()

---------------------------------------------------------------- road side: snail mailbox, stacked goods, signpost (plane 2/3)
local function snail()
  local post = rect(208, 136, 209, 146)
  local shell = c:rrect(203, 123, 216, 135, 5)
  local foot = rect(198, 133, 220, 136):add(rect(198, 129, 201, 133))
  local stalks = rect(198, 125, 198, 128):add(rect(201, 125, 201, 128))
  rimOf(union(post, shell, foot, stalks), L.timber)
  part(post, L.bamboo, { nopop = true })
  part(foot, sloth, { nopop = true }) hline(198, 220, 133, sloth.hi)
  fill(stalks, sloth.shade) px(198, 125, L.timber.edge) px(201, 125, L.timber.edge)
  part(shell, gourd)
  -- a banded tree-snail shell: cream, a chocolate band, a teal band, a spiral
  shell:each(function(x, y)
    local d = math.sqrt((x - 210) ^ 2 + (y - 129) ^ 2)
    local band = floor(d) % 4
    if band == 0 then px(x, y, cinna.shade) elseif band == 1 and d > 3 then px(x, y, L.accent.base) end
  end)
  px(209, 128, L.awnB.hi) px(206, 125, gourd.hi) px(207, 125, gourd.hi)
  hline(204, 215, 134, L.awnB.base)
  fill(rect(217, 126, 219, 129), L.awnA.base) vline(217, 126, 133, L.timber.deep)
end
snail()
local function signpost()
  local post = rect(442, 152, 445, 176)
  local b1 = poly{ { 430, 155 }, { 434, 151 }, { 454, 151 }, { 458, 155 }, { 454, 159 }, { 434, 159 } }
  local b2 = poly{ { 432, 165 }, { 436, 162 }, { 452, 162 }, { 456, 165 }, { 452, 168 }, { 436, 168 } }
  rimOf(union(post, b1, b2), L.timber)
  bambooPosts(post)
  part(b1, L.board) part(b2, L.wall2)
  hline(436, 452, 155, L.board.deep) hline(438, 450, 165, L.wall2.shade)
  F.orchid(445, 170, L.orchid, 2)
  F.moss(post, .2, 65)
end
signpost()

F.depth(3)
-- stacked goods on the left verge: crates of mangoes, dragon fruit and limes, a rice sack, a clay honey jar
F.shadow(198, 222, 180, 8, 3)
F.crate(198, 180, 12, 9, mango)
F.crate(211, 180, 11, 9, dragon)
F.crate(203, 170, 12, 8, lime)
F.sack(222, 182, L.awnB, 4)
F.shadow(200, 214, 204, 6, 2)
do
  local urn = c:rrect(200, 193, 212, 204, 4):add(rect(203, 191, 209, 193))
  rimOf(urn, cinna) part(urn, cinna) hline(200, 212, 197, L.awnB.base) hline(200, 212, 198, cinna.deep)
  vline(202, 195, 202, cinna.hi) F.shine(urn, .1, 12)
  px(205, 190, L.gold.hi) px(206, 190, L.gold.base)
end
F.sack(216, 206, L.needle, 4)
coconut(222, 199) coconut(226, 200, true)
-- right verge by the notice board: bamboo pole bundles for sale and a basket of coconuts
F.shadow(258, 280, 146, 6, 2)
for k = 0, 2 do local m = c:ellipse(262 + k * 7, 142, 3, 3) rimOf(m, L.bamboo) fill(m, L.bamboo.base) px(261 + k * 7, 141, L.bamboo.hi) fill(c:ellipse(262 + k * 7, 142, 1, 1), L.soil.deep) end
for k = 0, 1 do local m = c:ellipse(265 + k * 7, 136, 3, 3) rimOf(m, L.bamboo) fill(m, L.bamboo.base) px(264 + k * 7, 135, L.bamboo.hi) fill(c:ellipse(265 + k * 7, 136, 1, 1), L.soil.deep) end
hline(260, 280, 139, L.awnA.base)
basket(276, 290, 150, 6, L.soil, "round", 13)

---------------------------------------------------------------- the calabash-gourd house (plane 3, replaces the haystack house)
local function gourdHouse()
  local bulb = c:ellipse(443, 208, 21, 16)
  local neck = c:ellipse(443, 186, 10, 9)
  local m = union(bulb, neck):clip(rect(418, 170, 468, 224))
  local stem = line({ { 443, 178 }, { 444, 172 }, { 448, 170 } }, 2)
  shadow(424, 464, 224, 8, 3)
  rimOf(union(m, stem), L.timber)
  part(m, gourd)
  -- vertical ribs, a lit upper-left, mottling
  m:each(function(x, y)
    local cxx = y < 194 and 10 or 21
    local u = (x - 443) / cxx
    if abs(u * 6 - floor(u * 6 + .5)) < .12 and abs(u) < .9 then px(x, y, gourd.shade) end
    if (x - 443) / 21 + (y - 200) / 16 < -.9 then px(x, y, gourd.hi) end
    if (x - 443) / 21 + (y - 208) / 16 > .8 then px(x, y, gourd.deep) end
    if hash(x // 2, y // 2, 66) < .06 then px(x, y, L.moss.base) end
  end)
  part(stem, L.vine, { nopop = true })
  F.bigLeaf(448, 170, 11, -pi * .15, L.leaf, 67, 4, { droop = .3 })
  -- a curly tendril and a little bamboo stovepipe
  for k = 0, 10 do px(436 - floor(sin(k * .8) * 2), 176 - floor(k * .5), L.vine.shade) end
  local pipe = rect(452, 176, 454, 186) rimOf(pipe, L.bamboo) part(pipe, L.bamboo, { nopop = true }) hline(451, 455, 176, L.bamboo.deep)
  F.smoke(453, 168, 3, .4, 1)
  door(436, 207, 446, 223, L.wall2, true)
  local w = c:ellipse(455, 200, 2, 2) rimOf(w, L.timber) fill(w, L.glow.base) px(454, 199, L.glow.hi)
  local w2 = c:ellipse(443, 189, 2, 2) rimOf(w2, L.timber) fill(w2, L.glow.base) px(442, 188, L.glow.hi)
  -- a bromeliad and orchid on the shoulder, fungi at the foot
  F.orchid(424, 202, L.orchid, 2, true)
  F.mushroom(462, 226, L.helic, true)
  for _, p in ipairs({ { 426, 222 }, { 460, 222 } }) do F.fern(p[1], p[2], 5) end
end
gourdHouse()

---------------------------------------------------------------- left: the wishing well (plane 3)
local function well()
  local S, T, RR = L.stone, L.timber, L.roof
  local roofOuter = poly{ { 143, 90 }, { 198, 120 }, { 198, 126 }, { 88, 126 }, { 88, 120 } }
  local gable = poly{ { 143, 104 }, { 178, 121 }, { 108, 121 } }
  local roofM = roofOuter:copy():cut(gable)
  local postL, postR = rect(103, 126, 110, 156), rect(176, 126, 183, 156)
  local lipTop = poly{ { 98, 147 }, { 188, 147 }, { 194, 156 }, { 92, 156 } }
  local lipFront = rect(92, 156, 194, 165)
  local drum = poly{ { 97, 165 }, { 189, 165 }, { 191, 168 }, { 191, 204 }, { 187, 208 }, { 99, 208 }, { 95, 204 }, { 95, 168 } }
  local axle = rect(110, 130, 176, 133)
  local crank = rect(184, 130, 190, 133):add(rect(188, 133, 191, 143))
  local rope = rect(142, 134, 143, 140)
  local bucket = poly{ { 134, 141 }, { 152, 141 }, { 150, 153 }, { 136, 153 } }
  shadow(100, 192, 208, 14, 6)
  rimOf(union(roofOuter, postL, postR, lipTop, lipFront, drum, crank, axle, bucket), L.timber)
  part(drum, S) courses(drum, 165, 7, 13, S)
  F.moss(drum, .035, 71)
  F.vines(rect(97, 165, 189, 167), .03, 79, 9)
  part(lipFront, S, { sep = true }) courses(lipFront, 156, 10, 17, S, 5)
  F.moss(lipFront, .08, 72)
  part(lipTop, S, { sep = true })
  lipTop:each(function(x, y) if hash(x // 2, y, 73) < .25 then px(x, y, L.moss.hi) end end)
  F.shine(lipTop, .1, 82)
  local opening = poly{ { 106, 149 }, { 180, 149 }, { 184, 154 }, { 102, 154 } }
  fill(opening, L.water.deep) hline(110, 178, 149, S.edge) hline(118, 128, 152, L.water.shade) hline(156, 170, 151, L.water.shade)
  px(165, 152, L.glow.hi) px(166, 152, L.glow.base)
  bambooPosts(union(postL, postR))
  F.bambooWall(union(postL, postR), L.bamboo, 4, false, 83)
  part(axle, L.bamboo, { nopop = true }) hline(110, 176, 130, L.bamboo.hi) for x = 116, 172, 9 do vline(x, 130, 133, L.bamboo.deep) end
  for x = 136, 150, 3 do vline(x, 131, 133, L.needle.base) end
  fill(rope, L.needle.base) part(crank, T, { nopop = true }) fill(rect(188, 140, 191, 143), L.accent.base)
  part(bucket, T) hline(135, 151, 144, L.bamboo.shade) hline(136, 150, 150, L.bamboo.shade)
  line({ { 135, 141 }, { 143, 137 }, { 151, 141 } }):each(function(x, y) px(x, y, L.needle.deep) end)
  hline(137, 149, 142, L.water.hi)
  part(roofM, RR, { sep = true }) F.palmThatch(roofM, RR, 90, 143, 74)
  line({ { 89, 120 }, { 143, 91 } }):each(function(x, y) if roofM:has(x, y) then px(x, y, RR.hi) end end)
  for x = 88, 198 do local len = 1 + floor(hash(x, 126, 75) * 3) for k = 1, len do px(x, 126 + k, k == len and RR.edge or RR.deep) end end
  part(gable, L.plaster, { nopop = true })
  gable:each(function(x, y) px(x, y, (((x + y) // 2) % 2 == ((x - y) // 2) % 2) and L.plaster.base or L.plaster.shade) end)
  vline(143, 106, 121, L.bamboo.shade)
  line({ { 143, 112 }, { 130, 120 } }):each(function(x, y) px(x, y, L.bamboo.shade) end)
  line({ { 143, 112 }, { 156, 120 } }):each(function(x, y) px(x, y, L.bamboo.shade) end)
  -- a little pineapple finial
  F.sprite({ "g.g.g", ".ggg.", ".pPp.", "pPpPp", ".pPp." }, 141, 82, { g = L.foliage2.base, p = pine.shade, P = pine.hi })
  -- a vine with orchids climbing the left post, bromeliads and ferns at the drum foot, a red-eyed frog on the lip
  for y = 128, 155 do local vx = 104 + floor(sin(y / 4) * 1.5 + .5) px(vx, y, L.vine.shade) if y % 4 == 0 then px(vx + 1, y, L.vine.hi) px(vx - 1, y + 1, L.vine.base) end end
  F.orchid(104, 138, L.orchid, 2, true)
  for _, f in ipairs({ { 98, 208, 7 }, { 106, 210, 5 }, { 186, 208, 6 }, { 192, 206, 5 } }) do F.fern(f[1], f[2], f[3]) end
  for i = 0, 5 do local x, y = 97 + floor(hash(i, 1, 41) * 22), 168 + floor(hash(i, 2, 41) * 38) px(x, y, L.fern.base) px(x + 1, y, L.fern.hi) px(x, y + 1, L.fern.deep) end
  F.sprite({ "e.e.", "GGGG", "GgGG", "o..o" }, 120, 143, { e = L.apple.base, G = L.fern.hi, g = L.fern.shade, o = L.produce.base })
  c:sparkle(176, 160)
  -- a spider monkey sitting on the thatch, peeling a banana, its tail curled over the ridge
  F.sprite({
    "....MMMM......",
    "...MMMMMM.....",
    "..MMffffMM.YY.",
    "..MfeffefM.YYy",
    "..MMffffMM..Yy",
    "...MMfmmMM....",
    "..MMMMMMMMM...",
    ".MMMmMMMMMMM..",
    ".MMMmMMMMMMMt.",
    "MMMMMMMMMMMMMt",
    ".MM..MM..MMMt.",
    ".....MM....t..",
  }, 146, 86, { M = L.timber.base, m = L.timber.shade, f = L.skin.base, e = L.timber.edge, Y = L.gold.hi, y = L.gold.shade, t = L.timber.shade })
end
well()

---------------------------------------------------------------- left: the Spice Hut (plane 3)
local function spiceHut()
  local top, cx, wall, roofM = F.building{ x0 = 19, x1 = 75, yb = 212, wh = 42, rh = 16, wall = L.bamboo, roof = L.roof2, noFrame = true, noAttic = true }
  F.bambooWall(wall, L.bamboo, 4, false, 76)
  F.vines(rect(19, top - 1, 75, top + 2), .07, 77, 8)
  -- a chilli-bunch finial
  vline(cx, top - 18, top - 15, L.timber.deep)
  for k = -2, 2 do px(cx + k, top - 20 + abs(k), L.apple.base) px(cx + k, top - 19 + abs(k), L.apple.shade) end
  px(cx, top - 21, L.leaf.base)
  -- shop window: shelves of spice jars and bundled cinnamon
  fill(rect(23, 183, 71, 199), L.timber.deep) fill(rect(24, 184, 70, 198), L.glow.shade)
  fill(rect(24, 184, 70, 187), L.glow.base)
  for i = 0, 7 do
    local x = 25 + i * 6
    local rr = ({ L.gold, L.apple, cinna, L.moss, L.helic, mango, L.lav, L.produce })[i + 1]
    jar(x, 192, rr, (i % 2 == 0) and L.awnA or L.awnB)
  end
  hline(24, 70, 193, L.timber.base)
  for i = 0, 4 do
    local x = 26 + i * 9
    fill(rect(x, 195, x + 5, 198), cinna.base) hline(x, x + 5, 195, cinna.hi) hline(x, x + 5, 198, cinna.deep)
    vline(x + 2, 195, 198, L.awnA.base)
  end
  -- striped awning (turmeric and cream)
  local aw = poly{ { 18, 182 }, { 22, 174 }, { 72, 174 }, { 76, 182 } }
  for x = 18, 76, 4 do aw:add(poly{ { x, 182 }, { x + 4, 182 }, { x + 2, 185 } }) end
  aw:clip(rect(17, 170, 77, 186))
  rimOf(aw, L.helic)
  stripes(aw, 18, 4, L.helic, L.awnB)
  hline(22, 72, 174, L.awnB.hi)
  -- hanging sign: a star anise
  vline(30, 168, 170, L.timber.edge) vline(40, 168, 170, L.timber.edge)
  local sg = rect(28, 160, 42, 167) rimOf(sg, L.timber) part(sg, L.board)
  F.sprite({ "..c..", "c.c.c", ".ccc.", "c.c.c", "..c.." }, 33, 161, { c = cinna.shade }, { rim = false }) px(35, 163, L.gold.base)
  -- chilli strings either side of the door
  chilli(23, 199, 4) chilli(72, 188, 4)
  door(26, 200, 32, 211, L.timber)
  -- open spice sacks in front: turmeric, chilli, cinnamon, cardamom
  spiceSack(42, 213, L.gold) spiceSack(55, 214, L.apple) spiceSack(68, 213, cinna)
  spiceSack(80, 216, L.moss)
  -- a scoop in the chilli
  line({ { 56, 202 }, { 60, 198 } }):each(function(x, y) px(x, y, L.board.base) end)
end
spiceHut()
F.fern(14 + 8, 214, 6) F.heliconia(12, 222, 18, 78)

---------------------------------------------------------------- right hero: the fruit stall (plane 3)
local function stall()
  local T = L.timber
  local roof = poly{ { 288, 168 }, { 300, 151 }, { 400, 151 }, { 412, 168 } }
  local val = rect(289, 167, 411, 173)
  for x = 289, 405, 8 do val:add(poly{ { x, 173 }, { x + 8, 173 }, { x + 4, 178 } }) end
  val:clip(rect(289, 166, 411, 178))
  local posts = rect(295, 178, 299, 224):add(rect(401, 178, 405, 224))
  local back = rect(300, 178, 400, 195)
  local ctop = poly{ { 299, 194 }, { 401, 194 }, { 404, 199 }, { 296, 199 } }
  local cfront = rect(296, 199, 404, 220)
  local legs = rect(300, 221, 304, 225):add(rect(396, 221, 400, 225))
  shadow(296, 406, 224, 14, 5)
  rimOf(union(roof, val, posts, back, ctop, cfront, legs), T)
  bambooPosts(posts)
  -- back wall of woven palm mat, two bamboo shelves of jars and coconut cups
  part(back, L.plaster)
  back:each(function(x, y) px(x, y, (((x + y) // 2) % 2 == ((x - y) // 2) % 2) and L.plaster.shade or L.plaster.deep) end)
  hline(301, 399, 186, L.bamboo.base) hline(301, 399, 187, L.bamboo.deep) hline(301, 399, 193, L.bamboo.base)
  for i = 0, 15 do
    local x = 303 + i * 6
    local rr = ({ L.gold, L.apple, mango, L.lav, lime, cinna })[i % 6 + 1]
    if x < 342 or x > 362 then
      jar(x, 185, rr, (i % 3 == 0) and L.awnA or L.awnB)
      if i % 2 == 0 then coconut(x + 2, 191, true) end
    end
  end
  -- the stallkeeper, behind the counter
  F.gnome(352, 202, { hat = L.awnA, coat = L.wall2, arm = "up", noShadow = true })
  -- palm-thatch roof + woven valance
  part(roof, L.roof, { sep = true }) F.palmThatch(roof, L.roof, 151, 9999, 81)
  line({ { 289, 167 }, { 300, 152 } }):each(function(x, y) if roof:has(x, y) then px(x, y, L.roof.hi) end end)
  hline(300, 400, 151, L.roof.hi) hline(300, 400, 150, L.bamboo.base)
  weave(val, 289, 8, L.helic, L.accent)
  hline(289, 411, 167, L.helic.deep)
  -- sign on the ridge with the wares painted on: mango, banana, chilli, orchid, coconut
  local sign = rect(330, 142, 370, 150)
  rimOf(sign, T) part(sign, L.board) hline(331, 369, 150, L.board.deep)
  F.sprite({ ".mm.", "mmmm", ".mm." }, 333, 144, { m = mango.base }, { rim = false }) px(334, 144, mango.hi)
  F.sprite({ "y...", "yy..", ".yyy" }, 339, 144, { y = L.gold.shade }, { rim = false })
  F.sprite({ "g..", ".r.", ".r.", "..r" }, 346, 143, { g = L.leaf.shade, r = L.apple.base }, { rim = false })
  F.sprite({ "p.p", ".o.", "p.p" }, 352, 144, { p = L.orchid.shade, o = L.gold.base }, { rim = false })
  F.sprite({ ".cc.", "cccc", ".cc." }, 359, 144, { c = L.soil.base }, { rim = false })
  F.sprite({ ".l.", "lll", ".l." }, 365, 144, { l = L.leaf.shade }, { rim = false })
  -- hanging under the valance: lanterns, banana hands, chilli strings, an orchid basket
  lantern(304, 180, 1)
  lantern(396, 180, 1)
  hline(310, 336, 179, L.bamboo.deep)
  for k = 0, 2 do bananas(309 + k * 9, 180) end
  for k = 0, 3 do chilli(368 + k * 5, 181, 4 + (k % 2)) end
  -- counter: lashed horizontal bamboo front, split-bamboo top
  part(cfront, L.bamboo)
  F.bambooWall(cfront, L.bamboo, 3, true, 84)
  for x = 296, 404, 27 do vline(x, 200, 220, L.needle.deep) vline(x + 1, 200, 220, L.needle.shade) end
  part(ctop, L.board) F.bambooWall(ctop, L.board, 3, true, 85) hline(299, 401, 194, L.board.hi)
  part(legs, L.bamboo, { nopop = true })
  -- goods on the counter
  basket(300, 320, 198, 5, mango, "round", 82)
  basket(322, 340, 198, 5, L.apple, "rambutan", 83)
  basket(364, 384, 198, 5, dragon, "dragon", 84)
  spiceCone(389, 198, L.gold, 8) spiceCone(397, 198, L.apple, 7)
  -- a papaya cut open on a board
  local pap = c:ellipse(346, 195, 5, 2) rimOf(pap, mango) fill(pap, mango.base) hline(343, 349, 195, mango.hi)
  for x = 344, 348, 2 do px(x, 195, L.timber.edge) end
  -- crates in front: pineapples and green coconuts
  local cr1 = rect(308, 210, 332, 222) rimOf(cr1, T) part(cr1, L.board) F.bambooWall(cr1, L.board, 3, false, 86)
  hline(308, 332, 216, L.board.deep)
  for k = 0, 3 do
    local x = 311 + k * 6
    local pm = c:ellipse(x, 207, 2, 3) rimOf(pm, pine) fill(pm, pine.base) px(x - 1, 205, pine.hi) px(x + 1, 208, pine.shade) px(x, 207, pine.shade)
    px(x, 202, L.foliage2.base) px(x - 1, 203, L.foliage2.hi) px(x + 1, 203, L.foliage2.base) px(x - 2, 202, L.foliage2.shade) px(x + 2, 202, L.foliage2.shade)
  end
  local cr2 = rect(362, 210, 386, 222) rimOf(cr2, T) part(cr2, L.board) hline(362, 386, 216, L.board.deep) vline(374, 210, 222, L.board.deep)
  for k = 0, 4 do local x = 365 + k * 5 local m = c:ellipse(x, 207, 2, 2) c:rim(m, L.vine.edge) fill(m, L.vine.base) px(x - 1, 206, L.vine.hi) px(x + 1, 208, L.vine.shade) end
  F.sack(392, 224, L.awnB, 4)
  -- a perch on the right post with a scarlet macaw
  hline(405, 412, 186, L.timber.base) hline(405, 412, 187, L.timber.deep)
  F.sprite({
    "..RRR...",
    ".RWWRR..",
    "kkWeRR..",
    "kk.RRRR.",
    "...RRRRR",
    "...RRYYB",
    "...RYYBB",
    "....RBBb",
    "....RRBb",
    ".....RB.",
    ".....RB.",
    "......R.",
  }, 404, 175, { R = L.apple.base, W = L.awnB.hi, e = L.timber.edge, k = L.awnB.shade, Y = L.gold.base, B = "#4a8ad8", b = "#2c4c9c" })
  -- quirk: a three-toed sloth in a red gnome hat dozing on the roof, hugging the sign
  F.sprite({
    ".......R..........",
    "......RRr.........",
    ".....RRRRr........",
    "....RRRRRRr.......",
    "...hhhhhhhhh......",
    "..SFFFFFFFFFS.....",
    ".SFFkkFFFFkkFS....",
    ".SFFkkFFFFkkFS....",
    ".SFFFFnnnFFFFS....",
    "..SFFFFmmFFFS.....",
    "..ssssssssssss....",
    ".ssSSsSSSsSSssSc..",
    "ssSSSSsSSSSsSSSSc.",
    "ssSsSSSSSsSSSSsSc.",
    ".ssSS.ss..ssSSs.c.",
    "..ss..ss...ss.....",
  }, 307, 135, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, S = sloth.shade, s = sloth.deep, F = sloth.hi,
    k = sloth.edge, n = L.timber.edge, m = sloth.deep, c = L.awnB.hi })
end
stall()
basket(410, 426, 224, 5, lime, "round", 90)
basket(414, 430, 214, 5, mango, "round", 91)
-- a shopper with a fruit basket, by the stall
local _, shx, shy = F.gnome(284, 228, { hat = L.roof2, coat = L.helic, arm = "out", flip = true })
local bk = poly{ { shx - 3, shy }, { shx + 3, shy }, { shx + 2, shy + 5 }, { shx - 2, shy + 5 } }
rimOf(bk, L.timber) part(bk, L.board, { nopop = true })
px(shx - 1, shy - 1, mango.base) px(shx, shy - 1, mango.hi) px(shx + 1, shy - 1, dragon.base)
line({ { shx - 3, shy }, { shx, shy - 3 }, { shx + 3, shy } }):each(function(x, y) if y < shy then px(x, y, L.timber.deep) end end)

---------------------------------------------------------------- bottom: the long table under a striped canopy (plane 3)
local function longTable()
  local can = poly{ { 120, 233 }, { 128, 222 }, { 180, 222 }, { 188, 233 } }
  for x = 120, 186, 4 do can:add(poly{ { x, 233 }, { x + 4, 233 }, { x + 2, 236 } }) end
  can:clip(rect(120, 222, 188, 236))
  local posts = rect(123, 236, 125, 262):add(rect(183, 236, 185, 262))
  local top = poly{ { 131, 243 }, { 177, 243 }, { 181, 249 }, { 127, 249 } }
  local cloth = rect(127, 249, 181, 254)
  local legs = rect(129, 255, 131, 261):add(rect(177, 255, 179, 261))
  local bench = rect(126, 258, 182, 260)
  shadow(124, 186, 262, 8, 3)
  rimOf(union(can, posts, top, cloth, legs, bench), L.timber)
  bambooPosts(posts)
  stripes(can, 120, 4, L.awnB, L.teal)
  hline(128, 180, 222, L.awnB.hi)
  part(legs, L.bamboo, { nopop = true })
  part(top, L.board) F.bambooWall(top, L.board, 3, true, 87)
  part(cloth, L.accent, { nopop = true })
  cloth:each(function(x, y) if ((x // 3) + (y // 2)) % 2 == 0 then px(x, y, L.accent.shade) end if (x + y) % 6 == 0 then px(x, y, L.helic.base) end end) -- batik
  for x = 127, 181, 3 do px(x, 254, L.accent.hi) end
  part(bench, L.bamboo, { nopop = true }) hline(126, 182, 258, L.bamboo.hi)
  -- banana-leaf runner
  local run = rect(133, 244, 175, 246) fill(run, L.leaf.base) hline(133, 175, 244, L.leaf.hi) hline(133, 175, 246, L.leaf.shade)
  for x = 135, 173, 4 do px(x, 245, L.leaf.shade) end
  -- feast: teapot, a pineapple, a fruit platter, coconut drinks
  local tp = poly{ { 134, 238 }, { 142, 238 }, { 143, 244 }, { 133, 244 } }
  rimOf(tp, L.roof2) part(tp, L.roof2) line({ { 143, 240 }, { 146, 237 } }):each(function(x, y) px(x, y, L.roof2.deep) end)
  px(137, 237, L.roof2.deep) px(138, 237, L.roof2.deep)
  local pa = c:ellipse(150, 240, 3, 4) rimOf(pa, pine) part(pa, pine) pa:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, pine.shade) end end)
  for _, b in ipairs({ { -2, -3 }, { 0, -4 }, { 2, -3 } }) do line({ { 150, 236 }, { 150 + b[1], 236 + b[2] } }):each(function(x, y) px(x, y, L.foliage2.base) end) end
  local pl = c:ellipse(161, 244, 6, 1) fill(pl, L.awnB.base)
  for k = 0, 4 do px(157 + k * 2, 243, ({ mango.base, dragon.base, lime.base, L.apple.base, mango.hi })[k + 1]) px(158 + k * 2, 242, ({ mango.hi, dragon.hi, lime.hi, L.apple.hi, L.gold.hi })[k + 1]) end
  coconutDrink(170, 245) coconutDrink(176, 245)
  lantern(130, 236, 0)
  lantern(178, 236, 0)
end
longTable()

---------------------------------------------------------------- bottom left: the lotus pond with a bamboo jetty (plane 3)
local function pond()
  local bank = poly{ { 18, 238 }, { 32, 228 }, { 72, 226 }, { 100, 232 }, { 108, 246 }, { 100, 260 }, { 60, 264 }, { 26, 262 }, { 16, 252 } }
  local water = bank:shrink(3)
  shadow(24, 104, 262, 6, 3)
  rimOf(bank, L.water)
  fill(bank, L.soil.base)
  bank:each(function(x, y) if not water:has(x, y) then local v = hash(x, y, 51) px(x, y, v < .35 and L.stone.base or (v < .55 and L.stone.hi or (v < .62 and L.wet or L.moss.base))) end end)
  F.water(water, L.water)
  -- canopy reflections along the far edge
  for _, rx in ipairs({ 36, 58, 84 }) do for k = 0, 4 do hline(rx - 3 + k // 2, rx + 3 - k // 2, 233 + k * 2, L.water.shade) end end
  -- lotus pads, lotus flowers, koi
  for _, p in ipairs({ { 40, 240, 4 }, { 54, 252, 5 }, { 28, 250, 4 }, { 62, 240, 3 } }) do
    local pad = c:ellipse(p[1], p[2], p[3], math.max(1, p[3] // 3))
    c:rim(pad, L.leaf.edge) fill(pad, L.leaf.base) px(p[1] - p[3] + 1, p[2], L.leaf.hi) px(p[1] + 1, p[2], L.leaf.deep) px(p[1] - 1, p[2] - 1, L.leaf.hi)
  end
  F.sprite({ ".p.p.", "pPhPp", ".pPp.", "..g.." }, 38, 235, { p = L.petal.base, P = L.petal.hi, h = L.gold.hi, g = L.leaf.deep })
  F.sprite({ ".p.", "pPp", ".g." }, 53, 247, { p = L.petal.base, P = L.petal.hi, g = L.leaf.deep })
  F.sprite({ "ooO.", "OoooO", "ooO." }, 44, 256, { o = L.produce.base, O = L.awnB.hi }, { rim = false })
  F.sprite({ "oO..", "OOoO", "oO.." }, 70, 252, { o = L.produce.shade, O = L.produce.hi }, { rim = false })
  -- bamboo jetty
  local jet = poly{ { 70, 240 }, { 104, 240 }, { 106, 250 }, { 72, 250 } }
  local legs = rect(74, 250, 76, 257):add(rect(100, 250, 102, 256)):add(rect(86, 250, 88, 256))
  rimOf(union(jet, legs), L.timber)
  part(legs, L.bamboo, { nopop = true })
  part(jet, L.board) F.bambooWall(jet, L.board, 3, false, 52)
  hline(72, 105, 250, L.timber.deep)
  F.moss(legs, .3, 52)
  -- bamboo rod leaning, line + red float
  line({ { 98, 240 }, { 80, 222 }, { 66, 220 } }):each(function(x, y) px(x, y, L.bamboo.shade) end)
  vline(66, 221, 236, L.awnB.shade) fill(rect(65, 236, 67, 238), L.awnA.base) px(65, 236, L.awnA.hi)
  hline(62, 70, 239, L.water.hi)
  -- papyrus heads on the left bank
  for i = 0, 6 do
    local x = 20 + i * 4 local h = 7 + floor(hash(i, 9, 52) * 8)
    vline(x, 252 - h, 252, i % 2 == 0 and L.fern.shade or L.fern.deep)
    for d = -2, 2 do px(x + d, 252 - h - 1 + abs(d) // 2, abs(d) == 2 and L.fern.deep or L.fern.base) end
    px(x, 252 - h - 2, L.fern.hi)
  end
  -- a woven fish trap and a lidded basket on the jetty
  local box = c:rrect(90, 233, 99, 239, 2) rimOf(box, L.timber) part(box, L.board) box:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.board.shade) end end) hline(90, 99, 233, L.awnA.base)
  local fb = poly{ { 78, 234 }, { 86, 234 }, { 85, 239 }, { 79, 239 } } rimOf(fb, L.timber) part(fb, L.bamboo, { nopop = true })
  for x = 79, 85, 2 do vline(x, 235, 238, L.bamboo.shade) end
  F.moss(F.rock(16, 238, 6, 5), .3, 53)
  -- a red-eyed tree frog on a pad
  F.sprite({ "e.e.", "GGGG", "GgGG", "o..o" }, 26, 245, { e = L.apple.base, G = L.fern.hi, g = L.fern.shade, o = L.produce.base })
  F.bigLeaf(104, 226, 13, -pi * .3, L.foliage, 54, 5, { heart = true, stem = { 108, 240 } })
end
pond()

---------------------------------------------------------------- bottom right: raised bed of chillies and pineapple plants (plane 3)
local function bed()
  local T = L.timber
  local soil = poly{ { 304, 247 }, { 368, 247 }, { 374, 254 }, { 298, 254 } }
  local front = rect(298, 254, 374, 262)
  local back = rect(304, 245, 368, 247)
  shadow(300, 374, 262, 8, 2)
  rimOf(union(soil, front, back), T)
  part(back, L.bamboo, { nopop = true })
  fill(soil, L.soil.base) soil:each(function(x, y) if hash(x, y, 71) < .2 then px(x, y, L.soil.deep) elseif hash(x, y, 72) < .1 then px(x, y, L.litter.base) end end)
  part(front, L.bamboo) F.bambooWall(front, L.bamboo, 3, true, 88)
  for _, ex in ipairs({ 298, 374 }) do local m = c:ellipse(ex, 258, 3, 4) rimOf(m, L.bamboo) fill(m, L.bamboo.base) fill(c:ellipse(ex, 258, 1, 2), L.soil.deep) px(ex - 2, 256, L.bamboo.hi) end
  for i, x in ipairs({ 310, 333, 356 }) do -- pineapple plants: spiky rosettes with a little fruit
    local ro = HP.mask()
    for _, b in ipairs({ { -7, -3 }, { -5, -7 }, { -2, -9 }, { 2, -9 }, { 5, -7 }, { 7, -3 }, { -8, 0 }, { 8, 0 } }) do ro:add(line({ { x, 251 }, { x + b[1], 251 + b[2] } })) end
    rimOf(ro, L.foliage2) part(ro, L.foliage2, { nopop = true })
    ro:each(function(xx, yy) if xx < x then px(xx, yy, L.foliage2.hi) end end)
    local pm = c:ellipse(x, 244, 2, 3) rimOf(pm, pine) fill(pm, pine.base) px(x - 1, 242, pine.hi) px(x + 1, 245, pine.shade) px(x, 244, pine.shade)
    px(x, 240, L.foliage2.base) px(x - 1, 240, L.foliage2.hi) px(x + 1, 239, L.foliage2.base)
  end
  for i, x in ipairs({ 321, 344, 366 }) do -- chilli bushes
    local b = poly{ { x - 5, 251 }, { x - 4, 243 }, { x, 239 }, { x + 4, 243 }, { x + 5, 251 } }
    rimOf(b, L.leaf) part(b, L.leaf)
    b:each(function(xx, y) if hash(xx, y, 73) < .12 then px(xx, y, L.apple.base) px(xx, y + 1, L.apple.shade) px(xx, y - 1, L.leaf.deep) end end)
  end
  fill(rect(371, 238, 372, 246), L.bamboo.base)
  local bl = poly{ { 369, 246 }, { 374, 246 }, { 372, 251 } } fill(bl, L.iron.base) px(370, 246, L.iron.hi)
end
bed()

---------------------------------------------------------------- near ferns, heliconia, butterflies, sky life
for _, f in ipairs({ { 112, 262, 7 }, { 192, 262, 8 }, { 200, 250, 6 }, { 286, 258, 7 }, { 376, 226, 6 }, { 414, 228, 6 }, { 196, 226, 6 } }) do F.fern(f[1], f[2], f[3]) end
F.heliconia(206, 266, 22, 92)
F.mushroom(190, 266, L.helic, true) F.mushroom(194, 268, L.produce) F.mushroom(290, 236, L.litter, true)
F.puddle(280, 248, 5, 93)
F.orchid(114, 250, L.orchid, 2)
for _, b in ipairs({ { 190, 216 }, { 92, 222 }, { 278, 170 } }) do
  F.sprite({ "BB.BB", "bBkBb", ".b.b." }, b[1], b[2], { B = "#5aa8f0", b = "#2c62b4", k = L.timber.edge }, { rim = false })
end
F.depth(0)
F.birds({ { 300, 40, 2, "#2e7a46" }, { 310, 46, 1, "#2e7a46" }, { 292, 49, 1, "#b03a36" }, { 120, 58, 2, "#2e7a46" }, { 410, 50, 1, "#b03a36" } })

F.finish()
