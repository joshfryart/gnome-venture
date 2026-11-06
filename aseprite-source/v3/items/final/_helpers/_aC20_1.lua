-- _aC20_1.lua: private helpers for ph/lemongrass-cordial, lemongrass-seed, lentil, lentil-dal (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- blend sphere + pillow normals
function A.body(m, cx, cy, r, R, wS)
  local np = X.pillow(m, R or 5)
  local ns = X.sphere(cx, cy, r, m)
  local n = {}
  wS = wS or 0.6
  for k, a in pairs(np) do local b = ns[k]
    n[k] = { norm(a[1] * (1 - wS) + b[1] * wS, a[2] * (1 - wS) + b[2] * wS, a[3] * (1 - wS) + b[3] * wS) } end
  return n
end

function A.stem(c, pts, wfn, ramp, o)
  o = o or {}
  local m, n, T, S, samp = G.tube(pts, wfn)
  if o.cut then m:cut(o.cut) end
  local idx = A.shade(c, m, n, ramp, { amb = o.amb or 0.14, wrap = o.wrap or 0.3, cuts = o.cuts or (#ramp == 4 and { 0.3, 0.55, 0.8 } or A.CUTS), tok = o.tok, bias = o.bias })
  return m, n, T, S, idx, samp
end

-- grass blade (parallel veins, no branching): returns m, T, S, idx
function A.grass(c, ax, ay, cx, cy, bx, by, w, ramp, o)
  o = o or {}
  local wfn = o.wfn or function(t)
    if t > 0.99 then return -1 end
    return max(0.35, w * (1 - t) ^ (o.pw or 0.6))
  end
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, wfn, { fold = o.fold or 0.35 })
  if o.cut then m:cut(o.cut) end
  local tok = o.tok or { r = { name = "grass" } }
  local idx = G.toneN(c, m, n, ramp, { amb = 0.14, wrap = 0.3, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = tok, bias = o.bias })
  if w >= 1.6 then
    m:each(function(x, y) local k = K(x, y)
      if abs(S[k]) < 0.18 and T[k] < 0.85 then c:put(x, y, ramp[min(#ramp, (idx[k] or 3) + 1)], tok) end end)
  end
  return m, T, S, idx, len
end

function A.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end

-- lens-shaped seed (lentil): flat disc seen at an angle. rim band darker, flat face lighter, glint
function A.lens(c, cx, cy, rx, ry, ang, ramp, o)
  o = o or {}
  local m, n = G.oval(cx, cy, rx, ry, ang, 0.55)
  if o.cut then m:cut(o.cut) end
  local tok = o.tok or { r = { name = "lens" .. cx .. cy } }
  local idx = A.shade(c, m, n, ramp, { amb = 0.1, wrap = 0.3, bias = o.bias, tok = tok })
  -- raised rim ring: inner edge darker on lit side (lip), lighter on shade side
  local inner = m:copy():shrink(1)
  local e = inner:edge()
  e:each(function(x, y) local k = K(x, y) local i = idx[k] or 3
    local lit = (x - cx) + (y - cy) < 0
    if inner:shrink(1):count() > 2 then c:put(x, y, ramp[lit and max(1, i - 1) or min(#ramp, i + 1)], tok) end
  end)
  if not o.noglint then
    local gx, gy = G.specAt(m, n, 30)
    if gx then c:put(gx, gy, ramp[#ramp], tok) if m:has(gx + 1, gy) then c:put(gx + 1, gy, ramp[#ramp], tok) end end
  end
  return m, idx
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
