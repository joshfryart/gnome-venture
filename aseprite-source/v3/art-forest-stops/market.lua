-- market.lua : "Market hamlet" stop look, FOREST (forest_pinewood), 480x270 gate view.
-- Same composition and hotspots as the Maplewold market (here-gate/pilot-market.lua), re-cast as a woodland market:
-- road's end: the Wild Trail, a mossy-stone arch under a bough-heaped log lintel, a lantern, a path into the deep wood.
-- Back left: two log cottages with smoke. Back right: a roofed log notice board (an owl carved on the peak) and the log
-- rest lodge with its porch bench, patchwork quilt and teapot. Left: the giant mossy wishing well with a bark-shingle
-- roof, and the Seed Swap log shop (cone and seed jars, a crate of pine saplings). Right hero: the trader stall: log
-- posts, mossy shingle roof, red-and-cream valance, baskets of chanterelles, lingonberries and bilberries, honey jars,
-- smoked fish, herb bundles, a gnome stallkeeper. Stacked goods along the road. Bottom: the fishing pond with a jetty,
-- the long table under a striped canopy (bilberry pie, honey pot), the forage bed of mushrooms and bilberry bushes.
-- Quirks kept from Maplewold, in forest dress: the teapot-hatted scarecrow, the barrow growing something too big
-- (here a giant fly agaric), the snail mailbox (a mossy snail), and the haystack house as a hollow stump house.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-forest-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "market", out = DIR, treeLineGap = { 204, 276 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local courses, shadow, window, door = F.courses, F.shadow, F.window, F.door
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs

-- local ramps for market goods
local blueb = F.rp("#a8b4e0 #6c78b8 #4e5894 #383e6e #242a4a") -- bilberries
local honey = F.rp("#ffe08a #f2b440 #d08a2a #9c6424 #643e1e")
local smoke = F.rp("#e6b878 #c08548 #94603a #6a422e #42281e") -- smoked fish

---------------------------------------------------------------- local helpers
local function hjar(x, yb, r, lidR) -- little jar 4 wide, 6 tall, cloth lid
  local m = rect(x, yb - 5, x + 3, yb)
  rimOf(m, L.timber)
  fill(m, r.base) vline(x, yb - 4, yb, r.hi) vline(x + 3, yb - 4, yb, r.shade) hline(x, x + 3, yb, r.deep)
  hline(x, x + 3, yb - 5, (lidR or L.awnB).base) px(x + 1, yb - 5, (lidR or L.awnB).hi)
  px(x + 1, yb - 3, "#f6f2d8")
  return m
end
local function basket(x0, x1, yb, h, r, kind, seed) -- woven basket heaped with goods
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
    if kind == "berry" then -- 2x2 round berries: lit upper-left dot, dark gaps
      local bx, by = (x + (y // 2) % 2) % 2, y % 2
      if bx == 0 and by == 0 then px(x, y, r.hi) elseif bx == 1 and by == 1 then px(x, y, r.deep) end
    elseif kind == "chant" then -- frilly chanterelle caps
      local v = hash(x // 2, y, seed)
      if v < .25 then px(x, y, r.hi) elseif v > .82 then px(x, y, r.shade) end
      if (x + y) % 4 == 0 and hash(x, y, seed + 1) < .5 then px(x, y, r.deep) end
    else
      local v = hash(x, y, seed) if v < .18 then px(x, y, r.hi) elseif v > .85 then px(x, y, r.deep) end
    end
  end)
  -- a few leaves tucked in
  px(x0 + 3, yb - h - 3, L.leaf.base) px(x0 + 4, yb - h - 4, L.leaf.hi) px(x1 - 4, yb - h - 2, L.leaf.shade)
  return body
end
local function fish(x, y) -- a smoked fish hanging head-down, 3 wide, 8 tall
  F.sprite({ ".t.", "ttt", "sbs", "sbs", "sbs", "sbS", ".s.", ".h." }, x, y,
    { t = smoke.deep, s = smoke.base, b = smoke.hi, S = smoke.shade, h = honey.hi })
end
local function herbs(x, y, r) -- a drying herb bundle tied with string
  vline(x + 1, y - 2, y, L.board.deep)
  F.sprite({ ".b.", "bBb", "BbB", "bBb", "BBb", "b.b" }, x, y + 1, { b = r.shade, B = r.base })
  px(x + 1, y + 2, r.hi) hline(x, x + 2, y + 1, L.awnA.shade)
end
local function lantern(x, y, cord) -- little hanging lantern, top at y
  if cord then vline(x, y - cord, y - 1, L.timber.edge) end
  local l = rect(x - 2, y + 1, x + 2, y + 6)
  local cap = rect(x - 2, y, x + 2, y)
  rimOf(union(l, cap), L.timber)
  fill(l, L.glow.base) px(x - 2, y + 1, L.glow.hi) px(x - 1, y + 1, L.glow.hi) vline(x + 2, y + 2, y + 6, L.glow.shade)
  hline(x - 2, x + 2, y, L.timber.base) hline(x - 1, x + 1, y + 6, L.timber.deep)
end
local function stripes(m, x0, w, rA, rB)
  m:each(function(x, y) px(x, y, ((x - x0) // w) % 2 == 0 and rA.base or rB.base) end)
  m:each(function(x, y) if not m:has(x, y + 1) then px(x, y, (((x - x0) // w) % 2 == 0 and rA or rB).shade) end end)
  m:each(function(x, y) if ((x - x0) % w) == 0 and m:has(x, y + 1) and ((x - x0) // w) % 2 == 0 then px(x, y, rA.hi) end end)
end
local function logPosts(m) -- round log posts: lit left, dark right, bark rings
  rimOf(m, L.timber)
  part(m, L.timber, { nopop = true, noshade = true })
  m:each(function(x, y)
    if not m:has(x - 1, y) then px(x, y, L.timber.hi)
    elseif not m:has(x + 1, y) then px(x, y, L.timber.shade) end
    if hash(x, y // 3, 88) < .12 then px(x, y, L.timber.deep) end
  end)
end

---------------------------------------------------------------- far quirks (plane 1): scarecrow + fly-agaric barrow
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
  part(post, t, { nopop = true })
  part(shirt, L.fern)
  shirt:each(function(x, y) if x % 4 == 0 or y % 4 == 1 then px(x, y, L.fern.shade) end end) -- plaid
  part(head, L.awnB) px(107, 73, t.deep) px(110, 73, t.deep) hline(107, 110, 76, t.shade)
  part(hat, L.roof2) part(lid, L.roof2) fill(spout, L.roof2.shade)
  px(102, 69, L.roof2.deep) px(101, 68, L.roof2.deep)
  -- straw tufts at cuffs and hem, needle-coloured
  for _, p in ipairs({ { 99, 82 }, { 118, 82 }, { 103, 93 }, { 108, 93 }, { 113, 93 } }) do px(p[1], p[2], L.gold.base) px(p[1], p[2] + 1, L.gold.shade) end
  -- a jay perched on the arm
  F.sprite({ ".jj", "jJJk", ".JJk", "..o." }, 112, 76, { j = "#cfa08a", J = "#b88a76", k = "#3a3036", o = L.timber.deep })
  px(114, 78, "#6a9ed8")
end
scarecrow()
local function barrow()
  local t = L.timber
  local tray = poly{ { 160, 92 }, { 184, 92 }, { 180, 100 }, { 163, 100 } }
  local handles = line({ { 160, 94 }, { 152, 98 } }):add(line({ { 166, 100 }, { 164, 104 } }))
  local wheel = poly{ { 180, 98 }, { 186, 98 }, { 188, 101 }, { 186, 104 }, { 180, 104 }, { 178, 101 } }
  local stem = poly{ { 168, 92 }, { 176, 92 }, { 175, 56 }, { 169, 56 } }
  local ring = poly{ { 166, 70 }, { 178, 70 }, { 177, 74 }, { 167, 74 } }
  local cap = poly{ { 148, 58 }, { 152, 48 }, { 160, 41 }, { 172, 38 }, { 184, 41 }, { 192, 48 }, { 196, 58 }, { 186, 60 }, { 158, 60 } }
  rimOf(union(tray, handles, wheel, stem, ring, cap), t)
  part(handles, t, { nopop = true }) part(tray, t) part(wheel, L.stone, { nopop = true })
  part(stem, L.awnB, { nopop = true })
  stem:each(function(x, y) if x == 169 then px(x, y, L.awnB.hi) elseif x >= 174 then px(x, y, L.awnB.shade) end end)
  part(ring, L.awnB, { nopop = true }) hline(167, 177, 74, L.awnB.shade)
  part(cap, L.apple)
  cap:each(function(x, y) if (x - 172) * .6 + (y - 38) < 6 and x < 172 then px(x, y, L.apple.hi) end end)
  hline(150, 194, 59, L.apple.deep) hline(158, 186, 60, L.awnB.shade) -- gills
  for _, d in ipairs({ { 158, 47 }, { 168, 42 }, { 180, 44 }, { 188, 51 }, { 164, 52 }, { 176, 50 }, { 154, 55 } }) do
    fill(rect(d[1], d[2], d[1] + 1, d[2] + 1), L.awnB.base) px(d[1], d[2], L.awnB.hi)
  end
  -- moss in the barrow tray, little mushrooms at its rim
  hline(162, 182, 93, L.moss.base) hline(163, 181, 94, L.moss.shade)
  F.mushroom(162, 92, L.needle) F.mushroom(182, 92, L.apple)
end
barrow()

---------------------------------------------------------------- road's end: the Wild Trail arch (plane 2)
F.depth(2)
F.tree(202, 128, 60, 2)
F.tree(280, 126, 54, 1)
local function trail()
  local opening = poly{ { 222, 124 }, { 222, 80 }, { 258, 80 }, { 258, 124 } }
  fill(opening, L.foliage2.edge)
  opening:each(function(x, y) if hash(x // 2, y, 31) < .3 then px(x, y, L.foliage2.deep) end end)
  -- the deep wood inside: a far misted gap, receding conifers, the path running in
  fill(poly{ { 236, 104 }, { 244, 104 }, { 243, 94 }, { 237, 94 } }, L.mist)
  hline(237, 243, 104, L.mist2)
  for _, t in ipairs({ { 230, 112, 22, L.farTree }, { 251, 112, 24, L.farTree }, { 226, 120, 30, L.foliage2 }, { 255, 121, 32, L.foliage2 } }) do
    F.conifer(t[1], t[2], t[3], t[4], t[1], { far = t[4] == L.farTree, slim = true })
  end
  fill(poly{ { 234, 124 }, { 246, 124 }, { 242, 104 }, { 238, 104 } }, L.road.shade)
  for i = 0, 3 do hline(239 - i, 241 + i, 108 + i * 5, L.road.deep) end
  px(239, 106, L.road.base) px(240, 111, L.road.base)
  -- mossy stone pillars and a big log lintel heaped with pine boughs
  local pL, pR = rect(210, 76, 221, 124), rect(259, 76, 270, 124)
  local lintel = rect(206, 70, 274, 79)
  shadow(212, 270, 124, 8, 4)
  rimOf(union(pL, pR, lintel), L.stone)
  part(pL, L.stone) part(pR, L.stone)
  courses(union(pL, pR), 76, 6, 6, L.stone)
  F.moss(union(pL, pR), .16, 34)
  part(lintel, L.timber)
  F.logs(lintel, L.timber, 70, 5)
  F.logEnd(206, 74, 4) F.logEnd(274, 74, 4)
  local boughs = { { 214, 66, 11, 6, L.foliage }, { 232, 62, 13, 7, L.foliage2 }, { 250, 62, 12, 7, L.foliage }, { 266, 66, 10, 6, L.foliage2 } }
  for i, b in ipairs(boughs) do
    local m = F.crown(b[1], b[2], b[3], b[4], b[5], 120 + i)
    m:each(function(x, y) if not m:has(x, y + 1) and hash(x, y, 130 + i) < .5 then px(x, y + 1, b[5].deep) end end)
  end
  fill(rect(238, 57, 239, 59), L.soil.base) px(238, 57, L.soil.hi)
  fill(rect(256, 58, 257, 60), L.soil.base) px(256, 58, L.soil.hi)
  -- lantern hanging from the lintel, red trail blaze on the right pillar, ferns at the feet
  vline(240, 80, 82, L.timber.edge)
  lantern(240, 83)
  local mk = rect(262, 102, 267, 108) rimOf(mk, L.awnA) part(mk, L.awnA)
  for _, f in ipairs({ { 212, 124, 5 }, { 219, 125, 4 }, { 262, 124, 4 }, { 269, 125, 5 } }) do F.fern(f[1], f[2], f[3]) end
end
trail()

---------------------------------------------------------------- back left: two log cottages (plane 1)
F.depth(1)
F.tree(86, 126, 42, 2)
F.tree(10, 128, 36, 1)
do
  local top, cx, wall = F.building{ x0 = 19, x1 = 45, yb = 134, wh = 32, rh = 22, wall = L.timber, roof = L.roof, shingle = true, noFrame = true }
  F.logs(wall, L.timber, top, 3)
  for y = top + 1, 132, 3 do F.logEnd(46, y, 1) end
  F.moss(c:poly{ { 16, top + 3 }, { cx, top - 22 }, { 48, top + 3 } }, .1, 35)
  window(24, 110, 30, 116, L.timber) door(34, 118, 41, 133, L.accent)
  local top2, cx2, wall2, roof2 = F.building{ x0 = 52, x1 = 75, yb = 134, wh = 40, rh = 26, wall = L.wall2, roof = L.roof2, chimney = true, shingle = true, noFrame = true }
  F.planks(wall2, L.wall2, 4, true, 36)
  part(union(rect(52, top2, 53, 134), rect(74, top2, 75, 134)), L.timber, { nopop = true, noshade = true })
  F.moss(roof2, .1, 37)
  window(57, 100, 63, 106, L.timber) window(57, 116, 62, 122, L.timber)
  door(66, 116, 72, 133, L.timber)
  local pot = rect(47, 128, 50, 133) rimOf(pot, L.timber) part(pot, L.roof2, { nopop = true })
  F.fern(48, 127, 3)
  F.smoke(66, 78, 6, .6, 2)
end

---------------------------------------------------------------- back right: notice board (plane 2)
F.depth(2)
F.birch(348, 134, 50, 51)
local function notice()
  local T = L.timber
  local roof = poly{ { 282, 60 }, { 313, 46 }, { 344, 60 }, { 344, 63 }, { 282, 63 } }
  local posts = rect(289, 63, 294, 136):add(rect(332, 63, 337, 136))
  local board = rect(287, 65, 339, 114)
  local bar = rect(286, 120, 340, 123)
  shadow(290, 338, 136, 10, 5)
  rimOf(union(roof, posts, board, bar), T)
  logPosts(posts)
  part(board, L.board, { band = 2 })
  F.planks(board, L.board, 6, true, 61)
  hline(287, 339, 65, T.base) hline(287, 339, 114, T.base) vline(287, 65, 114, T.base) vline(339, 65, 114, T.base)
  part(bar, T, { nopop = true }) hline(286, 340, 120, T.hi)
  part(roof, L.roof2, { sep = true }) courses(roof, 46, 3, 5, L.roof2)
  F.moss(roof, .14, 62)
  -- the carved owl on the peak
  F.sprite({ "B.......B", "BB.....BB", "BbbbbbbbS", "bWWbbbWWS", "bWEbbWESS", "bbbbobbSS", ".bBbBbBS.", ".bbBbBSS.", "..bbbSS..", "..g...g.." }, 309, 37,
    { B = L.board.hi, b = L.board.base, S = L.board.shade, W = L.awnB.hi, E = L.timber.edge, o = L.gold.base, g = L.gold.shade })
  local notes = { { 291, 69, 302, 82, L.awnB }, { 306, 70, 320, 80, L.plaster }, { 324, 68, 335, 84, L.awnB },
                  { 292, 87, 305, 100, L.accent }, { 309, 85, 321, 104, L.birch }, { 325, 89, 335, 99, L.gold },
                  { 296, 103, 306, 111, L.awnA }, { 323, 102, 334, 111, L.plaster } }
  for _, n in ipairs(notes) do
    local m = rect(n[1], n[2], n[3], n[4])
    part(m, n[5], { nopop = true })
    c:edgeIn(m, n[5].deep)
    for y = n[2] + 3, n[4] - 2, 3 do hline(n[1] + 2, n[3] - 2 - (y % 4), y, n[5].shade) end
    px((n[1] + n[3]) // 2, n[2] + 1, L.awnA.base)
  end
  -- a pinned map scrap with a route line, a pressed leaf, a pinned feather
  line({ { 311, 90 }, { 316, 96 }, { 312, 100 } }):each(function(x, y) px(x, y, L.awnA.base) end)
  F.sprite({ "..l", ".ll", "lLl", "lL.", "l.." }, 298, 89, { l = L.birchLeaf.base, L = L.birchLeaf.shade }, { rim = false })
  line({ { 327, 104 }, { 331, 109 } }):each(function(x, y) px(x, y, L.accent.shade) end)
  -- lantern on the right post, paste bucket, a hen pecking at its foot
  hline(337, 340, 70, T.deep) vline(340, 70, 72, T.deep)
  lantern(340, 73)
  local b = poly{ { 300, 128 }, { 308, 128 }, { 307, 135 }, { 301, 135 } } rimOf(b, L.accent) part(b, L.accent, { nopop = true })
  vline(305, 122, 128, T.hi)
  F.hen(318, 136, L.needle)
end
notice()

---------------------------------------------------------------- back right: the rest lodge (plane 2)
local function lodge()
  local top, cx, wall, roofM = F.building{ x0 = 360, x1 = 456, yb = 136, wh = 46, rh = 26, wall = L.timber, roof = L.roof, chimney = true, shingle = true, noFrame = true }
  F.logs(wall, L.timber, top, 3)
  for y = top + 1, 134, 3 do F.logEnd(359, y, 1) F.logEnd(457, y, 1) end
  F.moss(roofM, .13, 63)
  local gab = poly{ { top == 90 and 366 or 366, 89 }, { 408, 72 }, { 450, 89 } }:cut(rect(402, 76, 413, 86))
  F.logs(gab, L.timber, 72, 3)
  F.moss(gab, .05, 60)
  F.smoke(447, 61, 5, .5, 2)
  -- bark-shingle porch roof on log posts
  local porch = poly{ { 356, 105 }, { 460, 105 }, { 463, 111 }, { 353, 111 } }
  rimOf(porch, L.roof2) part(porch, L.roof2, { sep = true }) courses(porch, 105, 3, 4, L.roof2)
  hline(356, 460, 105, L.roof2.hi)
  local pp = rect(361, 112, 362, 135):add(rect(454, 112, 455, 135))
  logPosts(pp)
  window(366, 95, 378, 101, L.timber) window(438, 95, 450, 101, L.timber)
  window(370, 115, 380, 120, L.timber) window(436, 115, 446, 120, L.timber)
  door(400, 112, 416, 135, L.roof2)
  local sign = rect(398, 85, 418, 91) rimOf(sign, L.timber) part(sign, L.board)
  F.sprite({ "..s..", ".sss.", "sssss", "..t.." }, 403, 86, { s = L.foliage2.shade, t = L.timber.shade }, { rim = false })
  F.sprite({ ".b.b.", "bbbbb", ".bbb.", "..b.." }, 410, 86, { b = L.awnA.base }, { rim = false }) -- a heart: welcome
  lantern(421, 113)
  -- bench with patchwork quilt
  local bench = rect(364, 128, 396, 130):add(rect(365, 131, 367, 135)):add(rect(393, 131, 395, 135)):add(rect(364, 123, 366, 128))
  local quilt = rect(370, 124, 390, 133)
  shadow(366, 396, 135, 5, 2)
  rimOf(union(bench, quilt), L.timber)
  part(bench, L.timber, { nopop = true })
  local qc = { L.awnA.base, L.awnB.base, L.accent.base, L.roof.hi, L.lav.base }
  quilt:each(function(x, y) px(x, y, qc[((x - 370) // 5 + (y - 124) // 4) % 5 + 1]) end)
  for x = 370, 390, 5 do vline(x, 124, 133, L.awnB.deep) end
  hline(370, 390, 133, L.awnA.deep)
  -- tea table + teapot + cups
  local tbl = rect(424, 127, 444, 129):add(rect(426, 130, 427, 135)):add(rect(441, 130, 442, 135))
  local pot = poly{ { 429, 120 }, { 438, 120 }, { 440, 126 }, { 427, 126 } }
  local lid = rect(432, 118, 435, 119)
  rimOf(union(tbl, pot, lid), L.timber)
  part(tbl, L.timber, { nopop = true }) part(pot, L.accent) part(lid, L.accent, { nopop = true })
  line({ { 440, 122 }, { 443, 119 } }):each(function(x, y) px(x, y, L.accent.deep) end)
  px(426, 122, L.accent.deep) px(425, 123, L.accent.deep)
  hline(429, 438, 123, L.awnB.base)
  fill(rect(441, 125, 443, 126), L.plaster.hi)
  -- fern window boxes under the top windows
  for _, x in ipairs({ 365, 437 }) do
    hline(x, x + 14, 104, L.timber.base)
    for i = 0, 14, 2 do px(x + i, 103, (i % 4 == 0) and L.petal.base or L.fern.base) px(x + i + 1, 102, L.fern.hi) end
  end
end
lodge()

---------------------------------------------------------------- road side: snail mailbox, stacked goods, signpost (plane 2/3)
local function snail()
  local post = rect(208, 136, 209, 146)
  local shell = c:rrect(203, 124, 216, 135, 4)
  local foot = rect(198, 133, 220, 136):add(rect(198, 129, 201, 133))
  local stalks = rect(198, 125, 198, 128):add(rect(201, 125, 201, 128))
  rimOf(union(post, shell, foot, stalks), L.timber)
  part(post, L.timber, { nopop = true })
  part(foot, L.moss, { nopop = true })
  fill(stalks, L.moss.shade) px(198, 125, L.timber.edge) px(201, 125, L.timber.edge)
  part(shell, L.redbark)
  line({ { 209, 129 }, { 212, 129 }, { 212, 132 }, { 207, 132 }, { 207, 127 }, { 214, 127 } }):each(function(x, y) px(x, y, L.redbark.deep) end)
  F.moss(shell, .2, 64)
  hline(204, 215, 134, L.awnB.base)
  fill(rect(217, 126, 219, 129), L.awnA.base) vline(217, 126, 133, L.timber.deep)
end
snail()
local function signpost()
  local post = rect(442, 152, 445, 176)
  local b1 = poly{ { 430, 155 }, { 434, 151 }, { 454, 151 }, { 458, 155 }, { 454, 159 }, { 434, 159 } }
  local b2 = poly{ { 432, 165 }, { 436, 162 }, { 452, 162 }, { 456, 165 }, { 452, 168 }, { 436, 168 } }
  rimOf(union(post, b1, b2), L.timber)
  logPosts(post)
  part(b1, L.board) part(b2, L.birch)
  hline(436, 452, 155, L.board.deep) hline(438, 450, 165, L.birch.edge)
  F.moss(post, .2, 65)
end
signpost()

F.depth(3)
-- stacked goods on the left verge: crates of cones and apples, a sack, a barrel of honey
F.shadow(198, 222, 180, 8, 3)
F.crate(198, 180, 12, 9, L.soil)
F.crate(211, 180, 11, 9, L.apple)
F.crate(203, 170, 12, 8, L.gold)
F.sack(222, 182, L.awnB, 4)
F.shadow(200, 214, 204, 6, 2)
F.barrel(206, 204, honey, 11)
px(204, 197, honey.hi) px(205, 197, honey.hi)
F.sack(216, 206, L.needle, 4)
-- right verge by the notice board: firewood bundles for sale and a cone barrel
F.shadow(258, 280, 146, 6, 2)
for k = 0, 2 do F.logEnd(262 + k * 7, 142, 3) end
for k = 0, 1 do F.logEnd(265 + k * 7, 136, 3) end
hline(260, 280, 139, L.awnA.base)
F.barrel(282, 150, L.timber, 10)
for k = 0, 3 do px(279 + k * 2, 139, L.soil.base) px(280 + k * 2, 139, L.soil.shade) px(279 + k * 2, 138, L.soil.hi) end

---------------------------------------------------------------- the stump house (plane 3, replaces the haystack house)
local function stumpHouse()
  local m = poly{ { 420, 224 }, { 425, 218 }, { 427, 204 }, { 429, 188 }, { 431, 184 }, { 455, 184 }, { 457, 188 }, { 459, 204 }, { 461, 218 }, { 466, 224 } }
  local top = c:ellipse(443, 184, 13, 3)
  local pipe = rect(449, 175, 451, 182)
  shadow(426, 462, 224, 8, 3)
  rimOf(union(m, top, pipe), L.timber)
  part(m, L.timber)
  m:each(function(x, y)
    if (x * 3 + (y // 6)) % 7 == 0 then px(x, y, L.timber.deep) elseif (x * 3 + (y // 6)) % 7 == 1 then px(x, y, L.timber.hi) end
    if x > 452 and hash(x, y, 66) < .3 then px(x, y, L.timber.shade) end
  end)
  fill(top, L.board.base)
  top:each(function(x, y) local d = math.sqrt(((x - 443) / 13) ^ 2 + ((y - 184) / 3) ^ 2) * 4 if floor(d) % 2 == 1 then px(x, y, L.board.shade) end end)
  hline(433, 440, 182, L.board.hi)
  F.moss(top, .25, 67)
  part(pipe, L.iron, { nopop = true }) hline(448, 452, 175, L.iron.deep)
  -- roots splaying into the needles, moss on the lower bark
  for _, r in ipairs({ { 420, 224, 427, 214 }, { 466, 224, 459, 212 }, { 440, 224, 438, 218 } }) do
    line({ { r[1], r[2] }, { r[3], r[4] } }, 2):each(function(x, y) px(x, y, L.timber.base) end)
  end
  m:each(function(x, y) if y > 214 and hash(x // 2, y, 68) < .4 then px(x, y, hash(x, y, 69) < .5 and L.moss.base or L.moss.shade) end end)
  door(436, 207, 446, 223, L.accent, true)
  local w = c:ellipse(453, 198, 2, 2) rimOf(w, L.timber) fill(w, L.glow.base) px(452, 197, L.glow.hi)
  -- bracket fungi and a little sapling on top
  for _, f in ipairs({ { 428, 200 }, { 430, 194 }, { 458, 210 } }) do
    hline(f[1] - 2, f[1] + 2, f[2], honey.base) hline(f[1] - 1, f[1] + 1, f[2] - 1, honey.hi) hline(f[1] - 2, f[1] + 2, f[2] + 1, honey.deep)
  end
  F.conifer(437, 183, 9, L.foliage, 70)
  F.mushroom(462, 226, L.apple, true)
end
stumpHouse()

---------------------------------------------------------------- left: the wishing well (plane 3)
local function well()
  local S, T, RR = L.stone, L.timber, L.roof2
  local roofOuter = poly{ { 143, 92 }, { 196, 120 }, { 196, 126 }, { 90, 126 }, { 90, 120 } }
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
  rimOf(union(roofOuter, postL, postR, lipTop, lipFront, drum, crank, axle, bucket), S)
  part(drum, S) courses(drum, 165, 7, 13, S)
  F.moss(drum, .12, 71)
  part(lipFront, S, { sep = true }) courses(lipFront, 156, 10, 17, S, 5)
  F.moss(lipFront, .1, 72)
  part(lipTop, S, { sep = true })
  lipTop:each(function(x, y) if hash(x // 2, y, 73) < .2 then px(x, y, L.moss.hi) end end)
  local opening = poly{ { 106, 149 }, { 180, 149 }, { 184, 154 }, { 102, 154 } }
  fill(opening, L.water.deep) hline(110, 178, 149, S.edge) hline(118, 128, 152, L.water.shade) hline(156, 170, 151, L.water.shade)
  px(165, 152, L.glow.hi) px(166, 152, L.glow.base)
  logPosts(union(postL, postR))
  part(axle, T, { nopop = true }) hline(110, 176, 130, T.hi)
  for x = 136, 150, 3 do vline(x, 131, 133, L.board.base) end
  fill(rope, L.board.base) part(crank, T, { nopop = true }) fill(rect(188, 140, 191, 143), L.accent.base)
  part(bucket, T) hline(135, 151, 144, L.iron.shade) hline(136, 150, 150, L.iron.shade)
  line({ { 135, 141 }, { 143, 137 }, { 151, 141 } }):each(function(x, y) px(x, y, L.iron.deep) end)
  hline(137, 149, 142, L.water.hi)
  part(roofM, RR, { sep = true }) courses(roofM, 92, 4, 6, RR)
  F.moss(roofM, .12, 74)
  line({ { 91, 120 }, { 143, 93 } }):each(function(x, y) if roofM:has(x, y) then px(x, y, RR.hi) end end)
  hline(90, 196, 126, RR.edge) hline(91, 195, 125, RR.deep)
  part(gable, L.board, { nopop = true })
  F.planks(gable, L.board, 4, true, 75)
  vline(143, 106, 121, T.base)
  line({ { 143, 112 }, { 130, 120 } }):each(function(x, y) px(x, y, T.base) end)
  line({ { 143, 112 }, { 156, 120 } }):each(function(x, y) px(x, y, T.base) end)
  -- a pine-cone finial
  F.sprite({ ".s.", "sSs", "SsS", "sSs", ".S." }, 142, 86, { s = L.soil.shade, S = L.soil.base })
  -- ferns and moss at the drum foot, coins glinting
  for _, f in ipairs({ { 98, 208, 7 }, { 106, 210, 5 }, { 186, 208, 6 }, { 192, 206, 5 } }) do F.fern(f[1], f[2], f[3]) end
  for i = 0, 14 do local x, y = 97 + floor(hash(i, 1, 41) * 22), 168 + floor(hash(i, 2, 41) * 38) px(x, y, L.fern.base) px(x + 1, y, L.fern.hi) px(x, y + 1, L.fern.deep) end
  c:sparkle(176, 160)
end
well()

---------------------------------------------------------------- left: the Seed Swap log shop (plane 3)
local function seed()
  local top, cx, wall, roofM = F.building{ x0 = 19, x1 = 75, yb = 212, wh = 42, rh = 16, wall = L.timber, roof = L.roof, shingle = true, noFrame = true, noAttic = true }
  F.logs(wall, L.timber, top, 4)
  for y = top + 2, 210, 4 do F.logEnd(76, y, 2) end
  F.moss(roofM, .14, 76)
  -- pine sapling finial
  F.conifer(cx, top - 15, 9, L.foliage, 77)
  -- shop window full of seed packets, cone and acorn jars
  fill(rect(23, 183, 71, 199), L.timber.deep) fill(rect(24, 184, 70, 198), L.glow.shade)
  fill(rect(24, 184, 70, 187), L.glow.base)
  for i = 0, 7 do
    local x = 25 + i * 6
    local rr = ({ L.awnA, L.awnB, L.accent, L.produce, L.leaf, blueb, L.gold, L.wall2 })[i + 1]
    local pk = rect(x, 186 + (i % 2), x + 4, 192 + (i % 2)) part(pk, rr, { nopop = true }) px(x + 1, 187 + (i % 2), rr.hi)
    hline(x, x + 4, 189 + (i % 2), rr.deep)
  end
  hline(24, 70, 193, L.timber.base)
  for i = 0, 4 do
    local x = 26 + i * 9
    fill(rect(x, 194, x + 5, 198), L.water.hi) hline(x, x + 5, 194, L.timber.base)
    fill(rect(x + 1, 196, x + 4, 198), (i % 2 == 0) and L.soil.shade or L.needle.base)
    px(x + 1, 196, (i % 2 == 0) and L.soil.hi or L.needle.hi)
  end
  -- striped awning
  local aw = poly{ { 18, 182 }, { 22, 174 }, { 72, 174 }, { 76, 182 } }
  for x = 18, 76, 4 do aw:add(poly{ { x, 182 }, { x + 4, 182 }, { x + 2, 185 } }) end
  aw:clip(rect(17, 170, 77, 186))
  rimOf(aw, L.awnA)
  stripes(aw, 18, 4, L.awnA, L.awnB)
  hline(22, 72, 174, L.awnB.hi)
  -- hanging sign: an acorn
  vline(30, 168, 170, L.timber.edge) vline(40, 168, 170, L.timber.edge)
  local sg = rect(28, 160, 42, 167) rimOf(sg, L.timber) part(sg, L.board)
  F.sprite({ ".ccc.", "ccccc", ".aaa.", ".aaa.", "..a.." }, 33, 161, { c = L.soil.shade, a = L.gold.shade }, { rim = false })
  door(26, 200, 32, 211, L.timber)
  -- crate of potted pine saplings for swapping
  local crate = rect(48, 202, 72, 211) rimOf(crate, L.timber) part(crate, L.board) hline(48, 72, 206, L.board.deep)
  for i = 0, 3 do F.conifer(51 + i * 6, 202, 8 + (i % 2) * 2, i % 2 == 0 and L.foliage or L.foliage2, 80 + i) end
end
seed()
F.fern(14 + 8, 214, 6) F.fern(80, 212, 6)

---------------------------------------------------------------- right hero: the trader stall (plane 3)
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
  logPosts(posts)
  -- back wall of split logs, two shelves of jars
  fill(back, T.deep)
  F.logs(rect(301, 179, 399, 194), T, 179, 5)
  hline(301, 399, 186, T.edge) hline(301, 399, 193, T.edge)
  for i = 0, 15 do
    local x = 303 + i * 6
    local rr = ({ honey, L.apple, blueb, honey, L.leaf, L.lav })[i % 6 + 1]
    if x < 342 or x > 362 then
      hjar(x, 185, rr, (i % 3 == 0) and L.apple or L.awnB)
      if i % 2 == 0 then hjar(x + 1, 192, ({ honey, L.gold, L.apple })[i % 3 + 1], L.awnB) end
    end
  end
  -- the stallkeeper, behind the counter
  F.gnome(352, 202, { hat = L.awnA, coat = L.leaf, arm = "up", noShadow = true })
  -- mossy shingle roof + red/cream valance
  part(roof, L.roof, { sep = true }) courses(roof, 151, 3, 5, L.roof)
  F.moss(roof, .14, 81)
  line({ { 289, 167 }, { 300, 152 } }):each(function(x, y) if roof:has(x, y) then px(x, y, L.roof.hi) end end)
  hline(300, 400, 151, L.roof.hi)
  stripes(val, 289, 8, L.awnA, L.awnB)
  hline(289, 411, 167, L.awnA.deep)
  -- sign on the ridge with the wares painted on: mushroom, berry, jar, fish, fern
  local sign = rect(330, 143, 370, 150)
  rimOf(sign, T) part(sign, L.board) hline(331, 369, 150, L.board.deep)
  F.sprite({ ".rr.", "rrrr", ".ww." }, 333, 145, { r = L.apple.base, w = L.awnB.base }, { rim = false })
  F.sprite({ ".b.", "bbb", ".b." }, 340, 145, { b = blueb.base }, { rim = false })
  F.sprite({ "aaa", "hhh", "hhh" }, 346, 145, { a = L.awnA.base, h = honey.base }, { rim = false })
  F.sprite({ "s.ss", "ssss", "s.ss" }, 352, 145, { s = smoke.shade }, { rim = false })
  F.sprite({ ".f.", "fff", ".f." }, 360, 145, { f = L.fern.shade }, { rim = false })
  vline(336, 151, 151, T.deep) vline(364, 151, 151, T.deep)
  -- hanging under the valance: lanterns, smoked fish, herb bundles, a mushroom garland
  lantern(304, 180, 1)
  lantern(396, 180, 1)
  hline(310, 334, 179, L.board.deep)
  for k = 0, 3 do fish(311 + k * 6, 180) end
  for k = 0, 2 do herbs(368 + k * 6, 180, k == 1 and L.lav or L.fern) end
  -- counter: split-log front, plank top
  part(cfront, T)
  F.logs(cfront, T, 199, 5)
  for x = 296, 404, 27 do vline(x, 200, 220, T.edge) end
  part(ctop, L.board) hline(299, 401, 194, L.board.hi)
  part(legs, T, { nopop = true })
  -- goods on the counter
  basket(300, 320, 198, 5, honey, "chant", 82)
  basket(322, 340, 198, 5, L.apple, "berry", 83)
  basket(364, 384, 198, 5, blueb, "berry", 84)
  for k = 0, 2 do hjar(386 + k * 5, 198, honey, L.apple) end
  -- a honeycomb slab on a board
  local comb = rect(342, 194, 350, 197) rimOf(comb, honey) fill(comb, honey.base)
  comb:each(function(x, y) if (x + (y % 2)) % 2 == 0 then px(x, y, honey.shade) end end) px(343, 194, honey.hi)
  -- crates in front: porcini in birch-bark, pine cones
  local cr1 = rect(308, 210, 332, 222) rimOf(cr1, T) part(cr1, L.birch) cr1:each(function(x, y) if hash(x // 3, y, 85) < .14 then px(x, y, L.birch.edge) end end)
  hline(308, 332, 216, L.birch.shade)
  for k = 0, 4 do local x = 310 + k * 5 local m = poly{ { x, 209 }, { x + 1, 207 }, { x + 3, 207 }, { x + 4, 209 } } fill(m, L.needle.base) px(x + 1, 207, L.needle.hi) hline(x + 1, x + 3, 210, L.awnB.base) end
  local cr2 = rect(362, 210, 386, 222) rimOf(cr2, T) part(cr2, L.board) hline(362, 386, 216, L.board.deep) vline(374, 210, 222, L.board.deep)
  for k = 0, 5 do local x = 364 + k * 4 px(x, 208, L.soil.hi) fill(rect(x, 209, x + 2, 210), L.soil.base) px(x + 2, 210, L.soil.deep) px(x + 1, 207, L.soil.shade) end
  F.sack(392, 224, L.awnB, 4)
end
stall()
basket(410, 426, 224, 5, blueb, "berry", 90)
basket(414, 430, 214, 5, honey, "chant", 91)
-- a shopper with a basket, by the stall
local _, shx, shy = F.gnome(284, 228, { hat = L.roof2, coat = L.wall2, arm = "out", flip = true })
local bk = poly{ { shx - 3, shy }, { shx + 3, shy }, { shx + 2, shy + 5 }, { shx - 2, shy + 5 } }
rimOf(bk, L.timber) part(bk, L.board, { nopop = true })
px(shx - 1, shy - 1, L.gold.base) px(shx, shy - 1, L.gold.hi) px(shx + 1, shy - 1, L.apple.base)
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
  logPosts(posts)
  stripes(can, 120, 4, L.awnB, L.fern)
  hline(128, 180, 222, L.awnB.hi)
  part(legs, L.timber, { nopop = true })
  part(top, L.board) F.planks(top, L.board, 5, true, 86)
  part(cloth, L.awnA, { nopop = true })
  cloth:each(function(x, y) if ((x // 3) + (y // 2)) % 2 == 0 then px(x, y, L.awnA.shade) end end) -- gingham
  for x = 127, 181, 3 do px(x, 254, L.awnA.hi) end
  part(bench, L.timber, { nopop = true })
  -- feast: teapot, bilberry pie, honey pot, jug, plates of mushrooms
  local tp = poly{ { 134, 239 }, { 142, 239 }, { 143, 245 }, { 133, 245 } }
  rimOf(tp, L.roof2) part(tp, L.roof2) line({ { 143, 241 }, { 146, 238 } }):each(function(x, y) px(x, y, L.roof2.deep) end)
  px(137, 238, L.roof2.deep) px(138, 238, L.roof2.deep)
  local pie = poly{ { 150, 243 }, { 162, 243 }, { 164, 246 }, { 148, 246 } } rimOf(pie, L.board) part(pie, L.board, { nopop = true })
  hline(151, 161, 244, blueb.base) for x = 151, 161, 3 do px(x, 244, L.board.hi) end
  local hp = c:rrect(166, 240, 171, 246, 2) rimOf(hp, honey) part(hp, honey) hline(166, 171, 240, L.awnA.base)
  vline(173, 239, 241, L.timber.edge)
  for x = 131, 175, 11 do hline(x, x + 3, 247, L.plaster.hi) px(x + 1, 246, L.gold.base) end
  lantern(130, 236, 0)
  lantern(178, 236, 0)
end
longTable()

---------------------------------------------------------------- bottom left: the fishing pond with a jetty (plane 3)
local function pond()
  local bank = poly{ { 18, 238 }, { 32, 228 }, { 72, 226 }, { 100, 232 }, { 108, 246 }, { 100, 260 }, { 60, 264 }, { 26, 262 }, { 16, 252 } }
  local water = bank:shrink(3)
  shadow(24, 104, 262, 6, 3)
  rimOf(bank, L.water)
  fill(bank, L.soil.base)
  bank:each(function(x, y) if not water:has(x, y) then local v = hash(x, y, 51) px(x, y, v < .35 and L.stone.base or (v < .6 and L.stone.hi or L.moss.base)) end end)
  F.water(water, L.water)
  -- spruce reflections along the far edge
  for _, rx in ipairs({ 36, 58, 84 }) do for k = 0, 4 do hline(rx - 3 + k // 2, rx + 3 - k // 2, 233 + k * 2, L.water.shade) end end
  for _, p in ipairs({ { 40, 240 }, { 54, 250 }, { 28, 250 } }) do
    local pad = poly{ { p[1] - 4, p[2] }, { p[1], p[2] - 2 }, { p[1] + 4, p[2] }, { p[1], p[2] + 2 } }
    fill(pad, L.leaf.base) px(p[1] - 3, p[2], L.leaf.hi) px(p[1] + 1, p[2] + 1, L.leaf.deep)
  end
  px(41, 238, L.petal.hi) px(42, 238, L.petal.base)
  -- jetty
  local jet = poly{ { 70, 240 }, { 104, 240 }, { 106, 250 }, { 72, 250 } }
  local legs = rect(74, 250, 76, 257):add(rect(100, 250, 102, 256)):add(rect(86, 250, 88, 256))
  rimOf(union(jet, legs), L.timber)
  part(legs, L.timber, { nopop = true })
  part(jet, L.board)
  jet:each(function(x, y) if (x - y // 3) % 5 == 0 then px(x, y, L.board.deep) end end)
  hline(72, 105, 250, L.timber.deep)
  F.moss(legs, .3, 52)
  -- rod leaning, line + red float
  line({ { 98, 240 }, { 80, 222 }, { 66, 220 } }):each(function(x, y) px(x, y, L.timber.deep) end)
  vline(66, 221, 236, L.awnB.shade) fill(rect(65, 236, 67, 238), L.awnA.base) px(65, 236, L.awnA.hi)
  hline(62, 70, 239, L.water.hi)
  -- cattails
  for i = 0, 6 do
    local x = 20 + i * 4 local h = 6 + floor(hash(i, 9, 52) * 8)
    vline(x, 252 - h, 252, i % 2 == 0 and L.fern.shade or L.fern.deep)
    if i % 2 == 0 then fill(rect(x, 252 - h, x + 1, 252 - h + 3), L.soil.base) px(x, 252 - h, L.soil.hi) px(x + 1, 252 - h + 3, L.soil.deep) end
  end
  -- tackle box and a fish basket on the jetty
  local box = rect(90, 234, 99, 239) rimOf(box, L.accent) part(box, L.accent) hline(90, 99, 236, L.accent.deep)
  local fb = poly{ { 78, 234 }, { 86, 234 }, { 85, 239 }, { 79, 239 } } rimOf(fb, L.timber) part(fb, L.board, { nopop = true })
  for x = 79, 85, 2 do vline(x, 235, 238, L.board.shade) end
  px(80, 233, smoke.base) px(81, 233, smoke.hi) px(83, 233, smoke.base)
  F.moss(F.rock(16, 238, 6, 5), .3, 53)
  -- a frog on a pad
  F.sprite({ "g.g", "ggg", "GgG" }, 53, 246, { g = L.leaf.base, G = L.leaf.deep })
end
pond()

---------------------------------------------------------------- bottom right: forage bed (plane 3)
local function forage()
  local T = L.timber
  local soil = poly{ { 304, 247 }, { 368, 247 }, { 374, 254 }, { 298, 254 } }
  local front = rect(298, 254, 374, 262)
  local back = rect(304, 245, 368, 247)
  shadow(300, 374, 262, 8, 2)
  rimOf(union(soil, front, back), T)
  part(back, T, { nopop = true })
  fill(soil, L.soil.base) soil:each(function(x, y) if hash(x, y, 71) < .2 then px(x, y, L.soil.deep) elseif hash(x, y, 72) < .1 then px(x, y, L.needle.base) end end)
  part(front, T) F.logs(front, T, 254, 4)
  F.logEnd(298, 258, 4) F.logEnd(374, 258, 4)
  for i, x in ipairs({ 308, 330, 352 }) do -- fly agarics
    local cap = poly{ { x - 5, 247 }, { x - 3, 243 }, { x + 3, 243 }, { x + 5, 247 } }
    local st = rect(x - 1, 248, x + 1, 251)
    rimOf(union(cap, st), L.apple) part(st, L.awnB, { nopop = true }) part(cap, L.apple)
    px(x - 2, 244, L.awnB.hi) px(x + 2, 245, L.awnB.hi) px(x, 246, L.awnB.base)
  end
  for i, x in ipairs({ 319, 341, 363 }) do -- bilberry bushes
    local b = poly{ { x - 6, 251 }, { x - 4, 242 }, { x, 238 }, { x + 4, 242 }, { x + 6, 251 } }
    rimOf(b, L.leaf) part(b, L.leaf)
    b:each(function(xx, y) if hash(xx, y, 73) < .12 then px(xx, y, blueb.base) px(xx, y - 1, blueb.hi) end end)
  end
  fill(rect(371, 238, 372, 246), T.base)
  local bl = poly{ { 369, 246 }, { 374, 246 }, { 372, 251 } } fill(bl, L.iron.base) px(370, 246, L.iron.hi)
end
forage()

---------------------------------------------------------------- near ferns and saplings, sky life
for _, f in ipairs({ { 112, 262, 7 }, { 192, 262, 8 }, { 200, 250, 6 }, { 286, 258, 7 }, { 380 - 4, 226, 6 }, { 414, 228, 6 }, { 196, 226, 6 } }) do F.fern(f[1], f[2], f[3]) end
F.mushroom(204, 262, L.apple, true) F.mushroom(208, 264, L.apple) F.mushroom(290, 236, L.needle, true)
F.depth(0)
F.birds({ { 300, 30, 2 }, { 310, 36, 1 }, { 120, 64, 2 }, { 410, 50, 1 } })

F.finish()
