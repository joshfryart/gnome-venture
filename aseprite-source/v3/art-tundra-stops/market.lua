-- market.lua : "Market hamlet" stop look, TUNDRA (tundra_frost), 480x270 gate view.
-- Same composition and hotspots as the Maplewold market (here-gate/pilot-market.lua) and the forest market, re-cast
-- as a snow market where SLEDS ARE THE STALLS.
-- Road's end: the Wild Trail through a gate of stacked snow blocks under a driftwood lintel crowned with a reindeer
-- antler rack, a lantern, a path running off between spruces toward the fells.
-- Back left: a reindeer-hide lavvu (tent) with smoke from its pole crown and a falu-red sod-roofed cottage.
-- Back right: a slate-roofed notice board (a carved raven on the peak) and the sod-roofed driftwood rest lodge with
-- reindeer-hide bench, striped blanket and a steaming copper kettle.
-- Left: the wishing well over a warm spring (steam, glowing water), and the Seed Swap: a hooped covered sled booth
-- with seed jars and potted spruce seedlings. Right hero: the trader sled-stall: curled runners, painted bed,
-- a striped wool canopy under snow, a rack of dried fish, birch-bark baskets of cloudberries, lingonberries and
-- crowberries, carved wooden toys, lanterns, a gnome stallkeeper, and a harnessed reindeer on the road.
-- Bottom: the frozen fishing pond (ice hole, tip-up flag, a gnome jigging, a ringed seal popping up), the long table
-- under a blue-striped canopy (kettle, cloudberry pie, steaming bowls), and the forage bed (cloudberry,
-- lingonberry, reindeer lichen).
-- Quirks kept from Maplewold in tundra dress: the teapot-hatted scarecrow is a teapot-hatted SNOWMAN, the barrow
-- growing something too big is a sled hauling a giant cloudberry, the snail mailbox is a seal mailbox, the haystack
-- house is an igloo, and an arctic fox in a red gnome hat curls on its dome.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-tundra-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "market", out = DIR, treeLineGap = { 204, 276 },
  peaks = { { 118, 34, 40 }, { 172, 46, 42 }, { 300, 38, 40 }, { 352, 50, 46 }, { 424, 34, 36 }, { 28, 24, 30 } },
  farTrees = { 30, 64, 196, 300, 330, 448 },
  clouds = { { 150, 30, 56 }, { 330, 40, 64 }, { 420, 22, 40 }, { 30, 50, 36 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local courses, shadow, window, door = F.courses, F.shadow, F.window, F.door
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local S = L.snow

-- local ramps for market goods
local cloudb = F.rp("#ffd894 #f6a84c #d27c30 #9c5626 #5e321c") -- cloudberries (amber)
local crowb = F.rp("#9690bc #5c5684 #403b62 #2c2846 #1c182c")  -- crowberries
local dfish = F.rp("#eedcbc #ccb288 #a48866 #765e4e #46383a")  -- dried / stock fish
local copper = F.rp("#f6c08a #dc8a52 #b0623a #7c4430 #4a2822")
local SACK = F.rp("#ecd6aa #ccae80 #a68660 #7a604a #4a3a34")
local hide = F.rp("#e2ccae #c0a282 #96785e #6c5446 #403032")   -- tanned reindeer hide
local wool = L.accent                                           -- Sami blue wool

---------------------------------------------------------------- local helpers
local function hjar(x, yb, r, lidR) -- little jar 4 wide, 6 tall, cloth lid
  local m = rect(x, yb - 5, x + 3, yb)
  rimOf(m, L.timber)
  fill(m, r.base) vline(x, yb - 4, yb, r.hi) vline(x + 3, yb - 4, yb, r.shade) hline(x, x + 3, yb, r.deep)
  hline(x, x + 3, yb - 5, (lidR or L.awnA).base) px(x + 1, yb - 5, (lidR or L.awnA).hi)
  px(x + 1, yb - 3, "#f6f2e6")
  return m
end
-- birch-bark basket heaped with berries (2x2 round berries, lit dot, dark gaps)
local function basket(x0, x1, yb, h, r, seed, snowy)
  local body = poly{ { x0, yb - h }, { x1, yb - h }, { x1 - 2, yb }, { x0 + 2, yb } }
  local mid = (x0 + x1) // 2
  local heap = poly{ { x0 + 1, yb - h }, { x0 + 3, yb - h - 4 }, { mid, yb - h - 6 }, { x1 - 3, yb - h - 4 }, { x1 - 1, yb - h } }
  rimOf(union(body, heap), L.timber)
  part(body, L.birch, { nopop = true })
  body:each(function(x, y)
    if hash(x // 3, y, seed) < .22 then px(x, y, L.birch.edge) end -- lenticels
    if (x - x0) % 5 == 0 then px(x, y, L.birch.shade) end
  end)
  hline(x0, x1, yb - h, L.redbark.base) hline(x0 + 1, x1 - 1, yb - h + 1, L.redbark.deep)
  part(heap, r, { nopop = true })
  heap:each(function(x, y)
    local bx, by = (x + (y // 2) % 2) % 2, y % 2
    if bx == 0 and by == 0 then px(x, y, r.hi) elseif bx == 1 and by == 1 then px(x, y, r.deep) end
  end)
  px(x0 + 3, yb - h - 3, L.foliage.base) px(x0 + 4, yb - h - 4, L.foliage.hi) px(x1 - 4, yb - h - 2, L.foliage.shade)
  if snowy then hline(mid - 2, mid + 1, yb - h - 6, S.hi) end
  return body
end
local function fish(x, y, r) -- a split dried fish hanging head-down, 3 wide, 9 tall
  r = r or dfish
  F.sprite({ ".t.", "tbt", "sbs", "sbs", "sbS", "sbS", ".s.", "sSs", "s.s" }, x, y,
    { t = r.deep, s = r.base, b = r.hi, S = r.shade })
end
local function lantern(x, y, cord) -- little hanging lantern, top at y
  if cord and cord > 0 then vline(x, y - cord, y - 1, L.timber.edge) end
  local l = rect(x - 2, y + 1, x + 2, y + 6)
  local cap = rect(x - 2, y, x + 2, y)
  rimOf(union(l, cap), L.timber)
  fill(l, L.glow.base) px(x - 2, y + 1, L.glow.hi) px(x - 1, y + 1, L.glow.hi) vline(x + 2, y + 2, y + 6, L.glow.shade)
  hline(x - 2, x + 2, y, L.timber.base) hline(x - 1, x + 1, y + 6, L.timber.deep)
  px(x, y - 1, S.hi)
end
local function stripes(m, x0, w, rA, rB)
  m:each(function(x, y) px(x, y, ((x - x0) // w) % 2 == 0 and rA.base or rB.base) end)
  m:each(function(x, y) if not m:has(x, y + 1) then px(x, y, (((x - x0) // w) % 2 == 0 and rA or rB).shade) end end)
  m:each(function(x, y) if ((x - x0) % w) == 0 and m:has(x, y + 1) and ((x - x0) // w) % 2 == 0 then px(x, y, rA.hi) end end)
end
local function poles(m) -- round driftwood poles: lit left, dark right, weathered flecks
  rimOf(m, L.timber)
  part(m, L.timber, { nopop = true, noshade = true })
  m:each(function(x, y)
    if not m:has(x - 1, y) then px(x, y, L.timber.hi)
    elseif not m:has(x + 1, y) then px(x, y, L.timber.shade) end
    if hash(x, y // 3, 88) < .12 then px(x, y, L.timber.deep) end
  end)
end
-- snow / ice block masonry: rows of cut blocks, some glazed ice blue, lit top-left faces
local function snowBlocks(m, y0, rowH, bw, seed)
  m:each(function(x, y)
    local row = (y - y0) // rowH
    local ry = (y - y0) % rowH
    local off = (row % 2) * (bw // 2)
    local bx, rx = (x + off) // bw, (x + off) % bw
    local v = hash(bx, row, seed)
    local R = v < .24 and L.ice or S
    local h
    if ry == rowH - 1 or rx == 0 then h = (v < .24) and L.ice.deep or S.deep
    elseif ry == 0 or rx == 1 then h = R.hi
    elseif rx == bw - 1 or ry == rowH - 2 then h = R.shade
    else h = (hash(x, y, seed + 1) < .08) and R.hi or R.base end
    px(x, y, h)
  end)
end
-- Sami-style woven band: red ground, gold zigzag, blue edges (x0..x1 at rows y..y+3)
local function band(x0, x1, y)
  hline(x0, x1, y, wool.base) hline(x0, x1, y + 3, wool.shade)
  for x = x0, x1 do
    px(x, y + 1, L.awnA.base) px(x, y + 2, L.awnA.shade)
    local k = (x - x0) % 4
    if k == 0 then px(x, y + 2, L.gold.hi) elseif k == 1 or k == 3 then px(x, y + 1 + (k == 1 and 0 or 0), L.gold.base) elseif k == 2 then px(x, y + 1, L.gold.hi) end
  end
end
-- antler pair rising from (cx, y): beams curve out and up, tines toward the centre; returns the mask
local function antlerMask(cx, y, span, h)
  local m = HP.mask()
  for _, s in ipairs({ -1, 1 }) do
    local function P(dx, dy) return { cx + dx * s, y + dy } end
    m:add(line({ P(1, 0), P(span * .45, -h * .35), P(span * .8, -h * .7), P(span, -h) }, 1))
    m:add(line({ P(span * .45, -h * .35), P(span * .3, -h * .62) }, 1))
    m:add(line({ P(span * .65, -h * .55), P(span * .5, -h * .9) }, 1))
    m:add(line({ P(span * .8, -h * .7), P(span * 1.05, -h * .78) }, 1))
    m:add(line({ P(2, -1), P(4, -h * .3) }, 1)) -- brow tine
  end
  return m
end
local function paintBone(m, seed)
  m:each(function(x, y) px(x, y, hash(x, y, seed) < .3 and L.board.shade or (hash(x, y, seed + 1) < .3 and L.board.hi or L.board.base)) end)
end
-- reindeer: s = 1 faces right, -1 faces left. Harness collar + bell. Returns mask, collar point.
local function reindeer(x, yb, s, seed)
  local function P(dx, dy) return { x + dx * s, yb + dy } end
  local body = c:ellipse(x, yb - 15, 12, 6)
  local neck = poly{ P(6, -18), P(12, -26), P(17, -25), P(13, -14) }
  local head = c:ellipse(x + 16 * s, yb - 26, 4, 3):add(poly{ P(16, -28), P(23, -25), P(23, -22), P(17, -23) })
  local legs = HP.mask()
  for _, lx in ipairs({ -9, -5, 6, 10 }) do legs:add(line({ P(lx, -11), P(lx + (lx > 0 and 1 or -1), 0) }, 2)) end
  local tail = rect(math.min(x - 13 * s, x - 12 * s), yb - 19, math.max(x - 13 * s, x - 12 * s), yb - 16)
  local antl = HP.mask()
  for _, a in ipairs({ { P(14, -29), P(11, -35), P(9, -42), P(12, -47) }, { P(17, -29), P(19, -36), P(18, -43), P(22, -47) },
    { P(11, -35), P(7, -37) }, { P(10, -40), P(5, -42) }, { P(19, -36), P(23, -39) }, { P(18, -41), P(23, -44) }, { P(15, -30), P(18, -33) } }) do
    antl:add(line(a, 1))
  end
  local m = union(body, neck, head, legs, tail, antl)
  F.shadowM(c:ellipse(x - 4 * s, yb + 1, 16, 2))
  rimOf(m, L.deer)
  part(legs, L.deer, { nopop = true, noshade = true })
  legs:each(function(xx, yy) if yy > yb - 3 then px(xx, yy, L.deer.edge) elseif yy > yb - 6 then px(xx, yy, L.fur.base) end end)
  part(body, L.deer)
  body:each(function(xx, yy) if yy > yb - 12 then px(xx, yy, L.fur.shade) end end)
  part(neck, L.fur, { nopop = true })
  neck:each(function(xx, yy) if hash(xx, yy, seed) < .25 then px(xx, yy, L.fur.shade) end end)
  part(head, L.deer, { nopop = true })
  px(x + 17 * s, yb - 27, L.timber.edge) px(x + 23 * s, yb - 24, L.timber.edge) px(x + 13 * s, yb - 28, L.deer.deep)
  part(antl, L.board, { nopop = true, noshade = true })
  antl:each(function(xx, yy) if hash(xx, yy, seed + 1) < .35 then px(xx, yy, L.board.shade) end end)
  antl:each(function(xx, yy) if not antl:has(xx, yy - 1) and hash(xx, yy, seed + 2) < .3 then px(xx, yy - 1, S.hi) end end)
  part(tail, L.fur, { nopop = true, noshade = true })
  -- harness: a woven collar with a brass bell
  local collar = line({ P(9, -20), P(13, -15) }, 2)
  collar:each(function(xx, yy) px(xx, yy, ((xx + yy) % 3 == 0) and L.gold.base or L.awnA.base) end)
  fill(rect(math.min(x + 13 * s, x + 14 * s), yb - 14, math.max(x + 13 * s, x + 14 * s), yb - 13), L.gold.base) px(x + 13 * s, yb - 14, L.gold.hi)
  -- a blue saddle blanket with a band
  local sad = poly{ P(-4, -21), P(4, -21), P(5, -14), P(-5, -14) }
  fill(sad, wool.base) hline(x - 5, x + 5, yb - 15, L.awnA.base) hline(x - 4, x + 4, yb - 21, wool.hi)
  for xx = x - 4, x + 4, 2 do px(xx, yb - 15, L.gold.base) end
  return m, x + 10 * s, yb - 16
end

---------------------------------------------------------------- far quirks (plane 1): teapot-hat snowman + giant cloudberry sled
F.depth(1)
F.tree(196, 118, 30, 1, true)
local function snowman()
  local b1, b2, hd = c:ellipse(109, 104, 8, 7), c:ellipse(109, 92, 6, 5), c:ellipse(109, 82, 5, 4)
  local body = union(b1, b2, hd)
  local hat = poly{ { 104, 73 }, { 114, 73 }, { 115, 78 }, { 103, 78 } }
  local spout = line({ { 115, 75 }, { 119, 72 } })
  local handle = line({ { 103, 74 }, { 101, 75 }, { 101, 77 }, { 103, 78 } })
  local lid = rect(107, 70, 110, 72)
  local arms = line({ { 103, 90 }, { 96, 84 }, { 94, 81 } }):add(line({ { 115, 90 }, { 122, 85 }, { 124, 86 } })):add(line({ { 96, 84 }, { 95, 86 } }))
  shadow(102, 117, 111, 6, 2)
  rimOf(union(body, hat, spout, lid, handle, arms), L.timber)
  fill(arms, L.redbark.shade)
  body:each(function(x, y)
    local ok = (x - 109) + (y - 92) * .4
    px(x, y, ok < -4 and S.hi or (ok < 3 and S.base or S.shade))
  end)
  for _, b in ipairs({ { b1, 104, 7 }, { b2, 92, 5 } }) do
    b[1]:each(function(x, y) if not b[1]:has(x, y + 1) and x > 104 then px(x, y, S.deep) end end)
  end
  hline(104, 114, 86, S.deep) hline(105, 113, 97, S.deep)
  px(107, 81, L.timber.edge) px(111, 81, L.timber.edge)
  hline(110, 113, 83, L.produce.base) px(110, 83, L.produce.hi) px(114, 83, L.produce.shade) -- carrot nose
  for _, y in ipairs({ 90, 94, 100, 104 }) do px(109, y, L.timber.edge) end
  -- red scarf with a tail blowing right
  hline(104, 114, 87, L.awnA.base) hline(105, 113, 88, L.awnA.shade)
  fill(rect(112, 88, 114, 94), L.awnA.base) vline(114, 88, 94, L.awnA.shade) hline(112, 114, 95, L.awnA.deep)
  for x = 105, 113, 2 do px(x, 87, L.awnA.hi) end
  part(hat, L.roof2) part(lid, L.roof2, { nopop = true }) fill(spout, L.roof2.shade) fill(handle, L.roof2.deep)
  hline(103, 115, 78, L.roof2.deep) hline(104, 114, 73, S.hi)
  -- a raven perched on the stick arm
  F.sprite({ ".kk..", "kKKk.", "kKKKk", ".kKKk", "..o.." }, 118, 80, { k = "#3a3646", K = "#56526a", o = L.gold.shade })
  px(119, 81, "#d6d2e0")
end
snowman()
local function cloudSled()
  local t = L.timber
  local bed = poly{ { 156, 96 }, { 188, 96 }, { 187, 101 }, { 157, 101 } }
  local run = line({ { 154, 103 }, { 188, 103 } }):add(line({ { 188, 103 }, { 192, 100 }, { 191, 97 } }))
  local rope = line({ { 154, 99 }, { 146, 104 } })
  local berry = c:ellipse(172, 76, 19, 18)
  local sep = poly{ { 158, 92 }, { 186, 92 }, { 190, 97 }, { 154, 97 } }
  local leaf = poly{ { 186, 90 }, { 196, 80 }, { 204, 84 }, { 202, 94 }, { 192, 98 } }
  local stem = line({ { 172, 58 }, { 174, 52 }, { 178, 50 } }, 2)
  rimOf(union(bed, run, berry, sep, leaf, stem), t)
  part(bed, L.wall2) F.planks(bed, L.wall2, 4, true, 33)
  part(run, L.iron, { nopop = true, noshade = true }) hline(154, 188, 103, L.iron.hi)
  fill(rope, L.board.deep)
  -- the cloudberry: a cluster of drupelets, each lit top-left, whole fruit darker lower right
  part(berry, cloudb)
  local dr = {}
  for t = 1, 900 do
    local gx, gy = floor(hash(t, 1, 93) * 40) - 20, floor(hash(t, 2, 94) * 38) - 19
    if (gx / 18) ^ 2 + (gy / 17) ^ 2 < 1.05 then
      local ok = true
      for _, e in ipairs(dr) do if (e[1] - gx) ^ 2 + (e[2] - gy) ^ 2 < 20 then ok = false break end end
      if ok then dr[#dr + 1] = { gx, gy } end
    end
  end
  table.sort(dr, function(p, q) return p[2] < q[2] end)
  fill(berry, cloudb.deep)
  for _, d in ipairs(dr) do
    local cx, cy = 172 + d[1], 76 + d[2]
    local m = c:ellipse(cx, cy, 2, 2):clip(berry)
    local sh = d[1] / 19 + d[2] / 18
    local base = sh < -.5 and cloudb.hi or (sh < .35 and cloudb.base or cloudb.shade)
    m:each(function(x, y)
      local lx, ly = x - cx, y - cy
      local h = base
      if lx + ly >= 2 then h = sh < .35 and cloudb.shade or cloudb.deep end
      if lx + ly <= -2 then h = sh < .35 and cloudb.hi or cloudb.base end
      px(x, y, h)
    end)
    px(cx - 1, cy - 1, sh < 0 and "#fff6d4" or cloudb.hi)
  end
  berry:each(function(x, y) if not berry:has(x + 1, y) or not berry:has(x, y + 1) then px(x, y, cloudb.deep) end end)
  -- papery sepals and the big crinkled leaf
  part(sep, L.leaf) sep:each(function(x, y) if (x % 5 == 0) then px(x, y, L.leaf.deep) end end)
  part(leaf, L.greyMoss) line({ { 188, 96 }, { 198, 85 } }):each(function(x, y) px(x, y, L.greyMoss.deep) end)
  leaf:each(function(x, y) if hash(x, y, 34) < .12 then px(x, y, L.leaf.base) end end)
  fill(stem, L.leaf.shade)
  hline(160, 168, 59, S.hi) hline(162, 166, 58, S.hi)
  F.drift(150, 106, 10, 3, 35)
end
cloudSled()

---------------------------------------------------------------- road's end: the Wild Trail through a snow-block gate (plane 2)
F.depth(2)
F.tree(202, 128, 60, 2)
F.tree(280, 126, 54, 1)
local function trail()
  local opening = poly{ { 222, 124 }, { 222, 80 }, { 258, 80 }, { 258, 124 } }
  fill(opening, L.foliage.edge)
  opening:each(function(x, y) if hash(x // 2, y, 31) < .3 then px(x, y, L.foliage.deep) end end)
  -- through the gate: a pale fell in the gap, receding snowy spruces, the trail running in
  fill(poly{ { 230, 104 }, { 240, 88 }, { 250, 104 } }, L.peak.shade)
  fill(poly{ { 230, 104 }, { 240, 88 }, { 240, 104 } }, L.peak.base) px(240, 88, L.peak.hi)
  fill(rect(223, 104, 257, 108), L.mist)
  for _, t in ipairs({ { 228, 112, 22, L.farTree }, { 252, 112, 24, L.farTree }, { 226, 121, 32, L.foliage2 }, { 255, 122, 34, L.foliage2 } }) do
    F.conifer(t[1], t[2], t[3], t[4], t[1], { far = t[4] == L.farTree, slim = true })
  end
  fill(poly{ { 233, 124 }, { 247, 124 }, { 242, 106 }, { 238, 106 } }, S.base)
  for i = 0, 3 do hline(239 - i, 241 + i, 110 + i * 4, S.shade) end
  px(239, 108, S.hi) px(242, 116, S.hi)
  -- snow-block pillars, a driftwood lintel, an antler rack on top
  local pL, pR = rect(209, 78, 221, 124), rect(259, 78, 271, 124)
  local lintel = rect(205, 70, 275, 78)
  shadow(212, 270, 124, 7, 3)
  local ant = antlerMask(240, 66, 26, 18)
  rimOf(union(pL, pR, lintel, ant), L.timber)
  snowBlocks(pL, 78, 6, 7, 36) snowBlocks(pR, 78, 6, 7, 37)
  union(pL, pR):each(function(x, y) if (x == 220 or x == 221 or x == 270 or x == 271) and y > 79 then px(x, y, (x % 2 == 0) and S.shade or S.deep) end end)
  part(lintel, L.timber)
  F.logs(lintel, L.timber, 70, 4)
  F.logEnd(205, 74, 4) F.logEnd(275, 74, 4)
  paintBone(ant, 38)
  ant:each(function(x, y) if not ant:has(x, y - 1) and hash(x, y, 39) < .5 then px(x, y, S.hi) end end)
  -- a small skull plate and a woven band where the antlers bind to the lintel
  fill(rect(236, 64, 244, 69), L.board.base) hline(236, 244, 64, L.board.hi) px(238, 66, L.timber.edge) px(242, 66, L.timber.edge)
  hline(236, 244, 69, L.board.shade)
  band(208, 272, 79)
  F.snowCap(lintel, 2, 40, { cx = 236, lip = true })
  F.snowCap(union(pL, pR), 3, 41, { cx = 240 })
  F.icicles(222, 258, 83, 5, 42, .4)
  -- lantern hanging from the lintel, red blaze on the right pillar, snow drifted at the feet
  vline(240, 83, 85, L.timber.edge)
  lantern(240, 86)
  local mk = rect(262, 100, 267, 106) rimOf(mk, L.awnA) part(mk, L.awnA)
  F.drift(214, 126, 9, 4, 43) F.drift(266, 126, 9, 3, 44)
  F.willow(206, 128, 4, 5, 45)
end
trail()

---------------------------------------------------------------- back left: a lavvu tent and a falu-red sod-roofed cottage (plane 1)
F.depth(1)
F.tree(86, 126, 42, 2)
F.tree(10, 128, 36, 1)
do
  -- the lavvu: hide cover on a cone of poles, poles crossing above the smoke hole, a door flap, snow banked round
  local cone = poly{ { 16, 134 }, { 29, 94 }, { 35, 94 }, { 48, 134 } }
  local pl = line({ { 26, 94 }, { 22, 84 } }):add(line({ { 30, 94 }, { 29, 82 } })):add(line({ { 34, 94 }, { 37, 83 } })):add(line({ { 38, 94 }, { 42, 86 } }))
  shadow(18, 48, 134, 6, 3)
  rimOf(union(cone, pl), L.timber)
  fill(pl, L.timber.base)
  pl:each(function(x, y) if y < 88 then px(x, y, L.timber.hi) end end)
  part(cone, hide)
  cone:each(function(x, y)
    local u = (x - 32) / math.max(1, (y - 94) * .4 + 3)
    if u < -.45 then px(x, y, hide.hi) elseif u > .4 then px(x, y, hide.shade) end
    if (y - 94) % 9 == 0 then px(x, y, hide.deep) end -- hide seams
    if hash(x // 3, y // 4, 46) < .07 then px(x, y, hide.base) end
  end)
  -- smoke-darkened crown, door flap with warm light, a woven band, snow banked at the foot
  hline(29, 35, 95, L.timber.deep) hline(28, 36, 96, hide.deep)
  local fl = poly{ { 28, 134 }, { 32, 116 }, { 36, 134 } }
  fill(fl, L.timber.edge) fill(poly{ { 30, 134 }, { 32, 122 }, { 34, 134 } }, L.glow.shade) px(32, 124, L.glow.base) px(32, 126, L.glow.hi)
  line({ { 32, 116 }, { 38, 128 } }):each(function(x, y) px(x, y, hide.deep) end)
  for x = 20, 44 do local y = 124 if cone:has(x, y) then px(x, y, L.awnA.base) px(x, y + 1, wool.base) if x % 3 == 0 then px(x, y, L.gold.base) end end end
  F.snowCap(cone:copy():clip(rect(0, 0, 479, 104)), 1, 47)
  for x = 15, 49 do local hh = 1 + floor(hash(x // 3, 2, 48) * 3) for k = 0, hh do px(x, 134 - k, k == hh and S.hi or (x < 32 and S.base or S.shade)) end end
  F.smoke(30, 78, 6, .5, 2)
  -- falu-red cottage with white trim under a snowy sod roof
  local top2, cx2, wall2 = F.building{ x0 = 52, x1 = 75, yb = 134, wh = 40, rh = 26, wall = L.wall2, chimney = true, noFrame = true, snow = 4 }
  F.planks(wall2, L.wall2, 4, true, 36)
  part(union(rect(52, top2, 53, 134), rect(74, top2, 75, 134)), L.plaster, { nopop = true, noshade = true })
  window(57, 100, 63, 106, L.plaster) window(57, 116, 62, 122, L.plaster)
  door(66, 116, 72, 133, wool)
  hline(65, 73, 115, S.hi)
  local pile = poly{ { 46, 134 }, { 48, 126 }, { 51, 126 }, { 51, 134 } } -- firewood stacked by the wall
  for y = 127, 133, 2 do for x = 47, 50, 2 do px(x, y, L.board.base) px(x + 1, y, L.timber.deep) end end
  hline(47, 51, 126, S.hi)
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
  shadow(290, 338, 136, 8, 4)
  rimOf(union(roof, posts, board, bar), T)
  poles(posts)
  part(board, L.timber, { band = 2 })
  F.planks(board, L.timber, 6, true, 61)
  hline(287, 339, 65, T.deep) hline(287, 339, 114, T.deep) vline(287, 65, 114, T.deep) vline(339, 65, 114, T.deep)
  part(bar, T, { nopop = true }) hline(286, 340, 120, S.hi)
  part(roof, L.roof2, { sep = true }) courses(roof, 46, 3, 5, L.roof2)
  F.snowCap(roof, 4, 62, { cx = 312, lip = true })
  F.icicles(283, 343, 64, 4, 63, .5)
  -- a carved raven on the peak
  F.sprite({ "...kk...", "..kKKk..", ".kKKKKb.", "kKKKKk..", "kKKKKk..", ".kKKk...", "..oo...." }, 309, 37,
    { k = "#3a3646", K = "#56526a", b = L.gold.shade, o = T.deep })
  px(312, 39, "#d6d2e0")
  local notes = { { 291, 69, 302, 82, L.awnB }, { 306, 70, 320, 80, L.plaster }, { 324, 68, 335, 84, L.awnB },
                  { 292, 87, 305, 100, L.accent }, { 309, 85, 321, 104, L.board }, { 325, 89, 335, 99, cloudb },
                  { 296, 103, 306, 111, L.awnA }, { 323, 102, 334, 111, L.plaster } }
  for _, n in ipairs(notes) do
    local m = rect(n[1], n[2], n[3], n[4])
    part(m, n[5], { nopop = true })
    c:edgeIn(m, n[5].deep)
    for y = n[2] + 3, n[4] - 2, 3 do hline(n[1] + 2, n[3] - 2 - (y % 4), y, n[5].shade) end
    px((n[1] + n[3]) // 2, n[2] + 1, L.awnA.base)
  end
  -- a sled-race poster (a reindeer and a flag), a map scrap with a route, a pinned feather, rime on the board
  line({ { 311, 90 }, { 316, 96 }, { 312, 100 } }):each(function(x, y) px(x, y, L.awnA.base) end)
  F.sprite({ "d..d.", ".dd..", "dddd.", "d..d." }, 296, 90, { d = L.deer.shade }, { rim = false })
  vline(302, 89, 95, T.deep) fill(rect(303, 89, 304, 90), L.awnA.base)
  line({ { 327, 104 }, { 331, 109 } }):each(function(x, y) px(x, y, L.fur.shade) end)
  board:each(function(x, y) if (y == 66 or x == 288 or x == 338) and hash(x, y, 64) < .5 then px(x, y, S.base) end end)
  -- lantern on the right post, a paste bucket with ice, a young gnome reading
  hline(337, 340, 70, T.deep) vline(340, 70, 72, T.deep)
  lantern(340, 73)
  local b = poly{ { 300, 128 }, { 308, 128 }, { 307, 135 }, { 301, 135 } } rimOf(b, L.timber) part(b, copper, { nopop = true })
  hline(301, 307, 128, L.ice.hi)
  vline(305, 122, 128, T.hi)
  F.gnome(320, 140, { small = true, hat = L.lav, coat = L.awnA, arm = "up" })
end
notice()

---------------------------------------------------------------- back right: the rest lodge (plane 2)
local function lodge()
  local top, cx, wall, roofM = F.building{ x0 = 360, x1 = 456, yb = 136, wh = 46, rh = 26, wall = L.timber, chimney = true, noFrame = true, snow = 4, icicles = 5 }
  F.planks(wall, L.timber, 4, false, 63)
  part(union(rect(360, top, 362, 136), rect(454, top, 456, 136)), L.plaster, { nopop = true, noshade = true })
  F.smoke(447, 61, 5, .5, 2)
  -- slate porch roof under snow, on driftwood poles
  local porch = poly{ { 356, 105 }, { 460, 105 }, { 463, 111 }, { 353, 111 } }
  rimOf(porch, L.roof2) part(porch, L.roof2, { sep = true }) courses(porch, 105, 3, 4, L.roof2)
  F.snowCap(porch, 2, 64, { cx = 400, lip = true })
  F.icicles(354, 462, 112, 4, 65, .45)
  local pp = rect(361, 113, 362, 135):add(rect(454, 113, 455, 135))
  poles(pp)
  window(366, 95, 378, 101, L.plaster) window(438, 95, 450, 101, L.plaster)
  window(370, 116, 380, 121, L.plaster) window(436, 116, 446, 121, L.plaster)
  door(400, 113, 416, 135, wool)
  -- antlers over the door, a painted sun sign
  local an = antlerMask(408, 89, 11, 8)
  rimOf(an, L.timber) paintBone(an, 66)
  local sign = rect(398, 90, 418, 96) rimOf(sign, L.timber) part(sign, L.board)
  F.sprite({ ".g.g.", "ggggg", ".gog.", "ggggg", ".g.g." }, 405, 91, { g = L.gold.base, o = L.awnA.base }, { rim = false })
  hline(398, 418, 90, S.hi)
  lantern(421, 114)
  -- bench under a reindeer hide and a striped blanket
  local bench = rect(364, 128, 396, 130):add(rect(365, 131, 367, 135)):add(rect(393, 131, 395, 135)):add(rect(364, 123, 366, 128))
  local pelt = poly{ { 368, 124 }, { 380, 123 }, { 381, 133 }, { 377, 134 }, { 372, 132 }, { 368, 134 } }
  local blank = rect(382, 125, 393, 133)
  shadow(366, 396, 135, 4, 2)
  rimOf(union(bench, pelt, blank), L.timber)
  part(bench, L.timber, { nopop = true })
  part(pelt, L.deer) pelt:each(function(x, y) if hash(x, y, 67) < .2 then px(x, y, L.fur.base) elseif hash(x, y, 68) < .15 then px(x, y, L.deer.deep) end end)
  blank:each(function(x, y) local k = (y - 125) % 4 px(x, y, k == 0 and L.awnA.base or (k == 1 and L.gold.base or (k == 2 and wool.base or wool.shade))) end)
  for y = 134, 135 do for x = 383, 393, 2 do px(x, y, L.awnA.shade) end end
  -- tea table + a steaming copper kettle + cups
  local tbl = rect(424, 127, 444, 129):add(rect(426, 130, 427, 135)):add(rect(441, 130, 442, 135))
  local pot = poly{ { 429, 120 }, { 438, 120 }, { 440, 126 }, { 427, 126 } }
  local lid = rect(432, 118, 435, 119)
  rimOf(union(tbl, pot, lid), L.timber)
  part(tbl, L.timber, { nopop = true }) part(pot, copper) part(lid, copper, { nopop = true })
  line({ { 440, 122 }, { 443, 119 } }):each(function(x, y) px(x, y, copper.deep) end)
  line({ { 429, 118 }, { 433, 115 }, { 437, 118 } }):each(function(x, y) px(x, y, L.iron.deep) end)
  hline(429, 438, 123, copper.hi)
  fill(rect(441, 125, 443, 126), L.plaster.hi) fill(rect(424, 125, 425, 126), wool.base)
  F.steam(444, 116, 4, .4, 69)
  -- crowberry window boxes under the top windows, snow on them
  for _, x in ipairs({ 365, 437 }) do
    hline(x, x + 14, 104, L.timber.base)
    for i = 0, 14, 2 do px(x + i, 103, (i % 4 == 0) and crowb.base or L.foliage.base) px(x + i + 1, 102, i % 6 == 0 and S.hi or L.foliage.hi) end
  end
  -- snow banked against the lodge foot
  for x = 357, 459 do if x < 398 or x > 418 then local hh = floor(hash(x // 4, 3, 70) * 3) for k = 0, hh do px(x, 136 - k, k == hh and S.hi or S.base) end end end
end
lodge()

---------------------------------------------------------------- road side: seal mailbox, signpost (plane 2)
local function sealBox()
  local post = rect(208, 136, 209, 146)
  local body = poly{ { 198, 136 }, { 200, 130 }, { 206, 126 }, { 214, 125 }, { 219, 127 }, { 221, 131 }, { 220, 136 } }
  local head = c:ellipse(201, 128, 4, 4)
  local tail = poly{ { 219, 133 }, { 224, 130 }, { 224, 136 } }
  rimOf(union(post, body, head, tail), L.timber)
  part(post, L.timber, { nopop = true })
  local seal = F.rp("#cfd0dc #a6a8bc #82849c #5e6078 #3c3e54")
  part(union(body, tail), seal) part(head, seal, { nopop = true })
  body:each(function(x, y) if hash(x // 2, y // 2, 71) < .14 then px(x, y, seal.shade) end end) -- ringed spots
  px(199, 127, L.timber.edge) px(202, 127, L.timber.edge) px(198, 129, L.timber.deep) hline(199, 202, 130, seal.deep)
  px(199, 126, seal.hi) px(196, 129, seal.shade) px(197, 130, seal.shade)
  hline(208, 216, 129, L.timber.edge) hline(209, 215, 130, seal.deep) -- mail slot
  fill(rect(222, 124, 224, 127), L.awnA.base) vline(221, 124, 130, L.timber.deep)
  F.snowCap(body, 2, 72, { cx = 208 })
end
sealBox()
local function signpost()
  local post = rect(442, 152, 445, 176)
  local b1 = poly{ { 430, 155 }, { 434, 151 }, { 454, 151 }, { 458, 155 }, { 454, 159 }, { 434, 159 } }
  local b2 = poly{ { 432, 165 }, { 436, 162 }, { 452, 162 }, { 456, 165 }, { 452, 168 }, { 436, 168 } }
  rimOf(union(post, b1, b2), L.timber)
  poles(post)
  part(b1, L.wall2) part(b2, L.board)
  hline(436, 452, 155, L.wall2.hi) hline(438, 450, 165, L.board.deep)
  hline(434, 454, 151, S.hi) hline(436, 452, 162, S.base)
  F.icicles(434, 454, 160, 3, 73, .4)
end
signpost()

F.depth(3)
-- stacked goods on the left verge: crates of carved toys and stockfish, a barrel, sacks, a parked kicksled
F.shadow(198, 222, 180, 6, 3)
F.crate(198, 180, 12, 9, dfish)
F.crate(211, 180, 11, 9, L.apple)
F.crate(203, 170, 12, 8, cloudb)
hline(203, 215, 161, S.hi)
F.sack(222, 182, SACK, 4)
F.snowCap(F.sack(222, 182, SACK, 4), 2, 74)
F.shadow(200, 214, 204, 5, 2)
F.barrel(206, 204, L.timber, 11)
for k = 0, 3 do px(202 + k * 2, 193, dfish.hi) px(203 + k * 2, 193, dfish.shade) end
F.sack(216, 206, L.leaf, 4)
-- right verge by the notice board: driftwood bundles for sale, a reindeer-hide stack
F.shadow(258, 280, 146, 5, 2)
for k = 0, 2 do F.logEnd(262 + k * 7, 142, 3) end
for k = 0, 1 do F.logEnd(265 + k * 7, 136, 3) end
hline(260, 280, 139, L.awnA.base)
hline(263, 278, 132, S.hi)
local hides = poly{ { 276, 150 }, { 278, 143 }, { 290, 143 }, { 292, 150 } }
rimOf(hides, L.timber) part(hides, L.deer)
for y = 145, 149, 2 do hline(278, 290, y, L.deer.deep) end
hline(279, 289, 143, S.hi)

---------------------------------------------------------------- the igloo (plane 3, replaces the haystack house) + fox in a gnome hat
local function igloo()
  local dome = c:ellipse(446, 224, 22, 22):clip(rect(400, 180, 479, 224))
  local tunnel = c:rrect(424, 208, 440, 228, 5):clip(rect(400, 200, 479, 224))
  local pipe = rect(455, 196, 457, 203)
  shadow(426, 466, 224, 6, 2)
  rimOf(union(dome, tunnel, pipe), L.timber)
  -- curved block courses: rows follow the dome, joints offset
  dome:each(function(x, y)
    local dy = 224 - y
    local row = dy // 5
    local ry = dy % 5
    local half = math.sqrt(math.max(1, 22 * 22 - dy * dy))
    local bw = math.max(4, floor(half / 3))
    local off = (row % 2) * (bw // 2)
    local rx = (x - 446 + floor(half) + off) % bw
    local lit = (x - 446) / 22 * .8 + (y - 214) / 22 * .6
    local h = lit < -.35 and S.hi or (lit < -.05 and S.base or (lit < .45 and S.shade or S.deep))
    if ry == 0 or rx == 0 then h = lit < -.3 and S.shade or (lit < .4 and S.deep or S.edge)
    elseif ry == 4 and lit < -.35 then h = "#fafaf6" end
    if hash(x // 3, row, 75) < .08 and ry > 0 and rx > 0 then h = L.ice.base end
    px(x, y, h)
  end)
  snowBlocks(tunnel, 208, 5, 5, 76)
  tunnel:each(function(x, y) if x > 436 then px(x, y, S.shade) end end)
  local dm = c:rrect(428, 213, 436, 228, 3):clip(rect(400, 200, 479, 224))
  fill(dm, L.glow.shade) fill(rect(430, 216, 432, 224), L.glow.base) px(430, 216, L.glow.hi)
  c:rim(dm, L.timber.edge, tunnel)
  -- an ice window glowing, a pipe with steam
  local w = c:ellipse(454, 212, 3, 2) rimOf(w, L.ice) fill(w, L.glow.hi) px(453, 211, "#fff6dc") px(456, 213, L.glow.base)
  part(pipe, L.iron, { nopop = true }) hline(454, 458, 196, L.iron.deep)
  F.steam(457, 192, 4, .5, 77)
  F.drift(470, 226, 8, 3, 78)
  -- the arctic fox, curled on the dome in a red gnome hat, tail brush over its nose
  F.sprite({
    "......R.......",
    ".....RRr......",
    "....RRRr......",
    "...RRRRRr.....",
    "...hhhhhh.....",
    "..kFFFFFFk....",
    "..FeFFeFFFFF..",
    ".nFFFFFFFFFFF.",
    "..FFFFFFFFFFFf",
    "fFFFFFFFFFFFf.",
    "FFTTFFFFFFFf..",
    ".fTTTff.......",
  }, 437, 193, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, F = L.fur.hi, f = L.fur.shade, k = L.fur.deep,
    e = L.timber.edge, n = L.timber.edge, T = L.fur.base })
  px(442, 193, L.awnA.hi)
end
igloo()

---------------------------------------------------------------- left: the wishing well over a warm spring (plane 3)
local function well()
  local St, T, RR = L.stone, L.timber, L.roof2
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
  shadow(100, 192, 208, 9, 5)
  rimOf(union(roofOuter, postL, postR, lipTop, lipFront, drum, crank, axle, bucket), L.timber)
  part(drum, St) F.rubble(drum, St, 165, 7, 71)
  -- frost: lilac on the right face, rime climbing from the ground
  drum:each(function(x, y) if x > 182 and hash(x, y, 79) < .35 then px(x, y, St.shade) end if y > 198 and hash(x // 2, y, 80) < .25 then px(x, y, S.base) end end)
  part(lipFront, St, { sep = true }) courses(lipFront, 156, 10, 17, St, 5)
  part(lipTop, S, { sep = true })
  lipTop:each(function(x, y) if hash(x // 2, y, 73) < .2 then px(x, y, S.hi) elseif x > 180 then px(x, y, S.shade) end end)
  -- the warm spring inside: teal water glowing, steam rising
  local opening = poly{ { 106, 149 }, { 180, 149 }, { 184, 154 }, { 102, 154 } }
  fill(opening, L.water.shade) hline(110, 178, 149, St.edge) hline(118, 128, 152, L.water.base) hline(156, 170, 151, L.water.base)
  hline(140, 148, 153, L.water.hi)
  px(165, 152, L.glow.hi) px(166, 152, L.glow.base) px(122, 151, L.glow.hi)
  poles(union(postL, postR))
  part(axle, T, { nopop = true }) hline(110, 176, 130, S.hi)
  for x = 136, 150, 3 do vline(x, 131, 133, L.board.base) end
  fill(rope, L.board.base) part(crank, T, { nopop = true }) fill(rect(188, 140, 191, 143), wool.base)
  part(bucket, copper) hline(135, 151, 144, L.iron.shade) hline(136, 150, 150, L.iron.shade)
  line({ { 135, 141 }, { 143, 137 }, { 151, 141 } }):each(function(x, y) px(x, y, L.iron.deep) end)
  hline(137, 149, 142, L.water.hi)
  part(roofM, RR, { sep = true }) courses(roofM, 92, 4, 6, RR)
  hline(90, 196, 126, RR.edge) hline(91, 195, 125, RR.deep)
  F.snowCap(roofM, 5, 74, { cx = 140, lip = true })
  F.icicles(90, 196, 127, 6, 75, .5)
  part(gable, L.board, { nopop = true })
  F.planks(gable, L.board, 4, true, 75)
  vline(143, 106, 121, T.base)
  line({ { 143, 112 }, { 130, 120 } }):each(function(x, y) px(x, y, T.base) end)
  line({ { 143, 112 }, { 156, 120 } }):each(function(x, y) px(x, y, T.base) end)
  band(110, 176, 121)
  -- a carved raven-head finial on the ridge
  F.sprite({ "..kk.", ".kKKb", "kKKk.", ".kK..", ".kK.." }, 140, 85, { k = T.edge, K = T.base, b = L.gold.shade })
  -- the steam of the warm spring curling out under the roof
  F.steam(122, 146, 5, .7, 81) F.steam(158, 146, 6, .5, 82)
  -- snow drifted at the drum foot, sedge poking through, coins glinting
  F.drift(104, 210, 12, 4, 83) F.drift(186, 210, 10, 3, 84)
  for _, f in ipairs({ { 98, 210, 6 }, { 191, 208, 5 } }) do F.fern(f[1], f[2], f[3]) end
  for i = 0, 10 do local x, y = 97 + floor(hash(i, 1, 41) * 22), 170 + floor(hash(i, 2, 41) * 30) px(x, y, L.lichen.base) px(x + 1, y, L.lichen.hi) px(x, y + 1, L.lichen.deep) end
  c:sparkle(176, 160)
end
well()

---------------------------------------------------------------- left: the Seed Swap covered sled booth (plane 3)
local function seedSled()
  local T = L.timber
  local cover = poly{ { 20, 196 }, { 20, 162 }, { 24, 152 }, { 32, 147 }, { 62, 147 }, { 70, 152 }, { 74, 162 }, { 74, 196 } }
  local bed = rect(18, 196, 76, 205)
  local runner = line({ { 20, 210 }, { 76, 210 } }):add(line({ { 20, 210 }, { 16, 207 }, { 15, 203 }, { 17, 201 } }))
  local stan = rect(26, 206, 27, 209):add(rect(46, 206, 47, 209)):add(rect(66, 206, 67, 209))
  shadow(20, 76, 210, 6, 3)
  rimOf(union(cover, bed, runner, stan), T)
  -- felt cover on hoops: hoop ribs, sun-lit left, lilac right, snow on the crown
  part(cover, L.lichen)
  cover:each(function(x, y)
    if (x - 20) % 13 == 0 then px(x, y, L.lichen.deep) elseif (x - 20) % 13 == 1 then px(x, y, L.lichen.hi) end
    if x > 66 then px(x, y, L.lichen.shade) end
  end)
  F.snowCap(cover, 3, 85, { cx = 44, lip = true })
  -- the side flap rolled up: a window into the booth, shelves of seed jars and packets lit by a lamp
  fill(rect(25, 165, 69, 192), T.edge)
  fill(rect(26, 166, 68, 191), L.glow.deep)
  fill(rect(26, 166, 68, 170), L.glow.shade)
  local roll = rect(23, 160, 71, 164)
  rimOf(roll, T) part(roll, L.lichen, { nopop = true }) hline(23, 71, 160, L.lichen.hi) hline(23, 71, 164, L.lichen.deep)
  for x = 26, 68, 7 do vline(x, 160, 164, L.awnA.base) end
  hline(26, 68, 177, T.base) hline(26, 68, 178, T.deep)
  for i = 0, 7 do
    local x = 27 + i * 5
    local rr = ({ L.awnA, cloudb, L.accent, L.produce, L.leaf, crowb, L.gold, L.wall2 })[i + 1]
    local pk = rect(x, 170 + (i % 2), x + 3, 176) part(pk, rr, { nopop = true }) px(x + 1, 171 + (i % 2), rr.hi)
    hline(x, x + 3, 173 + (i % 2), rr.deep)
  end
  for i = 0, 6 do hjar(27 + i * 6, 190, ({ cloudb, L.apple, crowb, L.gold, L.leaf, L.lav, cloudb })[i + 1], ({ L.awnA, wool })[i % 2 + 1]) end
  lantern(64, 166, 0)
  -- the painted bed: red, a woven band, runners
  part(bed, L.wall2) F.planks(bed, L.wall2, 6, true, 86)
  band(19, 75, 199)
  part(runner, L.iron, { nopop = true, noshade = true }) hline(20, 76, 210, L.iron.hi)
  part(stan, T, { nopop = true, noshade = true })
  -- hanging sign: a sprouting seed
  vline(30, 145, 147, T.edge) vline(40, 145, 147, T.edge)
  local sg = rect(28, 137, 42, 144) rimOf(sg, T) part(sg, L.board) hline(28, 42, 137, S.hi)
  F.sprite({ ".g.g.", "..g..", ".bbb.", "bbbbb", ".bbb." }, 33, 139, { g = L.foliage.base, b = L.soil.base }, { rim = false })
  -- crate of potted spruce seedlings on the snow, a watering can of meltwater
  local crate = rect(52, 200, 76, 208) rimOf(crate, T) part(crate, L.board) hline(52, 76, 204, L.board.deep)
  for i = 0, 3 do F.conifer(55 + i * 6, 200, 8 + (i % 2) * 2, i % 2 == 0 and L.foliage or L.foliage2, 80 + i) end
end
seedSled()
F.willow(10 + 6, 216, 5, 6, 87) F.willow(84, 212, 5, 6, 88)

---------------------------------------------------------------- right hero: the trader sled-stall (plane 3)
local function stall()
  local T = L.timber
  local roof = poly{ { 288, 168 }, { 300, 151 }, { 400, 151 }, { 412, 168 } }
  local val = rect(289, 167, 411, 172)
  for x = 289, 405, 8 do val:add(poly{ { x, 172 }, { x + 8, 172 }, { x + 4, 177 } }) end
  val:clip(rect(289, 166, 411, 177))
  local posts = rect(296, 177, 299, 200):add(rect(401, 177, 404, 200))
  local back = rect(300, 177, 400, 195)
  local ctop = poly{ { 299, 194 }, { 401, 194 }, { 404, 199 }, { 296, 199 } }
  local bed = rect(296, 199, 404, 215)
  local stan = rect(304, 216, 306, 220):add(rect(350, 216, 352, 220)):add(rect(394, 216, 396, 220))
  local runner = line({ { 296, 221 }, { 406, 221 } }, 2):add(line({ { 296, 221 }, { 289, 217 }, { 287, 211 }, { 290, 207 } }, 2))
  shadow(292, 408, 223, 9, 4)
  rimOf(union(roof, val, posts, back, ctop, bed, stan, runner), T)
  poles(posts)
  -- backdrop: a hanging blue wool blanket with a woven band, a rack of dried fish across it
  part(back, wool, { nopop = true })
  back:each(function(x, y) if (x + y) % 6 == 0 and y > 182 then px(x, y, wool.shade) end end)
  band(300, 400, 190)
  hline(301, 399, 179, T.base) hline(301, 399, 180, T.deep)
  for k = 0, 13 do
    local x = 303 + k * 7
    if x < 341 or x > 361 then fish(x, 181, (k % 3 == 1) and copper or dfish) end
  end
  -- the stallkeeper, behind the counter, in a blue kolt with a red hat
  F.gnome(352, 202, { hat = L.awnA, coat = wool, arm = "up", noShadow = true, hatBand = L.gold.base })
  -- striped wool canopy under snow, red valance with a gold zigzag
  part(roof, L.awnA, { sep = true })
  roof:each(function(x, y)
    local k = (x - 300 + floor((y - 151) * .7)) // 8
    if k % 2 == 0 then px(x, y, (y - 151) < 4 and wool.hi or wool.base) end
    if (x - 300 + floor((y - 151) * .7)) % 8 == 0 then px(x, y, wool.deep) end
  end)
  F.snowCap(roof, 4, 87, { cx = 330, lip = true })
  stripes(val, 289, 8, L.awnA, L.awnA)
  for x = 289, 411 do local k = (x - 289) % 6 px(x, 169 + (k < 3 and k or 6 - k) // 1 - 1, L.gold.base) end
  hline(289, 411, 167, L.awnA.deep)
  for x = 293, 409, 8 do px(x, 177, L.gold.hi) px(x, 178, L.gold.shade) end -- tassels
  -- sign board on the ridge with the wares painted on: fish, berry, toy horse, lantern
  local sign = rect(330, 140, 370, 148)
  rimOf(sign, T) part(sign, L.board) hline(331, 369, 148, L.board.deep) hline(330, 370, 140, S.hi)
  F.sprite({ "s.ss", "ssss", "s.ss" }, 334, 143, { s = dfish.shade }, { rim = false })
  F.sprite({ ".b.", "bbb", ".b." }, 341, 143, { b = cloudb.base }, { rim = false })
  F.sprite({ "..rr", "rrrr", "r..r" }, 347, 143, { r = L.awnA.base }, { rim = false })
  F.sprite({ "ggg", "ggg", ".g." }, 355, 143, { g = L.glow.base }, { rim = false })
  F.sprite({ ".b.", "bbb", ".b." }, 361, 143, { b = L.apple.base }, { rim = false })
  vline(336, 149, 150, T.deep) vline(364, 149, 150, T.deep)
  -- lanterns hanging under the valance
  lantern(304, 179, 1) lantern(396, 179, 1)
  lantern(330, 173, 0) lantern(372, 173, 0)
  -- counter planks
  part(ctop, L.board) hline(299, 401, 194, L.board.hi)
  -- the sled bed: falu-red boards, painted with a band and little white reindeer, iron runners with curled nose
  part(bed, L.wall2) F.planks(bed, L.wall2, 6, true, 89)
  band(297, 403, 201)
  for k = 0, 5 do
    local x = 304 + k * 17
    F.sprite({ "w...w.", ".w.w..", "wwww..", "wwwwww", ".wwwww", ".w..w." }, x, 207, { w = L.plaster.hi }, { rim = false })
    px(x + 5, 209, L.timber.edge)
  end
  part(stan, T, { nopop = true, noshade = true })
  part(runner, L.iron, { nopop = true, noshade = true })
  hline(296, 406, 221, L.iron.hi)
  -- goods on the counter: birch-bark baskets of berries, carved toys, a stack of bowls
  basket(300, 318, 198, 5, cloudb, 82, true)
  basket(320, 336, 198, 5, L.apple, 83)
  basket(366, 382, 198, 5, crowb, 84)
  -- carved and painted wooden toys: horse, reindeer, top, little boat, a toy sled
  F.sprite({ "...rr", "..rRr", "rrrrr", "rRrrr", "r..r." }, 384, 189, { r = L.awnA.base, R = L.gold.base })
  F.sprite({ "d.d...", ".dd...", "dddd..", "ddddd.", "d..d.." }, 392, 189, { d = L.board.shade })
  F.sprite({ "bbbb", ".bb.", "..b." }, 339, 190, { b = wool.base })
  px(340, 190, L.gold.hi)
  F.sprite({ ".y..", "yyyy", ".gg." }, 344, 190, { y = L.gold.base, g = L.leaf.base })
  -- hanging toy birds on a string between the lanterns
  hline(380, 392, 176, T.deep)
  for k = 0, 2 do px(382 + k * 4, 177, L.gold.base) px(383 + k * 4, 177, L.gold.base) px(382 + k * 4, 178, L.awnA.base) end
  -- berry baskets set out on the snow beside the sled
  basket(408, 424, 222, 5, L.apple, 90, true)
  basket(410, 426, 212, 5, cloudb, 91)
  for x = 296, 406 do if hash(x // 3, 1, 91) < .6 then px(x, 222, S.hi) px(x, 223, S.base) end end
end
stall()
-- the reindeer harnessed to the sled-stall, standing on the road facing left, traces to the curled nose
local _, rcx, rcy = reindeer(266, 228, -1, 92)
line({ { rcx, rcy }, { 289, 212 } }):each(function(x, y) px(x, y, L.soil.shade) end)
line({ { rcx, rcy + 3 }, { 290, 216 } }):each(function(x, y) px(x, y, L.soil.deep) end)
-- a shopper with a birch-bark basket of berries, on the road
local _, shx, shy = F.gnome(222, 238, { hat = L.roof2, coat = L.wall2, arm = "out" })
local bk = poly{ { shx - 3, shy }, { shx + 3, shy }, { shx + 2, shy + 5 }, { shx - 2, shy + 5 } }
rimOf(bk, L.timber) part(bk, L.birch, { nopop = true })
px(shx - 1, shy - 1, cloudb.base) px(shx, shy - 1, cloudb.hi) px(shx + 1, shy - 1, L.apple.base)
line({ { shx - 3, shy }, { shx, shy - 3 }, { shx + 3, shy } }):each(function(x, y) if y < shy then px(x, y, L.timber.deep) end end)
F.tracks({ { 226, 252 }, { 232, 266 } }, "boot", 5)
F.tracks({ { 250, 232 }, { 236, 226 }, { 230, 214 } }, "deer", 6)

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
  shadow(124, 186, 262, 6, 2)
  rimOf(union(can, posts, top, cloth, legs, bench), L.timber)
  poles(posts)
  stripes(can, 120, 4, wool, L.awnB)
  F.snowCap(can, 2, 93, { cx = 150 })
  part(legs, L.timber, { nopop = true })
  part(top, L.board) F.planks(top, L.board, 5, true, 86)
  part(cloth, L.awnA, { nopop = true })
  band(127, 181, 250)
  for x = 127, 181, 3 do px(x, 254, L.gold.base) end
  part(bench, L.timber, { nopop = true })
  -- hides on the bench
  for _, hx in ipairs({ 134, 160 }) do local p = rect(hx, 257, hx + 12, 259) fill(p, L.deer.base) hline(hx, hx + 12, 257, L.fur.base) px(hx + 4, 258, L.deer.deep) end
  -- feast: copper kettle steaming, cloudberry pie, bowls of soup steaming, a plate of fish
  local tp = poly{ { 134, 239 }, { 142, 239 }, { 143, 245 }, { 133, 245 } }
  rimOf(tp, L.timber) part(tp, copper) line({ { 143, 241 }, { 146, 238 } }):each(function(x, y) px(x, y, copper.deep) end)
  px(137, 238, copper.deep) px(138, 238, copper.deep)
  F.steam(146, 236, 3, .5, 94)
  local pie = poly{ { 150, 243 }, { 162, 243 }, { 164, 246 }, { 148, 246 } } rimOf(pie, L.board) part(pie, L.board, { nopop = true })
  hline(151, 161, 244, cloudb.base) for x = 151, 161, 3 do px(x, 244, cloudb.hi) end
  for _, bx in ipairs({ 167, 173 }) do
    local bw = rect(bx, 244, bx + 4, 246) rimOf(bw, L.timber) fill(bw, L.board.shade) hline(bx, bx + 4, 244, copper.hi)
  end
  F.steam(170, 241, 3, .3, 95)
  for x = 131, 175, 11 do hline(x, x + 3, 247, L.plaster.hi) px(x + 1, 246, dfish.base) end
  lantern(130, 236, 0)
  lantern(178, 236, 0)
end
longTable()

---------------------------------------------------------------- bottom left: the frozen fishing pond (plane 3)
local function pond()
  local bank = poly{ { 18, 238 }, { 32, 228 }, { 72, 226 }, { 100, 232 }, { 108, 246 }, { 100, 260 }, { 60, 264 }, { 26, 262 }, { 16, 252 } }
  local ice = bank:shrink(3)
  shadow(24, 104, 262, 4, 2)
  rimOf(bank, L.ice)
  bank:each(function(x, y) if not ice:has(x, y) then local v = hash(x, y, 51) px(x, y, v < .3 and L.stone.base or (v < .75 and S.hi or S.shade)) end end)
  -- the ice: pale glaze, snow skiffs blown across, cracks
  ice:each(function(x, y)
    local v = F.vnoise(x / 12, y / 4, 61)
    local h = v < .35 and L.ice.base or (v < .68 and L.ice.hi or S.base)
    if hash(x, y, 62) < .04 then h = L.ice.shade end
    if not ice:has(x, y - 1) or not ice:has(x, y - 2) then h = L.ice.shade end
    px(x, y, h)
  end)
  for _, ck in ipairs({ { { 30, 252 }, { 46, 256 }, { 66, 254 } }, { { 72, 252 }, { 90, 258 } } }) do
    line(ck):each(function(x, y) if ice:has(x, y) then px(x, y, L.ice.deep) if ice:has(x, y + 1) then px(x, y + 1, L.ice.hi) end end end)
  end
  -- spruce reflections faint along the far edge
  for _, rx in ipairs({ 40, 62, 84 }) do for k = 0, 3 do hline(rx - 2 + k // 2, rx + 2 - k // 2, 234 + k * 2, L.ice.shade) end end
  -- two holes: one with the fishing line, one where a ringed seal pops up
  local function hole(x, y, rx)
    local h = c:ellipse(x, y, rx, 2)
    c:rim(h, S.hi)
    fill(h, L.water.deep) hline(x - rx + 1, x + rx - 1, y - 1, L.water.edge) px(x + 1, y, L.water.shade)
    hline(x - rx, x + rx, y + 3, S.shade)
    return h
  end
  hole(46, 246, 5)
  hole(30, 240, 5)
  -- a tip-up: a crossed stick with a red flag sprung up
  vline(58, 236, 242, L.timber.base) hline(55, 61, 242, L.timber.deep)
  fill(rect(59, 236, 62, 238), L.awnA.base) px(59, 236, L.awnA.hi)
  -- jetty under snow
  local jet = poly{ { 70, 240 }, { 104, 240 }, { 106, 250 }, { 72, 250 } }
  local legs = rect(74, 250, 76, 257):add(rect(100, 250, 102, 256)):add(rect(86, 250, 88, 256))
  rimOf(union(jet, legs), L.timber)
  part(legs, L.timber, { nopop = true })
  part(jet, L.timber)
  jet:each(function(x, y) if (x - y // 3) % 5 == 0 then px(x, y, L.timber.deep) end end)
  F.snowCap(jet, 2, 52, { cx = 84 })
  hline(72, 105, 250, L.timber.deep)
  F.icicles(72, 105, 251, 3, 53, .35)
  -- the gnome jigging at the hole on an upturned bucket
  local bu = rect(62, 246, 68, 252) rimOf(bu, L.timber) part(bu, copper, { nopop = true }) hline(62, 68, 248, L.iron.shade)
  local _, ghx, ghy = F.gnome(66, 248, { hat = L.awnA, coat = L.leaf, arm = "out", flip = true, noShadow = true })
  line({ { ghx, ghy }, { 50, 240 } }):each(function(x, y) px(x, y, L.timber.deep) end)
  vline(50, 241, 246, L.awnB.shade)
  -- the catch: a birch-bark basket and a couple of fish on the snow of the jetty
  local fb = poly{ { 88, 234 }, { 96, 234 }, { 95, 239 }, { 89, 239 } } rimOf(fb, L.timber) part(fb, hide, { nopop = true })
  for x = 89, 95, 2 do vline(x, 235, 238, hide.deep) end
  px(90, 233, dfish.base) px(91, 233, dfish.hi) px(93, 233, dfish.base)
  F.sprite({ "ssss.s", "sSSSss", ".sss.s" }, 78, 237, { s = "#8ea6b8", S = "#b6cad6" })
  -- dry sedge and cotton grass along the bank
  for i = 0, 6 do
    local x = 20 + i * 4 local h = 6 + floor(hash(i, 9, 52) * 8)
    vline(x, 252 - h, 252, i % 2 == 0 and L.fern.shade or L.fern.base)
    if i % 2 == 0 then px(x, 252 - h - 1, L.awnB.hi) px(x + 1, 252 - h - 1, L.awnB.base) px(x, 252 - h - 2, L.awnB.hi) end
  end
  -- the ringed seal popping up from the second hole (drawn over the sedge so it reads)
  F.sprite({ "....kkkkkkk....", "...kHHHHSSSk...", "..kHHSSSSSSsk..", "..kHSeSSSSeSsk.", ".wkSSSSnnnSSskw", "kSSsSSSrSSSsSSk", "kssSSrSSSSrSssk", ".kksSSSSrSSssk.", "...kkkkkkkkk..." },
    23, 232, { k = "#3c3e54", s = "#82849c", S = "#a6a8bc", H = "#e2e4ee", e = L.timber.edge, n = "#2a2a3a", w = "#e2e4ee", r = "#5e6078" })
  F.snowCap(F.rock(16, 238, 6, 5), 2, 54)
end
pond()

---------------------------------------------------------------- bottom right: the forage bed (plane 3)
local function forage()
  local T = L.timber
  local soil = poly{ { 304, 247 }, { 368, 247 }, { 374, 254 }, { 298, 254 } }
  local front = rect(298, 254, 374, 262)
  local back = rect(304, 245, 368, 247)
  shadow(300, 374, 262, 5, 2)
  rimOf(union(soil, front, back), T)
  part(back, T, { nopop = true }) hline(304, 368, 245, S.hi)
  soil:each(function(x, y)
    local v = hash(x, y, 71)
    px(x, y, v < .35 and L.greyMoss.base or (v < .6 and L.greyMoss.shade or (v < .8 and S.base or L.mossGround.shade)))
  end)
  part(front, T) F.logs(front, T, 254, 4)
  F.logEnd(298, 258, 4) F.logEnd(374, 258, 4)
  F.snowCap(front, 2, 72, { cx = 330 })
  -- reindeer lichen cushions: pale branched clumps
  for _, x in ipairs({ 308, 330, 352 }) do
    local m = c:ellipse(x, 249, 5, 3)
    rimOf(m, L.lichen)
    m:each(function(xx, yy) local v = hash(xx, yy, 73) px(xx, yy, v < .35 and "#ece6cc" or (v < .7 and "#d6cfb2" or "#b8b094")) end)
    px(x - 2, 247, "#f2eedc")
  end
  -- cloudberry plants: crinkled rust-red autumn leaves, amber berries on short stems
  for i, x in ipairs({ 319, 341, 363 }) do
    for k = -1, 1 do vline(x + k * 3, 239 + abs(k), 246, L.greyMoss.deep) end
    for j, lf in ipairs({ { x - 4, 248, L.leaf }, { x + 4, 248, L.greyMoss }, { x, 245, L.leaf } }) do
      local m = c:ellipse(lf[1], lf[2], 3, 2)
      rimOf(m, lf[3]) fill(m, lf[3].base)
      m:each(function(xx, y) if xx < lf[1] and y < lf[2] then px(xx, y, lf[3].hi) elseif xx > lf[1] then px(xx, y, lf[3].shade) end end)
      px(lf[1], lf[2], lf[3].deep) px(lf[1], lf[2] - 1, lf[3].deep)
    end
    for k = -1, 1 do fill(rect(x + k * 3, 237 + abs(k), x + k * 3 + 1, 238 + abs(k)), cloudb.base) px(x + k * 3, 237 + abs(k), cloudb.hi) end
    hline(x - 3, x + 1, 240, S.hi)
  end
  -- a birch-bark picking basket and a berry rake
  local bb = poly{ { 368, 240 }, { 376, 240 }, { 375, 246 }, { 369, 246 } } rimOf(bb, L.timber) part(bb, L.birch, { nopop = true })
  hline(369, 375, 240, L.apple.base) px(371, 239, L.apple.hi) px(373, 239, crowb.base)
  fill(rect(377, 236, 378, 244), T.base)
end
forage()

---------------------------------------------------------------- near detail, sky life
for _, f in ipairs({ { 112, 262, 6 }, { 192, 262, 7 }, { 200, 250, 5 }, { 286, 258, 6 }, { 196, 226, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.willow(110, 248, 5, 6, 96) F.willow(290, 244, 6, 7, 97)
F.drift(206, 266, 10, 3, 98)
F.tracks({ { 104, 266 }, { 112, 240 }, { 118, 224 } }, "hare", 7)
F.depth(0)
F.birds({ { 300, 30, 2 }, { 310, 36, 1 }, { 120, 60, 2 }, { 410, 50, 1 }, { 190, 30, 1 } })

F.finish()
