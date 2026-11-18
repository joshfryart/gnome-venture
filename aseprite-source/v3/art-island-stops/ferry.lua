-- ferry.lua : "Ferry crossing" stop look, ISLAND (island_palm), 480x270 gate view.
-- Same composition as the Maplewold ferry (art-2701-batch4/stops/opus3/ferry.lua), re-cast for a coral island:
-- a reef channel runs across the whole view (turquoise reef flats with coral heads on both sides, a deep blue
-- current in the middle) between our beach and a palm motu. The road stops at it on a black lava-stone landing.
-- Centre hero: a bamboo raft lashed over twin dugout hulls, riding a guide rope strung high across the channel
-- (a pulley block on a little mast), coming in: a ferryman poles it, a traveller with a pareo bundle and cargo ride
-- it, and a gnome on the landing hauls the tow line. Far motu: the road goes on past the ferryman's stilt fale
-- (bell post, tiki torch), a thatched hut with smoke, pareo washing, a gnome waving, leaning palms and a pandanus
-- over the water with a reef egret on the guide-rope post. In the channel: an outrigger fisher with a crab-claw sail,
-- a sea turtle with three hatchlings, a ray, reef fish. Near beach: bell under a thatch cap with a conch, a painted
-- ferry sign, a bamboo ticket booth, a driftwood bench of travellers, a beached outrigger, a barrow of pineapples,
-- cargo, spider lilies and mangroves at the waterline, a fisher, a blue-footed booby after a fish.
-- Quirk: a sea turtle in a red gnome hat, riding the ferry on a sea chest.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-island-stops/"
local F = dofile(DIR .. "_frame.lua")
  .build{ name = "ferry", out = DIR, roadTop = 178, farTrees = { 30, 70, 120, 150, 330, 352, 446 },
    clouds = { { 160, 42, 38 }, { 290, 32, 50 }, { 446, 48, 24 }, { 18, 80, 22 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local mix = F.mix
local S, D = L.lagoon, L.sea -- shallow reef flat / deep channel
local GLINT = "#f4f8e6"
local TURT = { hi = "#d6c878", base = "#9a9046", shade = "#706a36", deep = "#4e4a28", edge = "#2e2c1a" }
-- DY: a temporary vertical offset for whole near-bank groups (set, draw, reset)
local DY = 0
do local base = c.put c.put = function(self, x, y, h, o) base(self, x, y + DY, h, o) end end

local function yF(x) return 124 + floor(2 * sin(x / 31) + 1.5 * sin(x / 11)) end
local function yN(x) local t = (x - 240) / 240 return 177 + floor(14 * t * t + 3 * sin(x / 23) + 2 * sin(x / 9 + 1)) end

---------------------------------------------------------------- the reef channel
local river = HP.mask()
for x = 0, 479 do for y = yF(x), yN(x) do river:set(x, y) end end
local function fOf(x, y) return (y - yF(x)) / math.max(1, yN(x) - yF(x)) end
local function waterCol(x, y)
  local f = fOf(x, y)
  local w = .03 * sin(x / 17) + .02 * sin(x / 7 + 1)
  f = f + w
  if f < .07 then return hash(x // 4, y, 11) < .5 and S.hi or mix(S.hi, L.ground.hi, .45) end
  if f < .2 then return hash(x // 5, y, 12) < .25 and S.hi or S.base end
  if f < .29 then return hash(x // 4, y, 13) < .5 and S.shade or S.base end
  if f < .36 then return hash(x // 3, y, 14) < .5 and S.deep or D.hi end
  if f < .46 then return D.base end
  if f < .6 then return hash(x // 6, y // 2, 15) < .55 and D.shade or D.base end
  if f < .68 then return hash(x // 3, y, 16) < .5 and D.hi or D.base end
  if f < .76 then return hash(x // 4, y, 17) < .5 and S.deep or S.shade end
  if f < .9 then return S.shade end
  return hash(x // 5, y, 18) < .5 and S.base or S.shade
end
do
  river:each(function(x, y) px(x, y, waterCol(x, y)) end)
  -- coral heads and dark weed patches seen through the shallows (both reef flats)
  local function coralHead(cx, cy, rx, ry, seed)
    local m = c:ellipse(cx, cy, rx, ry)
    m:each(function(x, y)
      if river:has(x, y) then
        local w = waterCol(x, y)
        local v = hash(x, y, seed)
        local lit = (x - cx) / rx + (y - cy) / ry < -.3
        local col = mix(v < .5 and L.coral.base or L.coral.shade, w, .42)
        if lit then col = mix(L.coral.hi, w, .35) end
        if hash(x // 2, y, seed + 1) < .18 then col = mix(L.seagrass.shade, w, .45) end
        px(x, y, col)
      end
    end)
    m:edge():each(function(x, y) if river:has(x, y) and y > cy then px(x, y, mix(L.coral.deep, waterCol(x, y), .5)) end end)
  end
  for i = 0, 34 do
    local x = floor(hash(i, 1, 51) * 480)
    local near = i % 2 == 0
    local y = near and (yN(x) - 3 - floor(hash(i, 2, 51) * 9)) or (yF(x) + 3 + floor(hash(i, 2, 51) * 5))
    local rx = near and 3 + floor(hash(i, 3, 51) * 5) or 2 + floor(hash(i, 3, 51) * 3)
    coralHead(x, y, rx, math.max(1, rx // 2), 52 + i)
  end
  for i = 0, 40 do -- dark weed / rock shadows in the shallows
    local x = floor(hash(i, 1, 53) * 480)
    local y = yN(x) - 2 - floor(hash(i, 2, 53) * 12)
    if river:has(x, y) and fOf(x, y) > .78 then for k = 0, 2 + floor(hash(i, 3, 53) * 4) do px(x + k, y, mix(L.lava.base, waterCol(x + k, y), .55)) end end
  end
  -- current streaks: long thin lit lines drifting with the flow, longer nearer; pale on the flats, blue on the deep
  for y = 126, 194 do
    local d = y - 122
    if y % 3 == 0 then
      local x = floor(hash(y, 1, 13) * 30)
      while x < 480 do
        local len = 4 + d // 3 + floor(hash(x, y, 18) * 8)
        if hash(x // 9, y, 16) < .5 then
          for xx = x, x + len do
            if river:has(xx, y) and river:has(xx, y + 1) then
              local f = fOf(xx, y)
              local deep = f > .33 and f < .7
              px(xx, y, deep and D.hi or S.hi)
              if d > 22 then px(xx, y + 1, deep and D.deep or S.deep) end
            end
          end
        end
        x = x + len + 10 + floor(hash(x, y, 17) * 22)
      end
    end
  end
  for i = 0, 70 do local x, y = floor(hash(i, 1, 18) * 480), 126 + floor(hash(i, 2, 18) * 64) if river:has(x, y) and river:has(x + 1, y) then px(x, y, GLINT) px(x + 1, y, S.hi) end end
  -- far bank: sand, foam lip, a few black lava ledges; near bank: foam, wet sand, lava pebbles
  for x = 0, 479 do
    local lava = hash(x // 7, 1, 54) < .3
    px(x, yF(x) - 1, lava and L.lava.shade or L.ground.hi)
    px(x, yF(x), lava and L.lava.deep or L.surf) px(x, yF(x) + 1, lava and S.deep or (hash(x // 2, 2, 54) < .5 and L.surf or S.hi))
    local yn = yN(x)
    px(x, yn, hash(x // 3, 3, 54) < .6 and L.surf or S.hi)
    px(x, yn - 1, hash(x // 2, 4, 54) < .4 and L.surf or S.base)
    for k = 1, 4 do
      local col
      if k == 1 then col = L.duff elseif k == 2 then col = hash(x, k, 5) < .5 and L.ground.shade or L.duff
      else local w = hash(x, k, 5) col = w < .12 and L.lava.base or (w < .2 and L.shell.hi or (w < .45 and L.ground.hi or L.ground.base)) end
      px(x, yn + k, col)
    end
    if hash(x, 9, 6) < .12 then px(x, yn + 2, L.lava.shade) px(x, yn + 1, L.lava.hi) end
  end
end

---------------------------------------------------------------- shared island bits
-- tall sedge with spider lilies (white starburst heads) along the waterline
local function sedge(x, yb, n, hmax, seed, near)
  local blades, heads = {}, {}
  for i = 1, n do
    local bx = x + floor((hash(i, 1, seed) - .5) * n * 1.6)
    local h = floor(hmax * (.55 + .45 * hash(i, 2, seed)))
    local lean = (hash(i, 3, seed) - .5) * (near and 10 or 4)
    blades[#blades + 1] = { bx, h, lean, hash(i, 4, seed) }
  end
  local m = HP.mask()
  for _, b in ipairs(blades) do
    local bx, h, lean, v = b[1], b[2], b[3], b[4]
    local pts = { { bx, yb }, { bx + lean * .25, yb - h * .5 }, { bx + lean, yb - h } }
    m:add(line(pts, near and 2 or 1))
    if v < .4 then heads[#heads + 1] = { floor(bx + lean * .7), yb - h - 1 } end
  end
  if near then c:rim(m, L.seagrass.edge) end
  m:each(function(xx, yy)
    local t = (yb - yy) / hmax
    local hsh = hash(xx, yy, seed)
    local col = t > .6 and L.seagrass.hi or (t > .25 and L.seagrass.base or L.seagrass.shade)
    if not m:has(xx - 1, yy) and t > .3 then col = L.leaf.hi end
    if hsh < .2 then col = L.seagrass.shade elseif hsh > .92 then col = L.needle.base end
    if yy >= yb - 1 then col = L.seagrass.deep end
    px(xx, yy, col)
  end)
  for _, hd in ipairs(heads) do
    local hx, hy = hd[1], hd[2]
    if near then -- spider lily: six thin curling petals round a gold eye
      local pm = HP.mask()
      for _, d in ipairs({ { -3, -1 }, { -2, -3 }, { 0, -4 }, { 2, -3 }, { 3, -1 }, { -2, 1 }, { 2, 1 } }) do pm:add(line({ { hx, hy }, { hx + d[1], hy + d[2] } })) end
      c:rim(pm, L.shell.deep)
      pm:each(function(xx, yy) px(xx, yy, (xx < hx or yy < hy - 1) and L.shell.hi or L.shell.base) end)
      px(hx, hy, L.gold.base) px(hx, hy - 1, L.gold.hi)
    else
      px(hx, hy, L.shell.hi) px(hx - 1, hy, L.shell.base) px(hx + 1, hy, L.shell.shade) px(hx, hy - 1, L.shell.hi)
    end
  end
end
-- mangrove: arched stilt roots into the water, a dark glossy clump, hanging green propagules
local function mangrove(x, yb, w, h, seed)
  local roots = HP.mask()
  local ry = yb - floor(h * .35)
  for k = -3, 3 do roots:add(line({ { x + k, ry }, { x + k * 2 + (k > 0 and 1 or -1), ry + 3 }, { x + k * 3, yb } }, 1)) end
  local tr = line({ { x, ry }, { x - 1, yb - floor(h * .6) } }, 2)
  rimOf(union(roots, tr), L.timber)
  roots:each(function(xx, yy) px(xx, yy, xx < x and L.timber.hi or (hash(xx, yy, seed) < .3 and L.timber.deep or L.timber.base)) end)
  part(tr, L.timber, { nopop = true })
  for xx = x - 3 * 3 - 1, x + 3 * 3 + 1 do if hash(xx, 1, seed) < .5 then px(xx, yb - 1, L.seagrass.shade) end end -- weed at the root feet
  local m = F.crown(x, yb - floor(h * .7), w, floor(h * .32), L.foliage2, seed)
  F.crown(x - floor(w * .55), yb - floor(h * .58), floor(w * .45), floor(h * .2), L.foliage2, seed + 1)
  F.crown(x + floor(w * .55), yb - floor(h * .6), floor(w * .45), floor(h * .2), L.foliage2, seed + 2)
  for k = 1, floor(w / 2) do
    local kx = x - w + floor(hash(k, 1, seed) * w * 2)
    local ky = yb - floor(h * .5) + floor(hash(k, 2, seed) * 3)
    if hash(k, 3, seed) < .6 then vline(kx, ky, ky + 3, L.leaf.shade) px(kx, ky + 4, L.coconut.base) end
  end
  return m
end
-- pandanus (screw pine): stilt-rooted ringed trunk forking into arms, spiky sword-leaf tufts, orange fruit
local function pandanus(x, yb, h, seed, lean)
  local by = yb - floor(h * .28)
  local roots = HP.mask()
  for k = -2, 2 do roots:add(line({ { x, by }, { x + k * 2, yb - 3 }, { x + k * 3, yb } }, 1)) end
  local fork = { floor(x + lean * .5), yb - floor(h * .62) }
  local tips = { { fork[1] - floor(h * .26), yb - floor(h * .86) }, { fork[1] + floor(h * .24), yb - floor(h * .9) }, { fork[1] + floor(lean * .4), yb - h } }
  local trunk = line({ { x, by }, { floor(x + lean * .25), yb - floor(h * .45) }, fork }, 2)
  for _, t in ipairs(tips) do trunk:add(line({ fork, t }, 1)) end
  rimOf(union(roots, trunk), L.timber)
  part(trunk, L.palmTrunk, { nopop = true })
  trunk:each(function(xx, yy) if yy % 2 == 0 then px(xx, yy, L.palmTrunk.shade) end if not trunk:has(xx - 1, yy) then px(xx, yy, L.palmTrunk.hi) end end)
  roots:each(function(xx, yy) px(xx, yy, xx < x and L.palmTrunk.hi or L.palmTrunk.base) end)
  local lm, strokes = HP.mask(), {}
  for ti, t in ipairs(tips) do
    for k = 0, 10 do
      local a = -pi + k * pi / 10 + (hash(k, ti, seed) - .5) * .3
      local len = floor(h * (.16 + .1 * hash(k, ti + 4, seed)))
      local droop = (abs(cos(a)) > .5) and len * .45 or len * .1
      local p2 = { floor(t[1] + cos(a) * len * .6), floor(t[2] + sin(a) * len * .6) }
      local p3 = { floor(t[1] + cos(a) * len), floor(t[2] + sin(a) * len + droop) }
      local s = line({ t, p2, p3 }, 1)
      lm:add(s) strokes[#strokes + 1] = { s, a }
    end
  end
  c:rim(lm, L.foliage2.edge)
  for _, st in ipairs(strokes) do
    local lit = -cos(st[2]) * .5 - sin(st[2]) * .6
    st[1]:each(function(xx, yy)
      local col = lit > .3 and L.leaf.base or (lit > -.1 and L.foliage2.base or L.foliage2.shade)
      if hash(xx, yy, seed) < .15 then col = L.foliage2.hi end
      if hash(xx, yy, seed + 1) > .95 then col = L.needle.base end
      px(xx, yy, col)
    end)
  end
  -- a ripe fruit under the first tuft: an orange segmented ball
  local fx, fy = tips[1][1] + 1, tips[1][2] + 4
  local fm = c:ellipse(fx, fy, 3, 3) c:rim(fm, L.produce.edge) fill(fm, L.produce.base)
  fm:each(function(xx, yy) if (xx + yy) % 2 == 0 then px(xx, yy, L.produce.shade) end if xx < fx and yy < fy then px(xx, yy, L.produce.hi) end end)
  px(fx - 1, fy - 1, L.gold.hi)
  return lm
end
-- a sea turtle seen from above, swimming (shell, four flippers, head), with a ripple
local function seaTurtle(x, y, sz, flip)
  local s = flip and -1 or 1
  local shellM = c:ellipse(x, y, 3 * sz, 2 * sz)
  local fl = HP.mask()
  fl:add(poly{ { x + 2 * s * sz, y - sz }, { x + 5 * s * sz, y - 3 * sz }, { x + 3 * s * sz, y } })
  fl:add(poly{ { x + 2 * s * sz, y + sz }, { x + 5 * s * sz, y + 2 * sz }, { x + 3 * s * sz, y } })
  fl:add(poly{ { x - 2 * s * sz, y - sz }, { x - 4 * s * sz, y - 2 * sz }, { x - 3 * s * sz, y } })
  fl:add(poly{ { x - 2 * s * sz, y + sz }, { x - 4 * s * sz, y + 2 * sz }, { x - 3 * s * sz, y } })
  local head = c:ellipse(x + 4 * s * sz, y, sz, sz)
  local all = union(shellM, fl, head)
  c:rim(all, L.foliage2.edge)
  part(union(fl, head), L.seagrass, { nopop = true })
  part(shellM, TURT, { nopop = true })
  shellM:each(function(xx, yy)
    if (xx - x) % (2 + sz) == 0 or (yy - y) == 0 then px(xx, yy, TURT.deep) end
    if (xx - x) * s > 0 and yy < y then px(xx, yy, TURT.hi) end
  end)
  px(x + (4 * sz + (sz > 1 and 1 or 0)) * s, y - 1, L.timber.edge)
  for k = 0, 1 do hline(x - 6 * sz - k * 3, x + 6 * sz + k * 3, y + 3 * sz + k * 2, k == 0 and S.hi or GLINT) end
end
local function pineapple(x, y)
  local m = c:ellipse(x, y, 3, 4)
  local crownM = HP.mask()
  for _, d in ipairs({ { -3, -9 }, { 0, -10 }, { 3, -9 }, { -2, -8 }, { 2, -8 } }) do crownM:add(line({ { x, y - 4 }, { x + d[1], y + d[2] } })) end
  c:rim(union(m, crownM), L.timber.edge)
  fill(m, L.gold.base)
  m:each(function(xx, yy) if (xx + yy) % 3 == 0 then px(xx, yy, L.produce.shade) elseif (xx - yy) % 3 == 0 then px(xx, yy, L.gold.shade) end if xx < x - 1 and yy < y then px(xx, yy, L.gold.hi) end end)
  crownM:each(function(xx, yy) px(xx, yy, xx < x and L.leaf.base or L.foliage2.shade) end)
end
local function basket(x0, y0, x1, y1, r)
  r = r or L.roof
  local m = c:rrect(x0, y0, x1, y1, 2)
  rimOf(m, r) part(m, r, { nopop = true })
  m:each(function(x, y) if ((x // 2) + (y // 2)) % 2 == 0 then px(x, y, r.shade) end if x == x0 + 1 then px(x, y, r.hi) end end)
  hline(x0 + 1, x1 - 1, y0, r.hi) hline(x0 + 1, x1 - 1, y0 + 1, r.deep)
  return m
end
local function fishSprite(x, y, r, flip)
  local rows = { ".tt.....", "ttbbbbb.", ".bbBBbbe", "ttbbbbb.", ".tt....." }
  if flip then for i, row in ipairs(rows) do rows[i] = row:reverse() end end
  F.sprite(rows, x, y, { t = r.shade, b = r.base, B = r.hi, e = L.timber.edge })
end

---------------------------------------------------------------- far motu: road on, landing, hut, scrub
F.depth(1)
F.drawRoad(113, 122)
F.tree(112, 122, 30, 0)
F.tree(16, 122, 34, 2)
do -- a thatched bamboo hut with smoke
  local top, cx, wallM, roofM = F.building{ x0 = 36, x1 = 80, yb = 122, wh = 12, rh = 13, wall = L.board, roof = L.roof, noFrame = true, noAttic = true, noShadow = true }
  F.bamboo(wallM:copy():clip(rect(36, top + 4, 80, 122)), L.board, 3)
  F.window(44, 113, 48, 116, L.timber) F.window(68, 113, 72, 116, L.timber)
  hline(36, 80, 121, L.lava.base) hline(36, 80, 122, L.lava.deep)
  F.smoke(76, 98, 4, .6, 2)
end
-- far waterline scrub: naupaka clumps and little lilies
for _, r in ipairs({ { 14, 8 }, { 40, 10 }, { 110, 9 }, { 150, 12 }, { 300, 8 }, { 352, 10 } }) do
  sedge(r[1], yF(r[1]) + 1, r[2], 7, r[1], false)
end
for _, r in ipairs({ { 92, 6 }, { 128, 5 }, { 276, 6 }, { 330, 7 } }) do F.crown(r[1], yF(r[1]) - 2, r[2], 3, L.foliage2, 600 + r[1]) end
-- far landing: lava blocks with a coral-stone cap
do
  local d = poly{ { 234, 121 }, { 248, 121 }, { 250, 130 }, { 232, 130 } }
  rimOf(d, L.lava) part(d, L.lava) F.courses(d, 121, 3, 5, L.lava)
  hline(234, 248, 121, L.stone.hi) hline(234, 248, 122, L.stone.base)
  for _, x in ipairs({ 233, 248 }) do vline(x, 131, 134, L.lava.deep) end
end
F.depth(2)
do -- the ferryman's stilt fale: steep thatch, bamboo walls, turquoise shutters, bell post and tiki torch
  local top, cx, wallM, roofM = F.building{ x0 = 166, x1 = 212, yb = 119, wh = 15, rh = 20, wall = L.board, roof = L.roof, noAttic = true, noFrame = true, noShadow = true }
  F.bamboo(wallM:copy():clip(rect(166, top + 4, 212, 119)), L.board, 3)
  hline(166, 212, top + 4, L.timber.base)
  -- stilts and a lava footing at the water's edge
  local st = HP.mask()
  for x = 168, 210, 7 do st:add(rect(x, 120, x + 1, 127)) end
  local dk = rect(164, 119, 214, 120)
  rimOf(union(st, dk), L.timber) part(st, L.timber, { nopop = true, noshade = true }) part(dk, L.timber, { nopop = true, noshade = true })
  for x = 168, 210, 7 do px(x, 126, L.lava.base) px(x + 1, 126, L.lava.shade) px(x, 127, L.lava.deep) px(x + 1, 127, L.lava.deep) end
  F.door(185, 106, 192, 118, L.timber)
  for _, wx in ipairs({ 172, 201 }) do
    F.window(wx, 106, wx + 5, 110, L.timber)
    fill(rect(wx - 3, 105, wx - 2, 111), L.wall2.base) fill(rect(wx + 7, 105, wx + 8, 111), L.wall2.base)
    vline(wx - 3, 105, 111, L.wall2.hi) vline(wx + 8, 105, 111, L.wall2.shade)
  end
  -- a carved ridge pole end and a net hung under the eave
  fill(rect(cx - 1, top - 22, cx + 1, top - 19), L.timber.base) px(cx - 1, top - 22, L.timber.hi)
  F.net(rect(204, 112, 212, 118), L.rope)
  -- the far ferry bell post at the landing
  local bp = rect(222, 100, 223, 125):add(rect(218, 100, 230, 101)) rimOf(bp, L.timber) part(bp, L.board, { nopop = true, noshade = true })
  for y = 103, 124, 5 do px(222, y, L.board.deep) px(223, y, L.board.deep) end
  local fb = poly{ { 226, 102 }, { 229, 102 }, { 230, 107 }, { 225, 107 } } c:rim(fb, L.timber.edge) part(fb, L.glow, { nopop = true })
  -- tiki torch: a bamboo pole, a woven cup, a flame
  local lp = rect(257, 100, 258, 125) rimOf(lp, L.board) part(lp, L.board, { nopop = true, noshade = true })
  for y = 104, 124, 4 do px(257, y, L.board.deep) end
  local cup = poly{ { 254, 96 }, { 261, 96 }, { 259, 100 }, { 256, 100 } } rimOf(cup, L.roof) part(cup, L.roof, { nopop = true })
  F.sprite({ "..g..", ".gGg.", ".gYg.", "gYYYg" }, 255, 92, { g = L.hibiscus.base, G = L.hibiscus.hi, Y = L.glow.hi }, { rim = false })
  -- pareo washing between the hut and a pole
  local wp = rect(132, 106, 133, 124) rimOf(wp, L.timber) part(wp, L.timber, { nopop = true, noshade = true })
  F.washing(133, 106, 165, 108, { { "sheet", L.hibiscus }, { "shirt", L.wall2 }, { "sheet", L.petal } }, 3)
  for _, p in ipairs({ { 138, 114 }, { 142, 118 }, { 136, 119 }, { 158, 113 }, { 162, 117 }, { 157, 119 } }) do px(p[1], p[2], L.awnB.hi) px(p[1] + 1, p[2], L.gold.hi) end
end
-- a small gnome waving from the far landing
F.gnome(242, 128, { small = true, hat = L.awnA, coat = L.wall2, arm = "up" })
-- far right: the guide-rope post, a pandanus and two palms leaning out over the water
local FPX, FPY = 398, 101  -- far guide-rope post top
local NPX, NPY = 262, 148  -- near guide-rope post top
do
  pandanus(424, 125, 34, 131, -4)
  local _, _, _ = F.palm(470, 126, 46, L.foliage2, 133, { lean = -9, dead = false })
  F.palm(446, 125, 60, L.foliage, 132, { lean = -26 })
  -- the guide-rope post: a tall bamboo pole on a lava cairn, stays
  local post = rect(FPX, FPY, FPX + 1, 126)
  local cairn = poly{ { FPX - 5, 127 }, { FPX - 3, 121 }, { FPX + 4, 120 }, { FPX + 6, 127 } }
  rimOf(union(post, cairn), L.timber)
  part(post, L.board, { nopop = true, noshade = true }) for y = FPY + 3, 120, 5 do px(FPX, y, L.board.deep) px(FPX + 1, y, L.board.deep) end
  part(cairn, L.lava) F.courses(cairn, 120, 3, 4, L.lava)
  line({ { FPX + 1, FPY + 2 }, { FPX + 14, 124 } }):each(function(x, y) px(x, y, L.rope.shade) end) -- back stay
  fill(rect(FPX - 1, FPY + 1, FPX + 2, FPY + 2), L.rope.base)
  -- a reef egret perched on the post top
  F.sprite({ "..ww.", ".wwWk", "..wW.", ".wWW.", "wwWWW", ".wwWs", "..s..", "..y.." }, FPX - 2, FPY - 8,
    { w = L.awnB.hi, W = L.awnB.base, s = L.awnB.shade, k = L.gold.base, y = L.gold.shade })
  -- reflections of the palms in the shallows
  for x = 400, 476 do for y = yF(x) + 2, yF(x) + 10 do if river:has(x, y) and (y + x // 4) % 3 == 0 and hash(x, y, 27) < .6 then px(x, y, mix(L.foliage2.shade, waterCol(x, y), .55)) end end end
end
-- broken reflections of the far bank in the shallows
for x = 0, 479 do
  local y0 = yF(x) + 3
  local v = c:get(x, yF(x) - 6)
  if v and hash(x, 1, 31) < .45 then
    for y = y0, y0 + 4, 2 do if river:has(x, y) and hash(x, y, 32) < .5 then px(x, y, mix(v, waterCol(x, y), .6)) end end
  end
end

---------------------------------------------------------------- left water: an outrigger fisher under a crab-claw sail
F.depth(2)
do
  local x0, x1, y = 62, 100, 143
  -- the crab-claw sail on a raked mast
  local mast = line({ { 72, y - 4 }, { 68, y - 30 } }, 1)
  local sail = poly{ { 69, y - 30 }, { 58, y - 22 }, { 66, y - 8 }, { 71, y - 6 }, { 70, y - 18 } }
  rimOf(union(mast, sail), L.timber)
  part(sail, L.awnB, { nopop = true })
  sail:each(function(x, y2) if (y2 - x) % 5 == 0 then px(x, y2, L.awnB.shade) end if x < 64 then px(x, y2, L.awnB.hi) end end)
  line({ { 60, y - 22 }, { 67, y - 9 } }):each(function(x, y2) if sail:has(x, y2) then px(x, y2, L.hibiscus.base) end end)
  fill(mast, L.timber.shade)
  F.gnome(84, y - 3, { small = true, hat = L.roof, coat = L.hibiscus, arm = "out", noShadow = true })
  F.outrigger(x0, x1, y, { side = -1, stripe = L.awnA })
  for k = 0, 2 do hline(x0 + k * 3, x1 - k * 3, y + 3 + k * 2, D.shade) end
  fill(line({ { 92, y - 8 }, { 114, y - 20 } }), L.board.shade)
  vline(114, y - 19, y + 6, L.awnB.shade) px(114, y + 6, L.hibiscus.base) hline(110, 118, y + 8, D.hi)
end

---------------------------------------------------------------- the near landing: lava-stone jetty with a coral-stone cap
F.depth(3)
local LY0, LY1 = 166, 180
do
  local deck = poly{ { F.xl(LY0) - 6, LY0 }, { F.xr(LY0) + 6, LY0 }, { F.xr(LY1) + 6, LY1 }, { F.xl(LY1) - 6, LY1 } }
  local face = rect(floor(F.xl(LY0)) - 6, LY0 - 3, floor(F.xr(LY0)) + 6, LY0 - 1)
  local piles = HP.mask()
  local pl, pr = floor(F.xl(LY0)) - 7, floor(F.xr(LY0)) + 4
  piles:add(rect(pl, LY0 - 7, pl + 3, LY0 + 6)):add(rect(pr, LY0 - 7, pr + 3, LY0 + 6))
  -- the tall bamboo guide-rope pole lashed to the right bollard
  local pole = rect(pr + 1, NPY, pr + 2, LY0 - 7)
  rimOf(union(deck, face, piles, pole), L.lava)
  part(pole, L.board, { nopop = true, noshade = true }) for y = NPY + 3, LY0 - 8, 5 do px(pr + 1, y, L.board.deep) px(pr + 2, y, L.board.deep) end
  fill(rect(pr, NPY + 1, pr + 3, NPY + 2), L.rope.base) fill(rect(pr, LY0 - 9, pr + 3, LY0 - 8), L.rope.base)
  part(piles, L.lava, { nopop = true }) F.courses(piles, LY0 - 7, 4, 4, L.lava)
  -- coral-stone slab top with sand in the joints, lava face below
  part(deck, L.stone) F.courses(deck, LY0, 4, 9, L.stone)
  deck:each(function(x, y) if hash(x, y, 81) < .05 then px(x, y, L.coral.hi) elseif hash(x, y, 82) < .04 then px(x, y, L.ground.shade) end end)
  hline(floor(F.xl(LY0)) - 5, floor(F.xr(LY0)) + 5, LY0, L.stone.hi)
  part(face, L.lava, { nopop = true }) F.courses(face, LY0 - 3, 3, 6, L.lava)
  for _, x in ipairs({ pl, pr }) do hline(x - 2, x + 5, LY0 + 7, S.hi) fill(rect(x, LY0 - 8, x + 3, LY0 - 8), L.lava.hi) end
  -- weed and barnacles at the waterline on the piles
  for _, x in ipairs({ pl, pr }) do for xx = x, x + 3 do px(xx, LY0 + 4, L.seagrass.base) px(xx, LY0 + 5, hash(xx, 1, 83) < .5 and L.shell.hi or L.seagrass.shade) end end
end

---------------------------------------------------------------- the ferry raft (centre hero)
local RX0, RX1, RY0, RY1 = 270, 366, 137, 152
local FY = RY1 - 6 -- where figures stand: the front of the deck stays visible
local function ropeY(x) local t = (x - NPX) / (FPX - NPX) return floor(NPY + (FPY - NPY) * t + 5 * 4 * t * (1 - t) + .5) end
local function turtleInHat(x0, y0)
  F.sprite({
    "........R....................",
    ".......RR....................",
    ".......RRr...................",
    "......HRRr...................",
    "......HRRRr..................",
    ".....HRRRRr..................",
    ".....HRRRRRr.................",
    "....HRRRRRRr.......TTTTT.....",
    "....bbbbbbbbb....TTTTTTSSS...",
    "....GGGggggg....TTTSSSsSSSS..",
    "...GGgWkggggg..TTSSSsSSSSsSS.",
    "...Ggggggggggg.TSSSsssSSSsSS.",
    "....gggggggggggTSSsSSSsSSsSSS",
    "FF...mgggggggSSSsSSSSSsssSSs.",
    "FFF...mmdggggSSsSSSSSSsSSSss.",
    ".FFF...ddggggYYYYYYYYYYYYYYY.",
    "..FFFfffdgggg.uuuuuuuuuuuu...",
    "...FFff.......fff.....fff....",
    "....f..........ff......ff....",
  }, x0, y0, { R = L.awnA.base, r = L.awnA.shade, H = L.awnA.hi, b = L.awnA.deep,
    G = L.seagrass.hi, g = L.seagrass.base, d = L.seagrass.shade, m = L.seagrass.deep, W = L.awnB.hi, k = L.timber.edge,
    T = TURT.hi, S = TURT.base, s = TURT.deep, Y = L.gold.base, u = L.gold.shade, F = L.seagrass.base, f = L.seagrass.shade })
end
do
  -- the raft's broken reflection, bow wave, wake
  for x = RX0, RX1 do for y = RY1 + 7, RY1 + 15 do
    if river:has(x, y) and (y % 2 == 0) and hash(x // 2, y, 41) < .55 - (y - RY1) * .03 then px(x, y, mix(L.timber.shade, waterCol(x, y), .5)) end
  end end
  for k = 0, 2 do px(RX0 - 9 - k, RY0 + 8 + k * 3, GLINT) hline(RX0 - 12 - k * 3, RX0 - 9 - k * 2, RY0 + 10 + k * 3, D.hi) end
  for k = 0, 3 do hline(RX0 - 10 - k * 5, RX0 - 4 - k * 2, RY1 + 8 + k * 2, D.hi) hline(RX1 + 4 + k * 2, RX1 + 10 + k * 5, RY1 + 8 + k * 2, D.hi) end
  -- the far hull's prow peeking out at the back left
  local fp = poly{ { RX0 + 2, RY0 + 1 }, { RX0 - 6, RY0 - 4 }, { RX0 - 3, RY0 + 3 }, { RX0 + 4, RY0 + 4 } }
  rimOf(fp, L.timber) part(fp, L.timber, { nopop = true }) px(RX0 - 5, RY0 - 3, L.timber.hi)
  -- the deck: bamboo canes lashed across two hulls
  local deck = poly{ { RX0 + 4, RY0 }, { RX1 - 4, RY0 }, { RX1, RY1 }, { RX0, RY1 } }
  local hull = poly{ { RX0 - 12, RY1 - 3 }, { RX0 - 4, RY1 + 1 }, { RX1 + 2, RY1 + 1 }, { RX1 + 8, RY1 - 2 }, { RX1 + 3, RY1 + 6 }, { RX0, RY1 + 6 } }
  local posts = HP.mask()
  for _, x in ipairs({ RX0 + 1, RX1 - 2 }) do posts:add(rect(x, RY1 - 9, x + 1, RY1)) end
  for _, x in ipairs({ RX0 + 5, RX1 - 6 }) do posts:add(rect(x, RY0 - 8, x + 1, RY0)) end
  rimOf(union(deck, hull), L.timber)
  part(deck, L.board) F.bamboo(deck, L.board, 3)
  hline(RX0 + 4, RX1 - 4, RY0, L.board.hi)
  for _, y in ipairs({ RY0 + 3, RY1 - 3 }) do
    for x = RX0 + 2, RX1 - 2 do if deck:has(x, y) then px(x, y, (x % 4 == 0) and L.rope.shade or L.rope.base) end end
  end
  -- the near dugout hull: driftwood-grey, a red gunwale stripe, a turquoise band, carved prow with an eye
  part(hull, L.timber, { nopop = true })
  hline(RX0 - 6, RX1 + 4, RY1 + 1, L.awnA.base) hline(RX0 - 4, RX1 + 3, RY1 + 2, L.awnA.shade)
  hline(RX0 - 1, RX1 + 1, RY1 + 4, L.wall2.base)
  for x = RX0 + 6, RX1 - 4, 8 do px(x, RY1 + 3, L.awnB.hi) px(x + 1, RY1 + 3, L.awnB.base) end
  hline(RX0 + 1, RX1 + 2, RY1 + 6, L.timber.deep)
  fill(rect(RX0 - 10, RY1 - 3, RX0 - 8, RY1 - 1), L.timber.hi) px(RX0 - 8, RY1 - 1, L.timber.edge) px(RX0 - 7, RY1 - 2, L.awnB.hi)
  for x = RX0 - 2, RX1 + 4 do if (x // 3) % 2 == 0 then px(x, RY1 + 7, D.deep) end end
  -- far rail rope behind the cargo
  for x = RX0 + 6, RX1 - 6 do px(x, RY0 - 6 + floor(2 * sin((x - RX0) / (RX1 - RX0) * pi)), L.rope.shade) end
  -- cargo at the back: two big calabash water gourds and a woven basket of mangoes
  for _, cx in ipairs({ RX0 + 9, RX0 + 17 }) do
    local gm = c:ellipse(cx, RY0 + 2, 4, 4):add(c:ellipse(cx, RY0 - 4, 2, 2)):add(rect(cx - 1, RY0 - 8, cx, RY0 - 6))
    c:rim(gm, L.coconut.edge) part(gm, L.gold)
    gm:each(function(x, y) if x < cx - 1 and y < RY0 + 2 then px(x, y, L.gold.hi) end end)
    hline(cx - 4, cx + 4, RY0 + 1, L.rope.shade) px(cx - 1, RY0 - 8, L.coconut.base)
  end
  basket(RX1 - 29, RY0 - 1, RX1 - 18, RY0 + 6, L.roof)
  for k = 0, 3 do local mx = RX1 - 27 + k * 3 F.coconut(mx, RY0 - 2 - (k % 2), 1, false) px(mx, RY0 - 2 - (k % 2), k % 2 == 0 and L.produce.base or L.gold.base) px(mx - 1, RY0 - 3 - (k % 2), L.produce.hi) end
  -- the mast with a pulley block riding the guide rope
  local MX = RX1 - 33
  local mast = rect(MX, ropeY(MX) + 3, MX + 1, RY0 + 4)
  local block = c:rrect(MX - 2, ropeY(MX) - 1, MX + 3, ropeY(MX) + 4, 1)
  rimOf(union(mast, block), L.timber)
  part(mast, L.board, { nopop = true, noshade = true })
  for y = ropeY(MX) + 6, RY0 + 2, 5 do px(MX, y, L.board.deep) px(MX + 1, y, L.board.deep) end
  part(block, L.timber, { nopop = true }) px(MX, ropeY(MX) + 1, L.iron.hi) px(MX + 1, ropeY(MX) + 2, L.iron.base)
  -- the guide rope: 2 px laid rope across the channel, sagging a little, through the block
  local pts = {}
  for xx = NPX + 1, FPX do pts[#pts + 1] = { xx, ropeY(xx) } end
  local gr = line(pts, 1)
  F.obj()
  gr:each(function(x, y) if not gr:has(x, y + 1) then px(x, y + 1, L.timber.deep) end end)
  gr:each(function(x, y) px(x, y, ((x // 2) % 3 == 0) and L.rope.shade or L.rope.hi) end)
  fill(rect(MX - 1, ropeY(MX) - 1, MX + 2, ropeY(MX) - 1), L.timber.base) -- the block's hook over the rope
  -- the sea chest the turtle rides on
  local T0 = RX0 + 40
  local tk = rect(T0, RY0 + 1, T0 + 22, RY0 + 9)
  c:rim(tk, L.timber.edge) part(tk, L.wall2) hline(T0, T0 + 22, RY0 + 4, L.wall2.deep)
  vline(T0 + 5, RY0 + 1, RY0 + 9, L.rope.base) vline(T0 + 17, RY0 + 1, RY0 + 9, L.rope.base)
  fill(rect(T0 + 10, RY0 + 4, T0 + 12, RY0 + 6), L.gold.base) px(T0 + 10, RY0 + 4, L.gold.hi)
  F.flower(T0 + 3, RY0 + 7, "plumeria", true) F.flower(T0 + 20, RY0 + 7, "hibiscus", true)
  -- the traveller with a pareo bundle on a stick
  local gx = RX0 + 28
  fill(line({ { gx + 7, FY - 17 }, { gx - 9, FY - 23 } }), L.board.base)
  local bun = c:ellipse(gx - 11, FY - 23, 4, 4) c:rim(bun, L.timber.edge) part(bun, L.hibiscus, { nopop = true })
  bun:each(function(x, y) if (x * 2 + y) % 5 == 0 then px(x, y, L.awnB.hi) end end) px(gx - 11, FY - 27, L.hibiscus.deep)
  F.gnome(gx, FY, { hat = L.lav, coat = L.roof, arm = "up", noShadow = true })
  -- QUIRK: a sea turtle in a red gnome hat, riding on the chest
  turtleInHat(T0 - 3, RY0 - 16)
  -- the ferryman, poling from the back right corner
  local _, fx, fy = F.gnome(RX1 - 14, FY, { hat = L.roof, coat = L.accent, arm = "up", noShadow = true, hatBand = L.hibiscus.base })
  local pole = line({ { fx - 3, fy - 10 }, { fx + 14, RY1 + 16 } }, 1)
  fill(pole, L.board.shade) line({ { fx - 2, fy - 10 }, { fx + 15, RY1 + 16 } }):each(function(x, y) if y < RY1 + 4 then px(x, y, (y % 6 == 0) and L.board.deep or L.board.hi) end end)
  for k = 0, 2 do hline(fx + 10 - k * 3, fx + 18 + k * 3, RY1 + 17 + k * 2, D.hi) end
  -- near rail (rope between bamboo posts) in front of everyone
  part(posts, L.board, { nopop = true, noshade = true })
  for x = RX0 + 2, RX1 - 2 do px(x, RY1 - 7 + floor(2 * sin((x - RX0) / (RX1 - RX0) * pi)), (x % 3 == 0) and L.rope.shade or L.rope.base) end
  -- a garland of plumeria hung on the front post
  for k = 0, 3 do F.flower(RX0 + 2 + k * 2, RY1 - 9 + k * 2, k % 2 == 0 and "plumeria" or "white", true) end
end

---------------------------------------------------------------- near bank: gnome hauling the tow line on the landing
F.depth(3)
do
  local _, hx, hy = F.gnome(244, 200, { hat = L.roof2, coat = L.wall2, arm = "up" })
  local x0, y0 = RX0 + 2, RY1 - 8
  local pts = {}
  for xx = hx, x0 do local t = (xx - hx) / (x0 - hx) pts[#pts + 1] = { xx, floor(hy + (y0 - hy) * t + 9 * 4 * t * (1 - t) + .5) } end
  local rope = line(pts, 2)
  c:rim(rope, L.timber.edge)
  rope:each(function(x, y) local top = not rope:has(x, y - 1) px(x, y, top and L.rope.hi or L.rope.base) if (x + y) % 3 == 0 then px(x, y, L.rope.shade) end end)
  for _, p in ipairs(pts) do if p[2] > yN(p[1]) - 3 and p[1] % 5 == 0 then px(p[1], p[2] + 2, GLINT) end end
  local coil = c:ellipse(232, 200, 6, 2) c:rim(coil, L.timber.edge) part(coil, L.rope, { nopop = true }) c:ellipse(232, 200, 3, 1):edge():each(function(x, y) px(x, y, L.rope.deep) end)
  local tail = line({ { hx - 1, hy + 1 }, { 236, 198 } }, 2) c:rim(tail, L.timber.edge) fill(tail, L.rope.base) tail:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.rope.shade) end end)
end

DY = 10
---------------------------------------------------------------- near bank left: bell frame, ferry sign, booth, bench, beached canoe
do -- the ferry bell on a bamboo frame under a thatch cap, a conch horn hung beside it
  local fr = rect(186, 150, 187, 196):add(rect(206, 150, 207, 196)):add(rect(183, 148, 210, 150))
  F.shadow(186, 208, 197, 6, 3)
  rimOf(fr, L.timber) part(fr, L.board, { nopop = true, noshade = true }) hline(183, 210, 148, L.board.hi)
  for y = 154, 194, 6 do hline(186, 187, y, L.board.deep) hline(206, 207, y, L.board.deep) end
  hline(185, 188, 151, L.rope.base) hline(205, 208, 151, L.rope.base)
  local roofb = poly{ { 179, 149 }, { 196, 138 }, { 214, 149 } } rimOf(roofb, L.roof) part(roofb, L.roof, { nopop = true }) F.thatch(roofb, L.roof, 138, 196)
  line({ { 180, 148 }, { 196, 139 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  vline(196, 151, 153, L.rope.shade)
  local bell = poly{ { 193, 154 }, { 199, 154 }, { 201, 163 }, { 203, 165 }, { 189, 165 }, { 191, 163 } }:add(c:ellipse(196, 155, 3, 2))
  c:rim(bell, L.timber.edge) part(bell, L.glow) vline(193, 156, 163, L.glow.hi) hline(190, 202, 164, L.glow.shade)
  fill(rect(195, 166, 197, 167), L.iron.base)
  fill(line({ { 197, 167 }, { 199, 180 } }), L.rope.shade)
  -- the conch horn on a cord from the left post
  vline(189, 151, 168, L.rope.shade)
  local ch = poly{ { 186, 169 }, { 193, 170 }, { 191, 176 }, { 187, 175 } }
  c:rim(ch, L.shell.edge) part(ch, L.shell, { nopop = true }) px(188, 172, L.petal.base) px(189, 173, L.petal.shade) px(190, 171, L.shell.hi)
end
do -- the ferry sign: a painted raft, a turtle and waves
  local post = rect(170, 168, 171, 200)
  local bd = rect(156, 152, 185, 168)
  rimOf(union(post, bd), L.timber) part(post, L.timber, { nopop = true }) part(bd, L.board, { nopop = true })
  c:edgeIn(bd, L.board.deep)
  for x = 159, 182 do px(x, 164 + floor(sin(x / 2) + .5), L.accent.base) px(x, 165 + floor(sin(x / 2) + .5), L.accent.shade) end
  fill(rect(162, 160, 176, 162), L.timber.base) hline(162, 176, 160, L.board.hi) hline(160, 178, 163, L.awnA.base)
  vline(166, 155, 159, L.timber.edge) fill(rect(169, 155, 172, 159), L.awnA.base)
  hline(158, 182, 154, L.rope.shade)
  F.sprite({ ".gg.", "gssg", ".gg." }, 178, 158, { g = L.seagrass.shade, s = L.coconut.base }, { rim = false })
  F.flower(158, 156, "hibiscus", true)
end
F.depth(3)
do -- the bamboo ticket booth with a gnome in the hatch
  local wall = rect(38, 168, 92, 200)
  local roof = poly{ { 30, 172 }, { 65, 142 }, { 100, 172 } }:add(rect(30, 168, 100, 172))
  local foot = rect(36, 197, 94, 201)
  F.shadow(40, 92, 200, 10, 4)
  rimOf(union(wall, roof, foot), L.timber)
  part(wall, L.board) F.bamboo(wall, L.board, 3)
  part(roof, L.roof, { sep = true }) F.thatch(roof, L.roof, 142, 65)
  line({ { 30, 172 }, { 65, 142 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  hline(30, 100, 172, L.roof.deep)
  for x = 31, 99, 3 do if hash(x, 1, 85) < .6 then px(x, 173, L.roof.shade) end end -- ragged thatch fringe
  part(foot, L.lava, { nopop = true }) F.courses(foot, 197, 3, 6, L.lava)
  -- hatch with a striped turquoise awning
  local hatch = rect(50, 178, 80, 192)
  fill(hatch, L.soil.deep) c:edgeIn(hatch, L.board.hi)
  F.gnome(65, 198, { hat = L.awnA, coat = L.hibiscus, arm = "out", noShadow = true })
  local sill = rect(48, 192, 82, 194) rimOf(sill, L.timber) part(sill, L.timber, { nopop = true })
  fill(rect(76, 189, 78, 191), L.awnB.hi) px(77, 189, L.hibiscus.base) -- a ticket
  local aw = poly{ { 46, 172 }, { 84, 172 }, { 88, 178 }, { 42, 178 } }
  rimOf(aw, L.wall2) fill(aw, L.wall2.base)
  aw:each(function(x, y) if ((x - 42) // 5) % 2 == 1 then px(x, y, L.awnB.base) end if y == 178 then px(x, y, ((x // 3) % 2 == 0) and L.wall2.deep or L.wall2.shade) end end)
  hline(46, 84, 172, L.wall2.hi)
  -- a hibiscus pot on the sill corner and a woven fan of tickets price board
  F.hibiscus(54, 191, 4, 6, 86)
  F.window(86, 160, 88, 163, L.timber)
  local pb = rect(40, 180, 47, 190) rimOf(pb, L.timber) part(pb, L.timber, { nopop = true })
  for y = 182, 188, 2 do hline(42, 45, y, L.awnB.hi) end
end
do -- driftwood log bench with two waiting travellers and their luggage
  F.gnome(112, 214, { hat = L.roof, coat = L.lav, arm = "hold", noShadow = true })
  F.gnome(134, 215, { hat = L.accent, coat = L.awnA, flip = true, noShadow = true })
  local seat = rect(100, 207, 146, 209)
  local legs = rect(103, 210, 105, 218):add(rect(141, 210, 143, 218))
  F.shadow(102, 146, 219, 8, 3)
  rimOf(union(seat, legs), L.timber) part(legs, L.timber, { nopop = true }) part(seat, L.timber, { nopop = true }) hline(100, 146, 207, L.timber.hi)
  for x = 102, 144, 5 do px(x, 208, L.timber.shade) px(x + 1, 208, L.timber.shade) end
  F.logEnd(100, 208, 2) F.logEnd(146, 208, 2)
  -- luggage: a woven pandanus chest, a pareo bag, a bunch of green coconuts
  basket(150, 204, 168, 218, L.roof)
  F.shadow(150, 168, 219, 5, 2)
  hline(150, 168, 209, L.rope.shade) vline(159, 204, 218, L.rope.shade) fill(rect(158, 208, 160, 210), L.hibiscus.base)
  local bag = c:rrect(152, 222, 166, 232, 3) rimOf(bag, L.timber) part(bag, L.wall2)
  bag:each(function(x, y) if (x + y) % 4 == 0 then px(x, y, L.wall2.hi) end end)
  F.flower(156, 227, "hibiscus", true) F.flower(162, 229, "plumeria", true)
  fill(c:ellipse(159, 221, 3, 2):cut(c:ellipse(159, 221, 1, 1)):clip(rect(150, 218, 168, 221)), L.rope.base)
  for k, p in ipairs({ { 172, 216 }, { 177, 217 }, { 174, 212 } }) do F.coconut(p[1], p[2], 3, k ~= 2) end
end
do -- an outrigger canoe pulled up on the sand, a paddle across it
  local y = 230
  local x0, x1 = 24, 80
  F.shadow(x0, x1, y + 2, 6, 3)
  local hull = poly{ { x0 - 6, y - 11 }, { x0 + 2, y - 7 }, { x1 - 2, y - 7 }, { x1 + 6, y - 12 }, { x1 + 2, y - 3 }, { x1 - 6, y }, { x0 + 5, y }, { x0 - 2, y - 4 } }
  local inside = c:ellipse((x0 + x1) // 2, y - 7, (x1 - x0) // 2 - 3, 1)
  local booms = HP.mask()
  for _, bx in ipairs({ x0 + 14, x1 - 16 }) do booms:add(line({ { bx, y - 6 }, { bx + 3, y + 7 } }, 2)) end
  local float = c:rrect(x0 + 6, y + 5, x1 - 8, y + 8, 2)
  rimOf(union(hull, booms, float), L.timber)
  part(hull, L.timber, { nopop = true })
  fill(inside, L.timber.deep) c:edgeIn(inside, L.timber.shade)
  hline(x0 + 1, x1 - 1, y - 6, L.awnA.base) hline(x0 + 2, x1 - 2, y - 5, L.awnA.shade)
  hline(x0 + 3, x1 - 4, y - 3, L.wall2.base) hline(x0 + 5, x1 - 6, y - 1, L.timber.deep)
  for x = x0 + 6, x1 - 6, 8 do px(x, y - 4, L.awnB.hi) px(x + 1, y - 4, L.awnB.base) end
  px(x0 - 4, y - 10, L.timber.hi) px(x1 + 4, y - 11, L.timber.hi)
  part(booms, L.board, { nopop = true, noshade = true })
  part(float, L.board, { nopop = true }) hline(x0 + 7, x1 - 9, y + 5, L.board.hi)
  fill(line({ { 30, y - 9 }, { 72, y - 5 } }), L.board.base) fill(c:ellipse(74, y - 5, 3, 1), L.board.shade)
end
DY = 0
-- near waterline: spider-lily sedge and mangroves on both sides of the landing
sedge(214, yN(214) + 3, 14, 20, 3, true)
mangrove(120, yN(120) + 3, 9, 26, 5)
sedge(392, yN(392) + 3, 14, 22, 7, true)
mangrove(452, yN(452) + 3, 10, 28, 9)
sedge(20, yN(20) + 3, 8, 16, 11, true)

---------------------------------------------------------------- the channel: a turtle and her hatchlings, a ray, fish, flowers
F.depth(3)
seaTurtle(150, 140, 2, true)
seaTurtle(166, 145, 1, true) seaTurtle(176, 142, 1, true) seaTurtle(186, 147, 1, true)
do -- a spotted eagle ray gliding under the surface
  local rx, ry = 130, 157
  local ray = poly{ { rx - 9, ry }, { rx, ry - 3 }, { rx + 9, ry }, { rx, ry + 3 } }
  ray:each(function(x, y) if river:has(x, y) then px(x, y, mix(L.lava.shade, waterCol(x, y), .45)) end end)
  ray:each(function(x, y) if river:has(x, y) and (x * 3 + y) % 7 == 0 then px(x, y, mix(L.shell.hi, waterCol(x, y), .5)) end end)
  for k = 1, 8 do px(rx - k, ry + 3 + k // 3, mix(L.lava.shade, waterCol(rx - k, ry + 3), .55)) end
end
for _, f in ipairs({ { 352, 172, L.gold }, { 356, 174, L.gold }, { 210, 150, L.accent }, { 400, 168, L.hibiscus }, { 60, 170, L.gold }, { 430, 172, L.accent }, { 100, 172, L.hibiscus } }) do
  if river:has(f[1], f[2]) then px(f[1], f[2], f[3].base) px(f[1] + 1, f[2], f[3].hi) px(f[1] - 1, f[2], f[3].shade) px(f[1] - 2, f[2] - 1, f[3].shade) px(f[1] - 2, f[2] + 1, f[3].shade) end
end
DY = 8
F.flower(360, 168, "hibiscus", true) F.flower(376, 172, "orange", true) F.flower(344, 176, "plumeria", true) F.flower(412, 160, "plumeria", true)
hline(357, 363, 170, S.hi) hline(341, 347, 178, S.hi)
F.coconut(388, 164, 2) hline(385, 391, 167, S.hi)
do -- a small outrigger canoe moored to a stake
  local y = 179
  F.outrigger(424, 468, y, { side = -1, stripe = L.wall2, hull = L.timber })
  for k = 0, 2 do hline(424 + k * 2, 466 - k * 2, y + 3 + k * 2, S.deep) end
  local st = rect(410, y - 12, 412, y + 6) rimOf(st, L.timber) part(st, L.timber, { nopop = true, noshade = true })
  fill(line({ { 412, y - 8 }, { 422, y - 3 } }), L.rope.shade)
  fill(line({ { 434, y - 5 }, { 458, y - 9 } }), L.board.base) fill(c:ellipse(459, y - 9, 2, 1), L.board.shade)
end

---------------------------------------------------------------- near bank right: cargo waiting to cross, a gnome with a fish
F.depth(3)
do
  F.crate(300, 222, 18, 12, L.produce)
  basket(318, 211, 334, 222, L.roof)
  for k = 0, 4 do F.coconut(320 + k * 3, 209 - (k % 2), 2, true) end
  -- a big bunch of green bananas lying on top of the crate
  local bb = c:rrect(304, 202, 318, 209, 3)
  c:rim(bb, L.leaf.edge) fill(bb, L.leaf.base)
  bb:each(function(x, y) if (x - 304) % 3 == 0 then px(x, y, L.leaf.shade) elseif y < 205 then px(x, y, L.leaf.hi) end end)
  fill(rect(318, 204, 321, 205), L.foliage2.shade) px(303, 206, L.lav.deep) px(302, 206, L.lav.shade)
  F.sack(342, 224, L.needle, 7) F.sack(354, 226, L.needle, 6)
  F.sprite({ "CCC", "C.C", "CCC" }, 340, 214, { C = L.wall2.base }, { rim = false })
  -- green coconuts heaped where the barrel stood
  for k, p in ipairs({ { 284, 222 }, { 290, 222 }, { 296, 223 }, { 287, 217 }, { 293, 217 }, { 290, 212 } }) do F.coconut(p[1], p[2], 3, k % 3 ~= 0) end
  local _, hx, hy = F.gnome(372, 236, { hat = L.lav, coat = L.leaf, arm = "out", flip = true })
  fishSprite(hx - 8, hy - 3, L.wall2, true)
  -- a tiki torch on a bamboo pole at the landing's right
  local lp = rect(280, 160, 281, 200) rimOf(lp, L.board) part(lp, L.board, { nopop = true, noshade = true })
  for y = 164, 198, 5 do px(280, y, L.board.deep) px(281, y, L.board.deep) end
  local cup = poly{ { 276, 153 }, { 285, 153 }, { 283, 160 }, { 278, 160 } } rimOf(cup, L.roof) part(cup, L.roof, { nopop = true })
  cup:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.roof.shade) end end)
  F.sprite({ "...g...", "..gGg..", ".gGYGg.", ".gYYYg.", "gGYYYGg" }, 277, 147, { g = L.hibiscus.base, G = L.hibiscus.hi, Y = L.glow.hi }, { rim = false })
  px(279, 145, L.glow.base) px(282, 144, L.hibiscus.hi)
end
-- foreground: a barrow of pineapples and coconuts waiting for the ferry, lava rocks
do
  local y = 250
  local tray = poly{ { 96, y - 12 }, { 132, y - 12 }, { 128, y - 2 }, { 100, y - 2 } }
  local legs = rect(102, y - 2, 103, y + 4):add(line({ { 132, y - 8 }, { 146, y - 2 } }, 2))
  local wh = c:ellipse(92, y, 5, 5)
  F.shadow(92, 132, y + 5, 8, 3)
  rimOf(union(tray, legs, wh), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true })
  part(tray, L.board) F.bamboo(tray, L.board, 3, { horizontal = true })
  part(wh, L.timber, { nopop = true }) px(92, y, L.iron.hi) hline(88, 96, y, L.timber.deep) vline(92, y - 4, y + 4, L.timber.deep)
  for k, p in ipairs({ { 106, y - 15 }, { 128, y - 14 } }) do F.coconut(p[1], p[2], 3, k == 1) end
  pineapple(112, y - 17) pineapple(121, y - 16) pineapple(116, y - 23)
end
F.lavaRock(160, 262, 9, 7, 140) F.lavaRock(172, 264, 5, 4, 141)
F.lavaRock(70, 262, 6, 5, 142)

---------------------------------------------------------------- beach lip, a fisher gnome, a booby after the fish
DY = 0
F.depth(3)
-- beach grass and sea-grape at the near beach lip, shells and lava pebbles in the wet sand
for x = 0, 479 do
  local yn = yN(x)
  if hash(x, 1, 91) < .4 and not F.roadM:has(x, yn + 1) and not (x > 190 and x < 290) then
    local h = 2 + floor(hash(x, 2, 91) * 4)
    vline(x, yn + 5 - h, yn + 5, L.mossGround.shade) px(x, yn + 5 - h, L.mossGround.hi) if h > 3 then px(x, yn + 4 - h, L.leaf.hi) end
  end
  if hash(x, 3, 91) < .04 then F.shell(x, yn + 6, hash(x, 4, 91) < .5 and "scallop" or "cowrie") end
end
-- a fisher gnome on an upturned basket at the right bank, rod out over the sedge, a catch in his creel
do
  F.shadowM(c:ellipse(418, 222, 10, 1))
  local bk = poly{ { 410, 210 }, { 422, 210 }, { 420, 220 }, { 412, 220 } }
  rimOf(bk, L.roof) part(bk, L.roof) bk:each(function(x, y) if ((x // 2) + (y // 2)) % 2 == 0 then px(x, y, L.roof.shade) end end)
  local _, hx, hy = F.gnome(416, 210, { hat = L.awnA, coat = L.wall2, arm = "up", flip = true, noShadow = true, hatBand = L.gold.base })
  local rod = line({ { hx, hy + 2 }, { 380, 176 } })
  fill(rod, L.board.shade) px(380, 176, L.board.deep)
  for y = 177, 190 do px(380 - floor((y - 177) * .2), y, L.awnB.shade) end
  px(377, 191, L.hibiscus.base) px(377, 190, GLINT) hline(372, 382, 192, S.hi)
  basket(428, 212, 442, 222, L.roof)
  F.sprite({ "s..s", "sSSs", ".SS.", ".ss." }, 433, 206, { s = L.accent.shade, S = L.accent.base })
  F.crab(450, 224, L.awnA) F.shell(446, 228, "conch", true)
end
-- a blue-footed booby stretching its neck at the gnome's fish
F.sprite({
  "..........WW..",
  ".........WWkoo",
  "..........WW..",
  "..........W...",
  ".........WW...",
  "........WW....",
  "..wwwwwWWW....",
  ".wwwwwwwWW....",
  "wwwsswwWWV....",
  ".sssswWWV.....",
  "...ss.WV......",
  "....f..f......",
  "...ff.ff......",
}, 336, 234, { W = L.awnB.hi, V = L.awnB.shade, w = L.timber.base, s = L.timber.shade, k = L.timber.edge, o = "#7e9ab8", f = "#4aa8e0" })
F.crab(204, 252, L.hibiscus, true)
F.shell(186, 246, "conch", true)

DY = 0
F.depth(0)
F.birds({ { 150, 64, 2 }, { 162, 58, 1 }, { 320, 52, 3 }, { 334, 58, 2 } })
F.finish()
