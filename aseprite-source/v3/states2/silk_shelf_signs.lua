-- silk_shelf: EMPTY state only (craft pass on the BUILD sign). 64x64, anchor (32,54).
local S = dofile("/tmp/ase/states2/q4signs_common.lua")
local K, HP, P = S.K, S.HP, S.P
local px, R = S.px, S.R
local lerp = K.lerp
local out = app.params.out or "/tmp/ase/states2/silk_shelf/"
local W, H, AX, AY = 64, 64, 32, 54
local c

local SILK = { hi = P.cream, base = "#f7e9c6", shade = "#e8d2a2", deep = "#cdb07e", line = "#efdcb2" }
local LEAF = {
  "..ll.gg...",
  ".lggmggg..",
  "lgggmggggs",
  ".ggggmggs.",
  "..gggmgs..",
  "...ggms...",
  "....s.....",
}
local LEAFMAP = { l = P.moss.hi, g = P.moss.base, m = P.moss.deep, s = P.moss.shade }

local function spool(sw)
  local x0, x1 = 15, 47           -- flange span
  local bx0, bx1 = 19, 43         -- silk body span (25 wide)
  local top = 15
  local function rows(spec, y)
    local m = HP.mask()
    for i, ins in ipairs(spec) do for x = x0 + ins, x1 - ins do m:set(x, y + i - 1) end end
    return m
  end
  local fT = rows({ 4, 1, 0, 0, 1 }, top)
  local body = c:rect(bx0, top + 5, bx1, top + 22)
  local fB = rows({ 0, 0, 0, 1, 4 }, top + 23)
  local pegT = c:rect(30, top - 3, 31, top - 1):add(c:rect(29, top - 4, 32, top - 4))
  local pegB = c:rect(30, top + 28, 31, 49)
  -- loose silk end swinging off the right side
  local tail = HP.mask()
  local tp = { { bx1 + 1, top + 19 }, { 46, top + 20 }, { 49, top + 22 }, { 49 + sw, top + 27 }, { 49 + sw, top + 31 } }
  for i = 1, #tp - 1 do tail:add(c:line({ tp[i], tp[i + 1] }, 1)) end
  K.ink(fT, body, fB, pegT, pegB, tail)
  -- spindle peg (wood), knob on top
  c:fillMask(pegB, P.wood.base) R(30, top + 28, 30, 49, P.wood.hi) px(31, 49, P.wood.deep) px(31, top + 28, P.wood.deep)
  c:fillMask(pegT, P.wood.base) R(29, top - 4, 31, top - 4, P.wood.hi) px(30, top - 3, P.wood.hi) px(31, top - 1, P.wood.shade)
  -- silk body: a wound cylinder, lit left, shaded right, flange shadow under the top flange
  c:fillMask(body, SILK.base)
  R(bx0, top + 5, bx0 + 1, top + 22, SILK.hi)
  R(bx1 - 3, top + 5, bx1, top + 22, SILK.shade) R(bx1, top + 5, bx1, top + 22, SILK.deep)
  R(bx0, top + 5, bx1, top + 5, SILK.shade) R(bx1 - 3, top + 5, bx1, top + 5, SILK.deep)
  -- winding lines in the margins only (never through the word or icon)
  for y = top + 6, top + 21 do
    if (y - top) % 2 == 0 then px(bx0, y, SILK.line) px(bx1 - 2, y, SILK.deep) end
  end
  for _, y in ipairs{ top + 6 } do for x = bx0 + 2, bx1 - 4, 2 do px(x, y, SILK.line) end end
  -- a gold cross-wound band (the stitch spice) on the lowest wraps
  R(bx0, top + 21, bx1, top + 22, SILK.shade)
  for x = bx0, bx1 - 1, 3 do px(x, top + 21, P.gold.base) px(x + 1, top + 22, P.gold.shade) end
  -- icon (mulberry leaf with a berry) and lettering
  K.sprite(LEAF, 26, top + 7, LEAFMAP, true)
  px(36, top + 11, P.dusk.deep) px(37, top + 11, P.dusk.shade) px(36, top + 12, P.dusk.shade) px(37, top + 12, P.dusk.deep) px(36, top + 10, P.dusk.hi)
  S.text(22, top + 15, P.ink, SILK.shade)
  -- top flange: a wooden disc seen from above: lit face with spindle hole, then the rim
  c:fillMask(fT, P.wood.hi)
  R(x0, top + 2, x1, top + 2, lerp(P.wood.hi, P.wood.base, .5))
  R(26, top + 1, 35, top + 1, lerp(P.wood.hi, P.wood.base, .5))
  R(29, top + 1, 32, top + 1, P.wood.deep) px(30, top + 1, P.wood.base) px(31, top + 1, P.wood.base)
  R(x0, top + 3, x1, top + 3, P.wood.base) R(x0 + 1, top + 4, x1 - 1, top + 4, P.wood.shade)
  R(x1 - 4, top + 3, x1, top + 3, P.wood.shade) R(x1 - 4, top + 4, x1 - 1, top + 4, P.wood.deep)
  px(x0 + 2, top + 3, P.wood.hi)
  -- bottom flange: rim only, curving under
  c:fillMask(fB, P.wood.base)
  R(x0, top + 23, x1, top + 23, P.wood.hi)
  R(x0 + 1, top + 26, x1 - 1, top + 26, P.wood.shade) R(x0 + 4, top + 27, x1 - 4, top + 27, P.wood.deep)
  R(x1 - 4, top + 24, x1, top + 25, P.wood.shade) R(x1 - 4, top + 26, x1 - 1, top + 26, P.wood.deep)
  -- tiny brass tack pinning the silk end
  px(bx1 + 1, top + 18, P.gold.hi)
  c:fillMask(tail, SILK.hi)
  tail:each(function(x, y) if y > top + 26 then px(x, y, SILK.base) end end)
end

local function moth(x, y, up)
  local rows = up and { "c...c", "cc.cc", ".cbc." } or { ".cbc.", "cc.cc", "c...c" }
  K.sprite(rows, x, y, { c = P.cream, b = P.wood.shade })
  if up then px(x + 2, y + 1, P.wood.deep) end
end

local function drawEmpty(k)
  c = S.new(W, H, "silk_shelf"); S.c = c
  S.plot(10, 43, 54, 60, 7)
  S.footprint(16, 46, 47, 13, 49, 56, 5)
  -- fallen mulberries, pebbles, tufts, flowers
  for _, b in ipairs{ { 21, 52 }, { 40, 50 }, { 43, 55 } } do
    px(b[1], b[2], P.dusk.shade) px(b[1] + 1, b[2], P.dusk.deep) px(b[1], b[2] - 1, P.dusk.hi)
  end
  S.pebble(25, 55, true) S.pebble(36, 47)
  S.tuft(9, 52) S.tuft(53, 54) S.tuft(31, 60) S.tuft(18, 44)
  S.flower(8, 55, P.cream, P.gold.base, 1)
  S.flower(56, 50, P.dusk.hi, P.gold.hi, -1)
  -- cool shadow of the spool on the soil
  R(32, 49, 37, 49, S.SHADOW) R(33, 50, 35, 50, S.SHADOW)
  spool(({ 0, 1, 1, 0 })[k])
  -- life: a silk moth flutters around the spool
  local mp = { { 51, 15 }, { 53, 12 }, { 55, 14 }, { 53, 17 } }
  moth(mp[k][1], mp[k][2], k % 2 == 1)
  return c
end

local fr = {}
for k = 1, 4 do fr[k] = drawEmpty(k) end
S.saveStrip(out, "silk_shelf", fr, W, H)
