-- ico-banana (final, Opus). A single slim banana lying as a smile, blossom end lower-left, top end upper-right.
-- Faceted per-pixel light (the peel's long ridges snapped to flat faces with a lit lip on each ridge), warm
-- 6-tone yellow, cooler green-yellow toward the top, a dark woody blossom nub, sugar freckles on the shade side,
-- waxy specular streak along the lit facet, cool bounce on the belly edge.
-- quirk: the top is half peeled, two peel strips curling back from cream flesh that already has a bite out of it.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA0_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.pi
local c = A.new("ico-banana")
local YE = { "#7e4a2a", "#b9762a", "#df9f2a", "#f5c63a", "#ffe066", "#fff3a6" }
local GY = { "#4a5a2a", "#7d8a2a", "#aab030", "#d4cc3a", "#efe46a", "#f8f4a6" }
local IN = { "#c99a4a", "#e6c470", "#f6e09a", "#fff2c4" }
local FL = { "#b8925a", "#dcc08a", "#f2e2b4", "#fff4d6" }
local ytok, ftok, ptok = { r = { name = "peel" } }, { r = { name = "flesh" } }, { r = { name = "strip" } }
local BOUNCE = "#c98a6a"

local P = { { 9, 41 }, { 15, 56 }, { 41, 57 }, { 50, 25 } }
local function hw(t)
  if t < 0.05 then return 1.6 + t / 0.05 * 1.6 end
  return 1.2 + 3.7 * sin(pi * min(1, (t - 0.0) * 0.92 + 0.08)) ^ 0.55
end
local m, n, T, S, samp = A.tube(P, hw)
local E = samp[#samp]
local tx, ty = E.tx, E.ty                 -- tangent at the top end (pointing out)
local px, py = E.px, E.py                 -- perpendicular, +lower-right

-- peel strips (behind the flesh, in front of nothing): right strip curls out and down, left one flops back
local function strip(pts, w0, w1)
  local sm, sn, ST, SS = A.tube(pts, function(t) return w0 + (w1 - w0) * t end)
  -- inside of the peel faces us on the -s half, outer yellow skin on the +s rim
  local v = X.light(sn, { amb = 0.15, wrap = 0.3 })
  sm:each(function(x, y) local k = K(x, y)
    local ss = SS[k]
    local i = max(1, min(4, floor(v[k] * 4) + 1))
    if ss > 0.1 then c:put(x, y, YE[max(2, min(6, i + 1))], ptok) else c:put(x, y, IN[i], ptok) end
  end)
  return sm
end
local ex, ey = E.x, E.y
local rS = strip({ { ex + px * 2.6, ey + py * 2.6 }, { ex + px * 6 + tx * 2, ey + py * 6 + ty * 2 },
  { ex + px * 9.5, ey + py * 8 }, { ex + px * 9 - tx * 3, ey + py * 9 - ty * 6 } }, 2.8, 1.2)
local lS = strip({ { ex - px * 2.6, ey - py * 2.6 }, { ex - px * 5.5 + tx * 2.5, ey - py * 5.5 + ty * 2.5 },
  { ex - px * 9, ey - py * 7 + 1 }, { ex - px * 10.5 - tx * 1, ey - py * 10 + 5 } }, 2.6, 1.2)

-- body: faceted light. sn snapped to 4 faces; ridge pixels get a lit lip
local FACES = { -0.72, -0.25, 0.25, 0.72 }
local nf = {}
local ridge, groove = HP.mask(), HP.mask()
m:each(function(x, y) local k = K(x, y)
  local s = S[k]
  local q = min(4, max(1, floor((s + 1) / 2 * 4) + 1))
  local f = FACES[q]
  local nz = sqrt(1 - f * f)
  nf[k] = { px * f, py * f, nz }
  local edgeQ = (s + 1) / 2 * 4
  local rq = floor(edgeQ + 0.5) local dq = edgeQ - rq
  if rq >= 1 and rq <= 3 then if dq > -0.28 and dq <= 0 then ridge:set(x, y) elseif dq > 0 and dq < 0.2 then groove:set(x, y) end end
end)
-- blend facet normals with the round tube normals so the faces are soft-cornered
for k, a in pairs(nf) do local b = n[k] nf[k] = { A.norm(a[1] * 0.6 + b[1] * 0.4, a[2] * 0.6 + b[2] * 0.4, a[3] * 0.6 + b[3] * 0.4) } end
local v = X.light(nf, { amb = 0.06, wrap = 0.2 })
local bias = {}
X.ao(bias, m, rS, 1, -1) X.ao(bias, m, lS, 1, -1)
local idx = {}
m:each(function(x, y) local k = K(x, y)
  local val = v[k]
  local i = 1
  for j, cut in ipairs(A.CUTS6) do if val >= cut then i = j + 1 end end
  i = max(1, min(6, i + (bias[k] or 0)))
  if ridge:has(x, y) and i <= 5 then i = i + 1 elseif groove:has(x, y) then i = max(1, i - 1) end
  idx[k] = i
  local ramp = T[k] > 0.9 and GY or YE
  c:put(x, y, ramp[i], ytok)
end)
-- blossom end: dark woody nub
m:each(function(x, y) local k = K(x, y)
  if T[k] < 0.045 then c:put(x, y, T[k] < 0.025 and "#3e2626" or "#5e3a2e", ytok) end end)
-- sugar freckles on the shade half
for _, q in ipairs{ { 0.3, 0.5 }, { 0.42, 0.75 }, { 0.55, 0.45 }, { 0.62, 0.8 }, { 0.72, 0.55 }, { 0.36, 0.2 } } do
  local s = samp[floor(q[1] * 160) + 1]
  local x, y = floor(s.x + s.px * s.w * q[2] + .5), floor(s.y + s.py * s.w * q[2] + .5)
  if m:has(x, y) then c:put(x, y, YE[2], ytok) if q[2] > 0.6 and m:has(x + 1, y) then c:put(x + 1, y, YE[1], ytok) end end
end
-- cool bounce along the belly (lower-right) edge
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y)
  if S[k] > 0.8 and T[k] > 0.2 and T[k] < 0.75 and rim[k] > 0.6 then c:put(x, y, BOUNCE, ytok) end end)
