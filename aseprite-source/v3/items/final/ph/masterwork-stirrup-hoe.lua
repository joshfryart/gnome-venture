-- masterwork-stirrup-hoe (final, Opus single pass). Long pale ash handle on the diagonal (grain dashes, pale end grain,
-- a dark hang-hole near the top), ringed brass ferrule, a bent steel shank into a riveted brass hinge bracket, and an
-- open trapezoid stirrup loop of bevelled steel whose bottom bar is the honed blade (lit bevel row, bright edge glints).
-- quirk: a pulled weed with its root still dangles off the blade corner.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC22_5.lua")
local K, HP = A.K, A.HP
local c = A.new("masterwork-stirrup-hoe")

-- handle (ash)
local hm, hT, hS, hidx, _, hlen = A.rod(c, 30, 36, 55, 9, 1.65, A.ASH, { round = true })
A.grain(c, hm, hT, hS, hidx, A.ASH, hlen, 3, { t1 = 0.9 })
-- pale end grain at the top
hm:each(function(x, y) local k = K(x, y) if hT[k] * hlen > hlen - 1.2 then c:put(x, y, A.ASH[6]) end end)
c:put(52, 12, A.ASH[1]) c:put(53, 12, A.ASH[2]) c:put(52, 13, A.ASH[3])

-- bent steel shank
local sm, sn = A.tube({ { 29, 37 }, { 26, 39.5 }, { 23.5, 40.5 }, { 21, 41.5 } }, function() return 1.0 end)
A.tone(c, sm, sn, A.STEEL, { amb = 0.14, wrap = 0.35 })

-- brass ferrule with two ring grooves
local fm, fT, fS, fidx = A.rod(c, 27.6, 38.4, 32.2, 33.8, 2.2, A.BRASS, { round = true })
fm:each(function(x, y) local k = K(x, y)
  local t = fT[k] if (t > 0.3 and t < 0.42) or (t > 0.7 and t < 0.8) then A.step(c, fidx, A.BRASS, x, y, -2) end end)
A.contact(c, fm, 1)

-- stirrup loop (steel, open centre)
local outer = c:poly{ { 13, 43 }, { 27, 43 }, { 31, 56 }, { 9, 56 } }
local inner = c:poly{ { 15, 45 }, { 25, 45 }, { 28, 53 }, { 12, 53 } }
local loop = outer:copy():cut(inner)
local lidx = A.plate(c, loop, A.STEEL, { R = 1.2, amb = 0.14, wrap = 0.35 })
-- blade bottom bar: lit bevel row, honed bright edge glints, dark heel
for x = 9, 31 do
  if loop:has(x, 54) and not inner:has(x, 54) then A.step(c, lidx, A.STEEL, x, 54, 1) end
  if loop:has(x, 56) and x % 3 ~= 0 then c:put(x, 56, A.STEEL[5]) end
end
c:put(14, 54, A.CREAM) c:put(15, 54, A.STEEL[6])

-- riveted brass hinge bracket on the loop top
local bm = c:rrect(17, 40, 24, 44, 1)
local bidx = A.plate(c, bm, A.BRASS, { R = 1.2 })
A.contact(c, bm, 1)
c:put(18, 42, A.STEEL[2]) c:put(18, 41, A.STEEL[5])
c:put(23, 42, A.STEEL[2]) c:put(23, 41, A.STEEL[5])

-- quirk: a weed caught on the right blade corner, root dangling
local l1, n1 = A.blade(31, 55, 35, 51, 38, 49, function(t) if t > 0.97 then return -1 end return math.max(0.3, 1.5 * math.sin(math.pi * t) ^ 0.7) end, { fold = 0.4 })
A.tone(c, l1, n1, A.LEAF, { amb = 0.14, wrap = 0.3 })
local l2, n2 = A.blade(31, 55, 35, 56, 37, 54, function(t) if t > 0.97 then return -1 end return math.max(0.3, 1.2 * math.sin(math.pi * t) ^ 0.7) end, { fold = 0.4 })
A.tone(c, l2, n2, A.LEAF, { amb = 0.1, wrap = 0.25, bias = (function() local b = {} l2:each(function(x, y) b[K(x, y)] = -1 end) return b end)() })
A.wire(c, { { 32, 54 }, { 34, 52 }, { 36, 50 } }, A.LEAF[6])
A.wire(c, { { 31, 57 }, { 32, 58 }, { 32, 59 }, { 33, 60 } }, A.ASH[6])
A.save(c, "masterwork-stirrup-hoe")
