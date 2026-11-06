-- greenhouse-2 (aC10_2 Opus pass): tier 2. Long-side view of a slim span glasshouse on a dressed-stone plinth:
-- glass walls with white-painted bars, a central glazed door with a wooden kick panel and brass knob, a sloped glass
-- roof with rafters and ridge cresting, one roof vent propped open on a stay, a red swallowtail pennant on the ridge.
-- Tomato bushes behind the glass. Glass: gradient + "/" reflection streaks, bright left rims, AO under every bar.
-- quirk: a bumblebee is heading in through the propped-open vent.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_2.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor = math.floor
local c = D.new("greenhouse-2")
c:groundShadow(32, 54, 25, 2)

-- plinth + sill
D.blocks(c, 10, 47, 54, 52, D.STONE, { bh = 3, bw = { 6, 9 }, seed = 4 })
D.ledge(c, 9, 55, 45, D.STONE)

-- walls: glass, bushes, bars
local wall = HP.rect(11, 28, 53, 44)
local gw = D.glass(c, wall, { phase = 3, period = 15 })
D.bush(c, 13, 27, 44, 9, nil, { fruit = D.RED, seed = 2, fdens = 0.06 })
D.bush(c, 37, 51, 44, 8, nil, { fruit = D.RED, seed = 5, fdens = 0.06 })
local ft = D.tok("frame", true)
D.hbar(c, 13, 51, 34, 1, ft)
D.vbar(c, 11, 26, 44, 2, ft) D.vbar(c, 52, 26, 44, 2, ft)
D.vbar(c, 20, 28, 44, 1, ft) D.vbar(c, 44, 28, 44, 1, ft)
-- door
local dg = D.glass(c, HP.rect(29, 31, 35, 39), { phase = 9, period = 9, base = 0.66 })
D.vbar(c, 27, 28, 44, 2, ft) D.vbar(c, 36, 28, 44, 2, ft)
D.hbar(c, 29, 35, 30, 1, ft)
local wt = D.tok("door")
for y = 40, 44 do for x = 29, 35 do
  local i = 4
  if y == 40 then i = 5 elseif x == 29 then i = 5 elseif x == 35 or y == 44 then i = 3 end
  if (x == 31 or x == 33) and y > 40 and y < 44 then i = i - 1 end         -- board grooves
  c:put(x, y, D.WOOD[i], wt)
end end
D.hbar(c, 29, 35, 39, 1, ft)
c:put(34, 37, D.GOLD[5], wt) c:put(34, 38, D.GOLD[3], wt) c:put(33, 37, D.GOLD[4], wt)
D.rims(c, gw, D.GL) D.rims(c, dg, D.GL)
-- eave beam with gutter
D.hbar(c, 9, 55, 26, 2, ft)
for x = 9, 55 do c:put(x, 28, D.FR[2], ft) end
for x = 13, 51 do if not D.frames[D.own(c, x, 29)] then c:put(x, 29, c:get(x, 29), gw) D.shift(c, x, 29, D.GL, -1) end end

-- roof: trapezoid of glass
local roof = HP.poly{ { 10, 25 }, { 54, 25 }, { 46, 15 }, { 18, 15 } }
local gr = D.glass(c, roof, { phase = 0, period = 12, base = 0.74 })
for _, xe in ipairs{ 16, 24, 32, 40, 48 } do
  local xr = 32 + (xe - 32) * 14 / 22
  D.sbar(c, xe, 25, floor(xr + 0.5), 16, 4, ft)
end
D.sbar(c, 10, 25, 18, 15, 5, ft) D.sbar(c, 54, 25, 46, 15, 3, ft)
-- vent: dark opening and the propped pane
local open = HP.poly{ { 35, 19 }, { 41, 19 }, { 42, 23 }, { 35, 23 } }
local vt = D.tok("vent", true)
open:each(function(x, y) c:put(x, y, (y == 19) and D.IRON[2] or D.IRON[3], vt) end)
for x = 36, 41 do if (x + 21) % 4 < 2 then c:put(x, 22, D.LEAF[3], vt) end end    -- leaves seen inside
local pane = HP.poly{ { 35, 14 }, { 42, 14 }, { 42, 18 }, { 35, 18 } }
local pg = D.glass(c, pane, { phase = 2, period = 6, base = 0.8 })
D.hbar(c, 35, 42, 18, 1, ft, D.FR) D.vbar(c, 35, 14, 18, 1, ft) D.vbar(c, 42, 14, 18, 1, ft)
for x = 35, 42 do c:put(x, 13, D.FR[5], ft) end
c:put(41, 19, D.IRON[5], ft) c:put(41, 20, D.IRON[5], ft) c:put(42, 19, D.IRON[4], ft)          -- stay
D.rims(c, gr, D.GL)
-- ridge with cresting
D.hbar(c, 17, 47, 14, 1, ft, D.FR)
for x = 17, 47 do c:put(x, 14, D.FR[5], ft) end
for x = 19, 33, 3 do c:put(x, 13, D.FR[4], ft) end
c:put(17, 14, D.FR[6], ft)
-- flag
local pt = D.tok("pole", true)
for y = 6, 13 do c:put(47, y, D.IRON[5], pt) end
c:put(47, 5, D.GOLD[5], pt) c:put(48, 5, D.GOLD[3], pt) c:put(47, 4, D.GOLD[4], pt)
local flag = HP.poly{ { 48, 6 }, { 56, 7 }, { 53, 8.5 }, { 56, 10 }, { 48, 10 } }
local ftk = D.vol(c, flag, D.RED, 2, { name = "flag", cuts = { 0.2, 0.4, 0.58, 0.74, 0.88 } })
for x = 49, 54, 2 do c:put(x, 8, D.RED[3], ftk) end                              -- cloth fold
c:put(48, 6, D.RED[6], ftk)

-- quirk: bumblebee near the vent
local bee = {
  ".ww..",
  "wwy..",
  "KyKyK",
  ".yKy.",
}
local BC = { K = D.INK, y = D.GOLD[4], w = "#e8f4ff" }
local bt = D.tok("bee")
for yy, row in ipairs(bee) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if BC[ch] then c:put(21 + xx, 6 + yy, BC[ch], bt) end end end
D.save(c, "greenhouse-2")
