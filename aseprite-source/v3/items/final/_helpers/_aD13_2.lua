-- _aD13_2.lua: private helpers for ph/root_cellar-lantern, root_cellar-mossy, rope, rose-arch (final pass).
-- Read-only use of batch1/_g0.lua (-> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
G.out = app.params.out or (DIR .. "/../ph/")
local A = setmetatable({}, { __index = G })
local sqrt, floor, ceil, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.ceil, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- 6-tone ramps (dark -> light), cool-violet shadows, warm lights
A.MOSS   = { "#1d3b3a", "#2c5f47", "#42834a", "#62a653", "#8cc660", "#c0e07c" }
A.OLIVE  = { "#233b38", "#35593d", "#4e7a3a", "#6f9b40", "#98bb4a", "#c6dc6c" }
A.STONE  = { "#3d3d5a", "#585876", "#767590", "#9796ac", "#bab8c9", "#e2e0e6" }
A.WOOD   = { "#3f2729", "#5c3733", "#7b4a37", "#a06540", "#c3854f", "#e8b982" }
A.AMBER  = { "#5e2430", "#9a3d22", "#d9701f", "#f5a42a", "#ffd062", "#fff2b0" }
A.IRON   = { "#231d2e", "#383350", "#524f6c", "#74738d", "#a0a0b6", "#d2d2e0" }
A.EMBER  = { "#4a1a32", "#7a2340", "#b52e3f", "#e8493b", "#ff7a54", "#ffb892" }
A.PETAL  = { "#5a2050", "#8c3972", "#c94f84", "#f5809f", "#ffa8c0", "#ffd9e5" }
A.YELLOW = { "#7a3d22", "#b8641f", "#e39a28", "#f5bf34", "#ffdf6a", "#fff3b0" }
A.LEAF   = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
A.HEMP   = { "#4a3639", "#74543a", "#a47746", "#cc9c5c", "#e6c27c", "#f8e6aa" }
A.CREAMR = { "#6c5a7a", "#948ca8", "#c2b8c2", "#e2d8d0", "#f6ecda", "#fffaf0" }

function A.hash(x, y, s) return X.hash(x, y, s or 0) end
function A.clamp(i, n) return max(1, min(n or 6, i)) end

-- light a normal field into a ramp; returns idx table, v
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.07, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end
function A.bump(c, idx, ramp, x, y, d)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = A.clamp(i + d, #ramp) idx[k] = i
  c:put(x, y, ramp[i])
end

-- pillow-lit mask in one go
function A.lit(c, m, ramp, R, o)
  o = o or {}
  local n = X.pillow(m, R or 3)
  local idx, v = A.shade(c, m, n, ramp, o)
  return idx, n, v
end

-- darken everything already painted just outside mask m (ambient / contact)
function A.contact(c, m, hex, region)
  m:grow(1):cut(m):each(function(x, y)
    if c:get(x, y) and (not region or region:has(x, y)) then c:put(x, y, hex) end
  end)
end

-- dense cubic bezier points {x,y}
function A.curve(p, n)
  local out = {}
  for i = 0, n do out[#out + 1] = { G.bez(p, i / n) } end
  return out
end
-- dense polyline resample (spacing ~step)
function A.poly(pts, step)
  step = step or 0.5
  local out = {}
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local l = sqrt((b[1] - a[1]) ^ 2 + (b[2] - a[2]) ^ 2)
    local n = max(1, ceil(l / step))
    for s = 0, n - 1 do out[#out + 1] = { a[1] + (b[1] - a[1]) * s / n, a[2] + (b[2] - a[2]) * s / n } end
  end
  out[#out + 1] = { pts[#pts][1], pts[#pts][2] }
  return out
end
function A.path(pts)
  local u = 0
  for i, p in ipairs(pts) do
    if i > 1 then u = u + sqrt((p[1] - pts[i - 1][1]) ^ 2 + (p[2] - pts[i - 1][2]) ^ 2) end
    p.u = u
  end
  for i, p in ipairs(pts) do
    local a, b = pts[max(1, i - 1)], pts[min(#pts, i + 1)]
    local tx, ty = b[1] - a[1], b[2] - a[2]
    local l = sqrt(tx * tx + ty * ty) if l == 0 then l = 1 end
    p.tx, p.ty = tx / l, ty / l
    local px, py = -p.ty, p.tx
    if px + py < 0 then px, py = -px, -py end
    p.px, p.py = px, py
  end
  return pts
end
-- swept tube along dense points; wfn(t01) half width. returns mask, normals, U (arc len), S (-1 lit .. 1 shade), total
function A.sweep(pts, wfn)
  A.path(pts)
  local total = pts[#pts].u
  local m, n, U, S = HP.mask(), {}, {}, {}
  local bx0, by0, bx1, by1 = 1e9, 1e9, -1e9, -1e9
  local wmax = 0
  for _, p in ipairs(pts) do
    bx0 = min(bx0, p[1]) by0 = min(by0, p[2]) bx1 = max(bx1, p[1]) by1 = max(by1, p[2])
    wmax = max(wmax, wfn(p.u / total))
  end
  for y = floor(by0 - wmax - 1), ceil(by1 + wmax + 1) do for x = floor(bx0 - wmax - 1), ceil(bx1 + wmax + 1) do
    local best, bp
    for _, p in ipairs(pts) do
      local dx, dy = x - p[1], y - p[2]
      local q = dx * dx + dy * dy
      if not best or q < best then best, bp = q, p end
    end
    local w = wfn(bp.u / total)
    if w > 0 and sqrt(best) <= w then
      local sd = (x - bp[1]) * bp.px + (y - bp[2]) * bp.py
      local sn = max(-0.97, min(0.97, sd / (w + 0.5)))
      local k = K(x, y)
      m:set(x, y)
      n[k] = { bp.px * sn, bp.py * sn, sqrt(1 - sn * sn) }
      U[k], S[k] = bp.u, sn
    end
  end end
  return m, n, U, S, total
end

-- twisted hemp: lit cylinder with diagonal strand grooves
function A.hempPaint(c, m, n, U, S, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = 0.08, wrap = 0.3 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.2, 0.38, 0.54, 0.7, 0.86 } })
  local per, kk = o.per or 3.4, o.k or 0.6
  m:each(function(x, y)
    local k = K(x, y)
    local ph = (U[k] / per + S[k] * kk) % 1
    local i = idx[k]
    if ph < 0.22 then i = i - 3 elseif ph < 0.36 then i = i - 1 elseif ph > 0.5 and ph < 0.68 then i = i + 1 end
    i = A.clamp(i, #ramp) idx[k] = i
    c:put(x, y, ramp[i])
  end)
  return idx
end
function A.shiftIdx(c, idx, ramp, mask, d)
  mask:each(function(x, y) A.bump(c, idx, ramp, x, y, d) end)
end

-- leaflet: tapered blade with midrib + veins, crinkled edge. returns mask
function A.leaflet(c, ax, ay, bx, by, w, ramp, o)
  o = o or {}
  local len = sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
  local m, n, T, S = X.cyl(ax, ay, bx, by, function(t)
    if t > 0.98 then return -1 end
    local b = w * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.62
    if o.serr then b = b + 0.35 * sin(t * len * 2.3) end
    return max(0.55, b)
  end)
  if o.cut then m:cut(o.cut) end
  local tok = { r = { name = "leaf" } }
  local v = X.light(n, { amb = 0.12, wrap = 0.28 })
  X.tone(c, m, v, ramp, { cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = tok })
  m:each(function(x, y)
    local k = K(x, y)
    local s, t = S[k], T[k]
    if abs(s) < 0.2 and t > 0.04 and t < 0.92 then c:put(x, y, s <= 0 and ramp[6] or ramp[3], tok)
    elseif o.veins ~= false and t > 0.2 and t < 0.82 and abs(s) > 0.34 and abs(s) < 0.8 then
      local d = (t * len) % 2.4 - abs(s) * 1.6
      if d > -0.5 and d < 0.5 then c:put(x, y, s < 0 and ramp[5] or ramp[2], tok) end
    end
  end)
  return m
end

-- rose seen from the front: scalloped sphere, spiral petal grooves, specular
function A.rose(c, cx, cy, r, ramp, o)
  o = o or {}
  local phi = o.phi or 0
  local m = HP.mask()
  local x0, x1, y0, y1 = floor(cx - r - 2), ceil(cx + r + 2), floor(cy - r - 2), ceil(cy + r + 2)
  for y = y0, y1 do for x = x0, x1 do
    local dx, dy = x - cx, y - cy
    local th = math.atan(dy, dx)
    local rr = r + 0.5 * cos(5 * th + phi)
    if dx * dx + dy * dy <= rr * rr then m:set(x, y) end
  end end
  local n = X.sphere(cx - 0.3, cy - 0.3, r, m)
  local v = X.light(n, { amb = 0.1, wrap = 0.3 })
  local idx = X.tone(c, m, v, ramp, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 } })
  m:each(function(x, y)
    local dx, dy = x - cx, y - cy
    local rd = sqrt(dx * dx + dy * dy)
    local th = math.atan(dy, dx)
    local i = idx[K(x, y)]
    local ph = (rd * (o.tight or 0.62) + th / (2 * pi) + (o.sp or 0)) % 1
    if rd < 1.0 then i = 1
    elseif ph < 0.3 then i = i - 2
    elseif ph > 0.5 and ph < 0.62 then i = i + 1 end
    c:put(x, y, ramp[A.clamp(i, #ramp)])
  end)
  return m
end
function A.bud(c, x, y, ramp)
  c:px(x, y, ramp[4])
  c:px(x - 1, y + 1, ramp[5]) c:px(x, y + 1, ramp[4]) c:px(x + 1, y + 1, ramp[3])
  c:px(x - 1, y + 2, ramp[4]) c:px(x, y + 2, ramp[3]) c:px(x + 1, y + 2, ramp[2])
  c:px(x, y + 3, ramp[2])
  c:px(x - 1, y + 3, A.LEAF[4]) c:px(x + 1, y + 3, A.LEAF[3])
  c:px(x, y + 4, A.LEAF[2]) c:px(x, y + 5, A.LEAF[2])
end
-- toadstool: cap (sphere-lit, flattened) + stem + spots; stem runs from cy+1 to cy+stemH
function A.toad(c, cx, cy, r, stemH)
  local stem = c:rect(floor(cx - 0.5), floor(cy + 1), floor(cx + 0.5), floor(cy + stemH))
  A.lit(c, stem, A.CREAMR, 1)
  local cap = c:ellipse(cx, cy, r + 0.5, r * 0.75)
  local n = X.sphere(cx - 0.4, cy - 0.5, r + 0.5, cap)
  A.shade(c, cap, n, A.EMBER, { amb = 0.08, wrap = 0.3 })
  c:px(floor(cx - r * 0.4), floor(cy - r * 0.3), A.CREAM)
  c:px(floor(cx + r * 0.45), floor(cy + 0.3), A.CREAM)
  local by = floor(cy + r * 0.75)
  for x = floor(cx - r), floor(cx + r) do if cap:has(x, by) then c:px(x, by, A.EMBER[1]) end end
  return cap
end
return A
