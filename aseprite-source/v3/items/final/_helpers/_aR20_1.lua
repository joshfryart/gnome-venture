-- _aR20_1.lua: private helpers for ph/birch-log, ph/bird-box, ph/bird-of-paradise-seed, ph/birdbath (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min = math.sqrt, math.floor, math.max, math.min
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm
function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
-- light + quantise a normal field
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end
-- normals of a cylinder with a vertical axis (x0..x1 span); tilt > 0 faces down, < 0 faces up
function A.vnorm(m, x0, x1, tilt)
  local n = {}
  m:each(function(x, y)
    local t = max(-0.97, min(0.97, ((x + 0.5 - x0) / (x1 + 1 - x0)) * 2 - 1))
    local ty = type(tilt) == "function" and tilt(x, y) or (tilt or 0)
    n[K(x, y)] = { norm(t, ty, sqrt(1 - t*t)) }
  end)
  return n
end
-- re-tone one pixel by d steps (uses an idx table from X.tone)
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
