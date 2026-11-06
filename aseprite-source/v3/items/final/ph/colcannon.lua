-- colcannon (final, Opus single pass). A heaped mound of creamy mashed potato, folded into soft lumps (AO line where
-- each lump sits on the mound), flecked with dark kale and a few pale spring-onion rings, in a slim shallow
-- sea-glaze bowl (lit lip, glossy streak, cool underside, foot ring, 2-tone ground shadow). A pat of butter melts
-- into a golden pool in the well on top.
-- quirk: a bead of melted butter runs down the side of the mash.
local NAME = "colcannon"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local MASH = { "#a08058", "#c4a474", "#dcc490", "#eedcae", "#f8ecc8", "#fff6dc" }
local BOWL = { "#24366a", "#2f5090", "#3a70ac", "#4f96c4", "#7cc0d8", "#b8eaea" }
local KALE = { "#1c4630", "#2a663a", "#3e8a42", "#64ac52" }
local ONION = { "#7cb860", "#c4e49a" }
local BUT = { "#b8701c", "#d9941e", "#f0b62a", "#fbd44a", "#ffe988", "#fff6c4" }

local CX, RY0 = 32, 38
c:groundShadow(CX, 52, 15, 2)

-- bowl body (lower half ellipse) + foot
local body = c:ellipse(CX, RY0, 20, 11)
body:cut(c:rect(0, 0, 63, RY0 - 1))
local foot = c:rect(CX - 7, 48, CX + 7, 50)
local btok = { r = { name = "bowl" } }
local function bowlN(m)
  local n = {}
  m:each(function(x, y)
    local nx = max(-0.95, min(0.95, (x - CX) / 21))
    local ny = max(0, min(0.9, (y - RY0) / 12)) * 0.8
    n[K(x, y)] = { A.norm(nx, ny, sqrt(max(0.05, 1 - nx * nx - ny * ny))) }
  end)
  return n
end
local fbias = {}
X.ao(fbias, foot, body, 1, -1)
foot:cut(body)
A.shade(c, foot, bowlN(foot), BOWL, { amb = 0.05, wrap = 0.25, bias = fbias, tok = btok })
local bidx = A.shade(c, body, bowlN(body), BOWL, { amb = 0.05, wrap = 0.25, tok = btok })
-- glossy streak + cool underside bounce
for _, q in ipairs{ { 17, 41 }, { 18, 42 }, { 19, 43 }, { 20, 44 } } do c:put(q[1], q[2], BOWL[6], btok) end
c:put(16, 40, A.CREAM, btok)
body:edge():each(function(x, y) if y > RY0 + 6 and x > CX - 4 and x < CX + 15 then c:put(x, y, "#5a5aa0", btok) end end)

-- rim: outer ring of the mouth ellipse
local mouth = c:ellipse(CX, RY0, 20, 5)
local inner = c:ellipse(CX, RY0, 18, 3.6)
local rim = mouth:copy():cut(inner)
local rtok = { r = { name = "rim" } }
rim:each(function(x, y)
  local t = (x - CX) / 20
  local i = (y < RY0) and 5 or 4
  if t > 0.45 then i = i - 1 end
  if t < -0.5 and y >= RY0 then i = 6 end
  c:put(x, y, BOWL[i], rtok)
end)
-- glaze inside (back wall) peeks between rim and mash
inner:each(function(x, y) c:put(x, y, BOWL[2], rtok) end)

-- mash mound: dome + lumps, clipped by the front rim
local mound = c:ellipse(CX, 33, 16, 9)
local lumps = { { 24, 29, 5, 4 }, { 33, 25, 6, 4.2 }, { 41, 30, 5, 3.6 }, { 28, 34, 5, 3 }, { 39, 35, 5, 2.6 } }
local lm = {}
for i, q in ipairs(lumps) do lm[i] = c:ellipse(q[1], q[2], q[3], q[4]) mound:add(lm[i]) end
local front = rim:copy():add(body)
local below = c:rect(0, RY0, 63, 63)
local frontRim = rim:copy():clip(below)
mound:cut(below:copy():cut(inner)):cut(frontRim)
local mbias = {}
X.ao(mbias, mound, frontRim, 1, -1)
-- AO row where each lump sits on the one under it (lower-right edges of lumps)
for i, l in ipairs(lm) do
  l:each(function(x, y)
    if mound:has(x, y) and (not l:has(x + 1, y + 1) or not l:has(x, y + 1)) and mound:has(x, y + 1) and y > lumps[i][2] - 1 then
      mbias[K(x, y)] = (mbias[K(x, y)] or 0) - 1 end end)
end
local mtok = { r = { name = "mash" } }
local np = X.pillow(mound, 4)
local ns = X.sphere(CX - 1, 30, 15, mound)
local n = {}
for k, a in pairs(np) do local b = ns[k] n[k] = { A.norm(a[1] * 0.5 + b[1] * 0.5, a[2] * 0.5 + b[2] * 0.5, a[3] * 0.5 + b[3] * 0.5) } end
local midx = A.shade(c, mound, n, MASH, { amb = 0.12, wrap = 0.3, bias = mbias, tok = mtok })

-- kale flecks (2px dashes) and spring-onion rings
mound:each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 5) < 0.07 and mound:has(x + 1, y) and not mbias[k] then
    local lit = (midx[k] or 3) >= 4
    c:put(x, y, KALE[lit and 3 or 2], mtok) c:put(x + 1, y, KALE[lit and 2 or 1], mtok)
    if X.hash(x, y, 9) < 0.4 and mound:has(x, y - 1) then c:put(x, y - 1, KALE[lit and 4 or 3], mtok) end
  end end)
for _, q in ipairs{ { 22, 31 }, { 43, 33 }, { 30, 36 } } do
  for _, d in ipairs{ { 0, -1 }, { 1, 0 }, { 0, 1 }, { -1, 0 } } do c:put(q[1] + d[1], q[2] + d[2], d[2] < 0 and ONION[2] or ONION[1], mtok) end
end

-- butter: melting pat in a golden pool on the top well
local but = { r = { name = "butter" } }
local pool = c:ellipse(33, 23, 5, 1.6)
pool:each(function(x, y) c:put(x, y, (y > 23 or x > 36) and BUT[3] or BUT[4], but) end)
local pat = c:rect(31, 20, 35, 22)
pat:each(function(x, y) c:put(x, y, (y == 20) and BUT[5] or ((x == 35 or y == 22) and BUT[3] or BUT[4]), but) end)
c:put(31, 20, BUT[6], but) c:put(32, 20, A.CREAM, but)
c:put(30, 23, BUT[2], but) c:put(36, 22, BUT[2], but)
-- quirk: drip of melted butter running down the right of the mound
for i, q in ipairs{ { 38, 24 }, { 39, 25 }, { 39, 26 }, { 40, 27 }, { 40, 28 }, { 40, 29 } } do c:put(q[1], q[2], BUT[(i % 2 == 0) and 3 or 4], but) end
c:put(39, 30, BUT[3], but) c:put(40, 30, BUT[2], but) c:put(41, 29, BUT[1], but) c:put(39, 29, BUT[5], but)

A.save(c, NAME)
