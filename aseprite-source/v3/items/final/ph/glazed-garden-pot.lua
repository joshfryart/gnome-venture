-- glazed-garden-pot (final, Opus single pass). A slim tapered garden pot in 3/4 view: rolled lip with a soil-filled
-- mouth, cobalt-teal glossy glaze over the top two thirds (vertical specular streak, an incised double ring, darker
-- pooled glaze along a wavy dipping line), bare speckled terracotta below and a separate foot ring, ground shadow.
-- quirk: one glaze drip ran past the line and froze as a glossy blue bead on the bare clay.
local NAME = "glazed-garden-pot"
local B = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_3.lua")
local HP, X, K = B.HP, B.X, B.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = B.new(NAME)
local GLZ = { "#1b2152", "#22357a", "#2a56a2", "#3580bc", "#56b0d2", "#a8e6e4" }
local CLAY = { "#4a2228", "#7a3a2c", "#a4553a", "#c6744a", "#de9862", "#f2bd88" }
local SOIL = { "#2e1a1e", "#4a2c26", "#6a4030", "#8a5a3c" }
local SPEC = "#e8fbf4"
local CX = 31.5
local gtok, ctok, stok = { r = { name = "glaze" } }, { r = { name = "clay" } }, { r = { name = "soil" } }

c:groundShadow(31.5, 53, 15, 2.5)

-- body profile: y 18..50, slight shoulder then straight taper
local Y0, Y1 = 18, 50
local function hw(y)
  local t = (y - Y0) / (Y1 - Y0)
  return 13.2 - 4.4 * t + 0.9 * sin(pi * min(1, t * 1.6)) * (1 - t)
end
local body, bn = HP.mask(), {}
for y = Y0, Y1 + 2 do for x = 8, 56 do
  local yy = min(y, Y1)
  local w = hw(yy)
  local inside = abs(x - CX) <= w
  if y > Y1 then -- rounded base: ellipse cap
    local u = (x - CX) / (w + 0.3) local v = (y - Y1) / 2.6
    inside = u * u + v * v <= 1
  end
  if inside then
    body:set(x, y)
    local nx = (x - CX) / (w + 0.6)
    bn[K(x, y)] = { B.norm(nx, -0.16 + (y > Y1 and 0.5 or 0), sqrt(max(0.03, 1 - nx * nx))) }
  end
end end
-- foot ring (unglazed, slightly flared)
local foot, fn = HP.mask(), {}
for y = 49, 53 do
  local w = (y <= 50) and 9.6 or 10.2
  if y == 53 then w = 9.4 end
  for x = 8, 56 do if abs(x - CX) <= w then foot:set(x, y)
    local nx = (x - CX) / (w + 0.6) fn[K(x, y)] = { B.norm(nx, (y - 51) * 0.25, sqrt(max(0.03, 1 - nx * nx))) } end end
end
body:cut(foot)

-- glaze line: wavy dip around y 38..41, plus drips
local function gl(x) return 39 + 1.4 * sin(x * 0.55 + 0.6) + 0.8 * sin(x * 1.3) end
local drips = { { 22, 44 }, { 36, 43 }, { 41, 42 } }
local bead = { 27, 47 }   -- quirk drip end
local function glazed(x, y)
  if y <= gl(x) then return true end
  for _, d in ipairs(drips) do if (x == d[1] or x == d[1] + 1) and y <= d[2] - ((x == d[1] + 1) and 1 or 0) then return true end end
  if x == bead[1] and y <= bead[2] then return true end
  return false
end

-- body paint
local bias = {}
body:each(function(x, y) if y <= 21 then bias[K(x, y)] = (y <= 20) and -2 or -1 end end) -- AO under the lip
local v = X.light(bn, { amb = 0.08, wrap = 0.3 })
local gm, cm = HP.mask(), HP.mask()
body:each(function(x, y) if glazed(x, y) then gm:set(x, y) else cm:set(x, y) end end)
local gi = X.tone(c, gm, v, GLZ, { cuts = { 0.16, 0.32, 0.5, 0.7, 0.9 }, bias = bias, tok = gtok })
-- terracotta: matte, flatter (one step darker), speckle grain
local cb = {}
cm:each(function(x, y) local k = K(x, y)
  cb[k] = -1
  if y <= gl(x) + 1.5 then cb[k] = -2 end                -- shadow just under the glaze edge
end)
local ci = X.tone(c, cm, v, CLAY, { cuts = { 0.14, 0.3, 0.48, 0.66, 0.86 }, bias = cb, tok = ctok })
cm:each(function(x, y) local h = X.hash(x, y, 7)
  if h > 0.86 then B.step(c, ci, CLAY, x, y, -1, ctok) elseif h < 0.06 then B.step(c, ci, CLAY, x, y, 1, ctok) end end)