-- waxy specular streak on the lit facet
for t = 0.4, 0.66, 0.035 do
  local s = samp[floor(t * 160) + 1]
  local x, y = floor(s.x + s.px * s.w * -0.55 + .5), floor(s.y + s.py * s.w * -0.55 + .5)
  if m:has(x, y) then c:put(x, y, YE[6], ytok) end
end
do local s = samp[floor(0.5 * 160) + 1]
  c:put(floor(s.x + s.px * s.w * -0.55 + .5), floor(s.y + s.py * s.w * -0.55 + .5), A.CREAM, ytok) end

-- peeled rim: dark ring where the peel was torn back
local flesh, fn, FT, FS = A.tube({ { ex - tx * 1, ey - ty * 1 }, { ex + tx * 3, ey + ty * 3 }, { ex + tx * 6, ey + ty * 6 }, { ex + tx * 8.5, ey + ty * 8.5 } },
  function(t) return 3.3 - t * 0.5 end)
-- rounded tip cap
local cap = c:ellipse(ex + tx * 8.5, ey + ty * 8.5, 2.7, 2.7)
local cn = X.sphere(ex + tx * 8.5, ey + ty * 8.5, 3, cap)
cap:each(function(x, y) local k = K(x, y) if not flesh:has(x, y) then flesh:set(x, y) fn[k] = cn[k] FT[k] = 1 FS[k] = 0.5 end end)
-- bite: round notch off the upper-right of the flesh tip
local bx, by = ex + tx * 11.2 + px * 1.6, ey + ty * 11.2 + py * 1.6
local bite = c:ellipse(bx, by, 3.1, 3.1)
flesh:cut(bite)
for _ = 1, 2 do   -- prune 1px slivers left by the bite
  local cut = HP.mask()
  flesh:each(function(x, y) local nb = 0
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do if flesh:has(x + d[1], y + d[2]) or m:has(x + d[1], y + d[2]) then nb = nb + 1 end end
    if nb <= 1 then cut:set(x, y) end end)
  flesh:cut(cut)
end
local fidx = A.shade(c, flesh, fn, FL, { amb = 0.2, wrap = 0.35, tok = ftok, cuts = { 0.3, 0.55, 0.8 } })
-- bite edge: tooth marks one tone darker
A.touch(flesh, bite):each(function(x, y) c:put(x, y, FL[1], ftok) end)
-- fibre lines down the flesh
flesh:each(function(x, y) local k = K(x, y) if abs(FS[k]) < 0.15 and FT[k] > 0.15 and FT[k] < 0.8 then c:put(x, y, FL[2], ftok) end end)
-- torn peel rim: body pixels touching the flesh go deep
A.touch(m, flesh):each(function(x, y) if not flesh:has(x, y) then c:put(x, y, YE[3], ytok) end end)
A.save(c, "ico-banana")
