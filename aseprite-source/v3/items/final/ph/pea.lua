-- pea (aC32_2 final, Opus single pass). A slim pea pod curved like a smile, split along its seam: the top valve has
-- flipped up behind (pale inner face showing), the bottom valve cradles five glossy round peas that sit in it with
-- AO between them and a contact shadow on the pale lining. Pod: 6-tone cylinder light, cool waxy bloom flecks,
-- a ridged seam with a lit lip along the belly, a pointed beak at the tip; five-pointed calyx, curved stalk and a
-- coiled tendril at the stem end.
-- quirk: a single dewdrop is sliding down the belly of the pod.
local NAME = "pea"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local full = c:rect(0, 0, 63, 63)
local POD  = { "#163b2f", "#225836", "#34773c", "#50964a", "#7ab85e", "#b2da84" }
local LIN  = { "#46703a", "#62903f", "#86b052", "#accc6e", "#cde496", "#ecf6c2" }
local PEA  = { "#1e4828", "#2e682e", "#4a8e32", "#70b33c", "#a0d458", "#d6f28c" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STEM = { "#3c744a", "#68a65a", "#9ccf78", "#d4eeaa" }
local BLOOM = "#9fc9b4"

local path = { { 10, 42 }, { 23, 54 }, { 40, 54 }, { 54, 38 } }
local function hw(t) return 0.7 + 5.4 * sin(pi * min(1, t)) ^ 0.55 end

-- top valve, flipped up behind: pale inner face, narrower, lifted
local pup = { { 11, 39 }, { 24, 49 }, { 39, 49 }, { 53, 34 } }
local bm, bn, BT, BS = A.tube(pup, function(t) return 0.5 + 3.4 * sin(pi * min(1, t)) ^ 0.55 end)
local btok = { r = { name = "valve-top" } }
local bidx = A.shade(c, bm, bn, LIN, { amb = 0.05, wrap = 0.2, tok = btok, cuts = { 0.3, 0.46, 0.62, 0.76, 0.9 } })
-- its outer (green) rim along the top edge
bm:edge():each(function(x, y) local k = K(x, y) if BS[k] < -0.5 then c:put(x, y, POD[3], btok) end end)

-- bottom valve
local vm, vn, VT, VS = A.tube(path, hw)
local vtok = { r = { name = "valve" } }
local vbias = {}
vm:each(function(x, y) local k = K(x, y) if VS[k] > 0.8 then vbias[k] = -1 end end)
local vidx = A.shade(c, vm, vn, POD, { amb = 0.08, wrap = 0.26, tok = vtok, bias = vbias })
-- ridged seam on the belly: dark groove on the edge, lit lip just inside
vm:each(function(x, y) local k = K(x, y)
  if VS[k] > 0.56 and VS[k] <= 0.74 and VT[k] > 0.08 and VT[k] < 0.92 then A.step(c, vidx, POD, x, y, 1, vtok) end end)
-- waxy bloom flecks on the lit outer shell
vm:each(function(x, y) local k = K(x, y)
  if VS[k] > 0.1 and VS[k] < 0.55 and (vidx[k] or 0) >= 4 and X.hash(x, y, 4) < 0.12 then c:put(x, y, BLOOM, vtok) end end)
-- record the shell colours so the front lip can be repainted over the peas
local col = {}
vm:each(function(x, y) col[K(x, y)] = c:get(x, y) end)

-- lining: the open inside of the valve (upper part of the tube)
local ltok = { r = { name = "lining" } }
local lin = HP.mask()
vm:each(function(x, y) local k = K(x, y)
  if VS[k] < -0.05 and VT[k] > 0.06 and VT[k] < 0.94 then lin:set(x, y)
    local i = VS[k] < -0.72 and 6 or (VS[k] < -0.42 and 4 or 3)
    c:put(x, y, LIN[i], ltok) end end)

-- peas: five spheres along the cradle
local peas = {}
local ts = { 0.17, 0.33, 0.5, 0.67, 0.83 }
for i, t in ipairs(ts) do
  local x, y = A.bez(path, t)
  local r = (i == 1 or i == 5) and 2.9 or 3.3
  peas[i] = { x = x - 0.3, y = y - 2.2, r = r }
  peas[i].m = c:ellipse(floor(x - 0.3 + .5), floor(y - 2.2 + .5), r, r)
end
-- contact shadow of the peas on the lining
local lb = {}
for _, p in ipairs(peas) do A.cast(lb, lin, p.m, 1, 1, -1) end
for k, d in pairs(lb) do local x, y = k % 1024 - 256, k // 1024 - 256 c:put(x, y, LIN[2], ltok) end
for i, p in ipairs(peas) do
  local tok = { r = { name = "pea" .. i } }
  local b = {}
  if peas[i - 1] then X.ao(b, p.m, peas[i - 1].m, 1, -1) end
  if peas[i + 1] then X.ao(b, p.m, peas[i + 1].m, 1, -1) end
  local n = X.sphere(p.x - 0.5, p.y - 0.6, p.r + 0.4, p.m)
  local idx = A.shade(c, p.m, n, PEA, { amb = 0.08, wrap = 0.24, tok = tok, bias = b })
  -- cool reflected light lower right
  local rr = X.rim(n)
  p.m:edge():each(function(x, y) local k = K(x, y) if rr[k] and rr[k] > 0.55 and not b[k] then c:put(x, y, "#3f8a6a", tok) end end)
  local sx, sy = A.specAt(p.m, n, 40)
  c:put(sx, sy, PEA[6], tok)
  if i == 3 then c:put(sx, sy, A.CREAM, tok) c:put(sx + 1, sy, PEA[6], tok) end
end
-- front lip of the valve repainted over the bottoms of the peas, with a dark AO row on the pea above it
local lip = HP.mask()
vm:each(function(x, y) local k = K(x, y) if VS[k] > 0.28 then lip:set(x, y) c:put(x, y, col[k], vtok) end end)
for _, p in ipairs(peas) do
  lip:shift(0, -1):each(function(x, y) if p.m:has(x, y) and not lip:has(x, y) then c:put(x, y, PEA[1], vtok) end end)
end
-- pointed beak at the tip
for _, q in ipairs{ { 9, 41, 3 }, { 8, 40, 4 }, { 8, 39, 3 }, { 7, 38, 2 } } do c:put(q[1], q[2], POD[q[3]], vtok) end

-- calyx at the stem end: five pointed sepals hugging the pod shoulder
local ktok = { r = { name = "calyx" } }
for _, s in ipairs{ { 50, 38, 2 }, { 51, 34, 1.6 }, { 57, 35, 1.6 }, { 58, 40, 1.6 }, { 54, 42, 1.6 } } do
  A.leaf(c, 54, 38, (54 + s[1]) / 2, (38 + s[2]) / 2, s[1], s[2], s[3] * 0.8, LEAF, { tok = ktok, vs = 9, fold = 0.3, pw = 0.6 })
end
c:put(54, 38, LEAF[1], ktok) c:put(53, 38, LEAF[2], ktok)
-- stalk and tendril
local stok = { r = { name = "stalk" } }
A.stem(c, { { 54, 37 }, { 56, 32 }, { 56, 27 }, { 53, 23 } }, function(t) return 1.05 - t * 0.2 end, STEM, { tok = stok })
local sp = A.spiral(49, 24, -0.2, 3.0, -0.1, 24, -1)
for _, p in ipairs{ { 52, 22 }, { 51, 21 } } do c:put(p[1], p[2], STEM[3], stok) end
for _, p in ipairs(sp) do c:put(p[1], p[2], p[2] > 24 and STEM[2] or STEM[3], stok) end

-- quirk: a dewdrop sliding down the belly
local dtok = { r = { name = "dew" } }
A.map(c, {
  ".a.",
  "acm",
  "amm",
  ".s.",
}, 27, 53, { a = "#d8fff0", c = A.CREAM, m = "#8fd8b8", s = "#2f6b55" }, dtok)

A.save(c, NAME)
