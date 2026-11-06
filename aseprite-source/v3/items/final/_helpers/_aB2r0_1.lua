-- _aB2r0_1.lua: private helpers for ph/elderberry-seed (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local floor, max, min, abs, sin, pi = math.floor, math.max, math.min, math.abs, math.sin, math.pi
A.HP, A.X, A.K = HP, X, K

-- serrated lanceolate blade along quadratic bezier. o: w (half width), per (tooth period px), depth (0..1),
-- tear (px of ragged torn base, 0 = intact), veinPer, fold, bias, tok, cut (mask), t0/t1 serration range
-- returns m, idx, T, S, len
function A.serrate(c, ax, ay, cx, cy, bx, by, ramp, o)
  o = o or {}
  local w = o.w or 3
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, o.wfn or function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.92 + 0.08)) ^ (o.pw or 0.8))
  end, { fold = o.fold or 0.4 })
  local per, depth = o.per or 3, o.depth or 0.3
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    local t, s = T[k], S[k]
    local ph = t * len / per + (s > 0 and 0.5 or 0)
    local f = ph - floor(ph)                     -- sawtooth: tooth tips point toward the leaf tip
    local lim = 1 - depth * (1 - f)
    if t > (o.t0 or 0.08) and t < (o.t1 or 0.93) and abs(s) > lim then cut[#cut + 1] = k end
    if o.tear and o.tear > 0 then
      local j = X.hash(floor(abs(s) * 4), 3, 17)
      local lim2 = o.tear * (0.35 + 0.65 * j) + (s > 0.2 and 1.2 or 0)
      if t * len < lim2 then cut[#cut + 1] = k end
    end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  if o.cut then m:cut(o.cut) end
  local tok = o.tok or { r = { name = "leaf" } }
  local idx = G.toneN(c, m, n, ramp, { bias = o.bias, tok = tok, cuts = o.cuts or { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
  local vp = o.veinPer or 4.2
  m:each(function(x, y) local k = K(x, y)
    if o.bias and o.bias[k] then return end
    local s, t = S[k], T[k]
    if abs(s) < 0.15 and t > 0.03 and t < 0.92 then
      c:put(x, y, s <= 0 and (o.vein or ramp[6]) or ramp[max(2, (idx[k] or 3) - 1)], tok) return end
    local ph = (t * len - abs(s) * w * 1.1) / vp + (s > 0 and 0.5 or 0)
    local f = abs((ph - floor(ph)) - 0.5) * 2
    if f > 0.86 and abs(s) > 0.2 and abs(s) < 0.72 and t > 0.08 and t < 0.86 then
      c:put(x, y, s < 0 and ramp[min(6, (idx[k] or 3) + 1)] or ramp[max(1, (idx[k] or 3) - 1)], tok) end
  end)
  return m, idx, T, S, len
end

return A
