-- ico-ruler (final, Opus single pass). A slim maple school ruler lying on the 45-degree diagonal (lower-left to
-- upper-right) with a steel measuring edge along its upper-left side and a brass grommet hole at the top end.
-- Material: flat bevelled wood face (6-tone honey maple) with long grain lines and a knot, a darker 2px thickness strip
-- on the shade side, a pale end grain on the lower-left end; steel edge with a lit bevel and a specular streak;
-- ink ticks (short, half, long) and dot markers; ambient shading where the steel strip meets the wood.
-- quirk: an inchworm is measuring the ruler, looped up over the steel edge.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA9_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, sin, pi, max, min = math.floor, math.abs, math.sqrt, math.sin, math.pi, math.max, math.min
local c = A.new("ico-ruler")
local WOOD = { "#5a2a26", "#8e4a2c", "#c27a34", "#e0a446", "#f2c766", "#ffe59a" }
local STEEL = { "#33314d", "#575a7c", "#8689a8", "#b3b6cc", "#dcdde9", "#f6f3f4" }
local BRASS = { "#4e2a20", "#8a5422", "#c08628", "#e8b63c", "#ffe07a", "#fff4d6" }
local TICK = "#4a2326"
local wtok, stok, btok = { r = { name = "wood" } }, { r = { name = "steel" } }, { r = { name = "brass" } }

local AX, AY = 8.5, 54.5                -- lower-left end (axis)
local L = 45 * sqrt(2)
local ux, uy = 1 / sqrt(2), -1 / sqrt(2)  -- along
local px, py = 1 / sqrt(2), 1 / sqrt(2)   -- across, +s = lower-right (shade side)
local S0, S1, S2, S3 = -4.6, -3.0, 2.4, 3.9   -- steel | face | thickness strip
local function ts(x, y) local rx, ry = x + 0.5 - AX, y + 0.5 - AY return rx * ux + ry * uy, rx * px + ry * py end

local all, face, side, steel = HP.mask(), HP.mask(), HP.mask(), HP.mask()
for y = 4, 60 do for x = 2, 60 do
  local t, s = ts(x, y)
  local cut = (t < 0.8 and abs(s) > 3.2) or (t > L - 0.8 and abs(s) > 3.2)
  if t >= 0 and t <= L and s >= S0 and s <= S3 and not cut then
    all:set(x, y)
    if s < S1 then steel:set(x, y) elseif s <= S2 then face:set(x, y) else side:set(x, y) end
  end
end end
-- hole near the top end
local HT = L - 4.2
local hole, grom = HP.mask(), HP.mask()
all:each(function(x, y) local t, s = ts(x, y) local d = sqrt((t - HT) ^ 2 + (s + 0.2) ^ 2)
  if d < 1.5 then hole:set(x, y) elseif d < 3.1 then grom:set(x, y) end end)
face:cut(hole) side:cut(hole) steel:cut(hole) all:cut(hole)
face:cut(grom) side:cut(grom)

-- wood face: bevelled slab + grain
local bias = {}
face:each(function(x, y) local t, s = ts(x, y) local k = K(x, y)
  if s < S1 + 1.0 then bias[k] = -1 end                         -- AO under the steel strip
  local g = s + 0.45 * sin(t * 0.13 + 1.3)
  for _, gl in ipairs{ 1.2 } do if abs(g - gl) < 0.4 and t > 3 and t < L - 3 then bias[k] = (bias[k] or 0) - 1 end end
end)
local fidx = A.slab(c, face, WOOD, 1.3, { bias = bias, tok = wtok, amb = 0.25, wrap = 0.4, cuts = { 0.15, 0.3, 0.48, 0.66, 0.86 } })
-- knot
local KT, KS = 17, 0.4
face:each(function(x, y) local t, s = ts(x, y) local d = sqrt(((t - KT) / 1.8) ^ 2 + ((s - KS) / 1.1) ^ 2)
  if d < 0.75 then c:put(x, y, WOOD[2], wtok) elseif d < 1.5 then c:put(x, y, WOOD[3], wtok) end end)
