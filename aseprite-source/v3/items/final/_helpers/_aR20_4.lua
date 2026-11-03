-- _aR20_4.lua: private helpers for black-pepper-seed, blackcurrant, blackcurrant-cordial, blackcurrant-jam (aR20_4).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local R = setmetatable({}, { __index = G })

-- glossy berry: sphere normals, 6-tone ramp, waxy bloom specks on the lit half, cool rim, one spec.
-- o.bias (AO), o.tok, o.bloom hex, o.rim hex, o.spec hex, o.seed (hash seed). returns mask, idx
function R.berry(c, cx, cy, r, ramp, o)
  o = o or {}
  local m = c:ellipse(cx, cy, r, r)
  if o.clipm then m:cut(o.clipm) end
  local n = X.sphere(cx - 0.3, cy - 0.3, r, m)
  local v = X.light(n, { amb = 0.06, wrap = 0.22 })
  local tok = o.tok or { r = { name = "berry" .. cx .. "_" .. cy } }
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.16, 0.34, 0.52, 0.7, 0.86 }, bias = o.bias, tok = tok })
  local rim = X.rim(n)
  m:each(function(x, y) local k = K(x, y)
    local i = idx[k]
    if o.rim and rim[k] > 0.74 and i <= 2 and not (o.bias and o.bias[k]) then c:put(x, y, o.rim, tok) end
    if o.bloom and i >= 3 and i <= 4 and X.hash(x, y, o.seed or 3) > 0.72 then c:put(x, y, o.bloom, tok) end
  end)
  -- spec: brightest pixel + one to the right
  local bx, by = G.specAt(m, n, 30)
  if bx and not o.nospec then
    c:put(bx, by, o.spec or "#fff4d6", tok)
    if r >= 3.5 and m:has(bx + 1, by) then c:put(bx + 1, by, ramp[#ramp], tok) end
  end
  return m, idx, n, tok
end

-- straight-ish line painter (1px), returns list of points
function R.line(c, x0, y0, x1, y1, hex, tok)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  local pts = {}
  for i = 0, n do
    local t = n == 0 and 0 or i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    if type(hex) == "function" then local h = hex(i, x, y) if h then c:put(x, y, h, tok) end else c:put(x, y, hex, tok) end
    pts[#pts + 1] = { x, y }
  end
  return pts
end

-- vertical cylinder lit by x only: returns normals for mask m between x0..x1
function R.vn(m, x0, x1)
  local n = {}
  m:each(function(x, y)
    local t = max(-.96, min(.96, ((x + .5 - x0) / (x1 + 1 - x0)) * 2 - 1))
    n[K(x, y)] = { t, -0.12, sqrt(1 - t * t) }
  end)
  return n
end
return R
