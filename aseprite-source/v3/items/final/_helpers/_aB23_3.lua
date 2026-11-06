-- _aB23_3.lua: private helpers for damask-rose-seed, darwin-tulip-seed, date, date-chutney (Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua, hp.lua, hpx.lua). Output: out param or ../ph/.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G0 = dofile(DIR .. "/../../batch2/_b2g1.lua")
local G = setmetatable({}, { __index = G0 })
local HP, X, K = G0.HP, G0.X, G0.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
G.OUT = app.params.out or (DIR .. "/../ph/")
function G.new(name) G.name = name return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function G.norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
-- fractional part helper
function G.fr(v) return v - floor(v) end
-- facetted seed: poly mask, ridge A->B; side of ridge toward upper-left is lit facet
function G.facet(m, ax, ay, bx, by, tilt)
  local n0 = X.pillow(m, 1.6)
  local n = {}
  m:each(function(x, y) local k = K(x, y)
    local cr = (bx - ax) * (y - ay) - (by - ay) * (x - ax)
    local px, py = -(by - ay), (bx - ax)
    local l = sqrt(px*px + py*py) px, py = px / l, py / l
    local sd = (cr > 0) and 1 or -1
    local a = n0[k]
    n[k] = { G.norm(a[1] + px * sd * (tilt or 0.45), a[2] + py * sd * (tilt or 0.45), a[3]) }
  end)
  return n
end
function G.fin(c)
  G0.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = G.OUT .. G.name .. ".aseprite", png = G.OUT .. G.name .. ".png", scale = 1 }
end
G.HP, G.X, G.K = HP, X, K
return G
