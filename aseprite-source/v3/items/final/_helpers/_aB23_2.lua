-- _aB23_2.lua: private helpers for ph/daffodil-seed, dahlia-seed, daikon, daikon-seed (final pass, Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

function A.new(name) return G.new2(name) end

-- tear a blade end into a ragged edge. T,S from G.blade; len = blade length.
-- atStart: tear the t=0 end, else the t=1 end. depth px of raggedness. returns mask of fresh torn-edge pixels.
function A.tear(m, T, S, len, atStart, depth, seed)
  local cut = {}
  local function lim(s)
    local b = floor((s + 1) * 4.5)
    return 1 + depth * X.hash(b, seed or 1, 7) + 0.8 * X.hash(b * 3 + 1, seed or 1, 9)
  end
  m:each(function(x, y) local k = K(x, y)
    local d = atStart and T[k] * len or (1 - T[k]) * len
    if d < lim(S[k]) then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  local edge = HP.mask()
  m:each(function(x, y) local k = K(x, y)
    local d = atStart and T[k] * len or (1 - T[k]) * len
    if d < lim(S[k]) + 1.1 then edge:set(x, y) end
  end)
  return edge
end

-- glossy oval seed; returns mask, normals, idx
function A.seed(c, cx, cy, rx, ry, ang, ramp, o)
  o = o or {}
  local m, n = G.oval(cx, cy, rx, ry, ang, o.flat or 0.8)
  if o.cutBy then for _, q in ipairs(o.cutBy) do m:cut(q) end end
  local idx = G.toneN(c, m, n, ramp, { bias = o.bias, tok = o.tok, cuts = o.cuts or A.CUTS, amb = o.amb or 0.1, wrap = o.wrap or 0.3 })
  return m, n, idx
end

-- put the brightest specular pixel (+ optional 2x1) on mask m
function A.glint(c, m, n, hex, tok, two)
  local x, y = G.specAt(m, n, 40)
  if x then c:put(x, y, hex, tok) if two and m:has(x + 1, y) then c:put(x + 1, y, hex, tok) end end
  return x, y
end

-- cool reflected light on the lower-right rim of a mask
function A.reflect(c, m, n, hex, tok, thr)
  local r = X.rim(n)
  m:edge():each(function(x, y) local k = K(x, y) if (r[k] or 0) > (thr or 0.35) then c:put(x, y, hex, tok) end end)
end

-- thin 1px polyline stem along cubic bezier with lit/shade colour by t
function A.thread(c, p, colf, tok, steps)
  steps = steps or 40
  local seen = {}
  for i = 0, steps do local x, y = G.bez(p, i / steps)
    local xi, yi = floor(x + .5), floor(y + .5)
    local k = K(xi, yi)
    if not seen[k] then seen[k] = true c:put(xi, yi, colf(i / steps), tok) end
  end
end
return A
