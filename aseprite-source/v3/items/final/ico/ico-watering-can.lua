-- ico-watering-can (final pass, Opus aR1_0). Slim garden can in side view: green enamel drum (per-pixel cylinder
-- light, 6 tones, cool reflected edge, pressed rib with lit lip, specular streak), domed shoulder with a galvanised seam
-- ring and steel filler cap, an enamel loop handle from the dome to the back, a long thin spout from a steel collar
-- (AO where it meets the drum) and a flared brass rose with a hole grid. Water drops fall from the rose.
-- quirk: a little square tin patch is riveted over an old leak on the drum.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aR1_0.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
local c = A.new("ico-watering-can")

local GRN   = { "#173a34", "#1f5640", "#2f7a48", "#4c9f4f", "#7cc35a", "#bfe88a" }
local STEEL = { "#3a3c58", "#56587a", "#7d7f99", "#a9a9bd", "#cfd0dc", "#eef0f4" }
local BRASS = { "#5a2c1e", "#8f4a1f", "#c47a26", "#e9a93b", "#ffd36a", "#fff0b0" }
local SEA   = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }
local CREAM = A.CREAM
local gtok, stok, btok, wtok = { r = { name = "grn" } }, { r = { name = "steel" } }, { r = { name = "brass" } }, { r = { name = "water" } }

local CX, TOP, BOT = 25.5, 31, 52
-- handle: green enamel tube from the dome over the back, down to the drum's rear (painted first; drum overlaps)
local hm, hn = A.tube({ { 24, TOP - 3 }, { 19, 10 }, { 5, 15 }, { 15, 42 } }, function() return 1.9 end)
A.shade(c, hm, hn, GRN, { tok = gtok })
c:put(13, 17, GRN[6], gtok) c:put(14, 16, GRN[6], gtok)

