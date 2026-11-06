-- _aC13_2.lua: private helpers for ph/jostaberry-seed, ph/jujube, ph/jujube-seed, ph/jute-mallow (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
A.CUTS = CUTS
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- blend sphere + pillow normals
function A.body(m, cx, cy, r, R, wS)
  local np = X.pillow(m, R or 5)
  local ns = X.sphere(cx, cy, r, m)
  local n = {}
  wS = wS or 0.6
  for k, a in pairs(np) do local b = ns[k]
    n[k] = { norm(a[1] * (1 - wS) + b[1] * wS, a[2] * (1 - wS) + b[2] * wS, a[3] * (1 - wS) + b[3] * wS) } end
  return n
end

function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- leaf along quadratic bezier; o.serr = serration period (px) on the margin; o.tri = 3 longitudinal veins (jujube)
function A.leaf(c, ax, ay, cx, cy, bx, by, w, ramp, o)
  o = o or {}
  local wfn = o.wfn or function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.98 + 0.04)) ^ (o.pw or 0.75))
  end
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, wfn, { fold = o.fold or 0.45 })
  if o.serr then
    local cut = {}
    m:each(function(x, y) local k = K(x, y)
      local ph = (T[k] * len / o.serr + (S[k] > 0 and 0.5 or 0)) % 1
      if abs(S[k]) > 0.8 and ph < 0.4 and T[k] > 0.1 and T[k] < 0.92 then cut[#cut + 1] = k end
    end)
    for _, k in ipairs(cut) do m.s[k] = nil end
  end
  if o.cut then m:cut(o.cut) end
  local tok = o.tok or { r = { name = "leaf" } }
  local idx = G.toneN(c, m, n, ramp, { amb = 0.12, wrap = 0.28, cuts = o.cuts or { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = tok, bias = o.bias })
  local vs = o.vs or 3.2
  m:each(function(x, y) local k = K(x, y)
    if o.bias and o.bias[k] then return end
    local s, t = S[k], T[k]
    local i = idx[k] or 3
    if abs(s) < 0.16 and t > 0.03 and t < 0.9 then c:put(x, y, s <= 0 and (o.vdark and ramp[6] or ramp[min(6, i + 2)]) or ramp[max(2, i - 1)], tok)
    elseif o.tri then
      -- two side veins running from the base along the blade (jujube: 3-nerved)
      local want = o.triw and (o.triw * sin(pi * min(1, t * 1.05 + 0.05)) ^ 0.6) or 0.55 * (1 - t * 0.6)
      if t > 0.06 and t < (o.triw and 0.9 or 0.8) and abs(abs(s) - want) < 0.1 then local j
        if o.vdark then j = (s < 0) and (i - o.vdark) or (i + 1) else j = (s < 0) and (i + 1) or (i - 1) end
        c:put(x, y, ramp[max(1, min(6, j))], tok) end
    elseif not o.novein and t > 0.12 and t < 0.86 and abs(s) > 0.3 and abs(s) < 0.8 then
      local d = (t * len - abs(s) * w * 1.1) % vs
      if d < 0.9 then c:put(x, y, s < 0 and ramp[min(6, i + 1)] or ramp[max(1, i - 1)], tok) end
    end
  end)
  -- cool reflected edge on the shade side
  if o.cool then m:edge():each(function(x, y) local k = K(x, y)
    if S[k] > 0.7 and T[k] > 0.15 and T[k] < 0.85 and not (o.bias and o.bias[k]) then c:put(x, y, o.cool, tok) end end) end
  return m, T, S, idx, len
end

function A.stem(c, pts, wfn, ramp, o)
  o = o or {}
  local m, n, T, S, samp = G.tube(pts, wfn)
  if o.cut then m:cut(o.cut) end
  local idx = A.shade(c, m, n, ramp, { amb = o.amb or 0.14, wrap = o.wrap or 0.3, cuts = o.cuts or (#ramp == 4 and { 0.3, 0.55, 0.8 } or CUTS), tok = o.tok, bias = o.bias })
  return m, n, T, S, idx, samp
end

-- polyline tube (straight segments) for zigzag twigs: list of points, half width w
function A.seg(pts, w)
  local m = HP.mask()
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local mm = X.cyl(a[1], a[2], b[1], b[2], function() return w end)
    m:add(mm)
    m:add(G.rell(a[1], a[2], 1, 0, w + 0.3, w + 0.3))
  end
  return m
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
