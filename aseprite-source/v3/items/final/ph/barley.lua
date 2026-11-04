-- barley (ph, round 3, artist 4). One slim straw stalk nodding into a two-row ear: plump hulled kernels
-- in alternating pairs (sphere-lit gold ramp, crease line, AO where they stack), a dense parallel beard of
-- long awns sweeping up past the ear, a node knuckle and a blue-green grass leaf (parallel veins, sheath
-- wrapping the stalk, AO under the sheath lip). quirk: a tiny red ant climbing the stalk.
local NAME = "barley"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR3_4.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new(NAME)

local GOLD = { "#6b3a1e", "#9a5a22", "#c98326", "#e6a83a", "#f5cf62", "#fff0a8" }
local AWN = { "#b0782c", "#d9a644", "#f0cf72", "#fbe8a6" }
local STRAW = { "#4a4a24", "#6e6e2e", "#94913a", "#bbb24c", "#dcd170", "#f2e9a4" }
local LEAF = { "#1b3d3a", "#255844", "#33764c", "#4c9652", "#74b660", "#a8d482" }
local VEIN = "#c4e49a"

-- ear axis (rachis): from A (bottom) to B (top), slight nod to the right
local ax, ay, bx, by = 31, 34, 35, 19
local ux, uy = (bx - ax), (by - ay) local L = sqrt(ux*ux + uy*uy) ux, uy = ux / L, uy / L
local px, py = -uy, ux        -- perpendicular (points right-ish)

-- kernels: 6 rows alternating sides
local ks = {}
local ROWS = 7
for i = 0, ROWS - 1 do
  local t = i / (ROWS - 1)
  local side = (i % 2 == 0) and -1 or 1
  local along = t * (L - 1)
  local sc = 1 - t * 0.28
  local cx = ax + ux * along + px * side * 2.1 * sc
  local cy = ay + uy * along + py * side * 2.1 * sc
  local ang = math.atan(uy, ux) + side * 0.32
  ks[#ks + 1] = { cx = cx, cy = cy, rx = 3.1 * sc, ry = 1.75 * sc, ang = ang, side = side, t = t }
end

-- awns: one per kernel, fanned to explicit tips 3 px apart (lower kernels -> outer awns) so each reads
local awnTok = G.tok("awn")
local tops = { [1] = { 23, 12 }, [3] = { 27, 9 }, [5] = { 31, 8 }, [7] = { 35, 7 }, [6] = { 39, 8 }, [4] = { 43, 9 }, [2] = { 47, 12 } }
for i, k in ipairs(ks) do
  local tx, ty = k.cx + cos(k.ang) * (k.rx + 0.3), k.cy + sin(k.ang) * (k.rx + 0.3)
  local e = tops[i]
  local p = { { tx, ty }, { tx + (e[1] - tx) * 0.15, ty + (e[2] - ty) * 0.4 }, { tx + (e[1] - tx) * 0.6, ty + (e[2] - ty) * 0.75 }, e }
  for _, q in ipairs(G.bezPix(p, 120)) do
    local tone = (k.side < 0) and 3 or 2
    if q[3] > 0.8 then tone = tone + 1 end
    if q[3] < 0.1 then tone = 1 end
    c:put(q[1], q[2], AWN[min(4, tone)], awnTok)
  end
end

-- stalk: slim straw tube from ground to ear base, slight S curve
local stTok = G.tok("stalk")
local sp = { { 28, 57 }, { 30, 50 }, { 29, 42 }, { 31, 34 } }
local sm, sn, ST, SS = G.tube(sp, function(t) return 1.15 - t * 0.2 end)
local sidx = X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STRAW, { cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 }, tok = stTok })
-- node knuckle at t~0.5 (darker band + bright bump)
local nx, ny = G.bez(sp, 0.36)
local node = G.oval(nx, ny, 1.9, 1.1, 0, 1)
X.tone(c, node, X.light(X.sphere(nx - .3, ny - .3, 1.9, node), { amb = 0.1, wrap = 0.2 }), STRAW, { cuts = { 0.2, 0.4, 0.58, 0.74, 0.88 }, tok = stTok })
-- straw sheen stripe on the lit side
sm:each(function(x, y) local k = K(x, y) if SS[k] < -0.55 and ST[k] > 0.05 and ST[k] < 0.92 and not node:has(x, y) and (y % 5 ~= 0) then c:put(x, y, STRAW[6], stTok) end end)

