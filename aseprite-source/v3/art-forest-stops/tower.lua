-- tower.lua : "Watchtower" stop look, FOREST (forest_pinewood), 480x270 gate view.
-- Same composition and story as the Maplewold watchtower (art-2701-batch3/stops/opus3/tower.lua), re-cast for a pine wood:
-- road's end: a timber fire-watch lookout on a mossy stone plinth, splayed legs with X braces rising above the
-- spruces to a log lookout cabin with a band of lamp-lit windows, a railed gallery, a shingle roof, a signal beacon
-- in an iron basket and a pennant. Two rope ladders (one with a gnome climbing), a sentry waving from the gallery.
-- A sharpened-log palisade runs off along the horizon. Left: a log guardhouse with red fire buckets, a spear and
-- shield rack, a log-and-sack training dummy, log-slice archery targets. Right: a log store in the mist, the alarm
-- bell frame, a telescope lookout, beacon log bundles, crates, a guard with a spear and his dog.
-- Quirk: a carrier pigeon with a tiny scroll landing on the birdhouse.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-forest-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "tower", out = DIR, farTrees = { 24, 52, 100, 380, 440 },
  treeLineGap = { 196, 284 }, clouds = { { 104, 40, 38 }, { 318, 34, 48 }, { 410, 68, 30 }, { 30, 80, 26 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local S, IR, G, T = L.stone, L.iron, L.glow, L.timber

---------------------------------------------------------------- sharpened-log palisade along the horizon
local function palisade(x0, x1, yb, h, seed)
  local m = HP.mask()
  local tops = {}
  for x = x0, x1 - 3, 4 do
    local hh = h + floor(hash(x, 1, seed) * 4)
    m:add(poly{ { x, yb }, { x + 3, yb }, { x + 3, yb - hh }, { x + 2, yb - hh - 3 }, { x + 1, yb - hh - 3 }, { x, yb - hh } })
    tops[#tops + 1] = { x, yb - hh }
  end
  F.shadow(x0, x1, yb, 4, 2)
  rimOf(m, T) part(m, T)
  m:each(function(x, y)
    local k = (x - x0) % 4
    if k == 0 then px(x, y, T.hi) elseif k == 3 then px(x, y, T.deep)
    elseif hash(x, y // 3, seed) < .18 then px(x, y, T.shade) end
    if y > yb - 4 and hash(x, y, seed + 1) < .5 then px(x, y, hash(x, y, seed + 2) < .5 and L.moss.base or L.moss.shade) end
  end)
  for _, t in ipairs(tops) do px(t[1] + 1, t[2] - 2, L.board.hi) px(t[1] + 2, t[2] - 2, L.board.base) end -- fresh-cut points
  -- two lashed rails
  for _, ry in ipairs({ yb - h + 3, yb - 5 }) do hline(x0, x1, ry, T.edge) hline(x0, x1, ry + 1, T.shade) end
  -- ferns at the foot
  for i = 0, (x1 - x0) // 9 do F.fern(x0 + 3 + i * 9 + floor(hash(i, 2, seed) * 4), yb + 1, 2 + floor(hash(i, 3, seed) * 2)) end
end
F.depth(1)
palisade(116, 204, 126, 11, 31)
palisade(278, 372, 126, 11, 37)

---------------------------------------------------------------- the fire-watch tower
local function tower()
  F.depth(2)
  local yTop, yBase = 58, 105
  local function xL(y) return 222 + (yBase - y) * 7 / 47 end
  local function xR(y) return 258 - (yBase - y) * 7 / 47 end
  F.shadow(216, 266, 129, 12, 4)
  -- back legs (darker, behind)
  local back = line({ { 235, yBase }, { 237, yTop } }, 2):add(line({ { 245, yBase }, { 243, yTop } }, 2))
  back:add(line({ { 236, 90 }, { 244, 74 } })):add(line({ { 244, 90 }, { 236, 74 } }))
  rimOf(back, T) fill(back, T.shade) back:each(function(x, y) if hash(x, y // 3, 5) < .3 then px(x, y, T.deep) end end)
  -- front legs, girts and X braces
  local front = line({ { 222, yBase }, { 229, yTop } }, 3):add(line({ { 258, yBase }, { 251, yTop } }, 3))
  local braces = HP.mask()
  local bays = { yTop + 1, 74, 90, yBase }
  for i = 1, 3 do
    local a, b = bays[i], bays[i + 1]
    braces:add(line({ { xL(a) + 2, a }, { xR(b) - 2, b } })):add(line({ { xR(a) - 2, a }, { xL(b) + 2, b } }))
    braces:add(rect(floor(xL(b)), b - 1, floor(xR(b)), b))
  end
  rimOf(union(front, braces), T)
  part(braces, T, { nopop = true, noshade = true })
  braces:each(function(x, y) if hash(x // 2, y, 6) < .2 then px(x, y, T.shade) end end)
  part(front, T, { nopop = true })
  front:each(function(x, y)
    if not front:has(x - 1, y) then px(x, y, T.hi) elseif not front:has(x + 1, y) then px(x, y, T.deep)
    elseif hash(x, y // 4, 7) < .25 then px(x, y, T.shade) end
  end)
  -- iron brackets where braces meet the legs
  for i = 2, 3 do local y = bays[i] px(floor(xL(y)) + 1, y - 1, IR.hi) px(floor(xR(y)) - 1, y - 1, IR.hi) end
  -- banner hanging from the deck
  local ban = poly{ { 218, 60 }, { 227, 60 }, { 227, 80 }, { 222, 76 }, { 218, 80 } }
  rimOf(ban, L.accent) part(ban, L.accent)
  F.sprite({ "..g..", ".ggg.", "ggggg", "..t.." }, 220, 64, { g = L.gold.base, t = L.gold.shade }, { rim = false })
  -- centre rope ladder up to the trap in the deck
  for y = yTop + 1, yBase - 1 do px(238, y, L.needle.shade) px(242, y, L.needle.deep) end
  for y = yTop + 3, yBase - 2, 4 do hline(239, 241, y, L.board.base) px(239, y, L.board.hi) hline(239, 241, y + 1, L.board.deep) end
  -- a gnome halfway up the ladder
  F.gnome(240, 96, { small = true, hat = L.awnA, coat = L.foliage, arm = "up", noShadow = true })
  -- a second rope ladder swinging from the right end of the deck
  local r1 = line({ { 263, 60 }, { 268, 98 } }) local r2 = line({ { 266, 60 }, { 271, 98 } })
  r1:each(function(x, y) px(x, y, L.needle.shade) end) r2:each(function(x, y) px(x, y, L.needle.deep) end)
  for y = 63, 96, 4 do local dx = floor((y - 60) * 5 / 38) hline(264 + dx, 266 + dx, y, L.board.base) end
  -- mossy stone plinth
  local base = poly{ { 216, 128 }, { 264, 128 }, { 261, 106 }, { 219, 106 } }
  local cap = rect(217, 103, 263, 106)
  rimOf(union(base, cap), S)
  part(base, S)
  base:each(function(x, y)
    local row = (y - 106) // 5
    local blk = (x + (row % 2) * 5) // 10
    local v = hash(blk, row, 77)
    if v < .25 then px(x, y, "#c2c8b4") elseif v > .85 then px(x, y, "#9aa294") end
    if x > 252 and (x + y) % 2 == 0 then px(x, y, S.shade) end
  end)
  F.courses(base, 106, 5, 10, S)
  F.moss(base, .2, 81)
  part(cap, S, { sep = true }) F.moss(cap, .3, 82)
  -- where the legs sit on the plinth: log feet
  for _, fx in ipairs({ 222, 235, 245, 258 }) do F.logEnd(fx, 104, 2) end
  F.door(233, 112, 247, 127, T, true)
  for k = 0, 1 do hline(231 - k * 2, 249 + k * 2, 126 + k, S.hi) end
  -- ferns and a mushroom ring at the foot of the plinth
  for _, f in ipairs({ { 214, 128, 5 }, { 219, 129, 4 }, { 263, 129, 4 }, { 267, 128, 5 } }) do F.fern(f[1], f[2], f[3]) end
  F.mushroom(226, 129, L.apple) F.mushroom(254, 129, L.apple)

  -- gallery deck (joist ends showing), lookout cabin, roof
  local deck = rect(212, 56, 268, 59)
  rimOf(deck, T) part(deck, L.board, { nopop = true }) hline(212, 268, 56, L.board.hi) hline(212, 268, 59, L.board.deep)
  for x = 214, 266, 6 do px(x, 58, T.deep) px(x, 57, L.board.shade) end
  local cab = rect(222, 34, 258, 55)
  local roofM = poly{ { 215, 37 }, { 240, 15 }, { 265, 37 } }
  rimOf(union(cab, roofM), T)
  part(cab, T)
  F.logs(cab, T, 34, 3)
  for y = 36, 54, 3 do F.logEnd(222, y, 1) F.logEnd(258, y, 1) end
  -- a band of lookout windows, lamp-lit
  F.window(226, 40, 232, 46, T) F.window(237, 40, 243, 46, T) F.window(248, 40, 254, 46, T)
  px(239, 43, L.awnA.base) px(240, 43, L.awnA.base) -- the lookout's red cap seen through the window
  part(roofM, L.roof, { sep = true })
  F.courses(roofM, 15, 3, 5, L.roof)
  F.moss(roofM, .16, 83)
  line({ { 216, 36 }, { 239, 16 } }):each(function(x, y) if roofM:has(x, y) then px(x, y, L.roof.hi) end end)
  hline(215, 265, 37, L.roof.deep)
  fill(rect(239, 13, 241, 15), IR.base) px(239, 13, IR.hi) -- finial
  -- sentry on the gallery, waving
  F.gnome(218, 52, { small = true, hat = L.awnA, coat = L.accent, arm = "up", noShadow = true, flip = true })
  -- railing in front
  local rail = rect(212, 48, 268, 49):add(rect(212, 52, 268, 52))
  for x = 212, 268, 7 do rail:add(rect(x, 48, x + 1, 55)) end
  rail:cut(rect(226, 50, 254, 51)) -- keep the window sills readable
  rimOf(rail, T) part(rail, T, { nopop = true, noshade = true }) hline(212, 268, 48, T.hi)
  -- pennant pole at the right end of the gallery
  local pole = rect(266, 16, 267, 55)
  rimOf(pole, T) part(pole, T, { nopop = true, noshade = true }) px(266, 15, L.gold.hi)
  local flag = poly{ { 268, 17 }, { 290, 20 }, { 284, 23 }, { 290, 27 }, { 268, 28 } }
  rimOf(flag, L.awnA) part(flag, L.awnA)
  F.sprite({ ".g.", "ggg", ".t." }, 272, 20, { g = L.gold.base, t = L.gold.shade }, { rim = false })
  -- signal beacon: an iron basket on a bracket off the left of the gallery, burning
  local arm = line({ { 213, 57 }, { 207, 52 } }, 1)
  local basket = poly{ { 200, 46 }, { 213, 46 }, { 211, 52 }, { 202, 52 } }
  rimOf(union(arm, basket), IR) part(arm, IR, { nopop = true, noshade = true }) part(basket, IR)
  for x = 202, 211, 3 do vline(x, 47, 51, IR.deep) end hline(201, 212, 46, IR.hi)
  local fire = poly{ { 200, 46 }, { 202, 38 }, { 204, 42 }, { 206, 33 }, { 209, 41 }, { 211, 37 }, { 213, 46 } }
  fill(fire, G.shade) fill(poly{ { 202, 46 }, { 206, 37 }, { 211, 46 } }, G.base) fill(poly{ { 205, 46 }, { 206, 41 }, { 208, 46 } }, G.hi)
  for i = 0, 4 do px(199 + floor(hash(i, 1, 2) * 16), 26 + floor(hash(i, 2, 2) * 8), G.hi) end
  F.smoke(200, 26, 4, -.6, 2)
end
tower()

-- spruces crowding the foot of the tower: the lookout rises above their tips
F.depth(2)
F.tree(198, 131, 60, 2)
F.tree(285, 131, 54, 1)
F.tree(184, 128, 40, 4)

---------------------------------------------------------------- pennant poles lining the road
local function banner(x, yb, s, r)
  local h = floor(30 * s)
  local pole = rect(x, yb - h, x + math.max(1, floor(s)), yb)
  local fl = poly{ { x + 1, yb - h + 1 }, { x + 1 + floor(9 * s), yb - h + 1 }, { x + 1 + floor(9 * s), yb - h + floor(16 * s) }, { x + 1 + floor(4.5 * s), yb - h + floor(12 * s) }, { x + 1, yb - h + floor(16 * s) } }
  F.shadow(x, x + 2, yb, floor(4 * s), 2)
  rimOf(union(pole, fl), T)
  part(pole, L.birch, { nopop = true, noshade = true })
  pole:each(function(xx, y) if hash(y // 2, xx, 3) < .25 then px(xx, y, L.birch.edge) end end) -- birch poles
  part(fl, r, { nopop = s < 1 })
  if s >= 1 then F.sprite({ ".g.", "ggg", ".t." }, x + floor(4 * s) - 1, yb - h + 4, { g = L.gold.base, t = L.gold.shade }, { rim = false }) end
  px(x, yb - h - 1, L.gold.base)
  F.fern(x - 1, yb, math.max(2, floor(4 * s)))
end
for _, p in ipairs({ { 140, .55 }, { 166, .8 }, { 206, 1.2 } }) do
  local y, s = p[1], p[2]
  banner(floor(F.xl(y)) - floor(14 * s) - 4, y, s, L.awnA)
  banner(floor(F.xr(y)) + floor(6 * s), y, s, L.accent)
end

---------------------------------------------------------------- left: log guardhouse + rack + training dummy
F.depth(1)
F.tree(30, 140, 40, 3)
F.tree(158, 136, 36, 0)
F.depth(2)
F.birch(166, 168, 44, 47)
F.depth(3)
local gt, gcx, gwall, groof = F.building{ x0 = 54, x1 = 150, yb = 168, wh = 40, rh = 26, wall = T, roof = L.roof, shingle = true, chimney = true, noFrame = true, noAttic = true }
F.logs(gwall, T, gt, 3)
for y = gt + 1, 166, 3 do F.logEnd(53, y, 1) F.logEnd(151, y, 1) end
F.moss(groof, .14, 84)
gwall:each(function(x, y) if y > 163 and hash(x // 2, y, 85) < .4 then px(x, y, L.moss.shade) end end)
F.window(98, 112, 104, 118, T) -- gable window
F.door(94, 142, 108, 167, T, true)
F.smoke(141, 104, 6, .5, 2)
local wp = rect(17, 149, 18, 172) rimOf(wp, T) part(wp, T, { nopop = true, noshade = true })
F.washing(18, 150, 54, 146, { { "sock", L.awnA }, { "shirt", L.accent }, { "sock", L.roof } }, 5)
F.window(66, 140, 74, 147, T) F.window(126, 140, 134, 147, T)
-- shield over the door: a pine on teal
local sh = poly{ { 95, 128 }, { 107, 128 }, { 107, 134 }, { 101, 139 }, { 95, 134 } }
rimOf(sh, L.accent) part(sh, L.accent)
F.sprite({ "..g..", ".ggg.", "ggggg", "..t.." }, 99, 130, { g = L.gold.base, t = L.gold.shade }, { rim = false })
-- red leather fire buckets on pegs between the door and the window
hline(111, 123, 150, T.edge)
for k = 0, 2 do
  local bx = 112 + k * 4
  local b = poly{ { bx, 152 }, { bx + 3, 152 }, { bx + 3, 157 }, { bx, 157 } }
  rimOf(b, L.apple) part(b, L.apple, { nopop = true }) px(bx, 152, L.apple.hi) hline(bx, bx + 3, 155, L.gold.shade)
  px(bx + 1, 151, T.edge) px(bx + 2, 151, T.edge)
end
-- a woodpile under the left window
for k = 0, 3 do F.logEnd(60 + k * 5, 164, 2) end
for k = 0, 2 do F.logEnd(62 + k * 5, 160, 2) end

local function rack(x0, yb)
  local posts = rect(x0, yb - 26, x0 + 2, yb):add(rect(x0 + 40, yb - 26, x0 + 42, yb))
  local rails = rect(x0, yb - 24, x0 + 42, yb - 23):add(rect(x0, yb - 8, x0 + 42, yb - 7))
  F.shadow(x0, x0 + 42, yb, 8, 3)
  rimOf(union(posts, rails), T)
  for k = 0, 4 do
    local x = x0 + 6 + k * 7
    if k == 2 then -- a fire beater (a broom of pine boughs) among the spears
      vline(x, yb - 34, yb - 1, L.board.base) vline(x + 1, yb - 34, yb - 1, L.board.shade)
      fill(poly{ { x - 3, yb - 34 }, { x + 4, yb - 34 }, { x + 2, yb - 44 }, { x - 1, yb - 44 } }, L.foliage.shade)
      for q = 0, 4 do px(x - 2 + q * 1, yb - 42 + q * 2, L.foliage.hi) px(x + 3 - q, yb - 41 + q * 2, L.foliage.deep) end
    else
      vline(x, yb - 34, yb - 1, L.board.base) vline(x + 1, yb - 34, yb - 1, L.board.shade)
      local tip = poly{ { x - 1, yb - 34 }, { x + 1, yb - 40 }, { x + 3, yb - 34 } } fill(tip, IR.hi) px(x + 2, yb - 34, IR.shade)
    end
  end
  part(posts, T, { nopop = true, noshade = true }) part(rails, T, { nopop = true, noshade = true })
  F.moss(posts, .2, 86)
  for k, r in ipairs({ L.awnA, L.accent }) do
    local x = x0 + 50 + k * 13
    local m = c:ellipse(x, yb - 8, 7, 8)
    rimOf(m, r) part(m, r)
    c:ellipse(x, yb - 8, 4, 5):edge():each(function(xx, yy) px(xx, yy, L.gold.base) end)
    fill(c:ellipse(x, yb - 8, 1, 1), IR.hi)
  end
end
rack(60, 200)
local function dummy(x, yb)
  local post = rect(x - 1, yb - 30, x + 1, yb):add(rect(x - 12, yb - 22, x + 12, yb - 20))
  local sack = c:rrect(x - 7, yb - 26, x + 7, yb - 10, 4)
  local head = c:ellipse(x, yb - 32, 5, 5)
  F.shadow(x - 6, x + 8, yb, 6, 2)
  rimOf(union(post, sack, head), T)
  part(post, T, { nopop = true, noshade = true })
  part(sack, L.needle) sack:each(function(xx, y) if (xx + y) % 4 == 0 then px(xx, y, L.needle.shade) end end)
  hline(x - 7, x + 7, yb - 18, T.edge) -- rope belt
  part(head, L.needle)
  fill(rect(x - 2, yb - 33, x - 1, yb - 32), T.edge) fill(rect(x + 2, yb - 33, x + 3, yb - 32), T.edge)
  hline(x - 3, x + 3, yb - 29, L.needle.deep)
  -- dented pot helmet with a fern stuck in it
  local hel = c:ellipse(x, yb - 37, 6, 3):clip(rect(x - 7, yb - 41, x + 7, yb - 36)) fill(hel, IR.base) hline(x - 6, x + 6, yb - 36, IR.deep) px(x - 3, yb - 39, IR.hi)
  F.fern(x + 4, yb - 40, 4)
  -- straw / needles leaking out
  px(x - 8, yb - 12, L.needle.hi) px(x + 8, yb - 14, L.needle.hi) px(x + 9, yb - 13, L.needle.base)
end
dummy(178, 208)

---------------------------------------------------------------- archery range, bottom-left: log-slice targets
local function target(x, yb, s)
  local legs = line({ { x - 6 * s, yb }, { x, yb - 22 * s } }, 2):add(line({ { x + 6 * s, yb }, { x, yb - 22 * s } }, 2))
  local cy = floor(yb - 16 * s)
  local R = floor(10 * s)
  local face = c:ellipse(x, cy, R, R)
  F.shadow(floor(x - 6 * s), floor(x + 8 * s), yb, 6, 2)
  rimOf(union(legs, face), T)
  part(legs, T, { nopop = true, noshade = true })
  fill(face, T.base)
  local inner = c:ellipse(x, cy, R - 1, R - 1)
  fill(inner, L.board.base)
  inner:each(function(xx, yy)
    local d = math.sqrt((xx - x) ^ 2 + (yy - cy) ^ 2)
    if floor(d + .5) % 2 == 0 and d > 1 then px(xx, yy, L.board.shade) end -- growth rings
    if (xx - x) + (yy - cy) < -R * .8 then px(xx, yy, L.board.hi) end
  end)
  -- painted rings
  fill(c:ellipse(x, cy, floor(7 * s), floor(7 * s)):cut(c:ellipse(x, cy, floor(6 * s), floor(6 * s))), L.awnA.base)
  fill(c:ellipse(x, cy, floor(4 * s), floor(4 * s)):cut(c:ellipse(x, cy, floor(3 * s), floor(3 * s))), L.accent.base)
  fill(c:ellipse(x, cy, math.max(1, floor(2 * s)), math.max(1, floor(2 * s))), L.awnA.base) px(x - 1, cy - 1, L.awnA.hi)
  px(x + floor(R * .6), cy - floor(R * .3), L.board.deep) -- a crack
  px(x + floor(R * .6) + 1, cy - floor(R * .3) + 1, L.board.deep)
  for k = 0, 1 do local ax, ay = floor(x - 2 + k * 5), floor(cy - 2 + k * 4) fill(line({ { ax, ay }, { ax - 6, ay + 3 } }), L.board.deep) px(ax - 6, ay + 3, L.awnB.hi) px(ax - 7, ay + 3, L.awnB.hi) end
  F.fern(floor(x - 7 * s), yb + 1, 4) F.fern(floor(x + 8 * s), yb + 1, 3)
end
target(40, 252, 1.2) target(82, 244, .9)
local _, ax, ay = F.gnome(150, 258, { hat = L.foliage, coat = L.roof2, arm = "out", flip = true })
fill(c:ellipse(ax - 1, ay, 2, 8):cut(c:ellipse(ax, ay, 1, 7)), T.base) vline(ax - 1, ay - 7, ay + 7, L.awnB.shade) -- bow
fill(line({ { ax - 1, ay }, { ax + 8, ay } }), L.board.deep) px(ax - 2, ay, IR.hi)
-- quiver of arrows in a stump by the archer
local qs = rect(164, 252, 172, 260) local qt = c:ellipse(168, 252, 4, 1)
rimOf(union(qs, qt), T) part(qs, T, { nopop = true }) fill(qt, L.board.base) px(168, 252, L.board.shade)
F.moss(qs, .25, 87)
for k = 0, 2 do vline(166 + k * 2, 244, 251, L.board.deep) px(166 + k * 2, 243, L.awnB.hi) px(166 + k * 2, 244, L.awnA.base) end
-- ferns and mushrooms along the left edge
for _, f in ipairs({ { 22, 216, 6 }, { 30, 212, 5 }, { 112, 222, 5 }, { 18, 262, 7 }, { 120, 262, 6 } }) do F.fern(f[1], f[2], f[3]) end
F.mushroom(58, 262, L.apple, true) F.mushroom(64, 264, L.apple) F.mushroom(54, 265, L.apple)
F.moss(F.rock(100, 266, 8, 6), .3, 88)

---------------------------------------------------------------- right: log store, alarm bell, birdhouse, telescope
local function bell(x0, yb)
  local posts = rect(x0, yb - 40, x0 + 3, yb):add(rect(x0 + 34, yb - 40, x0 + 37, yb))
  local beam = rect(x0 - 4, yb - 44, x0 + 41, yb - 40)
  local braces = line({ { x0 + 3, yb - 32 }, { x0 + 10, yb - 40 } }):add(line({ { x0 + 34, yb - 32 }, { x0 + 27, yb - 40 } }))
  local b = poly{ { x0 + 13, yb - 34 }, { x0 + 24, yb - 34 }, { x0 + 27, yb - 18 }, { x0 + 10, yb - 18 } }:add(c:rrect(x0 + 13, yb - 38, x0 + 24, yb - 31, 3))
  F.shadow(x0, x0 + 40, yb, 8, 3)
  rimOf(union(posts, beam, b, braces), T)
  part(posts, T, { nopop = true }) part(braces, T, { nopop = true, noshade = true }) part(beam, T) hline(x0 - 4, x0 + 41, yb - 44, T.hi)
  F.moss(beam, .25, 89) F.moss(posts:copy():clip(rect(x0, yb - 8, x0 + 37, yb)), .3, 90)
  -- a little shingle hood over the beam
  local hood = poly{ { x0 - 6, yb - 44 }, { x0 + 18, yb - 52 }, { x0 + 43, yb - 44 } }
  rimOf(hood, L.roof2) part(hood, L.roof2, { sep = true }) F.courses(hood, yb - 52, 3, 4, L.roof2) F.moss(hood, .2, 91)
  part(b, L.gold) hline(x0 + 10, x0 + 27, yb - 19, L.gold.deep) hline(x0 + 12, x0 + 25, yb - 26, L.gold.shade)
  b:each(function(x, y) if x < x0 + 15 and y < yb - 21 and y > yb - 36 then px(x, y, L.gold.hi) end end)
  vline(x0 + 18, yb - 40, yb - 38, T.edge)
  fill(rect(x0 + 18, yb - 18, x0 + 19, yb - 15), IR.base)
  vline(x0 + 26, yb - 18, yb - 4, L.board.deep) -- pull rope
end
F.depth(1)
F.tree(352, 136, 40, 2)
F.tree(442, 142, 54, 1)
local st, scx, swall, sroof = F.building{ x0 = 368, x1 = 424, yb = 146, wh = 22, rh = 16, wall = T, roof = L.roof, shingle = true, noFrame = true, noAttic = true }
F.logs(swall:copy():clip(rect(368, st, 424, 140)), T, st, 3)
local sfoot = rect(368, 141, 424, 146) part(sfoot, S, { nopop = true }) F.courses(sfoot, 141, 3, 8, S) F.moss(sfoot, .25, 92)
F.moss(sroof, .18, 93)
F.door(390, 132, 400, 145, T, true) F.window(408, 131, 413, 136, T)
for k = 0, 2 do F.logEnd(376 + k * 4, 143, 2) end
F.depth(2)
-- a stack of beacon logs waiting by the store, a stump with an axe bitten in
F.shadow(318, 352, 172, 6, 3)
for row = 0, 2 do for k = 0, 3 - row do F.logEnd(322 + k * 7 + row * 3, 168 - row * 6, 3) end end
F.fern(316, 173, 5) F.fern(356, 172, 4)
local stp2 = rect(366, 166, 374, 172) local stt2 = c:ellipse(370, 166, 4, 2)
rimOf(union(stp2, stt2), T) part(stp2, T, { nopop = true }) fill(stt2, L.board.base) px(370, 166, L.board.shade) F.moss(stp2, .3, 98)
line({ { 368, 165 }, { 364, 158 } }):each(function(x, y) px(x, y, L.board.base) end)
fill(rect(367, 163, 371, 165), IR.base) px(367, 163, IR.hi)
bell(300, 196)
local _, bx, by = F.gnome(334, 206, { hat = L.produce, coat = L.lav, arm = "up", flip = true })
F.depth(3)
local function birdhouse(x, yb)
  local post = rect(x - 1, yb - 40, x + 1, yb)
  local box = rect(x - 12, yb - 58, x + 12, yb - 40)
  local roofm = poly{ { x - 15, yb - 58 }, { x, yb - 68 }, { x + 15, yb - 58 } }
  F.shadow(x - 2, x + 4, yb, 6, 2)
  rimOf(union(post, box, roofm), T)
  part(post, T, { nopop = true, noshade = true }) part(box, L.board) F.planks(box, L.board, 4, true, 19)
  part(roofm, L.roof2, { sep = true }) F.courses(roofm, yb - 68, 3, 4, L.roof2) F.moss(roofm, .22, 94)
  for k = 0, 2 do local hx = x - 9 + k * 7 fill(c:rrect(hx, yb - 54, hx + 4, yb - 48, 2), T.edge) hline(hx - 1, hx + 5, yb - 47, T.base) end
  hline(x - 12, x + 12, yb - 45, L.board.deep)
  -- a fern growing out of the post foot, moss on the post
  F.moss(post, .3, 95) F.fern(x - 3, yb, 5) F.fern(x + 4, yb + 1, 4)
  for _, p in ipairs({ { x - 6, yb - 63 }, { x + 7, yb - 61 } }) do local m = c:ellipse(p[1], p[2], 3, 2) fill(m, S.base) px(p[1] - 2, p[2] - 2, S.hi) px(p[1] - 3, p[2] - 1, L.gold.base) end
  -- quirk: the carrier pigeon landing, wings up, a cream scroll tied with a red ribbon to its leg
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
  }, x - 7, yb - 86, { K = S.deep, W = S.hi, w = S.base, g = S.base, e = L.produce.base, y = L.gold.hi, P = "#7cc0a0", Q = "#b48ac8",
    T = S.shade, o = L.apple.base, s = L.awnB.hi, Z = L.awnB.shade, R = L.awnA.base })
end
birdhouse(440, 196)
-- telescope on a tripod with a gnome lookout
local tri = line({ { 362, 214 }, { 370, 196 } }):add(line({ { 378, 214 }, { 370, 196 } })):add(line({ { 370, 214 }, { 370, 196 } }))
local tube = line({ { 362, 198 }, { 384, 186 } }, 3)
rimOf(union(tri, tube), T) fill(tri, T.base) part(tube, L.gold) fill(rect(382, 184, 386, 188), L.gold.shade) px(362, 198, L.water.hi)
hline(370, 373, 192, L.gold.deep)
F.gnome(354, 218, { hat = L.lav, coat = L.awnA, arm = "out" })
-- beacon log bundles, crates, a barrel
for k = 0, 2 do
  local x = 300 + k * 18
  local m = rect(x, 228, x + 14, 236) rimOf(m, T) part(m, T, { nopop = true })
  F.logs(m, T, 228, 3)
  fill(rect(x + 6, 228, x + 7, 236), L.needle.shade) -- rope tie
  F.logEnd(x + 14, 230, 1) F.logEnd(x + 14, 234, 1) F.logEnd(x + 13, 232, 1)
end
F.crate(300, 254, 18, 12) F.crate(320, 256, 18, 12) F.crate(310, 242, 18, 10, L.soil)
F.moss(rect(300, 242, 338, 243), .25, 96)
F.barrel(346, 258, T, 12)
-- young spruces, ferns and mushrooms closing the wood in on the right (clear of the compass corner)
F.conifer(368, 266, 30, L.foliage2, 41)
F.conifer(420, 228, 22, L.foliage, 42)
for _, f in ipairs({ { 446, 222, 7 }, { 456, 226, 8 }, { 286, 262, 7 }, { 352, 264, 6 }, { 398, 214, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.mushroom(404, 224, L.apple, true) F.mushroom(410, 226, L.apple) F.mushroom(398, 226, L.needle, true)
-- a mossy stump by the road
local stp = rect(282, 210, 290, 218) local stt = c:ellipse(286, 210, 4, 2)
rimOf(union(stp, stt), T) part(stp, T, { nopop = true }) fill(stt, L.board.base) px(286, 210, L.board.shade) px(284, 209, L.board.hi)
F.moss(stp, .3, 97) F.mushroom(292, 218, L.needle)
-- guard with a spear on the road
local _, gx, gy = F.gnome(258, 242, { hat = L.roof2, coat = L.foliage, arm = "hold" })
fill(rect(gx + 6, 204, gx + 6, 242), L.board.shade) fill(poly{ { gx + 5, 204 }, { gx + 6, 197 }, { gx + 8, 204 } }, IR.hi) -- spear
-- the guard's dog
F.sprite({
  "e.......",
  "DDe.....",
  "DnDD....",
  ".DDDDDDt",
  ".DdDDDD.",
  ".d.d.d.d",
}, 272, 236, { e = T.shade, D = L.board.base, d = L.board.shade, n = T.edge, t = L.board.base })
-- a pine cone the dog dropped
px(282, 241, L.soil.base) px(283, 241, L.soil.shade) px(282, 240, L.soil.hi) px(283, 242, L.soil.deep)
F.depth(0)
F.birds({ { 164, 44, 2 }, { 304, 50, 2 }, { 318, 56, 1 }, { 150, 62, 1 } })
F.finish()
