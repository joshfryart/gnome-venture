-- ico-dice (final, Opus). A red six-sided die in three-quarter view with softly rounded edges: lit top face (1),
-- mid left face (2), shaded right face (3). Cream pips are drilled in: dark rim on the upper-left inside the hole,
-- lit lower-right lip. Material: per-face normals bent toward the neighbour face along every seam (rounded bevel),
-- snapped to a 6-tone red ramp; polished resin specular streak on the front-left seam plus one glint, AO on the
-- lower faces, small 2-tone ground shadow.
-- quirk: the single pip on top is drilled as a little heart.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-dice")
local RED = { "#4a1430", "#7a1e3a", "#ae2c40", "#dc4140", "#f66a48", "#ffa070" }
local PIP = { "#6e3a48", "#a87a7a", "#d8bfa6", "#f2e2c2", "#fff4d6" }
local SPEC = "#fff4d6"
local tok = A.tok("die")
local ptok = A.tok("pip")

-- geometry (isometric-ish 2:1): top rhombus apex T, left L, right R, front-centre F; faces drop by DH
local T, Lp, Rp, F, DH = { 32, 8 }, { 10, 19 }, { 54, 19 }, { 32, 30 }, 25
c:groundShadow(33, 56, 19, 2)
local hex = c:poly{ { T[1], T[2] - 0.5 }, { Rp[1] + 0.9, Rp[2] }, { Rp[1] + 0.9, Rp[2] + DH }, { F[1] + 0.5, F[2] + DH + 0.9 },
  { F[1] - 0.5, F[2] + DH + 0.9 }, { Lp[1] - 0.9, Lp[2] + DH }, { Lp[1] - 0.9, Lp[2] } }
local die = hex:shrink(2):grow(2)
-- face classification + seam distances
local function lineY(a, b, x) return a[2] + (b[2] - a[2]) * (x - a[1]) / (b[1] - a[1]) end
local NT = { 0, -0.8, 0.6 }
local NL = { -0.72, 0.18, 0.67 }
local NR = { 0.72, 0.18, 0.67 }
local face, n = {}, {}
local function nrm(v) local l = sqrt(v[1]^2 + v[2]^2 + v[3]^2) return { v[1]/l, v[2]/l, v[3]/l } end
local R = 2.6
die:each(function(x, y)
  local k = K(x, y)
  local px, py = x + 0.5, y + 0.5
  local seamY = px < F[1] and lineY(Lp, F, px) or lineY(F, Rp, px)
  local f, d1, nb1, d2, nb2
  if py < seamY then
    f = NT d1 = (seamY - py) * 0.9 nb1 = (px < F[1]) and NL or NR
  elseif px < F[1] then
    f = NL d1 = (py - seamY) * 0.9 nb1 = NT d2 = F[1] - px nb2 = NR
  else
    f = NR d1 = (py - seamY) * 0.9 nb1 = NT d2 = px - F[1] nb2 = NL
  end
  face[k] = (f == NT) and 1 or (f == NL and 2 or 3)
  local v = { f[1], f[2], f[3] }
  local function bend(d, nb) if d and d < R then local w = (1 - d / R) * 0.5 for i = 1, 3 do v[i] = v[i] + (nb[i] - f[i]) * w end end end
  bend(d1, nb1) bend(d2, nb2)
  n[k] = nrm(v)
end)
-- outer silhouette roll-off
local pn, dd = X.pillow(die, 2.2)
for k, a in pairs(n) do local b = pn[k] n[k] = nrm({ a[1] + b[1] * 0.7, a[2] + b[2] * 0.7, a[3] }) end
local bias = {}
die:each(function(x, y) local k = K(x, y)
  if face[k] ~= 1 and y > 50 then bias[k] = -1 end -- AO toward the floor
end)
local idx = A.shade(c, die, n, RED, { amb = 0.12, wrap = 0.45, bias = bias, tok = tok, cuts = { 0.2, 0.38, 0.58, 0.88, 0.96 },
  tilt = { 32, 32, 30, 0.12 } })

