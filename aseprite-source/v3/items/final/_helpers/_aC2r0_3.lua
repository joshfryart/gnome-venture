-- _aC2r0_3.lua: private helpers for ph/moth-wing, mulberry, mulberry-jam, mulberry-seed (final pass, Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.frac(v) return v - floor(v) end

-- serrated leaf blade (quadratic spine). Teeth point toward the tip: a notch every `per` px of the margin.
-- returns m, n, T, S, len
function A.leaf(ax, ay, cx, cy, bx, by, wfn, o)
  o = o or {}
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, wfn, { fold = o.fold or 0.35 })
  local per, depth = o.per or 3.2, o.depth or 0.16
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    local t, s = T[k], S[k]
    local f = A.frac(t * len / per + (s > 0 and 0.5 or 0))
    local lim = 0.97 - depth * (1 - f) ^ 1.6 * (o.toothScale and o.toothScale(t) or 1)
    if t > (o.t0 or 0.06) and t < 0.97 and abs(s) > lim then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  return m, n, T, S, len
end

-- midrib + pinnate veins (swept toward tip), lit side pale, shade side dark
function A.veins(c, m, T, S, len, ramp, tok, o)
  o = o or {}
  local per = o.per or 6
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if o.skip and o.skip[k] then return end
    if abs(s) < 0.13 and t > 0.02 and t < 0.93 then c:put(x, y, s <= 0 and (o.rib or ramp[6]) or ramp[3], tok) return end
    local ph = (t * len - abs(s) * (o.sweep or 4.5)) / per + (s > 0 and 0.5 or 0)
    local f = abs(A.frac(ph) - 0.5) * 2
    if f > 0.86 and abs(s) > 0.16 and abs(s) < 0.78 and t > 0.08 and t < 0.86 then c:put(x, y, s < 0 and ramp[6] or ramp[2], tok) end
  end)
end

-- sphere tone with blended body light; returns mask and idx
function A.ball(c, cx, cy, r, ramp, o)
  o = o or {}
  local m = HP.mask()
  for y = floor(cy - r - 1), floor(cy + r + 1) do for x = floor(cx - r - 1), floor(cx + r + 1) do
    if (x - cx) ^ 2 + (y - cy) ^ 2 <= (r + 0.3) ^ 2 then m:set(x, y) end end end
  if o.clip then m:cut(o.clip) end
  local n = X.sphere(cx - 0.3, cy - 0.3, r, m)
  local v = X.light(n, { amb = o.amb or 0.05, wrap = o.wrap or 0.2 })
  if o.body then for k, vv in pairs(v) do if o.body[k] then v[k] = vv * (1 - (o.mix or 0.45)) + o.body[k] * (o.mix or 0.45) end end end
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return m, idx, n
end

-- paint a polyline of 1px pixels
function A.line(c, pts, hex, tok, clip)
  for s = 1, #pts - 1 do
    local a, b = pts[s], pts[s + 1]
    local nn = max(abs(b[1] - a[1]), abs(b[2] - a[2]), 1)
    for i = 0, nn do
      local x, y = floor(a[1] + (b[1] - a[1]) * i / nn + .5), floor(a[2] + (b[2] - a[2]) * i / nn + .5)
      if not clip or clip:has(x, y) then c:put(x, y, hex, tok) end
    end
  end
end
return A