-- leaf: grass blade from the node, arcing out left and drooping; sheath hugs the stalk below the node
local lTok = G.tok("leaf")
local cx0, cy0 = G.bez(sp, 0.62)
local lm, ln, LT, LS, llen = G.blade(cx0 - 1, cy0, 18, 34, 11, 45, function(t)
  if t > 0.99 then return -1 end
  return max(0.45, 2.3 * (1 - t) ^ 0.7 * min(1, t * 6 + 0.35))
end, { fold = 0.25 })
lm:cut(sm)
local lb = {}
X.ao(lb, lm, sm, 1, -1)
G.toneN(c, lm, ln, LEAF, { bias = lb, tok = lTok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y)
  if lb[k] then return end
  local s, t = LS[k], LT[k]
  if abs(s) < 0.16 and t > 0.12 and t < 0.9 then c:put(x, y, VEIN, lTok)
  elseif s > 0.5 and t > 0.1 and t < 0.85 and ((x + y) % 3 == 0) then c:put(x, y, LEAF[3], lTok) end   -- parallel vein ticks on shade half
end)
-- sheath: a wider wrap on the stalk below the node
local sh = HP.mask()
for i = 0, 1, 0.02 do local x, y = G.bez(sp, 0.37 + i * 0.25) for d = -1, 1 do sh:set(floor(x + d + .5), floor(y + .5)) end end

sh:cut(node)
sh:each(function(x, y) local k = K(x, y)
  local xx = G.bez(sp, 0.5)
  local i = (x < xx - 0.5) and 5 or ((x > xx + 0.5) and 2 or 4)
  c:put(x, y, LEAF[i], lTok) end)
-- AO: deep row on stalk under the sheath lip
for _, q in ipairs{ { 0, 4 }, { 1, 4 } } do local x, y = G.bez(sp, 0.36) c:put(floor(x + .5) + q[1] - 1, floor(y + .5) + 2, STRAW[1], stTok) end

-- kernels (lower ones first so upper rows overlap them), with AO from the ones above
local kTok = {}
for i, k in ipairs(ks) do
  local m, n = G.oval(k.cx, k.cy, k.rx, k.ry, k.ang, 0.9)
  k.m, k.n = m, n
end
for i, k in ipairs(ks) do
  local bias = {}
  for j = i + 1, #ks do X.ao(bias, k.m, ks[j].m, 1, -1) end
  -- kernels further up partly cover this one: only paint visible
  local vis = k.m:copy()
  for j = i + 1, #ks do vis:cut(ks[j].m) end
  local tok = G.tok("k" .. i)
  local v = X.light(k.n, { amb = 0.08, wrap = 0.22 })
  local idx = X.tone(c, vis, v, GOLD, { cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, bias = bias, tok = tok })
  -- crease line down the kernel, slightly toward the shade side
  local ca, sa = cos(k.ang), sin(k.ang)
  vis:each(function(x, y)
    local dx, dy = x - k.cx, y - k.cy
    local u, w = (dx * ca + dy * sa) / (k.rx + .45), (-dx * sa + dy * ca) / (k.ry + .45)
    if abs(w - 0.15) < 0.22 and abs(u) < 0.55 and not bias[K(x, y)] then c:put(x, y, GOLD[max(1, (idx[K(x, y)] or 3) - 2)], tok) end
  end)
  -- tiny glint per kernel on the lit end (glossy hull)
  local gx, gy = G.specAt(vis, k.n, 30)
  if gx and i % 2 == 1 then c:put(gx, gy, GOLD[6], tok) end
end
-- rachis peeking between kernel pairs
for i = 0, 2 do local t = (i + 0.5) / 7 local x, y = ax + ux * t * L, ay + uy * t * L
  if not ks[1].m:has(floor(x + .5), floor(y + .5)) then end end
-- ear base: short collar where stalk enters the ear


-- one cream sparkle on the top kernel hull
local tk = ks[#ks]
local gx, gy = G.specAt(tk.m, tk.n, 40)
c:put(gx, gy, "#fff4d6", G.tok("k" .. #ks))

-- quirk: tiny red ant climbing the stalk (head up), 3 segments + legs
local ANT = { "#7a1f2a", "#c8362e", "#f0624a" }
local aTok = G.tok("ant")
local function leftEdge(y) local e = 99 sm:each(function(x, yy) if yy == y and x < e then e = x end end) return e end
local ay0 = 50
local e = leftEdge(ay0 + 2)
local body = { { -2, 0, 3 }, { -2, 1, 2 }, { -2, 2, 1 }, { -3, 3, 2 }, { -2, 3, 3 }, { -3, 4, 1 }, { -2, 4, 2 }, { -1, 1, 1 }, { -1, 3, 1 }, { -3, -1, 1 } }
for _, q in ipairs(body) do c:put(e + q[1], ay0 + q[2], ANT[q[3]], aTok) end
G.done(c, NAME)
