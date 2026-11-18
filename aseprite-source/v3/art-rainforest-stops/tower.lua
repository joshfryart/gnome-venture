-- tower.lua : "Watchtower" stop look, RAINFOREST (rainforest_canopy), 480x270 gate view.
-- Same composition and story as the Maplewold watchtower (art-2701-batch3/stops/opus3/tower.lua) and the forest
-- fire-watch tower, re-cast for the jungle canopy: road's end: a giant buttressed mahogany wrapped in strangler-fig
-- roots, a door in its hollow foot, a rope ladder (a gnome climbing) up to a bamboo lookout platform in the crown with
-- a woven-mat lookout hut, lamp-lit windows, palm thatch, a signal fire pot and a pennant. Rope bridges run off from
-- the platform through the canopy to two neighbouring tree platforms and on into the mist (they replace the curtain
-- wall); a capuchin crosses one, a sloth hangs under the other. Left: a teal plank guardhouse with palm thatch, water
-- tubes, a rattan shield; a spear and blowpipe rack; a coconut-headed training dummy; woven rattan targets; an archer.
-- Right: a stilt store in the mist, the alarm GONG in a carved frame (a gnome striking it), a bamboo nest box, a
-- brass spyglass on a bamboo tripod, palm-frond beacon bundles, coconut baskets, a clay water jar, a guard with a
-- spear and his coati.
-- Quirk: a toucan carrier in a red gnome hat, a tiny scroll tied to its leg, landing on the nest box.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-rainforest-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "tower", out = DIR, farTrees = { 24, 52, 380, 440 },
  treeLineGap = { 200, 280 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local S, IR, G, T, B, BD = L.stone, L.iron, L.glow, L.timber, L.bamboo, L.board
local RB = L.redbark
local rattan = F.rp("#f2d89a #d4b06a #a8844a #7a5e36 #4c3a24")
local clay = F.rp("#e8a070 #c4744a #9a5236 #6c3a2a #42241c")
local INK = "#2e2a30"

---------------------------------------------------------------- helpers (local; the shared frame stays untouched)
-- a rope bridge from (ax,ay) to (bx,by), sagging `sag` px: lashed plank deck, two hand ropes, stays and netting
local function bridge(ax, ay, bx, by, sag, s, seed)
  s = s or 1
  local deck = HP.mask()
  local ys = {}
  for x = ax, bx do
    local t = (x - ax) / (bx - ax)
    local y = floor(ay + (by - ay) * t + sag * 4 * t * (1 - t) + .5)
    ys[x] = y
    deck:add(rect(x, y, x, y + (s >= 1 and 1 or 0)))
  end
  -- fill vertical steps so a steep deck stays continuous
  for x = ax + 1, bx do if abs(ys[x] - ys[x - 1]) > 1 then local a, b = math.min(ys[x], ys[x - 1]), math.max(ys[x], ys[x - 1]) deck:add(rect(x, a, x, b)) end end
  local rh = floor(7 * s + .5)
  local rope = function(x) local t = (x - ax) / (bx - ax) return floor(ay - rh + (by - ay) * t + sag * 1.15 * 4 * t * (1 - t) + .5) end
  -- netting + stays first (thin, behind the deck)
  F.obj()
  for x = ax, bx do
    local ry, dy = rope(x), ys[x]
    local k = (x - ax) % (s >= 1 and 5 or 4)
    if k == 0 then vline(x, ry + 1, dy - 1, L.needle.shade)
    elseif s >= 1 then
      local q = (x - ax) % 10
      local ny = ry + 1 + (q < 5 and q or 10 - q)
      if ny < dy then px(x, ny, L.needle.deep) end
    end
    px(x, ry, L.needle.base)
    if hash(x, 1, seed) < .2 then px(x, ry, L.needle.hi) end
    if s >= 1 then px(x, ry + 1, L.needle.deep) end
  end
  rimOf(deck, T)
  deck:each(function(x, y)
    local top = not deck:has(x, y - 1)
    local h = top and BD.base or BD.shade
    if (x - ax) % 3 == 2 then h = top and BD.shade or BD.deep end
    if top and (x - ax) % 3 == 0 then h = BD.hi end
    if hash(x // 3, 0, seed) < .15 then h = top and T.base or T.shade end -- a few older dark planks
    px(x, y, h)
  end)
  return deck, ys, rope
end
-- a ring platform round a trunk: bamboo deck, two braces, a hand rail
local function ringDeck(x0, x1, y, cx, s)
  local deck = rect(x0, y, x1, y + 2)
  local br = line({ { x0 + 2, y + 3 }, { cx - 2, y + 12 } }):add(line({ { x1 - 2, y + 3 }, { cx + 2, y + 12 } }))
  rimOf(union(deck, br), T)
  part(br, B, { nopop = true, noshade = true })
  part(deck, B, { nopop = true }) F.bambooWall(deck, B, 2, true, x0)
  -- a rope hand rail on bamboo posts
  for x = x0 + 1, x1 - 1, 8 do vline(x, y - 5, y - 1, B.base) px(x, y - 5, B.hi) px(x + 1, y - 4, T.edge) end
  for x = x0, x1 do px(x, y - 4 + ((x - x0) % 8 == 4 and 1 or 0), L.needle.shade) end
  for x = x0 + 1, x1, 4 do px(x, y + 2, B.deep) end
end
local function coconut(x, y, half)
  local m = c:ellipse(x, y, 2, 2)
  c:rim(m, L.soil.edge) fill(m, L.soil.base) px(x - 1, y - 1, L.soil.hi)
  if half then fill(rect(x - 1, y - 1, x + 1, y), L.awnB.hi) px(x, y, L.awnB.shade) end
end
-- woven rattan texture over a mask
local function weave(m, r, seed)
  m:each(function(x, y)
    local a = ((x + y) // 2) % 2 == ((x - y) // 2) % 2
    local h = a and r.base or r.shade
    if a and (x + y) % 4 == 0 then h = r.hi end
    if hash(x, y, seed or 3) < .04 then h = r.deep end
    px(x, y, h)
  end)
end

---------------------------------------------------------------- far canopy: misty tree platforms the bridges run off to
F.depth(1)
F.tree(100, 134, 62, 1)
F.tree(392, 134, 58, 0)
F.tree(30, 140, 40, 2)
ringDeck(88, 112, 100, 100, .7)
ringDeck(380, 404, 102, 392, .7)
bridge(112, 101, 146, 93, 3, .7, 11)
bridge(336, 93, 380, 103, 3, .7, 12)

---------------------------------------------------------------- right back: a stilt store in the mist
F.depth(1)
local sstilts = HP.mask()
for _, sx in ipairs({ 372, 386, 404, 420 }) do sstilts:add(rect(sx, 140, sx + 1, 148)) end
rimOf(sstilts, T) part(sstilts, B, { nopop = true })
local st, scx, swall, sroof = F.building{ x0 = 368, x1 = 424, yb = 140, wh = 20, rh = 16, wall = L.plaster, roof = L.roof, noFrame = true, noAttic = true, noShadow = true }
F.door(390, 127, 400, 139, T, true) F.window(408, 126, 413, 131, T)
F.shadow(368, 424, 148, 6, 2)
F.bamboo(358, 148, 30, 3, 51)
-- a low woven-bamboo fence along the horizon, heliconia at the posts
F.fence(118, 196, 128, 9)
F.fence(286, 362, 128, 9)
for _, hx in ipairs({ 132, 176, 300, 346 }) do F.heliconia(hx, 129, 10, hx) end

---------------------------------------------------------------- road's end: the lookout tree
local function lookoutTree()
  F.depth(2)
  -- crown behind the lookout hut
  local crownM = HP.mask()
  for i, lb in ipairs({ { 202, 50, 24, 13, L.foliage }, { 278, 48, 24, 13, L.foliage2 }, { 240, 34, 34, 14, L.foliage },
    { 190, 66, 14, 8, L.foliage2 }, { 292, 64, 14, 8, L.foliage } }) do
    crownM:add(F.crown(lb[1], lb[2], lb[3], lb[4], lb[5], 60 + i))
  end
  -- epiphyte ferns and a bromeliad in the crown
  for _, p in ipairs({ { 196, 44 }, { 286, 42 }, { 262, 30 } }) do F.fern(p[1], p[2], 4) end
  -- the trunk with buttress fins
  local trunk = poly{ { 228, 60 }, { 252, 60 }, { 254, 100 }, { 259, 114 }, { 266, 124 }, { 274, 130 }, { 206, 130 }, { 214, 124 }, { 221, 114 }, { 226, 100 } }
  F.shadow(206, 274, 131, 14, 4)
  rimOf(trunk, RB)
  trunk:each(function(x, y)
    local hw = 12 + math.max(0, y - 100) * .9
    local t = (x - 240) / hw
    local h = RB.base
    if t < -.55 then h = RB.hi elseif t > .55 then h = RB.deep elseif t > .2 then h = RB.shade end
    if hash(x, y // 5, 17) < .16 then h = t < 0 and RB.shade or RB.deep end -- bark furrows
    if hash(x // 2, y // 7, 18) < .06 then h = RB.edge end
    if y > 112 and hash(x // 2, y // 2, 19) < .3 then h = hash(x, y, 20) < .5 and L.moss.base or L.moss.shade end
    px(x, y, h)
  end)
  -- buttress fin edges: lit lips on the left faces, dark creases between fins
  for _, f in ipairs({ { 229, 104, 210, 129, RB.hi }, { 233, 108, 226, 129, RB.edge }, { 251, 104, 270, 129, RB.edge }, { 247, 108, 254, 129, RB.deep } }) do
    line({ { f[1], f[2] }, { f[3], f[4] } }):each(function(x, y) if trunk:has(x, y) then px(x, y, f[5]) end end)
  end
  -- strangler-fig roots netting the trunk
  for k, r0 in ipairs({ { 232, 60, 1 }, { 248, 62, -1 }, { 244, 66, 1 } }) do
    local x0, y0, s = r0[1], r0[2], r0[3]
    for y = y0, 128 do
      local x = floor(x0 + s * sin((y - y0) / (9 + k)) * (4 + k) + (y > 100 and s * (y - 100) * .35 or 0) + .5)
      if trunk:has(x, y) and trunk:has(x + 1, y) then
        px(x, y, (y + k) % 9 == 0 and L.birch.shade or L.birch.base) px(x + 1, y, L.birch.deep)
        if trunk:has(x + 2, y) then px(x + 2, y, RB.edge) end
      end
    end
  end
  -- the hollow-foot door, stone steps, a lantern
  F.door(233, 112, 247, 127, T, true)
  for k = 0, 1 do hline(231 - k * 2, 249 + k * 2, 128 + k, S.hi) hline(231 - k * 2, 249 + k * 2, 129 + k, S.shade) end
  vline(229, 106, 108, T.edge) fill(rect(228, 109, 230, 112), G.base) px(228, 109, G.hi) px(230, 112, G.shade)
  -- orchids and a bromeliad on the bark
  F.orchid(222, 96, L.orchid, 2, true) F.orchid(254, 84, L.petal, 2)
  for _, b in ipairs({ { 232, 78 }, { 252, 102 } }) do
    local bx, by = b[1], b[2]
    px(bx, by, L.helic.base) px(bx - 1, by - 1, L.helic.hi) px(bx + 1, by - 1, L.helic.shade) px(bx, by - 1, L.helic.base)
    px(bx - 2, by, L.vine.base) px(bx + 2, by, L.vine.shade) px(bx, by + 1, L.vine.deep)
  end
  F.vines(rect(226, 60, 254, 62), .1, 71, 14)
  for _, f in ipairs({ { 206, 131, 6 }, { 214, 132, 5 }, { 266, 132, 5 }, { 274, 131, 6 } }) do F.fern(f[1], f[2], f[3]) end
  F.mushroom(222, 131, L.produce) F.mushroom(258, 131, L.produce, true)

  -- platform braces, deck
  local braces = line({ { 230, 88 }, { 206, 66 } }, 2):add(line({ { 250, 88 }, { 274, 66 } }, 2))
  braces:add(line({ { 229, 76 }, { 216, 66 } })):add(line({ { 251, 76 }, { 264, 66 } }))
  rimOf(braces, T) part(braces, B, { nopop = true, noshade = true })
  braces:each(function(x, y) if (x + y) % 7 == 0 then px(x, y, B.deep) end end)
  for _, p in ipairs({ { 230, 87 }, { 250, 87 } }) do fill(rect(p[1] - 1, p[2] - 1, p[1] + 1, p[2] + 1), L.needle.deep) px(p[1], p[2] - 1, L.needle.base) end -- rattan lashings
  local deck = rect(200, 62, 280, 66)
  rimOf(deck, T) part(deck, B) F.bambooWall(deck, B, 2, true, 72)
  for x = 201, 279, 5 do px(x, 66, B.deep) px(x, 67, T.edge) end
  -- rope ladder from the deck down the trunk to the door
  for y = 67, 110 do px(238, y, L.needle.shade) px(242, y, L.needle.deep) end
  for y = 69, 109, 4 do hline(239, 241, y, BD.base) px(239, y, BD.hi) hline(239, 241, y + 1, BD.deep) end
  F.gnome(240, 96, { small = true, hat = L.awnA, coat = L.wall2, arm = "up", noShadow = true })

  -- the lookout hut: woven mat walls between bamboo corner posts, a band of lamp-lit windows
  local hut = rect(220, 40, 260, 61)
  local roofM = poly{ { 210, 44 }, { 240, 19 }, { 270, 44 } }
  roofM:add(poly{ { 207, 46 }, { 211, 40 }, { 215, 44 } }):add(poly{ { 273, 46 }, { 269, 40 }, { 265, 44 } }) -- upswept eave tips
  rimOf(union(hut, roofM), T)
  part(hut, L.plaster)
  weave(hut, L.plaster, 73)
  for _, px0 in ipairs({ 220, 238, 258 }) do local pm = rect(px0, 40, px0 + 2, 61) part(pm, B, { nopop = true, noshade = true }) vline(px0, 40, 61, B.hi) vline(px0 + 2, 40, 61, B.shade) end
  hline(220, 260, 52, T.base) hline(220, 260, 53, T.deep)
  for _, w in ipairs({ { 224, 44, 235, 50 }, { 243, 44, 254, 50 } }) do
    fill(rect(w[1], w[2], w[3], w[4]), T.edge)
    fill(rect(w[1] + 1, w[2] + 1, w[3] - 1, w[4]), G.shade) fill(rect(w[1] + 1, w[2] + 1, w[1] + 5, w[2] + 3), G.base) px(w[1] + 1, w[2] + 1, G.hi)
    hline(w[1] - 1, w[3] + 1, w[4] + 1, T.base)
    -- rolled palm blinds
    hline(w[1], w[3], w[2], L.needle.base) hline(w[1], w[3], w[2] + 1, L.needle.shade)
  end
  -- the lookout inside: a red cap and a spyglass glint
  fill(rect(248, 46, 250, 48), L.awnA.base) px(248, 46, L.awnA.hi) px(251, 47, L.gold.hi) px(252, 47, L.gold.shade)
  part(roofM, L.roof, { sep = true })
  F.palmThatch(roofM, L.roof, 19, 240, 74)
  line({ { 211, 43 }, { 239, 20 } }):each(function(x, y) if roofM:has(x, y) then px(x, y, L.roof.hi) end end)
  for x = 207, 273 do
    local len = 1 + floor(hash(x, 44, 75) * 3)
    for k = 1, len do if not hut:has(x, 44 + k) or k == 1 then px(x, 44 + k, k == len and L.roof.edge or (k == 1 and L.roof.deep or L.roof.shade)) end end
  end
  vline(240, 15, 18, T.edge) px(240, 14, L.gold.hi) -- ridge finial
  -- railing along the front of the deck
  local rail = rect(200, 55, 280, 55):add(rect(200, 59, 280, 59))
  for x = 200, 280, 6 do rail:add(rect(x, 55, x, 61)) end
  rail:cut(rect(221, 56, 259, 58))
  rimOf(rail, T) part(rail, B, { nopop = true, noshade = true }) hline(200, 280, 55, B.hi)
  -- a woven palm screen hanging on the rail with the lookout's emblem: a gold eye
  local scr = rect(262, 56, 276, 61) rimOf(scr, T) weave(scr, rattan, 76)
  F.sprite({ ".ggg.", "gGkGg", ".ggg." }, 267, 57, { g = L.gold.base, G = L.awnB.hi, k = L.accent.deep }, { rim = false })
  -- sentry on the deck, waving
  F.gnome(212, 61, { small = true, hat = L.awnA, coat = L.accent, arm = "up", noShadow = true, flip = true })
  -- signal fire: a clay pot on a bamboo pole at the left end of the deck
  local pole = rect(203, 44, 204, 61)
  local pot = poly{ { 197, 40 }, { 210, 40 }, { 208, 45 }, { 199, 45 } }
  rimOf(union(pole, pot), T) part(pole, B, { nopop = true, noshade = true }) part(pot, clay)
  hline(197, 210, 40, clay.hi) hline(199, 208, 43, clay.deep)
  local fire = poly{ { 197, 40 }, { 199, 32 }, { 201, 36 }, { 203, 27 }, { 206, 35 }, { 208, 31 }, { 210, 40 } }
  fill(fire, G.shade) fill(poly{ { 199, 40 }, { 203, 31 }, { 208, 40 } }, G.base) fill(poly{ { 202, 40 }, { 203, 35 }, { 205, 40 } }, G.hi)
  for i = 0, 4 do px(196 + floor(hash(i, 1, 2) * 16), 22 + floor(hash(i, 2, 2) * 6), G.hi) end
  F.smoke(198, 20, 4, -.6, 2)
  -- pennant pole at the right end, a teal pennant with a gold leaf
  local pp = rect(278, 22, 279, 61)
  rimOf(pp, T) part(pp, B, { nopop = true, noshade = true }) px(278, 21, L.gold.hi)
  local flag = poly{ { 280, 23 }, { 302, 26 }, { 296, 29 }, { 302, 33 }, { 280, 34 } }
  rimOf(flag, L.awnA) part(flag, L.awnA)
  F.sprite({ ".g.", "ggg", ".t." }, 284, 26, { g = L.gold.base, t = L.gold.shade }, { rim = false })
  return crownM
end

---------------------------------------------------------------- neighbouring tree platforms and the rope bridges
F.depth(2)
F.canopy(160, 134, 92, L.foliage2, 3, { w = 26 })
F.canopy(322, 134, 90, L.foliage, 5, { w = 25 })
ringDeck(144, 176, 92, 160)
ringDeck(306, 338, 92, 322)
lookoutTree()
F.depth(2)
local _, lys = bridge(176, 93, 200, 64, 3, 1, 21)
local _, rys = bridge(280, 64, 306, 93, 3, 1, 22)
-- a capuchin crossing the left bridge, tail up in a curl
F.sprite({
  "........tt.",
  "..cc....t.t",
  ".cMMc...t..",
  ".MffM...t..",
  ".fefe..t...",
  ".MfnMMMt...",
  "..MMMMMM...",
  ".MM.MMmM...",
  ".M..M..M...",
}, 182, lys[186] - 9, { M = T.base, m = T.shade, c = L.awnB.base, f = L.skin.hi, e = T.edge, n = L.skin.deep, t = T.shade })
-- a three-toed sloth hanging under the right bridge
F.sprite({
  "c....c",
  "S....S",
  "SS..SS",
  ".SSSS.",
  "SmmmmS",
  "SememS",
  ".SmmS.",
  "..SS..",
}, 290, rys[293] + 2, { c = INK, S = L.palmTrunk.base, m = L.awnB.shade, e = T.edge })
F.vines(rect(144, 95, 176, 95), .12, 81, 10)

---------------------------------------------------------------- bamboo pennant poles lining the road
local function banner(x, yb, s, r)
  local h = floor(30 * s)
  local pole = rect(x, yb - h, x + math.max(1, floor(s)), yb)
  local fl = poly{ { x + 1, yb - h + 1 }, { x + 1 + floor(9 * s), yb - h + 1 }, { x + 1 + floor(9 * s), yb - h + floor(16 * s) }, { x + 1 + floor(4.5 * s), yb - h + floor(12 * s) }, { x + 1, yb - h + floor(16 * s) } }
  F.shadow(x, x + 2, yb, floor(4 * s), 2)
  rimOf(union(pole, fl), T)
  part(pole, B, { nopop = true, noshade = true })
  pole:each(function(xx, y) if (y - yb) % 6 == 0 then px(xx, y, B.deep) end end)
  part(fl, r, { nopop = s < 1 })
  fl:each(function(xx, y) if not fl:has(xx, y + 1) and (xx % 2 == 0) then px(xx, y, r.deep) end end) -- fringe
  if s >= 1 then F.sprite({ ".l.", "lLl", ".l." }, x + floor(4 * s) - 1, yb - h + 4, { l = L.leaf.base, L = L.leaf.hi }, { rim = false }) end
  -- macaw feather tuft at the tip
  px(x, yb - h - 1, L.apple.base) px(x - 1, yb - h - 2, L.apple.hi) px(x + 1, yb - h - 2, "#4a8ad8")
  F.fern(x - 1, yb, math.max(2, floor(4 * s)))
end
for _, p in ipairs({ { 140, .55 }, { 166, .8 }, { 206, 1.2 } }) do
  local y, s = p[1], p[2]
  banner(floor(F.xl(y)) - floor(14 * s) - 4, y, s, L.awnA)
  banner(floor(F.xr(y)) + floor(6 * s), y, s, L.accent)
end

---------------------------------------------------------------- left: teal plank guardhouse + rack + dummy
F.depth(3)
local gt, gcx, gwall, groof = F.building{ x0 = 54, x1 = 150, yb = 168, wh = 40, rh = 26, wall = L.wall2, roof = L.roof2, noFrame = true, noAttic = true }
F.planks(gwall:copy():clip(rect(54, gt, 150, 161)), L.wall2, 5, true, 7)
local gfoot = rect(54, 162, 150, 168) part(gfoot, S, { nopop = true }) F.courses(gfoot, 162, 3, 8, S) F.moss(gfoot, .3, 84) F.shine(gfoot, .08, 85)
hline(54, 150, 161, T.edge)
local gposts = union(rect(54, gt, 56, 161), rect(148, gt, 150, 161), rect(54, gt, 150, gt + 1))
part(gposts, T, { nopop = true, noshade = true })
-- red bands painted on the corner posts
for _, x in ipairs({ 54, 148 }) do for y = gt + 6, 158, 10 do hline(x, x + 2, y, L.awnA.base) hline(x, x + 2, y + 1, L.awnA.shade) end end
local ggable = poly{ { 59, gt }, { gcx, gt - 18 }, { 145, gt } }
weave(ggable, L.plaster, 86)
F.window(98, 112, 104, 118, T)
F.door(94, 142, 108, 167, T, true)
F.window(66, 140, 74, 147, T) F.window(126, 140, 134, 147, T)
F.smoke(102, 104, 5, .5, 2)
-- orchid baskets hanging from the eave
for _, bx in ipairs({ 62, 140 }) do
  vline(bx, gt + 2, gt + 6, L.needle.deep)
  local bk = c:ellipse(bx, gt + 8, 3, 2) rimOf(bk, T) weave(bk, rattan, bx)
  px(bx - 2, gt + 5, L.orchid.hi) px(bx - 1, gt + 6, L.orchid.base) px(bx + 2, gt + 5, L.orchid.base) px(bx + 1, gt + 4, L.orchid.hi) px(bx + 3, gt + 6, L.vine.base)
  F.vine(bx - 2, gt + 10, 6, bx, L.vine)
end
local wp = rect(17, 149, 18, 172) rimOf(wp, T) part(wp, B, { nopop = true, noshade = true })
F.washing(18, 150, 54, 146, { { "sock", L.awnA }, { "shirt", L.accent }, { "sock", L.roof } }, 5)
-- rattan round shield over the door, a red sun painted on it
local sh = c:ellipse(101, 133, 6, 5)
rimOf(sh, T) weave(sh, rattan, 87)
fill(c:ellipse(101, 133, 2, 2), L.awnA.base) px(100, 132, L.awnA.hi)
for _, d in ipairs({ { -4, 0 }, { 4, 0 }, { 0, -4 }, { 0, 4 } }) do px(101 + d[1], 133 + d[2], L.awnA.shade) end
-- bamboo water tubes on pegs between the door and the window (the fire buckets)
hline(111, 123, 150, T.edge)
for k = 0, 2 do
  local bx = 112 + k * 4
  local b = rect(bx, 151, bx + 2, 159)
  rimOf(b, B) part(b, B, { nopop = true }) px(bx, 151, B.hi) px(bx + 1, 151, L.water.base) hline(bx, bx + 2, 155, B.deep)
end
-- coconut pile under the left window
coconut(62, 164) coconut(67, 165) coconut(72, 164) coconut(65, 160, true) coconut(70, 160)

local function rack(x0, yb)
  local posts = rect(x0, yb - 26, x0 + 2, yb):add(rect(x0 + 40, yb - 26, x0 + 42, yb))
  local rails = rect(x0, yb - 24, x0 + 42, yb - 23):add(rect(x0, yb - 8, x0 + 42, yb - 7))
  F.shadow(x0, x0 + 42, yb, 8, 3)
  rimOf(union(posts, rails), T)
  for k = 0, 4 do
    local x = x0 + 6 + k * 7
    if k == 2 then -- a long blowpipe with a dart quiver
      vline(x, yb - 46, yb - 1, T.base) vline(x + 1, yb - 46, yb - 1, T.shade) px(x, yb - 46, T.edge)
      local q = rect(x + 2, yb - 22, x + 4, yb - 12) rimOf(q, B) part(q, B, { nopop = true })
      px(x + 3, yb - 23, L.awnB.hi) px(x + 4, yb - 24, L.apple.base)
    else
      vline(x, yb - 34, yb - 1, B.base) vline(x + 1, yb - 34, yb - 1, B.shade)
      for y = yb - 30, yb - 2, 7 do px(x, y, B.deep) px(x + 1, y, B.deep) end
      local tip = poly{ { x - 1, yb - 34 }, { x + 1, yb - 40 }, { x + 3, yb - 34 } } fill(tip, IR.hi) px(x + 2, yb - 34, IR.shade)
      px(x - 1, yb - 33, L.apple.base) -- red binding
    end
  end
  part(posts, T, { nopop = true, noshade = true }) part(rails, B, { nopop = true, noshade = true })
  F.moss(posts, .25, 86)
  for k, r in ipairs({ L.awnA, L.accent }) do
    local x = x0 + 50 + k * 13
    local m = c:ellipse(x, yb - 8, 7, 8)
    rimOf(m, T) weave(m, rattan, 90 + k)
    c:ellipse(x, yb - 8, 5, 6):edge():each(function(xx, yy) px(xx, yy, r.base) end)
    fill(c:ellipse(x, yb - 8, 1, 1), r.shade) px(x - 1, yb - 9, r.hi)
    px(x - 4, yb - 13, rattan.hi)
  end
end
rack(60, 200)
local function dummy(x, yb)
  local post = rect(x - 1, yb - 30, x + 1, yb):add(rect(x - 12, yb - 22, x + 12, yb - 20))
  local body = c:rrect(x - 7, yb - 26, x + 7, yb - 10, 4)
  local head = c:ellipse(x, yb - 32, 5, 5)
  F.shadow(x - 6, x + 8, yb, 6, 2)
  rimOf(union(post, body, head), T)
  part(post, B, { nopop = true, noshade = true })
  part(body, L.needle) body:each(function(xx, y) if (xx + y) % 3 == 0 then px(xx, y, L.needle.shade) elseif (xx - y) % 5 == 0 then px(xx, y, L.needle.hi) end end) -- palm fibre
  hline(x - 7, x + 7, yb - 18, T.edge) -- rattan belt
  part(head, L.soil) head:each(function(xx, y) if hash(xx, y, 9) < .3 then px(xx, y, L.soil.shade) end end) -- a coconut head
  px(x - 3, yb - 34, L.soil.hi) px(x - 2, yb - 35, L.soil.hi)
  fill(rect(x - 2, yb - 33, x - 1, yb - 32), T.edge) fill(rect(x + 2, yb - 33, x + 3, yb - 32), T.edge)
  hline(x - 2, x + 2, yb - 29, L.soil.deep)
  -- half a coconut shell as a helmet, with a red feather
  local hel = c:ellipse(x, yb - 37, 6, 3):clip(rect(x - 7, yb - 41, x + 7, yb - 36))
  fill(hel, L.soil.shade) hline(x - 6, x + 6, yb - 36, L.awnB.base) px(x - 3, yb - 39, L.soil.hi)
  line({ { x + 3, yb - 39 }, { x + 7, yb - 46 } }):each(function(xx, yy) px(xx, yy, L.apple.base) end) px(x + 8, yb - 47, L.apple.hi)
  px(x - 8, yb - 12, L.needle.hi) px(x + 8, yb - 14, L.needle.hi) px(x + 9, yb - 13, L.needle.base)
  -- a tree frog on the crossbar
  F.sprite({ "e.e", "GGG", "g.g" }, x + 8, yb - 25, { e = L.apple.base, G = L.fern.hi, g = L.fern.shade }, { rim = false })
end
dummy(178, 208)

---------------------------------------------------------------- archery range, bottom-left: woven rattan targets
local function target(x, yb, s)
  local legs = line({ { x - 6 * s, yb }, { x, yb - 22 * s } }, 2):add(line({ { x + 6 * s, yb }, { x, yb - 22 * s } }, 2))
  local cy = floor(yb - 16 * s)
  local R = floor(10 * s)
  local face = c:ellipse(x, cy, R, R)
  F.shadow(floor(x - 6 * s), floor(x + 8 * s), yb, 6, 2)
  rimOf(union(legs, face), T)
  part(legs, B, { nopop = true, noshade = true })
  -- coiled rattan: concentric rings, lit upper-left
  face:each(function(xx, yy)
    local d = math.sqrt((xx - x) ^ 2 + (yy - cy) ^ 2)
    local h = floor(d) % 2 == 0 and rattan.base or rattan.shade
    if (xx - x) + (yy - cy) < -R * .7 and floor(d) % 2 == 0 then h = rattan.hi end
    if (xx - x) + (yy - cy) > R * .8 then h = rattan.deep end
    if hash(floor(math.atan(yy - cy, xx - x) * 6), floor(d), 4) < .12 then h = rattan.deep end
    px(xx, yy, h)
  end)
  fill(c:ellipse(x, cy, floor(7 * s), floor(7 * s)):cut(c:ellipse(x, cy, floor(6 * s), floor(6 * s))), L.awnA.base)
  fill(c:ellipse(x, cy, floor(4 * s), floor(4 * s)):cut(c:ellipse(x, cy, floor(3 * s), floor(3 * s))), L.accent.base)
  fill(c:ellipse(x, cy, math.max(1, floor(2 * s)), math.max(1, floor(2 * s))), L.awnA.base) px(x - 1, cy - 1, L.awnA.hi)
  for k = 0, 1 do local ax, ay = floor(x - 2 + k * 5), floor(cy - 2 + k * 4) fill(line({ { ax, ay }, { ax - 6, ay + 3 } }), T.deep) px(ax - 6, ay + 3, L.apple.base) px(ax - 7, ay + 3, "#4a8ad8") end
  F.fern(floor(x - 7 * s), yb + 1, 4) F.fern(floor(x + 8 * s), yb + 1, 3)
end
target(40, 252, 1.2) target(82, 244, .9)
local _, ax, ay = F.gnome(150, 258, { hat = L.foliage, coat = L.roof2, arm = "out", flip = true })
fill(c:ellipse(ax - 1, ay, 2, 8):cut(c:ellipse(ax, ay, 1, 7)), T.base) vline(ax - 1, ay - 7, ay + 7, L.awnB.shade) -- bow
fill(line({ { ax - 1, ay }, { ax + 8, ay } }), T.deep) px(ax - 2, ay, IR.hi)
-- a bamboo quiver stuck in the ground by the archer
local qv = rect(165, 246, 169, 260) rimOf(qv, B) part(qv, B, { nopop = true }) hline(165, 169, 253, B.deep)
for k = 0, 2 do vline(165 + k * 2, 240, 245, T.deep) px(165 + k * 2, 239, k == 1 and "#4a8ad8" or L.apple.base) end
-- jungle floor along the left edge: elephant ears, a bamboo clump, heliconia, ferns
F.bigLeaf(22, 194, 14, -pi * .7, L.foliage, 21, 6, { heart = true, stem = { 28, 208 } })
F.bigLeaf(34, 198, 12, -pi * .3, L.leaf, 22, 5, { heart = true, stem = { 30, 210 } })
F.heliconia(122, 224, 18, 63)
for _, f in ipairs({ { 18, 262, 7 }, { 120, 262, 6 }, { 112, 218, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.mushroom(58, 262, L.produce, true) F.mushroom(64, 264, L.produce) F.mushroom(54, 265, L.produce)
local lr = F.rock(100, 266, 8, 6) F.moss(lr, .3, 88) F.shine(lr, .12, 89)
F.puddle(176, 234, 6, 31)

---------------------------------------------------------------- right: gong frame, nest box, spyglass
local function gongFrame(x0, yb)
  local posts = rect(x0, yb - 44, x0 + 3, yb):add(rect(x0 + 34, yb - 44, x0 + 37, yb))
  local beam = rect(x0 - 4, yb - 48, x0 + 41, yb - 45)
  beam:add(poly{ { x0 - 8, yb - 51 }, { x0 - 4, yb - 48 }, { x0 - 4, yb - 45 } }):add(poly{ { x0 + 45, yb - 51 }, { x0 + 41, yb - 48 }, { x0 + 41, yb - 45 } })
  local foot = rect(x0 - 3, yb - 3, x0 + 6, yb):add(rect(x0 + 31, yb - 3, x0 + 40, yb))
  local gx, gy, R = x0 + 18, yb - 24, 12
  local disc = c:ellipse(gx, gy, R, R)
  F.shadow(x0, x0 + 40, yb, 8, 3)
  rimOf(union(posts, beam, foot), T)
  part(posts, T, { nopop = true }) part(beam, T) hline(x0 - 4, x0 + 41, yb - 48, T.hi)
  for _, x in ipairs({ x0, x0 + 34 }) do
    for y = yb - 40, yb - 8, 8 do hline(x, x + 3, y, L.awnA.base) hline(x, x + 3, y + 1, L.awnA.shade) end -- painted bands
    px(x + 1, yb - 43, L.gold.hi)
  end
  part(foot, S, { nopop = true }) F.moss(foot, .4, 91)
  -- palm-thatch hood over the beam
  local hood = poly{ { x0 - 7, yb - 49 }, { x0 + 18, yb - 60 }, { x0 + 44, yb - 49 } }
  rimOf(hood, L.roof2) part(hood, L.roof2, { sep = true }) F.palmThatch(hood, L.roof2, yb - 60, x0 + 18, 92)
  -- hanging cords
  line({ { x0 + 12, yb - 45 }, { x0 + 14, yb - 35 } }):each(function(x, y) px(x, y, L.needle.deep) end)
  line({ { x0 + 24, yb - 45 }, { x0 + 22, yb - 35 } }):each(function(x, y) px(x, y, L.needle.deep) end)
  -- the bronze gong: rolled rim, hammered face, raised boss, lit upper left
  c:rim(disc, L.gold.edge)
  disc:each(function(x, y)
    local dx, dy = x - gx, y - gy
    local d = math.sqrt(dx * dx + dy * dy)
    local lit = (dx + dy) / (R * 1.41)
    local h = L.gold.base
    if lit < -.35 then h = L.gold.hi elseif lit > .45 then h = L.gold.deep elseif lit > .1 then h = L.gold.shade end
    if d > R - 2 then h = lit < 0 and L.gold.base or L.gold.deep end
    if floor(d + .5) == 8 then h = L.gold.deep end
    if floor(d + .5) == 7 and lit < 0 then h = L.gold.hi end
    if d < 8 and hash(x, y, 93) < .07 then h = L.gold.shade end -- hammer marks
    px(x, y, h)
  end)
  local boss = c:ellipse(gx, gy, 3, 3)
  fill(boss, L.gold.shade) px(gx - 1, gy - 1, L.gold.hi) px(gx - 2, gy, L.gold.base) px(gx, gy - 2, L.gold.base) px(gx + 1, gy + 1, L.gold.deep) px(gx + 2, gy + 1, L.gold.edge)
  px(gx - 6, gy - 7, L.wet) px(gx - 7, gy - 6, L.shine)
  -- ringing: sound arcs off the left rim
  for k = 0, 2 do
    local rr = R + 3 + k * 3
    for a = 0, 8 do local an = pi * .82 + a * .07 px(floor(gx + cos(an) * rr + .5), floor(gy + sin(an) * rr + .5), k == 0 and L.gold.hi or L.awnB.hi) end
  end
end
F.depth(2)
-- wild bananas and a palm behind the gong
F.palm(470, 152, 84, 9, { lean = -8 })
gongFrame(300, 196)
-- a gnome striking the gong with a padded mallet
local _, bx, by = F.gnome(338, 206, { hat = L.produce, coat = L.lav, arm = "up", flip = true })
local handle = line({ { bx, by + 1 }, { 332, 174 } })
handle:each(function(x, y) px(x, y, T.base) end)
local head = c:ellipse(331, 172, 2, 2) rimOf(head, L.awnB) fill(head, L.awnB.base) px(330, 171, L.awnB.hi) px(332, 173, L.awnB.shade)
F.depth(3)
local function nestBox(x, yb)
  local post = rect(x - 1, yb - 40, x + 1, yb)
  local box = rect(x - 12, yb - 58, x + 12, yb - 40)
  local roofm = poly{ { x - 16, yb - 57 }, { x, yb - 69 }, { x + 16, yb - 57 } }
  F.shadow(x - 2, x + 4, yb, 6, 2)
  rimOf(union(post, box, roofm), T)
  part(post, B, { nopop = true, noshade = true }) post:each(function(xx, y) if y % 7 == 0 then px(xx, y, B.deep) end end)
  part(box, BD) F.bambooWall(box, BD, 3, true, 19)
  part(roofm, L.roof, { sep = true }) F.palmThatch(roofm, L.roof, yb - 69, x, 94)
  for xx = x - 16, x + 16 do if hash(xx, 1, 95) < .6 then px(xx, yb - 56, L.roof.deep) end end
  for k = 0, 2 do local hx = x - 9 + k * 7 fill(c:ellipse(hx + 2, yb - 50, 2, 3), T.edge) px(hx + 1, yb - 52, T.deep) hline(hx - 1, hx + 5, yb - 46, T.base) end
  F.vine(x - 11, yb - 39, 9, 7) F.vine(x + 10, yb - 39, 6, 9, nil, L.orchid)
  F.moss(post, .3, 96) F.fern(x - 3, yb, 5) F.fern(x + 4, yb + 1, 4)
  F.heliconia(x - 8, yb + 2, 16, 97)
  -- quirk: the toucan carrier landing, wings up, in a red gnome hat, a cream scroll with a red ribbon on its leg
  F.sprite({
    "............RR.........",
    "...........RR..........",
    "..........RRr..........",
    ".........RRRr.......KK.",
    ".........RRRRr.....KKKK",
    "........hhhhhh....KKwKK",
    "........KKBBKK...KKwKK.",
    "YYYYYOOOKBeBKK..KKwKK..",
    "YYYYYYOOWWBKKKKKKKKK...",
    ".oYYYYYOWWWKKKKKKK.....",
    "..ooYYYOWWWWKKKKK......",
    "......WWWWWKKKKKK......",
    "......WWWWKKKKKK.......",
    ".......uuKKKKKKKK......",
    "........KKKKK..KKK.....",
    "........f..f.....KK....",
    ".......sZxs.......K....",
    ".......sZZs............",
  }, x - 13, yb - 87, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, K = INK, w = "#4a4450", B = "#4a8ad8", e = T.edge,
    Y = L.gold.base, O = L.produce.base, o = L.apple.base, W = L.gold.hi, u = L.apple.base, f = IR.base, s = L.awnB.hi, Z = L.awnB.shade, x = L.awnA.base })
end
nestBox(440, 196)
-- brass spyglass on a bamboo tripod with a gnome lookout
local tri = line({ { 362, 214 }, { 370, 196 } }):add(line({ { 378, 214 }, { 370, 196 } })):add(line({ { 370, 214 }, { 370, 196 } }))
local tube = line({ { 362, 198 }, { 384, 186 } }, 3)
rimOf(union(tri, tube), T) part(tri, B, { nopop = true, noshade = true }) part(tube, L.gold) fill(rect(382, 184, 386, 188), L.gold.shade) px(362, 198, L.water.hi)
hline(370, 373, 192, L.gold.deep) px(376, 190, L.gold.deep) px(366, 195, L.gold.deep)
F.gnome(354, 218, { hat = L.lav, coat = L.awnA, arm = "out" })
-- beacon bundles of dry palm fronds and bamboo torches, coconut baskets, a clay water jar
for k = 0, 2 do
  local x = 300 + k * 18
  local m = rect(x, 228, x + 14, 236) rimOf(m, L.needle) part(m, L.needle, { nopop = true })
  m:each(function(xx, y) if (y - 228) % 2 == 0 and hash(xx // 3, y, k) < .5 then px(xx, y, L.needle.hi) elseif (xx + y) % 5 == 0 then px(xx, y, L.needle.shade) end end)
  fill(rect(x + 5, 228, x + 6, 236), T.edge) fill(rect(x + 10, 228, x + 10, 236), T.shade) -- rattan ties
  for y = 229, 235, 2 do px(x + 15, y, L.needle.base) px(x + 16, y + 1, L.needle.shade) end -- frayed frond ends
end
local function basket(x, yb, w, h)
  local m = poly{ { x - w, yb - h }, { x + w, yb - h }, { x + w - 2, yb }, { x - w + 2, yb } }
  rimOf(m, T) weave(m, rattan, x)
  hline(x - w, x + w, yb - h, rattan.hi) hline(x - w + 1, x + w - 1, yb - h + 1, rattan.deep)
  return yb - h
end
local t1 = basket(310, 256, 9, 11) coconut(305, t1 - 1) coconut(310, t1 - 2, true) coconut(315, t1 - 1)
local t2 = basket(330, 258, 8, 10) for k = -2, 2 do px(330 + k * 2, t2 - 1, L.produce.base) px(330 + k * 2, t2 - 2, L.produce.hi) px(331 + k * 2, t2 - 1, L.produce.shade) end -- mangoes? papaya slices
local t3 = basket(320, 244, 7, 8) coconut(318, t3 - 1) coconut(322, t3 - 1)
local jar = c:ellipse(348, 252, 6, 7):add(rect(345, 243, 351, 246))
rimOf(jar, clay) part(jar, clay) hline(345, 351, 243, clay.hi) hline(344, 352, 246, clay.deep) px(345, 249, L.wet) px(346, 248, L.shine)
hline(343, 353, 254, clay.shade)
-- right foreground jungle, clear of the compass corner
F.treeFern(372, 266, 30, 41)
F.heliconia(412, 226, 18, 44)
for _, f in ipairs({ { 446, 222, 7 }, { 456, 226, 8 }, { 286, 262, 7 }, { 362, 228, 5 }, { 398, 214, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.mushroom(404, 224, L.produce, true) F.mushroom(398, 226, L.produce)
F.orchid(426, 222, L.orchid, 2, true)
F.puddle(404, 196, 7, 33) F.puddle(388, 204, 4, 34)
local fl = rect(414, 200, 436, 205) rimOf(fl, T) part(fl, T, { nopop = true }) F.moss(fl, .35, 98) F.logEnd(436, 202, 3)
F.mushroom(420, 199, L.produce, true) F.mushroom(426, 199, L.produce) F.fern(412, 206, 5)
-- a mossy stump by the road with a bromeliad
local stp = rect(282, 210, 290, 218) local stt = c:ellipse(286, 210, 4, 2)
rimOf(union(stp, stt), T) part(stp, T, { nopop = true }) fill(stt, BD.base) px(286, 210, BD.shade) px(284, 209, BD.hi)
F.moss(stp, .3, 97)
px(287, 208, L.helic.base) px(286, 207, L.helic.hi) px(288, 207, L.helic.shade) px(285, 208, L.vine.base) px(289, 208, L.vine.shade)
-- guard with a spear on the road
local _, gx, gy = F.gnome(258, 242, { hat = L.roof2, coat = L.foliage, arm = "hold" })
fill(rect(gx + 6, 204, gx + 6, 242), B.shade) fill(poly{ { gx + 5, 204 }, { gx + 6, 197 }, { gx + 8, 204 } }, IR.hi) px(gx + 5, 205, L.apple.base) -- spear
-- the guard's coati, ringed tail up
F.sprite({
  "...e.......t",
  "..DDD.....tT",
  "nnDwDDDDD.t.",
  "..DDDDDDDDT.",
  "..DdDDDDd...",
  "..d.d..d.d..",
}, 270, 236, { e = L.needle.deep, D = L.needle.base, d = L.needle.shade, w = L.awnB.hi, n = L.needle.deep, t = L.needle.base, T = T.deep })
-- a fallen fig the coati is after
px(266, 241, L.lav.base) px(267, 241, L.lav.shade) px(266, 240, L.lav.hi)
-- blue morphos
for _, b in ipairs({ { 186, 222 }, { 330, 140 }, { 70, 186 } }) do
  F.sprite({ "BB.BB", "bBkBb", ".b.b." }, b[1], b[2], { B = "#5aa8f0", b = "#2c62b4", k = T.edge }, { rim = false })
end
F.depth(0)
F.birds({ { 156, 40, 2, "#2e7a46" }, { 166, 46, 1, "#2e7a46" }, { 330, 50, 2, "#b03a36" }, { 344, 56, 1, "#2e7a46" } })
F.finish()
