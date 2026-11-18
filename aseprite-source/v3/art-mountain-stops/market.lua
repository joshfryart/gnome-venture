-- market.lua : "Market hamlet" stop look, MOUNTAIN (mountain_granite), 480x270 gate view.
-- Same composition and hotspots as the Maplewold market (here-gate/pilot-market.lua) and its forest port
-- (art-forest-stops/market.lua), re-cast as a high-mountain market:
-- road's end: the High Path, a granite trilithon under a slab lintel crowned with a cairn, a lantern, and through it a
-- switchback path climbing scree toward a snowy pass. Back left: two stone-and-larch chalets with smoke. Back right: a
-- slab-roofed larch notice board (an ibex head carved on the peak, a marmot at its foot) and the rest lodge: whitewashed
-- granite storey under larch boards, porch bench with a patchwork quilt and an enamel teapot. Left: the giant granite
-- wishing well under a weighted slab roof, and the Seed Swap chalet shop (seed packets, alpine-herb jars, a crate of
-- potted edelweiss). Right hero: the trader stall: larch posts, weighted slab roof, red-and-cream valance, mountain
-- cheeses, edelweiss honey, cured sausages, alpine-herb bundles, bilberries, lingonberries, arolla cones, a gnome
-- stallkeeper. Stacked goods and a milk churn by the road. Bottom: the glacial tarn with a larch jetty and cotton grass,
-- the long table under a gentian-striped canopy, the alpine herb bed (edelweiss, gentian, arnica, alpine rose).
-- Quirks kept in mountain dress: the teapot-hatted scarecrow (a chough on its arm), the barrow growing something too big
-- (a giant edelweiss), the snail mailbox (a lichened snail), and the haystack house as a hollow boulder house (a goat on
-- its roof, as goats do).
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-mountain-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "market", out = DIR, treeLineGap = { 204, 276 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local courses, shadow, window, door = F.courses, F.shadow, F.window, F.door
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs

-- local ramps for market goods
local blueb = F.rp("#a8b4e0 #6c78b8 #4e5894 #383e6e #242a4a") -- bilberries
local honey = F.rp("#fff2b8 #f2d27a #d4a646 #9c7430 #644622") -- pale edelweiss honey
local speck = F.rp("#eaa894 #c06a56 #8e4440 #602c30 #3c1c22") -- cured sausage / speck
local charR = F.rp("#f4c4ac #dc8c76 #ac6058 #763e40 #4a2630") -- arctic char
local chough = { k = "#3a3642", K = "#4e4a5a" }

---------------------------------------------------------------- local helpers
local function hjar(x, yb, r, lidR) -- little jar 4 wide, 6 tall, cloth lid
  local m = rect(x, yb - 5, x + 3, yb)
  rimOf(m, L.timber)
  fill(m, r.base) vline(x, yb - 4, yb, r.hi) vline(x + 3, yb - 4, yb, r.shade) hline(x, x + 3, yb, r.deep)
  hline(x, x + 3, yb - 5, (lidR or L.awnB).base) px(x + 1, yb - 5, (lidR or L.awnB).hi)
  px(x + 1, yb - 3, L.edel.hi)
  return m
end
local function cheese(x, yb, r, h) -- a wheel of mountain cheese, seen side-on
  local m = c:rrect(x - r, yb - h, x + r, yb, 2)
  c:rim(m, L.cheese.edge) part(m, L.cheese, { nopop = true })
  hline(x - r + 1, x + r - 1, yb - h, L.cheese.hi) hline(x - r + 1, x + r - 1, yb, L.cheese.deep)
  if r >= 3 then px(x - 1, yb - h // 2, L.cheese.shade) px(x, yb - h // 2, L.cheese.shade) end -- the stamp
  return m
end
local function wstone(x, y) -- a weighting stone on a slab roof
  local ws = c:ellipse(x, y, 3, 2) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true }) px(x - 1, y - 1, L.stone.hi)
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
    elseif kind == "cone" then -- arolla cones: scaly 3x3 lumps
      local bx, by = (x + (y // 3) * 2) % 3, y % 3
      if bx == 0 and by == 0 then px(x, y, r.hi) elseif bx == 2 or by == 2 then px(x, y, r.shade) end
      if bx == 2 and by == 2 then px(x, y, r.deep) end
    else
      local v = hash(x, y, seed) if v < .18 then px(x, y, r.hi) elseif v > .85 then px(x, y, r.deep) end
    end
  end)
  -- a sprig of juniper tucked in
  px(x0 + 3, yb - h - 3, L.juniper.base) px(x0 + 4, yb - h - 4, L.juniper.hi) px(x1 - 4, yb - h - 2, L.juniper.shade)
  return body
end
local function sausage(x, y) -- a cured sausage hanging, 3 wide, 9 tall, tied with string
  F.sprite({ ".t.", "sbs", "sbs", "sbS", "sbS", "sbS", "sbS", ".S.", ".t." }, x, y,
    { t = L.awnB.shade, s = speck.base, b = speck.hi, S = speck.shade })
  px(x + 1, y + 4, L.awnB.hi) -- a fat fleck
end
local function herbs(x, y, r, flower) -- a drying alpine-herb bundle tied with string
  vline(x + 1, y - 2, y, L.board.deep)
  F.sprite({ ".b.", "bBb", "BbB", "bBb", "BBb", "b.b" }, x, y + 1, { b = r.shade, B = r.base })
  px(x + 1, y + 2, r.hi) hline(x, x + 2, y + 1, L.awnA.shade)
  if flower then px(x, y + 5, flower.base) px(x + 2, y + 4, flower.hi) px(x + 1, y + 6, flower.base) end
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
local function logPosts(m) -- round larch posts: lit left, dark right, bark rings
  rimOf(m, L.timber)
  part(m, L.timber, { nopop = true, noshade = true })
  m:each(function(x, y)
    if not m:has(x - 1, y) then px(x, y, L.timber.hi)
    elseif not m:has(x + 1, y) then px(x, y, L.timber.shade) end
    if hash(x, y // 3, 88) < .12 then px(x, y, L.timber.deep) end
  end)
end
local function rubble(m, y0, seed) -- whitewashed rubble granite: irregular stones, some showing through the lime
  part(m, L.plaster, { nopop = true })
  m:each(function(x, y)
    local row = (y - y0) // 5
    local ry = (y - y0) % 5
    local bw = 6 + floor(hash(row, 1, seed) * 4)
    local rx = (x + row * 3) % bw
    if ry == 0 or rx == 0 then px(x, y, L.plaster.shade)
    elseif hash((x + row * 3) // bw, row, seed + 1) < .28 then px(x, y, (ry == 1) and L.stone.hi or L.stone.base)
    elseif ry == 1 and rx == 1 then px(x, y, L.plaster.hi) end
  end)
end
local function chalk(m) -- the lime wash darkens toward the damp foot
  local yb = -1 m:each(function(x, y) if y > yb then yb = y end end)
  m:each(function(x, y) if y > yb - 3 and hash(x, y, 21) < .35 then px(x, y, L.stone.shade) end end)
end

---------------------------------------------------------------- far quirks (plane 1): scarecrow + giant-edelweiss barrow
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
  part(shirt, L.awnA)
  shirt:each(function(x, y) if x % 3 == 0 or y % 3 == 1 then px(x, y, (x % 3 == 0 and y % 3 == 1) and L.awnB.shade or L.awnA.shade) end end) -- red check
  hline(101, 116, 89, L.timber.shade) -- a leather belt
  px(108, 89, L.gold.base)
  part(head, L.awnB) px(107, 73, t.deep) px(110, 73, t.deep) hline(107, 110, 76, t.shade)
  -- an enamel teapot for a hat: gentian blue, white spots
  part(hat, L.accent) part(lid, L.accent) fill(spout, L.accent.shade)
  px(105, 67, L.edel.hi) px(110, 68, L.edel.base) px(108, 64, L.accent.hi)
  px(102, 69, L.accent.deep) px(101, 68, L.accent.deep)
  -- straw tufts at cuffs and hem
  for _, p in ipairs({ { 99, 82 }, { 118, 82 }, { 103, 93 }, { 108, 93 }, { 113, 93 } }) do px(p[1], p[2], L.needle.base) px(p[1], p[2] + 1, L.needle.shade) end
  -- an alpine chough perched on the arm (yellow bill, red legs)
  F.sprite({ ".kk.", "kKKy", ".KKk", "..r." }, 112, 76, { k = chough.k, K = chough.K, y = L.gold.hi, r = L.apple.base })
  -- a sprig of edelweiss in the buttonhole
  px(105, 82, L.edel.hi) px(104, 82, L.edel.shade)
end
scarecrow()
local function barrow()
  local t = L.timber
  local tray = poly{ { 160, 92 }, { 184, 92 }, { 180, 100 }, { 163, 100 } }
  local handles = line({ { 160, 94 }, { 152, 98 } }):add(line({ { 166, 100 }, { 164, 104 } }))
  local wheel = poly{ { 180, 98 }, { 186, 98 }, { 188, 101 }, { 186, 104 }, { 180, 104 }, { 178, 101 } }
  local stem = poly{ { 170, 92 }, { 174, 92 }, { 173, 60 }, { 171, 60 } }
  local leaf1 = poly{ { 171, 82 }, { 163, 76 }, { 156, 75 }, { 160, 79 }, { 170, 85 } }
  local leaf2 = poly{ { 173, 76 }, { 181, 70 }, { 189, 68 }, { 185, 72 }, { 174, 79 } }
  local cx, cy = 172, 48
  local petals = HP.mask()
  local tips = {}
  for k = 0, 8 do
    local a = k * 2 * pi / 9 - pi / 2 + .15
    local len = 19 + floor(hash(k, 1, 5) * 4)
    local ux, uy = cos(a), sin(a) * .82
    local qx, qy = -sin(a), cos(a) * .82
    local w = 4.6
    local tip = { cx + ux * len, cy + uy * len }
    tips[#tips + 1] = { tip, a }
    petals:add(poly{ { cx + qx * 2, cy + qy * 2 }, { cx + ux * len * .5 + qx * w, cy + uy * len * .5 + qy * w }, { cx + ux * len * .82 + qx * w * .6, cy + uy * len * .82 + qy * w * .6 }, tip,
      { cx + ux * len * .82 - qx * w * .6, cy + uy * len * .82 - qy * w * .6 }, { cx + ux * len * .5 - qx * w, cy + uy * len * .5 - qy * w }, { cx - qx * 2, cy - qy * 2 } })
  end
  local center = c:ellipse(cx, cy, 6, 5)
  rimOf(union(tray, handles, wheel), t)
  rimOf(union(stem, leaf1, leaf2, petals, center), L.edel)
  part(handles, t, { nopop = true }) part(tray, t) part(wheel, L.stone, { nopop = true })
  -- woolly grey-green stem and leaves
  part(union(stem, leaf1, leaf2), L.juniper, { nopop = true })
  union(stem, leaf1, leaf2):each(function(x, y) if hash(x, y, 7) < .35 then px(x, y, L.edel.shade) elseif hash(x, y, 8) < .2 then px(x, y, L.juniper.hi) end end)
  vline(171, 61, 91, L.edel.base)
  -- felted bracts: lit toward the sun (upper left), cold shade on the lower right, green-tipped, a pale midrib
  petals:each(function(x, y)
    local dx, dy = x - cx, (y - cy) / .82
    local d = math.sqrt(dx * dx + dy * dy)
    local lit = (-dx - dy) / math.max(1, d)
    local h = lit > .35 and L.edel.hi or (lit < -.45 and L.edel.shade or L.edel.base)
    if d > 15.5 then h = (lit > 0) and L.moss.hi or L.moss.base end
    if hash(x, y, 9) < .14 then h = (h == L.edel.hi) and L.edel.base or L.edel.deep end
    px(x, y, h)
  end)
  for _, tp in ipairs(tips) do
    local a = tp[2]
    line({ { cx + cos(a) * 7, cy + sin(a) * .82 * 7 }, { cx + cos(a) * 14, cy + sin(a) * .82 * 14 } }):each(function(x, y) if petals:has(x, y) then px(x, y, (cos(a) + sin(a) < 0) and L.edel.base or L.edel.deep) end end)
  end
  -- the clustered yellow florets in the middle
  part(center, L.edel, { nopop = true })
  for _, f in ipairs({ { -3, -2 }, { 2, -2 }, { -1, 1 }, { 3, 2 }, { -4, 2 }, { 0, -4 } }) do
    local fx, fy = cx + f[1], cy + f[2]
    px(fx, fy, L.gold.hi) px(fx + 1, fy, L.gold.base) px(fx, fy + 1, L.gold.base) px(fx + 1, fy + 1, L.gold.shade)
  end
  -- turf and little flowers in the barrow tray
  hline(162, 182, 93, L.mossGround.base) hline(163, 181, 94, L.mossGround.shade)
  F.gentian(163, 91, true) F.edelweiss(181, 91, true)
end
barrow()

---------------------------------------------------------------- road's end: the High Path trilithon (plane 2)
F.depth(2)
F.tree(202, 128, 60, 2)
F.tree(280, 126, 54, 1)
local function trail()
  local opening = rect(222, 80, 258, 124)
  -- the view through: pale sky, a snowy col, scree, a switchback path climbing to it
  opening:each(function(x, y) px(x, y, y < 86 and L.sky[3] or (y < 92 and L.sky[4] or L.sky[5])) end)
  local pk = poly{ { 222, 104 }, { 228, 96 }, { 236, 86 }, { 242, 93 }, { 247, 89 }, { 258, 99 }, { 258, 108 }, { 222, 108 } }
  pk:clip(opening)
  pk:each(function(x, y)
    local lit = (x < 236 and y > 86 + (236 - x) * 1.1 - 1) or (x >= 236 and x < 242 and false) or (x >= 242 and x < 247 and y > 89 + (247 - x) * .8)
    local h = (x < 236 or (x >= 242 and x < 247)) and L.peakFar.hi or L.peakFar.shade
    if y < 95 then h = (x < 236 or (x >= 242 and x < 247)) and L.snow.hi or L.snow.shade end
    if y >= 95 and y < 99 and hash(x, y, 3) < .4 then h = L.snow.base end
    px(x, y, h)
  end)
  hline(222, 258, 100, L.mist) hline(226, 254, 101, L.mist2)
  local scree = poly{ { 222, 102 }, { 236, 108 }, { 246, 104 }, { 258, 106 }, { 258, 124 }, { 222, 124 } }
  scree:clip(opening)
  scree:each(function(x, y)
    local v = hash(x, y, 31)
    local h = (y < 112) and L.groundFar or (v < .5 and L.ground.base or L.ground.shade)
    if hash(x // 2, y // 2, 32) < .22 then h = (v < .5) and L.stone.base or L.stone.shade end
    px(x, y, h)
  end)
  -- the switchback path
  local path = line({ { 240, 124 }, { 233, 118 }, { 248, 112 }, { 238, 108 }, { 244, 105 } }, 2)
  path:clip(opening)
  path:each(function(x, y) px(x, y, y > 116 and L.road.base or L.road.hi) end)
  for _, t in ipairs({ { 228, 120, 14 }, { 252, 118, 12 }, { 226, 113, 8 } }) do F.conifer(t[1], t[2], t[3], L.farTree, t[1], { far = true, slim = true }) end
  -- granite posts and a great slab lintel crowned with a cairn
  local pL, pR = rect(210, 76, 221, 124), rect(259, 76, 270, 124)
  local lintel = poly{ { 205, 70 }, { 275, 69 }, { 276, 79 }, { 204, 79 } }
  shadow(212, 270, 124, 8, 4)
  rimOf(union(pL, pR, lintel), L.stone)
  part(pL, L.stone) part(pR, L.stone)
  courses(union(pL, pR), 76, 6, 6, L.stone)
  F.lichen(union(pL, pR), .22, 34)
  part(lintel, L.stone, { sep = true })
  hline(206, 274, 70, L.stone.hi) hline(205, 276, 79, L.stone.deep)
  lintel:each(function(x, y) if hash(x // 4, y, 35) < .12 then px(x, y, L.stone.shade) end end)
  line({ { 226, 71 }, { 229, 75 }, { 228, 78 } }):each(function(x, y) px(x, y, L.stone.deep) end) -- a crack
  F.lichen(lintel, .2, 36)
  -- the cairn (stone man): stacked flat stones, biggest at the foot
  local cairn = { { 240, 66, 9, 3 }, { 239, 61, 7, 2 }, { 241, 57, 6, 2 }, { 240, 53, 4, 2 }, { 240, 49, 3, 2 }, { 241, 46, 2, 1 } }
  for _, s in ipairs(cairn) do
    local m = c:ellipse(s[1], s[2], s[3], s[4])
    rimOf(m, L.stone) part(m, L.stone, { nopop = true })
    hline(s[1] - s[3] + 1, s[1], s[2] - s[4] + 1, L.stone.hi)
    hline(s[1], s[1] + s[3] - 1, s[2] + s[4] - 1, L.stone.shade)
    if s[3] > 4 then px(s[1] + 2, s[2], L.moss.base) end
  end
  -- juniper cushions at the lintel ends, a little red-white flag on the cairn
  F.juniper(212, 70, 8, 5, 37) F.juniper(268, 70, 8, 5, 38)
  vline(244, 40, 46, L.timber.deep)
  F.sprite({ "rrw", "rww" }, 245, 40, { r = L.awnA.base, w = L.awnB.hi }, { rim = false })
  -- lantern hanging from the lintel, the red-white-red trail blaze on the right post, edelweiss at the feet
  vline(240, 80, 82, L.timber.edge)
  lantern(240, 83)
  local mk = rect(262, 100, 267, 108) rimOf(mk, L.awnA)
  fill(rect(262, 100, 267, 101), L.awnA.base) fill(rect(262, 102, 267, 105), L.awnB.hi) fill(rect(262, 106, 267, 108), L.awnA.base)
  px(262, 100, L.awnA.hi) hline(262, 267, 108, L.awnA.shade)
  for _, f in ipairs({ { 212, 124, 4 }, { 269, 125, 4 } }) do F.fern(f[1], f[2], f[3]) end
  F.edelweiss(218, 122, true) F.gentian(263, 122, true) F.edelweiss(259, 125)
end
trail()

---------------------------------------------------------------- back left: two stone-and-larch chalets (plane 1)
F.depth(1)
F.tree(86, 126, 42, 2)
F.tree(10, 128, 36, 1)
do
  local top, cx, wall, roof1 = F.building{ x0 = 19, x1 = 45, yb = 134, wh = 32, rh = 22, wall = L.timber, roof = L.roof, shingle = true, noFrame = true }
  F.planks(wall, L.timber, 3, false, 35)
  local base = rect(19, 120, 45, 134) rubble(base, 120, 40) chalk(base)
  hline(19, 45, 119, L.timber.edge)
  F.lichen(roof1, .2, 35)
  window(24, 108, 30, 114, L.timber) door(34, 122, 41, 133, L.accent)
  hline(23, 31, 115, L.timber.base) for x = 24, 30, 2 do px(x, 114, L.apple.base) end
  local top2, cx2, wall2, roof2 = F.building{ x0 = 52, x1 = 75, yb = 134, wh = 40, rh = 26, wall = L.plaster, roof = L.roof2, chimney = true, shingle = true, noFrame = true }
  rubble(rect(52, top2 + 1, 75, 134), top2 + 1, 41) chalk(rect(52, top2, 75, 134))
  part(union(rect(52, top2, 53, 134), rect(74, top2, 75, 134)), L.stone, { nopop = true, noshade = true })
  F.lichen(roof2, .1, 37)
  window(57, 100, 63, 106, L.timber) window(57, 116, 62, 122, L.timber)
  -- painted shutters
  vline(56, 100, 106, L.awnA.base) vline(64, 100, 106, L.awnA.shade)
  door(66, 116, 72, 133, L.timber)
  local pot = rect(47, 128, 50, 133) rimOf(pot, L.timber) part(pot, L.roof2, { nopop = true })
  px(48, 127, L.apple.base) px(49, 126, L.apple.hi) px(48, 126, L.leaf.base)
  F.smoke(66, 78, 6, .6, 2)
end

---------------------------------------------------------------- back right: notice board (plane 2)
F.depth(2)
F.larch(348, 134, 50, 51)
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
  part(roof, L.roof, { sep = true }) courses(roof, 46, 3, 6, L.roof)
  F.lichen(roof, .22, 62)
  line({ { 283, 60 }, { 312, 47 } }):each(function(x, y) if roof:has(x, y) then px(x, y, L.roof.hi) end end)
  wstone(296, 57) wstone(330, 57)
  -- an ibex head carved on the peak, great ridged horns swept back
  F.sprite({ "h.......h", "Hh.....hH", ".Hh...hH.", "..hbbbh..", "..bEbEb..", "..BbbbS..", "...bbS...", "...bS....", "...g....." }, 309, 37,
    { h = L.timber.shade, H = L.timber.hi, b = L.board.base, B = L.board.hi, S = L.board.shade, E = L.timber.edge, g = L.board.deep })
  local notes = { { 291, 69, 302, 82, L.awnB }, { 306, 70, 320, 80, L.plaster }, { 324, 68, 335, 84, L.awnB },
                  { 292, 87, 305, 100, L.accent }, { 309, 85, 321, 104, L.edel }, { 325, 89, 335, 99, L.cheese },
                  { 296, 103, 306, 111, L.awnA }, { 323, 102, 334, 111, L.plaster } }
  for _, n in ipairs(notes) do
    local m = rect(n[1], n[2], n[3], n[4])
    part(m, n[5], { nopop = true })
    c:edgeIn(m, n[5].deep)
    for y = n[2] + 3, n[4] - 2, 3 do hline(n[1] + 2, n[3] - 2 - (y % 4), y, n[5].shade) end
    px((n[1] + n[3]) // 2, n[2] + 1, L.awnA.base)
  end
  -- a pinned trail map (a peak, a route line), a pressed edelweiss, a chough feather
  line({ { 311, 100 }, { 315, 89 }, { 319, 100 } }):each(function(x, y) px(x, y, L.stone.shade) end)
  px(315, 89, L.snow.hi) px(314, 90, L.snow.base)
  line({ { 311, 96 }, { 314, 94 }, { 313, 92 }, { 316, 91 } }):each(function(x, y) px(x, y, L.awnA.base) end)
  F.edelweiss(300, 93, true)
  line({ { 327, 104 }, { 331, 109 } }):each(function(x, y) px(x, y, chough.K) end) px(327, 104, L.edel.base)
  -- lantern on the right post, paste bucket, a marmot sitting up at its foot
  hline(337, 340, 70, T.deep) vline(340, 70, 72, T.deep)
  lantern(340, 73)
  local b = poly{ { 300, 128 }, { 308, 128 }, { 307, 135 }, { 301, 135 } } rimOf(b, L.accent) part(b, L.accent, { nopop = true })
  vline(305, 122, 128, T.hi)
  F.marmot(318, 136, { flip = true })
end
notice()

---------------------------------------------------------------- back right: the rest lodge (plane 2)
local function lodge()
  local top, cx, wall, roofM = F.building{ x0 = 360, x1 = 456, yb = 136, wh = 46, rh = 26, wall = L.timber, roof = L.roof, chimney = true, shingle = true, noFrame = true }
  F.planks(wall, L.timber, 3, false, 63)
  wall:each(function(x, y) if y < top + 6 and hash(x, y, 18) < .25 then px(x, y, L.timber.deep) end end) -- sun-scorched under the eaves
  local base = rect(360, 111, 456, 136) rubble(base, 111, 64) chalk(base)
  F.lichen(roofM, .2, 63)
  local gab = poly{ { 366, 89 }, { 408, 72 }, { 450, 89 } }:cut(rect(398, 84, 418, 92))
  F.planks(gab, L.timber, 3, true, 60)
  for _, w in ipairs({ { 372, 86 }, { 392, 77 }, { 424, 77 }, { 444, 86 } }) do wstone(w[1], w[2] + 1) end
  F.smoke(447, 61, 5, .5, 2)
  -- larch-shingle porch roof on log posts
  local porch = poly{ { 356, 105 }, { 460, 105 }, { 463, 111 }, { 353, 111 } }
  rimOf(porch, L.roof2) part(porch, L.roof2, { sep = true }) courses(porch, 105, 3, 4, L.roof2)
  hline(356, 460, 105, L.roof2.hi)
  local pp = rect(361, 112, 362, 135):add(rect(454, 112, 455, 135))
  logPosts(pp)
  window(366, 95, 378, 101, L.timber) window(438, 95, 450, 101, L.timber)
  window(370, 115, 380, 120, L.timber) window(436, 115, 446, 120, L.timber)
  door(400, 112, 416, 135, L.roof2)
  -- the welcome sign: a cup and a heart
  local sign = rect(398, 85, 418, 91) rimOf(sign, L.timber) part(sign, L.board)
  F.sprite({ "ccc.", "ccch", "ccc.", ".c.." }, 403, 86, { c = L.accent.base, h = L.accent.shade }, { rim = false })
  F.sprite({ ".b.b.", "bbbbb", ".bbb.", "..b.." }, 410, 86, { b = L.awnA.base }, { rim = false })
  lantern(421, 113)
  -- bench with patchwork quilt
  local bench = rect(364, 128, 396, 130):add(rect(365, 131, 367, 135)):add(rect(393, 131, 395, 135)):add(rect(364, 123, 366, 128))
  local quilt = rect(370, 124, 390, 133)
  shadow(366, 396, 135, 5, 2)
  rimOf(union(bench, quilt), L.timber)
  part(bench, L.timber, { nopop = true })
  local qc = { L.awnA.base, L.awnB.base, L.accent.base, L.cheese.base, L.lav.base }
  quilt:each(function(x, y) px(x, y, qc[((x - 370) // 5 + (y - 124) // 4) % 5 + 1]) end)
  for x = 370, 390, 5 do vline(x, 124, 133, L.awnB.deep) end
  hline(370, 390, 133, L.awnA.deep)
  -- tea table + enamel teapot + cups
  local tbl = rect(424, 127, 444, 129):add(rect(426, 130, 427, 135)):add(rect(441, 130, 442, 135))
  local pot = poly{ { 429, 120 }, { 438, 120 }, { 440, 126 }, { 427, 126 } }
  local lid = rect(432, 118, 435, 119)
  rimOf(union(tbl, pot, lid), L.timber)
  part(tbl, L.timber, { nopop = true }) part(pot, L.accent) part(lid, L.accent, { nopop = true })
  line({ { 440, 122 }, { 443, 119 } }):each(function(x, y) px(x, y, L.accent.deep) end)
  px(426, 122, L.accent.deep) px(425, 123, L.accent.deep)
  px(431, 122, L.edel.hi) px(435, 124, L.edel.base) px(433, 121, L.edel.base)
  fill(rect(441, 125, 443, 126), L.plaster.hi)
  -- geranium window boxes under the top windows
  for _, x in ipairs({ 365, 437 }) do
    hline(x, x + 14, 104, L.timber.base)
    for i = 0, 14, 2 do px(x + i, 103, L.leaf.base) px(x + i + 1, 102, (i % 4 == 0) and L.apple.hi or L.apple.base) end
  end
end
lodge()

---------------------------------------------------------------- road side: snail mailbox, signpost (plane 2)
local function snail()
  local post = rect(208, 136, 209, 146)
  local shell = c:rrect(203, 124, 216, 135, 4)
  local foot = rect(198, 133, 220, 136):add(rect(198, 129, 201, 133))
  local stalks = rect(198, 125, 198, 128):add(rect(201, 125, 201, 128))
  rimOf(union(post, shell, foot, stalks), L.timber)
  part(post, L.timber, { nopop = true })
  part(foot, L.goat, { nopop = true })
  fill(stalks, L.goat.shade) px(198, 125, L.timber.edge) px(201, 125, L.timber.edge)
  part(shell, L.redbark)
  line({ { 209, 129 }, { 212, 129 }, { 212, 132 }, { 207, 132 }, { 207, 127 }, { 214, 127 } }):each(function(x, y) px(x, y, L.redbark.deep) end)
  F.lichen(shell, .25, 64)
  hline(204, 215, 134, L.awnB.base)
  fill(rect(217, 126, 219, 129), L.awnA.base) vline(217, 126, 133, L.timber.deep)
  F.edelweiss(206, 123)
end
snail()
local function signpost()
  local post = rect(442, 152, 445, 176)
  local b1 = poly{ { 430, 155 }, { 434, 151 }, { 454, 151 }, { 458, 155 }, { 454, 159 }, { 434, 159 } }
  local b2 = poly{ { 432, 165 }, { 436, 162 }, { 452, 162 }, { 456, 165 }, { 452, 168 }, { 436, 168 } }
  rimOf(union(post, b1, b2), L.timber)
  logPosts(post)
  -- alpine trail signs: yellow and a red-white tipped one
  part(b1, L.gold) part(b2, L.awnB)
  hline(436, 452, 155, L.gold.deep) hline(438, 450, 165, L.awnB.deep)
  fill(rect(452, 163, 454, 167), L.awnA.base) fill(rect(434, 163, 435, 167), L.awnA.base)
  F.lichen(post, .2, 65)
end
signpost()

F.depth(3)
-- stacked goods on the left verge: crates of cheese and lingonberries, a sack, a keg of honey
F.shadow(198, 222, 180, 8, 3)
F.crate(198, 180, 12, 9, L.cheese)
F.crate(211, 180, 11, 9, L.apple)
F.crate(203, 170, 12, 8, L.gold)
F.sack(222, 182, L.awnB, 4)
F.shadow(200, 214, 204, 6, 2)
F.barrel(206, 204, honey, 11)
px(204, 197, honey.hi) px(205, 197, honey.hi)
F.sack(216, 206, L.needle, 4)
-- right verge by the notice board: larch firewood bundles for sale and a milk churn
F.shadow(258, 288, 146, 6, 2)
for k = 0, 2 do F.logEnd(262 + k * 7, 142, 3) end
for k = 0, 1 do F.logEnd(265 + k * 7, 136, 3) end
hline(260, 280, 139, L.awnA.base)
local function churn(x, yb)
  local body = c:rrect(x - 4, yb - 10, x + 4, yb, 2)
  local neck = rect(x - 2, yb - 13, x + 2, yb - 10)
  local lid = rect(x - 3, yb - 15, x + 3, yb - 14)
  rimOf(union(body, neck, lid), L.iron)
  part(body, L.iron) part(neck, L.iron, { nopop = true }) part(lid, L.iron, { nopop = true })
  vline(x - 3, yb - 9, yb - 1, L.iron.hi) hline(x - 4, x + 4, yb - 6, L.iron.deep)
  px(x - 2, yb - 15, L.iron.hi) px(x - 1, yb - 13, L.iron.hi)
end
F.shadow(278, 290, 150, 4, 2)
churn(283, 150)

---------------------------------------------------------------- the boulder house (plane 3, replaces the haystack house)
local function boulderHouse()
  local m = poly{ { 419, 224 }, { 421, 210 }, { 425, 198 }, { 431, 189 }, { 440, 184 }, { 450, 185 }, { 458, 191 }, { 463, 202 }, { 466, 214 }, { 467, 224 } }
  local pipe = rect(432, 176, 434, 186)
  shadow(424, 466, 224, 9, 3)
  rimOf(union(m, pipe), L.stone)
  part(m, L.stone)
  -- facets: a lit upper-left face, a ridge, a shaded right flank, crack lines
  m:each(function(x, y)
    local u = (x - 443) / 24 + (y - 184) / 40
    if u < .1 and y < 214 then px(x, y, L.stone.hi) elseif u > 1.05 then px(x, y, L.stone.shade) end
    if hash(x // 2, y // 2, 66) < .08 then px(x, y, L.stone.deep) end
  end)
  line({ { 446, 186 }, { 452, 196 }, { 451, 205 } }):each(function(x, y) px(x, y, L.stone.deep) end)
  line({ { 424, 206 }, { 430, 210 } }):each(function(x, y) px(x, y, L.stone.deep) end)
  line({ { 427, 197 }, { 437, 188 } }):each(function(x, y) if m:has(x, y) then px(x, y, L.edel.base) end end)
  F.lichen(m, .3, 67)
  part(pipe, L.iron, { nopop = true }) hline(431, 435, 176, L.iron.deep) px(432, 177, L.iron.hi)
  F.smoke(433, 168, 4, .4, 1)
  -- door with a larch frame, a round window glowing, a lintel slab
  door(436, 207, 446, 223, L.accent, true)
  local lin = rect(434, 204, 448, 205) rimOf(lin, L.timber) part(lin, L.timber, { nopop = true, noshade = true })
  local w = c:ellipse(455, 199, 3, 3) rimOf(w, L.timber) fill(w, L.glow.base) px(454, 198, L.glow.hi) px(456, 200, L.glow.shade) px(455, 197, L.timber.base)
  -- geraniums on the sill, a boot scraper, junipers and edelweiss at the foot
  hline(451, 459, 203, L.timber.base) for x = 452, 458, 2 do px(x, 202, L.apple.base) px(x + 1, 201, L.apple.hi) end
  F.juniper(424, 225, 6, 4, 68) F.juniper(463, 226, 5, 3, 69)
  F.edelweiss(449, 225, true) F.gentian(429, 227, true)
  -- a turf cap on top with edelweiss
  hline(437, 449, 184, L.mossGround.base) hline(439, 447, 183, L.mossGround.hi) px(441, 182, L.fern.hi) F.edelweiss(440, 181)
end
boulderHouse()
F.goat(452, 186, { k = .5, flip = true, noShadow = true })

---------------------------------------------------------------- left: the wishing well (plane 3)
local function well()
  local S, T, RR = L.stone, L.timber, L.roof
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
  F.lichen(drum, .2, 71)
  drum:each(function(x, y) if y > 202 and hash(x, y, 70) < .3 then px(x, y, S.shade) end end)
  part(lipFront, S, { sep = true }) courses(lipFront, 156, 10, 17, S, 5)
  F.lichen(lipFront, .15, 72)
  part(lipTop, S, { sep = true })
  lipTop:each(function(x, y) if hash(x // 2, y, 73) < .16 then px(x, y, L.moss.hi) end end)
  local opening = poly{ { 106, 149 }, { 180, 149 }, { 184, 154 }, { 102, 154 } }
  fill(opening, L.water.deep) hline(110, 178, 149, S.edge) hline(118, 128, 152, L.water.shade) hline(156, 170, 151, L.water.shade)
  px(165, 152, L.snow.hi) px(166, 152, L.water.hi) -- the sky (and a peak) mirrored far down
  logPosts(union(postL, postR))
  part(axle, T, { nopop = true }) hline(110, 176, 130, T.hi)
  for x = 136, 150, 3 do vline(x, 131, 133, L.board.base) end
  fill(rope, L.board.base) part(crank, T, { nopop = true }) fill(rect(188, 140, 191, 143), L.accent.base)
  part(bucket, T) hline(135, 151, 144, L.iron.shade) hline(136, 150, 150, L.iron.shade)
  line({ { 135, 141 }, { 143, 137 }, { 151, 141 } }):each(function(x, y) px(x, y, L.iron.deep) end)
  hline(137, 149, 142, L.water.hi)
  -- granite slab roof, lichened, weighted with stones
  part(roofM, RR, { sep = true }) courses(roofM, 92, 4, 7, RR)
  F.lichen(roofM, .22, 74)
  line({ { 91, 120 }, { 143, 93 } }):each(function(x, y) if roofM:has(x, y) then px(x, y, RR.hi) end end)
  hline(90, 196, 126, RR.edge) hline(91, 195, 125, RR.deep)
  for _, w in ipairs({ { 103, 117 }, { 122, 107 }, { 164, 107 }, { 183, 117 } }) do wstone(w[1], w[2]) end
  part(gable, L.board, { nopop = true })
  F.planks(gable, L.timber, 4, true, 75)
  vline(143, 106, 121, T.base)
  line({ { 143, 112 }, { 130, 120 } }):each(function(x, y) px(x, y, T.base) end)
  line({ { 143, 112 }, { 156, 120 } }):each(function(x, y) px(x, y, T.base) end)
  -- a little cairn finial
  for _, s in ipairs({ { 143, 90, 4, 2 }, { 142, 86, 3, 2 }, { 143, 83, 2, 1 } }) do
    local m = c:ellipse(s[1], s[2], s[3], s[4]) rimOf(m, S) part(m, S, { nopop = true }) px(s[1] - 1, s[2] - s[4] + 1, S.hi)
  end
  -- grass, junipers and edelweiss at the drum foot, coins glinting
  for _, f in ipairs({ { 98, 208, 5 }, { 106, 210, 4 }, { 186, 208, 5 } }) do F.fern(f[1], f[2], f[3]) end
  F.juniper(193, 208, 6, 4, 76) F.edelweiss(112, 210, true) F.gentian(180, 210, true)
  c:sparkle(176, 160)
end
well()

---------------------------------------------------------------- left: the Seed Swap chalet shop (plane 3)
local function seed()
  local top, cx, wall, roofM = F.building{ x0 = 19, x1 = 75, yb = 212, wh = 42, rh = 16, wall = L.timber, roof = L.roof, shingle = true, noFrame = true, noAttic = true }
  F.planks(wall, L.timber, 3, false, 77)
  local base = rect(19, 200, 75, 212) rubble(base, 200, 78) chalk(base)
  F.lichen(roofM, .2, 76)
  wstone(30, top - 2) wstone(64, top - 2)
  -- larch sapling finial
  F.larch(cx, top - 15, 10, 77)
  -- shop window full of seed packets and alpine-herb jars
  fill(rect(23, 183, 71, 199), L.timber.deep) fill(rect(24, 184, 70, 198), L.glow.shade)
  fill(rect(24, 184, 70, 187), L.glow.base)
  for i = 0, 7 do
    local x = 25 + i * 6
    local rr = ({ L.awnA, L.awnB, L.gentian, L.produce, L.leaf, blueb, L.gold, L.wall2 })[i + 1]
    local pk = rect(x, 186 + (i % 2), x + 4, 192 + (i % 2)) part(pk, rr, { nopop = true }) px(x + 1, 187 + (i % 2), rr.hi)
    hline(x, x + 4, 189 + (i % 2), rr.deep)
  end
  hline(24, 70, 193, L.timber.base)
  for i = 0, 4 do
    local x = 26 + i * 9
    fill(rect(x, 194, x + 5, 198), L.water.hi) hline(x, x + 5, 194, L.timber.base)
    fill(rect(x + 1, 196, x + 4, 198), (i % 2 == 0) and L.fern.shade or L.lav.base)
    px(x + 1, 196, (i % 2 == 0) and L.fern.hi or L.lav.hi)
  end
  -- striped awning
  local aw = poly{ { 18, 182 }, { 22, 174 }, { 72, 174 }, { 76, 182 } }
  for x = 18, 76, 4 do aw:add(poly{ { x, 182 }, { x + 4, 182 }, { x + 2, 185 } }) end
  aw:clip(rect(17, 170, 77, 186))
  rimOf(aw, L.awnA)
  stripes(aw, 18, 4, L.awnA, L.awnB)
  hline(22, 72, 174, L.awnB.hi)
  -- hanging sign: an edelweiss
  vline(30, 168, 170, L.timber.edge) vline(40, 168, 170, L.timber.edge)
  local sg = rect(28, 160, 42, 167) rimOf(sg, L.timber) part(sg, L.board)
  F.sprite({ "..e..", ".eEe.", "eEyEe", ".eEe.", "..e.." }, 33, 161, { e = L.edel.shade, E = L.edel.hi, y = L.gold.base }, { rim = false })
  door(26, 200, 32, 211, L.timber)
  -- crate of potted edelweiss and gentians for swapping
  local crate = rect(48, 202, 72, 211) rimOf(crate, L.timber) part(crate, L.board) hline(48, 72, 206, L.board.deep)
  for i = 0, 3 do
    local x = 51 + i * 6
    local pot = rect(x - 2, 198, x + 2, 202) rimOf(pot, L.roof2) part(pot, L.roof2, { nopop = true }) hline(x - 2, x + 2, 198, L.roof2.hi)
    px(x - 1, 197, L.juniper.base) px(x + 1, 197, L.juniper.shade)
    if i % 2 == 0 then F.edelweiss(x, 195, true) else F.gentian(x, 195, true) end
  end
end
seed()
F.fern(22, 214, 5) F.juniper(82, 213, 6, 4, 79)

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
  -- back wall of larch boards, a shelf of cheeses over a shelf of honey and herb jars
  fill(back, T.deep)
  F.planks(rect(301, 179, 399, 194), T, 5, true, 80)
  hline(301, 399, 186, T.edge) hline(301, 399, 193, T.edge)
  for i = 0, 11 do
    local x = 305 + i * 8
    if x < 340 or x > 364 then cheese(x, 185, 3, 4) end
  end
  for i = 0, 15 do
    local x = 303 + i * 6
    if x < 342 or x > 362 then hjar(x, 192, ({ honey, L.leaf, honey, L.lav, honey, L.apple })[i % 6 + 1], (i % 3 == 0) and L.awnA or L.awnB) end
  end
  -- the stallkeeper, behind the counter
  F.gnome(352, 202, { hat = L.awnA, coat = L.leaf, arm = "up", noShadow = true })
  -- lichened granite slab roof with weighting stones + red/cream valance
  part(roof, L.roof, { sep = true }) courses(roof, 151, 3, 6, L.roof)
  F.lichen(roof, .22, 81)
  line({ { 289, 167 }, { 300, 152 } }):each(function(x, y) if roof:has(x, y) then px(x, y, L.roof.hi) end end)
  hline(300, 400, 151, L.roof.hi)
  for _, w in ipairs({ { 306, 160 }, { 324, 156 }, { 378, 156 }, { 396, 160 } }) do wstone(w[1], w[2]) end
  stripes(val, 289, 8, L.awnA, L.awnB)
  hline(289, 411, 167, L.awnA.deep)
  -- sign on the ridge with the wares painted on: cheese, edelweiss, jar, sausage, herbs
  local sign = rect(330, 143, 370, 150)
  rimOf(sign, T) part(sign, L.board) hline(331, 369, 150, L.board.deep)
  F.sprite({ ".cc.", "cccc", "CCCC" }, 333, 145, { c = L.cheese.base, C = L.cheese.shade }, { rim = false })
  F.sprite({ ".e.", "eye", ".e." }, 340, 145, { e = L.edel.base, y = L.gold.base }, { rim = false })
  F.sprite({ "aaa", "hhh", "hhh" }, 346, 145, { a = L.awnA.base, h = honey.shade }, { rim = false })
  F.sprite({ "s...", ".sss", "..ss" }, 352, 145, { s = speck.shade }, { rim = false })
  F.sprite({ ".f.", "fff", ".f." }, 360, 145, { f = L.fern.shade }, { rim = false })
  vline(336, 151, 151, T.deep) vline(364, 151, 151, T.deep)
  -- hanging under the valance: lanterns, cured sausages, alpine-herb bundles
  lantern(304, 180, 1)
  lantern(396, 180, 1)
  hline(310, 334, 179, L.board.deep)
  for k = 0, 3 do sausage(311 + k * 6, 180) end
  for k = 0, 2 do herbs(368 + k * 6, 180, k == 1 and L.lav or L.fern, k == 0 and L.gold or (k == 2 and L.edel or nil)) end
  -- counter: larch planks, plank top
  part(cfront, T)
  F.planks(cfront, T, 4, true, 84)
  for x = 296, 404, 27 do vline(x, 200, 220, T.edge) end
  part(ctop, L.board) hline(299, 401, 194, L.board.hi)
  part(legs, T, { nopop = true })
  -- goods on the counter
  basket(300, 320, 198, 5, blueb, "berry", 82)
  basket(322, 340, 198, 5, L.apple, "berry", 83)
  basket(364, 384, 198, 5, L.redbark, "cone", 84)
  for k = 0, 2 do hjar(386 + k * 5, 198, honey, L.awnA) end
  -- a cut cheese on a board: a wheel with a wedge out of it
  local board2 = rect(341, 197, 351, 198) fill(board2, L.board.shade) hline(341, 351, 197, L.board.hi)
  local cw = c:rrect(342, 192, 350, 196, 2) c:rim(cw, L.cheese.edge) part(cw, L.cheese, { nopop = true })
  hline(343, 349, 192, L.cheese.hi) fill(rect(348, 192, 350, 194), L.cheese.hi) px(349, 193, L.cheese.base)
  -- crates in front: cheese wheels, arolla cones
  local cr1 = rect(308, 210, 332, 222) rimOf(cr1, T) part(cr1, L.board) hline(308, 332, 216, L.board.deep)
  cr1:each(function(x, y) if hash(x // 3, y, 85) < .1 then px(x, y, L.board.shade) end end)
  for k = 0, 2 do cheese(313 + k * 7, 209, 3, 3) end
  cheese(316, 205, 3, 3) cheese(323, 205, 3, 3)
  local cr2 = rect(362, 210, 386, 222) rimOf(cr2, T) part(cr2, L.board) hline(362, 386, 216, L.board.deep) vline(374, 210, 222, L.board.deep)
  for k = 0, 5 do local x = 364 + k * 4 px(x, 208, L.redbark.hi) fill(rect(x, 209, x + 2, 210), L.redbark.base) px(x + 2, 210, L.redbark.deep) px(x + 1, 207, L.redbark.shade) end
  -- a great wheel of mountain cheese standing against the counter, face-on: a thick rind, a branded stamp,
  -- and a wedge cut from it lying in front
  local big = c:ellipse(345, 214, 9, 8)
  rimOf(big, L.cheese) part(big, L.cheese, { nopop = true })
  big:each(function(x, y)
    local d = math.sqrt((x - 345) ^ 2 + ((y - 214) * 9 / 8) ^ 2)
    local lit = (x - 345) + (y - 214) < 0
    if d > 7.2 then px(x, y, lit and L.cheese.shade or L.cheese.deep) -- the rind band
    elseif d > 6.2 then px(x, y, lit and L.cheese.hi or L.cheese.shade)
    elseif (x - 345) + (y - 214) < -5 then px(x, y, L.cheese.hi) end
  end)
  -- the branded stamp: a ring with an edelweiss star
  local ring = c:ellipse(345, 214, 3, 3):cut(c:ellipse(345, 214, 2, 2))
  fill(ring, L.cheese.shade)
  px(345, 213, L.cheese.deep) px(344, 214, L.cheese.deep) px(346, 214, L.cheese.deep) px(345, 215, L.cheese.deep)
  local wd = poly{ { 352, 223 }, { 360, 216 }, { 361, 223 } }
  local wdr = rect(352, 223, 361, 224)
  rimOf(union(wd, wdr), L.cheese)
  fill(wd, L.cheese.hi) wd:each(function(x, y) if hash(x, y, 87) < .15 then px(x, y, L.cheese.base) end end)
  fill(wdr, L.cheese.shade) hline(352, 361, 224, L.cheese.deep)
  vline(361, 217, 223, L.cheese.shade)
  F.sack(392, 224, L.awnB, 4)
end
stall()
basket(410, 426, 224, 5, blueb, "berry", 90)
basket(414, 430, 214, 5, L.redbark, "cone", 91)
-- a shopper with a basket, by the stall
local _, shx, shy = F.gnome(284, 228, { hat = L.roof2, coat = L.wall2, arm = "out", flip = true })
local bk = poly{ { shx - 3, shy }, { shx + 3, shy }, { shx + 2, shy + 5 }, { shx - 2, shy + 5 } }
rimOf(bk, L.timber) part(bk, L.board, { nopop = true })
px(shx - 1, shy - 1, L.cheese.base) px(shx, shy - 1, L.cheese.hi) px(shx + 1, shy - 1, L.edel.hi)
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
  stripes(can, 120, 4, L.awnB, L.accent)
  hline(128, 180, 222, L.awnB.hi)
  part(legs, L.timber, { nopop = true })
  part(top, L.board) F.planks(top, L.board, 5, true, 86)
  part(cloth, L.awnA, { nopop = true })
  cloth:each(function(x, y) if ((x // 3) + (y // 2)) % 2 == 0 then px(x, y, L.awnA.shade) end end) -- gingham
  for x = 127, 181, 3 do px(x, 254, L.awnA.hi) end
  part(bench, L.timber, { nopop = true })
  -- feast: enamel teapot, bilberry tart, honey pot, a cheese board, a loaf, plates
  local tp = poly{ { 134, 239 }, { 142, 239 }, { 143, 245 }, { 133, 245 } }
  rimOf(tp, L.accent) part(tp, L.accent) line({ { 143, 241 }, { 146, 238 } }):each(function(x, y) px(x, y, L.accent.deep) end)
  px(137, 238, L.accent.deep) px(138, 238, L.accent.deep) px(136, 241, L.edel.hi) px(139, 243, L.edel.base)
  local pie = poly{ { 150, 243 }, { 162, 243 }, { 164, 246 }, { 148, 246 } } rimOf(pie, L.board) part(pie, L.board, { nopop = true })
  hline(151, 161, 244, blueb.base) for x = 151, 161, 3 do px(x, 244, L.board.hi) end
  local hp = c:rrect(166, 240, 171, 246, 2) rimOf(hp, honey) part(hp, honey) hline(166, 171, 240, L.awnA.base)
  vline(173, 239, 241, L.timber.edge)
  -- cheese board + loaf at the right end
  hline(174, 179, 246, L.board.shade)
  local wdg = poly{ { 174, 245 }, { 178, 242 }, { 179, 245 } } fill(wdg, L.cheese.base) px(177, 243, L.cheese.hi) hline(174, 179, 245, L.cheese.shade)
  for x = 131, 175, 11 do if x < 170 then hline(x, x + 3, 247, L.plaster.hi) px(x + 1, 246, L.cheese.base) end end
  lantern(130, 236, 0)
  lantern(178, 236, 0)
end
longTable()

---------------------------------------------------------------- bottom left: the glacial tarn with a larch jetty (plane 3)
local function pond()
F.boulder(112, 233, 6, 5, 54)
F.marmot(112, 228, { flip = true })
  local bank = poly{ { 18, 238 }, { 32, 228 }, { 72, 226 }, { 100, 232 }, { 108, 246 }, { 100, 260 }, { 60, 264 }, { 26, 262 }, { 16, 252 } }
  local water = bank:shrink(3)
  shadow(24, 104, 262, 6, 3)
  rimOf(bank, L.water)
  fill(bank, L.soil.base)
  bank:each(function(x, y) if not water:has(x, y) then local v = hash(x, y, 51) px(x, y, v < .4 and L.stone.base or (v < .7 and L.stone.hi or L.stone.shade)) end end)
  F.water(water, L.water)
  -- reflections: dark spruces and a pale snowy peak along the far edge
  for _, rx in ipairs({ 36, 84 }) do for k = 0, 4 do hline(rx - 3 + k // 2, rx + 3 - k // 2, 233 + k * 2, L.water.shade) end end
  for k = 0, 4 do hline(52 + k, 64 - k, 232 + k * 2, L.water.hi) end
  -- stones in the water with a dipper bobbing on one
  for _, b in ipairs({ { 44, 247, 4, 3 }, { 58, 254, 3, 2 } }) do F.boulder(b[1], b[2], b[3], b[4], b[1]) hline(b[1] - b[3] - 1, b[1] + b[3] + 1, b[2] + 1, L.water.hi) end
  F.sprite({ "..dd....", ".dbbd...", "dbebd..t", "kdWbbdtt", ".dWbbbd.", "..ddd...", "..o.o..." }, 41, 238,
    { d = "#4a3a36", b = "#6e5448", W = L.edel.hi, e = L.timber.edge, k = L.iron.deep, t = "#4a3a36", o = L.timber.deep })
  -- jetty
  local jet = poly{ { 70, 240 }, { 104, 240 }, { 106, 250 }, { 72, 250 } }
  local legs = rect(74, 250, 76, 257):add(rect(100, 250, 102, 256)):add(rect(86, 250, 88, 256))
  rimOf(union(jet, legs), L.timber)
  part(legs, L.timber, { nopop = true })
  part(jet, L.board)
  jet:each(function(x, y) if (x - y // 3) % 5 == 0 then px(x, y, L.board.deep) end end)
  hline(72, 105, 250, L.timber.deep)
  F.lichen(legs, .3, 52)
  -- rod leaning, line + red float
  line({ { 98, 240 }, { 80, 222 }, { 66, 220 } }):each(function(x, y) px(x, y, L.timber.deep) end)
  vline(66, 221, 236, L.awnB.shade) fill(rect(65, 236, 67, 238), L.awnA.base) px(65, 236, L.awnA.hi)
  hline(62, 70, 239, L.water.hi)
  -- cotton grass: white tufts on fine stems
  for i = 0, 7 do
    local x = 19 + i * 3 + floor(hash(i, 1, 52) * 2) local h = 6 + floor(hash(i, 9, 52) * 8)
    local yb = 254 - (i % 3)
    vline(x, yb - h, yb, i % 2 == 0 and L.fern.shade or L.fern.deep)
    px(x, yb - h - 1, L.edel.hi) px(x + 1, yb - h - 1, L.edel.base) px(x, yb - h - 2, L.edel.hi) px(x + 1, yb - h, L.edel.shade)
  end
  -- tackle box and a basket of arctic char on the jetty
  local box = rect(90, 234, 99, 239) rimOf(box, L.accent) part(box, L.accent) hline(90, 99, 236, L.accent.deep)
  local fb = poly{ { 78, 234 }, { 86, 234 }, { 85, 239 }, { 79, 239 } } rimOf(fb, L.timber) part(fb, L.board, { nopop = true })
  for x = 79, 85, 2 do vline(x, 235, 238, L.board.shade) end
  px(80, 233, charR.base) px(81, 233, charR.hi) px(82, 233, charR.shade) px(83, 233, charR.base) px(84, 232, charR.hi)
  F.boulder(16, 238, 6, 5, 53)
end
pond()

---------------------------------------------------------------- bottom right: the alpine herb bed (plane 3)
local function forage()
  local T = L.timber
  local soil = poly{ { 304, 247 }, { 368, 247 }, { 374, 254 }, { 298, 254 } }
  local front = rect(298, 254, 374, 262)
  local back = rect(304, 245, 368, 247)
  shadow(300, 374, 262, 8, 2)
  rimOf(union(soil, front, back), L.stone)
  part(back, T, { nopop = true })
  fill(soil, L.soil.base) soil:each(function(x, y) if hash(x, y, 71) < .2 then px(x, y, L.soil.deep) elseif hash(x, y, 72) < .1 then px(x, y, L.stone.base) end end)
  -- a dry-stone front, lichened
  part(front, L.stone) courses(front, 254, 4, 8, L.stone) F.lichen(front, .25, 73)
  for i, x in ipairs({ 308, 330, 352 }) do -- edelweiss clumps: a woolly grey rosette, three stars
    local ro = poly{ { x - 5, 251 }, { x - 3, 247 }, { x + 3, 247 }, { x + 5, 251 } }
    rimOf(ro, L.juniper) part(ro, L.juniper) ro:each(function(xx, y) if hash(xx, y, 74) < .3 then px(xx, y, L.edel.shade) end end)
    F.edelweiss(x - 2, 244, true) F.edelweiss(x + 2, 242, true) F.edelweiss(x + 1, 246)
  end
  for i, x in ipairs({ 319, 341, 363 }) do -- alpine-rose bushes, gentians and arnica at their feet
    local b = poly{ { x - 6, 251 }, { x - 4, 243 }, { x, 239 }, { x + 4, 243 }, { x + 6, 251 } }
    rimOf(b, L.foliage2) part(b, L.foliage2)
    b:each(function(xx, y) if hash(xx, y, 73) < .14 then px(xx, y, L.petal.base) px(xx, y - 1, L.petal.hi) end end)
    F.gentian(x - 7, 251, true) px(x + 7, 250, L.gold.hi) px(x + 7, 251, L.gold.shade) px(x + 8, 250, L.gold.base)
  end
  fill(rect(371, 238, 372, 246), T.base)
  local bl = poly{ { 369, 246 }, { 374, 246 }, { 372, 251 } } fill(bl, L.iron.base) px(370, 246, L.iron.hi)
end
forage()

---------------------------------------------------------------- near grass, junipers, flowers, a goat on the road, sky life
for _, f in ipairs({ { 112, 262, 6 }, { 192, 262, 7 }, { 286, 258, 6 }, { 376, 226, 5 }, { 414, 228, 5 }, { 196, 226, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.juniper(200, 252, 7, 4, 92) F.juniper(290, 240, 5, 3, 93)
F.edelweiss(204, 262, true) F.edelweiss(210, 265, true) F.gentian(207, 259, true) F.edelweiss(118, 266, true)
F.goat(266, 258, { k = .7, flip = true })
F.edelweiss(250, 258) -- the dropped bloom it is after
F.depth(0)
F.birds({ { 300, 30, 2 }, { 310, 36, 1 }, { 120, 64, 2 }, { 410, 50, 1 }, { 380, 40, 1 } })

F.finish()
