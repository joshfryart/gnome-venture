-- broken-soil-probe (aB12_3, Opus single pass). A T-handle soil probe: turned wooden crossbar, brass collar,
-- slim steel shaft with a long sample slot showing a banded soil core, brass depth marks, pointed tip.
-- Material: cylinder-lit wood with grain and pale end grain, steel shaft with a bright bevel edge + specular streak,
-- soil core layers, AO under the crossbar and around the collar.
-- broken: the shaft has snapped below the slot; the lower half with the tip hangs tilted and apart, jagged ends,
-- two steel chips flying.
-- quirk: an earthworm has looped itself round the broken tip, clods still stuck on the point.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, sqrt, max, min = math.floor, math.sqrt, math.max, math.min
local c = G.start(debug.getinfo(1, "S").source)
local WD, ST, BR, SO = G.WOOD, G.STEEL, G.BRASS, G.SOIL

-- upper shaft (vertical), drawn before the collar
local stok = G.tok("steel")
local sx = 31.5
local up = c:rect(30, 14, 33, 37)
-- jagged break at the bottom
up:cut(c:poly{ {29,35.5}, {31,33.5}, {32.2,36}, {34.5,33.5}, {34.5,38}, {29,38} })
local uidx = G.vcyl(c, up, ST, 29.6, 33.6, { tok = stok })
-- sample slot: a 2px window with banded soil core
local slot = c:rect(31, 19, 32, 30)
local bands = { SO[2], SO[3], SO[3], SO[4], SO[2], SO[3], SO[4], SO[4], SO[3], SO[1], SO[2], SO[3] }
for y = 19, 30 do
  c:put(31, y, bands[y - 18], stok)
end
for y = 19, 30 do c:put(32, y, bands[y - 18] == SO[4] and SO[3] or SO[1], stok) end  -- shade side of the core
c:put(31, 18, ST[1], stok) c:put(32, 18, ST[1], stok)   -- slot top lip shadow
c:put(31, 31, ST[5], stok) c:put(32, 31, ST[4], stok)   -- slot bottom lip lit
-- bright bevel edge on the lit side + specular
for y = 15, 33 do if up:has(30, y) and (y < 19 or y > 30) then c:put(30, y, ST[5], stok) end end
c:put(30, 16, G.CREAM, stok) c:put(30, 17, ST[6], stok)
-- brass depth marks below the slot
for _, y in ipairs{ 33 } do c:put(30, y, BR[5], stok) c:put(31, y, BR[4], stok) c:put(32, y, BR[3], stok) c:put(33, y, BR[2], stok) end

-- crossbar (turned wood), axis horizontal, tapered ends
local wtok = G.tok("wood")
local bar, BT, BS, bidx = G.cyl(c, 15, 10, 48, 10, function(t)
  local e = math.abs(t - 0.5) * 2
  if e > 0.93 then return 1.8 end
  return 2.6 - e * 0.5 - (e > 0.4 and e < 0.5 and 0.6 or 0)
end, WD, { tok = wtok })
-- grain lines along the bar
bar:each(function(x, y) local k = K(x, y)
  local s = BS[k]
  if s > -0.35 and s < 0.05 and (x * 7) % 9 > 2 then c:put(x, y, WD[max(1, (bidx[k] or 3) - 1)], wtok) end
end)
-- pale end grain caps
for y = 8, 12 do
  if bar:has(15, y) then c:put(15, y, (y <= 9) and WD[6] or WD[5], wtok) end
  if bar:has(48, y) then c:put(48, y, (y <= 9) and WD[4] or WD[3], wtok) end
end
c:put(20, 8, WD[6], wtok) c:put(21, 8, WD[6], wtok) c:put(22, 8, G.CREAM, wtok)

-- brass collar joining bar and shaft
local btok = G.tok("brass")
local col = c:rect(28, 12, 35, 15):cut(c:rect(28, 15, 28, 15)):cut(c:rect(35, 15, 35, 15))
G.vcyl(c, col, BR, 27.6, 35.6, { tok = btok })
for x = 29, 34 do c:put(x, 12, BR[2], btok) end      -- AO row under the bar
c:put(29, 13, BR[6], btok) c:put(30, 13, BR[6], btok)
-- AO on the shaft under the collar
c:put(31, 16, ST[2], stok) c:put(32, 16, ST[1], stok) c:put(33, 16, ST[1], stok)

-- lower half: tilted, with the tip (dropped apart)
local ltok = G.tok("steel2")
local lm, LT, LS, lidx = G.cyl(c, 34.5, 41, 39.5, 58, function(t)
  if t > 0.72 then return max(0.2, 1.9 * (1 - t) / 0.28) end
  return 1.9
end, ST, { tok = ltok })
-- jagged top of the broken piece (cut a notch)
for _, p in ipairs{ {35,41}, {36,41}, {34,42} } do lm.s[K(p[1], p[2])] = nil c.pix[p[2] * 64 + p[1]] = nil c.own[p[2] * 64 + p[1]] = nil end
lm:each(function(x, y) local k = K(x, y)
  if LS[k] < -0.45 and LT[k] < 0.7 then c:put(x, y, ST[5], ltok) end
  local d = LT[k] * 17.7
  if d > 4.5 and d < 5.5 then c:put(x, y, lidx[k] > 3 and BR[4] or BR[2], ltok) end
end)
c:put(35, 44, ST[6], ltok) c:put(36, 47, G.CREAM, ltok)
-- clods on the point
local ctok = G.tok("clod")
G.pts(c, { {38,55}, {39,56} }, SO[3], ctok) G.pts(c, { {40,55}, {41,56} }, SO[2], ctok) c:put(38, 56, SO[4], ctok) c:put(40, 57, SO[1], ctok)

-- quirk: earthworm looped round the tip piece
local WM = { "#8a3a4c", "#c45e6c", "#e98e8e", "#ffc0b0" }
local wk = G.tok("worm")
local worm = { {33,49,2}, {34,50,3}, {35,50,3}, {36,50,2}, {37,49,3}, {38,49,4}, {39,49,3}, {40,50,2}, {41,51,2}, {41,52,1}, {42,53,2}, {43,53,3} }
for _, p in ipairs(worm) do c:put(p[1], p[2], WM[p[3]], wk) end
c:put(32, 48, WM[3], wk) c:put(32, 49, WM[2], wk) c:put(33, 48, WM[4], wk)   -- head, lit
c:put(36, 49, WM[1], wk)  -- ring groove (clitellum shadow)

-- flying steel chips + a crumb of soil core
local ch1 = c:poly{ {25,40}, {28,39}, {27,42} }
G.toneN(c, ch1, X.pillow(ch1, 1), ST, { tok = G.tok("ch1") })
c:put(26, 40, ST[6])
c:put(41, 38, ST[4]) c:put(42, 38, ST[2]) c:put(41, 39, ST[3])
c:put(28, 44, SO[3]) c:put(29, 44, SO[2])

G.save(c)
