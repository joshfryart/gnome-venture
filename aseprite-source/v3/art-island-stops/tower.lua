-- tower.lua : "Watchtower" stop look, ISLAND (island_palm), 480x270 gate view.
-- Same composition and story as the Maplewold watchtower (art-2701-batch3/stops/opus3/tower.lua), re-cast for a
-- coral island. Road's end: a banded coral-stone LIGHTHOUSE (coral-red and lime-white bands) on a black lava
-- headland that juts into the lagoon with surf breaking round it; a lava corbel gallery with a bamboo railing, an
-- open driftwood lantern room with the signal fire blazing in an iron basket, a rust-tin cap whose smoke streams
-- off on the trade wind, frigatebirds riding the smoke. A tapa banner hangs off the gallery, a sentry waves, a
-- pennant flies. A lava drystone sea wall with coral coping and tiki torches runs off along the shore.
-- Left: a woven-pandanus guard fale on a lava footing (turtle-shell shield, conch horn, calabashes), a rack of fish
-- spears and woven shields, a coconut-husk training dummy with a giant-clam helmet, woven-mat archery targets.
-- Right: a coral-lime net store in the haze, a stack of husks for the beacon, a salvaged ship's bell on a bamboo
-- frame, a bamboo spyglass lookout, frond bundles, crates, a guard with a fish spear and his spotted pig.
-- Quirk: a brown booby with bright blue feet, in a red gnome hat, landing on the roost box with a scroll on its leg.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-island-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "tower", out = DIR, farTrees = { 24, 52, 100, 150, 340, 440 },
  treeLineGap = { 186, 294 }, clouds = { { 112, 42, 36 }, { 330, 32, 50 }, { 424, 66, 28 }, { 28, 82, 24 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local S, IR, G, T, LV, B = L.stone, L.iron, L.glow, L.timber, L.lava, L.board

-- local helpers ---------------------------------------------------------------------------
-- bamboo pole: lit left, node rings
local function bambooPole(m, r)
  r = r or B
  local bb = { m:bbox() }
  m:each(function(x, y)
    local h = r.base
    if not m:has(x - 1, y) then h = r.hi elseif not m:has(x + 1, y) then h = r.shade end
    if (y + floor(hash(bb[1], 0, 5) * 7)) % 7 == 0 then h = r.deep elseif (y + floor(hash(bb[1], 0, 5) * 7)) % 7 == 1 and h ~= r.shade then h = r.hi end
    px(x, y, h)
  end)
end
-- woven pandanus: alternating 3x3 blocks of horizontal and vertical strands
local function weave(m, r, o)
  o = o or {}
  r = r or L.rope
  m:each(function(x, y)
    local k = (x // 3 + y // 3) % 2
    local h
    if k == 0 then h = (y % 3 == 2) and r.shade or ((y % 3 == 0) and r.hi or r.base)
    else h = (x % 3 == 2) and r.deep or ((x % 3 == 0) and r.base or r.shade) end
    if o.lit and k == 0 and x < o.lit and y % 3 == 0 then h = r.hi end
    if hash(x, y, 141) < .03 then h = L.needle.base end -- frayed / sun-dried strand
    px(x, y, h)
  end)
end
-- faceted lava: lumpy blocks, each facet lit or shaded, with porous pits
local function lavaFacets(m, seed, light)
  m:each(function(x, y)
    local cx, cy = x // 5 + ((y // 4) % 2) * 3, y // 4
    local v = hash(cx, cy, seed)
    local fx, fy = x % 5, y % 4
    local h
    if v < .3 then h = LV.hi elseif v < .62 then h = LV.base elseif v < .88 then h = LV.shade else h = LV.deep end
    if fy == 3 and hash(cx, cy, seed + 1) < .6 then h = LV.deep end
    if fy == 0 and v < .62 then h = LV.hi end
    if fx == 0 and hash(cx, cy, seed + 2) < .45 then h = LV.edge end
    if hash(x, y, seed + 3) < .06 then h = LV.deep end
    if light and light(x, y) then h = (h == LV.deep or h == LV.edge) and LV.shade or LV.hi end
    px(x, y, h)
  end)
end
local function grass(x, y, s, r)
  r = r or L.mossGround
  vline(x, y - s, y, r.shade) px(x, y - s, r.hi)
  px(x - 1, y - s + 1, r.hi) px(x - 2, y - s + 2, r.base) px(x + 1, y - s + 1, r.base) px(x + 2, y - s + 2, r.deep)
  if s > 4 then vline(x - 2, y - 2, y, r.base) vline(x + 2, y - 3, y, r.deep) px(x - 3, y - 3, r.hi) px(x + 3, y - 4, r.shade) end
end
local function torch(x, yb, h)
  local pole = rect(x, yb - h, x + 1, yb)
  local cup = rect(x - 1, yb - h - 2, x + 2, yb - h)
  rimOf(union(pole, cup), T)
  bambooPole(pole) fill(cup, L.coconut.base) px(x - 1, yb - h - 2, L.coconut.hi) hline(x - 1, x + 2, yb - h, L.coconut.deep)
  px(x, yb - h - 3, G.base) px(x + 1, yb - h - 3, G.shade) px(x, yb - h - 4, G.hi) px(x + 1, yb - h - 5, G.base) px(x, yb - h - 6, G.hi)
end

---------------------------------------------------------------- lava sea wall along the shore
local function seawall(x0, x1, yb, h, seed)
  local m = rect(x0, yb - h, x1, yb)
  local merl = HP.mask()
  for x = x0, x1 - 5, 10 do merl:add(rect(x, yb - h - 3, x + 5, yb - h - 1)) end
  m:add(merl)
  F.shadow(x0, x1, yb, 4, 2)
  rimOf(m, LV)
  lavaFacets(m, seed, function(x, y) return x < x0 + 3 end)
  -- coral-stone coping on the wall top and the merlon caps
  local cope = rect(x0, yb - h, x1, yb - h + 1)
  for x = x0, x1 - 5, 10 do cope:add(rect(x, yb - h - 3, x + 5, yb - h - 3)) end
  cope:each(function(x, y) px(x, y, (y == yb - h + 1 and S.shade) or (hash(x // 4, y, seed) < .25 and S.base or S.hi)) end)
  for x = x0, x1 - 5, 10 do px(x + 5, yb - h - 2, S.shade) vline(x, yb - h - 2, yb - h - 1, S.base) end
  -- salt bloom and sea-grape at the foot
  m:each(function(x, y) if y > yb - 3 and hash(x, y, seed + 5) < .12 then px(x, y, L.shell.base) end end)
  for i = 0, (x1 - x0) // 11 do
    local gx = x0 + 3 + i * 11 + floor(hash(i, 2, seed) * 5)
    if hash(i, 3, seed) < .5 then grass(gx, yb + 1, 2 + floor(hash(i, 4, seed) * 3)) else F.crown(gx, yb - 1, 3, 2, L.foliage2, seed + i) end
  end
  torch(x0 + 1, yb - h - 3, 8) torch(x1 - 2, yb - h - 3, 8)
end
F.depth(1)
seawall(112, 194, 126, 9, 31)
seawall(286, 372, 126, 9, 37)
-- terns resting on the merlons
for _, t in ipairs({ { 134, 113 }, { 316, 113 }, { 346, 113 } }) do
  px(t[1], t[2], L.shell.hi) px(t[1] + 1, t[2], L.shell.base) px(t[1] - 1, t[2] - 1, L.shell.hi) px(t[1] - 2, t[2] - 1, L.gold.base) px(t[1] + 2, t[2] + 1, L.shell.shade)
end

---------------------------------------------------------------- the lighthouse on its lava headland
local function lighthouse()
  F.depth(2)
  -- the headland: a black lava point running out into the lagoon, surf round its foot
  local head = poly{ { 192, 132 }, { 197, 122 }, { 204, 115 }, { 214, 110 }, { 228, 107 }, { 254, 107 }, { 268, 110 }, { 278, 115 }, { 285, 122 }, { 290, 132 }, { 278, 134 }, { 204, 134 } }
  F.shadow(204, 290, 134, 8, 3)
  rimOf(head, LV)
  lavaFacets(head, 211, function(x, y) return (x - 240) * .5 + (y - 107) < -14 end)
  head:each(function(x, y) if not head:has(x, y - 1) then px(x, y, (x < 240) and LV.hi or LV.base) end end)
  -- surf breaking round the point (only where it meets the water above the beach line)
  for x = 186, 296 do for y = 104, 116 do
    if not head:has(x, y) and (head:has(x + 1, y) or head:has(x - 1, y) or head:has(x, y + 1)) and y <= 114 then
      px(x, y, L.surf) if hash(x, y, 212) < .5 then px(x + (x < 240 and -1 or 1), y - 1, L.mist) end
    end
  end end
  for i = 0, 9 do local sx = (i < 5) and (190 + i * 3) or (276 + (i - 5) * 4) local sy = 108 + floor(hash(i, 1, 213) * 6) px(sx, sy, L.surf) px(sx + 1, sy - 1, L.mist2) end
  -- naupaka scrub and beach grass on the shoulders, a tide pool on the left
  F.crown(203, 122, 6, 4, L.foliage2, 214) F.crown(279, 121, 7, 4, L.foliage2, 215) F.crown(287, 128, 4, 3, L.seagrass, 216)
  for _, f in ipairs({ { 200, 124 }, { 205, 121 }, { 284, 124 } }) do F.flower(f[1], f[2], "white", true) end
  grass(212, 114, 4) grass(268, 113, 4) grass(196, 130, 3) grass(274, 131, 3)
  local pool = c:ellipse(208, 128, 5, 2)
  c:rim(pool, LV.edge) fill(pool, L.lagoon.base) hline(205, 210, 127, L.lagoon.hi) px(211, 129, L.lagoon.shade) px(207, 128, L.coral.base)

  -- the tower body: a tapered round coral-stone tower painted in coral-red and lime-white bands
  local yt, yb = 58, 117
  local RED = { hi = F.mix(L.coral.hi, L.awnA.hi, .5), base = F.mix(L.coral.base, L.awnA.base, .55), shade = F.mix(L.coral.shade, L.awnA.shade, .55), deep = F.mix(L.coral.deep, L.awnA.deep, .5) }
  local function hw(y) return 20.5 - (126 - y) * 5.5 / 68 end
  local body = HP.mask()
  for y = yt, yb do local w = hw(y) for x = floor(240 - w + .5), floor(240 + w - .5) do body:set(x, y) end end
  rimOf(body, S)
  body:each(function(x, y)
    local w = hw(y)
    local t = (x + .5 - 240) / w
    local band = (y - yt) // 12
    local red = band % 2 == 0
    local r = red and RED or L.plaster
    local yy = y - floor(2.5 * (1 - t * t))
    local row = (yy - yt) // 6
    local off = (row % 2) * 4
    local lit = -t + (hash(x // 2, row, 220) - .5) * .25
    local h
    if lit > .62 then h = r.hi elseif lit > -.3 then h = r.base elseif lit > -.66 then h = r.shade
    else h = ((x + y) % 2 == 0) and r.deep or r.shade end
    if (yy - yt) % 6 == 0 then h = (lit > .62) and r.base or (lit > -.3 and r.shade or r.deep)
    elseif (x + off) % 8 == 0 and lit < .62 then h = r.shade end
    -- peeling paint shows the coral stone through the red; salt spots on the white
    if red and hash(x, y, 221) < .045 then h = lit > 0 and S.hi or S.shade end
    if not red and hash(x // 2, y, 222) < .02 then h = L.hibiscus.hi end -- orange lichen
    -- the band edges: a crisp painted line
    if (y - yt) % 12 == 0 and y > yt then h = red and RED.deep or L.plaster.shade end
    px(x, y, h)
  end)
  -- rust / salt streaks down from the slit windows
  for _, w in ipairs({ { 240, 64 }, { 231, 82 }, { 249, 82 } }) do
    fill(rect(w[1] - 1, w[2], w[1], w[2] + 7), LV.edge) px(w[1] - 1, w[2], LV.shade) px(w[1] - 1, w[2] + 8, S.hi) px(w[1], w[2] + 8, S.hi)
    for y = w[2] + 9, w[2] + 14 do if hash(w[1], y, 223) < .7 then px(w[1], y, L.roof2.shade) end end
  end
  F.window(237, 94, 243, 100, T, true)
  -- the lava plinth with a coral coping, the door, the steps
  local plinth = rect(216, 117, 264, 128)
  rimOf(plinth, LV)
  part(plinth, LV, { nopop = true }) F.courses(plinth, 117, 4, 9, LV)
  plinth:each(function(x, y) if hash(x, y, 224) < .08 then px(x, y, LV.deep) elseif x < 222 and (y - 117) % 4 == 1 then px(x, y, LV.hi) end end)
  hline(215, 265, 116, S.hi) hline(215, 265, 117, S.base) hline(215, 265, 118, S.shade)
  local arch = c:rrect(231, 101, 249, 132, 8):clip(rect(231, 101, 249, 126))
  rimOf(arch, S) part(arch, S, { nopop = true }) F.courses(arch, 101, 3, 5, S)
  F.door(234, 104, 246, 126, L.wall2, true)
  px(244, 115, G.hi) px(244, 116, L.gold.base) -- a brass ring handle
  for k = 0, 2 do hline(230 - k * 2, 250 + k * 2, 127 + k, k == 0 and S.hi or (k == 1 and S.base or S.shade)) end
  -- a morning-glory vine climbing the lit side
  for i = 0, 44 do
    local y = 126 - floor(hash(i, 3, 225) * 62)
    local x = floor(240 - hw(y)) + 1 + floor(hash(i, 4, 225) * 5) + floor((126 - y) * 3 / 62)
    if body:has(x, y) or plinth:has(x, y) then
      px(x, y, L.seagrass.base) px(x + 1, y, L.seagrass.shade) px(x, y - 1, L.seagrass.hi)
      if hash(i, 5, 225) < .2 then px(x + 1, y - 1, L.lav.hi) px(x + 2, y - 1, L.lav.base) end
    end
  end
  for y = 70, 126, 2 do local x = floor(240 - hw(y)) + 2 + floor(sin(y / 5) * 1.5 + (126 - y) * 3 / 62) if body:has(x, y) or plinth:has(x, y) then px(x, y, L.seagrass.deep) end end

  -- the gallery: a lava corbel ring with teeth under it
  local corb = rect(212, 52, 268, 57)
  local teeth = HP.mask()
  for x = 214, 264, 5 do teeth:add(rect(x, 58, x + 2, 60)) end
  rimOf(union(corb, teeth), LV)
  part(corb, LV, { nopop = true }) lavaFacets(corb, 226, function(x, y) return y == 52 end)
  hline(212, 268, 52, S.hi) hline(212, 268, 53, S.shade)
  part(teeth, LV, { nopop = true, noshade = true }) teeth:each(function(x, y) if x % 5 == 1 then px(x, y, LV.hi) elseif x % 5 == 3 then px(x, y, LV.deep) end end)
  -- tapa banner hanging from the gallery: brown bark-cloth with cream zigzags and a turtle
  local ban = poly{ { 221, 61 }, { 232, 61 }, { 232, 84 }, { 226, 80 }, { 221, 84 } }
  rimOf(ban, L.coconut)
  ban:each(function(x, y)
    local h = L.coconut.shade
    local k = (y - 61) % 8
    if k == 0 or k == 7 then h = L.awnB.hi
    elseif k == 1 and (x + y) % 3 == 0 then h = L.awnB.base
    elseif k == 6 and (x - y) % 3 == 0 then h = L.awnB.base end
    if x == 221 then h = L.coconut.base end
    px(x, y, h)
  end)
  for _, dy in ipairs({ 66, 74 }) do -- tapa diamonds
    for dx = 0, 2 do local cx = 223 + dx * 4 px(cx, dy - 1, L.awnB.base) px(cx - 1, dy, L.awnB.hi) px(cx + 1, dy, L.awnB.base) px(cx, dy + 1, L.awnB.shade) px(cx, dy, L.awnA.base) end
  end
  hline(221, 232, 61, L.rope.base)

  -- the lantern room: open bays between driftwood posts, the signal fire burning in an iron basket
  local room = rect(227, 31, 253, 51)
  fill(room, L.soil.deep)
  room:each(function(x, y)
    local d = math.sqrt(((x - 240) / 13) ^ 2 + ((y - 46) / 15) ^ 2)
    if d < .55 then px(x, y, G.deep) elseif d < .85 then px(x, y, L.soil.base) end
  end)
  local fire = poly{ { 229, 47 }, { 231, 39 }, { 233, 42 }, { 236, 33 }, { 239, 40 }, { 241, 30 }, { 244, 39 }, { 247, 34 }, { 249, 42 }, { 251, 47 } }
  fill(fire, G.shade)
  fill(poly{ { 232, 47 }, { 236, 37 }, { 238, 41 }, { 241, 33 }, { 244, 41 }, { 246, 38 }, { 248, 47 } }, G.base)
  fill(poly{ { 235, 47 }, { 238, 42 }, { 241, 36 }, { 243, 42 }, { 245, 47 } }, G.hi)
  fill(rect(239, 43, 242, 47), "#fff4d4")
  for i = 0, 6 do px(229 + floor(hash(i, 1, 227) * 22), 32 + floor(hash(i, 2, 227) * 8), G.hi) end
  local basket = poly{ { 229, 46 }, { 251, 46 }, { 248, 51 }, { 232, 51 } }
  rimOf(basket, IR) part(basket, IR, { nopop = true })
  for x = 231, 249, 3 do vline(x, 47, 50, IR.deep) end hline(229, 251, 46, IR.hi)
  local posts = HP.mask()
  for _, x in ipairs({ 225, 234, 245, 254 }) do posts:add(rect(x, 31, x + 1, 51)) end
  rimOf(posts, T)
  posts:each(function(x, y)
    local inner = (x == 235 or x == 245 or x == 226 or x == 254)
    local h = (x % 2 == 1) and T.hi or T.shade
    if x == 225 or x == 234 then h = T.base end
    if (x == 235 or x == 245) then h = G.shade end -- firelight on the inner faces
    if hash(x, y // 3, 228) < .15 then h = T.deep end
    px(x, y, h)
  end)
  -- lintel and the rust-tin cap with standing seams, a vent finial
  local lint = rect(222, 29, 258, 31)
  rimOf(lint, T) part(lint, T, { nopop = true, noshade = true }) hline(222, 258, 29, T.hi) hline(222, 258, 31, T.deep)
  for x = 228, 252, 6 do px(x, 31, G.shade) end
  local cap = poly{ { 218, 29 }, { 240, 14 }, { 262, 29 } }
  rimOf(cap, L.roof2)
  cap:each(function(x, y)
    local u = (x + .5 - 240) / math.max(1, y - 13)
    local u2 = (x - .5 - 240) / math.max(1, y - 13)
    local h
    if u < -.55 then h = L.roof2.hi elseif u < .35 then h = L.roof2.base else h = L.roof2.shade end
    if floor(u * 4) ~= floor(u2 * 4) then h = (u < 0) and L.roof2.base or L.roof2.deep end
    if floor(u * 4) ~= floor(u2 * 4) and u < -.4 then h = L.roof2.hi end
    if hash(x // 2, y, 229) < .08 then h = L.roof2.deep end -- rust blooms
    if y >= 27 then h = (y == 29) and L.roof2.deep or L.roof2.shade end
    px(x, y, h)
  end)
  line({ { 219, 28 }, { 239, 15 } }):each(function(x, y) if cap:has(x, y) then px(x, y, L.roof2.hi) end end)
  fill(rect(239, 12, 241, 14), IR.base) px(239, 12, IR.hi) px(241, 14, IR.deep)

  -- sentry on the gallery waving, then the bamboo railing in front
  F.gnome(218, 51, { small = true, hat = L.awnA, coat = L.wall2, arm = "up", noShadow = true, flip = true })
  local rail = rect(210, 44, 270, 45):add(rect(210, 48, 270, 48))
  for x = 210, 270, 6 do rail:add(rect(x, 43, x + 1, 51)) end
  rimOf(rail, T)
  rail:each(function(x, y)
    local h = B.base
    if y == 44 or y == 43 then h = B.hi elseif y == 45 or y == 48 then h = B.shade end
    if (x - 210) % 6 <= 1 and y ~= 44 and y ~= 48 then h = ((x - 210) % 6 == 0) and B.hi or B.shade end
    if (x - 210) % 6 == 3 and y == 44 then h = B.deep end
    px(x, y, h)
  end)
  for x = 210, 270, 12 do px(x + 2, 46, L.rope.base) px(x + 2, 47, L.rope.shade) end -- lashings
  -- pennant pole at the right end of the gallery, a palm on the flag
  local pole = rect(267, 18, 268, 51)
  rimOf(pole, T) bambooPole(pole) px(267, 17, L.gold.hi)
  local flag = poly{ { 269, 19 }, { 292, 22 }, { 286, 25 }, { 292, 29 }, { 269, 30 } }
  rimOf(flag, L.hibiscus) part(flag, L.hibiscus)
  flag:each(function(x, y) if y == 29 or y == 30 then px(x, y, L.hibiscus.shade) end end)
  F.sprite({ "g.g.g", ".ggg.", "..t..", ".tt.." }, 273, 21, { g = L.foliage.deep, t = L.coconut.shade }, { rim = false })
  -- smoke streaming off the vent on the trade wind
  local cols = { "#c8c4bc", "#d8d6ce", "#e6e6de", "#f0f0ea" }
  for i = 0, 8 do
    local t = i / 8
    local r = 2 + floor(t * 2.5)
    local sx, sy = 244 + i * 8 + floor(sin(i * 1.3) * 2), 18 + floor(sin(i * .9) * 1.5) + (i > 4 and 2 or 0)
    local m = c:ellipse(sx, sy, r, math.max(1, r - 1))
    local ci = math.min(4, 1 + floor(t * 3.5))
    fill(m, cols[ci])
    m:each(function(xx, yy) if not m:has(xx + 1, yy + 1) then px(xx, yy, cols[math.max(1, ci - 1)]) end end)
    px(sx - r + 1, sy - 1, cols[math.min(4, ci + 1)])
  end
  return body
end
lighthouse()

-- palms and a plumeria crowding the headland's shoulders; the lighthouse rises clear above them
F.depth(2)
F.palm(196, 132, 60, L.foliage, 6, { lean = -16 })
F.palm(288, 132, 54, L.foliage2, 9, { lean = 15 })
F.plumeria(180, 130, 32, 51)

---------------------------------------------------------------- bamboo pennant poles lining the road
local function banner(x, yb, s, r, k)
  local h = floor(30 * s)
  local pole = rect(x, yb - h, x + math.max(1, floor(s)), yb)
  local fl = poly{ { x + 1, yb - h + 1 }, { x + 1 + floor(9 * s), yb - h + 1 }, { x + 1 + floor(9 * s), yb - h + floor(16 * s) }, { x + 1 + floor(4.5 * s), yb - h + floor(12 * s) }, { x + 1, yb - h + floor(16 * s) } }
  F.shadow(x, x + 2, yb, floor(4 * s), 2)
  rimOf(union(pole, fl), T)
  bambooPole(pole)
  part(fl, r, { nopop = s < 1 })
  if s >= .8 then -- a cream zigzag hem
    for xx = x + 1, x + floor(9 * s) do local yy = yb - h + 2 + ((xx % 2 == 0) and 0 or 1) if fl:has(xx, yy) then px(xx, yy, L.awnB.hi) end end
  end
  if s >= 1 then F.flower(x + floor(4.5 * s) + 1, yb - h + floor(7 * s), k or "plumeria") end
  px(x, yb - h - 1, L.gold.base)
  -- a hibiscus lei tied round the pole under the flag
  if s >= .8 then for d = -1, 2 do px(x + d, yb - h + floor(17 * s), (d % 2 == 0) and L.awnA.base or L.petal.base) end end
  grass(x, yb + 1, math.max(2, floor(4 * s)))
end
for _, p in ipairs({ { 140, .55 }, { 166, .8 }, { 206, 1.2 } }) do
  local y, s = p[1], p[2]
  banner(floor(F.xl(y)) - floor(14 * s) - 4, y, s, L.awnA, "plumeria")
  banner(floor(F.xr(y)) + floor(6 * s), y, s, L.accent, "orange")
end

---------------------------------------------------------------- left: the woven guard fale + spear rack + training dummy
F.depth(1)
F.palm(28, 140, 42, L.foliage, 12, { lean = 8 })
F.palm(160, 136, 36, L.foliage2, 13, { lean = -6 })
F.depth(2)
F.banana(170, 170, 40, 45)
F.depth(3)
local gt, gcx, gwall, groof = F.building{ x0 = 54, x1 = 150, yb = 168, wh = 40, rh = 26, wall = L.rope, roof = L.roof, chimney = true, noFrame = true, noAttic = true }
local gable = poly{ { 59, gt }, { gcx, gt - 26 + 8 }, { 145, gt } }
weave(gwall:copy():clip(rect(54, gt + 3, 150, 161)), L.rope, { lit = 70 })
F.bamboo(gable, B, 3)
-- lava footing, bamboo corner and mid posts, a driftwood wall plate
local gfoot = rect(54, 162, 150, 168)
part(gfoot, LV, { nopop = true }) F.courses(gfoot, 162, 3, 8, LV) hline(54, 150, 162, LV.hi)
local gposts = HP.mask()
for _, x in ipairs({ 54, 82, 116, 147 }) do gposts:add(rect(x, gt + 2, x + 3, 161)) end
part(gposts, B, { nopop = true }) bambooPole(gposts)
local plate = rect(54, gt + 1, 150, gt + 3)
part(plate, T, { nopop = true, noshade = true }) hline(54, 150, gt + 1, T.hi) hline(54, 150, gt + 3, T.deep)
-- a crossed driftwood finial and a ridge of tied fronds on the roof
line({ { gcx - 5, gt - 31 }, { gcx + 2, gt - 23 } }):add(line({ { gcx + 5, gt - 31 }, { gcx - 2, gt - 23 } })):each(function(x, y) px(x, y, T.base) end)
px(gcx - 5, gt - 31, T.hi) px(gcx + 5, gt - 31, T.shade)
F.frond(gcx - 2, gt - 25, 2.6, 14, .35, L.foliage, 601, { wide = .25 })
F.frond(gcx + 2, gt - 25, .5, 14, .35, L.foliage, 602, { wide = .25 })
F.window(98, gt - 14, 104, gt - 9, T)
local function shuttered(x0, y0, x1, y1)
  F.window(x0, y0, x1, y1, T)
  local w = (x1 - x0) // 2 + 1
  local sl, sr = rect(x0 - w - 2, y0 - 1, x0 - 2, y1 + 1), rect(x1 + 2, y0 - 1, x1 + w + 2, y1 + 1)
  rimOf(union(sl, sr), L.wall2) part(sl, L.wall2, { nopop = true }) part(sr, L.wall2, { nopop = true })
  union(sl, sr):each(function(x, y) if y % 2 == 0 then px(x, y, L.wall2.shade) end end)
end
shuttered(66, 140, 74, 147) shuttered(126, 140, 134, 147)
F.door(94, 142, 108, 167, T, true)
F.smoke(141, 104, 6, .5, 2)
-- washing line: a pareo and two socks
local wp = rect(17, 149, 18, 172) rimOf(wp, T) bambooPole(wp)
F.washing(18, 150, 54, 146, { { "sock", L.awnA }, { "sheet", L.hibiscus }, { "sock", L.accent } }, 5)
-- turtle-shell shield over the door
local sh = c:ellipse(101, 133, 7, 5)
rimOf(sh, L.coconut) part(sh, L.coconut)
sh:each(function(x, y)
  local u, v = x - 101, y - 133
  if (abs(u) == 3 and abs(v) <= 2) or (abs(v) == 2 and abs(u) <= 3) or (u == 0 and abs(v) >= 3) then px(x, y, L.coconut.deep) end
  if u < -3 and v < 0 then px(x, y, L.coconut.hi) end
end)
fill(rect(100, 132, 102, 134), L.gold.base) px(100, 132, L.gold.hi)
c:edgeIn(sh, L.coral.shade)
-- a conch horn hung by the door, calabash gourds on pegs
vline(112, 144, 149, L.rope.shade)
F.sprite({ ".sss.", "sSSSp", ".sSpp", "..pP." }, 110, 149, { s = L.shell.hi, S = L.shell.base, p = L.petal.base, P = L.petal.shade })
hline(116, 125, 150, T.edge)
for k = 0, 1 do
  local bx = 118 + k * 5
  local g = c:ellipse(bx, 155, 2, 3):add(rect(bx, 151, bx, 152))
  rimOf(g, L.coconut) part(g, L.board, { nopop = true }) px(bx - 1, 154, B.hi) px(bx + 1, 157, B.deep)
end
-- a pile of husks for the beacon under the left window
for k = 0, 3 do F.coconut(60 + k * 5, 165, 2) end
for k = 0, 2 do F.coconut(62 + k * 5, 161, 2) end

local function rack(x0, yb)
  local posts = rect(x0, yb - 26, x0 + 2, yb):add(rect(x0 + 40, yb - 26, x0 + 42, yb))
  local rails = rect(x0, yb - 24, x0 + 42, yb - 23):add(rect(x0, yb - 8, x0 + 42, yb - 7))
  F.shadow(x0, x0 + 42, yb, 8, 3)
  rimOf(union(posts, rails), T)
  for k = 0, 4 do
    local x = x0 + 6 + k * 7
    vline(x, yb - 34, yb - 1, B.base) vline(x + 1, yb - 34, yb - 1, B.shade)
    for y = yb - 30, yb - 2, 6 do px(x, y, B.deep) px(x + 1, y, B.deep) end
    if k == 2 then -- a three-pronged fish spear
      hline(x - 2, x + 3, yb - 35, IR.base)
      for _, d in ipairs({ -2, 0, 3 }) do vline(x + d, yb - 41, yb - 36, IR.hi) px(x + d, yb - 41, IR.shade) end
    elseif k % 2 == 0 then -- shark-tooth tips
      local tip = poly{ { x - 1, yb - 34 }, { x + 1, yb - 41 }, { x + 3, yb - 34 } } fill(tip, L.shell.hi) px(x + 2, yb - 34, L.shell.shade) px(x, yb - 35, L.shell.base)
      hline(x - 1, x + 2, yb - 33, L.rope.base)
    else
      local tip = poly{ { x - 1, yb - 34 }, { x + 1, yb - 40 }, { x + 3, yb - 34 } } fill(tip, IR.hi) px(x + 2, yb - 34, IR.shade)
    end
  end
  part(posts, T, { nopop = true, noshade = true }) part(rails, T, { nopop = true, noshade = true })
  for _, ry in ipairs({ yb - 24, yb - 8 }) do px(x0 + 1, ry + 2, L.rope.base) px(x0 + 41, ry + 2, L.rope.base) end
  -- woven oval shields leaning against the rack, painted rims and a sun boss
  for k, r in ipairs({ L.awnA, L.accent }) do
    local x = x0 + 50 + k * 13
    local m = c:ellipse(x, yb - 9, 6, 9)
    rimOf(m, r)
    weave(m, L.rope)
    c:edgeIn(m, r.base)
    m:edge():each(function(xx, yy) if xx > x and yy > yb - 9 then px(xx, yy, r.shade) end end)
    vline(x, yb - 17, yb - 1, r.shade)
    fill(c:ellipse(x, yb - 9, 2, 2), L.gold.base) px(x - 1, yb - 10, L.gold.hi) px(x + 1, yb - 8, L.gold.shade)
  end
end
rack(60, 200)
local function dummy(x, yb)
  local post = rect(x - 1, yb - 30, x + 1, yb):add(rect(x - 12, yb - 22, x + 12, yb - 20))
  local sack = c:rrect(x - 7, yb - 26, x + 7, yb - 10, 4)
  local skirt = poly{ { x - 8, yb - 12 }, { x + 8, yb - 12 }, { x + 10, yb - 4 }, { x - 10, yb - 4 } }
  local head = c:ellipse(x, yb - 32, 5, 5)
  F.shadow(x - 6, x + 8, yb, 6, 2)
  rimOf(union(post, sack, head, skirt), T)
  part(post, T, { nopop = true, noshade = true })
  -- coconut-husk fibre body
  part(sack, L.needle)
  sack:each(function(xx, y) if (xx + y * 2) % 5 == 0 then px(xx, y, L.needle.shade) elseif (xx - y) % 7 == 0 then px(xx, y, L.needle.hi) end end)
  hline(x - 7, x + 7, yb - 18, L.rope.deep)
  -- a grass skirt of dry fronds
  skirt:each(function(xx, y) px(xx, y, (xx % 2 == 0) and L.leaf.shade or ((y % 3 == 0) and L.needle.base or L.leaf.base)) end)
  -- a coconut head with a painted face
  part(head, L.coconut)
  head:each(function(xx, y) if (xx - x) + (y - yb + 32) < -4 then px(xx, y, L.coconut.hi) end end)
  fill(rect(x - 2, yb - 33, x - 1, yb - 32), L.awnB.hi) fill(rect(x + 2, yb - 33, x + 3, yb - 32), L.awnB.hi)
  px(x - 1, yb - 32, T.edge) px(x + 3, yb - 32, T.edge)
  hline(x - 2, x + 2, yb - 29, L.awnA.base)
  -- half a giant clam for a helmet, fluted
  local hel = c:ellipse(x, yb - 37, 7, 3):clip(rect(x - 8, yb - 41, x + 8, yb - 36))
  c:rim(hel, L.shell.edge) fill(hel, L.shell.base)
  hel:each(function(xx, y) if (xx - x) % 3 == 0 then px(xx, y, L.shell.shade) elseif xx < x and y < yb - 37 then px(xx, y, L.shell.hi) end end)
  hline(x - 7, x + 7, yb - 36, L.shell.deep)
  for xx = x - 6, x + 6, 3 do px(xx, yb - 35, L.shell.shade) end
  -- fibre leaking out
  px(x - 8, yb - 14, L.needle.hi) px(x + 8, yb - 16, L.needle.hi) px(x + 9, yb - 15, L.needle.base)
end
dummy(178, 208)

---------------------------------------------------------------- archery range, bottom-left: woven-mat targets
local function target(x, yb, s)
  local legs = line({ { x - 6 * s, yb }, { x, yb - 22 * s } }, 2):add(line({ { x + 6 * s, yb }, { x, yb - 22 * s } }, 2))
  local cy = floor(yb - 16 * s)
  local R = floor(10 * s)
  local face = c:ellipse(x, cy, R, R)
  F.shadow(floor(x - 6 * s), floor(x + 8 * s), yb, 6, 2)
  rimOf(union(legs, face), T)
  part(legs, B, { nopop = true, noshade = true })
  legs:each(function(xx, y) if y % 5 == 0 then px(xx, y, B.deep) end end)
  -- a coiled pandanus mat: spiral rings
  face:each(function(xx, yy)
    local d = math.sqrt((xx - x) ^ 2 + (yy - cy) ^ 2)
    local a = math.atan(yy - cy, xx - x)
    local ring = floor(d + a / pi + .5)
    local h = (ring % 2 == 0) and L.rope.base or L.rope.shade
    if (xx - x) + (yy - cy) < -R * .7 and ring % 2 == 0 then h = L.rope.hi end
    if (xx - x) + (yy - cy) > R * .8 then h = L.rope.deep end
    px(xx, yy, h)
  end)
  fill(c:ellipse(x, cy, floor(7 * s), floor(7 * s)):cut(c:ellipse(x, cy, floor(6 * s), floor(6 * s))), L.awnA.base)
  fill(c:ellipse(x, cy, floor(4 * s), floor(4 * s)):cut(c:ellipse(x, cy, floor(3 * s), floor(3 * s))), L.accent.base)
  fill(c:ellipse(x, cy, math.max(1, floor(2 * s)), math.max(1, floor(2 * s))), L.awnA.base) px(x - 1, cy - 1, L.awnA.hi)
  for k = 0, 1 do local ax, ay = floor(x - 2 + k * 5), floor(cy - 2 + k * 4) fill(line({ { ax, ay }, { ax - 6, ay + 3 } }), B.deep) px(ax - 6, ay + 3, L.awnA.hi) px(ax - 7, ay + 3, L.shell.hi) end
  grass(floor(x - 7 * s), yb + 1, 4) grass(floor(x + 8 * s), yb + 1, 3)
end
target(40, 252, 1.2) target(82, 244, .9)
local _, ax, ay = F.gnome(150, 258, { hat = L.awnA, coat = L.hibiscus, arm = "out", flip = true })
fill(c:ellipse(ax - 1, ay, 2, 8):cut(c:ellipse(ax, ay, 1, 7)), T.base) vline(ax - 1, ay - 7, ay + 7, L.awnB.shade) -- bow
fill(line({ { ax - 1, ay }, { ax + 8, ay } }), B.deep) px(ax - 2, ay, L.shell.hi)
-- a bamboo quiver stuck in the sand
local qs = rect(164, 248, 167, 261)
rimOf(qs, T) bambooPole(qs)
for k = 0, 2 do vline(164 + k * 1 + k, 240 + k, 247, B.deep) px(164 + k * 2, 239 + k, L.awnA.base) px(164 + k * 2, 238 + k, L.shell.hi) end
-- beach grass, shells, a lava boulder and a crab along the left edge
for _, f in ipairs({ { 22, 216, 6 }, { 30, 212, 5 }, { 112, 222, 5 }, { 18, 262, 7 }, { 120, 262, 6 } }) do F.fern(f[1], f[2], f[3], L.seagrass) end
grass(58, 262, 5) grass(64, 264, 4) grass(26, 236, 4)
F.lavaRock(100, 266, 9, 7, 88)
F.shell(56, 266, "conch", true) F.shell(68, 262, "scallop", true) F.shell(130, 252, "cowrie")
F.crab(110, 254, L.awnA, true)
F.coconut(140, 262, 3) F.coconut(134, 265, 2, true)

---------------------------------------------------------------- right: net store, ship's bell, roost box, spyglass
local function bell(x0, yb)
  local posts = rect(x0, yb - 40, x0 + 3, yb):add(rect(x0 + 34, yb - 40, x0 + 37, yb))
  local beam = rect(x0 - 4, yb - 44, x0 + 41, yb - 40)
  local braces = line({ { x0 + 3, yb - 32 }, { x0 + 10, yb - 40 } }):add(line({ { x0 + 34, yb - 32 }, { x0 + 27, yb - 40 } }))
  local b = poly{ { x0 + 13, yb - 34 }, { x0 + 24, yb - 34 }, { x0 + 27, yb - 18 }, { x0 + 10, yb - 18 } }:add(c:rrect(x0 + 13, yb - 38, x0 + 24, yb - 31, 3))
  local hood = poly{ { x0 - 7, yb - 44 }, { x0 + 18, yb - 54 }, { x0 + 44, yb - 44 } }
  F.shadow(x0, x0 + 40, yb, 8, 3)
  rimOf(union(posts, beam, b, braces, hood), T)
  part(posts, B, { nopop = true }) bambooPole(posts)
  part(braces, T, { nopop = true, noshade = true })
  part(beam, T) hline(x0 - 4, x0 + 41, yb - 44, T.hi)
  beam:each(function(x, y) if hash(x // 4, y, 301) < .15 then px(x, y, T.shade) end end)
  part(hood, L.roof, { sep = true }) F.thatch(hood, L.roof, yb - 54, x0 + 18)
  line({ { x0 - 6, yb - 45 }, { x0 + 17, yb - 54 } }):each(function(x, y) if hood:has(x, y) then px(x, y, L.roof.hi) end end)
  hline(x0 - 7, x0 + 44, yb - 44, L.roof.deep)
  -- the salvaged brass ship's bell, green with verdigris low down
  part(b, L.gold) hline(x0 + 10, x0 + 27, yb - 19, L.gold.deep) hline(x0 + 12, x0 + 25, yb - 26, L.gold.shade)
  b:each(function(x, y)
    if x < x0 + 15 and y < yb - 21 and y > yb - 36 then px(x, y, L.gold.hi) end
    if y > yb - 23 and hash(x, y, 302) < .25 then px(x, y, L.seagrass.base) end
  end)
  hline(x0 + 12, x0 + 25, yb - 30, L.gold.deep)
  vline(x0 + 18, yb - 40, yb - 38, T.edge)
  fill(rect(x0 + 18, yb - 18, x0 + 19, yb - 15), IR.base)
  vline(x0 + 26, yb - 18, yb - 4, L.rope.shade) -- pull rope
  px(x0 + 26, yb - 3, L.awnA.base) px(x0 + 26, yb - 2, L.awnA.shade) -- a red tassel
end
F.depth(1)
F.palm(352, 138, 40, L.foliage, 14, { lean = -10 })
local st, scx, swall, sroof = F.building{ x0 = 368, x1 = 424, yb = 146, wh = 22, rh = 16, wall = L.plaster, roof = L.roof, noFrame = true, noAttic = true }
local sq = HP.mask()
for y = st + 2, 140, 4 do local w = ((y - st) // 4) % 2 == 0 and 4 or 2 sq:add(rect(368, y, 368 + w, y + 2)):add(rect(424 - w, y, 424, y + 2)) end
part(sq, S, { nopop = true })
local sfoot = rect(368, 141, 424, 146) part(sfoot, LV, { nopop = true }) F.courses(sfoot, 141, 3, 8, LV)
F.door(390, 132, 400, 145, L.wall2, true) F.window(408, 131, 413, 136, T)
-- a fishing net drying on a pole rack beside the store
local np = rect(428, 124, 429, 146):add(rect(450, 126, 451, 146))
rimOf(np, T) part(np, T, { nopop = true, noshade = true })
local netM = poly{ { 430, 126 }, { 450, 128 }, { 448, 140 }, { 432, 142 } }
F.net(netM, L.rope, { floats = true })
F.palm(458, 146, 52, L.foliage2, 16, { lean = 10 })
F.depth(2)
-- the beacon fuel: a pyramid of dry husks, a sheaf of dead fronds, a stump with a machete
F.shadow(346, 382, 176, 6, 3)
for k = 0, 2 do F.frond(372 + k * 3, 176, -1.75 - k * .3, 20, .15, L.needle, 700 + k, { wide = .22 }) end
for row = 0, 2 do for k = 0, 3 - row do F.coconut(350 + k * 7 + row * 3, 172 - row * 5, 3) end end
grass(346, 177, 5) grass(380, 177, 4)
local stp2 = rect(388, 170, 396, 176) local stt2 = c:ellipse(392, 170, 4, 2)
rimOf(union(stp2, stt2), T) part(stp2, T, { nopop = true }) fill(stt2, B.base) px(392, 170, B.shade) px(390, 169, B.hi)
stp2:each(function(x, y) if (x - 392) % 3 == 0 then px(x, y, T.shade) end end)
line({ { 390, 169 }, { 384, 164 } }):each(function(x, y) px(x, y, IR.hi) end) px(384, 164, IR.base) px(391, 169, L.coconut.deep) px(392, 168, L.coconut.base)
bell(300, 196)
local _, bx, by = F.gnome(334, 206, { hat = L.produce, coat = L.lav, arm = "up", flip = true })
F.depth(3)
local function roost(x, yb)
  local post = rect(x - 1, yb - 40, x + 1, yb)
  local box = rect(x - 12, yb - 58, x + 12, yb - 40)
  local roofm = poly{ { x - 16, yb - 57 }, { x, yb - 69 }, { x + 16, yb - 57 } }
  F.shadow(x - 2, x + 4, yb, 6, 2)
  rimOf(union(post, box, roofm), T)
  part(post, T, { nopop = true, noshade = true })
  post:each(function(xx, y) if xx == x - 1 then px(xx, y, T.hi) elseif (y // 4) % 3 == 0 then px(xx, y, T.shade) end end)
  part(box, B) F.bamboo(box, B, 3)
  part(roofm, L.roof, { sep = true }) F.thatch(roofm, L.roof, yb - 69, x)
  line({ { x - 15, yb - 58 }, { x - 1, yb - 68 } }):each(function(xx, y) if roofm:has(xx, y) then px(xx, y, L.roof.hi) end end)
  hline(x - 16, x + 16, yb - 57, L.roof.deep)
  for k = 0, 2 do local hx = x - 9 + k * 7 fill(c:rrect(hx, yb - 54, hx + 4, yb - 48, 2), T.edge) hline(hx - 1, hx + 5, yb - 47, T.base) end
  hline(x - 12, x + 12, yb - 45, T.base) hline(x - 12, x + 12, yb - 44, T.deep)
  grass(x - 3, yb, 5) grass(x + 4, yb + 1, 4) F.shell(x + 8, yb + 1, "scallop")
  -- two white fairy terns resting on the net-store roof behind
  for _, p in ipairs({ { 384, 112 }, { 404, 113 } }) do
    local m = c:ellipse(p[1], p[2], 3, 2) c:rim(m, L.shell.edge) fill(m, L.shell.hi) px(p[1] + 2, p[2] + 1, L.shell.shade) px(p[1] + 3, p[2], L.shell.shade)
    px(p[1] - 2, p[2] - 1, L.timber.edge) px(p[1] - 4, p[2] - 1, IR.deep) px(p[1] - 3, p[2] - 1, IR.base)
  end
  -- quirk: a brown booby landing, wings up, blue feet out, a red gnome hat, a scroll with a red ribbon on its leg
  F.sprite({
    "................KKK...",
    "..............KKWwK...",
    ".....H.......KWWwwK...",
    "....HHr.....KWWwwK....",
    "...HHHr....KWWwwK...KK",
    "..HHHHHr..KWWwwK..KKWK",
    ".ccccccc.KWwwwK.KKWwK.",
    "..BBBBB.KWwwwKKKWwwK..",
    ".BBeBBBBBwwwKWWwwK....",
    "YYBBBBBBBBwwwwwK......",
    "yyyy.bbbBBBBBBK.......",
    "....bbbbbBBBBB........",
    "....bbbbbbBBBBB.......",
    ".....bbbbbbBBBBTT.....",
    "......bbbbbBBBTTTT....",
    ".......bbbBB...TTT....",
    ".......F..F...........",
    ".....FFF.FFF..........",
    "........sZRs..........",
    "........sZZs..........",
  }, x - 8, yb - 87, { K = L.coconut.edge, W = L.coconut.hi, w = L.coconut.base, B = L.coconut.shade, b = L.shell.hi,
    e = L.timber.edge, Y = L.iron.hi, y = L.iron.base, H = L.awnA.base, c = L.awnA.deep, r = L.awnA.shade, T = L.coconut.deep,
    F = "#4aa6e0", s = L.awnB.hi, Z = L.awnB.shade, R = L.awnA.base })
  px(x - 5, yb - 83, L.awnA.hi) px(x - 4, yb - 82, L.awnA.hi) -- the hat's lit side
  px(x - 3, yb - 70, "#8ccaee") px(x, yb - 70, "#8ccaee") -- lit toes
end
roost(440, 196)
-- spyglass on a bamboo tripod, a gnome lookout
local tri = line({ { 362, 214 }, { 370, 196 } }):add(line({ { 378, 214 }, { 370, 196 } })):add(line({ { 370, 214 }, { 370, 196 } }))
local tube = line({ { 362, 198 }, { 384, 186 } }, 3)
rimOf(union(tri, tube), T) fill(tri, B.base) tri:each(function(x, y) if y % 4 == 0 then px(x, y, B.deep) end end)
part(tube, L.gold) fill(rect(382, 184, 386, 188), L.gold.shade) px(362, 198, L.lagoon.hi)
for _, wx in ipairs({ 368, 374 }) do line({ { wx, 194 + (374 - wx) // 2 }, { wx + 1, 197 + (374 - wx) // 2 } }):each(function(x, y) px(x, y, L.rope.base) end) end
F.gnome(354, 218, { hat = L.lav, coat = L.awnA, arm = "out" })
-- beacon bundles: sheaves of dry palm fronds tied with sennit
for k = 0, 2 do
  local x = 300 + k * 18
  local m = rect(x, 228, x + 14, 236)
  rimOf(m, L.needle)
  m:each(function(xx, y) px(xx, y, (y % 2 == 0) and ((xx + y) % 5 == 0 and L.needle.hi or L.needle.base) or L.needle.shade) end)
  fill(rect(x + 5, 228, x + 6, 236), L.rope.base) px(x + 5, 228, L.rope.hi) vline(x + 6, 229, 236, L.rope.deep)
  for y = 228, 236, 2 do px(x + 15, y, L.needle.base) px(x + 16, y + 1, L.needle.shade) end
end
F.crate(300, 254, 18, 12) F.crate(320, 256, 18, 12) F.crate(310, 242, 18, 10, L.coconut)
F.barrel(346, 258, T, 12)
-- right foreground flora (clear of the compass corner)
F.hibiscus(420, 224, 10, 12, 43)
for _, f in ipairs({ { 446, 222, 7 }, { 456, 226, 8 }, { 286, 262, 7 }, { 352, 264, 6 }, { 398, 214, 5 } }) do F.fern(f[1], f[2], f[3], L.seagrass) end
grass(372, 262, 5) grass(292, 228, 4)
F.shell(330, 246, "conch", true) F.shell(404, 222, "scallop", true) F.crab(392, 226, L.hibiscus)
-- a lava boulder by the road with a hermit crab
F.lavaRock(286, 218, 8, 7, 89)
F.sprite({ ".sss.", "spppP", ".lClP" }, 292, 214, { s = L.shell.hi, p = L.petal.base, P = L.petal.shade, l = L.hibiscus.deep, C = L.hibiscus.base })
-- guard with a fish spear on the road
local _, gx, gy = F.gnome(258, 242, { hat = L.roof2, coat = L.wall2, arm = "hold" })
fill(rect(gx + 6, 204, gx + 6, 242), B.shade) for y = 207, 240, 6 do px(gx + 6, y, B.deep) end
hline(gx + 4, gx + 8, 203, IR.base) for _, d in ipairs({ -2, 0, 2 }) do vline(gx + 6 + d, 197, 202, IR.hi) end -- trident
-- the guard's spotted pig, snuffling at a coconut
F.sprite({
  ".ee.......",
  "hPPhhPPP..",
  "nPePPPPkPt",
  "nPPPPkkPP.",
  ".pPPPPPPp.",
  ".d.d..d.d.",
}, 275, 236, { e = L.petal.shade, h = L.petal.hi, P = L.petal.base, p = L.petal.shade, n = L.petal.deep, k = L.coconut.shade, t = L.petal.shade, d = L.petal.deep })
px(277, 238, T.edge)
F.coconut(272, 241, 2)
F.depth(0)
---------------------------------------------------------------- frigatebirds riding the beacon smoke
local function frigate(x, y, big, flip)
  local rows = big and {
    "......KK.........KK......",
    "....KKkkK.......KkkKK....",
    "..KKk....KK...KK....kKK..",
    "KK.........KKRKK.......KK",
    "............KRK..........",
    "............K.K..........",
    "...........K...K.........",
  } or {
    "...KK.......KK...",
    ".KKkkK.....KkkKK.",
    "K.....KKRKK.....K",
    ".......KRK.......",
    "......K...K......",
  }
  local w = #rows[1]
  local map = { K = "#3a3444", k = "#5a5668", R = L.awnA.base }
  for j, row in ipairs(rows) do for i = 1, w do
    local ch = row:sub(i, i)
    if map[ch] then px(flip and (x + w // 2 - i + 1) or (x - w // 2 + i - 1), y + j - 1, map[ch]) end
  end end
end
frigate(300, 44, true) frigate(178, 52, true, true) frigate(330, 62, false, true) frigate(160, 72, false)
F.birds({ { 206, 40, 2 }, { 360, 46, 1 }, { 140, 58, 1 } })
F.finish()
