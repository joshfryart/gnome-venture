-- prunes (D10, Sonnet artist pass). Three dried plums with air between the back two: deep indigo skins shrivelled into
-- wavy lengthwise wrinkles, a pale waxy bloom on the lit shoulder, cool bounce on the shade side, a stem dimple at the
-- top. The front one is split: a concave amber cut face with fibre lines, a rough tan stone in a darker cavity, a ring of
-- skin around it. AO and contact shadows where they meet, soft ground shadow.
-- quirk: a bead of amber syrup is sliding off the cut half's rim and about to drip.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD10_3.lua")
local G, HP, X, K = D.G, D.HP, D.X, D.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("prunes")

local PL = { "#1c1232", "#33214f", "#4d3572", "#6b4e90", "#8e72b2", "#b9a0d4" }
local FL = { "#74340f", "#a65519", "#ca7a27", "#e49a37", "#f6bb58", "#ffe08c" }
local PIT = { "#3a2116", "#5a3622", "#7e5236", "#a47550", "#c89a6a", "#e6c698" }
local BLOOM, BOUNCE = "#cdc2e6", "#5a66b0"

c:groundShadow(32, 58, 21, 2.6)

-- geometry first (so every part can cast onto the others)
local P = {
  A = { cx = 21, cy = 26, rx = 10.2, ry = 11.4, ang = 1.45, seed = 1 },
  B = { cx = 44, cy = 28, rx = 9.6, ry = 10.8, ang = 1.7, seed = 2 },
  C = { cx = 32, cy = 46, rx = 12.2, ry = 9.6, ang = 0.06, seed = 3 },
}
for _, p in pairs(P) do p.m, p.n = G.oval(p.cx, p.cy, p.rx, p.ry, p.ang, 0.85) end
local whole = c:rect(0, 0, 63, 63)

local function whole_prune(p, others, stemdx)
  local bias = {}
  for _, o in ipairs(others) do X.ao(bias, p.m, o.m, 2, -1) G.cast(bias, p.m, o.m, 1, 2, -1) end
  local ca, sa = cos(p.ang), sin(p.ang)
  local U, V = {}, {}
  p.m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - p.cx, y - p.cy
    local u = (dx * ca + dy * sa) / (p.rx + 0.45)
    local v = (-dx * sa + dy * ca) / (p.ry + 0.45)
    U[k], V[k] = u, v
    -- shrivel: wavy valleys running along the long axis, puffy ridges between, a few cross creases
    local g = (v * 0.5 + 0.5) * 4.0 + 1.3 * sin(u * 2.9 + p.seed * 2.1)
    local fr = g - floor(g)
    if fr < 0.16 then bias[k] = (bias[k] or 0) - 2
    elseif fr > 0.5 and fr < 0.74 then bias[k] = (bias[k] or 0) + 1 end
    if abs(u - 0.15 * p.seed + 0.3) < 0.07 and abs(v) < 0.6 and X.hash(x, y, 3 + p.seed) > 0.3 then bias[k] = (bias[k] or 0) - 1 end
  end)
  local tok = { r = { name = "prune" .. p.seed } }
  local idx = G.toneN(c, p.m, p.n, PL, { bias = bias, tok = tok, cuts = { 0.2, 0.38, 0.56, 0.72, 0.88 }, amb = 0.1, wrap = 0.3 })
  -- cool bounce on the lower-right rim
  local rim = X.rim(p.n)
  p.m:edge():each(function(x, y) local k = K(x, y)
    if rim[k] and rim[k] > 0.72 and not bias[k] and (idx[k] or 0) <= 3 then c:put(x, y, BOUNCE, tok) end end)
  -- waxy bloom: pale specks on the lit shoulder, kept off the rim
  local inner = p.m:copy():shrink(1)
  inner:each(function(x, y) local k = K(x, y)
    if (idx[k] or 0) >= 4 and X.hash(x, y, 11 + p.seed) > 0.94 then c:put(x, y, BLOOM, tok) end end)
  -- stem dimple at the top end (u < 0 is the upper-left end)
  local sx, sy = p.cx - p.rx * 0.78 * ca * 1.0 + 0, p.cy - p.rx * 0.78 * sa
  return tok, ca, sa
end

-- back prunes: oriented with their long axis tilted so the stem end sits upper
local tokA = whole_prune(P.A, { P.C })
local tokB = whole_prune(P.B, { P.C })
-- specular: one bright 2x1 + glint on each shoulder, a dark dimple with a tiny stem stub
local function shoulder(p, x, y, stem)
  c:put(x, y, "#f4efff") c:put(x + 1, y, "#f4efff") c:put(x, y + 1, PL[6]) c:put(x - 1, y - 1 + 1, PL[6])
  local sx, sy = stem[1], stem[2]
  c:put(sx, sy, PL[1]) c:put(sx + 1, sy, PL[1]) c:put(sx - 1, sy, PL[2]) c:put(sx, sy + 1, PL[2]) c:put(sx + 1, sy + 1, PL[2])
  c:put(sx, sy - 1, "#6a4a2c") c:put(sx + 1, sy - 1, "#8a6238") c:put(sx, sy - 2, "#6a4a2c") c:put(sx + 1, sy - 2, "#a67c46")
