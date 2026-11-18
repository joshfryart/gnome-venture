-- tower.lua : "Watchtower" stop look, WETLAND (wetland_reed), 480x270 gate view.
-- Same composition and story as the Maplewold watchtower (art-2701-batch3/stops/opus3/tower.lua), re-cast for a reed fen:
-- road's end: a stilted bird-hide watchtower standing in a reedy pool. Four tall grey-brown stilts with lashed walings
-- and zig-zag diagonals, a zig-zag stair with a mid landing, a boardwalk gallery, a reed-wattle hide with a long viewing
-- slit (a lookout with a brass spyglass peering out), a wide conical water-reed thatch with a sedge crown, a beacon
-- basket burning on the apex, an alarm bell on a bracket rung by the sentry, a striped windsock, a lifebuoy.
-- Along the horizon: wattle hurdles on a low flood bank. Willow poles with pennants line the causeway.
-- Left: a weatherboard guardhouse with reed thatch on a stilted deck, eel traps, a peat stack, washing, a rack of
-- fish spears / leisters, a boat hook and wicker shields, a reed-sheaf training dummy, coiled-reed archery butts,
-- a pool with a fishing heron. Right: a boathouse in the mist, the alarm bell frame under a thatch hood,
-- a stack of reed beacon bundles, a pigeon loft on a post, a telescope lookout, reed faggots, crates,
-- a heron pool, a guard with a spear and his dog.
-- Quirk: the carrier pigeon landing on the loft, a cream scroll on its leg, now in a tiny red gnome hat.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-wetland-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "tower", out = DIR, farTrees = { 24, 52, 100, 380, 440 },
  treeLineGap = { 198, 284 }, poolK = .79 }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local S, IR, G, T, B = L.stone, L.iron, L.glow, L.timber, L.board
local WB = L.willowBark
local TAR = F.rp("#8a8c80 #64685e #4a4e48 #363a36 #24282a") -- tarred weatherboard

-- the cut end of a reed bundle seen face-on (as in mill.lua)
local function bundleEnd(x, y, r)
  local m = c:ellipse(x, y, r, r)
  c:rim(m, L.reed.edge)
  m:each(function(xx, yy)
    local d = (xx - x) + (yy - y)
    local col = d < -r * .6 and L.reed.hi or (d > r * .6 and L.reed.shade or L.reed.base)
    if (xx + yy * 2) % 3 == 0 then col = (d < 0) and L.reed.base or L.reed.deep end
    px(xx, yy, col)
  end)
  px(x, y, L.reed.deep)
  return m
end
-- a little pool with a peat bank (bank ring 2 px), still water
local function pool(pts, seed, dark, cutM)
  local m = poly(pts)
  if cutM then m:cut(cutM) end
  rimOf(m, L.peat)
  local bank = m:grow(2):cut(m)
  bank:each(function(x, y) local v = hash(x, y, seed) px(x, y, v < .4 and L.peat.base or (v < .65 and L.peat.hi or L.sedgeGround.base)) end)
  F.water(m, L.water, { dark = dark })
  return m
