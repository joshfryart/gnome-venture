-- _aD10_3: private helpers for primrose-seed, prospector-s-pick, prunes, pruning-shears (D10 artist pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua, hp.lua, hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local D = { G = G, HP = HP, X = X, K = K, INK = "#2b1c26", CREAM = "#fff4d6", hash = X.hash }
D.new, D.save = G.new2, G.save2

function D.line(c, pts, hex, tok) c:line(pts, 1):each(function(x, y) c:put(x, y, hex, tok) end) end
function D.px(c, list, hex, tok) for _, p in ipairs(list) do c:put(p[1], p[2], hex, tok) end end
function D.poly(c, pts) return c:poly(pts) end

-- tube along a cubic bezier, toned from its normals. returns m, n, T, S, idx
function D.tube(c, pts, wfn, ramp, o)
  o = o or {}
  local m, n, T, S = G.tube(pts, wfn, o.steps)
  if o.cut then m:cut(o.cut) end
  local idx = G.toneN(c, m, n, ramp, { bias = o.bias, tok = o.tok, cuts = o.cuts, amb = o.amb or 0.1, wrap = o.wrap or 0.3 })
  return m, n, T, S, idx
end

-- flat-lit oval (seed, fruit) with normals; returns m, n
function D.oval(c, cx, cy, rx, ry, ang, ramp, o)
  o = o or {}
  local m, n = G.oval(cx, cy, rx, ry, ang, o.flat or 0.8)
  if o.cut then m:cut(o.cut) end
  local idx = G.toneN(c, m, n, ramp, { bias = o.bias, tok = o.tok, cuts = o.cuts, amb = o.amb or 0.08, wrap = o.wrap or 0.28 })
  return m, n, idx
end

-- veined leaf blade (quadratic bezier a-c-b). o: wfn, ramp, per/amp/t0 (crenate margin), sp/slant (impressed veins),
-- bias, tok, fold, rib, vhi/vlo (vein colours), cool (reflected edge colour)
function D.leaf(c, a, o)
  local m, n, T, S, len = G.blade(a[1], a[2], a[3], a[4], a[5], a[6], o.wfn, { fold = o.fold or 0.4 })
  if o.per then
    local cut = {}
    m:each(function(x, y) local k = K(x, y)
      local t, s = T[k], S[k]
      local ph = t * len / o.per + (s > 0 and 0.5 or 0) + 0.25
      local f = abs((ph - floor(ph)) - 0.5) * 2
      local lim = 0.97 - (1 - f) ^ 2.4 * (o.amp or 0.3)
      if t > (o.t0 or 0.2) and t < 0.97 and abs(s) > lim then cut[#cut + 1] = k end
    end)
    for _, k in ipairs(cut) do m.s[k] = nil end
  end
  local bias = {}
  for k, v in pairs(o.bias or {}) do bias[k] = v end
  local R = o.ramp
  if o.sp then
    m:each(function(x, y) local k = K(x, y)
      local t, s = T[k], S[k]
      if t > 0.1 and abs(s) > 0.16 and abs(s) < 0.86 then
        local g = (t * len - abs(s) * o.slant) / o.sp
        local fr = g - floor(g)
        if fr >= 0.45 and fr < 0.78 then bias[k] = (bias[k] or 0) + 1 end
      end
    end)
  end
  local tok = o.tok or { r = { name = "leaf" } }
  G.toneN(c, m, n, R, { bias = bias, tok = tok, cuts = o.cuts or { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    local t, s = T[k], S[k]
    if o.rib ~= false and abs(s) < 0.15 and t > 0.03 and t < 0.94 then
      c:put(x, y, s <= 0 and o.vhi or R[3], tok) return
    end
    if o.sp and t > 0.1 and abs(s) > 0.16 and abs(s) < 0.86 and not (o.bias and o.bias[k] and o.bias[k] < 0) then
      local g = (t * len - abs(s) * o.slant) / o.sp
      local fr = g - floor(g)
      if fr < 0.2 then c:put(x, y, R[1], tok) elseif fr < 0.36 and s < 0 then c:put(x, y, R[5], tok) end
    end
  end)
  if o.cool then
    m:edge():each(function(x, y) local k = K(x, y)
      if S[k] and S[k] > 0.66 and T[k] > 0.1 and T[k] < 0.9 then c:put(x, y, o.cool, tok) end end)
  end
  return m, n, T, S, len, tok
end

return D
