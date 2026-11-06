-- _aB1r0_3.lua: private helpers for ph/cardamom, cardamom-seed, cardboard-sheet, carnation-seed (final pass, Opus).
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

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(n) return { r = { name = n } } end

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
end

-- ramp index lookup by colour for a pixel (falls back to `d`)
function A.idxOf(ramp, hex, d) for i, h in ipairs(ramp) do if h == hex then return i end end return d end
function A.bump(c, ramp, x, y, d, tok)
  local i = A.idxOf(ramp, c:get(x, y), nil)
  if i then c:put(x, y, ramp[max(1, min(#ramp, i + d))], tok) end
end

-- jagged torn cut of a blade end. side 0 = base (t small), 1 = tip end. depth in px.
function A.tear(m, T, S, len, w, side, depth, seed)
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    local along = (side == 0) and T[k] * len or (1 - T[k]) * len
    local q = floor((S[k] * (w + 0.6)) / 1.6)
    local j = depth * (0.25 + 0.75 * X.hash(q, seed or 3, 7))
    if along < j then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
end

-- spindle pod from base (bx,by) to tip (tx,ty), half width w. returns mask, normals, U, V (V<0 = lit side), geom
function A.pod(bx, by, tx, ty, w, sharp)
  local cx, cy = (bx + tx) / 2, (by + ty) / 2
  local ang = atan(ty - by, tx - bx)
  local rx = sqrt((tx - bx)^2 + (ty - by)^2) / 2
  local m, n = G.oval(cx, cy, rx, w, ang, 0.8)
  local ca, sa = cos(ang), sin(ang)
  local flip = ((-sa) + ca) > 0 and 1 or -1
  local U, V, cut = {}, {}, {}
  m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / (rx + 0.45)
    local v = flip * (-dx * sa + dy * ca) / (w + 0.45)
    if abs(v) > (max(0, 1 - u * u)) ^ (sharp or 0.7) + 0.05 then cut[#cut + 1] = k end
    U[k], V[k] = u, v
  end)
  for _, k in ipairs(cut) do m.s[k] = nil n[k] = nil end
  return m, n, U, V, { cx = cx, cy = cy, ca = ca, sa = sa, rx = rx, w = w, flip = flip }
end
-- pixel at pod-local (u, v) (v scaled by profile so lines converge at the ends)
function A.podAt(g, u, v, sharp)
  local prof = (max(0, 1 - u * u)) ^ (sharp or 0.7)
  local a, b = u * (g.rx + 0.45), g.flip * v * prof * (g.w + 0.45)
  return floor(g.cx + a * g.ca - b * g.sa + 0.5), floor(g.cy + a * g.sa + b * g.ca + 0.5)
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
