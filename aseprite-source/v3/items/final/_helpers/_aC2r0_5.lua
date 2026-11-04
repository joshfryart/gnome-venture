-- _aC2r0_5.lua: private helpers for ph/myrtle-seed, napa-cabbage, napa-cabbage-seed, naranjilla (final pass, Opus).
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
function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
-- light + tone a normal field; returns idx, v
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end
-- recolour pixel by tone index within a ramp
function A.at(c, x, y, ramp, i, tok) c:put(x, y, ramp[max(1, min(#ramp, i))], tok) end
function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  local r = HP.report(c) HP.assertClean(c)
  if r.margin.l < 5 or r.margin.r < 5 or r.margin.t < 5 or r.margin.b < 5 then print("WARNING margin < 5") end
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
