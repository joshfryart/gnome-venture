-- _aB34_2.lua: private helpers for ginger-beer, ginger-seed, ginseng, glass-thread (Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end

-- body of revolution about the vertical x = cx; rf(y) = half width (nil/neg = empty).
-- returns mask, normals, S (signed -1..1 across, <0 lit side)
function G.lathe(cx, y0, y1, rf)
  local m, n, S = HP.mask(), {}, {}
  for y = y0, y1 do
    local r = rf(y)
    if r and r > 0 then
      local ra, rb = rf(y - 1) or r, rf(y + 1) or r
      local slope = ((rb or r) - (ra or r)) / 2
      for x = floor(cx - r - 1), floor(cx + r + 1) do
        local s = (x + 0.5 - cx) / (r + 0.25)
        if abs(s) <= 1 then
          m:set(x, y)
          local sn = max(-0.97, min(0.97, s))
          local nz = sqrt(1 - sn * sn)
          n[K(x, y)] = { norm(sn, -slope * nz * 1.2, nz) }
          S[K(x, y)] = sn
        end
      end
    end
  end
  return m, n, S
end

-- distance from point to segment
function G.segd(x, y, ax, ay, bx, by)
  local vx, vy = bx - ax, by - ay
  local t = max(0, min(1, ((x - ax) * vx + (y - ay) * vy) / (vx * vx + vy * vy)))
  local dx, dy = x - ax - vx * t, y - ay - vy * t
  return sqrt(dx * dx + dy * dy), t
end

-- lanceolate leaf along quad bezier with midrib + swept veins + cool edge. returns mask
function G.lance(c, ax, ay, cx, cy, bx, by, wmax, ramp, tok, o)
  o = o or {}
  local pi, sin = math.pi, math.sin
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.97 then return -1 end
    return max(0.35, wmax * sin(pi * min(1, t * 0.92 + 0.06)) ^ (o.pow or 0.8))
  end, { fold = o.fold or 0.35 })
  if o.cut then m:cut(o.cut) end
  local idx = G.toneN(c, m, n, ramp, { tok = tok, cuts = o.cuts or { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.15, wrap = 0.3, bias = o.bias })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.16 and t > 0.05 and t < 0.88 then c:put(x, y, s <= 0 and (o.rib or ramp[6]) or ramp[3], tok) return end
    if o.veins and len then
      local ph = (t * len - abs(s) * 3.0) / (o.veins) + (s > 0 and 0.5 or 0)
      local f = abs((ph - floor(ph)) - 0.5) * 2
      if f > 0.86 and abs(s) > 0.2 and abs(s) < 0.72 and t > 0.08 and t < 0.85 then c:put(x, y, s < 0 and ramp[5] or ramp[2], tok) end
    end
  end)
  if o.cool then m:edge():each(function(x, y) local k = K(x, y)
    if S[k] > 0.6 and T[k] > 0.1 and T[k] < 0.9 and not (o.bias and o.bias[k]) then c:put(x, y, o.cool, tok) end end) end
  return m, n, T, S, idx
end

-- sphere tone helper
function G.ball(c, cx, cy, r, ramp, tok, o)
  o = o or {}
  local m = HP.mask()
  for y = floor(cy - r - 1), floor(cy + r + 1) do for x = floor(cx - r - 1), floor(cx + r + 1) do
    if (x + 0.5 - cx) ^ 2 + (y + 0.5 - cy) ^ 2 <= (r + 0.1) ^ 2 then m:set(x, y) end end end
  if o.cut then m:cut(o.cut) end
  local n = X.sphere(cx - 0.5, cy - 0.5, r, m)
  G.toneN(c, m, n, ramp, { tok = tok, cuts = o.cuts or { 0.18, 0.36, 0.55, 0.72, 0.88 }, amb = 0.1, wrap = 0.25, bias = o.bias })
  return m, n
end
return G
