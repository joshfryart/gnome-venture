-- _aB23_5.lua: private helpers for desert-glass, desert-rose-seed, desert-rose-stone, desert-sage (final, Opus single pass).
-- Read-only wrap of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua). Saves next to the calling script.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
-- flat facet: one normal for the whole mask
function A.flatN(m, nx, ny, nz)
  local l = sqrt(nx*nx + ny*ny + nz*nz)
  local n = {}
  m:each(function(x, y) n[K(x, y)] = { nx / l, ny / l, nz / l } end)
  return n
end
-- tone with explicit value table + bias
function A.toneV(c, m, v, ramp, cuts, bias, name)
  return X.tone(c, m, v, ramp, { cuts = cuts, bias = bias, tok = { r = { name = name } } })
end
function A.save(c, dir, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = dir .. name .. ".aseprite", png = dir .. name .. ".png", scale = 1 }
end
function A.here(lvl) return debug.getinfo(lvl or 2, "S").source:match("^@(.*[/\\])[^/\\]*$") end
return A
