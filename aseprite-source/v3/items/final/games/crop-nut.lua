-- crop-nut (final, Opus single pass). A slim upright acorn: a tall glossy nut narrowing to a pale point, under a
-- scaly cupule worn at a jaunty tilt, a short woody stalk and one small lobed oak leaf.
-- Material: per-pixel ellipsoid light (6-tone chestnut, cool-violet shade), fine meridian grain lines, one cream
-- specular streak, cool reflected light lower-right, pale tip with a dark ring. Cup: overlapping scales in offset
-- rows (dark lower lip, lit crown), rolled rim, contact shadow on the nut under the rim. Leaf: lobed edge, midrib.
-- quirk: the cap sits tilted like a beret, showing a sliver of pale nut-top on the high side.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA0_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, pi, max, min, sqrt, abs, atan = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.abs, math.atan
local c = A.new("crop-nut")
local NUT  = { "#43231f", "#6a3626", "#94512e", "#bb7136", "#d9954c", "#f0bf74" }
local CUP  = { "#2e2220", "#4a3428", "#664a32", "#86663e", "#a68650", "#c8aa6c" }
local LEAF = { "#1f3c33", "#2a5840", "#3c7646", "#5a944c", "#82b25a", "#b0cf72" }
local STEM = { "#3a2a20", "#5e4630", "#86683f", "#ad9058" }
local SPEC, BOUNCE, TIPC = "#fff4d6", "#8a6a8a", { "#8a6a44", "#c9a46c", "#e8cf98" }

local CX = 32
-- nut: ellipse body + tapered point
local nut = c:ellipse(CX, 41, 7.5, 11):add(c:poly{ {CX - 3, 49}, {CX + 3.5, 49}, {CX + 0.5, 55.2} })
nut = nut:grow(1):shrink(1)
local nn = A.body(nut, CX - 0.5, 41, 11, 4, 0.7)
-- ellipsoid: squash vertical normal component
for k, a in pairs(nn) do nn[k] = { A.norm(a[1] * 1.15, a[2] * 0.7, a[3]) } end

-- cap geometry (tilted): local coords u (across), w (down) about pivot
local ANG = -0.3
local PX, PY = CX, 32.5
local ca, sa = cos(ANG), sin(ANG)
local function loc(x, y) local dx, dy = x - PX, y - PY return dx * ca + dy * sa, -dx * sa + dy * ca end
local cap, cn, CU, CW = HP.mask(), {}, {}, {}
for y = 18, 40 do for x = 14, 50 do
  local u, w = loc(x + 0.0, y + 0.0)
  local RX, RY = 10.4, 8.2
  if w <= 1.6 and w >= -RY - 0.5 and (u / (RX + 0.45))^2 + (min(w, 0) / (RY + 0.45))^2 <= 1 then
    cap:set(x, y)
    local k = K(x, y)
    local nu, nw = u / (RX + 0.5), min(w, 0) / (RY + 0.5)
    local nz = sqrt(max(0.03, 1 - nu*nu - nw*nw))
    if w > 0 then nw = 0.35 end                       -- rolled rim faces down-out
    local gx, gy = nu * ca - nw * sa, nu * sa + nw * ca
    cn[k] = { A.norm(gx, gy, nz) }
    CU[k], CW[k] = u, w
  end
end end
-- nut-top sliver revealed on the high (left) side under the tilted rim
nut:add(cap:copy():shift(0, 2):cut(cap):clip(c:rect(22, 30, 30, 38)):clip(c:ellipse(CX, 40, 8, 11)))
nn = A.body(nut, CX - 0.5, 41, 11, 4, 0.7)
for k, a in pairs(nn) do nn[k] = { A.norm(a[1] * 1.15, a[2] * 0.7, a[3]) } end
nut:cut(cap)

