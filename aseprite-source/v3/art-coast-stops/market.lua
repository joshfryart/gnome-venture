-- market.lua : "Market hamlet" stop look, COAST (coast_driftwood), 480x270 gate view.
-- Same composition and hotspots as the Maplewold market (here-gate/pilot-market.lua) and its forest port
-- (art-forest-stops/market.lua), re-cast as a harbour-side market on a chalk-and-dune coast:
-- road's end: the Shore Path, a lichened granite arch under a driftwood lintel heaped with nets, cork and glass
-- floats and hanks of kelp, a lantern, and through it the path running down to the beach and the sea.
-- Back left: a whitewashed cottage (slate) and a tarred net loft (pantile) with smoke. Back right: the roofed
-- driftwood notice board (a gull carved on the peak, tide tables pinned up) and the whitewashed harbour rest house
-- with its porch bench, patchwork quilt and teapot. Left: the giant granite wishing well under a pantile roof, and
-- the Shell Swap (shell strings, painted pebbles, sea-glass jars, a crate of potted sea thrift). Right hero: the fish
-- stall: driftwood posts, slate roof, blue-and-cream valance, mackerel on ice, crabs, mussels, oysters, salt,
-- kippers and dulse hanging, a gnome fishwife in oilskins. Fish boxes and salt along the road. Bottom: the rock pool
-- with a jetty, the long table under a striped canopy (stargazy pie, crab, chips), a driftwood trough of sea kale.
-- Quirks kept from Maplewold, in coast dress: the teapot-hatted scarecrow (a gull on its arm), the barrow with
-- something far too big in it (a giant crab), the snail mailbox (a hermit crab in a whelk), and the haystack
-- house as a giant whelk-shell house.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-coast-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "market", out = DIR, duneLineGap = { 204, 276 },
  farTrees = { 24, 52, 290, 440 }, boats = { { 166, 97, 7 }, { 318, 95, 6 }, { 200, 100, 8 } },
  clouds = { { 112, 50, 46 }, { 292, 38, 60 }, { 420, 70, 34 }, { 26, 86, 30 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local courses, shadow, window, door = F.courses, F.shadow, F.window, F.door
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs

-- local ramps for the market goods
local silver = F.rp("#eef2ee #c4d0d0 #96a8ae #687c86 #42525c")  -- fish bellies
local mack = F.rp("#9cd0b4 #5ea08a #3e7a70 #2c5658 #1c3a40")    -- mackerel backs
local smoke = F.rp("#e6b878 #c08548 #94603a #6a422e #42281e")   -- kippers
local mussel = F.rp("#8a96b4 #58628a #3c4468 #2a3050 #1c2038")
local crab = F.rp("#f8a874 #e46c40 #b84a32 #86342c #521e20")
local dulse = F.rp("#d0848e #a8505e #803a4a #5c2a3a #3c1c28")
local kale = F.rp("#d6e6de #a4c4bc #789c94 #56766e #36504c")
local whelk = F.rp("#fbeedc #f0d6b6 #d4ae8a #a87e64 #6e4e40")
local honey = F.rp("#ffe08a #f2b440 #d08a2a #9c6424 #643e1e")

---------------------------------------------------------------- local helpers
local function hjar(x, yb, r, lidR) -- little jar 4 wide, 6 tall, cloth lid
  local m = rect(x, yb - 5, x + 3, yb)
  rimOf(m, L.timber)
  fill(m, r.base) vline(x, yb - 4, yb, r.hi) vline(x + 3, yb - 4, yb, r.shade) hline(x, x + 3, yb, r.deep)
  hline(x, x + 3, yb - 5, (lidR or L.awnB).base) px(x + 1, yb - 5, (lidR or L.awnB).hi)
  px(x + 1, yb - 3, "#f6f2d8")
  return m
end
local function lantern(x, y, cord) -- little hanging lantern, top at y
  if cord then vline(x, y - cord, y - 1, L.tar.edge) end
  local l = rect(x - 2, y + 1, x + 2, y + 6)
  local cap = rect(x - 2, y, x + 2, y)
  rimOf(union(l, cap), L.tar)
  fill(l, L.glow.base) px(x - 2, y + 1, L.glow.hi) px(x - 1, y + 1, L.glow.hi) vline(x + 2, y + 2, y + 6, L.glow.shade)
  hline(x - 2, x + 2, y, L.tar.base) hline(x - 1, x + 1, y + 6, L.tar.deep)
end
local function stripes(m, x0, w, rA, rB)
  m:each(function(x, y) px(x, y, ((x - x0) // w) % 2 == 0 and rA.base or rB.base) end)
  m:each(function(x, y) if not m:has(x, y + 1) then px(x, y, (((x - x0) // w) % 2 == 0 and rA or rB).shade) end end)
  m:each(function(x, y) if ((x - x0) % w) == 0 and m:has(x, y + 1) and ((x - x0) // w) % 2 == 0 then px(x, y, rA.hi) end end)
end
local function driftPosts(m) -- silvered driftwood posts: lit left, dark right, grain streaks, salt-white knots
  rimOf(m, L.tar)
  part(m, L.timber, { nopop = true, noshade = true })
  m:each(function(x, y)
    if not m:has(x - 1, y) then px(x, y, L.timber.hi)
    elseif not m:has(x + 1, y) then px(x, y, L.timber.shade) end
    if hash(x, y // 4, 88) < .12 then px(x, y, L.timber.deep) elseif hash(x, y // 3, 89) < .05 then px(x, y, L.awnB.shade) end
  end)
end
local function mackerel(x, y, flip) -- a mackerel lying flat, 9x3, head left (flip: head right)
  local rows = { ".BbBbBbBbT.", "eSSSSSSSSTT", ".sssssssT.." }
  if flip then for i, r in ipairs(rows) do rows[i] = r:reverse() end end
  F.sprite(rows, x, y, { B = mack.shade, b = mack.deep, T = mack.base, S = silver.hi, s = silver.base, e = L.tar.edge }, { rimCol = mack.deep })
end
local function wee_crab(x, y) -- a cooked crab seen from above, 5x4
  F.sprite({ "o...o", ".OHO.", "oOOOo", "o.o.o" }, x, y, { O = crab.base, H = crab.hi, o = crab.shade }, { rim = false })
end
local function ice(m, seed) -- crushed ice
  m:each(function(x, y) local v = hash(x, y, seed) px(x, y, v < .35 and L.foam or (v < .7 and L.water.hi or L.awnB.hi)) end)
end
local function fishBox(x0, x1, yb, h, kind, seed) -- shallow box heaped with goods
  local body = rect(x0, yb - h, x1, yb)
  local mid = (x0 + x1) // 2
  local heap = poly{ { x0 + 1, yb - h }, { x0 + 3, yb - h - 3 }, { mid, yb - h - 5 }, { x1 - 3, yb - h - 3 }, { x1 - 1, yb - h } }
  rimOf(union(body, heap), L.tar)
  part(body, L.board, { nopop = true })
  F.planks(body, L.board, 3, false, seed)
  hline(x0, x1, yb - h, L.board.hi)
  if kind == "mack" then
    ice(heap, seed)
    local k = 0
    for yy = yb - h - 4, yb - h - 1, 2 do for xx = x0 + 2 + (k % 2) * 3, x1 - 10, 8 do mackerel(xx, yy, k % 2 == 1) end k = k + 1 end
  elseif kind == "crab" then
    fill(heap, L.kelp.shade)
    heap:each(function(x, y) if hash(x, y, seed) < .3 then px(x, y, L.kelp.base) end end)
    for xx = x0 + 2, x1 - 6, 6 do wee_crab(xx, yb - h - 3 - (xx // 6) % 2) end
  elseif kind == "mussel" then
    heap:each(function(x, y)
      local bx, by = (x + (y // 2) % 2 * 2) % 3, y % 2
      px(x, y, by == 0 and (bx == 0 and mussel.hi or mussel.base) or (bx == 2 and mussel.deep or mussel.shade))
    end)
  elseif kind == "oyster" then
    heap:each(function(x, y) local v = hash(x // 2, y, seed) px(x, y, v < .3 and L.shingle.hi or (v < .7 and L.shingle.base or L.shingle.shade)) end)
    heap:each(function(x, y) if hash(x // 3, y // 2, seed + 1) < .2 and (x + y) % 3 == 0 then px(x, y, L.petal.hi) end end)
  elseif kind == "shell" then
    heap:each(function(x, y) local v = hash(x // 2, y, seed) px(x, y, v < .3 and whelk.hi or (v < .6 and whelk.base or (v < .85 and whelk.shade or L.petal.base))) end)
  end
  return body
end
local function kipper(x, y) -- a kipper hanging head-down, 3 wide, 8 tall
  F.sprite({ ".t.", "ttt", "sbs", "sbs", "sbs", "sbS", ".s.", ".h." }, x, y,
    { t = smoke.deep, s = smoke.base, b = smoke.hi, S = smoke.shade, h = honey.hi }, { rimCol = L.tar.edge })
end
local function dulseHank(x, y) -- a hank of dulse drying, tied with string
  vline(x + 1, y - 2, y, L.board.deep)
  F.sprite({ "dDd", "dDd", "DdD", "dDd.", "d.dD", "d..d" }, x, y + 1, { d = dulse.shade, D = dulse.base }, { rimCol = dulse.edge })
  px(x + 1, y + 2, dulse.hi) hline(x, x + 2, y + 1, L.cork.base)
end
local function glassFloat(x, y, r) -- a green glass float in a rope cage
  local m = c:ellipse(x, y, r, r)
  rimOf(m, L.glass) fill(m, L.glass.base)
  m:each(function(xx, yy) if (xx - x) + (yy - y) > r * .5 then px(xx, yy, L.glass.shade) end end)
  px(x - 1, y - 1, L.glass.hi) px(x - r + 1, y, L.glass.hi)
  hline(x - r, x + r, y, L.cork.shade) vline(x, y - r, y + r, L.cork.shade)
  return m
end
local function standGull(x, yb, flip) -- a little herring gull standing, feet at yb
  local rows = { "..WW...", ".eWWY..", ".WWW...", "WWWGGG.", "WWGGGKK", ".WWGGK.", "..p.p.." }
  if flip then for i, r in ipairs(rows) do rows[i] = r:reverse() end end
  F.sprite(rows, x - 3, yb - 6, { W = L.gull.hi, G = L.gull.shade, K = L.tar.deep, Y = L.gold.base, e = L.tar.edge, p = L.petal.shade }, { rimCol = L.gull.edge })
end

---------------------------------------------------------------- far quirks (plane 1): scarecrow + giant-crab barrow
F.depth(1)
F.tree(196, 118, 26, 1, true)
local function scarecrow()
  local t = L.timber
  local post = rect(108, 72, 109, 112):add(rect(100, 80, 117, 81))
  local shirt = poly{ { 103, 79 }, { 114, 79 }, { 116, 92 }, { 101, 92 } }
  local head = c:rrect(105, 70, 112, 78, 2)
  local hat = poly{ { 103, 66 }, { 114, 66 }, { 113, 70 }, { 104, 70 } }
  local spout = line({ { 114, 68 }, { 118, 65 } })
  local lid = rect(107, 63, 110, 65)
  rimOf(union(post, shirt, head, hat, spout, lid), L.tar)
  part(post, t, { nopop = true })
  part(shirt, L.accent)
  shirt:each(function(x, y) if y % 2 == 0 and (x + y) % 4 == 0 then px(x, y, L.accent.shade) end end) -- knit guernsey
  hline(102, 115, 88, L.awnA.base) hline(102, 115, 89, L.awnA.shade)                                    -- a red stripe
  part(head, L.cork) px(107, 73, L.tar.deep) px(110, 73, L.tar.deep) hline(107, 110, 76, L.cork.deep)    -- sacking face
  part(hat, L.wall2) part(lid, L.wall2) fill(spout, L.wall2.shade)                                      -- a blue enamel teapot
  hline(104, 113, 68, L.awnB.base)
  px(102, 69, L.wall2.deep) px(101, 68, L.wall2.deep)
  for _, p in ipairs({ { 99, 82 }, { 118, 82 }, { 103, 93 }, { 108, 93 }, { 113, 93 } }) do px(p[1], p[2], L.marram.base) px(p[1], p[2] + 1, L.marram.shade) end
  -- a herring gull perched on the arm
  F.sprite({ ".WW.", "eWWY", "WWGG", ".GGK", "..p." }, 112, 75, { W = L.gull.hi, G = L.gull.shade, K = L.tar.deep, Y = L.gold.base, e = L.tar.edge, p = L.petal.shade }, { rimCol = L.gull.edge })
end
scarecrow()
local function barrow()
  local t = L.timber
  local tray = poly{ { 158, 91 }, { 187, 91 }, { 183, 102 }, { 162, 102 } }
  local handles = line({ { 160, 95 }, { 150, 100 } }, 2):add(line({ { 166, 102 }, { 164, 107 } }, 2))
  local wheel = c:ellipse(184, 102, 6, 6)
  -- the giant crab, far too big for the barrow, claws up
  local body = c:ellipse(172, 82, 17, 9)
  local eyes = rect(166, 69, 167, 74):add(rect(177, 69, 178, 74))
  local armL = line({ { 158, 80 }, { 152, 70 }, { 154, 60 } }, 3)
  local armR = line({ { 186, 80 }, { 192, 70 }, { 190, 60 } }, 3)
  local clawL = poly{ { 148, 60 }, { 150, 48 }, { 155, 44 }, { 158, 50 }, { 154, 53 }, { 160, 56 }, { 158, 62 }, { 152, 64 } }
  local clawR = poly{ { 196, 60 }, { 194, 48 }, { 189, 44 }, { 186, 50 }, { 190, 53 }, { 184, 56 }, { 186, 62 }, { 192, 64 } }
  local legs = HP.mask()
  for k = 0, 2 do
    legs:add(line({ { 157, 84 + k * 2 }, { 152, 87 + k * 2 }, { 150, 90 + k } }, 1))
    legs:add(line({ { 187, 84 + k * 2 }, { 192, 87 + k * 2 }, { 194, 90 + k } }, 1))
  end
  local crabM = union(body, eyes, armL, armR, clawL, clawR, legs)
  rimOf(union(tray, handles, wheel, crabM), L.tar)
  part(handles, t, { nopop = true }) part(tray, L.timber) F.planks(tray, L.timber, 3, false, 77) part(wheel, L.stone, { nopop = true })
  hline(160, 185, 91, L.timber.hi) hline(162, 182, 97, L.timber.deep) vline(184, 97, 107, L.stone.deep) hline(178, 190, 102, L.stone.deep) px(184, 102, L.iron.hi)
  part(legs, crab, { nopop = true, noshade = true })
  part(union(armL, armR), crab, { nopop = true })
  part(body, crab)
  body:each(function(x, y)
    if (x - 172) * .5 + (y - 82) * 1.2 < -6 then px(x, y, crab.hi) end
    if y > 86 then px(x, y, crab.shade) end
    if hash(x // 2, y // 2, 140) < .1 then px(x, y, crab.deep) end
  end)
  hline(157, 187, 82, crab.shade) -- the shell lip
  for _, cm in ipairs({ clawL, clawR }) do
    part(cm, crab)
    cm:each(function(x, y) if y < 52 then px(x, y, crab.hi) end end)
  end
  -- black-tipped pincers
  fill(rect(150, 47, 152, 49), L.tar.base) fill(rect(192, 47, 194, 49), L.tar.base)
  fill(eyes, crab.shade) fill(rect(165, 68, 167, 70), L.tar.deep) fill(rect(177, 68, 179, 70), L.tar.deep)
  px(165, 68, L.gull.hi) px(177, 68, L.gull.hi)
  -- a little smile, and seawater slopping over the barrow rim
  line({ { 168, 86 }, { 172, 88 }, { 176, 86 } }):each(function(x, y) px(x, y, crab.deep) end)
  hline(161, 168, 91, L.water.hi) hline(177, 184, 91, L.water.hi) px(160, 92, L.foam) px(186, 92, L.foam)
end
barrow()

---------------------------------------------------------------- road's end: the Shore Path arch (plane 2)
F.depth(2)
F.tree(198, 128, 46, 2)
F.tree(282, 126, 42, 0)
local function shorePath()
  -- through the arch: the path running down to the beach, a dinghy drawn up, the surf
  local path = poly{ { 233, 124 }, { 247, 124 }, { 243, 110 }, { 238, 110 } }
  fill(path, L.sand.base)
  path:each(function(x, y) if hash(x // 2, y, 31) < .25 then px(x, y, L.sand.hi) elseif hash(x, y, 32) < .12 then px(x, y, L.sand.shade) end end)
  for i = 0, 3 do hline(238 - i, 242 + i, 112 + i * 3, L.sand.shade) end
  for i = 0, 6 do local x, y = 224 + floor(hash(i, 1, 33) * 32), 112 + floor(hash(i, 2, 33) * 11) if not path:has(x, y) then F.marram(x, y, 3) end end
  local dh = poly{ { 247, 106 }, { 257, 106 }, { 255, 109 }, { 249, 109 } }
  rimOf(dh, L.tar) fill(dh, L.wall2.base) hline(248, 256, 106, L.wall2.hi) hline(249, 255, 108, L.tar.base)
  F.driftwood(226, 109, 231, 108, 1)
  -- lichened granite pillars and a driftwood lintel heaped with nets and floats
  local pL, pR = rect(210, 76, 221, 124), rect(259, 76, 270, 124)
  local lintel = rect(206, 70, 274, 78)
  shadow(212, 270, 124, 8, 4)
  rimOf(union(pL, pR, lintel), L.tar)
  part(pL, L.stone) part(pR, L.stone)
  courses(union(pL, pR), 76, 6, 6, L.stone)
  F.lichen(union(pL, pR), .1, 34)
  F.barnacles(union(pL, pR), .1, 35, 116)
  part(lintel, L.timber)
  F.planks(lintel, L.timber, 3, false, 36)
  lintel:each(function(x, y) if y == 70 then px(x, y, L.timber.hi) elseif y == 78 then px(x, y, L.timber.deep) end end)
  F.logEnd(206, 74, 4) F.logEnd(274, 74, 4)
  -- the net heaps on the lintel: tarred mesh, a cork-floated rope, hanks of kelp
  local heaps = { { 216, 66, 10, 5 }, { 233, 63, 12, 7 }, { 251, 63, 11, 7 }, { 266, 66, 9, 5 } }
  local hm = HP.mask()
  for _, h in ipairs(heaps) do hm:add(c:ellipse(h[1], h[2], h[3], h[4]):clip(rect(h[1] - h[3], h[2] - h[4], h[1] + h[3], 70))) end
  rimOf(hm, L.tar)
  hm:each(function(x, y)
    local lt = (x - 240) / 40 + (y - 62) / 8
    local h = (x + y) % 3 == 0 and L.tar.base or ((x - y) % 3 == 0 and L.tar.shade or (lt < 0 and L.wall2.shade or L.wall2.deep))
    if not hm:has(x, y - 1) then h = L.tar.hi end
    px(x, y, h)
  end)
  for x = 210, 270, 5 do F.cork(x, 68 - floor(sin(x / 9) * 2)) end
  glassFloat(226, 60, 3) glassFloat(256, 59, 3) glassFloat(243, 56, 2)
  for _, k in ipairs({ { 209, 79, 9 }, { 213, 79, 6 }, { 266, 79, 8 }, { 271, 79, 10 } }) do
    for y = k[2], k[2] + k[3] do px(k[1] + (y > k[2] + 4 and 1 or 0), y, y == k[2] + k[3] and L.kelp.deep or (y % 2 == 0 and L.kelp.base or L.kelp.shade)) end
  end
  -- lantern hanging from the lintel, a blue fish plaque on the right pillar, marram and thrift at the feet
  lantern(240, 80, 1)
  local mk = rect(261, 100, 268, 107) rimOf(mk, L.tar) part(mk, L.wall2)
  F.sprite({ "f.ff.", "fffffe", "f.ff." }, 262, 102, { f = L.awnB.hi, e = L.tar.edge }, { rim = false })
  for _, f in ipairs({ { 212, 124, 5 }, { 219, 125, 4 }, { 262, 124, 4 }, { 269, 125, 5 } }) do F.marram(f[1], f[2], f[3]) end
  F.thrift(216, 126, false) F.thrift(265, 126, true)
end
shorePath()

---------------------------------------------------------------- back left: a whitewashed cottage and a tarred net loft (plane 1)
F.depth(1)
F.tree(10, 128, 30, 1)
do
  local top, cx, wall, roof = F.building{ x0 = 19, x1 = 45, yb = 134, wh = 32, rh = 22, wall = L.plaster, roof = L.roof, shingle = true, noFrame = true }
  F.lichen(roof, .06, 35)
  window(24, 110, 30, 116, L.wall2) door(34, 118, 41, 133, L.wall2)
  local top2, cx2, wall2, roof2 = F.building{ x0 = 52, x1 = 75, yb = 134, wh = 40, rh = 26, wall = L.tar, roof = L.roof2, chimney = true, shingle = true, noFrame = true }
  F.planks(wall2, L.tar, 4, true, 36)
  F.pantile(roof2, L.roof2, top2 - 26, 37)
  part(union(rect(52, top2, 53, 134), rect(74, top2, 75, 134)), L.timber, { nopop = true, noshade = true })
  window(57, 100, 63, 106, L.wall2) window(57, 116, 62, 122, L.wall2)
  door(66, 116, 72, 133, L.wall2)
  -- a net drying from the loft's gable
  F.netSwag(46, 51, 108, 10, { floatStep = 9 })
  local pot = rect(47, 128, 50, 133) rimOf(pot, L.tar) part(pot, L.roof2, { nopop = true })
  F.thrift(48, 127, true)
  F.smoke(66, 78, 6, .9, 2)
end

---------------------------------------------------------------- back right: notice board (plane 2)
F.depth(2)
F.tree(348, 134, 44, 0)
local function notice()
  local T = L.timber
  local roof = poly{ { 282, 60 }, { 313, 46 }, { 344, 60 }, { 344, 63 }, { 282, 63 } }
  local posts = rect(289, 63, 294, 136):add(rect(332, 63, 337, 136))
  local board = rect(287, 65, 339, 114)
  local bar = rect(286, 120, 340, 123)
  shadow(290, 338, 136, 10, 5)
  rimOf(union(roof, posts, board, bar), L.tar)
  driftPosts(posts)
  part(board, L.board, { band = 2 })
  F.planks(board, L.board, 6, true, 61)
  hline(287, 339, 65, T.base) hline(287, 339, 114, T.base) vline(287, 65, 114, T.base) vline(339, 65, 114, T.base)
  part(bar, T, { nopop = true }) hline(286, 340, 120, T.hi)
  part(roof, L.roof2, { sep = true }) F.pantile(roof, L.roof2, 46, 62)
  F.lichen(roof, .05, 63)
  -- the carved gull on the peak, wings up
  F.sprite({ "B.......B", "BB.....BB", ".BbbbbbS.", "..bEbbS..", "..bbbYY..", "..bbbS...", "...bS....", "..g..g..." }, 309, 38,
    { B = L.board.hi, b = L.board.base, S = L.board.shade, E = L.tar.edge, Y = L.gold.base, g = L.gold.shade })
  -- tide tables, a lost-and-found, a ferry notice, a fish-price list...
  local notes = { { 291, 69, 302, 82, L.awnB }, { 306, 70, 320, 80, L.wall2 }, { 324, 68, 335, 84, L.awnB },
                  { 292, 87, 305, 100, L.accent }, { 309, 85, 321, 104, L.chalk }, { 325, 89, 335, 99, L.gold },
                  { 296, 103, 306, 111, L.awnA }, { 323, 102, 334, 111, L.plaster } }
  for _, n in ipairs(notes) do
    local m = rect(n[1], n[2], n[3], n[4])
    part(m, n[5], { nopop = true })
    c:edgeIn(m, n[5].deep)
    for y = n[2] + 3, n[4] - 2, 3 do hline(n[1] + 2, n[3] - 2 - (y % 4), y, n[5].shade) end
    px((n[1] + n[3]) // 2, n[2] + 1, L.awnA.base)
  end
  -- the tide curve on the blue sheet, a pinned chart with a route line, a pressed frond, a gull feather
  for x = 308, 318 do px(x, 75 + floor(sin((x - 308) / 1.7) * 2 + .5), L.awnB.hi) end
  line({ { 311, 90 }, { 316, 96 }, { 312, 100 } }):each(function(x, y) px(x, y, L.awnA.base) end)
  F.sprite({ "..l", ".ll", "lLl", "lL.", "l.." }, 298, 89, { l = dulse.base, L = dulse.shade }, { rim = false })
  line({ { 327, 104 }, { 331, 109 } }):each(function(x, y) px(x, y, L.gull.shade) end) px(327, 104, L.tar.base)
  -- lantern on the right post, paste bucket, a gull eyeing it
  hline(337, 340, 70, L.tar.deep) vline(340, 70, 72, L.tar.deep)
  lantern(340, 73)
  local b = poly{ { 300, 128 }, { 308, 128 }, { 307, 135 }, { 301, 135 } } rimOf(b, L.tar) part(b, L.wall2, { nopop = true })
  vline(305, 122, 128, T.hi)
  standGull(318, 136)
end
notice()

---------------------------------------------------------------- back right: the harbour rest house (plane 2)
local function lodge()
  local top, cx, wall, roofM = F.building{ x0 = 360, x1 = 456, yb = 136, wh = 46, rh = 26, wall = L.plaster, roof = L.roof, chimney = true, shingle = true, noFrame = true }
  F.lichen(roofM, .03, 63)
  wall:each(function(x, y) if y > 131 and hash(x, y // 2, 64) < .35 then px(x, y, L.sand.shade) end end)
  local gab = poly{ { 366, 89 }, { 408, 72 }, { 450, 89 } }:cut(rect(402, 76, 413, 86))
  F.planks(gab, L.tar, 3, true, 60)
  F.smoke(447, 61, 5, 1.0, 2)
  -- pantile porch roof on driftwood posts
  local porch = poly{ { 356, 105 }, { 460, 105 }, { 463, 111 }, { 353, 111 } }
  rimOf(porch, L.roof2) part(porch, L.roof2, { sep = true }) F.pantile(porch, L.roof2, 105, 65)
  hline(356, 460, 105, L.roof2.hi)
  local pp = rect(361, 112, 362, 135):add(rect(454, 112, 455, 135))
  driftPosts(pp)
  window(366, 95, 378, 101, L.wall2) window(438, 95, 450, 101, L.wall2)
  window(370, 115, 380, 120, L.wall2) window(436, 115, 446, 120, L.wall2)
  door(400, 112, 416, 135, L.wall2)
  local sign = rect(398, 85, 418, 91) rimOf(sign, L.tar) part(sign, L.board)
  F.sprite({ ".a.", "aaa", ".a.", "a.a", ".a." }, 403, 86, { a = L.accent.shade }, { rim = false })       -- an anchor
  F.sprite({ ".b.b.", "bbbbb", ".bbb.", "..b.." }, 410, 86, { b = L.awnA.base }, { rim = false })       -- a heart: welcome
  lantern(421, 113)
  -- bench with patchwork quilt
  local bench = rect(364, 128, 396, 130):add(rect(365, 131, 367, 135)):add(rect(393, 131, 395, 135)):add(rect(364, 123, 366, 128))
  local quilt = rect(370, 124, 390, 133)
  shadow(366, 396, 135, 5, 2)
  rimOf(union(bench, quilt), L.tar)
  part(bench, L.timber, { nopop = true })
  local qc = { L.awnA.base, L.awnB.base, L.accent.base, L.wall2.hi, L.petal.base }
  quilt:each(function(x, y) px(x, y, qc[((x - 370) // 5 + (y - 124) // 4) % 5 + 1]) end)
  for x = 370, 390, 5 do vline(x, 124, 133, L.awnB.deep) end
  hline(370, 390, 133, L.awnA.deep)
  -- tea table + teapot + cups
  local tbl = rect(424, 127, 444, 129):add(rect(426, 130, 427, 135)):add(rect(441, 130, 442, 135))
  local pot = poly{ { 429, 120 }, { 438, 120 }, { 440, 126 }, { 427, 126 } }
  local lid = rect(432, 118, 435, 119)
  rimOf(union(tbl, pot, lid), L.tar)
  part(tbl, L.timber, { nopop = true }) part(pot, L.accent) part(lid, L.accent, { nopop = true })
  line({ { 440, 122 }, { 443, 119 } }):each(function(x, y) px(x, y, L.accent.deep) end)
  px(426, 122, L.accent.deep) px(425, 123, L.accent.deep)
  hline(429, 438, 123, L.awnB.base)
  fill(rect(441, 125, 443, 126), L.plaster.hi)
  -- thrift window boxes under the top windows
  for _, x in ipairs({ 365, 437 }) do
    hline(x, x + 14, 104, L.wall2.base)
    for i = 0, 14, 2 do px(x + i, 103, (i % 4 == 0) and L.petal.base or L.leaf.shade) px(x + i + 1, 102, (i % 4 == 2) and L.petal.hi or L.leaf.base) end
  end
end
lodge()

---------------------------------------------------------------- road side: hermit-crab whelk mailbox, signpost (plane 2/3)
local function mailbox()
  local post = rect(208, 136, 209, 146)
  local shell = poly{ { 202, 135 }, { 204, 128 }, { 209, 124 }, { 215, 122 }, { 218, 125 }, { 217, 131 }, { 213, 135 } }
  local foot = rect(198, 133, 214, 136)
  local claws = c:ellipse(200, 131, 2, 2):add(c:ellipse(197, 133, 2, 1))
  local stalks = rect(199, 125, 199, 128):add(rect(202, 125, 202, 128))
  rimOf(union(post, shell, foot, claws, stalks), L.tar)
  part(post, L.timber, { nopop = true })
  part(foot, L.timber, { nopop = true })
  part(claws, crab, { nopop = true })
  fill(stalks, crab.shade) px(199, 125, L.tar.edge) px(202, 125, L.tar.edge)
  part(shell, whelk)
  for k = 0, 3 do line({ { 204 + k * 3, 135 }, { 210 + k * 2, 124 + k } }):each(function(x, y) if shell:has(x, y) then px(x, y, whelk.shade) end end) end
  hline(205, 214, 132, L.petal.shade) px(206, 128, whelk.hi) px(207, 127, whelk.hi)
  F.barnacles(shell, .08, 64, 130)
  hline(204, 212, 134, L.awnB.base) -- a letter in the slot
  fill(rect(217, 126, 219, 129), L.awnA.base) vline(217, 126, 133, L.tar.deep)
end
mailbox()
local function signpost()
  local post = rect(442, 152, 445, 176)
  local b1 = poly{ { 430, 155 }, { 434, 151 }, { 454, 151 }, { 458, 155 }, { 454, 159 }, { 434, 159 } }
  local b2 = poly{ { 432, 165 }, { 436, 162 }, { 452, 162 }, { 456, 165 }, { 452, 168 }, { 436, 168 } }
  rimOf(union(post, b1, b2), L.tar)
  driftPosts(post)
  part(b1, L.board) part(b2, L.wall2)
  hline(436, 452, 155, L.board.deep) hline(438, 450, 165, L.wall2.deep)
  F.lichen(post, .18, 65)
  F.gull(450, 146, 2)
end
signpost()

F.depth(3)
-- stacked goods on the left verge: fish boxes of mackerel and crabs, a box of lemons, a sack of salt, a herring barrel
F.shadow(198, 222, 180, 8, 3)
F.crate(198, 180, 12, 9, mack)
F.crate(211, 180, 11, 9, crab)
F.crate(203, 170, 12, 8, L.gold)
F.sack(222, 182, L.awnB, 4)
F.shadow(200, 214, 204, 6, 2)
F.barrel(206, 204, L.timber, 11)
for k = 0, 3 do px(202 + k * 2, 193, silver.hi) px(203 + k * 2, 193, silver.shade) end
F.sack(216, 206, L.awnB, 4)
local coil = c:ellipse(226, 200, 4, 2)
rimOf(coil, L.cork) fill(coil, L.cork.base) hline(223, 229, 200, L.cork.shade) fill(c:ellipse(226, 200, 1, 0), L.cork.deep) px(223, 199, L.cork.hi)
-- right verge by the notice board: driftwood bundles for the fire and a barrel of cork floats
F.shadow(258, 280, 146, 6, 2)
for k = 0, 2 do F.logEnd(262 + k * 7, 142, 3) end
for k = 0, 1 do F.logEnd(265 + k * 7, 136, 3) end
hline(260, 280, 139, L.awnA.base)
F.barrel(282, 150, L.timber, 10)
for k = 0, 3 do F.cork(280 + k * 2, 139 - (k % 2)) end

---------------------------------------------------------------- the whelk-shell house (plane 3, replaces the haystack house)
local function whelkHouse()
  local m = poly{ { 420, 224 }, { 417, 216 }, { 417, 208 }, { 420, 201 }, { 425, 198 }, { 427, 195 }, { 429, 190 }, { 432, 187 }, { 435, 185 }, { 436, 181 }, { 439, 177 }, { 441, 174 }, { 443, 171 },
                  { 446, 174 }, { 450, 178 }, { 454, 181 }, { 453, 185 }, { 457, 188 }, { 460, 193 }, { 462, 197 }, { 461, 199 }, { 465, 203 }, { 468, 210 }, { 468, 218 }, { 466, 224 } }
  local pipe = rect(452, 176, 454, 186)
  shadow(426, 462, 224, 8, 3)
  rimOf(union(m, pipe), L.tar)
  part(m, whelk)
  -- sutures: each whorl's lower lip slants down to the right with a slight belly; a dark groove, the whorl
  -- under it lit along its shoulder, thin brown spiral cords between
  local sut = { 179, 186, 194, 204 }
  local function sy(y0, x) local t = (x - 418) / 50 return y0 + t * 7 + 2.2 * math.sin(t * pi) end
  m:each(function(x, y)
    local prev, nxt = 172, 240
    for _, y0 in ipairs(sut) do local yy = sy(y0, x) if yy <= y then prev = math.max(prev, yy) else nxt = math.min(nxt, yy) end end
    local dn = nxt - y
    local t = (y - prev) / math.max(1, nxt - prev)
    local side = (x - 443) / 25
    local h
    if dn < 1 then h = whelk.deep
    elseif dn < 2 then h = whelk.shade
    elseif t < .3 then h = side < .3 and whelk.hi or whelk.base
    elseif t < .7 then h = side < .5 and whelk.base or whelk.shade
    else h = side < -.2 and whelk.base or whelk.shade end
    if h ~= whelk.deep and (x * 2 + floor(y * .7)) % 9 == 0 and hash(x, y // 3, 66) < .5 then h = L.cork.base end -- growth streaks
    px(x, y, h)
  end)
  -- the apex tip, darker
  fill(rect(442, 173, 444, 175), whelk.deep) px(443, 172, L.cork.deep)
  part(pipe, L.iron, { nopop = true }) hline(451, 455, 176, L.iron.deep)
  -- barnacles and wrack at the foot, a thrift cushion on a whorl
  F.barnacles(m, .12, 68, 214)
  m:each(function(x, y) if y > 220 and hash(x // 2, y, 69) < .4 then px(x, y, hash(x, y, 70) < .5 and L.kelp.base or L.kelp.shade) end end)
  -- the aperture: a glossy pink lip flaring round the door
  local ap = c:ellipse(441, 216, 9, 12):clip(rect(420, 203, 462, 223))
  fill(ap, L.petal.base)
  ap:each(function(x, y) if x < 437 or y < 207 then px(x, y, L.petal.hi) elseif x > 446 then px(x, y, L.petal.shade) end end)
  c:edgeIn(ap, L.petal.deep)
  door(436, 207, 446, 223, L.wall2, true)
  local w = c:ellipse(456, 200, 2, 2) rimOf(w, L.tar) fill(w, L.glow.base) px(455, 199, L.glow.hi)
  local w2 = c:ellipse(441, 190, 1, 1) rimOf(w2, L.tar) fill(w2, L.glow.base)
  F.thrift(428, 200, true)
  F.shell(462, 226, true) F.shell(418, 226, false)
end
whelkHouse()

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
  rimOf(union(roofOuter, postL, postR, lipTop, lipFront, drum, crank, axle, bucket), L.tar)
  part(drum, S) courses(drum, 165, 7, 13, S)
  F.lichen(drum, .015, 71)
  F.barnacles(drum, .08, 81, 196)
  drum:each(function(x, y) if y > 202 and hash(x // 2, y, 82) < .4 then px(x, y, L.sand.shade) end end)
  part(lipFront, S, { sep = true }) courses(lipFront, 156, 10, 17, S, 5)
  F.lichen(lipFront, .04, 72)
  part(lipTop, S, { sep = true })
  lipTop:each(function(x, y) if hash(x // 2, y, 73) < .16 then px(x, y, L.lichen.base) end end)
  local opening = poly{ { 106, 149 }, { 180, 149 }, { 184, 154 }, { 102, 154 } }
  fill(opening, L.water.deep) hline(110, 178, 149, S.edge) hline(118, 128, 152, L.water.shade) hline(156, 170, 151, L.water.shade)
  px(165, 152, L.glow.hi) px(166, 152, L.glow.base)
  driftPosts(union(postL, postR))
  part(axle, T, { nopop = true }) hline(110, 176, 130, T.hi)
  for x = 136, 150, 3 do vline(x, 131, 133, L.cork.base) end
  fill(rope, L.cork.base) part(crank, T, { nopop = true }) fill(rect(188, 140, 191, 143), L.wall2.base)
  part(bucket, L.wall2) hline(135, 151, 144, L.iron.shade) hline(136, 150, 150, L.iron.shade)
  line({ { 135, 141 }, { 143, 137 }, { 151, 141 } }):each(function(x, y) px(x, y, L.iron.deep) end)
  hline(137, 149, 142, L.water.hi)
  part(roofM, RR, { sep = true }) F.pantile(roofM, RR, 92, 74)
  F.lichen(roofM, .025, 75)
  line({ { 91, 120 }, { 143, 93 } }):each(function(x, y) if roofM:has(x, y) then px(x, y, RR.hi) end end)
  line({ { 195, 120 }, { 143, 93 } }):each(function(x, y) if roofM:has(x, y) then px(x, y, RR.shade) end end)
  hline(90, 196, 126, RR.edge) hline(91, 195, 125, RR.deep)
  part(gable, L.board, { nopop = true })
  F.planks(gable, L.board, 4, true, 76)
  vline(143, 106, 121, T.base)
  line({ { 143, 112 }, { 130, 120 } }):each(function(x, y) px(x, y, T.base) end)
  line({ { 143, 112 }, { 156, 120 } }):each(function(x, y) px(x, y, T.base) end)
  -- a glass-float finial in its rope cage
  vline(143, 89, 92, L.tar.base)
  glassFloat(143, 86, 3)
  -- marram, thrift and shells at the drum foot, coins glinting in the water
  for _, f in ipairs({ { 98, 208, 7 }, { 106, 210, 5 }, { 186, 208, 6 }, { 192, 206, 5 } }) do F.marram(f[1], f[2], f[3]) end
  F.thrift(112, 211, true) F.thrift(176, 211, false)
  F.shell(120, 212, true) F.shell(160, 211, false) F.shell(168, 213, true)
  c:sparkle(176, 160)
end
well()

---------------------------------------------------------------- left: the Shell Swap (plane 3)
local function shellSwap()
  local top, cx, wall, roofM = F.building{ x0 = 19, x1 = 75, yb = 212, wh = 42, rh = 16, wall = L.plaster, roof = L.roof, shingle = true, noFrame = true, noAttic = true }
  F.lichen(roofM, .03, 76)
  wall:each(function(x, y) if y > 207 and hash(x, y // 2, 77) < .35 then px(x, y, L.sand.shade) end end)
  -- a fish weathervane on the ridge
  vline(cx, top - 24, top - 16, L.tar.base)
  F.sprite({ "f..ff..", "ffffffe", "f..ff.." }, cx - 3, top - 27, { f = L.gold.base, e = L.tar.edge })
  -- shop window full of shell strings, painted pebbles, sea-glass jars
  fill(rect(23, 183, 71, 199), L.tar.deep) fill(rect(24, 184, 70, 198), L.glow.shade)
  fill(rect(24, 184, 70, 187), L.glow.base)
  for i = 0, 7 do -- shell strings hanging
    local x = 26 + i * 6
    vline(x, 184, 190 + (i % 2) * 2, L.cork.deep)
    for y = 185, 189 + (i % 2) * 2, 2 do px(x, y, (y + i) % 4 == 1 and L.petal.hi or whelk.hi) px(x + 1, y, whelk.shade) end
  end
  hline(24, 70, 193, L.timber.base)
  for i = 0, 4 do -- sea-glass jars and painted pebbles
    local x = 26 + i * 9
    fill(rect(x, 194, x + 5, 198), L.water.hi) hline(x, x + 5, 194, L.timber.base)
    local rr = (i % 2 == 0) and L.glass or L.wall2
    fill(rect(x + 1, 196, x + 4, 198), rr.base) px(x + 1, 196, rr.hi) px(x + 3, 197, L.awnB.hi)
  end
  -- striped awning, red and cream
  local aw = poly{ { 18, 182 }, { 22, 174 }, { 72, 174 }, { 76, 182 } }
  for x = 18, 76, 4 do aw:add(poly{ { x, 182 }, { x + 4, 182 }, { x + 2, 185 } }) end
  aw:clip(rect(17, 170, 77, 186))
  rimOf(aw, L.awnA)
  stripes(aw, 18, 4, L.awnA, L.awnB)
  hline(22, 72, 174, L.awnB.hi)
  -- hanging sign: a scallop shell
  vline(30, 168, 170, L.tar.edge) vline(40, 168, 170, L.tar.edge)
  local sg = rect(28, 160, 42, 167) rimOf(sg, L.tar) part(sg, L.wall2)
  F.sprite({ "..sss..", ".sSsSs.", "sSsSsSs", ".sSsSs.", "..ttt.." }, 32, 161, { s = whelk.hi, S = whelk.shade, t = whelk.deep }, { rim = false })
  door(26, 200, 32, 211, L.wall2)
  -- crate of potted sea thrift for swapping
  local crate = rect(48, 202, 72, 211) rimOf(crate, L.tar) part(crate, L.board) hline(48, 72, 206, L.board.deep)
  for i = 0, 3 do F.thrift(52 + i * 6, 202, i % 2 == 0) end
end
shellSwap()
F.marram(22, 214, 6) F.marram(80, 212, 6)

---------------------------------------------------------------- right hero: the fish stall (plane 3)
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
  rimOf(union(roof, val, posts, back, ctop, cfront, legs), L.tar)
  driftPosts(posts)
  -- back wall of tarred boards, two shelves of jars: pickled herring, salt, sea glass, heather honey
  fill(back, L.tar.deep)
  F.planks(rect(301, 179, 399, 194), L.tar, 5, true, 79)
  hline(301, 399, 186, L.tar.edge) hline(301, 399, 193, L.tar.edge)
  for i = 0, 15 do
    local x = 303 + i * 6
    local rr = ({ L.glass, L.awnB, L.water, honey, L.glass, L.awnB })[i % 6 + 1]
    if x < 342 or x > 362 then
      hjar(x, 185, rr, (i % 3 == 0) and L.awnA or L.wall2)
      if i % 2 == 0 then hjar(x + 1, 192, ({ honey, L.awnB, L.glass })[i % 3 + 1], L.awnB) end
    end
  end
  -- the fishwife, behind the counter, in oilskins
  F.gnome(352, 202, { hat = L.awnA, coat = L.gorse, arm = "up", noShadow = true })
  -- slate roof with lichen + blue/cream valance
  part(roof, L.roof, { sep = true }) courses(roof, 151, 3, 5, L.roof)
  F.lichen(roof, .025, 81)
  line({ { 289, 167 }, { 300, 152 } }):each(function(x, y) if roof:has(x, y) then px(x, y, L.roof.hi) end end)
  hline(300, 400, 151, L.roof.hi)
  stripes(val, 289, 8, L.wall2, L.awnB)
  hline(289, 411, 167, L.wall2.deep)
  -- sign on the ridge with the wares painted on: fish, crab, shell, salt jar, kelp
  local sign = rect(330, 143, 370, 150)
  rimOf(sign, L.tar) part(sign, L.board) hline(331, 369, 150, L.board.deep)
  F.sprite({ "f.ff.", "fffff", "f.ff." }, 332, 145, { f = mack.shade }, { rim = false })
  F.sprite({ "c.c", "ccc", "c.c" }, 340, 145, { c = crab.base }, { rim = false })
  F.sprite({ ".s.", "sss", "sSs" }, 346, 145, { s = whelk.shade, S = whelk.deep }, { rim = false })
  F.sprite({ "aaa", "www", "www" }, 352, 145, { a = L.wall2.base, w = L.awnB.deep }, { rim = false })
  F.sprite({ ".k.", "kk.", ".kk" }, 360, 145, { k = L.kelp.shade }, { rim = false })
  vline(336, 151, 151, L.tar.deep) vline(364, 151, 151, L.tar.deep)
  -- hanging under the valance: lanterns, kippers, dulse hanks
  lantern(304, 180, 1)
  lantern(396, 180, 1)
  hline(310, 334, 179, L.board.deep)
  for k = 0, 3 do kipper(311 + k * 6, 180) end
  for k = 0, 2 do dulseHank(368 + k * 6, 180) end
  -- counter: tarred board front, plank top
  part(cfront, T)
  F.planks(cfront, T, 6, true, 83)
  for x = 296, 404, 27 do vline(x, 200, 220, L.tar.base) end
  cfront:each(function(x, y) if y > 215 and hash(x // 2, y, 84) < .3 then px(x, y, L.sand.shade) end end)
  part(ctop, L.board) hline(299, 401, 194, L.board.hi)
  part(legs, T, { nopop = true })
  -- goods on the counter: mackerel on ice, cooked crabs on wrack, mussels, oysters
  fishBox(300, 321, 198, 4, "mack", 82)
  fishBox(322, 340, 198, 4, "crab", 83)
  fishBox(364, 384, 198, 4, "mussel", 84)
  fishBox(386, 400, 198, 4, "oyster", 85)
  -- a salt cone on a board
  local salt = poly{ { 342, 197 }, { 346, 190 }, { 350, 197 } } rimOf(salt, L.chalk) fill(salt, L.chalk.base)
  salt:each(function(x, y) if x > 346 then px(x, y, L.chalk.shade) elseif x < 346 and y < 196 then px(x, y, L.awnB.hi) end end)
  -- a hanging scale pan by the post
  vline(299 + 6, 178, 181, L.iron.deep)
  -- crates in front: lobsters on seaweed, scallops
  local cr1 = rect(308, 210, 332, 222) rimOf(cr1, L.tar) part(cr1, L.board) F.planks(cr1, L.board, 4, false, 86)
  hline(308, 332, 216, L.board.deep)
  hline(309, 331, 209, L.kelp.base)
  for k = 0, 3 do
    local x = 310 + k * 6
    F.sprite({ "a.....", "CCCCt.", ".cccTT" }, x, 206, { C = crab.base, c = crab.shade, t = crab.deep, T = crab.shade, a = crab.hi }, { rimCol = crab.edge })
  end
  local cr2 = rect(362, 210, 386, 222) rimOf(cr2, L.tar) part(cr2, L.board) hline(362, 386, 216, L.board.deep) vline(374, 210, 222, L.board.deep)
  for k = 0, 5 do local x = 364 + k * 4 hline(x, x + 2, 209, whelk.hi) hline(x, x + 2, 208, k % 2 == 0 and L.petal.hi or whelk.base) px(x + 1, 207, whelk.hi) px(x + 2, 209, whelk.shade) end
  F.sack(392, 224, L.awnB, 4)
end
stall()
fishBox(410, 426, 224, 4, "shell", 90)
fishBox(414, 430, 214, 4, "mussel", 91)
F.lobsterPot(281, 214, 5)
-- a shopper with a basket (a fish tail out of it), by the stall
local _, shx, shy = F.gnome(284, 228, { hat = L.roof2, coat = L.wall2, arm = "out", flip = true })
local bk = poly{ { shx - 3, shy }, { shx + 3, shy }, { shx + 2, shy + 5 }, { shx - 2, shy + 5 } }
rimOf(bk, L.tar) part(bk, L.cork, { nopop = true })
px(shx - 1, shy - 1, silver.hi) px(shx - 2, shy - 2, mack.base) px(shx - 3, shy - 3, mack.shade) px(shx + 1, shy - 1, L.gold.base)
line({ { shx - 3, shy }, { shx, shy - 3 }, { shx + 3, shy } }):each(function(x, y) if y < shy then px(x, y, L.cork.deep) end end)

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
  rimOf(union(can, posts, top, cloth, legs, bench), L.tar)
  driftPosts(posts)
  stripes(can, 120, 4, L.accent, L.awnB)
  hline(128, 180, 222, L.awnB.hi)
  part(legs, L.timber, { nopop = true })
  part(top, L.board) F.planks(top, L.board, 5, true, 86)
  part(cloth, L.wall2, { nopop = true })
  cloth:each(function(x, y) if ((x // 3) + (y // 2)) % 2 == 0 then px(x, y, L.wall2.shade) end end) -- blue gingham
  for x = 127, 181, 3 do px(x, 254, L.wall2.hi) end
  part(bench, L.timber, { nopop = true })
  -- feast: teapot, stargazy pie, a crab on a plate, a jug, plates of chips
  local tp = poly{ { 134, 239 }, { 142, 239 }, { 143, 245 }, { 133, 245 } }
  rimOf(tp, L.tar) part(tp, L.roof2) line({ { 143, 241 }, { 146, 238 } }):each(function(x, y) px(x, y, L.roof2.deep) end)
  px(137, 238, L.roof2.deep) px(138, 238, L.roof2.deep)
  local pie = poly{ { 150, 243 }, { 162, 243 }, { 164, 246 }, { 148, 246 } } rimOf(pie, L.tar) part(pie, honey, { nopop = true })
  for x = 151, 161, 3 do px(x, 242, silver.base) px(x, 241, silver.hi) px(x + 1, 242, L.tar.edge) end -- fish heads gazing up
  hline(166, 175, 246, L.awnB.hi) wee_crab(168, 242)
  vline(173, 239, 241, L.tar.edge)
  for x = 131, 147, 11 do hline(x, x + 3, 247, L.plaster.hi) px(x + 1, 246, L.gold.base) px(x + 2, 246, L.gold.hi) end
  local jug = rect(176, 240, 178, 245) rimOf(jug, L.tar) part(jug, L.awnB, { nopop = true })
  lantern(130, 236, 0)
  lantern(178, 236, 0)
end
longTable()

---------------------------------------------------------------- bottom left: the rock pool with a jetty (plane 3)
local function pool()
  local bank = poly{ { 18, 238 }, { 32, 228 }, { 72, 226 }, { 100, 232 }, { 108, 246 }, { 100, 260 }, { 60, 264 }, { 26, 262 }, { 16, 252 } }
  local water = bank:shrink(3)
  shadow(24, 104, 262, 6, 3)
  rimOf(bank, L.stone)
  fill(bank, L.stone.base)
  bank:each(function(x, y) if not water:has(x, y) then local v = hash(x // 2, y, 51) px(x, y, v < .3 and L.stone.base or (v < .5 and L.stone.hi or (v < .75 and L.kelp.base or L.kelp.shade))) end end)
  F.water(water, L.water)
  -- reflections of the rocks and sky along the far edge
  for _, rx in ipairs({ 36, 58, 84 }) do for k = 0, 2 do hline(rx - 3 + k, rx + 3 - k, 233 + k * 2, L.water.shade) end end
  -- submerged rocks with anemones, a starfish
  for _, r in ipairs({ { 40, 248, 7, 3 }, { 30, 256, 5, 2 } }) do
    local m = c:ellipse(r[1], r[2], r[3], r[4]):clip(water)
    fill(m, L.water.shade) m:each(function(x, y) if y < r[2] - r[4] + 2 then px(x, y, L.water.base) end end)
  end
  for _, a in ipairs({ { 37, 246 }, { 43, 247 }, { 29, 255 } }) do px(a[1], a[2], L.apple.base) px(a[1], a[2] - 1, L.apple.hi) px(a[1] + 1, a[2], L.apple.deep) end
  F.sprite({ "..o..", "ooOoo", ".oOo.", "o...o" }, 50, 252, { o = L.produce.base, O = L.produce.hi }, { rimCol = L.produce.edge })
  -- jetty
  local jet = poly{ { 70, 240 }, { 104, 240 }, { 106, 250 }, { 72, 250 } }
  local legs = rect(74, 250, 76, 257):add(rect(100, 250, 102, 256)):add(rect(86, 250, 88, 256))
  rimOf(union(jet, legs), L.tar)
  part(legs, L.timber, { nopop = true })
  part(jet, L.board)
  jet:each(function(x, y) if (x - y // 3) % 5 == 0 then px(x, y, L.board.deep) end end)
  hline(72, 105, 250, L.timber.deep)
  F.barnacles(legs, .3, 52, 252)
  legs:each(function(x, y) if y > 254 then px(x, y, L.kelp.base) end end)
  -- rod leaning, line + red float
  line({ { 98, 240 }, { 80, 222 }, { 66, 220 } }):each(function(x, y) px(x, y, L.tar.deep) end)
  vline(66, 221, 236, L.awnB.shade) fill(rect(65, 236, 67, 238), L.awnA.base) px(65, 236, L.awnA.hi)
  hline(62, 70, 239, L.water.hi)
  -- marram on the bank (in place of cattails)
  for i = 0, 5 do F.marram(20 + i * 4, 252 - (i % 2), 5 + floor(hash(i, 9, 52) * 4)) end
  -- tackle box and a creel on the jetty
  local box = rect(90, 234, 99, 239) rimOf(box, L.tar) part(box, L.accent) hline(90, 99, 236, L.accent.deep)
  local fb = poly{ { 78, 234 }, { 86, 234 }, { 85, 239 }, { 79, 239 } } rimOf(fb, L.tar) part(fb, L.cork, { nopop = true })
  for x = 79, 85, 2 do vline(x, 235, 238, L.cork.shade) end
  px(80, 233, silver.hi) px(81, 233, silver.base) px(83, 233, mack.base)
  F.barnacles(F.rock(16, 238, 6, 5), .2, 53, 0)
  -- a little green shore crab on the bank (in place of the frog)
  F.sprite({ "g.g.g", ".GGG.", "g.g.g" }, 98, 229, { g = L.leaf.deep, G = L.kelp.base })
end
pool()

---------------------------------------------------------------- bottom right: a driftwood trough of sea kale and samphire (plane 3)
local function trough()
  local T = L.timber
  local soil = poly{ { 304, 247 }, { 368, 247 }, { 374, 254 }, { 298, 254 } }
  local front = rect(298, 254, 374, 262)
  local back = rect(304, 245, 368, 247)
  shadow(300, 374, 262, 8, 2)
  rimOf(union(soil, front, back), L.tar)
  part(back, T, { nopop = true })
  fill(soil, L.sand.shade) soil:each(function(x, y) if hash(x, y, 71) < .2 then px(x, y, L.sand.deep) elseif hash(x, y, 72) < .1 then px(x, y, L.shingle.base) end end)
  part(front, T) F.planks(front, T, 4, false, 87)
  front:each(function(x, y) if hash(x, y // 2, 88) < .06 then px(x, y, L.awnB.shade) end end)
  F.logEnd(298, 258, 4) F.logEnd(374, 258, 4)
  for _, x in ipairs({ 308, 330, 352 }) do -- sea-kale crowns: glaucous wavy leaves, white flower heads
    local b = poly{ { x - 6, 252 }, { x - 5, 245 }, { x - 2, 242 }, { x + 2, 242 }, { x + 5, 245 }, { x + 6, 252 } }
    rimOf(b, kale) part(b, kale)
    b:each(function(xx, y) if (xx + y) % 4 == 0 then px(xx, y, kale.shade) end end)
    for k = -3, 3, 2 do px(x + k, 241 - (k % 4 == 1 and 1 or 0), L.awnB.hi) px(x + k, 240 - (k % 4 == 1 and 1 or 0), L.foam) end
  end
  for _, x in ipairs({ 319, 341, 363 }) do -- samphire: little jointed green fingers
    for k = -4, 4, 2 do
      local h = 5 + floor(hash(x, k, 73) * 4)
      vline(x + k, 251 - h, 251, k < 0 and L.leaf.base or L.leaf.shade)
      px(x + k, 251 - h, L.leaf.hi) px(x + k + 1, 251 - h + 2, L.leaf.base)
    end
  end
  fill(rect(371, 238, 372, 246), T.base)
  local bl = poly{ { 369, 246 }, { 374, 246 }, { 372, 251 } } fill(bl, L.iron.base) px(370, 246, L.iron.hi)
end
trough()

---------------------------------------------------------------- near marram, thrift, shells, driftwood; sky life
for _, f in ipairs({ { 112, 262, 7 }, { 192, 262, 8 }, { 200, 250, 6 }, { 290, 258, 7 }, { 376, 226, 6 }, { 196, 226, 6 } }) do F.marram(f[1], f[2], f[3]) end
F.thrift(204, 262, true) F.thrift(209, 266, false) F.thrift(292, 248, false)
F.shell(214, 262, true) F.shell(190, 240, false) F.shell(270, 262, true) F.shell(276, 266, false)
F.driftwood(194, 254, 210, 256, 2)
F.wrack(256, 264, 8, 3)
F.depth(0)
F.gull(300, 30, 3) F.gull(312, 38, 2) F.gull(124, 30, 2) F.gull(410, 50, 2) F.gull(214, 44, 1)
F.birds({ { 330, 44, 1 } })

F.finish()
