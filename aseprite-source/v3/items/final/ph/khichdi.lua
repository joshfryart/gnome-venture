-- khichdi (final, Opus single pass). A hammered copper bowl on a slim foot ring, heaped with soft golden khichdi:
-- turmeric rice and split moong, pale rice grains and a few green whole moong, a glossy pool of ghee on top with a
-- tadka of cumin seeds, one curry leaf and a slim dried red chilli. Copper: per-pixel light, bright bevelled lip,
-- hammer dimples, specular streak, cool reflected light, AO under the lip and where the foot meets; ground shadow.
-- quirk: a bead of ghee has run over the lip and is dripping down the outside of the bowl.
local NAME = "khichdi"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local CU   = { "#3e1c26", "#6a2c28", "#9a4428", "#c4623a", "#e48c5a", "#ffc89a" }
local KH   = { "#7a5024", "#a8782a", "#cfa036", "#e8c24e", "#f6da7c", "#fff0b4" }
local RICE, MOONG = "#fff4d6", { "#3f7a3a", "#6aa84e" }
local GHEE = { "#e8a828", "#ffd860", "#fff1b8" }
local LEAF = { "#1f5240", "#3f8a4c", "#7cc35a" }
local CHILI = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local CUMIN = "#5a3a26"

c:groundShadow(32, 52, 14, 2)
-- foot ring
local foot = c:rrect(25, 46, 39, 50, 1)
local fn = select(2, X.cyl(25, 48, 39, 48, function() return 7 end, nil))
local fnn = {}
foot:each(function(x, y) local s = (x - 32) / 8 fnn[K(x, y)] = { A.norm(s, 0.2, sqrt(max(0.05, 1 - s*s))) } end)
local ftok = { r = { name = "foot" } }
local fb = {} foot:each(function(x, y) if y == 46 then fb[K(x, y)] = -2 end end)
A.shade(c, foot, fnn, CU, { tok = ftok, bias = fb, amb = 0.08 })
-- bowl body
local body = c:ellipse(32, 31, 21, 15):clip(c:rect(0, 31, 63, 63))
local bn = X.sphere(30, 26, 24, body)
local btok = { r = { name = "bowl" } }
local bb = {}
body:each(function(x, y) if y <= 32 then bb[K(x, y)] = -1 end end)   -- AO under the lip
local bidx = A.shade(c, body, bn, CU, { tok = btok, bias = bb, cuts = { 0.18, 0.32, 0.48, 0.64, 0.82 }, amb = 0.08, wrap = 0.3 })
-- hammer dimples: little lit/dark pixel pairs
body:each(function(x, y) local k = K(x, y)
  if y > 33 and y < 44 and (x * 5 + y * 3) % 9 == 0 and (y % 3 == 0) then
    local i = bidx[k]
    c:put(x, y, CU[max(1, i - 1)], btok)
    if body:has(x - 1, y - 1) then c:put(x - 1, y - 1, CU[min(6, i + 1)], btok) end
  end end)
-- specular streak on the upper-left belly + cool bounce on the lower right
for _, p in ipairs{ { 17, 35 }, { 17, 36 }, { 18, 37 }, { 18, 38 }, { 19, 39 } } do c:put(p[1], p[2], CU[6], btok) end
c:put(17, 34, A.CREAM, btok)
local rim = X.rim(bn)
body:edge():each(function(x, y) if rim[K(x, y)] > 0.55 and x > 34 then c:put(x, y, "#7a4a6a", btok) end end)
-- lip: bevelled rim ellipse ring
local lipO = c:ellipse(32, 31, 21, 5)
local lipI = c:ellipse(32, 31, 19, 4)
local lip = lipO:copy():cut(lipI)
local ltok = { r = { name = "lip" } }
lip:each(function(x, y)
  local front = y >= 31
  local i
  if front then i = (x < 26) and 6 or (x < 40) and 5 or 4 else i = (x < 32) and 3 or 2 end
  if y == 26 or (front and y == 36) then i = max(1, i - 1) end
  c:put(x, y, CU[i], ltok)
end)
-- inner wall (far side) shows above the food: dark copper
local inner = lipI:copy()
local itok = { r = { name = "inner" } }
inner:each(function(x, y) c:put(x, y, y < 29 and CU[2] or CU[3], itok) end)

