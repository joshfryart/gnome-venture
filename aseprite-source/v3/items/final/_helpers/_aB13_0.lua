-- _aB13_0.lua: private helpers for the broken-w* tool quartet (aB13_0, Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua). Output dir = app.params.out.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
A.HP, A.X, A.K, A.G = HP, X, K, G
local floor, max, min, abs, sqrt, sin, cos = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos

function A.new(name) A.name = name return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- lit tube along a cubic bezier. o: keep(t,s,x,y), bias(t,s,x,y)->steps, amb, wrap, cuts, concave
function A.tube(c, p, wfn, ramp, o)
  o = o or {}
  local m, n, T, S, samp = G.tube(p, wfn)
  if o.keep then
    local rm = HP.mask()
    m:each(function(x, y) local k = K(x, y) if not o.keep(T[k], S[k], x, y) then rm:set(x, y) end end)
    m:cut(rm)
  end
  local len = 0
  for i = 2, #samp do len = len + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
  local bias = {}
  if o.bias then m:each(function(x, y) local k = K(x, y) bias[k] = o.bias(T[k], S[k], x, y) end) end
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local tok = { r = { name = o.name or "tube" } }
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.22, 0.4, 0.56, 0.72, 0.88 }, bias = bias, tok = tok })
  return { m = m, n = n, T = T, S = S, samp = samp, idx = idx, tok = tok, len = len, ramp = ramp, wfn = wfn }
end

-- paint over pixels of a tube R: f(t, s, x, y, i) -> tone index or hex or nil
function A.over(c, R, f)
  R.m:each(function(x, y) local k = K(x, y)
    local r = f(R.T[k], R.S[k], x, y, R.idx[k] or 3)
    if type(r) == "number" then c:put(x, y, R.ramp[max(1, min(#R.ramp, r))], R.tok)
    elseif type(r) == "string" then c:put(x, y, r, R.tok) end
  end)
end

-- grain lines along a tube: lines = {{s, t0, t1, wave}}; darker by one step (two on the lit side for contrast)
function A.grain(c, R, lines)
  A.over(c, R, function(t, s, x, y, i)
    local w = R.wfn(t)
    for _, L in ipairs(lines) do
      if t >= L[2] and t <= L[3] then
        local sv = L[1] + (L[4] or 0) * sin(t * R.len * 0.55 + L[1] * 7)
        if abs(s - sv) * (w + 0.5) < 0.5 then return i - 1 end
      end
    end
  end)
end

-- jagged break profile (px along the axis) for a given s
local JAG = { 0.4, 2.2, -0.4, 1.4, -1.0, 2.6, 0.2 }
function A.jag(s, phase) local i = floor((s + 1) * 3.2 + (phase or 0)) % #JAG + 1 return JAG[i] end

-- small lit shard (rotated ellipse)
function A.shard(c, cx, cy, ang, ra, rb, ramp)
  local m = G.rell(cx, cy, cos(ang), sin(ang), ra, rb)
  local n = X.pillow(m, 1.2)
  G.toneN(c, m, n, ramp, { cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
  return m
end
-- polygon part lit with pillow normals
function A.slab(c, m, ramp, R, o)
  o = o or {}
  local n = X.pillow(m, R or 2, o.hs)
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local tok = { r = { name = o.name or "slab" } }
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.22, 0.4, 0.56, 0.72, 0.88 }, bias = o.bias, tok = tok })
  return idx, n, tok
end
-- 1px polyline in a colour (hard pixels)
function A.ln(c, pts, hex) c:line(pts, 1):each(function(x, y) c:put(x, y, hex) end) end
function A.map(c, x0, y0, rows, pal)
  for j, row in ipairs(rows) do for i = 1, #row do local ch = row:sub(i, i)
    if pal[ch] then c:put(x0 + i - 1, y0 + j - 1, pal[ch]) end end end
end
function A.fin(c) G.recentre(c) G.save(c, A.name) end
return A
