-- quince-seed (final, Sonnet high). A broad torn quince-leaf scrap (grey-green, felted pale underside showing on the torn
-- fibre rim, midrib + swept veins). Three glossy red-brown wedge pips glued tip to tip into a clover by a thick amber
-- jelly coat (mucilage bevel, wet specular), and a fourth pip that has split and sent up a pale hypocotyl, two oval
-- cotyledons and the first real quince leaves (ovate, pointed, downy rim).
-- quirk: a bead of the pip jelly has stretched into a string and hangs off the scrap's lower edge.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_0.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("quince-seed")
local LEAF = { "#27393a", "#3b5a47", "#547a54", "#74986a", "#9bb881", "#c6d7a0" }
local FUZZ = "#e4ecc4"
local PIP = { "#24111a", "#44191d", "#6b2b22", "#93432a", "#b9683a", "#e09a5e" }
local JEL = { "#7d3f1c", "#b86d26", "#dc9234", "#f0b246", "#fbd273", "#fff0b4" }
local STEM = { "#5d8a58", "#87b068", "#b0d08a", "#d8eaae" }
local ltok = { r = { name = "leaf" } }

-- pips (cx, cy, len, width, ang)
local pips = { { 16, 48, 10, 6, pi - 0.28 }, { 27, 48, 10, 6, 0.62 }, { 22, 53, 8, 5.4, pi / 2 } }
local sp = { 41, 47, 10, 6, -0.28 }
local jelly = HP.mask()
for _, p in ipairs(pips) do p.m = A.wedge(p[1], p[2], p[3], p[4], p[5], 0.3) jelly:add(p.m:grow(1)) end
sp.m = A.wedge(sp[1], sp[2], sp[3], sp[4], sp[5], 0.3)
local jelly2 = sp.m:grow(1)
-- fillets in the junctions between pips (jelly webbing)
jelly:add(c:ellipse(21.5, 49, 2.2, 2.4))
jelly:add(c:rect(20, 47, 23, 51))

-- leaf scrap: broad, pointed at the petiole end, ragged torn right end and a bite out of the upper edge
local function sw(t)
  if t > 0.97 then return -1 end
  local w = 7.8 * sin(pi * (0.07 + 0.86 * t)) ^ 0.55
  if t > 0.8 then w = w * (0.55 + 0.45 * X.hash(floor(t * 60), 4, 8)) end
  return max(0.6, w)
end
local bias = {}
G.cast(bias, HP.mask():add(c:rect(0, 0, 63, 63)), jelly, 1, 2, -1)
G.cast(bias, HP.mask():add(c:rect(0, 0, 63, 63)), jelly2, 1, 2, -1)
local lm, ln, LT, LS, len, torn = A.tornBlade(c, 8, 50, 29, 54, 55, 43, sw, {
  ramp = LEAF, veins = { 0.2, 0.32, 0.44, 0.56, 0.68, 0.8 }, sweep = 2.4, fibre = "#dfe6bc", cool = "#4b6d7a", bias = bias,
  tear = { [-1] = { depth = 0.5, t0 = 0.32, t1 = 0.7 }, [1] = { depth = 0.28, t0 = 0.55, t1 = 0.95 } } })
