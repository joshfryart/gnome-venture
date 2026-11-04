-- heather-seed (final, Opus single pass). A dry heather seed capsule (round, tan, split into four valves round a dark
-- mouth, pale papery calyx cupping it) spilling tiny russet dust-seeds across a torn scrap of a dusky grey-green leaf
-- (midrib, swept veins, ragged torn right end, cool reflected edge, AO + contact shadows). One dust-seed has sprouted
-- into a slim woody sprig with four ranks of needle leaves, the true heather leaf, ending in a bud tip.
-- quirk: a single fallen mauve heather bell lies on the leaf, mouth toward us.
local NAME = "heather-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min = math.floor, math.abs, math.sin, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#1e3434", "#2c4a44", "#3e6450", "#58805e", "#7c9e72", "#a9c290" }
local VEIN, COOL, TORN = "#c8dca8", "#4f7a80", "#d8e4b0"
local CAP = { "#3a2218", "#5c3a24", "#84582f", "#a8783e", "#cc9e5c", "#ecca8e" }
local CALYX = { "#6e5e40", "#a89468", "#d2c294", "#efe4bc" }
local DUST = { "#4a2420", "#7a3c28", "#b0603a", "#e09060" }
local WOOD = { "#4a2a2a", "#764238", "#a0644a" }
local NEED = { "#1c3e30", "#2c5a3c", "#3f7a48", "#5c9a52", "#84ba64", "#b4d888" }
local BELL = { "#4a2050", "#7a3478", "#a8509c", "#cc78bc", "#e8a4d8", "#fbd2ee" }

-- leaf scrap
local lm, ln, LT, LS, len = A.blade(6, 53, 30, 44, 57, 47, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 7.6 * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.75)
end, { fold = 0.34 })
local torn = A.tear(lm, LT, LS, 0.84, 0.05, 11, 0.06)

-- capsule + calyx masks
local CX, CY = 37, 42
local cm, cn = A.oval(CX, CY, 4.3, 3.8, 0, 0.9)
local calyx = HP.mask()
for _, q in ipairs{ {32,45},{33,46},{34,46},{35,47},{36,47},{37,47},{38,47},{39,47},{40,46},{41,46},{42,45},{31,44},{43,44} } do calyx:set(q[1], q[2]) end
calyx:cut(cm)
local all = cm:copy():add(calyx)

-- dust seeds (x, y, wide?)
local dust = { {22,47,1},{26,49,0},{28,46,1},{30,50,0},{17,50,1},{32,48,0},{13,52,0},{44,48,1},{24,51,0} }
local dm = HP.mask()
for _, d in ipairs(dust) do dm:set(d[1], d[2]) if d[3] == 1 then dm:set(d[1] + 1, d[2]) end end

-- sprout from the seed at (20,46)
local sp = { { 20, 46 }, { 19, 38 }, { 22, 28 }, { 21, 15 } }
local sm = A.tube(sp, function(t) return t < 0.55 and 1.15 or 0.95 end)

