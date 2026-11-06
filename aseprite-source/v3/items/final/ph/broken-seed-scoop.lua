-- broken-seed-scoop (aB12_3, Opus single pass). A slim tin seed scoop: deep pressed bowl with a pouring lip
-- (upper-left), brass ferrule, turned wooden handle running to the lower-right.
-- Material: pillow-lit rolled tin rim with a bevel + specular streak, inverted (cavity) light inside the bowl,
-- seeds heaped in the bottom, crimped brass ferrule, handle with grain lines and a paler end grain, AO where parts meet.
-- broken: a jagged notch torn out of the bowl's right wall with a crack running in, seeds spilling out of it,
-- a flying tin chip and a splinter lifting off the handle.
-- quirk: a twine loop through the handle end, still knotted.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, sqrt, max, min = math.floor, math.sqrt, math.max, math.min
local c = G.start(debug.getinfo(1, "S").source)
local ST, BR, WD, SD = G.STEEL, G.BRASS, G.WOOD, G.SEED
local ux, uy = 0.74, 0.67
local l = sqrt(ux*ux + uy*uy) ux, uy = ux / l, uy / l

-- handle first (bowl paints over its root)
local wtok = G.tok("wood")
local hm, HT, HS, hidx = G.cyl(c, 36, 35, 50, 48, function(t)
  if t > 0.9 then return 2.3 end
  return 1.45 + t * 0.35
end, WD, { tok = wtok })
-- grain: two broken lines along the handle, lit-side and shade-side
hm:each(function(x, y) local k = K(x, y)
  local t, s = HT[k], HS[k]
  if t > 0.12 and t < 0.86 then
    if s > -0.45 and s < -0.05 and (floor(t * 30) % 4 ~= 0) then c:put(x, y, WD[max(1, (hidx[k] or 3) - 1)], wtok) end
    if s > 0.5 and (floor(t * 30) % 5 == 2) then c:put(x, y, WD[1], wtok) end
  end
end)
-- end knob: paler end grain + hole for the twine
c:put(50, 48, WD[6], wtok) c:put(49, 47, WD[5], wtok) c:put(50, 47, WD[5], wtok)
c:put(51, 49, WD[2], wtok) c:put(50, 49, WD[1], wtok)
-- splinter lifting off the handle (damage)
G.pts(c, { {43,42}, {44,41}, {45,40}, {46,40} }, WD[5], wtok) c:put(44, 42, WD[2], wtok)

-- brass ferrule (crimped)
local btok = G.tok("brass")
local fm = G.cyl(c, 32, 31, 38, 37, function() return 2.4 end, BR, { tok = btok })
fm:each(function(x, y) local d = (x - 32) + (y - 31)
  if d == 6 or d == 7 then c:put(x, y, BR[2], btok) end end)  -- crimp groove
c:put(33, 31, BR[6], btok) c:put(34, 32, BR[6], btok)

-- bowl: outer shell, flattened pour lip at the front (upper-left)
local stok = G.tok("tin")
local CX, CY = 22, 20
local outer = G.rell(CX, CY, ux, uy, 14.5, 9)
outer:add(G.rell(CX + ux * 8, CY + uy * 8, ux, uy, 8, 7))
-- notch torn out of the right wall
local notch = c:poly{ {23,6}, {33,6}, {31,11}, {34,15}, {28,19}, {27,15}, {24,13} }
outer:cut(notch)
local inner = G.rell(CX - ux * 1.2, CY - uy * 1.2, ux, uy, 11.4, 6.2)
inner:clip(outer:shrink(2))
local rim = outer:copy():cut(inner)
local ridx = G.lit(c, rim, ST, { R = 2, tok = stok, amb = 0.12 })
-- cavity: inverted light, one step darker, AO toward the back
local cbias = {}
inner:each(function(x, y) local k = K(x, y)
  local a = (x + .5 - CX) * ux + (y + .5 - CY) * uy
  cbias[k] = a > 5 and -2 or -1 end)
local cidx = G.lit(c, inner, ST, { R = 4, invert = true, bias = cbias, tok = stok, amb = 0.1 })
-- seeds heaped at the back of the bowl
local stk = G.tok("seed")
local function seed(x, y, dir)
  if dir == 1 then
    c:put(x, y, SD[5], stk) c:put(x + 1, y, SD[4], stk) c:put(x, y + 1, SD[3], stk) c:put(x + 1, y + 1, SD[2], stk) c:put(x + 2, y + 1, SD[1], stk)
  else
    c:put(x, y, SD[4], stk) c:put(x, y + 1, SD[3], stk) c:put(x + 1, y + 1, SD[2], stk) c:put(x + 1, y, SD[5], stk) c:put(x + 1, y + 2, SD[1], stk)
  end
end
for _, s in ipairs{ {24,22,1}, {27,24,2}, {21,24,1}, {25,26,1}, {28,27,1}, {22,27,2}, {19,21,2}, {30,22,2}, {26,20,1}, {23,19,2}, {29,25,1}, {20,26,1}, {24,29,1}, {27,29,2}, {31,27,1} } do
  if inner:has(s[1], s[2]) then seed(s[1], s[2], s[3]) end
end
-- rim bevel: bright lip along the upper-left edge + specular streak
outer:edge():each(function(x, y)
  local k = K(x, y)
  if (ridx[k] or 0) >= 5 and (x + y) < 30 then c:put(x, y, ST[6], stok) end end)
G.pts(c, { {10,15}, {11,14}, {12,13} }, G.CREAM, stok)
-- seam where bowl meets ferrule (ambient dark row)
G.pts(c, { {31,31}, {32,30}, {30,31}, {31,32} }, ST[1], stok)
-- crack running from the notch into the wall
G.pts(c, { {28,16}, {27,17}, {27,18}, {26,19} }, ST[1], stok)
c:put(29, 17, ST[2], stok)
-- torn edge bright metal
G.pts(c, { {25,11}, {29,13} }, ST[6], stok)

-- spilled seeds falling from the notch
seed(33, 11, 2) seed(36, 15, 1)
-- flying tin chip
local chip = c:poly{ {37,6}, {41,7}, {39,10} }
G.lit(c, chip, ST, { R = 1, tok = G.tok("chip") })
c:put(38, 7, ST[6])

-- quirk: knotted twine loop through the handle end (twist pattern)
local TW = { "#7a5a32", "#b08a4e", "#e2c88a" }
local ttok = G.tok("twine")
local loop = { {52,49}, {53,50}, {54,51}, {54,52}, {54,53}, {53,54}, {52,54}, {51,54}, {50,53}, {50,52}, {51,51} }
for i, p in ipairs(loop) do c:put(p[1], p[2], i % 2 == 0 and TW[3] or TW[2], ttok) end
c:put(55, 54, TW[1], ttok) c:put(56, 55, TW[2], ttok) c:put(54, 55, TW[1], ttok)

G.save(c)
