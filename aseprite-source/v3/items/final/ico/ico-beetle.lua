-- ico-beetle (Opus single pass). Top-down jewel beetle, head up: small dark head with curved mandibles and
-- eyes, rounded pronotum, long slim oval elytra split down the middle, six jointed legs splayed, short antennae.
-- Material: per-pixel ellipsoid light on an iridescent 6-tone ramp (violet deep -> teal -> green -> lime hi),
-- punctured striae rows, bevelled seam (dark groove + lit lip), glossy specular streaks, violet rim on the
-- shade side, AO under the pronotum and where legs tuck under the body.
-- quirk: a single dewdrop rides on its right wing case.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, abs, max, min, sqrt, pi = math.floor, math.sin, math.cos, math.abs, math.max, math.min, math.sqrt, math.pi
local c = A.new("ico-beetle")
local JEWEL = { "#2a1f4e", "#1f4a62", "#1d7a6a", "#2ea86c", "#6fd26a", "#c6f08c" }
local PRO   = { "#24183e", "#2e2a5e", "#2f4f80", "#3a78a0", "#5aa6c0", "#a6e0e6" }
local LEG   = { "#1a1226", "#2a1f3c", "#3c2e56", "#54457a", "#7464a0", "#a294c8" }
local RIM, SPEC = "#7a4ab0", "#f4ffe0"
local DROP = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#9ee6e0", "#d2f8f2", "#f4fffb" }
local CX = 31.5

-- legs first (body paints over their roots). each: 3 points, mirrored
local legs = {
  { { 27, 22 }, { 21, 18 }, { 19, 12 } },
  { { 25, 33 }, { 17, 31 }, { 14, 36 } },
  { { 25, 44 }, { 19, 48 }, { 17, 54 } },
}
local legAll = HP.mask()
local function mir(p) return { 63 - p[1], p[2] } end
for _, L in ipairs(legs) do
  for side = 1, 2 do
    local P = side == 1 and L or { mir(L[1]), mir(L[2]), mir(L[3]) }
    local m = A.limb(P, 1.0)
    local n = {}
    m:each(function(x, y) n[K(x, y)] = { -0.3, -0.3, 0.9 } end)
    local idx = A.shade(m, n, LEG, { bias = setmetatable({}, { __index = function() return -2 end }) })
    m:each(function(x, y) if not m:has(x - 1, y) or not m:has(x, y - 1) then A.set(idx, LEG, x, y, 4) end end)
    A.set(idx, LEG, P[2][1], P[2][2], 6)
    -- tarsus claw nub
    c:px(P[3][1], P[3][2], LEG[2])
    legAll:add(m)
  end
end
-- antennae (thin, short, beaded tip)
for side = 1, 2 do
  local P = { { 27, 12 }, { 24, 9 }, { 21, 8 } }
  if side == 2 then P = { mir(P[1]), mir(P[2]), mir(P[3]) } end
  A.ln(P[1][1], P[1][2], P[2][1], P[2][2], LEG[3]) A.ln(P[2][1], P[2][2], P[3][1], P[3][2], LEG[4])
  c:px(P[3][1], P[3][2] - 1, LEG[5]) c:px(P[3][1] + (side == 1 and -1 or 1), P[3][2] - 1, LEG[4])
end

-- elytra: slim oval, slightly pointed tail
local em = HP.mask()
local en = {}
local ECY, ERX, ERY = 38, 10.6, 14
for y = floor(ECY - ERY), floor(ECY + ERY) + 1 do for x = 18, 46 do
  local v = (y - ECY) / (ERY + 0.4)
  local rx = (ERX + 0.4) * (1 - 0.22 * max(0, v) ^ 2.2)
  local u = (x - CX) / rx
  local q = u * u + v * v
  if q <= 1 then
    em:set(x, y)
    -- two domes: each elytron leans outward a bit
    local half = x < CX and -1 or 1
    local nx = u * 0.85 + half * 0.12
    local ny = v * 0.85
    local nz = sqrt(max(0.04, 1 - q))
    local l = sqrt(nx * nx + ny * ny + nz * nz)
    en[K(x, y)] = { nx / l, ny / l, nz / l }
  end
end end
local ebias = {}
local eidx = A.shade(em, en, JEWEL, { bias = ebias, amb = 0.06, wrap = 0.2 })
-- seam: dark groove on x=31/32, lit lip on the left of it
for y = 25, 52 do
  if em:has(31, y) then A.set(eidx, JEWEL, 31, y, 1) end
  if em:has(32, y) then A.set(eidx, JEWEL, 32, y, 2) end
  if em:has(30, y) and y > 26 and y < 49 then A.sh(eidx, JEWEL, 30, y, 1) end
