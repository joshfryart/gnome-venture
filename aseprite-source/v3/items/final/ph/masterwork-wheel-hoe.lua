-- masterwork-wheel-hoe (final, Opus single pass). Push cultivator: an iron-tyred oak wheel (six spokes, brass hub with
-- axle bolt) at the front, a long oak beam rising to a T crossbar with ribbed red grips at both ends, a brass clamp
-- holding a curved steel standard down to an arrow-shaped sweep blade (lit bevel, honed point).
-- quirk: an earthworm hitches a ride on the blade, head raised.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC22_5.lua")
local K, X, HP = A.K, A.X, A.HP
local sqrt, atan, cos, sin, pi, floor = math.sqrt, math.atan, math.cos, math.sin, math.pi, math.floor
local c = A.new("masterwork-wheel-hoe")
local WX, WY = 15, 46

-- wheel: iron tyre + oak felloe ring
local ring = HP.mask()
for y = WY - 10, WY + 10 do for x = WX - 10, WX + 10 do
  local d = sqrt((x - WX) ^ 2 + (y - WY) ^ 2)
  if d <= 8.6 and d >= 5.6 then ring:set(x, y) end end end
local rn = X.pillow(ring, 1.5)
local ridx = A.toneSel(c, ring, rn, function(k, x, y)
  return sqrt((x - WX) ^ 2 + (y - WY) ^ 2) > 7.4 and A.STEEL or A.WOOD end, { amb = 0.1, wrap = 0.3 })
-- spokes
for i = 0, 5 do
  local a = i * pi / 3 + 0.25
  for r = 2.4, 5.6, 0.5 do
    local x, y = floor(WX + cos(a) * r + 0.5), floor(WY + sin(a) * r + 0.5)
    c:put(x, y, (cos(a) + sin(a) < 0) and A.WOOD[5] or A.WOOD[3])
  end
end

-- beam (oak)
local bm, bT, bS, bidx, _, blen = A.rod(c, WX, WY, 50.5, 12.5, 1.6, A.WOOD, { round = true })
A.grain(c, bm, bT, bS, bidx, A.WOOD, blen, 11, { t0 = 0.12 })
A.contact(c, bm, 1)

-- hub over the beam end
local hm = A.ball(c, WX + 0.2, WY - 0.2, 2.5, A.BRASS)
c:put(WX, WY, A.BRASS[1]) c:put(WX - 1, WY - 1, A.CREAM)

-- crossbar with red grips
local ux, uy = 0.686, 0.727
local qx, qy = 51.5, 11.5
local xm, xn, xT, xS = A.X.cyl(qx - ux * 6, qy - uy * 6, qx + ux * 6, qy + uy * 6, function() return 1.6 end)
local xidx = A.toneSel(c, xm, xn, function(k) local t = xT[k] return (t < 0.36 or t > 0.64) and A.RED or A.WOOD end, { amb = 0.1, wrap = 0.3 })
xm:each(function(x, y) local k = K(x, y) local t = xT[k]
  if (t < 0.32 or t > 0.68) and (t * 12) % 2.2 < 0.75 then A.step(c, xidx, A.RED, x, y, -1) end
  if (t >= 0.34 and t < 0.38) or (t > 0.62 and t <= 0.66) then c:put(x, y, A.RED[1]) end end)
A.contact(c, xm, 1)

-- curved steel standard down to the blade
local sm, sn = A.tube({ { 28.5, 34 }, { 31.5, 40 }, { 31.5, 47 }, { 30, 52 } }, function() return 1.05 end)
A.tone(c, sm, sn, A.STEEL, { amb = 0.14, wrap = 0.35 })
-- brass clamp on the beam
local t0, t1 = 0.33, 0.43
local cm, cT = A.rod(c, WX + (50.5 - WX) * t0, WY + (12.5 - WY) * t0, WX + (50.5 - WX) * t1, WY + (12.5 - WY) * t1, 2.4, A.BRASS)
A.contact(c, cm, 1)
c:put(floor(WX + (50.5 - WX) * 0.38 + 0.5), floor(WY + (12.5 - WY) * 0.38 + 0.5), A.STEEL[2])

-- sweep blade, arrow pointing forward (toward the wheel)
local blm = c:poly{ { 24, 54 }, { 29, 51 }, { 39, 51 }, { 40, 54 }, { 38, 56 }, { 28, 56 } }
local blidx = A.plate(c, blm, A.STEEL, { R = 1.2, amb = 0.14, wrap = 0.35 })
for x = 25, 39 do if blm:has(x, 52) and blm:has(x, 51) then A.step(c, blidx, A.STEEL, x, 52, 1) end end
c:put(25, 54, A.STEEL[6]) c:put(24, 54, A.STEEL[5]) c:put(30, 52, A.CREAM)
A.contact(c, sm, 1)

-- quirk: earthworm on the blade, head up
A.map(c, {
  ".....hp",
  "....hp.",
  "hhhhpd.",
  "pdpdpd.",
}, 34, 47, { h = A.PINK[5], p = A.PINK[4], d = A.PINK[3] })
A.save(c, "masterwork-wheel-hoe")
