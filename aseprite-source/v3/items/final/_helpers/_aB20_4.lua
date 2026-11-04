-- _aB20_4.lua: private helpers for ph/clivia-seed, ph/cloudberry, ph/cloudberry-jam, ph/cloudberry-seed (final, Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi, atan = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.atan
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
function A.tok(name) return { r = { name = name } } end

-- light + tone; returns idx, v
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- ellipse mask (axis aligned or rotated by unit vector ux,uy) + ellipsoid normals
function A.ell(cx, cy, rx, ry, ang)
  local ca, sa = cos(ang or 0), sin(ang or 0)
  local m = G.rell(cx, cy, ca, sa, rx + 0.3, ry + 0.3)
  local n = {}
  m:each(function(x, y)
    local dx, dy = x - cx, y - cy
    local u, v = (dx*ca + dy*sa) / (rx + .5), (-dx*sa + dy*ca) / (ry + .5)
    local q = max(0.03, 1 - u*u - v*v)
    local wx, wy = u*ca - v*sa, u*sa + v*ca
    n[K(x, y)] = { norm(wx, wy, sqrt(q)) }
  end)
  return m, n
end

-- drupelet cluster (cloudberry): hex-packed beads over an ellipse body. Bumpy silhouette, a Voronoi seam
-- between beads one tone darker, each lit bead gets its own small specular (glossy). Returns mask, centres.
function A.drupes(c, cx, cy, rx, ry, rd, ramp, o)
  o = o or {}
  local sp = rd * 1.9
  local cs = {}
  local row = 0
  for y = cy - ry, cy + ry + 0.01, sp * 0.87 do
    local off = (row % 2) * sp * 0.5 row = row + 1
    for x = cx - rx - sp, cx + rx + sp, sp do
      local xx = x + off
      local u, v = (xx - cx) / (rx - rd * 0.55), (y - cy) / (ry - rd * 0.55)
      if u*u + v*v <= 1.02 then cs[#cs + 1] = { xx, y } end
    end
  end
  local m = HP.mask()
  for _, p in ipairs(cs) do m:add(G.rell(p[1], p[2], 1, 0, rd + 0.35, rd + 0.35)) end
  if o.clip then m:clip(o.clip) end
  local n, seam, near = {}, {}, {}
  m:each(function(x, y)
    local b1, b2, j = 1e9, 1e9, 1
    for i, p in ipairs(cs) do
      local d = sqrt((x - p[1])^2 + (y - p[2])^2)
      if d < b1 then b2 = b1 b1, j = d, i elseif d < b2 then b2 = d end
    end
    local p = cs[j]
    local bx, by = (p[1] - cx) / (rx + 1), (p[2] - cy) / (ry + 1)
    local lx, ly = (x - p[1]) / (rd + .6), (y - p[2]) / (rd + .6)
    local k = K(x, y)
    n[k] = { norm(bx * 0.8 + lx * 0.85, by * 0.8 + ly * 0.85, sqrt(max(0.05, 1 - lx*lx - ly*ly)) * 0.9 + sqrt(max(0.05, 1 - bx*bx - by*by)) * 0.4) }
    if b2 - b1 < 0.8 then seam[k] = -2 elseif b2 - b1 < 1.6 and x - p[1] + y - p[2] > 0 then seam[k] = -1 end
    near[k] = j
  end)
  local bias = o.bias or {}
  for k, v in pairs(seam) do bias[k] = (bias[k] or 0) + v end
  local idx = A.shade(c, m, n, ramp, { bias = bias, tok = o.tok, amb = o.amb or 0.06, wrap = o.wrap or 0.2, cuts = o.cuts })
  -- per-bead glint: upper-left of each bead on the lit half
  local lit = {}
  for i, p in ipairs(cs) do
    local gx, gy = floor(p[1] - rd * 0.38 + .5), floor(p[2] - rd * 0.42 + .5)
    local k = K(gx, gy)
    if m:has(gx, gy) and near[k] == i and (idx[k] or 0) >= 4 and not (o.bias and o.bias[k] and o.bias[k] < 0) then
      c:put(gx, gy, ramp[#ramp], o.tok) lit[#lit + 1] = { gx, gy, (p[1] - cx) + (p[2] - cy) }
    end
  end
  table.sort(lit, function(a, b) return a[3] < b[3] end)
  return m, cs, n, idx, lit, near
end

-- torn edge: bite irregular notches into mask m where sel(x,y) is true; returns the new raw edge mask
function A.tear(m, sel, seed, depth)
  local cut = {}
  m:edge():each(function(x, y) if sel(x, y) and X.hash(x, y, seed) < 0.55 then cut[#cut + 1] = { x, y } end end)
  for _, p in ipairs(cut) do m.s[K(p[1], p[2])] = nil
    if depth and X.hash(p[1], p[2], seed + 7) < 0.35 then
      for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do local x, y = p[1] + d[1], p[2] + d[2]
        if sel(x, y) and X.hash(x, y, seed + 3) < 0.4 then m.s[K(x, y)] = nil end end
    end
  end
  local e = HP.mask()
  m:edge():each(function(x, y) if sel(x, y) then e:set(x, y) end end)
  return e
end

-- 1 px polyline painter (ramp chooser f(t) -> hex)
function A.stroke(c, pts, f, tok, steps)
  steps = steps or 60
  local done = {}
  for i = 0, steps do local t = i / steps
    local x, y = G.bez(pts, t)
    local xi, yi = floor(x + .5), floor(y + .5)
    local k = K(xi, yi)
    if not done[k] then done[k] = true c:put(xi, yi, f(t, xi, yi), tok) end
  end
end

-- palmate lobed leaf (cloudberry): centre, radius rx/ry (foreshortened), petiole notch angle a0,
-- nl lobes, small teeth. Normals: pillow + crinkle between veins. Returns m, n, veinMask, ang(k), rad(k)
function A.palmLeaf(cx, cy, rx, ry, a0, nl, o)
  o = o or {}
  local m, A0, R = HP.mask(), {}, {}
  local Rm = max(rx, ry) + 3
  for y = floor(cy - Rm), floor(cy + Rm) do for x = floor(cx - Rm), floor(cx + Rm) do
    local dx, dy = (x - cx) / rx, (y - cy) / ry
    local r = sqrt(dx*dx + dy*dy)
    local a = atan(dy, dx) - a0
    a = (a + pi) % (2 * pi) - pi
    local lob = 1 - 0.09 * cos(nl * a) - 0.035 * (X.hash(floor(a * 18), 0, 5) > 0.5 and 1 or 0)
    if abs(a) < 0.32 then lob = lob - (0.32 - abs(a)) * 1.3 end   -- petiole notch
    if r <= lob then m:set(x, y) A0[K(x, y)] = a R[K(x, y)] = r / lob end
  end end
  local np = X.pillow(m, o.R or 3)
  local n, vein = {}, HP.mask()
  m:each(function(x, y) local k = K(x, y)
    local a, r = A0[k], R[k]
    local ph = a / (2 * pi) * nl                 -- vein centred in each lobe
    local f = ph - floor(ph) - 0.5               -- -0.5..0.5 across lobe
    local cr = sin(f * 2 * pi) * 0.42 * min(1, r * 1.6)
    local ta = a + a0
    local tx, ty = -sin(ta), cos(ta)
    local p = np[k]
    n[k] = { norm(p[1] + tx * cr, p[2] + ty * cr, p[3]) }
    if abs(f) < 0.06 + 0.02 / max(r, 0.2) and r > 0.12 and r < 0.88 then vein:set(x, y) end
  end)
  return m, n, vein, A0, R
end

return A