-- pips: drilled holes. on face plane f with axes (u,v) mapped to screen
local function pipAt(cx, cy, ux, uy, vx, vy, r, shape, fshift)
  local m = HP.mask()
  for y = floor(cy - 6), floor(cy + 6) do for x = floor(cx - 7), floor(cx + 7) do
    local dx, dy = x + 0.5 - cx, y + 0.5 - cy
    local det = ux * vy - uy * vx
    local a = (dx * vy - dy * vx) / det
    local b = (ux * dy - uy * dx) / det
    local ok
    if shape == "heart" then
      local hx, hy = a / r * 1.25, -b / r * 1.25 + 0.25
      ok = (hx * hx + hy * hy - 1) ^ 3 - hx * hx * hy ^ 3 <= 0
    else ok = a * a + b * b <= (r + 0.3) ^ 2 end
    if ok then m:set(x, y) end
  end end
  local inner = m:copy():cut(m:shift(1, 1))  -- upper-left inner rim (in shadow)
  local lip = m:copy():cut(m:shift(-1, -1))  -- lower-right lit lip
  m:each(function(x, y)
    local i = 4 + (fshift or 0)
    if inner:has(x, y) then i = 2 + (fshift or 0) end
    if lip:has(x, y) and not inner:has(x, y) then i = min(5, 5 + (fshift or 0)) end
    c:put(x, y, PIP[max(1, i)], ptok)
  end)
  return m
end
-- top face axes: u along T->R direction, v along T->L
local tu = { (Rp[1] - T[1]) / 22, (Rp[2] - T[2]) / 22 }
local tv = { (Lp[1] - T[1]) / 22, (Lp[2] - T[2]) / 22 }
do -- heart pip, hand drawn (reads better than a skewed formula at this size)
  local hm = { ".rrr.rrr.", "rrlllrllr", "rlllllllr", "rllllllhr", ".rllllll.", "..rlllh..", "...rlh...", "....h...." }
  local hmask = HP.mask()
  for yy, row in ipairs(hm) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if ch ~= "." then local x, y = 27 + xx, 14 + yy hmask:set(x, y)
      c:put(x, y, ch == "r" and PIP[2] or (ch == "h" and PIP[5] or PIP[4]), ptok) end end end
  -- deeper shadow on the upper-left inside the hole
  for _, p in ipairs{ { 29, 17 }, { 29, 18 }, { 30, 16 }, { 34, 16 } } do c:put(p[1], p[2], PIP[3], ptok) end
end
-- left face: u along L->F (down-right), v down
local lu = { (F[1] - Lp[1]) / 22, (F[2] - Lp[2]) / 22 }
local dv = { 0, 1 }
local function onL(a, b) return Lp[1] + lu[1] * a, Lp[2] + lu[2] * a + b end
local function onR(a, b) return F[1] + (Rp[1] - F[1]) / 22 * a, F[2] + (Rp[2] - F[2]) / 22 * a + b end
do local x, y = onL(6.5, 6.5) pipAt(x, y, lu[1], lu[2], 0, 1, 4.0, nil, 0) end
do local x, y = onL(15.5, 18) pipAt(x, y, lu[1], lu[2], 0, 1, 4.0, nil, 0) end
local ru = { (Rp[1] - F[1]) / 22, (Rp[2] - F[2]) / 22 }
do local x, y = onR(5.5, 5.5) pipAt(x, y, ru[1], ru[2], 0, 1, 3.6, nil, -1) end
do local x, y = onR(11, 12.3) pipAt(x, y, ru[1], ru[2], 0, 1, 3.6, nil, -1) end
do local x, y = onR(16.5, 19) pipAt(x, y, ru[1], ru[2], 0, 1, 3.6, nil, -1) end

-- polished resin: specular streak along the lit front-left seam + bright top-left edge, one glint
for x = 13, 26 do local y = floor(lineY(Lp, F, x + 0.5) + 0.5)
  if die:has(x, y) and (x % 5 ~= 0) then c:put(x, y, RED[6], tok) end end
for _, p in ipairs{ { 16, 14 }, { 17, 14 }, { 18, 13 } } do if die:has(p[1], p[2]) then c:put(p[1], p[2], RED[6], tok) end end
c:put(19, 22, SPEC, tok) c:put(20, 22, SPEC, tok) c:put(20, 23, RED[6], tok)
-- bevel: bright rim along the lit top-left edge of the top face (broken into two runs)
for x = 12, 29 do if x ~= 21 and x ~= 22 then
  local y = 0 while not die:has(x, y) and y < 63 do y = y + 1 end
  c:put(x, y + 1, RED[5], tok) end end
-- cool reflected light on the right face lower edge
for y = 30, 46 do local x = 54 if die:has(x, y) and not die:has(x + 1, y) then c:put(x, y, "#9a4a6a", tok) end end
A.save(c, "ico-dice")
