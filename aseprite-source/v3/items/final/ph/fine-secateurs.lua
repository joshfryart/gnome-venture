-- fine-secateurs (aB31_4, Opus single pass). Bypass pruning shears, closed, on the diagonal: a bright curved cutting
-- blade (honed bevel along its edge, specular streak) sliding past a darker hooked anvil jaw, a brass pivot bolt with a
-- screw slot, two slim forged handles opening in a narrow V with a gold coil spring between them and red rubber
-- grips with finger ridges. AO where the blades cross and where the grips sleeve the steel.
-- quirk: a snipped rose twig with one leaf is still caught in the jaws.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = A.new("fine-secateurs")
local STEEL = { "#2b2d46", "#464a6a", "#6a7090", "#959db6", "#c3cadb", "#eef1f7" }
local DARK  = { "#1f1c2e", "#2f2d44", "#45455f", "#5f627e", "#8287a2", "#b4b9cc" }
local GRIP  = { "#4e1530", "#7f1f36", "#b52e3f", "#e04a42", "#ff7a5c", "#ffb08a" }
local BRASS = { "#4f2a1e", "#87501f", "#c07f22", "#e5a92e", "#f8d468", "#fff1b8" }
local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TWIG  = { "#51302b", "#864c33", "#b97a4a" }
local PX, PY = 37, 27

-- spring (behind everything): gold zigzag coil between the handles
local st = A.tok("spring")
local coil = { { 33, 34 }, { 36, 33 }, { 33, 36 }, { 36, 35 }, { 33, 38 }, { 36, 37 } }
for i = 1, #coil - 1 do
  local a, b = coil[i], coil[i + 1]
  local n = max(abs(b[1] - a[1]), abs(b[2] - a[2]))
  for j = 0, n do
    local x, y = floor(a[1] + (b[1] - a[1]) * j / n + .5), floor(a[2] + (b[2] - a[2]) * j / n + .5)
    c:put(x, y, (i % 2 == 1) and BRASS[5] or BRASS[3], st)
  end
end

-- hooked anvil jaw (behind the cutting blade)
local hp = { { PX + 1, PY + 1 }, { 46, 26 }, { 52, 22 }, { 54, 15 } }
local hm, hn, HT, HS = A.tube(hp, function(t) return 2.7 - 1.5 * t end)
local hidx = A.tone(c, hm, hn, DARK, {})
-- cutting blade
local bp = { { PX - 1, PY + 1 }, { 40, 19 }, { 46, 12 }, { 53, 9 } }
local bm, bn, BT, BS, bs = A.tube(bp, function(t) return 0.4 + 2.9 * (1 - t) ^ 0.7 end)
local bb = {}
local bidx = A.tone(c, bm, bn, STEEL, { bias = bb, amb = 0.15 })
hm:cut(bm)
-- AO on the anvil jaw where the blade lies over it
A.touch(hm, bm):each(function(x, y) A.step(c, hidx, DARK, x, y, -2) end)
bm:each(function(x, y) local k = K(x, y)
  if BS[k] > 0.55 and BT[k] > 0.1 then c:put(x, y, STEEL[6]) end                 -- honed bevel on the edge
  if BS[k] > 0.2 and BS[k] <= 0.55 and BT[k] > 0.15 then A.step(c, bidx, STEEL, x, y, -1) end
end)
for _, t in ipairs{ 0.3, 0.36, 0.42, 0.48 } do
  local s = bs[floor(t * 160) + 1]
  c:put(floor(s.x - s.px * s.w * 0.45 + .5), floor(s.y - s.py * s.w * 0.45 + .5), STEEL[6])
end
do local s = bs[floor(0.33 * 160) + 1] c:put(floor(s.x - s.px * s.w * 0.45 + .5), floor(s.y - s.py * s.w * 0.45 + .5), A.CREAM) end

-- handles
local function handle(p, metalEnd)
  local m, n, T, S = A.tube(p, function(t) return t < metalEnd and 1.7 or 2.15 end)
  m:cut(bm) m:cut(hm)
  local met, gr = HP.mask(), HP.mask()
  m:each(function(x, y) if T[K(x, y)] < metalEnd then met:set(x, y) else gr:set(x, y) end end)
  local b = {}
  X.ao(b, met, gr, 1, -1)
  local mi = A.tone(c, met, n, STEEL, { bias = b })
  local gi = A.tone(c, gr, n, GRIP, {})
  local len = 0
  gr:each(function(x, y) local k = K(x, y)
    if abs(T[k] - metalEnd) < 0.02 then A.step(c, gi, GRIP, x, y, -2) end      -- sleeve lip
    if S[k] < -0.55 and T[k] > metalEnd + 0.06 and T[k] < 0.94 then A.step(c, gi, GRIP, x, y, 1) end
  end)
  return m, n, T, S, gi
end
-- lower handle (from the anvil jaw) first, upper handle over it
local m2, n2, T2, S2, g2 = handle({ { PX + 1, PY + 2 }, { 35, 37 }, { 31, 46 }, { 27, 55 } }, 0.36)
local m1, n1, T1, S1, g1 = handle({ { PX - 1, PY + 1 }, { 30, 34 }, { 22, 42 }, { 11, 50 } }, 0.32)
-- finger ridges on the underside of the upper grip
m1:each(function(x, y) local k = K(x, y)
  if S1[k] > 0.35 and T1[k] > 0.45 and T1[k] < 0.92 and floor(T1[k] * 40) % 3 == 0 then A.step(c, g1, GRIP, x, y, -2) end end)
m2:each(function(x, y) local k = K(x, y)
  if S2[k] > 0.35 and T2[k] > 0.48 and T2[k] < 0.92 and floor(T2[k] * 40) % 3 == 0 then A.step(c, g2, GRIP, x, y, -2) end end)
-- AO where upper handle crosses the lower one near the pivot
A.touch(m2, m1):each(function(x, y) c:put(x, y, STEEL[1]) end)

-- pivot bolt: brass, slot, glint
local pm = c:ellipse(PX, PY + 1, 2.5, 2.5)
local pn = X.sphere(PX, PY + 1, 2.5, pm)
A.tone(c, pm, pn, BRASS, {})
c:put(PX - 1, PY + 2, BRASS[1]) c:put(PX, PY + 1, BRASS[1]) c:put(PX + 1, PY, BRASS[1])
c:put(PX - 1, PY, BRASS[6])

-- quirk: snipped rose twig caught in the jaws, one leaf
local tt = A.tok("twig")
for i = 0, 6 do c:put(43 + i, 22 - floor(i * 0.5), i < 3 and TWIG[2] or TWIG[3], tt) c:put(43 + i, 23 - floor(i * 0.5), TWIG[1], tt) end
c:put(46, 20, TWIG[2], tt)  -- thorn
c:put(50, 18, "#c8a070", tt) c:put(50, 19, "#e8c890", tt) -- pale cut end
A.map(c, {
  "....ab",
  "..abbc",
  ".abcd.",
  "abcd..",
  "cd....",
}, 37, 16, { a = LEAF[6], b = LEAF[5], c = LEAF[4], d = LEAF[2] }, tt)
A.save(c, "fine-secateurs")
