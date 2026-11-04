-- _aB32_1.lua: private helpers for ph/flint, ph/florentine-iris-seed, ph/flower-pot, ph/fonio (final pass, Opus single pass).
-- Read-only use of _aA0_0.lua (-> batch2/_b2g1.lua -> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/_aA0_0.lua")
local B = setmetatable({}, { __index = A })
local HP, X, K = A.HP, A.X, A.K
local floor, max, min = math.floor, math.max, math.min
B.HP, B.X, B.K = HP, X, K
B.OUT = app.params.out or (DIR .. "/../ph/")

-- retone pixels of mask (by idx) with a parallel ramp
function B.retone(c, m, idx, ramp, tok, d)
  m:each(function(x, y) local i = idx[K(x, y)] if i then c:put(x, y, ramp[max(1, min(#ramp, i + (d or 0)))], tok) end end)
end

function B.save(c, name)
  A.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = B.OUT .. name .. ".aseprite", png = B.OUT .. name .. ".png", scale = 1 }
end
return B
