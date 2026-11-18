-- orchard.lua : "Orchard" stop look, RAINFOREST (rainforest_canopy), 480x270 gate view.
-- Same composition as the Maplewold orchard (art-2701-batch3/stops/opus3/orchard.lua) and the forest orchard,
-- re-cast as a tropical fruit grove cut into the jungle: rows of fruit trees in four kinds (dark glossy mango
-- domes with bronze new leaves and dangling fruit, tall slim papayas with leaf umbrellas and fruit hugging the
-- trunk, low cacao trees with yellow / red / purple pods on their trunks, torn-leaf banana plants with bunches and
-- purple bells), coconut palms standing in as shade, mulched rows of fallen banana leaves between green rides.
-- Road's end: a great old mango tree on buttress roots with epiphytes, fruit bats, parrots and a rattan swing (a
-- little gnome). Back right: a bamboo cacao-drying house and a raised drying deck of beans being raked.
-- Left hero: a bamboo screw press under a palm-thatch hood, a tub of mangoes, orange juice running into a clay
-- pot, a hummingbird at the spout, a turning gnome, mango and papaya heaps, rattan baskets, a bamboo table with a
-- calabash, a pineapple and a cut papaya, big clay jars. Right hero: a picker on a bamboo ladder at a big front
-- mango tree (blue-and-gold macaws in it), baskets and crates of pods by the road, a coati with a banana, a gnome
-- carrying a banana bunch, a bamboo barrow of papayas. A baby tapir at the windfalls, a parakeet by the road.
-- Quirk (kept): the hedgehog becomes a streaked tenrec trundling off with a mango and a red gnome hat on its spines.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-rainforest-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "orchard", out = DIR, farTrees = { 24, 52, 100, 380, 410, 440 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi

-- fruit and leaf ramps (hi base shade deep edge)
local MANGO = F.rp("#ffe680 #f6b234 #e4762c #b8462c #742c22")  -- ripe mango, yellow to orange
local MANGOG = F.rp("#e0ec88 #b2cc52 #84a63e #5a7a32 #364c22") -- unripe mango / green papaya
local PAPF = F.rp("#ffd88a #f8a040 #dc6c2c #a04a26 #62301c")   -- ripe papaya
local CACY = F.rp("#fff29a #f2c83e #c8962e #8c6424 #563c18")   -- cacao pods: yellow
local CACR = F.rp("#f6907c #cc4c4a #9a3242 #68223a #3e1428")   -- red
local CACP = F.rp("#d49ac0 #9a5a96 #703e74 #4c2a52 #2e1a34")   -- purple
local BAN = F.rp("#fff4a0 #f4dc52 #d0ac34 #92762a #5a4820")    -- ripe banana
local BANG = F.rp("#d8ec7a #a8cc4a #78a43a #507a30 #30501e")   -- green banana
local BELL = F.rp("#d898b4 #a85a84 #7a3e64 #542a48 #34182e")   -- banana bell
local MLEAF = F.rp("#a4d67e #58a456 #347c4a #205a40 #10382e")  -- glossy mango green
local MLEAF2 = F.rp("#b6dc7c #6cb050 #448a44 #2c663c #183f2c") -- lighter mango green
local MFLUSH = F.rp("#f4bc90 #d07c5c #a2544a #6e383c #42222a") -- bronze new mango leaves
local CLEAF = F.rp("#a6dc9a #5eae7a #3a8a66 #26664e #143e34")  -- cacao, blue-green
local DEADL = F.rp("#ecc480 #c89a54 #9c7040 #6e4c30 #44301e")  -- dead banana leaf
local RATTAN = F.rp("#f0d494 #d0aa62 #a8803e #785a2e #4a3620")
local CLAY = F.rp("#f0a878 #d0784a #a8563a #74382c #48221e")
local GOURD = F.rp("#f2e2a0 #d4b864 #aa8c44 #7a6232 #4c3c22")
local BEAN = F.rp("#c88a6a #9a5a46 #74403a #52302e #34201e")   -- fermented cacao beans
local INK = "#2a2226"
local PTRUNK = F.rp("#dce0b2 #b4bc8c #8c9670 #667056 #404a38") -- papaya trunk, grey-green

---------------------------------------------------------------- fruit
-- a fruit with its stalk on top at (ax, ay): big = 4x5 inked sprite, mid = 2x3, small = 1-2 px
local function fruitDot(ax, ay, s, fr, blush)
  if s >= 1.6 then
    F.sprite({ ".Hb.", "Hbbs", "bbbs", "sbsd", ".dd." }, ax - 1, ay, { H = blush or fr.hi, b = fr.base, s = fr.shade, d = fr.deep }, { rimCol = fr.edge })
  elseif s > 1.05 then
    px(ax, ay, blush or fr.hi) px(ax + 1, ay, fr.base) px(ax, ay + 1, fr.base) px(ax + 1, ay + 1, fr.shade) px(ax, ay + 2, fr.shade) px(ax + 1, ay + 2, fr.deep)
  else
    px(ax, ay, blush or fr.base) if s > .7 then px(ax, ay + 1, fr.shade) end
  end
end
-- a cacao pod: ridged, pointed, hanging from (ax, ay)
local function pod(ax, ay, s, fr)
  if s >= 1.1 then
    F.sprite({ ".Hb.", "Hbbs", "bHbs", "bbsd", "Hbsd", ".sd.", "..d." }, ax - 1, ay, { H = fr.hi, b = fr.base, s = fr.shade, d = fr.deep }, { rimCol = fr.edge })
  elseif s > .7 then
    px(ax, ay, fr.hi) px(ax + 1, ay, fr.base) px(ax, ay + 1, fr.base) px(ax + 1, ay + 1, fr.shade) px(ax, ay + 2, fr.shade)
  else
    px(ax, ay, fr.base) px(ax, ay + 1, fr.shade)
  end
end
local function crownBottom(m, ax, y0, y1) local by for yy = y0, y1 do if m:has(ax, yy) then by = yy end end return by end
local function crownTop(m, ax, y0, y1) for yy = y0, y1 do if m:has(ax, yy) then return yy end end end
-- mango flush: limp tassels of bronze-pink new leaves hanging from the crown top and spilling down its lit side
local function flush(m, x0, x1, y0, y1, n, seed, big)
  for i = 1, n do
    local ax = floor(x0 + hash(i, seed, 21) * (x1 - x0))
    local ty = crownTop(m, ax, y0, y1)
    if ty then
      local ay = ty + 1 + floor(hash(i, seed, 22) ^ 2 * (big and 10 or 4))
      if m:has(ax, ay + 3) and m:has(ax + 1, ay + 3) then
        local lit = hash(i, seed, 23) < .6
        px(ax, ay, lit and MFLUSH.hi or MFLUSH.base) px(ax + 1, ay, MFLUSH.base)
        px(ax, ay + 1, lit and MFLUSH.base or MFLUSH.shade) px(ax + 1, ay + 1, MFLUSH.shade)
        px(ax, ay + 2, MFLUSH.shade) px(ax + 1, ay + 3, MFLUSH.deep)
        if big then px(ax - 1, ay + 1, MFLUSH.hi) px(ax - 1, ay + 2, MFLUSH.base) px(ax - 1, ay + 3, MFLUSH.deep) end
      end
    end
  end
end

---------------------------------------------------------------- the four fruit trees
-- 1 mango: short thick trunk, a dark glossy dome, bronze flushes of new leaves, mangoes dangling on long stalks
local function mangoTree(x, yb, s, seed)
  local lr = (seed % 3 == 0) and MLEAF2 or MLEAF
  local lean = (hash(seed, 1, 9) - .5) * 4 * s
  local w2 = math.max(1, floor(2 * s))
  local tr = poly{ { x - 3 * s, yb }, { x - 2 * s + lean, yb - 11 * s }, { x + 2 * s + lean, yb - 11 * s }, { x + 3 * s, yb } }
  local brs = line({ { x + lean, yb - 9 * s }, { x - 10 * s, yb - 17 * s } }, w2):add(line({ { x + lean, yb - 9 * s }, { x + 10 * s, yb - 18 * s } }, w2))
  F.shadowM(c:ellipse(x + 4 * s, yb, 16 * s, 2 * s))
  rimOf(union(tr, brs), L.timber) part(tr, L.timber, { nopop = true }) part(brs, L.timber, { nopop = true, noshade = true })
  if s > .9 then tr:each(function(xx, yy)
    if hash(xx, yy // 4, seed) < .22 and tr:has(xx - 1, yy) then px(xx, yy, L.timber.deep)
    elseif hash(xx // 2, yy // 2, seed + 3) < .1 then px(xx, yy, L.moss.base) end end) end
  local cm = HP.mask()
  cm:add(F.crown(x - 10 * s, yb - 19 * s, 9 * s, 6 * s, lr, seed))
  cm:add(F.crown(x + 10 * s, yb - 20 * s, 9 * s, 6 * s, lr, seed + 1))
  if s > 1.6 then -- a big tree: a bumpier skyline of extra lobes
    cm:add(F.crown(x - 7 * s, yb - 31 * s, 7 * s, 5 * s, lr, seed + 3))
    cm:add(F.crown(x + 9 * s, yb - 30 * s, 7 * s, 5 * s, lr, seed + 4))
  end
  cm:add(F.crown(x + lean, yb - 26 * s, 14 * s, 9 * s, lr, seed + 2))
  if s > .6 then flush(cm, x - 20 * s, x + 18 * s, floor(yb - 40 * s), yb, floor(4 * s) + 1, seed, s > 1.6) end
  local n = floor((s > 1.6 and 5 or 8) * s * s) + 4
  for i = 1, n do
    local ax = floor(x + (hash(i, seed, 1) - .5) * 34 * s)
    local by = crownBottom(cm, ax, floor(yb - 40 * s), yb)
    if by then
      local fr = hash(i, seed, 3) < .3 and MANGOG or MANGO
      local bl = (fr == MANGO and hash(i, seed, 4) < .45) and L.apple.base or nil
      if hash(i, seed, 2) < .55 then
        local sl = 1 + floor(s * 2.4 * hash(i, seed, 5) ^ 1.5)
        vline(ax, by + 1, by + sl, L.vine.deep)
        fruitDot(ax, by + sl + 1, s, fr, bl)
      else
        local ay = floor(by - 3 - hash(i, seed, 6) * 8 * s)
        if cm:has(ax, ay) and cm:has(ax, ay - 2) then fruitDot(ax, ay, math.min(s, 1.5), fr, bl) end
      end
    end
  end
  return cm
end
-- 2 papaya: a tall slim pale trunk ringed with leaf scars, an umbrella of lobed leaves on long stalks,
-- a ring of green and orange fruit hugging the trunk under the leaves
local function papayaTree(x, yb, s, seed)
  local h = floor(30 * s) + 4
  local lean = (hash(seed, 1, 9) - .5) * 5 * s
  local tx, ty = floor(x + lean + .5), yb - h
  local tw = s >= 1.6 and 2 or (s >= .8 and 1 or 0)
  local trunk = HP.mask()
  for y = ty, yb do
    local t = (yb - y) / h
    local cx = floor(x + lean * t + .5)
    for xx = cx, cx + tw do trunk:set(xx, y) end
    if y > yb - 2 then trunk:set(cx - 1, y) trunk:set(cx + tw + 1, y) end
  end
  F.shadowM(c:ellipse(x + 3 * s, yb, 7 * s + 1, 1 + floor(s * .5)))
  rimOf(trunk, PTRUNK)
  trunk:each(function(xx, yy)
    local h2 = trunk:has(xx - 1, yy) and PTRUNK.base or PTRUNK.hi
    if tw > 0 and not trunk:has(xx + 1, yy) then h2 = PTRUNK.shade end
    if (yy - ty) % 3 == 0 and yy < yb - h * .15 then h2 = PTRUNK.deep end
    if yy > yb - h * .3 and hash(xx, yy // 2, seed) < .2 then h2 = L.moss.shade end
    px(xx, yy, h2)
  end)
  -- leaves: long stalks radiating up and out from the crown, a lobed blade at each end; one dead leaf hanging
  local n = s > .8 and 8 or 6
  local ends = {}
  for i = 1, n do
    local a = -pi - .3 + (i - .5) / n * (pi + .6) + (hash(i, seed, 3) - .5) * .3
    local ln = (8 + 4 * hash(i, seed, 4)) * s + 2
    local ex, ey = tx + cos(a) * ln, ty + sin(a) * ln * .75 + ln * .3
    ends[#ends + 1] = { floor(ex + .5), floor(ey + .5), a }
    line({ { tx, ty }, { ex, ey } }):each(function(xx, yy) px(xx, yy, (xx < tx) and L.vine.base or L.vine.shade) end)
  end
  if s > .7 then
    local dl = line({ { tx + 1, ty + 1 }, { tx + 4 * s, ty + 6 * s } })
    dl:each(function(xx, yy) px(xx, yy, DEADL.shade) end)
    fill(c:ellipse(floor(tx + 4 * s), floor(ty + 8 * s), math.max(1, floor(s * 1.5)), math.max(1, floor(s * 2))), DEADL.base)
  end
  local pl = (seed % 2 == 0) and L.leaf or L.birchLeaf
  table.sort(ends, function(a, b) return a[2] < b[2] end)
  for i, e in ipairs(ends) do
    local rx, ry = 3.2 * s + 1.5, 1.6 * s + 1
    F.crown(e[1], e[2], rx, ry, pl, seed * 5 + i)
    if s > .7 then -- finger lobes round the blade
      for k = -2, 2 do
        local a = e[3] + k * .55
        px(floor(e[1] + cos(a) * (rx + 1) + .5), floor(e[2] + sin(a) * (ry + 1) + .5), k < 0 and pl.base or pl.shade)
      end
    end
  end
  -- the fruit ring
  local nf = 3 + floor(4 * s)
  for i = 1, nf do
    local side = (i % 2 == 0) and -1 or 1
    local fx = tx + side * (tw + 1 + floor(hash(i, seed, 7) * 2 * s)) - (side < 0 and floor(s) or 0)
    local fy = ty + 2 + floor(hash(i, seed, 8) * 5 * s)
    local fr = hash(i, seed, 9) < .4 and PAPF or MANGOG
    if s >= 1.6 then
      F.sprite({ ".Hb.", "Hbbs", "bbbs", "bbsd", "sbsd", ".dd." }, fx - 1, fy, { H = fr.hi, b = fr.base, s = fr.shade, d = fr.deep }, { rimCol = fr.edge })
    else fruitDot(fx, fy, s * 1.1, fr) end
  end
  return trunk
end
-- 3 cacao: a low crooked tree with three limbs, a blue-green crown with drooping pink new leaves, and pods
-- (yellow, red, purple) growing straight out of the trunk and the big limbs; tiny flowers on the bark
local function cacaoTree(x, yb, s, seed)
  local lean = (hash(seed, 1, 9) - .5) * 4 * s
  local w2 = math.max(1, floor(1.6 * s))
  local tr = poly{ { x - 2 * s, yb }, { x - 1 * s + lean, yb - 12 * s }, { x + 1 * s + lean, yb - 12 * s }, { x + 2 * s, yb } }
  local l1 = { { x + lean, yb - 11 * s }, { x - 9 * s, yb - 18 * s } }
  local l2 = { { x + lean, yb - 11 * s }, { x + 8 * s, yb - 19 * s } }
  local brs = line(l1, w2):add(line(l2, w2)):add(line({ { x + lean, yb - 12 * s }, { x + lean + 1, yb - 21 * s } }, w2))
  F.shadowM(c:ellipse(x + 3 * s, yb, 12 * s, 2 * s))
  rimOf(union(tr, brs), L.palmTrunk) part(tr, L.palmTrunk, { nopop = true }) part(brs, L.palmTrunk, { nopop = true, noshade = true })
  if s > .8 then tr:each(function(xx, yy) if hash(xx // 2, yy // 2, seed) < .2 then px(xx, yy, hash(xx, yy, seed) < .5 and L.birch.base or L.moss.base) end end) end
  local cm = HP.mask()
  cm:add(F.crown(x - 9 * s, yb - 21 * s, 8 * s, 5 * s, CLEAF, seed))
  cm:add(F.crown(x + 9 * s, yb - 22 * s, 8 * s, 5 * s, CLEAF, seed + 1))
  cm:add(F.crown(x + lean, yb - 27 * s, 9 * s, 6 * s, CLEAF, seed + 2))
  -- limp pink-red new leaves hanging from the crown edge
  if s > .55 then
    for i = 1, floor(3 * s) + 1 do
      local ax = floor(x + (hash(i, seed, 11) - .5) * 26 * s)
      local by = crownBottom(cm, ax, floor(yb - 36 * s), yb)
      if by then for k = 0, floor(1 + s * 1.5) do px(ax, by - 1 + k, k == 0 and CACR.hi or CACR.base) end px(ax + 1, by, CACR.shade) end
    end
  end
  -- pods on the trunk and limbs (cauliflory)
  local spots = {}
  for k = 0, 2 do spots[#spots + 1] = { x + lean * (.3 + k * .3) + (k % 2 == 0 and -1 or 1) * (s + 1), yb - (3 + k * 3) * s } end
  for _, lb in ipairs({ l1, l2 }) do for _, t in ipairs({ .45, .75 }) do spots[#spots + 1] = { lb[1][1] + (lb[2][1] - lb[1][1]) * t, lb[1][2] + (lb[2][2] - lb[1][2]) * t + 1 } end end
  for i, sp in ipairs(spots) do
    if hash(i, seed, 12) < .8 then
      local fr = ({ CACY, CACR, CACP, CACY })[1 + floor(hash(i, seed, 13) * 4)]
      pod(floor(sp[1]), floor(sp[2]), s, fr)
    end
  end
  if s > .8 then for i = 1, 4 do px(floor(x + (hash(i, seed, 14) - .5) * 3 * s), floor(yb - 2 - hash(i, seed, 15) * 9 * s), L.petal.hi) end end
  return cm
end
-- 4 banana plant: a sheathed pseudostem, broad torn leaves, a dead leaf hanging, a fruit bunch and a purple bell
local function bananaPlant(x, yb, s, seed)
  local h = floor(28 * s) + 4
  local sh = floor(h * .45)
  local stem = poly{ { x - 2 * s - 1, yb }, { x + 2 * s + 1, yb }, { x + 1 * s, yb - sh }, { x - 1 * s, yb - sh } }
  F.shadowM(c:ellipse(x + 3 * s, yb, 10 * s + 1, 1 + floor(s)))
  rimOf(stem, L.vine) part(stem, L.vine, { nopop = true })
  stem:each(function(xx, yy)
    if xx < x then px(xx, yy, L.vine.hi) end
    if hash(xx, yy // 3, seed) < .18 then px(xx, yy, DEADL.shade) elseif hash(xx, yy // 4, seed + 1) < .12 then px(xx, yy, L.litter.shade) end
  end)
  local ty = yb - sh
  if s > .7 then F.bigLeaf(x - 1, ty + 1, floor(h * .3), pi * .58, DEADL, seed, math.max(2, floor(h * .06)), { torn = true }) end
  local lens = { .8, .85, .72, .62 }
  local wd = function(k) return math.max(2, floor(h * lens[k] * .22)) end
  F.bigLeaf(x, ty, math.max(6, floor(h * lens[1])), -pi * .9, L.leaf, seed + 1, wd(1), { torn = true, droop = .5 })
  F.bigLeaf(x, ty, math.max(6, floor(h * lens[2])), -pi * .1, (seed % 2 == 0) and L.foliage or L.vine, seed + 2, wd(2), { torn = true, droop = .55 })
  F.bigLeaf(x, ty, math.max(5, floor(h * lens[3])), -pi * .64, L.leaf, seed + 3, wd(3), { torn = true, droop = .15 })
  F.bigLeaf(x, ty, math.max(5, floor(h * lens[4])), -pi * .38, L.birchLeaf, seed + 4, wd(4), { torn = true, droop = .25 })
  -- the bunch: hands of fingers stacked down a curving stalk, the bell at the tip
  local fr = (seed % 3 == 0) and BAN or BANG
  local bx, by = x + floor(2 * s) + 1, ty + 2
  if s >= .9 then
    local rows = floor(2 + s * 2)
    local m = HP.mask()
    for k = 0, rows - 1 do m:add(rect(bx - (k < 2 and 0 or 1), by + k * 2, bx + floor(3.5 * s) - (k // 2), by + k * 2 + 1)) end
    rimOf(m, fr)
    m:each(function(xx, yy) local k = (yy - by) % 2 px(xx, yy, k == 0 and (xx == bx and fr.hi or fr.base) or fr.shade) end)
    m:each(function(xx, yy) if (xx - bx) % 2 == 1 and (yy - by) % 2 == 1 then px(xx, yy, fr.deep) end end)
    local bly = by + rows * 2
    vline(bx + 1, bly, bly + 1, L.vine.deep)
    F.sprite({ ".l.", "lLl", "lLl", ".l." }, bx, bly + 2, { l = BELL.shade, L = BELL.base })
  else
    px(bx, by, fr.base) px(bx, by + 1, fr.shade) px(bx + 1, by, fr.shade) px(bx, by + 2, BELL.base)
  end
end
local function fruitTree(x, yb, s, seed, kind)
  if kind == 1 then return mangoTree(x, yb, s, seed)
  elseif kind == 2 then return papayaTree(x, yb, s, seed)
  elseif kind == 3 then return cacaoTree(x, yb, s, seed)
  else return bananaPlant(x, yb, s, seed) end
end

---------------------------------------------------------------- basket, jar helpers
local function basket(x, yb, w, h, fr, kind)
  local m = poly{ { x - w, yb - h }, { x + w, yb - h }, { x + w - 2, yb }, { x - w + 2, yb } }
  local handle = c:ellipse(x, yb - h, w - 2, h - 1):cut(c:ellipse(x, yb - h, w - 4, h - 3)):clip(rect(x - w, yb - 2 * h, x + w, yb - h - 1))
  rimOf(union(m, handle), RATTAN) part(handle, RATTAN, { nopop = true, noshade = true })
  part(m, RATTAN, { nopop = true })
  m:each(function(xx, yy) local k = (xx + (yy // 2) * 2) % 4 if k == 0 then px(xx, yy, RATTAN.hi) elseif k == 2 then px(xx, yy, RATTAN.shade) end end)
  hline(x - w + 1, x + w - 1, yb - h, RATTAN.deep)
  for xx = x - w + 1, x + w - 2, 2 do
    local f = fr or MANGO
    if kind == "pods" then f = ({ CACY, CACR, CACP })[1 + (xx // 2) % 3] end
    px(xx, yb - h - 1, f.base) px(xx + 1, yb - h - 1, f.shade) px(xx, yb - h - 2, f.hi) px(xx + 1, yb - h - 2, f.base)
  end
  return m
end
local function jar(x, yb, hh, r)
  local body = c:ellipse(x, yb - floor(hh * .45), 6, floor(hh * .45))
  local neck = rect(x - 3, yb - hh, x + 3, yb - hh + 2)
  local lip = rect(x - 4, yb - hh - 1, x + 4, yb - hh)
  local m = union(body, neck, lip)
  rimOf(m, r) part(body, r) part(neck, r, { nopop = true }) part(lip, r, { nopop = true, noshade = true })
  hline(x - 3, x + 3, yb - hh - 1, r.hi) px(x - 2, yb - hh, L.soil.deep) px(x + 2, yb - hh, L.soil.deep)
  -- a rattan carrying sling and a painted band
  local band = yb - floor(hh * .55)
  body:each(function(xx, yy) if yy == band then px(xx, yy, (xx % 2 == 0) and RATTAN.base or RATTAN.deep) elseif yy == band + 2 then px(xx, yy, r.deep) end end)
  F.shine(body, .1, x)
  return m
end

---------------------------------------------------------------- the rows (back to front)
-- kinds per row {inner left, inner right, outer left, outer right}: 1 mango, 2 papaya, 3 cacao, 4 banana, 0 palm
local KINDS = { { 1, 4, 3, 0 }, { 4, 2, 1, 3 }, { 2, 0, 4, 1 }, { 3, 4, 1, 2 }, { 4, 2, 0, 3 }, { 2, 4, 3, 1 } }
local rows = {}
for k = 0, 5 do
  local t = k / 5
  local y = floor(122 + t * t * 70)
  local s = .45 + t * t * .75
  local kk = KINDS[k + 1]
  rows[#rows + 1] = { F.xl(y) - 18 - 60 * t, y, s, kk[1] }
  rows[#rows + 1] = { F.xr(y) + 18 + 60 * t, y, s, kk[2] }
  rows[#rows + 1] = { F.xl(y) - 70 - 110 * t, y + 2, s, kk[3] }
  rows[#rows + 1] = { F.xr(y) + 70 + 110 * t, y + 2, s, kk[4] }
end
-- green rides between the tree rows (a little red earth path worn down the middle of the near ones)
for y = 116, 229 do
  local d = y - 108
  local band = floor(60 / d * 6)
  if band % 2 == 0 then
    for x = 18, 461 do
      if not F.roadM:has(x, y) then
        local v = hash(x // 3, y, 91)
        if v < .5 then px(x, y, L.mossGround.base) elseif v < .66 then px(x, y, L.mossGround.hi) elseif v < .7 then px(x, y, L.fern.shade) end
      end
    end
  end
end
-- under each row a mulch band of dead banana leaves (long golden-brown strokes) over dark wet humus
for _, r in ipairs(rows) do
  local y = floor(r[2])
  local th = r[3] > .8 and 3 or 2
  for x = 18, 461 do
    for k = 1, th do
      if not F.roadM:has(x, y + k) and hash(x, y + k, 92) < .7 then px(x, y + k, (k == th) and L.duff or L.ground.deep) end
    end
  end
  local x = 18
  while x < 461 do
    local len = 2 + floor(hash(x, y, 93) * (r[3] > .8 and 7 or 4))
    local yy = y + 1 + floor(hash(x, y, 94) * th)
    local col = ({ DEADL.base, DEADL.shade, DEADL.hi, L.needle.shade })[1 + floor(hash(x, y, 95) * 4)]
    for q = 0, len - 1 do if not F.roadM:has(x + q, yy) then px(x + q, yy, (q == 0) and DEADL.deep or col) end end
    x = x + len + 1 + floor(hash(x, y, 96) * 4)
  end
end
-- low mist in the far rows
for _, m in ipairs({ { 30, 186, 128 }, { 294, 452, 127 }, { 60, 170, 139 }, { 316, 430, 138 } }) do
  for x = m[1], m[2] do
    local v = c:get(x, m[3])
    if v and not F.roadM:has(x, m[3]) and hash(x // 5, m[3], 93) < .55 then px(x, m[3], F.mix(v, L.mist, .45)) end
    local v2 = c:get(x, m[3] + 1)
    if v2 and (x - m[1]) % 9 < 4 and hash(x // 3, m[3], 94) < .4 then px(x, m[3] + 1, F.mix(v2, L.mist2, .3)) end
  end
end
-- a couple of rain puddles in the rides
F.puddle(150, 176, 6, 3) F.puddle(318, 170, 5, 4) F.puddle(96, 196, 7, 5)

table.sort(rows, function(a, b) if a[2] ~= b[2] then return a[2] < b[2] end return a[1] < b[1] end)
local function drawRow(i, r)
  F.depth(r[2] < 140 and 1 or (r[2] < 170 and 2 or 3))
  local x = floor(r[1])
  if x > 0 and x < 480 and not (x > 370 and r[2] > 175) then
    if r[4] == 0 then
      F.palm(x, r[2], floor(66 * r[3]), 400 + i, { lean = (x < 240) and -4 * r[3] or 4 * r[3] }) -- a coconut palm shading the row
    else
      fruitTree(x, r[2], r[3], i * 7 + 1, r[4])
    end
  end
end
local ri = 1
while rows[ri] and rows[ri][2] < 126 do drawRow(ri, rows[ri]) ri = ri + 1 end

F.depth(2)
---------------------------------------------------------------- great old mango tree at the road's end
local function oldTree()
  local tr = poly{ { 226, 126 }, { 233, 104 }, { 234, 96 }, { 230, 84 }, { 250, 84 }, { 246, 96 }, { 247, 104 }, { 254, 126 } }
  local fins = poly{ { 213, 127 }, { 221, 125 }, { 226, 118 }, { 229, 106 }, { 232, 127 } }:add(poly{ { 248, 127 }, { 250, 104 }, { 253, 116 }, { 259, 124 }, { 267, 127 } })
  fins:add(poly{ { 237, 127 }, { 239, 119 }, { 241, 127 } })
  local brs = line({ { 236, 90 }, { 212, 70 } }, 3):add(line({ { 246, 88 }, { 270, 68 } }, 3)):add(line({ { 240, 86 }, { 238, 66 } }, 2))
  F.shadow(214, 266, 128, 10, 3)
  local all = union(tr, fins, brs)
  rimOf(all, L.timber) part(tr, L.timber) part(brs, L.timber, { nopop = true })
  -- buttress fins, lit on their left faces, a dark crease where each meets the trunk
  fins:each(function(x, y)
    local h = x < 240 and L.timber.base or L.timber.shade
    if not fins:has(x - 1, y) or not fins:has(x, y - 1) then h = L.timber.hi end
    if tr:has(x, y) then h = L.timber.deep end
    px(x, y, h)
  end)
  tr:each(function(x, y)
    if (x * 2 + y) % 9 == 0 or ((x + y // 3) % 6 == 0 and y > 100) then px(x, y, L.timber.deep) end
    if x > 245 and hash(x // 2, y // 2, 61) < .5 then px(x, y, hash(x, y, 62) < .5 and L.moss.base or L.moss.shade) end
    if x < 236 and hash(x // 2, y // 3, 66) < .08 then px(x, y, L.birch.hi) end -- pale lichen
  end)
  F.moss(union(brs), .25, 63)
  -- epiphytes: a red bromeliad in the crotch, an orchid spray and a staghorn fern on the trunk
  F.sprite({ "r...r", ".rRr.", "rRhRr", ".gGg." }, 238, 82, { r = L.helic.shade, R = L.helic.base, h = L.helic.hi, g = L.vine.shade, G = L.vine.base })
  F.orchid(231, 106, L.orchid, 2, true)
  F.sprite({ "g..g..g", ".gG.Gg.", "..gGg..", "...g..." }, 247, 98, { g = L.fern.shade, G = L.fern.base })
  -- the crown
  local cm = HP.mask()
  cm:add(F.crown(210, 62, 24, 16, MLEAF, 51)) cm:add(F.crown(270, 60, 24, 16, MLEAF2, 52))
  cm:add(F.crown(240, 48, 30, 18, MLEAF, 53)) cm:add(F.crown(240, 72, 20, 10, MLEAF2, 54))
  flush(cm, 188, 292, 26, 90, 26, 55, true)
  -- mangoes: some in the leaves, many dangling under the crown on long stalks
  for i = 1, 52 do
    local ax = 188 + floor(hash(i, 3, 1) * 104)
    local by = crownBottom(cm, ax, 26, 90)
    if by then
      local fr = (i % 4 == 0) and MANGOG or MANGO
      local bl = (fr == MANGO and i % 3 == 0) and L.apple.base or nil
      if i % 2 == 0 then
        local sl = 1 + floor(hash(i, 5, 1) * 4)
        vline(ax, by + 1, by + sl, L.vine.deep)
        fill(rect(ax, by + sl + 1, ax + 1, by + sl + 3), fr.base) px(ax, by + sl + 1, bl or fr.hi) px(ax + 1, by + sl + 3, fr.shade) px(ax, by + sl + 3, fr.shade)
        px(ax, by + sl + 4, fr.deep)
      else
        local ay = floor(by - 4 - hash(i, 4, 1) * 26)
        if cm:has(ax, ay) and cm:has(ax + 1, ay + 2) then fill(rect(ax, ay, ax + 1, ay + 2), fr.base) px(ax, ay, bl or fr.hi) px(ax + 1, ay + 2, fr.shade) end
      end
    end
  end
  F.vines(cm:copy():clip(rect(180, 66, 300, 92)), .05, 77, 14)
  -- rattan swing
  vline(216, 72, 112, RATTAN.deep) vline(228, 74, 112, RATTAN.deep)
  for y = 76, 110, 4 do px(216, y, RATTAN.base) px(228, y + 2, RATTAN.base) end
  local seat = rect(214, 112, 230, 114) rimOf(seat, L.timber) part(seat, L.bamboo, { nopop = true })
  F.gnome(222, 112, { small = true, hat = L.awnA, coat = L.wall2, noShadow = true }) -- a little one swinging
  -- fruit bats hanging asleep from the right limb, one with a mango
  for k, b in ipairs({ { 256, 79 }, { 262, 75 } }) do
    F.sprite({ ".f.f.", ".WWW.", "WWwWW", "WWwWW", ".WWW.", ".hEh.", "..h.." }, b[1], b[2],
      { f = L.timber.deep, W = "#4c3a3c", w = "#6a5250", h = L.litter.shade, E = INK })
  end
  -- an amazon parrot on the left limb
  F.sprite({ ".gg..", "gyeg.", "ogGg.", ".gGGg", "..rGg", "...gg", "...g." }, 218, 64,
    { g = "#2e8a46", G = "#4cb058", y = L.gold.hi, e = INK, o = L.gold.shade, r = L.apple.base })
end
oldTree()

---------------------------------------------------------------- back-right: the cacao-drying house (between the rows)
while rows[ri] and rows[ri][2] < 140 do drawRow(ri, rows[ri]) ri = ri + 1 end
F.depth(1)
local function dryHouse()
  local top, cx, wallM, roofM = F.building{ x0 = 404, x1 = 462, yb = 140, wh = 30, rh = 22, wall = L.bamboo, roof = L.roof, noFrame = true, noAttic = true }
  F.bambooWall(wallM:copy():clip(rect(404, top + 4, 462, 140)), L.bamboo, 3, false, 25)
  local gab = poly{ { 409, top }, { 433, top - 14 }, { 457, top } }:cut(roofM)
  gab:each(function(x, y) px(x, y, (((x + y) // 2) % 2 == ((x - y) // 2) % 2) and L.plaster.base or L.plaster.shade) end)
  -- open doorway with sacks of beans inside, a lamp glow
  local dm = rect(422, 116, 442, 139)
  fill(rect(421, 115, 443, 139), L.timber.edge) fill(dm, L.soil.deep) fill(rect(423, 117, 431, 124), L.glow.shade) px(424, 118, L.glow.base)
  for _, sx in ipairs({ 427, 436 }) do local sm = F.sack(sx, 139, RATTAN, 4) end
  local posts = union(rect(404, top + 4, 405, 140), rect(461, top + 4, 462, 140))
  part(posts, L.timber, { nopop = true, noshade = true })
  F.vines(rect(404, top + 2, 462, top + 4), .06, 88, 8)
  -- a ladder leaning on the eave
  local lad = line({ { 456, 140 }, { 464, 112 } }):add(line({ { 460, 140 }, { 468, 112 } }))
  for k = 1, 6 do local t = k / 7 lad:add(line({ { 456 + 8 * t, 140 - 28 * t }, { 460 + 8 * t, 140 - 28 * t } })) end
  c:rim(lad, L.timber.edge) fill(lad, L.bamboo.base)
  -- the raised drying deck: a woven mat of cacao beans on bamboo legs, a gnome raking them
  local legs = HP.mask()
  for _, lx in ipairs({ 368, 382, 398 }) do legs:add(rect(lx, 132, lx + 1, 142)) end
  local deck = poly{ { 364, 128 }, { 402, 128 }, { 404, 132 }, { 362, 132 } }
  rimOf(union(legs, deck), L.timber) part(legs, L.bamboo, { nopop = true, noshade = true })
  fill(deck, RATTAN.shade)
  deck:each(function(x, y)
    if y < 131 then
      local v = hash(x, y, 89)
      px(x, y, v < .35 and BEAN.base or (v < .6 and BEAN.shade or (v < .75 and BEAN.hi or BEAN.deep)))
    else px(x, y, (x % 2 == 0) and RATTAN.base or RATTAN.deep) end
  end)
  hline(362, 404, 132, L.bamboo.shade)
  F.gnome(388, 128, { small = true, hat = L.roof2, coat = L.awnA, arm = "out" })
  line({ { 398, 121 }, { 404, 129 } }):each(function(x, y) px(x, y, L.bamboo.deep) end)
  hline(401, 406, 129, L.timber.base)
end
dryHouse()

---------------------------------------------------------------- the rest of the rows
while rows[ri] do drawRow(ri, rows[ri]) ri = ri + 1 end

---------------------------------------------------------------- left hero: the bamboo fruit press under a palm-thatch hood
F.depth(2)
F.heliconia(200, 184, 26, 45)
F.depth(3)
local function press(x0, yb)
  local posts = rect(x0, yb - 52, x0 + 4, yb):add(rect(x0 + 46, yb - 52, x0 + 50, yb))
  local beam = rect(x0 - 4, yb - 56, x0 + 54, yb - 50)
  local screw = rect(x0 + 23, yb - 50, x0 + 27, yb - 28)
  local bar = rect(x0 + 6, yb - 42, x0 + 44, yb - 40)
  local plate = rect(x0 + 10, yb - 28, x0 + 40, yb - 24)
  local tub = poly{ { x0 + 6, yb - 24 }, { x0 + 44, yb - 24 }, { x0 + 42, yb - 6 }, { x0 + 8, yb - 6 } }
  local base = rect(x0 - 4, yb - 6, x0 + 54, yb)
  local spout = rect(x0 + 52, yb - 10, x0 + 60, yb - 8)
  local roofM = poly{ { x0 - 12, yb - 54 }, { x0 + 25, yb - 74 }, { x0 + 62, yb - 54 } }
  F.shadow(x0, x0 + 56, yb, 12, 4)
  rimOf(union(posts, beam, screw, bar, plate, tub, base, spout, roofM), L.timber)
  part(roofM, L.roof, { sep = true }) F.palmThatch(roofM, L.roof, yb - 74, x0 + 25, 82)
  for x = x0 - 11, x0 + 61 do local len = 1 + floor(hash(x, 7, 83) * 3) for k = 1, len do px(x, yb - 54 + k, k == len and L.roof.edge or L.roof.shade) end end
  px(x0 + 25, yb - 75, L.bamboo.hi)
  -- bamboo posts with nodes, a hardwood beam lashed on with rattan
  F.bambooWall(posts, L.bamboo, 5, false, 84)
  part(beam, L.timber) hline(x0 - 4, x0 + 54, yb - 56, L.timber.hi)
  beam:each(function(x, y) if (x + y * 3) % 11 == 0 then px(x, y, L.timber.deep) end end)
  for _, lx in ipairs({ x0 + 1, x0 + 47 }) do for k = 0, 2 do hline(lx - 1, lx + 4, yb - 55 + k * 2, RATTAN.base) end end
  -- a carved hardwood screw
  part(screw, L.redbark, { nopop = true }) for y = yb - 49, yb - 29, 2 do hline(x0 + 23, x0 + 27, y, L.redbark.deep) px(x0 + 23, y + 1, L.redbark.hi) end
  part(bar, L.bamboo, { nopop = true }) part(plate, L.timber)
  -- the tub: hardwood staves bound with rattan, brimming with mangoes
  part(tub, L.timber) for x = x0 + 10, x0 + 40, 6 do vline(x, yb - 23, yb - 7, L.timber.deep) end
  for _, by in ipairs({ yb - 20, yb - 10 }) do for x = x0 + 7, x0 + 43 do if tub:has(x, by) then px(x, by, (x % 2 == 0) and RATTAN.base or RATTAN.shade) end end end
  for x = x0 + 9, x0 + 41, 2 do px(x, yb - 23, MANGO.shade) if x % 4 == 1 then px(x, yb - 22, MANGO.base) end end
  part(base, L.timber, { nopop = true }) F.bambooWall(base, L.bamboo, 3, true, 85)
  part(spout, L.bamboo, { nopop = true })
  -- juice pouring into a clay pot
  vline(x0 + 60, yb - 7, yb + 4, MANGO.base) vline(x0 + 61, yb - 7, yb + 4, MANGO.hi)
  local pot = c:ellipse(x0 + 61, yb + 9, 7, 5):add(rect(x0 + 56, yb + 3, x0 + 66, yb + 5))
  rimOf(pot, CLAY) part(pot, CLAY) hline(x0 + 56, x0 + 66, yb + 3, MANGO.base) hline(x0 + 57, x0 + 65, yb + 4, MANGO.shade)
  hline(x0 + 55, x0 + 67, yb + 6, CLAY.deep) F.shine(pot, .12, 86)
  -- a hummingbird at the sweet spout
  F.sprite({ "w.....", "ww....", ".GGgbb", "..rG..", "..g..." }, x0 + 62, yb - 18, { w = L.mist2, G = L.teal.base, g = L.teal.deep, r = L.apple.base, b = INK }, { rim = false })
end
press(92, 206)
-- a gnome turning the press bar
local _, tx, ty = F.gnome(80, 210, { hat = L.lav, coat = L.leaf, arm = "up" })
fill(line({ { tx, ty }, { 98, 166 } }), L.bamboo.base)
-- heaps of mangoes and papayas beside the press
local function heap(x0, x1, yb, fr, big)
  local m = poly{ { x0, yb }, { x0 + 4, yb - 7 }, { (x0 + x1) // 2, yb - 11 }, { x1 - 4, yb - 7 }, { x1, yb } }
  rimOf(m, fr) fill(m, fr.base)
  local step = big and 5 or 4
  m:each(function(x, y) local k = (x + (y // 3) * 2) % step if k == 0 then px(x, y, fr.hi) elseif k == step - 1 then px(x, y, fr.shade) end end)
  m:each(function(x, y) if (y - yb) % 3 == 0 and (x + y) % step == 2 then px(x, y, fr.deep) end end)
  for x = x0 + 4, x1 - 4, 7 do px(x, yb - 8 + (x % 3), MLEAF.base) px(x + 1, yb - 9 + (x % 3), MLEAF.hi) end
end
heap(30, 84, 214, MANGO)
heap(16, 44, 206, PAPF, true)
for _, b in ipairs({ { 34, 207 }, { 48, 210 }, { 62, 206 }, { 74, 210 } }) do px(b[1], b[2], L.apple.base) px(b[1] + 1, b[2], L.apple.shade) end -- red blush
-- a bamboo crate of cacao pods, rattan baskets of mangoes
local cr1 = F.crate(24, 232, 22, 12, CACY) F.bambooWall(cr1:copy():clip(rect(25, 221, 45, 231)), L.board, 3, true, 87)
local cr2 = F.crate(50, 234, 22, 12, CACR) F.bambooWall(cr2:copy():clip(rect(51, 223, 71, 233)), L.board, 3, true, 88)
basket(47, 220, 10, 8, MANGO)
basket(80, 226, 7, 6, nil, "pods")
-- taro leaves in the near-left corner
F.bigLeaf(6, 252, 18, -pi * .7, L.foliage, 31, 8, { heart = true, stem = { 12, 266 } })
F.bigLeaf(16, 256, 16, -pi * .35, L.leaf, 32, 7, { heart = true, stem = { 13, 267 } })
-- a bamboo table: a calabash, a pineapple, a cut papaya, a hand of bananas and a coconut cup of juice
local tbl = rect(118, 226, 182, 229):add(rect(121, 230, 123, 242)):add(rect(177, 230, 179, 242))
F.shadow(120, 182, 242, 8, 3)
rimOf(tbl, L.timber) part(tbl, L.bamboo, { nopop = true }) F.bambooWall(rect(118, 226, 182, 229), L.bamboo, 2, true, 89)
F.sprite({ "..nn...", "..GG...", ".GgGG..", "..Gg...", ".GGGGG.", "GGGgGGG", "GGgGGGG", "GGGGGgG", ".GGGGG." }, 124, 216,
  { n = L.timber.base, G = GOURD.base, g = GOURD.hi })
local gm = rect(124, 220, 130, 224) gm:each(function(x, y) if x > 128 then px(x, y, GOURD.shade) end end)
hline(125, 129, 221, CLAY.shade)
F.sprite({ "l.l.l", ".lLl.", "l.L.l", ".YyY.", "YyYyY", "yYyYy", "YyYyY", "yYyYy", ".yYy." }, 136, 216,
  { l = L.teal.shade, L = L.teal.base, Y = L.gold.base, y = L.gold.shade })
F.sprite({ ".gggggg.", "gOOOOOOg", "gOkOkOOg", "gOOkOkOg", ".gggggg." }, 145, 220, { g = MANGOG.base, O = PAPF.hi, k = INK })
F.sprite({ "..sYYY", ".YYYy.", "YYYy..", "yy...." }, 157, 219, { s = L.vine.deep, Y = BAN.base, y = BAN.shade })
F.sprite({ ".hhhh.", "hMMMMh", ".hhhh." }, 168, 222, { h = L.soil.base, M = MANGO.base })
-- big clay jars
jar(196, 250, 14, CLAY) jar(184, 262, 12, GOURD)
F.mushroom(206, 252, L.produce, true) F.mushroom(210, 254, L.produce)

---------------------------------------------------------------- right hero: picker on a bamboo ladder at a big front mango tree
local hero = mangoTree(408, 226, 2.3, 77)
-- blue-and-gold macaws in it
F.sprite({ "..BB....", ".BWeB...", "kWWBB...", "kk.YYB..", "...YYBB.", "...YYYB.", "...YYBB.", "....YBb.", "....BBb.", ".....Bb.", ".....B..", ".....b.." }, 428, 160,
  { B = "#3a7ac8", b = "#24508e", W = L.awnB.hi, e = INK, k = "#3a3438", Y = L.gold.base })
F.sprite({ "...BB.", "..BeWB", "...BWW", "..BYY.", ".BBYY.", ".BYYY.", ".bBY..", ".bB...", "..b..." }, 396, 166,
  { B = "#3a7ac8", b = "#24508e", W = L.awnB.hi, e = INK, Y = L.gold.base })
local lad = line({ { 352, 236 }, { 370, 168 } }, 2):add(line({ { 364, 238 }, { 382, 170 } }, 2))
local rungs = HP.mask()
for k = 0, 8 do local t = k / 8 rungs:add(line({ { 352 + 18 * t, 236 - 68 * t }, { 364 + 18 * t, 238 - 68 * t } })) end
rimOf(union(lad, rungs), L.timber) part(lad, L.bamboo, { nopop = true, noshade = true })
lad:each(function(x, y) if y % 7 == 0 then px(x, y, L.bamboo.deep) end end)
fill(rungs:cut(lad), L.bamboo.shade)
local _, phx, phy = F.gnome(375, 190, { hat = L.awnA, coat = L.wall2, arm = "up", noShadow = true })
fill(rect(phx, phy - 2, phx + 1, phy), MANGO.base) px(phx, phy - 2, L.apple.base) px(phx + 1, phy, MANGO.shade) -- a mango just picked
local bas = poly{ { 366, 186 }, { 380, 186 }, { 378, 195 }, { 368, 195 } } rimOf(bas, RATTAN) part(bas, RATTAN)
bas:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, RATTAN.shade) end end)
for k = 0, 5 do fill(rect(367 + k * 2, 184, 368 + k * 2, 185), MANGO.base) px(367 + k * 2, 184, (k % 2 == 0) and L.apple.base or MANGO.hi) end
-- crates and baskets by the road (right)
local cr3 = F.crate(290, 226, 22, 12, MANGO) F.bambooWall(cr3:copy():clip(rect(291, 215, 311, 225)), L.board, 3, true, 90)
local cr4 = F.crate(314, 228, 22, 12, CACP) F.bambooWall(cr4:copy():clip(rect(315, 217, 335, 227)), L.board, 3, true, 91)
local cr5 = F.crate(300, 213, 22, 11, CACY) F.bambooWall(cr5:copy():clip(rect(301, 203, 321, 212)), L.board, 3, true, 92)
basket(330, 214, 6, 5, PAPF)
-- a gnome carrying a green banana bunch
local _, ghx, ghy = F.gnome(336, 256, { hat = L.roof2, coat = L.awnA, arm = "out", flip = true })
vline(ghx, ghy - 4, ghy - 1, L.vine.deep)
local bunch = HP.mask()
for k = 0, 4 do bunch:add(rect(ghx - 3 + k // 2, ghy + k * 2, ghx + 3 - k // 2, ghy + k * 2 + 1)) end
rimOf(bunch, BANG)
bunch:each(function(x, y) local k = (y - ghy) % 2 px(x, y, k == 0 and (x < ghx and BANG.hi or BANG.base) or BANG.shade) end)
F.sprite({ ".l.", "lLl", ".l." }, ghx - 1, ghy + 10, { l = BELL.shade, L = BELL.base })
-- a bamboo barrow of papayas and a pineapple
local wb = poly{ { 282, 246 }, { 312, 246 }, { 306, 256 }, { 288, 256 } }
local wbh = line({ { 282, 250 }, { 270, 256 } }, 2):add(rect(296, 256, 297, 262))
local wbw = c:ellipse(310, 260, 4, 4)
F.shadow(276, 314, 264, 6, 2)
rimOf(union(wb, wbh, wbw), L.timber) part(wbh, L.bamboo, { nopop = true, noshade = true }) part(wb, L.bamboo) F.bambooWall(wb, L.bamboo, 3, false, 93)
part(wbw, L.timber, { nopop = true }) fill(c:ellipse(310, 260, 1, 1), L.timber.deep)
for x = 285, 305, 4 do
  local fr = (x % 8 == 1) and MANGOG or PAPF
  F.sprite({ ".Hbb.", "Hbbbs", ".sdd." }, x, 242 + (x % 3 == 0 and 1 or 0), { H = fr.hi, b = fr.base, s = fr.shade, d = fr.deep }, { rimCol = fr.edge })
end
F.sprite({ "l.l", ".L.", "YyY", "yYy", "YyY" }, 306, 238, { l = L.teal.shade, L = L.teal.base, Y = L.gold.base, y = L.gold.shade })

---------------------------------------------------------------- jungle at the edges of the grove
for _, f in ipairs({ { 22, 196, 6 }, { 28, 200, 5 }, { 110, 196, 5 }, { 268, 200, 5 }, { 458, 210, 6 }, { 450, 214, 5 },
  { 214, 236, 6 }, { 30, 250, 7 }, { 66, 254, 6 }, { 352, 210, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.heliconia(466, 214, 24, 46)
F.heliconia(12, 228, 22, 47)
F.orchid(440, 222, L.orchid, 2, true)
F.orchid(118, 252, L.petal, 3)
for _, m in ipairs({ { 120, 256 }, { 236, 222 }, { 274, 232 }, { 446, 202 } }) do F.mushroom(m[1], m[2], L.produce, true) end

---------------------------------------------------------------- windfalls + quirk tenrec
for i = 0, 44 do
  local x, y = 20 + floor(hash(i, 5, 7) * 440), 150 + floor(hash(i, 6, 7) * 110)
  local fr = (i % 5 == 0) and CACY or ((i % 5 == 1) and MANGOG or ((i % 5 == 2) and CACR or MANGO))
  if not F.roadM:has(x, y) and not (x > 378 and y > 228) then px(x, y, fr.base) px(x + 1, y, fr.shade) px(x, y - 1, fr.hi) px(x + 1, y + 1, fr.deep) end
end
-- quirk: a streaked tenrec trundling off with a mango and a little red gnome hat stuck on its spines
F.shadowM(c:ellipse(220, 263, 13, 1))
F.sprite({
  "..............R.....",
  ".............RRr....",
  "....mmm.....RRRr....",
  "..lmMMmm...RRRRr....",
  "...mMmmmk.hhhhhhh...",
  ".kYkmmmkYkYffffff...",
  "kYkYkYkYkYkfffEfff..",
  "kkYkYkYkYkYffffffffn",
  "kkkkkkkkkkkfffffff..",
  ".kkkkkkkkkkffff.....",
  "..dd...dd...dd......",
}, 206, 252, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, m = MANGO.base, M = L.apple.base, l = MLEAF.base,
  k = "#3a3036", Y = L.gold.base, f = L.needle.shade, E = INK, n = INK, d = L.timber.deep })
-- a Malayan tapir (dark front and legs, pale saddle) snuffling the windfalls under the far-left trees
F.sprite({
  "...d....................",
  "..dDd.....cccccccccc....",
  ".dDDDdddcCCCCCCCCCCCcc..",
  "dDEDDDDdcCCCCCCCCCCCCCc.",
  "dDDDDDDdcCCCCCCCCCCCCCCc",
  "nDDDDDDDdcCCCCCCCCCCCCCc",
  "nn.DDDDDDdcccccccccDDDd.",
  "n...DDDd.........DDDd...",
  "....DDd..........DDd....",
  "....ddd..........ddd....",
}, 40, 172, { D = "#4a4048", d = "#362e36", c = L.awnB.shade, C = L.awnB.base, E = L.awnB.shade, n = "#4a4048" })
F.shadowM(c:ellipse(53, 183, 12, 1))
for _, a in ipairs({ { 34, 180 }, { 37, 182 }, { 70, 181 } }) do px(a[1], a[2], MANGO.base) px(a[1] + 1, a[2], MANGO.shade) px(a[1], a[2] - 1, L.apple.base) end
-- a parakeet pecking a windfall mango by the road
F.sprite({ ".yg...", "yegGg.", "oyGGgg", ".gGGgt", "..d.dt" }, 182, 190, { y = L.gold.hi, e = INK, g = "#2e8a46", G = "#5cbc5a", o = L.helic.shade, t = "#1e6a3a", d = L.gold.shade })
px(180, 195, MANGO.base) px(179, 195, MANGO.shade) px(180, 194, L.apple.base)
-- a coati on the crate stack, ringed tail up, nibbling a banana
F.sprite({
  "T...............",
  "t...............",
  "T...............",
  "t...cccc........",
  "Tt.cCCCCcc......",
  ".tcCCCCCCcEcc...",
  "..cCCCCCCcccccnY",
  "..cccccccc...YYy",
  "...d.d..d.d.....",
}, 302, 193, { T = L.timber.deep, t = L.needle.hi, c = L.needle.shade, C = L.needle.base, E = INK, n = INK, Y = BAN.base, y = BAN.shade, d = L.timber.edge })
F.depth(0)
-- scarlet macaws and green parrots crossing the sky
F.birds({ { 330, 40, 2, "#c83a34" }, { 340, 45, 2, "#c83a34" }, { 120, 48, 2, "#2e7a46" }, { 132, 42, 1, "#2e7a46" }, { 166, 60, 1, "#3a6ec0" } })
F.finish()
