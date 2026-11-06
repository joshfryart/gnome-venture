-- greenhouse-mossy (aC10_2 Opus pass): an old lean-to glasshouse seen end-on, propped against a tall fragment of warm
-- stone garden wall. Weathered wooden frame (grain ticks, sagging slope rafter), green-tinged old glass, moss cushions on
-- the wall top, the rafter and the plinth, ivy creeping down the wall. One pane is cracked with a shard missing; the shard
-- lies chipped on the plinth and a tendril has found the gap. Overgrown tomato jungle inside.
-- quirk: a red toadstool has sprouted from the moss on the plinth corner.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_2.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, sqrt, max, min = math.floor, math.sqrt, math.max, math.min
local c = D.new("greenhouse-mossy")
local W, M, GG = D.WOOD, D.MOSS, D.GLG
c:groundShadow(33, 54, 24, 2)

-- stone wall + plinth
D.blocks(c, 9, 15, 18, 52, D.WST, { bh = 4, bw = { 4, 6 }, seed = 41, name = "wall" })
D.blocks(c, 19, 47, 55, 52, D.WST, { bh = 3, bw = { 5, 8 }, seed = 43, name = "plinth" })
-- end glass panel
local panel = HP.poly{ { 19, 17 }, { 54, 32 }, { 54, 45 }, { 19, 45 } }
local gt = D.glass(c, panel, { ramp = GG, phase = 5, period = 13, base = 0.6 })
-- overgrown inside
D.bush(c, 20, 52, 45, 12, panel, { fruit = D.RED, seed = 45, fdens = 0.04 })
D.bush(c, 21, 34, 45, 18, panel, { seed = 47 })
-- frame (weathered wood)
local ft = D.tok("wood", true)
local function slopeY(x) return 17 + (x - 19) * 15 / 35 end
for _, x in ipairs{ 28, 37, 46 } do D.vbar(c, x, floor(slopeY(x) + 1), 45, 1, ft, W) end
D.vbar(c, 19, 17, 45, 2, ft, W) D.vbar(c, 53, 31, 45, 2, ft, W)
D.hbar(c, 21, 52, 36, 1, ft, W)
D.hbar(c, 18, 55, 45, 2, ft, W)
-- sagging slope rafter (2px, dips 1px mid-span)
for x = 18, 55 do
  local y = floor(slopeY(x) + 0.5) + ((x > 30 and x < 44) and 1 or 0)
  c:put(x, y - 1, W[5], ft) c:put(x, y, W[3], ft)
  if x % 5 == 2 then c:put(x, y, W[2], ft) end                                    -- grain/checks
end
for y = 20, 44, 6 do c:put(19, y, W[4], ft) end
-- cracked pane: x 38..45, y 37..44
local hole = HP.poly{ { 40, 38 }, { 44, 37 }, { 43, 41 }, { 41, 40 } }
local hk = D.tok("hole", true)
hole:each(function(x, y) c:put(x, y, (y <= 38) and GG[1] or "#2e4a3e", hk) end)
local crack = HP.line({ { 41, 40 }, { 40, 42 }, { 41, 44 } }, 1):add(HP.line({ { 43, 41 }, { 45, 43 } }, 1))
  :add(HP.line({ { 40, 38 }, { 38, 39 } }, 1))
crack:each(function(x, y) if c.own[y * 64 + x] == gt then c:put(x, y, GG[6], gt) end end)
c:put(40, 43, GG[2], gt) c:put(44, 42, GG[2], gt)
D.rims(c, gt, GG)
-- tendril out of the hole
local tt = D.tok("tendril")
for _, p in ipairs{ { 43, 38 }, { 44, 37 }, { 45, 36 }, { 46, 35 }, { 47, 34 } } do c:put(p[1], p[2], D.LEAF[4], tt) end
c:put(47, 33, D.LEAF[5], tt) c:put(48, 33, D.LEAF[4], tt) c:put(48, 34, D.LEAF[2], tt) c:put(46, 34, D.LEAF[3], tt)

-- moss cushions
local function moss(cx, cy, rx, ry, seed)
  local m = HP.mask()
  for i = 0, 5 do
    local a = X.hash(i, 1, seed)
    m:add(G.rell(cx - rx + 2 * rx * i / 5, cy - ry * 0.3 * a, 1, 0, 1.8 + a, ry))
  end
  local tok = D.vol(c, m, M, 2, { name = "moss", amb = 0.12, wrap = 0.35 })
  m:each(function(x, y) if X.hash(x, y, seed) < 0.12 and m:has(x, y + 1) then c:put(x, y, M[6], tok) end end)
  return m
end
moss(13.5, 14, 5, 2.4, 1)
moss(27, 20.5, 4, 1.8, 2)
moss(49, 31, 3, 1.6, 3)
moss(23, 46, 3, 1.4, 4)
moss(52, 46, 3.2, 1.6, 5)
-- ivy on the wall
local iv = D.tok("ivy")
local stem = { { 15, 17 }, { 15, 20 }, { 14, 23 }, { 15, 26 }, { 16, 29 }, { 15, 32 } }
for i = 1, #stem - 1 do HP.line({ stem[i], stem[i + 1] }, 1):each(function(x, y) c:put(x, y, D.LEAF[2], iv) end) end
for _, p in ipairs{ { 13, 21 }, { 16, 24 }, { 13, 28 }, { 16, 31 } } do
  local x, y = p[1], p[2]
  c:put(x, y, D.LEAF[5], iv) c:put(x + 1, y, D.LEAF[4], iv) c:put(x, y + 1, D.LEAF[4], iv) c:put(x + 1, y + 1, D.LEAF[2], iv)
  c:put(x - 1, y, D.LEAF[3], iv)
end
-- fallen shard on the plinth (chip)
local sh = D.tok("shard")
c:put(46, 47, GG[6], sh) c:put(47, 47, GG[4], sh) c:put(47, 48, GG[3], sh)

-- quirk: toadstool on the plinth moss
local tst = D.tok("toad")
for y = 42, 45 do c:put(53, y, D.CREAM, tst) c:put(54, y, "#d8c8a8", tst) end
local cap = G.rell(53.5, 41, 1, 0, 3.4, 2)
cap:clip(HP.rect(0, 0, 63, 42))
local ct = D.vol(c, cap, D.RED, 1.6, { name = "cap" })
c:put(52, 40, D.CREAM, ct) c:put(55, 41, D.CREAM, ct) c:put(53, 39, D.RED[6], ct)
D.save(c, "greenhouse-mossy")
