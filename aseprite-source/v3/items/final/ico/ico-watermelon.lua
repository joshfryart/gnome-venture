-- ico-watermelon (final pass, Opus aR1_0). A slim upright wedge slice, gently tilted: juicy red cut face lit per
-- pixel (rounded cut edges, 6 tones, crystalline grain flecks), a pale white-green inner rind, a light green band and
-- a dark striped skin, plus a visible slice thickness (darker side face + rind) on the right. One row of glossy
-- teardrop seeds points at the tip, each with a glint; a drip of juice hangs from the right edge.
-- quirk: someone has already taken a bite out of the tip (scalloped tooth marks, paler bitten flesh).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aR1_0.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs, sin, cos, atan = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.atan
local c = A.new("ico-watermelon")

local FL   = { "#6a1c35", "#a2283d", "#d23a45", "#ee5753", "#ff8574", "#ffbfa6" }
local PALE = { "#bcc98c", "#dfe7b0", "#f4f6cf" }
local LG   = { "#5aa64e", "#86c75c", "#b2dd78" }
local SKIN = { "#132f2c", "#1d473c", "#2a6346", "#3d8250" }
local SEED = { "#2b1c26", "#4a2c2e", "#7a5244" }
local CREAM = A.CREAM
local ftok, rtok, stok = { r = { name = "flesh" } }, { r = { name = "rind" } }, { r = { name = "seed" } }

local AX, AY, R, SPAN, TILT = 30.5, 6, 46, 0.33, 0.06
local function polar(x, y, ax, ay)
  local vx, vy = x + 0.5 - ax, y + 0.5 - ay
  return sqrt(vx*vx + vy*vy), atan(vx, vy) - TILT
end
local function sector(ax, ay, rr)
  local m = HP.mask()
  for y = 0, 63 do for x = 0, 63 do
    local r, a = polar(x, y, ax, ay)
    -- rind arc slightly flattened so the bottom reads as a curve, not a fan
    if r <= rr and abs(a) <= SPAN then m:set(x, y) end
  end end
  return m
end
local front = sector(AX, AY, R)
local BX, BY = AX + 3, AY + 1.5
local back = sector(BX, BY, R):cut(front)

-- bite: scallops cut from the tip
local bite = c:ellipse(30.5, 5.5, 2, 2):add(c:ellipse(37.4, 15.5, 3.3, 3.3)):add(c:ellipse(38.6, 21.4, 3.1, 3.1)):add(c:ellipse(39.6, 26.6, 2.2, 2.2))
front:cut(bite) back:cut(bite):cut(bite:shift(3, 1))

-- slice thickness (side face), darker
back:each(function(x, y)
  local r = polar(x, y, BX, BY)
  local col
  if r > R - 2.2 then col = ((floor(x * 0.7 - y * 0.35) % 3) == 0) and SKIN[1] or SKIN[2]
  elseif r > R - 4.6 then col = LG[1]
  elseif r > R - 6.8 then col = PALE[1]
  else col = (r > R - 8) and FL[2] or FL[2] end
  c:put(x, y, col, rtok)
end)
-- darker seam where the side face meets the front
front:grow(1):cut(front):each(function(x, y) if back:has(x, y) then
  local r = polar(x, y, AX, AY) c:put(x, y, r > R - 5 and SKIN[1] or FL[1], rtok) end end)

-- front: rind bands by radius, flesh by per-pixel light
local flesh, pale, lg, skin = HP.mask(), HP.mask(), HP.mask(), HP.mask()
front:each(function(x, y)
  local r = polar(x, y, AX, AY)
  if r > R - 2.2 then skin:set(x, y)
  elseif r > R - 4.6 then lg:set(x, y)
  elseif r > R - 6.8 then pale:set(x, y)
  else flesh:set(x, y) end
end)
local fn = X.pillow(flesh, 3)
local bias = {}
X.ao(bias, flesh, pale, 1, -1)
A.shade(c, flesh, fn, FL, { tok = ftok, bias = bias, amb = 0.12, wrap = 0.3 })
-- crystalline grain: tiny lighter flecks radiating from the tip
flesh:shrink(2):each(function(x, y)
  local h = X.hash(x, y, 7)
  if h < 0.07 then c:put(x, y, FL[5], ftok) elseif h > 0.95 then c:put(x, y, FL[3], ftok) end
end)
pale:each(function(x, y) local r, a = polar(x, y, AX, AY)
  c:put(x, y, a < -0.2 and PALE[3] or (a < 0.22 and PALE[2] or PALE[1]), rtok) end)
lg:each(function(x, y) local r, a = polar(x, y, AX, AY)
  c:put(x, y, r < R - 3.4 and (a < 0 and LG[3] or LG[2]) or (a < 0.2 and LG[2] or LG[1]), rtok) end)
skin:each(function(x, y) local r, a = polar(x, y, AX, AY)
  local stripe = (floor(a * 40) % 3 == 0)
  c:put(x, y, stripe and SKIN[1] or (a < -0.15 and SKIN[4] or SKIN[3]), rtok) end)

-- bitten edge: paler, drier flesh along the scallops
front:each(function(x, y)
  for _, d in ipairs{ { 0, -1 }, { -1, 0 }, { 1, 0 } } do
    if bite:has(x + d[1], y + d[2]) then c:put(x, y, FL[6], ftok) break end
  end
end)

-- wet highlight streak along the lit left cut edge + one glint
for i = 0, 5 do
  local r = 14 + i * 3
  local a = -SPAN + 0.07
  local x, y = floor(AX + r * sin(a + TILT) ), floor(AY + r * cos(a + TILT))
  if flesh:has(x, y) then c:put(x, y, FL[6], ftok) end
end


-- seeds: one curved row, teardrops pointing at the tip
local SR = 31
for i, a in ipairs{ -0.22, -0.11, 0.0, 0.11, 0.22 } do
  local rr = SR + ((i % 2 == 0) and -4 or 0)
  local ang = a + TILT
  local sx, sy = AX + rr * sin(ang), AY + rr * cos(ang)
  local ux, uy = sin(ang), cos(ang)
  local sm = A.rell(sx, sy, ux, uy, 2.1, 1.1)
  sm:add(A.rell(sx - ux * 1.4, sy - uy * 1.4, ux, uy, 1.0, 0.6))
  local tipx, tipy = floor(sx - ux * 2.4 + 0.5), floor(sy - uy * 2.4 + 0.5)
  sm:each(function(x, y) c:put(x, y, SEED[2], stok) end)
  -- shade lower-right, glint upper-left
  sm:each(function(x, y) if not sm:has(x + 1, y) or not sm:has(x, y + 1) then c:put(x, y, SEED[1], stok) end end)
  local bx, by = sm:bbox()
  local gx, gy
  sm:each(function(x, y) if not gx or x + y < gx + gy then gx, gy = x, y end end)
  c:put(gx, gy + 1, SEED[3], stok)
  -- tiny AO dot under each seed on the flesh
  local ox, oy = floor(sx + 1.6), floor(sy + 2)
  if flesh:has(ox, oy) and not sm:has(ox, oy) then c:put(ox, oy, FL[3], ftok) end
end

-- juice drip hanging from the right edge of the cut face
local DR = { ".d", "dD", "dD", ".D" }

A.save(c, "ico-watermelon")
