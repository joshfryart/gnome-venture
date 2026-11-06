-- _aB13_2.lua: private helpers for ph/buckwheat, buckwheat-kasha, buckwheat-seed, building-stone (final pass, Opus).
-- Copy of _aA0_0.lua pattern. Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib). No shared file edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../games/")
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

-- triangular achene (buckwheat): 3 corners {x,y}; faceted pyramid normals with a ridge from each corner to apex
-- returns mask, facet-id per pixel, normals
function A.tri(p, apex, h)
  local m, F, n = HP.mask(), {}, {}
  local cx = (p[1][1] + p[2][1] + p[3][1]) / 3
  local cy = (p[1][2] + p[2][2] + p[3][2]) / 3
  apex = apex or { cx, cy }
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for _, q in ipairs(p) do x0, y0, x1, y1 = min(x0, q[1]), min(y0, q[2]), max(x1, q[1]), max(y1, q[2]) end
  local E = {}
  for i = 1, 3 do local a, b = p[i], p[i % 3 + 1]
    local ex, ey = b[1] - a[1], b[2] - a[2] local l = sqrt(ex*ex + ey*ey)
    local nx, ny = ey / l, -ex / l
    if (cx - a[1]) * nx + (cy - a[2]) * ny > 0 then nx, ny = -nx, -ny end -- outward
    E[i] = { a = a, nx = nx, ny = ny }
  end
  for y = floor(y0) - 1, floor(y1) + 1 do for x = floor(x0) - 1, floor(x1) + 1 do
    local d, ok, near = {}, true, 0
    for i = 1, 3 do d[i] = -((x - E[i].a[1]) * E[i].nx + (y - E[i].a[2]) * E[i].ny) if d[i] < -0.35 then ok = false end
      if d[i] < 0.9 then near = near + 1 end end
    if ok and near < 2 then
      m:set(x, y)
      -- facet: the edge with smallest distance relative to apex distance
      local bi, bv = 1, 1e9
      for i = 1, 3 do local da = -((apex[1] - E[i].a[1]) * E[i].nx + (apex[2] - E[i].a[2]) * E[i].ny)
        local r = d[i] / max(0.5, da) if r < bv then bv, bi = r, i end end
      local k = K(x, y) F[k] = bi
      n[k] = { norm(E[bi].nx * (h or 0.8), E[bi].ny * (h or 0.8), 1) }
    end
  end end
  return m, F, n
end

-- heart / arrow leaf: blade from base (ax,ay) via (cx,cy) to tip (bx,by) plus two rounded basal lobes; returns mask, n, T, S, len
function A.heart(ax, ay, cx, cy, bx, by, W, lobe)
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, W * (sin(pi * min(1, 0.42 + t * 0.6))) ^ 0.75 * (1 - t * 0.15))
  end, { fold = 0.4 })
  local ux, uy = cx - ax, cy - ay local l = sqrt(ux*ux + uy*uy) ux, uy = ux / l, uy / l
  local px, py = -uy, ux
  local lb = HP.mask()
  for _, sgn in ipairs{ -1, 1 } do
    local lx, ly = ax + px * sgn * W * 0.5 - ux * (lobe or 1.6), ay + py * sgn * W * 0.5 - uy * (lobe or 1.6)
    lb:add(G.rell(lx, ly, ux, uy, W * 0.62, W * 0.52))
  end
  lb:cut(m)
  -- V notch at the petiole
  local notch = HP.mask()
  lb:each(function(x, y) local rx, ry = x - ax, y - ay
    local al, pe = rx * ux + ry * uy, rx * px + ry * py
    if al < 0.6 and abs(pe) < (0.6 - al) * 0.42 + 0.2 then notch:set(x, y) end end)
  lb:cut(notch) m:cut(notch)
  local ln = X.pillow(lb, 2)
  for k, v in pairs(ln) do n[k] = v T[k] = 0 S[k] = 0.5 end
  return m:add(lb), n, T, S, len, lb
end
return A
