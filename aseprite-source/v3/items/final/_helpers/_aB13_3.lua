-- _aB13_3.lua: private helpers for ph/bukhara-iris-seed, bushy-tuft, busy-lizzie-seed, butterfly-scales (Opus single pass).
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
function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok }), v
end
-- jagged tear: remove pixels of m beyond a zig-zag line across direction (ux,uy) at origin (ox,oy)
function A.tear(m, ox, oy, ux, uy, amp, per, seed)
  local cut = {}
  m:each(function(x, y)
    local a = (x - ox) * ux + (y - oy) * uy
    local b = -(x - ox) * uy + (y - oy) * ux
    local ph = (b / per) % 1
    local z = (abs(ph - 0.5) * 2 - 0.5) * amp + (X.hash(floor(b / per), 3, seed or 1) - 0.5) * amp
    if a > z then cut[#cut + 1] = { x, y } end
  end)
  for _, p in ipairs(cut) do m.s[K(p[1], p[2])] = nil end
  return m
end
function A.fin(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
