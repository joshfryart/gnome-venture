-- broken-stirrup-hoe (aB12_4, Opus single pass). Long diagonal ash shaft (lower-left -> upper-right) with grain, brass
-- ferrule, then the steel stirrup head: a neck and pivot yoke with two bolts, two slim side arms and a honed cross blade
-- (open loop in the middle). broken: the shaft is snapped clean through mid-way (jagged gap, pale splinters, a wood
-- sliver flying), and the right stirrup arm is cracked. quirk: a weed sprig snagged on the blade, roots dangling.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, abs, max, min = math.floor, math.sqrt, math.abs, math.max, math.min
local c = A.new("broken-stirrup-hoe")
local W, S, B = A.ASH, A.STEEL, A.BRASS

local ax, ay, bx, by = 14.5, 54, 35, 28
local L = sqrt((bx - ax)^2 + (by - ay)^2)
local ux, uy = (bx - ax) / L, (by - ay) / L
local px, py = -uy, ux if px + py < 0 then px, py = -px, -py end

-- shaft (slightly thicker toward the ferrule)
local shaft, sn, ST, SS = A.rod(c, ax, ay, bx, by, function(t) return 1.5 + t * 0.3 end, W, { grain = true, seed = 5 })
-- butt end grain
c:px(floor(ax), floor(ay), W[5])

-- head, built in the shaft frame (a = along u from the ferrule end, b = across)
local ox, oy = bx, by
local function inHead(a, b)
  local ab = abs(b)
  if a >= -0.5 and a <= 4 and ab <= 1.4 + a * 0.15 then return "neck" end
  if a >= 3.5 and a <= 5.8 and ab <= 7.3 then return "yoke" end
  if a >= 3.5 and a <= 15 and ab >= 5.6 and ab <= 7.3 then return "arm" end
  if a >= 13.6 and a <= 16.4 and ab <= 8.2 - max(0, a - 15.6) * 1.2 then return "blade" end
  return nil
end
local head = A.frame(ox, oy, ux, uy, 20, 0, 63, 40, function(a, b) return inHead(a, b) ~= nil end)
A.pil(c, head, S, 1.3, { amb = 0.12 })
-- honed blade edge (outer edge of the cross blade) bright, inner fold darker
local bladeM = A.frame(ox, oy, ux, uy, 20, 0, 63, 40, function(a, b) return inHead(a, b) == "blade" end)
bladeM:each(function(x, y)
  local rx, ry = x - ox, y - oy local a = rx * ux + ry * uy
  if a >= 15.6 then c:px(x, y, a >= 16 and S[6] or S[5]) elseif a < 14.3 then A.dk(c, x, y, S, 1) end
end)
-- pivot bolts: dark eye with a lit rim
for _, sb in ipairs{ -6.4, 6.4 } do
  local x, y = floor(ox + ux * 4.6 + px * sb + .5), floor(oy + uy * 4.6 + py * sb + .5)
  c:px(x, y, S[1]) c:px(x - 1, y - 1, S[6]) c:px(x + 1, y, S[3])
end
-- brass ferrule over the shaft top
local fer = A.rod(c, ax + ux * (L - 5), ay + uy * (L - 5), bx + ux * 0.5, by + uy * 0.5, 2.3, B)
A.ao(c, shaft, fer, W, 2)
do local x, y = floor(ax + ux * (L - 3) - px * 1 + .5), floor(ay + uy * (L - 3) - py * 1 + .5) c:px(x, y, B[6]) c:px(x + 1, y, B[1]) end
-- ring groove on the ferrule
for s = -2, 2 do local x, y = floor(ax + ux * (L - 2) + px * s + .5), floor(ay + uy * (L - 2) + py * s + .5) A.dk(c, x, y, B, 2) end
-- specular on the left arm
do local x, y = floor(ox + ux * 9 - px * 6.4 + .5), floor(oy + uy * 9 - py * 6.4 + .5) c:px(x, y, A.CREAM) end

-- damage 1: shaft snapped mid-way, jagged gap
local mt = 0.42
local mx, my = ax + ux * L * mt, ay + uy * L * mt
local gap = HP.mask()
shaft:each(function(x, y)
  local rx, ry = x - mx, y - my
  local a, b = rx * ux + ry * uy, rx * px + ry * py
  local zig = (floor(b + 3) % 2 == 0) and 0.8 or -0.8
  if abs(a - zig) < 1.25 then gap:set(x, y) end
end)
A.erase(c, gap)
-- splinters: pale torn fibres poking into the gap from each side
for _, q in ipairs{ { -1.9, -1 }, { 2.2, 0.6 } } do
  local x, y = floor(mx + ux * q[1] + px * q[2] + .5), floor(my + uy * q[1] + py * q[2] + .5)
  c:px(x, y, W[6])
end
-- pale broken end grain either side of the gap
gap:grow(1):each(function(x, y) if shaft:has(x, y) and not gap:has(x, y) and c:get(x, y) then
  local i = A.idx(W, c:get(x, y)) if i then c:px(x, y, W[min(6, i + 1)]) end end end)
-- flying sliver
local sx, sy = mx + px * 6, my + py * 6
local sl = A.rod(c, sx - ux * 2.5, sy - uy * 2.5, sx + ux * 2.5, sy + uy * 2.5, 0.7, W)
-- damage 2: crack across the right arm
do
  local pts = {}
  for _, q in ipairs{ { 10, 5.3 }, { 9.5, 6.4 }, { 10.4, 7.6 } } do
    pts[#pts + 1] = { floor(ox + ux * q[1] + px * q[2] + .5), floor(oy + uy * q[1] + py * q[2] + .5) }
  end
  A.poly(c, pts, A.INK)
end

-- quirk: weed sprig snagged on the blade tip (left end), roots dangling
local tx, ty = ox + ux * 15 - px * 7.6, oy + uy * 15 - py * 7.6
local stem = A.lmask{ { floor(tx), floor(ty) }, { floor(tx) - 2, floor(ty) - 3 }, { floor(tx) - 3, floor(ty) - 5 } }
stem:each(function(x, y) c:px(x, y, A.LEAF[4]) end)
local lf = c:ellipse(floor(tx) - 5, floor(ty) - 6, 2, 1)
A.pil(c, lf, A.LEAF, 1)
c:px(floor(tx) - 5, floor(ty) - 6, A.LEAF[2])
local lf2 = c:ellipse(floor(tx) - 1, floor(ty) - 6, 1, 1)
A.pil(c, lf2, A.LEAF, 1)
-- roots
A.poly(c, { { floor(tx) + 1, floor(ty) + 1 }, { floor(tx) + 1, floor(ty) + 3 }, { floor(tx) + 2, floor(ty) + 4 } }, A.SAND[2])
c:px(floor(tx), floor(ty) + 2, A.SAND[3])
A.fin(c)
