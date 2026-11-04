-- rich-loam (final, artist aD12_4). A slim burlap sack of loam with the mouth rolled down into a fat cuff: 2x2 basket weave
-- with loose fibres, vertical folds, a stencilled seedling stamp, one gold-stitched seam, a twisted twine tie with a knot and
-- two frayed tails. Out of the cuff rises a dome of dark, moist, crumbly loam (relief clods with cast shadows, grit, two pebbles,
-- wet glints), a few crumbs have spilled over the cuff and a small pile has slumped on the ground at the foot.
-- quirk: a pink earthworm peeks out of a hole in the top of the heap and curls its head over like a question mark.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_4.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("rich-loam")

local BUR  = { "#4a3424", "#7a5a3c", "#a67f50", "#c9a56c", "#e0c48a", "#f6e2ac" }
local SOIL = { "#1e1220", "#34202a", "#4a2e30", "#66423a", "#85574a", "#a87258" }
local STONE = { "#35364f", "#4f5170", "#74758c", "#9795a8", "#bdbacb", "#e2e0e6" }
local TW   = { "#4a2e18", "#7a5028", "#b88a48", "#dcb066", "#f2d28a" }
local WM   = { "#7d2c5e", "#a8446e", "#d06484", "#e88aa0", "#f6b0bc", "#ffd0d8" }
local rnd = A.rng(23)

c:groundShadow(32, 56.5, 23, 2.5)

local body = c:poly{ {17,31},{47,31},{50,40},{49,50},{46,55},{18,55},{15,50},{14,40} }
local cuff = c:rrect(15, 25, 49, 31, 2)
local heap = c:ellipse(32, 27, 15, 14):clip(c:rect(0, 0, 63, 28))
local pile = A.ell(46, 55, 8.5, 3.4, 0):add(A.ell(41.5, 56, 3.6, 2, 0))

