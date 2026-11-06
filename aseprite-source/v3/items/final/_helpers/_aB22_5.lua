-- _aB22_5.lua: private helpers for ph/crowberries, crowberry-cordial, crown-anemone-seed, cucumber (final pass, Opus). Copy of _aB22_4.lua.
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

-- torn leaf scrap along quadratic bezier; o.casters = list of masks lying on it (AO + contact shadow);
-- o.tear0/o.tear1 = torn depth at base/tip (T units); o.veins = "net" | "par"; returns m, T, S, idx, len
function A.scrap(c, ramp, ax, ay, cx, cy, bx, by, w, o)
  o = o or {}
  local wfn = o.wfn or function(t)
    if t > 0.985 then return -1 end
    return max(0.5, w * sin(pi * min(1, t * 0.9 + 0.08)) ^ (o.pw or 0.55))
  end
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, wfn, { fold = o.fold or 0.35 })
  local cut, torn = {}, HP.mask()
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    local j0 = (o.tear0 or 0) * (0.55 + 0.9 * X.hash(floor(s * 3.5 + 7), 3, o.seed or 11))
    local j1 = (o.tear1 or 0) * (0.55 + 0.9 * X.hash(floor(s * 3 + 9), 5, o.seed or 11))
    if t < j0 or t > 1 - j1 then cut[#cut + 1] = k
    elseif t < j0 + 0.035 or (o.tear1 and t > 1 - j1 - 0.03) then torn:set(x, y) end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil n[k] = nil end
  torn:clip(m)
  local bias = {}
  for _, cm in ipairs(o.casters or {}) do X.ao(bias, m, cm, 1, -1) G.cast(bias, m, cm, 1, 2, -1) end
  local tok = o.tok or { r = { name = "scrap" } }
  local idx = G.toneN(c, m, n, ramp, { bias = bias, tok = tok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.16, wrap = 0.3 })
  local VEIN = o.vein or ramp[6]
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if bias[k] then return end
    if o.veins == "par" then
      local q = (s + 1) * (o.nvein or 4) % 1
      if abs(s) < 0.12 then c:put(x, y, s <= 0 and VEIN or ramp[3], tok)
      elseif q < 0.22 and abs(s) < 0.8 then c:put(x, y, s < 0 and ramp[min(6, idx[k] + 1)] or ramp[max(1, idx[k] - 1)], tok) end
    else
      if abs(s) < 0.13 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or ramp[3], tok) return end
      local d = (t * len - abs(s) * w * (o.sweep or 1.2)) % (o.vs or 5)
      if d < 0.8 and abs(s) > 0.2 and abs(s) < 0.78 and t < 0.9 then c:put(x, y, s < 0 and ramp[min(6, idx[k] + 1)] or ramp[max(1, idx[k] - 1)], tok) end
    end
  end)
  m:edge():each(function(x, y) local k = K(x, y)
    if not bias[k] and S[k] > 0.62 and not torn:has(x, y) then c:put(x, y, o.cool or "#3a6c72", tok) end end)
  torn:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, o.fibre or ramp[5], tok) end end)
  return m, T, S, idx, len
end

-- glossy seed: oval with tone, AO bias, one glint; returns mask, idx
function A.seed(c, s, ramp, o)
  o = o or {}
  local m, n = G.oval(s[1], s[2], s[3], s[4], s[5] or 0, o.flat or 0.8)
  local vis = m:copy()
  for _, cm in ipairs(o.over or {}) do vis:cut(cm) end
  local bias = o.bias or {}
  local nn = {} vis:each(function(x, y) nn[K(x, y)] = n[K(x, y)] end)
  local tok = { r = { name = o.name or "seed" } }
  local idx = A.shade(c, vis, nn, ramp, { tok = tok, bias = bias, amb = 0.08, wrap = 0.25 })
  local rim = X.rim(nn)
  vis:edge():each(function(x, y) local k = K(x, y) if (rim[k] or 0) > 0.55 and idx[k] and idx[k] <= 2 then c:put(x, y, o.cool or ramp[3], tok) end end)
  if o.glint ~= false then
    local gx, gy = G.specAt(vis, nn, 30)
    if gx then c:put(gx, gy, o.glint or ramp[6], tok) end
  end
  return m, idx, tok, vis
end
return A
