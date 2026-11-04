-- _aD14_5.lua: private helper for sea-buckthorn-seed / sea-daffodil-seed / sea-glass / sea-grape-sorbet (artist aD14_5).
-- Wraps batch2/_b2g1.lua (read-only). Output dir = param out (else ../ph/).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
G.out = app.params.out or (DIR .. "/../ph/")
G.hash = X.hash

-- quadratic bezier point
function G.qb(ax, ay, cx, cy, bx, by, t)
  local u = 1 - t
  return u*u*ax + 2*u*t*cx + t*t*bx, u*u*ay + 2*u*t*cy + t*t*by
end
-- paint a 6-tone seed (oval mask+normals from G.oval) with optional groove along its long axis and pale tip
-- s = {cx, cy, rx, ry, ang}; o: ramp, groove(0/1), tip hex, spec hex, bias table, tok, cuts
function G.paintSeed(c, s, vis, n, o)
  local ca, sa = math.cos(s[5]), math.sin(s[5])
  local tok = o.tok or { r = { name = "seed" } }
  G.toneN(c, vis, n, o.ramp, { bias = o.bias, tok = tok, cuts = o.cuts or { 0.12, 0.26, 0.42, 0.6, 0.8 }, amb = 0.1, wrap = 0.3 })
  local flip = ((-sa) + ca) > 0 and 1 or -1
  vis:each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), flip * (-dx * sa + dy * ca) / (s[4] + .45)
    if o.groove and abs(v) < 0.2 and abs(u) < 0.6 then c:put(x, y, o.ramp[2], tok) end
    if o.tip and u > 0.62 and abs(v) < 0.55 then c:put(x, y, o.tip, tok) end
  end)
  return tok
end
return G