local bias = {}
X.ao(bias, lm, all, 1, -1) A.cast(bias, lm, all, 1, 2, -1) A.cast(bias, lm, all, 2, 2, -1)
A.cast(bias, lm, dm, 1, 1, -1)
A.cast(bias, lm, sm, 1, 1, -1)
local ltok = A.tok("leaf")
A.leaf(c, lm, ln, LT, LS, len, LEAF, { bias = bias, tok = ltok, vein = VEIN, per = 6.5, sweep = 4, cool = COOL })
torn:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, TORN, ltok) end end)
for _, q in ipairs{ {5,54,3},{4,55,2} } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- quirk: fallen bell floret (lying, mouth toward lower-left), with contact shadow
local btok = A.tok("bell")
local bm, bn = A.oval(50, 42, 3.2, 2.6, -0.5, 0.9)
bm:shift(1, 2):each(function(x, y) if lm:has(x, y) and not bm:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
local bidx = A.shade(c, bm, bn, BELL, { tok = btok, amb = 0.12 })
-- mouth: dark oval at the lower-left end, 4 tiny lobes
for _, q in ipairs{ {47,43,1},{48,44,1},{47,44,2},{48,43,2} } do c:put(q[1], q[2], BELL[q[3]], btok) end
for _, q in ipairs{ {46,42,4},{47,45,3},{46,44,3} } do c:put(q[1], q[2], BELL[q[3]], btok) end
c:put(51, 40, BELL[6], btok)
-- tiny pedicel
c:put(53, 40, NEED[3], btok) c:put(54, 39, NEED[2], btok)

-- dust seeds: russet, lit left, dark right, glint
local dtok = A.tok("dust")
for i, d in ipairs(dust) do
  if d[3] == 1 then c:put(d[1], d[2], DUST[3], dtok) c:put(d[1] + 1, d[2], DUST[2], dtok)
    if i % 2 == 1 then c:put(d[1], d[2], DUST[4], dtok) end
  else c:put(d[1], d[2], (i % 3 == 0) and DUST[3] or DUST[2], dtok) end
end

-- calyx (papery straw sepals)
local ktok = A.tok("calyx")
calyx:each(function(x, y) local i = (x < CX) and 3 or 2 if y >= 47 then i = i - 1 end if x == 31 or x == 43 then i = 4 end
  c:put(x, y, CALYX[max(1, i)], ktok) end)
-- capsule: four valves, seams radiating from the open mouth, dark mouth with seeds inside
local ptok = A.tok("capsule")
local cbias = {}
local cidx = A.shade(c, cm, cn, CAP, { tok = ptok, bias = cbias, amb = 0.1 })
for _, q in ipairs{ {36,41,1},{37,41,1},{38,41,2},{36,40,2},{37,40,1} } do c:put(q[1], q[2], CAP[q[3]], ptok) end
c:put(37, 40, DUST[3], ptok)
-- seams (darker step) toward the four valve edges
for _, q in ipairs{ {35,42},{34,43},{39,42},{40,43},{37,43},{37,44},{35,39},{34,38},{39,39},{40,38} } do
  if cm:has(q[1], q[2]) then local k = K(q[1], q[2]) c:put(q[1], q[2], CAP[max(1, (cidx[k] or 3) - 2)], ptok) end end
-- valve lips: lit rim on the upper-left of the mouth, one specular
c:put(35, 40, CAP[6], ptok) c:put(36, 39, CAP[6], ptok) c:put(34, 41, CAP[5], ptok)

-- sprout: woody red-brown base turning green, needle leaves in pairs, bud tip
local stok = A.tok("sprig")
local sm2, sn2, ST, SS = A.tube(sp, function(t) return t < 0.55 and 1.15 or 0.95 end)
sm2:each(function(x, y) local k = K(x, y)
  local woody = ST[k] < 0.45
  local r = woody and WOOD or { NEED[2], NEED[3], NEED[5] }
  c:put(x, y, r[SS[k] < -0.2 and 3 or (SS[k] > 0.3 and 1 or 2)], stok) end)
-- husk of the seed at the foot
c:put(19, 47, DUST[2], stok) c:put(20, 47, DUST[1], stok) c:put(21, 47, DUST[2], stok) c:put(19, 46, DUST[4], stok)
-- needles: pairs every 3 rows, sweeping up and out, shorter toward the tip
local ntok = A.tok("needles")
for i = 0, 9 do
  local t = 0.24 + i * 0.075
  local x, y = A.bez(sp, t)
  x, y = floor(x + .5), floor(y + .5)
  local L = (i < 7) and 3 or 2
  for j = 1, L do
    local yy = y - floor((j + 1) / 2)
    c:put(x - 1 - j, yy, (j == L) and NEED[5] or NEED[4], ntok)
    c:put(x + 1 + j, yy, (j == L) and NEED[3] or NEED[2], ntok)
  end
  -- front rank: a short needle seen end-on
  if i % 2 == 0 then c:put(x - 1, y - 1, NEED[6], ntok) end
end
-- bud tip
local tx, ty = A.bez(sp, 1)
tx, ty = floor(tx + .5), floor(ty + .5)
for _, q in ipairs{ {0,-1,5},{-1,0,4},{0,0,4},{1,0,2},{0,-2,6} } do c:put(tx + q[1], ty + q[2], NEED[q[3]], ntok) end
c:put(tx, ty - 3, BELL[4], ntok)

A.save(c, NAME)
