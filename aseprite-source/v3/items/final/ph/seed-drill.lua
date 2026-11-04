-- seed-drill (D15 artist pass). A slim push seed drill in side view: a tall spoked wooden wheel with an iron tyre, a narrow
-- plank hopper with brass lid, iron straps and a seed-level window, a thin iron drop tube ending in a coulter shoe, two long
-- ash handles with leather-wrapped grips and a cross-bar. Seeds fall into a furrow.
-- quirk: a tiny sprout from an earlier row already peeks out of the soil behind the wheel.
local NAME = "seed-drill"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD15_1.lua")
local HP, X, K, R = A.HP, A.X, A.K, A.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)

-- soil strip
local soil = c:rrect(9, 57, 55, 59, 1)
A.lit2(c, soil, R.soil, 1.6)
for _, p in ipairs{ {13,58}, {20,59}, {33,58}, {40,59}, {53,58}, {49,59} } do c:px(p[1], p[2], R.soil[5]) end
for _, p in ipairs{ {15,59}, {27,59}, {36,58}, {52,59} } do c:px(p[1], p[2], R.soil[1]) end
-- quirk sprout from an earlier row, behind the wheel
A.ln(c, 11, 56, 11, 53, R.fresh[4])
A.leafE(c, 9, 53, 2.1, 1.1, -0.4, R.fresh, R.fresh[2])
A.leafE(c, 13.4, 52.4, 2.1, 1.1, 0.4, R.fresh, R.fresh[2])
c:px(11, 57, R.soil[1])

-- handles: far one darker (behind), near one lit
local function handle(ax, ay, bx, by, ramp)
  local m = A.cyl(c, ax, ay, bx, by, function(t) return t < 0.74 and 1.15 or 1.65 end, ramp, { amb = 0.08 })
  -- grain
  local dx, dy = bx - ax, by - ay
  for i = 2, 7 do
    local t = 0.1 + i * 0.075
    c:px(floor(ax + dx * t + .5), floor(ay + dy * t + .5) + 1, ramp[2])
  end
  -- leather grip wrap
  local gm = HP.mask()
  m:each(function(x, y) local t = ((x - ax) * dx + (y - ay) * dy) / (dx * dx + dy * dy) if t >= 0.74 then gm:set(x, y) end end)
  A.lit2(c, gm, R.brown, 1.3)
  local L = sqrt(dx * dx + dy * dy)
  for k = 0, 3 do
    local t = 0.78 + k * 0.055
    local cx0, cy0 = ax + dx * t, ay + dy * t
    local nx, ny = -dy / L, dx / L
    for s = -2, 2 do
      local px, py = floor(cx0 + nx * s + .5), floor(cy0 + ny * s + .5)
      if gm:has(px, py) then c:px(px, py, R.brown[1]) end
    end
  end
  return m
end
handle(38, 19, 10, 11, R.brown)
local hn = handle(38, 27, 10, 19, R.tan)
-- cross bar between the handles
A.cyl(c, 21, 14, 21, 21, function(t) return 0.95 end, R.tan)
c:px(20, 13, R.tan[5]) c:px(20, 14, R.tan[5])

-- hopper
local hop = c:poly{ {36, 16}, {50, 16}, {48, 34}, {39, 34} }
A.lit2(c, hop, R.tan, 3.2)
local function xAt(top, bot, y) return floor(top + (bot - top) * (y - 16) / 18 + .5) end
for y = 17, 33 do
  c:px(xAt(41, 42, y), y, R.tan[2]); c:px(xAt(45, 45, y), y, R.tan[2])
  if y % 4 == 1 then c:px(xAt(43, 43, y) + (y % 8 == 1 and 0 or 1), y, R.tan[3]) end
end
-- iron straps with rivets
for _, y0 in ipairs{ 20, 29 } do
  local band = hop:copy():clip(c:rect(0, y0, 63, y0 + 1))
  A.lit2(c, band, R.iron, 1.2)
  for _, tx in ipairs{ 40, 44, 47 } do local sx = tx + (y0 == 29 and 0 or -1) if band:has(sx, y0) then c:px(sx, y0, R.iron[6]) end end
