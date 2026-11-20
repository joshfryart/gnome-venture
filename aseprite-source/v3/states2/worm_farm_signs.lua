-- worm_farm EMPTY state: birch-bark sign balanced on the head of a smiling pink worm that pokes out of the plot.
local K = dofile("/tmp/ase/states2/signs4_kit.lua")
local out = app.params.out or "./"
K.init(56, 56, "worm_farm", out)
local P, HP = K.P, K.HP
local px, R, E, ink, pt = K.px, K.R, K.E, K.ink, K.pt
local floor = math.floor

local BARK = { hi = "#fbefd4", base = "#efdcb8", shade = "#d6bd94", deep = "#a8835f", edge = "#8a6650" }
local LENT = "#6b5156"
local PINK = P.petal
local HOLE = "#3a2430"

local function worm(k, sw)
  -- body rises from the hole (28,44) to the head; gentle S-curve, top shifts with sw
  local cells = {}
  local body = HP.mask()
  for y = 33, 44 do
    local t = (44 - y) / 11
    local cx = 27 + floor(1.6 * math.sin(t * 3.4) + .5) + floor(sw * t + .5)
    cells[y] = cx
    for dx = 0, 3 do body:set(cx + dx, y) end
  end
  local hx = cells[33]
  local head = c_rrect(hx - 2, 25, hx + 5, 33, 3)
  ink(body, head)
  for y = 33, 44 do
    local cx = cells[y]
    local ring = ((44 - y) % 3 == 1)
    px(cx, y, ring and PINK.base or PINK.hi); px(cx + 1, y, ring and PINK.shade or PINK.base)
    px(cx + 2, y, ring and PINK.shade or PINK.base); px(cx + 3, y, ring and PINK.deep or PINK.shade)
  end
  K.c:fillMask(head, PINK.base)
  head:each(function(x, y)
    if not head:has(x - 1, y) or not head:has(x, y - 1) then px(x, y, PINK.hi) end
    if not head:has(x + 1, y) or not head:has(x, y + 1) then px(x, y, PINK.shade) end
  end)
  R(hx - 1, 25, hx + 4, 25, PINK.shade)          -- the plate sits on the head: contact shade
  -- face
  if k == 4 then R(hx, 29, hx + 1, 29, P.ink); R(hx + 3, 29, hx + 4, 29, P.ink)
  else R(hx, 27, hx, 29, P.ink); R(hx + 3, 27, hx + 3, 29, P.ink); px(hx, 27, P.cream); px(hx + 3, 27, P.cream) end
  px(hx, 31, P.ink); px(hx + 1, 32, P.ink); px(hx + 2, 32, P.ink); px(hx + 3, 31, P.ink)   -- smile
  px(hx - 1, 30, P.ember.hi); px(hx + 4, 30, P.ember.hi)                                   -- cheeks
  return hx
end
function c_rrect(...) return K.c:rrect(...) end

local function plate(x0, y0)
  -- 30 x 17: bark plate with curled ends; word on top, worm-crate icon below
  local x1, y1 = x0 + 29, y0 + 17
  local face = K.c:rect(x0 + 2, y0, x1 - 2, y1)
  local curlL = K.c:rrect(x0, y0 + 1, x0 + 2, y1 - 1, 1)
  local curlR = K.c:rrect(x1 - 2, y0 + 1, x1, y1 - 1, 1)
  local thick = K.c:rect(x0 + 2, y1 + 1, x1 - 2, y1 + 1)
  ink(face, curlL, curlR, thick)
  K.c:fillMask(face, BARK.base)
  R(x0 + 2, y0, x1 - 2, y0, BARK.hi)
  R(x0 + 2, y1, x1 - 2, y1, BARK.shade)
  K.c:fillMask(thick, BARK.deep)
  -- rolled bark ends
  for _, cm in ipairs{ { curlL, true }, { curlR, false } } do
    local m = cm[1]
    K.c:fillMask(m, BARK.shade)
    m:each(function(x, y) if not m:has(x - 1, y) then px(x, y, cm[2] and BARK.hi or BARK.shade) end
      if not m:has(x + 1, y) then px(x, y, BARK.deep) end end)
  end
  R(x0 + 1, y0 + 3, x0 + 1, y1 - 3, BARK.edge); R(x1 - 1, y0 + 3, x1 - 1, y1 - 3, BARK.edge)
  -- lenticel dashes and grain in the margin only
  for _, d in ipairs{ { 3, 2 }, { 25, 1 }, { 4, 15 }, { 23, 16 }, { 19, 16 } } do R(x0 + d[1], y0 + d[2], x0 + d[1] + 1, y0 + d[2], LENT) end
  for _, d in ipairs{ { 6, 16 }, { 21, 11 }, { 4, 11 } } do R(x0 + d[1], y0 + d[2], x0 + d[1] + 2, y0 + d[2], BARK.shade) end
  K.word(x0 + 5, y0 + 3, P.ink)
  -- icon: teal worm crate with a pink worm waving out of the soil
  local ix, iy = x0 + 10, y0 + 11
  K.c:paint({
    "....pP...",
    "...pP.Pp.",
    "kkkkkkkkk",
    "hhhhhhhhs",
    "bbvbbbvbs",
    "sssssssss" }, ix, iy - 1, { p = PINK.base, P = PINK.hi, k = HOLE, h = P.sea.hi, b = P.sea.base, v = "#3b2c48", s = P.sea.shade })
  -- two copper tacks
  px(x0 + 3, y0 + 8, P.gold.shade); px(x1 - 3, y0 + 8, P.gold.shade)
end

local function crumbs(k)
  local C = { {}, { { 24, 41 }, { 33, 42 } }, { { 23, 39 }, { 34, 40 }, { 26, 38 } }, { { 22, 43 }, { 35, 43 } } }
  for _, q in ipairs(C[k]) do local m = pt{ { q[1], q[2] }, { q[1] + 1, q[2] } }; ink(m); px(q[1], q[2], K.ESH); px(q[1] + 1, q[2], HOLE) end
end

local function drawEmpty(k)
  local c = K.newc()
  local sw = ({ 0, 1, 1, 0 })[k]
  -- plot: cut turf, roughly the crate's footprint
  local m = K.plotMask({ { 12, 34 }, { 44, 34 }, { 48, 50 }, { 8, 50 } }, 3)
  K.plot(m, 3)
  K.corners({ { 15, 38 }, { 41, 38 }, { 44, 47 }, { 12, 47 } }, 5)
  -- the hole and its crumb rim
  local hole = E(28.5, 44, 4, 1)
  local rim = E(28.5, 44, 6, 2):cut(hole)
  rim:each(function(x, y) px(x, y, (y > 44) and K.EHI or K.ESH) end)
  K.c:fillMask(hole, HOLE)
  -- cast shadow of the worm and its sign onto the plot, lower right
  K.shadow(K.c:poly{ { 32, 43 }, { 43, 41 }, { 45, 44 }, { 33, 46 } }, .3)
  local hx = worm(k, sw)
  plate(hx - 13, 6)
  crumbs(k)
  -- garden bits
  K.pebble(19, 44); K.pebble(37, 40)
  K.tuft(4, 51); K.tuft(47, 52); K.tuft(36, 36)
  K.flower(51, 45, P.cream, P.petal.base)       -- clover
  K.flower(7, 44, P.gold.base, P.gold.deep)    -- dandelion
  return c
end

local frames = {}
for k = 1, 4 do frames[k] = drawEmpty(k) end
K.saveStrip(frames, "worm_farm-empty", "empty")
