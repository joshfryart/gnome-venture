-- oak-log (final, C3 Opus single pass). A slim oak log lying on its side in 3/4 view: deeply ridged grey-brown
-- bark (long fissured ridges, lit ridge tops), a pale end-grain face on the right with growth rings, dark pith,
-- a radial drying crack and a sapwood band inside a bark rim; a sawn branch stub on top; moss tuft at the foot.
-- Cylinder lighting per pixel, AO under the stub, 2-tone ground shadow (it stands).
-- quirk: a squirrel's acorn left tucked on top of the log.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "oak-log"
local c = A.new(NAME)
local BARK = { "#2e2128", "#4a3430", "#6b4a3a", "#8c684e", "#ad8a68", "#cdb08a" }
local WOOD = { "#7a4a2c", "#a26a3c", "#c48c50", "#dcac68", "#efca8a", "#fbe4b2" }
local MOSS = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local NUT = { "#51302b", "#864c33", "#b97a4a", "#d89a58", "#efc27e" }
local CAP = { "#3e2a24", "#5e4232", "#86644a", "#a8865e" }

c:groundShadow(31, 47, 23, 2)

-- log body: horizontal cylinder, axis y = cy, radius R; rounded far (left) end; end face on the right
local cy, R = 36, 8.6
local x0, x1 = 10, 47           -- left end centre / right end-face centre
local erx = 5.6                 -- end face half-width (3/4 view ellipse)
local body = HP.mask()
for y = floor(cy - R) - 1, floor(cy + R) + 1 do for x = x0 - 6, x1 + 1 do
  local dy = (y - cy) / (R + 0.45)
  if abs(dy) <= 1 then
    local half = sqrt(1 - dy * dy)
    if x >= x0 - erx * 0.62 * half and x <= x1 then body:set(x, y) end
  end
end end
local face = HP.mask()
for y = floor(cy - R) - 1, floor(cy + R) + 1 do for x = x1 - 8, x1 + 8 do
  local u, v = (x - x1) / (erx + 0.45), (y - cy) / (R + 0.45)
  if u * u + v * v <= 1 then face:set(x, y) end
end end
body:cut(face)

-- normals: cylinder across y, rounded off at the left end
local n = {}
body:each(function(x, y)
  local ny = max(-0.97, min(0.97, (y - cy) / (R + 0.5)))
  local nz = sqrt(1 - ny * ny)
  local nx = 0
  local dl = x - (x0 - erx * 0.62 * nz)
  if dl < 4 then nx = -(1 - dl / 4) * 0.8 end
  local l = sqrt(nx * nx + ny * ny + nz * nz)
  n[K(x, y)] = { nx / l, ny / l, nz / l }
end)
local btok = { r = { name = "bark" } }
local bias = {}
-- branch stub on top (sawn), cast AO onto bark
local stub = A.tube({ { 21, 29 }, { 20, 26 }, { 19, 24 }, { 18, 22 } }, function(t) return 2.2 - 0.3 * t end)
stub:cut(body)
local stubTop = HP.mask()
for _, p in ipairs{ { 16, 21 }, { 17, 21 }, { 18, 21 }, { 19, 21 }, { 17, 20 }, { 18, 20 }, { 19, 20 } } do stubTop:set(p[1], p[2]) end
X.ao(bias, body, stub, 1, -1)
A.cast(bias, body, stub, 1, 1, -1)
local bidx = A.shade(c, body, n, BARK, { bias = bias, tok = btok, amb = 0.06, wrap = 0.25 })
-- fissured ridges running along the log: dark furrows with lit ridge tops above them
body:each(function(x, y) local k = K(x, y)
  local i = bidx[k]
  local ph = (y + 1.3 * sin(x * 0.42 + y * 0.9) + 0.6 * sin(x * 0.17)) / 3.3
  local f = ph - floor(ph)
  local brk = X.hash(floor(x / 5), floor(ph), 11) > 0.78
  if f < 0.26 and not brk then c:put(x, y, BARK[max(1, i - 2)], btok)
  elseif f > 0.74 and not brk and i < 6 then c:put(x, y, BARK[min(6, i + 1)], btok) end
end)
-- bark rim around the end face: dark ring (bark thickness seen end-on)
local ring = face:grow(1):cut(face)
ring:each(function(x, y) if body:has(x, y) then c:put(x, y, BARK[2], btok) end end)