-- petiole stub
for _, q in ipairs{ { 7, 51, 3 }, { 6, 52, 2 }, { 5, 52, 2 }, { 6, 51, 3 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout (behind the husk)
local sm = A.stem(c, { { 41, 44 }, { 41, 38 }, { 43, 31 }, { 43, 24 } }, 1.1, 0.85, STEM)
local function downy(m, prob, seed)
  m:edge():each(function(x, y) if X.hash(x, y, seed) < prob then c:put(x, y, FUZZ, ltok) end end)
end
local function blade(ax, ay, cx, cy, bx, by, w, veins, cut)
  local m, n, T, S = A.tornBlade(c, ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, w * sin(pi * min(1, t * 0.93 + 0.07)) ^ 0.62 * (t > 0.6 and (1 - (t - 0.6) * 0.5) or 1))
  end, { ramp = LEAF, veins = veins or {}, sweep = 2.0, rib = 0.16, cool = "#4b6d7a", fold = 0.35 })
  return m
end
local cl = blade(43, 29, 36, 25, 29, 27.5, 2.5, {})
local cr = blade(43, 29, 50, 25, 55, 27.5, 2.5, {})
downy(cl, 0.35, 11) downy(cr, 0.35, 12)
-- epicotyl + true leaves
A.stem(c, { { 43, 28 }, { 43, 24 }, { 44, 20 }, { 44, 16 } }, 0.85, 0.7, STEM)
local tl = blade(44, 21, 47, 15, 53, 12.5, 4.3, { 0.25, 0.4, 0.55, 0.7 })
local tl2 = blade(43, 23, 38, 18, 33, 17, 3.0, { 0.3, 0.5, 0.7 })
downy(tl, 0.5, 13) downy(tl2, 0.5, 14)

-- jelly bed (amber, glossy), then pips
local jt = { r = { name = "jelly" } }
local jall = jelly:copy():add(jelly2)
local jn = X.pillow(jall, 2.4)
G.toneN(c, jall, jn, JEL, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = jt, amb = 0.1, wrap = 0.2 })
local function pip(p, hole)
  local m = p.m
  local n = X.pillow(m, 2.4)
  -- lengthwise tilt: a slight ridge along the long axis makes the wedge read as flattened
  local ca, sa = cos(p[5]), sin(p[5])
  for k, nn in pairs(n) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    local v = (-(x - p[1]) * sa + (y - p[2]) * ca) / (p[4] / 2 + 0.3)
    n[k] = { A.norm(nn[1] + (-sa) * v * 0.0 + (-sa * 0.1), nn[2] + ca * 0.1, nn[3]) }
  end
  local ptok = { r = { name = "pip" } }
  G.toneN(c, m, n, PIP, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = ptok, amb = 0.06, wrap = 0.15 })
  -- hilum line: a pale scar along the pointed end and fine seed-coat flecks
  local u0x, u0y = p[1] - ca * (p[3] / 2 - 1), p[2] - sa * (p[3] / 2 - 1)
  m:each(function(x, y)
    local u = ((x - p[1]) * ca + (y - p[2]) * sa)
    local v = (-(x - p[1]) * sa + (y - p[2]) * ca)
    if u < -p[3] / 2 + 2.2 and abs(v) < 0.6 then c:put(x, y, PIP[5], ptok) end
    if X.hash(x, y, 31) > 0.93 and u > -1 then c:put(x, y, PIP[4], ptok) end
  end)
  -- specular on the blunt shoulder (upper-left lit)
  local bx, by = G.specAt(m, n, 22)
  if bx then c:px(bx, by, "#fff0d0") c:px(bx + 1, by, PIP[6]) end
end
for _, p in ipairs(pips) do pip(p) end
pip(sp)
-- split husk at the sprouting pip: cream inside + torn coat lips
for _, q in ipairs{ { 36, 45 }, { 37, 44 }, { 37, 45 } } do c:put(q[1], q[2], "#f0dcae", jt) end
c:put(36, 44, "#c9a470", jt) c:put(38, 43, PIP[5], jt)
-- jelly specular streaks (wet shine)
for _, q in ipairs{ { 12, 44, 2 }, { 24, 43, 2 }, { 19, 56, 1 }, { 38, 41, 2 }, { 46, 45, 1 } } do
  if jall:has(q[1], q[2]) then c:put(q[1], q[2], JEL[6], jt) if q[3] == 2 and jall:has(q[1] + 1, q[2]) then c:put(q[1] + 1, q[2], JEL[6], jt) end end
end
-- quirk: jelly string with a bead hanging off the lower scrap edge
for _, q in ipairs{ { 31, 57, 3 }, { 31, 58, 4 } } do c:put(q[1], q[2], JEL[q[3]], jt) end
A.bead(c, 31, 60, 1.7, JEL, { spec = JEL[6] })
c:put(30, 59, JEL[6], jt)
A.save(c, "quince-seed")
