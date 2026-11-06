-- _aD11_3 helper (Opus-style single pass for ph/rain_barrel-painted, rainbow-fish, raisins, rambutan-seed).
-- Read-only use of _dD11.lua (barrel, pipe, ramp) and batch2/_b2g1.lua (tube, blade, oval, cast, recentre).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dD11.lua")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local A = { D = D, G = G, HP = G.HP, X = G.X, K = G.K }
local floor, max, min, abs, sqrt, sin, cos, pi, atan = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi, math.atan
A.ramp = D.ramp
A.hash = G.X.hash
-- leaf-like blade along a quad bezier with midrib + lateral veins. ramp = 6 hex table.
function A.leaflet(c, ax, ay, cx, cy, bx, by, w, ramp, o)
  o = o or {}
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.96 + 0.04)
    return max(0.5, w * (o.prof and o.prof(t) or sin(pi * u ^ (o.pw or 0.9)) ^ 0.7))
  end, { fold = o.fold or 0.4 })
  if o.cut then o.cut(m, T, S) end
  local tok = { r = { name = o.name or "leaf" } }
  G.toneN(c, m, n, ramp, { tok = tok, bias = o.bias, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.16, wrap = 0.3 })
  m:each(function(x, y)
    local k = G.K(x, y)
    local s, t = S[k], T[k]
    if o.bias and o.bias[k] and o.bias[k] < 0 then return end
    if abs(s) < 0.17 and t > 0.03 and t < 0.93 and not o.norib then c:put(x, y, s <= 0 and (o.rib or ramp[6]) or ramp[2], tok) end
    for _, vt in ipairs(o.veins or {}) do
      local d = t * len - (vt + abs(s) * (o.slant or 2.4))
      if d > -0.5 and d < 0.5 and abs(s) > 0.2 and abs(s) < 0.8 then c:put(x, y, s < 0 and ramp[5] or ramp[2], tok) end
    end
  end)
  return m, n, T, S, len
end
function A.leaflet_dir(c, ax, ay, ang, len, bend, w, ramp, o)
  local dx, dy = sin(ang), -cos(ang)
  local px, py = -dy, dx
  return A.leaflet(c, ax, ay, ax + dx * len * .5 + px * bend, ay + dy * len * .5 + py * bend, ax + dx * len, ay + dy * len, w, ramp, o)
end
return A