-- relief clod: tone = local base tone shifted by the clod's own light
local function clod(m, baseIdx, ramp, shadowTone)
  m:shift(1, 1):each(function(x, y) if not m:has(x, y) then c:px(x, y, ramp[shadowTone or 1]) end end)
  local n = X.pillow(m, 1.7)
  local v = X.light(n, { amb = 0.1, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    local b = baseIdx[k] or 3
    c:px(x, y, ramp[max(1, min(6, b + floor((v[k] - 0.5) * 5 + 0.5)))]) end)
end

-- sack body
local bb = {}
X.ao(bb, body, cuff, 2, -1) X.ao(bb, body, pile, 1, -1) G.cast(bb, body, pile, 1, 0, -1)
body:each(function(x, y) local k = K(x, y)
  if (floor(x / 2) + floor(y / 2)) % 2 == 0 then bb[k] = (bb[k] or 0) - 1 end end)
local nb = {}
body:each(function(x, y)
  local nx = max(-0.95, min(0.95, (x - 32) / 18.5 * 0.9 + 0.16 * sin((x - 32) * 0.5 + y * 0.05)))
  local ny = 0.15 * ((y - 43) / 12)
  local nz = sqrt(max(0.05, 1 - nx * nx))
  local l = sqrt(nx * nx + ny * ny + nz * nz)
  nb[K(x, y)] = { nx / l, ny / l, nz / l }
end)
local bidx = G.toneN(c, body, nb, BUR, { bias = bb, amb = 0.1, wrap = 0.32, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
body:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 4)
  if h > 0.94 then c:px(x, y, BUR[min(6, (bidx[k] or 3) + 1)]) end            -- loose fibres
  if abs(x - (28 + floor(sin(y * 0.3) + 0.5))) == 0 and y > 34 and y < 54 then c:px(x, y, BUR[max(1, (bidx[k] or 3) - 1)]) end
  if abs(x - (39 + floor(sin(y * 0.25 + 1) + 0.5))) == 0 and y > 40 and y < 54 then c:px(x, y, BUR[max(1, (bidx[k] or 3) - 1)]) end
end)
-- cool bounce on the lower-right edge
body:edge():each(function(x, y) if x > 44 and y > 41 and (bidx[K(x, y)] or 3) <= 3 then c:px(x, y, "#8a6a58") end end)
-- seedling stamp
local STP1, STP2 = "#3c6a46", "#2c5238"
local stamp = HP.mask()
stamp:add(A.ell(28.4, 45.4, 3.0, 1.5, -0.65)):add(A.ell(33.8, 43.2, 3.0, 1.5, 0.65)):add(c:rect(31, 44, 31, 52))
stamp:each(function(x, y) c:px(x, y, ((x + y) % 2 == 0) and STP1 or STP2) end)
c:px(28, 46, STP2) c:px(29, 47, STP2) c:px(32, 44, STP2) c:px(34, 44, STP2)
-- gold stitched seam (real cloth seam)
c:stitch({ {21, 36}, {21, 53} })
-- bottom edge fray
for _, p in ipairs{ {24,56},{25,56},{33,56},{37,56},{38,57} } do if not pile:has(p[1], p[2]) then c:px(p[1], p[2], BUR[2]) end end

-- heap of loam (behind the cuff)
local hb = {}
X.ao(hb, heap, cuff, 2, -1)
local hidx = A.sph(c, heap, 31, 26, 14, SOIL, { bias = hb, amb = 0.1, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
local hp = {}
heap:each(function(x, y) if y < 24 then hp[#hp + 1] = { x, y } end end)
table.sort(hp, function(a, b) if a[2] ~= b[2] then return a[2] < b[2] end return a[1] < b[1] end)
for i = 1, 9 do
  local p = hp[floor(rnd() * #hp) + 1]
  local m = A.ell(p[1], p[2], 2.1 + rnd() * 1.3, 1.5 + rnd() * 0.6, rnd() * 3):clip(heap)
  if p[2] < 22 or p[1] < 20 or p[1] > 44 then m:clip(heap:shrink(1)) end
  clod(m, hidx, SOIL, 1)
end
for i = 1, 26 do
  local p = hp[floor(rnd() * #hp) + 1]
  local k = K(p[1], p[2])
  c:px(p[1], p[2], SOIL[min(6, (hidx[k] or 3) + 2)])
  if i % 3 == 0 then c:px(p[1] + 1, p[2] + 1, SOIL[1]) end
end
-- grit, wet glints, pebbles
for _, q in ipairs{ {22,21},{27,18},{36,15},{41,20},{44,23},{30,22} } do c:px(q[1], q[2], "#d6c0a0") end
for _, q in ipairs{ {26,16},{38,18},{33,21},{20,23} } do c:px(q[1], q[2], "#c8967a") c:px(q[1] + 1, q[2], "#a87258") end
for _, q in ipairs{ {40,22,0.2,2.4,1.7}, {21,22,-0.3,1.4,1.0} } do
  local m = A.ell(q[1], q[2], q[4], q[5], q[3])
  m:shift(1, 1):each(function(x, y) if heap:has(x, y) and not m:has(x, y) then c:px(x, y, SOIL[1]) end end)
  A.pill(c, m, STONE, 1.5, {})
  c:px(q[1] - 1, q[2] - 1, "#e2e0e6")
end

-- worm hole
local hole = A.ell(29, 15.5, 3.2, 1.4, 0)
hole:each(function(x, y) c:px(x, y, SOIL[1]) end)
for x = 26, 32 do if heap:has(x, 17) then c:px(x, 17, SOIL[4]) end end

-- worm
local wm, wn, WT, WS = G.tube({ {29, 16}, {29, 7}, {20, 5}, {20, 12} }, function(t) return 1.9 - 0.7 * t end)
local widx = G.toneN(c, wm, wn, WM, { amb = 0.1, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
wm:each(function(x, y) local k = K(x, y)
  local t = WT[k]
  if t > 0.3 and t < 0.4 then c:px(x, y, WM[min(6, (widx[k] or 3) + 1)])
  elseif floor(t * 20) % 2 == 0 and t > 0.05 then c:px(x, y, WM[max(1, (widx[k] or 3) - 1)]) end
  if t < 0.12 then c:px(x, y, WM[1]) end
  if t > 0.55 and t < 0.62 and WS[k] < -0.45 then c:px(x, y, "#fff0f2") end
end)

-- rolled cuff
local cb = {}
X.ao(cb, cuff, heap, 0, 0)
local cn = {}
cuff:each(function(x, y)
  local ny = max(-0.9, min(0.9, (y - 28) / 3.6))
  local nx = ((x - 32) / 18) ^ 3 * 0.7
  local nz = sqrt(max(0.05, 1 - ny * ny - nx * nx))
  local l = sqrt(nx * nx + ny * ny + nz * nz)
  cn[K(x, y)] = { nx / l, ny / l, nz / l }
  if (floor(x / 2) + floor(y / 2)) % 2 == 0 then cb[K(x, y)] = -1 end
end)
local cidx = G.toneN(c, cuff, cn, BUR, { bias = cb, amb = 0.12, wrap = 0.32, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
for x = 17, 47 do if cuff:has(x, 28) then c:px(x, 28, BUR[max(1, (cidx[K(x, 28)] or 3) - 1)]) end end
cuff:each(function(x, y) if X.hash(x, y, 8) > 0.95 then c:px(x, y, BUR[min(6, (cidx[K(x, y)] or 3) + 1)]) end end)

-- twine tie under the cuff with a knot and two frayed tails
for x = 15, 49 do
  local y = floor(32 + 1.6 * sin(pi * (x - 15) / 34) + 0.5)
  for r = 0, 1 do
    local on = ((x + r * 2) % 4 < 2)
    local t = r == 0 and (on and 4 or 3) or (on and 2 or 3)
    if body:has(x, y + r) then c:px(x, y + r, TW[t]) end
  end
  if body:has(x, floor(32 + 1.6 * sin(pi * (x - 15) / 34) + 0.5) + 2) then
    c:px(x, floor(32 + 1.6 * sin(pi * (x - 15) / 34) + 0.5) + 2, BUR[1]) end
end
A.ell(41.5, 34, 2.1, 1.8, 0):each(function(x, y) c:px(x, y, (x + y) % 2 == 0 and TW[4] or TW[3]) end)
c:px(40, 33, TW[5]) c:px(43, 35, TW[1])
A.pl(c, { {41,36},{40,38},{40,41} }, TW[3]) A.pl(c, { {42,36},{44,38},{45,41} }, TW[4])
c:px(41, 36, TW[2]) c:px(40, 42, TW[4]) c:px(45, 42, TW[3]) c:px(39, 41, TW[2]) c:px(46, 41, TW[2])

-- soil crumbs spilled over the cuff
for _, q in ipairs{ {20,26.5,1.9,1.3,0.2}, {25,25,1.6,1.1,-0.3}, {19.5,33,1.5,1.1,0.4} } do
  local m = A.ell(q[1], q[2], q[3], q[4], q[5])
  clod(m, { }, SOIL, 1)
end
-- pile on the ground
local pb = {}
local pidx = A.sph(c, pile, 44, 52, 9.5, SOIL, { bias = pb, amb = 0.1, wrap = 0.3 })
for _, q in ipairs{ {44,55,2.2,1.5,0.2}, {48,56,2.0,1.3,-0.2}, {41,56.5,1.8,1.2,0.1}, {50,54,1.7,1.2,0.3} } do
  clod(A.ell(q[1], q[2], q[3], q[4], q[5]):clip(pile), pidx, SOIL, 1)
end
for _, q in ipairs{ {45,53},{47,55},{42,55} } do c:px(q[1], q[2], SOIL[6]) end

A.save(c, "rich-loam")
