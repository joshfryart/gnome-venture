-- broken-sprinkler-can (aB12_3, Opus single pass). A slim green-enamel sprinkler can: upright drum with rolled
-- tin rims, tall arched carry handle, long tapered spout rising to the upper-right.
-- Material: vertical-cylinder light on the enamel (6 tones), rolled rims with a bright bead and a dark seam row,
-- tube-lit tin handle with a specular, spout with a lit edge, AO where handle and spout meet the body.
-- broken: the brass rose has popped off the spout (flying, holes showing, open spout mouth), a dent in the drum,
-- and a crack near the base leaking drops.
-- quirk: a hand-painted daisy on the drum.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, sqrt, max, min = math.floor, math.sqrt, math.max, math.min
local c = G.start(debug.getinfo(1, "S").source)
local EN, ST, BR, WA = G.ENAM, G.STEEL, G.BRASS, G.WATER

c:groundShadow(27, 56, 13, 1)

-- carry handle (tin), arched over the top
local htok = G.tok("handle")
local hm, hn, HT, HS = G.tube({ {20.5,28}, {19,11}, {35,11}, {33.5,28} }, function() return 1.5 end)
G.toneN(c, hm, hn, ST, { tok = htok })
c:put(23, 15, G.CREAM, htok) c:put(24, 14, ST[6], htok)

-- spout (behind the body edge), tapering up-right, open mouth at the end
local sptok = G.tok("spout")
local sm, ST2, SS = G.cyl(c, 34, 47, 52, 25, function(t) return 2.3 - t * 0.9 end, EN, { tok = sptok })
sm:each(function(x, y) local k = K(x, y)
  if SS[k] < -0.55 and ST2[k] > 0.1 and ST2[k] < 0.9 then c:put(x, y, EN[6], sptok) end end)
-- jagged open mouth where the rose was (dark interior, torn tin lip)
G.pts(c, { {51,25}, {52,25}, {51,26} }, EN[1], sptok) c:put(52, 26, ST[4], sptok) c:put(50, 25, ST[5], sptok)
c:put(53, 24, ST[5], sptok)

-- drum body
local btok = G.tok("drum")
local body = c:rrect(17, 27, 36, 53, 2)
local bias = {}
-- AO under the top rim and where the spout joins
body:each(function(x, y) local k = K(x, y)
  if y == 29 then bias[k] = -1 end
  if (x - 36)^2 + (y - 46)^2 < 7 then bias[k] = (bias[k] or 0) - 1 end end)
local bidx = G.vcyl(c, body, EN, 16.5, 36.5, { tok = btok, bias = bias })
-- dent: inverted light in a small oval
local dent = c:ellipse(30, 35, 2.5, 2)
dent:each(function(x, y) local i = bidx[K(x, y)] or 3
  local up = (x - 30) + (y - 35) < 0
  c:put(x, y, EN[max(1, min(6, i + (up and -2 or 1)))], btok) end)
c:put(28, 34, EN[1], btok) c:put(29, 33, EN[1], btok)
-- specular streak on the lit side
for y = 32, 45 do if y ~= 39 then c:put(20, y, EN[6], btok) end end
c:put(20, 31, G.CREAM, btok) c:put(21, 31, EN[6], btok)

-- rolled rims (top bead + bottom), dark seam row under each
local rtok = G.tok("rim")
local top = c:rrect(16, 25, 37, 28, 1)
G.vcyl(c, top, ST, 15.5, 37.5, { tok = rtok })
for x = 17, 36 do c:put(x, 26, (x < 25) and ST[6] or ST[4], rtok) c:put(x, 28, ST[2], rtok) end
local bot = c:rrect(16, 51, 37, 54, 1)
G.vcyl(c, bot, ST, 15.5, 37.5, { tok = rtok })
for x = 17, 36 do c:put(x, 52, (x < 25) and ST[5] or ST[4], rtok) c:put(x, 54, ST[1], rtok) end
-- handle feet rivets
c:put(20, 25, ST[1], rtok) c:put(33, 25, ST[1], rtok)

-- crack near the base, lit lip beside it
G.pts(c, { {21,42}, {22,43}, {22,44}, {21,45}, {22,46}, {23,47}, {23,48}, {22,49}, {22,50} }, EN[1], btok)
G.pts(c, { {20,43}, {21,44}, {20,46}, {21,47} }, EN[5], btok)
-- leaking drops
local wt = G.tok("water")
local function drop(x, y)
  c:put(x, y, WA[3], wt) c:put(x, y + 1, WA[2], wt) c:put(x + 1, y + 1, WA[2], wt) c:put(x, y + 2, WA[1], wt) c:put(x + 1, y + 2, WA[1], wt)
  c:put(x, y + 1, WA[4], wt)
end
drop(14, 44) drop(12, 50)

-- quirk: hand-painted daisy on the drum
local PE = { "#c94f84", "#f5809f", "#ffc4d8" }
local fx, fy = 25, 38
local ftok = G.tok("daisy")
G.pts(c, { {fx, fy - 2}, {fx - 2, fy}, {fx + 2, fy}, {fx, fy + 2} }, PE[2], ftok)
G.pts(c, { {fx - 1, fy - 2}, {fx - 2, fy - 1} }, PE[3], ftok)
G.pts(c, { {fx + 1, fy + 2}, {fx + 2, fy + 1} }, PE[1], ftok)
c:put(fx, fy, BR[4], ftok) c:put(fx - 1, fy - 1, PE[3], ftok) c:put(fx + 1, fy + 1, PE[1], ftok)
G.pts(c, { {fx - 1, fy + 1}, {fx + 1, fy - 1} }, PE[2], ftok)
c:put(fx, fy + 3, EN[2], ftok) c:put(fx, fy + 4, EN[2], ftok) c:put(fx + 1, fy + 4, EN[3], ftok)

-- flying brass rose (face with holes, short neck)
local rtk = G.tok("rose")
local rose = c:ellipse(55.5, 15.5, 3.5, 3.5)
local rn = X.sphere(55, 15, 4.5, rose)
for _, v in pairs(rn) do v[3] = v[3] * 1.6 end
G.toneN(c, rose, rn, BR, { tok = rtk, amb = 0.15 })
for _, p in ipairs{ {54,13}, {56,13}, {53,15}, {55,15}, {57,15}, {54,17}, {56,17} } do c:put(p[1], p[2], BR[1], rtk) end
c:put(53, 14, BR[6], rtk) c:put(55, 12, BR[6], rtk)
local neck = G.cyl(c, 52.5, 18.5, 50.5, 20.5, function() return 1.2 end, BR, { tok = G.tok("neck") })
c:put(51, 21, BR[2])

G.save(c)
