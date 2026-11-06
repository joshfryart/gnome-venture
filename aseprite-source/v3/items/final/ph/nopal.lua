-- nopal (C3, Opus single pass): one slim prickly-pear paddle (cladode), obovate and leaning with a soft S, cut at the
-- base to show the pale juicy flesh with its vascular dots. Blue-green waxy skin lit per pixel (pillow + gentle dome),
-- areoles in a quincunx lattice (cream felt dot, dimple shadow below-right, 1 px glochid spines), cool reflected rim
-- on the shade edge, a few rim spines in the silhouette, waxy bloom freckles in the light.
-- quirk: a tiny new baby pad buds from the right shoulder, its tip blushing pink.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_3.lua")
local HP, X, K, B = A.HP, A.X, A.K, A.B
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("nopal")
local PAD = { "#173a3a", "#1f5246", "#2b6e50", "#43905a", "#6db468", "#a6d88a" }
local BUD = { "#2b6e50", "#43905a", "#6db468", "#94cc72", "#c4e690", "#e8f6b8" }
local FL = { "#7fa860", "#a8c87c", "#cfe2a0", "#e8f2c2" }
local COOL, FELT, FELTD, SPINE = "#4a8a88", "#efe2b0", "#c8b888", "#fff4d6"

-- main pad
local P = { { 31, 54 }, { 30, 44 }, { 34, 32 }, { 33, 22 } }
local function wf(t) return 2.8 + 8.0 * (sin(pi * (t * 0.55 + 0.05))) ^ 2 end
local pm, tn, PT, PS = A.tube(P, wf, { flat = 0.5 })
local pn = X.pillow(pm, 4.5)
-- blend bevel normals with a soft dome
local n = {}
pm:each(function(x, y) local k = K(x, y) local a, b = pn[k], tn[k]
  local nx, ny, nz = a[1] + b[1] * 0.45, a[2] + b[2] * 0.45, a[3] + b[3] * 0.6
  local l = sqrt(nx * nx + ny * ny + nz * nz) n[k] = { nx / l, ny / l, nz / l } end)

-- baby pad (quirk) on the right shoulder
local bm, bn, BT, BS = A.tube({ { 41, 18 }, { 42, 16 }, { 44, 14 }, { 46, 11 } }, function(t) return 1.4 + 1.6 * sin(pi * min(1, t * 0.7 + 0.2)) end, { flat = 0.6 })
local bias = {}
X.ao(bias, pm, bm, 1, -1)
-- cut face at the base: lowest rows of the pad
local cutF = HP.mask()
pm:each(function(x, y) if y >= 55 then cutF:set(x, y) end end)
local body = pm:copy():cut(cutF)
pm:each(function(x, y) if y == 54 then bias[K(x, y)] = (bias[K(x, y)] or 0) - 1 end end) -- ambient row above the cut
local ptok = A.tok("pad")
local idx = A.toneN(c, body, n, PAD, { tok = ptok, bias = bias, amb = 0.1, wrap = 0.3 })

-- cool reflected light on the lower-right edge
body:edge():each(function(x, y) local k = K(x, y) local q = n[k]
  if q and q[1] * 0.6 + q[2] * 0.75 > 0.45 and y < 52 and not bias[k] then c:put(x, y, COOL, ptok) end end)
-- waxy bloom freckles in the light
body:shrink(3):each(function(x, y) local k = K(x, y)
  if (idx[k] or 0) == 5 and X.hash(x, y, 11) < 0.04 then c:put(x, y, PAD[min(6, idx[k] + 1)], ptok) end end)

-- areoles: quincunx lattice in (along, across) px space
local len = 0 do local ox, oy = A.bez(P, 0) for i = 1, 40 do local x, y = A.bez(P, i / 40) len = len + sqrt((x - ox) ^ 2 + (y - oy) ^ 2) ox, oy = x, y end end
local best = {}
local inner = body:shrink(1)
inner:each(function(x, y) local k = K(x, y)
  local u, v = PT[k] * len, PS[k] * (wf(PT[k]) + .5)
  local r = floor(u / 6.2 + .5)
  local off = (r % 2) * 2.8
  local col = floor((v - off) / 5.6 + .5)
  local e = abs(u - r * 6.2) + abs(v - off - col * 5.6)
  local key = r * 100 + col
  if e < 1.3 and r >= 1 and (not best[key] or e < best[key][3]) then best[key] = { x, y, e } end
end)
local ai = 0
for key, q in pairs(best) do
  local x, y = q[1], q[2]
  ai = ai + 1
  local k = K(x, y)
  local lit = (idx[k] or 3)
  c:put(x, y, lit >= 3 and FELT or FELTD, ptok)
  if body:has(x + 1, y + 1) then c:put(x + 1, y + 1, PAD[max(1, (idx[K(x + 1, y + 1)] or 3) - 1)], ptok) end
  if X.hash(x, y, 5) < 0.3 and body:has(x - 1, y - 1) then c:put(x - 1, y - 1, lit >= 4 and SPINE or FELT, ptok) end
end
-- rim spines poking from the silhouette (1 px each, upper-left lit side and top)
for _, s in ipairs{ { 21, 24, 22, 24 }, { 27, 12, 27, 13 }, { 44, 34, 43, 34 }, { 22, 40, 23, 40 } } do
  if not pm:has(s[1], s[2]) and pm:has(s[3], s[4]) then c:put(s[1], s[2], "#d8cc9c", ptok) end
end
-- specular on the waxy skin
c:put(26, 20, A.CREAM, ptok) c:put(27, 20, A.CREAM, ptok) c:put(27, 21, PAD[6], ptok)

-- cut face: pale flesh, darker rim ring, vascular dots
local cb = HP.mask() cutF:each(function(x, y) cb:set(x, y) end)
local ce = cutF:edge()
cutF:each(function(x, y)
  local col = ce:has(x, y) and FL[2] or FL[3]
  if not cutF:has(x, y - 1) then col = FL[4] end
  if ce:has(x, y) and (cutF:has(x + 1, y) == false or not cutF:has(x, y + 1)) then col = FL[1] end
  c:put(x, y, col, ptok)
end)
for _, q in ipairs{ { 29, 56 }, { 31, 56 }, { 33, 56 } } do if cutF:has(q[1], q[2]) then c:put(q[1], q[2], FL[1], ptok) end end

-- baby pad drawn over the shoulder
local btok = A.tok("bud")
local bidx = A.toneN(c, bm, bn, BUD, { tok = btok, amb = 0.14, wrap = 0.3 })
bm:each(function(x, y) local k = K(x, y)
  if BT[k] > 0.86 then c:put(x, y, BS[k] < 0 and "#f49ab0" or "#d8506a", btok) end end)
c:put(43, 15, FELT, btok)
-- contact shadow where the bud leaves the pad
for _, q in ipairs{ { 41, 20 }, { 42, 19 }, { 43, 18 } } do if body:has(q[1], q[2]) and not bm:has(q[1], q[2]) then c:put(q[1], q[2], PAD[1], ptok) end end
A.shift(c, -3, 0)
A.fin()