end
-- a thick straight member (beam / post) between two points, lit on its upper-left side
local function member(m, r)
  m:each(function(x, y)
    local h = r.base
    if not m:has(x - 1, y) or not m:has(x, y - 1) then h = r.hi
    elseif not m:has(x + 1, y) or not m:has(x, y + 1) then h = r.shade end
    if hash(x // 2, y // 3, 17) < .12 then h = r.deep end
    px(x, y, h)
  end)
end

---------------------------------------------------------------- wattle hurdles on a flood bank along the horizon
local function hurdles(x0, x1, yb, h, seed)
  local bank = poly{ { x0 - 4, yb + 1 }, { x0, yb - 3 }, { x1, yb - 3 }, { x1 + 4, yb + 1 } }
  rimOf(bank, L.sedgeGround) part(bank, L.sedgeGround, { nopop = true })
  bank:each(function(x, y) if y == yb - 3 then px(x, y, L.sedgeGround.hi) elseif hash(x, y, seed) < .2 then px(x, y, L.peat.base) end end)
  local m = HP.mask()
  local stakes = HP.mask()
  for x = x0, x1, 10 do stakes:add(rect(x, yb - h - 3 - floor(hash(x, 1, seed) * 2), x + 1, yb - 3)) end
  local weave = rect(x0, yb - h - 1, x1 + 1, yb - 4)
  m:add(weave):add(stakes)
  rimOf(m, WB)
  -- woven withies: 2 px rows bowing in and out between the stakes
  weave:each(function(x, y)
    local row = (y - (yb - h - 1)) // 2
    local seg = (x - x0) // 10
    local front = (row + seg) % 2 == 0
    local k = (y - (yb - h - 1)) % 2
    local h2
    if front then h2 = k == 0 and WB.hi or WB.base else h2 = k == 0 and WB.shade or WB.deep end
    if hash(x // 3, y, seed + 2) < .1 then h2 = WB.shade end
    px(x, y, h2)
  end)
  stakes:each(function(x, y) px(x, y, (x % 2 == 0) and T.hi or T.shade) end)
  stakes:each(function(x, y) if not stakes:has(x, y - 1) then px(x, y, T.edge) end end)
  -- reed tufts and sedge along the foot
  for x = x0, x1, 5 do
    if hash(x, 4, seed) < .6 then F.sedge(x + floor(hash(x, 5, seed) * 3), yb, 3 + floor(hash(x, 6, seed) * 2), hash(x, 7, seed) < .5 and L.reed or L.reedGreen) end
  end
end
F.depth(1)
hurdles(118, 200, 125, 7, 31)
hurdles(280, 372, 125, 7, 37)
F.mist(120, 196, 118, 123, 64, .45)
F.mist(284, 370, 118, 123, 65, .45)

---------------------------------------------------------------- the stilted bird-hide watchtower
local function tower()
  F.depth(2)
  -- the pool the stilts stand in, a boardwalk landing at the causeway's end
  local tp = pool({ { 186, 127 }, { 196, 119 }, { 226, 116 }, { 254, 116 }, { 284, 119 }, { 298, 126 }, { 290, 134 }, { 192, 134 } }, 51, false, F.roadM)
  F.water(tp:copy():clip(rect(208, 116, 272, 134)), L.water, { dark = true })
  -- reflections of the tower legs going down into the water
  for _, sx in ipairs({ 214, 228, 252, 264 }) do for y = 128, 133, 2 do if tp:has(sx, y) then px(sx, y, L.water.deep) px(sx + 1, y, L.water.shade) end end end
  for y = 118, 122, 2 do for x = 214, 266 do if tp:has(x, y) and hash(x // 3, y, 52) < .4 then px(x, y, L.water.deep) end end end

  -- back stilts (darker) and their braces
  local function xA(y) return 214 + (129 - y) * 10 / 61 end  -- front left post
  local function xD(y) return 265 - (129 - y) * 10 / 61 end  -- front right post
  local back = line({ { 229, 129 }, { 234, 68 } }, 2):add(line({ { 251, 129 }, { 246, 68 } }, 2))
  back:add(line({ { 230, 112 }, { 250, 90 } })):add(line({ { 233, 88 }, { 247, 72 } }))
  rimOf(back, T) fill(back, T.shade) back:each(function(x, y) if hash(x, y // 3, 5) < .3 then px(x, y, T.deep) end end)
  -- front stilts (3 px), walings and zig-zag diagonals
  local front = line({ { 214, 129 }, { 224, 68 } }, 3):add(line({ { 265, 129 }, { 255, 68 } }, 3))
  local braces = HP.mask()
  local bays = { 70, 88, 108, 126 }
  for i = 2, 4 do local y = bays[i] braces:add(rect(floor(xA(y)) + 2, y - 1, floor(xD(y)), y)) end
  -- knee braces under each waling (and under the deck) at both stilts
  for _, y in ipairs({ 70, 88, 108 }) do
    braces:add(line({ { xA(y) + 9, y + 1 }, { xA(y + 8) + 2, y + 8 } }, 2))
    braces:add(line({ { xD(y) - 8, y + 1 }, { xD(y + 8) - 1, y + 8 } }, 2))
  end
  rimOf(union(front, braces), T)
  member(braces, T)
  member(front, WB)
  front:each(function(x, y) if y >= 124 then px(x, y, T.deep) elseif y >= 121 then px(x, y, L.moss.shade) end end) -- wet feet, green waterline
  for _, x in ipairs({ 214, 265 }) do hline(x - 2, x + 3, 125, L.water.hi) end
  -- rope lashings where the walings meet the stilts
  for i = 2, 4 do local y = bays[i]
    for _, x in ipairs({ floor(xA(y)) + 1, floor(xD(y)) }) do px(x, y - 2, L.reed.hi) px(x, y - 1, L.reed.shade) px(x + 1, y - 2, L.reed.base) px(x, y + 1, L.reed.deep) end
  end
  -- an eel trap hanging from the lowest waling, a lantern on the middle one
  local et = poly{ { 256, 108 }, { 260, 108 }, { 259, 118 }, { 257, 118 } }
  rimOf(et, L.reed) part(et, L.reed, { nopop = true }) et:each(function(x, y) if (x + y) % 2 == 0 then px(x, y, L.reed.shade) end end)
  vline(258, 107, 107, T.edge)

  -- zig-zag stair: lower flight up-left from the landing, a mid landing, upper flight up-right to the trap
  local function flight(x0, y0, x1, y1)
    local m = line({ { x0, y0 }, { x1, y1 } }, 3)
    local rail = line({ { x0, y0 - 7 }, { x1, y1 - 7 } })
    rimOf(union(m, rail), T)
    fill(m, B.base)
    m:each(function(x, y)
      if not m:has(x, y - 1) then px(x, y, B.hi) elseif not m:has(x, y + 1) then px(x, y, T.shade) end
      if (x + y) % 3 == 0 and m:has(x, y - 1) and m:has(x, y + 1) then px(x, y, B.deep) end -- treads
    end)
    rail:each(function(x, y) px(x, y, T.hi) end)
    local dx = (x1 - x0) / math.abs(x1 - x0)
    for k = 0, 2 do local t = k / 2 local xx, yy = floor(x0 + (x1 - x0) * t), floor(y0 + (y1 - y0) * t) vline(xx, yy - 6, yy - 1, T.base) end
  end
  flight(252, 120, 228, 97)
  local landing = rect(216, 95, 234, 98)
  rimOf(landing, T) part(landing, B, { nopop = true }) hline(216, 234, 95, B.hi) hline(216, 234, 98, T.deep)
  flight(230, 95, 252, 71)
  -- a gnome halfway up the lower flight
  F.gnome(241, 109, { small = true, hat = L.awnA, coat = L.leaf, arm = "up", noShadow = true, flip = true })
  -- the landing at the causeway end
  local land = rect(226, 122, 256, 127)
  F.boardwalk(land, true, 21)
  hline(226, 256, 127, B.deep)
  for _, x in ipairs({ 226, 255 }) do local p = rect(x, 118, x + 1, 129) rimOf(p, T) part(p, T, { nopop = true, noshade = true }) px(x, 118, T.hi) end
  -- a punt moored at the landing, painter rope to the post
  F.punt(258, 284, 131, T)
  line({ { 256, 119 }, { 262, 127 } }):each(function(x, y) px(x, y, L.reed.shade) end)
  -- reed beds round the feet
  F.reeds(196, 208, 130, 11, 41, { cattails = 2, green = true })
  F.reeds(276, 292, 129, 12, 42, { cattails = 2 })
  F.lily(204, 131, false, "white") F.lily(286, 129, false)

  -- gallery deck, joist ends
  local deck = rect(204, 66, 276, 70)
  rimOf(deck, T) part(deck, B, { nopop = true }) hline(204, 276, 66, B.hi) hline(204, 276, 70, B.deep)
  for x = 206, 274, 5 do px(x, 69, T.deep) px(x, 68, B.shade) end
  -- banner hanging under the deck: a gold heron on teal
  local ban = poly{ { 216, 71 }, { 226, 71 }, { 226, 92 }, { 221, 88 }, { 216, 92 } }
  rimOf(ban, L.accent) part(ban, L.accent)
  F.sprite({ "..gg.", ".gg..", "..g..", "..gg.", ".ggg.", "..g..", "..g.." }, 219, 75, { g = L.gold.base }, { rim = false })
  px(222, 75, L.gold.hi) px(218, 76, L.produce.base)

  -- the hide: reed-wattle walls in a timber frame, a long viewing slit, a lamp window
  local cab = rect(220, 44, 260, 65)
  rimOf(cab, T)
  cab:each(function(x, y)
    local h = (x % 2 == 0) and L.reed.base or L.reed.shade
    if (x % 2 == 0) and y % 7 == 3 then h = L.reed.hi end
    if hash(x, y // 4, 19) < .1 then h = L.reed.deep end
    if x > 252 then h = (x % 2 == 0) and L.reed.shade or L.reed.deep end -- the right side in shade
    px(x, y, h)
  end)
  for _, y in ipairs({ 49, 57 }) do hline(220, 260, y, T.base) hline(221, 259, y + 1, T.deep) end
  local posts = union(rect(220, 44, 221, 65), rect(259, 44, 260, 65), rect(240, 44, 240, 65))
  part(posts, T, { nopop = true, noshade = true }) vline(220, 44, 65, T.hi)
  -- viewing slit with a propped shutter
  local slit = rect(223, 51, 257, 54)
  fill(slit, L.timber.edge) hline(223, 257, 54, T.deep)
  vline(240, 51, 54, T.base)
  -- through the slit: the lookout's red hat, eyes, and a brass spyglass poking out
  fill(rect(230, 51, 236, 52), L.awnA.base) px(230, 51, L.awnA.hi)
  px(231, 53, L.skin.base) px(232, 53, L.timber.edge) px(233, 53, L.skin.base) px(234, 53, L.timber.edge) px(235, 53, L.skin.base)
  local glass = rect(246, 52, 262, 53)
  rimOf(glass, L.gold) fill(glass, L.gold.base) hline(246, 262, 52, L.gold.hi) fill(rect(259, 51, 263, 54), L.gold.shade) px(263, 52, L.water.hi)
  px(245, 52, L.awnB.base) px(244, 53, L.awnB.shade) -- a second lookout's beard
  F.window(224, 59, 229, 63, T)
  -- a lifebuoy on the right wall
  local buoy = c:ellipse(251, 60, 4, 4):cut(c:ellipse(251, 60, 1, 1))
  rimOf(buoy, L.awnA) fill(buoy, L.awnA.base)
  buoy:each(function(x, y) if (x - 251) * (y - 60) > 0 then px(x, y, L.awnB.base) end if x - 251 + y - 60 < -4 then px(x, y, (x - 251) * (y - 60) > 0 and L.awnB.hi or L.awnA.hi) end end)
  fill(c:ellipse(251, 60, 1, 1), L.reed.deep)

  -- the sentry on the gallery, ringing the alarm bell on its bracket
  F.gnome(212, 65, { small = true, hat = L.awnA, coat = L.accent, arm = "up", noShadow = true, flip = true })
  local arm = rect(198, 46, 219, 47):add(line({ { 210, 47 }, { 219, 55 } }))
  rimOf(arm, T) part(arm, T, { nopop = true, noshade = true }) hline(198, 219, 46, T.hi)
  local bellm = poly{ { 200, 50 }, { 206, 50 }, { 208, 58 }, { 198, 58 } }:add(c:rrect(200, 48, 206, 52, 2))
  rimOf(bellm, L.gold) part(bellm, L.gold, { nopop = true })
  bellm:each(function(x, y) if x <= 201 and y < 57 then px(x, y, L.gold.hi) end end)
  hline(198, 208, 58, L.gold.deep) hline(199, 207, 55, L.gold.shade) vline(203, 59, 60, IR.base)
  vline(203, 47, 48, T.edge)
  -- sound lines
  for k = 0, 2 do px(195 - k, 50 + k * 3, L.awnB.hi) px(194 - k, 51 + k * 3, L.awnB.hi) end

  -- railing in front of the hide
  local rail = rect(204, 59, 276, 59):add(rect(204, 63, 276, 63))
  for x = 204, 276, 6 do rail:add(rect(x, 59, x + 1, 65)) end
  rail:cut(rect(222, 60, 230, 64)):cut(rect(246, 56, 256, 64)):cut(rect(209, 59, 215, 64))
  rimOf(rail, T) part(rail, T, { nopop = true, noshade = true }) hline(204, 276, 59, T.hi)

  -- wide conical water-reed thatch with a sedge crown and a deep eave lip
  local roofM = poly{ { 198, 46 }, { 240, 30 }, { 282, 46 }, { 278, 49 }, { 202, 49 } }
  rimOf(roofM, L.roof)
  part(roofM, L.roof, { sep = true })
  F.thatch(roofM, L.roof, 30, 240)
  roofM:each(function(x, y)
    local d = y - 30
    if d >= 0 and d < 7 then
      local h = (d >= 6 - ((x // 3) % 2)) and L.roof2.deep or ((x + y) % 4 == 0 and L.roof2.hi or (x < 240 and L.roof2.base or L.roof2.shade))
      if d == 2 and x % 5 == 0 then h = T.hi end
      px(x, y, h)
    end
    if y >= 48 then px(x, y, (x + y) % 3 == 0 and L.roof.deep or L.roof.shade) end -- the thick cut eave
    if x > 248 and y > 30 and y < 48 and (x + y) % 2 == 0 then px(x, y, L.roof.shade) end
  end)
  line({ { 200, 45 }, { 238, 31 } }):each(function(x, y) if roofM:has(x, y) then px(x, y, L.roof.hi) end end)
  F.moss(roofM:copy():clip(rect(200, 36, 280, 47)), .05, 83)
  -- a dormer peep-hole in the thatch
  local dorm = c:ellipse(240, 41, 3, 2)
  fill(dorm, L.timber.edge) hline(237, 243, 39, L.roof.deep) px(239, 41, G.shade) px(240, 41, G.base)

  -- beacon: an iron basket on a short pole at the apex, burning
  vline(239, 25, 30, IR.deep) vline(240, 25, 30, IR.base)
  local basket = poly{ { 232, 19 }, { 248, 19 }, { 245, 25 }, { 235, 25 } }
  rimOf(basket, IR) part(basket, IR)
  for x = 234, 246, 3 do vline(x, 20, 24, IR.deep) end hline(233, 247, 19, IR.hi)
  local fire = poly{ { 232, 19 }, { 234, 11 }, { 236, 14 }, { 239, 5 }, { 242, 13 }, { 245, 9 }, { 248, 19 } }
  fill(fire, G.shade) fill(poly{ { 235, 19 }, { 239, 8 }, { 245, 19 } }, G.base) fill(poly{ { 238, 19 }, { 240, 12 }, { 242, 19 } }, G.hi)
  for i = 0, 5 do px(228 + floor(hash(i, 1, 2) * 26), 13 + floor(hash(i, 2, 2) * 6), G.hi) end
  -- warm glow on the thatch near the beacon
  roofM:each(function(x, y) if y < 37 and math.abs(x - 240) < 8 and (x + y) % 2 == 0 then px(x, y, L.roof.hi) end end)
  -- windsock on a pole at the right end of the gallery
  local pole = rect(271, 37, 272, 65)
  rimOf(pole, T) part(pole, T, { nopop = true, noshade = true }) px(271, 36, L.gold.hi)
  local sock = poly{ { 273, 38 }, { 292, 42 }, { 292, 46 }, { 273, 47 } }
  rimOf(sock, L.awnA)
  sock:each(function(x, y)
    local band = ((x - 273) // 5) % 2 == 0
    local r = band and L.awnA or L.awnB
    local h = (y <= 39 + (x - 273) // 5) and r.hi or (y >= 46 and r.shade or r.base)
    px(x, y, h)
  end)
  vline(273, 38, 47, IR.base)

end
-- flanking trees at a distance: an alder on the left, a pollard on the right
F.depth(1)
F.tree(180, 124, 40, 1)
F.tree(304, 124, 40, 3)
tower()

-- a heron wading in the tower pool
F.depth(2)
F.heron(198, 131, false)
for xx = 192, 206 do if hash(xx, 5, 59) < .6 then px(xx, 132, L.water.hi) end end

---------------------------------------------------------------- willow poles with pennants lining the causeway
local function banner(x, yb, s, r)
  local h = floor(30 * s)
  local pole = rect(x, yb - h, x + math.max(1, floor(s)), yb)
  local fl = poly{ { x + 1, yb - h + 1 }, { x + 1 + floor(9 * s), yb - h + 1 }, { x + 1 + floor(9 * s), yb - h + floor(16 * s) }, { x + 1 + floor(4.5 * s), yb - h + floor(12 * s) }, { x + 1, yb - h + floor(16 * s) } }
  F.shadow(x, x + 2, yb, floor(4 * s), 2)
  rimOf(union(pole, fl), T)
  part(pole, WB, { nopop = true, noshade = true })
  pole:each(function(xx, y) if hash(y // 3, xx, 3) < .2 then px(xx, y, WB.deep) end end)
  part(fl, r, { nopop = s < 1 })
  if s >= 1 then
    F.sprite({ ".gg", "gg.", ".g.", ".gg", "g.." }, x + floor(4 * s) - 1, yb - h + 3, { g = L.gold.base }, { rim = false })
  end
  -- a reed tassel on the top
  px(x, yb - h - 1, L.plume.base) px(x + 1, yb - h - 2, L.plume.hi)
  F.sedge(x, yb, math.max(3, floor(5 * s)), L.reedGreen)
end
for _, p in ipairs({ { 140, .55 }, { 166, .8 }, { 206, 1.2 } }) do
  local y, s = p[1], p[2]
  banner(floor(F.xl(y)) - floor(14 * s) - 4, y, s, L.awnA)
  banner(floor(F.xr(y)) + floor(6 * s), y, s, L.accent)
end

---------------------------------------------------------------- left: stilted weatherboard guardhouse, rack, dummy
F.depth(1)
F.tree(30, 140, 40, 3)
F.tree(158, 134, 38, 1)
F.depth(2)
F.tree(10, 170, 46, 0)
F.depth(3)
-- the deck the guardhouse stands on, and its stilt stubs in the mud
F.shadow(52, 156, 177, 10, 4)
local gst = HP.mask()
for x = 52, 152, 12 do gst:add(rect(x, 171, x + 1, 177)) end
rimOf(gst, T) gst:each(function(x, y) px(x, y, y > 174 and T.deep or (x % 2 == 0 and T.base or T.shade)) end)
fill(rect(50, 176, 156, 177), L.peat.shade)
local gdeck = rect(46, 167, 158, 171)
F.boardwalk(gdeck, true, 23)
hline(46, 158, 171, B.deep)
local gt, gcx, gwall, groof = F.building{ x0 = 54, x1 = 150, yb = 166, wh = 38, rh = 26, wall = L.wall2, roof = L.roof, chimney = true, noFrame = true, noShadow = true }
F.planks(gwall:copy():clip(rect(54, gt + 2, 150, 166)), L.wall2, 4, false, 17)
local gc = union(rect(54, gt, 56, 166), rect(148, gt, 150, 166))
part(gc, B, { nopop = true, noshade = true })
gwall:each(function(x, y) if y > 162 and hash(x // 2, y, 85) < .4 then px(x, y, L.moss.shade) end end)
F.moss(groof, .04, 84)
F.window(98, 110, 104, 116, T) -- gable window
F.door(94, 140, 108, 165, T, true)
F.smoke(141, 102, 6, .5, 2)
local wp = rect(17, 149, 18, 172) rimOf(wp, T) part(wp, T, { nopop = true, noshade = true })
F.washing(18, 150, 54, 146, { { "sock", L.awnA }, { "shirt", L.accent }, { "sock", L.roof } }, 5)
F.window(66, 138, 74, 145, T) F.window(126, 138, 134, 145, T)
-- shield over the door: a heron on teal
local sh = poly{ { 95, 126 }, { 107, 126 }, { 107, 132 }, { 101, 137 }, { 95, 132 } }
rimOf(sh, L.accent) part(sh, L.accent)
F.sprite({ "..gg.", ".gg..", "..g..", ".ggg.", "..g.." }, 99, 128, { g = L.awnB.hi }, { rim = false }) px(98, 129, L.produce.base)
-- eel traps (wicker cones) leaning by the door, a coiled net on a peg
for _, ex in ipairs({ 112, 118 }) do
  local t = poly{ { ex, 152 }, { ex + 5, 152 }, { ex + 4, 166 }, { ex + 1, 166 } }
  rimOf(t, L.reed) part(t, L.reed, { nopop = true })
  t:each(function(x, y) if (x + y) % 2 == 0 then px(x, y, L.reed.shade) end if y % 4 == 0 then px(x, y, L.reed.deep) end end)
  fill(c:ellipse(ex + 2, 152, 2, 1), L.reed.deep)
end
local net = poly{ { 78, 148 }, { 90, 148 }, { 88, 162 }, { 84, 164 }, { 80, 162 } }
rimOf(net, L.board) net:each(function(x, y) px(x, y, ((x + y) % 3 == 0 or (x - y) % 3 == 0) and B.shade or L.wall2.shade) end)
px(84, 147, T.edge) hline(80, 88, 149, L.reed.base) px(82, 160, L.produce.base) px(86, 156, L.produce.base) -- cork floats
-- a stack of peat turves under the right window
for row = 0, 3 do for k = 0, 4 - row do
  local tx, ty = 122 + k * 6 + row * 3, 164 - row * 3
  local tm = rect(tx, ty - 2, tx + 5, ty) rimOf(tm, L.peat) fill(tm, L.peat.base) hline(tx, tx + 5, ty - 2, L.peat.hi) px(tx + 5, ty, L.peat.deep)
end end

local function rack(x0, yb)
  local posts = rect(x0, yb - 26, x0 + 2, yb):add(rect(x0 + 40, yb - 26, x0 + 42, yb))
  local rails = rect(x0, yb - 24, x0 + 42, yb - 23):add(rect(x0, yb - 8, x0 + 42, yb - 7))
  F.shadow(x0, x0 + 42, yb, 8, 3)
  rimOf(union(posts, rails), T)
  for k = 0, 4 do
    local x = x0 + 6 + k * 7
    vline(x, yb - 34, yb - 1, B.base) vline(x + 1, yb - 34, yb - 1, B.shade)
    if k == 2 then -- a boat hook
      vline(x + 1, yb - 42, yb - 35, IR.base) px(x, yb - 42, IR.hi) px(x + 2, yb - 41, IR.base) px(x + 3, yb - 40, IR.base) px(x + 3, yb - 39, IR.shade)
      px(x - 1, yb - 38, IR.hi) px(x - 2, yb - 37, IR.base)
    elseif k % 2 == 1 then -- a three-tined eel leister
      hline(x - 2, x + 3, yb - 35, IR.base)
      for _, tx in ipairs({ x - 2, x, x + 3 }) do vline(tx, yb - 41, yb - 36, IR.hi) px(tx, yb - 42, IR.shade) end
      px(x + 1, yb - 36, IR.shade)
    else
      local tip = poly{ { x - 1, yb - 34 }, { x + 1, yb - 40 }, { x + 3, yb - 34 } } fill(tip, IR.hi) px(x + 2, yb - 34, IR.shade)
      px(x - 1, yb - 33, L.awnA.base) px(x + 2, yb - 33, L.awnA.shade) -- a red binding
    end
  end
  part(posts, T, { nopop = true, noshade = true }) part(rails, T, { nopop = true, noshade = true })
  F.moss(posts:copy():clip(rect(x0, yb - 8, x0 + 42, yb)), .3, 86)
  -- woven wicker shields leaning, painted bosses
  for k, r in ipairs({ L.awnA, L.accent }) do
    local x = x0 + 50 + k * 13
    local m = c:ellipse(x, yb - 8, 7, 8)
    rimOf(m, L.reed) fill(m, L.reed.base)
    m:each(function(xx, yy)
      local d = math.sqrt((xx - x) ^ 2 + ((yy - yb + 8) * 7 / 8) ^ 2)
      if floor(d) % 2 == 0 then px(xx, yy, ((xx + yy) % 2 == 0) and L.reed.shade or L.reed.base) end
      if (xx - x) + (yy - yb + 8) < -6 then px(xx, yy, L.reed.hi) elseif (xx - x) + (yy - yb + 8) > 7 then px(xx, yy, L.reed.deep) end
    end)
    local boss = c:ellipse(x, yb - 8, 3, 3) rimOf(boss, r) part(boss, r, { nopop = true }) px(x - 1, yb - 9, r.hi)
    c:ellipse(x, yb - 8, 5, 6):edge():each(function(xx, yy) if (xx + yy) % 2 == 0 then px(xx, yy, r.shade) end end)
  end
end
rack(60, 200)
local function dummy(x, yb)
  local post = rect(x - 1, yb - 30, x + 1, yb):add(rect(x - 12, yb - 22, x + 12, yb - 20))
  local body = poly{ { x - 6, yb - 26 }, { x + 6, yb - 26 }, { x + 8, yb - 8 }, { x - 8, yb - 8 } }
  local head = c:ellipse(x, yb - 32, 5, 5)
  F.shadow(x - 6, x + 8, yb, 6, 2)
  rimOf(union(post, body, head), T)
  part(post, T, { nopop = true, noshade = true })
  -- a reed-sheaf body: stalk stripes, two bands, a ragged hem
  part(body, L.reed, { nopop = true })
  body:each(function(xx, yy) if (xx - x) % 2 == 0 then px(xx, yy, xx < x and L.reed.hi or L.reed.shade) end end)
  for _, by in ipairs({ yb - 22, yb - 13 }) do hline(x - 7, x + 7, by, T.deep) hline(x - 6, x + 6, by - 1, T.base) end
  for xx = x - 8, x + 8, 2 do px(xx, yb - 7, L.reed.shade) end
  -- a sacking head with a painted face
  part(head, L.plaster)
  fill(rect(x - 2, yb - 33, x - 1, yb - 32), T.edge) fill(rect(x + 2, yb - 33, x + 3, yb - 32), T.edge)
  hline(x - 3, x + 3, yb - 29, L.plaster.deep)
  -- dented pot helmet with a reed plume
  local hel = c:ellipse(x, yb - 37, 6, 3):clip(rect(x - 7, yb - 41, x + 7, yb - 36)) fill(hel, IR.base) hline(x - 6, x + 6, yb - 36, IR.deep) px(x - 3, yb - 39, IR.hi)
  for k = 0, 4 do px(x + 2 + k, yb - 41 - k, L.plume.base) px(x + 3 + k, yb - 41 - k, L.plume.shade) end
  px(x + 7, yb - 46, L.plume.hi)
end
dummy(178, 208)

---------------------------------------------------------------- archery range, bottom-left: coiled-reed butts, a heron pool
local function target(x, yb, s)
  local legs = line({ { x - 6 * s, yb }, { x, yb - 22 * s } }, 2):add(line({ { x + 6 * s, yb }, { x, yb - 22 * s } }, 2))
  local cy = floor(yb - 16 * s)
  local R = floor(10 * s)
  local face = c:ellipse(x, cy, R, R)
  F.shadow(floor(x - 6 * s), floor(x + 8 * s), yb, 6, 2)
  rimOf(union(legs, face), T)
  part(legs, T, { nopop = true, noshade = true })
  -- coiled reed rope: a spiral of bands, lit upper left
  face:each(function(xx, yy)
    local dx, dy = xx - x, yy - cy
    local d = math.sqrt(dx * dx + dy * dy)
    local a = math.atan(dy, dx)
    local band = floor(d + a / (2 * pi) * 2 + 10) % 2
    local h = band == 0 and L.reed.base or L.reed.shade
    if dx + dy < -R * .7 then h = band == 0 and L.reed.hi or L.reed.base elseif dx + dy > R * .8 then h = band == 0 and L.reed.shade or L.reed.deep end
    px(xx, yy, h)
  end)
  -- painted target face
  fill(c:ellipse(x, cy, floor(7 * s), floor(7 * s)), L.awnB.base)
  fill(c:ellipse(x, cy, floor(7 * s), floor(7 * s)):cut(c:ellipse(x, cy, floor(6 * s), floor(6 * s))), L.awnA.base)
  fill(c:ellipse(x, cy, floor(4 * s), floor(4 * s)):cut(c:ellipse(x, cy, floor(3 * s), floor(3 * s))), L.accent.base)
  fill(c:ellipse(x, cy, math.max(1, floor(2 * s)), math.max(1, floor(2 * s))), L.awnA.base) px(x - 1, cy - 1, L.awnA.hi)
  c:ellipse(x, cy, floor(5 * s), floor(5 * s)):each(function(xx, yy) if xx - x + yy - cy > 3 and (xx + yy) % 2 == 0 and c:get(xx, yy) == L.awnB.base then px(xx, yy, L.awnB.shade) end end)
  for k = 0, 1 do local ax, ay = floor(x - 2 + k * 5), floor(cy - 2 + k * 4) fill(line({ { ax, ay }, { ax - 6, ay + 3 } }), B.deep) px(ax - 6, ay + 3, L.awnB.hi) px(ax - 7, ay + 3, L.awnB.hi) end
  F.sedge(floor(x - 7 * s), yb + 1, 5) F.sedge(floor(x + 8 * s), yb + 1, 4, L.reed)
end
target(40, 252, 1.2) target(82, 244, .9)
-- a small pool between the butts and the archer, a heron fishing in it
pool({ { 94, 230 }, { 110, 222 }, { 128, 224 }, { 136, 234 }, { 130, 246 }, { 110, 250 }, { 96, 244 } }, 53)
F.heron(118, 240, false)
for xx = 110, 126 do if hash(xx, 3, 54) < .6 then px(xx, 241, L.water.hi) end end
F.lily(102, 236, true, "white") F.lily(126, 244, false) F.lily(100, 245, false, "yellow")
F.reeds(130, 140, 236, 14, 55, { cattails = 2, green = true })
F.frog(108, 249, true)
local _, ax, ay = F.gnome(150, 258, { hat = L.foliage, coat = L.roof2, arm = "out", flip = true })
fill(c:ellipse(ax - 1, ay, 2, 8):cut(c:ellipse(ax, ay, 1, 7)), T.base) vline(ax - 1, ay - 7, ay + 7, L.awnB.shade) -- bow
fill(line({ { ax - 1, ay }, { ax + 8, ay } }), B.deep) px(ax - 2, ay, IR.hi)
-- a wicker quiver basket of arrows
local qs = poly{ { 164, 252 }, { 172, 252 }, { 171, 261 }, { 165, 261 } }
rimOf(qs, L.reed) part(qs, L.reed, { nopop = true }) qs:each(function(x, y) if (x + y) % 2 == 0 then px(x, y, L.reed.shade) end if y % 3 == 0 then px(x, y, L.reed.deep) end end)
for k = 0, 2 do vline(166 + k * 2, 244, 251, B.deep) px(166 + k * 2, 243, L.awnB.hi) px(166 + k * 2, 244, L.awnA.base) end
-- sedge, marigolds and reeds along the left edge
for _, f in ipairs({ { 22, 216, 6 }, { 30, 212, 5 }, { 112, 214, 5 }, { 18, 262, 7 }, { 60, 262, 6 } }) do F.sedge(f[1], f[2], f[3]) px(f[1] - 1, f[2] - f[3] + 1, L.marigold.base) px(f[1] + 2, f[2] - f[3] + 2, L.marigold.hi) end
F.reeds(4, 16, 240, 20, 56, { cattails = 2 })
F.moss(F.rock(186, 262, 8, 6), .3, 88)
F.dragonfly(80, 222, L.accent) F.dragonfly(136, 218, L.apple, true)

---------------------------------------------------------------- right: boathouse in the mist, bell frame, loft, telescope
local function bell(x0, yb)
  local posts = rect(x0, yb - 40, x0 + 3, yb):add(rect(x0 + 34, yb - 40, x0 + 37, yb))
  local beam = rect(x0 - 4, yb - 44, x0 + 41, yb - 40)
  local braces = line({ { x0 + 3, yb - 32 }, { x0 + 10, yb - 40 } }):add(line({ { x0 + 34, yb - 32 }, { x0 + 27, yb - 40 } }))
  local b = poly{ { x0 + 13, yb - 34 }, { x0 + 24, yb - 34 }, { x0 + 27, yb - 18 }, { x0 + 10, yb - 18 } }:add(c:rrect(x0 + 13, yb - 38, x0 + 24, yb - 31, 3))
  F.shadow(x0, x0 + 40, yb, 8, 3)
  rimOf(union(posts, beam, b, braces), T)
  member(posts, WB) part(braces, T, { nopop = true, noshade = true }) part(beam, T) hline(x0 - 4, x0 + 41, yb - 44, T.hi)
  F.moss(posts:copy():clip(rect(x0, yb - 8, x0 + 37, yb)), .35, 90)
  -- a little reed-thatched hood over the beam with a sedge ridge
  local hood = poly{ { x0 - 7, yb - 43 }, { x0 + 18, yb - 54 }, { x0 + 44, yb - 43 } }
  rimOf(hood, L.roof) part(hood, L.roof, { sep = true }) F.thatch(hood, L.roof, yb - 54, x0 + 18)
  hood:each(function(x, y) if y <= yb - 51 then px(x, y, x < x0 + 18 and L.roof2.base or L.roof2.shade) end end)
  hline(x0 - 6, x0 + 43, yb - 43, L.roof.deep)
  part(b, L.gold) hline(x0 + 10, x0 + 27, yb - 19, L.gold.deep) hline(x0 + 12, x0 + 25, yb - 26, L.gold.shade)
  b:each(function(x, y) if x < x0 + 15 and y < yb - 21 and y > yb - 36 then px(x, y, L.gold.hi) end end)
  vline(x0 + 18, yb - 40, yb - 38, T.edge)
  fill(rect(x0 + 18, yb - 18, x0 + 19, yb - 15), IR.base)
  vline(x0 + 26, yb - 18, yb - 4, L.reed.shade) -- pull rope
  F.sedge(x0 + 1, yb + 1, 5) F.sedge(x0 + 37, yb + 1, 6, L.reed)
end
F.depth(1)
F.tree(352, 136, 40, 1)
F.tree(446, 142, 54, 0)
-- the boathouse: tarred boards, reed thatch, a dark boat bay over a strip of water, a punt's bow nosing out
local bw = rect(360, 140, 432, 150)
F.water(bw, L.water)
local st, scx, swall, sroof = F.building{ x0 = 368, x1 = 424, yb = 141, wh = 18, rh = 16, wall = TAR, roof = L.roof2, noFrame = true, noAttic = true, noShadow = true, ridge = L.timber }
F.planks(swall:copy():clip(rect(368, st + 2, 424, 141)), TAR, 4, true, 9)
F.moss(sroof, .08, 93)
local bay = rect(384, 127, 408, 141)
fill(bay, L.timber.edge) fill(rect(385, 128, 407, 141), "#2e3432")
F.punt(388, 414, 146, T)
F.stilts({ 368, 380, 412, 422 }, 142, 150, 146)
F.window(372, 130, 377, 135, T) F.window(414, 130, 419, 135, T)
F.reeds(430, 462, 150, 12, 92, { cattails = 1 })
F.mist(330, 470, 146, 150, 66, .4)
F.depth(2)
-- a stack of reed beacon bundles waiting by the bell, a reed hook
F.shadow(346, 382, 174, 6, 3)
for row = 0, 3 do
  for k = 0, 3 - row do
    local lx, ly = 348 + k * 9 + row * 4, 170 - row * 7
    local side = rect(lx, ly - 3, lx + 8, ly + 3)
    rimOf(side, L.reed) part(side, L.reed, { nopop = true })
    side:each(function(x, y) if y % 2 == 0 then px(x, y, L.reed.hi) end end)
    vline(lx + 5, ly - 3, ly + 3, T.deep)
  end
end
for row = 0, 3 do for k = 0, 3 - row do bundleEnd(348 + k * 9 + row * 4, 170 - row * 7, 3) end end
line({ { 390, 174 }, { 384, 151 } }):each(function(x, y) px(x, y, B.base) end)
c:rim(line({ { 384, 151 }, { 378, 152 }, { 377, 156 } }), IR.edge) line({ { 384, 151 }, { 378, 152 }, { 377, 156 } }):each(function(x, y) px(x, y, IR.hi) end)
bell(300, 196)
local _, bx, by = F.gnome(334, 206, { hat = L.produce, coat = L.lav, arm = "up", flip = true })
F.depth(3)
-- the right pool: a heron, lilies, reeds
local rp = pool({ { 396, 208 }, { 420, 202 }, { 452, 202 }, { 476, 208 }, { 474, 222 }, { 448, 228 }, { 412, 226 }, { 398, 220 } }, 57)
F.heron(456, 222, true)
for xx = 448, 466 do if hash(xx, 2, 84) < .6 then px(xx, 223, L.water.hi) end end
F.lily(414, 216, true, "white") F.lily(432, 222, false, "yellow") F.lily(408, 210, false)
F.reeds(394, 404, 214, 16, 58, { cattails = 2, green = true })
F.goose(430, 212, false, true)
local function loft(x, yb)
  local post = rect(x - 1, yb - 40, x + 1, yb)
  local box = rect(x - 12, yb - 58, x + 12, yb - 40)
  local roofm = poly{ { x - 15, yb - 57 }, { x, yb - 68 }, { x + 15, yb - 57 } }
  F.shadow(x - 2, x + 4, yb, 6, 2)
  rimOf(union(post, box, roofm), T)
  member(post, WB)
  part(box, L.wall2) F.planks(box, L.wall2, 4, true, 19)
  part(roofm, L.roof, { sep = true }) F.thatch(roofm, L.roof, yb - 68, x)
  roofm:each(function(xx, yy) if yy <= yb - 65 then px(xx, yy, xx < x and L.roof2.base or L.roof2.shade) end end)
  hline(x - 15, x + 15, yb - 57, L.roof.deep)
  for k = 0, 2 do local hx = x - 9 + k * 7 fill(c:rrect(hx, yb - 54, hx + 4, yb - 48, 2), T.edge) hline(hx - 1, hx + 5, yb - 47, B.base) px(hx - 1, yb - 47, B.hi) end
  hline(x - 12, x + 12, yb - 44, L.wall2.deep)
  -- a strut and a little landing board
  line({ { x, yb - 30 }, { x - 10, yb - 40 } }):each(function(xx, yy) px(xx, yy, T.base) end)
  F.moss(post:copy():clip(rect(x - 1, yb - 10, x + 1, yb)), .4, 95)
  for _, p in ipairs({ { x - 6, yb - 63 }, { x + 7, yb - 61 } }) do local m = c:ellipse(p[1], p[2], 3, 2) fill(m, S.base) px(p[1] - 2, p[2] - 2, S.hi) px(p[1] - 3, p[2] - 1, L.gold.base) end
  -- quirk: the carrier pigeon landing, wings up, a cream scroll tied with a red ribbon to its leg, in a red gnome hat
  local x0, y0 = x - 7, yb - 86
  F.sprite({
    "K............K",
    "KWw........wWK",
    ".KWw......wWK.",
    "..KWw....wWK..",
    "...KWwwggWK...",
    ".....wggggey..",
    "....gggPQgg...",
    "...ggggPQg....",
    ".TTgggggg.....",
    "TT..gggg......",
    ".....o.o......",
    "....sZRs......",
    "....sZZs......",
  }, x0, y0, { K = S.deep, W = S.hi, w = S.base, g = S.base, e = L.produce.base, y = L.gold.hi, P = "#7cc0a0", Q = "#b48ac8",
    T = S.shade, o = L.apple.base, s = L.awnB.hi, Z = L.awnB.shade, R = L.awnA.base })
  F.sprite({ "....r.", "...Rr.", "..RRr.", ".RRRr.", "hhhhhh" }, x0 + 5, y0, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep })
  px(x0 + 7, y0 + 3, L.awnA.hi) px(x0 + 8, y0 + 2, L.awnA.hi)
end
loft(440, 196)
-- telescope on a tripod with a gnome lookout
local tri = line({ { 362, 214 }, { 370, 196 } }):add(line({ { 378, 214 }, { 370, 196 } })):add(line({ { 370, 214 }, { 370, 196 } }))
local tube = line({ { 362, 198 }, { 384, 186 } }, 3)
rimOf(union(tri, tube), T) fill(tri, WB.base) part(tube, L.gold) fill(rect(382, 184, 386, 188), L.gold.shade) px(362, 198, L.water.hi)
hline(370, 373, 192, L.gold.deep)
F.gnome(354, 218, { hat = L.lav, coat = L.awnA, arm = "out" })
F.sedge(366, 216, 4) F.sedge(379, 216, 5, L.reed)
-- reed faggots for the beacon, crates, a barrel, a coil of rope
for k = 0, 2 do
  local x = 300 + k * 18
  local m = rect(x, 228, x + 14, 236) rimOf(m, L.reed) part(m, L.reed, { nopop = true })
  m:each(function(xx, y) if y % 2 == 0 then px(xx, y, L.reed.hi) end end)
  fill(rect(x + 5, 228, x + 6, 236), T.deep)
  bundleEnd(x + 14, 232, 3)
  px(x, 230, L.plume.base) px(x - 1, 231, L.plume.hi) px(x, 233, L.plume.shade)
end
F.crate(300, 254, 18, 12) F.crate(320, 256, 18, 12) F.crate(310, 242, 18, 10, L.wall2)
F.barrel(346, 258, T, 12)
local coil = c:ellipse(362, 262, 6, 3)
rimOf(coil, L.reed) fill(coil, L.reed.base) c:ellipse(362, 262, 3, 1):edge():each(function(x, y) px(x, y, L.reed.deep) end)
coil:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.reed.shade) end if y < 261 and x < 360 then px(x, y, L.reed.hi) end end)
-- sedge, marigolds and a reed clump on the right
for _, f in ipairs({ { 290, 214 }, { 352, 232 }, { 392, 226 }, { 286, 262 } }) do F.sedge(f[1], f[2], 6) px(f[1] - 1, f[2] - 5, L.marigold.base) px(f[1] + 2, f[2] - 4, L.marigold.hi) end
F.dragonfly(420, 196, L.accent, true)
-- guard with a spear on the causeway
local _, gx, gy = F.gnome(258, 242, { hat = L.roof2, coat = L.wall2, arm = "hold" })
fill(rect(gx + 6, 204, gx + 6, 242), B.shade) fill(poly{ { gx + 5, 204 }, { gx + 6, 197 }, { gx + 8, 204 } }, IR.hi) -- spear
px(gx + 5, 205, L.awnA.base) px(gx + 7, 205, L.awnA.shade)
-- the guard's dog, and a fish it has pinched
F.sprite({
  "e.......",
  "DDe.....",
  "DnDD....",
  ".DDDDDDt",
  ".DdDDDD.",
  ".d.d.d.d",
}, 272, 236, { e = T.shade, D = B.base, d = B.shade, n = T.edge, t = B.base })
F.sprite({ "s.ff.", "ssfff", "s.ff." }, 266, 238, { s = L.iron.shade, f = L.iron.hi })
F.depth(0)
-- a skein of geese and a heron flying far off
F.birds({ { 150, 40, 2 }, { 156, 43, 2 }, { 162, 46, 2 }, { 144, 43, 2 }, { 138, 46, 2 }, { 316, 52, 1 }, { 186, 70, 1 } })
F.sprite({ "......ww....", "wwwwwwwww...", "..wwwwwwwkYY", ".wwwww......", "..www......." }, 336, 64, { w = L.heron.base, k = L.heron.deep, Y = L.marigold.shade }, { rim = false })
F.finish()