-- khichdi mound: fills the opening, domes up
local mound = c:ellipse(32, 31, 18, 3.6):add(c:ellipse(31, 30, 15, 8):clip(c:rect(0, 0, 63, 31)))
mound:clip(c:rect(0, 0, 63, 34))
local mn = X.sphere(29, 28, 17, mound)
local mtok = { r = { name = "khichdi" } }
local mb = {}
mound:each(function(x, y) if not lipI:has(x, y) or y >= 33 then mb[K(x, y)] = -1 end end)
local midx = A.shade(c, mound, mn, KH, { tok = mtok, bias = mb, cuts = { 0.12, 0.28, 0.44, 0.6, 0.78 }, amb = 0.12, wrap = 0.35 })
-- texture: rice grains (2x1 pale), moong (green dots), soft lumps
mound:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 21) local i = midx[k]
  if h < 0.06 and mound:has(x + 1, y) then c:put(x, y, i >= 4 and RICE or KH[5], mtok) c:put(x + 1, y, KH[min(6, i + 1)], mtok)
  elseif h < 0.09 then c:put(x, y, MOONG[i >= 4 and 2 or 1], mtok)
  elseif h > 0.92 then c:put(x, y, KH[max(1, i - 1)], mtok) end end)
-- re-draw the front lip over the mound so the food sits inside
lip:each(function(x, y) if y >= 32 then
  local i = (x < 26) and 6 or (x < 40) and 5 or 4 if y == 36 then i = i - 1 end c:put(x, y, CU[i], ltok) end end)
c:put(19, 33, A.CREAM, ltok)
-- ghee pool on top
local pool = c:ellipse(30, 25, 5, 1.6)
pool:each(function(x, y) c:put(x, y, (x < 29 and y <= 25) and GHEE[2] or GHEE[1], mtok) end)
c:put(28, 24, GHEE[3]) c:put(29, 24, A.CREAM)
-- cumin seeds
for _, p in ipairs{ { 24, 27 }, { 36, 26 }, { 38, 29 }, { 22, 30 }, { 33, 28 }, { 27, 29 } } do
  c:put(p[1], p[2], CUMIN) c:put(p[1] + 1, p[2], KH[2]) end
-- curry leaf: small pointed leaf, left
local cl, cln, CT, CS = A.blade(20, 25, 23, 21, 28, 21, function(t) return 1.8 * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.7 end, { fold = 0.4 })
A.shade(c, cl, cln, { LEAF[1], LEAF[1], LEAF[2], LEAF[2], LEAF[3], LEAF[3] }, { amb = 0.2 })
cl:each(function(x, y) local k = K(x, y) if abs(CS[k]) < 0.18 and CT[k] > 0.1 and CT[k] < 0.85 then c:put(x, y, LEAF[3]) end end)
-- dried red chilli: slim curved pod with a green cap, right
local ch, chn, CHT = A.tube({ { 35, 23 }, { 39, 21 }, { 43, 22 }, { 45, 25 } }, function(t) return 1.5 * (1 - t) ^ 0.6 + 0.3 end)
local chidx = A.shade(c, ch, chn, { CHILI[1], CHILI[2], CHILI[2], CHILI[3], CHILI[3], CHILI[4] }, { amb = 0.15 })
ch:each(function(x, y) if CHT[K(x, y)] > 0.3 and CHT[K(x, y)] < 0.36 then c:put(x, y, CHILI[1]) end end)
c:put(34, 23, LEAF[1]) c:put(34, 22, LEAF[2]) c:put(33, 22, LEAF[2])
do local x, y = A.specAt(ch, chn, 30) if x then c:put(x, y, "#ffd0b0") end end
-- contact shadow under the chilli onto the khichdi
ch:shift(0, 1):each(function(x, y) if mound:has(x, y) and not ch:has(x, y) then c:put(x, y, KH[2], mtok) end end)

-- quirk: ghee drip over the right-front lip, running down the outside
for _, p in ipairs{ { 42, 34, 1 }, { 42, 35, 2 }, { 42, 36, 2 }, { 42, 37, 1 }, { 42, 38, 1 }, { 42, 39, 2 }, { 42, 40, 1 } } do
  c:put(p[1], p[2], GHEE[p[3]]) end
c:put(41, 40, GHEE[1]) c:put(41, 41, GHEE[2]) c:put(42, 41, GHEE[1]) c:put(41, 39, GHEE[3])
A.save(c, NAME)