-- thickness strip (shade side), darker toward the bottom edge
side:each(function(x, y) local t, s = ts(x, y) c:put(x, y, s > S3 - 0.75 and WOOD[2] or WOOD[3], wtok) end)
-- end grain on the lower-left end
all:each(function(x, y) local t, s = ts(x, y) if t < 1.6 and not steel:has(x, y) then c:put(x, y, (s > 1.5) and WOOD[4] or WOOD[6], wtok) end end)

-- steel edge: cylinder-ish across, bright bevel, specular streak
local sidx = {}
steel:each(function(x, y) local t, s = ts(x, y)
  local f = (s - S0) / (S1 - S0)
  local i = f < 0.35 and 5 or (f < 0.7 and 4 or 2)
  if t < 2 or t > L - 2 then i = i - 1 end
  sidx[K(x, y)] = i
  c:put(x, y, STEEL[i], stok)
end)
steel:each(function(x, y) local t = ts(x, y) if (t > 8 and t < 13) or (t > 15 and t < 16.5) then c:put(x, y, STEEL[6], stok) end end)

-- brass grommet
grom:each(function(x, y) local t, s = ts(x, y) local dx, dy = t - HT, s + 0.2
  local i = (dy - dx * 0.2 < -0.8) and 5 or ((dy > 0.8) and 2 or 4)
  c:put(x, y, BRASS[i], btok) end)

-- ticks along the steel/face boundary: lines x - y = const (perpendicular to the ruler)
face:each(function(x, y) local t, s = ts(x, y)
  local q = x - y
  if t > 3 and t < HT - 3.5 and (q % 4 == 0 or q % 4 == 1) then
    local n = q // 4
    local len = (n % 4 == 0) and 4.2 or ((n % 2 == 0) and 2.9 or 1.9)
    if s < S1 + len then c:put(x, y, TICK, wtok) end
  end
end)
-- dot markers next to the long ticks (stand-ins for numerals)
face:each(function(x, y) local t, s = ts(x, y) local q = x - y
  if t > 3 and t < HT - 3.5 and false then c:put(x, y, WOOD[2], wtok) end end)

-- quirk: an inchworm looped up over the steel edge
local mtok = { r = { name = "worm" } }
local WORM = { "#1f4a3e", "#2d6a44", "#45924c", "#6ab455", "#9ad06a", "#d0ee96" }
local function at(t, s) return AX + ux * t + px * s, AY + uy * t + py * s end
local t0 = 24
local P = {}
P[1] = { at(t0, 0.6) } P[2] = { at(t0 + 0.5, -8) } P[3] = { at(t0 + 11.5, -8) } P[4] = { at(t0 + 12, 0.4) }
local wm, wn, WT, WS = A.tube(P, function(t) return 1.55 end)
local widx = A.shade(c, wm, wn, WORM, { tok = mtok, amb = 0.15, wrap = 0.35 })
-- segment rings
wm:each(function(x, y) local k = K(x, y) local t = WT[k]
  if (floor(t * 11) % 2 == 0) and WS[k] > -0.2 then A.step(c, widx, WORM, x, y, -1, mtok) end end)
-- head at the front (upper-right) foot: eye
local hx, hy = at(t0 + 12, 0.4)
local hm = c:ellipse(floor(hx + 0.5), floor(hy + 0.5) - 1, 2, 2)
local hn = X.sphere(floor(hx + 0.5), floor(hy + 0.5) - 1, 2, hm)
A.shade(c, hm, hn, WORM, { tok = mtok, amb = 0.2, wrap = 0.3 })
c:eyeSmall(floor(hx + 0.5), floor(hy + 0.5) - 2)
c:put(floor(hx + 0.5) + 2, floor(hy + 0.5), "#c94f84", mtok)
-- one cream glint on the steel
local gx, gy = at(10.5, -4.0) c:put(floor(gx), floor(gy), A.CREAM, stok)

A.save(c, "ico-ruler")
