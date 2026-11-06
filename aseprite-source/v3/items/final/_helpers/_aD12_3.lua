-- _aD12_3.lua: artist helper (agent D12_3). Wraps batch2/_b2g1.lua (read-only) + small line / mask utilities.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local A = { G = G, HP = HP, X = X, K = K }
A.new = function(name) return G.new2(name) end
A.save = function(c, name) G.save2(c, name) end
-- 1px line (bresenham); only where clip mask has (if given). hex string or f(i,n) -> hex
function A.line(c, x0, y0, x1, y1, hex, clip, tok)
  x0, y0, x1, y1 = floor(x0 + .5), floor(y0 + .5), floor(x1 + .5), floor(y1 + .5)
  local dx, dy = abs(x1 - x0), abs(y1 - y0)
  local n = max(dx, dy)
  for i = 0, n do
    local t = n == 0 and 0 or i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    if not clip or clip:has(x, y) then c:put(x, y, type(hex) == "function" and hex(i, n) or hex, tok) end
  end
end
-- polygon mask from rotated template points
function A.rotpts(pts, cx, cy, ang, s)
  local ca, sa = cos(ang), sin(ang)
  local r = {}
  for _, p in ipairs(pts) do r[#r + 1] = { cx + (p[1] * ca - p[2] * sa) * (s or 1), cy + (p[1] * sa + p[2] * ca) * (s or 1) } end
  return r
end
-- lit pillow part
function A.lit(c, m, ramp, R, o)
  o = o or {}
  local n = X.pillow(m, R or 2.5)
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.26, 0.44, 0.6, 0.75, 0.88 }, bias = o.bias, tok = o.tok }), n, v
end
-- vertical-axis cylinder shading between x0..x1
function A.vcyl(c, m, ramp, x0, x1, o)
  o = o or {}
  local n = {}
  m:each(function(x, y)
    local t = max(-.97, min(.97, ((x - x0) / (x1 - x0)) * 2 - 1))
    n[K(x, y)] = { t, 0, sqrt(1 - t * t) }
  end)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.3 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.26, 0.44, 0.6, 0.75, 0.88 }, bias = o.bias, tok = o.tok })
  return idx, n, v
end
function A.maskFrom(f, x0, y0, x1, y1)
  local m = HP.mask()
  for y = y0, y1 do for x = x0, x1 do if f(x, y) then m:set(x, y) end end end
  return m
end
return A
