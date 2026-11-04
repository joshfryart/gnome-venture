-- _aD14_1.lua: private helpers for ph/salted-eggs, sampaguita-seed, samphire, samphire-salad (final pass).
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

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

-- light + tone a normal field; returns idx, v
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- blend of sphere-ish normal (about cx,cy, radius r) and pillow normals: round body with a soft silhouette
function A.body(m, cx, cy, r, R, wS)
  local np = X.pillow(m, R or 5)
  local ns = X.sphere(cx, cy, r, m)
  local n = {}
  wS = wS or 0.6
  for k, a in pairs(np) do local b = ns[k]
    n[k] = { norm(a[1] * (1 - wS) + b[1] * wS, a[2] * (1 - wS) + b[2] * wS, a[3] * (1 - wS) + b[3] * wS) } end
  return n
end

-- re-tone one pixel by delta steps using idx
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- leaf blade along quadratic bezier A-C-B; wfn optional; veins every `vs` px; returns mask, T, S
function A.leaf(c, ax, ay, cx, cy, bx, by, w, ramp, o)
  o = o or {}
  local wfn = o.wfn or function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.98 + 0.04)) ^ (o.pw or 0.75))
  end
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, wfn, { fold = o.fold or 0.45 })
  if o.cut then m:cut(o.cut) end
  local tok = o.tok or { r = { name = "leaf" } }
  local idx = G.toneN(c, m, n, ramp, { amb = 0.12, wrap = 0.28, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = tok, bias = o.bias })
  local vs = o.vs or 3.2
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if abs(s) < 0.16 and t > 0.03 and t < 0.9 then c:put(x, y, s <= 0 and ramp[min(6, (idx[k] or 3) + 2)] or ramp[max(2, (idx[k] or 3) - 1)], tok)
    elseif t > 0.12 and t < 0.86 and abs(s) > 0.3 and abs(s) < 0.8 then
      local d = (t * len - abs(s) * w * 1.1) % vs
      if d < 0.9 then c:put(x, y, s < 0 and ramp[min(6, (idx[k] or 3) + 1)] or ramp[max(1, (idx[k] or 3) - 1)], tok) end
    end
  end)
  return m, T, S, idx
end

-- tube with lighting; returns m, n, T, S, idx, samp
function A.stem(c, pts, wfn, ramp, o)
  o = o or {}
  local m, n, T, S, samp = G.tube(pts, wfn)
  if o.cut then m:cut(o.cut) end
  local idx = A.shade(c, m, n, ramp, { amb = o.amb or 0.14, wrap = o.wrap or 0.3, cuts = o.cuts or (#ramp == 4 and { 0.3, 0.55, 0.8 } or CUTS), tok = o.tok, bias = o.bias })
  return m, n, T, S, idx, samp
end

function A.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end

-- ---- D14_1 additions ----
local hash = X.hash
A.hash = hash
-- ellipsoid-ish normals for a mask about (cx,cy) with radii rx,ry
function A.ellN(m, cx, cy, rx, ry, flat)
  local n = {}
  m:each(function(x, y)
    local nx, ny = (x - cx) / (rx + 0.5), (y - cy) / (ry + 0.5)
    local q = 1 - nx * nx - ny * ny
    n[K(x, y)] = { norm(nx, ny, sqrt(max(q, 0.02)) * (flat or 1)) }
  end)
  return n
end
-- egg mask, broad end DOWN, lean = x shift per row
function A.eggM(cx, cy, rx, ry, k, lean)
  local m = HP.mask()
  for y = floor(cy - ry), math.ceil(cy + ry) do
    local t = (y - cy) / ry
    local w = rx * sqrt(max(0, 1 - t * t)) * (1 + (k or 0.14) * t)
    local sh = (lean or 0) * t
    for x = floor(cx + sh - w + 0.5), floor(cx + sh + w - 0.5) do m:set(x, y) end
  end
  return m
end
function A.bezlen(p)
  local L, px, py = 0
  for i = 0, 40 do local x, y = G.bez(p, i / 40) if px then L = L + sqrt((x - px) ^ 2 + (y - py) ^ 2) end px, py = x, y end
  return L
end
-- jointed succulent tube: width w, joints every `seg` px (pinched to pin*w), taper over the last 8%
function A.segtube(p, w, seg, pin, o)
  o = o or {}
  local L = A.bezlen(p)
  local m, n, T, S, sm = G.tube(p, function(t)
    local ph = (t * L) / seg + (o.off or 0.5)
    local f = abs(sin(pi * ph)) ^ 0.6
    local k = (pin or 0.62) + (1 - (pin or 0.62)) * f
    local tp = 1
    if t > 0.92 then tp = 1 - (t - 0.92) / 0.08 * 0.45 end
    if t < 0.05 then tp = 0.85 + t * 3 end
    return max(0.7, w * k * tp)
  end, o.steps or 90)
  return m, n, T, S, sm, L
end
-- dark band across the stem at each joint
function A.joints(c, sm, L, seg, w, col, tok, off)
  local nj = floor(L / seg)
  for j = 0, nj + 1 do
    local tt = (j - (off or 0.5) + 1.0) * seg / L
    -- joints are where phase is an integer: t*L/seg + off = j  => t = (j - off)*seg/L
    tt = (j - (off or 0.5)) * seg / L
    if tt > 0.06 and tt < 0.9 then
      local best, bs = 1e9
      for _, s in ipairs(sm) do local q = abs(s.t - tt) if q < best then best, bs = q, s end end
      for d = -1, 1 do
        local x, y = floor(bs.x + bs.px * d * w * 0.8 + 0.5), floor(bs.y + bs.py * d * w * 0.8 + 0.5)
        c:put(x, y, col, tok)
      end
    end
  end
end
return A
