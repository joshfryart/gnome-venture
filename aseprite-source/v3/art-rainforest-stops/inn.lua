-- inn.lua : "Inn" stop look, RAINFOREST (rainforest_canopy), 480x270 gate view.
-- Same composition as the Maplewold inn (art-2701-batch4/stops/opus3/inn.lua) and the forest inn, re-cast for the
-- jungle: left hero: a big jungle lodge raised on dark hardwood stilts, a steep hipped palm-thatch roof with upswept
-- eave tips, crossed ridge horns and two smoking thatch vent cowls, woven-mat upper rooms in a bamboo frame with
-- propped palm shutters, a bamboo veranda railing, a string of paper lanterns under the eave and a bamboo stair up
-- to the door. Under the floor: two hammocks (a gnome asleep in one, a capuchin in the other) and a glowing bamboo
-- bar counter. A hardwood gallows post by the road hangs the tankard board. Right: a beer garden under a big
-- buttress-rooted fig, a long bamboo table with three gnomes raising coconut cups, paper-lantern festoons with a
-- spider monkey swinging from them, clay jars and bamboo kegs, a waiter. Road's end: a stilted palm-thatch granary.
-- A tapir eats from the fruit cart; a capybara chews the tether at the hitching rail beside a hollow-log trough.
-- Quirk: an ocelot in a red gnome hat asleep on top of the inn sign, tail hanging over the tankard, "z z" rising.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-rainforest-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "inn", out = DIR, farTrees = { 24, 150, 206, 300, 340, 380, 452 }, shafts = { { -70, 18 }, { 440, 14 }, { 470, 8 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local mix = F.mix
local burlap = F.rp("#ead6a4 #ccb27c #a68c5c #7a6644 #4c402e")  -- rice-sack hessian
local clay = F.rp("#f0a878 #d0784a #a85438 #7a3a2c #4a2420")    -- terracotta jars
local ocelot = F.rp("#f6d896 #dcaa58 #b07a3c #6a4228 #3e261c")  -- ocelot coat
local tapir = F.rp("#a49aa0 #786e78 #5a525e #403a48 #28242e")   -- tapir hide
local capy = F.rp("#d8a878 #b07e52 #8a5e3c #604030 #3c281e")    -- capybara fur
local darkBam = F.rp(mix(L.bamboo.deep, L.timber.deep, .35) .. " " .. mix(L.bamboo.deep, L.timber.edge, .55) .. " " .. mix(L.bamboo.edge, L.timber.edge, .5) .. " " .. L.timber.edge .. " " .. L.timber.edge)

---------------------------------------------------------------- local helpers
local function coconut(x, y, half)
  local m = c:ellipse(x, y, 2, 2)
  c:rim(m, L.soil.edge) fill(m, L.soil.base) px(x - 1, y - 1, L.soil.hi)
  if half then fill(rect(x - 1, y - 1, x + 1, y), L.awnB.hi) px(x, y, L.awnB.shade) end
end
local function sack(x, yb, w, r)
  r = r or burlap
  local m = F.sack(x, yb, r, w)
  m:each(function(xx, yy) if (xx + yy) % 3 == 0 and hash(xx, yy, 5) < .4 then px(xx, yy, r.shade) end end)
  px(x, yb - w + 1, L.awnA.base) px(x - 1, yb - w + 2, L.awnA.shade) px(x + 1, yb - w + 2, L.awnA.shade)
  return m
end
-- a round paper lantern hanging from (x, y): cord, cap, ribbed glowing body, base, tassel
local function plantern(x, y, r, big)
  local w, h = big and 3 or 2, big and 7 or 5
  vline(x, y, y + 1, L.timber.deep)
  local body = c:rrect(x - w, y + 3, x + w, y + 3 + h, 2)
  local cap = rect(x - 1, y + 2, x + 1, y + 2):add(rect(x - 1, y + 4 + h, x + 1, y + 4 + h))
  c:rim(union(body, cap), L.timber.edge)
  fill(body, r.base)
  body:each(function(xx, yy)
    if (yy - y) % 2 == 0 then px(xx, yy, r.shade) end
    if xx == x - w and yy > y + 3 then px(xx, yy, r.hi) end
    if xx == x + w then px(xx, yy, r.deep) end
  end)
  px(x - w + 1, y + 4, L.glow.hi) px(x - w + 1, y + 5, r.hi)
  fill(cap, L.timber.base)
  px(x, y + 5 + h, r.deep) px(x, y + 6 + h, r.shade)
end
local lanternCols = { L.awnA, L.glow, L.helic, L.glow, L.orchid }
-- a woven hammock slung between two hooks: ropes fan in, a striped sagging body. Returns its sag function.
local function hammock(x0, y0, x1, y1, sag, r1, r2, thick)
  local function ly(x) local t = (x - x0) / (x1 - x0) return y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) end
  local a, b = x0 + 5, x1 - 5
  local m = HP.mask()
  for x = a, b do
    local t = (x - a) / (b - a)
    local th = floor(1 + (thick or 3) * sin(pi * t) + .5)
    local yy = floor(ly(x) + .5)
    for k = 0, th do m:set(x, yy - th + 1 + k) end
  end
  -- ropes from the hooks to the ends of the bed
  for k = 0, 2 do
    line({ { x0, y0 }, { a, floor(ly(a) + .5) - k } }):each(function(x, y) px(x, y, L.needle.shade) end)
    line({ { x1, y1 }, { b, floor(ly(b) + .5) - k } }):each(function(x, y) px(x, y, L.needle.shade) end)
  end
  c:rim(m, L.timber.edge)
  m:each(function(x, y)
    local st = ((x - a) // 3) % 2 == 0 and r1 or r2
    local h = st.base
    if not m:has(x, y - 1) then h = st.hi elseif not m:has(x, y + 1) then h = st.deep elseif (x + y) % 4 == 0 then h = st.shade end
    px(x, y, h)
  end)
  -- fringe under the bed
  for x = a + 2, b - 2, 2 do local yy = floor(ly(x) + .5) px(x, yy + 2, r1.shade) end
  px(x0, y0, L.iron.hi) px(x1, y1, L.iron.hi)
  return ly
end
local function zed(x, y, s)
  for i = 0, s do px(x + i, y, L.awnB.hi) px(x + i, y + s, L.awnB.hi) px(x + s - i, y + i, L.awnB.hi) end
end
-- a terracotta water jar
local function jar(x, yb, h, r)
  r = r or clay
  local w = floor(h * .45)
  local body = c:ellipse(x, yb - floor(h * .45), w, floor(h * .45))
  local neck = rect(x - 2, yb - h, x + 2, yb - floor(h * .7))
  local lip = rect(x - 3, yb - h - 1, x + 3, yb - h)
  local m = union(body, neck, lip)
  rimOf(m, r) part(m, r, { nopop = true })
  body:each(function(xx, yy) if xx < x - w * .4 and yy < yb - h * .3 then px(xx, yy, r.hi) end end)
  hline(x - w + 1, x + w - 1, yb - floor(h * .55), r.deep) -- a painted band
  for xx = x - w + 2, x + w - 2, 3 do px(xx, yb - floor(h * .55) - 1, L.gold.base) end
  fill(lip, r.hi) px(x + 3, yb - h, r.shade)
  return m
end
-- a bamboo keg: a short fat culm section, rattan bands, a cork bung
local function keg(x, yb, w, h)
  local m = c:rrect(x - w, yb - h, x + w, yb, 2)
  rimOf(m, L.timber)
  m:each(function(xx, yy)
    local k = xx - (x - w)
    local hh = k <= 1 and L.board.hi or (xx >= x + w - 1 and L.board.shade or L.board.base)
    if (yy - (yb - h)) % 5 == 2 then hh = L.needle.shade end
    if xx == x and yy < yb - 1 then hh = L.board.shade end
    px(xx, yy, hh)
  end)
  hline(x - w + 1, x + w - 1, yb - h, L.board.hi)
  px(x + 2, yb - h + 3, L.timber.base)
  return m
end
-- a coconut cup (half shell, cream flesh rim, a pink straw)
local function cupAt(x, y)
  local m = c:ellipse(x + 2, y - 2, 2, 2):add(rect(x, y - 3, x + 4, y - 3))
  c:rim(m, L.soil.edge) fill(m, L.soil.base) px(x + 1, y - 2, L.soil.hi) px(x + 3, y - 1, L.soil.shade)
  hline(x, x + 4, y - 3, L.awnB.hi) hline(x + 1, x + 3, y - 4, L.produce.hi)
  px(x + 3, y - 5, L.petal.base) px(x + 4, y - 6, L.petal.hi)
end

---------------------------------------------------------------- back row: stilted granary at the road's end, far stilt hut
F.depth(1)
F.tree(300, 128, 34, 4)
F.palm(236, 124, 34, 6, { lean = -4 })
do
  F.shadow(248, 292, 131, 8, 3)
  local st = HP.mask()
  for _, sx in ipairs({ 248, 258, 268, 279, 289 }) do st:add(rect(sx, 120, sx + 1, 130)) end
  rimOf(st, L.timber) part(st, L.timber, { nopop = true, noshade = true })
  local top, _, bwall = F.building{ x0 = 246, x1 = 292, yb = 122, wh = 14, rh = 14, wall = L.bamboo, roof = L.roof2, noFrame = true, noAttic = true, noShadow = true }
  F.bambooWall(bwall:copy():clip(rect(246, top + 4, 292, 122)), L.bamboo, 3, false, 61)
  -- big doorway with a lit lamp deep inside and rice sacks piled
  local d = c:rrect(261, 111, 275, 126, 4):clip(rect(261, 111, 275, 122))
  fill(d, L.soil.deep) c:edgeIn(d, L.timber.hi)
  fill(rect(264, 118, 272, 121), burlap.shade) hline(264, 272, 118, burlap.base) px(266, 116, L.glow.base) px(267, 116, L.glow.hi)
  -- a ladder up to the door
  for y = 123, 129, 2 do hline(263, 273, y, L.bamboo.base) end vline(263, 122, 130, L.bamboo.shade) vline(273, 122, 130, L.bamboo.shade)
end
do
  local hs = HP.mask()
  for _, sx in ipairs({ 418, 434, 452 }) do hs:add(rect(sx, 122, sx + 1, 130)) end
  rimOf(hs, L.timber) part(hs, L.timber, { nopop = true, noshade = true })
  local top, _, cwall = F.building{ x0 = 416, x1 = 456, yb = 122, wh = 12, rh = 12, wall = L.plaster, roof = L.roof, noFrame = true, noAttic = true, noShadow = true }
  F.window(424, 113, 428, 116, L.timber) F.window(446, 113, 450, 116, L.timber)
end
F.smoke(436, 96, 4, .5, 2)
F.fenceP(300, 132, 410, 129, 10)
-- the inn's washing line: sarongs and aprons, hazed with the back row
do local wp = rect(318, 110, 319, 130) rimOf(wp, L.bamboo) part(wp, L.bamboo, { nopop = true, noshade = true }) end
F.washing(293, 112, 318, 111, { { "sheet", L.helic }, { "shirt", L.teal }, { "sock", L.orchid } }, 3)

---------------------------------------------------------------- mid right: a palm and a canopy tree, the fruit cart, the tapir
F.depth(2)
F.tree(352, 152, 50, 1)
F.palm(392, 156, 58, 10, { lean = 7 })
F.treeFern(322, 140, 30, 8)
local function fruitCart(x0, yb)
  local bed = poly{ { x0, yb - 12 }, { x0 + 46, yb - 12 }, { x0 + 44, yb - 6 }, { x0 + 2, yb - 6 } }
  local heap = c:ellipse(x0 + 23, yb - 15, 23, 7):clip(rect(x0 - 2, yb - 28, x0 + 48, yb - 11))
  local shaft = line({ { x0, yb - 9 }, { x0 - 16, yb - 3 } }, 2)
  rimOf(union(bed, heap, shaft), L.timber)
  part(shaft, L.bamboo, { nopop = true, noshade = true })
  part(bed, L.timber) F.bambooWall(bed, L.bamboo, 3, false, 23)
  hline(x0 + 1, x0 + 45, yb - 12, L.bamboo.hi)
  -- the heap: banana hands, coconuts, papayas, a pineapple
  part(heap, L.leaf, { nopop = true })
  heap:each(function(x, y)
    local v = hash(x // 3, y // 2, 84)
    local h
    if v < .4 then h = ((x + y) % 3 == 0) and L.gold.shade or L.gold.base if not heap:has(x, y - 1) then h = L.gold.hi end
    elseif v < .55 then h = L.soil.base
    elseif v < .7 then h = L.produce.base
    elseif v < .82 then h = L.leaf.base
    else h = L.gold.base end
    if hash(x, y, 85) < .1 then h = L.gold.hi end
    px(x, y, h)
  end)
  for _, p in ipairs({ { x0 + 8, yb - 17 }, { x0 + 30, yb - 18 }, { x0 + 40, yb - 14 } }) do coconut(p[1], p[2]) end
  -- pineapple crown on top
  local px0, py0 = x0 + 20, yb - 22
  fill(c:ellipse(px0, py0, 2, 3), L.gold.shade) px(px0 - 1, py0 - 1, L.gold.hi) px(px0 + 1, py0 + 1, L.produce.shade)
  for _, d in ipairs({ { -2, -5 }, { -1, -6 }, { 0, -7 }, { 1, -6 }, { 2, -5 }, { 0, -5 }, { -3, -4 }, { 3, -4 } }) do px(px0 + d[1], py0 + d[2], (d[1] < 0) and L.fern.hi or L.fern.shade) end
  for _, wx in ipairs({ x0 + 9, x0 + 37 }) do
    local w = c:ellipse(wx, yb - 4, 6, 6)
    rimOf(w, L.timber) part(w, L.timber, { nopop = true })
    fill(c:ellipse(wx, yb - 4, 3, 3), L.timber.shade)
    vline(wx, yb - 9, yb + 1, L.timber.deep) hline(wx - 5, wx + 5, yb - 4, L.timber.deep) px(wx, yb - 4, L.iron.hi)
  end
end
F.shadow(300, 350, 166, 8, 3)
fruitCart(302, 166)
-- a lowland tapir with its little trunk in the bananas
F.shadowM(c:ellipse(366, 167, 13, 1))
F.sprite({
  ".......ee...............",
  "......eBBhhhhhhhhh......",
  ".....eBBBBBBBBBBBBBh....",
  "....BBBBBBBBBBBBBBBBh...",
  "...BBBBBBBBBBBBBBBBBBh..",
  "..BkBB.BBBBBBBBBBBBBBB..",
  ".BBBB..BBBBBBBBBBBBBBBt.",
  "TBBB...dBBBBBBBBBBBBBd..",
  "TTw.....dBBdddddddBBBd..",
  "T.......BB.d.....BB.d...",
  "........Bd.d.....Bd.d...",
  "........dd.dd....dd.dd..",
  "........ff.ff....ff.ff..",
}, 344, 154, { e = tapir.hi, h = tapir.hi, B = tapir.base, d = tapir.shade, k = L.timber.edge, w = L.awnB.base,
  T = tapir.shade, t = tapir.shade, f = tapir.deep })
px(343, 162, L.gold.hi) px(342, 163, L.gold.base) px(343, 164, L.gold.shade)

---------------------------------------------------------------- behind the inn: a tall canopy tree and a palm over the roof
F.depth(2)
F.tree(16, 118, 84, 1)
F.palm(196, 120, 74, 14, { lean = 10 })

---------------------------------------------------------------- the jungle lodge (left hero)
F.depth(3)
local UX0, UX1, UTOP, DECK = 24, 190, 108, 136
local STILTS = { 28, 78, 122, 152, 184 }
local function lodge()
  local upper = rect(UX0, UTOP, UX1, DECK - 1)
  local roof = poly{ { 12, 109 }, { 202, 109 }, { 180, 62 }, { 34, 62 } }
  local tipL = poly{ { 3, 114 }, { 9, 101 }, { 22, 109 } }
  local tipR = poly{ { 211, 114 }, { 205, 101 }, { 192, 109 } }
  local vents = {}
  for _, vx in ipairs({ 57, 156 }) do vents[#vents + 1] = { x = vx, m = poly{ { vx - 9, 66 }, { vx, 49 }, { vx + 9, 66 } } } end
  local horns = line({ { 36, 63 }, { 28, 54 }, { 25, 52 } }, 2):add(line({ { 178, 63 }, { 186, 54 }, { 189, 52 } }, 2))
  local deck = rect(UX0 - 5, DECK, UX1 + 5, DECK + 3)
  local stilts = HP.mask()
  for _, sx in ipairs(STILTS) do stilts:add(rect(sx, DECK + 3, sx + 3, 178)) end
  local under = rect(30, DECK + 4, 184, 178)
  local sil = union(roof, tipL, tipR, upper, deck, stilts, horns)
  for _, v in ipairs(vents) do sil:add(v.m) end
  F.shadow(32, 190, 182, 16, 6)
  rimOf(sil, L.timber)
  ---------------- the dark under-floor space and its back wall: a set-back bamboo screen
  fill(under, L.timber.edge)
  local back = rect(30, DECK + 9, 184, 176)
  back:each(function(x, y)
    local k = (x - 30) % 4
    local nd = (y + floor(hash((x - 30) // 4, 0, 71) * 9)) % 9
    local h = k == 0 and darkBam.deep or (k == 1 and darkBam.hi or (k == 3 and darkBam.shade or darkBam.base))
    if nd == 0 and k ~= 0 then h = darkBam.deep end
    if y > 168 and k ~= 0 then h = darkBam.shade end
    px(x, y, h)
  end)
  under:each(function(x, y) if y <= DECK + 8 then px(x, y, (y == DECK + 8 and x % 3 == 0) and darkBam.base or L.timber.edge) end end)
  -- joists seen from below
  for x = 32, 182, 8 do vline(x, DECK + 4, DECK + 7, darkBam.hi) end
  ---------------- roof: palm thatch, hipped ends, ridge cap of bundled leaf, upswept tips
  part(roof, L.roof, { band = 3 })
  F.palmThatch(roof, L.roof, 62, 9999, 81)
  roof:each(function(x, y)
    if y <= 65 then px(x, y, (x % 5 < 2) and L.roof2.shade or L.roof2.deep) end
    local lx = 34 - (y - 62) * 22 / 47
    local rx = 180 + (y - 62) * 22 / 47
    if x > rx - 13 and hash(x, y, 9) < .7 then px(x, y, ((y - 62) % 5 == 4) and L.roof.edge or L.roof.deep) end
    if x < lx + 7 and (y - 62) % 5 ~= 4 and hash(x, y, 10) < .5 then px(x, y, L.roof.hi) end
  end)
  hline(34, 180, 62, L.roof2.hi)
  for x = 36, 178, 6 do vline(x, 62, 65, L.bamboo.deep) px(x, 63, L.needle.base) end -- ridge bindings
  for _, t in ipairs({ { tipL, 9 }, { tipR, 205 } }) do
    part(t[1], L.roof, { nopop = true })
    F.palmThatch(t[1], L.roof, 101, t[2] == 9 and 9999 or 0, 82)
  end
  -- fresh green palm patches where the thatch was mended, a bromeliad and a fern growing in the old thatch
  for i, b in ipairs({ { 52, 98, 9 }, { 128, 100, 10 }, { 168, 92, 7 }, { 100, 78, 6 }, { 30, 104, 6 } }) do
    roof:each(function(x, y)
      local d = ((x - b[1]) / b[3]) ^ 2 + ((y - b[2]) / (b[3] * .6)) ^ 2
      if d < 1 and hash(x // 2, y, 30 + i) < .8 then
        local ry = (y - 62) % 5
        local h = ry == 0 and L.roof2.hi or (ry == 4 and L.roof2.deep or ((x + y) % 3 == 0 and L.roof2.shade or L.roof2.base))
        if i % 2 == 0 and d < .6 then h = ry == 0 and L.moss.hi or (ry == 4 and L.moss.deep or L.moss.base) end
        px(x, y, h)
      end
    end)
  end
  F.fern(122, 98, 4) F.fern(170, 90, 3)
  -- the lower thatch darkens toward the eave (the overhang curls under)
  roof:each(function(x, y) if y >= 104 and hash(x, y, 12) < (y - 103) * .18 then px(x, y, (y - 62) % 5 == 4 and L.roof.edge or L.roof.deep) end end)
  -- two thatched dormers with lamp-lit windows and orchid sprays
  for i, dx in ipairs({ 74, 140 }) do
    local dm = poly{ { dx - 12, 99 }, { dx, 79 }, { dx + 12, 99 } }:add(rect(dx - 8, 90, dx + 8, 101))
    rimOf(dm, L.roof)
    part(dm, L.roof, { nopop = true }) F.palmThatch(dm, L.roof, 79, dx, 86 + i)
    local wall = rect(dx - 7, 91, dx + 7, 101)
    part(wall, L.plaster, { nopop = true })
    wall:each(function(x, y) if (((x + y) // 2) % 2 == ((x - y) // 2) % 2) then px(x, y, L.plaster.shade) end end)
    F.window(dx - 4, 92, dx + 3, 98, L.timber, true)
    line({ { dx - 12, 99 }, { dx, 79 } }):each(function(x, y) px(x, y, L.roof.hi) end)
    line({ { dx + 12, 99 }, { dx, 79 } }):each(function(x, y) px(x, y, L.roof.edge) end)
    for x = dx - 11, dx + 11, 2 do px(x, 102, L.roof.deep) end
    px(dx, 77, L.timber.edge) px(dx, 78, L.helic.base) -- a little carved finial
    F.orchid(dx - 7, 101, L.orchid, 2) 
  end
  for _, bx in ipairs({ { 100, 76 }, { 44, 100 } }) do
    local x, y = bx[1], bx[2]
    px(x, y, L.helic.base) px(x - 1, y - 1, L.helic.hi) px(x + 1, y - 1, L.helic.shade) px(x, y - 2, L.helic.hi)
    px(x - 2, y, L.leaf.base) px(x + 2, y, L.leaf.shade) px(x - 3, y + 1, L.leaf.deep) px(x + 3, y + 1, L.leaf.deep) px(x, y + 1, L.leaf.shade)
  end
  -- ridge horns: carved crossed hardwood, curling out
  part(horns, L.timber, { nopop = true, noshade = true })
  line({ { 36, 62 }, { 28, 53 } }):each(function(x, y) px(x, y, L.timber.hi) end)
  line({ { 178, 62 }, { 186, 53 } }):each(function(x, y) px(x, y, L.timber.hi) end)
  px(24, 51, L.helic.base) px(190, 51, L.helic.base)
  -- smoke vents: little thatch cowls on the ridge with a dark smoke mouth
  for _, v in ipairs(vents) do
    rimOf(v.m, L.roof)
    part(v.m, L.roof, { nopop = true }) F.palmThatch(v.m, L.roof, 49, v.x, 83)
    local mouth = poly{ { v.x - 4, 66 }, { v.x, 58 }, { v.x + 4, 66 } }
    fill(mouth, L.timber.edge) mouth:each(function(x, y) if y > 63 and hash(x, y, 4) < .4 then px(x, y, L.glow.deep) end end)
    line({ { v.x - 9, 66 }, { v.x, 49 } }):each(function(x, y) px(x, y, L.roof.hi) end)
    px(v.x, 48, L.bamboo.hi)
  end
  -- ragged leaf fringe under the eave
  hline(4, 210, 109, L.roof.edge) hline(12, 202, 108, L.roof.deep)
  for x = 6, 208 do
    local len = 1 + floor(hash(x, 109, 64) * 3)
    if x > 12 and x < 202 or len < 3 then
      for k = 1, len do px(x, 109 + k, k == len and L.roof.edge or (k == 1 and L.roof.deep or L.roof.shade)) end
    end
  end
  -- a toucan on the ridge
  vline(118, 59, 61, L.timber.edge)
  F.sprite({ "..KKK...", ".KWWKOO.", "KKWeKOOo", "KKKKK...", ".KKK....", "..K....." }, 114, 54,
    { K = "#2e2a30", W = L.gold.hi, e = L.timber.edge, O = L.produce.base, o = L.awnA.base })
  ---------------- upper rooms: woven palm mat in a bamboo frame
  part(upper, L.plaster, { nopop = true })
  upper:each(function(x, y)
    local h
    if (((x + y) // 2) % 2 == ((x - y) // 2) % 2) then h = L.plaster.base else h = L.plaster.shade end
    if hash(x // 3, y // 2, 44) < .05 then h = L.plaster.hi end
    if y <= UTOP + 4 then h = (y <= UTOP + 2) and L.plaster.deep or L.plaster.shade end -- eave shadow
    px(x, y, h)
  end)
  local frame = union(rect(UX0, UTOP, UX1, UTOP + 1), rect(UX0, DECK - 2, UX1, DECK - 1))
  for _, bx in ipairs({ UX0, 58, 90, 122, 152, UX1 - 1 }) do frame:add(rect(bx, UTOP, bx + 2, DECK - 1)) end
  part(frame, L.bamboo, { nopop = true, noshade = true })
  frame:each(function(x, y)
    if (y - UTOP) % 9 == 0 then px(x, y, L.bamboo.deep) elseif (y - UTOP) % 9 == 1 and not frame:has(x - 1, y) then px(x, y, L.shine) end
    if not frame:has(x - 1, y) and frame:has(x + 1, y) and (y - UTOP) % 9 ~= 0 then px(x, y, L.bamboo.hi) end
    if not frame:has(x + 1, y) and frame:has(x - 1, y) then px(x, y, L.bamboo.shade) end
  end)
  -- windows with propped palm shutters
  local function win(x0, x1)
    F.window(x0, UTOP + 8, x1, UTOP + 17, L.timber)
    for y = UTOP + 9, UTOP + 16, 2 do px(x0 + 1, y, L.glow.shade) px(x1 - 1, y + 1, L.glow.shade) end
    local flap = poly{ { x0 - 3, UTOP + 6 }, { x1 + 3, UTOP + 6 }, { x1 + 5, UTOP + 3 }, { x0 - 1, UTOP + 3 } }
    rimOf(flap, L.roof2) part(flap, L.roof2, { nopop = true })
    flap:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.roof2.shade) end if y == UTOP + 3 then px(x, y, L.roof2.hi) end end)
    for x = x0 - 2, x1 + 3, 2 do px(x, UTOP + 7, L.roof2.deep) end
    line({ { x1 + 2, UTOP + 6 }, { x1 + 1, UTOP + 12 } }):each(function(x, y) px(x, y, L.bamboo.shade) end) -- prop stick
  end
  win(36, 50) win(64, 80) win(130, 146) win(160, 176)
  -- the door at the top of the stair, a woven-palm hood and a hanging lantern
  F.door(99, UTOP + 7, 115, DECK - 2, L.teal, true)
  local hood = poly{ { 94, UTOP + 8 }, { 107, UTOP }, { 120, UTOP + 8 } }:add(rect(94, UTOP + 7, 120, UTOP + 9))
  rimOf(hood, L.roof2) part(hood, L.roof2, { nopop = true }) F.palmThatch(hood, L.roof2, UTOP, 107, 84)
  for x = 95, 119, 2 do px(x, UTOP + 10, L.roof2.deep) end
  -- a carved hornbill mask over the hood
  F.sprite({ ".kk.", "kWek", "kOOO", ".kk." }, 105, UTOP - 3, { k = L.timber.base, W = L.awnB.hi, e = L.timber.edge, O = L.produce.base })
  ---------------- the veranda: deck, joist ends, bamboo railing (gap for the stair)
  part(deck, L.timber, { nopop = true, noshade = true })
  F.bambooWall(deck, L.board, 2, true, 85)
  hline(UX0 - 5, UX1 + 5, DECK, L.board.hi)
  for x = UX0 - 3, UX1 + 3, 6 do fill(rect(x, DECK + 2, x + 2, DECK + 3), L.timber.edge) px(x, DECK + 2, L.board.base) end
  local rail = HP.mask()
  local RT = DECK - 10
  for _, seg in ipairs({ { UX0 - 3, 94 }, { 120, UX1 + 3 } }) do
    rail:add(rect(seg[1], RT, seg[2], RT + 1)):add(rect(seg[1], RT + 6, seg[2], RT + 6))
    for x = seg[1], seg[2] - 1, 12 do
      rail:add(rect(x, RT, x + 1, DECK - 1))
      if x + 12 <= seg[2] then rail:add(line({ { x + 2, RT + 2 }, { x + 11, DECK - 1 } })):add(line({ { x + 11, RT + 2 }, { x + 2, DECK - 1 } })) end
    end
    rail:add(rect(seg[2] - 1, RT, seg[2], DECK - 1))
  end
  rimOf(rail, L.timber)
  part(rail, L.bamboo, { nopop = true, noshade = true })
  rail:each(function(x, y)
    if y == RT then px(x, y, L.bamboo.hi) elseif y == RT + 1 then px(x, y, L.bamboo.shade) end
    if (x * 3 + y) % 11 == 0 then px(x, y, L.bamboo.deep) end
  end)
  -- orchids and a fern basket on the rail
  F.orchid(28, RT - 1, L.orchid, 2) F.orchid(182, RT - 1, L.orchid, 2, true)
  for _, bx in ipairs({ 148 }) do
    local b = c:ellipse(bx, RT - 2, 3, 2) rimOf(b, L.timber) fill(b, L.needle.base) px(bx - 1, RT - 3, L.needle.hi)
    F.fern(bx - 2, RT - 4, 3) F.fern(bx + 2, RT - 4, 3)
  end
  ---------------- paper lanterns under the eave
  for i, lx in ipairs({ 30, 56, 88, 124, 154, 186 }) do
    vline(lx, 110, 111, L.timber.deep)
    plantern(lx, 111, lanternCols[(i - 1) % #lanternCols + 1], i % 2 == 0)
  end
  -- a cord sagging between the lanterns along the eave
  for x = 30, 186 do if hash(x, 1, 2) < .5 then px(x, 110 + floor(sin((x - 30) / 30 * pi) + .5), L.timber.deep) end end
  ---------------- stilts on stone pads, braces
  part(stilts, L.timber, { nopop = true })
  stilts:each(function(x, y)
    if not stilts:has(x - 1, y) then px(x, y, L.timber.hi) end
    if hash(x, y // 3, 46) < .12 then px(x, y, L.timber.shade) end
  end)
  for _, sx in ipairs(STILTS) do
    local pad = c:ellipse(sx + 2, 179, 4, 2)
    rimOf(pad, L.stone) part(pad, L.stone, { nopop = true }) F.moss(pad, .3, sx) px(sx, 178, L.wet)
  end
  -- braces between the outer stilts
  for _, br in ipairs({ { 156, DECK + 6, 183, 172 } }) do
    line({ { br[1], br[2] }, { br[3], br[4] } }, 1):each(function(x, y) px(x, y, L.bamboo.shade) end)
  end
end
lodge()

---------------------------------------------------------------- under the lodge: hammocks (left) and the bar (right)
F.depth(3)
do
  -- water jars and rice sacks at the back
  jar(88, 176, 12) jar(38, 176, 9, F.rp("#a8d8cc #6aac9c #48867a #33625c #203e3e"))
  sack(48, 176, 4) sack(66, 176, 4) sack(57, 170, 3)
  -- a long striped hammock: a gnome asleep in it, hat flopped over the end, boots up; a capuchin on his belly
  local ly = hammock(32, 145, 78, 145, 14, L.helic, L.gold, 5)
  local function my(x) return floor(ly(x) + .5) end
  -- head end (left): red cone hat drooping over the side, face, big beard
  local hx0, hy0 = 45, my(45) - 7
  local hat = poly{ { hx0 - 3, hy0 + 2 }, { hx0 + 5, hy0 - 2 }, { hx0 - 2, hy0 - 9 }, { hx0 - 9, hy0 - 5 }, { hx0 - 12, hy0 + 3 }, { hx0 - 9, hy0 + 6 } }
  local face = rect(hx0 + 1, hy0 - 1, hx0 + 8, hy0 + 4)
  local beard = poly{ { hx0 + 2, hy0 + 3 }, { hx0 + 15, hy0 + 3 }, { hx0 + 12, hy0 + 8 }, { hx0 + 3, hy0 + 8 } }
  local boots = rect(63, my(63) - 11, 66, my(63) - 5):add(rect(68, my(68) - 10, 71, my(68) - 4))
  c:rim(union(hat, face, beard, boots), L.timber.edge)
  part(hat, L.awnA, { nopop = true }) hat:each(function(x, y) if y < hy0 - 2 then px(x, y, L.awnA.hi) end end) px(hx0 - 12, hy0 + 3, L.awnB.hi) px(hx0 - 11, hy0 + 3, L.awnB.hi)
  part(face, L.skin, { nopop = true, noshade = true }) hline(hx0 + 2, hx0 + 4, hy0 + 1, L.timber.edge) hline(hx0 + 6, hx0 + 7, hy0 + 1, L.timber.edge) px(hx0 + 5, hy0 + 2, L.skin.shade) px(hx0 + 2, hy0 + 3, L.apple.base)
  part(beard, L.awnB, { nopop = true }) beard:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.awnB.shade) end end)
  part(boots, L.timber, { nopop = true, noshade = true }) hline(63, 66, my(63) - 11, L.timber.hi) hline(68, 71, my(68) - 10, L.timber.hi)
  zed(52, hy0 - 10, 2) zed(57, hy0 - 16, 3)
  -- the capuchin sitting on his belly, eating a banana
  local cx, cy = 56, my(56) - 5
  F.sprite({
    "..MMM.....",
    ".MfffM....",
    ".MfefM..Y.",
    "..fnf..Yy.",
    ".MMMMMMMy.",
    "MMmMMMMM..",
  }, cx - 2, cy - 7, { M = L.timber.base, m = L.timber.shade, f = L.skin.hi, e = L.timber.edge, n = L.skin.deep, Y = L.gold.hi, y = L.gold.shade })
  for k = 0, 6 do px(cx + 7 + k, cy - 1 + floor(sin(k * .9) * 1.5 + .5), L.timber.shade) end -- tail over the side
  -- the bar: glowing back shelves, a bamboo counter, coconut cups
  local backlit = rect(126, 146, 180, 160)
  fill(backlit, L.glow.shade)
  backlit:each(function(x, y)
    if y < 150 and x < 150 then px(x, y, L.glow.base) end
    if (x + y) % 7 == 0 then px(x, y, L.glow.deep) end
  end)
  for _, sy in ipairs({ 151, 156 }) do hline(126, 180, sy, L.timber.base) hline(126, 180, sy + 1, L.timber.edge) end
  for x = 128, 178, 3 do
    local v = hash(x, 2, 88)
    local col = v < .3 and L.leaf or (v < .55 and L.helic or (v < .75 and clay or L.teal))
    px(x, 150, col.base) px(x, 149, col.hi) if v < .5 then px(x, 148, col.shade) end
    if hash(x, 3, 88) < .6 then px(x + 1, 155, L.soil.base) px(x + 1, 154, L.awnB.hi) end
  end
  local counter = rect(126, 162, 180, 177)
  local ctop = rect(124, 160, 182, 162)
  rimOf(union(counter, ctop), L.timber)
  F.bambooWall(counter, L.bamboo, 3, false, 89)
  part(ctop, L.timber, { nopop = true, noshade = true }) hline(124, 182, 160, L.timber.hi)
  hline(126, 180, 168, L.needle.shade) -- rattan lashing
  cupAt(132, 160) cupAt(150, 160) cupAt(166, 160)
  -- a pineapple and a bunch of bananas on the bar
  fill(c:ellipse(158, 157, 2, 2), L.gold.base) px(157, 156, L.gold.hi) px(158, 154, L.fern.hi) px(157, 153, L.fern.base) px(159, 153, L.fern.shade)
  for k = 0, 3 do px(172 + k, 158 - (k % 2), L.gold.hi) px(172 + k, 159, L.gold.shade) end
  -- a hanging lantern over the bar
  plantern(152, DECK + 4, L.awnA)
end
-- the bamboo stair up to the door
do
  local stair = HP.mask()
  stair:add(rect(96, DECK, 97, 182)):add(rect(118, DECK, 119, 182))
  for y = DECK + 4, 180, 5 do stair:add(rect(96, y, 119, y + 1)) end
  rimOf(stair, L.timber)
  part(stair, L.bamboo, { nopop = true, noshade = true })
  stair:each(function(x, y)
    if stair:has(x, y + 1) and not stair:has(x, y - 1) then px(x, y, L.bamboo.hi) end
    if not stair:has(x, y + 1) then px(x, y, L.bamboo.deep) end
    if (x == 96 or x == 118) and (y % 8 == 0) then px(x, y, L.bamboo.deep) end
  end)
  hline(96, 119, 182, L.stone.hi)
  -- a lantern on a bamboo post at the foot of the stair
  local pole = rect(122, 160, 123, 182)
  rimOf(pole, L.timber) part(pole, L.bamboo, { nopop = true, noshade = true })
  hline(120, 125, 160, L.timber.base)
  plantern(120, 160, L.glow, true)
  -- a vine and orchids climbing the left stilt
  for i = 0, 40 do
    local y = 178 - i
    local x = 29 + floor(1.5 * sin(i * .45) + .5)
    px(x, y, L.vine.shade)
    if i % 4 == 0 then px(x - 1, y, L.vine.hi) px(x + 1, y - 1, L.vine.base) end
    if i % 13 == 6 then px(x + 1, y, L.orchid.hi) px(x + 2, y, L.orchid.base) px(x + 1, y + 1, L.orchid.deep) end
  end
  F.vines(rect(UX0 - 5, DECK, UX1 + 5, DECK + 3), .05, 47, 9)
end
-- upstairs: a gnome leaning out of the window, shaking a woven mat, dust flying
F.gnome(72, 130, { small = true, hat = L.leaf, coat = L.awnA, arm = "out" })
do
  local mat = rect(80, 124, 92, 140)
  c:rim(mat, L.timber.edge)
  mat:each(function(x, y)
    local h = (((x + y) // 2) % 2 == ((x - y) // 2) % 2) and L.gold.base or L.gold.shade
    if ((y - 124) // 4) % 2 == 1 then h = (x % 2 == 0) and L.helic.shade or L.helic.base end
    if x == 92 then h = L.gold.deep end
    if y == 124 then h = L.gold.hi end
    px(x, y, h)
  end)
  for x = 80, 92, 2 do px(x, 141, L.gold.shade) end
  for _, p in ipairs({ { 94, 126 }, { 96, 123 }, { 95, 130 }, { 98, 127 }, { 93, 134 }, { 97, 120 } }) do px(p[1], p[2], "#e2e2c4") px(p[1] + 1, p[2], "#cfd4b2") end
end
-- a spider monkey hanging by its tail from the right eave tip
F.sprite({
  "....t.......",
  "....t.......",
  ".....t......",
  "....tMM.....",
  "...MMMMM....",
  "..MMffMM....",
  "..MfefM.....",
  "..MMfnMM....",
  ".MMMMMMMM...",
  "MM.MMMM.MM..",
  "M..MMMM..M..",
  "M..MmMM..M..",
  "...M..M.....",
}, 202, 111, { t = L.timber.shade, M = L.timber.base, m = L.timber.shade, f = L.skin.base, e = L.timber.edge, n = L.skin.deep })
F.smoke(57, 44, 7, .5, 2) F.smoke(156, 43, 8, .8, 3)

-- the innkeeper in her apron with a coconut cup, at the foot of the stair
F.depth(3)
local _, ihx, ihy = F.gnome(132, 194, { hat = L.awnA, coat = L.awnB, arm = "out" })
cupAt(ihx, ihy + 1)
-- a slate board by the stair: a chalk cup and a pineapple
do
  local leg = line({ { 82, 198 }, { 86, 180 } }, 1):add(line({ { 96, 198 }, { 92, 180 } }, 1))
  local bd = rect(80, 178, 98, 192)
  rimOf(union(bd, leg), L.timber) part(leg, L.bamboo, { nopop = true, noshade = true })
  fill(bd, L.iron.deep) c:edgeIn(bd, L.bamboo.base)
  -- frame of bamboo, lashed corners
  px(80, 178, L.needle.base) px(98, 178, L.needle.base) px(80, 192, L.needle.base) px(98, 192, L.needle.base)
  for _, p in ipairs({ { 83, 182 }, { 84, 182 }, { 85, 182 }, { 86, 182 }, { 83, 183 }, { 84, 184 }, { 85, 184 }, { 86, 183 }, { 85, 181 }, { 86, 180 } }) do px(p[1], p[2], L.awnB.base) end
  for _, p in ipairs({ { 91, 185 }, { 92, 184 }, { 93, 185 }, { 92, 186 }, { 91, 187 }, { 93, 187 }, { 92, 188 }, { 91, 183 }, { 93, 183 }, { 92, 182 } }) do px(p[1], p[2], L.awnB.base) end
  hline(83, 95, 189, L.awnB.shade)
end

---------------------------------------------------------------- the gallows sign post and its tankard board
F.depth(3)
local SX0, SX1, SY0, SY1 = 202, 240, 128, 152
do
  local post = rect(194, 96, 197, 196)
  local arm = rect(194, 96, 246, 99)
  local brace = line({ { 198, 118 }, { 218, 100 } }, 2)
  local foot = rect(189, 192, 202, 198)
  F.shadowM(c:ellipse(204, 199, 12, 2))
  rimOf(union(post, arm, brace, foot), L.timber)
  part(post, L.timber, { nopop = true }) part(arm, L.timber, { nopop = true, noshade = true }) part(brace, L.bamboo, { nopop = true, noshade = true })
  post:each(function(x, y) if hash(x, y // 3, 37) < .15 then px(x, y, L.timber.shade) end end)
  part(foot, L.stone, { nopop = true }) hline(189, 202, 192, L.stone.hi) F.moss(foot, .3, 38) F.shine(foot, .1, 39)
  hline(194, 246, 96, L.timber.hi)
  -- rattan lashings where the arm and brace meet the post
  for _, p in ipairs({ { 194, 100 }, { 194, 102 }, { 196, 101 }, { 216, 100 }, { 218, 101 } }) do px(p[1], p[2], L.needle.base) end
  -- a carved parrot finial
  F.sprite({ ".RR.", "RWeR", ".RYk", ".RB.", "..B." }, 243, 90, { R = L.apple.base, W = L.awnB.hi, e = L.timber.edge, Y = L.gold.base, k = L.awnB.shade, B = "#4a8ad8" })
  -- a vine twining up the post with an orchid
  for y = 120, 190 do
    local vx = 195 + floor(sin(y / 4) * 2 + .5)
    px(vx, y, L.vine.shade)
    if y % 5 == 0 then local s = ((y // 5) % 2 == 0) and -1 or 1 px(vx + s, y, s < 0 and L.vine.hi or L.vine.base) px(vx + s, y + 1, L.vine.deep) end
    if y % 31 == 7 then px(vx - 1, y - 1, L.orchid.hi) px(vx, y - 1, L.orchid.base) px(vx, y - 2, L.orchid.hi) px(vx - 1, y, L.orchid.deep) end
  end
  -- rattan ropes
  for y = 100, SY0 - 1 do if y % 2 == 0 then px(SX0 + 3, y, L.needle.shade) px(SX1 - 3, y, L.needle.shade) else px(SX0 + 3, y, L.needle.hi) px(SX1 - 3, y, L.needle.hi) end end
  -- the board: teal frame, cream field, a big foaming tankard, little painted leaves in the corners
  local board = rect(SX0, SY0, SX1, SY1)
  rimOf(board, L.teal) part(board, L.teal, { nopop = true })
  local field = rect(SX0 + 3, SY0 + 3, SX1 - 3, SY1 - 3)
  fill(field, L.plaster.hi) field:each(function(x, y) if hash(x, y, 6) < .06 then px(x, y, L.plaster.base) end end)
  hline(SX0, SX1, SY0, L.teal.hi) vline(SX0, SY0, SY1, L.teal.hi)
  F.sprite({ "g.g", ".g.", "g.." }, SX0 + 4, SY1 - 7, { g = L.foliage.shade }, { rim = false })
  F.sprite({ "..h", "hhh", ".h." }, SX1 - 7, SY1 - 7, { h = L.helic.shade }, { rim = false })
  local tk = rect(213, 136, 227, 149)
  local hnd = c:ellipse(229, 142, 4, 4):cut(c:ellipse(229, 142, 2, 2)):cut(rect(222, 136, 227, 149))
  local foam = c:ellipse(220, 135, 9, 3):add(c:ellipse(216, 133, 3, 2)):add(c:ellipse(223, 132, 3, 2))
  c:rim(union(tk, hnd, foam), L.timber.edge)
  part(tk, L.glow) part(hnd, L.glow, { nopop = true })
  for x = 215, 225, 4 do vline(x, 139, 148, L.glow.shade) end
  hline(213, 227, 138, L.timber.base) hline(213, 227, 147, L.timber.base)
  part(foam, L.awnB, { nopop = true }) px(214, 132, L.awnB.hi) px(215, 131, L.awnB.hi) px(222, 131, L.awnB.hi)
  px(211, 137, L.awnB.base) px(210, 139, L.awnB.base)
end
-- QUIRK: an ocelot in a red gnome hat asleep on top of the board, tail hanging down over the tankard
do
  local by = SY0 - 1
  local O = ocelot
  local body = c:ellipse(226, by - 6, 13, 6):clip(rect(200, by - 14, 245, by))
  local head = c:ellipse(208, by - 7, 7, 6):clip(rect(196, by - 14, 220, by))
  local ears = poly{ { 211, by - 12 }, { 214, by - 16 }, { 216, by - 9 } }
  local tail = line({ { 238, by - 2 }, { 240, by + 4 }, { 237, by + 12 }, { 233, by + 15 } }, 3)
  local paws = c:ellipse(212, by - 1, 5, 1)
  local hat = poly{ { 200, by - 10 }, { 212, by - 11 }, { 207, by - 17 }, { 202, by - 22 }, { 197, by - 21 }, { 201, by - 17 } }
  local cat = union(body, head, ears, tail, paws, hat)
  c:rim(cat, L.timber.edge)
  part(union(body, tail), O, { nopop = true })
  -- rosettes: dark open rings along the flank, a pale belly
  body:each(function(x, y)
    if y >= by - 2 then px(x, y, O.hi) end
    if y <= by - 10 and hash(x, y, 3) < .4 then px(x, y, O.hi) end
  end)
  -- rosettes in chains along the flank: open dark rings with a tawny centre
  for _, r in ipairs({ { 217, by - 9 }, { 223, by - 8 }, { 229, by - 10 }, { 235, by - 8 }, { 219, by - 4 }, { 226, by - 4 }, { 232, by - 3 }, { 238, by - 5 } }) do
    local x, y = r[1], r[2]
    for _, d in ipairs({ { -1, -1 }, { 0, -1 }, { 1, -1 }, { -2, 0 }, { 2, 0 }, { -1, 1 }, { 1, 1 } }) do
      if body:has(x + d[1], y + d[2]) then px(x + d[1], y + d[2], O.edge) end
    end
    px(x, y, O.shade) px(x - 1, y, O.shade) px(x + 1, y, O.base) px(x, y + 1, O.shade)
  end
  for x = 214, 236, 3 do px(x, by - 12, O.edge) end -- dorsal stripe dashes
  tail:each(function(x, y) if (y - by) % 4 == 0 then px(x, y, O.edge) elseif (y - by) % 4 == 1 then px(x, y, O.deep) end end)
  part(head, O, { nopop = true }) part(ears, O, { nopop = true }) px(213, by - 13, "#f2a0a0")
  -- head stripes, white muzzle and paws
  px(206, by - 10, O.deep) px(209, by - 10, O.deep) px(203, by - 6, O.deep) px(213, by - 6, O.deep)
  fill(c:ellipse(208, by - 3, 4, 2), L.awnB.hi) fill(paws, L.awnB.hi) px(209, by - 1, O.deep) px(213, by - 1, O.deep) px(215, by - 2, O.deep)
  -- closed eyes: two smiling arcs
  px(203, by - 8, L.timber.edge) px(204, by - 7, L.timber.edge) px(205, by - 8, L.timber.edge)
  px(210, by - 8, L.timber.edge) px(211, by - 7, L.timber.edge) px(212, by - 8, L.timber.edge)
  fill(rect(207, by - 6, 208, by - 5), L.petal.base) px(207, by - 6, L.petal.hi)
  px(208, by - 4, L.timber.edge)
  hline(197, 200, by - 5, L.awnB.shade) hline(215, 218, by - 5, L.awnB.shade)
  -- the red gnome hat, slipped down over one ear, tip flopped left
  part(hat, L.awnA, { nopop = true })
  hat:each(function(x, y) if x < 203 and y > by - 20 then px(x, y, L.awnA.hi) end end)
  hline(200, 212, by - 10, L.awnA.deep) hline(201, 211, by - 11, L.awnA.shade)
  px(197, by - 21, L.awnB.hi) px(196, by - 21, L.awnB.base) px(197, by - 22, L.awnB.base) -- pompom
  zed(214, by - 24, 3) zed(220, by - 32, 4) zed(228, by - 41, 5)
end

---------------------------------------------------------------- beer garden (right): a big buttress fig, a palm, festoons, the table
F.depth(3)
do
  F.shadowM(c:ellipse(434, 196, 30, 3))
  F.palm(470, 192, 84, 18, { lean = -6 })
  local cm = F.canopy(428, 196, 104, L.foliage2, 53, { w = 40, noVines = true })
  -- a denser, darker fig crown: clumps of emerald and teal over the umbrella, vines and a strangler root
  local fig = F.rp("#86cc7c #48a05c #2c7e50 #1b5c46 #0e3a32")
  cm:add(F.crown(446, 140, 22, 15, L.foliage2, 12)):add(F.crown(406, 138, 20, 14, fig, 14))
  cm:add(F.crown(428, 112, 26, 18, fig, 13)):add(F.crown(456, 112, 14, 11, L.foliage2, 15)):add(F.crown(400, 118, 11, 9, L.foliage2, 16))
  -- leaf texture: little dark leaf notches and lit leaf tips scattered over the crown
  cm:each(function(x, y)
    local v = hash(x, y, 58)
    if v < .05 then px(x, y, fig.edge) elseif v > .97 then px(x, y, L.leaf.hi) end
  end)
  F.vines(cm, .14, 57, 28)
  -- figs on the branches
  for i = 0, 9 do local fx, fy = 400 + floor(hash(i, 1, 59) * 56), 126 + floor(hash(i, 2, 59) * 22) if cm:has(fx, fy) then px(fx, fy, L.apple.base) px(fx - 1, fy - 1, L.apple.hi) end end
  F.orchid(410, 156, L.orchid, 3)
end
-- paper-lantern festoons: sign arm -> pole across the road, pole -> the fig
local function festoon(x0, y0, x1, y1, sag, step, startI)
  local function ly(x) local t = (x - x0) / (x1 - x0) return floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + .5) end
  for x = x0, x1 do px(x, ly(x), L.timber.deep) end
  local i = startI or 0
  for x = x0 + 8, x1 - 6, step do
    i = i + 1
    plantern(x, ly(x), lanternCols[i % #lanternCols + 1], i % 3 == 0)
  end
  return ly
end
local fly
do
  local pole = rect(288, 116, 289, 196)
  rimOf(pole, L.timber) part(pole, L.bamboo, { nopop = true, noshade = true })
  for y = 120, 194, 7 do px(288, y, L.bamboo.deep) px(289, y, L.bamboo.deep) end
  F.sprite({ "h.h", "hhh", ".h." }, 287, 112, { h = L.helic.base }) -- a heliconia sprig tied to the pole top
  fly = festoon(289, 117, 404, 128, 3, 12, 0)
  festoon(246, 100, 288, 117, 4, 11, 2)
end
-- a spider monkey swinging under the festoon by tail and one arm
do
  local x = 344
  local y = fly(x)
  F.sprite({
    "t.......a...",
    ".t......a...",
    "..t....Ma...",
    "...t..MMM...",
    "....MMMMM...",
    "....MffMM...",
    "...MMefMM...",
    "...MMMMMMM..",
    "..MMMMMMM.MM",
    ".MM.MMMM...M",
    "M...MMMM....",
    "....M..M....",
    "....M...M...",
  }, x - 4, y + 1, { t = L.timber.shade, a = L.timber.base, M = L.timber.base, f = L.skin.base, e = L.timber.edge })
end
-- clay jars and bamboo kegs against the pole
jar(298, 207, 13) jar(312, 208, 12, F.rp("#a8d8cc #6aac9c #48867a #33625c #203e3e")) keg(305, 196, 5, 9)
F.moss(rect(292, 202, 318, 207), .08, 39)
-- long bamboo table with three gnomes behind it, raising coconut cups
do
  local g1 = { 338, 210, L.roof2, L.leaf, "up" }
  local g2 = { 366, 209, L.lav, L.teal, "up" }
  local g3 = { 394, 210, L.helic, L.awnA, "out" }
  for i, g in ipairs({ g1, g2, g3 }) do
    local _, hx, hy = F.gnome(g[1], g[2], { hat = g[3], coat = g[4], arm = g[5], flip = (i == 3), noShadow = true })
    cupAt(hx - 2, hy + 1)
  end
  for _, p in ipairs({ { 356, 186 }, { 352, 184 }, { 358, 182 } }) do px(p[1], p[2], L.awnB.hi) end
  local top = rect(322, 209, 414, 213)
  local legs = rect(328, 214, 330, 228):add(rect(406, 214, 408, 228)):add(line({ { 329, 222 }, { 407, 222 } }))
  local bench = rect(318, 224, 418, 226):add(rect(322, 227, 323, 231)):add(rect(413, 227, 414, 231))
  F.shadow(324, 414, 231, 10, 3)
  rimOf(union(top, legs, bench), L.timber)
  part(legs, L.bamboo, { nopop = true, noshade = true }) legs:each(function(x, y) if y % 6 == 0 then px(x, y, L.bamboo.deep) end end)
  part(bench, L.bamboo, { nopop = true }) F.bambooWall(bench, L.bamboo, 3, true, 91)
  part(top, L.board) F.bambooWall(top, L.board, 2, true, 92) hline(322, 414, 209, L.board.hi)
  -- a banana-leaf runner down the table
  for x = 330, 406 do if x % 9 ~= 0 then px(x, 210, L.leaf.base) px(x, 211, (x % 3 == 0) and L.leaf.shade or L.leaf.hi) end end
  cupAt(346, 209) cupAt(380, 209)
  -- a papaya cut open, a pineapple, a bowl of rambutans, a candle in a jar
  local pap = c:ellipse(362, 206, 5, 3) rimOf(pap, L.leaf) fill(pap, L.produce.base) fill(c:ellipse(362, 206, 3, 1), L.produce.hi)
  for k = -2, 2, 2 do px(362 + k, 206, L.timber.edge) end
  local pin = c:ellipse(396, 205, 3, 4) rimOf(pin, L.soil) fill(pin, L.gold.base)
  pin:each(function(x, y) if (x + y) % 2 == 0 then px(x, y, L.gold.shade) end end) px(395, 203, L.gold.hi)
  for _, d in ipairs({ { -2, -6 }, { -1, -7 }, { 0, -8 }, { 1, -7 }, { 2, -6 }, { 0, -6 } }) do px(396 + d[1], 205 + d[2], d[1] < 0 and L.fern.hi or L.fern.shade) end
  local bowl = c:ellipse(334, 208, 5, 1) fill(bowl, L.soil.base)
  for k = -3, 3, 2 do px(334 + k, 206, L.apple.base) px(334 + k + 1, 206, L.apple.shade) px(334 + k, 205, L.apple.hi) end
  fill(rect(371, 204, 373, 208), L.awnB.hi) px(372, 203, L.glow.hi) px(372, 202, L.glow.base)
end
-- the waiter crossing the road with a tray of coconut cups
F.depth(3)
do
  local _, hx, hy = F.gnome(268, 232, { hat = L.teal, coat = L.awnA, arm = "up", flip = true })
  local tray = rect(hx - 9, hy - 1, hx + 5, hy)
  rimOf(tray, L.timber) part(tray, L.board, { nopop = true, noshade = true })
  cupAt(hx - 9, hy - 1) cupAt(hx - 4, hy - 1) cupAt(hx + 1, hy - 1)
end

---------------------------------------------------------------- foreground left: hollow-log trough, hitching rail, firewood, keg roller
F.depth(3)
do
  local rail = rect(22, 212, 104, 214):add(rect(26, 212, 28, 228)):add(rect(98, 212, 100, 228))
  rimOf(rail, L.timber) part(rail, L.bamboo, { nopop = true, noshade = true }) hline(22, 104, 212, L.bamboo.hi)
  for x = 30, 96, 9 do px(x, 213, L.bamboo.deep) end
  fill(rect(40, 214, 41, 218), L.needle.shade) -- a tied rope
  -- a hollowed mahogany log on two stones, filled by a bamboo spout
  F.shadow(32, 96, 234, 8, 3)
  local chocks = F.rock(42, 234, 5, 5):add(F.rock(86, 234, 5, 5))
  local t = rect(32, 219, 96, 230)
  rimOf(t, L.redbark) part(t, L.redbark)
  F.logs(t, L.redbark, 219, 4)
  t:each(function(x, y) if hash(x // 4, y, 40) < .12 then px(x, y, L.redbark.deep) end end)
  fill(rect(34, 219, 94, 219), L.board.base)
  local w = rect(35, 220, 93, 222)
  fill(w, L.water.base) hline(35, 93, 220, L.water.hi) for x = 38, 92, 9 do px(x, 221, L.water.hi) px(x + 1, 221, L.wet) end
  hline(34, 94, 223, L.board.shade)
  F.logEnd(96, 225, 5, L.redbark)
  fill(c:ellipse(96, 224, 2, 2), L.water.shade) px(95, 223, L.water.hi)
  F.moss(t, .12, 41) F.shine(t, .06, 42)
  -- the bamboo spout from the left, a trickle into the trough
  local sp = poly{ { 14, 205 }, { 38, 213 }, { 38, 215 }, { 14, 207 } }
  rimOf(sp, L.bamboo) part(sp, L.bamboo, { nopop = true })
  for y = 216, 219 do px(38, y, L.water.hi) px(39, y, (y % 2 == 0) and L.wet or L.water.base) end
  px(36, 220, L.wet) px(41, 220, L.wet)
end
do -- firewood stack under a little palm lean-to by the stair
  local stackM = rect(146, 196, 184, 212)
  F.shadow(146, 186, 213, 6, 3)
  rimOf(stackM, L.timber) fill(stackM, L.timber.shade)
  for row = 0, 2 do for k = 0, 6 do
    local cx, cy = 149 + k * 6 + (row % 2) * 3, 199 + row * 5
    if cx <= 182 then
      local tr = (hash(k, row, 8) < .3) and L.redbark or L.board
      local lg = c:ellipse(cx, cy, 2.5, 2.5)
      fill(lg, tr.hi) px(cx, cy, tr.shade) px(cx + 1, cy, tr.base)
      lg:edge():each(function(x, y) px(x, y, (x > cx or y > cy) and L.timber.base or tr.base) end)
    end
  end end
  local lean = poly{ { 142, 196 }, { 188, 191 }, { 188, 195 }, { 142, 199 } }
  rimOf(lean, L.roof) part(lean, L.roof, { nopop = true }) F.palmThatch(lean, L.roof, 191, 9999, 93)
  for x = 142, 188, 2 do px(x, 199 - floor((x - 142) / 46 * 4) + 1, L.roof.deep) end
  -- a machete in a block
  line({ { 186, 212 }, { 181, 203 } }):each(function(x, y) px(x, y, L.timber.base) end)
  local bl = poly{ { 180, 203 }, { 182, 202 }, { 176, 194 }, { 175, 195 } } c:rim(bl, L.iron.edge) fill(bl, L.iron.base) px(176, 195, L.iron.hi)
end
-- a gnome rolling a bamboo-hooped barrel toward the inn
do
  local _, hx, hy = F.gnome(176, 252, { hat = L.roof2, coat = L.teal, arm = "out", flip = true })
  local b = c:rrect(152, 240, 166, 254, 4)
  F.shadowM(c:ellipse(160, 255, 9, 1))
  rimOf(b, L.timber) part(b, L.timber)
  vline(155, 241, 253, L.bamboo.shade) vline(163, 241, 253, L.bamboo.shade) vline(156, 241, 253, L.bamboo.hi) hline(153, 165, 246, L.timber.hi)
  for _, p in ipairs({ { 146, 250 }, { 144, 246 }, { 143, 253 } }) do px(p[1], p[2], L.litter.hi) end
end
-- crate of green bottles, rice sacks, coconuts, bottom left
do
  F.crate(40, 256, 26, 12)
  for k = 0, 5 do
    local bx = 43 + k * 4
    local b = rect(bx, 238, bx + 2, 244):add(rect(bx + 1, 235, bx + 1, 237))
    c:rim(b, L.timber.edge) fill(b, L.leaf.shade) px(bx, 239, L.leaf.hi) px(bx + 1, 235, L.produce.base)
  end
  sack(86, 258, 7) sack(100, 262, 6, L.board)
  F.moss(F.rock(124, 262, 8, 6), .35, 43)
  coconut(112, 258) coconut(116, 260, true) coconut(30, 256, true)
  F.bigLeaf(4, 246, 22, -pi * .22, L.foliage, 31, 8, { heart = true, droop = .2, stem = { 12, 268 } })
  F.bigLeaf(22, 232, 18, -pi * .6, L.leaf, 32, 7, { heart = true, droop = .15, stem = { 18, 262 } })
  F.fern(24, 250, 8) F.fern(70, 264, 6) F.fern(132, 248, 6)
  F.mushroom(134, 258, L.produce, true) F.mushroom(138, 260, L.produce)
end
-- a clay pot of heliconias and orchids by the road
do
  local pot = c:rrect(210, 228, 228, 240, 3)
  F.shadowM(c:ellipse(222, 241, 10, 1))
  F.heliconia(219, 228, 20, 61)
  rimOf(pot, clay) part(pot, clay) hline(210, 228, 231, clay.deep) for x = 212, 226, 3 do px(x, 232, L.gold.base) end
  F.orchid(212, 226, L.orchid, 2, true) F.orchid(224, 226, L.petal, 2)
end

-- red junglefowl pecking at crumbs dropped from the table
F.depth(3)
F.hen(318, 252, L.produce) F.hen(342, 258, L.helic, true) F.hen(360, 246, L.awnB, true)
for _, g in ipairs({ { 326, 254 }, { 332, 256 }, { 336, 251 }, { 350, 255 }, { 329, 250 } }) do px(g[1], g[2], L.gold.hi) end
-- a spare cart wheel leaning on the jars
do local w = c:ellipse(290, 214, 7, 8) rimOf(w, L.timber) part(w, L.timber, { nopop = true })
  fill(c:ellipse(290, 214, 4, 5), L.ground.shade) vline(290, 207, 221, L.timber.deep) hline(284, 296, 214, L.timber.deep) fill(rect(289, 213, 291, 215), L.iron.base)
  F.vine(286, 207, 7, 3) end
-- understorey around the garden (clear of the compass corner)
F.heliconia(452, 226, 22, 62)
F.treeFern(440, 226, 24, 63)
F.bamboo(468, 228, 46, 3, 64)
for _, f in ipairs({ { 304, 262, 8 }, { 290, 250, 6 }, { 374, 262, 7 }, { 428, 224, 6 }, { 284, 236, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.mushroom(300, 240, L.apple, true) F.mushroom(304, 242, L.apple) F.mushroom(368, 252, L.produce, true)
F.orchid(316, 236, L.orchid, 2) F.heliconia(330, 266, 16, 65)
-- a capybara tied to the hitching rail, chewing the rope
F.depth(3)
F.sprite({
  "..ee................",
  ".eBBBBhhhhhhhhh.....",
  "BBkBBBBBBBBBBBBBh...",
  "BBBBBBBBBBBBBBBBBh..",
  "nBBBBBBBBBBBBBBBBB..",
  ".dBBdBBBBBBBBBBBBB..",
  "..dd..dBBBBBBBBBBd..",
  "......dBB.....dBBd..",
  "......dd......dd....",
  "......ff......ff....",
}, 106, 217, { e = capy.shade, h = capy.hi, B = capy.base, d = capy.shade, k = L.timber.edge, n = capy.deep, f = capy.deep })
for x = 100, 106 do px(x, 218 + (x - 100) // 3, L.needle.deep) end
F.shadowM(c:ellipse(118, 228, 10, 1))
-- a little yellow bird riding on the capybara
F.sprite({ ".yy.", "yYey", ".yy." }, 116, 213, { y = L.gold.base, Y = L.gold.hi, e = L.timber.edge })
-- a coati asleep under the table between the legs, ringed tail curled
F.sprite({
  "..........tT....",
  "...........Tt...",
  "............tT..",
  "............Tt..",
  ".............tT.",
  "..bb.........Tt.",
  ".bBBbbb.....tT..",
  "wwBkkBBBBBBBBBb.",
  "wnBBBBBBBBBBBBBb",
  ".dddBBbbBBBBbbB.",
  "...ddd..ddddd...",
}, 364, 212, { b = L.litter.shade, B = L.litter.base, d = L.litter.deep, k = L.timber.edge, w = L.awnB.hi, n = L.timber.edge, t = L.timber.edge, T = L.awnB.hi })
-- blue morpho butterflies
for _, b in ipairs({ { 182, 222 }, { 318, 186 }, { 236, 168 } }) do
  F.sprite({ "BB.BB", "bBkBb", ".b.b." }, b[1], b[2], { B = "#5aa8f0", b = "#2c62b4", k = L.timber.edge }, { rim = false })
end

F.depth(0)
F.birds({ { 330, 52, 2, "#2e7a46" }, { 342, 46, 1, "#2e7a46" }, { 300, 58, 1, "#b03a36" }, { 380, 78, 2, "#2e7a46" } })
F.finish()
