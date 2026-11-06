-- chickpea (final, Opus single pass). One short puffy chickpea pod split open on the diagonal (straw-green, downy
-- stipple, dark suture, pale concave lining) holding two wrinkled beaked peas; a slim stalk with a calyx and a sprig
-- of small glaucous leaflets at the top; two loose peas rolled out below. quirk: a dewdrop on the pod's shoulder.
local NAME = "chickpea"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local POD = { "#4a5626", "#6c7a34", "#94a04a", "#b8c062", "#d4d886", "#eef0b4" }
local LIN = { "#8a8a4a", "#b0ac68", "#ccc88c", "#e4dcac" }
local CP = { "#6a4a30", "#94703f", "#bc9558", "#d9b678", "#efd59c", "#fff0c4" }
local LEAF = { "#1c3a3e", "#28524c", "#3a6e5a", "#58905f", "#80b070", "#b4d494" }
local STEM = { "#4e6a3a", "#76904a", "#a2b866", "#cad890" }

local ANG = -0.62
local PCX, PCY = 34, 29
local ca, sa = cos(ANG), sin(ANG)
-- pod: oval with pointed beak at lower-left
local pod, pn = A.oval(PCX, PCY, 12, 6.2, ANG, 0.8)
local bx, by = PCX - ca * 13, PCY - sa * 13
pod:add(c:line({ { floor(bx + 1.5), floor(by - 0.5) }, { floor(bx - 1.5), floor(by + 1.5) } }, 1))
for _, k in ipairs{} do end
local cav = A.oval(PCX - 0.6, PCY + 0.6, 9.5, 3.4, ANG, 1)
local peaA = c:ellipse(29, 32, 3.6, 3.4)
local peaB = c:ellipse(37, 27, 3.6, 3.4)

-- stalk + calyx + leaf sprig (behind pod)
local stok = { r = { name = "stalk" } }
local SP = { { 44, 23 }, { 48, 19 }, { 49, 15 }, { 47, 9 } }
local sm, sn = A.tube(SP, function(t) return 1.2 - 0.3 * t end)
sm:cut(pod)
X.tone(c, sm, X.light(sn, { amb = 0.12, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local ltok = { r = { name = "leaf" } }
local lm = HP.mask()
for _, q in ipairs{ { 0.45, -1, 4.6 }, { 0.6, 1, 4.4 }, { 0.75, -1, 4.0 }, { 0.88, 1, 3.6 } } do
  local x, y = A.bez(SP, q[1])
  local ux, uy = A.rot(0, -1, q[2] * 1.2)
  lm:add(A.leaflet(x + ux * 0.8, y + uy * 0.8, ux, uy, q[3], 1.5))
end
do local x, y = A.bez(SP, 1) lm:add(A.leaflet(x, y + 0.5, -0.3, -0.95, 4, 1.5)) end
lm:cut(sm):cut(pod)
A.toneN(c, lm, X.pillow(lm, 1.5), LEAF, { tok = ltok, cuts = A.LCUTS, amb = 0.2, wrap = 0.3 })
for i = 0, 30 do local t = 0.4 + 0.6 * i / 30 local x, y = A.bez(SP, t)
  local xi, yi = floor(x + .5), floor(y + .5) if not sm:has(xi, yi) then c:put(xi, yi, STEM[3], stok) end end

-- pod shell
do
  local tok = { r = { name = "pod" } }
  local bias = {}
  pod:each(function(x, y) if A.X.hash(x, y, 2) > 0.8 then bias[K(x, y)] = 1 end end) -- downy stipple
  X.ao(bias, pod, cav, 1, -1)
  for k, nn in pairs(pn) do end
  local v = X.light(pn, { amb = 0.1, wrap = 0.3 })
  -- fill beak (no normals) by giving it mid light
  pod:each(function(x, y) local k = K(x, y) if not v[k] then v[k] = 0.45 end end)
  X.tone(c, pod, v, POD, { cuts = A.CUTS6, bias = bias, tok = tok })
  -- calyx: five little sepals at the stalk end
  local ex, ey = PCX + ca * 12, PCY + sa * 12
  for _, d in ipairs{ { -1, 0 }, { 0, -1 }, { 1, 0 }, { 0, 1 }, { 1, -1 } } do
    c:put(floor(ex + d[1] + .5), floor(ey + d[2] + .5), (d[1] + d[2] < 0) and LEAF[5] or LEAF[3], tok) end
  -- concave lining: lit from lower-right inside
  local cn = {}
  local cn0 = select(2, A.oval(PCX - 0.6, PCY + 0.6, 9.5, 3.4, ANG, 1))
  for k, nn in pairs(cn0) do cn[k] = { -nn[1], -nn[2], nn[3] } end
  X.tone(c, cav, X.light(cn, { amb = 0.15, wrap = 0.3 }), LIN, { cuts = { 0.3, 0.55, 0.8 }, tok = tok })
  -- suture: dark line along the upper lip of the opening
  cav:edge():each(function(x, y)
    local dx, dy = x - PCX, y - PCY
    if (-dx * sa + dy * ca) < 0 then c:put(x, y, POD[1], tok) end end)
  -- lit rim along the lower lip
  cav:grow(1):cut(cav):each(function(x, y)
    local dx, dy = x - PCX, y - PCY
    if pod:has(x, y) and (-dx * sa + dy * ca) > 0 then c:put(x, y, POD[5], tok) end end)
  -- glossy pod sheen
  c:put(30, 25, POD[6], tok) c:put(31, 24, POD[6], tok) c:put(32, 24, A.CREAM, tok)
end
-- peas in the pod (contact shadow on lining below each)
for _, pm in ipairs{ peaA, peaB } do pm:shift(1, 1):each(function(x, y) if cav:has(x, y) and not pm:has(x, y) then c:put(x, y, LIN[1]) end end) end
A.chickpea(c, 29, 32, 3.6, -2.4, CP, { name = "pa", ph = 1.3 })
A.chickpea(c, 37, 27, 3.6, -2.0, CP, { name = "pb", ph = 0.2 })
-- loose peas below
local l1 = c:ellipse(25, 48, 4.4, 4)
A.chickpea(c, 15, 44, 5, -2.2, CP, { name = "l0", ph = 2.6, clip = l1 })
A.chickpea(c, 25, 48, 4.4, -0.7, CP, { name = "l1", ph = 1.7 })
-- quirk: dewdrop on the pod shoulder
A.dew(c, 41, 31)
A.save(c, NAME)