-- pooled glaze: last glazed pixel of each column is one step darker, drip tips darker too
gm:each(function(x, y) if not gm:has(x, y + 1) and body:has(x, y + 1) then B.step(c, gi, GLZ, x, y, -1, gtok) end end)
-- incised double ring on the shoulder (dark groove + lit lower lip)
for x = 0, 63 do
  for _, ry in ipairs{ 24, 27 } do
    local y = ry + floor(((x - CX) / 13) ^ 2 * 1.5 + 0.5)
    if gm:has(x, y) then B.step(c, gi, GLZ, x, y, -2, gtok) end
    if gm:has(x, y + 1) then B.step(c, gi, GLZ, x, y + 1, 1, gtok) end
  end
end
-- glossy specular streak: vertical, on the lit side, broken by the rings
gm:each(function(x, y)
  local w = hw(min(y, Y1))
  local nx = (x - CX) / (w + 0.6)
  if nx > -0.62 and nx < -0.44 and y >= 21 and y <= 36 and not (y >= 24 and y <= 25) and not (y >= 27 and y <= 28) then
    c:put(x, y, (y < 33) and SPEC or GLZ[6], gtok) end
end)
-- reflected cool light on the shade edge of the glaze
gm:each(function(x, y) if not body:has(x + 1, y) and y > 22 and y < gl(x) - 1 then c:put(x, y, GLZ[3], gtok) end end)
-- quirk: glossy bead at the drip end
do local bx, by = bead[1], bead[2]
  for _, p in ipairs{ { -1, 0, 3 }, { 0, 0, 4 }, { 1, 0, 2 }, { -1, 1, 2 }, { 0, 1, 2 }, { 1, 1, 1 }, { 0, -1, 4 }, { -1, -1, 3 } } do
    c:put(bx + p[1], by + p[2], GLZ[p[3]], gtok) end
  c:put(bx - 1, by - 1, SPEC, gtok)
end

-- foot ring
local fb = {}
foot:each(function(x, y) if y == 49 then fb[K(x, y)] = -2 end end)
local fi = X.tone(c, foot, X.light(fn, { amb = 0.08, wrap = 0.3 }), CLAY, { cuts = { 0.14, 0.3, 0.48, 0.66, 0.86 }, bias = fb, tok = ctok })
foot:each(function(x, y) if y == 50 and X.hash(x, y, 3) > 0.7 then B.step(c, fi, CLAY, x, y, 1, ctok) end end)

-- rolled lip: torus band y 11..19 with an elliptical top
local RX = 16.2
local lip, ln = HP.mask(), {}
for y = 8, 20 do for x = 8, 56 do
  local u = (x - CX) / (RX + 0.3)
  local inTop = u * u + ((y - 12.5) / 4.4) ^ 2 <= 1
  local inBand = abs(x - CX) <= RX and y >= 12 and y <= 17
  local inBot = u * u + ((y - 17) / 2.4) ^ 2 <= 1
  if inTop or inBand or inBot then
    lip:set(x, y)
    local nx = (x - CX) / (RX + 0.8)
    local vy = (y - 15) / 3.6
    if y < 12 then vy = -0.9 end
    vy = max(-0.95, min(0.95, vy))
    ln[K(x, y)] = { B.norm(nx * 0.9, vy, sqrt(max(0.05, 1 - vy * vy)) * sqrt(max(0.05, 1 - nx * nx))) }
  end
end end
-- mouth opening
local mouth = HP.mask()
for y = 8, 16 do for x = 8, 56 do
  if ((x - CX) / 13.6) ^ 2 + ((y - 12.4) / 2.9) ^ 2 <= 1 then mouth:set(x, y) end end end
lip:cut(mouth)
local li = X.tone(c, lip, X.light(ln, { amb = 0.08, wrap = 0.3 }), GLZ, { cuts = { 0.16, 0.32, 0.5, 0.7, 0.9 }, tok = gtok })
-- lip bevel: bright top edge of the front roll, specular 2x1, dark crease where the lip meets the mouth rim
lip:each(function(x, y)
  if y == 14 and x > 17 and x < 46 then B.step(c, li, GLZ, x, y, 1, gtok) end
  if mouth:has(x, y - 1) and y >= 14 then B.step(c, li, GLZ, x, y, 1, gtok) end
end)
c:put(19, 13, SPEC, gtok) c:put(20, 13, SPEC, gtok) c:put(21, 14, GLZ[6], gtok)
-- soil inside: back inner wall shadow on top row, crumbly soil, a pebble
mouth:each(function(x, y)
  local col = SOIL[2]
  if not mouth:has(x, y - 1) or not mouth:has(x, y - 2) then col = GLZ[1]
  else
    local h = X.hash(x, y, 11)
    col = h > 0.75 and SOIL[3] or (h < 0.2 and SOIL[1] or SOIL[2])
    if not mouth:has(x, y + 1) then col = SOIL[1] end
  end
  c:put(x, y, col, stok)
end)
c:put(36, 12, SOIL[4], stok) c:put(37, 12, SOIL[3], stok) c:put(36, 13, SOIL[3], stok) c:put(37, 13, SOIL[1], stok)
c:put(25, 13, SOIL[4], stok)

B.save(c, NAME)
