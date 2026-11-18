-- spring.lua : "Spring" stop look, TUNDRA (tundra_frost), 480x270 gate view.
-- Same composition as the Maplewold spring (art-2701-batch4/stops/opus3/spring.lua) and the forest spring, re-cast as
-- an arctic HOT SPRING: right hero: a dark granite outcrop under snow-loaded spruces, snow-capped boulders with
-- icicles, a travertine face with a carved stone gnome head; hot water arcs from its mouth into a steaming stone basin
-- (milky turquoise, green geothermal moss round the rim, ochre mineral crust). Big steam plumes rise over the rocks.
-- A second trickle from a crack into a gnome's pail. The basin overflows down rimstone steps into a steaming brook that
-- winds down-left between ice shelves, under a snowy stone bridge, into an open, steaming pond with whooper swans.
-- Left: a sod-roofed stone well-head with a gnome winding the bucket, bare birches with frozen-stiff washing, a falu-red
-- cottage. A gnome carries two steaming pails on a yoke, another washes laundry in the warm pond, another hauls a barrel
-- sledge. Road's end: a sod hamlet with a stone chapel. A raven on the bridge, an ermine by the rocks.
-- Quirk: an arctic fox in a red gnome hat soaks up to its chin in the basin, eyes shut, under the hot shower, towel on the rim.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-tundra-stops/"
local F = dofile(DIR .. "_frame.lua")
  .build{ name = "spring", out = DIR, farTrees = { 22, 60, 104, 150, 330, 372, 452 }, treeLineGap = { 188, 290 },
    clouds = { { 130, 42, 40 }, { 280, 30, 46 }, { 400, 58, 34 }, { 30, 70, 24 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs, sqrt = math.floor, math.sin, math.cos, math.pi, math.abs, math.sqrt
local S = L.snow
local HW = F.rp("#e2f6f2 #a6dedc #72bec8 #4c94ac #2c6282") -- milky turquoise hot water
local GL = "#f2faf8"
local rock = L.rock -- dark violet granite: snow caps read on it
local trav = F.rp("#f0e6d2 #d6c6aa #b29e84 #887660 #574a3e") -- travertine / sinter stone
local hmoss = F.rp("#d2e8a2 #9ec86c #70a04e #4c7840 #2e4a30") -- geothermal moss, green in the snow
local crust = { "#e6c27a", "#c8944e", "#a66a3e" } -- ochre mineral crust

-- steam plume: a soft lumpy field of puffs rising from (x,y) h px, drifting `drift` px per px; solid tones, dithered
-- fringe, lit upper left, lilac lower right. dens 0..1.
local STM = { "#f4f4f8", "#e6e8f2", "#d4d8ea", "#c2c6de" }
local function plume(x, y, h, drift, w0, seed, dens)
  dens = dens or 1
  local puffs, n = {}, floor(h / 6) + 2
  for i = 0, n do
    local t = i / n
    puffs[#puffs + 1] = { x + drift * h * t * t + sin(t * 5 + seed) * 3 * t, y - h * t, w0 * (1 + t * 1.5), (1 - t * .6) * dens }
  end
  local function fld(xx, yy)
    local s = 0
    for _, p in ipairs(puffs) do
      local d2 = ((xx - p[1]) ^ 2 + ((yy - p[2]) * 1.5) ^ 2) / (p[3] * p[3])
      if d2 < 1 then local v = (1 - d2) * p[4] if v > s then s = v end end
    end
    return s + (F.vnoise(xx / 4, yy / 3, seed) - .5) * .42
  end
  local x0, x1 = floor(x - w0 * 3 - 4), floor(x + drift * h + w0 * 3 + 6)
  F.obj()
  for yy = floor(y - h - w0 * 2), floor(y + w0) do for xx = x0, x1 do
    local v = fld(xx, yy)
    if v > .14 then
      local g = fld(xx + 2, yy + 2) - fld(xx - 2, yy - 2)
      local col
      local solid = v > .5 or (v > .34 and (xx + yy) % 2 == 0) or (v > .22 and xx % 2 == 0 and yy % 2 == 0)
      if solid then
        if g > .12 then col = STM[1]
        elseif g < -.12 then col = (v < .4) and STM[4] or STM[3]
        else col = (v > .6 and hash(xx, yy, seed) < .3) and STM[1] or STM[2] end
      end
      if col then px(xx, yy, col) end
    end
  end end
end

---------------------------------------------------------------- back row: a sod hamlet with a stone chapel at the road's end
F.depth(1)
do
  local top, _, wall = F.building{ x0 = 196, x1 = 228, yb = 126, wh = 13, rh = 11, wall = L.stone, roof = L.roof, noFrame = true, noAttic = true, chimney = true, snow = 3, icicles = 2 }
  F.rubble(wall, L.stone, top, 3, 11)
  F.window(204, 117, 208, 120, L.timber)
end
F.smoke(219, 97, 4, .5, 2)
do -- a little stone chapel with a slate spire right of the road
  local wall = rect(254, 112, 278, 126)
  local roof = poly{ { 251, 113 }, { 266, 102 }, { 281, 113 } }
  local tower = rect(256, 96, 263, 112)
  local spire = poly{ { 255, 97 }, { 259, 80 }, { 264, 97 } }
  rimOf(union(wall, roof, tower, spire), L.timber)
  part(wall, L.plaster) F.rubble(tower, L.stone, 96, 3, 12)
  part(roof, L.roof2, { nopop = true }) F.courses(roof, 102, 2, 4, L.roof2)
  part(spire, L.roof2, { nopop = true }) F.courses(spire, 80, 2, 3, L.roof2)
  F.snowCap(roof, 3, 13, { cx = 264, lip = true }) F.snowCap(spire, 2, 14, { cx = 259 })
  F.icicles(251, 281, 114, 2, 15, .5)
  fill(c:rrect(258, 99, 261, 104, 1), L.glow.shade) px(259, 79, L.gold.base) px(259, 78, L.gold.hi)
  F.window(270, 116, 273, 120, L.timber, true)
end
F.tree(300, 128, 28, 3)
F.tree(186, 128, 30, 2)
F.fenceP(120, 132, 190, 127, 6)
F.depth(2)
F.tree(184, 150, 36, 4)
F.tree(8, 156, 34, 1)
do -- mid-left: drifts, willow scrub, a cairn, sedge between the cottage and the well
  F.drift(34, 166, 18, 4, 31) F.drift(172, 166, 14, 3, 32)
  F.willow(20, 150, 6, 6, 33) F.willow(50, 156, 5, 5, 34) F.willow(176, 156, 5, 6, 35)
  F.cairn(34, 160, 10, 36)
  for i = 1, 12 do
    local x, y = 18 + floor(hash(i, 1, 36) * 200), 142 + floor(hash(i, 2, 36) * 20)
    if not F.roadM:has(x, y) and (x < 104 or x > 168) then F.fern(x, y, 2 + (y - 140) // 9) end
  end
end

---------------------------------------------------------------- mid left: falu-red cottage, bare birches, frozen washing
F.depth(2)
do
  local top, _, wall = F.building{ x0 = 24, x1 = 70, yb = 136, wh = 20, rh = 16, wall = L.wall2, roof = L.roof, chimney = true, noAttic = true, noFrame = true, snow = 3 }
  F.planks(wall, L.wall2, 4, true, 37)
  part(union(rect(24, top, 25, 135), rect(69, top, 70, 135)), L.plaster, { nopop = true, noshade = true })
  F.window(30, 122, 35, 127, L.plaster) F.door(50, 124, 57, 135, L.timber)
  hline(28, 37, 131, S.hi)
end
F.smoke(61, 88, 6, .5, 2)
F.birch(92, 150, 56, 31)
-- washing strung from the cottage gable to the birch, frozen stiff: rime on the tops, icicles at the hems
F.washing(70, 118, 91, 120, { { "shirt", L.awnA }, { "sock", L.accent }, { "trousers", L.lav } }, 3)
do
  local function ly(xx) local t = (xx - 70) / 21 return floor(118 + 2 * t + 12 * t * (1 - t) + .5) end
  for i, it in ipairs({ { 73, 9 }, { 80, 7 }, { 87, 10 } }) do
    local yy = ly(it[1]) + 1
    hline(it[1] - 2, it[1] + 2, yy, S.hi)
    F.icicles(it[1] - 3, it[1] + 3, yy + it[2] + 1, 3, 38 + i, .5)
  end
end
F.birch(160, 140, 44, 34)
F.tree(124, 146, 40, 6)

---------------------------------------------------------------- right hero: the granite outcrop under snowy spruces
F.depth(2)
F.tree(446, 128, 70, 8)
F.tree(404, 104, 44, 5)
F.tree(352, 114, 38, 2)
F.tree(326, 136, 30, 1)
F.depth(3)
local boulders = {
  { 312, 158, 22, 22, 41 }, { 340, 128, 26, 24, 42 }, { 384, 114, 30, 22, 43 }, { 430, 120, 26, 24, 44 },
  { 452, 160, 20, 30, 45 }, { 300, 196, 16, 16, 46 }, { 436, 196, 26, 18, 47 },
  { 330, 190, 22, 18, 48 }, { 352, 166, 14, 16, 50 }, { 418, 150, 12, 16, 51 },
}
local SPX, SPY = 388, 168 -- the warm heart (spout and basin): snow melts near it
local function warmth(x, y) return 1 - math.min(1, sqrt((x - SPX) ^ 2 + ((y - SPY) * 1.2) ^ 2) / 50) end
local rockM = HP.mask()
for _, b in ipairs(boulders) do
  local pts = {}
  for i = 0, 13 do
    local a = i / 14 * 2 * pi
    local k = .82 + .2 * hash(i, b[5], 3)
    pts[#pts + 1] = { b[1] + cos(a) * b[3] * k, b[2] + sin(a) * b[4] * k }
  end
  b.m = poly(pts)
  rockM:add(b.m)
end
local face = rect(352, 132, 420, 196)
local mass = poly{ { 294, 212 }, { 298, 172 }, { 312, 132 }, { 346, 106 }, { 388, 96 }, { 432, 98 }, { 466, 110 }, { 470, 212 } }
rockM:add(face):add(mass)
F.shadowM(c:ellipse(380, 214, 92, 5))
rimOf(rockM, rock)
mass:each(function(x, y)
  local v = hash(x, y, 77)
  local h = (hash(x // 5, y // 4, 78) < .5) and rock.shade or rock.deep
  if v < .06 then h = rock.base elseif v > .96 then h = rock.edge end
  if hash(x // 3, y // 3, 79) < .1 then h = S.deep end -- snow packed in the crevices
  px(x, y, h)
end)
for _, b in ipairs(boulders) do
  local off = hash(b[5], 1, 2) * 2 * pi
  b.m:each(function(x, y)
    local nx, ny = (x - b[1]) / b[3], (y - b[2]) / b[4]
    local r = sqrt(nx * nx + ny * ny)
    local a = math.atan(ny, nx)
    local sec = floor(((a + off) % (2 * pi)) / (2 * pi) * 7)
    local ca = sec / 7 * 2 * pi + pi / 7 - off
    local lit
    if r < .38 then lit = .25 - (nx * .6 + ny * .8) * .4
    else lit = -(cos(ca) * .6 + sin(ca) * .8) * math.min(1, r * 1.2) end
    lit = lit + (hash(x // 2, y // 2, b[5]) - .5) * .25
    local h
    if lit > .55 then h = rock.hi elseif lit > .1 then h = rock.base elseif lit > -.4 then h = rock.shade else h = rock.deep end
    if (x * 3 + y * 7 + b[5]) % 41 == 0 then h = rock.edge end
    if hash(x, y, b[5]) > .97 then h = rock.deep elseif hash(x, y, b[5]) < .03 then h = rock.hi end
    if lit > -.4 and hash(x, y, b[5] + 9) < .02 then h = "#d6d4e0" end -- feldspar flecks
    -- wet dark sheen on the warm rocks
    if warmth(x, y) > .35 and lit < .1 and hash(x // 2, y, 7) < .3 then h = rock.edge end
    px(x, y, h)
  end)
  c:edgeIn(b.m, rock.edge)
  for k = 1, 2 do
    local x, y = floor(b[1] + (hash(k, b[5], 81) - .5) * b[3]), floor(b[2] - b[4] * .1 + (hash(k, b[5], 82) - .2) * b[4] * .6)
    for t = 0, floor(b[4] * .5) do
      if b.m:has(x, y) and b.m:has(x, y + 1) then px(x, y, rock.edge) if b.m:has(x - 1, y) then px(x - 1, y, rock.hi) end end
      y = y + 1 x = x + ((hash(t, k, b[5]) < .5) and 1 or -1) * ((t % 2) == 0 and 1 or 0)
    end
  end
  -- lichen rosettes: ochre map lichen and rust
  for k = 1, 3 do
    local x, y = floor(b[1] + (hash(k, b[5], 83) - .5) * b[3] * 1.2), floor(b[2] + (hash(k, b[5], 84) - .3) * b[4] * .8)
    local r = k == 3 and L.rust or L.lichen
    if b.m:has(x, y) then px(x, y, r.hi) px(x + 1, y, r.base) px(x, y + 1, r.base) px(x - 1, y + 1, r.shade) end
  end
  -- the top: a heavy snow cushion with a lilac underside and icicles; near the spring it melts to green moss
  b.m:each(function(x, y)
    local nx, ny = (x - b[1]) / b[3], (y - b[2]) / b[4]
    local cap = -.32 + .16 * sin(x * .31 + b[5]) + .2 * hash(x // 3, 3, b[5]) + .06 * hash(x, 4, b[5])
    if ny < cap and nx < .8 then
      local w = warmth(x, y)
      local edge = not b.m:has(x, y - 1)
      local lt = -(nx * .6 + ny * .8)
      local bottom = not (ny + .06 < cap)
      if w > .42 then
        local h = lt > .7 and hmoss.hi or (lt > .3 and hmoss.base or hmoss.shade)
        if hash(x, y, 9) < .12 then h = hmoss.hi elseif hash(x, y, 9) > .9 then h = hmoss.deep end
        if edge then h = hmoss.edge end
        px(x, y, h)
        if bottom then px(x, y + 1, hmoss.deep) end
      elseif w > .3 then
        if edge or hash(x, y, 10) < .25 then px(x, y, S.base) end -- thin rime
      else
        local h = lt > .7 and S.hi or (lt > .2 and S.base or S.shade)
        if hash(x, y, 9) < .1 then h = S.hi end
        if edge then h = (x < b[1]) and S.hi or S.base end
        px(x, y, h)
        if bottom then
          px(x, y + 1, S.deep)
          if hash(x, b[5], 11) < .16 and b.m:has(x, y + 3) then
            local len = 2 + floor(hash(x, b[5], 12) * 5)
            for k = 2, len do if b.m:has(x, y + k) then px(x, y + k, k == len and L.ice.deep or (k == 2 and L.ice.hi or L.ice.base)) end end
          end
        end
      end
    end
  end)
end
-- the travertine face: ashlar courses, an arched niche, a snow ledge with icicles on top
part(face, trav, { inner = false })
F.courses(face, 132, 7, 14, trav)
c:edgeIn(face, trav.edge)
local niche = c:rrect(362, 136, 410, 186, 20):clip(rect(362, 136, 410, 186))
fill(niche, rock.deep) c:edgeIn(niche, trav.edge)
niche:each(function(x, y)
  if (x - 386) + (y - 160) < -14 then px(x, y, rock.shade) end
  if hash(x, y, 5) < .04 then px(x, y, rock.edge) end
  if y > 176 and hash(x // 2, y, 6) < .35 then px(x, y, hmoss.deep) end
end)
c:rrect(360, 134, 412, 188, 22):clip(rect(360, 134, 412, 186)):cut(c:rrect(362, 136, 410, 188, 20)):each(function(x, y) px(x, y, ((x + y) % 5 == 0) and trav.deep or trav.hi) end)
-- mineral streaks bleeding down the face from the course joints
for x = 353, 419 do
  if hash(x, 6, 20) < .14 and not niche:has(x, 150) then
    local y0, n = 134 + floor(hash(x, 7, 20) * 30), 4 + floor(hash(x, 8, 20) * 14)
    for k = 0, n do if not niche:has(x, y0 + k) and y0 + k < 196 then px(x, y0 + k, k < n // 2 and crust[2] or crust[1]) end end
  end
end
-- snow ledge along the top with icicles (long at the cold ends, short over the warm middle)
for x = 350, 422 do
  local hh = 2 + floor(hash(x // 3, 1, 21) * 2)
  for k = 0, hh do px(x, 132 - k, k == hh and S.hi or (x < 386 and S.base or S.shade)) end
  px(x, 133, S.deep)
end
F.icicles(352, 366, 134, 9, 22, .6) F.icicles(406, 420, 134, 9, 23, .6) F.icicles(367, 405, 134, 3, 24, .4)
-- steam rising out of the niche behind the head and over the rocks
plume(390, 128, 38, .5, 6, 3, .95)
plume(414, 126, 30, .55, 5, 4, .8)
-- the carved stone gnome head spout
do
  local hx, hy = 386, 158
  local hat = poly{ { hx - 13, hy - 8 }, { hx + 13, hy - 8 }, { hx + 6, hy - 22 }, { hx + 11, hy - 26 }, { hx + 2, hy - 25 }, { hx - 6, hy - 18 } }
  local fc = c:rrect(hx - 11, hy - 9, hx + 11, hy + 3, 4)
  local beard = poly{ { hx - 12, hy - 1 }, { hx + 12, hy - 1 }, { hx + 9, hy + 12 }, { hx, hy + 18 }, { hx - 9, hy + 12 } }
  local head = union(hat, fc, beard)
  c:rim(head, trav.edge)
  part(fc, trav, { nopop = true }) part(beard, trav, { nopop = true }) part(hat, trav, { nopop = true })
  hline(hx - 13, hx + 13, hy - 8, trav.deep) hline(hx - 12, hx + 12, hy - 9, trav.hi)
  beard:each(function(x, y) if (x + 2 * y) % 5 == 0 and y > hy + 1 then px(x, y, trav.shade) end end)
  for _, ex in ipairs({ hx - 6, hx + 6 }) do px(ex - 2, hy - 4, trav.edge) px(ex - 1, hy - 3, trav.edge) px(ex, hy - 3, trav.edge) px(ex + 1, hy - 3, trav.edge) px(ex + 2, hy - 4, trav.edge) end
  local nose = c:ellipse(hx, hy - 1, 4, 3) c:rim(nose, trav.deep) part(nose, trav, { nopop = true }) px(hx - 2, hy - 3, trav.hi) px(hx - 1, hy - 3, trav.hi)
  px(hx - 9, hy - 1, trav.shade) px(hx + 9, hy - 1, trav.shade)
  -- a copper pipe gone green, ochre mineral crust down the beard below it
  local pipe = rect(hx - 2, hy + 4, hx + 4, hy + 7) c:rim(pipe, L.timber.edge) fill(pipe, "#6aa88e") hline(hx - 2, hx + 4, hy + 4, "#a8d8c0") fill(rect(hx + 3, hy + 5, hx + 4, hy + 6), HW.edge)
  for y = hy + 8, hy + 16 do px(hx + 1, y, crust[1 + (y % 2)]) px(hx + 2, y, crust[2]) if y > hy + 11 then px(hx, y, crust[3]) end end
  -- a snow cap on the hat tip, a little rime on the brim
  F.snowCap(hat, 3, 25, { cx = hx + 2 })
  for x = hx - 12, hx + 12, 3 do px(x, hy - 9, S.hi) end
end
-- the jet: an arc of hot water from the mouth down into the basin
local JX0, JY0 = 391, 164
local function jetY(x) local t = (x - JX0) / 18 return JY0 + floor(t * t * 22 + t * 2) end
for x = JX0, JX0 + 17 do
  local y0, y1 = jetY(x), jetY(x + 1)
  for y = y0, math.max(y0 + 3, y1 + 1) do px(x, y, HW.base) px(x + 1, y, HW.base) px(x + 2, y, HW.shade) end
  px(x, y0, HW.hi) px(x, y0 - 1, HW.edge)
  if x % 3 == 0 then px(x + 1, y0 + 1, GL) end
end

---------------------------------------------------------------- the basin, its overflow and the fox
F.depth(3)
local BX, BY = 392, 202
local inner
do
  local outer = c:ellipse(BX, BY, 40, 10)
  local wall = rect(BX - 40, BY, BX + 40, BY + 8)
  inner = c:ellipse(BX, BY - 1, 35, 7)
  rimOf(union(outer, wall), L.stone)
  part(union(outer, wall), L.stone)
  F.rubble(wall, L.stone, BY, 4, 26)
  wall:each(function(x, y) if (x - BX) > 20 and y > BY + 2 and hash(x, y, 27) < .6 then px(x, y, L.stone.shade) end end)
  outer:edge():each(function(x, y) if y < BY then px(x, y, L.stone.hi) end end)
  F.water(inner, HW)
  -- milky swirls and bubbles in the hot water
  inner:each(function(x, y)
    if hash(x // 3, y, 28) < .18 and (x + y) % 3 == 0 then px(x, y, HW.hi) end
    if hash(x, y, 29) < .025 then px(x, y, GL) px(x + 1, y, HW.hi) end
  end)
  -- ochre crust stains down the wall where it overflows, green moss creeping up the wall, snow banked at its foot
  for x = BX - 40, BX + 40 do
    if hash(x, 4, 12) < .5 then local n = floor(hash(x, 5, 12) * 4) for k = 0, n do px(x, BY + 8 - k, k == n and hmoss.hi or hmoss.base) end end
    if x < BX - 26 and hash(x, 6, 12) < .5 then vline(x, BY + 1, BY + 2 + floor(hash(x, 7, 12) * 5), crust[1 + floor(hash(x, 8, 12) * 3)]) end
    local hh = 1 + floor(hash(x // 3, 9, 12) * 3)
    if x > BX - 6 then for k = 0, hh do px(x, BY + 9 - k + 1, k == hh and S.hi or S.base) end end
  end
end
-- the trickle from a crack in the rock into a gnome's pail (steaming)
do
  local cx, cy = 334, 168
  fill(line({ { cx - 3, cy - 4 }, { cx, cy } }, 2), rock.edge)
  for y = cy - 3, cy + 6 do px(cx - 1 + floor((y - cy + 4) * .3), y + 1, crust[2]) end
  for y = cy, 196 do px(cx + floor((y - cy) * .1), y, ((y // 2) % 2 == 0) and HW.hi or HW.base) end
  local _, hx, hy = F.gnome(318, 218, { hat = L.awnA, coat = L.lav, arm = "out" })
  local pail = poly{ { hx + 1, hy - 7 }, { hx + 10, hy - 7 }, { hx + 9, hy + 3 }, { hx + 2, hy + 3 } }
  c:rim(pail, L.timber.edge) part(pail, L.board) F.planks(pail, L.board, 3, true, 31)
  hline(hx + 1, hx + 10, hy - 5, L.iron.shade) hline(hx + 2, hx + 9, hy + 1, L.iron.shade)
  hline(hx + 2, hx + 9, hy - 7, HW.hi) px(hx + 5, hy - 8, GL) px(hx + 8, hy - 9, HW.hi)
  c:ellipse(hx + 5, hy - 12, 5, 4):edge():each(function(x, y) if y < hy - 11 then px(x, y, L.iron.base) end end)
  F.steam(hx + 3, hy - 10, 4, .4, 32)
end
-- rimstone steps where the overflow spills off the basin lip: little ochre-cream terraces with water on each
do
  for k = 0, 3 do
    local x, y = 350 - k * 4, 204 + k * 3
    local st = rect(x - 3, y, x + 3, y + 2)
    c:rim(st, trav.edge) fill(st, trav.base) hline(x - 3, x + 3, y, HW.hi) hline(x - 2, x + 3, y + 2, crust[2]) px(x - 3, y + 1, trav.hi)
  end
end
-- QUIRK: an arctic fox in a red gnome hat soaking to its chin in the basin, eyes shut, under the hot shower
do
  F.sprite({
    "...........RR.....",
    "..........RRr.....",
    ".........HRRr.....",
    "........HRRRr.....",
    ".......HRRRRr.....",
    ".k....HRRRRRRr..k.",
    ".kF..HRRRRRRRRr.Fk",
    ".kFFbbbbbbbbbbbbFk",
    "..FFFFFFFFFFFFFFf.",
    ".FFFkkFFFFFFkkFFf.",
    ".FFFFkFFFFFFkFFFf.",
    ".fFpFFFFnnFFFFpFf.",
    "..fFFFFFFnFFFFFf..",
    "..ffFFFFmmFFFFff..",
    "...ffFFFFFFFFff...",
  }, 399, 180, { R = L.awnA.base, r = L.awnA.shade, H = L.awnA.hi, b = L.awnB.base, F = L.fur.hi, f = L.fur.shade,
    k = L.timber.edge, n = L.timber.edge, m = L.petal.shade, p = L.petal.hi })
  -- ripple rings round its neck, splashes on the hat
  for x = 397, 418 do if (x % 3) ~= 0 then px(x, 195, HW.hi) end end
  hline(394, 398, 197, GL) hline(417, 421, 197, GL) hline(399, 416, 197, HW.shade)
  for _, p in ipairs({ { 409, 176 }, { 405, 178 }, { 413, 177 }, { 402, 181 }, { 417, 182 }, { 411, 173 }, { 398, 186 }, { 420, 186 } }) do px(p[1], p[2], HW.hi) end
  px(407, 175, GL) px(414, 175, GL)
  -- a folded striped towel on the basin rim beside it
  local tw = c:rrect(424, 193, 436, 198, 1) c:rim(tw, L.timber.edge) fill(tw, L.awnB.base)
  hline(424, 436, 195, L.wall2.base) hline(424, 436, 197, L.wall2.base) hline(424, 436, 193, L.awnB.hi) px(436, 198, L.awnB.shade)
end
-- low steam drifting off the basin water (in front, thin)
F.steam(366, 198, 6, .5, 33) F.steam(382, 200, 5, .3, 34) F.steam(426, 199, 5, .6, 35)
-- the brook winding down-left under the road into the pond
local brook = HP.mask()
do
  local pts = { { 340, 214 }, { 330, 220 }, { 318, 226 }, { 296, 232 }, { 270, 238 }, { 240, 242 }, { 210, 244 }, { 180, 247 }, { 150, 250 } }
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local w = 10 + floor(i * 1.6)
    brook:add(line({ a, b }, w))
    brook:add(c:ellipse(b[1], b[2], w // 2, w // 2))
  end
  local pond = c:ellipse(84, 252, 76, 18):clip(rect(19, 230, 200, 269))
  brook:add(pond)
end
local onRoad = HP.mask()
brook:each(function(x, y) if F.roadM:has(x, y) then onRoad:set(x, y) end end)
brook:cut(onRoad)
do
  local bank = brook:grow(3):cut(brook):cut(F.roadM)
  bank:each(function(x, y) local v = hash(x, y, 51) px(x, y, v < .45 and S.hi or (v < .75 and S.base or (v < .88 and hmoss.base or L.stone.base))) end)
  F.water(brook, HW, { step = 3 })
  -- ice shelves along the cold banks: a pale shelf with a dark undercut line into the water
  local shelf = brook:copy():cut(brook:shrink(2))
  shelf:each(function(x, y)
    if hash(x // 6, y // 3, 53) < .6 and y > 222 then px(x, y, brook:has(x, y + 1) and brook:has(x, y + 2) and L.ice.base or L.ice.hi) end
  end)
  brook:shrink(2):each(function(x, y) if shelf:has(x, y - 1) and c:get(x, y - 1) == L.ice.base and hash(x, y, 54) < .7 then px(x, y, HW.edge) end end)
  brook:each(function(x, y)
    if y % 3 == 1 and hash(x // 5, y, 54) < .3 and brook:has(x - 2, y) and brook:has(x + 2, y) and brook:has(x, y + 2) and c:get(x, y) ~= L.ice.hi and c:get(x, y) ~= L.ice.base then px(x, y, HW.hi) end
    if hash(x, y, 55) < .012 and brook:has(x, y - 3) then px(x, y, GL) end
  end)
  -- snow-capped stones in the stream with a foam lip on the upstream side
  for _, s in ipairs({ { 326, 222 }, { 306, 230 }, { 286, 235 }, { 186, 247 }, { 266, 241 } }) do
    local m = c:ellipse(s[1], s[2], 3, 2) rimOf(m, L.stone) part(m, L.stone, { nopop = true })
    hline(s[1] - 2, s[1] + 1, s[2] - 2, S.hi) px(s[1] + 2, s[2] - 2, S.base)
    for k = 0, 3 do px(s[1] + 3 + k, s[2] - 2 + (k % 2), GL) end hline(s[1] - 4, s[1] - 1, s[2] + 3, HW.hi)
  end
end
-- stone bridge where the road crosses the brook: snow on the coping, icicles under the arches
do
  local Y0, Y1 = 226, 258
  local par, cope = HP.mask(), HP.mask()
  for y = Y0, Y1 do
    local xl, xr = floor(F.xl(y)), floor(F.xr(y) + .99)
    par:add(rect(xl - 7, y - 10, xl + 1, y)):add(rect(xr - 1, y - 10, xr + 7, y))
  end
  par:clip(rect(0, Y0 - 10, 479, Y1))
  par:each(function(x, y) if not par:has(x, y - 2) then cope:set(x, y) end end)
  local wallL = poly{ { floor(F.xl(234)) - 22, 236 }, { floor(F.xl(234)) - 6, 230 }, { floor(F.xl(256)) - 6, 258 }, { floor(F.xl(256)) - 24, 258 } }
  local wallR = poly{ { floor(F.xr(226)) + 6, 224 }, { floor(F.xr(226)) + 22, 228 }, { floor(F.xr(244)) + 22, 248 }, { floor(F.xr(244)) + 6, 248 } }
  local walls = union(wallL, wallR)
  rimOf(union(par, walls), L.stone)
  part(walls, L.stone, { nopop = true }) F.rubble(walls, L.stone, 224, 4, 56)
  for _, a in ipairs({ { floor(F.xl(244)) - 15, 251, wallL }, { floor(F.xr(236)) + 14, 242, wallR } }) do
    local arch = c:ellipse(a[1], a[2], 7, 9):clip(rect(a[1] - 7, a[2] - 9, a[1] + 7, a[2] + 4)):clip(a[3])
    fill(arch, HW.edge)
    arch:each(function(x, y) if y > a[2] - 2 then px(x, y, (x + y) % 3 == 0 and HW.shade or HW.deep) end end)
    c:ellipse(a[1], a[2], 9, 11):cut(c:ellipse(a[1], a[2], 7, 9)):clip(rect(a[1] - 9, a[2] - 11, a[1] + 9, a[2])):clip(a[3]):each(function(x, y)
      px(x, y, (math.atan(y - a[2], x - a[1]) * 4 // 1) % 2 == 0 and L.stone.hi or L.stone.base) end)
    for k = 0, 4 do px(a[1] - 4 + k * 2, a[2] + 3, GL) end
    -- icicles hanging in the arch mouth
    for k = -4, 4, 2 do local n = 2 + floor(hash(k, a[1], 61) * 4) for t = 0, n do if arch:has(a[1] + k, a[2] - 8 + t) then px(a[1] + k, a[2] - 8 + t, t == n and L.ice.deep or L.ice.hi) end end end
    F.steam(a[1], a[2] - 1, 3, .4, a[1])
  end
  part(par, L.stone, { nopop = true })
  F.courses(par, Y0 - 10, 4, 7, L.stone)
  par:each(function(x, y) if hash(x, y, 57) < .06 then px(x, y, L.lichen.base) end end)
  cope:each(function(x, y) px(x, y, cope:has(x, y - 1) and S.base or S.hi) end)
  for _, p in ipairs({ { floor(F.xl(254)) - 6, 254 }, { floor(F.xr(250)) + 4, 250 } }) do for k = -4, 4 do px(p[1] + k, p[2] - (k % 2), S.base) px(p[1] + k, p[2] - 1 - (k % 2), S.hi) end end
end

---------------------------------------------------------------- left: a stone well-head with a sod roof, a gnome winding the bucket
F.depth(3)
do
  local x0, x1, yb = 52, 104, 204
  local wall = c:rrect(x0, yb - 18, x1, yb, 3)
  local postL, postR = rect(x0 + 4, yb - 52, x0 + 7, yb - 18), rect(x1 - 7, yb - 52, x1 - 4, yb - 18)
  local roof = poly{ { x0 - 6, yb - 48 }, { (x0 + x1) // 2, yb - 66 }, { x1 + 6, yb - 48 } }:add(rect(x0 - 6, yb - 49, x1 + 6, yb - 46))
  local axle = rect(x0 + 4, yb - 36, x1 - 4, yb - 34)
  local crank = line({ { x1 - 2, yb - 35 }, { x1 + 4, yb - 35 }, { x1 + 4, yb - 29 } }, 2)
  F.shadow(x0 + 2, x1, yb, 6, 4)
  rimOf(union(wall, postL, postR, roof, axle, crank), L.timber)
  part(wall, L.stone) F.rubble(wall, L.stone, yb - 18, 5, 62)
  hline(x0 + 2, x1 - 2, yb - 18, S.hi) hline(x0 + 3, x1 - 3, yb - 17, S.base)
  part(postL, L.timber, { nopop = true }) part(postR, L.timber, { nopop = true })
  part(roof, L.roof, { sep = true }) F.sod(roof, L.roof, yb - 66, (x0 + x1) // 2)
  F.snowCap(roof, 4, 63, { cx = (x0 + x1) // 2, lip = true })
  F.icicles(x0 - 5, x1 + 5, yb - 45, 5, 64)
  part(axle, L.timber, { nopop = true, noshade = true })
  fill(rect((x0 + x1) // 2 - 4, yb - 37, (x0 + x1) // 2 + 4, yb - 33), L.board.base)
  for x = (x0 + x1) // 2 - 4, (x0 + x1) // 2 + 4, 2 do vline(x, yb - 37, yb - 33, L.board.shade) end
  part(crank, L.iron, { nopop = true, noshade = true })
  local bx = (x0 + x1) // 2
  vline(bx, yb - 32, yb - 26, L.board.deep)
  local bk = poly{ { bx - 5, yb - 25 }, { bx + 5, yb - 25 }, { bx + 4, yb - 17 }, { bx - 4, yb - 17 } }
  c:rim(bk, L.timber.edge) part(bk, L.board) hline(bx - 5, bx + 5, yb - 23, L.iron.shade) hline(bx - 4, bx + 4, yb - 25, L.ice.hi)
  F.icicles(bx - 4, bx + 4, yb - 16, 2, 65, .5)
  -- snow banked against the well foot
  for x = x0 - 3, x1 + 2 do local hh = floor(hash(x // 3, 1, 66) * 3) for k = 0, hh do px(x, yb + 1 - k, k == hh and S.hi or S.base) end end
  local _, hx, hy = F.gnome(x1 + 14, yb + 4, { hat = L.awnA, coat = L.accent, arm = "up", flip = true })
  fill(line({ { hx, hy }, { x1 + 4, yb - 29 } }), L.skin.base)
end
F.willow(40, 210, 7, 9, 67) F.willow(114, 214, 5, 6, 68)

---------------------------------------------------------------- road: gnome with two steaming pails on a yoke; the hot-spring sign
F.depth(3)
do
  local x, yb = 262, 212
  F.gnome(x, yb, { hat = L.fern, coat = L.roof2, arm = "hold" })
  local yoke = line({ { x - 16, yb - 12 }, { x, yb - 14 }, { x + 16, yb - 12 } }, 2)
  c:rim(yoke, L.timber.edge) part(yoke, L.board, { nopop = true, noshade = true })
  for _, sx in ipairs({ -16, 16 }) do
    vline(x + sx, yb - 11, yb - 6, L.board.deep)
    local p = poly{ { x + sx - 5, yb - 6 }, { x + sx + 5, yb - 6 }, { x + sx + 4, yb + 2 }, { x + sx - 4, yb + 2 } }
    c:rim(p, L.timber.edge) part(p, L.board) hline(x + sx - 5, x + sx + 5, yb - 4, L.iron.shade) hline(x + sx - 4, x + sx + 4, yb - 6, HW.hi)
    px(x + sx + 3, yb + 4, HW.hi)
    F.steam(x + sx, yb - 9, 4, .4, 70 + sx)
  end
  F.tracks({ { 258, 204 }, { 250, 170 } }, "boot", 6)
end
do -- the spring sign: the steaming-bowl mark (a bowl with three red wavy steam lines), snow on top
  local post = rect(206, 168, 207, 196)
  local bd = rect(194, 156, 220, 170)
  rimOf(union(post, bd), L.timber) part(post, L.timber, { nopop = true }) part(bd, L.board, { nopop = true }) c:edgeIn(bd, L.board.deep)
  F.planks(bd:shrink(1), L.board, 5, false, 33)
  local bowl = c:ellipse(207, 165, 7, 3):clip(rect(199, 165, 215, 169))
  c:rim(bowl, HW.edge) fill(bowl, HW.base) hline(201, 213, 165, HW.hi) px(203, 166, GL)
  for i, wx in ipairs({ 203, 207, 211 }) do for y = 157, 162 do px(wx + ((y + i) % 3 == 0 and 1 or 0), y, L.awnA.base) end end
  for x = 193, 221 do local hh = floor(hash(x // 2, 1, 34) * 2) for k = 0, hh do px(x, 155 - k, k == hh and S.hi or S.base) end end
  F.icicles(195, 219, 171, 3, 35, .4)
end

---------------------------------------------------------------- a stall by the sign: jugs of spring water and striped towels, a seller behind
F.depth(3)
do
  F.gnome(156, 188, { hat = L.lav, coat = L.awnB, arm = "out", noShadow = true })
  local top = rect(132, 186, 182, 189)
  local legs = rect(135, 190, 136, 200):add(rect(178, 190, 179, 200))
  local cloth = rect(132, 190, 182, 194)
  F.shadow(134, 182, 201, 6, 3)
  rimOf(union(top, legs, cloth), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true }) part(top, L.board, { nopop = true }) hline(132, 182, 186, L.board.hi)
  fill(cloth, L.awnB.base) cloth:each(function(x, y) if ((x - 132) // 4) % 2 == 0 then px(x, y, L.wall2.base) end if y == 194 then px(x, y, L.wall2.deep) end end)
  for i, jx in ipairs({ 137, 147, 174 }) do
    local big = i % 2 == 1
    local jh = big and 10 or 7
    local jug = c:rrect(jx - 3, 185 - jh, jx + 3, 185, 2):add(rect(jx - 1, 183 - jh, jx + 1, 185 - jh))
    local hnd = c:ellipse(jx + 4, 180 - jh // 2, 2, 2):cut(c:ellipse(jx + 4, 180 - jh // 2, 1, 1))
    c:rim(union(jug, hnd), L.timber.edge) part(jug, L.soil) fill(hnd, L.soil.shade)
    hline(jx - 3, jx + 3, 182 - jh // 2, L.gold.base) px(jx - 2, 184 - jh, L.soil.hi)
  end
  F.steam(147, 175, 3, .3, 36)
  -- a stack of folded striped towels
  for k = 0, 2 do
    local y = 185 - k * 3
    local tw = rect(161, y - 2, 170, y) c:rim(tw, L.timber.edge)
    local r = ({ L.accent, L.awnA, L.gold })[k + 1]
    fill(tw, r.base) hline(161, 170, y - 2, r.hi) hline(161, 170, y - 1, L.awnB.base)
  end
  hline(132, 182, 195, S.base)
end

---------------------------------------------------------------- mid: a driftwood bench under the birches, a far gnome on the road, path stones
F.depth(2)
do
  local lg = rect(112, 158, 146, 162) rimOf(lg, L.timber) part(lg, L.timber, { nopop = true }) F.logs(lg, L.timber, 158, 5)
  F.logEnd(112, 160, 2) hline(113, 145, 157, S.hi)
  F.gnome(124, 160, { small = true, hat = L.roof2, coat = L.wall2, arm = "out", noShadow = true })
  F.gnome(136, 160, { small = true, hat = L.accent, coat = L.awnA, flip = true, noShadow = true })
  F.gnome(238, 146, { small = true, hat = L.lav, coat = L.wall2, arm = "out" })
  px(248, 139, L.roof2.base) px(248, 140, L.roof2.shade)
end
F.depth(3)
for _, s in ipairs({ { 200, 206 }, { 186, 210 }, { 170, 212 }, { 150, 210 }, { 132, 208 } }) do
  local m = c:ellipse(s[1], s[2], 5, 2) rimOf(m, L.stone) part(m, L.stone, { nopop = true })
  hline(s[1] - 3, s[1] + 2, s[2] - 2, S.hi) px(s[1] + 3, s[2] - 1, S.base)
end

---------------------------------------------------------------- right of the road: a small gnome with a jug, a young spruce and willow
F.depth(2)
F.conifer(280, 152, 28, L.foliage2, 61) F.willow(300, 148, 8, 8, 62)
F.depth(3)
do
  local _, hx, hy = F.gnome(286, 192, { hat = L.awnA, coat = L.accent, arm = "hold" })
  local jug = c:rrect(hx - 2, hy - 6, hx + 3, hy + 1, 2) c:rim(jug, L.timber.edge) part(jug, L.soil, { nopop = true }) px(hx - 1, hy - 5, L.soil.hi)
end

---------------------------------------------------------------- the pond: open steaming water, swans, a gnome washing laundry in it
F.depth(3)
local function swan(x, y, flip)
  local rows = {
    "..WWW.........",
    ".bkWW.........",
    "...WW.........",
    "...WW.........",
    "...WW...WW....",
    "...WWW.WWWWW..",
    "...WWWWWWWWWWW",
    "....wWWWWWWWw.",
    ".....wwwwwww..",
  }
  if flip then for i, r in ipairs(rows) do rows[i] = r:reverse() end end
  F.sprite(rows, x, y, { W = L.fur.hi, w = L.fur.shade, b = L.gold.base, k = L.timber.edge })
  hline(x + 3, x + 13, y + 9, HW.hi) hline(x + 5, x + 11, y + 10, HW.shade)
end
swan(52, 238) swan(92, 246, true)
for _, s in ipairs({ { 30, 258, 6, 4 }, { 132, 262, 5, 3 } }) do F.snowCap(F.rock(s[1], s[2], s[3], s[4]), 2, s[1]) end
do -- dry sedge with cotton grass at the pond's left, hoarfrost on the tips
  local m = HP.mask()
  for i = 0, 8 do
    local x = 22 + i * 3 + (i % 2)
    local h = 10 + floor(hash(i, 4, 3) * 12)
    m:add(line({ { x, 248 }, { x + (i % 3) - 1, 248 - h } }, 1))
  end
  c:rim(m, L.fern.edge)
  m:each(function(x, y) px(x, y, hash(x, y, 4) < .3 and L.fern.shade or (y < 236 and L.fern.hi or L.fern.base)) end)
  for i = 0, 8, 2 do
    local x = 22 + i * 3 + (i % 2) + (i % 3) - 1
    local h = 10 + floor(hash(i, 4, 3) * 12)
    local cm = c:ellipse(x, 248 - h - 2, 2, 2) c:rim(cm, L.fur.deep) fill(cm, L.fur.hi) px(x + 1, 248 - h - 1, L.fur.shade)
  end
  for x = 18, 50 do px(x, 249, S.hi) px(x, 250, S.base) end
end
do -- the washer gnome on a flat stone, a washboard, a basket of laundry; the wash water steams
  local st = c:ellipse(170, 236, 12, 3) rimOf(st, L.stone) part(st, L.stone, { nopop = true })
  local _, hx, hy = F.gnome(168, 232, { hat = L.awnB, coat = L.fern, arm = "out", flip = true, noShadow = true })
  local wb = rect(hx - 6, hy - 6, hx, hy + 4) c:rim(wb, L.timber.edge) part(wb, L.board, { nopop = true })
  for y = hy - 4, hy + 3, 2 do hline(hx - 5, hx - 1, y, L.board.deep) end
  for k = 0, 2 do hline(hx - 12 - k * 2, hx - 6 + k * 2, hy + 7 + k * 2, HW.hi) end
  F.steam(hx - 8, hy + 4, 5, .5, 37)
  local bsk = c:rrect(184, 222, 202, 234, 3) rimOf(bsk, L.board) part(bsk, L.roof)
  bsk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.roof.shade) elseif (x - y) % 4 == 0 then px(x, y, L.roof.hi) end end)
  fill(c:ellipse(189, 221, 4, 2), L.accent.base) fill(c:ellipse(196, 220, 4, 2), L.wall2.base) px(194, 219, L.wall2.hi) px(187, 220, L.accent.hi)
end

---------------------------------------------------------------- round the rocks: sedge, bearberry with red berries in melted patches
F.depth(3)
for _, f in ipairs({ { 292, 214, 6 }, { 306, 222, 5 }, { 452, 214, 6 }, { 376, 222, 5 }, { 120, 208, 5 }, { 468, 220, 5 }, { 230, 214, 4 } }) do F.fern(f[1], f[2], f[3]) end
for i = 0, 9 do
  local x, y = 300 + floor(hash(i, 1, 71) * 160), 218 + floor(hash(i, 2, 71) * 10)
  if not F.roadM:has(x, y) and not brook:grow(3):has(x, y) and not (x >= 378 and y >= 228) then
    -- a melted patch of moss with bearberry leaves and red berries
    for _, d in ipairs({ { -3, 0 }, { -1, -1 }, { 1, 0 }, { 3, -1 }, { 0, 1 }, { -2, 1 }, { 2, 1 } }) do
      px(x + d[1], y + d[2], hash(d[1], i, 72) < .5 and L.rust.base or hmoss.shade) px(x + d[1] + 1, y + d[2], L.rust.shade)
    end
    px(x - 1, y - 2, L.rust.hi) px(x, y - 1, L.apple.base) px(x + 2, y, L.apple.hi) px(x - 2, y, L.apple.base)
    hline(x - 3, x + 4, y + 2, S.shade)
  end
end
for i, s in ipairs({ { 292, 206 }, { 306, 202 }, { 322, 204 } }) do
  local m = c:ellipse(s[1], s[2], 5, 2) rimOf(m, L.stone) part(m, L.stone, { nopop = true }) hline(s[1] - 3, s[1] + 1, s[2] - 2, S.hi)
end
F.tree(458, 228, 30, 2)
-- an ermine in white winter coat, black tail tip, peeking out by the rocks
F.sprite({
  ".kk.........",
  "kWWW........",
  "WeWWW.......",
  "nWWWWWWWWW..",
  ".wWWWWWWWWWD",
  "..w.w...w.DD",
}, 288, 194, { W = L.fur.hi, w = L.fur.shade, k = L.fur.shade, e = L.timber.edge, n = L.timber.edge, D = "#3c3844" })
F.tracks({ { 300, 210 }, { 316, 214 }, { 332, 212 } }, "hare", 6)

---------------------------------------------------------------- foreground: frosted sedge by the brook, a barrel sledge, steam, a raven
F.depth(3)
local function sedge(x, yb, n, hmax, seed)
  local m, heads = HP.mask(), {}
  for i = 1, n do
    local bx = x + floor((hash(i, 1, seed) - .5) * n * 1.4)
    local h = floor(hmax * (.55 + .45 * hash(i, 2, seed)))
    local lean = (hash(i, 3, seed) - .5) * 7
    m:add(line({ { bx, yb }, { bx + lean * .3, yb - h * .5 }, { bx + lean, yb - h } }, 1))
    if hash(i, 4, seed) < .45 then heads[#heads + 1] = { floor(bx + lean), yb - h - 1 } end
  end
  c:rim(m, L.fern.edge)
  m:each(function(xx, yy)
    local t = (yb - yy) / hmax
    local col = t > .6 and L.fern.hi or (t > .25 and L.fern.base or L.fern.shade)
    if hash(xx, yy, seed) < .2 then col = L.fern.shade elseif hash(xx, yy, seed) > .9 then col = L.rust.base end
    if t > .5 and hash(xx, yy, seed + 1) < .2 then col = S.hi end -- hoarfrost from the steam
    px(xx, yy, col)
  end)
  for _, hd in ipairs(heads) do
    local cm = c:ellipse(hd[1], hd[2] - 1, 1, 2) c:rim(cm, L.fur.deep) fill(cm, L.fur.hi) px(hd[1] + 1, hd[2], L.fur.shade)
  end
  local d = c:ellipse(x, yb, n, 2):clip(rect(x - n - 1, yb - 2, x + n + 1, yb))
  fill(d, S.base) hline(x - n + 1, x, yb - 2, S.hi)
end
sedge(352, 236, 9, 16, 21) sedge(366, 262, 8, 18, 22) sedge(156, 268, 8, 14, 23)
-- a gnome hauling a steaming barrel of spring water on a sledge
do
  local x, yb = 318, 266
  local bar = c:rrect(330, 244, 354, 260, 5)
  local runner = line({ { 326, 264 }, { 358, 264 } }):add(line({ { 326, 264 }, { 323, 261 }, { 324, 258 } }))
  local stan = rect(333, 261, 334, 263):add(rect(349, 261, 350, 263))
  F.shadowM(c:ellipse(346, 267, 16, 1))
  rimOf(union(bar, runner, stan), L.timber)
  part(bar, L.timber) F.planks(bar, L.timber, 4, true, 12)
  for _, hy in ipairs({ 247, 257 }) do hline(330, 354, hy, L.iron.shade) hline(331, 353, hy - 1, L.iron.hi) end
  part(runner, L.iron, { nopop = true, noshade = true }) hline(326, 358, 264, L.iron.hi)
  part(stan, L.timber, { nopop = true, noshade = true })
  hline(331, 353, 244, S.hi)
  fill(rect(339, 242, 345, 243), HW.base) px(340, 242, HW.hi)
  F.steam(342, 239, 6, .5, 38)
  local _, hx, hy = F.gnome(x, yb, { hat = L.roof2, coat = L.wall2, arm = "out" })
  line({ { hx, hy }, { 324, 260 } }):each(function(xx, yy) px(xx, yy, L.soil.base) end)
  F.tracks({ { 300, 268 }, { 280, 262 } }, "boot", 6)
end
-- a raven on the bridge coping
F.sprite({ "..kk....", ".kKKk...", "gKsKKk..", ".kKKKKkt", "..kKKkkt", "..l.l..." }, floor(F.xr(230)) + 1, 207,
  { k = "#3e3a48", K = "#4e4a5c", s = "#7a7a98", g = L.iron.base, t = "#36323e", l = L.timber.edge })
-- steam plumes off the brook and pond (thin, drifting right)
plume(300, 228, 14, 1.2, 5, 41, .8)
plume(226, 242, 12, 1.4, 5, 42, .75)
plume(60, 252, 16, 1.3, 7, 43, .85)
plume(122, 256, 12, 1.5, 6, 44, .75)
-- the main basin plume: rising from the right half of the basin, behind the fox, drifting up over the outcrop
plume(432, 194, 80, .18, 8, 45, 1.15)
plume(360, 198, 30, -.15, 5, 46, .8)

F.depth(0)
F.birds({ { 330, 44, 2 }, { 340, 50, 1 }, { 168, 60, 2 }, { 186, 54, 2 }, { 236, 70, 1 } })
F.finish()
