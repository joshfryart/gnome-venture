-- hat-seedkeeper (final, Opus single pass). Tall slim blue cone whose soft tip flops over to the LEFT and hangs
-- down, ending in an acorn-like seed-pod tassel. Leather band with a gold stitched seam and a brass seed buckle.
-- Material: per-pixel cone light (6-tone blue felt, cool shade), felt nap, fold creases where the tip bends;
-- leather band (grain flecks, dark top seam); brass buckle with bevel and specular; seed pod: scaly cap + glossy nut.
-- quirk: a tiny hole near the flop lets two seeds trickle out.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min = math.floor, math.max, math.min
local c = A.new("hat-seedkeeper")
local BLUE  = { "#161d42", "#223468", "#2d5090", "#3c70b4", "#5f9cd6", "#9ccdef" }
local LEATH = { "#2e1a18", "#51302b", "#7a4a33", "#a26b45", "#c68f5f", "#e8b982" }
local BRASS = { "#5a3418", "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a", "#fff4d6" }
local NUT   = { "#3a2018", "#6a3a22", "#9a5a2e", "#c47e3c", "#e2a65a", "#f8d48c" }

local CX, BY, RW, RY = 32, 47, 9, 2.2
local pts = { { 33, 48 }, { 33, 27 }, { 31, 10 }, { 18, 19 } }
local cm, cn, CT, CS, samp = A.tube(pts, function(t) return 9.4 * (1 - t) ^ 0.8 + 1.6 end)
A.arcClip(cm, CX, BY, RW + 1, RY)

-- brim
local bias = {}
local tmp = HP.mask()
for y = 40, 58 do for x = 8, 58 do
  local u, v = (x - 32) / 20.45, (y - 50) / 4.95
  if u*u + v*v <= 1 then tmp:set(x, y) end end end
X.ao(bias, tmp, cm, 2, -1)
A.cast(bias, tmp, cm, 3, 2, -1)
local top, under, bidx, btok = A.brim(c, 32, 50, 20, 4.5, 2, BLUE, { bias = bias })
A.felt(c, top, bidx, BLUE, btok, 21, 0.04)

-- crown
local ctok = { r = { name = "crown" } }
local cbias = {}
-- the hanging tip sits in the shade of the fold
cm:each(function(x, y) local k = K(x, y) if CT[k] > 0.82 then cbias[k] = -1 end end)
local cidx = A.shade(c, cm, cn, BLUE, { tok = ctok, bias = cbias })
A.felt(c, cm, cidx, BLUE, ctok, 7, 0.06)
local LEN = A.tubeLen(samp)
A.creases(c, cm, cidx, CT, CS, LEN, BLUE, ctok, { { 0.6, -0.8, 0.6, 1.2 }, { 0.68, -0.3, 0.9, -0.8 }, { 0.36, 0.1, 0.9, 1.5 } })
local rim = X.rim(cn)
cm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.72 and CT[k] > 0.1 and CT[k] < 0.5 then c:put(x, y, "#4f7fc0", ctok) end end)
c:put(29, 29, BLUE[6], ctok) c:put(29, 30, BLUE[6], ctok)

-- leather band with stitch
local bm = A.bandMask(cm, CX, BY, RW + 1, RY, 6)
local ltok = { r = { name = "band" } }
local lidx = A.shade(c, bm, cn, LEATH, { tok = ltok })
bm:each(function(x, y)
  local a = A.arcY(x, CX, BY, RW + 1, RY)
  if y <= a - 5.3 then A.step(c, lidx, LEATH, x, y, -2, ltok)
  elseif X.hash(x, y, 4) < 0.12 then A.step(c, lidx, LEATH, x, y, -1, ltok) end
end)
local st = {}
for x = 24, 42 do st[#st + 1] = { x, floor(A.arcY(x, CX, BY, RW + 1, RY) - 1.6 + 0.5) } end
for i, p in ipairs(st) do if (i - 1) % 3 < 2 and bm:has(p[1], p[2]) then c:put(p[1], p[2], "#f5b82e", ltok) end end

-- brass seed buckle (teardrop, point up)
A.map(c, {
  "..d..",
  ".dhd.",
  "dhHbd",
  "dhbsd",
  "dbssd",
  ".ddd.",
}, 30, 41, { d = BRASS[2], h = BRASS[5], H = BRASS[6], b = BRASS[4], s = BRASS[3] })

-- seed-pod tassel at the tip end
local ex, ey = floor(samp[#samp].x + 0.5), floor(samp[#samp].y + 0.5)
local nm, nn = A.oval(ex, ey + 5, 2.4, 3.2, 0, 1)
local ntok = { r = { name = "nut" } }
local nidx = A.shade(c, nm, nn, NUT, { tok = ntok })
c:put(ex - 1, ey + 4, NUT[6], ntok) c:put(ex, ey + 9, NUT[1], ntok)
local capm = c:rrect(ex - 3, ey + 1, ex + 3, ey + 3, 1)
local ptok = { r = { name = "cap" } }
capm:each(function(x, y)
  local i = (x < ex) and 4 or (x == ex and 3 or 2)
  if y == ey + 1 then i = i + 1 end
  if (x + y) % 2 == 0 then i = i - 1 end           -- scales
  if y == ey + 3 then i = 1 end                     -- dark row where cap meets nut
  c:put(x, y, LEATH[max(1, min(6, i))], ptok)
end)

-- quirk: a small hole near the flop, two seeds trickling out
local s = samp[floor(0.74 * #samp)]
local hx, hy = floor(s.x + s.px * s.w * 0.55 + 0.5), floor(s.y + s.py * s.w * 0.55 + 0.5)
c:put(hx, hy, BLUE[1], ctok) c:put(hx + 1, hy, BLUE[1], ctok) c:put(hx, hy - 1, BLUE[6], ctok)
local seedmap = { ".a.", "aSa", "abd", ".d." }
local spal = { a = NUT[4], S = NUT[6], b = NUT[3], d = NUT[2] }
A.map(c, seedmap, hx - 4, hy + 4, spal)
A.map(c, seedmap, hx - 6, hy + 10, spal)
A.save(c, "hat-seedkeeper")