end
shoulder(P.A, 15, 22, { 20, 15 })
shoulder(P.B, 39, 24, { 44, 18 })

-- front prune: split half. skin ring, concave flesh, stone in a cavity
local C = P.C
local tokS = { r = { name = "skin" } }
local tokF = { r = { name = "flesh" } }
local tokP = { r = { name = "pit" } }
local sb = {}
X.ao(sb, C.m, P.A.m, 0, 0)
G.toneN(c, C.m, C.n, PL, { bias = sb, tok = tokS, cuts = { 0.2, 0.38, 0.56, 0.72, 0.88 }, amb = 0.1, wrap = 0.3 })
-- cut face: slightly smaller oval, tilted toward the viewer (centre nudged up)
local fm, fn = G.oval(C.cx - 0.5, C.cy - 0.6, C.rx - 2.2, C.ry - 2.0, C.ang, 0.7)
local cn = {}
for k, n in pairs(fn) do cn[k] = { -n[1], -n[2], n[3] } end      -- concave: light from upper-left now hits the lower-right wall
local fbias = {}
local pm, pn = G.oval(C.cx + 0.5, C.cy - 0.4, 5.5, 3.5, 0.12, 0.8)
X.ao(fbias, fm, pm, 1, -1)
fm:each(function(x, y) local k = K(x, y)
  -- fibres radiating from the stone
  local dx, dy = x - (C.cx + 0.5), y - (C.cy - 0.4)
  local a = math.atan(dy, dx)
  local fr = (a / pi * 9) % 1
  if fr < 0.14 and dx * dx + dy * dy > 40 then fbias[k] = (fbias[k] or 0) - 1 end
end)
G.toneN(c, fm, cn, FL, { bias = fbias, tok = tokF, cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 }, amb = 0.14, wrap = 0.3 })
-- thin dark skin lip around the flesh (inner ring) + lit lip upper-left
fm:edge():each(function(x, y) local k = K(x, y) c:put(x, y, (x + y < C.cx + C.cy - 4) and PL[3] or PL[2], tokS) end)
-- stone: cavity rim then the rough stone
local cav = pm:copy():grow(1)
cav:each(function(x, y) if fm:has(x, y) then c:put(x, y, FL[1], tokF) end end)
G.toneN(c, pm, pn, PIT, { tok = tokP, cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 }, amb = 0.1, wrap = 0.3 })
pm:each(function(x, y)
  local k = K(x, y)
  -- ridged stone: pale ridges along its length, dark grooves
  local g = (x * 0.9 + y * 0.35) * 0.8 + 1.7 * sin(y * 1.1)
  local fr = g - floor(g)
  if fr < 0.16 then c:put(x, y, PIT[2], tokP) elseif fr > 0.5 and fr < 0.62 and X.hash(x, y, 2) > 0.3 then c:put(x, y, PIT[5], tokP) end
end)
c:put(29, 43, PIT[6], tokP) c:put(30, 43, PIT[6], tokP) c:put(28, 44, PIT[5], tokP)
-- glossy flesh sparkle (sticky) + specular on the lit lower-right of the cavity wall
c:put(40, 47, FL[6], tokF) c:put(41, 47, FL[6], tokF) c:put(40, 48, FL[5], tokF) c:put(24, 48, FL[5], tokF)
-- bloom on the skin ring
for _, p in ipairs{ { 25, 54 }, { 33, 55 }, { 40, 54 }, { 22, 52 } } do if C.m:has(p[1], p[2]) and not fm:has(p[1], p[2]) then c:put(p[1], p[2], BLOOM, tokS) end end

-- quirk: syrup bead sliding off the lower rim and dripping
local SY = { "#8a3e10", "#bf6a1a", "#e8962c", "#fdc050", "#ffe488" }
local sy = { tok = { r = { name = "syrup" } } }
local stok = sy.tok
for _, p in ipairs{ { 37, 53, 2 }, { 38, 53, 3 }, { 37, 54, 2 }, { 38, 54, 3 }, { 37, 55, 2 }, { 38, 55, 3 } } do c:put(p[1], p[2], SY[p[3]], stok) end
c:put(37, 56, SY[2], stok) c:put(38, 56, SY[3], stok)
c:put(36, 58, SY[2], stok) c:put(37, 58, SY[3], stok) c:put(38, 58, SY[3], stok) c:put(39, 58, SY[2], stok)
c:put(36, 59, SY[1], stok) c:put(37, 59, SY[2], stok) c:put(38, 59, SY[2], stok) c:put(39, 59, SY[1], stok)
c:put(37, 57, SY[3], stok) c:put(38, 57, SY[2], stok) c:put(37, 58, SY[4], stok)
c:put(37, 54, SY[5], stok)
D.save(c, "prunes")
