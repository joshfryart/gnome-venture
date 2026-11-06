-- _aA8_5.lua: private helpers for ico-rain, ico-rainbow, ico-refresh, ico-ribbon (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi, atan = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.atan
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ico/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local cuts = o.cuts
  if not cuts then
    if #ramp == 5 then cuts = { 0.24, 0.44, 0.64, 0.84 } elseif #ramp == 4 then cuts = { 0.3, 0.55, 0.8 } else cuts = A.CUTS end
  end
  local idx = X.tone(c, m, v, ramp, { cuts = cuts, bias = o.bias, tok = o.tok })
  return idx, v
end

-- normals from a height function h(x,y) (0 outside)
function A.hnorm(m, h, s)
  s = s or 1
  local n = {}
  m:each(function(x, y)
    local gx = (h(x + 1, y) - h(x - 1, y)) / 2 * s
    local gy = (h(x, y + 1) - h(x, y - 1)) / 2 * s
    n[K(x, y)] = { norm(-gx, -gy, 1) }
  end)
  return n
end

-- puffy cloud from bumps {cx,cy,r,front}; flat bottom at ybot. Returns mask, idx, owner bump map.
-- Bumps marked front=true overlap the others: a 1-px crease line (2 tones down) where a front puff sits on a back one.
function A.cloud(c, bumps, ybot, x0, x1, ramp, o)
  o = o or {}
  local m = HP.mask()
  for _, b in ipairs(bumps) do m:add(HP.ellipse(b[1], b[2], b[3], b[3])) end
  m:add(HP.rrect(x0, ybot - (o.baseH or 7), x1, ybot, 3))
  m:cut(HP.rect(0, ybot + 1, 63, 63))
  local d = X.dist(m)
  local own, hh = {}, {}
  m:each(function(x, y)
    local best, bi = -1, 0
    for i, b in ipairs(bumps) do
      local q = b[3] * b[3] - (x - b[1])^2 - (y - b[2])^2
      if q > 0 then local hv = sqrt(q) + (b[4] and 2.5 or 0) if hv > best then best, bi = hv, i end end
    end
    local dv = d[K(x, y)] or 0
    local pill = min(dv + 0.5, 4) -- base slab
    local hv = max(best * 0.85, pill)
    hv = min(hv, (dv + 0.5) * 2.2) -- rounded silhouette
    hh[K(x, y)] = hv own[K(x, y)] = bi
  end)
  local function h(x, y) return hh[K(x, y)] or 0 end
  local n = A.hnorm(m, h, 1)
  local bias = {}
  -- belly: the flat underside sits in shadow
  m:each(function(x, y) if y >= ybot - 1 then bias[K(x, y)] = -1 end end)
  local tok = o.tok or { r = { name = "cloud" } }
  local idx = A.shade(c, m, n, ramp, { amb = o.amb or 0.16, wrap = o.wrap or 0.35, bias = bias, tok = tok })
  -- creases: pixel of a back bump next to a front bump, below the front bump's centre line
  m:each(function(x, y)
    local k = K(x, y) local bi = own[k]
    if bi > 0 and not bumps[bi][4] then
      for _, dd in ipairs{ {1,0}, {-1,0}, {0,-1}, {0,1} } do
        local nk = K(x + dd[1], y + dd[2]) local nb = own[nk]
        if nb and nb > 0 and nb ~= bi and bumps[nb][4] and y < bumps[nb][2] + 1 then
          local i = max(1, (idx[k] or 3) - 2) idx[k] = i c:put(x, y, ramp[i], tok) break
        end
      end
    end
  end)
  return m, idx, own, tok
end

-- annulus arc tube: centre, mid radius R, half width w, angles a0..a1 (radians, screen: clockwise from +x)
function A.arc(cx, cy, R, w, a0, a1)
  local m, n, S, Aa = HP.mask(), {}, {}, {}
  for y = floor(cy - R - w - 2), floor(cy + R + w + 2) do for x = floor(cx - R - w - 2), floor(cx + R + w + 2) do
    local dx, dy = x - cx, y - cy
    local r = sqrt(dx*dx + dy*dy)
    local a = atan(dy, dx)
    while a < a0 do a = a + 2 * pi end
    if a <= a1 and abs(r - R) <= w then
      m:set(x, y)
      local s = max(-0.96, min(0.96, (r - R) / (w + 0.5)))
      local ux, uy = dx / r, dy / r
      n[K(x, y)] = { norm(ux * s, uy * s, sqrt(1 - s*s)) }
      S[K(x, y)], Aa[K(x, y)] = s, a
    end
  end end
  return m, n, S, Aa
end

function A.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end

function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
