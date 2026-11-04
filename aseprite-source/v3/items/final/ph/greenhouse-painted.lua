-- greenhouse-painted (aC10_3 Opus pass). Gable-end view of a tall, slim A-frame glasshouse whose glazing bars are
-- freshly painted sea-teal with coral bargeboards and a coral finial. Central door painted mint with a glazed top and a
-- hand-painted daisy on the kick panel, brass knob. Brick plinth with a cream-painted coping. Glass: gradient + "/"
-- reflection streaks, bright left rims, AO under bars. Ferns and a geranium behind the glass.
-- quirk: the painter left the paint tin by the step, brush still in it, a coral drip running down its side.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_3.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, max, min = math.floor, math.max, math.min
local c = D.new("greenhouse-painted")
local TEAL  = { "#1e3f57", "#245f73", "#2f8a92", "#49b2ad", "#7fd6c6", "#c4f2e2" }
local CORAL = { "#5a1c34", "#8e2a40", "#c8424a", "#ec6a5e", "#ff9c84", "#ffd2bc" }
local MINT  = { "#2c5048", "#3f7462", "#5c9c80", "#84c09c", "#b0dcb8", "#def2d6" }
local TIN   = { "#34344e", "#545670", "#7a7d96", "#a6a9bc", "#cfd1dc", "#eeeef2" }
local CRM   = { "#6e5a52", "#9a8270", "#c4ad90", "#e2cfae", "#f4e6c8", "#fff4d6" }

c:groundShadow(32, 53, 24, 1.5)
-- plinth: brick courses + cream painted coping
D.blocks(c, 13, 47, 51, 52, D.BRICK, { bh = 3, bw = { 5, 7 }, seed = 7 })
D.ledge(c, 12, 52, 45, CRM)

-- glass: walls + gable in one sheet
local body = HP.poly{ { 14, 27 }, { 32, 9 }, { 50, 27 }, { 50, 44 }, { 14, 44 } }
local gw = D.glass(c, body, { phase = 5, period = 13, base = 0.68 })
-- plants behind glass (ferns left, geranium right)
D.bush(c, 16, 27, 44, 9, nil, { ramp = D.LEAF, seed = 3 })
D.bush(c, 37, 48, 44, 8, nil, { ramp = D.MOSS, seed = 8, fruit = CORAL, fdens = 0.07 })
local ft = D.tok("frame", true)
-- wall bars
D.vbar(c, 14, 27, 44, 2, ft, TEAL) D.vbar(c, 49, 27, 44, 2, ft, TEAL)
D.vbar(c, 21, 27, 44, 1, ft, TEAL) D.vbar(c, 43, 27, 44, 1, ft, TEAL)
D.hbar(c, 15, 27, 36, 1, ft, TEAL) D.hbar(c, 37, 49, 36, 1, ft, TEAL)
-- tie beam (eave line) across the gable foot
D.hbar(c, 13, 51, 26, 2, ft, TEAL)
-- gable glazing: king post + two short posts + collar
D.vbar(c, 32, 10, 25, 1, ft, TEAL)
D.vbar(c, 24, 18, 25, 1, ft, TEAL) D.vbar(c, 40, 18, 25, 1, ft, TEAL)
D.hbar(c, 25, 39, 18, 1, ft, TEAL)
-- round oculus in the gable apex (painted coral ring)
local ring = HP.mask()
for y = 11, 17 do for x = 29, 35 do local d = (x - 32) ^ 2 + (y - 14) ^ 2 if d <= 9.5 and d >= 3.5 then ring:set(x, y) end end end
ring:each(function(x, y) c:put(x, y, CORAL[(x + y < 46) and 5 or ((x + y > 47) and 3 or 4)], ft) end)

-- door: mint, glazed top, painted daisy on the kick panel
local dt = D.tok("door", true)
local dg = D.glass(c, HP.rect(29, 31, 35, 37), { phase = 2, period = 7, base = 0.72 })
D.vbar(c, 27, 29, 44, 2, dt, MINT) D.vbar(c, 36, 29, 44, 2, dt, MINT)
D.hbar(c, 29, 35, 29, 2, dt, MINT) D.hbar(c, 29, 35, 38, 1, dt, MINT)
for y = 39, 44 do for x = 29, 35 do
  local i = 4
  if y == 39 or x == 29 then i = 5 elseif x == 35 or y == 44 then i = 3 end
  c:put(x, y, MINT[i], dt)
end end
-- daisy: cream petals, gold eye, painted stem
for _, p in ipairs{ { 32, 40 }, { 31, 41 }, { 33, 41 }, { 32, 42 } } do c:put(p[1], p[2], CRM[6], dt) end
c:put(32, 41, D.GOLD[4], dt) c:put(32, 43, MINT[2], dt) c:put(33, 43, MINT[3], dt)
-- knob
c:put(35, 34, D.GOLD[5], dt) c:put(35, 35, D.GOLD[3], dt)
D.rims(c, gw, D.GL) D.rims(c, dg, D.GL)

-- bargeboards: 2 px coral, lit outer edge
local bt = D.tok("barge", true)
for i = 0, 19 do
  local yl = 27 - i
  c:put(13 + i, yl, CORAL[5], bt) c:put(14 + i, yl, CORAL[3], bt)
  c:put(51 - i, yl, CORAL[4], bt) c:put(50 - i, yl, CORAL[2], bt)
end
c:put(32, 7, CORAL[5], bt) c:put(32, 8, CORAL[4], bt)
-- finial: coral ball on a teal spike
c:put(32, 6, TEAL[4], bt)
c:put(31, 5, CORAL[5], bt) c:put(32, 5, CORAL[3], bt) c:put(31, 4, CORAL[6], bt) c:put(32, 4, CORAL[4], bt)

-- step stone under the door
local st = D.tok("step", true)
for x = 26, 38 do c:put(x, 45, D.STONE[(x == 26) and 6 or 5], st) c:put(x, 46, D.STONE[(x == 38) and 2 or 3], st) end

-- quirk: paint tin with brush, coral drip
local tin = HP.rect(52, 46, 57, 52)
local tt = D.tok("tin")
tin:each(function(x, y)
  local i = ({ 5, 6, 5, 4, 3, 2 })[x - 51]
  if y == 52 then i = i - 1 end
  c:put(x, y, TIN[max(1, i)], tt)
end)
for x = 52, 57 do c:put(x, 46, CORAL[(x < 55) and 5 or 3], tt) end                 -- paint at the rim
c:put(52, 47, CORAL[4], tt) c:put(52, 48, CORAL[3], tt) c:put(53, 47, CORAL[3], tt)   -- drip down the side
c:put(54, 49, CORAL[2], tt) c:put(55, 49, CORAL[2], tt) c:put(56, 49, CORAL[2], tt)   -- label band
c:put(54, 50, TIN[2], tt)
-- brush: wooden handle leaning out to the right, ferrule
local bh = D.tok("brush")
for i = 0, 6 do c:put(55 + floor(i / 2), 45 - i, (i < 2) and TIN[5] or D.WOOD[(i % 2 == 0) and 5 or 4], bh) end
c:put(58, 38, D.WOOD[3], bh)
D.save(c, "greenhouse-painted")
