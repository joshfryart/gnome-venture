-- _aA7_5.lua: private helpers for ico-pancakes, ico-party, ico-path, ico-paw (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ico/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUT6 = { 0.16, 0.32, 0.5, 0.68, 0.86 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm
function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(name) return { r = { name = name } } end
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUT6, bias = o.bias, tok = o.tok or A.tok(o.name or "p") })
  return idx, v
end
function A.pil(c, m, R, ramp, o)
  o = o or {}
  local n = X.pillow(m, R, o.hs)
  if o.tilt then for k, v in pairs(n) do n[k] = { norm(v[1] + o.tilt[1], v[2] + o.tilt[2], v[3]) } end end
  local idx = A.shade(c, m, n, ramp, o)
  return idx, n
end
function A.ovl(c, cx, cy, rx, ry, ang, ramp, o)
  o = o or {}
  local m, n = G.oval(cx, cy, rx, ry, ang or 0, o.flat)
  if o.clip then m:clip(o.clip) end
  local idx = A.shade(c, m, n, ramp, o)
  return m, n, idx
end
-- step a painted pixel d tones along its ramp
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end
function A.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end end end
end
-- pixels of m within r rings of other (outside other)
function A.near(m, other, r)
  local g = other:grow(r)
  local out = HP.mask()
  m:each(function(x, y) if g:has(x, y) and not other:has(x, y) then out:set(x, y) end end)
  return out
end
function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
