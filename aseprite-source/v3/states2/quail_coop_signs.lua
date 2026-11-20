-- quail_coop: EMPTY state only (craft pass on the BUILD sign). 64x56, anchor (32,46).
local S = dofile("/tmp/ase/states2/q4signs_common.lua")
local K, HP, P = S.K, S.HP, S.P
local px, R = S.px, S.R
local out = app.params.out or "/tmp/ase/states2/quail_coop/"
local W, H, AX, AY = 64, 56, 32, 46
local sqrt, floor = math.sqrt, math.floor
local c

local EGG = { hi = P.cream, base = "#f6e3b4", shade = "#e8c995", edge = "#c9975f", edged = "#9c6a44" }
local NEST = {
  "..ooo.ooo..",
  ".ohheohheo.",
  ".oekeoekeo.",
  "gGgGgGgGgGg",
  "dgGgGgGgGgd",
  ".dgdgdgdgd.",
  "..ddddddd..",
}
local NESTMAP = { o = P.wood.shade, h = P.cream, e = "#f2d8a8", k = P.wood.deep, g = P.gold.base, G = P.gold.shade, d = P.wood.deep }

-- upright egg, pointed end up; (x0,y0) top-left, w x h
local function eggMask(x0, y0, w, h)
  local m = HP.mask()
  local a, b = w / 2, h / 2
  local cx, cy = x0 + a - .5, y0 + b - .5
  for y = y0, y0 + h - 1 do for x = x0, x0 + w - 1 do
    local v = (y - cy) / b
    local hw = a * (1 + .2 * v)                  -- wider toward the bottom (blunt) end
    local u = (x - cx) / hw
    if u * u + v * v <= 1.03 then m:set(x, y) end
  end end
  return m
end

local QR = { ".....DD.", "..HHHBBB", ".HBBBBeg", "HBcBBBww", "BBBcSSww", ".SSSSSS." }
local QMAP = { B = "wood.base", H = "wood.hi", S = "wood.shade", D = "wood.deep", g = "gold.base", e = P.ink, c = P.cream, w = "#f6dfae" }

local function sign(dx)
  local w, h = 26, 27
  local x0, y0 = AX - 13 + dx, 6
  local plate = eggMask(x0, y0, w, h)
  local thick = plate:shift(1, 1):add(plate:shift(2, 1)):cut(plate)
  -- stick: from the fixed foot (AX-1..AX, 43) up behind the plate (leans with the sway)
  local stick = HP.mask()
  local footy, topy = 43, y0 + h - 3
  for y = topy, footy do
    local sx = AX - 1 + ((y < topy + 6) and dx or 0)
    stick:set(sx, y):set(sx + 1, y)
  end
  K.ink(stick, plate, thick)
  c:fillMask(stick, P.wood.base)
  stick:each(function(x, y) if not stick:has(x - 1, y) then px(x, y, P.wood.hi) end end)
  px(AX - 1, footy, P.wood.shade) px(AX, footy, P.wood.deep)
  -- board thickness (lower-right edge of the cut board)
  c:fillMask(thick, EGG.edge)
  thick:each(function(x, y) if not thick:has(x, y + 1) then px(x, y, EGG.edged) end end)
  -- painted face: base, lit upper-left crescent, shade lower-right crescent
  local cx, cy = x0 + w / 2, y0 + h / 2
  plate:each(function(x, y)
    local u, v = (x - cx) / (w / 2), (y - cy) / (h / 2)
    local col = EGG.base
    if u * -0.6 + v * -0.8 > .55 then col = EGG.hi elseif u * 0.6 + v * 0.8 > .62 then col = EGG.shade end
    px(x, y, col)
  end)
  -- quail-egg blotches, kept out of the lettering / icon zones
  local tx, ty = x0 + 4, y0 + 14            -- word box (19x5)
  local ix, iy = AX - 5 + dx, y0 + 5        -- nest icon box (11x7)
  local function clear(x, y)
    if x >= tx - 2 and x <= tx + 20 and y >= ty - 2 and y <= ty + 6 then return false end
    if x >= ix - 1 and x <= ix + 11 and y >= iy - 1 and y <= iy + 7 then return false end
    return plate:has(x, y) and plate:has(x + 1, y) and plate:has(x, y + 1) and plate:has(x - 1, y) and plate:has(x, y - 1)
  end
  local blot = { { 9, 1, 1 }, { 15, 2, 0 }, { 4, 7, 2 }, { 19, 6, 2 }, { 2, 12, 0 }, { 23, 11, 0 }, { 4, 21, 2 }, { 18, 22, 2 }, { 10, 24, 0 }, { 22, 19, 0 } }
  for _, b in ipairs(blot) do
    local bx, by = x0 + b[1], y0 + b[2]
    if clear(bx, by) then
      px(bx, by, P.wood.shade)
      if b[3] >= 1 and clear(bx + 1, by) then px(bx + 1, by, P.wood.shade) end
      if b[3] >= 2 and clear(bx, by + 1) and clear(bx + 1, by + 1) then px(bx, by + 1, P.wood.deep) px(bx + 1, by + 1, P.wood.shade) end
    end
  end
  -- nest icon and lettering (dark ink on the pale shell, a soft engraved shadow)
  K.sprite(NEST, ix, iy, NESTMAP, true)
  S.text(tx, ty, P.ink, EGG.shade)
  -- two nail heads where the stick is fixed (below the word, clear of it)
  local ny = y0 + h - 3
  px(AX - 1 + dx, ny, P.stone.shade) px(AX + dx, ny, P.stone.deep)
  px(AX - 1 + dx, ny - 1, P.stone.hi)
end

local function drawEmpty(k)
  c = S.new(W, H, "quail_coop"); S.c = c
  S.plot(10, 36, 54, 51, 3)
  -- staked footprint of the coop
  S.footprint(16, 46, 39, 13, 49, 48, 5)
  -- pebbles, straw, tufts, flowers
  S.pebble(25, 45, true) S.pebble(41, 46) S.pebble(36, 39)
  px(25, 47, P.gold.hi) px(26, 47, P.gold.base) px(27, 46, P.gold.hi)
  px(44, 42, P.gold.base) px(45, 42, P.gold.hi)
  S.tuft(9, 44) S.tuft(53, 46) S.tuft(30, 51) S.tuft(18, 36)
  S.flower(8, 47, P.cream, P.gold.base, 1)
  S.flower(56, 42, P.petal.hi, P.petal.shade, -1)
  -- sign shadow on the soil (cool, lower right)
  R(AX + 1, 43, AX + 6, 43, S.SHADOW) R(AX + 2, 44, AX + 4, 44, S.SHADOW)
  sign(({ 0, 1, 1, 0 })[k])
  -- life: a quail hops across the plot
  local hy = ({ 0, -2, -3, -1 })[k]
  local qx = 15
  if hy == 0 then R(qx + 1, 45, qx + 6, 45, S.SHADOW) else R(qx + 2, 45, qx + 5, 45, S.SHADOW) end
  K.sprite(QR, qx, 39 + hy, QMAP)
  return c
end

local fr = {}
for k = 1, 4 do fr[k] = drawEmpty(k) end
S.saveStrip(out, "quail_coop", fr, W, H)
