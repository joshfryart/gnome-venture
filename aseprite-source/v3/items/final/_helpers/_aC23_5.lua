-- _aC23_5.lua: private helpers for ph/miso, miss-joaquim-seed, mixed-berry-cordial, monja-blanca-seed (final pass, Opus).
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

-- vertical cylinder normals between x0..x1 (optional top dome blend)
function A.vcylN(m, x0, x1)
  local n = {}
  m:each(function(x, y)
    local t = max(-.97, min(.97, ((x + 0.5 - x0) / (x1 + 1 - x0)) * 2 - 1))
    n[K(x, y)] = { t, 0, sqrt(1 - t * t) }
  end)
  return n
end
-- set of pixels as mask from list of rows of chars
function A.maskRows(rows, x0, y0, ch)
  local m = HP.mask()
  for yy, row in ipairs(rows) do for xx = 1, #row do
    if row:sub(xx, xx) == ch then m:set(x0 + xx - 1, y0 + yy - 1) end end end
  return m
end

-- torn leaf scrap along quadratic bezier A-C-B, half width w; tears at t>t1 (and t<t0) with jagged edge + pale fibres.
-- o.casters = masks lying on the scrap (AO ring + contact shadow down-right). returns m, n, T, S, idx, len, tok
function A.scrap(c, ax, ay, cx, cy, bx, by, w, ramp, o)
  o = o or {}
  local wfn = o.wfn or function(t) if t > 0.995 then return -1 end return max(0.6, w * sin(pi * min(1, t * 0.8 + 0.12)) ^ 0.6) end
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, wfn, { fold = o.fold or 0.35 })
  local t1, t0 = o.t1 or 2, o.t0 or -1
  local cut = {}
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    local j1 = t1 + 0.04 * sin(s * 11 + 1.3) + 0.04 * (X.hash(floor(s * 6 + 9), 3, 7) - 0.5)
    local j0 = t0 + 0.04 * sin(s * 9 + 0.4) + 0.04 * (X.hash(floor(s * 5 + 9), 1, 9) - 0.5)
    if t > j1 or t < j0 then cut[#cut + 1] = k end end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  local bias = o.bias or {}
  for _, cm in ipairs(o.casters or {}) do X.ao(bias, m, cm, 1, -1) G.cast(bias, m, cm, 1, 2, -1) end
  local tok = o.tok or { r = { name = "scrap" } }
  local idx = G.toneN(c, m, n, ramp, { amb = 0.14, wrap = 0.3, cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 }, tok = tok, bias = bias })
  local vs = o.vs or 4.2
  m:each(function(x, y) local k = K(x, y)
    if bias[k] then return end
    local s, t, i = S[k], T[k], idx[k] or 3
    if abs(s) < 0.14 then c:put(x, y, s <= 0 and ramp[min(6, i + 2)] or ramp[max(2, i - 1)], tok)
    elseif abs(s) > 0.25 and abs(s) < 0.82 then
      local d = (t * len - abs(s) * w * 1.15) % vs
      if d < 0.9 then c:put(x, y, s < 0 and ramp[min(6, i + 1)] or ramp[max(1, i - 1)], tok) end
    end
  end)
  m:edge():each(function(x, y) local k = K(x, y)
    if T[k] > t1 - 0.07 or T[k] < t0 + 0.07 then c:put(x, y, o.fibre or ramp[6], tok)
    elseif o.cool and S[k] > 0.55 and not bias[k] then c:put(x, y, o.cool, tok) end end)
  return m, n, T, S, idx, len, tok
end
return A
