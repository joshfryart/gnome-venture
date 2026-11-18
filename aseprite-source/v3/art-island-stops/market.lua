-- market.lua : "Market hamlet" stop look, ISLAND (island_palm), 480x270 gate view.
-- Same composition and hotspots as the Maplewold market (here-gate/pilot-market.lua, ported in art-forest-stops/market.lua),
-- re-cast as a beach bazaar on a coral island:
-- road's end: the Beach Gate, two carved driftwood tiki posts under a palm-thatch gable heaped with fronds and
-- flowers, a glass fishing-float lantern; through it the lagoon and a little outrigger with a crab-claw sail.
-- Back left: two painted stilt huts with smoke. Back right: a bamboo notice board under thatch (a pelican in a red
-- gnome hat on the peak) and the bamboo rest house with a hammock (a gnome napping), coconut cups and a teapot.
-- Left: the coral-stone wishing well with a thatch roof (a macaw on the ridge), a giant clam full of wish coins, and
-- the Shell Swap hut (shells in the window, shell strings, rolled pandanus mats). Right hero: the fruit stall:
-- bamboo posts, thatch roof, red-and-gold valance, baskets of mangoes, limes and rambutan, banana hands, coconut
-- oil bottles, a gnome stallkeeper. Bottom: the woven-goods table (mats, hats, fans, a lei), a tide pool with a
-- starfish, and a beached outrigger canoe selling fish on ice; a pineapple patch.
-- Quirks kept from Maplewold, in island dress: the teapot-hatted scarecrow (coconut head, grass skirt), the barrow
-- growing something too big (a giant pineapple), the snail mailbox (a conch-shell mailbox with a hermit crab), and
-- the haystack house as a giant coconut house. The local animal in a red gnome hat: the pelican.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-island-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "market", out = DIR, treeLineGap = { 200, 280 },
  farTrees = { 24, 60, 140, 330, 446 }, clouds = { { 140, 40, 44 }, { 300, 30, 50 }, { 438, 52, 30 }, { 24, 70, 24 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local shadow, window, door = F.shadow, F.window, F.door
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs

-- local ramps for market goods
local mango = F.rp("#ffe680 #ffbe3c #f2862e #c85a2a #7c3420")
local lime = F.rp("#e2f48c #a8d84a #74b03a #4c8432 #2c5426")
local ice = F.rp("#f2fafa #d8f0f2 #b4dae4 #88b6c8 #5a86a0")
local glass = F.rp("#d4f6ea #96e0cc #5cbcae #3a8e88 #265e62")
local pine = F.rp("#ffe88e #f2c04a #d0922e #9c6422 #5e3c18")
local tuna = F.rp("#a8d0f0 #5a96d0 #3a70ac #2a5086 #1a345a")
local urchin = F.rp("#b88ac8 #7a4e9a #583a78 #3e2858 #261a3a")
local starR = F.rp("#ffc27a #ff9440 #e0682c #a8462a #6a2a20")

---------------------------------------------------------------- local helpers
local function weave(m, r, seed) -- pandanus weave: two-tone 2x2 checks, a dark seam every other row
  m:each(function(x, y)
    local wv = ((x // 2 + y // 2) % 2 == 0)
    local h = wv and r.hi or r.base
    if (wv and y % 2 == 1) or (not wv and x % 2 == 1) then h = wv and r.base or r.shade end
    if hash(x // 4, y // 4, seed or 3) < .06 then h = r.shade end
    px(x, y, h)
  end)
end
local function bambooPosts(m) -- round bamboo poles: lit left, dark right, node rings
  rimOf(m, L.board)
  m:each(function(x, y)
    local h = L.board.base
    if not m:has(x - 1, y) then h = L.board.hi elseif not m:has(x + 1, y) then h = L.board.shade end
    if (y + (x // 6) * 3) % 8 == 0 then h = L.board.deep elseif (y + (x // 6) * 3) % 8 == 1 and m:has(x - 1, y) then h = L.board.hi end
    px(x, y, h)
  end)
end
local function thatchRoof(m, y0, cx, r)
  r = r or L.roof
  part(m, r, { sep = true })
  F.thatch(m, r, y0, cx)
end
local function float(x, y, cord) -- a green glass fishing float in a rope net, hung as a lantern; top at y
  if cord and cord > 0 then vline(x, y - cord, y - 1, L.rope.deep) end
  local m = c:ellipse(x, y + 3, 3, 3)
  c:rim(m, glass.edge) fill(m, glass.base)
  m:each(function(xx, yy) if not m:has(xx + 1, yy + 1) then px(xx, yy, glass.shade) end end)
  px(x - 1, y + 2, glass.hi) px(x - 2, y + 3, glass.hi) px(x, y + 3, L.glow.hi)
  hline(x - 3, x + 3, y + 3, L.rope.shade) vline(x, y, y + 6, L.rope.shade) px(x, y + 3, L.glow.base)
end
local function fruitHeap(m, r, kind, seed)
  part(m, r, { nopop = true })
  m:each(function(x, y)
    if kind == "round" then -- 2x2 round fruit: lit upper-left dot, dark gaps
      local bx, by = (x + (y // 2) % 2) % 2, y % 2
      if bx == 0 and by == 0 then px(x, y, r.hi) elseif bx == 1 and by == 1 then px(x, y, r.deep) end
    elseif kind == "mango" then -- 3x2 mangoes, a green-blush shoulder, red cheek
      local u, v = (x + (y // 2) * 2) % 3, y % 2
      if u == 0 and v == 0 then px(x, y, r.hi) elseif u == 2 and v == 1 then px(x, y, r.deep)
      elseif u == 1 and v == 1 and hash(x // 3, y // 2, seed) < .4 then px(x, y, lime.base)
      elseif u == 2 and v == 0 and hash(x // 3, y // 2, seed + 1) < .5 then px(x, y, L.awnA.base) end
    elseif kind == "hairy" then -- rambutan: red with hairy dots
      local v = hash(x, y, seed)
      if v < .2 then px(x, y, r.hi) elseif v > .78 then px(x, y, lime.shade) end
      if (x + y) % 3 == 0 and hash(x, y, seed + 1) < .5 then px(x, y, r.deep) end
    else
      local v = hash(x, y, seed) if v < .18 then px(x, y, r.hi) elseif v > .85 then px(x, y, r.deep) end
    end
  end)
end
local function basket(x0, x1, yb, h, r, kind, seed) -- woven pandanus basket heaped with goods
  local body = poly{ { x0, yb - h }, { x1, yb - h }, { x1 - 2, yb }, { x0 + 2, yb } }
  local mid = (x0 + x1) // 2
  local heap = poly{ { x0 + 1, yb - h }, { x0 + 3, yb - h - 4 }, { mid, yb - h - 7 }, { x1 - 3, yb - h - 4 }, { x1 - 1, yb - h } }
  rimOf(union(body, heap), L.timber)
  part(body, L.rope, { nopop = true })
  weave(body, L.rope, seed)
  hline(x0, x1, yb - h, L.rope.hi) hline(x0 + 2, x1 - 2, yb, L.rope.deep)
  fruitHeap(heap, r, kind, seed)
  px(x0 + 3, yb - h - 3, L.leaf.base) px(x0 + 4, yb - h - 4, L.leaf.hi) px(x1 - 4, yb - h - 2, L.foliage.shade)
  return body
end
local function bottle(x, yb, r) -- coconut-oil / syrup bottle 3 wide, 8 tall, cork
  local m = rect(x, yb - 4, x + 2, yb):add(rect(x + 1, yb - 6, x + 1, yb - 5))
  rimOf(m, L.timber)
  fill(m, r.base) vline(x, yb - 4, yb, r.hi) vline(x + 2, yb - 4, yb, r.shade) px(x + 1, yb - 6, L.coconut.base)
  px(x + 1, yb - 2, L.awnB.hi)
end
local function jar(x, yb, r, lidR) -- little jar 4 wide, 6 tall, cloth lid
  local m = rect(x, yb - 5, x + 3, yb)
  rimOf(m, L.timber)
  fill(m, r.base) vline(x, yb - 4, yb, r.hi) vline(x + 3, yb - 4, yb, r.shade) hline(x, x + 3, yb, r.deep)
  hline(x, x + 3, yb - 5, (lidR or L.awnB).base) px(x + 1, yb - 5, (lidR or L.awnB).hi)
  px(x + 1, yb - 3, L.awnB.hi)
end
local function bananas(x, y) -- a hand of bananas hanging from a stalk, top at y, 7 wide 9 tall
  F.sprite({ "...t...", "...t...", ".yYtYy.", "yYyYyYy", "yYyYyYy", ".yYyYy.", ".yYyYy.", "..d.d..", }, x - 3, y,
    { t = L.foliage2.shade, Y = L.gold.hi, y = L.gold.base, d = L.gold.deep })
  px(x - 2, y + 4, lime.base) px(x + 2, y + 5, L.gold.shade)
end
local function fishSide(x, y, r, flip) -- a fish lying on its side, 12 wide, head at the right (flip: left)
  local rows = { "....ffff....", "t..bBBBBbbe.", "ttbBBBbbbbbm", "ttbbbbbbbbh.", "t..ssssssh..", "....s.s....." }
  local map = { f = r.shade, t = r.deep, b = r.base, B = r.hi, e = L.timber.edge, h = r.shade, m = r.deep, s = "S" }
  local m = HP.mask()
  for j, row in ipairs(rows) do for i = 1, #row do
    local ch = row:sub(i, i)
    if map[ch] then m:set(flip and (x + 12 - i) or (x + i - 1), y + j - 1) end
  end end
  c:rim(m, r.edge)
  for j, row in ipairs(rows) do for i = 1, #row do
    local ch = row:sub(i, i)
    if map[ch] then px(flip and (x + 12 - i) or (x + i - 1), y + j - 1, ch == "s" and F.mix(r.base, ice.hi, .55) or map[ch]) end
  end end
  px(flip and (x + 2) or (x + 9), y + 1, L.awnB.hi) -- eye glint
end
local function stripes(m, x0, w, rA, rB)
  m:each(function(x, y) px(x, y, ((x - x0) // w) % 2 == 0 and rA.base or rB.base) end)
  m:each(function(x, y) if not m:has(x, y + 1) then px(x, y, (((x - x0) // w) % 2 == 0 and rA or rB).shade) end end)
  m:each(function(x, y) if ((x - x0) % w) == 0 and m:has(x, y + 1) and ((x - x0) // w) % 2 == 0 then px(x, y, rA.hi) end end)
end
local function shuttered(x0, y0, x1, y1)
  window(x0, y0, x1, y1, L.timber)
  local w = (x1 - x0) // 2 + 1
  local sl, sr = rect(x0 - w - 2, y0 - 1, x0 - 2, y1 + 1), rect(x1 + 2, y0 - 1, x1 + w + 2, y1 + 1)
  rimOf(union(sl, sr), L.wall2) part(sl, L.wall2, { nopop = true }) part(sr, L.wall2, { nopop = true })
  union(sl, sr):each(function(x, y) if y % 2 == 0 then px(x, y, L.wall2.shade) end end)
end
local function tapa(m, x0, y0) -- tapa bark-cloth: cream with brown zig-zag and diamond bands
  m:each(function(x, y)
    local ry, rx = (y - y0) % 6, (x - x0) % 6
    local h = L.awnB.base
    if ry == 0 then h = L.coconut.shade
    elseif ry <= 2 and abs(rx - 3) <= ry then h = L.soil.shade
    elseif ry >= 4 and (rx + ry) % 3 == 0 then h = L.coconut.base end
    px(x, y, h)
  end)
end

---------------------------------------------------------------- far quirks (plane 1): coconut scarecrow + giant pineapple barrow
F.depth(1)
F.tree(196, 118, 28, 3, false)
local function scarecrow()
  local t = L.timber
  local post = rect(108, 72, 109, 112):add(rect(100, 81, 117, 82))
  local shirt = poly{ { 103, 80 }, { 114, 80 }, { 115, 91 }, { 102, 91 } }
  local skirt = poly{ { 101, 91 }, { 116, 91 }, { 118, 100 }, { 99, 100 } }
  local head = c:ellipse(108, 74, 4, 4)
  local hat = poly{ { 103, 67 }, { 114, 67 }, { 113, 70 }, { 104, 70 } }
  local spout = line({ { 114, 69 }, { 118, 65 } })
  local lid = rect(107, 64, 110, 66)
  rimOf(union(post, shirt, skirt, head, hat, spout, lid), t)
  part(post, t, { nopop = true })
  -- an aloha shirt: turquoise with hibiscus print
  part(shirt, L.wall2)
  shirt:each(function(x, y) if (x * 3 + y * 5) % 11 == 0 then px(x, y, L.awnA.base) px(x - 1, y, L.awnA.hi) end end)
  -- a grass skirt of dry fronds
  skirt:each(function(x, y) px(x, y, (x % 2 == 0) and L.needle.base or (y > 96 and L.needle.shade or L.needle.hi)) end)
  hline(101, 116, 91, L.rope.deep)
  -- the coconut head with a carved grin
  part(head, L.coconut)
  head:each(function(x, y) if (x + y * 2) % 5 == 0 then px(x, y, L.coconut.shade) end end)
  px(106, 73, t.edge) px(110, 73, t.edge) hline(106, 110, 76, L.coconut.deep) px(105, 75, L.coconut.deep) px(111, 75, L.coconut.deep)
  -- the teapot hat
  part(hat, L.accent) part(lid, L.accent, { nopop = true }) fill(spout, L.accent.shade)
  px(102, 69, L.accent.deep) px(101, 68, L.accent.deep) px(101, 67, L.accent.deep)
  hline(104, 113, 68, L.awnB.base)
  for _, p in ipairs({ { 99, 82 }, { 118, 82 } }) do px(p[1], p[2], L.needle.hi) px(p[1], p[2] + 1, L.needle.shade) end
  -- a lory perched on the arm, a hibiscus over the ear
  F.parrot(115, 70, "lory", true)
  F.flower(104, 72, "hibiscus", true)
end
scarecrow()
local function barrow()
  local t = L.timber
  local tray = poly{ { 158, 93 }, { 186, 93 }, { 182, 101 }, { 162, 101 } }
  local handles = line({ { 158, 95 }, { 150, 99 } }):add(line({ { 165, 101 }, { 163, 105 } }))
  local wheel = poly{ { 182, 99 }, { 188, 99 }, { 190, 102 }, { 188, 105 }, { 182, 105 }, { 180, 102 } }
  local fruit = c:ellipse(172, 74, 13, 19)
  local leaves = HP.mask()
  local tips = { { 160, 40 }, { 164, 34 }, { 170, 30 }, { 176, 32 }, { 182, 36 }, { 188, 44 }, { 156, 48 }, { 172, 38 }, { 192, 52 } }
  for _, tp in ipairs(tips) do leaves:add(poly{ { 168, 57 }, { 176, 57 }, { tp[1], tp[2] } }) end
  rimOf(union(tray, handles, wheel, fruit, leaves), t)
  part(handles, t, { nopop = true }) part(tray, t) F.bamboo(tray, L.board, 3, { horizontal = true })
  part(wheel, L.timber, { nopop = true }) px(185, 102, L.iron.base)
  -- the spiky crown: blue-green leaves, lit on the left, each with a dark midrib
  part(leaves, L.seagrass, { nopop = true })
  for _, tp in ipairs(tips) do
    line({ { 172, 57 }, { tp[1], tp[2] } }):each(function(x, y) px(x, y, tp[1] < 172 and L.seagrass.hi or L.seagrass.shade) end)
  end
  -- the giant pineapple: a diamond lattice of scales, each lit upper-left, darker to the right
  fill(fruit, pine.base)
  fruit:each(function(x, y)
    local u, v = (x + y) % 6, (x - y) % 6
    local h = pine.base
    if u == 0 or v == 0 then h = pine.deep
    elseif u == 1 and v == 1 then h = pine.hi
    elseif u >= 4 and v >= 4 then h = pine.shade end
    if x > 177 and h == pine.base then h = pine.shade end
    if x > 181 and h == pine.hi then h = pine.base end
    if (u == 3 and v == 3) and hash(x, y, 3) < .5 then h = lime.shade end
    px(x, y, h)
  end)
  -- a little rope sling and a note: SOLD
  hline(160, 184, 94, L.board.hi)
  local tag = rect(150, 82, 157, 87) rimOf(tag, L.timber) part(tag, L.awnB, { nopop = true }) hline(151, 156, 84, L.awnA.base) hline(151, 155, 86, L.awnB.shade)
  line({ { 157, 84 }, { 160, 82 } }):each(function(x, y) px(x, y, L.rope.deep) end)
end
barrow()

---------------------------------------------------------------- road's end: the Beach Gate, tiki posts and a thatch gable (plane 2)
F.depth(2)
F.tree(198, 128, 56, 5)
F.tree(284, 128, 52, 3)
local function beachGate()
  -- through the gate: a sandy path to the water, a little outrigger with a crab-claw sail on the lagoon
  fill(poly{ { 233, 124 }, { 247, 124 }, { 243, 113 }, { 237, 113 } }, L.ground.hi)
  hline(237, 243, 113, L.duff) hline(236, 244, 118, L.ground.base)
  local hull = poly{ { 226, 108 }, { 244, 108 }, { 247, 106 }, { 243, 110 }, { 228, 110 }, { 224, 106 } }
  local sail = poly{ { 233, 106 }, { 230, 88 }, { 248, 96 } }
  local mast = line({ { 236, 106 }, { 233, 90 } })
  rimOf(union(hull, sail, mast), L.timber)
  part(hull, L.timber, { nopop = true }) hline(226, 244, 108, L.awnA.base)
  part(sail, L.rope, { nopop = true }) weave(sail, L.rope, 9)
  line({ { 232, 96 }, { 244, 98 } }):each(function(x, y) if sail:has(x, y) then px(x, y, L.awnA.base) end end)
  fill(mast, L.timber.deep)
  hline(222, 230, 110, L.lagoon.hi) hline(240, 252, 111, L.lagoon.hi)
  -- the two carved driftwood tiki posts
  local pL, pR = rect(210, 78, 221, 124), rect(259, 78, 270, 124)
  local lintel = rect(206, 72, 274, 79)
  local roof = poly{ { 200, 74 }, { 240, 52 }, { 280, 74 } }
  local gable = poly{ { 214, 72 }, { 240, 58 }, { 266, 72 } }
  roof:cut(gable)
  shadow(212, 270, 124, 8, 4)
  rimOf(union(pL, pR, lintel, roof, gable), L.timber)
  for _, p in ipairs({ { 210, 221 }, { 259, 270 } }) do
    local m = rect(p[1], 78, p[2], 124)
    part(m, L.timber, { nopop = true })
    m:each(function(x, y)
      local h = L.timber.base
      if x == p[1] then h = L.timber.hi elseif x >= p[2] - 1 then h = L.timber.shade end
      if hash(x, y // 3, 12) < .1 then h = L.timber.deep end
      px(x, y, h)
    end)
    local cx = (p[1] + p[2]) // 2
    for _, fy in ipairs({ 82, 104 }) do -- two stacked faces per post: brow, round eyes, wide grinning mouth
      hline(p[1] + 1, p[2] - 1, fy, L.timber.deep) hline(p[1] + 1, p[2] - 1, fy + 1, L.timber.hi)
      for _, ex in ipairs({ cx - 3, cx + 2 }) do
        fill(rect(ex, fy + 3, ex + 1, fy + 5), L.timber.edge) px(ex, fy + 3, L.awnB.base)
        px(ex - 1, fy + 3, L.timber.deep) px(ex + 2, fy + 5, L.timber.hi)
      end
      vline(cx, fy + 5, fy + 8, L.timber.hi) px(cx + 1, fy + 8, L.timber.deep)
      fill(rect(cx - 4, fy + 11, cx + 4, fy + 14), L.awnA.shade)
      hline(cx - 3, cx + 3, fy + 12, L.awnB.base) hline(cx - 4, cx + 4, fy + 15, L.timber.deep)
      for x = cx - 3, cx + 3, 2 do px(x, fy + 13, L.awnA.deep) end
      hline(p[1], p[2], fy + 18, L.wall2.base) hline(p[1], p[2], fy + 19, L.wall2.shade)
    end
  end
  -- bamboo lintel lashed with rope, a palm-thatch gable with a woven mat face
  part(lintel, L.board) F.bamboo(lintel, L.board, 3, { horizontal = true })
  for _, lx in ipairs({ 212, 268 }) do fill(rect(lx - 2, 72, lx + 1, 79), L.rope.base) for yy = 72, 79, 2 do hline(lx - 2, lx + 1, yy, L.rope.shade) end end
  thatchRoof(roof, 52, 240)
  line({ { 201, 73 }, { 239, 53 } }):each(function(x, y) if roof:has(x, y) then px(x, y, L.roof.hi) end end)
  part(gable, L.rope, { nopop = true }) weave(gable, L.rope, 21)
  -- crossed ridge poles
  line({ { 236, 54 }, { 244, 46 } }, 1):add(line({ { 244, 54 }, { 236, 46 } }, 1)):each(function(x, y) px(x, y, L.timber.deep) end)
  px(236, 46, L.timber.hi) px(244, 46, L.timber.hi)
  -- fronds and flowers draped over the eaves
  F.frond(204, 72, 2.2, 16, .9, L.foliage, 31, { wide = .3 })
  F.frond(276, 72, .95, 16, .9, L.foliage2, 32, { wide = .3 })
  for _, fl in ipairs({ { 222, 70, "hibiscus" }, { 231, 66, "plumeria" }, { 250, 66, "orange" }, { 258, 70, "white" }, { 240, 71, "hibiscus" } }) do F.flower(fl[1], fl[2], fl[3]) end
  float(240, 81, 1)
  -- shells strung on the right post, beach grass at the feet
  for k = 0, 3 do F.shell(272, 88 + k * 4, k % 2 == 0 and "cowrie" or "conch") end
  vline(272, 84, 101, L.rope.shade)
  for _, f in ipairs({ { 208, 124, 5 }, { 223, 125, 4 }, { 257, 124, 4 }, { 272, 125, 5 } }) do F.fern(f[1], f[2], f[3], L.mossGround) end
end
beachGate()

---------------------------------------------------------------- back left: two painted stilt huts (plane 1)
F.depth(1)
F.palm(84, 126, 40, L.foliage2, 2, { lean = -9 })
F.tree(8, 130, 36, 0)
do
  local top, cx, wall = F.building{ x0 = 19, x1 = 45, yb = 128, wh = 26, rh = 20, wall = L.wall2, roof = L.roof, noFrame = true, noAttic = true }
  F.planks(wall, L.wall2, 3, true, 36)
  hline(19, 45, top + 4, L.awnB.base)
  window(24, 108, 30, 114, L.awnB) door(34, 113, 41, 128, L.roof2)
  local stilts = rect(20, 129, 21, 134):add(rect(43, 129, 44, 134)):add(rect(31, 129, 32, 134))
  rimOf(stilts, L.timber) part(stilts, L.timber, { nopop = true, noshade = true })
  for y = 129, 134, 2 do hline(36, 39, y, L.board.base) end vline(36, 129, 134, L.board.shade) vline(39, 129, 134, L.board.shade)
  local top2, cx2, wall2, roof2 = F.building{ x0 = 52, x1 = 75, yb = 128, wh = 34, rh = 24, wall = L.pinkwash, roof = L.roof2, chimney = true, shingle = true, noFrame = true }
  roof2:each(function(x, y) if x % 3 == 0 then px(x, y, L.roof2.shade) elseif x % 3 == 1 and hash(x, y // 4, 37) < .5 then px(x, y, L.roof2.hi) end end) -- corrugated tin
  hline(52, 75, top2 + 4, L.wall2.base)
  shuttered(60, 100, 65, 106) shuttered(60, 114, 64, 120)
  door(68, 113, 73, 128, L.wall2)
  local st2 = rect(53, 129, 54, 134):add(rect(73, 129, 74, 134))
  rimOf(st2, L.timber) part(st2, L.timber, { nopop = true, noshade = true })
  F.hibiscus(48, 134, 4, 7, 35)
  F.smoke(66, 72, 6, .6, 2)
end

---------------------------------------------------------------- back right: bamboo notice board under thatch (plane 2)
F.depth(2)
F.tree(350, 134, 50, 4)
local function notice()
  local T = L.timber
  local roof = poly{ { 280, 61 }, { 313, 45 }, { 346, 61 }, { 346, 64 }, { 280, 64 } }
  local posts = rect(289, 64, 293, 136):add(rect(333, 64, 337, 136))
  local board = rect(287, 66, 339, 114)
  local bar = rect(286, 120, 340, 123)
  shadow(290, 338, 136, 10, 5)
  rimOf(union(roof, posts, board, bar), T)
  bambooPosts(posts)
  part(board, L.rope, { band = 2 })
  weave(board, L.rope, 61)
  hline(287, 339, 66, L.board.base) hline(287, 339, 114, L.board.shade) vline(287, 66, 114, L.board.hi) vline(339, 66, 114, L.board.shade)
  part(bar, L.board, { nopop = true }) F.bamboo(bar, L.board, 2, { horizontal = true })
  thatchRoof(roof, 45, 313)
  line({ { 281, 61 }, { 312, 46 } }):each(function(x, y) if roof:has(x, y) then px(x, y, L.roof.hi) end end)
  hline(280, 346, 64, L.roof.deep)
  local notes = { { 291, 70, 302, 83, L.awnB }, { 306, 71, 320, 81, L.shell }, { 324, 69, 335, 85, L.awnB },
                  { 292, 88, 305, 101, L.lagoon }, { 309, 86, 321, 105, L.awnB }, { 325, 90, 335, 100, L.gold },
                  { 296, 104, 306, 111, L.coral }, { 323, 103, 334, 111, L.awnB } }
  for _, n in ipairs(notes) do
    local m = rect(n[1], n[2], n[3], n[4])
    part(m, n[5], { nopop = true })
    c:edgeIn(m, n[5].deep)
    for y = n[2] + 3, n[4] - 2, 3 do hline(n[1] + 2, n[3] - 2 - (y % 4), y, n[5].shade) end
    px((n[1] + n[3]) // 2, n[2] + 1, L.awnA.base)
  end
  -- a pinned island map with a dotted route, a pressed frangipani, a tide chart
  fill(rect(311, 89, 318, 96), L.lagoon.base) fill(c:ellipse(314, 93, 2, 2), L.ground.hi) px(313, 92, L.foliage.base)
  for k = 0, 3 do px(312 + k * 2, 99 + (k % 2), L.awnA.base) end
  F.flower(298, 94, "plumeria")
  line({ { 326, 95 }, { 328, 93 }, { 330, 96 }, { 332, 93 }, { 334, 95 } }):each(function(x, y) px(x, y, L.sea.base) end)
  -- glass float lantern on the right post, a coconut-shell paste pot, a jungle fowl at its foot
  hline(337, 340, 70, T.deep) vline(340, 70, 72, T.deep)
  float(340, 73)
  local b = c:ellipse(304, 131, 4, 3):clip(rect(299, 129, 309, 135)) rimOf(b, L.coconut) part(b, L.coconut, { nopop = true })
  hline(301, 307, 129, L.awnB.base) vline(306, 122, 129, L.board.hi)
  F.hen(320, 136, L.hibiscus)
  -- quirk: a pelican in a red gnome hat, perched on the peak
  F.sprite({
    "..........R.....",
    ".........RRr....",
    "........RRRr....",
    ".......hhhhhh...",
    "........WWWW....",
    "........WeWWs...",
    "bbbbbbbbbWWs....",
    ".pppppPbbWWs....",
    "...ppP...WWWs...",
    "........WWWWWgg.",
    ".......WWWWWgggg",
    ".......WWWWggggg",
    "........WWWgggg.",
    ".........o..o...",
  }, 302, 32, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, W = L.awnB.hi, s = L.awnB.shade, e = L.timber.edge,
    b = L.gold.base, p = L.gold.shade, P = L.gold.deep, g = L.iron.base, o = L.gold.deep })
  px(310, 34, L.awnA.hi) px(309, 41, L.gold.hi) px(310, 37, L.awnB.base)
end
notice()

---------------------------------------------------------------- back right: the bamboo rest house (plane 2)
local function restHouse()
  local top, cx, wall, roofM = F.building{ x0 = 360, x1 = 456, yb = 136, wh = 46, rh = 26, wall = L.board, roof = L.roof, noFrame = true }
  F.bamboo(wall:copy():clip(rect(360, top + 4, 456, 136)), L.board, 3)
  hline(360, 456, top + 4, L.timber.base) hline(360, 456, top + 5, L.timber.deep)
  local foot = rect(360, 131, 456, 136)
  part(foot, L.lava, { nopop = true }) F.courses(foot, 131, 3, 8, L.lava)
  local gab = poly{ { 366, 89 }, { 408, 72 }, { 450, 89 } }:cut(rect(402, 76, 413, 86))
  weave(gab, L.rope, 60)
  -- a palm-thatch porch roof on bamboo posts
  local porch = poly{ { 356, 105 }, { 460, 105 }, { 463, 111 }, { 353, 111 } }
  rimOf(porch, L.roof) thatchRoof(porch, 105, 408)
  hline(356, 460, 105, L.roof.hi)
  local pp = rect(360, 112, 362, 135):add(rect(454, 112, 456, 135)):add(rect(397, 112, 398, 135))
  bambooPosts(pp)
  shuttered(372, 95, 378, 101) shuttered(440, 95, 446, 101)
  shuttered(422, 115, 428, 121)
  door(401, 112, 416, 135, L.wall2)
  local sign = rect(398, 85, 418, 91) rimOf(sign, L.timber) part(sign, L.board)
  F.sprite({ ".fff.", "ffffe", ".fff.", "f...." }, 401, 86, { f = L.lagoon.shade, e = L.timber.edge }, { rim = false })
  F.sprite({ ".b.b.", "bbbbb", ".bbb.", "..b.." }, 410, 86, { b = L.awnA.base }, { rim = false }) -- a heart: welcome
  float(420, 113)
  -- a hammock slung between the porch posts, tapa-striped, a gnome napping in it
  local function hy(x) local t = (x - 363) / 33 return floor(116 + 12 * t * (1 - t) + .5) end
  local ham = HP.mask()
  for x = 366, 393 do for y = hy(x), hy(x) + 3 do ham:set(x, y) end end
  local body, head, beard, hat, boots = HP.mask(), rect(368, hy(369) - 4, 371, hy(369) - 1), HP.mask(), HP.mask(), HP.mask()
  for x = 373, 388 do local hh = floor(4.5 * sin(pi * (x - 372) / 17)) for y = hy(x) - hh, hy(x) - 1 do body:set(x, y) end end
  for _, p in ipairs({ { 370, 0 }, { 371, 0 }, { 372, 0 }, { 372, 1 }, { 373, 1 }, { 371, 1 } }) do beard:set(p[1], hy(p[1]) - 1 - p[2]) end
  hat:add(poly{ { 367, hy(368) - 4 }, { 372, hy(368) - 4 }, { 364, hy(368) - 9 } })
  boots:add(rect(389, hy(389) - 3, 390, hy(389) - 1))
  rimOf(union(ham, body, head, beard, hat, boots), L.timber)
  line({ { 363, 116 }, { 366, hy(366) } }):each(function(x, y) px(x, y, L.rope.deep) end)
  line({ { 396, 116 }, { 393, hy(393) } }):each(function(x, y) px(x, y, L.rope.deep) end)
  part(body, L.leaf, { nopop = true }) body:each(function(x, y) if not body:has(x, y - 1) then px(x, y, L.leaf.hi) end end)
  fill(head, L.skin.base) px(368, hy(369) - 3, L.timber.edge) px(370, hy(369) - 2, L.skin.shade) px(369, hy(369) - 4, L.skin.hi)
  fill(beard, L.awnB.hi)
  part(hat, L.awnA, { nopop = true }) hline(367, 372, hy(368) - 4, L.awnA.deep)
  fill(boots, L.timber.base)
  ham:each(function(x, y)
    local k = (x - 366) // 4
    local h = ({ L.awnA.base, L.awnB.base, L.gold.base, L.awnB.base, L.accent.base })[k % 5 + 1]
    if y == hy(x) + 3 then h = L.timber.deep elseif y == hy(x) and not body:has(x, y - 1) then h = F.mix(h, "#fff4cc", .25) end
    px(x, y, h)
  end)
  -- a low table: teapot and coconut-shell cups
  local tbl = rect(426, 127, 446, 129):add(rect(428, 130, 429, 135)):add(rect(443, 130, 444, 135))
  local pot = poly{ { 431, 120 }, { 440, 120 }, { 442, 126 }, { 429, 126 } }
  local lid = rect(434, 118, 437, 119)
  rimOf(union(tbl, pot, lid), L.timber)
  part(tbl, L.board, { nopop = true }) part(pot, L.wall2) part(lid, L.wall2, { nopop = true })
  line({ { 442, 122 }, { 445, 119 } }):each(function(x, y) px(x, y, L.wall2.deep) end)
  px(428, 122, L.wall2.deep) px(427, 123, L.wall2.deep)
  hline(431, 440, 123, L.awnA.base)
  for _, cx2 in ipairs({ 446, 425 }) do local cup = c:ellipse(cx2, 126, 2, 1) fill(cup, L.coconut.base) px(cx2 - 1, 125, L.shell.hi) end
  -- hibiscus window boxes under the top windows
  for _, x in ipairs({ 368, 436 }) do
    hline(x, x + 14, 104, L.timber.base)
    for i = 0, 14, 2 do px(x + i, 103, (i % 4 == 0) and L.awnA.base or L.foliage2.base) px(x + i + 1, 102, L.foliage2.hi) end
  end
end
restHouse()

---------------------------------------------------------------- road side: conch mailbox, stacked goods, signpost (plane 2/3)
local function mailbox()
  local post = rect(208, 136, 209, 146)
  local sh = poly{ { 201, 131 }, { 205, 125 }, { 212, 123 }, { 218, 125 }, { 224, 128 }, { 219, 133 }, { 214, 136 }, { 205, 136 } }
  local knobs = HP.mask()
  for _, k in ipairs({ { 206, 123 }, { 210, 121 }, { 214, 122 }, { 218, 123 } }) do knobs:add(rect(k[1], k[2], k[1] + 1, k[2] + 1)) end
  local lip = poly{ { 198, 128 }, { 203, 124 }, { 206, 131 }, { 205, 137 }, { 199, 136 } }
  rimOf(union(post, sh, knobs, lip), L.timber)
  part(post, L.timber, { nopop = true })
  part(sh, L.shell)
  -- spiral whorls stepping toward the spire, brown banding, lit knobs
  sh:each(function(x, y)
    local h = L.shell.base
    if y >= 133 or (x > 219 and y > 128) then h = L.shell.shade elseif y <= 125 then h = L.shell.hi end
    if (x - y // 2) % 5 == 0 and x > 207 then h = L.coconut.base end
    if (x - y // 2) % 5 == 1 and x > 207 and y < 131 then h = L.shell.hi end
    if y == 136 then h = L.shell.deep end
    px(x, y, h)
  end)
  for k = 0, 2 do line({ { 210 + k * 4, 124 + k }, { 212 + k * 4, 135 - k * 2 } }):each(function(x, y) if sh:has(x, y) then px(x, y, L.shell.deep) end end) end
  fill(knobs, L.shell.hi) knobs:each(function(x, y) if (x % 2) == 1 then px(x, y, L.shell.shade) end end)
  part(lip, L.petal, { nopop = true }) lip:each(function(x, y) if x == 199 or y == 124 then px(x, y, L.petal.hi) end end)
  fill(poly{ { 201, 129 }, { 204, 128 }, { 204, 134 }, { 202, 135 } }, L.coral.shade)
  -- a letter in the mouth, red stamp
  local env = rect(197, 126, 203, 130) c:rim(env, L.timber.edge) fill(env, L.awnB.hi) px(202, 127, L.awnA.base) line({ { 197, 126 }, { 200, 128 }, { 203, 126 } }):each(function(x, y) px(x, y, L.awnB.shade) end)
  -- a hermit crab peeking out under it, and the flag
  F.crab(204, 142, L.hibiscus)
  fill(rect(225, 130, 227, 133), L.awnA.base) px(225, 130, L.awnA.hi) vline(224, 130, 140, L.timber.deep)
end
mailbox()
local function signpost()
  local post = rect(442, 152, 445, 176)
  local b1 = poly{ { 430, 155 }, { 434, 151 }, { 454, 151 }, { 458, 155 }, { 454, 159 }, { 434, 159 } }
  local b2 = poly{ { 432, 165 }, { 436, 162 }, { 452, 162 }, { 456, 165 }, { 452, 168 }, { 436, 168 } }
  rimOf(union(post, b1, b2), L.timber)
  part(post, L.timber, { nopop = true })
  part(b1, L.wall2) part(b2, L.coral)
  hline(436, 452, 155, L.wall2.deep) hline(438, 450, 165, L.coral.deep)
  px(434, 155, L.awnB.base) px(454, 165, L.awnB.base)
  F.flower(443, 149, "plumeria", true)
end
signpost()

F.depth(3)
-- stacked goods on the left verge: crates of mangoes and limes, a crate of coconuts, a sack of rice, a water jar
F.shadow(198, 222, 180, 8, 3)
F.crate(198, 180, 12, 9, mango)
F.crate(211, 180, 11, 9, lime)
F.crate(203, 170, 12, 8, L.coconut)
F.sprite({ ".mm.", "mmmm", ".mg." }, 202, 175, { m = mango.base, g = lime.base }, { rim = false })
F.sprite({ ".l.", "lll", ".l." }, 215, 175, { l = lime.shade }, { rim = false })
F.sprite({ ".c.", "ccc", ".c." }, 208, 165, { c = L.coconut.shade }, { rim = false })
F.sack(222, 182, L.awnB, 4)
F.shadow(200, 214, 204, 6, 2)
do
  local jarM = c:ellipse(206, 198, 6, 6):add(rect(203, 190, 209, 193))
  rimOf(jarM, L.soil) part(jarM, L.roof2)
  hline(201, 211, 197, L.roof2.deep) hline(203, 209, 190, L.roof2.hi) px(203, 195, L.roof2.hi) px(202, 196, L.roof2.hi)
  for x = 202, 210, 3 do px(x, 200, L.awnB.base) end
end
F.sack(216, 206, L.rope, 4)
-- right verge by the notice board: cane bundles and a heap of green coconuts
F.shadow(258, 284, 146, 6, 2)
for k = 0, 2 do
  local x = 264 + k * 7
  local m = poly{ { x - 3, 146 }, { x + 3, 146 }, { x + 1, 132 }, { x - 1, 132 } }
  rimOf(m, L.board) part(m, L.board, { nopop = true })
  m:each(function(xx, yy) if xx % 2 == 0 then px(xx, yy, L.board.shade) end if yy % 4 == 0 then px(xx, yy, L.board.deep) end end)
  hline(x - 2, x + 2, 140, L.rope.deep)
  px(x - 1, 131, L.leaf.hi) px(x + 1, 130, L.leaf.base) px(x, 131, L.leaf.shade) px(x + 2, 131, L.leaf.base)
end
for k = 0, 2 do F.coconut(281 + k * 5, 148, 2, true) end
F.coconut(283, 144, 2, true) F.coconut(288, 144, 2)

---------------------------------------------------------------- the giant coconut house (plane 3, replaces the haystack house)
local function coconutHouse()
  local m = c:ellipse(443, 202, 21, 22):clip(rect(400, 170, 490, 224))
  local pipe = rect(456, 176, 458, 184)
  shadow(426, 464, 224, 8, 3)
  rimOf(union(m, pipe), L.coconut)
  part(m, L.coconut)
  -- fibrous husk: short combed strands, lit upper-left, the dark right flank
  m:each(function(x, y)
    local dx, dy = (x - 443) / 21, (y - 202) / 22
    local h = L.coconut.base
    local lit = -(dx * .7 + dy * .7)
    if lit > .45 then h = L.coconut.hi elseif lit < -.4 then h = L.coconut.shade end
    if (x * 2 + y * 3) % 7 == 0 then h = lit > .2 and L.coconut.base or L.coconut.deep end
    if (x + y * 5) % 11 == 0 and lit > -.2 then h = L.palmTrunk.hi end
    if dx > .6 and hash(x, y, 66) < .3 then h = L.coconut.deep end
    px(x, y, h)
  end)
  -- the three coconut "eyes": two round windows and the arched door
  for _, w in ipairs({ { 434, 194 }, { 452, 194 } }) do
    local wm = c:ellipse(w[1], w[2], 3, 3)
    c:rim(wm, L.coconut.edge) fill(wm, L.glow.base) px(w[1] - 1, w[2] - 1, L.glow.hi) px(w[1] + 1, w[2] + 1, L.glow.shade)
    vline(w[1], w[2] - 3, w[2] + 3, L.coconut.deep) hline(w[1] - 3, w[1] + 3, w[2], L.coconut.deep)
    hline(w[1] - 3, w[1] + 3, w[2] + 5, L.foliage2.base) for k = -3, 3, 2 do px(w[1] + k, w[2] + 4, L.awnA.base) end
  end
  door(438, 207, 448, 223, L.wall2, true)
  part(pipe, L.iron, { nopop = true }) hline(455, 459, 176, L.iron.deep)
  -- a sprouting palm on top, sand banked round the foot
  F.palm(441, 182, 16, L.foliage, 70, { lean = -2, fronds = 6, nuts = false, dead = false })
  for x = 422, 464 do if hash(x, 1, 67) < .7 then px(x, 223, L.ground.hi) end if hash(x, 2, 67) < .4 then px(x, 222, L.ground.base) end end
  F.flower(426, 220, "hibiscus") F.flower(462, 221, "plumeria", true)
  F.shell(466, 226, "conch", true)
end
coconutHouse()

---------------------------------------------------------------- left: the coral-stone wishing well (plane 3)
local function well()
  local S, T = L.stone, L.timber
  local roofOuter = poly{ { 143, 92 }, { 196, 120 }, { 196, 126 }, { 90, 126 }, { 90, 120 } }
  local gable = poly{ { 143, 104 }, { 178, 121 }, { 108, 121 } }
  local roofM = roofOuter:copy():cut(gable)
  local postL, postR = rect(104, 126, 109, 156), rect(177, 126, 182, 156)
  local lipTop = poly{ { 98, 147 }, { 188, 147 }, { 194, 156 }, { 92, 156 } }
  local lipFront = rect(92, 156, 194, 165)
  local drum = poly{ { 97, 165 }, { 189, 165 }, { 191, 168 }, { 191, 204 }, { 187, 208 }, { 99, 208 }, { 95, 204 }, { 95, 168 } }
  local axle = rect(110, 130, 176, 133)
  local crank = rect(184, 130, 190, 133):add(rect(188, 133, 191, 143))
  local rope = rect(142, 134, 143, 140)
  local bucket = poly{ { 134, 141 }, { 152, 141 }, { 150, 153 }, { 136, 153 } }
  shadow(100, 192, 208, 14, 6)
  rimOf(union(roofOuter, postL, postR, lipTop, lipFront, drum, crank, axle, bucket), S)
  -- coral stone: rounded cream blocks with pores, a few black lava blocks, salt bloom near the foot
  part(drum, S) F.courses(drum, 165, 7, 13, S)
  drum:each(function(x, y)
    local row, col = (y - 165) // 7, (x + ((y - 165) // 7 % 2) * 6) // 13
    local ry = (y - 165) % 7
    if hash(col, row, 71) < .2 and ry ~= 0 and ((x + ((y - 165) // 7 % 2) * 6) % 13) ~= 0 then
      px(x, y, ry == 1 and L.lava.hi or (hash(x, y, 72) < .2 and L.lava.deep or L.lava.base))
    elseif hash(x, y, 73) < .07 then px(x, y, S.shade) if hash(x, y, 79) < .4 then px(x + 1, y, S.hi) end
    elseif hash(x, y, 80) < .008 then px(x, y, L.coral.base)
    elseif y > 198 and hash(x // 2, y, 74) < .25 then px(x, y, L.seagrass.base) end
  end)
  local u = drum:copy() u:each(function(x, y) if x > 182 and hash(x, y, 75) < .5 and not ((y - 165) % 7 == 0) then px(x, y, S.shade) end end)
  part(lipFront, L.lava, { sep = true }) F.courses(lipFront, 156, 10, 17, L.lava, 5)
  part(lipTop, L.lava, { sep = true })
  lipTop:each(function(x, y) if hash(x // 2, y, 76) < .2 then px(x, y, L.lava.hi) end end)
  local opening = poly{ { 106, 149 }, { 180, 149 }, { 184, 154 }, { 102, 154 } }
  fill(opening, L.lagoon.deep) hline(110, 178, 149, L.lava.edge) hline(118, 128, 152, L.lagoon.shade) hline(156, 170, 151, L.lagoon.shade)
  px(165, 152, L.glow.hi) px(166, 152, L.glow.base) px(124, 151, L.glow.base)
  bambooPosts(union(postL, postR))
  for _, py in ipairs({ 140, 150 }) do hline(103, 110, py, L.rope.base) hline(176, 183, py, L.rope.base) end
  part(axle, T, { nopop = true }) hline(110, 176, 130, T.hi)
  for x = 136, 150, 3 do vline(x, 131, 133, L.rope.base) end
  fill(rope, L.rope.base) part(crank, T, { nopop = true }) fill(rect(188, 140, 191, 143), L.wall2.base)
  -- a half-coconut bucket
  part(bucket, L.coconut)
  bucket:each(function(x, y) if (x * 2 + y) % 5 == 0 then px(x, y, L.coconut.deep) end end)
  line({ { 135, 141 }, { 143, 137 }, { 151, 141 } }):each(function(x, y) px(x, y, L.rope.deep) end)
  hline(137, 149, 142, L.lagoon.hi) hline(135, 151, 141, L.shell.hi)
  -- palm-thatch roof with a woven gable and bamboo king post
  thatchRoof(roofM, 92, 143)
  line({ { 91, 120 }, { 143, 93 } }):each(function(x, y) if roofM:has(x, y) then px(x, y, L.roof.hi) end end)
  hline(90, 196, 126, L.roof.edge) hline(91, 195, 125, L.roof.deep)
  for x = 92, 194, 3 do if hash(x, 1, 77) < .6 then px(x, 127, L.roof.shade) end end -- ragged eave
  part(gable, L.rope, { nopop = true }) weave(gable, L.rope, 78)
  vline(143, 106, 121, L.board.base) vline(144, 106, 121, L.board.shade)
  line({ { 143, 112 }, { 130, 120 } }):each(function(x, y) px(x, y, L.board.base) end)
  line({ { 143, 112 }, { 156, 120 } }):each(function(x, y) px(x, y, L.board.base) end)
  -- a scarlet macaw on the ridge
  F.parrot(143, 81, "macaw")
  vline(142, 92, 96, L.awnA.shade) vline(143, 92, 95, "#3c78c8")
  -- beach grass at the drum foot, shells set in the mortar
  for _, f in ipairs({ { 98, 208, 7 }, { 106, 210, 5 }, { 188, 208, 6 } }) do F.fern(f[1], f[2], f[3], L.mossGround) end
  for i = 0, 10 do local x, y = 99 + floor(hash(i, 1, 41) * 86), 168 + floor(hash(i, 2, 41) * 34) F.shell(x, y, i % 3 == 0 and "scallop" or "cowrie") end
  c:sparkle(176, 160)
end
well()
-- a giant clam full of wish coins before the well
do
  local clam = poly{ { 158, 214 }, { 162, 207 }, { 168, 204 }, { 176, 204 }, { 182, 207 }, { 186, 214 } }
  local lipM = rect(160, 213, 184, 215)
  shadow(160, 186, 215, 6, 2)
  rimOf(union(clam, lipM), L.shell)
  part(clam, L.shell, { nopop = true })
  clam:each(function(x, y) if (x - 172) % 4 == 0 then px(x, y, L.shell.shade) elseif (x - 172) % 4 == 1 and y < 209 then px(x, y, L.shell.hi) end end)
  fill(lipM, urchin.base) lipM:each(function(x, y) if hash(x, y, 5) < .4 then px(x, y, tuna.base) end end) hline(160, 184, 213, urchin.hi)
  for _, p in ipairs({ { 165, 211 }, { 170, 210 }, { 175, 211 }, { 179, 210 }, { 168, 212 } }) do px(p[1], p[2], L.gold.base) px(p[1] + 1, p[2], L.gold.hi) end
  c:sparkle(181, 207)
end

---------------------------------------------------------------- left: the Shell Swap hut (plane 3)
local function shellShop()
  local top, cx, wall, roofM = F.building{ x0 = 19, x1 = 75, yb = 212, wh = 42, rh = 16, wall = L.board, roof = L.roof, noFrame = true, noAttic = true }
  F.bamboo(wall:copy():clip(rect(19, top + 4, 75, 212)), L.board, 3)
  hline(19, 75, top + 4, L.timber.base)
  F.frond(cx, top - 16, -2.6, 10, .6, L.foliage, 79, { wide = .3 }) F.frond(cx, top - 16, -.5, 10, .6, L.foliage2, 80, { wide = .3 })
  -- shop window full of shells
  fill(rect(23, 183, 71, 199), L.timber.deep) fill(rect(24, 184, 70, 198), L.glow.shade)
  fill(rect(24, 184, 70, 187), L.glow.base)
  hline(24, 70, 191, L.timber.base) hline(24, 70, 198, L.timber.base)
  local kinds = { "conch", "scallop", "cowrie" }
  for i = 0, 7 do F.shell(27 + i * 6, 189, kinds[i % 3 + 1], i % 2 == 0) end
  for i = 0, 6 do
    local x = 28 + i * 6
    if i % 2 == 0 then
      local m = c:ellipse(x, 195, 2, 2) fill(m, ({ L.coral, L.shell, L.petal, urchin })[i // 2 + 1].base) px(x - 1, 194, L.awnB.hi)
    else F.coral(x, 197, 4, L.coral) end
  end
  -- strings of shells hanging in the window top
  for _, sx in ipairs({ 30, 48, 64 }) do for k = 0, 2 do px(sx, 185 + k * 2, L.shell.hi) px(sx, 186 + k * 2, L.rope.shade) end end
  -- striped awning: turquoise and cream
  local aw = poly{ { 18, 182 }, { 22, 174 }, { 72, 174 }, { 76, 182 } }
  for x = 18, 76, 4 do aw:add(poly{ { x, 182 }, { x + 4, 182 }, { x + 2, 185 } }) end
  aw:clip(rect(17, 170, 77, 186))
  rimOf(aw, L.accent)
  stripes(aw, 18, 4, L.accent, L.awnB)
  hline(22, 72, 174, L.awnB.hi)
  -- hanging sign: a scallop shell
  vline(30, 168, 170, L.rope.deep) vline(40, 168, 170, L.rope.deep)
  local sg = rect(28, 160, 42, 167) rimOf(sg, L.timber) part(sg, L.timber)
  F.sprite({ ".ccc.", "ccCcc", "cCcCc", ".ccc.", "..c.." }, 33, 161, { c = L.coral.base, C = L.coral.hi }, { rim = false })
  door(26, 200, 32, 211, L.wall2)
  -- a bin of rolled pandanus mats
  local bin = rect(48, 202, 72, 211) rimOf(bin, L.timber) part(bin, L.timber) F.planks(bin, L.timber, 3, false, 81)
  for i = 0, 4 do
    local x = 50 + i * 5
    local hgt = 10 + (i % 2) * 3
    local roll = rect(x, 202 - hgt, x + 3, 202)
    rimOf(roll, L.rope) fill(roll, L.rope.base) vline(x, 202 - hgt, 202, L.rope.hi) vline(x + 3, 202 - hgt, 202, L.rope.shade)
    for y = 202 - hgt + 2, 202, 3 do hline(x, x + 3, y, L.rope.shade) end
    local endm = rect(x, 202 - hgt, x + 3, 202 - hgt + 1) fill(endm, L.rope.hi) px(x + 1, 202 - hgt, L.rope.deep)
    if i % 2 == 1 then hline(x, x + 3, 202 - hgt + 4, L.awnA.base) else hline(x, x + 3, 202 - hgt + 4, L.accent.base) end
  end
end
shellShop()
F.fern(22, 214, 6, L.mossGround) F.fern(80, 212, 6)

---------------------------------------------------------------- right hero: the fruit stall (plane 3)
local function stall()
  local T = L.timber
  local roof = poly{ { 286, 168 }, { 300, 150 }, { 400, 150 }, { 414, 168 } }
  local val = rect(289, 167, 411, 172)
  for x = 289, 405, 8 do val:add(poly{ { x, 172 }, { x + 8, 172 }, { x + 4, 177 } }) end
  val:clip(rect(289, 166, 411, 177))
  local posts = rect(295, 177, 299, 224):add(rect(401, 177, 405, 224))
  local back = rect(300, 177, 400, 195)
  local ctop = poly{ { 299, 194 }, { 401, 194 }, { 404, 199 }, { 296, 199 } }
  local cfront = rect(296, 199, 404, 220)
  local legs = rect(300, 221, 304, 225):add(rect(396, 221, 400, 225))
  shadow(296, 406, 224, 14, 5)
  rimOf(union(roof, val, posts, back, ctop, cfront, legs), T)
  bambooPosts(posts)
  -- back wall: a woven mat with two bamboo shelves of bottles and jars
  part(back, L.rope, { nopop = true }) weave(back, L.rope, 82)
  back:each(function(x, y) if y > 186 then px(x, y, F.mix(c:get(x, y) or L.rope.base, L.rope.deep, .3)) end end)
  hline(301, 399, 186, L.board.base) hline(301, 399, 187, L.board.deep) hline(301, 399, 193, L.board.base)
  for i = 0, 15 do
    local x = 303 + i * 6
    if x < 342 or x > 362 then
      if i % 2 == 0 then bottle(x, 185, ({ L.glow, lime, L.awnB, glass })[i // 2 % 4 + 1]) else jar(x, 185, ({ mango, L.gold, L.apple })[i % 3 + 1], L.awnA) end
      if i % 3 ~= 1 then jar(x + 1, 192, ({ L.gold, mango, lime, L.coral })[i % 4 + 1], L.awnB) end
    end
  end
  -- the stallkeeper behind the counter, a hibiscus in the hat band
  F.gnome(352, 202, { hat = L.awnA, coat = L.wall2, arm = "up", noShadow = true })
  F.flower(347, 187, "orange", true)
  -- palm-thatch roof + red/gold valance
  thatchRoof(roof, 150, 350)
  line({ { 287, 167 }, { 300, 151 } }):each(function(x, y) if roof:has(x, y) then px(x, y, L.roof.hi) end end)
  hline(300, 400, 150, L.roof.hi)
  stripes(val, 289, 8, L.awnA, L.gold)
  hline(289, 411, 167, L.awnA.deep)
  -- sign on the ridge, the wares painted on: mango, coconut, banana, fish, shell
  local sign = rect(330, 142, 370, 149)
  rimOf(sign, T) part(sign, L.awnB) hline(331, 369, 149, L.awnB.shade)
  F.sprite({ ".mm.", "mmmm", ".gm." }, 333, 144, { m = mango.base, g = lime.base }, { rim = false })
  F.sprite({ ".c.", "ccc", ".c." }, 340, 144, { c = L.coconut.base }, { rim = false })
  F.sprite({ "y..", "yy.", ".yy" }, 346, 144, { y = L.gold.shade }, { rim = false })
  F.sprite({ "s.ss", "ssss", "s.ss" }, 352, 144, { s = tuna.base }, { rim = false })
  F.sprite({ ".c.", "ccc", "c.c" }, 360, 144, { c = L.coral.base }, { rim = false })
  vline(336, 150, 150, T.deep) vline(364, 150, 150, T.deep)
  -- a lory perched on the sign
  F.parrot(366, 131, "lory", true)
  -- hanging under the valance: glass floats, hands of bananas, a shell wind chime
  float(304, 179, 1)
  float(396, 179, 1)
  hline(310, 336, 178, L.board.deep)
  for k = 0, 3 do bananas(313 + k * 7, 179) end
  hline(366, 388, 178, L.board.deep)
  for k = 0, 4 do vline(368 + k * 5, 179, 181 + (k % 2) * 2, L.rope.shade) F.shell(368 + k * 5, 183 + (k % 2) * 2, k % 2 == 0 and "cowrie" or "scallop") end
  -- counter: bamboo canes, plank top
  part(cfront, L.board) F.bamboo(cfront, L.board, 3)
  for x = 296, 404, 27 do vline(x, 200, 220, L.timber.base) end
  hline(296, 404, 205, L.rope.shade) hline(296, 404, 214, L.rope.shade)
  part(ctop, T) hline(299, 401, 194, T.hi) F.planks(ctop, T, 6, true, 83)
  part(legs, T, { nopop = true })
  -- goods on the counter
  basket(300, 320, 198, 5, mango, "mango", 84)
  basket(322, 340, 198, 5, lime, "round", 85)
  basket(364, 384, 198, 5, L.apple, "hairy", 86)
  -- a split papaya and a coconut with a straw on a leaf
  hline(342, 362, 198, L.foliage.shade) hline(343, 361, 197, L.foliage.base)
  local pap = c:ellipse(346, 195, 4, 2) rimOf(pap, mango) fill(pap, mango.shade) fill(c:ellipse(346, 195, 2, 1), L.awnA.shade) px(345, 195, L.timber.edge) px(347, 195, L.timber.edge)
  F.coconut(357, 195, 3, true) vline(358, 189, 192, L.awnA.base) px(359, 189, L.awnA.base)
  for k = 0, 2 do bottle(387 + k * 5, 198, ({ L.glow, lime, L.awnB })[k + 1]) end
  -- crates in front: coconuts, pineapples
  local cr1 = rect(308, 210, 332, 222) rimOf(cr1, T) part(cr1, L.timber) F.planks(cr1, L.timber, 4, false, 87)
  for k = 0, 4 do F.coconut(311 + k * 5, 208, 2, k % 2 == 1) end
  local cr2 = rect(362, 210, 386, 222) rimOf(cr2, T) part(cr2, L.board) F.bamboo(cr2, L.board, 3, { horizontal = true }) vline(374, 210, 222, L.board.deep)
  for k = 0, 3 do
    local x = 366 + k * 6
    local pm = c:ellipse(x, 207, 2, 3) rimOf(pm, pine) fill(pm, pine.base)
    pm:each(function(xx, yy) if (xx + yy) % 2 == 0 then px(xx, yy, pine.shade) end end) px(x - 1, 206, pine.hi)
    px(x - 1, 202, L.seagrass.base) px(x, 201, L.seagrass.hi) px(x + 1, 202, L.seagrass.shade) px(x, 203, L.seagrass.base)
  end
  -- a bunch of green bananas leaning on the leg
  F.sprite({ ".tt..", "lLlLl", "lLlLl", ".lLl.", ".lLl." }, 388, 216, { t = L.foliage2.shade, l = lime.base, L = lime.hi })
end
stall()
basket(410, 426, 224, 5, mango, "mango", 90)
basket(414, 430, 214, 5, L.apple, "hairy", 91)
-- a shopper with a basket of mangoes, by the stall
local _, shx, shy = F.gnome(284, 228, { hat = L.roof2, coat = L.coral, arm = "out", flip = true })
local bk = poly{ { shx - 3, shy }, { shx + 3, shy }, { shx + 2, shy + 5 }, { shx - 2, shy + 5 } }
rimOf(bk, L.timber) part(bk, L.rope, { nopop = true })
px(shx - 1, shy - 1, mango.base) px(shx, shy - 1, mango.hi) px(shx + 1, shy - 1, lime.base)
line({ { shx - 3, shy }, { shx, shy - 3 }, { shx + 3, shy } }):each(function(x, y) if y < shy then px(x, y, L.timber.deep) end end)

---------------------------------------------------------------- bottom: the woven-goods table under a striped canopy (plane 3)
local function wovenTable()
  local can = poly{ { 120, 233 }, { 128, 222 }, { 180, 222 }, { 188, 233 } }
  for x = 120, 186, 4 do can:add(poly{ { x, 233 }, { x + 4, 233 }, { x + 2, 236 } }) end
  can:clip(rect(120, 222, 188, 236))
  local posts = rect(123, 236, 125, 262):add(rect(183, 236, 185, 262))
  local top = poly{ { 131, 243 }, { 177, 243 }, { 181, 249 }, { 127, 249 } }
  local cloth = rect(127, 249, 181, 254)
  local legs = rect(129, 255, 131, 261):add(rect(177, 255, 179, 261))
  shadow(124, 186, 262, 8, 3)
  rimOf(union(can, posts, top, cloth, legs), L.timber)
  bambooPosts(posts)
  stripes(can, 120, 4, L.hibiscus, L.awnB)
  hline(128, 180, 222, L.awnB.hi)
  part(legs, L.timber, { nopop = true })
  part(top, L.rope) weave(top, L.rope, 88)
  tapa(cloth, 127, 249)
  for x = 127, 181, 3 do px(x, 254, L.coconut.shade) end
  -- hanging from the canopy: two fans and a plumeria lei
  for _, fx in ipairs({ 136, 172 }) do
    local fan = poly{ { fx - 3, 237 }, { fx + 3, 237 }, { fx, 241 } } fill(fan, L.rope.hi) px(fx, 240, L.rope.shade) px(fx - 2, 237, L.rope.base) px(fx + 2, 237, L.rope.shade) vline(fx, 236, 236, L.rope.deep)
  end
  for k = 0, 8 do px(145 + k * 2, 237 + floor(2 * sin(k / 8 * pi) + .5), k % 2 == 0 and L.petal.base or L.shell.hi) end
  -- on the table: a stack of folded mats, rolled mats, a woven sun hat, a basket
  local stack = rect(133, 238, 145, 243)
  rimOf(stack, L.rope) for y = 238, 243 do hline(133, 145, y, (y % 2 == 0) and L.rope.hi or ((y == 239 or y == 243) and L.rope.shade or L.awnA.base)) end
  hline(133, 145, 240, L.accent.base)
  for k = 0, 1 do local r = rect(149, 240 - k * 2, 159, 241 - k * 2) rimOf(r, L.rope) fill(r, L.rope.base) hline(149, 159, 240 - k * 2, L.rope.hi) px(159, 240 - k * 2, L.rope.deep) end
  local hat = poly{ { 162, 244 }, { 176, 244 }, { 173, 242 }, { 171, 239 }, { 167, 239 }, { 165, 242 } }
  rimOf(hat, L.rope) part(hat, L.needle, { nopop = true }) weave(hat, L.needle, 89) hline(166, 172, 242, L.awnA.base)
end
wovenTable()

---------------------------------------------------------------- bottom left: a tide pool and a beached outrigger selling fish on ice (plane 3)
local function tidePool()
  local bank = poly{ { 14, 240 }, { 24, 230 }, { 50, 227 }, { 64, 232 }, { 68, 244 }, { 58, 256 }, { 30, 260 }, { 14, 254 } }
  local water = bank:shrink(3)
  shadow(18, 66, 258, 4, 2)
  rimOf(bank, L.lava)
  bank:each(function(x, y) if not water:has(x, y) then local v = hash(x, y, 51) px(x, y, v < .45 and L.lava.base or (v < .65 and L.lava.hi or (v < .8 and L.lava.shade or L.ground.hi))) end end)
  F.water(water, L.lagoon)
  -- sea life under the clear water: a starfish, an urchin, an anemone, sea grass
  F.sprite({ "..s..", "..s..", "sssss", ".sSs.", "s...s" }, 28, 242, { s = starR.base, S = starR.hi })
  local u = c:ellipse(48, 248, 2, 2) fill(u, urchin.deep)
  for _, d in ipairs({ { -3, 0 }, { 3, 0 }, { 0, -3 }, { -2, -2 }, { 2, -2 }, { -2, 2 }, { 2, 2 } }) do px(48 + d[1], 248 + d[2], urchin.base) end
  px(47, 247, urchin.hi)
  for k = 0, 3 do px(54 + k, 238 - (k % 2), L.petal.base) px(54 + k, 239, L.petal.shade) end px(55, 236, L.petal.hi)
  for k = 0, 3 do vline(22 + k * 3, 249 - k % 2, 252, L.seagrass.shade) end
  F.crab(60, 236, L.awnA, true)
  -- lava rocks on the rim
  F.lavaRock(16, 238, 6, 5, 53) F.lavaRock(66, 258, 6, 5, 54)
end
tidePool()
local function canoe()
  -- the canoe hauled up on the sand, its hull heaped with crushed ice and the morning catch
  F.shadow(66, 116, 252, 6, 3)
  local heap = poly{ { 68, 245 }, { 72, 236 }, { 84, 230 }, { 100, 230 }, { 110, 236 }, { 114, 245 } }
  rimOf(heap, ice)
  part(heap, ice, { nopop = true })
  heap:each(function(x, y) local v = hash(x // 2, y, 55) if v < .3 then px(x, y, ice.hi) elseif v > .8 then px(x, y, ice.shade) end if (x + y) % 5 == 0 and hash(x, y, 56) < .3 then px(x, y, ice.base) end end)
  fishSide(73, 232, L.coral, false)
  fishSide(92, 230, tuna, true)
  fishSide(96, 237, L.accent, false)
  fishSide(76, 238, L.iron, true)
  for _, l in ipairs({ { 89, 238 }, { 108, 242 } }) do px(l[1], l[2], lime.hi) px(l[1] + 1, l[2], lime.base) px(l[1], l[2] + 1, lime.shade) px(l[1] + 1, l[2] + 1, L.awnB.hi) end
  F.outrigger(66, 114, 248, { side = 1, stripe = L.awnA, hull = L.timber })
  -- a paddle leaning, a chalked slate: FISH, a bucket of ice
  line({ { 112, 230 }, { 118, 254 } }):each(function(x, y) px(x, y, L.board.shade) end)
  local blade = poly{ { 116, 248 }, { 120, 248 }, { 120, 257 }, { 118, 259 }, { 116, 257 } } rimOf(blade, L.timber) part(blade, L.board, { nopop = true }) px(118, 252, L.awnA.base)
  local slate = rect(58, 262, 70, 268) rimOf(slate, L.timber) fill(slate, L.lava.shade)
  F.sprite({ "aa.a.aa.a.a", "a..a.a..aaa", "aa.a..a.a.a", "a..a.aa.a.a" }, 59, 263, { a = L.awnB.base }, { rim = false })
  local bucket = rect(104, 256, 111, 263) rimOf(bucket, L.timber) part(bucket, L.timber, { nopop = true }) hline(104, 111, 256, ice.hi) px(106, 255, ice.base) px(108, 255, ice.hi)
  hline(104, 111, 259, L.iron.shade)
end
canoe()

---------------------------------------------------------------- bottom right: pineapple patch (plane 3)
local function pineBed()
  local soil = poly{ { 304, 247 }, { 368, 247 }, { 374, 254 }, { 298, 254 } }
  local front = rect(298, 254, 374, 262)
  local back = rect(304, 245, 368, 247)
  shadow(300, 374, 262, 8, 2)
  rimOf(union(soil, front, back), L.lava)
  part(back, L.lava, { nopop = true })
  fill(soil, L.soil.base) soil:each(function(x, y) if hash(x, y, 71) < .2 then px(x, y, L.soil.deep) elseif hash(x, y, 72) < .1 then px(x, y, L.needle.base) end end)
  part(front, L.lava) F.courses(front, 254, 4, 9, L.lava)
  front:each(function(x, y) if hash(x, y, 73) < .08 then px(x, y, L.lava.deep) end end)
  for _, x in ipairs({ 312, 336, 360 }) do -- pineapple plants: spiky rosettes, a little fruit on a stalk
    local leaves = HP.mask()
    for _, tp in ipairs({ { -9, -3 }, { -6, -8 }, { -2, -11 }, { 3, -10 }, { 7, -7 }, { 9, -2 } }) do leaves:add(poly{ { x - 1, 251 }, { x + 1, 251 }, { x + tp[1], 251 + tp[2] } }) end
    rimOf(leaves, L.seagrass) part(leaves, L.seagrass, { nopop = true })
    for _, tp in ipairs({ { -9, -3 }, { -6, -8 }, { 7, -7 } }) do line({ { x, 250 }, { x + tp[1], 251 + tp[2] } }):each(function(xx, yy) px(xx, yy, tp[1] < 0 and L.seagrass.hi or L.seagrass.shade) end) end
    local fr = c:ellipse(x, 240, 2, 3) rimOf(fr, pine) fill(fr, pine.base) fr:each(function(xx, yy) if (xx + yy) % 2 == 0 then px(xx, yy, pine.shade) end end) px(x - 1, 239, pine.hi)
    px(x, 236, L.seagrass.hi) px(x - 1, 235, L.seagrass.base) px(x + 1, 235, L.seagrass.shade)
  end
  for _, x in ipairs({ 324, 348 }) do -- taro: heart-shaped leaves
    local lf = poly{ { x - 5, 242 }, { x, 238 }, { x + 5, 242 }, { x, 247 } }
    rimOf(lf, L.foliage2) part(lf, L.foliage2, { nopop = true }) line({ { x, 239 }, { x, 246 } }):each(function(xx, yy) px(xx, yy, L.foliage2.hi) end)
    vline(x, 248, 251, L.foliage2.shade)
  end
  -- a coconut-shell scoop on a stick
  fill(rect(371, 236, 372, 246), L.timber.base)
  local sc = c:ellipse(372, 247, 2, 1) fill(sc, L.coconut.base) px(371, 247, L.coconut.hi)
end
pineBed()

---------------------------------------------------------------- near beach grass, flowers, shells, sky life
for _, f in ipairs({ { 112, 262, 7 }, { 192, 262, 8 }, { 200, 250, 6 }, { 290, 260, 7 }, { 376, 226, 6 }, { 196, 226, 6 } }) do F.fern(f[1], f[2], f[3], (f[1] % 2 == 0) and L.mossGround or nil) end
F.hibiscus(204, 266, 7, 10, 93)
F.shell(208, 238, "conch", true) F.shell(292, 236, "scallop", true) F.shell(196, 256, "cowrie")
F.flower(286, 250, "plumeria") F.flower(196, 244, "orange", true)
F.crab(214, 252, L.hibiscus, true)
F.depth(0)
F.birds({ { 300, 22, 2 }, { 310, 28, 1 }, { 120, 60, 2 }, { 418, 44, 1 }, { 190, 30, 3 } })

F.finish()
