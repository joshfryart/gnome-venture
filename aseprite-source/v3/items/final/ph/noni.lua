-- noni (final, Opus single pass). Morinda fruit: a slim, lopsided upright oval covered in polygonal "eyes" (each a
-- domed cell with a brown pip at its centre, creased borders between), pale yellow-green ripening to waxy cream at the
-- lower right, short woody stalk with one glossy elliptical noni leaf (sunken veins).
-- Material: per-pixel light on body + per-cell dome normals (6-tone), crease AO between cells, waxy bloom flecks,
-- cool reflected light lower-right, one cream specular, AO under the stalk.
-- quirk: a tiny white star flower is still blooming out of one eye on the shoulder (real noni flowers on the fruit).
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "noni"
local c = A.new(NAME)
local FR   = { "#2f3d33", "#52683c", "#82963f", "#b2bf58", "#d8df86", "#f2f2bc" }
local RIPE = { "#4c4636", "#7c7448", "#aaa266", "#d2ca8c", "#ece6b4", "#fbf7de" }
local PIP, PIPD = "#7a5530", "#4e3326"
local WOOD = { "#3e2622", "#62402e", "#8c623f", "#b88a58" }
local LEAF = { "#123a32", "#1d553f", "#2a7447", "#3f964d", "#62b656", "#98d46a" }
local COOL, SPEC = "#8fb0b8", "#fff4d6"
local CX, CY = 31, 38

-- stalk + leaf first
local wtok = { r = { name = "stalk" } }
A.stem(c, { { 31, 24 }, { 31, 20 }, { 32, 17 }, { 34, 14 } }, function(t) return 1.4 - 0.3 * t end, WOOD, { tok = wtok })
c:put(34, 13, WOOD[4], wtok) c:put(35, 13, WOOD[3], wtok)
A.leaf(c, 33, 16, 41, 5, 55, 9, 4.6, LEAF, { pw = 0.8, fold = 0.5 })

-- body: lopsided egg, a touch fuller low on the right, tilted slightly
local body = HP.mask()
for y = CY - 15, CY + 16 do
  local t = (y - (CY - 15)) / 31
  local hw = 10.6 * sin(pi * min(1, t * 0.96 + 0.04)) ^ 0.62 + (t > 0.5 and 0.8 * (t - 0.5) or 0)
  local cx = CX + (t - 0.5) * 2.2
  for x = floor(cx - hw + 0.5), floor(cx + hw + 0.5) do
    -- lumpy outline: cells bulge the silhouette a little
    body:set(x, y)
  end
end
-- lumpy rim: nibble pixels at cell borders on the silhouette
local cells = {}
for r = 0, 8 do for q = 0, 6 do
  local x = CX - 15 + q * 5 + ((r % 2 == 1) and 2.5 or 0) + (X.hash(q, r, 5) - 0.5) * 1.4
  local y = CY - 17 + r * 4.4 + (X.hash(q, r, 9) - 0.5) * 1.2
  cells[#cells + 1] = { x, y }
end end
local cellOf, border, dOff = {}, {}, {}
body:each(function(x, y) local k = K(x, y)
  local b1, b2, i1 = 1e9, 1e9, 0
  for i, p in ipairs(cells) do local d = sqrt((x - p[1])^2 + (y - p[2])^2)
    if d < b1 then b2 = b1 b1, i1 = d, i elseif d < b2 then b2 = d end end
  cellOf[k] = i1 dOff[k] = { x - cells[i1][1], y - cells[i1][2], b1 }
  if b2 - b1 < 0.9 then border[k] = true end
end)
local rimNib = {}
body:edge():each(function(x, y) if border[K(x, y)] then rimNib[#rimNib + 1] = K(x, y) end end)
for _, k in ipairs(rimNib) do body.s[k] = nil end

local nb = A.body(body, CX - 1, CY, 15, 6, 0.6)
-- per-cell dome perturbation
local n = {}
for k, nn in pairs(nb) do local o = dOff[k]
  local px, py = o and o[1] / 2.6 or 0, o and o[2] / 2.4 or 0
  n[k] = { A.norm(nn[1] + px * 0.42, nn[2] + py * 0.42, nn[3]) }
end
local bias = {}
X.ao(bias, body, c:rect(29, CY - 18, 33, CY - 16), 2, -1)
for k in pairs(border) do if body.s[k] then bias[k] = (bias[k] or 0) - 1 end end
local v = X.light(n, { amb = 0.06, wrap = 0.22 })
local ftok = { r = { name = "fruit" } }
-- ripening: cream on the lower right, ragged boundary
local ripe = {}
body:each(function(x, y) local k = K(x, y)
  local d = (x - CX) * 0.55 + (y - CY) * 0.85
  if d > 9 + (X.hash(cellOf[k] or 0, 1, 3) - 0.5) * 6 then ripe[k] = true end
end)
local idx = X.tone(c, body, v, FR, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bias, tok = ftok })
for k in pairs(ripe) do local x, y = k % 1024 - 256, k // 1024 - 256 c:put(x, y, RIPE[idx[k]], ftok) end
-- eye pips: centre pixel of every cell well inside the body
local inner = body:copy():shrink(1)
for i, p in ipairs(cells) do
  local x, y = floor(p[1] + 0.5), floor(p[2] + 0.5)
  if inner:has(x, y) then
    c:put(x, y, (idx[K(x, y)] or 3) >= 4 and PIP or PIPD, ftok)
    if inner:has(x + 1, y + 1) and X.hash(i, 2, 7) > 0.5 then c:put(x + 1, y + 1, PIPD, ftok) end
  end
end
-- waxy bloom: pale flecks on the lit cell tops
inner:each(function(x, y) local k = K(x, y)
  local o = dOff[k]
  if o and o[3] > 1 and o[3] < 1.9 and o[1] < 0 and o[2] < 0 and idx[k] >= 4 and X.hash(x, y, 13) > 0.6 then
    c:put(x, y, ripe[k] and RIPE[6] or FR[6], ftok) end
end)
-- cool reflected light lower-right
local rim = X.rim(nb)
body:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.62 and y > CY - 2 then c:put(x, y, COOL, ftok) end end)
-- specular
c:put(24, 30, SPEC, ftok) c:put(25, 30, SPEC, ftok) c:put(24, 31, FR[6], ftok)
-- stalk cavity AO
for x = 29, 33 do if body:has(x, CY - 15) then c:put(x, CY - 15, FR[1], ftok) end end
c:put(31, CY - 14, FR[2], ftok)

-- quirk: tiny white star flower out of an eye on the right shoulder
local ftk = { r = { name = "flower" } }
local FX, FY = 37, 29
local PET, PETS = "#f4f0ea", "#c9c2d6"
for _, q in ipairs{ { 0, -2 }, { 0, -3 }, { 2, -1 }, { 3, -1 }, { 1, 1 }, { 2, 2 }, { -1, 1 }, { -2, 2 }, { -2, -1 }, { -3, -1 } } do
  c:put(FX + q[1], FY + q[2], (q[2] > 0) and PETS or PET, ftk) end
c:put(FX, FY, "#f0c040", ftk) c:put(FX, FY - 1, PET, ftk) c:put(FX + 1, FY, PET, ftk) c:put(FX - 1, FY, PETS, ftk)
c:put(FX, FY + 1, FR[2], ftk)

A.save(c, NAME)