end
-- striae: dotted rows of punctures, two per elytron
for _, sx in ipairs{ 25, 28, 35, 38 } do
  for y = 28, 49, 2 do
    local x = sx + floor((y - 38) * (sx < CX and 1 or -1) * 0.06 + .5)
    if em:has(x, y) and em:has(x, y + 2) then A.sh(eidx, JEWEL, x, y, -1) end
  end
end
-- violet iridescent rim on the shade side
em:edge():each(function(x, y) local nn = en[K(x, y)]
  if nn and nn[1] * 0.7 + nn[2] * 0.7 > 0.35 then c:px(x, y, RIM) end end)
-- glossy specular streaks (one per wing case) + one glint
for _, p in ipairs{ { 25, 29 }, { 25, 30 }, { 24, 31 }, { 24, 32 }, { 26, 28 } } do A.set(eidx, JEWEL, p[1], p[2], 6) end
for _, p in ipairs{ { 35, 29 }, { 35, 30 }, { 34, 31 } } do A.set(eidx, JEWEL, p[1], p[2], 5) end
c:px(25, 30, SPEC)

-- pronotum: rounded shield over the elytra top
local pm = HP.mask()
for y = 17, 27 do for x = 22, 41 do
  local v = (y - 22.2) / 5.4
  local rx = 8.4 - (v < 0 and 1.8 * v * v or 0)
  local u = (x - CX) / rx
  if u * u + v * v <= 1 then pm:set(x, y) end
end end
local pn = {}
pm:each(function(x, y)
  local u, v = (x - CX) / 8.6, (y - 22.2) / 5.6
  local nz = sqrt(max(0.05, 1 - u * u - v * v))
  local l = sqrt(u * u + v * v + nz * nz)
  pn[K(x, y)] = { u / l, v / l, nz / l } end)
local pidx = A.shade(pm, pn, PRO, { amb = 0.06 })
-- AO: elytra just under the pronotum, legs under the body
A.ao(eidx, JEWEL, em, pm, 2, -1)
pm:each(function(x, y) if em:has(x, y + 1) and not pm:has(x, y + 1) then A.sh(pidx, PRO, x, y, -1) end end)
-- pronotum gloss + centre line
A.set(pidx, PRO, 27, 20, 6) A.set(pidx, PRO, 28, 19, 6) A.set(pidx, PRO, 26, 21, 5)
for y = 19, 25 do A.sh(pidx, PRO, 31, y, -1) end

-- head: small, dark, eyes at the sides, curved mandibles
local hm = HP.mask()
for y = 10, 17 do for x = 25, 38 do
  local u, v = (x - CX) / 5.2, (y - 14.2) / 3.8
  if u * u + v * v <= 1 then hm:set(x, y) end end end
local hn = {}
hm:each(function(x, y) local u, v = (x - CX) / 5.4, (y - 14.2) / 4
  local nz = sqrt(max(0.05, 1 - u * u - v * v)) local l = sqrt(u * u + v * v + nz * nz)
  hn[K(x, y)] = { u / l, v / l, nz / l } end)
local hidx = A.shade(hm, hn, LEG, { amb = 0.1 })
A.ao(hidx, LEG, hm, pm, 1, -1)
-- mandibles
for side = 1, 2 do
  local pts = { { 29, 10 }, { 28, 9 }, { 28, 8 }, { 29, 7 }, { 30, 7 } }
  local s2 = side == 1 and 1 or -1
  for i, p in ipairs(pts) do
    local q = side == 2 and mir(p) or p
    c:px(q[1], q[2], i < 3 and LEG[4] or LEG[3])
    if i < 4 then c:px(q[1] + s2, q[2], LEG[2]) end
  end
end
-- eyes: 2x3 ink pills with glint at the head sides
c:eyeSmall(26, 12) c:eyeSmall(36, 12)
-- clear mouth line between the mandibles
c:px(31, 10, A.INK) c:px(32, 10, A.INK)

-- quirk: dewdrop on the right elytron (glass: dark rim lower-right, pale core, bright glint)
local dm = c:ellipse(37, 41, 1.8, 1.8)
local dn = X.sphere(37, 41, 2, dm)
local didx = A.shade(dm, dn, DROP, { amb = 0.3, wrap = 0.4 })
c:px(36, 40, SPEC)
-- the drop's shadow on the shell
for _, p in ipairs{ { 39, 43 }, { 38, 43 }, { 39, 42 } } do if not dm:has(p[1], p[2]) then A.sh(eidx, JEWEL, p[1], p[2], -2) end end

A.save("ico-beetle")