-- spout (behind the drum's front edge) + collar
local sm, sn, ST, SS = X.cyl(35, 46, 51.5, 21.5, function(t) return 2.2 - 0.6 * t end)
local sbias = {}
sm:each(function(x, y) if ST[K(x, y)] < 0.12 then sbias[K(x, y)] = -1 end end)
A.shade(c, sm, sn, GRN, { tok = gtok, bias = sbias })
sm:each(function(x, y) local k = K(x, y) if SS[k] < -0.35 and ST[k] > 0.25 and ST[k] < 0.8 and (x + y) % 3 ~= 0 then c:put(x, y, GRN[6], gtok) end end)

-- drum
local dm, dn, DT, DS = X.cyl(CX, TOP, CX, BOT, function(t) return 9.6 + 1.2 * t end)
-- round the foot corners
dm:cut(c:rect(0, 52, 15, 52)):cut(c:rect(36, 52, 63, 52))
local bias = {}
dm:each(function(x, y) local k = K(x, y)
  if DT[k] and DT[k] > 0.93 then bias[k] = (bias[k] or 0) - 1 end end)
local di = A.shade(c, dm, dn, GRN, { tok = gtok, bias = bias, amb = 0.1 })
-- pressed rib across the middle: dark groove row + lit row above, following the light
local RIB = 39
dm:each(function(x, y) local k = K(x, y) local i = di[k] or 3
  if y == RIB then c:put(x, y, GRN[max(1, i - 2)], gtok)
  elseif y == RIB - 1 then c:put(x, y, GRN[min(6, i + 1)], gtok) end end)
-- vertical specular streak on the lit side
for y = TOP + 4, BOT - 4 do if y ~= RIB and y ~= RIB - 1 then c:put(18, y, GRN[6], gtok) end end

-- cool reflected light on the right edge
for y = TOP + 4, BOT - 3 do local x = floor(CX + 9.6 + 1.2 * (y - TOP) / (BOT - TOP)) if dm:has(x, y) then c:put(x, y, "#4f7a8a", gtok) end end

-- domed shoulder (half ellipsoid) with a galvanised seam ring and a steel filler cap
local dome = c:ellipse(CX, TOP, 9.8, 5):cut(c:rect(0, TOP + 1, 63, 63))
local don = X.sphere(CX, TOP + 2, 10, dome)
local dmi = A.shade(c, dome, don, GRN, { tok = gtok, amb = 0.12 })
c:put(20, TOP - 3, GRN[6], gtok) c:put(21, TOP - 3, GRN[6], gtok) c:put(19, TOP - 2, CREAM, gtok)
for x = 14, 37 do if dm:has(x, TOP + 1) then c:put(x, TOP + 1, x < 22 and STEEL[5] or (x < 31 and STEEL[4] or STEEL[3]), stok) end
  if dm:has(x, TOP + 2) then local i = di[K(x, TOP + 2)] or 3 c:put(x, TOP + 2, GRN[max(1, i - 1)], gtok) end end
c:put(17, TOP + 1, STEEL[6], stok)
local cap = c:rrect(24, TOP - 7, 28, TOP - 5, 1)
c:fillMask(cap, STEEL[4]) c:put(24, TOP - 6, STEEL[5], stok) c:put(25, TOP - 7, STEEL[6], stok)
for x = 26, 28 do c:put(x, TOP - 5, STEEL[2], stok) end c:put(28, TOP - 6, STEEL[3], stok)
-- foot bead
for x = 13, 36 do
  if dm:has(x, BOT - 1) then c:put(x, BOT - 1, x < 22 and STEEL[5] or (x < 31 and STEEL[4] or STEEL[3]), stok) end
  if dm:has(x, BOT) then c:put(x, BOT, x < 22 and STEEL[3] or STEEL[2], stok) end
end

-- collar where the spout leaves the drum
local col = A.rell(36.3, 45.2, 0.56, -0.83, 1.3, 2.9)
local cn = X.sphere(36.3, 45.2, 2.6, col)
A.shade(c, col, cn, STEEL, { tok = stok })

-- brass rose: flared cone + face disc
local ux, uy = 0.56, -0.83
local cone = HP.mask()
for i = 0, 10 do local f = i / 10
  cone:add(A.rell(50.4 + ux * f * 3.4, 23.0 + uy * f * 3.4, ux, uy, 0.9, 1.6 + 2.6 * f)) end
local con = X.pillow(cone, 1.5)
A.shade(c, cone, con, BRASS, { tok = btok })
local face = A.rell(52.8 + ux * 0.9, 19.9 + uy * 0.9, ux, uy, 1.5, 4.6)
face:cut(cone:copy():cut(face:copy()))
local fn = X.pillow(face, 1.2)
local fi = A.shade(c, face, fn, BRASS, { tok = btok, bias = {} })
face:each(function(x, y) if (x + y) % 2 == 0 and face:shrink(1):has(x, y) then c:put(x, y, BRASS[2], btok) end end)
c:put(50, 18, BRASS[6], btok) c:put(51, 17, BRASS[6], btok)

-- falling drops
local function drop(x, y, big)
  c:put(x, y - 1, SEA[4], wtok)
  c:put(x, y, SEA[3], wtok)
  c:put(x, y + 1, SEA[2], wtok) c:put(x + 1, y + 1, SEA[2], wtok) c:put(x - 1, y + 1, SEA[3], wtok)
  if big then c:put(x - 1, y + 2, SEA[2], wtok) c:put(x, y + 2, SEA[2], wtok) c:put(x + 1, y + 2, SEA[1], wtok) end
  c:put(x - 1, y + 1, SEA[4], wtok)
end
drop(58, 25, true) drop(59, 32, false) drop(55, 31, true)

-- quirk: riveted tin patch over an old leak
local PT = {
  "rbbbbr",
  "bhhhgb",
  "bhggfb",
  "bgggfb",
  "rbffbr",
}
A.map(c, PT, 26, 42, { r = STEEL[6], b = STEEL[2], h = STEEL[5], g = STEEL[4], f = STEEL[3] }, stok)
c:put(26, 47, GRN[1], gtok) c:put(27, 47, GRN[1], gtok) c:put(28, 47, GRN[2], gtok) c:put(32, 43, GRN[2], gtok) c:put(32, 44, GRN[1], gtok)

A.save(c, "ico-watering-can")
