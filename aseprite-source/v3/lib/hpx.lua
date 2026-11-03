-- hpx.lua: "realism" helpers on top of hp.lua (items pass 3, 2026-11-03).
-- Per-pixel light from a normal field, quantised to a 5-7 tone ramp (hard pixels, no dither).
--   local X = dofile(<lib>/hpx.lua)            -- needs HP loaded first (pass it: X.init(HP))
--   X.L                                        -- light dir (upper-left, toward viewer)
--   X.dist(mask)        -> d[k]                -- Euclidean distance of each pixel to the nearest non-mask pixel
--   X.pillow(mask, R)   -> n[k]={nx,ny,nz}     -- rounded-edge normals (bevel radius R px) from the distance field
--   X.sphere(cx,cy,r,mask) -> n[k]             -- analytic sphere normals
--   X.cyl(ax,ay,bx,by,mask,wfn) -> n[k], t[k], s[k]  -- cylinder along A->B; s = signed offset across (-1..1)
--   X.light(n, opts)    -> v[k] in [0,1]        -- lambert (+ambient) with optional wrap
--   X.tone(c, mask, v, ramp, opts)            -- paint ramp[ index(v) ]; opts.bias[k] adds tone steps (AO = negative)
-- Keys: k = y*64+x style handled internally via X.K(x,y).
local X = {}
local HP
function X.init(hp) HP = hp return X end
local sqrt, floor, max, min = math.sqrt, math.floor, math.max, math.min
function X.K(x, y) return (y + 256) * 1024 + (x + 256) end
local K = X.K
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
X.L = { norm(-0.55, -0.7, 0.55) }

function X.dist(m)
  local edge = m:grow(1):cut(m)
  local pts = {}
  edge:each(function(x, y) pts[#pts+1] = { x, y } end)
  local d = {}
  m:each(function(x, y)
    local best = 1e9
    for _, p in ipairs(pts) do
      local dx, dy = p[1] - x, p[2] - y
      local q = dx*dx + dy*dy
      if q < best then best = q end
    end
    d[K(x, y)] = sqrt(best) - 0.5
  end)
  return d
end

-- rounded profile: height rises over R px from the edge then is flat. flat=true keeps top planar
function X.pillow(m, R, hscale)
  hscale = hscale or 1
  local d = X.dist(m)
  local function h(x, y)
    local v = d[K(x, y)]
    if not v then return 0 end
    local t = min(v + 0.5, R) / R
    return R * sqrt(1 - (1 - t) ^ 2) * hscale
  end
  local n = {}
  m:each(function(x, y)
    local gx = (h(x + 1, y) - h(x - 1, y)) / 2
    local gy = (h(x, y + 1) - h(x, y - 1)) / 2
    n[K(x, y)] = { norm(-gx, -gy, 1) }
  end)
  return n, d
end

function X.sphere(cx, cy, r, m)
  local n = {}
  m:each(function(x, y)
    local nx, ny = (x - cx) / (r + 0.5), (y - cy) / (r + 0.5)
    local q = 1 - nx*nx - ny*ny
    n[K(x, y)] = { norm(nx, ny, sqrt(max(q, 0.02))) }
  end)
  return n
end

-- cylinder along A->B with half-width wfn(t) (t 0..1); returns mask too if m == nil
function X.cyl(ax, ay, bx, by, wfn, m)
  local vx, vy = bx - ax, by - ay
  local len = sqrt(vx*vx + vy*vy)
  local ux, uy = vx / len, vy / len
  local px, py = -uy, ux           -- perpendicular
  if px + py < 0 then px, py = -px, -py end   -- +s points lower-right (shade side), s<0 = lit side
  local made = m == nil
  if made then m = HP.mask() end
  local n, T, S = {}, {}, {}
  local x0, x1 = floor(min(ax, bx)) - 8, floor(max(ax, bx)) + 8
  local y0, y1 = floor(min(ay, by)) - 8, floor(max(ay, by)) + 8
  for y = y0, y1 do for x = x0, x1 do
    local rx, ry = x - ax, y - ay
    local t = (rx*ux + ry*uy) / len
    local s = rx*px + ry*py
    if t >= 0 and t <= 1 then
      local w = wfn(t)
      if made and math.abs(s) <= w then m:set(x, y) end
      if m:has(x, y) then
        local sn = max(-0.98, min(0.98, s / (w + 0.5)))
        local nz = sqrt(1 - sn*sn)
        n[K(x, y)] = { px * sn, py * sn, nz }
        T[K(x, y)], S[K(x, y)] = t, sn
      end
    end
  end end
  return m, n, T, S
end

function X.light(n, o)
  o = o or {}
  local L = o.L or X.L
  local amb, wrap = o.amb or 0, o.wrap or 0
  local v = {}
  for k, nn in pairs(n) do
    local dl = nn[1]*L[1] + nn[2]*L[2] + nn[3]*L[3]
    dl = (dl + wrap) / (1 + wrap)
    v[k] = max(0, min(1, amb + (1 - amb) * max(dl, 0)))
  end
  return v
end

-- specular (Blinn) term per pixel
function X.spec(n, power, L)
  L = L or X.L
  local hx, hy, hz = norm(L[1], L[2], L[3] + 1)
  local s = {}
  for k, nn in pairs(n) do
    local d = max(0, nn[1]*hx + nn[2]*hy + nn[3]*hz)
    s[k] = d ^ power
  end
  return s
end

-- reflected light from lower-right (cool bounce): grazing pixels facing lower-right
function X.rim(n, L)
  L = L or { norm(0.6, 0.7, -0.1) }
  local r = {}
  for k, nn in pairs(n) do r[k] = max(0, nn[1]*L[1] + nn[2]*L[2] + nn[3]*L[3]) end
  return r
end

-- paint quantised tones. ramp = {dark .. light}; cuts optional (ascending, #ramp-1 thresholds)
function X.tone(c, m, v, ramp, o)
  o = o or {}
  local nR = #ramp
  local idx = {}
  m:each(function(x, y)
    local k = K(x, y)
    local val = v[k] or 0
    local i
    if o.cuts then
      i = 1
      for j, t in ipairs(o.cuts) do if val >= t then i = j + 1 end end
    else
      i = floor(val * nR) + 1
    end
    if o.bias and o.bias[k] then i = i + o.bias[k] end
    i = max(1, min(nR, i))
    idx[k] = i
  end)
  local tok = o.tok or { r = { name = o.name or tostring(ramp) } }
  for k, i in pairs(idx) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    c:put(x, y, ramp[i], tok)
  end
  return idx, tok
end

-- add `amt` to bias for pixels of m within `r` px (4-conn rings) of mask `other`
function X.ao(bias, m, other, r, amt)
  local ring = other:copy()
  for i = 1, r do
    local g = ring:grow(1)
    local new = g:copy():cut(ring)
    new:each(function(x, y) if m:has(x, y) and not other:has(x, y) then
      local k = K(x, y) bias[k] = (bias[k] or 0) + (amt or -1) end end)
    ring = g
  end
  return bias
end

-- simple deterministic hash noise 0..1
function X.hash(x, y, s)
  local h = (x * 374761393 + y * 668265263 + (s or 0) * 144665) % 2147483647
  h = (h ~ (h >> 13)) * 1274126177 % 2147483647
  return (h % 10007) / 10007
end
return X