end
-- seed level window
c:fillMask(c:rect(42, 23, 45, 26), R.brown[1])
for _, p in ipairs{ {42,25}, {43,26}, {44,26}, {45,25}, {44,25} } do c:px(p[1], p[2], R.gold[4]) end
c:px(43, 25, R.gold[5]) c:px(42, 24, R.brown[2])
A.ln(c, 41, 22, 46, 22, R.gold[3])
-- lid
local lid = c:rrect(34, 12, 52, 16, 1)
A.lit2(c, lid, R.gold, 2.2)
c:px(37, 13, R.gold[6]) c:px(38, 13, R.gold[6])
A.ln(c, 35, 16, 51, 16, R.gold[1])
A.ln(c, 47, 14, 50, 14, R.gold[2])
-- ring pull on the lid

-- drive beam hub -> feed box
A.cyl(c, 27, 45, 41, 36, function(t) return 1.5 end, R.brown)
local box = c:rect(39, 33, 47, 36)
A.lit2(c, box, R.iron, 1.4)
A.ln(c, 40, 33, 46, 33, R.iron[2])
-- drop tube + coulter shoe
local tm = A.cyl(c, 43, 37, 45, 52, function(t) return 1.1 end, R.steel)
local shoe = c:poly{ {42, 51}, {48, 51}, {49, 55}, {46, 59}, {43, 55} }
A.lit2(c, shoe, R.steel, 1.6)
A.ln(c, 43, 55, 46, 58, R.steel[6])
A.ln(c, 43, 51, 48, 51, R.steel[2])
c:px(44, 51, R.steel[6])
-- seeds falling into the furrow
for _, p in ipairs{ {51, 53}, {53, 57} } do A.lit2(c, A.ell(p[1], p[2], 1.6, 1.2, 0.5), R.gold, 1.2); end
c:px(51, 52, A.CREAM)

-- wheel (near plane)
local WX, WY = 27, 45
local W = A.ell(WX, WY, 11, 11, 0)
local inner = A.ell(WX, WY, 7.3, 7.3, 0)
local tyre = W:copy():cut(A.ell(WX, WY, 9.7, 9.7, 0))
local felloe = W:copy():cut(tyre):cut(inner)
-- spokes
for i = 0, 5 do
  local a = i * pi / 3 + 0.35
  local m = A.cyl(c, WX + cos(a) * 2, WY + sin(a) * 2, WX + cos(a) * 8.5, WY + sin(a) * 8.5, function(t) return 1.0 end, R.tan, { amb = 0.12 })
end
A.seam(c, felloe, W:copy():cut(felloe), R.brown[1])
A.lit2(c, felloe, R.brown, 1.7)
A.lit2(c, tyre, R.iron, 1.3)
-- tyre bolt heads and felloe pegs
for i = 0, 7 do
  local a = i * pi / 4 + 0.2
  c:px(floor(WX + cos(a) * 9.7 + .5), floor(WY + sin(a) * 9.7 + .5), R.iron[6])
end
for i = 0, 5 do  -- joint lines in felloe
  local a = i * pi / 3 + 0.35 + pi / 6
  c:px(floor(WX + cos(a) * 8.1 + .5), floor(WY + sin(a) * 8.1 + .5), R.brown[1])
end
-- spoke ambient dark next to felloe
-- hub
local hub = A.ell(WX, WY, 3.4, 3.4, 0)
A.lit2(c, hub, R.tan, 2.4)
A.seam(c, hub:copy():grow(1), hub, R.brown[1])
local bolt = A.ell(WX, WY, 1.6, 1.6, 0)
A.lit2(c, bolt, R.steel, 1.2)
c:px(WX - 1, WY - 1, R.steel[6])
-- contact shadow on soil under the wheel
for x = WX - 4, WX + 4 do c:px(x, 57, R.soil[1]) end
-- ambient: dark row where wheel overlaps beam

A.save2(c, NAME)
