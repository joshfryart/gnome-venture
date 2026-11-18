-- market.lua : "Market hamlet" stop look, WETLAND (wetland_reed), 480x270 gate view.
-- Same composition and hotspots as the Maplewold market (here-gate/pilot-market.lua), re-cast as a boardwalk and
-- punt market on a marsh channel:
-- road's end: the Wild Trail, a woven willow-withy arch on tarred posts, a lantern, a boardwalk running off into
-- tall reed and mist. Back left: a daub cottage and a tarred cottage on a low deck, peat smoke. Back right: the
-- reed-thatched notice board (a heron carved on the peak, a goose at its foot) and the rest house on a deck over
-- the marsh channel, porch bench with a patchwork quilt and a teapot. Along the channel: punts moored as floating
-- stalls (cranberries, eel traps), a gnome poling. Left: the wishing well as a hooped tarred-stave cistern under a
-- reed hood on a boardwalk, and the Seed Swap hut (seed packets, jars of seeds, a crate of iris and marigold
-- seedlings). Right hero: the trader stall on stilts over a pool: reed thatch with a red-and-cream valance, smoked
-- eels hanging, woven reed baskets of cranberries and duck eggs, jars, a gnome stallkeeper, a punt of eel traps
-- moored in front, ducks. Stacked goods along the road. Bottom: the eel pond with a jetty and a mallard brood, the
-- long table under a striped canopy (cranberry pie, smoked eel, duck eggs), and the forage patch as a flooded
-- cranberry bog with the berries floating.
-- Quirks kept from Maplewold, in fen dress: the teapot-hatted scarecrow (reed-stuffed), the barrow growing
-- something too big (a giant cranberry), the snail mailbox (a great pond snail), the haystack house (a reed-stook
-- house), and a mallard in a red gnome hat sitting on the duck-egg basket.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-wetland-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "market", out = DIR, treeLineGap = { 204, 276 }, poolK = .8,
  farTrees = { 24, 52, 160, 330, 352, 440 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local courses, shadow, window, door = F.courses, F.shadow, F.window, F.door
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs

-- local ramps for fen market goods
local TAR = F.rp("#8a8c80 #64685e #4a4e48 #363a36 #24282a")       -- tarred weatherboard / posts
local cran = F.rp("#ff9a94 #d8344c #a6203e #70162e #44101e")      -- cranberries
local egg = F.rp("#f2f2e2 #d6e2d2 #b0c4b8 #849a92 #54645e")       -- duck eggs, pale blue-green
local eelR = F.rp("#d0a870 #9a7244 #6a5034 #463626 #2a201a")      -- smoked eel
local mal = F.rp("#8cd2a2 #3e8c64 #2a6a4e #1e4c3a #14302a")       -- mallard green
local chest = F.rp("#d89a74 #ac6a4a #84503a #5e382c #3a2420")     -- chestnut breast / hen brown
local cress = F.rp("#c6e08a #8cb85a #64903e #466a32 #2c4626")     -- watercress
local iris = F.rp("#c8b4f0 #8c72d0 #6650a8 #483a7c #2e2650")      -- flag iris (purple) for the seedlings
local withy = F.rp("#e2c88c #b89660 #8e7046 #644e34 #3e3024")     -- peeled / dried willow withies
local oak = F.rp("#cdb894 #a48e6a #7e6a50 #5a4c3c #3a3028")       -- weathered oak staves
local amber = F.rp("#ecc88e #c49a5c #986e42 #6c4c30 #44301e")     -- pond-snail shell

---------------------------------------------------------------- local helpers
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
local function tarPosts(m) -- tarred square posts: lit left edge, dark right edge, grain flecks
  rimOf(m, TAR)
  part(m, TAR, { nopop = true, noshade = true })
  m:each(function(x, y)
    if not m:has(x - 1, y) then px(x, y, TAR.hi) elseif not m:has(x + 1, y) then px(x, y, TAR.deep) end
    if hash(x, y // 3, 88) < .1 then px(x, y, TAR.shade) end
  end)
end
local function weave(m, r, ox, oy) -- wicker / woven reed: staggered 2x2 over-under, lit upper-left of each strand
  m:each(function(x, y)
    local bx, by = (x - (ox or 0)) // 2, (y - (oy or 0)) // 2
    local over = (bx + by) % 2 == 0
    local sx, sy = (x - (ox or 0)) % 2, (y - (oy or 0)) % 2
    local h
    if over then h = (sx == 0 and sy == 0) and r.hi or r.base else h = (sy == 1) and r.deep or r.shade end
    px(x, y, h)
  end)
end
-- woven reed basket heaped with goods: kind = "cran" | "egg" | "eel" | "cress"
local function basket(x0, x1, yb, h, kind, seed)
  local body = poly{ { x0, yb - h }, { x1, yb - h }, { x1 - 2, yb }, { x0 + 2, yb } }
  local mid = (x0 + x1) // 2
  local heap = poly{ { x0 + 1, yb - h }, { x0 + 3, yb - h - 3 }, { mid, yb - h - 6 }, { x1 - 3, yb - h - 3 }, { x1 - 1, yb - h } }
  rimOf(union(body, heap), L.reed)
  weave(body, L.reed, x0, yb)
  hline(x0, x1, yb - h, L.reed.hi) hline(x0 + 2, x1 - 2, yb, L.reed.deep)
  if kind == "cran" then
    fill(heap, cran.shade)
    heap:each(function(x, y)
      local bx, by = (x + (y // 2) % 2) % 2, y % 2
      if bx == 0 and by == 0 then px(x, y, cran.hi) elseif bx == 1 and by == 0 then px(x, y, cran.base) elseif bx == 1 and by == 1 then px(x, y, cran.deep) end
    end)
  elseif kind == "egg" then
    fill(heap, egg.deep)
    heap:each(function(x, y)
      local row = (y - (yb - h - 6)) // 2
      local u = (x + row * 2) % 4
      local v = (y - (yb - h - 6)) % 2
      if u <= 2 then px(x, y, (u == 0 and v == 0) and egg.hi or (v == 1 and u == 2 and egg.shade or egg.base)) end
    end)
    for k = 0, 2 do px(x0 + 4 + k * 5, yb - h - 2 + (k % 2), "#b8a684") end -- a few brown-speckled ones
  elseif kind == "eel" then
    fill(heap, eelR.deep)
    heap:each(function(x, y) local d = (x - mid) * (x - mid) + (y - (yb - h)) * (y - (yb - h)) * 4
      if floor(math.sqrt(d)) % 3 == 0 then px(x, y, eelR.hi) elseif floor(math.sqrt(d)) % 3 == 1 then px(x, y, eelR.base) end end)
  else
    part(heap, cress, { nopop = true })
    heap:each(function(x, y) local v = hash(x, y, seed) if v < .25 then px(x, y, cress.hi) elseif v > .8 then px(x, y, cress.deep) end end)
    px(mid, yb - h - 6, "#f2f2e2") px(mid - 3, yb - h - 3, "#f2f2e2")
  end
  return body
end
-- a smoked eel hanging head-down from a string, 3 wide x 13 tall
local function eel(x, y)
  vline(x + 1, y - 2, y, L.board.deep)
  F.sprite({ ".k.", ".e.", "eE.", "eEs", ".eE", ".eE", "eEs", "eE.", ".eE", ".eE", ".e.", "..e", "..s" }, x, y,
    { k = L.timber.deep, e = eelR.base, E = eelR.hi, s = eelR.shade })
end
-- a bundle of bulrush heads / dried cress hanging
local function rushes(x, y)
  vline(x + 1, y - 2, y, L.board.deep)
  F.sprite({ "c.c.", "cCcC", "CcCc", "gcgc", "g.g.", "g.g.", "gg.." }, x, y, { c = L.cattail.base, C = L.cattail.hi, g = L.reedGreen.base })
  hline(x, x + 3, y + 3, L.awnA.shade)
end
-- mallard: drake (green head, cream collar, chestnut breast, grey body) or hen (mottled brown). Facing left;
-- flip = right. swim = no feet, a ripple line. (x, yb) = feet / belly. ~12 px wide, 12 tall.
local function duck(x, yb, flip, swim, hen)
  local rows = {
    "...GG.......",
    "..GHGG......",
    "YYGGGG......",
    "..GGG.......",
    "...WW.......",
    "..CCCs......",
    ".CCcssssssTt",
    ".Ccsssssssst",
    "..sSSSSSSs..",
    "...SSSSS....",
  }
  if not swim then rows[#rows + 1] = "....o..o...." rows[#rows + 1] = "...oo.oo...." end
  if flip then for i, row in ipairs(rows) do rows[i] = row:reverse() end end
  local map
  if hen then
    map = { G = chest.base, H = chest.hi, Y = L.produce.shade, W = chest.base, C = chest.shade, c = chest.deep,
      s = chest.base, S = chest.shade, T = chest.deep, t = chest.shade, o = L.produce.base }
  else
    map = { G = mal.base, H = mal.hi, Y = L.marigold.base, W = L.awnB.hi, C = chest.base, c = chest.shade,
      s = L.heron.base, S = L.heron.shade, T = mal.deep, t = L.heron.hi, o = L.produce.base }
  end
  local m = F.sprite(rows, x - 6, yb - #rows + 1, map)
  if hen then m:each(function(xx, yy) if yy > yb - #rows + 5 and hash(xx, yy, 91) < .3 and c:get(xx, yy) == chest.base then px(xx, yy, chest.deep) end end) end
  if swim then for xx = x - 8, x + 8 do if hash(xx, yb, 92) < .7 then px(xx, yb + 1, (xx < x) and L.water.hi or F.SKYREF) end end end
  return m
end
local function duckling(x, y)
  local m = c:ellipse(x, y, 2, 1):add(rect(x - 2, y - 3, x - 1, y - 1))
  rimOf(m, L.timber) part(m, L.marigold, { nopop = true })
  px(x - 3, y - 2, L.produce.base) px(x + 1, y, chest.shade) hline(x - 3, x + 3, y + 2, L.water.hi)
end
-- a wicker eel trap (cone, rings), lying or standing; (x, y) = mouth centre, len to the right
local function eelTrap(x, y, len, r)
  r = r or withy
  local q1, q2 = x + floor(len * .3), x + floor(len * .7)
  local m = poly{ { x, y - 3 }, { q1, y - 4 }, { q2, y - 3 }, { x + len, y - 1 }, { x + len, y + 1 }, { q2, y + 3 }, { q1, y + 4 }, { x, y + 3 } }
  rimOf(m, r)
  weave(m, r, x, y)
  m:each(function(xx, yy)
    if (xx - x) % 5 == 2 then px(xx, yy, r.deep) elseif (xx - x) % 5 == 3 then px(xx, yy, r.hi) end
    if not m:has(xx, yy + 1) then px(xx, yy, r.shade) end
  end)
  vline(x, y - 3, y + 3, r.hi) vline(x + 1, y - 2, y + 2, r.edge) px(x, y, r.deep)
  px(x + len + 1, y, L.board.deep) px(x + len + 2, y + 1, L.board.deep) -- the tied tail
  return m
end

---------------------------------------------------------------- far quirks (plane 1): reed scarecrow + giant-cranberry barrow
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
  part(shirt, L.accent)
  shirt:each(function(x, y) if x % 4 == 0 or y % 4 == 1 then px(x, y, L.accent.shade) end end) -- plaid
  part(head, L.plaster) px(107, 73, t.deep) px(110, 73, t.deep) hline(107, 110, 76, t.shade)
  part(hat, L.awnA) part(lid, L.awnA) fill(spout, L.awnA.shade)
  px(102, 69, L.awnA.deep) px(101, 68, L.awnA.deep)
  -- reed stuffing bursting from cuffs and hem, a plume tuft on top of the lid
  for _, p in ipairs({ { 99, 82 }, { 118, 82 }, { 103, 93 }, { 106, 94 }, { 110, 93 }, { 113, 94 } }) do px(p[1], p[2], L.reed.hi) px(p[1], p[2] + 1, L.reed.shade) end
  px(108, 62, L.plume.base) px(109, 61, L.plume.hi)
  -- a reed bunting perched on the arm
  F.sprite({ ".kk", "kKbb", ".bBb", "..o." }, 112, 76, { k = "#4a4440", K = "#e6e0cc", b = "#b08a68", B = "#8a6a50", o = L.timber.deep })
end
scarecrow()
local function barrow()
  local t = L.timber
  local tray = poly{ { 160, 94 }, { 184, 94 }, { 180, 102 }, { 163, 102 } }
  local handles = line({ { 160, 96 }, { 152, 100 } }):add(line({ { 166, 102 }, { 164, 106 } }))
  local wheel = poly{ { 180, 100 }, { 186, 100 }, { 188, 103 }, { 186, 106 }, { 180, 106 }, { 178, 103 } }
  local berry = c:ellipse(172, 78, 20, 15)
  local stem = rect(171, 56, 172, 63)
  rimOf(union(tray, handles, wheel, berry, stem), t)
  part(handles, t, { nopop = true }) part(tray, L.board) part(wheel, L.stone, { nopop = true })
  F.planks(tray, L.board, 3, true, 41)
  -- the giant cranberry: oblong, waxy, mottled crimson with a pale blush, lenticel dots, a dry blossom star
  fill(berry, cran.base)
  berry:each(function(x, y)
    local dx, dy = (x - 172) / 20, (y - 78) / 15
    local d = dx * dx + dy * dy
    local l = -dx * .6 - dy * .8
    local mot = hash(x // 3, y // 2, 43)
    local h = cran.base
    if l > .45 then h = (mot < .5) and "#ee7a84" or cran.base
    elseif l > .05 then h = (mot < .3) and "#ee7a84" or cran.base
    elseif l < -.55 then h = cran.deep
    elseif l < -.1 then h = (mot < .5) and cran.shade or cran.base end
    if d > .8 and l < .1 then h = cran.deep end
    px(x, y, h)
    if hash(x, y, 44) < .035 and d < .85 then px(x, y, "#f4c0b0") end
  end)
  fill(c:ellipse(162, 70, 4, 2), "#ffc4ba") px(160, 69, "#fff0e0") px(161, 69, "#fff0e0")
  F.sprite({ ".k.", "kdk", ".k." }, 189, 79, { k = cran.edge, d = L.peat.base }, { rim = false })
  fill(stem, L.reedGreen.shade)
  F.sprite({ "..ll...", ".lLLl..", "lLl.....", }, 172, 50, { l = L.leaf.base, L = L.leaf.hi })
  F.sprite({ "...ll", "..lLl", "lLl.." }, 166, 52, { l = L.leaf.shade, L = L.leaf.base })
  -- cranberry runners spilling over the tray lip, a few normal-sized berries for scale
  hline(162, 182, 95, L.leaf.shade) hline(163, 181, 96, L.leaf.deep)
  for _, p in ipairs({ { 163, 94 }, { 168, 95 }, { 178, 94 }, { 182, 95 } }) do px(p[1], p[2], cran.base) px(p[1], p[2] - 1, cran.hi) end
end
barrow()

---------------------------------------------------------------- road's end: the Wild Trail, a withy arch into the reeds (plane 2)
F.depth(2)
F.tree(202, 128, 58, 2)
F.tree(280, 126, 52, 1)
local function trail()
  -- the view through: a boardwalk running off into tall reed beds and mist
  local open = rect(221, 74, 259, 124)
  local bw = poly{ { 233, 124 }, { 247, 124 }, { 242, 98 }, { 238, 98 } }
  F.reeds(221, 236, 122, 30, 131, { cattails = 2 })
  F.reeds(244, 259, 122, 32, 132, { cattails = 1, green = true })
  F.mist(222, 258, 94, 97, 133, .6)
  -- a far willow in the gap, misted
  F.willow(240, 98, 18, 134, L.farTree)
  fill(bw, L.board.base)
  bw:each(function(x, y)
    local p = floor(math.log(125 - y) * 9)
    if p % 3 == 0 then px(x, y, L.board.deep) elseif p % 3 == 1 then px(x, y, L.board.hi) end
    if x <= 235 - (124 - y) // 6 or x >= 245 + (124 - y) // 6 - 1 then px(x, y, L.board.shade) end
  end)
  vline(238, 98, 101, L.board.shade)
  -- posts, tarred, with a woven withy arch springing from their tops
  local pL, pR = rect(212, 72, 219, 124), rect(261, 72, 268, 124)
  local arch = HP.mask()
  for k = 0, 60 do
    local a = pi * k / 60
    local cx, cy = 240 - cos(a) * 24.5, 74 - sin(a) * 18
    arch:add(c:ellipse(floor(cx + .5), floor(cy + .5), 3, 3))
  end
  arch:cut(rect(220, 74, 260, 140)):add(rect(211, 70, 220, 76)):add(rect(260, 70, 269, 76))
  shadow(212, 268, 124, 8, 4)
  rimOf(union(pL, pR, arch), L.timber)
  -- willow-pole posts: round, lit left, bark rings, with withies spiralling up them
  union(pL, pR):each(function(x, y)
    local u = (x < 240) and (x - 212) or (x - 261)
    local h = u <= 1 and L.willowBark.hi or (u >= 6 and L.willowBark.deep or (u >= 4 and L.willowBark.shade or L.willowBark.base))
    if hash(x, y // 3, 137) < .08 then h = L.willowBark.deep end
    if (y + u * 2) % 9 == 0 or (y + u * 2) % 9 == 1 then h = (y + u * 2) % 9 == 0 and withy.hi or withy.shade end
    px(x, y, h)
  end)
  -- the arch: twisted willow withies, lit on top, with willow leaves and reed plumes tucked in
  arch:each(function(x, y)
    local w = (x * 2 + y * 3) % 7
    local h = (w < 2) and withy.hi or (w < 5 and withy.base or withy.shade)
    if w == 6 then h = withy.deep end
    if not arch:has(x, y - 1) then h = withy.hi elseif not arch:has(x, y + 1) then h = withy.deep end
    px(x, y, h)
  end)
  for k = 0, 16 do
    local a = pi * (k + .5) / 17
    local x, y = floor(240 - cos(a) * 25 + .5), floor(74 - sin(a) * 19 + .5)
    if k % 3 == 1 then px(x, y - 3, L.plume.hi) px(x + 1, y - 2, L.plume.base) px(x, y - 2, L.plume.base)
    else px(x - 1, y + 3, L.willow.base) px(x, y + 4, L.willow.shade) px(x - 1, y + 5, L.willow.base) px(x, y + 3, L.willow.hi) end
  end
  -- long fronds trailing from the arch shoulders
  for _, f in ipairs({ { 222, 64, 12 }, { 226, 60, 9 }, { 256, 61, 10 }, { 259, 64, 13 } }) do
    for k = 0, f[3] do px(f[1] + (k % 4 == 3 and 1 or 0), f[2] + 6 + k, k % 2 == 0 and L.willow.base or L.willow.shade) end
  end
  -- red ribbon bow on the crown, lantern under it, a painted heron on a board on the right post
  F.sprite({ "rr.rr", "rRkRr", ".r.r.", "r...r" }, 238, 52, { r = L.awnA.base, R = L.awnA.hi, k = L.awnA.deep })
  vline(240, 60, 66, L.timber.edge)
  lantern(240, 67)
  local bd = rect(262, 96, 269, 106) rimOf(bd, L.timber) part(bd, L.board)
  F.sprite({ "..w.", ".www", "w.w.", "..w." }, 264, 99, { w = L.heron.deep }, { rim = false })
  -- reed tufts at the post feet
  F.reeds(208, 214, 124, 9, 135) F.reeds(266, 273, 124, 10, 136, { green = true })
end
trail()

---------------------------------------------------------------- back left: two fen cottages on a low deck (plane 1)
F.depth(1)
F.tree(86, 126, 42, 2)
F.tree(10, 128, 36, 1)
do
  local dk = rect(14, 128, 82, 131)
  F.stilts({ 18, 34, 50, 66, 78 }, 131, 135, 134)
  F.boardwalk(dk, true, 37)
  local top, cx, wall = F.building{ x0 = 19, x1 = 45, yb = 127, wh = 28, rh = 22, wall = L.plaster, roof = L.roof, noShadow = true }
  window(24, 104, 30, 110, L.timber) door(34, 112, 41, 126, L.accent)
  local top2, cx2, wall2, roof2 = F.building{ x0 = 52, x1 = 75, yb = 127, wh = 36, rh = 26, wall = TAR, roof = L.roof2, chimney = true, noFrame = true, noShadow = true }
  F.planks(wall2:copy():clip(rect(52, top2 + 2, 75, 127)), TAR, 3, false, 36)
  part(union(rect(52, top2, 53, 127), rect(74, top2, 75, 127)), L.board, { nopop = true, noshade = true })
  F.moss(roof2, .1, 37)
  window(57, 96, 63, 102, L.board) window(57, 110, 62, 116, L.board)
  door(66, 110, 72, 126, L.awnA)
  -- an eel trap and a pot of marigolds on the deck, washing on a line, peat smoke
  eelTrap(46, 124, 6)
  local pot = rect(78, 122, 81, 127) rimOf(pot, L.timber) part(pot, L.soil, { nopop = true })
  px(78, 121, L.marigold.base) px(80, 120, L.marigold.hi) px(81, 121, L.reedGreen.base)
  F.smoke(66, 72, 6, .6, 2)
end

---------------------------------------------------------------- back right: the marsh channel with punts (plane 2)
F.depth(2)
local chan = poly{ { 262, 140 }, { 470, 137 }, { 470, 151 }, { 268, 152 } }
do
  rimOf(chan, L.peat)
  local bank = chan:grow(1):cut(chan)
  bank:each(function(x, y) local v = hash(x, y, 140) px(x, y, v < .5 and L.peat.base or L.sedgeGround.shade) end)
  F.water(chan, L.water, { step = 3 })
  -- reflections of the notice board and rest house, and reeds at the channel mouth
  for y = 141, 149, 2 do hline(290, 336, y, L.water.shade) hline(362, 452, y, L.water.shade) end
  F.reeds(262, 276, 141, 9, 141, { green = true })
end

---------------------------------------------------------------- back right: notice board under a reed hood (plane 2)
F.depth(2)
local function notice()
  local T = L.timber
  local roof = poly{ { 280, 62 }, { 313, 44 }, { 346, 62 }, { 346, 65 }, { 280, 65 } }
  local posts = rect(289, 65, 294, 138):add(rect(332, 65, 337, 138))
  local board = rect(287, 67, 339, 114)
  local bar = rect(286, 120, 340, 123)
  shadow(290, 338, 138, 8, 3)
  rimOf(union(roof, posts, board, bar), T)
  tarPosts(posts)
  part(board, L.board, { band = 2 })
  F.planks(board, L.board, 6, true, 61)
  hline(287, 339, 67, TAR.base) hline(287, 339, 114, TAR.base) vline(287, 67, 114, TAR.base) vline(339, 67, 114, TAR.base)
  part(bar, TAR, { nopop = true }) hline(286, 340, 120, TAR.hi)
  part(roof, L.roof, { sep = true }) F.thatch(roof, L.roof, 44, 313)
  -- sedge ridge cap along the two top edges
  line({ { 281, 62 }, { 313, 45 } }):each(function(x, y) for d = 0, 2 do px(x, y + d, d == 2 and L.roof2.deep or L.roof2.base) end end)
  line({ { 313, 45 }, { 345, 62 } }):each(function(x, y) for d = 0, 2 do px(x, y + d, d == 2 and L.roof2.deep or L.roof2.shade) end end)
  hline(280, 346, 65, L.roof.deep)
  -- the carved heron on the peak
  F.sprite({ "..BBk....", ".BbBBYY..", "..bb.....", "..bS.....", "..bbS....", ".bbbbS...", "bbbbbbSS.", ".bbbbSSS.", "...S.S...", "...S.S..." }, 309, 34,
    { B = L.board.hi, b = L.board.base, S = L.board.shade, k = L.timber.edge, Y = L.gold.base })
  local notes = { { 291, 71, 302, 84, L.awnB }, { 306, 72, 320, 82, L.plaster }, { 324, 70, 335, 86, L.awnB },
                  { 292, 89, 305, 102, L.accent }, { 309, 87, 321, 106, egg }, { 325, 91, 335, 101, L.gold },
                  { 296, 105, 306, 112, L.awnA }, { 323, 104, 334, 112, L.plaster } }
  for _, n in ipairs(notes) do
    local m = rect(n[1], n[2], n[3], n[4])
    part(m, n[5], { nopop = true })
    c:edgeIn(m, n[5].deep)
    for y = n[2] + 3, n[4] - 2, 3 do hline(n[1] + 2, n[3] - 2 - (y % 4), y, n[5].shade) end
    px((n[1] + n[3]) // 2, n[2] + 1, L.awnA.base)
  end
  -- a drawn duck on one notice, a channel map with a route on another, an eel sketch, a pinned feather
  F.sprite({ ".gg..", "ygg..", ".ssss", "..ss." }, 294, 74, { g = mal.base, y = L.marigold.base, s = L.heron.shade }, { rim = false })
  line({ { 311, 90 }, { 316, 95 }, { 312, 100 }, { 317, 104 } }):each(function(x, y) px(x, y, L.water.shade) end)
  px(316, 95, L.awnA.base) px(312, 100, L.awnA.base)
  line({ { 326, 95 }, { 329, 93 }, { 331, 96 }, { 334, 94 } }):each(function(x, y) px(x, y, eelR.shade) end)
  line({ { 327, 106 }, { 331, 111 } }):each(function(x, y) px(x, y, L.goose.shade) end)
  -- lantern on the right post, paste bucket, a goose at the foot
  hline(337, 340, 70, T.deep) vline(340, 70, 72, T.deep)
  lantern(340, 73)
  local b = poly{ { 298, 129 }, { 306, 129 }, { 305, 136 }, { 299, 136 } } rimOf(b, L.accent) part(b, L.accent, { nopop = true })
  vline(303, 123, 129, T.hi)
  F.goose(320, 136, true)
end
notice()

---------------------------------------------------------------- back right: the rest house on a deck over the channel (plane 2)
local function rest()
  F.stilts({ 356, 372, 390, 410, 428, 446, 458 }, 136, 149, 144)
  local dk = rect(352, 131, 462, 136)
  F.boardwalk(dk, true, 63)
  hline(352, 462, 136, L.board.deep)
  local top, cx, wall, roofM = F.building{ x0 = 360, x1 = 456, yb = 130, wh = 40, rh = 28, wall = L.wall2, roof = L.roof, chimney = true, noFrame = true, noShadow = true }
  F.planks(wall:copy():clip(rect(360, top + 2, 456, 130)), L.wall2, 3, false, 64)
  part(union(rect(360, top, 362, 130), rect(454, top, 456, 130)), L.board, { nopop = true, noshade = true })
  F.moss(roofM, .05, 63)
  F.smoke(447, 56, 5, .5, 2)
  -- sedge-thatched porch roof on tarred posts
  local porch = poly{ { 356, 100 }, { 460, 100 }, { 463, 107 }, { 353, 107 } }
  rimOf(porch, L.roof2) part(porch, L.roof2, { sep = true }) F.thatch(porch, L.roof2, 100)
  hline(356, 460, 100, L.roof2.hi)
  tarPosts(rect(361, 108, 362, 130):add(rect(454, 108, 455, 130)))
  window(366, 91, 378, 96, L.board) window(438, 91, 450, 96, L.board)
  window(370, 111, 380, 116, L.board) window(436, 111, 446, 116, L.board)
  door(400, 108, 416, 130, L.awnA)
  local sign = rect(398, 81, 418, 87) rimOf(sign, L.timber) part(sign, L.board)
  F.sprite({ ".ccc.", "cccc.", "cccc.", ".cc.." }, 401, 82, { c = L.awnB.shade }, { rim = false }) -- a teacup
  px(405, 83, L.awnB.deep)
  F.sprite({ ".gg..", "ygg..", ".ssss" }, 409, 82, { g = mal.base, y = L.marigold.base, s = L.heron.shade }, { rim = false }) -- a duck: the Mallard's Rest
  lantern(421, 109)
  -- bench with patchwork quilt
  local bench = rect(364, 124, 396, 126):add(rect(365, 127, 367, 130)):add(rect(393, 127, 395, 130)):add(rect(364, 119, 366, 124))
  local quilt = rect(370, 120, 390, 129)
  rimOf(union(bench, quilt), L.timber)
  part(bench, L.timber, { nopop = true })
  local qc = { L.awnA.base, L.awnB.base, L.accent.base, L.roof.hi, L.lav.base, cran.shade }
  quilt:each(function(x, y) px(x, y, qc[((x - 370) // 5 + (y - 120) // 4) % 6 + 1]) end)
  for x = 370, 390, 5 do vline(x, 120, 129, L.awnB.deep) end
  hline(370, 390, 129, L.awnA.deep)
  -- tea table + teapot + cups
  local tbl = rect(424, 123, 444, 125):add(rect(426, 126, 427, 130)):add(rect(441, 126, 442, 130))
  local pot = poly{ { 429, 116 }, { 438, 116 }, { 440, 122 }, { 427, 122 } }
  local lid = rect(432, 114, 435, 115)
  rimOf(union(tbl, pot, lid), L.timber)
  part(tbl, L.timber, { nopop = true }) part(pot, L.accent) part(lid, L.accent, { nopop = true })
  line({ { 440, 118 }, { 443, 115 } }):each(function(x, y) px(x, y, L.accent.deep) end)
  px(426, 118, L.accent.deep) px(425, 119, L.accent.deep)
  hline(429, 438, 119, L.awnB.base)
  fill(rect(441, 121, 443, 122), L.plaster.hi)
  -- marsh marigold window boxes
  for _, x in ipairs({ 365, 437 }) do
    hline(x, x + 14, 99, L.timber.base)
    for i = 0, 14, 2 do px(x + i, 98, (i % 4 == 0) and L.marigold.base or L.reedGreen.base) px(x + i + 1, 97, L.reedGreen.hi) end
  end
  -- a mooring ring with a punt tied under the deck
  F.punt(418, 452, 149, L.timber)
  hline(424, 446, 144, L.board.shade)
  duck(436, 144, true)
end
rest()

---------------------------------------------------------------- channel punts: a floating cranberry stall and a gnome poling
F.depth(2)
do
  F.punt(296, 336, 150, L.timber)
  basket(302, 314, 146, 3, "cran", 142) basket(316, 328, 146, 3, "cran", 143)
  F.punt(338, 356, 149, TAR)
  eelTrap(340, 144, 12)
  F.gnome(348, 145, { small = true, hat = L.awnA, coat = L.leaf, arm = "up" })
  line({ { 355, 125 }, { 349, 151 } }):each(function(x, y) px(x, y, L.board.base) end)
end

---------------------------------------------------------------- road side: pond-snail mailbox, signpost (plane 2/3)
local function snail()
  local X = 4 -- shifted right of the well roof so the snail's head reads
  local post = rect(208 + X, 137, 209 + X, 146)
  local foot = rect(197 + X, 134, 220 + X, 137):add(rect(197 + X, 128, 201 + X, 134))
  local body = c:ellipse(211 + X, 129, 8, 6)
  local spire = poly{ { 205 + X, 126 }, { 212 + X, 120 }, { 221 + X, 107 }, { 223 + X, 108 }, { 220 + X, 126 } }
  local shell = union(body, spire)
  local stalks = rect(197 + X, 124, 197 + X, 127):add(rect(200 + X, 124, 200 + X, 127))
  rimOf(union(post, shell, foot, stalks), L.timber)
  part(post, L.timber, { nopop = true })
  part(foot, L.goose, { nopop = true }) hline(197 + X, 220 + X, 134, L.goose.hi)
  px(198 + X, 130, L.timber.edge) -- eye
  fill(stalks, L.goose.shade) px(197 + X, 124, L.timber.edge) px(200 + X, 124, L.timber.edge)
  part(shell, amber)
  -- whorl bands round the spire and the body whorl, lit upper left
  for _, s2 in ipairs({ { { 204, 127 }, { 219, 122 } }, { { 211, 121 }, { 221, 116 } }, { { 216, 115 }, { 222, 111 } } }) do
    line({ { s2[1][1] + X, s2[1][2] }, { s2[2][1] + X, s2[2][2] } }):each(function(x, y) if shell:has(x, y) then px(x, y, amber.deep) if shell:has(x, y - 1) then px(x, y - 1, amber.hi) end end end)
  end
  body:each(function(x, y) if (x - 211 - X) + (y - 129) * 2 > 9 then px(x, y, amber.shade) end end)
  hline(206 + X, 215 + X, 132, L.awnB.base) hline(206 + X, 215 + X, 133, L.timber.deep) -- letter slot
  fill(rect(221 + X, 126, 223 + X, 129), L.awnA.base) vline(221 + X, 126, 136, L.timber.deep)
  F.lily(212, 146, false)
end
F.depth(3)
snail()
local function signpost()
  local post = rect(442, 152, 445, 176)
  local b1 = poly{ { 430, 155 }, { 434, 151 }, { 454, 151 }, { 458, 155 }, { 454, 159 }, { 434, 159 } }
  local b2 = poly{ { 432, 165 }, { 436, 162 }, { 452, 162 }, { 456, 165 }, { 452, 168 }, { 436, 168 } }
  rimOf(union(post, b1, b2), L.timber)
  tarPosts(post)
  part(b1, L.board) part(b2, egg)
  hline(436, 452, 155, L.board.deep) hline(438, 450, 165, egg.deep)
  F.moss(post, .2, 65)
  F.reeds(436, 450, 177, 8, 66, { green = true })
end

F.depth(3)
signpost()
-- stacked goods on the left verge: crates of duck eggs and cranberries, sacks, a barrel, a stack of eel traps
F.shadow(196, 222, 180, 8, 3)
F.crate(196, 180, 12, 9, egg)
F.crate(209, 180, 11, 9, cran)
F.crate(201, 170, 12, 8, cress)
F.sack(222, 182, L.plaster, 4)
F.shadow(198, 220, 206, 6, 2)
F.barrel(205, 204, TAR, 11)
for k = 0, 3 do px(201 + k * 2, 193, cran.base) px(202 + k * 2, 193, cran.hi) end
eelTrap(211, 202, 12)
eelTrap(212, 196, 10)
-- right verge by the channel: bundles of cut reed for thatching, for sale
F.shadow(256, 280, 162, 6, 2)
for k = 0, 2 do
  local m = rect(256 + k * 7, 150, 261 + k * 7, 161)
  rimOf(m, L.reed) part(m, L.reed, { nopop = true })
  m:each(function(x, y) if (x + k) % 2 == 0 then px(x, y, L.reed.hi) end end)
  hline(256 + k * 7, 261 + k * 7, 155, L.timber.deep)
  px(257 + k * 7, 149, L.plume.base) px(259 + k * 7, 148, L.plume.hi) px(260 + k * 7, 149, L.plume.shade)
end
F.barrel(282, 164, L.timber, 10)
for k = 0, 3 do px(279 + k * 2, 153, egg.base) px(280 + k * 2, 153, egg.hi) end

---------------------------------------------------------------- the reed-stook house (plane 3, replaces the haystack house)
local function stookHouse()
  local m = poly{ { 420, 224 }, { 425, 212 }, { 430, 198 }, { 437, 188 }, { 443, 182 }, { 449, 188 }, { 456, 198 }, { 461, 212 }, { 466, 224 } }
  local tuft = poly{ { 438, 184 }, { 441, 174 }, { 443, 171 }, { 446, 174 }, { 448, 184 } }
  local pipe = rect(452, 182, 454, 192)
  shadow(426, 462, 224, 8, 3)
  rimOf(union(m, tuft, pipe), L.reed)
  part(m, L.reed)
  m:each(function(x, y)
    local k = (x - 443) * 8 // math.max(1, (y - 176))
    if (x * 2 + k) % 4 == 0 then px(x, y, L.reed.shade) elseif (x * 2 + k) % 4 == 1 and x < 443 then px(x, y, L.reed.hi) end
    if x > 452 and hash(x, y, 66) < .3 then px(x, y, L.reed.shade) end
  end)
  -- two hazel bands binding the stook
  for _, by in ipairs({ { 196, 431, 455 }, { 210, 425, 461 } }) do hline(by[2], by[3], by[1], L.timber.base) hline(by[2] + 1, by[3] - 1, by[1] + 1, L.timber.deep) end
  part(tuft, L.plume)
  tuft:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.plume.hi) elseif (x + y) % 3 == 1 and x > 443 then px(x, y, L.plume.shade) end end)
  part(pipe, L.iron, { nopop = true }) hline(451, 455, 182, L.iron.deep)
  door(437, 208, 447, 223, L.accent, true)
  local w = c:ellipse(454, 202, 2, 2) rimOf(w, L.timber) fill(w, L.glow.base) px(453, 201, L.glow.hi)
  F.smoke(453, 168, 3, .4, 1)
  F.reeds(414, 422, 224, 10, 67, { cattails = 1 }) F.reeds(463, 470, 224, 9, 68, { green = true })
  px(426, 224, L.marigold.base) px(428, 223, L.marigold.hi)
end
stookHouse()

---------------------------------------------------------------- left: the wishing well, a hooped cistern on a boardwalk (plane 3)
local function well()
  local T, RR = L.timber, L.roof
  local plat = rect(84, 203, 202, 210)
  local roofOuter = poly{ { 143, 92 }, { 196, 120 }, { 196, 126 }, { 90, 126 }, { 90, 120 } }
  local gable = poly{ { 143, 104 }, { 178, 121 }, { 108, 121 } }
  local roofM = roofOuter:copy():cut(gable)
  local postL, postR = rect(103, 126, 110, 156), rect(176, 126, 183, 156)
  local lipTop = poly{ { 98, 147 }, { 188, 147 }, { 194, 156 }, { 92, 156 } }
  local drum = poly{ { 94, 156 }, { 192, 156 }, { 191, 198 }, { 187, 204 }, { 99, 204 }, { 95, 198 } }
  local axle = rect(110, 130, 176, 133)
  local crank = rect(184, 130, 190, 133):add(rect(188, 133, 191, 143))
  local rope = rect(142, 134, 143, 140)
  local bucket = poly{ { 134, 141 }, { 152, 141 }, { 150, 153 }, { 136, 153 } }
  -- the boardwalk platform it stands on, with stilts into a sliver of water
  local wpool = poly{ { 80, 210 }, { 206, 210 }, { 204, 216 }, { 84, 216 } }
  rimOf(wpool, L.peat) F.water(wpool, L.water, { dark = true })
  F.stilts({ 88, 110, 134, 158, 182, 198 }, 210, 216, 214)
  F.boardwalk(plat, false, 70)
  hline(84, 202, 210, L.board.deep)
  shadow(98, 194, 205, 10, 3)
  rimOf(union(roofOuter, postL, postR, lipTop, drum, crank, axle, bucket), T)
  -- the drum: tarred staves, iron hoops, lit left, damp moss at the foot
  part(drum, oak)
  drum:each(function(x, y)
    local k = (x - 94) % 7
    if k == 0 then px(x, y, oak.deep) elseif k == 1 then px(x, y, oak.hi)
    elseif k == 5 then px(x, y, oak.shade)
    elseif hash(x, y // 4, 170) < .1 then px(x, y, oak.shade) end
    if x < 104 and k ~= 0 then px(x, y, k < 4 and oak.hi or oak.base) end
    if x > 182 and k ~= 0 then px(x, y, k < 3 and oak.base or oak.shade) end
    if y > 196 and k ~= 0 and hash(x, y, 171) < .5 then px(x, y, oak.shade) end
  end)
  for _, hy in ipairs({ 160, 180, 199 }) do
    hline(95, 191, hy, L.iron.base) hline(95, 191, hy + 1, L.iron.deep) hline(95, 104, hy, L.iron.hi)
    for x = 98, 190, 14 do px(x, hy, L.iron.hi) end
  end
  F.moss(drum:copy():clip(rect(90, 194, 196, 204)), .07, 71)
  -- a wishing wreath of reed and marsh marigolds hung on the drum, a little painted plaque with a coin
  local wr = c:ellipse(143, 172, 8, 7):cut(c:ellipse(143, 172, 4, 3))
  rimOf(wr, L.reed) part(wr, L.reed, { nopop = true })
  wr:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.reed.shade) elseif (x * 2 + y) % 5 == 0 then px(x, y, L.reedGreen.base) end end)
  for k = 0, 7 do local a = k * pi / 4 + .3 local x, y = floor(143 + cos(a) * 6 + .5), floor(172 + sin(a) * 5 + .5) px(x, y, L.marigold.base) px(x - 1, y - 1, L.marigold.hi) end
  F.sprite({ "rr.rr", ".rrr.", "..r.." }, 141, 182, { r = L.awnA.base })
  local pq = rect(110, 186, 124, 194) rimOf(pq, L.timber) part(pq, L.board)
  fill(c:ellipse(117, 190, 2, 2), L.gold.base) px(116, 189, L.gold.hi) px(118, 191, L.gold.deep)
  lipTop:each(function(x, y) end)
  part(lipTop, L.board, { sep = true }) F.planks(lipTop, L.board, 5, true, 72)
  local opening = poly{ { 106, 149 }, { 180, 149 }, { 184, 154 }, { 102, 154 } }
  fill(opening, L.water.deep) hline(110, 178, 149, oak.edge) hline(118, 128, 152, L.water.shade) hline(156, 170, 151, F.SKYREF)
  px(165, 152, L.glow.hi) px(166, 152, L.glow.base) px(124, 151, L.gold.hi) -- coins
  F.lily(150, 152, false, "white")
  tarPosts(union(postL, postR))
  part(axle, T, { nopop = true }) hline(110, 176, 130, T.hi)
  for x = 136, 150, 3 do vline(x, 131, 133, L.board.base) end
  fill(rope, L.board.base) part(crank, T, { nopop = true }) fill(rect(188, 140, 191, 143), L.awnA.base)
  part(bucket, L.reed, { nopop = true }) weave(bucket, L.reed, 134, 141)
  hline(135, 151, 141, L.reed.hi) hline(136, 150, 153, L.reed.deep)
  line({ { 135, 141 }, { 143, 137 }, { 151, 141 } }):each(function(x, y) px(x, y, T.deep) end)
  hline(137, 149, 142, L.water.hi)
  -- reed-thatched hood, sedge ridge, wattle gable
  part(roofM, RR, { sep = true }) F.thatch(roofM, RR, 92, 143)
  line({ { 91, 120 }, { 143, 93 } }):each(function(x, y) if roofM:has(x, y) then px(x, y, RR.hi) end end)
  line({ { 92, 118 }, { 143, 92 } }):each(function(x, y) for d = 0, 2 do if roofM:has(x, y + d) then px(x, y + d, d == 2 and L.roof2.deep or L.roof2.base) end end end)
  line({ { 143, 92 }, { 194, 118 } }):each(function(x, y) for d = 0, 2 do if roofM:has(x, y + d) then px(x, y + d, d == 2 and L.roof2.deep or L.roof2.shade) end end end)
  hline(90, 196, 126, RR.edge) hline(91, 195, 125, RR.deep)
  part(gable, L.reed, { nopop = true }) weave(gable, L.reed, 108, 104)
  vline(143, 106, 121, T.base)
  line({ { 143, 112 }, { 130, 120 } }):each(function(x, y) px(x, y, T.base) end)
  line({ { 143, 112 }, { 156, 120 } }):each(function(x, y) px(x, y, T.base) end)
  -- a bulrush finial
  F.sprite({ ".c.", "cCc", "cCc", "cCc", ".g.", ".g." }, 142, 84, { c = L.cattail.base, C = L.cattail.hi, g = L.reedGreen.shade })
  -- a frog on the lip, marigolds and reeds at the foot, coins glinting
  F.frog(100, 147, false)
  F.reeds(80, 92, 203, 16, 73, { cattails = 2, green = true })
  F.reeds(194, 204, 203, 12, 74)
  for _, p in ipairs({ { 100, 205 }, { 112, 206 }, { 172, 206 }, { 186, 205 } }) do F.sedge(p[1], p[2], 5) px(p[1] - 1, p[2] - 4, L.marigold.base) px(p[1] + 1, p[2] - 5, L.marigold.hi) end
  c:sparkle(176, 160)
end
well()

---------------------------------------------------------------- left: the Seed Swap hut on a deck (plane 3)
local function seed()
  F.stilts({ 18, 36, 56, 74 }, 209, 213, 212)
  local dk = rect(14, 205, 80, 209)
  F.boardwalk(dk, true, 75)
  local top, cx, wall, roofM = F.building{ x0 = 19, x1 = 75, yb = 204, wh = 38, rh = 18, wall = TAR, roof = L.roof, noFrame = true, noAttic = true, noShadow = true }
  F.planks(wall:copy():clip(rect(19, top + 2, 75, 204)), TAR, 3, false, 76)
  part(union(rect(19, top, 20, 204), rect(74, top, 75, 204)), L.board, { nopop = true, noshade = true })
  -- bulrush finial
  F.sprite({ ".c.", "cCc", "cCc", "cCc", ".g.", ".g." }, cx - 1, top - 24, { c = L.cattail.base, C = L.cattail.hi, g = L.reedGreen.shade })
  -- shop window: seed packets, jars of seeds (wild rice, iris pods, marigold, sedge)
  fill(rect(23, 177, 71, 193), L.timber.deep) fill(rect(24, 178, 70, 192), L.glow.shade)
  fill(rect(24, 178, 70, 181), L.glow.base)
  for i = 0, 7 do
    local x = 25 + i * 6
    local rr = ({ L.awnA, L.awnB, L.accent, iris, L.leaf, cran, L.marigold, L.wall2 })[i + 1]
    local pk = rect(x, 180 + (i % 2), x + 4, 186 + (i % 2)) part(pk, rr, { nopop = true }) px(x + 1, 181 + (i % 2), rr.hi)
    hline(x, x + 4, 183 + (i % 2), rr.deep)
  end
  hline(24, 70, 187, L.timber.base)
  for i = 0, 4 do
    local x = 26 + i * 9
    fill(rect(x, 188, x + 5, 192), L.water.hi) hline(x, x + 5, 188, L.timber.base)
    local sr = ({ L.reed, L.soil, L.marigold, L.cattail, L.peat })[i + 1]
    fill(rect(x + 1, 190, x + 4, 192), sr.base) px(x + 1, 190, sr.hi) px(x + 4, 192, sr.deep)
  end
  -- striped awning
  local aw = poly{ { 18, 176 }, { 22, 168 }, { 72, 168 }, { 76, 176 } }
  for x = 18, 76, 4 do aw:add(poly{ { x, 176 }, { x + 4, 176 }, { x + 2, 179 } }) end
  aw:clip(rect(17, 164, 77, 180))
  rimOf(aw, L.awnA)
  stripes(aw, 18, 4, L.awnA, L.awnB)
  hline(22, 72, 168, L.awnB.hi)
  -- hanging sign: an iris seed pod
  vline(30, 160, 162, L.timber.edge) vline(40, 160, 162, L.timber.edge)
  local sg = rect(28, 152, 42, 159) rimOf(sg, L.timber) part(sg, L.board)
  F.sprite({ "..p..", ".pPp.", ".pPp.", "..p..", "..g.." }, 33, 153, { p = L.reedGreen.shade, P = L.reedGreen.base, g = L.timber.shade }, { rim = false })
  door(26, 194, 32, 204, L.awnA)
  -- crate of potted flag irises and marsh marigolds for swapping
  local crate = rect(46, 196, 72, 204) rimOf(crate, L.timber) part(crate, L.board) hline(46, 72, 200, L.board.deep)
  for i = 0, 4 do
    local x = 49 + i * 5
    vline(x, 189, 195, L.reedGreen.base) vline(x + 1, 191, 195, L.reedGreen.shade) px(x - 1, 192, L.reedGreen.hi)
    if i % 2 == 0 then px(x, 188, iris.base) px(x - 1, 189, iris.hi) px(x + 1, 189, iris.shade)
    else px(x, 189, L.marigold.base) px(x + 1, 188, L.marigold.hi) end
  end
  -- seed sacks by the door
  F.sack(40, 204, L.plaster, 3)
end
seed()
F.sedge(10, 214, 6) F.sedge(84, 214, 5)
F.reeds(4, 14, 214, 14, 77, { cattails = 1 })

---------------------------------------------------------------- right hero: the trader stall on stilts over a pool (plane 3)
local function stall()
  local T = L.timber
  -- the pool under the stall, with stilts and a moored punt
  local spool = poly{ { 290, 214 }, { 414, 214 }, { 416, 222 }, { 398, 228 }, { 378, 236 }, { 300, 236 }, { 292, 228 } }
  rimOf(spool, L.peat)
  local sbank = spool:grow(2):cut(spool)
  sbank:each(function(x, y) if y > 214 then local v = hash(x, y, 150) px(x, y, v < .4 and L.peat.base or (v < .65 and L.peat.hi or L.sedgeGround.base)) end end)
  F.water(spool, L.water)
  F.water(spool:copy():clip(rect(290, 214, 416, 221)), L.water, { dark = true })
  F.stilts({ 296, 318, 342, 366, 390, 404 }, 212, 228, 223)
  local roof = poly{ { 288, 168 }, { 300, 151 }, { 400, 151 }, { 412, 168 } }
  local val = rect(289, 167, 411, 173)
  for x = 289, 405, 8 do val:add(poly{ { x, 173 }, { x + 8, 173 }, { x + 4, 178 } }) end
  val:clip(rect(289, 166, 411, 178))
  local posts = rect(295, 178, 299, 212):add(rect(401, 178, 405, 212))
  local back = rect(300, 178, 400, 195)
  local ctop = poly{ { 299, 194 }, { 401, 194 }, { 404, 199 }, { 296, 199 } }
  local cfront = rect(296, 199, 404, 208)
  local deck = rect(288, 208, 412, 212)
  rimOf(union(roof, val, posts, back, ctop, cfront), T)
  tarPosts(posts)
  -- back wall of tarred boards, two shelves of jars (cranberry jelly, pickled eggs, honey, eel in jelly)
  fill(back, TAR.deep)
  F.planks(rect(301, 179, 399, 194), TAR, 3, true, 151)
  hline(301, 399, 186, TAR.edge) hline(301, 399, 193, TAR.edge)
  for i = 0, 15 do
    local x = 303 + i * 6
    local rr = ({ cran, L.gold, egg, cran, cress, eelR })[i % 6 + 1]
    if x < 340 or x > 372 then
      local m = rect(x, 180, x + 3, 185) rimOf(m, L.timber)
      fill(m, rr.base) vline(x, 181, 185, rr.hi) vline(x + 3, 181, 185, rr.shade) hline(x, x + 3, 185, rr.deep)
      hline(x, x + 3, 180, (i % 3 == 0 and L.awnA or L.awnB).base) px(x + 1, 182, "#f6f2d8")
      if i % 2 == 0 then
        local m2 = rect(x + 1, 187, x + 4, 192) rimOf(m2, L.timber)
        local r2 = ({ cran, L.marigold, egg })[i % 3 + 1]
        fill(m2, r2.base) vline(x + 1, 188, 192, r2.hi) hline(x + 1, x + 4, 192, r2.deep) hline(x + 1, x + 4, 187, L.awnB.base)
      end
    end
  end
  -- the stallkeeper, behind the counter
  F.gnome(362, 202, { hat = L.awnA, coat = L.wall2, arm = "out", noShadow = true })
  -- reed thatch roof with sedge ridge, red/cream valance
  part(roof, L.roof, { sep = true }) F.thatch(roof, L.roof, 151, 350)
  hline(300, 400, 151, L.roof2.base) hline(300, 400, 152, L.roof2.base) hline(300, 400, 153, L.roof2.deep)
  for x = 300, 400, 6 do px(x, 152, L.timber.hi) end
  line({ { 289, 167 }, { 300, 152 } }):each(function(x, y) if roof:has(x, y) then px(x, y, L.roof.hi) end end)
  stripes(val, 289, 8, L.awnA, L.awnB)
  hline(289, 411, 167, L.awnA.deep)
  -- sign on the ridge with the wares painted on: eel, cranberry, egg, duck, basket
  local sign = rect(326, 142, 374, 150)
  rimOf(sign, T) part(sign, L.board) hline(327, 373, 150, L.board.deep)
  F.sprite({ "e..ee", ".eee.", "....." }, 329, 145, { e = eelR.shade }, { rim = false })
  F.sprite({ ".r.", "rrr", ".r." }, 336, 145, { r = cran.base }, { rim = false })
  F.sprite({ ".e.", "eee", "eee" }, 342, 144, { e = egg.shade }, { rim = false })
  F.sprite({ ".gg..", "ygg..", ".ssss", "..ss." }, 348, 144, { g = mal.base, y = L.marigold.base, s = L.heron.shade }, { rim = false })
  F.sprite({ "bbbbb", ".bbb." }, 356, 146, { b = L.reed.shade }, { rim = false })
  F.sprite({ "c.c", "ccc" }, 364, 146, { c = cress.shade }, { rim = false })
  vline(334, 151, 151, T.deep) vline(366, 151, 151, T.deep)
  -- hanging under the valance: lanterns, smoked eels, bulrush bundles
  lantern(304, 180, 1)
  lantern(396, 180, 1)
  hline(310, 336, 179, L.board.deep)
  for k = 0, 4 do eel(310 + k * 5, 181) end
  for k = 0, 2 do rushes(372 + k * 6, 181) end
  -- counter: woven reed front panels between tarred rails, a silver plank top
  part(cfront, L.reed, { nopop = true })
  weave(cfront, L.reed, 296, 199)
  for x = 296, 404, 27 do vline(x, 200, 208, TAR.base) vline(x + 1, 200, 208, TAR.deep) end
  hline(296, 404, 199, TAR.base)
  part(ctop, L.board) hline(299, 401, 194, L.board.hi)
  -- the deck the stall stands on
  F.boardwalk(deck, true, 152)
  hline(288, 412, 212, L.board.deep)
  -- goods on the counter
  basket(300, 318, 198, 5, "cran", 82)
  basket(320, 338, 198, 5, "egg", 83)
  basket(374, 392, 198, 5, "eel", 84)
  for k = 0, 1 do
    local x = 394 + k * 5 local m = rect(x, 193, x + 3, 198) rimOf(m, L.timber)
    fill(m, cran.base) vline(x, 194, 198, cran.hi) hline(x, x + 3, 193, L.awnB.base)
  end
  -- watercress bunches on a slate
  basket(341, 352, 198, 3, "cress", 86)
  -- QUIRK: a mallard drake in a red gnome hat sitting on the egg basket
  F.sprite({
    ".......Rr..",
    "......RRr..",
    ".....RRRr..",
    "....RRRRRr.",
    "...hhhhhhh.",
    "...GGHGG...",
    ".YYGkGGG...",
    "YYYGGGG....",
    "....GGG....",
    "....WWW....",
    "...CCCCss..",
    "..CCCcsssst",
    "..CCcsssssT",
    "...csSSSSST",
  }, 324, 179, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, G = mal.base, H = mal.hi, k = L.timber.edge,
    Y = L.marigold.base, W = L.awnB.hi, C = chest.base, c = chest.shade, s = L.heron.base, S = L.heron.shade,
    t = L.heron.hi, T = mal.deep })
  px(327, 182, L.awnA.hi) px(332, 180, L.awnA.hi) -- hat lights
  -- a punt moored in front, loaded with eel traps and a crate of live ducks
  F.punt(332, 380, 234, TAR)
  eelTrap(338, 226, 12) eelTrap(351, 227, 9)
  local cage = rect(362, 221, 376, 229)
  rimOf(cage, L.timber) fill(cage, L.timber.deep)
  cage:each(function(x, y) if (x - 362) % 3 == 0 or y == 221 or y == 229 then px(x, y, L.reed.base) end end)
  px(366, 224, mal.base) px(367, 224, mal.hi) px(365, 225, L.marigold.base) px(372, 225, chest.base) px(373, 224, chest.hi) px(371, 226, L.produce.base)
  hline(362, 376, 221, L.reed.hi)
  -- ducks on the pool
  duck(308, 232, false, true, true) duck(322, 231, false, true)
  F.lily(400, 222, false, "yellow")
end
stall()
basket(410, 426, 224, 5, "cran", 90)
basket(414, 428, 214, 4, "egg", 91)
-- a shopper with a basket of eggs, by the stall
local _, shx, shy = F.gnome(282, 228, { hat = L.roof2, coat = L.accent, arm = "out", flip = true })
local bk = poly{ { shx - 3, shy }, { shx + 3, shy }, { shx + 2, shy + 5 }, { shx - 2, shy + 5 } }
rimOf(bk, L.reed) weave(bk, L.reed, shx, shy)
px(shx - 1, shy - 1, egg.hi) px(shx, shy - 1, egg.base) px(shx + 1, shy - 1, cran.base)
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
  -- it stands on a boardwalk platform in the wet sedge
  local plat = rect(118, 260, 190, 264)
  F.boardwalk(plat, false, 160)
  rimOf(union(can, posts, top, cloth, legs, bench), L.timber)
  tarPosts(posts)
  stripes(can, 120, 4, L.awnA, L.awnB)
  hline(128, 180, 222, L.awnB.hi)
  part(legs, L.timber, { nopop = true })
  part(top, L.board) F.planks(top, L.board, 5, true, 86)
  part(cloth, L.accent, { nopop = true })
  cloth:each(function(x, y) if ((x // 3) + (y // 2)) % 2 == 0 then px(x, y, L.accent.shade) end end) -- gingham
  for x = 127, 181, 3 do px(x, 254, L.accent.hi) end
  part(bench, L.timber, { nopop = true })
  -- feast: teapot, cranberry pie, a platter of smoked eel, a bowl of duck eggs, a jug
  local tp = poly{ { 134, 239 }, { 142, 239 }, { 143, 245 }, { 133, 245 } }
  rimOf(tp, L.awnA) part(tp, L.awnA) line({ { 143, 241 }, { 146, 238 } }):each(function(x, y) px(x, y, L.awnA.deep) end)
  px(137, 238, L.awnA.deep) px(138, 238, L.awnA.deep)
  local pie = poly{ { 148, 243 }, { 160, 243 }, { 162, 246 }, { 146, 246 } } rimOf(pie, L.board) part(pie, L.board, { nopop = true })
  hline(149, 159, 244, cran.base) for x = 149, 159, 3 do px(x, 244, L.board.hi) end px(150, 245, cran.hi)
  local pl = c:ellipse(169, 245, 5, 1) rimOf(pl, L.awnB) fill(pl, L.awnB.base)
  line({ { 165, 245 }, { 167, 244 }, { 170, 245 }, { 173, 244 } }):each(function(x, y) px(x, y, eelR.base) px(x, y - 1, eelR.hi) end)
  local bowl = poly{ { 174, 242 }, { 180, 242 }, { 179, 245 }, { 175, 245 } } rimOf(bowl, L.timber) part(bowl, L.reed, { nopop = true })
  px(175, 241, egg.hi) px(176, 241, egg.base) px(178, 241, egg.base) px(177, 240, egg.hi)
  vline(131, 239, 242, L.timber.edge)
  for x = 131, 175, 11 do hline(x, x + 3, 247, L.plaster.hi) px(x + 1, 246, cran.base) end
  lantern(130, 236, 0)
  lantern(178, 236, 0)
end
longTable()

---------------------------------------------------------------- bottom left: the eel pond with a jetty (plane 3)
local function pond()
  local water = poly{ { 18, 238 }, { 32, 228 }, { 72, 226 }, { 100, 232 }, { 108, 246 }, { 100, 260 }, { 60, 264 }, { 26, 262 }, { 16, 252 } }
  rimOf(water, L.peat)
  local bank = water:grow(2):cut(water)
  bank:each(function(x, y) local v = hash(x, y, 51) px(x, y, v < .4 and L.peat.base or (v < .65 and L.peat.hi or L.sedgeGround.base)) end)
  F.water(water, L.water)
  -- willow reflections along the far edge
  for _, rx in ipairs({ 36, 58, 84 }) do for k = 0, 4 do hline(rx - 3 + k // 2, rx + 3 - k // 2, 231 + k * 2, L.water.shade) end end
  for _, p in ipairs({ { 40, 242, true, "white" }, { 54, 252 }, { 28, 250, false, "yellow" } }) do F.lily(p[1], p[2], p[3], p[4]) end
  -- jetty of silvered boards on stilts
  F.stilts({ 74, 87, 101 }, 250, 257, 254)
  local jet = poly{ { 70, 240 }, { 104, 240 }, { 106, 250 }, { 72, 250 } }
  F.boardwalk(jet, false, 52)
  hline(72, 105, 250, L.timber.deep)
  -- rod leaning, line + red float
  line({ { 98, 240 }, { 80, 222 }, { 64, 220 } }):each(function(x, y) px(x, y, L.timber.deep) end)
  vline(64, 221, 236, L.awnB.shade) fill(rect(63, 236, 65, 238), L.awnA.base) px(63, 236, L.awnA.hi)
  hline(60, 68, 239, L.water.hi)
  -- an eel trap half sunk off the jetty end, its rope tied to a stilt
  eelTrap(48, 236, 14, L.reed)
  line({ { 62, 236 }, { 74, 246 } }):each(function(x, y) px(x, y, L.board.shade) end)
  -- a creel with an eel tail flipping out, and a tackle box on the jetty
  local fb = poly{ { 78, 233 }, { 87, 233 }, { 86, 239 }, { 79, 239 } } rimOf(fb, L.reed) weave(fb, L.reed, 78, 233)
  F.sprite({ "e.", "ee", ".e" }, 82, 230, { e = eelR.base })
  local box = rect(91, 234, 99, 239) rimOf(box, L.accent) part(box, L.accent) hline(91, 99, 236, L.accent.deep)
  -- a mallard hen and her ducklings
  duck(34, 248, true, true, true)
  duckling(44, 252) duckling(50, 254) duckling(56, 253)
  F.reeds(14, 26, 240, 16, 53, { cattails = 3, green = true })
  F.reeds(100, 110, 262, 12, 54, { cattails = 1 })
  F.dragonfly(66, 230, L.accent)
  F.moss(F.rock(16, 238, 6, 5), .3, 53)
end
pond()

---------------------------------------------------------------- bottom right: the flooded cranberry bog (plane 3, the forage patch)
local function bog()
  local T = L.timber
  local bed = poly{ { 304, 245 }, { 368, 245 }, { 374, 254 }, { 298, 254 } }
  local front = rect(298, 254, 374, 262)
  local back = rect(304, 243, 368, 245)
  shadow(300, 374, 262, 8, 2)
  rimOf(union(bed, front, back), T)
  part(back, L.board, { nopop = true })
  -- left two thirds flooded for the harvest: a raft of floating berries; right third still runners on peat
  local wet = bed:copy():clip(rect(298, 245, 350, 254))
  local dry = bed:copy():clip(rect(351, 245, 374, 254))
  fill(wet, L.water.shade)
  wet:each(function(x, y)
    local v = hash(x, y, 171)
    if v < .42 then px(x, y, ((x + y) % 2 == 0) and cran.base or cran.shade)
    elseif v < .52 then px(x, y, cran.hi) elseif v < .58 then px(x, y, F.SKYREF) end
  end)
  fill(dry, L.peat.shade)
  dry:each(function(x, y) local v = hash(x, y, 172)
    if v < .35 then px(x, y, L.leaf.shade) elseif v < .5 then px(x, y, L.leaf.base) elseif v < .6 then px(x, y, cran.base) end end)
  -- a floating boom of reed corralling the berries
  line({ { 312, 246 }, { 322, 252 }, { 340, 252 }, { 348, 247 } }):each(function(x, y) px(x, y, L.reed.base) px(x, y + 1, L.reed.deep) end)
  part(front, L.board) F.planks(front, L.board, 4, false, 173)
  F.logEnd(298, 258, 4) F.logEnd(374, 258, 4)
  -- cranberry bushes in flower along the back edge, marigolds
  for _, x in ipairs({ 310, 330, 360 }) do
    local b = poly{ { x - 6, 246 }, { x - 4, 239 }, { x, 236 }, { x + 4, 239 }, { x + 6, 246 } }
    rimOf(b, L.leaf) part(b, L.leaf)
    b:each(function(xx, y) local v = hash(xx, y, 73) if v < .12 then px(xx, y, cran.base) px(xx, y - 1, cran.hi) elseif v > .94 then px(xx, y, L.petal.hi) end end)
  end
  for _, x in ipairs({ 320, 345 }) do F.sedge(x, 245, 5) px(x - 1, 241, L.marigold.base) px(x + 1, 240, L.marigold.hi) end
  -- the wooden cranberry scoop (a toothed rake-box) leaning on the end
  fill(rect(371, 236, 372, 246), T.base)
  local sc = poly{ { 368, 246 }, { 376, 246 }, { 375, 252 }, { 369, 252 } } rimOf(sc, T) part(sc, L.board, { nopop = true })
  for x = 369, 375, 2 do px(x, 253, L.board.deep) end
end
bog()

---------------------------------------------------------------- near sedge and reeds, life
for _, f in ipairs({ { 112, 262, 7 }, { 194, 262, 8 }, { 200, 250, 6 }, { 288, 258, 7 }, { 196, 226, 6 }, { 112, 232, 5 } }) do F.sedge(f[1], f[2], f[3]) end
for _, f in ipairs({ { 196, 224 }, { 290, 256 }, { 116, 230 } }) do px(f[1] - 1, f[2] - 5, L.marigold.base) px(f[1] + 1, f[2] - 6, L.marigold.hi) end
F.reeds(190, 198, 264, 14, 180, { cattails = 1, green = true })
F.dragonfly(272, 206, L.apple, true)
F.frog(204, 262, true)
F.depth(0)
-- a skein of ducks and a few far birds
F.birds({ { 300, 30, 2 }, { 306, 33, 2 }, { 312, 36, 2 }, { 294, 33, 2 }, { 288, 36, 2 }, { 120, 64, 1 }, { 410, 48, 1 } })

F.finish()
