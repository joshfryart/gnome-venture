-- jute-mallow (final pass, Opus aC13_2). A cut bunch of jute mallow (molokhia): three slim reddish-green stems tied
-- with a band of twisted jute twine, glossy saw-toothed lanceolate leaves (midrib + side veins, the two hair-like
-- tails at the leaf base), one small five-petal yellow flower and a slender ridged seed capsule on the centre stem.
-- Pale cut ends on the stems, AO where the twine bites into them.
-- quirk: the twine is the plant's own fibre - its loose end has frayed into a pale tuft of strands.
local NAME = "jute-mallow"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF = { "#123a2a", "#1a5432", "#28703c", "#3e9046", "#62b250", "#9cd468" }
local STEM = { "#3a2a24", "#5a3c2c", "#7a5a34", "#8e7a3e", "#aca052", "#cac67a" }
local TWINE = { "#3a2618", "#5a3e24", "#80602e", "#a4823e", "#c8a65a", "#e8cc8c" }
local PET = { "#8a5a10", "#c88a14", "#eebc24", "#ffe066", "#fff4b0" }
local POD = { "#1e3a22", "#2c5228", "#3e6c30", "#58883a", "#7aa448", "#a6c86a" }
local COOL = "#3a6874"
STEM[5] = "#aca052"

local ltok, stok = { r = { name = "leaf" } }, { r = { name = "stem" } }
local stems = {
  { { 29, 56 }, { 27, 45 }, { 21, 30 }, { 16, 19 } },
  { { 31, 56 }, { 31, 46 }, { 31, 32 }, { 30, 21 } },
  { { 33, 56 }, { 35, 45 }, { 40, 30 }, { 45, 17 } },
}
-- leaves: base, control, tip, half-width (terminal and side leaves)
local leaves = {
  { 16, 19, 12, 15, 10, 9, 3.4 },
  { 45, 17, 50, 13, 53, 8, 3.4 },
  { 23, 34, 16, 31, 9, 33, 3.0 },
  { 38, 35, 46, 31, 54, 33, 3.0 },
  { 25, 41, 20, 44, 13, 49, 2.8 },
}
-- stems first (leaves overlap their bases), AO under the twine later
local stemAll = HP.mask()
for i, p in ipairs(stems) do
  local m = A.stem(c, p, function(t) return 1.15 - 0.3 * t end, STEM, { tok = stok, amb = 0.12 })
  stemAll:add(m)
end
-- seed capsule off the centre stem: long, slim, ridged, pointed
local podP = { { 31, 37 }, { 33, 33 }, { 35, 29 }, { 37, 24 } }
local pm, pn, PT, PS = A.tube(podP, function(t) return t < 0.06 and 0.7 or (1.6 - 1.2 * t ^ 3) end)
pm:cut(stemAll)
local ptok = { r = { name = "pod" } }
local pidx = A.shade(c, pm, pn, POD, { tok = ptok, amb = 0.1, wrap = 0.3 })
pm:each(function(x, y) local k = K(x, y)
  if abs(PS[k] - 0.15) < 0.22 and PT[k] > 0.1 and PT[k] < 0.92 then c:put(x, y, POD[max(1, pidx[k] - 2)], ptok) end
  if abs(PS[k] + 0.5) < 0.18 and PT[k] > 0.15 and PT[k] < 0.85 then c:put(x, y, POD[min(6, pidx[k] + 1)], ptok) end
end)

-- leaves
local leafAll = HP.mask()
for i, L in ipairs(leaves) do
  local m, T, S, idx = A.leaf(c, L[1], L[2], L[3], L[4], L[5], L[6], L[7], LEAF, {
    serr = 2.6, vs = 2.8, tok = ltok, cool = COOL, pw = 0.6, fold = 0.5, cut = pm })
  -- the two hair-like tails at the blade base (jute mallow tell)
  local dx, dy = L[3] - L[1], L[4] - L[2]
  local l = sqrt(dx * dx + dy * dy) dx, dy = dx / l, dy / l
  local px, py = -dy, dx
  for _, sd in ipairs{ -1, 1 } do
    local hx, hy = L[1] + dx * 2.4 + px * sd * 2.6, L[2] + dy * 2.4 + py * sd * 2.6
    local xi, yi = floor(hx + .5), floor(hy + .5)
    if not m:has(xi, yi) and not stemAll:has(xi, yi) then c:put(xi, yi, LEAF[3], ltok) end
  end
  leafAll:add(m)
