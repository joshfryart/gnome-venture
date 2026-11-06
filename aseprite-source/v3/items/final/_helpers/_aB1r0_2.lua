-- _aB1r0_2.lua: private helpers for ph/cantuta-seed, cape-daisy-seed, caper, caper-seed (Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua). Nothing shared is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local A = { G = G, HP = HP, X = X, K = K }

-- torn leaf scrap. o = {a,c,b (quad bezier), W, prof(t)->0..1, ramp(6), vein, cool, torn, fold, per (vein spacing),
--   tear={t0,amp,seed}, teeth={per,depth}, casters={masks}, name}
function A.scrap(c, o)
  local W = o.W
  local lm, ln, LT, LS, len = G.blade(o.a[1], o.a[2], o.c[1], o.c[2], o.b[1], o.b[2], function(t)
    if t > 0.985 then return -1 end
    return max(0.5, W * o.prof(t))
  end, { fold = o.fold or 0.4 })
  local tearEdge = {}
  if o.tear then
    local cut = {}
    lm:each(function(x, y) local k = K(x, y)
      local z = X.hash(floor((LS[k] + 1) * 3.2), 5, o.tear.seed or 3)
      local lim = o.tear.t0 + o.tear.amp * z
      if LT[k] < lim then cut[#cut + 1] = k
      elseif LT[k] < lim + 1.3 / len then tearEdge[k] = true end
    end)
    for _, k in ipairs(cut) do lm.s[k] = nil tearEdge[k] = nil end
  end
  if o.teeth then
    local cut = {}
    lm:each(function(x, y) local k = K(x, y)
      local t, s = LT[k], LS[k]
      local ph = t * len / o.teeth.per + (s > 0 and 0.5 or 0)
      local f = ph - floor(ph)                    -- sawtooth: tooth points toward tip
      local lim = 0.98 - (1 - f) * o.teeth.depth
      if t > 0.1 and t < 0.93 and abs(s) > lim then cut[#cut + 1] = k end
    end)
    for _, k in ipairs(cut) do lm.s[k] = nil end
  end
  local bias = {}
  for _, m in ipairs(o.casters or {}) do X.ao(bias, lm, m, 1, -1) G.cast(bias, lm, m, 1, 2, -1) end
  local tok = { r = { name = o.name or "scrap" } }
  local R = o.ramp
  G.toneN(c, lm, ln, R, { bias = bias, tok = tok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
  local PER = o.per or 6.5
  lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
    if bias[k] then return end
    if tearEdge[k] then c:put(x, y, o.torn, tok) return end
    if abs(s) < 0.14 and t < 0.95 then c:put(x, y, s <= 0 and o.vein or R[3], tok) return end
    local ph = (t * len - abs(s) * (o.slant or 4.0)) / PER + (s > 0 and 0.5 or 0) + 0.25
    local f = abs((ph - floor(ph)) - 0.5) * 2
    if f > 0.88 and abs(s) > 0.17 and abs(s) < 0.72 and t < 0.9 then c:put(x, y, s < 0 and R[6] or R[2], tok) end
  end)
  lm:edge():each(function(x, y) local k = K(x, y)
    if not bias[k] and not tearEdge[k] and LS[k] > 0.62 and LT[k] < 0.88 then c:put(x, y, o.cool, tok) end end)
  return lm, LT, LS, tok, bias, len
end

-- small sprout leaf along quad bezier with midrib; prof(t) 0..1; o.teeth optional
function A.leaflet(c, ax, ay, cx, cy, bx, by, w, prof, R, tok, o)
  o = o or {}
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * prof(t))
  end, { fold = o.fold or 0.3 })
  if o.teeth then
    local cut = {}
    m:each(function(x, y) local k = K(x, y)
      local ph = T[k] * len / o.teeth + (S[k] > 0 and 0.5 or 0)
      if T[k] > 0.3 and T[k] < 0.9 and abs(S[k]) > 0.55 and (ph - floor(ph)) < 0.34 then cut[#cut + 1] = k end
    end)
    for _, k in ipairs(cut) do m.s[k] = nil end
  end
  if o.cutBy then for _, cm in ipairs(o.cutBy) do m:cut(cm) end end
  G.toneN(c, m, n, R, { tok = tok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.14, wrap = 0.3, bias = o.bias })
  if not o.norib then
    m:each(function(x, y) local k = K(x, y)
      if abs(S[k]) < 0.14 and T[k] > 0.12 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and R[6] or R[3], tok) end end)
  end
  return m, T, S
end

-- lit tube (stems, pedicels) along cubic bezier
function A.stem(c, pts, wfn, R, tok, cuts)
  local m, n, T, S = G.tube(pts, wfn)
  X.tone(c, m, X.light(n, { amb = 0.15, wrap = 0.3 }), R, { cuts = cuts or { 0.3, 0.55, 0.8 }, tok = tok })
  return m, T, S
end

function A.within(m, x, y) return m:has(x, y) end
return A