-- stalk (behind leaf, on top of cap): from cap crown up and right
local capTopX, capTopY = PX + 8.4 * sa, PY - 8.4 * ca
local LT = { r = { name = "leaf" } }
-- small lobed oak leaf behind the stalk
A.leaf(c, capTopX + 1.5, capTopY - 2.5, capTopX + 8, capTopY - 13, capTopX + 19, capTopY - 11, 4.2, LEAF, {
  tok = LT, vs = 3.4,
  wfn = function(t) if t > 0.985 then return -1 end
    local base = 4.2 * sin(pi * min(1, t * 0.97 + 0.05)) ^ 0.7
    return max(0.4, base * (0.8 + 0.2 * cos(t * 21))) end })
A.stem(c, { {capTopX, capTopY + 1}, {capTopX, capTopY - 1.5}, {capTopX + 0.6, capTopY - 3}, {capTopX + 2, capTopY - 4.2} },
  function(t) return 1.3 - 0.35 * t end, STEM)

-- nut tones + AO under the rim
local bias = {}
X.ao(bias, nut, cap, 2, -1)
local ntok = { r = { name = "nut" } }
local idx, v = A.shade(c, nut, nn, NUT, { bias = bias, tok = ntok, cuts = { 0.16, 0.32, 0.5, 0.7, 0.86 } })
-- meridian grain lines
nut:each(function(x, y) local k = K(x, y)
  local hw = 7.5 * sqrt(max(0.05, 1 - ((y - 41) / 12)^2))
  local u = (x - CX + 0.3) / hw
  if abs(u) < 0.92 and y > 32 and y < 51 then
    local ph = (math.asin(max(-1, min(1, u))) / pi * 9) % 1
    if ph < 0.16 and X.hash(x, floor(y / 4), 3) > 0.2 then c:put(x, y, NUT[max(1, idx[k] - 1)], ntok) end
  end
end)
-- pale pointed tip with a dark ring above it
nut:each(function(x, y)
  if y >= 52 then c:put(x, y, (x <= CX) and TIPC[2] or TIPC[1], ntok)
  elseif y == 51 then c:put(x, y, NUT[1], ntok) end
end)
c:put(CX, 52, TIPC[3], ntok)
-- reflected light
local rim = X.rim(nn)
nut:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.72 and y > 40 and y < 50 and x > CX then c:put(x, y, BOUNCE, ntok) end end)
-- specular streak + glint on the left
for _, p in ipairs{ {27, 39}, {27, 40}, {27, 41}, {28, 38} } do c:put(p[1], p[2], NUT[6], ntok) end
c:put(27, 40, SPEC, ntok) c:put(27, 41, SPEC, ntok) c:put(29, 37, SPEC, ntok)

-- cap tones
local ctok = { r = { name = "cup" } }
local cidx = A.shade(c, cap, cn, CUP, { tok = ctok, amb = 0.08, cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 } })
-- scales: offset rows in cap coords, each scale = a small arc: dark lower lip, lit upper face
cap:each(function(x, y) local k = K(x, y)
  local u, w = CU[k], CW[k]
  if w < -0.2 then
    local row = floor((w + 9.5) / 2.8)
    local rw = (w + 9.5) / 2.8 - row
    local cell = (u * (1.25 - 0.05 * row) + (row % 2) * 1.6) / 3.2
    local cu = (cell % 1) - 0.5
    local i = cidx[k]
    if rw > 0.7 - cu * cu * 0.8 or (abs(cu) > 0.4 and rw > 0.3) then c:put(x, y, CUP[max(1, i - 2)], ctok)
    elseif rw < 0.38 and abs(cu) < 0.22 and i >= 2 then c:put(x, y, CUP[min(6, i + 2)], ctok) end
  end
end)
-- rolled rim: lit top row, dark underside
cap:each(function(x, y) local k = K(x, y)
  local w = CW[k]
  if w > 0.6 then c:put(x, y, CUP[max(1, min(6, cidx[k] - 1))], ctok)
  elseif w > -0.5 then c:put(x, y, CUP[min(6, cidx[k] + 1)], ctok) end
end)
-- crown boss where the stalk joins
c:put(floor(capTopX + 0.5), floor(capTopY + 1.5), CUP[1], ctok)
c:put(floor(capTopX - 0.5), floor(capTopY + 1.5), CUP[2], ctok)
A.save(c, "crop-nut")
