-- broken-copper-watering-can (aB11_0, Opus single pass). Upright copper can: slim drum with two raised riveted hoops,
-- an oval top with a dark filler hole, arched top handle, long thin spout on a brace with a brass rose.
-- Material: per-pixel vertical-cylinder light (6-tone copper), hoop bevels (lit lip + dark groove), rivets, a specular
-- streak, verdigris at the base seam, AO under the hoops and where handle / spout meet the drum. Ground shadow.
-- broken: the spout is snapped clean through (real gap) with a jagged end, a copper chip flies off, and a split
-- seam on the drum weeps a drip. quirk: a small snail is riding on the handle.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_0.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.start("broken-copper-watering-can")
local CU, B = A.COPPER, A.BRASS

c:groundShadow(25, 51, 14, 1.5)
-- handle arch (behind the drum)
local hm, hn = G.tube({ { 16, 28 }, { 14, 12 }, { 33, 11 }, { 32, 28 } }, function() return 1.3 end)
local hb = {}
hm:each(function(x, y) if y >= 26 then hb[K(x, y)] = -1 end end)
A.toneN(c, hm, hn, CU, { bias = hb })

-- drum
local x0, x1, y0, y1 = 14, 34, 27, 50
local body = c:rrect(x0, y0, x1, y1, 2)
local bias = {}
local hoops = { 31, 46 }
body:each(function(x, y) local k = K(x, y)
  for _, hy in ipairs(hoops) do
    if y == hy then bias[k] = 1 elseif y == hy + 1 then bias[k] = 0 elseif y == hy + 2 then bias[k] = -2 end
  end
  if y == y1 then bias[k] = (bias[k] or 0) - 1 end
end)
local n = {}
body:each(function(x, y)
  local t = max(-.97, min(.97, ((x + 0.5 - x0) / (x1 + 1 - x0)) * 2 - 1))
  n[K(x, y)] = { t, 0, sqrt(1 - t * t) }
end)
local bidx = A.toneN(c, body, n, CU, { bias = bias, amb = 0.1, wrap = 0.3 })
-- specular streak down the lit flank
for y = 34, 44 do if y ~= 39 then c:px(18, y, CU[6]) end end
c:px(18, 35, A.CREAM)
-- rivets on the hoops
for _, hy in ipairs(hoops) do for _, rx in ipairs{ 17, 24, 31 } do
  c:px(rx, hy + 1, CU[1]) c:px(rx - 1, hy, CU[6])
end end
-- vertical side seam on the shade side
for y = 33, 45 do c:px(30, y, CU[max(1, (bidx[K(30, y)] or 3) - 1)]) end
-- verdigris along the base
for _, p in ipairs{ { 16, 49 }, { 17, 49 }, { 21, 50 }, { 27, 49 }, { 28, 50 }, { 32, 49 } } do c:px(p[1], p[2], "#5fc4a8") end
c:px(17, 48, "#3a8a80") c:px(28, 49, "#3a8a80")

-- oval top + filler hole
local top = c:ellipse(24, 27, 10, 2)
local tn = {}
top:each(function(x, y) tn[K(x, y)] = { (x - 24) / 14, -0.6, 0.8 } end)
A.toneN(c, top, tn, CU, { cuts = { 0.15, 0.3, 0.45, 0.62, 0.8 } })
top:edge():each(function(x, y) if y >= 28 then c:px(x, y, CU[3]) end end)
local hole = c:ellipse(20.5, 27, 3.5, 0.8)
hole:each(function(x, y) c:px(x, y, A.INK) end)
c:px(19, 27, "#3a86b0") c:px(20, 27, "#5fc4c8")
c:px(22, 26, CU[1])
-- handle feet / AO on the top
for _, p in ipairs{ { 16, 27 }, { 17, 27 }, { 31, 27 }, { 32, 27 } } do c:px(p[1], p[2], CU[2]) end

-- spout from the low front, with a thin brace
local sp = { { 33, 46 }, { 40, 41 }, { 46, 32 }, { 51, 22 } }
local sm, sn, ST, SS = G.tube(sp, function(t) return 1.7 - t * 0.6 end)
local sb = {}
X.ao(sb, sm, body, 1, -1)
local sidx = A.toneN(c, sm, sn, CU, { bias = sb })
sm:each(function(x, y) local k = K(x, y) if SS[k] < -0.35 and SS[k] > -0.75 and ST[k] > 0.1 and ST[k] < 0.5 then c:px(x, y, CU[6]) end end)
local brace = c:line({ { 35, 37 }, { 41, 39 } }, 1)
brace:cut(body):cut(sm)
brace:each(function(x, y) c:px(x, y, CU[3]) end)
-- rose (brass, faces up-right), with holes
local rm, rn = A.oval(52.5, 20.5, 2.2, 3.6, math.pi / 4, 0.8)
A.toneN(c, rm, rn, B)
for _, p in ipairs{ { 52, 19 }, { 54, 20 }, { 53, 21 }, { 51, 21 }, { 52, 22 } } do if rm:has(p[1], p[2]) then c:px(p[1], p[2], B[2]) end end
c:px(51, 18, B[6])
-- collar where rose meets spout
c:px(50, 23, B[3]) c:px(49, 23, B[4]) c:px(50, 24, B[2])

-- broken: spout snapped across (real gap) with a jagged end, chip and drip
A.gap(c, { { 42, 34 }, { 46, 37 } }, 1)
A.gap(c, { { 43, 34 }, { 46, 36 } }, 1)
c:px(42, 35, CU[6]) c:px(45, 38, CU[2])
A.map(c, 55, 32, { "ab", "bc" }, { a = CU[6], b = CU[4], c = CU[2] })
-- split seam weeping a drip
A.map(c, 25, 37, { "k.", ".k", "k.", ".k", "k." }, { k = CU[1] })
c:px(25, 42, "#b6f0e0") c:px(25, 43, "#5fc4c8")

-- quirk: snail on the handle
A.map(c, 21, 9, {
  "....s.s.",
  ".gGg.s.s",
  "gGoGg.ss",
  "goGog.ss",
  "bbbbbbbs",
}, { g = "#f5b82e", G = "#ffe38a", o = "#b56a2a", s = "#e2d0c0", b = "#c8a898" })
A.save(c, "broken-copper-watering-can")