end

-- flower at the centre stem tip: five rounded petals, orange throat, pale stamens
local fx, fy = 30, 18
local ftok = { r = { name = "flower" } }
local fm = HP.mask()
for i = 0, 4 do local a = -pi / 2 + i * 2 * pi / 5
  fm:add(A.rell(fx + cos(a) * 2.5, fy + sin(a) * 2.5, cos(a), sin(a), 1.9, 1.5)) end
fm:add(A.rell(fx, fy, 1, 0, 1.6, 1.6))
local fn = X.pillow(fm, 2.2)
A.shade(c, fm, fn, PET, { tok = ftok, amb = 0.16, wrap = 0.3, cuts = { 0.25, 0.45, 0.65, 0.85 } })
-- petal clefts (darker spokes)
for i = 0, 4 do local a = -pi / 2 + (i + 0.5) * 2 * pi / 5
  local x, y = floor(fx + cos(a) * 2.6 + .5), floor(fy + sin(a) * 2.6 + .5)
  if fm:has(x, y) then c:put(x, y, PET[2], ftok) end end
c:put(fx, fy, PET[1], ftok) c:put(fx + 1, fy, PET[2], ftok) c:put(fx, fy - 1, PET[5], ftok) c:put(fx - 1, fy - 1, PET[5], ftok)
-- sepal cup under the flower
for _, q in ipairs{ { 29, 22, 3 }, { 30, 22, 4 }, { 31, 22, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- twine band around the bunch (twisted ply), AO on stems above and below
local twM = HP.mask()
for y = 50, 53 do for x = 26, 37 do
  local cx = 31.5
  if abs(x - cx) <= 5.2 - ((y == 50 or y == 53) and 0.6 or 0) then twM:set(x, y) end
end end
local twn = {}
twM:each(function(x, y) local sx = (x - 31.5) / 6.0 local sy = (y - 51.5) / 3.0
  twn[K(x, y)] = { A.norm(sx * 0.9, sy * 0.6, 1) } end)
local ttok = { r = { name = "twine" } }
local tidx = A.shade(c, twM, twn, TWINE, { tok = ttok, amb = 0.1, wrap = 0.3 })
-- twist: diagonal ply grooves every 3 px
twM:each(function(x, y) local k = K(x, y)
  local d = (x + y * 1) % 3
  if d == 0 then c:put(x, y, TWINE[max(1, tidx[k] - 2)], ttok) elseif d == 1 and tidx[k] >= 3 then c:put(x, y, TWINE[min(6, tidx[k] + 1)], ttok) end
end)
-- AO rings on stems at the band
for _, y in ipairs{ 49, 54 } do for x = 26, 37 do if stemAll:has(x, y) then c:put(x, y, STEM[1], stok) end end end
-- loose end of twine hanging right, frayed into strands (quirk)
local tail = { { 37, 52 }, { 39, 53 }, { 40, 54 }, { 41, 56 } }
for i, q in ipairs(tail) do c:put(q[1], q[2], TWINE[(i % 2 == 0) and 3 or 5], ttok) c:put(q[1], q[2] + 1, TWINE[2], ttok) end
for _, q in ipairs{ { 41, 58, 6 }, { 42, 58, 5 }, { 43, 57, 6 }, { 40, 58, 4 }, { 43, 59, 5 } } do c:put(q[1], q[2], TWINE[q[3]], ttok) end

-- pale cut ends at the stem bottoms
for _, x in ipairs{ 29, 31, 33 } do c:put(x, 57, STEM[6], stok) c:put(x, 58, STEM[3], stok) end
A.save(c, NAME)
