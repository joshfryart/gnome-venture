-- tower.lua : "Watchtower" stop look, MOUNTAIN (mountain_granite), 480x270 gate view.
-- Same composition and story as the Maplewold watchtower (art-2701-batch3/stops/opus3/tower.lua), re-cast for the
-- high mountains: road's end: a round granite signal tower on a lichened crag, crenels capped with snow, a burning
-- beacon in an iron brazier, a sentry waving, a flag. A rope bridge swings from a side door to a granite needle
-- with a cairn; prayer-flag lines run from the tower to the needle and down to a dry-stone rampart. Far off, two
-- more beacon towers stand on the snow peaks (the signal chain); a golden eagle circles. Left: a stone-and-larch
-- guardhouse with fire buckets, a spear rack with an alpenhorn, a straw training dummy, larch-slice archery targets.
-- Right: a stone store in the haze, the alarm bell under a slab hood, a telescope lookout, beacon log bundles,
-- crates, a guard with a spear and his big mountain dog (with a tiny barrel). Goats on the crags, a marmot.
-- Quirk: a carrier pigeon with a tiny scroll landing on the pigeon loft.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-mountain-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "tower", out = DIR, farTrees = { 24, 52, 100, 380, 440 },
  treeLineGap = { 126, 300 }, clouds = { { 96, 40, 40 }, { 318, 30, 48 }, { 408, 50, 34 }, { 14, 70, 26 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local S, IR, G, T = L.stone, L.iron, L.glow, L.timber
local mix = F.mix

---------------------------------------------------------------- local helpers
-- a granite crag / needle: faceted, lit upper-left, diagonal joints, ledges with snow, lichen
local function crag(m, cx, w, seed, snowK)
  local S = {}
  for k, v in pairs(L.peak) do S[k] = (type(v) == "string") and mix(v, L.stone.deep, .28) or v end
  rimOf(m, S) part(m, S)
  -- big planar facets: a quantised noise field; each facet gets one tone by its side of the rock,
  -- a lit lip on its upper-left boundary and a dark crack on its lower-right one
  local function fid(x, y) return floor((x * .9 + y * .55) / 9 + F.vnoise(x / 14, y / 14, seed) * 1.3) end
  m:each(function(x, y)
    local u = (x - cx) / w + (hash(fid(x, y), 1, seed) - .5) * .5
    local f = fid(x, y)
    local tones = u < -.2 and { S.base, S.hi, S.base, S.shade } or (u > .3 and { S.shade, S.deep, S.shade, S.deep } or { S.shade, S.base, S.shade, S.base })
    local h = tones[f % 4 + 1]
    if f ~= fid(x - 1, y) or f ~= fid(x, y - 1) then h = u < -.2 and S.hi or (u < .3 and S.base or S.shade)
    elseif f ~= fid(x + 1, y) or f ~= fid(x, y + 1) then h = S.edge end
    if (x + y * 2) % 13 == 0 and hash(x // 3, y // 4, seed) < .35 then h = S.deep end -- joints
    if hash(x // 2, y // 5, seed + 3) < .04 then h = "#c4bab4" end -- feldspar pink
    if not m:has(x, y - 1) then h = u < .3 and S.hi or S.base end
    if not m:has(x + 1, y) and u > 0 then h = S.deep end
    px(x, y, h)
  end)
  F.lichen(m, .14, seed + 10)
  if snowK then F.snow(m, snowK, seed + 20) end
end
-- prayer-flag line sagging between two points; flags hang from the rope, cycling five colours
local PF = { L.gentian, L.awnB, L.awnA, L.leaf, L.gold }
local function prayer(x0, y0, x1, y1, sag, seed)
  local function ly(x) local t = (x - x0) / (x1 - x0) return floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + .5) end
  local st = x1 > x0 and 1 or -1
  local prev
  for x = x0, x1, st do
    local y = ly(x)
    px(x, y, T.deep)
    if prev and abs(y - prev) > 1 then vline(x, math.min(y, prev) + 1, math.max(y, prev) - 1, T.deep) end
    prev = y
  end
  local i = seed or 0
  for x = x0 + 3 * st, x1 - 4 * st, 5 * st do
    local r = PF[i % 5 + 1] i = i + 1
    local len = 3 + floor(hash(x, 1, seed or 3) * 2)
    for dx = 0, 2 do
      local xx = x + dx * st
      local yt = ly(xx)
      for dy = 1, len - (dx == 2 and hash(x, 2, 4) < .5 and 1 or 0) do
        px(xx, yt + dy, dx == 0 and r.hi or (dx == 2 and r.shade or r.base))
      end
    end
  end
end
-- dry-stone wall along a ground line, h tall
local function stoneWall(x0, y0, x1, y1, h0, h1, seed)
  local m = HP.mask()
  for x = x0, x1 do
    local t = (x - x0) / (x1 - x0)
    local y = floor(y0 + (y1 - y0) * t + .5)
    local h = floor(h0 + (h1 - h0) * t + .5) + (hash(x // 5, 1, seed) < .3 and 1 or 0)
    for yy = y - h, y do m:set(x, yy) end
  end
  rimOf(m, S)
  m:each(function(x, y)
    local v = hash(x // 3, y // 2 + (x // 3) % 2, seed)
    local hh = v < .3 and S.hi or (v < .75 and S.base or S.shade)
    if (x + (y // 2) * 2) % 3 == 0 and hash(x, y, seed + 1) < .6 then hh = S.deep end
    if not m:has(x, y - 1) then hh = S.hi end
    px(x, y, hh)
  end)
  F.lichen(m, .25, seed + 2)
  F.snow(m, .3, seed + 3)
  return m
end
local function grass(x, yb, n, seed)
  for k = 0, n - 1 do
    local xx = x + k - n // 2
    local h = 2 + floor(hash(k, 1, seed) * 4)
    vline(xx, yb - h, yb, k % 2 == 0 and L.fern.base or L.fern.shade)
    px(xx, yb - h, k % 3 == 0 and L.needle.hi or L.fern.hi)
  end
end
local function cairn(x, yb, n)
  local yy = yb
  for k = 0, n - 1 do
    local rx, ry = math.max(1, 4 - k), 2
    local m = c:ellipse(x + (k % 2), yy - ry, rx, ry)
    rimOf(m, S) part(m, S, { nopop = true }) px(x + (k % 2) - rx + 1, yy - ry - 1, S.hi)
    yy = yy - ry * 2
  end
  return yy
end

---------------------------------------------------------------- far: two more beacon towers on the peaks (the signal chain)
F.depth(0)
local function farBeacon(x, yb, lit)
  local hz = function(h) return mix(h, L.sky[4], .12) end
  local m = rect(x - 3, yb - 12, x + 3, yb):add(rect(x - 5, yb - 16, x + 5, yb - 12)):add(rect(x - 5, yb - 2, x + 5, yb))
  m:add(rect(x - 5, yb - 18, x - 4, yb - 17)):add(rect(x + 4, yb - 18, x + 5, yb - 17)):add(rect(x - 1, yb - 18, x + 1, yb - 17))
  c:rim(m, S.edge)
  fill(m, hz(S.shade))
  m:each(function(xx, yy) if xx < x - 1 then px(xx, yy, hz(S.hi)) elseif xx > x + 1 then px(xx, yy, hz(S.deep)) end end)
  hline(x - 5, x + 5, yb - 13, hz(S.deep))
  fill(rect(x - 1, yb - 8, x, yb - 5), S.edge)
  if lit then
    fill(rect(x - 1, yb - 20, x + 1, yb - 19), G.shade) px(x, yb - 21, G.base) px(x - 1, yb - 20, G.base) px(x, yb - 20, G.hi) px(x, yb - 22, G.hi) px(x - 1, yb - 22, G.base)
    for i = 0, 3 do px(x - 1 - i, yb - 24 - i * 3, i < 2 and "#bcc3cb" or "#cfd5db") px(x - i, yb - 24 - i * 3, "#cfd5db") end
  end
end
farBeacon(421, 79, true)
farBeacon(62, 76, true)

---------------------------------------------------------------- right: dry-stone rampart along the horizon
F.depth(1)
stoneWall(268, 126, 356, 125, 6, 6, 31)
-- a few grazing goats on the slope beyond the rampart
F.goat(300, 117, { k = .4, graze = true, noShadow = true })
F.goat(318, 115, { k = .38, flip = true, r = L.chamois, noShadow = true })

---------------------------------------------------------------- the granite needle with a cairn (the far end of the rope bridge)
F.depth(2)
local needle = poly{ { 132, 130 }, { 138, 116 }, { 144, 104 }, { 149, 92 }, { 152, 80 }, { 156, 70 }, { 161, 66 }, { 166, 69 },
  { 169, 78 }, { 172, 86 }, { 180, 88 }, { 185, 98 }, { 189, 112 }, { 194, 130 } }
crag(needle, 162, 26, 41, .45)
-- a ledge, a juniper in a crack
F.juniper(146, 104, 4, 3, 5)
local cairnTop = cairn(160, 68, 3)
-- bridge anchor posts on the shoulder
local ap = rect(176, 79, 177, 88):add(rect(180, 80, 181, 88))
rimOf(ap, T) part(ap, T, { nopop = true, noshade = true })
-- the flag pole on the cairn
local fp = rect(161, 46, 161, cairnTop) fill(fp, T.base) px(161, 45, L.gold.hi)
-- a chamois on a ledge of the needle


---------------------------------------------------------------- the round granite signal tower on its crag
local function tower()
  F.depth(2)
  local x0, x1, yb, yt = 214, 266, 128, 46
  local body = poly{ { x0, yb }, { x1, yb }, { x1 - 6, yt }, { x0 + 6, yt } }
  local cor = rect(x0 - 2, yt - 8, x1 + 2, yt)
  local cren = HP.mask()
  for x = x0 - 2, x1 - 2, 8 do cren:add(rect(x, yt - 16, x + 4, yt - 8)) end
  F.shadow(x0, x1, yb + 1, 14, 4)
  rimOf(union(body, cor, cren), S)
  part(body, S)
  -- rounded courses of dressed granite: the row curve suggests a cylinder
  body:each(function(x, y)
    local t = (x - 240) / 26
    local yy = y - floor(3 * (1 - t * t))
    local row = (yy - yt) // 7
    local bw = 9
    local off = (row % 2) * 4
    local brick = ((x + off) // bw) * 31 + row
    local v = hash(brick, row, 77)
    if v < .22 then px(x, y, "#c8bfb8") elseif v < .3 then px(x, y, "#bcc2b2") elseif v > .9 then px(x, y, "#8e959c") end -- pink, lichen-grey, dark
    if (yy - yt) % 7 == 0 then px(x, y, S.deep)
    elseif (x + off) % bw == 0 then px(x, y, S.shade)
    elseif (yy - yt) % 7 == 1 and t < .2 then px(x, y, S.hi) end
    if hash(x, y, 78) < .05 then px(x, y, S.shade) end -- granite grain
    if y > yb - 9 and ((yy - yt) % 7 == 0 or (x + off) % 14 == 0) then px(x, y, S.edge) end -- big footing blocks
    if t > .5 and t <= .75 then px(x, y, ((yy - yt) % 7 == 0) and S.deep or S.shade) end
    if t > .75 then px(x, y, ((yy - yt) % 7 == 0 or (x + off) % bw == 0) and S.deep or S.shade) end
    if t < -.6 and (yy - yt) % 7 == 1 then px(x, y, S.hi) end
  end)
  F.lichen(body:copy():clip(rect(x0, yt + 40, x1, yb)), .1, 55)
  part(cor, S, { sep = true })
  for x = x0, x1, 5 do fill(rect(x, yt, x + 2, yt + 3), S.shade) px(x, yt, S.deep) end -- corbels
  part(cren, S, { sep = true, nopop = true })
  F.snow(cor, .7, 61) F.snow(cren, 1, 62)
  -- beacon brazier and fire behind the crenels
  local braz = rect(232, yt - 22, 248, yt - 16) rimOf(braz, IR) part(braz, IR)
  for x = 233, 247, 3 do vline(x, yt - 21, yt - 17, IR.deep) end hline(232, 248, yt - 22, IR.hi)
  local fire = poly{ { 232, yt - 22 }, { 235, yt - 32 }, { 238, yt - 26 }, { 240, yt - 38 }, { 243, yt - 27 }, { 246, yt - 33 }, { 248, yt - 22 } }
  fill(fire, G.shade) fill(poly{ { 235, yt - 22 }, { 240, yt - 33 }, { 245, yt - 22 } }, G.base) fill(poly{ { 238, yt - 22 }, { 240, yt - 28 }, { 242, yt - 22 } }, G.hi)
  for i = 0, 5 do px(232 + floor(hash(i, 1, 2) * 18), yt - 36 - floor(hash(i, 2, 2) * 8), G.hi) end
  F.smoke(236, yt - 44, 4, -.7, 2)
  -- warm glow on the snow of the crenels next to the fire
  for x = 228, 252 do if cren:has(x, yt - 16) then px(x, yt - 16, G.hi) end end
  F.gnome(222, yt - 9, { small = true, hat = L.awnA, coat = L.accent, arm = "up", noShadow = true }) -- sentry waving
  -- flag pole + pennant (gentian on red)
  local pole = rect(258, yt - 32, 259, yt - 8) rimOf(pole, T) part(pole, T, { nopop = true, noshade = true })
  local flag = poly{ { 260, yt - 31 }, { 280, yt - 27 }, { 274, yt - 24 }, { 280, yt - 20 }, { 260, yt - 20 } }
  rimOf(flag, L.awnA) part(flag, L.awnA)
  F.sprite({ ".h.", "hbh", ".s." }, 264, yt - 28, { h = L.gentian.hi, b = L.gentian.base, s = L.fern.base }, { rim = false })
  px(258, yt - 33, L.gold.hi)
  -- windows (arrow slits + one lit window), the bridge door, the main door
  for _, w in ipairs({ { 240, 60 }, { 228, 92 }, { 252, 84 } }) do fill(rect(w[1] - 1, w[2], w[1], w[2] + 8), S.edge) px(w[1] - 1, w[2], S.deep) end
  F.window(237, 96, 243, 102, T, true)
  hline(236, 244, 103, S.hi)
  -- the side door onto the rope bridge
  local sd = rect(218, 72, 223, 84):add(c:ellipse(220, 72, 2, 2))
  c:rim(sd, S.edge) fill(sd, T.deep) vline(219, 72, 84, T.shade) px(222, 78, IR.hi)
  hline(216, 225, 85, S.hi)
  -- banner hanging from the corbel
  local ban = poly{ { 228, yt + 3 }, { 236, yt + 3 }, { 236, yt + 24 }, { 232, yt + 20 }, { 228, yt + 24 } }
  rimOf(ban, L.accent) part(ban, L.accent)
  F.edelweiss(232, yt + 10, true)
  -- icicles under the corbels on the shaded side
  for _, ix in ipairs({ 252, 257, 262 }) do vline(ix, yt + 4, yt + 5 + ix % 3, L.snow.shade) px(ix, yt + 4, L.snow.hi) end

  -- the crag the tower stands on: rock buttresses wrap the foot
  local cl = poly{ { 194, 131 }, { 198, 120 }, { 204, 110 }, { 212, 104 }, { 218, 108 }, { 222, 118 }, { 226, 131 } }
  local cr = poly{ { 254, 131 }, { 258, 116 }, { 262, 108 }, { 268, 103 }, { 276, 108 }, { 284, 120 }, { 288, 131 } }
  crag(cl, 210, 16, 71, .4)
  crag(cr, 270, 17, 73, .4)
  -- rock-cut steps up to the door
  for k = 0, 2 do
    local st = rect(230 - k * 2, 124 + k * 2, 250 + k * 2, 125 + k * 2)
    fill(st, S.base) hline(230 - k * 2, 250 + k * 2, 124 + k * 2, S.hi) hline(230 - k * 2, 250 + k * 2, 125 + k * 2, S.shade)
  end
  F.door(233, 108, 247, 123, T, true)
  -- iron lantern by the door
  fill(rect(250, 110, 252, 113), G.base) px(250, 110, G.hi) c:rim(rect(250, 110, 252, 113), IR.edge) px(251, 109, IR.base)
  -- edelweiss and gentian in the rock cracks
  F.edelweiss(206, 118, true) F.gentian(274, 116, true) F.edelweiss(280, 124, true) F.gentian(200, 126, true)
  -- a goat on the right buttress
  F.goat(272, 106, { k = .5, flip = true, noShadow = true })
  F.goat(206, 112, { k = .42, r = L.chamois, noShadow = true })
end
tower()

---------------------------------------------------------------- the rope bridge from the needle to the tower's side door
F.depth(2)
do
  local ax, ay, bx, by = 178, 88, 218, 84
  local function dy(x, sag) local t = (x - ax) / (bx - ax) return floor(ay + (by - ay) * t + sag * 4 * t * (1 - t) + .5) end
  -- back hand rope (lighter, behind), suspenders, planks, front hand rope
  for x = ax, bx do px(x, dy(x, 5) - 8, L.needle.shade) end
  for x = ax + 2, bx - 2, 3 do vline(x, dy(x, 5) - 7, dy(x, 7) - 1, L.needle.deep) end
  for x = ax, bx do
    local y = dy(x, 7)
    local k = (x - ax) % 3
    px(x, y, k == 0 and T.edge or (hash(x, 1, 9) < .5 and L.board.hi or L.board.base))
    px(x, y + 1, k == 0 and T.edge or L.board.shade)
    px(x, y + 2, T.edge)
  end
  px(197, dy(197, 7), L.sky[4]) px(197, dy(197, 7) + 1, T.edge) -- a missing plank
  for x = ax, bx do px(x, dy(x, 6) - 6, L.needle.deep) end
  F.snow(rect(ax, dy(ax, 7), bx, dy(ax, 7)), 0, 1)
end

---------------------------------------------------------------- prayer flags: tower to needle, flagpole down to the rampart
F.depth(2)
prayer(212, 36, 162, 47, 7, 0)
prayer(260, 15, 362, 96, 12, 2)
local rp = rect(362, 94, 363, 126) rimOf(rp, T) part(rp, T, { nopop = true, noshade = true }) px(362, 93, L.gold.hi)

-- spruces and a larch at the foot of the crags (clear of the bridge)
F.depth(2)
F.tree(296, 132, 50, 0)
F.larch(310, 134, 38, 5)
F.tree(124, 134, 34, 2)

---------------------------------------------------------------- pennant poles lining the road
local function banner(x, yb, s, r)
  local h = floor(30 * s)
  local pole = rect(x, yb - h, x + math.max(1, floor(s)), yb)
  local fl = poly{ { x + 1, yb - h + 1 }, { x + 1 + floor(9 * s), yb - h + 1 }, { x + 1 + floor(9 * s), yb - h + floor(16 * s) }, { x + 1 + floor(4.5 * s), yb - h + floor(12 * s) }, { x + 1, yb - h + floor(16 * s) } }
  F.shadow(x, x + 2, yb, floor(4 * s), 2)
  rimOf(union(pole, fl), T)
  part(pole, T, { nopop = true, noshade = true })
  pole:each(function(xx, y) if hash(y // 3, xx, 3) < .2 then px(xx, y, L.moss.base) end end) -- lichened larch poles
  part(fl, r, { nopop = s < 1 })
  if s >= 1 then F.sprite({ ".w.", "wgw", ".w." }, x + floor(4 * s) - 1, yb - h + 4, { w = L.edel.hi, g = L.gold.base }, { rim = false }) end
  px(x, yb - h - 1, L.gold.base)
  -- a little cairn at the foot
  local m = c:ellipse(x + 1, yb - 1, math.max(2, floor(3 * s)), 1) rimOf(m, S) part(m, S, { nopop = true })
end
for _, p in ipairs({ { 140, .55 }, { 166, .8 }, { 206, 1.2 } }) do
  local y, s = p[1], p[2]
  banner(floor(F.xl(y)) - floor(14 * s) - 4, y, s, L.awnA)
  banner(floor(F.xr(y)) + floor(6 * s), y, s, L.accent)
end

---------------------------------------------------------------- left: stone-and-larch guardhouse + rack + training dummy
F.depth(1)
F.tree(30, 140, 40, 3)
F.depth(2)
F.larch(166, 168, 44, 47)
F.depth(3)
local gt, gcx, gwall, groof = F.building{ x0 = 54, x1 = 150, yb = 168, wh = 40, rh = 26, wall = T, roof = L.roof, shingle = true, chimney = true, noFrame = true, noAttic = true }
local gboards = gwall:copy():clip(rect(54, gt + 2, 150, 149))
F.planks(gboards, T, 4, false, 23)
gboards:each(function(x, y) if y < gt + 8 and hash(x, y, 18) < .25 then px(x, y, T.deep) end end)
local gfoot = rect(54, 150, 150, 168)
part(gfoot, L.plaster, { nopop = true })
gfoot:each(function(x, y)
  local row = (y - 150) // 5
  local ry = (y - 150) % 5
  local bw = 7 + floor(hash(row, 1, 19) * 4)
  local rx = (x + row * 3) % bw
  if ry == 0 or rx == 0 then px(x, y, L.plaster.shade)
  elseif hash((x + row * 3) // bw, row, 20) < .3 then px(x, y, (ry == 1) and S.hi or S.base)
  elseif ry == 1 and rx == 1 then px(x, y, L.plaster.hi) end
  if y > 164 and hash(x, y, 21) < .35 then px(x, y, S.shade) end
end)
hline(54, 150, 149, T.edge)
part(union(rect(54, gt, 56, 149), rect(148, gt, 150, 149)), T, { nopop = true, noshade = true })
F.lichen(groof, .2, 84)
F.snow(groof, .35, 85)
for _, w in ipairs({ { 64, 124 }, { 84, 114 }, { 120, 114 }, { 140, 124 } }) do
  local ws = c:ellipse(w[1], w[2], 3, 2) rimOf(ws, S) part(ws, S, { nopop = true }) px(w[1] - 1, w[2] - 1, S.hi) px(w[1], w[2] - 2, L.snow.hi)
end
F.window(98, 112, 104, 118, T) -- gable window
F.door(94, 142, 108, 167, T, true)
F.smoke(141, 98, 6, .5, 2)
local wp = rect(17, 149, 18, 172) rimOf(wp, T) part(wp, T, { nopop = true, noshade = true })
F.washing(18, 150, 54, 146, { { "sock", L.awnA }, { "shirt", L.accent }, { "sock", L.roof } }, 5)
F.window(66, 140, 74, 147, T) F.window(126, 140, 134, 147, T)
-- window boxes with red geraniums
for _, wx in ipairs({ 70, 130 }) do
  hline(wx - 5, wx + 5, 149, T.base) hline(wx - 5, wx + 5, 150, T.deep)
  for k = -4, 4, 2 do px(wx + k, 148, L.leaf.base) px(wx + k + 1, 147, L.apple.base) px(wx + k, 147, k % 4 == 0 and L.apple.hi or L.leaf.hi) end
end
-- shield over the door: an edelweiss on gentian
local sh = poly{ { 95, 128 }, { 107, 128 }, { 107, 134 }, { 101, 139 }, { 95, 134 } }
rimOf(sh, L.gentian) part(sh, L.gentian)
F.edelweiss(101, 132, true)
-- red leather fire buckets on pegs between the door and the window
hline(111, 123, 152, T.edge)
for k = 0, 2 do
  local bx = 112 + k * 4
  local b = poly{ { bx, 154 }, { bx + 3, 154 }, { bx + 3, 159 }, { bx, 159 } }
  rimOf(b, L.apple) part(b, L.apple, { nopop = true }) px(bx, 154, L.apple.hi) hline(bx, bx + 3, 157, L.gold.shade)
  px(bx + 1, 153, T.edge) px(bx + 2, 153, T.edge)
end
-- a woodpile under the left window
for k = 0, 3 do F.logEnd(60 + k * 5, 164, 2) end
for k = 0, 2 do F.logEnd(62 + k * 5, 160, 2) end
-- skis and poles leaning by the door
for k = 0, 1 do
  local sx = 88 + k * 3
  vline(sx, 140, 167, L.board.base) vline(sx + 1, 140, 167, L.board.shade) px(sx, 139, L.board.hi) px(sx + 1, 138, L.board.hi)
end
vline(86, 146, 167, IR.base) px(86, 163, T.edge) px(85, 163, T.edge) px(87, 163, T.edge)

local function rack(x0, yb)
  local posts = rect(x0, yb - 26, x0 + 2, yb):add(rect(x0 + 40, yb - 26, x0 + 42, yb))
  local rails = rect(x0, yb - 24, x0 + 42, yb - 23):add(rect(x0, yb - 8, x0 + 42, yb - 7))
  F.shadow(x0, x0 + 42, yb, 8, 3)
  rimOf(union(posts, rails), T)
  for k = 0, 4 do
    local x = x0 + 6 + k * 7
    if k == 2 then -- an alpenhorn stood on its bell among the spears
      local tube = rect(x, yb - 44, x + 1, yb - 6)
      local bellM = poly{ { x - 1, yb - 7 }, { x + 2, yb - 7 }, { x + 5, yb - 1 }, { x - 4, yb - 1 } }
      local mp = rect(x - 1, yb - 46, x + 2, yb - 45)
      c:rim(union(tube, bellM, mp), T.edge)
      fill(tube, L.board.base) vline(x, yb - 44, yb - 6, L.board.hi)
      fill(bellM, L.board.base) hline(x - 3, x + 4, yb - 2, L.board.shade) px(x - 1, yb - 5, L.board.hi)
      fill(mp, T.deep)
      for _, by in ipairs({ yb - 36, yb - 24, yb - 12 }) do hline(x, x + 1, by, L.gentian.base) end -- painted bands
    else
      vline(x, yb - 34, yb - 1, L.board.base) vline(x + 1, yb - 34, yb - 1, L.board.shade)
      local tip = poly{ { x - 1, yb - 34 }, { x + 1, yb - 40 }, { x + 3, yb - 34 } } fill(tip, IR.hi) px(x + 2, yb - 34, IR.shade)
    end
  end
  part(posts, T, { nopop = true, noshade = true }) part(rails, T, { nopop = true, noshade = true })
  F.lichen(posts, .25, 86)
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
  -- dented pot helmet with an edelweiss stuck in it, a red scarf
  local hel = c:ellipse(x, yb - 37, 6, 3):clip(rect(x - 7, yb - 41, x + 7, yb - 36)) fill(hel, IR.base) hline(x - 6, x + 6, yb - 36, IR.deep) px(x - 3, yb - 39, IR.hi)
  vline(x + 5, yb - 42, yb - 39, L.fern.shade) F.edelweiss(x + 5, yb - 44, true)
  hline(x - 5, x + 5, yb - 27, L.awnA.base) px(x + 5, yb - 26, L.awnA.shade) px(x + 6, yb - 25, L.awnA.shade)
  px(x - 8, yb - 12, L.needle.hi) px(x + 8, yb - 14, L.needle.hi) px(x + 9, yb - 13, L.needle.base)
end
dummy(178, 208)

---------------------------------------------------------------- archery range, bottom-left: larch-slice targets
local function target(x, yb, s)
  local legs = line({ { x - 6 * s, yb }, { x, yb - 22 * s } }, 2):add(line({ { x + 6 * s, yb }, { x, yb - 22 * s } }, 2))
  local cy = floor(yb - 16 * s)
  local R = floor(10 * s)
  local face = c:ellipse(x, cy, R, R)
  F.shadow(floor(x - 6 * s), floor(x + 8 * s), yb, 6, 2)
  rimOf(union(legs, face), T)
  part(legs, T, { nopop = true, noshade = true })
  fill(face, L.redbark.base)
  local inner = c:ellipse(x, cy, R - 1, R - 1)
  fill(inner, L.board.base)
  inner:each(function(xx, yy)
    local d = math.sqrt((xx - x) ^ 2 + (yy - cy) ^ 2)
    if floor(d + .5) % 2 == 0 and d > 1 then px(xx, yy, L.board.shade) end -- growth rings
    if (xx - x) + (yy - cy) < -R * .8 then px(xx, yy, L.board.hi) end
  end)
  fill(c:ellipse(x, cy, floor(7 * s), floor(7 * s)):cut(c:ellipse(x, cy, floor(6 * s), floor(6 * s))), L.awnA.base)
  fill(c:ellipse(x, cy, floor(4 * s), floor(4 * s)):cut(c:ellipse(x, cy, floor(3 * s), floor(3 * s))), L.gentian.base)
  fill(c:ellipse(x, cy, math.max(1, floor(2 * s)), math.max(1, floor(2 * s))), L.awnA.base) px(x - 1, cy - 1, L.awnA.hi)
  px(x + floor(R * .6), cy - floor(R * .3), L.board.deep)
  px(x + floor(R * .6) + 1, cy - floor(R * .3) + 1, L.board.deep)
  for k = 0, 1 do local ax, ay = floor(x - 2 + k * 5), floor(cy - 2 + k * 4) fill(line({ { ax, ay }, { ax - 6, ay + 3 } }), L.board.deep) px(ax - 6, ay + 3, L.awnB.hi) px(ax - 7, ay + 3, L.awnB.hi) end
  grass(floor(x - 7 * s), yb + 1, 4, x) grass(floor(x + 8 * s), yb + 1, 3, x + 1)
end
target(40, 252, 1.2) target(82, 244, .9)
local _, ax, ay = F.gnome(150, 258, { hat = L.foliage, coat = L.roof2, arm = "out", flip = true })
fill(c:ellipse(ax - 1, ay, 2, 8):cut(c:ellipse(ax, ay, 1, 7)), T.base) vline(ax - 1, ay - 7, ay + 7, L.awnB.shade) -- bow
fill(line({ { ax - 1, ay }, { ax + 8, ay } }), L.board.deep) px(ax - 2, ay, IR.hi)
-- quiver of arrows in a granite block by the archer
local qs = F.boulder(168, 260, 5, 7, 87)
for k = 0, 2 do vline(166 + k * 2, 246, 253, L.board.deep) px(166 + k * 2, 245, L.awnB.hi) px(166 + k * 2, 246, L.awnA.base) end
-- junipers, boulders, edelweiss and gentian along the left edge
F.juniper(24, 216, 8, 5, 3) F.juniper(116, 224, 7, 4, 6)
F.boulder(102, 266, 8, 6, 88) F.boulder(18, 262, 6, 5, 89)
for _, f in ipairs({ { 30, 212 }, { 36, 216 }, { 58, 262 }, { 64, 264 }, { 124, 262 }, { 112, 216 } }) do F.edelweiss(f[1], f[2], true) end
for _, f in ipairs({ { 54, 264 }, { 130, 260 }, { 20, 222 }, { 120, 214 } }) do F.gentian(f[1], f[2], true) end

---------------------------------------------------------------- right: stone store, alarm bell, pigeon loft, telescope
local function bell(x0, yb)
  local posts = rect(x0, yb - 40, x0 + 3, yb):add(rect(x0 + 34, yb - 40, x0 + 37, yb))
  local beam = rect(x0 - 4, yb - 44, x0 + 41, yb - 40)
  local braces = line({ { x0 + 3, yb - 32 }, { x0 + 10, yb - 40 } }):add(line({ { x0 + 34, yb - 32 }, { x0 + 27, yb - 40 } }))
  local b = poly{ { x0 + 13, yb - 34 }, { x0 + 24, yb - 34 }, { x0 + 27, yb - 18 }, { x0 + 10, yb - 18 } }:add(c:rrect(x0 + 13, yb - 38, x0 + 24, yb - 31, 3))
  F.shadow(x0, x0 + 40, yb, 8, 3)
  rimOf(union(posts, beam, b, braces), T)
  part(posts, T, { nopop = true }) part(braces, T, { nopop = true, noshade = true }) part(beam, T) hline(x0 - 4, x0 + 41, yb - 44, T.hi)
  -- granite footing stones under the posts
  for _, fx in ipairs({ x0 + 1, x0 + 35 }) do local fs = c:ellipse(fx + 1, yb - 1, 4, 2) rimOf(fs, S) part(fs, S, { nopop = true }) end
  -- a slab hood over the beam, snow on it
  local hood = poly{ { x0 - 6, yb - 44 }, { x0 + 18, yb - 52 }, { x0 + 43, yb - 44 } }
  rimOf(hood, L.roof) part(hood, L.roof, { sep = true }) F.courses(hood, yb - 52, 3, 4, L.roof) F.lichen(hood, .2, 91) F.snow(hood, .5, 92)
  part(b, L.gold) hline(x0 + 10, x0 + 27, yb - 19, L.gold.deep) hline(x0 + 12, x0 + 25, yb - 26, L.gold.shade)
  b:each(function(x, y) if x < x0 + 15 and y < yb - 21 and y > yb - 36 then px(x, y, L.gold.hi) end end)
  vline(x0 + 18, yb - 40, yb - 38, T.edge)
  fill(rect(x0 + 18, yb - 18, x0 + 19, yb - 15), IR.base)
  vline(x0 + 26, yb - 18, yb - 4, L.board.deep) -- pull rope
end
F.depth(1)
F.tree(352, 136, 40, 2)
F.tree(442, 142, 54, 1)
local st, scx, swall, sroof = F.building{ x0 = 368, x1 = 424, yb = 146, wh = 22, rh = 16, wall = L.plaster, roof = L.roof, shingle = true, noFrame = true, noAttic = true }
F.courses(swall:copy():clip(rect(368, st + 2, 424, 146)), st + 2, 4, 9, L.plaster)
swall:each(function(x, y) if y > st + 2 and hash(x // 3, y // 3, 12) < .14 then px(x, y, S.base) end end)
F.lichen(sroof, .2, 93) F.snow(sroof, .4, 94)
F.door(390, 132, 400, 145, T, true) F.window(408, 131, 413, 136, T)
for k = 0, 2 do F.logEnd(376 + k * 4, 143, 2) end
F.depth(2)
F.goat(424, 184, { k = .6, graze = true, flip = true })
-- a stack of beacon logs waiting by the store, a chopping block with an axe bitten in
F.shadow(318, 352, 172, 6, 3)
for row = 0, 2 do for k = 0, 3 - row do F.logEnd(322 + k * 7 + row * 3, 168 - row * 6, 3) end end
F.snow(rect(325, 153, 342, 154), .6, 95)
grass(316, 173, 5, 7) grass(356, 172, 4, 8)
local stp2 = rect(366, 166, 374, 172) local stt2 = c:ellipse(370, 166, 4, 2)
rimOf(union(stp2, stt2), T) part(stp2, T, { nopop = true }) fill(stt2, L.board.base) px(370, 166, L.board.shade) F.lichen(stp2, .3, 98)
line({ { 368, 165 }, { 364, 158 } }):each(function(x, y) px(x, y, L.board.base) end)
fill(rect(367, 163, 371, 165), IR.base) px(367, 163, IR.hi)
bell(300, 196)
local _, bx, by = F.gnome(334, 206, { hat = L.produce, coat = L.lav, arm = "up", flip = true })
F.depth(3)
local function loft(x, yb)
  local post = rect(x - 1, yb - 40, x + 1, yb)
  local box = rect(x - 12, yb - 58, x + 12, yb - 40)
  local roofm = poly{ { x - 15, yb - 58 }, { x, yb - 68 }, { x + 15, yb - 58 } }
  F.shadow(x - 2, x + 4, yb, 6, 2)
  rimOf(union(post, box, roofm), T)
  part(post, T, { nopop = true, noshade = true }) part(box, L.board) F.planks(box, L.board, 4, true, 19)
  part(roofm, L.roof, { sep = true }) F.courses(roofm, yb - 68, 3, 4, L.roof) F.lichen(roofm, .22, 94) F.snow(roofm, .5, 96)
  for k = 0, 2 do local hx = x - 9 + k * 7 fill(c:rrect(hx, yb - 54, hx + 4, yb - 48, 2), T.edge) hline(hx - 1, hx + 5, yb - 47, T.base) end
  hline(x - 12, x + 12, yb - 45, L.board.deep)
  -- granite footing and a cairn of stones at the post foot
  local fs = c:ellipse(x + 1, yb - 1, 5, 2) rimOf(fs, S) part(fs, S, { nopop = true })
  F.gentian(x - 5, yb - 2, true) F.edelweiss(x + 7, yb - 1, true)
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
loft(440, 196)
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
F.crate(300, 254, 18, 12) F.crate(320, 256, 18, 12) F.crate(310, 242, 18, 10)
F.barrel(346, 258, T, 12)
-- a young spruce, juniper and flowers closing in on the right (clear of the compass corner)
F.conifer(368, 266, 30, L.foliage2, 41)
F.conifer(420, 228, 22, L.foliage2, 42)
F.juniper(450, 222, 8, 5, 13) F.juniper(290, 262, 7, 4, 14)
F.boulder(404, 226, 6, 5, 15)
for _, f in ipairs({ { 398, 214 }, { 412, 222 }, { 284, 258 }, { 356, 264 } }) do F.edelweiss(f[1], f[2], true) end
for _, f in ipairs({ { 394, 218 }, { 440, 226 }, { 350, 262 } }) do F.gentian(f[1], f[2], true) end
-- a lichened boulder by the road with a whistling marmot on top
F.boulder(286, 220, 10, 9, 97)
F.marmot(285, 211)
px(292, 198, L.edel.hi) px(294, 197, L.edel.base) px(295, 196, L.edel.hi) -- the whistle
F.gentian(296, 218, true)
-- guard with a spear on the road
local _, gx, gy = F.gnome(258, 242, { hat = L.iron, coat = L.awnA, arm = "hold" })
fill(rect(gx + 6, 204, gx + 6, 242), L.board.shade) fill(poly{ { gx + 5, 204 }, { gx + 6, 197 }, { gx + 8, 204 } }, IR.hi) -- spear
-- the guard's big mountain dog, chestnut and white, a tiny barrel at its collar
F.shadow(270, 288, 242, 4, 1)
F.sprite({
  ".BBB............",
  "BeWBB...........",
  "nWWWBB.........B",
  "nWWWWBBBBBBBBBBb",
  ".WWWWBBBBBBBBBbb",
  "..GWWWBBBBBBbbb.",
  "..gWWWWWWWWWbb..",
  "..WWWWWWWWWbbb..",
  "..WW.WW....Wb.b.",
  "..WW.WW....Wb.b.",
  "..WW.WW....Wb.b.",
  "..WW.WW....Wb.b.",
  "..WW.WW...WWb.bb",
}, 270, 230, { B = L.chamois.base, b = L.chamois.shade, W = L.goat.hi, e = T.edge, n = T.edge, G = L.gold.hi, g = L.gold.shade })
F.depth(0)
-- a golden eagle circling over the beacon smoke, choughs lower down
F.sprite({
  "dd.................dd",
  ".dd.......hh......dd.",
  "..ddl....hHHe...bdd..",
  "...dlllbbbbbbbbbbd...",
  ".....ddbbbbbbbdd.....",
  "........dbbbd........",
  "........tTTTt........",
  ".........ttt.........",
}, 318, 42, { d = "#4a3a30", b = "#7a5a3c", l = "#9a7650", h = L.gold.base, H = L.gold.hi, e = L.gold.shade, t = "#5a4434", T = "#8a6a48" }, { rim = false })
F.birds({ { 164, 44, 2 }, { 188, 52, 1 }, { 330, 70, 1 }, { 150, 62, 1 } })
F.finish()
