-- _aR21_1.lua: private helpers for ph/blue-poppy-seed, ph/blue-violet-seed, ph/bluebell-seed, ph/blueberry-jam (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm
function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
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
-- ragged tear: cut pixels of m whose along-value f(x,y) is beyond lim + jag noise (end = 0 low end / 1 high end)
function A.tear(m, f, lim, hi, amp, seed)
  local cut = {}
  m:each(function(x, y)
    local t = f(x, y)
    local j = (X.hash(floor(y / 2), floor(x / 2), seed or 1) - 0.5) * (amp or 0.06)
    if (hi and t > lim + j) or (not hi and t < lim + j) then cut[#cut + 1] = { x, y } end
  end)
  for _, p in ipairs(cut) do m.s[K(p[1], p[2])] = nil end
  return m
end
-- pixels of m 4-adjacent to the outside (or to `other`) -> list
function A.border(m, other)
  local out = {}
  m:each(function(x, y)
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do
      local a, b = x + d[1], y + d[2]
      if (not other and not m:has(a, b)) or (other and other:has(a, b) and not m:has(a, b)) then out[#out + 1] = { x, y, d[1], d[2] } return end
    end
  end)
  return out
end
-- round seed: sphere normals, tone, one spec pixel, cool reflected rim on the lower right
function A.bead(c, cx, cy, rx, ry, ramp, o)
  o = o or {}
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    if ((x - cx) / (rx + 0.45))^2 + ((y - cy) / (ry + 0.45))^2 <= 1 then m:set(x, y) end end end
  if o.cutm then m:cut(o.cutm) end
  local n = {}
  m:each(function(x, y)
    local a, b = (x - cx) / (rx + 0.6), (y - cy) / (ry + 0.6)
    n[K(x, y)] = { norm(a, b, sqrt(max(0.03, 1 - a*a - b*b))) }
  end)
  local idx = A.shade(c, m, n, ramp, { bias = o.bias, tok = o.tok, cuts = o.cuts or { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.04, wrap = 0.2 })
  if o.rim then
    local r = X.rim(n)
    m:each(function(x, y) local k = K(x, y) if r[k] > 0.55 and (idx[k] or 9) <= 2 and not (o.bias and o.bias[k]) then c:put(x, y, o.rim, o.tok) end end)
  end
  if not o.nospec then
    local sx, sy = floor(cx - rx * 0.45 + 0.5), floor(cy - ry * 0.45 + 0.5)
    if m:has(sx, sy) then c:put(sx, sy, o.spec or ramp[#ramp], o.tok) end
  end
  return m, idx, n
end
return A
