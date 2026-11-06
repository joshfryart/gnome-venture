-- ico-pie (Opus single pass, aA8_1). A cherry pie seen three-quarter from above in a fluted tin: thumb-crimped crust
-- rim, woven lattice (strips go over/under at the crossings) on glossy cherry filling with whole cherries showing.
-- Material: 6-tone baked pastry lit per pixel (pillow normals), sugar specks on the lattice, dark ambient rows where
-- strips cross and where the lattice meets the rim; filling 6-tone with wet speculars; tin side in vertical flutes
-- with a bright lip. Ground shadow (it stands).
-- quirk: one cherry drip has escaped over the crust and runs down the tin.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA8_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, cos, pi, atan = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi, math.atan
local c = A.new("ico-pie")

local CRUST = { "#5c2c22", "#8a4a2a", "#b46e34", "#d69440", "#edbb5e", "#fbdf96" }
local FILL  = { "#3e0c24", "#6a1430", "#981e36", "#c8323e", "#ea5a50", "#ff9c86" }
local TIN   = { "#363852", "#55587a", "#7b7f9c", "#a3a7bd", "#c8ccdb", "#e6e9f1" }
local SPEC = "#fff4e8"
local CX, CY = 32, 33
local RX, RY = 25, 13          -- outer rim
local IRX, IRY = 19.5, 9.4     -- inner well

c:groundShadow(CX + 1, CY + 19, 25, 3)

-- tin side: below the rim ellipse, tapering inward
local tin = A.fmask(0, CY, 63, CY + 16, function(x, y)
  local d = y - CY
  local rx = RX - 1.5 - max(0, d - 6) * 0.25
  local ry = RY - 0.5
  local e = ((x - CX) / (rx + 0.5)) ^ 2
  if e > 1 then return false end
  local yb = CY + 6 + ry * sqrt(1 - e)
  return y <= yb
end)
local tn = {}
tin:each(function(x, y) local t = max(-0.97, min(0.97, (x - CX) / (RX - 1))) tn[K(x, y)] = { t, 0.15, sqrt(1 - t * t) } end)
local tv = X.light(tn, { amb = 0.12, wrap = 0.3 })
local ttok = { r = { name = "tin" } }
local tbias = {}
tin:each(function(x, y) local k = K(x, y)
  -- flutes: alternating ridges by angle around the rim
  local ang = math.asin(max(-1, min(1, (x - CX) / (RX - 1))))
  local f = (ang * 14 / pi) % 1
  if f < 0.33 then tbias[k] = -1 elseif f > 0.75 then tbias[k] = 1 end
end)
local tidx = A.paintV(tin, tv, TIN, { 0.25, 0.42, 0.58, 0.74, 0.88 }, tbias, ttok)
-- lower edge of the tin darker (underside)
tin:each(function(x, y) if not tin:has(x, y + 1) then c:put(x, y, TIN[1], ttok) elseif not tin:has(x, y + 2) then
  c:put(x, y, TIN[max(1, (tidx[K(x, y)] or 3) - 1)], ttok) end end)

-- crust rim (whole top ellipse), crimped outer edge
local rim = c:ellipse(CX, CY, RX, RY)
local well = c:ellipse(CX, CY - 0.5, IRX, IRY)
local ring = rim:copy():cut(well)
local rn = X.pillow(rim, 4, 1.0)
local rv = X.light(rn, { amb = 0.08, wrap = 0.25 })
local ctok = { r = { name = "crust" } }
local rb = {}
ring:each(function(x, y) local k = K(x, y)
  local dx, dy = (x - CX) / RX, (y - CY) / RY
  local ang = atan(dy, dx)
  -- thumb presses: dark radial grooves
  local f = (ang * 18 / (2 * pi)) % 1
  if f < 0.18 and dx * dx + dy * dy > 0.62 then rb[k] = -2 end
  -- inner lip slopes into the well: darker
  if ((x - CX) / (IRX + 1.2)) ^ 2 + ((y - CY + 0.5) / (IRY + 1.2)) ^ 2 <= 1 and y < CY + 2 then rb[k] = (rb[k] or 0) - 1 end
end)
local ridx = A.paintV(ring, rv, CRUST, { 0.22, 0.4, 0.56, 0.72, 0.86 }, rb, ctok)

-- filling in the well
local fn = X.pillow(well, 2.5)
for k, nn in pairs(fn) do fn[k] = { -nn[1] * 0.7, -nn[2] * 0.7, nn[3] } end     -- concave well
local fv = X.light(fn, { amb = 0.1, wrap = 0.3 })
local ftok = { r = { name = "fill" } }
A.paintV(well, fv, FILL, { 0.35, 0.55, 0.72, 0.88, 0.98 }, nil, ftok)
-- whole cherries poking up between the strips
local cherries = { { 22, 31 }, { 27, 36 }, { 37, 30 }, { 43, 36 }, { 32, 27 }, { 27, 26 }, { 38, 39 }, { 22, 37 } }
for _, q in ipairs(cherries) do
  local m = c:ellipse(q[1], q[2], 1.6, 1.3):clip(well)
  local n = X.sphere(q[1] - 0.3, q[2] - 0.3, 1.8, m)
  A.litN(m, n, FILL, { cuts = { 0.25, 0.45, 0.62, 0.8, 0.95 }, tok = ftok })
