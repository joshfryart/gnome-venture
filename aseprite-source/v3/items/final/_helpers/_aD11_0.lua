-- _aD11_0.lua: private helpers for ph/quince-seed, quinoa, quinoa-seed, quinoa-soup (final pass, Sonnet high).
-- Read-only use of _aD10_0.lua (-> batch2/_b2g1.lua -> batch1/_g1.lua -> _h.lua -> lib). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/_aD10_0.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local norm = A.norm

-- smooth-ish 1D value noise from the hash
function A.noise1(t, s)
  local i = floor(t) local f = t - i
  local a, b = X.hash(i, 7, s), X.hash(i + 1, 7, s)
  f = f * f * (3 - 2 * f)
  return a + (b - a) * f
end

-- wedge / teardrop seed: pointed tip at -u end, blunt round end at +u. L length, W full width
function A.wedge(cx, cy, L, W, ang, fat)
  local ca, sa = cos(ang), sin(ang)
  local m = HP.mask()
  local R = L / 2 + 2
  for y = floor(cy - R), floor(cy + R) + 1 do for x = floor(cx - R), floor(cx + R) + 1 do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / (L / 2 + 0.4)
    local v = (-dx * sa + dy * ca) / (W / 2 + 0.3)
    if u >= -1 and u <= 1 then
      local k = (fat or 0.3)
      local wu
      if u < k then wu = sqrt(max(0, 1 - ((u - k) / (1 + k)) ^ 2)) ^ 1.15 else wu = sqrt(max(0, 1 - ((u - k) / (1 - k)) ^ 2)) end
      if abs(v) <= wu then m:set(x, y) end
    end
  end end
  return m
end

-- ramp from 2 anchor colours: dark..light by mixing through a mid
function A.ramp6(deep, mid, hi)
  local mix = G.mix
  return { deep, mix(deep, mid, .5), mid, mix(mid, hi, .4), mix(mid, hi, .75), hi }
end

-- torn leaf blade: broad blade along a bezier, with ragged torn edge on the side(s) in `tear`, pale fibre rim on the tear,
-- midrib, swept lateral veins, optional downy edge speckle. returns m, n, T, S, len, tornEdge mask
function A.tornBlade(c, ax, ay, cx, cy, bx, by, wfn, o)
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, wfn, { fold = o.fold or 0.4 })
  local torn = HP.mask()
  if o.tear then
    local cutk = {}
    m:each(function(x, y) local k = K(x, y)
      local t, s = T[k], S[k]
      local side = (s < 0) and -1 or 1
      local td = o.tear[side]
      if td then
        local nz = A.noise1(t * len / 2.3, 3 + side) * 0.7 + A.noise1(t * len / 0.9, 9 + side) * 0.3
        local lim = 0.97 - td.depth * nz
        if t >= (td.t0 or 0.05) and t <= (td.t1 or 0.95) and abs(s) > lim then cutk[#cutk + 1] = k end
      end
    end)
    for _, k in ipairs(cutk) do m.s[k] = nil end
    -- keep the biggest connected piece (drop floaters)
  end
  local R = o.ramp
  local bias = o.bias or {}
  local tok = o.tok or { r = { name = "leaf" } }
  G.toneN(c, m, n, R, { bias = bias, tok = tok, cuts = o.cuts or { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = o.amb or 0.16, wrap = o.wrap or 0.3 })
  -- midrib + veins
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if bias[k] then return end
    if abs(s) < (o.rib or 0.14) and t > 0.03 and t < (o.ribEnd or 0.92) then c:put(x, y, s <= 0 and (o.ribHi or R[6]) or R[3], tok) return end
    for _, vt in ipairs(o.veins or {}) do
      local d = (t - vt) * len - abs(s) * (o.sweep or 2.6)
      if d > -0.5 and d < 0.5 and abs(s) > 0.2 and abs(s) < (o.veinMax or 0.82) then
        c:put(x, y, s < 0 and R[5] or R[2], tok)
      end
    end
  end)
  -- cool reflected light on the lower-right rim
  if o.cool then
    m:edge():each(function(x, y) local k = K(x, y)
      if not bias[k] and S[k] > 0.55 and T[k] > 0.08 and T[k] < 0.9 then c:put(x, y, o.cool, tok) end end)
  end
  -- torn rim: a pale fibrous 1px line on the tear sides
  if o.tear then
    m:edge():each(function(x, y) local k = K(x, y)
      local s, t = S[k], T[k]
      local side = (s < 0) and -1 or 1
      local td = o.tear[side]
      if td and abs(s) > 0.5 and t > (td.t0 or 0.05) - 0.02 and t < (td.t1 or 0.95) + 0.02 and not bias[k] then
        torn:set(x, y)
        c:put(x, y, o.fibre or R[6], tok)
      end
    end)
  end
  return m, n, T, S, len, torn
end

-- thin stem along a bezier with a light-to-shade tube. returns m
function A.stem(c, pts, w0, w1, ramp, cuts, extra)
  local m, n, T, S = G.tube(pts, function(t) return w0 + (w1 - w0) * t end)
  if extra and extra.cut then m:cut(extra.cut) end
  G.toneN(c, m, n, ramp, { cuts = cuts or { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3, bias = extra and extra.bias })
  return m, T, S
end

-- small lit bead (sphere): ramp 6 tones, optional spec
function A.bead(c, cx, cy, r, ramp, o)
  o = o or {}
  local m = c:ellipse(cx, cy, r, r)
  if o.cut then m:cut(o.cut) end
  local n = X.sphere(cx - 0.3, cy - 0.3, r, m)
  G.toneN(c, m, n, ramp, { cuts = o.cuts or { 0.2, 0.38, 0.54, 0.7, 0.86 }, bias = o.bias, amb = o.amb or 0.06, wrap = o.wrap or 0.2 })
  if o.spec then
    local sx, sy = G.specAt(m, n, 30)
    if sx then c:px(sx, sy, o.spec) end
  end
  return m
end
return A