-- end face: pale end grain, rings, pith, crack, sapwood band, slight ambient shade lower-right
local wtok = { r = { name = "endgrain" } }
face:each(function(x, y)
  local u, v = (x - x1) / (erx + 0.45), (y - cy) / (R + 0.45)
  local d = sqrt(u * u + v * v)
  local a = math.atan(v, u)
  local i = 5
  if d > 0.86 then i = 6 end                                   -- pale sapwood band
  if d > 0.94 then i = 3 end                                   -- inner bark / cambium line
  local rph = d * 4.2 + 0.08 * sin(a * 3)
  if d <= 0.86 and rph - floor(rph) < 0.24 then i = 3 end      -- growth rings
  if u + v > 0.75 and i > 2 then i = i - 1 end                 -- ambient shade lower-right of face
  if d < 0.16 then i = 2 end                                   -- pith
  c:put(x, y, WOOD[i], wtok)
end)
-- radial drying crack from the pith toward the upper-right
for _, p in ipairs{ { 48, 35 }, { 49, 34 }, { 49, 33 }, { 50, 32 }, { 50, 31 } } do c:put(p[1], p[2], WOOD[1], wtok) end
c:put(48, 36, WOOD[1], wtok)
-- sawn-face pop: a pale glint on the upper-left of the face
c:put(44, 31, WOOD[6], wtok) c:put(45, 30, "#fff4d6", wtok)

-- branch stub: bark sides + pale sawn top
local sidx = A.shade(c, stub, select(2, A.tube({ { 21, 29 }, { 20, 26 }, { 19, 24 }, { 18, 22 } }, function(t) return 2.2 - 0.3 * t end)), BARK, { tok = btok, amb = 0.1, wrap = 0.3 })
stubTop:each(function(x, y) c:put(x, y, (x == 19 and y == 21) and WOOD[3] or WOOD[5], wtok) end)
c:put(17, 20, WOOD[6], wtok) c:put(18, 21, WOOD[4], wtok)

-- moss tuft at the foot of the log (bottom-left)
local mtok = { r = { name = "moss" } }
local moss = { "..3.3....", ".3323.3..", "3221223.3", "211112211" }
for j, row in ipairs(moss) do for i = 1, #row do
  local ch = row:sub(i, i)
  if ch ~= "." then local x, y = 12 + i - 1, 40 + j - 1
    if body:has(x, y) or j <= 2 then c:put(x, y, MOSS[tonumber(ch)], mtok) end end
end end
c:put(14, 40, MOSS[4], mtok)

-- quirk: an acorn left on top of the log (cap + glossy nut)
local atok = { r = { name = "acorn" } }
local acorn = {
  "..dd..",
  ".cbbc.",
  "abbbba",
  ".ghhf.",
  ".gihf.",
  ".ghff.",
  "..ff..",
}
local amap = { a = CAP[2], b = CAP[3], c = CAP[4], d = CAP[1], f = NUT[2], g = NUT[4], h = NUT[3], i = NUT[5] }
for j, row in ipairs(acorn) do for i = 1, #row do local ch = row:sub(i, i)
  if amap[ch] then c:put(32 + i - 1, 21 + j - 1, amap[ch], atok) end end end
c:put(34, 20, CAP[1], atok)   -- cap stalk
-- contact shadow under the acorn on the bark
for _, p in ipairs{ { 33, 28 }, { 34, 28 }, { 35, 28 }, { 36, 28 } } do if body:has(p[1], p[2]) then c:put(p[1], p[2], BARK[1], btok) end end

A.save(c, NAME)
