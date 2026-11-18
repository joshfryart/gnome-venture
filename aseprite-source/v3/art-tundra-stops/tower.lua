-- tower.lua : "Watchtower" stop look, TUNDRA (tundra_frost), 480x270 gate view.
-- Same composition and story as the Maplewold watchtower (art-2701-batch3/stops/opus3/tower.lua), re-cast for an
-- arctic tundra: road's end: a tapering granite-rubble beacon and aurora-watch tower lashed with driftwood ring
-- beams, a snow-capped crenel ring, a driftwood tripod holding a burning iron beacon basket, a sentry waving, a
-- red pennant, a driftwood jib hoisting a net of peat. A strong green-lilac aurora hangs over it in the pale sky.
-- A dry-stone dyke runs off along the horizon. Left: a lime-rendered guardhouse with a slate roof, falu-red door and
-- shutters, frozen-stiff washing, skis; a spear and shield rack with snowshoes, a SNOWMAN training dummy in a pot
-- helmet, coiled-sedge archery targets. Right: a turf-shouldered store, a whale-jawbone bell arch, a brass telescope
-- aimed at the aurora, driftwood bundles and peat, crates, a whale-oil barrel, the guard and his husky, musk oxen.
-- A snowy owl glides past the tower. Quirk: a ptarmigan in a red gnome hat landing on the message box with a scroll.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-tundra-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "tower", out = DIR, farTrees = { 24, 52, 100, 380, 440 },
  treeLineGap = { 196, 284 }, clouds = { { 96, 46, 40 }, { 330, 60, 44 }, { 20, 64, 30 } },
  peaks = { { 116, 36, 44 }, { 162, 22, 26 }, { 330, 42, 50 }, { 404, 30, 34 }, { 462, 46, 44 }, { 12, 22, 26 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local S, IR, G, T, SN = L.stone, L.iron, L.glow, L.timber, L.snow
local BONE = F.rp("#f2ead6 #dccdb0 #b8a686 #8a7a64 #564a42")
local PEAT = F.rp("#9a7a62 #7a5a48 #5c4238 #42302c #2a1e20")
local SEDGE = F.rp("#ecdca6 #d0b878 #aa9056 #7c6a44 #4c4232")
local OX = F.rp("#8a7262 #6a5244 #4e3c34 #382a26 #22191a")

---------------------------------------------------------------- a stronger aurora: two bright curtains (sky pixels only)
do
  local sky = {}
  for _, h in ipairs(L.sky) do sky[h:lower()] = true end
  for _, h in ipairs(L.aurora) do sky[h:lower()] = true end
  local A = { "#88d0b0", "#a2dcc0", "#bce8d0", "#aea6dc", "#c0b6e6", "#d0c8ec" }
  for k, au in ipairs({ { 14, 46, 120, 470, 0 }, { 30, 34, 230, 440, 90 }, { 44, 30, 330, 479, 40 } }) do
    for x = au[3], au[4] do
      local yc = floor(au[1] + 6 * sin((x + au[5]) / au[2]) + 3 * sin(x / 13 + k))
      local on = F.vnoise(x / 8, k * 7, 141)
      local len = 8 + floor(F.vnoise(x / 6, k, 142) * 16)
      if on > .38 then
        local ray = hash(x // 2, k, 143) < .35
        for y = yc, yc + len do
          local v = c:get(x, y)
          if v and sky[v:lower()] then
            local t = (y - yc) / len
            local col
            if t < .12 then col = A[3] elseif t < .45 then col = ray and A[3] or A[2] elseif t < .62 then col = A[1]
            elseif t < .82 then col = ray and A[6] or A[5] else col = A[4] end
            if on < .46 and t > .45 then col = nil end
            if col and t > .7 and hash(x, y, 144) < .35 then col = nil end
            if col then px(x, y, col) end
          end
        end
      end
    end
  end
end

---------------------------------------------------------------- dry-stone dyke along the horizon
local function dyke(x0, x1, yb, h, seed)
  local m = HP.mask()
  for x = x0, x1 do
    local hh = h + floor(F.vnoise(x / 9, seed, 3) * 4) - 1
    if not (x > x0 + 30 and x < x0 + 36) then m:add(rect(x, yb - hh, x, yb)) end -- a tumbled gap
  end
  F.shadow(x0, x1, yb, 3, 2)
  rimOf(m, S) part(m, S)
  F.rubble(m, S, yb - h - 3, 4, seed)
  F.snowCap(m, 2, seed, { cx = x0 - 999 })
  -- tumbled stones in the gap, a drift banked on the lee
  for k = 0, 2 do local r = c:rrect(x0 + 30 + k * 2, yb - 2 - (k % 2) * 2, x0 + 33 + k * 2, yb, 1) c:rim(r, S.edge) part(r, S, { nopop = true }) end
  F.drift(x0 + 20, yb + 2, 14, 3, seed)
end
F.depth(1)
dyke(116, 206, 126, 9, 31)
dyke(276, 372, 126, 9, 37)
for _, w in ipairs({ { 132, 128, 4, 4 }, { 300, 129, 5, 4 }, { 356, 129, 4, 3 } }) do F.willow(w[1], w[2], w[3], w[4], w[1]) end
F.cairn(110, 128, 12, 9)

---------------------------------------------------------------- musk oxen far right, heads down in the wind
local function muskox(x, yb, flip)
  local s = flip and -1 or 1
  local body = c:ellipse(x, yb - 5, 6, 4):add(rect(x - 6, yb - 4, x + 6, yb - 1))
  local hump = c:ellipse(x + 2 * s, yb - 8, 3, 2)
  local head = flip and rect(x - 9, yb - 5, x - 6, yb - 1) or rect(x + 6, yb - 5, x + 9, yb - 1)
  local legs = rect(x - 4, yb, x - 4, yb):add(rect(x + 3, yb, x + 3, yb))
  local m = union(body, hump, head, legs)
  c:rim(m, OX.edge) part(m, OX, { nopop = true })
  m:each(function(xx, yy) if yy >= yb - 1 and hash(xx, yy, 7) < .6 then px(xx, yy, OX.deep) end end) -- long skirt
  hline(x - 3, x + 3, yb - 9, OX.hi) px(x + 1, yb - 7, "#b49c84") px(x + 2, yb - 7, "#b49c84") -- pale saddle
  local hx = x + 7 * s
  px(hx, yb - 5, BONE.base) px(hx + s, yb - 4, BONE.base) px(hx - s, yb - 6, BONE.hi) -- horn boss
  px(x - 4, yb, OX.edge) px(x + 3, yb, OX.edge)
end
F.depth(1)
for _, m in ipairs({ { 318, 135, false }, { 333, 132, true }, { 346, 137, false }, { 456, 131, false } }) do muskox(m[1], m[2], m[3]) end
F.tracks({ { 352, 142 }, { 372, 150 } }, "deer", 5)

---------------------------------------------------------------- the beacon / aurora-watch tower
local function tower()
  F.depth(2)
  local x0, x1, yb, yt = 214, 266, 128, 54
  local body = poly{ { x0, yb }, { x1, yb }, { x1 - 6, yt }, { x0 + 6, yt } }
  local cor = rect(x0 - 2, yt - 7, x1 + 2, yt)
  local cren = HP.mask()
  for x = x0 - 2, x1 - 2, 8 do cren:add(rect(x, yt - 15, x + 4, yt - 7)) end
  F.shadow(x0, x1, yb + 1, 12, 4)
  -- driftwood tripod + beacon basket behind the crenels
  local legs = line({ { 230, yt - 7 }, { 239, yt - 27 } }, 2):add(line({ { 250, yt - 7 }, { 241, yt - 27 } }, 2)):add(line({ { 240, yt - 7 }, { 240, yt - 27 } }, 1))
  local basket = poly{ { 231, yt - 34 }, { 249, yt - 34 }, { 246, yt - 26 }, { 234, yt - 26 } }
  rimOf(union(legs, basket), T)
  part(legs, T, { nopop = true }) legs:each(function(x, y) if hash(x, y // 3, 4) < .3 then px(x, y, T.hi) end end)
  part(basket, IR) for x = 233, 247, 3 do vline(x, yt - 33, yt - 27, IR.deep) end hline(231, 249, yt - 34, IR.hi)
  hline(234, 246, yt - 30, IR.edge)
  local fire = poly{ { 231, yt - 34 }, { 234, yt - 42 }, { 237, yt - 38 }, { 240, yt - 50 }, { 243, yt - 39 }, { 246, yt - 45 }, { 249, yt - 34 } }
  fill(fire, G.shade) fill(poly{ { 234, yt - 34 }, { 240, yt - 46 }, { 246, yt - 34 } }, G.base) fill(poly{ { 237, yt - 34 }, { 240, yt - 41 }, { 243, yt - 34 } }, G.hi)
  for i = 0, 6 do px(230 + floor(hash(i, 1, 2) * 22), yt - 48 - floor(hash(i, 2, 2) * 8), i % 2 == 0 and G.hi or G.base) end
  F.smoke(246, yt - 52, 5, .8, 2)
  -- the tower body
  rimOf(union(body, cor, cren), S)
  part(body, S)
  local tint = { L.lichen, L.greyMoss, L.rust }
  body:each(function(x, y)
    local t = (x - 240) / 26
    local yy = y - floor(3 * (1 - t * t))
    local row = (yy - yt) // 6
    local ry = (yy - yt) % 6
    local off = floor(hash(row, 1, 70) * 9)
    local sw = 7 + floor(hash(row, 2, 70) * 5)
    local st = (x + off) // sw
    local sx = (x + off) % sw
    local v = hash(st, row, 71)
    local h = v < .28 and S.hi or (v > .8 and S.shade or S.base)
    if v > .93 then h = "#b8b0b8" end
    local tv = hash(st, row, 72)
    if tv < .16 and hash(x, y, 73) < .7 then h = tint[1 + floor(tv * 19) % 3].base end
    if ry == 5 or (sx == 0 and hash(st, row, 74) < .85) then h = S.deep
    elseif ry == 0 and t < .3 then h = S.hi
    elseif sx == sw - 1 then h = S.shade end
    if ry == 0 and hash(x // 2, row, 75) < .45 then h = SN.base end -- frost on the course tops
    if t > .55 and (x + y) % 2 == 0 and h ~= S.deep then h = S.shade end
    if t > .82 then h = (h == S.deep) and S.edge or S.deep end
    if t < -.7 and ry == 1 then h = SN.hi end
    if y > yb - 10 and (ry == 5 or (x + off) % 15 == 0) then h = S.edge end -- big plinth blocks
    px(x, y, h)
  end)
  -- driftwood ring beams lashed round the tower, snow on top, icicles below
  for _, ry in ipairs({ 76, 96 }) do
    local w0 = floor(x0 + 6 * (yb - ry) / (yb - yt)) - 1
    local w1 = floor(x1 - 6 * (yb - ry) / (yb - yt)) + 1
    local bm = HP.mask()
    for x = w0, w1 do local tt = (x - 240) / 26 local dy = floor(3 * (1 - tt * tt)) bm:add(rect(x, ry + dy, x, ry + dy + 2)) end
    rimOf(bm, T) part(bm, T, { nopop = true })
    bm:each(function(x, y) if hash(x // 3, y, 76) < .25 then px(x, y, T.shade) end if x > 256 then px(x, y, T.shade) end end)
    F.snowCap(bm, 1, ry, { cx = 248 })
    F.icicles(w0 + 2, w1 - 2, ry + 5, 4, ry, .35)
    for x = w0 + 6, w1 - 4, 12 do local tt = (x - 240) / 26 local dy = floor(3 * (1 - tt * tt)) vline(x, ry + dy, ry + dy + 2, PEAT.deep) end -- lashings
  end
  part(cor, S, { sep = true })
  F.rubble(cor, S, yt - 7, 4, 77)
  for x = x0, x1, 5 do fill(rect(x, yt, x + 2, yt + 3), S.shade) px(x, yt, S.deep) px(x + 1, yt + 3, S.edge) end -- corbels
  F.icicles(x0 - 1, x1 + 1, yt + 4, 5, 78, .4)
  part(cren, S, { sep = true, nopop = true })
  cren:each(function(x, y) if (x - x0 + 2) % 8 >= 3 then px(x, y, S.shade) end end)
  F.snowCap(cren, 2, 79, { cx = 236, lip = true })
  F.snowCap(cor:copy():cut(rect(0, 0, 479, yt - 7)), 1, 80, { cx = 230 })
  -- sentry waving between the crenels (his breath steaming)
  F.gnome(222, yt - 8, { small = true, hat = L.awnA, coat = L.accent, arm = "up", noShadow = true })
  -- flag pole + red pennant with a white star (the north star)
  local pole = rect(258, yt - 36, 259, yt - 8) rimOf(pole, T) part(pole, T, { nopop = true, noshade = true }) px(258, yt - 37, L.gold.hi)
  local flag = poly{ { 260, yt - 35 }, { 283, yt - 31 }, { 276, yt - 28 }, { 283, yt - 24 }, { 260, yt - 24 } }
  rimOf(flag, L.awnA) part(flag, L.awnA)
  flag:each(function(x, y) if (x - 260) % 6 == 5 and hash(x, y, 81) < .6 then px(x, y, L.awnA.shade) end end)
  F.sprite({ ".s.", "sSs", ".s." }, 264, yt - 31, { s = L.awnB.base, S = L.awnB.hi }, { rim = false })
  hline(260, 266, yt - 35, SN.hi) -- frost on the hoist edge
  -- windows: arrow slits, one lamp-lit window, an arched door under snow with steps
  for _, w in ipairs({ { 240, 62 }, { 228, 84 }, { 252, 84 }, { 236, 104 } }) do fill(rect(w[1] - 1, w[2], w[1], w[2] + 7), S.edge) px(w[1] - 1, w[2], S.deep) px(w[1], w[2] + 7, G.shade) end
  F.window(243, 100, 249, 106, T, true)
  hline(242, 250, 109, SN.hi)
  F.door(233, 112, 247, 127, L.wall2, true)
  for k = 0, 1 do hline(230 - k * 2, 250 + k * 2, 126 + k, k == 0 and SN.hi or SN.base) end
  F.drift(222, 129, 8, 3, 83) F.drift(262, 129, 7, 3, 84)
  -- rust lichen creeping up the left side
  for i = 0, 40 do
    local y = 128 - floor(hash(i, 3, 5) * 58)
    local x = x0 + 1 + floor(hash(i, 4, 5) * 7) + floor((128 - y) * 6 / 74)
    if body:has(x, y) then px(x, y, L.rust.base) px(x + 1, y, L.rust.shade) px(x, y - 1, L.lichen.hi) end
  end
  -- banner hanging from the corbel ring: blue with the white north star
  local ban = poly{ { 222, yt + 4 }, { 230, yt + 4 }, { 230, yt + 24 }, { 226, yt + 20 }, { 222, yt + 24 } }
  rimOf(ban, L.accent) part(ban, L.accent)
  F.sprite({ "..s..", ".sSs.", "sSSSs", ".sSs.", "..s.." }, 224, yt + 8, { s = L.awnB.base, S = L.awnB.hi }, { rim = false })
  -- driftwood jib on the left with a rope hoisting a net of peat blocks
  local jib = line({ { 213, yt - 4 }, { 196, yt - 10 } }, 2):add(line({ { 213, yt + 6 }, { 199, yt - 8 } }, 1))
  rimOf(jib, T) part(jib, T, { nopop = true, noshade = true }) F.snowCap(jib, 1, 85, { cx = 240 })
  vline(197, yt - 8, 82, PEAT.edge)
  local net = c:rrect(191, 82, 203, 92, 3)
  rimOf(net, PEAT) part(net, PEAT)
  net:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, PEAT.edge) elseif (x - y) % 4 == 0 then px(x, y, PEAT.hi) end end)
  hline(193, 201, 82, SN.hi)
  -- a lookout gnome hauling the jib rope inside the crenels
end
tower()

-- stunted spruces at the tower foot
F.depth(2)
F.tree(184, 130, 44, 0)
F.tree(290, 131, 48, 1)
F.tree(300, 130, 34, 3)

---------------------------------------------------------------- pennant poles lining the road (driftwood, rimed)
local function banner(x, yb, s, r)
  local h = floor(30 * s)
  local pole = rect(x, yb - h, x + math.max(1, floor(s)), yb)
  local fl = poly{ { x + 1, yb - h + 1 }, { x + 1 + floor(9 * s), yb - h + 1 }, { x + 1 + floor(9 * s), yb - h + floor(16 * s) }, { x + 1 + floor(4.5 * s), yb - h + floor(12 * s) }, { x + 1, yb - h + floor(16 * s) } }
  F.shadow(x, x + 2, yb, floor(4 * s), 2)
  rimOf(union(pole, fl), T)
  part(pole, T, { nopop = true, noshade = true })
  pole:each(function(xx, y) if hash(y // 2, xx, 3) < .25 then px(xx, y, T.hi) end end)
  part(fl, r, { nopop = s < 1 })
  if s >= 1 then F.sprite({ ".s.", "sss", ".s." }, x + floor(4 * s) - 1, yb - h + 4, { s = L.awnB.hi }, { rim = false }) end
  hline(x + 1, x + 1 + floor(9 * s), yb - h + 1, SN.hi) -- rime on the top hem
  px(x, yb - h - 1, L.gold.base)
  local mound = c:ellipse(x + 1, yb, math.max(2, floor(4 * s)), math.max(1, floor(1.5 * s)))
  fill(mound, SN.hi) hline(x + 1, x + 1 + math.max(2, floor(4 * s)), yb, SN.shade)
end
for _, p in ipairs({ { 140, .55 }, { 166, .8 }, { 206, 1.2 } }) do
  local y, s = p[1], p[2]
  banner(floor(F.xl(y)) - floor(14 * s) - 4, y, s, L.awnA)
  banner(floor(F.xr(y)) + floor(6 * s), y, s, L.accent)
end

---------------------------------------------------------------- left: lime-rendered guardhouse
F.depth(1)
F.tree(30, 140, 40, 0)
F.tree(12, 146, 34, 2)
F.depth(3)
local gt, gcx, gwall, groof = F.building{ x0 = 54, x1 = 150, yb = 168, wh = 40, rh = 26, wall = L.plaster, roof = L.roof2, shingle = true, chimney = true, noFrame = true, snow = 5, icicles = 6 }
local gfoot = rect(54, 160, 150, 168) part(gfoot, S, { nopop = true }) F.rubble(gfoot, S, 160, 4, 61)
hline(54, 150, 159, T.edge)
local gcorn = union(rect(54, gt, 56, 159), rect(148, gt, 150, 159)) part(gcorn, T, { nopop = true, noshade = true })
gcorn:each(function(x, y) if hash(x, y // 3, 62) < .3 then px(x, y, T.shade) end end)
-- falu-red door and shutters
F.door(94, 142, 108, 167, L.wall2, true)
hline(92, 110, 141, SN.hi)
for _, w in ipairs({ { 66, 140, 74, 147 }, { 126, 140, 134, 147 } }) do
  F.window(w[1], w[2], w[3], w[4], T)
  for _, sx in ipairs({ w[1] - 6, w[3] + 2 }) do
    local sh = rect(sx, w[2] - 1, sx + 3, w[4] + 1) rimOf(sh, L.wall2) part(sh, L.wall2, { nopop = true })
    hline(sx, sx + 3, (w[2] + w[4]) // 2, L.wall2.deep) px(sx + 1, w[2], L.wall2.hi)
  end
  hline(w[1] - 3, w[3] + 3, w[4] + 2, SN.hi) hline(w[1] - 2, w[3] + 2, w[4] + 1, SN.base)
end
F.window(98, 112, 104, 118, T) -- gable window
F.smoke(141, 100, 6, .6, 2)
-- shield over the door: the north star on blue
local sh = poly{ { 95, 128 }, { 107, 128 }, { 107, 134 }, { 101, 139 }, { 95, 134 } }
rimOf(sh, L.accent) part(sh, L.accent)
F.sprite({ "..s..", ".sSs.", "..s.." }, 99, 130, { s = L.awnB.base, S = L.awnB.hi }, { rim = false })
-- skis and poles leaning by the door
for k = 0, 1 do
  local sk = line({ { 113 + k * 4, 167 }, { 116 + k * 4, 136 } }, 1)
  rimOf(sk, T) fill(sk, k == 0 and L.wall2.base or L.board.base) px(116 + k * 4, 135, k == 0 and L.wall2.hi or L.board.hi)
end
vline(122, 144, 167, IR.shade) px(121, 162, IR.base) px(123, 162, IR.base)
-- drift against the left wall, a peat stack under the left window
F.drift(60, 172, 12, 5, 63)
for row = 0, 1 do for k = 0, 3 - row do
  local b = rect(78 + k * 4 + row * 2, 162 - row * 3, 81 + k * 4 + row * 2, 164 - row * 3) c:rim(b, PEAT.edge) part(b, PEAT, { nopop = true })
end end
hline(80, 92, 158, SN.hi)
-- frozen-stiff washing (icicles off the hems)
local wp = rect(17, 149, 18, 172) rimOf(wp, T) part(wp, T, { nopop = true, noshade = true }) F.snowCap(wp, 1, 64)
F.washing(18, 150, 54, 146, { { "sock", L.awnA }, { "shirt", L.accent }, { "sock", L.lichen } }, 5)
F.icicles(22, 50, 160, 3, 65, .3)

---------------------------------------------------------------- spear rack with shields and snowshoes
local function rack(x0, yb)
  local posts = rect(x0, yb - 26, x0 + 2, yb):add(rect(x0 + 40, yb - 26, x0 + 42, yb))
  local rails = rect(x0, yb - 24, x0 + 42, yb - 23):add(rect(x0, yb - 8, x0 + 42, yb - 7))
  F.shadow(x0, x0 + 42, yb, 7, 3)
  rimOf(union(posts, rails), T)
  for k = 0, 4 do
    local x = x0 + 6 + k * 7
    vline(x, yb - 34, yb - 1, L.board.base) vline(x + 1, yb - 34, yb - 1, L.board.shade)
    if k == 2 then -- an ice axe among the spears
      fill(rect(x - 3, yb - 36, x + 5, yb - 35), IR.base) px(x - 3, yb - 34, IR.shade) px(x + 5, yb - 34, IR.shade) px(x - 2, yb - 36, IR.hi)
    else
      local tip = poly{ { x - 1, yb - 34 }, { x + 1, yb - 40 }, { x + 3, yb - 34 } } fill(tip, IR.hi) px(x + 2, yb - 34, IR.shade)
      px(x, yb - 33, BONE.base) -- bone collar
    end
  end
  part(posts, T, { nopop = true, noshade = true }) part(rails, T, { nopop = true, noshade = true })
  F.snowCap(union(posts:copy():clip(rect(0, yb - 26, 479, yb - 26)), rails:copy():clip(rect(0, yb - 24, 479, yb - 24)), rails:copy():clip(rect(0, yb - 8, 479, yb - 8))), 1, 66)
  for k, r in ipairs({ L.awnA, L.accent }) do
    local x = x0 + 50 + k * 13
    local m = c:ellipse(x, yb - 8, 7, 8)
    rimOf(m, r) part(m, r)
    c:ellipse(x, yb - 8, 4, 5):edge():each(function(xx, yy) px(xx, yy, L.awnB.base) end)
    fill(c:ellipse(x, yb - 8, 1, 1), IR.hi)
    hline(x - 4, x + 3, yb - 16, SN.hi)
  end
  -- a pair of snowshoes leaning on the left post
  for k = 0, 1 do
    local sx = x0 - 10 + k * 5
    local o = c:ellipse(sx, yb - 9, 3, 8)
    rimOf(o, T) fill(o, T.base)
    local inner = c:ellipse(sx, yb - 9, 2, 6) fill(inner, BONE.shade)
    inner:each(function(xx, yy) if (xx + yy) % 2 == 0 then px(xx, yy, T.deep) end end)
    px(sx - 1, yb - 15, T.hi)
  end
end
rack(60, 200)

---------------------------------------------------------------- the training dummy: a snowman in a pot helmet
local function snowman(x, yb)
  local b1 = c:ellipse(x, yb - 7, 9, 7)
  local b2 = c:ellipse(x, yb - 19, 7, 6)
  local hd = c:ellipse(x, yb - 30, 5, 5)
  local arms = line({ { x - 16, yb - 24 }, { x - 6, yb - 21 } }, 1):add(line({ { x + 6, yb - 21 }, { x + 15, yb - 27 } }, 1))
  arms:add(line({ { x - 13, yb - 24 }, { x - 15, yb - 28 } })):add(line({ { x + 12, yb - 25 }, { x + 13, yb - 29 } }))
  F.shadow(x - 6, x + 8, yb, 6, 2)
  local m = union(b1, b2, hd)
  rimOf(union(m, arms), SN)
  part(arms, T, { nopop = true, noshade = true })
  for _, ball in ipairs({ { b1, x, yb - 7, 9 }, { b2, x, yb - 19, 7 }, { hd, x, yb - 30, 5 } }) do
    ball[1]:each(function(xx, yy)
      local d = ((xx - ball[2]) + (yy - ball[3])) / ball[4]
      local h = d < -.7 and SN.hi or (d < .35 and SN.base or (d < .95 and SN.shade or SN.deep))
      if hash(xx, yy, 67) < .08 then h = SN.shade end
      px(xx, yy, h)
    end)
  end
  hline(x - 6, x + 6, yb - 13, SN.deep) hline(x - 5, x + 5, yb - 25, SN.deep)
  -- coal eyes and buttons, carrot nose
  px(x - 2, yb - 31, T.edge) px(x + 2, yb - 31, T.edge)
  for k = 0, 2 do px(x, yb - 22 + k * 3, T.edge) end
  hline(x + 1, x + 4, yb - 29, L.produce.base) px(x + 1, yb - 28, L.produce.shade)
  for k = -2, 2 do px(x + k, yb - 27 + (abs(k) == 2 and -1 or 0), T.deep) end
  -- red scarf
  local sc = rect(x - 5, yb - 26, x + 5, yb - 25):add(rect(x + 3, yb - 25, x + 5, yb - 19))
  fill(sc, L.awnA.base) hline(x - 5, x + 5, yb - 26, L.awnA.hi) vline(x + 5, yb - 24, yb - 19, L.awnA.shade)
  px(x + 3, yb - 19, L.awnA.deep) px(x + 5, yb - 18, L.awnA.deep)
  -- dented pot helmet
  local hel = c:ellipse(x, yb - 35, 6, 3):clip(rect(x - 7, yb - 39, x + 7, yb - 34))
  c:rim(hel, IR.edge) fill(hel, IR.base) hline(x - 6, x + 6, yb - 34, IR.deep) px(x - 3, yb - 37, IR.hi) px(x - 2, yb - 37, IR.hi)
  px(x + 3, yb - 36, IR.shade) hline(x - 3, x + 3, yb - 38, SN.hi)
  -- arrows stuck in his belly
  for k = 0, 1 do
    local ax, ay = x - 3 + k * 6, yb - 9 + k * 3
    fill(line({ { ax, ay }, { ax + 7, ay - 3 } }), L.board.deep) px(ax + 7, ay - 3, L.awnA.base) px(ax + 8, ay - 3, L.awnA.hi)
  end
end
snowman(178, 208)

---------------------------------------------------------------- archery: coiled-sedge targets on driftwood legs
local function target(x, yb, s)
  local legs = line({ { x - 6 * s, yb }, { x, yb - 22 * s } }, 2):add(line({ { x + 6 * s, yb }, { x, yb - 22 * s } }, 2))
  local cy = floor(yb - 16 * s)
  local R = floor(10 * s)
  local face = c:ellipse(x, cy, R, R)
  F.shadow(floor(x - 6 * s), floor(x + 8 * s), yb, 6, 2)
  rimOf(union(legs, face), T)
  part(legs, T, { nopop = true, noshade = true })
  fill(face, SEDGE.base)
  face:each(function(xx, yy)
    local d = math.sqrt((xx - x) ^ 2 + (yy - cy) ^ 2)
    if floor(d) % 2 == 0 then px(xx, yy, SEDGE.shade) end -- the straw coils
    if (xx - x) + (yy - cy) < -R * .8 then px(xx, yy, SEDGE.hi) end
    if (xx - x) + (yy - cy) > R * .9 then px(xx, yy, SEDGE.deep) end
  end)
  fill(c:ellipse(x, cy, floor(7 * s), floor(7 * s)):cut(c:ellipse(x, cy, floor(6 * s), floor(6 * s))), L.awnA.base)
  fill(c:ellipse(x, cy, floor(4 * s), floor(4 * s)):cut(c:ellipse(x, cy, floor(3 * s), floor(3 * s))), L.accent.base)
  fill(c:ellipse(x, cy, math.max(1, floor(2 * s)), math.max(1, floor(2 * s))), L.awnA.base) px(x - 1, cy - 1, L.awnA.hi)
  F.snowCap(face, 2, x, { cx = x + 2 })
  for k = 0, 1 do local ax, ay = floor(x - 2 + k * 5), floor(cy - 2 + k * 4) fill(line({ { ax, ay }, { ax - 6, ay + 3 } }), L.board.deep) px(ax - 6, ay + 3, L.awnA.hi) px(ax - 7, ay + 3, L.awnA.base) end
end
target(40, 252, 1.2) target(82, 244, .9)
local _, ax, ay = F.gnome(150, 258, { hat = L.lichen, coat = L.wall2, arm = "out", flip = true })
fill(c:ellipse(ax - 1, ay, 2, 8):cut(c:ellipse(ax, ay, 1, 7)), BONE.shade) vline(ax - 1, ay - 7, ay + 7, L.awnB.shade) -- antler bow
fill(line({ { ax - 1, ay }, { ax + 8, ay } }), L.board.deep) px(ax - 2, ay, IR.hi)
-- quiver of arrows in a snow heap
local qv = rect(164, 248, 168, 258) rimOf(qv, PEAT) part(qv, PEAT, { nopop = true })
for k = 0, 2 do vline(164 + k * 2, 241, 247, L.board.deep) px(164 + k * 2, 240, L.awnA.base) end
local hp = c:ellipse(166, 259, 7, 2) fill(hp, SN.base) hline(160, 166, 258, SN.hi) hline(167, 172, 260, SN.shade)
F.tracks({ { 130, 262 }, { 112, 250 }, { 96, 248 } }, "boot", 6)
F.tracks({ { 14, 236 }, { 40, 222 }, { 70, 220 } }, "hare", 8)
for _, w in ipairs({ { 22, 216, 6, 6 }, { 112, 224, 5, 5 }, { 120, 264, 6, 6 } }) do F.willow(w[1], w[2], w[3], w[4], w[1] + 5) end
F.snowCap(F.rock(100, 266, 8, 6), 3, 68)
F.snowCap(F.rock(14, 262, 7, 5), 2, 69)
-- sedge tufts poking through the snow by the targets
for i = 0, 6 do local x = 54 + i * 3 local h = 4 + floor(hash(i, 9, 52) * 5) vline(x, 258 - h, 258, i % 2 == 0 and L.fern.shade or L.fern.base) end

---------------------------------------------------------------- right: turf-shouldered store in the haze
F.depth(1)
F.tree(352, 136, 38, 2)
F.tree(446, 142, 50, 1)
local st, scx, swall, sroof = F.building{ x0 = 372, x1 = 420, yb = 146, wh = 22, rh = 16, wall = T, roof = L.roof, noFrame = true, noAttic = true, snow = 4 }
F.planks(swall, T, 3, false, 70)
for _, side in ipairs({ { 360, 373, -1 }, { 419, 432, 1 } }) do
  local sh2 = side[3] < 0 and poly{ { 360, 146 }, { 366, 130 }, { 373, 124 }, { 373, 146 } } or poly{ { 419, 124 }, { 426, 130 }, { 432, 146 }, { 419, 146 } }
  rimOf(sh2, L.roof) part(sh2, L.roof) F.sod(sh2, L.roof, 124, 380) F.snowCap(sh2, 3, side[1], { cx = 390 })
end
F.door(390, 132, 400, 145, L.wall2, true) F.window(408, 131, 413, 136, T)
hline(388, 402, 131, SN.hi)

---------------------------------------------------------------- whale-jawbone bell arch with a bronze bell
local function bellArch(x0, yb)
  local cx = x0 + 18
  local lb = HP.mask() local rb = HP.mask()
  local pl, pr = {}, {}
  for i = 0, 12 do
    local t = i / 12
    local dx = floor(15 * (1 - cos(t * pi / 2)) + .5)
    pl[#pl + 1] = { x0 + 2 + dx, yb - floor(t * 48) }
    pr[#pr + 1] = { x0 + 35 - dx, yb - floor(t * 48) }
  end
  lb:add(line(pl, 3)) rb:add(line(pr, 3))
  local beam = rect(cx - 1, yb - 47, cx + 1, yb - 41) -- iron hanger at the apex
  local b = poly{ { cx - 5, yb - 34 }, { cx + 5, yb - 34 }, { cx + 8, yb - 19 }, { cx - 8, yb - 19 } }:add(c:rrect(cx - 5, yb - 40, cx + 5, yb - 31, 3))
  F.shadow(x0, x0 + 38, yb, 8, 3)
  rimOf(union(lb, rb, beam, b), T)
  part(lb, BONE, { nopop = true }) part(rb, BONE, { nopop = true })
  union(lb, rb):each(function(x, y)
    if hash(x, y // 2, 88) < .12 then px(x, y, BONE.shade) end
    if (x < cx and not lb:has(x - 1, y)) then px(x, y, BONE.hi) end
    if (x > cx and not rb:has(x + 1, y)) then px(x, y, BONE.deep) end
  end)
  part(beam, IR, { nopop = true, noshade = true })
  F.snowCap(union(lb, rb), 2, 89, { cx = cx })
  part(b, L.gold) hline(cx - 8, cx + 8, yb - 20, L.gold.deep) hline(cx - 6, cx + 6, yb - 27, L.gold.shade)
  b:each(function(x, y) if x < cx - 3 and y < yb - 22 and y > yb - 38 then px(x, y, L.gold.hi) end end)
  hline(cx - 3, cx + 3, yb - 40, SN.hi) F.icicles(cx - 6, cx + 6, yb - 19, 3, 87, .4)
  fill(rect(cx, yb - 18, cx + 1, yb - 15), IR.base)
  vline(cx + 7, yb - 19, yb - 4, L.board.deep) -- pull rope
  -- vertebra stepping stones and a rib laid at the foot
  for k = 0, 2 do local v = c:ellipse(x0 + 10 + k * 8, yb + 3, 2, 1) c:rim(v, BONE.edge) fill(v, BONE.base) px(x0 + 9 + k * 8, yb + 2, BONE.hi) end
  -- a stone footing round each jawbone
  for _, fx in ipairs({ x0 + 2, x0 + 35 }) do F.snowCap(F.rock(fx, yb + 1, 5, 4), 2, fx) end
end
F.depth(2)
bellArch(300, 196)
local _, bx, by = F.gnome(334, 206, { hat = L.produce, coat = L.lav, arm = "up", flip = true })
F.depth(3)

---------------------------------------------------------------- message box on a post + the quirk ptarmigan
local function msgbox(x, yb)
  local post = rect(x - 1, yb - 40, x + 1, yb)
  local box = rect(x - 12, yb - 58, x + 12, yb - 40)
  local roofm = poly{ { x - 15, yb - 57 }, { x, yb - 66 }, { x + 15, yb - 57 } }
  F.shadow(x - 2, x + 4, yb, 6, 2)
  rimOf(union(post, box, roofm), T)
  part(post, T, { nopop = true, noshade = true }) part(box, T) F.planks(box, T, 4, true, 19)
  part(roofm, L.roof2, { sep = true }) F.courses(roofm, yb - 66, 3, 4, L.roof2)
  F.snowCap(roofm, 3, 90, { cx = x, lip = true })
  F.icicles(x - 14, x + 14, yb - 56, 4, 91, .4)
  -- three pigeonhole slots with scrolls in them
  for k = 0, 2 do local hx = x - 9 + k * 7 fill(rect(hx, yb - 53, hx + 4, yb - 47), T.edge) px(hx + 1, yb - 49, L.awnB.base) px(hx + 2, yb - 49, L.awnB.hi) px(hx + 3, yb - 49, L.awnA.base) hline(hx - 1, hx + 5, yb - 46, SN.hi) end
  hline(x - 12, x + 12, yb - 43, T.deep)
  F.drift(x + 2, yb + 1, 9, 3, 92)
  -- quirk: a rock ptarmigan in a red gnome hat, wings up, landing with a cream scroll tied with red ribbon
  F.sprite({
    "K..............K",
    "KWw..........wWK",
    ".KWw...RR...wWK.",
    "..KWw.RRRr.wWK..",
    "...KWRRRRRrWK...",
    "....hhhhhhhh....",
    ".....WWWWWwy....",
    ".....WcWWEWmb...",
    "....WWWWWWWw....",
    "..kkWWWWWWw.....",
    ".kk.wWWWWw......",
    "......o.o.......",
    ".....sZRs.......",
    ".....sZZs.......",
  }, x - 8, yb - 86, { K = SN.edge, W = L.fur.hi, w = L.fur.shade, R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep,
    y = L.fur.base, c = L.fur.base, E = T.edge, m = L.apple.base, b = T.edge, k = T.edge, o = L.gold.shade,
    s = L.awnB.hi, Z = L.awnB.shade })
  px(x - 1, yb - 86 + 3, L.awnA.hi)
end
msgbox(440, 196)

---------------------------------------------------------------- brass telescope aimed up at the aurora, with its lookout
local tri = line({ { 362, 214 }, { 370, 196 } }):add(line({ { 378, 214 }, { 370, 196 } })):add(line({ { 370, 214 }, { 370, 196 } }))
local tube = line({ { 362, 200 }, { 382, 180 } }, 3)
rimOf(union(tri, tube), T) fill(tri, T.base) part(tube, L.gold) fill(rect(380, 177, 384, 181), L.gold.shade) px(363, 200, L.water.hi)
line({ { 365, 196 }, { 379, 182 } }):each(function(x, y) px(x, y, L.gold.hi) end)
hline(370, 373, 192, L.gold.deep)
F.gnome(354, 218, { hat = L.lav, coat = L.awnA, arm = "out" })
-- a star chart pinned on a board beside him
F.sign(390, 196, 14, 10, L.board)
F.sprite({ "a...b..", "..c...a", ".b..a..", "a..c..b" }, 384, 199, { a = L.accent.shade, b = L.awnA.base, c = L.gold.shade }, { rim = false })
hline(382, 398, 195, SN.hi)

---------------------------------------------------------------- driftwood beacon bundles, peat, crates, the whale-oil barrel
for k = 0, 2 do
  local x = 300 + k * 18
  local m = rect(x, 228, x + 14, 236) rimOf(m, T) part(m, T, { nopop = true })
  F.logs(m, T, 228, 3)
  m:each(function(xx, y) if hash(xx // 4, y, 93) < .2 then px(xx, y, T.hi) end end)
  fill(rect(x + 6, 228, x + 7, 236), PEAT.deep) -- rope tie
  F.logEnd(x + 14, 230, 1) F.logEnd(x + 14, 234, 1) F.logEnd(x + 13, 232, 1)
  hline(x + 1, x + 12, 227, SN.hi) hline(x + 2, x + 11, 228, SN.base)
end
-- peat stack
for row = 0, 2 do for k = 0, 3 - row do
  local b = rect(282 + k * 5 + row * 2, 224 - row * 4, 286 + k * 5 + row * 2, 227 - row * 4) c:rim(b, PEAT.edge) part(b, PEAT, { nopop = true })
  b:each(function(x, y) if hash(x, y, 94) < .2 then px(x, y, L.rust.shade) end end)
end end
hline(286, 296, 215, SN.hi)
for _, cr in ipairs({ { 300, 254, 18, 12 }, { 320, 256, 18, 12 }, { 310, 242, 18, 10 } }) do F.snowCap(F.crate(cr[1], cr[2], cr[3], cr[4]), 2, cr[1], { cx = cr[1] + 10 }) end
local brl = F.barrel(346, 258, T, 12) F.snowCap(brl, 2, 95)
px(343, 250, L.gold.base) px(344, 250, L.gold.shade) -- oil drip
F.willow(286, 262, 7, 7, 96) F.willow(356, 236, 5, 5, 97)
F.conifer(370, 266, 28, L.foliage2, 41)
F.conifer(424, 226, 22, L.foliage, 42)
F.willow(456, 224, 7, 8, 98) F.willow(404, 220, 5, 5, 99)

---------------------------------------------------------------- guard with a spear on the road, and his husky
local _, gx, gy = F.gnome(258, 242, { hat = L.awnA, coat = L.deer, arm = "hold" })
fill(rect(gx + 6, 204, gx + 6, 242), L.board.shade) fill(poly{ { gx + 5, 204 }, { gx + 6, 197 }, { gx + 8, 204 } }, IR.hi)
px(gx + 6, 205, BONE.base)
F.sprite({
  ".e.e........",
  ".ee.e.....TT",
  "dDDDd.....Tt",
  "dDnmDd...Tt.",
  "nWWWDDDDDDd.",
  ".WWbWDDDDDd.",
  "..WWWWWWWWd.",
  "..WW.WW.WW..",
  "..dd.dd.dd..",
}, 270, 234, { e = L.fur.deep, D = L.fur.deep, d = L.fur.edge, n = T.edge, m = L.accent.hi, W = L.fur.base, b = L.fur.shade, T = L.fur.base, t = L.fur.deep })
F.tracks({ { 282, 246 }, { 300, 262 } }, "bird", 5)
F.tracks({ { 286, 244 }, { 306, 262 } }, "hare", 7)

---------------------------------------------------------------- sky: a snowy owl gliding past the tower, ravens
F.depth(0)
F.sprite({
  "WW.................WW",
  "kWWW.............WWWk",
  ".kWWWW....WW...WWWWk.",
  "..kWsWWWWWWWWWWWsWk..",
  "...kWWsWWWyKyWWsWk...",
  ".....kkWWWWbWWWkk....",
  "........WsWsW........",
  ".........www.........",
}, 290, 70, { W = L.fur.hi, w = L.fur.shade, s = L.fur.deep, k = L.fur.edge, y = L.gold.hi, K = T.edge, b = T.edge }, { rimCol = SN.edge })
F.birds({ { 172, 44, 2 }, { 186, 52, 1 }, { 356, 92, 2 }, { 370, 86, 1 } })
F.finish()