end

-- lattice: three strips each way, woven
local LW = 1.6
local hs = { CY - 5.5, CY - 0.5, CY + 4.5 }     -- horizontal strips (y centres)
local vs = { CX - 9, CX, CX + 9 }                -- vertical strips (x centres)
local inner = c:ellipse(CX, CY - 0.5, IRX + 1, IRY + 1)
local H, V = {}, {}
for i, yc in ipairs(hs) do H[i] = A.fmask(0, 0, 63, 63, function(x, y) return abs(y - yc) <= 1.1 and inner:has(x, y) end) end
for j, xc in ipairs(vs) do
  -- vertical strips lean slightly with perspective (fan out toward the viewer)
  V[j] = A.fmask(0, 0, 63, 63, function(x, y)
    local xx = xc + (xc - CX) * (y - CY) * 0.035
    return abs(x - xx) <= LW and inner:has(x, y) end)
end
local function strip(m, horiz)
  local n = {}
  m:each(function(x, y)
    local s
    if horiz then
      local yc for _, v in ipairs(hs) do if abs(y - v) <= 1.1 then yc = v end end
      s = (y - yc) / 1.6
      n[K(x, y)] = { 0, s * 0.9, sqrt(1 - min(0.9, s * s * 0.81)) }
    else
      local xc for _, v in ipairs(vs) do local xx = v + (v - CX) * (y - CY) * 0.035 if abs(x - xx) <= LW then xc = xx end end
      s = (x - xc) / 2.1
      n[K(x, y)] = { s * 0.9, 0, sqrt(1 - min(0.9, s * s * 0.81)) }
    end
  end)
  return n
end
local hm, vm = HP.mask(), HP.mask()
for _, m in ipairs(H) do hm:add(m) end
for _, m in ipairs(V) do vm:add(m) end
local hn, vn = strip(hm, true), strip(vm, false)
-- woven: at crossing (i,j) the horizontal strip is on top when (i+j) even
local onTopV = HP.mask()
for i = 1, 3 do for j = 1, 3 do if (i + j) % 2 == 1 then onTopV:add(H[i]:copy():clip(V[j])) end end end
local hb, vb = {}, {}
-- AO: under strip next to the over strip darkens; strips darken at the rim
local hOnly = hm:copy():cut(onTopV)
X.ao(hb, hm:copy():cut(vm), vm, 1, -1)
local vOnly = vm:copy():cut(hm):add(onTopV)
X.ao(vb, vm:copy():cut(hm), hm:copy():cut(onTopV), 1, -1)
-- shadow on the filling cast lower-right of strips
local lat = hm:copy():add(vm)
lat:shift(1, 1):each(function(x, y) if well:has(x, y) and not lat:has(x, y) then c:put(x, y, FILL[1], ftok) end end)
A.paintV(hOnly, X.light(hn, { amb = 0.1, wrap = 0.3 }), CRUST, { 0.22, 0.4, 0.56, 0.72, 0.86 }, hb, ctok)
A.paintV(vOnly, X.light(vn, { amb = 0.1, wrap = 0.3 }), CRUST, { 0.22, 0.4, 0.56, 0.72, 0.86 }, vb, ctok)
-- strips fade under the rim lip (ambient)
lat:each(function(x, y) if not well:has(x, y) then c:put(x, y, CRUST[3], ctok) end end)
-- sugar specks on the lattice
lat:each(function(x, y) if well:has(x, y) and X.hash(x, y, 7) > 0.9 then c:put(x, y, CRUST[6], ctok) end end)

-- rim spec + glossy filling glints
c:put(14, 26, CRUST[6], ctok) c:put(15, 25, CRUST[6], ctok) c:put(16, 25, SPEC, ctok)
for _, q in ipairs(cherries) do if well:has(q[1] - 1, q[2] - 1) and not lat:has(q[1] - 1, q[2] - 1) then
  c:put(q[1] - 1, q[2] - 1, FILL[6], ftok) end end
c:put(26, 25, SPEC, ftok)

-- quirk: a cherry drip over the front rim and down the tin
local drip = { { 39, 44 }, { 40, 44 }, { 39, 45 }, { 40, 45 }, { 39, 46 }, { 40, 46 }, { 39, 47 }, { 40, 47 }, { 40, 48 }, { 39, 48 }, { 39, 49 }, { 40, 49 } }
for _, q in ipairs(drip) do c:put(q[1], q[2], FILL[4], ftok) end
c:put(40, 44, FILL[3], ftok) c:put(40, 45, FILL[3], ftok) c:put(40, 46, FILL[3], ftok) c:put(40, 47, FILL[3], ftok)
c:put(39, 45, FILL[6], ftok) c:put(40, 49, FILL[2], ftok) c:put(39, 50, FILL[3], ftok) c:put(40, 50, FILL[2], ftok)
c:put(39, 51, FILL[2], ftok)

-- steam-free: one bright sugar sparkle on the lit rim
A.done()
