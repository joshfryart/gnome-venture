-- _aB1r1_0.lua: private helpers for cattail-fritters, cattail-root, cattleya-seed, cauliflower (ph).
-- Read-only use of batch2/_b2g1.lua (tube, bez, rell, recentre) -> batch1/_g1.lua (blade, oval, cast, toneN, save).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local A = setmetatable({}, { __index = G })
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
function A.tok(n) return { r = { name = n } } end
-- paint per-pixel lit ellipsoid; returns mask, normals, idx
function A.ovalLit(c, cx, cy, rx, ry, ang, flat, ramp, o)
  o = o or {}
  local m, n = G.oval(cx, cy, rx, ry, ang, flat)
  if o.cut then m:cut(o.cut) end
  local idx = X.tone(c, m, X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 }), ramp,
    { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return m, n, idx
end
-- shift an index map tone by d on pixels of mask
function A.retone(c, m, idx, ramp, f, tok)
  m:each(function(x, y) local k = K(x, y) local d = f(x, y, k)
    if d and d ~= 0 and idx[k] then idx[k] = max(1, min(#ramp, idx[k] + d)) c:put(x, y, ramp[idx[k]], tok) end end)
end
A.hash = X.hash
-- paint a G.blade leaf: lit tones, midrib (lit/shade split), swept veins every per px, cool reflected edge
function A.leaf(c, m, n, T, S, len, ramp, o)
  o = o or {}
  local tok = o.tok or A.tok("leaf")
  local bias = o.bias or {}
  local idx = G.toneN(c, m, n, ramp, { bias = bias, tok = tok, cuts = o.cuts or { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = o.amb or 0.16, wrap = o.wrap or 0.3 })
  local per = o.per or 5
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if (bias[k] or 0) < 0 then return end
    if abs(s) < (o.rib or 0.14) and t > 0.02 and t < 0.9 then c:put(x, y, s <= 0 and (o.ribHi or ramp[6]) or (o.ribLo or ramp[3]), tok) return end
    local ph = (t * len - abs(s) * (o.sweep or 3.5)) / per + (s > 0 and 0.5 or 0)
    local f = abs((ph - floor(ph)) - 0.5) * 2
    if f > 0.86 and abs(s) > 0.18 and abs(s) < 0.78 and t > 0.06 and t < 0.86 then
      c:put(x, y, s < 0 and ramp[min(6, (idx[k] or 3) + 1)] or ramp[max(1, (idx[k] or 3) - 1)], tok) end
  end)
  if o.cool then m:edge():each(function(x, y) local k = K(x, y)
    if (bias[k] or 0) >= 0 and S[k] > 0.6 and T[k] > 0.1 and T[k] < 0.85 then c:put(x, y, o.cool, tok) end end) end
  return idx, tok
end
return A
