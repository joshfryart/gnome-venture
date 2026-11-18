-- ferry.lua : "Ferry crossing" stop look, MOUNTAIN (mountain_granite), 480x270 gate view.
-- Same composition as the Maplewold ferry (art-2701-batch4/stops/opus3/ferry.lua), re-cast for the high mountains:
-- a fast, milky glacial river runs across the whole view between granite banks, and the road stops at it on a granite
-- slab landing. A rope-hauled cable ferry: a steel cable is strung from a larch A-frame on the far bank to a mast on the
-- near bank, the raft hangs off it by a pulley and bridle, a ferryman steadies it with a pole and a gnome on the landing
-- hauls it in by the tow rope. On the raft: a traveller with a bundle, milk cans and a stack of cheeses. Far bank: the road
-- goes on past the ferryman's stone-and-larch house (bell post), a stone hut with smoke, washing, a gnome waving, larch and
-- spruce; on the right a granite crag (the gorge wall) with a waterfall and a chamois on top. In the river: rapids around
-- granite boulders, a fisher gnome on a midstream rock, dippers. Near bank: ferry bell under a slab roof, a painted ferry
-- sign, a stone-and-larch ticket booth with a gnome in the hatch, a bench of waiting travellers, a beached rowboat, a
-- barrow of firewood, cheeses and sacks waiting to cross, a fisher on a bucket, a goat after a gnome's apple, sedge and
-- cotton grass, boulders, edelweiss and gentian. Quirk: a big white hen in a red gnome hat, riding the raft on a trunk.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-mountain-stops/"
local F = dofile(DIR .. "_frame.lua")
  .build{ name = "ferry", out = DIR, roadTop = 178, farTrees = { 30, 70, 120, 168, 330, 372, 446 }, treeLineGap = { 212, 288 },
    clouds = { { 150, 30, 46 }, { 290, 20, 60 }, { 404, 44, 34 }, { 12, 50, 30 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local mix, vnoise = F.mix, F.vnoise
local Wt = L.water
local FOAM = "#eef4f0"   -- white water (never pure white)
local GLINT = "#f2f6ea"
-- DY: a temporary vertical offset for whole near-bank groups (set, draw, reset)
local DY = 0
do local base = c.put c.put = function(self, x, y, h, o) base(self, x, y + DY, h, o) end end

local function yF(x) return 124 + floor(2 * sin(x / 31) + 1.5 * sin(x / 11)) end
local function yN(x) local t = (x - 240) / 240 return 177 + floor(14 * t * t + 3 * sin(x / 23) + 2 * sin(x / 9 + 1)) end

---------------------------------------------------------------- the glacial river
local river = HP.mask()
for x = 0, 479 do for y = yF(x), yN(x) do river:set(x, y) end end
-- rapids: choppy standing waves inside an ellipse (crests foam, troughs dark), densest at the centre
local function rapids(cx, cy, rx, ry, seed, k)
  k = k or 1
  for y = cy - ry, cy + ry do for x = cx - rx, cx + rx do
    if river:has(x, y) and river:has(x, y + 1) then
      local e = ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2
      if e < 1 then
        local v = vnoise(x / 4 + y * .35, y / 1.6, seed)
        local thr = .5 + e * .35 / k
        if v > thr + .14 then px(x, y, FOAM)
        elseif v > thr then px(x, y, Wt.hi)
        elseif v < .2 + e * .1 then px(x, y, Wt.deep)
        elseif v < .32 then px(x, y, Wt.shade) end
      end
    end
  end end
end
-- a granite rock standing in the current: foam pillow upstream (left), collar, a V of white water trailing right
local function riverRock(x, yb, w, h, seed)
  local m = F.boulder(x, yb, w, h, seed)
  m:each(function(xx, yy) if yy >= yb - 1 then px(xx, yy, L.stone.deep) end end) -- wet foot
  for k = 0, 2 do px(x - w - 1 - k, yb - 1 + (k == 2 and 1 or 0), FOAM) end
  for xx = x - w - 1, x + w + 1 do px(xx, yb + 1, hash(xx, yb, seed) < .6 and FOAM or Wt.hi) end
  for k = 1, w * 3 do
    local a = floor(k * .28)
    local col = k < w * 1.5 and FOAM or Wt.hi
    if hash(k, 1, seed) < .8 then px(x + w + k, yb - a, col) end
    if hash(k, 2, seed) < .8 then px(x + w + k, yb + 1 + a, col) px(x + w + k, yb + 2 + a, Wt.shade) end
  end
  return m
end
do
  river:each(function(x, y)
    local f = (y - yF(x)) / math.max(1, yN(x) - yF(x))
    local h
    if f < .16 then h = Wt.hi
    elseif f < .38 then h = hash(x // 8, y, 14) < .5 and Wt.hi or mix(Wt.hi, Wt.base, .5)
    elseif f < .78 then h = Wt.base
    else h = hash(x // 6, y // 2, 15) < .6 and mix(Wt.base, Wt.shade, .5) or Wt.base end
    px(x, y, h)
  end)
  -- the current: long streaks racing left to right, longer nearer, a dark under-line on the near half,
  -- foam tearing off the heads of some
  for y = 126, 196 do
    local d = y - 122
    if y % 2 == 0 then
      local x = floor(hash(y, 1, 13) * 30)
      while x < 480 do
        local len = 6 + d // 2 + floor(hash(x, y, 18) * 10)
        if hash(x // 9, y, 16) < .55 then
          for xx = x, x + len do if river:has(xx, y) and river:has(xx, y + 1) then
            px(xx, y, (xx > x + len - 3 and hash(xx, y, 19) < .7) and FOAM or Wt.hi)
            if d > 18 then px(xx, y + 1, Wt.shade) end
          end end
        end
        x = x + len + 8 + floor(hash(x, y, 17) * 20)
      end
    end
  end
  for i = 0, 90 do local x, y = floor(hash(i, 1, 18) * 480), 126 + floor(hash(i, 2, 18) * 64) if river:has(x, y) and river:has(x + 1, y) then px(x, y, GLINT) px(x + 1, y, Wt.hi) end end
  -- rapids: a riffle across the left-centre, white water under the crag, a chute along the near right
  rapids(165, 146, 46, 9, 51, 1.1)
  rapids(64, 160, 40, 8, 52, .9)
  rapids(420, 140, 50, 10, 53, 1.2)
  rapids(430, 170, 46, 9, 54, 1)
  rapids(200, 133, 30, 5, 55, .7)
  -- far bank: a dark wet lip, a granite ledge above it; near bank: lapping foam on a ledge of granite slabs
  for x = 0, 479 do
    local yf = yF(x)
    px(x, yf, Wt.deep) px(x, yf + 1, Wt.shade)
    local v = hash(x // 4, 1, 7)
    px(x, yf - 1, (x % 9 == 0) and L.stone.deep or (v < .5 and L.stone.base or L.stone.shade))
    px(x, yf - 2, (v < .4) and L.stone.hi or L.stone.base)
    local yn = yN(x)
    px(x, yn, hash(x, 1, 8) < .5 and FOAM or Wt.hi)
    px(x, yn - 1, hash(x, 2, 8) < .25 and FOAM or c:get(x, yn - 1))
    local j = (x + floor(hash(x // 11, 3, 9) * 7)) % 11 == 0
    for k = 1, 6 do
      local col
      if k == 1 then col = L.stone.deep
      elseif k == 2 then col = hash(x, 2, 10) < .6 and L.stone.hi or L.stone.base
      elseif k == 6 then col = hash(x, 6, 10) < .5 and L.ground.deep or L.stone.deep
      else col = (hash(x // 3, k, 11) < .35) and L.stone.shade or L.stone.base end
      if j and k > 1 and k < 6 then col = L.stone.deep end
      px(x, yn + k, col)
    end
    if hash(x, 9, 12) < .05 then px(x, yn + 3, L.moss.base) end
    if hash(x, 10, 12) < .012 then px(x, yn + 4, L.lichenOrange) end
  end
end

---------------------------------------------------------------- far bank: road on, landing, stone hut, larch and spruce
F.depth(1)
F.drawRoad(113, 122)
F.tree(20, 122, 40, 2)
F.tree(96, 121, 30, 3)
F.tree(112, 122, 34, 5)
do -- a stone hut with smoke: whitewashed granite, slab roof weighed down with stones
  local top, cx, wallM, roofM = F.building{ x0 = 36, x1 = 80, yb = 122, wh = 13, rh = 11, wall = L.plaster, roof = L.roof, noFrame = true, noAttic = true, chimney = true, shingle = true }
  F.courses(wallM, top, 3, 6, L.plaster)
  F.lichen(roofM, .2, 101)
  for _, w in ipairs({ { 44, 105 }, { 58, 100 }, { 72, 105 } }) do fill(c:ellipse(w[1], w[2], 2, 1), L.stone.shade) px(w[1] - 1, w[2] - 1, L.stone.hi) end
  F.window(44, 113, 48, 116, L.timber) F.window(68, 113, 72, 116, L.timber)
  F.smoke(70, 94, 4, .6, 2)
end
-- sedge with cotton grass along the banks (far: fine blades and dots; near: 2 px blades and white tufts)
local function sedge(x, yb, n, hmax, seed, near)
  local blades = {}
  for i = 1, n do
    local bx = x + floor((hash(i, 1, seed) - .5) * n * 1.6)
    local h = floor(hmax * (.55 + .45 * hash(i, 2, seed)))
    local lean = (hash(i, 3, seed) - .5) * (near and 8 or 4)
    blades[#blades + 1] = { bx, h, lean, hash(i, 4, seed) }
  end
  local m = HP.mask()
  local heads = {}
  for _, b in ipairs(blades) do
    local bx, h, lean, v = b[1], b[2], b[3], b[4]
    local pts = { { bx, yb }, { bx + lean * .3, yb - h * .5 }, { bx + lean, yb - h } }
    m:add(line(pts, near and 2 or 1))
    if v < .5 then heads[#heads + 1] = { floor(bx + lean * .8), yb - h - 1 } end
  end
  if near then c:rim(m, L.fern.edge) end
  m:each(function(xx, yy)
    local t = (yb - yy) / hmax
    local hsh = hash(xx, yy, seed)
    local col = t > .6 and L.fern.hi or (t > .25 and L.fern.base or L.fern.shade)
    if hsh < .22 then col = L.fern.shade elseif hsh > .88 then col = L.needle.base end
    if yy >= yb - 1 then col = L.fern.deep end
    px(xx, yy, col)
  end)
  for _, hd in ipairs(heads) do
    local hx, hy = hd[1], hd[2]
    if near then
      local tuft = rect(hx - 1, hy - 3, hx + 1, hy) c:rim(tuft, L.edel.deep)
      fill(tuft, L.edel.base) px(hx - 1, hy - 3, L.edel.hi) px(hx, hy - 3, L.edel.hi) px(hx - 1, hy - 2, L.edel.hi) px(hx + 1, hy, L.edel.shade) px(hx + 1, hy - 1, L.edel.shade)
    else
      px(hx, hy, L.edel.hi) px(hx, hy + 1, L.edel.shade)
    end
  end
end
for _, r in ipairs({ { 14, 8 }, { 40, 10 }, { 110, 9 }, { 150, 12 }, { 192, 8 }, { 300, 8 }, { 352, 10 } }) do
  sedge(r[1], yF(r[1]) - 1, r[2], 7, r[1], false)
end
-- far landing: granite slabs on a block face, two stone bollards
do
  local d = poly{ { 234, 121 }, { 248, 121 }, { 250, 129 }, { 232, 129 } }
  local fc = rect(232, 130, 250, 132)
  rimOf(union(d, fc), L.stone) part(d, L.stone) F.courses(d, 121, 3, 6, L.stone) part(fc, L.stone, { nopop = true, noshade = true }) F.courses(fc, 130, 3, 5, L.stone)
  for _, x in ipairs({ 233, 248 }) do fill(rect(x, 120, x + 1, 122), L.stone.shade) px(x, 120, L.stone.hi) end
  hline(231, 251, 133, FOAM)
end

---------------------------------------------------------------- far bank right: the gorge wall, a granite crag with a waterfall
F.depth(2)
local crag
do
  local tops = { { 380, 126 }, { 383, 112 }, { 388, 102 }, { 394, 97 }, { 401, 96 }, { 406, 90 }, { 413, 87 }, { 418, 81 }, { 424, 82 },
    { 429, 89 }, { 436, 90 }, { 441, 84 }, { 447, 77 }, { 455, 75 }, { 462, 80 }, { 470, 79 }, { 479, 83 }, { 479, 127 } }
  crag = poly(tops)
  crag:cut(river)
  local function topAt(x) for y = 60, 127 do if crag:has(x, y) then return y end end return 127 end
  rimOf(crag, L.stone)
  crag:each(function(x, y)
    -- vertical granite facets (lit faces to the left of each crack), curved sheeting joints, wet dark foot
    local f = (x + (y - 80) * .28) / 10 + vnoise(x / 13, y / 17, 61) * 1.3
    local fr = f - floor(f)
    local h
    if fr < .22 then h = L.stone.hi elseif fr < .62 then h = L.stone.base elseif fr < .9 then h = L.stone.shade else h = L.stone.deep end
    local jy = (y + floor(3 * sin(x / 11) + (x - 380) * .08)) % 10
    if jy == 0 and hash(x // 5, y, 62) < .8 then h = L.stone.deep elseif jy == 1 and h ~= L.stone.deep then h = L.stone.hi end
    if x > 452 and h == L.stone.hi then h = L.stone.base end
    if x > 462 and h == L.stone.base then h = L.stone.shade end
    if y > yF(x) - 7 and hash(x, y, 63) < .55 then h = (h == L.stone.hi) and L.stone.base or L.stone.deep end
    if y == topAt(x) then h = (x < 452) and L.stone.hi or L.stone.base end
    px(x, y, h)
    -- streaks of dark water stain running down from the joints
    if (x * 7) % 13 == 0 and hash(x, y // 6, 64) < .5 and h ~= L.stone.hi then px(x, y, L.stone.shade) end
  end)
  F.lichen(crag, .22, 65)
  -- snow and turf left on the ledges (the pixel above a joint)
  crag:each(function(x, y)
    local jy = (y + 1 + floor(3 * sin(x / 11) + (x - 380) * .08)) % 10
    if jy == 0 and y < 112 and hash(x // 4, y, 66) < .35 then px(x, y, hash(x, y, 67) < .5 and L.snow.hi or L.snow.base) px(x, y + 1, L.snow.shade)
    elseif jy == 0 and hash(x // 3, y, 68) < .25 then px(x, y, L.fern.base) px(x, y - 1, L.fern.hi) end
  end)
  -- turf and trees on the top: larch, arolla, spruce
  for x = 381, 479 do local t = topAt(x) if t < 127 then px(x, t, L.fern.hi) if hash(x, 1, 69) < .5 then px(x, t - 1, L.fern.base) end end end
  F.larch(397, 98, 26, 7)
  F.tree(415, 88, 18, 3)
  F.tree(452, 77, 30, 0)
  F.larch(468, 81, 22, 9)
  F.tree(438, 86, 14, 2)
  F.goat(426, 83, { k = .42, r = L.chamois, flip = true, noShadow = true })
  -- the waterfall out of the notch, falling in two leaps to the river, spray at the foot
  local function wx(y) return 431 + floor(1.5 * sin(y / 6)) + (y > 104 and 1 or 0) end
  for y = 89, yF(431) + 1 do
    local w = 1 + floor((y - 89) / 12)
    for x = wx(y) - w, wx(y) + w do
      local v = hash(x, y // 2, 70)
      px(x, y, (x == wx(y) - w) and L.snow.hi or (v < .45 and L.snow.base or (v < .8 and Wt.hi or L.snow.hi)))
    end
    px(wx(y) + w + 1, y, L.stone.deep)
    if y == 104 then hline(wx(y) - w - 2, wx(y) + w + 2, y, FOAM) end
  end
  for i = 0, 22 do px(422 + floor(hash(i, 1, 71) * 20), 121 + floor(hash(i, 2, 71) * 7), i % 3 == 0 and L.mist2 or FOAM) end
  -- its reflection in the water: dark broken dashes of the crag, a pale streak under the fall
  for x = 380, 479 do for y = yF(x) + 2, yF(x) + 11 do if river:has(x, y) and (y + x // 4) % 3 == 0 and hash(x, y, 72) < .6 then px(x, y, mix(L.stone.shade, Wt.base, .55)) end end end
  for y = yF(431) + 2, yF(431) + 10, 2 do hline(428, 434, y, FOAM) end
end

---------------------------------------------------------------- far bank: ferryman's house, bell post, cable tower, washing
F.depth(2)
F.larch(296, 124, 40, 5)
F.tree(318, 123, 30, 2)
F.tree(350, 124, 48, 0)
F.tree(372, 123, 30, 3)
do -- the ferryman's house: whitewashed granite ground storey, larch boards above, slab roof with stones
  local top, cx, wallM, roofM = F.building{ x0 = 164, x1 = 214, yb = 125, wh = 22, rh = 16, wall = L.timber, roof = L.roof, shingle = true, noAttic = true, chimney = true, noFrame = true }
  F.planks(wallM, L.timber, 3, true, 41)
  local base = rect(164, 114, 214, 125)
  part(base, L.plaster, { nopop = true }) F.courses(base, 114, 4, 7, L.plaster)
  hline(164, 214, 113, L.timber.edge)
  F.lichen(roofM, .2, 103)
  for _, w in ipairs({ { 172, 99 }, { 189, 91 }, { 206, 99 } }) do local ws = c:ellipse(w[1], w[2], 2, 1) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true }) px(w[1] - 1, w[2] - 1, L.stone.hi) end
  F.door(184, 114, 192, 124, L.timber)
  F.window(171, 106, 176, 110, L.timber) F.window(201, 106, 206, 110, L.timber)
  for x = 170, 177, 2 do px(x, 113, L.apple.base) end for x = 200, 207, 2 do px(x, 113, L.apple.base) end
  F.smoke(205, 74, 6, .7, 2)
  -- washing between the house and a pole
  local wp = rect(132, 106, 133, 124) rimOf(wp, L.timber) part(wp, L.timber, { nopop = true, noshade = true })
  F.washing(133, 106, 163, 108, { { "shirt", L.accent }, { "sock", L.awnA }, { "sheet", L.awnB } }, 3)
end
-- the far cable tower: a larch A-frame on a granite plinth, the sheave at the top, a lantern on the crossbar
local CT = { 226, 86 }   -- far cable end
do -- the ferry bell hangs under its crossbar, a lantern on the other side
  local legs = line({ { 219, 123 }, { 226, 86 } }, 2):add(line({ { 233, 123 }, { 226, 86 } }, 2)):add(rect(219, 102, 233, 103))
  local plinth = rect(216, 119, 235, 125)
  rimOf(union(legs, plinth), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true })
  part(plinth, L.stone, { nopop = true }) F.courses(plinth, 119, 3, 6, L.stone)
  local sh = c:ellipse(226, 86, 2, 2) c:rim(sh, L.iron.edge) fill(sh, L.iron.base) px(225, 85, L.iron.hi)
  local fb = poly{ { 224, 105 }, { 228, 105 }, { 229, 110 }, { 223, 110 } } c:rim(fb, L.timber.edge) part(fb, L.gold, { nopop = true }) px(224, 106, L.gold.hi)
  local lam = rect(229, 105, 232, 110) rimOf(lam, L.timber) fill(lam, L.glow.base) px(230, 106, L.glow.hi) vline(232, 106, 110, L.glow.shade)
end
-- a small gnome waving from the far landing
F.gnome(238, 128, { small = true, hat = L.awnA, coat = L.leaf, arm = "up" })
-- granite boulders along the far waterline
F.depth(2)
for x = 6, 470, 1 do
  if hash(x, 1, 81) < .07 and not (x > 226 and x < 256) and not (x > 378) then
    F.boulder(x, yF(x) + 1, 2 + floor(hash(x, 2, 81) * 3), 2 + floor(hash(x, 3, 81) * 2), x)
    hline(x - 3, x + 3, yF(x) + 2, FOAM)
  end
end
-- reflections of the far bank in the water (broken, milky: glacial water reflects little)
for x = 0, 379 do
  local y0 = yF(x) + 2
  local v = c:get(x, yF(x) - 6)
  if v and hash(x, 1, 31) < .45 then
    for y = y0, y0 + 5, 2 do if river:has(x, y) and hash(x, y, 32) < .5 then px(x, y, mix(v, Wt.base, .62)) end end
  end
end

---------------------------------------------------------------- the river left: a fisher on a midstream rock, a riffle of boulders with dippers
F.depth(2)
do
  riverRock(82, 152, 15, 10, 201)
  local _, hx, hy = F.gnome(80, 143, { small = true, hat = L.roof2, coat = L.awnA, arm = "out", noShadow = true })
  fill(line({ { 88, 136 }, { 114, 120 } }), L.timber.deep)
  vline(114, 121, 148, L.awnB.shade) px(114, 149, L.awnA.base) hline(110, 118, 150, FOAM)
  F.sack(70, 142, L.needle, 3) -- his creel
end
local function dipper(x, yb, flip)
  local rows = { "..dd.....", ".dbbd....", "dbebd...t", "kdWbbd.tt", ".dWWbbbd.", "..dWbbdd.", "...ddd...", "...o.o..." }
  if flip then for i, r in ipairs(rows) do rows[i] = r:reverse() end end
  F.sprite(rows, x - 4, yb - 7, { d = "#4a3a36", b = "#6e5448", W = L.edel.hi, e = L.timber.edge, k = L.iron.deep, t = "#4a3a36", o = L.timber.deep })
end
F.depth(3)
riverRock(140, 147, 9, 6, 211)
riverRock(167, 151, 11, 7, 212)
riverRock(192, 144, 6, 5, 213)
riverRock(214, 152, 5, 4, 214)
dipper(166, 144) dipper(140, 141, true)

---------------------------------------------------------------- the near landing: granite slab quay, bollards with iron rings
F.depth(3)
local LY0, LY1 = 166, 180
do
  local deck = poly{ { F.xl(LY0) - 6, LY0 }, { F.xr(LY0) + 6, LY0 }, { F.xr(LY1) + 6, LY1 }, { F.xl(LY1) - 6, LY1 } }
  local face = rect(floor(F.xl(LY0)) - 6, LY0 - 4, floor(F.xr(LY0)) + 6, LY0 - 1)
  local piles = HP.mask()
  for _, x in ipairs({ floor(F.xl(LY0)) - 7, floor(F.xr(LY0)) + 4 }) do piles:add(c:rrect(x, LY0 - 8, x + 3, LY0 + 4, 1)) end
  rimOf(union(deck, face, piles), L.stone)
  part(deck, L.stone) F.courses(deck, LY0, 4, 9, L.stone)
  deck:each(function(x, y) if hash(x // 9, (y - LY0) // 4, 105) < .25 then if hash(x, y, 106) < .4 then px(x, y, L.stone.hi) end end end)
  F.lichen(deck, .12, 107)
  part(face, L.stone, { nopop = true }) F.courses(face, LY0 - 4, 4, 7, L.stone)
  face:each(function(x, y) if y == LY0 - 1 and hash(x, y, 108) < .5 then px(x, y, L.stone.deep) end end)
  part(piles, L.stone, { nopop = true }) F.lichen(piles, .25, 109)
  for _, x in ipairs({ floor(F.xl(LY0)) - 7, floor(F.xr(LY0)) + 4 }) do
    hline(x - 2, x + 5, LY0 + 5, FOAM) hline(x - 1, x + 4, LY0 + 6, Wt.hi)
    local ring = c:ellipse(x + 1, LY0 - 3, 2, 2):cut(c:ellipse(x + 1, LY0 - 3, 1, 1)) fill(ring, L.iron.deep) px(x, LY0 - 5, L.iron.hi)
  end
  hline(floor(F.xl(LY0)) - 8, floor(F.xr(LY0)) + 8, LY0, L.stone.hi)
end

---------------------------------------------------------------- the ferry raft (centre hero)
local RX0, RX1, RY0, RY1 = 270, 366, 137, 152
local FY = RY1 - 6 -- where figures stand: the front of the deck stays visible
local function hen(x0, y0)
  F.sprite({
    "..........RR.....",
    ".........RRr.....",
    "........HRRr.....",
    ".......HRRRr.....",
    ".......RRRRr.....",
    "......HRRRRRr....",
    "......RRRRRRr....",
    ".....HRRRRRRRr...",
    "....bbbbbbbbbbb..",
    ".....WWWWWW......",
    "....WWeWWWWW.....",
    "..yyWWWWWWWW.....",
    ".yYYkWWWWWWw.....",
    "...kkWWWWWWw...ww",
    "....kWWWWWWw..wWw",
    ".....WWWWWWWwwWWw",
    "....WWWWWWWWWWWWs",
    "....WWwwwWWWWWWWs",
    "....WWWwwwwWWWWs.",
    ".....WWWWwwwWWss.",
    "......sWWWWWsss..",
    "........l...l....",
    "........l...l....",
    ".......ll..ll....",
  }, x0, y0, { R = L.awnA.base, r = L.awnA.shade, H = L.awnA.hi, b = L.gold.hi, W = "#fbf6e6", w = L.awnB.base, s = L.awnB.shade,
    y = L.gold.base, Y = L.gold.shade, k = L.apple.base, e = L.timber.edge, l = L.gold.shade })
end
local function cheese(x, yb, r, h)
  local m = c:rrect(x - r, yb - h, x + r, yb, 2)
  c:rim(m, L.cheese.edge) part(m, L.cheese, { nopop = true })
  hline(x - r + 1, x + r - 1, yb - h, L.cheese.hi) hline(x - r + 1, x + r - 1, yb, L.cheese.deep)
  px(x - 1, yb - h // 2, L.cheese.shade) px(x, yb - h // 2, L.cheese.shade)
  return m
end
local frontPost, backPost = { RX0 + 1, RY1 - 9 }, { RX0 + 5, RY0 - 8 }
do
  -- the raft's broken reflection, quickly torn up by the current; a bow wave piling against the upstream side
  for x = RX0, RX1 do for y = RY1 + 5, RY1 + 12 do
    if river:has(x, y) and (y % 2 == 0) and hash(x // 3, y, 41) < .5 - (y - RY1) * .04 then px(x, y, mix(L.timber.shade, Wt.base, .5)) end
  end end
  for k = 0, 3 do px(RX0 - 2 - k, RY0 + 5 + k * 3, FOAM) hline(RX0 - 7 - k * 3, RX0 - 3 - k * 2, RY0 + 7 + k * 3, k < 2 and FOAM or Wt.hi) end
  for k = 0, 3 do hline(RX0 - 10 - k * 5, RX0 - 2 - k * 2, RY1 + 6 + k * 2, Wt.hi) hline(RX1 + 2 + k * 2, RX1 + 10 + k * 6, RY1 + 6 + k * 2, k == 0 and FOAM or Wt.hi) end
  for x = RX0 - 2, RX1 + 2 do if (x // 3) % 2 == 0 then px(x, RY1 + 5, Wt.deep) px(x, RY1 + 6, Wt.shade) else px(x, RY1 + 5, FOAM) end end
  local deck = poly{ { RX0 + 4, RY0 }, { RX1 - 4, RY0 }, { RX1, RY1 }, { RX0, RY1 } }
  local face = rect(RX0, RY1 + 1, RX1, RY1 + 4)
  local posts = HP.mask()
  for _, x in ipairs({ RX0 + 1, RX1 - 2 }) do posts:add(rect(x, RY1 - 9, x + 1, RY1)) end
  for _, x in ipairs({ RX0 + 5, RX1 - 6 }) do posts:add(rect(x, RY0 - 8, x + 1, RY0)) end
  rimOf(union(deck, face), L.timber)
  part(deck, L.board) F.planks(deck, L.board, 5, true, 17)
  -- sun-silvered larch planks, wet at the edges
  deck:each(function(x, y)
    local v = hash(x // 5, y // 3, 108)
    if v < .22 then px(x, y, ((x % 5) == 0) and L.timber.shade or L.board.hi) end
    if y >= RY1 - 1 and hash(x, y, 109) < .5 then px(x, y, L.timber.base) end
  end)
  hline(RX0 + 4, RX1 - 4, RY0, L.board.hi)
  part(face, L.timber, { nopop = true })
  for x = RX0 + 2, RX1 - 2, 5 do fill(c:ellipse(x, RY1 + 2.5, 1.5, 1.5), L.board.base) px(x, RY1 + 2, L.board.hi) px(x + 1, RY1 + 3, L.board.shade) end
  -- far rail behind the cargo
  for x = RX0 + 6, RX1 - 6 do px(x, RY0 - 6 + floor(2 * sin((x - RX0) / (RX1 - RX0) * pi)), L.board.shade) end
  -- cargo: a stack of cheeses, two milk cans
  cheese(RX1 - 28, RY0 + 8, 5, 4) cheese(RX1 - 18, RY0 + 8, 5, 4) cheese(RX1 - 23, RY0 + 3, 5, 4)
  for _, cx in ipairs({ RX0 + 9, RX0 + 16 }) do
    local ch = c:rrect(cx - 3, RY0 - 4, cx + 3, RY0 + 6, 2):add(rect(cx - 1, RY0 - 6, cx + 1, RY0 - 4))
    c:rim(ch, L.iron.edge) part(ch, L.iron) hline(cx - 3, cx + 3, RY0 - 1, L.iron.deep) px(cx - 2, RY0 - 3, L.iron.hi)
  end
  -- the trunk the hen stands on
  local T0 = RX0 + 40
  local tk = rect(T0, RY0 + 1, T0 + 18, RY0 + 9)
  c:rim(tk, L.timber.edge) part(tk, L.awnA) hline(T0, T0 + 18, RY0 + 4, L.timber.deep) vline(T0 + 6, RY0 + 1, RY0 + 9, L.gold.shade) vline(T0 + 12, RY0 + 1, RY0 + 9, L.gold.shade)
  fill(rect(T0 + 8, RY0 + 4, T0 + 10, RY0 + 6), L.gold.base) px(T0 + 8, RY0 + 4, L.gold.hi)
  -- the traveller with a big bundle on a stick
  local gx = RX0 + 28
  fill(line({ { gx + 7, FY - 17 }, { gx - 9, FY - 23 } }), L.board.base)
  local bun = c:ellipse(gx - 11, FY - 23, 4, 4) c:rim(bun, L.timber.edge) part(bun, L.accent, { nopop = true })
  bun:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.awnB.hi) end end) px(gx - 11, FY - 27, L.accent.deep)
  F.gnome(gx, FY, { hat = L.lav, coat = L.roof2, arm = "up", noShadow = true })
  -- QUIRK: the hen in the red gnome hat, riding on the trunk
  hen(T0 + 1, RY0 - 23)
  -- the ferryman, steadying the raft with a pole from the back right corner
  local _, fx, fy = F.gnome(RX1 - 14, FY, { hat = L.foliage2, coat = L.accent, arm = "up", flip = false, noShadow = true, hatBand = L.gold.base })
  local pole = line({ { fx - 3, fy - 10 }, { fx + 14, RY1 + 16 } }, 1)
  fill(pole, L.board.shade) line({ { fx - 2, fy - 10 }, { fx + 15, RY1 + 16 } }):each(function(x, y) if y < RY1 + 4 then px(x, y, L.board.hi) end end)
  for k = 0, 2 do hline(fx + 10 - k * 3, fx + 18 + k * 3, RY1 + 17 + k * 2, k == 0 and FOAM or Wt.hi) end
  -- near rail and posts in front of everyone
  part(posts, L.timber, { nopop = true, noshade = true })
  for x = RX0 + 2, RX1 - 2 do px(x, RY1 - 7 + floor(2 * sin((x - RX0) / (RX1 - RX0) * pi)), L.board.deep) end
end

---------------------------------------------------------------- near bank: gnome hauling the tow rope on the landing
F.depth(3)
do
  local _, hx, hy = F.gnome(244, 200, { hat = L.roof2, coat = L.board, arm = "up" })
  local x0, y0 = RX0 + 2, RY1 - 8
  local pts = {}
  for xx = hx, x0 do local t = (xx - hx) / (x0 - hx) pts[#pts + 1] = { xx, floor(hy + (y0 - hy) * t + 9 * 4 * t * (1 - t) + .5) } end
  local rope = line(pts, 2)
  c:rim(rope, L.timber.edge)
  rope:each(function(x, y) local top = not rope:has(x, y - 1) px(x, y, top and L.board.hi or L.board.base) if (x + y) % 3 == 0 then px(x, y, L.board.shade) end end)
  for _, p in ipairs(pts) do if p[2] > yN(p[1]) - 3 and p[1] % 5 == 0 then px(p[1], p[2] + 2, GLINT) end end -- drips where it skims the water
  local coil = c:ellipse(232, 200, 6, 2) c:rim(coil, L.timber.edge) part(coil, L.board, { nopop = true }) c:ellipse(232, 200, 3, 1):edge():each(function(x, y) px(x, y, L.board.deep) end)
  local tail = line({ { hx - 1, hy + 1 }, { 236, 198 } }, 2) c:rim(tail, L.timber.edge) fill(tail, L.board.base) tail:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.board.shade) end end)
end

---------------------------------------------------------------- the near cable mast and the cable over the river
local CN = { 285, 150 }  -- near cable end
do
  local legs = line({ { 277, 206 }, { 285, 150 } }, 2):add(line({ { 293, 206 }, { 285, 150 } }, 2)):add(rect(279, 178, 291, 179))
  local foot = rect(272, 202, 298, 210)
  F.shadow(274, 298, 210, 8, 3)
  rimOf(union(legs, foot), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true })
  legs:each(function(x, y) if hash(x, y // 3, 141) < .2 then px(x, y, L.timber.deep) end end)
  part(foot, L.stone, { nopop = true }) F.courses(foot, 202, 4, 8, L.stone) F.lichen(foot, .2, 142)
  hline(272, 298, 202, L.stone.hi)
  -- the windlass drum on the crossbar, wound with rope, a crank
  local drum = c:rrect(280, 180, 290, 186, 2) rimOf(drum, L.timber) part(drum, L.board, { nopop = true })
  for x = 281, 289, 2 do vline(x, 181, 185, L.board.shade) end
  fill(line({ { 291, 183 }, { 296, 187 } }), L.iron.base) fill(rect(296, 187, 297, 190), L.timber.base)
  -- the sheave at the top and a lantern hung off a short arm
  local sh = c:ellipse(CN[1], CN[2], 2, 2) c:rim(sh, L.iron.edge) fill(sh, L.iron.base) px(CN[1] - 1, CN[2] - 1, L.iron.hi)
  local arm = rect(286, 156, 295, 157) rimOf(arm, L.timber) part(arm, L.timber, { nopop = true, noshade = true })
  vline(294, 158, 159, L.iron.deep)
  local lam = rect(291, 160, 297, 168) rimOf(lam, L.timber) fill(lam, L.glow.base) fill(rect(292, 161, 293, 166), L.glow.hi) vline(297, 161, 168, L.glow.shade)
  fill(rect(290, 159, 298, 159), L.timber.base) fill(rect(292, 169, 296, 169), L.timber.base)
  -- the cable: from the far tower down to the mast, a sheen on the near half; a pulley block riding on it,
  -- the bridle running down to the raft's two left posts
  local cab = HP.mask()
  local n = 200
  local P = {}
  for i = 0, n do
    local t = i / n
    local x = CT[1] + (CN[1] - CT[1]) * t
    local y = CT[2] + (CN[2] - CT[2]) * t + 6 * 4 * t * (1 - t)
    P[i] = { floor(x + .5), floor(y + .5) }
    cab:set(P[i][1], P[i][2])
    if t > .35 then cab:set(P[i][1], P[i][2] + 1) end
  end
  cab:each(function(x, y) px(x, y, (cab:has(x, y + 1) and not cab:has(x, y - 1) and x % 3 ~= 0) and L.iron.base or L.iron.edge) end)
  local pb = P[floor(n * .6)]
  for _, tgt in ipairs({ { frontPost[1] + 1, frontPost[2] }, { backPost[1] + 1, backPost[2] } }) do
    line({ { pb[1], pb[2] + 3 }, tgt }):each(function(x, y) px(x, y, L.board.shade) end)
  end
  local blk = rect(pb[1] - 2, pb[2] - 1, pb[1] + 2, pb[2] + 3) c:rim(blk, L.iron.edge) fill(blk, L.timber.base) px(pb[1] - 1, pb[2], L.timber.hi)
  fill(rect(pb[1] - 1, pb[2] - 2, pb[1] + 1, pb[2] - 1), L.iron.base) px(pb[1], pb[2] + 2, L.iron.hi)
end

-- a young larch and a spruce at the left of the near bank (behind the booth)
F.depth(3)
F.tree(28, 196, 40, 0)
F.larch(104, 186, 26, 132)

DY = 10
---------------------------------------------------------------- near bank left: bell frame, ferry sign, booth, bench, rowboat
do -- the ferry bell on a frame under a little slab roof
  local fr = rect(186, 150, 187, 196):add(rect(206, 150, 207, 196)):add(rect(183, 148, 210, 150))
  F.shadow(186, 208, 197, 6, 3)
  rimOf(fr, L.timber) part(fr, L.timber, { nopop = true, noshade = true }) hline(183, 210, 148, L.timber.hi)
  local roofb = poly{ { 181, 148 }, { 196, 140 }, { 212, 148 } } rimOf(roofb, L.roof) part(roofb, L.roof, { nopop = true })
  F.courses(roofb, 140, 3, 5, L.roof) F.lichen(roofb, .25, 114)
  local ws = c:ellipse(196, 140, 2, 1) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true })
  vline(196, 151, 153, L.iron.shade)
  local bell = poly{ { 193, 154 }, { 199, 154 }, { 201, 163 }, { 203, 165 }, { 189, 165 }, { 191, 163 } }:add(c:ellipse(196, 155, 3, 2))
  c:rim(bell, L.timber.edge) part(bell, L.gold) vline(193, 156, 163, L.gold.hi) hline(190, 202, 164, L.gold.shade)
  fill(rect(195, 166, 197, 167), L.iron.base)
  fill(line({ { 197, 167 }, { 199, 180 } }), L.board.shade)
end
do -- the ferry sign: a painted raft on a cable, a snowy peak and a wavy river
  local post = rect(170, 168, 171, 200)
  local bd = rect(156, 152, 185, 168)
  rimOf(union(post, bd), L.timber) part(post, L.timber, { nopop = true }) part(bd, L.board, { nopop = true })
  c:edgeIn(bd, L.board.deep)
  F.sprite({ "...w....", "..wWs...", ".wSSss..", ".SSSsss.", "SSSSssss" }, 158, 154, { w = L.snow.hi, W = L.snow.base, s = L.peak.shade, S = L.peak.base }, { rim = false })
  for x = 159, 182 do px(x, 164 + floor(sin(x / 2) + .5), L.water.base) px(x, 165 + floor(sin(x / 2) + .5), L.water.shade) end
  fill(rect(166, 160, 182, 162), L.timber.base) hline(166, 182, 160, L.board.hi)
  vline(170, 156, 159, L.timber.edge) vline(179, 156, 159, L.timber.edge) fill(rect(173, 156, 176, 159), L.awnA.base)
  line({ { 166, 154 }, { 183, 157 } }):each(function(x, y) px(x, y, L.iron.deep) end)
end
F.depth(3)
do -- the ticket booth: whitewashed granite below, larch boards above, slab roof with stones; a gnome in the hatch
  local wall = rect(38, 168, 92, 200)
  local roof = poly{ { 32, 170 }, { 65, 146 }, { 98, 170 } }:add(rect(32, 168, 98, 171))
  F.shadow(40, 92, 200, 10, 4)
  rimOf(union(wall, roof), L.timber)
  part(wall, L.timber) F.planks(rect(38, 168, 92, 185), L.timber, 4, true, 3)
  local foot = rect(38, 186, 92, 200)
  part(foot, L.plaster, { nopop = true }) F.courses(foot, 186, 4, 7, L.plaster)
  foot:each(function(x, y) if hash(x // 3, y // 3, 12) < .14 then px(x, y, L.stone.base) end end)
  hline(38, 92, 185, L.timber.edge)
  part(roof, L.roof, { sep = true }) F.courses(roof, 146, 3, 5, L.roof)
  F.lichen(roof, .2, 116)
  line({ { 32, 170 }, { 65, 146 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  for _, w in ipairs({ { 48, 160 }, { 65, 150 }, { 82, 160 } }) do local ws = c:ellipse(w[1], w[2], 3, 2) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true }) px(w[1] - 1, w[2] - 1, L.stone.hi) end
  -- hatch with awning
  local hatch = rect(50, 178, 80, 192)
  fill(hatch, L.soil.deep) c:edgeIn(hatch, L.timber.hi)
  fill(rect(51, 179, 56, 183), L.glow.shade) px(52, 180, L.glow.base) -- a lamp lit inside
  F.gnome(65, 198, { hat = L.awnA, coat = L.accent, arm = "out", noShadow = true })
  local sill = rect(48, 192, 82, 194) rimOf(sill, L.timber) part(sill, L.board, { nopop = true })
  fill(rect(76, 189, 78, 191), L.awnB.hi) px(77, 189, L.awnA.base) -- a ticket
  local aw = poly{ { 46, 172 }, { 84, 172 }, { 88, 178 }, { 42, 178 } }
  rimOf(aw, L.awnA) fill(aw, L.awnA.base)
  aw:each(function(x, y) if ((x - 42) // 5) % 2 == 1 then px(x, y, L.awnB.base) end if y == 178 then px(x, y, ((x // 3) % 2 == 0) and L.awnA.deep or L.awnA.shade) end end)
  hline(46, 84, 172, L.awnA.hi)
  F.window(86, 158, 88, 161, L.timber)
  -- an edelweiss plaque in the gable
  local pl = c:ellipse(65, 162, 3, 3) rimOf(pl, L.timber) part(pl, L.board, { nopop = true })
  F.edelweiss(65, 162, true)
  -- geraniums on the sill ends
  for x = 49, 55, 2 do px(x, 191, L.apple.base) px(x + 1, 191, L.leaf.base) end
end
do -- bench with two waiting travellers and their luggage
  F.gnome(112, 214, { hat = L.roof2, coat = L.lav, arm = "hold", noShadow = true })
  F.gnome(134, 215, { hat = L.accent, coat = L.awnA, flip = true, noShadow = true })
  local seat = rect(100, 207, 146, 209)
  local legs = rect(103, 210, 104, 218):add(rect(142, 210, 143, 218))
  F.shadow(102, 146, 219, 8, 3)
  rimOf(union(seat, legs), L.timber) part(legs, L.timber, { nopop = true, noshade = true }) part(seat, L.board, { nopop = true }) hline(100, 146, 207, L.board.hi)
  local tr = c:rrect(150, 204, 168, 218, 3):clip(rect(150, 204, 168, 218))
  F.shadow(150, 168, 219, 5, 2)
  rimOf(tr, L.timber) part(tr, L.redbark) hline(150, 168, 209, L.iron.base) vline(155, 204, 218, L.iron.shade) vline(163, 204, 218, L.iron.shade) px(159, 211, L.glow.hi)
  local bag = c:rrect(152, 222, 166, 232, 3) rimOf(bag, L.timber) part(bag, L.lav)
  bag:each(function(x, y) if (x + y) % 4 == 0 then px(x, y, L.lav.hi) end end)
  fill(c:ellipse(159, 221, 3, 2):cut(c:ellipse(159, 221, 1, 1)):clip(rect(150, 218, 168, 221)), L.timber.base)
  -- an alpenstock leaning on the bench
  fill(line({ { 96, 218 }, { 102, 192 } }), L.board.shade) px(102, 191, L.iron.hi) px(96, 219, L.iron.base)
end
do -- a rowboat pulled up on the gravel, oars across it
  local y = 228
  local hull = poly{ { 18, y - 4 }, { 24, y }, { 76, y + 2 }, { 82, y - 3 }, { 74, y + 9 }, { 26, y + 8 } }
  local inside = c:ellipse(50, y - 1, 26, 2)
  F.shadow(24, 78, y + 10, 6, 3)
  rimOf(union(hull, inside), L.timber)
  part(hull, L.accent) hline(24, 76, y + 4, L.awnB.base) hline(26, 74, y + 5, L.awnB.shade)
  fill(inside, L.timber.shade) c:edgeIn(inside, L.board.base)
  fill(line({ { 30, y - 5 }, { 74, y + 1 } }), L.board.base) fill(rect(72, y - 1, 78, y + 1), L.board.base)
end
DY = 0
-- near sedge and cotton grass on both sides of the landing
sedge(214, yN(214) + 3, 14, 20, 3, true)
sedge(120, yN(120) + 3, 12, 16, 5, true)
sedge(392, yN(392) + 3, 14, 20, 7, true)
sedge(452, yN(452) + 3, 10, 18, 9, true)
sedge(20, yN(20) + 3, 8, 14, 11, true)

---------------------------------------------------------------- the river right: rocks in the chute, a moored punt
F.depth(3)
riverRock(372, 171, 7, 5, 221)
riverRock(404, 161, 10, 6, 222)
riverRock(450, 151, 9, 6, 223)
DY = 8
do -- a larch punt tied to a stake
  local y = 178
  local hull = poly{ { 420, y - 2 }, { 470, y - 2 }, { 466, y + 4 }, { 424, y + 4 } }
  rimOf(hull, L.timber) part(hull, L.board) hline(422, 468, y, L.board.deep)
  F.planks(hull, L.board, 3, false, 118)
  for k = 0, 2 do hline(424 + k * 2, 466 - k * 2, y + 6 + k * 2, k == 0 and FOAM or Wt.shade) end
  local st = rect(410, y - 12, 412, y + 6) rimOf(st, L.timber) part(st, L.timber, { nopop = true, noshade = true })
  fill(line({ { 412, y - 8 }, { 422, y - 1 } }), L.board.shade)
  hline(407, 415, y + 7, FOAM)
end

---------------------------------------------------------------- near bank right: cheeses and sacks waiting to cross, a gnome with an apple
F.depth(3)
do
  F.crate(300, 222, 18, 12) F.crate(318, 222, 16, 12)
  cheese(305, 209, 5, 4) cheese(316, 209, 5, 4) cheese(310, 204, 5, 4)
  local can = c:rrect(326, 200, 332, 210, 2):add(rect(328, 198, 330, 200)) c:rim(can, L.iron.edge) part(can, L.iron) hline(326, 332, 203, L.iron.deep) px(327, 201, L.iron.hi)
  F.sack(342, 224, L.awnB, 7) F.sack(354, 226, L.board, 6)
  F.barrel(290, 226, L.timber, 12)
  local _, hx, hy = F.gnome(372, 236, { hat = L.lav, coat = L.leaf, arm = "out", flip = true })
  local ap = c:ellipse(hx - 1, hy - 2, 2, 2) c:rim(ap, L.timber.edge) part(ap, L.apple, { nopop = true }) px(hx - 1, hy - 5, L.leaf.base)
end
DY = 0
-- foreground: a barrow of split larch firewood waiting for the ferry, boulders, junipers and alpine flowers
do
  local y = 250
  local tray = poly{ { 96, y - 12 }, { 132, y - 12 }, { 128, y - 2 }, { 100, y - 2 } }
  local legs = rect(102, y - 2, 103, y + 4):add(line({ { 132, y - 8 }, { 146, y - 2 } }, 2))
  local wh = c:ellipse(92, y, 5, 5)
  F.shadow(92, 132, y + 5, 8, 3)
  rimOf(union(tray, legs, wh), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true })
  part(tray, L.board) F.planks(tray, L.board, 5, true, 2)
  part(wh, L.timber, { nopop = true }) px(92, y, L.iron.hi) hline(88, 96, y, L.timber.deep)
  for k = 0, 3 do F.logEnd(104 + k * 7, y - 15, 3, k == 2 and L.redbark or nil) end
  for k = 0, 2 do F.logEnd(107 + k * 7, y - 21, 3, k == 1 and L.redbark or nil) end
  F.logEnd(111, y - 27, 3) F.logEnd(118, y - 27, 3, L.redbark)
end
F.boulder(162, 256, 10, 8, 121) F.boulder(176, 258, 5, 4, 122)
F.boulder(70, 256, 7, 5, 123)
F.boulder(212, 262, 6, 4, 124)
F.juniper(30, 218, 9, 5, 125) F.juniper(266, 216, 7, 4, 126) F.juniper(196, 248, 7, 4, 127)
for _, f in ipairs({ { 36, 212 }, { 148, 244 }, { 186, 240 }, { 274, 222 }, { 60, 262 }, { 290, 252 }, { 330, 258 }, { 222, 220 }, { 92, 222 } }) do F.edelweiss(f[1], f[2], true) end
for _, f in ipairs({ { 42, 214 }, { 152, 247 }, { 192, 242 }, { 280, 224 }, { 66, 264 }, { 296, 256 }, { 336, 262 }, { 300, 240 }, { 362, 214 } }) do F.gentian(f[1], f[2], true) end
for _, f in ipairs({ { 50, 250 }, { 140, 262 }, { 238, 260 }, { 320, 246 }, { 254, 222 } }) do
  local x, yb = f[1], f[2]
  for k = -2, 2 do local h = 3 + (2 - abs(k)) * 2 vline(x + k * 2, yb - h, yb, L.fern.shade) px(x + k * 2, yb - h, L.fern.hi) px(x + k * 2 + 1, yb - 1, L.fern.deep) end
end

---------------------------------------------------------------- bank turf, a fisher gnome, a goat after the apple
DY = 0
F.depth(3)
-- turf overhanging the near ledge, with pebbles
for x = 0, 479 do
  local yn = yN(x)
  if hash(x, 1, 91) < .45 and not F.roadM:has(x, yn + 7) and not (x > 190 and x < 300) then
    local h = 2 + floor(hash(x, 2, 91) * 3)
    vline(x, yn + 7 - h, yn + 7, L.fern.deep) px(x, yn + 7 - h, L.fern.base) if h > 3 then px(x, yn + 6 - h, L.fern.hi) end
  end
  if hash(x, 3, 91) < .04 then px(x, yn + 8, L.stone.base) px(x + 1, yn + 8, L.stone.shade) px(x, yn + 7, L.stone.hi) end
end
-- a fisher gnome on an upturned bucket at the right bank, rod out over the sedge, a catch in the creel
do
  local bk = poly{ { 410, 210 }, { 422, 210 }, { 420, 220 }, { 412, 220 } }
  F.shadowM(c:ellipse(418, 222, 10, 1))
  rimOf(bk, L.timber) part(bk, L.board) hline(410, 422, 213, L.iron.shade) hline(411, 421, 218, L.iron.shade)
  local _, hx, hy = F.gnome(416, 210, { hat = L.awnA, coat = L.wall2, arm = "up", flip = true, noShadow = true, hatBand = L.gold.base })
  local rod = line({ { hx, hy + 2 }, { 380, 176 } })
  fill(rod, L.timber.shade) px(380, 176, L.timber.deep)
  for y = 177, 190 do px(380 - floor((y - 177) * .2), y, L.awnB.shade) end
  px(377, 191, L.apple.base) px(377, 190, GLINT) hline(372, 382, 192, FOAM)
  local cr = c:rrect(428, 212, 442, 222, 2) rimOf(cr, L.timber) part(cr, L.needle)
  cr:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) end end)
  F.sprite({ "s..s", "sSSs", ".SS.", ".ss." }, 433, 206, { s = L.iron.hi, S = L.iron.base })
  F.gentian(446, 220, true) F.edelweiss(450, 222, true)
end
-- a goat stretching its neck at the gnome's apple
F.goat(344, 242, { k = .72 })
px(352, 229, L.awnA.base) px(353, 228, L.awnA.base) px(352, 230, L.gold.hi) -- a red collar, brass bell

DY = 0
F.depth(0)
F.birds({ { 150, 58, 2 }, { 162, 52, 1 }, { 340, 40, 2 }, { 352, 46, 2 }, { 200, 70, 1 } })
F.finish()
