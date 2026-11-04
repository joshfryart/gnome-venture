-- cricket-chirp (final, Opus single pass). The chirp itself: a pair of amber cricket forewings raised in a V from a
-- small dark saddle (pronotum), each with longitudinal veins, curved harp cross-veins, a pale glassy "mirror" cell
-- (bright rim, pale core) and the ridged stridulatory file near the base; two gold sound arcs rise in the V.
-- quirk: a tiny plum eighth-note has escaped above the arcs.
local NAME = "cricket-chirp"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB22_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, cos, pi, atan = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi, math.atan
local c = A.new(NAME)
local WG = { "#3b2414", "#6a4320", "#9a6a2e", "#c8963e", "#e7bf62", "#f8e09a" }
local MIR = { "#e9d7a0", "#fbf0c8" }
local PN = { "#24161a", "#3e2620", "#5e3a28", "#86553a", "#b07a50", "#d8a670" }
local GD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local PL = { "#35295f", "#5a459e", "#8a6fd0", "#c9b2f0" }

local hx, hy = 32, 47
local function wing(bx, by, cx, cy, tx, ty, nm)
  local wfn = function(t)
    if t > 0.985 then return -1 end
    return max(0.6, 6.4 * sin(pi * min(1, t * 0.82 + 0.1)) ^ 0.55 * (1 - 0.25 * t))
  end
  local m, n, T, S, len = A.blade(bx, by, cx, cy, tx, ty, wfn, { fold = 0.22 })
  return { m = m, n = n, T = T, S = S, len = len, tok = { r = { name = nm } } }
end
local L = wing(30, 45, 20, 33, 13, 13, "wingL")
local R = wing(34, 45, 44, 33, 51, 13, "wingR")
-- saddle (pronotum) at the base, drawn last on top
local sad = A.rell(32, 49.5, 1, 0, 5.2, 3.2)
sad:add(A.rell(32, 47, 1, 0, 3.2, 2.2))
L.m:cut(sad) R.m:cut(sad) R.m:cut(L.m)

for _, w in ipairs{ L, R } do
  local bias = X.ao({}, w.m, sad, 1, -1)
  local idx = A.shade(c, w.m, w.n, WG, { amb = 0.16, wrap = 0.35, bias = bias, tok = w.tok })
  w.m:each(function(x, y) local k = K(x, y)
    local t, s = w.T[k], w.S[k]
    local i = idx[k]
    local function put(d) i = max(1, min(6, idx[k] + d)) c:put(x, y, WG[i], w.tok) end
    -- mirror cell: pale glassy oval with a dark rim vein
    local mu, mv = (t - 0.6) / 0.13, (s - 0.12) / 0.42
    local q = mu * mu + mv * mv
    if q < 0.55 then c:put(x, y, (mu + mv < -0.2) and MIR[2] or MIR[1], w.tok) return end
    if q < 1.0 then put(-2) return end
    -- longitudinal veins
    if abs(s - 0.5) < 0.09 or abs(s + 0.45) < 0.09 or (abs(s) < 0.07 and t < 0.45) then put(-2) return end
    -- harp cross-veins (curved), finer toward the tip
    if t > 0.22 and t < 0.92 and ((t * w.len + s * s * 7) % 4.6) < 0.8 then put(-1) return end
    -- stridulatory file: ridged band near the base
    if t > 0.12 and t < 0.19 and abs(s) < 0.75 then put(((x + y) % 2 == 0) and -3 or 0) return end
  end)
end
-- glints on each wing's lit edge
c:put(18, 22, A.CREAM, L.tok) c:put(19, 21, WG[6], L.tok)
c:put(42, 27, WG[6], R.tok)

-- sound arcs in the V, centred on the hinge
local atok = { r = { name = "arcs" } }
for _, a in ipairs{ { 20.5, 0.42 }, { 26.5, 0.5 } } do
  local r, span = a[1], a[2]
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - hx, y - hy
    local d = sqrt(dx*dx + dy*dy)
    local ang = atan(dx, -dy)
    if d >= r and d < r + 1.9 and abs(ang) < span and not L.m:has(x, y) and not R.m:has(x, y) then
      local e = abs(ang) / span
      c:put(x, y, (d < r + 0.95) and (e > 0.75 and GD[2] or GD[4]) or (e > 0.75 and GD[1] or GD[3]), atok)
    end
  end end
end

-- pronotum saddle with a pale rim and a glossy hi
local ptok = { r = { name = "saddle" } }
local pidx = A.shade(c, sad, A.body(sad, 30.5, 47.5, 4.5, 2, 0.6), PN, { tok = ptok, amb = 0.1 })
for x = 28, 36 do if sad:has(x, 50) then c:put(x, 50, PN[2], ptok) end end
c:put(29, 47, PN[6], ptok) c:put(30, 47, PN[5], ptok)

-- quirk: a stray eighth note above the arcs
local ntok = { r = { name = "note" } }
local nh = A.rell(30.6, 16.2, 1, -0.35, 1.8, 1.25)
A.shade(c, nh, A.body(nh, 30, 15.6, 1.8, 1, 0.9), PL, { tok = ntok, cuts = { 0.3, 0.55, 0.8 } })
for y = 10, 15 do c:put(32, y, y < 12 and PL[3] or PL[2], ntok) end
c:put(33, 11, PL[2], ntok) c:put(34, 12, PL[2], ntok) c:put(34, 13, PL[1], ntok)
c:put(30, 15, PL[4], ntok)

A.save(c, NAME)
