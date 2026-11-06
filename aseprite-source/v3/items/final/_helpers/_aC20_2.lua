-- _aC20_2.lua: private helpers for ph/lentil-seed, lettuce, lettuce-seed, lignum-vitae-seed (final pass, Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- tear a blade: remove pixels whose T is below t0 + jagged offset (per S bin). Returns the new torn edge mask.
function A.tear(m, T, S, t0, amp, seed)
  local rm = {}
  m:each(function(x, y) local k = K(x, y)
    local b = floor((S[k] + 1) * 3.2)
    local j = X.hash(b, 7, seed or 1)
    local j2 = X.hash(b + 1, 7, seed or 1)
    local f = (S[k] + 1) * 3.2 - b
    local off = t0 + amp * (j * (1 - f) + j2 * f) + amp * 0.35 * X.hash(x, y, seed or 1)
    if T[k] < off then rm[#rm + 1] = k end
  end)
  for _, k in ipairs(rm) do m.s[k] = nil end
  local e = HP.mask()
  m:edge():each(function(x, y) local k = K(x, y) if T[k] and T[k] < t0 + amp * 1.6 then e:set(x, y) end end)
  return e
end

-- paint midrib + pinnate veins on a blade
function A.veins(c, m, T, S, len, ramp, o)
  o = o or {}
  local per, sweep, skip = o.per or 5.5, o.sweep or 3.5, o.skip or {}
  m:each(function(x, y) local k = K(x, y)
    if skip[k] then return end
    local s, t = S[k], T[k]
    if abs(s) < (o.rib or 0.14) and t > (o.t0 or 0.02) and t < (o.t1 or 0.92) then
      c:put(x, y, s <= 0 and (o.ribLit or ramp[6]) or ramp[3], o.tok) return end
    local ph = (t * len - abs(s) * sweep) / per + (s > 0 and 0.5 or 0)
    local f = abs((ph - floor(ph)) - 0.5) * 2
    if f > 0.86 and abs(s) > 0.18 and abs(s) < 0.78 and t > 0.08 and t < 0.88 then
      c:put(x, y, s < 0 and ramp[6] or ramp[2], o.tok) end
  end)
end

-- lens / disc seed: oval with flattened normals, a keel rim on the shade side, speckles
function A.lens(c, cx, cy, rx, ry, ang, ramp, o)
  o = o or {}
  local m, n = G.oval(cx, cy, rx, ry, ang, o.flat or 0.55)
  local vis = m:copy()
  if o.under then vis:cut(o.under) end
  local idx = G.toneN(c, vis, n, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, amb = 0.1, wrap = 0.3, tok = o.tok })
  local ca, sa = cos(ang), sin(ang)
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - cx, y - cy
    local u, v = (dx * ca + dy * sa) / (rx + .45), (-dx * sa + dy * ca) / (ry + .45)
    local q = u * u + v * v
    local i = idx[k]
    if q > 0.55 and (dx + dy) > 0 then i = i - 1 end              -- keel rim, shade side
    if q > 0.5 and q < 0.78 and (dx + dy) < -1 then i = i + 1 end -- lit rim
    if o.speck and X.hash(x, y, o.seed or 3) < o.speck then i = i - 1 end
    c:put(x, y, ramp[max(1, min(#ramp, i))], o.tok)
  end)
  return m, n
end

-- small leaflet (rotated ellipse) with pillow light and a lit midrib
function A.leaflet(c, cx, cy, ux, uy, ra, rb, ramp, o)
  o = o or {}
  local m = G.rell(cx, cy, ux, uy, ra, rb)
  if o.cut then m:cut(o.cut) end
  local n = X.pillow(m, o.R or 1.6)
  G.toneN(c, m, n, ramp, { cuts = o.cuts or A.CUTS, amb = 0.14, wrap = 0.3, bias = o.bias, tok = o.tok })
  if ra >= 2.4 then
    for i = -floor(ra) + 1, floor(ra) - 1 do
      local x, y = floor(cx + ux * i + .5), floor(cy + uy * i + .5)
      if m:has(x, y) then c:put(x, y, ramp[o.ribTone or 5], o.tok) end
    end
  end
  return m
end

-- plot a 1px polyline (float points), returns mask
function A.pline(c, pts, hex, tok)
  local m = HP.mask()
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local L = max(abs(b[1] - a[1]), abs(b[2] - a[2]))
    for j = 0, max(1, floor(L * 2)) do local t = j / max(1, floor(L * 2))
      local x, y = floor(a[1] + (b[1] - a[1]) * t + .5), floor(a[2] + (b[2] - a[2]) * t + .5)
      m:set(x, y) if hex then c:put(x, y, hex, tok) end end
  end
  return m
end

function A.save(c, name) G.recentre(c) G.save(c, name) end
return A
