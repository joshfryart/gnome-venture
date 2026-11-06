-- _aR4_3.lua: private helpers for ph/beetle-shell, ph/bell-clapper, ph/bell-pepper, ph/bell-pepper-seed (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos
A.HP, A.X, A.K = HP, X, K
A.DIR = DIR
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- light + quantise; returns idx, v
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- shift one already-toned pixel by d steps
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- sphere normals blended with a pillow (soft-edged round things)
function A.dome(m, cx, cy, r, R, wS)
  local np = X.pillow(m, R or 3)
  local ns = X.sphere(cx, cy, r, m)
  local n = {}
  wS = wS or 0.6
  for k, a in pairs(np) do local b = ns[k]
    n[k] = { norm(a[1] * (1 - wS) + b[1] * wS, a[2] * (1 - wS) + b[2] * wS, a[3] * (1 - wS) + b[3] * wS) } end
  return n
end

-- ellipsoid normals (rx, ry axis aligned) for any mask
function A.ellN(m, cx, cy, rx, ry, flat)
  local n = {}
  m:each(function(x, y)
    local u, v = (x - cx) / (rx + 0.5), (y - cy) / (ry + 0.5)
    local q = 1 - u*u - v*v
    n[K(x, y)] = { norm(u / (rx + .5) * (flat or 1) * 8, v / (ry + .5) * (flat or 1) * 8, sqrt(max(q, 0.02)) * 8 / ((rx + ry) / 2)) }
  end)
  return n
end

-- kidney: rotated oval with a hilum notch bitten from the +perp side. returns mask, hilum point
function A.kidney(cx, cy, rx, ry, ang, side)
  local ca, sa = cos(ang), sin(ang)
  local m = G.rell(cx, cy, ca, sa, rx + 0.45, ry + 0.45)
  local s = side or 1
  local px, py = -sa * s, ca * s
  local hx, hy = cx + px * (ry + 0.9), cy + py * (ry + 0.9)
  m:cut(G.rell(hx, hy, ca, sa, rx * 0.42, ry * 0.62))
  return m, cx + px * (ry - 0.6), cy + py * (ry - 0.6)
end

function A.pl(pts) return HP.line(pts, 1) end

function A.save(c, name, norecentre)
  if not norecentre then G.recentre(c) end
  c:finish{ outline = true }
  local r = HP.report(c) HP.assertClean(c)
  local out = app.params.out or (DIR .. "/../ph/")
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
  return r
end
return A
