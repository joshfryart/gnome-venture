-- ico-peanut (final, Opus single pass). One peanut pod lying on the diagonal: a round lower chamber, a pinched
-- waist and a slightly smaller upper chamber ending in the little hooked beak. Material: per-pixel lobe/sphere
-- light on a 6-tone tan ramp, netted shell (longitudinal ridges with a lit lip + irregular cross veins), deep
-- ambient pinch at the waist, cool bounce on the lower-right rim, one dry matte glint.
-- quirk: a flake of shell has popped off the upper chamber, so the red-skinned nut peeks out.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA8_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = A.new("ico-peanut")
local TAN = { "#45252a", "#6e3e2e", "#9c6138", "#c58a4a", "#e4b36c", "#f8dc9e" }
local BOUNCE, SPEC = "#8e6a80", "#fff1d4"
local SKIN = { "#5a1e26", "#8e2e30", "#bf4a3c", "#e07a5c" }

local AX, AY, BX, BY = 13, 51, 50, 14
local f, L, ux, uy, px, py = A.axis(AX, AY, BX, BY)
local lobes = { { t = 0.24, r = 10.6 }, { t = 0.745, r = 9.6 } }
local function hw(t)
  local w = 0
  for _, lb in ipairs(lobes) do local d = (t - lb.t) * L
    if abs(d) < lb.r then w = max(w, sqrt(lb.r^2 - d * d)) end end
  if t > 0.36 and t < 0.62 then w = max(w, 6.1 + 2.2 * ((t - 0.49) / 0.13)^2) end
  return w
end
local m = HP.mask()
local T, S = {}, {}
for y = 4, 60 do for x = 4, 60 do
  local t, s = f(x, y)
  if t >= -0.05 and t <= 1.05 and abs(s + 0.25) <= hw(t) then m:set(x, y) T[K(x, y)], S[K(x, y)] = t, s end
end end
-- beak: small hooked tip at the upper end, toward the lit side
local ET = lobes[2].t + lobes[2].r / L
for d = -2, 2.6, 0.25 do
  local w = 1.9 - (d + 2) * 0.45
  local cx, cy = AX + ux * (ET * L + d) - px * (1.0 + max(0, d) * 0.6), AY + uy * (ET * L + d) - py * (1.0 + max(0, d) * 0.6)
  for y = floor(cy - 3), floor(cy + 3) do for x = floor(cx - 3), floor(cx + 3) do
    if w > 0.3 and (x - cx)^2 + (y - cy)^2 <= w * w and not m:has(x, y) then m:set(x, y) T[K(x, y)], S[K(x, y)] = 1.0, -1.2 end
  end end
end
-- normals: nearest-chamber sphere blended with a pillow for a soft silhouette
local np = X.pillow(m, 5)
local n = {}
m:each(function(x, y) local k = K(x, y)
  local t = T[k]
  local lb = (t < 0.49) and lobes[1] or lobes[2]
  local cx, cy = AX + ux * lb.t * L, AY + uy * lb.t * L
  local nx, ny = (x - cx) / (lb.r + 1.5), (y - cy) / (lb.r + 1.5)
  local q = max(0.04, 1 - nx * nx - ny * ny)
  local a = { A.norm(nx, ny, sqrt(q)) }
  local b = np[k]
  n[k] = { A.norm(a[1] * 0.6 + b[1] * 0.4, a[2] * 0.6 + b[2] * 0.4, a[3] * 0.6 + b[3] * 0.4) }
end)
local v = X.light(n, { amb = 0.03, wrap = 0.12 })
local bias = {}
m:each(function(x, y) local k = K(x, y) local d = abs(T[k] - 0.49) * L
  if d < 1.2 then bias[k] = -2 elseif d < 3.2 then bias[k] = -1 end end)
local tok = { r = { name = "shell" } }
local idx = X.tone(c, m, v, TAN, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = bias, tok = tok })
local function step(x, y, d) A.step(c, idx, TAN, x, y, d, tok) end
-- netted shell: longitudinal ridges (groove + lit lip on the upper-left side) and wobbly cross veins
local inner = m:shrink(1)
inner:each(function(x, y) local k = K(x, y)
  local t, s = T[k], S[k]
  local w = hw(t) local d = abs(t - 0.49) * L
  if d < 1.5 or t > 0.96 then return end
  local sn = s / max(w, 1)
  local wob = (X.hash(floor(t * L / 4), floor(s / 3.6 + 9), 3) - 0.5) * 1.6
  local rs = (s + 20 + wob * 0.5) % 4.6
  if abs(sn) < 0.85 and rs < 0.9 then step(x, y, -1)
  elseif abs(sn) < 0.8 and rs >= 0.9 and rs < 1.8 and idx[k] >= 3 and idx[k] <= 5 then step(x, y, 1) end
  local cs = (t * L + s * 0.35 + wob + 40) % 5.2
  if abs(sn) < 0.75 and cs < 0.85 and X.hash(x, y, 11) > 0.3 then step(x, y, -1) end
end)
-- cool bounce on the lower-right rim
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.6 and n[k][1] > 0.1 and n[k][2] > 0.1 then c:put(x, y, BOUNCE, tok) end end)
-- dry glint on the lower chamber
c:put(12, 36, SPEC, tok) c:put(13, 36, SPEC, tok) c:put(13, 37, TAN[6], tok)

-- quirk: broken flake on the upper chamber showing the red-skinned kernel
local hole = HP.mask()
local hx, hy = 41, 25
for _, p in ipairs{ {0,0},{1,0},{2,0},{-1,1},{0,1},{1,1},{2,1},{3,1},{-1,2},{0,2},{1,2},{2,2},{3,2},{0,3},{1,3},{2,3} } do
  hole:set(hx + p[1], hy + p[2]) end
local lip = hole:grow(1):cut(hole)
lip:each(function(x, y) if m:has(x, y) then
  -- broken shell edge: pale fibrous cut on the far side, dark shadow lip on the near (upper-left) side
  if x + y < hx + hy + 2 then c:put(x, y, TAN[1], tok) else c:put(x, y, TAN[6], tok) end end end)
hole:each(function(x, y)
  local r = (x - hx - 0.5) + (y - hy - 0.5)
  local i = r < 0.5 and 1 or (r < 2.5 and 3 or 2)
  c:put(x, y, SKIN[i], tok) end)
c:put(hx + 1, hy + 1, SKIN[4], tok) c:put(hx, hy, SKIN[1], tok)
-- kernel skin veins
c:put(hx + 2, hy + 2, SKIN[1], tok)
A.save(c, "ico-peanut")
